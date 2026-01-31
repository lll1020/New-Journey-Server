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
	["3"] = function(play,mob)      --开辟仙府
		local du = getbaseinfo(play,3)
		if daluditu[du] and daluditu[du] == 3 then
			local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
			sg_data["npc55"] = (sg_data["npc55"] or 0) + 1
			if sg_data["npc55"] >= 200 then
				shaguai.jian(play,3)
				messagebox(play,"任务完成,立即前往提交")
			end
			Player.sendmsgEx(play,  "开辟仙府#253|击杀怪物+"..1 .." ( "..sg_data["npc55"].."/200 )#57")
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
	["30"] = function(play,mob)      --灵根使者
		local du = getbaseinfo(play,3)
		if getbaseinfo(play,1).."_lgsz" == du then
			local T_dljq = Player.getJsonTableByVar(play, VarCfg.T_dljq)
			T_dljq["npc_602"] = T_dljq["npc_602"] or {}

			if getbaseinfo(mob,1) == "金灵根守护兽" and T_dljq["npc_602"][""..1] and T_dljq["npc_602"][""..1] == 0 then
				T_dljq["npc_602"][""..1] = 1
				Player.setJsonVarByTable(play, VarCfg.T_dljq, T_dljq)
				Player.sendmsgEx(play,  "成功击杀灵根守护兽#57")
				Npclib[602].link(play, 602, 2, 1, "")
			elseif getbaseinfo(mob,1) == "木灵根守护兽" and T_dljq["npc_602"][""..2] and T_dljq["npc_602"][""..2] == 0 then
				T_dljq["npc_602"][""..2] = 1
				Player.setJsonVarByTable(play, VarCfg.T_dljq, T_dljq)
				Player.sendmsgEx(play,  "成功击杀灵根守护兽#57")
				Npclib[602].link(play, 602, 2, 2, "")
			elseif getbaseinfo(mob,1) == "水灵根守护兽" and T_dljq["npc_602"][""..3] and T_dljq["npc_602"][""..3] == 0 then
				T_dljq["npc_602"][""..3] = 1
				Player.setJsonVarByTable(play, VarCfg.T_dljq, T_dljq)
				Player.sendmsgEx(play,  "成功击杀灵根守护兽#57")
				Npclib[602].link(play, 602, 2, 3, "")
			elseif getbaseinfo(mob,1) == "火灵根守护兽" and T_dljq["npc_602"][""..4] and T_dljq["npc_602"][""..4] == 0 then
				T_dljq["npc_602"][""..4] = 1
				Player.setJsonVarByTable(play, VarCfg.T_dljq, T_dljq)
				Player.sendmsgEx(play,  "成功击杀灵根守护兽#57")
				Npclib[602].link(play, 602, 2, 4, "")
			elseif getbaseinfo(mob,1) == "土灵根守护兽" and T_dljq["npc_602"][""..5] and T_dljq["npc_602"][""..5] == 0 then
				T_dljq["npc_602"][""..5] = 1
				Player.setJsonVarByTable(play, VarCfg.T_dljq, T_dljq)
				Player.sendmsgEx(play,  "成功击杀灵根守护兽#57")
				Npclib[602].link(play, 602, 2, 5, "")
			elseif getbaseinfo(mob,1) == "雷灵根守护兽" and T_dljq["npc_68"][""..1] and T_dljq["npc_68"][""..1] == 0 then
				T_dljq["npc_68"][""..1] = 1
				Player.setJsonVarByTable(play, VarCfg.T_dljq, T_dljq)
				Player.sendmsgEx(play,  "成功击杀灵根守护兽#57")
				Npclib[68].link(play, 68, 2, 1, "")
			elseif getbaseinfo(mob,1) == "风灵根守护兽" and T_dljq["npc_68"][""..2] and T_dljq["npc_68"][""..2] == 0 then
				T_dljq["npc_68"][""..2] = 1
				Player.setJsonVarByTable(play, VarCfg.T_dljq, T_dljq)
				Player.sendmsgEx(play,  "成功击杀灵根守护兽#57")
				Npclib[68].link(play, 68, 2, 2, "")
			elseif getbaseinfo(mob,1) == "冰灵根守护兽" and T_dljq["npc_68"][""..3] and T_dljq["npc_68"][""..3] == 0 then
				T_dljq["npc_68"][""..3] = 1
				Player.setJsonVarByTable(play, VarCfg.T_dljq, T_dljq)
				Player.sendmsgEx(play,  "成功击杀灵根守护兽#57")
				Npclib[68].link(play, 68, 2, 3, "")
			elseif getbaseinfo(mob,1) == "焚灵根守护兽" and T_dljq["npc_68"][""..4] and T_dljq["npc_68"][""..4] == 0 then
				T_dljq["npc_68"][""..4] = 1
				Player.setJsonVarByTable(play, VarCfg.T_dljq, T_dljq)
				Player.sendmsgEx(play,  "成功击杀灵根守护兽#57")
				Npclib[68].link(play, 68, 2, 4, "")
			elseif getbaseinfo(mob,1) == "岩灵根守护兽" and T_dljq["npc_68"][""..5] and T_dljq["npc_68"][""..5] == 0 then
				T_dljq["npc_68"][""..5] = 1
				Player.setJsonVarByTable(play, VarCfg.T_dljq, T_dljq)
				Player.sendmsgEx(play,  "成功击杀灵根守护兽#57")
				Npclib[68].link(play, 68, 2, 5, "")
			end
			
		end
	end,
	["603"] = function(play,mob)      --扫荡野火帮
		local config = teshudata["npc_603"]
		if not config then
			return
		end
		if config.map and getbaseinfo(play,3) ~= config.map then
			return
		end
		local mob_name = getbaseinfo(mob,1)
		if config.mob and config.mob ~= "" and mob_name ~= config.mob then
			return
		end
		local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
		local key = "npc_603"
		sg_data[key] = (sg_data[key] or 0) + 1
		if sg_data[key] >= (config.num or 0) then
			shaguai.jian(play,603)
			messagebox(play,"任务完成,立即前往提交")
		end
		Player.sendmsgEx(play,  (config.name or "任务").."击杀+"..1 .." ( "..sg_data[key].."/"..(config.num or 0).." )#57")
		Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
	end,
	["604"] = function(play,mob)      --剿灭恶徒
		local config = teshudata["npc_604"]
		if not config then
			return
		end
		if config.map and getbaseinfo(play,3) ~= config.map then
			return
		end
		local mob_name = getbaseinfo(mob,1)
		local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
		local key = "npc_604"
		local key_a = key.."_a"
		local key_b = key.."_b"
		local match_a = (mob_name == config.mob_a)
		local match_b = (mob_name == config.mob_b)
		if not match_a and not match_b then
			if (not config.mob_a or config.mob_a == "") and (not config.mob_b or config.mob_b == "") then
				if (sg_data[key_a] or 0) < (config.num_a or 0) then
					match_a = true
				else
					match_b = true
				end
			else
				return
			end
		end
		if match_a then
			sg_data[key_a] = (sg_data[key_a] or 0) + 1
		end
		if match_b then
			sg_data[key_b] = (sg_data[key_b] or 0) + 1
		end
		local a = sg_data[key_a] or 0
		local b = sg_data[key_b] or 0
		if a >= (config.num_a or 0) and b >= (config.num_b or 0) then
			shaguai.jian(play,604)
			messagebox(play,"任务完成,立即前往提交")
		end
		

		Player.sendmsgEx(play,  (config.name or "任务").."击杀寒霜狐/冰羽雀+"..1 .." ( "..a.."/"..(config.num_a or 0).." , "..b.."/"..(config.num_b or 0).." )#57")
		Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
	end,
	["605"] = function(play,mob)      --杀伐之路
		local config = teshudata["npc_605"]
		if not config then
			return
		end
		if config.map and getbaseinfo(play,3) ~= config.map then
			return
		end
		local mob_name = getbaseinfo(mob,1)
		if config.mob and config.mob ~= "" and mob_name ~= config.mob then
			return
		end
		local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
		local key = "npc_605"
		sg_data[key] = (sg_data[key] or 0) + 1
		if sg_data[key] >= (config.num or 0) then
			shaguai.jian(play,605)
			messagebox(play,"任务完成,立即前往提交")
		end
		Player.sendmsgEx(play,  (config.name or "任务").."击杀+"..1 .." ( "..sg_data[key].."/"..(config.num or 0).." )#57")
		Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
	end,
	["606"] = function(play,mob)      --讨伐夜魔
		local config = teshudata["npc_606"]
		if not config then
			return
		end
		if config.map and getbaseinfo(play,3) ~= config.map then
			return
		end
		local mob_name = getbaseinfo(mob,1)
		local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
		local key = "npc_606"
		local key_a = key.."_a"
		local key_b = key.."_b"
		local match_a = (mob_name == config.mob_a)
		local match_b = (mob_name == config.mob_b)
		if not match_a and not match_b then
			if (not config.mob_a or config.mob_a == "") and (not config.mob_b or config.mob_b == "") then
				if (sg_data[key_a] or 0) < (config.num_a or 0) then
					match_a = true
				else
					match_b = true
				end
			else
				return
			end
		end
		if match_a then
			sg_data[key_a] = (sg_data[key_a] or 0) + 1
		end
		if match_b then
			sg_data[key_b] = (sg_data[key_b] or 0) + 1
		end
		local a = sg_data[key_a] or 0
		local b = sg_data[key_b] or 0
		if a >= (config.num_a or 0) and b >= (config.num_b or 0) then
			shaguai.jian(play,606)
			messagebox(play,"任务完成,立即前往提交")
		end
	
		Player.sendmsgEx(play,  (config.name or "任务").."击杀夜蝠魇/地腔鼠+"..1 .." ( "..a.."/"..(config.num_a or 0).." , "..b.."/"..(config.num_b or 0).." )#57")
		Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
	end,
	["608"] = function(play,mob)      --守护森林
		local config = teshudata["npc_608"]
		if not config then
			return
		end
		if config.map and getbaseinfo(play,3) ~= config.map then
			return
		end
		local mob_name = getbaseinfo(mob,1)
		if config.mob and config.mob ~= "" and mob_name ~= config.mob then
			return
		end
		local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
		local key = "npc_608"
		sg_data[key] = (sg_data[key] or 0) + 1
		if sg_data[key] >= (config.num or 0) then
			shaguai.jian(play,608)
			messagebox(play,"任务完成,立即前往提交")
		end
		Player.sendmsgEx(play,  (config.name or "任务").."击杀+"..1 .." ( "..sg_data[key].."/"..(config.num or 0).." )#57")
		Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
	end,
	["621"] = function(play,mob)      --踏入·虚妄山脉
		local config = teshudata["npc_621"]
		if not config then
			return
		end
		if config.map and getbaseinfo(play,3) ~= config.map then
			return
		end
		local mob_name = getbaseinfo(mob,1)
		if config.mob and config.mob ~= "" and mob_name ~= config.mob then
			return
		end
		local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
		local key = "npc_621"
		sg_data[key] = (sg_data[key] or 0) + 1
		if sg_data[key] >= (config.num or 0) then
			shaguai.jian(play,621)
			messagebox(play,"任务完成,立即前往提交")
		end
		Player.sendmsgEx(play,  (config.name or "任务").."击杀+"..1 .." ( "..sg_data[key].."/"..(config.num or 0).." )#57")
		Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
	end,
	["622"] = function(play,mob)      --踏入·叹息旷野
		local config = teshudata["npc_622"]
		if not config then
			return
		end
		if config.map and getbaseinfo(play,3) ~= config.map then
			return
		end
		local mob_name = getbaseinfo(mob,1)
		if config.mob and config.mob ~= "" and mob_name ~= config.mob then
			return
		end
		local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
		local key = "npc_622"
		sg_data[key] = (sg_data[key] or 0) + 1
		if sg_data[key] >= (config.num or 0) then
			shaguai.jian(play,622)
			messagebox(play,"任务完成,立即前往提交")
		end
		Player.sendmsgEx(play,  (config.name or "任务").."击杀+"..1 .." ( "..sg_data[key].."/"..(config.num or 0).." )#57")
		Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
	end,
	["623"] = function(play,mob)      --踏入·鬼嘲深渊
		local config = teshudata["npc_623"]
		if not config then
			return
		end
		if config.map and getbaseinfo(play,3) ~= config.map then
			return
		end
		local mob_name = getbaseinfo(mob,1)
		if config.mob and config.mob ~= "" and mob_name ~= config.mob then
			return
		end
		local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
		local key = "npc_623"
		sg_data[key] = (sg_data[key] or 0) + 1
		if sg_data[key] >= (config.num or 0) then
			shaguai.jian(play,623)
			messagebox(play,"任务完成,立即前往提交")
		end
		Player.sendmsgEx(play,  (config.name or "任务").."击杀+"..1 .." ( "..sg_data[key].."/"..(config.num or 0).." )#57")
		Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
	end,
	["624"] = function(play,mob)      --踏入·禁忌之海
		local config = teshudata["npc_624"]
		if not config then
			return
		end
		if config.map and getbaseinfo(play,3) ~= config.map then
			return
		end
		local mob_name = getbaseinfo(mob,1)
		if config.mob and config.mob ~= "" and mob_name ~= config.mob then
			return
		end
		local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
		local key = "npc_624"
		sg_data[key] = (sg_data[key] or 0) + 1
		if sg_data[key] >= (config.num or 0) then
			shaguai.jian(play,624)
			messagebox(play,"任务完成,立即前往提交")
		end
		Player.sendmsgEx(play,  (config.name or "任务").."击杀+"..1 .." ( "..sg_data[key].."/"..(config.num or 0).." )#57")
		Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
	end,


	["645"] = function(play,mob)      --黄风大圣
		local config = teshudata["npc_645"]
		if not config then
			return
		end
		if config.map and getbaseinfo(play,3) ~= config.map then
			return
		end
		local mob_name = getbaseinfo(mob,1)
		if config.mob and config.mob ~= "" and mob_name ~= config.mob then
			return
		end
		local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
		local key = "npc_645"
		sg_data[key] = (sg_data[key] or 0) + 1
		if sg_data[key] >= (config.num or 0) then
			shaguai.jian(play,645)
			messagebox(play,"任务完成,立即前往提交")
		end
		Player.sendmsgEx(play,  (config.name or "任务").."击杀+"..1 .." ( "..sg_data[key].."/"..(config.num or 0).." )#57")
		Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
	end,
	["653"] = function(play,mob)      --天虎的游戏
		local config = teshudata["npc_653"]
		if not config then
			return
		end
		local ls_data = Player.getJsonTableByVar(play, VarCfg["T_灵兽"])
		if not ls_data or ls_data.dqzh ~= 4 then
			return
		end
		if config.map and getbaseinfo(play,3) ~= config.map then
			return
		end
		local mob_name = getbaseinfo(mob,1)
		if config.mob and config.mob ~= "" and mob_name ~= config.mob then
			return
		end
		local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
		local key = "npc_653"
		sg_data[key] = (sg_data[key] or 0) + 1
		if sg_data[key] >= (config.num or 0) then
			shaguai.jian(play,653)
			messagebox(play,"任务完成,立即前往提交")
		end
		Player.sendmsgEx(play,  (config.name or "任务").."击杀+"..1 .." ( "..sg_data[key].."/"..(config.num or 0).." )#57")
		Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
	end,
	["658"] = function(play,mob)      --天羊的游戏
		local config = teshudata["npc_658"]
		if not config then
			return
		end
		if config.map and getbaseinfo(play,3) ~= config.map then
			return
		end
		local mob_name = getbaseinfo(mob,1)
		if config.mob and config.mob ~= "" and mob_name ~= config.mob then
			return
		end
		local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
		local key = "npc_658"
		sg_data[key] = (sg_data[key] or 0) + 1
		if sg_data[key] >= (config.num or 0) then
			shaguai.jian(play,658)
			messagebox(play,"任务完成,立即前往提交")
		end
		Player.sendmsgEx(play,  (config.name or "任务").."击杀+"..1 .." ( "..sg_data[key].."/"..(config.num or 0).." )#57")
		Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
	end,
	["661"] = function(play,mob)      --天狗的游戏
		local config = teshudata["npc_661"]
		if not config then
			return
		end
		if config.map and getbaseinfo(play,3) ~= config.map then
			return
		end
		local mob_name = getbaseinfo(mob,1)
		if config.mob and config.mob ~= "" and mob_name ~= config.mob then
			return
		end
		local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
		local key = "npc_661"
		if not jq_data[key] or jq_data[key] ~= 1 then
			return
		end
		if jq_data[key.."_ok"] == 1 then
			return
		end
		local limit = config.time or 0
		local start = jq_data[key.."_st"] or 0
		if limit > 0 and (os.time() - start) > limit then
			return
		end
		local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
		sg_data[key] = (sg_data[key] or 0) + 1
		if sg_data[key] >= (config.num or 0) then
			jq_data[key.."_ok"] = 1
			Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
			shaguai.jian(play,661)
			messagebox(play,"任务完成,立即前往提交")
		end
		Player.sendmsgEx(play,  (config.name or "任务").."击杀+"..1 .." ( "..sg_data[key].."/"..(config.num or 0).." )#57")
		Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
	end,
	["666"] = function(play,mob)      --捉鬼人
		local config = teshudata["npc_666"]
		if not config then
			return
		end
		if config.map and getbaseinfo(play,3) ~= config.map then
			return
		end
		local mob_name = getbaseinfo(mob,1)
		if config.mob and config.mob ~= "" and mob_name ~= config.mob then
			return
		end
		local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
		local key = "npc_666"
		sg_data[key] = (sg_data[key] or 0) + 1
		if sg_data[key] >= (config.num or 0) then
			shaguai.jian(play,666)
			messagebox(play,"任务完成,立即前往提交")
		end
		Player.sendmsgEx(play,  (config.name or "任务").."击杀+"..1 .." ( "..sg_data[key].."/"..(config.num or 0).." )#57")
		Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
	end,
	["672"] = function(play,mob)      --轮回之路
		local config = teshudata["npc_672"]
		if not config then
			return
		end
		-- if config.map and getbaseinfo(play,3) ~= config.map then
		-- 	return
		-- end
		local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
		local mob_name = getbaseinfo(mob,1)
		local map = getbaseinfo(play,3)
		local key = "npc_672"
		local add_a, add_b, add_c = false, false, false
		if config.details then
			for _, v in ipairs(config.details) do
				if v.a_num and xilieditu[map] and xilieditu[map] == 2 then add_a = true end
				if v.b_num and map == "六道轮回" then add_b = true end
				if v.c_num and mob_name == "鸡" then add_c = true end
			end
		end
		if add_a then
			sg_data[key.."_a"] = (sg_data[key.."_a"] or 0) + 1
		end
		if add_b then
			sg_data[key.."_b"] = (sg_data[key.."_b"] or 0) + 1
		end
		if add_c then
			sg_data[key.."_c"] = (sg_data[key.."_c"] or 0) + 1
		end
		Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
	end,
	["676"] = function(play,mob)      --共公怒触不周山
		local config = teshudata["npc_676"]
		if not config then
			return
		end
		if config.map and getbaseinfo(play,3) ~= config.map then
			return
		end
		local mob_name = getbaseinfo(mob,1)
		if config.mob and config.mob ~= "" and mob_name ~= config.mob then
			return
		end
		local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
		local key = "npc_676"
		sg_data[key] = (sg_data[key] or 0) + 1
		if config.num and sg_data[key] >= config.num then
			shaguai.jian(play,676)
			messagebox(play,"击杀已达标,可前往提交")
		end
		Player.sendmsgEx(play,  (config.name or "任务").."击杀+"..1 .." ( "..sg_data[key].."/"..(config.num or 0).." )#57")
		Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
	end,
	["678"] = function(play,mob)      --后土娘娘
		local config = teshudata["npc_678"]
		if not config then
			return
		end
		local det = config.details and config.details[2]
		if not det then
			return
		end
		if det.map and getbaseinfo(play,3) ~= det.map then
			return
		end
		local mob_name = getbaseinfo(mob,1)
		if det.mob and det.mob ~= "" and mob_name ~= det.mob then
			return
		end
		local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
		local key = "npc_678"
		sg_data[key] = (sg_data[key] or 0) + 1
		if det.num and sg_data[key] >= det.num then
			shaguai.jian(play,678)
			messagebox(play,"击杀已达标,可前往提交")
		end
		Player.sendmsgEx(play,  (config.name or "任务").."击杀+"..1 .." ( "..sg_data[key].."/"..(det.num or 0).." )#57")
		Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
	end,
	["648"] = function(play,mob)      --大闹狮驼岭
		local config = teshudata["npc_648"]
		if not config then
			return
		end
		if config.map and getbaseinfo(play,3) ~= config.map then
			return
		end
		local mob_name = getbaseinfo(mob,1)
		local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
		local key = "npc_648"
		local key_a = key.."_a"
		local key_b = key.."_b"
		local key_c = key.."_c"
		local match_a = (mob_name == config.mob_a)
		local match_b = (mob_name == config.mob_b)
		local match_c = (mob_name == config.mob_c)
		if not match_a and not match_b and not match_c then
			if (not config.mob_a or config.mob_a == "") and (not config.mob_b or config.mob_b == "") and (not config.mob_c or config.mob_c == "") then
				if (sg_data[key_a] or 0) < (config.num_a or 0) then
					match_a = true
				elseif (sg_data[key_b] or 0) < (config.num_b or 0) then
					match_b = true
				else
					match_c = true
				end
			else
				return
			end
		end
		if match_a then
			sg_data[key_a] = (sg_data[key_a] or 0) + 1
		end
		if match_b then
			sg_data[key_b] = (sg_data[key_b] or 0) + 1
		end
		if match_c then
			sg_data[key_c] = (sg_data[key_c] or 0) + 1
		end
		local a = sg_data[key_a] or 0
		local b = sg_data[key_b] or 0
		local c = sg_data[key_c] or 0
		if a >= (config.num_a or 0) and b >= (config.num_b or 0) and c >= (config.num_c or 0) then
			shaguai.jian(play,648)
			messagebox(play,"任务完成,立即前往提交")
		end
		Player.sendmsgEx(play,  (config.name or "任务").."击杀+"..1 .." ( "..a.."/"..(config.num_a or 0).." , "..b.."/"..(config.num_b or 0).." , "..c.."/"..(config.num_c or 0).." )#57")
		Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
	end,
	["631"] = function(play,mob)      --谁是内鬼
		local config = teshudata["npc_631"]
		if not config then
			return
		end
		if config.map and getbaseinfo(play,3) ~= config.map then
			return
		end
		local mob_name = getbaseinfo(mob,1)
		if config.mob and config.mob ~= "" and mob_name ~= config.mob then
			return
		end
		local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
		local key = "npc_631"
		sg_data[key] = (sg_data[key] or 0) + 1
		if config.num and sg_data[key] >= config.num then
			shaguai.jian(play,631)
			messagebox(play,"击杀已达标,可前往提交")
		end
		Player.sendmsgEx(play,  (config.name or "任务").."击杀+"..1 .." ( "..sg_data[key].."/"..(config.num or 0).." )#57")
		Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
	end,
	["634"] = function(play,mob)      --杀戮的欲望(小怪)
		local config = teshudata["npc_634"]
		if not config then
			return
		end
		if config.map and getbaseinfo(play,3) ~= config.map then
			return
		end
		local mob_name = getbaseinfo(mob,1)
		if config.mob and config.mob ~= "" and mob_name ~= config.mob then
			return
		end
		local guai = getbaseinfo(mob,1)
		local guaitype = (guaiwutype[guai] or 0)
		if guaitype == 0 then
			local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
			local key = "npc_634"
			sg_data[key] = (sg_data[key] or 0) + 1
			if config.num and sg_data[key] >= config.num then
				shaguai.jian(play,634)
				messagebox(play,"击杀已达标,可前往提交")
			end
			Player.sendmsgEx(play,  (config.name or "任务").."击杀+"..1 .." ( "..sg_data[key].."/"..(config.num or 0).." )#57")
			Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
		end
		
	end,
	["635"] = function(play,mob)      --送葬者(BOSS)
		local config = teshudata["npc_635"]
		if not config then
			return
		end
		if config.map and getbaseinfo(play,3) ~= config.map then
			return
		end
		local mob_name = getbaseinfo(mob,1)
		if config.mob and config.mob ~= "" and mob_name ~= config.mob then
			return
		end
		local guai = getbaseinfo(mob,1)
		local guaitype = (guaiwutype[guai] or 0)
		if guaitype >= 1 then
			local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
			local key = "npc_635"
			sg_data[key] = (sg_data[key] or 0) + 1
			if config.num and sg_data[key] >= config.num then
				shaguai.jian(play,635)
				messagebox(play,"击杀已达标,可前往提交")
			end
			Player.sendmsgEx(play,  (config.name or "任务").."击杀+"..1 .." ( "..sg_data[key].."/"..(config.num or 0).." )#57")
			Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
		end
	end,
	["642"] = function(play,mob)      --资格考验
		local config = teshudata["npc_642"]
		if not config then
			return
		end
		if config.map and getbaseinfo(play,3) ~= config.map then
			return
		end
		local guai = getbaseinfo(mob,1)
		local guaitype = (guaiwutype[guai] or 0)
		local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
		local key = "npc_642"
		local key_a = key.."_a"
		local key_b = key.."_b"
		if guaitype == 2 then
			sg_data[key_b] = (sg_data[key_b] or 0) + 1
		else
			sg_data[key_a] = (sg_data[key_a] or 0) + 1
		end
		local a = sg_data[key_a] or 0
		local b = sg_data[key_b] or 0
		if a >= (config.num_a or 0) and b >= (config.num_b or 0) then
			shaguai.jian(play,642)
			messagebox(play,"任务完成,立即前往提交")
		end
		Player.sendmsgEx(play,  (config.name or "任务").."击杀小怪/首领+"..1 .." ( "..a.."/"..(config.num_a or 0).." , "..b.."/"..(config.num_b or 0).." )#57")
		Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
	end,
	["644"] = function(play,mob)      --我的袈裟！
		local config = teshudata["npc_644"]
		if not config then
			return
		end
		if config.map and getbaseinfo(play,3) ~= config.map then
			return
		end
		local mob_name = getbaseinfo(mob,1)
		if config.mob and config.mob ~= "" and mob_name ~= config.mob then
			return
		end
		local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
		local key = "npc_644"
		sg_data[key] = (sg_data[key] or 0) + 1
		if sg_data[key] >= (config.num or 0) then
			shaguai.jian(play,644)
			messagebox(play,"任务完成,立即前往提交")
		end
		Player.sendmsgEx(play,  (config.name or "任务").."击杀+"..1 .." ( "..sg_data[key].."/"..(config.num or 0).." )#57")
		Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
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








