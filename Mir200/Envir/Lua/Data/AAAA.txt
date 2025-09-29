local GongShaChuanSong = {}
local NpcId = 109
GongShaChuanSong.SwinReward = 14000      --首次攻沙胜利方奖励
GongShaChuanSong.SloserReward = 6000    --首次攻沙失败方奖励
-- GongShaChuanSong.SchengZhuReward = 2000 --首次城主奖励
GongShaChuanSong.winReward = 3500       --后续胜利方奖励
GongShaChuanSong.loserReward = 1500      --后续失败方奖励
-- GongShaChuanSong.chengZhuReward = 1000  --后续城主奖励
GongShaChuanSong.money = "绑定灵符#"
GongShaChuanSong.minimum = 600  --最小积分才能获取奖励
GongShaChuanSong.killPoint = 50 --杀人获得50积分
GongShaChuanSong.killedPoint = 10 --被杀获得10积分
GongShaChuanSong.guaJiPoint = 3 --挂机积分
GongShaChuanSong.guildPoints = Player.getJsonTableByVar(nil, VarCfg["A_行会积分记录"])
-- Player.getJsonTableByVar(nil, VarCfg["A_行会积分记录"])
--计算行会总积分
function GongShaChuanSong.calculateGuildPoints()
    local winnerGuildName = castleinfo(2) --胜利方行会
    local winnerPoints = 0
    local loserPoints = 0
    local guildPoints = Player.getJsonTableByVar(nil, VarCfg["A_行会积分记录"])
    for guildName, players in pairs(guildPoints) do
        local totalPoints = 0
        for _, points in pairs(players) do
            if points >= GongShaChuanSong.minimum then
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
function GongShaChuanSong.RequestCS(actor, arg1)
    if not arg1 then
        return
    end
    -- if not getbaseinfo(actor, ConstCfg.gbase.issaferect) then
    --     Player.sendmsg(actor, "只能在安全区传送！")
    --     return
    -- end

    local isInRange = FCheckNPCRange(actor, NpcId, 15)
    if not isInRange then
        Player.sendmsgEx(actor, "距离太远#249")
        return
    end

    if checkkuafuconnect() then
        Player.sendmsgEx(actor, "跨服已开启，本服攻沙已关闭！#249")
        return
    end

    local isGongSha = castleinfo(5)
    if not isGongSha then
        Player.sendmsgEx(actor, "非攻沙时间,禁止传送#249")
        return
    end

    if arg1 == 1 then
        mapmove(actor, "n3", 629, 283)
    elseif arg1 == 2 then
        mapmove(actor, "n3", 637, 313)
    elseif arg1 == 3 then
        mapmove(actor, "n3", 659, 288)
    elseif arg1 == 4 then
        mapmove(actor, "n3", 674, 332)
    end
    local name = getbaseinfo(actor, ConstCfg.gbase.name)
    guildnoticemsg(actor, 251, 249, "勇士【" .. name .. "】开始征战沙城！")
end

------------网络消息-------------
--同步消息
function GongShaChuanSong.SyncResponse(actor)
    --判断首次拿沙奖励
    local gongShaConunt = getsysvar(VarCfg["G_攻沙次数"])
    local winReward, loserReward, chengZhuReward = 0, 0, 0
    --后续攻沙
    if gongShaConunt > 1 then
        winReward = GongShaChuanSong.winReward
        loserReward = GongShaChuanSong.loserReward
        --首次攻沙
    else
        winReward = GongShaChuanSong.SwinReward
        loserReward = GongShaChuanSong.SloserReward
    end
    local myPoints                                   = getplaydef(actor, VarCfg["J_攻沙积分"]) --个人攻沙积分
    local winnerGuildName, winnerPoints, loserPoints = GongShaChuanSong.calculateGuildPoints() --胜利方行会，胜利方积分，失败方积分
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
    Message.sendmsg(actor, ssrNetMsgCfg.GongShaChuanSong_SyncResponse, 0, 0, 0, data)
end

--会长领取奖励
function GongShaChuanSong.HuiZhang(actor)
    if castleidentity(actor) ~= 2 then
        Player.sendmsgEx(actor, "别开玩笑了，你不是老大。#249")
        return
    end

    if getsysvar(VarCfg["A_沙城主领取"]) ~= "" then
        Player.sendmsgEx(actor, string.format("奖励被|[%s]#249|领取过了", getsysvar(VarCfg["A_沙城主领取"])))
        return
    end

    local isTime = isTimeInRange(22, 04, 23, 00)
    if not isTime then
        Player.sendmsgEx(actor, string.format("请在|22:05-23:00#249|领取奖励!"))
        return
    end

    local name = getbaseinfo(actor, ConstCfg.gbase.name)
    setsysvar(VarCfg["A_沙城主领取"], name)
    confertitle(actor, "沙城之主", 1)
    local timestamp = os.time()
    changetitletime(actor, "沙城之主", "=", timestamp + 129600)
    Player.sendmsgEx(actor, string.format("领取成功,称号已经为您自动穿戴,有效期36个小时!"))
    Player.setAttList(actor, "爆率附加")
end

--胜利方成员领取称号奖励
function GongShaChuanSong.ChengYuan(actor)
    if castleidentity(actor) == 2 then
        Player.sendmsgEx(actor, "你是沙巴克老大,无法领取!#249")
        return
    end

    if castleidentity(actor) == 0 then
        Player.sendmsgEx(actor, "你不是胜利方行会成员。#249")
        return
    end

    local isTime = isTimeInRange(22, 04, 23, 00)
    if not isTime then
        Player.sendmsgEx(actor, string.format("请在|22:05-23:00#249|领取奖励!"))
        return
    end
    local lingQuList = Player.getJsonTableByVar(nil, VarCfg["A_胜利方行会成员领取记录"])
    local userId = getbaseinfo(actor, ConstCfg.gbase.id)
    if table.contains(lingQuList, userId) then
        Player.sendmsgEx(actor, string.format("你已经领取过了!"))
        return
    end
    table.insert(lingQuList, userId)
    Player.setJsonVarByTable(nil, VarCfg["A_胜利方行会成员领取记录"], lingQuList)
    confertitle(actor, "胜利之师", 1)
    local timestamp = os.time()
    changetitletime(actor, "胜利之师", "=", timestamp + 129600)
    Player.sendmsgEx(actor, string.format("领取成功,称号已经为您自动穿戴,有效期36个小时!"))
    Player.setAttList(actor, "爆率附加")
end

--双方领取货币奖励
function GongShaChuanSong.LingQu(actor)
    if getmyguild(actor) == "0" then
        Player.sendmsgEx(actor, string.format("你没有加入行会#249"))
        return
    end

    local isLingQu = getplaydef(actor, VarCfg["J_是否领取沙奖励"])
    if isLingQu > 0 then
        Player.sendmsgEx(actor, string.format("你已经领取过奖励了!#249"))
        return
    end

    local isTime = isTimeInRange(22, 05, 23, 00)
    if not isTime then
        Player.sendmsgEx(actor, string.format("请在|22:05-23:00#249|领取奖励!"))
        return
    end

    --四舍五入
    local function round(num)
        local decimal = num % 1 -- 获取小数部分
        if decimal >= 0.5 then
            return math.ceil(num)
        else
            return math.floor(num)
        end
    end
    -- local openday = getsysvar(VarCfg["G_开区天数"])
    local gongShaConunt = getsysvar(VarCfg["G_攻沙次数"])
    local winReward, loserReward = 0, 0 --胜利方总奖励，失败方总奖励
    if gongShaConunt > 1 then
        winReward = GongShaChuanSong.winReward
        loserReward = GongShaChuanSong.loserReward
    else
        winReward = GongShaChuanSong.SwinReward
        loserReward = GongShaChuanSong.SloserReward
    end
    local myPoints = getplaydef(actor, VarCfg["J_攻沙积分"])

    if myPoints < 600 then
        Player.sendmsgEx(actor, string.format("你的活跃度小于600,无法领取!#249"))
        return
    end

    local winnerGuildName, winnerPoints, loserPoints = GongShaChuanSong.calculateGuildPoints()
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
    local userid = getbaseinfo(actor, ConstCfg.gbase.id)
    MyReward = round(MyReward)
    setplaydef(actor,VarCfg["J_是否领取沙奖励"] ,1)
    sendmail(userid, 1, sbk_type, "请领取您的沙巴克奖励", GongShaChuanSong.money .. MyReward)
    Player.sendmsgEx(actor,"奖励已发送到邮件,请到邮件查收!")
    if sbk_type == "沙巴克胜利方奖励" then
        GameEvent.push(EventCfg.GetCastleRewards, actor)
    end
end

Message.RegisterNetMsg(ssrNetMsgCfg.GongShaChuanSong, GongShaChuanSong)

-----------游戏事件-----------------
-- 函数用于增加玩家的积分到行会中
-- guildName: 行会名称
-- playerName: 玩家名称
-- points: 玩家获得的积分
function GongShaChuanSong.addPlayerPoints(guildName, playerName, points)
    -- 检查行会是否存在，如果不存在则创建
    if not GongShaChuanSong.guildPoints[guildName] then
        GongShaChuanSong.guildPoints[guildName] = {}
    end

    -- 检查玩家是否存在，如果不存在则创建
    if not GongShaChuanSong.guildPoints[guildName][playerName] then
        GongShaChuanSong.guildPoints[guildName][playerName] = 0
    end
    GongShaChuanSong.guildPoints[guildName][playerName] = points
    Player.setJsonVarByTable(nil, VarCfg["A_行会积分记录"], GongShaChuanSong.guildPoints)
end

--开始
local function _Castlewaract()
    setsysvar(VarCfg["A_行会积分记录"], "")
    GongShaChuanSong.guildPoints = {} --清理可能存在的缓存
    setsysvar(VarCfg["A_沙城主领取"], "")
    setsysvar(VarCfg["A_胜利方行会成员领取记录"], "")
    setsysvar(VarCfg["A_排行榜领取记录"], "")
    setsysvar(VarCfg["A_第一滴血玩家名字"], "暂无")
    local player_list = getplayerlst(1)
    for i, actor in ipairs(player_list) do
        if checkkuafu(actor) then --跨服中不使用这个
            return
        end
        --没三秒执行一次
        setontimer(actor, 2, 3, 0, 1)
    end
end
-- 结束
local function _Castlewarend()
    local player_list = getplayerlst()
    for i, actor in ipairs(player_list) do
        if checkkuafu(actor) then  --跨服中不使用这个
            return
        end
        setofftimer(actor, 2)
    end
end
--攻城中
local function _Castlewaring(actor)
    if checkkuafu(actor) then
        return
    end
    if castleinfo(5) then
        if FCheckMap(actor, "new0150") or FCheckMap(actor, "kuafu0150") then
            local points = getplaydef(actor, VarCfg["J_攻沙积分"])
            setplaydef(actor, VarCfg["J_攻沙积分"], points + GongShaChuanSong.guaJiPoint)
            local name = getbaseinfo(actor, ConstCfg.gbase.name)
            local guild = getbaseinfo(actor, ConstCfg.gbase.guild)
            GongShaChuanSong.addPlayerPoints(guild, name, points + GongShaChuanSong.guaJiPoint)
        end
        --强制剔除其他地图
        -- if not FCheckMap(actor, "new0150") and not FCheckMap(actor, "n3") and not FCheckMap(actor, "起源村") then
        --     Player.sendmsgEx(actor,"攻沙期间不允许下图打怪！")
        --     mapmove(actor, ConstCfg.main_city, 330, 330, 5)
        -- end
    end
end

--登录触发
local function _onLoginEnd(actor)
    --如果正在攻城开启定时器
    if checkkuafu(actor) then
        return
    end
    if castleinfo(5) then
        setontimer(actor, 2, 3, 0, 1)
    end
end
GameEvent.add(EventCfg.onLoginEnd, _onLoginEnd, GongShaChuanSong)
GameEvent.add(EventCfg.onKFLogin, _onLoginEnd, GongShaChuanSong)
--攻城中定时器
GameEvent.add(EventCfg.gocastlewaring, _Castlewaring, GongShaChuanSong)
--沙巴克开始触发
GameEvent.add(EventCfg.gocastlewarstart, _Castlewaract, GongShaChuanSong)
--沙巴克结束触发
GameEvent.add(EventCfg.goCastlewarend, _Castlewarend, GongShaChuanSong)

--杀人触发
local function _Castlewarkill(actor, play)
    if checkkuafu(actor) then
        return
    end
    --增加杀人积分
    if castleinfo(5) then
        if getbaseinfo(actor, ConstCfg.gbase.issbk) then
            --杀人者积分
            local points = getplaydef(actor, VarCfg["J_攻沙积分"])
            setplaydef(actor, VarCfg["J_攻沙积分"], points + GongShaChuanSong.killPoint)
            local name = getbaseinfo(actor, ConstCfg.gbase.name)
            local guild = getbaseinfo(actor, ConstCfg.gbase.guild)
            GongShaChuanSong.addPlayerPoints(guild, name, points + GongShaChuanSong.killPoint)

            --被杀者积分
            local killedPoints = getplaydef(play, VarCfg["J_攻沙积分"])
            setplaydef(play, VarCfg["J_攻沙积分"], killedPoints + GongShaChuanSong.killedPoint)
            local killedName = getbaseinfo(play, ConstCfg.gbase.name)
            local killedGuild = getbaseinfo(play, ConstCfg.gbase.guild)
            GongShaChuanSong.addPlayerPoints(killedGuild, killedName, killedPoints + GongShaChuanSong.killedPoint)
            --添加奇遇称号触发
            if checkkuafu(actor) then
                --攻沙期间第一个击杀敌对行会成员
                if getsysvar(VarCfg["A_第一滴血玩家名字"]) == "暂无" then
                    if randomex(50,100) then
                        FKuaFuToBenFuRunScript(actor,4)
                    end
                    local name = getbaseinfo(actor,ConstCfg.gbase.name)
                    setsysvar(VarCfg["A_第一滴血玩家名字"], name)
                end
            else
                if not checktitle(actor, "第一滴血") then
                    if getsysvar(VarCfg["A_第一滴血玩家名字"]) == "暂无" then
                        local name = getbaseinfo(actor,ConstCfg.gbase.name)
                        setsysvar(VarCfg["A_第一滴血玩家名字"], name)
                        if randomex(50,100) then
                            confertitle(actor,"第一滴血")
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
GameEvent.add(EventCfg.onkillplay, _Castlewarkill, GongShaChuanSong)
-- GameEvent.add(EventCfg.gomapeventwalk, _mapeventwalk,CastWar)
return
