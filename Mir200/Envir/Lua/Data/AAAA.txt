local KFGongShaChuanSong = {}
local NpcId = 126
KFGongShaChuanSong.SwinReward = 10000  --首次攻沙胜利方奖励
KFGongShaChuanSong.SloserReward = 3000 --首次攻沙失败方奖励
KFGongShaChuanSong.money = "绑定灵符#"
KFGongShaChuanSong.minimum = 600       --最小积分才能获取奖励
KFGongShaChuanSong.killPoint = 50      --杀人获得50积分
KFGongShaChuanSong.killedPoint = 10    --被杀获得10积分
KFGongShaChuanSong.guaJiPoint = 3      --挂机积分
KFGongShaChuanSong.guildPoints = Player.getJsonTableByVar(nil, VarCfg["A_行会积分记录跨服"])
--计算行会总积分
function KFGongShaChuanSong.calculateGuildPoints()
    local winnerGuildName = castleinfo(2) --胜利方行会
    local winnerPoints = 0
    local loserPoints = 0
    local guildPoints = Player.getJsonTableByVar(nil, VarCfg["A_行会积分记录跨服"])
    for guildName, players in pairs(guildPoints) do
        local totalPoints = 0
        for _, points in pairs(players) do
            if points >= KFGongShaChuanSong.minimum then
                totalPoints = totalPoints + points
            end
        end

        if guildName == winnerGuildName then
            winnerPoints = totalPoints
        else
            loserPoints = loserPoints + totalPoints
        end
    end
    return winnerGuildName, winnerPoints, loserPoints
end

--传送
function KFGongShaChuanSong.RequestCS(actor, arg1)
    if not arg1 then
        return
    end
    if not checkkuafu(actor) then
        return
    end
    FBenFuToKuaFuRunScript(actor, 1, arg1)
end

------------网络消息-------------
--同步消息 --本服执行，需要传递到跨服
function KFGongShaChuanSong.SyncResponse(actor)
    FBenFuToKuaFuRunScript(actor, 2, "")
end

local function _onKFGongShaRewardSync(actor)
    local winReward, loserReward, chengZhuReward     = 0, 0, 0
    winReward                                        = KFGongShaChuanSong.SwinReward
    loserReward                                      = KFGongShaChuanSong.SloserReward
    local myPoints                                   = getplaydef(actor, VarCfg["U_攻沙积分跨服"]) --个人攻沙积分
    local winnerGuildName, winnerPoints, loserPoints = KFGongShaChuanSong.calculateGuildPoints() --胜利方行会，胜利方积分，失败方积分
    local bossName                                   = castleinfo(3)
    -- local bossNameId                                 = getbaseinfo(getplayerbyname(bossName), ConstCfg.gbase.id)
    local castleidentity                             = castleidentity(actor)
    local data                                       = {
        ["winReward"] = winReward,
        ["loserReward"] = loserReward,
        -- ["chengZhuReward"] = chengZhuReward,
        ["myPoints"] = myPoints,
        ["winnerGuildName"] = winnerGuildName,
        ["winnerPoints"] = winnerPoints,
        ["loserPoints"] = loserPoints,
        ["bossName"] = bossName,
        -- ["bossNameId"] = bossNameId,
        ["castleidentity"] = castleidentity,
    }
    Message.sendmsg(actor, ssrNetMsgCfg.KFGongShaChuanSong_SyncResponse, 0, 0, 0, data)
end
GameEvent.add(EventCfg.onKFGongShaRewardSync, _onKFGongShaRewardSync, KFGongShaChuanSong)

--双方领取货币奖励  --本服执行，需要传递到跨服
function KFGongShaChuanSong.LingQu(actor)
    FBenFuToKuaFuRunScript(actor, 3, "")
end

--攻沙领取奖励
local function _onKFGongShaLinQu(actor)
    if getmyguild(actor) == "0" then
        Player.sendmsgEx(actor, string.format("你没有加入行会#249"))
        return
    end

    local isLingQu = getflagstatus(actor,VarCfg["F_跨服攻沙是否领取"])
    if isLingQu == 1 then
        Player.sendmsgEx(actor, string.format("你已经领取过奖励了!#249"))
        return
    end
    local isTime = isTimeInRange(22, 04, 22, 59)
    if not isTime then
        Player.sendmsgEx(actor, string.format("请在|22:05-23:00#249|领取奖励!"))
        return
    end

    local winReward, loserReward = 0, 0 --胜利方总奖励，失败方总奖励
    winReward = KFGongShaChuanSong.SwinReward
    loserReward = KFGongShaChuanSong.SloserReward
    local myPoints = getplaydef(actor, VarCfg["U_攻沙积分跨服"])
    if myPoints < 600 then
        Player.sendmsgEx(actor, string.format("你的活跃度小于600,无法领取!#249"))
        return
    end

    local winnerGuildName, winnerPoints, loserPoints = KFGongShaChuanSong.calculateGuildPoints()
    local castleidentity                             = castleidentity(actor) --获取沙巴克身份
    local MyReward
    local sbk_type
    --沙巴克失败方
    if castleidentity == 0 then
        if loserPoints == 0 then
            return
        end
        MyReward = (loserReward / loserPoints) * myPoints --奖励算法，奖金池/失败方总积分*我的积分
        sbk_type = "沙巴克失败方奖励"
    else
        if winnerPoints == 0 then
            return
        end
        MyReward = (winReward / winnerPoints) * myPoints --奖励算法，奖金池/失败方总积分*我的积分
        sbk_type = "沙巴克胜利方奖励"
    end
    MyReward = numberRound(MyReward)
    setflagstatus(actor,VarCfg["F_跨服攻沙是否领取"],1)
    FKuaFuToBenFuGongShaReward(actor, sbk_type, KFGongShaChuanSong.money .. MyReward)
    Player.sendmsgEx(actor, "奖励已发送到邮件,请到邮件查收!")
end

GameEvent.add(EventCfg.onKFGongShaLinQu, _onKFGongShaLinQu, KFGongShaChuanSong)


Message.RegisterNetMsg(ssrNetMsgCfg.KFGongShaChuanSong, KFGongShaChuanSong)

-----------游戏事件-----------------
-- 函数用于增加玩家的积分到行会中
-- guildName: 行会名称
-- playerName: 玩家名称
-- points: 玩家获得的积分
function KFGongShaChuanSong.addPlayerPoints(guildName, playerName, points)
    -- 检查行会是否存在，如果不存在则创建
    if not KFGongShaChuanSong.guildPoints[guildName] then
        KFGongShaChuanSong.guildPoints[guildName] = {}
    end

    -- 检查玩家是否存在，如果不存在则创建
    if not KFGongShaChuanSong.guildPoints[guildName][playerName] then
        KFGongShaChuanSong.guildPoints[guildName][playerName] = 0
    end
    KFGongShaChuanSong.guildPoints[guildName][playerName] = points
    Player.setJsonVarByTable(nil, VarCfg["A_行会积分记录跨服"], KFGongShaChuanSong.guildPoints)
end

--开始 --跨服执行
local function _Castlewaract()
    setsysvar(VarCfg["A_行会积分记录跨服"], "")
    KFGongShaChuanSong.guildPoints = {} --清理可能存在的缓存
    setsysvar(VarCfg["A_沙城主领取"], "")
    setsysvar(VarCfg["A_胜利方行会成员领取记录"], "")
    setsysvar(VarCfg["A_排行榜领取记录"], "")
    setsysvar(VarCfg["A_第一滴血玩家名字"], "暂无")
    local player_list = getplayerlst(1)
    if checkkuafuserver() then
        setontimerex(2, 3)
    end
    for i, actor in ipairs(player_list) do
        --没三秒执行一次
        setontimer(actor, 2, 3, 0, 1)
    end
end
-- 结束 --跨服执行
local function _Castlewarend()
    if checkkuafuserver() then
        setofftimerex(2)
        local player_list = getplayerlst()
        for i, actor in ipairs(player_list) do
            setofftimer(actor, 2)
        end
    end
end
--攻城中 --跨服执行
local function _Castlewaring(actor)
    if not checkkuafu(actor) then
        return
    end
    if castleinfo(5) then
        if FCheckMap(actor, "new0150") or FCheckMap(actor, "kuafu0150") then
            local points = getplaydef(actor, VarCfg["U_攻沙积分跨服"])
            setplaydef(actor, VarCfg["U_攻沙积分跨服"], points + KFGongShaChuanSong.guaJiPoint)
            local name = getbaseinfo(actor, ConstCfg.gbase.name)
            local guild = getbaseinfo(actor, ConstCfg.gbase.guild)
            KFGongShaChuanSong.addPlayerPoints(guild, name, points + KFGongShaChuanSong.guaJiPoint)
        end
        --强制剔除其他地图
        -- if not FCheckMap(actor, "new0150") and not FCheckMap(actor, "n3") and not FCheckMap(actor, "起源村") then
        --     Player.sendmsgEx(actor,"攻沙期间不允许下图打怪！")
        --     mapmove(actor, ConstCfg.main_city, 330, 330, 5)
        -- end
    end
end

--登录触发 --跨服执行
local function _onKFLogin(actor)
    --如果正在攻城开启定时器
    if castleinfo(5) then
        setontimer(actor, 2, 3, 0, 1)
    end
end
GameEvent.add(EventCfg.onKFLogin, _onKFLogin, KFGongShaChuanSong)
--攻城中定时器
GameEvent.add(EventCfg.gocastlewaring, _Castlewaring, KFGongShaChuanSong)
--沙巴克开始触发
GameEvent.add(EventCfg.gocastlewarstart, _Castlewaract, KFGongShaChuanSong)
--沙巴克结束触发
GameEvent.add(EventCfg.goCastlewarend, _Castlewarend, KFGongShaChuanSong)

--杀人触发
local function _Castlewarkill(actor, play)
    if not checkkuafu(actor) then
        return
    end
    --增加杀人积分
    if castleinfo(5) then
        if getbaseinfo(actor, ConstCfg.gbase.issbk) then
            --杀人者积分
            local points = getplaydef(actor, VarCfg["U_攻沙积分跨服"])
            setplaydef(actor, VarCfg["U_攻沙积分跨服"], points + KFGongShaChuanSong.killPoint)
            local name = getbaseinfo(actor, ConstCfg.gbase.name)
            local guild = getbaseinfo(actor, ConstCfg.gbase.guild)
            KFGongShaChuanSong.addPlayerPoints(guild, name, points + KFGongShaChuanSong.killPoint)

            --被杀者积分
            local killedPoints = getplaydef(play, VarCfg["U_攻沙积分跨服"])
            setplaydef(play, VarCfg["U_攻沙积分跨服"], killedPoints + KFGongShaChuanSong.killedPoint)
            local killedName = getbaseinfo(play, ConstCfg.gbase.name)
            local killedGuild = getbaseinfo(play, ConstCfg.gbase.guild)
            KFGongShaChuanSong.addPlayerPoints(killedGuild, killedName, killedPoints + KFGongShaChuanSong.killedPoint)
            --添加奇遇称号触发
            if checkkuafu(actor) then
                --攻沙期间第一个击杀敌对行会成员
                if getsysvar(VarCfg["A_第一滴血玩家名字"]) == "暂无" then
                    if randomex(50, 100) then
                        FKuaFuToBenFuRunScript(actor, 4)
                    end
                    local name = getbaseinfo(actor, ConstCfg.gbase.name)
                    setsysvar(VarCfg["A_第一滴血玩家名字"], name)
                end
            else
                if not checktitle(actor, "第一滴血") then
                    if getsysvar(VarCfg["A_第一滴血玩家名字"]) == "暂无" then
                        local name = getbaseinfo(actor, ConstCfg.gbase.name)
                        setsysvar(VarCfg["A_第一滴血玩家名字"], name)
                        if randomex(50, 100) then
                            confertitle(actor, "第一滴血")
                            GameEvent.push(EventCfg.onAddAchievementTitle, actor, "第一滴血")
                        end
                    end
                end
            end
        end
    end
    addbuff(actor, 31030)
    local KillNum = getplaydef(actor, VarCfg["N$连杀人数"])
    KillNum = KillNum + 1
    setplaydef(actor, VarCfg["N$连杀人数"], KillNum)
    GameEvent.push(EventCfg.onContinuousKillPlayer, actor, KillNum)

    if KillNum <= 10 then
        local effecf = 62100
        playeffect(actor, effecf + KillNum, -50, 80, 1, 0, 1)
    elseif KillNum > 10 then
        playeffect(actor, 62110, -50, 80, 1, 0, 1)
    end
end
GameEvent.add(EventCfg.onkillplay, _Castlewarkill, KFGongShaChuanSong)


--跨服同步积分
local function _goKFGongShaSync()
    local playList = getplayerlst()
    for _, actor in ipairs(playList) do
        -- KFGongShaChuanSong_HuiZhang
        Message.sendmsg(actor, ssrNetMsgCfg.KFGongShaChuanSong_SyncPoints, 0, 0, 0, KFGongShaChuanSong.guildPoints)
    end
end
GameEvent.add(EventCfg.goKFGongShaSync, _goKFGongShaSync, KFGongShaChuanSong)
return
