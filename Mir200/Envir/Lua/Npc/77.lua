npc = {}

local _config = Guard.getConfig("npc_77") or {}
local _var_name = VarCfg["T_登神之路"] or "T_登神之路"
local _attr_list_name = tostring(_config.attr_list_name or "登神之路")

local function _toint(v) return tonumber(v) or 0 end
local function _god_key(god) return tostring(_toint(god)) end
local function _god_cfg(god) return ((_config.shendao or {})[_toint(god)] or {}) end
local function _path_cfg(god, path) return ((_god_cfg(god).paths or {})[_toint(path)] or {}) end

local function _get_data(play)
    local data = Player.getJsonTableByVar(play, _var_name) or {}
    data.gods = type(data.gods) == "table" and data.gods or {}
    return data
end

local function _god_data(data, god)
    local key = _god_key(god)
    data.gods[key] = type(data.gods[key]) == "table" and data.gods[key] or {}
    local info = data.gods[key]
    info.path = _toint(info.path)
    info.rank = math.max(1, _toint(info.rank))
    info.power = _toint(info.power)
    info.kills = type(info.kills) == "table" and info.kills or {}
    info.cert = _toint(info.cert)
    return info
end

local function _save_data(play, data)
    Player.setJsonVarByTable(play, _var_name, data)
end

local function _set_power(info, value)
    info.power = math.max(0, math.min(_toint(_config.power_max or 1000), _toint(value)))
end

local function _rebuild_attr(play, data)
    local attrs = {}
    for god in pairs(_config.shendao or {}) do
        local info = _god_data(data, god)
        local pcfg = _path_cfg(god, info.path)
        local eventKey = tostring(pcfg.event or "")
        local kill = _toint(info.kills[eventKey])
        for _, attr in ipairs(pcfg.attr or {}) do
            local attrId = _toint(attr[1])
            local val = _toint(attr[2]) * kill
            if attrId > 0 and val > 0 then attrs[#attrs + 1] = {attrId, val, attr[3]} end
        end
    end
    if #attrs > 0 then
        Player.add_attlist(play, _attr_list_name, "=", Player.getAttrTableToStr(attrs), 1)
    else
        Player.del_attlist(play, _attr_list_name)
    end
end

local function _sync_legacy_finish(play, god)
    local legacy = tostring(_god_cfg(god).legacy_task or "")
    if legacy == "" then return end
    local jq = Player.getJsonTableByVar(play, VarCfg.T_dljq) or {}
    if _toint(jq[legacy]) < 2 then
        jq[legacy] = 2
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq)
    end
end

local function _build_payload(play)
    local data = _get_data(play)
    for god in pairs(_config.shendao or {}) do _god_data(data, god) end
    if _toint(_god_data(data, 2).path) > 0 and shaguai and shaguai.jia then
        shaguai.jia(play, 42)
    end
    _rebuild_attr(play, data)
    return {T_data = data, config = _config}
end

local function _send(play, npcid, p2, p3)
    sendluamsg(play, 100, npcid, p2 or 0, p3 or 0, tbl2json(_build_payload(play)))
end

local function _check_cost(play, cost)
    local missName, missNum = Player.checkItemNumByTable(play, cost)
    if missName then
        Player.sendmsgEx(play, string.format("材料不足：#57|【%s】#218| 需要 %d", tostring(missName), _toint(missNum)))
        return false
    end
    return true
end

function npc.main(play, npcid)
    _send(play, npcid, 0, 0)
end

function npc.link(play, npcid, p2, p3, msgData)
    if not Guard.ensurePlayer(play, npcid) then return end
    local action = Guard.normalizeAction(play, npcid, p2)
    if action == nil then return end
    p2 = action
    if not Guard.ensureActionAllowed(play, npcid, p2, Guard.newActionSet({1,2,3,9})) then return end
    local req = json2tbl(msgData) or {}
    local god = _toint(req.god or p3)
    local data = _get_data(play)
    local info = _god_data(data, god)
    if p2 == 1 then
        local path = _toint(req.path)
        if info.path > 0 then Player.sendmsgEx(play, "该神道已经选择过路线#57") return end
        if not _god_cfg(god).name or not _path_cfg(god, path).name then Player.sendmsgEx(play, "神道参数错误#57") return end
        info.path = path
        info.rank = 1
        if god == 2 and shaguai and shaguai.jia then
            shaguai.jia(play, 42)
        end
        _save_data(play, data)
        _rebuild_attr(play, data)
        Player.sendmsgEx(play, string.format("已选择#57|【%s·%s】#218|", _god_cfg(god).name, _path_cfg(god, path).name))
        _send(play, npcid, 1, god)
    elseif p2 == 2 then
        if info.path <= 0 then Player.sendmsgEx(play, "请先选择该神道路线#57") return end
        local nextRank = info.rank + 1
        if nextRank > _toint(_config.max_rank or 9) then Player.sendmsgEx(play, "神道阶级已满#57") return end
        local needPower = _toint((_config.rank_need or {})[nextRank] or 0)
        if info.power < needPower then Player.sendmsgEx(play, string.format("神力值不足，需要 %d", needPower)) return end
        local cost = {{"元宝", nextRank * _toint(_config.upgrade_cost_base_yb or 500000)}, {"业火结晶", nextRank * _toint(_config.upgrade_cost_fire or 10)}}
        if not _check_cost(play, cost) then return end
        Player.takeItemByTable(play, cost, "登神之路升阶")
        info.rank = nextRank
        _save_data(play, data)
        Player.sendmsgEx(play, string.format("%s升至#57|【%d阶】#218|", tostring(_god_cfg(god).name or "神道"), info.rank))
        _send(play, npcid, 2, god)
    elseif p2 == 3 then
        if info.path <= 0 then Player.sendmsgEx(play, "请先选择该神道路线#57") return end
        if info.rank < _toint(_config.max_rank or 9) then Player.sendmsgEx(play, "神道达到九阶后才可自证#57") return end
        if info.cert >= 1 then Player.sendmsgEx(play, "该神道已经完成自证#57") return end
        local needPower = _toint(_config.certify_cost_power or 1000)
        if info.power < needPower then Player.sendmsgEx(play, string.format("神力值不足，需要 %d", needPower)) return end
        local cost = {{"元宝", _toint(_config.certify_cost_yb or 4500000)}}
        if not _check_cost(play, cost) then return end
        Player.takeItemByTable(play, cost, "神道自证")
        _set_power(info, info.power - needPower)
        info.cert = 1
        _save_data(play, data)
        local title = tostring(_god_cfg(god).certify_title or "")
        if title ~= "" then Player.title_give(play, title) end
        _sync_legacy_finish(play, god)
        Player.sendmsgEx(play, string.format("完成#57|【%s】#218|自证", tostring(_god_cfg(god).name or "神道")))
        _send(play, npcid, 3, god)
    else
        _send(play, npcid, 9, 0)
    end
end

function npc.add_power(play, god, num, reason)
    god = _toint(god); num = _toint(num)
    if not play or god <= 0 or num <= 0 then return 0 end
    local data = _get_data(play)
    local info = _god_data(data, god)
    _set_power(info, info.power + num)
    _save_data(play, data)
    if reason and reason ~= "" then Player.sendmsgEx(play, string.format("%s，#57|【%s】#218|+%d", reason, tostring(_god_cfg(god).power_name or "神力值"), num)) end
    return info.power
end

function npc.onKillMon(play, mob)
    local data = _get_data(play)
    for god in pairs(_config.shendao or {}) do
        local info = _god_data(data, god)
        local pcfg = _path_cfg(god, info.path)
        if tostring(pcfg.event or "") == "monster" then
            info.kills.monster = _toint(info.kills.monster) + 1
            _set_power(info, info.power + _toint(_god_cfg(god).power_kill_mon or 1))
            Player.sendmsgEx(play, string.format("击杀六大陆怪物，#57|【%s】#218|+%d", tostring(_god_cfg(god).power_name or "神力值"), _toint(_god_cfg(god).power_kill_mon or 1)))
        end
    end
    _save_data(play, data)
    _rebuild_attr(play, data)
end

local function _on_kill_play(play, target)
    local data = _get_data(play)
    for god in pairs(_config.shendao or {}) do
        local info = _god_data(data, god)
        local pcfg = _path_cfg(god, info.path)
        if tostring(pcfg.event or "") == "player" then
            info.kills.player = _toint(info.kills.player) + 1
            _set_power(info, info.power + _toint(_god_cfg(god).power_kill_player or 20))
            Player.sendmsgEx(play, string.format("击杀玩家，#57|【%s】#218|+%d", tostring(_god_cfg(god).power_name or "神力值"), _toint(_god_cfg(god).power_kill_player or 20)))
        end
    end
    _save_data(play, data)
    _rebuild_attr(play, data)
end

GameEvent.add(EventCfg.onkillplay, _on_kill_play, "登神之路")
return npc
