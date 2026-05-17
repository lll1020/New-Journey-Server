npc = {}

-- drop_hint: 诡异碎片一：1/2000 诡异碎片二：1/1000 诡异碎片三：1/888

local _cfg_key = "npc_703"
local _config = Guard.getConfig(_cfg_key)
local _task_cfg = (_config and _config.task_cfg) or {}

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
    local __guardAllowedActions = Guard.newActionSet({1})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end
    if ew ~= 1 then
        return
    end

    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local max_num = 1
    local prog_key = _cfg_key .. "_a"
    local state = tonumber(jq_data[_cfg_key] or 0) or 0
    local cnt = tonumber(jq_data[prog_key] or 0) or 0
    if state >= 2 then
        Player.sendmsgEx(play, "你已经完成#57|【"..(_config.name or "该任务").."】#218|")
        return
    end

    if state < 1 then
        jq_data[_cfg_key] = 1
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
    end

    local req_map = _task_cfg.map or "画壁"
    if getbaseinfo(play,3) ~= req_map and getbaseinfo(play,3) ~= "xtc" then
        Player.sendmsgEx(play, "请前往#57|【"..req_map.."】#218|完成后再提交#57")
        if npcid then Guard.closeNpc(play, npcid) end
        return
    end

    local costs = _task_cfg.submit
    if not Guard.ensureCost(play, costs) then
        return
    end
    Guard.consumeCost(play, costs, ","..(_config.name or "剧情任务"))

    cnt = cnt + 1
    jq_data[prog_key] = cnt
    Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
    Player.sendmsgEx(play, string.format("提交进度：#57|【%d/%d】#218|", cnt, max_num))

    if cnt >= max_num then
        Guard.clearTaskTemp(jq_data, _cfg_key)
        jq_data[_cfg_key] = 2
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        Player.sendmsgEx(play, "|【"..(_config.name or "任务").."】#218|完成#57")
        if npcid then Guard.closeNpc(play, npcid) end
        sendluamsg(play,101,1005,0,0,"rwwc")

        Guard.giveTaskReward(play, _config, (_config.name or "剧情任务").."奖励")
    end

    sendluamsg(play,100,npcid,1,cnt,"")
end

return npc



