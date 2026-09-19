npc = {}


function npc.main(play, npcid)
   
    Player.sendmsgEx(play, "携带矿物移动到此处可以提交矿石#57")
end

function npc.link(play, npcid, ew, aid, data)
    npc.main(play, npcid)
end

return npc
