npc = {}

-- 赤焰试炼（三段）
-- 1) 赤焰焚殿：击杀200只小怪（type=0）
-- 2) 赤焰焚殿二层：击杀50只精英（type=1）
-- 3) 赤焰焚殿三层：击杀5只BOSS（type=2）
-- 完成一段自动开启下一段地图门，三段全部完成后在本NPC一次领取奖励。

local _cfg_key = "npc_700"
local _config = Guard.getConfig(_cfg_key)
local _task_cfg = (_config and _config.task_cfg) or {}
local _shaguai_id = tonumber(_config and (_config.shaguai_id or string.match(_cfg_key, "%d+")) or 0) or 0

local function _stages()
    local cfg = _task_cfg.trial_stages
    if type(cfg) == "table" and #cfg >= 3 then
        return cfg
    end
    return {
        {name = "一层试炼", map = "赤焰焚殿", mob_type = 0, need = 200, tp = {"赤焰焚殿",31,123}},
        {name = "二层试炼", map = "赤焰焚殿二层", mob_type = 1, need = 50, tp = {"赤焰焚殿二层",24,21}},
        {name = "三层试炼", map = "赤焰焚殿三层", mob_type = 2, need = 5, tp = {"赤焰焚殿三层",242,255}},
    }
end

local function _suffix(idx)
    if idx == 1 then return "a" end
    if idx == 2 then return "b" end
    if idx == 3 then return "c" end
    return tostring(idx)
end

local function _cnt_key(idx)
    return _cfg_key .. "_" .. _suffix(idx)
end

local function _need_of(stage)
    local n = tonumber(stage and stage.need or 0) or 0
    if n < 1 then
        n = 1
    end
    return n
end

local function _stage_done(sg_data, idx, stage)
    local cur = tonumber(sg_data[_cnt_key(idx)] or 0) or 0
    return cur >= _need_of(stage)
end

local function _next_stage_idx(sg_data)
    local stages = _stages()
    for i, st in ipairs(stages) do
        if not _stage_done(sg_data, i, st) then
            return i
        end
    end
    return 0
end

local function _is_unlocked(jq_data, sg_data, idx)
    local state = tonumber(jq_data[_cfg_key] or 0) or 0
    if state >= 2 then
        return true
    end
    if state < 1 then
        return false
    end
    if idx <= 1 then
        return true
    end

    local stages = _stages()
    for i = 1, idx - 1 do
        if not _stage_done(sg_data, i, stages[i]) then
            return false
        end
    end
    return true
end

local function _try_tp(play, jq_data, sg_data, idx)
    local stages = _stages()
    local st = stages[idx]
    if not st then
        Player.sendmsgEx(play, "传送目标不存在#57")
        return
    end

    if not _is_unlocked(jq_data, sg_data, idx) then
        Player.sendmsgEx(play, "该层尚未开启，请先完成前置试炼#57")
        if npcid then Guard.closeNpcAndAuto(play, npcid) end
        return
    end

    local tp = st.tp or {st.map, 20, 20}
    if not (type(tp) == "table" and tp[1] and tp[2] and tp[3]) then
        Player.sendmsgEx(play, "传送配置缺失#57")
        if npcid then Guard.closeNpcAndAuto(play, npcid) end
        return
    end
    mapmove(play, tp[1], tp[2], tp[3], 5)
end

local function _clear_sg_temp(play)
    local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
    sg_data[_cnt_key(1)] = nil
    sg_data[_cnt_key(2)] = nil
    sg_data[_cnt_key(3)] = nil
    Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
end

function npc.main(play,npcid)
    if not _config then
        return
    end
    local data = {}
    data["T_dljq"] = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    data["sg_data"] = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
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
    local __guardAllowedActions = Guard.newActionSet({1,2,3,4})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end

    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])

    if ew >= 2 and ew <= 4 then
        _try_tp(play, jq_data, sg_data, ew - 1)
        return
    end

    local state = tonumber(jq_data[_cfg_key] or 0) or 0
    if state < 1 then
        jq_data[_cfg_key] = 1
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        if _shaguai_id > 0 then
            shaguai.jia(play, _shaguai_id)
        end
        Player.sendmsgEx(play, "领取|【"..(_config.name or "任务").."】#249|")
        if npcid then Guard.closeNpcAndAuto(play, npcid) end
        sendluamsg(play,101,1005,0,0,"rwjs")
        sendluamsg(play,100,npcid,1,0,"")
        return
    end

    if state >= 2 then
        Player.sendmsgEx(play, "你已经完成#57|【"..(_config.name or "该任务").."】#249|")
        return
    end

    local next_idx = _next_stage_idx(sg_data)
    if next_idx <= 0 then
        Guard.clearTaskTemp(jq_data, _cfg_key)
        jq_data[_cfg_key] = 2
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        _clear_sg_temp(play)

        if _shaguai_id > 0 then
            shaguai.jian(play, _shaguai_id)
        end

        Player.sendmsgEx(play, "|【"..(_config.name or "任务").."】#249|完成#57")
        if npcid then Guard.closeNpc(play, npcid) end
        sendluamsg(play,101,1005,0,0,"rwwc")
        Guard.giveTaskReward(play, _config, (_config.name or "剧情任务").."奖励")
        sendluamsg(play,100,npcid,1,3,"")
        return
    end

    local stages = _stages()
    local st = stages[next_idx]
    local cur = tonumber(sg_data[_cnt_key(next_idx)] or 0) or 0
    local need = _need_of(st)
    Player.sendmsgEx(play, string.format("当前进度：|【%s %d/%d】#249|", st.name or ("试炼"..next_idx), cur, need))
    Player.sendmsgEx(play, "完成当前试炼后将自动开启下一层地图门#57")
    sendluamsg(play,100,npcid,1,next_idx - 1,"")
end

return npc
