npc = {}
local function _ff9999_parse_reward(text) -- 9999????????????????§Ö????/???/???
    local ret = {items = {}, title = "", realm_exp = 0}
    text = tostring(text or ""):gsub("???????????????%+(%d+)", "???????+%1????????+%1"):gsub("??", "??"):gsub(",", "??")
    for part in string.gmatch(text, "[^??]+") do
        part = tostring(part):gsub("^%s+", ""):gsub("%s+$", "")
        if part ~= "" then
            local itemName, itemNum = string.match(part, "^(.-)%*(%d+)$")
            if itemName and itemNum then
                ret.items[#ret.items + 1] = {itemName, tonumber(itemNum) or 0}
            elseif string.find(part, "^????") then
                ret.title = string.gsub(part, "^????", "")
            else
                local n = string.match(part, "^???%+(%d+)$")
                if n then ret.realm_exp = tonumber(n) or 0 end
            end
        end
    end
    return ret
end
local function _ff9999_random_finish(play) -- 9999??????????????¦Ä?????
    local cfg = include("lua/Data/fairy_fate_cfg.lua") or {}
    local state = Player.getJsonTableByVar(play, VarCfg["T_??????"])
    state.done = type(state.done) == "table" and state.done or {}
    local pending = {}
    for _, detail in ipairs(cfg.details or {}) do
        if tonumber(state.done[tostring(detail.id)] or 0) < 1 then
            pending[#pending + 1] = detail
        end
    end
    if #pending <= 0 then
        Player.sendmsgEx(play, "????¦Ä?????#57")
        return
    end
    local detail = pending[math.random(1, #pending)]
    local reward = _ff9999_parse_reward(detail.reward)
    state.done[tostring(detail.id)] = 1
    Player.setJsonVarByTable(play, VarCfg["T_??????"], state)
    if #reward.items > 0 then Player.rwjl(play, reward.items, "9999??????", 1, 0) end
    if reward.title ~= "" then Player.title_give(play, reward.title) end
    if reward.realm_exp > 0 then
        setplaydef(play, VarCfg["U_????????"][2], (tonumber(getplaydef(play, VarCfg["U_????????"][2])) or 0) + reward.realm_exp)
    end
    if FairyFate and FairyFate.touch then FairyFate.touch(play, "title") end
    sendluamsg(play, 101, 515, 2, tonumber(detail.id) or 0, tbl2json({tp = "cjdc", id = detail.id, name = detail.name, tip = "?????[" .. tostring(detail.name or detail.id) .. "]"}))
    -- Player.sendmsgEx(play, "????????|??" .. tostring(detail.name or detail.id) .. "??#218|???")
end
local function _ff9999_copy_rewards(list)
    local out = {}
    if type(list) ~= "table" then
        return out
    end
    for _, v in ipairs(list) do
        if type(v) == "table" and type(v[1]) == "string" then
            local cnt = tonumber(v[2]) or 0
            if cnt > 0 then
                out[#out + 1] = { v[1], cnt }
            end
        end
    end
    return out
end

local function _ff9999_activate_linggen(play, idx)
    return true
end
local function _ff9999_apply_special_reward(play, name)
    if name == "???????????" then
        return _ff9999_activate_linggen(play, 0)
    elseif name == "????????" then
        return _ff9999_activate_linggen(play, 1)
    elseif name == "????????" then
        return _ff9999_activate_linggen(play, 2)
    elseif name == "????????" then
        return _ff9999_activate_linggen(play, 3)
    elseif name == "????????" then
        return _ff9999_activate_linggen(play, 4)
    elseif name == "?????????" then
        return _ff9999_activate_linggen(play, 5)
    end
    return false
end

local function _ff9999_award_rewards(play, rewardList, reason)
    local items = _ff9999_copy_rewards(rewardList)
    local normal = {}
    for _, v in ipairs(items) do
        if not _ff9999_apply_special_reward(play, v[1]) then
            normal[#normal + 1] = v
        end
    end
    if #normal > 0 then
        Player.rwjl(play, normal, reason or "9999XYL", 1, 0)
    end
end

local function _ff9999_mark_story_node_done(jq_data, key)
    key = tostring(key or "")
    if key == "" then
        return
    end
    if key == "npc_46" then
        local node = type(jq_data[key]) == "table" and jq_data[key] or {}
        node.wc = 1
        jq_data[key] = node
    else
        jq_data[key] = 2
    end
end

local function _ff9999_finish_second_continent_xyl(play)
    -- ?????????? XYL???????????????/????????
    local xyl_cfg = include("lua/Data/npc_xyl.lua") or {}
    local chapters = xyl_cfg[2] or {}
    if #chapters <= 0 then
        Player.sendmsgEx(play, "????????????????#57")
        return
    end
    local ywl = Player.getJsonTableByVar(play, VarCfg.T_ywl)
    ywl = type(ywl) == "table" and ywl or {}
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    jq_data = type(jq_data) == "table" and jq_data or {}

    for j, chapter in ipairs(chapters) do
        local chapterKey = "jl_2_" .. j
        local chapterDone = tonumber(ywl[chapterKey] or 0) == 1
        local tasks = type(chapter) == "table" and chapter.jq or {}
        for z, task in ipairs(tasks) do
            local taskKey = chapterKey .. "_" .. z
            local taskDone = tonumber(ywl[taskKey] or 0) == 1
            if not taskDone then
                if type(task) == "table" and task.jl then
                    _ff9999_award_rewards(play, task.jl, "9999?????XYL????")
                end
                ywl[taskKey] = 1
            end
            if type(task) == "table" and task.tk then
                _ff9999_mark_story_node_done(jq_data, task.tk)
            end
        end
        if not chapterDone then
            if type(chapter) == "table" and chapter.jl then
                _ff9999_award_rewards(play, chapter.jl, "9999?????XYL???")
            end
            ywl[chapterKey] = 1
        end
    end

    ywl.dq = ""
    ywl.dq_i = nil
    ywl.dq_j = nil
    ywl.dq_z = nil
    ywl.dq_id = nil
    Player.setJsonVarByTable(play, VarCfg.T_ywl, ywl)
    Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
    setplaydef(play, VarCfg.U_zxrw[1], 37)
    setplaydef(play, VarCfg.U_zxrw[2], 0)
    sendluamsg(play, 103, 1, 0, 0, '{"rwid":37}')
    Player.sendmsgEx(play, "????????????????????????????????????§Ö?37#218")
end

local function _ff9999_mark_xyl_story_received(play, continents)
    local ok, xyl = pcall(dofile, 'Envir/Lua/Data/npc_xyl.lua')
    if not ok or type(xyl) ~= "table" then
        return false
    end
    local ywl = Player.getJsonTableByVar(play, VarCfg.T_ywl) or {}
    ywl = type(ywl) == "table" and ywl or {}
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq) or {}
    jq_data = type(jq_data) == "table" and jq_data or {}
    for _, continent in ipairs(continents or {}) do
        local chapters = xyl[continent]
        if type(chapters) == "table" then
            for chapter_idx, chapter in ipairs(chapters) do
                local tasks = type(chapter) == "table" and chapter.jq or nil
                if type(tasks) == "table" then
                    local chapter_key = "jl_" .. continent .. "_" .. chapter_idx
                    for task_idx, task in ipairs(tasks) do
                        ywl[chapter_key .. "_" .. task_idx] = 1
                        if type(task) == "table" and task.tk then
                            _ff9999_mark_story_node_done(jq_data, task.tk)
                        end
                    end
                    ywl[chapter_key] = 1
                end
            end
        end
    end
    ywl.dq = ""
    ywl.dq_i = nil
    ywl.dq_j = nil
    ywl.dq_z = nil
    ywl.dq_id = nil
    Player.setJsonVarByTable(play, VarCfg.T_ywl, ywl)
    Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
    return true
end

local function _ff9999_clear_xyl_story(play, continent)
    continent = tonumber(continent) or 0
    if continent <= 0 then
        return false
    end
    local ok, xyl = pcall(dofile, 'Envir/Lua/Data/npc_xyl.lua')
    if not ok or type(xyl) ~= "table" or type(xyl[continent]) ~= "table" then
        return false
    end
    local ywl = Player.getJsonTableByVar(play, VarCfg.T_ywl) or {}
    ywl = type(ywl) == "table" and ywl or {}
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq) or {}
    jq_data = type(jq_data) == "table" and jq_data or {}
    for chapter_idx, chapter in ipairs(xyl[continent]) do
        local chapter_key = "jl_" .. continent .. "_" .. chapter_idx
        ywl[chapter_key] = nil
        local tasks = type(chapter) == "table" and chapter.jq or nil
        if type(tasks) == "table" then
            for task_idx, task in ipairs(tasks) do
                ywl[chapter_key .. "_" .. task_idx] = nil
                if type(task) == "table" and task.tk then
                    jq_data[tostring(task.tk)] = nil
                end
            end
        end
    end
    Player.setJsonVarByTable(play, VarCfg.T_ywl, ywl)
    Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
    return true
end
local function _ff9999_set_min_level_and_rebirth(play, level, zs)
    level = tonumber(level) or 0
    zs = tonumber(zs) or 0
    local cur_level = tonumber(getbaseinfo(play, 6)) or 0
    if level > 0 and cur_level < level then
        callscriptex(play, "CHANGELEVEL", "=", level)
    end
    local cur_zs_var = tonumber(getplaydef(play, VarCfg["U_??????"]) or 0) or 0
    if zs > 0 and cur_zs_var < zs then
        setplaydef(play, VarCfg["U_??????"], zs)
    end
    local cur_zs_base = tonumber(getbaseinfo(play, 39)) or 0
    if zs > 0 and cur_zs_base < zs then
        setbaseinfo(play, 39, zs)
    end
end

local function _ff9999_complete_destiny_plate(play)
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq) or {}
    jq_data = type(jq_data) == "table" and jq_data or {}
    local destiny_state = type(jq_data["npc_74"]) == "table" and jq_data["npc_74"] or {}
    local destiny_need = tonumber((((teshudata or {})["npc_74"] or {}).all) or 4) or 4
    for i = 1, destiny_need do
        destiny_state[tostring(i)] = 1
    end
    destiny_state.all = destiny_need
    destiny_state.level_bonus = 1
    jq_data["npc_74"] = destiny_state
    Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
end
local function _ff9999_complete_basic_linggen(play)
    local linggen_data = Player.getJsonTableByVar(play, VarCfg["T_???"]) or {}
    linggen_data = type(linggen_data) == "table" and linggen_data or {}
    linggen_data.level = type(linggen_data.level) == "table" and linggen_data.level or {}
    for i = 1, 5 do
        if (tonumber(linggen_data.level[tostring(i)]) or 0) < 1 then
            linggen_data.level[tostring(i)] = 1
        end
    end
    linggen_data.main = tonumber(linggen_data.main or 4) or 4
    linggen_data.other = tonumber(linggen_data.other or 3) or 3
    Player.setJsonVarByTable(play, VarCfg["T_???"], linggen_data)
end
local function _ff9999_complete_continent_gates(play, continent)
    continent = math.max(2, math.min(6, tonumber(continent) or 2))
    local min_zs = {
        [2] = 0,
        [3] = 0,
        [4] = 30,
        [5] = 40,
        [6] = 50,
    }
    if continent >= 2 then
        local target_task = continent == 2 and 16 or 35
        local cur_task = tonumber(getplaydef(play, VarCfg.U_zxrw[1])) or 0
        if cur_task < target_task then
            setplaydef(play, VarCfg.U_zxrw[1], target_task)
            setplaydef(play, VarCfg.U_zxrw[2], 0)
            sendluamsg(play, 103, 1, 0, 0, tbl2json({rwid = target_task}))
        end
    end
    _ff9999_set_min_level_and_rebirth(play, continent == 4 and 150 or 0, min_zs[continent] or 0)
    _ff9999_clear_xyl_story(play, continent)
    local xyl_continent = continent - 1
    if xyl_continent == 2 then
        _ff9999_finish_second_continent_xyl(play)
    elseif xyl_continent >= 3 then
        local list = {}
        for i = 3, xyl_continent do
            list[#list + 1] = i
        end
        _ff9999_mark_xyl_story_received(play, list)
    end
end
local _admin_test_monsters = {
    -- "?????????",
---???---
-- "??????????",
-- "?????????",
-- "?????????",
-- "???????????",
-- "???????????",
-- "????????????",
-- "??????????",
-- "?????????????",
-- "???????????",
-- "??????????[???????]",
"---?????---",
"???????????",
"?????????",
"??????????",
"???ûš????[????]",
"???????????",
"??????????[????]",
"???",
"??????????",
"????????",
"???????????[???]",
"????",
"???????????",
"?????????[???]",
"??????",
"??????????",
"??????????",
"??????????[????????]",
"??????????",
"????????",
"??????????",
"???????ýq",
"?????????[????????]",
"??????",
-- "---?????--",
-- "????????",
-- "??????????[????]",
-- "?????????",
-- "????????§ß?",
-- "????????????[???]",
-- "???????????",
-- "??þ ?????",
-- "??????????????",
-- "?????????",
-- "?????????",
-- "??????????",
-- "???????????",
-- "?????????",
-- "??????????",
-- "?????????þ ?????????",
-- "??????????",
-- "??????????",
-- "?????????[???]",
-- "---?????---",
-- "?????????",
-- "?????????",
-- "??????????",
-- "??????????[??]",
-- "?????????",
-- "????????",
-- "??¡¥??????",
-- "????????[??]",
-- "---?????boss---",
-- "??????????????",
-- "???????????[????????]",
-- "????????¦Ë??????",
-- "??????????????????????",
-- "???????????????????",
}
local function _admin_spawn_test_monsters(play)
    if type(_admin_test_monsters) ~= "table" or #_admin_test_monsters <= 0 then
        Player.sendmsgEx(play, "????????§Ò????#57")
        return
    end
    local mapName = tostring(getbaseinfo(play, 3) or "")
    local px = tonumber(getbaseinfo(play, 4) or 0) or 0
    local py = tonumber(getbaseinfo(play, 5) or 0) or 0
    if mapName == "" then
        Player.sendmsgEx(play, "????????#57")
        return
    end
    killmonsters(mapName, "*", 0, false)
    local spawned = 0
    for _, monName in ipairs(_admin_test_monsters) do
        if type(monName) == "string" and monName ~= "" then
            local dx = ((spawned % 8) - 3.5) * 3
            local dy = (math.floor(spawned / 8) - 3.5) * 3
            dx = math.floor(dx + 0.5)
            dy = math.floor(dy + 0.5)
            if dx == 0 and dy == 0 then
                dx = 6
            end
            genmonex(mapName, px + dx, py + dy, monName, 1, 1, 0, 254, "", 0)
            spawned = spawned + 1
        end
    end
    Player.sendmsgEx(play, "???????????????????|??" .. tostring(spawned) .. "??#218|??????")
end
local function _admin_simple_activity_start(play, idx, name, minutes)
    idx = tonumber(idx) or 0
    minutes = tonumber(minutes) or 5
    local actName = tostring(name or "?????")
    sendmovemsg("0", 1, 254, 0, 300, 1, "????????" .. actName .. "??????????????,????¦Ì??...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "????????" .. actName .. "??????????????,????¦Ì??...")
    for _, playerObj in ipairs(getplayerlst() or {}) do
    end
    Player.sendmsgEx(play, actName .. "??????#218")
end
local function _admin_simple_activity_finish(play, idx, name)
    idx = tonumber(idx) or 0
    local actName = tostring(name or "?????")
    sendmovemsg("0", 1, 254, 0, 300, 1, "????????" .. actName .. "??????...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "????????" .. actName .. "??????...")
    for _, playerObj in ipairs(getplayerlst() or {}) do
        sendluamsg(playerObj, 101, 12, 4, idx, "")
    end
    Player.sendmsgEx(play, actName .. "???????#218")
end
local function _admin_not_ready(play, name)
    _admin_simple_activity_start(play, 0, tostring(name or "?????"), 5)
end
local function _admin_qmdk_start(play)
    local cfg = QmdkApi and QmdkApi.get_cfg and QmdkApi.get_cfg() or nil
    if not cfg then
        Player.sendmsgEx(play, "???????????#57")
        return
    end
    if getsysvar(VarCfg["G_???????"]) == 1 then
        Player.sendmsgEx(play, "???????????#57")
        return
    end
    if QmdkApi and QmdkApi.reset_online_scores then
        QmdkApi.reset_online_scores()
    end
    local dqfz = tonumber(getsysvar(VarCfg["G_????????"]) or 0) or 0
    local state = {
        open = 1,
        start_minute = dqfz,
        map = cfg.map,
        score_var = cfg.score_var_prefix or "?????",
        from_bot = 1,
        prepare_end_ts = os.time() + (tonumber(cfg.prepare_sec) or 10),
    }
    setsysvar(VarCfg["G_???????"], 1)
    if QmdkApi and QmdkApi.save_state then
        QmdkApi.save_state(state)
    else
        setsysvar(VarCfg["A_?????json"], tbl2json(state))
    end
    if QmdkApi and QmdkApi.tick_runtime then
        state = QmdkApi.tick_runtime(cfg, state) or state
    end
    setenvirontimer(cfg.map, 3, tonumber(cfg.score_tick_sec) or 1, "@hd_tcppk," .. cfg.map)
    sendmovemsg("0", 1, 254, 0, 300, 1, "????????????????????10??????????...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "????????????????????10??????????...")
    for _, playerObj in ipairs(getplayerlst() or {}) do
        if QmdkApi and QmdkApi.refresh_actor then
            QmdkApi.refresh_actor(playerObj)
        end
    end
    Player.sendmsgEx(play, "???????????????#218")
end
local function _admin_qmdk_finish(play)
    local cfg = QmdkApi and QmdkApi.get_cfg and QmdkApi.get_cfg() or nil
    if not cfg then
        Player.sendmsgEx(play, "???????????#57")
        return
    end
    if getsysvar(VarCfg["G_???????"]) ~= 1 then
        Player.sendmsgEx(play, "??????¦Ä????#57")
        return
    end
    local state = QmdkApi and QmdkApi.get_state and QmdkApi.get_state() or {}
    local mapName = (type(state) == "table" and state.map and state.map ~= "") and state.map or cfg.map
    setenvirofftimer(mapName, 3)
    if cfg.ore_mob and cfg.ore_mob ~= "" then
        killmonsters(mapName, cfg.ore_mob, 0, false)
    end
    if QmdkApi and QmdkApi.clear_all_online then
        QmdkApi.clear_all_online(cfg, false)
    end
    for _, playerObj in ipairs(getplayerlst() or {}) do
        sendluamsg(playerObj, 101, 498, 2, 0, "")
        setplaydef(playerObj, "N$qmdk_panel", 0)
    end
    sendmovemsg("0", 1, 254, 0, 300, 1, "??????????????????,???¦Å???????????????...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "??????????????????,???¦Å???????????????...")
    state.open = 0
    state.finished = 1
    state.from_bot = 1
    state.rank = state.rank or {}
    if QmdkApi and QmdkApi.save_state then
        QmdkApi.save_state(state)
    else
        setsysvar(VarCfg["A_?????json"], tbl2json(state))
    end
    setsysvar(VarCfg["G_???????"], 0)
    Player.sendmsgEx(play, "??????????????#218")
end
local function _admin_bwcz_start(play)
    local cfg = BwczApi and BwczApi.get_cfg and BwczApi.get_cfg() or nil
    if not cfg then
        Player.sendmsgEx(play, "?????????????#57")
        return
    end
    if getsysvar(VarCfg["G_?????????"]) == 1 then
        Player.sendmsgEx(play, "???????????????#57")
        return
    end
    local dqfz = tonumber(getsysvar(VarCfg["G_????????"]) or 0) or 0
    BwczApi.start(dqfz, cfg, true)
    Player.sendmsgEx(play, "?????????????????#218")
end

local function _admin_bwcz_finish(play)
    local cfg = BwczApi and BwczApi.get_cfg and BwczApi.get_cfg() or nil
    if not cfg then
        Player.sendmsgEx(play, "?????????????#57")
        return
    end
    if getsysvar(VarCfg["G_?????????"]) ~= 1 then
        Player.sendmsgEx(play, "??????????¦Ä????#57")
        return
    end
    BwczApi.finish(cfg, true)
    Player.sendmsgEx(play, "????????????????#218")
end
local function _admin_qmdt_start(play)
    local cfg = QmdtApi and QmdtApi.get_cfg and QmdtApi.get_cfg() or (teshudata and teshudata["anniu_507"] and teshudata["anniu_507"].qmdt or nil)
    if type(cfg) ~= "table" or type(cfg.questions) ~= "table" or #cfg.questions <= 0 then
        Player.sendmsgEx(play, "????????????#57")
        return
    end
    if getsysvar(VarCfg["G_????????"]) == 1 then
        Player.sendmsgEx(play, "????????????#57")
        return
    end
    local dqfz = tonumber(getsysvar(VarCfg["G_????????"]) or 0) or 0
    if QmdtApi and QmdtApi.start then
        QmdtApi.start(dqfz, cfg)
    end
    Player.sendmsgEx(play, "?????????????¦Ë??????#218")
end
local function _admin_qmdt_finish(play)
    local cfg = QmdtApi and QmdtApi.get_cfg and QmdtApi.get_cfg() or (teshudata and teshudata["anniu_507"] and teshudata["anniu_507"].qmdt or nil)
    if type(cfg) ~= "table" then
        Player.sendmsgEx(play, "????????????#57")
        return
    end
    if getsysvar(VarCfg["G_????????"]) ~= 1 then
        Player.sendmsgEx(play, "???????¦Ä????#57")
        return
    end
    if QmdtApi and QmdtApi.finish then
        QmdtApi.finish(cfg)
    end
    Player.sendmsgEx(play, "??????????????#218")
end
local function _admin_wlmz_start(play)
    setenvirontimer("??????", 2, 10, "@hd_tcppk,??????")
    sendmovemsg("0", 1, 254, 0, 300, 1, "??????????????????????????????,????¦Ì??...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "??????????????????????????????,????¦Ì??...")
    for _, playerObj in ipairs(getplayerlst() or {}) do
    end
    Player.sendmsgEx(play, "??????????????#218")
end
local function _admin_wlmz_finish(play)
    setenvirofftimer("??????", 2)
    sendmovemsg("0", 1, 254, 0, 300, 1, "??????????????????????,???¦Ë?????????????????...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "??????????????????????,???¦Ë?????????????????...")
    Player.sendmsgEx(play, "???????????????#218")
end
local function _admin_tcppk_start(play)
    local tcppkRound = (tonumber(Player.GetGlobalTempInt("TCPPK_ROUND") or 0) or 0) + 1
    Player.SetGlobalTempInt("TCPPK_ROUND", tcppkRound)
    Player.SetGlobalTempInt("TCPPK_EQUIP_ROUND", tcppkRound)
    Player.SetGlobalTempInt("TCPPK_EQUIP_TOTAL", 0)
    for _, playerObj in ipairs(getplayerlst() or {}) do
        sendluamsg(playerObj, 101, 1000, 1, 0, "")
        setplaydef(playerObj, "N$???????x", 0)
        setplaydef(playerObj, "N$???????y", 0)
        sendluamsg(playerObj, 101, 12, 1, 5, '{"sk":3,"kf":2,"idx":5}')
    end
    sendmovemsg("0", 1, 254, 0, 300, 1, "???????????????????????????,????¦Ì??...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "???????????????????????????,????¦Ì??...")
    sendmovemsg("0", 1, 254, 0, 240, 1, "???????????????????????????,????¦Ì??...")
    Player.sendmsgEx(play, "????????????#218")
end
local function _admin_tcppk_finish(play)
    for _, playerObj in ipairs(getplayerlst() or {}) do
        sendluamsg(playerObj, 101, 1000, 2, 0, "")
        sendluamsg(playerObj, 101, 12, 4, 5, "")
        setplaydef(playerObj, "N$???????x", 0)
        setplaydef(playerObj, "N$???????y", 0)
    end
    sendmovemsg("0", 1, 254, 0, 300, 1, "???????????????????...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "???????????????????...")
    Player.sendmsgEx(play, "?????????????#218")
end
local function _admin_txzr_start(play)
    sendmovemsg("0", 1, 253, 0, 300, 1, "???????????????????????,???????????...")
    sendmovemsg("0", 1, 249, 0, 250, 1, "???????????????????????,???????????...")
    for _, playerObj in ipairs(getplayerlst() or {}) do
    end
    Player.sendmsgEx(play, "???????????#218")
end
local function _admin_txzr_finish(play)
    sendmovemsg("0", 1, 253, 0, 300, 1, "???????????????????...")
    sendmovemsg("0", 1, 249, 0, 250, 1, "???????????????????...")
    Player.sendmsgEx(play, "????????????#218")
end
local function _admin_sbk_start(play)
    repaircastle()
    addattacksabakall()
    Player.sendmsgEx(play, "?????????#218")
end
local function _admin_sbk_finish(play)
    Player.sendmsgEx(play, "??????????#218")
end
local function _admin_sjdb_start(play)
    local cfg = teshudata and teshudata["anniu_507"] and teshudata["anniu_507"].sjdb or {}
    local keepSec = tonumber(cfg.keep_sec) or 180
    local keepMin = math.max(1, math.floor((keepSec + 59) / 60))
    local mapName = tostring(cfg.map or "?????")
    local center = type(cfg.center) == "table" and cfg.center or {x = 215, y = 53}
    sendmovemsg("0", 1, 254, 0, 300, 1, "???????????????????????????,????¦Ì??...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "???????????????????????????,????¦Ì??...")
    sendmovemsg("0", 1, 254, 0, 240, 1, "???????????????????????????,????¦Ì??...")
    for _, playerObj in ipairs(getplayerlst() or {}) do
    end
    for _, circle in ipairs(cfg.circles or {}) do
        local range = tonumber(circle and circle.range) or 200
        for _, drop in ipairs((circle and circle.drops) or {}) do
            local itemName = drop and drop.item or ""
            local dropCount = tonumber(drop and drop.count) or 0
            if itemName ~= "" and dropCount > 0 then
                throwitem("0", mapName, tonumber(center.x) or 215, tonumber(center.y) or 53, range, itemName, dropCount, keepSec, false, true, false, false)
            end
        end
    end
    Player.sendmsgEx(play, "???????????#218")
end
local function _admin_sjdb_finish(play)
    sendmovemsg("0", 1, 254, 0, 300, 1, "???????????????????...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "???????????????????...")
    Player.sendmsgEx(play, "????????????#218")
end
local function _admin_mskh_start(play)
    local cfg = MskhApi and MskhApi.get_cfg and MskhApi.get_cfg() or nil
    if not cfg then
        Player.sendmsgEx(play, "???????????#57")
        return
    end
    if getsysvar(VarCfg["G_???????"]) == 1 then
        Player.sendmsgEx(play, "?????????????#57")
        return
    end
    local dqfz = tonumber(getsysvar(VarCfg["G_????????"]) or 0) or 0
    if MskhApi and MskhApi.start and MskhApi.start(dqfz, cfg, true) then
        Player.sendmsgEx(play, "???????????????#218")
    else
        Player.sendmsgEx(play, "????????????#57")
    end
end
local function _admin_mskh_finish(play)
    local cfg = MskhApi and MskhApi.get_cfg and MskhApi.get_cfg() or nil
    if not cfg then
        Player.sendmsgEx(play, "???????????#57")
        return
    end
    if getsysvar(VarCfg["G_???????"]) ~= 1 then
        Player.sendmsgEx(play, "????????¦Ä????#57")
        return
    end
    if MskhApi and MskhApi.finish and MskhApi.finish(cfg, true) then
        Player.sendmsgEx(play, "??????????????#218")
    else
        Player.sendmsgEx(play, "???????????#57")
    end
end
local function _admin_hdjd_start(play)
    local cfg = HdjdApi and HdjdApi.get_cfg and HdjdApi.get_cfg() or nil
    if not cfg then
        Player.sendmsgEx(play, "?????????????#57")
        return
    end
    if getsysvar(VarCfg["G_?????????"]) == 1 then
        Player.sendmsgEx(play, "??????????????#57")
        return
    end
    local dqfz = tonumber(getsysvar(VarCfg["G_????????"]) or 0) or 0
    if HdjdApi and HdjdApi.start and HdjdApi.start(dqfz, cfg, true) then
        Player.sendmsgEx(play, "?????????????????#218")
    else
        Player.sendmsgEx(play, "?????????????#57")
    end
end
local function _admin_hdjd_finish(play)
    local cfg = HdjdApi and HdjdApi.get_cfg and HdjdApi.get_cfg() or nil
    if not cfg then
        Player.sendmsgEx(play, "?????????????#57")
        return
    end
    if getsysvar(VarCfg["G_?????????"]) ~= 1 then
        Player.sendmsgEx(play, "?????????¦Ä????#57")
        return
    end
    if HdjdApi and HdjdApi.finish and HdjdApi.finish(cfg, true) then
        Player.sendmsgEx(play, "????????????????#218")
    else
        Player.sendmsgEx(play, "????????????#57")
    end
end
local function _ff9999_get_continent_unlock_desc(continent)
    continent = tonumber(continent) or 0
    if continent == 2 then
        return "??????????"
    elseif continent == 3 then
        return "??????????"
    elseif continent == 4 then
        return "???????????????????????????"
    elseif continent == 5 then
        return "??????????????????????????"
    elseif continent == 6 then
        return "????????????????"
    end
    return "???xyl??????????????????"
end
local function _ff9999_unlock_continent(play, continent)
    continent = math.max(2, math.min(6, tonumber(continent) or 2))
    _ff9999_complete_continent_gates(play, continent)
    local current = tonumber(getplaydef(play, "U_????????") or 0) or 0
    local unlocked = current == 1 and 1 or math.max(current, continent)
    setplaydef(play, "U_????????", unlocked)
    Player.syncDlUnlockOnce(play, unlocked)
    Player.sendmsgEx(play, tostring(continent) .. "?????????????????" .. _ff9999_get_continent_unlock_desc(continent) .. "?????????????#57|??" .. (unlocked == 1 and "??????" or (tostring(unlocked) .. "???")) .. "??#218|")
end


local function _ff9999_clear_npc_725(play)
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq) or {}
    jq_data = type(jq_data) == "table" and jq_data or {}
    jq_data["npc_725"] = nil
    jq_data["npc_725_a"] = nil
    if Guard and Guard.clearTaskTemp then
        Guard.clearTaskTemp(jq_data, "npc_725")
    end
    Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
    setplaydef(play, "N$npc_725_escort", 0)
    sendluamsg(play, 100, 725, 0, 0, tbl2json({T_dljq = jq_data, sg_data = Player.getJsonTableByVar(play, VarCfg["T_?????????"]) or {}}))
    Player.sendmsgEx(play, "?????725???ÂË???????????????2???#218")
end
function npc.main(play,npcid)
    local zhid = tonumber(getconst(play,"<$USERACCOUNT>"))
    if constant.pz_htqx[zhid] or getconst(play, '<$SERVERNAME>') == "" or getconst(play, '<$SERVERNAME>') == "??????" then
        -- release_print("-----------------------------")
        -- release_print(getbaseinfo(play,3).." "..getbaseinfo(play,4).." "..getbaseinfo(play,5))
        -- return
        say(play,[[<Img|id=ui_1|x=0.0|y=-1.0|width=800|height=600|img=public/bg_npc_01.png|bg=1|esc=1|move=0|reset=1|show=0|scale9l=15|scale9r=15|scale9t=15|scale9b=15|loadDelay=1>
            <Layout|id=ui_2|x=801.0|y=0.0|width=80|height=80|link=@exit>
            <Button|id=ui_3|x=794|y=0.0|width=26|height=42|nimg=public/1900000510.png|pimg=public/1900000511.png|color=255|size=18|link=@exit>
            <EquipShow|id=ui_27|x=0|y=500|index=71|showtips=1|link=@???????>
            <EquipShow|id=ui_28|x=50|y=500|index=72|showtips=1|link=@???????>
            <EquipShow|id=ui_29|x=100|y=500|index=73|showtips=1|link=@???????>
            <EquipShow|id=ui_30|x=150|y=500|index=17|showtips=1|link=@???????>
            <EquipShow|id=ui_300|x=200|y=500|index=87|showtips=1|link=@???????>
            <EquipShow|id=ui_301|x=250|y=500|index=104|showtips=1|link=@???????>
            <Button|id=ui_100|x=150|y=450|width=160|height=40|nimg=public/1900000660.png|color=251|size=16|text=llxf????|link=@ggna,24>
            <Button|id=ui_101|x=350|y=450|width=160|height=40|nimg=public/1900000660.png|color=251|size=16|text=???????|link=@ggna,23>
            <Button|id=ui_102|x=550|y=450|width=160|height=40|nimg=public/1900000660.png|color=251|size=16|text=????????|link=@ggna,25>
            <Button|id=ui_103|x=550|y=400|width=160|height=40|nimg=public/1900000660.png|color=251|size=16|text=????????|link=@ggna,54>
            <Button|id=ui_39|x=18|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=??????|link=@ggna,32>
            <Button|id=ui_40|x=130|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=???????|link=@ggna,33>
            <Button|id=ui_41|x=242|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=????|link=@ggna,26>
            <Button|id=ui_42|x=354|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=??????|link=@ggna,27>
            <Button|id=ui_43|x=466|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=?????|link=@ggna,28>
            <Button|id=ui_44|x=578|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=???????|link=@ggna,29>
            <Button|id=ui_45|x=18|y=150|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=??????|link=@ggna,34>
            <Button|id=ui_46|x=130|y=150|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=???????|link=@ggna,35>
            <Button|id=ui_47|x=242|y=150|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=????|link=@ggna,36>
            <Button|id=ui_48|x=354|y=150|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=??????|link=@ggna,37>
            <Button|id=ui_49|x=466|y=150|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=??????|link=@ggna,38>
            <Button|id=ui_50|x=578|y=150|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=???????|link=@ggna,39>
            <Button|id=ui_51|x=18|y=200|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=??????|link=@ggna,40>
            <Button|id=ui_52|x=130|y=200|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=???????|link=@ggna,41>
            <Button|id=ui_53|x=242|y=200|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=??§Ñ???|link=@ggna,42>
            <Button|id=ui_54|x=354|y=200|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=??§Ñ????|link=@ggna,43>
            <Button|id=ui_55|x=466|y=200|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=???????|link=@ggna,30>
            <Button|id=ui_56|x=578|y=200|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=????????|link=@ggna,31>
            <Button|id=ui_57|x=18|y=250|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=?????|link=@ggna,44>
            <Button|id=ui_58|x=130|y=250|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=??????|link=@ggna,45>
            <Button|id=ui_59|x=242|y=250|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=BOSS???|link=@ggna,46>
            <Button|id=ui_60|x=354|y=250|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=BOSS????|link=@ggna,47>
            <Button|id=ui_61|x=466|y=250|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=?????|link=@ggna,48>
            <Button|id=ui_62|x=578|y=250|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=??????|link=@ggna,49>
            <Button|id=ui_63|x=18|y=300|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=??????|link=@ggna,50>
            <Button|id=ui_64|x=130|y=300|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=???????|link=@ggna,51>
            <Button|id=ui_66|x=242|y=300|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=??????|link=@ggna,52>
            <Button|id=ui_67|x=354|y=300|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=??????|link=@ggna,53>
            <Button|id=ui_68|x=466|y=300|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=????????|link=@ggna,55>
            <Button|id=ui_65|x=578|y=300|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=??????|link=@ggna,14>
            <Button|id=ui_69|x=18|y=350|width=160|height=40|nimg=public/1900000660.png|color=251|size=16|text=?????XYL???|link=@ggna,56>
            <Button|id=ui_70|x=190|y=350|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=2???????|link=@ggna,57>
            <Button|id=ui_71|x=302|y=350|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=3???????|link=@ggna,58>
            <Button|id=ui_72|x=414|y=350|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=4???????|link=@ggna,59>
            <Button|id=ui_73|x=526|y=350|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=5???????|link=@ggna,60>
            <Button|id=ui_74|x=638|y=350|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=6???????|link=@ggna,61>
            <Button|id=ui_75|x=18|y=400|width=160|height=40|nimg=public/1900000660.png|color=251|size=16|text=???725|link=@ggna,62>
                ]])
    end
end
function ggna(play,id)
    if id == "1" then
        local item = linkbodyitem(play,73)
        if item == "0" then
            Player.sendmsgEx(play, "??????#57")
        else
            if checktitle(play,"?????") then
                Player.sendmsgEx(play, "???????????#57|?????????#218|??#57")
            else
                confertitle(play,"?????")
                changecustomitemvalue(play,linkbodyitem(play,73),0,"=",20,1)
                Player.sendmsgEx(play, "???")
            end
        end
    elseif id == "2" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            Player.sendmsgEx(play, "??????#57")
        else
            local sx = json2tbl(getitemcustomabil(play, item))
            if sx.abil[2].v[1][3] >= 30 then
                Player.sendmsgEx(play, "??????#57")
            else
                changecustomitemvalue(play,item,0,"=",30,1)
                changecustomitemvalue(play,item,1,"=",1500,1)
                --changecustomitemvalue(play,item,8,"=",3000,1)
                changecustomitemvalue(play,item,2,"=",30,1)
                changecustomitemvalue(play,item,3,"=",30,1)
                changecustomitemvalue(play,item,4,"=",6000,1)
                changecustomitemvalue(play,item,5,"=",6000,1)
                changecustomitemvalue(play,item,6,"=",600,1)
                changecustomitemvalue(play,item,7,"=",600,1)
                confertitle(play,"??????????")
                Player.sendmsgEx(play, "???")
            end
        end
    elseif id == "3" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            Player.sendmsgEx(play, "??????#57")
        else
            changecustomitemvalue(play,item,0,"=",400,0)
            changecustomitemvalue(play,item,1,"=",400,0)
            changecustomitemvalue(play,item,2,"=",4000,0)
            changecustomitemvalue(play,item,3,"=",20000,0)
            changecustomitemvalue(play,item,9,"=",5000,0)
            confertitle(play,teshudata["npc_54"].del_title)
            changecustomitemvalue(play,item,4,"=",200,0)
            changecustomitemvalue(play,item,5,"=",10,0)
            changecustomitemvalue(play,item,6,"=",20,0)
            changecustomitemvalue(play,item,7,"=",10,0)
            changecustomitemvalue(play,item,8,"=",20,0)
            Player.sendmsgEx(play, "???")
        end
    elseif id == "4" then
        local zs = getbaseinfo(play,39)
        if zs > 5 then
            Player.sendmsgEx(play, "???????#218|????????????????????#57")
        else
            setbaseinfo(play,39,6)
            confertitle(play,"6?????")
            changecustomitemvalue(play,linkbodyitem(play,72),0,"=",15,2)
            Player.sendmsgEx(play, "???")
        end
    elseif id == "5" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            Player.sendmsgEx(play, "??????#57")
        else
            changecustomitemvalue(play,item,0,"=",500,2)
            changecustomitemvalue(play,item,1,"=",5000,2)
            changecustomitemvalue(play,item,2,"=",10,2)
            changecustomitemvalue(play,item,3,"=",10,2)
            changecustomitemvalue(play,item,4,"=",10,2)
            changecustomitemvalue(play,item,5,"=",1000,2)
            changecustomitemvalue(play,item,6,"=",20,2)
            changecustomitemvalue(play,item,7,"=",40,2)
            changecustomitemvalue(play,item,8,"=",20,2)
            changecustomitemvalue(play,item,9,"=",40,2)
            confertitle(play,"???????")
            Player.sendmsgEx(play, "???")
        end
    elseif id == "6" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            Player.sendmsgEx(play, "??????#57")
        else
            changecustomitemvalue(play,item,0,"=",10,3)
            changecustomitemvalue(play,item,1,"=",10,3)
            changecustomitemvalue(play,item,2,"=",10,3)
            changecustomitemvalue(play,item,3,"=",10,3)
            changecustomitemvalue(play,item,4,"=",1000,3)
            changecustomitemvalue(play,item,5,"=",10,3)
            changecustomitemvalue(play,item,6,"=",20,3)
            changecustomitemvalue(play,item,7,"=",10,3)
            changecustomitemvalue(play,item,8,"=",20,3)
            changecustomitemvalue(play,item,9,"=",1,3)
            changecustomitemvalue(play,item,0,"=",15,4)
            changecustomitemvalue(play,item,1,"=",30,4)
            changecustomitemvalue(play,item,2,"=",15,4)
            changecustomitemvalue(play,item,3,"=",30,4)
            confertitle(play,"????????")
            Player.sendmsgEx(play, "???")
        end
    elseif id == "7" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            Player.sendmsgEx(play, "??????#57")
        else
            Player.sendmsgEx(play, "???")
        end
    elseif id == "8" then
        local item = linkbodyitem(play, 72)
        if item == "0" then
            Player.sendmsgEx(play, "??????#57")
        else
            changecustomitemvalue(play,item,0,"+",100,0)
            changecustomitemvalue(play,item,1,"+",100,0)
            changecustomitemvalue(play,item,2,"+",5000,0)
            local data = json2tbl(getplaydef(play,VarCfg.T_ystz))
            data.xt1 = 1
            data.xt2 = 1
            data.xt3 = 1
            data.xt4 = 1
            data.xt5 = 1
            data.xt6 = 1
            data.xt7 = 1
            data.xt8 = 1
            setplaydef(play,VarCfg.T_ystz,tbl2json(data))
            confertitle(play,"?????(??)")
            Player.sendmsgEx(play, "???")
        end
    elseif id == "9" then
        local item = linkbodyitem(play, 72)
        if item == "0" then
            Player.sendmsgEx(play, "??????#57")
        else
            changecustomitemvalue(play,item,0,"+",250,0)
            changecustomitemvalue(play,item,1,"+",250,0)
            changecustomitemvalue(play,item,2,"+",10000,0)
            local data = json2tbl(getplaydef(play,VarCfg.T_ystz))
            data.yy1 = 1
            data.yy2 = 1
            data.yy3 = 1
            data.yy4 = 1
            data.yy5 = 1
            data.yy6 = 1
            data.yy7 = 1
            data.yy8 = 1
            setplaydef(play,VarCfg.T_ystz,tbl2json(data))
            confertitle(play,"?????(??)")
            Player.sendmsgEx(play, "???")
        end
    elseif id == "10" then
        local item = linkbodyitem(play, 72)
        if item == "0" then
            Player.sendmsgEx(play, "??????#57")
        else
            changecustomitemvalue(play,item,0,"+",500,0)
            changecustomitemvalue(play,item,1,"+",500,0)
            changecustomitemvalue(play,item,2,"+",20000,0)
            local data = json2tbl(getplaydef(play,VarCfg.T_ystz))
            data.xc1 = 1
            data.xc2 = 1
            data.xc3 = 1
            data.xc4 = 1
            data.xc5 = 1
            data.xc6 = 1
            data.xc7 = 1
            data.xc8 = 1
            setplaydef(play,VarCfg.T_ystz,tbl2json(data))
            confertitle(play,"?????(??)")
            Player.sendmsgEx(play, "???")
        end
    elseif id == "11" then
        setplaydef(play,VarCfg.T_gjyj,'{"gjyj":[100000,100000,100000,100000,100000,100000,100000,100000,100000,0,0,0]}')  --??????
        Player.sendmsgEx(play, "???")
    elseif id == "12" then
        setplaydef(play,VarCfg.U_qhdj[1],66)
        setplaydef(play,VarCfg.U_qhdj[2],66)
        Player.sendmsgEx(play, "???")
    elseif id == "13" then
        reddot(play, 200, 100, 10, 10, 0, "res/public/ists.png")
        reddot(play, 200, 101, 10, 10, 0, "res/public/ists.png")
        reddot(play, 0, tonumber("Button"), 10, 10, 0, "res/public/ists.png")
        Player.sendmsgEx(play, "???")
        Player.sendmsgEx(play, "??????")
    elseif id == "14" then
        local activity_names = {"?????", "??????", "???????", "??????", "????????", "?????"}
        local base_row = tonumber(getsysvar("N$9999ActivityNoticeRow") or 0) or 0
        for idx, actName in ipairs(activity_names) do
            local row = (base_row + idx - 1) % 30
            local x = 100
            local y = 700 - row * 18
            local payload = getbaseinfo(play, 1) .. "??????[" .. actName .. "]??"
            for _, playerObj in ipairs(getplayerlst() or {}) do
                sendcustommsg(playerObj, 1, payload, 251, 0, x, y)
            end
        end
        setsysvar("N$9999ActivityNoticeRow", (base_row + #activity_names) % 30)
        Player.sendmsgEx(play, "???????????????")
    elseif id == "15" then
        local wpdx = linkbodyitem(play,76)
        local item = linkbodyitem(play,17)
        setitemcustomabil(play, wpdx,getitemcustomabil(play, item))
        Player.sendmsgEx(play, "???")
    elseif id == "16" then
        setplaydef(play,VarCfg.U_zllv,1)
        Player.sendmsgEx(play, "???")
    elseif id == "17" then
        local zl = json2tbl(getplaydef(play,VarCfg.T_zlxj))
        zl["dj"] = 1 + zl["dj"]
        setplaydef(play,VarCfg.T_zlxj,tbl2json(zl))
        Player.sendmsgEx(play, "???")
    elseif id == "18" then
        if getplaydef(play,VarCfg.U_zxrw[1])then
            newdeletetask(play,getplaydef(play,VarCfg.U_zxrw[1]))
            playeffect(play,4011,25,-50,1,0,0)
        end
    elseif id == "19" then
        setplaydef(play,VarCfg.T_mjsj,'{"mjsj":[0,99,199,0,0,0,0,0,0,0,0,0]}')  --??????
    elseif id == "20" then
        setitemintparam(play,71,1,2)
    elseif id == "21" then
        repaircastle()
        addattacksabakall()
        Player.sendmsgEx(play, "??????")
    elseif id == "26" then
        _admin_qmdk_start(play)
    elseif id == "27" then
        _admin_qmdk_finish(play)
    elseif id == "28" then
        _admin_qmdt_start(play)
    elseif id == "29" then
        _admin_qmdt_finish(play)
    elseif id == "30" then
        _admin_wlmz_start(play)
    elseif id == "31" then
        _admin_wlmz_finish(play)
    elseif id == "32" then
        _admin_bwcz_start(play)
    elseif id == "33" then
        _admin_bwcz_finish(play)
    elseif id == "34" then
        _admin_simple_activity_start(play, 4, "??????", 5)
    elseif id == "35" then
        _admin_simple_activity_finish(play, 4, "??????")
    elseif id == "36" then
        _admin_tcppk_start(play)
    elseif id == "37" then
        _admin_tcppk_finish(play)
    elseif id == "38" then
        _admin_mskh_start(play)
    elseif id == "39" then
        _admin_mskh_finish(play)
    elseif id == "40" then
        _admin_txzr_start(play)
    elseif id == "41" then
        _admin_txzr_finish(play)
    elseif id == "42" then
        if jqr_zxdz_start then
            jqr_zxdz_start()
            Player.sendmsgEx(play, "??§Ñ?????????#218")
        else
            Player.sendmsgEx(play, "??§Ñ?????????????#57")
        end
    elseif id == "43" then
        if jqr_zxdz_end then
            jqr_zxdz_end()
            Player.sendmsgEx(play, "??§Ñ??????????#218")
        else
            Player.sendmsgEx(play, "??§Ñ?????????????#57")
        end
    elseif id == "44" then
        _admin_sbk_start(play)
    elseif id == "45" then
        _admin_sbk_finish(play)
    elseif id == "46" then
        _admin_simple_activity_start(play, 12, "???BOSS", 5)
    elseif id == "47" then
        _admin_simple_activity_finish(play, 12, "???BOSS")
    elseif id == "48" then
        _admin_sjdb_start(play)
    elseif id == "49" then
        _admin_sjdb_finish(play)
    elseif id == "50" then
        _admin_hdjd_start(play)
    elseif id == "51" then
        _admin_hdjd_finish(play)
    elseif id == "52" then
        _ff9999_random_finish(play)
    elseif id == "53" then
        _admin_spawn_test_monsters(play)
    elseif id == "54" then
        local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
        local keys = {"npc_621", "npc_622", "npc_623", "npc_624", "npc_625", "npc_626", "npc_627", "npc_628"}
        for _, key in ipairs(keys) do
            jq_data[key] = 2
        end
        local prep_keys = {"npc_625_rw", "npc_626_rw", "npc_627_rw", "npc_628_rw"}
        for _, key in ipairs(prep_keys) do
            jq_data[key] = 2
        end
        jq_data["npc_55"] = 2
        if Guard and Guard.clearTaskTemp then
            Guard.clearTaskTemp(jq_data, "npc_55")
        end
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        Player.sendmsgEx(play, "???????????????#218")
    elseif id == "55" then
        local varName = VarCfg["T_??????"] or "T51"
        local data = Player.getJsonTableByVar(play, varName) or {}
        data.daily = {date = os.date("%Y%m%d"), free = 0, paid = 0}
        data.in_run = 0
        data.run_floor = 0
        data.active_floor = 0
        Player.setJsonVarByTable(play, varName, data)
        local dtm = getbaseinfo(play, 1) .. "_ttt"
        if checkmirrormap(dtm) then
            delmirrormap(dtm)
        end
        Player.sendmsgEx(play, "??????????????????????????????#218")
    elseif id == "56" then
        _ff9999_finish_second_continent_xyl(play)
    elseif id == "57" then
        _ff9999_unlock_continent(play, 2)
    elseif id == "58" then
        _ff9999_unlock_continent(play, 3)
    elseif id == "59" then
        _ff9999_unlock_continent(play, 4)
    elseif id == "60" then
        _ff9999_unlock_continent(play, 5)
    elseif id == "61" then
        _ff9999_unlock_continent(play, 6)
    elseif id == "62" then
        _ff9999_clear_npc_725(play)
    elseif id == "25" then
        setplaydef(play, "U_????????", 1)
        Player.syncDlUnlockOnce(play, 1)
        -- ???????????????¡ä????????????????3-6???????????????????????????????????????????????
        local target_task = 35
        local target_level = 150
        local target_zs = 70
        local cur_task = tonumber(getplaydef(play, VarCfg.U_zxrw[1])) or 0
        if cur_task < target_task then
            setplaydef(play, VarCfg.U_zxrw[1], target_task)
            setplaydef(play, VarCfg.U_zxrw[2], 0)
            sendluamsg(play, 103, 1, 0, 0, '{"rwid":35}')
        end
        local cur_level = tonumber(getbaseinfo(play, 6)) or 0
        if cur_level < target_level then
            callscriptex(play, "CHANGELEVEL", "=", target_level)
        end
        local cur_zs_var = tonumber(getplaydef(play, VarCfg["U_??????"])) or 0
        if cur_zs_var < target_zs then
            setplaydef(play, VarCfg["U_??????"], target_zs)
        end
        local cur_zs_base = tonumber(getbaseinfo(play, 39)) or 0
        if cur_zs_base < target_zs then
            setbaseinfo(play, 39, target_zs)
        end
        _ff9999_mark_xyl_story_received(play, {3,4,5,6})
        local linggen_data = Player.getJsonTableByVar(play, VarCfg["T_???"]) or {}
        linggen_data.level = type(linggen_data.level) == "table" and linggen_data.level or {}
        for i = 1, 10 do
            if (tonumber(linggen_data.level[tostring(i)]) or 0) <= 0 then
                linggen_data.level[tostring(i)] = 1
            end
        end
        linggen_data.main = tonumber(linggen_data.main or 4) or 4
        linggen_data.other = tonumber(linggen_data.other or 3) or 3
        Player.setJsonVarByTable(play, VarCfg["T_???"], linggen_data)
        local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq) or {}
        local destiny_state = type(jq_data["npc_74"]) == "table" and jq_data["npc_74"] or {}
        local destiny_need = tonumber((((teshudata or {})["npc_74"] or {}).all) or 4) or 4
        for i = 1, destiny_need do
            destiny_state[tostring(i)] = 1
        end
        destiny_state.all = destiny_need
        destiny_state.level_bonus = 1
        jq_data["npc_74"] = destiny_state
        local rune_state = Player.getJsonTableByVar(play, VarCfg["T_???????"]) or {}
        rune_state.runes = type(rune_state.runes) == "table" and rune_state.runes or {}
        for i = 1, 7 do
            rune_state.runes[tostring(i)] = 1
        end
        rune_state.all = 7
        rune_state.claim = 1
        rune_state.level_bonus = 1
        Player.setJsonVarByTable(play, VarCfg["T_???????"], rune_state)
        jq_data["npc_84"] = type(jq_data["npc_84"]) == "table" and jq_data["npc_84"] or {}
        jq_data["npc_84"].wc = 1
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        Player.title_give(play, "????????[????]")
        Player.sendmsgEx(play, "??????????????????????>=35?????>=150?????>=70??3-6?????????????????????????????????[????]")
    elseif id == "23" then
        release_print("???????")
        local cailiao = {
"??§¶???[??]",
"??§¶???[?]",
"??§¶???[??]",
"??§¶???[??]",
"??§¶???[??]",
"??§¶???[??]",
"??§¶???[??]",
"??§¶???[??]",
"??§¶???[??]",
"??§¶???[??]",
"??§¶???[??]",
"??§¶???[??]",






        }
        for k, v in pairs(cailiao) do
            giveitem(play,v,1)
        end
    elseif id == "24" then

            local story = Player.getJsonTableByVar(play, VarCfg.T_dljq) or {}
            story["npc_721"] = 2
            Player.setJsonTableByVar(play, VarCfg.T_dljq,story)

        -- local jq_data = {}
        -- Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
--         -- ???????????????????????????§³???9x9??????
--         local map_list = {

-- "??????",

--         } -- TODO: ???????????????
--         local normal_mobs = {"????"} -- TODO: ??????§Ò?

--         local range = 3 -- ?????????
--         local check_range = 6 -- 9x9????(2*4+1)
--         local max_fail = 40 -- ???????????(????)
--         local tries_per_spawn = 10 -- ??????????????
--         local spawn_limit = 5000 -- ????????¦Â???????

--         for _, map in ipairs(map_list) do
--             local w = getmapinfo(map, 0) or 0
--             local h = getmapinfo(map, 1) or 0
--             if w > 0 and h > 0 then
--                 -- ???????????????
--                 killmonsters(map, "*", 0, false)

--                 local counter = {n = 0}
--                 local added_normal = 0
--                 local sample_count = 0
--                 local total_ncnt = 0

--                 local fail_streak = 0
--                 local used_points = {}

--                 while fail_streak < max_fail do
--                     local rx = math.random(1, w)
--                     local ry = math.random(1, h)

--                     local key = rx.."_"..ry
--                     if used_points[key] then
--                         fail_streak = fail_streak + 1
--                     else
--                         local ok = true
--                         for k, _ in pairs(used_points) do
--                             local sx, sy = k:match("(%d+)_([%d]+)")
--                             if sx and sy then
--                                 sx = tonumber(sx)
--                                 sy = tonumber(sy)
--                                 if math.abs(rx - sx) <= check_range and math.abs(ry - sy) <= check_range then
--                                     ok = false
--                                     break
--                                 end
--                             end
--                         end

--                         if ok then
--                             genmonex(map, rx, ry, normal_mobs[math.random(1, #normal_mobs)], 1, 1, 0, 54, "", 0)
--                             used_points[key] = true
--                             counter.n = counter.n + 1
--                             added_normal = added_normal + 1
--                             fail_streak = 0
--                         else
--                             fail_streak = fail_streak + 1
--                         end
--                     end

--                     sample_count = sample_count + 1
--                     total_ncnt = total_ncnt + (used_points[key] and 1 or 0)

--                     if counter.n >= spawn_limit then
--                         break
--                     end
--                 end
--                     local avg_n = math.floor(total_ncnt / math.max(1, sample_count) + 0.5)
--                     sendmsg(play, 1, "{\"Msg\":\"<font color=\\\"#00ff00\\\">???["..map.."] §³?????"..added_normal.." ????????"..avg_n.."</font>\",\"Type\":9}")
--                     release_print("???["..map.."] §³?????"..added_normal)
--                     release_print("?????? §³???"..avg_n)
--             else
--                 sendmsg(play, 1, '{"Msg":"<font color=\"#ff0000\">???['..map..']????????</font>","Type":9}')
--             end
--         end
--         return
        -- local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
        -- jq_data["npc_714"] = nil
        -- Player.setJsonTableByVar(play, VarCfg.T_dljq, jq_data)
        -- local sg_data = Player.getJsonTableByVar(play, VarCfg["T_?????????"])
        -- sg_data["npc_696"] = sg_data["npc_696"] + 100
        -- Player.setJsonTableByVar(play, VarCfg["T_?????????"], sg_data)
        		-- sendmsgnew(play, 255, 0, '??????????{??' .. getbaseinfo(play, 1) .. '??/FCOLOR=251}???????{[?????]/FCOLOR=250},???????????????...', 1, 3)
        ---??????
        -- ?????????????????@ggn,14
        -- Npclib[654].link(play, 654, 1, 0, "")
        -- -- release_print(where)
        -- if not where then
        --     Player.sendmsgEx(play, "???????????????????????#57")
        --     return
        -- end
        -- local itemobj = linkbodyitem(play,where)
        -- local item_json = getitemcustomabil(play, itemobj)
        -- release_print(item_json)
        -- item_json = json2tbl(item_json)
        -- if item_json then
        -- end
        -- item_json.abil[1].v[1] = {1,253,200,1,13,1,1}
        -- item_json.abil[1].v[2] = {1,200,300,1,14,2,2}
        -- item_json.abil[1].v[3] = {1,244,8000,0,15,3,3}
        -- item_json.abil[1].v[4] = {1,30,5,1,16,4,4}
        -- item_json.abil[1].v[5] = {1,73,100,1,17,5,5}
        -- item_json.abil[1].v[6] = {1,89,100,1,18,6,6}
        -- item_json.abil[1].v[7] = {1,206,100,1,19,7,7}
        -- item_json = tbl2json(item_json)
        -- -- release_print(type(item_json))
        -- setitemcustomabil(play, itemobj, item_json)
        -- Player.setJsonVarByTable(play, VarCfg["T_??????"], {})
        -- setplaydef(play, VarCfg.T_czlb,"{}")
        -- setplaydef(play,VarCfg.U_zxrw[1],21)
        -- local _cfg_key = "npc_705"
        -- local _config = Guard.getConfig(_cfg_key)
        -- local _task_cfg = (_config and _config.task_cfg) or {}
        -- local _choice_key = _cfg_key .. "_choice" -- 1=???????2=???¦Ë?
        -- local _step_key = _cfg_key .. "_step" -- 1=???????????
        -- local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
        -- local sg_data = Player.getJsonTableByVar(play, VarCfg["T_?????????"])
        -- local state = tonumber(jq_data[_cfg_key] or 0) or 0
        -- local key_small = _cfg_key .. "_small"
        -- local key_boss = _cfg_key .. "_boss"
        -- local cur_small = tonumber(sg_data[key_small] or 0) or 0
        -- local cur_boss = tonumber(sg_data[key_boss] or 0) or 0
        -- jq_data[_cfg_key] = nil
        -- jq_data[_choice_key] = nil
        -- jq_data[_cfg_key] = nil
        --     jq_data[_step_key] = nil
        --     Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        --     -- ???????????
        -- sg_data[key_small] = nil
        -- sg_data[key_boss] = nil
        -- Player.setJsonVarByTable(play, VarCfg["T_?????????"], sg_data)
        -- local sg_data = Player.getJsonTableByVar(play, VarCfg["T_?????????"])
        -- local key_small = _cfg_key .. "_small"
        -- local key_boss = _cfg_key .. "_boss"
        -- sg_data[key_small] = 200
        -- sg_data[key_boss] = 2
        -- Player.setJsonVarByTable(play, VarCfg["T_?????????"], sg_data)
        -- local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
        -- jq_data["npc_55"] = nil
        -- Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
    end
end
return npc
















