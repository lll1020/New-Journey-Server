npc = {}

-- drop_hint: 葬亡晶石：1/2500

local _cfg_key = "npc_701"
local _config = Guard.getConfig(_cfg_key)
local _shaguai_id = tonumber(_config and (_config.shaguai_id or string.match(_cfg_key, "%d+")) or 0) or 0
local _task_cfg = (_config and _config.task_cfg) or {}



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
    local __guardAllowedActions = Guard.newActionSet({1})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end
    if ew ~= 1 then
        return
    end

    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
    local max_num = 1
    local prog_key = _cfg_key .. "_a"
    local state = tonumber(jq_data[_cfg_key] or 0) or 0
    local cnt = tonumber(jq_data[prog_key] or 0) or 0
    if state >= 2 then
        Player.sendmsgEx(play, "你已经完成#57|【"..(_config.name or "该任务").."】#249|")
        return
    end
    if state < 1 then
        jq_data[_cfg_key] = 1
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        Player.sendmsgEx(play, "领取|【"..(_config.name or "任务").."】#249|")
        if npcid then Guard.closeNpcAndAuto(play, npcid) end
        if _shaguai_id > 0 then
            shaguai.jia(play, _shaguai_id)
        end
        sendluamsg(play,101,1005,0,0,"rwjs")
        sendluamsg(play,100,npcid,1,cnt,"")
        return
    end

    if getbaseinfo(play,3) ~= "葬天旧土" and getbaseinfo(play,3) ~= "xtc" then
        Player.sendmsgEx(play, "请前往#57|【葬天旧土】#249|完成后再提交#57")
        if npcid then Guard.closeNpc(play, npcid) end
        return
    end

    local kill_cur = tonumber(sg_data[_cfg_key] or 0) or 0
    if kill_cur < 300 then
        Player.sendmsgEx(play, string.format("击杀不足：#57|【%d/%d】#249|", kill_cur, 300))
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
    Player.sendmsgEx(play, string.format("提交进度：#57|【%d/%d】#249|", cnt, max_num))

    if cnt >= max_num then
        Guard.clearTaskTemp(jq_data, _cfg_key)
        jq_data[_cfg_key] = 2
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        Player.sendmsgEx(play, "|【"..(_config.name or "任务").."】#249|完成#57")
        if npcid then Guard.closeNpc(play, npcid) end
        sendluamsg(play,101,1005,0,0,"rwwc")

        Guard.giveTaskReward(play, _config, (_config.name or "剧情任务").."奖励")
    end

    sendluamsg(play,100,npcid,1,cnt,"")
end

return npc



