npc = {}

-- 血契之门：处理签订、进入、额外掉落与死亡掉装规则。
local _config = Guard.getConfig("npc_81")
local _var_name = VarCfg["T_血契之门"] or "T67"
local _drop_pending_var = "N$血契之门掉落补发"
local _notice_state_var = VarCfg["A_血契之门公告"] or "A11"
local _equip_slots = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,40,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88}

-- 统一处理可能为空的数值。
local function _toint(v)
    return tonumber(v) or 0
end

-- 读取可配置文案，缺省时使用默认值。
local function _safe_text(key, default_text)
    local texts = (_config and _config.texts) or {}
    local value = texts[key]
    if type(value) == "string" and value ~= "" then
        return value
    end
    return default_text or ""
end

-- 读取并规范化玩家血契存档数据。
local function _get_data(play)
    local data = Player.getJsonTableByVar(play, _var_name) or {}
    data.contract = _toint(data.contract)
    data.enter_count = _toint(data.enter_count)
    data.last_enter = _toint(data.last_enter)
    data.drop_kill = _toint(data.drop_kill)
    data.drop_death = _toint(data.drop_death)
    return data
end

-- 持久化玩家血契存档数据。
local function _save_data(play, data)
    Player.setJsonVarByTable(play, _var_name, data)
end

-- 在同一处完成血契数据的读取、修改与保存。
local function _touch_data(play, func)
    local data = _get_data(play)
    if func then
        func(data)
    end
    _save_data(play, data)
    return data
end

-- 收集所有计入血契玩法的地图。
local function _collect_maps()
    local maps = {}
    local function _push(map_name)
        if type(map_name) ~= "string" or map_name == "" then
            return
        end
        for _, one in ipairs(maps) do
            if one == map_name then
                return
            end
        end
        maps[#maps + 1] = map_name
    end
    _push(_config.enter_map)
    for _, one in ipairs(_config.maps or {}) do
        _push(one)
    end
    return maps
end

-- 检查指定地图是否属于血契区域。
local function _is_contract_map(map_name)
    map_name = tostring(map_name or "")
    if map_name == "" then
        return false
    end
    for _, one in ipairs(_collect_maps()) do
        if one == map_name then
            return true
        end
    end
    return false
end

-- 将小时与分钟换算为当天的分钟数。
local function _time_to_minute(hour, minute)
    return (_toint(hour) * 60) + _toint(minute)
end

-- 将单条开放时段配置格式化为界面展示文本。
local function _period_to_desc(period)
    local start = period.start or {}
    local finish = period.finish or {}
    return string.format("%02d:%02d-%02d:%02d", _toint(start[1]), _toint(start[2]), _toint(finish[1]), _toint(finish[2]))
end

-- 检查血契之门当前是否处于开放状态。
local function _is_open_now()
    local periods = (_config and _config.open_periods) or {}
    if #periods <= 0 then
        return true
    end
    local now = os.date("*t")
    local cur = _time_to_minute(now.hour, now.min)
    for _, period in ipairs(periods) do
        local start = period.start or {}
        local finish = period.finish or {}
        local start_min = _time_to_minute(start[1], start[2])
        local end_min = _time_to_minute(finish[1], finish[2])
        if start_min == end_min then
            return true
        end
        if start_min < end_min then
            if cur >= start_min and cur < end_min then
                return true
            end
        else
            if cur >= start_min or cur < end_min then
                return true
            end
        end
    end
    return false
end

-- 组装面板使用的开放时间描述。
local function _build_open_desc()
    local periods = (_config and _config.open_periods) or {}
    if #periods <= 0 then
        return _safe_text("open_always", "")
    end
    local ret = {}
    for _, period in ipairs(periods) do
        ret[#ret + 1] = _period_to_desc(period)
    end
    return table.concat(ret, " / ")
end

-- 检查玩家是否满足所需称号门槛。
local function _has_need_title(play)
    local need_title = tostring((_config and _config.need_title) or "")
    if need_title == "" then
        return true
    end
    return checktitle(play, need_title)
end

-- 激活状态表示已签订且当前位于血契地图内。
local function _is_contract_active(play)
    if play == nil then
        return false
    end
    local data = _get_data(play)
    if data.contract ~= 1 then
        return false
    end
    return _is_contract_map(getbaseinfo(play, 3))
end

-- 组装血契面板下发给客户端的数据。
local function _build_payload(play)
    local data = _get_data(play)
    local open_now = _is_open_now() and 1 or 0
    local has_title = _has_need_title(play) and 1 or 0
    return {
        T_data = data,
        config = _config,
        contract = data.contract,
        enter_count = data.enter_count,
        drop_kill = data.drop_kill,
        drop_death = data.drop_death,
        is_open = open_now,
        open_desc = _build_open_desc(),
        has_title = has_title,
        in_map = _is_contract_map(getbaseinfo(play, 3)) and 1 or 0,
        can_enter = (open_now == 1 and has_title == 1 and data.contract == 1) and 1 or 0,
    }
end

-- 将最新面板数据推送给客户端。
local function _refresh_panel(play, npcid, ew, aid)
    sendluamsg(play, 100, npcid, ew or 0, aid or 0, tbl2json(_build_payload(play)))
end

-- 传送玩家进入配置的血契地图。
local function _enter_map(play)
    local target_map = tostring((_config and _config.enter_map) or "")
    local pos = (_config and _config.enter_pos) or {}
    local x = _toint(pos[1])
    local y = _toint(pos[2])
    if target_map == "" or x <= 0 or y <= 0 then
        Player.sendmsgEx(play, _safe_text("map_error", ""))
        return false
    end
    mapmove(play, target_map, x, y, 2)
    return true
end

-- 生成按分钟区分的键，避免重复广播开放提示。
local function _get_notice_bucket()
    local now = os.date("*t")
    return string.format("%04d%02d%02d%02d%02d", now.year, now.month, now.day, now.hour, now.min)
end

-- 检查当前分钟是否命中某个开放起点。
local function _is_notice_time(period)
    local start = period.start or {}
    local now = os.date("*t")
    return _toint(now.hour) == _toint(start[1]) and _toint(now.min) == _toint(start[2])
end

-- 向全服广播血契开放提示。
local function _roll_notice(msg)
    if msg == "" then
        return
    end
    sendmovemsg("0", 1, 253, 0, 300, 1, msg)
    sendmovemsg("0", 1, 249, 0, 250, 1, msg)
end

-- 定时入口：每个命中的分钟只广播一次开放提示。
function npc.roll_open_notice()
    local periods = (_config and _config.open_periods) or {}
    if #periods <= 0 then
        return false
    end
    local bucket = _get_notice_bucket()
    local state = tostring(getsysvar(_notice_state_var) or "")
    if state == bucket then
        return false
    end
    for _, period in ipairs(periods) do
        if _is_notice_time(period) then
            _roll_notice(tostring(_config.notice or ""))
            setsysvar(_notice_state_var, bucket)
            return true
        end
    end
    return false
end

-- 统计击杀时额外获得的血契掉落次数。
local function _touch_drop_kill(play)
    _touch_data(play, function(data)
        data.drop_kill = _toint(data.drop_kill) + 1
    end)
end

-- 统计血契死亡时触发的装备掉落次数。
local function _touch_drop_death(play)
    _touch_data(play, function(data)
        data.drop_death = _toint(data.drop_death) + 1
    end)
end

-- 将物品对象解析为展示名称。
local function _drop_name_from_obj(play, itemobj)
    if not itemobj or itemobj == "0" then
        return ""
    end
    return tostring(getiteminfo(play, itemobj, 7) or "")
end

-- 血契掉装只对非绑定装备生效。
local function _is_item_bound(itemobj)
    if not itemobj or itemobj == "0" then
        return true
    end
    if _toint(getitemaddvalue("0", itemobj, 2, 1)) ~= 0 then
        return true
    end
    local bind_state = _toint(getiteminfo("0", itemobj, 6))
    if bind_state ~= 0 then
        return true
    end
    for bind_type = 0, 8 do
        if checkitemstate(itemobj, bind_type) then
            return true
        end
    end
    return false
end

-- 随机选取一件允许掉落的已穿戴装备。
local function _pick_drop_equip(play)
    local equip_list = {}
    for _, where in ipairs(_equip_slots) do
        local itemobj = linkbodyitem(play, where)
        if itemobj and itemobj ~= "0" and not _is_item_bound(itemobj) then
            local name = _drop_name_from_obj(play, itemobj)
            if name ~= "" then
                equip_list[#equip_list + 1] = {where = where, item = itemobj, name = name}
            end
        end
    end
    if #equip_list <= 0 then
        return nil
    end
    return equip_list[math.random(#equip_list)]
end

-- 血契死亡时将一件穿戴装备掉落到地面。
local function _drop_one_equip(play)
    local info = _pick_drop_equip(play)
    if not info then
        return false
    end
    local makeindex = tostring(getiteminfo(play, info.item, 1) or "")
    local name = tostring(info.name or "")
    if makeindex == "" or name == "" then
        return false
    end
    local map_name = tostring(getbaseinfo(play, 3) or "")
    local x = _toint(getbaseinfo(play, 4))
    local y = _toint(getbaseinfo(play, 5))
    if map_name == "" or x <= 0 or y <= 0 then
        return false
    end
    local death_cfg = ((_config or {}).death or {})
    local drop_range = math.max(1, _toint(death_cfg.range))
    local keep_sec = math.max(60, _toint(death_cfg.keep_sec))
    local source = tostring(death_cfg.source or "血契之门")
    local owner = _toint(death_cfg.owner)
    local item_json = tostring(getitemjson(info.item) or "")
    local drop_ok = false
    if item_json ~= "" then
        local ret = gendropitem(map_name, play, x, y, item_json, source, drop_range, owner)
        if type(ret) == "table" and next(ret) ~= nil then
            drop_ok = true
        end
    end
    if not drop_ok then
        throwitem(play, map_name, x, y, drop_range, name, 1, keep_sec, true, true, false, false)
    end
    delitembymakeindex(play, makeindex, 1, "血契之门死亡掉落")
    setplaydef(play, VarCfg.Die_Drop_item, name)
    _touch_drop_death(play)
    Player.sendmsgEx(play, string.format("血契生效，你掉落了#57|【%s】#218|", name))
    return true
end

-- 打开血契之门面板。
function npc.main(play, npcid)
    _refresh_panel(play, npcid, 0, 0)
end

-- 处理签订、进入与刷新操作。
function npc.link(play, npcid, p2, p3, msgData)
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local action = Guard.normalizeAction(play, npcid, p2)
    if action == nil then
        return
    end
    p2 = action
    local allowed = Guard.newActionSet({1,2,9})
    if not Guard.ensureActionAllowed(play, npcid, p2, allowed) then
        return
    end

    local data = _get_data(play)

    if p2 == 1 then
        if data.contract == 1 then
            Player.sendmsgEx(play, _safe_text("signed", ""))
            _refresh_panel(play, npcid, 1, 0)
            return
        end
        data.contract = 1
        _save_data(play, data)
        Player.sendmsgEx(play, _safe_text("sign_success", ""))
        _refresh_panel(play, npcid, 1, 0)
        return
    end

    if p2 == 2 then
        if not _has_need_title(play) then
            Player.sendmsgEx(play, _safe_text("need_title", ""))
            return
        end
        if data.contract ~= 1 then
            Player.sendmsgEx(play, _safe_text("need_contract", ""))
            return
        end
        if not _is_open_now() then
            Player.sendmsgEx(play, _safe_text("not_open", ""))
            return
        end
        if _enter_map(play) then
            data.enter_count = data.enter_count + 1
            data.last_enter = os.time()
            _save_data(play, data)
            Player.sendmsgEx(play, _safe_text("enter_success", ""))
        end
        return
    end

    _refresh_panel(play, npcid, p2, _toint(p3))
end

-- 复制原始掉落，用于实现额外掉落次数。
local function _duplicate_drop(play, mob, name, extra)
    if extra <= 0 or name == "" then
        return
    end
    setplaydef(play, _drop_pending_var, extra)
    for _ = 1, extra do
        shaguai.temp_drop(play, mob, name)
    end
end

-- 挂接怪物掉落，在血契地图内复制额外掉落。
local function _on_mon_drop(play, drop_item, mon)
    if play == nil or mon == nil then
        return
    end
    if not _is_contract_active(play) then
        return
    end
    local item_name = _drop_name_from_obj(play, drop_item)
    if item_name == "" then
        return
    end
    local pending = _toint(getplaydef(play, _drop_pending_var))
    if pending > 0 then
        setplaydef(play, _drop_pending_var, pending - 1)
        return
    end
    local mon_name = tostring(getbaseinfo(mon, 1) or "")
    local mon_type = _toint((guaiwutype or {})[mon_name])
    local drop_cfg = (_config and _config.drop) or {}
    local extra = mon_type >= 2 and _toint(drop_cfg.boss_extra) or _toint(drop_cfg.normal_extra)
    _duplicate_drop(play, mon, item_name, extra)
end

-- 为普通怪物额外预览物掉落进行一次判定。
local function _try_extra_small_drop(play, mob)
    local extra_cfg = ((_config or {}).extra_drop or {})
    local item = tostring(extra_cfg.item or "")
    local rate = _toint(extra_cfg.rate)
    if item == "" or rate <= 0 then
        return
    end
    local mon_name = tostring(getbaseinfo(mob, 1) or "")
    local mon_type = _toint((guaiwutype or {})[mon_name])
    if mon_type >= 2 then
        return
    end
    if math.random(rate) == 1 and shaguai.temp_drop(play, mob, item) then
        _touch_drop_kill(play)
        Player.sendmsgEx(play, "血契额外掉落#57|【" .. item .. "】#218|")
    end
end

-- 击杀后尝试追加小怪额外掉落。
local function _on_kill_mon(play, mob)
    if play == nil or mob == nil then
        return
    end
    if not _is_contract_active(play) then
        return
    end
    _try_extra_small_drop(play, mob)
end
npc.onKillMon = _on_kill_mon

-- 玩家处于血契状态死亡时触发掉装。
local function _on_play_die(play)
    if not _is_contract_active(play) then
        return
    end
    _drop_one_equip(play)
end

GameEvent.add(EventCfg.onMondropItemex, _on_mon_drop, "血契之门")
GameEvent.add(EventCfg.onPlaydie, _on_play_die, "血契之门")

return npc

