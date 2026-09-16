local Atlas = {}
local AtlasCfg = dofile("Envir/Lua/Data/atlas_data.lua") or {}
local AtlasRewards = dofile("Envir/Lua/LuaLib/atlas_rewards.lua") or {}
local STATE_VAR = VarCfg.T_tujian or "T3"
local MSG_ID = 518
local REDPOINT_ICON = 23
local ATLAS_ATTR_LIST = "atlas_collection_attrs"
local MSG_ENTRY_INACTIVE = "¸ÃÍ¼¼øÉÐÎ´¼¤»î#57"
local MSG_ENTRY_CLAIMED = "¸ÃÍ¼¼ø½±ÀøÒÑ¾­ÁìÈ¡#57"
local MSG_CHAPTER_CLAIMED = "ÕÂ½Ú½±ÀøÒÑ¾­ÁìÈ¡#57"
local MSG_CHAPTER_INCOMPLETE = "ÕÂ½ÚÍ¼¼øÉÐÎ´È«²¿¼¤»î#57"
local REASON_ENTRY = "Í¼¼ø¼¤»î½±Àø"
local REASON_CHAPTER = "Í¼¼øÕÂ½Ú½±Àø"
local EntryIdIndex = {monster = {}, equip = {}}
local EntryNameIndex = {monster = {}, equip = {}}
local MapIndex = {}
local BossNameSet

local function normalize_state(state)
    state = type(state) == "table" and state or {}
    state.monster = type(state.monster) == "table" and state.monster or {}
    state.equip = type(state.equip) == "table" and state.equip or {}
    state.monster_claimed = type(state.monster_claimed) == "table" and state.monster_claimed or {}
    state.equip_claimed = type(state.equip_claimed) == "table" and state.equip_claimed or {}
    state.chapter_claimed = type(state.chapter_claimed) == "table" and state.chapter_claimed or {}
    state.monster_attr = type(state.monster_attr) == "table" and state.monster_attr or {}
    return state
end

local function get_state(play)
    return normalize_state(Player.getJsonTableByVar(play, STATE_VAR))
end

local function save_state(play, state)
    Player.setJsonVarByTable(play, STATE_VAR, normalize_state(state))
end

local function each_entry(kind, fn)
    for _, continent in ipairs(AtlasCfg.continents or {}) do
        for _, map in ipairs(continent.maps or {}) do
            for _, entry in ipairs(map[kind] or {}) do
                fn(entry, map, continent)
            end
        end
    end
end

local function refresh_attributes(play, state)
    local attack = 0
    for _, continent in ipairs(AtlasCfg.continents or {}) do
        for _, map in ipairs(continent.maps or {}) do
            for _, entry in ipairs(map.monster or {}) do
                local key = tostring(entry.id or "")
                if tonumber(state.monster_claimed[key] or 0) == 1 then
                    attack = attack + (tonumber(state.monster_attr[key]) or 0)
                end
            end
        end
    end
    if attack > 0 then
        Player.add_attlist(play, ATLAS_ATTR_LIST, "=", Player.getAttrTableToStr({[4] = attack}), 1)
    else
        Player.del_attlist(play, ATLAS_ATTR_LIST)
    end
    recalcabilitys(play)
end

local function find_entry(kind, id)
    local index = EntryIdIndex[kind]
    return index and index[tostring(id or "")]
end

local function normalize_name(name)
    name = tostring(name or "")
    name = string.gsub(name, "%s+", "")
    name = string.gsub(name, "\161\164", "")
    name = string.gsub(name, "\129\57\167\57", "")
    name = string.gsub(name, "\194\183", "")
    name = string.gsub(name, "\226\128\162", "")
    return name
end

local function build_indexes()
    for _, continent in ipairs(AtlasCfg.continents or {}) do
        for _, map in ipairs(continent.maps or {}) do
            local map_id = tostring(map.id or "")
            if map_id ~= "" and not MapIndex[map_id] then
                MapIndex[map_id] = {map = map, continent = continent}
            end
            for _, kind in ipairs({"monster", "equip"}) do
                for _, entry in ipairs(map[kind] or {}) do
                    local id = tostring(entry.id or "")
                    local found = {entry = entry, map = map, continent = continent}
                    if id ~= "" and not EntryIdIndex[kind][id] then
                        EntryIdIndex[kind][id] = found
                    end
                    local name_key = normalize_name(entry.name)
                    if name_key ~= "" and not EntryNameIndex[kind][name_key] then
                        EntryNameIndex[kind][name_key] = found
                    end
                end
            end
        end
    end
end

build_indexes()

local function find_by_name(kind, name)
    local index = EntryNameIndex[kind]
    return index and index[normalize_name(name)]
end

local function is_boss(mob_name)
    if not guaiwutype then
        return false
    end
    if not BossNameSet then
        BossNameSet = {}
        for name, kind in pairs(guaiwutype) do
            if tonumber(kind or 0) == 2 then
                BossNameSet[normalize_name(name)] = true
            end
        end
    end
    return BossNameSet[normalize_name(mob_name)] == true
end

local function is_continent_unlocked(play, continent)
    local id = tonumber(continent and continent.id or 0) or 0
    if id <= 1 then
        return id == 1
    end
    if Player and type(Player.dl_sz_notip) == "function" then
        return Player.dl_sz_notip(play, id) == true
    end
    return false
end

local function entry_activated(state, kind, entry)
    return tonumber(state[kind][tostring(entry.id)] or 0) == 1
end

local function chapter_ready(state, kind, map)
    local list = map[kind] or {}
    if #list == 0 then
        return false
    end
    for _, entry in ipairs(list) do
        if not entry_activated(state, kind, entry) then
            return false
        end
    end
    return true
end

local function has_pending(play, state)
    for _, continent in ipairs(AtlasCfg.continents or {}) do
        if is_continent_unlocked(play, continent) then
            for _, map in ipairs(continent.maps or {}) do
                for _, kind in ipairs({"monster", "equip"}) do
                    for _, entry in ipairs(map[kind] or {}) do
                        if entry_activated(state, kind, entry)
                            and tonumber(state[kind .. "_claimed"][tostring(entry.id)] or 0) ~= 1 then
                            return true
                        end
                    end
                    if chapter_ready(state, kind, map)
                        and tonumber(state.chapter_claimed[kind .. ":" .. tostring(map.id)] or 0) ~= 1 then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function send_redpoint(play)
    local state = get_state(play)
    sendluamsg(play, 101, 1, 10, REDPOINT_ICON, has_pending(play, state) and "1" or "0")
end

local function send_sync(play, mode, payload)
    sendluamsg(play, 101, MSG_ID, mode or 1, 0, tbl2json(payload or {}))
end

local function build_state_payload(play)
    local state = get_state(play)
    return {
        version = tonumber(AtlasCfg.version or 1) or 1,
        state = {
            monster = state.monster,
            equip = state.equip,
            monster_claimed = state.monster_claimed,
            equip_claimed = state.equip_claimed,
            chapter_claimed = state.chapter_claimed,
            monster_attr = state.monster_attr,
        },
    }
end

function Atlas.sendFull(play)
    send_sync(play, 1, build_state_payload(play))
    send_redpoint(play)
end

local function activate(play, kind, entry)
    local state = get_state(play)
    local key = tostring(entry.id)
    if tonumber(state[kind][key] or 0) ~= 1 then
        state[kind][key] = 1
        save_state(play, state)
        send_sync(play, 2, {
            kind = kind,
            id = key,
            activated = 1,
            claimed = tonumber(state[kind .. "_claimed"][key] or 0) == 1 and 1 or 0,
        })
        send_redpoint(play)
    end
end

function Atlas.onKillMon(play, mob)
    if not play or not mob then
        return
    end
    local name = tostring(getbaseinfo(mob, 1) or "")
    if name == "" or not is_boss(name) then
        return
    end
    local found = find_by_name("monster", name)
    if found and is_continent_unlocked(play, found.continent) then
        activate(play, "monster", found.entry)
    end
end

function Atlas.onAddBag(play, item)
    if not play or not item then
        return
    end
    local name = tostring(getiteminfo(play, item, 7) or "")
    if name == "" then
        return
    end
    local found = find_by_name("equip", name)
    if found and is_continent_unlocked(play, found.continent) then
        activate(play, "equip", found.entry)
    end
end

local function get_entry_reward(kind, found)
    if type(found.entry.reward) == "table" and #found.entry.reward > 0 then
        return found.entry.reward, found.entry.attr_reward
    end
    if AtlasRewards and type(AtlasRewards.entry) == "function" then
        return AtlasRewards.entry(kind, found.entry, found.map)
    end
    return {}, nil
end

local function claim_entry(play, kind, id)
    local found = find_entry(kind, id)
    if not found then
        return
    end
    if not is_continent_unlocked(play, found.continent) then
        return
    end
    local state = get_state(play)
    local key = tostring(found.entry.id)
    if tonumber(state[kind][key] or 0) ~= 1 then
        Player.sendmsgEx(play, MSG_ENTRY_INACTIVE)
        return
    end
    if tonumber(state[kind .. "_claimed"][key] or 0) == 1 then
        Player.sendmsgEx(play, MSG_ENTRY_CLAIMED)
        return
    end

    local reward, attr_cfg = get_entry_reward(kind, found)
    local attr_value
    if kind == "monster" and type(attr_cfg) == "table" then
        attr_value = tonumber(state.monster_attr[key])
        if attr_value == nil then
            local min_value = tonumber(attr_cfg.min or 0) or 0
            local max_value = tonumber(attr_cfg.max or min_value) or min_value
            if max_value < min_value then
                max_value = min_value
            end
            attr_value = math.random(min_value, max_value)
            state.monster_attr[key] = attr_value
        end
    end

    state[kind .. "_claimed"][key] = 1
    save_state(play, state)
    if type(reward) == "table" and #reward > 0 then
        Player.rwjl(play, reward, REASON_ENTRY, 1, 0)
    end
    if attr_value ~= nil then
        refresh_attributes(play, state)
    end
    send_sync(play, 3, {
        kind = kind,
        id = key,
        claimed = 1,
        attr_value = attr_value,
    })
    send_redpoint(play)
end

local function find_map(map_id)
    local found = MapIndex[tostring(map_id or "")]
    if found then
        return found.map, found.continent
    end
    return nil, nil
end

local function claim_chapter(play, kind, map_id)
    local found, found_continent = find_map(map_id)
    if not found then
        return
    end
    if not is_continent_unlocked(play, found_continent) then
        return
    end
    local state = get_state(play)
    local key = kind .. ":" .. tostring(found.id)
    if tonumber(state.chapter_claimed[key] or 0) == 1 then
        Player.sendmsgEx(play, MSG_CHAPTER_CLAIMED)
        return
    end
    if not chapter_ready(state, kind, found) then
        Player.sendmsgEx(play, MSG_CHAPTER_INCOMPLETE)
        return
    end
    state.chapter_claimed[key] = 1
    save_state(play, state)
    local reward = found[kind .. "_chapter_reward"] or found.chapter_reward or {}
    if type(reward) ~= "table" or #reward == 0 then
        if AtlasRewards and type(AtlasRewards.chapter) == "function" then
            reward = AtlasRewards.chapter(kind, found, #(found.monster or {}), #(found.equip or {}))
        else
            reward = {}
        end
    end
    if type(reward) == "table" and #reward > 0 then
        Player.rwjl(play, reward, REASON_CHAPTER, 1, 0)
    end
    send_sync(play, 4, {kind = kind, map_id = tostring(found.id), claimed = 1})
    send_redpoint(play)
end

function Atlas.main(play, p2, p3, msgData)
    if p2 == 0 then
        Atlas.sendFull(play)
    elseif p2 == 1 then
        local data = type(msgData) == "string" and msgData ~= "" and json2tbl(msgData) or {}
        claim_entry(play, tostring(data.kind or ""), data.id)
    elseif p2 == 2 then
        local data = type(msgData) == "string" and msgData ~= "" and json2tbl(msgData) or {}
        claim_chapter(play, tostring(data.kind or ""), data.map_id)
    elseif p2 == 3 then
        send_redpoint(play)
    end
end

GameEvent.add(EventCfg.onKillMon, Atlas.onKillMon, "atlas boss activation")
GameEvent.add(EventCfg.onAddBag, Atlas.onAddBag, "atlas equipment activation")
GameEvent.add(EventCfg.onLogin, function(play)
    local state = get_state(play)
    refresh_attributes(play, state)
    send_redpoint(play)
end, "atlas login refresh")

rawset(_G, "Atlas", Atlas)
return Atlas
