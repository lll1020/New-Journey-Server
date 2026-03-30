npc = {}
local _config = Guard.getConfig("npc_101")
local _attr_list_name = _config.attr_list_name or "马上发财活动属性"
local _token_name = _config.token_name or _config.name or "马上发财"
local _crown_title = _config.crown_title or "冠名"
local _skill_name = _config.skill_name or "十步一杀"
-- 工具方法：返回当天日期键
local function _today()
    return os.date("%Y%m%d")
end
-- 工具方法：按次数展开消耗表
local function _ensure_cost_table(cost, count)
    local ret = {}
    count = tonumber(count) or 1
    for _, v in ipairs(cost or {}) do
        table.insert(ret, {v[1], (tonumber(v[2]) or 0) * count})
    end
    return ret
end
local function _merge_attrs(dst, src)
    for _, attr in ipairs(src or {}) do
        local attrId = tonumber(attr[1])
        local attrValue = tonumber(attr[2]) or 0
        if attrId and attrValue ~= 0 then
            dst[attrId] = (dst[attrId] or 0) + attrValue
        end
    end
end
local function _count_owned(tbl)
    local num = 0
    for _, v in pairs(tbl or {}) do
        if tonumber(v) == 1 then
            num = num + 1
        end
    end
    return num
end
local function _get_1002_unlock_data(play)
    local T_szjl = Player.getJsonTableByVar(play, VarCfg.T_szjl)
    T_szjl.yjs = T_szjl.yjs or {}
    T_szjl.yjszj = T_szjl.yjszj or {}
    return T_szjl
end
local function _append_log(T_data, text)
    return
end
-- 存档方法：读取并补齐活动数据
local function _get_data(play)
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_马上发财"])
    T_data.token_count = tonumber(T_data.token_count) or 0 -- 当前可用抽奖次数
    T_data.draw_count = tonumber(T_data.draw_count) or 0 -- 累计抽奖次数
    T_data.exchange_date = tostring(T_data.exchange_date or "") -- 上次兑换重置日期
    T_data.exchange_used = tonumber(T_data.exchange_used) or 0 -- 当日已兑换次数
    T_data.claim_normal = T_data.claim_normal or {} -- 普通累抽奖励领取标记
    T_data.claim_crown = T_data.claim_crown or {} -- 冠名累抽奖励领取标记
    T_data.box_counts = T_data.box_counts or {low = 0, high = 0, super = 0} -- 自选箱数量表
    T_data.box_counts.low = tonumber(T_data.box_counts.low) or 0 -- 低级材料箱数量
    T_data.box_counts.high = tonumber(T_data.box_counts.high) or 0 -- 高级材料箱数量
    T_data.box_counts.super = tonumber(T_data.box_counts.super) or 0 -- 特级材料箱数量
    T_data.fashion = T_data.fashion or {} -- 时装收集标记表
    T_data.footstep = T_data.footstep or {} -- 足迹收集标记表
    T_data.placeholder = T_data.placeholder or {} -- 占位奖励累计表
    T_data.flags = T_data.flags or {} -- 额外状态标记表
    T_data.logs = {} -- 不记录抽奖日志
    T_data.day_card_claim_date = tostring(T_data.day_card_claim_date or "") -- 日卡礼包领取日期
    if T_data.exchange_date ~= _today() then
        T_data.exchange_date = _today()
        T_data.exchange_used = 0
    end
    return T_data
end
local function _save_data(play, T_data)
    Player.setJsonVarByTable(play, VarCfg["T_马上发财"], T_data)
end
local function _has_crown(play)
    return querymoney(play, 23) >= (tonumber(_config.crown_cost) or 0) or checktitle(play, _crown_title)
end
local function _get_today_charge(play)
    return tonumber(getplaydef(play, VarCfg.J_zscz) or 0) or 0
end
local function _is_day_card_claimed(T_data)
    return tostring(T_data.day_card_claim_date or "") == _today()
end
local function _get_daily_kills(play)
    return (tonumber(getplaydef(play, VarCfg.J_jsgw[1]) or 0) or 0) + (tonumber(getplaydef(play, VarCfg.J_jsgw[2]) or 0) or 0)
end
-- 状态方法：计算兑换次数与进度
local function _get_exchange_info(play, T_data)
    local totalKills = _get_daily_kills(play)
    local killPer = tonumber(_config.kill_per_exchange) or 188
    local dailyLimit = tonumber(_config.exchange_daily_limit) or 50
    local maxCanExchange = math.floor(totalKills / killPer)
    local exchangeUsed = tonumber(T_data.exchange_used) or 0
    if exchangeUsed < 0 then exchangeUsed = 0 end
    if exchangeUsed > dailyLimit then exchangeUsed = dailyLimit end
    if exchangeUsed > maxCanExchange then exchangeUsed = maxCanExchange end
    T_data.exchange_used = exchangeUsed
    local canExchange = math.max(0, math.min(dailyLimit - exchangeUsed, maxCanExchange - exchangeUsed))
    local progress = totalKills - exchangeUsed * killPer
    if progress < 0 then progress = 0 end
    if progress > killPer then progress = killPer end
    return canExchange, progress, totalKills
end
-- 属性方法：重算称号与套装属性
local function _refresh_bonus(play, T_data)
    T_data = T_data or _get_data(play)
    local unlockData = _get_1002_unlock_data(play)
    local attrs = {}
    if _config.title_reward and checktitle(play, _config.title_reward.name) then
        T_data.flags.title_msfc = 1
    end
    if tonumber(T_data.flags.title_msfc) == 1 and _config.title_reward then
        _merge_attrs(attrs, _config.title_reward.attr)
    end
    local fashionCount = _count_owned(unlockData.yjs)
    if fashionCount >= 6 then
        _merge_attrs(attrs, _config.fashion_bonus[6].attr)
    elseif fashionCount >= 3 then
        _merge_attrs(attrs, _config.fashion_bonus[3].attr)
    end
    local footstepCount = _count_owned(unlockData.yjszj)
    if footstepCount >= 5 then
        _merge_attrs(attrs, _config.footstep_bonus[5].attr)
        setskilldeccd(play, _config.footstep_bonus[5].skill.name, "=", _config.footstep_bonus[5].skill.dec_cd)
    else
        setskilldeccd(play, _skill_name, "=", 0)
    end
    local attrsstr = Player.getAttrTableToStr(attrs)
    if attrsstr and attrsstr ~= "" then
        Player.add_attlist(play, _attr_list_name, "=", attrsstr, 1)
    else
        Player.del_attlist(play, _attr_list_name)
    end
end
local function _reward_label(reward)
    if not reward then return "" end
    if reward.label and reward.label ~= "" then return reward.label end
    if reward.give and reward.give[1] then
        return tostring(reward.give[1][1]) .. "*" .. tostring(reward.give[1][2])
    end
    return tostring(reward.name or reward.kind or "reward")
end
local function _grant_item(play, reward, reason)
    if reward and reward.give then
        Player.rwjl(play, reward.give, reason, 1,0)
    end
end
local function _grant_placeholder(play, T_data, reward)
    local key = tostring(reward.name or reward.label or "placeholder")
    local num = tonumber(reward.num) or 1
    T_data.placeholder[key] = (tonumber(T_data.placeholder[key]) or 0) + num
    return key .. "*" .. tostring(num) .. "(占位)"
end
local function _grant_fashion(play, T_data, reward, reason)
    local idx = tostring(tonumber(reward.idx) or 0)
    local fashionCfg = (((teshudata or {})["npc_1002"] or {}).details or {}).sz or {}
    local name = reward.name or (fashionCfg[tonumber(idx) or 0] and fashionCfg[tonumber(idx) or 0].name) or ("时装：累抽" .. idx)
    if idx == "0" then return "" end
    Player.rwjl(play, {{name, 1}}, reason, 1, 0)
    return name
end
local function _grant_random_fashion(play, T_data, reason)
    local unlockData = _get_1002_unlock_data(play)
    local unowned = {}
    for _, cfg in ipairs(_config.fashion_pool or {}) do
        if tonumber(unlockData.yjs[tostring(cfg.idx)]) ~= 1 then
            table.insert(unowned, cfg)
        end
    end
    local pick = nil
    if #unowned > 0 then
        pick = unowned[math.random(1, #unowned)]
    elseif #(_config.fashion_pool or {}) > 0 then
        pick = _config.fashion_pool[math.random(1, #_config.fashion_pool)]
    end
    if not pick then return "" end
    return _grant_fashion(play, T_data, {idx = pick.idx, name = pick.name}, reason)
end
local function _grant_footstep(play, T_data, reward)
    local idx = tostring(tonumber(reward.idx) or 0)
    local footstepCfg = (((teshudata or {})["npc_1002"] or {}).details or {}).zj or {}
    local name = reward.name or (footstepCfg[tonumber(idx) or 0] and footstepCfg[tonumber(idx) or 0].name) or ("累抽足迹" .. idx)
    if idx == "0" then
        return name
    end
    Player.rwjl(play, {{name, 1}}, ",msfc_footstep", 1, 0)
    return name
end
local function _grant_title(play, T_data, reward)
    local name = tostring(reward.name or _token_name)
    T_data.flags.title_msfc = 1
    if not checktitle(play, name) then
        Player.title_give(play, name, 1)
    end
    return "称号：" .. name
end
local function _get_box_item_name(boxType)
    local boxMap = {
        low = "低级材料自选箱",
        high = "高级材料自选箱",
        super = "特级材料自选箱",
    }
    return boxMap[tostring(boxType or "low")] or "低级材料自选箱"
end
local function _grant_box(play, reward, reason)
    local boxType = tostring(reward.box or "low")
    local num = tonumber(reward.num) or 1
    local boxName = _get_box_item_name(boxType)
    Player.rwjl(play, {{boxName, num}}, reason, 1,0)
    return tostring(reward.label or (boxName .. "*" .. tostring(num)))
end
-- 奖励方法：按奖励类型发放
local function _grant_reward(play, T_data, reward, reason)
    if not reward then return nil end
    local kind = tostring(reward.kind or "item")
    if kind == "item" then
        _grant_item(play, reward, reason)
        return _reward_label(reward)
    elseif kind == "placeholder" then
        return _grant_placeholder(play, T_data, reward)
    elseif kind == "fashion" then
        return _grant_fashion(play, T_data, reward, reason)
    elseif kind == "fashion_random" then
        return _grant_random_fashion(play, T_data, reason)
    elseif kind == "footstep" then
        return _grant_footstep(play, T_data, reward)
    elseif kind == "title" then
        return _grant_title(play, T_data, reward)
    elseif kind == "box" then
        return _grant_box(play, reward, reason)
    end
    return nil
end
local function _grant_reward_pack(play, T_data, pack, reason)
    local labels = {}
    if not pack then return labels end
    if pack.main then
        local label = _grant_reward(play, T_data, pack.main, reason)
        if label and label ~= "" then table.insert(labels, label) end
    end
    if pack.extra then
        local label = _grant_reward(play, T_data, pack.extra, reason)
        if label and label ~= "" then table.insert(labels, label) end
    end
    return labels
end
local function _roll_pool(pool)
    local total = 0
    for _, reward in ipairs(pool or {}) do
        total = total + (tonumber(reward.rate) or 0)
    end
    if total <= 0 then return nil end
    local rnd = math.random(1, total)
    local acc = 0
    for _, reward in ipairs(pool or {}) do
        acc = acc + (tonumber(reward.rate) or 0)
        if rnd <= acc then return reward end
    end
    return nil
end
local function _find_milestone(aid, json_data)
    local idx = tonumber(json_data.idx or aid)
    if idx and _config.milestones[idx] then return idx, _config.milestones[idx] end
    local draw = tonumber(json_data.draw or aid)
    if draw then
        for i, cfg in ipairs(_config.milestones or {}) do
            if tonumber(cfg.draw) == draw then return i, cfg end
        end
    end
    return nil, nil
end
local function _claim_milestone_range(play, T_data, p2, milestoneIdx)
    local bucket = p2 == 5 and T_data.claim_normal or T_data.claim_crown
    local allLabels = {}
    local claimedCount = 0
    for idx, cfg in ipairs(_config.milestones or {}) do
        if idx > milestoneIdx then break end
        if T_data.draw_count >= tonumber(cfg.draw or 0) and tonumber(bucket[tostring(idx)]) ~= 1 then
            local rewardPack = p2 == 5 and cfg.normal or cfg.crown
            local labels = _grant_reward_pack(play, T_data, rewardPack, ",msfc_milestone")
            bucket[tostring(idx)] = 1
            claimedCount = claimedCount + 1
            for _, label in ipairs(labels) do
                table.insert(allLabels, label)
            end
        end
    end
    return claimedCount, allLabels
end
local function _claim_day_card(play, T_data)
    local cfg = _config.day_card or {}
    local needCharge = tonumber(cfg.need_charge) or 28
    local titleName = tostring(cfg.title or "日卡")
    local tokenCount = tonumber(cfg.token_count) or 0
    if _is_day_card_claimed(T_data) then
        return false, "今日日卡礼包已领取#57"
    end
    if _get_today_charge(play) < needCharge then
        return false, string.format("今日累计充值不足%d元#57", needCharge)
    end
    if titleName ~= "" and not checktitle(play, titleName) then
        Player.title_give(play, titleName, 1)
    end
    if type(cfg.rewards) == "table" and #cfg.rewards > 0 then
        Player.rwjl(play, cfg.rewards, ",msfc_day_card", 1, 0)
    end
    if tokenCount > 0 then
        T_data.token_count = (tonumber(T_data.token_count) or 0) + tokenCount
    end
    T_data.day_card_claim_date = _today()
    return true, titleName
end
-- 面板方法：组装客户端展示数据
local function _build_panel_data(play)
    local T_data = _get_data(play)
    local unlockData = _get_1002_unlock_data(play)
    local exchangeAvailable, exchangeProgress, totalKills = _get_exchange_info(play, T_data)
    local data = {}
    data.T_data = T_data
    data.token_name = _token_name
    data.token_count = T_data.token_count
    data.draw_count = T_data.draw_count
    data.exchange_available = exchangeAvailable
    data.exchange_progress = exchangeProgress
    data.exchange_need = _config.kill_per_exchange
    data.exchange_limit = _config.exchange_daily_limit
    data.exchange_used = T_data.exchange_used
    data.total_kills = totalKills
    data.has_crown = _has_crown(play) and 1 or 0
    data.crown_cost = _config.crown_cost
    data.buy_cost = _config.buy_cost
    data.draw_once_cost = _config.draw_once_cost
    data.draw_ten_cost = _config.draw_ten_cost
    data.fashion_pity_every = _config.fashion_pity_every
    data.box_counts = {
        low = getbagitemcount(play, "低级材料自选箱") or 0,
        high = getbagitemcount(play, "高级材料自选箱") or 0,
        super = getbagitemcount(play, "特级材料自选箱") or 0,
    }
    data.logs = {}
    data.placeholder = T_data.placeholder
    data.fashion_count = _count_owned(unlockData.yjs)
    data.footstep_count = _count_owned(unlockData.yjszj)
    data.title_owned = tonumber(T_data.flags.title_msfc) or 0
    data.today_charge = _get_today_charge(play)
    data.day_card_need_charge = tonumber((_config.day_card or {}).need_charge) or 28
    data.day_card_claimed = _is_day_card_claimed(T_data) and 1 or 0
    data.day_card_has_title = checktitle(play, ((_config.day_card or {}).title or "日卡")) and 1 or 0
    return data, T_data
end
-- 面板方法：刷新101号NPC数据
local function _refresh_panel(play, npcid, p2)
    local data = _build_panel_data(play)
    sendluamsg(play, 100, npcid, p2 or 0, 0, tbl2json(data))
end
-- 抽奖方法：处理单抽十连与保底
local function _do_draw(play, T_data, drawTimes)
    local labels = {}
    drawTimes = tonumber(drawTimes) or 1
    if T_data.token_count < drawTimes then
        return false, labels, "锄子次数不足#57"
    end
    T_data.token_count = T_data.token_count - drawTimes
    for _ = 1, drawTimes do
        T_data.draw_count = T_data.draw_count + 1
        local reward = _roll_pool(_config.pool)
        local label = _grant_reward(play, T_data, reward, ",msfc_draw")
        if label and label ~= "" then
            table.insert(labels, label)
            _append_log(T_data, "抽奖获得：" .. label)
        end
        for _, g in ipairs(_config.guarantee_boxes or {}) do
            if tonumber(g.every) and tonumber(g.every) > 0 and T_data.draw_count % tonumber(g.every) == 0 then
                local glabel = _grant_reward(play, T_data, {kind = "box", box = g.box, num = g.num, label = g.label}, ",msfc_guarantee")
                if glabel and glabel ~= "" then
                    table.insert(labels, glabel)
                    _append_log(T_data, "保底获得：" .. glabel)
                end
            end
        end
        if tonumber(_config.fashion_pity_every) and tonumber(_config.fashion_pity_every) > 0 and T_data.draw_count % tonumber(_config.fashion_pity_every) == 0 then
            local flabel = _grant_reward(play, T_data, {kind = "fashion_random"}, ",msfc_fashion")
            if flabel and flabel ~= "" then
                table.insert(labels, flabel)
                _append_log(T_data, "时装保底：" .. flabel)
            end
        end
    end
    return true, labels
end
-- 开箱方法：材料箱改为背包物品，需在背包中直接使用
local function _open_box(play, T_data, boxType, choiceIdx)
    return false, "材料自选箱已改为背包物品，请在背包中直接使用#57"
end
local function _on_login(play)
    local T_data = _get_data(play)
    _save_data(play, T_data)
    _refresh_bonus(play, T_data)
end
-- 入口方法：打开活动面板
function npc.main(play, npcid)
    local T_data = _get_data(play)
    _save_data(play, T_data)
    _refresh_panel(play, npcid, 0)
end
-- 交互方法：p2对应单抽十连兑换购买领奖开箱
function npc.link(play, npcid, p2, p3, msgData)
    if not Guard.ensurePlayer(play, npcid) then return end
    local __guardAction = Guard.normalizeAction(play, npcid, p2)
    if __guardAction == nil then return end
    p2 = __guardAction
    local __guardAllowedActions = Guard.newActionSet({1,2,3,4,5,6,7,8})
    if not Guard.ensureActionAllowed(play, npcid, p2, __guardAllowedActions) then return end
    local json_data = {}
    if msgData and msgData ~= "" then
        local tmp = json2tbl(msgData)
        if type(tmp) == "table" then json_data = tmp end
    end
    local T_data = _get_data(play)
    if p2 == 1 or p2 == 2 then -- draw
        local drawTimes = p2 == 1 and (tonumber(_config.draw_once_cost) or 1) or (tonumber(_config.draw_ten_cost) or 10)
        local ok, labels, err = _do_draw(play, T_data, drawTimes)
        if not ok then Player.sendmsgEx(play, err) return end
        Player.sendmsgEx(play, "本次获得：|【"..table.concat(labels, "、").."】#249|")
        _save_data(play, T_data)
        _refresh_bonus(play, T_data)
        _refresh_panel(play, npcid, p2)
    elseif p2 == 3 then -- exchange by kills
        local count = tonumber(json_data.count or p3) or 1
        if count < 1 then count = 1 end
        local canExchange, progress = _get_exchange_info(play, T_data)
        if canExchange <= 0 then
            Player.sendmsgEx(play, string.format("当前杀怪进度不足：#57|【%d/%d】#249|，今日已兑换#57|【%d次】#249|", progress, tonumber(_config.kill_per_exchange) or 188, tonumber(T_data.exchange_used) or 0))
            return
        end
        if count > canExchange then count = canExchange end
        T_data.exchange_used = T_data.exchange_used + count
        T_data.token_count = T_data.token_count + count
        _append_log(T_data, "杀怪兑换：获得" .. _token_name .. "*" .. count)
        _save_data(play, T_data)
        Player.sendmsgEx(play, "兑换成功，获得|【".._token_name.."】#249|*" .. count)
        _refresh_panel(play, npcid, p2)
    elseif p2 == 4 then -- buy by cost
        local count = tonumber(json_data.count or p3) or 1
        if count < 1 then count = 1 end
        local cost = _ensure_cost_table(_config.buy_cost, count)
        local name, num = Player.checkItemNumByTable(play, cost)
        if name then
            Player.sendmsgEx(play, string.format("你的#57|【%s】#249|不足：#57|【%d】#249|", name, num))
            return
        end
        Player.takeItemByTable(play, cost, ",msfc_buy", nil)
        T_data.token_count = T_data.token_count + count
        _append_log(T_data, "购买：获得" .. _token_name .. "*" .. count)
        _save_data(play, T_data)
        Player.sendmsgEx(play, "购买成功，获得|【".._token_name.."】#249|*" .. count)
        _refresh_panel(play, npcid, p2)
    elseif p2 == 5 or p2 == 6 then -- 领取累抽奖励
        local milestoneIdx, milestone = _find_milestone(p3, json_data)
        if not milestone then Player.sendmsgEx(play, "参数错误#57") return end
        if T_data.draw_count < tonumber(milestone.draw or 0) then
            Player.sendmsgEx(play, "累计抽奖次数不足#57|，暂时无法领取#57")
            return
        end
        if p2 == 6 and not _has_crown(play) then
            Player.sendmsgEx(play, "你尚未达到#57|【冠名条件】#249|，无法领取冠名奖励#57")
            return
        end
        local claimedCount, labels = _claim_milestone_range(play, T_data, p2, milestoneIdx)
        if claimedCount <= 0 then
            Player.sendmsgEx(play, "该档位及此前奖励已领取，无需重复领取#57")
            return
        end
        _append_log(T_data, "领取累抽奖励：" .. table.concat(labels, "、"))
        _save_data(play, T_data)
        _refresh_bonus(play, T_data)
        Player.sendmsgEx(play, "领取成功：|【"..table.concat(labels, "、").."】#249|")
        _refresh_panel(play, npcid, p2)
    elseif p2 == 8 then -- 领取日卡礼包
        local ok, msg = _claim_day_card(play, T_data)
        if not ok then Player.sendmsgEx(play, msg) return end
        _save_data(play, T_data)
        _refresh_bonus(play, T_data)
        Player.sendmsgEx(play, "领取成功：|【"..tostring((_config.day_card or {}).title or "日卡") .. "、元宝*100000、" .. _token_name .. "次数*" .. tostring(tonumber(((_config.day_card or {}).token_count) or 0) or 0).."】#249|")
        _refresh_panel(play, npcid, p2)
    elseif p2 == 7 then -- 打开材料箱
        local boxType = tostring(json_data.box_type or json_data.box or "")
        if boxType == "1" then boxType = "low" end
        if boxType == "2" then boxType = "high" end
        if boxType == "3" then boxType = "super" end
        if boxType == "" then
            if tonumber(p3) == 1 then boxType = "low"
            elseif tonumber(p3) == 2 then boxType = "high"
            elseif tonumber(p3) == 3 then boxType = "super" end
        end
        local choiceIdx = tonumber(json_data.idx or json_data.choice or 0)
        local ok, msg = _open_box(play, T_data, boxType, choiceIdx)
        if not ok then Player.sendmsgEx(play, msg) return end
        _save_data(play, T_data)
        Player.sendmsgEx(play, "开启成功，获得|【"..tostring(msg).."】#249|")
        _refresh_panel(play, npcid, p2)
    end
end
GameEvent.add(EventCfg.onLoginEnd, _on_login, _token_name)
GameEvent.add(EventCfg.onKFLogin, _on_login, _token_name)
return npc
