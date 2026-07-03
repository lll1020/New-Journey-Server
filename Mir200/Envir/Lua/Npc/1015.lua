local KuafuMapEntry = include("lua/LuaLib/kuafu_map_entry.lua")
local npc = {}

function npc.main(play, npcid)
    KuafuMapEntry.main(play, npcid)
end

function npc.link(play, npcid, p2, p3)
    KuafuMapEntry.link(play, npcid, p2 or p3)
end

return npc
