--------------------领取任务触发-------------------
local function _zxrw_get_equip_level(play, pos)
    local lv = Player.getEquipFieldByPos(play, pos, 1) or 0
    return tonumber(lv) or 0
end
local function _zxrw_get_trial_data(play)
    local t = Player.getJsonTableByVar(play, VarCfg["T_天书试炼"])
    t = type(t) == "table" and t or {}
    t.submit = type(t.submit) == "table" and t.submit or {}
    t.finish = tonumber(t.finish) or 0
    t.claimed = tonumber(t.claimed) or 0
    return t
end
local function _zxrw_get_xiantian_data(play)
    local t = Player.getJsonTableByVar(play, VarCfg["T_天书先天"])
    t = type(t) == "table" and t or {}
    t.saved = type(t.saved) == "table" and t.saved or {}
    return t
end
local function _zxrw_get_task_npc_xy(rwid)
    local cfg = constant.rw_syb[rwid] or {}
    local xx = tonumber(cfg[4]) or 0
    local yy = tonumber(cfg[5]) or 0
    local npcIndex = tonumber(cfg[3]) or 0
    if npcIndex > 0 then
        local npcObj = getnpcbyindex(npcIndex)
        if npcObj then
            local nx = tonumber(getbaseinfo(npcObj, 4)) or 0
            local ny = tonumber(getbaseinfo(npcObj, 5)) or 0
            if nx > 0 and ny > 0 then
                xx = nx
                yy = ny
            end
        end
    end
    return xx, yy
end
-- handle pre-completed mainline tasks
local function _zxrw_is_precompleted(play, rwid)
    if rwid == 4 then
        local t = Player.getJsonTableByVar(play, VarCfg["T_免费赞助"])
        return t and (tonumber(t["zzlb_1"] or 0) or 0) >= 1
    elseif rwid == 7 then
        return (tonumber(getplaydef(play, VarCfg["U_兰姐好感度"]) or 0) or 0) >= 1
    elseif rwid == 10 then
        local T_qrbq = Player.getJsonTableByVar(play, VarCfg.T_qrbq) or {}
        return (tonumber(T_qrbq["7rqd"] or 0) or 0) >= 1
    elseif rwid == 3 or rwid == 6 or rwid == 9 or rwid == 12 then
        local trial = _zxrw_get_trial_data(play)
        local submitMap = {[3] = "1", [6] = "2", [9] = "3", [12] = "4"}
        return tonumber(trial.submit[submitMap[rwid]] or 0) >= 1
    elseif rwid == 13 then
        local trial = _zxrw_get_trial_data(play)
        return tonumber(trial.finish or 0) >= 1
    elseif rwid == 14 then
        local trial = _zxrw_get_trial_data(play)
        return tonumber(trial.claimed or 0) >= 1
    elseif rwid == 15 then
        return (tonumber(getplaydef(play, VarCfg["U_转生等级"]) or 0) or 0) >= 10
    end
    return false
end
local function _zxrw_block_click_during_xyl_guide(play)
    return false
end
local function _zxrw_refresh_xyl_auto_entry(play, rwid)
    -- 二大陆下雨了流程已迁移到主线，主线不再自动同步 xyl 当前任务。
    return
end
local function _zxrw_get_main_task_cfg(rwid)
    local cfg = constant.rw_syb[tonumber(rwid) or 0]
    return type(cfg) == "table" and type(cfg.task) == "table" and cfg.task or nil
end
local function _zxrw_get_json(play, varName)
    local data = Player.getJsonTableByVar(play, varName)
    return type(data) == "table" and data or {}
end
local function _zxrw_mark_treasure_basin_started(play)
    local mod = rawget(_G, "__treasure_basin_module")
    if not mod then
        mod = dofile("Envir/Lua/LuaLib/treasure_basin.lua")
    end
    if mod and type(mod.markTaskStarted) == "function" then
        mod.markTaskStarted(play)
    end
end
local function _zxrw_has_tianshu_level(play)
    local data = _zxrw_get_json(play, VarCfg["T_天书"])
    return (tonumber(data.level or 0) or 0) >= 1
end
local function _zxrw_has_any_xianfa(play)
    local data = _zxrw_get_json(play, VarCfg["T_天书"])
    local caowei = data.caowei or {}
    for _, v in pairs(caowei) do
        if type(v) == "table" then
            return true
        end
    end
    local tj = data.tj or {}
    for _ in pairs(tj) do
        return true
    end
    return false
end
local function _zxrw_story_done(play, key)
    key = tostring(key or "")
    if key == "" then
        return false
    end
    local cfg = teshudata and teshudata[key]
    if cfg and cfg.ch and checktitle(play, cfg.ch) then
        return true
    end
    local jqData = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    jqData = type(jqData) == "table" and jqData or {}
    local node = jqData[key]
    local maxNum = tonumber(cfg and cfg.max_num or 0) or 0
    if type(node) == "number" then
        return maxNum > 0 and node >= maxNum or node >= 2
    end
    if type(node) == "table" then
        if maxNum > 0 then
            local cnt = tonumber(node.cnt or node.num or 0) or 0
            if cnt >= maxNum then
                return true
            end
        end
        return (tonumber(node.wc or 0) or 0) >= 1
            or (tonumber(node.finish or 0) or 0) >= 1
            or (tonumber(node.done or 0) or 0) >= 1
            or (tonumber(node.ok or 0) or 0) >= 1
    end
    return false
end
local function _zxrw_has_divination(play)
    return (tonumber(getplaydef(play, VarCfg["U_占卜次数"]) or 0) or 0) > 0
end
local function _zxrw_has_main_linggen(play)
    local data = _zxrw_get_json(play, VarCfg["T_灵根"])
    return (tonumber(data.main or 0) or 0) > 0
end
local function _zxrw_has_treasure_basin_fixed(play)
    local data = _zxrw_get_json(play, VarCfg["T_聚宝盆"])
    if (tonumber(data.rebuilt or 0) or 0) >= 1 then
        return true
    end
    data = _zxrw_get_json(play, "T44")
    return (tonumber(data.rebuilt or 0) or 0) >= 1
end
local function _zxrw_has_equip_strength(play)
    local cfg = teshudata and teshudata["npc_28"]
    if not (cfg and cfg.where) then
        return false
    end
    for _, info in pairs(cfg.where) do
        local part = info and info[1]
        if part and (tonumber(getplaydef(play, VarCfg["U_装备强化_" .. part]) or 0) or 0) > 0 then
            return true
        end
    end
    return false
end
local function _zxrw_has_jianghu_title(play)
    return (tonumber(getplaydef(play, VarCfg["U_江湖称号"]) or 0) or 0) > 0
end
local function _zxrw_has_lingshou_hatched(play)
    local data = _zxrw_get_json(play, VarCfg["T_灵兽"])
    if (tonumber(data.baby_choice or 0) or 0) > 0 then
        return true
    end
    for _, mapName in ipairs({"ls", "ls_sp"}) do
        local map = data[mapName] or {}
        for _, v in pairs(map) do
            if (tonumber(v or 0) or 0) > 0 then
                return true
            end
        end
    end
    return false
end
local function _zxrw_has_xuanyuan_fixed(play)
    local cfg = teshudata and teshudata["npc_601"]
    local title = cfg and cfg.details and cfg.details.ch
    return title and checktitle(play, title) or false
end
local function _zxrw_has_foundation_realm(play)
    return (tonumber(getplaydef(play, "U28") or 0) or 0) >= 10
end
local function _zxrw_has_rebirth(play, level)
    return (tonumber(getplaydef(play, VarCfg["U_转生等级"]) or 0) or 0) >= (tonumber(level or 1) or 1)
end
local function _zxrw_has_items(play, items)
    if type(items) ~= "table" or #items <= 0 then
        return false
    end
    local miss = Player.checkItemNumByTable(play, items)
    return not miss
end
local function _zxrw_main_task_done(play, taskCfg)
    if type(taskCfg) ~= "table" then
        return false
    end
    local kind = tostring(taskCfg.kind or "")
    if kind == "tianshu_level" then
        return _zxrw_has_tianshu_level(play)
    elseif kind == "tianshu_xianfa" then
        return _zxrw_has_any_xianfa(play)
    elseif kind == "story" then
        return _zxrw_story_done(play, taskCfg.tk)
    elseif kind == "divination" then
        return _zxrw_has_divination(play)
    elseif kind == "main_linggen" then
        return _zxrw_has_main_linggen(play)
    elseif kind == "treasure_basin" then
        return _zxrw_has_treasure_basin_fixed(play)
    elseif kind == "equip_strength" then
        return _zxrw_has_equip_strength(play)
    elseif kind == "jianghu_title" then
        return _zxrw_has_jianghu_title(play)
    elseif kind == "lingshou_hatched" then
        return _zxrw_has_lingshou_hatched(play)
    elseif kind == "xuanyuan_fixed" then
        return _zxrw_has_xuanyuan_fixed(play)
    elseif kind == "foundation_realm" then
        return _zxrw_has_foundation_realm(play)
    elseif kind == "rebirth" then
        return _zxrw_has_rebirth(play, taskCfg.level)
    elseif kind == "items" then
        return _zxrw_has_items(play, taskCfg.items)
    end
    return false
end
local _zxrw_close_window_by_kind = {
    tianshu_level = 24,
    tianshu_xianfa = 24,
    divination = 26,
    main_linggen = 22,
    treasure_basin = 106,
    equip_strength = 28,
    jianghu_title = 43,
    lingshou_hatched = 64,
    xuanyuan_fixed = 601,
    foundation_realm = 21,
    rebirth = 32,
}
local function _zxrw_close_mainline_window(play, taskCfg)
    if type(taskCfg) ~= "table" then
        return
    end
    local closeName = taskCfg.close
    if not closeName then
        local yd = taskCfg.yd
        if type(yd) == "table" and yd[1] == 1 and yd[3] then
            closeName = "npc_" .. tostring(yd[3])
        else
            local npcid = _zxrw_close_window_by_kind[tostring(taskCfg.kind or "")]
            if npcid then
                closeName = "npc_" .. tostring(npcid)
            end
        end
    end
    if closeName and closeName ~= "" then
        sendluamsg(play, 101, 9999, 0, 0, tostring(closeName))
    end
end

function zxrw_try_finish_current_mainline(play, desc)
    local rwid = tonumber(getplaydef(play, VarCfg.U_zxrw[1]) or 0) or 0
    if rwid <= 0 then
        return false
    end
    local cfg = constant.rw_syb[rwid]
    local taskCfg = cfg and cfg.task or nil
    if _zxrw_main_task_done(play, taskCfg) then
        Player.zxrw_wancheng(play, rwid, desc or "任务")
        _zxrw_close_mainline_window(play, taskCfg)
        return true
    end
    return false
end
local function _zxrw_apply_special_reward(play, name, count)
    if name == "基础灵根解锁" then
        return true
    end
    return false
end
local function _zxrw_story_task_key(xylCfg)
    return type(xylCfg) == "table" and tostring(xylCfg.tk or "") or ""
end
local function _zxrw_get_story_cfg(xylCfg)
    local key = _zxrw_story_task_key(xylCfg)
    return key ~= "" and teshudata and teshudata[key] or nil
end
local function _zxrw_has_cost(play, cost)
    if type(cost) ~= "table" or #cost <= 0 then
        return false
    end
    local miss = Player.checkItemNumByTable(play, cost)
    return not miss
end
local function _zxrw_story_need_fight(play, xylCfg)
    local cfg = _zxrw_get_story_cfg(xylCfg)
    if not cfg then
        return xylCfg and xylCfg.auto
    end
    if type(cfg.cost) == "table" and #cfg.cost > 0 then
        return not _zxrw_has_cost(play, cfg.cost)
    end
    if cfg.shaguai_id then
        local sgData = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
        return (tonumber(sgData[_zxrw_story_task_key(xylCfg)] or 0) or 0) < (tonumber(cfg.num or 0) or 0)
    end
    return false
end
local function _zxrw_ensure_story_started(play, xylCfg)
    if not (xylCfg and xylCfg.need_receive and xylCfg.tk) then
        return
    end
    local cfg = _zxrw_get_story_cfg(xylCfg)
    if not (cfg and cfg.shaguai_id) then
        return
    end
    local jqData = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local key = tostring(xylCfg.tk)
    if (tonumber(jqData[key] or 0) or 0) <= 0 then
        jqData[key] = 1
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jqData)
        shaguai.jia(play, cfg.shaguai_id)
        Player.sendmsgEx(play, "已接取#57|【" .. tostring(cfg.name or xylCfg.name or "任务") .. "】#218|，开始自动战斗")
    end
end
local function _zxrw_send_npc_guide(play, xylCfg)
    local yd = xylCfg and xylCfg.yd
    if type(yd) ~= "table" or yd[1] ~= 1 then
        return false
    end
    sendluamsg(play, 101, 0, 1, 1, '{"lx":2,"npcdt":"' .. tostring(yd[2]) .. '","npcid":' .. tostring(yd[3] or 0) .. ',"xx":' .. tostring(yd[4] or 0) .. ',"yy":' .. tostring(yd[5] or 0) .. '}')
    return true
end
local function _zxrw_guide_main_task(play, rwid, xylCfg)
    local yd = xylCfg and xylCfg.yd
    if type(yd) ~= "table" then
        return false
    end
    if yd[1] == 1 then
        local targetMap, targetX, targetY = yd[2], tonumber(yd[4]) or 0, tonumber(yd[5]) or 0
        mapmove(play, targetMap, targetX, targetY, xylCfg.auto and 5 or 3)
        if xylCfg.kind == "treasure_basin" then
            _zxrw_mark_treasure_basin_started(play)
            startautoattack(play)
            return true
        end
        if xylCfg.auto and _zxrw_story_need_fight(play, xylCfg) then
            _zxrw_ensure_story_started(play, xylCfg)
            startautoattack(play)
            return true
        end
        if not xylCfg.auto then
            _zxrw_send_npc_guide(play, xylCfg)
        end
        return true
    elseif yd[1] == 3 then
        sendluamsg(play, 101, 0, 1, 1, '{"lx":3,"rwid":' .. tostring(rwid) .. '}')
        return true
    elseif yd[1] == 4 then
        local btn = tonumber(yd[3]) or tonumber(yd[2]) or 0
        sendluamsg(play, 101, 0, 1, 1, '{"lx":1,"fx":1,"an":' .. tostring(btn) .. ',"rwid":' .. tostring(rwid) .. ',"ms":"点击顶部按钮"}')
        return true
    end
    return false
end
local function _zxrw_auto_mainline_map_task(play)
    local rwid = tonumber(getplaydef(play, VarCfg.U_zxrw[1]) or 0) or 0
    local taskCfg = _zxrw_get_main_task_cfg(rwid)
    local xylCfg = taskCfg
    local yd = xylCfg and xylCfg.yd
    if not (xylCfg and xylCfg.auto and type(yd) == "table" and yd[1] == 1) then
        return
    end
    if _zxrw_main_task_done(play, taskCfg) then
        return
    end
    if tostring(getbaseinfo(play, 3)) ~= tostring(yd[2]) then
        return
    end
    if xylCfg.kind == "treasure_basin" then
        _zxrw_mark_treasure_basin_started(play)
        startautoattack(play)
        return
    end
    if _zxrw_story_need_fight(play, xylCfg) then
        _zxrw_ensure_story_started(play, xylCfg)
        startautoattack(play)
    else
        _zxrw_send_npc_guide(play, xylCfg)
    end
end
GameEvent.add(EventCfg.goSwitchMap, _zxrw_auto_mainline_map_task, "二大陆主线地图自动战斗")
local _zxrw_story_kill_task_map = {
    npc_603 = 19,
    npc_608 = 25,
    npc_605 = 27,
    npc_606 = 31,
}
local function _zxrw_sync_story_kill_task_progress(play, rwid)
    local cfg = constant.rw_syb[tonumber(rwid) or 0]
    local taskCfg = cfg and cfg.task or nil
    if not (taskCfg and taskCfg.kind == "story" and taskCfg.tk and _zxrw_story_kill_task_map[taskCfg.tk] == tonumber(rwid)) then
        return
    end
    local storyCfg = teshudata and teshudata[taskCfg.tk]
    local need = tonumber(storyCfg and storyCfg.num or 0) or 0
    if need <= 0 then
        return
    end
    local sgData = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
    local cur = tonumber(sgData[taskCfg.tk] or 0) or 0
    if cur > need then
        cur = need
    end
    newchangetask(play, rwid, cur)
end
local function _zxrw_register_sjwp_progress(play, rwid)
    local cfg = constant.rw_syb[tonumber(rwid) or 0]
    if not (cfg and cfg.sjwp) then
        return
    end
    if cfg.task and cfg.task.kind == "treasure_basin" then
        _zxrw_mark_treasure_basin_started(play)
    end
    local sl = {}
    local keys = {}
    for name in pairs(cfg.sjwp) do
        table.insert(keys, name)
    end
    table.sort(keys)
    local chuli = json2tbl(getplaydef(play, VarCfg.T_rwwp))
    for _, name in ipairs(keys) do
        local need = tonumber(cfg.sjwp[name]) or 0
        local have = tonumber(getbagitemcount(play, name) or 0) or 0
        if have < need then
            chuli[name] = {rwid, need}
        elseif chuli[name] and tonumber(chuli[name][1] or 0) == tonumber(rwid) then
            chuli[name] = nil
        end
        table.insert(sl, have >= need and need or have)
    end
    setplaydef(play, VarCfg.T_rwwp, tbl2json(chuli))
    if #sl > 0 then
        newchangetask(play, rwid, unpack(sl))
    end
end
function task_login(play)
    ---------------------------------------------------任务初始化
    local rwid = getplaydef(play,VarCfg.U_zxrw[1])
    local sl = getplaydef(play,VarCfg.U_zxrw[2])
    local chuli = json2tbl(getplaydef(play, VarCfg.T_zxrw))
    local chuliwp = json2tbl(getplaydef(play, VarCfg.T_rwwp))
    if chuli ~= "{}" then
        for v,k in pairs(chuli) do
            newpicktask(play,tonumber(v),k and 0 or tonumber(k))
            _zxrw_register_sjwp_progress(play, tonumber(v))
            Player.zxrw_teshushuaxin(play, tonumber(v), nil)
        end
    end
    if constant.rw_syb[rwid] then
        newpicktask(play,rwid,sl)
        _zxrw_register_sjwp_progress(play, rwid)
        _zxrw_sync_story_kill_task_progress(play, rwid)
        if linkbodyitem(play,2) ~= "0" and rwid == 49 then
            newchangetask(play,rwid,sl)
        end
        if constant.rw_syb[rwid].jd then
            local db = json2tbl(getplaydef(play,VarCfg.T_dljq))
            if db[constant.rw_syb[rwid].jd[1]] and constant.rw_syb[rwid].jd[2] == 1 then
                newchangetask(play, rwid,db[constant.rw_syb[rwid].jd[1]][2])
                --release_print("任务初始化"..rwid..db[constant.rw_syb[rwid].jd[1]][2])
            elseif db[constant.rw_syb[rwid].jd[1]] and db[constant.rw_syb[rwid].jd[1]] == 1 and constant.rw_syb[rwid].jd[2] == 0 then
                if constant.rw_syb[rwid].sjwp then
                    local wp_sl = {}
                    -- 获取表的键并排序
                    local keys = {}
                    for k in pairs(constant.rw_syb[rwid].sjwp) do
                        table.insert(keys, k)
                    end
                    table.sort(keys)
                    for i, y in ipairs(keys) do
                        if chuliwp[y] then
                            table.insert(wp_sl,getbagitemcount(play,y) >= constant.rw_syb[rwid].sjwp[y] and constant.rw_syb[rwid].sjwp[y] or getbagitemcount(play,y))
                        else
                            table.insert(wp_sl,constant.rw_syb[rwid].sjwp[y])
                        end
                    end
                    -- 调用newpicktask函数，并将sj表中的元素作为参数传入
                    newchangetask(play, rwid,unpack(wp_sl))
                end
            end
        end
        if constant.rw_syb[rwid] and constant.rw_syb[rwid].sg then
            if sl > 0 then
                shaguai.jia(play,24)
                setplaydef(play,VarCfg.N_znpc,1)
            end
        end
        if _zxrw_is_precompleted(play, rwid) then
            newdeletetask(play,rwid)
            return
        end
        local mainTaskCfg = _zxrw_get_main_task_cfg(rwid)
        if mainTaskCfg and _zxrw_main_task_done(play, mainTaskCfg) then
            newdeletetask(play,rwid)
            return
        end
        Player.zxrw_teshushuaxin(play, rwid, nil)
        _zxrw_refresh_xyl_auto_entry(play, rwid)
        _zxrw_auto_mainline_map_task(play)
    elseif rwid == 51 then
        --newpicktask(play,51,getplaydef(play,VarCfg.U_zxrw[2]))
    end
end
GameEvent.add(EventCfg.onLogin, task_login, "task")
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
        elseif lx == 7 or lx == 8 then
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
    if rwid < 500 and getplaydef(actor,VarCfg.U_zxrw[1]) ~= rwid then
        return
    end
    clicknewtask(actor,rwid)
end
--------------------点击任务触发-------------------
function clicknewtask(play,rwid)
    if _zxrw_block_click_during_xyl_guide(play) then
        return
    end
    if rwid < 500 and getplaydef(play,VarCfg.U_zxrw[1]) ~= rwid then
        return
    end
     ---------------------------------------------------任务逻辑处理
    if constant.rw_syb[rwid] then
        if _zxrw_is_precompleted(play, rwid) then
            newdeletetask(play,rwid)
            playeffect(play,4011,25,-50,1,0,0)
            return
        end
        local mainTaskCfg = _zxrw_get_main_task_cfg(rwid)
        if mainTaskCfg then
            if _zxrw_main_task_done(play, mainTaskCfg) then
                newdeletetask(play,rwid)
                playeffect(play,4011,25,-50,1,0,0)
            else
                _zxrw_guide_main_task(play, rwid, mainTaskCfg)
            end
            return
        end
        if not constant.rw_syb[rwid].sg then
            if constant.rw_syb[rwid].ktg and constant.rw_syb[rwid].ktg == 1 then
                if getplaydef(play,VarCfg.N_rwlg) >= 1 then
                    newdeletetask(play,getplaydef(play,VarCfg.U_zxrw[1]))
                    playeffect(play,4011,25,-50,1,0,0)
                    setplaydef(play,VarCfg.N_rwlg,0)
                    return
                else
                    setplaydef(play,VarCfg.N_rwlg,getplaydef(play,VarCfg.N_rwlg)+1)
                end
            end
        end
        if constant.rw_syb[rwid].yz then
            local db = json2tbl(getplaydef(play,VarCfg.T_dljq))
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
        elseif lx == 1 then--点击按钮
            sendluamsg(play, 101, 0, 1, 1,'{"lx":1,"fx":1,"an":'..constant.rw_syb[rwid][2]..',"ms":"点击按钮"}')
        elseif lx == 2 then--引导任务  npc类
            local xx, yy = _zxrw_get_task_npc_xy(rwid)
            if xx <= 0 then
                xx = tonumber(getbaseinfo(play, 4)) or 0
            end
            if yy <= 0 then
                yy = tonumber(getbaseinfo(play, 5)) or 0
            end
            if constant.rw_syb[rwid][2] ~= getbaseinfo(play,3) or true then
                mapmove(play,constant.rw_syb[rwid][2],xx,yy,3)
            end
            sendluamsg(play, 101, 0, 1, 1,'{"lx":2,"npcdt":"'..constant.rw_syb[rwid][2]..'","npcid":'..constant.rw_syb[rwid][3]..',"xx":'..xx..',"yy":'..yy..'}')
        elseif lx == 3 then--刷新任务
            sendluamsg(play, 101, 0, 1, 1,'{"lx":3,"rwid":'.. rwid ..'}')
        elseif lx == 4 then--直接完成类的任务
            newdeletetask(play,getplaydef(play,VarCfg.U_zxrw[1]))
            playeffect(play,4011,25,-50,1,0,0)
        elseif lx == 5 then--二层任务逻辑
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
        elseif lx == 6 then--按钮类的任务触发  没有点击引导的
            Npclib['anniu'][constant.rw_syb[rwid][2]](play, 0)
        elseif lx == 9 then--跳转任务类地图
            mapmove(play,constant.rw_syb[rwid][2],constant.rw_syb[rwid][3],constant.rw_syb[rwid][4],3)
        elseif lx == 11 then--三层任务逻辑
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
        elseif lx == 14 then
            sendluamsg(play, 101, 0, 1, 1,'{"lx":14}')
        elseif lx == 15 then--拾取物品类任务
            local dqdt = getbaseinfo(play,3)
            local clwc = true
            local chuli = json2tbl(getplaydef(play, VarCfg.T_rwwp)) --任务物品
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
        elseif lx == 17 then--等级或者转生类任务
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
        elseif lx == 18 then--引导到伏妖录
            sendluamsg(play, 101, 0, 18, 1,'{"l":'..constant.rw_syb[rwid][2][1]..',"xl":'..constant.rw_syb[rwid][2][2] ..',"jm":'..constant.rw_syb[rwid][2][3] ..'}')
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
        end
    end
end
--------------------删除任务触发-------------------
function deletetask(play,rwid)
    setplaydef(play,VarCfg.N_rwlg,0)
    if constant.rw_syb[rwid+1] and constant.rw_syb[rwid+1].istg then
        rwid = rwid + 1
    end
    if rwid < 40 then
        setplaydef(play,VarCfg.U_zxrw[1],rwid+1)
        setplaydef(play,VarCfg.U_zxrw[2],0)
    end
    -- if rwid == 19 then
    --     setplaydef(play, VarCfg["U_境界修炼"][2], 900)
    -- end
    if constant.rw_syb[rwid+1] and rwid < 1000 then
        local lx = constant.rw_syb[rwid+1][1]
        if rwid < 1000 then
            newpicktask(play,rwid+1,getplaydef(play,VarCfg.U_zxrw[2]))
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
        _zxrw_register_sjwp_progress(play, rwid + 1)
        _zxrw_sync_story_kill_task_progress(play, rwid + 1)
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
        elseif lx == 7 or lx == 8 then
            delnpceffect(play,constant.rw_syb[rwid][2][2])
        end
    end
    if constant.rw_syb[rwid].sjwp then
        local chuli = json2tbl(getplaydef(play, VarCfg.T_rwwp)) --任务物品
        for i, v in pairs(constant.rw_syb[rwid].sjwp) do
            if chuli[i] and chuli[i][1] == rwid then
                chuli[i] = nil
            end
        end
        setplaydef(play, VarCfg.T_rwwp, tbl2json(chuli))
    end
    local sj = json2tbl(getplaydef(play, VarCfg.T_rwjl))
    if not sj[""..rwid] then
        if getplaydef(play,VarCfg.U_zxrw[1]) < 51 then
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
                        if not _zxrw_apply_special_reward(play, v[1], v[2]) then
                            if str ~= "" then
                                str = str..",[\""..v[1].."\","..v[2].."]"
                            else
                                str = str.."[\""..v[1].."\","..v[2].."]"
                            end
                            giveitem(play,v[1],v[2],850)
                        end
                    end
                end
                if str ~= "" then
                    -- sendluamsg(play,101,0,9,rwid,'{"item":['..str..']}')
                end
            end
        end
        sj[""..rwid] = true
        setplaydef(play, VarCfg.T_rwjl, tbl2json(sj))
    end
    if rwid < 40 then
        sendluamsg(play,103,1,0,0,'{"rwid":'..(rwid+1)..'}')
        _zxrw_refresh_xyl_auto_entry(play, rwid + 1)
    end
    if rwid > 2000 then
        rwcf.jian(play,rwid)
    end
    if rwid >= 3000 then
        local ywl = json2tbl(getplaydef(play, VarCfg.T_ywl))
        ywl["rw_"..rwid] = 1
        setplaydef(play, VarCfg.T_ywl, tbl2json(ywl))
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
rwcf = {
    [32] = {15},
    [516] = {4},
    [502] = {16},
    [46] = {35},
}
rwcf.jia = function(play, id)
    local chuli = json2tbl(getplaydef(play, VarCfg.T_zxrw))
    chuli[""..id] = true
    setplaydef(play, VarCfg.T_zxrw, tbl2json(chuli))
end
rwcf.jian = function(play, id)
    local chuli = json2tbl(getplaydef(play, VarCfg.T_zxrw))
    chuli[""..id] = nil
    setplaydef(play, VarCfg.T_zxrw, tbl2json(chuli))
end
rwcf.wpjia = function(play, id,rwid,sl)
    local chuli = json2tbl(getplaydef(play, VarCfg.T_rwwp))
    chuli[""..id] = {rwid,sl}
    setplaydef(play, VarCfg.T_rwwp, tbl2json(chuli))
end
rwcf.wpjian = function(play, id)
    local chuli = json2tbl(getplaydef(play, VarCfg.T_rwwp))
    chuli[""..id] = nil
    setplaydef(play, VarCfg.T_rwwp, tbl2json(chuli))
end
return rwcf
