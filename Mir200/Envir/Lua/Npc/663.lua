npc = {}


--灵域使者·一

local _config = Guard.getConfig("npc_663")




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
        local key = "npc_663"
        if jq_data[key] and jq_data[key] >= 2 then
            Player.sendmsgEx(play, "你已经完成#57|【"..(_config.name or "该任务").."】#218|")
            return
        end

        local list = _config.xz or {}
        local total = #list
        local done = 0
        local undone = {}
        for i = 1, total do
            local sub = "npc_"..list[i]
            local cfg = Guard.getConfig(sub)
            local ch = cfg and cfg.ch
            if ch and checktitle(play, ch) then
                done = done + 1
            else
                local nm = cfg and cfg.name or sub
                undone[#undone + 1] = nm
            end
        end

        if total > 0 and done >= total then
            jq_data[key] = 2
            if (jq_data[key] or 0) >= 2 then
                Guard.clearTaskTemp(jq_data, key)
                jq_data[key] = 2
            end
            Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
            Player.sendmsgEx(play, "|【"..(_config.name or "任务").."】#218|完成#57")
            if npcid then Guard.closeNpc(play, npcid) end
            if _config.ch then
                Player.title_give(play, _config.ch)
            end
            sendluamsg(play,101,1005,0,0,"rwwc")
            local reward = _config.jl or _config.rwjl
            if reward then
                Player.rwjl(play, reward, (_config.name or "剧情任务").."奖励", 1)
            end
            sendluamsg(play,100,npcid,1,2,"")
            return
        end

        local msg = string.format("进度：|【%d/%d】#218|", done, total)
        if #undone > 0 then
            msg = msg.."\n未完成："..table.concat(undone, "、")
        end
        Player.sendmsgEx(play, msg)
    end
end

return npc




