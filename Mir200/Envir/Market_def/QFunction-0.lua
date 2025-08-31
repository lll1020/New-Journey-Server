--------------------修理装备表头--------------------
itemstype = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 55, 71, 72, 73, 74, 75, 76}
--------------------异常处理--------------------
for k, _ in pairs(package.loaded) do
	if string.find(k, '^Envir/Lua/') then
		release_print(k)
		package.loaded[k] = nil
	end
end

function MainError(errinfo)
	if errinfo then
		release_print('脚本错误', errinfo)
	end
end

local function init()
    dofile('Envir/Lua/Main.lua')
end

local result, errinfo = pcall(init)
if not result then
	MainError(errinfo)
end


--------------------引擎初始化--------------------
function startup()
    local qf_ditucanshu = dofile('Envir/Lua/Data/ditulianjie.lua')
    for k, v in pairs(qf_ditucanshu) do
        mapeffect('连接' .. k, v[1], v[2], v[3], 10297, 0, 0)
        if v[4] then
            mapeffect('名字' .. k, v[1], v[2], v[3], v[4], 0, 0)
        end
    end
    setontimerex(1, 60) ---全区定时器
end

--------------------人物初始化--------------------
function login(play)
    local quming = getconst(play, '<$SERVERNAME>')
    if callcheckscriptex(play,"ISDUMMY") then
        Login.main(play)
        setontimer(play, 10, 3)
    else
        if getsysvar(VarCfg["G_开区分钟"]) >= 1440 and linkbodyitem(play,71) == "0" then
            --TODO
            if quming ~= "" and quming ~= "测试区" and quming ~= "直播区" and quming ~= "审核区1区" then
                if not constant.pz_htqx[tonumber(getconst(play,"<$USERACCOUNT>"))] then
                    messagebox(play,"开区24小时后禁止注册角色,请前往新区发展")
                    kick(play)
                    return
                end
            end
        end
        Login.main(play)
        setontimer(play, 1, 3, 0, 1)
        --红点系统定时器
        setontimer(play,6,60,0,1)
    end
end
--------------------跨天登录触发--------------------
function resetday(play)
    ---清理每日称号
	for _, v in pairs(constant.pz_ldql) do
		Player.title_del(play, v)
	end
end
--------------------传送戒指传送前触发触发-------------------
function beginteleport(play)
    setplaydef(play,"S$dtm",getbaseinfo(play, 3))
    local sj  = os.time()
    local bl = sj - getplaydef(play,"N$传送功能CD")
    if bl < 5 then
        sendmsg(play,1,'{"Msg":"请等待'..(5-bl)..'秒后在使用","FColor":56,"BColor":255,"Type":1}')
        return false
    end
    local du = getbaseinfo(play, 3)
    if (daluditu[du] and daluditu[du] < 3) or (getplaydef(play,"N$战斗状态") < os.time()) then
        setplaydef(play,"N$传送功能CD",sj)
        return true
    end
    sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>战斗状态无法使用...</font>","Type":9}')
    return false
end

--------------------AI挂机自动切换地图-------------------
function ai_qhdt(play)
	local json, lins = json2tbl(getplaydef(play, VarCfg.T_aigj)), {}
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
                sendmsg(play, 1, '{"Msg":"<font color=\'#28ef01\'>AI挂机：已自动切换地图!</font>","Type":9}')
            end
        end
    end
end
function ai_ksgj(play)
    startautoattack(play)
end

--------------------切换地图触发-------------------
function entermap(play)
    local dt = getbaseinfo(play,3)
    if getplaydef(play,"S$dtm") ~= dt then
        sendluamsg(play,101,1002,0,0,getmapname(dt))
    end
end

--------------------死亡物品掉了-------------------
function checkdropuseitems(play,item_wz,item_id,bool)
    local zb_dx = linkbodyitem(play,item_wz)
    local dt = getbaseinfo(play, 3)
    if dt == "阵营对抗" or dt == "跨服阵营对抗" or dt == "武林盟主" then
        return false
    end
    if getitemaddvalue(play,zb_dx,2,1) ~= 0 then
        delitembymakeindex(play,getiteminfo(play,zb_dx,1))
    end
end

--------------------角色扔掉任意物品前触发-------------------
function dropitemfrontex(play,item,itemName)
    if getitemaddvalue(play,item,2,1) ~= 0  then
        delitembymakeindex(play,getiteminfo(play,item,1))
        return false
    end
end

--------------------拾取前触发-------------------
function pickupitemfrontex(play, item)
    if getflagstatus(play,VarCfg.BS_mztq) == 0 then
        setitemaddvalue(play,item,2,1,850)
    end
end

--------------------进背包触发-------------------
function addbag(play, item)
end

--------------------捡物品触发-------------------
function pickupitemex(play, item)
    local idx = getiteminfo(play, item, 2)
    local chuli = json2tbl(getplaydef(play, VarCfg.T_rwwp)) --任务物品
    local name = getiteminfo(play,item,7)
    if chuli[name] then
        local rwid = chuli[name][1] --任务ID\
        if getbagitemcount(play,name) >= chuli[name][2] then
            --rwcf.wpjian(play,name)
            chuli[name] = nil
            if not constant.rw_syb[rwid] then
                messagebox(play,"所需材料已找到,立即前往NPC提交","@moni_dj_rw,"..rwid,"@exit")
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
                    messagebox(play,"所需材料已找到,立即前往NPC提交","@moni_dj_rw,"..rwid,"@exit")
                end
                -- 调用newpicktask函数，并将sj表中的元素作为参数传入
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
                -- 调用newpicktask函数，并将sj表中的元素作为参数传入
                newchangetask(play, rwid,unpack(sl))
                if clwc then
                    if constant.rw_syb[rwid].jwpjc then
                        messagebox(play,"所需物品已找到任务完成")
                        Player.zxrw_wancheng(play, rwid, "")
                    else
                        messagebox(play,"所需材料已找到,立即前往NPC提交","@moni_dj_rw,"..rwid,"@exit")
                    end
                end
            end
        end
    end
	if idx > 10010 and idx < 10019 then    --经验丹
        local sl = getiteminfo(play, item, 5)
        changeexp(play, '+', getstditeminfo(idx, 8) * sl, false)
        delitembymakeindex(play, getiteminfo(play, item, 1), sl)
    elseif idx > 10018 and idx < 10023 then    --元宝
        local sl = getiteminfo(play, item, 5)
        changemoney(play, getflagstatus(play,VarCfg.BS_mztq) == 1 and 1 or 3, '+', getstditeminfo(idx, 8) * sl, '捡物自动吃', true)
        delitembymakeindex(play, getiteminfo(play, item, 1), sl)
    elseif idx > 10022 and idx < 10034 then    --灵符
        local sl = getiteminfo(play, item, 5)
        changemoney(play, getflagstatus(play,VarCfg.BS_mztq) == 1 and 2 or 4, '+', getstditeminfo(idx, 8) * sl, '捡物自动吃', true)
        delitembymakeindex(play, getiteminfo(play, item, 1), sl)
    end
    --进背包动画
    setpickitemtobag(play,"200","101")
end
--------------------穿戴前触发-------------------
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
--------------------穿套装触发-------------------idx为套装ID
function groupitemonex(play,idx)
end
--------------------脱套装触发-------------------
function groupitemoffex(play,idx)
end
--------------------穿戴后触发-------------------
function takeonex(play, item, where, Name, makeindex)
	Buff.chuan(play, item)
    if where == 14 then
        changemoney(play,16,"=",1,"登录复活",true)
    end
end
--------------------脱下后触发-------------------
function takeoffex(play, item, where, Name, makeindex)
	Buff.tuo(play, item)
    if where == 14 then
        changemoney(play,16,"=",0,"登录复活",true)
    end
end


--------------------攻击前触发-------------------
function attackdamage(play, Target, Hiter, MagicId, Damage,Model)
	if getbaseinfo(Target, -1) then
		local bl = getplaydef(play, VarCfg.S_buffgjq)
		local data = json2tbl(bl == '' and {} or bl)
		local ew = 0
		for k, v in pairs(data) do
			local sy = tonumber(k)
			if sy and Buff[sy] then
				ew = ew + (Buff[sy](play, 3, Damage, Target, MagicId,Model) or 0)
			end
		end
		bl = getplaydef(play, VarCfg.S_buffrwq)
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
            --攻击造成与对方巅峰等级差值*10%的伤害
            local dfdj_damage = math.floor(Damage * ((play_dfdj - Target_dfdj) / 10) / 100)
            if dfdj_damage > 0 then
                Damage = Damage + dfdj_damage
            end
        end
		return Damage
	else
        local js = getbaseinfo(Target, 18)
        if js > 0 then
            Damage = Damage - (Damage * js/10000)
        end
        ---------------------------------------------对怪切割计算
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
						else
							humanhp(Target, '-', sy, 102, 0, play, 1)
							return Damage
						end
					end
				else
					humanhp(Target, '-', sy, math.random(100) > 10 and 101 or 112, 0, play, 1)
					return Damage
				end
			else
				return zd
			end
		end
        ---------------------------------------------通用攻击前触发模块，怪有效
		local bl = getplaydef(play, VarCfg.S_buffgjq)
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
		bl = getplaydef(play, VarCfg.S_buffgwq)
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
		return Damage
	end
end
--------------------攻击后触发-------------------
function attack(play, Target, Hiter, MagicId)
    local gs
	if getbaseinfo(Target, -1) then
		gs = math.floor(getbaseinfo(play, 51, 201) / 100)
	else
		gs = math.floor(getbaseinfo(play, 51, 200) / 100)
	end
	if getplaydef(play, VarCfg.N_dqgs) ~= gs then
		local sj = os.time()
		if sj - getplaydef(play, VarCfg.N_gscd) > 0 then
			setplaydef(play, VarCfg.N_gscd, sj)
			setplaydef(play, VarCfg.N_dqgs, gs)
			callscriptex(play, 'changespeedex', 2, gs)
			sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>当前攻击速度+' .. gs .. '%</font>","Type":9}')
		end
	end
	local bl = getplaydef(play, VarCfg.S_buffgjh)
	local data = json2tbl(bl == '' and {} or bl)
	for k, v in pairs(data) do
		local sy = tonumber(k)
		if sy then
			Buff[sy](play, 3, 0, Target, MagicId)
		end
	end
	if getbaseinfo(Target, -1) then
		bl = getplaydef(play, VarCfg.S_buffrwh)
		data = json2tbl(bl == '' and {} or bl)
		for k, v in pairs(data) do
			local sy = tonumber(k)
			if sy then
				Buff[sy](play, 3, 0, Target, MagicId)
			end
		end
        setplaydef(play,"N$战斗状态",os.time()+3)
	else
        bl = getplaydef(play, VarCfg.S_buffgwh)
        data = json2tbl(bl == '' and {} or bl)
        for k, v in pairs(data) do
            local sy = tonumber(k)
            if sy and Buff[sy] then
                Buff[sy](play, 3, 0, Target, MagicId)
            end
        end
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

--------------------被攻击前触发-------------------
function struckdamage(play, Hiter, Target, MagicId, Damage)
	if hasbuff(play, 20033) and MagicId > 0 then
		return 0
	end
	local bl = getplaydef(play, VarCfg.S_buffbgjq)
	local data = json2tbl(bl == '' and {} or bl)
	local ew = 0
	for k, v in pairs(data) do
		local sy = tonumber(k)
		if sy then
			ew = ew + (Buff[sy](play, 3, Damage, Hiter, MagicId) or 0)
		end
	end

    if getbaseinfo(Hiter, -1) then
		bl = getplaydef(play, VarCfg.S_buffbrwq)
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
            --收到伤害减免与对方巅峰等级差值*10%
            local dfdj_damage = math.floor(Damage * ((play_dfdj - Target_dfdj) / 10) / 100)
            if dfdj_damage > 0 then
                Damage = Damage - dfdj_damage
            end
        end
	else
		bl = getplaydef(play, VarCfg.S_buffbgwq)
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
    return (Damage + ew + xi) > 0 and (Damage + ew + xi) or 1
end
--------------------被攻击后触发-------------------
function struck(play, Hiter, Target, MagicId)
    if getbaseinfo(Hiter, -1) then
        setplaydef(play,"N$战斗状态",os.time()+3)
    end
end

--------------------杀怪触发-------------------
function killmon(play, mob)
    local bl = getplaydef(play, VarCfg.S_buffsgcf)
	local data = json2tbl(bl == "" and {} or bl)
	for k, v in pairs(data) do
		local sy = tonumber(k)
		if sy then
			Buff[sy](play, 3, mob)
		end
	end
	bl = getplaydef(play, VarCfg.T_sgcf)
	data = json2tbl(bl == "" and {} or bl)
	for k, v in pairs(data) do
        if shaguai[k] then
            shaguai[k](play, mob)
        end
	end
    ---每日杀怪数量
    local gw_name = getbaseinfo(mob,1)
    if guaiwutype[gw_name] and guaiwutype[gw_name] >= 1 then
        setplaydef(play,VarCfg.J_jsgw[1],getplaydef(play,VarCfg.J_jsgw[1])+1)
    else
        setplaydef(play,VarCfg.J_jsgw[2],getplaydef(play,VarCfg.J_jsgw[2])+1)
    end
    local dt = getbaseinfo(play, 3)
    if dt ~= "xtc" then
        local mz = getbaseinfo(mob, 1, 1)
        if guaiwutype[mz] and daluditu[dt] then
            local bianshi = getbaseinfo(play, 51, 207)
            if bianshi > 0 then
                if math.random(10000) <= bianshi then
                    sendmsg(play,1,'{"Msg":"<font color=\'#00ff00\'>[鞭尸]</font>触发鞭尸['..mz..']","FColor":253,"BColor":255,"Type":9}')
                    local guaiwu = genmonex(getbaseinfo(play, 3), getbaseinfo(play, 4), getbaseinfo(play, 5), mz, 1, 1, play, 254, mz .. "[鞭尸]", 0)
                    for _, v in pairs(guaiwu) do
                        humanhp(v, "=", 1)
                    end
                end
            end
        end
    end
end


--------------------货币改变触发-------------------元宝
function moneychange1(play)
    local gb = getplaydef(play,"N$元宝改变触发")
    if gb > 0 and Buff[gb] then
        Buff[gb](play, 1)
    end
end
--------------------货币改变触发-------------------灵符
function moneychange2(play)
    local gb = getplaydef(play,"N$灵符改变触发")
    if gb > 0 and Buff[gb] then
        Buff[gb](play, 1)
    end
end

--------------------货币改变触发-------------------复活
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
--------------------人物前复活触发-------------------
function nextdie(play)
end
--------------------人物后复活触发-------------------
function revival(play)
	local bl = getplaydef(play, VarCfg.S_bufffuhuo)
	local data = json2tbl(bl == '' and {} or bl)
	for k, v in pairs(data) do
		local sy = tonumber(k)
		if sy then
			Buff[sy](play, 4)
		end
	end
    if querymoney(play,15) > 0 then
        changemoney(play,15,"-",1,"复活",true)
        if not hasbuff(play,20078) then
            addbuff(play,20078,180)
        end
    else
        addbuff(play,20060,getbaseinfo(play,44))
    end
end
--------------------杀死玩家触发-------------------
function killplay(play,hiter)
    setplaydef(play,VarCfg.U_srsl,getplaydef(play,VarCfg.U_srsl)+1)
    login_fhsx(play)
end
--------------------玩家死亡触发-------------------
function playdie(play, hiter)
    local dt,x,y = getbaseinfo(play,3),getbaseinfo(play,4),getbaseinfo(play,5)
    sendmail("#" .. getbaseinfo(play, 1), 1, "系统提示", "您被["..getbaseinfo(hiter, 1).."]在"..getbaseinfo(play,45).."("..x.."."..y..")杀害了...")
    setplaydef(play,VarCfg.U_bssl,getplaydef(play,VarCfg.U_bssl)+1)
    if not castleinfo(5) and dt ~= "比武大会" and getbaseinfo(hiter,-1) and dt ~= "武林盟主" and dt ~= "阵营对抗" and not checkkuafu(play) then
        local U_dkb = getplaydef(play,VarCfg.U_dkb)
        if U_dkb > 0 then
            U_dkb = U_dkb - 1
            setplaydef(play,VarCfg.U_dkb,U_dkb)
            if U_dkb < 1 then
                Player.title_del(play, '究极狂暴')
                Buff[26](play, 2)
                seticon(play, 0, -1)
            end
            Login_msg(play, 4, hiter)
            changemoney(hiter, 3, '+', 1880000, '击杀狂暴', true)
        end
        if (checktitle(play,"狂暴之力") or checktitle(play,"狂暴之力[体验]")) and (checktitle(hiter,"狂暴之力") or checktitle(hiter,"狂暴之力[体验]")) then
            if checktitle(play,"狂暴之力") then
                Player.title_del(play, '狂暴之力')
                changemoney(hiter, 7, '+', 688, '击杀狂暴', true)
            else
                Player.title_del(play, "狂暴之力[体验]")
            end
            seticon(play, 0, -1)
            Login_msg(play, 4, hiter)
        end
    end

    if getbaseinfo(hiter,-1) then
        local cs = getplaydef(hiter,VarCfg.U_jskb) + 1
        setplaydef(hiter,VarCfg.U_jskb,cs)
    end
    showprogressbardlg(play,5,"@yc_fuhuo_hc","复活中..", 0,"@yc_fuhuo_hc")
end
--------------------跳转回城复活-------------------
function yc_fuhuo_hc(play)
    mapmove(play, 'xtc', 137,138,8)
    realive(play)
    addhpper(play, '=', 100)
    addmpper(play, '=', 100)
    delaygoto(play, 2000, "ai_qhdt", 0)
end
--------------------人物升级触发-------------------
function playlevelup(play)

end

--------------------属性改变触发-------------------
function sendability(play)
    local sd = math.floor(getbaseinfo(play,51,243) / 4)
    if getplaydef(play,"N$移动速度加成") ~= sd then
        setplaydef(play,"N$移动速度加成",sd)
        callscriptex(play, 'changespeedex', 1, sd)
    end
    Player.updata_zdl(play)
end

local czlb_je = {18,38,68,128,288,588,888,1188,1588,1888}
--------------------真充积分改变触发-------------------在线充值礼包筛选
function moneychange22(play)
    local lb_json,hbsl,jezz = json2tbl(getplaydef(play, VarCfg.T_czlb)),querymoney(play,22),0
    for i = 1, 10, 1 do
        if not lb_json["cz"..i] then
            if jezz + czlb_je[i] <= hbsl then
                jezz = jezz + czlb_je[i]
                lb_json["cz" .. i] = true
                setplaydef(play, VarCfg.T_czlb, tbl2json(lb_json))
                setplaydef(play,VarCfg.N_lbyz,1)
                czlb_pz(play,i)
            else
                break
            end
        end
    end
    if jezz > 0 then
        changemoney(play,22,"-",jezz,"礼包积分",true)
    end
end

function czlb_pz(play,sy)
    sy = tonumber(sy)
    local lb_json = json2tbl(getplaydef(play, VarCfg.T_czlb))
    if getplaydef(play,VarCfg.N_lbyz) == 1 then
        setplaydef(play,VarCfg.N_lbyz,0)
    end
end


--------------------累计充值改变触发-------------------冠名称号
function moneychange23(play)
    if querymoney(play,23) >= 998 and not checktitle(play,"踏月主宰") then
        messagebox(play,"累计充值数量已达到,可以去领取冠名奖励了")
    end
end


--------------------充值触发-------------------
function recharge(play, Gold, ProductId, MoneyId, isReal)
    release_print("充值触发","玩家："..getbaseinfo(play,1), "金额："..Gold, "订单:"..ProductId, "货币id:"..MoneyId, "是否真充:"..(isReal and "是" or "否"))
    setplaydef(play,VarCfg.J_zscz,(getplaydef(play,VarCfg.J_zscz) or 0) + Gold)

    if MoneyId == 7 then   ---仙玉充值
        local lb_json, sy = getplaydef(play, VarCfg.T_czlb), constant.cz_jeyz[Gold]
        lb_json = lb_json == "" and {} or json2tbl(lb_json)
        if constant.cz_jeyz[Gold] and getplaydef(play, VarCfg.U_czyz) == constant.cz_jeyz[Gold] and not lb_json["cz" .. sy] then
            setplaydef(play, VarCfg.U_czyz, 0)
            if not lb_json["cz" .. sy] then
                lb_json["cz" .. sy] = true
                setplaydef(play,VarCfg.T_czlb, tbl2json(lb_json))
                setplaydef(play,VarCfg.N_lbyz,1)
                czlb_pz(play,sy)
            end
        else
            changemoney(play,22,"+",Gold,"真充积分",true)
        end
        changemoney(play,20,"+",Gold,"平台累计充值",true)
        changemoney(play,8,"+",Gold*100,"充值送一倍",true)
        changemoney(play,23,"+",Gold,"累计充值",true)
        Login_msg(play,18,Gold,Gold*200)
    elseif MoneyId == 21 then  --直拉礼包
        changemoney(play,23,"+",Gold,"平台累计充值",true)
    elseif MoneyId == 24 then  -- 超级馈赠

    end
end
-------------------开始挂机触发--------------------
function startautoplaygame(play)
    sendmsg(play, 1, '{"BColor":69,"FColor":255,"Msg":"开启挂机","Type":1}')
    setflagstatus(play,300,1)
end
-------------------停止挂机触发--------------------
function stopautoplaygame(play)
    sendmsg(play, 1, '{"BColor":69,"FColor":255,"Msg":"停止挂机","Type":1}')
    setflagstatus(play,300,0)
end

--------------------延迟杀死宝宝触发-------------------
function qf_ssbaobao(play)
    local ncount = getbaseinfo(play,38)
    for i = 0 ,ncount-1 do
        local mob = getslavebyindex(play,i)
    end
end
function rw_exit(play)
    local json = getplaydef(play,VarCfg.S_sdlmjdt)
    if json ~= "" then
        json = json2tbl(json)
        mapmove(play,json.dt,json.xx,json.yy,3)
        setplaydef(play,VarCfg.S_sdlmjdt,"")
    else
        mapmove(play,"xtc",137,138)
    end
end

--------------------机器人触发脚本-------------------
function jqr_qingli() -- 每日0点清理
    if getsysvar(VarCfg["G_新区验证"]) == 0 then  -------是否有人验证
        return
    end
	setsysvar(VarCfg["G_开区天数"],getsysvar(VarCfg["G_开区天数"])+1)
end
--------------------机器人触发脚本-------------------沙巴克
function jqr_shabake()
    local hqcs = globalinfo(3)
    if hqcs > 0 then
        if getsysvar(VarCfg["G_合区次数对比"]) ~= hqcs then
            setsysvar(VarCfg["G_合区次数对比"],hqcs)
            repaircastle()
            addattacksabakall()
        end
    end
end

--------------------机器人触发脚本-------------------跨服沙巴克
function jqr_kfshabake()
    if checkkuafuserver() or checkkuafuconnect() then
        repaircastle()
        addattacksabakall()
    end
end
--------------------机器人触发脚本-------------------沙巴克发放通知
function jqr_kfshabakejltz()
    if castleinfo(5) then
        sendmovemsg("0", 1, 253, 0, 150, 5,"沙巴克攻城战：今日沙城战将于9点结束,奖励于攻城结束自动发放（跨服攻沙需要保证在跨服内）保持在线以免领取不到...")
    end
end

--------------------加入行会后触发-------------------
function guildaddmemberafter(play,guild,name)
end
--------------------退出行会后触发-------------------
function guilddelmember(play)
end

function updateguildnotice(play)
    stop(play)
    sendmsg(play,1,'{"Msg":"<font color=\'#00ff00\'>禁止修改行会通告</font>","Type":9}')
end
--点击采集
function collectmonex(play,monIDX,monName,monMakeIndex)
    showprogressbardlg(play,3,"@func_cjcg","采集中..", 1,"@func_cjsb")
    setplaydef(play,"S$采集目标",monMakeIndex)
    setplaydef(play,"N$iscaiji",1)
end
function func_cjcg(play)
    setplaydef(play,"N$iscaiji",0)
    callscriptex(play, "CAIJIBYPARAM", getplaydef(play,"S$采集目标"), 0)
end
function func_cjsb(play)
    release_print("func_2",getbaseinfo(play,1))
end

function playoffline(play)--人物大退触发
    if getconst(play,"<$SERVERNAME>") ~= "" and getbaseinfo(play,6) > 31 and getplaycountinmap(play,"xtc",0) < 200 then
        setofftimer(play,1)
        setofftimer(play,4)
        setofftimer(play,5)
        setofftimer(play,6)
        mapmove(play, 'xtc',137,138,8)
        offlineplay(play,9999)
    end
end
function playreconnection(play)--	人物小退触发
    if getconst(play,"<$SERVERNAME>") ~= "" and getbaseinfo(play,6) > 31 and getplaycountinmap(play,"xtc",0) < 200 then
        setofftimer(play,1)
        setofftimer(play,4)
        setofftimer(play,5)
        setofftimer(play,6)
        mapmove(play, 'xtc',137,138,8)
        offlineplay(play,9999)
    end
end

function kflogin(play)--	跨服服务器进入
    release_print("跨服服务器进入")
    setbaseinfo(play,57,0)
    addtocastlewarlistex(getguildinfo(getmyguild(play),1))
end


function kuafuend(play)--	退出跨服
    local szjl = json2tbl(getplaydef(play,VarCfg.T_szjl))
end

--------------------宠物攻击伤害前触发-------------------

function attackdamagebb(self,Target,Hiter,MagicId,Damage)
    return Damage
end

function canpaimaiitem(actor,itemIdx,itemMakeIndex,moneyType,price)
    if checkkuafu(actor) then
        sendmsg(actor, 1, '{"Msg":"<font color=\'#ff0000\'>跨服不能上架拍卖行！</font>","Type":9}')
        callscriptex(actor,"allowpaimai","1")
        return
    end
end

function biddingpaimaiitem(actor)
    if checkkuafu(actor) then
        sendmsg(actor,1, '{"Msg":"<font color=\'#ff0000\'>跨服不能使用拍卖行！</font>","Type":9}')
        callscriptex(actor,"allowpaimai","1")
        return
    end
end
function cangetbackpaimaiitem(actor)
    if checkkuafu(actor) then
        sendmsg(actor, 1, '{"Msg":"<font color=\'#ff0000\'>跨服不能使用拍卖行！</font>","Type":9}')
        callscriptex(actor,"allowpaimai","1")
        return
    end
end
function buypaimaiitem(actor,itemIdx,itemMakeIndex,moneyType,price)
    if checkkuafu(actor) then
        sendmsg(actor, 1, '{"Msg":"<font color=\'#ff0000\'>跨服不能使用拍卖行！</font>","Type":9}')
        callscriptex(actor,"allowpaimai","1")
        return
    end
end

--------------------怪物掉落物品触发--------------------
function mondropitemex(play,DropItem,mon,x,y)
    local dt = getbaseinfo(play,3)
     --2024-4-1 lxf  开服1400分钟以后  第一大陆不再掉落装备
     if getsysvar(VarCfg["G_开区分钟"]) > 1440 then
         local quming = getconst(play, '<$SERVERNAME>')
         if daluditu[dt] and daluditu[dt] == 1 and quming ~= "" and quming ~= "测试区" and quming ~= "直播区" then
             return false
         end
     end
    return true
end
--------------------切换称号触发--------------------
function titlechanged_1(play)
    seticon(play,1,-1)
end


function titlechanged_30405(play) seticon(play,1,1,30405,0,0,0,0,0) end
function untitled_30405(play) seticon(play,1,-1) end



--------------------聊天触发前置接口--------------------
function triggerchat(play,sMsg,chat,msgType)
    if getflagstatus(play,VarCfg.BS_sckg) == 0 then
        sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>领取首冲礼包才可以开启发言...</font>","FColor":219,"BColor":255,"Type":1}')
        return false
    end
    return true
end

--------------------拿沙开始触发--------------------
function castlewarstart()
    sendmovemsg("0", 1, 253, 0, 300, 2,"沙巴克攻城战：今日沙城战已开放，勇士们快快前往沙城传送了解详情，攻城时服务器不再刷新新的怪物，期间死亡不会掉落狂暴之力请保持在线以免领取不到...")
    sendmovemsg("0", 1, 249, 0, 250, 2,"沙巴克攻城战：今日沙城战已开放，勇士们快快前往沙城传送了解详情，攻城时服务器不再刷新新的怪物，期间死亡不会掉落狂暴之力请保持在线以免领取不到...")
end
---占领沙巴克触发
function getcastle0()
    sendmovemsg("0", 1, 253, 0, 300, 2,"沙巴克攻城战：【"..castleinfo(2).."】 行会成功夺得沙城...")
    release_print("沙巴克攻城战：【"..castleinfo(2).."】 行会成功夺得沙城...")
end

--------------------拿沙结束触发--------------------
function castlewarend()
    release_print("shabakejl")
    local player_list = getplayerlst()
    if checkkuafuserver() then
        kfbackcall(50,getbaseinfo(getplayerbyname(castleinfo(3)), 2),"恭喜你获得沙巴克战争中胜利方会长奖励，奖励已发放，请及时提取!",teshudata["sbk"][1][1])--玩家对象发送
    else
        if not checkkuafuconnect() then
            sendmail("#" .. castleinfo(3),0,"攻城奖励","恭喜你获得沙巴克战争中胜利方会长奖励，奖励已发放，请及时提取!",teshudata["sbk"][1][1])
        end
    end
    for _, player in ipairs(player_list or {}) do
        if castleidentity(player) > 0 then
            if checkkuafuserver() then
                kfbackcall(50,getbaseinfo(player, 2),"恭喜你获得沙巴克战争中胜利方奖励，奖励已发放，请及时提取!",teshudata["sbk"][2][1])  --玩家对象发送
            else
                if not checkkuafuconnect() then
                    if  getplaydef(player,VarCfg.J_isgs) == 1 then
                        sendmail(getbaseinfo(player,2),0,"攻城奖励","恭喜你获得沙巴克战争中胜利方奖励，奖励已发放，请及时提取!",teshudata["sbk"][2][1])
                    end
                end
            end
        elseif getmyguild(player) ~= "0" then
            if checkkuafuserver() then
                kfbackcall(50,getbaseinfo(player, 2),"恭喜你获得沙巴克战争中参与奖励，奖励已发放，请及时提取!",teshudata["sbk"][3][1])  --玩家对象发送
            else
                if not checkkuafuconnect() then
                    if  getplaydef(player,VarCfg.J_isgs) == 1 then
                        sendmail(getbaseinfo(player,2),0,"攻城奖励","恭喜你获得沙巴克战争奖励，奖励已发放，请及时提取!",teshudata["sbk"][3][1])
                    end
                end
            end
        end
    end
    sendmovemsg("0", 1, 253, 0, 300, 1,"沙巴克攻城战：今日沙城战已结束，所有奖励均已发放，请各位玩家及时领取...")
    sendmovemsg("0", 1, 249, 0, 250, 1,"沙巴克攻城战：今日沙城战已结束，所有奖励均已发放，请各位玩家及时领取...")
end


--------------------NPC点击触发--------------------
local qf_teshunpc = {

}
function clicknpc(play, npcid)
    --打印
    release_print("clicknpc", "玩家："..getbaseinfo(play,1), "npcid："..npcid)
	if qf_teshunpc[npcid] then
		Npclib[qf_teshunpc[npcid]].main(play, npcid)
		return true
    elseif npcid > 200 and npcid < 400 then--地图NPC
        Npclib[1].main(play, npcid)
        return true
	elseif npcid < 1000 then
		Npclib[npcid].main(play, npcid)
		return true
	end
	return false
end

-- 消息号 100，NPC点击事件，p1:NPCid,p2:按钮id,p3:额外,
--------------------消息监听触发--------------------
function handlerequest(play, msgID, p1, p2, p3, msgData)
    release_print("handlerequest", "玩家："..getbaseinfo(play,1), "消息id："..msgID, "npcid："..p1, "按钮2："..p2, "额外3："..p3, "消息数据："..msgData)
	if msgID == 100 then
        if qf_teshunpc[p1] then --可以无视距离点击npc
            Npclib[qf_teshunpc[p1]].link(play, p1, p2, p3, msgData)
        elseif p1 > 200 and p1 < 400 then --地图NPC
            Npclib[1].link(play, p1, p2)
        else
            local dx = getnpcbyindex(p1)
            if dx then
                if FCheckNPCRange(play, p1, 15) then
                    if qf_teshunpc[p1] then
                        Npclib[qf_teshunpc[p1]].link(play, p1, p2, p3, msgData)
                    elseif p1 < 1000 then
                        Npclib[p1].link(play, p1, p2, p3, msgData)
                    end
                end
            end
        end
	elseif msgID == 101 then
		Npclib['anniu'][p1](play, p2, p3, msgData)
    elseif msgID == 105 then
        if p1 > 200 and p1 < 400 then--地图NPC
            Npclib[1].main(play, p1, p2)
        else
            Npclib[p1].main(play, p2)
        end
	end
end