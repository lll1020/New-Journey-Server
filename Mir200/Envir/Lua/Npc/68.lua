npc = {}

local _config = Guard.getConfig("npc_68")
local _state_key = "npc_68"
local _branch_names = {
    [1] = "金灵根",
    [2] = "木灵根",
    [3] = "水灵根",
    [4] = "火灵根",
    [5] = "土灵根",
}

local eff_top = {
    [1] = 60501,
    [2] = 60502,
    [3] = 60503,
    [4] = 60500,
    [5] = 60504,
}

local function _toint(value, default)
    value = tonumber(value)
    if value == nil then
        return default or 0
    end
    return math.floor(value)
end

local function _get_story(play)
    return Player.getJsonTableByVar(play, VarCfg.T_dljq) or {}
end

local function _save_story(play, data)
    Player.setJsonVarByTable(play, VarCfg.T_dljq, data or {})
end

local function _get_trial(data)
    data[_state_key] = type(data[_state_key]) == "table" and data[_state_key] or {}
    return data[_state_key]
end

local function _get_main_branch_from_state(play)
    local var = (VarCfg and VarCfg.T_talent_tree) or "T74"
    local state = Player.getJsonTableByVar(play, var) or {}
    local nodes = type(state.nodes) == "table" and state.nodes or {}
    local id_branch = {
        metal_M1 = 1,
        wood_M1 = 2,
        water_M1 = 3,
        fire_M1 = 4,
        earth_M1 = 5,
    }
    for node_id, value in pairs(nodes) do
        if _toint(value, 0) == 1 then
            local branch = id_branch[tostring(node_id)]
            if branch then
                return branch
            end
        end
    end
    return 0
end

local function _get_main_branch(play)
    local talent = rawget(_G, "TalentTree")
    if talent and type(talent.getMainBranch) == "function" then
        local ok, branch = pcall(talent.getMainBranch, play)
        branch = _toint(branch, 0)
        if ok and branch > 0 then
            return branch
        end
    end
    return _get_main_branch_from_state(play)
end


local function _get_linggen_core_level(play)
    local talent = rawget(_G, "TalentTree")
    if talent and type(talent.getCoreLevel) == "function" then
        local ok, level = pcall(talent.getCoreLevel, play)
        if ok then
            return _toint(level, 0)
        end
    end
    local var = (VarCfg and VarCfg.T_talent_tree) or "T74"
    local state = Player.getJsonTableByVar(play, var) or {}
    return _toint(state.core_level, 0)
end
local function _clear_trial_effects(play)
    if type(clearplayeffect) ~= "function" then
        return
    end
    for _, effect_id in pairs(eff_top) do
        pcall(clearplayeffect, play, effect_id)
    end
end

local function _play_trial_effect(play, branch)
    local effect_id = eff_top[branch]
    if effect_id and type(playeffect) == "function" then
        -- times = 0 means the top effect keeps playing until it is cleared.
        pcall(playeffect, play, effect_id, 0, 0, 0, 1, 0)
    end
end

local function _normalize_trial_for_branch(play, branch, data)
    data = data or _get_story(play)
    local trial = _get_trial(data)
    local main = _toint(trial.main, 0)
    if main > 0 and main ~= branch then
        data[_state_key] = {}
        _save_story(play, data)
        return data[_state_key], data
    end
    return trial, data
end

local function _build_client_linggen_data(play, branch, trial)
    return {level = {}}
end

function Npc68RefreshMainLinggenEffect(play)
    _clear_trial_effects(play)
    local branch = _get_main_branch(play)
    if branch <= 0 then
        return false
    end
    local trial = _normalize_trial_for_branch(play, branch)
    if type(trial) == "table"
        and _toint(trial.main, 0) == branch
        and _toint(trial[tostring(branch)], 0) >= 2
    then
        _play_trial_effect(play, branch)
        return true
    end
    return false
end

function Npc68ResetMainTrial(play)
    _clear_trial_effects(play)
    local data = _get_story(play)
    data[_state_key] = {}
    _save_story(play, data)
end

local function _is_axe_need(need)
    need = tostring(need or "")
    return need == "切割之斧[lv10]" or need == "切割之斧LV10"
end

local function _has_equipped_axe_level(play, needLevel)
    local item = linkbodyitem(play, 9)
    if not item or item == "0" then
        return false
    end
    local equipLevel = _toint(Player.getEquipFieldByPos(play, 9, 1), 0)
    if equipLevel < _toint(needLevel, 10) then
        return false
    end
    local itemName = tostring(getiteminfo(play, item, 7) or "")
    if itemName == "" then
        return false
    end
    return string.find(itemName, "切割之斧", 1, true) ~= nil
end

local function _check_trial_limit(play, aid)
    local cfg = _config and _config.details and _config.details[aid]
    if not cfg then
        Player.sendmsgEx(play, "试炼配置缺失#57")
        return false
    end

    local need = cfg.itme
    if not need or need == "" then
        return true
    end
    if _is_axe_need(need) then
        if _has_equipped_axe_level(play, 10) then
            return true
        end
        Player.sendmsgEx(play, "请先穿戴|切割之斧[lv10]#218|或更高等级装备#57")
        return false
    end
    if checktitle(play, need) then
        return true
    end
    if Player.hasEquipInArtifactSlot(play, need) then
        return true
    end

    Player.sendmsgEx(play, "进入该灵根试炼需要拥有称号或神器位装备#57|" .. tostring(need) .. "#218|")
    return false
end
local function _take_trial_cost(play)
    local cost = (_config and _config.cost) or {}
    if type(cost) ~= "table" or #cost <= 0 then
        return true
    end
    local name, num = Player.checkItemNumByTable(play, cost)
    if name then
        Player.sendmsgEx(play, string.format("缺少|%s#218|数量|%d#218", name, num))
        return false
    end
    Player.takeItemByTable(play, cost, ",灵根试炼", nil)
    return true
end

local function _send_main(play, npcid)
    local branch = _get_main_branch(play)
    local trial, data = _normalize_trial_for_branch(play, branch)
    local payload = {
        T_data = _build_client_linggen_data(play, branch, trial),
        T_dljq = data,
        main_branch = branch,
    }
    sendluamsg(play, 100, npcid, 0, 0, tbl2json(payload))
end

function npc.main(play, npcid)
    _send_main(play, npcid)
end

function npc.link(play, npcid, ew, aid)
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local action = Guard.normalizeAction(play, npcid, ew)
    if action == nil then
        return
    end
    ew = action
    if not Guard.ensureActionAllowed(play, npcid, ew, Guard.newActionSet({1, 2})) then
        return
    end

    aid = _toint(aid, 0)
    local cfg = _config and _config.details and _config.details[aid]
    if not cfg then
        Player.sendmsgEx(play, "灵根试炼配置缺失#57")
        return
    end

    local branch = _get_main_branch(play)
    if branch <= 0 then
        Player.sendmsgEx(play, "请先在灵根天赋中选择本命灵根#57")
        return
    end
    if aid ~= branch then
        Player.sendmsgEx(play, "只能挑战当前本命灵根试炼：|"..(_branch_names[branch] or "本命灵根").."#218|")
        return
    end

    local data = _get_story(play)
    local trial = _normalize_trial_for_branch(play, branch, data)

    if ew == 1 then
        if _toint(trial[tostring(aid)], 0) >= 2 and _toint(trial.main, 0) == aid then
            Player.sendmsgEx(play, "当前本命灵根试炼已经通关#57")
            return
        end
        if _toint(trial[tostring(aid)], -1) == 0 then
            Player.sendmsgEx(play, "当前本命灵根试炼正在进行中#57")
            return
        end
        local needCoreLevel = _toint(_config and _config.need_core_level, 30)
        local coreLevel = _get_linggen_core_level(play)
        if needCoreLevel > 0 and coreLevel < needCoreLevel then
            Player.sendmsgEx(play, "灵根核心等级达到Lv." .. tostring(needCoreLevel) .. "后才可进入本命灵根试炼#57")
            return
        end
        if not _check_trial_limit(play, aid) then
            return
        end
        if not _take_trial_cost(play) then
            return
        end
        trial[tostring(aid)] = 0
        trial.main = aid
        _save_story(play, data)
        sendluamsg(play, 100, npcid, 1, aid, "")
        Player.sendmsgEx(play, "已进入本命灵根试炼，请击败守护兽#57")
        syt_jrdt_602(play, aid)
    elseif ew == 2 then
        if _toint(trial[tostring(aid)], -1) ~= 1 then
            Player.sendmsgEx(play, "本命灵根试炼尚未完成#57")
            return
        end
        trial[tostring(aid)] = 2
        trial.main = aid
        _save_story(play, data)
        Npc68RefreshMainLinggenEffect(play)
        Player.sendmsgEx(play, "本命灵根试炼通关，灵根特效已激活#218")
        sendluamsg(play, 100, npcid, 2, aid, "")
        sendluamsg(play, 101, 1005, 0, 0, "rwwc")
    end
end

function syt_jrdt_602(play, idx)
    local cfg = _config and _config.details and _config.details[idx]
    if not cfg then
        return false
    end
    local dtm = getbaseinfo(play, 1) .. "_lgsz"
    if checkmirrormap(dtm) then
        delmirrormap(dtm)
    end
    addmirrormap("D3804_2", dtm, "灵根试炼", 300, "xtc", 136, 136)
    mapmove(play, dtm, 29, 27, 2)
    genmonex(dtm, 29, 31, cfg.mob_name, 2, 1, 0, 54, "", 0)
    startautoattack(play)
    delaygoto(play, 100, "@npc_68_fbjs")
    shaguai.jia(play, 30)
    return true
end

function npc_68_fbjs(play)
    senddelaymsg(play, "灵根试炼通关剩余%s", 180, 250, 1, "@npc_68_fb_end")
end

function npc_68_fb_end(play)
    local dtm = getbaseinfo(play, 1) .. "_lgsz"
    if getbaseinfo(play, 3) == dtm then
        if getmoncount(dtm, -1, true) < 1 then
            delmirrormap(dtm)
        else
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>未通关试炼，请重新挑战...</font>","Type":9}')
            delmirrormap(dtm)
        end
    end
end

if GameEvent and EventCfg then
    GameEvent.add(EventCfg.onLogin, Npc68RefreshMainLinggenEffect, "npc68_linggen_trial_effect_login")
    GameEvent.add(EventCfg.onLoginEnd, Npc68RefreshMainLinggenEffect, "npc68_linggen_trial_effect_login_end")
    GameEvent.add(EventCfg.onKFLogin, Npc68RefreshMainLinggenEffect, "npc68_linggen_trial_effect_kf_login")
end

rawset(_G, "Npc68RefreshMainLinggenEffect", Npc68RefreshMainLinggenEffect)
rawset(_G, "Npc68ResetMainTrial", Npc68ResetMainTrial)

return npc