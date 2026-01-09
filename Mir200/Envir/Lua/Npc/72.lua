npc = {}


--npc名称：
--npc功能：
local _config = Guard.getConfig("npc_72")

function npc.main(play,npcid)
    local data = {}
    data["dj_data"] = Player.getJsonTableByVar(play, VarCfg["T_时光之杖"])
    sendluamsg(play,100,npcid,0,0,tbl2json(data))
end

function npc.link(play, npcid, p2, p3, msgData)

    -- npc_guard: 入参校验
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local __guardAction = Guard.normalizeAction(play, npcid, p2)
    if __guardAction == nil then
        return
    end
    p2 = __guardAction
    -- npc_guard: 操作白名单（优化：限定合法操作编号）
    local __guardAllowedActions = Guard.newActionSet({1, 2})
    if not Guard.ensureActionAllowed(play, npcid, p2, __guardAllowedActions) then
        return
    end

    if p2 == 1 then
        local jsonData = json2tbl(msgData)

        
        local equipLevel = Player.getEquipFieldByPos(play, _config.where, 1) or 0
        
        if equipLevel == 0 then
            Player.sendmsgEx(play,  "请先装备时光之杖#57")
            return
        end
        equipLevel = tonumber(equipLevel)

        if equipLevel < jsonData.idx then
            Player.sendmsgEx(play,  "时光之杖等级不足，无法提升该属性#57")
            return
        end

        local dj_data = Player.getJsonTableByVar(play, VarCfg["T_时光之杖"])
        -- 记录每条属性的鉴定次数，限制前两次的随机上限
        dj_data.__cnt = dj_data.__cnt or {}
        local idxStr = ""..jsonData.idx
        dj_data[idxStr] = dj_data[idxStr] or 0
        local curLevel = dj_data[idxStr]
        -- 没有历史次数但已有等级的，视为已完成至少三次，避免老玩家被强制降档
        local identifyCnt = dj_data.__cnt[idxStr]
        if identifyCnt == nil then
            identifyCnt = curLevel > 0 and 3 or 0
        end
        identifyCnt = identifyCnt + 1
        dj_data.__cnt[idxStr] = identifyCnt

        local maxLevel = _config.config[jsonData.idx].max_level
        local limitRatio = 1
        if identifyCnt == 1 then
            limitRatio = 0.3
        elseif identifyCnt == 2 then
            limitRatio = 0.5
        end
        local maxRoll = math.floor(maxLevel * limitRatio)
        if maxRoll < 1 then
            maxRoll = 1
        elseif maxRoll > maxLevel then
            maxRoll = maxLevel
        end

        if dj_data[""..jsonData.idx] >= _config.config[jsonData.idx].max_level then
            Player.sendmsgEx(play,  "等级已经达到了"..dj_data[""..jsonData.idx].."级，无需再提升#57")
            return
        end
        local name, num = Player.checkItemNumByTable(play, _config.cost)
        if name then
            Player.sendmsgEx(play, string.format("你的|%s#249|不足#249", name))
            return
        end
        Player.takeItemByTable(play, _config.cost, ",时光之杖",nil)
        dj_data[idxStr] = math.random(1, maxRoll)
        local attrs = {}
        local attrsstr = ""
        for i=1,10 do
            attrs[_config.config[i].attrID] = (dj_data[""..i] or 0) * _config.config[i].ratio
        end
        attrsstr = Player.getAttrTableToStr(attrs)

        local itemobj = linkbodyitem(play,_config.where)
        setaddnewabil(play, -2, "=",attrsstr, itemobj)
        refreshitem(play, itemobj)
        recalcabilitys(play)

        Player.setJsonVarByTable(play, VarCfg["T_时光之杖"], dj_data)
        local data = {}
        data["dj_data"] = dj_data
        sendluamsg(play,100,npcid,1,0,tbl2json(data))
        Player.sendmsgEx(play,  string.format("恭喜你，成功提升了|%s#249|到|%d级#249", _config.config[jsonData.idx].attr_desc, dj_data[""..jsonData.idx]))
    elseif p2 == 2 then
    end
end



local function _onTakeOnEx(actor, itemobj, where, itemname, makeid)
    if where == _config.where then
         --T_时光之杖
        local data = Player.getJsonTableByVar(actor, VarCfg["T_时光之杖"])
        local attrs = {}
        local attrsstr = ""
        for i=1,10 do
            attrs[teshudata["npc_72"].config[i].attrID] = (data[""..i] or 0) * teshudata["npc_72"].config[i].ratio
        end
        attrsstr = Player.getAttrTableToStr(attrs)
        setaddnewabil(actor, -2, "=",attrsstr, itemobj)
        refreshitem(actor, itemobj)
        recalcabilitys(actor)
    end
end
--穿装备触发
GameEvent.add(EventCfg.onTakeOnEx, _onTakeOnEx, "时光之杖附加属性")




return npc
