npc = {}


--npc名称：升级切割
--npc功能：
local _config = Guard.getConfig("npc_9")

function npc.main(play,npcid)
    sendluamsg(play,100,npcid,0,0,"")
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
        local idx = tonumber(p3)
        if not idx or not _config.where[idx] or not _config.config[idx] then
            Player.sendmsgEx(play, "参数错误#57")
            return
        end
        p3 = idx
        local equipLevel = Player.getEquipFieldByPos(play, _config.where[p3], 1) or 0
        if equipLevel == 0 then
            Player.sendmsgEx(play,  "请先装备#57|【对应装备】#249|")
            return
        end
        equipLevel = tonumber(equipLevel)
        if equipLevel >= _config.max_level then
            Player.sendmsgEx(play,  "你的装备等级已达到#57|【"..equipLevel.."级】#249|，无需再提升#57")
            return
        end
        local config = _config.config[p3][equipLevel]
        local name, num = Player.checkItemNumByTable(play, config.cost)
        if name then
            Player.sendmsgEx(play, string.format("你的#57|【%s】#249|不足：#57|【%d】#249|", name, num))
            return
        end
        Player.takeItemByTable(play, config.cost, ",升级特戒",nil)

        changeitemidx(play,getiteminfo(play,linkbodyitem(play,_config.where[p3]),1),getstditeminfo(config.give, ConstCfg.stditeminfo.idx))
        Player.sendmsgEx(play,  "恭喜你，装备提升成功，当前装备等级为|【"..(equipLevel + 1).."级】#249|")
        sendluamsg(play,100,npcid,1,0,"")
        sendluamsg(play,101,1005,0,0,"qhcg")
        if rwcf[npcid][1] == getplaydef(play,VarCfg.U_zxrw[1]) then 
            Player.zxrw_wancheng(play, rwcf[npcid][1], "任务") --完成任务
            sendluamsg(play, 101, 9999, 0, 0, "npc_"..npcid)
        end


    elseif p2 == 2 and false then
        if p3 == 1 then
            giveonitem(play,_config.where[p3],"复活戒指",1)
        elseif p3 == 2 then
            giveonitem(play,_config.where[p3],"麻痹戒指",1)
        end
        sendluamsg(play,100,npcid,1,0,"")
    end
end


return npc
