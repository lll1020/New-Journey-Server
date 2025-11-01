npc = {}
--转生

local _config = teshudata["npc_32"]

function npc.main(play,npcid)
    local data = {}
    data["level"] = getplaydef(play, VarCfg["U_转生等级"])
    sendluamsg(play,100,npcid,0,0,tbl2json(data))
end

function npc.link(play,npcid,ew,aid)
    if ew == 1 then
        local level = getplaydef(play, VarCfg["U_转生等级"])
        if level > _config.max_level then
            Player.sendmsgEx(play,"已经满级")
            return
        end
        level = level + 1
        local config = _config.details[level]
        local name, num = Player.checkItemNumByTable(play, config.cost)
        if name then
            Player.sendmsgEx(play, string.format("你的|%s#249|不足|%d#249", name, num))
            return
        end
        Player.takeItemByTable(play, config.cost, ",转生",nil)
        setplaydef(play, VarCfg["U_转生等级"], level)
        Player.sendmsgEx(play, "升级成功，当前等级为"..config.x_level)
        sendluamsg(play,100,npcid,1,0,"")
        if config.x_level == 10 then
            renewlevel(play,1,0,0)
            Player.sendmsgEx(play, "转生成功")
            Player.zxrw_wancheng(play, rwcf[npcid][1], "任务") --完成任务

        end
    end
end

function Login_zsattr(play)
    local level = getplaydef(play, VarCfg["U_转生等级"])
    local attrs = {}
    local attrsstr = ""
    if level <= 0 then
        return
    end
    for i = 1, level do
        local config = _config.details[i]
        for v,k in ipairs(config.attr) do
            attrs[k[1]] = (attrs[k[1]] or 0) + k[2]
        end
    end
    attrsstr = Player.getAttrTableToStr(attrs)
    addattlist(play, "转生", "=", attrsstr, 1)
end
GameEvent.add(EventCfg.onLogin, Login_zsattr, "Login_zsattr")

return npc