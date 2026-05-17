npc = {}


--修复轩辕剑

local _config = Guard.getConfig("npc_601")
function npc.main(play,npcid)
    if not _config then
        return
    end
    sendluamsg(play,100,npcid,0,0,"")
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
        if not (_config.cost and _config.details and _config.details.ch) then
            Player.sendmsgEx(play, "配置缺失#57")
            return
        end
        if not checktitle(play, _config.details.ch) then
            local name, num = Player.checkItemNumByTable(play, _config.cost)
            if name then
                Player.sendmsgEx(play, string.format("你的#57|【%s】#218|不足：#57|【%d】#218|", name, num))
                return
            end
            Player.takeItemByTable(play, _config.cost, ",修复轩辕剑",nil)


            Player.title_give(play, _config.details.ch)
            Player.sendmsgEx(play, "轩辕剑修复成功，获得称号|【".._config.details.ch.."】#218|")
            sendluamsg(play,101,1005,0,0,"rwwc")
            sendluamsg(play,100,npcid,1,0,"")
            Guard.closeNpc(play, npcid)
        else
            Player.sendmsgEx(play, "你已经拥有轩辕剑称号，无需修复#57")
            return
        end
    end
end

return npc

