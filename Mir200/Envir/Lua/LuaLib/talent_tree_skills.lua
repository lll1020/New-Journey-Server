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

local STACKS = {
    [20179] = {var = 23079, end_var = 23089, max = 3, duration = 5},
    [20180] = {var = 23080, end_var = 23090, max = 8, duration = 3},
    [20181] = {var = 23081, end_var = 23091, max = 12, duration = 5},
    [20182] = {var = 23082, end_var = 23092, max = 5, duration = 3},
}
local PERIODIC_STACKS = {20179, 20182}

local DOMAIN_VAR = "S$talent_tree_domains"
local CURRENT_VAR_SLOT = "9"
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
local stack_owners = {}
local periodic_tick_at = {}
local object_vars = {}
local unlink_stack_owner
local link_stack_owner
local flow_active
local target_defense_break
local apply_wood
local clear_domains
local base_skill_damage

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

local ELEMENT_NAME = {
    metal = "Èá?",
    water = "Ê∞?",
    wood = "Êú?",
    fire = "ÁÅ?",
    earth = "Âú?",
}
local M1_ELEMENT = {
    metal_M1 = "metal",
    water_M1 = "water",
    wood_M1 = "wood",
    fire_M1 = "fire",
    earth_M1 = "earth",
}
local RESTRAIN_TARGET = {
    wood = "earth",
    earth = "water",
    water = "fire",
    fire = "metal",
    metal = "wood",
}

local function active_m1_element(state)
    for node_id, element in pairs(M1_ELEMENT) do
        if node_active(state, node_id) then
            return element
        end
    end
    return nil
end

local function relation_matches(relation, source, target)
    if type(relation) ~= "table" or not source or not target then
        return false
    end
    if relation.relation_type == "restrain"
        and tostring(relation.source or "") == source
        and tostring(relation.target or "") == target
    then
        return true
    end
    local expected = tostring(ELEMENT_NAME[source] or "") .. "ÂÖ?" .. tostring(ELEMENT_NAME[target] or "")
    return expected ~= "ÂÖ?" and tostring(relation.name or "") == expected
end

local function resonance_relation(state)
    local source = active_m1_element(state)
    local target = RESTRAIN_TARGET[source]
    if not source or not target then
        return nil
    end
    for _, relation in ipairs(Cfg.relations or {}) do
        if relation_matches(relation, source, target) then
            return relation
        end
    end
    return nil
end

local function resonance_ignore_percent(state, target)
    local relation = resonance_relation(state)
    if not relation then
        return 0
    end
    return toint(is_player(target) and relation.player_defense_ignore or relation.monster_defense_ignore, 0)
end

local function resonance_taken_multiplier(state)
    local relation = resonance_relation(state)
    if not relation then
        return 1
    end
    local taken = tonumber(relation.taken)
    if not taken or taken <= 0 then
        return 1
    end
    return taken
end

local function apply_resonance_damage(state, target, damage)
    damage = math.max(0, toint(damage, 0))
    local percent = resonance_ignore_percent(state, target)
    if percent <= 0 or damage <= 0 then
        return damage
    end
    return math.floor(damage * (100 + percent) / 100)
end

local function same_actor(a, b)
    if not a or not b then
        return false
    end
    return tostring(a) == tostring(b)
end

local function same_map(a, b)
    if not a or not b then
        return false
    end
    local am = getbaseinfo(a, ConstCfg.gbase.mapid) or getbaseinfo(a, 3)
    local bm = getbaseinfo(b, ConstCfg.gbase.mapid) or getbaseinfo(b, 3)
    if am == nil or bm == nil then
        return false
    end
    return tostring(am) == tostring(bm)
end

local function is_valid_skill_target(play, target)
    if not play or not target or target == "0" or same_actor(play, target) then
        return false
    end
    if not same_map(play, target) then
        return false
    end
    return is_monster(target) or is_player(target)
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

local function parse_current_vars(raw)
    local vars = {}
    raw = tostring(raw or "")
    for key, value in string.gmatch(raw, "([^=|]+)=([^|]*)") do
        vars[toint(key, 0)] = toint(value, 0)
    end
    return vars
end

local function pack_current_vars(vars)
    if type(vars) ~= "table" then
        return ""
    end
    local parts = {}
    for key, value in pairs(vars) do
        value = toint(value, 0)
        if value ~= 0 then
            parts[#parts + 1] = tostring(key) .. "=" .. tostring(value)
        end
    end
    return table.concat(parts, "|")
end

local function get_current_vars(obj)
    if type(getcurrent) == "function" then
        local ok, raw = pcall(getcurrent, obj, CURRENT_VAR_SLOT)
        if ok then
            return parse_current_vars(raw)
        end
    end
    return object_vars[obj] or {}
end

local function set_current_vars(obj, vars)
    local packed = pack_current_vars(vars)
    if type(setcurrent) == "function" then
        local ok = pcall(setcurrent, obj, CURRENT_VAR_SLOT, packed)
        if ok then
            return
        end
    end
    object_vars[obj] = vars
end

local function get_obj_var(obj, index)
    if not obj then
        return 0
    end
    if is_player(obj) then
        return tonumber(getplaydef(obj, "N$talent_stack_" .. tostring(index)) or 0) or 0
    end
    local vars = get_current_vars(obj)
    return vars and toint(vars[index], 0) or 0
end

local function set_obj_var(obj, index, value)
    if obj then
        if is_player(obj) then
            setplaydef(obj, "N$talent_stack_" .. tostring(index), toint(value, 0))
            return
        end
        local vars = get_current_vars(obj)
        value = toint(value, 0)
        if value == 0 then
            vars[index] = nil
        else
            vars[index] = value
        end
        set_current_vars(obj, vars)
    end
end

local function clear_obj_vars(obj)
    if obj and not is_player(obj) then
        if type(setcurrent) == "function" then
            pcall(setcurrent, obj, CURRENT_VAR_SLOT, "")
        end
        object_vars[obj] = nil
    end
end

local function get_play_number(play, key)
    return tonumber(getplaydef(play, key) or 0) or 0
end

local function get_stack(obj, buff_id)
    local cfg = STACKS[buff_id]
    if not cfg or not obj then
        return 0
    end
    local stored = get_obj_var(obj, cfg.var)
    local stored_end = get_obj_var(obj, cfg.end_var)

    if stored <= 0 then
        return 0
    end

    -- These buffs are display carriers. Their scripted stack and expiry are
    -- authoritative because getbuffinfo values differ between object types.
    if stored_end > now() then
        return math.min(cfg.max, stored)
    end
    delbuff(obj, buff_id)
    unlink_stack_owner(obj, buff_id)
    set_obj_var(obj, cfg.var, 0)
    set_obj_var(obj, cfg.end_var, 0)
    return 0
end

unlink_stack_owner = function(target, buff_id)
    local by_buff = stack_owners[target]
    local owner = by_buff and by_buff[buff_id]
    if owner and owner_targets[owner] then
        owner_targets[owner][target] = nil
        if next(owner_targets[owner]) == nil then
            owner_targets[owner] = nil
        end
    end
    if by_buff then
        by_buff[buff_id] = nil
        if next(by_buff) == nil then
            stack_owners[target] = nil
        end
    end
    if periodic_tick_at[target] then
        periodic_tick_at[target][buff_id] = nil
        if next(periodic_tick_at[target]) == nil then
            periodic_tick_at[target] = nil
        end
    end
end

link_stack_owner = function(owner, target, buff_id)
    if not owner or not target then
        return
    end
    local by_buff = stack_owners[target]
    if not by_buff then
        by_buff = {}
        stack_owners[target] = by_buff
    end
    if by_buff[buff_id] and by_buff[buff_id] ~= owner then
        unlink_stack_owner(target, buff_id)
        by_buff = stack_owners[target]
        if not by_buff then
            by_buff = {}
            stack_owners[target] = by_buff
        end
    end
    by_buff[buff_id] = owner
    local targets = owner_targets[owner]
    if not targets then
        targets = {}
        owner_targets[owner] = targets
    end
    targets[target] = true
    local ticks = periodic_tick_at[target]
    if not ticks then
        ticks = {}
        periodic_tick_at[target] = ticks
    end
    if not ticks[buff_id] then
        ticks[buff_id] = now() + 1
    end
end

local function set_stack(obj, buff_id, stack, duration, owner)
    local cfg = STACKS[buff_id]
    if not cfg or not obj then
        return 0
    end
    stack = math.max(0, math.min(cfg.max, toint(stack, 0)))
    if stack <= 0 then
        unlink_stack_owner(obj, buff_id)
        delbuff(obj, buff_id)
        set_obj_var(obj, cfg.var, 0)
        set_obj_var(obj, cfg.end_var, 0)
        return 0
    end
    duration = math.max(1, toint(duration, cfg.duration))
    local expires_at = now() + duration

    -- Save the script-side stack before adding the engine buff. Player buffs
    -- may invoke their callback synchronously from addbuff; saving afterward
    -- lets that callback see zero stacks and remove the new buff immediately.
    set_obj_var(obj, cfg.var, stack)
    set_obj_var(obj, cfg.end_var, expires_at)

    -- The engine Buff is only a display carrier. Its stack argument is
    -- additive, so replace the carrier before writing the authoritative
    -- script-side total; otherwise 1, 2, 3, 4 becomes 1, 3, 6, 10.
    pcall(delbuff, obj, buff_id)
    pcall(addbuff, obj, buff_id, duration, stack, owner or obj)
    return stack
end

local function add_stack(caster, target, buff_id, amount, limit, duration)
    if not target or not STACKS[buff_id] then
        return 0
    end
    local current = get_stack(target, buff_id)
    local cap = math.min(
        STACKS[buff_id].max,
        math.max(0, toint(limit, STACKS[buff_id].max))
    )
    -- Each application event adds one layer only; do not copy source stacks.
    local delta = toint(amount, 0) > 0 and 1 or 0
    if delta > 0 and current >= cap then
        return current
    end
    local stack = math.min(cap, current + delta)
    if stack <= 0 then
        return 0
    end
    stack = set_stack(target, buff_id, stack, duration, caster)
    if stack <= 0 then
        return 0
    end
    link_stack_owner(caster or target, target, buff_id)
    return stack
end

local function clear_stack(target, buff_id)
    if target and STACKS[buff_id] then
        unlink_stack_owner(target, buff_id)
        delbuff(target, buff_id)
        set_obj_var(target, STACKS[buff_id].var, 0)
        set_obj_var(target, STACKS[buff_id].end_var, 0)
    end
end

local function effect(target, effect_id)
    if target and effect_id and effect_id > 0 then
        pcall(playeffect, target, effect_id, 0, 0, 1, 0, 0)
    end
end

local function area_damage(play, center, radius, damage, effect_id, exclude, state)
    if not play or not center or damage <= 0 then
        return
    end
    local map_id = getbaseinfo(center, 3)
    local x, y = getbaseinfo(center, 4), getbaseinfo(center, 5)
    for _, target in ipairs(getobjectinmap(map_id, x, y, radius, 2) or {}) do
        if target ~= exclude and is_monster(target) then
            humanhp(target, "-", apply_resonance_damage(state, target, damage), 112, 0, play, 1)
            effect(target, effect_id)
        end
    end
end

local function area_damage_limited(play, center, radius, damage, effect_id, exclude, max_targets, on_target, state)
    if not play or not center or damage <= 0 then
        return 0
    end
    local map_id = getbaseinfo(center, ConstCfg.gbase.mapid)
    local x, y = getbaseinfo(center, ConstCfg.gbase.x), getbaseinfo(center, ConstCfg.gbase.y)
    local count = 0
    local limit = math.max(1, toint(max_targets, 20))
    for _, target in ipairs(getobjectinmap(map_id, x, y, radius, 2) or {}) do
        if target ~= exclude and is_monster(target) and count < limit then
            humanhp(target, "-", apply_resonance_damage(state, target, damage), 112, 0, play, 1)
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

local function get_skill_target(play, explicit_target)
    if not play then
        return nil
    end

    if is_valid_skill_target(play, explicit_target) then
        return explicit_target
    end

    local target
    if ConstCfg and ConstCfg.gbase and ConstCfg.gbase.attack_target then
        target = getbaseinfo(play, ConstCfg.gbase.attack_target)
    end
    target = target or getbaseinfo(play, 67)
    if is_valid_skill_target(play, target) then
        return target
    end

    -- Use the nearest monster as a safe fallback when beginmagic has no target.
    local map_id = getbaseinfo(play, ConstCfg.gbase.mapid)
    local x = getbaseinfo(play, ConstCfg.gbase.x)
    local y = getbaseinfo(play, ConstCfg.gbase.y)
    local nearest
    local nearest_distance
    for _, item in ipairs(getobjectinmap(map_id, x, y, 8, 2) or {}) do
        if is_monster(item) then
            local dx = (tonumber(getbaseinfo(item, ConstCfg.gbase.x) or 0) or 0)
                - (tonumber(x or 0) or 0)
            local dy = (tonumber(getbaseinfo(item, ConstCfg.gbase.y) or 0) or 0)
                - (tonumber(y or 0) or 0)
            local distance = dx * dx + dy * dy
            if not nearest_distance or distance < nearest_distance then
                nearest = item
                nearest_distance = distance
            end
        end
    end
    return nearest
end

function TalentTreeSkills.onSkillCast(play, skill_id, explicit_target)
    if not play then
        return false
    end
    skill_id = tonumber(skill_id) or 0
    local skill_key = SKILL_KEYS[skill_id]
    if not skill_key then
        return false
    end
    local state_ok, state = pcall(state_of, play)
    if not state_ok then
        return false
    end
    state = state or {}
    local active = key_active(state, skill_key)
    if not active then
        return false
    end

    local target_ok, target = pcall(get_skill_target, play, explicit_target)
    if not target_ok then
        return false
    end
    if not target then
        return false
    end

    -- Resolve the skill formula and buff logic here, then apply the main hit
    -- directly. Area hits are handled by base_skill_damage.
    local hit_count = 1
    if skill_id == 1018 then
        hit_count = node_active(state, "metal_F1_6") and 7 or 6
    end
    local total_damage = 0
    for _ = 1, hit_count do
        if current_hp(target) <= 0 then
            break
        end
        local formula_ok, result = pcall(base_skill_damage, play, target, skill_id, 0, state)
        if not formula_ok then
            return false
        end
        result = toint(result, 0)
        if result > 0 then
            local hit_ok = pcall(humanhp,
                target,
                "-",
                result,
                110,
                0,
                play,
                1
            )
            if not hit_ok then
                return false
            end
            total_damage = total_damage + result
        end
    end
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
            addskill(play, skill.idx, 1)
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
        local target_list = {}
        for target in pairs(targets) do
            target_list[#target_list + 1] = target
        end
        for _, target in ipairs(target_list) do
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
    local resonanceTaken = resonance_taken_multiplier(state_of(play))
    if resonanceTaken ~= 1 then
        remaining = math.floor(remaining * resonanceTaken)
    end
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
    return add_stack(play, target, 20182, 1, limit, 3)
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
    effect(play, 60458)
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
                    humanhp(target, "-", apply_resonance_damage(state, target, damage), 106, 0, play, 1)
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
                    humanhp(target, "-", apply_resonance_damage(state, target, damage), 106, 0, play, 1)
                end
            elseif kind == "water" then
                if damage > 0 then
                    humanhp(target, "-", apply_resonance_damage(state, target, damage), 112, 0, play, 1)
                end
            elseif kind == "fire" then
                add_stack(play, target, 20182, 1, flow_active(state, "fire", 1) and 5 or 3, 3)
                if damage > 0 then
                    humanhp(target, "-", apply_resonance_damage(state, target, damage), 112, 0, play, 1)
                end
            elseif kind == "earth" then
                add_target_defense_break(target, 8, 3, 24)
                if damage > 0 then
                    humanhp(target, "-", apply_resonance_damage(state, target, damage), 106, 0, play, 1)
                end
            end
            effect(target, domain.effect)
        end
    end
end

local function trigger_periodic_stack(play, target, buff_id, stack, state)
    local percent = 10
    if buff_id == 20179 then
        if flow_active(state, "wood", 1) then
            percent = percent + 5
        end
        if flow_active(state, "wood", 2)
            and get_obj_var(target, WOOD_DOMAIN_MARKER) > now()
        then
            percent = percent + 10
        end
    elseif buff_id == 20182
        and flow_active(state, "fire", 2)
        and stack >= 3
    then
        percent = percent + 10
    end

    local damage = math.floor(attack_value(play) * stack * percent / 100)
    if damage <= 0 then
        return
    end
    humanhp(target, "-", apply_resonance_damage(state, target, damage), buff_id == 20179 and 106 or 112, 0, play, 1)
    if buff_id == 20179 and changespeedex then
        changespeedex(target, 1, -10, 2)
    end
    effect(target, buff_id == 20179 and 14 or 36)
end

local function trigger_periodic_stacks(play, current, state)
    local targets = owner_targets[play]
    if not targets then
        return
    end

    local target_list = {}
    for target in pairs(targets) do
        target_list[#target_list + 1] = target
    end
    for _, target in ipairs(target_list) do
        local by_buff = stack_owners[target]
        if by_buff then
            for _, buff_id in ipairs(PERIODIC_STACKS) do
                if by_buff[buff_id] == play then
                    local stack = get_stack(target, buff_id)
                    if stack > 0 then
                        local next_tick = periodic_tick_at[target]
                            and periodic_tick_at[target][buff_id]
                            or 0
                        if current >= next_tick then
                            trigger_periodic_stack(play, target, buff_id, stack, state)
                            if periodic_tick_at[target] then
                                periodic_tick_at[target][buff_id] = current + 1
                            end
                        end
                    end
                end
            end
        end
    end
end

function TalentTreeSkills.tick(play)
    if not play then
        return
    end
    local current = now()
    local state = state_of(play)
    trigger_periodic_stacks(play, current, state)
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

base_skill_damage = function(play, target, skill_id, damage, state)
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
            start_domain_once(play, skill_id, "metal", play, radius, duration, domain_damage, 13400)
        end
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
        end, state)
    elseif skill_id == 1019 and key_active(state, "wood_skill") then
        apply_wood(play, target, state)
        if flow_active(state, "wood", 2) then
            add_domain(play, "wood", target, 3, 3, 0, 13387)
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
    elseif skill_id == 1020 and key_active(state, "wood_ultimate") then
        result = 0
        apply_wood(play, target, state)
        start_domain_once(play, skill_id, "wood", target, 5, 6, 100, 13387)
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
                add_stack(play, item, 20180, detonated and 0 or 1, corrosion_limit, 3)
                local corrosion = get_stack(item, 20180)
                local multiplier = 100 + corrosion * (flow_active(state, "water", 1) and 5 or 4)
                local hit_damage = math.floor(result * multiplier / 100) + burst
                if item ~= target then
                    humanhp(item, "-", apply_resonance_damage(state, item, hit_damage), 112, 0, play, 1)
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
        start_domain_once(play, skill_id, "water", target, 5, 3, 30, 60459)
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
                    humanhp(item, "-", apply_resonance_damage(state, item, result), 112, 0, play, 1)
                end
                apply_fire(play, item, state)
                effect(item, 60463)
            end
        end
        start_domain_once(play, skill_id, "fire", target, 5, 5, 25, 60463)
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
            area_damage_limited(play, target, 3, result, 60452, target, 20, function(item)
                add_target_defense_break(item, 5, 2, 5)
                if changespeedex then
                    changespeedex(item, 1, -5, 2)
                end
            end, state)
        end
        apply_earth_shield(play, state)
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
                    humanhp(item, "-", apply_resonance_damage(state, item, result), 106, 0, play, 1)
                    effect(item, 60452)
                end
            end
        end
        start_domain_once(play, skill_id, "earth", target, 5, 3, 35, 60452)
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
    local resonance_break = resonance_ignore_percent(state, target)
    if resonance_break > 0 then
        defense_break = defense_break + resonance_break
    end
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
    skill_id = tonumber(skill_id) or 0
    if not play or not target then
        return damage
    end
    local result = base_skill_damage(play, target, skill_id, damage, state_of(play))
    return result
end

function TalentTreeSkills.onBuffTrigger(target, buff_id)
    buff_id = tonumber(buff_id) or 0
    if not STACKS[buff_id] or not target then
        return false
    end
    -- These Buffs are display carriers. Periodic damage is processed by
    -- TalentTreeSkills.tick so monster and player targets use the same path.
    return true
end

function TalentTreeSkills.onBuffChange(target, buff_id, zid, operation)
    buff_id = tonumber(buff_id) or 0
    if not STACKS[buff_id] then
        return false
    end
    -- The timer owns stack expiry. The engine callback must not clear the
    -- scripted state because its timing/operation differs by object type.
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
                node_active(state, "fire_F2_9") and 5 or 2,
                nil,
                state
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
                add_stack(play, target, 20182, 1, node_active(state, "fire_F2_9") and 5 or 3, 3)
                count = count + 1
            end
        end
    end
    clear_stack(mob, 20179)
    clear_stack(mob, 20180)
    clear_stack(mob, 20182)
    clear_obj_vars(mob)
end

GameEvent.add(EventCfg.onKillMon, TalentTreeSkills.onKillMon, "talent_tree_skills.kill")
GameEvent.add(EventCfg.onProHarm, on_player_hurt, "talent_tree_skills.earth_reflect")

rawset(_G, "TalentTreeSkills", TalentTreeSkills)
return TalentTreeSkills
