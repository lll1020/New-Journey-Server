function split(str,reps)
    local resultStrList = {}
    string.gsub(str,'[^'..reps..']+',function (w)
        table.insert(resultStrList,w)
    end)
    return resultStrList
end

function Login_msg(play, id, msg, leve)
	id = tonumber(id)
	if id == 0 then -- ���˵�¼��ʾ���
		sendmsgnew(play, 255, 0, '���{��' .. getbaseinfo(play, 1) .. '��/FCOLOR=251}��¼{[' .. getconst(play, '<$SERVERNAME>') .. ']/FCOLOR=250}���������綨������һ��Ѫ���ȷ磡����', 1, 3)
	elseif id == 1 then -- �µ�ͼ��ʾ���
		sendmsg(play, 2, '{"BColor":249,"FColor":255,"Msg":"<outline size=\'1\'><font color=\'#FFFF00\'>����ͼ�򱦡���</font>���<font color=\'#00ff00\'>[' .. getbaseinfo(play, 1) .. ']</font>ǰ����ͼ<font color=\'#00FFFF\'>[' .. getbaseinfo(play, 45) .. ']</font>��ʼ̽��֮�ã�</outline>","Type":1}')
	elseif id == 2 then -- ת���ɹ���ʾ
		sendmsg(play, 2, '{"BColor":249,"FColor":255,"Msg":"<outline size=\'1\'><font color=\'#FFFF00\'>������ת������</font>���<font color=\'#00ff00\'>[' .. getbaseinfo(play, 1) .. ']</font>�ɹ�ת��<font color=\'#00FFFF\'>[' .. msg .. ']</font>��;��ͨ��</outline>","Type":1}')
	elseif id == 3 then -- �ɹ���������ʾ
		sendmsgnew(play, 255, 0, '��֮�������{��' .. getbaseinfo(play, 1) .. '��/FCOLOR=251}�ɹ�����{[��֮��]/FCOLOR=250},��ɱ���˿ɻ�ö��⽱��...', 1, 3)
	elseif id == 4 then -- ����������ʾ
		sendmsgnew(play, 255, 0, 'ǰ��ս���������{��' .. getbaseinfo(play, 1) .. '��/FCOLOR=251}��{��' .. getbaseinfo(msg, 1) .. '��/FCOLOR=250}նɱ���������ڽ��¡�...', 1, 3)
	elseif id == 5 then -- ��ԯ�����и�֮����ʾ
		sendmsg(play, 2, '{"BColor":249,"FColor":255,"Msg":"<outline size=\'1\'><font color=\'#FFFF00\'>��' .. msg .. '��������</font>���<font color=\'#00ff00\'>[' .. getbaseinfo(play, 1) .. ']</font>�ɹ�����<font color=\'#00FFFF\'>[' .. msg .. ']</font>��;��ͨ��</outline>","Type":1}')
	elseif id == 6 then -- ����������ʾ
		sendmsg(play, 2, '{"BColor":249,"FColor":255,"Msg":"<outline size=\'1\'><font color=\'#FFFF00\'>��' .. msg .. '��������</font>���<font color=\'#00ff00\'>[' .. getbaseinfo(play, 1) .. ']</font>�ɹ�<font color=\'#00FFFF\'>[' .. msg .. leve .. '��]</font>��;��ͨ��</outline>","Type":1}')
	elseif id == 7 then -- ��ħϰ����ʽ��ʾ
		sendmsg(play, 2, '{"BColor":249,"FColor":255,"Msg":"<outline size=\'1\'><font color=\'#FFFF00\'>�����졿��</font>���<font color=\'#00ff00\'>[' .. getbaseinfo(play, 1) .. ']</font>�ɹ�����<font color=\'#00FFFF\'>[' ..msg .. '] ���� '..leve.. '��</font>����;��ͨ��</outline>","Type":1}')
	elseif id == 8 then -- ����������ʾ
		sendmsg(play, 2, '{"BColor":249,"FColor":255,"Msg":"<outline size=\'1\'><font color=\'#FFFF00\'>��������������</font>���<font color=\'#00ff00\'>[' .. getbaseinfo(play, 1) .. ']</font>�ɹ���<font color=\'#00FFFF\'>[' .. msg .. ']</font>������<font color=\'#00FFFF\'>[LV.' .. leve .. ']</font>��;��ͨ��</outline>","Type":1}')
	elseif id == 9 then -- �ɷ���������ʾ
		sendmsg(play, 2, '{"BColor":249,"FColor":255,"Msg":"<outline size=\'1\'><font color=\'#FFFF00\'>���ɷ�����������</font>���<font color=\'#00ff00\'>[' .. getbaseinfo(play, 1) .. ']</font>�ɹ���<font color=\'#00FFFF\'>[' .. msg .. ']</font>������<font color=\'#00FFFF\'>[LV.' .. leve .. ']</font>��;��ͨ��</outline>","Type":1}')
	elseif id == 10 then -- ����
        if msg > 0 or leve > 0 then
            sendmsg(play, 2, '{"BColor":249,"FColor":255,"Msg":"<outline size=\'1\'><font color=\'#FFFF00\'>��װ�����ա���</font>���<font color=\'#00ff00\'>[' .. getbaseinfo(play, 1) .. ']</font>�ɹ�����װ��,���<font color=\'#00FFFF\'>[' .. msg .. ']</font>Ԫ����<font color=\'#00FFFF\'>[' .. leve .. ']</font>�����</outline>","Type":1}')
        end
	elseif id == 12 then -- �ɹ������籩��ʾ
		sendmsgnew(play, 255, 0, '�����񱩣����{��' .. getbaseinfo(play, 1) .. '��/FCOLOR=251}�ɹ�����{[������]/FCOLOR=250},��ɱ���˿ɻ�ö��⽱��...', 1, 3)
    elseif id == 13 then -- ����������ʾ
		sendmsgnew(play, 255, 0, 'ǰ��ս�����籩���{��' .. getbaseinfo(play, 1) .. '��/FCOLOR=251}��{��' .. getbaseinfo(msg, 1) .. '��/FCOLOR=250}������ŵ��ڵ�...', 1, 3)
    elseif id == 14 then -- ��Ԩ����������ʾ
        sendmsg(play, 2, '{"BColor":249,"FColor":255,"Msg":"<outline size=\'1\'><font color=\'#FFFF00\'>����Ԩ������������</font>���<font color=\'#00ff00\'>[' .. getbaseinfo(play, 1) .. ']</font>�ɹ�����<font color=\'#00FFFF\'>[' .. msg .. ']</font>��;��ͨ��</outline>","Type":1}')
    elseif id == 15 then -- ʵ�����
        sendmsgnew(play, 255, 0, '���{��' .. getbaseinfo(play, 1) .. '��/FCOLOR=251}ʵ�����{[' .. msg .. ']/FCOLOR=250}��������{[' .. leve .. ']/FCOLOR=250}', 1, 3)
    elseif id == 16 then -- С�տ�
        sendmsgnew(play, 255, 0, '���{��' .. getbaseinfo(play, 1) .. '��/FCOLOR=251}С�տ�{[' .. msg .. ']/FCOLOR=250}���������{[1000]/FCOLOR=250}Ԫ��{[300000]/FCOLOR=250}���{[100000]/FCOLOR=250}', 1, 3)
    elseif id == 17 then -- ���տ�
        sendmsgnew(play, 255, 0, '���{��' .. getbaseinfo(play, 1) .. '��/FCOLOR=251}���տ�{[' .. msg .. ']/FCOLOR=250}���������{[3000]/FCOLOR=250}Ԫ��{[1000000]/FCOLOR=250}���{[300000]/FCOLOR=250}', 1, 3)
    elseif id == 18 then -- ��ֵ
        sendmsgnew(play, 255, 0, '���{��' .. string.sub(getbaseinfo(play, 1), 1, 2) .. '******��/FCOLOR=251}{ͨ����ֵ����˴�������/FCOLOR=250}', 1, 3)
    end
end

local jnsh_data = {"��������","��ɱ����","�����䵶","�һ𽣷�","���ս���","����ն"}
function Login_jnsh(play)
    for i, v in ipairs(VarCfg.N_jnsh) do
        local linshi = getplaydef(play,v)
        if linshi > 0 then
            setmagicpower(play,jnsh_data[i],linshi,1)
        end
    end
end
GameEvent.add(EventCfg.onLogin, Login_jnsh, "Login_jnsh")

local jmjnsh_data = {"�һ𽣷�","���ս���","����ն"}
function Login_jmjnsh(play)
    for i = 1,3 do
        setplaydef(play,VarCfg.N_jmjnsh[i], getbaseinfo(play, 51, 256))
    end
    for i, v in ipairs(VarCfg.N_jmjnsh) do
        local linshi = getplaydef(play,v)
        if linshi > 0 then
            setmagicdefpower(play,jmjnsh_data[i],linshi,1)
        end
    end
end
GameEvent.add(EventCfg.onLogin, Login_jmjnsh, "Login_jmjnsh")


function login_fhsx(play)
    local T_zzsj = json2tbl(getplaydef(play,VarCfg.T_zzsj))
    if T_zzsj.dqzy then
        if T_zzsj.sh and T_zzsj.sh[""..T_zzsj.dqzy] == 1 then
            setranklevelname(play,"%s\\[̤�¡���Ĭ]\\[����".. constant.zzxg.zy[T_zzsj.dqzy].name.."]\\��ɱ��"..getplaydef(play,VarCfg.U_srsl).."��")
        else
            setranklevelname(play,"%s\\[̤�¡���Ĭ]\\["..constant.zzxg.zy[T_zzsj.dqzy].name.."]\\��ɱ��"..getplaydef(play,VarCfg.U_srsl).."��")
        end
    else
        setranklevelname(play,"%s\\[̤�¡���Ĭ]\\��ɱ��"..getplaydef(play,VarCfg.U_srsl).."��")
    end
end
GameEvent.add(EventCfg.onLogin, login_fhsx, "login_fhsx")


-----------------------------���ඨʱ��-------------------------
