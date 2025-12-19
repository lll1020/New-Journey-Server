npc = {}


--

local _config = Guard.getConfig("npc_47")

function npc.main(play,npcid)
    local data = {}
    data["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_藏宝图"])
    data["J_cs"] = getplaydef(play, VarCfg["J_今日藏宝图次数"])
    sendluamsg(play,100,npcid,0,0,tbl2json(data))
end

function npc.link(play,npcid,ew,aid,data)
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

    if ew == 1 then --
        local T_data = Player.getJsonTableByVar(play, VarCfg["T_藏宝图"])
        local J_cs = getplaydef(play, VarCfg["J_今日藏宝图次数"])
        if J_cs >= _config.max then
            Player.sendmsgEx(play, "今日藏宝图次数已达上限#249")
            return
        end

        local name, num = Player.checkItemNumByTable(play, _config.cost)
        if name then
            Player.sendmsgEx(play, string.format("你的|%s#249|不足|%d#249", name, num))
            return
        end

        local level = ransjstr(_config.weight, 1, 3)
        level = tonumber(level)
        J_cs = J_cs + 1
        
        T_data["map_"..J_cs] = _config.details[level].map[math.random(1,#_config.details)]
        T_data["level_"..J_cs] = level

        Player.setJsonVarByTable(play, VarCfg["T_藏宝图"], T_data)
        setplaydef(play, VarCfg["J_今日藏宝图次数"], J_cs)


        local data = {}
        data["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_藏宝图"])
        data["J_cs"] = getplaydef(play, VarCfg["J_今日藏宝图次数"])
        npc.main(play,npcid)
        
    end
end


return npc