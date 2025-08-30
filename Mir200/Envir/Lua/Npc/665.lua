npc = {}

function npc.main(play,npcid)
    say(play,[[<Img|id=ui_1|x=0.0|y=-1.0|width=800|height=600|img=public/bg_npc_01.png|bg=1|esc=1|move=0|reset=1|show=0|scale9l=15|scale9r=15|scale9t=15|scale9b=15|loadDelay=1>
<Layout|id=ui_2|x=801.0|y=0.0|width=80|height=80|link=@exit>
<Button|id=ui_3|x=794|y=0.0|width=26|height=42|nimg=public/1900000510.png|pimg=public/1900000511.png|color=255|size=18|link=@exit>
<EquipShow|id=ui_27|x=0|y=500|index=71|showtips=1|link=@�ű�����>
<EquipShow|id=ui_28|x=50|y=500|index=72|showtips=1|link=@�ű�����>
<EquipShow|id=ui_29|x=100|y=500|index=73|showtips=1|link=@�ű�����>
<EquipShow|id=ui_30|x=150|y=500|index=17|showtips=1|link=@�ű�����>
<EquipShow|id=ui_300|x=200|y=500|index=87|showtips=1|link=@�ű�����>
<EquipShow|id=ui_301|x=250|y=500|index=104|showtips=1|link=@�ű�����>

<Button|id=ui_100|x=150|y=450|width=160|height=40|nimg=public/1900000660.png|color=251|size=16|text=llxf����|link=@ggna,23>

<Button|id=ui_39|x=18|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=����������ʼ|link=@jqr_ddzbks,20>
<Button|id=ui_40|x=100|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=������������|link=@jqr_ddzbjs,21>
<Button|id=ui_41|x=200|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=��ټ���Ľ��ʼ|link=@jqr_yjxbks,22>
<Button|id=ui_42|x=300|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=��ټ���Ľ����|link=@jqr_yjxbjs,23>
<Button|id=ui_43|x=400|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=��Ӫ�Կ���ʼ|link=@jqr_zydkks,24>
<Button|id=ui_44|x=500|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=��Ӫ�Կ�����|link=@jqr_zydkjs,25>


<Button|id=ui_45|x=500|y=150|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=��ɳ��ʼ|link=@ggna,21>
<Button|id=ui_46|x=700|y=150|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=Ʈ�ֲ���|link=@ggn,14>

	]])
end

function ggn(play,id)
    if id == "1" then
        local item = linkbodyitem(play,73)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>�����쳣</font>","Type":9}')
        else
            if checktitle(play,"��֮��") then
                sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>���Ѿ���������֮����</font>","Type":9}')
            else
                confertitle(play,"��֮��")
                changecustomitemvalue(play,linkbodyitem(play,73),0,"=",20,1)
                sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>���</font>","Type":9}')
            end
        end
    elseif id == "2" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>�����쳣</font>","Type":9}')
        else
            local sx = json2tbl(getitemcustomabil(play, item))
            if sx.abil[2].v[1][3] >= 30 then
                sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>������</font>","Type":9}')
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
                confertitle(play,"���������ħ")
                sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>���</font>","Type":9}')
            end
        end
    elseif id == "3" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>�����쳣</font>","Type":9}')
        else
            changecustomitemvalue(play,item,0,"=",400,0)
            changecustomitemvalue(play,item,1,"=",400,0)
            changecustomitemvalue(play,item,2,"=",4000,0)
            changecustomitemvalue(play,item,3,"=",20000,0)
            changecustomitemvalue(play,item,9,"=",5000,0)
            confertitle(play,"�������200��")
            changecustomitemvalue(play,item,4,"=",200,0)
            changecustomitemvalue(play,item,5,"=",10,0)
            changecustomitemvalue(play,item,6,"=",20,0)
            changecustomitemvalue(play,item,7,"=",10,0)
            changecustomitemvalue(play,item,8,"=",20,0)
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>���</font>","Type":9}')
        end
    elseif id == "4" then
        local zs = getbaseinfo(play,39)
        if zs > 5 then
            sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[ת��]</font><font color=\'#ff0000\'>��ת���������Ѿ�������</font>","Type":9}')
        else
            setbaseinfo(play,39,6)
            confertitle(play,"6��ת��")
            changecustomitemvalue(play,linkbodyitem(play,72),0,"=",15,2)
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>���</font>","Type":9}')
        end
    elseif id == "5" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>�����쳣</font>","Type":9}')
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
            confertitle(play,"����ʮ��")
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>���</font>","Type":9}')
        end
    elseif id == "6" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>�����쳣</font>","Type":9}')
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
            confertitle(play,"�ɷ���ʮ��")
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>���</font>","Type":9}')
        end
    elseif id == "7" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>�����쳣</font>","Type":9}')
        else
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>���</font>","Type":9}')
        end
    elseif id == "8" then
        local item = linkbodyitem(play, 72)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>�����쳣</font>","Type":9}')
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
            confertitle(play,"��ŵر�(��)")
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>���</font>","Type":9}')
        end
    elseif id == "9" then
        local item = linkbodyitem(play, 72)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>�����쳣</font>","Type":9}')
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
            confertitle(play,"��ŵر�(��)")
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>���</font>","Type":9}')
        end
    elseif id == "10" then
        local item = linkbodyitem(play, 72)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>�����쳣</font>","Type":9}')
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
            confertitle(play,"��ŵر�(��)")
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>���</font>","Type":9}')
        end
    elseif id == "11" then
        setplaydef(play,VarCfg.T_gjyj,'{"gjyj":[100000,100000,100000,100000,100000,100000,100000,100000,100000,0,0,0]}')  --�ھ�һ��
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>���</font>","Type":9}')
    elseif id == "12" then
        setplaydef(play,VarCfg.U_qhdj[1],66)
        setplaydef(play,VarCfg.U_qhdj[2],66)
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>���</font>","Type":9}')
    elseif id == "13" then
        reddot(play, 200, 100, 10, 10, 0, "res/public/ists.png")
        reddot(play, 200, 101, 10, 10, 0, "res/public/ists.png")
        reddot(play, 0, tonumber("Button"), 10, 10, 0, "res/public/ists.png")
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>���</font>","Type":9}')
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>��ɫ���</font>","Type":9}')
    elseif id == "14" then
        sendluamsg(play,101,1002,0,0,"���Ե�ͼ")
    end
end

function ggna(play,id)
    if id == "1" then
        local item = linkbodyitem(play,73)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>�����쳣</font>","Type":9}')
        else
            deprivetitle(play,"��֮��")
            changecustomitemvalue(play,linkbodyitem(play,73),0,"=",0,1)
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>���</font>","Type":9}')
        end
    elseif id == "2" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>�����쳣</font>","Type":9}')
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
            deprivetitle(play,"������С��ħ")
            deprivetitle(play,"���������ħ")
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>���</font>","Type":9}')
        end
    elseif id == "3" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>�����쳣</font>","Type":9}')
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
                deprivetitle(play,"�������"..i.."��")
            end
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>���</font>","Type":9}')
        end
    elseif id == "4" then
        setbaseinfo(play,39,0)
        deprivetitle(play,"1��ת��")
        deprivetitle(play,"2��ת��")
        deprivetitle(play,"3��ת��")
        deprivetitle(play,"4��ת��")
        deprivetitle(play,"5��ת��")
        deprivetitle(play,"6��ת��")
        changecustomitemvalue(play,linkbodyitem(play,72),0,"=",0,2)
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>���</font>","Type":9}')
    elseif id == "5" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>�����쳣</font>","Type":9}')
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
            deprivetitle(play,"��������")
            deprivetitle(play,"����ʮ��")
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>���</font>","Type":9}')
        end
    elseif id == "6" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>�����쳣</font>","Type":9}')
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
            deprivetitle(play,"�ɷ�������")
            deprivetitle(play,"�ɷ���ʮ��")
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>���</font>","Type":9}')
        end
    elseif id == "7" then
        local item = linkbodyitem(play,71)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>�����쳣</font>","Type":9}')
        else
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>���</font>","Type":9}')
        end
    elseif id == "8" then
        local item = linkbodyitem(play,72)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>�����쳣</font>","Type":9}')
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
            deprivetitle(play,"��ŵر�(��)")
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>���</font>","Type":9}')
        end
    elseif id == "9" then
        local item = linkbodyitem(play,72)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>�����쳣</font>","Type":9}')
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
            deprivetitle(play,"��ŵر�(��)")
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>���</font>","Type":9}')
        end
    elseif id == "10" then
        local item = linkbodyitem(play,72)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>�����쳣</font>","Type":9}')
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
            deprivetitle(play,"��ŵر�(��)")
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>���</font>","Type":9}')
        end
    elseif id == "11" then
        setplaydef(play,VarCfg.T_gjyj,'{"gjyj":[100000,100000,100000,100000,100000,100000,100000,100000,100000,0,0,0],"dhjl":[0,0,0,0,0,0,0,0,0]}')  --�ھ�һ��
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>���</font>","Type":9}')
    elseif id == "12" then
        setplaydef(play,VarCfg.T_gjyj,'{"gjyj":[100000,100000,100000,100000,100000,100000,100000,100000,100000,0,0,0],"dhjl":[1,1,1,1,1,0,0,0,0]}')  --�ھ�һ��
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>���</font>","Type":9}')
    elseif id == "13" then
        setbaseinfo(play,39,36)
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>���</font>","Type":9}')
    elseif id == "14" then
        callscriptex(play, "CHANGELEVEL", "=", 200)
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>���</font>","Type":9}')
    elseif id == "15" then
        local wpdx = linkbodyitem(play,76)
        local item = linkbodyitem(play,17)
        setitemcustomabil(play, wpdx,getitemcustomabil(play, item))
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>���</font>","Type":9}')
    elseif id == "16" then
        setplaydef(play,VarCfg.U_zllv,1)
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>���</font>","Type":9}')
    elseif id == "17" then
        local zl = json2tbl(getplaydef(play,VarCfg.T_zlxj))
        zl["dj"] = 1 + zl["dj"]
        setplaydef(play,VarCfg.T_zlxj,tbl2json(zl))
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>���</font>","Type":9}')
    elseif id == "18" then
        if getplaydef(play,VarCfg.U_zxrw[1])then
            newdeletetask(play,getplaydef(play,VarCfg.U_zxrw[1]))
            playeffect(play,4011,25,-50,1,0,0)
        end
    elseif id == "19" then
        setplaydef(play,VarCfg.T_mjsj,'{"mjsj":[0,99,199,0,0,0,0,0,0,0,0,0]}')  --�ھ�һ��
    elseif id == "20" then
        setitemintparam(play,71,1,2)
    elseif id == "21" then
        repaircastle()
        addattacksabakall()
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>��ɳ��ʼ</font>","Type":9}')
    elseif id == "22" then
        setsysvar(constant.G_zbdtbs,getsysvar(constant.G_zbdtbs) > 5 and 1 or getsysvar(constant.G_zbdtbs) + 1)
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>���</font>","Type":9}')
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>��ֱ����ͼ�Ѹ���Ϊ:'..getsysvar(constant.G_zbdtbs)..'</font>","Type":9}')
    elseif id == "23" then

        --local db = json2tbl(getplaydef(play,VarCfg.T_dljq))
        --db["npc"..403][2] = 199
        --
        --setplaydef(play,VarCfg.T_dljq,tbl2json(db))

        --local data = {
        --    "��Ԩ��",
        --    "��������",
        --    "Ԩͫ�ؼ�",
        --}
        --table.sort(data)
        --for i, v in pairs(data) do
        --   release_print(i,v)
        --end


        --Player.zxrw_lingqu(play, 2008, "֧������npc_")

        --sendmail(getbaseinfo(play, 2), 0, "���߳�ֵ", "ȫ����������","����׷��ר������#1#850&�߼�׷��ר������#1#850")
        --sendluamsg(play,101,28,0,getflagstatus(play,VarCfg.BS_xslb),"")


        --
        --setitemparam(play,1,1,"996ItemValue_1")
        --
        --updatecustitemparam(play,1)
        --
        --release_print(setitemintparam(play, 1, 1))
        --delbuff(play,20137)--30��
        Player.zxrw_lingqu(play, 2129, "֧������npc_"..512)

    end

end

return npc