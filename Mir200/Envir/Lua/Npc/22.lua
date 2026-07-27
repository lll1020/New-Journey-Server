npc = {}
--灵根
local _config = Guard.getConfig("npc_22") or {}
local FairyFate = include("lua/LuaLib/fairy_fate.lua")
local _base_ratio = tonumber(_config.base_ratio or 0) or 0
local eff_top = {
    [1] = 60501, [2] = 60502, [3] = 60503, [4] = 60500, [5] = 60504,
}

local function _toint(v, d)
    v = tonumber(v)
    if v == nil then return d or 0 end
    return math.floor(v)
end

local function _round(value)
    value = tonumber(value) or 0
    if value <= 0 then return 0 end
    local ret = math.floor(value + 0.5)
    if ret <= 0 then ret = 1 end
    return ret
end

local function _root_cfg(idx)
    return _config.main_r and _config.main_r[tonumber(idx or 0)] or nil
end

local function _has_root(T_data, idx)
    T_data = type(T_data) == "table" and T_data or {}
    T_data.level = type(T_data.level) == "table" and T_data.level or {}
    return T_data.level[tostring(idx)] ~= nil
end

local function _has_any_basic_root(T_data)
    for i = 1, 5 do
        if _has_root(T_data, i) then return true end
    end
    return false
end

local function _ensure_data(T_data)
    T_data = type(T_data) == "table" and T_data or {}
    T_data.level = type(T_data.level) == "table" and T_data.level or {}
    if T_data.other then T_data.other = nil end
    T_data.unlock_chance = nil
    T_data.init_unlock_given = nil
    return T_data
end

local function _activate_basic_roots(T_data)
    T_data = _ensure_data(T_data)
    for i = 1, 5 do
        local key = tostring(i)
        if T_data.level[key] == nil then
            T_data.level[key] = 0
        end
    end
    return T_data
end

local function _clear_basic_roots_before_mainline(T_data)
    T_data = _ensure_data(T_data)
    for i = 1, 5 do
        local key = tostring(i)
        if _toint(T_data.level[key], 0) <= 0 then
            T_data.level[key] = nil
        end
    end
    if _toint(T_data.main, 0) >= 1 and _toint(T_data.main, 0) <= 5 and not _has_root(T_data, T_data.main) then
        T_data.main = nil
    end
    return T_data
end

local function _level(T_data, idx)
    if not _has_root(T_data, idx) then return 0 end
    return math.max(0, _toint(T_data.level[tostring(idx)], 0))
end

local _linggen_skill_ids = {
    [1] = 1007, [2] = 1008, [3] = 1009, [4] = 1010, [5] = 1011,
    [6] = 1012, [7] = 1013, [8] = 1014, [9] = 1015, [10] = 1016,
}

local function _sync_linggen_skill(play, T_data)
    T_data = _ensure_data(T_data or Player.getJsonTableByVar(play, VarCfg["T_灵根"]))
    for _, skillId in pairs(_linggen_skill_ids) do
        delskill(play, skillId)
        setplaydef(play, "N$magtag_level_" .. tostring(skillId), 0)
    end
    local mainIdx = _toint(T_data.main, 0)
    local skillId = _linggen_skill_ids[mainIdx]
    local level = _level(T_data, mainIdx)
    if skillId and level > 0 then
        addskill(play, skillId, level)
        setplaydef(play, "N$magtag_level_" .. tostring(skillId), level)
    end
end

local function _interp_attr_value(one, level)
    level = math.max(1, math.min(10, _toint(level, 1)))
    local v1 = tonumber(one[2]) or 0
    local v10 = tonumber(one[3])
    if v10 then
        return _round(v1 + (v10 - v1) * (level - 1) / 9)
    end
    return _round(v1 * (level + _base_ratio))
end

local function _build_attr_by_level(attr_list, level)
    local attrs = {}
    if _toint(level, 0) <= 0 then return attrs end
    for _, one in ipairs(attr_list or {}) do
        attrs[#attrs + 1] = {one[1], _interp_attr_value(one, level)}
    end
    return attrs
end

local function _build_lv0_attr(idx)
    local isHigh = _toint(idx, 0) > 5
    local base = isHigh and 100 or 10
    local hpmp = isHigh and 2000 or 200
    return {
        {1, hpmp}, {2, hpmp},
        {3, base}, {4, base}, {5, base}, {6, base}, {7, base}, {8, base},
        {9, base}, {10, base},
    }
end

local function _build_root_attr(idx, level)
    local cfg = _root_cfg(idx)
    if not cfg then return {} end
    local attrs = _build_lv0_attr(idx)
    for _, one in ipairs(_build_attr_by_level(cfg.attr, level)) do
        attrs[#attrs + 1] = one
    end
    return attrs
end

local function _build_special_by_level(special_list, level)
    local specials = {}
    if _toint(level, 0) <= 0 then return specials end
    level = math.max(1, math.min(10, _toint(level, 1)))
    for _, one in ipairs(special_list or {}) do
        local key = tostring(one.key or one[1] or "")
        if key ~= "" then
            local v1 = tonumber(one.v1 or one[2]) or 0
            local v10 = tonumber(one.v10 or one[3])
            local value = v10 and _round(v1 + (v10 - v1) * (level - 1) / 9) or _round(v1 * (level + _base_ratio))
            specials[key] = (specials[key] or 0) + value
        end
    end
    return specials
end

local function _build_root_special(idx, level)
    local cfg = _root_cfg(idx)
    if not cfg then return {} end
    return _build_special_by_level(cfg.special, level)
end

local function _refresh_linggen_special(play, T_data)
    T_data = _ensure_data(T_data or Player.getJsonTableByVar(play, VarCfg["T_灵根"]))
    local totals = {}
    for i = 1, 10 do
        local lv = _level(T_data, i)
        if lv > 0 then
            for key, value in pairs(_build_root_special(i, lv)) do
                totals[key] = (totals[key] or 0) + value
            end
        end
    end
    setplaydef(play, "N$linggen_skill_cd_dec", _toint(totals.skill_cd_dec, 0))
end
local function _refresh_send(play, npcid, p2)
    sendluamsg(play, 100, npcid, p2 or 1, 0, tbl2json({T_data = Player.getJsonTableByVar(play, VarCfg["T_灵根"])}))
end

local function _take_change_cost(play)
    local cost = _config.main_xl_cost or {}
    if #cost <= 0 then return true end
    local name, num = Player.checkItemNumByTable(play, cost)
    if name then
        Player.sendmsgEx(play, string.format("切换本命灵根需要#57|【%s】#218|x%s", tostring(name), tostring(num or 0)))
        return false
    end
    Player.takeItemByTable(play, cost, ",本命灵根切换", nil)
    return true
end

local function _mainline_reached_linggen(play)
    return (tonumber(getplaydef(play, VarCfg.U_zxrw[1]) or 0) or 0) >= 22
end

local function _check_linggen_unlock(play)
    local data = Player.getJsonTableByVar(play, VarCfg["T_锁妖塔"] or "T51") or {}
    if (tonumber(data.total_runs or 0) or 0) >= 6 then
        return true
    end
    Player.sendmsgEx(play, "请先完成异闻录任务#57|【挑战六次通天塔】#218|后再开启灵根功能#57")
    return false
end
local function _need_role_level(rootIdx, nextLevel)
    local low = {80,80,80,100,100,100,150,150,150,151}
    local high = {152,152,152,155,155,155,160,160,160,165}
    return (tonumber(rootIdx) or 0) <= 5 and low[nextLevel] or high[nextLevel]
end

function npc.main(play, npcid)
    if not _check_linggen_unlock(play) then return end
    local T_data = _activate_basic_roots(Player.getJsonTableByVar(play, VarCfg["T_灵根"]))
    Player.setJsonVarByTable(play, VarCfg["T_灵根"], T_data)
    sendluamsg(play, 100, npcid, 0, 0, tbl2json({T_data = T_data}))
    openhyperlink(play, 1, 2)
end

function npc.link(play, npcid, ew, aid)
    if not Guard.ensurePlayer(play, npcid) then return end
    if not _check_linggen_unlock(play) then return end
    ew = Guard.normalizeAction(play, npcid, ew)
    if ew == nil then return end
    if not Guard.ensureActionAllowed(play, npcid, ew, Guard.newActionSet({1, 2, 3, 5, 6})) then return end

    aid = _toint(aid, 0)
    local T_data = _activate_basic_roots(Player.getJsonTableByVar(play, VarCfg["T_灵根"]))

    if ew == 1 then -- 主线到达后选择基础灵根；基础灵根此时初始化为Lv0
        if aid < 1 or aid > 5 then
            Player.sendmsgEx(play, "只能选择金木水火土基础灵根#57")
            return
        end
        T_data.level[tostring(aid)] = _level(T_data, aid)
        if _toint(T_data.main, 0) <= 0 then T_data.main = aid end
        Player.setJsonVarByTable(play, VarCfg["T_灵根"], T_data)
        _sync_linggen_skill(play, T_data)
        _refresh_linggen_special(play, T_data)
        if zxrw_try_finish_current_mainline then zxrw_try_finish_current_mainline(play, "任务") end -- linggen_auto_1
        if FairyFate and FairyFate.touch then FairyFate.touch(play, "linggen") end
        local cfg = _root_cfg(aid) or {}
        Player.sendmsgEx(play, "提示：你选择了#7|【"..tostring(cfg.name or "").."灵根】#22|")
        _refresh_send(play, npcid, 1)
        return
    end

    if ew == 2 then -- 设置本命灵根
        local oldMain = _toint(T_data.main, 0)
        if aid == 0 then
            if oldMain <= 0 then
                Player.sendmsgEx(play, "当前未设置本命灵根#57")
                return
            end
            if not _take_change_cost(play) then return end
            T_data.main = nil
            Player.setJsonVarByTable(play, VarCfg["T_灵根"], T_data)
            _sync_linggen_skill(play, T_data)
            Player.sendmsgEx(play, "提示：本命灵根已卸下#7")
            _refresh_send(play, npcid, 1)
            clearplayeffect(play,(oldMain > 5 and oldMain - 5 or oldMain) + 60499)
            return
        end
        if not _has_root(T_data, aid) then
            Player.sendmsgEx(play, "你还没有该灵根，无法设置为本命#57")
            return
        end
        if oldMain == aid then
            Player.sendmsgEx(play, "该灵根已经是本命灵根#57")
            return
        end
        if oldMain > 0 and not _take_change_cost(play) then return end
        T_data.main = aid
        Player.setJsonVarByTable(play, VarCfg["T_灵根"], T_data)
        _sync_linggen_skill(play, T_data)
        if zxrw_try_finish_current_mainline then zxrw_try_finish_current_mainline(play, "任务") end -- linggen_auto_2
        Player.sendmsgEx(play, "提示：本命灵根切换成功#7")
        clearplayeffect(play,eff_top[(oldMain > 5 and oldMain - 5 or oldMain)])
        playeffect(play,eff_top[(aid > 5 and aid - 5 or aid)],0,0,0,0,0)
        _refresh_send(play, npcid, 1)
        return
    end

    if ew == 3 then -- 副灵根取消，兼容旧请求
        T_data.other = nil
        Player.setJsonVarByTable(play, VarCfg["T_灵根"], T_data)
        Player.sendmsgEx(play, "副灵根已取消，现在只保留本命灵根#57")
        _refresh_send(play, npcid, 1)
        return
    end

    if ew == 6 then -- 双形态灵根切换
        local mainIdx = _toint(T_data.main, 0)
        local pairIdx = _toint(_config.awaken_pairs and _config.awaken_pairs[mainIdx], 0)
        if mainIdx <= 0 or pairIdx <= 0 or not _has_root(T_data, pairIdx) then
            Player.sendmsgEx(play, "需要同时拥有本命灵根与对应觉醒灵根后才可切换#57")
            return
        end
        local realmNeed = _toint(_config.realm_dual_need, 26)
        local realmLevel = _toint(getplaydef(play, VarCfg["U_境界修炼"][1]), 0)
        if realmLevel < realmNeed then
            Player.sendmsgEx(play, "境界达到渡劫境[前期]后才可切换双形态灵根#57")
            return
        end
        if _toint(getplaydef(play, "N$战斗状态"), 0) >= os.time() then
            Player.sendmsgEx(play, "战斗状态无法切换灵根，脱战后再试#57")
            return
        end
        local now = os.time()
        local nextTime = _toint(T_data.dual_switch_next, 0)
        if nextTime > now then
            Player.sendmsgEx(play, "灵根形态切换冷却中，还需|【"..tostring(nextTime - now).."】#218|秒#57")
            return
        end
        T_data.main = pairIdx
        T_data.dual_switch_next = now + _toint(_config.switch_cd, 60)
        Player.setJsonVarByTable(play, VarCfg["T_灵根"], T_data)
        _sync_linggen_skill(play, T_data)
        local cfg = _root_cfg(pairIdx) or {}
        Player.sendmsgEx(play, "提示：已切换为#7|【"..tostring(cfg.name or "觉醒").."灵根】#22|")
        _refresh_send(play, npcid, 1)
        return
    end
    if ew == 5 then -- 灵根升级
        if not _has_root(T_data, aid) then
            Player.sendmsgEx(play, "你还没有该灵根，无法升级#57")
            return
        end
        local oldLevel = _level(T_data, aid)
        local nextLevel = oldLevel + 1
        if nextLevel > _toint(_config.main_updata and _config.main_updata.max_level, 10) then
            Player.sendmsgEx(play, "该灵根已达到最高等级#57")
            return
        end
        local needLv = _need_role_level(aid, nextLevel)
        local roleLv = _toint(getbaseinfo(play, 6), 0)
        if needLv and roleLv < needLv then
            Player.sendmsgEx(play, "升级该灵根需要人物等级达到|【Lv."..needLv.."】#218|，当前|【Lv."..roleLv.."】#249|#57")
            return
        end
        local details = ((_config.main_updata or {}).details or {})[aid <= 5 and "low" or "up"] or {}
        local upCfg = details[nextLevel]
        if not upCfg then
            Player.sendmsgEx(play, "灵根升级配置异常#57")
            return
        end
        local name = Player.checkItemNumByTable(play, upCfg.cost)
        if name then
            Player.sendmsgEx(play, "你的#57|【"..tostring(name).."】#218|不足#57")
            return
        end
        Player.takeItemByTable(play, upCfg.cost, ",灵根升级", nil)
        T_data.level[tostring(aid)] = nextLevel
        Player.setJsonVarByTable(play, VarCfg["T_灵根"], T_data)
        if _toint(T_data.main, 0) == aid then _sync_linggen_skill(play, T_data) end
        Player.updateSomeAddr(play, _build_root_attr(aid, oldLevel), _build_root_attr(aid, nextLevel))
        _refresh_linggen_special(play, T_data)
        if zxrw_try_finish_current_mainline then zxrw_try_finish_current_mainline(play, "任务") end -- linggen_auto_1
        TMLP_refresh_linggen_bonus(play)
        if FairyFate and FairyFate.touch then FairyFate.touch(play, "linggen") end
        Player.sendmsgEx(play, "提示：你的#7|【灵根】#22|升级成功#7")
        sendluamsg(play, 101, 1005, 0, 0, "tpcg")
        _refresh_send(play, npcid, 2)
        return
    end
end

function Login_lg(play)
    local T_data = _ensure_data(Player.getJsonTableByVar(play, VarCfg["T_灵根"]))
    if not _mainline_reached_linggen(play) then
        T_data = _clear_basic_roots_before_mainline(T_data)
        Player.setJsonVarByTable(play, VarCfg["T_灵根"], T_data)
    end
    _sync_linggen_skill(play, T_data)
    _refresh_linggen_special(play, T_data)
    local attrs = {}
    for i = 1, 10 do
        if _has_root(T_data, i) then
            local lv = _level(T_data, i)
            for _, one in ipairs(_build_root_attr(i, lv)) do attrs[#attrs + 1] = one end
        end
    end
    local oldMain = _toint(T_data.main, 0)
    if oldMain > 0 then
        playeffect(play,eff_top[(oldMain > 5 and oldMain - 5 or oldMain)],0,0,0,0,0)
    end
    Player.updateSomeAddr(play, nil, attrs)
    TMLP_refresh_linggen_bonus(play)
end
GameEvent.add(EventCfg.onLogin, Login_lg, "Login_lg")

function TMLP_refresh_linggen_bonus(play)
    local T_data = _ensure_data(Player.getJsonTableByVar(play, VarCfg["T_灵根"]) or {})
    local maxLevel = _toint((_config.main_updata or {}).max_level, 10)
    local count = 0
    for _, level in pairs(T_data.level or {}) do
        if _toint(level, 0) >= maxLevel then count = count + 1 end
    end
    Player.del_attlist(play, "天命道盘_灵根加成")
    if count < 2 then return end
    local attrs = {}
    for i = 1, 10 do
        for _, one in ipairs(_build_root_attr(i, maxLevel)) do
            local id = tonumber(one[1])
            local value = math.floor((_toint(one[2], 0)) * 5 / 100)
            if id and value > 0 then attrs[id] = (attrs[id] or 0) + value end
        end
    end
    local attrsstr = Player.getAttrTableToStr(attrs)
    if attrsstr and attrsstr ~= "" then
        Player.add_attlist(play, "天命道盘_灵根加成", "=", attrsstr, 1)
    end
end

function npc.lgcf(play, zt, Damage, Target, triggerType)
    -- 新版灵根主动技能改为手动/自动释放，旧版30秒自动触发效果停用。
    return 0
end

function LingGenGrantBasicUnlockChance(play, count)
    if not _mainline_reached_linggen(play) then
        return false
    end
    local T_data = _activate_basic_roots(Player.getJsonTableByVar(play, VarCfg["T_灵根"]))
    Player.setJsonVarByTable(play, VarCfg["T_灵根"], T_data)
    return true
end

return npc
