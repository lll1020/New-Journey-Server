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
    -- 特殊验证
    if key == "npc_633" then
        return node >= 2
    end
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

-- 备注：是否已选择本命灵根
local function _xyl_has_main_linggen(play)
    local data = Player.getJsonTableByVar(play, VarCfg["T_灵根"])
    return (tonumber(data.main or 0) or 0) > 0
end

-- 备注：本命灵根是否升级过一次
local function _xyl_has_main_linggen_upgraded(play)
    local data = Player.getJsonTableByVar(play, VarCfg["T_灵根"])
    local mainIdx = tonumber(data.main or 0) or 0
    if mainIdx <= 0 then
        return false
    end
    local levels = data.level or {}
    return (tonumber(levels[tostring(mainIdx)] or 0) or 0) > 1
end

-- 备注：是否已领取灵兽幼崽；老号已获得/孵化任意灵兽也视为完成
local function _xyl_has_lingshou_hatched(play)
    local data = Player.getJsonTableByVar(play, VarCfg["T_灵兽"])
    if (tonumber(data.baby_choice or 0) or 0) > 0 then
        return true
    end
    for _, mapName in ipairs({"ls", "ls_sp"}) do
        local map = data[mapName] or {}
        for _, v in pairs(map) do
            if tonumber(v) and tonumber(v) > 0 then
                return true
            end
        end
    end
    return false
end


-- 备注：轩辕剑任务必须实际修复完成，不能只靠材料齐全跳过
local function _xyl_has_xuanyuan_material(play)
    local cfg = teshudata and teshudata["npc_601"]
    return cfg and cfg.details and _xyl_has_title(play, cfg.details.ch)
end
-- 备注：江湖称号任务要求实际强化一次
local function _xyl_has_jianghu_title(play)
    return (tonumber(getplaydef(play, VarCfg["U_江湖称号"]) or 0) or 0) > 0
end
-- 备注：气运占卜次数是否大于 0
local function _xyl_has_divination(play)
    return (getplaydef(play, VarCfg["U_占卜次数"]) or 0) > 0
end
-- 备注：是否已打开过二大陆限时福利
local function _xyl_has_second_continent_welfare_open(play)
    return (tonumber(getplaydef(play, "N$XYL2_WELFARE_OPEN") or 0) or 0) > 0
end

-- 备注：是否已完成过一次天书使者洗炼
local function _xyl_has_second_continent_tianshu_refine(play)
    return (tonumber(getplaydef(play, "N$XYL2_TIANSHU_REFINE") or 0) or 0) > 0
end

-- 备注：幸运增幅任务要求实际强化一次
local function _xyl_has_second_continent_lucky_view(play)
    return (tonumber(getplaydef(play, VarCfg["U_幸运强化"]) or 0) or 0) > 0
end

-- 备注：境界是否已达到筑基境（等级 10）
local function _xyl_has_foundation_realm(play)
    return (tonumber(getplaydef(play, "U28") or 0) or 0) >= 10
end

-- 备注：聚宝盆是否已修复/激活
local function _xyl_has_treasure_basin_fixed(play)
    local data = Player.getJsonTableByVar(play, "T44")
    return (tonumber(data and data.rebuilt or 0) or 0) >= 1
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

-- 备注：是否拥有传说神石类道具，背包或神石装备槽位任意满足即可。
local function _xyl_has_legendary_stone(play)
    local cfg = teshudata and teshudata["npc_53"]
    local list = cfg and cfg.cost and cfg.cost[3]
    if _xyl_has_any_item(play, list) then
        return true
    end
    for where = 103, 110 do
        local equipName = Player.getEquipNameByPos(play, where)
        if equipName and equipName:find("神石", 1, true) and equipName:find("【传说】", 1, true) then
            return true
        end
    end
    return false
end

-- 备注：传说斗笠（装备或背包）是否拥有（上位斗笠也视为完成）
local function _xyl_has_legendary_hat(play)
    local equipLevel = Player.getEquipFieldByPos(play, 13, 1) or 0
    if equipLevel == 0 then
        return false
    end
    equipLevel = tonumber(equipLevel)
    return equipLevel >= 13
end

-- 备注：神酒葫芦（装备或背包）是否拥有（上位葫芦也视为完成）
local function _xyl_has_god_gourd(play)
    local equipLevel = Player.getEquipFieldByPos(play, 16, 1) or 0
    if equipLevel == 0 then
        return false
    end
    equipLevel = tonumber(equipLevel)
    return equipLevel >= 13
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
    return type(data) == "table" and tonumber(data.opened or 0) >= 1
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
    return (tonumber(data.level) or 0) >= 1
end

-- 备注：是否已激活全部圣遗物（灵兽圣遗物）
local function _xyl_has_all_syw(play)
    local data = Player.getJsonTableByVar(play, VarCfg["T_灵兽"])
    if data.syw_all == 1 then
        return true
    end
    if checktitle(play, "上古神兽掌控者") then
        return true
    end
    local syw = data.syw or {}
    for i = 1, 5 do
        if syw[tostring(i)] ~= 1 then
            return false
        end
    end
    return true
end

-- 备注：是否已激活全部天命装备（持有或穿戴）
local function _xyl_has_all_tianming(play)
    local list = {
        { name = "天命·复活", where = 12 },
        { name = "天命·麻痹", where = 14 },
        { name = "天命·神镰", where = 15 },
        { name = "天命·神斧", where = 9 },
    }
    for _, one in ipairs(list) do
        local ok = _xyl_has_item(play, one.name, 1)
        if not ok and one.where then
            ok = _xyl_has_equip_named(play, one.where, one.name)
        end
        if not ok then
            return false
        end
    end
    return true
end

-- 备注：剧情点验证入口（优先特殊逻辑，其次剧情完成）
local function _xyl_check_task(play, name)
    local key = _xyl_norm_name(name)
    local special = {
        ["天书强化"] = _xyl_has_tianshu_level,
        ["初识仙法"] = _xyl_has_any_xianfa,
        ["天书仙法"] = _xyl_has_any_xianfa,
        ["装备强化"] = _xyl_has_equip_strength,
        ["装备强化1次"] = _xyl_has_equip_strength,
        ["气运占卜"] = _xyl_has_divination,
        ["江湖称号"] = _xyl_has_jianghu_title,
        ["引导江湖称号"] = _xyl_has_jianghu_title,
        ["江湖称号强化一次"] = _xyl_has_jianghu_title,
        ["江湖称号升级1次"] = _xyl_has_jianghu_title,
        ["幸运增幅"] = _xyl_has_second_continent_lucky_view,
        ["幸运强化"] = _xyl_has_second_continent_lucky_view,
        ["引导幸运增幅"] = _xyl_has_second_continent_lucky_view,
        ["幸运增幅强化一次"] = _xyl_has_second_continent_lucky_view,
        ["限时福利"] = _xyl_has_second_continent_welfare_open,
        ["洗炼天书"] = _xyl_has_second_continent_tianshu_refine,
        ["引导天书使者洗炼一次"] = _xyl_has_second_continent_tianshu_refine,
        ["本命灵根"] = _xyl_has_main_linggen,
        ["灵兽孵化"] = _xyl_has_lingshou_hatched,
        ["筑基"] = _xyl_has_foundation_realm,
        ["提升修为至筑基境"] = _xyl_has_foundation_realm,
        ["转生·二"] = function(play)
            return _xyl_has_rebirth(play, 20)
        end,
        ["完成转生"] = function(play)
            return _xyl_has_rebirth(play, 20)
        end,
        ["完转生"] = function(play)
            return _xyl_has_rebirth(play, 20)
        end,
        ["完成2大陆转生"] = function(play)
            return _xyl_has_rebirth(play, 20)
        end,
        ["转生·三"] = function(play)
            return _xyl_has_rebirth(play, 30)
        end,
        ["转生·四"] = function(play)
            return _xyl_has_rebirth(play, 40)
        end,
        ["转生·五"] = function(play)
            return _xyl_has_rebirth(play, 50)
        end,
        ["完成转生·五"] = function(play)
            return _xyl_has_rebirth(play, 50)
        end,
        ["拥有1传说神石"] = _xyl_has_legendary_stone,
        ["传说·斗笠"] = _xyl_has_legendary_hat,
        ["神·酒葫芦"] = _xyl_has_god_gourd,
        ["高级淬体"] = _xyl_has_advanced_quench,
        ["开辟仙府"] = _xyl_has_xianfu_open,
        ["炼制丹药"] = _xyl_has_xianfu_refine,
        ["了解砍树"] = _xyl_has_tree,
        ["种植仙草"] = _xyl_has_xianfu_plant,
        ["寻宝大师"] = _xyl_has_treasure,
        ["修复聚宝盆"] = _xyl_has_treasure_basin_fixed,
        ["聚宝盆"] = _xyl_has_treasure_basin_fixed,
        ["聚宝盆任务"] = _xyl_has_treasure_basin_fixed,
        ["激活全部圣遗物"] = _xyl_has_all_syw,
        ["激活全部天命装备"] = _xyl_has_all_tianming,
        ["灵兽全一星"] = function(play)
            return _xyl_has_lingshou_star(play, 2)
        end,
        ["灵兽全二星"] = function(play)
            return _xyl_has_lingshou_star(play, 3)
        end,
        ["灵兽全三星"] = function(play)
            return _xyl_has_lingshou_star(play, 4)
        end,
        ["唐代古玩"] = _xyl_has_tang_antique,
        ["红色仙法"] = _xyl_has_red_xianfa,
        ["生肖守护"] = _xyl_has_shengxiao_guard,
        ["修复轩辕剑"] = _xyl_has_xuanyuan_material,
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
    {},
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
                    yd = { 1, "三大陆主城", 55, 146, 234 },
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
                    yd = { 1, "旷野之原", 625, 174, 460 },
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
                    yd = { 1, "恐怖裂隙", 627, 85, 126 },
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
                    yd = { 1, "海峰孤岛", 626, 74, 67 },
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
                    yd = { 1, "山脉入口", 628, 107, 97 },
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
            jqd = 0,

            jl = { { "1元真实充值", 1 }, { "基础灵根解锁", 1 } },
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
            jqd = 0,
            pre = {
                check = function(play)
                    return _xyl_check_task(play, "开辟仙府")
                end,
                lock_tip = "需先解锁仙府",
                tip = "请先完成【开辟仙府】后再进入本章节",
            },

            jl = {{ "1元真实充值", 2 }, { "基础灵根解锁", 1 }},
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
                    -- ydtk = "npc_629",
                    -- ydtip = "沉船之谜",
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
                    -- ydtk = "npc_629",
                    -- ydtip = "沉船之谜",
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
            jqd = 0,

            jl = {{ "1元真实充值", 2 }, { "基础灵根解锁", 1 }},
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
            jqd = 2,

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
            jqd = 7,

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
            jqd = 0,

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
            jqd = 21,

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
            jqd = 28,

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

            jqd = 27,

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

            jqd = 27,

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

            jqd = 27,

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

            jqd = 27,

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
            jqd = 51,
            jl = { { "等级卷轴", 10 }, { "1元真实充值", 15 } },
        },
    },
    {
        {
            jq = {
                {
                    "灵兽奥秘",
                    tk = "npc_682",
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
                    yd = { 1, "灵兽谷", 682, 88, 91 },
                    desc = "踏入灵兽奥秘，探寻灵兽之源",
                },
                {
                    "激活全部圣遗物",
                    id = 999,
                    jl = { { "剧情点", 5 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "激活全部圣遗物")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "为全部灵兽激活圣遗物",
                },
                {
                    "激活全部天命装备",
                    id = 999,
                    jl = { { "剧情点", 5 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "激活全部天命装备")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "集齐并激活全部天命装备",
                },
                {
                    "完成转生·五",
                    id = 999,
                    jl = { { "剧情点", 1 } },
                    fwdjy = function(play)
                        return _xyl_check_task(play, "完成转生·五")
                    end,
                    khdjy = function()
                        return true
                    end,
                    yd = { 0 },
                    desc = "完成转生·五，跨入更高境界",
                },
            },
            name = "红尘秘闻",
            jqd = 61,
            jl = { { "等级卷轴", 20 }, { "1元真实充值", 25 } },
        },
        {
            jq = {
                {
                    "时空之门",
                    tk = "npc_688",
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
                    yd = { 1, "时空裂隙", 688, 54, 277 },
                    desc = "开启时空之门，踏入裂隙",
                },
                {
                    "屠龙宝刀",
                    tk = "npc_714",
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
                    yd = { 1, "冰火岛", 714, 34, 51 },
                    desc = "屠龙宝刀出世，拔刀破敌",
                },
                {
                    "围攻光明顶",
                    tk = "npc_715",
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
                    yd = { 1, "光明顶", 715, 46, 42 },
                    desc = "围攻光明顶，夺取乾坤之力",
                },
                {
                    "孤身战吕布",
                    tk = "npc_716",
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
                    yd = { 1, "虎牢关", 716, 238, 238 },
                    desc = "孤身战吕布，破阵夺势",
                },
                {
                    "火烧赤壁",
                    tk = "npc_717",
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
                    yd = { 1, "赤壁", 717, 258, 53 },
                    desc = "火烧赤壁，胜局已定",
                },
                {
                    "景阳冈打虎",
                    tk = "npc_718",
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
                    yd = { 1, "景阳冈", 718, 52, 151 },
                    desc = "景阳冈打虎，名扬四方",
                },
                {
                    "血溅狮子楼",
                    tk = "npc_719",
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
                    yd = { 1, "狮子楼", 719, 93, 44 },
                    desc = "血溅狮子楼，快意恩仇",
                },
                {
                    "时空守护者",
                    tk = "npc_690",
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
                    yd = { 1, "五大陆主城", 690, 24, 13 },
                    desc = "直面时空守护者，守护时空秩序",
                },
            },
            name = "守护时空",
            jqd = 71,
            jl = { { "等级卷轴", 10 }, { "1元真实充值", 15 } },
        },
        {
            jq = {
                {
                    "神庙逃亡",
                    tk = "npc_696",
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
                    yd = { 1, "白骨神庙", 696, 336, 153 },
                    desc = "神庙逃亡，避开杀机",
                },
                {
                    "祭祀河神",
                    tk = "npc_698",
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
                    yd = { 1, "诡冥墨河", 698, 120, 130 },
                    desc = "祭祀河神，平息河患",
                },
                {
                    "赤焰试炼",
                    tk = "npc_700",
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
                    yd = { 1, "赤焰焚殿", 700, 28, 104 },
                    desc = "赤焰试炼，淬火成锋",
                },
                {
                    "葬天试炼",
                    tk = "npc_701",
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
                    yd = { 1, "葬天旧土", 701, 247, 244 },
                    desc = "葬天试炼，踏破旧土",
                },
                {
                    "生命边界之谜",
                    tk = "npc_692",
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
                    yd = { 1, "五大陆主城", 692, 32, 13 },
                    desc = "破解生命边界之谜",
                },
            },
            name = "生命边界",
            jqd = 81,
            jl = { { "等级卷轴", 10 }, { "1元真实充值", 15 } },
        },
        {
            jq = {
                {
                    "倩女幽魂",
                    tk = "npc_702",
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
                    yd = { 1, "兰若寺", 702, 88, 74 },
                    desc = "倩女幽魂，镇杀幽魂",
                },
                {
                    "画中仙境",
                    tk = "npc_703",
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
                    yd = { 1, "画壁", 703, 33, 57 },
                    desc = "画中仙境，探寻真相",
                },
                {
                    "崂山学法",
                    tk = "npc_704",
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
                    yd = { 1, "崂山", 704, 80, 33 },
                    desc = "崂山学法，道法自成",
                },
                {
                    "是非难辨",
                    tk = "npc_720",
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
                    yd = { 1, "罗刹海市", 705, 71, 31 },
                    yd2 = { 1, "罗刹海市", 720, 71, 31 },
                    desc = "是非难辨，见证真相",
                },
            },
            name = "聊斋志异",
            jqd = 81,
            jl = { { "等级卷轴", 10 }, { "1元真实充值", 15 } },
        },
        {
            jq = {
                {
                    "守护壁画",
                    tk = "npc_706",
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
                    yd = { 1, "莫高窟", 706, 19, 25 },
                    desc = "守护壁画，护佑遗梦",
                },
                {
                    "沙海明珠",
                    tk = "npc_707",
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
                    yd = { 1, "月牙泉", 707, 81, 167 },
                    desc = "沙海明珠，寻回秘宝",
                },
                {
                    "丝路往事",
                    tk = "npc_708",
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
                    yd = { 1, "玉门关", 708, 35, 45 },
                    desc = "丝路往事，回溯旧影",
                },
                {
                    "故人远行",
                    tk = "npc_709",
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
                    yd = { 1, "阳关道", 709, 179, 207 },
                    desc = "故人远行，缘起缘落",
                },
            },
            name = "敦煌遗梦",
            jqd = 81,
            jl = { { "等级卷轴", 10 }, { "1元真实充值", 15 } },
        },
        {
            jq = {
                {
                    "禁墟之门",
                    tk = "npc_689",
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
                    yd = { 1, "世界禁墟", 689, 95, 69 },
                    desc = "禁墟之门开启，步入禁墟",
                },
                {
                    "大地之王",
                    tk = "npc_710",
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
                    yd = { 1, "大地禁墟三层", 710, 61, 57 },
                    desc = "挑战大地之王，夺取祝福",
                },
                {
                    "天空之王",
                    tk = "npc_711",
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
                    yd = { 1, "天空禁墟三层", 711, 40, 31 },
                    desc = "挑战天空之王，夺取祝福",
                },
                {
                    "海洋之王",
                    tk = "npc_712",
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
                    yd = { 1, "海洋禁墟三层", 712, 200, 210 },
                    desc = "挑战海洋之王，夺取祝福",
                },
                {
                    "青铜之王",
                    tk = "npc_713",
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
                    yd = { 1, "青铜禁墟三层", 713, 31, 49 },
                    desc = "挑战青铜之王，夺取祝福",
                },
                {
                    "重启世界",
                    tk = "npc_691",
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
                    yd = { 1, "五大陆主城", 691, 28, 13 },
                    desc = "完成重启世界，开启新篇",
                },
            },
            name = "重启世界",
            jqd = 81,
            jl = { { "等级卷轴", 10 }, { "1元真实充值", 15 } },
        },
    },
}
npc_xyl.check_task = _xyl_check_task
return npc_xyl
