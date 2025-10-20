shaguai = {
	["1"] = function(play,mob)      --任务1：杀怪任务
		if getbaseinfo(mob,1) == "恶狼" or true then
			local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
			sg_data["npc2"] = (sg_data["npc2"] or 0) + 1
			if sg_data["npc2"] >= 5 then
				shaguai.jian(play,1)
				messagebox(play,"任务完成,立即前往提交")
			end
			Player.sendmsgEx(play,  "击杀恶狼+"..1 .." ( "..sg_data["npc2"].."/5 )#57")
			Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
		end
	end,
	["2"] = function(play,mob)      --任务1：杀怪任务
		if getbaseinfo(mob,1) == "恶狼" or true then
			local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
			sg_data["npc4"] = (sg_data["npc4"] or 0) + 1
			if sg_data["npc4"] >= 5 then
				shaguai.jian(play,2)
				messagebox(play,"任务完成,立即前往提交")
			end
			Player.sendmsgEx(play,  "击杀怪物+"..1 .." ( "..sg_data["npc4"].."/5 )#57")
			Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
		end
	end,
	["24"] = function(play,mob)      --主线任务杀怪
		local rwdy,sgsl,dqdt = getplaydef(play,VarCfg.U_zxrw[1]),getplaydef(play,VarCfg.U_zxrw[2]),getbaseinfo(play,3)
		if constant.rw_syb[rwdy] and constant.rw_syb[rwdy].sg and constant.rw_syb[rwdy].sg[1] and constant.rw_syb[rwdy].sg[1][dqdt] then
			setplaydef(play,VarCfg.U_zxrw[2],sgsl+1)
			Player.sendmsgEx(play,  "击杀怪物+"..1 .." ( "..(sgsl+1).."/"..constant.rw_syb[rwdy].sg[2].." )#57")

			if sgsl+1 >= constant.rw_syb[rwdy].sg[2] then
				shaguai.jian(play,24)
				newdeletetask(play,rwdy)
				if not constant.rw_syb[rwdy].jl then
					messagebox(play,"当前任务已完成")
				end

				playeffect(play,4011,25,-50,1,0,0)
			else
				newchangetask(play,getplaydef(play,VarCfg.U_zxrw[1]),sgsl+1)
			end
		end
	end,
	["29"] = function(play,mob)      --除魔杀怪
		local dl,boss,xg = getplayvar(play,"除魔大陆"),getplayvar(play,"除魔大怪数量"),getplayvar(play,"除魔小怪数量")
		--检测怪物地图是否为目标大陆，检测怪物类型
		local du = getbaseinfo(play,3)
		if daluditu[du] and daluditu[du] == dl then
			local guai = getbaseinfo(mob,1)
			local guaitype = (guaiwutype[guai] or 0)
			if guaitype and guaitype == 1 then
				boss = 1 + (boss or 0)
				setplayvar(play,"HUMAN","除魔大怪数量",boss,1)
			else
				xg = 1 + (xg or 0)
				setplayvar(play,"HUMAN","除魔小怪数量",xg,1)
			end
			newchangetask(play, 1300,dl, boss < 50 and boss or 50,xg < 500 and xg or 500)
			if boss >= 50 and xg >= 500 then
				shaguai.jian(play,29)
				sendmsg(play,1,'{"Msg":"<font color=\'#00ff00\'>恭喜你完成除魔任务...</font>","Type":9}')
			end
		end
	end,
}


shaguai.jia = function(play, id)
	local chuli = json2tbl(getplaydef(play, VarCfg.T_sgcf))
	chuli["" .. id] = true
	setplaydef(play, VarCfg.T_sgcf, tbl2json(chuli))
end

shaguai.jian = function(play, id)
	local chuli = json2tbl(getplaydef(play, VarCfg.T_sgcf))
	chuli["" .. id] = nil
	setplaydef(play, VarCfg.T_sgcf, tbl2json(chuli))
end

return shaguai