npc = {}
--ÌìÊé

local _config = teshudata["npc_24"]

function npc.main(play,npcid)
    sendluamsg(play,100,npcid,0,0,"")
end

function npc.link(play,npcid,ew,aid)
    if ew == 1 then

    end
end

return npc