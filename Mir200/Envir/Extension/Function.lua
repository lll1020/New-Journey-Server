-------------------------
-------------------------
--对引擎提供方法的扩展
-------------------------
-------------------------

--检查一个对象的范围
function FCheckRange(obj, x, y, range)
    local cur_x, cur_y = getbaseinfo(obj, ConstCfg.gbase.x), getbaseinfo(obj, ConstCfg.gbase.y)
    local min_x, max_x = x - range, x + range
    local min_y, max_y = y - range, y + range

    if (cur_x >= min_x) and (cur_x <= max_x) and
            (cur_y >= min_y) and (cur_y <= max_y) then
        return true
    end

    return false
end
--检查自己与npc的距离
function FCheckNPCRange(actor, npcidx, range)
    range = range or 15
    local npcobj = getnpcbyindex(npcidx)
    local npc_mapid = getbaseinfo(npcobj, ConstCfg.gbase.mapid)
    local my_mapid = getbaseinfo(actor, ConstCfg.gbase.mapid)
    if npc_mapid ~= my_mapid then return false end

    local npc_x = getbaseinfo(npcobj, ConstCfg.gbase.x)
    local npc_y = getbaseinfo(npcobj, ConstCfg.gbase.y)
    return FCheckRange(actor, npc_x, npc_y, range)
end

--移动到指定NPC，如果不在本地图或者指定范围就飞到目标
---*  actor: 玩家对象
---*  npcId: NPCID
---*  range: 检测范围
---*  mapID: 不在范围内的地图ID
---*  mapX: 飞地图X
---*  mapY: 飞地图Y
---* mapRange: 飞地图范围
---@param actor string
---@param npcId number
---@param range number
---@param mapID string
---@param mapX number
---@param mapY number
---@param mapRange number?
function FMoveNpc(actor, npcId, range, mapID, mapX, mapY, mapRange)
    mapRange = mapRange or 1
    if FCheckNPCRange(actor, npcId, range) then
        opennpcshowex(actor, npcId, 0, 2)
    else
        mapmove(actor, mapID, mapX, mapY, mapRange)
        opennpcshowex(actor, npcId, 0, 2)
    end
end

--检测是否在当前的地图
function FCheckMap(actor, mapId)
    local currMapId = getbaseinfo(actor, ConstCfg.gbase.mapid)
    return mapId == currMapId
end

--地图全部玩家移动到指定地图
function FMoveMapPlay(currMapId, targetMapId, x, y, range)
    local playerList = getplaycount(currMapId, 0, 0)
    if playerList == "0" then
        return
    end
    for i = 1, #playerList do
        local actor = playerList[i]
        mapmove(actor, targetMapId, x, y, range)
    end
end

--检测是否达到等级
function FCheckLevel(actor, level)
    if not level then return end
    local currLevel = getbaseinfo(actor, ConstCfg.gbase.level)
    return currLevel >= level
end

-- 判断当前坐标是否在指定坐标的范围内
function FisInRange(currentX, currentY, targetX, targetY, range)
    local dx = targetX - currentX
    local dy = targetY - currentY
    local distSquared = dx * dx + dy * dy
    local rangeSquared = range * range
    return distSquared <= rangeSquared
end

--判断是否行本会成员
function getIsGuildMember(actor, traget)
    local guildObj = getmyguild(actor)
    if guildObj == "0" then
        return false
    end
    local result = getguildinfo(guildObj, 3)
    local targetName = getbaseinfo(traget, ConstCfg.gbase.name)
    for _, value in ipairs(result or {}) do
        if targetName == value then
            return true
        end
    end
    return false
end

--判断是否小组成员
function getIsGroupMember(actor, traget)
    local result = getgroupmember(actor)
    for index, value in ipairs(result or {}) do
        if value == traget then
            return true
        end
    end
    return false
end

--传送扩展
function FMapMoveEx(actor, mapId, x, y, range)
    mapmove(actor, mapId, x, y, range)
end

--传送地图扩展
function FMapEx(actor, mapId, isAuto)
    map(actor, mapId)
end

--根据数组或者布尔返回颜色值
function FGetColor(data)
    if type(data) == "boolean" then
        return data and "#00FF00" or "#FF0000"
    elseif type(data) == "table" then
        return data[1] >= data[2] and "#00FF00" or "#FF0000"
    end
end

--传送地图扩展
function FOpenNpcShowEx(actor, npcID)
    opennpcshowex(actor, npcID, 2, 6)
end
--大飘屏
function FsendHuoDongGongGao(msgStr)
    sendmsg("0", 2, '{"Msg":"' .. msgStr .. '","FColor":249,"BColor":0,"Type":5,"Time":3,"SendId":"123","Y":"100"}')
    sendmsg("0", 2, '{"Msg":"' .. msgStr .. '","FColor":249,"BColor":0,"Type":5,"Time":3,"SendId":"123","Y":"140"}')
    sendmsg("0", 2, '{"Msg":"' .. msgStr .. '","FColor":249,"BColor":0,"Type":5,"Time":3,"SendId":"123","Y":"180"}')
    sendmsg("0", 2, '{"Msg":"' .. msgStr .. '","FColor":249,"BColor":0,"Type":5,"Time":3,"SendId":"123","Y":"220"}')
    sendmsg("0", 2, '{"Msg":"' .. msgStr .. '","FColor":249,"BColor":0,"Type":5,"Time":3,"SendId":"123","Y":"260"}')
end

-----------------------攻沙提示
--攻沙tips 攻沙提示 开启提示
function FSendGongShaTips1(isKF)
    local isKFStr = ""
    if isKF then
        isKFStr = "跨服"
    end
    sendmsg("0", 2,
            '{"Msg":"今晚集体' ..
                    isKFStr .. '攻沙请各行会的兄弟做好准备！！！","FColor":250,"BColor":0,"Type":6,"Time":6,"SendName":"系统：","Y":"0"}')
    sendmsg("0", 2,
            '{"Msg":"今晚集体' ..
                    isKFStr .. '攻沙请各行会的兄弟做好准备！！！","FColor":250,"BColor":0,"Type":6,"Time":6,"SendName":"系统：","Y":"0"}')
    sendmsg("0", 2,
            '{"Msg":"今晚集体' ..
                    isKFStr .. '攻沙请各行会的兄弟做好准备！！！","FColor":250,"BColor":0,"Type":6,"Time":6,"SendName":"系统：","Y":"0"}')
    for i = 1, 5, 1 do
        sendmsg("0", 2,
                '{"Msg":"今晚集体' ..
                        isKFStr .. '攻沙请各行会的兄弟做好准备！！！","FColor":250,"BColor":0,"Type":0,"Time":3,"SendName":"系统：","Y":"30"}')
    end
end


---修改角色外观(武器、衣服、特效)
---*  play: 玩家对象
---*  type: 0=衣服;1=武器;2=衣服特效;3武器特效;4=盾牌;5=盾牌特效
---*  shape: 外观的shape(角色模型ID),-1表示清除
---*  time: 时间 (秒)
---*  param1: 仅在参数1位置为0时有效(0=覆盖时装外观, 1=时装外观优先)
---*  param2: 仅在参数1位置为0时有效(0-斗笠、头发不变, 1-隐藏斗笠, 2-隐藏头发, 3-隐藏斗笠和头发 4-隐藏盾牌和盾牌特效)
---@param actor string
---@param type number
---@param shape number
---@param time number
---@param param1 number
---@param param2 number
function FSetFeature(actor, type, shape, time, param1, param2)
    setplaydef(actor, VarCfg["U_时装外观记录"], shape)
    setfeature(actor, type, shape, time, param1, param2)
    setfeature(actor, 1, 9999, time, 0, 0)
end

--幻化时装形象
function FIllusionAppearance(actor, shape, sEffect)
    --外观幻化
    FSetFeature(actor, 0, shape, 655350, 0, 0)
    --改变内观
    if sEffect then
        local equipObj = linkbodyitem(actor, 17)
        setitemaddvalue(actor, equipObj, 1, 47, sEffect)
        refreshitem(actor, equipObj)
    end
end

--设置足迹
function FSetMoveEff(actor, effectID)
    setplaydef(actor, VarCfg["U_足迹外观记录"], effectID)
    setmoveeff(actor, effectID, 1)
end

--设置光环
function FSetGuangHuan(actor, effectID)
    setplaydef(actor, VarCfg["U_光环外观记录"], effectID)
    seticon(actor, ConstCfg.iconWhere.guangHuan, 1, effectID, 0, 0, 0, 0, 1)
end

--计算爆率
function FCalculateActualExplosionRate(P)
    local R0 = 100
    local Delta_R = 0

    if P <= 1000 then
        Delta_R = P / 10
    elseif P <= 3000 then
        Delta_R = 100 + (P - 1000) / 20
    else
        Delta_R = 200 + (P - 3000) / 50
    end

    local R = R0 + Delta_R

    if R > 400 then
        R = 400
    end

    R = math.floor(R)

    return R
end

--设置仙途奇缘
function FSetSerendipity(actor, idx)
    local T_data = Player.getJsonTableByVar(actor, VarCfg["T_仙途奇缘"])
    if not T_data[""..idx] then
        T_data[""..idx] = 1
        Player.setJsonVarByTable(actor, VarCfg["T_仙途奇缘"], T_data)
        scenevibration(actor,0,2,1)
    end
end

-----------跨服相关，跨服到本服执行-------------------

--跨服到本服删除称号
function FKuaFuToBenFuDelTitle(actor, arg1, arg2)
    local userID = getbaseinfo(actor, ConstCfg.gbase.id)
    kfbackcall(52, userID, tostring(arg1), tostring(arg2)) --通知本服
end