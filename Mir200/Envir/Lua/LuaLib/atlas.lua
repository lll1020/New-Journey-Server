local Atlas = {}
local AtlasCfg = dofile("Envir/Lua/Data/atlas_data.lua") or {}
local STATE_VAR = VarCfg.T_tujian or "T3"
local MSG_ID = 518
local REDPOINT_ICON = 23

local function normalize_state(state)
    state = type(state) == "table" and state or {}
    state.monster = type(state.monster) == "table" and state.monster or {}
    state.equip = type(state.equip) == "table" and state.equip or {}
    state.monster_claimed = type(state.monster_claimed) == "table" and state.monster_claimed or {}
    state.equip_claimed = type(state.equip_claimed) == "table" and state.equip_claimed or {}
    state.chapter_claimed = type(state.chapter_claimed) == "table" and state.chapter_claimed or {}
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

local function find_entry(kind, id)
    local found
    each_entry(kind, function(entry, map, continent)
        if not found and tostring(entry.id or "") == tostring(id or "") then
            found = {entry = entry, map = map, continent = continent}
        end
    end)
    return found
end

local function find_by_name(kind, name)
    local found
    each_entry(kind, function(entry, map, continent)
        if not found and tostring(entry.name or "") == tostring(name or "") then
            found = {entry = entry, map = map, continent = continent}
        end
    end)
    return found
end

local function is_boss(mob_name)
    return tonumber((guaiwutype and guaiwutype[mob_name]) or 0) == 2
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

local function has_pending(state)
    local pending = false
    each_entry("monster", function(entry, map)
        if entry_activated(state, "monster", entry)
            and tonumber(state.monster_claimed[tostring(entry.id)] or 0) ~= 1 then
            pending = true
        end
        if chapter_ready(state, "monster", map)
            and tonumber(state.chapter_claimed["monster:" .. tostring(map.id)] or 0) ~= 1 then
            pending = true
        end
    end)
    each_entry("equip", function(entry, map)
        if entry_activated(state, "equip", entry)
            and tonumber(state.equip_claimed[tostring(entry.id)] or 0) ~= 1 then
            pending = true
        end
        if chapter_ready(state, "equip", map)
            and tonumber(state.chapter_claimed["equip:" .. tostring(map.id)] or 0) ~= 1 then
            pending = true
        end
    end)
    return pending
end

local function send_redpoint(play)
    sendluamsg(play, 101, 1, 10, REDPOINT_ICON, has_pending(get_state(play)) and "1" or "0")
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
        },
    }
end

function Atlas.sendFull(play)
    -- Static map, monster, equipment, model, and reward data are kept by the client.
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
    end
    send_redpoint(play)
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
    if found then
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
    if found then
        activate(play, "equip", found.entry)
    end
end

local function claim_entry(play, kind, id)
    local found = find_entry(kind, id)
    if not found then
        return
    end
    local state = get_state(play)
    local key = tostring(found.entry.id)
    if tonumber(state[kind][key] or 0) ~= 1 then
        Player.sendmsgEx(play, "¸ÃÍ¼¼øÉÐÎ´¼¤»î#57")
        return
    end
    if tonumber(state[kind .. "_claimed"][key] or 0) == 1 then
        Player.sendmsgEx(play, "¸ÃÍ¼¼ø½±ÀøÒÑ¾­ÁìÈ¡#57")
        return
    end
    state[kind .. "_claimed"][key] = 1
    save_state(play, state)
    if type(found.entry.reward) == "table" and #found.entry.reward > 0 then
        Player.rwjl(play, found.entry.reward, "Í¼¼ø¼¤»î½±Àø", 1, 0)
    end
    send_sync(play, 3, {kind = kind, id = key, claimed = 1})
    send_redpoint(play)
end

local function claim_chapter(play, kind, map_id)
    local found
    for _, continent in ipairs(AtlasCfg.continents or {}) do
        for _, map in ipairs(continent.maps or {}) do
            if tostring(map.id or "") == tostring(map_id or "") then
                found = map
                break
            end
        end
    end
    if not found then
        return
    end
    local state = get_state(play)
    local key = kind .. ":" .. tostring(found.id)
    if tonumber(state.chapter_claimed[key] or 0) == 1 then
        Player.sendmsgEx(play, "ÕÂ½Ú½±ÀøÒÑ¾­ÁìÈ¡#57")
        return
    end
    if not chapter_ready(state, kind, found) then
        Player.sendmsgEx(play, "ÕÂ½ÚÍ¼¼øÉÐÎ´È«²¿¼¤»î#57")
        return
    end
    state.chapter_claimed[key] = 1
    save_state(play, state)
    if type(found.chapter_reward) == "table" and #found.chapter_reward > 0 then
        Player.rwjl(play, found.chapter_reward, "Í¼¼øÕÂ½Ú½±Àø", 1, 0)
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

GameEvent.add(EventCfg.onKillMon, Atlas.onKillMon, "Í¼¼øBOSS¼¤»î")
GameEvent.add(EventCfg.onAddBag, Atlas.onAddBag, "Í¼¼ø×°±¸¼¤»î")
GameEvent.add(EventCfg.onLogin, function(play)
    send_redpoint(play)
end, "Í¼¼øºìµãµÇÂ¼Ë¢ÐÂ")

rawset(_G, "Atlas", Atlas)
return Atlas
