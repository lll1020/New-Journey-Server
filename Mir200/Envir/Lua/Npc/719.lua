npc = {}

-- 血溅狮子楼
-- 1) 本图打怪掉落【净化水晶】，提交后进入副本
-- 2) 副本限时20分钟，失败可重来，退出可重来
-- 3) 三阶段战斗 + 半血狂暴引爆机制

local _cfg_key = "npc_719"
local _config = Guard.getConfig(_cfg_key)
local _task_cfg = (_config and _config.task_cfg) or {}

local _back_pos_var = "S$npc719_back"
local _run_map_var = "S$npc719_map"
local _run_stage_var = "U$npc719_stage"                -- 0=未开始,1=第一层,2=第二层,3=第三层,4=通关
local _run_stage_start_var = "N$npc719_stage_start"    -- 当前阶段开始时间
local _run_s1_extra_var = "U$npc719_s1_extra"          -- 第一层超时补刷精英标记
local _run_rage_var = "U$npc719_rage"                  -- BOSS狂暴标记
local _run_explode_var = "U$npc719_explode"            -- 随从引爆标记

-- 719副本运行态（按镜像地图dtm存储，避免计时器回调玩家句柄差异）
local _run_state = {}

-- 获取运行态，不存在则初始化
local function _state_get(dtm)
    local st = _run_state[dtm]
    if not st then
        st = {stage = 0, stage_start = 0, s1_extra = 0, rage = 0, explode = 0}
        _run_state[dtm] = st
    end
    return st
end

-- 清理运行态
local function _state_clear(dtm)
    if dtm and dtm ~= "" then
        _run_state[dtm] = nil
    end
end
-- 读取副本配置（默认值可在 teshudata.npc_719.task_cfg 覆盖）
local function _fb_cfg()
    local cfg = {}
    cfg.base_map = _task_cfg.fb_map or _task_cfg.map or "狮子楼"
    cfg.limit_time_sec = tonumber(_task_cfg.limit_time_sec or 1200) or 1200
    cfg.enter_pos = _task_cfg.enter_pos or {29, 27}

    cfg.stage1_mob = _task_cfg.stage1_mob or "暗影打手"
    cfg.stage1_count = tonumber(_task_cfg.stage1_count or 20) or 20
    cfg.stage1_timeout = tonumber(_task_cfg.stage1_timeout or 300) or 300
    cfg.stage1_elite_mob = _task_cfg.stage1_elite_mob or "暗影打手·精英"
    cfg.stage1_elite_count = tonumber(_task_cfg.stage1_elite_count or 2) or 2

    cfg.stage2_boss = _task_cfg.stage2_boss or "王婆"
    cfg.stage2_boss_count = tonumber(_task_cfg.stage2_boss_count or 1) or 1
    cfg.stage2_mob = _task_cfg.stage2_mob or "暗影侍女"
    cfg.stage2_mob_count = tonumber(_task_cfg.stage2_mob_count or 2) or 2

    cfg.stage3_boss = _task_cfg.stage3_boss or "邪恶西门庆"
    cfg.stage3_boss_count = tonumber(_task_cfg.stage3_boss_count or 1) or 1
    cfg.stage3_mob = _task_cfg.stage3_mob or "暗影侍女"
    cfg.stage3_mob_count = tonumber(_task_cfg.stage3_mob_count or 4) or 4

    cfg.boss_pos = _task_cfg.boss_pos or {32, 36}
    cfg.mob_center = _task_cfg.mob_center or {32, 36}
    cfg.scan_range = tonumber(_task_cfg.scan_range or 40) or 40

    cfg.rage_hp_pct = tonumber(_task_cfg.rage_hp_pct or 50) or 50
    cfg.explode_hurt_pct = tonumber(_task_cfg.explode_hurt_pct or 12) or 12
    cfg.explode_effect_id = tonumber(_task_cfg.explode_effect_id or 4011) or 4011
    return cfg
end

-- 保存进入副本前坐标
local function _save_pos(play)
    local map = getbaseinfo(play,3)
    local x = getbaseinfo(play,4)
    local y = getbaseinfo(play,5)
    setplaydef(play, _back_pos_var, map..","..x..","..y)
end

-- 回到进入副本前坐标，并清理运行态
local function _back(play)
    local dtm = getplaydef(play, _run_map_var)
    local back = getplaydef(play, _back_pos_var)
    if back and back ~= "" then
        local parts = split(back, ",")
        local map = parts[1]
        local x = tonumber(parts[2]) or 0
        local y = tonumber(parts[3]) or 0
        if map and map ~= "" and x > 0 and y > 0 then
            mapmove(play, map, x, y, 2)
        end
    end

    setplaydef(play, _back_pos_var, "")
    setplaydef(play, _run_map_var, "")
    setplaydef(play, _run_stage_var, 0)
    setplaydef(play, _run_stage_start_var, 0)
    setplaydef(play, _run_s1_extra_var, 0)
    setplaydef(play, _run_rage_var, 0)
    setplaydef(play, _run_explode_var, 0)
    _state_clear(dtm)
end

-- 统计地图内指定怪物数量
local function _count_mon_by_name(dtm, name, cx, cy, range)
    if not name or name == "" then
        return 0
    end
    local r = tonumber(range or 0) or 0
    local list
    if cx and cy and r > 0 then
        list = getobjectinmap(dtm, tonumber(cx) or 0, tonumber(cy) or 0, r, 2)
    else
        list = getobjectinmap(dtm, 0, 0, 999, 2)
    end
    local cnt = 0
    if list then
        for _, v in ipairs(list) do
            local mon_name = getbaseinfo(v,1)
            local hp = tonumber(getbaseinfo(v, 9) or 0) or 0
            if mon_name == name and hp > 0 then
                cnt = cnt + 1
            end
        end
    end
    return cnt
end

-- 获取地图内指定名称怪物对象（用于读取BOSS血量）
local function _find_mon_by_name(dtm, name, cx, cy, range)
    if not name or name == "" then
        return nil
    end
    local r = tonumber(range or 0) or 0
    local list
    if cx and cy and r > 0 then
        list = getobjectinmap(dtm, tonumber(cx) or 0, tonumber(cy) or 0, r, 2)
    else
        list = getobjectinmap(dtm, 0, 0, 999, 2)
    end
    if list then
        for _, v in ipairs(list) do
            local mon_name = getbaseinfo(v,1)
            local hp = tonumber(getbaseinfo(v, 9) or 0) or 0
            if mon_name == name and hp > 0 then
                return v
            end
        end
    end
    return nil
end

-- 批量刷怪
local function _spawn_many(dtm, name, count, cx, cy)
    if not name or name == "" then
        return
    end
    local n = tonumber(count or 0) or 0
    if n < 1 then
        return
    end
    local x0 = tonumber(cx or 32) or 32
    local y0 = tonumber(cy or 36) or 36

    for i = 1, n do
        local dx = ((i - 1) % 3) - 1
        local dy = math.floor((i - 1) / 3)
        genmonex(dtm, x0 + dx, y0 + dy, name, 1, 1, 0, 54, "", 0)
    end
end

-- 第一层：暗影打手
local function _start_stage1(play, dtm, cfg)
    local c = cfg.mob_center
    _spawn_many(dtm, cfg.stage1_mob, cfg.stage1_count, c[1], c[2])

    local st = _state_get(dtm)
    st.stage = 1
    st.stage_start = os.time()
    st.s1_extra = 0

    setplaydef(play, _run_stage_var, 1)
    setplaydef(play, _run_stage_start_var, st.stage_start)
    setplaydef(play, _run_s1_extra_var, 0)

    local s1_left = _count_mon_by_name(dtm, cfg.stage1_mob, c[1], c[2], cfg.scan_range)
    local s1_elite_left = _count_mon_by_name(dtm, cfg.stage1_elite_mob, c[1], c[2], cfg.scan_range)

    Player.sendmsgEx(play, "第一层：清理所有暗影打手#57")
end

-- 第二层：王婆 + 暗影侍女
local function _start_stage2(play, dtm, cfg)
    local c = cfg.mob_center
    _spawn_many(dtm, cfg.stage2_boss, cfg.stage2_boss_count, c[1], c[2])
    _spawn_many(dtm, cfg.stage2_mob, cfg.stage2_mob_count, c[1] + 2, c[2])

    local st = _state_get(dtm)
    st.stage = 2
    st.stage_start = os.time()

    setplaydef(play, _run_stage_var, 2)
    setplaydef(play, _run_stage_start_var, st.stage_start)
    Player.sendmsgEx(play, "第二层：击杀王婆与暗影侍女#57")
end

-- 第三层：邪恶西门庆 + 4暗影侍女
local function _start_stage3(play, dtm, cfg)
    local bp = cfg.boss_pos
    _spawn_many(dtm, cfg.stage3_boss, cfg.stage3_boss_count, bp[1], bp[2])
    _spawn_many(dtm, cfg.stage3_mob, cfg.stage3_mob_count, bp[1] + 2, bp[2])

    local st = _state_get(dtm)
    st.stage = 3
    st.stage_start = os.time()
    st.rage = 0
    st.explode = 0

    setplaydef(play, _run_stage_var, 3)
    setplaydef(play, _run_stage_start_var, st.stage_start)
    setplaydef(play, _run_rage_var, 0)
    setplaydef(play, _run_explode_var, 0)
    Player.sendmsgEx(play, "第三层：击败邪恶西门庆#57")
end

-- 随从引爆：对副本内玩家造成高额伤害，并清掉随从
local function _explode_minions(play, dtm, minion_name, effect_id, hurt_pct)
    local players = getobjectinmap(dtm, 0, 0, 999, 1)
    local mobs = getobjectinmap(dtm, 0, 0, 999, 2)
    if not mobs then
        return
    end

    local boom_cnt = 0
    for _, m in ipairs(mobs) do
        if getbaseinfo(m,1) == minion_name then
            boom_cnt = boom_cnt + 1
            humanhp(m, "-", 999999999, 107, 0, play)
        end
    end

    if boom_cnt < 1 or not players then
        return
    end

    local total_pct = hurt_pct * boom_cnt
    for _, v in ipairs(players) do
        playeffect(v, effect_id, 25, -50, 1, 0, 0)
        local maxhp = tonumber(getbaseinfo(v, 10) or 0) or 0
        local hurt = math.floor(maxhp * (total_pct / 100))
        if hurt < 1 then
            hurt = 1
        end
        humanhp(v, "-", hurt, 110, 0, play)
    end

    Player.sendmsgEx(play, "随从自爆，引发大范围伤害！#57")
end

-- 通关：任务完成并发奖励
local function _finish_task(play)
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local state = tonumber(jq_data[_cfg_key] or 0) or 0
    if state >= 2 then
        return
    end

    Guard.clearTaskTemp(jq_data, _cfg_key)
    jq_data[_cfg_key] = 2
    Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)

    shaguai.jian(play, 719)

    sendluamsg(play,101,1005,0,0,"rwwc")
    Player.sendmsgEx(play, "|【"..(_config.name or "任务").."】#249|完成#57")
    if npcid then Guard.closeNpc(play, npcid) end
    Guard.giveTaskReward(play, _config, (_config.name or "剧情任务").."奖励")
end

-- 进入副本
local function _enter_fb(play)
    local cfg = _fb_cfg()
    local dtm = getbaseinfo(play,1) .. "_npc719"

    if checkmirrormap(dtm) then
        delmirrormap(dtm)
    end

    _save_pos(play)
    _state_clear(dtm)
    addmirrormap(cfg.base_map, dtm, _config.name or "副本", cfg.limit_time_sec, "xtc")
    mapmove(play, dtm, tonumber(cfg.enter_pos[1] or 29) or 29, tonumber(cfg.enter_pos[2] or 27) or 27, 2)

    setplaydef(play, _run_map_var, dtm)
    _start_stage1(play, dtm, cfg)

    local stage_set_player = tonumber(getplaydef(play, _run_stage_var) or 0) or 0
    local stage_set_state = tonumber((_state_get(dtm).stage or 0)) or 0

    startautoattack(play)
    setenvirontimer(dtm, 1, 1, "@npc_719_dsq,"..play..","..dtm)
    senddelaymsg(play, "距离副本结束剩余%s", cfg.limit_time_sec, 250, 1, "@npc_719_timeout")
    Player.sendmsgEx(play, "血溅狮子楼开启：限时20分钟#57")
end

function npc.main(play,npcid)
    if not _config then
        return
    end
    local data = {}
    data["T_dljq"] = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    sendluamsg(play,100,npcid,0,0,tbl2json(data))
end

function npc.link(play,npcid,ew,aid)
    if not _config then
        return
    end
    if not Guard.ensurePlayer(play, npcid) then
        return
    end

    local __guardAction = Guard.normalizeAction(play, npcid, ew)
    if __guardAction == nil then
        return
    end
    ew = __guardAction
    local __guardAllowedActions = Guard.newActionSet({1,2})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end

    if ew == 2 then
        local dtm = getplaydef(play, _run_map_var)
        if dtm and dtm ~= "" and getbaseinfo(play,3) == dtm then
            Player.sendmsgEx(play, "你已退出副本，本次挑战失败，可重新提交进入#57")
            _back(play)
            if checkmirrormap(dtm) then
                setenvirofftimer(dtm, 1)
                delmirrormap(dtm)
            end
            return
        end
        Player.sendmsgEx(play, "你当前不在血溅狮子楼副本#57")
        return
    end

    local dtm = getplaydef(play, _run_map_var)
    if dtm and dtm ~= "" and getbaseinfo(play,3) == dtm then
        Player.sendmsgEx(play, "你已在血溅狮子楼副本中#57")
        return
    end

    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local state = tonumber(jq_data[_cfg_key] or 0) or 0
    if state >= 2 then
        shaguai.jian(play, 719)
        Player.sendmsgEx(play, "|【"..(_config.name or "任务").."】#249|已完成，不能再次提交进入副本#57")
        return
    end

    if state < 1 then
        jq_data[_cfg_key] = 1
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        Player.sendmsgEx(play, "领取|【"..(_config.name or "任务").."】#249|")
        if npcid then Guard.closeNpcAndAuto(play, npcid) end
        sendluamsg(play,101,1005,0,0,"rwjs")
    end

    -- 领取任务后注册打怪掉落监听
    shaguai.jia(play, 719)

    local costs = _task_cfg.submit or {{"净化水晶",1}}
    if not Guard.ensureCost(play, costs) then
        return
    end
    Guard.consumeCost(play, costs, ","..(_config.name or "剧情任务").."进入副本")

    _enter_fb(play)
end

-- 副本计时器：阶段推进 + 狂暴机制
function npc_719_dsq(xt,play,dtm,data)
    local pc = getplaycount(dtm,false,true)
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
local st = _state_get(dtm)
    local stage_now = tonumber(st.stage or 0) or 0
    local pd_stage = tonumber(getplaydef(run_play, _run_stage_var) or 0) or 0
    if stage_now <= 0 and pd_stage > 0 then
        st.stage = pd_stage
        st.stage_start = tonumber(getplaydef(run_play, _run_stage_start_var) or 0) or tonumber(st.stage_start or 0) or 0
        st.s1_extra = tonumber(getplaydef(run_play, _run_s1_extra_var) or 0) or tonumber(st.s1_extra or 0) or 0
        st.rage = tonumber(getplaydef(run_play, _run_rage_var) or 0) or tonumber(st.rage or 0) or 0
        st.explode = tonumber(getplaydef(run_play, _run_explode_var) or 0) or tonumber(st.explode or 0) or 0
        stage_now = st.stage
    end

    local no_player = false
    if pc == "0" or pc == 0 then
        no_player = true
    elseif type(pc) == "table" and next(pc) == nil then
        no_player = true
    end

    if no_player then
        setenvirofftimer(dtm, 1)
        if checkmirrormap(dtm) then
            delmirrormap(dtm)
        end
        if getplaydef(run_play, _run_map_var) == dtm then
            setplaydef(run_play, _run_map_var, "")
            setplaydef(run_play, _run_stage_var, 0)
            setplaydef(run_play, _run_stage_start_var, 0)
            setplaydef(run_play, _run_s1_extra_var, 0)
            setplaydef(run_play, _run_rage_var, 0)
            setplaydef(run_play, _run_explode_var, 0)
        end
        _state_clear(dtm)
        return
    end

    local cfg = _fb_cfg()
    local stage = tonumber(st.stage or 0) or 0
    local now = os.time()

    -- 容错：若阶段丢失但第一层怪仍在，则自动恢复阶段1
    if stage <= 0 then
        local s1_left_fix = _count_mon_by_name(dtm, cfg.stage1_mob, cfg.mob_center[1], cfg.mob_center[2], cfg.scan_range)
        if s1_left_fix > 0 then
            stage = 1
            st.stage = 1
            if tonumber(st.stage_start or 0) <= 0 then
                st.stage_start = now
            end
            setplaydef(run_play, _run_stage_var, 1)
            setplaydef(run_play, _run_stage_start_var, tonumber(st.stage_start or 0) or now)
            setplaydef(run_play, _run_s1_extra_var, tonumber(st.s1_extra or 0) or 0)
        else
            _start_stage1(run_play, dtm, cfg)
            st = _state_get(dtm)
            stage = tonumber(st.stage or 0) or 0
        end
    end

    if stage == 1 then
        local s1_left = _count_mon_by_name(dtm, cfg.stage1_mob, cfg.mob_center[1], cfg.mob_center[2], cfg.scan_range)
        local s1_elite_left = _count_mon_by_name(dtm, cfg.stage1_elite_mob, cfg.mob_center[1], cfg.mob_center[2], cfg.scan_range)
        local st_time = tonumber(st.stage_start or 0) or 0
        local s1_extra = tonumber(st.s1_extra or 0) or 0
        local elapsed = (st_time > 0) and (now - st_time) or 0

        if st_time > 0 and (now - st_time) >= cfg.stage1_timeout and s1_extra ~= 1 then
            local c = cfg.mob_center
            _spawn_many(dtm, cfg.stage1_elite_mob, cfg.stage1_elite_count, c[1] + 1, c[2])
            st.s1_extra = 1
            setplaydef(run_play, _run_s1_extra_var, 1)
            Player.sendmsgEx(run_play, "第一层超时，刷新2只精英怪！#57")
            s1_elite_left = _count_mon_by_name(dtm, cfg.stage1_elite_mob, cfg.mob_center[1], cfg.mob_center[2], cfg.scan_range)
        end

        if s1_left < 1 and ((tonumber(st.s1_extra or 0) or 0) == 0 or s1_elite_left < 1) then
            _start_stage2(run_play, dtm, cfg)
        end
        return
    end

    if stage == 2 then
        local b_left = _count_mon_by_name(dtm, cfg.stage2_boss, cfg.mob_center[1], cfg.mob_center[2], cfg.scan_range)
        local m_left = _count_mon_by_name(dtm, cfg.stage2_mob, cfg.mob_center[1], cfg.mob_center[2], cfg.scan_range)

        if b_left < 1 and m_left < 1 then
            _start_stage3(run_play, dtm, cfg)
        end
        return
    end

    if stage == 3 then
        local boss = _find_mon_by_name(dtm, cfg.stage3_boss, cfg.boss_pos[1], cfg.boss_pos[2], cfg.scan_range)
        local maid_left = _count_mon_by_name(dtm, cfg.stage3_mob, cfg.boss_pos[1], cfg.boss_pos[2], cfg.scan_range)

        if boss then
            local curhp = tonumber(getbaseinfo(boss, 9) or 0) or 0
            local maxhp = tonumber(getbaseinfo(boss, 10) or 0) or 0

            if maxhp > 0 and (curhp / maxhp) <= (cfg.rage_hp_pct / 100) and tonumber(st.rage or 0) ~= 1 then
                st.rage = 1
                setplaydef(run_play, _run_rage_var, 1)
                Player.sendmsgEx(run_play, "邪恶西门庆进入狂暴模式！#57")

                if maid_left > 0 and tonumber(st.explode or 0) ~= 1 then
                    st.explode = 1
                    setplaydef(run_play, _run_explode_var, 1)
                    _explode_minions(run_play, dtm, cfg.stage3_mob, cfg.explode_effect_id, cfg.explode_hurt_pct)
                end
            end
            return
        end

        st.stage = 4
        setplaydef(run_play, _run_stage_var, 4)
        _finish_task(run_play)

        if getbaseinfo(run_play,3) == dtm then
            _back(run_play)
        else
            setplaydef(run_play, _run_map_var, "")
            setplaydef(run_play, _run_stage_var, 0)
            setplaydef(run_play, _run_stage_start_var, 0)
            setplaydef(run_play, _run_s1_extra_var, 0)
            setplaydef(run_play, _run_rage_var, 0)
            setplaydef(run_play, _run_explode_var, 0)
            _state_clear(dtm)
        end

        if checkmirrormap(dtm) then
            setenvirofftimer(dtm, 1)
            delmirrormap(dtm)
        end
    end
end

-- 副本超时：判定失败，强制退出
function npc_719_timeout(play)
    local dtm = getplaydef(play, _run_map_var)
    if not dtm or dtm == "" then
        return
    end

    if getbaseinfo(play,3) == dtm then
        Player.sendmsgEx(play, "副本挑战失败（超时），可重新提交进入#57")
        _back(play)
    else
        setplaydef(play, _run_map_var, "")
        setplaydef(play, _run_stage_var, 0)
        setplaydef(play, _run_stage_start_var, 0)
        setplaydef(play, _run_s1_extra_var, 0)
        setplaydef(play, _run_rage_var, 0)
        setplaydef(play, _run_explode_var, 0)
        _state_clear(dtm)
    end

    if checkmirrormap(dtm) then
        setenvirofftimer(dtm, 1)
        delmirrormap(dtm)
    end
end

return npc



