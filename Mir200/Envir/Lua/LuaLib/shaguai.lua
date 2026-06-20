local COMBAT_STATE_SEC = 3
local function _mark_combat_state(play)
    if play then
        setplaydef(play, "N$战斗状态", os.time() + COMBAT_STATE_SEC)
    end
end
if GameEvent and EventCfg and EventCfg.onAttackDamageMonster and not rawget(_G, "__combat_state_attack_mon_event") then
    _G.__combat_state_attack_mon_event = true
    GameEvent.add(EventCfg.onAttackDamageMonster, function(play)
        _mark_combat_state(play)
    end, "combat_state_attack_mon")
end
local function _sg_color_text(text, color)
    local code = "#253"
    local c = string.lower(tostring(color or ""))
    if c == "#ff0000" or c == "#ff3030" or c == "red" then
        code = "#249"
    elseif c == "#f7f7de" or c == "#ffffff" or c == "white" then
        code = "#250"
    end
    return code .. "|" .. tostring(text or "")
end
local function _sg_kill_tip(play, title, cur, need, action)
    title = tostring(title or "任务")
    action = tostring(action or "击杀")
    cur = tostring(cur or 0)
    need = tostring(need or 0)
    Player.sendmsgEx(play,
        _sg_color_text(title .. action .. "+1", "#00ff00") ..
        _sg_color_text("（", "#f7f7de") ..
        _sg_color_text(cur, "#ff3030") ..
        _sg_color_text("/", "#f7f7de") ..
        _sg_color_text(need, "#00ff00") ..
        _sg_color_text("）", "#f7f7de"))
end
local function _sg_kill_multi_tip(play, title, action, content)
    Player.sendmsgEx(play,
        _sg_color_text(tostring(title or "任务") .. tostring(action or "击杀") .. "+1", "#00ff00") ..
        _sg_color_text("（", "#00ff00") ..
        tostring(content or "") ..
        _sg_color_text("）", "#00ff00"))
end
local _zxrw_story_kill_rwid = {
    [603] = 19,
    [608] = 25,
    [605] = 27,
    [606] = 31,
}
local function _zxrw_sync_story_kill_progress(play, taskId, cur, need)
    local rwid = _zxrw_story_kill_rwid[tonumber(taskId) or 0]
    if not rwid or (tonumber(getplaydef(play, VarCfg.U_zxrw[1]) or 0) or 0) ~= rwid then
        return
    end
    cur = tonumber(cur or 0) or 0
    need = tonumber(need or 0) or 0
    if need > 0 and cur > need then
        cur = need
    end
    newchangetask(play, rwid, cur)
end
-- 第五章击杀任务：计算当前轮次目标
local function _story5_kill_need(task_cfg, done_cnt)
	local step_need = tonumber(task_cfg.kill_per_step or 0) or 0
	if step_need > 0 then
		return step_need * (done_cnt + 1)
	end
	return tonumber(task_cfg.kill_count or 0) or 0
end
-- 第五章击杀任务：统一累计、达标提示、注销监听
local function _story5_kill_progress(play, mob, task_id)
	local key = "npc_" .. tostring(task_id)
	local wrap = teshudata[key]
	local task_cfg = wrap and wrap.task_cfg or nil
	if type(task_cfg) ~= "table" then
		return
	end
	local cur_map = getbaseinfo(play,3)
	if task_cfg.map and task_cfg.map ~= "" and task_cfg.map ~= cur_map then
		return
	end
	local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
	local state = tonumber(jq_data[key] or 0) or 0
	local done_cnt = tonumber(jq_data[key .. "_a"] or 0) or 0
	local max_num = tonumber(task_cfg.max_submit_times or task_cfg.max_reward_round or wrap.max_num or 1) or 1
	if max_num < 1 then
		max_num = 1
	end
	-- 只在任务已领取且未完成时累计击杀
	if state < 1 then
		return
	end
	if state >= 2 or done_cnt >= max_num then
		shaguai.jian(play, task_id)
		return
	end
	local need = _story5_kill_need(task_cfg, done_cnt)
	if need <= 0 then
		return
	end
	local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
	local cur = tonumber(sg_data[key] or 0) or 0
	if cur >= need then
		return
	end
	cur = cur + 1
	if cur > need then
		cur = need
	end
	sg_data[key] = cur
	Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
	_sg_kill_tip(play, (wrap.name or key), cur, need)
	if cur >= need then
		shaguai.jian(play, task_id)
		messagebox(play,"任务完成,立即前往提交")
	end
end
local function _sg_drop_record_get(play)
	local dropData = Player.getJsonTableByVar(play, VarCfg["T_物品掉落记录"])
	if type(dropData) ~= "table" then
		dropData = {}
	end
	return dropData
end
local function _sg_drop_record_save(play, dropData)
	Player.setJsonVarByTable(play, VarCfg["T_物品掉落记录"], dropData or {})
end
local function _sg_drop_record_inc(play, key)
	local dropData = _sg_drop_record_get(play)
	local cur = (tonumber(dropData[key] or 0) or 0) + 1
	dropData[key] = cur
	_sg_drop_record_save(play, dropData)
	return cur, dropData
end
local function _sg_drop_record_set(play, key, value, dropData)
	dropData = type(dropData) == "table" and dropData or _sg_drop_record_get(play)
	dropData[key] = tonumber(value) or 0
	_sg_drop_record_save(play, dropData)
end
local function _sg_can_count_common_mon(play, mob)
	if not play or not mob then
		return false
	end
	local mobName = tostring(getbaseinfo(mob,1) or "")
	if mobName == "" or mobName == "稻草人" then
		return false
	end
	return true
end
local function _sg_tb_state(play)
	local state = Player.getJsonTableByVar(play, VarCfg["T_聚宝盆"]) or {}
	return {
		rebuilt = tonumber(state.rebuilt or 0) or 0,
		task_started = tonumber(state.task_started or 0) or 0,
	}
end
local function _sg_xianfu_dan_is_active(play, varName)
	local expireAt = tonumber(getplaydef(play, varName) or 0) or 0
	return expireAt > os.time()
end
local function _sg_is_godstone_red_boss(mob)
	local mobName = tostring(getbaseinfo(mob, 1) or "")
	if mobName == "" then
		return false
	end
	return string.find(mobName, "★", 1, true) ~= nil
		or string.find(mobName, "≮", 1, true) ~= nil
		or string.find(mobName, "红", 1, true) ~= nil
end
local function _sg_is_kuafu_boss(mob)
	local mapName = tostring(getbaseinfo(mob, 3) or "")
	if mapName == "" then
		return false
	end
	return string.find(mapName, "跨服", 1, true) ~= nil
		or string.find(mapName, "kuafu", 1, true) ~= nil
end
local function _sg_record_killed_boss(play, mob)
	if not play or not mob then
		return
	end
	local mobName = tostring(getbaseinfo(mob, 1) or "")
	if mobName == "" then
		return
	end
	local mobType = tonumber((guaiwutype and guaiwutype[mobName]) or 0) or 0
	if mobType < 2 then
		return
	end
	local ok, data = pcall(json2tbl, getplaydef(play, "S$equip_killed_boss"))
	data = ok and type(data) == "table" and data or {}
	data[mobName] = true
	setplaydef(play, "S$equip_killed_boss", tbl2json(data))
end
shaguai = {
	["1"] = function(play,mob)      --任务1：杀怪任务
		if getbaseinfo(mob,1) == "恶狼" or true then
			local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
			sg_data["npc2"] = (sg_data["npc2"] or 0) + 1
			if sg_data["npc2"] >= 10 then
				shaguai.jian(play,1)
				messagebox(play,"任务完成,立即前往提交")
			end
			_sg_kill_tip(play, "恶狼", sg_data["npc2"], 10)
			Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
		end
	end,
	["2"] = function(play,mob)      --任务1：杀怪任务
		if getbaseinfo(mob,1) == "恶狼" or true then
			local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
			sg_data["npc4"] = (sg_data["npc4"] or 0) + 1
			if sg_data["npc4"] >= 10 then
				shaguai.jian(play,2)
				messagebox(play,"任务完成,立即前往提交")
			end
			_sg_kill_tip(play, "怪物", sg_data["npc4"], 10)
			Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
		end
	end,
	["3"] = function(play,mob)      --开辟仙府
		local du = getbaseinfo(play,3)
		if xilieditu[du] and xilieditu[du] == 3 then
			local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
			sg_data["npc_55"] = (sg_data["npc_55"] or 0) + 1
			if sg_data["npc_55"] >= 200 then
				shaguai.jian(play,3)
				-- messagebox(play,"任务完成,立即前往提交")
			end
			-- Player.sendmsgEx(play,  "开辟仙府#253|击杀怪物+"..1 .." ( "..sg_data["npc_55"].."/200 )#57")
			Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
		end
	end,
	["24"] = function(play,mob)      --主线任务杀怪
		local rwdy,sgsl,dqdt = getplaydef(play,VarCfg.U_zxrw[1]),getplaydef(play,VarCfg.U_zxrw[2]),getbaseinfo(play,3)
		if constant.rw_syb[rwdy] and constant.rw_syb[rwdy].sg and constant.rw_syb[rwdy].sg[1] and constant.rw_syb[rwdy].sg[1][dqdt] then
			setplaydef(play,VarCfg.U_zxrw[2],sgsl+1)
			-- Player.sendmsgEx(play,  "击杀怪物+"..1 .." ( "..(sgsl+1).."/"..constant.rw_syb[rwdy].sg[2].." )#57")
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
	["25"] = function(play,mob)      --天书杀意值：按天书等级与大陆限制
		-- 天书杀意值：按天书等级与大陆限制
		local ts_cfg = teshudata["npc_24"]
		if ts_cfg then
			local ts_data = Player.getJsonTableByVar(play, VarCfg["T_天书"])
			local ts_lv = ts_data and (ts_data.level or 0) or 0
			local jf = (ts_data.jf or 0)
			if ts_lv >= 0 then
				local allow = false
				local dl = daluditu[getbaseinfo(play,3)] or 0
				if jf >= 0 and jf <= 1000 then
					allow = true
				elseif jf >= 1001 and jf <= 6000 then
					allow = (dl >= 2)
				elseif jf >= 6001 and jf <= 16000 then
					allow = (dl >= 3)
				elseif jf >= 16001 and jf <= 36000 then
					allow = (dl >= 4)
				elseif jf >= 36001 and jf <= 130000 then
					allow = (dl >= 5)
				end
				-- if allow then
				-- 	local min_hp = 0
				-- 	if ts_cfg.kill_min_hp and dl and ts_cfg.kill_min_hp[dl] then
				-- 		min_hp = ts_cfg.kill_min_hp[dl]
				-- 	end
				-- 	if min_hp and min_hp > 0 then
				-- 		local monidx = tonumber(getbaseinfo(mob,2)) or 0
				-- 		if monidx > 0 then
				-- 			local mhp = tonumber(getmonbaseinfo(monidx, 4)) or 0
				-- 			if mhp < min_hp then
				-- 				allow = false
				-- 			end
				-- 		else
				-- 			allow = false
				-- 		end
				-- 	end
				-- end
				if allow then
					ts_data = type(ts_data) == "table" and ts_data or {}
					ts_data.level = tonumber(ts_data.level) or 0
					ts_data.jf = jf + 1
					ts_data.shaqi = tonumber(ts_data.shaqi) or 0
					local shaqiRate = tonumber(ts_cfg.shaqi_gain_rate) or 10
					local shaqiMax = tonumber(ts_cfg.shaqi_max) or 1000
					local changedShaqi = false
					if ts_data.shaqi < shaqiMax and math.random(100) <= shaqiRate then
						ts_data.shaqi = ts_data.shaqi + 1
						if ts_data.shaqi > shaqiMax then
							ts_data.shaqi = shaqiMax
						end
						changedShaqi = true
					end
					Player.setJsonVarByTable(play, VarCfg["T_天书"], ts_data)
					if changedShaqi and xianfa_refresh then
						xianfa_refresh(play)
					end
					if tianshu_refresh_item then
						tianshu_refresh_item(play, ts_data)
					else
						local itemobj = linkbodyitem(play, ts_cfg.where)
						if itemobj and itemobj ~= "0" then
							setcustomitemprogressbar(play, itemobj, 1, tbl2json({["cur"] = ts_data.jf}))
							refreshitem(play, itemobj)
						end
					end
				end
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
	["340"] = function(play,mob)      --古刹魔瓶：装备背包神器后，击杀怪物有5%概率累计1点打怪切割
		if not Player.hasEquipInArtifactSlot(play, "古刹魔瓶") then
			shaguai.jian(play,340)
			if Buff and Buff[340] then
				Buff[340](play, 2)
			end
			return
		end
		if math.random(100) > 5 then
			return
		end
		local stack = tonumber(getplaydef(play, "N$buff340_stack") or 0) or 0
		setplaydef(play, "N$buff340_stack", stack + 1)
		if Buff and Buff[340] then
			Buff[340](play, 1)
		end
	end,
	["564"] = function(play,mob)      --切割刀：30 元档位激活后，每杀 1 只怪累计 +1 切割，上限 88888
		if tonumber(getplaydef(play, "N$切割刀已激活") or 0) ~= 1 then
			shaguai.jian(play,564)
			if Buff and Buff[564] then
				Buff[564](play, 2)
			end
			return
		end
		local stack = tonumber(getplaydef(play, "N$切割刀累计切割") or 0) or 0
		if stack >= 88888 then
			return
		end
		stack = stack + 1
		if stack > 88888 then
			stack = 88888
		end
		setplaydef(play, "N$切割刀累计切割", stack)
		if Buff and Buff.refreshRechargeBlade then
			Buff.refreshRechargeBlade(play)
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
		_zxrw_sync_story_kill_progress(play, 603, sg_data[key], config.num)
		if sg_data[key] >= (config.num or 0) then
			shaguai.jian(play,603)
			messagebox(play,"任务完成,立即前往提交")
		end
		-- _sg_kill_tip(play, (config.name or "任务"), sg_data[key], (config.num or 0))
		Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
	end,
	-- ["604"] = function(play,mob)      --剿灭恶徒
		-- local config = teshudata["npc_604"]
		-- if not config then
			-- return
		-- end
		-- if config.map and getbaseinfo(play,3) ~= config.map then
			-- return
		-- end
		-- local mob_name = getbaseinfo(mob,1)
		-- local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
		-- local key = "npc_604"
		-- local key_a = key.."_a"
		-- local key_b = key.."_b"
		-- local match_a = (mob_name == config.mob_a)
		-- local match_b = (mob_name == config.mob_b)
		-- if not match_a and not match_b then
			-- if (not config.mob_a or config.mob_a == "") and (not config.mob_b or config.mob_b == "") then
				-- if (sg_data[key_a] or 0) < (config.num_a or 0) then
					-- match_a = true
				-- else
					-- match_b = true
				-- end
			-- else
				-- return
			-- end
		-- end
		-- if match_a then
			-- sg_data[key_a] = (sg_data[key_a] or 0) + 1
		-- end
		-- if match_b then
			-- sg_data[key_b] = (sg_data[key_b] or 0) + 1
		-- end
		-- local a = sg_data[key_a] or 0
		-- local b = sg_data[key_b] or 0
		-- if a >= (config.num_a or 0) and b >= (config.num_b or 0) then
			-- shaguai.jian(play,604)
			-- messagebox(play,"任务完成，请前往提交")
		-- end
		-- 
		-- Player.sendmsgEx(play,  (config.name or "任务").."：击杀寒霜狼/烈焰雀+"..1 .." ( "..a.."/"..(config.num_a or 0).." , "..b.."/"..(config.num_b or 0).." )#57")
		-- Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
	-- end,
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
		_zxrw_sync_story_kill_progress(play, 605, sg_data[key], config.num)
		if sg_data[key] >= (config.num or 0) then
			shaguai.jian(play,605)
			messagebox(play,"任务完成,立即前往提交")
		end
		-- _sg_kill_tip(play, (config.name or "任务"), sg_data[key], (config.num or 0))
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
		local guaitype = (guaiwutype[mob_name] or 0)
		if guaitype ~= (tonumber(config.mob_type or 1) or 1) then
			return
		end
		local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
		local key = "npc_606"
		sg_data[key] = (sg_data[key] or 0) + 1
		_zxrw_sync_story_kill_progress(play, 606, sg_data[key], config.num)
		if (sg_data[key] or 0) >= (config.num or 0) then
			shaguai.jian(play,606)
			messagebox(play,"任务完成,立即前往提交")
		end
		-- Player.sendmsgEx(play,  (config.name or "任务").."：击杀精英怪+"..1 .." ( "..(sg_data[key] or 0).."/"..(config.num or 0).." )#57")
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
		_zxrw_sync_story_kill_progress(play, 608, sg_data[key], config.num)
		if sg_data[key] >= (config.num or 0) then
			shaguai.jian(play,608)
			messagebox(play,"任务完成,立即前往提交")
		end
		-- _sg_kill_tip(play, (config.name or "任务"), sg_data[key], (config.num or 0))
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
		-- _sg_kill_tip(play, (config.name or "任务"), sg_data[key], (config.num or 0))
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
		-- _sg_kill_tip(play, (config.name or "任务"), sg_data[key], (config.num or 0))
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
		-- _sg_kill_tip(play, (config.name or "任务"), sg_data[key], (config.num or 0))
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
		-- _sg_kill_tip(play, (config.name or "任务"), sg_data[key], (config.num or 0))
		Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
	end,
	["625"] = function(play,mob)      --嘲天笑地
		local cfg = teshudata["npc_625"]
		local prep = cfg and cfg.prep_task or nil
		if not prep or getbaseinfo(play,3) ~= prep.map then
			return
		end
		local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
		if tonumber(jq_data["npc_625_rw"] or 0) ~= 1 then
			return
		end
		local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
		local key = "npc_625_rw"
		sg_data[key] = (sg_data[key] or 0) + 1
		if sg_data[key] >= (prep.need or 0) then
			shaguai.jian(play,625)
			messagebox(play,"任务完成,立即前往提交")
		end
		-- Player.sendmsgEx(play,  (prep.progress_name or "任务").."击杀+"..1 .." ( "..sg_data[key].."/"..(prep.need or 0).." )#57")
		Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
	end,
	["626"] = function(play,mob)      --净化宝石
		local cfg = teshudata["npc_626"]
		local prep = cfg and cfg.prep_task or nil
		if not prep or getbaseinfo(play,3) ~= prep.map then
			return
		end
		local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
		if tonumber(jq_data["npc_626_rw"] or 0) ~= 1 then
			return
		end
		local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
		local killKey = "npc_626_rw_kill"
		sg_data[killKey] = (sg_data[killKey] or 0) + 1
		local need = tonumber(prep.need or 0) or 0
		local cur = getbagitemcount(play, prep.item_name or "净化之泪")
		if cur < need and sg_data[killKey] % (prep.drop_every or 5) == 0 then
			giveitem(play, prep.item_name or "净化之泪", 1)
			cur = getbagitemcount(play, prep.item_name or "净化之泪")
			Player.sendmsgEx(play, (prep.item_name or "任务物品").."+1 ( "..cur.."/"..need.." )#57")
			if cur >= need then
				shaguai.jian(play,626)
				messagebox(play,"任务完成,立即前往提交")
			end
		end
		Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
	end,
	["627"] = function(play,mob)      --定身符
		local cfg = teshudata["npc_627"]
		local prep = cfg and cfg.prep_task or nil
		if not prep or getbaseinfo(play,3) ~= prep.map then
			return
		end
		local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
		if tonumber(jq_data["npc_627_rw"] or 0) ~= 1 then
			return
		end
		local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
		local killKey = "npc_627_rw_kill"
		sg_data[killKey] = (sg_data[killKey] or 0) + 1
		local need = tonumber(prep.need or 0) or 0
		local cur = getbagitemcount(play, prep.item_name or "定身符碎片")
		if cur < need and sg_data[killKey] % (prep.drop_every or 5) == 0 then
			giveitem(play, prep.item_name or "定身符碎片", 1)
			cur = getbagitemcount(play, prep.item_name or "定身符碎片")
			Player.sendmsgEx(play, (prep.item_name or "任务物品").."+1 ( "..cur.."/"..need.." )#57")
			if cur >= need then
				shaguai.jian(play,627)
				messagebox(play,"任务完成,立即前往提交")
			end
		end
		Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
	end,
	["628"] = function(play,mob)      --真视之眼
		local cfg = teshudata["npc_628"]
		local prep = cfg and cfg.prep_task or nil
		if not prep or getbaseinfo(play,3) ~= prep.map then
			return
		end
		local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
		if tonumber(jq_data["npc_628_rw"] or 0) ~= 1 then
			return
		end
		local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
		local killKey = "npc_628_rw_kill"
		sg_data[killKey] = (sg_data[killKey] or 0) + 1
		local curKill = tonumber(sg_data[killKey] or 0) or 0
		local leftName = prep.left_name or "真视之眼左"
		local rightName = prep.right_name or "真视之眼右"
		if curKill >= (prep.left_need or 15) and getbagitemcount(play, leftName) < 1 then
			giveitem(play, leftName, 1)
			Player.sendmsgEx(play, leftName.."已找到#57")
		end
		if curKill >= (prep.right_need or 35) and getbagitemcount(play, rightName) < 1 then
			giveitem(play, rightName, 1)
			Player.sendmsgEx(play, rightName.."已找到#57")
		end
		if getbagitemcount(play, leftName) >= 1 and getbagitemcount(play, rightName) >= 1 then
			shaguai.jian(play,628)
			messagebox(play,"任务完成,立即前往提交")
		end
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
		_sg_kill_tip(play, (config.name or "任务"), sg_data[key], (config.num or 0))
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
		_sg_kill_tip(play, (config.name or "任务"), sg_data[key], (config.num or 0))
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
		_sg_kill_tip(play, (config.name or "任务"), sg_data[key], (config.num or 0))
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
		_sg_kill_tip(play, (config.name or "任务"), sg_data[key], (config.num or 0))
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
		_sg_kill_tip(play, (config.name or "任务"), sg_data[key], (config.num or 0))
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
		_sg_kill_tip(play, (config.name or "任务"), sg_data[key], (config.num or 0))
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
		_sg_kill_tip(play, (config.name or "任务"), sg_data[key], (det.num or 0))
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
		_sg_kill_multi_tip(play, (config.name or "任务"), "击杀", _sg_color_text(a, "#ff3030") .. _sg_color_text("/"..(config.num_a or 0).."，", "#00ff00") .. _sg_color_text(b, "#ff3030") .. _sg_color_text("/"..(config.num_b or 0).."，", "#00ff00") .. _sg_color_text(c, "#ff3030") .. _sg_color_text("/"..(config.num_c or 0), "#00ff00"))
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
		_sg_kill_tip(play, (config.name or "任务"), sg_data[key], (config.num or 0))
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
			_sg_kill_tip(play, (config.name or "任务"), sg_data[key], (config.num or 0))
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
			_sg_kill_tip(play, (config.name or "任务"), sg_data[key], (config.num or 0))
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
		_sg_kill_multi_tip(play, (config.name or "任务"), "击杀小怪/首领", _sg_color_text(a, "#ff3030") .. _sg_color_text("/"..(config.num_a or 0).."，", "#00ff00") .. _sg_color_text(b, "#ff3030") .. _sg_color_text("/"..(config.num_b or 0), "#00ff00"))
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
		_sg_kill_tip(play, (config.name or "任务"), sg_data[key], (config.num or 0))
		Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
	end,
	["682"] = function(play,mob)      --第五章：灵兽奥秘
		_story5_kill_progress(play, mob, 682)
	end,
	["688"] = function(play,mob)      --第五章：时空之门（累计击杀，支持一次刷满600）
		local key = "npc_688"
		local wrap = teshudata[key]
		local task_cfg = wrap and wrap.task_cfg or nil
		if type(task_cfg) ~= "table" then
			return
		end
		local cur_map = getbaseinfo(play,3)
		if task_cfg.map and task_cfg.map ~= "" and task_cfg.map ~= cur_map then
			return
		end
		local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
		local state = tonumber(jq_data[key] or 0) or 0
		if state < 1 then
			return
		end
		if state >= 2 then
			shaguai.jian(play,688)
			return
		end
		local stage_cnt = 3
		if type(task_cfg.unlock_maps) == "table" and #task_cfg.unlock_maps > 0 then
			stage_cnt = #task_cfg.unlock_maps
		end
		local step_need = tonumber(task_cfg.kill_count or 0) or 0
		local need = step_need * stage_cnt
		if need <= 0 then
			return
		end
		local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
		local cur = tonumber(sg_data[key] or 0) or 0
		if cur >= need then
			shaguai.jian(play,688)
			return
		end
		cur = cur + 1
		if cur > need then
			cur = need
		end
		sg_data[key] = cur
		Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
		_sg_kill_tip(play, (wrap.name or key), cur, need)
		if cur >= need then
			shaguai.jian(play,688)
			messagebox(play,"累计击杀已达上限,可连续提交解锁地图")
		end
	end,
	["689"] = function(play,mob)      --第五章：禁墟之门（累计击杀，支持一次刷满800）
		local key = "npc_689"
		local wrap = teshudata[key]
		local task_cfg = wrap and wrap.task_cfg or nil
		if type(task_cfg) ~= "table" then
			return
		end
		local cur_map = getbaseinfo(play,3)
		if task_cfg.map and task_cfg.map ~= "" and task_cfg.map ~= cur_map then
			return
		end
		local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
		local state = tonumber(jq_data[key] or 0) or 0
		if state < 1 then
			return
		end
		if state >= 2 then
			shaguai.jian(play,689)
			return
		end
		local stage_cnt = 4
		if type(task_cfg.unlock_maps) == "table" and #task_cfg.unlock_maps > 0 then
			stage_cnt = #task_cfg.unlock_maps
		end
		local step_need = tonumber(task_cfg.kill_count or 0) or 0
		local need = step_need * stage_cnt
		if need <= 0 then
			return
		end
		local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
		local cur = tonumber(sg_data[key] or 0) or 0
		if cur >= need then
			shaguai.jian(play,689)
			return
		end
		cur = cur + 1
		if cur > need then
			cur = need
		end
		sg_data[key] = cur
		Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
		_sg_kill_tip(play, (wrap.name or key), cur, need)
		if cur >= need then
			shaguai.jian(play,689)
			messagebox(play,"累计击杀已达上限,可连续提交解锁地图")
		end
	end,
	["696"] = function(play,mob)      --第五章：神庙逃亡（每100杀推进一次）
		local key = "npc_696"
		local wrap = teshudata[key]
		local task_cfg = wrap and wrap.task_cfg or nil
		if type(task_cfg) ~= "table" then
			return
		end
		local req_map = task_cfg.map or "白骨神庙"
		if req_map ~= "" and getbaseinfo(play,3) ~= req_map then
			return
		end
		local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
		local state = tonumber(jq_data[key] or 0) or 0
		if state < 1 then
			return
		end
		if state >= 2 then
			shaguai.jian(play,696)
			return
		end
		local max_moves = tonumber(task_cfg.max_moves or task_cfg.max_reward_round or 4) or 4
		if max_moves < 1 then
			max_moves = 1
		end
		local moves = tonumber(jq_data["npc696_move"] or 0) or 0
		if moves >= max_moves then
			shaguai.jian(play,696)
			return
		end
		local kill_per = tonumber(task_cfg.kill_per_step or 100) or 100
		if kill_per < 1 then
			kill_per = 1
		end
		local total_need = kill_per * max_moves
		local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
		local cur = tonumber(sg_data[key] or 0) or 0
		if cur >= total_need then
			return
		end
		local prev = cur
		cur = cur + 1
		if cur > total_need then
			cur = total_need
		end
		sg_data[key] = cur
		Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
		local next_need = (moves + 1) * kill_per
		Player.sendmsgEx(play, _sg_color_text((wrap.name or key).."击杀+1（累计", "#00ff00") .. _sg_color_text(cur, "#ff3030") .. _sg_color_text("，下一步"..next_need.."）", "#00ff00"))
		if prev < next_need and cur >= next_need then
			messagebox(play,"神庙逃亡：可前进一次，请前往NPC操作")
		end
	end,
		["700"] = function(play,mob)      --第五章：赤焰试炼（三段：小怪/精英/BOSS）
		local key = "npc_700"
		local wrap = teshudata[key]
		local task_cfg = wrap and wrap.task_cfg or nil
		if type(task_cfg) ~= "table" then
			return
		end
		local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
		local state = tonumber(jq_data[key] or 0) or 0
		if state < 1 then
			return
		end
		if state >= 2 then
			shaguai.jian(play,700)
			return
		end
		local stages = task_cfg.trial_stages
		if type(stages) ~= "table" or #stages < 3 then
			stages = {
				{name = "一层试炼", map = "赤焰焚殿", mob_type = 0, need = 200},
				{name = "二层试炼", map = "赤焰焚殿二层", mob_type = 1, need = 50},
				{name = "三层试炼", map = "赤焰焚殿三层", mob_type = 2, need = 5},
			}
		end
		local function _k(i)
			local s = (i == 1 and "a") or (i == 2 and "b") or (i == 3 and "c") or tostring(i)
			return key .. "_" .. s
		end
		local function _need(st)
			local n = tonumber(st and st.need or 0) or 0
			if n < 1 then n = 1 end
			return n
		end
		local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
		local function _done(i)
			return (tonumber(sg_data[_k(i)] or 0) or 0) >= _need(stages[i])
		end
		local idx = 0
		for i = 1, #stages do
			if not _done(i) then
				idx = i
				break
			end
		end
		if idx <= 0 then
			shaguai.jian(play,700)
			messagebox(play,"三重试炼已完成，可前往NPC领取奖励")
			return
		end
		local st = stages[idx]
		local cur_map = getbaseinfo(play,3)
		if st.map and st.map ~= "" and st.map ~= cur_map then
			return
		end
		local mob_name = getbaseinfo(mob,1)
		local guaitype = (guaiwutype[mob_name] or 0)
		local need_type = tonumber(st.mob_type or 0) or 0
		if guaitype ~= need_type then
			return
		end
		local k = _k(idx)
		local need = _need(st)
		local cur = tonumber(sg_data[k] or 0) or 0
		if cur >= need then
			return
		end
		cur = cur + 1
		if cur > need then
			cur = need
		end
		sg_data[k] = cur
		Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
		_sg_kill_tip(play, (st.name or ("试炼"..idx)), cur, need)
		if cur >= need then
			if idx < #stages then
				local nx = stages[idx + 1]
				messagebox(play,(st.name or ("试炼"..idx)).."已完成，已开启"..(nx.name or ("试炼"..(idx+1))))
			else
				shaguai.jian(play,700)
				messagebox(play,"三重试炼已全部完成，可前往NPC领取奖励")
			end
		end
	end,
	["701"] = function(play,mob)      --第五章：葬天试炼
		_story5_kill_progress(play, mob, 701)
	end,
	["705"] = function(play,mob)      --第五章：是非难辨（击杀小怪+BOSS）
		local wrap = teshudata["npc_705"]
		local task_cfg = wrap and wrap.task_cfg or nil
		if type(task_cfg) ~= "table" then
			return
		end
		local cur_map = getbaseinfo(play,3)
		if task_cfg.map and task_cfg.map ~= "" and task_cfg.map ~= cur_map then
			return
		end
		local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
		local state = tonumber(jq_data["npc_705"] or 0) or 0
		if state < 1 then
			return
		end
		if state >= 2 then
			shaguai.jian(play,705)
			return
		end
		local mob_name = getbaseinfo(mob,1)
		local small = task_cfg.mob_small or task_cfg.mob
		local boss = task_cfg.mob_boss or task_cfg.boss
		local is_small = getbaseinfo(play,3) == wrap.task_cfg.map and guaiwutype[mob_name] <= 1
		local is_boss = getbaseinfo(play,3) == wrap.task_cfg.map and guaiwutype[mob_name] == 2
		if not is_small and not is_boss then
			return
		end
		local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
		local key_small = "npc_705_small"
		local key_boss = "npc_705_boss"
		local need_small = tonumber(task_cfg.kill_small or 0) or 0
		local need_boss = tonumber(task_cfg.kill_boss or 0) or 0
		if need_small < 0 then
			need_small = 0
		end
		if need_boss < 0 then
			need_boss = 0
		end
		local cur_small = tonumber(sg_data[key_small] or 0) or 0
		local cur_boss = tonumber(sg_data[key_boss] or 0) or 0
		local updated = false
		if is_small and need_small > 0 and cur_small < need_small then
			cur_small = cur_small + 1
			if cur_small > need_small then
				cur_small = need_small
			end
			sg_data[key_small] = cur_small
			updated = true
			_sg_kill_tip(play, (wrap.name or "npc_705").."击杀["..small.."]", cur_small, need_small, "")
		elseif is_boss and need_boss > 0 and cur_boss < need_boss then
			cur_boss = cur_boss + 1
			if cur_boss > need_boss then
				cur_boss = need_boss
			end
			sg_data[key_boss] = cur_boss
			updated = true
			_sg_kill_tip(play, (wrap.name or "npc_705").."击杀["..boss.."]", cur_boss, need_boss, "")
		end
		if updated then
			Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
		end
		if (need_small <= 0 or cur_small >= need_small) and (need_boss <= 0 or cur_boss >= need_boss) then
			shaguai.jian(play,705)
			messagebox(play,"任务完成,立即前往提交")
		end
	end,["709"] = function(play,mob)      --第五章：故人远行（使用酒壶召唤指定BOSS后击杀）
		local wrap = teshudata["npc_709"]
		local task_cfg = wrap and wrap.task_cfg or nil
		if type(task_cfg) ~= "table" then
			return
		end
		local req_map = task_cfg.map or "阳关道"
		if req_map ~= "" and getbaseinfo(play,3) ~= req_map then
			return
		end
		local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
		local state = tonumber(jq_data["npc_709"] or 0) or 0
		if state < 1 then
			return
		end
		if state >= 2 then
			shaguai.jian(play,709)
			return
		end
		if tonumber(jq_data["npc_709_b"] or 0) ~= 1 then
			return
		end
		local boss = task_cfg.boss
		if not boss or boss == "" or boss == "请配置709任务BOSS名" then
			return
		end
		if getbaseinfo(mob,1) ~= boss then
			return
		end
		local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
		local key = "npc_709"
		local need = tonumber(task_cfg.kill_count or 1) or 1
		if need < 1 then
			need = 1
		end
		local cur = tonumber(sg_data[key] or 0) or 0
		if cur >= need then
			shaguai.jian(play,709)
			return
		end
		cur = cur + 1
		if cur > need then
			cur = need
		end
		sg_data[key] = cur
		Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
		jq_data["npc_709_b"] = nil
		Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
		_sg_kill_tip(play, (wrap.name or key).."击杀["..boss.."]", cur, need, "")
		if cur >= need then
			shaguai.jian(play,709)
			messagebox(play,"任务完成,立即前往提交")
		end
	end,
	["714"] = function(play,mob)      --第五章：屠龙宝刀（击杀进度+地图掉落冰火龙鳞）
		local key = "npc_714"
		local wrap = teshudata[key]
		local task_cfg = wrap and wrap.task_cfg or nil
		if type(task_cfg) ~= "table" then
			return
		end
		local req_map = task_cfg.map or "冰火岛"
		if req_map ~= "" and getbaseinfo(play,3) ~= req_map then
			return
		end
		local mob_name = getbaseinfo(mob,1)
		-- 本地图打怪掉落冰火龙鳞（默认 1/1000）
		local drop_item = task_cfg.scale_item or "冰火龙鳞"
		local drop_rate = tonumber(task_cfg.scale_drop_rate or 1000) or 1000
		if drop_item ~= "" and drop_rate > 0 then
			if math.random(drop_rate) == 1 then
				shaguai.temp_drop(play, mob, drop_item)
			end
		end
		-- 任务击杀进度：可选只统计指定BOSS击杀（kill_boss）
		local need_boss = task_cfg.kill_boss or task_cfg.boss_mob
		if type(need_boss) == "string" and need_boss ~= "" then
			if need_boss == "BOSS" then
				if not string.find(mob_name or "", "BOSS", 1, true) then
					return
				end
			elseif mob_name ~= need_boss then
				return
			end
		elseif type(need_boss) == "table" then
			local _match = false
			for _, _name in ipairs(need_boss) do
				if mob_name == _name then
					_match = true
					break
				end
			end
			if not _match then
				return
			end
		end
		local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
		local state = tonumber(jq_data[key] or 0) or 0
		if state < 1 then
			return
		end
		if state >= 2 then
			return
		end
		local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
		local need = tonumber(task_cfg.kill_count or 10) or 10
		if need < 1 then
			need = 1
		end
		local cur = tonumber(sg_data[key] or 0) or 0
		if cur >= need then
			return
		end
		cur = cur + 1
		if cur > need then
			cur = need
		end
		sg_data[key] = cur
		Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
		_sg_kill_tip(play, (wrap.name or key), cur, need)
		if cur >= need then
			messagebox(play,"任务完成,立即前往提交")
		end
	end,
	["718"] = function(play,mob)      --第五章：景阳冈打虎（打怪掉落武松的酒）
		local key = "npc_718"
		local wrap = teshudata[key]
		local task_cfg = wrap and wrap.task_cfg or nil
		if type(task_cfg) ~= "table" then
			return
		end
		local req_map = task_cfg.map or "景阳冈"
		if req_map ~= "" and getbaseinfo(play,3) ~= req_map then
			return
		end
		local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
		local state = tonumber(jq_data[key] or 0) or 0
		if state < 1 then
			return
		end
		if state >= 2 then
			shaguai.jian(play,718)
			return
		end
		-- 掉落改为怪物爆率表处理，避免双倍掉落
		return
	end,
	["719"] = function(play,mob)      --第五章：血溅狮子楼（本图掉落净化水晶）
		local key = "npc_719"
		local wrap = teshudata[key]
		local task_cfg = wrap and wrap.task_cfg or nil
		if type(task_cfg) ~= "table" then
			return
		end
		local req_map = task_cfg.map or "狮子楼"
		if req_map ~= "" and getbaseinfo(play,3) ~= req_map then
			return
		end
		local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
		local state = tonumber(jq_data[key] or 0) or 0
		if state < 1 then
			return
		end
		if state >= 2 then
			shaguai.jian(play,719)
			return
		end
		local drop_item = task_cfg.drop_item or "净化水晶"
		local drop_rate = tonumber(task_cfg.drop_rate or 3000) or 3000
		if drop_item ~= "" and drop_rate > 0 and math.random(drop_rate) == 1 then
			shaguai.temp_drop(play, mob, drop_item)
			Player.sendmsgEx(play, "打怪掉落【"..drop_item.."】#57")
		end
	end,
	["721"] = function(play,mob)      -- story npc kill route
		local mod = dofile("Envir/Lua/Npc/721.lua")
		if mod and mod.link then
			mod.link(play, 721, 4, mob)
		end
	end,
	["722"] = function(play,mob)      -- story npc kill route
		local mod = dofile("Envir/Lua/Npc/722.lua")
		if mod and mod.link then
			mod.link(play, 722, 4, mob)
		end
	end,
	["723"] = function(play,mob)      -- story npc kill route
		local mod = dofile("Envir/Lua/Npc/723.lua")
		if mod and mod.link then
			mod.link(play, 723, 4, mob)
		end
	end,
	["724"] = function(play,mob)      -- story npc kill route
		local mod = dofile("Envir/Lua/Npc/724.lua")
		if mod and mod.link then
			mod.link(play, 724, 4, mob)
		end
	end,
	["725"] = function(play,mob)      -- story npc kill route
		local mod = dofile("Envir/Lua/Npc/725.lua")
		if mod and mod.link then
			mod.link(play, 725, 4, mob)
		end
	end,
	["726"] = function(play,mob)      -- story npc kill route
		local mod = dofile("Envir/Lua/Npc/726.lua")
		if mod and mod.link then
			mod.link(play, 726, 4, mob)
		end
	end,
	["728"] = function(play,mob)      -- story npc kill route
		local mod = dofile("Envir/Lua/Npc/728.lua")
		if mod and mod.link then
			mod.link(play, 728, 4, mob)
		end
	end,
	["729"] = function(play,mob)      -- story npc kill route
		local mod = dofile("Envir/Lua/Npc/729.lua")
		if mod and mod.link then
			mod.link(play, 729, 4, mob)
		end
	end,
	["730"] = function(play,mob)      -- story npc kill route
		local mod = dofile("Envir/Lua/Npc/730.lua")
		if mod and mod.link then
			mod.link(play, 730, 4, mob)
		end
	end,
	["731"] = function(play,mob)      -- story npc kill route
		local mod = dofile("Envir/Lua/Npc/731.lua")
		if mod and mod.link then
			mod.link(play, 731, 4, mob)
		end
	end,
	["732"] = function(play,mob)      -- story npc kill route
		local mod = dofile("Envir/Lua/Npc/732.lua")
		if mod and mod.link then
			mod.link(play, 732, 4, mob)
		end
	end,
	["733"] = function(play,mob)      -- story npc kill route
		local mod = dofile("Envir/Lua/Npc/733.lua")
		if mod and mod.link then
			mod.link(play, 733, 4, mob)
		end
	end,
	["734"] = function(play,mob)      -- story npc kill route
		local mod = dofile("Envir/Lua/Npc/734.lua")
		if mod and mod.link then
			mod.link(play, 734, 4, mob)
		end
	end,
	["735"] = function(play,mob)      -- story npc kill route
		local mod = dofile("Envir/Lua/Npc/735.lua")
		if mod and mod.link then
			mod.link(play, 735, 4, mob)
		end
	end,
	["736"] = function(play,mob)      -- story npc kill route
		local mod = dofile("Envir/Lua/Npc/736.lua")
		if mod and mod.link then
			mod.link(play, 736, 4, mob)
		end
	end,
	["737"] = function(play,mob)      -- story npc kill route
		local mod = dofile("Envir/Lua/Npc/737.lua")
		if mod and mod.link then
			mod.link(play, 737, 4, mob)
		end
	end,
	["738"] = function(play,mob)      -- story npc kill route
		local mod = dofile("Envir/Lua/Npc/738.lua")
		if mod and mod.link then
			mod.link(play, 738, 4, mob)
		end
	end,
	["739"] = function(play,mob)      -- story npc kill route
		local mod = dofile("Envir/Lua/Npc/739.lua")
		if mod and mod.link then
			mod.link(play, 739, 4, mob)
		end
	end,
	["740"] = function(play,mob)      -- story npc kill route
		local mod = dofile("Envir/Lua/Npc/740.lua")
		if mod and mod.link then
			mod.link(play, 740, 4, mob)
		end
	end,
	["33"] = function(play,mob)      --聚宝盆碎片：接到聚宝盆任务后，极光城郊怪物按 1/70 + 20 杀保底掉落
		
		-- local state = _sg_tb_state(play)
		-- if state.rebuilt >= 1 or state.task_started < 1 then
		-- 	return
		-- end
		if getbaseinfo(play,3) ~= "极光城郊" then
			return
		end
		local cfg = teshudata["npc_106"] or {}
		local itemName = tostring(cfg.fragment_item or "聚宝盆碎片")
		local needNum = tonumber(cfg.fragment_count or 20) or 20
		if getbagitemcount(play, itemName) >= needNum then
			return
		end
		local key = "kill_pity_聚宝盆碎片"
		local cur, dropData = _sg_drop_record_inc(play, key)
		local dropped = false
		if math.random(70) == 1 then
			dropped = shaguai.temp_drop(play, mob, itemName)
		elseif cur >= 20 then
			dropped = shaguai.temp_drop(play, mob, itemName)
		end
		if dropped then
			_sg_drop_record_set(play, key, 0, dropData)
			Player.sendmsgEx(play, "打怪掉落【"..itemName.."】#57")
		end
	end,
	["34"] = function(play,mob)      --筑基丹碎片：聚宝盆修复后，二三大陆普通怪每累计 100 只保底掉落
		local record = Player.getJsonTableByVar(play, "T39") or {}
		local jz_count = tonumber(record.jz_dan_count or 0) or 0
		if jz_count >= 3 then
			return
		end
		local mapName = tostring(getbaseinfo(play,3) or "")
		local dl = tonumber((daluditu and daluditu[mapName]) or 0) or 0
		if dl ~= 2 and dl ~= 3 then
			return
		end
		local key = "kill_pity_筑基丹碎片"
		local cur, dropData = _sg_drop_record_inc(play, key)
		if cur % 100 ~= 0 then
			return
		end
		if shaguai.temp_drop(play, mob, "筑基丹碎片") then
			_sg_drop_record_set(play, key, 0, dropData)
			Player.sendmsgEx(play, "打怪掉落【筑基丹碎片】#57")
		end
	end,
	["35"] = function(play,mob)      --修为丹独立掉落：不吃全局爆率，小丹二大陆起掉，大丹需真实充值大于 100
		local mapName = tostring(getbaseinfo(mob, 3) or "")
		local dl = tonumber((daluditu and daluditu[mapName]) or 0) or 0
		if dl < 2 then
			return
		end
		if math.random(100) == 1 then
			shaguai.temp_drop(play, mob, "修为丹（小）")
		end
		local realCharge = math.max(tonumber(querymoney(play, 23) or 0) or 0, tonumber(getplaydef(play, VarCfg["U_真实充值"]) or 0) or 0)
		if realCharge > 100 and math.random(1000) == 1 then
			shaguai.temp_drop(play, mob, "修为丹（大）")
		end
	end,
	["36"] = function(play,mob)      --神石宝箱：统一走 shaguai 杀怪掉落监听
		if not play or not mob then
			return
		end
		local mapName = tostring(getbaseinfo(play, 3) or "")
		local dl = tonumber((daluditu and daluditu[mapName]) or 0) or 0
		if dl < 3 then
			return
		end
		local mobName = tostring(getbaseinfo(mob, 1) or "")
		if mobName == "" or mobName == "稻草人" then
			return
		end
		local guaiType = tonumber((guaiwutype and guaiwutype[mobName]) or 0) or 0
		local isBoss = guaiType >= 2
		local isKuafuBoss = isBoss and _sg_is_kuafu_boss(mob)
		local isRedBoss = isBoss and _sg_is_godstone_red_boss(mob)
		local lowDanActive = _sg_xianfu_dan_is_active(play, "N$xf_dan_low_expire")
		if isKuafuBoss then
			shaguai.temp_drop(play, mob, "神石宝箱")
			shaguai.temp_drop(play, mob, "神石宝箱")
			shaguai.temp_drop(play, mob, "神石宝箱")
			shaguai.temp_drop(play, mob, "神石宝箱")
			shaguai.temp_drop(play, mob, "神石宝箱")
			shaguai.temp_drop(play, mob, "神石宝箱")
			shaguai.temp_drop(play, mob, "神石宝箱")
			shaguai.temp_drop(play, mob, "神石宝箱")
			shaguai.temp_drop(play, mob, "神石宝箱")
			shaguai.temp_drop(play, mob, "神石宝箱")
			shaguai.temp_drop(play, mob, "神石宝箱钥匙")
			local legendRate = lowDanActive and 1.1 or 1
			if math.random(10000) <= math.floor(100 * legendRate) then
				shaguai.temp_drop(play, mob, "神石宝箱[传说级]")
			end
			return
		end
		if isBoss then
			shaguai.temp_drop(play, mob, "神石宝箱")
			shaguai.temp_drop(play, mob, "神石宝箱")
			shaguai.temp_drop(play, mob, "神石宝箱")
			shaguai.temp_drop(play, mob, "神石宝箱")
			shaguai.temp_drop(play, mob, "神石宝箱")
			local legendRate = lowDanActive and 1.1 or 1
			if math.random(10000) <= math.floor(100 * legendRate) then
				shaguai.temp_drop(play, mob, "神石宝箱[传说级]")
			end
			if isRedBoss then
				local rate = _sg_xianfu_dan_is_active(play, "N$xf_dan_high_expire") and 240 or 288
				if math.random(rate) == 1 then
					shaguai.temp_drop(play, mob, "神石宝箱[史诗级]")
				end
			end
			return
		end
		local normalBase = lowDanActive and math.floor(188 / 1.1) or 188
		if math.random(math.max(1, normalBase)) == 1 then
			shaguai.temp_drop(play, mob, "神石宝箱")
		end
	end,
	["37"] = function(play,mob)      --聚宝盆：统一走 shaguai 杀怪进度
		local mod = rawget(_G, "__treasure_basin_module")
		if mod and mod.onKillMon then
			mod.onKillMon(play, mob)
		end
	end,
	["38"] = function(play,mob)      --天命试炼：统一走 shaguai 渡劫丹掉落
		if Npclib and Npclib[76] and Npclib[76].onKillMonDanjie then
			Npclib[76].onKillMonDanjie(play, mob)
		end
	end,
	["39"] = function(play,mob)      --血契之门：统一走 shaguai 杀怪额外掉落
		if Npclib and Npclib[81] and Npclib[81].onKillMon then
			Npclib[81].onKillMon(play, mob)
		end
	end,
	["40"] = function(play,mob)      --武器性格：统一走 shaguai 杀怪状态更新
		if Npclib and Npclib[82] and Npclib[82].onKillMon then
			Npclib[82].onKillMon(play, mob)
		end
	end,
	["42"] = function(play,mob)      --登神之路：鬼神道击杀六大陆怪物获得神力
		if Npclib and Npclib[77] and Npclib[77].onKillMon then
			Npclib[77].onKillMon(play, mob)
		end
	end,
	["41"] = function(play,mob)      --保卫村庄：统一走 shaguai 击杀结算
		if BwczApi and BwczApi.onKillMon then
			BwczApi.onKillMon(play, mob)
		end
	end,
	["32"] = function(play,mob)      --转生材料掉落（二重固定1/12，其他按大陆击杀区间）
		local map = getbaseinfo(play,3)
		local dl = daluditu and daluditu[map] or 0
		if not dl or dl <= 0 or dl > 6 then
			return
		end
		local items = {"","二重转生石","三重转生石","四重转生石","五重转生石","六重转生石"}
		local item = items[dl]
		if not item or item == "" then
			return
		end
		if dl == 2 then
			if math.random(12) == 1 then
				shaguai.temp_drop(play, mob, item)
			end
			return
		end
		local data = json2tbl(getplaydef(play, VarCfg.T_zscl)) or {}
		data.drop_cnt = data.drop_cnt or {}
		data.kill_prog = data.kill_prog or {}
		data.kill_goal = data.kill_goal or {}
		local cnt = tonumber(data.drop_cnt[item]) or 0
		local prog = tonumber(data.kill_prog[item]) or 0
		local goal = tonumber(data.kill_goal[item]) or 0
		local cz = tonumber(getplaydef(play, VarCfg["U_真实充值"])) or 0
		local function _base_by_old_rule(_dl, _cnt, _cz)
			if _dl == 3 then
				if _cz > 80 then
					return math.random(50,100)
				end
				return math.random(150,200)
			elseif _dl == 4 or _dl == 5 or _dl == 6 then
				if _cz > 200 then
					return math.random(80,100)
				elseif _cz >= 100 then
					return math.random(100,150)
				end
				return math.random(500,600)
			end
			return nil
		end
		local base = _base_by_old_rule(dl, cnt, cz)
		if not base then
			return
		end
		if goal <= 0 then
			goal = base + math.random(-20,20)
			if goal < 1 then
				goal = 1
			end
			data.kill_goal[item] = goal
		end
		prog = prog + 1
		data.kill_prog[item] = prog
		local can_drop = false
		if prog >= goal then
			can_drop = true
		else
			local left = goal - prog
			if left <= 20 then
				local p = 21 - left
				if math.random(20) <= p then
					can_drop = true
				end
			end
		end
		if can_drop and shaguai.temp_drop(play, mob, item) then
			local next_cnt = cnt + 1
			data.drop_cnt[item] = next_cnt
			data.kill_prog[item] = 0
			local next_base = _base_by_old_rule(dl, next_cnt, cz) or base
			local next_goal = next_base + math.random(-20,20)
			if next_goal < 1 then
				next_goal = 1
			end
			data.kill_goal[item] = next_goal
		end
		setplaydef(play, VarCfg.T_zscl, tbl2json(data))
	end,
}
local _raw_shaguai_handlers = shaguai
shaguai = setmetatable({}, {
    __index = _raw_shaguai_handlers,
    __newindex = _raw_shaguai_handlers,
})
for id, handler in pairs(_raw_shaguai_handlers) do
    if type(handler) == "function" then
        shaguai[id] = function(play, mob, ...)
            _mark_combat_state(play)
            return handler(play, mob, ...)
        end
    end
end
-- 备注：临时掉落物品（封装 additemtodroplist）
shaguai.temp_drop = function(play, mob, itemname)
    if not (play and mob and itemname and itemname ~= "") then
        return false
    end
    additemtodroplist(play, mob, itemname)
    return true
end
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
if GameEvent and EventCfg and EventCfg.onkillplay and not rawget(_G, "__npc728_killplay_event") then
	_G.__npc728_killplay_event = true
	GameEvent.add(EventCfg.onkillplay, function(play, target)
		local mod = dofile("Envir/Lua/Npc/728.lua")
		if mod and mod.link then
			mod.link(play, 728, 5, target)
		end
	end, "npc728_恶魔契约")
end
if GameEvent and EventCfg and EventCfg.onKillMon and not rawget(_G, "__equip_killed_boss_record_event") then
	_G.__equip_killed_boss_record_event = true
	GameEvent.add(EventCfg.onKillMon, function(play, mob)
		_sg_record_killed_boss(play, mob)
	end, "equip_killed_boss_record")
end
return shaguai
