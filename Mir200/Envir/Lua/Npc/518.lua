local Atlas = rawget(_G, "Atlas") or dofile("Envir/Lua/LuaLib/atlas.lua")
local npc = {}

function npc.main(play)
    if Atlas and Atlas.main then
        Atlas.main(play, 0, 0, "")
    end
end

function npc.link(play, npcid, p2, p3, msgData)
    if Atlas and Atlas.main then
        Atlas.main(play, p2, p3, msgData)
    end
end

return npc
