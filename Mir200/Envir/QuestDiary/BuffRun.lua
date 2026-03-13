--------------------buff自定义监听触发-------------------
function buffchufa(play, buffid, zid)
    if buffid == 19999 then
        if getbaseinfo(play, 6) < 30 then
            changelevel(play, '+', 1)
            humanhp(play,"+",getbaseinfo(play,10)-getbaseinfo(play,9))
        else
            delbuff(play, 19999)
        end
    elseif buffid == 20103 then

        local curzuiyi = getplaydef(play, VarCfg["J_醉意值"])
        if curzuiyi < 100 then
            Player.sendmsgEx(play, string.format("你的醉意值未达上限|%d#249|，无法开启|醉酒狂魔舞#57", _config.max_zuiyi))
            delbuff(play, 20103)
            return
        end


        local name, num = Player.checkItemNumByTable(play, {{"元宝",200}})
        if name then
            delbuff(play, 20103)
            return
        end
        Player.takeItemByTable(play, {{"元宝",200}}, ",醉酒狂魔舞",nil)
    end
end
--------------------buff监听触发-------------------
function buffchange(play, buffid, zid, lx)
    if buffid == 20060 then
        if lx == 4 then
            moneychange16(play)
        end
    elseif buffid == 20078 then
        if lx == 4 then
            if querymoney(play,15) < querymoney(play,14) then
                changemoney(play,15,"+",1,"倒计时结束",true)
            end
            if querymoney(play,15) < querymoney(play,14) then
                addbuff(play,20078,180)
            end
        end
    elseif buffid == 20000 or buffid == 20001 or buffid == 20002 then
        -- 飞剑功能临时下线
    elseif buffid == 20103 then 
        if getbaseinfo(play,1) == "酒仙秘境" then
            mapmove(play, "xtc",137,138,5)
            Player.sendmsgEx(play, "醉酒狂魔舞效果消失#57|,你离开了|酒仙秘境#249")
        end
    end
end
