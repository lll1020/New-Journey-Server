-------------------------
-------------------------
--对引擎提供方法的扩展
-------------------------
-------------------------

--声明自定义个人变量
function FIniPlayVar(actor, varname, isstr)
    local vartype = isstr and "string" or "integer"
    if type(varname) == "table" then
        varname = table.concat(varname, "|")
    end
    iniplayvar(actor, vartype, "HUMAN", varname)
end

--设置自定义个人变量
function FSetPlayVar(actor, varname, value, save)
    value = value or 0
    save = save or 1
    if type(varname) == "table" then
        for _, vname in ipairs(varname) do
            setplayvar(actor, "HUMAN", vname, value, save)
        end
    else
        setplayvar(actor, "HUMAN", varname, value, save)
    end
end
--设置自定义个人变量
function SetPlayDefEx(actor, varName, value)
    setplaydef(actor, varName, value)
end
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
