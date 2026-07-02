local CrossServerGuard = {}

local USED_VAR = "N$cross_server_used_sec"
local DAY_VAR = "N$cross_server_used_day"
local START_VAR = "N$cross_server_enter_ts"
local NOTICE_VAR = "N$cross_server_notice_until"
local TIMEOUT_LABEL = "@cross_server_guard_timeout"
local RETURN_MAP, RETURN_X, RETURN_Y, RETURN_RANGE = "xtc", 137, 138, 8
local NORMAL_LIMIT = 30 * 60
local SENIOR_LIMIT = 60 * 60

local function _gbk(bytes)
    local chars = {}
    for i = 1, #bytes do
        chars[i] = string.char(bytes[i])
    end
    return table.concat(chars)
end

local TITLE_SENIOR = _gbk({184,223,188,182,205,230,188,210})
local TITLE_SUPREME = _gbk({214,193,215,240,205,230,188,210})
local MSG_LEFT = _gbk({191,231,183,254,202,163,211,224,202,177,188,228,37,115})
local MSG_TIMEOUT = _gbk({191,231,183,254,205,163,193,244,202,177,188,228,210,209,211,195,205,234,163,172,210,209,183,181,187,216,214,247,179,199})
local MSG_NOT_ENOUGH = _gbk({191,231,183,254,202,163,211,224,202,177,188,228,178,187,215,227,163,172,210,209,183,181,187,216,214,247,179,199})

local function _toint(v, d)
    return tonumber(v or d or 0) or d or 0
end

local function _today()
    return tonumber(os.date("%Y%m%d")) or 0
end

local function _sync_day(play)
    local today = _today()
    if _toint(getplaydef(play, DAY_VAR), 0) ~= today then
        setplaydef(play, DAY_VAR, today)
        setplaydef(play, USED_VAR, 0)
        setplaydef(play, START_VAR, 0)
        setplaydef(play, NOTICE_VAR, 0)
    end
end

local function _is_cross(play)
    return play and checkkuafu and checkkuafu(play)
end

local function _limit_seconds(play)
    if checktitle and checktitle(play, TITLE_SUPREME) then
        return 0
    end
    if checktitle and checktitle(play, TITLE_SENIOR) then
        return SENIOR_LIMIT
    end
    return NORMAL_LIMIT
end

local function _return_home(play, msg)
    if not play then return end
    setplaydef(play, START_VAR, 0)
    if Player and Player.sendmsgEx then
        Player.sendmsgEx(play, tostring(msg or MSG_TIMEOUT) .. "#57")
    end
    mapmove(play, RETURN_MAP, RETURN_X, RETURN_Y, RETURN_RANGE)
    addhpper(play, "=", 100)
    addmpper(play, "=", 100)
end

local function _settle_used(play)
    _sync_day(play)
    local startAt = _toint(getplaydef(play, START_VAR), 0)
    if startAt <= 0 then
        return _toint(getplaydef(play, USED_VAR), 0)
    end
    local now = os.time()
    local used = _toint(getplaydef(play, USED_VAR), 0) + math.max(0, now - startAt)
    setplaydef(play, USED_VAR, used)
    setplaydef(play, START_VAR, 0)
    return used
end

local function _current_used(play)
    _sync_day(play)
    local used = _toint(getplaydef(play, USED_VAR), 0)
    local startAt = _toint(getplaydef(play, START_VAR), 0)
    if startAt > 0 then
        used = used + math.max(0, os.time() - startAt)
    end
    return used
end

local function _start_if_needed(play)
    _sync_day(play)
    if _toint(getplaydef(play, START_VAR), 0) <= 0 then
        setplaydef(play, START_VAR, os.time())
    end
end

local function _send_countdown(play, left, force)
    if not play or left <= 0 then return end
    local noticeUntil = _toint(getplaydef(play, NOTICE_VAR), 0)
    if not force and noticeUntil > os.time() + 3 then
        return
    end
    setplaydef(play, NOTICE_VAR, os.time() + left)
    senddelaymsg(play, MSG_LEFT, left, 250, 1, TIMEOUT_LABEL)
end

function CrossServerGuard.check(play, forceNotice)
    if not play then return end
    _sync_day(play)
    if not _is_cross(play) then
        if _toint(getplaydef(play, START_VAR), 0) > 0 then
            _settle_used(play)
        end
        return
    end

    local limit = _limit_seconds(play)
    if limit <= 0 then
        setplaydef(play, START_VAR, 0)
        return
    end

    _start_if_needed(play)
    local left = limit - _current_used(play)
    if left <= 0 then
        _settle_used(play)
        _return_home(play, MSG_NOT_ENOUGH)
        return
    end
    _send_countdown(play, left, forceNotice)
end

function CrossServerGuard.leave(play)
    if not play then return end
    _settle_used(play)
end

function cross_server_guard_timeout(play)
    if not play then return end
    if not _is_cross(play) then
        _settle_used(play)
        return
    end
    local limit = _limit_seconds(play)
    if limit <= 0 then
        return
    end
    if limit - _current_used(play) <= 1 then
        _settle_used(play)
        _return_home(play, MSG_TIMEOUT)
    else
        CrossServerGuard.check(play)
    end
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
