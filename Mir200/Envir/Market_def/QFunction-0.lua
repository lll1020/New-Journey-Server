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
        setontimer(play, 4, 60, 0, 1)
        --红点系统定时器
        setontimer(play,6,60,0,1)
        delaygoto(play,10000,"ontimer6")
    end
end
--------------------跨天登录触发--------------------
local function _qf_salary_with_title_bonus(play, salary)
    if type(salary) ~= "table" then
        return salary
    end
    if not checktitle(play, "极光使者") then
        return salary
    end
    local doubled = {}
    for i, v in ipairs(salary) do
        if type(v) == "table" then
            doubled[i] = {v[1], (tonumber(v[2] or 0) or 0) * 2}
        else
            doubled[i] = v
        end
    end
    return doubled
end
function resetday(play)
    ---清理每日称号
	for _, v in pairs(constant.pz_ldql) do
		Player.title_del(play, v)
	end
    local curMap = tostring(getbaseinfo(play, ConstCfg.gbase.mapid) or "")
    local mijingMaps = { ["极光秘境"] = true, ["苍云秘境"] = true, ["若水秘境"] = true, ["红尘秘境"] = true, ["灵虚秘境"] = true, ["万灵秘境"] = true, ["诸天秘境"] = true }
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
    -- 至尊黑卡按正常使用逻辑自动触发，避免跨天后忘记领取每日奖励。
    if getbagitemcount(play, "至尊黑卡") >= 1 and type(stdmodefunc59) == "function" then
        pcall(stdmodefunc59, play, nil)
    end
    for i = #zz_cfg, 1, -1 do
        local detail = zz_cfg[i]
        local titleName = tostring((detail or {}).ch or "")
        if titleName ~= "" and checktitle(play, titleName) and type(detail.salary) == "table" and #detail.salary > 0 then
            sendmail(getbaseinfo(play, 2), 0, "至尊赞助工资", "跨天登录成功，今日【" .. titleName .. "】工资已通过邮件发放，请注意查收。", Player.jl_mail(_qf_salary_with_title_bonus(play, detail.salary)))
            zz_data.salary_date = today
            Player.setJsonVarByTable(play, VarCfg["T_免费赞助"], zz_data)
            break
        end
    end
    -- 聚宝盆每日进度：跨天清空击杀积分与自动发放标记，并刷新背包神器进度条。
    if TreasureBasin and TreasureBasin.resetDaily then
        TreasureBasin.resetDaily(play)
    else
        setplaydef(play, VarCfg["J_聚宝盆积分"], 0)
        setplaydef(play, VarCfg["J_聚宝盆领取次数"], 0)
    end
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
local function _zz516_has_teleport_cd_privilege(play)
    local zz_data = Player.getJsonTableByVar(play, VarCfg["T_免费赞助"]) or {}
    return (tonumber(zz_data["zzlb_2"] or 0) or 0) >= 1
end
local function _set_combat_until(play, varName, untilTime)
    setplaydef(play, varName, untilTime)
end
local function _is_transfer_out_of_combat(play, now)
    now = now or os.time()
    return getplaydef(play, "N$怪物脱战") < now and getplaydef(play, "N$PK脱战") < now
end
local function _transfer_combat_left(play, now)
    now = now or os.time()
    local monsterLeft = (tonumber(getplaydef(play, "N$怪物脱战") or 0) or 0) - now
    local pkLeft = (tonumber(getplaydef(play, "N$PK脱战") or 0) or 0) - now
    local left = math.max(monsterLeft, pkLeft, 0)
    return left > 0 and math.ceil(left) or 0
end
--------------------传送戒指传送前触发触发-------------------
function beginteleport(play)
    setplaydef(play,"S$dtm",getbaseinfo(play, 3))
    local sj  = os.time()
    if not _sc_has_patrol_privilege(play) then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>领取首充礼包后才可使用定点传送...</font>","Type":9}')
        return false
    end
    local cd = _zz516_has_teleport_cd_privilege(play) and 3 or 5
    if getplaydef(play,"N$buff310") == 1 then
        cd = math.max(0, cd - 5) -- 来去自如：传送冷却-5秒
    end
    if cd > 0 then
        local bl = sj - getplaydef(play,"N$传送功能CD")
        if bl < cd then
            sendmsg(play,1,'{"Msg":"传送冷却中,剩余'..math.max(1, math.ceil(cd - bl))..'秒","FColor":56,"BColor":255,"Type":1}')
            return false
        end
    end
    local du = getbaseinfo(play, 3)
    if (daluditu[du] and daluditu[du] < 3) or _is_transfer_out_of_combat(play, os.time()) then
        setplaydef(play,"N$传送功能CD",sj)
        return true
    end
    sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>战斗中不能传送,剩余' .. math.max(1, _transfer_combat_left(play, os.time())) .. '秒</font>","Type":9}')
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
local function _zxht_switch_left_seconds()
    local now = os.date("*t")
    local left = (60 - (tonumber(now.min) or 0)) * 60 - (tonumber(now.sec) or 0)
    if left <= 0 or left > 3600 then
        left = 3600
    end
    return left
end

local function _zxht_show_switch_countdown(play)
    local dt = getbaseinfo(play,3)
    if dt ~= "葬星海滩" and dt ~= "葬星海滩1" then
        return
    end
    senddelaymsg(play, "距离涨落潮切换剩余%s", _zxht_switch_left_seconds(), 250, 1)
end


function entermap(play)
    local dt = getbaseinfo(play,3)
    _zxht_show_switch_countdown(play)
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
    elseif QmdtApi and QmdtApi.is_timer_map and QmdtApi.is_timer_map(dt) then
        if QmdtApi.send_panel then
            QmdtApi.send_panel(play, QmdtApi.get_state and QmdtApi.get_state() or {}, QmdtApi.get_cfg and QmdtApi.get_cfg() or nil)
        end
        setplaydef(play,VarCfg.N_tyecmb,0)
    elseif BwczApi and BwczApi.get_cfg then
        local bwcz_cfg = BwczApi.get_cfg()
        if bwcz_cfg and dt == tostring(bwcz_cfg.map or "") and getsysvar(VarCfg["G_保卫村庄状态"]) == 1 then
            local state = BwczApi.get_state and BwczApi.get_state() or {}
            local scoreVar = tostring(bwcz_cfg.score_var or "保卫村庄")
            local payload = {
                mode = "bwcz",
                grjf = tonumber(getplayvar(play, "HUMAN", scoreVar) or 0) or 0,
                wave_name = tostring(state.current_wave_name or ""),
                left_mon = BwczApi.count_alive_monsters and BwczApi.count_alive_monsters(bwcz_cfg) or 0,
                mon_left = BwczApi.count_alive_monsters_by_wave and BwczApi.count_alive_monsters_by_wave(bwcz_cfg, state) or {},
            }
            setplaydef(play,VarCfg.N_tyecmb,1)
            sendluamsg(play,101,498,1,0,tbl2json(payload))
        else
            sendluamsg(play,101,498,2,0,"")
            setplaydef(play,VarCfg.N_tyecmb,0)
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
    if dt == "正邪大战" then
        zxdz_apply_camp(play)
        zxdz_send_rank(play)
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
    if dt == "阵营对抗" or dt == "跨服阵营对抗" or dt == "武林盟主" or dt == "正邪大战" then
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
    if where >= 77 and where <= 88 then
        local itemName = tostring(getiteminfo(play, item, ConstCfg.iteminfo.name) or "")
        local baseName = string.match(itemName, "^(.-)【") or itemName
        if baseName == "逐日弓" then
            for pos = 77, 88 do
                if pos ~= where then
                    local bodyItem = linkbodyitem(play, pos)
                    if bodyItem and bodyItem ~= "0" then
                        local bodyName = tostring(getiteminfo(play, bodyItem, ConstCfg.iteminfo.name) or "")
                        local bodyBaseName = string.match(bodyName, "^(.-)【") or bodyName
                        if bodyBaseName == "逐日弓" then
                            Player.sendmsgEx(play, "逐日弓在背包神器位同时只能装备一把#57")
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
local function _magtag_tonum(v, d)
    v = tonumber(v)
    if v == nil then
        return d or 0
    end
    return v
end

local _magtag_skill_root = {
    [1007] = 1, [1008] = 2, [1009] = 3, [1010] = 4, [1011] = 5,
    [1012] = 6, [1013] = 7, [1014] = 8, [1015] = 9, [1016] = 10,
}

local function _magtag_skill_level(play, skillId)
    local rootIdx = _magtag_skill_root[tonumber(skillId or 0)]
    local lv = 0
    if rootIdx and Player and Player.getJsonTableByVar and VarCfg and VarCfg["T_灵根"] then
        local data = Player.getJsonTableByVar(play, VarCfg["T_灵根"]) or {}
        local levels = type(data.level) == "table" and data.level or {}
        lv = tonumber(levels[tostring(rootIdx)] or 0) or 0
    end
    if lv <= 0 then
        lv = 1
    end
    if lv < 1 then lv = 1 end
    if lv > 10 then lv = 10 end
    return math.floor(lv)
end
local function _magtag_lerp(lv, minValue, maxValue)
    lv = math.max(1, math.min(10, _magtag_tonum(lv, 1)))
    if lv <= 1 then return minValue end
    if lv >= 10 then return maxValue end
    return math.floor(minValue + (maxValue - minValue) * (lv - 1) / 9 + 0.5)
end

local function _magtag_now()
    return _magtag_tonum(os.time(), 0)
end

local function _magtag_cd_ready(play, skillId, cd)
    local now = _magtag_now()
    local key = "N$magtag_cd_" .. tostring(skillId)
    local last = _magtag_tonum(getplaydef(play, key), 0)
    cd = _magtag_tonum(cd, 0)
    local cdDec = _magtag_tonum(getplaydef(play, "N$linggen_skill_cd_dec"), 0)
    if cdDec > 0 then
        if cdDec > 80 then cdDec = 80 end
        cd = math.max(1, math.floor(cd * (100 - cdDec) / 100 + 0.5))
    end
    if cd > 0 and now - last < cd then
        local left = cd - (now - last)
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>Skill cooldown '..left..'s</font>","Type":9}')
        return false
    end
    setplaydef(play, key, now)
    return true
end

local function _magtag_attack(play)
    local dc2 = 0
    if ConstCfg and ConstCfg.gbase and ConstCfg.gbase.dc2 then
        dc2 = _magtag_tonum(getbaseinfo(play, ConstCfg.gbase.dc2), 0)
    end
    dc2 = math.max(dc2, _magtag_tonum(getbaseinfo(play, 20), 0))
    if dc2 <= 0 then dc2 = 1 end
    return dc2
end

local function _magtag_xy(play)
    local x = _magtag_tonum(getbaseinfo(play, 4), 0)
    local y = _magtag_tonum(getbaseinfo(play, 5), 0)
    return x, y
end

local function _magtag_forward_xy(play, step)
    local x, y = _magtag_xy(play)
    local dirId = ConstCfg and ConstCfg.gbase and ConstCfg.gbase.dir or 69
    local dir = _magtag_tonum(getbaseinfo(play, dirId), 0)
    local dirs = {
        [0] = {0, -1}, [1] = {1, -1}, [2] = {1, 0}, [3] = {1, 1},
        [4] = {0, 1}, [5] = {-1, 1}, [6] = {-1, 0}, [7] = {-1, -1},
    }
    local d = dirs[dir] or dirs[0]
    step = math.max(1, _magtag_tonum(step, 1))
    return x + d[1] * step, y + d[2] * step
end

local function _magtag_range_damage(play, range, pct, hits, effectId, maxTargets, centerX, centerY)
    local x, y = centerX, centerY
    if not x or not y then
        x, y = _magtag_xy(play)
    end
    local hurt = math.floor(_magtag_attack(play) * _magtag_tonum(pct, 100) / 100)
    if hurt <= 0 then hurt = 1 end
    hits = math.max(1, _magtag_tonum(hits, 1))
    for _ = 1, hits do
        rangeharm(play, x, y, range or 1, hurt, 0, 0, 0, 2, effectId or 20310, maxTargets or 20)
    end
    return hurt
end

local function _magtag_play_effect(obj, effectId)
    if obj and effectId and effectId > 0 and playeffect then
        playeffect(obj, effectId, 0, 0, 1, 0, 0)
    end
end

local function _magtag_cast_feedback(play, name)
    sendmsg(play, 1, '{"Msg":"<font color=\'#c0c0c0\' size=\'14\'>释放</font><font color=\'#ff3131\' size=\'14\'>【' .. tostring(name or '') .. '】</font>","Type":9}')
end
local function _magtag_heal_self(play, pct)
    local maxhp = _magtag_tonum(getbaseinfo(play, 10), 0)
    if maxhp <= 0 then return 0 end
    local heal = math.floor(maxhp * _magtag_tonum(pct, 0) / 100)
    if heal > 0 then
        humanhp(play, "+", heal, 5, 0, play)
    end
    return heal
end

local function _magtag_set_until(play, key, duration, value)
    setplaydef(play, "N$magtag_" .. key .. "_until", _magtag_now() + _magtag_tonum(duration, 0))
    if value ~= nil then
        setplaydef(play, "N$magtag_" .. key, value)
    end
end

local function _magtag_is_active(play, key)
    return _magtag_tonum(getplaydef(play, "N$magtag_" .. key .. "_until"), 0) >= _magtag_now()
end

local function _magtag_clear(play, key)
    setplaydef(play, "N$magtag_" .. key .. "_until", 0)
    setplaydef(play, "N$magtag_" .. key, 0)
end

local function _magtag_consume_lucky_marks(play)
    local keys = {"N$magtag_lucky_mark", "N$lucky_mark", "N$xianfa_lucky_mark"}
    local count = 0
    for _, key in ipairs(keys) do
        local v = _magtag_tonum(getplaydef(play, key), 0)
        if v > count then count = v end
    end
    for _, key in ipairs(keys) do
        setplaydef(play, key, 0)
    end
    return count
end

local function _magtag_is_red_mon(Target)
    if not Target or getbaseinfo(Target, -1) then return false end
    local monName = tostring(getbaseinfo(Target, 1) or "")
    if monName == "" then return false end
    local idx = getdbmonfieldvalue(monName, "idx")
    return _magtag_tonum(getmonbaseinfo(idx, 2), 0) == 249
end

local function _magtag_open_drop_window(play, skillId, lv, duration, count, freezeSec, chancePct)
    local marks = _magtag_consume_lucky_marks(play)
    local per = _magtag_lerp(lv, 1, 10)
    _magtag_set_until(play, "drop", duration, skillId)
    setplaydef(play, "N$magtag_drop_count", count or 1)
    setplaydef(play, "N$magtag_drop_chance_pct", chancePct or 0)
    setplaydef(play, "N$magtag_drop_lucky_marks", marks)
    setplaydef(play, "N$magtag_drop_bonus_pct", marks * per)
    setplaydef(play, "N$magtag_drop_freeze_sec", freezeSec or 0)
    setplaydef(play, "S$magtag_drop_target", "")
    setplaydef(play, "S$magtag_drop_map", "")
    setplaydef(play, "N$magtag_drop_applied", 0)
    sendmsg(play, 1, '{"Msg":"<font color=\'#c0c0c0\' size=\'14\'>掉落窗口已开启</font>","Type":9}')
end

local _magtag_drop_pool_cache = nil

local function _magtag_trim(v)
    return tostring(v or ""):gsub("^%s*(.-)%s*$", "%1")
end

local function _magtag_load_drop_pool()
    if _magtag_drop_pool_cache then
        return _magtag_drop_pool_cache
    end
    local cache = {headers = {}, byHeader = {}}
    _magtag_drop_pool_cache = cache
    if not io or not io.open then
        return cache
    end
    local paths = {
        "Envir/QuestDiary/功能数据/通用爆率/地图专属装备池.txt",
        "./Envir/QuestDiary/功能数据/通用爆率/地图专属装备池.txt",
        "E:/新起航/服务端/Mir200/Envir/QuestDiary/功能数据/通用爆率/地图专属装备池.txt",
    }
    local text = nil
    for _, path in ipairs(paths) do
        local f = io.open(path, "r")
        if f then
            text = f:read("*a")
            f:close()
            break
        end
    end
    if not text then
        return cache
    end
    local current = nil
    for line in (text .. "\n"):gmatch("([^\n]*)\n") do
        line = line:gsub("\r$", "")
        local header = line:match("^%s*%[(@[^%]]+)%]")
        if header then
            current = header
            if not cache.byHeader[current] then
                cache.byHeader[current] = {}
                table.insert(cache.headers, current)
            end
        elseif current then
            local rate, item = line:match("^%s*1/(%d+)%s+(.+)%s*$")
            item = _magtag_trim(item)
            if rate and item ~= "" then
                table.insert(cache.byHeader[current], {rate = _magtag_tonum(rate, 0), name = item})
            end
        end
    end
    return cache
end

local function _magtag_pick_drop_item_by_map(mapName)
    mapName = _magtag_trim(mapName)
    if mapName == "" then
        return ""
    end
    local cache = _magtag_load_drop_pool()
    local hit = nil
    for _, header in ipairs(cache.headers or {}) do
        if header:find(mapName, 1, true) then
            hit = header
            break
        end
    end
    if not hit then
        for _, header in ipairs(cache.headers or {}) do
            local shortName = header:gsub("^@[^_]*_", ""):gsub("专属池$", "")
            if shortName ~= "" and mapName:find(shortName, 1, true) then
                hit = header
                break
            end
        end
    end
    local list = hit and cache.byHeader[hit] or nil
    if not list or #list == 0 then
        return ""
    end
    local candidates = {}
    for _, item in ipairs(list) do
        if _magtag_tonum(item.rate, 0) > 0 and _magtag_tonum(item.rate, 0) <= 50000 then
            table.insert(candidates, item)
        end
    end
    if #candidates == 0 then
        candidates = list
    end
    table.sort(candidates, function(a, b)
        return _magtag_tonum(a.rate, 0) < _magtag_tonum(b.rate, 0)
    end)
    local limit = math.min(#candidates, 5)
    return candidates[math.random(limit)].name or ""
end

local function _magtag_try_extra_drop(play, mob)
    if not play or not mob or not _magtag_is_active(play, "drop") then
        return
    end
    if not _magtag_is_red_mon(mob) then
        return
    end
    local mobName = tostring(getbaseinfo(mob, 1) or "")
    local targetName = tostring(getplaydef(play, "S$magtag_drop_target") or "")
    if targetName ~= "" and mobName ~= targetName then
        return
    end
    local mapName = tostring(getbaseinfo(mob, 3) or "")
    local mapTitle = tostring(getbaseinfo(mob, 45) or "")
    local count = math.max(1, _magtag_tonum(getplaydef(play, "N$magtag_drop_count"), 1))
    local chancePct = _magtag_tonum(getplaydef(play, "N$magtag_drop_chance_pct"), 0)
    local bonusPct = _magtag_tonum(getplaydef(play, "N$magtag_drop_bonus_pct"), 0)
    if chancePct > 0 or bonusPct > 0 then
        chancePct = chancePct + bonusPct
        local fixed = math.floor(chancePct / 100)
        local remain = chancePct - fixed * 100
        count = fixed
        if remain > 0 and math.random(100) <= remain then
            count = count + 1
        end
    end
    local dropped = 0
    for _ = 1, count do
        local itemName = _magtag_pick_drop_item_by_map(mapName)
        if itemName == "" then
            itemName = _magtag_pick_drop_item_by_map(mapTitle)
        end
        if itemName ~= "" then
            if additemtodroplist then
                additemtodroplist(play, mob, itemName)
            else
                giveitem(play, itemName, 1, 0, "magtag_extra_drop")
            end
            dropped = dropped + 1
        end
    end
    if dropped > 0 then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff3131\' size=\'14\'>额外掉落</font><font color=\'#c0c0c0\' size=\'14\'>已触发</font>","Type":9}')
    end
    _magtag_clear(play, "drop")
    setplaydef(play, "N$magtag_drop_applied", 0)
end
local function _magtag_on_attack_target(play, Target, Damage, MagicId)
    if not Target then return Damage end
    local now = _magtag_now()
    Damage = _magtag_tonum(Damage, 0)
    if _magtag_is_active(play, "jingang") and getbaseinfo(Target, -1) then
        local maxhp = _magtag_tonum(getbaseinfo(Target, 10), 0)
        local hurt = math.floor(maxhp * 15 / 100)
        local cap = _magtag_attack(play) * 10
        if cap > 0 and hurt > cap then hurt = cap end
        if hurt > 0 then
            humanhp(Target, "-", hurt, 110, 0, play, 1)
            _magtag_play_effect(Target, 60451)
        end
        _magtag_clear(play, "jingang")
    end
    local thunderHits = _magtag_tonum(getplaydef(play, "N$magtag_thunder_hits"), 0)
    if thunderHits > 0 and _magtag_is_active(play, "thunder") then
        local thunderLv = _magtag_tonum(getplaydef(play, "N$magtag_thunder_level"), 1)
        if thunderLv >= 10 then
            if ConstCfg and ConstCfg.pmode and ConstCfg.pmode.palsy then
                changemode(Target, ConstCfg.pmode.palsy, 1)
            elseif ConstCfg and ConstCfg.pmode and ConstCfg.pmode.stick then
                changemode(Target, ConstCfg.pmode.stick, 1)
            end
            if getbaseinfo(Target, -1) then
                setplaydef(Target, "N$magtag_break_def_until", now + 1)
            end
        elseif changespeedex then
            changespeedex(Target, 2, -5, 1)
        end
        setplaydef(play, "N$magtag_thunder_hits", thunderHits - 1)
        _magtag_play_effect(Target, 60452)
    end
    if _magtag_is_active(play, "drop") and _magtag_is_red_mon(Target) then
        local freezeSec = _magtag_tonum(getplaydef(play, "N$magtag_drop_freeze_sec"), 0)
        if freezeSec > 0 and ConstCfg and ConstCfg.pmode and ConstCfg.pmode.frost then
            changemode(Target, ConstCfg.pmode.frost, freezeSec)
            _magtag_play_effect(Target, 60385)
        end
        setplaydef(play, "S$magtag_drop_target", tostring(getbaseinfo(Target, 1) or ""))
        setplaydef(play, "S$magtag_drop_map", tostring(getbaseinfo(Target, 3) or ""))
        setplaydef(play, "N$magtag_drop_applied", 1)
    end
    return Damage
end

local function _magtag_apply_defense(play, Hiter, final)
    final = _magtag_tonum(final, 0)
    if final <= 0 then return final end
    if _magtag_tonum(getplaydef(play, "N$magtag_break_def_until"), 0) >= _magtag_now() then
        final = math.floor(final * 1.10)
    end
    local reduce = 0
    if _magtag_is_active(play, "heal_reduce") then
        reduce = reduce + _magtag_tonum(getplaydef(play, "N$magtag_heal_reduce"), 0)
    end
    if _magtag_is_active(play, "shanhe") then
        reduce = reduce + _magtag_tonum(getplaydef(play, "N$magtag_shanhe_reduce"), 0)
        local block = _magtag_tonum(getplaydef(play, "N$magtag_shanhe_block"), 0)
        if block > 0 and math.random(100) <= block then
            final = 0
        end
        local reflect = _magtag_tonum(getplaydef(play, "N$magtag_shanhe_reflect"), 0)
        if reflect > 0 and Hiter then
            humanhp(Hiter, "-", math.floor(final * reflect / 100), 110, 0, play, 1)
        end
    end
    if _magtag_is_active(play, "barrier") then
        reduce = reduce + _magtag_tonum(getplaydef(play, "N$magtag_barrier_reduce"), 0)
    end
    if reduce > 0 then
        if reduce > 80 then reduce = 80 end
        final = math.floor(final * (100 - reduce) / 100)
    end
    return final
end
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
        Damage = _magtag_on_attack_target(play, Target, Damage, MagicId)
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
			local zhi = getbaseinfo(play, 51, 244) * (1 + getbaseinfo(play,51,253)/ 10000)
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
        Damage = _magtag_on_attack_target(play, Target, Damage, MagicId)
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
    local showGs = gs
    local realGs = math.floor(gs / 2)
	if getplaydef(play, VarCfg.N_dqgs) ~= realGs then
		local sj = os.time()
		if sj - getplaydef(play, VarCfg.N_gscd) > 0 then
			setplaydef(play, VarCfg.N_gscd, sj)
			setplaydef(play, VarCfg.N_dqgs, realGs)
			callscriptex(play, 'changespeedex', 2, realGs)
			sendmsg(play, 1, '{"Msg":"<font color=\'#c0c0c0\' size=\'14\'>当前攻击速度+</font><font color=\'#ff3131\' size=\'14\'>' .. showGs .. '%</font>","Type":9}')
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
        _set_combat_until(play, "N$PK脱战", os.time() + 3)
	else
        _set_combat_until(play, "N$怪物脱战", os.time() + 3)
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
local function _red_mon_knock_is_red(Hiter)
    if not Hiter or getbaseinfo(Hiter, -1) then
        return false
    end
    local name = tostring(getbaseinfo(Hiter, 1) or "")
    if name == "" then
        return false
    end
    local allow = {
        ["二大陆boss"] = true,
        ["三大陆boss"] = true,
        ["四大陆boss"] = true,
        ["五大陆boss"] = true,
        ["六大陆boss"] = true,
        ["七大陆boss"] = true,
        ["八大陆boss"] = true,
        ["九大陆boss"] = true,
    }
    return allow[name] == true
end

local function _red_mon_knock_try(play, Hiter)
    if not play or not Hiter or getbaseinfo(play, ConstCfg.gbase.isdie) then
        return
    end
    if not _red_mon_knock_is_red(Hiter) then
        return
    end
    if (tonumber(getplaydef(play, "N$godstone_mountain") or 0) or 0) >= 4 then
        return
    end
    local now = os.time()
    local cdKey = "N$red_mon_knock_cd"
    local last = tonumber(getplaydef(play, cdKey) or 0) or 0
    if now - last < 2 then
        return
    end
    if math.random(100) > 20 then
        return
    end
    local px = tonumber(getbaseinfo(play, ConstCfg.gbase.x) or 0) or 0
    local py = tonumber(getbaseinfo(play, ConstCfg.gbase.y) or 0) or 0
    setplaydef(play, cdKey, now)
    rangeharm(Hiter, px, py, 0, 0, 1, 10, 1, 1, 0, 1)
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
    realDamage = _magtag_apply_defense(play, Hiter, realDamage)
    _red_mon_knock_try(play, Hiter)
    GameEvent.push(EventCfg.onProHarm, play, realDamage, Hiter, Target, MagicId)
    return realDamage
end
--------------------被攻击后触发-------------------
function struck(play, Hiter, Target, MagicId)
    if getbaseinfo(Hiter, -1) then
        _set_combat_until(play, "N$PK脱战", os.time() + 3)
    else
        _set_combat_until(play, "N$怪物脱战", os.time() + 3)
    end
end
--------------------杀怪触发-------------------
function killmon(play, mob)
    GameEvent.push(EventCfg.onKillMon, play, mob, getbaseinfo(mob, ConstCfg.gbase.idx))
    _magtag_try_extra_drop(play, mob)
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
                    sendmsg(play,1,'{"Msg":"<font color=\'#ff3131\' size=\'14\'>[鞭尸]</font><font color=\'#c0c0c0\' size=\'14\'>触发鞭尸['..mz..']</font>","FColor":253,"BColor":255,"Type":9}')
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
--------------------正邪大战-------------------
local _ZXDZ_MAP_NAME = "正邪大战"
local _ZXDZ_SCORE_VAR = "正邪大战"
local _ZXDZ_CAMP_VAR = "N$正邪大战阵营"
local _ZXDZ_STATUS_VAR = "G_正邪大战状态"
local _ZXDZ_RED_SCORE_VAR = "G_正邪大战正方积分"
local _ZXDZ_BLUE_SCORE_VAR = "G_正邪大战邪方积分"
local _ZXDZ_REWARDS = {
    rank = {{"跨服积分", 30}, {"跨服积分", 20}, {"跨服积分", 15}},
    win = {{"跨服积分", 50}},
    join = {{"跨服积分", 20}},
}
local function _zxdz_toint(v, d)
    return tonumber(v or d or 0) or d or 0
end
local function _zxdz_add_kf_point(play, amount)
    amount = _zxdz_toint(amount, 0)
    if not play or amount <= 0 then return end
    local varName = VarCfg["U_跨服积分"] or "U49"
    setplaydef(play, varName, _zxdz_toint(getplaydef(play, varName), 0) + amount)
end
local function _zxdz_give_reward(play, reward, reason)
    if not play or type(reward) ~= "table" then return end
    local mail = {}
    for _, item in ipairs(reward) do
        if type(item) == "table" then
            local name = tostring(item[1] or "")
            local count = _zxdz_toint(item[2], 0)
            if name == "跨服积分" then
                _zxdz_add_kf_point(play, count)
            elseif name ~= "" and count > 0 then
                mail[#mail + 1] = {name, count}
            end
        end
    end
    if #mail > 0 then
        sendmail(getbaseinfo(play, 2), 0, reason or "正邪大战", "正邪大战奖励已发放，请及时提取。", Player.jl_mail(mail))
    end
end
function zxdz_send_rank(play)
    if not play then return end
    sendluamsg(play, 101, 498, 1, 0, '{"mode":"zxdz","pmsj":' .. tbl2json(sorthumvar(_ZXDZ_SCORE_VAR, 1, 1, 5)) .. ',"grjf":' .. _zxdz_toint(getplayvar(play, "HUMAN", _ZXDZ_SCORE_VAR), 0) .. ',"hjf":' .. _zxdz_toint(getsysvar(_ZXDZ_RED_SCORE_VAR), 0) .. ',"ljf":' .. _zxdz_toint(getsysvar(_ZXDZ_BLUE_SCORE_VAR), 0) .. '}')
end
function zxdz_apply_camp(play)
    if not play then return 0 end
    local camp = _zxdz_toint(getplaydef(play, _ZXDZ_CAMP_VAR), 0)
    if camp <= 0 then
        local red = _zxdz_toint(getsysvar(_ZXDZ_RED_SCORE_VAR), 0)
        local blue = _zxdz_toint(getsysvar(_ZXDZ_BLUE_SCORE_VAR), 0)
        camp = red <= blue and 1 or 2
        setplaydef(play, _ZXDZ_CAMP_VAR, camp)
    end
    if camp == 1 then
        setcamp(play, 1)
        changenamecolor(play, 69)
        playeffect(play, 11502, 0, 0, 0, 1, 0)
    else
        setcamp(play, 2)
        changenamecolor(play, 180)
        playeffect(play, 11506, 0, 0, 0, 1, 0)
    end
    setattackmode(play, 8, 100)
    return camp
end
function zxdz_enter(play)
    if not checkkuafu(play) and not checkkuafuconnect() then
        Player.sendmsgEx(play, "跨服未开启，暂时无法参加正邪大战#57")
        return false
    end
    if _zxdz_toint(getsysvar(_ZXDZ_STATUS_VAR), 0) ~= 1 then
        Player.sendmsgEx(play, "正邪大战当前未开启#57")
        return false
    end
    zxdz_apply_camp(play)
    mapmove(play, _ZXDZ_MAP_NAME, 33, 37, 8)
    return true
end
function jqr_zxdz_start()
    if (tonumber(getsysvar(VarCfg["G_开区分钟"]) or 0) or 0) < 1440 then
        release_print("正邪大战未开启：开服未满第二天")
        return false
    end
    if not checkkuafuconnect() then
        release_print("正邪大战未开启：跨服未连接")
        return false
    end
    clearhumcustvar("*", _ZXDZ_SCORE_VAR)
    setsysvar(_ZXDZ_STATUS_VAR, 1)
    setsysvar(_ZXDZ_RED_SCORE_VAR, 0)
    setsysvar(_ZXDZ_BLUE_SCORE_VAR, 0)
    setenvirontimer(_ZXDZ_MAP_NAME, 8, 3, "@hd_tcppk," .. _ZXDZ_MAP_NAME)
    sendmovemsg("0", 1, 254, 0, 300, 1, "活动：活动《正邪大战》已开启，自动分配正邪阵营，请尽快参加活动...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "活动：活动《正邪大战》已开启，自动分配正邪阵营，请尽快参加活动...")
    for _, player in ipairs(getplayerlst() or {}) do
        sendluamsg(player, 101, 12, 1, 8, '{"sk":10,"kf":2,"idx":8}')
    end
end
function zxdz_map_tick()
    if _zxdz_toint(getsysvar(_ZXDZ_STATUS_VAR), 0) ~= 1 then return end
    local players = getobjectinmap(_ZXDZ_MAP_NAME, 34, 33, 100, 1)
    for _, v in pairs(players or {}) do
        local camp = zxdz_apply_camp(v)
        local jf = getplayvar(v, "HUMAN", _ZXDZ_SCORE_VAR) + 1
        setplayvar(v, "HUMAN", _ZXDZ_SCORE_VAR, jf, 1)
        if camp == 1 then
            setsysvar(_ZXDZ_RED_SCORE_VAR, _zxdz_toint(getsysvar(_ZXDZ_RED_SCORE_VAR), 0) + 1)
        else
            setsysvar(_ZXDZ_BLUE_SCORE_VAR, _zxdz_toint(getsysvar(_ZXDZ_BLUE_SCORE_VAR), 0) + 1)
        end
        zxdz_send_rank(v)
    end
end

function jqr_zxdz_end()
    setenvirofftimer(_ZXDZ_MAP_NAME, 8)
    setsysvar(_ZXDZ_STATUS_VAR, 0)
    local rank = sorthumvar(_ZXDZ_SCORE_VAR, 1, 1, 5) or {}
    local top = {}
    for i = 1, #rank, 2 do
        local pos = math.floor((i + 1) / 2)
        local name = rank[i]
        local score = _zxdz_toint(rank[i + 1], 0)
        if pos <= 3 and name and score > 0 then
            local p = getplayerbyname(name)
            if p then
                top[getbaseinfo(p, 2)] = true
                _zxdz_give_reward(p, _ZXDZ_REWARDS.rank[pos], "正邪大战第" .. pos .. "名奖励")
            end
        end
    end
    local redScore = _zxdz_toint(getsysvar(_ZXDZ_RED_SCORE_VAR), 0)
    local blueScore = _zxdz_toint(getsysvar(_ZXDZ_BLUE_SCORE_VAR), 0)
    local winCamp = redScore >= blueScore and 1 or 2
    for _, player in ipairs(getplayerlst() or {}) do
        if _zxdz_toint(getplayvar(player, "HUMAN", _ZXDZ_SCORE_VAR), 0) > 0 then
            local roleId = getbaseinfo(player, 2)
            if not top[roleId] then
                local camp = _zxdz_toint(getplaydef(player, _ZXDZ_CAMP_VAR), 0)
                _zxdz_give_reward(player, camp == winCamp and _ZXDZ_REWARDS.win or _ZXDZ_REWARDS.join, camp == winCamp and "正邪大战胜利方奖励" or "正邪大战失败方奖励")
            end
        end
        if getbaseinfo(player, 3) == _ZXDZ_MAP_NAME then
            sendluamsg(player, 101, 498, 2, 0, "")
            mapmove(player, "xtc", 137, 138, 8)
        end
        if _zxdz_toint(getplaydef(player, _ZXDZ_CAMP_VAR), 0) > 0 then
            setplaydef(player, _ZXDZ_CAMP_VAR, 0)
            setcamp(player, 0)
            changenamecolor(player, 255)
        end
        sendluamsg(player, 101, 12, 4, 8, getsysvar(VarCfg.G_kqfz))
    end
    sendmovemsg("0", 1, 254, 0, 300, 1, "活动：活动《正邪大战》已结束，胜利阵营为【" .. (winCamp == 1 and "正方" or "邪方") .. "】...")
    clearhumcustvar("*", _ZXDZ_SCORE_VAR)
end
--------------------杀死玩家触发-------------------
function killplay(play,hiter)
    -- 杀人事件：派发给监听模块（如天书仙法）
    GameEvent.push(EventCfg.onkillplay, play, hiter)
    local srsl = tonumber(getplaydef(play,VarCfg.U_srsl) or 0) or 0
    setplaydef(play,VarCfg.U_srsl,srsl + 1)
    login_fhsx(play)
    local kqfz = tonumber(getsysvar(VarCfg.G_kqfz) or 0) or 0
    if kqfz >= 40 and kqfz <= 50 then
        local jf = (tonumber(getplayvar(play, "HUMAN", "比武大会") or 0) or 0) + 50
        setplayvar(play, "HUMAN", "比武大会", jf, 1)
        sendmsg(play,1,'{"Msg":"比武大会：当前积分:'..jf..'","FColor":253,"BColor":255,"Type":1}')
        if hiter then
            jf = (tonumber(getplayvar(hiter, "HUMAN", "比武大会") or 0) or 0) + 10
            setplayvar(hiter, "HUMAN", "比武大会", jf, 1)
            Player.sendmsgEx(hiter,1,'{"Msg":"比武大会：当前积分:'..jf..'","FColor":253,"BColor":255,"Type":1}')
        end
    end
    if getbaseinfo(play, 3) == _ZXDZ_MAP_NAME and _zxdz_toint(getsysvar(_ZXDZ_STATUS_VAR), 0) == 1 then
        local jf = (tonumber(getplayvar(play, "HUMAN", _ZXDZ_SCORE_VAR) or 0) or 0) + 50
        setplayvar(play, "HUMAN", _ZXDZ_SCORE_VAR, jf, 1)
        if _zxdz_toint(getplaydef(play, _ZXDZ_CAMP_VAR), 0) == 1 then
            setsysvar(_ZXDZ_RED_SCORE_VAR, _zxdz_toint(getsysvar(_ZXDZ_RED_SCORE_VAR), 0) + 50)
            setsysvar(_ZXDZ_BLUE_SCORE_VAR, _zxdz_toint(getsysvar(_ZXDZ_BLUE_SCORE_VAR), 0) + 25)
        else
            setsysvar(_ZXDZ_BLUE_SCORE_VAR, _zxdz_toint(getsysvar(_ZXDZ_BLUE_SCORE_VAR), 0) + 50)
            setsysvar(_ZXDZ_RED_SCORE_VAR, _zxdz_toint(getsysvar(_ZXDZ_RED_SCORE_VAR), 0) + 25)
        end
        sendmsg(play, 1, '{"Msg":"正邪大战：当前积分:' .. jf .. '","FColor":253,"BColor":255,"Type":1}')
        zxdz_send_rank(play)
        if hiter and getbaseinfo(hiter, 3) == _ZXDZ_MAP_NAME then
            local bjf = (tonumber(getplayvar(hiter, "HUMAN", _ZXDZ_SCORE_VAR) or 0) or 0) + 10
            setplayvar(hiter, "HUMAN", _ZXDZ_SCORE_VAR, bjf, 1)
            zxdz_send_rank(hiter)
        end
    end
end

local function _is_gray_world_map_name(mapName)
    if Player and Player.isHuiJieMap then
        return Player.isHuiJieMap(mapName)
    end
    mapName = tostring(mapName or "")
    return string.find(mapName, "灰界", 1, true) ~= nil
        or mapName == "虚妄山脉"
        or mapName == "山脉入口"
        or mapName == "叹息旷野"
        or mapName == "恐怖裂隙"
        or mapName == "鬼嘲深渊"
        or mapName == "旷野之原"
        or mapName == "禁忌之海"
        or mapName == "海峰孤岛"
end
local function _build_first_gray_world_death_mail_tip(play)
    if not play then
        return "", nil
    end
    if tonumber(getplaydef(play, "N$gray_world_death_mail") or 0) == 1 then
        return "", nil
    end
    local mapName = tostring(getbaseinfo(play, 45) or "")
    local mapIdName = tostring(getbaseinfo(play, 3) or "")
    if not _is_gray_world_map_name(mapName) and not _is_gray_world_map_name(mapIdName) then
        return "", nil
    end
    setplaydef(play, "N$gray_world_death_mail", 1)
    local tip = "灰界系列地图存在特殊压制BUFF：未破除前，你在灰界系列地图对怪伤害会降低，受到灰界怪物伤害会提升。若想破除灰界对你的影响，请获得称号【诸邪退散】。"
    return tip, Player.jl_mail({{"诸邪退散[称号]", 0}})
end
--------------------玩家死亡触发-------------------
function playdie(play, hiter)
    local dt,x,y = getbaseinfo(play,3),getbaseinfo(play,4),getbaseinfo(play,5)
    local grayTip, grayIcon = _build_first_gray_world_death_mail_tip(play)
    local deathContent = "您被["..getbaseinfo(hiter, 1).."]在"..getbaseinfo(play,45).."("..x.."."..y..")杀害了..." .. tostring(grayTip ~= "" and " " .. grayTip or "")
    if grayIcon and grayIcon ~= "" then
        sendmail("#" .. getbaseinfo(play, 1), 1, "系统提示", deathContent, grayIcon)
    else
        sendmail("#" .. getbaseinfo(play, 1), 1, "系统提示", deathContent)
    end
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
    if Npclib and Npclib[102] and type(Npclib[102].tryAutoSend) == "function" then
        Npclib[102].tryAutoSend(play)
    end
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
    if querymoney(play,23) >= teshudata["npc_20"].cost and not checktitle(play,"天下谁人不识君") then
        messagebox(play,"累计充值数量已达到,可以去领取冠名奖励了")
        Npclib[20].link(play, 20, 1)
    end
end
--------------------充值触发-------------------
function recharge(play, Gold, ProductId, MoneyId, isReal)
    release_print("充值触发","玩家："..getbaseinfo(play,1), "金额："..Gold, "订单:"..ProductId, "货币id:"..MoneyId, "是否真充:"..(isReal and "是" or "否"))
    setplaydef(play,VarCfg["U_真实充值"],getplaydef(play,VarCfg["U_真实充值"])+Gold)

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
function magselffunc1007(play)  -- 惊雷斩
    local skillId = 1007
    local lv = _magtag_skill_level(play, skillId)
    if not _magtag_cd_ready(play, skillId, 12) then return end
    _magtag_cast_feedback(play, "惊雷斩")
    local pct = _magtag_lerp(lv, 80, 200)
    local x, y = _magtag_forward_xy(play, 2)
    _magtag_range_damage(play, 1, pct, 3, 60451, 12, x, y)
    if lv >= 10 then
        _magtag_set_until(play, "jingang", 5, 1)
    end
end
function magselffunc1008(play)  -- 万物回春
    local skillId = 1008
    local lv = _magtag_skill_level(play, skillId)
    if not _magtag_cd_ready(play, skillId, 45) then return end
    _magtag_cast_feedback(play, "万物回春")
    _magtag_play_effect(play, 60462)
    local healPct = _magtag_lerp(lv, 15, 35)
    local reduce = _magtag_lerp(lv, 4, 12)
    _magtag_heal_self(play, healPct)
    _magtag_set_until(play, "heal_reduce", 3, reduce)
    setplaydef(play, "N$magtag_heal_reduce", reduce)
end
function magselffunc1009(play)  -- 寻宝天眼
    local skillId = 1009
    local lv = _magtag_skill_level(play, skillId)
    if not _magtag_cd_ready(play, skillId, 45) then return end
    _magtag_cast_feedback(play, "寻宝天眼")
    _magtag_play_effect(play, 60460)
    _magtag_open_drop_window(play, skillId, lv, 5, 1, 0, _magtag_lerp(lv, 20, 200))
end
function magselffunc1010(play)  -- 烈焰旋风
    local skillId = 1010
    local lv = _magtag_skill_level(play, skillId)
    if not _magtag_cd_ready(play, skillId, 10) then return end
    _magtag_cast_feedback(play, "烈焰旋风")
    local pct = _magtag_lerp(lv, 50, 110)
    _magtag_range_damage(play, 1, pct, 1, 60463, 16)
end
function magselffunc1011(play)  -- 山河霸体
    local skillId = 1011
    local lv = _magtag_skill_level(play, skillId)
    if not _magtag_cd_ready(play, skillId, 25) then return end
    _magtag_cast_feedback(play, "山河霸体")
    _magtag_play_effect(play, 60458)
    local reduce = _magtag_lerp(lv, 7, 18)
    local reflect = _magtag_lerp(lv, 1, 10)
    local block = _magtag_lerp(lv, 1, 10)
    _magtag_set_until(play, "shanhe", 5, 1)
    setplaydef(play, "N$magtag_shanhe_reduce", reduce)
    setplaydef(play, "N$magtag_shanhe_reflect", reflect)
    setplaydef(play, "N$magtag_shanhe_block", block)
end
function magselffunc1012(play)  -- 雷霆灭世斩
    local skillId = 1012
    local lv = _magtag_skill_level(play, skillId)
    if not _magtag_cd_ready(play, skillId, 15) then return end
    _magtag_cast_feedback(play, "雷霆灭世斩")
    local pct = _magtag_lerp(lv, 50, 90)
    local x, y = _magtag_forward_xy(play, 2)
    _magtag_range_damage(play, 2, pct, 5, 60452, 16, x, y)
    _magtag_set_until(play, "thunder", 5, 1)
    setplaydef(play, "N$magtag_thunder_hits", 5)
    setplaydef(play, "N$magtag_thunder_level", lv)
end
function magselffunc1013(play)  -- 风影重生
    local skillId = 1013
    local lv = _magtag_skill_level(play, skillId)
    if not _magtag_cd_ready(play, skillId, 35) then return end
    _magtag_cast_feedback(play, "风影重生")
    _magtag_play_effect(play, 60384)
    local healPct = _magtag_lerp(lv, 20, 45)
    local duration = _magtag_lerp(lv, 4, 8)
    local speed = _magtag_lerp(lv, 5, 30)
    local healUp = _magtag_lerp(lv, 0, 25)
    _magtag_heal_self(play, healPct)
    if changespeedex then
        changespeedex(play, 1, speed, duration)
    end
    _magtag_set_until(play, "heal_up", duration, healUp)
    setplaydef(play, "N$magtag_heal_up", healUp)
end
function magselffunc1014(play)  -- 寒霜祈运
    local skillId = 1014
    local lv = _magtag_skill_level(play, skillId)
    if not _magtag_cd_ready(play, skillId, 50) then return end
    _magtag_cast_feedback(play, "寒霜祈运")
    _magtag_play_effect(play, 60385)
    local dropCount = lv >= 10 and 2 or 1
    local freezeSec = lv >= 10 and 3 or 1
    _magtag_open_drop_window(play, skillId, lv, 5, dropCount, freezeSec)
end
function magselffunc1015(play)  -- 焚天炼狱
    local skillId = 1015
    local lv = _magtag_skill_level(play, skillId)
    if not _magtag_cd_ready(play, skillId, 15) then return end
    _magtag_cast_feedback(play, "焚天炼狱")
    local pct = _magtag_lerp(lv, 60, 120)
    _magtag_range_damage(play, 12, pct, 3, 20311, 30)
end
function magselffunc1016(play)  -- 镇岳结界
    local skillId = 1016
    local lv = _magtag_skill_level(play, skillId)
    if not _magtag_cd_ready(play, skillId, 25) then return end
    _magtag_cast_feedback(play, "镇岳结界")
    _magtag_play_effect(play, 14228)
    local duration = _magtag_lerp(lv, 5, 8)
    local reduce = _magtag_lerp(lv, 10, 25)
    local shareReduce = _magtag_lerp(lv, 5, 10)
    _magtag_set_until(play, "barrier", duration, 1)
    setplaydef(play, "N$magtag_barrier_reduce", reduce)
    local group = getgroupmember and (getgroupmember(play) or {}) or {}
    local mapId = tostring(getbaseinfo(play, 3) or "")
    local x, y = _magtag_xy(play)
    local myGuild = getmyguild and tostring(getmyguild(play) or "") or ""
    for _, member in ipairs(group) do
        if member and member ~= play and tostring(getbaseinfo(member, 3) or "") == mapId then
            local mx = _magtag_tonum(getbaseinfo(member, 4), 0)
            local my = _magtag_tonum(getbaseinfo(member, 5), 0)
            local memberGuild = getmyguild and tostring(getmyguild(member) or "") or ""
            if math.abs(mx - x) <= 4 and math.abs(my - y) <= 4 and memberGuild ~= "" and memberGuild == myGuild then
                _magtag_set_until(member, "barrier", duration, 1)
                setplaydef(member, "N$magtag_barrier_reduce", shareReduce)
                _magtag_play_effect(member, 14228)
            end
        end
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

--------------------机器人触发脚本-------------------天下第一武道会
local function _wdh_module()
    return dofile('Envir/Lua/Npc/1011.lua')
end
function jqr_wudaohui_start()
    if (tonumber(getsysvar(VarCfg["G_开区分钟"]) or 0) or 0) < 1440 then
        release_print("武道大会未开启：开服未满第二天")
        return false
    end
    if not checkkuafuconnect() then
        release_print("武道大会未开启：跨服未连接")
        return false
    end
    local mod = _wdh_module()
    if mod and rawget(_G, "__wudaohui_module") and __wudaohui_module.start then
        __wudaohui_module.start()
    end
end
function jqr_wudaohui_end()
    local mod = _wdh_module()
    if mod and rawget(_G, "__wudaohui_module") and __wudaohui_module.stop then
        __wudaohui_module.stop()
    end
end
function jqr_wudaohui_rank_reward()
    local mod = _wdh_module()
    if mod and rawget(_G, "__wudaohui_module") and __wudaohui_module.rankReward then
        __wudaohui_module.rankReward()
    end
end
function qf_kfdz(xt, mapIdx)
    local mod = _wdh_module()
    if mod and rawget(_G, "__wudaohui_module") and __wudaohui_module.settle then
        __wudaohui_module.settle(mapIdx)
    end
end
function kf_slwj(play, mapIdx)
    local mod = _wdh_module()
    if mod and rawget(_G, "__wudaohui_module") and __wudaohui_module.leave then
        __wudaohui_module.leave(play, mapIdx)
    end
end
function qf_kfjinrdt(xt, play1, play2, mapIdx)
    local mod = _wdh_module()
    if mod and rawget(_G, "__wudaohui_module") and __wudaohui_module.enterBattle then
        __wudaohui_module.enterBattle(play1, play2, mapIdx)
    end
end
function bfsyscall22(actor, arg1, arg2)
    local mod = _wdh_module()
    if mod and rawget(_G, "__wudaohui_module") and __wudaohui_module.queueUpdate then
        __wudaohui_module.queueUpdate(actor, arg1, arg2)
    end
end
function bfsyscall23(actor, arg1, arg2)
    local mod = _wdh_module()
    if mod and rawget(_G, "__wudaohui_module") and __wudaohui_module.receiveOpponentPreview then
        __wudaohui_module.receiveOpponentPreview(actor, arg2)
    end
end
function kfsyscall22(actor, arg1, arg2)
    local mod = _wdh_module()
    if mod and rawget(_G, "__wudaohui_module") and __wudaohui_module.matchSuccess then
        __wudaohui_module.matchSuccess(actor, arg2)
    end
end
function kfsyscall23(actor, arg1, arg2)
    local mod = _wdh_module()
    if mod and rawget(_G, "__wudaohui_module") and __wudaohui_module.receiveHistory then
        __wudaohui_module.receiveHistory(actor, arg1, arg2)
    end
end
function kfsyscall50(actor, arg1, arg2)
    local mod = _wdh_module()
    if mod and rawget(_G, "__wudaohui_module") and __wudaohui_module.receiveCrossReward then
        if __wudaohui_module.receiveCrossReward(actor, arg1, arg2) then
            return
        end
    end
    sendmail(getbaseinfo(actor, 2), 0, "奖励", arg1, arg2)
end
function qf_kfdzdjs(play)
    local mod = _wdh_module()
    if mod and rawget(_G, "__wudaohui_module") and __wudaohui_module.battleCountdown then
        __wudaohui_module.battleCountdown(play)
    end
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
function jqr_kuafu_mon_spawn()
    if not checkkuafuconnect() then
        release_print("跨服地图刷怪跳过：跨服未连接")
        return
    end
    local spawn_list = {
        {"幽邃地窟", 32, 32, "幽邃小怪—[跨服]",30},
        {"幽邃地窟", 35, 35, "幽邃精英—[跨服]",30},
        {"摄魂红尘", 32, 32, "摄魂小怪—[跨服]",30},
        {"摄魂红尘", 35, 35, "摄魂精英—[跨服]",30},
        {"逆灵离心", 32, 32, "逆灵小怪—[跨服]",30},
        {"逆灵离心", 35, 35, "逆灵精英—[跨服]",30},
        {"生死之门", 32, 32, "生死小怪—[跨服]",30},
        {"生死之门", 35, 35, "生死精英—[跨服]",30},
        {"跨服秘境", 28, 28, "跨服小怪—[跨服]",30},
        {"跨服秘境", 32, 32, "跨服精英—[跨服]",30},
        {"跨服秘境", 36, 36, "跨服boss—[跨服]",3},
    }
    for _, row in ipairs(spawn_list) do
        genmonex(row[1], row[2], row[3], row[4], 9999, row[5], 0, 54, "", 0)
    end
    release_print("跨服地图定时刷怪完成", #spawn_list)
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
-- 角色限时装备到期触发;
function itemexpired(role,itemobj)
    release_print("角色限时装备到期触发","角色ID："..getbaseinfo(role,1),"物品ID："..getbaseinfo(itemobj,1))
    local petNpc = Npclib and Npclib[64]
    if petNpc and type(petNpc.onBabyExpired) == "function" then
        local ok, err = pcall(petNpc.onBabyExpired, role, itemobj)
        if not ok then
            release_print("[灵兽幼崽到期]处理失败", err)
        end
    end
end
--------------------宠物攻击伤害前触发-------------------
local _lingshou_cut_damage = 10000
local _lingshou_pet_index = {
    ["麒麟"] = 1,
    ["青龙"] = 2,
    ["朱雀"] = 3,
    ["白虎"] = 4,
    ["玄武"] = 5,
}

local function _lingshou_get_owner(Hiter)
    if Hiter and getbaseinfo(Hiter, ConstCfg.gbase.isplayer) then
        return Hiter
    end
    return nil
end

local function _lingshou_get_level(play, petName)
    local idx = _lingshou_pet_index[petName]
    if not idx then return 0 end
    local data = Player.getJsonTableByVar(play, VarCfg["T_灵兽"]) or {}
    if tonumber(data.dqzh or 0) ~= idx then
        return 0
    end
    local ls = data.ls or {}
    return tonumber(ls[tostring(idx)] or 0) or 0
end

local function _lingshou_has_active_skill(play, petName)
    local level = _lingshou_get_level(play, petName)
    local cfg = (teshudata and teshudata["npc_64"] and teshudata["npc_64"].config) or {}
    local maxLevel = tonumber(cfg.wy and cfg.wy.max_level or 10) or 10
    local det = cfg.wy and cfg.wy.det and cfg.wy.det[level] or nil
    return level >= maxLevel and det and det.s_skill == true
end

local function _lingshou_skill_ready(play, petName, cd)
    local now = os.time()
    local key = "N$灵兽技能CD_" .. tostring(petName or "")
    if now - (tonumber(getplaydef(play, key) or 0) or 0) < (tonumber(cd) or 10) then
        return false
    end
    setplaydef(play, key, now)
    return true
end

local function _lingshou_target_xy(Target)
    return tonumber(getbaseinfo(Target, ConstCfg.gbase.x) or 0) or 0,
        tonumber(getbaseinfo(Target, ConstCfg.gbase.y) or 0) or 0
end

local function _lingshou_root_level(play, idx)
    local data = Player.getJsonTableByVar(play, VarCfg["T_灵根"]) or {}
    local level = data.level or {}
    return tonumber(level[tostring(idx)] or 0) or 0
end

local function _lingshou_safe_effect(Target, effectId)
    if playeffect and Target and effectId and effectId > 0 then
        playeffect(Target, effectId, 0, 0, 1, 0, 0)
    end
end

local _lingshou_skills = {
    ["麒麟"] = function(play, Target)
        local x, y = _lingshou_target_xy(Target)
        rangeharm(play, x, y, 2, 1, 0, 0, 0, 2, 20310, 12)
        changemode(Target, ConstCfg.pmode.stick, 1)
        _lingshou_safe_effect(Target, 60456)
    end,
    ["青龙"] = function(play, Target)
        local hurt = (_lingshou_root_level(play, 2) + _lingshou_root_level(play, 7)) * 10000
        if hurt <= 0 then hurt = 10000 end
        local x, y = _lingshou_target_xy(Target)
        rangeharm(play, x, y, 4, hurt, 0, 0, 0, 2, 20310, 16)
        _lingshou_safe_effect(Target, 60456)
    end,
    ["朱雀"] = function(play, Target)
        local x, y = _lingshou_target_xy(Target)
        rangeharm(play, x, y, 12, 10000, 0, 0, 0, 2, 20310, 24)
        _lingshou_safe_effect(Target, 60456)
    end,
    ["白虎"] = function(play, Target)
        local x, y = _lingshou_target_xy(Target)
        rangeharm(play, x, y, 1, 50000, 0, 0, 0, 2, 20310, 12)
        _lingshou_safe_effect(Target, 60456)
    end,
    ["玄武"] = function(play, Target)
        local x, y = _lingshou_target_xy(Target)
        rangeharm(play, x, y, 2, 50000, 0, 0, 0, 2, 20310, 12)
        changemode(Target, ConstCfg.pmode.frost, 1)
        _lingshou_safe_effect(Target, 60456)
    end,
}

function attackdamagebb(self,Target,Hiter,MagicId,Damage)
    if self and Target and not getbaseinfo(Target, ConstCfg.gbase.isplayer) then
        local petName = tostring(getbaseinfo(self, 1) or "")
        if _lingshou_pet_index[petName] then
            local play = _lingshou_get_owner(Hiter)
            if play and _lingshou_has_active_skill(play, petName) and _lingshou_skill_ready(play, petName, 10) then
                local skill = _lingshou_skills[petName]
                if skill then
                    local ok, err = pcall(skill, play, Target)
                    if not ok then
                        release_print("[灵兽技能]触发失败", petName, err)
                    end
                end
            end
            return (tonumber(Damage) or 0) + _lingshou_cut_damage
        end
    end
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
    [102] = 102,
    [1011] = 1011, -- 武道大会/跨服PK
    [9998] = 9998, -- rename card ui
    [46] = 46, -- 灾厄入侵
    [1028] = 16, -- 沙巴克
    [53] = 53, -- 神石
    [106] = 106, -- 神石
    [623] = 623, -- 可能会卡tp的 npc
}
function clicknpc(play, npcid)
    --打印
    release_print("clicknpc", "玩家："..getbaseinfo(play,1), "npcid："..npcid)
	if qf_teshunpc[npcid] then
        local mod = Npclib[qf_teshunpc[npcid]]
        if mod and mod.main then
            mod.main(play, npcid)
        else
            release_print("clicknpc", "NPC模块不存在", "npcid："..npcid, "映射："..qf_teshunpc[npcid])
        end
		return true
    elseif npcid > 200 and npcid < 500 then--地图NPC
        if Npclib[200] and Npclib[200].main then Npclib[200].main(play, npcid) else release_print("clicknpc", "NPC模块不存在", "npcid：200") end
        return true
    elseif npcid > 500 and npcid < 520 then--大陆地图NPC
        if Npclib[500] and Npclib[500].main then Npclib[500].main(play, npcid) else release_print("clicknpc", "NPC模块不存在", "npcid：500") end
        return true
	elseif npcid < 2000 then
        local mod = Npclib[npcid]
        if mod and mod.main then
            mod.main(play, npcid)
        else
            release_print("clicknpc", "NPC模块不存在", "npcid："..npcid)
        end
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
            local mod = Npclib[qf_teshunpc[p1]]
            if mod and mod.link then
                mod.link(play, p1, p2, p3, msgData)
            else
                release_print("handlerequest", "NPC模块不存在", "npcid："..p1, "映射："..qf_teshunpc[p1])
            end
        else
            local dx = getnpcbyindex(p1)
            if dx then
                if FCheckNPCRange(play, p1, 15) then
                    if qf_teshunpc[p1] then
                        local mod = Npclib[qf_teshunpc[p1]]
                        if mod and mod.link then
                            mod.link(play, p1, p2, p3, msgData)
                        else
                            release_print("handlerequest", "NPC模块不存在", "npcid："..p1, "映射："..qf_teshunpc[p1])
                        end
                    elseif p1 > 200 and p1 < 500 then --地图NPC
                        if Npclib[200] and Npclib[200].link then Npclib[200].link(play, p1, p2,p3) else release_print("handlerequest", "NPC模块不存在", "npcid：200") end
                    elseif p1 > 500 and p1 < 520 then--大陆地图NPC
                        if Npclib[500] and Npclib[500].link then Npclib[500].link(play, p1, p2) else release_print("handlerequest", "NPC模块不存在", "npcid：500") end
                    elseif p1 < 2000 then
                        local mod = Npclib[p1]
                        if mod and mod.link then
                            mod.link(play, p1, p2, p3, msgData)
                        else
                            release_print("handlerequest", "NPC模块不存在", "npcid："..p1)
                        end
                    end
                end
            end
        end
	elseif msgID == 101 then
		if Npclib['anniu'] and Npclib['anniu'][p1] then Npclib['anniu'][p1](play, p2, p3, msgData) else release_print("handlerequest", "按钮模块不存在", "按钮："..p1) end
    elseif msgID == 105 and p1 ~= 675 then
        if p1 == 64 and p2 == 0 and p3 == 1064 then
            if Npclib[64] and Npclib[64].syncContractState then Npclib[64].syncContractState(play) else release_print("handlerequest", "NPC同步接口不存在", "npcid：64") end
            return
        end
        if p1 == 64 and (p2 == 64 or p2 == 1064) then
            local openNpcid = (p2 == 1064) and 1064 or 64
            if Npclib[64] and Npclib[64].main then Npclib[64].main(play, openNpcid) else release_print("handlerequest", "NPC模块不存在", "npcid：64") end
            return
        end
        if qf_teshunpc[p1] then
            local mod = Npclib[qf_teshunpc[p1]]
            if mod and mod.main then
                mod.main(play, p1)
            else
                release_print("handlerequest", "NPC模块不存在", "npcid："..p1, "映射："..qf_teshunpc[p1])
            end
        elseif p1 > 200 and p1 < 500 then--地图NPC
            if Npclib[200] and Npclib[200].main then Npclib[200].main(play, p1, p2) else release_print("handlerequest", "NPC模块不存在", "npcid：200") end
        elseif p1 > 500 and p1 < 520 then--大陆地图NPC
            if Npclib[500] and Npclib[500].main then Npclib[500].main(play, p1, p2) else release_print("handlerequest", "NPC模块不存在", "npcid：500") end
        else
            local mod = Npclib[p1]
            if mod and mod.main then
                mod.main(play, p2)
            else
                release_print("handlerequest", "NPC模块不存在", "npcid："..p1)
            end
        end
	end
end



function msfcbox(play, code)
    local mod = dofile('Envir/Lua/LuaLib/useitme.lua')
    if _G.msfcbox then
        return _G.msfcbox(play, code)
    end
    Player.sendmsgEx(play, "材料自选箱回调异常#57")
    return false
end
local function _qf_npc_725()
    if Npclib and Npclib[725] then
        return Npclib[725]
    end
    local ok, mod = pcall(dofile, 'Envir/Lua/Npc/725.lua')
    if ok and type(mod) == "table" then
        return mod
    end
    return nil
end

function npc_725_spawn_assassin(play)
    local mod = _qf_npc_725()
    if mod and mod.spawnAssassin then
        return mod.spawnAssassin(play)
    end
end

function carpathend(play)
    local mod = _qf_npc_725()
    if mod and mod.carpathend then
        return mod.carpathend(play)
    end
end

function losercar(play,car)
    local mod = _qf_npc_725()
    if mod and mod.losercar then
        return mod.losercar(play)
    end
end

function cardie(play,car)
    local mod = _qf_npc_725()
    if mod and mod.cardie then
        return mod.cardie(play)
    end
end

function carDie(play, car)
    return cardie(play)
end




