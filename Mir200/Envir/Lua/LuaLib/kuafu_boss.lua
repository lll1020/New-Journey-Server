local M = {}
local MAP = "跨服战场"
local BOSS = "跨服boss—[活动]"
local STATE = "N$kuafu_boss_active"
local ENTERED = "S$kuafu_boss_entered"
local function point(play, n, reason)
    local varName = (VarCfg and VarCfg["U_跨服积分"]) or "U_跨服积分"
    local value = tonumber(getplaydef(play, varName) or 0) or 0
    setplaydef(play, varName, value + (tonumber(n) or 0))
    if reason and reason ~= "" and Player and Player.sendmsgEx then
        Player.sendmsgEx(play, tostring(reason) .. "：+" .. tostring(n) .. "跨服积分#57")
    end
end
local function players()
    return getobjectinmap(MAP, 0, 0, 999, 1) or {}
end
local function notify(text)
    sendmovemsg("0", 1, 254, 0, 300, 1, text)
    sendmovemsg("0", 1, 254, 0, 270, 1, text)
end
function jqr_kuafu_boss()
    if not checkkuafuconnect() then return end
    killmonsters(MAP, BOSS, 0, false)
    if tonumber(getsysvar(STATE) or 0) == 1 then return end
    genmonex(MAP, 38, 41, BOSS, 2, 1, 0, 54, "", 0)
    setsysvar(STATE, 1)
    notify("讨伐BOSS活动已经开启，跨服boss—[活动]现身于跨服战场！")
end
GameEvent.add(EventCfg.goSwitchMap, function(play)
    if tonumber(getsysvar(STATE) or 0) ~= 1 then return end
    if tostring(getbaseinfo(play, 3) or "") ~= MAP then return end
    if tonumber(getplaydef(play, ENTERED) or 0) == 1 then return end
    setplaydef(play, ENTERED, 1)
    point(play, 10, "讨伐BOSS参与奖励")
end, "kuafu_boss_enter")
GameEvent.add(EventCfg.onKillMon, function(play, mob)
    if not play or not mob or tonumber(getsysvar(STATE) or 0) ~= 1 then return end
    if tostring(getbaseinfo(mob, 1) or "") ~= BOSS then return end
    if tostring(getbaseinfo(mob, 3) or "") ~= MAP then return end
    for _, actor in pairs(players()) do
        if actor then setplaydef(actor, ENTERED, 0) end
    end
    point(play, 20, "讨伐BOSS最后一击奖励")
    setsysvar(STATE, 0)
    notify("讨伐BOSS活动结束，最后一击奖励已经发放！")
end, "kuafu_boss_kill")
return M