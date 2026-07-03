local npc = {}

local _npc_id = 1025
local _state_var = "T$npc_1025_shop"
local _point_var = VarCfg["U_跨服积分"] or "U49"
local _medal_name = "跨服勋章"

local _point_rewards = {
    [1] = {need = 50, reward = {{"千年玄铁", 288}}},
    [2] = {need = 100, reward = {{"五行石", 50}}},
    [3] = {need = 200, reward = {{"灵兽蛋", 3}}},
    [4] = {need = 300, reward = {{"神石宝箱钥匙", 5}}},
}

local _medal_shop = {
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
    data.point_claim = type(data.point_claim) == "table" and data.point_claim or {}
    data.medal_buy = type(data.medal_buy) == "table" and data.medal_buy or {}
    if tostring(data.today or "") ~= _today() then
        data.today = _today()
        data.medal_buy = {}
    end
    return data
end

local function _save_state(play, data)
    Player.setJsonVarByTable(play, _state_var, data or {})
end

local function _point(play)
    return _toint(getplaydef(play, _point_var))
end

local function _medal_count(play)
    return _toint(getbagitemcount(play, _medal_name))
end

local function _build_payload(play)
    local data = _get_state(play)
    _save_state(play, data)
    return {
        point = _point(play),
        medal = _medal_count(play),
        medal_name = _medal_name,
        point_rewards = _point_rewards,
        medal_shop = _medal_shop,
        T_data = data,
    }
end

local function _refresh(play, npcid, msgType)
    sendluamsg(play, 100, npcid or _npc_id, msgType or 0, 0, tbl2json(_build_payload(play)))
end

local function _claim_point_reward(play, npcid, idx)
    local cfg = _point_rewards[_toint(idx)]
    if not cfg then
        Player.sendmsgEx(play, "奖励配置不存在#57")
        return _refresh(play, npcid, 1)
    end
    local data = _get_state(play)
    local key = tostring(idx)
    if _toint(data.point_claim[key]) >= 1 then
        Player.sendmsgEx(play, "该积分奖励已领取#57")
        return _refresh(play, npcid, 1)
    end
    if _point(play) < _toint(cfg.need) then
        Player.sendmsgEx(play, "跨服积分不足#57")
        return _refresh(play, npcid, 1)
    end
    Player.rwjl(play, cfg.reward, "跨服积分领奖", 1, 0)
    data.point_claim[key] = 1
    _save_state(play, data)
    Player.sendmsgEx(play, "跨服积分奖励领取成功#218")
    _refresh(play, npcid, 1)
end

local function _buy_medal_item(play, npcid, idx)
    local cfg = _medal_shop[_toint(idx)]
    if not cfg then
        Player.sendmsgEx(play, "兑换配置不存在#57")
        return _refresh(play, npcid, 2)
    end
    local data = _get_state(play)
    local key = tostring(idx)
    local bought = _toint(data.medal_buy[key])
    local limit = _toint(cfg.limit)
    if limit > 0 and bought >= limit then
        Player.sendmsgEx(play, "今日购买次数已用完#57")
        return _refresh(play, npcid, 2)
    end
    local cost = _toint(cfg.cost)
    if _medal_count(play) < cost then
        Player.sendmsgEx(play, "跨服勋章不足#57")
        return _refresh(play, npcid, 2)
    end
    Player.takeItemByTable(play, {{_medal_name, cost}}, "跨服勋章兑换", nil)
    Player.rwjl(play, cfg.reward, "跨服勋章兑换", 1, 0)
    data.medal_buy[key] = bought + 1
    _save_state(play, data)
    Player.sendmsgEx(play, "兑换成功#218")
    _refresh(play, npcid, 2)
end

function npc.main(play, npcid)
    _refresh(play, npcid, 0)
end

function npc.link(play, npcid, p2, p3, msgData)
    if not Guard.ensurePlayer(play, npcid) then return end
    local action = Guard.normalizeAction(play, npcid, p2)
    if action == nil then return end
    if not Guard.ensureActionAllowed(play, npcid, action, Guard.newActionSet({1, 2, 9})) then return end
    if action == 9 then
        return _refresh(play, npcid, 9)
    end
    local idx = _toint(p3)
    local req = type(msgData) == "table" and msgData or (msgData and msgData ~= "" and json2tbl(msgData) or {})
    if idx <= 0 and type(req) == "table" then
        idx = _toint(req.idx or req.id)
    end
    if action == 1 then
        return _claim_point_reward(play, npcid, idx)
    end
    if action == 2 then
        return _buy_medal_item(play, npcid, idx)
    end
end

return npc
