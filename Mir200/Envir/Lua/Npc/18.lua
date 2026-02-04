npc = {}



function npc.main(play,npcid)
    if getbaseinfo(play,48) then
        local sj = os.time()
        if sj - getplaydef(play,"N$zls") > 10 then
            setplaydef(play,"N$zls",sj)
            addhpper(play,"=",100)
            addmpper(play,"=",100)
            sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[疗伤师]</font><font color=\'#00ff00\'>治疗好了...</font>","Type":9}')
        else
            sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[疗伤师]</font><font color=\'#ff0000\'>治疗冷却中...['.. 10  - (sj - getplaydef(play,"N$zls"))..'秒]</font>","Type":9}')
        end
    else
        sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[疗伤师]</font><font color=\'#ff0000\'>安全区外无法使用...</font>","Type":9}')
        sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[疗伤师]</font><font color=\'#ff0000\'>请先回到安全区...</font>","Type":9}')
    end
end

return npc
