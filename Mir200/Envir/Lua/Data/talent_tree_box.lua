-- Talent tree gem box configuration.
-- Item names are resolved from the server item table by index.
local cfg = {
    select_box_stdmode = 33,
    random_box_stdmode = 34,
    -- Fill these when the item table has stable indexes. Name lookup is the fallback.
    select_box_idx = 0,
    random_box_idx = 0,
    common_gems = {
        [1] = 14249,
        [2] = 14250,
    },
    level3_gems = {
        14251,
        14252,
        14253,
        14254,
        14255,
    },
    random_weights = {
        level1 = 70,
        level2 = 25,
        select_level3 = 5,
    },
}

return cfg
