npc = {}

-- npc_78 暂时停用，保留脚本文件避免外部引用报错。

function npc.main(play, npcid)
    Player.sendmsgEx(play, "该功能暂未开放#57")
    sendluamsg(play, 100, npcid, 0, 0, tbl2json({disabled = 1}))
end

function npc.link(play, npcid, p2, p3, msgData)
    if not Guard.ensurePlayer(play, npcid) then return end
    Player.sendmsgEx(play, "该功能暂未开放#57")
    sendluamsg(play, 100, npcid, p2 or 0, p3 or 0, tbl2json({disabled = 1}))
end

return npc