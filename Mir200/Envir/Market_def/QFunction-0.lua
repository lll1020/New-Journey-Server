--------------------����װ����ͷ--------------------
itemstype = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 55, 71, 72, 73, 74, 75, 76}
--------------------�쳣����--------------------
for k, _ in pairs(package.loaded) do
	if string.find(k, '^Envir/Lua/') then
		release_print(k)
		package.loaded[k] = nil
	end
end

function MainError(errinfo)
	if errinfo then
		release_print('�ű�����', errinfo)
	end
end

local function init()
	dofile('Envir/Lua/Main.lua')
end

local result, errinfo = pcall(init)
if not result then
	MainError(errinfo)
end
local kfttxl = {
    1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100
}


--------------------�����ʼ��--------------------
function startup()
    local qf_ditucanshu = dofile('Envir/Lua/Data/ditulianjie.lua')
    for k, v in pairs(qf_ditucanshu) do
        mapeffect('����' .. k, v[1], v[2], v[3], 10297, 0, 0)
        if v[4] then
            mapeffect('����' .. k, v[1], v[2], v[3], v[4], 0, 0)
        end
    end
    setontimerex(1, 60)
    --setontimerex(2, 1)

    if getmoncount("���ֵ�ͼ",1003,true) < 200 then
        genmon("���ֵ�ͼ",74,80,"����",25,400,255)
    end
    if getmoncount("���ֵ�ͼ",1004,true) < 200 then
        genmon("���ֵ�ͼ",183,174,"ɽ��",25,400,255)
    end
end

--------------------�·��ˢ�ֱ�--------------------
local G_zydk = {0,0}
local A_kfdzdl = {}

--------------------�����ʼ��--------------------
function login(play)
    local quming = getconst(play, '<$SERVERNAME>')
    if callcheckscriptex(play,"ISDUMMY") then
        Login.main(play)
        setontimer(play, 10, 3)
    else
        if getsysvar(constant.G_kqfz) >= 1440 and linkbodyitem(play,71) == "0" then
            --TODO
            if quming ~= "" and quming ~= "������" and quming ~= "ֱ����" and quming ~= "�����1��" then
                if not constant.pz_htqx[tonumber(getconst(play,"<$USERACCOUNT>"))] then
                    messagebox(play,"����24Сʱ���ֹע���ɫ,��ǰ��������չ")
                    kick(play)
                    return
                end
            end
        end
        Login.main(play)
        setontimer(play, 1, 3, 0, 1)
        --���ϵͳ��ʱ��
        setontimer(play,6,60,0,1)
    end
end
--------------------���촥��--------------------
function resetday(play)
	for _, v in pairs(constant.pz_ldql) do
		Player.title_del(play, v)
	end



end
-----------------ȫ��1��60�붨ʱ��----------------
function ontimerex1()
	if getsysvar(constant.G_kqyz) > 0 and not checkkuafuserver() then
		local dqfz = getsysvar(constant.G_kqfz) + 1
		setsysvar(constant.G_kqfz, dqfz)

	end

    if getmoncount("���ɽ��",-1,true) < 100 then genmon("���ɽ��",0,0,"�ѵ�Գ",500,100,250) genmon("���ɽ��",0,0,"���ҹ�",500,100,250) end
end


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
                    giveitem(v, wpmz,1,getflagstatus(v,constant.BS_mztq) == 0 and 0 or 850)
                end
            end
        end
    end
end

-----------------����1��3�붨ʱ��----------------һֱ����
function ontimer1(play)
    --------------------------------------------------���սű�
	if getbagblank(play) < 20 then -- ���սű�
        Player.huishou(play)
	end
end

-----------------����4�Ŷ�ʱ��----------------60�붨ʱ��
function ontimer4(play)
    local zxsj = getplaydef(play, constant.U_fldt[1])
    setplaydef(play, constant.U_fldt[1], zxsj + 1)
    setplaydef(play, constant.J_zxsj,getplaydef(play, constant.J_zxsj) + 1)
end
-----------------����5�Ŷ�ʱ��----------------1�붨ʱ��AI�һ�����
function ontimer5(play)
    local json = json2tbl(getplaydef(play, constant.T_aigj))
    if json.gjkg then
        if  getbaseinfo(play, 3) ~= "xtc" then
            local hdtsj,sgsj = getplaydef(play, constant.N_Aigj[3]),getplaydef(play, constant.N_Aigj[2])
            if json.zgx3 and os.time() - hdtsj >= 120  then
                ai_qhdt(play)
                setplaydef(play, constant.N_Aigj[2], os.time())
                setplaydef(play, constant.N_Aigj[3], os.time())
            elseif json.zgx2 and  os.time() - sgsj >= 120 then
                if getplaydef(play,"N$ս��״̬") < os.time() and not getbaseinfo(play,0) then
                    map(play, getbaseinfo(play, 3))
                    setplaydef(play, constant.N_Aigj[2], os.time())
                    sendmsg(play, 1, '{"Msg":"<font color=\'#28ef01\'>AI�һ���120���޹��Զ����</font>","Type":9}')
                    startautoattack(play)
                else
                    setplaydef(play, constant.N_Aigj[2], os.time())
                end
            end
        elseif getbaseinfo(play, 3) == "xtc" and json.zgx4 then
            local tcsj = getplaydef(play, constant.N_Aigj[4])
            if tcsj >= 60 then
                ai_qhdt(play)
                setplaydef(play, constant.N_Aigj[4], 0)
            else
                setplaydef(play, constant.N_Aigj[4], tcsj + 1)
            end
        elseif json.zgx5 and os.time() - getplaydef(play, constant.N_Aigj[5]) >= (60*20) then
            ai_qhdt(play)
            setplaydef(play, constant.N_Aigj[5], os.time())
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
--------------------���ͽ�ָ����ǰ��������-------------------
function beginteleport(play)
    setplaydef(play,"S$dtm",getbaseinfo(play, 3))
    local lb_json,sj  = json2tbl(getplaydef(play,constant.T_czlb)),os.time()
    local bl = sj - getplaydef(play,"N$���͹���CD")
    if bl < 5 then
        sendmsg(play,1,'{"Msg":"��ȴ�'..(5-bl)..'�����ʹ��","FColor":56,"BColor":255,"Type":1}')
        return false
    end
    local du = getbaseinfo(play, 3)
    if (daluditu[du] and daluditu[du] < 3) or (getplaydef(play,"N$ս��״̬") < os.time()) then
        setplaydef(play,"N$���͹���CD",sj)
        return true
    end
    sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>ս��״̬�޷�ʹ��...</font>","Type":9}')
    return false
end

--------------------AI�һ��Զ��л���ͼ-------------------
function ai_qhdt(play)
	local json, lins = json2tbl(getplaydef(play, constant.T_aigj)), {}
    if json.gjkg then
        if json.zgx4 or json.zgx3 or json.zgx5 then
            for i = 1, 10, 1 do
                if json["fgx" .. i] then
                    table.insert(lins, json["dtid" .. i])
                end
            end
            if #lins > 0 and not getbaseinfo(play,0) then
                map(play, lins[math.random(#lins)])
                delaygoto(play, 500, "ai_ksgj", 0)
                sendmsg(play, 1, '{"Msg":"<font color=\'#28ef01\'>AI�һ������Զ��л���ͼ!</font>","Type":9}')
            end
        end
    end
end

function ai_ksgj(play)
    startautoattack(play)
end
function beforeroute(play)
    if getflagstatus(play,300) == 1 then
        return false
    end
end

--------------------�л���ͼ����-------------------
function entermap(play)
    local dt = getbaseinfo(play,3)
    if getplaydef(play,"S$dtm") ~= dt then
        sendluamsg(play,101,1002,0,0,getmapname(dt))
    end
end
--------------------������Ʒ����-------------------
function checkdropuseitems(play,item_wz,item_id,bool)
    local zb_dx = linkbodyitem(play,item_wz)
    local dt = getbaseinfo(play, 3)
    if dt == "��Ӫ�Կ�" or dt == "�����Ӫ�Կ�" or dt == "��������" then
        return false
    end
    if getitemaddvalue(play,zb_dx,2,1) ~= 0  then
        delitembymakeindex(play,getiteminfo(play,zb_dx,1))
    end
end

--------------------��ɫ�ӵ�������Ʒǰ����-------------------
function dropitemfrontex(play,item,itemName)
    if getitemaddvalue(play,item,2,1) ~= 0  then
        delitembymakeindex(play,getiteminfo(play,item,1))
        return false
    end
end

--------------------ʰȡǰ����-------------------
function pickupitemfrontex(play, item)
    if getflagstatus(play,constant.BS_mztq) == 0 then
        setitemaddvalue(play,item,2,1,850)
    end
end

--------------------����������-------------------
function addbag(play, item)

end

--------------------����Ʒ����-------------------
function pickupitemex(play, item)
    local idx = getiteminfo(play, item, 2)
    local chuli = json2tbl(getplaydef(play, constant.T_rwwp)) --������Ʒ
    local name = getiteminfo(play,item,7)
    if chuli[name] then
        local rwid = chuli[name][1] --����ID\
        if getbagitemcount(play,name) >= chuli[name][2] then
            --rwcf.wpjian(play,name)
            chuli[name] = nil
            if not constant.rw_syb[rwid] then
                messagebox(play,"����������ҵ�,����ǰ��NPC�ύ","@moni_dj_rw,"..rwid,"@exit")
            end
        end

        if constant.rw_syb[rwid] then
            if constant.rw_syb[rwid].ts then
                Player.zxrw_teshushuaxin(play, rwid, nil)
            elseif constant.rw_syb[rwid].cl then
                local sl = {}
                local clwc = true
                local keys = {}
                for k in pairs(constant.rw_syb[rwid].cl) do
                    table.insert(keys, k)
                end
                table.sort(keys)
                for i, v in pairs(keys) do
                    if chuli[v] or getbagitemcount(play,v) < constant.rw_syb[rwid].cl[v] then
                        clwc = false
                    end
                    table.insert(sl, getbagitemcount(play,v) >= constant.rw_syb[rwid].cl[v] and constant.rw_syb[rwid].cl[v] or getbagitemcount(play,v))
                end
                if clwc then
                    messagebox(play,"����������ҵ�,����ǰ��NPC�ύ","@moni_dj_rw,"..rwid,"@exit")
                end
                -- ����newpicktask����������sj���е�Ԫ����Ϊ��������
                newchangetask(play, rwid,unpack(sl))
            elseif constant.rw_syb[rwid].sjwp then
                local sl = {}
                local clwc = true
                local keys = {}
                for k in pairs(constant.rw_syb[rwid].sjwp) do
                    table.insert(keys, k)
                end
                table.sort(keys)
                for i, v in pairs(keys) do
                    if chuli[v] or getbagitemcount(play,v) < constant.rw_syb[rwid].sjwp[v] then
                        clwc = false
                    end
                    table.insert(sl,getbagitemcount(play,v) >= constant.rw_syb[rwid].sjwp[v] and constant.rw_syb[rwid].sjwp[v] or getbagitemcount(play,v))
                end
                -- ����newpicktask����������sj���е�Ԫ����Ϊ��������
                newchangetask(play, rwid,unpack(sl))
                if clwc then
                    if constant.rw_syb[rwid].jwpjc then
                        messagebox(play,"������Ʒ���ҵ��������")
                        Player.zxrw_wancheng(play, rwid, "")
                    else
                        messagebox(play,"����������ҵ�,����ǰ��NPC�ύ","@moni_dj_rw,"..rwid,"@exit")
                    end
                end
            end
        end
    end



	if idx > 10010 and idx < 10019 then    --���鵤
        local sl = getiteminfo(play, item, 5)
        changeexp(play, '+', getstditeminfo(idx, 8) * sl, false)
        delitembymakeindex(play, getiteminfo(play, item, 1), sl)
    elseif idx > 10018 and idx < 10023 then    --Ԫ��
        local sl = getiteminfo(play, item, 5)
        changemoney(play, getflagstatus(play,constant.BS_mztq) == 1 and 1 or 3, '+', getstditeminfo(idx, 8) * sl, '�����Զ���', true)
        delitembymakeindex(play, getiteminfo(play, item, 1), sl)
    elseif idx > 10022 and idx < 10034 then    --���
        local sl = getiteminfo(play, item, 5)
        changemoney(play, getflagstatus(play,constant.BS_mztq) == 1 and 2 or 4, '+', getstditeminfo(idx, 8) * sl, '�����Զ���', true)
        delitembymakeindex(play, getiteminfo(play, item, 1), sl)
    end
    --����������
    setpickitemtobag(play,"200","101")
end
--------------------����ǰ����-------------------
function takeonbeforeex(play,item,where,makeIndex)
    if where == 22 then
        if getiteminfo(play,item,2) > 21043 then
            callscriptex(play,"TAKEONMAKEINDEX",23,makeIndex)
            return false
        end
    elseif where == 24 then
        if getiteminfo(play,item,2) > 21043 then
            callscriptex(play,"TAKEONMAKEINDEX",25,makeIndex)
            return false
        end
    end
    return true
end
--------------------����װ����-------------------idxΪ��װID
function groupitemonex(play,idx)

end
--------------------����װ����-------------------
function groupitemoffex(play,idx)

end
--------------------�����󴥷�-------------------
function takeonex(play, item, where, Name, makeindex)
	Buff.chuan(play, item)
    if where == 14 then
        changemoney(play,16,"=",1,"��¼����",true)
    end
end
--------------------���º󴥷�-------------------
function takeoffex(play, item, where, Name, makeindex)
	Buff.tuo(play, item)
    if where == 14 then
        changemoney(play,16,"=",0,"��¼����",true)
    end
end


--------------------����ǰ����-------------------
function attackdamage(play, Target, Hiter, MagicId, Damage,Model)
	if getbaseinfo(Target, -1) then
		local bl = getplaydef(play, constant.S_buffgjq)
		local data = json2tbl(bl == '' and {} or bl)
		local ew = 0
		for k, v in pairs(data) do
			local sy = tonumber(k)
			if sy and Buff[sy] then
				ew = ew + (Buff[sy](play, 3, Damage, Target, MagicId,Model) or 0)
			end
		end
		bl = getplaydef(play, constant.S_buffrwq)
		data = json2tbl(bl == '' and {} or bl)
		for k, v in pairs(data) do
			local sy = tonumber(k)
			if sy and Buff[sy] then
				ew = ew + (Buff[sy](play, 3, Damage, Target, MagicId) or 0)
			end
		end
		if ew > 0 then
			humanhp(Target, '-', ew, 107, 0, play, 1)
		end
        local play_dfdj = getbaseinfo(play, 51, 252)
        local Target_dfdj = getbaseinfo(Target, 51, 252)
        if play_dfdj > Target_dfdj then
            --���������Է��۷�ȼ���ֵ*10%���˺�
            local dfdj_damage = math.floor(Damage * ((play_dfdj - Target_dfdj) / 10) / 100)
            if dfdj_damage > 0 then
                Damage = Damage + dfdj_damage
            end
        end
        if hasbuff(play, 20152) then
            return Damage + Damage
        end
		return Damage
	else
        local js = getbaseinfo(Target, 18)
        if js > 0 then
            Damage = Damage - (Damage * js/10000)
        end


        ---------------------------------------------�Թ��и����
		local zd = getbaseinfo(Target, 12)
		local sy = -1
		if zd == 0 then
			local zhi = getbaseinfo(play, 51, 244)
			if zhi > 0 then
				humanhp(Target, '-', zhi, math.random(100) > 10 and 101 or 112, 0, play, 1)
			end
			zhi = getbaseinfo(play, 51, 245)
			if zhi > 0 then
				humanhp(Target, '-', Damage / 10000 * zhi, 102, 0, play, 1)
			end
		else
			if zd > Damage then
				sy = zd - Damage
				local qie = getbaseinfo(play, 51, 244) * (1 + getbaseinfo(play,51,253)/ 10000)
				if sy > qie then
                    if qie > 0 then
                        sy = sy - qie
                        local qiebjjl = getbaseinfo(play, 51, 250)
                        if math.random(100) <= qiebjjl then
                            humanhp(Target, '-', math.floor(qie * (getbaseinfo(play, 51, 251)/100 + 1)), 101, 0, play, 1)
                        else
                            humanhp(Target, '-', qie, math.random(100) > 10 and 101 or 112, 0, play, 1)
                        end
                    end
					local zeng = Damage / 10000 * getbaseinfo(play, 51, 245)
					if zeng > 0 then
						if sy > zeng then
							sy = sy - zeng
							humanhp(Target, '-', zeng, 102, 0, play, 1)
                            --sendmsg(play,1,'{"Msg":"����˺�'..Damage..',�и�'..qie..',����'..zeng..'","FColor":56,"BColor":255,"Type":1}')
						else
							humanhp(Target, '-', sy, 102, 0, play, 1)
                            --sendmsg(play,1,'{"Msg":"����˺�'..Damage..',�и�'..qie..',����'..sy..'����","FColor":56,"BColor":255,"Type":1}')
							return Damage
						end
					end
				else
					humanhp(Target, '-', sy, math.random(100) > 10 and 101 or 112, 0, play, 1)
                    --sendmsg(play,1,'{"Msg":"����˺�'..Damage..',�и�'..sy..',������","FColor":56,"BColor":255,"Type":1}')
					return Damage
				end
			else
                --sendmsg(play,1,'{"Msg":"����˺�'..Damage..'����'..zd..',������","FColor":56,"BColor":255,"Type":1}')
				return zd
			end
		end
        ---------------------------------------------ͨ�ù���ǰ����ģ�飬����Ч
		local bl = getplaydef(play, constant.S_buffgjq)
		local data = json2tbl(bl == '' and {} or bl)
		local buffsh = 0
		for k, v in pairs(data) do
			local isy = tonumber(k)
			if isy then
				local ew = Buff[isy](play, 3, Damage, Target, MagicId)
				if ew and ew > 0 then
					if sy == -1 then
						buffsh = buffsh + ew
					elseif sy > ew then
						sy = sy - ew
						buffsh = buffsh + ew
					else
						humanhp(Target, '-', sy, 107, 0, play, 1)
						return Damage
					end
				end
			end
		end
		bl = getplaydef(play, constant.S_buffgwq)
		data = json2tbl(bl == '' and {} or bl)
		for k, v in pairs(data) do
			local isy = tonumber(k)
			if isy then
				local ew = Buff[isy](play, 3, Damage, Target, MagicId)
				if ew and ew > 0 then
					if sy == -1 then
						buffsh = buffsh + ew
					elseif sy > ew then
						sy = sy - ew
						buffsh = buffsh + ew
					else
						humanhp(Target, '-', sy, 107, 0, play, 1)
						return Damage
					end
				end
			end
		end
		if buffsh > 0 then
			humanhp(Target, '-', buffsh, 107, 0, play, 1)
		end
        if hasbuff(play, 20152) then
            return Damage + Damage
        end
		return Damage
	end
end
--------------------�����󴥷�-------------------
function attack(play, Target, Hiter, MagicId)
    local gs
	if getbaseinfo(Target, -1) then
		gs = math.floor(getbaseinfo(play, 51, 201) / 100)
	else
		gs = math.floor(getbaseinfo(play, 51, 200) / 100)
	end
	if getplaydef(play, constant.N_dqgs) ~= gs then
		local sj = os.time()
		if sj - getplaydef(play, constant.N_gscd) > 0 then
			setplaydef(play, constant.N_gscd, sj)
			setplaydef(play, constant.N_dqgs, gs)
			callscriptex(play, 'changespeedex', 2, gs)
			sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>��ǰ�����ٶ�+' .. gs .. '%</font>","Type":9}')
		end
	end
	local bl = getplaydef(play, constant.S_buffgjh)
	local data = json2tbl(bl == '' and {} or bl)
	for k, v in pairs(data) do
		local sy = tonumber(k)
		if sy then
			Buff[sy](play, 3, 0, Target, MagicId)
		end
	end
	if getbaseinfo(Target, -1) then
		bl = getplaydef(play, constant.S_buffrwh)
		data = json2tbl(bl == '' and {} or bl)
		for k, v in pairs(data) do
			local sy = tonumber(k)
			if sy then
				Buff[sy](play, 3, 0, Target, MagicId)
			end
		end
        setplaydef(play,"N$ս��״̬",os.time()+3)
	else
        bl = getplaydef(play, constant.S_buffgwh)
        data = json2tbl(bl == '' and {} or bl)
        for k, v in pairs(data) do
            local sy = tonumber(k)
            if sy and Buff[sy] then
                Buff[sy](play, 3, 0, Target, MagicId)
            end
        end
        --setplaydef(play,"N$ս��״̬",os.time() + 1)
        local xi = getbaseinfo(play, 51, 248)
        if xi > 0 then
            humanhp(play,"+",xi)
        end
	end
    local xi = getbaseinfo(play, 51, 249)
    if xi > 0 then
        humanhp(play,"+",xi)
    end
end

--------------------������ǰ����-------------------
function struckdamage(play, Hiter, Target, MagicId, Damage)
	if hasbuff(play, 20033) and MagicId > 0 then
		return 0
	end
	local bl = getplaydef(play, constant.S_buffbgjq)
	local data = json2tbl(bl == '' and {} or bl)
	local ew = 0
	for k, v in pairs(data) do
		local sy = tonumber(k)
		if sy then
			ew = ew + (Buff[sy](play, 3, Damage, Hiter, MagicId) or 0)
		end
	end

    if getbaseinfo(Hiter, -1) then
		bl = getplaydef(play, constant.S_buffbrwq)
		data = json2tbl(bl == '' and {} or bl)
		for k, v in pairs(data) do
			local sy = tonumber(k)
			if sy then
				ew = ew + Buff[sy](play, 3, Damage, Hiter, MagicId)
			end
		end
        local play_dfdj = getbaseinfo(play, 51, 252)
        local Target_dfdj = getbaseinfo(Target, 51, 252)
        if play_dfdj > Target_dfdj then
            --�յ��˺�������Է��۷�ȼ���ֵ*10%
            local dfdj_damage = math.floor(Damage * ((play_dfdj - Target_dfdj) / 10) / 100)
            if dfdj_damage > 0 then
                Damage = Damage - dfdj_damage
            end
        end
	else
		bl = getplaydef(play, constant.S_buffbgwq)
		data = json2tbl(bl == '' and {} or bl)
		for k, v in pairs(data) do
			local sy = tonumber(k)
			if sy then
				ew = ew + Buff[sy](play, 3, Damage, Hiter, MagicId)
			end
		end
        local gd = getbaseinfo(play, 51, 255)
        if gd > 0 then
            ew = ew - gd
        end
	end
    if ew > 0 then
        ew = -ew
    end

	local xi = getbaseinfo(play, 51, 206)
	if xi > 0 then
		xi = Damage / 10000 * xi
		sendattackeff(play, 108, xi, "*")
		xi = -xi
	end
    if hasbuff(play,20111) and (Damage + ew + xi) > 10000 then
        return 10000
    end
    if Damage + ew + xi > 0 then
        return Damage + ew + xi
    else
        return 1
    end
end
--------------------�������󴥷�-------------------
function struck(play, Hiter, Target, MagicId)
    if getbaseinfo(Hiter, -1) then
        setplaydef(play,"N$ս��״̬",os.time()+3)
    end
end
--------------------��Ŀ��ʹ�ü��ܴ���-------------------Ұ��
function magtagfunc27(play, Target)

end
--------------------��Ŀ��ʹ�ü��ܴ���-------------------����
function magtagfunc66(play, Target)
end
--------------------��Ŀ��ʹ�ü��ܴ���-------------------ʮ��һɱ
function magselffunc82(play)

end
--------------------��Ŀ��ʹ�ü��ܴ���-------------------ʩ����
function magtagfunc6(play, Target)

end
--------------------��Ŀ��ʹ�ü��ܴ���-------------------������
function magselffunc18(play, Target)
end

function magselffunc26(play) ---�һ�

end
function magselffunc66(play) ---����

end
function magselffunc56(play) ---����

end

--------------------ɱ�ִ���-------------------
function killmon(play, mob)
    local bl = getplaydef(play, constant.S_buffsgcf)
	local data = json2tbl(bl == "" and {} or bl)
	for k, v in pairs(data) do
		local sy = tonumber(k)
		if sy then
			Buff[sy](play, 3, mob)
		end
	end
	bl = getplaydef(play, constant.T_sgcf)
	data = json2tbl(bl == "" and {} or bl)
	for k, v in pairs(data) do
        if shaguai[k] then
            shaguai[k](play, mob)
        end
	end
    ---ÿ��ɱ������
    local gw_name = getbaseinfo(mob,1)
    if guaiwutype[gw_name] and guaiwutype[gw_name] >= 1 then
        setplaydef(play,constant.J_jsgw[1],getplaydef(play,constant.J_jsgw[1])+1)
    else
        setplaydef(play,constant.J_jsgw[2],getplaydef(play,constant.J_jsgw[2])+1)
    end


    local dt = getbaseinfo(play, 3)
    if dt ~= "xtc" then
        local mz = getbaseinfo(mob, 1, 1)
        if guaiwutype[mz] and daluditu[dt] then
            local bianshi = getbaseinfo(play, 51, 207)
            if bianshi > 0 then
                if math.random(20000) <= bianshi then
                    sendmsg(play,1,'{"Msg":"<font color=\'#00ff00\'>[��ʬ]</font>������ʬ['..mz..']","FColor":253,"BColor":255,"Type":9}')
                    local guaiwu = genmonex(getbaseinfo(play, 3), getbaseinfo(play, 4), getbaseinfo(play, 5), mz, 1, 1, play, 254, mz .. "[��ʬ]", 0)
                    for _, v in pairs(guaiwu) do
                        humanhp(v, "=", 1)
                    end
                end
            end
        end
    end
end


--------------------���Ҹı䴥��-------------------Ԫ��
function moneychange1(play)
    local gb = getplaydef(play,"N$Ԫ���ı䴥��")
    if gb > 0 and Buff[gb] then
        Buff[gb](play, 1)
    end
end
--------------------���Ҹı䴥��-------------------���
function moneychange2(play)
    local gb = getplaydef(play,"N$����ı䴥��")
    if gb > 0 and Buff[gb] then
        Buff[gb](play, 1)
    end
end

--------------------���Ҹı䴥��-------------------����
function moneychange15(play)
    if querymoney(play,16) > 0 and not hasbuff(play,20060) then
        changemode(play,23,999999999,querymoney(play,15)+1)
    else
        changemode(play,23,999999999,querymoney(play,15))
    end
end

function moneychange16(play)
    if querymoney(play,16) > 0 and not hasbuff(play,20060) then
        changemode(play,23,999999999,querymoney(play,15)+1)
    else
        changemode(play,23,999999999,querymoney(play,15))
    end
end
--------------------����ǰ�����-------------------
function nextdie(play)
end
--------------------����󸴻��-------------------
function revival(play)
	local bl = getplaydef(play, constant.S_bufffuhuo)
	local data = json2tbl(bl == '' and {} or bl)
	for k, v in pairs(data) do
		local sy = tonumber(k)
		if sy then
			Buff[sy](play, 4)
		end
	end
    if querymoney(play,15) > 0 then
        changemoney(play,15,"-",1,"����",true)
        if not hasbuff(play,20078) then
            addbuff(play,20078,180)
        end
    else
        addbuff(play,20060,getbaseinfo(play,44))
    end
end
--------------------ɱ����Ҵ���-------------------
function killplay(play,hiter)
    setplaydef(play,constant.U_srsl,getplaydef(play,constant.U_srsl)+1)
    login_fhsx(play)
end
--------------------�����������-------------------
function playdie(play, hiter)
    local dt,x,y = getbaseinfo(play,3),getbaseinfo(play,4),getbaseinfo(play,5)
    sendmail("#" .. getbaseinfo(play, 1), 1, "ϵͳ��ʾ", "����["..getbaseinfo(hiter, 1).."]��"..getbaseinfo(play,45).."("..x.."."..y..")ɱ����...")
    setplaydef(play,constant.U_bssl,getplaydef(play,constant.U_bssl)+1)
    if not castleinfo(5) and dt ~= "������" and getbaseinfo(hiter,-1) and dt ~= "��������" and dt ~= "��Ӫ�Կ�" and not checkkuafu(play) then
        local U_dkb = getplaydef(play,constant.U_dkb)
        if U_dkb > 0 then
            U_dkb = U_dkb - 1
            setplaydef(play,constant.U_dkb,U_dkb)
            if U_dkb < 1 then
                Player.title_del(play, '������')
                Buff[26](play, 2)
                seticon(play, 0, -1)
            end
            Login_msg(play, 4, hiter)
            changemoney(hiter, 3, '+', 1880000, '��ɱ��', true)
        end
        if (checktitle(play,"��֮��") or checktitle(play,"��֮��[����]")) and (checktitle(hiter,"��֮��") or checktitle(hiter,"��֮��[����]")) then
            if checktitle(play,"��֮��") then
                Player.title_del(play, '��֮��')
                changemoney(hiter, 7, '+', 688, '��ɱ��', true)
            else
                Player.title_del(play, "��֮��[����]")
            end
            seticon(play, 0, -1)
            Login_msg(play, 4, hiter)
        end
    end

    if getbaseinfo(hiter,-1) then
        local cs = getplaydef(hiter,constant.U_jskb) + 1
        setplaydef(hiter,constant.U_jskb,cs)
    end
    say(play,[[<Img|id=ui_1|x=0|y=0|width=500|height=300|img=wy\public\fuhuo_bj.png|bg=1|move=1|reset=1|show=4|loadDelay=1>
                            <Text|id=ui_6|a=4|x=264|y=84|color=255|size=18|text=�㱻��]]..getconst(play,"<$CURRRTARGETNAME>")..[[��ɱ���ˣ��Ƿ�Ҫ���>
                            <Button|id=ui_8|x=69|y=226|width=145|height=40|nimg=wy\public\fuhuo_1.png|color=251|size=16|link=@yc_fuhuo_hc>
                            <Button|id=ui_9|x=298|y=226|width=145|height=40|nimg=wy\public\fuhuo_2.png|color=251|size=16|link=@yc_fuhuo_yd>
                            <Text|id=ui_12|x=384|y=175|color=250|size=16|text=(ʣ��]]..(getbagitemcount(play,"���"))..[[ö)>
                            <COUNTDOWN|id=ui_14|a=0|x=168|y=176|time=30|color=249|size=18|count=1|link=@yc_fuhuo_hc>
                            ]])

end
--------------------��ת�سǸ���-------------------
function yc_fuhuo_hc(play)
    mapmove(play, 'xtc', 137,138,8)
    realive(play)
    addhpper(play, '=', 100)
    addmpper(play, '=', 100)
    delaygoto(play, 2000, "ai_qhdt", 0)
end
--------------------���ԭ�ظ���-------------------
function yc_fuhuo_yd(play)
    local cs = getplaydef(play, constant.J_mrfhw)
    if checkkuafu(play) then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>�����ͼ����ʹ�ø��!</font>","Type":9}')
        return
    end
    if string.find(getbaseinfo(play,3),"_") then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>������ͼ����ʹ�ø��!</font>","Type":9}')
        return
    end
    if cs > 100 then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>����ʹ�ø������������!</font>","Type":9}')
    else
        if getbagitemcount(play,"���") > 0 then
            takeitem(play,"���",1)
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>�����Ч��ԭ�ظ���!</font>","Type":9}')
            realive(play)
            addhpper(play, '=', 100)
            addmpper(play, '=', 100)
            close(play)
        else
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>�㱳����û�и��!</font>","Type":9}')
        end
    end
end
--------------------��תԭ�ظ���-------------------
function yc_fuhuo_mx(play)
	realive(play)
	addhpper(play, '=', 100)
	addmpper(play, '=', 100)
end

--------------------������������-------------------
function playlevelup(play)
    if getbaseinfo(play, 6) == 150 then
        sendluamsg(play, 101, 0, 17, 1,"")
    end
end

--------------------���Ըı䴥��-------------------
function sendability(play)
    local sd = math.floor(getbaseinfo(play,51,243) / 4)
    if getplaydef(play,"N$�ƶ��ٶȼӳ�") ~= sd then
        setplaydef(play,"N$�ƶ��ٶȼӳ�",sd)
        callscriptex(play, 'changespeedex', 1, sd)
    end
    Player.updata_zdl(play)
end
--------------------���ʼ�������-------------------���鵤
function bl_zyjhl1(play)
    return true
end
--------------------���ʼ�������-------------------���˱���
function bl_zyjhl2(play,mingzi)
    local sj = json2tbl(getplaydef(play,constant.T_xybl))
    if sj and not sj[mingzi] then
        sj[mingzi] = 1
        setplaydef(play,constant.T_xybl,tbl2json(sj))
        return true
    end
    return false
end


--------------------���ʼ�������-------------------ʵ����յ���
function bl_zyjhl5(play,mingzi)
    if globalinfo(3) > 1 and daluditu[getbaseinfo(play,3)] and (daluditu[getbaseinfo(play,3)] < 3 and math.random(100) < 25) then
        return false
    end
    return true
end

local czlb_je = {18,38,68,128,288,588,888,1188,1588,1888}
--------------------�����ָı䴥��-------------------���߳�ֵ���ɸѡ
function moneychange22(play)
    local lb_json,hbsl,jezz = json2tbl(getplaydef(play, constant.T_czlb)),querymoney(play,22),0
    for i = 1, 10, 1 do
        if not lb_json["cz"..i] then
            if jezz + czlb_je[i] <= hbsl then
                jezz = jezz + czlb_je[i]
                lb_json["cz" .. i] = true
                setplaydef(play, constant.T_czlb, tbl2json(lb_json))
                setplaydef(play,constant.N_lbyz,1)
                czlb_pz(play,i)
            else
                break
            end
        end
    end
    if jezz > 0 then
        changemoney(play,22,"-",jezz,"�������",true)
    end
end

function czlb_pz(play,sy)
    sy = tonumber(sy)
    local lb_json = json2tbl(getplaydef(play, constant.T_czlb))
    if getplaydef(play,constant.N_lbyz) == 1 then
        setplaydef(play,constant.N_lbyz,0)
        if sy == 1 then
            setflagstatus(play,constant.BS_18cz,1)
            sendmail(getbaseinfo(play, 2), 0, "���߳�ֵ", "��ϲ��ɹ����18Ԫ��ֵ�������뼰ʱ��ȡ����",Player.jl_mail(teshudata[502].jl[sy].jl))
            if teshudata[502].jl[sy].ch then Player.title_give(play, teshudata[502].jl[sy].ch) end
        elseif sy == 2 then
            sendmail(getbaseinfo(play, 2), 0, "���߳�ֵ", "��ϲ��ɹ����38Ԫ��ֵ�������뼰ʱ��ȡ����",Player.jl_mail(teshudata[502].jl[sy].jl))
            if teshudata[502].jl[sy].ch then Player.title_give(play, teshudata[502].jl[sy].ch) end
        elseif sy == 3 then
            sendmail(getbaseinfo(play, 2), 0, "���߳�ֵ", "��ϲ��ɹ����68Ԫ��ֵ�������뼰ʱ��ȡ����",Player.jl_mail(teshudata[502].jl[sy].jl))
            setflagstatus(play,constant.BS_mztq,1)
            local T_bbsq = json2tbl(getplaydef(play,constant.T_bbsq))
            T_bbsq[teshudata[502].jl[sy].bbsq] = 1
            setplaydef(play,constant.T_bbsq,tbl2json(T_bbsq))

            if bbsq[teshudata[502].jl[sy].bbsq].attr then
                Player.updateSomeAddr(play,nil,bbsq[teshudata[502].jl[sy].bbsq].attr)
            end
            if bbsq[teshudata[502].jl[sy].bbsq].buff then
                Buff[bbsq[teshudata[502].jl[sy].bbsq].buff](play,1)
            end
            sendmsg(play, 1, '{"Msg":"<font color=\'#00FF00\'>��ñ���������'..teshudata[502].jl[sy].bbsq..'�����ڡ�����-��������������鿴</font>","Type":9}')
        elseif sy == 4 then
            sendmail(getbaseinfo(play, 2), 0, "���߳�ֵ", "��ϲ��ɹ����128Ԫ��ֵ�������뼰ʱ��ȡ����",Player.jl_mail(teshudata[502].jl[sy].jl))
            Buff[94](play,1)
            lb_json.jskg = true
            setplaydef(play, constant.T_czlb, tbl2json(lb_json))
            local T_bbsq = json2tbl(getplaydef(play,constant.T_bbsq))
            T_bbsq[teshudata[502].jl[sy].bbsq] = 1
            setplaydef(play,constant.T_bbsq,tbl2json(T_bbsq))

            if bbsq[teshudata[502].jl[sy].bbsq].attr then
                Player.updateSomeAddr(play,nil,bbsq[teshudata[502].jl[sy].bbsq].attr)
            end
            if bbsq[teshudata[502].jl[sy].bbsq].buff then
                Buff[bbsq[teshudata[502].jl[sy].bbsq].buff](play,1)
            end
            setflagstatus(play,constant.BS_bossjd,1)

            sendmsg(play, 1, '{"Msg":"<font color=\'#00FF00\'>��ñ���������'..teshudata[502].jl[sy].bbsq..'�����ڡ�����-��������������鿴</font>","Type":9}')
        elseif sy == 5 then
            sendmail(getbaseinfo(play, 2), 0, "���߳�ֵ", "��ϲ��ɹ����288Ԫ��ֵ�������뼰ʱ��ȡ����",Player.jl_mail(teshudata[502].jl[sy].jl))
            local T_fb = json2tbl(getplaydef(play,constant.T_fb))
            T_fb[teshudata[502].jl[sy].fb] = 1
            setplaydef(play,constant.T_fb,tbl2json(T_fb))

            Player.updateSomeAddr(play, nil, fb[teshudata[502].jl[sy].fb].attr, 1)
            if fb[teshudata[502].jl[sy].fb].buff then
                Buff[fb[teshudata[502].jl[sy].fb].buff](play,1)
            end
            sendmsg(play, 1, '{"Msg":"<font color=\'#00FF00\'>��ý�����'..teshudata[502].jl[sy].fb..'�����ڡ�����-����������鿴</font>","Type":9}')
        elseif sy == 6 then
            sendmail(getbaseinfo(play, 2), 0, "���߳�ֵ", "��ϲ��ɹ����588Ԫ��ֵ�������뼰ʱ��ȡ����",Player.jl_mail(teshudata[502].jl[sy].jl))
            local sj = json2tbl(getplaydef(play,constant.T_szjl))
            sj["zj"] = sj["zj"] or {}
            sj["zj"][""..4] = 1
            setplaydef(play,constant.T_szjl,tbl2json(sj))
            Player.updateSomeAddr(play, nil, sz.zj[4].attr, 1)
            Buff[20195](play,1)
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff7700\'>[���߳�ֵ]</font><font color=\'#28ef01\'>����㼣���������ˡ����ˡ������л�</font>","Type":9}')
        elseif sy == 7 then
            sendmail(getbaseinfo(play, 2), 0, "���߳�ֵ", "��ϲ��ɹ����888Ԫ��ֵ�������뼰ʱ��ȡ����",Player.jl_mail(teshudata[502].jl[sy].jl))
            if teshudata[502].jl[sy].ch then Player.title_give(play, teshudata[502].jl[sy].ch) end
        elseif sy == 8 then
            sendmail(getbaseinfo(play, 2), 0, "���߳�ֵ", "��ϲ��ɹ����1188Ԫ��ֵ�������뼰ʱ��ȡ����",Player.jl_mail(teshudata[502].jl[sy].jl))
            local T_fb = json2tbl(getplaydef(play,constant.T_fb))
            T_fb[teshudata[502].jl[sy].fb] = 1
            setplaydef(play,constant.T_fb,tbl2json(T_fb))

            Player.updateSomeAddr(play, nil, fb[teshudata[502].jl[sy].fb].attr, 1)
            if fb[teshudata[502].jl[sy].fb].buff then
                Buff[fb[teshudata[502].jl[sy].fb].buff](play,1)
            end
        elseif sy == 9 then
            sendmail(getbaseinfo(play, 2), 0, "���߳�ֵ", "��ϲ��ɹ����1588Ԫ��ֵ�������뼰ʱ��ȡ����",Player.jl_mail(teshudata[502].jl[sy].jl))
            local T_bbsq = json2tbl(getplaydef(play,constant.T_bbsq))
            T_bbsq[teshudata[502].jl[sy].bbsq] = 1
            setplaydef(play,constant.T_bbsq,tbl2json(T_bbsq))

            if bbsq[teshudata[502].jl[sy].bbsq].attr then
                Player.updateSomeAddr(play,nil,bbsq[teshudata[502].jl[sy].bbsq].attr)
            end
            if bbsq[teshudata[502].jl[sy].bbsq].buff then
                Buff[bbsq[teshudata[502].jl[sy].bbsq].buff](play,1)
            end
            sendmsg(play, 1, '{"Msg":"<font color=\'#00FF00\'>��ñ���������'..teshudata[502].jl[sy].bbsq..'�����ڡ�����-��������������鿴</font>","Type":9}')
        elseif sy == 10 then
            sendmail(getbaseinfo(play, 2), 0, "���߳�ֵ", "��ϲ��ɹ����1888Ԫ��ֵ�������뼰ʱ��ȡ����",Player.jl_mail(teshudata[502].jl[sy].jl))
            if teshudata[502].jl[sy].ch then Player.title_give(play, teshudata[502].jl[sy].ch) end
        end
        if lb_json["cz1"] and lb_json["cz2"] and lb_json["cz3"] and lb_json["cz4"] and lb_json["cz5"] and lb_json["cz6"] then
            local sj = json2tbl(getplaydef(play,constant.T_szjl))
            sj["sz"] = sj["sz"] or {}
            if not lb_json.yijd then
                sj["sz"][""..7] = 1
                lb_json.yijd = true
                setplaydef(play, constant.T_czlb, tbl2json(lb_json))
                sendmail(getbaseinfo(play, 2), 0, "���߳�ֵ", "��ϲ��ɹ���ó�ֵ�������뼰ʱ��ȡ����",Player.jl_mail({wp = {{"��֮����",100}}}))
                setplaydef(play,constant.T_szjl,tbl2json(sj))
                sendmsg(play, 1, '{"Msg":"<font color=\'#ff7700\'>[���߳�ֵ]</font><font color=\'#28ef01\'>���ʱװ���������ˡ����ˡ������л�</font>","Type":9}')
            end
            if lb_json["cz7"] and lb_json["cz8"] and lb_json["cz9"] and lb_json["cz10"] and not lb_json.erjd then
                sendmail(getbaseinfo(play, 2), 0, "���߳�ֵ", "ȫ����������","��ͼ��ҵһЦ��#1#850&��ʤ����һ����#1#850")
                lb_json.erjd = true
                setplaydef(play, constant.T_czlb, tbl2json(lb_json))
            end
        end
    end
end


--------------------�ۼƳ�ֵ�ı䴥��-------------------�����ƺ�
function moneychange23(play)
    if querymoney(play,23) >= 998 and not checktitle(play,"̤������") then
        messagebox(play,"�ۼƳ�ֵ�����Ѵﵽ,����ȥ��ȡ����������")
    end
end


--------------------��ֵ����-------------------
function recharge(play, Gold, ProductId, MoneyId, isReal)
    release_print("��ֵ����","��ң�"..getbaseinfo(play,1), "��"..Gold, "����:"..ProductId, "����id:"..MoneyId, "�Ƿ����:"..(isReal and "��" or "��"))

    local T_tsg = json2tbl(getplaydef(play,constant.T_tsg))
    T_tsg["j_cz"] = (T_tsg["j_cz"] or 0) + Gold
    setplaydef(play,constant.T_tsg,tbl2json(T_tsg))

    if MoneyId == 7 then   ---�����ֵ
        local lb_json, sy = getplaydef(play, constant.T_czlb), constant.cz_jeyz[Gold]
        lb_json = lb_json == "" and {} or json2tbl(lb_json)
        if constant.cz_jeyz[Gold] and getplaydef(play, constant.U_czyz) == constant.cz_jeyz[Gold] and not lb_json["cz" .. sy] then
            setplaydef(play, constant.U_czyz, 0)
            if not lb_json["cz" .. sy] then
                lb_json["cz" .. sy] = true
                setplaydef(play,constant.T_czlb, tbl2json(lb_json))
                setplaydef(play,constant.N_lbyz,1)
                czlb_pz(play,sy)
            end
        else
            changemoney(play,22,"+",Gold,"������",true)
        end
        changemoney(play,20,"+",Gold,"ƽ̨�ۼƳ�ֵ",true)
        changemoney(play,8,"+",Gold*100,"��ֵ��һ��",true)
        changemoney(play,23,"+",Gold,"�ۼƳ�ֵ",true)
        setplaydef(play,constant.J_zscz,(getplaydef(play,constant.J_zscz) or 0) + Gold)

        Login_msg(play,18,Gold,Gold*200)

        if getflagstatus(play,constant.BS_sckg) == 0 and querymoney(play,20) >= 10 then
            sendluamsg(play, 101, 501, 0, 0,getflagstatus(play,constant.BS_sckg))
        end


    elseif MoneyId == 21 then  --ֱ�����
        setplaydef(play,constant.J_zscz,(getplaydef(play,constant.J_zscz) or 0) + Gold)
        changemoney(play,23,"+",Gold,"ƽ̨�ۼƳ�ֵ",true)
        if Gold == 98 then -- ÿ�����
            local J_mrlb = getplaydef(play,constant.J_mrlb)
            if J_mrlb < 1 then
                J_mrlb = J_mrlb + 1
                setplaydef(play,constant.J_mrlb,J_mrlb)

                local T_bbsq = json2tbl(getplaydef(play,constant.T_bbsq))
                if T_bbsq["һ���ħ"] then
                    if T_bbsq["һ���ħ"] < 30 then
                        T_bbsq["һ���ħ"] = T_bbsq["һ���ħ"] + 1
                        Player.updateSomeAddr(play,nil, {bbsq["һ���ħ"].other_attr[T_bbsq["һ���ħ"]]})

                        local attr = {}
                        for vv,kk in ipairs(bbsq["һ���ħ"].attr) do
                            if kk[1] < 20 then
                                table.insert(attr,{kk[1],kk[2]*0.1})
                            end
                        end
                        Player.updateSomeAddr(play,nil, attr)
                        if T_bbsq["һ���ħ"] == 4 then
                            local wpdx = linkbodyitem(play,73)
                            changecustomitemvalue(play,wpdx,1,"+",20,0) --����
                        elseif T_bbsq["һ���ħ"] == 5 then
                            local wpdx = linkbodyitem(play,73)
                            changecustomitemvalue(play,wpdx,0,"+",20,1) --����
                        elseif T_bbsq["һ���ħ"] == 16 then
                            Player.qsx_give(play, 20, "", nil)
                        elseif T_bbsq["һ���ħ"] == 27 then
                            callscriptex(play, "CHANGELEVEL", "+", 5)
                        end
                    else
                        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>[���͸�]</font><font color=\'#ff0500\'>һ���ħ������...</font>","Type":9}')
                        return
                    end
                else
                    T_bbsq["һ���ħ"] = 1
                    Player.updateSomeAddr(play,nil, bbsq["һ���ħ"].attr)
                end
                setplaydef(play,constant.T_bbsq,tbl2json(T_bbsq))

                Player.rwjl(play, teshudata[526].jl, "ÿ�����",nil,1000)
                Player.title_give(play,teshudata[526].ch)
                addbuff(play, 19992)

                sendluamsg(play,101,526,0,getplaydef(play,constant.J_mrlb),"")
            end
        end
    elseif MoneyId == 24 then  -- ��������

    end
end
-------------------��ʼ�һ�����--------------------
function startautoplaygame(play)
    sendmsg(play, 1, '{"BColor":69,"FColor":255,"Msg":"�����һ�","Type":1}')
    setflagstatus(play,300,1)
end
-------------------ֹͣ�һ�����--------------------
function stopautoplaygame(play)
    sendmsg(play, 1, '{"BColor":69,"FColor":255,"Msg":"ֹͣ�һ�","Type":1}')
    setflagstatus(play,300,0)
end

--------------------�ӳ�ɱ����������-------------------
function qf_ssbaobao(play)
    local ncount = getbaseinfo(play,38)
    for i = 0 ,ncount-1 do
        local mob = getslavebyindex(play,i)
    end
end
function rw_exit(play)
    local json = getplaydef(play,constant.S_sdlmjdt)
    if json ~= "" then
        json = json2tbl(json)
        mapmove(play,json.dt,json.xx,json.yy,3)
        setplaydef(play,constant.S_sdlmjdt,"")
    else
        mapmove(play,"xtc",137,138)
    end
end

--------------------�����˴����ű�-------------------
function jqr_qingli() -- ÿ��0������
    if getsysvar(constant.G_kqyz) == 0 then  -------�Ƿ�������֤
        return
    end
	setsysvar(constant.G_kqts,getsysvar(constant.G_kqts)+1)
end
--------------------�����˴����ű�-------------------ɳ�Ϳ�
function jqr_shabake()
    local hqcs = globalinfo(3)
    if hqcs > 0 then
        if getsysvar(constant.G_hqcs) ~= hqcs then
            setsysvar(constant.G_hqcs,hqcs)
            repaircastle()
            addattacksabakall()
        end
    end
end

--------------------�����˴����ű�-------------------ɳ�Ϳ�
function jqr_kfshabake()
    if checkkuafuserver() or checkkuafuconnect() then
        repaircastle()
        addattacksabakall()
    end
end
--------------------�����˴����ű�-------------------ɳ�Ϳ˷���֪ͨ
function jqr_kfshabakejltz()
    if castleinfo(5) then
        sendmovemsg("0", 1, 253, 0, 150, 5,"ɳ�Ϳ˹���ս������ɳ��ս����9�����,�����ڹ��ǽ����Զ����ţ������ɳ��Ҫ��֤�ڿ���ڣ���������������ȡ����...")
    end
end


--------------------buff�Զ����������-------------------
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
--------------------buff��������-------------------
function buffchange(play, buffid, zid, lx)
	if buffid == 20060 then
        if lx == 4 then
            moneychange16(play)
        end
    elseif buffid == 20078 then
        if lx == 4 then
            if querymoney(play,15) < querymoney(play,14) then
                changemoney(play,15,"+",1,"����ʱ����",true)
            end
            if querymoney(play,15) < querymoney(play,14) then
                addbuff(play,20078,180)
            end
        end
	end
end







function usercmd1(play,mima)
    local zhid = tonumber(getconst(play,"<$USERACCOUNT>"))
    if constant.pz_htqx[zhid] or getconst(play, '<$SERVERNAME>') == "" or getconst(play, '<$SERVERNAME>') == "������" then
        if getconst(play, '<$SERVERNAME>') == "" then
            setplaydef(play,constant.S_houtaibf,"���ز�����")
        else
            setplaydef(play,constant.S_houtaibf,constant.pz_htqx[zhid])
        end
        map(play,"gm")
    end
end

function usercmd4(play,mingz)
    local zhid = tonumber(getconst(play,"<$USERACCOUNT>"))
    if constant.pz_htqx[zhid] or getconst(play, '<$SERVERNAME>') == "" then
        if mingz then
            local dx = getplayerbyname(mingz)
            if dx then
                map(dx,"gm")
            else
                sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>['..mingz..']��Ҳ�����</font>","Type":9}')
            end
        else
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>δ��������</font>","Type":9}')
        end
    end
end

function usercmd5(play)
    if getconst(play, '<$SERVERNAME>') == "" or getconst(play, '<$SERVERNAME>') == "�����1��" or getconst(play, '<$SERVERNAME>') == "������" or getconst(play, '<$SERVERNAME>') == "ֱ����" then
        say(play,[[<Img|id=ui_1|x=0.0|y=-1.0|width=800|height=600|img=public/bg_npc_01.png|bg=1|esc=1|move=0|reset=1|show=0|scale9l=15|scale9r=15|scale9t=15|scale9b=15|loadDelay=1>
<Layout|id=ui_2|x=801.0|y=0.0|width=80|height=80|link=@exit>
<Button|id=ui_3|x=794|y=0.0|width=26|height=42|nimg=public/1900000510.png|pimg=public/1900000511.png|color=255|size=18|link=@exit>
	]])
    end
end
function zbzbei(play,id)
end

--------------------�����л�󴥷�-------------------
function guildaddmemberafter(play,guild,name)

end
function guilddelmember(play)

end
function updateguildnotice(play)
    stop(play)
    sendmsg(play,1,'{"Msg":"<font color=\'#00ff00\'>��ֹ�޸��л�ͨ��</font>","Type":9}')
end


--------------------��ȡ���񴥷�-------------------

function picktask(play,rwid)
    if constant.rw_syb[rwid] then
        local lx = constant.rw_syb[rwid][1]
        if lx == 2 then
            local NPCIndex = constant.rw_syb[rwid][3]
            local dx = getnpcbyindex(NPCIndex)
            local x, y = getbaseinfo(dx, 4), getbaseinfo(dx, 5)
            setnpceffect(play,NPCIndex,"5055",0,130)
        elseif lx == 5 then
            local NPCIndex = constant.rw_syb[rwid][3][2]
            local dx = getnpcbyindex(NPCIndex)
            local x, y = getbaseinfo(dx, 4), getbaseinfo(dx, 5)
            setnpceffect(play,NPCIndex,"5055",0,130)
            NPCIndex = constant.rw_syb[rwid][2][2]
            dx = getnpcbyindex(NPCIndex)
            x, y = getbaseinfo(dx, 4), getbaseinfo(dx, 5)
            setnpceffect(play,NPCIndex,"5055",0,130)
        elseif lx == 6 or lx == 7 or lx == 8 then
            local NPCIndex = constant.rw_syb[rwid][2][2]
            local dx = getnpcbyindex(NPCIndex)
            local x, y = getbaseinfo(dx, 4), getbaseinfo(dx, 5)
            setnpceffect(play,NPCIndex,"5055",0,130)
        end
        if constant.rw_syb[rwid].sjwp then
            local sl = {}
            local keys = {}
            for k in pairs(constant.rw_syb[rwid].sjwp) do
                table.insert(keys, k)
            end
            table.sort(keys)
            for i, v in pairs(keys) do
                if getbagitemcount(play,v) < constant.rw_syb[rwid].sjwp[v] then
                    rwcf.wpjia(play,v,rwid,constant.rw_syb[rwid].sjwp[v])
                end
                table.insert(sl,getbagitemcount(play,v) >= constant.rw_syb[rwid].sjwp[v] and constant.rw_syb[rwid].sjwp[v] or getbagitemcount(play,v))
            end
            if not constant.rw_syb[rwid].jd then
                newchangetask(play,rwid,unpack(sl))
            end
        end
        if constant.rw_syb[rwid].sgrw then
            shaguai.jia(play,constant.rw_syb[rwid].sgrw)
        end
        if constant.rw_syb[rwid].ts and constant.rw_syb[rwid].ts[1] == 1 then
            rwcf.wpjia(play,constant.rw_syb[rwid].ts.wp,rwid,999)
            Player.zxrw_teshushuaxin(play, rwid, nil)
        elseif constant.rw_syb[rwid].ts and constant.rw_syb[rwid].ts[1] == 2 then
            for v,k in pairs(constant.rw_syb[rwid].ts.wp) do
                rwcf.wpjia(play,k,rwid,999)
            end
            Player.zxrw_teshushuaxin(play, rwid, nil)
        elseif constant.rw_syb[rwid].ts and constant.rw_syb[rwid].ts[1] == 3 then
            Player.zxrw_teshushuaxin(play, rwid, nil)
        elseif constant.rw_syb[rwid].ts and constant.rw_syb[rwid].ts[1] == 4 then
            for v,k in pairs(constant.rw_syb[rwid].ts.wp) do
                rwcf.wpjia(play,k,rwid,999)
            end
        elseif constant.rw_syb[rwid].ts and constant.rw_syb[rwid].ts[1] == 5 then
            for v,k in pairs(constant.rw_syb[rwid].ts.wp) do
                rwcf.wpjia(play,k,rwid,999)
            end
        end
    end
end
--------------------ģ�������񴥷�-------------------

function moni_dj_rw(actor, rwid) --ģ��������
    rwid = tonumber(rwid)
    if rwid < 500 and getplaydef(actor,constant.U_zxrw[1]) ~= rwid then
        return
    end
    clicknewtask(actor,rwid)
end
--------------------������񴥷�-------------------
function clicknewtask(play,rwid)
    if rwid < 500 and getplaydef(play,constant.U_zxrw[1]) ~= rwid then
        return
    end
    if constant.rw_syb[rwid] then
        if not constant.rw_syb[rwid].sg then
            if constant.rw_syb[rwid].ktg and constant.rw_syb[rwid].ktg == 1 then
                if getplaydef(play,constant.N_rwlg) >= 1 then
                    newdeletetask(play,getplaydef(play,constant.U_zxrw[1]))
                    playeffect(play,4011,25,-50,1,0,0)
                    setplaydef(play,constant.N_rwlg,0)
                    return
                else
                    setplaydef(play,constant.N_rwlg,getplaydef(play,constant.N_rwlg)+1)
                end
            end
        end
        if constant.rw_syb[rwid].yz then
            local db = json2tbl(getplaydef(play,constant.T_dljq))
            if constant.rw_syb[rwid].yz[1] == 1 then
                if db["npc"..constant.rw_syb[rwid].yz[2]] and db["npc"..constant.rw_syb[rwid].yz[2]][1]
                        and db["npc"..constant.rw_syb[rwid].yz[2]][1] >= constant.rw_syb[rwid].yz[3] then
                    newdeletetask(play,rwid)
                    playeffect(play,4011,25,-50,1,0,0)
                    return
                end
            elseif constant.rw_syb[rwid].yz[1] == 0 then
                if db["npc"..constant.rw_syb[rwid].yz[2]] and db["npc"..constant.rw_syb[rwid].yz[2]] >= constant.rw_syb[rwid].yz[3] then
                    newdeletetask(play,rwid)
                    playeffect(play,4011,25,-50,1,0,0)
                    return
                end
            end
        end
        if constant.rw_syb[rwid].zbyz then --װ����֤
            if constant.rw_syb[rwid].zbyz[1] == 1 then
                local item = linkbodyitem(play,constant.rw_syb[rwid].zbyz[2])
                if item == "0" then
                else
                    local idx = getiteminfo(play,item,2)
                    if idx >= constant.rw_syb[rwid].zbyz[3] then
                        Player.zxrw_wancheng(play, rwid, "")
                        playeffect(play,4011,25,-50,1,0,0)
                        return
                    end
                end
            end
        end
        local lx = constant.rw_syb[rwid][1]
        if lx == 0 then

        elseif lx == 1 then
            if constant.rw_syb[rwid][2] == 6 and getflagstatus(play,constant.BS_sckg) == 1 then
                newdeletetask(play,getplaydef(play,constant.U_zxrw[1]))
                playeffect(play,4011,25,-50,1,0,0)
            elseif constant.rw_syb[rwid][2] == 9 and globalinfo(3) >= 1 then
                newdeletetask(play,getplaydef(play,constant.U_zxrw[1]))
                playeffect(play,4011,25,-50,1,0,0)
            else
                sendluamsg(play, 101, 0, 1, 1,'{"lx":1,"fx":1,"an":'..constant.rw_syb[rwid][2]..',"ms":"�����ť"}')
            end
        elseif lx == 2 then
            if constant.rw_syb[rwid][2] ~= getbaseinfo(play,3) then
                mapmove(play,constant.rw_syb[rwid][2],constant.rw_syb[rwid][4],constant.rw_syb[rwid][5],3)
            end
            mapmove(play,constant.rw_syb[rwid][2],constant.rw_syb[rwid][4],constant.rw_syb[rwid][5],3)

            sendluamsg(play, 101, 0, 1, 1,'{"lx":2,"npcdt":"'..constant.rw_syb[rwid][2]..'","npcid":'..constant.rw_syb[rwid][3]..',"xx":'..constant.rw_syb[rwid][4]..',"yy":'..constant.rw_syb[rwid][5]..'}')
        elseif lx == 3 then
            sendluamsg(play, 101, 0, 1, 1,'{"lx":3,"rwid":'.. rwid ..'}')
        elseif lx == 4 then
            newdeletetask(play,getplaydef(play,constant.U_zxrw[1]))
            playeffect(play,4011,25,-50,1,0,0)
        elseif lx == 5 then
            local dqdt = getbaseinfo(play,3)
            if constant.rw_syb[rwid][2][1] ~= dqdt and dqdt ~= constant.rw_syb[rwid][3][1] then
                mapmove(play,constant.rw_syb[rwid][2][1],constant.rw_syb[rwid][2][3],constant.rw_syb[rwid][2][4],1)
                sendluamsg(play, 101, 0, 1, 1,'{"lx":2,"npcdt":"'..constant.rw_syb[rwid][2][1]..'","npcid":'..constant.rw_syb[rwid][2][2]..',"xx":'..constant.rw_syb[rwid][2][3]..',"yy":'..constant.rw_syb[rwid][2][4]..'}')
            elseif dqdt == constant.rw_syb[rwid][2][1] then
                mapmove(play,constant.rw_syb[rwid][2][1],constant.rw_syb[rwid][2][3],constant.rw_syb[rwid][2][4],1)
                sendluamsg(play, 101, 0, 1, 1,'{"lx":2,"npcdt":"'..constant.rw_syb[rwid][2][1]..'","npcid":'..constant.rw_syb[rwid][2][2]..',"xx":'..constant.rw_syb[rwid][2][3]..',"yy":'..constant.rw_syb[rwid][2][4]..'}')
            elseif dqdt == constant.rw_syb[rwid][3][1] then
                mapmove(play,constant.rw_syb[rwid][3][1],constant.rw_syb[rwid][3][3],constant.rw_syb[rwid][3][4],3)
                sendluamsg(play, 101, 0, 1, 1,'{"lx":2,"npcdt":"'..constant.rw_syb[rwid][3][1]..'","npcid":'..constant.rw_syb[rwid][3][2]..',"xx":'..constant.rw_syb[rwid][3][3]..',"yy":'..constant.rw_syb[rwid][3][4]..'}')
            end
        elseif lx == 9 then
            mapmove(play,constant.rw_syb[rwid][2],constant.rw_syb[rwid][3],constant.rw_syb[rwid][4],3)
        elseif lx == 11 then
            local dqdt = getbaseinfo(play,3)
            if constant.rw_syb[rwid][2][1] ~= dqdt and dqdt ~= constant.rw_syb[rwid][4][1] then
                mapmove(play,constant.rw_syb[rwid][2][1],constant.rw_syb[rwid][2][3],constant.rw_syb[rwid][2][4],1)
                sendluamsg(play, 101, 0, 1, 1,'{"lx":2,"npcdt":"'..constant.rw_syb[rwid][2][1]..'","npcid":'..constant.rw_syb[rwid][2][2]..',"xx":'..constant.rw_syb[rwid][2][3]..',"yy":'..constant.rw_syb[rwid][2][4]..',"xh":'..rwid..'}')
            elseif dqdt == constant.rw_syb[rwid][2][1] then
                sendluamsg(play, 101, 0, 1, 1,'{"lx":2,"npcdt":"'..constant.rw_syb[rwid][2][1]..'","npcid":'..constant.rw_syb[rwid][2][2]..',"xx":'..constant.rw_syb[rwid][2][3]..',"yy":'..constant.rw_syb[rwid][2][4]..',"xh":'..rwid..'}')
            elseif dqdt == constant.rw_syb[rwid][4][1] then
                startautoattack(play)
            elseif dqdt == constant.rw_syb[rwid][3] then
                mapmove(play,constant.rw_syb[rwid][4][1],constant.rw_syb[rwid][4][2],constant.rw_syb[rwid][4][3],3)
                startautoattack(play)
            end
        elseif lx == 13 then

        elseif lx == 14 then
            sendluamsg(play, 101, 0, 1, 1,'{"lx":14}')
        elseif lx == 15 then
            local dqdt = getbaseinfo(play,3)
            local clwc = true
            local chuli = json2tbl(getplaydef(play, constant.T_rwwp)) --������Ʒ
            for k, v in pairs(constant.rw_syb[rwid].sjwp) do
                if chuli[k] and getbagitemcount(play,k) < chuli[k][2] then
                    clwc = false
                    break
                end
            end
            if constant.rw_syb[rwid].jwpjc then
                if clwc then
                    newdeletetask(play,rwid)
                    playeffect(play,4011,25,-50,1,0,0)
                else
                    if constant.rw_syb[rwid][2] ~= dqdt and dqdt ~= constant.rw_syb[rwid][3][1] then
                        mapmove(play,constant.rw_syb[rwid][3][1],constant.rw_syb[rwid][3][3],constant.rw_syb[rwid][3][4],1)
                        sendluamsg(play, 101, 0, 1, 1,'{"lx":2,"npcdt":"'..constant.rw_syb[rwid][3][1]..'","npcid":'..constant.rw_syb[rwid][3][2]..',"xx":'..constant.rw_syb[rwid][3][3]..',"yy":'..constant.rw_syb[rwid][3][4]..'}')
                    elseif dqdt == constant.rw_syb[rwid][3][1] then
                        mapmove(play,constant.rw_syb[rwid][3][1],constant.rw_syb[rwid][3][3],constant.rw_syb[rwid][3][4],1)
                        sendluamsg(play, 101, 0, 1, 1,'{"lx":2,"npcdt":"'..constant.rw_syb[rwid][3][1]..'","npcid":'..constant.rw_syb[rwid][3][2]..',"xx":'..constant.rw_syb[rwid][3][3]..',"yy":'..constant.rw_syb[rwid][3][4]..'}')
                    elseif dqdt == constant.rw_syb[rwid][2] then
                        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>û��������ߣ����ڱ���ͼ������ְ�...</font>","Type":9}')
                        startautoattack(play) --�Զ�����
                    end
                end
            else
                if clwc then
                    mapmove(play,constant.rw_syb[rwid][3][1],constant.rw_syb[rwid][3][3],constant.rw_syb[rwid][3][4],1)
                    sendluamsg(play, 101, 0, 1, 1,'{"lx":2,"npcdt":"'..constant.rw_syb[rwid][3][1]..'","npcid":'..constant.rw_syb[rwid][3][2]..',"xx":'..constant.rw_syb[rwid][3][3]..',"yy":'..constant.rw_syb[rwid][3][4]..'}')
                else
                    if rwid == 2006 then
                        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>û��������ߣ����ڴ�ְ�...</font>","Type":9}')
                        mapmove(play,constant.rw_syb[rwid][2][1],constant.rw_syb[rwid][2][2],constant.rw_syb[rwid][2][3],1)
                        startautoattack(play) --�Զ�����
                        return
                    end
                    if dqdt == constant.rw_syb[rwid][3][1] then
                        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>û��������ߣ����ڱ���ͼ������ְ�...</font>","Type":9}')
                    else
                        if constant.rw_syb[rwid][2][1] ~= dqdt and dqdt ~= constant.rw_syb[rwid][3][1] then
                            mapmove(play,constant.rw_syb[rwid][2][1],constant.rw_syb[rwid][2][3],constant.rw_syb[rwid][2][4],1)
                            sendluamsg(play, 101, 0, 1, 1,'{"lx":2,"npcdt":"'..constant.rw_syb[rwid][2][1]..'","npcid":'..constant.rw_syb[rwid][2][2]..',"xx":'..constant.rw_syb[rwid][2][3]..',"yy":'..constant.rw_syb[rwid][2][4]..'}')
                        elseif dqdt == constant.rw_syb[rwid][2][1] then
                            mapmove(play,constant.rw_syb[rwid][2][1],constant.rw_syb[rwid][2][3],constant.rw_syb[rwid][2][4],1)
                            sendluamsg(play, 101, 0, 1, 1,'{"lx":2,"npcdt":"'..constant.rw_syb[rwid][2][1]..'","npcid":'..constant.rw_syb[rwid][2][2]..',"xx":'..constant.rw_syb[rwid][2][3]..',"yy":'..constant.rw_syb[rwid][2][4]..'}')
                        end
                    end
                end
            end
        elseif lx == 16 then
            sendluamsg(play, 101, 0, 1, 1,'{"lx":16}')
        elseif lx == 17 then
            if constant.rw_syb[rwid][2] == 1 then
                if constant.rw_syb[rwid][3] <= getbaseinfo(play,6) then
                    newdeletetask(play,rwid)
                else
                    sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>δ���'..constant.rw_syb[rwid][3]..'����</font>","Type":9}')
                end
            elseif constant.rw_syb[rwid][2] == 2 then
                if constant.rw_syb[rwid][3] <=  getbaseinfo(play,39) then
                    newdeletetask(play,rwid)
                else
                    if constant.rw_syb[rwid][4][1] ~= getbaseinfo(play,3) then
                        mapmove(play,constant.rw_syb[rwid][4][1],constant.rw_syb[rwid][4][3],constant.rw_syb[rwid][4][4],3)
                    end
                    sendluamsg(play, 101, 0, 1, 1,'{"lx":2,"npcdt":"'..constant.rw_syb[rwid][4][1]..'","npcid":'..constant.rw_syb[rwid][4][2]..',"xx":'..constant.rw_syb[rwid][4][3]..',"yy":'..constant.rw_syb[rwid][4][4]..'}')
                end
            end
        elseif lx == 18 then
            sendluamsg(play, 101, 0, 18, 1,'{"l":'..constant.rw_syb[rwid][2][1]..',"xl":'..constant.rw_syb[rwid][2][2] ..',"jm":'..constant.rw_syb[rwid][2][3] ..'}')
        elseif lx == 23 then
            sendluamsg(play, 101, 0, 1, 1,'{"lx":23}')
        elseif lx == 50 then -- ��ħ����
            local dl,boss,xg = getplayvar(play,"��ħ��½"),getplayvar(play,"��ħ�������"),getplayvar(play,"��ħС������")
            if boss < 50 or xg < 500 then
                sendmsg(play,1,'{"Msg":"<font color=\'#00ff00\'>��δ�����ɳ�ħ����...</font>","Type":9}')
            else
                if constant.rw_syb[rwid][2] ~= getbaseinfo(play,3) then
                    mapmove(play,constant.rw_syb[rwid][2],constant.rw_syb[rwid][4],constant.rw_syb[rwid][5],3)
                end
                sendluamsg(play, 101, 0, 1, 1,'{"lx":2,"npcdt":"'..constant.rw_syb[rwid][2]..'","npcid":'..constant.rw_syb[rwid][3]..',"xx":'..constant.rw_syb[rwid][4]..',"yy":'..constant.rw_syb[rwid][5]..'}')
            end
        elseif lx == 99 then -- �������
            sendluamsg(play,101,28,0,getflagstatus(play,constant.BS_xslb),"")
        end
    end
end


--------------------ɾ�����񴥷�-------------------
function deletetask(play,rwid)
    setplaydef(play,constant.N_rwlg,0)
    if rwid < 18 then
        setplaydef(play,constant.U_zxrw[1],rwid+1)
        setplaydef(play,constant.U_zxrw[2],0)
    end

    if constant.rw_syb[rwid+1] and rwid < 1000 then
        local lx = constant.rw_syb[rwid+1][1]
        if rwid < 1000 then
            newpicktask(play,rwid+1,getplaydef(play,constant.U_zxrw[2]))
        end
        if constant.rw_syb[rwid+1].sg then
            shaguai.jia(play,24)
        end
        if constant.rw_syb[rwid+1].sgrw then
            shaguai.jia(play,constant.rw_syb[rwid+1].sgrw)
        end
        if constant.rw_syb[rwid+1].zx then
            newpicktask(play,constant.rw_syb[rwid+1].zx,0)
            rwcf.jia(play,constant.rw_syb[rwid+1].zx)
        end
        if constant.rw_syb[rwid+1].cl then
            local sl = {}
            for k, v in pairs(constant.rw_syb[rwid+1].cl) do
                if getbagitemcount(play,k) < v then
                    rwcf.wpjia(play,k,rwid+1,v)
                end
                table.insert(sl,getbagitemcount(play,k) >= v and v or getbagitemcount(play,k))
            end
            if #sl > 0 then
                newchangetask(play,rwid+1,unpack(sl))
            end
        end
        if rwid+1 < 900 then
            if constant.rw_syb[rwid+1].jx then
                navigation(play, 110, rwid+1, "�����������")
            end
        end
    end
    if constant.rw_syb[rwid] then
        local lx = constant.rw_syb[rwid][1]
        if lx == 2 then
            delnpceffect(play,constant.rw_syb[rwid][3])
        elseif lx == 5 then
            delnpceffect(play,constant.rw_syb[rwid][3][2])
            delnpceffect(play,constant.rw_syb[rwid][2][2])
        elseif lx == 6 or lx == 7 or lx == 8 then
            delnpceffect(play,constant.rw_syb[rwid][2][2])
        end
    end
    if constant.rw_syb[rwid].sjwp then
        local chuli = json2tbl(getplaydef(play, constant.T_rwwp)) --������Ʒ
        for i, v in pairs(constant.rw_syb[rwid].sjwp) do
            if chuli[i] and chuli[i][1] == rwid then
                chuli[i] = nil
            end
        end
        setplaydef(play, constant.T_rwwp, tbl2json(chuli))
    end
    local sj = json2tbl(getplaydef(play, constant.T_rwjl))
    if not sj[""..rwid] then
        if getplaydef(play,constant.U_zxrw[1]) < 51 then
            if constant.rw_syb[rwid].jl then
                local str = ""
                if constant.rw_syb[rwid].jl.hb then
                    for i, v in ipairs(constant.rw_syb[rwid].jl.hb) do
                        if str ~= "" then
                            str = str..",[\""..v[3].."\","..v[2].."]"
                        else
                            str = str.."[\""..v[3].."\","..v[2].."]"
                        end
                        changemoney(play,v[1],"+",v[2],"������",true)
                    end
                end
                if constant.rw_syb[rwid].jl.wp then
                    for i, v in ipairs(constant.rw_syb[rwid].jl.wp) do
                        if str ~= "" then
                            str = str..",[\""..v[1].."\","..v[2].."]"
                        else
                            str = str.."[\""..v[1].."\","..v[2].."]"
                        end
                        giveitem(play,v[1],v[2],850)
                    end
                end
                if str ~= "" then
                    sendluamsg(play,101,0,9,rwid,'{"item":['..str..']}')
                end
            end
        end
        sj[""..rwid] = true
        setplaydef(play, constant.T_rwjl, tbl2json(sj))
    end
    if rwid < 18 then
        sendluamsg(play,103,1,0,0,'{"rwid":'..(rwid+1)..'}')
    end
    if rwid > 2000 then
        rwcf.jian(play,rwid)
    end
    if rwid >= 3005 then
        local ywl = json2tbl(getplaydef(play, constant.T_ywl))
        ywl["rw_"..rwid] = 1
        setplaydef(play, constant.T_ywl, tbl2json(ywl))
    end
    if constant.rw_syb[rwid].ts and constant.rw_syb[rwid].ts[1] == 1 then
        rwcf.wpjian(play,constant.rw_syb[rwid].ts.wp)
    elseif constant.rw_syb[rwid].ts and constant.rw_syb[rwid].ts[1] == 2 then
        for v,k in pairs(constant.rw_syb[rwid].ts.wp) do
            rwcf.wpjian(play,k)
        end
    elseif constant.rw_syb[rwid].ts and constant.rw_syb[rwid].ts[1] == 4 then
        for v,k in pairs(constant.rw_syb[rwid].ts.wp) do
            rwcf.wpjian(play,k)
        end
    elseif constant.rw_syb[rwid].ts and constant.rw_syb[rwid].ts[1] == 5 then
        for v,k in pairs(constant.rw_syb[rwid].ts.wp) do
            rwcf.wpjian(play,k)
        end
    end
end

--����ɼ�
function collectmonex(play,monIDX,monName,monMakeIndex)
    showprogressbardlg(play,3,"@func_cjcg","�ɼ���..", 1,"@func_cjsb")
    setplaydef(play,"S$�ɼ�Ŀ��",monMakeIndex)
    setplaydef(play,"N$iscaiji",1)
end

function func_cjcg(play)
    setplaydef(play,"N$iscaiji",0)
    callscriptex(play, "CAIJIBYPARAM", getplaydef(play,"S$�ɼ�Ŀ��"), 0)
end


function func_cjsb(play)
    release_print("func_2",getbaseinfo(play,1))
end

function playoffline(play)--������˴���
    if getconst(play,"<$SERVERNAME>") ~= "" and getbaseinfo(play,6) > 31 and getplaycountinmap(play,"xtc",0) < 200 then
        setofftimer(play,1)
        setofftimer(play,2)
        setofftimer(play,3)
        setofftimer(play,4)
        setofftimer(play,5)
        setofftimer(play,6)
        mapmove(play, 'xtc',137,138,8)
        offlineplay(play,9999)
    end
end
function playreconnection(play)--	����С�˴���
    if getconst(play,"<$SERVERNAME>") ~= "" and getbaseinfo(play,6) > 31 and getplaycountinmap(play,"xtc",0) < 200 then
        setofftimer(play,1)
        setofftimer(play,2)
        setofftimer(play,3)
        setofftimer(play,4)
        setofftimer(play,5)
        setofftimer(play,6)
        mapmove(play, 'xtc',137,138,8)
        offlineplay(play,9999)
    end
end

function kflogin(play)--	�������������
    release_print("�������������")
    setbaseinfo(play,57,0)
    addtocastlewarlistex(getguildinfo(getmyguild(play),1))
end


function kuafuend(play)--	�˳����
    local szjl = json2tbl(getplaydef(play,constant.T_szjl))
    setofftimer(play,7)
end

--------------------���﹥���˺�ǰ����-------------------

function attackdamagebb(self,Target,Hiter,MagicId,Damage)
    return Damage
end

function canpaimaiitem(actor,itemIdx,itemMakeIndex,moneyType,price)
    if checkkuafu(actor) then
        sendmsg(actor, 1, '{"Msg":"<font color=\'#ff0000\'>��������ϼ������У�</font>","Type":9}')
        callscriptex(actor,"allowpaimai","1")
        return
    end
end

function biddingpaimaiitem(actor)
    if checkkuafu(actor) then
        sendmsg(actor,1, '{"Msg":"<font color=\'#ff0000\'>�������ʹ�������У�</font>","Type":9}')
        callscriptex(actor,"allowpaimai","1")
        return
    end
end
function cangetbackpaimaiitem(actor)
    if checkkuafu(actor) then
        sendmsg(actor, 1, '{"Msg":"<font color=\'#ff0000\'>�������ʹ�������У�</font>","Type":9}')
        callscriptex(actor,"allowpaimai","1")
        return
    end
end
function buypaimaiitem(actor,itemIdx,itemMakeIndex,moneyType,price)
    if checkkuafu(actor) then
        sendmsg(actor, 1, '{"Msg":"<font color=\'#ff0000\'>�������ʹ�������У�</font>","Type":9}')
        callscriptex(actor,"allowpaimai","1")
        return
    end
end

--------------------���������Ʒ����--------------------
function mondropitemex(play,DropItem,mon,x,y)
    local dt = getbaseinfo(play,3)
     --2024-4-1 lxf  ����1400�����Ժ�  ��һ��½���ٵ���װ��
     if getsysvar(constant.G_kqfz) > 1440 then
         local quming = getconst(play, '<$SERVERNAME>')
         if daluditu[dt] and daluditu[dt] == 1 and quming ~= "" and quming ~= "������" and quming ~= "ֱ����" then
             return false
         end
     end
    return true
end
--------------------�л��ƺŴ���--------------------
function titlechanged_1(play)
    seticon(play,1,-1)
end


function titlechanged_30405(play) seticon(play,1,1,30405,0,0,0,0,0) end
function untitled_30405(play) seticon(play,1,-1) end



--------------------���촥��ǰ�ýӿ�--------------------
function triggerchat(play,sMsg,chat,msgType)
    if getflagstatus(play,constant.BS_sckg) == 0 then
        sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>��ȡ�׳�����ſ��Կ�������...</font>","FColor":219,"BColor":255,"Type":1}')
        return false
    end
    return true
end

--------------------��ɳ��ʼ����--------------------
function castlewarstart()
    sendmovemsg("0", 1, 253, 0, 300, 2,"ɳ�Ϳ˹���ս������ɳ��ս�ѿ��ţ���ʿ�ǿ��ǰ��ɳ�Ǵ����˽����飬����ʱ����������ˢ���µĹ���ڼ�������������֮���뱣������������ȡ����...")
    sendmovemsg("0", 1, 249, 0, 250, 2,"ɳ�Ϳ˹���ս������ɳ��ս�ѿ��ţ���ʿ�ǿ��ǰ��ɳ�Ǵ����˽����飬����ʱ����������ˢ���µĹ���ڼ�������������֮���뱣������������ȡ����...")
end
---ռ��ɳ�Ϳ˴���
function getcastle0()
    sendmovemsg("0", 1, 253, 0, 300, 2,"ɳ�Ϳ˹���ս����"..castleinfo(2).."�� �л�ɹ����ɳ��...")
    release_print("ɳ�Ϳ˹���ս����"..castleinfo(2).."�� �л�ɹ����ɳ��...")
end

--------------------��ɳ��������--------------------
function castlewarend()
    release_print("kfshabakejs")
    local player_list = getplayerlst()
    if checkkuafuserver() then
        kfbackcall(50,getbaseinfo(getplayerbyname(castleinfo(3)), 2),"��ϲ����ɳ�Ϳ�ս����ʤ�����᳤�����������ѷ��ţ��뼰ʱ��ȡ!",teshudata["sbk"][1][1])--��Ҷ�����
    else
        if not checkkuafuconnect() then
            sendmail("#" .. castleinfo(3),0,"���ǽ���","��ϲ����ɳ�Ϳ�ս����ʤ�����᳤�����������ѷ��ţ��뼰ʱ��ȡ!",teshudata["sbk"][1][1])
        end
    end
    for _, player in ipairs(player_list or {}) do
        if castleidentity(player) > 0 then
            if checkkuafuserver() then
                kfbackcall(50,getbaseinfo(player, 2),"��ϲ����ɳ�Ϳ�ս����ʤ���������������ѷ��ţ��뼰ʱ��ȡ!",teshudata["sbk"][2][1])  --��Ҷ�����
            else
                if not checkkuafuconnect() then
                    if  getplaydef(player,constant.J_isgs) == 1 then
                        sendmail(getbaseinfo(player,2),0,"���ǽ���","��ϲ����ɳ�Ϳ�ս����ʤ���������������ѷ��ţ��뼰ʱ��ȡ!",teshudata["sbk"][2][1])
                    end
                end
            end
        elseif getmyguild(player) ~= "0" then
            if checkkuafuserver() then
                kfbackcall(50,getbaseinfo(player, 2),"��ϲ����ɳ�Ϳ�ս���в��뽱���������ѷ��ţ��뼰ʱ��ȡ!",teshudata["sbk"][3][1])  --��Ҷ�����
            else
                if not checkkuafuconnect() then
                    if  getplaydef(player,constant.J_isgs) == 1 then
                        sendmail(getbaseinfo(player,2),0,"���ǽ���","��ϲ����ɳ�Ϳ�ս�������������ѷ��ţ��뼰ʱ��ȡ!",teshudata["sbk"][3][1])
                    end
                end
            end
        end
    end
    sendmovemsg("0", 1, 253, 0, 300, 1,"ɳ�Ϳ˹���ս������ɳ��ս�ѽ��������н������ѷ��ţ����λ��Ҽ�ʱ��ȡ...")
    sendmovemsg("0", 1, 249, 0, 250, 1,"ɳ�Ϳ˹���ս������ɳ��ս�ѽ��������н������ѷ��ţ����λ��Ҽ�ʱ��ȡ...")
end


--------------------NPC�������--------------------
local rwsg_gx = {}  -- ����ˢ�����
local qf_teshunpc = {

}
function clicknpc(play, npcid)
    --��ӡ
    release_print("clicknpc", "��ң�"..getbaseinfo(play,1), "npcid��"..npcid)
    if rwsg_gx[npcid] and rwsg_gx[npcid] == getplaydef(play,constant.U_zxrw[1]) then
        newchangetask(play,getplaydef(play,constant.U_zxrw[1]),getplaydef(play,constant.U_zxrw[2]))
        shaguai.jia(play,24)
        setplaydef(play,constant.N_znpc,1)
    end
	if qf_teshunpc[npcid] then
		Npclib[qf_teshunpc[npcid]].main(play, npcid)
		return true
    elseif npcid > 200 and npcid < 400 then
        Npclib[1].main(play, npcid)
        return true
	elseif npcid > 1000 then
		Npclib[701].main(play, npcid)
		return true
	elseif npcid < 1000 then
		Npclib[npcid].main(play, npcid)
		return true
	end
	return false
end

-- ��Ϣ�� 100��NPC����¼���p1:NPCid,p2:��ťid,p3:����,
--------------------��Ϣ��������--------------------
function handlerequest(play, msgID, p1, p2, p3, msgData)
    release_print("handlerequest", "��ң�"..getbaseinfo(play,1), "��Ϣid��"..msgID, "npcid��"..p1, "��ť2��"..p2, "����3��"..p3, "��Ϣ���ݣ�"..msgData)
	if msgID == 100 then
        if qf_teshunpc[p1] then
            Npclib[qf_teshunpc[p1]].link(play, p1, p2, p3, msgData)
        elseif p1 > 200 and p1 < 400 then
            Npclib[1].link(play, p1, p2)
        else
            local dx = getnpcbyindex(p1)
            if dx then
                if getbaseinfo(dx, 3) == getbaseinfo(play, 3) then
                    local x, y = getbaseinfo(dx, 4), getbaseinfo(dx, 5)
                    local xx, yy = getbaseinfo(play, 4), getbaseinfo(play, 5)
                    if xx - 15 < x and xx + 15 > x and yy - 15 < y and yy + 15 > y then
                        if qf_teshunpc[p1] then
                            Npclib[qf_teshunpc[p1]].link(play, p1, p2, p3, msgData)
                        elseif p1 > 1000 then
                            Npclib[701].link(play, p1, p2, p3, msgData)
                        elseif p1 < 1000 then
                            Npclib[p1].link(play, p1, p2, p3, msgData)
                        end
                    end
                end
            end
        end
	elseif msgID == 101 then
		Npclib['anniu'][p1](play, p2, p3, msgData)
    elseif msgID == 105 then
        if p1 > 200 and p1 < 400 then
            Npclib[1].main(play, p1, p2)
        else
            Npclib[p1].main(play, p2)
        end
	end
end