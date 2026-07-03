local Entry = include("lua/LuaLib/rikaguaji_entry.lua")
local npc = {}
function npc.main(play, npcid) Entry.main(play, npcid) end
function npc.link(play, npcid, p2, p3) Entry.link(play, npcid, p2 or p3) end
return npc
