npc = {}


--

local _config = Guard.getConfig("npc_43")

function npc.main(play,npcid)
    local data = {}
    data["dj_num"] = getplaydef(play, VarCfg["U_江湖称号"])
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
        local dj_num = getplaydef(play, VarCfg["U_江湖称号"])
        if dj_num >= _config.max_level then
            Player.sendmsgEx(play, "你已经拥有最高等级称号#57")
            return
        end
        local nextLevel = dj_num + 1
        local name, num = Player.checkItemNumByTable(play, _config.cost[nextLevel])
        if name then
            Player.sendmsgEx(play, string.format("你的|%s#249|不足|%d#249", name, num))
            return
        end
        Player.takeItemByTable(play, _config.cost[nextLevel], ",江湖称号",nil)
        DeleteAllTitle(play)
        Player.title_give(play, _config.ch[nextLevel])
        setplaydef(play, VarCfg["U_江湖称号"], nextLevel)
        Player.sendmsgEx(play, string.format("恭喜你，获得了|%s#249|称号！", _config.ch[nextLevel]))
        sendluamsg(play,100,npcid,1,0,"")
        sendluamsg(play,101,1005,0,0,"qhcg")
    end
end

function DeleteAllTitle(play)
    for index, value in ipairs(_config.ch) do
        deprivetitle(play, value)
    end
end

return npc