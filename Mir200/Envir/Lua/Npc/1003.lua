
npc = {}


--




function npc.main(play,npcid)
    local data = {}
    data["T_data"] = Player.getJsonTableByVar(play, VarCfg.T_szjl)
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
    local T_data = Player.getJsonTableByVar(play, VarCfg.T_szjl)
    local _config = Guard.getConfig("npc_"..tostring(npcid))
    if ew == 1 then ----更换装扮
        T_data.dqzb = T_data.dqzb or 0
        T_data.yjs = T_data.yjs or {}
        if T_data.yjs["".._config.idx] and T_data.yjs["".._config.idx] == 1 then
            Player.sendmsgEx(play, "你已拥有该时装，无需解锁")
            return
        end
        local name, num = Player.checkItemNumByTable(play, _config.cost)
        if name then
            Player.sendmsgEx(play, string.format("你的|%s#249|不足|%d#249", name, num))
            return
        end
        Player.takeItemByTable(play, _config.cost, ",时装解锁",nil)
        T_data.yjs["".._config.idx] = 1
        Player.setJsonVarByTable(play, VarCfg.T_szjl, T_data)
        Player.sendmsgEx(play, "恭喜你，时装解锁成功")
        local data = {}
        data["T_data"] = T_data
        sendluamsg(play,100,npcid,1,0,tbl2json(data))
    end
end



return npc