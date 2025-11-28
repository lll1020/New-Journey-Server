npc = {}


--npc名称：
--npc功能：
local _config = Guard.getConfig("npc_14")

function npc.main(play,npcid)
    local data = {}
    data["dj_data"] = Player.getJsonTableByVar(play, VarCfg["T_仙食坊"])
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
            Player.sendmsgEx(play,  "请先装备酒葫芦#57")
            return
        end

        local dj_data = Player.getJsonTableByVar(play, VarCfg["T_仙食坊"])
        dj_data[""..jsonData.idx] = dj_data[""..jsonData.idx] or 0
        if dj_data[""..jsonData.idx] >= _config.config[jsonData.idx].max_level then
            Player.sendmsgEx(play,  "等级已经达到了"..dj_data[""..jsonData.idx].."级，无需再提升#57")
            return
        end
        local name, num = Player.checkItemNumByTable(play, _config.config[jsonData.idx].cost)
        if name then
            Player.sendmsgEx(play, string.format("你的|%s#249|不足#249", name))
            return
        end
        Player.takeItemByTable(play, _config.config[jsonData.idx].cost, ",仙食坊",nil)
        dj_data[""..jsonData.idx] = dj_data[""..jsonData.idx] + 1
        local attrs = {}
        local attrsstr = ""
        local isall = true
        for i=1,5 do
            attrs[_config.config[i].attrID] = (dj_data[""..i] or 0) * _config.config[i].ratio
            if (dj_data[""..i] or 0) < _config.config[i].max_level then
                isall = false
            end
        end
        attrsstr = Player.getAttrTableToStr(attrs)

        local itemobj = linkbodyitem(play,_config.where)
        setaddnewabil(play, -2, "=",attrsstr, itemobj)
        refreshitem(play, itemobj)
        recalcabilitys(play)

        Player.setJsonVarByTable(play, VarCfg["T_仙食坊"], dj_data)
        local data = {}
        data["dj_data"] = dj_data
        sendluamsg(play,100,npcid,1,0,tbl2json(data))
        Player.sendmsgEx(play,  string.format("成功，%s提升到了%d级", _config.config[jsonData.idx].cost[1][1], dj_data[""..jsonData.idx]))
        if isall then
            npc.AllMaxLevel(play)
        end
    elseif p2 == 2 then
    end
end


function npc.AllMaxLevel(play)
    if checktitle(play, _config.title) then
        Player.sendmsgEx(play, "你已经拥有该称号，无需重复领取#57")
        return
    end
    Player.title_give(play, _config.title)
    Player.sendmsgEx(play, "恭喜你获得称号：|".._config.title.."#249|，称号属性永久生效")

end



local function _onTakeOnEx(actor, itemobj, where, itemname, makeid)
    if where == _config.where then
         --仙食坊
        local data = Player.getJsonTableByVar(play, VarCfg["T_仙食坊"])
        attrs = {}
        attrsstr = ""
        for i=1,5 do
            attrs[teshudata["npc_14"].config[i].attrID] = (data[""..i] or 0) * teshudata["npc_14"].config[i].ratio
        end
        attrsstr = Player.getAttrTableToStr(attrs)
        setaddnewabil(play, -2, "=",attrsstr, itemobj)
        refreshitem(play, itemobj)
        recalcabilitys(play)
    end
end
--穿装备触发
GameEvent.add(EventCfg.onTakeOnEx, _onTakeOnEx, "酒葫芦附加属性")




return npc