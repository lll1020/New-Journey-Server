npc = {}


--升级1

local _config = Guard.getConfig("npc_52")

function npc.main(play,npcid)
    sendluamsg(play,100,npcid,0,0,"")
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
        local equipname = Player.getEquipNameByPos(play, _config.where)
        if equipname ~= _config.now then
            Player.sendmsgEx(play, "请先装备".._config.now.."#249|进行升级#57")
            return
        end
        if equipname == _config.give then
            Player.sendmsgEx(play, "你的斗笠已经是最高级别，无法继续升级#57")
            return
        end
        local name, num = Player.checkItemNumByTable(play, _config.cost)
        if name then
            Player.sendmsgEx(play, string.format("你的|%s#249|不足|%d#249", name, num))
            return
        end
        Player.takeItemByTable(play, _config.cost, ",升级葫芦",nil)
        changeitemidx(play,getiteminfo(play,linkbodyitem(play,_config.where),1),getstditeminfo(_config.give, ConstCfg.stditeminfo.idx))
        Player.sendmsgEx(play,  "恭喜你，葫芦升级成功，当前葫芦为".._config.give.."#249|")
        sendluamsg(play,100,npcid,1,0,"")
        sendluamsg(play,101,1005,0,0,"qhcg")
    end
end


return npc