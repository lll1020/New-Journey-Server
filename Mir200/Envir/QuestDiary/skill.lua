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

local linggen_mag = {
    [1017] = true,
    [1018] = true,
    [1019] = true,
    [1020] = true,
    [1023] = true,
    [1024] = true,
    [1025] = true,
    [1026] = true,
    [1027] = true,
    [1028] = true,
}

local function _talent_tree_skill_cast(play, skill_id, target_object, x, y)
    if not TalentTreeSkills or not TalentTreeSkills.onSkillCast then
        return false
    end
    local ok, result = pcall(TalentTreeSkills.onSkillCast, play, skill_id, target_object, x, y)
    if not ok then
        return false
    end
    return result
end

function beginmagic(play, maigicID, maigicName, targetObject, x, y)
    local skill_id = tonumber(maigicID) or 0
    if linggen_mag[skill_id] then
        return _talent_tree_skill_cast(play, skill_id, targetObject, x, y)
    end
end
