-- 异闻录：剧情完成判定辅助
local _xyl_name_map

local function _xyl_norm_name(name)
    if not name then
        return ""
    end
    local v = tostring(name)
    v = v:gsub("（.-）", "")
    v = v:gsub("%s+", "")
    v = v:gsub("　", "")
    return v
end

local function _xyl_build_name_map()
    local map = {}
    local data = teshudata or {}
    for key, cfg in pairs(data) do
        if type(key) == "string" and key:match("^npc_%d+$") and type(cfg) == "table" and cfg.name then
            map[_xyl_norm_name(cfg.name)] = key
        end
    end
    return map
end

local function _xyl_get_npc_key(name)
    if not _xyl_name_map then
        _xyl_name_map = _xyl_build_name_map()
    end
    return _xyl_name_map[_xyl_norm_name(name)]
end

local function _xyl_check_story(play, name)
    local key = _xyl_get_npc_key(name)
    if not key then
        return false
    end
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local node = jq_data[key]
    if type(node) == "number" then
        return node >= 2
    end
    if type(node) == "table" then
        if node.wc and node.wc >= 1 then
            return true
        end
        if node.finish and node.finish >= 1 then
            return true
        end
        if node.done and node.done >= 1 then
            return true
        end
        if node.ok and node.ok >= 1 then
            return true
        end
    end
    return false
end

local function _xyl_has_title(play, title)
    if not title or title == "" then
        return false
    end
    return checktitle(play, title)
end

local function _xyl_has_item(play, name, count)
    if not name or name == "" then
        return false
    end
    local miss = Player.checkItemNumByTable(play, {{name, count or 1}})
    return not miss
end

local function _xyl_has_any_item(play, list)
    if type(list) ~= "table" then
        return false
    end
    for _, name in ipairs(list) do
        if _xyl_has_item(play, name, 1) then
            return true
        end
    end
    return false
end

local function _xyl_has_equip_named(play, where, name)
    if not where or not name then
        return false
    end
    local equipName = Player.getEquipNameByPos(play, where)
    return equipName == name
end

local function _xyl_has_tianshu_level(play)
    local data = Player.getJsonTableByVar(play, VarCfg["T_天书"])
    return (data.level or 0) >= 1
end

local function _xyl_has_any_xianfa(play)
    local data = Player.getJsonTableByVar(play, VarCfg["T_天书"])
    local caowei = data.caowei or {}
    for _, v in pairs(caowei) do
        if type(v) == "table" then
            return true
        end
    end
    if data.tj then
        for _ in pairs(data.tj) do
            return true
        end
    end
    return false
end

local function _xyl_has_red_xianfa(play)
    local data = Player.getJsonTableByVar(play, VarCfg["T_天书"])
    local caowei = data.caowei or {}
    for _, v in pairs(caowei) do
        if type(v) == "table" and tonumber(v[1]) and tonumber(v[1]) >= 5 then
            return true
        end
    end
    return false
end

local function _xyl_has_equip_strength(play)
    local cfg = teshudata and teshudata["npc_28"]
    if not (cfg and cfg.where) then
        return false
    end
    for _, info in pairs(cfg.where) do
        local part = info[1]
        if part then
            local lv = getplaydef(play, VarCfg["U_装备强化_" .. part])
            if tonumber(lv) and tonumber(lv) > 0 then
                return true
            end
        end
    end
    return false
end

local function _xyl_has_linggen_feed(play)
    local data = Player.getJsonTableByVar(play, VarCfg["T_灵根"])
    local levels = data.level or {}
    for _, v in pairs(levels) do
        if tonumber(v) and tonumber(v) > 0 then
            return true
        end
    end
    return false
end

local function _xyl_has_lucky_upgrade(play)
    return (getplaydef(play, VarCfg["U_幸运强化"]) or 0) > 0
end

local function _xyl_has_divination(play)
    return (getplaydef(play, VarCfg["U_占卜次数"]) or 0) > 0
end

local function _xyl_has_rebirth(play, level)
    return (getplaydef(play, VarCfg["U_转生等级"]) or 0) >= (level or 1)
end

local function _xyl_has_legendary_stone(play)
    local cfg = teshudata and teshudata["npc_53"]
    local list = cfg and cfg.cost and cfg.cost[3]
    return _xyl_has_any_item(play, list)
end

local function _xyl_has_legendary_hat(play)
    local cfg = teshudata and teshudata["npc_51"]
    if cfg and cfg.where and cfg.give then
        if _xyl_has_equip_named(play, cfg.where, cfg.give) then
            return true
        end
        return _xyl_has_item(play, cfg.give, 1)
    end
    return false
end

local function _xyl_has_god_gourd(play)
    local cfg = teshudata and teshudata["npc_52"]
    if cfg and cfg.where and cfg.give then
        if _xyl_has_equip_named(play, cfg.where, cfg.give) then
            return true
        end
        return _xyl_has_item(play, cfg.give, 1)
    end
    return false
end

local function _xyl_has_advanced_quench(play)
    local cfg = teshudata and teshudata["npc_54"]
    if cfg and cfg.title and _xyl_has_title(play, cfg.title) then
        return true
    end
    local maxLevel = (cfg and cfg.max_level) or 0
    if maxLevel <= 0 then
        return false
    end
    local data = Player.getJsonTableByVar(play, VarCfg["T_灵根修炼"])
    for i = 1, 5 do
        if (data[tostring(i)] or 0) < maxLevel then
            return false
        end
    end
    return true
end

local function _xyl_has_xianfu_open(play)
    local data = Player.getJsonTableByVar(play, VarCfg.T_XianFuData)
    return next(data or {}) ~= nil
end

local function _xyl_has_xianfu_refine(play)
    local data = Player.getJsonTableByVar(play, VarCfg.T_XianFuData)
    local refine = data and data.refine and data.refine.collection
    if type(refine) == "table" then
        for _ in pairs(refine) do
            return true
        end
    end
    return false
end

local function _xyl_has_xianfu_plant(play)
    local data = Player.getJsonTableByVar(play, VarCfg.T_XianFuData)
    local fields = data and data.fields
    if type(fields) == "table" then
        for _, plot in pairs(fields) do
            if type(plot) == "table" and plot.state and plot.state ~= "empty" then
                return true
            end
        end
    end
    local herbs = data and data.herbs
    if type(herbs) == "table" then
        for _, v in pairs(herbs) do
            if tonumber(v) and tonumber(v) > 0 then
                return true
            end
        end
    end
    return false
end

local function _xyl_has_tree(play)
    local data = Player.getJsonTableByVar(play, VarCfg["T_砍树系统"])
    return next(data or {}) ~= nil
end

local function _xyl_has_treasure(play)
    return (getplaydef(play, VarCfg["J_今日藏宝图次数"]) or 0) > 0
end

local function _xyl_has_lingshou_star(play, star)
    local cfg = teshudata and teshudata["npc_64"]
    local count = 0
    if cfg and cfg.config and cfg.config.ls then
        count = #cfg.config.ls
    end
    if count <= 0 then
        return false
    end
    local data = Player.getJsonTableByVar(play, VarCfg["T_灵兽"])
    local ls_sp = data.ls_sp or {}
    for i = 1, count do
        if (ls_sp[tostring(i)] or 0) < star then
            return false
        end
    end
    return true
end

local function _xyl_has_tang_antique(play)
    local cfg = teshudata and teshudata["npc_65"]
    if not (cfg and cfg.config) then
        return false
    end
    local list = {}
    for _, it in ipairs(cfg.config) do
        for _, jl in ipairs(it.jl or {}) do
            if type(jl[1]) == "string" and jl[1]:find("【唐代】") then
                table.insert(list, jl[1])
            end
        end
    end
    return _xyl_has_any_item(play, list)
end

local function _xyl_has_shengxiao_guard(play)
    local data = Player.getJsonTableByVar(play, VarCfg["T_生肖守护"])
    if data["jl_all"] and data["jl_all"] == 1 then
        return true
    end
    for i = 1, 12 do
        if not (data[tostring(i)] and data[tostring(i)] == 1) then
            return false
        end
    end
    return true
end

local function _xyl_check_task(play, name)
    local key = _xyl_norm_name(name)
    local special = {
        ["天书强化"] = _xyl_has_tianshu_level,
        ["初识仙法"] = _xyl_has_any_xianfa,
        ["装备强化"] = _xyl_has_equip_strength,
        ["喂养灵根"] = _xyl_has_linggen_feed,
        ["幸运增幅"] = _xyl_has_lucky_upgrade,
        ["气运占卜"] = _xyl_has_divination,
        ["转生·二"] = function(play) return _xyl_has_rebirth(play, 2) end,
        ["转生·三"] = function(play) return _xyl_has_rebirth(play, 3) end,
        ["转生·四"] = function(play) return _xyl_has_rebirth(play, 4) end,
        ["拥有1传说神石"] = _xyl_has_legendary_stone,
        ["传说·斗笠"] = _xyl_has_legendary_hat,
        ["神·酒葫芦"] = _xyl_has_god_gourd,
        ["高级淬体"] = _xyl_has_advanced_quench,
        ["开辟仙府"] = _xyl_has_xianfu_open,
        ["炼制丹药"] = _xyl_has_xianfu_refine,
        ["了解砍树"] = _xyl_has_tree,
        ["种植仙草"] = _xyl_has_xianfu_plant,
        ["寻宝大师"] = _xyl_has_treasure,
        ["灵兽全一星"] = function(play) return _xyl_has_lingshou_star(play, 1) end,
        ["灵兽全二星"] = function(play) return _xyl_has_lingshou_star(play, 2) end,
        ["灵兽全三星"] = function(play) return _xyl_has_lingshou_star(play, 3) end,
        ["唐代古玩"] = _xyl_has_tang_antique,
        ["红色仙法"] = _xyl_has_red_xianfa,
        ["生肖守护"] = _xyl_has_shengxiao_guard,
        ["修复轩辕剑"] = function(play)
            local cfg = teshudata and teshudata["npc_601"]
            return cfg and cfg.details and _xyl_has_title(play, cfg.details.ch)
        end,
        ["灾厄入侵"] = function(play)
            local cfg = teshudata and teshudata["npc_46"]
            return cfg and _xyl_has_title(play, cfg.ch)
        end,
        ["兵道之谜"] = function(play)
            return _xyl_check_story(play, "古刹之谜")
        end,
    }
    if special[key] then
        return special[key](play)
    end
    return _xyl_check_story(play, key)
end
local npc_xyl = {
    {
        {
            jq = {
                {
                    "扫荡野火帮（剧）",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "扫荡野火帮（剧）")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "剿灭恶徒（剧）",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "剿灭恶徒（剧）")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "天书强化",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "天书强化")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "初识仙法",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "初识仙法")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
            },
            name = "初入江湖",

            jqd = 0,

            jl = { { "1元真实充值", 1 }, { "激活金灵根", 1 } },
        },
        {
            jq = {
                {
                    "杀伐之路（剧）",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "杀伐之路（剧）")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "讨伐夜魔（剧）",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "讨伐夜魔（剧）")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "装备强化",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "装备强化")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "喂养灵根",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "喂养灵根")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
            },
            name = "小试牛刀",

            jqd = 4,

            jl = { { "1元真实充值", 1 }, { "激活木灵根", 1 } },
        },
        {
            jq = {
                {
                    "修复轩辕剑（剧）",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "修复轩辕剑（剧）")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "深入野火（剧）",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "深入野火（剧）")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "守护森林（剧）",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "守护森林（剧）")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "兵道之谜（剧）",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "兵道之谜（剧）")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "幸运增幅",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "幸运增幅")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "气运占卜",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "气运占卜")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "转生·二",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "转生·二")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
            },
            name = "漫漫仙途",

            jqd = 8,

            jl = { { "1元真实充值", 1 }, { "激活水灵根", 1 } },
        },
    },
    {
        {
            jq = {
                {
                    "拥有1传说神石",
                    id = 999,
                    jl = { { "剧情点", 3 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "拥有1传说神石")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "转生·三",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "转生·三")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "传说·斗笠",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "传说·斗笠")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "神·酒葫芦",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "神·酒葫芦")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "高级淬体",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "高级淬体")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
            },
            name = "苍云秘闻",

            jqd = 15,

            jl = { { "1元真实充值", 5 }, { "等级卷轴", 5 } },
        },
        {
            jq = {
                {
                    "开辟仙府（主城NPC）",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "开辟仙府（主城NPC）")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "炼制丹药",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "炼制丹药")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "了解砍树",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "了解砍树")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "种植仙草",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "种植仙草")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "寻宝大师",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "寻宝大师")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
            },
            name = "初入苍云",

            jqd = 15,

            jl = { { "1元真实充值", 2 }, { "激活火灵根", 1 } },
        },
        {
            jq = {
                {
                    "杀戮的欲望",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "杀戮的欲望")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "沉船之谜",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "沉船之谜")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "船长的宝藏",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "船长的宝藏")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "谁是内鬼",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "谁是内鬼")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
            },
            name = "外海之旅",

            jqd = 21,

            jl = { { "1元真实充值", 2 }, { "激活土灵根", 1 } },
        },
        {
            jq = {
                {
                    "送葬者",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "送葬者")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "热血的友情",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "热血的友情")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "真正的海贼王",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "真正的海贼王")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "海滩拾贝",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "海滩拾贝")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "海盗宝藏",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "海盗宝藏")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
            },
            name = "内海探秘",

            jqd = 25,

            jl = { { "1元真实充值", 2 }, { "神石宝箱钥匙", 1 } },
        },
        {
            jq = {
                {
                    "采仙草咯",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "采仙草咯")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "丹仙秘辛",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "丹仙秘辛")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "棋痴老王",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "棋痴老王")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
            },
            name = "平步青云",

            jqd = 32,

            jl = { { "1元真实充值", 2 }, { "神石宝箱钥匙", 1 } },
        },
        {
            jq = {
                {
                    "灾厄入侵",
                    id = 999,
                    jl = {},
                    fwdjy = function(play)
                        return _xyl_check_task(play, "灾厄入侵")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "讨伐嘲灾",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "讨伐嘲灾")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "讨伐忌灾",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "讨伐忌灾")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "讨伐息灾",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "讨伐息灾")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "讨伐妄灾",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "讨伐妄灾")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "踏入·虚妄山脉",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "踏入·虚妄山脉")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "踏入·叹息旷野",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "踏入·叹息旷野")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "踏入·鬼嘲深渊",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "踏入·鬼嘲深渊")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "踏入·禁忌之海",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "踏入·禁忌之海")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
            },
            name = "灭世灾厄",

            jqd = 37,

            jl = { { "1元真实充值", 5 }, { "神石宝箱钥匙", 2 } },
        },
    },
    {
        {
            jq = {
                {
                    "灵兽全一星",
                    id = 999,
                    jl = { { "剧情点", 3 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "灵兽全一星")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "灵兽全二星",
                    id = 999,
                    jl = { { "剧情点", 5 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "灵兽全二星")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "灵兽全三星",
                    id = 999,
                    jl = { { "剧情点", 10 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "灵兽全三星")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "唐代古玩",
                    id = 999,
                    jl = { { "剧情点", 3 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "唐代古玩")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "红色仙法",
                    id = 999,
                    jl = { { "剧情点", 3 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "红色仙法")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "转生·四",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "转生·四")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
            },
            name = "若水秘闻",

            jqd = 50,

            jl = { { "等级卷轴", 20 }, { "1元真实充值", 25 } },
        },
        {
            jq = {
                {
                    "捉鬼人",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "捉鬼人")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "买路钱",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "买路钱")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "思念之人",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "思念之人")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "忘却前生情",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "忘却前生情")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "讨伐六天宫",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "讨伐六天宫")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "地狱使者",
                    id = 999,
                    jl = { { "剧情点", 3 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "地狱使者")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "轮回之路",
                    id = 999,
                    jl = { { "剧情点", 3 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "轮回之路")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
            },
            name = "地府探秘",

            jqd = 50,

            jl = { { "等级卷轴", 5 }, { "1元真实充值", 8 } },
        },
        {
            jq = {
                {
                    "资格考验",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "资格考验")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "龙王的噩梦",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "龙王的噩梦")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "我的袈裟！",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "我的袈裟！")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "黄风大圣",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "黄风大圣")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "你竟是女王？",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "你竟是女王？")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "驮我过河",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "驮我过河")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "大闹狮驼岭",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "大闹狮驼岭")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "真假经书",
                    id = 999,
                    jl = { { "剧情点", 3 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "真假经书")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "重走西游路",
                    id = 999,
                    jl = {},
                    fwdjy = function(play)
                        return _xyl_check_task(play, "重走西游路")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
            },
            name = "重走西游",

            jqd = 60,

            jl = { { "等级卷轴", 10 }, { "1元真实充值", 15 } },
        },
        {
            jq = {
                {
                    "天鼠的游戏",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "天鼠的游戏")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "天牛的游戏",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "天牛的游戏")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "天虎的游戏",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "天虎的游戏")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "天兔的游戏",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "天兔的游戏")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "灵域使者·一",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "灵域使者·一")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
            },
            name = "生肖守护[始]",

            jqd = 75,

            jl = { { "等级卷轴", 5 }, { "1元真实充值", 8 } },
        },
        {
            jq = {
                {
                    "天龙的游戏",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "天龙的游戏")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "天蛇的游戏",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "天蛇的游戏")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "天马的游戏",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "天马的游戏")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "天羊的游戏",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "天羊的游戏")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "灵域使者·二",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "灵域使者·二")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
            },
            name = "生肖守护[转]",

            jqd = 82,

            jl = { { "等级卷轴", 5 }, { "1元真实充值", 8 } },
        },
        {
            jq = {
                {
                    "天猴的游戏",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "天猴的游戏")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "天鸡的游戏",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "天鸡的游戏")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "天狗的游戏",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "天狗的游戏")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "天猪的游戏",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "天猪的游戏")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "灵域使者·三",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "灵域使者·三")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "生肖守护",
                    id = 999,
                    jl = { { "剧情点", 5 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "生肖守护")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
            },
            name = "生肖守护[终]",

            jqd = 80,

            jl = { { "等级卷轴", 5 }, { "1元真实充值", 8 } },
        },
        {
            jq = {
                {
                    "传说修复局",
                    id = 999,
                    jl = {},
                    fwdjy = function(play)
                        return _xyl_check_task(play, "传说修复局")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "盘古开天",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "盘古开天")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "羿射九日",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "羿射九日")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "共公怒触不周山",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "共公怒触不周山")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "女娲补天",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "女娲补天")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "后土娘娘",
                    id = 999,
                    jl = { { "剧情点", 3 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "后土娘娘")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "黑白无常",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "黑白无常")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "真假玉帝",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "真假玉帝")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
                {
                    "白蛇传说",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "白蛇传说")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "",
                },
            },
            name = "修复传说",

            jqd = 89,

            jl = { { "等级卷轴", 10 }, { "1元真实充值", 15 } },
        },
    },
    {
        {
            jq = {},
            name = "红尘秘闻",
            jqd = 100,
            jl = { { "等级卷轴", 20 }, { "1元真实充值", 25 } },
        },
        {
            jq = {},
            name = "守护时空",
            jqd = 100,
            jl = { { "等级卷轴", 10 }, { "1元真实充值", 15 } },
        },
        {
            jq = {},
            name = "生命边界",
            jqd = 115,
            jl = { { "等级卷轴", 10 }, { "1元真实充值", 15 } },
        },
        {
            jq = {},
            name = "聊斋志异",
            jqd = 120,
            jl = { { "等级卷轴", 10 }, { "1元真实充值", 15 } },
        },
        {
            jq = {},
            name = "敦煌遗梦",
            jqd = 126,
            jl = { { "等级卷轴", 10 }, { "1元真实充值", 15 } },
        },
        {
            jq = {},
            name = "重启世界",
            jqd = 133,
            jl = { { "等级卷轴", 10 }, { "1元真实充值", 15 } },
        },
    },
}
return npc_xyl















