npc = {}
local _config = Guard.getConfig("npc_104")
local _tianshu_cfg = Guard.getConfig("npc_24") or {}
local _tag_prefix = tostring((_config and _config.custom_tag) or "附魔属性")
local _tag_index = tonumber((_config and _config.custom_index) or 1) or 1
local _legacy_tag_prefix = "先天词条"
local _title_attr_list_name = "天书使者称号属性"

local function _get_tianshu_item(play)
    local where = tonumber((_config and _config.where) or _tianshu_cfg.where or 90) or 90
    local itemobj = linkbodyitem(play, where)
    if not itemobj or itemobj == "0" then
        return nil, where
    end
    return itemobj, where
end

local function _normalize_choice(choice)
    choice = type(choice) == "table" and choice or {}
    choice.key = tostring(choice.key or "")
    choice.name = tostring(choice.name or "")
    choice.desc = tostring(choice.desc or "")
    choice.attrs = type(choice.attrs) == "table" and choice.attrs or {}
    return choice
end

local function _get_data(play)
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_天书先天"])
    T_data.refresh_times = tonumber(T_data.refresh_times) or 0
    T_data.preview = _normalize_choice(T_data.preview)
    T_data.saved = _normalize_choice(T_data.saved)
    return T_data
end

local function _save_data(play, T_data)
    Player.setJsonVarByTable(play, VarCfg["T_天书先天"], T_data or {})
end

local function _build_attr_desc(name, values)
    values = values or {}
    if name == "幸运" then
        return string.format("打怪爆率+%d%%", math.floor((tonumber(values[1]) or 0) / 100))
    elseif name == "杀伐" then
        return string.format("攻击伤害+%d%%", tonumber(values[1]) or 0)
    elseif name == "夺金" then
        return string.format("打怪经验+%d%% 金币回收+%d%%", math.floor((tonumber(values[1]) or 0) / 100), math.floor((tonumber(values[2]) or 0) / 100))
    elseif name == "神罚" then
        return string.format("暴击几率+%d%%", tonumber(values[1]) or 0)
    elseif name == "急速" then
        return string.format("攻击速度+%d%%", tonumber(values[1]) or 0)
    end
    return ""
end

local function _build_desc_by_attrs(attrs)
    attrs = attrs or {}
    if #attrs == 2 and tonumber((attrs[1] or {})[2]) == 66 and tonumber((attrs[2] or {})[2]) == 204 then
        return {name = "夺金", desc = _build_attr_desc("夺金", {tonumber((attrs[1] or {})[3]) or 0, tonumber((attrs[2] or {})[3]) or 0})}
    end
    if #attrs == 2 and tonumber((attrs[1] or {})[2]) == 200 and tonumber((attrs[2] or {})[2]) == 201 then
        return {name = "急速", desc = _build_attr_desc("急速", {tonumber((attrs[1] or {})[3]) or 0})}
    end
    local attr_id = tonumber((attrs[1] or {})[2]) or 0
    local value = tonumber((attrs[1] or {})[3]) or 0
    if attr_id == 242 then
        return {name = "幸运", desc = _build_attr_desc("幸运", {value})}
    elseif attr_id == 25 then
        return {name = "杀伐", desc = _build_attr_desc("杀伐", {value})}
    elseif attr_id == 21 then
        return {name = "神罚", desc = _build_attr_desc("神罚", {value})}
    elseif attr_id == 200 or attr_id == 201 then
        return {name = "急速", desc = _build_attr_desc("急速", {value})}
    end
    return {name = "", desc = ""}
end

local function _roll_one(cfg)
    local attrs = {}
    local values = {}
    for _, attr in ipairs(cfg.attrs or {}) do
        local minv = tonumber(attr.min) or 0
        local maxv = tonumber(attr.max) or minv
        local value = minv
        if maxv > minv then
            value = math.random(minv, maxv)
        end
        table.insert(values, value)
        table.insert(attrs, {
            id = tonumber(attr.id) or 0,
            value = value,
            percent = tonumber(attr.percent) or 0,
            color = tonumber(attr.color) or 20,
        })
    end
    return _normalize_choice({
        key = cfg.key,
        name = cfg.name,
        attrs = attrs,
        desc = _build_attr_desc(cfg.name, values),
    })
end

local function _build_preview(play, refresh_times)
    local pool = (_config and _config.pool) or {}
    local count = #pool
    if count <= 0 then
        return {}
    end
    local idx = math.random(1, count) -- 当前洗炼出的属性概率均等
    return _roll_one(pool[idx])
end

local function _get_item_json(play, itemobj)
    local ok, item_json = pcall(json2tbl, getitemcustomabil(play, itemobj))
    item_json = ok and type(item_json) == "table" and item_json or {}
    item_json.abil = type(item_json.abil) == "table" and item_json.abil or {}
    item_json.name = tostring(item_json.name or "")
    return item_json
end

local function _find_custom_group(item_json)
    for i, v in ipairs(item_json.abil or {}) do
        local title = tostring(v.t or "")
        if title == "[" .. _tag_prefix .. "]" or title == "[" .. _legacy_tag_prefix .. "]" then
            return i
        end
        if string.find(title, "^%[" .. _tag_prefix .. "·") or string.find(title, "^%[" .. _legacy_tag_prefix .. "·") then
            return i
        end
    end
    return nil
end

local function _get_current_line(play, T_data)
    T_data = T_data or _get_data(play)
    if tostring((T_data.saved or {}).name or "") ~= "" then
        return _normalize_choice(T_data.saved)
    end
    local itemobj = _get_tianshu_item(play)
    if not itemobj then
        return {}
    end
    local item_json = _get_item_json(play, itemobj)
    local idx = _find_custom_group(item_json)
    if not idx then
        return {}
    end
    local node = item_json.abil[idx] or {}
    local attrs = {}
    for _, one in ipairs(node.v or {}) do
        table.insert(attrs, {
            id = tonumber(one[2]) or 0,
            value = tonumber(one[3]) or 0,
            percent = tonumber(one[4]) or 0,
            color = tonumber(one[5]) or 20,
        })
    end
    local desc_data = _build_desc_by_attrs(node.v or {})
    if tostring(desc_data.name or "") == "" then
        return {}
    end
    return _normalize_choice({name = desc_data.name, desc = desc_data.desc, attrs = attrs})
end

local function _apply_choice(play, choice)
    local itemobj = _get_tianshu_item(play)
    if not itemobj then
        return false
    end
    choice = _normalize_choice(choice)

    for attr_idx = 0, 9 do
        changecustomitemvalue(play, itemobj, attr_idx, "=", 0, _tag_index)
    end
    for i, attr in ipairs(choice.attrs or {}) do
        Player.addModifyCustomAttributes(
            play,
            itemobj,
            _tag_index,
            i - 1,
            1,
            tonumber(attr.color) or 20,
            tonumber(attr.id) or 0,
            tonumber(attr.id) or 0,
            tonumber(attr.percent) or 0,
            tonumber(attr.value) or 0
        )
    end

    local item_json = _get_item_json(play, itemobj)
    local idx = _find_custom_group(item_json)
    if not idx then
        idx = _tag_index + 1
    end
    for fill = 1, idx do
        if type(item_json.abil[fill]) ~= "table" then
            item_json.abil[fill] = {i = fill - 1, t = "", c = 251, v = {}}
        end
    end
    item_json.abil[idx] = item_json.abil[idx] or {i = _tag_index, t = "", c = 251, v = {}}
    item_json.abil[idx].i = _tag_index
    item_json.abil[idx].t = "[" .. _tag_prefix .. "]"
    item_json.abil[idx].c = 251
    setitemcustomabil(play, itemobj, tbl2json(item_json))
    refreshitem(play, itemobj)
    recalcabilitys(play)
    return true
end

local function _refresh_title_attr(play)
    -- 称号属性已统一写入真实称号表，这里只清理旧版脚本附加属性，避免重复叠加。
    Player.del_attlist(play, _title_attr_list_name)
end

local function _grant_refresh_title(play)
    local reward = (_config and _config.reward_title) or {}
    local title_name = tostring(reward.name or "")
    if title_name == "" or checktitle(play, title_name) then
        return
    end
    Player.title_give(play, title_name, 1)
    _refresh_title_attr(play)
    recalcabilitys(play)
    Player.sendmsgEx(play, "恭喜你获得称号：|【" .. title_name .. "】#218|")
end

local function _build_panel_data(play)
    local T_data = _get_data(play)
    local data = {}
    data.T_data = T_data
    data.current = _get_current_line(play, T_data)
    data.preview = _normalize_choice(T_data.preview)
    return data
end

function npc.main(play, npcid)
    if not _config then
        return
    end
    local itemobj = _get_tianshu_item(play)
    if not itemobj then
        Player.sendmsgEx(play, "请先装备#57|【天书】#218|后再操作#57")
        return
    end
    _refresh_title_attr(play)
    sendluamsg(play, 100, npcid, 0, 0, tbl2json(_build_panel_data(play)))
end

function npc.link(play, npcid, ew, aid, msgData)
    if not _config then
        return
    end
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local __guardAction = Guard.normalizeAction(play, npcid, ew)
    if __guardAction == nil then
        return
    end
    ew = __guardAction
    local __guardAllowedActions = Guard.newActionSet({1,2})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end
    local itemobj = _get_tianshu_item(play)
    if not itemobj then
        Player.sendmsgEx(play, "请先装备#57|【天书】#218|后再操作#57")
        return
    end

    local T_data = _get_data(play)
    if ew == 1 then
        local max_refresh = tonumber((_config and _config.max_refresh) or 20) or 20
        if T_data.refresh_times >= max_refresh then
            Player.sendmsgEx(play, string.format("先天词条最多只能刷新#57|【%d次】#218|", max_refresh))
            return
        end
        local cost = (_config and _config.cost) or {{"辉耀水晶",5},{"金币",500000}}
        local name, num = Player.checkItemNumByTable(play, cost)
        if name then
            Player.sendmsgEx(play, string.format("你的#57|【%s】#218|不足：#57|【%d】#218|", name, tonumber(num) or 0))
            return
        end
        Player.takeItemByTable(play, cost, ",天书先天词条", nil)
        T_data.refresh_times = T_data.refresh_times + 1
        T_data.preview = _build_preview(play, T_data.refresh_times)
        setplaydef(play, "N$XYL2_TIANSHU_REFINE", 1)
        Player.trySyncSecondContinentXyl(play)
        _save_data(play, T_data)
        if T_data.refresh_times >= max_refresh then
            _grant_refresh_title(play)
        end
        Player.sendmsgEx(play, "刷新成功，当前获得1条先天词条，可选择保留替换到天书上#57")
        sendluamsg(play, 100, npcid, 1, 0, tbl2json(_build_panel_data(play)))
        return
    end

    local choice = _normalize_choice(T_data.preview)
    if tostring(choice.name or "") == "" then
        Player.sendmsgEx(play, "当前没有可保留的先天词条#57")
        return
    end
    if not _apply_choice(play, choice) then
        Player.sendmsgEx(play, "附魔失败，请重新操作#57")
        return
    end
    T_data.saved = choice
    T_data.preview = {}
    _save_data(play, T_data)

    Player.sendmsgEx(play, "附魔成功：|【" .. tostring(choice.name or "先天词条") .. "】#218| " .. tostring(choice.desc or "") .. "，已替换天书当前词条#57")
    sendluamsg(play, 100, npcid, 2, 0, tbl2json(_build_panel_data(play)))
end

local function _on_login_104(play)
    _refresh_title_attr(play)
end

GameEvent.add(EventCfg.onLoginEnd, _on_login_104, "天书使者")
GameEvent.add(EventCfg.goSwitchMap, _on_login_104, "天书使者")

return npc
