npc = {}


--npc名称：
--npc功能：
local _config = Guard.getConfig("npc_11")

function npc.main(play,npcid)
    local data = {}
    data["dj_data"] = Player.getJsonTableByVar(play, VarCfg["T_灵根修炼"])
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

        local idx = tonumber(jsonData and jsonData.idx)
        if not idx or not _config.config[idx] then
            Player.sendmsgEx(play, "参数错误#57")
            return
        end
        jsonData.idx = idx

        local dj_data = Player.getJsonTableByVar(play, VarCfg["T_灵根修炼"])
        dj_data[""..jsonData.idx] = dj_data[""..jsonData.idx] or 0
        if dj_data[""..jsonData.idx] >= _config.max_level then
            Player.sendmsgEx(play,  "等级已经达到了"..dj_data[""..jsonData.idx].."级，无需再提升#57")
            return
        end
        local name, num = Player.checkItemNumByTable(play, _config.cost)
        if name then
            Player.sendmsgEx(play, string.format("你的|%s#249|不足|%d#249", name, num))
            return
        end
        Player.takeItemByTable(play, _config.cost, ",灵根修炼",nil)
        dj_data[""..jsonData.idx] = dj_data[""..jsonData.idx] + 1
        if randomex(_config.randomdata[dj_data[""..jsonData.idx]]) then
            local attrs = {}
            local attrsstr = ""
            local isall = true
            for i=1,5 do
                attrs[_config.attrID[i]] = (dj_data[""..i] or 0) * _config.config[i].ratio
                if (dj_data[""..i] or 0) < _config.max_level then
                    isall = false
                end
            end
            attrsstr = Player.getAttrTableToStr(attrs)
            delattlist(play, "灵根修炼")
            addattlist(play, "灵根修炼", "=", attrsstr, 1)

            Player.setJsonVarByTable(play, VarCfg["T_灵根修炼"], dj_data)
            local data = {}
            data["dj_data"] = dj_data
            sendluamsg(play,100,npcid,1,0,tbl2json(data))
            Player.sendmsgEx(play,  string.format("修炼成功，%s提升到了%d级", _config.config[jsonData.idx].name, dj_data[""..jsonData.idx]))
            if isall then
                AllMaxLevel(play)
            end
        else
            Player.sendmsgEx(play,  "修炼失败，灵根没有提升#57")
            local data = {}
            data["dj_data"] = Player.getJsonTableByVar(play, VarCfg["T_灵根修炼"])
            sendluamsg(play,100,npcid,0,0,tbl2json(data))
            return
        end
    elseif p2 == 2 then
        AllMaxLevel(play)
    end
end


function AllMaxLevel(play)
    if checktitle(play, _config.title) then
        Player.sendmsgEx(play, "你已经拥有该称号，无需重复领取#57")
        return
    end
    local name, num = Player.checkItemNumByTable(play, _config.max_cost)
    if name then
        Player.sendmsgEx(play, string.format("你的|%s#249|不足|%d#249", name, num))
        return
    end
    Player.takeItemByTable(play, _config.max_cost, ",灵根修炼",nil)
    Player.title_give(play, _config.title)
    local dj_data = Player.getJsonTableByVar(play, VarCfg["T_灵根修炼"])
    local attrs = {}
    local attrsstr = ""
    for i=1,5 do
        dj_data[""..i] = 10
        attrs[_config.attrID[i]] = (dj_data[""..i] or 0) * _config.config[i].ratio
    end
    attrsstr = Player.getAttrTableToStr(attrs)
    delattlist(play, "灵根修炼")
    addattlist(play, "灵根修炼", "=", attrsstr, 1)
    Player.setJsonVarByTable(play, VarCfg["T_灵根修炼"], dj_data)
    local data = {}
    data["dj_data"] = dj_data
    sendluamsg(play,100,11,1,0,tbl2json(data))
    Player.sendmsgEx(play, "恭喜你获得称号：|".._config.title.."#249|，称号属性永久生效")

end





return npc
