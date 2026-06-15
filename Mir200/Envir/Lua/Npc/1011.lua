npc = {}

local WDH = rawget(_G, "__wudaohui_module")
if not WDH then
    WDH = {queue = {}, queueIndex = {}, mapPool = {}, battle = {}, rank = {}}
    _G.__wudaohui_module = WDH
end

local UI_NPC_ID = 1011
local LOBBY_MAP = "跨服地图"
local LOBBY_X, LOBBY_Y = 26, 55
local BATTLE_PREFIX = "kftt"
local BATTLE_TIMER_ID = 1
local BATTLE_SECONDS = 180
local WIN_RANK_SCORE, LOSE_RANK_SCORE = 10, 2
local WIN_CROSS_SCORE, LOSE_CROSS_SCORE = 10, 2
local QUEUE_FLAG_VAR = "N$kfdl"
local ENTER_COUNT_VAR = "N$武道大会次数"
local ENTER_DATE_VAR = "S$武道大会次数日期"
local HISTORY_VAR = "T$武道大会战绩"
local PROCESSED_REWARD_VAR = "T$武道大会已发奖励"
local SEASON_VAR = "N$武道大会赛季"
local RANK_SYS_VAR = "A_武道会排行"
local ACTIVE_SYS_VAR = "G_武道大会状态"
local SEASON_SYS_VAR = "G_武道大会赛季"
local SCORE_VAR = "跨服对抗积分"
local CROSS_SCORE_VAR = "跨服积分"
local RANK_REWARDS = {[1] = 100, [2] = 80, [3] = 70, [4] = 60, [5] = 50, [6] = 40, [7] = 30, [8] = 25, [9] = 20, [10] = 15, default = 10}

local function _toint(v, d)
    local n = tonumber(v)
    if n == nil then return d or 0 end
    return n
end

local function _json_decode(raw, defaultValue)
    if type(raw) == "table" then return raw end
    if raw == nil or raw == "" then return defaultValue or {} end
    local ok, data = pcall(json2tbl, raw)
    if ok and type(data) == "table" then return data end
    return defaultValue or {}
end

local function _playvar(play, name)
    if not play then return 0 end
    local ok, value = pcall(getplayvar, play, "HUMAN", name)
    if ok then return _toint(value, 0) end
    ok, value = pcall(getplayvar, play, name)
    return ok and _toint(value, 0) or 0
end

local function _set_playvar(play, name, value)
    if not play then return end
    if pcall(setplayvar, play, "HUMAN", name, _toint(value, 0), 1) then return end
    pcall(setplayvar, play, name, _toint(value, 0), 1)
end

local function _msg(play, text)
    if not play then return end
    sendmsg(play, 1, '{"Msg":"<font color=\'#ff7700\'>[武道大会]</font><font color=\'#00ff00\'>' .. tostring(text or "") .. '</font>","Type":9}')
end

local function _broadcast(text)
    sendmovemsg("0", 1, 254, 0, 300, 5, tostring(text or ""))
end

local function _load_rank()
    WDH.rank = _json_decode(getsysvar(RANK_SYS_VAR), {})
    return WDH.rank
end

local function _save_rank()
    setsysvar(RANK_SYS_VAR, tbl2json(WDH.rank or {}))
end

local function _add_rank_score(play, score)
    score = _toint(score, 0)
    if not play or score <= 0 then return end
    local nextScore = _playvar(play, SCORE_VAR) + score
    _set_playvar(play, SCORE_VAR, nextScore)
    local roleId = tostring(getbaseinfo(play, 2) or "")
    local name = tostring(getbaseinfo(play, 1) or "")
    if roleId == "" then return end
    local rank = _load_rank()
    local found = false
    for _, row in ipairs(rank) do
        if tostring(row[1] or "") == roleId then
            row[2], row[3], found = nextScore, name, true
            break
        end
    end
    if not found then rank[#rank + 1] = {roleId, nextScore, name} end
    table.sort(rank, function(a, b) return _toint(a[2]) > _toint(b[2]) end)
    _save_rank()
end

local function _add_personal_score(play, score)
    score = _toint(score, 0)
    if not play or score <= 0 then return end
    _set_playvar(play, SCORE_VAR, _playvar(play, SCORE_VAR) + score)
end

local function _add_cross_score(play, score)
    score = _toint(score, 0)
    if not play or score <= 0 then return end
    _set_playvar(play, CROSS_SCORE_VAR, _playvar(play, CROSS_SCORE_VAR) + score)
end

local function _add_history(play, opponentName, isWin)
    if not play then return end
    local data = _json_decode(getplaydef(play, HISTORY_VAR), {})
    data[#data + 1] = {tostring(opponentName or "玩家"), isWin and "1" or "0"}
    while #data > 10 do table.remove(data, 1) end
    setplaydef(play, HISTORY_VAR, tbl2json(data))
end

local function _consume_reward_once(play, key)
    key = tostring(key or "")
    if not play or key == "" then return true end
    local data = _json_decode(getplaydef(play, PROCESSED_REWARD_VAR), {})
    if data[key] then
        release_print("武道大会奖励重复回调已拦截", getbaseinfo(play, 1), key)
        return false
    end
    local count = 0
    for _ in pairs(data) do count = count + 1 end
    while count > 100 do
        local oldestKey, oldestTime = nil, nil
        for k, v in pairs(data) do
            local t = _toint(v, 0)
            if oldestTime == nil or t < oldestTime then
                oldestKey, oldestTime = k, t
            end
        end
        if not oldestKey then break end
        data[oldestKey] = nil
        count = count - 1
    end
    data[key] = os.time()
    setplaydef(play, PROCESSED_REWARD_VAR, tbl2json(data))
    return true
end

local function _season_reset_if_needed(play)
    if not play then return end
    local season = _toint(getsysvar(SEASON_SYS_VAR), 0)
    if _toint(getplaydef(play, SEASON_VAR), -1) ~= season then
        _set_playvar(play, SCORE_VAR, 0)
        setplaydef(play, ENTER_COUNT_VAR, 0)
        setplaydef(play, ENTER_DATE_VAR, os.date("%Y%m%d"))
        setplaydef(play, QUEUE_FLAG_VAR, 0)
        setplaydef(play, SEASON_VAR, season)
    end
    local today = os.date("%Y%m%d")
    if tostring(getplaydef(play, ENTER_DATE_VAR) or "") ~= today then
        setplaydef(play, ENTER_COUNT_VAR, 0)
        setplaydef(play, ENTER_DATE_VAR, today)
    end
end

local function _ui_payload(play)
    _season_reset_if_needed(play)
    local rank = _load_rank()
    local pm = {}
    for i, row in ipairs(rank) do
        if i > 20 then break end
        pm[#pm + 1] = {tostring(row[3] or row[1] or ""), _toint(row[2])}
    end
    return {jf = _playvar(play, SCORE_VAR), jl = _json_decode(getplaydef(play, HISTORY_VAR), {}), pm = pm, cs = _toint(getplaydef(play, ENTER_COUNT_VAR), 0)}
end

local function _open_ui(play, buttonState)
    sendluamsg(play, 100, UI_NPC_ID, 0, buttonState or _toint(getplaydef(play, QUEUE_FLAG_VAR), 0), tbl2json(_ui_payload(play)))
end

local function _ensure_map_pool()
    if type(WDH.mapPool) == "table" and #WDH.mapPool > 0 then return end
    WDH.mapPool = {}
    for i = 1, 100 do WDH.mapPool[#WDH.mapPool + 1] = i end
end

local function _take_map()
    _ensure_map_pool()
    return table.remove(WDH.mapPool, 1)
end

local function _return_map(mapIdx)
    mapIdx = _toint(mapIdx, 0)
    if mapIdx <= 0 then return end
    WDH.mapPool = WDH.mapPool or {}
    for _, v in ipairs(WDH.mapPool) do if _toint(v) == mapIdx then return end end
    WDH.mapPool[#WDH.mapPool + 1] = mapIdx
end

local function _remove_queue(roleId)
    roleId = tostring(roleId or "")
    if roleId == "" then return end
    WDH.queueIndex = WDH.queueIndex or {}
    WDH.queueIndex[roleId] = nil
    for i = #(WDH.queue or {}), 1, -1 do
        if tostring(WDH.queue[i][1] or "") == roleId then table.remove(WDH.queue, i) end
    end
end

local function _is_active()
    return _toint(getsysvar(ACTIVE_SYS_VAR), 0) > 0
end

local function _safe_kfbackcall(code, roleId, arg1, arg2)
    if type(kfbackcall) == "function" then
        kfbackcall(code, roleId, tostring(arg1 or ""), tostring(arg2 or ""))
    end
end

function WDH.start()
    if (tonumber(getsysvar(VarCfg["G_开区分钟"]) or 0) or 0) < 1440 then
        release_print("武道大会未开启：开服未满第二天")
        return false
    end
    if not checkkuafuconnect() then
        release_print("武道大会未开启：跨服未连接")
        return false
    end
    setsysvar(ACTIVE_SYS_VAR, 1)
    WDH.queue, WDH.queueIndex = {}, {}
    _ensure_map_pool()
    _broadcast("跨服活动：武道大会已开启，奖励丰厚，请前往跨服参加！")
end

function WDH.stop()
    setsysvar(ACTIVE_SYS_VAR, 0)
    WDH.queue, WDH.queueIndex = {}, {}
    _broadcast("跨服活动：武道大会已结束，未匹配玩家已自动退出队列。")
end

function WDH.rankReward()
    if not checkkuafuserver() then
        return
    end
    local season = _toint(getsysvar(SEASON_SYS_VAR), 0)
    local rank = _load_rank()
    table.sort(rank, function(a, b) return _toint(a[2]) > _toint(b[2]) end)
    for i, row in ipairs(rank) do
        local roleId = tostring(row[1] or "")
        if roleId ~= "" and _toint(row[2]) > 0 then
            _safe_kfbackcall(50, roleId, "__WDH_WEEKLY__", (RANK_REWARDS[i] or RANK_REWARDS.default) .. "|" .. season)
        end
    end
    setsysvar(RANK_SYS_VAR, "{}")
    setsysvar(SEASON_SYS_VAR, season + 1)
    WDH.rank, WDH.queue, WDH.queueIndex = {}, {}, {}
    clearhumcustvar("*", SCORE_VAR)
end

function WDH.match()
    if not checkkuafuserver() or not _is_active() then return end
    WDH.queue = WDH.queue or {}
    table.sort(WDH.queue, function(a, b) return _toint(a[3]) < _toint(b[3]) end)
    while #WDH.queue >= 2 do
        local a = table.remove(WDH.queue, 1)
        local b = table.remove(WDH.queue, 1)
        WDH.queueIndex[tostring(a[1])] = nil
        WDH.queueIndex[tostring(b[1])] = nil
        local mapIdx = _take_map()
        if not mapIdx then
            WDH.queue[#WDH.queue + 1] = a
            WDH.queue[#WDH.queue + 1] = b
            return
        end
        _safe_kfbackcall(22, a[1], "1", b[1])
        _safe_kfbackcall(22, b[1], "1", a[1])
        local p2 = getplayerbyid(b[1])
        if p2 then
            delaygoto(p2, 5000, "@qf_kfjinrdt," .. tostring(a[2]) .. "," .. tostring(b[2]) .. "," .. tostring(mapIdx))
        else
            qf_kfjinrdt(nil, tostring(a[2]), tostring(b[2]), tostring(mapIdx))
        end
    end
end

function WDH.queueUpdate(actor, action, score)
    local roleId = tostring(getbaseinfo(actor, 2) or "")
    if roleId == "" then return end
    _remove_queue(roleId)
    if tostring(action) == "1" then
        WDH.queue, WDH.queueIndex = WDH.queue or {}, WDH.queueIndex or {}
        WDH.queue[#WDH.queue + 1] = {roleId, tostring(getbaseinfo(actor, 1) or ""), _toint(score)}
        WDH.queueIndex[roleId] = true
    end
    release_print("武道大会队列", tbl2json(WDH.queue or {}))
    WDH.match()
end

function WDH.enterBattle(name1, name2, mapIdx)
    mapIdx = _toint(mapIdx, 0)
    local mapName = BATTLE_PREFIX .. tostring(mapIdx)
    local p1 = getplayerbyname(tostring(name1 or ""))
    local p2 = getplayerbyname(tostring(name2 or ""))
    WDH.battle = WDH.battle or {}
    if WDH.battle[mapName] then
        release_print("武道大会重复进入战斗已拦截", mapName, name1, name2)
        _return_map(mapIdx)
        if p1 then _msg(p1, "对战地图占用，请重新报名匹配") end
        if p2 then _msg(p2, "对战地图占用，请重新报名匹配") end
        return
    end
    WDH.battle[mapName] = {mapIdx = mapIdx, start = os.time()}
    if p1 then
        mapmove(p1, mapName, 20, 29, 1)
        addbuff(p1, 20176, 3)
        screffects(p1, "1", 20130, 400, 400, 1, 1, 0)
        setattackmode(p1, 0, 30)
    end
    if p2 then
        mapmove(p2, mapName, 29, 29, 1)
        addbuff(p2, 20176, 3)
        screffects(p2, "1", 20130, 400, 400, 1, 1, 0)
        setattackmode(p2, 0, 30)
    end
    mapeffect("武道大会" .. tostring(mapIdx), mapName, 25, 29, 20126, 3, 0, nil, 0)
    setenvirontimer(mapName, BATTLE_TIMER_ID, 1, "@qf_kfdz," .. tostring(mapIdx))
end

local function _opponent_name(play)
    local target = getbaseinfo(play, 67)
    if target then return tostring(getbaseinfo(target, 1) or "玩家") end
    return "玩家"
end

local function _finish_battle_player(play, isWin, mapIdx, battleKey)
    if not play then return end
    local rankScore = isWin and WIN_RANK_SCORE or LOSE_RANK_SCORE
    local crossScore = isWin and WIN_CROSS_SCORE or LOSE_CROSS_SCORE
    _add_rank_score(play, rankScore)
    local rewardKey = tostring(battleKey or mapIdx) .. ":" .. tostring(getbaseinfo(play, 2) or "")
    _safe_kfbackcall(50, getbaseinfo(play, 2), "__WDH_MATCH__", rankScore .. "|" .. crossScore .. "|" .. (isWin and "1" or "0") .. "|" .. rewardKey)
    _safe_kfbackcall(23, getbaseinfo(play, 2), isWin and "1" or "0", _opponent_name(play))
    _msg(play, isWin and ("对战胜利，排位分+" .. rankScore .. "，跨服积分+" .. crossScore) or ("对战结束，排位分+" .. rankScore .. "，跨服积分+" .. crossScore))
    screffects(play, "1", isWin and 20128 or 20129, 400, 400, 1, 1, 0)
    senddelaymsg(play, "距离离开地图剩余%s", 5, 250, 1, "kf_slwj," .. tostring(mapIdx))
end

function WDH.settle(mapIdx)
    mapIdx = _toint(mapIdx, 0)
    local mapName = BATTLE_PREFIX .. tostring(mapIdx)
    local state = WDH.battle and WDH.battle[mapName]
    if not state then
        setenvirofftimer(mapName, BATTLE_TIMER_ID)
        return
    end
    local players = getplaycount(mapName, 0, 0)
    players = type(players) == "table" and players or {}
    local alive = {}
    for _, player in ipairs(players) do
        if getbaseinfo(player, 0) then alive[#alive + 1] = player end
    end
    local timeout = os.time() - _toint(state.start) >= BATTLE_SECONDS
    if #alive >= 2 and not timeout then return end
    setenvirofftimer(mapName, BATTLE_TIMER_ID)
    _return_map(mapIdx)
    if WDH.battle then WDH.battle[mapName] = nil end
    local battleKey = tostring(mapIdx) .. ":" .. tostring(state.start)
    if #alive == 1 then
        for _, player in ipairs(players) do _finish_battle_player(player, player == alive[1], mapIdx, battleKey) end
        sendmovemsg("0", 1, 253, 0, 200, 1, "玩家《" .. tostring(getbaseinfo(alive[1], 1) or "") .. "》取得武道大会胜利！")
        return
    end
    for _, player in ipairs(players) do _finish_battle_player(player, false, mapIdx, battleKey) end
end

function WDH.mapTick(mapName)
    local mapIdx = string.match(tostring(mapName or ""), "^" .. BATTLE_PREFIX .. "(%d+)$")
    WDH.settle(mapIdx or mapName)
end

function WDH.leave(play, mapIdx)
    mapmove(play, LOBBY_MAP, LOBBY_X, LOBBY_Y, 3)
end

function WDH.matchSuccess(actor, opponentRoleId)
    if not checkkuafuconnect() then
        _msg(actor, "跨服未开启，暂时无法进入对战")
        return
    end
    mapmove(actor, LOBBY_MAP, LOBBY_X, LOBBY_Y, 8)
    sendluamsg(actor, 100, UI_NPC_ID, 3, 0, "")
    bfbackcall(23, getbaseinfo(actor, 2), "1", tostring(opponentRoleId or ""))
    setplaydef(actor, QUEUE_FLAG_VAR, 0)
    _msg(actor, "匹配成功，正在进入对战")
    delaygoto(actor, 300, "@qf_kfdzdjs")
end

function WDH.battleCountdown(play)
    senddelaymsg(play, "距离对战结束%s", BATTLE_SECONDS, 250, 1)
end

function WDH.receiveOpponentPreview(actor, opponentRoleId)
    local target = getplayerbyid(opponentRoleId)
    local data = {}
    if target then
        local weapon = linkbodyitem(target, 1)
        local dress = linkbodyitem(target, 0)
        local shield = linkbodyitem(target, 16)
        data.weaponData = weapon ~= "0" and getstditeminfo(getiteminfo(target, weapon, 2)) or nil
        data.dressData = dress ~= "0" and getstditeminfo(getiteminfo(target, dress, 2)) or nil
        data.shieldData = shield ~= "0" and getstditeminfo(getiteminfo(target, shield, 2)) or nil
    end
    sendluamsg(actor, 100, UI_NPC_ID, 4, 0, tbl2json(data))
end

function WDH.receiveHistory(actor, isWin, opponentName)
    _add_history(actor, tostring(opponentName or "玩家"), tostring(isWin) == "1")
end

function WDH.receiveCrossReward(actor, rewardType, payload)
    if rewardType == "__WDH_MATCH__" then
        local a, b, c, key = string.match(tostring(payload or ""), "([^|]+)|([^|]+)|([^|]+)|([^|]+)")
        if not a then
            a, b, c = string.match(tostring(payload or ""), "([^|]+)|([^|]+)|([^|]+)")
            key = "match:" .. tostring(os.time()) .. ":" .. tostring(getbaseinfo(actor, 2) or "")
        end
        if not _consume_reward_once(actor, "M:" .. tostring(key or "")) then return true end
        local rankScore = _toint(a)
        local crossScore = _toint(b)
        _add_personal_score(actor, rankScore)
        _add_cross_score(actor, crossScore)
        setplaydef(actor, ENTER_COUNT_VAR, _toint(getplaydef(actor, ENTER_COUNT_VAR), 0) + 1)
        _msg(actor, (c == "1" and "武道大会胜利" or "武道大会参与") .. "，跨服积分+" .. crossScore)
        return true
    elseif rewardType == "__WDH_WEEKLY__" then
        local scoreRaw, seasonRaw = string.match(tostring(payload or ""), "([^|]+)|([^|]+)")
        local score = _toint(scoreRaw or payload)
        local season = tostring(seasonRaw or getplaydef(actor, SEASON_VAR) or "")
        if not _consume_reward_once(actor, "W:" .. season .. ":" .. tostring(getbaseinfo(actor, 2) or "")) then return true end
        _add_cross_score(actor, score)
        _set_playvar(actor, SCORE_VAR, 0)
        setplaydef(actor, ENTER_COUNT_VAR, 0)
        setplaydef(actor, ENTER_DATE_VAR, os.date("%Y%m%d"))
        _msg(actor, "武道大会周排行结算，跨服积分+" .. score)
        return true
    end
    return false
end

function WDH.open(play)
    _open_ui(play)
end

function WDH.join(play)
    if not checkkuafuconnect() then
        _msg(play, "跨服未开启，暂时无法参加武道大会")
        return
    end
    if not _is_active() then
        _msg(play, "活动未开启，等待开启后再报名")
        return
    end
    if _toint(getplaydef(play, ENTER_COUNT_VAR), 0) >= 8 then
        _msg(play, "今日跨服对战次数不足")
        return
    end
    bfbackcall(22, getbaseinfo(play, 2), "1", _playvar(play, SCORE_VAR))
    setplaydef(play, QUEUE_FLAG_VAR, 1)
    _msg(play, "报名成功，正在为你匹配对手")
    sendluamsg(play, 100, UI_NPC_ID, 1, 0, "")
end

function WDH.cancel(play)
    if checkkuafuconnect() then
        bfbackcall(22, getbaseinfo(play, 2), "2", _playvar(play, SCORE_VAR))
    end
    setplaydef(play, QUEUE_FLAG_VAR, 0)
    _msg(play, "已取消武道大会匹配")
    sendluamsg(play, 100, UI_NPC_ID, 2, 0, "")
end

function npc.main(play, npcid)
    WDH.open(play)
end

function npc.link(play, npcid, ew, aid, msgData)
    if ew == 1 then
        WDH.join(play)
    elseif ew == 2 then
        WDH.cancel(play)
    else
        WDH.open(play)
    end
end

return npc
