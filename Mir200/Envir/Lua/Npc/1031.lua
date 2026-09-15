npc = {}

local NEED_TITLE = "\212\214\182\242\201\177\202\214"
local TARGET_MAP = "\200\253\180\243\194\189\214\247\179\199"

function npc.main(play, npcid)
    if checktitle(play, NEED_TITLE) then
        mapmove(play, TARGET_MAP, 159, 231, 5)
        local data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
        data["npc_1031"] = 1
        local ok = pcall(Player.setJsonVarByTable, play, VarCfg.T_dljq, data)
        if ok and zxrw_try_finish_current_mainline then
            zxrw_try_finish_current_mainline(play, "gray_continent_enter")
        end
        addhpper(play, "=", 100)
        addmpper(play, "=", 100)
        return
    end
    Player.sendmsgEx(play, "\208\232\205\234\179\201\187\210\189\231\200\206\206\241\186\243\178\197\196\220\189\248\200\235\200\253\180\243\194\189#57")
end

function npc.link(play, npcid, ew, aid, data)
    npc.main(play, npcid)
end

return npc
