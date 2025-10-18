npc = {}
--Áé¸ù

local _config = teshudata["npc_22"]

function npc.main(play,npcid)
    local data = {}
    data["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_Áé¸ù"])
    sendluamsg(play,100,npcid,0,0,tbl2json(data))
end

function npc.link(play,npcid,ew,aid)
    if ew == 1 then

    end
end

return npc