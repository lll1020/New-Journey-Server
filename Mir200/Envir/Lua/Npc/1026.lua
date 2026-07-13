local npc = {}

local _return_map = "xtc"
local _return_x = 137
local _return_y = 138
local _return_range = 8

local function _is_cross(play)
    return play and checkkuafu and checkkuafu(play)
end

local function _send_tip(play, msg)
    if play and Player and Player.sendmsgEx then
        Player.sendmsgEx(play, tostring(msg or "") .. "#57")
    end
end

local function _return_home(play)
    mapmove(play, _return_map, _return_x, _return_y, _return_range)
    addhpper(play, "=", 100)
    addmpper(play, "=", 100)
end

function npc.main(play, npcid)
    if not Guard.ensurePlayer(play, npcid) then return end
    if not _is_cross(play) then
        _send_tip(play, "当前不在跨服状态")
        return
    end

    _return_home(play)
    _send_tip(play, "已退出跨服并返回主城")
end

function npc.link(play, npcid, p2, p3)
    if not Guard.ensurePlayer(play, npcid) then return end
    local action = Guard.normalizeAction(play, npcid, p2 or p3)
    if action == nil then return end
    if not Guard.ensureActionAllowed(play, npcid, action, Guard.newActionSet({1})) then return end

    if not _is_cross(play) then
        _send_tip(play, "当前不在跨服状态")
        return
    end

    _return_home(play)
    _send_tip(play, "已退出跨服并返回主城")
end

return npc
