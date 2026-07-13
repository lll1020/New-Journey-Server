local npc = {}

local _npc_id = 1027
local _state_var = "T$npc_1027_shop"
local _medal_name = "跨服勋章"

local _shop = {
    [1] = {cost = 100, limit = 2, reward = {{"帝星本源", 1}}},
    [2] = {cost = 50, limit = 5, reward = {{"圣星核", 1}}},
    [3] = {cost = 10, limit = 10, reward = {{"星核碎片", 1}}},
    [4] = {cost = 5, limit = 0, reward = {{"深渊门票", 1}}},
}

local function _toint(v)
    return tonumber(v) or 0
end

local function _today()
    return os.date("%Y%m%d")
end

local function _get_state(play)
    local data = Player.getJsonTableByVar(play, _state_var)
    data = type(data) == "table" and data or {}
    data.buy = type(data.buy) == "table" and data.buy or {}
    if tostring(data.today or "") ~= _today() then
        data.today = _today()
        data.buy = {}
    end
    return data
end

local function _save_state(play, data)
    Player.setJsonVarByTable(play, _state_var, data or {})
end

local function _medal_count(play)
    return _toint(getbagitemcount(play, _medal_name))
end

local function _build_payload(play)
    local data = _get_state(play)
    _save_state(play, data)
    return {
        medal = _medal_count(play),
        medal_name = _medal_name,
        shop = _shop,
        T_data = data,
    }
end

local function _refresh(play, npcid, msgType)
    sendluamsg(play, 100, npcid or _npc_id, msgType or 0, 0, tbl2json(_build_payload(play)))
end

local function _buy(play, npcid, idx)
    local cfg = _shop[_toint(idx)]
    if not cfg then
        Player.sendmsgEx(play, "兑换配置不存在#57")
        return _refresh(play, npcid, 1)
    end

    local data = _get_state(play)
    local key = tostring(idx)
    local bought = _toint(data.buy[key])
    local limit = _toint(cfg.limit)
    if limit > 0 and bought >= limit then
        Player.sendmsgEx(play, "今日购买次数已用完#57")
        return _refresh(play, npcid, 1)
    end

    local cost = _toint(cfg.cost)
    if _medal_count(play) < cost then
        Player.sendmsgEx(play, "跨服勋章不足#57")
        return _refresh(play, npcid, 1)
    end

    Player.takeItemByTable(play, {{_medal_name, cost}}, "跨服勋章碎片商店兑换", nil)
    Player.rwjl(play, cfg.reward, "跨服勋章碎片商店兑换", 1, 0)
    data.buy[key] = bought + 1
    _save_state(play, data)
    Player.sendmsgEx(play, "兑换成功#218")
    _refresh(play, npcid, 1)
end

function npc.main(play, npcid)
    _refresh(play, npcid, 0)
end

function npc.link(play, npcid, p2, p3, msgData)
    if not Guard.ensurePlayer(play, npcid) then return end
    local action = Guard.normalizeAction(play, npcid, p2)
    if action == nil then return end
    if not Guard.ensureActionAllowed(play, npcid, action, Guard.newActionSet({1, 9})) then return end
    if action == 9 then
        return _refresh(play, npcid, 9)
    end

    local idx = _toint(p3)
    local req = type(msgData) == "table" and msgData or (msgData and msgData ~= "" and json2tbl(msgData) or {})
    if idx <= 0 and type(req) == "table" then
        idx = _toint(req.idx or req.id)
    end
    return _buy(play, npcid, idx)
end

return npc
