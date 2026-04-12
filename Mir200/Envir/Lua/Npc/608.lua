npc = {}


--守护森林（剧）

local _config = Guard.getConfig("npc_608")
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
    local key = "npc_608"
    if jq_data[key] and jq_data[key] >= 2 then
        Player.sendmsgEx(play, "你已经完成#57|【"..(_config.name or "该任务").."】#249|")
        return
    end
    if ew == 1 then
        if jq_data[key] and jq_data[key] == 1 then
            Player.sendmsgEx(play, "你已经领取#57|【"..(_config.name or "该任务").."】#249|")
            return
        end
        jq_data[key] = 1
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        Player.sendmsgEx(play, "领取|【"..(_config.name or "任务").."】#249|")
        shaguai.jia(play, _config.shaguai_id or 608)
        sendluamsg(play,101,1005,0,0,"rwjs")
        sendluamsg(play,100,npcid,1,1,"")
        Guard.closeNpcAndAuto(play, npcid)
    elseif ew == 2 then
        if jq_data[key] and jq_data[key] == 1 then
            if sg_data[key] and sg_data[key] >= (_config.num or 0) then
                jq_data[key] = 2
                if (jq_data[key] or 0) >= 2 then
                    Guard.clearTaskTemp(jq_data, key)
                    jq_data[key] = 2
                end
                Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
                Player.sendmsgEx(play, "|【"..(_config.name or "任务").."】#249|完成")
                sendluamsg(play,101,1005,0,0,"rwwc")
                Player.rwjl(play, _config.rwjl or {{"绑定元宝",1},{"绑定金币",1}}, (_config.name or "剧情任务").."奖励", 1)
                if _config.ch then
                    Player.title_give(play, _config.ch)
                    Player.sendmsgEx(play, "恭喜获得称号|【".._config.ch.."】#249|")
                end
                sendluamsg(play,100,npcid,1,2,"")
                Guard.closeNpc(play, npcid)
            else
                Player.sendmsgEx(play, "你还没有完成#57|【"..(_config.name or "该任务").."】#249|")
                Guard.closeNpcAndAuto(play, npcid)
                return
            end
        else
            Player.sendmsgEx(play, "你还没有领取#57|【"..(_config.name or "任务").."】#249|")
            return
        end
    end
end

return npc

