npc = {}


--共公怒触不周山

local _config = Guard.getConfig("npc_676")




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
        local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
        local key = "npc_676"
        if jq_data[key] and jq_data[key] >= 2 then
            Player.sendmsgEx(play, "你已经完成【"..(_config.name or "该任务").."】#57")
            return
        end

        if not jq_data[key] or jq_data[key] == 0 then
            jq_data[key] = 1
            Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
            Player.sendmsgEx(play, "领取【"..(_config.name or "任务").."】")
            shaguai.jia(play, _config.shaguai_id or 676)
            sendluamsg(play,101,1005,0,0,"rwjs")
            npc.main(play,npcid)
            return
        end

        local cntKey = key.."_cnt"
        local cnt = jq_data[cntKey] or 0

        local need = (_config.jl_num or 0) * (cnt + 1)
        local cur = sg_data[key] or 0
        if cur < need then
            Player.sendmsgEx(play, string.format("击杀不足：%d/%d#57", cur, need))
            return
        end
        cnt = cnt + 1
        jq_data[cntKey] = cnt

        if cnt >= 5 then
            jq_data[key] = 2
            if (jq_data[key] or 0) >= 2 then
                Guard.clearTaskTemp(jq_data, key)
                jq_data[key] = 2
            end
            Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
            local jl_c = _config.jl_c
            if jl_c and #jl_c > 0 then
                local idx = math.random(1, #jl_c)
                local reward = {jl_c[idx]}
                Player.rwjl(play, reward, (_config.name or "剧情任务").."小奖励", 1)
            end
            Player.sendmsgEx(play, "【"..(_config.name or "任务").."】完成#57")
            if _config.ch then
                Player.title_give(play, _config.ch)
            end
            sendluamsg(play,101,1005,0,0,"rwwc")
            shaguai.jian(play, _config.shaguai_id or 676)
            npc.main(play,npcid)
        else
            jq_data[key] = 1
            Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
            local jl_c = _config.jl_c
            if jl_c and #jl_c > 0 then
                local idx = math.random(1, #jl_c)
                local reward = {jl_c[idx]}
                Player.rwjl(play, reward, (_config.name or "剧情任务").."小奖励", 1)
            end
            Player.sendmsgEx(play, string.format("提交成功：%d/5#57", cnt))
            npc.main(play,npcid)
        end
    end
end

return npc






