npc = {}


--斗笠升级2

local _config = Guard.getConfig("npc_51")

function npc.main(play,npcid)
    if not Player.ensureThirdContinentPass(play, '请先完成#57|【灾厄入侵】#218|后再使用该功能#57') then
        return
    end
    local equipLevel = Player.getEquipFieldByPos(play, _config.where, 1) or 0
    equipLevel = tonumber(equipLevel)

    if equipLevel < 12 then
        Player.sendmsgEx(play,  "请先装备#57|【".._config.now.."】#218|进行升级#57")
        return
    elseif equipLevel == 12 then
        sendluamsg(play,100,npcid,0,0,"")
    elseif equipLevel > 12 then
        Player.sendmsgEx(play,  "你的斗笠已经升级了，当前斗笠为#57|【".._config.give.."】#218|")
        return
    end
end

function npc.link(play,npcid,ew,aid,data)
    if not Player.ensureThirdContinentPass(play, '请先完成#57|【灾厄入侵】#218|后再使用该功能#57') then
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

    if ew == 1 then --
        if not (_config.now and _config.cost and _config.give) then
            Player.sendmsgEx(play, "配置异常，请联系管理员#57")
            return
        end
        local equipname = Player.getEquipNameByPos(play, _config.where)
        if equipname ~= _config.now then
            Player.sendmsgEx(play, "请先装备#57|【".._config.now.."】#218|进行升级#57")
            return
        end
        if equipname == _config.give then
            Player.sendmsgEx(play, "你的斗笠已经是最高级别，无法继续升级#57")
            return
        end
        local name, num = Player.checkItemNumByTable(play, _config.cost)
        if name then
            Player.sendmsgEx(play, string.format("你的#57|【%s】#218|不足：#57|【%d】#218|", name, num))
            return
        end
        Player.takeItemByTable(play, _config.cost, ",升级斗笠",nil)
        changeitemidx(play,getiteminfo(play,linkbodyitem(play,_config.where),1),getstditeminfo(_config.give, ConstCfg.stditeminfo.idx))
        Player.sendmsgEx(play,  "恭喜你，斗笠升级成功，当前斗笠为|【".._config.give.."】#218|")
        sendluamsg(play,100,npcid,1,0,"")
        sendluamsg(play,101,1005,0,0,"qhcg")
    end
end


return npc
