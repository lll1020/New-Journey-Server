npc = {}


--天鼠的游戏

local _config = Guard.getConfig("npc_651")




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
        local ans = tonumber(aid) 
        if not ans then
            Player.sendmsgEx(play, "请先选择答案#57")
            return
        end

        local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
        local key = "npc_651"
        if jq_data[key] and jq_data[key] >= 2 then
            Player.sendmsgEx(play, "你已经完成【"..(_config.name or "该任务").."】#57")
            return
        end

        local answers = _config.answer or {}
        local total = #answers
        if total <= 0 then
            Player.sendmsgEx(play, "题目配置错误#57")
            return
        end

        local step_key = key.."_step"
        local step = tonumber(jq_data[step_key]) or 1
        if step > total then
            step = total
        end

        if ans ~= answers[step] then
            Player.sendmsgEx(play, "回答错误#57")
            return
        end

        step = step + 1
        if step > total then
            jq_data[key] = 2
            jq_data[step_key] = total
            if (jq_data[key] or 0) >= 2 then
                Guard.clearTaskTemp(jq_data, key)
                jq_data[key] = 2
            end
            Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
            Player.sendmsgEx(play, "【"..(_config.name or "任务").."】完成#57")
            if _config.ch then
                Player.title_give(play, _config.ch)
            end
            sendluamsg(play,101,1005,0,0,"rwwc")
            local reward = _config.jl or _config.rwjl
            if reward then
                Player.rwjl(play, reward, (_config.name or "剧情任务").."奖励", 1)
            end
            sendluamsg(play,100,npcid,1,2,tbl2json({step_key = jq_data[step_key]}))
            return
        end

        jq_data[step_key] = step
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        Player.sendmsgEx(play, string.format("回答正确，当前进度：%d/%d#57", step - 1, total))
        sendluamsg(play,100,npcid,1,1,tbl2json({step_key = jq_data[step_key]}))
        
    end
end

return npc


