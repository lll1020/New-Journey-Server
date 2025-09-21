npc = {}
--npcÃû³Æ£º
--npc¹¦ÄÜ£º
local _config = {

}


function npc.main(play,npcid)
    sendluamsg(play,100,npcid,0,0,"")
end

function npc.link(play, msgID, p1, p2, p3, msgData)
    if p1 == 1 then

    elseif p1 == 2 then

    end
end


return npc