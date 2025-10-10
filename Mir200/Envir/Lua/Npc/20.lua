npc = {}
--冠名

local _config = teshudata["npc_20"]

function npc.main(play,npcid)
    sendluamsg(play,100,npcid,0,0,"")
end

function npc.link(play,npcid,ew,aid)
    if ew == 1 then
        if querymoney(play,23) >= _config.cost then
            if not checktitle(play,_config.ch) then
                Player.title_give(play,_config.ch,1)
                sendluamsg(play,100,npcid,0,0,"")
            else
                Player.sendmsgEx(play, "您已经拥有冠名称号，无需重复领取#57")
            end
        else
            Player.sendmsgEx(play, "您的充值金额不足，无法领取冠名称号#57")
        end
    end
end

return npc