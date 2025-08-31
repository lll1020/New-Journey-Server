-------------------------
-------------------------
--�������ṩ��������չ
-------------------------
-------------------------

--�����Զ�����˱���
function FIniPlayVar(actor, varname, isstr)
    local vartype = isstr and "string" or "integer"
    if type(varname) == "table" then
        varname = table.concat(varname, "|")
    end
    iniplayvar(actor, vartype, "HUMAN", varname)
end

--�����Զ�����˱���
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
--�����Զ�����˱���
function SetPlayDefEx(actor, varName, value)
    setplaydef(actor, varName, value)
end
--���һ������ķ�Χ
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
--����Լ���npc�ľ���
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

--�ƶ���ָ��NPC��������ڱ���ͼ����ָ����Χ�ͷɵ�Ŀ��
---*  actor: ��Ҷ���
---*  npcId: NPCID
---*  range: ��ⷶΧ
---*  mapID: ���ڷ�Χ�ڵĵ�ͼID
---*  mapX: �ɵ�ͼX
---*  mapY: �ɵ�ͼY
---* mapRange: �ɵ�ͼ��Χ
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

--����Ƿ��ڵ�ǰ�ĵ�ͼ
function FCheckMap(actor, mapId)
    local currMapId = getbaseinfo(actor, ConstCfg.gbase.mapid)
    return mapId == currMapId
end

--��ͼȫ������ƶ���ָ����ͼ
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

--����Ƿ�ﵽ�ȼ�
function FCheckLevel(actor, level)
    if not level then return end
    local currLevel = getbaseinfo(actor, ConstCfg.gbase.level)
    return currLevel >= level
end

-- �жϵ�ǰ�����Ƿ���ָ������ķ�Χ��
function FisInRange(currentX, currentY, targetX, targetY, range)
    local dx = targetX - currentX
    local dy = targetY - currentY
    local distSquared = dx * dx + dy * dy
    local rangeSquared = range * range
    return distSquared <= rangeSquared
end

--�ж��Ƿ��б����Ա
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

--�ж��Ƿ�С���Ա
function getIsGroupMember(actor, traget)
    local result = getgroupmember(actor)
    for index, value in ipairs(result or {}) do
        if value == traget then
            return true
        end
    end
    return false
end

--������չ
function FMapMoveEx(actor, mapId, x, y, range)
    mapmove(actor, mapId, x, y, range)
end

--���͵�ͼ��չ
function FMapEx(actor, mapId, isAuto)
    map(actor, mapId)
end

--����������߲���������ɫֵ
function FGetColor(data)
    if type(data) == "boolean" then
        return data and "#00FF00" or "#FF0000"
    elseif type(data) == "table" then
        return data[1] >= data[2] and "#00FF00" or "#FF0000"
    end
end

--���͵�ͼ��չ
function FOpenNpcShowEx(actor, npcID)
    opennpcshowex(actor, npcID, 2, 6)
end
--��Ʈ��
function FsendHuoDongGongGao(msgStr)
    sendmsg("0", 2, '{"Msg":"' .. msgStr .. '","FColor":249,"BColor":0,"Type":5,"Time":3,"SendId":"123","Y":"100"}')
    sendmsg("0", 2, '{"Msg":"' .. msgStr .. '","FColor":249,"BColor":0,"Type":5,"Time":3,"SendId":"123","Y":"140"}')
    sendmsg("0", 2, '{"Msg":"' .. msgStr .. '","FColor":249,"BColor":0,"Type":5,"Time":3,"SendId":"123","Y":"180"}')
    sendmsg("0", 2, '{"Msg":"' .. msgStr .. '","FColor":249,"BColor":0,"Type":5,"Time":3,"SendId":"123","Y":"220"}')
    sendmsg("0", 2, '{"Msg":"' .. msgStr .. '","FColor":249,"BColor":0,"Type":5,"Time":3,"SendId":"123","Y":"260"}')
end

-----------------------��ɳ��ʾ
--��ɳtips ��ɳ��ʾ ������ʾ
function FSendGongShaTips1(isKF)
    local isKFStr = ""
    if isKF then
        isKFStr = "���"
    end
    sendmsg("0", 2,
            '{"Msg":"������' ..
                    isKFStr .. '��ɳ����л���ֵ�����׼��������","FColor":250,"BColor":0,"Type":6,"Time":6,"SendName":"ϵͳ��","Y":"0"}')
    sendmsg("0", 2,
            '{"Msg":"������' ..
                    isKFStr .. '��ɳ����л���ֵ�����׼��������","FColor":250,"BColor":0,"Type":6,"Time":6,"SendName":"ϵͳ��","Y":"0"}')
    sendmsg("0", 2,
            '{"Msg":"������' ..
                    isKFStr .. '��ɳ����л���ֵ�����׼��������","FColor":250,"BColor":0,"Type":6,"Time":6,"SendName":"ϵͳ��","Y":"0"}')
    for i = 1, 5, 1 do
        sendmsg("0", 2,
                '{"Msg":"������' ..
                        isKFStr .. '��ɳ����л���ֵ�����׼��������","FColor":250,"BColor":0,"Type":0,"Time":3,"SendName":"ϵͳ��","Y":"30"}')
    end
end
