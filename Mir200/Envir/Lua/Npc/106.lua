npc = {}
local TreasureBasin = rawget(_G, "__treasure_basin_module") or dofile("Envir/Lua/LuaLib/treasure_basin.lua")

-- 独立 106 NPC：打开聚宝盆任务修复界面。
function npc.main(play, npcid)
    TreasureBasin.main(play, npcid or 106)
end

-- 独立 106 NPC：只处理聚宝盆修复任务交互。
function npc.link(play, npcid, p2, p3, msgData)
    TreasureBasin.link(play, npcid or 106, p2, p3, msgData)
end

return npc
