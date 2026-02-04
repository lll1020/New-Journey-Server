npc = {}


--杀戮的欲望

local _config = Guard.getConfig("npc_634")

function npc.main(play,npcid)
    if not _config then
        return
    end
    local data = {}
    data["sg_data"] = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
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

    local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local key = "npc_634"
    if jq_data[key] and jq_data[key] >= 2 then
        Player.sendmsgEx(play, "你已经完成【"..(_config.name or "该任务").."】#57")
        return
    end
    if ew == 1 then
        if jq_data[key] and jq_data[key] == 1 then
            Player.sendmsgEx(play, "你已经领取【"..(_config.name or "该任务").."】#57")
            return
        end
        jq_data[key] = 1
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        Player.sendmsgEx(play, "领取【"..(_config.name or "任务").."】")
        shaguai.jia(play, _config.shaguai_id or 634)
        sendluamsg(play,101,1005,0,0,"rwjs")
        sendluamsg(play,100,npcid,1,1,"")
    elseif ew == 2 then
        if jq_data[key] and jq_data[key] == 1 then
            if sg_data[key] and sg_data[key] >= (_config.num or 0) then
                jq_data[key] = 2
                Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
                Player.sendmsgEx(play, "【"..(_config.name or "任务").."】完成")
                sendluamsg(play,101,1005,0,0,"rwwc")
                if _config.ch then
                    Player.title_give(play, _config.ch)
                end
                local reward = _config.jl or _config.rwjl
                if reward then
                    Player.rwjl(play, reward, (_config.name or "剧情任务").."奖励", 1)
                end
                sendluamsg(play,100,npcid,1,2,"")
            else
                Player.sendmsgEx(play, "你还没有完成【"..(_config.name or "该任务").."】#57")
                return
            end
        else
            Player.sendmsgEx(play, "你还没有领取【"..(_config.name or "任务").."】#57")
            return
        end
    end
end

return npc


