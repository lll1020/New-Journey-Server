npc = {}
--斗笠升级2

local _config = teshudata["npc_51"]

function npc.main(play,npcid)
    sendluamsg(play,100,npcid,0,0,"")
end

function npc.link(play,npcid,ew,aid,data)
    if ew == 1 then --
        local equipname = Player.getEquipNameByPos(play, _config.where)
        if equipname ~= _config.now then
            Player.sendmsgEx(play, "请先装备".._config.now.."#249|进行升级#57")
            return
        end
        local name, num = Player.checkItemNumByTable(play, _config.cost)
        if name then
            Player.sendmsgEx(play, string.format("你的|%s#249|不足|%d#249", name, num))
            return
        end
        Player.takeItemByTable(play, _config.cost, ",升级斗笠",nil)
        changeitemidx(play,getiteminfo(play,linkbodyitem(play,_config.where),1),getstditeminfo(_config.give, ConstCfg.stditeminfo.idx))
        Player.sendmsgEx(play,  "恭喜你，斗笠升级成功，当前斗笠为".._config.give.."#249|")
        sendluamsg(play,100,npcid,1,0,"")
        sendluamsg(play,101,1005,0,0,"qhcg")
    end
end


return npc