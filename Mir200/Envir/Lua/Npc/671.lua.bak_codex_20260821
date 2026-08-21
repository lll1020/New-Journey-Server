npc = {}


--地狱使者

local _config = Guard.getConfig("npc_671")

local function _sync_671_progress(jq_data, total)
    jq_data = jq_data or {}
    total = tonumber(total) or 0
    local token = tonumber(jq_data["npc_671_token"] or 0) or 0
    if token < 0 then
        token = 0
    end
    if total > 0 and token > total then
        token = total
    end
    jq_data["npc_671_token"] = token
    jq_data["npc_671_lv"] = token
    jq_data["npc_671_cur"] = 0
    return jq_data
end


function npc.main(play,npcid)
    if not _config then
        return
    end
    local data = {}
    local details = _config.details or {}
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    jq_data = _sync_671_progress(jq_data, #details)
    Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
    data["T_dljq"] = jq_data
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
    local __guardAllowedActions = Guard.newActionSet({1,2,3})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end

    local details = _config.details or {}
    local total = #details
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local key = "npc_671"
    jq_data = _sync_671_progress(jq_data, total)

    if ew == 1 then
        if jq_data[key] and jq_data[key] >= 2 then
            Player.sendmsgEx(play, "你已经完成#57|【"..(_config.name or "该任务").."】#218|")
            return
        end

        if npcid then Guard.closeNpcAndAuto(play, npcid) end

        local next_lv = (jq_data["npc_671_token"] or 0) + 1
        if next_lv > total then
            Player.sendmsgEx(play, "已完成全部挑战，请领取最终奖励#57")
            return
        end

        local cfg = details[next_lv]
        if not cfg or not cfg.map then
            Player.sendmsgEx(play, "地图配置缺失#57")
            if npcid then Guard.closeNpcAndAuto(play, npcid) end
            return
        end

        local tp = cfg.tp or {54, 85}
        map(play, cfg.map)
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        return
    end


    if ew == 3 then
        local total_get = 0
        local details = _config.details or {}
        for i = 1, #details do
            local cfg = details[i]
            local item = cfg and cfg.jl and cfg.jl[1] and cfg.jl[1][1]
            if item and item ~= "" then
                local name, num = Player.checkItemNumByTable(play, {{item,1}})
                if not name then
                    Guard.consumeCost(play, {{item,1}}, ",回收信物")
                    total_get = total_get + 1
                end
            end
        end
        local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
        jq_data["npc_671_token"] = (jq_data["npc_671_token"] or 0) + total_get
        jq_data = _sync_671_progress(jq_data, total)
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        Player.sendmsgEx(play, string.format("已回收信物：|【%d个】#218|", total_get))
        Player.sendmsgEx(play, string.format("共计已回收信物：|【%d个】#218|", jq_data["npc_671_token"] or 0))
        sendluamsg(play,100,npcid,0,0,tbl2json({T_dljq = jq_data}))
        return
    end

    if ew == 2 then
        if jq_data[key] and jq_data[key] >= 2 then
            Player.sendmsgEx(play, "你已经完成#57|【"..(_config.name or "该任务").."】#218|")
            return
        end
        local npc_671_token = jq_data["npc_671_token"] or 0
        if total > 0 and npc_671_token >= total then
            -- 本NPC不清理临时字段，保留层数和回收进度
            jq_data[key] = 2
            Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
            Player.sendmsgEx(play, "|【"..(_config.name or "任务").."】#218|完成#57")
            if npcid then Guard.closeNpc(play, npcid) end
            sendluamsg(play,101,1005,0,0,"rwwc")
            local reward = _config.jl or _config.rwjl
            if reward then
                Player.rwjl(play, reward, (_config.name or "剧情任务").."奖励", 1)
            end
            sendluamsg(play,100,npcid,1,2,"")
        else
            Player.sendmsgEx(play, string.format("当前进度：|【%d/%d】#218|", npc_671_token, total))
        end
    end
end

return npc
