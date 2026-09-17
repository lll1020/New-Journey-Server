local TalentTree = {}
local Cfg = include("lua/Data/talent_tree_cfg.lua") or {}
local GemCfg = include("lua/Data/talent_tree_gems.lua") or {}
local SkillLogic = rawget(_G, "TalentTreeSkills")

local STATE_VAR = (VarCfg and VarCfg.T_talent_tree) or "T74"
local ATTR_LIST = "talent_tree_attrs"
local REDPOINT_ICON = 22

local function touch_fairy_fate(play)
    local fairy_fate = rawget(_G, "FairyFate")
    if fairy_fate and type(fairy_fate.touch) == "function" then
        fairy_fate.touch(play, "talent_tree")
    end
end

if Player and type(Player.getAttrTableToStr) == "function"
    and not rawget(_G, "__talent_tree_attr_serializer_guard")
then
    local _get_attr_table_to_str = Player.getAttrTableToStr
    Player.getAttrTableToStr = function(attrs)
        return _get_attr_table_to_str(type(attrs) == "table" and attrs or {})
    end
    rawset(_G, "__talent_tree_attr_serializer_guard", true)
end

local function get_skill_logic()
    if type(SkillLogic) == "table" and type(SkillLogic.sync) == "function" then
        return SkillLogic
    end
    local globalLogic = rawget(_G, "TalentTreeSkills")
    if type(globalLogic) == "table" and type(globalLogic.sync) == "function" then
        SkillLogic = globalLogic
        return SkillLogic
    end
    if type(include) == "function" then
        local ok, mod = pcall(include, "lua/LuaLib/talent_tree_skills.lua")
        if ok and type(mod) == "table" then
            SkillLogic = mod
            return SkillLogic
        end
    end
    if type(require) == "function" then
        local ok, mod = pcall(require, "Envir/Lua/LuaLib/talent_tree_skills.lua")
        if ok and type(mod) == "table" then
            SkillLogic = mod
            return SkillLogic
        end
    end
    if release_print then
        release_print("TalentTree skill logic load failed")
    end
    return nil
end

local function toint(value, default)
    value = tonumber(value)
    if value == nil then
        return default or 0
    end
    return math.floor(value)
end

local function table_len(t)
    local count = 0
    if type(t) == "table" then
        for _ in pairs(t) do
            count = count + 1
        end
    end
    return count
end

local function clone_cost(cost)
    local result = {}
    for _, item in ipairs(cost or {}) do
        result[#result + 1] = {item[1], toint(item[2], 0)}
    end
    return result
end

local function add_cost(target, cost)
    for _, item in ipairs(cost or {}) do
        local name = item[1]
        local amount = toint(item[2], 0)
        if name and amount > 0 then
            target[name] = (target[name] or 0) + amount
        end
    end
end

local function cost_map_to_list(map)
    local result = {}
    for name, amount in pairs(map or {}) do
        amount = toint(amount, 0)
        if amount > 0 then
            result[#result + 1] = {name, amount}
        end
    end
    return result
end

local function new_state(play)
    local initialPoints = toint(Cfg.initial_normal_points, 0)
    return {
        version = toint(Cfg.version, 1),
        initialized = 1,
        core_level = toint(Cfg.initial_core_level, 0),
        normal_points = initialPoints,
        normal_total = initialPoints,
        normal_external_total = 0,
        nodes = {root = 1},
        sockets = {},
        special = {},
        spent_costs = {},
        reset_count = 0,
    }
end

local function normalize_state(state, play)
    if type(state) ~= "table"
        or toint(state.initialized, 0) ~= 1
        or toint(state.version, 0) ~= toint(Cfg.version, 1)
    then
        state = new_state(play)
    end
    state.version = toint(Cfg.version, 1)
    state.initialized = 1
    state.core_level = math.max(0, toint(state.core_level, toint(Cfg.initial_core_level, 0)))
    state.normal_points = math.max(0, toint(state.normal_points, 0))
    state.normal_total = math.min(toint(Cfg.normal_point_limit, 210), math.max(0, toint(state.normal_total, 0)))
    state.normal_points = math.min(state.normal_points, state.normal_total)
    state.normal_external_total = math.min(toint(Cfg.external_normal_point_limit, 7), math.max(0, toint(state.normal_external_total, 0)))
    state.nodes = type(state.nodes) == "table" and state.nodes or {}
    state.nodes.root = 1
    state.sockets = type(state.sockets) == "table" and state.sockets or {}
    for node_id, gem_name in pairs(state.sockets) do
        if type(gem_name) ~= "string" or gem_name == "" then
            state.sockets[node_id] = nil
        end
    end
    state.special = type(state.special) == "table" and state.special or {}
    state.spent_costs = type(state.spent_costs) == "table" and state.spent_costs or {}
    state.reset_count = math.max(0, toint(state.reset_count, 0))
    return state
end

local function get_state(play)
    return normalize_state(Player.getJsonTableByVar(play, STATE_VAR), play)
end

local function save_state(play, state)
    Player.setJsonVarByTable(play, STATE_VAR, normalize_state(state, play))
end

local function node_cfg(node_id)
    return Cfg.node_map and Cfg.node_map[tostring(node_id)] or nil
end

local function active(state, node_id)
    return toint((state.nodes or {})[tostring(node_id)] or 0, 0) == 1
end

local function is_m1_node(node)
    return node and (
        node.exclusive_group == "core_m1"
        or tostring(node.id or ""):match("^[^_]+_M1$")
    )
end

local function active_m1_node(state, exclude_id)
    for node_id, value in pairs(state.nodes or {}) do
        if toint(value, 0) == 1 and tostring(node_id) ~= tostring(exclude_id or "") then
            local node = node_cfg(node_id)
            if is_m1_node(node) then
                return node
            end
        end
    end
    return nil
end

local function count_active_talent_points(state)
    local count = 0
    for node_id, value in pairs(state.nodes or {}) do
        if tostring(node_id) ~= "root" and toint(value, 0) == 1 then
            local node = node_cfg(node_id)
            local point_cost = node and math.max(0, toint(node.point_cost, 1)) or 0
            count = count + point_cost
        end
    end
    return count
end

local function get_single_reset_cost(node)
    if is_m1_node(node) then
        return clone_cost(Cfg.m1_reset_cost or {{"灵石", 100}})
    end
    return clone_cost(Cfg.single_reset_cost or {{"灵石", 20}})
end

local function get_full_reset_cost(state)
    local point_cost = math.max(0, toint(Cfg.talent_reset_point_cost, 20))
    local amount = count_active_talent_points(state) * point_cost
    if amount <= 0 then
        return {}
    end
    return {{"灵石", amount}}
end

local function core_max_level()
    local maxLevel = 0
    for _, levelCfg in ipairs(Cfg.core_levels or {}) do
        maxLevel = math.max(maxLevel, toint(levelCfg.level, 0))
    end
    return maxLevel
end

local function next_core_cfg(state)
    local nextLevel = toint(state.core_level, 0) + 1
    return Cfg.core_level_map and Cfg.core_level_map[nextLevel] or nil
end

local function add_attr(attrs, attr_id, attr_value, replace)
    attr_id = tonumber(attr_id)
    attr_value = tonumber(attr_value) or 0
    if not attr_id or attr_value == 0 then
        return
    end
    if replace then
        attrs[attr_id] = math.max(toint(attrs[attr_id], 0), attr_value)
    else
        attrs[attr_id] = (attrs[attr_id] or 0) + attr_value
    end
end

local function add_attr_list(attrs, list, replace_cut)
    for _, attr in ipairs(list or {}) do
        local attr_id = attr.id or attr[1]
        local attr_value = attr.value or attr[2]
        add_attr(attrs, attr_id, attr_value, replace_cut and tonumber(attr_id) == 244)
    end
end

local function count_branch(state, branch)
    local count = 0
    for node_id, value in pairs(state.nodes or {}) do
        if toint(value, 0) == 1 then
            local node = node_cfg(node_id)
            if node and toint(node.branch, 0) == toint(branch, 0) and node.kind ~= "root" and toint(node.point_cost, 1) > 0 then
                count = count + toint(node.point_cost, 1)
            end
        end
    end
    return count
end

local function count_side_nodes(state, branch)
    local count = 0
    for node_id, value in pairs(state.nodes or {}) do
        if toint(value, 0) == 1 then
            local node = node_cfg(node_id)
            if node and node.lane == "side" and toint(node.branch, 0) == toint(branch, 0) and toint(node.point_cost, 1) > 0 then
                count = count + toint(node.point_cost, 1)
            end
        end
    end
    return count
end

local function has_children(state, node_id)
    for active_id, value in pairs(state.nodes or {}) do
        if toint(value, 0) == 1 then
            local node = node_cfg(active_id)
            for _, requirement in ipairs(node and node.requires or {}) do
                if tostring(requirement) == tostring(node_id) then
                    return true
                end
            end
            for _, requirement in ipairs(node and node.requires_any or {}) do
                if tostring(requirement) == tostring(node_id) then
                    return true
                end
            end
        end
    end
    return false
end

local function contains_id(list, target_id)
    for _, value in ipairs(list or {}) do
        if tostring(value) == tostring(target_id) then
            return true
        end
    end
    return false
end

local function is_socket_node(node)
    return node and (node.kind == "socket"
        or tostring(node.slot_type or "") == "X"
        or tostring(node.slot_type or "") == "socket")
end

local function has_missing_socket_prerequisite(state, node)
    local function check_list(list)
        for _, requirement in ipairs(list or {}) do
            local requirement_id = tostring(requirement)
            local requirement_node = node_cfg(requirement_id)
            if is_socket_node(requirement_node)
                and active(state, requirement_id)
                and tostring((state.sockets or {})[requirement_id] or "") == ""
            then
                return requirement_node.name or requirement_id
            end
        end
        return nil
    end
    return check_list(node and node.requires) or check_list(node and node.requires_any)
end

local function resolve_gem_idx(item_name, item_idx)
    local idx = tonumber(item_idx) or 0
    if idx > 0 then
        return idx
    end
    item_name = tostring(item_name or "")
    if item_name == "" then
        return 0
    end
    return tonumber(getstditeminfo(item_name, 0) or 0) or 0
end

local function get_gem_def(item_name, item_idx)
    local idx = resolve_gem_idx(item_name, item_idx)
    if idx <= 0 or type(GemCfg.items) ~= "table" then
        return nil
    end
    return GemCfg.items[idx] or GemCfg.items[tostring(idx)]
end

local function get_gem_level(item_name, gem_def)
    if gem_def and tonumber(gem_def.level) then
        return math.max(1, toint(gem_def.level, 1))
    end
    local level = string.match(tostring(item_name or ""), "[Ll][Vv][%.、%- ]*(%d+)")
        or string.match(tostring(item_name or ""), "(%d+)[级阶]")
    return math.max(1, toint(level, toint(GemCfg.default_level, 1)))
end

local function is_gem_item(item_name, item_idx)
    return get_gem_def(item_name, item_idx) ~= nil
end

local function socket_level_limit(node)
    local node_text = tostring(node and node.effect or "") .. tostring(node and node.desc or "")
    if string.find(node_text, "只能装3级", 1, true) then
        return {3}
    end
    if string.find(node_text, "只能装1/2级", 1, true) then
        return {1, 2}
    end
    return {1, 2, 3}
end

local function can_socket_gem(node, item_name, item_idx)
    if not node or not is_gem_item(item_name, item_idx) then
        return false, "该物品不是灵根天赋宝石#57"
    end
    local gem_def = get_gem_def(item_name, item_idx)
    local gem_level = get_gem_level(item_name, gem_def)
    if not contains_id(socket_level_limit(node), gem_level) then
        return false, "该宝石等级不符合当前槽位要求#57"
    end
    if gem_def and type(gem_def.allowed_socket_types) == "table"
        and not contains_id(gem_def.allowed_socket_types, tostring(node.slot_type or ""))
        and not contains_id(gem_def.allowed_socket_types, tostring(node.kind or ""))
    then
        return false, "该宝石不能镶嵌在当前槽位#57"
    end
    return true, gem_def, gem_level
end

local function get_owned_gems(play, node)
    local result = {}
    local by_name = {}
    for _, item in ipairs(getbagitems(play) or {}) do
        local item_idx = tonumber(getiteminfo(play, item, 2) or 0) or 0
        local item_name = tostring(getiteminfo(play, item, 7) or "")
        local item_count = tonumber(getiteminfo(play, item, 5) or 1) or 1
        if item_count <= 0 then
            item_count = 1
        end
        local ok, gem_def, gem_level = can_socket_gem(node, item_name, item_idx)
        if ok then
            local entry = by_name[item_name]
            if not entry then
                entry = {
                    name = item_name,
                    idx = item_idx,
                    count = 0,
                    level = gem_level,
                    attrs = gem_def and gem_def.attrs or {},
                    special = gem_def and gem_def.special or nil,
                }
                by_name[item_name] = entry
                result[#result + 1] = entry
            end
            entry.count = entry.count + item_count
        end
    end
    table.sort(result, function(left, right)
        return tostring(left.name) < tostring(right.name)
    end)
    return result
end

local function collect_socket_refund(state)
    local refund = {}
    for _, gem_name in pairs(state.sockets or {}) do
        if type(gem_name) == "string" and gem_name ~= "" and get_gem_def(gem_name) then
            refund[gem_name] = (refund[gem_name] or 0) + 1
        end
    end
    return refund
end

-- Links are traversable from either endpoint, including cross-element links.
local function has_active_neighbor(state, node)
    local node_id = tostring(node.id)
    for _, requirement in ipairs(node.requires or {}) do
        if active(state, requirement) then
            return true
        end
    end
    for _, requirement in ipairs(node.requires_any or {}) do
        if active(state, requirement) then
            return true
        end
    end
    for _, candidate in ipairs(Cfg.nodes or {}) do
        if tostring(candidate.id) ~= node_id
            and (contains_id(candidate.requires, node_id)
                or contains_id(candidate.requires_any, node_id))
            and active(state, candidate.id)
        then
            return true
        end
    end
    return false
end

local function check_requirements(state, node)
    if toint(node.core_level, 0) > 0 and toint(state.core_level, 0) < toint(node.core_level, 0) then
        return false, "该节点需要灵根核心达到" .. tostring(node.core_level) .. "级#57"
    end
    if not has_active_neighbor(state, node) then
        return false, "需要先点亮任意相连节点#57"
    end
    local socket_name = has_missing_socket_prerequisite(state, node)
    if socket_name then
        return false, "需要先镶嵌宝石：" .. tostring(socket_name) .. "#57"
    end
    return true
end

local function check_exclusive(state, node)
    if is_m1_node(node) then
        for node_id, value in pairs(state.nodes or {}) do
            if toint(value, 0) == 1
                and is_m1_node(node_cfg(node_id))
                and tostring(node_id) ~= tostring(node.id)
            then
                return false, "五行灵根只能选择一个核心#57"
            end
        end
    end
    if node.exclusive_group then
        for node_id, value in pairs(state.nodes or {}) do
            if toint(value, 0) == 1 then
                local other = node_cfg(node_id)
                if other and other.exclusive_group == node.exclusive_group
                    and tostring(other.exclusive_side or "") ~= tostring(node.exclusive_side or "") then
                    return false, "该流派已选择另一条路线，不能同时点亮#57"
                end
            end
        end
    end
    if node.side_group then
        for node_id, value in pairs(state.nodes or {}) do
            if toint(value, 0) == 1 then
                local other = node_cfg(node_id)
                if other and other.side_group == node.side_group and tostring(other.side or "") ~= tostring(node.side or "") then
                    return false, "同一处侧枝只能选择一个方向#57"
                end
            end
        end
    end
    return true
end

local function has_cost(play, cost)
    if type(cost) ~= "table" or #cost <= 0 then
        return true
    end
    local missing = Player.checkItemNumByTable(play, cost)
    return missing == nil or missing == false
end

local function take_cost(play, cost, reason)
    if type(cost) ~= "table" or #cost <= 0 then
        return true
    end
    local missing, amount = Player.checkItemNumByTable(play, cost)
    if missing then
        Player.sendmsgEx(play, "材料不足：#57|" .. tostring(missing) .. "#218| x" .. tostring(amount or 0))
        return false
    end
    Player.takeItemByTable(play, cost, reason or "天赋树消耗", nil)
    return true
end

local function refund_cost(play, cost, reason)
    if type(cost) ~= "table" or #cost <= 0 then
        return
    end
    Player.rwjl(play, cost, reason or "天赋树返还", 1, 0)
end

local function can_switch_m1(play, state, node, old_node)
    if not is_m1_node(node) or not old_node or active(state, node.id) then
        return false, "本命灵根切换失败#57"
    end
    local ok, msg = check_requirements(state, node)
    if not ok then
        return false, msg
    end
    if has_children(state, old_node.id) then
        return false, "请先退回旧本命灵根下的外层连接节点#57"
    end

    local old_point_cost = math.max(0, toint(old_node.point_cost, 1))
    local new_point_cost = math.max(0, toint(node.point_cost, 1))
    if toint(state.normal_points, 0) + old_point_cost < new_point_cost then
        return false, "天赋点不足#57"
    end

    if toint(node.branch, 0) > 0 and new_point_cost > 0 then
        local branch_points = count_branch(state, node.branch) - old_point_cost + new_point_cost
        if branch_points > toint(Cfg.single_branch_limit, 40) then
            return false, "该灵根分支已达到上限#57"
        end
    end
    if not has_cost(play, node.cost) then
        return false, "材料不足#57"
    end
    return true
end

local refresh_effects
local send_partial

local function switch_m1(play, npcid, state, node, old_node)
    local ok, msg = can_switch_m1(play, state, node, old_node)
    if not ok then
        Player.sendmsgEx(play, msg or "本命灵根切换失败#57")
        return
    end
    if not take_cost(play, get_single_reset_cost(node), "本命灵根切换") then
        return
    end

    local refund = clone_cost(state.spent_costs[old_node.id] or old_node.cost or {})
    local old_gem = state.sockets[old_node.id]
    if type(old_gem) == "string" and old_gem ~= "" and get_gem_def(old_gem) then
        refund[#refund + 1] = {old_gem, 1}
    end

    state.nodes[old_node.id] = nil
    state.sockets[old_node.id] = nil
    state.spent_costs[old_node.id] = nil
    state.nodes[node.id] = 1
    if type(node.cost) == "table" and #node.cost > 0 then
        state.spent_costs[node.id] = clone_cost(node.cost)
    else
        state.spent_costs[node.id] = nil
    end
    state.normal_points = math.min(
        toint(state.normal_points, 0)
            + math.max(0, toint(old_node.point_cost, 1))
            - math.max(0, toint(node.point_cost, 1)),
        toint(state.normal_total, 0)
    )

    save_state(play, state)
    local logic = get_skill_logic()
    if logic and logic.clear then
        logic.clear(play)
    end
    refresh_effects(play, state)
    refund_cost(play, refund, "本命灵根切换返还")
    touch_fairy_fate(play)
    Player.sendmsgEx(play, "本命灵根已切换，消耗100灵石#7")
    send_partial(play, npcid, 7, node.id, state)
end

local function aggregate_attributes(state)
    local attrs = {}
    local special = {}
    for level = 1, toint(state.core_level, 0) do
        local levelCfg = Cfg.core_level_map and Cfg.core_level_map[level] or nil
        if levelCfg and type(levelCfg.attrs) == "table" then
            add_attr_list(attrs, levelCfg.attrs.cut, true)
            add_attr_list(attrs, levelCfg.attrs.hp, false)
            add_attr_list(attrs, levelCfg.attrs.attack, false)
            add_attr_list(attrs, levelCfg.attrs.defense, false)
            add_attr_list(attrs, levelCfg.attrs.recovery, false)
            add_attr_list(attrs, levelCfg.attrs.percent, false)
        end
    end
    for node_id, value in pairs(state.nodes or {}) do
        if toint(value, 0) == 1 then
            local node = node_cfg(node_id)
            add_attr_list(attrs, node and node.attrs, false)
            if node and node.special and node.special.key then
                special[node.special.key] = (special[node.special.key] or 0) + (tonumber(node.special.value) or 0)
            end
        end
    end
    for _, gem_name in pairs(state.sockets or {}) do
        local gem_def = get_gem_def(gem_name)
        if gem_def then
            add_attr_list(attrs, gem_def.attrs, false)
            if gem_def.special and gem_def.special.key then
                special[gem_def.special.key] = (special[gem_def.special.key] or 0)
                    + (tonumber(gem_def.special.value) or 0)
            end
        end
    end
    return attrs, special
end

refresh_effects = function(play, state)
    local attrs, special = aggregate_attributes(state)
    attrs = type(attrs) == "table" and attrs or {}
    special = type(special) == "table" and special or {}
    Player.del_attlist(play, ATTR_LIST)
    local attrs_str = Player.getAttrTableToStr(attrs)
    if attrs_str and attrs_str ~= "" then
        Player.add_attlist(play, ATTR_LIST, "=", attrs_str, 1)
    end
    for key in pairs(state.special or {}) do
        if special[key] == nil then
            setplaydef(play, "N$talent_" .. tostring(key), 0)
        end
    end
    for key, value in pairs(special) do
        setplaydef(play, "N$talent_" .. tostring(key), value)
    end
    state.special = special
    local logic = get_skill_logic()
    if logic and logic.sync then
        logic.sync(play, state)
    end
    recalcabilitys(play)
end

local function can_activate(play, state, node, silent)
    if not node or node.kind == "root" then
        return false, "天赋节点不存在#57"
    end
    if active(state, node.id) then
        return false, "该天赋节点已经点亮#57"
    end
    local ok, msg = check_requirements(state, node)
    if not ok then
        return false, msg
    end
    ok, msg = check_exclusive(state, node)
    if not ok then
        return false, msg
    end
    local pointCost = toint(node.point_cost, 1)
    if toint(node.branch, 0) > 0 and pointCost > 0
        and count_branch(state, node.branch) + pointCost > toint(Cfg.single_branch_limit, 40) then
        return false, "该灵根分支最多激活" .. tostring(toint(Cfg.single_branch_limit, 40)) .. "点#57"
    end
    if node.lane == "side" and pointCost > 0
        and count_side_nodes(state, node.branch) + pointCost > toint(Cfg.side_branch_limit, 6) then
        return false, "侧枝最多激活" .. tostring(toint(Cfg.side_branch_limit, 6)) .. "点#57"
    end
    if toint(state.normal_points, 0) < pointCost then
        return false, "天赋点不足#57"
    end
    if not silent and not has_cost(play, node.cost) then
        return false, "材料不足#57"
    end
    return true
end

local function has_pending(play, state)
    if state.normal_points <= 0 then
        local nextCfg = next_core_cfg(state)
        return nextCfg ~= nil and has_cost(play, nextCfg.cost)
    end
    for _, node in ipairs(Cfg.nodes or {}) do
        local ok = can_activate(play, state, node, true)
        if ok then
            return true
        end
    end
    return false
end

local function send_redpoint(play, state)
    local flag = has_pending(play, state) and "1" or "0"
    sendluamsg(play, 101, 1, 10, REDPOINT_ICON, flag)
    sendluamsg(play, 101, 9999, 0, 0, "npc_22")
end

local function build_payload(play, state)
    local _, special = aggregate_attributes(state)
    return {
        core_level = toint(state.core_level, 0),
        normal_points = state.normal_points,
        normal_total = state.normal_total,
        normal_external_total = state.normal_external_total,
        nodes = state.nodes,
        sockets = state.sockets,
        special = special,
    }
end

local function send_full(play, npcid, state)
    sendluamsg(play, 100, npcid or 22, 0, 0, tbl2json(build_payload(play, state)))
    send_redpoint(play, state)
end

send_partial = function(play, npcid, mode, node_id, state, gem_list, socket_result)
    local payload = build_payload(play, state)
    payload.gem_list = gem_list
    payload.socket_result = socket_result
    sendluamsg(play, 100, npcid or 22, mode or 1, 0, tbl2json({
        id = node_id,
        payload = payload,
    }))
    send_redpoint(play, state)
end

local function parse_request(p3, msg_data)
    if type(msg_data) == "string" and msg_data ~= "" then
        local ok, data = pcall(json2tbl, msg_data)
        if ok and type(data) == "table" then
            return data
        end
    end
    return {id = p3}
end

local function activate_node(play, npcid, request)
    local state = get_state(play)
    local node_id = tostring(request.id or "")
    local node = node_cfg(node_id)
    if is_m1_node(node) then
        local old_m1 = active_m1_node(state, node_id)
        if old_m1 then
            if request.switch == true then
                switch_m1(play, npcid, state, node, old_m1)
            else
                Player.sendmsgEx(play, "五行灵根只能选择一个核心，请先确认切换#57")
            end
            return
        end
    end
    local ok, msg = can_activate(play, state, node, false)
    if not ok then
        Player.sendmsgEx(play, msg or "该节点当前不可点亮#57")
        return
    end
    if not take_cost(play, node.cost, "天赋树节点消耗") then
        return
    end
    local pointCost = toint(node.point_cost, 1)
    state.normal_points = state.normal_points - pointCost
    state.nodes[node_id] = 1
    if type(node.cost) == "table" and #node.cost > 0 then
        state.spent_costs[node_id] = clone_cost(node.cost)
    else
        state.spent_costs[node_id] = nil
    end
    save_state(play, state)
    refresh_effects(play, state)
    touch_fairy_fate(play)
    Player.sendmsgEx(play, "天赋节点已点亮#7")
    send_partial(play, npcid, 1, node_id, state)
    if type(zxrw_try_finish_current_mainline) == "function" then
        zxrw_try_finish_current_mainline(play, "talent_tree")
    end
end

local function deactivate_node(play, npcid, request)
    local state = get_state(play)
    local node_id = tostring(request.id or "")
    local node = node_cfg(node_id)
    if not node or node.kind == "root" or not active(state, node_id) then
        Player.sendmsgEx(play, "该节点当前不可退回#57")
        return
    end
    if has_children(state, node_id) then
        Player.sendmsgEx(play, "请先退回外层连接节点#57")
        return
    end
    if not take_cost(play, get_single_reset_cost(node), "天赋树单独退点") then
        return
    end
    local refund = clone_cost(state.spent_costs[node_id] or node.cost or {})
    local socket_gem = state.sockets[node_id]
    if type(socket_gem) == "string" and socket_gem ~= "" and get_gem_def(socket_gem) then
        refund[#refund + 1] = {socket_gem, 1}
    end
    state.nodes[node_id] = nil
    state.sockets[node_id] = nil
    state.spent_costs[node_id] = nil
    state.normal_points = math.min(
        toint(state.normal_points, 0) + toint(node.point_cost, 1),
        toint(state.normal_total, 0)
    )
    save_state(play, state)
    local logic = get_skill_logic()
    if logic and logic.clear then
        logic.clear(play)
    end
    refresh_effects(play, state)
    refund_cost(play, refund, "天赋树节点返还")
    touch_fairy_fate(play)
    Player.sendmsgEx(play, "天赋节点已退回，点数已返还#7")
    send_partial(play, npcid, 2, node_id, state)
end

local function reset_tree(play, npcid)
    local state = get_state(play)
    if not take_cost(play, get_full_reset_cost(state), "天赋树洗点") then
        return
    end
    local refundMap = {}
    for node_id, value in pairs(state.nodes or {}) do
        if node_id ~= "root" and toint(value, 0) == 1 then
            local node = node_cfg(node_id)
            add_cost(refundMap, state.spent_costs[node_id] or (node and node.cost) or {})
        end
    end
    for gem_name, amount in pairs(collect_socket_refund(state)) do
        refundMap[gem_name] = (refundMap[gem_name] or 0) + amount
    end
    local refund = cost_map_to_list(refundMap)
    state.normal_points = state.normal_total
    state.nodes = {root = 1}
    state.sockets = {}
    state.special = {}
    state.spent_costs = {}
    state.reset_count = state.reset_count + 1
    save_state(play, state)
    local logic = get_skill_logic()
    if logic and logic.clear then
        logic.clear(play)
    end
    refresh_effects(play, state)
    refund_cost(play, refund, "天赋树洗点返还")
    touch_fairy_fate(play)
    Player.sendmsgEx(play, "天赋树已重置，点数已返还#7")
    send_partial(play, npcid, 3, "", state)
end

local function upgrade_core(play, npcid)
    local state = get_state(play)
    local levelCfg = next_core_cfg(state)
    if not levelCfg then
        Player.sendmsgEx(play, "灵根核心已满级#57")
        return
    end
    if not take_cost(play, levelCfg.cost or {}, "灵根核心升级") then
        return
    end
    state.core_level = toint(levelCfg.level, state.core_level + 1)
    local pointGain = toint(levelCfg.point_gain, 0)
    if pointGain > 0 then
        local canGain = math.max(0, toint(Cfg.normal_point_limit, 210) - toint(state.normal_total, 0))
        pointGain = math.min(pointGain, canGain)
        state.normal_total = state.normal_total + pointGain
        state.normal_points = state.normal_points + pointGain
    end
    save_state(play, state)
    refresh_effects(play, state)
    touch_fairy_fate(play)
    Player.sendmsgEx(play, "灵根核心升级成功#7")
    send_partial(play, npcid, 6, "root", state)
    if type(zxrw_try_finish_current_mainline) == "function" then
        zxrw_try_finish_current_mainline(play, "talent_tree")
    end
end

local function socket_gem(play, npcid, request)
    local state = get_state(play)
    local node_id = tostring(request.id or "")
    local node = node_cfg(node_id)
    if not node or (node.kind ~= "socket" and node.slot_type ~= "X") then
        Player.sendmsgEx(play, "该节点不是宝石槽#57")
        return
    end
    if not active(state, node_id) then
        Player.sendmsgEx(play, "需要先点亮宝石槽节点#57")
        return
    end
    local requested_gem = tostring(request.gem or "")
    if requested_gem == "" then
        send_partial(play, npcid, 4, node_id, state, get_owned_gems(play, node))
        return
    end
    local item_idx = tonumber(requested_gem) or tonumber(getstditeminfo(requested_gem, 0) or 0) or 0
    local item_name = item_idx > 0 and tostring(getstditeminfo(item_idx, 1) or requested_gem) or requested_gem
    local ok, gem_def, gem_level = can_socket_gem(node, item_name, item_idx)
    if not ok then
        Player.sendmsgEx(play, gem_def or "该宝石不能镶嵌在当前槽位#57")
        return
    end
    if tostring(state.sockets[node_id] or "") == item_name then
        Player.sendmsgEx(play, "该宝石已经镶嵌在当前槽位#57")
        return
    end
    if (tonumber(getbagitemcount(play, item_name) or 0) or 0) < 1 then
        Player.sendmsgEx(play, "背包中没有该宝石#57")
        return
    end
    local old_gem = state.sockets[node_id]
    local old_count = tonumber(getbagitemcount(play, item_name) or 0) or 0
    takeitem(play, item_name, 1)
    local new_count = tonumber(getbagitemcount(play, item_name) or 0) or 0
    if new_count >= old_count then
        Player.sendmsgEx(play, "宝石扣除失败，请稍后重试#57")
        return
    end
    state.sockets[node_id] = item_name
    save_state(play, state)
    refresh_effects(play, state)
    if type(old_gem) == "string" and old_gem ~= "" then
        refund_cost(play, {{old_gem, 1}}, "天赋树替换宝石返还")
    end
    touch_fairy_fate(play)
    Player.sendmsgEx(play, "宝石镶嵌成功，属性已刷新#7")
    send_partial(play, npcid, 4, node_id, state, get_owned_gems(play, node), 1)
end

function TalentTree.ensure(play)
    local state = get_state(play)
    save_state(play, state)
    return state
end

function TalentTree.hasBaseUnlock(play)
    return toint(get_state(play).initialized, 0) == 1
end

function TalentTree.getCoreLevel(play)
    return toint(get_state(play).core_level, 0)
end

function TalentTree.hasCoreLevel(play, level)
    return TalentTree.getCoreLevel(play) >= toint(level, 0)
end

function TalentTree.hasSocketGemLevel(play, level)
    level = toint(level, 0)
    if level <= 0 then
        return false
    end
    local state = get_state(play)
    for _, gem_name in pairs(state.sockets or {}) do
        local gem_def = get_gem_def(gem_name)
        if gem_def and get_gem_level(gem_name, gem_def) >= level then
            return true
        end
    end
    return false
end

function TalentTree.getAchievementSnapshot(play)
    local state = get_state(play)
    local branch_points = {}
    for branch = 1, 5 do
        branch_points[tostring(branch)] = count_branch(state, branch)
    end
    local gem_counts = {[3] = 0, [4] = 0}
    for _, gem_name in pairs(state.sockets or {}) do
        local gem_def = get_gem_def(gem_name)
        local gem_level = get_gem_level(gem_name, gem_def)
        if gem_level == 3 then
            gem_counts[3] = gem_counts[3] + 1
        elseif gem_level == 4 then
            gem_counts[4] = gem_counts[4] + 1
        end
    end
    return {
        core_level = toint(state.core_level, 0),
        branch_points = branch_points,
        gem_counts = gem_counts,
        gem3_count = gem_counts[3],
        gem4_count = gem_counts[4],
    }
end

function TalentTree.addNormalPoints(play, count, reason)
    count = math.max(0, toint(count, 0))
    if count <= 0 then
        return 0
    end
    local state = get_state(play)
    local leftExternal = math.max(0, toint(Cfg.external_normal_point_limit, 7) - toint(state.normal_external_total, 0))
    local leftTotal = math.max(0, toint(Cfg.normal_point_limit, 210) - toint(state.normal_total, 0))
    local gain = math.min(count, leftExternal, leftTotal)
    if gain <= 0 then
        return 0
    end
    state.normal_external_total = state.normal_external_total + gain
    state.normal_total = state.normal_total + gain
    state.normal_points = state.normal_points + gain
    save_state(play, state)
    Player.sendmsgEx(play, "获得普通天赋点 +" .. tostring(gain) .. "#7")
    send_redpoint(play, state)
    return gain
end

function TalentTree.getState(play)
    local state = get_state(play)
    local _, special = aggregate_attributes(state)
    state.special = type(special) == "table" and special or {}
    return state
end

function TalentTree.main(play, npcid)
    local state = TalentTree.ensure(play)
    refresh_effects(play, state)
    send_full(play, npcid or 22, state)
end

function TalentTree.link(play, npcid, action, p3, msg_data)
    if not Guard.ensurePlayer(play, npcid or 22) then
        return
    end
    action = Guard.normalizeAction(play, npcid or 22, action)
    if action == nil or not Guard.ensureActionAllowed(play, npcid or 22, action, Guard.newActionSet({1, 2, 3, 4, 5, 6})) then
        return
    end
    if action == 5 then
        return TalentTree.main(play, npcid or 22)
    end
    local request = parse_request(p3, msg_data)
    if action == 1 then
        activate_node(play, npcid or 22, request)
    elseif action == 2 then
        deactivate_node(play, npcid or 22, request)
    elseif action == 3 then
        reset_tree(play, npcid or 22)
    elseif action == 4 then
        socket_gem(play, npcid or 22, request)
    elseif action == 6 then
        upgrade_core(play, npcid or 22)
    end
end

function TalentTree.onLogin(play)
    local state = TalentTree.ensure(play)
    refresh_effects(play, state)
    send_redpoint(play, state)
end

function TalentTree.onLevelUp(play)
    -- New talent points come from Linggen core upgrades and reserved external
    -- systems, not from character level-up.
end

GameEvent.add(EventCfg.onLogin, TalentTree.onLogin, "TalentTree.onLogin")

local gemBox = include("lua/LuaLib/talent_tree_box.lua")
if type(gemBox) == "table" then
    rawset(_G, "LinggenGemBox", gemBox)
end

rawset(_G, "TalentTree", TalentTree)
return TalentTree
