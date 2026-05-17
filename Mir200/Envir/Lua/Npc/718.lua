npc = {}

-- 景阳冈打虎
-- 1) 打怪掉落【武松的酒】
-- 2) 提交3碗酒后进入副本
-- 3) 入本后先喝酒，再击杀吊睛白额虎完成任务

local _cfg_key = "npc_718"
local _config = Guard.getConfig(_cfg_key)
local _task_cfg = (_config and _config.task_cfg) or {}

local _back_pos_var = "S$npc718_back"
local _run_map_var = "S$npc718_map"
local _run_boss_state_var = "U$npc718_boss_state" -- 0=无, 1=主BOSS存活, 2=主BOSS已击杀
local _run_spawn_ok_var = "U$npc718_spawn_ok"      -- 0=未成功刷出主BOSS, 1=已成功刷出主BOSS

-- 718副本运行态（按镜像地图dtm存储，避免计时器回调玩家句柄差异）
local _run_state = {}

-- 获取运行态，不存在则初始化
local function _state_get(dtm)
    local st = _run_state[dtm]
    if not st then
        st = {boss_state = 0, spawn_ok = 0}
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

local function _fb_cfg()
    local cfg = {}
    cfg.base_map = _task_cfg.fb_map or _task_cfg.map or "景阳冈"
    cfg.fb_time = tonumber(_task_cfg.fb_time or 300) or 300
    cfg.enter_pos = _task_cfg.enter_pos or {29, 27}
    cfg.boss = _task_cfg.boss or "吊睛白额虎"
    cfg.boss_pos = _task_cfg.boss_pos or {32, 36}
    return cfg
end

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

local function _save_pos(play)
    local map = getbaseinfo(play,3)
    local x = getbaseinfo(play,4)
    local y = getbaseinfo(play,5)
    setplaydef(play, _back_pos_var, map..","..x..","..y)
end

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
    setplaydef(play, _run_boss_state_var, 0)
    setplaydef(play, _run_spawn_ok_var, 0)
    _state_clear(dtm)
end

local function _spawn_boss(dtm)
    local cfg = _fb_cfg()
    genmonex(dtm, tonumber(cfg.boss_pos[1] or 32) or 32, tonumber(cfg.boss_pos[2] or 36) or 36, cfg.boss, 1, 1, 0, 54, "", 0)
end

local function _on_pass(play)
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local state = tonumber(jq_data[_cfg_key] or 0) or 0
    if state >= 2 then
        return
    end

    Guard.clearTaskTemp(jq_data, _cfg_key)
    jq_data[_cfg_key] = 2
    Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)

    shaguai.jian(play, 718)

    sendluamsg(play,101,1005,0,0,"rwwc")
    Player.sendmsgEx(play, "|【"..(_config.name or "任务").."】#218|完成#57")
    if npcid then Guard.closeNpc(play, npcid) end
    Guard.giveTaskReward(play, _config, (_config.name or "剧情任务").."奖励")
end

function npc_718_enter(play)
    local cfg = _fb_cfg()
    local dtm = getbaseinfo(play,1) .. "_npc718"

    if checkmirrormap(dtm) then
        delmirrormap(dtm)
    end

    _save_pos(play)
    _state_clear(dtm)
    addmirrormap(cfg.base_map, dtm, _config.name or "副本", cfg.fb_time, "xtc")
    mapmove(play, dtm, tonumber(cfg.enter_pos[1] or 29) or 29, tonumber(cfg.enter_pos[2] or 27) or 27, 2)

    Player.sendmsgEx(play, "武松连喝三碗酒，酒劲上头，虎胆大增！#57")
    playeffect(play, 4011, 25, -50, 1, 0, 0)

    _spawn_boss(dtm)
    setplaydef(play, _run_map_var, dtm)

    local st = _state_get(dtm)
    if _count_mon_by_name(dtm, cfg.boss) > 0 then
        st.boss_state = 1
        st.spawn_ok = 1
        setplaydef(play, _run_boss_state_var, 1)
        setplaydef(play, _run_spawn_ok_var, 1)
    else
        st.boss_state = 0
        st.spawn_ok = 0
        setplaydef(play, _run_boss_state_var, 0)
        setplaydef(play, _run_spawn_ok_var, 0)
        Player.sendmsgEx(play, "主BOSS生成失败，请检查 task_cfg.boss 配置#57")
    end

    startautoattack(play)
    setenvirontimer(dtm, 1, 1, "@npc_718_dsq,"..play..","..dtm)
    senddelaymsg(play, "距离副本结束剩余%s", cfg.fb_time, 250, 1, "@npc_718_timeout")
    Player.sendmsgEx(play, "击杀#57|【"..cfg.boss.."】#218|即可完成任务#57")
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
            _back(play)
            Player.sendmsgEx(play, "已离开副本#57")
            return
        end
        Player.sendmsgEx(play, "你当前不在景阳冈打虎副本#57")
        return
    end

    local dtm = getplaydef(play, _run_map_var)
    if dtm and dtm ~= "" and getbaseinfo(play,3) == dtm then
        Player.sendmsgEx(play, "你已在景阳冈打虎副本中#57")
        return
    end

    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local state = tonumber(jq_data[_cfg_key] or 0) or 0
    if state >= 2 then
        shaguai.jian(play, 718)
        Player.sendmsgEx(play, "|【"..(_config.name or "任务").."】#218|已完成，不能再次提交进入副本#57")
        return
    end

    if state < 1 then
        jq_data[_cfg_key] = 1
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        Player.sendmsgEx(play, "领取|【"..(_config.name or "任务").."】#218|")
        if npcid then Guard.closeNpcAndAuto(play, npcid) end
        sendluamsg(play,101,1005,0,0,"rwjs")
    end

    shaguai.jia(play, 718)

    local costs = _task_cfg.submit or {{"武松的酒",3}}
    if not Guard.ensureCost(play, costs) then
        return
    end
    Guard.consumeCost(play, costs, ","..(_config.name or "剧情任务").."进入副本")

    npc_718_enter(play)
end

-- 副本计时器：检测主BOSS是否击杀
function npc_718_dsq(xt,play,dtm,data)
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
            setplaydef(run_play, _run_spawn_ok_var, 0)
        end
        _state_clear(dtm)
        return
    end

    local cfg = _fb_cfg()
    local st = _state_get(dtm)

    local pd_boss_state = tonumber(getplaydef(run_play, _run_boss_state_var) or 0) or 0
    local pd_spawn_ok = tonumber(getplaydef(run_play, _run_spawn_ok_var) or 0) or 0
    if tonumber(st.boss_state or 0) <= 0 and pd_boss_state > 0 then
        st.boss_state = pd_boss_state
    end
    if tonumber(st.spawn_ok or 0) <= 0 and pd_spawn_ok > 0 then
        st.spawn_ok = pd_spawn_ok
    end

    local boss_left = _count_mon_by_name(dtm, cfg.boss)

    -- 容错：状态丢失但主BOSS仍存活时，自动恢复为进行中
    if tonumber(st.boss_state or 0) < 1 and tonumber(st.spawn_ok or 0) == 1 and boss_left > 0 then
        st.boss_state = 1
        setplaydef(run_play, _run_boss_state_var, 1)
    end

    if tonumber(st.spawn_ok or 0) == 1 and boss_left < 1 then
        st.boss_state = 2
        setplaydef(run_play, _run_boss_state_var, 2)
        Player.sendmsgEx(run_play, "副本通关#57")
        _on_pass(run_play)

        if getbaseinfo(run_play,3) == dtm then
            _back(run_play)
        else
            setplaydef(run_play, _run_map_var, "")
            setplaydef(run_play, _run_boss_state_var, 0)
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
function npc_718_timeout(play)
    local dtm = getplaydef(play, _run_map_var)
    if not dtm or dtm == "" then
        return
    end

    if getbaseinfo(play,3) == dtm then
        Player.sendmsgEx(play, "副本时间结束#57")
        _back(play)
    else
        setplaydef(play, _run_map_var, "")
        setplaydef(play, _run_boss_state_var, 0)
        setplaydef(play, _run_spawn_ok_var, 0)
        _state_clear(dtm)
    end

    if checkmirrormap(dtm) then
        setenvirofftimer(dtm, 1)
        delmirrormap(dtm)
    end
end

return npc
