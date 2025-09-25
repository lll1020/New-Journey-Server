npc = {}
--npc名称：升级切割
--npc功能：
local _config = teshudata["npc_9"]

function npc.main(play,npcid)
    sendluamsg(play,100,npcid,0,0,"")
end

function npc.link(play, npcid, p2, p3, msgData)

    if p2 == 1 then
        local equipLevel = Player.getEquipFieldByPos(play, _config.where[p3], 1) or 0
        if equipLevel == 0 then
            Player.sendmsgEx(play,  "请先装备#57")
            return
        end
        equipLevel = tonumber(equipLevel)
        if equipLevel >= _config.max_level then
            Player.sendmsgEx(play,  "你的装备等级已经达到了"..equipLevel.."级，无需再提升#57")
            return
        end
        local config = _config.config[p3][equipLevel]
        local name, num = Player.checkItemNumByTable(play, config.cost)
        if name then
            Player.sendmsgEx(play, string.format("你的|%s#249|不足|%d#249", name, num))
            return
        end
        Player.takeItemByTable(play, config.cost, ",升级斗笠",nil)

        changeitemidx(play,getiteminfo(play,linkbodyitem(play,_config.where[p3]),1),getstditeminfo(config.give, ConstCfg.stditeminfo.idx))
        Player.sendmsgEx(play,  "恭喜你，装备提升成功，当前装备等级为"..(equipLevel + 1).."级")
        sendluamsg(play,100,npcid,1,0,"")
        sendluamsg(play,101,1005,0,0,"qhcg")


    elseif p2 == 2 then
        if p3 == 1 then
            giveonitem(play,_config.where[p3],"复活戒指",1)
        elseif p3 == 2 then
            giveonitem(play,_config.where[p3],"麻痹戒指",1)
        end
        sendluamsg(play,100,npcid,1,0,"")
    end
end


return npc