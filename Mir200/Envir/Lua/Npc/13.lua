npc = {}
--npc名称：
--npc功能：
local _config = teshudata["npc_13"]

function npc.main(play,npcid)
    local data = {}
    data["dj_num"] = getplaydef(play, VarCfg["U_兰姐好感度"])
    sendluamsg(play,100,npcid,0,0,tbl2json(data))
end

function npc.link(play, npcid, p2, p3, msgData)

    if p2 == 1 then
        local dj_data = getplaydef(play, VarCfg["U_兰姐好感度"])
        if dj_data >= _config.max_level then
            Player.sendmsgEx(play,  "好感度等级已经达到了"..dj_data.."级，无需再提升#57")
            return
        end
        dj_data = dj_data + 1
        local config = _config.config[dj_data]
        local name, num = Player.checkItemNumByTable(play, config.cost)
        if name then
            Player.sendmsgEx(play, string.format("你的|%s#249|不足|%d#249", name, num))
            return
        end
        Player.takeItemByTable(play, config.cost, ",兰姐好感度",nil)
        setplaydef(play, VarCfg["U_兰姐好感度"], dj_data)

        delattlist(play, "兰姐好感度")
        addattlist(play, "兰姐好感度", "=", "3#".._config.attrID.."#".._config.config[dj_data].ratio, 1)
        sendluamsg(play,100,npcid,1,0,"")

        if dj_data == _config.max_level then
            npc.AllMaxLevel(play)
            Player.sendmsgEx(play, "恭喜你，你的好感度提升到了|"..dj_data.."级#249|，已满级")
        else
            Player.sendmsgEx(play, "恭喜你，你的好感度提升到了|"..dj_data.."级#249|")
        end
    elseif p2 == 2 then
    end
end


function npc.AllMaxLevel(play)
    Player.rwjl(play,{{_config.max_give,1}},"兰姐好感度",nil)
end





return npc