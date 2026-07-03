-- 聚宝盆：新版聚能收益、炼灵宝石、禁器系统。
local TreasureBasin = rawget(_G, "__treasure_basin_module")
if TreasureBasin then
    return TreasureBasin
end

TreasureBasin = {}
_G.__treasure_basin_module = TreasureBasin

local _config = Guard.getConfig("npc_106") or {}
local _state_var = "T44"
local _attr_list_name = "聚宝盆属性"
local _forbidden_attr_list = "聚宝盆禁器属性"
local _artifact_name = "聚宝盆"
local _artifact_names = {"聚宝盆", "聚宝盆[封印]"}

local _levels = {
    [1] = {name = "凡品聚宝盆", charge = 0, speed = 1.0, cap = 0},
    [2] = {name = "人品聚宝盆", charge = 98, speed = 1.2, cap = 3 * 3600},
    [3] = {name = "地品聚宝盆", charge = 198, speed = 1.4, cap = 5 * 3600},
    [4] = {name = "天品聚宝盆", charge = 328, speed = 1.7, cap = 8 * 3600},
    [5] = {name = "极品聚宝盆", charge = 988, speed = 2.0, cap = 12 * 3600},
}

local _stone_list = {
    [1] = {name = "聚宝魔石", kind = "normal", continent = 0, bind = 0, time = 30 * 60},
    [2] = {name = "极光·专属宝石·绑定", kind = "exclusive", continent = 2, bind = 1, time = 2 * 3600, rate = 123},
    [3] = {name = "苍云·专属宝石·绑定", kind = "exclusive", continent = 3, bind = 1, time = 6 * 3600, rate = 222},
    [4] = {name = "若水·专属宝石·绑定", kind = "exclusive", continent = 4, bind = 1, time = 12 * 3600, rate = 333},
    [5] = {name = "红尘·专属宝石·绑定", kind = "exclusive", continent = 5, bind = 1, time = 24 * 3600, rate = 666},
    [6] = {name = "灵虚·专属宝石·绑定", kind = "exclusive", continent = 6, bind = 1, time = 48 * 3600, rate = 888},
    [7] = {name = "极光·专属宝石·非绑", kind = "exclusive", continent = 2, bind = 0, time = 2 * 3600, red_rate = 100},
    [8] = {name = "苍云·专属宝石·非绑", kind = "exclusive", continent = 3, bind = 0, time = 6 * 3600, red_rate = 150},
    [9] = {name = "若水·专属宝石·非绑", kind = "exclusive", continent = 4, bind = 0, time = 12 * 3600, red_rate = 266},
    [10] = {name = "红尘·专属宝石·非绑", kind = "exclusive", continent = 5, bind = 0, time = 24 * 3600, red_rate = 300},
    [11] = {name = "灵虚·专属宝石·非绑", kind = "exclusive", continent = 6, bind = 0, time = 48 * 3600, red_rate = 888},
}

local _stone_by_name = {}
for id, cfg in pairs(_stone_list) do
    cfg.id = id
    _stone_by_name[cfg.name] = cfg
end

-- 临时池子：先保证功能跑通，后续按实际专属装备池再替换。
local _exclusive_pools = {
    [2] = {equips = {"星空·道极", "命运之轮", "轮回之力"}, mat = "二重转生石"},
    [3] = {equips = {"死之藤蔓", "流明", "旧日支配者"}, mat = "三重转生石"},
    [4] = {equips = {"耶梦加得", "尼德霍格", "血の恩赐"}, mat = "四重转生石"},
    [5] = {equips = {"世界树灵枝", "午夜虹吸", "王之蔑视"}, mat = "五重转生石"},
    [6] = {equips = {"雷霆幻", "龙鳞震岳", "啸风逐电", "天罚雷击", "烈焰焚天", "霜雪之间"}, mat = "六重转生石"},
}

local _forbidden = {
    [1] = {name = "焚天禁器·炎狱龙尊", skill = "天地异象", plus = "最大攻击+1%"},
    [2] = {name = "幽狱禁器·冥河鬼主", skill = "黄泉降世", plus = "最大生命+1%"},
    [3] = {name = "万灵禁器·太古神凰", skill = "万灵朝凤", plus = "人物双防+1%"},
}
local _forbidden_grade = {"未激活", "凡", "人", "地", "天", "极"}
local _forbidden_cost = {
    [1] = {yuanbao = 180000, crystal = 1, need_level = 1},
    [2] = {yuanbao = 500000, crystal = 3, need_level = 2},
    [3] = {yuanbao = 1000000, crystal = 5, need_level = 3},
    [4] = {yuanbao = 2000000, crystal = 7, need_level = 4},
    [5] = {yuanbao = 3000000, crystal = 9, need_level = 5},
}

local _forbidden_title_name = "初识禁器"


local function _toint(v)
    return tonumber(v) or 0
end

local function _now()
    return os.time()
end

local function _today_key()
    return os.date("%Y%m%d", _now())
end

local function _get_state(play)
    local data = Player.getJsonTableByVar(play, _state_var)
    data = type(data) == "table" and data or {}
    data.rebuilt = _toint(data.rebuilt)
    data.activated = math.max(_toint(data.activated), data.rebuilt)
    data.rebuilt = math.max(data.rebuilt, data.activated)
    data.granted_item = _toint(data.granted_item)
    data.task_started = _toint(data.task_started)
    data.level = math.max(1, _toint(data.level))
    data.energy_sec = tonumber(data.energy_sec) or 0
    data.last_tick = _toint(data.last_tick)
    data.refine = type(data.refine) == "table" and data.refine or {}
    data.forbidden = type(data.forbidden) == "table" and data.forbidden or {}
    data.forbidden.point = _toint(data.forbidden.point)
    data.forbidden.show = _toint(data.forbidden.show)
    data.forbidden.list = type(data.forbidden.list) == "table" and data.forbidden.list or {}
    data.forbidden.title_given = _toint(data.forbidden.title_given)
    return data
end

local function _save_state(play, data)
    Player.setJsonVarByTable(play, _state_var, data or {})
end

local function _check_forbidden_title(play, data)
    data = data or _get_state(play)
    for id = 1, 3 do
        local node = data.forbidden.list[tostring(id)] or data.forbidden.list[id] or {}
        if _toint(node.lv) <= 0 then
            return false
        end
    end
    if _toint(data.forbidden.title_given) < 1 then
        Player.title_give(play, _forbidden_title_name, 1)
        data.forbidden.title_given = 1
        _save_state(play, data)
        Player.sendmsgEx(play, "三大禁器全部激活，获得称号#57|【" .. _forbidden_title_name .. "】#218|")
    end
    return true
end

local function _recharge_total(play)
    return math.max(_toint(querymoney(play, 23)), _toint(getplaydef(play, "U_真实充值")))
end

local function _level_by_charge(play)
    local charge = _recharge_total(play)
    local lv = 1
    for i = 1, #_levels do
        if charge >= _toint(_levels[i].charge) then
            lv = i
        end
    end
    return lv
end

local function _sync_level(play, data)
    local newLv = _level_by_charge(play)
    if newLv > _toint(data.level) then
        data.level = newLv
        return true
    end
    return false
end

local function _is_artifact_name(name)
    name = tostring(name or "")
    for _, one in ipairs(_artifact_names) do
        if name == one then
            return true
        end
    end
    return false
end

local function _equipped_where(play)
    for _, name in ipairs(_artifact_names) do
        local where = Player.hasEquipInArtifactSlot(play, name)
        if where then
            return where
        end
    end
    return nil
end

local function _has_artifact(play)
    for _, name in ipairs(_artifact_names) do
        if getbagitemcount(play, name) >= 1 or Player.hasEquipInArtifactSlot(play, name) then
            return true
        end
    end
    return false
end

local function _equipped_itemobj(play)
    local where = _equipped_where(play)
    if not where then
        return nil
    end
    local itemobj = linkbodyitem(play, where)
    if itemobj and itemobj ~= "0" then
        return itemobj
    end
    return nil
end

local function _cap_seconds(level)
    local cfg = _levels[level] or _levels[1]
    return _toint(cfg.cap)
end

local function _add_energy_seconds(play, data, sec)
    sec = tonumber(sec) or 0
    if data.activated < 1 or sec <= 0 then
        return false
    end
    local cap = _cap_seconds(data.level)
    if cap <= 0 then
        data.energy_sec = 0
        return false
    end
    local before = data.energy_sec
    data.energy_sec = math.min(cap, math.max(0, data.energy_sec + sec))
    return math.floor(before) ~= math.floor(data.energy_sec)
end

local function _calc_energy_reward(sec)
    sec = math.max(0, math.floor(tonumber(sec) or 0))
    return {
        gold = sec * 1000,
        iron = math.floor(sec * 0.01),
        hat = math.floor(sec * 0.01),
    }
end

local function _format_time(sec)
    sec = math.max(0, _toint(sec))
    local h = math.floor(sec / 3600)
    local m = math.floor(sec % 3600 / 60)
    local s = sec % 60
    if h > 0 then
        return string.format("%02d:%02d:%02d", h, m, s)
    end
    return string.format("%02d:%02d", m, s)
end

local function _give_rewards(play, reward, reason)
    reward = reward or {}
    if _toint(reward.gold) > 0 then
        changemoney(play, 3, "+", _toint(reward.gold), reason or "聚宝盆", true)
    end
    if _toint(reward.yuanbao) > 0 then
        changemoney(play, 4, "+", _toint(reward.yuanbao), reason or "聚宝盆", true)
    end
    if _toint(reward.lingshi) > 0 then
        changemoney(play, 7, "+", _toint(reward.lingshi), reason or "聚宝盆", true)
    end
    local items = {}
    if _toint(reward.iron) > 0 then
        items[#items + 1] = {"千年玄铁", _toint(reward.iron)}
    end
    if _toint(reward.hat) > 0 then
        items[#items + 1] = {"斗笠碎片", _toint(reward.hat)}
    end
    for _, item in ipairs(reward.items or {}) do
        items[#items + 1] = item
    end
    if #items > 0 then
        Player.rwjl(play, items, reason or "聚宝盆", 1, 999)
    end
end

local function _clear_item_bar(play, itemobj)
    if not itemobj or itemobj == "0" then
        return
    end
    for idx = 0, 4 do
        setcustomitemprogressbar(play, itemobj, idx, tbl2json({open = 0}))
    end
    refreshitem(play, itemobj)
end

local function _forbidden_used_count(play)
    return _toint(getplaydef(play, "J_禁器技能_CD")) >= 1 and 1 or 0
end

local function _has_super_privilege(play)
    return checktitle(play, "超级特权")
end

local function _refresh_item_bar(play)
    local itemobj = _equipped_itemobj(play)
    if not itemobj then
        return
    end
    local data = _get_state(play)
    _sync_level(play, data)
    local lvCfg = _levels[data.level] or _levels[1]
    local reward = _calc_energy_reward(data.energy_sec)
    setcustomitemprogressbar(play, itemobj, 0, tbl2json({
        open = 1, show = 0, name = string.format("%s Lv.%d", lvCfg.name, data.level), color = 253, imgcount = 1,
    }))
    if _cap_seconds(data.level) > 0 then
        local percent = math.floor(math.max(0, math.min(100, (tonumber(data.energy_sec) or 0) / math.max(1, _cap_seconds(data.level)) * 100)))
        setcustomitemprogressbar(play, itemobj, 1, tbl2json({
            open = 1, show = 2, name = "聚能存储", color = 249, imgcount = 1,
            cur = percent, max = 100, level = 1,
        }))
    else
        setcustomitemprogressbar(play, itemobj, 1, tbl2json({open = 0}))
    end
    setcustomitemprogressbar(play, itemobj, 2, tbl2json({
        open = 1, show = 0,
        name = string.format("可领金币：%d", reward.gold),
        color = 223, imgcount = 1,
    }))
    setcustomitemprogressbar(play, itemobj, 3, tbl2json({
        open = 1, show = 0,
        name = string.format("可领材料：千年玄铁%d 斗笠碎片%d", reward.iron, reward.hat),
        color = 223, imgcount = 1,
    }))
    setcustomitemprogressbar(play, itemobj, 4, tbl2json({
        open = 1, show = 0,
        name = string.format("禁器技能：今日剩余%d/1", 1 - _forbidden_used_count(play)),
        color = 223, imgcount = 1,
    }))
    refreshitem(play, itemobj)
    _save_state(play, data)
end

local function _refresh_attr(play)
    Player.del_attlist(play, _attr_list_name)
    Player.del_attlist(play, _forbidden_attr_list)
    local data = _get_state(play)
    if data.activated < 1 or not _equipped_where(play) then
        return
    end
    -- 聚宝盆本体保留背包神器身份，不再给旧的打怪经验/金币回收属性。
    local attrs = {}
    for id, node in pairs(data.forbidden.list or {}) do
        local lv = _toint(node.lv)
        if lv > 0 then
            local mul = ({1, 1.5, 2, 2.5, 3})[math.min(lv, 5)] or 1
            attrs[1] = (attrs[1] or 0) + math.floor(1888 * mul)
            attrs[3] = (attrs[3] or 0) + math.floor(188 * mul)
            attrs[4] = (attrs[4] or 0) + math.floor(188 * mul)
            attrs[36] = (attrs[36] or 0) + math.floor(50 * mul)
            attrs[37] = (attrs[37] or 0) + math.floor(50 * mul)
            attrs[300] = (attrs[300] or 0) + lv
        end
    end
    if next(attrs) then
        Player.add_attlist(play, _forbidden_attr_list, "=", Player.getAttrTableToStr(attrs), 1)
    end
end

function TreasureBasin.activate(play, reason)
    if not play then
        return false
    end
    local data = _get_state(play)
    local changed = false
    if data.activated < 1 then
        data.activated = 1
        data.rebuilt = 1
        data.level = math.max(1, _level_by_charge(play))
        data.last_tick = _now()
        changed = true
    end
    if not _has_artifact(play) then
        Player.rwjl(play, {{_artifact_name, 1}}, reason or "聚宝盆", 1, 999)
        changed = true
    end
    if changed then
        _save_state(play, data)
        Player.sendmsgEx(play, "已激活#57|【聚宝盆】#218|，可在背包神器位穿戴查看聚能进度。")
    end
    _refresh_attr(play)
    _refresh_item_bar(play)
    return true
end

function TreasureBasin.markTaskStarted(play)
    if not play then
        return false
    end
    local data = _get_state(play)
    if data.rebuilt >= 1 then
        return false
    end
    if shaguai and shaguai.jia then
        shaguai.jia(play, 33)
    end
    if data.task_started >= 1 then
        return false
    end
    data.task_started = 1
    _save_state(play, data)
    local dropData = Player.getJsonTableByVar(play, VarCfg["T_物品掉落记录"])
    if type(dropData) ~= "table" then
        dropData = {}
    end
    dropData["kill_pity_聚宝盆碎片"] = 0
    Player.setJsonVarByTable(play, VarCfg["T_物品掉落记录"], dropData)
    return true
end

function TreasureBasin.isTaskStarted(play)
    return (_get_state(play).task_started or 0) >= 1
end

function TreasureBasin.isActivated(play)
    return _get_state(play).activated >= 1 or _has_artifact(play)
end

local function _tick_energy(play, onlineSec, offlineSec)
    local data = _get_state(play)
    if data.activated < 1 and _has_artifact(play) then
        data.activated = 1
        data.rebuilt = 1
    end
    local changed = _sync_level(play, data)
    if _add_energy_seconds(play, data, onlineSec) then
        changed = true
    end
    if _add_energy_seconds(play, data, (tonumber(offlineSec) or 0) * 0.5) then
        changed = true
    end
    data.last_tick = _now()
    if changed then
        _save_state(play, data)
    end
    _refresh_item_bar(play)
end

local function _build_refine_payload(data)
    local ref = data.refine or {}
    if tostring(ref.stone or "") == "" then
        return {active = 0}
    end
    local left = math.max(0, _toint(ref.end_at) - _now())
    return {
        active = 1,
        stone = ref.stone,
        end_at = _toint(ref.end_at),
        left = left,
        done = left <= 0 and 1 or 0,
        continent = _toint(ref.continent),
        bind = _toint(ref.bind),
    }
end

local function _build_forbidden_payload(play, data)
    local list = {}
    local used = _forbidden_used_count(play)
    for id, _ in ipairs(_forbidden) do
        local node = data.forbidden.list[tostring(id)] or data.forbidden.list[id] or {}
        list[#list + 1] = {
            id = id,
            lv = _toint(node.lv),
            show = _toint(data.forbidden.show) == id and 1 or 0,
            used = used,
        }
    end
    return list
end

local function _artifact_item_name()
    return tostring(_config.artifact_name or "聚宝盆")
end

local function _artifact_show_name()
    return tostring(_config.artifact_display_name or _config.artifact_name or "聚宝盆")
end

local function _artifact_reward()
    local reward = type(_config.artifact_reward) == "table" and _config.artifact_reward or {}
    if #reward <= 0 then
        reward = {{_artifact_item_name(), 1}}
    end
    return reward
end

local function _progress_need()
    local need = _toint(_config.daily_kill or 1000)
    if need <= 0 then need = 1000 end
    return need
end

local function _get_progress(play)
    return math.min(_toint(getplaydef(play, VarCfg["J_聚宝盆积分"])), _progress_need())
end

local function _set_progress(play, value)
    setplaydef(play, VarCfg["J_聚宝盆积分"], math.max(0, math.min(_progress_need(), _toint(value))))
end

local function _is_claimed(play)
    return _toint(getplaydef(play, VarCfg["J_聚宝盆领取次数"])) >= 1
end

local function _set_claimed(play, flag)
    setplaydef(play, VarCfg["J_聚宝盆领取次数"], flag and 1 or 0)
end

local function _grant_artifact_if_needed(play, data)
    data = data or _get_state(play)
    local hasArtifact = _has_artifact(play)
    local changed = false
    if hasArtifact and data.rebuilt < 1 then
        data.rebuilt = 1
        data.activated = 1
        changed = true
    end
    if hasArtifact and data.granted_item < 1 then
        data.granted_item = 1
        changed = true
    end
    if data.rebuilt >= 1 and data.granted_item < 1 and not hasArtifact then
        Player.rwjl(play, _artifact_reward(), "聚宝盆重铸", 1, 999)
        data.granted_item = 1
        changed = true
        Player.sendmsgEx(play, "获得背包神器：|【".._artifact_show_name().."】#218|")
    end
    if changed then
        _save_state(play, data)
    end
    return data
end

local function _build_task_payload(play)
    local data = _grant_artifact_if_needed(play, _get_state(play))
    local itemName = tostring(_config.fragment_item or "聚宝盆碎片")
    return {
        mode = "task",
        T_data = data,
        fragment_item = itemName,
        fragment_need = _toint(_config.fragment_count or 20),
        fragment_have = getbagitemcount(play, itemName),
        artifact_name = _artifact_show_name(),
        artifact_item_name = _artifact_item_name(),
        artifact_reward = _artifact_reward(),
        activated = data.rebuilt >= 1 and 1 or 0,
        equipped = _equipped_where(play) and 1 or 0,
        progress_cur = _get_progress(play),
        progress_need = _progress_need(),
        claimed = _is_claimed(play) and 1 or 0,
        daily_reward = _config.daily_reward or {{"金币",2000000}},
        attr = _config.attr or {},
    }
end

local function _send_task_panel(play, msgType, npcid)
    sendluamsg(play, 100, npcid or 106, msgType or 0, 0, tbl2json(_build_task_payload(play)))
end
local function _build_payload(play)
    local data = _get_state(play)
    if data.activated < 1 and _has_artifact(play) then
        data.activated = 1
        data.rebuilt = 1
    end
    _sync_level(play, data)
    _check_forbidden_title(play, data)
    _save_state(play, data)
    local reward = _calc_energy_reward(data.energy_sec)
    return {
        mode = "feature",
        T_data = data,
        activated = data.activated,
        equipped = _equipped_where(play) and 1 or 0,
        level = data.level,
        charge = _recharge_total(play),
        cap = _cap_seconds(data.level),
        cap_sec = _cap_seconds(data.level),
        energy_sec = math.floor(data.energy_sec),
        energy_text = _format_time(data.energy_sec),
        energy_reward = reward,
        refine = _build_refine_payload(data),
        forbidden_point = _toint(data.forbidden.point),
        forbidden = _build_forbidden_payload(play, data),
        today = _today_key(),
        has_forbidden_title = _toint(data.forbidden.title_given),
    }
end

local function _send_panel(play, msgType, npcid)
    sendluamsg(play, 101, npcid or 106, msgType or 0, 0, tbl2json(_build_payload(play)))
end

function TreasureBasin.main(play, npcid)
    _grant_artifact_if_needed(play, _get_state(play))
    _refresh_attr(play)
    _refresh_item_bar(play)
    _send_task_panel(play, 0, npcid or 106)
end

function TreasureBasin.link(play, npcid, p2, p3, msgData)
    if not Guard.ensurePlayer(play, npcid) then return end
    local action = Guard.normalizeAction(play, npcid, p2)
    if action == nil then return end
    local allowed = Guard.newActionSet({1, 9})
    if not Guard.ensureActionAllowed(play, npcid, action, allowed) then return end
    if action == 9 then
        return _send_task_panel(play, 9, npcid)
    end
    local data = _grant_artifact_if_needed(play, _get_state(play))
    if data.rebuilt >= 1 or _has_artifact(play) then
        Player.sendmsgEx(play, "你已拥有#57|【".._artifact_show_name().."】#218|")
        _refresh_attr(play)
        _refresh_item_bar(play)
        return _send_task_panel(play, 1, npcid)
    end
    local itemName = tostring(_config.fragment_item or "聚宝盆碎片")
    local needNum = _toint(_config.fragment_count or 20)
    local haveNum = getbagitemcount(play, itemName)
    if haveNum < needNum then
        Player.sendmsgEx(play, string.format("还需要#57|【%s】#218|：#57|【%d/%d】#218|", itemName, haveNum, needNum))
        Guard.closeNpcAndAuto(play, npcid)
        return
    end
    Player.takeItemByTable(play, {{itemName, needNum}}, "聚宝盆重铸", nil)
    data.rebuilt = 1
    data.activated = 1
    data.task_fixed = 1
    _save_state(play, data)
    if zxrw_try_finish_current_mainline then zxrw_try_finish_current_mainline(play, "任务") end
    if shaguai and shaguai.jian then shaguai.jian(play, 33) end
    if shaguai and shaguai.jia then shaguai.jia(play, 34) end
    data = _grant_artifact_if_needed(play, data)
    _refresh_attr(play)
    _refresh_item_bar(play)
    Player.sendmsgEx(play, "成功重铸#57|【".._artifact_show_name().."】#218|，已发放实体背包神器#57")
    sendluamsg(play, 101, 9999, 0, 0, "npc_106")
    sendluamsg(play, 101, 0, 1, 1, '{"lx":3,"rwid":24}')
    _send_task_panel(play, 1, npcid)
end
function TreasureBasin.mainFeature(play, npcid)
    local data = _get_state(play)
    if data.rebuilt < 1 and data.activated < 1 then
        Player.sendmsgEx(play, "请先完成聚宝盆任务")
        return
    end
    _refresh_attr(play)
    _refresh_item_bar(play)
    _send_panel(play, 0, npcid or 106)
end

local function _claim_energy(play, npcid)
    local data = _get_state(play)
    local reward = _calc_energy_reward(data.energy_sec)
    if reward.gold <= 0 and reward.iron <= 0 and reward.hat <= 0 then
        Player.sendmsgEx(play, "当前暂无可领取的聚能收益")
        _send_panel(play, 1, npcid)
        return
    end
    _give_rewards(play, reward, "聚宝盆聚能收益")
    data.energy_sec = 0
    data.last_tick = _now()
    _save_state(play, data)
    _refresh_item_bar(play)
    _send_panel(play, 1, npcid)
end

local function _start_refine(play, npcid, msgData)
    local data = _get_state(play)
    local req = type(msgData) == "table" and msgData or (msgData and msgData ~= "" and json2tbl(msgData) or {})
    local stoneName = tostring(req.stone or req.name or "")
    local cfg = _stone_by_name[stoneName]
    if not cfg then
        Player.sendmsgEx(play, "请选择要炼灵的宝石")
        return _send_panel(play, 2, npcid)
    end
    if tostring(data.refine.stone or "") ~= "" then
        Player.sendmsgEx(play, "当前已有宝石正在炼灵，请先领取完成的产物")
        return _send_panel(play, 2, npcid)
    end
    if getbagitemcount(play, stoneName) < 1 then
        Player.sendmsgEx(play, "背包中没有#57|【" .. stoneName .. "】#218|")
        return _send_panel(play, 2, npcid)
    end
    Player.takeItemByTable(play, {{stoneName, 1}}, "聚宝盆炼灵", nil)
    local speed = (_levels[data.level] or _levels[1]).speed or 1
    data.refine = {stone = stoneName, end_at = _now() + math.ceil(cfg.time / speed), continent = cfg.continent, bind = cfg.bind, kind = cfg.kind}
    _save_state(play, data)
    Player.sendmsgEx(play, "已放入#57|【" .. stoneName .. "】#218|开始炼灵")
    _send_panel(play, 2, npcid)
end

local function _claim_refine(play, npcid)
    local data = _get_state(play)
    local ref = data.refine or {}
    if tostring(ref.stone or "") == "" then
        Player.sendmsgEx(play, "当前没有正在炼灵的宝石")
        return _send_panel(play, 3, npcid)
    end
    if _toint(ref.end_at) > _now() then
        Player.sendmsgEx(play, "炼灵尚未完成，剩余#57|【" .. _format_time(_toint(ref.end_at) - _now()) .. "】#218|")
        return _send_panel(play, 3, npcid)
    end
    local reward = {items = {}}
    if tostring(ref.kind) == "normal" then
        local r = math.random(100)
        if r <= 5 then
            reward.lingshi = 10
        elseif r <= 55 then
            reward.gold = 500000
        else
            reward.items[#reward.items + 1] = {"千年玄铁", 10}
        end
    else
        local pool = _exclusive_pools[_toint(ref.continent)] or _exclusive_pools[2]
        local equips = pool.equips or {}
        local equipName = equips[math.random(math.max(1, #equips))] or "六大陆专属装备随机宝箱"
        reward.items[#reward.items + 1] = {equipName, 1}
        if pool.mat and math.random(100) <= 50 then
            reward.items[#reward.items + 1] = {pool.mat, 1}
        end
    end
    _give_rewards(play, reward, "聚宝盆炼灵")
    if _toint(data.forbidden.show) > 0 then
        data.forbidden.point = _toint(data.forbidden.point) + math.max(1, _toint(ref.continent)) * 10
    end
    data.refine = {}
    _save_state(play, data)
    _refresh_item_bar(play)
    _send_panel(play, 3, npcid)
end

local function _unlock_forbidden(play, npcid, id)
    id = _toint(id)
    local cfg = _forbidden[id]
    if not cfg then return end
    local data = _get_state(play)
    local node = data.forbidden.list[tostring(id)] or {}
    if _toint(node.lv) > 0 then
        Player.sendmsgEx(play, "该禁器已激活")
        return false
    end
    if _toint(data.forbidden.point) < 8888 then
        Player.sendmsgEx(play, "聚宝值不足，激活禁器需要#57|【8888】#218|点")
        return false
    end
    data.forbidden.point = _toint(data.forbidden.point) - 8888
    data.forbidden.list[tostring(id)] = {lv = 1}
    if _toint(data.forbidden.show) <= 0 then data.forbidden.show = id end
    _save_state(play, data)
    _refresh_attr(play)
    _refresh_item_bar(play)
    _check_forbidden_title(play, data)
    Player.sendmsgEx(play, "成功激活#57|【" .. cfg.name .. "】#218|")
    _send_panel(play, 4, npcid)
end

function TreasureBasin.useForbiddenItem(play, itemName)
    local itemMap = {
        ["\183\217\204\236\189\251\198\247\161\164\209\215\211\252\193\250\215\240"] = 1,
        ["\211\196\211\252\189\251\198\247\161\164\218\164\186\211\185\237\214\247"] = 2,
        ["\205\242\193\233\189\251\198\247\161\164\204\171\185\197\201\241\187\203"] = 3,
    }
    local id = itemMap[tostring(itemName or "")]
    local cfg = id and _forbidden[id]
    if not cfg then
        return false
    end
    local data = _get_state(play)
    local node = data.forbidden.list[tostring(id)] or {}
    if _toint(node.lv) > 0 then
        Player.sendmsgEx(play, "该禁器已激活")
        return false
    end
    data.activated = 1
    data.rebuilt = 1
    data.forbidden.list[tostring(id)] = {lv = 1}
    if _toint(data.forbidden.show) <= 0 then data.forbidden.show = id end
    _save_state(play, data)
    _refresh_attr(play)
    _refresh_item_bar(play)
    Player.sendmsgEx(play, "成功激活#57|【" .. cfg.name .. "】#218|")
    return true
end
local function _upgrade_forbidden(play, npcid, id)
    id = _toint(id)
    local data = _get_state(play)
    local node = data.forbidden.list[tostring(id)] or {}
    local lv = _toint(node.lv)
    if lv <= 0 then
        Player.sendmsgEx(play, "请先激活该禁器")
        return false
    end
    if lv >= 5 then
        Player.sendmsgEx(play, "该禁器已是极品")
        return false
    end
    local nextLv = lv + 1
    local cost = _forbidden_cost[nextLv]
    if data.level < cost.need_level then
        Player.sendmsgEx(play, "聚宝盆品阶不足，无法升级该禁器")
        return false
    end
    if querymoney(play, 4) < cost.yuanbao then
        Player.sendmsgEx(play, "元宝不足，需要#57|【" .. cost.yuanbao .. "】#218|")
        return false
    end
    if getbagitemcount(play, "禁元神晶") < cost.crystal then
        Player.sendmsgEx(play, "禁元神晶不足，需要#57|【" .. cost.crystal .. "】#218|个")
        return false
    end
    changemoney(play, 4, "-", cost.yuanbao, "禁器升级", true)
    Player.takeItemByTable(play, {{"禁元神晶", cost.crystal}}, "禁器升级", nil)
    data.forbidden.list[tostring(id)] = {lv = nextLv}
    _save_state(play, data)
    _refresh_attr(play)
    _refresh_item_bar(play)
    local name = _forbidden[id] and _forbidden[id].name or "禁器"
    Player.sendmsgEx(play, "#57|【" .. name .. "】#218|升级成功")
    if nextLv >= 5 then
        sendmovemsg("0", 1, 253, 0, 200, 1, "[禁器]玩家《" .. tostring(getbaseinfo(play, 1) or "") .. "》炼成极品" .. name .. "，天地震动！")
    end
    _send_panel(play, 5, npcid)
end

local function _set_show_forbidden(play, npcid, id)
    id = _toint(id)
    if not _forbidden[id] then
        return false
    end
    local data = _get_state(play)
    data.forbidden.show = id
    _save_state(play, data)
    _refresh_item_bar(play)
    Player.sendmsgEx(play, "已选择禁器展示：#57|【" .. tostring(_forbidden[id].name or "禁器") .. "】#218|")
    _send_panel(play, 6, npcid)
end

local function _claim_forbidden_reward(play, npcid, id)
    local data = _get_state(play)
    local showId = _toint(data.forbidden.show)
    if showId <= 0 or not _forbidden[showId] then
        Player.sendmsgEx(play, "请先选择一个外显禁器")
        return false
    end
    id = _toint(id)
    if id > 0 and id ~= showId then
        Player.sendmsgEx(play, "只能释放当前外显禁器技能")
        return false
    end
    local node = data.forbidden.list[tostring(showId)] or {}
    if _toint(node.lv) <= 0 then
        Player.sendmsgEx(play, "请先激活当前外显禁器")
        return false
    end
    local jKey = "J_禁器技能_CD"
    if _toint(getplaydef(play, jKey)) >= 1 then
        Player.sendmsgEx(play, "禁器技能冷却中")
        return false
    end
    setplaydef(play, jKey, 1)
    local cfg = _forbidden[showId]
    if showId == 1 then
        local gold = math.random(100000, 300000)
        local yb = math.random(1000, 3000)
        changemoney(play, 3, "+", gold, "禁器技能", true)
        changemoney(play, 4, "+", yb, "禁器技能", true)
    elseif showId == 2 then
        setplaydef(play, "N$聚宝盆黄泉降世", _now() + 300)
    elseif showId == 3 then
        Player.rwjl(play, {{"凤凰之瞳", 5}}, "禁器技能", 1, 999)
    end
    Player.sendmsgEx(play, "成功释放外显禁器技能：#57|【" .. tostring(cfg.name or "禁器") .. "】#218|")
    _refresh_item_bar(play)
    _send_panel(play, 7, npcid)
end

function TreasureBasin.linkFeature(play, npcid, p2, p3, msgData)
    if not Guard.ensurePlayer(play, npcid) then return end
    local action = Guard.normalizeAction(play, npcid, p2)
    if action == nil then return end
    local allowed = Guard.newActionSet({1, 2, 3, 4, 5, 6, 7, 9})
    if not Guard.ensureActionAllowed(play, npcid, action, allowed) then return end
    local data = _get_state(play)
    if data.rebuilt < 1 and data.activated < 1 then
        Player.sendmsgEx(play, "请先完成聚宝盆任务")
        return _send_task_panel(play, action, 106)
    end
    if action == 1 then
        _claim_energy(play, npcid)
    elseif action == 2 then
        _start_refine(play, npcid, msgData)
    elseif action == 3 then
        _claim_refine(play, npcid)
    elseif action == 4 then
        _unlock_forbidden(play, npcid, p3)
    elseif action == 5 then
        _upgrade_forbidden(play, npcid, p3)
    elseif action == 6 then
        _set_show_forbidden(play, npcid, p3)
    elseif action == 7 then
        _claim_forbidden_reward(play, npcid, p3)
    else
        _send_panel(play, action, npcid)
    end
end

function TreasureBasin.onTimer60(play)
    _tick_energy(play, 60, 0)
end

function TreasureBasin.onExitGame(play)
    local data = _get_state(play)
    data.last_logout = _now()
    _save_state(play, data)
end

local function _on_login(play)
    local data = _get_state(play)
    if data.activated < 1 and _has_artifact(play) then
        data.activated = 1
        data.rebuilt = 1
    end
    _sync_level(play, data)
    local lastLogout = _toint(data.last_logout)
    if data.activated >= 1 and lastLogout > 0 then
        _add_energy_seconds(play, data, math.max(0, _now() - lastLogout) * 0.5)
        data.last_logout = 0
    end
    data.last_tick = _now()
    _check_forbidden_title(play, data)
    _save_state(play, data)
    _refresh_attr(play)
    _refresh_item_bar(play)
end

local function _on_daily(play)
    setplaydef(play, "J_禁器技能_CD", 0)
    _set_progress(play, 0)
    _set_claimed(play, false)
    _refresh_item_bar(play)
end

function TreasureBasin.resetDaily(play)
    _on_daily(play)
end

local function _continent_by_map_name(mapName)
    return _toint(daluditu and daluditu[tostring(mapName or "")])
end

function TreasureBasin.onKillMon(play, mob)
    if not play or not mob then return end
    local data = _get_state(play)
    if data.activated < 1 and not _has_artifact(play) then return end
    data.activated = 1
    data.rebuilt = 1
    if _toint(data.forbidden.show) > 0 then
        data.forbidden.point = _toint(data.forbidden.point) + 1
    end
    _save_state(play, data)

    local mapName = tostring(getbaseinfo(play, 3) or "")
    local dl = _continent_by_map_name(mapName)
    local mobName = tostring(getbaseinfo(mob, 1) or "")
    local gtype = _toint(guaiwutype and guaiwutype[mobName])
    local isBig = gtype >= 1
    -- 聚宝魔石：全大陆 1/100，大怪及以上必掉 1 个。
    if isBig or math.random(100) == 1 then
        shaguai.temp_drop(play, mob, "聚宝魔石")
    end

    -- 专属宝石掉落已迁回各大陆爆率文件，这里不再通过杀怪监听直接产出。

end
local function _on_take_on(actor, itemobj, where, itemname, makeid)
    if not _is_artifact_name(itemname) and not _equipped_where(actor) then return end
    TreasureBasin.activate(actor, "聚宝盆")
    _refresh_attr(actor)
    _refresh_item_bar(actor)
end

local function _on_take_off(actor, itemobj, where, itemname, makeid)
    if _is_artifact_name(itemname) then
        _clear_item_bar(actor, itemobj)
    end
    _refresh_attr(actor)
    _refresh_item_bar(actor)
end

GameEvent.add(EventCfg.onLogin, _on_login, "聚宝盆")
GameEvent.add(EventCfg.onKFLogin, _on_login, "聚宝盆")
GameEvent.add(EventCfg.goDailyUpdate, _on_daily, "聚宝盆")
GameEvent.add(EventCfg.onKillMon, TreasureBasin.onKillMon, "聚宝盆")
GameEvent.add(EventCfg.onExitGame, TreasureBasin.onExitGame, "聚宝盆")
GameEvent.add(EventCfg.onTakeOnEx, _on_take_on, "聚宝盆")
GameEvent.add(EventCfg.onTakeOffEx, _on_take_off, "聚宝盆")

return TreasureBasin








