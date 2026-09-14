-- Talent tree gem box configuration.
-- Item names are resolved from the server item table by index.
local cfg = {
    select_box_stdmode = 33,
    random_box_stdmode = 34,
    -- Fill these when the item table has stable indexes. Name lookup is the fallback.
    select_box_idx = 0,
    random_box_idx = 0,
    charge_box_idx = 14262,
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
        -- Cumulative real recharge below this value cannot roll the level-3 selection box.
        select_level3_min_real_charge = 300,
    },
    charge_weights = {
        level1 = 70,
        level2 = 30,
    },
}

return cfg
