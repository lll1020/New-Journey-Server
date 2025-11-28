npc = {}
--npc名称：
--npc功能：
local _config = {}

function npc.main(play,npcid)
    sendluamsg(play,100,npcid,0,0,'{"hbdh1":'..getplaydef(play,VarCfg.J_hbdh[1])..',"hbdh2":'..getplaydef(play,VarCfg.J_hbdh[2])..'}')
end

function npc.link(play, npcid, p2, p3, msgData)
    if p2 == 1 then
        if getplaydef(play,VarCfg.J_hbdh[1]) >= 10 then
            sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[货币兑换]</font><font color=\'#ff0000\'>每日兑换次数已达上限...</font>","Type":9}')
            return
        end
        if changemoney(play,3,"-",1000000,"货币兑换",true) then
            changemoney(play,4,"+",200000,"货币兑换",true)
            setplaydef(play,VarCfg.J_hbdh[1], getplaydef(play,VarCfg.J_hbdh[1]) + 1)
            sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[货币兑换]</font><font color=\'#00ff00\'>兑换成功...</font>","Type":9}')
            sendluamsg(play,100,npcid,1,0,'{"hbdh1":'..getplaydef(play,VarCfg.J_hbdh[1])..',"hbdh2":'..getplaydef(play,VarCfg.J_hbdh[2])..'}')

        else
            sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[货币兑换]</font><font color=\'#ff0000\'>元宝不足...</font>","Type":9}')
        end
    elseif p2 == 2 then
        if getplaydef(play,VarCfg.J_hbdh[2]) >= 10 then
            sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[货币兑换]</font><font color=\'#ff0000\'>每日兑换次数已达上限...</font>","Type":9}')
            return
        end
        if changemoney(play,1,"-",1000000,"货币兑换",true) then
            changemoney(play,2,"+",200000,"货币兑换",true)
            setplaydef(play,VarCfg.J_hbdh[2], getplaydef(play,VarCfg.J_hbdh[2]) + 1)
            sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[货币兑换]</font><font color=\'#00ff00\'>兑换成功...</font>","Type":9}')
            sendluamsg(play,100,npcid,1,0,'{"hbdh1":'..getplaydef(play,VarCfg.J_hbdh[1])..',"hbdh2":'..getplaydef(play,VarCfg.J_hbdh[2])..'}')

        else
            sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[货币兑换]</font><font color=\'#ff0000\'>绑定元宝不足...</font>","Type":9}')
        end
    -- elseif p2 == 3 then
    --     if changemoney(play,7,"-",1000,"货币兑换",true) then
    --         changemoney(play,1,"+",2000000,"货币兑换",true)
    --         sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[货币兑换]</font><font color=\'#00ff00\'>兑换成功...</font>","Type":9}')
    --     else
    --         sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[货币兑换]</font><font color=\'#ff0000\'>仙玉不足...</font>","Type":9}')
    --     end
    -- elseif p2 == 4 then
    --     if changemoney(play,8,"-",1000,"货币兑换",true) then
    --         changemoney(play,3,"+",2000000,"货币兑换",true)
    --         sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[货币兑换]</font><font color=\'#00ff00\'>兑换成功...</font>","Type":9}')
    --     else
    --         sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[货币兑换]</font><font color=\'#ff0000\'>绑定仙玉不足...</font>","Type":9}')
    --     end
    end
end





return npc