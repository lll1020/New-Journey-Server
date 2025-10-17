npc = {}
--ÐÞ¸´ÐùÔ¯½£

local _config = teshudata["npc_601"]

function npc.main(play,npcid)
    sendluamsg(play,100,npcid,0,0,"")
end

function npc.link(play,npcid,ew,aid)
    if ew == 1 then
        if not checktitle(play, _config.details.ch) then
            local name, num = Player.checkItemNumByTable(play, _config.cost)
            if name then
                Player.sendmsgEx(play, string.format("ÄãµÄ|%s#249|²»×ã|%d#249", name, num))
                return
            end
            Player.takeItemByTable(play, _config.cost, ",ÐÞ¸´ÐùÔ¯½£",nil)


            Player.title_give(play, _config.details.ch)
            Player.sendmsgEx(play, "ÐùÔ¯½£ÐÞ¸´³É¹¦£¬»ñµÃ³ÆºÅ¡¾".._config.details.ch.."¡¿")
        else
            Player.sendmsgEx(play, "ÄãÒÑ¾­ÓµÓÐÐùÔ¯½£³ÆºÅ£¬ÎÞÐèÐÞ¸´#249")
            return
        end
    end
end

return npc