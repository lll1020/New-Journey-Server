Login = {}
function Login.main(play)
    local weizhi = linkbodyitem(play,17)
    if weizhi == "0" then
        setsndaitembox(play,1) --���κ�
        setbagcount(play,126) --����
        giveonitem(play,17,"ʱװ�·�",1)
        setitemcustomabil(play,linkbodyitem(play,17),'{"abil":[{"i":0,"t":"[ʱװ�·�]:","c":251,"v":[[-1,243,0,1,0,0,0],[-1,1,0,0,0,1,1],[-1,14,0,0,0,1,2],[-1,25,0,0,0,2,3],[-1,4,0,0,0,2,4],[-1,22,0,1,0,3,5],[-1,9,0,0,0,3,6],[-1,10,0,0,0,4,7],[-1,11,0,0,0,5,8]]},{"i":1,"t":"[ʱװ�·�]:","c":251,"v":[[-1,12,0,0,0,0,0],[-1,89,0,2,0,1,1],[-1,245,0,2,0,2,2],[-1,76,0,2,0,3,3],[-1,79,0,2,0,3,4],[-1,25,0,2,0,4,5],[-1,73,0,2,0,5,6],[-1,242,0,2,0,6,7],[-1,73,0,2,0,7,8]]},{"i":2,"t":"[ʱװ�·�]:","c":251,"v":[[-1,12,0,0,0,0,0],[-1,77,0,2,0,1,1],[-1,245,0,2,0,2,2],[-1,76,0,2,0,3,3],[-1,79,0,2,0,3,4],[-1,204,0,2,0,4,5],[-1,205,0,2,0,5,6],[-1,246,0,2,0,6,7],[-1,73,0,2,0,7,8]]}],"name":""}')
        giveonitem(play,71,"��������",1)
        setitemcustomabil(play,linkbodyitem(play,71),'{"abil":[{"i":0,"t":"[��������]:","c":251,"v":[[-1,3,0,0,0,0,0],[-1,4,0,0,0,0,1],[-1,1,0,0,0,1,2],[-1,5,0,0,0,2,3],[-1,6,0,0,0,3,4],[-1,7,0,0,0,4,5],[-1,8,0,0,0,5,6]]},{"i":1,"t":"[����]:","c":251,"v":[[-1,4,0,1,0,0,0],[-1,25,0,1,0,1,1],[-1,4,0,1,0,2,2],[-1,28,0,1,0,3,3],[-1,60,0,1,0,4,4],[-1,1,0,1,0,5,5],[-1,1,0,0,0,6,6],[-1,10,0,0,0,7,7],[-1,244,0,0,0,8,8],[-1,242,0,1,0,9,9]]},{"i":2,"t":"[��ϻ]:","c":251,"v":[[-1,4,0,1,0,0,0],[-1,6,0,1,0,1,1],[-1,8,0,1,0,2,2],[-1,1,0,1,0,3,3],[-1,10,0,1,0,4,4],[-1,12,0,1,0,5,5],[-1,21,0,0,0,6,6],[-1,22,0,0,0,7,7],[-1,200,0,0,0,8,8]]},{"i":3,"t":"[����]:","c":251,"v":[[-1,245,0,1,0,0,0],[-1,21,0,1,0,1,1],[-1,22,0,1,0,2,2],[-1,25,0,1,0,3,3],[-1,200,0,1,0,4,4],[-1,206,0,1,0,5,5],[-1,4,0,1,10,6,6],[-1,999,0,1,4,8,8],[-1,1,0,1,4,6,8],[-1,9999,0,0,5,7,9]]},{"i":4,"t":"[����]:","c":251,"v":[[-1,999,0,1,10,0,0],[-1,4,0,1,10,0,1],[-1,999,0,1,4,1,2],[-1,1,0,1,4,1,3]]},{"i":5,"t":"[������Ϊ]:","c":251,"v":[[-1,1,0,0,0,0,0],[-1,3,0,0,0,1,1],[-1,4,0,0,0,2,2],[-1,5,0,0,0,3,3],[-1,6,0,0,0,4,4],[-1,7,0,0,0,5,5],[-1,8,0,0,0,6,6],[-1,245,0,0,0,7,7],[-1,242,0,0,0,8,8]]}],"name":""}')
        giveonitem(play,72,"��������",1)
        setitemcustomabil(play,linkbodyitem(play,72),'{"abil":[{"i":0,"t":"[������]:","c":251,"v":[[-1,244,0,0,0,0,0],[-1,3,0,1,0,1,1],[-1,4,0,1,0,2,2],[-1,1,0,1,0,3,3],[-1,244,0,0,0,4,4]]},{"i":1,"t":"[����]:","c":251,"v":[[-1,4,0,0,0,0,0],[-1,10,0,0,0,1,1],[-1,12,0,0,0,2,2],[-1,1,0,0,0,3,3],[-1,248,0,0,0,4,4],[-1,255,0,0,0,5,5],[-1,61,0,0,0,6,6],[-1,245,0,1,0,7,7],[-1,242,0,1,0,8,8],[-1,253,0,1,0,9,9]]}],"name":""}')
        giveonitem(play,73,"�ƺ�����",1)
        setitemcustomabil(play,linkbodyitem(play,73),'{"abil":[{"i":0,"t":"[����ƺ�����]:","c":251,"v":[[-1,3,0,1,0,0,0],[-1,4,0,1,0,0,1],[-1,5,0,1,0,1,2],[-1,6,0,1,0,1,3],[-1,7,0,1,0,2,4],[-1,8,0,1,7,2,5],[-1,9,0,1,0,3,6],[-1,10,0,1,0,3,7],[-1,11,0,1,0,4,8],[-1,12,0,1,0,4,9]]},{"i":1,"t":"[����ƺ�����]:","c":251,"v":[[-1,1,0,1,0,0,0],[-1,253,0,1,0,1,1],[-1,3,0,0,2,2,2],[-1,4,0,0,2,2,3],[-1,25,0,1,0,3,4],[-1,30,0,1,0,4,5],[-1,22,0,1,0,5,6],[-1,21,0,1,0,6,7],[-1,1,0,0,0,7,8]]},{"i":2,"t":"[����ƺ�����]:","c":251,"v":[[-1,999,0,1,4,0,0],[-1,1,0,1,4,0,1],[-1,999,0,1,10,1,2],[-1,4,0,1,10,1,3],[-1,82,0,1,0,2,4],[-1,200,0,1,0,3,5],[-1,201,0,1,0,4,6],[-1,77,0,1,0,5,7],[-1,67,0,1,0,6,8]]},{"i":3,"t":"[��ʯ����]:","c":251,"v":[[-1,89,0,1,0,0,0],[-1,21,0,1,0,0,1],[-1,73,0,1,0,1,2],[-1,243,0,1,0,1,3],[-1,28,0,1,0,2,4],[-1,200,0,1,0,3,5],[-1,201,0,1,0,4,6],[-1,77,0,1,0,5,7],[-1,67,0,1,0,6,8]]}],"name":""}')
        giveonitem(play,87,"���฽������",1)
        setitemcustomabil(play,linkbodyitem(play,87),'{"abil":[{"i":0,"t":"[��������]:","c":251,"v":[[-1,244,0,0,0,0,0],[-1,1,0,0,0,1,1],[-1,248,0,0,0,2,2],[-1,9,0,0,0,3,3],[-1,10,0,0,0,4,4],[-1,11,0,0,0,5,5],[-1,12,0,0,0,6,6],[-1,245,0,0,0,7,7]]},{"i":1,"t":"[����]:","c":251,"v":[[-1,244,0,0,0,0,0],[-1,1,0,0,0,1,1],[-1,248,0,0,0,2,2],[-1,3,0,0,0,3,3],[-1,4,0,0,0,4,4],[-1,242,0,0,0,5,5],[-1,12,0,0,0,6,6],[-1,245,0,0,0,7,7]]},{"i":2,"t":"[��ʳ��]:","c":251,"v":[[-1,9,0,0,0,0,0],[-1,10,0,0,0,1,1],[-1,11,0,0,0,2,2],[-1,12,0,0,0,3,3],[-1,1,0,0,0,4,4],[-1,244,0,0,0,5,5],[-1,4,0,0,0,6,6],[-1,242,0,0,0,7,7],[-1,245,0,0,0,8,8]]},{"i":3,"t":"[�������]:","c":251,"v":[[-1,1,0,0,0,0,0],[-1,1,0,1,0,1,1],[-1,9,0,1,0,2,2],[-1,10,0,1,0,3,3],[-1,11,0,1,0,4,4],[-1,12,0,1,0,5,5]]},{"i":4,"t":"[����]:","c":251,"v":[[-1,4,0,0,0,0,0],[-1,6,0,0,0,1,1],[-1,8,0,0,0,2,2],[-1,242,0,0,0,3,3],[-1,245,0,0,0,4,4]]}],"name":""}')
        giveonitem(play,104,"�����฽������",1)
        setitemcustomabil(play,linkbodyitem(play,104),'{"abil":[{"i":0,"t":"[����ǿ��]:","c":251,"v":[[-1,242,0,0,0,0,0],[-1,4,0,1,0,1,1],[-1,4,0,1,0,2,2],[-1,1,0,1,0,3,3],[-1,245,0,0,0,4,4],[-1,82,0,0,0,5,5],[-1,39,0,0,0,6,6],[-1,4,0,1,0,7,7]]},{"i":1,"t":"[��ҩ����]:","c":251,"v":[[-1,4,0,0,0,0,0],[-1,1,0,0,0,1,1],[-1,4,0,1,0,2,2],[-1,1,0,1,0,3,3],[-1,242,0,1,0,4,4],[-1,244,0,0,0,5,5],[-1,67,0,1,0,6,6],[-1,21,0,1,0,7,7],[-1,25,0,1,0,8,8],[-1,22,0,1,0,9,9]]},{"i":2,"t":"[ת������]:","c":251,"v":[[-1,1,0,1,0,0,0],[-1,3,0,1,0,1,1],[-1,4,0,1,0,2,2],[-1,9,0,1,0,3,3],[-1,10,0,1,0,4,4],[-1,11,0,1,0,5,5],[-1,12,0,1,0,6,6]]},{"i":3,"t":"[Ⱥ��ǿ��]:","c":251,"v":[[-1,1,0,1,0,0,0],[-1,3,0,1,0,1,1],[-1,4,0,1,0,2,2],[-1,5,0,1,0,3,3],[-1,6,0,1,0,4,4],[-1,7,0,1,0,5,5],[-1,8,0,1,0,6,6],[-1,245,0,0,0,7,7]]},{"i":4,"t":"[¾�ɽ�¾�ɼ�]:","c":251,"v":[[-1,3,0,0,0,0,0],[-1,4,0,1,0,1,1],[-1,245,0,0,0,2,2],[-1,1,0,0,0,3,3],[-1,1,0,1,0,4,4],[-1,89,0,0,0,5,5],[-1,36,0,0,0,6,6],[-1,37,0,0,0,7,7]]}],"name":""}')
        changemoney(play, 19, '=', 1000, '��ʼ', true)
        addbuff(play,19999) --�����ݵ�buff
        setplaydef(play,constant.T_sgcf,"{}")--ɱ�ִ���
        setplaydef(play,constant.T_hsdg, '{"1_1_1":1,"1_1_2":1,"1_1_3":1,"1_2_1":1,"1_2_2":1,"1_3_1":1,"1_3_2":1,"1_3_3":1}')--���մ�
        setflagstatus(play,constant.BS_huishou[1],1)
        setflagstatus(play,constant.BS_huishou[2],1)
        setflagstatus(play,constant.BS_huishou[3],1)
        setflagstatus(play,constant.BS_huishou[4],1)
        setflagstatus(play,constant.BS_huishou[5],1)
        setplaydef(play,constant.T_dljq,"{}")--������JSON
        setplaydef(play,constant.T_czlb,"{}")--�������
        setplaydef(play,constant.T_jls,"{}")--��¼ʯ
        setplaydef(play,constant.T_zxrw,"{}")--֧���������
        setplaydef(play,constant.T_rwjl,"{}")--������ȡ��¼
        setplaydef(play,constant.T_xybl,"{}")--���˱���
        setplaydef(play,constant.T_grss,"{}")--�����ױ�
        setplaydef(play,constant.T_qrbq,"{}")--��������
        setplaydef(play,constant.T_szjl,"{}")--ʱװ��¼
        setplaydef(play,constant.T_xldtsg,"{}")--ϵ�е�ͼɱ��
        setplaydef(play,constant.T_xldtsgjl,"{}")--ϵ�е�ͼɱ�ֽ���
        setplaydef(play,constant.T_aigj,"{}")--ai�һ�
        setplaydef(play,constant.T_rwwp,"{}")--������Ʒ
        setplaydef(play,constant.T_ywl,"{}")--����¼
        setplaydef(play,constant.T_hdjl,"{}")--�����
        setplaydef(play,constant.T_zscl,"{}")--ת�����ϵ���
        setplaydef(play,constant.T_txzr,"{}")--��ѡ֮�˵���
        setplaydef(play,constant.T_sq_jd,"{}")--�ر���������
        setplaydef(play,constant.T_tshs,"{}")--�������
        setplaydef(play,constant.T_rwsg,"{}")--��������ɱ��
        setplaydef(play,constant.T_dlsgjl,"{}")--��½ɱ������



        if getsysvar(constant.G_kqyz) == 0 then
            setsysvar(constant.G_kqyz,1)
            setsysvar(constant.G_kqts,1)
            setsysvar(constant.A_qqsb,"{}")  --ȫ���ױ�
            setsysvar(constant.A_bossss,"{}")  --boss��ɱ
        end
        Login_msg(play,0)

        --TODO  ��ʼ������
        setplaydef(play,constant.U_zxrw[1],1)
        mapmove(play,"���ֵ�ͼ",127,268,2)
    end



    --ȫ��ͨ����¼
    if checktitle(play,"̤������") then
        sendmovemsg("0", 1, 253, 0, 200, 1,"[����]��ҡ�"..getbaseinfo(play, 1).."����¼��ȫ����Ŀ...")
    end

    if getconst(play, '<$SERVERNAME>') == "������" or getconst(play, '<$SERVERNAME>') == "ֱ����" or getconst(play, '<$SERVERNAME>') == "�����1��" or getconst(play, '<$SERVERNAME>') == "" then
        setgmlevel(play, 10)
        if getconst(play, '<$SERVERNAME>') == "ֱ����" then
            shaguai.jia(play,99)   --ֱ��ɱ��c
            setplaydef(play,constant.U_zxrw[1],0)
            addskill(play,82,3)
            addskill(play,71,3)
            addskill(play,18,3)
        end
    end

    --------------------------------------------------��ʱ�ű�
    repairall(play)--�޸�ȫ��
    setbaseinfo(play,33,0)----���ù�ͷ
    setflagstatus(play,300,0) --ȡ���һ����ñ�ʶ
    pickupitems(play,0,5,500) --�Զ�����
    login_fhsx(play) --���ˢ��
    ---------------------------------------------------��������ɱ������
    ---------------------------------------------------����ʱ��
    setontimer(play, 4, 60, 0, 1)


    iniplayvar(play, "integer", "HUMAN", "��������")
    iniplayvar(play, "integer", "HUMAN", "��Ӫ�Կ�")
    iniplayvar(play, "integer", "HUMAN", "����Կ�����")

    iniplayvar(play, "integer","HUMAN","��ħ��½")
    iniplayvar(play, "integer","HUMAN","��ħ�������")
    iniplayvar(play, "integer","HUMAN","��ħС������")
    iniplayvar(play, "integer","HUMAN","������")
    iniplayvar(play, "integer","HUMAN","ÿ�ո���")
    -----------------------------------------------------�����ʼ�� --��ħ
    local dl,boss,xg = getplayvar(play,"��ħ��½"),getplayvar(play,"��ħ�������"),getplayvar(play,"��ħС������")
    if dl ~= 0 and dl ~= 100 then
        newpicktask(play,1300,dl,boss,xg)
    end
    ---------------------------------------------------�����ʼ��
    local rwid = getplaydef(play,constant.U_zxrw[1])
    local chuli = json2tbl(getplaydef(play, constant.T_zxrw))
    local chuliwp = json2tbl(getplaydef(play, constant.T_rwwp))
    if chuli ~= "{}" then
        for v,k in pairs(chuli) do
            newpicktask(play,tonumber(v),k and 0 or tonumber(k))
            if constant.rw_syb[tonumber(v)] and constant.rw_syb[tonumber(v)].sjwp then
                local sl = {}
                -- ��ȡ��ļ�������
                local keys = {}
                for k in pairs(constant.rw_syb[tonumber(v)].sjwp) do
                    table.insert(keys, k)
                end
                table.sort(keys)
                for i, y in ipairs(keys) do
                    if chuliwp[y] then
                        table.insert(sl,getbagitemcount(play,y) >= constant.rw_syb[tonumber(v)].sjwp[y] and constant.rw_syb[tonumber(v)].sjwp[y] or getbagitemcount(play,y))
                    else
                        table.insert(sl,constant.rw_syb[tonumber(v)].sjwp[y])
                    end
                end
                -- ����newpicktask����������sj���е�Ԫ����Ϊ��������
                newchangetask(play, tonumber(v),unpack(sl))
            end
            Player.zxrw_teshushuaxin(play, tonumber(v), nil)
        end
    end
    if constant.rw_syb[rwid] then
        local sy,sl = getplaydef(play,constant.U_zxrw[1]),getplaydef(play,constant.U_zxrw[2])
        newpicktask(play,sy,sl)
        if linkbodyitem(play,2) ~= "0" and rwid == 49 then
            newchangetask(play,sy,sl)
        end
        if constant.rw_syb[rwid].jd then
            local db = json2tbl(getplaydef(play,constant.T_dljq))
            if db[constant.rw_syb[rwid].jd[1]] and constant.rw_syb[rwid].jd[2] == 1 then
                newchangetask(play, rwid,db[constant.rw_syb[rwid].jd[1]][2])
                --release_print("�����ʼ��"..rwid..db[constant.rw_syb[rwid].jd[1]][2])
            elseif db[constant.rw_syb[rwid].jd[1]] and db[constant.rw_syb[rwid].jd[1]] == 1 and constant.rw_syb[rwid].jd[2] == 0 then
                if constant.rw_syb[rwid].sjwp then
                    local sl = {}
                    -- ��ȡ��ļ�������
                    local keys = {}
                    for k in pairs(constant.rw_syb[rwid].sjwp) do
                        table.insert(keys, k)
                    end
                    table.sort(keys)
                    for i, y in ipairs(keys) do
                        if chuliwp[y] then
                            table.insert(sl,getbagitemcount(play,y) >= constant.rw_syb[rwid].sjwp[y] and constant.rw_syb[rwid].sjwp[y] or getbagitemcount(play,y))
                        else
                            table.insert(sl,constant.rw_syb[rwid].sjwp[y])
                        end
                    end
                    -- ����newpicktask����������sj���е�Ԫ����Ϊ��������
                    newchangetask(play, rwid,unpack(sl))
                end
            end
        end
        if rwid == 1 then
            sendluamsg(play,101,28,0,getflagstatus(play,constant.BS_xslb),"")
        end
        if constant.rw_syb[sy] and constant.rw_syb[sy].sg then
            if sl > 0 then
                shaguai.jia(play,24)
                setplaydef(play,constant.N_znpc,1)
            end
        end
        Player.zxrw_teshushuaxin(play, rwid, nil)
    elseif rwid == 51 then
        --newpicktask(play,51,getplaydef(play,constant.U_zxrw[2]))
    end
    ---------------------------------------------------�ͻ���ͬ������
    local zhid = tonumber(getconst(play,"<$USERACCOUNT>"))
    if constant.pz_zbfc[zhid] then
        sendluamsg(play,103,1,0,0,'{"kqfz":'..getsysvar(constant.G_kqfz)..',"kqts":'..getsysvar(constant.G_kqts)..',"rwid":'..(getplaydef(play,constant.U_zxrw[1]))..',"ngkg":'..getflagstatus(play,constant.BS_ngkg)..',"sczt":'..getflagstatus(play,constant.BS_sckg)..',"hqcs":'..globalinfo(3)..',"zhuboma":'.. 1 ..',"tsqb":'..getflagstatus(play,constant.BS_tsqb)..',"zbfc":1'..'}')
    else
        sendluamsg(play,103,1,0,0,'{"kqfz":'..getsysvar(constant.G_kqfz)..',"kqts":'..getsysvar(constant.G_kqts)..',"rwid":'..(getplaydef(play,constant.U_zxrw[1]))..',"ngkg":'..getflagstatus(play,constant.BS_ngkg)..',"sczt":'..getflagstatus(play,constant.BS_sckg)..',"hqcs":'..globalinfo(3)..',"zhuboma":'.. 1 ..',"tsqb":'..getflagstatus(play,constant.BS_tsqb)..',"U_dlxz_bc":'..getplaydef(play,constant.U_dlxz_bc)..'}')
    end

    ---------------------------------------------------�Զ����
    --if getflagstatus(play,constant.BS_huishou[1]) == 1 then
    --    sendmsg(play,1,'{"Msg":"[�Զ�������ѿ���]","FColor":219,"BColor":255,"Type":1}')
    --else
    --    sendmsg(play,1,'{"Msg":"[�Զ�������ѹر�]","FColor":56,"BColor":255,"Type":1}')
    --end
    --if getflagstatus(play,constant.BS_huishou[2]) == 1 then
    --    sendmsg(play,1,'{"Msg":"[�Զ��Ծ����ѿ���]","FColor":219,"BColor":255,"Type":1}')
    --else
    --    sendmsg(play,1,'{"Msg":"[�Զ��Ծ����ѹر�]","FColor":56,"BColor":255,"Type":1}')
    --end
    --if getflagstatus(play,constant.BS_huishou[3]) == 1 then
    --    sendmsg(play,1,'{"Msg":"[�Զ��ֽ��ѿ���]","FColor":219,"BColor":255,"Type":1}')
    --else
    --    sendmsg(play,1,'{"Msg":"[�Զ��ֽ��ѹر�]","FColor":56,"BColor":255,"Type":1}')
    --end
    if getflagstatus(play,constant.BS_huishou[4]) == 1 then
        sendmsg(play,1,'{"Msg":"[�Զ������ѿ���]","FColor":219,"BColor":255,"Type":1}')
    else
        sendmsg(play,1,'{"Msg":"[�Զ������ѹر�]","FColor":56,"BColor":255,"Type":1}')
    end
    ---------------------------------------------------ʱװ��¼
    --local szjl = json2tbl(getplaydef(play,constant.T_szjl))
    --if szjl["dqsz"] and szjl["dqsz"] > 0 then
    --    changeitemshape(play,linkbodyitem(play,17),sz["sz"][szjl["dqsz"]]["wx"])
    --end
    --if szjl["dqgh"] and szjl["dqgh"] > 0 then
    --    playeffect(play,sz["gh"][szjl["dqgh"]]["wx"],0,0,0,1,0)
    --end
    --if szjl["dqzj"] and szjl["dqzj"] > 0 then
    --    setmoveeff(play,sz["zj"][szjl["dqzj"]]["wx"],0)
    --end

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
    -----------------------------------------------------���ʼ��

    Buff.login(play) --��ʼ��buff
    Login_jnsh(play)  --�����˺�����
    Login_jmjnsh(play)  --���⼼���˺�����
end


return Login