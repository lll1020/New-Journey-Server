release_print("加载Buff模块")
local function _godstone_level(play, key)
    return tonumber(getplaydef(play, "N$godstone_" .. key) or 0) or 0
end
local function _godstone_is_mon(obj)
    return obj and not getbaseinfo(obj, ConstCfg.gbase.isplayer)
end
local function _godstone_is_player(obj)
    return obj and getbaseinfo(obj, ConstCfg.gbase.isplayer)
end
local function _godstone_mon_type(obj)
    if not _godstone_is_mon(obj) then
        return 0
    end
    local name = tostring(getbaseinfo(obj, 1) or "")
    return tonumber((guaiwutype and guaiwutype[name]) or 0) or 0
end
local function _godstone_is_red_boss(obj)
    if not _godstone_is_mon(obj) then
        return false
    end
    local name = tostring(getbaseinfo(obj, 1) or "")
    return string.find(name, "★", 1, true) ~= nil
        or string.find(name, "≮", 1, true) ~= nil
        or string.find(name, "红", 1, true) ~= nil
end
local function _is_red_name_monster(obj)
    if not _godstone_is_mon(obj) then
        return false
    end
    local monidx = getbaseinfo(obj, 1)

    return tonumber(getmonbaseinfo(getdbmonfieldvalue(monidx, "idx"), 2) or 0) == 249
end
local function _godstone_roll(play, key, rate, cd)
    local now = os.time()
    local cdKey = "N$godstone_" .. key .. "_cd"
    local last = tonumber(getplaydef(play, cdKey) or 0) or 0
    if now - last < (tonumber(cd or 0) or 0) then
        return false
    end
    if math.random(10000) <= (tonumber(rate or 0) or 0) then
        setplaydef(play, cdKey, now)
        return true
    end
    return false
end
local function _huti_set_trigger(play, varName, buffId, enable)
    local bl = getplaydef(play, varName)
    local data = json2tbl(bl == "" and {} or bl)
    if enable then
        data[tostring(buffId)] = true
    else
        data[tostring(buffId)] = nil
    end
    setplaydef(play, varName, tbl2json(data))
end
local function _huti_monster_type(obj)
    if not obj or getbaseinfo(obj, -1) then
        return nil
    end
    local name = getbaseinfo(obj, 1)
    if not name or name == "" then
        return nil
    end
    return guaiwutype and guaiwutype[name] or nil
end
local function _toggle_buff_var(play, varName, buffId, enable)
    local bl = getplaydef(play, varName)
    local data = json2tbl(bl == "" and {} or bl)
    if enable then
        data[tostring(buffId)] = true
    else
        data[tostring(buffId)] = nil
    end
    setplaydef(play, varName, tbl2json(data))
end
local function _set_title_buff_flag(play, buffId, enable)
    setplaydef(play, "N$buff" .. tostring(buffId), enable and 1 or 0)
end
local function _has_title_buff_flag(play, buffId)
    return (tonumber(getplaydef(play, "N$buff" .. tostring(buffId)) or 0) or 0) == 1
end
local function _title_all_percent_attr(percent)
    local ids = {280, 281, 282, 283, 284, 285, 286, 287, 288, 289, 290, 291, 300}
    local arr = {}
    for _, id in ipairs(ids) do
        arr[#arr + 1] = "3#" .. id .. "#" .. percent
    end
    return table.concat(arr, "|")
end
local function _title_sync_time_attr(play, buffId, attrListName, attrStr, mode)
    if not _has_title_buff_flag(play, buffId) then
        Player.del_attlist(play, attrListName)
        return false
    end
    local hour = tonumber(os.date("%H")) or 0
    local enable = false
    if mode == "day" then
        enable = hour >= 6 and hour < 18
    elseif mode == "night" then
        enable = not (hour >= 6 and hour < 18)
    else
        enable = true
    end
    if enable then
        Player.add_attlist(play, attrListName, "=", attrStr, 1)
    else
        Player.del_attlist(play, attrListName)
    end
    return enable
end
local function _title_sync_dadi_attr(play)
    local stack = tonumber(getplaydef(play, "N$buff328_stack") or 0) or 0
    if not _has_title_buff_flag(play, 328) then
        stack = 0
    end
    if stack < 0 then
        stack = 0
    elseif stack > 10 then
        stack = 10
    end
    setplaydef(play, "N$buff328_stack", stack)
    if stack > 0 then
        Player.add_attlist(play, "title_dadi_stack", "=", _title_all_percent_attr(stack), 1)
    else
        Player.del_attlist(play, "title_dadi_stack")
    end
end
local function _gcmp_refresh_item(play)
    local stack = tonumber(getplaydef(play, "N$buff340_stack") or 0) or 0
    if stack < 0 then
        stack = 0
    end
    setplaydef(play, "N$buff340_stack", stack)
    if not _has_title_buff_flag(play, 340) then
        return
    end
    local where = Player.hasEquipInArtifactSlot(play, "古刹魔瓶")
    if not where then
        return
    end
    local itemobj = linkbodyitem(play, where)
    if not itemobj or itemobj == "0" then
        return
    end
    local ok, item_json = pcall(json2tbl, getitemcustomabil(play, itemobj))
    item_json = ok and type(item_json) == "table" and item_json or nil
    if not item_json or type(item_json.abil) ~= "table" then
        item_json = json2tbl('{"abil":[{"i":0,"t":"[古刹切割]","c":251,"v":[]}],"name":""}')
    end
    item_json.name = tostring(item_json.name or "")
    local idx = nil
    local abil_i = nil
    for i, v in ipairs(item_json.abil) do
        if type(v) == "table" and tostring(v.t or "") == "[古刹切割]" then
            idx = i
            abil_i = tonumber(v.i) or (i - 1)
            break
        end
    end
    if not idx then
        for i, v in ipairs(item_json.abil) do
            if type(v) == "table" and tostring(v.t or "") == "" and next(v.v or {}) == nil then
                idx = i
                abil_i = tonumber(v.i) or (i - 1)
                break
            end
        end
    end
    if not idx then
        idx = #item_json.abil + 1
        abil_i = idx - 1
    end
    local attr_list = {}
    if stack > 0 then
        table.insert(attr_list, {254, 244, stack, 0, 0, 1, 1})
    end
    item_json.abil[idx] = {i = abil_i or (idx - 1), t = "[古刹切割]", c = 251, v = attr_list}
    setitemcustomabil(play, itemobj, tbl2json(item_json))
    -- setcustomitemprogressbar(play, itemobj, 0, tbl2json({
    --     ["open"] = 1,
    --     ["show"] = 0,
    --     ["name"] = string.format("古刹切割：+%d", stack),
    --     ["color"] = 251,
    --     ["imgcount"] = 1,
    -- }))
    refreshitem(play, itemobj)
end
local function _find_bag_item_obj_by_name(play, itemName)
    local bagItems = getbagitems(play) or {}
    for _, itemobj in ipairs(bagItems) do
        if getiteminfo(play, itemobj, ConstCfg.iteminfo.name) == itemName then
            return itemobj
        end
    end
    return nil
end
local function _find_recharge_blade_item_obj(play)
    -- 切割刀：优先读取当前已穿戴的神器位物品，未穿戴时再回退到背包同名物品。
    local where = Player and Player.hasEquipInArtifactSlot and Player.hasEquipInArtifactSlot(play, "切割刀")
    if where then
        local itemobj = linkbodyitem(play, where)
        if itemobj and itemobj ~= "0" then
            return itemobj
        end
    end
    return _find_bag_item_obj_by_name(play, "切割刀")
end
local function _sync_item_named_cut_attr(play, itemobj, tagName, stack)
    if not itemobj or itemobj == "0" then
        return
    end
    local ok, item_json = pcall(json2tbl, getitemcustomabil(play, itemobj))
    item_json = ok and type(item_json) == "table" and item_json or nil
    if not item_json or type(item_json.abil) ~= "table" then
        item_json = json2tbl('{"abil":[{"i":0,"t":"' .. tagName .. '","c":251,"v":[]}],"name":""}')
    end
    item_json.name = tostring(item_json.name or "")
    local idx = nil
    local abil_i = nil
    for i, v in ipairs(item_json.abil) do
        if type(v) == "table" and tostring(v.t or "") == tagName then
            idx = i
            abil_i = tonumber(v.i) or (i - 1)
            break
        end
    end
    if not idx then
        for i, v in ipairs(item_json.abil) do
            if type(v) == "table" and tostring(v.t or "") == "" and next(v.v or {}) == nil then
                idx = i
                abil_i = tonumber(v.i) or (i - 1)
                break
            end
        end
    end
    if not idx then
        idx = #item_json.abil + 1
        abil_i = idx - 1
    end
    local cutValue = tonumber(stack or 0) or 0
    local attr_list = {}
    if cutValue > 0 then
        table.insert(attr_list, {254, 244, cutValue, 0, 20, 1, 1})
    end
    item_json.abil[idx] = {i = abil_i or (idx - 1), t = tagName, c = 251, v = attr_list}
    setitemcustomabil(play, itemobj, tbl2json(item_json))
    setcustomitemprogressbar(play, itemobj, 0, tbl2json({
        ["open"] = 1,
        ["show"] = 0,
        ["name"] = string.format("充值切割：+%d", cutValue),
        ["color"] = 251,
        ["imgcount"] = 1,
    }))
    refreshitem(play, itemobj)
end
-- 30 元档切割刀：击杀怪物累积切割，最终同步到切割刀物品自定义属性。
local function Buff_refreshRechargeBlade(play)
    local active = tonumber(getplaydef(play, "N$切割刀已激活") or 0) or 0
    local bladeItem = _find_recharge_blade_item_obj(play)
-- 兼容老号：角色若已拥有切割刀物品，但历史数据未写激活位，则自动补齐激活标记。
    if active ~= 1 and bladeItem and bladeItem ~= "0" then
        active = 1
        setplaydef(play, "N$切割刀已激活", 1)
    end
-- 只保留物品上的切割属性，避免角色身上残留旧版同名属性。
    Player.del_attlist(play, "充值切割刀")
    if active == 1 then
        _set_title_buff_flag(play, 564, true)
        if shaguai and shaguai.jia then
            shaguai.jia(play, 564)
        end
    end
    if active ~= 1 then
        if bladeItem and bladeItem ~= "0" then
            _sync_item_named_cut_attr(play, bladeItem, "[充值切割]", 0)
        end
        return
    end
    local stack = tonumber(getplaydef(play, "N$切割刀累计切割") or 0) or 0
    if stack < 0 then
        stack = 0
    elseif stack > 88888 then
        stack = 88888
    end
    setplaydef(play, "N$切割刀累计切割", stack)
    if bladeItem and bladeItem ~= "0" then
        _sync_item_named_cut_attr(play, bladeItem, "[充值切割]", stack)
    end
end
local function _tianshu_buff_splash(play, Target)
    -- release_print("触发天书溅射buff")
    if not play or not Target or getbaseinfo(Target, ConstCfg.gbase.isplayer) then
        return
    end
    local cfg = teshudata and teshudata["npc_24"] or nil
    if not cfg then
        return
    end
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_天书"]) or {}
    local level = tonumber(T_data.level) or 0
    if level <= 0 then
        return
    end
    local rate = (tonumber(cfg.splash_base_rate) or 10) + math.max(0, level - 1) * (tonumber(cfg.splash_add_rate) or 2)
    local maxRate = tonumber(cfg.splash_max_rate) or 110
    if rate > maxRate then
        rate = maxRate
    end
    local damage = math.floor((tonumber(getbaseinfo(play, ConstCfg.gbase.dc2) or 0) or 0) * rate / 100)
    if damage <= 0 then
        return
    end
    rangeharm(play, getbaseinfo(Target, ConstCfg.gbase.x), getbaseinfo(Target, ConstCfg.gbase.y), tonumber(cfg.splash_range) or 2, damage, 0, 0, 0, 2, tonumber(cfg.splash_effect) or 20310, tonumber(cfg.splash_max_targets) or 12)
    local splash_effect_cd = tonumber(getplaydef(play, "N$天书溅射特效CD") or 0) or 0
    local now = os.time()
    if now - splash_effect_cd >= 5 then
        setplaydef(play, "N$天书溅射特效CD", now)
        playeffect(Target, tonumber(cfg.splash_hit_effect) or 60463, 0, 0, 1, 1, 0)
    end
    -- Player.sendmsgEx(play,"【帝疆】#253|触发，范围造成"..damage.."点真实伤害")
end
local function _equip_is_normal_attack(MagicId)
    -- 仅普攻(MagicId为0或空)
    return not MagicId or MagicId == 0
end
-- 装备特殊效果辅助(Price列作为BuffId)
-- 说明: 所有逻辑只在穿戴/脱下时计算一次, 升级不自动刷新.
local _equip_slots = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,55,71,72,73,74,75,76,78,85,86,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120}
local function _equip_has_name(play, itemname)
    -- 检测当前穿戴中是否存在指定装备名
    if not play or not itemname or itemname == "" then
        return false
    end
    for _, pos in ipairs(_equip_slots) do
        local item = linkbodyitem(play, pos)
        if item and item ~= "0" then
            local name = getiteminfo(play, item, 7)
            -- release_print("检测装备位置"..pos.."，物品名："..tostring(name))
            if name == itemname then
                return true
            end
        end
    end
    return false
end
local function _equip_has_any(play, names)
    -- 检测当前穿戴中是否存在任意一件装备名
    if type(names) ~= "table" then
        return false
    end
    for _, name in ipairs(names) do
        if _equip_has_name(play, name) then
            return true
        end
    end
    return false
end
local function _equip_find_item(play, itemname)
    -- 获取指定装备名的物品对象
    if not play or not itemname or itemname == "" then
        return nil
    end
    for _, pos in ipairs(_equip_slots) do
        local item = linkbodyitem(play, pos)
        if item and item ~= "0" then
            local name = getiteminfo(play, item, 7)
            if name == itemname then
                return item
            end
        end
    end
    return nil
end
local function _equip_attr_str(attrs)
    -- 属性表转为 add_attlist 字符串
    if type(attrs) ~= "table" then
        return ""
    end
    local t = {}
    for k, v in pairs(attrs) do
        if v and v ~= 0 then
            t[k] = v
        end
    end
    return Player.getAttrTableToStr(t)
end
local function _equip_set_attr(play, listName, attrs, enable)
    -- 统一的属性加成/删除入口
    if not play or not listName or listName == "" then
        return
    end
    if enable then
        local attrStr = _equip_attr_str(attrs)
        if attrStr ~= "" then
            Player.add_attlist(play, listName, "=", attrStr, 1)
        end
    else
        Player.del_attlist(play, listName)
    end
end
local function _equip_roll(play, idx, chance, cd)
    -- 概率+CD触发判定(默认5%/30s)
    local now = os.time()
    local key = "N$equipbuff" .. idx .. "cd"
    local last = tonumber(getplaydef(play, key) or 0) or 0
    local cdv = tonumber(cd or 30) or 30
    if now - last < cdv then
        return false
    end
    local rate = tonumber(chance or 5) or 5
    if math.random(100) <= rate then
        setplaydef(play, key, now)
        return true
    end
    return false
end
local function _equip_hit_step(play, idx, step, MagicId)
    -- 连击计数: 只算普攻
    if not _equip_is_normal_attack(MagicId) then
        return false
    end
    local key = "N$equipbuff" .. idx .. "hit"
    local cnt = (tonumber(getplaydef(play, key) or 0) or 0) + 1
    setplaydef(play, key, cnt)
    return cnt % step == 0
end
local function _equip_clear_state(play, idx)
    -- 脱下时清除CD与计数
    setplaydef(play, "N$equipbuff" .. idx .. "cd", 0)
    setplaydef(play, "N$equipbuff" .. idx .. "hit", 0)
end
local function _equip_set_flag(play, key, enable)
    -- 套装标记
    setplaydef(play, key, enable and 1 or 0)
end
local function _equip_has_flag(play, key)
    return (tonumber(getplaydef(play, key) or 0) or 0) == 1
end
local function _equip_set_next_flag(play, idx, enable)
    setplaydef(play, "N$equipbuff" .. idx .. "next", enable and 1 or 0)
end
local function _equip_has_next_flag(play, idx)
    return (tonumber(getplaydef(play, "N$equipbuff" .. idx .. "next") or 0) or 0) == 1
end
local function _equip_is_player(obj)
    return obj and getbaseinfo(obj, ConstCfg.gbase.isplayer)
end
local function _equip_is_mon(obj)
    return obj and not getbaseinfo(obj, ConstCfg.gbase.isplayer)
end
local function _equip_get_maxhp(obj)
    return tonumber(getbaseinfo(obj, ConstCfg.gbase.maxhp) or 0) or 0
end
local function _equip_get_curhp(obj)
    return tonumber(getbaseinfo(obj, ConstCfg.gbase.curhp) or 0) or 0
end
local function _equip_is_full_hp(obj)
    local maxhp = _equip_get_maxhp(obj)
    local curhp = _equip_get_curhp(obj)
    return maxhp > 0 and curhp >= maxhp
end
local function _equip_add_hp_pct(play, pct)
    local maxhp = _equip_get_maxhp(play)
    if maxhp > 0 then
        humanhp(play, "+", math.floor(maxhp * pct))
    end
end
local function _equip_is_dalu(play, d)
    local mapid = tostring(getbaseinfo(play, ConstCfg.gbase.mapid) or "")
    return daluditu and daluditu[mapid] == d
end
local function _equip_set_timed_attr(play, key, listName, attrs, seconds)
    local now = os.time()
    local end_time = now + (tonumber(seconds) or 0)
    setplaydef(play, key, end_time)
    _equip_set_attr(play, listName, attrs, true)
end
local function _equip_clear_timed_attr(play, key, listName)
    local end_time = tonumber(getplaydef(play, key) or 0) or 0
    if end_time > 0 and os.time() >= end_time then
        setplaydef(play, key, 0)
        _equip_set_attr(play, listName, {}, false)
    end
end
local function _equip_add_random_stamina(play, itemname, minv, maxv)
    -- 体力元素(属性30)随机, 已有则不再生成
    local itemobj = _equip_find_item(play, itemname)
    if not itemobj or itemobj == "0" then
        return
    end
    local ok, item_json = pcall(json2tbl, getitemcustomabil(play, itemobj))
    item_json = ok and type(item_json) == "table" and item_json or nil
    if not item_json or type(item_json.abil) ~= "table" then
        item_json = json2tbl('{"abil":[{"i":0,"t":"[体力元素]","c":251,"v":[]}],"name":""}')
    end
    local idx = nil
    local abil_i = nil
    for i, v in ipairs(item_json.abil) do
        if type(v) == "table" and tostring(v.t or "") == "[体力元素]" then
            idx = i
            abil_i = tonumber(v.i) or (i - 1)
            if type(v.v) == "table" and #v.v > 0 then
                return
            end
            break
        end
    end
    if not idx then
        for i, v in ipairs(item_json.abil) do
            if type(v) == "table" and tostring(v.t or "") == "" and next(v.v or {}) == nil then
                idx = i
                abil_i = tonumber(v.i) or (i - 1)
                break
            end
        end
    end
    if not idx then
        idx = #item_json.abil + 1
        abil_i = idx - 1
    end
    local vmin = tonumber(minv) or 1
    local vmax = tonumber(maxv) or vmin
    if vmax < vmin then
        vmax = vmin
    end
    local val = math.random(vmin, vmax)
    local attr_list = {
        {254, 30, val, 0, 20, 1, 1},
    }
    item_json.abil[idx] = {i = abil_i or (idx - 1), t = "[体力元素]", c = 251, v = attr_list}
    setitemcustomabil(play, itemobj, tbl2json(item_json))
    refreshitem(play, itemobj)
end
local function _equip_add_random_element(play, itemname)
    -- 断情遗世/浮生梦痕: 首次穿戴随机21~26属性+5, 已有则不再生成
    local itemobj = _equip_find_item(play, itemname)
    if not itemobj or itemobj == "0" then
        return
    end
    local ok, item_json = pcall(json2tbl, getitemcustomabil(play, itemobj))
    item_json = ok and type(item_json) == "table" and item_json or nil
    if not item_json or type(item_json.abil) ~= "table" then
        item_json = json2tbl('{"abil":[{"i":0,"t":"[元素随机]","c":251,"v":[]}],"name":""}')
    end
    local idx = nil
    local abil_i = nil
    for i, v in ipairs(item_json.abil) do
        if type(v) == "table" and tostring(v.t or "") == "[元素随机]" then
            idx = i
            abil_i = tonumber(v.i) or (i - 1)
            if type(v.v) == "table" and #v.v > 0 then
                return
            end
            break
        end
    end
    if not idx then
        for i, v in ipairs(item_json.abil) do
            if type(v) == "table" and tostring(v.t or "") == "" and next(v.v or {}) == nil then
                idx = i
                abil_i = tonumber(v.i) or (i - 1)
                break
            end
        end
    end
    if not idx then
        idx = #item_json.abil + 1
        abil_i = idx - 1
    end
    local pool = {21, 22, 23, 24, 25, 26}
    local attr_id = pool[math.random(#pool)]
    local attr_list = {
        {254, attr_id, 5, 0, 20, 1, 1},
    }
    item_json.abil[idx] = {i = abil_i or (idx - 1), t = "[元素随机]", c = 251, v = attr_list}
    setitemcustomabil(play, itemobj, tbl2json(item_json))
    refreshitem(play, itemobj)
end
local function _equip_lock_series(play, zt, Damage, Target, MagicId, idx)
    -- 天痕: 穿戴加攻/血/魔; 对低等级玩家烈火/开天/逐日有概率冰冻
    if zt == 3 then
        if not Target or not getbaseinfo(Target, ConstCfg.gbase.isplayer) then
            return 0
        end
        if MagicId ~= 26 and MagicId ~= 66 and MagicId ~= 56 then
            return 0
        end
        local mylv = tonumber(getbaseinfo(play, ConstCfg.gbase.level) or 0) or 0
        local tlv = tonumber(getbaseinfo(Target, ConstCfg.gbase.level) or 0) or 0
        if tlv >= mylv then
            return 0
        end
        if _equip_roll(play, idx, 5, 30) then
            changemode(Target, ConstCfg.pmode.frost, 1)
        end
        return 0
    else
        _equip_set_attr(play, "装备buff" .. idx, { [3]=4888, [4]=4888, [1]=48888, [2]=48888 }, zt == 1)
        _toggle_buff_var(play, VarCfg.S_buffrwq, idx, zt == 1)
        if zt == 2 then
            _equip_clear_state(play, idx)
        end
    end
end
Buff = {
    [565] = function(play, zt, Damage, Target, MagicId)
        -- 神石攻击触发：火焰增伤、雷电控制。
        if zt ~= 3 then
            return 0
        end
        local extra = 0
        if _godstone_is_mon(Target) then
            local fire = _godstone_level(play, "fire")
            local monType = _godstone_mon_type(Target)
            if fire >= 1 and monType >= 2 and Damage and Damage > 0 then
                local rate = ({600, 1000, 1500, 2200})[fire] or 0
                extra = extra + math.floor(Damage * rate / 10000)
            end
            local thunder = _godstone_level(play, "thunder")
            if thunder > 0 then
                if thunder == 1 and monType <= 0 and _godstone_roll(play, "thunder_mon_1", 300, 0) then
                    changemode(Target, ConstCfg.pmode.stick, 1)
                elseif thunder == 2 and monType >= 1 and _godstone_roll(play, "thunder_mon_2", 600, 0) then
                    changemode(Target, ConstCfg.pmode.stick, 2)
                elseif thunder == 3 and _godstone_roll(play, "thunder_mon_3", 900, 0) then
                    local x = tonumber(getbaseinfo(Target, ConstCfg.gbase.x) or 0) or 0
                    local y = tonumber(getbaseinfo(Target, ConstCfg.gbase.y) or 0) or 0
                    rangeharm(play, x, y, 3, 1, 0, 0, 0, 2, 0, 3)
                    changemode(Target, ConstCfg.pmode.stick, 3)
                elseif thunder >= 4 and _godstone_is_red_boss(Target) and _godstone_roll(play, "thunder_mon_4", 1000, 0) then
                    changemode(Target, ConstCfg.pmode.stick, 3)
                end
            end
        elseif _godstone_is_player(Target) then
            local fire = _godstone_level(play, "fire")
            if fire >= 4 and Damage and Damage > 0 then
                extra = extra + math.floor(Damage * 1000 / 10000)
            end
            local thunder = _godstone_level(play, "thunder")
            if thunder >= 4 and _godstone_roll(play, "thunder_player", 800, 0) then
                changemode(Target, ConstCfg.pmode.stick, 2)
            end
        end
        return extra
    end,
    [566] = function(play, zt, Damage, Hiter, MagicId)
        -- 神石受击触发：山川减伤、海洋低血保命、大地反伤。
        if zt ~= 3 then
            return 0
        end
        local extra = 0
        if _godstone_is_mon(Hiter) then
            local mountain = _godstone_level(play, "mountain")
            if mountain >= 3 and Damage and Damage > 0 and _godstone_mon_type(Hiter) >= 1 then
                extra = extra - math.floor(Damage * 300 / 10000)
            end
            local ocean = _godstone_level(play, "ocean")
            if ocean >= 3 then
                local maxhp = tonumber(getbaseinfo(play, ConstCfg.gbase.maxhp) or 0) or 0
                local curhp = tonumber(getbaseinfo(play, ConstCfg.gbase.curhp) or 0) or 0
                if maxhp > 0 and curhp * 100 <= maxhp * 50 then
                    humanhp(play, "+", 1000)
                end
                if ocean >= 4 and maxhp > 0 and curhp * 100 <= maxhp * 2 and _godstone_roll(play, "ocean_shield", 10000, 180) then
                    addbuff(play, 20033, 1, 0, play)
                end
            end
        elseif _godstone_is_player(Hiter) then
            local earth = _godstone_level(play, "earth")
            if earth >= 4 and Damage and Damage > 0 and _godstone_roll(play, "earth_reflect", 800, 0) then
                humanhp(Hiter, "-", Damage, 110, 0, play, 1)
            end
        end
        return extra
    end,
    [70] = function(play,zt)      --被人物攻击随机(CD30秒)
        if zt == 3 then
            local sj = os.time()
            if sj - getplaydef(play,"N$buff70cd") > 30 then
                setplaydef(play,"N$buff70cd",sj)
                map(play,getbaseinfo(play,3))
            end
            return 0
        else
            local bl = getplaydef(play,VarCfg.S_buffbrwq)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["70"] = true
                setplaydef(play,"N$buff70cd",os.time())
            elseif zt == 2 then
                data["70"] = nil
            end
            setplaydef(play,VarCfg.S_buffbrwq,tbl2json(data))
        end
    end,
    [71] = function(play,zt,Damage,Target)      --溅射伤害  打怪时5%触发闪电，电击自身8*8范围内的所有敌人，造成500真实伤害拉取怪物仇恨。
        if zt == 3 then
            local sj = os.time()
            if sj - getplaydef(play,VarCfg.N_jsys) > 6 and math.random(100) > 5 then
                setplaydef(play,VarCfg.N_jsys,sj)
                local xx,yy,dqdt = getbaseinfo(play,4),getbaseinfo(play,5),getbaseinfo(play,3)
                local mons,gjsx = getobjectinmap(dqdt, xx,yy, 10, 2),500
                rangeharm(play,getbaseinfo(play,4),getbaseinfo(play,5),6,0,0,0,0,2,20310)
                if #mons > 1 then
                    for i, v in ipairs(mons) do
                        if i < 20 then
                            if Target ~= v then
                                humanhp(v,"-",500,108,0,play)
                                monmission(v,getbaseinfo(play,4)-3,getbaseinfo(play,5)-3,0)
                            end
                        end
                    end
                end
            end
        else
            local bl = getplaydef(play,VarCfg.S_buffgwh)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["71"] = true
            elseif zt == 2 then
                data["71"] = nil
            end
            setplaydef(play,VarCfg.S_buffgwh,tbl2json(data))
        end
    end,
    [72] = function(play,zt)      --AI挂机,被攻击自动随机
        if zt == 3 then
            local sj = os.time()
            local json = json2tbl(getplaydef(play,VarCfg.T_aigj))
            json = type(json) == "table" and json or {}
            local sc_data = Player.getJsonTableByVar(play, VarCfg["T_首充礼包"]) or {}
            local has_patrol = getflagstatus(play, VarCfg.BS_sckg) == 1 or (tonumber(sc_data.main_claimed or sc_data.other_lb or 0) or 0) >= 1
            if not has_patrol then
                return 0
            end
            if sj - getplaydef(play,VarCfg.N_Aigj[1]) >= 60 and not getbaseinfo(play,0) and json.gjkg then
                setplaydef(play,VarCfg.N_Aigj[1],sj)
                map(play,getbaseinfo(play,3))
                sendmsg(play,1,'{"Msg":"<font color=\'#28ef01\'>AI挂机：被人物攻击自动随机！</font>","Type":9}')
                startautoattack(play)
            end
            return 0
        else
            local bl = getplaydef(play,VarCfg.S_buffbrwq)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["72"] = true
            elseif zt == 2 then
                data["72"] = nil
            end
            setplaydef(play,VarCfg.S_buffbrwq,tbl2json(data))
        end
    end,
    [73] = function(play,zt,Damage,Target)      --赠送属性,刀刀绿毒
        if zt == 3 then
            makeposion(Target,0,2,10)
        else
            local bl = getplaydef(play,VarCfg.S_buffgwh)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["73"] = true
            elseif zt == 2 then
                data["73"] = nil
            end
            setplaydef(play,VarCfg.S_buffgwh,tbl2json(data))
        end
    end,
    --
    --callscriptex(play,"SETMAGICSKILLEFFT","野蛮冲撞",2704)
    --callscriptex(play,"SETMAGICSKILLEFFT","烈火剑法",2604)
    --callscriptex(play,"SETMAGICSKILLEFFT","逐日剑法",5602)
    --callscriptex(play,"SETMAGICSKILLEFFT","开天斩",6604)
    [74] = function(play,zt,Damage,Target,MagicId)      --攻杀剑术额外附加自身攻击上限35%的真实伤害
        if zt == 3 then
            if MagicId == 7 then
                humanhp(Target,"-",math.floor(getbaseinfo(play, 20)*0.35))
            end
        else
            local bl = getplaydef(play,VarCfg.S_buffgjh)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["74"] = true
            elseif zt == 2 then
                data["74"] = nil
            end
            setplaydef(play,VarCfg.S_buffgjh,tbl2json(data))
        end
    end,
    [75] = function(play,zt,Damage,Target,MagicId)      --刺杀剑术有5%的几率使目标受到的伤害翻倍
        if zt == 3 then
            if MagicId == 12 then
                if math.random(100) <= 5 then
                    return Damage
                end
            end
            return 0
        else
            local bl = getplaydef(play,VarCfg.S_buffgjq)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["75"] = true
            elseif zt == 2 then
                data["75"] = nil
            end
            setplaydef(play,VarCfg.S_buffgjq,tbl2json(data))
        end
    end,
    [76] = function(play,zt,Damage,Target,MagicId)      --半月弯刀攻击目标时，有20%的几率使攻击速度+2.持续5秒
        if zt == 3 then
            if MagicId == 25 then
                if math.random(100) <= 20 then
                    addbuff(play, 20101)
                end
            end
        else
            local bl = getplaydef(play,VarCfg.S_buffgjh)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["76"] = true
            elseif zt == 2 then
                data["76"] = nil
            end
            setplaydef(play,VarCfg.S_buffgjh,tbl2json(data))
        end
    end,
    [77] = function(play,zt,Damage,Target,MagicId)      --烈火剑法点燃被击中的目标3秒，没秒减少等同于释放者攻击上限20%的生命
        if zt == 3 then
            if MagicId == 26 then
                humanhp(Target,"-",math.floor(getbaseinfo(play, 20)*0.2),112,1,play)
                humanhp(Target,"-",math.floor(getbaseinfo(play, 20)*0.2),112,2,play)
                humanhp(Target,"-",math.floor(getbaseinfo(play, 20)*0.2),112,3,play)
            end
        else
            local bl = getplaydef(play,VarCfg.S_buffgjh)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["77"] = true
            elseif zt == 2 then
                data["77"] = nil
            end
            setplaydef(play,VarCfg.S_buffgjh,tbl2json(data))
        end
    end,
    [78] = function(play,zt,Damage,Target,MagicId)      --开天斩命中目标后，使目标5秒内降低20%的防御
        if zt == 3 then
            if MagicId == 66 then
                addbuff(Target, 20102)
            end
        else
            local bl = getplaydef(play,VarCfg.S_buffgjh)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["78"] = true
            elseif zt == 2 then
                data["78"] = nil
            end
            setplaydef(play,VarCfg.S_buffgjh,tbl2json(data))
        end
    end,
    [79] = function(play,zt,Damage,Target,MagicId)      --逐日剑法击中的目标为玩家时，有35%的几率使其额外减少当前HP10%的生命
        if zt == 3 then
            if MagicId == 56 then
                if getbaseinfo(Target,ConstCfg.gbase.isplayer) then
                    if math.random(100) <= 35 then
                        humanhp(Target,"-",math.floor(getbaseinfo(Target,11)*0.1))
                    end
                end
            end
        else
            local bl = getplaydef(play,VarCfg.S_buffgjh)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["79"] = true
            elseif zt == 2 then
                data["79"] = nil
            end
            setplaydef(play,VarCfg.S_buffgjh,tbl2json(data))
        end
    end,
    [107] = function(play,zt,Damage,Target,MagicId) --护体光环1：每3刀额外造成1000伤害
        if zt == 3 then
            local cnt = (tonumber(getplaydef(play, 'N$buff107_hit') or 0) or 0) + 1
            setplaydef(play, 'N$buff107_hit', cnt)
            if cnt % 3 == 0 then
                return 1000
            end
            return 0
        else
            _huti_set_trigger(play, VarCfg.S_buffgwq, 107, zt == 1)
        end
    end,
    [108] = function(play,zt,Damage,Target,MagicId) --护体光环2：对白怪切割+8888
        if zt == 3 then
            if _huti_monster_type(Target) == 1 then
                return 8888
            end
            return 0
        else
            _huti_set_trigger(play, VarCfg.S_buffgwq, 108, zt == 1)
        end
    end,
    [109] = function(play,zt,Damage,Target,MagicId) --护体光环2：格挡怪物伤害+888
        if zt == 3 then
            if _huti_monster_type(Target) ~= nil then
                return 888
            end
            return 0
        else
            _huti_set_trigger(play, VarCfg.S_buffbgwq, 109, zt == 1)
        end
    end,
    [110] = function(play,zt,Damage,Target,MagicId) --护体光环：所有怪物血量低于 5% 时直接斩杀
        if zt == 3 then
            if _huti_monster_type(Target) ~= nil then
                local curhp = tonumber(getbaseinfo(Target, 9) or 0) or 0
                local maxhp = tonumber(getbaseinfo(Target, 10) or 0) or 0
                if curhp > 0 and maxhp > 0 and curhp * 100 <= maxhp * 5 then
                    humanhp(Target, "-", curhp, 107, 0, play, 1)
                end
            end
            return 0
        else
            _huti_set_trigger(play, VarCfg.S_buffgwq, 110, zt == 1)
        end
    end,
    [111] = function(play,zt,Damage,Target,MagicId) --增加固定攻击伤害 + 13888
        if zt == 3 then
            return 13888
        else
            _huti_set_trigger(play, VarCfg.S_buffgwq, 111, zt == 1)
        end
    end,
    [301] = function(play,zt,Damage,Target,MagicId,Model) --天书仙法攻击触发
        -- zt=1/2：注册或移除攻击触发；zt=3：攻击回调并返回额外伤害
        if zt == 3 then
            _tianshu_buff_splash(play, Target)
            if xianfa_attack_trigger then
                return xianfa_attack_trigger(play, Damage, Target, MagicId, Model) or 0
            end
            return 0
        else
            local bl = getplaydef(play,VarCfg.S_buffgjq)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["301"] = true
            elseif zt == 2 then
                data["301"] = nil
            end
            setplaydef(play,VarCfg.S_buffgjq,tbl2json(data))
        end
    end,
    [302] = function(play,zt) --天书仙法复活触发
        -- zt=1/2：注册或移除复活触发；zt=4：复活后回调
        if zt == 4 then
            if xianfa_revive_trigger then
                xianfa_revive_trigger(play)
            end
        else
            local bl = getplaydef(play,VarCfg.S_bufffuhuo)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["302"] = true
            elseif zt == 2 then
                data["302"] = nil
            end
            setplaydef(play,VarCfg.S_bufffuhuo,tbl2json(data))
        end
    end,
    [303] = function(play,zt,Damage,Target) --诅咒傀儡：攻击怪物触发(zt=3)，10%概率上绿毒，10秒内置CD
        if zt == 3 then
            local now = os.time()
            if now - (getplaydef(play,"N$buff303cd") or 0) < 10 then
                return 0
            end
            if Target and math.random(100) <= 10 then
                setplaydef(play,"N$buff303cd",now)
                makeposion(Target,0,2,10)
            end
        else
            local bl = getplaydef(play,VarCfg.S_buffgwh)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["303"] = true
            elseif zt == 2 then
                data["303"] = nil
            end
            setplaydef(play,VarCfg.S_buffgwh,tbl2json(data))
        end
    end,
    [304] = function(play,zt,Damage,Target) --已取真经：攻击怪物触发(zt=3)，1%概率按目标最大HP的10%切割，10秒内置CD
        if zt == 3 then
            local now = os.time()
            if now - (getplaydef(play,"N$buff304cd") or 0) < 10 then
                return 0
            end
            if Target and math.random(100) <= 1 then
                if not getbaseinfo(Target,ConstCfg.gbase.isplayer) then
                    setplaydef(play,"N$buff304cd",now)
                    humanhp(Target,"-",math.floor(getbaseinfo(Target,11)*0.1))
                end
            end
        else
            local bl = getplaydef(play,VarCfg.S_buffgjh)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["304"] = true
            elseif zt == 2 then
                data["304"] = nil
            end
            setplaydef(play,VarCfg.S_buffgjh,tbl2json(data))
        end
    end,
    [305] = function(play,zt) --天蛇的认可：隐身效果占位，仅记录开关，具体隐身逻辑待接入
        if zt == 1 then
            setplaydef(play,"N$buff305",1)
        elseif zt == 2 then
            setplaydef(play,"N$buff305",0)
        end
    end,
    [306] = function(play,zt) --黑化肥会挥发：仙草成熟/炼丹加成；仅记录开关，逻辑由炼丹/种植处读取
        if zt == 1 then
            setplaydef(play,"N$buff306",1)
        elseif zt == 2 then
            setplaydef(play,"N$buff306",0)
        end
    end,
    [307] = function(play,zt) --定风珠：黄风谷/风灵珠试炼通行占位，仅记录开关
        if zt == 1 then
            setplaydef(play,"N$buff307",1)
        elseif zt == 2 then
            setplaydef(play,"N$buff307",0)
        end
    end,
    [308] = function(play,zt) --金箍棒：击杀附魔记录占位，仅记录开关
        if zt == 1 then
            setplaydef(play,"N$buff308",1)
        elseif zt == 2 then
            setplaydef(play,"N$buff308",0)
        end
    end,
    [309] = function(play,zt) --我是许仙：复活触发(zt=4) 1%概率不消耗复活次数，10秒内置CD
        if zt == 4 then
            local now = os.time()
            if now - (getplaydef(play,"N$buff309cd") or 0) < 10 then
                return 0
            end
            if math.random(100) <= 1 then
                setplaydef(play,"N$buff309cd",now)
                -- 标记本次复活不消耗次数（由下方立即处理一次）
                setplaydef(play,"N$buff309_free",1)
            end
            if getplaydef(play,"N$buff309_free") == 1 then
                -- 直接补回一次复活次数（避免本次消耗）
                setplaydef(play,"N$buff309_free",0)
                local cur = querymoney(play,15)
                local max = querymoney(play,14)
                if cur < max then
                    changemoney(play,15,"+",1,"BUFF309",true)
                end
                changemode(play,23,999999999,querymoney(play,15))
            end
            return 0
        end
        if zt == 1 then
            setplaydef(play,"N$buff309",1)
        elseif zt == 2 then
            setplaydef(play,"N$buff309",0)
        end
    end,
    [310] = function(play,zt) --来去自如：传送冷却-5秒；仅记录开关，传送逻辑读取该标记
        if zt == 1 then
            setplaydef(play,"N$buff310",1)
        elseif zt == 2 then
            setplaydef(play,"N$buff310",0)
        end
    end,
    [311] = function(play,zt) --头号玩家：红色仙法概率+20%；仅记录开关，抽取逻辑读取该标记
        if zt == 1 then
            setplaydef(play,"N$buff311",1)
        elseif zt == 2 then
            setplaydef(play,"N$buff311",0)
        end
    end,
    [312] = function(play,zt) --丹仙秘辛：丹药持续+50%/炼丹消耗-50%；仅记录开关，丹药/炼丹逻辑读取
        if zt == 1 then
            setplaydef(play,"N$buff312",1)
        elseif zt == 2 then
            setplaydef(play,"N$buff312",0)
        end
    end,
    [313] = function(play,zt) --阴阳玉佩：按时间切换属性（06-18阳：对怪攻速+10%，18-06阴：打怪爆率+10%）
        local function _apply(mode)
            if mode == 1 then
                Player.add_attlist(play, "阴阳玉佩_阳", "=", "3#200#1000", 1)
                Player.del_attlist(play, "阴阳玉佩_阴")
            else
                Player.add_attlist(play, "阴阳玉佩_阴", "=", "3#242#1000", 1)
                Player.del_attlist(play, "阴阳玉佩_阳")
            end
        end
        if zt == 1 then
            local h = tonumber(os.date("%H")) or 0
            local mode = (h >= 6 and h < 18) and 1 or 2
            setplaydef(play,"N$buff313",1)
            setplaydef(play,"N$buff313mode",mode)
            _apply(mode)
        elseif zt == 2 then
            setplaydef(play,"N$buff313",0)
            Player.del_attlist(play, "阴阳玉佩_阳")
            Player.del_attlist(play, "阴阳玉佩_阴")
        elseif zt == 3 then
            if getplaydef(play,"N$buff313") == 1 then
                local h = tonumber(os.date("%H")) or 0
                local mode = (h >= 6 and h < 18) and 1 or 2
                if getplaydef(play,"N$buff313mode") ~= mode then
                    setplaydef(play,"N$buff313mode",mode)
                    _apply(mode)
                end
            end
        end
    end,
    [314] = function(play,zt) --胖娃的肚兜：奇遇概率+10%占位，仅记录开关
        if zt == 1 then
            setplaydef(play,"N$buff314",1)
        elseif zt == 2 then
            setplaydef(play,"N$buff314",0)
        end
    end,
    [315] = function(play,zt,Damage,Target) --打怪，单体目标 BUFF：攻击有5%的概率附带[打怪切割+攻击力]x Y%的真实伤害  切割之斧的buff
        if zt == 3 then
            if not Target or getbaseinfo(Target,ConstCfg.gbase.isplayer) then
                return 0
            end
            if math.random(100) > 5 then
                return 0
            end
            local now = tonumber(os.time() or 0) or 0
            local last = tonumber(getplaydef(play,"N$buff315cd") or 0) or 0
            if now <= last then
                return 0
            end
            setplaydef(play,"N$buff315cd", now + 1)
            local cutDamage = tonumber(getbaseinfo(play, 51, 244) or 0) or 0
            local atkDamage = tonumber(getbaseinfo(play, 20) or 0) or 0
            local axeLevel = tonumber(Player.getEquipFieldByPos(play, 9, 1) or 0) or 0
            local axeRatio = axeLevel > 0 and (10 + (axeLevel - 1) * 5) or 0
            local extraDamage = math.floor((cutDamage + atkDamage) * axeRatio / 100)
            if extraDamage < 0 then
                extraDamage = 0
            end
            if extraDamage > 0 then
                Player.sendmsgEx(play,"【毁灭】#253|切割之斧触发，额外造成"..extraDamage.."点真实伤害")
                playeffect(Target,60456,0,0,1,0,0)
            end
            return extraDamage
        else
            local bl = getplaydef(play,VarCfg.S_buffgjq)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["315"] = true
            elseif zt == 2 then
                data["315"] = nil
            end
            setplaydef(play,VarCfg.S_buffgjq,tbl2json(data))
        end
    end,
    -- 316~338：称号/活动类 BUFF
    -- 说明：
    -- 1. zt == 1 表示获得称号或登录补挂时启用效果
    -- 2. zt == 2 表示失去称号时移除效果
    -- 3. zt == 3 表示战斗阶段的实时触发，用于追加伤害/回血等逻辑
    -- 4. 纯标记型称号只记录 N$buffxxx 状态，具体数值由称号属性表或其他流程处理
    [316] = function(play,zt) -- 镇杀幽魂：标记型BUFF，实际常驻属性由称号表提供
        if zt == 1 then
            _set_title_buff_flag(play, 316, true)
        elseif zt == 2 then
            _set_title_buff_flag(play, 316, false)
        end
    end,
    [317] = function(play,zt) -- 画中仙境：标记型BUFF，免控类判定可从该状态继续扩展
        if zt == 1 then
            _set_title_buff_flag(play, 317, true)
        elseif zt == 2 then
            _set_title_buff_flag(play, 317, false)
        end
    end,
    [318] = function(play,zt) -- 崂山秘法：标记型BUFF，常驻属性由称号表提供
        if zt == 1 then
            _set_title_buff_flag(play, 318, true)
        elseif zt == 2 then
            _set_title_buff_flag(play, 318, false)
        end
    end,
    [319] = function(play,zt,Damage,Target,MagicId) -- 赤焰天使：烈火剑法额外增伤10%
        if zt == 3 then
            if MagicId == 26 and Damage and Damage > 0 then
                return math.floor(Damage * 0.1)
            end
            return 0
        end
        -- 挂到 S_buffgjq，确保登录后能重新注册攻击增伤逻辑
        _set_title_buff_flag(play, 319, zt == 1)
        _toggle_buff_var(play, VarCfg.S_buffgjq, 319, zt == 1)
    end,
    [320] = function(play,zt,Damage) -- 葬众生：血量低于30%时，攻击伤害额外+20%
        if zt == 3 then
            local maxhp = tonumber(getbaseinfo(play, (ConstCfg and ConstCfg.gbase and ConstCfg.gbase.maxhp) or 10) or 0) or 0
            local curhp = tonumber(getbaseinfo(play, (ConstCfg and ConstCfg.gbase and ConstCfg.gbase.curhp) or 11) or maxhp) or 0
            if maxhp > 0 and curhp / maxhp <= 0.3 and Damage and Damage > 0 then
                return math.floor(Damage * 0.2)
            end
            return 0
        end
        _set_title_buff_flag(play, 320, zt == 1)
        _toggle_buff_var(play, VarCfg.S_buffgjq, 320, zt == 1)
    end,
    [321] = function(play,zt) -- 小倩的感谢：夜晚对怪增伤+1%，打怪爆率+10%
        if zt == 3 then
            -- 夜晚时补上限时属性，白天会自动移除，避免属性常驻
            _title_sync_time_attr(play, 321, "title_321_night", "3#245#100|3#242#1000", "night")
            return 0
        end
        if zt == 1 then
            _set_title_buff_flag(play, 321, true)
            _title_sync_time_attr(play, 321, "title_321_night", "3#245#100|3#242#1000", "night")
            _toggle_buff_var(play, VarCfg.S_buffgwq, 321, true)
        elseif zt == 2 then
            _set_title_buff_flag(play, 321, false)
            Player.del_attlist(play, "title_321_night")
            _toggle_buff_var(play, VarCfg.S_buffgwq, 321, false)
        end
    end,
    [322] = function(play,zt) -- 守护壁画：标记型BUFF，常驻切割属性由称号表提供
        if zt == 1 then
            _set_title_buff_flag(play, 322, true)
        elseif zt == 2 then
            _set_title_buff_flag(play, 322, false)
        end
    end,
    [323] = function(play,zt) -- 以貌取人：白天对怪增伤+10%
        if zt == 3 then
            _title_sync_time_attr(play, 323, "title_323_day", "3#245#1000", "day")
            return 0
        end
        if zt == 1 then
            _set_title_buff_flag(play, 323, true)
            _title_sync_time_attr(play, 323, "title_323_day", "3#245#1000", "day")
            _toggle_buff_var(play, VarCfg.S_buffgwq, 323, true)
        elseif zt == 2 then
            _set_title_buff_flag(play, 323, false)
            Player.del_attlist(play, "title_323_day")
            _toggle_buff_var(play, VarCfg.S_buffgwq, 323, false)
        end
    end,
    [324] = function(play,zt) -- 迟来的清醒：夜晚对怪增伤+10%
        if zt == 3 then
            _title_sync_time_attr(play, 324, "title_324_night", "3#245#1000", "night")
            return 0
        end
        if zt == 1 then
            _set_title_buff_flag(play, 324, true)
            _title_sync_time_attr(play, 324, "title_324_night", "3#245#1000", "night")
            _toggle_buff_var(play, VarCfg.S_buffgwq, 324, true)
        elseif zt == 2 then
            _set_title_buff_flag(play, 324, false)
            Player.del_attlist(play, "title_324_night")
            _toggle_buff_var(play, VarCfg.S_buffgwq, 324, false)
        end
    end,
    [325] = function(play,zt,Damage,Target) -- 沙海明珠：攻击3%概率雷击怪物，并切割其最大生命3%
        if zt == 3 then
            if not Target or getbaseinfo(Target, ConstCfg.gbase.isplayer) then
                return 0
            end
            local now = os.time()
            -- 10秒公共CD，避免同一称号效果过于频繁触发
            if now - (tonumber(getplaydef(play, "N$buff325cd") or 0) or 0) < 10 then
                return 0
            end
            if math.random(100) <= 3 then
                setplaydef(play, "N$buff325cd", now)
                local maxhp = tonumber(getbaseinfo(Target, (ConstCfg and ConstCfg.gbase and ConstCfg.gbase.maxhp) or 10) or 0) or 0
                local hurt = math.floor(maxhp * 0.03)
                if hurt > 0 then
                    humanhp(Target, "-", hurt, 106, 0, play, 1)
                    playeffect(Target, 60463, 0, 0, 1, 0, 0)
                end
            end
            return 0
        end
        -- 挂到 S_buffgwh，确保登录后能重新注册攻击附加伤害逻辑
        _set_title_buff_flag(play, 325, zt == 1)
        _toggle_buff_var(play, VarCfg.S_buffgwh, 325, zt == 1)
    end,
    [326] = function(play,zt,Damage,Target) -- 丝路往事：攻击等级高于自身的玩家时，额外造成5%伤害
        if zt == 3 then
            if Target and getbaseinfo(Target, ConstCfg.gbase.isplayer) and Damage and Damage > 0 then
                local myLevel = tonumber(getbaseinfo(play, ConstCfg.gbase.level) or 0) or 0
                local targetLevel = tonumber(getbaseinfo(Target, ConstCfg.gbase.level) or 0) or 0
                if targetLevel > myLevel then
                    return math.floor(Damage * 0.05)
                end
            end
            return 0
        end
        _set_title_buff_flag(play, 326, zt == 1)
        _toggle_buff_var(play, VarCfg.S_buffgjq, 326, zt == 1)
    end,
    [327] = function(play,zt,Damage,Target) -- 你的因果我来抗：攻击满血玩家时，额外造成5%伤害
        if zt == 3 then
            if Target and getbaseinfo(Target, ConstCfg.gbase.isplayer) and Damage and Damage > 0 then
                local maxhp = tonumber(getbaseinfo(Target, (ConstCfg and ConstCfg.gbase and ConstCfg.gbase.maxhp) or 10) or 0) or 0
                local curhp = tonumber(getbaseinfo(Target, (ConstCfg and ConstCfg.gbase and ConstCfg.gbase.curhp) or 11) or 0) or 0
                if maxhp > 0 and curhp >= maxhp then
                    return math.floor(Damage * 0.05)
                end
            end
            return 0
        end
        _set_title_buff_flag(play, 327, zt == 1)
        _toggle_buff_var(play, VarCfg.S_buffgjq, 327, zt == 1)
    end,
    [328] = function(play,zt) -- 大地之王祝福：击杀玩家后每层全属性+1%，最多10层
        if zt == 1 then
            _set_title_buff_flag(play, 328, true)
            _title_sync_dadi_attr(play)
        elseif zt == 2 then
            _set_title_buff_flag(play, 328, false)
            setplaydef(play, "N$buff328_stack", 0)
            _title_sync_dadi_attr(play)
        end
    end,
    [329] = function(play,zt) -- 天空之王祝福：生命+10%，并且每60秒恢复10%最大生命
        if zt == 3 then
            local now = os.time()
            if now - (tonumber(getplaydef(play, "N$buff329cd") or 0) or 0) >= 60 then
                setplaydef(play, "N$buff329cd", now)
                local maxhp = tonumber(getbaseinfo(play, (ConstCfg and ConstCfg.gbase and ConstCfg.gbase.maxhp) or 10) or 0) or 0
                local heal = math.floor(maxhp * 0.1)
                if heal > 0 then
                    humanhp(play, "+", heal, 5, 0, play)
                    playeffect(play, 60458, 0, 0, 1, 1, 0)
                end
            end
            return 0
        end
        -- 该效果既有常驻加成也有定时回血，因此保留登录重挂和CD状态
        if zt == 1 then
            _set_title_buff_flag(play, 329, true)
            _toggle_buff_var(play, VarCfg.S_buffgjh, 329, true)
            _toggle_buff_var(play, VarCfg.S_buffbgjq, 329, true)
        elseif zt == 2 then
            _set_title_buff_flag(play, 329, false)
            _toggle_buff_var(play, VarCfg.S_buffgjh, 329, false)
            _toggle_buff_var(play, VarCfg.S_buffbgjq, 329, false)
        end
    end,
    [340] = function(play,zt) -- 古刹魔瓶：装备背包神器后，击杀怪物有5%概率使打怪切割+1（常驻累计）
        if zt == 1 then
            _set_title_buff_flag(play, 340, true)
            if shaguai and shaguai.jia then
                shaguai.jia(play, 340)
            end
            _gcmp_refresh_item(play)
        elseif zt == 2 then
            _set_title_buff_flag(play, 340, false)
            if shaguai and shaguai.jian then
                shaguai.jian(play, 340)
            end
            _gcmp_refresh_item(play)
        end
    end,
    [341] = function(play,zt,Damage,Target) -- 首刀：首次命中满血怪物时，额外斩掉目标最大生命值15%
        if zt == 3 then
            if not Target or getbaseinfo(Target, ConstCfg.gbase.isplayer) then
                return 0
            end
            local maxhp = tonumber(getbaseinfo(Target, (ConstCfg and ConstCfg.gbase and ConstCfg.gbase.maxhp) or 10) or 0) or 0
            local curhp = tonumber(getbaseinfo(Target, (ConstCfg and ConstCfg.gbase and ConstCfg.gbase.hp) or 9) or 0) or 0
            if maxhp <= 0 or curhp <= 0 then
                return 0
            end
            -- attackdamage 里会先结算人物切割/对怪增伤，这里把那部分补回去后再判断是否为首刀。
            local pre_cut = tonumber(getbaseinfo(play, 51, 244) or 0) or 0
            local pre_hurt_up = 0
            if Damage and Damage > 0 then
                pre_hurt_up = Damage / 10000 * (tonumber(getbaseinfo(play, 51, 245) or 0) or 0)
            end
            if curhp + pre_cut + pre_hurt_up < maxhp then
                return 0
            end
            local hurt = math.floor(maxhp * 0.15)
            if hurt < 1 then
                hurt = 1
            end
            if hurt > curhp then
                hurt = curhp
            end
            return hurt
        end
        _set_title_buff_flag(play, 341, zt == 1)
        _toggle_buff_var(play, VarCfg.S_buffgwq, 341, zt == 1)
    end,
    [342] = function(play,zt,Damage,Target) -- 对玩家每次命中额外附加6666点真伤
        if zt == 3 then
            if Target and getbaseinfo(Target, ConstCfg.gbase.isplayer) then
                return 6666
            end
            return 0
        end
        _set_title_buff_flag(play, 342, zt == 1)
        _toggle_buff_var(play, VarCfg.S_buffrwq, 342, zt == 1)
    end,
    [330] = function(play,zt) -- 海洋之王祝福：标记型BUFF，冰冻相关数值由称号表或其他逻辑处理
        if zt == 1 then
            _set_title_buff_flag(play, 330, true)
        elseif zt == 2 then
            _set_title_buff_flag(play, 330, false)
        end
    end,
    [331] = function(play,zt,Damage,Target) -- 青铜之王祝福：攻击红名玩家时，额外造成10%伤害
        if zt == 3 then
            if Target and getbaseinfo(Target, ConstCfg.gbase.isplayer) and Damage and Damage > 0 then
                local pk = tonumber(getbaseinfo(Target, 46) or 0) or 0
                if pk > 0 then
                    return math.floor(Damage * 0.1)
                end
            end
            return 0
        end
        _set_title_buff_flag(play, 331, zt == 1)
        _toggle_buff_var(play, VarCfg.S_buffgjq, 331, zt == 1)
    end,
    [332] = function(play,zt,Damage,Target) -- 乾坤大挪移：5%概率对目标3x3范围造成最大魔法5%的范围伤害
        if zt == 3 then
            if not Target or math.random(100) > 5 then
                return 0
            end
            local now = os.time()
            -- 8秒公共CD，避免范围伤害效果连续触发
            if now - (tonumber(getplaydef(play, "N$buff332cd") or 0) or 0) < 8 then
                return 0
            end
            local maxmp = tonumber(getbaseinfo(play, (ConstCfg and ConstCfg.gbase and ConstCfg.gbase.maxmp) or 14) or 0) or 0
            local hurt = math.floor(maxmp * 0.05)
            if hurt > 0 then
                setplaydef(play, "N$buff332cd", now)
                rangeharm(play, getbaseinfo(Target, ConstCfg.gbase.x), getbaseinfo(Target, ConstCfg.gbase.y), 1, hurt, 0, 0, 0, 2, 20310, 12)
            end
            return 0
        end
        _set_title_buff_flag(play, 332, zt == 1)
        _toggle_buff_var(play, VarCfg.S_buffgwh, 332, zt == 1)
    end,
    [333] = function(play,zt) -- 吕布之力：标记型BUFF，激活外观或展示效果时可据此判定
        if zt == 1 then
            _set_title_buff_flag(play, 333, true)
        elseif zt == 2 then
            _set_title_buff_flag(play, 333, false)
        end
    end,
    [334] = function(play,zt,Damage,Target,MagicId) -- 火中取胜：受到烈火剑法伤害时减免5%
        if zt == 3 then
            if MagicId == 26 and Damage and Damage > 0 then
                return math.floor(Damage * 0.05)
            end
            return 0
        end
        _set_title_buff_flag(play, 334, zt == 1)
        _toggle_buff_var(play, VarCfg.S_buffbgjq, 334, zt == 1)
    end,
    [335] = function(play,zt) -- 打虎英雄：标记型BUFF，常驻攻速属性由称号表提供
        if zt == 1 then
            _set_title_buff_flag(play, 335, true)
        elseif zt == 2 then
            _set_title_buff_flag(play, 335, false)
        end
    end,
    [336] = function(play,zt) -- 侠义祝福：标记型BUFF，常驻全属性由称号表提供
        if zt == 1 then
            _set_title_buff_flag(play, 336, true)
        elseif zt == 2 then
            _set_title_buff_flag(play, 336, false)
        end
    end,
    [337] = function(play,zt) -- 马上发财：标记型BUFF，大奖励称号属性直接走称号表
        if zt == 1 then
            _set_title_buff_flag(play, 337, true)
        elseif zt == 2 then
            _set_title_buff_flag(play, 337, false)
        end
    end,
    [338] = function(play,zt) -- 日卡：标记型BUFF，常驻爆率属性由称号表提供
        if zt == 1 then
            _set_title_buff_flag(play, 338, true)
        elseif zt == 2 then
            _set_title_buff_flag(play, 338, false)
        end
    end,
    [563] = function(play,zt,Damage,Target) -- 诸邪退散：对红名怪每9刀额外造成288888真实伤害，并作为灰界免疫标记
        if zt == 3 then
            if not _is_red_name_monster(Target) then
                return 0
            end
            local cur = tonumber(getplaydef(play, "N$buff563_count") or 0) or 0
            cur = cur + 1
            if cur >= 9 then
                cur = 0
                setplaydef(play, "N$buff563_count", cur)
                playeffect(Target, 60456, 0, 0, 1, 0, 0)
                return 288888
            end
            setplaydef(play, "N$buff563_count", cur)
            return 0
        end
        _set_title_buff_flag(play, 563, zt == 1)
        _toggle_buff_var(play, VarCfg.S_buffgwq, 563, zt == 1)
        if zt ~= 1 then
            setplaydef(play, "N$buff563_count", 0)
        end
    end,
    [564] = function(play,zt) -- 切割刀：登录与激活时同步累计切割到切割刀物品上
        _set_title_buff_flag(play, 564, zt == 1)
        if zt == 1 then
            if shaguai and shaguai.jia then
                shaguai.jia(play, 564)
            end
        else
            if shaguai and shaguai.jian then
                shaguai.jian(play, 564)
            end
        end
        Buff_refreshRechargeBlade(play)
    end,
    [101] = function(play,zt) --仙食坊全满
        if zt == 1 then
            Player.add_attlist(play, "仙食坊全满", "=", "3#1#8888|3#4#588|3#242#3800|3#244#4888", 1)
        elseif zt == 2 then
            Player.del_attlist(play, "仙食坊全满")
        end
    end,
    [102] = function(play,zt,Damage,Target) --轩辕剑传人  BUFF:每三刀附带额外最大攻击1%的真实伤害
        if zt == 3 then
            local cs = getplaydef(play,"N$buff102")
            if cs < 3 then
                cs = cs + 1
                setplaydef(play,"N$buff102",cs)
            else
                setplaydef(play,"N$buff102",0)
                humanhp(Target,"-",math.floor(getbaseinfo(play, 20)*0.01))
                --Player.sendmsgEx(play,"轩辕剑传人触发真实伤害，造成"..math.floor(getbaseinfo(play, 20)*0.01).."点真实伤害！")
            end
        else
            local bl = getplaydef(play,VarCfg.S_buffgjh)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["102"] = true
                setplaydef(play,"N$buff102",0)
            elseif zt == 2 then
                data["102"] = nil
            end
            setplaydef(play,VarCfg.S_buffgjh,tbl2json(data))
        end
    end,
    [103] = function(play,zt,Damage,Target) --触发攻击系的灵根
        if zt == 3 then
            Npclib[22].lgcf(play,zt,Damage,Target,1)
        else
            local bl = getplaydef(play,VarCfg.S_buffgjh)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["103"] = true
                setplaydef(play,"N$buff_lg",0)
            elseif zt == 2 then
                data["103"] = nil
            end
            setplaydef(play,VarCfg.S_buffgjh,tbl2json(data))
        end
    end,
    [104] = function(play,zt,Damage,Target) --触发被攻击系的灵根
        if zt == 3 then
            Npclib[22].lgcf(play,zt,Damage,Target,2)
            return 0
        else
            local bl = getplaydef(play,VarCfg.S_buffbgjq)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["104"] = true
                setplaydef(play,"N$buff_lg",os.time())
            elseif zt == 2 then
                data["104"] = nil
            end
            setplaydef(play,VarCfg.S_buffbgjq,tbl2json(data))
        end
    end,
    [105] = function(play,zt,Damage,Target) --触发灵兽
        if zt == 3 then
            Npclib[64].lscf(play,zt,Damage,Target)
            return 0
        else
            local bl = getplaydef(play,VarCfg.S_buffgjh)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["105"] = true
                setplaydef(play,"N$buff_ls",os.time())
            elseif zt == 2 then
                data["105"] = nil
            end
            setplaydef(play,VarCfg.S_buffgjh,tbl2json(data))
        end
    end,
    [106] = function(play,zt,Damage,Target) --攻击嘲灾  如果没有buff_106 则对玩家造成100%的伤害
        if zt == 3 then
            if Target == nil then
                return 0
            end
            -- release_print("嘲灾触发")
            -- release_print(getbaseinfo(Target,1))
            -- release_print(hasbuff(play,20110))
            if getbaseinfo(Target,1) == "嘲灾" then
                local hasWeapon = Player.hasEquipOnPos(play, 1, "嘲天笑地")
                if not hasWeapon then
                    humanhp(play, "-", Damage, 0, 0)
                    -- release_print("嘲灾触发，造成"..Damage.."点伤害")
                end
            end
        else
            local bl = getplaydef(play,VarCfg.S_buffgwq)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["106"] = true
            elseif zt == 2 then
                data["106"] = nil
            end
            setplaydef(play,VarCfg.S_buffgwq,tbl2json(data))
        end
    end,
    [339] = function(play,zt,Damage,Target,MagicId,Model) --天书仙法攻击触发
        -- zt=1/2：注册或移除攻击触发；zt=3：攻击回调并返回额外伤害
        if zt == 3 then
            _tianshu_buff_splash(play, Target)
            return 0
        else
            local bl = getplaydef(play,VarCfg.S_buffgjq)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["339"] = true
            elseif zt == 2 then
                data["339"] = nil
            end
            setplaydef(play,VarCfg.S_buffgjq,tbl2json(data))
        end
    end,
    -- 装备特殊效果(Price列作为BuffId)
    [343] = function(play,zt,Damage,Target,MagicId) -- 锁鳞(无特殊效果)
        -- 注释: 仅作为装备表映射, 无属性与触发
        return 0
    end,
    [344] = function(play,zt,Damage,Target,MagicId) -- 裂天(无特殊效果)
        return 0
    end,
    [345] = function(play,zt,Damage,Target,MagicId) -- 星陨(无特殊效果)
        return 0
    end,
    [346] = function(play,zt,Damage,Target,MagicId) -- 寂照(无特殊效果)
        return 0
    end,
    [347] = function(play,zt,Damage,Target,MagicId) -- 天痕
        -- 效果: 穿戴加攻/血/魔; 对低等级玩家施放烈火/开天/逐日有概率冰冻1秒
        return _equip_lock_series(play, zt, Damage, Target, MagicId, 347)
    end,
    [348] = function(play,zt,Damage,Target,MagicId) -- ￠破晓￠
        -- 效果: 与潜锋两件套, 对怪伤害+5%
        if zt == 3 then
            return 0
        else
            local has = _equip_has_name(play, "￠破晓￠") and _equip_has_name(play, "潜锋")
            _equip_set_attr(play, "套装_破晓潜锋", { [245]=500 }, has)
        end
    end,
    [349] = function(play,zt,Damage,Target,MagicId) -- 潜锋
        -- 效果: 与￠破晓￠两件套, 对怪伤害+5%
        if zt == 3 then
            return 0
        else
            local has = _equip_has_name(play, "￠破晓￠") and _equip_has_name(play, "潜锋")
            _equip_set_attr(play, "套装_破晓潜锋", { [245]=500 }, has)
        end
    end,
    [350] = function(play,zt,Damage,Target,MagicId) -- 杀破狼
        -- 效果: 打怪爆率+20%; 与狱魔神两件套对怪切割+500
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff350", { [242]=2000 }, zt == 1)
            local has = _equip_has_name(play, "杀破狼") and _equip_has_name(play, "狱魔神")
            _equip_set_attr(play, "套装_玫瑰奇缘", { [244]=500 }, has)
        end
    end,
    [351] = function(play,zt,Damage,Target,MagicId) -- 狱魔神
        -- 效果: 打怪爆率+20%; 与杀破狼两件套对怪切割+500
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff351", { [242]=2000 }, zt == 1)
            local has = _equip_has_name(play, "杀破狼") and _equip_has_name(play, "狱魔神")
            _equip_set_attr(play, "套装_玫瑰奇缘", { [244]=500 }, has)
        end
    end,
    [352] = function(play,zt,Damage,Target,MagicId) -- 飞霞
        -- 效果: 固定攻击+444; 攻击怪物附带对怪切割7777
        if zt == 3 then
            if Target and not getbaseinfo(Target, ConstCfg.gbase.isplayer) then
                return 7777
            end
            return 0
        else
            _equip_set_attr(play, "装备buff352", { [3]=444, [4]=444 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgwq, 352, zt == 1)
        end
    end,
    [353] = function(play,zt,Damage,Target,MagicId) -- 雷渊
        -- 效果: 打怪爆率+28%; 固定生命/魔法+4444
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff353", { [242]=2800, [1]=4444, [2]=4444 }, zt == 1)
        end
    end,
    [354] = function(play,zt,Damage,Target,MagicId) -- 玄冥
        -- 效果: 固定攻击+444
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff354", { [3]=444, [4]=444 }, zt == 1)
        end
    end,
    [355] = function(play,zt,Damage,Target,MagicId) -- 月痕
        -- 效果: 固定生命/魔法+4444; 概率切割怪物1%~3%最大生命
        if zt == 3 then
            if Target and not getbaseinfo(Target, ConstCfg.gbase.isplayer) then
                if _equip_roll(play, 355, 5, 30) then
                    local maxhp = tonumber(getbaseinfo(Target, ConstCfg.gbase.maxhp) or 0) or 0
                    if maxhp > 0 then
                        local pct = math.random(1, 3)
                        return math.floor(maxhp * pct / 100)
                    end
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff355", { [1]=4444, [2]=4444 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgwq, 355, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 355)
            end
        end
    end,
    [356] = function(play,zt,Damage,Target,MagicId) -- 青衿
        -- 效果: 生命<50%时概率回血15%, CD 60s
        if zt == 3 then
            local maxhp = tonumber(getbaseinfo(play, ConstCfg.gbase.maxhp) or 0) or 0
            local curhp = tonumber(getbaseinfo(play, ConstCfg.gbase.curhp) or 0) or 0
            if maxhp > 0 and curhp * 100 <= maxhp * 50 then
                if _equip_roll(play, 356, 5, 60) then
                    humanhp(play, "+", math.floor(maxhp * 0.15))
                end
            end
            return 0
        else
            _toggle_buff_var(play, VarCfg.S_buffbgwq, 356, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffbrwq, 356, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 356)
            end
        end
    end,
    [357] = function(play,zt,Damage,Target,MagicId) -- 烛阴
        -- 效果: 固定生命/魔法+4444; 被攻击概率回复10%最大生命, CD 30s
        if zt == 3 then
            if _equip_roll(play, 357, 5, 30) then
                local maxhp = tonumber(getbaseinfo(play, ConstCfg.gbase.maxhp) or 0) or 0
                if maxhp > 0 then
                    humanhp(play, "+", math.floor(maxhp * 0.10))
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff357", { [1]=4444, [2]=4444 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffbgwq, 357, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffbrwq, 357, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 357)
            end
        end
    end,
    [358] = function(play,zt,Damage,Target,MagicId) -- 流岚
        -- 效果: 固定攻击+444; 概率造成攻击*333%
        if zt == 3 then
            if Target and not getbaseinfo(Target, ConstCfg.gbase.isplayer) then
                if _equip_roll(play, 358, 5, 30) then
                    local dc2 = tonumber(getbaseinfo(play, ConstCfg.gbase.dc2) or 0) or 0
                    return math.floor(dc2 * 3.33)
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff358", { [3]=444, [4]=444 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgwq, 358, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 358)
            end
        end
    end,
    [359] = function(play,zt,Damage,Target,MagicId) -- 酒醉黄龙(无特殊效果)
        return 0
    end,
    [360] = function(play,zt,Damage,Target,MagicId) -- 云渡履
        -- 效果: 固定攻击+444; 攻击满血怪物切割10%最大生命(普攻, CD 60s)
        if zt == 3 then
            if Target and not getbaseinfo(Target, ConstCfg.gbase.isplayer) then
                local curhp = tonumber(getbaseinfo(Target, ConstCfg.gbase.curhp) or 0) or 0
                local maxhp = tonumber(getbaseinfo(Target, ConstCfg.gbase.maxhp) or 0) or 0
                if maxhp > 0 and curhp == maxhp and _equip_is_normal_attack(MagicId) then
                    if _equip_roll(play, 360, 5, 60) then
                        return math.floor(maxhp * 0.10)
                    end
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff360", { [3]=444, [4]=444 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgwq, 360, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 360)
            end
        end
    end,
    [361] = function(play,zt,Damage,Target,MagicId) -- 笑傲天
        -- 效果: 打怪爆率+22%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff361", { [242]=2200 }, zt == 1)
        end
    end,
    [362] = function(play,zt,Damage,Target,MagicId) -- 破云金盔
        -- 效果: 固定攻+1488, 固定血/魔+14888; 攻击玩家概率切割10%~50%最大生命
        if zt == 3 then
            if Target and getbaseinfo(Target, ConstCfg.gbase.isplayer) then
                if _equip_roll(play, 362, 5, 30) then
                    local maxhp = tonumber(getbaseinfo(Target, ConstCfg.gbase.maxhp) or 0) or 0
                    if maxhp > 0 then
                        local pct = math.random(10, 50)
                        return math.floor(maxhp * pct / 100)
                    end
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff362", { [3]=1488, [4]=1488, [1]=14888, [2]=14888 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffrwq, 362, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 362)
            end
        end
    end,
    [363] = function(play,zt,Damage,Target,MagicId) -- 云影缥缈
        -- 效果: 对怪切割+4396
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff363", { [244]=4396 }, zt == 1)
        end
    end,
    [364] = function(play,zt,Damage,Target,MagicId) -- 金乌映日
        -- 效果: 对怪切割+4396
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff364", { [244]=4396 }, zt == 1)
        end
    end,
    [365] = function(play,zt,Damage,Target,MagicId) -- 雁南飞
        -- 效果: 与龙吟风两件套, 最大MP*1%转为攻击, 上限2000
        if zt == 3 then
            return 0
        else
            local has = _equip_has_name(play, "雁南飞") and _equip_has_name(play, "龙吟风")
            if has then
                local maxmp = tonumber(getbaseinfo(play, ConstCfg.gbase.maxmp) or 0) or 0
                local add = math.floor(maxmp * 0.01)
                if add > 2000 then
                    add = 2000
                end
                _equip_set_attr(play, "套装_雁南飞龙吟风", { [3]=add, [4]=add }, true)
            else
                _equip_set_attr(play, "套装_雁南飞龙吟风", {}, false)
            end
        end
    end,
    [366] = function(play,zt,Damage,Target,MagicId) -- 龙吟风
        -- 效果: 与雁南飞两件套, 最大MP*1%转为攻击, 上限2000
        if zt == 3 then
            return 0
        else
            local has = _equip_has_name(play, "雁南飞") and _equip_has_name(play, "龙吟风")
            if has then
                local maxmp = tonumber(getbaseinfo(play, ConstCfg.gbase.maxmp) or 0) or 0
                local add = math.floor(maxmp * 0.01)
                if add > 2000 then
                    add = 2000
                end
                _equip_set_attr(play, "套装_雁南飞龙吟风", { [3]=add, [4]=add }, true)
            else
                _equip_set_attr(play, "套装_雁南飞龙吟风", {}, false)
            end
        end
    end,
    [367] = function(play,zt,Damage,Target,MagicId) -- 踏风追电
        -- 效果: 固定攻击+444; 最大攻击+3%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff367", { [3]=444, [4]=444, [282]=3 }, zt == 1)
        end
    end,
    [368] = function(play,zt,Damage,Target,MagicId) -- 流光仙索
        -- 效果: 最大生命+3%; 固定生命/魔法+4444
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff368", { [280]=3, [1]=4444, [2]=4444 }, zt == 1)
        end
    end,
    [369] = function(play,zt,Damage,Target,MagicId) -- 断情遗世
        -- 效果: 固定攻击+444; 首次穿戴随机元素21~26之一+5
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff369", { [3]=444, [4]=444 }, zt == 1)
            if zt == 1 then
                _equip_add_random_element(play, "断情遗世")
            end
        end
    end,
    [370] = function(play,zt,Damage,Target,MagicId) -- 浮生梦痕
        -- 效果: 固定攻击+1488; 固定生命/魔法+14888; 首次穿戴随机元素21~26之一+5
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff370", { [3]=1488, [4]=1488, [1]=14888, [2]=14888 }, zt == 1)
            if zt == 1 then
                _equip_add_random_element(play, "浮生梦痕")
            end
        end
    end,
    [371] = function(play,zt,Damage,Target,MagicId) -- 清君侧
        -- 效果: 每三刀, 对人1.5倍伤害; 对怪2倍切割
        if zt == 3 then
            if not Target then
                return 0
            end
            if _equip_hit_step(play, 371, 3, MagicId) then
                if getbaseinfo(Target, ConstCfg.gbase.isplayer) then
                    return math.floor(Damage * 0.5)
                else
                    local cut = tonumber(getbaseinfo(play, 51, 244) or 0) or 0
                    if cut > 0 then
                        return cut * 2
                    end
                end
            end
            return 0
        else
            _toggle_buff_var(play, VarCfg.S_buffgjq, 371, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 371)
            end
        end
    end,
    [372] = function(play,zt,Damage,Target,MagicId) -- 鸿蒙初启
        -- 效果: 每三刀, 对人1.5倍伤害; 对怪2倍切割
        if zt == 3 then
            if not Target then
                return 0
            end
            if _equip_hit_step(play, 372, 3, MagicId) then
                if getbaseinfo(Target, ConstCfg.gbase.isplayer) then
                    return math.floor(Damage * 0.5)
                else
                    local cut = tonumber(getbaseinfo(play, 51, 244) or 0) or 0
                    if cut > 0 then
                        return cut * 2
                    end
                end
            end
            return 0
        else
            _toggle_buff_var(play, VarCfg.S_buffgjq, 372, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 372)
            end
        end
    end,
    [373] = function(play,zt,Damage,Target,MagicId) -- 青冥幻影
        -- 效果: 固定攻+288, 固定血/魔+2888; 每三刀对人1.5倍伤害
        if zt == 3 then
            if Target and getbaseinfo(Target, ConstCfg.gbase.isplayer) then
                if _equip_hit_step(play, 373, 3, MagicId) then
                    return math.floor(Damage * 0.5)
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff373", { [3]=288, [4]=288, [1]=2888, [2]=2888 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgjq, 373, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 373)
            end
        end
    end,
    [374] = function(play,zt,Damage,Target,MagicId) -- 玄羽乘风
        -- 效果: 固定攻+288, 固定血/魔+2888; 每三刀对怪切割*2
        if zt == 3 then
            if Target and not getbaseinfo(Target, ConstCfg.gbase.isplayer) then
                if _equip_hit_step(play, 374, 3, MagicId) then
                    local cut = tonumber(getbaseinfo(play, 51, 244) or 0) or 0
                    if cut > 0 then
                        return cut * 2
                    end
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff374", { [3]=288, [4]=288, [1]=2888, [2]=2888 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgjq, 374, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 374)
            end
        end
    end,
    [375] = function(play,zt,Damage,Target,MagicId) -- 锁天紫绦
        -- 效果: 固定攻+1888, 固定血/魔+18888; 每三刀对人1.5倍, 对怪切割*2
        if zt == 3 then
            if not Target then
                return 0
            end
            if _equip_hit_step(play, 375, 3, MagicId) then
                if getbaseinfo(Target, ConstCfg.gbase.isplayer) then
                    return math.floor(Damage * 0.5)
                else
                    local cut = tonumber(getbaseinfo(play, 51, 244) or 0) or 0
                    if cut > 0 then
                        return cut * 2
                    end
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff375", { [3]=1888, [4]=1888, [1]=18888, [2]=18888 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgjq, 375, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 375)
            end
        end
    end,
    [376] = function(play,zt,Damage,Target,MagicId) -- 裂星玄盔(无特殊效果)
        return 0
    end,
    [377] = function(play,zt,Damage,Target,MagicId) -- 曜天灵珑(无特殊效果)
        return 0
    end,
    [378] = function(play,zt,Damage,Target,MagicId) -- 风云浩劫(无特殊效果)
        return 0
    end,
    [379] = function(play,zt,Damage,Target,MagicId) -- 寂灭苍穹(无特殊效果)
        return 0
    end,
    [380] = function(play,zt,Damage,Target,MagicId) -- 伏龙玄带(无特殊效果)
        return 0
    end,
    [381] = function(play,zt,Damage,Target,MagicId) -- 长歌踏月
        -- 效果: 与九霄游风两件套, 触发九霄游风效果
        if zt == 3 then
            return 0
        else
            local has = _equip_has_name(play, "九霄游风") and _equip_has_name(play, "长歌踏月")
            _equip_set_flag(play, "N$equipset_jiuxiao", has)
        end
    end,
    [382] = function(play,zt,Damage,Target,MagicId) -- 九霄游风
        -- 效果: 两件套(九霄游风+长歌踏月)时, 对人概率打掉10%血量并回复自身同等血量
        if zt == 3 then
            if not _equip_has_flag(play, "N$equipset_jiuxiao") then
                return 0
            end
            if Target and getbaseinfo(Target, ConstCfg.gbase.isplayer) then
                if _equip_roll(play, 382, 5, 30) then
                    local maxhp = tonumber(getbaseinfo(Target, ConstCfg.gbase.maxhp) or 0) or 0
                    if maxhp > 0 then
                        local dmg = math.floor(maxhp * 0.10)
                        humanhp(play, "+", dmg)
                        return dmg
                    end
                end
            end
            return 0
        else
            local has = _equip_has_name(play, "九霄游风") and _equip_has_name(play, "长歌踏月")
            _equip_set_flag(play, "N$equipset_jiuxiao", has)
            _toggle_buff_var(play, VarCfg.S_buffrwq, 382, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 382)
            end
        end
    end,
    [383] = function(play,zt,Damage,Target,MagicId) -- 封魔镇狱
        -- 效果: 被人物攻击概率定身对方2秒
        if zt == 3 then
            if Target and getbaseinfo(Target, ConstCfg.gbase.isplayer) then
                if _equip_roll(play, 383, 5, 30) then
                    changemode(Target, ConstCfg.pmode.stick, 2)
                end
            end
            return 0
        else
            _toggle_buff_var(play, VarCfg.S_buffbrwq, 383, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 383)
            end
        end
    end,
    [384] = function(play,zt,Damage,Target,MagicId) -- 炽焰珠链
        -- 效果: 打怪爆率+25%; 固定生命/魔法+4444
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff384", { [242]=2500, [1]=4444, [2]=4444 }, zt == 1)
        end
    end,
    [385] = function(play,zt,Damage,Target,MagicId) -- 火种之戒
        -- 效果: 固定生命/魔法+4888; 防止全毒+100%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff385", { [1]=4888, [2]=4888, [16]=100 }, zt == 1)
        end
    end,
    [386] = function(play,zt,Damage,Target,MagicId) -- 明冽寒
        -- 效果: 每18次普攻触发斩杀怪物5%最大生命
        if zt == 3 then
            if Target and not getbaseinfo(Target, ConstCfg.gbase.isplayer) then
                if _equip_hit_step(play, 386, 18, MagicId) then
                    local maxhp = tonumber(getbaseinfo(Target, ConstCfg.gbase.maxhp) or 0) or 0
                    if maxhp > 0 then
                        return math.floor(maxhp * 0.05)
                    end
                end
            end
            return 0
        else
            _toggle_buff_var(play, VarCfg.S_buffgwq, 386, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 386)
            end
        end
    end,
    [387] = function(play,zt,Damage,Target,MagicId) -- 赤焰戒
        -- 效果: 每18次普攻触发斩杀怪物5%最大生命
        if zt == 3 then
            if Target and not getbaseinfo(Target, ConstCfg.gbase.isplayer) then
                if _equip_hit_step(play, 387, 18, MagicId) then
                    local maxhp = tonumber(getbaseinfo(Target, ConstCfg.gbase.maxhp) or 0) or 0
                    if maxhp > 0 then
                        return math.floor(maxhp * 0.05)
                    end
                end
            end
            return 0
        else
            _toggle_buff_var(play, VarCfg.S_buffgwq, 387, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 387)
            end
        end
    end,
    [388] = function(play,zt,Damage,Target,MagicId) -- 火舞手镯
        -- 效果: 固定攻+488; 固定血/魔+4888; 打怪爆率+28%; 每秒回血=等级*10
        if zt == 3 then
            return 0
        else
            local level = tonumber(getbaseinfo(play, ConstCfg.gbase.level) or 0) or 0
            _equip_set_attr(play, "装备buff388", { [3]=488, [4]=488, [1]=4888, [2]=4888, [242]=2800, [71]=level*10 }, zt == 1)
        end
    end,
    [389] = function(play,zt,Damage,Target,MagicId) -- 熔岩手镯
        -- 效果: 固定攻+288; 固定血/魔+2888; 攻击力+688
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff389", { [3]=976, [4]=976, [1]=2888, [2]=2888 }, zt == 1)
        end
    end,
    [390] = function(play,zt,Damage,Target,MagicId) -- 烈风之履
        -- 效果: 固定攻+288; 固定血/魔+2888; 攻击力+488
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff390", { [3]=776, [4]=776, [1]=2888, [2]=2888 }, zt == 1)
        end
    end,
    [391] = function(play,zt,Damage,Target,MagicId) -- 火龙束带
        -- 效果: 固定攻+444; 对怪伤害+5%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff391", { [3]=444, [4]=444, [245]=500 }, zt == 1)
        end
    end,
    [392] = function(play,zt,Damage,Target,MagicId) -- ??
        -- 效果: 固定攻+288; 固定血/魔+2888; 攻击倍数+1.05(属性67 +5)
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff392", { [3]=288, [4]=288, [1]=2888, [2]=2888, [67]=5 }, zt == 1)
        end
    end,
        [393] = function(play,zt,Damage,Target,MagicId) -- 冥火
-- 被玩家攻击时有高概率反弹(50%)的伤害
-- 并恢复自身[50%]的生命值(CD120秒)
        if zt == 3 then
            if _equip_is_player(Target) then
                if _equip_roll(play, 393, 50, 120) then
                    local maxhp = _equip_get_maxhp(play)
                    if maxhp > 0 then
                        humanhp(play, "+", math.floor(maxhp * 0.50))
                    end
                    if Damage and Damage > 0 then
                        humanhp(Target, "-", math.floor(Damage * 0.50), 110, 0, play, 1)
                    end
                end
            end
            return 0
        else
            _toggle_buff_var(play, VarCfg.S_buffbrwq, 393, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 393)
            end
        end
    end,
        [394] = function(play,zt,Damage,Target,MagicId) -- 鬼影
-- 攻击力：+ 4888
-- 生命值：+ 48888
-- 魔法值：+ 48888
-- IMG:res/tips/3.png#0#0&0
-- 攻击对当前(5000W生命值)以下的怪物时
-- 触发刀刀切割[2%]的最大生命值！
        if zt == 3 then
            if _equip_is_mon(Target) then
                local maxhp = _equip_get_maxhp(Target)
                if maxhp > 0 and maxhp <= 50000000 then
                    return math.floor(maxhp * 0.02)
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff394", { [3]=4888, [4]=4888, [1]=48888, [2]=48888 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgwq, 394, zt == 1)
        end
    end,
        [395] = function(play,zt,Damage,Target,MagicId) -- 夜行
-- 攻击力：+ 3888
-- 生命值：+ 38888
-- 魔法值：+ 38888
-- IMG:res/tips/3.png#0#0&0
-- 人物在三大陆所属地图增加以下属性
-- 对怪伤害：+ 20%
-- 打怪爆率：+ 50%
-- 攻击时附带对(三大陆所属地图)的怪
-- 物额外造成[88888]点对怪切割！
        if zt == 3 then
            if _equip_is_mon(Target) and _equip_is_dalu(play, 3) then
                return 88888
            end
            return 0
        else
            _equip_set_attr(play, "装备buff395", { [3]=3888, [4]=3888, [1]=38888, [2]=38888, [245]=2000, [242]=5000 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgwq, 395, zt == 1)
        end
    end,
        [396] = function(play,zt,Damage,Target,MagicId) -- 星辰冕冠
-- 固定攻击力：+ 1288
-- 固定生命值：+ 12888
-- 固定魔法值：+ 12888
-- IMG:res/tips/3.png#0#0&0
-- 每秒恢复人物(等级*10)的生命值
-- 攻击时附带对(三大陆所属地图)的怪
-- 物额外造成[88888]点对怪切割！
        if zt == 3 then
            if _equip_is_mon(Target) and _equip_is_dalu(play, 3) then
                return 88888
            end
            return 0
        else
            local level = tonumber(getbaseinfo(play, ConstCfg.gbase.level) or 0) or 0
            _equip_set_attr(play, "装备buff396", { [3]=1288, [4]=1288, [1]=12888, [2]=12888, [71]=level*10 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgwq, 396, zt == 1)
        end
    end,
        [397] = function(play,zt,Damage,Target,MagicId) -- 无影梦链
-- 固定攻击力：+ 1288
-- 固定生命值：+ 12888
-- 固定魔法值：+ 12888
-- IMG:res/tips/3.png#0#0&0
-- 每秒恢复人物(等级*10)的生命值
-- 攻击时附带对(三大陆所属地图)的怪
-- 物额外造成[88888]点对怪切割！
        if zt == 3 then
            if _equip_is_mon(Target) and _equip_is_dalu(play, 3) then
                return 88888
            end
            return 0
        else
            local level = tonumber(getbaseinfo(play, ConstCfg.gbase.level) or 0) or 0
            _equip_set_attr(play, "装备buff397", { [3]=1288, [4]=1288, [1]=12888, [2]=12888, [71]=level*10 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgwq, 397, zt == 1)
        end
    end,
        [398] = function(play,zt,Damage,Target,MagicId) -- 冥炎之戒
-- 固定攻击力：+ 1288
-- 固定生命值：+ 12888
-- 固定魔法值：+ 12888
-- IMG:res/tips/3.png#0#0&0
-- 每秒恢复人物(等级*10)的生命值
-- 攻击时附带对(三大陆所属地图)的怪
-- 物额外造成[88888]点对怪切割！
        if zt == 3 then
            if _equip_is_mon(Target) and _equip_is_dalu(play, 3) then
                return 88888
            end
            return 0
        else
            local level = tonumber(getbaseinfo(play, ConstCfg.gbase.level) or 0) or 0
            _equip_set_attr(play, "装备buff398", { [3]=1288, [4]=1288, [1]=12888, [2]=12888, [71]=level*10 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgwq, 398, zt == 1)
        end
    end,
        [399] = function(play,zt,Damage,Target,MagicId) -- 破碎轮回
-- 固定攻击力：+ 1288
-- 固定生命值：+ 12888
-- 固定魔法值：+ 12888
-- IMG:res/tips/3.png#0#0&0
-- 每秒恢复人物(等级*10)的生命值
-- 攻击时附带对(三大陆所属地图)的怪
-- 物额外造成[88888]点对怪切割！
        if zt == 3 then
            if _equip_is_mon(Target) and _equip_is_dalu(play, 3) then
                return 88888
            end
            return 0
        else
            local level = tonumber(getbaseinfo(play, ConstCfg.gbase.level) or 0) or 0
            _equip_set_attr(play, "装备buff399", { [3]=1288, [4]=1288, [1]=12888, [2]=12888, [71]=level*10 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgwq, 399, zt == 1)
        end
    end,
    [400] = function(play,zt,Damage,Target,MagicId) -- 幽灵步履
-- 固定攻击力：+ 1288
-- IMG:res/tips/3.png#0#0&0
-- 攻击倍数：+ 5%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff400", { [3]=1288, [4]=1288, [67]=5 }, zt == 1)
        end
    end,
    [401] = function(play,zt,Damage,Target,MagicId) -- 惊雷踏云
-- 固定攻击力：+ 1288
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff401", { [3]=1288, [4]=1288 }, zt == 1)
        end
    end,
    [402] = function(play,zt,Damage,Target,MagicId) -- 疾风追星
-- 固定攻击力：+ 1288
-- 固定生命值：+ 12888
-- 固定魔法值：+ 12888
-- IMG:res/tips/3.png#0#0&0
-- 打怪爆率：+ 38%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff402", { [3]=1288, [4]=1288, [1]=12888, [2]=12888, [242]=3800 }, zt == 1)
        end
    end,
    [403] = function(play,zt,Damage,Target,MagicId) -- 九重苍带
-- 固定攻击力：+ 1288
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff403", { [3]=1288, [4]=1288 }, zt == 1)
        end
    end,
        [404] = function(play,zt,Damage,Target,MagicId) -- 紫电
-- IMG:res/tips/3.png#0#0&0
-- 每2分钟必定会获得一个[能量护盾]
-- 可抵挡一次目标的技能伤害，护盾被
-- 击破后会召唤雷劫降临，对击破护盾
-- 的目标造成[20%]最大生命值的伤害!
        if zt == 3 then
            if MagicId and MagicId > 0 and Target then
                if _equip_roll(play, 404, 100, 120) then
                    local tmax = _equip_get_maxhp(Target)
                    if tmax > 0 then
                        humanhp(Target, "-", math.floor(tmax * 0.20), 110, 0, play, 1)
                    end
                    return Damage
                end
            end
            return 0
        else
            _toggle_buff_var(play, VarCfg.S_buffbgjq, 404, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 404)
            end
        end
    end,
    [405] = function(play,zt,Damage,Target,MagicId) -- 羽化仙
        -- 人物触发复活后每秒恢复人物[10%]
        -- 的最大生命值，效果持续(5秒)
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff405", { [1]=12888, [2]=12888 }, zt == 1)
        end
    end,
    [406] = function(play,zt,Damage,Target,MagicId) -- 幻梦池
        -- 人物触发复活后每秒恢复人物[10%]
        -- 的最大生命值，效果持续(5秒)
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff406", { [1]=12888, [2]=12888 }, zt == 1)
        end
    end,
    [407] = function(play,zt,Damage,Target,MagicId) -- 血焰
        -- 使用传送功能增加[30%]移速3S。
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff407", { [1]=12888, [2]=12888 }, zt == 1)
        end
    end,
        [408] = function(play,zt,Damage,Target,MagicId) -- 青霄剑舞
-- 固定攻击力：+ 2888
-- 固定生命值：+ 28888
-- 固定魔法值：+ 28888
-- IMG:res/tips/3.png#0#0&0
-- 攻击生命值低于30%的怪物时刀刀切
-- 割[1%]最大生命值。
        if zt == 3 then
            if _equip_is_mon(Target) then
                local maxhp = _equip_get_maxhp(Target)
                local curhp = _equip_get_curhp(Target)
                if maxhp > 0 and curhp * 100 <= maxhp * 30 then
                    return math.floor(maxhp * 0.01)
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff408", { [3]=2888, [4]=2888, [1]=28888, [2]=28888 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgwq, 408, zt == 1)
        end
    end,
    [409] = function(play,zt,Damage,Target,MagicId) -- 苍月孤行
-- 打怪爆率：+ 20%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff409", { [242]=2000 }, zt == 1)
        end
    end,
    [410] = function(play,zt,Damage,Target,MagicId) -- 白莲盛开
-- 打怪爆率：+ 20%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff410", { [242]=2000 }, zt == 1)
        end
    end,
    [411] = function(play,zt,Damage,Target,MagicId) -- 指天
-- 打怪爆率：+ 20%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff411", { [242]=2000 }, zt == 1)
        end
    end,
    [412] = function(play,zt,Damage,Target,MagicId) -- 金刚
-- 打怪爆率：+ 20%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff412", { [242]=2000 }, zt == 1)
        end
    end,
        [413] = function(play,zt,Damage,Target,MagicId) -- 出世
-- 固定生命值：+ 12888
-- 固定魔法值：+ 12888
-- IMG:res/tips/3.png#0#0&0
-- 杀死人物后触发隐身[2秒]并且恢复
-- (10%)的最大生命值！[CD:20S]
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff413", { [1]=12888, [2]=12888 }, zt == 1)
            _equip_set_flag(play, "N$equipbuff413on", zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 413)
            end
        end
    end,
    [414] = function(play,zt,Damage,Target,MagicId) -- 宿命
-- 固定生命值：+ 12888
-- 固定魔法值：+ 12888
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff414", { [1]=12888, [2]=12888 }, zt == 1)
        end
    end,
    [415] = function(play,zt,Damage,Target,MagicId) -- 向问天
-- 固定攻击力：+ 1288
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff415", { [3]=1288, [4]=1288 }, zt == 1)
        end
    end,
    [416] = function(play,zt,Damage,Target,MagicId) -- 归一
-- 固定攻击力：+ 1288
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff416", { [3]=1288, [4]=1288 }, zt == 1)
        end
    end,
        [417] = function(play,zt,Damage,Target,MagicId) -- 薜萝藏虺
-- 攻击时有概率召唤天雷对[3*3范围]
-- 的目标麻痹(1S)，并造成5倍攻击力
-- 数值的对怪切割！(CD60秒)
        if zt == 3 then
            if _equip_is_mon(Target) then
                if _equip_roll(play, 417, 5, 60) then
                    changemode(Target, ConstCfg.pmode.stick, 1)
                    local dc2 = tonumber(getbaseinfo(play, ConstCfg.gbase.dc2) or 0) or 0
                    return math.floor(dc2 * 5)
                end
            end
            return 0
        else
            _toggle_buff_var(play, VarCfg.S_buffgwq, 417, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 417)
            end
        end
    end,
        [418] = function(play,zt,Damage,Target,MagicId) -- 破界
-- 攻击时有概率召唤天雷对[3*3范围]
-- 的目标麻痹(1S)，并造成5倍攻击力
-- 数值的对怪切割！(CD60秒)
        if zt == 3 then
            if _equip_is_mon(Target) then
                if _equip_roll(play, 418, 5, 60) then
                    changemode(Target, ConstCfg.pmode.stick, 1)
                    local dc2 = tonumber(getbaseinfo(play, ConstCfg.gbase.dc2) or 0) or 0
                    return math.floor(dc2 * 5)
                end
            end
            return 0
        else
            _toggle_buff_var(play, VarCfg.S_buffgwq, 418, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 418)
            end
        end
    end,
        [419] = function(play,zt,Damage,Target,MagicId) -- 传奇
-- 固定攻击力：+ 2888
-- 固定生命值：+ 28888
-- 固定魔法值：+ 28888
-- IMG:res/tips/3.png#0#0&0
-- 攻击时有概率可召唤天雷对目标进行
-- [8次]连击，第一次造成20%伤害，后
-- 续每次连击增加30%伤害![CD：60秒]
        if zt == 3 then
            if _equip_roll(play, 419, 5, 60) then
                return math.floor(Damage * 10)
            end
            return 0
        else
            _equip_set_attr(play, "装备buff419", { [3]=2888, [4]=2888, [1]=28888, [2]=28888 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgjq, 419, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 419)
            end
        end
    end,
        [420] = function(play,zt,Damage,Target,MagicId) -- 阿修罗之眼
-- IMG:res/tips/3.png#0#0&0
-- 搭配[扶摇上青天]可组合套装
-- 人物每秒恢复[1%]的最大生命值
        if zt == 3 then
            return 0
        else
            local has = _equip_has_name(play, "阿修罗之眼") and _equip_has_name(play, "扶摇上青天")
            if has then
                local maxhp = _equip_get_maxhp(play)
                local add = math.floor(maxhp * 0.01)
                _equip_set_attr(play, "装备buff_阿修罗之眼_扶摇上青天", { [71]=add }, true)
            else
                _equip_set_attr(play, "装备buff_阿修罗之眼_扶摇上青天", {}, false)
            end
        end
    end,
        [421] = function(play,zt,Damage,Target,MagicId) -- 扶摇上青天
-- IMG:res/tips/3.png#0#0&0
-- 搭配[阿修罗之眼]可组合套装
-- 人物每秒恢复[1%]的最大生命值
        if zt == 3 then
            return 0
        else
            local has = _equip_has_name(play, "阿修罗之眼") and _equip_has_name(play, "扶摇上青天")
            if has then
                local maxhp = _equip_get_maxhp(play)
                local add = math.floor(maxhp * 0.01)
                _equip_set_attr(play, "装备buff_阿修罗之眼_扶摇上青天", { [71]=add }, true)
            else
                _equip_set_attr(play, "装备buff_阿修罗之眼_扶摇上青天", {}, false)
            end
        end
    end,
        [422] = function(play,zt,Damage,Target,MagicId) -- 空
-- 固定攻击力：+ 1288
-- IMG:res/tips/3.png#0#0&0
-- 攻击满血人物直接斩杀(10%)生命值
-- (60秒内只允许触发一次当前BUFF)
        if zt == 3 then
            if _equip_is_player(Target) and _equip_is_full_hp(Target) then
                if _equip_roll(play, 422, 5, 60) then
                    local maxhp = _equip_get_maxhp(Target)
                    return math.floor(maxhp * 0.10)
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff422", { [3]=1288, [4]=1288 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffrwq, 422, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 422)
            end
        end
    end,
        [423] = function(play,zt,Damage,Target,MagicId) -- 若
-- 固定攻击力：+ 1288
-- IMG:res/tips/3.png#0#0&0
-- 攻击满血人物直接斩杀(10%)生命值
-- (60秒内只允许触发一次当前BUFF)
        if zt == 3 then
            if _equip_is_player(Target) and _equip_is_full_hp(Target) then
                if _equip_roll(play, 423, 5, 60) then
                    local maxhp = _equip_get_maxhp(Target)
                    return math.floor(maxhp * 0.10)
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff423", { [3]=1288, [4]=1288 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffrwq, 423, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 423)
            end
        end
    end,
        [424] = function(play,zt,Damage,Target,MagicId) -- 道
-- 固定攻击力：+ 1288
-- IMG:res/tips/3.png#0#0&0
-- 每十三刀会触发对(3*3)范围内的所
-- 有怪物造成(66万)的对怪切割！
        if zt == 3 then
            if _equip_is_mon(Target) then
                if _equip_hit_step(play, 424, 13, MagicId) then
                    local x = getbaseinfo(Target, ConstCfg.gbase.x)
                    local y = getbaseinfo(Target, ConstCfg.gbase.y)
                    rangeharm(play, x, y, 3, 660000, 0, 0, 0, 2, 0, 20)
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff424", { [3]=1288, [4]=1288 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgwq, 424, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 424)
            end
        end
    end,
        [425] = function(play,zt,Damage,Target,MagicId) -- ?
-- 固定攻击力：+ 1288
-- IMG:res/tips/3.png#0#0&0
-- 施放技能后下次攻击造成[2]倍伤害!
-- (60秒内只允许触发一次当前BUFF)
        if zt == 3 then
            if MagicId and MagicId > 0 then
                if _equip_roll(play, 425, 100, 60) then
                    _equip_set_next_flag(play, 425, true)
                end
                return 0
            end
            if _equip_has_next_flag(play, 425) then
                _equip_set_next_flag(play, 425, false)
                return Damage
            end
            return 0
        else
            _equip_set_attr(play, "装备buff425", { [3]=1288, [4]=1288 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgjq, 425, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 425)
                _equip_set_next_flag(play, 425, false)
            end
        end
    end,
        [426] = function(play,zt,Damage,Target,MagicId) -- 悲
-- 固定攻击力：+ 2888
-- 固定生命值：+ 28888
-- 固定魔法值：+ 28888
-- IMG:res/tips/3.png#0#0&0
-- 生命值低于(20%)时触发BUFF隐身1秒
-- 恢复自身(100%)生命值[CD：120秒]
        if zt == 3 then
            local maxhp = _equip_get_maxhp(play)
            local curhp = _equip_get_curhp(play)
            if maxhp > 0 and curhp * 100 <= maxhp * 20 then
                if _equip_roll(play, 426, 5, 120) then
                    humanhp(play, "+", maxhp)
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff426", { [3]=2888, [4]=2888, [1]=28888, [2]=28888 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffbgwq, 426, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffbrwq, 426, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 426)
            end
        end
    end,
    [427] = function(play,zt,Damage,Target,MagicId) -- 桃李满天下
-- 固定攻击力：+ 888
-- 固定生命值：+ 8888
-- 固定魔法值：+ 8888
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff427", { [3]=888, [4]=888, [1]=8888, [2]=8888 }, zt == 1)
        end
    end,
    [428] = function(play,zt,Damage,Target,MagicId) -- 狂风起苍穹
-- 固定攻击力：+ 888
-- 固定生命值：+ 8888
-- 固定魔法值：+ 8888
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff428", { [3]=888, [4]=888, [1]=8888, [2]=8888 }, zt == 1)
        end
    end,
    [429] = function(play,zt,Damage,Target,MagicId) -- 恶
-- 固定生命值：+ 12888
-- 固定魔法值：+ 12888
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff429", { [1]=12888, [2]=12888 }, zt == 1)
        end
    end,
        [430] = function(play,zt,Damage,Target,MagicId) -- 天
-- 固定生命值：+ 12888
-- 固定魔法值：+ 12888
-- IMG:res/tips/3.png#0#0&0
-- PK时有概率对目标造成禁锢(2秒钟)
        if zt == 3 then
            if _equip_is_player(Target) then
                if _equip_roll(play, 430, 5, 30) then
                    changemode(Target, ConstCfg.pmode.stick, 2)
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff430", { [1]=12888, [2]=12888 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffrwq, 430, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 430)
            end
        end
    end,
    [431] = function(play,zt,Damage,Target,MagicId) -- 月上影
        -- 复活状态不可用时概率获得一次原地重
        -- 生的机会！(300秒只触发一次BUFF)
        if zt == 3 then
            return 0
        else
-- 装备效果
        end
    end,
        [432] = function(play,zt,Damage,Target,MagicId) -- 月无痕
-- 固定攻击力：+ 1288
-- 固定生命值：+ 12888
-- 固定魔法值：+ 12888
-- 每秒恢复人物(等级*10)的生命值
-- IMG:res/tips/3.png#0#0&0
-- 每秒恢复[1%]的最大生命值
-- 每隔(60S)增加[10%]的最大攻击力
-- (效果持续20秒)
        if zt == 3 then
            _equip_clear_timed_attr(play, "N$equipbuff432_atk_end", "装备buff432_atk20")
            if _equip_roll(play, 432, 100, 60) then
                _equip_set_timed_attr(play, "N$equipbuff432_atk_end", "装备buff432_atk20", { [282]=10 }, 20)
            end
            return 0
        else
            local level = tonumber(getbaseinfo(play, ConstCfg.gbase.level) or 0) or 0
            local maxhp = _equip_get_maxhp(play)
            local regen = level * 10
            if maxhp > 0 then
                regen = regen + math.floor(maxhp * 0.01)
            end
            _equip_set_attr(play, "装备buff432", { [3]=1288, [4]=1288, [1]=12888, [2]=12888, [71]=regen }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgjq, 432, zt == 1)
            if zt == 2 then
                _equip_set_attr(play, "装备buff432_atk20", {}, false)
                setplaydef(play, "N$equipbuff432_atk_end", 0)
                _equip_clear_state(play, 432)
            end
        end
    end,
    [433] = function(play,zt,Damage,Target,MagicId) -- 月如歌
-- 固定攻击力：+ 1288
-- 打怪爆率：+ 30%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff433", { [3]=1288, [4]=1288, [242]=3000 }, zt == 1)
        end
    end,
    [434] = function(play,zt,Damage,Target,MagicId) -- 月中寒
-- 固定攻击力：+ 1288
-- 打怪爆率：+ 30%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff434", { [3]=1288, [4]=1288, [242]=3000 }, zt == 1)
        end
    end,
    [435] = function(play,zt,Damage,Target,MagicId) -- 锁九天
-- 固定攻击力：+ 1288
-- 打怪爆率：+ 30%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff435", { [3]=1288, [4]=1288, [242]=3000 }, zt == 1)
        end
    end,
        [436] = function(play,zt,Damage,Target,MagicId) -- 春不语
-- 固定攻击力：+ 2888
-- 固定生命值：+ 28888
-- 固定魔法值：+ 28888
-- IMG:res/tips/3.png#0#0&0
-- 攻击生命值低于(20%)的怪物时触发
-- 造成[2.0]倍对怪切割的伤害！
        if zt == 3 then
            if _equip_is_mon(Target) then
                local maxhp = _equip_get_maxhp(Target)
                local curhp = _equip_get_curhp(Target)
                if maxhp > 0 and curhp * 100 <= maxhp * 20 then
                    local cut = tonumber(getbaseinfo(play, 51, 244) or 0) or 0
                    if cut > 0 then
                        return cut * 2
                    end
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff436", { [3]=2888, [4]=2888, [1]=28888, [2]=28888 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgwq, 436, zt == 1)
        end
    end,
    [437] = function(play,zt,Damage,Target,MagicId) -- 叶知秋
-- 攻击倍数：+ 5%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff437", { [67]=5 }, zt == 1)
        end
    end,
    [438] = function(play,zt,Damage,Target,MagicId) -- 浅吟唱
        -- 施放技能时有概率触发双重施法效果
        -- 让技能额外在释放一次[CD60秒]
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff438", { [1]=12888, [2]=12888 }, zt == 1)
        end
    end,
    [439] = function(play,zt,Damage,Target,MagicId) -- 烟醉雨
-- 攻击力：+ 777
-- 生命值：+ 7777
-- 魔法值：+ 7777
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff439", { [3]=777, [4]=777, [1]=7777, [2]=7777 }, zt == 1)
        end
    end,
        [440] = function(play,zt,Damage,Target,MagicId) -- 洛情弃
-- 固定攻击力：+ 2888
-- 固定生命值：+ 28888
-- IMG:res/tips/3.png#0#0&0
-- 最大生命值：+ 10%
-- 穿戴时随机获得[1%-10%]的体力元素
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff440", { [3]=2888, [4]=2888, [1]=28888, [280]=10 }, zt == 1)
            if zt == 1 then
                _equip_add_random_stamina(play, "洛情弃", 1, 10)
            end
        end
    end,
        [441] = function(play,zt,Damage,Target,MagicId) -- 仙人跪
-- 固定攻击力：+ 1288
-- IMG:res/tips/3.png#0#0&0
-- 烈火剑法可斩杀目标[10%]的生命值
        if zt == 3 then
            if MagicId == 26 and Target then
                local maxhp = _equip_get_maxhp(Target)
                if maxhp > 0 then
                    return math.floor(maxhp * 0.10)
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff441", { [3]=1288, [4]=1288 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgjq, 441, zt == 1)
        end
    end,
    [442] = function(play,zt,Damage,Target,MagicId) -- 遮云日
        -- 战斗状态下可使用[回城石]无视限制
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff442", { [3]=1288, [4]=1288, [1]=12888, [2]=12888 }, zt == 1)
        end
    end,
    [443] = function(play,zt,Damage,Target,MagicId) -- 囚魍魉
-- 固定攻击力：+ 2888
-- 固定生命值：+ 28888
-- 固定魔法值：+ 28888
-- IMG:res/tips/3.png#0#0&0
-- 最大攻击力：+ 3%
-- 最大生命值：+ 5%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff443", { [3]=2891, [4]=2891, [1]=28893, [2]=28888 }, zt == 1)
        end
    end,
    [444] = function(play,zt,Damage,Target,MagicId) -- 深渊低语
-- 打怪爆率：+ 25%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff444", { [242]=2500 }, zt == 1)
        end
    end,
    [445] = function(play,zt,Damage,Target,MagicId) -- 血月残魂
-- 打怪爆率：+ 25%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff445", { [242]=2500 }, zt == 1)
        end
    end,
    [446] = function(play,zt,Damage,Target,MagicId) -- 亡者契约
-- 固定攻击力：+ 888
-- 固定生命值：+ 8888
-- 固定魔法值：+ 8888
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff446", { [3]=888, [4]=888, [1]=8888, [2]=8888 }, zt == 1)
        end
    end,
    [447] = function(play,zt,Damage,Target,MagicId) -- 混沌之种
-- 固定攻击力：+ 888
-- 固定生命值：+ 8888
-- 固定魔法值：+ 8888
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff447", { [3]=888, [4]=888, [1]=8888, [2]=8888 }, zt == 1)
        end
    end,
        [448] = function(play,zt,Damage,Target,MagicId) -- 暗影囚笼
-- 固定攻击力：+ 2488
-- IMG:res/tips/3.png#0#0&0
-- 攻击时有概率切割怪物[1%-3%]的最
-- 大生命值！(对极少数BOSS不生效)
        if zt == 3 then
            if _equip_is_mon(Target) then
                if _equip_roll(play, 448, 5, 30) then
                    local maxhp = _equip_get_maxhp(Target)
                    if maxhp > 0 then
                        local pct = math.random(1, 3)
                        return math.floor(maxhp * pct / 100)
                    end
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff448", { [3]=2488, [4]=2488 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgwq, 448, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 448)
            end
        end
    end,
        [449] = function(play,zt,Damage,Target,MagicId) -- 噬魂之镰影
-- 固定生命值：+ 24888
-- 固定魔法值：+ 24888
-- IMG:res/tips/3.png#0#0&0
-- 人物生命值低于(15%)的时候会瞬间
-- 恢复人物[55%]最大生命值(CD120S)
        if zt == 3 then
            local maxhp = _equip_get_maxhp(play)
            local curhp = _equip_get_curhp(play)
            if maxhp > 0 and curhp * 100 <= maxhp * 15 then
                if _equip_roll(play, 449, 5, 120) then
                    humanhp(play, "+", math.floor(maxhp * 0.55))
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff449", { [1]=24888, [2]=24888 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffbgwq, 449, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffbrwq, 449, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 449)
            end
        end
    end,
    [450] = function(play,zt,Damage,Target,MagicId) -- 霸天震九州
-- 固定属性/未配置说明
        if zt == 3 then
            return 0
        else
-- 装备效果
        end
    end,
    [451] = function(play,zt,Damage,Target,MagicId) -- 永夜诅咒
        -- 攻击时有概率卸下目标[1件]装备返
        -- 回到背包里面！
        if zt == 3 then
            return 0
        else
-- 装备效果
        end
    end,
    [452] = function(play,zt,Damage,Target,MagicId) -- 狂风之力
-- 打怪爆率：+ 25%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff452", { [242]=2500 }, zt == 1)
        end
    end,
    [453] = function(play,zt,Damage,Target,MagicId) -- 虚空回响
        -- 人物复活后必定获得[100%暴击几率]
        -- (暴击几率的BUFF持续时间为5秒)
        if zt == 3 then
            return 0
        else
-- 装备效果
        end
    end,
    [454] = function(play,zt,Damage,Target,MagicId) -- 堕落圣歌
-- 固定攻击力：+ 3888
-- 固定生命值：+ 38888
-- 固定魔法值：+ 38888
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff454", { [3]=3888, [4]=3888, [1]=38888, [2]=38888 }, zt == 1)
        end
    end,
    [455] = function(play,zt,Damage,Target,MagicId) -- 焚天令
-- PK时伤害：+ 10%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff455", { [76]=10 }, zt == 1)
        end
    end,
    [456] = function(play,zt,Damage,Target,MagicId) -- 逆命玉
-- PK时伤害：+ 10%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff456", { [76]=10 }, zt == 1)
        end
    end,
    [457] = function(play,zt,Damage,Target,MagicId) -- 诛仙箓
        -- 施放技能时有概率触发双重施法效果
        -- 让技能额外在释放一次[CD60秒]
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff457", { [3]=2488, [4]=2488 }, zt == 1)
        end
    end,
    [458] = function(play,zt,Damage,Target,MagicId) -- 万法归宗卷
-- 固定攻击力：+ 2488
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff458", { [3]=2488, [4]=2488 }, zt == 1)
        end
    end,
    [459] = function(play,zt,Damage,Target,MagicId) -- 九霄龙吟印
-- 固定生命值：+ 24888
-- 固定魔法值：+ 24888
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff459", { [1]=24888, [2]=24888 }, zt == 1)
        end
    end,
    [460] = function(play,zt,Damage,Target,MagicId) -- 飞龙在天
-- 固定攻击力：+ 555
-- 固定生命值：+ 5555
-- 固定魔法值：+ 5555
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff460", { [3]=555, [4]=555, [1]=5555, [2]=5555 }, zt == 1)
        end
    end,
    [461] = function(play,zt,Damage,Target,MagicId) -- 霸者傲天下
-- 固定攻击力：+ 555
-- 固定生命值：+ 5555
-- 固定魔法值：+ 5555
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff461", { [3]=555, [4]=555, [1]=5555, [2]=5555 }, zt == 1)
        end
    end,
        [462] = function(play,zt,Damage,Target,MagicId) -- 铁血战歌
-- 固定攻击力：+ 3888
-- 固定生命值：+ 38888
-- 固定魔法值：+ 38888
-- IMG:res/tips/3.png#0#0&0
-- 伤害吸收：+ 10%
-- 穿戴时随机获得[1%-15%]的体力元素
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff462", { [3]=3888, [4]=3888, [1]=38888, [2]=38888, [206]=10 }, zt == 1)
            if zt == 1 then
                _equip_add_random_stamina(play, "铁血战歌", 1, 15)
            end
        end
    end,
    [463] = function(play,zt,Damage,Target,MagicId) -- 焚天战旗
        -- 人物脱战后每秒恢复[1%]最大生命
        -- 搭配[无尽征伐]可组合套装
        if zt == 3 then
            return 0
        else
-- 装备效果
        end
    end,
    [464] = function(play,zt,Damage,Target,MagicId) -- 无尽征伐
        -- 人物脱战后每秒恢复[1%]最大生命
        -- 搭配[焚天战旗]可组合套装
        if zt == 3 then
            return 0
        else
-- 装备效果
        end
    end,
    [465] = function(play,zt,Damage,Target,MagicId) -- 天罚之威
        -- 暴击时概率切割目标(3%)最大生命值
        -- (30秒内只允许触发一次当前BUFF)
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff465", { [1]=24888, [2]=24888 }, zt == 1)
        end
    end,
    [466] = function(play,zt,Damage,Target,MagicId) -- 诸神黄昏令
-- 固定攻击力：+ 2488
-- IMG:res/tips/3.png#0#0&0
-- 攻击倍数：+ 5%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff466", { [3]=2488, [4]=2488, [67]=5 }, zt == 1)
        end
    end,
    [467] = function(play,zt,Damage,Target,MagicId) -- 死亡彗星
-- 固定属性/未配置说明
        if zt == 3 then
            return 0
        else
-- 装备效果
        end
    end,
        [468] = function(play,zt,Damage,Target,MagicId) -- 太虚真意
-- 固定攻击力：+ 2488
-- 固定生命值：+ 24888
-- 固定魔法值：+ 24888
-- 每秒恢复人物(等级*10)的生命值
-- IMG:res/tips/3.png#0#0&0
-- 穿戴后激活人物[全身黑化]的状态
-- 黑化状态下增加(5%)的最大攻击力
        if zt == 3 then
            return 0
        else
            local level = tonumber(getbaseinfo(play, ConstCfg.gbase.level) or 0) or 0
            _equip_set_attr(play, "装备buff468", { [3]=2488, [4]=2488, [1]=24888, [2]=24888, [71]=level*10, [282]=5 }, zt == 1)
        end
    end,
        [469] = function(play,zt,Damage,Target,MagicId) -- 傲骨豪
-- 固定攻击力：+ 3888
-- 固定生命值：+ 38888
-- 固定魔法值：+ 38888
-- IMG:res/tips/3.png#0#0&0
-- 攻击满血人物直接斩杀(30%)生命值
-- (60秒内只允许触发一次当前BUFF)
        if zt == 3 then
            if _equip_is_player(Target) and _equip_is_full_hp(Target) then
                if _equip_roll(play, 469, 5, 60) then
                    local maxhp = _equip_get_maxhp(Target)
                    return math.floor(maxhp * 0.30)
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff469", { [3]=3888, [4]=3888, [1]=38888, [2]=38888 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffrwq, 469, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 469)
            end
        end
    end,
        [470] = function(play,zt,Damage,Target,MagicId) -- 灵犀一点
-- 固定攻击力：+ 3888
-- 固定生命值：+ 38888
-- 固定魔法值：+ 38888
-- IMG:res/tips/3.png#0#0&0
-- 攻击满血人物直接斩杀(30%)生命值
-- (60秒内只允许触发一次当前BUFF)
        if zt == 3 then
            if _equip_is_player(Target) and _equip_is_full_hp(Target) then
                if _equip_roll(play, 470, 5, 60) then
                    local maxhp = _equip_get_maxhp(Target)
                    return math.floor(maxhp * 0.30)
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff470", { [3]=3888, [4]=3888, [1]=38888, [2]=38888 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffrwq, 470, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 470)
            end
        end
    end,
        [471] = function(play,zt,Damage,Target,MagicId) -- 碎穹裂宇
-- 固定攻击力：+ 3888
-- 固定生命值：+ 38888
-- 固定魔法值：+ 38888
-- IMG:res/tips/3.png#0#0&0
-- 攻击满血人物直接斩杀(30%)生命值
-- (60秒内只允许触发一次当前BUFF)
        if zt == 3 then
            if _equip_is_player(Target) and _equip_is_full_hp(Target) then
                if _equip_roll(play, 471, 5, 60) then
                    local maxhp = _equip_get_maxhp(Target)
                    return math.floor(maxhp * 0.30)
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff471", { [3]=3888, [4]=3888, [1]=38888, [2]=38888 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffrwq, 471, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 471)
            end
        end
    end,
    [472] = function(play,zt,Damage,Target,MagicId) -- 万劫归墟
-- 攻击倍数：+ 5%
-- 最大生命值：+ 10%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff472", { [1]=10, [67]=5 }, zt == 1)
        end
    end,
        [473] = function(play,zt,Damage,Target,MagicId) -- 弑道焚心
-- 攻击时刀刀切割怪物[1%]的生命值
-- (切割效果对极少数BOSS无法生效)
        if zt == 3 then
            if _equip_is_mon(Target) then
                local maxhp = _equip_get_maxhp(Target)
                if maxhp > 0 then
                    return math.floor(maxhp * 0.01)
                end
            end
            return 0
        else
            _toggle_buff_var(play, VarCfg.S_buffgwq, 473, zt == 1)
        end
    end,
    [474] = function(play,zt,Damage,Target,MagicId) -- 破界诛邪
        -- 攻击人物时有概率使目标诅咒[5秒]
        -- 命中被诅咒的目标每秒额外掉血[1%]
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff474", { [1]=24888, [2]=24888 }, zt == 1)
        end
    end,
    [475] = function(play,zt,Damage,Target,MagicId) -- 镇狱封魔
        -- 施放烈火时有概率触发双重施法效果
        -- 让技能额外在释放一次[CD60秒]
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff475", { [3]=2488, [4]=2488 }, zt == 1)
        end
    end,
    [476] = function(play,zt,Damage,Target,MagicId) -- 灭道焚天
-- 固定攻击力：+ 2488
-- 固定生命值：+ 24888
-- 固定魔法值：+ 24888
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff476", { [3]=2488, [4]=2488, [1]=24888, [2]=24888 }, zt == 1)
        end
    end,
        [477] = function(play,zt,Damage,Target,MagicId) -- 破天魂
-- 人物死亡后记录[击杀者]的游戏名称
-- 下次与目标PK时增加[20%]的伤害值
-- 搭配[地狱火]可组合套装
        if zt == 3 then
            if _equip_has_flag(play, "N$equipset_potian") and _equip_is_player(Target) then
                local name = tostring(getplaydef(play, "N$equipbuff477_target") or "")
                if name ~= "" and name == tostring(getbaseinfo(Target, ConstCfg.gbase.name) or "") then
                    setplaydef(play, "N$equipbuff477_target", "")
                    return math.floor(Damage * 0.20)
                end
            end
            return 0
        else
            local has = _equip_has_name(play, "破天魂") and _equip_has_name(play, "地狱火")
            _equip_set_flag(play, "N$equipset_potian", has)
            _toggle_buff_var(play, VarCfg.S_buffrwq, 477, zt == 1)
        end
    end,
        [478] = function(play,zt,Damage,Target,MagicId) -- 地狱火
-- 人物死亡后记录[击杀者]的游戏名称
-- 下次与目标PK时增加[20%]的伤害值
-- 搭配[破天魂]可组合套装
        if zt == 3 then
            if _equip_has_flag(play, "N$equipset_potian") and _equip_is_player(Target) then
                local name = tostring(getplaydef(play, "N$equipbuff477_target") or "")
                if name ~= "" and name == tostring(getbaseinfo(Target, ConstCfg.gbase.name) or "") then
                    setplaydef(play, "N$equipbuff477_target", "")
                    return math.floor(Damage * 0.20)
                end
            end
            return 0
        else
            local has = _equip_has_name(play, "破天魂") and _equip_has_name(play, "地狱火")
            _equip_set_flag(play, "N$equipset_potian", has)
            _toggle_buff_var(play, VarCfg.S_buffrwq, 478, zt == 1)
        end
    end,
        [479] = function(play,zt,Damage,Target,MagicId) -- 三生石影
-- 生命值低于[30%]时触发无敌状态1秒
-- 并且恢复人物(100%)的最大生命值！
-- [CD150秒]
        if zt == 3 then
            local maxhp = _equip_get_maxhp(play)
            local curhp = _equip_get_curhp(play)
            if maxhp > 0 and curhp * 100 <= maxhp * 30 then
                if _equip_roll(play, 479, 5, 150) then
                    humanhp(play, "+", maxhp)
                end
            end
            return 0
        else
            _toggle_buff_var(play, VarCfg.S_buffbgwq, 479, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffbrwq, 479, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 479)
            end
        end
    end,
    [480] = function(play,zt,Damage,Target,MagicId) -- 忘川渡魂
        -- 每秒恢复人物(等级*10)的生命值
        -- 复活在不可用的情况下有(3%)的概率
        -- 斩杀目标人物[99%]的最大生命值！
        -- [CD300秒]
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff480", { [3]=3888, [4]=3888, [1]=38888, [2]=38888 }, zt == 1)
        end
    end,
        [481] = function(play,zt,Damage,Target,MagicId) -- 渡厄仙符
-- 固定攻击力：+ 2488
-- 固定生命值：+ 24888
-- 固定魔法值：+ 24888
-- IMG:res/tips/3.png#0#0&0
-- 攻击时有概率强制麻痹目标[1]秒
        if zt == 3 then
            if Target then
                if _equip_roll(play, 481, 5, 30) then
                    changemode(Target, ConstCfg.pmode.stick, 1)
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff481", { [3]=2488, [4]=2488, [1]=24888, [2]=24888 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgjq, 481, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 481)
            end
        end
    end,
    [482] = function(play,zt,Damage,Target,MagicId) -- 因果天锁
        -- 杀怪触发鞭尸后有[2%]概率触发连爆
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff482", { [3]=2488, [4]=2488, [1]=24888 }, zt == 1)
        end
    end,
    [483] = function(play,zt,Damage,Target,MagicId) -- 命数天盘
        -- 被击杀时有[20%]的概率不掉狂暴
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff483", { [3]=2488, [4]=2488, [1]=24888, [2]=24888 }, zt == 1)
        end
    end,
        [484] = function(play,zt,Damage,Target,MagicId) -- 尘缘劫火
-- 固定攻击力：+ 2488
-- IMG:res/tips/3.png#0#0&0
-- 人物复活后触发隐身[2秒]下次攻击
-- 必定造成[3.0]倍伤害[CD:30秒]
        if zt == 3 then
            if _equip_has_next_flag(play, 484) then
                _equip_set_next_flag(play, 484, false)
                return math.floor(Damage * 2)
            end
            return 0
        elseif zt == 4 then
            if _equip_roll(play, 484, 100, 30) then
                _equip_set_next_flag(play, 484, true)
            end
        else
            _equip_set_attr(play, "装备buff484", { [3]=2488, [4]=2488 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgjq, 484, zt == 1)
            _toggle_buff_var(play, VarCfg.S_bufffuhuo, 484, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 484)
                _equip_set_next_flag(play, 484, false)
            end
        end
    end,
        [485] = function(play,zt,Damage,Target,MagicId) -- 渡世莲华
-- 攻击时触发刀刀斩杀人物[3%]生命值
        if zt == 3 then
            if _equip_is_player(Target) then
                local maxhp = _equip_get_maxhp(Target)
                if maxhp > 0 then
                    return math.floor(maxhp * 0.03)
                end
            end
            return 0
        else
            _toggle_buff_var(play, VarCfg.S_buffrwq, 485, zt == 1)
        end
    end,
    [486] = function(play,zt,Damage,Target,MagicId) -- 鸿蒙初判
        -- 等级上限：+ 3
        if zt == 3 then
            return 0
        else
-- 装备效果
        end
    end,
    [487] = function(play,zt,Damage,Target,MagicId) -- 混沌道胎
-- 固定攻击力：+ 1288
-- 固定生命值：+ 12888
-- 固定魔法值：+ 12888
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff487", { [3]=1288, [4]=1288, [1]=12888, [2]=12888 }, zt == 1)
        end
    end,
    [488] = function(play,zt,Damage,Target,MagicId) -- 轩辕镇世符
-- 固定攻击力：+ 1288
-- IMG:res/tips/3.png#0#0&0
-- 攻击倍数：+ 5%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff488", { [3]=1288, [4]=1288, [67]=5 }, zt == 1)
        end
    end,
        [489] = function(play,zt,Damage,Target,MagicId) -- 东皇钟魂
-- 攻击时有概率连续造成[8]连击，每
-- 次连击时造成最大伤害值的(70%)！
-- (30秒内只允许触发一次当前BUFF)
        if zt == 3 then
            if _equip_roll(play, 489, 5, 30) then
                return math.floor(Damage * 0.70 * 8)
            end
            return 0
        else
            _toggle_buff_var(play, VarCfg.S_buffgjq, 489, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 489)
            end
        end
    end,
    [490] = function(play,zt,Damage,Target,MagicId) -- 熱翔
-- 装备回收：+ 30%
-- 经验倍数：+ 50%
-- 打怪爆率：+ 50%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff490", { [242]=5000, [204]=30, [66]=50 }, zt == 1)
        end
    end,
    [491] = function(play,zt,Damage,Target,MagicId) -- 致命节奏
-- 固定属性/未配置说明
        if zt == 3 then
            return 0
        else
-- 装备效果
        end
    end,
    [492] = function(play,zt,Damage,Target,MagicId) -- 玄武震天尊
-- 固定属性/未配置说明
        if zt == 3 then
            return 0
        else
-- 装备效果
        end
    end,
    [493] = function(play,zt,Damage,Target,MagicId) -- 月下听松
        -- 人物永久进入[杀人不红名]状态
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff493", { [3]=4888, [4]=4888, [1]=48888, [2]=48888 }, zt == 1)
        end
    end,
    [494] = function(play,zt,Damage,Target,MagicId) -- 风吟鹤唳
-- 固定攻击力：+ 4888
-- 固定生命值：+ 48888
-- 固定魔法值：+ 48888
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff494", { [3]=4888, [4]=4888, [1]=48888, [2]=48888 }, zt == 1)
        end
    end,
    [495] = function(play,zt,Damage,Target,MagicId) -- 空山灵雨
        -- 每层噬魂之力：附加20点攻击力
        -- 每层噬魂之力：附加200点生命值
        -- 击杀怪物有概率增加(1层)噬魂之力
        -- 击杀狂暴玩家可增加(3层)噬魂之力
        -- 击杀狂暴玩家可增加[1%]攻击倍数
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff495", { [3]=4888, [4]=4888, [1]=48888, [2]=48888 }, zt == 1)
        end
    end,
        [496] = function(play,zt,Damage,Target,MagicId) -- 流霞醉客
-- 固定攻击力：+ 3688
-- IMG:res/tips/3.png#0#0&0
-- 攻击怪物时附带[15555]点对怪切割
        if zt == 3 then
            if _equip_is_mon(Target) then
                return 15555
            end
            return 0
        else
            _equip_set_attr(play, "装备buff496", { [3]=3688, [4]=3688 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgwq, 496, zt == 1)
        end
    end,
    [497] = function(play,zt,Damage,Target,MagicId) -- 星垂平野
-- 固定生命值：+ 36888
-- 固定魔法值：+ 36888
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff497", { [1]=36888, [2]=36888 }, zt == 1)
        end
    end,
        [498] = function(play,zt,Damage,Target,MagicId) -- 月落乌啼
-- 固定攻击力：+ 3688
-- IMG:res/tips/3.png#0#0&0
-- 攻击时有概率切割怪物[1%-3%]的最
-- 大生命值！
        if zt == 3 then
            if _equip_is_mon(Target) then
                if _equip_roll(play, 498, 5, 30) then
                    local maxhp = _equip_get_maxhp(Target)
                    if maxhp > 0 then
                        local pct = math.random(1, 3)
                        return math.floor(maxhp * pct / 100)
                    end
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff498", { [3]=3688, [4]=3688 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgwq, 498, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 498)
            end
        end
    end,
        [499] = function(play,zt,Damage,Target,MagicId) -- 一苇渡江
-- 固定攻击力：+ 4888
-- 固定生命值：+ 48888
-- 固定魔法值：+ 48888
-- IMG:res/tips/3.png#0#0&0
-- 攻击有概率打掉目标[66%]的生命值
-- 恢复自身[66%]的生命值(仅PK触发)
        if zt == 3 then
            if _equip_is_player(Target) then
                if _equip_roll(play, 499, 5, 30) then
                    local maxhp = _equip_get_maxhp(Target)
                    if maxhp > 0 then
                        local dmg = math.floor(maxhp * 0.66)
                        humanhp(play, "+", dmg)
                        return dmg
                    end
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff499", { [3]=4888, [4]=4888, [1]=48888, [2]=48888 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffrwq, 499, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 499)
            end
        end
    end,
        [500] = function(play,zt,Damage,Target,MagicId) -- 浮生若梦
-- 固定生命值：+ 36888
-- 固定魔法值：+ 36888
-- IMG:res/tips/3.png#0#0&0
-- 每八刀对目标造成[2.0倍]对怪切割
        if zt == 3 then
            if _equip_is_mon(Target) then
                if _equip_hit_step(play, 500, 8, MagicId) then
                    local cut = tonumber(getbaseinfo(play, 51, 244) or 0) or 0
                    if cut > 0 then
                        return cut * 2
                    end
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff500", { [1]=36888, [2]=36888 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgwq, 500, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 500)
            end
        end
    end,
    [501] = function(play,zt,Damage,Target,MagicId) -- 血煞魔心
-- 固定攻击力：+ 3688
-- IMG:res/tips/3.png#0#0&0
-- 攻击倍数：+ 5%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff501", { [3]=3688, [4]=3688, [67]=5 }, zt == 1)
        end
    end,
        [502] = function(play,zt,Damage,Target,MagicId) -- 万魔归宗
-- 固定攻击力：+ 4888
-- 固定生命值：+ 48888
-- 固定魔法值：+ 48888
-- IMG:res/tips/3.png#0#0&0
-- 当人物生命值低于[20%]时触发冰冻
-- 自身[2*2范围]内的目标1S(CD60秒)
        if zt == 3 then
            local maxhp = _equip_get_maxhp(play)
            local curhp = _equip_get_curhp(play)
            if maxhp > 0 and curhp * 100 <= maxhp * 20 then
                if _equip_roll(play, 502, 5, 60) then
                    if Target then
                        changemode(Target, ConstCfg.pmode.frost, 1)
                    end
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff502", { [3]=4888, [4]=4888, [1]=48888, [2]=48888 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffbgwq, 502, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffbrwq, 502, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 502)
            end
        end
    end,
        [503] = function(play,zt,Damage,Target,MagicId) -- 幽狱炼魂
-- 固定攻击力：+ 3688
-- IMG:res/tips/3.png#0#0&0
-- 攻击时有概率直接打掉5大陆内的
-- 怪物(5%)最大生命值！
        if zt == 3 then
            if _equip_is_mon(Target) and _equip_is_dalu(play, 5) then
                if _equip_roll(play, 503, 5, 30) then
                    local maxhp = _equip_get_maxhp(Target)
                    if maxhp > 0 then
                        return math.floor(maxhp * 0.05)
                    end
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff503", { [3]=3688, [4]=3688 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgwq, 503, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 503)
            end
        end
    end,
        [504] = function(play,zt,Damage,Target,MagicId) -- 蚀道魔印
-- 固定生命值：+ 36888
-- 固定魔法值：+ 36888
-- IMG:res/tips/3.png#0#0&0
-- 施放技能后下次攻击造成[2]倍伤害!
-- (30秒内只允许触发一次当前BUFF)
        if zt == 3 then
            if MagicId and MagicId > 0 then
                if _equip_roll(play, 504, 100, 30) then
                    _equip_set_next_flag(play, 504, true)
                end
                return 0
            end
            if _equip_has_next_flag(play, 504) then
                _equip_set_next_flag(play, 504, false)
                return Damage
            end
            return 0
        else
            _equip_set_attr(play, "装备buff504", { [1]=36888, [2]=36888 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgjq, 504, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 504)
                _equip_set_next_flag(play, 504, false)
            end
        end
    end,
    [505] = function(play,zt,Damage,Target,MagicId) -- 血河浮屠
-- 固定攻击力：+ 3688
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff505", { [3]=3688, [4]=3688 }, zt == 1)
        end
    end,
    [506] = function(play,zt,Damage,Target,MagicId) -- 噬魂夺魄
-- 攻击倍数：+ 10%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff506", { [67]=10 }, zt == 1)
        end
    end,
    [507] = function(play,zt,Damage,Target,MagicId) -- 九幽魔音
        -- 每秒恢复人物(等级*10)的生命值
        -- 人物永久进入[杀人不红名]状态
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff507", { [3]=3688, [4]=3688, [1]=36888, [2]=36888, [76]=10 }, zt == 1)
        end
    end,
        [508] = function(play,zt,Damage,Target,MagicId) -- 焚霄
-- 被攻击时有概率反弹(50%)的伤害
-- 并恢复自身[50%]的生命值(CD120秒)
        if zt == 3 then
            if _equip_roll(play, 508, 50, 120) then
                local maxhp = _equip_get_maxhp(play)
                if maxhp > 0 then
                    humanhp(play, "+", math.floor(maxhp * 0.50))
                end
                if Target and Damage and Damage > 0 then
                    humanhp(Target, "-", math.floor(Damage * 0.50), 110, 0, play, 1)
                end
            end
            return 0
        else
            _toggle_buff_var(play, VarCfg.S_buffbgjq, 508, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 508)
            end
        end
    end,
    [509] = function(play,zt,Damage,Target,MagicId) -- 镇渊
        -- 人物触发复活后每秒恢复人物[10%]
        -- 的最大生命值，效果持续(5秒)
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff509", { [1]=36888, [2]=36888 }, zt == 1)
        end
    end,
    [510] = function(play,zt,Damage,Target,MagicId) -- 逆命
        -- 攻击有概率忽视[100%]的防御力
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff510", { [3]=3688, [4]=3688 }, zt == 1)
        end
    end,
    [511] = function(play,zt,Damage,Target,MagicId) -- 斩仙令
-- 固定攻击力：+ 3688
-- IMG:res/tips/3.png#0#0&0
-- 防止暴击概率：+ 10%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff511", { [3]=3688, [4]=3688, [23]=10 }, zt == 1)
        end
    end,
        [512] = function(play,zt,Damage,Target,MagicId) -- 焚天印
-- 固定攻击力：+ 3688
-- 固定生命值：+ 36888
-- 固定魔法值：+ 36888
-- 每秒恢复人物(等级*10)的生命值
        if zt == 3 then
            return 0
        else
            local level = tonumber(getbaseinfo(play, ConstCfg.gbase.level) or 0) or 0
            _equip_set_attr(play, "装备buff512", { [3]=3688, [4]=3688, [1]=36888, [2]=36888, [71]=level*10 }, zt == 1)
        end
    end,
    [513] = function(play,zt,Damage,Target,MagicId) -- 渡魂舟
-- 固定生命值：+ 36888
-- 固定魔法值：+ 36888
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff513", { [1]=36888, [2]=36888 }, zt == 1)
        end
    end,
    [514] = function(play,zt,Damage,Target,MagicId) -- 碎星刃
        -- 穿戴后体型增大且增加(大量生命值)
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff514", { [3]=4888, [4]=4888, [1]=48888, [2]=48888 }, zt == 1)
        end
    end,
        [515] = function(play,zt,Damage,Target,MagicId) -- 九霄龙吟
-- 固定攻击力：+ 4888
-- 固定生命值：+ 48888
-- 固定魔法值：+ 48888
-- IMG:res/tips/3.png#0#0&0
-- 攻击时有概率恢复[100%]最大生命值 CD500
        if zt == 3 then
            if _equip_roll(play, 515, 5, 500) then
                local maxhp = _equip_get_maxhp(play)
                if maxhp > 0 then
                    humanhp(play, "+", maxhp)
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff515", { [3]=4888, [4]=4888, [1]=48888, [2]=48888 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgjq, 515, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 515)
            end
        end
    end,
    [516] = function(play,zt,Damage,Target,MagicId) -- 万法归宗
        -- PK时有概率将目标的武器打入背包
        -- (30秒内只允许触发一次当前BUFF)
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff516", { [3]=3688, [4]=3688, [1]=36888, [2]=36888 }, zt == 1)
        end
    end,
        [517] = function(play,zt,Damage,Target,MagicId) -- 天罚
-- 固定生命值：+ 36888
-- 固定魔法值：+ 36888
-- IMG:res/tips/3.png#0#0&0
-- 烈火剑法可斩杀目标[10%]的生命值
        if zt == 3 then
            if MagicId == 26 and Target then
                local maxhp = _equip_get_maxhp(Target)
                if maxhp > 0 then
                    return math.floor(maxhp * 0.10)
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff517", { [1]=36888, [2]=36888 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgjq, 517, zt == 1)
        end
    end,
        [518] = function(play,zt,Damage,Target,MagicId) -- 神寂
-- 攻击满血人物时有(30%)的概率斩杀
-- 掉目标[50%]的最大生命值!并且额外
-- 触发缴械目标人物的武器(3)秒钟！
-- (当处于缴械期间无法佩戴任何武器)
        if zt == 3 then
            if _equip_is_player(Target) and _equip_is_full_hp(Target) then
                if _equip_roll(play, 518, 30, 30) then
                    local maxhp = _equip_get_maxhp(Target)
                    return math.floor(maxhp * 0.50)
                end
            end
            return 0
        else
            _toggle_buff_var(play, VarCfg.S_buffrwq, 518, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 518)
            end
        end
    end,
    [519] = function(play,zt,Damage,Target,MagicId) -- 劫烬
-- 固定属性/未配置说明
        if zt == 3 then
            return 0
        else
-- 装备效果
        end
    end,
        [520] = function(play,zt,Damage,Target,MagicId) -- 道陨
-- 当人物死亡时会对3*3范围内的全部
-- 目标造成攻击力[333%]的伤害!
        if zt == 3 then
            return 0
        else
            _equip_set_flag(play, "N$equipbuff520on", zt == 1)
        end
    end,
    [521] = function(play,zt,Damage,Target,MagicId) -- 无情铁御
-- 固定生命值：+ 12888
-- 固定魔法值：+ 12888
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff521", { [1]=12888, [2]=12888 }, zt == 1)
        end
    end,
    [522] = function(play,zt,Damage,Target,MagicId) -- 褪色者
-- 固定生命值：+ 12888
-- 固定魔法值：+ 12888
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff522", { [1]=12888, [2]=12888 }, zt == 1)
        end
    end,
    [523] = function(play,zt,Damage,Target,MagicId) -- 七日杀
-- 固定生命值：+ 12888
-- 固定魔法值：+ 12888
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff523", { [1]=12888, [2]=12888 }, zt == 1)
        end
    end,
    [524] = function(play,zt,Damage,Target,MagicId) -- 长生
-- 固定攻击力：+ 1288
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff524", { [3]=1288, [4]=1288 }, zt == 1)
        end
    end,
    [525] = function(play,zt,Damage,Target,MagicId) -- 特殊 T 套效果
-- 打怪爆率：+ 20%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff525", { [242]=2000 }, zt == 1)
        end
    end,
    [526] = function(play,zt,Damage,Target,MagicId) -- 伏魔御厨子
-- 打怪爆率：+ 20%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff526", { [242]=2000 }, zt == 1)
        end
    end,
    [527] = function(play,zt,Damage,Target,MagicId) -- 嵌合暗翳庭
-- 打怪爆率：+ 20%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff527", { [242]=2000 }, zt == 1)
        end
    end,
    [528] = function(play,zt,Damage,Target,MagicId) -- 裂穹
-- 打怪爆率：+ 20%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff528", { [242]=2000 }, zt == 1)
        end
    end,
    [529] = function(play,zt,Damage,Target,MagicId) -- 弑道
-- 打怪爆率：+ 20%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff529", { [242]=2000 }, zt == 1)
        end
    end,
    [530] = function(play,zt,Damage,Target,MagicId) -- 封魔
-- 对怪切割：+ 9999
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff530", { [244]=9999 }, zt == 1)
        end
    end,
    [531] = function(play,zt,Damage,Target,MagicId) -- 碎星
-- 对怪切割：+ 9999
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff531", { [244]=9999 }, zt == 1)
        end
    end,
    [532] = function(play,zt,Damage,Target,MagicId) -- 玄元道印
-- 对怪伤害：+ 10%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff532", { [245]=1000 }, zt == 1)
        end
    end,
    [533] = function(play,zt,Damage,Target,MagicId) -- 诸神黄昏
-- 对怪伤害：+ 10%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff533", { [245]=1000 }, zt == 1)
        end
    end,
        [534] = function(play,zt,Damage,Target,MagicId) -- 青冥道果
-- 人物每秒恢复[1%]的最大生命值
        if zt == 3 then
            return 0
        else
            local maxhp = _equip_get_maxhp(play)
            local regen = 0
            if maxhp > 0 then
                regen = math.floor(maxhp * 0.01)
            end
            _equip_set_attr(play, "装备buff534", { [71]=regen }, zt == 1)
        end
    end,
        [535] = function(play,zt,Damage,Target,MagicId) -- 噬仙印
-- 人物每秒恢复[1%]的最大生命值
        if zt == 3 then
            return 0
        else
            local maxhp = _equip_get_maxhp(play)
            local regen = 0
            if maxhp > 0 then
                regen = math.floor(maxhp * 0.01)
            end
            _equip_set_attr(play, "装备buff535", { [71]=regen }, zt == 1)
        end
    end,
        [536] = function(play,zt,Damage,Target,MagicId) -- 圣光誓约
-- 固定攻击力：+ 4588
-- IMG:res/tips/3.png#0#0&0
-- 施放烈火剑法概率冰冻目标[1-3]秒
        if zt == 3 then
            if MagicId == 26 and Target then
                if _equip_roll(play, 536, 5, 30) then
                    changemode(Target, ConstCfg.pmode.frost, math.random(1, 3))
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff536", { [3]=4588, [4]=4588 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgjq, 536, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 536)
            end
        end
    end,
        [537] = function(play,zt,Damage,Target,MagicId) -- 天恩圣符
-- 固定攻击力：+ 4588
-- IMG:res/tips/3.png#0#0&0
-- 攻击时有概率触发[死亡一指]直接斩
-- 杀目标[100%]的最大生命值！ cd 600 不能对高等级玩家生效
        if zt == 3 then
            if Target then
                if _equip_is_player(Target) then
                    local mylv = tonumber(getbaseinfo(play, ConstCfg.gbase.level) or 0) or 0
                    local tlv = tonumber(getbaseinfo(Target, ConstCfg.gbase.level) or 0) or 0
                    if tlv >= mylv then
                        return 0
                    end
                end
                if _equip_roll(play, 537, 5, 600) then
                    local maxhp = _equip_get_maxhp(Target)
                    if maxhp > 0 then
                        return maxhp
                    end
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff537", { [3]=4588, [4]=4588 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgjq, 537, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 537)
            end
        end
    end,
        [538] = function(play,zt,Damage,Target,MagicId) -- 净世真言
-- 血量低于(30%)时恢复自身[50%]血量
-- 并且推开周围人物三格距离(CD60秒)
        if zt == 3 then
            local maxhp = _equip_get_maxhp(play)
            local curhp = _equip_get_curhp(play)
            if maxhp > 0 and curhp * 100 <= maxhp * 30 then
                if _equip_roll(play, 538, 5, 60) then
                    humanhp(play, "+", math.floor(maxhp * 0.50))
                end
            end
            return 0
        else
            _toggle_buff_var(play, VarCfg.S_buffbgwq, 538, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffbrwq, 538, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 538)
            end
        end
    end,
    [539] = function(play,zt,Damage,Target,MagicId) -- 荣耀之证
        -- 每次攻击怪物时增加[10%]的总伤害
        -- 当效果叠加十次后触发增伤效果清零
        -- (效果清零后需要人物重新叠加BUFF)
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff539", { [3]=6288, [4]=6288, [1]=62888, [2]=62888 }, zt == 1)
        end
    end,
        [540] = function(play,zt,Damage,Target,MagicId) -- 深渊凝视
-- 破复活几率：+ 5%
-- 攻击时有概率斩杀人物[15%]生命值
        if zt == 3 then
            if _equip_is_player(Target) then
                if _equip_roll(play, 540, 5, 30) then
                    local maxhp = _equip_get_maxhp(Target)
                    if maxhp > 0 then
                        return math.floor(maxhp * 0.15)
                    end
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff540", { [47]=5 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffrwq, 540, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 540)
            end
        end
    end,
    [541] = function(play,zt,Damage,Target,MagicId) -- 亡语回响
-- 固定攻击力：+ 4588
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff541", { [3]=4588, [4]=4588 }, zt == 1)
        end
    end,
        [542] = function(play,zt,Damage,Target,MagicId) -- 血祭残章
-- 固定攻击力：+ 4588
-- IMG:res/tips/3.png#0#0&0
-- 对怪伤害：+ 5%
-- 攻击时附带[18888]点对怪切割
        if zt == 3 then
            if _equip_is_mon(Target) then
                return 18888
            end
            return 0
        else
            _equip_set_attr(play, "装备buff542", { [3]=4588, [4]=4588, [245]=500 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgwq, 542, zt == 1)
        end
    end,
        [543] = function(play,zt,Damage,Target,MagicId) -- 混沌余烬
-- 固定攻击力：+ 4588
-- IMG:res/tips/3.png#0#0&0
-- 攻击有概率打掉目标[50%]的生命值
-- 恢复自身[20%]的生命值(仅PK触发)
        if zt == 3 then
            if _equip_is_player(Target) then
                if _equip_roll(play, 543, 5, 30) then
                    local maxhp = _equip_get_maxhp(Target)
                    if maxhp > 0 then
                        local dmg = math.floor(maxhp * 0.50)
                        local selfmax = _equip_get_maxhp(play)
                        humanhp(play, "+", math.floor(selfmax * 0.20))
                        return dmg
                    end
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff543", { [3]=4588, [4]=4588 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffrwq, 543, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 543)
            end
        end
    end,
        [544] = function(play,zt,Damage,Target,MagicId) -- 古神语
-- 固定攻击力：+ 6288
-- 固定生命值：+ 62888
-- 固定魔法值：+ 62888
-- 每秒恢复人物(等级*10)的生命值
-- IMG:res/tips/3.png#0#0&0
-- 当生命值低于[50%]时触发下一次攻
-- 击切割人物(20%)的生命值(CD120秒)
        if zt == 3 then
            if _equip_has_next_flag(play, 544) and _equip_is_player(Target) then
                _equip_set_next_flag(play, 544, false)
                local maxhp = _equip_get_maxhp(Target)
                if maxhp > 0 then
                    return math.floor(maxhp * 0.20)
                end
            end
            local maxhp = _equip_get_maxhp(play)
            local curhp = _equip_get_curhp(play)
            if maxhp > 0 and curhp * 100 <= maxhp * 50 then
                if _equip_roll(play, 544, 5, 120) then
                    _equip_set_next_flag(play, 544, true)
                end
            end
            return 0
        else
            local level = tonumber(getbaseinfo(play, ConstCfg.gbase.level) or 0) or 0
            _equip_set_attr(play, "装备buff544", { [3]=6288, [4]=6288, [1]=62888, [2]=62888, [71]=level*10 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgjq, 544, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffbgwq, 544, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffbrwq, 544, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 544)
                _equip_set_next_flag(play, 544, false)
            end
        end
    end,
    [545] = function(play,zt,Damage,Target,MagicId) -- 虚空裂隙
        -- 攻击时有概率将目标[衣服]打入背包
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff545", { [1]=45888, [2]=45888 }, zt == 1)
        end
    end,
    [546] = function(play,zt,Damage,Target,MagicId) -- 禁忌之书
-- 固定生命值：+ 45888
-- IMG:res/tips/3.png#0#0&0
-- 攻击倍数：+ 5%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff546", { [1]=45888, [67]=5 }, zt == 1)
        end
    end,
        [547] = function(play,zt,Damage,Target,MagicId) -- 旧日契约
-- 固定攻击力：+ 4588
-- 固定生命值：+ 45888
-- 固定魔法值：+ 45888
-- 每秒恢复人物(等级*10)的生命值
-- IMG:res/tips/3.png#0#0&0
-- 人物永久进入[防冰冻]状态
-- 攻击时有概率造成冰冻[1]秒的效果
        if zt == 3 then
            if Target and _equip_roll(play, 547, 5, 30) then
                changemode(Target, ConstCfg.pmode.frost, 1)
            end
            return 0
        else
            local level = tonumber(getbaseinfo(play, ConstCfg.gbase.level) or 0) or 0
            _equip_set_attr(play, "装备buff547", { [3]=4588, [4]=4588, [1]=45888, [2]=45888, [71]=level*10, [51]=100 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgjq, 547, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 547)
            end
        end
    end,
    [548] = function(play,zt,Damage,Target,MagicId) -- 幻梦之钥
-- 固定攻击力：+ 6288
-- 固定生命值：+ 62888
-- 固定魔法值：+ 62888
-- IMG:res/tips/3.png#0#0&0
-- 防止冰冻：+ 100%
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff548", { [3]=6288, [4]=6288, [1]=62888, [2]=62888, [51]=100 }, zt == 1)
        end
    end,
    [549] = function(play,zt,Damage,Target,MagicId) -- 残响
-- 固定攻击力：+ 4588
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff549", { [3]=4588, [4]=4588 }, zt == 1)
        end
    end,
        [550] = function(play,zt,Damage,Target,MagicId) -- 虚骸
-- 固定攻击力：+ 4588
-- 固定生命值：+ 45888
-- 固定魔法值：+ 45888
-- IMG:res/tips/3.png#0#0&0
-- 被攻击时有概率反弹[30%]所受伤害
        if zt == 3 then
            if Target and Damage and Damage > 0 then
                if _equip_roll(play, 550, 5, 30) then
                    humanhp(Target, "-", math.floor(Damage * 0.30), 110, 0, play, 1)
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff550", { [3]=4588, [4]=4588, [1]=45888, [2]=45888 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffbgjq, 550, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 550)
            end
        end
    end,
    [551] = function(play,zt,Damage,Target,MagicId) -- 蚀骨
        -- 复活后触发增加[50%]的最大攻击力
        -- (BUFF效果持续5秒·无法重复触发)
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff551", { [1]=45888, [2]=45888 }, zt == 1)
        end
    end,
    [552] = function(play,zt,Damage,Target,MagicId) -- 冥契
        -- 攻击人物时有概率使目标灼烧[10秒]
        -- 被灼烧命中的目标每秒额外掉血[2%]
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff552", { [3]=4588, [4]=4588, [1]=45888, [2]=45888 }, zt == 1)
        end
    end,
    [553] = function(play,zt,Damage,Target,MagicId) -- 罪印
        -- 攻击时有概率将目标附加[攻击倍数]
        -- 全部清空，BUFF效果持续3秒！
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff553", { [1]=45888, [2]=45888 }, zt == 1)
        end
    end,
    [554] = function(play,zt,Damage,Target,MagicId) -- 魂锁
-- 固定攻击力：+ 6288
-- 固定生命值：+ 62888
-- 固定魔法值：+ 62888
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff554", { [3]=6288, [4]=6288, [1]=62888, [2]=62888 }, zt == 1)
        end
    end,
    [555] = function(play,zt,Damage,Target,MagicId) -- 暗核
-- 固定攻击力：+ 6288
-- 固定生命值：+ 62888
-- 固定魔法值：+ 62888
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff555", { [3]=6288, [4]=6288, [1]=62888, [2]=62888 }, zt == 1)
        end
    end,
    [556] = function(play,zt,Damage,Target,MagicId) -- 星骸
        -- 穿戴随机获得以下[变异属性]的一种
        -- 变异①：攻击增加10%上限
        -- 变异②：全技能冷却CD减少2秒
        -- 变异③：人物体型增大增加10%体力
        -- 变异④：直接斩杀血量低于10%的怪物
        -- 变异⑤：攻击时概率触发1-3倍多重攻击
        if zt == 3 then
            return 0
        else
-- 装备效果
        end
    end,
    [557] = function(play,zt,Damage,Target,MagicId) -- 异星之骸
        -- 当人物的生命值低于(50%)时触发每秒
        -- 恢复[3%]生命值且增加(10%)攻击倍数
        -- (回血等BUFF效果持续10S·CD120秒)
        if zt == 3 then
            return 0
        else
-- 装备效果
        end
    end,
        [558] = function(play,zt,Damage,Target,MagicId) -- 虚空之光
-- 固定攻击力：+ 4588
-- IMG:res/tips/3.png#0#0&0
-- 攻击时有概率对目标造成瘫痪[1秒]
-- 并且恢复自身(30%)的最大生命值！
        if zt == 3 then
            if Target and _equip_roll(play, 558, 5, 30) then
                changemode(Target, ConstCfg.pmode.stick, 1)
                local maxhp = _equip_get_maxhp(play)
                if maxhp > 0 then
                    humanhp(play, "+", math.floor(maxhp * 0.30))
                end
            end
            return 0
        else
            _equip_set_attr(play, "装备buff558", { [3]=4588, [4]=4588 }, zt == 1)
            _toggle_buff_var(play, VarCfg.S_buffgjq, 558, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 558)
            end
        end
    end,
    [559] = function(play,zt,Damage,Target,MagicId) -- 界域之核
        -- (非战斗状态下)使用十步一杀会触发
        -- 接下来第一刀必定会麻痹目标[1秒]
        if zt == 3 then
            return 0
        else
            _equip_set_attr(play, "装备buff559", { [1]=45888, [2]=45888 }, zt == 1)
        end
    end,
        [560] = function(play,zt,Damage,Target,MagicId) -- 空界之芯
-- 攻击时有概率造成[700%]的对怪切割
        if zt == 3 then
            if _equip_is_mon(Target) then
                if _equip_roll(play, 560, 5, 30) then
                    local cut = tonumber(getbaseinfo(play, 51, 244) or 0) or 0
                    if cut > 0 then
                        return cut * 7
                    end
                end
            end
            return 0
        else
            _toggle_buff_var(play, VarCfg.S_buffgwq, 560, zt == 1)
            if zt == 2 then
                _equip_clear_state(play, 560)
            end
        end
    end,
        -- Buff 561 将攻击触发转发到星象圣图系统。
        [561] = function(play,zt,Damage,Target,MagicId,Model) -- 星象圣图攻击触发
        if zt == 3 then
            if star_chart_attack_trigger then
                return star_chart_attack_trigger(play, Damage, Target, MagicId, Model) or 0
            end
            return 0
        else
            _toggle_buff_var(play, VarCfg.S_buffgjq, 561, zt == 1)
        end
    end,
        -- Buff 562 将受击触发转发到星象圣图系统。
        [562] = function(play,zt,Damage,Target,MagicId) -- 星象圣图被击触发
        if zt == 3 then
            if star_chart_struck_trigger then
                return star_chart_struck_trigger(play, Damage, Target, MagicId) or 0
            end
            return 0
        else
            _toggle_buff_var(play, VarCfg.S_buffbgjq, 562, zt == 1)
        end
    end,
}
local weizhi = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,55,71,72,73,74,75,76,78,85,86,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120}
function Buff.refreshHuTiGuangHuan(play)
    Buff[107](play, 2)
    -- Buff[108](play, 2)
    -- Buff[109](play, 2)
    Buff[110](play, 2)
    clearplayeffect(play,11501)
    clearplayeffect(play,11506)
    clearplayeffect(play,11505)
    local zs_level = tonumber(getplaydef(play, VarCfg["U_转生等级"]) or 0) or 0
    local sc_data = Player.getJsonTableByVar(play, VarCfg["T_首冲礼包"]) or {}
    local unlocked = {
        [1] = zs_level >= 10,
        [2] = tonumber(sc_data["首充"] or 0) == 1,
        [3] = getflagstatus(play, VarCfg.BS_mztq) == 1,
    }
    local active = tonumber(getplaydef(play, VarCfg["U_护体光环激活"]) or 0) or 0
    if active < 1 or active > 3 or not unlocked[active] then
        active = 0
        setplaydef(play, VarCfg["U_护体光环激活"], 0)
    end
    if unlocked[1] then
        Buff[107](play, 1)
        -- playeffect(play,11502,0,0,0,1,0)
    end
    if unlocked[2] then
        -- Buff[108](play, 1)
        -- Buff[109](play, 1)
        Player.add_attlist(play, "光环属性", "=", "3#255#888", 1)
        -- playeffect(play,11503,0,0,0,1,0)
    end
    if unlocked[3] then
        Buff[110](play, 1)
        -- playeffect(play,11504,0,0,0,1,0)
    end
    if active == 1 then
        playeffect(play,11501,0,0,0,1,0)
    elseif active == 2 then
        playeffect(play,11506,0,0,0,1,0)
    elseif active == 3 then
        playeffect(play,11505,0,0,0,1,0)
    end
end
function Buff.login(play)
    -------------------------------------------------------------------装备BUFF登录初始化
    -- 登录时先清空属性下发缓存，避免跨上下线后同属性被误判为已挂载
    Player.clear_attlist_cache(play)
    for k, v in pairs(weizhi) do
        local item = linkbodyitem(play,v)
        if item ~= "0" then
            if v == 14 then
                changemoney(play,16,"=",1,"登录复活",true)
            end
            local id = getstditeminfo(getiteminfo(play,item,2),8)
            if id > 0 and Buff[id] then
                Buff[id](play,1)
            end
        end
    end
    -------------------------------------------------------------------称号BUFF登录初始化
    local ch = gettitlelist(play)
    for _, v in pairs(ch) do
        local idx = getstditeminfo(getiteminfo(play,v,1),8)
        if idx and idx > 0 then
            Buff[idx](play,1)
        end
    end
    -------------------------------------------------------------------护体光环
    local T_data = _sc_get_data(play)
    if (T_data["ok"] and T_data["ok"] == 1) then
        Buff[73](play,1)
    end
    -------------------------------------------------------------------护体光环
    -- 护体光环登录刷新
    Buff.refreshHuTiGuangHuan(play)
    -------------------------------------------------------------------额外附加属性登录初始化
    --灵根鉴定
    local data = Player.getJsonTableByVar(play, VarCfg["T_灵根鉴定"])
    if data["1"] then
        local attrs = {}
        local attrsstr = ""
        for i=1,5 do
            attrs[teshudata["npc_1"].config[i].attr] = data[""..i] or 0
        end
        attrsstr = Player.getAttrTableToStr(attrs)
        Player.add_attlist(play, "灵根鉴定", "=", attrsstr, 1)
    end
    --灵根修炼
    data = Player.getJsonTableByVar(play, VarCfg["T_灵根修炼"])
    local attrs = {}
    local attrsstr = ""
    for i=1,5 do
        attrs[teshudata["npc_11"].attrID[i]] = (data[""..i] or 0) * teshudata["npc_11"].config[i].ratio
    end
    attrsstr = Player.getAttrTableToStr(attrs)
    Player.add_attlist(play, "灵根修炼", "=", attrsstr, 1)
    --兰姐好感度
    if getplaydef(play, VarCfg["U_兰姐好感度"]) > 0 then
        Player.add_attlist(play, "兰姐好感度", "=", "3#"..teshudata["npc_13"].attrID.."#"..teshudata["npc_13"].config[getplaydef(play, VarCfg["U_兰姐好感度"])].ratio, 1)
    end
    --福娃猜拳切割
    data = Player.getJsonTableByVar(play, VarCfg["T_福娃猜拳"] )
    local fuwa_cut = tonumber(data.cut) or 0
    Player.del_attlist(play, "福娃猜拳切割")
    if fuwa_cut > 0 then
        Player.add_attlist(play, "福娃猜拳切割", "=", "3#" .. (teshudata["npc_66"].cut_attr or 244) .. "#" .. fuwa_cut, 1)
    end
    -- 古刹魔瓶：背包神器位不走常规装备位登录初始化，这里补一次。
    if Player.hasEquipInArtifactSlot(play, "古刹魔瓶") then
        Buff[340](play, 1)
    else
        Buff[340](play, 2)
    end
    -- 切割刀：登录时补一次累计切割同步，确保物品上展示实时正确。
    if tonumber(getplaydef(play, "N$切割刀已激活") or 0) == 1 then
        Buff[564](play, 1)
    else
        Buff[564](play, 2)
    end
    ------------------------------------------------------------通用属性
    local attr = {}
    Player.updateSomeAddr(play,nil, attr)
end
GameEvent.add(EventCfg.onLogin, Buff.login, "buff")
-- 大地之王祝福：击杀玩家叠层事件
-- 该称号不走普通 Buff[328](zt=3) 分支，改为在 onkillplay 中直接累加层数并同步属性
GameEvent.add(EventCfg.onkillplay, function(play)
    if not _has_title_buff_flag(play, 328) then
        return
    end
    local stack = tonumber(getplaydef(play, "N$buff328_stack") or 0) or 0
    if stack < 10 then
        setplaydef(play, "N$buff328_stack", stack + 1)
        _title_sync_dadi_attr(play)
    end
end, "Buff_328_stack")
-- 装备效果
GameEvent.add(EventCfg.onkillplay, function(play, target)
    if (tonumber(getplaydef(play, "N$equipbuff413on") or 0) or 0) == 1 then
        if _equip_roll(play, 413, 100, 20) then
            local maxhp = _equip_get_maxhp(play)
            if maxhp > 0 then
                humanhp(play, "+", math.floor(maxhp * 0.10))
            end
        end
    end
end, "Equip_Kill_413")
-- 装备效果
GameEvent.add(EventCfg.onPlaydie, function(play, killer)
    if _equip_has_flag(play, "N$equipset_potian") and killer and getbaseinfo(killer, ConstCfg.gbase.isplayer) then
        setplaydef(play, "N$equipbuff477_target", tostring(getbaseinfo(killer, ConstCfg.gbase.name) or ""))
    end
    if _equip_has_flag(play, "N$equipbuff520on") then
        local dc2 = tonumber(getbaseinfo(play, ConstCfg.gbase.dc2) or 0) or 0
        if dc2 > 0 then
            local x = getbaseinfo(play, ConstCfg.gbase.x)
            local y = getbaseinfo(play, ConstCfg.gbase.y)
            rangeharm(play, x, y, 3, math.floor(dc2 * 3.33), 0, 0, 0, 2, 0, 20)
        end
    end
end, "Equip_OnPlaydie")
Buff.refreshRechargeBlade = Buff_refreshRechargeBlade
function Buff.chuan(play,item)
    local id = getstditeminfo(getiteminfo(play,item,2),8)
    if id > 0 and Buff[id]then
        Buff[id](play,1)
        release_print("装备BUFF触发，位置："..item.."，BUFFID："..id)
    end
end
function Buff.tuo(play,item)
    local id = getstditeminfo(getiteminfo(play,item,2),8)
    if id > 0 and Buff[id] then
        Buff[id](play,2)
    end
end
return Buff