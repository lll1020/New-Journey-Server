npc = {}

--[[
神石合成与图鉴逻辑：
1. 神石槽位固定为 103-110，并受仙府等级开放槽位限制。
2. 合成规则为同阶 10 合 1，可混合同阶不同槽位；全部同槽位时 100% 升对应槽位，否则按投入占比随机。
3. 图鉴按“拥有过”点亮，150 级后收集满指定品质自动补发等级奖励。
4. 宝箱开启统一走本模块，客户端负责播放开箱动画，服务端负责真实开奖与扣除材料。
]]

local _config = Guard.getConfig("npc_53") or {}
local _xianfu_cfg = Guard.getConfig("npc_44") or {}
local _xianfu_var = VarCfg.T_XianFuData or "T47"
local _slot_pos = {103, 104, 105, 106, 107, 108, 109, 110}
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
local _box_name_order = {"神石宝箱", "神石宝箱[史诗级]", "神石宝箱[传说级]"}
--[[
服务端基础状态方法说明：
1. _build_item_attr_by_level(level)
   用途：根据神石等级生成需要挂载到物品上的附加属性表。
   参数：level=神石等级/品质层级。
2. _is_high_dan_active(play)
   用途：判断玩家当前是否处于凝萃神丹生效期。
   参数：play=玩家对象。
3. _load_xianfu(play) / _save_xianfu(play, data)
   用途：读取与保存仙府扩展数据中的神石子数据。
   参数：play=玩家对象；data=待保存的仙府数据表。
4. _get_xianfu_level(play) / _get_open_slot_count(play)
   用途：读取仙府等级以及当前开放的神石槽位数量。
   参数：play=玩家对象。
5. _build_slot_lookup(level)
   用途：按神石品质层级构建“物品名 -> 槽位序号”的映射表。
   参数：level=神石品质层级。
6. _get_stack_count(play, itemobj)
   用途：读取某个物品堆叠数量，兼容单件物品返回 1。
   参数：play=玩家对象；itemobj=物品对象。
7. _choose_slot(slot_counts, need_num)
   用途：根据投入材料的槽位分布，计算合成结果槽位。
   参数：slot_counts=各槽位数量表；need_num=本次合成所需材料数。
8. _take_extra_cost(play, level)
   用途：扣除某些品质合成时需要的额外材料。
   参数：play=玩家对象；level=当前合成品质层级。
9. _mark_owned(play, item_name)
   用途：把某个神石记录为“玩家曾拥有过”，供图鉴点亮使用。
   参数：play=玩家对象；item_name=神石名称。
10. _get_collection_pool() / _get_collection_progress(play, quality_level)
    用途：构建图鉴池并统计某个品质的收集进度。
    参数：play=玩家对象；quality_level=图鉴品质层级。
11. _try_grant_collection_reward(play)
    用途：当图鉴收集满时，检查并发放对应等级奖励。
    参数：play=玩家对象。
12. _is_godstone_slot(where)
    用途：判断装备位是否属于神石专用槽位 103-110。
    参数：where=装备位编号。
13. _refresh_godstone_item(play, itemobj, item_name)
    用途：刷新某颗神石物品自身附加属性与显示数据。
    参数：play=玩家对象；itemobj=物品对象；item_name=物品名。
14. _sync_equipped_items(play)
    用途：同步当前已穿戴神石的图鉴记录和物品属性显示。
    参数：play=玩家对象。
15. _roll_open_pool(pool)
    用途：从指定奖池列表中随机取一个结果。
    参数：pool=可选物品列表。
16. _try_bonus_compose_reward(play)
    用途：凝萃神丹生效时，尝试发放额外暴击神石奖励。
    参数：play=玩家对象。
17. _filter_box_list_by_open_slots(play, item_list)
    用途：按玩家当前已开放的神石槽位过滤开箱候选列表。
    参数：play=玩家对象；item_list=待过滤的神石列表。
]]

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

-- 宝箱只能开出玩家当前已开放槽位对应的神石，避免提前产出未解锁槽位奖励。
local function _filter_box_list_by_open_slots(play, item_list)
    local open_slots = _get_open_slot_count(play)
    local out = {}
    for slot_idx, item_name in ipairs(item_list or {}) do
        if slot_idx <= open_slots and tostring(item_name or "") ~= "" then
            out[#out + 1] = item_name
        end
    end
    return out
end

--[[
服务端面板、开奖与交互方法说明：
1. _build_panel_payload(play)
   用途：组装发给客户端神石面板的动态数据。
   参数：play=玩家对象。
2. _send_panel(play, npcid, p2, p3)
   用途：向客户端发送神石主界面数据。
   参数：play=玩家对象；npcid=当前 NPC 编号；p2=消息类型；p3=预留参数。
3. _pick_box_reward(play, box_name)
   用途：根据宝箱名称、配置概率与已开放槽位，抽取本次开箱奖励。
   参数：play=玩家对象；box_name=宝箱名称。
4. _open_box_by_name(play, npcid, box_name)
   用途：统一处理 NPC 开箱和背包双击开箱逻辑。
   参数：play=玩家对象；npcid=当前 NPC 编号；box_name=宝箱名称。
5. _take_off_all_godstone(play)
   用途：一键卸下玩家已穿戴的全部神石。
   参数：play=玩家对象。
6. _handle_compose(play, npcid, data)
   用途：处理客户端提交的神石合成请求。
   参数：play=玩家对象；npcid=当前 NPC 编号；data=客户端提交的 JSON 字符串。
7. npc.main(play, npcid)
   用途：神石系统服务端主入口，打开面板时下发当前状态。
   参数：play=玩家对象；npcid=当前 NPC 编号。
8. npc.link(play, npcid, ew, aid, data)
   用途：处理神石系统各类点击事件，包括合成、开箱、一键卸下。
   参数：play=玩家对象；npcid=当前 NPC 编号；ew=动作编号；aid=预留参数；data=附带 JSON 数据。
9. _on_login_sync(play)
   用途：玩家登录时同步神石穿戴状态与图鉴奖励检查。
   参数：play=玩家对象。
10. _on_take_on_sync(play, itemobj, where, itemname, makeid)
    用途：穿戴神石后刷新物品属性与图鉴拥有记录。
    参数：play=玩家对象；itemobj=物品对象；where=装备位；itemname=物品名；makeid=物品唯一标识。
11. _on_take_off_sync(play, itemobj, where, itemname, makeid)
    用途：卸下神石时清理物品临时附加显示。
    参数：play=玩家对象；itemobj=物品对象；where=装备位；itemname=物品名；makeid=物品唯一标识。
12. npc.markOwned(play, item_name)
    用途：对外暴露图鉴点亮接口，供其他模块调用。
    参数：play=玩家对象；item_name=神石名称。
13. npc.getCollectionProgress(play)
    用途：对外返回各品质图鉴收集进度。
    参数：play=玩家对象。
14. npc.getPanelPayload(play)
    用途：对外返回当前面板动态数据。
    参数：play=玩家对象。
15. npc.openBoxByName(play, box_name)
    用途：对外暴露按宝箱名称直接开箱的统一入口。
    参数：play=玩家对象；box_name=宝箱名称。
]]
-- 组装客户端需要的动态面板数据，静态配置仍然由客户端 teshudata 负责。
local function _build_panel_payload(play)
    _sync_equipped_items(play)
    local data = _load_xianfu(play)
    local payload = {
        xianfu_level = _get_xianfu_level(play),
        open_slots = _get_open_slot_count(play),
        key_count = tonumber(getbagitemcount(play, "神石宝箱钥匙") or 0) or 0,
        boxes = {},
        owned = {},
        progress = {},
        equipped = {},
    }
    for _, box_name in ipairs(_box_name_order) do
        payload.boxes[box_name] = tonumber(getbagitemcount(play, box_name) or 0) or 0
    end
    for item_name, flag in pairs(data.godstone.owned or {}) do
        if flag then
            payload.owned[tostring(item_name)] = 1
        end
    end
    for quality_level = 1, #(_config.cost or {}) do
        local hit, total = _get_collection_progress(play, quality_level)
        payload.progress[tostring(quality_level)] = {
            hit = hit,
            total = total,
            title = _quality_title[quality_level] or tostring(quality_level),
            reward = _collection_reward[quality_level] or 0,
        }
    end
    for slot_index, where in ipairs(_slot_pos) do
        local itemobj = linkbodyitem(play, where)
        payload.equipped[#payload.equipped + 1] = {
            slot = slot_index,
            where = where,
            item_name = itemobj and itemobj ~= "0" and tostring(getiteminfo(play, itemobj, ConstCfg.iteminfo.name) or "") or "",
        }
    end
    return payload
end

local function _send_panel(play, npcid, p2, p3)
    sendluamsg(play, 100, npcid or 53, p2 or 0, p3 or 0, tbl2json(_build_panel_payload(play)))
end

-- 神石宝箱开启规则与物品使用保持同源，避免 UI 开启与背包双击开启结果不一致。
local function _pick_box_reward(play, box_name)
    local cost = _config.cost or {}
    local open_rate = _config.open_rate or {}
    if box_name == "神石宝箱[史诗级]" then
        local list = _filter_box_list_by_open_slots(play, cost[2] or {})
        return _roll_open_pool(list), "史诗"
    end
    if box_name == "神石宝箱[传说级]" then
        local list = _filter_box_list_by_open_slots(play, cost[3] or {})
        return _roll_open_pool(list), "传说"
    end
    local pool = {
        {weight = tonumber(open_rate.rare or 0) or 0, list = _filter_box_list_by_open_slots(play, cost[1] or {}), title = "稀有"},
        {weight = tonumber(open_rate.epic or 0) or 0, list = _filter_box_list_by_open_slots(play, cost[2] or {}), title = "史诗"},
        {weight = tonumber(open_rate.legendary or 0) or 0, list = _filter_box_list_by_open_slots(play, cost[3] or {}), title = "传说"},
        {weight = tonumber(open_rate.myth or 0) or 0, list = _filter_box_list_by_open_slots(play, cost[4] or {}), title = "神话"},
    }
    local total_weight = 0
    for _, entry in ipairs(pool) do
        if entry.list and #entry.list > 0 and (tonumber(entry.weight) or 0) > 0 then
            total_weight = total_weight + (tonumber(entry.weight) or 0)
        end
    end
    if total_weight <= 0 then
        return nil, nil
    end
    local roll = math.random(total_weight)
    local acc = 0
    for _, entry in ipairs(pool) do
        local weight = tonumber(entry.weight) or 0
        if entry.list and #entry.list > 0 and weight > 0 then
            acc = acc + weight
            if roll <= acc then
                return _roll_open_pool(entry.list), entry.title
            end
        end
    end
    local last = pool[#pool]
    if last and last.list and #last.list > 0 then
        return _roll_open_pool(last.list), last.title
    end
    return nil, nil
end

-- 神石宝箱既支持 NPC 宝箱页开启，也支持背包直接双击开启，最终都走这里。
local function _open_box_by_name(play, npcid, box_name)
    box_name = tostring(box_name or _box_name_order[1])
    if box_name == "" then
        box_name = _box_name_order[1]
    end
    if (tonumber(getbagitemcount(play, box_name) or 0) or 0) < 1 then
        Player.sendmsgEx(play, string.format("背包中没有|%s#249|#57", box_name))
        return false
    end
    local missing_name, missing_num = Player.checkItemNumByTable(play, {{"神石宝箱钥匙", 1}})
    if missing_name then
        Player.sendmsgEx(play, string.format("缺少|%s#249|数量|%d#249", missing_name, missing_num))
        return false
    end
    local reward_name, quality_title = _pick_box_reward(play, box_name)
    if not reward_name or reward_name == "" then
        Player.sendmsgEx(play, "神石宝箱开启失败：奖池为空#57")
        return false
    end
    Player.takeItemByTable(play, {{box_name, 1}, {"神石宝箱钥匙", 1}}, ",神石宝箱开启", nil)
    giveitem(play, reward_name, 1)
    _mark_owned(play, reward_name)
    _try_grant_collection_reward(play)
    sendluamsg(play, 100, npcid or 53, 10, 0, tbl2json({
        box_name = box_name,
        reward_name = reward_name,
        quality_title = quality_title,
        panel = _build_panel_payload(play),
    }))
    Player.sendmsgEx(play, string.format("开启|%s#249|成功，获得#57|【%s】#249|%s#57", box_name, reward_name, quality_title and ("（" .. quality_title .. "）") or ""))
    return true
end

-- 一键卸下当前已装配的全部神石，便于玩家直接切回合成页操作。
local function _take_off_all_godstone(play)
    local changed = 0
    for _, where in ipairs(_slot_pos) do
        local itemobj = linkbodyitem(play, where)
        if itemobj and itemobj ~= "0" then
            callscriptex(play, "TakeOffItem", where)
            changed = changed + 1
        end
    end
    return changed
end

local function _handle_compose(play, npcid, data)
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
    _send_panel(play, npcid, 1, 0)
end

function npc.main(play, npcid)
    _send_panel(play, npcid, 0, 0)
end

function npc.link(play, npcid, ew, aid, data)
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local action = Guard.normalizeAction(play, npcid, ew)
    if action == nil then
        return
    end
    if not Guard.ensureActionAllowed(play, npcid, action, Guard.newActionSet({1, 2, 3})) then
        return
    end
    if action == 1 then
        _handle_compose(play, npcid, data)
        return
    end
    if action == 2 then
        local ok, jsondata = pcall(json2tbl, data or "{}")
        if not ok or type(jsondata) ~= "table" then
            Player.sendmsgEx(play, "神石宝箱开启失败：请求数据错误#57")
            return
        end
        _open_box_by_name(play, npcid, jsondata.box_name)
        return
    end
    if action == 3 then
        _take_off_all_godstone(play)
        _send_panel(play, npcid, 1, 0)
    end
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
    for quality_level = 1, #(_config.cost or {}) do
        local hit, total = _get_collection_progress(play, quality_level)
        out[quality_level] = {
            hit = hit,
            total = total,
            title = _quality_title[quality_level] or tostring(quality_level),
            reward = _collection_reward[quality_level] or 0,
        }
    end
    return out
end

function npc.getPanelPayload(play)
    return _build_panel_payload(play)
end

function npc.openBoxByName(play, box_name)
    return _open_box_by_name(play, 53, box_name)
end

return npc

