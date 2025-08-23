npc = {}

function npc.main(play,npcid)
    local zhid = tonumber(getconst(play,"<$USERACCOUNT>"))
    if constant.pz_htqx[zhid] or getconst(play, '<$SERVERNAME>') == "" or getconst(play, '<$SERVERNAME>') == "测试区" then
        say(play,[[<Img|id=ui_1|children={ui_4}|x=0.0|y=-1.0|width=800|height=600|img=public/bg_npc_01.png|bg=1|esc=1|move=0|reset=1|show=0|scale9l=15|scale9r=15|scale9t=15|scale9b=15|loadDelay=1>
<Text|id=ui_4|x=85|y=360|color=255|size=18|text=发送充值礼包和人物变量查询，发送物品>
<Layout|id=ui_2|x=801.0|y=0.0|width=80|height=80|link=@exit>
<Button|id=ui_3|x=794|y=0.0|width=26|height=40|nimg=public/1900000510.png|pimg=public/1900000511.png|color=255|size=18|link=@exit>
<Button|id=ui_32|x=32|y=27|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=10转|link=@jjlggna,1>
<Button|id=ui_33|x=147|y=27|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=200级|link=@jjlggna,2>
<Button|id=ui_37|x=148|y=90|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=完成当前任务|link=@jjlggna,3>
<Button|id=ui_14|x=31|y=173|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=+10级|link=@jjlggna,14>
<Button|id=ui_15|x=152|y=174|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=-10级|link=@jjlggna,15>
<Button|id=ui_23|x=81|y=312|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=后台|link=@jjlggna,23>
<Button|id=ui_5|x=80|y=426|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=装备|link=@jjlggna,24>

<Button|id=ui_6|x=19|y=475|width=106|height=40|nimg=public/1900000660.png|color=249|size=16|text=三大陆|link=@sandalu>
<Button|id=ui_7|x=140|y=475|width=106|height=40|nimg=public/1900000660.png|color=249|size=16|text=四大陆|link=@sidalu>
<Button|id=ui_9|x=253|y=475|width=106|height=40|nimg=public/1900000660.png|color=249|size=16|text=五大陆|link=@wudalu>
<Button|id=ui_10|x=377|y=475|width=106|height=40|nimg=public/1900000660.png|color=249|size=16|text=六大陆|link=@liudalu>
<Button|id=ui_11|x=500|y=475|width=106|height=40|nimg=public/1900000660.png|color=249|size=16|text=限制全解锁|link=@buff>

<Button|id=ui_12|x=24|y=539|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=脱下身上|link=@tuo>
<Button|id=ui_13|x=140|y=539|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=清理背包|link=@qing>
<Button|id=ui_16|x=255|y=539|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=货币全满|link=@jhb>
<Button|id=ui_17|x=374|y=539|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=货币清零|link=@qhb>


	]])
    end

end

function jjlggna(play,id)
    if id == "1" then
        setbaseinfo(play,39,36)
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
    elseif id == "2" then
        callscriptex(play, "CHANGELEVEL", "=", 200)
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
    elseif id == "3" then
        if getplaydef(play,constant.U_zxrw[1])then
            newdeletetask(play,getplaydef(play,constant.U_zxrw[1]))
            playeffect(play,4011,25,-50,1,0,0)
        end
    elseif id == "4" then

    elseif id == "5" then
    elseif id == "6" then
    elseif id == "7" then
    elseif id == "8" then
    elseif id == "9" then
    elseif id == "10" then
    elseif id == "11" then
    elseif id == "12" then
    elseif id == "13" then
    elseif id == "14" then
        callscriptex(play, "CHANGELEVEL", "+", 10)
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
    elseif id == "15" then
        callscriptex(play, "CHANGELEVEL", "-", 10)
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
    elseif id == "16" then
    elseif id == "17" then
    elseif id == "18" then
    elseif id == "19" then
    elseif id == "20" then
    elseif id == "21" then
    elseif id == "22" then
    elseif id == "23" then
        sendluamsg(play, 101, 998, 0, 0,"")
    elseif id == "24" then
        Npclib[666].main(play, 0, 0, "")
    end


end

function qing(play)
    gmexecute(play,"qq")
    giveitem(play,"盟重回城石")
    giveitem(play,"随机传送石")
end

function sandalu(play)
    mapmove(play,"中州城",643,175,4)
end

function buff(play)

    setplaydef(play,constant.U_zxrw[1],18)
    Player.zxrw_wancheng(play, 18, "")

    renewlevel(play,5,0,0)


    local item = linkbodyitem(play, 71)
    local sx = json2tbl(getitemcustomabil(play, item))
    local dj = sx.abil[rwxw.attr[1][1] + 1].v[rwxw.attr[1][2] + 1][3] / rwxw.attr[1][3]
    for _,k in ipairs(rwxw.attr) do
        changecustomitemvalue(play,item,k[2],"=",k[3] * 171,k[1])
    end
    local T_ywl = json2tbl(getplaydef(play,constant.T_ywl))
    T_ywl["jl_2_2_6"] = 1
    T_ywl["jl_2_2_1"] = 1
    T_ywl["jl_2_2_2"] = 1
    T_ywl["jl_2_2_3"] = 1
    T_ywl["jl_2_2_4"] = 1
    T_ywl["jl_2_2_5"] = 1
    T_ywl["jl_3_2_6"] = 1
    T_ywl["jl_3_2_1"] = 1
    T_ywl["jl_3_2_2"] = 1
    T_ywl["jl_3_2_3"] = 1
    T_ywl["jl_3_2_4"] = 1
    T_ywl["jl_3_2_5"] = 1
    setplaydef(play,constant.T_ywl,tbl2json(T_ywl))
    local T_zzsj = json2tbl(getplaydef(play,constant.T_zzsj))
    T_zzsj.dqzy = 1
    T_zzsj.zy_dj = {}
    T_zzsj.zy_dj[""..T_zzsj.dqzy] = 100
    T_zzsj.two_jue = {}
    T_zzsj.two_jue[""..T_zzsj.dqzy] = 1
    T_zzsj.three_jue = {}
    T_zzsj.three_jue[""..T_zzsj.dqzy] = 1
    T_zzsj.sh = {}
    T_zzsj.sh[""..T_zzsj.dqzy] = 1
    setplaydef(play,constant.T_zzsj,tbl2json(T_zzsj))
end

function sidalu(play)
    mapmove(play,"天玄界",47,46,4)
end

function wudalu(play)
    mapmove(play,"北境仙域",53,43,4)
end

function liudalu(play)
    mapmove(play,"中央仙域",197,189,5)
end

function jhb(play)
    changemoney(play,1,"=",2000000000,"",true)
    changemoney(play,2,"=",2000000000,"",true)
    changemoney(play,3,"=",2000000000,"",true)
    changemoney(play,4,"=",2000000000,"",true)

    changemoney(play,7,"=",2000000000,"",true)
    changemoney(play,8,"=",2000000000,"",true)
end
function qhb(play)
    changemoney(play,1,"=",0,"",true)
    changemoney(play,2,"=",0,"",true)
    changemoney(play,3,"=",0,"",true)
    changemoney(play,4,"=",0,"",true)

    changemoney(play,7,"=",0,"",true)
    changemoney(play,8,"=",0,"",true)
end

function tuo(play)
    local dx = linkbodyitem(play,1)
    delitembymakeindex(play,getiteminfo(play,dx,1))
    for i = 0, 46, 1 do
        callscriptex(play,"TakeOffItem",i)
    end
end

return npc