npc = {}

--羿射九日
local _config = Guard.getConfig("npc_675")
local TASK_KEY = "npc_675"
local BOW_NAME = "逐日弓"
local AFFIX_TAG = "[逐日神秘属性]"
local MAX_AFFIX = tonumber(_config and _config.max_num or 9) or 9

local PERCENT_AFFIX_IDS = {
    [21] = true,
    [25] = true,
    [81] = true,
    [242] = true,
    [243] = true,
    [245] = true,
}

local AFFIX_POOL = {
    {
        label = "打怪切割",
        attr_id = 244,
        roll = function()
            return math.random(1000, 10000)
        end,
        desc = function(value)
            return string.format("打怪切割+%d", value)
        end,
    },
    {
        label = "打怪爆率",
        attr_id = 242,
        roll = function()
            return math.random(10, 50) * 100
        end,
        desc = function(value)
            return string.format("打怪爆率+%d%%", math.floor(value / 100))
        end,
    },
    {
        label = "打怪增伤",
        attr_id = 245,
        roll = function()
            return math.random(1, 10) * 100
        end,
        desc = function(value)
            return string.format("打怪增伤+%d%%", math.floor(value / 100))
        end,
    },
    {
        label = "暴击几率",
        attr_id = 21,
        roll = function()
            return math.random(1, 5)
        end,
        desc = function(value)
            return string.format("暴击几率+%d%%", value)
        end,
    },
    {
        label = "移动速度",
        attr_id = 243,
        roll = function()
            return math.random(1, 3)
        end,
        desc = function(value)
            return string.format("移动速度+%d%%", value)
        end,
    },
    {
        label = "增加攻击伤害",
        attr_id = 25,
        roll = function()
            return math.random(1, 5)
        end,
        desc = function(value)
            return string.format("增加攻击伤害+%d%%", value)
        end,
    },
    {
        label = "固定攻击",
        attr_id = 4,
        roll = function()
            return math.random(100, 300)
        end,
        desc = function(value)
            return string.format("固定攻击+%d", value)
        end,
    },
    {
        label = "固定生命",
        attr_id = 1,
        roll = function()
            return math.random(10000, 50000)
        end,
        desc = function(value)
            return string.format("固定生命+%d", value)
        end,
    },
    {
        label = "对怪吸血",
        attr_id = 81,
        roll = function()
            return math.random(1, 3) * 100
        end,
        desc = function(value)
            return string.format("对怪吸血+%d%%", math.floor(value / 100))
        end,
    },
}

local function _is_task_done(play, jq_data)
    if _config and _config.ch and checktitle(play, _config.ch) then
        return true
    end
    local node = jq_data and jq_data[TASK_KEY]
    return (tonumber(node or 0) or 0) >= 2
end

local function _get_equipped_bow(play)
    local where = Player.hasEquipInArtifactSlot(play, BOW_NAME)
    if not where then
        return nil, nil
    end
    local itemobj = linkbodyitem(play, where)
    if not itemobj or itemobj == "0" then
        return nil, nil
    end
    return itemobj, where
end

local function _get_item_json(play, itemobj)
    local ok, item_json = pcall(json2tbl, getitemcustomabil(play, itemobj))
    item_json = ok and type(item_json) == "table" and item_json or {}
    item_json.name = tostring(item_json.name or "")
    item_json.abil = type(item_json.abil) == "table" and item_json.abil or {}
    item_json.zhuri_affixes = type(item_json.zhuri_affixes) == "table" and item_json.zhuri_affixes or {}
    return item_json
end

local function _normalize_affixes(item_json)
    local affixes = {}
    if type(item_json.zhuri_affixes) == "table" then
        for _, one in ipairs(item_json.zhuri_affixes) do
            if type(one) == "table" then
                local attr_id = tonumber(one.attr_id or 0) or 0
                local value = tonumber(one.value or 0) or 0
                if attr_id > 0 and value > 0 then
                    table.insert(affixes, {
                        label = tostring(one.label or "神秘属性"),
                        attr_id = attr_id,
                        value = value,
                        desc = tostring(one.desc or ""),
                    })
                end
            end
        end
    end
    if #affixes == 0 and type(item_json.abil) == "table" then
        for _, abil in ipairs(item_json.abil) do
            if type(abil) == "table" and tostring(abil.t or "") == AFFIX_TAG and type(abil.v) == "table" then
                for _, attr in ipairs(abil.v) do
                    if type(attr) == "table" then
                        local attr_id = tonumber(attr[2] or 0) or 0
                        local value = tonumber(attr[3] or 0) or 0
                        if attr_id > 0 and value > 0 then
                            table.insert(affixes, {
                                label = "神秘属性",
                                attr_id = attr_id,
                                value = value,
                                desc = string.format("属性%d+%d", attr_id, value),
                            })
                        end
                    end
                end
                break
            end
        end
    end
    item_json.zhuri_affixes = affixes
    return affixes
end

local function _rebuild_item_abil(item_json)
    local affixes = _normalize_affixes(item_json)
    local keep = {}
    for _, abil in ipairs(item_json.abil or {}) do
        if type(abil) == "table" and tostring(abil.t or "") ~= AFFIX_TAG then
            table.insert(keep, abil)
        end
    end
    local attr_list = {}
    for idx, one in ipairs(affixes) do
        local attr_id = tonumber(one.attr_id or 0) or 0
        local is_percent = PERCENT_AFFIX_IDS[attr_id] and 1 or 0
        table.insert(attr_list, {254, attr_id, tonumber(one.value or 0) or 0, is_percent, 0, idx, idx})
    end
    if #attr_list > 0 then
        table.insert(keep, {i = #keep, t = AFFIX_TAG, c = 251, v = attr_list})
    end
    item_json.abil = keep
end

local function _build_affix_desc(one)
    local desc = tostring(one and one.desc or "")
    if desc ~= "" then
        return desc
    end
    return string.format("%s+%d", tostring(one and one.label or "神秘属性"), tonumber(one and one.value or 0) or 0)
end

local function _roll_random_affix()
    local cfg = AFFIX_POOL[math.random(1, #AFFIX_POOL)]
    local value = cfg.roll()
    return {
        label = cfg.label,
        attr_id = cfg.attr_id,
        value = value,
        desc = cfg.desc(value),
    }
end

local function _build_client_data(play)
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local itemobj, where = _get_equipped_bow(play)
    local affixes = {}
    if itemobj then
        local item_json = _get_item_json(play, itemobj)
        affixes = _normalize_affixes(item_json)
        if tonumber(item_json.zhuri_percent_format or 0) ~= 1 then
            _rebuild_item_abil(item_json)
            item_json.zhuri_percent_format = 1
            setitemcustomabil(play, itemobj, tbl2json(item_json))
            refreshitem(play, itemobj)
        end
    end
    local affix_list = {}
    for i, one in ipairs(affixes) do
        affix_list[i] = _build_affix_desc(one)
    end
    local arrow_name = _config and _config.cost and _config.cost[1] and _config.cost[1][1] or "箭矢"
    return {
        T_dljq = jq_data,
        key = TASK_KEY,
        max_num = MAX_AFFIX,
        task_done = _is_task_done(play, jq_data) and 1 or 0,
        has_equipped_bow = itemobj and 1 or 0,
        equipped_slot = where or 0,
        equipped_bow_full = (#affixes >= MAX_AFFIX) and 1 or 0,
        affix_count = #affixes,
        affix_list = affix_list,
        bag_bow_count = tonumber(getbagitemcount(play, BOW_NAME) or 0) or 0,
        arrow_count = tonumber(getbagitemcount(play, arrow_name) or 0) or 0,
    }
end

local function _send_state(play, npcid, p2)
    sendluamsg(play, 100, npcid, p2 or 0, 0, tbl2json(_build_client_data(play)))
end

function npc.main(play, npcid)
    if not _config then
        return
    end
    _send_state(play, npcid, 0)
end

function npc.link(play, npcid, ew, aid)
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
    local __guardAllowedActions = Guard.newActionSet({1, 2})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end

    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local taskDone = _is_task_done(play, jq_data)

    if ew == 1 then
        local itemobj = nil
        local where = nil
        itemobj, where = _get_equipped_bow(play)
        if not itemobj then
            Player.sendmsgEx(play, "请先将逐日弓穿戴到背包神器槽位后再射日#57")
            _send_state(play, npcid, 1)
            return
        end

        local item_json = _get_item_json(play, itemobj)
        local affixes = _normalize_affixes(item_json)
        if #affixes >= MAX_AFFIX then
            Player.sendmsgEx(play, "这把逐日弓已满9条词条，请更换新的逐日弓后再射日#57")
            _send_state(play, npcid, 1)
            return
        end

        if not Guard.ensureCost(play, _config.cost) then
            return
        end
        Guard.consumeCost(play, _config.cost, "," .. (_config.name or "剧情任务"))

        local new_affix = _roll_random_affix()
        table.insert(affixes, new_affix)
        item_json.zhuri_affixes = affixes
        _rebuild_item_abil(item_json)
        setitemcustomabil(play, itemobj, tbl2json(item_json))
        refreshitem(play, itemobj)

        if not taskDone then
            jq_data[TASK_KEY] = 1
        end
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        Player.sendmsgEx(play, string.format("射日成功，获得词条：#57|【%s】#218|", _build_affix_desc(new_affix)))

        if (not taskDone) and #affixes >= MAX_AFFIX then
            Guard.clearTaskTemp(jq_data, TASK_KEY)
            jq_data[TASK_KEY] = 2
            Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
            Player.sendmsgEx(play, "|【" .. (_config.name or "任务") .. "】#218|完成#57")
            if _config.ch and not checktitle(play, _config.ch) then
                Player.title_give(play, _config.ch)
            end
            sendluamsg(play, 101, 1005, 0, 0, "rwwc")
            local reward = _config.jl or _config.rwjl
            if reward then
                Player.rwjl(play, reward, (_config.name or "剧情任务") .. "奖励", 1)
            end
            if npcid then
                Guard.closeNpc(play, npcid)
            end
        end
        _send_state(play, npcid, 1)
        return
    end

    if ew == 2 then
        local bagCount = tonumber(getbagitemcount(play, BOW_NAME) or 0) or 0
        if bagCount > 0 then
            Player.sendmsgEx(play, "你的背包中已经有逐日弓了#57")
            _send_state(play, npcid, 1)
            return
        end
        if not _config.hb then
            return
        end
        if not Guard.ensureCost(play, _config.hb) then
            return
        end
        Guard.consumeCost(play, _config.hb, "," .. (_config.name or "剧情任务"))
        giveitem(play, BOW_NAME, 1)
        Player.sendmsgEx(play, "已为你补充新的逐日弓#57")
        _send_state(play, npcid, 1)
    end
end

function Login_jq_675(play)
    Player.del_attlist(play, "后羿射日")
end
GameEvent.add(EventCfg.onLogin, Login_jq_675, "Login_后羿射日")

return npc

