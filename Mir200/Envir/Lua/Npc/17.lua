npc = {}
-- npc名称：货币兑换
-- npc功能：金币兑换元宝，优先消耗绑定金币
local _config = {}

local _exchange_cfg = {
    [1] = {cost_gold = 1000000, reward_yb = 10000},
    [2] = {cost_gold = 10000000, reward_yb = 100000},
    [3] = {cost_gold = 100000000, reward_yb = 1000000},
}
local EXCHANGE_DAILY_LIMIT = 999

local _count_vars = {
    [1] = VarCfg.J_hbdh[1],
    [2] = VarCfg.J_hbdh[2],
    [3] = "J25",
}

local function _get_day_count(play, idx)
    local key = _count_vars[idx]
    if not key or key == "" then
        return 0
    end
    return tonumber(getplaydef(play, key) or 0) or 0
end

local function _set_day_count(play, idx, num)
    local key = _count_vars[idx]
    if not key or key == "" then
        return
    end
    setplaydef(play, key, tonumber(num or 0) or 0)
end

local function _build_data(play)
    return string.format('{"hbdh1":%d,"hbdh2":%d,"hbdh3":%d}', _get_day_count(play, 1), _get_day_count(play, 2), _get_day_count(play, 3))
end

local function _take_gold_bind_first(play, need, desc)
    need = tonumber(need or 0) or 0
    if need <= 0 then
        return true
    end
    local bind_gold = tonumber(querymoney(play, 1) or 0) or 0
    local gold = tonumber(querymoney(play, 3) or 0) or 0
    if bind_gold + gold < need then
        return false
    end
    if bind_gold > 0 then
        local use_bind = math.min(bind_gold, need)
        if use_bind > 0 then
            changemoney(play, 1, "-", use_bind, desc, true)
            need = need - use_bind
        end
    end
    if need > 0 then
        changemoney(play, 3, "-", need, desc, true)
    end
    return true
end

function npc.main(play,npcid)
    sendluamsg(play,100,npcid,0,0,_build_data(play))
end

function npc.link(play, npcid, p2, p3, msgData)
    local cfg = _exchange_cfg[tonumber(p2) or 0]
    if not cfg then
        return
    end

    local day_count = _get_day_count(play, p2)
    if day_count >= EXCHANGE_DAILY_LIMIT then
        sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[货币兑换]</font><font color=\'#ff0000\'>每日兑换次数已达上限...</font>","Type":9}')
        return
    end

    if not _take_gold_bind_first(play, cfg.cost_gold, "货币兑换") then
        sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[货币兑换]</font><font color=\'#ff0000\'>金币不足...</font>","Type":9}')
        return
    end

    changemoney(play,4,"+",cfg.reward_yb,"货币兑换",true)
    _set_day_count(play, p2, day_count + 1)
    sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[货币兑换]</font><font color=\'#00ff00\'>兑换成功...</font>","Type":9}')
    sendluamsg(play,100,npcid,1,0,_build_data(play))
end

return npc
