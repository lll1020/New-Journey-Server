npc = {}


--功能21：沙巴克

local _config = Guard.getConfig("sbk")

function npc.main(play,npcid)
    sendluamsg(play,100,npcid,0,0,"")
end

function npc.link(play,npcid,ew,aid)
    -- npc_guard: 入参校验
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local __guardAction = Guard.normalizeAction(play, npcid, ew)
    if __guardAction == nil then
        return
    end
    ew = __guardAction
    -- npc_guard: 操作白名单（优化：限定合法操作编号）
    local __guardAllowedActions = Guard.newActionSet({1, 2})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end

    if getmyguild(play) == "0" then
        Player.sendmsgEx(play, string.format("你没有加入行会#249"))
        return
    end

    if ew == 1 then  --传送进地图
        if not castleinfo(5) then
            Player.sendmsgEx(play, string.format("当前不是沙巴克攻城时间，无法进入沙巴克地图#249"))
            return
        end

        local isInMap = false
        for _, mapInfo in ipairs(_config.map) do
            if FCheckMap(play, mapInfo.mpa_name) then
                isInMap = true
                break
            end
        end

        if isInMap then
            Player.sendmsgEx(play, string.format("你已经在沙巴克地图中，无需重复传送#249"))
            return
        end

        local targetMap = _config.map[aid]
        mapmove(play, targetMap.mpa_name, targetMap.x, targetMap.y, 5)
    
    elseif ew == 2 then  --胜利方成员领取称号奖励
    elseif ew == 3 then  --胜利方成员领取称号奖励
    elseif ew == 4 then  --双方领取货币奖励

    end
end


-----------游戏事件-----------------
-- 函数用于增加玩家的积分到行会中
-- guildName: 行会名称
-- playerName: 玩家名称
-- points: 玩家获得的积分
function npc.addPlayerPoints(guildName, playerName, points)
    -- 检查行会是否存在，如果不存在则创建
    local guildPoints = {}
    if checkkuafuserver() then
        guildPoints = Player.getJsonTableByVar(nil, VarCfg["A_行会积分记录跨服"])
    else
        guildPoints = Player.getJsonTableByVar(nil, VarCfg["A_行会积分记录"])
    end

    if not guildPoints[guildName] then
        guildPoints[guildName] = {}
    end

    -- 检查玩家是否存在，如果不存在则创建
    if not guildPoints[guildName][playerName] then
        guildPoints[guildName][playerName] = 0
    end
    guildPoints[guildName][playerName] = points
    if checkkuafuserver() then
        Player.setJsonVarByTable(nil, VarCfg["A_行会积分记录跨服"], guildPoints)
        synzvar(2,"A5","A5",1)
    else
        Player.setJsonVarByTable(nil, VarCfg["A_行会积分记录"], guildPoints)
    end

end

--开始
local function _Castlewaract()
    setsysvar(VarCfg["A_行会积分记录"], "")
    setsysvar(VarCfg["A_行会积分记录跨服"], "")
    if checkkuafuserver() then
        setontimerex(2, 3)
    end
    local player_list = getplayerlst(1)
    for i, actor in ipairs(player_list) do
        if not checkkuafu(actor) then --跨服中不使用这个
            --没三秒执行一次
            setontimer(actor, 2, 3, 0, 1)
        end
    end
end

-- 结束
local function _Castlewarend()
    local player_list = getplayerlst()
    for i, actor in ipairs(player_list) do
        if not checkkuafu(actor) then  --跨服中不使用这个
            setofftimer(actor, 2)
        end
    end
    if checkkuafuserver() then
        setofftimerex(2)
    end
end

local function _Castlewaring(actor)
    if checkkuafu(actor) then
        return
    end
    if castleinfo(5) then
        if FCheckMap(actor, "new0150") or FCheckMap(actor, "kuafu0150") then
            local points = getplaydef(actor, VarCfg["J_攻沙积分"])
            setplaydef(actor, VarCfg["J_攻沙积分"], points + _config.guaJiPoint)
            local name = getbaseinfo(actor, ConstCfg.gbase.name)
            local guild = getbaseinfo(actor, ConstCfg.gbase.guild)
            npc.addPlayerPoints(guild, name, points + _config.guaJiPoint)
        end
        --强制剔除其他地图
        -- if not FCheckMap(actor, "new0150") and not FCheckMap(actor, "n3") and not FCheckMap(actor, "xtc") then
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

GameEvent.add(EventCfg.onLoginEnd, _onLoginEnd, "攻沙")
GameEvent.add(EventCfg.onKFLogin, _onLoginEnd, "攻沙")
--攻城中定时器
GameEvent.add(EventCfg.gocastlewaring, _Castlewaring, "攻沙")
--沙巴克开始触发
GameEvent.add(EventCfg.gocastlewarstart, _Castlewaract, "攻沙")
--沙巴克结束触发
GameEvent.add(EventCfg.goCastlewarend, _Castlewarend, "攻沙")


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
            setplaydef(actor, VarCfg["J_攻沙积分"], points + _config.killPoint)
            local name = getbaseinfo(actor, ConstCfg.gbase.name)
            local guild = getbaseinfo(actor, ConstCfg.gbase.guild)
            npc.addPlayerPoints(guild, name, points + _config.killPoint)

            --被杀者积分
            local killedPoints = getplaydef(play, VarCfg["J_攻沙积分"])
            setplaydef(play, VarCfg["J_攻沙积分"], killedPoints + _config.killedPoint)
            local killedName = getbaseinfo(play, ConstCfg.gbase.name)
            local killedGuild = getbaseinfo(play, ConstCfg.gbase.guild)
            npc.addPlayerPoints(killedGuild, killedName, killedPoints + _config.killedPoint)
        end
    end

end
GameEvent.add(EventCfg.onkillplay, _Castlewarkill, "攻沙")

return npc
