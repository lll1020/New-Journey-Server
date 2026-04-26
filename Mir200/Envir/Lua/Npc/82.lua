npc = {}

-- 武器性格：管理每日抽取、运行态状态与战斗侧修正。
local _config = Guard.getConfig("npc_82") or {}
local _var_name = VarCfg["T_武器性格"] or "T68"
local _attr_list_name = tostring(_config.attr_list_name or "武器性格")
local _temp_attr_list_name = tostring(_config.temp_attr_list_name or "武器性格_临时")
local _tick_cmd = "@weapon_personality_tick"

-- 统一处理可能为空的数值。
local function _toint(v)
    return tonumber(v) or 0
end

-- 统一获取当前时间戳。
local function _now()
    return os.time()
end

-- 将当前日期按 YYYYMMDD 存储，用于每日重置。
local function _today_num()
    return _toint(os.date("%Y%m%d"))
end

-- 兼容两种地图来源读取当前地图。
local function _current_map(play)
    return tostring(getbaseinfo(play, ConstCfg.gbase.mapid) or getbaseinfo(play, 3) or "")
end

-- 按序号读取单个性格配置。
local function _personality_cfg(idx)
    return ((_config.personalities or {})[_toint(idx)] or {})
end

-- 读取单个性格的逻辑键名。
local function _personality_key(idx)
    return tostring(_personality_cfg(idx).key or "")
end

-- 读取单个性格的显示名称。
local function _personality_name(idx)
    return tostring(_personality_cfg(idx).name or "")
end

-- 从配置池中抽取当天的武器性格。
local function _pick_daily_personality()
    local order = _config.personality_order or {}
    if #order > 0 then
        return _toint(order[math.random(#order)])
    end
    local list = {}
    for k in pairs(_config.personalities or {}) do
        list[#list + 1] = _toint(k)
    end
    table.sort(list)
    return list[math.random(math.max(#list, 1))] or 1
end

-- 读取并规范化该系统的运行态数据。
local function _get_data(play)
    local data = Player.getJsonTableByVar(play, _var_name) or {}
    data.day = _toint(data.day)
    data.personality = _toint(data.personality)
    data.kill_player_layer = _toint(data.kill_player_layer)
    data.kill_player_expire = _toint(data.kill_player_expire)
    data.same_map = tostring(data.same_map or "")
    data.same_map_kill = _toint(data.same_map_kill)
    data.greed_gold = _toint(data.greed_gold)
    data.temp_type = tostring(data.temp_type or "")
    data.temp_gap = _toint(data.temp_gap)
    data.temp_end = _toint(data.temp_end)
    data.next_tick_at = _toint(data.next_tick_at)
    return data
end

-- 持久化该系统的运行态数据。
local function _save_data(play, data)
    Player.setJsonVarByTable(play, _var_name, data)
end

-- 统一处理命名属性列表的添加与清除。
local function _apply_attr_list(play, list_name, attrs)
    if type(attrs) == "table" and next(attrs) ~= nil then
        Player.add_attlist(play, list_name, "=", Player.getAttrTableToStr(attrs), 1)
    else
        Player.del_attlist(play, list_name)
    end
end

-- 跨天时清理按天生效的运行态数据。
local function _reset_daily_runtime(data)
    data.kill_player_layer = 0
    data.kill_player_expire = 0
    data.same_map = ""
    data.same_map_kill = 0
    data.greed_gold = 0
    data.temp_type = ""
    data.temp_gap = 0
    data.temp_end = 0
    data.next_tick_at = 0
end

-- 按需重新抽取每日性格。
local function _roll_daily_if_needed(play, data, force)
    local today_num = _today_num()
    if not force and data.day == today_num and _personality_key(data.personality) ~= "" then
        return false
    end
    data.day = today_num
    data.personality = _pick_daily_personality()
    _reset_daily_runtime(data)
    _save_data(play, data)
    return true
end

-- 清理过期定时器与无效的跨图状态。
local function _normalize_runtime(play, data)
    local changed = false
    local now = _now()
    local cur_key = _personality_key(data.personality)
    local cur_map = _current_map(play)

    if data.kill_player_expire > 0 and data.kill_player_expire <= now then
        if data.kill_player_layer ~= 0 then
            changed = true
        end
        data.kill_player_layer = 0
        data.kill_player_expire = 0
    end

    if data.temp_end > 0 and data.temp_end <= now then
        if data.temp_type ~= "" or data.temp_gap ~= 0 then
            changed = true
        end
        data.temp_type = ""
        data.temp_gap = 0
        data.temp_end = 0
    end

    if cur_key ~= "shixue" then
        if data.same_map ~= "" or data.same_map_kill ~= 0 then
            changed = true
        end
        data.same_map = ""
        data.same_map_kill = 0
    elseif data.same_map ~= "" and cur_map ~= "" and data.same_map ~= cur_map then
        data.same_map = ""
        data.same_map_kill = 0
        changed = true
    end

    if changed then
        _save_data(play, data)
    end
    return changed
end

-- 根据当前状态重建运行态属性。
local function _refresh_attrs(play, data)
    local now = _now()
    local cur_cfg = _personality_cfg(data.personality)
    local cur_key = tostring(cur_cfg.key or "")
    local main_attrs = {}
    local temp_attrs = {}

    if cur_key == "baonu" then
        local layer = 0
        if data.kill_player_expire > now then
            layer = math.min(_toint(cur_cfg.layer_max or 5), _toint(data.kill_player_layer))
        end
        if layer > 0 then
            main_attrs[_toint(cur_cfg.attack_attr or 282)] = layer * _toint(cur_cfg.attack_per_layer or 2)
        end
        if layer >= _toint(cur_cfg.layer_max or 5) then
            main_attrs[_toint(cur_cfg.full_crit_attr or 22)] = _toint(cur_cfg.full_crit_bonus or 10)
        end
    elseif cur_key == "shixue" then
        local cur_map = _current_map(play)
        if data.same_map ~= "" and data.same_map == cur_map and data.same_map_kill >= _toint(cur_cfg.kill_need or 100) then
            main_attrs[_toint(cur_cfg.mon_damage_attr or 245)] = _toint(cur_cfg.mon_damage_bonus or 500)
        end
    end

    if data.temp_end > now and data.temp_gap > 0 then
        if cur_key == "lianmin" and data.temp_type == "lianmin" then
            temp_attrs[_toint(cur_cfg.crit_damage_attr or 22)] = data.temp_gap
        elseif cur_key == "lumang" and data.temp_type == "lumang" then
            temp_attrs[_toint(cur_cfg.crit_resist_attr or 23)] = data.temp_gap
        end
    end

    _apply_attr_list(play, _attr_list_name, main_attrs)
    _apply_attr_list(play, _temp_attr_list_name, temp_attrs)
end

-- 安排下一次运行态清理定时。
local function _schedule_tick(play, data)
    local now = _now()
    local next_tick = 0
    local function _push(ts)
        ts = _toint(ts)
        if ts > now and (next_tick == 0 or ts < next_tick) then
            next_tick = ts
        end
    end
    _push(data.kill_player_expire)
    _push(data.temp_end)
    if next_tick > 0 then
        -- 战斗事件触发频繁，只有目标过期时间变化时才重新安排定时器。
        if _toint(data.next_tick_at) ~= next_tick then
            data.next_tick_at = next_tick
            _save_data(play, data)
            delaygoto(play, math.max(1000, (next_tick - now) * 1000 + 100), _tick_cmd)
        end
    elseif _toint(data.next_tick_at) ~= 0 then
        data.next_tick_at = 0
        _save_data(play, data)
    end
end

-- 统一入口：负责重抽、校正、刷新与重设定时。
local function _prepare_state(play, force_roll)
    local data = _get_data(play)
    _roll_daily_if_needed(play, data, force_roll)
    _normalize_runtime(play, data)
    _refresh_attrs(play, data)
    _schedule_tick(play, data)
    return data
end

-- 清理保底与莽撞效果使用的临时等级差状态。
local function _clear_temp_relation(play, data, relation_key)
    if relation_key ~= "" and data.temp_type ~= relation_key then
        return false
    end
    if data.temp_type == "" and data.temp_gap == 0 and data.temp_end == 0 then
        return false
    end
    data.temp_type = ""
    data.temp_gap = 0
    data.temp_end = 0
    _save_data(play, data)
    _refresh_attrs(play, data)
    return true
end

-- 将等级差换算为有上限的百分比加成。
local function _calc_gap_bonus(cur_cfg, my_level, target_level, relation)
    local max_gap = math.max(1, _toint(cur_cfg.gap_max or 5))
    local per_level = math.max(1, _toint(cur_cfg.gap_per_level or 1))
    local gap = 0
    if relation == "lower" and my_level > target_level then
        gap = (my_level - target_level) * per_level
    elseif relation == "higher" and target_level > my_level then
        gap = (target_level - my_level) * per_level
    end
    if gap <= 0 then
        return 0
    end
    return math.min(max_gap, gap)
end

-- 保存临时等级差状态并安排过期清理。
local function _set_temp_relation(play, data, relation_key, gap)
    local keep_sec = math.max(1, _toint(_config.temp_relation_sec or 3))
    gap = math.max(0, _toint(gap))
    if gap <= 0 then
        return _clear_temp_relation(play, data, relation_key)
    end
    data.temp_type = tostring(relation_key or "")
    data.temp_gap = gap
    data.temp_end = _now() + keep_sec
    _save_data(play, data)
    _refresh_attrs(play, data)
    _schedule_tick(play, data)
    return true
end

-- 为贪婪性格判定额外金币奖励。
local function _pick_greed_gold(cur_cfg)
    local pools = cur_cfg.gold_roll or {}
    local total_weight = 0
    for _, one in ipairs(pools) do
        total_weight = total_weight + math.max(0, _toint(one.weight))
    end
    if total_weight <= 0 then
        return math.random(100, 200)
    end
    local roll = math.random(total_weight)
    local acc = 0
    for _, one in ipairs(pools) do
        acc = acc + math.max(0, _toint(one.weight))
        if roll <= acc then
            local min_num = _toint(one.min)
            local max_num = _toint(one.max)
            if max_num < min_num then
                max_num = min_num
            end
            return math.random(min_num, max_num)
        end
    end
    return math.random(100, 200)
end

-- 组装武器性格面板下发给客户端的数据。
local function _build_payload(play)
    local data = _prepare_state(play, false)
    local cur_cfg = _personality_cfg(data.personality)
    local now = _now()
    local cur_map = _current_map(play)
    local layer = (data.kill_player_expire > now) and data.kill_player_layer or 0
    local temp_gap = (data.temp_end > now) and data.temp_gap or 0
    return {
        T_data = data,
        config = _config,
        current_idx = data.personality,
        current_key = tostring(cur_cfg.key or ""),
        current_name = tostring(cur_cfg.name or ""),
        current_desc = tostring(cur_cfg.desc or ""),
        layer = layer,
        layer_remain = math.max(0, _toint(data.kill_player_expire) - now),
        same_map = data.same_map,
        same_map_kill = data.same_map_kill,
        same_map_active = (tostring(cur_cfg.key or "") == "shixue" and data.same_map ~= "" and data.same_map == cur_map and data.same_map_kill >= _toint(cur_cfg.kill_need or 100)) and 1 or 0,
        greed_gold = data.greed_gold,
        temp_gap = temp_gap,
        cur_map = cur_map,
    }
end

-- 打开武器性格面板。
function npc.main(play, npcid)
    sendluamsg(play, 100, npcid, 0, 0, tbl2json(_build_payload(play)))
end

-- 仅刷新并回传当前面板状态。
function npc.link(play, npcid, p2, p3, msgData)
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local action = Guard.normalizeAction(play, npcid, p2)
    if action == nil then
        return
    end
    p2 = action
    local allowed = Guard.newActionSet({1,9})
    if not Guard.ensureActionAllowed(play, npcid, p2, allowed) then
        return
    end
    sendluamsg(play, 100, npcid, p2, _toint(p3), tbl2json(_build_payload(play)))
end

-- 用于清理运行态状态的定时入口。
function weapon_personality_tick(play)
    _prepare_state(play, false)
end

-- 攻击方伤害修正，处理保底与莽撞逻辑。
function weapon_personality_attack_adjust(play, target, damage, magicid, model)
    if not play or not target or _toint(damage) <= 0 then
        return damage
    end
    local data = _prepare_state(play, false)
    local cur_cfg = _personality_cfg(data.personality)
    local cur_key = tostring(cur_cfg.key or "")
    if cur_key ~= "lianmin" and cur_key ~= "lumang" then
        return damage
    end
    -- 怜悯/鲁莽的“伤害增幅”直接走伤害倍率，不额外占属性位。
    local my_level = _toint(getbaseinfo(play, ConstCfg.gbase.level))
    local target_level = _toint(getbaseinfo(target, ConstCfg.gbase.level))
    local gap = 0
    if cur_key == "lianmin" then
        gap = _calc_gap_bonus(cur_cfg, my_level, target_level, "lower")
    else
        gap = _calc_gap_bonus(cur_cfg, my_level, target_level, "higher")
    end
    if gap <= 0 then
        return damage
    end
    return math.floor(_toint(damage) * (100 + gap) / 100)
end

-- 受击方伤害修正，并更新临时状态。
function weapon_personality_struck_adjust(play, damage, hiter, magicid)
    if not play or _toint(damage) <= 0 then
        return damage
    end
    local data = _prepare_state(play, false)
    local cur_cfg = _personality_cfg(data.personality)
    local cur_key = tostring(cur_cfg.key or "")

    if cur_key == "lumang" and hiter and getbaseinfo(hiter, ConstCfg.gbase.isplayer) then
        local my_level = _toint(getbaseinfo(play, ConstCfg.gbase.level))
        local target_level = _toint(getbaseinfo(hiter, ConstCfg.gbase.level))
        local gap = _calc_gap_bonus(cur_cfg, my_level, target_level, "higher")
        if gap > 0 then
            _set_temp_relation(play, data, "lumang", gap)
        else
            _clear_temp_relation(play, data, "lumang")
        end
    end

    if cur_key == "baonu" then
        -- 暴怒满层时额外承伤 5%。
        local layer = (data.kill_player_expire > _now()) and _toint(data.kill_player_layer) or 0
        if layer >= _toint(cur_cfg.layer_max or 5) then
            return math.floor(_toint(damage) * (100 + _toint(cur_cfg.full_hurt_more or 5)) / 100)
        end
    end
    return damage
end

-- 登录时刷新每日状态。
local function _on_login(play)
    _prepare_state(play, false)
end

-- 跨天刷新时强制重新抽取当日性格。
local function _on_daily(play)
    _prepare_state(play, true)
end

-- 切换地图时清理地图绑定状态。
local function _on_switch_map(play)
    local data = _prepare_state(play, false)
    local cur_cfg = _personality_cfg(data.personality)
    if tostring(cur_cfg.key or "") == "shixue" then
        local cur_map = _current_map(play)
        if data.same_map ~= "" and data.same_map ~= cur_map then
            data.same_map = ""
            data.same_map_kill = 0
            _save_data(play, data)
            _refresh_attrs(play, data)
        end
    end
    _clear_temp_relation(play, data, "")
end

-- 玩家击杀玩家时叠加暴怒性格层数。
local function _on_kill_play(play, target)
    local data = _prepare_state(play, false)
    local cur_cfg = _personality_cfg(data.personality)
    if tostring(cur_cfg.key or "") ~= "baonu" then
        return
    end
    local now = _now()
    if data.kill_player_expire <= now then
        data.kill_player_layer = 0
    end
    data.kill_player_layer = math.min(_toint(cur_cfg.layer_max or 5), _toint(data.kill_player_layer) + 1)
    data.kill_player_expire = now + math.max(1, _toint(cur_cfg.layer_keep_sec or 300))
    _save_data(play, data)
    _refresh_attrs(play, data)
    _schedule_tick(play, data)
end

-- 击杀怪物时更新嗜血与贪婪性格进度。
local function _on_kill_mon(play, mob)
    if not play or not mob then
        return
    end
    local data = _prepare_state(play, false)
    local cur_cfg = _personality_cfg(data.personality)
    local cur_key = tostring(cur_cfg.key or "")
    local cur_map = _current_map(play)

    if cur_key == "shixue" then
        if data.same_map == cur_map then
            data.same_map_kill = _toint(data.same_map_kill) + 1
        else
            data.same_map = cur_map
            data.same_map_kill = 1
        end
        _save_data(play, data)
        _refresh_attrs(play, data)
    elseif cur_key == "tanlan" then
        if _toint(daluditu and daluditu[cur_map]) == _toint(cur_cfg.continent or 6) then
            local add_gold = _pick_greed_gold(cur_cfg)
            if add_gold > 0 then
                data.greed_gold = _toint(data.greed_gold) + add_gold
                _save_data(play, data)
                changemoney(play, _toint(cur_cfg.money_id or 3), "+", add_gold, tostring(cur_cfg.money_reason or "武器性格"), true)
            end
        end
    end
end

-- 攻击其他玩家时更新临时等级差状态。
local function _on_attack_damage_player(play, target)
    if not play or not target then
        return
    end
    local data = _prepare_state(play, false)
    local cur_cfg = _personality_cfg(data.personality)
    local cur_key = tostring(cur_cfg.key or "")
    local my_level = _toint(getbaseinfo(play, ConstCfg.gbase.level))
    local target_level = _toint(getbaseinfo(target, ConstCfg.gbase.level))

    if cur_key == "lianmin" then
        local gap = _calc_gap_bonus(cur_cfg, my_level, target_level, "lower")
        if gap > 0 then
            _set_temp_relation(play, data, "lianmin", gap)
        else
            _clear_temp_relation(play, data, "lianmin")
        end
    elseif cur_key == "lumang" then
        local gap = _calc_gap_bonus(cur_cfg, my_level, target_level, "higher")
        if gap > 0 then
            _set_temp_relation(play, data, "lumang", gap)
        else
            _clear_temp_relation(play, data, "lumang")
        end
    end
end

GameEvent.add(EventCfg.onLogin, _on_login, "武器性格")
GameEvent.add(EventCfg.goDailyUpdate, _on_daily, "武器性格")
GameEvent.add(EventCfg.goSwitchMap, _on_switch_map, "武器性格")
GameEvent.add(EventCfg.onkillplay, _on_kill_play, "武器性格")
GameEvent.add(EventCfg.onKillMon, _on_kill_mon, "武器性格")
GameEvent.add(EventCfg.onAttackDamagePlayer, _on_attack_damage_player, "武器性格")

return npc

