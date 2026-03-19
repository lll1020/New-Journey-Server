npc = {}

-- 火烧赤壁
-- 1) 仅夜晚可提交道具进入副本
-- 2) 副本内持续火焰攻击特效与灼烧伤害
-- 3) BOSS血量降至50%时触发一次全屏烈火攻击

local _cfg_key = "npc_717"
local _config = Guard.getConfig(_cfg_key)
local _task_cfg = (_config and _config.task_cfg) or {}

local _back_pos_var = "S$npc717_back"
local _run_map_var = "S$npc717_map"
local _run_boss_state_var = "U$npc717_boss_state" -- 0=无, 1=主BOSS存活, 2=主BOSS已击杀
local _run_half_fire_var = "U$npc717_half_fire"   -- 0=未触发, 1=已触发50%全屏烈火
local _run_spawn_ok_var = "U$npc717_spawn_ok"     -- 0=未成功刷出主BOSS, 1=已成功刷出主BOSS

-- 717副本运行态（按镜像地图dtm存储，避免计时器回调玩家句柄差异）
local _run_state = {}

-- 获取运行态，不存在则初始化
local function _state_get(dtm)
    local st = _run_state[dtm]
    if not st then
        st = {boss_state = 0, spawn_ok = 0, half_fire = 0}
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

-- 夜晚判定：默认 18:00~次日06:00
local function _is_night_open()
    local hour = tonumber(os.date("%H")) or 12
    local start_h = tonumber(_task_cfg.night_start or 18) or 18
    local end_h = tonumber(_task_cfg.night_end or 6) or 6

    if start_h == end_h then
        return true
    end

    if start_h < end_h then
        return hour >= start_h and hour < end_h
    end

    return hour >= start_h or hour < end_h
end

-- 副本配置读取（默认值均可在 teshudata.npc_717.task_cfg 覆盖）
local function _fb_cfg()
    local cfg = {}
    cfg.base_map = _task_cfg.fb_map or _task_cfg.map or "赤壁"
    cfg.fb_time = tonumber(_task_cfg.fb_time or 300) or 300
    cfg.enter_pos = _task_cfg.enter_pos or {29, 27}
    cfg.boss = _task_cfg.boss or "请配置717任务BOSS名"
    cfg.boss_pos = _task_cfg.boss_pos or {32, 36}
    cfg.fire_effect_id = tonumber(_task_cfg.fire_effect_id or 4011) or 4011
    cfg.fire_tick_hurt_pct = tonumber(_task_cfg.fire_tick_hurt_pct or 2) or 2
    cfg.fire_burst_hurt_pct = tonumber(_task_cfg.fire_burst_hurt_pct or 20) or 20
    cfg.half_fire_hp_pct = tonumber(_task_cfg.half_fire_hp_pct or 50) or 50
    return cfg
end

-- 统计地图内指定怪物数量（仅统计存活怪）
local function _count_mon_by_name(dtm, name)
    if not name or name == "" then
        return 0
    end
    local list = getobjectinmap(dtm, 0, 0, 999, 2)
    local cnt = 0
    if list then
        for _, v in ipairs(list) do
            if getbaseinfo(v,1) == name then
                local hp = tonumber(getbaseinfo(v, 9) or 0) or 0
                if hp > 0 then
                    cnt = cnt + 1
                end
            end
        end
    end
    return cnt
end

-- 获取地图内指定名称怪物对象（仅返回存活）
local function _find_mon_by_name(dtm, name)
    if not name or name == "" then
        return nil
    end
    local list = getobjectinmap(dtm, 0, 0, 999, 2)
    if list then
        for _, v in ipairs(list) do
            if getbaseinfo(v,1) == name then
                local hp = tonumber(getbaseinfo(v, 9) or 0) or 0
                if hp > 0 then
                    return v
                end
            end
        end
    end
    return nil
end

-- 对副本内玩家执行火焰攻击（特效+扣血）
local function _fire_attack_map(play, dtm, effect_id, hurt_pct)
    local players = getobjectinmap(dtm, 0, 0, 999, 1)
    if not players then
        return
    end

    for _, v in ipairs(players) do
        playeffect(v, effect_id, 25, -50, 1, 0, 0)

        local maxhp = tonumber(getbaseinfo(v, 10) or 0) or 0
        local hurt = math.floor(maxhp * (hurt_pct / 100))
        if hurt < 1 then
            hurt = 1
        end
        humanhp(v, "-", hurt, 112, 0, play)
    end
end

-- 保存进入副本前坐标
function npc_717_savepos(play)
    local map = getbaseinfo(play,3)
    local x = getbaseinfo(play,4)
    local y = getbaseinfo(play,5)
    setplaydef(play, _back_pos_var, map..","..x..","..y)
end

-- 回到进入副本前坐标
function npc_717_back(play)
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
    setplaydef(play, _run_boss_state_var, 0)
    setplaydef(play, _run_half_fire_var, 0)
    setplaydef(play, _run_spawn_ok_var, 0)
    _state_clear(dtm)
end

-- 副本通关处理：完成任务并发奖励（仅一次）
local function _on_pass(play)
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local state = tonumber(jq_data[_cfg_key] or 0) or 0
    if state >= 2 then
        return
    end

    Guard.clearTaskTemp(jq_data, _cfg_key)
    jq_data[_cfg_key] = 2
    Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)

    sendluamsg(play,101,1005,0,0,"rwwc")
    Player.sendmsgEx(play, "【"..(_config.name or "任务").."】完成#57")
    Guard.giveTaskReward(play, _config, (_config.name or "剧情任务").."奖励")
end

-- 进入副本（提交成功后调用）
function npc_717_enter(play)
    npc_717_savepos(play)

    local cfg = _fb_cfg()
    local dtm = getbaseinfo(play,1) .. "_npc717"
    if checkmirrormap(dtm) then
        delmirrormap(dtm)
    end

    _state_clear(dtm)
    addmirrormap(cfg.base_map, dtm, _config.name or "副本", cfg.fb_time, "xtc")
    mapmove(play, dtm, tonumber(cfg.enter_pos[1] or 29) or 29, tonumber(cfg.enter_pos[2] or 27) or 27, 2)

    genmonex(dtm, tonumber(cfg.boss_pos[1] or 32) or 32, tonumber(cfg.boss_pos[2] or 36) or 36, cfg.boss, 1, 1, 0, 54, "", 0)

    setplaydef(play, _run_map_var, dtm)
    setplaydef(play, _run_half_fire_var, 0)

    local st = _state_get(dtm)
    if _count_mon_by_name(dtm, cfg.boss) > 0 then
        st.boss_state = 1
        st.spawn_ok = 1
        st.half_fire = 0
        setplaydef(play, _run_boss_state_var, 1)
        setplaydef(play, _run_half_fire_var, 0)
        setplaydef(play, _run_spawn_ok_var, 1)
    else
        st.boss_state = 0
        st.spawn_ok = 0
        st.half_fire = 0
        setplaydef(play, _run_boss_state_var, 0)
        setplaydef(play, _run_half_fire_var, 0)
        setplaydef(play, _run_spawn_ok_var, 0)
        Player.sendmsgEx(play, "主BOSS生成失败，请检查 task_cfg.boss 配置#57")
    end

    startautoattack(play)
    setenvirontimer(dtm, 1, 1, "@npc_717_dsq,"..play..","..dtm)
    senddelaymsg(play, "距离副本结束剩余%s", cfg.fb_time, 250, 1, "@npc_717_timeout")
    Player.sendmsgEx(play, "已进入赤壁火海副本，BOSS会持续释放火焰攻击#57")
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
            npc_717_back(play)
            Player.sendmsgEx(play, "已离开副本#57")
            return
        end
        Player.sendmsgEx(play, "你当前不在火烧赤壁副本#57")
        return
    end

    local dtm = getplaydef(play, _run_map_var)
    if dtm and dtm ~= "" and getbaseinfo(play,3) == dtm then
        Player.sendmsgEx(play, "你已在火烧赤壁副本中#57")
        return
    end

    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local state = tonumber(jq_data[_cfg_key] or 0) or 0
    if state >= 2 then
        Player.sendmsgEx(play, "【"..(_config.name or "任务").."】已完成，不能再次提交进入副本#57")
        return
    end

    if not _is_night_open() then
        Player.sendmsgEx(play, "该副本仅夜晚可进入（默认18:00-06:00）#57")
        return
    end

    if state < 1 then
        jq_data[_cfg_key] = 1
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        Player.sendmsgEx(play, "领取【"..(_config.name or "任务").."】")
        sendluamsg(play,101,1005,0,0,"rwjs")
    end

    local costs = _task_cfg.submit or {}
    if not Guard.ensureCost(play, costs) then
        return
    end
    Guard.consumeCost(play, costs, ","..(_config.name or "剧情任务").."进入副本")

    npc_717_enter(play)
end

-- 副本计时器：持续火焰攻击 + 半血全屏烈火 + 通关检测
function npc_717_dsq(xt,play,dtm,data)
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
            setplaydef(run_play, _run_boss_state_var, 0)
            setplaydef(run_play, _run_half_fire_var, 0)
            setplaydef(run_play, _run_spawn_ok_var, 0)
        end
        _state_clear(dtm)
        return
    end

    local cfg = _fb_cfg()
    local st = _state_get(dtm)

    local pd_boss_state = tonumber(getplaydef(run_play, _run_boss_state_var) or 0) or 0
    local pd_half_fire = tonumber(getplaydef(run_play, _run_half_fire_var) or 0) or 0
    local pd_spawn_ok = tonumber(getplaydef(run_play, _run_spawn_ok_var) or 0) or 0
    if tonumber(st.boss_state or 0) <= 0 and pd_boss_state > 0 then
        st.boss_state = pd_boss_state
    end
    if tonumber(st.spawn_ok or 0) <= 0 and pd_spawn_ok > 0 then
        st.spawn_ok = pd_spawn_ok
    end
    if tonumber(st.half_fire or 0) <= 0 and pd_half_fire > 0 then
        st.half_fire = pd_half_fire
    end

    local boss = _find_mon_by_name(dtm, cfg.boss)

    if boss then
        if tonumber(st.boss_state or 0) ~= 1 then
            st.boss_state = 1
            setplaydef(run_play, _run_boss_state_var, 1)
        end
        if tonumber(st.spawn_ok or 0) ~= 1 then
            st.spawn_ok = 1
            setplaydef(run_play, _run_spawn_ok_var, 1)
        end

        -- 常驻火焰攻击：BOSS持续释放火焰伤害
        _fire_attack_map(run_play, dtm, cfg.fire_effect_id, cfg.fire_tick_hurt_pct)

        local curhp = tonumber(getbaseinfo(boss, 9) or 0) or 0
        local maxhp = tonumber(getbaseinfo(boss, 10) or 0) or 0
        if maxhp > 0 and (curhp / maxhp) <= (cfg.half_fire_hp_pct / 100) and tonumber(st.half_fire or 0) ~= 1 then
            st.half_fire = 1
            setplaydef(run_play, _run_half_fire_var, 1)
            Player.sendmsgEx(run_play, "BOSS血量降至50%，全屏烈火爆发！#57")
            -- 半血阶段全屏烈火（一次性高额伤害）
            _fire_attack_map(run_play, dtm, cfg.fire_effect_id, cfg.fire_burst_hurt_pct)
        end
        return
    end

    if tonumber(st.spawn_ok or 0) == 1 and tonumber(st.boss_state or 0) >= 1 then
        st.boss_state = 2
        setplaydef(run_play, _run_boss_state_var, 2)
        Player.sendmsgEx(run_play, "副本通关#57")
        _on_pass(run_play)

        if getbaseinfo(run_play,3) == dtm then
            npc_717_back(run_play)
        else
            setplaydef(run_play, _run_map_var, "")
            setplaydef(run_play, _run_boss_state_var, 0)
            setplaydef(run_play, _run_half_fire_var, 0)
            setplaydef(run_play, _run_spawn_ok_var, 0)
            _state_clear(dtm)
        end

        if checkmirrormap(dtm) then
            setenvirofftimer(dtm, 1)
            delmirrormap(dtm)
        end
    end
end

-- 副本超时：强制离开并清理镜像
function npc_717_timeout(play)
    local dtm = getplaydef(play, _run_map_var)
    if not dtm or dtm == "" then
        return
    end

    if getbaseinfo(play,3) == dtm then
        Player.sendmsgEx(play, "副本时间结束#57")
        npc_717_back(play)
    else
        setplaydef(play, _run_map_var, "")
        setplaydef(play, _run_boss_state_var, 0)
        setplaydef(play, _run_half_fire_var, 0)
        setplaydef(play, _run_spawn_ok_var, 0)
        _state_clear(dtm)
    end

    if checkmirrormap(dtm) then
        setenvirofftimer(dtm, 1)
        delmirrormap(dtm)
    end
end

return npc
