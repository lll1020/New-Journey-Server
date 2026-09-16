npc = {}

local NEED_TITLE = "灾厄杀手"
local TARGET_MAP = "三大陆主城"

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
    Player.sendmsgEx(play, "需完成灰界任务后才能进入三大陆#57")
end

function npc.link(play, npcid, ew, aid, data)
    npc.main(play, npcid)
end

return npc
