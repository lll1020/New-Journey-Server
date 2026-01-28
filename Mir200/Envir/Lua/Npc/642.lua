npc = {}


--资格考验

local _config = Guard.getConfig("npc_642")


function npc.main(play,npcid)
    local data = {}
    data["T_dljq"] = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    data["sg_data"] = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
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
        local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
        local key = "npc_642"
        if jq_data[key] and jq_data[key] >= 2 then
            if _config.tp_map and _config.tp_map[1] and _config.tp_map[2] and _config.tp_map[3] then
                mapmove(play, _config.tp_map[1], _config.tp_map[2], _config.tp_map[3], 5)
            else
                Player.sendmsgEx(play, "传送配置缺失#57")
            end
            return
        end

        if not jq_data[key] or jq_data[key] == 0 then
            jq_data[key] = 1
            Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
            Player.sendmsgEx(play, "领取任务")
            shaguai.jia(play, _config.shaguai_id or 642)
            sendluamsg(play,101,1005,0,0,"rwjs")
            sendluamsg(play,100,npcid,1,1,"")
            return
        end

        if jq_data[key] == 1 then
            local a = sg_data[key.."_a"] or 0
            local b = sg_data[key.."_b"] or 0
            if a >= (_config.num_a or 0) and b >= (_config.num_b or 0) then
                jq_data[key] = 2
                Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
                Player.sendmsgEx(play, "任务完成")
                sendluamsg(play,101,1005,0,0,"rwwc")
                Player.rwjl(play, _config.rwjl or {{"元宝",1},{"金币",1}}, (_config.name or "剧情任务").."奖励", 1)
                sendluamsg(play,100,npcid,1,2,"")
            else
                Player.sendmsgEx(play, "你还没有完成任务#57")
            end
        end
    end
end

return npc