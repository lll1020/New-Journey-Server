release_print("useitme.lua")
--------------------˫����Ʒ����-------------------���ʯ
function stdmodefunc9(play, item)
    setplaydef(play,"S$dtm",getbaseinfo(play, 3))
    if getplaydef(play,"N$ս��״̬") < os.time() then
        map(play,getbaseinfo(play,3))
    else
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>ս��״̬�޷�ʹ��...</font>","Type":9}')
    end
    return false
end
--------------------˫����Ʒ����-------------------�س�ʯ
function stdmodefunc10(play, item)
    setplaydef(play,"S$dtm",getbaseinfo(play, 3))

    local du = getbaseinfo(play, 3)
    if getplaydef(play,"N$ս��״̬") < os.time() then
        if du == "xtc" or du == "��������" or du == "��������" or du == "���ݳ�" or du == "������" or du == "��������" or du == "��������" or du == "����λ��" or du == "̾Ϣ��Ұ" then
            mapmove(play, 'xtc', 137,138,8)
            addhpper(play, '=', 100)
            addmpper(play, '=', 100)
        elseif daluditu[du] and daluditu[du] == 1 then mapmove(play, "xtc",137,138,5) addhpper(play, '=', 100) addmpper(play, '=', 100)
        elseif daluditu[du] and daluditu[du] == 2 then mapmove(play, "��������",104,85,4) addhpper(play, '=', 100) addmpper(play, '=', 100)
        elseif daluditu[du] and daluditu[du] == 3 then mapmove(play, "��������",104,119,5) addhpper(play, '=', 100) addmpper(play, '=', 100)
        elseif daluditu[du] and daluditu[du] == 4 then mapmove(play, "���ݳ�",649,183,3) addhpper(play, '=', 100) addmpper(play, '=', 100)
        elseif daluditu[du] and daluditu[du] == 5 then mapmove(play, "������",47,46,4) addhpper(play, '=', 100) addmpper(play, '=', 100)
        elseif daluditu[du] and daluditu[du] == 6 then mapmove(play, "��������",53,43,4) addhpper(play, '=', 100) addmpper(play, '=', 100)
        elseif daluditu[du] and daluditu[du] == 7 then mapmove(play, "��������",24,22,5) addhpper(play, '=', 100) addmpper(play, '=', 100)
        elseif daluditu[du] and daluditu[du] == 8 then mapmove(play, "����λ��",62,61,5) addhpper(play, '=', 100) addmpper(play, '=', 100)
        elseif daluditu[du] and daluditu[du] == 9 then mapmove(play, "̾Ϣ��Ұ",92,76,5) addhpper(play, '=', 100) addmpper(play, '=', 100)
        else
            mapmove(play, 'xtc', 137,138,8)
            addhpper(play, '=', 100)
            addmpper(play, '=', 100)
        end
    else
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>ս��״̬�޷�ʹ��...</font>","Type":9}')
    end
    return false
end
--------------------˫����Ʒ����-------------------������ϴ��
function stdmodefunc20(play, item)
    setbaseinfo(play,46,getbaseinfo(play,46)-100)
    sendmsg(play,1,'{"Msg":"pkֵ�½�100��...","FColor":219,"BColor":255,"Type":1}')
    sendmsg(play,1,'{"Msg":"ʣ��'..getbaseinfo(play,46)..'...","FColor":219,"BColor":255,"Type":1}')
end
--------------------˫����Ʒ����-------------------����ͨ��
function stdmodefunc21(play, item)
    changemoney(play, getflagstatus(play,VarCfg.BS_mztq) == 1 and 7 or 8, '+', getstditeminfo(getiteminfo(play, item, 2), 8), '˫�����', true)
end

--------------------˫����Ʒ����-------------------���ͨ��
function stdmodefunc11(play, item)
    local sl = getiteminfo(play, item, 5)
    changemoney(play, getflagstatus(play,VarCfg.BS_mztq) == 1 and 2 or 4, '+', getstditeminfo(getiteminfo(play, item, 2), 8) * sl, '˫�����', true)
    delitembymakeindex(play, getiteminfo(play, item, 1), sl)
end
--------------------˫����Ʒ����-------------------Ԫ��ͨ��
function stdmodefunc18(play, item)
    local sl = getiteminfo(play, item, 5)
    changemoney(play, getflagstatus(play,VarCfg.BS_mztq) == 1 and 1 or 3, '+', getstditeminfo(getiteminfo(play, item, 2), 8) * sl, '˫�����', true)
    delitembymakeindex(play, getiteminfo(play, item, 1), sl)
end

---ǧ�ﴫ��
function stdmodefunc234(play) ---ǧ�ﴫ�� ��ʾ��ʹ��50��
    if checkkuafu(play) then
        stop(play)
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>�������ʹ�ø���Ʒ</font>","Type":9}')
        return
    end
    stop(play)
    if getbaseinfo(play,6) < 60 then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>ʹ��ǧ�ﴫ����Ҫ�ﵽ60����</font>","Type":9}')
        return
    end
    say(play, "<����/@@InputString23(�����봫�����ݣ�)>\\")
end
function inputstring23(play) ---
    if getbaseinfo(play,6) < 60 then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>ʹ��ǧ�ﴫ����Ҫ�ﵽ60����</font>","Type":9}')
        return
    end
    local text = getplaydef(play, "S23")
    local name_len = string.len(text)
    if name_len < 1 then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>����������</font>","Type":9}')
        return
    end
    if name_len > 100 then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>���ݹ���</font>","Type":9}')
        return
    end
    if getbagitemcount(play, "ǧ�ﴫ��") < 1 then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>ǧ�ﴫ������</font>","Type":9}')
        return
    end
    local result, name = exisitssensitiveword(text)
    if result then
        sendmsg(actor, 1, '{"Msg":"<font color=\'#ff0000\'>���ݰ������д�</font>","Type":9}')
        return
    end
    takeitem(play, "ǧ�ﴫ��", 1)
    FsendQfPz(play, "��ǧ�ﴫ����" .. getbaseinfo(play, 1) .. "��" .. text, 1)
end
function FsendQfPz(actor,str,count)
    for i = 1, count, 1 do
        sendmsg(actor, 2, '{"Msg":"'..str..'","FColor":250,"BColor":0,"Y":'..(90+i*30)..',"Type":5}')
    end
end
---ǧ�ﴫ�� --end