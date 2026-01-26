npc = {}


--沉船之谜

local _config = Guard.getConfig("npc_629")


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
        local key = "npc_629"
        if jq_data[key] and jq_data[key] >= 2 then
            Player.sendmsgEx(play, "你已经完成了该任务#57")
            return
        end

        local idx = tonumber(aid)
        if idx ~= 1 and idx ~= 2 then
            Player.sendmsgEx(play, "参数异常#57")
            return
        end

        local cost = _config.cost and _config.cost[idx]
        if not cost then
            Player.sendmsgEx(play, "提交配置缺失#57")
            return
        end

        local markKey = key .. (idx == 1 and "_a" or "_b")
        if jq_data[markKey] == 1 then
            Player.sendmsgEx(play, "该物品已提交#57")
            return
        end

        if not Guard.ensureCost(play, cost) then
            return
        end
        Guard.consumeCost(play, cost, ","..(_config.name or "剧情任务"))
        jq_data[markKey] = 1

        local a_done = (not (_config.cost and _config.cost[1])) or (jq_data[key.."_a"] == 1)
        local b_done = (not (_config.cost and _config.cost[2])) or (jq_data[key.."_b"] == 1)

        if a_done and b_done then
            jq_data[key] = 2
            Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
            Player.sendmsgEx(play, "任务完成#57")
            sendluamsg(play,101,1005,0,0,"rwwc")
            local reward = _config.jl or _config.rwjl
            if reward then
                Player.rwjl(play, reward, (_config.name or "剧情任务").."奖励", 1)
            end
            sendluamsg(play,100,npcid,1,2,"")
        else
            jq_data[key] = 1
            Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
            Player.sendmsgEx(play, "已提交部分物品#57")
            npc.main(play,npcid)

        end
    end
end

return npc