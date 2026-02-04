npc = {}


--深入野火（剧）

local _config = Guard.getConfig("npc_607")

function npc.main(play,npcid)
    if not _config then
        return
    end
    local data = {}
    data["jq_data"] = Player.getJsonTableByVar(play, VarCfg.T_dljq)
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
    local __guardAllowedActions = Guard.newActionSet({1, 2})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end

    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local key = "npc_607"
    if jq_data[key] and jq_data[key] >= 2 then
        Player.sendmsgEx(play, "你已经完成【"..(_config.name or "该任务").."】#57")
        return
    end
    if ew == 1 then
        Player.sendmsgEx(play, "该任务无需领取，直接提交#57")
        return
    elseif ew == 2 then
        if not Guard.ensureCost(play, _config.cost) then
            return
        end
        Guard.consumeCost(play, _config.cost, ","..(_config.name or "剧情任务"))
        jq_data[key] = 2
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        Player.sendmsgEx(play, "【"..(_config.name or "任务").."】完成")
        sendluamsg(play,101,1005,0,0,"rwwc")
        Player.rwjl(play, _config.rwjl or {{"元宝",1},{"金币",1}}, (_config.name or "剧情任务").."奖励", 1)
        sendluamsg(play,100,npcid,1,2,"")
    end
end

return npc

