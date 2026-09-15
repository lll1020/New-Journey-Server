local TalentTreeSkills = {}

local Cfg = include("lua/Data/talent_tree_cfg.lua") or {}

local SKILLS = {
    metal_skill = {idx = 1017},
    metal_ultimate = {idx = 1018},
    wood_skill = {idx = 1019},
    wood_ultimate = {idx = 1020},
    water_skill = {idx = 1023},
    water_ultimate = {idx = 1024},
    fire_skill = {idx = 1025},
    fire_ultimate = {idx = 1026},
    earth_skill = {idx = 1027},
    earth_ultimate = {idx = 1028},
}

local SKILL_KEYS = {}
for key, skill in pairs(SKILLS) do
    SKILL_KEYS[skill.idx] = key
end

local SKILL_CAST_EFFECTS = {
    [1017] = 60456,
    [1018] = 60456,
    [1019] = 60463,
    [1020] = 60463,
    [1023] = 60454,
    [1024] = 60454,
    [1025] = 60463,
    [1026] = 60463,
    [1027] = 60458,
    [1028] = 60458,
}

local STACKS = {
    [20179] = {var = 23079, end_var = 23089, max = 3, duration = 5},
    [20180] = {var = 23080, end_var = 23090, max = 8, duration = 3},
    [20181] = {var = 23081, end_var = 23091, max = 12, duration = 5},
    [20182] = {var = 23082, end_var = 23092, max = 5, duration = 3},
}

local DOMAIN_VAR = "S$talent_tree_domains"
local SHIELD_VARS = {
    earth = {
        value = "N$talent_earth_shield",
        expires = "N$talent_earth_shield_end",
        cooldown = "N$talent_earth_shield_cd",
    },
    water = {
        value = "N$talent_water_shield",
        expires = "N$talent_water_shield_end",
        cooldown = "N$talent_water_shield_cd",
    },
    wood = {
        value = "N$talent_wood_shield",
        expires = "N$talent_wood_shield_end",
    },
}

local WOOD_DOMAIN_MARKER = 23095

local owner_targets = {}
local flow_active
local target_defense_break
local apply_wood
local clear_domains

local function toint(value, default)
    value = tonumber(value)
    if value == nil then
        return default or 0
    end
    return math.floor(value)
end

local function node_active(state, node_id)
    return type(state) == "table"
        and type(state.nodes) == "table"
        and toint(state.nodes[tostring(node_id)], 0) == 1
end

local function node_has_special(state, key)
    if type(state) ~= "table" or type(state.nodes) ~= "table" then
        return false
    end
    for node_id, value in pairs(state.nodes) do
        if toint(value, 0) == 1 then
            local node = Cfg.node_map and Cfg.node_map[tostring(node_id)] or nil
            if node and node.special and node.special.key == key then
                return true
            end
        end
    end
    return false
end

local function key_active(state, key)
    if type(state) == "table"
        and type(state.special) == "table"
        and toint(state.special[key], 0) > 0
    then
        return true
    end
    return node_has_special(state, key)
end

local function is_player(obj)
    if not obj then
        return false
    end
    local value = getbaseinfo(obj, ConstCfg.gbase.isplayer)
    return value == true or tonumber(value) == 1
end

local function is_monster(obj)
    return obj and not is_player(obj)
end

local function max_hp(obj)
    return tonumber(getbaseinfo(obj, ConstCfg.gbase.maxhp) or 0) or 0
end

local function current_hp(obj)
    return tonumber(getbaseinfo(obj, ConstCfg.gbase.curhp) or 0) or 0
end

local function attack_value(obj)
    local value = tonumber(getbaseinfo(obj, ConstCfg.gbase.dc2) or 0) or 0
    if value <= 0 then
        value = tonumber(getbaseinfo(obj, 20) or 0) or 0
    end
    return math.max(0, value)
end

local function now()
    return os.time()
end

local function get_obj_var(obj, index)
    if not obj then
        return 0
    end
    local ok, value = pcall(getobjintvar, obj, index)
    return ok and toint(value, 0) or 0
end

local function set_obj_var(obj, index, value)
    if obj then
        pcall(setobjintvar, obj, index, toint(value, 0))
    end
end

local function get_play_number(play, key)
    return tonumber(getplaydef(play, key) or 0) or 0
end

local function get_engine_stack(obj, buff_id)
    if not obj or not getbuffinfo then
        return 0
    end
    local ok, value = pcall(getbuffinfo, obj, buff_id, 1)
    return ok and math.max(0, toint(value, 0)) or 0
end

local function get_engine_remaining(obj, buff_id)
    if not obj or not getbuffinfo then
        return 0
    end
    local ok, value = pcall(getbuffinfo, obj, buff_id, 2)
    return ok and math.max(0, toint(value, 0)) or 0
end

local function get_stack(obj, buff_id)
    local cfg = STACKS[buff_id]
    if not cfg or not obj then
        return 0
    end
    local stored = get_obj_var(obj, cfg.var)
    local engine = get_engine_stack(obj, buff_id)
    local remaining = get_engine_remaining(obj, buff_id)
    local stored_end = get_obj_var(obj, cfg.end_var)

    -- The custom value is written together with every talent stack update.
    -- Treat an explicit zero as authoritative so a delayed engine removal
    -- cannot make a detonated stack appear again in the same frame.
    if stored <= 0 then
        if engine > 0 and stored_end <= 0 then
            delbuff(obj, buff_id)
        end
        return 0
    end

    -- The engine is authoritative when the buff still exists. The custom
    -- variables are only a fallback for stack/owner data that the engine
    -- does not expose after a reload.
    if engine > 0 then
        if remaining > 0 and stored_end <= now() then
            set_obj_var(obj, cfg.end_var, now() + remaining)
        end
        return math.min(cfg.max, math.max(stored, engine))
    end
    if stored > 0 and stored_end > now() then
        return math.min(cfg.max, stored)
    end
    set_obj_var(obj, cfg.var, 0)
    set_obj_var(obj, cfg.end_var, 0)
    return 0
end

local function set_stack(obj, buff_id, stack, duration, owner)
    local cfg = STACKS[buff_id]
    if not cfg or not obj then
        return 0
    end
    stack = math.max(0, math.min(cfg.max, toint(stack, 0)))
    if stack <= 0 then
        delbuff(obj, buff_id)
        set_obj_var(obj, cfg.var, 0)
        set_obj_var(obj, cfg.end_var, 0)
        return 0
    end
    duration = math.max(1, toint(duration, cfg.duration))
    addbuff(obj, buff_id, duration, stack, owner or obj)
    set_obj_var(obj, cfg.var, stack)
    set_obj_var(obj, cfg.end_var, now() + duration)
    return stack
end

local function add_stack(caster, target, buff_id, amount, limit, duration)
    if not target or not STACKS[buff_id] then
        return 0
    end
    local current = get_stack(target, buff_id)
    local stack = math.min(toint(limit, STACKS[buff_id].max), current + math.max(0, toint(amount, 0)))
    if stack <= 0 then
        return 0
    end
    set_stack(target, buff_id, stack, duration, caster)
    if caster and caster ~= target then
        local bucket = owner_targets[caster]
        if not bucket then
            bucket = {}
            owner_targets[caster] = bucket
        end
        bucket[target] = true
    end
    return stack
end

local function clear_stack(target, buff_id)
    if target and STACKS[buff_id] then
        delbuff(target, buff_id)
        set_obj_var(target, STACKS[buff_id].var, 0)
        set_obj_var(target, STACKS[buff_id].end_var, 0)
        for owner, targets in pairs(owner_targets) do
            targets[target] = nil
            if next(targets) == nil then
                owner_targets[owner] = nil
            end
        end
    end
end

local function effect(target, effect_id)
    if target and effect_id and effect_id > 0 then
        pcall(playeffect, target, effect_id, 0, 0, 1, 0, 0)
    end
end

local function area_damage(play, center, radius, damage, effect_id, exclude)
    if not play or not center or damage <= 0 then
        return
    end
    local map_id = getbaseinfo(center, 3)
    local x, y = getbaseinfo(center, 4), getbaseinfo(center, 5)
    for _, target in ipairs(getobjectinmap(map_id, x, y, radius, 2) or {}) do
        if target ~= exclude and is_monster(target) then
            humanhp(target, "-", damage, 112, 0, play, 1)
            effect(target, effect_id)
        end
    end
end

local function area_damage_limited(play, center, radius, damage, effect_id, exclude, max_targets, on_target)
    if not play or not center or damage <= 0 then
        return 0
    end
    local map_id = getbaseinfo(center, ConstCfg.gbase.mapid)
    local x, y = getbaseinfo(center, ConstCfg.gbase.x), getbaseinfo(center, ConstCfg.gbase.y)
    local count = 0
    local limit = math.max(1, toint(max_targets, 20))
    for _, target in ipairs(getobjectinmap(map_id, x, y, radius, 2) or {}) do
        if target ~= exclude and is_monster(target) and count < limit then
            humanhp(target, "-", damage, 112, 0, play, 1)
            effect(target, effect_id)
            if on_target then
                on_target(target)
            end
            count = count + 1
        end
    end
    return count
end

flow_active = function(state, element, lane)
    local prefix = tostring(element) .. "_flow_" .. tostring(lane) .. "_"
    return key_active(state, prefix .. "3")
        or key_active(state, prefix .. "6")
        or key_active(state, prefix .. "9")
end

local function has_buff(obj, buff_id)
    if not obj or type(hasbuff) ~= "function" then
        return false
    end
    local ok, value = pcall(hasbuff, obj, buff_id)
    return ok and (value == true or tonumber(value) == 1)
end

local function sync_passive_buff(play, buff_id, enabled)
    if enabled then
        if not has_buff(play, buff_id) then
            addbuff(play, buff_id)
        end
    else
        delbuff(play, buff_id)
    end
end

local function set_target_defense_break(target, percent, duration)
    if not target then
        return
    end
    local until_var = 23094
    local value_var = 23093
    if get_obj_var(target, until_var) <= now() then
        set_obj_var(target, value_var, 0)
    end
    set_obj_var(target, value_var, math.max(get_obj_var(target, value_var), toint(percent, 0)))
    set_obj_var(target, until_var, now() + math.max(1, toint(duration, 2)))
end

target_defense_break = function(target)
    if not target or get_obj_var(target, 23094) <= now() then
        return 0
    end
    return get_obj_var(target, 23093)
end

local function add_target_defense_break(target, percent, duration, limit)
    if not target then
        return
    end
    local current = target_defense_break(target)
    local value = math.max(0, toint(percent, 0))
    if limit then
        value = math.min(toint(limit, value), current + value)
    else
        value = math.max(current, value)
    end
    set_obj_var(target, 23093, value)
    set_obj_var(target, 23094, now() + math.max(1, toint(duration, 2)))
end

local function within_area(caster, target, radius)
    if not caster or not target then
        return false
    end
    if tostring(getbaseinfo(caster, 3) or "") ~= tostring(getbaseinfo(target, 3) or "") then
        return false
    end
    local cx = tonumber(getbaseinfo(caster, 4) or 0) or 0
    local cy = tonumber(getbaseinfo(caster, 5) or 0) or 0
    local tx = tonumber(getbaseinfo(target, 4) or 0) or 0
    local ty = tonumber(getbaseinfo(target, 5) or 0) or 0
    return math.abs(cx - tx) <= radius and math.abs(cy - ty) <= radius
end

local function state_of(play)
    if TalentTree and TalentTree.getState then
        return TalentTree.getState(play)
    end
    return {}
end

function TalentTreeSkills.onSkillCast(play, skill_id)
    if not play then
        return false
    end
    skill_id = tonumber(skill_id) or 0
    local skill_key = SKILL_KEYS[skill_id]
    if not skill_key then
        return false
    end
    local state = state_of(play)
    if not key_active(state, skill_key) then
        return false
    end

    -- Keep the cast hook lightweight. Damage, stacks, domains and target
    -- effects are resolved by the existing damage/timer hooks below.
    effect(play, SKILL_CAST_EFFECTS[skill_id])
    setplaydef(play, "N$talent_tree_last_skill", skill_id)
    setplaydef(play, "N$talent_tree_last_skill_time", now())
    return true
end

function TalentTreeSkills.sync(play, state)
    if not play then
        return
    end
    state = state or state_of(play)
    for key, skill in pairs(SKILLS) do
        local flag = "N$talent_skill_" .. tostring(skill.idx)
        if key_active(state, key) then
            addskill(play, skill.idx, 3)
            setplaydef(play, flag, 1)
        else
            delskill(play, skill.idx)
            setplaydef(play, flag, 0)
        end
    end
    -- These two buffs are the persistent metal-path markers used by the
    -- existing combat/buff configuration.
    sync_passive_buff(play, 20177, flow_active(state, "metal", 1))
    sync_passive_buff(play, 20178, flow_active(state, "metal", 2))
end

function TalentTreeSkills.clear(play)
    if not play then
        return
    end
    for _, skill in pairs(SKILLS) do
        local flag = "N$talent_skill_" .. tostring(skill.idx)
        -- These ids belong to the talent tree. Remove them unconditionally so
        -- old saves without the marker flag cannot keep stale skills.
        delskill(play, skill.idx)
        setplaydef(play, flag, 0)
    end
    delbuff(play, 20177)
    delbuff(play, 20178)
    delbuff(play, 20179)
    delbuff(play, 20180)
    delbuff(play, 20181)
    delbuff(play, 20182)
    for buff_id in pairs(STACKS) do
        clear_stack(play, buff_id)
    end
    local targets = owner_targets[play]
    if targets then
        for target in pairs(targets) do
            for buff_id in pairs(STACKS) do
                clear_stack(target, buff_id)
            end
            set_obj_var(target, 23093, 0)
            set_obj_var(target, 23094, 0)
        end
        owner_targets[play] = nil
    end
    setplaydef(play, "N$talent_earth_shield", 0)
    setplaydef(play, "N$talent_earth_shield_end", 0)
    setplaydef(play, "N$talent_earth_shield_cd", 0)
    setplaydef(play, "N$talent_earth_shield_reduce", 0)
    setplaydef(play, "N$talent_water_shield", 0)
    setplaydef(play, "N$talent_water_shield_end", 0)
    setplaydef(play, "N$talent_water_shield_cd", 0)
    setplaydef(play, "N$talent_wood_shield", 0)
    setplaydef(play, "N$talent_wood_shield_end", 0)
    setplaydef(play, WOOD_DOMAIN_MARKER, 0)
    clear_domains(play)
end

function TalentTreeSkills.adjustTakenDamage(play, hiter, target, damage, magic_id)
    if not play or not hiter or not is_player(play) then
        return nil, false
    end
    damage = math.max(0, toint(damage, 0))
    if damage <= 0 then
        return nil, false
    end
    local remaining = damage
    local still_reduce = get_play_number(play, "N$talent_earth_still_count")
    if still_reduce > 0 then
        remaining = math.floor(remaining * math.max(0, 100 - still_reduce) / 100)
    end
    for _, shield_kind in ipairs({"earth", "water", "wood"}) do
        local shield_cfg = SHIELD_VARS[shield_kind]
        local shield_end = get_play_number(play, shield_cfg.expires)
        local shield = get_play_number(play, shield_cfg.value)
        if shield_end <= now() or shield <= 0 then
            if shield > 0 and shield_end <= now() then
                TalentTreeSkills.breakShield(play, shield_kind)
            end
        else
            local shield_before = shield
            local shield_reduce = shield_kind == "earth"
                and get_play_number(play, "N$talent_earth_shield_reduce")
                or 0
            if shield_reduce > 0 then
                remaining = math.floor(remaining * math.max(0, 100 - shield_reduce) / 100)
            end
            local absorbed = math.min(shield, remaining)
            remaining = remaining - absorbed
            shield = shield - absorbed
            if shield <= 0 then
                -- Pass the pre-hit value so breakShield can still reflect.
                TalentTreeSkills.breakShield(play, shield_kind, nil, shield_before)
            else
                setplaydef(play, shield_cfg.value, shield)
            end

        end
    end
    if remaining <= 0 then
        return 0, true
    end
    return remaining, false
end

apply_wood = function(play, target, state)
    local limit = 3
    add_stack(play, target, 20179, 1, limit, 5)
end

local function apply_fire(play, target, state)
    local limit = flow_active(state, "fire", 1) and 5 or 3
    add_stack(play, target, 20182, 1, limit, 3)
end

local function apply_water(play, target, state, corrosion_amount, tide_amount)
    local corrosion_limit = flow_active(state, "water", 1) and 8 or 5
    local tide_limit = flow_active(state, "water", 2) and 12 or 8
    local tide_duration = flow_active(state, "water", 2) and 8 or 5
    local corrosion = add_stack(play, target, 20180, corrosion_amount or 1, corrosion_limit, 3)
    local tide = add_stack(play, play, 20181, tide_amount or 1, tide_limit, tide_duration)
    if tide > 0 and changespeedex then
        changespeedex(play, 1, tide, tide_duration)
    end
    return corrosion, tide
end

local function apply_water_shield(play, state, value_percent)
    local max_value = max_hp(play)
    if max_value <= 0 then
        return
    end
    local duration = node_active(state, "water_F2_9") and 7 or 5
    local value = tonumber(value_percent) or 10
    setplaydef(play, "N$talent_water_shield", math.floor(max_value * value / 100))
    setplaydef(play, "N$talent_water_shield_end", now() + duration)
    effect(play, 60454)
end

local function apply_earth_shield(play, state)
    local max_value = max_hp(play)
    if max_value <= 0 then
        return
    end
    local cooldown_end = get_play_number(play, SHIELD_VARS.earth.cooldown)
    if cooldown_end > now() then
        return
    end
    local percent = flow_active(state, "earth", 1) and 15 or 8
    local shield = math.floor(max_value * percent / 100)
    setplaydef(play, "N$talent_earth_shield", shield)
    setplaydef(play, "N$talent_earth_shield_end", now() + (node_active(state, "earth_F1_9") and 4 or 3))
    setplaydef(play, SHIELD_VARS.earth.cooldown, now() + 20)
    effect(play, 60458)
end

local function get_domains(play)
    local raw = getplaydef(play, DOMAIN_VAR)
    local data = type(raw) == "string" and raw ~= "" and json2tbl(raw) or {}
    return type(data) == "table" and data or {}
end

local function save_domains(play, domains)
    setplaydef(play, DOMAIN_VAR, tbl2json(type(domains) == "table" and domains or {}))
end

local function add_domain(play, kind, center, radius, duration, damage_percent, effect_id)
    if not play or not center then
        return
    end
    local map_id = getbaseinfo(center, ConstCfg.gbase.mapid)
    local x = tonumber(getbaseinfo(center, ConstCfg.gbase.x) or 0) or 0
    local y = tonumber(getbaseinfo(center, ConstCfg.gbase.y) or 0) or 0
    if not map_id then
        return
    end
    local domains = get_domains(play)
    local next_domains = {}
    for _, domain in ipairs(domains) do
        if type(domain) == "table" and tostring(domain.kind or "") ~= tostring(kind) then
            next_domains[#next_domains + 1] = domain
        end
    end
    next_domains[#next_domains + 1] = {
        kind = kind,
        map = map_id,
        x = x,
        y = y,
        radius = math.max(1, toint(radius, 1)),
        finish = now() + math.max(1, toint(duration, 1)),
        next = now() + 1,
        damage = tonumber(damage_percent) or 0,
        effect = toint(effect_id, 0),
    }
    save_domains(play, next_domains)
end

clear_domains = function(play)
    if play then
        save_domains(play, {})
    end
end

local function start_domain_once(play, skill_id, kind, center, radius, duration, damage, effect_id)
    if not play or not skill_id then
        return false
    end
    local marker = "N$talent_tree_domain_" .. tostring(skill_id)
    local stamp = now()
    if get_play_number(play, marker) == stamp then
        return false
    end
    setplaydef(play, marker, stamp)
    add_domain(play, kind, center, radius, duration, damage, effect_id)
    return true
end

local function domain_targets(domain)
    if type(domain) ~= "table" then
        return {}
    end
    return getobjectinmap(domain.map, domain.x, domain.y, domain.radius, 2) or {}
end

local function remaining_stack_seconds(target, buff_id)
    local cfg = STACKS[buff_id]
    if not cfg then
        return 0
    end
    local engine_remaining = get_engine_remaining(target, buff_id)
    if engine_remaining > 0 then
        return engine_remaining
    end
    return math.max(1, get_obj_var(target, cfg.end_var) - now())
end

local function detonate_stack(caster, target, buff_id, percent_per_second, keep_stack)
    local stack = get_stack(target, buff_id)
    if stack <= 0 then
        return 0
    end
    local duration = remaining_stack_seconds(target, buff_id)
    local damage = math.floor(
        attack_value(caster) * stack * math.max(0, tonumber(percent_per_second) or 0)
            * duration / 100
    )
    if keep_stack and keep_stack > 0 then
        set_stack(target, buff_id, keep_stack, STACKS[buff_id].duration, caster)
    else
        clear_stack(target, buff_id)
    end
    return damage
end

local function trigger_domain(play, domain, state)
    local damage = math.floor(attack_value(play) * (tonumber(domain.damage) or 0) / 100)
    local kind = tostring(domain.kind or "")
    if kind == "wood" and flow_active(state, "wood", 2) then
        local heal = math.floor(max_hp(play) * 2 / 100)
        if heal > 0 then
            for _, ally in ipairs(getobjectinmap(domain.map, domain.x, domain.y, domain.radius, 1) or {}) do
                if is_player(ally) then
                    humanhp(ally, "+", heal, 5, 0, play)
                end
            end
        end
    end
    for _, target in ipairs(domain_targets(domain)) do
        if is_monster(target) then
            if kind == "metal" then
                if damage > 0 then
                    humanhp(target, "-", damage, 106, 0, play, 1)
                end
                add_target_defense_break(target, 8, 2, node_active(state, "metal_F2_9") and 40 or 8)
            elseif kind == "wood" then
                apply_wood(play, target, state)
                if node_active(state, "wood_F2_6") then
                    set_obj_var(target, WOOD_DOMAIN_MARKER, now() + 2)
                end
                if changespeedex then
                    changespeedex(target, 1, -20, 2)
                end
                if damage > 0 then
                    humanhp(target, "-", damage, 106, 0, play, 1)
                end
            elseif kind == "water" then
                if damage > 0 then
                    humanhp(target, "-", damage, 112, 0, play, 1)
                end
            elseif kind == "fire" then
                add_stack(play, target, 20182, 1, flow_active(state, "fire", 1) and 5 or 3, 3)
                if damage > 0 then
                    humanhp(target, "-", damage, 112, 0, play, 1)
                end
            elseif kind == "earth" then
                add_target_defense_break(target, 8, 3, 24)
                if damage > 0 then
                    humanhp(target, "-", damage, 106, 0, play, 1)
                end
            end
            effect(target, domain.effect)
        end
    end
end

function TalentTreeSkills.tick(play)
    if not play then
        return
    end
    local current = now()
    local state = state_of(play)
    local x = tonumber(getbaseinfo(play, ConstCfg.gbase.x) or 0) or 0
    local y = tonumber(getbaseinfo(play, ConstCfg.gbase.y) or 0) or 0
    local last_x = get_play_number(play, "N$talent_earth_last_x")
    local last_y = get_play_number(play, "N$talent_earth_last_y")
    local still_count = get_play_number(play, "N$talent_earth_still_count")
    if node_active(state, "earth_F1_6") and last_x == x and last_y == y then
        still_count = math.min(10, still_count + 1)
    else
        still_count = 0
    end
    setplaydef(play, "N$talent_earth_last_x", x)
    setplaydef(play, "N$talent_earth_last_y", y)
    setplaydef(play, "N$talent_earth_still_count", still_count)
    local domains = get_domains(play)
    local kept = {}
    for _, domain in ipairs(domains) do
        if type(domain) == "table" and current <= toint(domain.finish, 0) then
            if current >= toint(domain.next, 0) then
                trigger_domain(play, domain, state)
                domain.next = current + 1
            end
            kept[#kept + 1] = domain
        end
    end
    save_domains(play, kept)

    local water_end = get_play_number(play, SHIELD_VARS.water.expires)
    if water_end > 0 and water_end <= current then
        setplaydef(play, SHIELD_VARS.water.value, 0)
        setplaydef(play, SHIELD_VARS.water.expires, 0)
    end
    local water_shield = get_play_number(play, SHIELD_VARS.water.value)
    if water_shield > 0 and flow_active(state, "water", 2)
        and node_active(state, "water_F2_6")
    then
        humanhp(play, "+", math.floor(max_hp(play) / 100), 5, 0, play)
    end
    local earth_end = get_play_number(play, SHIELD_VARS.earth.expires)
    if earth_end > 0 and earth_end <= current then
        TalentTreeSkills.breakShield(play, "earth", state)
    end
    local wood_end = get_play_number(play, SHIELD_VARS.wood.expires)
    if wood_end > 0 and wood_end <= current then
        if flow_active(state, "wood", 1) and node_active(state, "wood_F1_9") then
            humanhp(play, "+", math.floor(max_hp(play) * 2 / 100), 5, 0, play)
        end
        setplaydef(play, SHIELD_VARS.wood.value, 0)
        setplaydef(play, SHIELD_VARS.wood.expires, 0)
    end
end

function TalentTreeSkills.breakShield(play, shield_kind, state, break_value)
    local shield_cfg = SHIELD_VARS[shield_kind]
    if not play or not shield_cfg then
        return
    end
    local shield = tonumber(break_value)
    if shield == nil then
        shield = get_play_number(play, shield_cfg.value)
    end
    if shield <= 0 then
        setplaydef(play, shield_cfg.value, 0)
        setplaydef(play, shield_cfg.expires, 0)
        return
    end
    setplaydef(play, shield_cfg.value, 0)
    setplaydef(play, shield_cfg.expires, 0)
    state = state or state_of(play)
    if shield_kind == "earth" and flow_active(state, "earth", 1) then
        local reflect = math.floor(max_hp(play) * (node_active(state, "earth_F1_9") and 13 or 8) / 100)
        if reflect > 0 then
            for _, target in ipairs(getobjectinmap(
                getbaseinfo(play, ConstCfg.gbase.mapid),
                getbaseinfo(play, ConstCfg.gbase.x),
                getbaseinfo(play, ConstCfg.gbase.y),
                3,
                2
            ) or {}) do
                if is_monster(target) then
                    humanhp(target, "-", reflect, 106, 0, play, 1)
                    effect(target, 60458)
                end
            end
        end
    end
end

local function base_skill_damage(play, target, skill_id, damage, state)
    local atk = attack_value(play)
    local result = math.max(0, toint(damage, 0))

    if is_monster(target)
        and flow_active(state, "fire", 2)
        and node_active(state, "fire_F2_6")
        and get_stack(target, 20182) > 0
    then
        humanhp(play, "+", math.floor(atk * 50 / 100), 5, 0, play)
    end

    if skill_id == 1017 and key_active(state, "metal_skill") then
        local percent = flow_active(state, "metal", 1) and 120 or 30
        local threshold = flow_active(state, "metal", 1) and 0.30 or 0.20
        if max_hp(target) > 0 and current_hp(target) / max_hp(target) <= threshold then
            percent = percent + 20
        end
        result = math.floor(atk * percent / 100)
        if flow_active(state, "metal", 2) then
            local radius = node_active(state, "metal_F2_9") and 4 or 3
            local duration = node_active(state, "metal_F2_9") and 6 or 5
            local domain_damage = node_active(state, "metal_F2_6") and 30 or 15
            start_domain_once(play, skill_id, "metal", play, radius, duration, domain_damage, 60456)
        end
        effect(target, 60456)
    elseif skill_id == 1018 and key_active(state, "metal_ultimate") then
        local segment_count = node_active(state, "metal_F1_6") and 7 or 6
        result = math.floor(atk * 800 / 100 / segment_count)
        if flow_active(state, "metal", 1) then
            if max_hp(target) > 0 and current_hp(target) / max_hp(target) <= 0.30 then
                result = math.floor(result * 130 / 100)
            end
            result = math.floor(result * 150 / 100)
        end
        set_target_defense_break(target, 15, 5)
        area_damage_limited(play, target, 5, result, 60456, target, 20, function(item)
            set_target_defense_break(item, 15, 5)
        end)
        effect(target, 60458)
    elseif skill_id == 1019 and key_active(state, "wood_skill") then
        apply_wood(play, target, state)
        if flow_active(state, "wood", 2) then
            add_domain(play, "wood", target, 3, 3, 0, 60463)
            for _, item in ipairs(getobjectinmap(
                getbaseinfo(target, ConstCfg.gbase.mapid),
                getbaseinfo(target, ConstCfg.gbase.x),
                getbaseinfo(target, ConstCfg.gbase.y),
                3,
                2
            ) or {}) do
                if is_monster(item) then
                    apply_wood(play, item, state)
                end
            end
        end
        if node_active(state, "wood_F2_9") and changespeedex then
            changespeedex(target, 1, -30, 2)
        end
        if node_active(state, "wood_F1_9") then
            local current = current_hp(play)
            if max_hp(play) > 0 and current / max_hp(play) > 0.5 then
                setplaydef(play, SHIELD_VARS.wood.value, math.floor(current / 100))
                setplaydef(play, SHIELD_VARS.wood.expires, now() + 1)
            else
                humanhp(play, "+", math.floor(max_hp(play) * 2 / 100), 5, 0, play)
            end
        end
        effect(target, 60463)
    elseif skill_id == 1020 and key_active(state, "wood_ultimate") then
        result = 0
        apply_wood(play, target, state)
        start_domain_once(play, skill_id, "wood", target, 5, 6, 100, 60463)
        effect(target, 60463)
    elseif skill_id == 1023 and key_active(state, "water_skill") then
        local corrosion_limit = flow_active(state, "water", 1) and 8 or 5
        local tide_limit = flow_active(state, "water", 2) and 12 or 8
        local before_corrosion = get_stack(target, 20180)
        local before_tide = get_stack(play, 20181)
        local burst = 0
        local detonated = false
        if flow_active(state, "water", 1) and before_corrosion >= corrosion_limit then
            burst = detonate_stack(
                play,
                target,
                20180,
                flow_active(state, "water", 1) and 5 or 4,
                node_active(state, "water_F1_9") and 3 or nil
            )
            if node_active(state, "water_F1_9") then
                burst = math.floor(burst * 115 / 100)
            end
            detonated = true
            if node_active(state, "water_F1_9") then
                add_target_defense_break(target, 10, 2, 10)
                if changespeedex then
                    changespeedex(target, 1, -5, 2)
                end
            end
        end
        local corrosion, tide = apply_water(
            play,
            target,
            state,
            detonated and 0 or 1,
            1
        )
        result = math.floor(atk * (30 + tide * 2) / 100)
        if detonated then
            result = result + burst
            effect(target, 60454)
        end
        if flow_active(state, "water", 2) and before_tide < 8 and tide >= 8 then
            apply_water_shield(play, state)
        end
        result = math.floor(result * (100 + corrosion * (flow_active(state, "water", 1) and 5 or 4)) / 100)
        effect(target, 60454)
    elseif skill_id == 1024 and key_active(state, "water_ultimate") then
        result = math.floor(atk * 160 / 100)
        local corrosion_limit = flow_active(state, "water", 1) and 8 or 5
        for _, item in ipairs(getobjectinmap(
            getbaseinfo(target, ConstCfg.gbase.mapid),
            getbaseinfo(target, ConstCfg.gbase.x),
            getbaseinfo(target, ConstCfg.gbase.y),
            5,
            2
        ) or {}) do
            if is_monster(item) then
                local before_corrosion = get_stack(item, 20180)
                local burst = 0
                local detonated = false
                if flow_active(state, "water", 1) and before_corrosion >= corrosion_limit then
                    burst = detonate_stack(
                        play,
                        item,
                        20180,
                        12,
                        node_active(state, "water_F1_9") and 3 or nil
                    )
                    if node_active(state, "water_F1_9") then
                        burst = math.floor(burst * 115 / 100)
                    end
                    detonated = true
                end
                add_stack(play, item, 20180, detonated and 0 or 3, corrosion_limit, 3)
                local corrosion = get_stack(item, 20180)
                local multiplier = 100 + corrosion * (flow_active(state, "water", 1) and 5 or 4)
                local hit_damage = math.floor(result * multiplier / 100) + burst
                if item ~= target then
                    humanhp(item, "-", hit_damage, 112, 0, play, 1)
                    effect(item, 60454)
                else
                    result = hit_damage
                end
            end
        end
        apply_water(play, target, state, 0, 4)
        if flow_active(state, "water", 2) then
            apply_water_shield(play, state, 20)
        end
        start_domain_once(play, skill_id, "water", target, 5, 3, 30, 60454)
        effect(target, 60454)
    elseif skill_id == 1025 and key_active(state, "fire_skill") then
        local limit = flow_active(state, "fire", 1) and 5 or 3
        local percent = 35
        local burst = 0
        local before_burn = get_stack(target, 20182)
        local detonated = false
        if flow_active(state, "fire", 1) and before_burn >= limit then
            burst = detonate_stack(play, target, 20182, 10, node_active(state, "fire_F1_9") and 3 or nil)
            if node_active(state, "fire_F1_9") then
                burst = math.floor(burst * 120 / 100)
            end
            percent = node_active(state, "fire_F1_6") and 100 or 50
            detonated = true
        end
        local burn = add_stack(play, target, 20182, detonated and 0 or 1, limit, 3)
        result = math.floor(atk * percent / 100) + burst
        if flow_active(state, "fire", 2) and burn >= 3 then
            result = math.floor(result * 110 / 100)
        end
        effect(target, 60463)
    elseif skill_id == 1026 and key_active(state, "fire_ultimate") then
        result = math.floor(atk * 180 / 100)
        local target_burn = get_stack(target, 20182)
        local burn_limit = flow_active(state, "fire", 1) and 5 or 3
        if flow_active(state, "fire", 1) and target_burn >= burn_limit then
            result = math.floor(result * 120 / 100)
            result = result + detonate_stack(
                play,
                target,
                20182,
                15,
                node_active(state, "fire_F1_9") and 3 or nil
            )
        else
            apply_fire(play, target, state)
        end
        for _, item in ipairs(getobjectinmap(
            getbaseinfo(target, ConstCfg.gbase.mapid),
            getbaseinfo(target, ConstCfg.gbase.x),
            getbaseinfo(target, ConstCfg.gbase.y),
            5,
            2
        ) or {}) do
            if is_monster(item) then
                if item ~= target then
                    humanhp(item, "-", result, 112, 0, play, 1)
                end
                apply_fire(play, item, state)
                effect(item, 60463)
            end
        end
        start_domain_once(play, skill_id, "fire", target, 5, 5, 25, 60463)
        effect(target, 60463)
    elseif skill_id == 1027 and key_active(state, "earth_skill") then
        local rockfall = flow_active(state, "earth", 2)
        result = math.floor(atk * (rockfall and 100 or 40) / 100)
        if rockfall and node_active(state, "earth_F2_9")
            and (math.random(100) <= 50 or key_active(state, "earth_ultimate"))
        then
            result = result * 2
        end
        set_target_defense_break(target, rockfall and 15 or 5, 2)
        if rockfall then
            add_target_defense_break(target, 10, 2, 25)
            if changespeedex then
                changespeedex(target, 1, -25, 2)
            end
        else
            area_damage_limited(play, target, 3, result, 60458, target, 20, function(item)
                add_target_defense_break(item, 5, 2, 5)
                if changespeedex then
                    changespeedex(item, 1, -5, 2)
                end
            end)
        end
        apply_earth_shield(play, state)
        effect(target, 60458)
    elseif skill_id == 1028 and key_active(state, "earth_ultimate") then
        result = math.floor(atk * 170 / 100)
        if flow_active(state, "earth", 1) then
            local shield = math.floor(max_hp(play) * 30 / 100)
            setplaydef(play, SHIELD_VARS.earth.value, shield)
            setplaydef(play, SHIELD_VARS.earth.expires, now() + (node_active(state, "earth_F1_9") and 9 or 8))
            setplaydef(play, "N$talent_earth_shield_reduce", 20)
            setplaydef(play, SHIELD_VARS.earth.cooldown, now() + 20)
            effect(play, 60458)
        end
        for _, item in ipairs(getobjectinmap(
            getbaseinfo(target, ConstCfg.gbase.mapid),
            getbaseinfo(target, ConstCfg.gbase.x),
            getbaseinfo(target, ConstCfg.gbase.y),
            5,
            2
        ) or {}) do
            if is_monster(item) then
                add_target_defense_break(item, 8, 3, 24)
                if item ~= target then
                    humanhp(item, "-", result, 106, 0, play, 1)
                    effect(item, 60458)
                end
            end
        end
        start_domain_once(play, skill_id, "earth", target, 5, 3, 35, 60458)
        effect(target, 60458)
    end

    if get_stack(target, 20179) > 0 and flow_active(state, "wood", 1) and result > 0 then
        result = result + math.floor(atk * 3 / 100)
        humanhp(play, "+", math.floor(max_hp(play) * 5 / 1000), 5, 0, play)
    end
    if get_stack(target, 20179) > 0 and flow_active(state, "wood", 2) and result > 0 then
        humanhp(play, "+", math.floor(result * 8 / 100), 5, 0, play)
    end
    if flow_active(state, "earth", 2)
        and node_active(state, "earth_F2_9")
    then
        local shield = get_play_number(play, SHIELD_VARS.earth.value)
        if shield > 0 then
            result = result + math.floor(shield / 100)
        end
    end
    local defense_break = target_defense_break(target)
    if defense_break > 0 then
        result = math.floor(result * (100 + defense_break) / 100)
    end
    return result
end

local function on_player_hurt(play, damage, hiter, target, magic_id)
    if not play or not hiter or not is_player(play) then
        return
    end
    if tonumber(magic_id or 0) ~= 0 or not is_monster(hiter) then
        return
    end
    if get_play_number(play, SHIELD_VARS.earth.expires) <= now()
        or get_play_number(play, SHIELD_VARS.earth.value) <= 0
        or get_play_number(play, "N$talent_earth_shield_reduce") < 20
    then
        return
    end
    local state = state_of(play)
    local reflect = math.floor(
        max_hp(play) * (node_active(state, "earth_F1_9") and 10 or 5) / 100
    )
    if reflect > 0 then
        humanhp(hiter, "-", reflect, 106, 0, play, 1)
        effect(hiter, 60458)
    end
end

function TalentTreeSkills.adjustDamage(play, target, hiter, skill_id, damage, model)
    if not play or not target then
        return damage
    end
    return base_skill_damage(play, target, tonumber(skill_id) or 0, damage, state_of(play))
end

function TalentTreeSkills.onBuffTrigger(target, buff_id)
    buff_id = tonumber(buff_id) or 0
    if not STACKS[buff_id] or not target then
        return false
    end
    local stack = get_stack(target, buff_id)
    if stack <= 0 then
        return true
    end
    local owner
    if getbuffinfo then
        local ok, value = pcall(getbuffinfo, target, buff_id, 3)
        if ok and value and value ~= 0 then
            owner = value
        end
    end
    owner = owner or target
    if buff_id == 20179 or buff_id == 20182 then
        local state = is_player(owner) and state_of(owner) or {}
        local percent = 10
        if buff_id == 20179 and flow_active(state, "wood", 1) then
            percent = percent + 5
        end
        if buff_id == 20179
            and flow_active(state, "wood", 2)
            and get_obj_var(target, WOOD_DOMAIN_MARKER) > now()
        then
            percent = percent + 10
        end
        if buff_id == 20182 and flow_active(state, "fire", 2) and stack >= 3 then
            percent = percent + 10
        end
        local damage = math.floor(attack_value(owner) * stack * percent / 100)
        if damage > 0 then
            humanhp(target, "-", damage, buff_id == 20179 and 106 or 112, 0, owner, 1)
        end
        if buff_id == 20179 and changespeedex then
            changespeedex(target, 1, -10, 2)
        end
        effect(target, 60463)
    end
    return true
end

function TalentTreeSkills.onBuffChange(target, buff_id, zid, operation)
    buff_id = tonumber(buff_id) or 0
    if not STACKS[buff_id] then
        return false
    end
    if toint(operation, 0) == 4 then
        local cfg = STACKS[buff_id]
        set_obj_var(target, cfg.var, 0)
        set_obj_var(target, cfg.end_var, 0)
    end
    return true
end

function TalentTreeSkills.onKillMon(play, mob)
    if not play or not mob then
        return
    end
    local state = state_of(play)
    local wither = get_stack(mob, 20179)
    local burn = get_stack(mob, 20182)
    if wither > 0 and node_active(state, "wood_F1_6") then
        humanhp(play, "+", math.floor(max_hp(play) * 5 / 100), 5, 0, play)
    end
    if burn > 0 then
        local burn_damage = math.floor(
            attack_value(play) * burn * 10 / 100 * remaining_stack_seconds(mob, 20182)
        )
        if burn_damage > 0 then
            area_damage_limited(
                play,
                mob,
                node_active(state, "fire_F2_9") and 4 or 3,
                math.floor(burn_damage * 50 / 100),
                60463,
                mob,
                node_active(state, "fire_F2_9") and 5 or 2
            )
        end
    end
    if burn > 0 and flow_active(state, "fire", 2) then
        local map_id = getbaseinfo(mob, 3)
        local x, y = getbaseinfo(mob, 4), getbaseinfo(mob, 5)
        local radius = node_active(state, "fire_F2_9") and 4 or 3
        local limit = node_active(state, "fire_F2_9") and 5 or 2
        local count = 0
        for _, target in ipairs(getobjectinmap(map_id, x, y, radius, 2) or {}) do
            if target ~= mob and is_monster(target) and count < limit then
                add_stack(play, target, 20182, burn, node_active(state, "fire_F2_9") and 5 or 3, 3)
                count = count + 1
            end
        end
    end
    clear_stack(mob, 20179)
    clear_stack(mob, 20180)
    clear_stack(mob, 20182)
end

GameEvent.add(EventCfg.onKillMon, TalentTreeSkills.onKillMon, "talent_tree_skills.kill")
GameEvent.add(EventCfg.onProHarm, on_player_hurt, "talent_tree_skills.earth_reflect")

rawset(_G, "TalentTreeSkills", TalentTreeSkills)
return TalentTreeSkills
