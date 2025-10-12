npc = {}
--转生

local _config = teshudata["npc_32"]

function npc.main(play,npcid)
    sendluamsg(play,100,npcid,0,0,"")
end

function npc.link(play,npcid,ew,aid)
    if ew == 1 then
        local level = getbaseinfo(play,39)
        if level > _config.max_level then
            Player.sendmsgEx(play,"已经满级")
            return
        end
        level = level + 1
        local name, num = Player.checkItemNumByTable(play, _config.details[level].cost)
        if name then
            Player.sendmsgEx(play, string.format("你的|%s#249|不足|%d#249", name, num))
            return
        end
        Player.takeItemByTable(play, _config.details[level].cost, ",转生",nil)
        renewlevel(play,1,0,0)
    end
end

return npc