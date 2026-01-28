npc = {}


--真假经书

local _config = Guard.getConfig("npc_649")


function npc.main(play,npcid)
    local data = {}
    data["T_dljq"] = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    sendluamsg(play,100,npcid,0,0,tbl2json(data))
end

function npc.link(play,npcid,ew,aid)
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
        local key = "npc_649"
        local try_key = key.."_try"
        local ok_key = key.."_ok"
        if jq_data[key] and jq_data[key] >= 2 then
            Player.sendmsgEx(play, string.format("已完成：成功 %d/%d，累计提交 %d 次#57", (jq_data[ok_key] or 0), (_config.num or 0), (jq_data[try_key] or 0)))
            return
        end

        if not Guard.ensureCost(play, _config.cost) then
            return
        end
        Guard.consumeCost(play, _config.cost, ","..(_config.name or "剧情任务"))

        jq_data[try_key] = (jq_data[try_key] or 0) + 1

        local success = FProbabilityHit(_config.gl or 0)
        if success then
            jq_data[ok_key] = (jq_data[ok_key] or 0) + 1
            Player.sendmsgEx(play, string.format("提交成功：%d/%d#57", jq_data[ok_key], (_config.num or 0)))
            sendluamsg(play,100,npcid,1,1,tbl2json({try_key = jq_data[try_key], ok_key = jq_data[ok_key]}))
        else
            Player.sendmsgEx(play, "提交失败#57")
            sendluamsg(play,100,npcid,1,1,tbl2json({try_key = jq_data[try_key], ok_key = jq_data[ok_key]}))
        end
        Player.sendmsgEx(play, string.format("累计提交：%d 次#57", jq_data[try_key]))

        if (jq_data[ok_key] or 0) >= (_config.num or 0) then
            jq_data[key] = 2
            Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
            Player.sendmsgEx(play, "任务完成#57")
            sendluamsg(play,101,1005,0,0,"rwwc")
            local reward = _config.jl or _config.rwjl
            if reward then
                Player.rwjl(play, reward, (_config.name or "剧情任务").."奖励", 1)
            end
            sendluamsg(play,100,npcid,1,2,"")
            return
        end

        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
    end
end

return npc
