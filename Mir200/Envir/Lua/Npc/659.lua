npc = {}


--天猴的游戏

local _config = Guard.getConfig("npc_659")




function npc.main(play,npcid)
    if not _config then
        return
    end
    local data = {}
    data["T_dljq"] = Player.getJsonTableByVar(play, VarCfg.T_dljq)
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
        local key = "npc_659"
        local round_key = key.."_round"
        local round = jq_data[round_key] or 0

        if jq_data[key] and jq_data[key] >= 2 then
            Player.sendmsgEx(play, "你已经完成【"..(_config.name or "该任务").."】#57")
            return
        end
        if round >= 5 then
            jq_data[key] = 2
            if (jq_data[key] or 0) >= 2 then
                Guard.clearTaskTemp(jq_data, key)
                jq_data[key] = 2
            end
            Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
            Player.sendmsgEx(play, "你已经完成【"..(_config.name or "该任务").."】#57")
            return
        end

        local choice = tonumber(aid)
        if data and data ~= "" then
            local ok, json_data = pcall(json2tbl, data)
            if ok and type(json_data) == "table" and json_data.choice then
                choice = tonumber(json_data.choice)
            end
        end
        if not choice or choice < 1 or choice > 3 then
            Player.sendmsgEx(play, "请选择有效的出拳选项#57")
            return
        end

        if not Guard.ensureCost(play, _config.cost) then
            return
        end
        Guard.consumeCost(play, _config.cost, ","..(_config.name or "剧情任务"))

        local outcomes = {1,1,2,2,1} -- 1玩家赢 2玩家输
        local result = outcomes[round + 1] or 1
        local npc_choice
        if result == 1 then
            if choice == 1 then
                npc_choice = 3
            elseif choice == 2 then
                npc_choice = 1
            else
                npc_choice = 2
            end
        else
            if choice == 1 then
                npc_choice = 2
            elseif choice == 2 then
                npc_choice = 3
            else
                npc_choice = 1
            end
        end

        round = round + 1
        jq_data[round_key] = round
        jq_data[key.."_win"] = (jq_data[key.."_win"] or 0) + (result == 1 and 1 or 0)
        if round >= 5 then
            jq_data[key] = 2
        end
            if (jq_data[key] or 0) >= 2 then
                Guard.clearTaskTemp(jq_data, key)
                jq_data[key] = 2
            end
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)

        local name_map = {[1] = "布", [2] = "剪刀", [3] = "石头"}
        local npc_name = name_map[npc_choice] or tostring(npc_choice or "?")
        if result == 1 then
            Player.sendmsgEx(play, "本轮你获胜，系统出："..npc_name.."#57")
        else
            Player.sendmsgEx(play, "本轮你失败，系统出："..npc_name.."#57")
        end
        local win_count = jq_data[key.."_win"] or 0
        Player.sendmsgEx(play, string.format("当前胜利：%d/3#57", win_count))

        local send_data = {}
        send_data["T_dljq"] = jq_data
        send_data["result"] = result
        send_data["round"] = round
        send_data["player_choice"] = choice
        send_data["npc_choice"] = npc_choice
        sendluamsg(play,100,npcid,1,0,tbl2json(send_data))

        if jq_data[key] and jq_data[key] >= 2 then
            Player.sendmsgEx(play, "【"..(_config.name or "任务").."】完成#57")
            if _config.ch then
                Player.title_give(play, _config.ch)
            end
            sendluamsg(play,101,1005,0,0,"rwwc")
            local reward = _config.jl or _config.rwjl
            if reward then
                Player.rwjl(play, reward, (_config.name or "剧情任务").."奖励", 1)
            end
            sendluamsg(play,100,npcid,1,2,"")
        end
    end
end

return npc






