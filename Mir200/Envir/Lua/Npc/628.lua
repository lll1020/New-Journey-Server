npc = {}


--讨伐妄灾

local _config = Guard.getConfig("npc_628")



function npc.main(play,npcid)
    if not _config then
        return
    end
    local data = {}
    data["T_dljq"] = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    sendluamsg(play,100,npcid,0,0,tbl2json(data))
end

local function npc_628_spawn_main(dtm)
    local mob_name = _config.mob or "怪物"
    genmonex(dtm, 32, 36, mob_name, 1, 1, 0, 54, "", 0)
end

local function npc_628_spawn_x(dtm)
    local mob_name = _config.mob_x or "怪物[目标]"
    genmonex(dtm, 32, 36, mob_name, 1, 1, 0, 54, "", 0)
end

local function npc_628_count_by_name(dtm, name)
    if not name or name == "" then
        return 0
    end
    local list = getobjectinmap(dtm, 0, 0, 999, 2)
    local cnt = 0
    if list then
        for _, v in ipairs(list) do
            if getbaseinfo(v,1) == name then
                cnt = cnt + 1
            end
        end
    end
    return cnt
end

local function npc_628_kill_by_name(play, dtm, name)
    if not name or name == "" then
        return
    end
    local list = getobjectinmap(dtm, 0, 0, 999, 2)
    if list then
        for _, v in ipairs(list) do
            if getbaseinfo(v,1) == name then
                humanhp(v, "-", 999999999, 107, 0, play)
            end
        end
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
        local key = "npc_628"
        if jq_data[key] and jq_data[key] >= 2 then
            Player.sendmsgEx(play, "任务已完成，无法再次进入#57")
            return
        end

        if not Guard.ensureCost(play, _config.cost) then
            return
        end
        Guard.consumeCost(play, _config.cost, ","..(_config.name or "剧情任务"))
        jq_data[key] = 1
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)

        npc_628_enter(play)
    end
end

function npc_628_savepos(play)
    local map = getbaseinfo(play,3)
    local x = getbaseinfo(play,4)
    local y = getbaseinfo(play,5)
    setplaydef(play, "S$npc628_back", map..","..x..","..y)
end

function npc_628_back(play)
    local back = getplaydef(play, "S$npc628_back")
    if back and back ~= "" then
        local parts = split(back, ",")
        local map = parts[1]
        local x = tonumber(parts[2]) or 0
        local y = tonumber(parts[3]) or 0
        if map and map ~= "" and x > 0 and y > 0 then
            mapmove(play, map, x, y, 2)
        end
    end
    setplaydef(play, "S$npc628_back", "")
end

function npc_628_enter(play)
    npc_628_savepos(play)

    local dtm = getbaseinfo(play,1).."_npc628"
    if checkmirrormap(dtm) then
        delmirrormap(dtm)
    end
    local base_map = _config.fb_map or "mwsl"
    addmirrormap(base_map, dtm, _config.name or "副本", 300, "xtc")
    mapmove(play, dtm, 29, 27, 2)

    if hasbuff(play, 20113) then
        npc_628_spawn_main(dtm)
    else
        npc_628_spawn_x(dtm)
    end

    startautoattack(play)
    setenvirontimer(dtm, 1, 1, "@npc_628_dsq,"..play..","..dtm)
    senddelaymsg(play, "距离副本结束剩余%s", 300, 250, 1, "@npc_628_timeout")
end

function npc_628_dsq(xt,play,dtm,data)
    if getplaycount(dtm,false,true) == "0" then
        setenvirofftimer(dtm, 1)
        delmirrormap(dtm)
        return
    end

    if getmoncount(dtm,-1,true) < 1 then
        setenvirofftimer(dtm, 1)
        npc_628_finish(play)
        if getbaseinfo(play,3) == dtm then
            npc_628_back(play)
        end
        delmirrormap(dtm)
    end

    local main_name = _config.mob or "怪物"
    local x_name = _config.mob_x or "怪物[目标]"

    if hasbuff(play, 20113) then
        if npc_628_count_by_name(dtm, main_name) < 1 then
            npc_628_spawn_main(dtm)
        end
        if npc_628_count_by_name(dtm, main_name) >= 1 and npc_628_count_by_name(dtm, x_name) >= 1 then
            npc_628_kill_by_name(play, dtm, x_name)
        end
    end

    
end

function npc_628_timeout(play)
    local dtm = getbaseinfo(play,1).."_npc628"
    if getbaseinfo(play,3) == dtm then
        if getmoncount(dtm,-1,true) < 1 then
            npc_628_finish(play)
        else
            Player.sendmsgEx(play, "副本时间结束#57")
        end
        npc_628_back(play)
        if checkmirrormap(dtm) then
            setenvirofftimer(dtm, 1)
            delmirrormap(dtm)
        end
    end
end

function npc_628_finish(play)
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local key = "npc_628"
    if jq_data[key] and jq_data[key] >= 2 then
        return
    end
    jq_data[key] = 2
    if (jq_data[key] or 0) >= 2 then
        Guard.clearTaskTemp(jq_data, key)
        jq_data[key] = 2
    end
    Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
    Player.sendmsgEx(play, "【"..(_config.name or "任务").."】完成#57")
    sendluamsg(play,101,1005,0,0,"rwwc")
    if _config.jl then
        Player.rwjl(play, _config.jl, (_config.name or "剧情任务").."奖励", 1)
    end
end

return npc


