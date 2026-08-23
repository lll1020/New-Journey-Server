npc = {}


-- 天命试炼
local _config = Guard.getConfig("npc_76")
local _pre_key = "npc_74"
local _task_key = "npc_76"
local _back_pos_var = "S$npc76_back"
local _run_map_var = "S$npc76_map"
local _run_idx_var = "U$npc76_idx"
local _dujie_end_var = "N$npc76_dj_end"
local _safe_effect_prefix = "npc76_safe_"
local _safe_effect_timer_id = 2
local _run_state = {}

local function _dbg(tag, ...)
    -- release_print("[npc76][" .. tostring(tag) .. "]", ...)
end

local function _state_get(dtm)
    if not dtm or dtm == "" then
        return {}
    end
    local st = _run_state[dtm]
    if not st then
        st = {}
        _run_state[dtm] = st
    end
    return st
end

local function _state_clear(dtm)
    if dtm and dtm ~= "" then
        _run_state[dtm] = nil
    end
end

local function _safe_effect_id(dtm)
    return _safe_effect_prefix .. tostring(dtm or "")
end

local function _draw_xianfa_safe_effect(dtm, cfg, st)
    if not dtm or dtm == "" or not checkmirrormap(dtm) or not st then
        return
    end
    local x = tonumber(st.safe_x or 0) or 0
    local y = tonumber(st.safe_y or 0) or 0
    if x <= 0 or y <= 0 then
        return
    end
    local effect_id = tonumber(cfg and cfg.safe_effect or 92) or 92
    release_print("[npc76][_draw_xianfa_safe_effect] dtm=" .. tostring(dtm) .. " x=" .. tostring(x) .. " y=" .. tostring(y) .. " effect_id=" .. tostring(effect_id))
    release_print(_safe_effect_id(dtm)..os.time())
    mapeffect(_safe_effect_id(dtm)..os.time(), dtm, x, y, effect_id, 2, 0)
    for i = 1, 50 do
        mapeffect(_safe_effect_id(dtm).."lei"..os.time(), dtm, 33 + math.random(-30, 30), 37 + math.random(-30, 30), 56, 1, 0)
    end
    
end

local function _get_data(play)
    local T_data = Player.getJsonTableByVar(play, VarCfg.T_dljq) or {}
    T_data[_pre_key] = T_data[_pre_key] or {}
    T_data[_task_key] = T_data[_task_key] or {}
    return T_data
end

local function _save_data(play, T_data)
    Player.setJsonVarByTable(play, VarCfg.T_dljq, T_data)
end

local function _build_panel_data(play)
    local data = {T_data = _get_data(play)}
    local run_map = tostring(getplaydef(play, _run_map_var) or "")
    local current_map = tostring(getbaseinfo(play, 3) or "")
    local run_idx = tonumber(getplaydef(play, _run_idx_var) or 0) or 0
    if run_idx < 1 or run_idx > 4 then
        run_idx = tonumber(string.match(current_map, "_npc76_(%d+)$") or 0) or 0
    end
    if run_map == "" and run_idx >= 1 and run_idx <= 4 and checkmirrormap(current_map) then
        run_map = current_map
    end
    data.run_idx = run_idx
    data.in_fb = (run_map ~= "" and current_map == run_map) and 1 or 0
    return data
end

local function _refresh_panel(play, ew, aid)
    sendluamsg(play, 100, 76, ew or 0, aid or 0, tbl2json(_build_panel_data(play)))
end

local function _trial_cfg(idx)
    local detail = _config and _config.details and _config.details[idx] or nil
    return detail and detail.trial or {}
end

local function _idx_from_map(dtm)
    local idx = tonumber(string.match(tostring(dtm or ""), "_npc76_(%d+)$") or 0) or 0
    if idx >= 1 and idx <= 4 then
        return idx
    end
    return 0
end

local function _get_run_idx(play, dtm, st)
    local idx = tonumber(st and st.idx or 0) or 0
    if idx < 1 or idx > 4 then
        idx = tonumber(getplaydef(play, _run_idx_var) or 0) or 0
    end
    if idx < 1 or idx > 4 then
        idx = _idx_from_map(dtm)
    end
    if idx >= 1 and idx <= 4 then
        if st then
            st.idx = idx
        end
        setplaydef(play, _run_idx_var, idx)
    end
    return idx
end

local function _count_mon_by_name(dtm, name)
    if not dtm or dtm == "" or not name or name == "" then
        return 0
    end
    local list = getobjectinmap(dtm, 0, 0, 999, 2)
    local cnt = 0
    if list then
        for _, v in ipairs(list) do
            if getbaseinfo(v, 1) == name then
                local hp = tonumber(getbaseinfo(v, 9) or 0) or 0
                if hp > 0 then
                    cnt = cnt + 1
                end
            end
        end
    end
    return cnt
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

local function _spawn_many(dtm, name, count, center)
    if not name or name == "" then
        return
    end
    local total = tonumber(count or 0) or 0
    if total < 1 then
        return
    end
    local cx = tonumber((center or {})[1] or 32) or 32
    local cy = tonumber((center or {})[2] or 36) or 36
    for i = 1, total do
        local dx = ((i - 1) % 4) - 1
        local dy = math.floor((i - 1) / 4)
        genmonex(dtm, cx + dx, cy + dy, name, 1, 1, 0, 54, "", 0)
    end
end

local function _save_back(play)
    local map = getbaseinfo(play, 3)
    local x = getbaseinfo(play, 4)
    local y = getbaseinfo(play, 5)
    setplaydef(play, _back_pos_var, tostring(map or "") .. "," .. tostring(x or 0) .. "," .. tostring(y or 0))
end

local function _clear_run(play)
    setplaydef(play, _back_pos_var, "")
    setplaydef(play, _run_map_var, "")
    setplaydef(play, _run_idx_var, 0)
    setplaydef(play, _dujie_end_var, 0)
end

local function _get_current_trial_map(play)
    local run_map = tostring(getplaydef(play, _run_map_var) or "")
    local current_map = tostring(getbaseinfo(play, 3) or "")
    if run_map == "" and _idx_from_map(current_map) > 0 and checkmirrormap(current_map) then
        run_map = current_map
        setplaydef(play, _run_map_var, run_map)
    end
    return run_map
end

local function _get_active_trial_map(play)
    local run_map = _get_current_trial_map(play)
    if run_map == "" then
        return ""
    end
    if checkmirrormap(run_map) then
        return run_map
    end
    _clear_run(play)
    return ""
end

local function _back(play)
    local dtm = _get_current_trial_map(play)
    local back = tostring(getplaydef(play, _back_pos_var) or "")
    _dbg("back", tostring(getbaseinfo(play, 1) or ""), "run_map=" .. dtm, "back=" .. back)
    delmapeffect(_safe_effect_id(dtm))
    if back ~= "" then
        local parts = split(back, ",")
        local map = parts[1]
        local x = tonumber(parts[2] or 0) or 0
        local y = tonumber(parts[3] or 0) or 0
        if map and map ~= "" and x > 0 and y > 0 then
            mapmove(play, map, x, y, 2)
        end
    end
    _clear_run(play)
    _state_clear(dtm)
end

local function _close_map(dtm)
    if dtm and dtm ~= "" then
        _dbg("close_map", "dtm=" .. tostring(dtm), "check=" .. tostring(checkmirrormap(dtm)))
        delmapeffect(_safe_effect_id(dtm))
        setenvirofftimer(dtm, 1)
        setenvirofftimer(dtm, _safe_effect_timer_id)
        if checkmirrormap(dtm) then
            delmirrormap(dtm)
        end
        _state_clear(dtm)
    end
end

local function _has_pet_ready(play)
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_灵兽"]) or {}
    local idx = tonumber(T_data.dqzh or 0) or 0
    if idx <= 0 then
        return false
    end
    local ls = T_data.ls or {}
    return (tonumber(ls[tostring(idx)] or 0) or 0) > 0
end

local function _pick_safe_point(cfg, st)
    local points = cfg.safe_points
    if type(points) == "table" and #points > 0 then
        local last_idx = tonumber(st.safe_idx or 0) or 0
        local point_idx = math.random(#points)
        if #points > 1 then
            for _ = 1, 10 do
                if point_idx ~= last_idx then
                    break
                end
                point_idx = math.random(#points)
            end
        end
        local point = points[point_idx] or {}
        return {tonumber(point[1] or 32) or 32, tonumber(point[2] or 31) or 31}, point_idx
    end
    local center = cfg.safe_center or {32, 31}
    local radius = tonumber(cfg.safe_spawn_radius or 5) or 5
    local cx = tonumber(center[1] or 32) or 32
    local cy = tonumber(center[2] or 31) or 31
    local last_x = tonumber(st.safe_x or 0) or 0
    local last_y = tonumber(st.safe_y or 0) or 0
    for _ = 1, 20 do
        local x = cx + math.random(-radius, radius)
        local y = cy + math.random(-radius, radius)
        if math.max(math.abs(x - cx), math.abs(y - cy)) <= radius then
            if x ~= last_x or y ~= last_y then
                return {x, y}, 1
            end
        end
    end
    return {cx, cy}, 1
end

local function _start_xianfa_round(play, dtm, cfg, st)
    st.round = (tonumber(st.round) or 0) + 1
    local point, safe_idx = _pick_safe_point(cfg, st)
    st.safe_idx = safe_idx
    st.safe_x = tonumber(point[1] or 32) or 32
    st.safe_y = tonumber(point[2] or 31) or 31
    st.round_end = os.time() + (tonumber(cfg.round_sec or 20) or 20)
    st.last_score_tick = 0
    delmapeffect(_safe_effect_id(dtm))
    _draw_xianfa_safe_effect(dtm, cfg, st)
    Player.sendmsgEx(play, string.format("第%d轮开始，前往安全区累计积分#57", st.round))
end

local function _enter_trial(play, idx)
    local cfg = _trial_cfg(idx)
    local dtm = tostring(getbaseinfo(play, 1) or "") .. "_npc76_" .. tostring(idx)
    _dbg("enter_begin", "player=" .. tostring(getbaseinfo(play, 1) or ""), "idx=" .. tostring(idx), "dtm=" .. dtm, "map=" .. tostring(getbaseinfo(play, 3) or ""))
    if checkmirrormap(dtm) then
        _dbg("enter_delete_old", "dtm=" .. dtm)
        delmirrormap(dtm)
    end

    _save_back(play)
    _state_clear(dtm)
    local st = _state_get(dtm)
    st.idx = idx
    st.created_at = os.time()
    st.last_player_seen = st.created_at
    st.spawn_verified = false
    st.spawn_grace_until = nil

    addmirrormap(cfg.fb_map or "mwsl", dtm, (_config.details[idx] and _config.details[idx].name or "天命试炼"), tonumber(cfg.fb_time or 300) or 300,"xtc",136,136)
    _dbg("enter_map_created", "dtm=" .. dtm, "fb_map=" .. tostring(cfg.fb_map or "mwsl"), "fb_time=" .. tostring(cfg.fb_time or 300))
    local enter_pos = cfg.enter_pos or {29, 27}
    setplaydef(play, _run_map_var, dtm)
    setplaydef(play, _run_idx_var, idx)
    setplaydef(play, _dujie_end_var, 0)
    -- 先记录副本状态，再传送，避免切图后首个计时器读到默认 idx=0。
    mapmove(play, dtm, tonumber(enter_pos[1] or 29) or 29, tonumber(enter_pos[2] or 27) or 27, 2)
    _dbg("enter_mapmove_called", "player=" .. tostring(getbaseinfo(play, 1) or ""), "now_map=" .. tostring(getbaseinfo(play, 3) or ""), "target=" .. dtm)

    if idx == 1 then
        st.spawn_grace_until = os.time() + 5
        local pos = cfg.boss_pos or {32, 36}
        genmonex(dtm, tonumber(pos[1] or 32) or 32, tonumber(pos[2] or 36) or 36, cfg.boss or "≮火烧连营·天命策尊≯", 1, 1, 0, 54, "", 0)
        if tonumber(cfg.boss_effect or 0) > 0 then
            mapeffect("npc76_boss_" .. dtm, dtm, tonumber(pos[1] or 32) or 32, tonumber(pos[2] or 36) or 36, tonumber(cfg.boss_effect or 92) or 92, 10, 2, 0)
        end
        Player.sendmsgEx(play, "灵兽试炼开启：只有灵兽攻击才能让BOSS掉血#57")
    elseif idx == 2 then
        st.spawn_grace_until = os.time() + 5
        _spawn_many(dtm, cfg.mob or "暗影打手", tonumber(cfg.mob_count or 10) or 10, cfg.mob_center or {32, 36})
        _spawn_many(dtm, cfg.elite or "暗影打手·精英", tonumber(cfg.elite_count or 3) or 3, {34, 36})
        _spawn_many(dtm, cfg.boss or "王婆", 1, cfg.boss_pos or {32, 36})
        Player.sendmsgEx(play, "灵根试炼开启：清理全部怪物即可通关#57")
    elseif idx == 3 then
        st.success = 0
        st.next_lightning_at = os.time() + (tonumber(cfg.lightning_sec or 5) or 5)
        st.last_notice = -1
        Player.sendmsgEx(play, "境界试炼开启：服用【天道·渡劫丹】可抵挡1次雷劫#57")
    elseif idx == 4 then
        st.score = 0
        st.round = 0
        _start_xianfa_round(play, dtm, cfg, st)
        Player.sendmsgEx(play, "天书仙法试炼开启：站在安全区内累计积分#57")
    end

    startautoattack(play)
    setenvirontimer(dtm, 1, 1, "@npc_76_dsq," .. play .. "," .. dtm)
    if idx == 4 then
        setenvirontimer(dtm, _safe_effect_timer_id, 2, "@npc_76_safe_fx," .. dtm)
    end
    senddelaymsg(play, "距离试炼结束剩余%s", tonumber(cfg.fb_time or 300) or 300, 250, 1, "@npc_76_timeout")
    _refresh_panel(play, 1, idx)
end

local function _finish_trial(play, idx, dtm)
    local T_data = _get_data(play)
    local state = T_data[_task_key]
    if tonumber(state[tostring(idx)] or 0) == 1 then
        _back(play)
        _close_map(dtm)
        return
    end
    state[tostring(idx)] = 1
    _save_data(play, T_data)
    Player.rwjl(play, _config.details[idx].reward or {}, "天命试炼", 1)
    Player.sendmsgEx(play, string.format("你完成了|【%s】#218|试炼#57", _config.details[idx].name or "天命试炼"))
    _back(play)
    _close_map(dtm)
    _refresh_panel(play, 3, idx)
end

local function _fail_trial(play, dtm, msg)
    if msg and msg ~= "" then
        Player.sendmsgEx(play, msg)
    end
    _back(play)
    _close_map(dtm)
    _refresh_panel(play, 4, 0)
end

local function _resolve_run_play(play, dtm)
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
    local no_player = false
    if pc == "0" or pc == 0 then
        no_player = true
    elseif type(pc) == "table" and next(pc) == nil then
        no_player = true
    end
    return run_play, no_player
end

local function _get_player_in_trial_map(dtm)
    if not dtm or dtm == "" then
        return nil
    end
    local players = getobjectinmap(dtm, 0, 0, 999, 1)
    if type(players) ~= "table" then
        return nil
    end
    for _, player in pairs(players) do
        return player
    end
    return nil
end

local function _has_player_in_trial_map(dtm)
    return _get_player_in_trial_map(dtm) ~= nil
end

local function _tick_pet_trial(play, dtm, cfg, st)
    local boss = _find_mon_by_name(dtm, cfg.boss or "≮火烧连营·天命策尊≯")
    if not boss then
        if not st.spawn_verified and os.time() < (tonumber(st.spawn_grace_until or 0) or 0) then
            return
        end
        if tonumber(st.pet_damage_done or 0) >= 1 then
            _finish_trial(play, 1, dtm)
        else
            _fail_trial(play, dtm, "请依靠灵兽击败BOSS#57")
        end
        return
    end
    st.spawn_verified = true

    local curhp = tonumber(getbaseinfo(boss, 9) or 0) or 0
    local maxhp = tonumber(getbaseinfo(boss, 10) or 0) or 0
    if not st.expect_hp or st.expect_hp <= 0 then
        st.expect_hp = curhp
    end
    if curhp < st.expect_hp then
        local heal = st.expect_hp - curhp
        if heal > 0 then
            humanhp(boss, "+", heal, 5, 0, play)
        end
        curhp = st.expect_hp
    end

    if not _has_pet_ready(play) then
        st.expect_hp = curhp
        if os.time() - (tonumber(st.last_hint_time or 0) or 0) >= (tonumber(cfg.pet_hint_sec or 5) or 5) then
            st.last_hint_time = os.time()
            Player.sendmsgEx(play, "请先出战灵兽，只有灵兽攻击才能对BOSS造成伤害#57")
        end
        return
    end

    if os.time() >= (tonumber(st.next_pet_tick or 0) or 0) then
        local hurt = math.floor(maxhp * ((tonumber(cfg.pet_hurt_pct or 4) or 4) / 100))
        if hurt < 1 then
            hurt = 1
        end
        if hurt > curhp then
            hurt = curhp
        end
        humanhp(boss, "-", hurt, 110, 0, play, 1)
        st.pet_damage_done = 1
        st.expect_hp = curhp - hurt
        st.next_pet_tick = os.time() + (tonumber(cfg.pet_tick_sec or 1) or 1)
        if os.time() - (tonumber(st.last_pet_msg or 0) or 0) >= 5 then
            st.last_pet_msg = os.time()
            Player.sendmsgEx(play, "灵兽已命中BOSS，伤害生效#57")
        end
    end
end

local function _tick_linggen_trial(play, dtm, cfg)
    local total = _count_mon_by_name(dtm, cfg.mob or "暗影打手")
    total = total + _count_mon_by_name(dtm, cfg.elite or "暗影打手·精英")
    total = total + _count_mon_by_name(dtm, cfg.boss or "王婆")
    if total > 0 then
        local st = _state_get(dtm)
        st.spawn_verified = true
    end
    if total <= 0 then
        local st = _state_get(dtm)
        if not st.spawn_verified and os.time() < (tonumber(st.spawn_grace_until or 0) or 0) then
            return
        end
        if not st.spawn_verified then
            _fail_trial(play, dtm, "试炼怪物生成失败，请稍后重新挑战#57")
            return
        end
        _finish_trial(play, 2, dtm)
    end
end

local function _tick_realm_trial(play, dtm, cfg, st)
    if (tonumber(st.success or 0) or 0) >= (tonumber(cfg.need_success or 3) or 3) then
        _finish_trial(play, 3, dtm)
        return
    end

    local now = os.time()
    local remain = (tonumber(st.next_lightning_at or 0) or 0) - now
    if remain > 0 and remain ~= tonumber(st.last_notice or -1) then
        st.last_notice = remain
        Player.sendmsgEx(play, string.format("下次雷劫将在%d秒后到来#57", remain))
    end

    if remain > 0 then
        return
    end

    st.last_notice = -1
    st.next_lightning_at = now + (tonumber(cfg.lightning_sec or 5) or 5)
    local protect_end = tonumber(st.dujie_end or 0) or 0
    if protect_end <= 0 then
        protect_end = tonumber(getplaydef(play, _dujie_end_var) or 0) or 0
    end
    playeffect(play, tonumber(cfg.lightning_effect or 60463) or 60463, 0, 0, 1, 0, 0)
    if protect_end >= now then
        st.dujie_end = 0
        setplaydef(play, _dujie_end_var, 0)
        st.success = (tonumber(st.success or 0) or 0) + 1
        Player.sendmsgEx(play, string.format("成功抵挡第%d次雷劫#57", st.success))
        if st.success >= (tonumber(cfg.need_success or 3) or 3) then
            _finish_trial(play, 3, dtm)
        end
        return
    end

    _fail_trial(play, dtm, "你被天道雷劫击中，挑战失败#57")
end

local function _tick_xianfa_trial(play, dtm, cfg, st)
    local now = os.time()
    if (tonumber(st.score or 0) or 0) >= (tonumber(cfg.score_target or 10) or 10) then
        _finish_trial(play, 4, dtm)
        return
    end

    if now > (tonumber(st.round_end or 0) or 0) then
        if (tonumber(st.round or 0) or 0) >= (tonumber(cfg.total_round or 3) or 3) then
            _fail_trial(play, dtm, "规定时间内积分不足，试炼失败#57")
            return
        end
        _start_xianfa_round(play, dtm, cfg, st)
    end

    if now - (tonumber(st.last_score_tick or 0) or 0) < (tonumber(cfg.score_tick_sec or 1) or 1) then
        return
    end
    st.last_score_tick = now

    local px = tonumber(getbaseinfo(play, 4) or 0) or 0
    local py = tonumber(getbaseinfo(play, 5) or 0) or 0
    local dx = math.abs(px - (tonumber(st.safe_x or 0) or 0))
    local dy = math.abs(py - (tonumber(st.safe_y or 0) or 0))
    if math.max(dx, dy) <= (tonumber(cfg.safe_radius or 2) or 2) and math.random(1, 100) <= 30 then
        st.score = (tonumber(st.score or 0) or 0) + 1
        Player.sendmsgEx(play, string.format("天书仙法积分+1 ( %d/%d )#57", st.score, tonumber(cfg.score_target or 10) or 10))
        if st.score >= (tonumber(cfg.score_target or 10) or 10) then
            _finish_trial(play, 4, dtm)
        end
    else
        addhpper(play, "-", 3)
    end
end

function npc.main(play, npcid)
    sendluamsg(play, 100, npcid, 0, 0, tbl2json(_build_panel_data(play)))
end

function npc.link(play, npcid, p2, p3, msgData)
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local __guardAction = Guard.normalizeAction(play, npcid, p2)
    if __guardAction == nil then
        return
    end
    p2 = __guardAction
    local __guardAllowedActions = Guard.newActionSet({1, 2})
    if not Guard.ensureActionAllowed(play, npcid, p2, __guardAllowedActions) then
        return
    end

    local json_data = json2tbl(msgData) or {}
    local T_data = _get_data(play)
    _dbg("link", "player=" .. tostring(getbaseinfo(play, 1) or ""), "p2=" .. tostring(p2), "idx=" .. tostring(json_data.idx), "map=" .. tostring(getbaseinfo(play, 3) or ""))
    if p2 == 1 then
        local idx = tonumber(json_data.idx)
        if not idx or not (_config.details and _config.details[idx]) then
            Player.sendmsgEx(play, "参数错误#57")
            return
        end
        if tonumber((T_data[_pre_key] or {})[tostring(idx)] or 0) ~= 1 then
            _dbg("link_reject_pre", "idx=" .. tostring(idx), "pre=" .. tostring((T_data[_pre_key] or {})[tostring(idx)] or 0))
            Player.sendmsgEx(play, "你未激活对应命盘，无法进入该试炼#57")
            return
        end
        if tonumber((T_data[_task_key] or {})[tostring(idx)] or 0) == 1 then
            _dbg("link_reject_done", "idx=" .. tostring(idx))
            Player.sendmsgEx(play, "该试炼已通关，无法重复挑战#57")
            return
        end
        local run_map = _get_active_trial_map(play)
        if run_map ~= "" then
            if getbaseinfo(play, 3) == run_map then
                Player.sendmsgEx(play, "你当前已经在天命试炼副本中#57")
            else
                Player.sendmsgEx(play, "你已有进行中的天命试炼，请先完成或离开当前试炼#57")
            end
            return
        end
        local cost = (_config.details[idx] and _config.details[idx].cost) or {}
        if not Guard.ensureCost(play, cost) then
            _dbg("link_reject_cost", "idx=" .. tostring(idx))
            return
        end
        Guard.consumeCost(play, cost, ",天命试炼")
        _enter_trial(play, idx)
    elseif p2 == 2 then
        local dtm = _get_current_trial_map(play)
        if dtm == "" or getbaseinfo(play, 3) ~= dtm then
            Player.sendmsgEx(play, "你当前不在天命试炼副本中#57")
            return
        end
        Player.sendmsgEx(play, "你已离开当前试炼，本次挑战失败#57")
        _back(play)
        _close_map(dtm)
        _refresh_panel(play, 2, 0)
    end
end

function npc.use_dujie_dan(play, item)
    local run_map = _get_current_trial_map(play)
    local run_idx = _get_run_idx(play, run_map, _state_get(run_map))
    if run_idx ~= 3 or run_map == "" or getbaseinfo(play, 3) ~= run_map then
        Player.sendmsgEx(play, "【天道·渡劫丹】只能在境界试炼中使用#57")
        return false
    end
    local cfg = _trial_cfg(3)
    local keep_sec = tonumber(cfg.dan_keep_sec or 3) or 3
    local end_time = os.time() + keep_sec
    setplaydef(play, _dujie_end_var, end_time)
    local st = _state_get(run_map)
    st.dujie_end = end_time
    for i = 1, 50 do
        mapeffect(run_map.."lei"..os.time(), run_map, 33 + math.random(-30, 30), 37 + math.random(-30, 30), 56, 1, 0)
    end
    Player.sendmsgEx(play, string.format("你服用了【%s】, %d秒内可免疫1次雷劫#57", cfg.dan_item or "天道·渡劫丹", keep_sec))
end

function npc_76_dsq(xt, play, dtm, data)
    local st = _state_get(dtm)
    local run_play, no_player = _resolve_run_play(play, dtm)
    _dbg("tick_begin", "xt=" .. tostring(xt), "play=" .. tostring(play), "dtm=" .. tostring(dtm), "run_play=" .. tostring(run_play), "no_player=" .. tostring(no_player), "map=" .. tostring(getbaseinfo(run_play, 3) or ""))
    if no_player then
        -- 镜像地图刚创建/刚切图时玩家列表可能短暂为空，不能立即销毁副本。
        local now = os.time()
        local created_at = tonumber(st.created_at or now) or now
        local fallback_play = _get_player_in_trial_map(dtm)
        if fallback_play then
            run_play = fallback_play
            st.last_player_seen = now
            no_player = false
            _dbg("tick_player_fallback", "dtm=" .. tostring(dtm))
        elseif now - created_at < 8 then
            _dbg("tick_grace", "dtm=" .. tostring(dtm), "age=" .. tostring(now - created_at))
            return
        elseif tonumber(st.last_player_seen or 0) > 0 and now - tonumber(st.last_player_seen) < 3 then
            return
        end
    end
    if no_player then
        _dbg("tick_close_no_player", "dtm=" .. tostring(dtm))
        if tostring(getplaydef(run_play, _run_map_var) or "") == dtm then
            _clear_run(run_play)
        end
        _close_map(dtm)
        return
    end

    local run_map = _get_current_trial_map(run_play)
    if run_map ~= dtm then
        _dbg("tick_close_run_map_mismatch", "dtm=" .. tostring(dtm), "run_map=" .. tostring(run_map or ""))
        _close_map(dtm)
        return
    end

    local idx = _get_run_idx(run_play, dtm, st)
    _dbg("tick_state", "dtm=" .. tostring(dtm), "idx=" .. tostring(idx), "run_map=" .. tostring(run_map or ""))
    if idx < 1 or idx > 4 then
        _dbg("tick_close_bad_idx", "dtm=" .. tostring(dtm), "idx=" .. tostring(idx))
        _close_map(dtm)
        return
    end

    local cfg = _trial_cfg(idx)
    st.idx = idx

    if idx == 1 then
        _tick_pet_trial(run_play, dtm, cfg, st)
    elseif idx == 2 then
        _tick_linggen_trial(run_play, dtm, cfg)
    elseif idx == 3 then
        _tick_realm_trial(run_play, dtm, cfg, st)
    elseif idx == 4 then
        _tick_xianfa_trial(run_play, dtm, cfg, st)
    end
end

function npc_76_safe_fx(xt, dtm, data)
    if not dtm or dtm == "" or not checkmirrormap(dtm) then
        if dtm and dtm ~= "" then
            setenvirofftimer(dtm, _safe_effect_timer_id)
        end
        return
    end
    local st = _state_get(dtm)
    local idx = tonumber(st.idx or _idx_from_map(dtm) or 0) or 0
    if idx ~= 4 then
        setenvirofftimer(dtm, _safe_effect_timer_id)
        return
    end
    _draw_xianfa_safe_effect(dtm, _trial_cfg(idx), st)
end

function npc_76_timeout(play)
    local dtm = _get_current_trial_map(play)
    if dtm == "" then
        return
    end
    if getbaseinfo(play, 3) == dtm then
        Player.sendmsgEx(play, "试炼时间结束，本次挑战失败#57")
        _back(play)
    else
        _clear_run(play)
    end
    _close_map(dtm)
    _refresh_panel(play, 5, 0)
end

local function _on_kill_mon_danjie(play, mob)
    if not play or not mob or not _config then
        return
    end
    local cur_map = getbaseinfo(play, 3)
    if not cur_map or not daluditu or tonumber(daluditu[cur_map] or 0) ~= 5 then
        return
    end
    local drop_cfg = _config.dujie_drop or {}
    local need_charge = tonumber(drop_cfg.need_charge or 100) or 100
    local charge = tonumber(getplaydef(play, VarCfg["U_真实充值"]) or 0) or 0
    if charge <= need_charge then
        return
    end
    local drop_item = drop_cfg.item or "天道·渡劫丹"
    local drop_rate = tonumber(drop_cfg.rate or 5000) or 5000
    if drop_item ~= "" and drop_rate > 0 and math.random(drop_rate) == 1 then
        shaguai.temp_drop(play, mob, drop_item)
        Player.sendmsgEx(play, "打怪掉落【" .. drop_item .. "】#57")
    end
end
npc.onKillMonDanjie = _on_kill_mon_danjie

return npc
