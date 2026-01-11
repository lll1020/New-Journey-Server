npc = {}


--npc名称：
--npc功能：
local _config = Guard.getConfig("npc_75")

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
    local __guardAllowedActions = Guard.newActionSet({1})
    if not Guard.ensureActionAllowed(play, npcid, p2, __guardAllowedActions) then
        return
    end
    local json_data = json2tbl(msgData)
    if p2 == 1 then
        if json_data.idx < 1 or json_data.idx > #_config.details then
            return
        end
        local equipname = Player.getEquipNameByPos(play, _config.details[json_data.idx].where)
        if equipname ~= _config.details[json_data.idx].now then
            Player.sendmsgEx(play, "请先装备".._config.details[json_data.idx].now.."#249|进行升级#57")
            return
        end
        if equipname == _config.details[json_data.idx].give then
            Player.sendmsgEx(play, "你的".._config.details[json_data.idx].name.."已经是最高级别，无法继续升级#57")
            return
        end
        local name, num = Player.checkItemNumByTable(play, _config.details[json_data.idx].cost)
        if name then
            Player.sendmsgEx(play, string.format("你的|%s#249|不足|%d#249", name, num))
            return
        end
        Player.takeItemByTable(play, _config.details[json_data.idx].cost, ",装备解封",nil)
        changeitemidx(play,getiteminfo(play,linkbodyitem(play,_config.details[json_data.idx].where),1),getstditeminfo(_config.details[json_data.idx].give, ConstCfg.stditeminfo.idx))
        Player.sendmsgEx(play,  "恭喜你，".._config.details[json_data.idx].name.."升级成功，当前为".._config.details[json_data.idx].give.."#249|")
        sendluamsg(play,100,npcid,1,0,"")
        sendluamsg(play,101,1005,0,0,"qhcg")
        
    end
end



return npc

