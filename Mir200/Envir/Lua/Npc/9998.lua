local npc = {}

function npc.main(play, npcid)
    local itemName = tostring(getplaydef(play, "S$改名卡道具") or "改名卡")
    if itemName == "" then
        itemName = "改名卡"
    end
    sendluamsg(play, 100, 9998, 0, 0, tbl2json({itemName = itemName}))
end

function npc.link(play, npcid, ew, aid, msgData)
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    if tonumber(ew) ~= 1 then
        return
    end
    local data = json2tbl(msgData) or {}
    local newName = tostring(data.name or "")
    if renamecardsubmit then
        renamecardsubmit(play, newName)
    else
        Player.sendmsgEx(play, "rename card submit not loaded#57")
    end
end

return npc
