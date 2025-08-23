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
local kfttxl = {
    1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100
}


--------------------引擎初始化--------------------
function startup()
    local qf_ditucanshu = dofile('Envir/Lua/Data/ditulianjie.lua')
    for k, v in pairs(qf_ditucanshu) do
        mapeffect('连接' .. k, v[1], v[2], v[3], 10297, 0, 0)
        if v[4] then
            mapeffect('名字' .. k, v[1], v[2], v[3], v[4], 0, 0)
        end
    end
    setontimerex(1, 60)
    --setontimerex(2, 1)

    if getmoncount("新手地图",1003,true) < 200 then
        genmon("新手地图",74,80,"恶狼",25,400,255)
    end
    if getmoncount("新手地图",1004,true) < 200 then
        genmon("新手地图",183,174,"山贼",25,400,255)
    end
end

--------------------新服活动刷怪表--------------------
local G_zydk = {0,0}
local A_kfdzdl = {}

--------------------人物初始化--------------------
function login(play)
    local quming = getconst(play, '<$SERVERNAME>')
    if callcheckscriptex(play,"ISDUMMY") then
        Login.main(play)
        setontimer(play, 10, 3)
    else
        if getsysvar(constant.G_kqfz) >= 1440 and linkbodyitem(play,71) == "0" then
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
--------------------跨天触发--------------------
function resetday(play)
	for _, v in pairs(constant.pz_ldql) do
		Player.title_del(play, v)
	end



end
-----------------全局1号60秒定时器----------------
function ontimerex1()
	if getsysvar(constant.G_kqyz) > 0 and not checkkuafuserver() then
		local dqfz = getsysvar(constant.G_kqfz) + 1
		setsysvar(constant.G_kqfz, dqfz)

	end

    if getmoncount("横断山脉",-1,true) < 100 then genmon("横断山脉",0,0,"裂地猿",500,100,250) genmon("横断山脉",0,0,"崩岩鬼",500,100,250) end
end


-----------------地图定时器----------------
function hd_tcppk(xx,ditu)
    if ditu == "xtc" then
        local wanjia = getobjectinmap("xtc",137,138,20,1)
        for k, v in pairs(wanjia) do
            if math.random(2) == 1 then
                local x, y = getbaseinfo(v, 4), getbaseinfo(v, 5)
                if getplaydef(v, "N$上次坐标x") ~= x and getplaydef(v, "N$上次坐标y") ~= y then
                    setplaydef(v, "N$上次坐标x", x)
                    setplaydef(v, "N$上次坐标y", y)
                    local wpmz = paokujl[math.random(#paokujl)]
                    sendmsg(v,1,'{"Msg":"<font color=\'#ff7700\'>[土城跑酷]</font><font color=\'#00ff00\'>恭喜你获得了['..wpmz..']...</font>","Type":9}')
                    sendmsg(v, 2, '{"BColor":249,"FColor":255,"Msg":"[土城跑酷]<font color=\'#00ff00\'>恭喜'..getbaseinfo(v, 1)..'获得了['..wpmz..']...</font>","Type":1}')
                    giveitem(v, wpmz,1,getflagstatus(v,constant.BS_mztq) == 0 and 0 or 850)
                end
            end
        end
    end
end

-----------------个人1号3秒定时器----------------一直开启
function ontimer1(play)
    --------------------------------------------------回收脚本
	if getbagblank(play) < 20 then -- 回收脚本
        Player.huishou(play)
	end
end

-----------------个人4号定时器----------------60秒定时器
function ontimer4(play)
    local zxsj = getplaydef(play, constant.U_fldt[1])
    setplaydef(play, constant.U_fldt[1], zxsj + 1)
    setplaydef(play, constant.J_zxsj,getplaydef(play, constant.J_zxsj) + 1)
end
-----------------个人5号定时器----------------1秒定时器AI挂机开启
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
                if getplaydef(play,"N$战斗状态") < os.time() and not getbaseinfo(play,0) then
                    map(play, getbaseinfo(play, 3))
                    setplaydef(play, constant.N_Aigj[2], os.time())
                    sendmsg(play, 1, '{"Msg":"<font color=\'#28ef01\'>AI挂机：120秒无怪自动随机</font>","Type":9}')
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
-----------------个人6号定时器---------------红点系统--60s
function ontimer6(play)
    --release_print("红点系统")
    --天上阁
    local ists = false



end

-----------------定时器----------------清空除魔  每天五点
function ql_smmrrw()

end

-----------------个人10号定时器----------------假人用-流程
function ontimer10(play)
    local dqlc = getplaydef(play,"N$当前流程")
    if dqlc == 0 then
        setplaydef(play,"N$当前流程",1)
        mapmove(play,"xtc",137,138,5)
    end
end
--------------------传送戒指传送前触发触发-------------------
function beginteleport(play)
    setplaydef(play,"S$dtm",getbaseinfo(play, 3))
    local lb_json,sj  = json2tbl(getplaydef(play,constant.T_czlb)),os.time()
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
                sendmsg(play, 1, '{"Msg":"<font color=\'#28ef01\'>AI挂机：已自动切换地图!</font>","Type":9}')
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
    if getitemaddvalue(play,zb_dx,2,1) ~= 0  then
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
    if getflagstatus(play,constant.BS_mztq) == 0 then
        setitemaddvalue(play,item,2,1,850)
    end
end

--------------------进背包触发-------------------
function addbag(play, item)

end

--------------------捡物品触发-------------------
function pickupitemex(play, item)
    local idx = getiteminfo(play, item, 2)
    local chuli = json2tbl(getplaydef(play, constant.T_rwwp)) --任务物品
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
        changemoney(play, getflagstatus(play,constant.BS_mztq) == 1 and 1 or 3, '+', getstditeminfo(idx, 8) * sl, '捡物自动吃', true)
        delitembymakeindex(play, getiteminfo(play, item, 1), sl)
    elseif idx > 10022 and idx < 10034 then    --灵符
        local sl = getiteminfo(play, item, 5)
        changemoney(play, getflagstatus(play,constant.BS_mztq) == 1 and 2 or 4, '+', getstditeminfo(idx, 8) * sl, '捡物自动吃', true)
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
            --攻击造成与对方巅峰等级差值*10%的伤害
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
                            --sendmsg(play,1,'{"Msg":"打怪伤害'..Damage..',切割'..qie..',增伤'..zeng..'","FColor":56,"BColor":255,"Type":1}')
						else
							humanhp(Target, '-', sy, 102, 0, play, 1)
                            --sendmsg(play,1,'{"Msg":"打怪伤害'..Damage..',切割'..qie..',增伤'..sy..'限伤","FColor":56,"BColor":255,"Type":1}')
							return Damage
						end
					end
				else
					humanhp(Target, '-', sy, math.random(100) > 10 and 101 or 112, 0, play, 1)
                    --sendmsg(play,1,'{"Msg":"打怪伤害'..Damage..',切割'..sy..',达限伤","FColor":56,"BColor":255,"Type":1}')
					return Damage
				end
			else
                --sendmsg(play,1,'{"Msg":"打怪伤害'..Damage..'限制'..zd..',达限伤","FColor":56,"BColor":255,"Type":1}')
				return zd
			end
		end
        ---------------------------------------------通用攻击前触发模块，怪有效
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
--------------------攻击后触发-------------------
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
			sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>当前攻击速度+' .. gs .. '%</font>","Type":9}')
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
        setplaydef(play,"N$战斗状态",os.time()+3)
	else
        bl = getplaydef(play, constant.S_buffgwh)
        data = json2tbl(bl == '' and {} or bl)
        for k, v in pairs(data) do
            local sy = tonumber(k)
            if sy and Buff[sy] then
                Buff[sy](play, 3, 0, Target, MagicId)
            end
        end
        --setplaydef(play,"N$战斗状态",os.time() + 1)
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
            --收到伤害减免与对方巅峰等级差值*10%
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
--------------------被攻击后触发-------------------
function struck(play, Hiter, Target, MagicId)
    if getbaseinfo(Hiter, -1) then
        setplaydef(play,"N$战斗状态",os.time()+3)
    end
end
--------------------对目标使用技能触发-------------------野蛮
function magtagfunc27(play, Target)

end
--------------------对目标使用技能触发-------------------开天
function magtagfunc66(play, Target)
end
--------------------对目标使用技能触发-------------------十步一杀
function magselffunc82(play)

end
--------------------对目标使用技能触发-------------------施毒术
function magtagfunc6(play, Target)

end
--------------------对目标使用技能触发-------------------隐身术
function magselffunc18(play, Target)
end

function magselffunc26(play) ---烈火

end
function magselffunc66(play) ---开天

end
function magselffunc56(play) ---逐日

end

--------------------杀怪触发-------------------
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
    ---每日杀怪数量
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
	local bl = getplaydef(play, constant.S_bufffuhuo)
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
    setplaydef(play,constant.U_srsl,getplaydef(play,constant.U_srsl)+1)
    login_fhsx(play)
end
--------------------玩家死亡触发-------------------
function playdie(play, hiter)
    local dt,x,y = getbaseinfo(play,3),getbaseinfo(play,4),getbaseinfo(play,5)
    sendmail("#" .. getbaseinfo(play, 1), 1, "系统提示", "您被["..getbaseinfo(hiter, 1).."]在"..getbaseinfo(play,45).."("..x.."."..y..")杀害了...")
    setplaydef(play,constant.U_bssl,getplaydef(play,constant.U_bssl)+1)
    if not castleinfo(5) and dt ~= "比武大会" and getbaseinfo(hiter,-1) and dt ~= "武林盟主" and dt ~= "阵营对抗" and not checkkuafu(play) then
        local U_dkb = getplaydef(play,constant.U_dkb)
        if U_dkb > 0 then
            U_dkb = U_dkb - 1
            setplaydef(play,constant.U_dkb,U_dkb)
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
        local cs = getplaydef(hiter,constant.U_jskb) + 1
        setplaydef(hiter,constant.U_jskb,cs)
    end
    say(play,[[<Img|id=ui_1|x=0|y=0|width=500|height=300|img=wy\public\fuhuo_bj.png|bg=1|move=1|reset=1|show=4|loadDelay=1>
                            <Text|id=ui_6|a=4|x=264|y=84|color=255|size=18|text=你被【]]..getconst(play,"<$CURRRTARGETNAME>")..[[】杀死了，是否要复活？>
                            <Button|id=ui_8|x=69|y=226|width=145|height=40|nimg=wy\public\fuhuo_1.png|color=251|size=16|link=@yc_fuhuo_hc>
                            <Button|id=ui_9|x=298|y=226|width=145|height=40|nimg=wy\public\fuhuo_2.png|color=251|size=16|link=@yc_fuhuo_yd>
                            <Text|id=ui_12|x=384|y=175|color=250|size=16|text=(剩余]]..(getbagitemcount(play,"复活丹"))..[[枚)>
                            <COUNTDOWN|id=ui_14|a=0|x=168|y=176|time=30|color=249|size=18|count=1|link=@yc_fuhuo_hc>
                            ]])

end
--------------------跳转回城复活-------------------
function yc_fuhuo_hc(play)
    mapmove(play, 'xtc', 137,138,8)
    realive(play)
    addhpper(play, '=', 100)
    addmpper(play, '=', 100)
    delaygoto(play, 2000, "ai_qhdt", 0)
end
--------------------点击原地复活-------------------
function yc_fuhuo_yd(play)
    local cs = getplaydef(play, constant.J_mrfhw)
    if checkkuafu(play) then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>跨服地图不能使用复活丹!</font>","Type":9}')
        return
    end
    if string.find(getbaseinfo(play,3),"_") then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>副本地图不能使用复活丹!</font>","Type":9}')
        return
    end
    if cs > 100 then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>今日使用复活丹次数已上限!</font>","Type":9}')
    else
        if getbagitemcount(play,"复活丹") > 0 then
            takeitem(play,"复活丹",1)
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>复活丹生效已原地复活!</font>","Type":9}')
            realive(play)
            addhpper(play, '=', 100)
            addmpper(play, '=', 100)
            close(play)
        else
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>你背包里没有复活丹!</font>","Type":9}')
        end
    end
end
--------------------跳转原地复活-------------------
function yc_fuhuo_mx(play)
	realive(play)
	addhpper(play, '=', 100)
	addmpper(play, '=', 100)
end

--------------------人物升级触发-------------------
function playlevelup(play)
    if getbaseinfo(play, 6) == 150 then
        sendluamsg(play, 101, 0, 17, 1,"")
    end
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
--------------------爆率监听触发-------------------经验丹
function bl_zyjhl1(play)
    return true
end
--------------------爆率监听触发-------------------幸运爆率
function bl_zyjhl2(play,mingzi)
    local sj = json2tbl(getplaydef(play,constant.T_xybl))
    if sj and not sj[mingzi] then
        sj[mingzi] = 1
        setplaydef(play,constant.T_xybl,tbl2json(sj))
        return true
    end
    return false
end


--------------------爆率监听触发-------------------实物回收掉落
function bl_zyjhl5(play,mingzi)
    if globalinfo(3) > 1 and daluditu[getbaseinfo(play,3)] and (daluditu[getbaseinfo(play,3)] < 3 and math.random(100) < 25) then
        return false
    end
    return true
end

local czlb_je = {18,38,68,128,288,588,888,1188,1588,1888}
--------------------真充积分改变触发-------------------在线充值礼包筛选
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
        changemoney(play,22,"-",jezz,"礼包积分",true)
    end
end

function czlb_pz(play,sy)
    sy = tonumber(sy)
    local lb_json = json2tbl(getplaydef(play, constant.T_czlb))
    if getplaydef(play,constant.N_lbyz) == 1 then
        setplaydef(play,constant.N_lbyz,0)
        if sy == 1 then
            setflagstatus(play,constant.BS_18cz,1)
            sendmail(getbaseinfo(play, 2), 0, "在线充值", "恭喜你成功获得18元充值奖励，请及时提取奖励",Player.jl_mail(teshudata[502].jl[sy].jl))
            if teshudata[502].jl[sy].ch then Player.title_give(play, teshudata[502].jl[sy].ch) end
        elseif sy == 2 then
            sendmail(getbaseinfo(play, 2), 0, "在线充值", "恭喜你成功获得38元充值奖励，请及时提取奖励",Player.jl_mail(teshudata[502].jl[sy].jl))
            if teshudata[502].jl[sy].ch then Player.title_give(play, teshudata[502].jl[sy].ch) end
        elseif sy == 3 then
            sendmail(getbaseinfo(play, 2), 0, "在线充值", "恭喜你成功获得68元充值奖励，请及时提取奖励",Player.jl_mail(teshudata[502].jl[sy].jl))
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
            sendmsg(play, 1, '{"Msg":"<font color=\'#00FF00\'>获得背包神器：'..teshudata[502].jl[sy].bbsq..'，可在【背包-背包神器】界面查看</font>","Type":9}')
        elseif sy == 4 then
            sendmail(getbaseinfo(play, 2), 0, "在线充值", "恭喜你成功获得128元充值奖励，请及时提取奖励",Player.jl_mail(teshudata[502].jl[sy].jl))
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

            sendmsg(play, 1, '{"Msg":"<font color=\'#00FF00\'>获得背包神器：'..teshudata[502].jl[sy].bbsq..'，可在【背包-背包神器】界面查看</font>","Type":9}')
        elseif sy == 5 then
            sendmail(getbaseinfo(play, 2), 0, "在线充值", "恭喜你成功获得288元充值奖励，请及时提取奖励",Player.jl_mail(teshudata[502].jl[sy].jl))
            local T_fb = json2tbl(getplaydef(play,constant.T_fb))
            T_fb[teshudata[502].jl[sy].fb] = 1
            setplaydef(play,constant.T_fb,tbl2json(T_fb))

            Player.updateSomeAddr(play, nil, fb[teshudata[502].jl[sy].fb].attr, 1)
            if fb[teshudata[502].jl[sy].fb].buff then
                Buff[fb[teshudata[502].jl[sy].fb].buff](play,1)
            end
            sendmsg(play, 1, '{"Msg":"<font color=\'#00FF00\'>获得禁器：'..teshudata[502].jl[sy].fb..'，可在【人物-禁器】界面查看</font>","Type":9}')
        elseif sy == 6 then
            sendmail(getbaseinfo(play, 2), 0, "在线充值", "恭喜你成功获得588元充值奖励，请及时提取奖励",Player.jl_mail(teshudata[502].jl[sy].jl))
            local sj = json2tbl(getplaydef(play,constant.T_szjl))
            sj["zj"] = sj["zj"] or {}
            sj["zj"][""..4] = 1
            setplaydef(play,constant.T_szjl,tbl2json(sj))
            Player.updateSomeAddr(play, nil, sz.zj[4].attr, 1)
            Buff[20195](play,1)
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff7700\'>[在线充值]</font><font color=\'#28ef01\'>获得足迹，可在仙姿【仙姿】界面切换</font>","Type":9}')
        elseif sy == 7 then
            sendmail(getbaseinfo(play, 2), 0, "在线充值", "恭喜你成功获得888元充值奖励，请及时提取奖励",Player.jl_mail(teshudata[502].jl[sy].jl))
            if teshudata[502].jl[sy].ch then Player.title_give(play, teshudata[502].jl[sy].ch) end
        elseif sy == 8 then
            sendmail(getbaseinfo(play, 2), 0, "在线充值", "恭喜你成功获得1188元充值奖励，请及时提取奖励",Player.jl_mail(teshudata[502].jl[sy].jl))
            local T_fb = json2tbl(getplaydef(play,constant.T_fb))
            T_fb[teshudata[502].jl[sy].fb] = 1
            setplaydef(play,constant.T_fb,tbl2json(T_fb))

            Player.updateSomeAddr(play, nil, fb[teshudata[502].jl[sy].fb].attr, 1)
            if fb[teshudata[502].jl[sy].fb].buff then
                Buff[fb[teshudata[502].jl[sy].fb].buff](play,1)
            end
        elseif sy == 9 then
            sendmail(getbaseinfo(play, 2), 0, "在线充值", "恭喜你成功获得1588元充值奖励，请及时提取奖励",Player.jl_mail(teshudata[502].jl[sy].jl))
            local T_bbsq = json2tbl(getplaydef(play,constant.T_bbsq))
            T_bbsq[teshudata[502].jl[sy].bbsq] = 1
            setplaydef(play,constant.T_bbsq,tbl2json(T_bbsq))

            if bbsq[teshudata[502].jl[sy].bbsq].attr then
                Player.updateSomeAddr(play,nil,bbsq[teshudata[502].jl[sy].bbsq].attr)
            end
            if bbsq[teshudata[502].jl[sy].bbsq].buff then
                Buff[bbsq[teshudata[502].jl[sy].bbsq].buff](play,1)
            end
            sendmsg(play, 1, '{"Msg":"<font color=\'#00FF00\'>获得背包神器：'..teshudata[502].jl[sy].bbsq..'，可在【背包-背包神器】界面查看</font>","Type":9}')
        elseif sy == 10 then
            sendmail(getbaseinfo(play, 2), 0, "在线充值", "恭喜你成功获得1888元充值奖励，请及时提取奖励",Player.jl_mail(teshudata[502].jl[sy].jl))
            if teshudata[502].jl[sy].ch then Player.title_give(play, teshudata[502].jl[sy].ch) end
        end
        if lb_json["cz1"] and lb_json["cz2"] and lb_json["cz3"] and lb_json["cz4"] and lb_json["cz5"] and lb_json["cz6"] then
            local sj = json2tbl(getplaydef(play,constant.T_szjl))
            sj["sz"] = sj["sz"] or {}
            if not lb_json.yijd then
                sj["sz"][""..7] = 1
                lb_json.yijd = true
                setplaydef(play, constant.T_czlb, tbl2json(lb_json))
                sendmail(getbaseinfo(play, 2), 0, "在线充值", "恭喜你成功获得充值奖励，请及时提取奖励",Player.jl_mail({wp = {{"灵之宝箱",100}}}))
                setplaydef(play,constant.T_szjl,tbl2json(sj))
                sendmsg(play, 1, '{"Msg":"<font color=\'#ff7700\'>[在线充值]</font><font color=\'#28ef01\'>获得时装，可在仙姿【仙姿】界面切换</font>","Type":9}')
            end
            if lb_json["cz7"] and lb_json["cz8"] and lb_json["cz9"] and lb_json["cz10"] and not lb_json.erjd then
                sendmail(getbaseinfo(play, 2), 0, "在线充值", "全部礼包激活奖励","皇图霸业一笑中#1#850&不胜人生一场醉#1#850")
                lb_json.erjd = true
                setplaydef(play, constant.T_czlb, tbl2json(lb_json))
            end
        end
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

    local T_tsg = json2tbl(getplaydef(play,constant.T_tsg))
    T_tsg["j_cz"] = (T_tsg["j_cz"] or 0) + Gold
    setplaydef(play,constant.T_tsg,tbl2json(T_tsg))

    if MoneyId == 7 then   ---仙玉充值
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
            changemoney(play,22,"+",Gold,"真充积分",true)
        end
        changemoney(play,20,"+",Gold,"平台累计充值",true)
        changemoney(play,8,"+",Gold*100,"充值送一倍",true)
        changemoney(play,23,"+",Gold,"累计充值",true)
        setplaydef(play,constant.J_zscz,(getplaydef(play,constant.J_zscz) or 0) + Gold)

        Login_msg(play,18,Gold,Gold*200)

        if getflagstatus(play,constant.BS_sckg) == 0 and querymoney(play,20) >= 10 then
            sendluamsg(play, 101, 501, 0, 0,getflagstatus(play,constant.BS_sckg))
        end


    elseif MoneyId == 21 then  --直拉礼包
        setplaydef(play,constant.J_zscz,(getplaydef(play,constant.J_zscz) or 0) + Gold)
        changemoney(play,23,"+",Gold,"平台累计充值",true)
        if Gold == 98 then -- 每日礼包
            local J_mrlb = getplaydef(play,constant.J_mrlb)
            if J_mrlb < 1 then
                J_mrlb = J_mrlb + 1
                setplaydef(play,constant.J_mrlb,J_mrlb)

                local T_bbsq = json2tbl(getplaydef(play,constant.T_bbsq))
                if T_bbsq["一念·神魔"] then
                    if T_bbsq["一念·神魔"] < 30 then
                        T_bbsq["一念·神魔"] = T_bbsq["一念·神魔"] + 1
                        Player.updateSomeAddr(play,nil, {bbsq["一念·神魔"].other_attr[T_bbsq["一念·神魔"]]})

                        local attr = {}
                        for vv,kk in ipairs(bbsq["一念·神魔"].attr) do
                            if kk[1] < 20 then
                                table.insert(attr,{kk[1],kk[2]*0.1})
                            end
                        end
                        Player.updateSomeAddr(play,nil, attr)
                        if T_bbsq["一念·神魔"] == 4 then
                            local wpdx = linkbodyitem(play,73)
                            changecustomitemvalue(play,wpdx,1,"+",20,0) --攻上
                        elseif T_bbsq["一念·神魔"] == 5 then
                            local wpdx = linkbodyitem(play,73)
                            changecustomitemvalue(play,wpdx,0,"+",20,1) --生命
                        elseif T_bbsq["一念·神魔"] == 16 then
                            Player.qsx_give(play, 20, "", nil)
                        elseif T_bbsq["一念·神魔"] == 27 then
                            callscriptex(play, "CHANGELEVEL", "+", 5)
                        end
                    else
                        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>[天赏阁]</font><font color=\'#ff0500\'>一念·神魔已满级...</font>","Type":9}')
                        return
                    end
                else
                    T_bbsq["一念·神魔"] = 1
                    Player.updateSomeAddr(play,nil, bbsq["一念·神魔"].attr)
                end
                setplaydef(play,constant.T_bbsq,tbl2json(T_bbsq))

                Player.rwjl(play, teshudata[526].jl, "每日礼包",nil,1000)
                Player.title_give(play,teshudata[526].ch)
                addbuff(play, 19992)

                sendluamsg(play,101,526,0,getplaydef(play,constant.J_mrlb),"")
            end
        end
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
    local json = getplaydef(play,constant.S_sdlmjdt)
    if json ~= "" then
        json = json2tbl(json)
        mapmove(play,json.dt,json.xx,json.yy,3)
        setplaydef(play,constant.S_sdlmjdt,"")
    else
        mapmove(play,"xtc",137,138)
    end
end

--------------------机器人触发脚本-------------------
function jqr_qingli() -- 每日0点清理
    if getsysvar(constant.G_kqyz) == 0 then  -------是否有人验证
        return
    end
	setsysvar(constant.G_kqts,getsysvar(constant.G_kqts)+1)
end
--------------------机器人触发脚本-------------------沙巴克
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

--------------------机器人触发脚本-------------------沙巴克
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


--------------------buff自定义监听触发-------------------
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
--------------------buff监听触发-------------------
function buffchange(play, buffid, zid, lx)
	if buffid == 20060 then
        if lx == 4 then
            moneychange16(play)
        end
    elseif buffid == 20078 then
        if lx == 4 then
            if querymoney(play,15) < querymoney(play,14) then
                changemoney(play,15,"+",1,"倒计时结束",true)
            end
            if querymoney(play,15) < querymoney(play,14) then
                addbuff(play,20078,180)
            end
        end
	end
end







function usercmd1(play,mima)
    local zhid = tonumber(getconst(play,"<$USERACCOUNT>"))
    if constant.pz_htqx[zhid] or getconst(play, '<$SERVERNAME>') == "" or getconst(play, '<$SERVERNAME>') == "测试区" then
        if getconst(play, '<$SERVERNAME>') == "" then
            setplaydef(play,constant.S_houtaibf,"本地测试区")
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
                sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>['..mingz..']玩家不在线</font>","Type":9}')
            end
        else
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>未输入名字</font>","Type":9}')
        end
    end
end

function usercmd5(play)
    if getconst(play, '<$SERVERNAME>') == "" or getconst(play, '<$SERVERNAME>') == "审核区1区" or getconst(play, '<$SERVERNAME>') == "测试区" or getconst(play, '<$SERVERNAME>') == "直播区" then
        say(play,[[<Img|id=ui_1|x=0.0|y=-1.0|width=800|height=600|img=public/bg_npc_01.png|bg=1|esc=1|move=0|reset=1|show=0|scale9l=15|scale9r=15|scale9t=15|scale9b=15|loadDelay=1>
<Layout|id=ui_2|x=801.0|y=0.0|width=80|height=80|link=@exit>
<Button|id=ui_3|x=794|y=0.0|width=26|height=42|nimg=public/1900000510.png|pimg=public/1900000511.png|color=255|size=18|link=@exit>
	]])
    end
end
function zbzbei(play,id)
end

--------------------加入行会后触发-------------------
function guildaddmemberafter(play,guild,name)

end
function guilddelmember(play)

end
function updateguildnotice(play)
    stop(play)
    sendmsg(play,1,'{"Msg":"<font color=\'#00ff00\'>禁止修改行会通告</font>","Type":9}')
end


--------------------领取任务触发-------------------

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
--------------------模拟点击任务触发-------------------

function moni_dj_rw(actor, rwid) --模拟点击任务
    rwid = tonumber(rwid)
    if rwid < 500 and getplaydef(actor,constant.U_zxrw[1]) ~= rwid then
        return
    end
    clicknewtask(actor,rwid)
end
--------------------点击任务触发-------------------
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
        if constant.rw_syb[rwid].zbyz then --装备验证
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
                sendluamsg(play, 101, 0, 1, 1,'{"lx":1,"fx":1,"an":'..constant.rw_syb[rwid][2]..',"ms":"点击按钮"}')
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
            local chuli = json2tbl(getplaydef(play, constant.T_rwwp)) --任务物品
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
                        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>没有任务道具，请在本地图继续打怪吧...</font>","Type":9}')
                        startautoattack(play) --自动攻击
                    end
                end
            else
                if clwc then
                    mapmove(play,constant.rw_syb[rwid][3][1],constant.rw_syb[rwid][3][3],constant.rw_syb[rwid][3][4],1)
                    sendluamsg(play, 101, 0, 1, 1,'{"lx":2,"npcdt":"'..constant.rw_syb[rwid][3][1]..'","npcid":'..constant.rw_syb[rwid][3][2]..',"xx":'..constant.rw_syb[rwid][3][3]..',"yy":'..constant.rw_syb[rwid][3][4]..'}')
                else
                    if rwid == 2006 then
                        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>没有任务道具，请在打怪吧...</font>","Type":9}')
                        mapmove(play,constant.rw_syb[rwid][2][1],constant.rw_syb[rwid][2][2],constant.rw_syb[rwid][2][3],1)
                        startautoattack(play) --自动攻击
                        return
                    end
                    if dqdt == constant.rw_syb[rwid][3][1] then
                        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>没有任务道具，请在本地图继续打怪吧...</font>","Type":9}')
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
                    sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>未到达【'..constant.rw_syb[rwid][3]..'级】</font>","Type":9}')
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
        elseif lx == 50 then -- 除魔任务
            local dl,boss,xg = getplayvar(play,"除魔大陆"),getplayvar(play,"除魔大怪数量"),getplayvar(play,"除魔小怪数量")
            if boss < 50 or xg < 500 then
                sendmsg(play,1,'{"Msg":"<font color=\'#00ff00\'>还未完成完成除魔任务...</font>","Type":9}')
            else
                if constant.rw_syb[rwid][2] ~= getbaseinfo(play,3) then
                    mapmove(play,constant.rw_syb[rwid][2],constant.rw_syb[rwid][4],constant.rw_syb[rwid][5],3)
                end
                sendluamsg(play, 101, 0, 1, 1,'{"lx":2,"npcdt":"'..constant.rw_syb[rwid][2]..'","npcid":'..constant.rw_syb[rwid][3]..',"xx":'..constant.rw_syb[rwid][4]..',"yy":'..constant.rw_syb[rwid][5]..'}')
            end
        elseif lx == 99 then -- 新手礼包
            sendluamsg(play,101,28,0,getflagstatus(play,constant.BS_xslb),"")
        end
    end
end


--------------------删除任务触发-------------------
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
                navigation(play, 110, rwid+1, "点击继续任务")
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
        local chuli = json2tbl(getplaydef(play, constant.T_rwwp)) --任务物品
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
                        changemoney(play,v[1],"+",v[2],"任务奖励",true)
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
        setofftimer(play,2)
        setofftimer(play,3)
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
        setofftimer(play,2)
        setofftimer(play,3)
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
    local szjl = json2tbl(getplaydef(play,constant.T_szjl))
    setofftimer(play,7)
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
     if getsysvar(constant.G_kqfz) > 1440 then
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
    if getflagstatus(play,constant.BS_sckg) == 0 then
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
    release_print("kfshabakejs")
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
                    if  getplaydef(player,constant.J_isgs) == 1 then
                        sendmail(getbaseinfo(player,2),0,"攻城奖励","恭喜你获得沙巴克战争中胜利方奖励，奖励已发放，请及时提取!",teshudata["sbk"][2][1])
                    end
                end
            end
        elseif getmyguild(player) ~= "0" then
            if checkkuafuserver() then
                kfbackcall(50,getbaseinfo(player, 2),"恭喜你获得沙巴克战争中参与奖励，奖励已发放，请及时提取!",teshudata["sbk"][3][1])  --玩家对象发送
            else
                if not checkkuafuconnect() then
                    if  getplaydef(player,constant.J_isgs) == 1 then
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
local rwsg_gx = {}  -- 任务刷怪添加
local qf_teshunpc = {

}
function clicknpc(play, npcid)
    --打印
    release_print("clicknpc", "玩家："..getbaseinfo(play,1), "npcid："..npcid)
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

-- 消息号 100，NPC点击事件，p1:NPCid,p2:按钮id,p3:额外,
--------------------消息监听触发--------------------
function handlerequest(play, msgID, p1, p2, p3, msgData)
    release_print("handlerequest", "玩家："..getbaseinfo(play,1), "消息id："..msgID, "npcid："..p1, "按钮2："..p2, "额外3："..p3, "消息数据："..msgData)
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