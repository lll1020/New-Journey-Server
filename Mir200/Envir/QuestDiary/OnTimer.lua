--ȫ�ֶ�ʱ��

-----------------ȫ��1��60�붨ʱ��----------------
function ontimerex1()
    if getsysvar(VarCfg["G_������֤"]) > 0 and not checkkuafuserver() then
        local dqfz = getsysvar(VarCfg["G_��������"]) + 1
        setsysvar(VarCfg["G_��������"], dqfz)

    end
end



------------------------------------���˶�ʱ��begin---------------------------------
-----------------����1��3�붨ʱ��----------------һֱ����
function ontimer1(play)
    --------------------------------------------------���սű�
    if getbagblank(play) < 20 then -- ���սű�
        Player.huishou(play)
    end
end

-----------------����4�Ŷ�ʱ��----------------60�붨ʱ��
function ontimer4(play)
    local zxsj = getplaydef(play, VarCfg.U_fldt[1])
    setplaydef(play, VarCfg.U_fldt[1], zxsj + 1)
    setplaydef(play, VarCfg.J_zxsj,getplaydef(play, VarCfg.J_zxsj) + 1)
end
-----------------����5�Ŷ�ʱ��----------------1�붨ʱ��AI�һ�����
function ontimer5(play)
    local json = json2tbl(getplaydef(play, VarCfg.T_aigj))
    if json.gjkg then
        if  getbaseinfo(play, 3) ~= "xtc" then
            local hdtsj,sgsj = getplaydef(play, VarCfg.N_Aigj[3]),getplaydef(play, VarCfg.N_Aigj[2])
            if json.zgx3 and os.time() - hdtsj >= 120  then
                ai_qhdt(play)
                setplaydef(play, VarCfg.N_Aigj[2], os.time())
                setplaydef(play, VarCfg.N_Aigj[3], os.time())
            elseif json.zgx2 and  os.time() - sgsj >= 120 then
                if getplaydef(play,"N$ս��״̬") < os.time() and not getbaseinfo(play,0) then
                    map(play, getbaseinfo(play, 3))
                    setplaydef(play, VarCfg.N_Aigj[2], os.time())
                    sendmsg(play, 1, '{"Msg":"<font color=\'#28ef01\'>AI�һ���120���޹��Զ����</font>","Type":9}')
                    startautoattack(play)
                else
                    setplaydef(play, VarCfg.N_Aigj[2], os.time())
                end
            end
        elseif getbaseinfo(play, 3) == "xtc" and json.zgx4 then
            local tcsj = getplaydef(play, VarCfg.N_Aigj[4])
            if tcsj >= 60 then
                ai_qhdt(play)
                setplaydef(play, VarCfg.N_Aigj[4], 0)
            else
                setplaydef(play, VarCfg.N_Aigj[4], tcsj + 1)
            end
        elseif json.zgx5 and os.time() - getplaydef(play, VarCfg.N_Aigj[5]) >= (60*20) then
            ai_qhdt(play)
            setplaydef(play, VarCfg.N_Aigj[5], os.time())
        end
    end
end
-----------------����6�Ŷ�ʱ��---------------���ϵͳ--60s
function ontimer6(play)
    --release_print("���ϵͳ")
    --���ϸ�
    local ists = false
end

-----------------��ʱ��----------------��ճ�ħ  ÿ�����
function ql_smmrrw()

end

-----------------����10�Ŷ�ʱ��----------------������-����
function ontimer10(play)
    local dqlc = getplaydef(play,"N$��ǰ����")
    if dqlc == 0 then
        setplaydef(play,"N$��ǰ����",1)
        mapmove(play,"xtc",137,138,5)
    end
end

------------------------------------���˶�ʱ��end---------------------------------
-----------------��ͼ��ʱ��----------------
function hd_tcppk(xx,ditu)
    if ditu == "xtc" then
        local wanjia = getobjectinmap("xtc",137,138,20,1)
        for k, v in pairs(wanjia) do
            if math.random(2) == 1 then
                local x, y = getbaseinfo(v, 4), getbaseinfo(v, 5)
                if getplaydef(v, "N$�ϴ�����x") ~= x and getplaydef(v, "N$�ϴ�����y") ~= y then
                    setplaydef(v, "N$�ϴ�����x", x)
                    setplaydef(v, "N$�ϴ�����y", y)
                    local wpmz = paokujl[math.random(#paokujl)]
                    sendmsg(v,1,'{"Msg":"<font color=\'#ff7700\'>[�����ܿ�]</font><font color=\'#00ff00\'>��ϲ������['..wpmz..']...</font>","Type":9}')
                    sendmsg(v, 2, '{"BColor":249,"FColor":255,"Msg":"[�����ܿ�]<font color=\'#00ff00\'>��ϲ'..getbaseinfo(v, 1)..'�����['..wpmz..']...</font>","Type":1}')
                    giveitem(v, wpmz,1,getflagstatus(v,VarCfg.BS_mztq) == 0 and 0 or 850)
                end
            end
        end
    end
end
