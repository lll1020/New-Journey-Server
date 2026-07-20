npc = {}


local NPC_ID = 728
local _cfg_key = "npc_" .. tostring(NPC_ID)
local _config = Guard.getConfig(_cfg_key)
local _task_cfg = (_config and _config.task_cfg) or {}
local DROP_RULES = {}
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

local function _give_items(play, reward, reason)
    if type(reward) == "table" and #reward > 0 then
        Player.rwjl(play, reward, reason or "第六章剧情奖励", 1)
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
        messagebox(play, "任务目标完成,请前往提交")
    end
end

local function _onKillPlay(play, target)
    local map = tostring(getbaseinfo(play, 3) or "")
    if map ~= "血契之地" and map ~= "血契之地二层" then
        return
    end
    local jq = _get_story(play)
    if _toint(jq[_cfg_key .. "_draw"]) >= 10 then
        return
    end
    jq[_cfg_key] = math.max(_toint(jq[_cfg_key]), 1)
    jq[_cfg_key .. "_kill"] = _toint(jq[_cfg_key .. "_kill"]) + 1
    _save_story(play, jq)
    Player.sendmsgEx(play, string.format("恶魔契约击杀进度：#57|【%d/100】#218|", _toint(jq[_cfg_key .. "_kill"])))
end

local function _handle(play, npcid, action, aid)
    if action ~= 2 then
        Player.sendmsgEx(play, "进入血契之地击杀玩家自动累计，每击杀10名玩家可抽奖一次，最多10次#57")
        return
    end
    local taskCfg = _task_cfg
    local jq = _get_story(play)
    local kills = _toint(jq[_cfg_key .. "_kill"])
    local draws = _toint(jq[_cfg_key .. "_draw"])
    local maxDraw = _toint(taskCfg.max_draw or 10)
    local needKill = (draws + 1) * _toint(taskCfg.kill_per_draw or 10)
    if draws >= maxDraw then
        Player.sendmsgEx(play, "今日契约抽奖次数已满#57")
        return
    end
    if kills < needKill then
        Player.sendmsgEx(play, string.format("击杀玩家不足：#57|【%d/%d】#218|", kills, needKill))
        return
    end
    local pool = taskCfg.draw_pool or {{"业火结晶", 5}, {"元宝", 100000}}
    local reward = pool[math.random(#pool)]
    draws = draws + 1
    jq[_cfg_key] = 1
    jq[_cfg_key .. "_draw"] = draws
    _save_story(play, jq)
    _give_items(play, {reward}, "恶魔契约抽奖")
    Player.sendmsgEx(play, string.format("恶魔契约抽奖成功：%d/%d#57", draws, maxDraw))
    if draws >= maxDraw then
        _finish(play, "恶魔契约奖励")
    end
end

function npc.main(play, npcid)
    if not _config then
        return
    end
    _send_state(play, npcid or NPC_ID)
end

function npc.link(play, npcid, ew, aid, msgData)
    if not _config then
        return
    end
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local action = Guard.normalizeAction(play, npcid, ew)
    if not action then
        return
    end
    if not Guard.ensureActionAllowed(play, npcid, action, Guard.newActionSet({1, 2, 3, 4, 5})) then
        return
    end
    if action == 4 then
        _onKillMon(play, aid)
        return
    end
    if action == 5 then
        _onKillPlay(play, aid)
        return
    end
    _handle(play, npcid or NPC_ID, action, aid)
    _send_state(play, npcid or NPC_ID)
end

return npc

