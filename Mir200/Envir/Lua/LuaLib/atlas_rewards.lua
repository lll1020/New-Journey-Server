local Rewards = {}

-- Keep server-side item names encoding-safe for the GBK Lua runtime.
local function chars(...)
    return string.char(...)
end

local item = {
    gold = chars(189, 240, 177, 210),
    water = chars(187, 212, 210, 171, 203, 174, 190, 167),
    iron = chars(199, 167, 196, 234, 208, 254, 204, 250),
    hat = chars(182, 183, 243, 210, 203, 233, 198, 172),
    recharge = chars(49, 212, 170, 213, 230, 179, 228),
    abyss_ticket = chars(201, 238, 212, 168, 195, 197, 198, 177),
    soul = chars(209, 253, 185, 214, 190, 171, 198, 199),
    mid_dust = chars(214, 208, 189, 215, 208, 199, 179, 190),
    low_dust = chars(179, 245, 189, 215, 208, 199, 179, 190),
    nether_talisman = chars(190, 187, 210, 181, 183, 251),
    spirit_egg = chars(193, 233, 202, 222, 181, 176),
    page = chars(202, 233, 210, 179),
    key = chars(201, 241, 202, 175, 177, 166, 207, 228, 212, 191, 179, 215),
}

local function map_parts(map)
    local id = tostring(map and map.id or "")
    local continent, chapter = string.match(id, "^(%d+)_(%d+)$")
    return tonumber(continent or 0) or 0, tonumber(chapter or 0) or 0
end

local function list(...)
    return {...}
end

function Rewards.entry(kind, entry, map)
    local continent = map_parts(map)
    if kind == "monster" then
        local gold, max_attack
        if continent == 2 then
            gold, max_attack = 10000, 2
        elseif continent == 3 then
            gold, max_attack = 50000, 5
        elseif continent == 4 then
            gold, max_attack = 100000, 10
        elseif continent == 5 then
            gold, max_attack = 500000, 15
        elseif continent == 6 then
            gold, max_attack = 1000000, 30
        end
        if gold then
            return list({item.gold, gold}), {
                id = 4,
                min = 0,
                max = max_attack,
            }
        end
        return {}, nil
    end

    local water_count = ({
        [1] = 1,
        [2] = 1,
        [3] = 2,
        [4] = 3,
        [5] = 4,
        [6] = 5,
    })[continent]
    if water_count then
        return list({item.water, water_count}), nil
    end
    return {}, nil
end

function Rewards.chapter(kind, map, monster_count, equip_count)
    local continent, chapter = map_parts(map)
    local count = kind == "monster" and (monster_count or 0) or (equip_count or 0)
    if count <= 0 then
        return {}
    end

    if kind == "monster" then
        if continent == 2 then
            local hat_count = (chapter == 1 or chapter == 2) and 10 or 20
            local gold = chapter == 1 and 10000 or 50000
            return list(
                {item.gold, gold},
                {item.iron, 10 * count},
                {item.hat, hat_count}
            )
        elseif continent == 3 then
            return list(
                {item.gold, 500000},
                {item.iron, 10 * count},
                {item.water, count}
            )
        elseif continent == 4 then
            return list(
                {item.gold, 1000000},
                {item.iron, 20 * count},
                {item.water, 2 * count}
            )
        elseif continent == 5 then
            return list(
                {item.gold, 3000000},
                {item.abyss_ticket, count},
                {item.water, 3 * count}
            )
        elseif continent == 6 then
            return list(
                {item.gold, 5000000},
                {item.water, 5 * count},
                {item.mid_dust, count}
            )
        end
        return {}
    end

    if continent == 1 then
        return list(
            {item.recharge, 10},
            {item.gold, 5000000}
        )
    elseif continent == 2 then
        local hat_count = ({[1] = 10, [2] = 30, [3] = 50, [4] = 80})[chapter] or 10
        return list(
            {item.recharge, count},
            {item.iron, 20 * count},
            {item.hat, hat_count}
        )
    elseif continent == 3 then
        local chapter_key_count = math.min(chapter, 4)
        return list(
            {item.recharge, count},
            {item.page, count},
            {item.key, chapter_key_count}
        )
    elseif continent == 4 then
        local egg_count = ({[1] = 1, [2] = 1, [3] = 2, [4] = 2})[chapter] or 1
        return list(
            {item.recharge, count},
            {item.spirit_egg, egg_count},
            {item.soul, count}
        )
    elseif continent == 5 then
        return list(
            {item.recharge, count},
            {item.abyss_ticket, math.min(chapter, 6)}
        )
    elseif continent == 6 then
        return list(
            {item.recharge, count},
            {item.low_dust, 5 * count},
            {item.nether_talisman, math.min(chapter, 6)}
        )
    end
    return {}
end

return Rewards
