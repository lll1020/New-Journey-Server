local TalentTree = include("lua/LuaLib/talent_tree.lua")

npc = {}

local TALENT_TREE_MAINLINE_ID = 22
local TALENT_TREE_GATE_TIP = "请先跟随主线任务到达【升级一次灵根核心】后再开启灵根功能"

local function _has_talent_tree_task_access(play)
    local current = tonumber(getplaydef(play, VarCfg.U_zxrw[1]) or 0) or 0
    return current >= TALENT_TREE_MAINLINE_ID
end

local function _ensure_talent_tree_task_access(play)
    if _has_talent_tree_task_access(play) then
        return true
    end
    Player.sendmsgEx(play, TALENT_TREE_GATE_TIP)
    return false
end

function npc.main(play, npcid)
    if TalentTree and TalentTree.main then
        if tonumber(npcid) == 0 and TalentTree.syncCache then
            return TalentTree.syncCache(play, 22)
        end
        if not _ensure_talent_tree_task_access(play) then
            return
        end
        return TalentTree.main(play, npcid or 22)
    end
end

function npc.link(play, npcid, action, p3, msg_data)
    if TalentTree and TalentTree.link then
        if not _ensure_talent_tree_task_access(play) then
            return
        end
        return TalentTree.link(play, npcid or 22, action, p3, msg_data)
    end
end

function Login_lg(play)
    if TalentTree and TalentTree.onLogin then
        return TalentTree.onLogin(play)
    end
end

function TMLP_refresh_linggen_bonus(play)
    if TalentTree and TalentTree.onLogin then
        return TalentTree.onLogin(play)
    end
end

function LingGenGrantBasicUnlockChance(play, count)
    if TalentTree and TalentTree.ensure then
        TalentTree.ensure(play)
    end
    return true
end

-- Keep legacy combat callbacks harmless while the talent tree replaces them.
function npc.lgcf(play, zt, damage, target, mode)
    return 0
end

return npc
