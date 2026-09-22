-- Talent tree gem whitelist.
-- This file is ASCII-only because the server Lua files use the legacy code page.
local ALL_ATTR_IDS = {280, 281, 282, 283, 284, 285, 286, 287, 288, 289, 290, 291, 300}

local function build_attrs(hp, block, defense, all_percent)
    local attrs = {
        {id = 1, value = hp},
        {id = 2, value = hp},
        {id = 244, value = block},
        {id = 10, value = defense},
        {id = 12, value = defense},
    }
    for _, attr_id in ipairs(ALL_ATTR_IDS) do
        attrs[#attrs + 1] = {id = attr_id, value = all_percent}
    end
    return attrs
end

local cfg = {
    version = 2,
    auto_discover = false,
    default_level = 1,
    items = {
        [14249] = {
            level = 1,
            attrs = build_attrs(2000, 50, 25, 1),
        },
        [14250] = {
            level = 2,
            attrs = build_attrs(5000, 100, 50, 2),
        },
        [14251] = {
            level = 3,
            element = "metal",
            attrs = build_attrs(20000, 400, 200, 3),
        },
        [14252] = {
            level = 3,
            element = "wood",
            attrs = build_attrs(20000, 400, 200, 3),
        },
        [14253] = {
            level = 3,
            element = "water",
            attrs = build_attrs(20000, 400, 200, 3),
        },
        [14254] = {
            level = 3,
            element = "fire",
            attrs = build_attrs(20000, 400, 200, 3),
        },
        [14255] = {
            level = 3,
            element = "earth",
            attrs = build_attrs(20000, 400, 200, 3),
        },
        [14256] = {
            level = 4,
            attrs = build_attrs(20000, 400, 200, 3),
        },
    },
}

return cfg
