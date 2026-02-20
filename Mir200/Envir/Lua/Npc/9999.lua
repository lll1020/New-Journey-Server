npc = {}



function npc.main(play,npcid)
    local zhid = tonumber(getconst(play,"<$USERACCOUNT>"))
    if constant.pz_htqx[zhid] or getconst(play, '<$SERVERNAME>') == "" or getconst(play, '<$SERVERNAME>') == "测试区" then
        -- release_print("-----------------------------")
        -- release_print(getbaseinfo(play,3).." "..getbaseinfo(play,4).." "..getbaseinfo(play,5))
        say(play,[[<Img|id=ui_1|x=0.0|y=-1.0|width=800|height=600|img=public/bg_npc_01.png|bg=1|esc=1|move=0|reset=1|show=0|scale9l=15|scale9r=15|scale9t=15|scale9b=15|loadDelay=1>
            <Layout|id=ui_2|x=801.0|y=0.0|width=80|height=80|link=@exit>
            <Button|id=ui_3|x=794|y=0.0|width=26|height=42|nimg=public/1900000510.png|pimg=public/1900000511.png|color=255|size=18|link=@exit>
            <EquipShow|id=ui_27|x=0|y=500|index=71|showtips=1|link=@脚本命令>
            <EquipShow|id=ui_28|x=50|y=500|index=72|showtips=1|link=@脚本命令>
            <EquipShow|id=ui_29|x=100|y=500|index=73|showtips=1|link=@脚本命令>
            <EquipShow|id=ui_30|x=150|y=500|index=17|showtips=1|link=@脚本命令>
            <EquipShow|id=ui_300|x=200|y=500|index=87|showtips=1|link=@脚本命令>
            <EquipShow|id=ui_301|x=250|y=500|index=104|showtips=1|link=@脚本命令>

            <Button|id=ui_100|x=150|y=450|width=160|height=40|nimg=public/1900000660.png|color=251|size=16|text=llxf测试|link=@ggna,24>
            <Button|id=ui_101|x=350|y=450|width=160|height=40|nimg=public/1900000660.png|color=251|size=16|text=测试装备|link=@ggna,23>

            <Button|id=ui_39|x=18|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=武林盟主开始|link=@jqr_ddzbks,20>
            <Button|id=ui_40|x=100|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=武林盟主结束|link=@jqr_ddzbjs,21>
            <Button|id=ui_41|x=200|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=真假鸡爱慕开始|link=@jqr_yjxbks,22>
            <Button|id=ui_42|x=300|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=真假鸡爱慕结束|link=@jqr_yjxbjs,23>
            <Button|id=ui_43|x=400|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=阵营对抗开始|link=@jqr_zydkks,24>
            <Button|id=ui_44|x=500|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=阵营对抗结束|link=@jqr_zydkjs,25>


            <Button|id=ui_45|x=500|y=150|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=攻沙开始|link=@ggna,21>
            <Button|id=ui_46|x=700|y=150|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=飘字测试|link=@ggn,14>

                ]])
    end

end

function ggn(play,id)
    if id == "1" then
        local item = linkbodyitem(play,73)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            if checktitle(play,"狂暴之力") then
                sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>您已经开启过狂暴之力了</font>","Type":9}')
            else
                confertitle(play,"狂暴之力")
                changecustomitemvalue(play,linkbodyitem(play,73),0,"=",20,1)
                sendmsg(play,1,'{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
            end
        end
    elseif id == "2" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            local sx = json2tbl(getitemcustomabil(play, item))
            if sx.abil[2].v[1][3] >= 30 then
                sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>已满级</font>","Type":9}')
            else
                changecustomitemvalue(play,item,0,"=",30,1)
                changecustomitemvalue(play,item,1,"=",1500,1)
                --changecustomitemvalue(play,item,8,"=",3000,1)
                changecustomitemvalue(play,item,2,"=",30,1)
                changecustomitemvalue(play,item,3,"=",30,1)
                changecustomitemvalue(play,item,4,"=",6000,1)
                changecustomitemvalue(play,item,5,"=",6000,1)
                changecustomitemvalue(play,item,6,"=",600,1)
                changecustomitemvalue(play,item,7,"=",600,1)
                confertitle(play,"传功阁大神魔")
                sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
            end
        end
    elseif id == "3" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            changecustomitemvalue(play,item,0,"=",400,0)
            changecustomitemvalue(play,item,1,"=",400,0)
            changecustomitemvalue(play,item,2,"=",4000,0)
            changecustomitemvalue(play,item,3,"=",20000,0)
            changecustomitemvalue(play,item,9,"=",5000,0)
            confertitle(play,"人物淬体200级")
            changecustomitemvalue(play,item,4,"=",200,0)
            changecustomitemvalue(play,item,5,"=",10,0)
            changecustomitemvalue(play,item,6,"=",20,0)
            changecustomitemvalue(play,item,7,"=",10,0)
            changecustomitemvalue(play,item,8,"=",20,0)
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        end
    elseif id == "4" then
        local zs = getbaseinfo(play,39)
        if zs > 5 then
            sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[转生]</font><font color=\'#ff0000\'>您转生在我这已经满级了</font>","Type":9}')
        else
            setbaseinfo(play,39,6)
            confertitle(play,"6重转生")
            changecustomitemvalue(play,linkbodyitem(play,72),0,"=",15,2)
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        end
    elseif id == "5" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            changecustomitemvalue(play,item,0,"=",500,2)
            changecustomitemvalue(play,item,1,"=",5000,2)
            changecustomitemvalue(play,item,2,"=",10,2)
            changecustomitemvalue(play,item,3,"=",10,2)
            changecustomitemvalue(play,item,4,"=",10,2)
            changecustomitemvalue(play,item,5,"=",1000,2)
            changecustomitemvalue(play,item,6,"=",20,2)
            changecustomitemvalue(play,item,7,"=",40,2)
            changecustomitemvalue(play,item,8,"=",20,2)
            changecustomitemvalue(play,item,9,"=",40,2)
            confertitle(play,"八卦十重")
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        end
    elseif id == "6" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            changecustomitemvalue(play,item,0,"=",10,3)
            changecustomitemvalue(play,item,1,"=",10,3)
            changecustomitemvalue(play,item,2,"=",10,3)
            changecustomitemvalue(play,item,3,"=",10,3)
            changecustomitemvalue(play,item,4,"=",1000,3)
            changecustomitemvalue(play,item,5,"=",10,3)
            changecustomitemvalue(play,item,6,"=",20,3)
            changecustomitemvalue(play,item,7,"=",10,3)
            changecustomitemvalue(play,item,8,"=",20,3)
            changecustomitemvalue(play,item,9,"=",1,3)
            changecustomitemvalue(play,item,0,"=",15,4)
            changecustomitemvalue(play,item,1,"=",30,4)
            changecustomitemvalue(play,item,2,"=",15,4)
            changecustomitemvalue(play,item,3,"=",30,4)
            confertitle(play,"仙法阁十重")
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        end
    elseif id == "7" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        end
    elseif id == "8" then
        local item = linkbodyitem(play, 72)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            changecustomitemvalue(play,item,0,"+",100,0)
            changecustomitemvalue(play,item,1,"+",100,0)
            changecustomitemvalue(play,item,2,"+",5000,0)
            local data = json2tbl(getplaydef(play,VarCfg.T_ystz))
            data.xt1 = 1
            data.xt2 = 1
            data.xt3 = 1
            data.xt4 = 1
            data.xt5 = 1
            data.xt6 = 1
            data.xt7 = 1
            data.xt8 = 1
            setplaydef(play,VarCfg.T_ystz,tbl2json(data))
            confertitle(play,"天才地宝(地)")
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        end
    elseif id == "9" then
        local item = linkbodyitem(play, 72)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            changecustomitemvalue(play,item,0,"+",250,0)
            changecustomitemvalue(play,item,1,"+",250,0)
            changecustomitemvalue(play,item,2,"+",10000,0)
            local data = json2tbl(getplaydef(play,VarCfg.T_ystz))
            data.yy1 = 1
            data.yy2 = 1
            data.yy3 = 1
            data.yy4 = 1
            data.yy5 = 1
            data.yy6 = 1
            data.yy7 = 1
            data.yy8 = 1
            setplaydef(play,VarCfg.T_ystz,tbl2json(data))
            confertitle(play,"天才地宝(天)")
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        end
    elseif id == "10" then
        local item = linkbodyitem(play, 72)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            changecustomitemvalue(play,item,0,"+",500,0)
            changecustomitemvalue(play,item,1,"+",500,0)
            changecustomitemvalue(play,item,2,"+",20000,0)
            local data = json2tbl(getplaydef(play,VarCfg.T_ystz))
            data.xc1 = 1
            data.xc2 = 1
            data.xc3 = 1
            data.xc4 = 1
            data.xc5 = 1
            data.xc6 = 1
            data.xc7 = 1
            data.xc8 = 1
            setplaydef(play,VarCfg.T_ystz,tbl2json(data))
            confertitle(play,"天才地宝(神)")
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        end
    elseif id == "11" then
        setplaydef(play,VarCfg.T_gjyj,'{"gjyj":[100000,100000,100000,100000,100000,100000,100000,100000,100000,0,0,0]}')  --冠绝一界
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
    elseif id == "12" then
        setplaydef(play,VarCfg.U_qhdj[1],66)
        setplaydef(play,VarCfg.U_qhdj[2],66)
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
    elseif id == "13" then
        reddot(play, 200, 100, 10, 10, 0, "res/public/ists.png")
        reddot(play, 200, 101, 10, 10, 0, "res/public/ists.png")
        reddot(play, 0, tonumber("Button"), 10, 10, 0, "res/public/ists.png")
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>角色红点</font>","Type":9}')
    elseif id == "14" then
        sendluamsg(play,101,1002,0,0,"测试地图")
    end
end

function ggna(play,id)
    if id == "1" then
        local item = linkbodyitem(play,73)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            deprivetitle(play,"狂暴之力")
            changecustomitemvalue(play,linkbodyitem(play,73),0,"=",0,1)
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        end
    elseif id == "2" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            changecustomitemvalue(play,item,0,"=",0,1)
            changecustomitemvalue(play,item,1,"=",0,1)
            changecustomitemvalue(play,item,2,"=",0,1)
            changecustomitemvalue(play,item,3,"=",0,1)
            changecustomitemvalue(play,item,4,"=",0,1)
            changecustomitemvalue(play,item,5,"=",0,1)
            changecustomitemvalue(play,item,6,"=",0,1)
            changecustomitemvalue(play,item,7,"=",0,1)
            changecustomitemvalue(play,item,8,"=",0,1)
            deprivetitle(play,"传功阁小神魔")
            deprivetitle(play,"传功阁大神魔")
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        end
    elseif id == "3" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            changecustomitemvalue(play,item,0,"=",0,0)
            changecustomitemvalue(play,item,1,"=",0,0)
            changecustomitemvalue(play,item,2,"=",0,0)
            changecustomitemvalue(play,item,3,"=",0,0)
            changecustomitemvalue(play,item,4,"=",0,0)
            changecustomitemvalue(play,item,5,"=",0,0)
            changecustomitemvalue(play,item,6,"=",0,0)
            changecustomitemvalue(play,item,7,"=",0,0)
            changecustomitemvalue(play,item,8,"=",0,0)
            changecustomitemvalue(play,item,9,"=",0,0)
            for i = 10, 200, 10 do
                deprivetitle(play,"神诀感悟："..i.."次")
            end
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        end
    elseif id == "4" then
        setbaseinfo(play,39,0)
        deprivetitle(play,"1重转生")
        deprivetitle(play,"2重转生")
        deprivetitle(play,"3重转生")
        deprivetitle(play,"4重转生")
        deprivetitle(play,"5重转生")
        deprivetitle(play,"6重转生")
        changecustomitemvalue(play,linkbodyitem(play,72),0,"=",0,2)
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
    elseif id == "5" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            changecustomitemvalue(play,item,0,"=",0,2)
            changecustomitemvalue(play,item,1,"=",0,2)
            changecustomitemvalue(play,item,2,"=",0,2)
            changecustomitemvalue(play,item,3,"=",0,2)
            changecustomitemvalue(play,item,4,"=",0,2)
            changecustomitemvalue(play,item,5,"=",0,2)
            changecustomitemvalue(play,item,6,"=",0,2)
            changecustomitemvalue(play,item,7,"=",0,2)
            changecustomitemvalue(play,item,8,"=",0,2)
            changecustomitemvalue(play,item,9,"=",0,2)
            deprivetitle(play,"八卦五重")
            deprivetitle(play,"八卦十重")
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        end
    elseif id == "6" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            changecustomitemvalue(play,item,0,"=",0,3)
            changecustomitemvalue(play,item,1,"=",0,3)
            changecustomitemvalue(play,item,2,"=",0,3)
            changecustomitemvalue(play,item,3,"=",0,3)
            changecustomitemvalue(play,item,4,"=",0,3)
            changecustomitemvalue(play,item,5,"=",0,3)
            changecustomitemvalue(play,item,6,"=",0,3)
            changecustomitemvalue(play,item,7,"=",0,3)
            changecustomitemvalue(play,item,8,"=",0,3)
            changecustomitemvalue(play,item,9,"=",0,3)
            changecustomitemvalue(play,item,0,"=",0,4)
            changecustomitemvalue(play,item,1,"=",0,4)
            changecustomitemvalue(play,item,2,"=",0,4)
            changecustomitemvalue(play,item,3,"=",0,4)
            deprivetitle(play,"仙法阁五重")
            deprivetitle(play,"仙法阁十重")
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        end
    elseif id == "7" then
        local item = linkbodyitem(play,71)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        end
    elseif id == "8" then
        local item = linkbodyitem(play,72)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            changecustomitemvalue(play,item,0,"-",100,0)
            changecustomitemvalue(play,item,1,"-",100,0)
            changecustomitemvalue(play,item,2,"-",5000,0)
            local data = json2tbl(getplaydef(play,VarCfg.T_ystz))
            data.xt1 = nil
            data.xt2 = nil
            data.xt3 = nil
            data.xt4 = nil
            data.xt5 = nil
            data.xt6 = nil
            data.xt7 = nil
            data.xt8 = nil
            setplaydef(play,VarCfg.T_ystz,tbl2json(data))
            deprivetitle(play,"天才地宝(地)")
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        end
    elseif id == "9" then
        local item = linkbodyitem(play,72)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            changecustomitemvalue(play,item,0,"-",250,0)
            changecustomitemvalue(play,item,1,"-",250,0)
            changecustomitemvalue(play,item,2,"-",10000,0)
            local data = json2tbl(getplaydef(play,VarCfg.T_ystz))
            data.yy1 = nil
            data.yy2 = nil
            data.yy3 = nil
            data.yy4 = nil
            data.yy5 = nil
            data.yy6 = nil
            data.yy7 = nil
            data.yy8 = nil
            setplaydef(play,VarCfg.T_ystz,tbl2json(data))
            deprivetitle(play,"天才地宝(天)")
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        end
    elseif id == "10" then
        local item = linkbodyitem(play,72)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            changecustomitemvalue(play,item,0,"-",500,0)
            changecustomitemvalue(play,item,1,"-",500,0)
            changecustomitemvalue(play,item,2,"-",20000,0)
            local data = json2tbl(getplaydef(play,VarCfg.T_ystz))
            data.xc1 = nil
            data.xc2 = nil
            data.xc3 = nil
            data.xc4 = nil
            data.xc5 = nil
            data.xc6 = nil
            data.xc7 = nil
            data.xc8 = nil
            setplaydef(play,VarCfg.T_ystz,tbl2json(data))
            deprivetitle(play,"天才地宝(神)")
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        end
    elseif id == "11" then
        setplaydef(play,VarCfg.T_gjyj,'{"gjyj":[100000,100000,100000,100000,100000,100000,100000,100000,100000,0,0,0],"dhjl":[0,0,0,0,0,0,0,0,0]}')  --冠绝一界
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
    elseif id == "12" then
        setplaydef(play,VarCfg.T_gjyj,'{"gjyj":[100000,100000,100000,100000,100000,100000,100000,100000,100000,0,0,0],"dhjl":[1,1,1,1,1,0,0,0,0]}')  --冠绝一界
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
    elseif id == "13" then
        setbaseinfo(play,39,36)
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
    elseif id == "14" then
        callscriptex(play, "CHANGELEVEL", "=", 200)
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
    elseif id == "15" then
        local wpdx = linkbodyitem(play,76)
        local item = linkbodyitem(play,17)
        setitemcustomabil(play, wpdx,getitemcustomabil(play, item))
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
    elseif id == "16" then
        setplaydef(play,VarCfg.U_zllv,1)
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
    elseif id == "17" then
        local zl = json2tbl(getplaydef(play,VarCfg.T_zlxj))
        zl["dj"] = 1 + zl["dj"]
        setplaydef(play,VarCfg.T_zlxj,tbl2json(zl))
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
    elseif id == "18" then
        if getplaydef(play,VarCfg.U_zxrw[1])then
            newdeletetask(play,getplaydef(play,VarCfg.U_zxrw[1]))
            playeffect(play,4011,25,-50,1,0,0)
        end
    elseif id == "19" then
        setplaydef(play,VarCfg.T_mjsj,'{"mjsj":[0,99,199,0,0,0,0,0,0,0,0,0]}')  --冠绝一界
    elseif id == "20" then
        setitemintparam(play,71,1,2)
    elseif id == "21" then
        repaircastle()
        addattacksabakall()
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>攻沙开始</font>","Type":9}')
    elseif id == "23" then
        local cailiao = {
"山川神石【稀有】",
"海洋神石【稀有】",
"天空神石【稀有】",
"清风神石【稀有】",
"火焰神石【稀有】",
"满月神石【稀有】",
"大地神石【稀有】",
"雷电神石【稀有】",














        }
        for k, v in pairs(cailiao) do
            giveitem(play,v,1)
        end
    elseif id == "24" then
        -- 测试脚本：调整地图怪物密度（逐图刷小怪，9x9检测饱和）
--         local map_list = {
--             -- "山庄",
--             -- "幽谷",
--             -- "洞穴",
--             -- "古殿",
--             -- "山庄一",
--             -- "幽谷一",
--             -- "洞穴一",
--             -- "古殿一",
--             -- "隐藏地图二",
--             -- "野火帮",
--             -- "野火帮大营",
--             -- "极光城郊",
--             -- "神秘森林",
--             -- "兵道古藏",
--             -- "乱葬岗",
--             -- "夜魔洞",
--             -- "洞穴深处",
--             -- "洞穴秘境",

-- --             "灰界",
-- -- "灰界南部",
-- -- "灰界北部",
-- -- "灰界东部",
-- -- "灰界西部",
-- -- "虚妄山脉",
-- -- "鬼嘲深渊",
-- -- "叹息旷野",
-- -- "禁忌之海",
-- -- "藏星海",
-- -- "藏星外海",
-- -- "神秘岛屿",
-- -- "黑暗洞窟",
-- -- "千年沉船",
-- -- "船长室",
-- -- "水手舱",
-- -- "藏星内海",
-- -- "七星岛",
-- -- "葬星城",
-- -- "葬星海滩",
-- -- "葬星海滩1",
-- -- "苍云城",
-- -- "苍云城郊外",
-- -- "苍云内城",
-- -- "苍云客栈",
-- -- "草药谷",
-- -- "仙草田",
-- -- "草药古深处",
-- -- "丹道古藏",
-- -- "酆都鬼城",
-- -- "鬼门关",
-- -- "黄泉路",
-- -- "奈何桥",
-- -- "罗酆六天",
-- -- "十八层地狱",
-- -- "六道轮回",
-- -- "大唐·长安城",
-- -- "东海龙宫",
-- -- "黑风山",
-- -- "黄风岭",
-- -- "女儿国",
-- -- "通天河",
-- -- "狮驼岭",
-- -- "天竺山",
-- -- "火焰山",
-- -- "生肖灵域",
-- -- "灵域·一层",
-- -- "子鼠灵域",
-- -- "丑牛灵域",
-- -- "寅虎灵域",
-- -- "卯兔灵域",
-- -- "灵域·二层",
-- -- "辰龙灵域",
-- -- "巳蛇灵域",
-- -- "午马灵域",
-- -- "未羊灵域",
-- -- "灵域·三层",
-- -- "申猴灵域",
-- -- "酉鸡灵域",
-- -- "戌狗灵域",
-- -- "亥猪灵域",
-- -- "灵域·秘境",
-- -- "传说之地",
-- -- "盘古开天",
-- -- "羿射九日",
-- -- "不周山",
-- -- "女娲补天",
-- -- "黑白无常",
-- -- "后土娘娘",
-- -- "真假玉帝",
-- -- "白蛇传说",
-- -- "灵兽谷",
-- -- "青龙之境",
-- -- "朱雀之境",
-- -- "玄武之境",
-- -- "白虎之境",
-- -- "麒麟之境",
-- -- "时空裂隙",
-- -- "倚天江湖",
-- -- "冰火岛",
-- -- "光明顶",
-- -- "三国乱世",
-- -- "虎牢关",
-- -- "赤壁",
-- -- "水浒再临",
-- -- "景阳冈",
-- -- "狮子楼",
-- -- "生命边界",
-- -- "白骨神庙",
-- -- "神庙暗廊",
-- -- "诡冥墨河",
-- -- "河神寝宫",
-- -- "赤焰焚殿",
-- -- "赤焰焚殿二层",
-- -- "赤焰焚殿三层",
-- -- "葬天旧土",
-- -- "聊斋志异",
-- "兰若寺",
-- "画壁",
-- "崂山",
-- "罗刹海市",
-- "敦煌遗梦",
-- "莫高窟",
-- "月牙泉",
-- "玉门关",
-- "阳关道",
-- "世界禁墟",
-- "大地禁墟一层",
-- "大地禁墟二层",
-- "大地禁墟三层",
-- "天空禁墟一层",
-- "天空禁墟二层",
-- "天空禁墟三层",
-- "海洋禁墟一层",
-- "海洋禁墟二层",
-- "海洋禁墟三层",
-- "青铜禁墟一层",
-- "青铜禁墟二层",
-- "青铜禁墟三层",
--         } -- TODO: 填入要调整的地图名
--         local normal_mobs = {"枯灯客"} -- TODO: 普通怪列表

--         local range = 3 -- 刷怪点随机半径
--         local check_range = 6 -- 9x9检测半径(2*4+1)
--         local max_fail = 40 -- 连续失败上限(饱和)
--         local tries_per_spawn = 10 -- 每次刷怪找点尝试次数
--         local spawn_limit = 5000 -- 每张地图单次补怪上限

--         for _, map in ipairs(map_list) do
--             local w = getmapinfo(map, 0) or 0
--             local h = getmapinfo(map, 1) or 0
--             if w > 0 and h > 0 then
--                 -- 检测前先清空地图怪物
--                 killmonsters(map, "*", 0, false)

--                 local counter = {n = 0}
--                 local added_normal = 0
--                 local sample_count = 0
--                 local total_ncnt = 0

--                 local fail_streak = 0
--                 local used_points = {}

--                 while fail_streak < max_fail do
--                     local rx = math.random(1, w)
--                     local ry = math.random(1, h)

--                     local key = rx.."_"..ry
--                     if used_points[key] then
--                         fail_streak = fail_streak + 1
--                     else
--                         local ok = true
--                         for k, _ in pairs(used_points) do
--                             local sx, sy = k:match("(%d+)_([%d]+)")
--                             if sx and sy then
--                                 sx = tonumber(sx)
--                                 sy = tonumber(sy)
--                                 if math.abs(rx - sx) <= check_range and math.abs(ry - sy) <= check_range then
--                                     ok = false
--                                     break
--                                 end
--                             end
--                         end

--                         if ok then
--                             genmonex(map, rx, ry, normal_mobs[math.random(1, #normal_mobs)], 1, 1, 0, 54, "", 0)
--                             used_points[key] = true
--                             counter.n = counter.n + 1
--                             added_normal = added_normal + 1
--                             fail_streak = 0
--                         else
--                             fail_streak = fail_streak + 1
--                         end
--                     end

--                     sample_count = sample_count + 1
--                     total_ncnt = total_ncnt + (used_points[key] and 1 or 0)

--                     if counter.n >= spawn_limit then
--                         break
--                     end
--                 end
--                     local avg_n = math.floor(total_ncnt / math.max(1, sample_count) + 0.5)
--                     sendmsg(play, 1, "{\"Msg\":\"<font color=\\\"#00ff00\\\">地图["..map.."] 小怪补："..added_normal.." 当前平均："..avg_n.."</font>\",\"Type\":9}")
--                     release_print("地图["..map.."] 小怪补："..added_normal)
--                     release_print("当前平均 小怪："..avg_n)
--             else
--                 sendmsg(play, 1, '{"Msg":"<font color=\"#ff0000\">地图['..map..']尺寸获取失败</font>","Type":9}')
--             end
--         end
--         return
        -- local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
        -- jq_data["npc_625"] = 0
        -- jq_data["npc_626"] = 0
        -- jq_data["npc_627"] = 0
        -- jq_data["npc_628"] = 0
        -- Player.setJsonTableByVar(play, VarCfg.T_dljq, jq_data)
        -- release_print("测试LLXF")

        -- Npclib[654].link(play, 654, 1, 0, "")

        -- local where = Player.hasEquipInArtifactSlot(play, "金箍棒")
        -- -- release_print(where)
        -- if not where then
        --     Player.sendmsgEx(play, "你需要装备金箍棒才能完成任务#57")
        --     return
        -- end
        -- local itemobj = linkbodyitem(play,where)
        -- local item_json = getitemcustomabil(play, itemobj)
        -- release_print(item_json)
        -- item_json = json2tbl(item_json)
        -- if item_json then
        --     item_json = json2tbl('{"abil":[{"i":0,"t":"[附加属性]","c":251,"v":[]}],"name":""}')
        -- end
        -- item_json.abil[1].v[1] = {1,253,200,1,13,1,1}
        -- item_json.abil[1].v[2] = {1,200,300,1,14,2,2}
        -- item_json.abil[1].v[3] = {1,244,8000,0,15,3,3}
        -- item_json.abil[1].v[4] = {1,30,5,1,16,4,4}
        -- item_json.abil[1].v[5] = {1,73,100,1,17,5,5}
        -- item_json.abil[1].v[6] = {1,89,100,1,18,6,6}
        -- item_json.abil[1].v[7] = {1,206,100,1,19,7,7}
        -- item_json = tbl2json(item_json)
        -- -- release_print(type(item_json))
        -- setitemcustomabil(play, itemobj, item_json)
        -- Player.setJsonVarByTable(play, VarCfg["T_砍树系统"], {})
        -- setplaydef(play, VarCfg.T_czlb,"{}")
        -- setplaydef(play,VarCfg.U_zxrw[1],21)
        -- setplaydef(play,VarCfg.T_hsdg, '{"1_1_1":1,"1_1_2":1,"1_1_3":1,"1_1_4":1,"1_1_5":1,"1_1_6":1,"1_1_7":1,"1_1_8":1,"1_1_9":1,"1_1_10":1,"1_1_11":1,"1_1_12":1}')--回收打勾
        sendluamsg(play, 101, 0, 1, 1, '{"lx":2,"npcdt":"' .. "二大陆主城" .. '","npcid":' .. 601 .. ',"xx":' .. 99 .. ',"yy":' .. 123 .. "}")

    end

end

return npc














