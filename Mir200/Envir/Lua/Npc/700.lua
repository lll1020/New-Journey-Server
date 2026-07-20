npc = {}

-- 赤焰试炼：在任务地图累计击杀300只怪物。
local _cfg_key = "npc_700"
local _config = Guard.getConfig(_cfg_key)
local _task_cfg = (_config and _config.task_cfg) or {}
local _shaguai_id = tonumber(_config and (_config.shaguai_id or string.match(_cfg_key, "%d+")) or 0) or 0

local function _kill_need()
    return tonumber(_task_cfg.kill_count or (_config and _config.num) or 300) or 300
end

local function _clear_sg_temp(play)
    local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
    sg_data[_cfg_key .. "_a"] = nil
    sg_data[_cfg_key .. "_b"] = nil
    sg_data[_cfg_key .. "_c"] = nil
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
    local guard_action = Guard.normalizeAction(play, npcid, ew)
    if guard_action == nil then
        return
    end
    ew = guard_action
    local allowed_actions = Guard.newActionSet({1})
    if not Guard.ensureActionAllowed(play, npcid, ew, allowed_actions) or ew ~= 1 then
        return
    end

    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
    local state = tonumber(jq_data[_cfg_key] or 0) or 0

    if state >= 2 then
        Player.sendmsgEx(play, "你已经完成#57|【"..(_config.name or "该任务").."】#218|")
        return
    end

    if state < 1 then
        jq_data[_cfg_key] = 1
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        if _shaguai_id > 0 then
            shaguai.jia(play, _shaguai_id)
        end
        Player.sendmsgEx(play, "领取|【"..(_config.name or "任务").."】#218|")
        if npcid then Guard.closeNpcAndAuto(play, npcid) end
        sendluamsg(play,101,1005,0,0,"rwjs")
        sendluamsg(play,100,npcid,1,1,"")
        return
    end

    local task_map = _task_cfg.map or "赤焰焚殿"
    if task_map ~= "" and getbaseinfo(play,3) ~= task_map and getbaseinfo(play,3) ~= "xtc" then
        Player.sendmsgEx(play, "请前往#57|【"..task_map.."】#218|完成后再提交#57")
        return
    end

    local kill_cur = tonumber(sg_data[_cfg_key] or 0) or 0
    local kill_need = _kill_need()
    if kill_cur < kill_need then
        Player.sendmsgEx(play, string.format("击杀不足：#57|【%d/%d】#218|", kill_cur, kill_need))
        return
    end

    Guard.clearTaskTemp(jq_data, _cfg_key)
    jq_data[_cfg_key] = 2
    Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
    _clear_sg_temp(play)

    if _shaguai_id > 0 then
        shaguai.jian(play, _shaguai_id)
    end

    Player.sendmsgEx(play, "|【"..(_config.name or "任务").."】#218|完成#57")
    if npcid then Guard.closeNpc(play, npcid) end
    sendluamsg(play,101,1005,0,0,"rwwc")
    Guard.giveTaskReward(play, _config, (_config.name or "剧情任务").."奖励")
    sendluamsg(play,100,npcid,1,2,"")
end

return npc
