npc = {}

-- 残魂商店：管理残魂积分、火毒值、奖励兑换与称号逻辑。
local _config = Guard.getConfig("npc_83")
local _var_name = VarCfg["T_残魂商店"]
local _title_cfg = (_config and _config.title_reward) or {}
local _title_name = tostring(_title_cfg.name or "向死而生")
local _point_name = tostring(_config.point_name or "残魂值")
local _fire_name = tostring(_config.fire_name or "业火值")

-- 统一处理可能为空的数值。
local function _toint(v)
    return tonumber(v) or 0
end

-- 读取并规范化玩家商店存档数据。
local function _get_data(play)
    local data = Player.getJsonTableByVar(play, _var_name) or {}
    data.point = _toint(data.point)
    data.fire = _toint(data.fire)
    data.buy = type(data.buy) == "table" and data.buy or {}
    data.title_claim = _toint(data.title_claim)
    data.level_bonus = _toint(data.level_bonus)
    return data
end

-- 持久化玩家商店存档数据。
local function _save_data(play, data)
    Player.setJsonVarByTable(play, _var_name, data)
end

-- 读取某个商店条目的已购买次数。
local function _get_buy_num(data, idx)
    return _toint((data.buy or {})[tostring(idx)])
end

-- 检查玩家是否已拥有最终称号。
local function _has_title(play)
    return checktitle(play, _title_name)
end


-- 组装商店面板下发给客户端的数据。
local function _build_payload(play)
    local data = _get_data(play)
    return {
        T_data = data,
        point = data.point,
        fire = data.fire,
        has_title = _has_title(play) and 1 or 0,
        title_bonus_done = Player.hasTitleLevelBonusReward(play, _title_name) and 1 or 0,
    }
end

-- 发放物品奖励或最终称号奖励。
local function _grant_reward(play, data, reward, reason)
    if type(reward) ~= "table" then
        return false
    end
    local kind = tostring(reward.kind or "item")
    if kind == "item" then
        if type(reward.give) ~= "table" or #reward.give <= 0 then
            return false
        end
        Player.rwjl(play, reward.give, reason or _point_name, 1, 0)
        return true
    elseif kind == "title" then
        if not _has_title(play) then
            Player.title_give(play, tostring(reward.name or _title_name))
        end
        data.title_claim = 1
        return true
    end
    return false
end

-- 打开残魂商店面板。
function npc.main(play, npcid)
    sendluamsg(play, 100, npcid, 0, 0, tbl2json(_build_payload(play)))
end

-- 处理兑换、刷新与客户端回调操作。
function npc.link(play, npcid, p2, p3, msgData)
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local __guardAction = Guard.normalizeAction(play, npcid, p2)
    if __guardAction == nil then
        return
    end
    p2 = __guardAction
    local __guardAllowedActions = Guard.newActionSet({1,2,9})
    if not Guard.ensureActionAllowed(play, npcid, p2, __guardAllowedActions) then
        return
    end

    local json_data = json2tbl(msgData) or {}
    local idx = _toint(json_data.idx or json_data.id or p3)
    local data = _get_data(play)

    if p2 == 1 then
        local cfg = (_config.shop or {})[idx]
        if not cfg then
            Player.sendmsgEx(play, "参数错误#57")
            return
        end
        local reward = cfg.reward or {}
        local limit = _toint(cfg.limit)
        if limit > 0 and _get_buy_num(data, idx) >= limit then
            Player.sendmsgEx(play, "该奖励已达兑换上限#57")
            return
        end
        if tostring(reward.kind or "") == "title" and _has_title(play) then
            Player.sendmsgEx(play, "你已经拥有该称号#57")
            return
        end
        local cost = _toint(cfg.cost)
        if data.point < cost then
            Player.sendmsgEx(play, string.format("你的#57|【%s】#218|不足：#57|【%d】#218|", _point_name, cost))
            return
        end
        if not _grant_reward(play, data, reward, "残魂商店") then
            Player.sendmsgEx(play, "奖励配置未完成#57")
            return
        end
        data.point = data.point - cost
        data.buy[tostring(idx)] = _get_buy_num(data, idx) + 1
        _save_data(play, data)
        Player.sendmsgEx(play, string.format("兑换成功，获得#57|【%s】#218|", tostring(cfg.name or "奖励")))
        sendluamsg(play, 100, npcid, 1, idx, tbl2json(_build_payload(play)))
    elseif p2 == 2 then
        sendluamsg(play, 100, npcid, 2, 0, tbl2json(_build_payload(play)))
    elseif p2 == 9 then
        sendluamsg(play, 100, npcid, 9, idx, tbl2json(_build_payload(play)))
    end
end

-- 对外接口：增加残魂积分。
function npc.add_point(play, num, reason)
    num = _toint(num)
    if num <= 0 then
        return 0
    end
    local data = _get_data(play)
    data.point = data.point + num
    _save_data(play, data)
    if reason and reason ~= "" then
        Player.sendmsgEx(play, string.format("%s，#57|【%s】#218|+%d", reason, _point_name, num))
    end
    return data.point
end

-- 对外接口：扣除残魂积分。
function npc.cost_point(play, num)
    num = _toint(num)
    if num <= 0 then
        return true
    end
    local data = _get_data(play)
    if data.point < num then
        return false
    end
    data.point = data.point - num
    _save_data(play, data)
    return true
end

-- 对外接口：增减火毒值并返回最新结果。
function npc.add_fire(play, num)
    num = _toint(num)
    if num == 0 then
        return _toint((_get_data(play) or {}).fire)
    end
    local data = _get_data(play)
    data.fire = math.max(0, data.fire + num)
    _save_data(play, data)
    return data.fire
end

-- 对外接口：减少火毒值。
function npc.reduce_fire(play, num)
    return npc.add_fire(play, -_toint(num))
end

-- 对外接口：获取当前残魂商店存档数据。
function npc.get_data(play)
    return _get_data(play)
end


-- 残魂值先按“被玩家击杀+10”落地，后续业火系统可直接复用 add_point。
local function _on_playdie(play, killer)
    if killer and getbaseinfo(killer, ConstCfg.gbase.isplayer) then
        npc.add_point(play, _toint(_config.die_add_point or 10), "你被玩家击杀")
    end
end

-- 向死而生：对指定目标额外造成20%真实伤害，避免依赖称号 Buff 表配置。
local function _on_attack_damage_monster(play, target, damage)
    if not _has_title(play) then
        return
    end
    if not target or getbaseinfo(target, ConstCfg.gbase.isplayer) then
        return
    end
    local need_name = tostring(_title_cfg.target or "天罚猎杀者")
    if need_name == "" then
        return
    end
    local mon_name = tostring(getbaseinfo(target, ConstCfg.gbase.name) or "")
    if mon_name == "" or not string.find(mon_name, need_name, 1, true) then
        return
    end
    local pct = _toint(_title_cfg.damage_pct)
    local extra = math.floor((_toint(damage) * pct) / 100)
    if extra > 0 then
        humanhp(target, "-", extra, 106, 0, play, 1)
    end
end

GameEvent.add(EventCfg.onPlaydie, _on_playdie, "残魂商店")
GameEvent.add(EventCfg.onAttackDamageMonster, _on_attack_damage_monster, "残魂商店")

return npc

