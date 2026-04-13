npc = {}


--赛跑挑战

local _config = Guard.getConfig("npc_654")




function npc.main(play,npcid)
    if not _config then
        return
    end
    local data = {}
    data["T_dljq"] = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    sendluamsg(play,100,npcid,0,0,tbl2json(data))
end

local function npc_654_finish(play, dtm, win)
    if dtm then
        setenvirofftimer(dtm,1)
        if checkmirrormap(dtm) then
            delmirrormap(dtm)
        end
    end
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local key = "npc_654"
    local back = jq_data[key.."_back"]
    if back and back[1] and back[2] and back[3] then
        mapmove(play, back[1], back[2], back[3], 2)
    end
    jq_data[key.."_st"] = nil
    jq_data[key.."_back"] = nil
    jq_data[key.."_run"] = nil
    if win then
        jq_data[key] = 2
        if (jq_data[key] or 0) >= 2 then
            Guard.clearTaskTemp(jq_data, key)
            jq_data[key] = 2
        end
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        Player.sendmsgEx(play, "|【"..(_config.name or "任务").."】#249|完成#57")
        if npcid then Guard.closeNpc(play, npcid) end
        if _config.ch then
            Player.title_give(play, _config.ch)
        end
        sendluamsg(play,101,1005,0,0,"rwwc")
        local reward = _config.jl or _config.rwjl
        if reward then
            Player.rwjl(play, reward, (_config.name or "剧情任务").."奖励", 1)
        end
    else
        jq_data[key] = 0
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        Player.sendmsgEx(play, "任务失败#57")
    end
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
    local __guardAllowedActions = Guard.newActionSet({1})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end

    if ew == 1 then
        local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
        local key = "npc_654"
        if jq_data[key] and jq_data[key] >= 2 then
            Player.sendmsgEx(play, "你已经完成#57|【"..(_config.name or "该任务").."】#249|")
            return
        end

        local base_map = _config.map
        if not base_map or base_map == "" then
            Player.sendmsgEx(play, "地图配置缺失#57")
            if npcid then Guard.closeNpcAndAuto(play, npcid) end
            return
        end
        local dtm = getbaseinfo(play,1).."_npc654"
        if checkmirrormap(dtm) then
            delmirrormap(dtm)
        end

        local limit = _config.time or 600
        addmirrormap(base_map, dtm, (_config.name or "赛跑"), limit, "xtc")

        local sx = (_config.start_pos and _config.start_pos[1]) or 0
        local sy = (_config.start_pos and _config.start_pos[2]) or 0
        local ex = (_config.end_pos and _config.end_pos[1]) or 0
        local ey = (_config.end_pos and _config.end_pos[2]) or 0
        if sx <= 0 or sy <= 0 or ex <= 0 or ey <= 0 then
            Player.sendmsgEx(play, "起点/终点配置缺失#57")
            if npcid then Guard.closeNpcAndAuto(play, npcid) end
            return
        end

        local back = {getbaseinfo(play,3), getbaseinfo(play,4), getbaseinfo(play,5)}
        jq_data[key] = 1
        jq_data[key.."_st"] = os.time()
        jq_data[key.."_back"] = back
        jq_data[key.."_run"] = 1
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)

        mapmove(play, dtm, sx, sy, 2)

        local mob = genmonex(dtm, sx, sy, _config.mob or "赛跑怪", 1, 1, 0, 54, "", 0)
        if mob then
            monmission(mob[1], ex, ey, 0)
        end

        setenvirontimer(dtm, 1, 1, "@npc_654_dsq,"..play..","..dtm)
        senddelaymsg(play, "剩余时间%s", limit, 250, 1, "@npc_654_timeout")
    end
end

function npc_654_dsq(xt, play, dtm, data)
    if getplaycount(dtm,false,true) == "0" then
        setenvirofftimer(dtm,1)
        if checkmirrormap(dtm) then
            delmirrormap(dtm)
        end
        return
    end

    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local key = "npc_654"
    if not jq_data[key] or jq_data[key] ~= 1 or jq_data[key.."_run"] ~= 1 then
        return
    end

    local ex = (_config.end_pos and _config.end_pos[1]) or 0
    local ey = (_config.end_pos and _config.end_pos[2]) or 0
    local limit = _config.time or 600
    local start = jq_data[key.."_st"] or 0
    if limit > 0 and (os.time() - start) > limit then
        npc_654_finish(play, dtm, false)
        return
    end

    if getbaseinfo(play,3) == dtm then
        local px = getbaseinfo(play,4)
        local py = getbaseinfo(play,5)
        if math.abs(px - ex) <= 2 and math.abs(py - ey) <= 2 then
            npc_654_finish(play, dtm, true)
            return
        end
    end

    local mons = getobjectinmap(dtm, ex, ey, 1, 2)
    if mons and #mons > 0 then
        npc_654_finish(play, dtm, false)
        return
    end
end

function npc_654_timeout(play)
    Player.sendmsgEx(play, "任务时间已到#57")
end

return npc




