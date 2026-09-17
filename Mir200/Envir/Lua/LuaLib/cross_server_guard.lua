local CrossServerGuard = {}

local USED_VAR = "N$cross_server_used_sec"
local DAY_VAR = "N$cross_server_used_day"
local START_VAR = "N$cross_server_enter_ts"
local NOTICE_VAR = "N$cross_server_notice_until"

local function _clear_legacy_timer(play)
    setplaydef(play, USED_VAR, 0)
    setplaydef(play, DAY_VAR, 0)
    setplaydef(play, START_VAR, 0)
    setplaydef(play, NOTICE_VAR, 0)
end

function CrossServerGuard.check(play, forceNotice)
    if not play then return end
    -- 跨服停留不再限时，只清掉旧版倒计时状态，避免旧延迟消息继续踢人。
    _clear_legacy_timer(play)
end

function CrossServerGuard.leave(play)
    if not play then return end
    _clear_legacy_timer(play)
end

function cross_server_guard_timeout(play)
    if not play then return end
    CrossServerGuard.check(play)
end

GameEvent.add(EventCfg.onKFLogin, function(play)
    CrossServerGuard.check(play)
end, "cross_server_guard")

GameEvent.add(EventCfg.goSwitchMap, function(play)
    CrossServerGuard.check(play, true)
end, "cross_server_guard")

GameEvent.add(EventCfg.onKuaFuEnd, function(play)
    CrossServerGuard.leave(play)
end, "cross_server_guard")

rawset(_G, "__cross_server_guard", CrossServerGuard)
return CrossServerGuard
