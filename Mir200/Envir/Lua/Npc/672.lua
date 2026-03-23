npc = {}


--轮回之路

local _config = Guard.getConfig("npc_672")




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
    local __guardAllowedActions = Guard.newActionSet({1,2,3})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end

    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
    local key = "npc_672"
    local details = _config.details or {}

    if ew == 1 then
        if jq_data[key] and jq_data[key] >= 2 then
            Player.sendmsgEx(play, "你已经完成#57|【"..(_config.name or "该任务").."】#249|")
            return
        end
        if jq_data[key] and jq_data[key] == 1 then
            Player.sendmsgEx(play, "你已经领取#57|【"..(_config.name or "该任务").."】#249|")
            return
        end
        jq_data[key] = 1
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        shaguai.jia(play, _config.shaguai_id or 672)
        Player.sendmsgEx(play, "领取|【"..(_config.name or "任务").."】#249|")
        sendluamsg(play,101,1005,0,0,"rwjs")
        sendluamsg(play,100,npcid,1,1,"")
        return
    end

    if ew == 2 then
        local idx = tonumber(aid)
        if not idx or idx < 1 or idx > #details then
            Player.sendmsgEx(play, "参数异常#57")
            return
        end
        local subKey = key.."_"..idx
        if jq_data[subKey] and jq_data[subKey] >= 1 then
            Player.sendmsgEx(play, "该小任务已完成#57")
            return
        end

        local cfg = details[idx]
        if not cfg then
            Player.sendmsgEx(play, "配置缺失#57")
            return
        end

        if cfg.a_num and (sg_data[key.."_a"] or 0) < cfg.a_num then
            Player.sendmsgEx(play, "击杀数量不足#57")
            return
        end
        if cfg.b_num and (sg_data[key.."_b"] or 0) < cfg.b_num then
            Player.sendmsgEx(play, "击杀数量不足#57")
            return
        end
        if cfg.c_num and (sg_data[key.."_c"] or 0) < cfg.c_num then
            Player.sendmsgEx(play, "击杀数量不足#57")
            return
        end
        if cfg.cost and not Guard.ensureCost(play, cfg.cost) then
            return
        end
        if cfg.cost then
            Guard.consumeCost(play, cfg.cost, ","..(_config.name or "剧情任务"))
        end

        jq_data[subKey] = 2
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        Player.sendmsgEx(play, "提交成功")
        sendluamsg(play,100,npcid,2,idx,"")
        return
    end

    if ew == 3 then
        local done = 0
        for i = 1, #details do
            if jq_data[key.."_"..i] and jq_data[key.."_"..i] >= 2 then
                done = done + 1
            end
        end
        if done >= #details and #details > 0 then
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
        else
            Player.sendmsgEx(play, string.format("进度：|【%d/%d】#249|", done, #details))
        end
        return
    end
end

return npc



