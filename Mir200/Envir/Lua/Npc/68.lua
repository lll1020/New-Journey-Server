npc = {}

function npc.main(play, npcid)
    if Player and Player.sendmsgEx then
        Player.sendmsgEx(play, "旧灵根试炼已停用，请使用天赋树")
    end
end

function npc.link(play, npcid, action, p3, msg_data)
    if Player and Player.sendmsgEx then
        Player.sendmsgEx(play, "旧灵根试炼已停用，请使用天赋树")
    end
end

function syt_jrdt_602(play, idx)
    return false
end

function npc_68_fbjs(play)
    return false
end

function npc_68_fb_end(play)
    return false
end

return npc
