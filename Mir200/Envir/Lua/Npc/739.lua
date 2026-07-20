npc = {}


local NPC_ID = 739
local _cfg_key = "npc_" .. tostring(NPC_ID)
local _config = Guard.getConfig(_cfg_key)
local _task_cfg = (_config and _config.task_cfg) or {}
local DROP_RULES = {{map = "魔焰祭坛", item = "幽影密函残页", rate = 200}}
local KILL_ONLY = false
local ALLOW_PRESTART_DROP = false


local function _toint(v, d)
    local n = tonumber(v)
    if n == nil then
        return d or 0
    end
    return math.floor(n)
end

local function _get_story(play)
    return Player.getJsonTableByVar(play, VarCfg.T_dljq) or {}
end

local function _save_story(play, data)
    Player.setJsonVarByTable(play, VarCfg.T_dljq, data or {})
end

local function _get_kill(play)
    return Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"]) or {}
end

local function _save_kill(play, data)
    Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], data or {})
end

local function _send_state(play, npcid)
    local data = {T_dljq = _get_story(play), sg_data = _get_kill(play)}
    sendluamsg(play, 100, npcid or NPC_ID, 0, 0, tbl2json(data))
end


local function _sg_add(play, id)
    if shaguai and shaguai.jia then
        shaguai.jia(play, id)
    end
end

local function _sg_remove(play, id)
    if shaguai and shaguai.jian then
        shaguai.jian(play, id)
    end
end

local function _sg_drop(play, mob, item)
    if shaguai and shaguai.temp_drop then
        return shaguai.temp_drop(play, mob, item)
    end
    additemtodroplist(play, mob, item)
    return true
end

local function _finish(play, reason, noReward)
    local jq = _get_story(play)
    jq[_cfg_key] = 2
    jq[_cfg_key .. "_a"] = nil
    _save_story(play, jq)
    local levelReward = _toint(_task_cfg.level_reward)
    if not noReward and levelReward <= 0 then
        Guard.giveTaskReward(play, _config, reason or ((_config.name or "第六章剧情") .. "奖励"))
    end
    if levelReward > 0 then
        callscriptex(play, "CHANGELEVEL", "+", levelReward)
        Player.sendmsgEx(play, "等级提升+" .. levelReward .. "#57")
    end
    sendluamsg(play, 101, 1005, 0, 0, "rwwc")
end

local function _ensure_started(play)
    local jq = _get_story(play)
    if _toint(jq[_cfg_key]) >= 2 then
        return true
    end
    if _toint(jq[_cfg_key]) < 1 then
        jq[_cfg_key] = 1
        _save_story(play, jq)
        Player.sendmsgEx(play, "领取|【" .. (_config.name or "第六章剧情") .. "】#218|")
        sendluamsg(play, 101, 1005, 0, 0, "rwjs")
        local shaguaiId = _toint(_config.shaguai_id)
        if shaguaiId > 0 then
            _sg_add(play, shaguaiId)
        end
        return false
    end
    return true
end

local function _need_map_ok(play, taskCfg)
    local map = taskCfg.map
    if not map or map == "" then
        return true
    end
    local cur = getbaseinfo(play, 3)
    if cur == map or cur == "xtc" or cur == "六大陆主城" then
        return true
    end
    Player.sendmsgEx(play, "请前往#57|【" .. map .. "】#218|完成后再提交#57")
    return false
end

local function _check_kill(play, need)
    need = _toint(need)
    if need <= 0 then
        return true
    end
    local sg = _get_kill(play)
    local cur = _toint(sg[_cfg_key])
    if cur < need then
        Player.sendmsgEx(play, string.format("击杀不足：#57|【%d/%d】#218|", cur, need))
        return false
    end
    return true
end

local function _consume_cost(play, cost, reason)
    if not Guard.ensureCost(play, cost) then
        return false
    end
    Guard.consumeCost(play, cost, reason)
    return true
end

local _back_pos_var = "S$npc739_back"
local _run_map_var = "S$npc739_map"
local _run_boss_state_var = "U$npc739_boss_state"
local _run_spawn_ok_var = "U$npc739_spawn_ok"
local _run_fail_var = "U$npc739_fail"
local _run_state = {}

local function _has_zhuque_pet(play)
    local data = Player.getJsonTableByVar(play, VarCfg["T_灵兽"]) or {}
    return _toint(data.dqzh) == 3
end
local function _state_get(dtm)
    local st = _run_state[dtm]
    if not st then
        st = {boss_state = 0, spawn_ok = 0, failed = 0}
        _run_state[dtm] = st
    end
    return st
end

local function _state_clear(dtm)
    if dtm and dtm ~= "" then
        _run_state[dtm] = nil
    end
end

local function _find_mon_by_name(dtm, name)
    if not dtm or dtm == "" or not name or name == "" then
        return nil
    end
    local list = getobjectinmap(dtm, 0, 0, 999, 2)
    if list then
        for _, v in ipairs(list) do
            if getbaseinfo(v, 1) == name then
                local hp = tonumber(getbaseinfo(v, 9) or 0) or 0
                if hp > 0 then
                    return v
                end
            end
        end
    end
    return nil
end

local function _save_back_pos(play)
    setplaydef(play, _back_pos_var, tostring(getbaseinfo(play, 3) or "") .. "," .. tostring(getbaseinfo(play, 4) or 0) .. "," .. tostring(getbaseinfo(play, 5) or 0))
end

local function _clear_run_vars(play, dtm)
    setplaydef(play, _back_pos_var, "")
    setplaydef(play, _run_map_var, "")
    setplaydef(play, _run_boss_state_var, 0)
    setplaydef(play, _run_spawn_ok_var, 0)
    setplaydef(play, _run_fail_var, 0)
    _state_clear(dtm)
end

local function _back(play)
    local dtm = getplaydef(play, _run_map_var)
    local back = tostring(getplaydef(play, _back_pos_var) or "")
    if back ~= "" then
        local parts = split(back, ",")
        local map = parts[1]
        local x = tonumber(parts[2]) or 0
        local y = tonumber(parts[3]) or 0
        if map and map ~= "" and x > 0 and y > 0 then
            mapmove(play, map, x, y, 2)
        else
            mapmove(play, "六大陆主城", 17, 74, 2)
        end
    else
        mapmove(play, "六大陆主城", 17, 74, 2)
    end
    _clear_run_vars(play, dtm)
end

local function _on_pass(play)
    local jq = _get_story(play)
    if _toint(jq[_cfg_key]) >= 2 then
        return
    end
    Guard.clearTaskTemp(jq, _cfg_key)
    jq[_cfg_key] = 2
    _save_story(play, jq)
    local sg = _get_kill(play)
    sg[_cfg_key] = _toint(_task_cfg.kill_count, 1)
    _save_kill(play, sg)
    _sg_remove(play, NPC_ID)
    sendluamsg(play, 101, 1005, 0, 0, "rwwc")
    Player.sendmsgEx(play, "|【" .. (_config.name or "任务") .. "】#218|完成，获得称号|【幽影之力】#218|")
    Guard.giveTaskReward(play, _config, (_config.name or "剧情任务") .. "奖励")
end

local function _fail(play, dtm)
    local st = _state_get(dtm)
    if _toint(st.failed) > 0 then
        return
    end
    st.failed = 1
    setplaydef(play, _run_fail_var, 1)
    Player.sendmsgEx(play, "幽影逃走了#57")
    messagebox(play, "幽影逃走了")
    if getbaseinfo(play, 3) == dtm then
        _back(play)
    else
        _clear_run_vars(play, dtm)
    end
    if checkmirrormap(dtm) then
        setenvirofftimer(dtm, 1)
        delmirrormap(dtm)
    end
end

local function _enter_dungeon(play, npcid)
    local jq = _get_story(play)
    if _toint(jq[_cfg_key]) >= 2 then
        Player.sendmsgEx(play, "你已经完成#57|【" .. (_config.name or "该任务") .. "】#218|")
        return
    end
    if _toint(jq[_cfg_key]) < 1 then
        jq[_cfg_key] = 1
        _save_story(play, jq)
    end
    _sg_add(play, NPC_ID)
    _save_back_pos(play)
    local baseMap = _task_cfg.fb_map or _task_cfg.map or "魔焰祭坛"
    local dtm = tostring(getbaseinfo(play, 1) or "player") .. "_npc739"
    if checkmirrormap(dtm) then
        delmirrormap(dtm)
    end
    _state_clear(dtm)
    addmirrormap(baseMap, dtm, "幽影的分身", _task_cfg.fb_time or 300, "xtc")
    local pos = _task_cfg.enter_pos or {29, 27}
    mapmove(play, dtm, tonumber(pos[1] or 29) or 29, tonumber(pos[2] or 27) or 27, 2)
    local bossPos = _task_cfg.boss_pos or {32, 36}
    genmonex(dtm, tonumber(bossPos[1] or 32) or 32, tonumber(bossPos[2] or 36) or 36, _task_cfg.boss or "幽影的分身", 1, 1, 0, 54, "", 0)
    local st = _state_get(dtm)
    st.boss_state = 1
    st.spawn_ok = 1
    st.failed = 0
    setplaydef(play, _run_map_var, dtm)
    setplaydef(play, _run_boss_state_var, 1)
    setplaydef(play, _run_spawn_ok_var, 1)
    setplaydef(play, _run_fail_var, 0)
    startautoattack(play)
    setenvirontimer(dtm, 1, 1, "@npc_739_dsq," .. play .. "," .. dtm)
    senddelaymsg(play, "距离副本结束剩余%s", _task_cfg.fb_time or 300, 250, 1, "@npc_739_timeout")
    if npcid then
        Guard.closeNpcAndAuto(play, npcid)
    end
    if _has_zhuque_pet(play) then
        Player.sendmsgEx(play, "已携带灵兽朱雀，幽影无法逃走#57")
    else
        Player.sendmsgEx(play, "未携带灵兽朱雀，幽影半血会逃走#57")
    end
end

function npc_739_dsq(xt, play, dtm, data)
    local pc = getplaycount(dtm, false, true)
    local run_play = play
    if type(pc) == "table" then
        if pc[1] then
            run_play = pc[1]
        else
            for _, p in pairs(pc) do
                run_play = p
                break
            end
        end
    end
    local no_player = (pc == "0" or pc == 0 or (type(pc) == "table" and next(pc) == nil))
    if no_player then
        setenvirofftimer(dtm, 1)
        if checkmirrormap(dtm) then
            delmirrormap(dtm)
        end
        if run_play then
            _clear_run_vars(run_play, dtm)
        end
        return
    end
    local st = _state_get(dtm)
    local boss = _find_mon_by_name(dtm, _task_cfg.boss or "幽影的分身")
    if boss then
        st.boss_state = 1
        st.spawn_ok = 1
        local curhp = tonumber(getbaseinfo(boss, 9) or 0) or 0
        local maxhp = tonumber(getbaseinfo(boss, 10) or 0) or 0
        local failPct = tonumber(_task_cfg.half_fail_hp_pct or 50) or 50
        if not _has_zhuque_pet(run_play) and maxhp > 0 and curhp > 0 and curhp * 100 <= maxhp * failPct then
            _fail(run_play, dtm)
        end
        return
    end
    if _toint(st.spawn_ok) == 1 and _toint(st.boss_state) >= 1 then
        if not _has_zhuque_pet(run_play) then
            _fail(run_play, dtm)
            return
        end
        _on_pass(run_play)
        if getbaseinfo(run_play, 3) == dtm then
            _back(run_play)
        else
            _clear_run_vars(run_play, dtm)
        end
        if checkmirrormap(dtm) then
            setenvirofftimer(dtm, 1)
            delmirrormap(dtm)
        end
    end
end

function npc_739_timeout(play)
    local dtm = getplaydef(play, _run_map_var)
    if not dtm or dtm == "" then
        return
    end
    Player.sendmsgEx(play, "副本时间结束#57")
    if getbaseinfo(play, 3) == dtm then
        _back(play)
    else
        _clear_run_vars(play, dtm)
    end
    if checkmirrormap(dtm) then
        setenvirofftimer(dtm, 1)
        delmirrormap(dtm)
    end
end

local function _generic_submit(play)
    local state = _toint((_get_story(play))[_cfg_key])
    if state >= 2 then
        Player.sendmsgEx(play, "你已经完成#57|【" .. (_config.name or "该任务") .. "】#218|")
        return
    end
    local ready = _ensure_started(play)
    if not ready and _task_cfg.task_type ~= "auto_claim" then
        return
    end
    if not _need_map_ok(play, _task_cfg) then
        return
    end
    if not _check_kill(play, _task_cfg.kill_count) then
        return
    end
    if not _consume_cost(play, _task_cfg.submit or _config.cost or {}, "," .. (_config.name or "第六章剧情")) then
        return
    end
    _finish(play, (_config.name or "第六章剧情") .. "奖励")
end


local function _is_six_continent_map(map)
    if not map or map == "" then
        return false
    end
    if daluditu and _toint(daluditu[map]) == 6 then
        return true
    end
    local known = {
        ["六大陆主城"] = true, ["冰川雪域"] = true, ["冻魂冰窟"] = true,
        ["森罗魔域"] = true, ["魔焰祭坛"] = true, ["边关烽城"] = true,
        ["镇关帅府"] = true, ["盛世古城"] = true, ["长安西市"] = true,
        ["洛阳天街"] = true, ["汴京御街"] = true, ["临安古渡"] = true,
        ["血契之地"] = true, ["血契之地二层"] = true,
    }
    return known[map] == true
end

local function _has_post_done_drop(play)
    for _, rule in ipairs(DROP_RULES) do
        if rule.require_done then
            return true
        end
    end
    return false
end

local function _drop_by_rule(play, mob, state)
    local map = tostring(getbaseinfo(play, 3) or "")
    for _, rule in ipairs(DROP_RULES) do
        local ok = true
        if rule.map and rule.map ~= map then
            ok = false
        end
        if rule.continent and not _is_six_continent_map(map) then
            ok = false
        end
        if rule.require_done and state < 2 then
            ok = false
        end
        if rule.require_craft then
            local jq = _get_story(play)
            if _toint(jq[_cfg_key .. "_done"]) < 1 then
                ok = false
            end
        end
        if ok and rule.item and rule.item ~= "" then
            if not rule.max_bag or getbagitemcount(play, rule.item) < _toint(rule.max_bag) then
                local rate = math.max(1, _toint(rule.rate, 1))
                if math.random(rate) == 1 and _sg_drop(play, mob, rule.item) then
                    Player.sendmsgEx(play, "打怪掉落【" .. rule.item .. "】#57")
                end
            end
        end
    end
end

local function _onKillMon(play, mob)
    local state = _toint((_get_story(play))[_cfg_key])
    if state >= 2 and not _has_post_done_drop(play) then
        _sg_remove(play, NPC_ID)
        return
    end
    if state < 1 and not ALLOW_PRESTART_DROP then
        return
    end
    _drop_by_rule(play, mob, state)
    local need = _toint(_task_cfg.kill_count)
    if need <= 0 and not KILL_ONLY then
        return
    end
    if state >= 2 then
        return
    end
    local map = tostring(getbaseinfo(play, 3) or "")
    local reqMap = _task_cfg.map
    local bossName = _task_cfg.boss or _task_cfg.escort_boss
    local mobName = tostring(getbaseinfo(mob, 1) or "")
    local countThis = false
    if (_task_cfg.task_type == "weakness_dungeon" or _task_cfg.task_type == "escort") and bossName and bossName ~= "" then
        countThis = mobName == bossName
    elseif bossName and bossName ~= "" and mobName == bossName then
        countThis = true
    elseif reqMap and reqMap == map then
        countThis = true
    end
    if not countThis then
        return
    end
    local sg = _get_kill(play)
    local cur = _toint(sg[_cfg_key])
    if cur >= need then
        return
    end
    cur = math.min(cur + 1, need)
    sg[_cfg_key] = cur
    _save_kill(play, sg)
    Player.sendmsgEx(play, (_config.name or _cfg_key) .. "进度+1 ( " .. cur .. "/" .. need .. " )#57")
    if cur >= need then
        _sg_remove(play, NPC_ID)
        if _task_cfg.task_type == "weakness_dungeon" then
            if _has_zhuque_pet(play) then
                _on_pass(play)
            else
                Player.sendmsgEx(play, "幽影逃走了#57")
                messagebox(play, "幽影逃走了")
            end
            return
        end
        messagebox(play, "任务目标完成,请前往提交")
    end
end

local function _handle(play, npcid, action, aid)
    local taskCfg = _task_cfg
    if action == 2 then
        local jq = _get_story(play)
        if _toint(jq[_cfg_key]) >= 2 then
            Player.sendmsgEx(play, "你已经完成#57|【" .. (_config.name or "该任务") .. "】#218|")
            return
        end
        if _toint(jq[_cfg_key .. "_weak"]) == 1 then
            Player.sendmsgEx(play, "幽影弱点已揭示，可进入副本挑战#57")
            return
        end
        if not _consume_cost(play, taskCfg.reveal_cost or {{"幽影密函残页", 10}}, ",幽影弱点揭示") then
            return
        end
        jq[_cfg_key] = 1
        jq[_cfg_key .. "_weak"] = 1
        _save_story(play, jq)
        _sg_add(play, NPC_ID)
        Player.sendmsgEx(play, "已揭示弱点：击杀幽影的分身后自动完成任务#57")
        return
    end
    if action == 3 then
        _enter_dungeon(play, npcid)
        return
    end
    Player.sendmsgEx(play, "该任务击杀幽影的分身后会自动完成#57")
end

function npc.main(play, npcid)
    if not _config then
        return
    end
    if not Guard.ensureStoryPrerequisite(play, _config, NPC_ID) then
        return
    end
    _send_state(play, npcid or NPC_ID)
end

function npc.link(play, npcid, ew, aid, msgData)
    if not _config then
        return
    end
    if not Guard.ensureStoryPrerequisite(play, _config, NPC_ID) then
        return
    end
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local action = Guard.normalizeAction(play, npcid, ew)
    if not action then
        return
    end
    if not Guard.ensureActionAllowed(play, npcid, action, Guard.newActionSet({2, 3, 4})) then
        return
    end
    if action == 4 then
        _onKillMon(play, aid)
        return
    end
    _handle(play, npcid or NPC_ID, action, aid)
    _send_state(play, npcid or NPC_ID)
end

return npc



