npc = {}


--天羊的游戏

local _config = Guard.getConfig("npc_658")




function npc.main(play,npcid)
    if not _config then
        return
    end
    local data = {}
    data["T_dljq"] = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    data["sg_data"] = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
    sendluamsg(play,100,npcid,0,0,tbl2json(data))
end

function npc.link(play,npcid,ew,aid,data)
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
        local key = "npc_658"
        if jq_data[key] and jq_data[key] >= 2 then
            Player.sendmsgEx(play, "你已经完成#57|【"..(_config.name or "该任务").."】#218|")
            return
        end

        if not jq_data[key] or jq_data[key] == 0 then
            jq_data[key] = 1
            Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
            Player.sendmsgEx(play, "领取|【"..(_config.name or "任务").."】#218|")
            if npcid then Guard.closeNpcAndAuto(play, npcid) end
            shaguai.jia(play, _config.shaguai_id or 658)
            sendluamsg(play,101,1005,0,0,"rwjs")
            sendluamsg(play,100,npcid,1,1,"")
            return
        end

        if jq_data[key] == 1 then
            if sg_data[key] and sg_data[key] >= (_config.num or 0) then
                local answer = tostring(data or "")
                if answer == "" and aid ~= nil then
                    answer = tostring(aid or "")
                end
                local expect = tostring(_config.value or "")
                if answer == "" or answer ~= expect then
                    Player.sendmsgEx(play, "字谜答案不正确#57")
                    return
                end

                jq_data[key] = 2
                if (jq_data[key] or 0) >= 2 then
                    Guard.clearTaskTemp(jq_data, key)
                    jq_data[key] = 2
                end
                Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
                Player.sendmsgEx(play, "|【"..(_config.name or "任务").."】#218|完成")
                if npcid then Guard.closeNpc(play, npcid) end
                if _config.ch then
                    Player.title_give(play, _config.ch)
                end
                sendluamsg(play,101,1005,0,0,"rwwc")
                Player.rwjl(play, _config.rwjl or { {"绑定元宝",1} }, (_config.name or "剧情任务").."奖励", 0)
                sendluamsg(play,100,npcid,1,2,"")
            else
                Player.sendmsgEx(play, "你还没有完成#57|【"..(_config.name or "该任务").."】#218|")
                if npcid then Guard.closeNpcAndAuto(play, npcid) end
            end
        end
    end
end

return npc



