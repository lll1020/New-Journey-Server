-- 聚宝盆：独立背包神器逻辑。
local TreasureBasin = rawget(_G, "__treasure_basin_module")
if TreasureBasin then
    return TreasureBasin
end

TreasureBasin = {}
_G.__treasure_basin_module = TreasureBasin

local _config = Guard.getConfig("npc_106") or {}
local _attr_list_name = "聚宝盆属性"

local function _toint(v)
    return tonumber(v) or 0
end

-- 聚宝盆真实装备名：当前通过背包神器【聚宝盆】承载效果。
local function _artifact_item_name()
    return tostring(_config.artifact_name or "聚宝盆")
end

-- 聚宝盆界面统一展示名。
local function _artifact_show_name()
    return tostring(_config.artifact_display_name or _config.artifact_name or "聚宝盆")
end

-- 聚宝盆补发奖励：默认补发真实背包神器。
local function _artifact_reward()
    local reward = type(_config.artifact_reward) == "table" and _config.artifact_reward or {}
    if #reward <= 0 then
        reward = {{_artifact_item_name(), 1}}
    end
    return reward
end

-- 兼容旧数据：默认识别【聚宝盆】与【聚宝盆[封印]】双命名，其他兼容名由配置显式声明。
local function _artifact_names()
    local names = {}
    local seen = {}
    local function _push(name)
        name = tostring(name or "")
        if name ~= "" and not seen[name] then
            seen[name] = true
            names[#names + 1] = name
        end
    end
    local itemName = _artifact_item_name()
    local showName = _artifact_show_name()
    _push(itemName)
    _push(showName)
    if itemName:match("%[封印%]$") then
        _push((itemName:gsub("%[封印%]$", "")))
    else
        _push(itemName .. "[封印]")
    end
    if showName:match("%[封印%]$") then
        _push((showName:gsub("%[封印%]$", "")))
    else
        _push(showName .. "[封印]")
    end
    for _, name in ipairs(_config.artifact_check_names or {}) do
        _push(name)
    end
    return names
end

local function _is_artifact_name(name)
    name = tostring(name or "")
    if name == "" then
        return false
    end
    for _, one in ipairs(_artifact_names()) do
        if one == name then
            return true
        end
    end
    return false
end

-- 查询是否已拥有聚宝盆：背包或背包神器位都算。
local function _has_artifact(play)
    for _, name in ipairs(_artifact_names()) do
        if getbagitemcount(play, name) >= 1 or Player.hasEquipInArtifactSlot(play, name) then
            return true
        end
    end
    return false
end

-- 查询聚宝盆当前是否穿戴在背包神器位。
local function _equipped_where(play)
    for _, name in ipairs(_artifact_names()) do
        local where = Player.hasEquipInArtifactSlot(play, name)
        if where then
            return where
        end
    end
    return nil
end

-- 获取当前穿戴中的聚宝盆物品对象，用于刷新进度条。
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

-- 聚宝盆状态：rebuilt=已修复，granted_item=已补发实体神器。
local function _get_state(play)
    local data = Player.getJsonTableByVar(play, VarCfg["T_聚宝盆"]) or {}
    data.rebuilt = _toint(data.rebuilt)
    data.granted_item = _toint(data.granted_item)
    data.task_started = _toint(data.task_started)
    return data
end

local function _save_state(play, data)
    Player.setJsonVarByTable(play, VarCfg["T_聚宝盆"], data or {})
end

-- 每日聚宝盆进度上限：满后自动发放奖励。

-- 聚宝盆碎片卡点从异闻录任务接到这一刻开始计时。
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
    if zxrw_try_finish_current_mainline then zxrw_try_finish_current_mainline(play, "任务") end
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
local function _progress_need()
    local need = _toint(_config.daily_kill or 1000)
    if need <= 0 then
        need = 1000
    end
    return need
end

local function _get_progress(play)
    return math.min(_toint(getplaydef(play, VarCfg["U_聚宝盆积分"])), _progress_need())
end

local function _set_progress(play, value)
    setplaydef(play, VarCfg["U_聚宝盆积分"], math.max(0, math.min(_progress_need(), _toint(value))))
end

local function _is_claimed(play)
    return _toint(getplaydef(play, VarCfg["J_聚宝盆领取次数"])) >= 1
end

local function _set_claimed(play, flag)
    setplaydef(play, VarCfg["J_聚宝盆领取次数"], flag and 1 or 0)
end

-- 聚宝盆属性只在背包神器位穿戴后生效，避免修复后永久常驻。
local function _refresh_attr(play)
    Player.del_attlist(play, _attr_list_name)
    if not _equipped_where(play) then
        return
    end
    local attrs = {}
    for _, entry in ipairs(_config.attr or {}) do
        local attrId = tonumber(entry[1])
        local attrValue = tonumber(entry[2]) or 0
        if attrId and attrValue ~= 0 then
            attrs[attrId] = (attrs[attrId] or 0) + attrValue
        end
    end
    if next(attrs) then
        Player.add_attlist(play, _attr_list_name, "=", Player.getAttrTableToStr(attrs), 1)
    end
end

-- 物品脱下后关闭聚宝盆进度条，避免背包里仍显示装备进度。
local function _clear_item_bar(play, itemobj)
    if not itemobj or itemobj == "0" then
        return
    end
    for idx = 0, 2 do
        setcustomitemprogressbar(play, itemobj, idx, tbl2json({open = 0}))
    end
    refreshitem(play, itemobj)
end

-- 聚宝盆物品提示文本：展示每日进度与自动发奖状态。
local function _progress_prompt(play)
    if not _equipped_where(play) then
        return "请穿戴到背包神器位后生效", 249
    end
    if _is_claimed(play) then
        return "今日奖励已自动发放", 251
    end
    if _get_progress(play) >= _progress_need() then
        return "奖励已达标，正在自动发放", 223
    end
    return string.format("今日击杀：%d/%d", _get_progress(play), _progress_need()), 223
end

-- 刷新聚宝盆实体神器上的三条自定义进度条。
local function _refresh_item_bar(play)
    local itemobj = _equipped_itemobj(play)
    if not itemobj then
        return
    end
    local prompt, promptColor = _progress_prompt(play)
    setcustomitemprogressbar(play, itemobj, 0, tbl2json({
        ["open"] = 1,
        ["show"] = 0,
        ["name"] = _artifact_show_name() .. "已激活",
        ["color"] = 223,
        ["imgcount"] = 1,
    }))
    setcustomitemprogressbar(play, itemobj, 1, tbl2json({
        ["open"] = 1,
        ["show"] = 2,
        ["name"] = "每日进度",
        ["color"] = 249,
        ["imgcount"] = 1,
        ["cur"] = _get_progress(play),
        ["max"] = _progress_need(),
        ["level"] = 1,
    }))
    setcustomitemprogressbar(play, itemobj, 2, tbl2json({
        ["open"] = 1,
        ["show"] = 0,
        ["name"] = prompt,
        ["color"] = promptColor,
        ["imgcount"] = 1,
    }))
    refreshitem(play, itemobj)
end

-- 兼容老玩家：修复状态存在但没有实体神器时，自动补发一次。
local function _grant_artifact_if_needed(play, data)
    data = data or _get_state(play)
    local hasArtifact = _has_artifact(play)
    local changed = false
    if hasArtifact and data.rebuilt < 1 then
        data.rebuilt = 1
        changed = true
    end
    if hasArtifact and data.granted_item < 1 then
        data.granted_item = 1
        changed = true
    end
    if data.rebuilt >= 1 and data.granted_item < 1 and not hasArtifact then
        Player.rwjl(play, _artifact_reward(), "聚宝盆重铸", 1)
        data.granted_item = 1
        changed = true
        Player.sendmsgEx(play, "获得背包神器：|【".._artifact_show_name().."】#218|")
    end
    if changed then
        _save_state(play, data)
    if zxrw_try_finish_current_mainline then zxrw_try_finish_current_mainline(play, "任务") end
    end
    return data
end

-- 构建聚宝盆面板数据：供独立 106 NPC 界面展示。
local function _build_payload(play)
    local data = _grant_artifact_if_needed(play, _get_state(play))
    return {
        T_data = data,
        fragment_item = tostring(_config.fragment_item or "聚宝盆碎片"),
        fragment_need = _toint(_config.fragment_count or 20),
        fragment_have = getbagitemcount(play, tostring(_config.fragment_item or "聚宝盆碎片")),
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

-- 统一推送聚宝盆 106 面板。
local function _send_panel(play, msgType, npcid)
    sendluamsg(play, 100, npcid or 106, msgType or 0, 0, tbl2json(_build_payload(play)))
end

-- 每日奖励改为自动发放：达标后直接结算，不再手动领取。
local function _try_auto_reward(play, npcid)
    local data = _grant_artifact_if_needed(play, _get_state(play))
    if data.rebuilt < 1 then
        return false
    end
    if not _equipped_where(play) then
        return false
    end
    if _is_claimed(play) then
        return false
    end
    if _get_progress(play) < _progress_need() then
        return false
    end
    _set_progress(play, _progress_need())
    _set_claimed(play, true)
    Player.rwjl(play, _config.daily_reward or {{"金币",2000000}}, "聚宝盆每日奖励", 1)
    sendmsg(play, 1, '{"Msg":"<font color=\'#ff7700\'>[聚宝盆]</font><font color=\'#28ef01\'>今日奖励已自动发放...</font>","Type":9}')
    _refresh_item_bar(play)
    _send_panel(play, 2, npcid or 106)
    return true
end

function TreasureBasin.main(play, npcid)
    _grant_artifact_if_needed(play, _get_state(play))
    _refresh_attr(play)
    _refresh_item_bar(play)
    _try_auto_reward(play, npcid or 106)
    _send_panel(play, 0, npcid or 106)
end

function TreasureBasin.link(play, npcid, p2, p3, msgData)
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local __guardAction = Guard.normalizeAction(play, npcid, p2)
    if __guardAction == nil then
        return
    end
    p2 = __guardAction
    local __guardAllowedActions = Guard.newActionSet({1, 9})
    if not Guard.ensureActionAllowed(play, npcid, p2, __guardAllowedActions) then
        return
    end

    if p2 == 9 then
        _send_panel(play, 9, npcid)
        return
    end

    local data = _grant_artifact_if_needed(play, _get_state(play))
    if data.rebuilt >= 1 or _has_artifact(play) then
        Player.sendmsgEx(play, "你已拥有#57|【".._artifact_show_name().."】#218|")
        _refresh_attr(play)
        _refresh_item_bar(play)
        _try_auto_reward(play, npcid)
        _send_panel(play, 1, npcid)
        return
    end

    local itemName = tostring(_config.fragment_item or "聚宝盆碎片")
    local needNum = _toint(_config.fragment_count or 20)
    local haveNum = getbagitemcount(play, itemName)
    if haveNum < needNum then
        Player.sendmsgEx(play, string.format("还需要#57|【%s】#218|：#57|【%d/%d】#218|", itemName, haveNum, needNum))
        Guard.closeNpcAndAuto(play, npcid)
        return
    end

    Player.takeItemByTable(play, {{itemName, needNum}}, ",聚宝盆重铸", nil)
    data.rebuilt = 1
    _save_state(play, data)
    if zxrw_try_finish_current_mainline then zxrw_try_finish_current_mainline(play, "任务") end
    if shaguai and shaguai.jian then
        shaguai.jian(play, 33)
    end
    if shaguai and shaguai.jia then
        shaguai.jia(play, 34)
    end
    data = _grant_artifact_if_needed(play, data)
    _refresh_attr(play)
    _refresh_item_bar(play)
    Player.sendmsgEx(play, "成功重铸#57|【".._artifact_show_name().."】#218|，已发放实体背包神器#57")
    sendluamsg(play, 101, 9999, 0, 0, "npc_106")
    _send_panel(play, 1, npcid)
end

local function _refresh_all(play)
    _grant_artifact_if_needed(play, _get_state(play))
    _refresh_attr(play)
    _refresh_item_bar(play)
    _try_auto_reward(play, 106)
end

local function _on_login(play)
    _refresh_all(play)
end

local function _on_daily(play)
    _set_progress(play, 0)
    _set_claimed(play, false)
    _refresh_all(play)
end

-- 聚宝盆进度改为每击杀 1 只怪累计 1 点，满后直接自动发奖。
local function _on_kill_mon(play, mob)
    if not play or not mob then
        return
    end
    local data = _grant_artifact_if_needed(play, _get_state(play))
    if data.rebuilt < 1 then
        return
    end
    if not _equipped_where(play) then
        return
    end
    if not _is_claimed(play) and _get_progress(play) < _progress_need() then
        _set_progress(play, _get_progress(play) + 1)
    end
    _try_auto_reward(play, 106)
    _refresh_item_bar(play)
end
TreasureBasin.onKillMon = _on_kill_mon

local function _on_take_on(actor, itemobj, where, itemname, makeid)
    if not _is_artifact_name(itemname) and not _equipped_where(actor) then
        return
    end
    _refresh_attr(actor)
    _refresh_item_bar(actor)
    _try_auto_reward(actor, 106)
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
GameEvent.add(EventCfg.onTakeOnEx, _on_take_on, "聚宝盆")
GameEvent.add(EventCfg.onTakeOffEx, _on_take_off, "聚宝盆")

return TreasureBasin
