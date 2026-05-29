npc = {}


--

local _config = Guard.getConfig("npc_43")

local _xyl_jhch_view_flag = "N$查看江湖称号"
function npc.main(play,npcid)
    setplaydef(play, _xyl_jhch_view_flag, 1)
    Player.trySyncSecondContinentXyl(play)
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
            Player.sendmsgEx(play, "你已拥有最高等级#57|【称号】#218|")
            return
        end
        local nextLevel = dj_num + 1
        if not (_config.cost and _config.cost[nextLevel] and _config.ch and _config.ch[nextLevel]) then
            Player.sendmsgEx(play, "称号配置缺失，请联系管理员#57")
            return
        end
        local isFreeGuide = dj_num <= 0
        if not isFreeGuide then
            local name, num = Player.checkItemNumByTable(play, _config.cost[nextLevel])
            if name then
                Player.sendmsgEx(play, string.format("你的#57|【%s】#218|不足：#57|【%d】#218|", name, num))
                return
            end
            Player.takeItemByTable(play, _config.cost[nextLevel], ",江湖称号",nil)
        end
        DeleteAllTitle(play)
        Player.title_give(play, _config.ch[nextLevel])
        setplaydef(play, VarCfg["U_江湖称号"], nextLevel)
        Player.trySyncSecondContinentXyl(play)
        Player.sendmsgEx(play, string.format("恭喜你，获得了|【%s】#218|称号！", _config.ch[nextLevel]))
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
