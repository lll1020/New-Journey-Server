npc = {}


--羿射九日

local _config = Guard.getConfig("npc_675")


function npc.main(play,npcid)
    if not _config then
        return
    end
    local data = {}
    data["T_dljq"] = Player.getJsonTableByVar(play, VarCfg.T_dljq)
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
    local __guardAllowedActions = Guard.newActionSet({1,2})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end

    if ew == 1 then
        local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
        local key = "npc_675"
        local max_num = _config.max_num or 1
        local cnt = jq_data[key] or 0
        if cnt >= max_num then
            Player.sendmsgEx(play, "你已经完成【"..(_config.name or "该任务").."】#57")
            return
        end

        if _config.bag_cost then
            local name, num = Player.checkItemNumByTable(play, _config.bag_cost)
            if name then
                Player.sendmsgEx(play, string.format("你的|%s#249|不足|%d#249", name, num))
                return
            end
        end

        if not Guard.ensureCost(play, _config.cost) then
            return
        end
        Guard.consumeCost(play, _config.cost, ","..(_config.name or "剧情任务"))

        cnt = cnt + 1
        jq_data[key] = cnt
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        Player.sendmsgEx(play, string.format("提交进度：%d/%d#57", cnt, max_num))

        if cnt >= max_num then
            Player.sendmsgEx(play, "【"..(_config.name or "任务").."】完成#57")
            if _config.ch then
                Player.title_give(play, _config.ch)
            end
            sendluamsg(play,101,1005,0,0,"rwwc")
            local reward = _config.jl or _config.rwjl
            if reward then
                Player.rwjl(play, reward, (_config.name or "剧情任务").."奖励", 1)
            end
            sendluamsg(play,100,npcid,1,cnt,"")
        else
            Player.sendmsgEx(play, "提交成功#57")
            sendluamsg(play,100,npcid,1,cnt,"")
        end
        delattlist(play, "后羿射日")
        Login_jq_675(play)
    elseif ew == 2 then
        if _config.bag_cost then
            local name, num = Player.checkItemNumByTable(play, _config.bag_cost)
            if not name then
                Player.sendmsgEx(play, "你已经拥有所需物品#57")
                return
            end

            if not _config.hb or not Guard.ensureCost(play, _config.hb) then
                return
            end
            Guard.consumeCost(play, _config.hb, ","..(_config.name or "剧情任务"))

            for i = 1, #_config.bag_cost do
                local it = _config.bag_cost[i]
                if it and it[1] and it[2] then
                    giveitem(play, it[1], it[2])
                end
            end
            Player.sendmsgEx(play, "已为你补充所需物品#57")
        end
    end
end


function Login_jq_675(play)
    local attrs = {}
    local attrsstr = ""
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local key = "npc_675"
    local level = jq_data[key] or 0
    if level <= 0 then
        return
    end
    for v,k in ipairs(_config.attr) do
        attrs[k[1]] = k[2] * level
    end
    attrsstr = Player.getAttrTableToStr(attrs)
    addattlist(play, "后羿射日", "=", attrsstr, 1)
end
GameEvent.add(EventCfg.onLogin, Login_jq_675, "Login_后羿射日")


return npc



