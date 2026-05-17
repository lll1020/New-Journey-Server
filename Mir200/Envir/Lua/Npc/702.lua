npc = {}

-- 倩女幽魂（特殊逻辑）
-- 1) 提交道具进入副本（可重复进入）
-- 2) 副本中再次提交道具，召唤隐藏BOSS
-- 3) 击杀主BOSS即视为通关，发放 ch[1]，并完成任务
-- 4) 击杀隐藏BOSS发放 ch[2]

local _cfg_key = "npc_702"
local _config = Guard.getConfig(_cfg_key)
local _task_cfg = (_config and _config.task_cfg) or {}

-- 持久字段：故意不走 npc_702_ 前缀，绕过 Guard.clearTaskTemp(jq_data, "npc_702")
local _persist_prefix = "npc702_"
local _pass_done_key = _persist_prefix .. "pass_done"
local _hidden_kill_key = _persist_prefix .. "hidden_kill"
local _hidden_title_key = _persist_prefix .. "hidden_title"
local _reward_done_key = _persist_prefix .. "reward_done"

-- 运行态字段（玩家变量）
local _back_pos_var = "S$npc702_back"
local _run_map_var = "S$npc702_map"
local _run_main_state_var = "U$npc702_main_state"         -- 0=无, 1=主BOSS存活, 2=主BOSS已击杀
local _run_hide_state_var = "U$npc702_hide_state"         -- 0=未召唤, 1=隐藏BOSS存活, 2=隐藏BOSS已击杀
local _run_main_spawn_ok_var = "U$npc702_main_spawn_ok"   -- 0=主BOSS未成功刷出, 1=已成功刷出
local _run_hide_spawn_ok_var = "U$npc702_hide_spawn_ok"   -- 0=隐藏BOSS未成功刷出, 1=已成功刷出

-- 702副本运行态（按镜像地图dtm存储，避免计时器回调玩家句柄差异）
local _run_state = {}

-- 获取运行态，不存在则初始化
local function _state_get(dtm)
    local st = _run_state[dtm]
    if not st then
        st = {main_state = 0, hide_state = 0, main_spawn_ok = 0, hide_spawn_ok = 0}
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

-- 读取称号（支持 ch=string 或 ch={a,b}）
local function _get_title(idx)
    local ch = _config and _config.ch
    if type(ch) == "table" then
        return ch[idx]
    end
    if idx == 1 and type(ch) == "string" then
        return ch
    end
    return nil
end

-- 仅发放物品奖励，不处理称号（避免一次性发出 ch[1]/ch[2]）
local function _give_item_reward_only(play)
    local reward = _config.jl or _config.rwjl or _task_cfg.jl or _task_cfg.rwjl or _task_cfg.reward or _task_cfg.rewards
    if type(reward) ~= "table" or #reward == 0 then
        return
    end

    local reason = (_config.name or "剧情任务") .. "奖励"
    if type(reward[1]) == "table" and type(reward[1][1]) == "string" then
        Player.rwjl(play, reward, reason, 1)
        return
    end

    if type(reward[1]) == "table" and type(reward[1][1]) == "table" then
        for _, pack in ipairs(reward) do
            if type(pack) == "table" and #pack > 0 then
                Player.rwjl(play, pack, reason, 1)
            end
        end
    end
end

-- 保存进入副本前坐标
function npc_702_savepos(play)
    local map = getbaseinfo(play,3)
    local x = getbaseinfo(play,4)
    local y = getbaseinfo(play,5)
    setplaydef(play, _back_pos_var, map..","..x..","..y)
end

-- 回到进入副本前坐标
function npc_702_back(play)
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
    setplaydef(play, _run_main_state_var, 0)
    setplaydef(play, _run_hide_state_var, 0)
    setplaydef(play, _run_main_spawn_ok_var, 0)
    setplaydef(play, _run_hide_spawn_ok_var, 0)
    _state_clear(dtm)
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

-- 读取副本配置
local function _fb_cfg()
    local cfg = {}
    cfg.base_map = _task_cfg.fb_map or _task_cfg.map or "兰若寺"
    cfg.fb_time = tonumber(_task_cfg.fb_time or 300) or 300
    cfg.enter_pos = _task_cfg.enter_pos or {29, 27}
    cfg.main_pos = _task_cfg.main_pos or {32, 36}
    cfg.hide_pos = _task_cfg.hide_pos or {35, 36}
    cfg.main_boss = _task_cfg.main_boss or _task_cfg.boss or "树妖姥姥"
    cfg.hidden_boss = _task_cfg.hidden_boss or "黑山老妖"
    return cfg
end

-- 生成主BOSS
local function _spawn_main_boss(dtm)
    local cfg = _fb_cfg()
    genmonex(dtm, tonumber(cfg.main_pos[1] or 32) or 32, tonumber(cfg.main_pos[2] or 36) or 36, cfg.main_boss, 1, 1, 0, 54, "", 0)
end

-- 生成隐藏BOSS
local function _spawn_hidden_boss(dtm)
    local cfg = _fb_cfg()
    genmonex(dtm, tonumber(cfg.hide_pos[1] or 35) or 35, tonumber(cfg.hide_pos[2] or 36) or 36, cfg.hidden_boss, 1, 1, 0, 54, "", 0)
end

-- 进入副本（可重复）
function npc_702_enter(play)
    npc_702_savepos(play)

    local cfg = _fb_cfg()
    local dtm = getbaseinfo(play,1) .. "_npc702"
    if checkmirrormap(dtm) then
        delmirrormap(dtm)
    end

    _state_clear(dtm)
    addmirrormap(cfg.base_map, dtm, _config.name or "副本", cfg.fb_time, "xtc")
    mapmove(play, dtm, tonumber(cfg.enter_pos[1] or 29) or 29, tonumber(cfg.enter_pos[2] or 27) or 27, 2)

    _spawn_main_boss(dtm)
    setplaydef(play, _run_map_var, dtm)

    local st = _state_get(dtm)
    if _count_mon_by_name(dtm, cfg.main_boss) > 0 then
        st.main_state = 1
        st.main_spawn_ok = 1
        st.hide_state = 0
        st.hide_spawn_ok = 0
        setplaydef(play, _run_main_state_var, 1)
        setplaydef(play, _run_hide_state_var, 0)
        setplaydef(play, _run_main_spawn_ok_var, 1)
        setplaydef(play, _run_hide_spawn_ok_var, 0)
    else
        st.main_state = 0
        st.main_spawn_ok = 0
        st.hide_state = 0
        st.hide_spawn_ok = 0
        setplaydef(play, _run_main_state_var, 0)
        setplaydef(play, _run_hide_state_var, 0)
        setplaydef(play, _run_main_spawn_ok_var, 0)
        setplaydef(play, _run_hide_spawn_ok_var, 0)
        Player.sendmsgEx(play, "主BOSS生成失败，请检查 task_cfg.main_boss 配置#57")
    end

    startautoattack(play)
    setenvirontimer(dtm, 1, 1, "@npc_702_dsq,"..play..","..dtm)
    senddelaymsg(play, "距离副本结束剩余%s", cfg.fb_time, 250, 1, "@npc_702_timeout")
    Player.sendmsgEx(play, "已进入副本，击杀主BOSS可通关；副本内可再次提交召唤隐藏BOSS#57")
end

-- 主BOSS击杀后的通关处理：完成任务 + 发称号ch[1]
local function _on_main_boss_killed(play)
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)

    local title1 = _get_title(1)
    if title1 and title1 ~= "" and tonumber(jq_data[_pass_done_key] or 0) ~= 1 then
        Player.title_give(play, title1)
    end
    jq_data[_pass_done_key] = 1

    if (tonumber(jq_data[_cfg_key] or 0) or 0) < 2 then
        jq_data[_cfg_key] = 2
        sendluamsg(play,101,1005,0,0,"rwwc")
        Player.sendmsgEx(play, "|【"..(_config.name or "任务").."】#218|完成#57")
        if npcid then Guard.closeNpc(play, npcid) end
    end

    if tonumber(jq_data[_reward_done_key] or 0) ~= 1 then
        _give_item_reward_only(play)
        jq_data[_reward_done_key] = 1
    end

    Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
end

-- 隐藏BOSS击杀：发称号ch[2]
local function _on_hidden_boss_killed(play)
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    jq_data[_hidden_kill_key] = (tonumber(jq_data[_hidden_kill_key] or 0) or 0) + 1

    local title2 = _get_title(2)
    if title2 and title2 ~= "" and tonumber(jq_data[_hidden_title_key] or 0) ~= 1 then
        Player.title_give(play, title2)
        jq_data[_hidden_title_key] = 1
        Player.sendmsgEx(play, "击杀|【隐藏BOSS】#218|成功，获得称号：|【"..title2.."】#218|")
    else
        Player.sendmsgEx(play, "击杀|【隐藏BOSS】#218|成功")
    end

    Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
end

-- 召唤隐藏BOSS前置校验（返回副本镜像地图名）
local function _check_hidden_summon_ready(play)
    local dtm = getplaydef(play, _run_map_var)
    if not dtm or dtm == "" or getbaseinfo(play,3) ~= dtm then
        Player.sendmsgEx(play, "请先进入倩女幽魂副本#57")
        return nil
    end

    local st = _state_get(dtm)

    local main_state = tonumber(getplaydef(play, _run_main_state_var) or 0) or 0
    if main_state <= 0 and tonumber(st.main_state or 0) > 0 then
        main_state = tonumber(st.main_state or 0) or 0
        setplaydef(play, _run_main_state_var, main_state)
    end

    if main_state ~= 2 then
        local cfg = _fb_cfg()
        local main_spawn_ok = tonumber(getplaydef(play, _run_main_spawn_ok_var) or 0) or 0
        if main_spawn_ok <= 0 and tonumber(st.main_spawn_ok or 0) > 0 then
            main_spawn_ok = tonumber(st.main_spawn_ok or 0) or 0
            setplaydef(play, _run_main_spawn_ok_var, main_spawn_ok)
        end

        -- 容错：主BOSS实际已死但状态未推进时，立即推进并放行召唤
        if main_spawn_ok == 1 and _count_mon_by_name(dtm, cfg.main_boss) < 1 then
            st.main_state = 2
            setplaydef(play, _run_main_state_var, 2)
            _on_main_boss_killed(play)
            main_state = 2
        end
    end

    if main_state ~= 2 then
        Player.sendmsgEx(play, "请先击杀副本主BOSS，再召唤隐藏BOSS#57")
        return nil
    end

    local hide_state = tonumber(getplaydef(play, _run_hide_state_var) or 0) or 0
    if hide_state <= 0 and tonumber(st.hide_state or 0) > 0 then
        hide_state = tonumber(st.hide_state or 0) or 0
        setplaydef(play, _run_hide_state_var, hide_state)
    end

    if hide_state == 1 then
        local cfg = _fb_cfg()
        -- 容错：显示已召唤但隐藏BOSS实际已死，自动推进到2
        if _count_mon_by_name(dtm, cfg.hidden_boss) < 1 then
            st.hide_state = 2
            setplaydef(play, _run_hide_state_var, 2)
        else
            Player.sendmsgEx(play, "隐藏BOSS已召唤，请先击杀#57")
            return nil
        end
    end

    return dtm
end

-- 副本内再次提交道具：召唤隐藏BOSS（NPC提交）
local function _try_summon_hidden(play)
    local dtm = _check_hidden_summon_ready(play)
    if not dtm then
        return false
    end

    local costs = _task_cfg.submit or {}
    if not Guard.ensureCost(play, costs) then
        return false
    end
    Guard.consumeCost(play, costs, ","..(_config.name or "剧情任务").."召唤隐藏BOSS")

    local cfg = _fb_cfg()
    _spawn_hidden_boss(dtm)

    local st = _state_get(dtm)
    if _count_mon_by_name(dtm, cfg.hidden_boss) > 0 then
        st.hide_state = 1
        st.hide_spawn_ok = 1
        setplaydef(play, _run_hide_state_var, 1)
        setplaydef(play, _run_hide_spawn_ok_var, 1)
        Player.sendmsgEx(play, "你使用道具唤醒了隐藏BOSS#57")
        return true
    else
        st.hide_state = 0
        st.hide_spawn_ok = 0
        setplaydef(play, _run_hide_state_var, 0)
        setplaydef(play, _run_hide_spawn_ok_var, 0)
        Player.sendmsgEx(play, "隐藏BOSS生成失败，请检查 task_cfg.hidden_boss 配置#57")
        return false
    end
end

-- 供 useitme.lua 调用：副本内双击道具召唤隐藏BOSS（仅消耗当前点击的1个道具）
function npc_702_use_item(play, item)
    local dtm = _check_hidden_summon_ready(play)
    if not dtm then
        return false
    end

    if not item then
        Player.sendmsgEx(play, "道具数据异常#57")
        return false
    end

    local mk = getiteminfo(play, item, 1)
    if not mk or mk == 0 then
        Player.sendmsgEx(play, "道具不存在或已失效#57")
        return false
    end

    delitembymakeindex(play, mk, 1)

    local cfg = _fb_cfg()
    _spawn_hidden_boss(dtm)

    local st = _state_get(dtm)
    if _count_mon_by_name(dtm, cfg.hidden_boss) > 0 then
        st.hide_state = 1
        st.hide_spawn_ok = 1
        setplaydef(play, _run_hide_state_var, 1)
        setplaydef(play, _run_hide_spawn_ok_var, 1)
        Player.sendmsgEx(play, "你使用道具唤醒了隐藏BOSS#57")
        return true
    else
        st.hide_state = 0
        st.hide_spawn_ok = 0
        setplaydef(play, _run_hide_state_var, 0)
        setplaydef(play, _run_hide_spawn_ok_var, 0)
        Player.sendmsgEx(play, "隐藏BOSS生成失败，请检查 task_cfg.hidden_boss 配置#57")
        return false
    end
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

    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)

    if ew == 2 then
        local dtm = getplaydef(play, _run_map_var)
        if dtm and dtm ~= "" and getbaseinfo(play,3) == dtm then
            npc_702_back(play)
            Player.sendmsgEx(play, "已离开副本#57")
            return
        end
        Player.sendmsgEx(play, "你当前不在倩女幽魂副本#57")
        return
    end

    -- ew=1：
    -- 1) 在副本外：提交道具进入副本（可重复）
    -- 2) 在副本内：再次提交道具召唤隐藏BOSS
    local dtm = getplaydef(play, _run_map_var)
    if dtm and dtm ~= "" and getbaseinfo(play,3) == dtm then
        _try_summon_hidden(play)
        return
    end

    if (tonumber(jq_data[_cfg_key] or 0) or 0) < 1 then
        jq_data[_cfg_key] = 1
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        Player.sendmsgEx(play, "领取|【"..(_config.name or "任务").."】#218|")
        if npcid then Guard.closeNpcAndAuto(play, npcid) end
        sendluamsg(play,101,1005,0,0,"rwjs")
    end

    local costs = _task_cfg.submit or {}
    if not Guard.ensureCost(play, costs) then
        return
    end
    Guard.consumeCost(play, costs, ","..(_config.name or "剧情任务").."进入副本")

    npc_702_enter(play)
end

-- 副本计时器：检测主BOSS/隐藏BOSS击杀
function npc_702_dsq(xt,play,dtm,data)
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
            setplaydef(run_play, _run_main_state_var, 0)
            setplaydef(run_play, _run_hide_state_var, 0)
            setplaydef(run_play, _run_main_spawn_ok_var, 0)
            setplaydef(run_play, _run_hide_spawn_ok_var, 0)
        end
        _state_clear(dtm)
        return
    end

    local cfg = _fb_cfg()
    local st = _state_get(dtm)

    local pd_main_state = tonumber(getplaydef(run_play, _run_main_state_var) or 0) or 0
    local pd_hide_state = tonumber(getplaydef(run_play, _run_hide_state_var) or 0) or 0
    local pd_main_spawn_ok = tonumber(getplaydef(run_play, _run_main_spawn_ok_var) or 0) or 0
    local pd_hide_spawn_ok = tonumber(getplaydef(run_play, _run_hide_spawn_ok_var) or 0) or 0

    if tonumber(st.main_state or 0) <= 0 and pd_main_state > 0 then
        st.main_state = pd_main_state
    end
    if tonumber(st.hide_state or 0) <= 0 and pd_hide_state > 0 then
        st.hide_state = pd_hide_state
    end
    if tonumber(st.main_spawn_ok or 0) <= 0 and pd_main_spawn_ok > 0 then
        st.main_spawn_ok = pd_main_spawn_ok
    end
    if tonumber(st.hide_spawn_ok or 0) <= 0 and pd_hide_spawn_ok > 0 then
        st.hide_spawn_ok = pd_hide_spawn_ok
    end

    local main_left = _count_mon_by_name(dtm, cfg.main_boss)
    local hide_left = _count_mon_by_name(dtm, cfg.hidden_boss)

    -- 容错：状态丢失但主BOSS仍存活时，自动恢复为进行中
    if tonumber(st.main_state or 0) < 1 and tonumber(st.main_spawn_ok or 0) == 1 and main_left > 0 then
        st.main_state = 1
        setplaydef(run_play, _run_main_state_var, 1)
    end

    -- 主BOSS死亡判定
    if tonumber(st.main_spawn_ok or 0) == 1 and tonumber(st.main_state or 0) < 2 and main_left < 1 then
        st.main_state = 2
        setplaydef(run_play, _run_main_state_var, 2)
        Player.sendmsgEx(run_play, "主BOSS已击杀，副本通关#57")
        _on_main_boss_killed(run_play)
    end

    -- 容错：状态丢失但隐藏BOSS仍存活时，自动恢复为进行中
    if tonumber(st.hide_state or 0) < 1 and tonumber(st.hide_spawn_ok or 0) == 1 and hide_left > 0 then
        st.hide_state = 1
        setplaydef(run_play, _run_hide_state_var, 1)
    end

    -- 隐藏BOSS死亡判定
    if tonumber(st.hide_spawn_ok or 0) == 1 and tonumber(st.hide_state or 0) < 2 and hide_left < 1 then
        st.hide_state = 2
        setplaydef(run_play, _run_hide_state_var, 2)
        _on_hidden_boss_killed(run_play)
    end
end

-- 副本超时：强制离开并清理镜像
function npc_702_timeout(play)
    local dtm = getplaydef(play, _run_map_var)
    if not dtm or dtm == "" then
        return
    end

    if getbaseinfo(play,3) == dtm then
        Player.sendmsgEx(play, "副本时间结束#57")
        npc_702_back(play)
    end

    if checkmirrormap(dtm) then
        setenvirofftimer(dtm, 1)
        delmirrormap(dtm)
    end

    setplaydef(play, _run_map_var, "")
    setplaydef(play, _run_main_state_var, 0)
    setplaydef(play, _run_hide_state_var, 0)
    setplaydef(play, _run_main_spawn_ok_var, 0)
    setplaydef(play, _run_hide_spawn_ok_var, 0)
    _state_clear(dtm)
end

return npc

