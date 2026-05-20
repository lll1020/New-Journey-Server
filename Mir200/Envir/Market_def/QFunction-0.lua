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
        pcall(function()
            local xianfuNpc = dofile('Envir/Lua/Npc/44.lua')
            if xianfuNpc and xianfuNpc.refreshDollAttr then
                xianfuNpc.refreshDollAttr(play)
            end
        end)
        setontimer(play, 10, 3)
    else
        local open_minutes = tonumber(getsysvar(VarCfg["G_开区分钟"])) or 0
        if open_minutes >= 1440 and linkbodyitem(play,71) == "0" then
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
        pcall(function()
            local xianfuNpc = dofile('Envir/Lua/Npc/44.lua')
            if xianfuNpc and xianfuNpc.refreshDollAttr then
                xianfuNpc.refreshDollAttr(play)
            end
        end)
        setontimer(play, 1, 3, 0, 1)
        --红点系统定时器
        setontimer(play,6,60,0,1)
        delaygoto(play,10000,"ontimer6")
    end
end
--------------------跨天登录触发--------------------
function resetday(play)
    ---清理每日称号
	for _, v in pairs(constant.pz_ldql) do
		Player.title_del(play, v)
	end
    local curMap = tostring(getbaseinfo(play, ConstCfg.gbase.mapid) or "")
    local mijingMaps = { ["苍云秘境"] = true, ["若水秘境"] = true, ["红尘秘境"] = true, ["灵虚秘境"] = true, ["万灵秘境"] = true, ["诸天秘境"] = true }
    if mijingMaps[curMap] then
        mapmove(play, "xtc", 137, 138, 5)
        Player.sendmsgEx(play, "日卡已跨天失效，已返回主城#57")
    end
    setplaydef(play, VarCfg["U_登录天数"], getplaydef(play, VarCfg["U_登录天数"]) + 1)
    local T_qrbq = Player.getJsonTableByVar(play, VarCfg.T_qrbq)
    T_qrbq["zxjl"] = 0
    T_qrbq["sgjl"] = 0
    Player.setJsonVarByTable(play, VarCfg.T_qrbq, T_qrbq)
    local zz_cfg = (teshudata["anniu_516"] and teshudata["anniu_516"].details) or {}
    local zz_data = Player.getJsonTableByVar(play, VarCfg["T_免费赞助"])
    local today = os.date("%Y%m%d")
    if type(zz_data) ~= "table" then
        zz_data = {}
    end
    for i = #zz_cfg, 1, -1 do
        local detail = zz_cfg[i]
        local titleName = tostring((detail or {}).ch or "")
        if titleName ~= "" and checktitle(play, titleName) and type(detail.salary) == "table" and #detail.salary > 0 then
            sendmail(getbaseinfo(play, 2), 0, "至尊赞助工资", "跨天登录成功，今日【" .. titleName .. "】工资已通过邮件发放，请注意查收。", Player.jl_mail(detail.salary))
            zz_data.salary_date = today
            Player.setJsonVarByTable(play, VarCfg["T_免费赞助"], zz_data)
            break
        end
    end
    -- 聚宝盆每日进度：跨天清空击杀积分与自动发放标记。
    setplaydef(play, VarCfg["U_聚宝盆积分"], 0)
    setplaydef(play, VarCfg["J_聚宝盆领取次数"], 0)
    pcall(function()
        local xianfuNpc = dofile('Envir/Lua/Npc/44.lua')
        if xianfuNpc and xianfuNpc.refreshDollAttr then
            xianfuNpc.refreshDollAttr(play)
        end
    end)
end
local function _sc_has_patrol_privilege(play)
    local sc_data = Player.getJsonTableByVar(play, VarCfg["T_首冲礼包"]) or {}
    return (tonumber(sc_data.main_claimed or sc_data.other_lb or 0) or 0) >= 1
end
--------------------传送戒指传送前触发触发-------------------
function beginteleport(play)
    setplaydef(play,"S$dtm",getbaseinfo(play, 3))
    local sj  = os.time()
    local cd = _sc_has_patrol_privilege(play) and 3 or 5
    if getplaydef(play,"N$buff310") == 1 then
        cd = math.max(0, cd - 5) -- 来去自如：传送冷却-5秒
    end
    if cd > 0 then
        local bl = sj - getplaydef(play,"N$传送功能CD")
        if bl < cd then
            sendmsg(play,1,'{"Msg":"请等待'..(cd-bl)..'秒后在使用","FColor":56,"BColor":255,"Type":1}')
            return false
        end
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
    json = type(json) == "table" and json or {}
    if not _sc_has_patrol_privilege(play) then
        if json.gjkg or getflagstatus(play, VarCfg.BS_AIgj) == 1 then
            json.gjkg = nil
            setplaydef(play, VarCfg.T_aigj, tbl2json(json))
            setflagstatus(play, VarCfg.BS_AIgj, 0)
            stopautoattack(play)
        end
        return
    end
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
    if dt == "天降财宝" then
        addbuff(play,20003)
    else
        delbuff(play,20003)
    end
    if dt == "比武大会" then
        if getsysvar(VarCfg["G_开区分钟"]) < 75 then
            local hsmy_px = sorthumvar("比武大会",1,1,5)
            setplaydef(play,VarCfg.N_tyecmb,1)
            sendluamsg(play,101,498,0,0,'{"pmsj":'..tbl2json(hsmy_px)..',"grjf":'..getplayvar(play, "HUMAN", "比武大会")..'}')
        end
    else
        sendluamsg(play,101,498,2,0,"")
        setplaydef(play,VarCfg.N_tyecmb,0)
    end
    if getflagstatus(play, VarCfg.BS_AIgj) == 1 then
        if _sc_has_patrol_privilege(play) and not getbaseinfo(play, 48) then
            startautoattack(play)
        else
            local ai_json = json2tbl(getplaydef(play, VarCfg.T_aigj))
            ai_json = type(ai_json) == "table" and ai_json or {}
            ai_json.gjkg = nil
            setplaydef(play, VarCfg.T_aigj, tbl2json(ai_json))
            setflagstatus(play, VarCfg.BS_AIgj, 0)
            stopautoattack(play)
        end
    end
    -- 切图时立即刷新灰界视野限制，避免必须重登才生效。
    -- 切换地图触发：用于刷新天书仙法等模块状态
    if Login and Login.refreshGrayWorldVision then
        Login.refreshGrayWorldVision(play)
    end
    GameEvent.push(EventCfg.goSwitchMap, play)
end
-- 进入/离开队伍触发（引擎回调入口）
function entergroup(play, ...)
    GameEvent.push(EventCfg.onEnterGroup, play, ...)
end
function leavegroup(play, ...)
    GameEvent.push(EventCfg.onLeaveGroup, play, ...)
end
function findpathbegin(actor)
    --寻路自动传送
    local mapid = getbaseinfo(actor, ConstCfg.gbase.mapid)
    if string.find(mapid, "_") then
        Player.sendmsgEx(actor, "当前地图无法自动寻路传送#57")
        -- gotonow(actor,getconst(actor, "<$ToPointX>"),getconst(actor, "<$ToPointY>"))
        gotonow(actor, getbaseinfo(actor, ConstCfg.gbase.x), getbaseinfo(actor, ConstCfg.gbase.y))
        return false
    end
    -- local x = tonumber(getconst(actor, "<$ToPointX>")) or 0
    -- local y = tonumber(getconst(actor, "<$ToPointY>")) or 0
    -- if checkkuafu(actor) then
    -- else
    --     mapmove(actor, mapid, x, y)
    -- end
end
--------------------死亡物品掉了-------------------
function checkdropuseitems(play,item_wz,item_id,bool)
    local zb_dx = linkbodyitem(play,item_wz)
    local dt = getbaseinfo(play, 3)
    if dt == "阵营对抗" or dt == "跨服阵营对抗" or dt == "武林盟主" then
        return false
    end
    -- 天书仙法：守财奴每日一次防掉落
    if xianfa_check_drop and xianfa_check_drop(play) == false then
        return false
    end
    GameEvent.push(EventCfg.onCheckDropUseItems, play, item_wz, item_id, bool)
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
	if idx > 10006 and idx < 10022 then    --经验丹
        if Player.canGainRoleLevel(play, false) then
            local sl = getiteminfo(play, item, 5)
            local useCount = 0
            local addExp = getstditeminfo(idx, 8)
            for i = 1, sl do
                if not Player.canGainRoleLevel(play, false) then
                    break
                end
                changeexp(play, '+', addExp, false)
                Player.clampRoleLevel(play, false)
                useCount = useCount + 1
            end
            if useCount > 0 then
                delitembymakeindex(play, getiteminfo(play, item, 1), useCount)
            end
        end
    elseif idx > 10022 and idx < 10040 then    --金币
        local sl = getiteminfo(play, item, 5)
        changemoney(play, getflagstatus(play,VarCfg.BS_mztq) == 1 and 1 or 3, '+', getstditeminfo(idx, 8) * sl, '捡物自动吃', true)
        delitembymakeindex(play, getiteminfo(play, item, 1), sl)
    elseif idx > 10045 and idx < 10063 then    --元宝
        local sl = getiteminfo(play, item, 5)
        changemoney(play, getflagstatus(play,VarCfg.BS_mztq) == 1 and 2 or 4, '+', getstditeminfo(idx, 8) * sl, '捡物自动吃', true)
        delitembymakeindex(play, getiteminfo(play, item, 1), sl)
    end
    --进背包动画
    setpickitemtobag(play,"200","101")
    --TODO: 首爆装备
    if getconst(play,"<$SERVERNAME>") ~= "" and getconst(play,"<$SERVERNAME>") ~= "直播区" or true then
        local T_grsb = Player.getJsonTableByVar(play, VarCfg.T_grsb)
        if teshudata["fldt"]["grsb"][idx] and not T_grsb[""..idx] then
            T_grsb[""..idx] = 1
            Player.setJsonVarByTable(play, VarCfg.T_grsb, T_grsb)
        end
        local qqsb = Player.getJsonTableByVar(nil, VarCfg["A_全区首曝json"])
        if type(qqsb) ~= "table" then
            qqsb = {}
        end
-- A1 记录 idx -> 首爆玩家名，同时额外保存 first_name/first_item/first_idx 作为全服第一件展示信息。
-- T_qrbq.qqsb_first 记录玩家自己的首爆归属，用来判断是否具备首爆领取资格。
        if teshudata["fldt"]["qqsb"][idx] and not qqsb[""..idx] then
            local mz = getbaseinfo(play,1)
            qqsb[""..idx] = mz
            Player.setJsonVarByTable(nil, VarCfg["A_全区首曝json"], qqsb)
            sendmovemsg(play,1,253,0,150,1,'全区首爆: <玩家/FCOLOR=250><【'..mz..'】/FCOLOR=243><爆出/FCOLOR=250><【'..name..'】/FCOLOR=243>')
            sendmovemsg(play,1,253,0,180,1,'全区首爆: <玩家/FCOLOR=250><【'..mz..'】/FCOLOR=243><爆出/FCOLOR=250><【'..name..'】/FCOLOR=243>')
            sendmovemsg(play,1,253,0,210,1,'全区首爆: <玩家/FCOLOR=250><【'..mz..'】/FCOLOR=243><爆出/FCOLOR=250><【'..name..'】/FCOLOR=243>')
            Player.sendmsgEx(play, "恭喜#215|【"..name.."】#191|首爆成功,请前往福利大厅领取奖励#215")
        end
        if teshudata["fldt"]["qqsb"][idx] and qqsb[""..idx] then
            local T_grqqsb = Player.getJsonTableByVar(play, VarCfg.T_grqqsb)
            T_grqqsb[""..idx] = 1
            Player.setJsonVarByTable(play, VarCfg.T_grqqsb, T_grqqsb)
        end
    end
end
function takeonbeforeex(play,item,where,makeIndex)
    -- if where == 22 then
    --     if getiteminfo(play,item,2) > 21043 then
    --         callscriptex(play,"TAKEONMAKEINDEX",23,makeIndex)
    --         return false
    --     end
    -- elseif where == 24 then
    --     if getiteminfo(play,item,2) > 21043 then
    --         callscriptex(play,"TAKEONMAKEINDEX",25,makeIndex)
    --         return false
    --     end
    -- end
    if where >= 103 and where <= 110 then
        local xianfuVar = VarCfg.T_XianFuData or "T47"
        local xianfuCfg = Guard.getConfig("npc_44") or {}
        local xianfuData = Player.getJsonTableByVar(play, xianfuVar) or {}
        local level = tonumber(xianfuData.level or 1) or 1
        local levelCfg = (xianfuCfg.level_cfg or {})[level] or {}
        local openCount = tonumber(levelCfg.open_slots or 0) or 0
        if openCount <= 0 then
            Player.sendmsgEx(play, "当前仙府等级尚未解锁神石槽位#57")
            return false
        end

        local targetItem = linkbodyitem(play, where)
        if not targetItem or targetItem == "0" then
            local equipped = 0
            for pos = 103, 110 do
                local bodyItem = linkbodyitem(play, pos)
                if bodyItem and bodyItem ~= "0" then
                    equipped = equipped + 1
                end
            end
            if equipped >= openCount then
                Player.sendmsgEx(play, string.format("当前仙府等级仅开放%d个神石槽位#57", openCount))
                return false
            end
        end

        local itemName = tostring(getiteminfo(play, item, ConstCfg.iteminfo.name) or "")
        local baseName = string.match(itemName, "^(.-)【") or itemName
        if baseName ~= "" then
            for pos = 103, 110 do
                if pos ~= where then
                    local bodyItem = linkbodyitem(play, pos)
                    if bodyItem and bodyItem ~= "0" then
                        local bodyName = tostring(getiteminfo(play, bodyItem, ConstCfg.iteminfo.name) or "")
                        local bodyBaseName = string.match(bodyName, "^(.-)【") or bodyName
                        if bodyBaseName ~= "" and bodyBaseName == baseName then
                            Player.sendmsgEx(play, string.format("同名神石仅可装备一个：%s#57", baseName))
                            return false
                        end
                    end
                end
            end
        end
    end
    return true
end
--穿套装
function groupitemonex(actor, idx)
    GameEvent.push(EventCfg.onGroupItemOnEx, actor, idx)
end
--脱套装
function groupitemoffex(actor, idx)
    GameEvent.push(EventCfg.onGroupItemOffEx, actor, idx)
end
--------------------穿戴后触发-------------------
function takeonex(play, item, where, Name, makeindex)
	Buff.chuan(play, item)
    if where == 14 then
        changemoney(play,16,"=",1,"登录复活",true)
    end
    GameEvent.push(EventCfg.onTakeOnEx, play, item, where, Name, makeindex)
end
--------------------脱下后触发-------------------
function takeoffex(play, item, where, Name, makeindex)
	Buff.tuo(play, item)
    if where == 14 then
        changemoney(play,16,"=",0,"登录复活",true)
    end
    GameEvent.push(EventCfg.onTakeOffEx, play, item, where, Name, makeindex)
end
--------------------攻击前触发-------------------
function attackdamage(play, Target, Hiter, MagicId, Damage,Model)
    GameEvent.push(EventCfg.onAttackDamage, play, Target, Hiter, MagicId, Damage, Model)
	if getbaseinfo(Target, -1) then
        GameEvent.push(EventCfg.onAttackDamagePlayer, play, Target, Damage, MagicId, Model)
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
			humanhp(Target, '-', ew, 110, 0, play, 1)
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
        -- 在基础规则结算后，由武器性格修正最终攻击侧伤害。
        if weapon_personality_attack_adjust then
            local adj = weapon_personality_attack_adjust(play, Target, Damage, MagicId, Model)
            if type(adj) == "number" then
                Damage = adj
            end
        end
        if TianMingDaoPanAdjustPlayerDamage then
            Damage = TianMingDaoPanAdjustPlayerDamage(play, Target, Damage)
        end
		return Damage
	else
        GameEvent.push(EventCfg.onAttackDamageMonster, play, Target, Damage, MagicId, Model)
        if BwczApi and BwczApi.get_cfg then
            local bwcz_cfg = BwczApi.get_cfg()
            if bwcz_cfg and getsysvar(VarCfg["G_保卫村庄状态"]) == 1 then
                local targetMap = tostring(getbaseinfo(Target, 3) or "")
                local targetName = tostring(getbaseinfo(Target, 1) or "")
                if targetMap == tostring(bwcz_cfg.map or "") and BwczApi.is_event_mon and BwczApi.is_event_mon(targetName, bwcz_cfg) then
                    return tonumber(bwcz_cfg.fixed_damage) or 1
                end
            end
        end
        -- 灰界压制：无【诸邪退散】时，对灰界怪物的所有输出统一按50%结算。
        local huijie_damage_rate = 1
        if Player and Player.getHuiJieMonsterDamageRate then
            huijie_damage_rate = tonumber(Player.getHuiJieMonsterDamageRate(play) or 1) or 1
        end
        ---------------------------------------------对怪切割计算
		local zd = getbaseinfo(Target, 12)
		local sy = -1
		if zd == 0 or true then
			local zhi = getbaseinfo(play, 51, 244)
			if zhi > 0 then
                zhi = math.floor(zhi * huijie_damage_rate)
                if zhi > 0 then
					humanhp(Target, '-', zhi, 106, 0, play, 1)
                end
			end
			zhi = getbaseinfo(play, 51, 245)
			if zhi > 0 then
                local extra_damage = math.floor((Damage / 10000 * zhi) * huijie_damage_rate)
                if extra_damage > 0 then
					humanhp(Target, '-', extra_damage, 108, 0, play, 1)
                end
			end
		else
			if zd > Damage then
				sy = zd - Damage
				local qie = getbaseinfo(play, 51, 244) * (1 + getbaseinfo(play,51,253)/ 10000)
				if sy > qie then
                    if qie > 0 then
                        sy = sy - qie
                        humanhp(Target, '-', math.floor(qie * (getbaseinfo(play, 51, 251)/100 + 1)), 106, 0, play, 1)
                    end
					local zeng = Damage / 10000 * getbaseinfo(play, 51, 245)
					if zeng > 0 then
						if sy > zeng then
							sy = sy - zeng
							humanhp(Target, '-', zeng, 110, 0, play, 1)
						else
							humanhp(Target, '-', sy, 110, 0, play, 1)
							return Damage
						end
					end
				else
					humanhp(Target, '-', sy, 106, 0, play, 1)
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
                    ew = math.floor(ew * huijie_damage_rate)
                    if ew <= 0 then
                        ew = nil
                    end
                end
				if ew and ew > 0 then
					if sy == -1 then
						buffsh = buffsh + ew
					elseif sy > ew then
						sy = sy - ew
						buffsh = buffsh + ew
					else
						humanhp(Target, '-', sy, 110, 0, play, 1)
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
                    ew = math.floor(ew * huijie_damage_rate)
                    if ew <= 0 then
                        ew = nil
                    end
                end
				if ew and ew > 0 then
					if sy == -1 then
						buffsh = buffsh + ew
					elseif sy > ew then
						sy = sy - ew
						buffsh = buffsh + ew
					else
						humanhp(Target, '-', sy, 110, 0, play, 1)
						return Damage
					end
				end
			end
		end
		if buffsh > 0 then
			humanhp(Target, '-', buffsh, 110, 0, play, 1)
		end
        if huijie_damage_rate ~= 1 then
            Damage = math.floor(Damage * huijie_damage_rate)
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
            ew = ew + gd
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
    local final = Damage + ew + xi
    -- 天书仙法：双刃剑/诅咒冠冕等被动修正最终伤害
    if xianfa_struck_adjust then
        local adj = xianfa_struck_adjust(play, final, Hiter, MagicId)
        if type(adj) == "number" then
            final = adj
        end
    end
    -- 在其他钩子结算后，由武器性格修正最终受击侧伤害。
    if weapon_personality_struck_adjust then
        local adj = weapon_personality_struck_adjust(play, final, Hiter, MagicId)
        if type(adj) == "number" then
            final = adj
        end
    end
    -- 灰界压制：无【诸邪退散】时，受到灰界怪物伤害按110%结算。
    if Hiter and (not getbaseinfo(Hiter, -1)) and Player and Player.getHuiJieMonsterHurtRate and final > 0 then
        local huijie_hurt_rate = tonumber(Player.getHuiJieMonsterHurtRate(play) or 1) or 1
        if huijie_hurt_rate ~= 1 then
            final = math.floor(final * huijie_hurt_rate)
        end
    end
    local realDamage = final > 0 and final or 1
    if Hiter and (not getbaseinfo(Hiter, -1)) and BwczApi and BwczApi.get_cfg then
        local bwcz_cfg = BwczApi.get_cfg()
        if bwcz_cfg and getsysvar(VarCfg["G_保卫村庄状态"]) == 1 then
            local hitMap = tostring(getbaseinfo(Hiter, 3) or "")
            local hitName = tostring(getbaseinfo(Hiter, 1) or "")
            if hitMap == tostring(bwcz_cfg.map or "") and BwczApi.is_event_mon and BwczApi.is_event_mon(hitName, bwcz_cfg) then
                realDamage = math.max(0, math.floor(realDamage * (tonumber(bwcz_cfg.player_hurt_scale) or 0)))
            end
        end
    end
    GameEvent.push(EventCfg.onProHarm, play, realDamage, Hiter, Target, MagicId)
    return realDamage
end
--------------------被攻击后触发-------------------
function struck(play, Hiter, Target, MagicId)
    if getbaseinfo(Hiter, -1) then
        setplaydef(play,"N$战斗状态",os.time()+3)
    end
end
--------------------杀怪触发-------------------
function killmon(play, mob)
    GameEvent.push(EventCfg.onKillMon, play, mob, getbaseinfo(mob, ConstCfg.gbase.idx))
    if BwczApi and BwczApi.get_cfg then
        local bwcz_cfg = BwczApi.get_cfg()
        if bwcz_cfg and getsysvar(VarCfg["G_保卫村庄状态"]) == 1 then
            local mapName = tostring(getbaseinfo(mob, 3) or "")
            local monName = tostring(getbaseinfo(mob, 1) or "")
            if mapName == tostring(bwcz_cfg.map or "") and BwczApi.is_event_mon and BwczApi.is_event_mon(monName, bwcz_cfg) then
                local state = BwczApi.get_state and BwczApi.get_state() or {}
                if type(state) == "table" and tonumber(state.open) == 1 and BwczApi.build_rank_data then
                    if getmapmon and BwczApi.build_rank_data then
                        state.spawn_done = 0
                        if BwczApi.save_state then
                            BwczApi.save_state(state)
                        end
                    end
                end
            end
        end
    end
    if FairyFate and FairyFate.touch then
        FairyFate.touch(play, "kill_mon", getbaseinfo(play, 3))
    end
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
    -- 第五章任务杀怪进度：按任务类型处理 kill_count / kill_per_step
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
    local sg_changed = false
    local cur_map = getbaseinfo(play,3)
    for task_id = 682, 719 do
        local task_key = "npc_"..tostring(task_id)
        local task_cfg_wrap = teshudata[task_key]
        local task_cfg = task_cfg_wrap and task_cfg_wrap.task_cfg or nil
        local has_shaguai = shaguai and shaguai[tostring(task_id)] ~= nil
        if type(task_cfg) == "table" and not has_shaguai then
            local map_ok = (not task_cfg.map or task_cfg.map == "" or task_cfg.map == cur_map)
            if map_ok then
                local task_state = tonumber(jq_data[task_key] or 0) or 0
                local done_cnt = tonumber(jq_data[task_key .. "_a"] or 0) or 0
                local max_num = tonumber(task_cfg.max_submit_times or task_cfg.max_reward_round or task_cfg_wrap.max_num or 1) or 1
                if max_num < 1 then
                    max_num = 1
                end
                if task_state < 2 and done_cnt < max_num then
                    local target_need = 0
                    local step_need = tonumber(task_cfg.kill_per_step or 0) or 0
                    if step_need > 0 then
                        target_need = step_need * (done_cnt + 1)
                    else
                        target_need = tonumber(task_cfg.kill_count or 0) or 0
                    end
                    if target_need > 0 then
                        if task_state >= 1 then
                            local cur_kill = tonumber(sg_data[task_key] or 0) or 0
                            if cur_kill < target_need then
                                cur_kill = cur_kill + 1
                                if cur_kill > target_need then
                                    cur_kill = target_need
                                end
                                sg_data[task_key] = cur_kill
                                sg_changed = true
                                if cur_kill == target_need then
                                    Player.sendmsgEx(play, string.format("%s击杀目标已达成(%d/%d)，可提交任务#57", (task_cfg_wrap.name or task_key), cur_kill, target_need))
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if sg_changed then
        Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
    end
    ---每日杀怪数量
    local gw_name = getbaseinfo(mob,1)
    if guaiwutype[gw_name] and guaiwutype[gw_name] >= 1 then
        setplaydef(play,VarCfg.J_jsgw[1],getplaydef(play,VarCfg.J_jsgw[1])+1)
    else
        setplaydef(play,VarCfg.J_jsgw[2],getplaydef(play,VarCfg.J_jsgw[2])+1)
    end
    -- 聚宝盆改为独立监听累计，这里不再走旧的随机积分逻辑。
    setplaydef(play,VarCfg.U_fldt[2],getplaydef(play,VarCfg.U_fldt[2])+1)
    local mz = getbaseinfo(mob, 1, 1)
    local T_grss = Player.getJsonTableByVar(play, VarCfg.T_grss)
    local idx = getdbmonfieldvalue(mz, "idx")
    if teshudata["fldt"]["grss"][idx] and not T_grss[""..idx] then
        T_grss[""..idx] = 1
        Player.setJsonVarByTable(play, VarCfg.T_grss, T_grss)
    end
    local dt = getbaseinfo(play, 3)
    if dt ~= "xtc" then
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
--------------------货币改变触发-------------------金币
function moneychange1(play)
    local gb = getplaydef(play,"N$金币改变触发")
    if gb > 0 and Buff[gb] then
        Buff[gb](play, 1)
    end
end
--------------------货币改变触发-------------------元宝
function moneychange2(play)
    local gb = getplaydef(play,"N$元宝改变触发")
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
--------------------货币改变触发-------------------充值触发
function moneychange23(play)
    local _config = Guard.getConfig("npc_20")
    if querymoney(play,23) >= _config.cost then
        if not checktitle(play,_config.ch) then
            Player.title_give(play,_config.ch,1)
            messagebox(play,"恭喜您获得称号：【".._config.ch.."】")
        end
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
    -- 杀人事件：派发给监听模块（如天书仙法）
    GameEvent.push(EventCfg.onkillplay, play, hiter)
    setplaydef(play,VarCfg.U_srsl,getplaydef(play,VarCfg.U_srsl)+1)
    login_fhsx(play)
    if getsysvar(VarCfg.G_kqfz) >= 40 and getsysvar(VarCfg.G_kqfz) <= 50 then
        local jf = getplayvar(play, "HUMAN", "比武大会") + 50
        setplayvar(play, "HUMAN", "比武大会", jf, 1)
        sendmsg(play,1,'{"Msg":"比武大会：当前积分:'..jf..'","FColor":253,"BColor":255,"Type":1}')
        jf = getplayvar(hiter, "HUMAN", "比武大会") + 10
        setplayvar(hiter, "HUMAN", "比武大会", jf, 1)
        Player.sendmsgEx(hiter,1,'{"Msg":"比武大会：当前积分:'..jf..'","FColor":253,"BColor":255,"Type":1}')
    end
end
--------------------玩家死亡触发-------------------
function playdie(play, hiter)
    local dt,x,y = getbaseinfo(play,3),getbaseinfo(play,4),getbaseinfo(play,5)
    sendmail("#" .. getbaseinfo(play, 1), 1, "系统提示", "您被["..getbaseinfo(hiter, 1).."]在"..getbaseinfo(play,45).."("..x.."."..y..")杀害了...")
    setplaydef(play,VarCfg.U_bssl,getplaydef(play,VarCfg.U_bssl)+1)
    GameEvent.push(EventCfg.onPlaydie, play, hiter)
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
function playlevelup(play, level, oldlevel)
    -- 升级事件：派发给监听模块（如天书仙法）
    if not level then
        level = getbaseinfo(play, ConstCfg.gbase.level)
    end
    GameEvent.push(EventCfg.onPlayLevelUp, play, level, oldlevel)
end
--------------------属性改变触发-------------------
function sendability(play)
    GameEvent.push(EventCfg.onSendAbility, play)
    local sd = math.floor(getbaseinfo(play,51,243) / 4)
    if getplaydef(play,"N$移动速度加成") ~= sd then
        setplaydef(play,"N$移动速度加成",sd)
        callscriptex(play, 'changespeedex', 1, sd)
    end
    local zhenShiBaoLv = FCalculateActualExplosionRate(getbaseinfo(play,51,242)/100 - 100)
    --设置真实爆率
    setbaseinfo(play, 43, zhenShiBaoLv)
    Player.updata_zdl(play)
end
local czlb_je = constant.cz_je
function _cz502_apply_reward(play, amount, idx, lb_json)
    local config = teshudata["anniu_502"]
    if not config or not config.jl then
        return lb_json
    end
    if not idx then
        if amount and config.fj then
            for i, v in ipairs(config.fj) do
                if v == amount then
                    idx = i
                    break
                end
            end
        end
    end
    if not idx then
        return lb_json
    end
    if not amount then
        if config.fj then
            amount = config.fj[idx]
        elseif constant.cz_je then
            amount = constant.cz_je[idx]
        end
    end
    if not amount then
        return lb_json
    end
    if type(lb_json) ~= "table" then
        lb_json = json2tbl(getplaydef(play, VarCfg.T_czlb))
        lb_json = lb_json == "" and {} or lb_json
        if type(lb_json) ~= "table" then
            lb_json = {}
        end
    end
    local key = "cz502_" .. tostring(amount)
    if lb_json[key] and lb_json[key] == 1 then
        return lb_json
    end
    lb_json[key] = 1
    local reward = config.jl[idx]
    if reward then
        if reward.give then
            Player.rwjl(play, reward.give, "充值档位奖励", 1)
        end
        if tonumber(reward.token_count) and tonumber(reward.token_count) > 0 then
            local T_data = Player.getJsonTableByVar(play, VarCfg["T_马上发财"])
            T_data.token_count = (tonumber(T_data.token_count) or 0) + tonumber(reward.token_count)
            Player.setJsonVarByTable(play, VarCfg["T_马上发财"], T_data)
        end
        if reward.ch then
            if not checktitle(play, reward.ch) then
                Player.title_give(play, reward.ch)
            end
        end
        if reward.skill then
            local skillId = getskillindex(reward.skill)
            if skillId and skillId > 0 then
                addskill(play, skillId, 3)
            end
        end
    end
    if config.fj then
        local all = true
        for _, v in ipairs(config.fj) do
            if not lb_json["cz502_" .. tostring(v)] then
                all = false
                break
            end
        end
        if all and config.ch then
            -- 在线充值全购买奖励：授予全购买称号。
            lb_json.cz502_all = 1
            if not checktitle(play, config.ch) then
                Player.title_give(play, config.ch)
            end
        end
    end
    return lb_json
end
--------------------真充积分改变触发-------------------在线充值礼包筛选
-- function moneychange22(play)
--     local lb_json,hbsl,jezz = json2tbl(getplaydef(play, VarCfg.T_czlb)),querymoney(play,22),0
--     for i = 1, #czlb_je, 1 do
--         if not lb_json["cz"..i] then
--             if jezz + czlb_je[i] <= hbsl then
--                 jezz = jezz + czlb_je[i]
--                 lb_json["cz" .. i] = true
--                 setplaydef(play, VarCfg.T_czlb, tbl2json(lb_json))
--                 setplaydef(play,VarCfg.N_lbyz,1)
--                 czlb_pz(play,i)
--             else
--                 break
--             end
--         end
--     end
--     if jezz > 0 then
--         changemoney(play,22,"-",jezz,"礼包积分",true)
--     end
-- end
function czlb_pz(play,sy)
    sy = tonumber(sy)
    local lb_json = json2tbl(getplaydef(play, VarCfg.T_czlb))
    lb_json = _cz502_apply_reward(play, nil, sy, lb_json)
    setplaydef(play, VarCfg.T_czlb, tbl2json(lb_json))
    local config = teshudata["anniu_502"] or {}
    local amount = config.fj and config.fj[sy]
    if amount then
        PackageBuy_msg(play, tostring(amount) .. "元礼包")
    end
    if getplaydef(play,VarCfg.N_lbyz) == 1 then
        setplaydef(play,VarCfg.N_lbyz,0)
    end
end
--------------------累计充值改变触发-------------------冠名称号
function moneychange23(play)
    setplaydef(play,VarCfg["U_真实充值"],querymoney(play,23))
    if querymoney(play,23) >= teshudata["npc_20"].cost and not checktitle(play,"天下谁人不识君") then
        messagebox(play,"累计充值数量已达到,可以去领取冠名奖励了")
        Npclib[20].link(play, 20, 1)
    end
end
--------------------充值触发-------------------
function recharge(play, Gold, ProductId, MoneyId, isReal)
    release_print("充值触发","玩家："..getbaseinfo(play,1), "金额："..Gold, "订单:"..ProductId, "货币id:"..MoneyId, "是否真充:"..(isReal and "是" or "否"))
    local zhid = tonumber(getconst(play,"<$USERACCOUNT>"))
    if isReal or (constant.pz_htqx[zhid] or getconst(play, '<$SERVERNAME>') == "" or getconst(play, '<$SERVERNAME>') == "测试区") then
        changemoney(play,23,"+",Gold,"平台累计充值",true)
        if getflagstatus(play, VarCfg["F_是否首充"]) == 0 then
            setflagstatus(play, VarCfg["F_是否首充"], 1)
        end
        setplaydef(play,VarCfg.J_zscz,(getplaydef(play,VarCfg.J_zscz) or 0) + Gold)
        if MoneyId == 7 then   ---灵石充值
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
            if not isReal then
                changemoney(play,8,"+",Gold*10,"充值送一倍",true)
            end
            Login_msg(play,18,Gold,Gold*10)
        elseif MoneyId == 21 then  --直拉礼包
            if Gold == 18 then
                local zz_data = Player.getJsonTableByVar(play, VarCfg["T_免费赞助"]) or {}
                if tonumber(zz_data["pay21_18"] or 0) ~= 1 then
                    zz_data["pay21_18"] = 1
                    Player.setJsonVarByTable(play, VarCfg["T_免费赞助"], zz_data)
                    sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>18元礼包支付成功，当前角色已满足高级玩家领取条件...</font>","Type":9}')
                    PackageBuy_msg(play, "18元礼包")
                end
            elseif Gold == 88 then
                if getflagstatus(play,VarCfg.BS_mztq) == 0 then
                    Player.title_give(play, teshudata["anniu_504"].ch,1)
                    Player.rwjl(play, teshudata["anniu_504"].give, "快人一步",1,1000)
                    setflagstatus(play,VarCfg.BS_mztq,1)
                    PackageBuy_msg(play, "88元礼包")
                    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
                    if jq_data["npc_55"] and jq_data["npc_55"] >= 2 then
                        if Npclib and Npclib["anniu"] and Npclib["anniu"][30] then
                            Npclib["anniu"][30](play, 3, 0, "")
                        end
                    end
                    if Buff and Buff.refreshHuTiGuangHuan then
                        Buff.refreshHuTiGuangHuan(play)
                    end
                    -- 飞剑功能临时下线：不再改动飞剑冷却参数
                    -- local T_data_fj = Player.getJsonTableByVar(play, VarCfg["T_飞剑"])
                    -- T_data_fj.cd = teshudata["anniu_19"].cd/2
                    -- Player.setJsonVarByTable(play, VarCfg["T_飞剑"], T_data_fj)
                    --sendluamsg(play,101,504,1,0,"")
                end
            elseif Gold == 6 then
                local T_data = Player.getJsonTableByVar(play, VarCfg["T_首冲礼包"])
                if not (T_data["ok"] and T_data["ok"] == 1) then
                    T_data["ok"] = 1
                    T_data["首充"] = 1
                    Player.setJsonVarByTable(play, VarCfg["T_首冲礼包"], T_data)
                    if Buff and Buff.refreshHuTiGuangHuan then
                        Buff.refreshHuTiGuangHuan(play)
                        if Buff[73] then
                            Buff[73](play, 1)
                        end
                    end
                    sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>首充礼包已激活，当前角色已可领取相关奖励...</font>","Type":9}')
                    PackageBuy_msg(play, "首充礼包")
                end
            end
        end
        GameEvent.push(EventCfg.onRechargeEnd, play, Gold, ProductId, MoneyId, isReal)
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
    -- 每日重置全民夺矿状态，防止异常跨天残留
    setsysvar(VarCfg["G_全民夺矿状态"], 0)
    setsysvar(VarCfg["A_全民夺矿json"], "")
    -- 每日重置黑暗禁地状态，防止跨天后残留宝箱与开启标记。
    local hdjdCfg = HdjdApi and HdjdApi.get_cfg and HdjdApi.get_cfg() or nil
    local hdjdState = HdjdApi and HdjdApi.get_state and HdjdApi.get_state() or {}
    if hdjdCfg and HdjdApi and HdjdApi.clear_map_chests then
        HdjdApi.clear_map_chests(hdjdCfg, hdjdState)
    elseif hdjdCfg and hdjdCfg.map and hdjdCfg.chest_mob and hdjdCfg.chest_mob ~= "" then
        killmonsters(hdjdCfg.map, hdjdCfg.chest_mob, 0, false)
    end
    setsysvar(VarCfg["G_黑暗禁地状态"], 0)
    setsysvar(VarCfg["A_黑暗禁地json"], "")
end
--------------------机器人触发脚本-------------------全民夺矿开始
function jqr_qmdk_start()
    local state = getsysvar(VarCfg["A_全民夺矿json"])
    state = state == "" and {} or json2tbl(state)
    state["force_start"] = 1
    state["force_end"] = nil
    setsysvar(VarCfg["A_全民夺矿json"], tbl2json(state))
    release_print("机器人触发：全民夺矿开始")
end
--------------------机器人触发脚本-------------------全民夺矿结束
function jqr_qmdk_end()
    local state = getsysvar(VarCfg["A_全民夺矿json"])
    state = state == "" and {} or json2tbl(state)
    state["force_end"] = 1
    state["force_start"] = nil
    setsysvar(VarCfg["A_全民夺矿json"], tbl2json(state))
    release_print("机器人触发：全民夺矿结束")
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
--------------------机器人触发脚本-------------------葬星海滩 切换
function jqr_zxht_change()
    -- release_print("葬星海滩涨落潮切换触发")
    -- release_print("当前时间小时数为："..os.date("%H"))
    local hour = tonumber(os.date("%H")) or 0
    local map_even = "葬星海滩"
    local map_odd = "葬星海滩1"
    local target = (hour % 2 == 0) and map_even or map_odd
    local source = (hour % 2 == 0) and map_odd or map_even
    -- release_print("当前地图为："..target)
    local players = getobjectinmap(source, 0, 0, 999, 1)
    if players then
        for _, v in pairs(players) do
            map(v, target)      
            Player.sendmsgEx(v, "葬星海滩涨落潮已切换，已为你传送#57")
        end
    end
end
--------------------加入行会后触发-------------------
function guildaddmemberafter(play,guild,name)
    GameEvent.push(EventCfg.goGuild, play, guild, name)
    GameEvent.push(EventCfg.onGuildAddMemberAfter, play, guild, name)
end
--------------------退出行会后触发-------------------
function guilddelmember(play)
end
function updateguildnotice(play)
    stop(play)
    sendmsg(play,1,'{"Msg":"<font color=\'#00ff00\'>禁止修改行会通告</font>","Type":9}')
end
--点击采集
-- 采集类活动统一走这里分发，当前包含全民夺矿与黑暗禁地。
local function _collect_activity_handlers()
    local handlers = {}
    if QmdkApi then
        handlers[#handlers + 1] = QmdkApi
    end
    if HdjdApi then
        handlers[#handlers + 1] = HdjdApi
    end
    if MskhApi then
        handlers[#handlers + 1] = MskhApi
    end
    return handlers
end
function collectmonex(play,monIDX,monName,monMakeIndex)
    for _, api in ipairs(_collect_activity_handlers()) do
        if api and api.before_collect then
            local status, collectSec = api.before_collect(play, monName, monMakeIndex)
            if status == "blocked" then
                return
            end
            if status == "start" then
                showprogressbardlg(play, collectSec, "@func_cjcg", "采集中%s..", 1, "@func_cjsb")
                setplaydef(play,"S$采集目标",monMakeIndex)
                setplaydef(play,"S$采集目标名字",monName)
                setplaydef(play,"N$iscaiji",1)
                return
            end
        end
    end
    if not Bag.checkBagEmptyNum(play, 5) then
        Player.sendmsgEx(play, "采集失败,你的背包格子不足!")
        return
    end
    showprogressbardlg(play,3,"@func_cjcg","采集中%s..", 1,"@func_cjsb")
    setplaydef(play,"S$采集目标",monMakeIndex)
    setplaydef(play,"S$采集目标名字",monName)
    setplaydef(play,"N$iscaiji",1)
end
function func_cjcg(play)
    setplaydef(play,"N$iscaiji",0)
    local monName = getplaydef(play, "S$采集目标名字")
    local monMakeIndex = getplaydef(play, "S$采集目标")
    if monName == nil or monName == "" or monMakeIndex == nil or monMakeIndex == "" then
        setplaydef(play, "S$采集目标", "")
        setplaydef(play, "S$采集目标名字", "")
        return
    end
    for _, api in ipairs(_collect_activity_handlers()) do
        if api and api.on_collect_success and api.on_collect_success(play, monName, monMakeIndex) then
            setplaydef(play, "S$采集目标", "")
            setplaydef(play, "S$采集目标名字", "")
            return
        end
    end
    local mapid = getbaseinfo(play, ConstCfg.gbase.mapid)
    local monobj = getmonbyuserid(mapid, monMakeIndex)
    if not monobj then
        setplaydef(play, "S$采集目标", "")
        setplaydef(play, "S$采集目标名字", "")
        return
    end
    killmonbyobj(play, monobj, false, false, false)
    if monName == "采集任务一" then
        local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
        sg_data["npc3"] = (sg_data["npc3"] or 0) + 1
        if sg_data["npc3"] >= 5 then
            messagebox(play,"任务完成,立即前往提交")
        end
        Player.sendmsgEx(play,  "采集+"..1 .." ( "..sg_data["npc3"].."/5 )#57")
        Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
    elseif monName == "贵族宝藏" then
        local jl = teshudata["npc_47"].details[1].jl
        local randomNum = ransjstr(jl.weight, 1, 3)
        randomNum = tonumber(randomNum)
        Player.rwjl(play, {jl.details[randomNum]}, "贵族宝藏",1,1000)
    elseif monName == "王室宝藏" then
        local jl = teshudata["npc_47"].details[2].jl
        local randomNum = ransjstr(jl.weight, 1, 3)
        randomNum = tonumber(randomNum)
        Player.rwjl(play, {jl.details[randomNum]}, "贵族宝藏",1,1000)
    elseif monName == "普通宝藏" then
        local jl = teshudata["npc_47"].details[3].jl
        local randomNum = ransjstr(jl.weight, 1, 3)
        randomNum = tonumber(randomNum)
        Player.rwjl(play, {jl.details[randomNum]}, "贵族宝藏",1,1000)
    elseif monName == "仙草" then
        Player.rwjl(play, {{"仙草[任务]",1}}, "贝壳",1,0)
    elseif monName == "贝壳" then
        Player.rwjl(play, {{"贝壳",1}}, "贝壳",1,0)
    elseif monName == "紫梦花" then
        Player.rwjl(play, {{"紫梦花",1}}, "紫梦花",1,0)
    elseif monName == "赤血花" then
        Player.rwjl(play, {{"赤血花",1}}, "赤血花",1,0)
    end
    setplaydef(play, "S$采集目标", "")
    setplaydef(play, "S$采集目标名字", "")
end
function func_cjsb(play)
    setplaydef(play,"N$iscaiji",0)
    local monName = getplaydef(play,"S$采集目标名字")
    for _, api in ipairs(_collect_activity_handlers()) do
        if api and api.on_collect_fail then
            api.on_collect_fail(play, monName)
        end
    end
    setplaydef(play,"S$采集目标","")
    setplaydef(play,"S$采集目标名字","")
end
function playoffline(play)--人物大退触发
    if getconst(play,"<$SERVERNAME>") ~= "" and getbaseinfo(play,6) > 31 and getplaycountinmap(play,"xtc",0) < 200 then
        setofftimer(play,1)
        setofftimer(play,4)
        setofftimer(play,5)
        setofftimer(play,6)
        setofftimer(play,7)
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
        setofftimer(play,7)
        mapmove(play, 'xtc',137,138,8)
        offlineplay(play,9999)
    end
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
    if BwczApi and BwczApi.get_cfg then
        local bwcz_cfg = BwczApi.get_cfg()
        if bwcz_cfg and getsysvar(VarCfg["G_保卫村庄状态"]) == 1 then
            local mapName = tostring(getbaseinfo(mon, 3) or "")
            local monName = tostring(getbaseinfo(mon, 1) or "")
            if mapName == tostring(bwcz_cfg.map or "") and BwczApi.is_event_mon and BwczApi.is_event_mon(monName, bwcz_cfg) then
                return false
            end
        end
    end
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
    GameEvent.push(EventCfg.onTriggerChat, play, sMsg, chat, msgType)
    return true
end
--------------------拿沙开始触发--------------------
function castlewarstart()
    sendmovemsg("0", 1, 253, 0, 300, 2,"沙巴克攻城战：今日沙城战已开放，勇士们快快前往沙城传送了解详情，攻城时服务器不再刷新新的怪物，期间死亡不会掉落狂暴之力请保持在线以免领取不到...")
    sendmovemsg("0", 1, 249, 0, 250, 2,"沙巴克攻城战：今日沙城战已开放，勇士们快快前往沙城传送了解详情，攻城时服务器不再刷新新的怪物，期间死亡不会掉落狂暴之力请保持在线以免领取不到...")
    GameEvent.push(EventCfg.gocastlewarstart)
end
---占领沙巴克触发
function getcastle0()
    sendmovemsg("0", 1, 253, 0, 300, 2,"沙巴克攻城战：【"..castleinfo(2).."】 行会成功夺得沙城...")
    release_print("沙巴克攻城战：【"..castleinfo(2).."】 行会成功夺得沙城...")
end
--------------------拿沙结束触发--------------------
function castlewarend()
    release_print("shabakejl")
    sendmovemsg("0", 1, 253, 0, 300, 1,"沙巴克攻城战：今日沙城战已结束，所有奖励均已发放，请各位玩家及时领取...")
    sendmovemsg("0", 1, 249, 0, 250, 1,"沙巴克攻城战：今日沙城战已结束，所有奖励均已发放，请各位玩家及时领取...")
    GameEvent.push(EventCfg.goCastlewarend)
end
--进入跨服触发
function kflogin(actor)
    --同步数据
    local logindatas = {}
    GameEvent.push(EventCfg.onKFLogin, actor, logindatas)
    --跨服开启拾取小精灵
    pickupitems(actor, 0, 10, 500)
    setflagstatus(actor,VarCfg["F_是否进入过跨服"],1)
end
function kuafuend(play)--	退出跨服
    GameEvent.push(EventCfg.onKuaFuEnd, play)
    -- local szjl = json2tbl(getplaydef(play,VarCfg.T_szjl))
end
function showfashion(actor)
    local T_data = Player.getJsonTableByVar(actor, VarCfg.T_szjl)
    T_data.dqzb = T_data.dqzb or 0
    if T_data.dqzb > 0 then
    else
        Player.sendmsgEx(actor, '当前没有时装可以展示哦~')
        setbaseinfo(actor,57,0)
        return false
    end
    GameEvent.push(EventCfg.onShowFashion, actor)
end
function notshowfashion(actor)
    GameEvent.push(EventCfg.onNotShowFashion, actor)
end
local function _rename_card_finish(actor, refund)
    if not actor then
        return
    end
    local itemName = tostring(getplaydef(actor, "S$改名卡道具") or "改名卡")
    if itemName == "" then
        itemName = "改名卡"
    end
    if refund and tonumber(getplaydef(actor, "N$改名卡处理中") or 0) == 1 then
        giveitem(actor, itemName, 1)
    end
    setplaydef(actor, "N$改名卡处理中", 0)
    setplaydef(actor, "S$改名卡目标名称", "")
end

--正在查询玩家名称
function queryinghumname(actor)
    sendmsg(actor, 1, '{"Msg":"<font color=\'#ff0000\'>正在查询请稍后。。。</font>","Type":9}')
end

--名称被过滤
function humnamefilter(actor)
    _rename_card_finish(actor, true)
    sendmsg(actor, 1, '{"Msg":"<font color=\'#ff0000\'>名称被过滤。。。</font>","Type":9}')
end

--长度不符合要求
function namelengthfail(actor)
    _rename_card_finish(actor, true)
    sendmsg(actor, 1, '{"Msg":"<font color=\'#ff0000\'>长度不符合要求</font>","Type":9}')
end

--名称已经存在
function humnameexists(actor)
    _rename_card_finish(actor, true)
    sendmsg(actor, 1, '{"Msg":"<font color=\'#ff0000\'>名称已经存在</font>","Type":9}')
end

--正在执行改名操作
function changeinghumname(actor)
    sendmsg(actor, 1, '{"Msg":"<font color=\'#ff0000\'>正在修改请稍后。。。</font>","Type":9}')
end

--改名成功
function changehumnameok(actor)
    _rename_card_finish(actor, false)
    sendmsg(actor, 1, '{"Msg":"<font color=\'#ff0000\'>'..parsetext("你的名字修改成功，旧名称：<$USERNAME> 新名称：<$USERNEWNAME>！",actor)..'</font>","Type":9}')
end

--改名失败
function changehumnamefail(actor)
    _rename_card_finish(actor, true)
    sendmsg(actor, 1, '{"Msg":"<font color=\'#ff0000\'>修改名称失败</font>","Type":9}')
end
--------------------NPC点击触发--------------------
local qf_teshunpc = {
    [501] = 500, [502] = 500, [503] = 500, [504] = 500, [505] = 500, [506] = 500, [507] = 500, [508] = 500, [509] = 500, -- 世界地图
    [32] = 32, [33] = 32, [34] = 32, [35] = 32, [36] = 32, [37] = 32, [38] = 32, [39] = 32, [40] = 32,-- 转生
    [15] = 15,-- 狂暴
    [21] = 21,-- 境界修为
    [17] = 17,-- 货币兑换
    [44] = 44,-- 仙府
    [24] = 24,-- 天书
    [64] = 64,-- 灵兽
    [70] = 70, -- 狂魔乱舞
    [86] = 86, [87] = 86, [88] = 86, [89] = 86, [90] = 86, [91] = 86, -- 日卡秘境
    [93] = 93, -- 通天塔
    [105] = 105,
    [1002] = 1002,[1003] = 1003,[1004] = 1003,[1005] = 1003,[1006] = 1003,[1007] = 1003, -- 各大陆时装兑换
    [69] = 64, -- 神兽圣遗物 --这个是特殊的 前端不要的
    [6] = 6,[7] = 7,[8] = 8,[9] = 9,[10] = 10,[11] = 11,[13] = 13,[14] = 14,[24] = 24,[22] = 22,[43] = 43,[26] = 26,[28] = 28,[25] = 25,[54] = 54,[27] = 27,[44] = 44,[64] = 64,[65] = 65,[70] = 70,--小提升
    [1] = 6,[2] = 7,
    [101] = 101,
    [46] = 46, -- 灾厄入侵
}
function clicknpc(play, npcid)
    --打印
    release_print("clicknpc", "玩家："..getbaseinfo(play,1), "npcid："..npcid)
	if qf_teshunpc[npcid] then
		Npclib[qf_teshunpc[npcid]].main(play, npcid)
		return true
    elseif npcid > 200 and npcid < 500 then--地图NPC
        Npclib[200].main(play, npcid)
        return true
    elseif npcid > 500 and npcid < 520 then--大陆地图NPC
        Npclib[500].main(play, npcid)
        return true
	elseif npcid < 2000 then
		Npclib[npcid].main(play, npcid)
		return true
	end
	return false
end
-- 消息号 100，NPC点击事件，p1:NPCid,p2:按钮id,p3:额外,
--------------------消息监听触发--------------------
function handlerequest(play, msgID, p1, p2, p3, msgData)
    if p1 ~= 19 then
        release_print("handlerequest", "玩家："..getbaseinfo(play,1), "消息id："..msgID, "npcid："..p1, "按钮2："..p2, "额外3："..p3, "消息数据："..msgData)
    end
	if msgID == 100 then 
        if qf_teshunpc[p1] then --可以无视距离点击npc
            Npclib[qf_teshunpc[p1]].link(play, p1, p2, p3, msgData)
        else
            local dx = getnpcbyindex(p1)
            if dx then
                if FCheckNPCRange(play, p1, 15) then
                    if qf_teshunpc[p1] then
                        Npclib[qf_teshunpc[p1]].link(play, p1, p2, p3, msgData)
                    elseif p1 > 200 and p1 < 500 then --地图NPC
                        Npclib[200].link(play, p1, p2,p3)
                    elseif p1 > 500 and p1 < 520 then--大陆地图NPC
                        Npclib[500].link(play, p1, p2)
                    elseif p1 < 2000 then
                        Npclib[p1].link(play, p1, p2, p3, msgData)
                    end
                end
            end
        end
	elseif msgID == 101 then
		Npclib['anniu'][p1](play, p2, p3, msgData)
    elseif msgID == 105 then
        if p1 > 200 and p1 < 400 then--地图NPC
            Npclib[200].main(play, p1, p2)
        elseif p1 > 500 and p1 < 520 then--大陆地图NPC
            Npclib[500].main(play, p1, p2)
        else
            Npclib[p1].main(play, p2)
        end
	end
end

