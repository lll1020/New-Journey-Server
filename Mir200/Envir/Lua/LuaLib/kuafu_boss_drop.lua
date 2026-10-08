local BOSS = "跨服boss—[活动]"
local MAP = "跨服战场"
local function drop(play, mob, item)
    additemtodroplist(play, mob, item)
end
GameEvent.add(EventCfg.onKillMon, function(play, mob)
    if not play or not mob then return end
    if tostring(getbaseinfo(mob, 1) or "") ~= BOSS then return end
    if tostring(getbaseinfo(mob, 3) or "") ~= MAP then return end
    drop(play, mob, "杀伐神石")
    drop(play, mob, "杀伐神石")
    drop(play, mob, "杀伐神石")
    drop(play, mob, "杀伐神石")
    drop(play, mob, "杀伐神石")
    drop(play, mob, "杀伐神石")
    drop(play, mob, "杀伐神石")
    drop(play, mob, "杀伐神石")
    drop(play, mob, "杀伐神石")
    drop(play, mob, "杀伐神石")
    for _ = 1, 10 do drop(play, mob, "辉耀水晶") end
    for _ = 1, 5 do drop(play, mob, "1元真实充值") end
    for _ = 1, 188 do drop(play, mob, "千年玄铁") end
    drop(play, mob, "圣星核")
    for _ = 1, 3 do drop(play, mob, "大修为丹") end
    for _ = 1, 200 do drop(play, mob, "金币[50000]") end
    if math.random(8) == 1 then drop(play, mob, "灵兽蛋") end
end, "kuafu_boss_drop")
return true