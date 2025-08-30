--------------------buff自定义监听触发-------------------
function buffchufa(play, buffid, zid)
    if buffid == 19999 then
        if getbaseinfo(play, 6) < 30 then
            changelevel(play, '+', 1)
            humanhp(play,"+",getbaseinfo(play,10)-getbaseinfo(play,9))
        else
            delbuff(play, 19999)
        end
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
    end
end