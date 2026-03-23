npc = {}


--天鸡的游戏

local _config = Guard.getConfig("npc_660")




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
    -- npc_guard: 入参校验
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local __guardAction = Guard.normalizeAction(play, npcid, ew)
    if __guardAction == nil then
        return
    end
    ew = __guardAction
    -- npc_guard: 操作白名单（优化：限定合法操作编号）
    local __guardAllowedActions = Guard.newActionSet({1})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end

    if ew == 1 then
        local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
        local key = "npc_660"
        if jq_data[key] and jq_data[key] >= 2 then
            Player.sendmsgEx(play, "你已经完成#57|【"..(_config.name or "该任务").."】#249|")
            return
        end

        if not Guard.ensureCost(play, _config.cost) then
            return
        end
        Guard.consumeCost(play, _config.cost, ","..(_config.name or "剧情任务"))

        jq_data[key] = 2
        if (jq_data[key] or 0) >= 2 then
            Guard.clearTaskTemp(jq_data, key)
            jq_data[key] = 2
        end
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        Player.sendmsgEx(play, "|【"..(_config.name or "任务").."】#249|完成#57")
        if _config.ch then
            Player.title_give(play, _config.ch)
        end
        sendluamsg(play,101,1005,0,0,"rwwc")
        local reward = _config.jl or _config.rwjl
        if reward then
            Player.rwjl(play, reward, (_config.name or "剧情任务").."奖励", 1)
        end
        sendluamsg(play,100,npcid,1,2,"")
    end
end

return npc


