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
    if not name then
        return nil
    end
    local v = tostring(name)
    if v:match("^npc_%d+$") then
        return v
    end
    return nil
end

-- 备注：通用剧情完成判定（读取 T_dljq，优先称号，其次次数/完成标记）
local function _xyl_check_story(play, name)
    local key = _xyl_get_npc_key(name)
    if not key then
        return false
    end
    local cfg = teshudata and teshudata[key]
    local max_num = cfg and cfg.max_num
    if cfg and cfg.ch and checktitle(play, cfg.ch) then
        return true
    end
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local node = jq_data[key]
    if type(node) == "number" then
        if max_num and max_num > 0 then
            return node >= max_num
        end
        return node >= 2
    end
    if type(node) == "table" then
        if max_num and max_num > 0 then
            local cnt = node.cnt or node.num
            if tonumber(cnt) then
                return tonumber(cnt) >= max_num
            end
        end
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

-- 备注：是否已拥有指定称号
local function _xyl_has_title(play, title)
    if not title or title == "" then
        return false
    end
    return checktitle(play, title)
end

-- 备注：背包道具数量是否满足
local function _xyl_has_item(play, name, count)
    if not name or name == "" then
        return false
    end
    local miss = Player.checkItemNumByTable(play, {{name, count or 1}})
    return not miss
end

-- 备注：列表内任意道具满足即可
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

-- 备注：指定部位是否装备指定名称物品
local function _xyl_has_equip_named(play, where, name)
    if not where or not name then
        return false
    end
    local equipName = Player.getEquipNameByPos(play, where)
    return equipName == name
end

-- 备注：天书等级是否达到 1 级
local function _xyl_has_tianshu_level(play)
    local data = Player.getJsonTableByVar(play, VarCfg["T_天书"])
    return (data.level or 0) >= 1
end

-- 备注：天书是否已配置任意仙法
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

-- 备注：天书是否拥有红色仙法
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

-- 备注：任意装备强化等级 > 0
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

-- 备注：灵根喂养任意等级 > 0
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

-- 备注：江湖称号任务改为查看界面即可完成，不再要求实际升级称号等级
local function _xyl_has_jianghu_title(play)
    return (tonumber(getplaydef(play, "N$查看江湖称号") or 0) or 0) > 0
end

-- 备注：是否已装配主灵根
local function _xyl_has_main_linggen(play)
    local data = Player.getJsonTableByVar(play, VarCfg["T_灵根"])
    return (tonumber(data.main) or 0) > 0
end

-- 备注：是否已装配副灵根
local function _xyl_has_other_linggen(play)
    local data = Player.getJsonTableByVar(play, VarCfg["T_灵根"])
    return (tonumber(data.other) or 0) > 0
end

-- 备注：气运占卜次数是否大于 0
local function _xyl_has_divination(play)
    return (getplaydef(play, VarCfg["U_占卜次数"]) or 0) > 0
end

-- 备注：转生等级是否达到指定等级
local function _xyl_has_rebirth(play, level)
    return (getplaydef(play, VarCfg["U_转生等级"]) or 0) >= (level or 1)
end

-- 备注：判断斗笠低阶名称（低阶不算完成传说/更高）
local function _xyl_is_lower_hat_name(name)
    if not name or name == "" then
        return false
    end
    if name == "江湖·斗笠" then
        return true
    end
    return name:match("^斗笠%[lv%d+%]$") ~= nil
end

-- 备注：判断葫芦低阶名称（低阶不算完成神/更高）
local function _xyl_is_lower_gourd_name(name)
    if not name or name == "" then
        return false
    end
    if name == "真·酒葫芦" then
        return true
    end
    return name:match("^酒葫芦%[lv%d+%]$") ~= nil
end

-- 备注：读取物品在装备/物品表中的 std idx，系列装备按 idx 先后判断高低
local function _xyl_get_std_idx(name)
    if not name or name == "" then
        return 0
    end
    return tonumber(getstditeminfo(name, ConstCfg.stditeminfo.idx) or 0) or 0
end

-- 备注：检测是否拥有某个系列里达到目标档位及以上的装备/物品
-- 规则：名称命中系列关键字，且物品表 idx 不低于目标档位
local function _xyl_has_series_item_at_least(play, cfg, keyword)
    if not (cfg and cfg.give and cfg.where) then
        return false
    end
    local targetIdx = _xyl_get_std_idx(cfg.give)
    if targetIdx <= 0 then
        return false
    end

    local equipIdx = tonumber(Player.getEquipIdxByPos(play, cfg.where) or 0) or 0
    if equipIdx >= targetIdx then
        local equipName = Player.getEquipNameByPos(play, cfg.where)
        if equipName and (not keyword or equipName:find(keyword, 1, true)) then
            return true
        end
    end

    local bagItems = getbagitems(play) or {}
    for _, itemObj in pairs(bagItems) do
        local itemIdx = tonumber(getiteminfo(play, itemObj, ConstCfg.iteminfo.idx) or 0) or 0
        if itemIdx >= targetIdx then
            local itemName = getiteminfo(play, itemObj, ConstCfg.iteminfo.name)
            if itemName and (not keyword or itemName:find(keyword, 1, true)) then
                return true
            end
        end
    end
    return false
end

-- 备注：是否拥有传说神石类道具
local function _xyl_has_legendary_stone(play)
    local cfg = teshudata and teshudata["npc_53"]
    local list = cfg and cfg.cost and cfg.cost[3]
    return _xyl_has_any_item(play, list)
end

-- 备注：传说斗笠（装备或背包）是否拥有（上位斗笠也视为完成）
local function _xyl_has_legendary_hat(play)
    local cfg = teshudata and teshudata["npc_51"]
    return _xyl_has_series_item_at_least(play, cfg, "斗笠")
end

-- 备注：神酒葫芦（装备或背包）是否拥有（上位葫芦也视为完成）
local function _xyl_has_god_gourd(play)
    local cfg = teshudata and teshudata["npc_52"]
    return _xyl_has_series_item_at_least(play, cfg, "葫芦")
end
-- 备注：高级淬体是否全完成（或已有称号）
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

-- 备注：仙府是否已开启（有数据记录）
local function _xyl_has_xianfu_open(play)
    local data = Player.getJsonTableByVar(play, VarCfg.T_XianFuData)
    return next(data or {}) ~= nil
end

-- 备注：仙府炼制是否有记录
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

-- 备注：仙府种植或药草是否有记录
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

-- 备注：砍树系统是否有数据记录
local function _xyl_has_tree(play)
    local data = Player.getJsonTableByVar(play, VarCfg["T_砍树系统"])
    return next(data or {}) ~= nil
end

-- 备注：藏宝图累计完成次数 > 0
local function _xyl_has_treasure(play)
    return (getplaydef(play, VarCfg["U_藏宝图次数"]) or 0) > 0
end

-- 备注：灵兽全星级是否达到指定等级
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

-- 备注：是否拥有【唐代】古玩类道具
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

-- 备注：生肖守护是否全激活
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

-- 备注：剧情点验证入口（优先特殊逻辑，其次剧情完成）
local function _xyl_check_task(play, name)
    local key = _xyl_norm_name(name)
    release_print(name)
    local special = {
        ["天书强化"] = _xyl_has_tianshu_level,
        ["初识仙法"] = _xyl_has_any_xianfa,
        ["装备强化"] = _xyl_has_equip_strength,
        ["升级灵根"] = _xyl_has_linggen_feed,
        ["查看江湖称号"] = _xyl_has_jianghu_title,
        ["装配主灵根"] = _xyl_has_main_linggen,
        ["装配副灵根"] = _xyl_has_other_linggen,
        ["气运占卜"] = _xyl_has_divination,
        ["转生·二"] = function(play) return _xyl_has_rebirth(play, 20) end,
        ["转生·三"] = function(play) return _xyl_has_rebirth(play, 30) end,
        ["转生·四"] = function(play) return _xyl_has_rebirth(play, 40) end,
        ["拥有1传说神石"] = _xyl_has_legendary_stone,
        ["传说·斗笠"] = _xyl_has_legendary_hat,
        ["神·酒葫芦"] = _xyl_has_god_gourd,
        ["高级淬体"] = _xyl_has_advanced_quench,
        ["开辟仙府"] = _xyl_has_xianfu_open,
        ["炼制丹药"] = _xyl_has_xianfu_refine,
        ["了解砍树"] = _xyl_has_tree,
        ["种植仙草"] = _xyl_has_xianfu_plant,
        ["寻宝大师"] = _xyl_has_treasure,
        ["灵兽全一星"] = function(play) return _xyl_has_lingshou_star(play, 2) end,
        ["灵兽全二星"] = function(play) return _xyl_has_lingshou_star(play, 3) end,
        ["灵兽全三星"] = function(play) return _xyl_has_lingshou_star(play, 4) end,
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
    }
    if special[key] then
        return special[key](play)
    end
    return _xyl_check_story(play, key)
end
local npc_xyl = {
    {},
    {
        {
            jq = {
                {
                    "天书强化",
                    id = 999,
                    jl = { { "剧情点", 1 },{"仙法卷轴",1} },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "天书强化")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 3, 14 },
                    desc = "直面天书强化，破局前行",
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
                    yd = { 3, 14 },
                    desc = "历经初识仙法，收获机缘",
                },
                {
                    "扫荡野火帮（剧）",
                    tk = "npc_603",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "野火帮", 603, 100, 223 },
                    desc = "直面扫荡野火帮，破局前行",
                },
                {
                    "深入野火（剧）",
                    tk = "npc_607",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "野火帮大营", 607, 60, 279 },
                    desc = "探入敌营深处，摸清野火脉络",
                },
            },
            name = "初入江湖",

            jqd = 0,

            jl = { { "1元真实充值", 1 }, { "激活火灵根", 1 } },
        },
        {
            jq = {
                {
                    "装配主灵根",
                    id = 999,
                    fwdjy = function(play)
                        return _xyl_check_task(play, "装配主灵根")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 3, 14 },
                    desc = "装配主灵根，掌握灵根之力",
                },
                {
                    "查看江湖称号",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "查看江湖称号")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "二大陆主城", 43, 119, 122 },
                    desc = "查看江湖称号，踏出江湖第一步",
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
                    yd = { 1, "二大陆主城", 26, 110, 106 },
                    desc = "闯过气运占卜，证我道途",
                },
                {
                    "剿灭恶徒（剧）",
                    tk = "npc_604",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "极光城郊", 604, 83, 166 },
                    desc = "踏入剿灭恶徒，循迹而行",
                },
                {
                    "守护森林（剧）",
                    tk = "npc_608",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "神秘森林", 608, 52, 53 },
                    desc = "前往守护森林，探寻其中机缘",
                },
            },
            name = "小试牛刀",

            jqd = 4,

            jl = { { "1元真实充值", 1 }, { "激活木灵根", 1 } },
        },
        {
            jq = {
                {
                    "装配副灵根",
                    id = 999,
                    fwdjy = function(play)
                        return _xyl_check_task(play, "装配副灵根")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 3, 14 },
                    desc = "装配副灵根，补全第二道灵根之力",
                },
                {
                    "装备强化",
                    tk = "npc_28",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "装备强化")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "二大陆主城", 28, 115, 106 },
                    desc = "于装备强化中磨砺，道心更稳",
                },
                {
                    "杀伐之路（剧）",
                    tk = "npc_605",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "兵道古藏", 605, 103, 53 },
                    desc = "踏入杀伐之路，循迹而行",
                },
                {
                    "掘墓人（剧）",
                    tk = "npc_610",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "乱葬岗", 610, 170, 212 },
                    desc = "踏入掘墓人，循迹而行",
                },
            },
            name = "漫漫仙途",

            jqd = 8,

            jl = { { "1元真实充值", 1 }, { "激活水灵根", 1 } },
        },
        {
            jq = {
                {
                    "升级灵根",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "升级灵根")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 3, 14 },
                    desc = "历经升级灵根，收获机缘",
                },
                {
                    "讨伐夜魔（剧）",
                    tk = "npc_606",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "夜魔洞", 606, 98, 95 },
                    desc = "闯过讨伐夜魔，证我道途",
                },
                {
                    "古刹之谜（剧）",
                    tk = "npc_609",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "洞穴秘境", 609, 143, 153 },
                    desc = "前往古刹，探寻其中机缘",
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
                    yd = { 1, "二大陆主城", 33, 90, 127 },
                    desc = "踏入转生·二，循迹而行",
                },
                {
                    "修复轩辕剑（剧）",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play, tk)
                        return _xyl_check_task(play, "修复轩辕剑（剧）")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "二大陆主城", 601, 91, 116 },
                    desc = "于修复轩辕剑中磨砺，道心更稳",
                },
            },
            name = "融会贯通",

            jqd = 11,

            jl = { { "1元真实充值", 1 }, { "仙法卷轴", 1 } },
        },
    },
    {
        {
            jq = {
                {
                    "开辟仙府",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "开辟仙府")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "灰界", 55, 197, 196 },
                    desc = "开辟仙府，正式踏入灰界后的修行之路",
                },
                {
                    "讨伐嘲灾",
                    tk = "npc_625",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "鬼嘲深渊", 625, 174, 460 },
                    desc = "前往灾厄入口，进入嘲灾讨伐线",
                },
                {
                    "讨伐息灾",
                    tk = "npc_627",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "叹息旷野", 627, 85, 126 },
                    desc = "前往灾厄入口，进入息灾讨伐线",
                },
                {
                    "讨伐忌灾",
                    tk = "npc_626",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "禁忌之海", 626, 74, 67 },
                    desc = "前往灾厄入口，进入忌灾讨伐线",
                },
                {
                    "讨伐妄灾",
                    tk = "npc_628",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "虚妄山脉", 628, 107, 97 },
                    desc = "前往灾厄入口，进入妄灾讨伐线",
                },
                {
                    "灾厄入侵",
                    tk = "npc_46",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "灰界", 46, 205, 196 },
                    desc = "完成四线讨伐后，回到灾厄入口提交总任务",
                },
            },
            name = "灰界开篇",
            jqd = 11,

            jl = { { "1元真实充值", 1 }, { "藏宝图碎片", 10 } },
        },
        {
            jq = {
                {
                    "种植仙草",
                    id = 999,
                    jl = { { "剧情点", 1 }, { "藏宝图碎片", 5 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "开辟仙府") and _xyl_check_task(play, "种植仙草")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 3, 14 },
                    desc = "闯过种植仙草，证我道途",
                },
                {
                    "了解砍树",
                    id = 999,
                    jl = { { "剧情点", 1 }, { "藏宝图碎片", 5 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "开辟仙府") and _xyl_check_task(play, "了解砍树")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 3, 14 },
                    desc = "行走了解砍树，破除迷障",
                },
                {
                    "寻宝大师",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "开辟仙府") and _xyl_check_task(play, "寻宝大师")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "三大陆主城", 47, 154, 223 },
                    desc = "行走寻宝大师，破除迷障",
                },
            },
            name = "仙府功能",
            jqd = 17,

            jl = {{ "1元真实充值", 2 }, { "激活火灵根", 1 }},
        },
        {
            jq = {
                {
                    "杀戮的欲望",
                    tk = "npc_634",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "藏星外海", 634, 69, 132 },
                    desc = "直面杀戮的欲望，化解其中隐患",
                },
                {
                    "沉船之谜",
                    tk = "npc_629",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "千年沉船", 629, 44, 34 },
                    desc = "直面沉船之谜，化解其中隐患",
                },
                {
                    "船长的宝藏",
                    tk = "npc_630",
                    ydtk = "npc_629",
                    ydtip = "沉船之谜",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "船长室", 630, 29, 34 },
                    desc = "踏破船长的宝藏，守护一方安宁",
                },
                {
                    "谁是内鬼",
                    tk = "npc_631",
                    ydtk = "npc_629",
                    ydtip = "沉船之谜",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "水手舱", 631, 30, 36 },
                    desc = "历经谁是内鬼，收获机缘",
                },
            },
            name = "外海之旅",
            jqd = 21,

            jl = {{ "1元真实充值", 2 }, { "激活土灵根", 1 }},
        },
        {
            jq = {
                {
                    "送葬者",
                    tk = "npc_635",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "藏星内海", 635, 81, 166 },
                    desc = "闯过送葬者，证我道途",
                },
                {
                    "热血的友情",
                    tk = "npc_636",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "七星岛", 636, 159, 408 },
                    desc = "直面热血的友情，化解其中隐患",
                },
                {
                    "真正的海贼王",
                    tk = "npc_637",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "葬星城", 637, 110, 96 },
                    desc = "深入真正的海贼王，寻回失落线索",
                },
                {
                    "海滩拾贝",
                    tk = "npc_632",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "葬星海滩1", 632, 62, 22 },
                    desc = "直面海滩拾贝，化解其中隐患",
                },
                {
                    "海盗宝藏",
                    tk = "npc_633",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "葬星海滩1", 633, 33, 36 },
                    desc = "深入海盗宝藏，寻回失落线索",
                },
            },
            name = "内海探秘",
            jqd = 29,

            jl = {{ "1元真实充值", 2 }, { "神石宝箱钥匙", 1 }},
        },
        {
            jq = {
                {
                    "采仙草咯",
                    tk = "npc_638",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "草药古深处", 638, 31, 51 },
                    desc = "于采仙草咯中磨砺，道心更稳",
                },
                {
                    "丹仙秘辛",
                    tk = "npc_639",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "丹道古藏", 639, 243, 97 },
                    desc = "行走丹仙秘辛，破除迷障",
                },
                {
                    "棋痴老王",
                    tk = "npc_640",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "苍云客栈", 640, 26, 58 },
                    desc = "前往棋痴老王，探寻其中机缘",
                },
            },
            name = "草谷丹道",
            jqd = 33,

            jl = {{ "1元真实充值", 2 }, { "神石宝箱钥匙", 1 }},
        },
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
                    yd = { 1, "三大陆主城", 53, 159, 223 },
                    desc = "深入拥有1传说神石，寻回失落线索",
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
                    yd = { 1, "三大陆主城", 51, 172, 226 },
                    desc = "深入传说·斗笠，寻回失落线索",
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
                    yd = { 1, "三大陆主城", 52, 172, 231 },
                    desc = "踏入神·酒葫芦，循迹而行",
                },
                {
                    "高级淬体",
                    tk = "npc_53",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "三大陆主城", 53, 159, 223 },
                    desc = "踏入高级淬体，循迹而行",
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
                    yd = { 1, "三大陆主城", 34, 142, 236 },
                    desc = "历经转生·三，收获机缘",
                },
            },
            name = "三大陆毕业章",
            jqd = 36,

            jl = {{ "1元真实充值", 5 }, { "等级卷轴", 5 }},
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
                    yd = { 1, "四大陆主城", 64, 24, 23 },
                    desc = "前往灵兽全一星，探寻其中机缘",
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
                    yd = { 1, "四大陆主城", 64, 24, 23 },
                    desc = "前往灵兽全二星，探寻其中机缘",
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
                    yd = { 1, "四大陆主城", 64, 24, 23 },
                    desc = "踏入灵兽全三星，循迹而行",
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
                    yd = { 1, "四大陆主城", 65, 28, 23 },
                    desc = "踏破唐代古玩，守护一方安宁",
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
                    yd = { 3, 14 },
                    desc = "闯过红色仙法，证我道途",
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
                    yd = { 1, "四大陆主城", 35, 16, 31 },
                    desc = "探访转生·四，揭开真相",
                },
            },
            name = "若水秘闻",
            jqd = 42,

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
                    yd = { 1, "酆都鬼城", 666, 84, 50 },
                    desc = "前往捉鬼人，探寻其中机缘",
                },
                {
                    "买路钱",
                    tk = "npc_667",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "鬼门关", 667, 83, 95 },
                    desc = "踏入买路钱，循迹而行",
                },
                {
                    "思念之人",
                    tk = "npc_668",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "黄泉路", 668, 41, 44 },
                    desc = "探访思念之人，揭开真相",
                },
                {
                    "忘却前生情",
                    tk = "npc_669",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "奈何桥", 669, 38, 43 },
                    desc = "行走忘却前生情，破除迷障",
                },
                {
                    "讨伐六天宫",
                    tk = "npc_670",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "罗酆六天", 670, 165, 157 },
                    desc = "历经讨伐六天宫，收获机缘",
                },
                {
                    "地狱使者",
                    tk = "npc_671",
                    id = 999,
                    jl = { { "剧情点", 3 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "十八层地狱", 671, 54, 85 },
                    desc = "历经地狱使者，收获机缘",
                },
                {
                    "轮回之路",
                    tk = "npc_672",
                    id = 999,
                    jl = { { "剧情点", 3 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "六道轮回", 672, 39, 30 },
                    desc = "深入轮回之路，寻回失落线索",
                },
            },
            name = "地府探秘",
            jqd = 42,

            jl = { { "等级卷轴", 5 }, { "1元真实充值", 8 } },
        },
        {
            jq = {
                {
                    "资格考验",
                    tk = "npc_642",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "大唐·长安城", 642, 35, 57 },
                    desc = "直面资格考验，化解其中隐患",
                },
                {
                    "龙王的噩梦",
                    tk = "npc_643",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "东海龙宫", 643, 44, 97 },
                    desc = "探访龙王的噩梦，揭开真相",
                },
                {
                    "我的袈裟！",
                    tk = "npc_644",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "黑风山", 644, 195, 223 },
                    desc = "探访我的袈裟！，揭开真相",
                },
                {
                    "黄风大圣",
                    tk = "npc_645",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "黄风岭", 645, 159, 187 },
                    desc = "于黄风大圣中磨砺，道心更稳",
                },
                {
                    "你竟是女王？",
                    tk = "npc_646",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "女儿国", 646, 106, 105 },
                    desc = "直面你竟是女王？，化解其中隐患",
                },
                {
                    "驮我过河",
                    tk = "npc_647",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "通天河", 647, 123, 155 },
                    desc = "直面驮我过河，化解其中隐患",
                },
                {
                    "大闹狮驼岭",
                    tk = "npc_648",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "狮驼岭", 648, 56, 61 },
                    desc = "前往大闹狮驼岭，探寻其中机缘",
                },
                {
                    "真假经书",
                    tk = "npc_649",
                    id = 999,
                    jl = { { "剧情点", 3 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "天竺山", 649, 62, 72 },
                    desc = "历经真假经书，收获机缘",
                },
                {
                    "重走西游路",
                    tk = "npc_641",
                    id = 999,
                    jl = {},
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "四大陆主城", 641, 20, 27 },
                    desc = "直面重走西游路，化解其中隐患",
                },
            },
            name = "重走西游",

            jqd = 55,

            jl = { { "等级卷轴", 10 }, { "1元真实充值", 15 } },
        },
        {
            jq = {
                {
                    "天鼠的游戏",
                    tk = "npc_651",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "子鼠灵域", 651, 71, 78 },
                    desc = "踏入天鼠的游戏，循迹而行",
                },
                {
                    "天牛的游戏",
                    tk = "npc_652",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "丑牛灵域", 652, 53, 42 },
                    desc = "历经天牛的游戏，收获机缘",
                },
                {
                    "天虎的游戏",
                    tk = "npc_653",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "寅虎灵域", 653, 35, 45 },
                    desc = "踏破天虎的游戏，守护一方安宁",
                },
                {
                    "天兔的游戏",
                    tk = "npc_654",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "卯兔灵域", 654, 74, 67 },
                    desc = "深入天兔的游戏，寻回失落线索",
                },
                {
                    "灵域使者·一",
                    tk = "npc_663",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "灵域·一层", 663, 43, 44 },
                    desc = "历经灵域使者·一，收获机缘",
                },
            },
            name = "生肖守护[始]",

            jqd = 70,

            jl = { { "等级卷轴", 5 }, { "1元真实充值", 8 } },
        },
        {
            jq = {
                {
                    "天龙的游戏",
                    tk = "npc_655",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "辰龙灵域", 655, 55, 70 },
                    desc = "前往天龙的游戏，探寻其中机缘",
                },
                {
                    "天蛇的游戏",
                    tk = "npc_656",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "巳蛇灵域", 656, 89, 85 },
                    desc = "探访天蛇的游戏，揭开真相",
                },
                {
                    "天马的游戏",
                    tk = "npc_657",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "午马灵域", 657, 144, 108 },
                    desc = "踏破天马的游戏，守护一方安宁",
                },
                {
                    "天羊的游戏",
                    tk = "npc_658",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "未羊灵域", 658, 42, 43 },
                    desc = "深入天羊的游戏，寻回失落线索",
                },
                {
                    "灵域使者·二",
                    tk = "npc_664",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "灵域·二层", 664, 52, 57 },
                    desc = "历经灵域使者·二，收获机缘",
                },
            },
            name = "生肖守护[转]",

            jqd = 77,

            jl = { { "等级卷轴", 5 }, { "1元真实充值", 8 } },
        },
        {
            jq = {
                {
                    "天猴的游戏",
                    tk = "npc_659",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "申猴灵域", 659, 133, 170 },
                    desc = "踏破天猴的游戏，守护一方安宁",
                },
                {
                    "天鸡的游戏",
                    tk = "npc_660",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "酉鸡灵域", 660, 173, 139 },
                    desc = "行走天鸡的游戏，破除迷障",
                },
                {
                    "天狗的游戏",
                    tk = "npc_661",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "戌狗灵域", 661, 162, 166 },
                    desc = "直面天狗的游戏，化解其中隐患",
                },
                {
                    "天猪的游戏",
                    tk = "npc_662",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "亥猪灵域", 662, 211, 161 },
                    desc = "踏破天猪的游戏，守护一方安宁",
                },
                {
                    "灵域使者·三",
                    tk = "npc_665",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "灵域·三层", 665, 109, 15 },
                    desc = "闯过灵域使者·三，证我道途",
                },
                {
                    "生肖守护",
                    tk = "npc_67",
                    id = 999,
                    jl = { { "剧情点", 5 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "四大陆主城", 67, 36, 23 },
                    desc = "行走生肖守护，破除迷障",
                },
            },
            name = "生肖守护[终]",

            jqd = 85,

            jl = { { "等级卷轴", 5 }, { "1元真实充值", 8 } },
        },
        {
            jq = {
                {
                    "传说修复局",
                    tk = "npc_673",
                    id = 999,
                    jl = {},
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "四大陆主城", 673, 20, 31 },
                    desc = "历经传说修复局，收获机缘",
                },
                {
                    "盘古开天",
                    tk = "npc_674",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "盘古开天", 674, 55, 65 },
                    desc = "行走盘古开天，破除迷障",
                },
                {
                    "羿射九日",
                    tk = "npc_675",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "羿射九日", 675, 358, 114 },
                    desc = "行走羿射九日，破除迷障",
                },
                {
                    "共公怒触不周山",
                    tk = "npc_676",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "不周山", 676, 70, 77 },
                    desc = "直面共公怒触不周山，化解其中隐患",
                },
                {
                    "女娲补天",
                    tk = "npc_677",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "女娲补天", 677, 102, 58 },
                    desc = "前往女娲补天，探寻其中机缘",
                },
                {
                    "后土娘娘",
                    tk = "npc_678",
                    id = 999,
                    jl = { { "剧情点", 3 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "后土娘娘", 678, 152, 171 },
                    desc = "历经后土娘娘，收获机缘",
                },
                {
                    "黑白无常",
                    tk = "npc_679",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "黑白无常", 679, 101, 57 },
                    desc = "踏入黑白无常，循迹而行",
                },
                {
                    "真假玉帝",
                    tk = "npc_680",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "真假玉帝", 680, 84, 93 },
                    desc = "踏破真假玉帝，守护一方安宁",
                },
                {
                    "白蛇传说",
                    tk = "npc_681",
                    id = 999,
                    jl = { { "剧情点", 2 } },
                    fwdjy = function(play, tk)
                        if tk then
                            return _xyl_check_task(play, tk)
                        end
                        return false
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 1, "白蛇传说", 681, 216, 167 },
                    desc = "踏入白蛇传说，循迹而行",
                },
            },
            name = "修复传说",
            jqd = 99,
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









































