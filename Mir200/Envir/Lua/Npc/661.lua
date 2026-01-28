npc = {}


--天狗的游戏

local _config = Guard.getConfig("npc_661")


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
        local key = "npc_661"
        local now = os.time()
        local limit = _config.time or 0

        if jq_data[key] and jq_data[key] >= 2 then
            Player.sendmsgEx(play, "你已经完成了该任务#57")
            return
        end

        if not jq_data[key] or jq_data[key] == 0 then
            jq_data[key] = 1
            jq_data[key.."_st"] = now
            jq_data[key.."_ok"] = 0
            sg_data[key] = 0
            Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
            Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
            Player.sendmsgEx(play, "领取任务")
            if limit and limit > 0 then
                senddelaymsg(play, "任务剩余时间：%s", limit, 250, 1, "@npc_661_timeout")
            end
            shaguai.jia(play, _config.shaguai_id or 661)
            sendluamsg(play,101,1005,0,0,"rwjs")
            sendluamsg(play,100,npcid,1,1,"")
            return
        end

        if jq_data[key] == 1 then
            if jq_data[key.."_ok"] == 1 then
                jq_data[key] = 2
                Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
                Player.sendmsgEx(play, "任务完成")
                if _config.ch then
                    Player.title_give(play, _config.ch)
                end
                sendluamsg(play,101,1005,0,0,"rwwc")
                Player.rwjl(play, _config.rwjl or { {"元宝",1},{"金币",1} }, (_config.name or "剧情任务").."奖励", 1)
                sendluamsg(play,100,npcid,1,2,"")
                return
            end

            local start = jq_data[key.."_st"] or 0
            if limit > 0 and (now - start) > limit then
                jq_data[key] = 0
                jq_data[key.."_ok"] = 0
                sg_data[key] = 0
                Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
                Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
                local left = limit > 0 and (limit - (now - start)) or 0
                if left < 0 then left = 0 end
                Player.sendmsgEx(play, string.format("任务失败，已超时（剩余：%d秒）#57", left))
                return
            end

            Player.sendmsgEx(play, "你还没有完成任务#57")
        end
    end
end



function npc_661_timeout(play)
    Player.sendmsgEx(play, "任务时间已到#57")
end



return npc

