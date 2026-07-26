npc = {}

function npc.main(play, npcid)
    sendluamsg(play, 100, npcid, 0, 0, "")
end

function npc.link(play, npcid, aid)
    if aid ~= 1 then
        return
    end

    if checkkuafuconnect() then
        mapmove(play, "跨服地图", 45, 45, 4)
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff7700\'>[跨服]</font><font color=\'#00ff00\'>跨服传送成功</font>","Type":9}')
        sendluamsg(play, 101, 9999, 0, 0, "npc_1012")
    else
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff7700\'>[跨服]</font><font color=\'#ff0000\'>跨服未开启...</font>","Type":9}')
    end
end

return npc
