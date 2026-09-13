local TalentTree = include("lua/LuaLib/talent_tree.lua")

npc = {}

function npc.main(play, npcid)
    if TalentTree and TalentTree.main then
        return TalentTree.main(play, npcid or 22)
    end
end

function npc.link(play, npcid, action, p3, msg_data)
    if TalentTree and TalentTree.link then
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
