npc = {}


-- 天道命盘
local _config = Guard.getConfig("npc_74")
local _npc_key = "npc_74"
local _attr_list_name = "天道命盘"
local _realm_need_level = 18

local function _get_dljq_data(play)
    local T_data = Player.getJsonTableByVar(play, VarCfg.T_dljq) or {}
    T_data[_npc_key] = T_data[_npc_key] or {}
    return T_data, T_data[_npc_key]
end

local function _save_dljq_data(play, T_data)
    Player.setJsonVarByTable(play, VarCfg.T_dljq, T_data)
end

local function _count_full_lingshou(play)
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_灵兽"]) or {}
    local ls = T_data.ls or {}
    local max_level = ((((teshudata or {})["npc_64"] or {}).config or {}).wy or {}).max_level or 0
    local count = 0
    if max_level <= 0 then
        return 0, 0
    end
    for _, level in pairs(ls) do
        if (tonumber(level) or 0) >= max_level then
            count = count + 1
        end
    end
    return count, max_level
end

local function _has_awakened_main_linggen_level(play, needLevel)
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_灵根"]) or {}
    local mainIdx = tonumber(T_data.main or 0) or 0
    if mainIdx <= 0 then
        return false, 0, 0
    end
    local cfg = (teshudata or {})["npc_22"] or {}
    local pair = (cfg.awaken_pairs or {})[mainIdx]
    if not pair or pair <= 5 then
        return false, pair or 0, 0
    end
    local lv = tonumber((T_data.level or {})[tostring(pair)] or 0) or 0
    return lv >= (needLevel or 3), pair, lv
end
local function _get_realm_level(play)
    return tonumber(getplaydef(play, VarCfg["U_境界修炼"][1])) or 0
end

local function _count_red_xianfa(play)
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_天书"]) or {}
    local count = 0
    for _, v in pairs(T_data.caowei or {}) do
        if type(v) == "table" and (tonumber(v[1]) or 0) >= 5 then
            count = count + 1
        end
    end
    return count, tonumber(T_data.level) or 0
end

function TianMingDaoPanHasPath(play, idx)
    local T_data = Player.getJsonTableByVar(play, VarCfg.T_dljq) or {}
    local state = T_data[_npc_key] or {}
    return tonumber(state[tostring(idx)] or 0) == 1
end

function TianMingDaoPanAdjustPlayerDamage(play, target, damage)
    damage = tonumber(damage) or 0
    if damage <= 0 or not play or not target then
        return damage
    end
    local attackerDone = TianMingDaoPanHasPath(play, 3)
    local targetDone = TianMingDaoPanHasPath(target, 3)
    if attackerDone and not targetDone then
        damage = math.floor(damage * 110 / 100)
    end
    if targetDone and not attackerDone then
        damage = math.floor(damage * 90 / 100)
    end
    return damage
end

local function _refresh_tmlp_extra_effects(play)
    if TMLP_refresh_linggen_bonus then
        TMLP_refresh_linggen_bonus(play)
    end
    if TMLP_refresh_pet_bonus then
        TMLP_refresh_pet_bonus(play)
    end
end
local function _check_task_condition(play, idx)
    if idx == 1 then
        local count = _count_full_lingshou(play)
        if count < 2 then
            return false, string.format("需要任意2只灵兽亲密度满级后才可激活，当前仅完成%d/2#57", count)
        end
        return true
    elseif idx == 2 then
        local ok, pair, lv = _has_awakened_main_linggen_level(play, 3)
        if not ok then
            return false, string.format("需要本命灵根对应的觉醒灵根达到|【Lv.3】#218|后才可激活，当前觉醒灵根等级为|【%d】#218|#57", lv or 0)
        end
        return true
    elseif idx == 3 then
        local level = _get_realm_level(play)
        if level < _realm_need_level then
            return false, "需要境界达到|【元婴境】#218|后才可激活#57"
        end
        return true
    elseif idx == 4 then
        local red_count, book_level = _count_red_xianfa(play)
        if book_level < 30 then
            return false, string.format("需要天书达到|【LV30】#218|后才可激活，当前等级为|【%d】#218|#57", book_level)
        end
        if red_count < 3 then
            return false, string.format("需要拥有|【3条红色仙法】#218|后才可激活，当前仅有|【%d条】#218|#57", red_count)
        end
        return true
    end
    return false, "参数错误#57"
end

local function _refresh_all_count(state)
    local count = 0
    for i = 1, #(_config.details or {}) do
        if state[tostring(i)] == 1 then
            count = count + 1
        end
    end
    state.all = count
    return count
end

local function _rebuild_tmlp_attr(play)
    local _, state = _get_dljq_data(play)
    local attrs = {}
    Player.del_attlist(play, _attr_list_name)
    for idx, cfg in ipairs(_config.details or {}) do
        if state[tostring(idx)] == 1 then
            for _, attr in pairs(cfg.attr or cfg.attrs or {}) do
                if type(attr) == "table" then
                    local attr_id = tonumber(attr.attrID or attr[1])
                    local value = tonumber(attr.value or attr[2]) or 0
                    if attr_id and value ~= 0 then
                        attrs[attr_id] = (attrs[attr_id] or 0) + value
                    end
                end
            end
        end
    end
    local attrsstr = Player.getAttrTableToStr(attrs)
    if attrsstr and attrsstr ~= "" then
        Player.add_attlist(play, _attr_list_name, "=", attrsstr, 1)
    end
end

local function _try_grant_all_level_bonus(play, T_data, state)
    if state.level_bonus == 1 then
        return false
    end
    if (state.all or 0) < (_config.all or 0) then
        return false
    end
    if (tonumber(getbaseinfo(play, 6)) or 0) < (_config.all_level_need or 150) then
        return false
    end
    state.level_bonus = 1
    _save_dljq_data(play, T_data)
    local _, realAdd = Player.addRoleLevel(play, _config.all_level_add or 5, false)
    if realAdd > 0 then
        Player.sendmsgEx(play, string.format("你已激活全部|【天道命盘】#218|，额外获得|【%d级】#218|", realAdd))
    else
        Player.sendmsgEx(play, string.format("你已激活全部|【天道命盘】#218|，但当前等级已达|【%d级】#218|上限，未获得额外等级#57", Player.getRoleLevelCap()))
    end
    return true
end

function npc.main(play, npcid)
    local T_data = Player.getJsonTableByVar(play, VarCfg.T_dljq) or {}
    T_data[_npc_key] = T_data[_npc_key] or {}
    sendluamsg(play, 100, npcid, 0, 0, tbl2json({T_data = T_data}))
end

function npc.link(play, npcid, p2, p3, msgData)

    -- npc_guard: 入参校验
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local __guardAction = Guard.normalizeAction(play, npcid, p2)
    if __guardAction == nil then
        return
    end
    p2 = __guardAction
    -- npc_guard: 操作白名单（优化：限定合法操作编号）
    local __guardAllowedActions = Guard.newActionSet({1, 2})
    if not Guard.ensureActionAllowed(play, npcid, p2, __guardAllowedActions) then
        return
    end

    local json_data = json2tbl(msgData) or {}
    local T_data, state = _get_dljq_data(play)
    if p2 == 1 then
        local idx = tonumber(json_data.idx)
        local detail = idx and _config.details[idx] or nil
        if not detail then
            Player.sendmsgEx(play, "参数错误#57")
            return
        end
        if state[tostring(idx)] == 1 then
            Player.sendmsgEx(play, "你已经完成了该任务#57")
            return
        end

        local ok, err = _check_task_condition(play, idx)
        if not ok then
            Player.sendmsgEx(play, err)
            return
        end

        local name, num = Player.checkItemNumByTable(play, detail.cost or {})
        if name then
            Player.sendmsgEx(play, string.format("你的#57|【%s】#218|不足：#57|【%d】#218|", name, num))
            return
        end
        Player.takeItemByTable(play, detail.cost or {}, ",天道命盘", nil)

        state[tostring(idx)] = 1
        _refresh_all_count(state)
        _save_dljq_data(play, T_data)
        _rebuild_tmlp_attr(play)

        Player.sendmsgEx(play, string.format("你完成了|【%s】#218|命盘激活", detail.name))
        if (state.all or 0) >= (_config.all or 0) then
            if not _try_grant_all_level_bonus(play, T_data, state) then
                if (tonumber(getbaseinfo(play, 6)) or 0) < (_config.all_level_need or 150) then
                    Player.sendmsgEx(play, string.format("你已激活全部|【天道命盘】#218|，达到|【%d级】#218|后可额外获得|【%d级】#218|", _config.all_level_need or 150, _config.all_level_add or 5))
                end
            end
        end
        sendluamsg(play, 100, npcid, 1, 0, tbl2json({T_data = T_data}))
    elseif p2 == 2 then
        _try_grant_all_level_bonus(play, T_data, state)
        sendluamsg(play, 100, npcid, 2, 0, tbl2json({T_data = T_data}))
    end
end

function Login_tmlp(play)
    _rebuild_tmlp_attr(play)
    local T_data, state = _get_dljq_data(play)
    _try_grant_all_level_bonus(play, T_data, state)
end

function LevelUp_tmlp(play)
    local T_data, state = _get_dljq_data(play)
    _try_grant_all_level_bonus(play, T_data, state)
end

GameEvent.add(EventCfg.onLogin, Login_tmlp, "Login_tmlp")
GameEvent.add(EventCfg.onPlayLevelUp, LevelUp_tmlp, "LevelUp_tmlp")


return npc
