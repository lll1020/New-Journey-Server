npc = {}

-- 星象圣图：管理阶段解锁、节点进度、被动属性与战斗技能。
local _config = Guard.getConfig("npc_85")
local _var_name = VarCfg["T_星象圣图"]
local _attr_list_name = (_config and _config.attr_list_name) or "星象圣图"
local _skill_bonus_var = "N$星象圣图技能加成"
local _combat_until_var = "N$星象圣图战斗截止"
local _heal_timer_flag = "N$星象圣图回血计时"
local _mang_cd_var = "N$星象圣图星芒CD"
local _burst_cd_var = "N$星象圣图爆发CD"
local _burst_end_var = "N$星象圣图爆发结束"
local _burst_speed_var = "N$星象圣图爆发攻速"
local _domain_cd_var = "N$星象圣图领域CD"
local _domain_end_var = "N$星象圣图领域结束"
local _domain_pct_var = "N$星象圣图领域加成"
local _domain_reduce_var = "N$星象圣图领域减伤"
local _emperor_cd_var = "N$星象圣图帝星CD"
local _emperor_end_var = "N$星象圣图帝星结束"
local _huti_end_var = "N$星象圣图护体结束"
local _burst_attr_list = "星象圣图_星力爆发"
local _emperor_attr_list = "星象圣图_帝星降世"
local _domain_attr_list = "星象圣图_星象领域"
local _all_percent_ids = {280,281,282,283,284,285,286,287,288,289,290,291,300}
local _attack_buff = tonumber((((_config or {}).buff or {}).attack) or 0) or 0
local _struck_buff = tonumber((((_config or {}).buff or {}).struck) or 0) or 0
if _attack_buff <= 0 then _attack_buff = 561 end
if _struck_buff <= 0 then _struck_buff = 562 end

-- 统一处理可能为空的数值。
local function _toint(v)
    return tonumber(v) or 0
end

-- 统一维护攻击/受击触发 Buff 的标记数据。
local function _json_toggle_var(play, varName, buffId, enable)
    local bl = getplaydef(play, varName)
    local data = json2tbl(bl == "" and {} or bl)
    if enable then
        data[tostring(buffId)] = true
    else
        data[tostring(buffId)] = nil
    end
    setplaydef(play, varName, tbl2json(data))
end

-- 收集单个材料或奖励条目的所有别名。
local function _collect_names(entry)
    local names = {}
    local function _push(name)
        if type(name) ~= "string" or name == "" then
            return
        end
        for _, v in ipairs(names) do
            if v == name then
                return
            end
        end
        table.insert(names, name)
    end
    if type(entry) == "table" then
        if type(entry.name) == "table" then
            for _, name in ipairs(entry.name) do
                _push(name)
            end
        else
            _push(entry.name or entry[1])
        end
        for _, name in ipairs(entry.alias or {}) do
            _push(name)
        end
    end
    return names
end

-- 读取单个条目的配置数量。
local function _entry_num(entry)
    if type(entry) ~= "table" then
        return 0
    end
    return _toint(entry.num or entry[2])
end

-- 获取单个条目的展示名称，用于界面提示。
local function _entry_display(entry)
    local names = _collect_names(entry)
    return names[1] or "未知材料"
end

-- 统计玩家当前拥有的数量，兼容别名与货币。
local function _entry_total(play, entry)
    local need = _entry_num(entry)
    if need <= 0 then
        return 0
    end
    local names = _collect_names(entry)
    if #names == 0 then
        return 0
    end
    local idx = _toint(getstditeminfo(names[1], 0))
    if idx > 0 and Item.isCurrency(idx) then
        return _toint(Player.getMoneyNum(play, idx))
    end
    local total = 0
    for _, name in ipairs(names) do
        total = total + _toint(getbagitemcount(play, name))
    end
    return total
end

-- 返回某组消耗中第一个不足的材料。
local function _check_costs(play, cost)
    for _, entry in ipairs(cost or {}) do
        local need = _entry_num(entry)
        if need > 0 and _entry_total(play, entry) < need then
            return _entry_display(entry), need
        end
    end
end

-- 从背包物品或货币中扣除一组消耗。
local function _take_costs(play, cost, reason)
    for _, entry in ipairs(cost or {}) do
        local need = _entry_num(entry)
        if need > 0 then
            local names = _collect_names(entry)
            local idx = _toint(getstditeminfo(names[1] or "", 0))
            if idx > 0 and Item.isCurrency(idx) then
                Player.takeItemByTable(play, {{names[1], need}}, reason, nil)
            else
                local remain = need
                local temp = {}
                for _, name in ipairs(names) do
                    temp[#temp + 1] = {name = name, num = _toint(getbagitemcount(play, name))}
                end
                table.sort(temp, function(a, b)
                    return (a.num or 0) > (b.num or 0)
                end)
                for _, info in ipairs(temp) do
                    if remain <= 0 then
                        break
                    end
                    local take_num = math.min(remain, info.num or 0)
                    if take_num > 0 then
                        takeitem(play, info.name, take_num)
                        remain = remain - take_num
                    end
                end
            end
        end
    end
end

-- 从别名列表中选出可发放的奖励名称。
local function _resolve_reward_name(entry)
    local names = _collect_names(entry)
    for _, name in ipairs(names) do
        if _toint(getstditeminfo(name, 0)) > 0 then
            return name
        end
    end
    return names[1] or ""
end

-- 发放一组材料奖励包。
local function _grant_pack(play, pack, reason)
    local reward = {}
    for _, entry in ipairs(pack or {}) do
        local name = _resolve_reward_name(entry)
        local num = _entry_num(entry)
        if name ~= "" and num > 0 then
            reward[#reward + 1] = {name, num}
        end
    end
    if #reward > 0 then
        Player.rwjl(play, reward, reason, 1, 0)
    end
end

-- 读取并规范化星象圣图存档数据。
local function _get_data(play)
    local data = Player.getJsonTableByVar(play, _var_name) or {}
    data.stage = data.stage or {}
    for i = 1, #(_config.stages or {}) do
        local key = tostring(i)
        local info = data.stage[key] or {}
        info.unlock = _toint(info.unlock)
        info.full = _toint(info.full)
        info.reward = _toint(info.reward)
        info.nodes = info.nodes or {}
        for node_idx = 1, #(((_config.stages or {})[i] or {}).nodes or {}) do
            local node_key = tostring(node_idx)
            info.nodes[node_key] = _toint(info.nodes[node_key])
        end
        data.stage[key] = info
    end
    return data
end

-- 持久化星象圣图存档数据。
local function _save_data(play, data)
    Player.setJsonVarByTable(play, _var_name, data)
end

-- 统计单个阶段已点亮的节点数量。
local function _count_nodes(stage_data, stage_cfg)
    local count = 0
    for node_idx = 1, #(stage_cfg.nodes or {}) do
        if _toint((stage_data.nodes or {})[tostring(node_idx)]) == 1 then
            count = count + 1
        end
    end
    return count
end

-- 按顺序统计已完整完成的阶段数量。
local function _full_stage_count(data)
    local count = 0
    for i = 1, #(_config.stages or {}) do
        local info = data.stage[tostring(i)] or {}
        if _toint(info.full) == 1 then
            count = count + 1
        else
            break
        end
    end
    return count
end

-- 判定当前允许推进的阶段。
local function _current_stage(data)
    local idx = _full_stage_count(data) + 1
    if idx < 1 then idx = 1 end
    if idx > #(_config.stages or {}) then idx = #(_config.stages or {}) end
    return idx
end

-- 根据已完成阶段数读取当前生效的技能包。
local function _get_skill_cfg(data)
    return ((_config.stage_skill or {})[_full_stage_count(data)] or {})
end

-- 将单条属性累加到合并属性表中。
local function _add_attr(attrs, attr_id, value)
    attr_id = _toint(attr_id)
    value = _toint(value)
    if attr_id > 0 and value ~= 0 then
        attrs[attr_id] = (attrs[attr_id] or 0) + value
    end
end

-- 合并所有已激活节点的属性与仙法加成。
local function _collect_attrs_and_bonus(data)
    local attrs = {}
    local skill_bonus = 0
    for stage_idx, stage_cfg in ipairs(_config.stages or {}) do
        local stage_data = data.stage[tostring(stage_idx)] or {}
        for node_idx, node_cfg in ipairs(stage_cfg.nodes or {}) do
            if _toint((stage_data.nodes or {})[tostring(node_idx)]) == 1 then
                for _, attr in ipairs(node_cfg.attr or {}) do
                    _add_attr(attrs, attr[1], attr[2])
                end
                skill_bonus = skill_bonus + _toint(node_cfg.skill_bonus)
            end
        end
    end
    return attrs, skill_bonus
end

-- 当没有通用刷新入口时，直接回写仙法倍率。
local function _apply_skill_bonus_direct(play, bonus)
    local skill_data = Player.getJsonTableByVar(play, VarCfg["T_技能升级"]) or {}
    skill_data.level = skill_data.level or {}
    for i, v in ipairs(VarCfg.N_jnsh) do
        local base = _toint(skill_data.level[""..i]) * 2
        setplaydef(play, v, base + bonus)
    end
    if Login_jnsh then
        Login_jnsh(play)
    end
end

-- 对外接口：向其他系统提供星图仙法加成。
function star_chart_skill_bonus_get(play)
    return _toint(getplaydef(play, _skill_bonus_var))
end

-- 组装帝星与领域效果使用的全属性百分比字符串。
local function _build_all_pct_attr(percent, reduce)
    local attrs = {}
    for _, attr_id in ipairs(_all_percent_ids) do
        attrs[attr_id] = _toint(percent)
    end
    if _toint(reduce) > 0 then
        attrs[206] = _toint(reduce) * 100
    end
    return Player.getAttrTableToStr(attrs)
end

-- 检查帝星状态当前是否仍然生效。
local function _is_emperor_active(play)
    return _toint(getplaydef(play, _emperor_end_var)) > os.time()
end

-- 刷新爆发攻速属性列表。
local function _refresh_burst_attr(play)
    local now = os.time()
    local end_time = _toint(getplaydef(play, _burst_end_var))
    if end_time > now then
        local speed = _toint(getplaydef(play, _burst_speed_var))
        if _is_emperor_active(play) then
            speed = speed * 2
        end
        if speed > 0 then
            Player.add_attlist(play, _burst_attr_list, "=", "3#200#" .. speed .. "|3#201#" .. speed, 1)
            return
        end
    end
    Player.del_attlist(play, _burst_attr_list)
end

-- 刷新帝星全属性百分比属性列表。
local function _refresh_emperor_attr(play)
    if _is_emperor_active(play) then
        Player.add_attlist(play, _emperor_attr_list, "=", _build_all_pct_attr(30, 0), 1)
    else
        Player.del_attlist(play, _emperor_attr_list)
    end
end

-- 刷新某个目标玩家的领域加成。
local function _refresh_domain_target(play)
    local now = os.time()
    local end_time = _toint(getplaydef(play, _domain_end_var))
    if end_time > now then
        local pct = _toint(getplaydef(play, _domain_pct_var))
        local reduce = _toint(getplaydef(play, _domain_reduce_var))
        if pct > 0 then
            Player.add_attlist(play, _domain_attr_list, "=", _build_all_pct_attr(pct, reduce), 1)
            return
        end
    end
    Player.del_attlist(play, _domain_attr_list)
    setplaydef(play, _domain_pct_var, 0)
    setplaydef(play, _domain_reduce_var, 0)
end

-- 爆发持续时间清理的定时入口。
function star_chart_burst_tick(play)
    _refresh_burst_attr(play)
    local remain = _toint(getplaydef(play, _burst_end_var)) - os.time()
    if remain > 0 then
        delaygoto(play, math.max(1000, remain * 1000), "@star_chart_burst_tick")
    end
end

-- 帝星持续时间清理的定时入口。
function star_chart_emperor_tick(play)
    _refresh_emperor_attr(play)
    _refresh_burst_attr(play)
    local remain = _toint(getplaydef(play, _emperor_end_var)) - os.time()
    if remain > 0 then
        delaygoto(play, math.max(1000, remain * 1000), "@star_chart_emperor_tick")
    end
end

-- 领域持续时间清理的定时入口。
function star_chart_domain_tick(play)
    _refresh_domain_target(play)
    local remain = _toint(getplaydef(play, _domain_end_var)) - os.time()
    if remain > 0 then
        delaygoto(play, math.max(1000, remain * 1000), "@star_chart_domain_tick")
    end
end

-- 记录战斗时间，并在需要时启动回血跳。
local function _mark_combat(play, skill_cfg)
    setplaydef(play, _combat_until_var, os.time() + 3)
    if skill_cfg and skill_cfg.heal and _toint(getplaydef(play, _heal_timer_flag)) ~= 1 then
        setplaydef(play, _heal_timer_flag, 1)
        delaygoto(play, 1000, "@star_chart_heal_tick")
    end
end

-- 相关技能生效时，在战斗中按跳回血。
function star_chart_heal_tick(play)
    local data = _get_data(play)
    local skill_cfg = _get_skill_cfg(data)
    if not skill_cfg.heal then
        setplaydef(play, _heal_timer_flag, 0)
        return
    end
    if _toint(getplaydef(play, _combat_until_var)) <= os.time() then
        setplaydef(play, _heal_timer_flag, 0)
        return
    end
    local heal = _toint(skill_cfg.heal.value)
    if _is_emperor_active(play) then
        heal = heal * 2
    end
    if heal > 0 then
        humanhp(play, "+", heal, 5, 0, play)
    end
    delaygoto(play, 1000, "@star_chart_heal_tick")
end

-- 对单个队友目标施加领域加成。
local function _apply_domain_to_target(target, percent, reduce, duration)
    if not target then
        return
    end
    local now = os.time()
    setplaydef(target, _domain_end_var, now + duration)
    setplaydef(target, _domain_pct_var, percent)
    setplaydef(target, _domain_reduce_var, reduce)
    _refresh_domain_target(target)
    delaygoto(target, math.max(1000, duration * 1000), "@star_chart_domain_tick")
end

-- 收集领域效果范围内的附近队友。
local function _get_group_targets(play, range)
    local list = {}
    local group = getgroupmember(play) or {}
    local map_id = getbaseinfo(play, 3)
    local x = _toint(getbaseinfo(play, 4))
    local y = _toint(getbaseinfo(play, 5))
    range = math.max(0, math.floor(_toint(range) / 2))
    for _, member in ipairs(group) do
        if member and member ~= play and getbaseinfo(member, 3) == map_id then
            local mx = _toint(getbaseinfo(member, 4))
            local my = _toint(getbaseinfo(member, 5))
            if math.abs(mx - x) <= range and math.abs(my - y) <= range then
                table.insert(list, member)
            end
        end
    end
    return list
end

-- 攻击触发入口：处理芒、爆发、领域与帝星逻辑。
function star_chart_attack_trigger(play, Damage, Target, MagicId, Model)
    local data = _get_data(play)
    local skill_cfg = _get_skill_cfg(data)
    if next(skill_cfg) == nil then
        return 0
    end
    _mark_combat(play, skill_cfg)

    local now = os.time()
    if skill_cfg.emperor and now - _toint(getplaydef(play, _emperor_cd_var)) >= _toint(skill_cfg.emperor.cd) then
        setplaydef(play, _emperor_cd_var, now)
        setplaydef(play, _emperor_end_var, now + _toint(skill_cfg.emperor.duration))
        _refresh_emperor_attr(play)
        _refresh_burst_attr(play)
        delaygoto(play, math.max(1000, _toint(skill_cfg.emperor.duration) * 1000), "@star_chart_emperor_tick")
    end

    local emperor_active = _is_emperor_active(play)

    if skill_cfg.burst and now - _toint(getplaydef(play, _burst_cd_var)) >= _toint(skill_cfg.burst.cd) then
        setplaydef(play, _burst_cd_var, now)
        setplaydef(play, _burst_end_var, now + _toint(skill_cfg.burst.duration))
        setplaydef(play, _burst_speed_var, _toint(skill_cfg.burst.speed))
        _refresh_burst_attr(play)
        delaygoto(play, math.max(1000, _toint(skill_cfg.burst.duration) * 1000), "@star_chart_burst_tick")
    end

    if skill_cfg.domain and now - _toint(getplaydef(play, _domain_cd_var)) >= _toint(skill_cfg.domain.cd) then
        setplaydef(play, _domain_cd_var, now)
        local percent = _toint(skill_cfg.domain.all_pct)
        local reduce = _toint(skill_cfg.domain.reduce)
        if emperor_active then
            percent = percent * 2
            reduce = reduce * 2
        end
        for _, member in ipairs(_get_group_targets(play, _toint(skill_cfg.domain.range))) do
            _apply_domain_to_target(member, percent, reduce, _toint(skill_cfg.domain.duration))
        end
    end

    if skill_cfg.mang and Target then
        if now - _toint(getplaydef(play, _mang_cd_var)) >= _toint(skill_cfg.mang.cd) then
            setplaydef(play, _mang_cd_var, now)
            local extra = _toint(skill_cfg.mang.damage)
            if emperor_active then
                extra = extra * 2
            end
            return extra
        end
    end
    return 0
end

-- 受击触发入口：处理护盾与反弹逻辑。
function star_chart_struck_trigger(play, Damage, Hiter, MagicId)
    local data = _get_data(play)
    local skill_cfg = _get_skill_cfg(data)
    if next(skill_cfg) == nil then
        return 0
    end
    _mark_combat(play, skill_cfg)

    local now = os.time()
    local emperor_active = _is_emperor_active(play)
    local reduce_value = 0

    if skill_cfg.huti and Damage and Damage > 0 then
        local rate = _toint(skill_cfg.huti.rate)
        local reduce = _toint(skill_cfg.huti.reduce)
        if emperor_active then
            rate = rate * 2
            reduce = reduce * 2
        end
        local end_time = _toint(getplaydef(play, _huti_end_var))
        if end_time <= now and math.random(100) <= rate then
            end_time = now + _toint(skill_cfg.huti.duration)
            setplaydef(play, _huti_end_var, end_time)
        end
        if end_time > now and reduce > 0 then
            reduce_value = reduce_value + math.floor(_toint(Damage) * reduce / 100)
        end
    end

    if skill_cfg.fan and Hiter and Damage and Damage > 0 then
        local rate = _toint(skill_cfg.fan.rate)
        local reflect = _toint(skill_cfg.fan.reflect)
        if emperor_active then
            rate = rate * 2
            reflect = reflect * 2
        end
        if math.random(100) <= rate then
            humanhp(Hiter, "-", math.floor(_toint(Damage) * reflect / 100), 110, 0, play, 1)
        end
    end
    return reduce_value
end

-- 发放某个阶段完整完成后的阶段奖励。
local function _grant_stage_reward(play, stage_cfg)
    if not stage_cfg or not stage_cfg.reward then
        return
    end
    local reward = stage_cfg.reward
    if reward.type == "title" then
        Player.title_give(play, reward.name)
    else
        _grant_pack(play, reward.give, "星象圣图")
    end
end

-- 重建属性、仙法加成与触发 Buff 开关。
function star_chart_refresh(play)
    local data = _get_data(play)
    local attrs, skill_bonus = _collect_attrs_and_bonus(data)

    Player.del_attlist(play, _attr_list_name)
    local attr_str = Player.getAttrTableToStr(attrs)
    if attr_str and attr_str ~= "" then
        Player.add_attlist(play, _attr_list_name, "=", attr_str, 1)
    end

    setplaydef(play, _skill_bonus_var, skill_bonus)
    if xianfa_refresh then
        xianfa_refresh(play)
    else
        _apply_skill_bonus_direct(play, skill_bonus)
    end

    local skill_cfg = _get_skill_cfg(data)
    local need_attack = (skill_cfg.heal or skill_cfg.mang or skill_cfg.burst or skill_cfg.domain or skill_cfg.emperor) and true or false
    local need_struck = (skill_cfg.heal or skill_cfg.huti or skill_cfg.fan) and true or false
    _json_toggle_var(play, VarCfg.S_buffgjq, _attack_buff, need_attack)
    _json_toggle_var(play, VarCfg.S_buffbgjq, _struck_buff, need_struck)

    if not skill_cfg.heal or _toint(getplaydef(play, _combat_until_var)) <= os.time() then
        setplaydef(play, _heal_timer_flag, 0)
    end

    _refresh_emperor_attr(play)
    _refresh_burst_attr(play)
    _refresh_domain_target(play)
end

-- 前三星用于开启星图之谜；三星完成后，完成天机道长对话3即可解锁后续星图。
local function _ensure_story_unlocked(play, data)
    if _full_stage_count(data) < 3 then
        return true
    end
    local story = Player.getJsonTableByVar(play, VarCfg.T_dljq) or {}
    if (tonumber(story["npc_721"]) or 0) >= 2 then
        return true
    end
    Player.sendmsgEx(play, "请先完成#57|【天机道长对话3】#218|后再继续提升星象圣图")
    return false
end
-- 组装星象圣图面板下发给客户端的数据。
local function _build_payload(play, data)
    return {
        T_data = data,
        cur_stage = _current_stage(data),
        full_stage = _full_stage_count(data),
        skill = _get_skill_cfg(data),
    }
end

-- 打开星象圣图面板。
function npc.main(play, npcid)
    local data = _get_data(play)
    if not _ensure_story_unlocked(play, data) then
        return
    end
    star_chart_refresh(play)
    sendluamsg(play, 100, npcid, 0, 0, tbl2json(_build_payload(play, data)))
    openhyperlink(play, 1, 2)
end

-- 处理阶段解锁与节点点亮操作。
function npc.link(play, npcid, p2, p3, msgData)
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local __guardAction = Guard.normalizeAction(play, npcid, p2)
    if __guardAction == nil then
        return
    end
    p2 = __guardAction
    local __guardAllowedActions = Guard.newActionSet({1, 2})
    if not Guard.ensureActionAllowed(play, npcid, p2, __guardAllowedActions) then
        return
    end

    local data = _get_data(play)
    local json_data = json2tbl(msgData) or {}
    if not _ensure_story_unlocked(play, data) then
        return
    end
    if p2 == 1 then
        local stage_idx = _toint(json_data.stage or json_data.idx)
        local stage_cfg = (_config.stages or {})[stage_idx]
        local stage_data = data.stage[tostring(stage_idx)] or {}
        if not stage_cfg then
            Player.sendmsgEx(play, "参数错误#57")
            return
        end
        if stage_idx ~= _current_stage(data) then
            Player.sendmsgEx(play, "请按顺序解锁当前星象阶段#57")
            return
        end
        if _toint(stage_data.unlock) == 1 then
            Player.sendmsgEx(play, "当前阶段已经解锁#57")
            return
        end
        local miss_name, miss_num = _check_costs(play, stage_cfg.unlock_cost or {})
        if miss_name then
            Player.sendmsgEx(play, "你的#57|【" .. miss_name .. "】#218|不足：#57|【" .. miss_num .. "】#218|")
            return
        end
        _take_costs(play, stage_cfg.unlock_cost or {}, ",星象圣图")
        stage_data.unlock = 1
        data.stage[tostring(stage_idx)] = stage_data
        _save_data(play, data)
        star_chart_refresh(play)
        Player.sendmsgEx(play, "你成功解锁了#57|【" .. (stage_cfg.name or "星象阶段") .. "】#218|")
        sendluamsg(play, 100, npcid, 1, 0, tbl2json(_build_payload(play, data)))
    elseif p2 == 2 then
        local stage_idx = _toint(json_data.stage)
        local node_idx = _toint(json_data.node or json_data.idx)
        local stage_cfg = (_config.stages or {})[stage_idx]
        local stage_data = data.stage[tostring(stage_idx)] or {}
        if not stage_cfg or not stage_cfg.nodes or not stage_cfg.nodes[node_idx] then
            Player.sendmsgEx(play, "参数错误#57")
            return
        end
        if stage_idx ~= _current_stage(data) then
            Player.sendmsgEx(play, "请先完成当前阶段后再点亮后续星宿#57")
            return
        end
        if _toint(stage_data.unlock) ~= 1 then
            Player.sendmsgEx(play, "请先解锁当前阶段#57")
            return
        end
        if _toint(stage_data.full) == 1 then
            Player.sendmsgEx(play, "当前阶段已经全部点亮#57")
            return
        end
        local next_node = _count_nodes(stage_data, stage_cfg) + 1
        if node_idx ~= next_node then
            Player.sendmsgEx(play, "请按顺序点亮当前阶段的星宿#57")
            return
        end
        local node_cfg = stage_cfg.nodes[node_idx]
        local miss_name, miss_num = _check_costs(play, node_cfg.cost or {})
        if miss_name then
            Player.sendmsgEx(play, "你的#57|【" .. miss_name .. "】#218|不足：#57|【" .. miss_num .. "】#218|")
            return
        end
        _take_costs(play, node_cfg.cost or {}, ",星象圣图")
        stage_data.nodes[tostring(node_idx)] = 1

        if _count_nodes(stage_data, stage_cfg) >= #(stage_cfg.nodes or {}) then
            stage_data.full = 1
            if _toint(stage_data.reward) ~= 1 then
                _grant_stage_reward(play, stage_cfg)
                stage_data.reward = 1
            end
            Player.sendmsgEx(play, "你完成了#57|【" .. (stage_cfg.name or "星象阶段") .. "】#218|的全部点亮#57")
        else
            Player.sendmsgEx(play, "你点亮了#57|【" .. (node_cfg.name or "星宿") .. "】#218|")
        end

        data.stage[tostring(stage_idx)] = stage_data
        _save_data(play, data)
        star_chart_refresh(play)
        if stage_idx == 3 and _toint(stage_data.full) == 1 then
            local story = Player.getJsonTableByVar(play, VarCfg.T_dljq) or {}
            if (tonumber(story["npc_721"]) or 0) < 2 then
                Player.sendmsgEx(play, "三星已完成，请完成#57|【天机道长对话3】#218|以解锁后续星象圣图")
                Guard.closeNpc(play, npcid)
                return
            end
        end
        sendluamsg(play, 100, npcid, 2, 0, tbl2json(_build_payload(play, data)))
    end
end

-- 登录时刷新星象圣图运行态状态。
local function _star_chart_on_login(play)
    star_chart_refresh(play)
end

GameEvent.add(EventCfg.onLoginEnd, _star_chart_on_login, "星象圣图")
GameEvent.add(EventCfg.onKFLogin, _star_chart_on_login, "星象圣图")

return npc
