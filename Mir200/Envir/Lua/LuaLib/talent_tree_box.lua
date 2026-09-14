-- Talent tree gem box use logic.
-- The server item table remains the source of item names and indexes.
local BoxCfg = include("lua/Data/talent_tree_box.lua") or {}
local GemCfg = include("lua/Data/talent_tree_gems.lua") or {}

local SELECT_BOX_NAME = string.char(
    200, 253, 188, 182, 177, 166, 202, 175, 215, 212, 209, 161, 176, 252
)
local RANDOM_BOX_NAME = string.char(
    193, 233, 184, 249, 177, 166, 202, 175, 203, 230, 187, 250, 177, 166, 207, 228
)
local CHARGE_BOX_NAME = string.char(
    193, 233, 184, 249, 177, 166, 202, 175, 207, 228
)
local SELECT_HINT = string.char(
    199, 235, 209, 161, 212, 241, 210, 187, 191, 197, 200, 253, 188, 182,
    193, 233, 184, 249, 177, 166, 202, 175
)
local RECEIVE_PREFIX = string.char(187, 241, 181, 195, 163, 186)
local MISSING_PREFIX = string.char(200, 177, 201, 217)
local CONFIG_ERROR = string.char(197, 228, 214, 195, 210, 236, 179, 163)

local function _item_name(item_idx)
    return tostring(getstditeminfo(tonumber(item_idx) or 0, 1) or "")
end

local function _item_idx(item_name)
    return tonumber(getstditeminfo(item_name or "", 0) or 0) or 0
end

local function _configured_item_name(idx, fallback_name)
    idx = tonumber(idx) or 0
    if idx > 0 then
        local name = _item_name(idx)
        if name ~= "" then
            return name
        end
    end
    return fallback_name
end

local function _current_item_name(play, item)
    if not item then
        return ""
    end
    return tostring(getiteminfo(play, item, ConstCfg.iteminfo.name) or "")
end

local function _real_charge(play)
    local key = VarCfg and VarCfg["U_’Ê µ≥‰÷µ"]
    if not key then
        return 0
    end
    return tonumber(getplaydef(play, key) or 0) or 0
end

local function _take_one(play, item, item_name)
    item_name = tostring(item_name or "")
    if item_name == "" then
        return false
    end
    local before = tonumber(getbagitemcount(play, item_name) or 0) or 0
    if before < 1 then
        return false
    end
    if item then
        local make_index = getiteminfo(play, item, ConstCfg.iteminfo.id)
        if make_index then
            delitembymakeindex(play, make_index, 1)
        else
            takeitem(play, item_name, 1)
        end
    else
        takeitem(play, item_name, 1)
    end
    local after = tonumber(getbagitemcount(play, item_name) or 0) or 0
    return after < before
end

local function _give_one(play, item_name, reason)
    if item_name == "" then
        return false
    end
    if type(Player.rwjl) == "function" then
        Player.rwjl(play, {{item_name, 1}}, reason, 1, 1000)
    else
        giveitem(play, item_name, 1)
    end
    return true
end

local function _level3_pool()
    local pool = {}
    for _, item_idx in ipairs(BoxCfg.level3_gems or {}) do
        local idx = tonumber(item_idx) or 0
        local def = (GemCfg.items or {})[idx] or (GemCfg.items or {})[tostring(idx)]
        if def and tonumber(def.level) == 3 then
            local name = _item_name(idx)
            if name ~= "" then
                pool[#pool + 1] = {
                    idx = idx,
                    name = name,
                }
            end
        end
    end
    return pool
end

local function _set_pending_box(play, box_name)
    setplaydef(play, "S$linggen_gem_box", box_name or "")
end

local function _get_pending_box(play)
    return tostring(getplaydef(play, "S$linggen_gem_box") or "")
end

local function _open_select_window(play, box_name)
    local pool = _level3_pool()
    if #pool < 1 then
        Player.sendmsgEx(play, CONFIG_ERROR .. "#57")
        return false
    end

    _set_pending_box(play, box_name)
    local height = math.max(220, 126 + #pool * 42)
    local lines = {
        '<Img|id=ui_linggen_gem_box|x=0|y=0|width=390|height='
            .. tostring(height)
            .. '|img=public/bg_npc_01.png|bg=1|esc=1|move=0|reset=1|show=0|scale9l=15|scale9r=15|scale9t=15|scale9b=15>',
        '<Layout|id=ui_linggen_gem_close_area|x=347|y=3|width=36|height=40|link=@linggenGemCancel>',
        '<Button|id=ui_linggen_gem_close|x=352|y=3|width=26|height=40|nimg=public/1900000510.png|pimg=public/1900000511.png|color=255|size=18|link=@linggenGemCancel>',
        '<Text|id=ui_linggen_gem_title|x=28|y=23|color=251|size=18|text='
            .. SELECT_HINT .. '>',
    }
    for index, entry in ipairs(pool) do
        local y = 68 + (index - 1) * 42
        lines[#lines + 1] = '<Layout|id=ui_linggen_gem_hit_' .. tostring(index)
            .. '|x=27|y=' .. tostring(y - 4) .. '|width=330|height=38>'
        lines[#lines + 1] = '<Button|id=ui_linggen_gem_btn_' .. tostring(index)
            .. '|x=34|y=' .. tostring(y) .. '|width=316|height=32|nimg=public/1900000651_1.png|pimg=public/1900000651_1.png|color=255|size=18|text='
            .. entry.name .. '|link=@linggenGemSelect,' .. tostring(index) .. '>'
    end
    say(play, table.concat(lines, "\r\n"))
    return false
end

function linggenGemCancel(play)
    _set_pending_box(play, "")
    return false
end

function linggenGemSelect(play, code)
    local choice_index = tonumber(code) or 0
    local pool = _level3_pool()
    local choice = pool[choice_index]
    local box_name = _get_pending_box(play)
    if not choice or box_name == "" then
        Player.sendmsgEx(play, CONFIG_ERROR .. "#57")
        return false
    end
    if getbagitemcount(play, box_name) < 1 then
        _set_pending_box(play, "")
        Player.sendmsgEx(play, MISSING_PREFIX .. box_name .. "#57")
        return false
    end

    -- Consume first and clear the pending selection before granting anything.
    if not _take_one(play, nil, box_name) then
        _set_pending_box(play, "")
        Player.sendmsgEx(play, CONFIG_ERROR .. "#57")
        return false
    end
    _set_pending_box(play, "")
    _give_one(play, choice.name, box_name)
    Player.sendmsgEx(play, RECEIVE_PREFIX .. choice.name .. "#218")
    return false
end

local function use_select_box(play, item)
    local box_name = _current_item_name(play, item)
    if box_name == "" then
        box_name = _configured_item_name(BoxCfg.select_box_idx, SELECT_BOX_NAME)
    end
    if getbagitemcount(play, box_name) < 1 then
        Player.sendmsgEx(play, MISSING_PREFIX .. box_name .. "#57")
        return false
    end
    return _open_select_window(play, box_name)
end

local function use_charge_box(play, item, box_name)
    box_name = tostring(box_name or _current_item_name(play, item))
    if box_name == "" then
        box_name = CHARGE_BOX_NAME
    end
    if getbagitemcount(play, box_name) < 1 then
        Player.sendmsgEx(play, MISSING_PREFIX .. box_name .. "#57")
        return false
    end

    local weights = BoxCfg.charge_weights or {}
    local level1_weight = tonumber(weights.level1) or 70
    local level2_weight = tonumber(weights.level2) or 30
    local total_weight = level1_weight + level2_weight
    if total_weight <= 0 then
        Player.sendmsgEx(play, CONFIG_ERROR .. "#57")
        return false
    end

    local roll = math.random(total_weight)
    local reward_name
    local reward_desc
    if roll <= level1_weight then
        reward_name = _item_name((BoxCfg.common_gems or {})[1])
        reward_desc = "charge_level1"
    else
        reward_name = _item_name((BoxCfg.common_gems or {})[2])
        reward_desc = "charge_level2"
    end
    if reward_name == "" then
        Player.sendmsgEx(play, CONFIG_ERROR .. "#57")
        return false
    end

    if not _take_one(play, item, box_name) then
        Player.sendmsgEx(play, CONFIG_ERROR .. "#57")
        return false
    end
    _give_one(play, reward_name, box_name .. ":" .. reward_desc)
    Player.sendmsgEx(play, RECEIVE_PREFIX .. reward_name .. "#218")
    return false
end

local function use_random_box(play, item)
    local box_name = _current_item_name(play, item)
    if box_name == "" then
        box_name = _configured_item_name(BoxCfg.random_box_idx, RANDOM_BOX_NAME)
    end
    if box_name == CHARGE_BOX_NAME then
        return use_charge_box(play, item, box_name)
    end
    if getbagitemcount(play, box_name) < 1 then
        Player.sendmsgEx(play, MISSING_PREFIX .. box_name .. "#57")
        return false
    end

    local weights = BoxCfg.random_weights or {}
    local level1_weight = tonumber(weights.level1) or 70
    local level2_weight = tonumber(weights.level2) or 25
    local select_weight = tonumber(weights.select_level3) or 5
    local min_real_charge = tonumber(weights.select_level3_min_real_charge) or 300
    if _real_charge(play) < min_real_charge then
        select_weight = 0
    end
    local total_weight = level1_weight + level2_weight + select_weight
    if total_weight <= 0 then
        Player.sendmsgEx(play, CONFIG_ERROR .. "#57")
        return false
    end

    local roll = math.random(total_weight)
    local reward_name
    local reward_desc
    if roll <= level1_weight then
        reward_name = _item_name((BoxCfg.common_gems or {})[1])
        reward_desc = "level1"
    elseif roll <= level1_weight + level2_weight then
        reward_name = _item_name((BoxCfg.common_gems or {})[2])
        reward_desc = "level2"
    else
        reward_name = _configured_item_name(BoxCfg.select_box_idx, SELECT_BOX_NAME)
        reward_desc = "select_level3"
    end
    if reward_name == "" then
        Player.sendmsgEx(play, CONFIG_ERROR .. "#57")
        return false
    end

    -- Consume first, then grant the rolled result.
    if not _take_one(play, item, box_name) then
        Player.sendmsgEx(play, CONFIG_ERROR .. "#57")
        return false
    end
    _give_one(play, reward_name, box_name .. ":" .. reward_desc)
    Player.sendmsgEx(play, RECEIVE_PREFIX .. reward_name .. "#218")
    return false
end

function stdmodefunc33(play, item)
    return use_select_box(play, item)
end

function stdmodefunc34(play, item)
    return use_random_box(play, item)
end

local BoxLogic = {
    select_box_name = SELECT_BOX_NAME,
    random_box_name = RANDOM_BOX_NAME,
    charge_box_name = CHARGE_BOX_NAME,
    use_select_box = use_select_box,
    use_random_box = use_random_box,
    use_charge_box = use_charge_box,
}

rawset(_G, "LinggenGemBox", BoxLogic)
return BoxLogic
