npc = {}
--冠名

local _config = teshudata["npc_20"]

function npc.main(play,npcid)
    sendluamsg(play,100,npcid,0,0,"")
end

function npc.link(play,npcid,ew,aid)
    if ew == 1 then
        if querymoney(play,23) >= 998 then
            if not checktitle(play,"踏月主宰") then
                Player.title_give(play,"踏月主宰",1)
                Player.rwjl(play, _config.jl, "冠名")
                sendluamsg(play,100,npcid,0,0,"")
            else
                sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[踏月主宰]</font><font color=\'#ff0000\'>您已经开启过踏月主宰了</font>","Type":9}')
            end
        else
            sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[踏月主宰]</font><font color=\'#ff0000\'>您没有998充值金额，无法开启</font>","Type":9}')
        end
    elseif ew == 2 then
        if querymoney(play,23) >= 3998 then
            if not checktitle(play,"绝世无双") then
                Player.title_give(play,"绝世无双",1)
                Player.rwjl(play, _config.jl2, "冠名")
                sendluamsg(play,100,npcid,0,0,"")
            else
                sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[踏月主宰]</font><font color=\'#ff0000\'>您已经开启过绝世无双了</font>","Type":9}')
            end
        else
            sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[踏月主宰]</font><font color=\'#ff0000\'>您没有3998充值金额，无法开启</font>","Type":9}')
        end
    end
end

return npc