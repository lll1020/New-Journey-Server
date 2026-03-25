npc = {}
local _npcid = 103
local _config = Guard.getConfig("npc_103")
local _attr_list_name = (_config and _config.attr_list_name) or "天书试炼属性"
local _back_pos_var = "S$npc103_back"
local _run_map_var = "S$npc103_map"
local _effect_prefix = "npc103_fx_"
local _boss_effect_timer_id = 2
local _submit_task_map = {[1] = 11,[2] = 13,[3] = 15,[4] = 17}
local function _finish_mainline(play, taskId)
    taskId = tonumber(taskId) or 0
    if taskId > 0 and getplaydef(play, VarCfg.U_zxrw[1]) == taskId then
        Player.zxrw_wancheng(play, taskId, "任务")
    end
end
local function _merge_attrs(dst, src)
    for _, attr in ipairs(src or {}) do
        local attrId = tonumber(attr[1])
        local attrValue = tonumber(attr[2]) or 0
        if attrId and attrValue ~= 0 then
            dst[attrId] = (dst[attrId] or 0) + attrValue
        end
    end
end
local function _is_all_submit(T_data)
    local materials = (_config and _config.materials) or {}
    if #materials < 1 then
        return false
    end
    local submit = (T_data and T_data.submit) or {}
    for _, cfg in ipairs(materials) do
        if tonumber(submit[tostring(cfg.idx or 0)] or 0) ~= 1 then
            return false
        end
    end
    return true
end
local function _get_data(play)
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_天书试炼"])
    T_data.submit = type(T_data.submit) == "table" and T_data.submit or {}
    T_data.unlock = tonumber(T_data.unlock) or 0
    T_data.finish = tonumber(T_data.finish) or 0
    for _, cfg in ipairs((_config and _config.materials) or {}) do
        local key = tostring(cfg.idx or 0)
        T_data.submit[key] = tonumber(T_data.submit[key]) or 0
    end
    if T_data.unlock ~= 1 and _is_all_submit(T_data) then
        T_data.unlock = 1
    end
    return T_data
end
local function _save_data(play, T_data)
    Player.setJsonVarByTable(play, VarCfg["T_天书试炼"], T_data or {})
end
local function _refresh_attr(play, T_data)
    local attrs = {}
    for _, cfg in ipairs((_config and _config.materials) or {}) do
        if tonumber((T_data.submit or {})[tostring(cfg.idx or 0)] or 0) == 1 then
            _merge_attrs(attrs, cfg.attr)
        end
    end
    if next(attrs) then
        addattlist(play, _attr_list_name, "=", Player.getAttrTableToStr(attrs), 1)
    else
        delattlist(play, _attr_list_name)
    end
    recalcabilitys(play)
end
local function _build_panel_data(play)
    local T_data = _get_data(play)
    local data = {
        T_data = T_data,
        unlock = T_data.unlock,
        finish = T_data.finish,
    }
    local runMap = tostring(getplaydef(play, _run_map_var) or "")
    data.in_fb = runMap ~= "" and getbaseinfo(play, 3) == runMap and 1 or 0
    return data
end
local function _refresh_panel(play, npcid, ew, aid)
    sendluamsg(play, 100, npcid or _npcid, ew or 0, aid or 0, tbl2json(_build_panel_data(play)))
end
local function _on_login(play)
    if not _config then
        return
    end
    local T_data = _get_data(play)
    _save_data(play, T_data)
    _refresh_attr(play, T_data)
end
local function _save_back(play)
    local map = getbaseinfo(play, 3)
    local x = getbaseinfo(play, 4)
    local y = getbaseinfo(play, 5)
    setplaydef(play, _back_pos_var, map..","..x..","..y)
end
local function _play_boss_effect(dtm)
    local bossPos = (_config and _config.boss_pos) or {32, 36}
    mapeffect(_effect_prefix..dtm, dtm, tonumber(bossPos[1]) or 32, tonumber(bossPos[2]) or 36, tonumber((_config and _config.boss_effect) or 16419) or 16419, 2, 0)
end
local function _stop_fb_timers(dtm)
    setenvirofftimer(dtm, 1)
    setenvirofftimer(dtm, _boss_effect_timer_id)
end
local function _clear_run(play)
    setplaydef(play, _back_pos_var, "")
    setplaydef(play, _run_map_var, "")
end
local function _back(play)
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
    _clear_run(play)
end
local function _finish(play)
    local T_data = _get_data(play)
    if T_data.finish == 1 then
        return
    end
    T_data.finish = 1
    T_data.unlock = 1
    _save_data(play, T_data)
    _refresh_attr(play, T_data)
    if _config and _config.reward and #_config.reward > 0 then
        Player.rwjl(play, _config.reward, (_config.name or "天书试炼").."奖励", 1, 0)
    end
    Player.sendmsgEx(play, "|【"..((_config and _config.name) or "天书试炼").."】#249|完成，恭喜获得|【天书】#249|#57")
    sendluamsg(play, 101, 1005, 0, 0, "rwwc")
    _finish_mainline(play, 18)
end
local function _enter_fb(play)
    local runMap = tostring(getplaydef(play, _run_map_var) or "")
    if runMap ~= "" and getbaseinfo(play, 3) == runMap then
        Player.sendmsgEx(play, "你已经在|【天书试炼】#249|副本中#57")
        return
    end
    _save_back(play)
    local dtm = tostring(getbaseinfo(play, 1) or "").."_npc103"
    if checkmirrormap(dtm) then
        delmirrormap(dtm)
    end
    addmirrormap((_config and _config.fb_map) or "mwsl", dtm, (_config and _config.name) or "天书试炼", tonumber((_config and _config.fb_time) or 300) or 300, "xtc")
    setplaydef(play, _run_map_var, dtm)
    local enterPos = (_config and _config.enter_pos) or {29, 27}
    mapmove(play, dtm, tonumber(enterPos[1]) or 29, tonumber(enterPos[2]) or 27, 2)
    local bossPos = (_config and _config.boss_pos) or {32, 36}
    genmonex(dtm, tonumber(bossPos[1]) or 32, tonumber(bossPos[2]) or 36, ((_config and _config.boss) or "★天穹裂变·雷域主★"), 1, 1, 0, 54, "", 0)
    _play_boss_effect(dtm)
    mobfireburn(play, dtm, tonumber(bossPos[1]) or 32, tonumber(bossPos[2]) or 36, tonumber((_config and _config.boss_fire) or 5) or 5, 30, 1, 1)
    startautoattack(play)
    setenvirontimer(dtm, 1, 1, "@npc_103_dsq,"..play..","..dtm)
    setenvirontimer(dtm, _boss_effect_timer_id, 10, "@npc_103_fx,"..dtm)
    senddelaymsg(play, "距离副本结束剩余%s", tonumber((_config and _config.fb_time) or 300) or 300, 250, 1, "@npc_103_timeout")
    Player.sendmsgEx(play, "已进入|【天书试炼】#249|副本，击败炫光BOSS即可获得|【天书】#249|#57")
    sendluamsg(play, 101, 9999, 0, 0, "npc_"..103)
end
function npc.main(play, npcid)
    if not _config then
        return
    end
    _refresh_panel(play, npcid, 0, 0)
end
function npc.link(play, npcid, ew, aid, data)
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
    local __guardAllowedActions = Guard.newActionSet({1,2,3,4,5})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end
    local T_data = _get_data(play)
    local aid_num = tonumber(aid or 0) or 0
    local submit_idx = nil
    local is_enter = false
    if ew == 1 and aid_num >= 1 and aid_num <= 4 then
        submit_idx = aid_num
    elseif ew == 2 and aid_num == 0 then
        is_enter = true
    elseif ew == 5 then
        is_enter = true
    elseif ew >= 1 and ew <= 4 and aid_num == 0 then
        submit_idx = ew
    end
    if submit_idx then
        local cfg = (_config.materials or {})[submit_idx]
        if not cfg then
            return
        end
        local key = tostring(cfg.idx or submit_idx)
        if tonumber(T_data.submit[key] or 0) == 1 then
            Player.sendmsgEx(play, "|【"..(cfg.name or ("材料"..submit_idx)).."】#249|已提交过#57")
            return
        end
        local missName, missNum = Player.checkItemNumByTable(play, cfg.cost or {})
        if missName then
            Player.sendmsgEx(play, string.format("你的#57|【%s】#249|不足：#57|【%d】#249|", missName, tonumber(missNum) or 0))
            return
        end
        Player.takeItemByTable(play, cfg.cost or {}, ",天书试炼提交", nil)
        T_data.submit[key] = 1
        if _is_all_submit(T_data) then
            T_data.unlock = 1
        end
        _save_data(play, T_data)
        _refresh_attr(play, T_data)
        Player.sendmsgEx(play, "成功提交|【"..(cfg.name or ("材料"..submit_idx)).."】#249|，获得属性：|【"..(cfg.attr_desc or "已生效").."】#249|")
        if T_data.unlock == 1 then
            Player.sendmsgEx(play, "四种材料已全部提交，已解锁|【天书试炼副本】#249|挑战权限#57")
        end
        _refresh_panel(play, npcid, 1, submit_idx)
        _finish_mainline(play, _submit_task_map[submit_idx])
        return
    end
    if not is_enter then
        return
    end
    if T_data.finish == 1 then
        Player.sendmsgEx(play, "|【天书试炼】#249|已完成，无法再次领取|【天书】#249|#57")
        return
    end
    if T_data.unlock ~= 1 and not _is_all_submit(T_data) then
        Player.sendmsgEx(play, "请先提交四种材料后再进入副本#57")
        return
    end
    _enter_fb(play)
    -- _refresh_panel(play, npcid, 2, 0)
end
function npc_103_dsq(xt, play, dtm, data)
    if getplaycount(dtm, false, true) == "0" then
        _stop_fb_timers(dtm)
        if checkmirrormap(dtm) then
            delmirrormap(dtm)
        end
        return
    end
    if getmoncount(dtm, -1, true) < 1 then
        _stop_fb_timers(dtm)
        if getbaseinfo(play, 3) == dtm then
            _back(play)
        else
            _clear_run(play)
        end
        _finish(play)
        if checkmirrormap(dtm) then
            delmirrormap(dtm)
        end
        _refresh_panel(play, _npcid, 3, 0)
    end
end
function npc_103_fx(xt, dtm, data)
    if not dtm or dtm == "" or not checkmirrormap(dtm) then
        if dtm and dtm ~= "" then
            setenvirofftimer(dtm, _boss_effect_timer_id)
        end
        return
    end
    _play_boss_effect(dtm)
end
function npc_103_timeout(play)
    local dtm = tostring(getplaydef(play, _run_map_var) or "")
    if dtm == "" then
        dtm = tostring(getbaseinfo(play, 1) or "").."_npc103"
    end
    if checkmirrormap(dtm) then
        _stop_fb_timers(dtm)
    end
    if getbaseinfo(play, 3) == dtm then
        if getmoncount(dtm, -1, true) < 1 then
            _finish(play)
        else
            Player.sendmsgEx(play, "副本时间结束，本次挑战失败，可重新进入#57")
        end
        _back(play)
    else
        _clear_run(play)
    end
    if checkmirrormap(dtm) then
        delmirrormap(dtm)
    end
    _refresh_panel(play, _npcid, 4, 0)
end
GameEvent.add(EventCfg.onLogin, _on_login, "天书试炼")
GameEvent.add(EventCfg.onKFLogin, _on_login, "天书试炼")
return npc