npc = {}




function npc.main(play,npcid)
    sendluamsg(play,100,npcid,0,0,tbl2json({num = getplaydef(play, VarCfg["J_醉意值"])}))
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

    if ew == 1 then -- 进地图
        if hasbuff(play,20103) then
            map(play, "酒仙秘境")
            Player.sendmsgEx(play, "你带着醉酒狂魔舞效果进入了|【酒仙秘境】#249")
            sendluamsg(play, 101, 9999, 0, 0, "npc_71")
        else
            Player.sendmsgEx(play, "进入#57|【酒仙秘境】#249|需要携带醉酒狂魔舞效果#57")
        end
    end
end


return npc