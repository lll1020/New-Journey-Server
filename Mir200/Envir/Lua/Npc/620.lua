npc = {}


--修复轩辕剑

local _config = Guard.getConfig("npc_620")

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
    local __guardAllowedActions = Guard.newActionSet({1})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end

    if ew == 1 then
        local T_dljq = Player.getJsonTableByVar(play, VarCfg.T_dljq)
        if not T_dljq["npc_620"] or T_dljq["npc_620"] < 2 then
            if not _config.cost then
                Player.sendmsgEx(play, "配置缺失#57")
                if npcid then Guard.closeNpcAndAuto(play, npcid) end
                return
            end
            local name, num = Player.checkItemNumByTable(play, _config.cost)
            if name then
                Player.sendmsgEx(play, string.format("你的#57|【%s】#218|不足：#57|【%d】#218|", name, num))
                Player.sendmsgEx(play, "阴阳玉佩合成失败#57")
                return
            end
            Player.takeItemByTable(play, _config.cost, ",阴阳玉佩",nil)
            T_dljq["npc_620"] = 2
            Player.setJsonVarByTable(play, VarCfg.T_dljq, T_dljq)
            if _config.give and #_config.give > 0 then
                Player.rwjl(play, _config.give, tostring(_config.name or "npc_620") .. "_reward", 1, 0)
            end
            sendluamsg(play,100,npcid,1,2,"")
            Player.sendmsgEx(play, "阴阳玉佩合成成功，获得|【阴阳玉佩】#218|")
            sendluamsg(play,101,1005,0,0,"rwwc")
        else
            Player.sendmsgEx(play, "你已经拥有阴阳玉佩")
            return
        end
    end
end

return npc

