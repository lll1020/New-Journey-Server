local StarChartSkills = {}

local data_var = VarCfg["T_ÐÇÏóÊ¥Í¼"]
local domain_cd_var = "N$star_chart_domain_cd"
local domain_end_var = "N$star_chart_domain_end"
local domain_pct_var = "N$star_chart_domain_pct"
local domain_reduce_var = "N$star_chart_domain_reduce"
local emperor_cd_var = "N$star_chart_emperor_cd"
local emperor_end_var = "N$star_chart_emperor_end"
local domain_attrs = "star_chart_active_domain"
local emperor_attrs = "star_chart_active_emperor"
local percent_attrs = {280, 281, 282, 283, 284, 285, 286, 287, 288, 289, 290, 291, 300}

local function int(value)
    return tonumber(value) or 0
end

local function get_data(play)
    return Player.getJsonTableByVar(play, data_var) or {}
end

local function get_config()
    return Guard.getConfig("npc_85") or {}
end

local function full_stage(data)
    local count = 0
    local config = get_config()
    for index = 1, #(config.stages or {}) do
        local stage = (data.stage or {})[tostring(index)] or {}
        if int(stage.full) == 1 then
            count = count + 1
        else
            break
        end
    end
    return count
end

local function get_skill_config(play)
    local config = get_config()
    local data = get_data(play)
    local stage = full_stage(data)
    return stage, (config.stage_skill or {})[stage] or {}
end

function StarChartSkills.sync_skills(play)
    if not play then
        return
    end
    local stage = full_stage(get_data(play))
    local enabled = {[1029] = stage >= 6, [1030] = stage >= 8}
    for skill_id, active in pairs(enabled) do
        if active then
            addskill(play, skill_id, 1)
            if getskillname and setmagicskillefft then
                setmagicskillefft(play, getskillname(skill_id), skill_id)
            end
        else
            delskill(play, skill_id)
        end
    end
end

local function attrs_to_string(percent, reduce)
    local attrs = {}
    for _, attr_id in ipairs(percent_attrs) do
        attrs[attr_id] = int(percent)
    end
    if int(reduce) > 0 then
        attrs[206] = int(reduce) * 100
    end
    return Player.getAttrTableToStr(attrs)
end

local function refresh_emperor(play)
    if int(getplaydef(play, emperor_end_var)) > os.time() then
        Player.add_attlist(play, emperor_attrs, "=", attrs_to_string(30, 0), 1)
    else
        Player.del_attlist(play, emperor_attrs)
    end
end

local function refresh_domain(play)
    if int(getplaydef(play, domain_end_var)) > os.time() then
        local percent = int(getplaydef(play, domain_pct_var))
        if percent > 0 then
            Player.add_attlist(play, domain_attrs, "=", attrs_to_string(percent, getplaydef(play, domain_reduce_var)), 1)
            return
        end
    end
    Player.del_attlist(play, domain_attrs)
    setplaydef(play, domain_pct_var, 0)
    setplaydef(play, domain_reduce_var, 0)
end

local function area_targets(play, cast_x, cast_y, range)
    local targets = {play}
    local members = getgroupmember(play) or {}
    local map_id = getbaseinfo(play, 3)
    local x = tonumber(cast_x) or tonumber(getbaseinfo(play, 4)) or 0
    local y = tonumber(cast_y) or tonumber(getbaseinfo(play, 5)) or 0
    local radius = math.max(0, math.floor(int(range) / 2))
    for _, member in ipairs(members) do
        if member and member ~= play and getbaseinfo(member, 3) == map_id then
            local mx = int(getbaseinfo(member, 4))
            local my = int(getbaseinfo(member, 5))
            if math.abs(mx - x) <= radius and math.abs(my - y) <= radius then
                targets[#targets + 1] = member
            end
        end
    end
    return targets
end

function StarChartSkills.cast(play, skill_id, target_object, cast_x, cast_y)
    if not play then
        return false
    end
    StarChartSkills.sync_skills(play)
    local stage, skills = get_skill_config(play)
    local now = os.time()
    skill_id = int(skill_id)

    if skill_id == 1029 then
        local domain = skills.domain
        if stage < 6 or not domain then
            return false
        end
        if now - int(getplaydef(play, domain_cd_var)) < int(domain.cd) then
            return false
        end
        setplaydef(play, domain_cd_var, now)
        local percent = int(domain.all_pct)
        local reduce = int(domain.reduce)
        if int(getplaydef(play, emperor_end_var)) > now then
            percent = percent * 2
            reduce = reduce * 2
        end
        for _, target in ipairs(area_targets(play, cast_x, cast_y, domain.range)) do
            setplaydef(target, domain_end_var, now + int(domain.duration))
            setplaydef(target, domain_pct_var, percent)
            setplaydef(target, domain_reduce_var, reduce)
            refresh_domain(target)
            delaygoto(target, math.max(1000, int(domain.duration) * 1000), "@star_chart_domain_active_tick")
        end
        return true
    end

    if skill_id == 1030 then
        local emperor = skills.emperor
        if stage < 8 or not emperor then
            return false
        end
        if now - int(getplaydef(play, emperor_cd_var)) < int(emperor.cd) then
            return false
        end
        setplaydef(play, emperor_cd_var, now)
        setplaydef(play, emperor_end_var, now + int(emperor.duration))
        refresh_emperor(play)
        delaygoto(play, math.max(1000, int(emperor.duration) * 1000), "@star_chart_emperor_active_tick")
        return true
    end
    return false
end

function star_chart_domain_active_tick(play)
    refresh_domain(play)
    local remain = int(getplaydef(play, domain_end_var)) - os.time()
    if remain > 0 then
        delaygoto(play, math.max(1000, remain * 1000), "@star_chart_domain_active_tick")
    end
end

function star_chart_emperor_active_tick(play)
    refresh_emperor(play)
    local remain = int(getplaydef(play, emperor_end_var)) - os.time()
    if remain > 0 then
        delaygoto(play, math.max(1000, remain * 1000), "@star_chart_emperor_active_tick")
    end
end

local previous_beginmagic = beginmagic
function beginmagic(play, magic_id, magic_name, target_object, x, y)
    local skill_id = int(magic_id)
    if skill_id == 1029 or skill_id == 1030 then
        return StarChartSkills.cast(play, skill_id, target_object, x, y)
    end
    if previous_beginmagic then
        return previous_beginmagic(play, magic_id, magic_name, target_object, x, y)
    end
end

local function on_login(play)
    StarChartSkills.sync_skills(play)
    refresh_domain(play)
    refresh_emperor(play)
end

rawset(_G, "star_chart_skills_sync", StarChartSkills.sync_skills)
GameEvent.add(EventCfg.onLoginEnd, on_login, "star_chart_active_skills")
GameEvent.add(EventCfg.onKFLogin, on_login, "star_chart_active_skills_kf")
rawset(_G, "StarChartSkills", StarChartSkills)
rawset(_G, "star_chart_cast", StarChartSkills.cast)
return StarChartSkills
