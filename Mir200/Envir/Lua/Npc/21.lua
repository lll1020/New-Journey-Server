npc = {}
--境界提升

local _config = teshudata["npc_21"]

function npc.main(play,npcid)

    local data = {}
    --{等级,经验}
    data["level"] = getplaydef(play, VarCfg["U_境界修炼"][1])
    data["exp"] = getplaydef(play, VarCfg["U_境界修炼"][2])
    sendluamsg(play,100,npcid,0,0,tbl2json(data))
end

function npc.link(play,npcid,ew,aid)
    if ew == 1 then
        local level = getplaydef(play, VarCfg["U_境界修炼"][1])
        local exp = getplaydef(play, VarCfg["U_境界修炼"][2])
        level = level + 1

        if level >= _config.max_level then
            Player.sendmsgEx(play,  "你的境界已经达到了"..level.."级，无需再提升")
            return
        end
        local config = _config.details[level]
        if exp >= config.need_xxz then
            local name, num = Player.checkItemNumByTable(play, config.cost)
            if name then
                Player.sendmsgEx(play, string.format("你的|%s#249|不足|%d#249", name, num))
                return
            end
            Player.takeItemByTable(play, config.cost, ",材料兑换",nil)

            if FProbabilityHit(config.gl) then
                Player.sendmsgEx(play,  "很遗憾，境界提升失败，请继续努力#57")
                return
            end

            setplaydef(play, VarCfg["U_境界修炼"][1], level)
            Player.sendmsgEx(play,  "恭喜你，境界提升成功，当前境界等级为"..level.."级")
            sendluamsg(play,100,npcid,1,0,"")
            delattlist(play, "境界修为")
            Login_jjxw(play)

            sendluamsg(play,101,1005,0,0,"tpcg")
        else
            Player.sendmsgEx(play,  "你的境界经验不足，无法提升境界#57")
            return
        end
    end
end

function Login_jjxw(play)
    local attrs = {}
    local attrsstr = ""
    local level = getplaydef(play, VarCfg["U_境界修炼"][1])
    local config = _config.details[level]
    for v,k in ipairs(config.attr) do
        attrs[k[1]] = k[2]
    end
    attrsstr = Player.getAttrTableToStr(attrs)
    addattlist(play, "境界修为", "=", attrsstr, 1)
end
GameEvent.add(EventCfg.onLogin, Login_jjxw, "Login_jjxw")



return npc