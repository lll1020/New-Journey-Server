Login = {}
function Login.main(play)
    local weizhi = linkbodyitem(play,17)
    if weizhi == "0" then
        setsndaitembox(play,1) --���κ�
        setbagcount(play,126) --����
        giveonitem(play,17,"ʱװ�·�",1)
        addbuff(play,19999) --�����ݵ�buff

        setflagstatus(play,VarCfg.BS_huishou[1],1)
        setflagstatus(play,VarCfg.BS_huishou[2],1)
        setflagstatus(play,VarCfg.BS_huishou[3],1)
        setflagstatus(play,VarCfg.BS_huishou[4],1)
        setflagstatus(play,VarCfg.BS_huishou[5],1)

        setplaydef(play,VarCfg.T_sgcf,"{}")--ɱ�ִ���
        setplaydef(play,VarCfg.T_hsdg, '{"1_1_1":1,"1_1_2":1,"1_1_3":1,"1_2_1":1,"1_2_2":1,"1_3_1":1,"1_3_2":1,"1_3_3":1}')--���մ�
        setplaydef(play,VarCfg.T_dljq,"{}")--������JSON
        setplaydef(play,VarCfg.T_czlb,"{}")--�������
        setplaydef(play,VarCfg.T_jls,"{}")--��¼ʯ
        setplaydef(play,VarCfg.T_zxrw,"{}")--֧���������
        setplaydef(play,VarCfg.T_rwjl,"{}")--������ȡ��¼
        setplaydef(play,VarCfg.T_xybl,"{}")--���˱���
        setplaydef(play,VarCfg.T_grss,"{}")--�����ױ�
        setplaydef(play,VarCfg.T_qrbq,"{}")--��������
        setplaydef(play,VarCfg.T_szjl,"{}")--ʱװ��¼
        setplaydef(play,VarCfg.T_xldtsg,"{}")--ϵ�е�ͼɱ��
        setplaydef(play,VarCfg.T_xldtsgjl,"{}")--ϵ�е�ͼɱ�ֽ���
        setplaydef(play,VarCfg.T_aigj,"{}")--ai�һ�
        setplaydef(play,VarCfg.T_rwwp,"{}")--������Ʒ
        setplaydef(play,VarCfg.T_ywl,"{}")--����¼
        setplaydef(play,VarCfg.T_hdjl,"{}")--�����
        setplaydef(play,VarCfg.T_zscl,"{}")--ת�����ϵ���
        setplaydef(play,VarCfg.T_txzr,"{}")--��ѡ֮�˵���
        setplaydef(play,VarCfg.T_sq_jd,"{}")--�ر���������
        setplaydef(play,VarCfg.T_tshs,"{}")--�������
        setplaydef(play,VarCfg.T_rwsg,"{}")--��������ɱ��
        setplaydef(play,VarCfg.T_dlsgjl,"{}")--��½ɱ������

        if getsysvar(VarCfg["G_������֤"]) == 0 then
            setsysvar(VarCfg["G_������֤"],1)
            setsysvar(VarCfg["G_��������"],1)
            setsysvar(VarCfg["A_ȫ������json"],"{}")  --ȫ���ױ�
        end
        Login_msg(play,0)

        --TODO  ��ʼ������
        setplaydef(play,VarCfg.U_zxrw[1],1)
        mapmove(play,"���ֵ�ͼ",127,268,2)
    end

    --ȫ��ͨ����¼
    if checktitle(play,"̤������") then
        sendmovemsg("0", 1, 253, 0, 200, 1,"[����]��ҡ�"..getbaseinfo(play, 1).."����¼��ȫ����Ŀ...")
    end

    if getconst(play, '<$SERVERNAME>') == "������" or getconst(play, '<$SERVERNAME>') == "ֱ����" or getconst(play, '<$SERVERNAME>') == "�����1��" or getconst(play, '<$SERVERNAME>') == "" then
        setgmlevel(play, 10)
    end

    --------------------------------------------------��ʱ�ű�
    repairall(play)--�޸�ȫ��
    setbaseinfo(play,33,0)----���ù�ͷ
    setflagstatus(play,300,0) --ȡ���һ����ñ�ʶ
    pickupitems(play,0,5,800) --�Զ�����
    login_fhsx(play) --���ˢ��
    ---------------------------------------------------����ʱ��
    setontimer(play, 4, 60, 0, 1)

    ---------------------------------------------------�ͻ���ͬ������
    local zhid = tonumber(getconst(play,"<$USERACCOUNT>"))
    if constant.pz_zbfc[zhid] then
        sendluamsg(play,103,1,0,0,'{"kqfz":'..getsysvar(VarCfg["G_��������"])..',"kqts":'..getsysvar(VarCfg["G_��������"])..',"rwid":'..(getplaydef(play,VarCfg.U_zxrw[1]))..',"ngkg":'..getflagstatus(play,VarCfg.BS_ngkg)..',"sczt":'..getflagstatus(play,VarCfg.BS_sckg)..',"hqcs":'..globalinfo(3)..',"zhuboma":'.. 1 ..',"tsqb":'..getflagstatus(play,VarCfg.BS_tsqb)..',"zbfc":1'..'}')
    else
        sendluamsg(play,103,1,0,0,'{"kqfz":'..getsysvar(VarCfg["G_��������"])..',"kqts":'..getsysvar(VarCfg["G_��������"])..',"rwid":'..(getplaydef(play,VarCfg.U_zxrw[1]))..',"ngkg":'..getflagstatus(play,VarCfg.BS_ngkg)..',"sczt":'..getflagstatus(play,VarCfg.BS_sckg)..',"hqcs":'..globalinfo(3)..',"zhuboma":'.. 1 ..',"tsqb":'..getflagstatus(play,VarCfg.BS_tsqb)..',"U_dlxz_bc":'..getplaydef(play,VarCfg.U_dlxz_bc)..'}')
    end

    ---------------------------------------------------�Զ����
    if getflagstatus(play,VarCfg.BS_huishou[4]) == 1 then
        sendmsg(play,1,'{"Msg":"[�Զ������ѿ���]","FColor":219,"BColor":255,"Type":1}')
    else
        sendmsg(play,1,'{"Msg":"[�Զ������ѹر�]","FColor":56,"BColor":255,"Type":1}')
    end
    ---------------------------------------------------����
    if checktitle(play,"��֮��") then
        seticon(play,0,1,10294,0,0,0,0,0)
    end

    ---------------------------------------------------�������
    if querymoney(play,15) < querymoney(play,14) and not hasbuff(play,20078) then
        changemoney(play,15,"=",querymoney(play,14),"��ʼ������",true)
    elseif querymoney(play,16) > 0 and not hasbuff(play,20060) then
        changemode(play,23,999999999,querymoney(play,15)+1)
    else
        changemode(play,23,999999999,querymoney(play,15))
    end
    Login_jnsh(play)  --�����˺�����
    Login_jmjnsh(play)  --���⼼���˺�����


    GameEvent.push(EventCfg.onLogin, play)

end


return Login