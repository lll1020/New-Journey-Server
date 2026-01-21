npc = {}


--npc名称：
--npc功能：
local _config = Guard.getConfig("npc_12")

function npc.main(play,npcid)
    local data = {}
    data["dh_num"] = getplaydef(play, VarCfg["J_今日材料兑换"])
    sendluamsg(play,100,npcid,0,0,tbl2json(data))
end

function npc.link(play, npcid, p2, p3, msgData)

    -- npc_guard: 入参校验
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local __guardAction = Guard.normalizeAction(play, npcid, p2)
    if __guardAction == nil then
        return
    end
    p2 = __guardAction
    -- npc_guard: 操作白名单（优化：限定合法操作编号）
    local __guardAllowedActions = Guard.newActionSet({1, 2})
    if not Guard.ensureActionAllowed(play, npcid, p2, __guardAllowedActions) then
        return
    end

    if p2 == 1 then
        local dh_num = getplaydef(play, VarCfg["J_今日材料兑换"])
        if dh_num >= _config.xg_day then
            Player.sendmsgEx(play, "提示:#251|你今天的兑换次数已经用完了...")
            return
        end
        local config = _config.sd[p3]
        local name, num = Player.checkItemNumByTable(play, config.cost)
        if name then
            Player.sendmsgEx(play, string.format("你的|%s#249|不足|%d#249", name, num))
            return
        end
        Player.takeItemByTable(play, config.cost, ",材料兑换",nil)
        dh_num = dh_num + 1
        setplaydef(play, VarCfg["J_今日材料兑换"], dh_num)
        Player.rwjl(play,{{config.give,1}},"材料兑换",nil,1)
        Player.sendmsgEx(play, "兑换成功")

        local data = {}
        data["dh_num"] = getplaydef(play, VarCfg["J_今日材料兑换"])
        sendluamsg(play,100,npcid,1,0,tbl2json(data))
    elseif p2 == 2 then

    end
end


return npc