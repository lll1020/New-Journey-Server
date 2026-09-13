--------------------对目标使用技能触发-------------------野蛮
function magtagfunc27(play, Target)
end
--------------------对目标使用技能触发-------------------开天
function magtagfunc66(play, Target)
end
--------------------对目标使用技能触发-------------------十步一杀
function magselffunc82(play)
end
--------------------对目标使用技能触发-------------------施毒术
function magtagfunc6(play, Target)
end
--------------------对目标使用技能触发-------------------隐身术
function magselffunc18(play, Target)
end
function magselffunc26(play) ---烈火
end
function magselffunc66(play) ---开天
end
function magselffunc56(play) ---逐日
end

local function _talent_tree_skill_cast(play, skill_id)
    if TalentTreeSkills and TalentTreeSkills.onSkillCast then
        TalentTreeSkills.onSkillCast(play, skill_id)
    end
end

function magselffunc1017(play)
    _talent_tree_skill_cast(play, 1017)
end

function magselffunc1018(play)
    _talent_tree_skill_cast(play, 1018)
end

function magselffunc1019(play)
    _talent_tree_skill_cast(play, 1019)
end

function magselffunc1020(play)
    _talent_tree_skill_cast(play, 1020)
end

function magselffunc1023(play)
    _talent_tree_skill_cast(play, 1023)
end

function magselffunc1024(play)
    _talent_tree_skill_cast(play, 1024)
end

function magselffunc1025(play)
    _talent_tree_skill_cast(play, 1025)
end

function magselffunc1026(play)
    _talent_tree_skill_cast(play, 1026)
end

function magselffunc1027(play)
    _talent_tree_skill_cast(play, 1027)
end

function magselffunc1028(play)
    _talent_tree_skill_cast(play, 1028)
end
