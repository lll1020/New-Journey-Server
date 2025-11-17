npc = {}
--npc名称：
--npc功能：
local _config = teshudata["npc_44"]

function npc.main(play,npcid)
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    if jq_data["npc55"] and jq_data["npc55"] >= 2 then
        sendluamsg(play,100,npcid,0,0,tbl2json(data))
    else -- 未完成该前置任务
        Player.sendmsgEx(play,  "你还未完成开辟仙府任务，无法进行该操作#57")
        return
    end
end

function npc.link(play, npcid, p2, p3, msgData)
    if p2 == 1 then
       
    elseif p2 == 2 then
        
    end
end




return npc