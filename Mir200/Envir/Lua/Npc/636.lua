npc = {}


--热血的友情

local _config = Guard.getConfig("npc_636")




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
        local key = "npc_636"
        local max_num = _config.max_num or 1
        local cnt = jq_data[key] or 0
        if cnt >= max_num then
            Player.sendmsgEx(play, "你已经完成【"..(_config.name or "该任务").."】#57")
            return
        end

        if not Guard.ensureCost(play, _config.cost) then
            return
        end
        Guard.consumeCost(play, _config.cost, ","..(_config.name or "剧情任务"))
        cnt = cnt + 1
        jq_data[key] = cnt
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        Player.sendmsgEx(play, string.format("提交进度：%d/%d#57", cnt, max_num))

        if _config.jl then
            Player.rwjl(play, _config.jl, (_config.name or "剧情任务").."奖励", 1)
        end

        if cnt >= max_num then
            if (jq_data[key] or 0) >= max_num then
                Guard.clearTaskTemp(jq_data, key)
                jq_data[key] = cnt
                Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
            end
            Player.sendmsgEx(play, "【"..(_config.name or "任务").."】完成#57")
            sendluamsg(play,101,1005,0,0,"rwwc")
            sendluamsg(play,100,npcid,1,2,"")
        else
            Player.sendmsgEx(play, "提交成功#57")
        end
    end
end

return npc

