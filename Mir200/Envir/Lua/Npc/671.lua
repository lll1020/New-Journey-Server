npc = {}


--地狱使者

local _config = Guard.getConfig("npc_671")


function npc.main(play,npcid)
    if not _config then
        return
    end
    local data = {}
    data["T_dljq"] = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    sendluamsg(play,100,npcid,0,0,tbl2json(data))
end

local function npc_671_savepos(play)
    local map = getbaseinfo(play,3)
    local x = getbaseinfo(play,4)
    local y = getbaseinfo(play,5)
    setplaydef(play, "S$npc671_back", map..","..x..","..y)
end

local function npc_671_back(play)
    local back = getplaydef(play, "S$npc671_back")
    if back and back ~= "" then
        local parts = split(back, ",")
        local map = parts[1]
        local x = tonumber(parts[2]) or 0
        local y = tonumber(parts[3]) or 0
        if map and map ~= "" and x > 0 and y > 0 then
            mapmove(play, map, x, y, 2)
        end
    end
    setplaydef(play, "S$npc671_back", "")
end

local function npc_671_finish_level(play, dtm, level)
    local details = _config.details or {}
    local cfg = details[level]

    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    jq_data["npc_671_lv"] = level
    jq_data["npc_671_cur"] = nil
    Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)

    if cfg and cfg.jl then
        Player.rwjl(play, cfg.jl, (_config.name or "剧情任务").."奖励", 1)
    end
    npc_671_back(play)
    if dtm and checkmirrormap(dtm) then
        setenvirofftimer(dtm,1)
        delmirrormap(dtm)
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
    local __guardAllowedActions = Guard.newActionSet({1,2,3})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end

    local details = _config.details or {}
    local total = #details
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local key = "npc_671"

    if ew == 1 then
        if jq_data[key] and jq_data[key] >= 2 then
            Player.sendmsgEx(play, "你已经完成【"..(_config.name or "该任务").."】#57")
            return
        end

        -- local cur = jq_data["npc_671_cur"]
        -- if cur and cur > 0 then
        --     Player.sendmsgEx(play, "正在挑战中，请先完成当前层#57")
        --     return
        -- end

        local next_lv = (jq_data["npc_671_lv"] or 0) + 1
        if next_lv > total then
            Player.sendmsgEx(play, "已完成全部挑战，请领取最终奖励#57")
            return
        end

        if next_lv > 1 then
            local prev_done = jq_data["npc_671_lv"] or 0
            if prev_done < (next_lv - 1) then
                Player.sendmsgEx(play, "请先成功挑战上一层#57")
                return
            end
        end

        local cfg = details[next_lv]
        if not cfg or not cfg.fb_map or not cfg.mob then
            Player.sendmsgEx(play, "挑战配置缺失#57")
            return
        end

        npc_671_savepos(play)
        local dtm = getbaseinfo(play,1).."_npc671"
        if checkmirrormap(dtm) then
            delmirrormap(dtm)
        end
        addmirrormap(cfg.fb_map, dtm, (_config.name or "挑战")..next_lv.."层", 300, "xtc")
        mapmove(play, dtm, 29, 27, 2)
        genmonex(dtm, 29, 31, cfg.mob, 1, 1, 0, 54, "", 0)

        jq_data["npc_671_cur"] = next_lv
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)

        setenvirontimer(dtm, 1, 1, "@npc_671_dsq,"..play..","..dtm)
        return
    end


    if ew == 3 then
        local total_get = 0
        local details = _config.details or {}
        for i = 1, #details do
            local cfg = details[i]
            local item = cfg and cfg.jl and cfg.jl[1] and cfg.jl[1][1]
            if item and item ~= "" then
                local name, num = Player.checkItemNumByTable(play, {{item,1}})
                if not name then
                    Guard.consumeCost(play, {{item,1}}, ",回收信物")
                    total_get = total_get + 1
                end
            end
        end
        local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
        jq_data["npc_671_token"] = (jq_data["npc_671_token"] or 0) + total_get
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        Player.sendmsgEx(play, string.format("已回收信物：%d 个#57", total_get))
        Player.sendmsgEx(play, string.format("共计已回收信物：%d 个#57", jq_data["npc_671_token"] or 0))
        return
    end

    if ew == 2 then
        if jq_data[key] and jq_data[key] >= 2 then
            Player.sendmsgEx(play, "你已经完成【"..(_config.name or "该任务").."】#57")
            return
        end
        local npc_671_token = jq_data["npc_671_token"] or 0
        if total > 0 and npc_671_token >= total then
            -- 本NPC不清理临时字段，保留层数和回收进度
            jq_data[key] = 2
            Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
            Player.sendmsgEx(play, "【"..(_config.name or "任务").."】完成#57")
            sendluamsg(play,101,1005,0,0,"rwwc")
            local reward = _config.jl or _config.rwjl
            if reward then
                Player.rwjl(play, reward, (_config.name or "剧情任务").."奖励", 1)
            end
            sendluamsg(play,100,npcid,1,2,"")
        else
            Player.sendmsgEx(play, string.format("当前进度：%d/%d#57", npc_671_token, total))
        end
    end
end

function npc_671_dsq(xt,play,dtm,data)
    if getplaycount(dtm,false,true) == "0" then
        setenvirofftimer(dtm, 1)
        if checkmirrormap(dtm) then
            delmirrormap(dtm)
        end
        return
    end

    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local cur = jq_data["npc_671_cur"] or 0
    if cur <= 0 then
        return
    end

    if getmoncount(dtm,-1,true) < 1 then
        npc_671_finish_level(play, dtm, cur)
    end
end

return npc
