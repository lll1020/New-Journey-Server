
npc = {}


--

local _config = {}


function npc.main(play,npcid)
    local data = {}
    data["T_data"] = Player.getJsonTableByVar(nil, VarCfg["A_È«·þ¹ÂÆ·"])
    sendluamsg(play,100,npcid,0,0,tbl2json(data))
end


return npc