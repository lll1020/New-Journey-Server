npc = {}

--[[
神石合成与图鉴逻辑：
1. 神石槽位固定为 103-110，并受仙府等级开放槽位限制。
2. 合成规则为同阶 10 合 1，可混合同阶不同槽位；全部同槽位时 100% 升对应槽位，否则按投入占比随机。
3. 图鉴按“拥有过”点亮，150 级后收集满指定品质自动补发等级奖励。
]]

local _config = Guard.getConfig("npc_53") or {}
local _xianfu_cfg = Guard.getConfig("npc_44") or {}
local _xianfu_var = VarCfg.T_XianFuData or "T47"
local _slot_pos = {103, 104, 105, 106, 107, 108, 109, 110}
local _artifact_attr_list = "神石属性"
local _quality_title = {
    [1] = "稀有",
    [2] = "史诗",
    [3] = "传说",
    [4] = "神话",
}
local _collection_reward = {
    [1] = 1,
    [2] = 2,
    [3] = 5,
    [4] = 10,
}

-- 神石临时属性统一挂在物品自身，当前先保留切割成长显示。
local function _build_item_attr_by_level(level)
    local attrs = {}
    level = tonumber(level or 0) or 0
    if level > 0 then
        attrs[244] = level * 100
    end
    return attrs
end

-- 凝萃神丹生效时，合成神石有 30% 几率额外暴击出 1 颗稀有/史诗神石。
local function _is_high_dan_active(play)
    local expireAt = tonumber(getplaydef(play, "N$xf_dan_high_expire") or 0) or 0
    return expireAt > os.time()
end

local function _load_xianfu(play)
    local data = Player.getJsonTableByVar(play, _xianfu_var) or {}
    if type(data) ~= "table" then
        data = {}
    end
    data.level = tonumber(data.level or 1) or 1
    data.godstone = data.godstone or {}
    data.godstone.owned = data.godstone.owned or {}
    data.godstone.reward_claimed = data.godstone.reward_claimed or {}
    return data
end

local function _save_xianfu(play, data)
    Player.setJsonVarByTable(play, _xianfu_var, data)
end

local function _get_xianfu_level(play)
    local data = _load_xianfu(play)
    return tonumber(data.level or 1) or 1
end

local function _get_open_slot_count(play)
    local lv = _get_xianfu_level(play)
    local cfg = (_xianfu_cfg.level_cfg or {})[lv] or {}
    return tonumber(cfg.open_slots or 0) or 0
end

local function _build_slot_lookup(level)
    local slot_list = _config.cost and _config.cost[level]
    if type(slot_list) ~= "table" then
        return nil, nil
    end
    local lookup = {}
    for idx, name in ipairs(slot_list) do
        lookup[name] = idx
    end
    return slot_list, lookup
end

local function _get_stack_count(play, itemobj)
    local count = tonumber(getiteminfo(play, itemobj, ConstCfg.iteminfo.overlap) or 0) or 0
    if count <= 0 then
        count = 1
    end
    return count
end

-- 混合同阶神石时按投入数量占比抽取目标槽位。
local function _choose_slot(slot_counts, need_num)
    local unique = 0
    local only_slot = nil
    local total = 0
    for slot_idx, count in pairs(slot_counts or {}) do
        unique = unique + 1
        only_slot = slot_idx
        total = total + (tonumber(count) or 0)
    end
    if unique <= 0 or total ~= need_num then
        return nil
    end
    if unique == 1 then
        return only_slot, true, total
    end
    local roll = math.random(total)
    local acc = 0
    for slot_idx, count in pairs(slot_counts) do
        acc = acc + (tonumber(count) or 0)
        if roll <= acc then
            return slot_idx, false, count
        end
    end
    return nil
end

local function _take_extra_cost(play, level)
    local extra = _config.extra_cost and _config.extra_cost[level]
    if not extra or #extra <= 0 then
        return true
    end
    local name, num = Player.checkItemNumByTable(play, extra)
    if name then
        Player.sendmsgEx(play, string.format("合成失败：缺少|%s#249|数量|%d#249", name, num))
        return false
    end
    Player.takeItemByTable(play, extra, ",神石合成", nil)
    return true
end

local function _mark_owned(play, item_name)
    item_name = tostring(item_name or "")
    if item_name == "" then
        return false
    end
    local data = _load_xianfu(play)
    if data.godstone.owned[item_name] then
        return false
    end
    data.godstone.owned[item_name] = 1
    _save_xianfu(play, data)
    return true
end

local function _get_collection_pool()
    local pool = {}
    for quality_level, list in pairs(_config.cost or {}) do
        pool[quality_level] = {}
        for _, item_name in ipairs(list or {}) do
            pool[quality_level][tostring(item_name)] = true
        end
    end
    return pool
end

local _collection_pool = _get_collection_pool()

local function _get_collection_progress(play, quality_level)
    local data = _load_xianfu(play)
    local owned = data.godstone.owned or {}
    local pool = _collection_pool[quality_level] or {}
    local total = 0
    local hit = 0
    for item_name, _ in pairs(pool) do
        total = total + 1
        if owned[item_name] then
            hit = hit + 1
        end
    end
    return hit, total
end

-- 图鉴奖励只在 150 级后发放，且每个品质只补一次等级。
local function _try_grant_collection_reward(play)
    local role_level = tonumber(getbaseinfo(play, ConstCfg.gbase.level) or 0) or 0
    if role_level < 150 then
        return
    end
    local data = _load_xianfu(play)
    local changed = false
    for quality_level, add_level in pairs(_collection_reward) do
        local hit, total = _get_collection_progress(play, quality_level)
        local reward_key = tostring(quality_level)
        if total > 0 and hit >= total and not data.godstone.reward_claimed[reward_key] then
            data.godstone.reward_claimed[reward_key] = 1
            changed = true
            local _, real_add = Player.addRoleLevel(play, add_level, false)
            if (tonumber(real_add or 0) or 0) > 0 then
                Player.sendmsgEx(play, string.format("神石图鉴【%s】收集完成，获得等级+%d#57", _quality_title[quality_level] or tostring(quality_level), add_level))
            end
        end
    end
    if changed then
        _save_xianfu(play, data)
    end
end

local function _get_godstone_equipped_count(play)
    local count = 0
    for _, where in ipairs(_slot_pos) do
        local itemobj = linkbodyitem(play, where)
        if itemobj and itemobj ~= "0" then
            count = count + 1
        end
    end
    return count
end

local function _is_godstone_slot(where)
    for _, pos in ipairs(_slot_pos) do
        if pos == where then
            return true
        end
    end
    return false
end

-- 神石属性显示直接挂在神石物品上，避免依赖额外面板计算。
local function _refresh_godstone_item(play, itemobj, item_name)
    if not itemobj or itemobj == "0" then
        return
    end
    local item_name_real = tostring(item_name or getiteminfo(play, itemobj, ConstCfg.iteminfo.name) or "")
    local level_found = nil
    for level, list in pairs(_config.cost or {}) do
        for _, cfg_name in ipairs(list or {}) do
            if cfg_name == item_name_real then
                level_found = tonumber(level) or 0
                break
            end
        end
        if level_found then
            break
        end
    end
    if not level_found then
        return
    end
    setitemaddvalue(play, itemobj, 2, 3, level_found)
    local attrs = _build_item_attr_by_level(level_found)
    local attr_str = Player.getAttrTableToStr(attrs)
    setaddnewabil(play, -2, "=", attr_str, itemobj)
    refreshitem(play, itemobj)
end

local function _sync_equipped_items(play)
    for _, where in ipairs(_slot_pos) do
        local itemobj = linkbodyitem(play, where)
        if itemobj and itemobj ~= "0" then
            local item_name = getiteminfo(play, itemobj, ConstCfg.iteminfo.name)
            _mark_owned(play, item_name)
            _refresh_godstone_item(play, itemobj, item_name)
        end
    end
end

local function _roll_open_pool(pool)
    if type(pool) ~= "table" or #pool <= 0 then
        return nil
    end
    return pool[math.random(#pool)]
end

local function _try_bonus_compose_reward(play)
    if not _is_high_dan_active(play) then
        return nil
    end
    if math.random(10000) > 3000 then
        return nil
    end
    local config = Guard.getConfig("npc_53") or {}
    local candidate = {}
    for _, level in ipairs({1, 2}) do
        for _, name in ipairs((config.cost and config.cost[level]) or {}) do
            candidate[#candidate + 1] = name
        end
    end
    local reward_name = _roll_open_pool(candidate)
    if not reward_name then
        return nil
    end
    giveitem(play, reward_name, 1)
    _mark_owned(play, reward_name)
    return reward_name
end

function npc.main(play, npcid)
    sendluamsg(play, 100, npcid, 0, 0, "")
end

function npc.link(play, npcid, ew, aid, data)
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local action = Guard.normalizeAction(play, npcid, ew)
    if action == nil then
        return
    end
    if not Guard.ensureActionAllowed(play, npcid, action, Guard.newActionSet({1})) then
        return
    end
    if action ~= 1 then
        return
    end

    local ok, jsondata = pcall(json2tbl, data or "{}")
    if not ok or type(jsondata) ~= "table" then
        Player.sendmsgEx(play, "合成失败：请重新提交数据#57")
        return
    end
    if type(jsondata.itemlist) ~= "table" then
        Player.sendmsgEx(play, "合成失败：无法判断物品#57")
        return
    end

    local total_items = #jsondata.itemlist
    if total_items ~= (_config.needitemnum or 10) then
        Player.sendmsgEx(play, "合成失败：请放入正确物品数量#57")
        return
    end

    local level = tonumber(jsondata.item_level or 0) or 0
    if level <= 0 then
        Player.sendmsgEx(play, "合成失败：物品等级无效#57")
        return
    end

    local current_list, slot_lookup = _build_slot_lookup(level)
    local next_list = _config.cost and _config.cost[level + 1]
    if not current_list or not slot_lookup or not next_list then
        Player.sendmsgEx(play, "合成失败：已达最高等级或配置缺失#57")
        return
    end

    local consume_map = {}
    local slot_counts = {}
    for _, raw_idx in ipairs(jsondata.itemlist) do
        local make_idx = tostring(raw_idx)
        local itemobj = getitembymakeindex(play, make_idx)
        if not itemobj then
            Player.sendmsgEx(play, "合成失败：存在材料已被使用#57")
            return
        end
        local item_name = getiteminfo(play, itemobj, ConstCfg.iteminfo.name)
        local slot_idx = slot_lookup[item_name]
        if not slot_idx then
            Player.sendmsgEx(play, "合成失败：存在非当前等级材料#57")
            return
        end
        local info = consume_map[make_idx]
        if not info then
            info = {count = 0, total = _get_stack_count(play, itemobj)}
            consume_map[make_idx] = info
        end
        info.count = info.count + 1
        if info.count > info.total then
            Player.sendmsgEx(play, "合成失败：材料数量不足#57")
            return
        end
        slot_counts[slot_idx] = (slot_counts[slot_idx] or 0) + 1
    end

    local chosen_slot, guaranteed, slot_weight = _choose_slot(slot_counts, _config.needitemnum or 10)
    if not chosen_slot then
        Player.sendmsgEx(play, "合成失败：未找到可用槽位#57")
        return
    end

    local reward_name = next_list[chosen_slot]
    if not reward_name or reward_name == "" then
        Player.sendmsgEx(play, "合成失败：未找到对应奖励#57")
        return
    end

    if not _take_extra_cost(play, level) then
        return
    end

    for make_idx, info in pairs(consume_map) do
        delitembymakeindex(play, make_idx, info.count)
    end

    giveitem(play, reward_name, 1)
    _mark_owned(play, reward_name)
    local bonus_reward = _try_bonus_compose_reward(play)
    _try_grant_collection_reward(play)

    local tip = guaranteed and "（100%）" or string.format("（%d/%d）", tonumber(slot_weight or 0) or 0, _config.needitemnum or 10)
    if bonus_reward then
        Player.sendmsgEx(play, string.format("合成成功，获得：|%s#249|%s；凝萃神丹额外暴击获得：|%s#249|#57", reward_name, tip, bonus_reward))
    else
        Player.sendmsgEx(play, string.format("合成成功，获得：|%s#249|%s#57", reward_name, tip))
    end
    sendluamsg(play, 100, npcid, 1, 0, "")
end

local function _on_login_sync(play)
    _sync_equipped_items(play)
    _try_grant_collection_reward(play)
end
GameEvent.add(EventCfg.onLogin, _on_login_sync, "godstone_sync_login")

local function _on_take_on_sync(play, itemobj, where, itemname, makeid)
    if not _is_godstone_slot(where) then
        return
    end
    local open_count = _get_open_slot_count(play)
    if open_count <= 0 then
        Player.sendmsgEx(play, "当前仙府等级尚未解锁神石槽位#57")
        return false
    end
    local equipped = _get_godstone_equipped_count(play)
    if equipped > open_count then
        Player.sendmsgEx(play, string.format("当前仙府等级仅开放%d个神石槽位#57", open_count))
        return false
    end
    if itemobj and itemobj ~= "0" then
        local item_name = itemname or getiteminfo(play, itemobj, ConstCfg.iteminfo.name)
        _mark_owned(play, item_name)
        _refresh_godstone_item(play, itemobj, item_name)
        _try_grant_collection_reward(play)
    end
end
GameEvent.add(EventCfg.onTakeOnEx, _on_take_on_sync, "godstone_sync_takeon")

local function _on_take_off_sync(play, itemobj, where, itemname, makeid)
    if not _is_godstone_slot(where) then
        return
    end
    if itemobj and itemobj ~= "0" then
        setitemaddvalue(play, itemobj, 2, 3, 0)
        refreshitem(play, itemobj)
    end
end
GameEvent.add(EventCfg.onTakeOffEx, _on_take_off_sync, "godstone_sync_takeoff")

function npc.markOwned(play, item_name)
    local changed = _mark_owned(play, item_name)
    _try_grant_collection_reward(play)
    return changed
end

function npc.getCollectionProgress(play)
    local out = {}
    for quality_level, _ in pairs(_config.cost or {}) do
        local hit, total = _get_collection_progress(play, quality_level)
        out[quality_level] = {
            hit = hit,
            total = total,
            title = _quality_title[quality_level] or tostring(quality_level),
        }
    end
    return out
end

return npc
