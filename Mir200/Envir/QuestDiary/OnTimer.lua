--全局定时器
local _fairy_fate_red_cfg = include("lua/Data/fairy_fate_cfg.lua") or {}
-----------------全局1号60秒定时器----------------
-- 读取玩家在指定轮次的天选 roll 点
local function _txzr_get_roll_point(play, roundIdx)
    local txzr_data = json2tbl(getplaydef(play, VarCfg.T_txzr))
    return tonumber(txzr_data[roundIdx]) or 0
end
-- 获取天选活动基础配置（单源：teshudata.anniu_506）
local function _txzr_get_base_cfg()
    local cfg = teshudata and teshudata["anniu_506"] or {}
    return type(cfg) == "table" and cfg or {}
end
-- 读取天选名次奖励列表（1~10）
local function _txzr_get_reward_list()
    local cfg = _txzr_get_base_cfg()
    local rewards = {}
    for i = 1, 10 do
        rewards[i] = cfg[i]
    end
    return rewards
end
-- 读取天选参与奖励配置（未进前十）
local function _txzr_get_join_reward_cfg()
    local cfg = _txzr_get_base_cfg()
    local join = cfg.join_reward
    if type(join) == "table" and join.item and join.item ~= "" then
        return {
            item = join.item,
            count = tonumber(join.count) or 1,
            desc = join.desc or "",
        }
    end
    return nil
end
-- 读取天选第一名额外神器配置
local function _txzr_get_shenqi_cfg()
    local cfg = _txzr_get_base_cfg()
    if type(cfg.shenqi) == "table" then
        return cfg.shenqi
    end
    return {}
end
-- 读取天选活动注意事项配置
local function _txzr_get_notice_cfg()
    local cfg = _txzr_get_base_cfg()
    if type(cfg.notice) == "table" then
        return cfg.notice
    end
    return {}
end
-- 为指定玩家抽取未重复的背包神器
local _TCPPK_ROUND_VAR = "TCPPK_ROUND"
local _TCPPK_EQUIP_ROUND_VAR = "TCPPK_EQUIP_ROUND"
local _TCPPK_EQUIP_COUNT_VAR = "TCPPK_EQUIP_TOTAL"
local _TCPPK_REWARD_CACHE = nil

local function _tcppk_begin_round()
    local round = tonumber(Player.GetGlobalTempInt(_TCPPK_ROUND_VAR) or 0) or 0
    round = round + 1
    Player.SetGlobalTempInt(_TCPPK_ROUND_VAR, round)
    return round
end

local function _tcppk_get_round()
    return tonumber(Player.GetGlobalTempInt(_TCPPK_ROUND_VAR) or 0) or 0
end

local function _tcppk_get_reward_cache()
    if _TCPPK_REWARD_CACHE then
        return _TCPPK_REWARD_CACHE.normal, _TCPPK_REWARD_CACHE.equip, _TCPPK_REWARD_CACHE.equipSet, _TCPPK_REWARD_CACHE.categoryWeight, _TCPPK_REWARD_CACHE.maxEquip
    end
    local cfg = type(paokujl) == "table" and paokujl or {}
    local normal = type(cfg.normal) == "table" and cfg.normal or {}
    local equip = type(cfg.equip) == "table" and cfg.equip or {}
    local equipSet = {}
    for _, rewardName in ipairs(equip) do
        equipSet[rewardName] = true
    end
    local categoryWeight = type(cfg.category_weight) == "table" and cfg.category_weight or {}
    local maxEquip = tonumber(cfg.max_equip_per_round or 2) or 2
    _TCPPK_REWARD_CACHE = {normal = normal, equip = equip, equipSet = equipSet, categoryWeight = categoryWeight, maxEquip = maxEquip}
    return normal, equip, equipSet, categoryWeight, maxEquip
end

local function _tcppk_get_activity_equip_count()
    local round = _tcppk_get_round()
    local savedRound = tonumber(Player.GetGlobalTempInt(_TCPPK_EQUIP_ROUND_VAR) or 0) or 0
    if savedRound ~= round then
        return 0
    end
    return tonumber(Player.GetGlobalTempInt(_TCPPK_EQUIP_COUNT_VAR) or 0) or 0
end

local function _tcppk_set_activity_equip_count(count)
    count = math.max(0, tonumber(count) or 0)
    Player.SetGlobalTempInt(_TCPPK_EQUIP_ROUND_VAR, _tcppk_get_round())
    Player.SetGlobalTempInt(_TCPPK_EQUIP_COUNT_VAR, count)
end

local function _tcppk_pick_reward(play)
    local normal, equip, equipSet, categoryWeight, maxEquip = _tcppk_get_reward_cache()
    local equipCount = _tcppk_get_activity_equip_count()
    local normalWeight = tonumber(categoryWeight.normal or 50) or 50
    local equipWeight = tonumber(categoryWeight.equip or 50) or 50
    if #normal <= 0 then
        normalWeight = 0
    end
    if #equip <= 0 or equipCount >= maxEquip then
        equipWeight = 0
    end
    if normalWeight <= 0 and equipWeight <= 0 then
        return nil
    end

    -- Pick category first, then item; long equip list should not dominate reward rate.
    local useEquip = false
    if equipWeight > 0 and normalWeight > 0 then
        useEquip = math.random(normalWeight + equipWeight) > normalWeight
    elseif equipWeight > 0 then
        useEquip = true
    end

    local pool = useEquip and equip or normal
    if #pool <= 0 then
        return nil
    end
    local rewardName = pool[math.random(#pool)]
    if equipSet[rewardName] then
        _tcppk_set_activity_equip_count(equipCount + 1)
    end
    return rewardName
end

local function _txzr_pick_unique_shenqi(txzz_data, playerName)
    local shenqi_cfg = _txzr_get_shenqi_cfg()
    if #shenqi_cfg <= 0 then
        return nil
    end
    txzz_data["sq_rec"] = txzz_data["sq_rec"] or {}
    local player_rec = txzz_data["sq_rec"][playerName]
    if type(player_rec) ~= "table" then
        player_rec = {}
        txzz_data["sq_rec"][playerName] = player_rec
    end
    local candidates = {}
    for _, cfg in ipairs(shenqi_cfg) do
        if cfg and cfg.name and not player_rec[cfg.name] then
            table.insert(candidates, cfg.name)
        end
    end
    if #candidates <= 0 then
        return nil
    end
    local picked = candidates[math.random(#candidates)]
    player_rec[picked] = 1
    return picked
end
-- 持久化玩家天选轮次结果与神器记录
local function _txzr_save_player_history(player, roundIdx, rankIdx, rollPoint, rewardName, shenqiName)
    if not player then
        return
    end
    local hdjl = Player.getJsonTableByVar(player, VarCfg.T_hdjl)
    hdjl["txzr"] = hdjl["txzr"] or {}
    hdjl["txzr"]["md" .. roundIdx] = {
        rank = rankIdx,
        roll = rollPoint,
        reward = rewardName,
    }
    if shenqiName and shenqiName ~= "" then
        hdjl["txzr"]["sq"] = hdjl["txzr"]["sq"] or {}
        hdjl["txzr"]["sq"][shenqiName] = 1
        hdjl["txzr"]["md" .. roundIdx]["sq"] = shenqiName
    end
    Player.setJsonVarByTable(player, VarCfg.T_hdjl, hdjl)
end
-- 广播当前轮次 roll 点前三名结果
local function _txzr_broadcast_roll(roundIdx, rankData)
    local showCount = math.min(3, #rankData)
    if showCount <= 0 then
        return
    end
    local msgList = {}
    for i = 1, showCount do
        local one = rankData[i]
        msgList[#msgList + 1] = string.format("%s名:%s(%s)", constant.pz_hanzi[i] or tostring(i), one[1], tostring(one[2] or 0))
    end
    local roundText = constant.pz_hanzi[roundIdx] or tostring(roundIdx)
    local msg = "天选之人：第" .. roundText .. "轮roll点结果 -> " .. table.concat(msgList, "，")
    sendmovemsg("0", 1, 253, 0, 300, 1, msg)
    sendmovemsg("0", 1, 249, 0, 250, 1, msg)
end
local function _txzr_broadcast_reward_rollscreen(roundIdx, rankData, rewardList, txzz_data)
    if type(rankData) ~= "table" or #rankData <= 0 then
        return
    end
    local players = getplayerlst() or {}
    if #players <= 0 then
        return
    end
    local maxCount = math.min(10, #rankData)
    local roundText = constant.pz_hanzi[roundIdx] or tostring(roundIdx)
    for i = 1, maxCount do
        local one = rankData[i]
        local playerName = tostring(one[1] or "")
        local rewardName = tostring((rewardList and rewardList[i]) or "")
        local rankText = constant.pz_hanzi[i] or tostring(i)
        local msg = string.format("天选之人第%s轮开奖：%s获得第%s名，奖励[%s]", roundText, playerName, rankText, rewardName)
        if i == 1 and type(txzz_data) == "table" and type(txzz_data["sq" .. roundIdx]) == "table" and txzz_data["sq" .. roundIdx].item and txzz_data["sq" .. roundIdx].item ~= "" then
            msg = string.format("天选之人第%s轮开奖：%s获得第%s名，奖励[%s]，额外获得[%s]", roundText, playerName, rankText, rewardName, tostring(txzz_data["sq" .. roundIdx].item))
        end
        sendmovemsg("0", 1, 253, 0, 300, 1, msg)
        sendmovemsg("0", 1, 249, 0, 250, 1, msg)
    end
end
-- 获取随机夺宝配置（单源：teshudata.anniu_507.sjdb）
local function _sjdb_get_cfg()
    local cfg = teshudata and teshudata["anniu_507"] or {}
    cfg = type(cfg) == "table" and cfg or {}
    local sjdb = cfg.sjdb
    if type(sjdb) ~= "table" then
        return nil
    end
    if type(sjdb.map) ~= "string" or sjdb.map == "" then
        return nil
    end
    if type(sjdb.center) ~= "table" then
        return nil
    end
    if tonumber(sjdb.center.x) == nil or tonumber(sjdb.center.y) == nil then
        return nil
    end
    if type(sjdb.circles) ~= "table" or #sjdb.circles <= 0 then
        return nil
    end
    return sjdb
end
-- 随机夺宝：按 teshudata 配置投放奖励
local function _sjdb_throw_by_cfg(sjdb_cfg)
    if not sjdb_cfg then
        return false
    end
    local mapName = sjdb_cfg.map
    local cx = tonumber(sjdb_cfg.center.x) or 215
    local cy = tonumber(sjdb_cfg.center.y) or 53
    local keepSec = tonumber(sjdb_cfg.keep_sec) or 300
    local hasThrow = false
    for _, circle in ipairs(sjdb_cfg.circles or {}) do
        local range = tonumber(circle and circle.range) or 200
        for _, drop in ipairs((circle and circle.drops) or {}) do
            local itemName = drop and drop.item or ""
            local dropCount = tonumber(drop and drop.count) or 0
            if itemName ~= "" and dropCount > 0 then
                throwitem("0", mapName, cx, cy, range, itemName, dropCount, keepSec, false, true, false, false)
                hasThrow = true
            end
        end
    end
    return hasThrow
end
-- 随机夺宝：旧常量兜底投放，避免配置缺失导致活动异常
local function _sjdb_throw_fallback()
    local hasThrow = false
    for _, v in ipairs(constant.pz_yxhdbg or {}) do
        if v and v[1] and tonumber(v[2]) and tonumber(v[2]) > 0 then
            throwitem("0", "天降财宝", 215, 53, 200, v[1], tonumber(v[2]), 300, false, true, false, false)
            hasThrow = true
        end
    end
    return hasThrow
end
-- 获取全民答题配置（单源：teshudata.anniu_507.qmdt）
local function _qmdt_get_cfg()
    local cfg = teshudata and teshudata["anniu_507"] and teshudata["anniu_507"].qmdt or nil
    if type(cfg) ~= "table" then
        return nil
    end
    if type(cfg.questions) ~= "table" or #cfg.questions <= 0 then
        return nil
    end
    cfg.start_minute = tonumber(cfg.start_minute) or 33
    cfg.question_count = math.min(tonumber(cfg.question_count) or 5, #cfg.questions)
    cfg.per_question_sec = tonumber(cfg.per_question_sec) or 52
    cfg.final_question_sec = tonumber(cfg.final_question_sec) or 30
    cfg.settle_before_sec = tonumber(cfg.settle_before_sec) or 5
    cfg.base_score = tonumber(cfg.base_score) or 100
    cfg.map = tostring(cfg.map or "全民答题")
    cfg.answer_mob = tostring(cfg.answer_mob or "问题答案")
    cfg.answer_range = tonumber(cfg.answer_range) or 5
    cfg.enter_pos = type(cfg.enter_pos) == "table" and cfg.enter_pos or {50, 50}
    cfg.answer_points = type(cfg.answer_points) == "table" and cfg.answer_points or {
        {x = 43, y = 50}, {x = 57, y = 50}, {x = 50, y = 43}, {x = 50, y = 57},
    }
    return cfg
end
local function _qmdt_get_state()
    local raw = getsysvar(VarCfg["A_全民答题json"])
    if raw == "" then
        return {}
    end
    local tb = json2tbl(raw)
    return type(tb) == "table" and tb or {}
end
local function _qmdt_save_state(state)
    setsysvar(VarCfg["A_全民答题json"], tbl2json(state or {}))
end
local function _qmdt_question_duration(cfg, qidx)
    if tonumber(qidx) >= tonumber(cfg.question_count) then
        return tonumber(cfg.final_question_sec) or 30
    end
    return tonumber(cfg.per_question_sec) or 52
end
local function _qmdt_get_answer_point(cfg, idx)
    local point = cfg.answer_points and cfg.answer_points[idx]
    if type(point) ~= "table" then
        return nil
    end
    return {x = tonumber(point.x or point[1]) or 0, y = tonumber(point.y or point[2]) or 0}
end
local function _qmdt_build_prompt(q, qidx, total)
    local lines = {"第" .. tostring(qidx) .. "/" .. tostring(total) .. "题：" .. tostring(q.title or "")}
    for i, one in ipairs(q.options or {}) do
        lines[#lines + 1] = tostring(i) .. "." .. tostring(one)
    end
    lines[#lines + 1] = "请进入全民答题地图，站到正确答案旁等待结算"
    return table.concat(lines, "\n")
end
local function _qmdt_build_notice(q, qidx, total, duration, settleBefore)
    local opts = {}
    for i, one in ipairs(q.options or {}) do
        opts[#opts + 1] = tostring(i) .. "." .. tostring(one)
    end
    return "全民答题：第" .. tostring(qidx) .. "/" .. tostring(total) .. "题【" .. tostring(q.title or "") .. "】 " .. table.concat(opts, "  ") .. "，请进入【全民答题】地图，站到正确答案怪物旁。本题" .. tostring(duration) .. "秒，结束前" .. tostring(settleBefore) .. "秒结算。"
end
local function _qmdt_make_payload(state, cfg, qidx)
    local q = cfg.questions[qidx]
    if not q then
        return {open = 0}
    end
    local remain = math.max(0, (tonumber(state.question_end_ts) or 0) - os.time())
    return {
        open = 1,
        idx = qidx,
        total = cfg.question_count,
        title = _qmdt_build_prompt(q, qidx, cfg.question_count),
        question_title = q.title,
        options = q.options or {},
        input_mode = 0,
        answer_mode = "map_pos",
        placeholder = "进入地图后站到正确答案怪物旁",
        limit_sec = remain,
        end_ts = tonumber(state.question_end_ts) or 0,
        settle_ts = tonumber(state.settle_ts) or 0,
        map = cfg.map,
    }
end
local function _qmdt_make_panel_payload(state, cfg, qidx)
    local q = cfg and cfg.questions and cfg.questions[qidx]
    if not q then
        return nil
    end
    return {
        mode = "qmdt",
        idx = qidx,
        total = cfg.question_count,
        question = q.title,
        end_ts = tonumber(state.question_end_ts) or 0,
        settle_ts = tonumber(state.settle_ts) or 0,
        map = cfg.map,
    }
end
local function _qmdt_send_panel(play, state, cfg)
    if not play or not cfg then
        return
    end
    state = type(state) == "table" and state or _qmdt_get_state()
    if getsysvar(VarCfg["G_全民答题状态"]) ~= 1 or tonumber(state.open) ~= 1 then
        sendluamsg(play, 101, 498, 2, 0, "")
        return
    end
    local payload = _qmdt_make_panel_payload(state, cfg, tonumber(state.current_idx) or 0)
    if payload then
        sendluamsg(play, 101, 498, 1, 0, tbl2json(payload))
    end
end
local function _qmdt_send_panel_to_map(state, cfg)
    local players = getobjectinmap(cfg.map, 0, 0, 999, 1) or {}
    for _, play in pairs(players) do
        _qmdt_send_panel(play, state, cfg)
    end
end
local function _qmdt_clear_answers(cfg)
    if not cfg or not cfg.map or cfg.map == "" then
        return
    end
    -- 答案怪物会被改名展示，按基础名不一定能清掉；全民答题为独立地图，直接清空本地图怪物最稳。
    pcall(function() killmonsters(cfg.map, "*", 0, false) end)
    pcall(function() killmapmon(cfg.map, 0, 0, 999, "*", false, true) end)
end
local function _qmdt_rename_mon(monObj, name)
    if not monObj then
        return
    end
    if type(monObj) == "table" then
        for _, one in pairs(monObj) do
            pcall(function() changemonname(one, name) end)
        end
    else
        pcall(function() changemonname(monObj, name) end)
    end
end
local function _qmdt_spawn_answers(cfg, q)
    _qmdt_clear_answers(cfg)
    for i, optionText in ipairs(q.options or {}) do
        local point = _qmdt_get_answer_point(cfg, i)
        if point then
            local showName = tostring(optionText)
            release_print("spawning answer monster:", showName, "at", point.x, point.y)
            local monObj = genmonex(cfg.map, point.x, point.y, cfg.answer_mob, 0, 1, 0, 254, showName, 0)
            mapeffect('问题连接1', cfg.map, point.x - 2, point.y + 2, 27, 0, 0)
            mapeffect('问题连接2', cfg.map, point.x - 1, point.y + 2, 27, 0, 0)
            mapeffect('问题连接3', cfg.map, point.x, point.y + 2, 27, 0, 0)
            mapeffect('问题连接4', cfg.map, point.x + 2, point.y + 2, 27, 0, 0)
            mapeffect('问题连接5', cfg.map, point.x + 1, point.y + 2, 27, 0, 0)

            mapeffect('问题连接6', cfg.map, point.x - 2, point.y - 2, 27, 0, 0)
            mapeffect('问题连接7', cfg.map, point.x - 1, point.y - 2, 27, 0, 0)
            mapeffect('问题连接8', cfg.map, point.x, point.y - 2, 27, 0, 0)
            mapeffect('问题连接9', cfg.map, point.x + 2, point.y - 2, 27, 0, 0)
            mapeffect('问题连接10', cfg.map, point.x + 1, point.y - 2, 27, 0, 0)

            mapeffect('问题连接11', cfg.map, point.x - 2, point.y + 1, 27, 0, 0)
            mapeffect('问题连接12', cfg.map, point.x - 2, point.y, 27, 0, 0)
            mapeffect('问题连接13', cfg.map, point.x - 2, point.y - 1, 27, 0, 0)

            mapeffect('问题连接14', cfg.map, point.x + 2, point.y + 1, 27, 0, 0)
            mapeffect('问题连接15', cfg.map, point.x + 2, point.y, 27, 0, 0)
            mapeffect('问题连接16', cfg.map, point.x + 2, point.y - 1, 27, 0, 0)

            -- _qmdt_rename_mon(monObj, showName)
        end
    end
end
local function _qmdt_broadcast_question(cfg, q, qidx, duration)
    local msg = _qmdt_build_notice(q, qidx, cfg.question_count, duration, cfg.settle_before_sec)
    sendtopchatboardmsg("0", 1, 254, 0, 300, msg, 8)
end
local function _qmdt_push_question(state, cfg, qidx, dqfz)
    local q = cfg.questions[qidx]
    if not q then
        return false
    end
    local nowTs = os.time()
    local duration = _qmdt_question_duration(cfg, qidx)
    local endTs = nowTs + duration
    local settleTs = endTs
    if qidx < cfg.question_count then
        settleTs = math.max(nowTs + 1, endTs - math.max(0, tonumber(cfg.settle_before_sec) or 5))
    end
    state.current_idx = qidx
    state.question_start_minute = dqfz or tonumber(state.question_start_minute) or tonumber(state.start_minute) or getsysvar(VarCfg["G_开区分钟"])
    state.question_start_ts = nowTs
    state.question_end_ts = endTs
    state.settle_ts = settleTs
    state.next_question_ts = endTs
    state.settled_idx = 0
    state.phase = "answer"
    state.payload = _qmdt_make_payload(state, cfg, qidx)
    _qmdt_save_state(state)
    _qmdt_spawn_answers(cfg, q)
    _qmdt_broadcast_question(cfg, q, qidx, duration)
    _qmdt_send_panel_to_map(state, cfg)
    return true
end
local function _qmdt_get_player_answer_idx(play, cfg)
    local px = tonumber(getbaseinfo(play, 4) or 0) or 0
    local py = tonumber(getbaseinfo(play, 5) or 0) or 0
    local range = tonumber(cfg.answer_range) or 5
    local bestIdx = nil
    local bestDist = nil
    for i, _ in ipairs(cfg.answer_points or {}) do
        local point = _qmdt_get_answer_point(cfg, i)
        if point then
            local dx = px - point.x
            local dy = py - point.y
            local dist = math.sqrt(dx * dx + dy * dy)
            if not bestDist or dist < bestDist then
                bestDist = dist
                bestIdx = i
            end
        end
    end
    if bestIdx and bestDist and bestDist < range then
        return bestIdx
    end
    return nil
end
local function _qmdt_record_answer(state, cfg, qidx, play, answerIdx)
    local q = cfg.questions[qidx]
    if not q or not answerIdx then
        return false, 0
    end
    local playerName = getbaseinfo(play, 1)
    state.players = state.players or {}
    local rec = state.players[playerName] or {score = 0, right = 0, total = 0, questions = {}}
    rec.questions = rec.questions or {}
    local ansKey = tostring(qidx)
    local qrec = rec.questions[ansKey] or {joined = 0, done = 0}
    if tonumber(qrec.joined) == 1 then
        return false, 0
    end
    qrec.joined = 1
    qrec.answer = answerIdx
    qrec.x = tonumber(getbaseinfo(play, 4) or 0) or 0
    qrec.y = tonumber(getbaseinfo(play, 5) or 0) or 0
    rec.total = (tonumber(rec.total) or 0) + 1
    local gainScore = 0
    if tonumber(q.answer) == tonumber(answerIdx) then
        qrec.done = 1
        gainScore = tonumber(q.score) or tonumber(cfg.base_score) or 100
        rec.right = (tonumber(rec.right) or 0) + 1
        rec.score = (tonumber(rec.score) or 0) + gainScore
    end
    rec.questions[ansKey] = qrec
    state.players[playerName] = rec
    return tonumber(q.answer) == tonumber(answerIdx), gainScore
end
local function _qmdt_settle_question(state, cfg, qidx)
    if tonumber(state.settled_idx) == tonumber(qidx) then
        return state
    end
    local q = cfg.questions[qidx]
    if not q then
        return state
    end
    local rightCount = 0
    local answerCount = 0
    local players = getobjectinmap(cfg.map, 0, 0, 999, 1) or {}
    for _, play in pairs(players) do
        local answerIdx = _qmdt_get_player_answer_idx(play, cfg)
        if answerIdx then
            local ok = false
            local gain = 0
            ok, gain = _qmdt_record_answer(state, cfg, qidx, play, answerIdx)
            answerCount = answerCount + 1
            if ok then
                rightCount = rightCount + 1
                Player.sendmsgEx(play, "回答正确，当前积分+|【" .. tostring(gain) .. "】#218|")
            else
                Player.sendmsgEx(play, "回答错误，本题已结算#57")
            end
        end
    end
    state.settled_idx = qidx
    state.phase = "settled"
    _qmdt_clear_answers(cfg)
    local answerText = tostring((q.options or {})[tonumber(q.answer) or 0] or q.answer or "")
    sendmovemsg("0", 1, 254, 0, 300, 3, "全民答题：第" .. tostring(qidx) .. "题结算，正确答案【" .. answerText .. "】，答对" .. tostring(rightCount) .. "人，参与" .. tostring(answerCount) .. "人。")
    sendtopchatboardmsg("0", 1, 254, 0, 300, "全民答题：第" .. tostring(qidx) .. "题结算，正确答案【" .. answerText .. "】，答对" .. tostring(rightCount) .. "人，参与" .. tostring(answerCount) .. "人。", 5)
    _qmdt_save_state(state)
    return state
end
local function _qmdt_start(dqfz, cfg)
    local state = {
        open = 1,
        mode = "map_pos",
        map = cfg.map,
        start_minute = dqfz,
        current_idx = 0,
        question_start_minute = dqfz,
        question_end_ts = 0,
        settle_ts = 0,
        players = {},
    }
    setsysvar(VarCfg["G_全民答题状态"], 1)
    _qmdt_save_state(state)
    setenvirontimer(cfg.map, 4, 1, "@hd_tcppk," .. cfg.map)
    sendmovemsg("0", 1, 254, 0, 300, 5, "活动：活动《全民答题》已开启，请前往【" .. tostring(cfg.map) .. "】站到正确答案怪物旁参与答题...")
    sendmovemsg("0", 1, 254, 0, 270, 5, "活动：活动《全民答题》已开启，请前往【" .. tostring(cfg.map) .. "】站到正确答案怪物旁参与答题...")
    for _, player in ipairs(getplayerlst() or {}) do
        sendluamsg(player, 101, 12, 1, 3, '{"sk":' .. tostring(tonumber(cfg.duration_min) or 4) .. ',"kf":2,"idx":3}')
    end
    _qmdt_push_question(state, cfg, 1, dqfz)
end
local function _qmdt_finish(cfg)
    if getsysvar(VarCfg["G_全民答题状态"]) ~= 1 then
        return
    end
    local state = _qmdt_get_state()
    local currentIdx = tonumber(state.current_idx) or 0
    if currentIdx > 0 and tonumber(state.settled_idx) ~= currentIdx then
        state = _qmdt_settle_question(state, cfg, currentIdx)
    end
    local rankData = {}
    for name, rec in pairs(state.players or {}) do
        local total = tonumber(rec.total) or 0
        if total > 0 then
            table.insert(rankData, {
                name = name,
                score = tonumber(rec.score) or 0,
                right = tonumber(rec.right) or 0,
                total = total,
            })
        end
    end
    table.sort(rankData, function(a, b)
        if a.score ~= b.score then
            return a.score > b.score
        end
        if a.right ~= b.right then
            return a.right > b.right
        end
        return a.name < b.name
    end)
    local rankRewards = cfg.rank_rewards or {}
    local mailTitle = cfg.mail_title or "全民答题"
    local rankedTop = {}
    for i, one in ipairs(rankData) do
        local rewardCfg = rankRewards[i]
        if rewardCfg and type(rewardCfg.items) == "table" then
            rankedTop[one.name] = 1
            sendmail("#" .. one.name, 0, mailTitle, "恭喜你获得全民答题第[" .. tostring(i) .. "]名,奖励已下发!", Player.jl_mail(rewardCfg.items))
        end
        local playerObj = getplayerbyname(one.name)
        if playerObj then
            local hdjl = Player.getJsonTableByVar(playerObj, VarCfg.T_hdjl)
            hdjl["qmdt"] = hdjl["qmdt"] or {}
            hdjl["qmdt"]["last"] = {rank = i, score = one.score, right = one.right, total = one.total}
            Player.setJsonVarByTable(playerObj, VarCfg.T_hdjl, hdjl)
        end
    end
    if type(cfg.join_reward) == "table" and #cfg.join_reward > 0 then
        for _, one in ipairs(rankData) do
            if not rankedTop[one.name] then
                sendmail("#" .. one.name, 0, mailTitle, "恭喜你参与全民答题,参与奖励已下发!", Player.jl_mail(cfg.join_reward))
            end
        end
    end
    local topName = rankData[1] and rankData[1].name or "无人上榜"
    sendmovemsg("0", 1, 254, 0, 300, 1, "活动：活动《全民答题》已结束,本次第一名为【" .. topName .. "】...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "活动：活动《全民答题》已结束,本次第一名为【" .. topName .. "】...")
    state.open = 0
    state.finished = 1
    state.rank = rankData
    _qmdt_save_state(state)
    setsysvar(VarCfg["G_全民答题状态"], 0)
    setenvirofftimer(cfg.map, 4)
    _qmdt_clear_answers(cfg)
    for _, player in ipairs(getplayerlst() or {}) do
        sendluamsg(player, 101, 12, 4, 3, "")
    end
end
local function _qmdt_tick_runtime(cfg, state)
    if getsysvar(VarCfg["G_全民答题状态"]) ~= 1 then
        return state
    end
    state = type(state) == "table" and state or _qmdt_get_state()
    if tonumber(state.open) ~= 1 then
        return state
    end
    local currentIdx = tonumber(state.current_idx) or 0
    if currentIdx <= 0 then
        _qmdt_push_question(state, cfg, 1, tonumber(getsysvar(VarCfg["G_开区分钟"]) or 0) or 0)
        return _qmdt_get_state()
    end
    local nowTs = os.time()
    local settleTs = tonumber(state.settle_ts) or 0
    if settleTs > 0 and nowTs >= settleTs and tonumber(state.settled_idx) ~= currentIdx then
        state = _qmdt_settle_question(state, cfg, currentIdx)
    end
    local nextTs = tonumber(state.next_question_ts) or tonumber(state.question_end_ts) or 0
    if currentIdx >= cfg.question_count then
        if tonumber(state.settled_idx) == currentIdx then
            _qmdt_finish(cfg)
        end
        return _qmdt_get_state()
    end
    if nextTs > 0 and nowTs >= nextTs and tonumber(state.settled_idx) == currentIdx then
        _qmdt_push_question(state, cfg, currentIdx + 1, tonumber(getsysvar(VarCfg["G_开区分钟"]) or 0) or 0)
        return _qmdt_get_state()
    end
    return state
end
local function _qmdt_tick(dqfz, cfg)
    _qmdt_tick_runtime(cfg, _qmdt_get_state())
end
local function _qmdt_is_timer_map(ditu)
    local cfg = _qmdt_get_cfg()
    local state = _qmdt_get_state()
    local qmdtMap = (state.map and state.map ~= "") and state.map or (cfg and cfg.map)
    return cfg ~= nil and tostring(qmdtMap or "") == tostring(ditu or "")
end
QmdtApi = QmdtApi or {}
QmdtApi.get_cfg = _qmdt_get_cfg
QmdtApi.get_state = _qmdt_get_state
QmdtApi.start = _qmdt_start
QmdtApi.finish = _qmdt_finish
QmdtApi.tick_runtime = _qmdt_tick_runtime
QmdtApi.make_payload = _qmdt_make_payload
QmdtApi.send_panel = _qmdt_send_panel
QmdtApi.is_timer_map = _qmdt_is_timer_map

QmdkApi = QmdkApi or {}
local _QMDK_PREP_NOTICE_VAR = "N$qmdk_prep_notice"
local _QMDK_PANEL_FLAG_VAR = "N$qmdk_panel"
local _QMDK_CARRY_VAR = "N$qmdk_carry"
local _QMDK_COLLECT_CANCEL_VAR = "N$qmdk_collect_cancel"
local _QMDK_SCORE_VAR = "全民夺矿"
local function _qmdk_get_cfg()
    local cfg = teshudata and teshudata["anniu_507"] and teshudata["anniu_507"].qmdk or nil
    if type(cfg) ~= "table" then
        return nil
    end
    if type(cfg.map) ~= "string" or cfg.map == "" then
        return nil
    end
    cfg.start_minute = tonumber(cfg.start_minute) or -1
    cfg.duration_min = tonumber(cfg.duration_min) or 20
    cfg.score_tick_sec = tonumber(cfg.score_tick_sec) or 1
    cfg.score_var_prefix = cfg.score_var_prefix or "全民夺矿"
    cfg.prepare_sec = tonumber(cfg.prepare_sec) or 10
    cfg.collect_sec = tonumber(cfg.collect_sec) or 3
    cfg.collect_range = tonumber(cfg.collect_range) or 3
    cfg.initial_ore_count = tonumber(cfg.initial_ore_count) or 20
    cfg.respawn_sec = tonumber(cfg.respawn_sec) or 10
    cfg.spawn_try_count = tonumber(cfg.spawn_try_count) or 30
    cfg.spawn_radius = tonumber(cfg.spawn_radius) or 20
    cfg.deliver_score = tonumber(cfg.deliver_score) or 50
    cfg.deliver_range = tonumber(cfg.deliver_range) or 3
    cfg.deliver_pos = cfg.deliver_pos or {21, 20}
    cfg.ore_mob = cfg.ore_mob or "大矿石"
    cfg.carry_buff = tonumber(cfg.carry_buff) or 20115
    cfg.mail_title = cfg.mail_title or "全民夺矿"
    cfg.min_open_day = tonumber(cfg.min_open_day) or 2
    cfg.start_hour = tonumber(cfg.start_hour) or 19
    cfg.start_minute_clock = tonumber(cfg.start_minute_clock) or 0
    return cfg
end
local function _qmdk_get_state()
    local raw = getsysvar(VarCfg["A_全民夺矿json"])
    if raw == "" then
        return {}
    end
    local tb = json2tbl(raw)
    return type(tb) == "table" and tb or {}
end
local function _qmdk_save_state(state)
    setsysvar(VarCfg["A_全民夺矿json"], tbl2json(state or {}))
end
local function _qmdk_get_score_var(cfg, state)
    return _QMDK_SCORE_VAR
end
local function _qmdk_reset_online_scores()
    for _, player in ipairs(getplayerlst() or {}) do
        setplayvar(player, "HUMAN", _QMDK_SCORE_VAR, 0, 1)
    end
end
local function _safe_getplayvar_num(play, objType, key)
    local raw = getplayvar(play, objType, key)
    return tonumber(raw or 0) or 0
end
local function _qmdk_is_active_map(play, cfg, state)
    if not play or not cfg then
        return false
    end
    local mapName = (state and state.map and state.map ~= "") and state.map or cfg.map
    return getbaseinfo(play, 3) == mapName
end
local function _qmdk_rank_payload(play, cfg, state)
    local scoreVar = _qmdk_get_score_var(cfg, state)
    return '{"pmsj":' .. tbl2json(sorthumvar(scoreVar, 1, 1, 5)) .. ',"grjf":' .. _safe_getplayvar_num(play, "HUMAN", scoreVar) .. '}'
end
local function _qmdk_send_rank(play, cfg, state)
    if not play or not cfg then
        return
    end
    sendluamsg(play, 101, 498, 0, 0, _qmdk_rank_payload(play, cfg, state))
    setplaydef(play, _QMDK_PANEL_FLAG_VAR, 1)
end
local function _qmdk_close_rank(play)
    if getplaydef(play, _QMDK_PANEL_FLAG_VAR) == 1 then
        sendluamsg(play, 101, 498, 2, 0, "")
        setplaydef(play, _QMDK_PANEL_FLAG_VAR, 0)
    end
end
local function _qmdk_send_rank_to_map(cfg, state)
    local mapName = (state and state.map and state.map ~= "") and state.map or (cfg and cfg.map)
    if not mapName or mapName == "" then
        return
    end
    local players = getobjectinmap(mapName, 0, 0, 999, 1)
    for _, v in pairs(players or {}) do
        sendluamsg(v, 101, 498, 1, 0, _qmdk_rank_payload(v, cfg, state))
    end
end
local function _qmdk_map_name(cfg, state)
    return (state and state.map and state.map ~= "") and state.map or (cfg and cfg.map) or ""
end
local function _qmdk_clear_map_ores(cfg, state)
    local mapName = _qmdk_map_name(cfg, state)
    if mapName == "" or not cfg or not cfg.ore_mob or cfg.ore_mob == "" then
        return
    end
    killmonsters(mapName, cfg.ore_mob, 0, false)
end
local function _qmdk_spawn_one_ore(cfg, state)
    local mapName = _qmdk_map_name(cfg, state)
    if mapName == "" or not cfg or not cfg.ore_mob or cfg.ore_mob == "" then
        return false
    end
    local mapW = tonumber(getmapinfo(mapName, 0) or 0) or 0
    local mapH = tonumber(getmapinfo(mapName, 1) or 0) or 0
    if mapW <= 0 or mapH <= 0 then
        return false
    end
    local cx = tonumber((cfg.deliver_pos and cfg.deliver_pos[1]) or 21) or 21
    local cy = tonumber((cfg.deliver_pos and cfg.deliver_pos[2]) or 20) or 20
    local radius = math.max(1, tonumber(cfg.spawn_radius) or 20)
    local tryCount = math.max(1, tonumber(cfg.spawn_try_count) or 30)
    for _ = 1, tryCount do
        local dx = math.random(-radius, radius)
        local dy = math.random(-radius, radius)
        if dx * dx + dy * dy <= radius * radius then
            local rx = math.max(1, math.min(mapW, cx + dx))
            local ry = math.max(1, math.min(mapH, cy + dy))
            if isemptyinmap(mapName, rx, ry) then
                local mob = genmonex(mapName, rx, ry, cfg.ore_mob, 1, 1, 0, 54, "", 0)
                if mob then
                    return true
                end
            end
        end
    end
    return false
end
local function _qmdk_spawn_ores(cfg, state, count)
    local need = math.max(0, tonumber(count) or 0)
    local spawned = 0
    for _ = 1, need do
        if _qmdk_spawn_one_ore(cfg, state) then
            spawned = spawned + 1
        end
    end
    return spawned
end
local function _qmdk_tick_runtime(cfg, state)
    if not cfg or type(state) ~= "table" or getsysvar(VarCfg["G_全民夺矿状态"]) ~= 1 or tonumber(state.open) ~= 1 then
        return state
    end
    local nowTs = os.time()
    local changed = false
    if tonumber(state.init_ore_spawned) ~= 1 then
        _qmdk_clear_map_ores(cfg, state)
        _qmdk_spawn_ores(cfg, state, cfg.initial_ore_count)
        state.init_ore_spawned = 1
        state.last_spawn_ts = nowTs
        changed = true
    else
        local respawnSec = math.max(1, tonumber(cfg.respawn_sec) or 10)
        local lastSpawnTs = tonumber(state.last_spawn_ts) or nowTs
        if nowTs - lastSpawnTs >= respawnSec then
            local need = math.max(1, math.floor((nowTs - lastSpawnTs) / respawnSec))
            _qmdk_spawn_ores(cfg, state, need)
            state.last_spawn_ts = nowTs
            changed = true
        end
    end
    if changed then
        _qmdk_save_state(state)
    end
    return state
end
local function _qmdk_is_collecting_ore(play, cfg)
    if not play or not cfg then
        return false
    end
    return tonumber(getplaydef(play, "N$iscaiji") or 0) == 1 and getplaydef(play, "S$采集目标名字") == cfg.ore_mob
end
local function _qmdk_clear_collect(play, reason)
    local cfg = _qmdk_get_cfg()
    local isCollectingOre = _qmdk_is_collecting_ore(play, cfg)
    setplaydef(play, _QMDK_COLLECT_CANCEL_VAR, 0)
    if cfg and (isCollectingOre or getplaydef(play, "S$采集目标名字") == cfg.ore_mob) then
        setplaydef(play, "N$iscaiji", 0)
        setplaydef(play, "S$采集目标", "")
        setplaydef(play, "S$采集目标名字", "")
        if isCollectingOre and reason and reason ~= "" then
            Player.sendmsgEx(play, reason .. "#57")
        end
    end
end
local function _qmdk_drop_ore(play, cfg)
    if not cfg or not cfg.ore_mob or cfg.ore_mob == "" then
        return
    end
    local mapName = getbaseinfo(play, 3)
    local x = getbaseinfo(play, 4)
    local y = getbaseinfo(play, 5)
    if mapName and mapName ~= "" and x > 0 and y > 0 then
        genmonex(mapName, x, y, cfg.ore_mob, 1, 1, 0, 54, "", 0)
    end
end
local function _qmdk_clear_carry(play, cfg, dropOre, reason)
    if tonumber(getplaydef(play, _QMDK_CARRY_VAR) or 0) ~= 1 then
        return
    end
    if cfg and tonumber(cfg.carry_buff or 0) > 0 and hasbuff(play, cfg.carry_buff) then
        delbuff(play, cfg.carry_buff)
    end
    setplaydef(play, _QMDK_CARRY_VAR, 0)
    if dropOre then
        _qmdk_drop_ore(play, cfg)
    end
    if reason and reason ~= "" then
        Player.sendmsgEx(play, reason .. "#57")
    end
end
local function _qmdk_clear_actor_state(play, cfg, dropOre)
    _qmdk_clear_collect(play)
    _qmdk_clear_carry(play, cfg, dropOre)
    setplaydef(play, _QMDK_PREP_NOTICE_VAR, 0)
end
local function _qmdk_try_deliver(play, cfg, state)
    if tonumber(getplaydef(play, _QMDK_CARRY_VAR) or 0) ~= 1 then
        return false
    end
    local dx = tonumber(cfg.deliver_pos[1] or 21) or 21
    local dy = tonumber(cfg.deliver_pos[2] or 20) or 20
    local px = getbaseinfo(play, 4)
    local py = getbaseinfo(play, 5)
    if math.abs(px - dx) > cfg.deliver_range or math.abs(py - dy) > cfg.deliver_range then
        return false
    end
    local scoreVar = _qmdk_get_score_var(cfg, state)
    local jf = _safe_getplayvar_num(play, "HUMAN", scoreVar) + cfg.deliver_score
    setplayvar(play, "HUMAN", scoreVar, jf, 1)
    _qmdk_clear_carry(play, cfg, false)
    Player.sendmsgEx(play, "成功运回一块矿石，积分+" .. cfg.deliver_score .. "#218")
    _qmdk_send_rank_to_map(cfg, state)
    return true
end
local function _qmdk_tick_player(play, cfg, state)
    if not _qmdk_is_active_map(play, cfg, state) then
        _qmdk_clear_actor_state(play, cfg, false)
        _qmdk_close_rank(play)
        return
    end
    _qmdk_send_rank(play, cfg, state)
    local nowTs = os.time()
    local prepLeft = math.max(0, (tonumber(state.prepare_end_ts) or 0) - nowTs)
    if prepLeft > 0 then
        local lastNotice = tonumber(getplaydef(play, _QMDK_PREP_NOTICE_VAR) or 0) or 0
        if lastNotice ~= prepLeft then
            setplaydef(play, _QMDK_PREP_NOTICE_VAR, prepLeft)
            if prepLeft == tonumber(cfg.prepare_sec) or prepLeft <= 5 then
                Player.sendmsgEx(play, "全民夺矿准备阶段，" .. prepLeft .. "秒后开始采矿#57")
            end
        end
        _qmdk_clear_collect(play)
        return
    end
    setplaydef(play, _QMDK_PREP_NOTICE_VAR, 0)
    _qmdk_try_deliver(play, cfg, state)
end
local function _qmdk_refresh_actor(play)
    local cfg = _qmdk_get_cfg()
    if not cfg then
        return
    end
    local state = _qmdk_get_state()
    if getsysvar(VarCfg["G_全民夺矿状态"]) == 1 and tonumber(state.open) == 1 and _qmdk_is_active_map(play, cfg, state) then
        if tonumber(getplaydef(play, _QMDK_CARRY_VAR) or 0) == 1 and tonumber(cfg.carry_buff or 0) > 0 and not hasbuff(play, cfg.carry_buff) then
            addbuff(play, cfg.carry_buff)
        end
        _qmdk_send_rank(play, cfg, state)
    else
        _qmdk_clear_actor_state(play, cfg, false)
        _qmdk_close_rank(play)
    end
end
local function _qmdk_interrupt_collect(play, reason)
    local cfg = _qmdk_get_cfg()
    if _qmdk_is_collecting_ore(play, cfg) then
        setplaydef(play, _QMDK_COLLECT_CANCEL_VAR, 1)
        setplaydef(play, "N$iscaiji", 0)
        setplaydef(play, "S$采集目标", "")
        setplaydef(play, "S$采集目标名字", "")
        Player.sendmsgEx(play, (reason or "采集中断") .. "#57")
    end
end
local function _qmdk_on_die(play)
    local cfg = _qmdk_get_cfg()
    if not cfg then
        return
    end
    local state = _qmdk_get_state()
    if _qmdk_is_active_map(play, cfg, state) then
        _qmdk_clear_collect(play, "你已死亡，采集中断")
        _qmdk_clear_carry(play, cfg, true, "你已死亡，矿石掉落")
        _qmdk_send_rank_to_map(cfg, state)
    else
        _qmdk_clear_actor_state(play, cfg, false)
    end
end
local function _qmdk_clear_all_online(cfg, dropOre)
    for _, player in ipairs(getplayerlst() or {}) do
        _qmdk_clear_actor_state(player, cfg, dropOre)
    end
end
QmdkApi.get_cfg = _qmdk_get_cfg
QmdkApi.get_state = _qmdk_get_state
QmdkApi.save_state = _qmdk_save_state
QmdkApi.get_score_var = _qmdk_get_score_var
QmdkApi.reset_online_scores = _qmdk_reset_online_scores
QmdkApi.send_rank = _qmdk_send_rank
QmdkApi.send_rank_to_map = _qmdk_send_rank_to_map
QmdkApi.refresh_actor = _qmdk_refresh_actor
QmdkApi.interrupt_collect = _qmdk_interrupt_collect
QmdkApi.on_actor_hurt = _qmdk_interrupt_collect
QmdkApi.on_actor_move = function(play) _qmdk_interrupt_collect(play, "你移动了，采集中断") end
QmdkApi.on_actor_die = _qmdk_on_die
QmdkApi.clear_actor_state = _qmdk_clear_actor_state
QmdkApi.clear_all_online = _qmdk_clear_all_online
QmdkApi.tick_runtime = _qmdk_tick_runtime
QmdkApi.before_collect = function(play, monName)
    local cfg = _qmdk_get_cfg()
    if not cfg or monName ~= cfg.ore_mob then
        return "pass"
    end
    local state = _qmdk_get_state()
    if getsysvar(VarCfg["G_全民夺矿状态"]) ~= 1 or tonumber(state.open) ~= 1 or not _qmdk_is_active_map(play, cfg, state) then
        Player.sendmsgEx(play, "全民夺矿当前未开启#57")
        return "blocked"
    end
    if (tonumber(state.prepare_end_ts) or 0) > os.time() then
        Player.sendmsgEx(play, "准备阶段中，暂时不能采集矿石#57")
        return "blocked"
    end
    if tonumber(getplaydef(play, _QMDK_CARRY_VAR) or 0) == 1 then
        Player.sendmsgEx(play, "每次只能携带一块矿石#57")
        return "blocked"
    end
    setplaydef(play, _QMDK_COLLECT_CANCEL_VAR, 0)
    return "start", cfg.collect_sec or 3
end
QmdkApi.on_collect_success = function(play, monName, monMakeIndex)
    local cfg = _qmdk_get_cfg()
    if not cfg or monName ~= cfg.ore_mob then
        return false
    end
    local state = _qmdk_get_state()
    local cancelled = tonumber(getplaydef(play, _QMDK_COLLECT_CANCEL_VAR) or 0) == 1
    setplaydef(play, _QMDK_COLLECT_CANCEL_VAR, 0)
    if cancelled then
        return true
    end
    if getsysvar(VarCfg["G_全民夺矿状态"]) ~= 1 or tonumber(state.open) ~= 1 or not _qmdk_is_active_map(play, cfg, state) then
        Player.sendmsgEx(play, "全民夺矿当前未开启#57")
        return true
    end
    if (tonumber(state.prepare_end_ts) or 0) > os.time() then
        Player.sendmsgEx(play, "准备阶段中，暂时不能采集矿石#57")
        return true
    end
    if tonumber(getplaydef(play, _QMDK_CARRY_VAR) or 0) == 1 then
        Player.sendmsgEx(play, "每次只能携带一块矿石#57")
        return true
    end
    local mapid = getbaseinfo(play, ConstCfg.gbase.mapid)
    local monobj = (monMakeIndex ~= nil and monMakeIndex ~= "") and getmonbyuserid(mapid, monMakeIndex) or nil
    if not monobj then
        Player.sendmsgEx(play, "矿石已被他人采走#57")
        return true
    end
    killmonbyobj(play, monobj, false, false, false)
    setplaydef(play, _QMDK_CARRY_VAR, 1)
    if tonumber(cfg.carry_buff or 0) > 0 and not hasbuff(play, cfg.carry_buff) then
        addbuff(play, cfg.carry_buff)
    end
    Player.sendmsgEx(play, "采集成功，运回矿石可获得" .. cfg.deliver_score .. "积分#218")
    _qmdk_send_rank(play, cfg, state)
    return true
end
QmdkApi.on_collect_fail = function(play, monName)
    local cfg = _qmdk_get_cfg()
    if not cfg or monName ~= cfg.ore_mob then
        return false
    end
    setplaydef(play, _QMDK_COLLECT_CANCEL_VAR, 0)
    return true
end
local function _qmdk_start(dqfz, cfg, fromBot)
    if getsysvar(VarCfg["G_全民夺矿状态"]) == 1 then
        return false
    end
    _qmdk_reset_online_scores()
    local state = {
        open = 1,
        start_minute = dqfz,
        map = cfg.map,
        score_var = _QMDK_SCORE_VAR,
        from_bot = fromBot and 1 or 0,
        prepare_end_ts = os.time() + cfg.prepare_sec,
    }
    setsysvar(VarCfg["G_全民夺矿状态"], 1)
    _qmdk_save_state(state)
    state = _qmdk_tick_runtime(cfg, state) or state
    setenvirontimer(cfg.map, 3, cfg.score_tick_sec, "@hd_tcppk," .. cfg.map)
    sendmovemsg("0", 1, 254, 0, 300, 1, "活动：活动《全民夺矿》已开启，10秒后开始采矿搬运...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "活动：活动《全民夺矿》已开启，10秒后开始采矿搬运...")
    for _, player in ipairs(getplayerlst() or {}) do
        sendluamsg(player, 101, 12, 1, 2, '{"sk":' .. cfg.duration_min .. ',"kf":2,"idx":2}')
        _qmdk_refresh_actor(player)
    end
    return true
end
local function _qmdk_finish(cfg, fromBot)
    if getsysvar(VarCfg["G_全民夺矿状态"]) ~= 1 then
        return false
    end
    local state = _qmdk_get_state()
    local mapName = (state.map and state.map ~= "") and state.map or cfg.map
    setenvirofftimer(mapName, 3)
    _qmdk_clear_map_ores(cfg, state)
    _qmdk_clear_all_online(cfg, false)
    local scoreVar = _qmdk_get_score_var(cfg, state)
    local rankRaw = sorthumvar(scoreVar, 1, 1, 10)
    local rankData = {}
    for i = 1, #rankRaw, 2 do
        local name = rankRaw[i]
        local score = tonumber(rankRaw[i + 1]) or 0
        if name and score > 0 then
            table.insert(rankData, {name = name, score = score})
        end
    end
    local mailTitle = cfg.mail_title or "全民夺矿"
    local topNames = {}
    for i, one in ipairs(rankData) do
        local reward = cfg.rank_rewards and cfg.rank_rewards[i]
        if reward and type(reward.items) == "table" and #reward.items > 0 then
            sendmail("#" .. one.name, 0, mailTitle, "恭喜你获得全民夺矿第[" .. tostring(i) .. "]名,奖励已下发!", Player.jl_mail(reward.items))
            topNames[one.name] = 1
        end
        local playerObj = getplayerbyname(one.name)
        if playerObj then
            local hdjl = Player.getJsonTableByVar(playerObj, VarCfg.T_hdjl)
            hdjl["qmdk"] = hdjl["qmdk"] or {}
            hdjl["qmdk"]["last"] = {rank = i, score = one.score}
            Player.setJsonVarByTable(playerObj, VarCfg.T_hdjl, hdjl)
        end
    end
    if type(cfg.join_reward) == "table" and #cfg.join_reward > 0 then
        for _, player in ipairs(getplayerlst() or {}) do
            local score = _safe_getplayvar_num(player, "HUMAN", scoreVar)
            local name = getbaseinfo(player, 1)
            if score > 0 and not topNames[name] then
                sendmail(getbaseinfo(player, 2), 0, mailTitle, "恭喜你参与全民夺矿,参与奖励已下发!", Player.jl_mail(cfg.join_reward))
            end
        end
    end
    local topName = rankData[1] and rankData[1].name or "无人上榜"
    sendmovemsg("0", 1, 254, 0, 300, 1, "活动：活动《全民夺矿》已结束,本次第一名为【" .. topName .. "】...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "活动：活动《全民夺矿》已结束,本次第一名为【" .. topName .. "】...")
    state.open = 0
    state.finished = 1
    state.from_bot = fromBot and 1 or 0
    state.rank = rankData
    _qmdk_save_state(state)
    setsysvar(VarCfg["G_全民夺矿状态"], 0)
    _qmdk_send_rank_to_map(cfg, state)
    return true
end
local function _qmdk_tick(dqfz, cfg)
    local state = _qmdk_get_state()
    if tonumber(state.force_end) == 1 then
        state.force_end = nil
        _qmdk_save_state(state)
        _qmdk_finish(cfg, true)
        return
    end
    if getsysvar(VarCfg["G_全民夺矿状态"]) == 1 then
        local startMinute = tonumber(state.start_minute) or dqfz
        if dqfz - startMinute >= cfg.duration_min then
            _qmdk_finish(cfg, false)
        end
        return
    end
    if tonumber(state.force_start) == 1 then
        state.force_start = nil
        _qmdk_save_state(state)
        _qmdk_start(dqfz, cfg, true)
        return
    end
    if dqfz == cfg.start_minute then
        _qmdk_start(dqfz, cfg, false)
        return
    end
    if dqfz >= ((cfg.min_open_day - 1) * 24 * 60) then
        local hour = tonumber(os.date("%H")) or 0
        local minute = tonumber(os.date("%M")) or 0
        if hour == cfg.start_hour and minute == cfg.start_minute_clock then
            _qmdk_start(dqfz, cfg, false)
        end
    end
end
-- 黑暗禁地：复用采集类活动框架，负责刷宝箱、采集发奖与压低视野。
HdjdApi = HdjdApi or {}
local _HDJD_EVENT_NAME = "黑暗禁地"
local _HDJD_COLLECT_CANCEL_VAR = "N$hdjd_collect_cancel"
local function _hdjd_get_cfg()
    local cfg = teshudata and teshudata["anniu_507"] and teshudata["anniu_507"].hdjd or nil
    if type(cfg) ~= "table" then
        return nil
    end
    if type(cfg.map) ~= "string" or cfg.map == "" then
        return nil
    end
    cfg.map = tostring(cfg.map)
    cfg.chest_mob = tostring(cfg.chest_mob or "")
    if cfg.chest_mob == "" then
        return nil
    end
    cfg.collect_sec = tonumber(cfg.collect_sec) or 3
    cfg.duration_min = tonumber(cfg.duration_min) or 20
    cfg.score_tick_sec = tonumber(cfg.score_tick_sec) or 1
    cfg.initial_chest_count = tonumber(cfg.initial_chest_count) or 18
    cfg.respawn_sec = tonumber(cfg.respawn_sec) or 8
    cfg.spawn_try_count = tonumber(cfg.spawn_try_count) or 40
    cfg.spawn_radius = tonumber(cfg.spawn_radius) or 32
    cfg.center_pos = cfg.center_pos or {36, 36}
    cfg.mail_title = tostring(cfg.mail_title or _HDJD_EVENT_NAME)
    cfg.min_open_day = tonumber(cfg.min_open_day) or 2
    cfg.start_hour = tonumber(cfg.start_hour) or 19
    cfg.start_minute_clock = tonumber(cfg.start_minute_clock) or 30
    cfg.vision = tonumber(cfg.vision) or 1
    cfg.rewards = type(cfg.rewards) == "table" and cfg.rewards or {}
    return cfg
end
local function _hdjd_get_state()
    local raw = getsysvar(VarCfg["A_黑暗禁地json"])
    if raw == "" then
        return {}
    end
    local tb = json2tbl(raw)
    return type(tb) == "table" and tb or {}
end
local function _hdjd_save_state(state)
    setsysvar(VarCfg["A_黑暗禁地json"], tbl2json(state or {}))
end
local function _hdjd_map_name(cfg, state)
    return (state and state.map and state.map ~= "") and state.map or (cfg and cfg.map) or ""
end
local function _hdjd_is_active_map(play, cfg, state)
    if not play or not cfg then
        return false
    end
    return getbaseinfo(play, 3) == _hdjd_map_name(cfg, state)
end
local function _hdjd_clear_map_chests(cfg, state)
    local mapName = _hdjd_map_name(cfg, state)
    if mapName == "" or not cfg or cfg.chest_mob == "" then
        return
    end
    killmonsters(mapName, cfg.chest_mob, 0, false)
end
local function _hdjd_spawn_one_chest(cfg, state)
    local mapName = _hdjd_map_name(cfg, state)
    if mapName == "" or not cfg or cfg.chest_mob == "" then
        return false
    end
    local mapW = tonumber(getmapinfo(mapName, 0) or 0) or 0
    local mapH = tonumber(getmapinfo(mapName, 1) or 0) or 0
    if mapW <= 0 or mapH <= 0 then
        return false
    end
    local cx = tonumber((cfg.center_pos and cfg.center_pos[1]) or math.floor(mapW / 2)) or math.floor(mapW / 2)
    local cy = tonumber((cfg.center_pos and cfg.center_pos[2]) or math.floor(mapH / 2)) or math.floor(mapH / 2)
    local radius = math.max(1, tonumber(cfg.spawn_radius) or 32)
    local tryCount = math.max(1, tonumber(cfg.spawn_try_count) or 40)
    for _ = 1, tryCount do
        local dx = math.random(-radius, radius)
        local dy = math.random(-radius, radius)
        if dx * dx + dy * dy <= radius * radius then
            local rx = math.max(1, math.min(mapW, cx + dx))
            local ry = math.max(1, math.min(mapH, cy + dy))
            if isemptyinmap(mapName, rx, ry) then
                local mob = genmonex(mapName, rx, ry, cfg.chest_mob, 1, 1, 0, 54, "", 0)
                if mob then
                    return true
                end
            end
        end
    end
    return false
end
local function _hdjd_spawn_chests(cfg, state, count)
    local need = math.max(0, tonumber(count) or 0)
    local spawned = 0
    for _ = 1, need do
        if _hdjd_spawn_one_chest(cfg, state) then
            spawned = spawned + 1
        end
    end
    return spawned
end
local function _hdjd_tick_runtime(cfg, state)
    if not cfg or type(state) ~= "table" or getsysvar(VarCfg["G_黑暗禁地状态"]) ~= 1 or tonumber(state.open) ~= 1 then
        return state
    end
    local nowTs = os.time()
    local changed = false
    if tonumber(state.init_chest_spawned) ~= 1 then
        _hdjd_clear_map_chests(cfg, state)
        _hdjd_spawn_chests(cfg, state, cfg.initial_chest_count)
        state.init_chest_spawned = 1
        state.last_spawn_ts = nowTs
        changed = true
    else
        local respawnSec = math.max(1, tonumber(cfg.respawn_sec) or 8)
        local lastSpawnTs = tonumber(state.last_spawn_ts) or nowTs
        if nowTs - lastSpawnTs >= respawnSec then
            local need = math.max(1, math.floor((nowTs - lastSpawnTs) / respawnSec))
            _hdjd_spawn_chests(cfg, state, need)
            state.last_spawn_ts = nowTs
            changed = true
        end
    end
    if changed then
        _hdjd_save_state(state)
    end
    return state
end
local function _hdjd_restore_vision(play)
    if Login and Login.refreshGrayWorldVision then
        Login.refreshGrayWorldVision(play)
    else
        setcandlevalue(play, 20)
    end
end
local function _hdjd_is_collecting_chest(play, cfg)
    if not play or not cfg then
        return false
    end
    return tonumber(getplaydef(play, "N$iscaiji") or 0) == 1 and getplaydef(play, "S$采集目标名字") == cfg.chest_mob
end
local function _hdjd_interrupt_collect(play, reason)
    local cfg = _hdjd_get_cfg()
    local isCollectingChest = _hdjd_is_collecting_chest(play, cfg)
    setplaydef(play, _HDJD_COLLECT_CANCEL_VAR, 0)
    if cfg and (isCollectingChest or getplaydef(play, "S$采集目标名字") == cfg.chest_mob) then
        setplaydef(play, _HDJD_COLLECT_CANCEL_VAR, 1)
        setplaydef(play, "N$iscaiji", 0)
        setplaydef(play, "S$采集目标", "")
        setplaydef(play, "S$采集目标名字", "")
        if isCollectingChest and reason and reason ~= "" then
            Player.sendmsgEx(play, reason .. "#57")
        end
    end
end
local function _hdjd_refresh_actor(play)
    local cfg = _hdjd_get_cfg()
    if not cfg then
        return
    end
    local state = _hdjd_get_state()
    if getsysvar(VarCfg["G_黑暗禁地状态"]) == 1 and tonumber(state.open) == 1 and _hdjd_is_active_map(play, cfg, state) then
        setcandlevalue(play, math.max(1, tonumber(cfg.vision) or 1))
    else
        _hdjd_interrupt_collect(play)
        _hdjd_restore_vision(play)
    end
end
local function _hdjd_on_die(play)
    local cfg = _hdjd_get_cfg()
    if not cfg then
        return
    end
    local state = _hdjd_get_state()
    if _hdjd_is_active_map(play, cfg, state) then
        _hdjd_interrupt_collect(play, "你已死亡，采集中断")
        setcandlevalue(play, math.max(1, tonumber(cfg.vision) or 1))
    else
        _hdjd_refresh_actor(play)
    end
end
local function _hdjd_build_reward_desc(rewardList)
    local desc = {}
    for _, one in ipairs(rewardList or {}) do
        local name = tostring(one[1] or "")
        local count = tonumber(one[2] or 0) or 0
        if name ~= "" and count > 0 then
            desc[#desc + 1] = name .. "*" .. tostring(count)
        end
    end
    return table.concat(desc, "、")
end
local function _hdjd_pick_reward_entry(cfg)
    local rewards = type(cfg.rewards) == "table" and cfg.rewards or {}
    if #rewards <= 0 then
        return nil
    end
    local base = tonumber((rewards[1] and rewards[1].base) or 10000) or 10000
    local roll = math.random(base)
    local acc = 0
    local picked = rewards[#rewards]
    for _, entry in ipairs(rewards) do
        acc = acc + (tonumber(entry.rate) or 0)
        if roll <= acc then
            picked = entry
            break
        end
    end
    return picked
end
local function _hdjd_parse_reward_list(rawList)
    local rewardList = {}
    for _, one in ipairs(rawList or {}) do
        local itemName = tostring(one[1] or "")
        local countRaw = one[2]
        local count = tonumber(countRaw)
        if type(countRaw) == "table" then
            local minCount = tonumber(countRaw[1] or 0) or 0
            local maxCount = tonumber(countRaw[2] or minCount) or minCount
            if maxCount < minCount then
                minCount, maxCount = maxCount, minCount
            end
            count = math.random(minCount, maxCount)
        end
        if itemName ~= "" and (tonumber(count) or 0) > 0 then
            rewardList[#rewardList + 1] = {itemName, tonumber(count) or 0}
        end
    end
    return rewardList
end
local function _hdjd_roll_reward(cfg)
    local entry = _hdjd_pick_reward_entry(cfg)
    if not entry then
        return nil, ""
    end
    local rewardList = {}
    if type(entry.give) == "table" and #entry.give > 0 then
        rewardList = _hdjd_parse_reward_list(entry.give)
    elseif type(entry.random_one) == "table" and #entry.random_one > 0 then
        local picked = entry.random_one[math.random(#entry.random_one)]
        rewardList = _hdjd_parse_reward_list(picked)
    end
    return rewardList, _hdjd_build_reward_desc(rewardList)
end
local function _hdjd_clear_all_online()
    for _, player in ipairs(getplayerlst() or {}) do
        _hdjd_refresh_actor(player)
    end
end
HdjdApi.get_cfg = _hdjd_get_cfg
HdjdApi.get_state = _hdjd_get_state
HdjdApi.save_state = _hdjd_save_state
HdjdApi.refresh_actor = _hdjd_refresh_actor
HdjdApi.clear_map_chests = _hdjd_clear_map_chests
HdjdApi.clear_all_online = _hdjd_clear_all_online
HdjdApi.tick_runtime = _hdjd_tick_runtime
HdjdApi.on_actor_hurt = _hdjd_interrupt_collect
HdjdApi.on_actor_move = function(play)
    _hdjd_interrupt_collect(play, "你移动了，采集中断")
end
HdjdApi.on_actor_die = _hdjd_on_die
HdjdApi.before_collect = function(play, monName)
    local cfg = _hdjd_get_cfg()
    if not cfg or monName ~= cfg.chest_mob then
        return "pass"
    end
    local state = _hdjd_get_state()
    if getsysvar(VarCfg["G_黑暗禁地状态"]) ~= 1 or tonumber(state.open) ~= 1 or not _hdjd_is_active_map(play, cfg, state) then
        Player.sendmsgEx(play, "黑暗禁地当前未开启#57")
        return "blocked"
    end
    setplaydef(play, _HDJD_COLLECT_CANCEL_VAR, 0)
    return "start", cfg.collect_sec or 3
end
HdjdApi.on_collect_success = function(play, monName, monMakeIndex)
    local cfg = _hdjd_get_cfg()
    if not cfg or monName ~= cfg.chest_mob then
        return false
    end
    local state = _hdjd_get_state()
    local cancelled = tonumber(getplaydef(play, _HDJD_COLLECT_CANCEL_VAR) or 0) == 1
    setplaydef(play, _HDJD_COLLECT_CANCEL_VAR, 0)
    if cancelled then
        return true
    end
    if getsysvar(VarCfg["G_黑暗禁地状态"]) ~= 1 or tonumber(state.open) ~= 1 or not _hdjd_is_active_map(play, cfg, state) then
        Player.sendmsgEx(play, "黑暗禁地当前未开启#57")
        _hdjd_refresh_actor(play)
        return true
    end
    local mapid = getbaseinfo(play, ConstCfg.gbase.mapid)
    local monobj = (monMakeIndex ~= nil and monMakeIndex ~= "") and getmonbyuserid(mapid, monMakeIndex) or nil
    if not monobj then
        Player.sendmsgEx(play, "黑暗宝箱已被他人采走#57")
        return true
    end
    killmonbyobj(play, monobj, false, false, false)
    local rewardList, rewardDesc = _hdjd_roll_reward(cfg)
    if type(rewardList) == "table" and #rewardList > 0 then
        Player.rwjl(play, rewardList, _HDJD_EVENT_NAME, 1, 0)
        Player.sendmsgEx(play, "采集黑暗宝箱成功，获得#218|" .. rewardDesc .. "#57")
    else
        Player.sendmsgEx(play, "采集黑暗宝箱成功，但奖励配置为空#57")
    end
    return true
end
HdjdApi.on_collect_fail = function(play, monName)
    local cfg = _hdjd_get_cfg()
    if not cfg or monName ~= cfg.chest_mob then
        return false
    end
    setplaydef(play, _HDJD_COLLECT_CANCEL_VAR, 0)
    return true
end
local function _hdjd_start(dqfz, cfg, fromBot)
    if getsysvar(VarCfg["G_黑暗禁地状态"]) == 1 then
        return false
    end
    local state = {
        open = 1,
        start_minute = dqfz,
        map = cfg.map,
        from_bot = fromBot and 1 or 0,
    }
    setsysvar(VarCfg["G_黑暗禁地状态"], 1)
    _hdjd_save_state(state)
    state = _hdjd_tick_runtime(cfg, state) or state
    setenvirontimer(cfg.map, 3, cfg.score_tick_sec, "@hd_tcppk," .. cfg.map)
    sendmovemsg("0", 1, 254, 0, 300, 1, "活动：活动《黑暗禁地》已开启，黑暗宝箱开始刷新...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "活动：活动《黑暗禁地》已开启，请尽快前往采集宝箱...")
    local keepMin = math.max(1, tonumber(cfg.duration_min) or 20)
    for _, player in ipairs(getplayerlst() or {}) do
        sendluamsg(player, 101, 12, 1, 14, '{"sk":' .. keepMin .. ',"kf":2,"idx":14}')
        _hdjd_refresh_actor(player)
    end
    return true
end
local function _hdjd_finish(cfg, fromBot)
    if getsysvar(VarCfg["G_黑暗禁地状态"]) ~= 1 then
        return false
    end
    local state = _hdjd_get_state()
    local mapName = _hdjd_map_name(cfg, state)
    setenvirofftimer(mapName, 3)
    _hdjd_clear_map_chests(cfg, state)
    state.open = 0
    state.finished = 1
    state.from_bot = fromBot and 1 or 0
    state.force_start = nil
    state.force_end = nil
    _hdjd_save_state(state)
    setsysvar(VarCfg["G_黑暗禁地状态"], 0)
    for _, player in ipairs(getplayerlst() or {}) do
        sendluamsg(player, 101, 12, 4, 14, "")
    end
    _hdjd_clear_all_online()
    sendmovemsg("0", 1, 254, 0, 300, 1, "活动：活动《黑暗禁地》已结束...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "活动：活动《黑暗禁地》已结束...")
    return true
end
local function _hdjd_tick(dqfz, cfg)
    local state = _hdjd_get_state()
    if tonumber(state.force_end) == 1 then
        state.force_end = nil
        _hdjd_save_state(state)
        _hdjd_finish(cfg, true)
        return
    end
    if getsysvar(VarCfg["G_黑暗禁地状态"]) == 1 then
        local startMinute = tonumber(state.start_minute) or dqfz
        if dqfz - startMinute >= cfg.duration_min then
            _hdjd_finish(cfg, false)
        end
        return
    end
    if tonumber(state.force_start) == 1 then
        state.force_start = nil
        _hdjd_save_state(state)
        _hdjd_start(dqfz, cfg, true)
        return
    end
    if dqfz >= ((cfg.min_open_day - 1) * 24 * 60) then
        local hour = tonumber(os.date("%H")) or 0
        local minute = tonumber(os.date("%M")) or 0
        if hour == cfg.start_hour and minute == cfg.start_minute_clock then
            _hdjd_start(dqfz, cfg, false)
        end
    end
end
HdjdApi.start = _hdjd_start
HdjdApi.finish = _hdjd_finish
-- 保卫村庄：活动开启时为 1，关闭时为 0。
BwczApi = BwczApi or {}
local _BWCZ_EVENT_NAME = "保卫村庄"
local _BWCZ_SCORE_VAR = "保卫村庄"
local _BWCZ_MON_LOOKUP = nil
local _BWCZ_HP_LOOKUP = nil
local _BWCZ_TYPE_LOOKUP = nil
local _BWCZ_MERIT_LOOKUP = nil

local function _bwcz_get_cfg()
    local cfg = teshudata and teshudata["anniu_507"] and teshudata["anniu_507"].bwcz or nil
    if type(cfg) ~= "table" then
        return nil
    end
    if type(cfg.map) ~= "string" or cfg.map == "" then
        return nil
    end
    cfg.map = tostring(cfg.map)
    cfg.duration_min = math.max(1, tonumber(cfg.duration_min) or 30)
    cfg.min_open_day = tonumber(cfg.min_open_day) or 2
    cfg.start_hour = tonumber(cfg.start_hour) or 18
    cfg.start_minute_clock = tonumber(cfg.start_minute_clock) or 0
    cfg.score_var = tostring(cfg.score_var or _BWCZ_SCORE_VAR)
    cfg.score_per_join = tonumber(cfg.score_per_join) or 10
    cfg.prepare_notice_min = tonumber(cfg.prepare_notice_min) or 5
    cfg.spawn_radius = tonumber(cfg.spawn_radius) or 24
    cfg.spawn_try_count = tonumber(cfg.spawn_try_count) or 60
    cfg.fixed_damage = tonumber(cfg.fixed_damage) or 1
    cfg.player_hurt_scale = tonumber(cfg.player_hurt_scale) or 0
    cfg.enter_pos = type(cfg.enter_pos) == "table" and cfg.enter_pos or {108, 105}
    cfg.center_pos = type(cfg.center_pos) == "table" and cfg.center_pos or cfg.enter_pos
    cfg.spawn_pos = type(cfg.spawn_pos) == "table" and cfg.spawn_pos or {67, 76}
    cfg.kill_reward = type(cfg.kill_reward) == "table" and cfg.kill_reward or {}
    cfg.rank_rewards = type(cfg.rank_rewards) == "table" and cfg.rank_rewards or {}
    cfg.title_levels = type(cfg.title_levels) == "table" and cfg.title_levels or {}
    cfg.waves = type(cfg.waves) == "table" and cfg.waves or {}
    cfg.mail_title = tostring(cfg.mail_title or _BWCZ_EVENT_NAME)
    cfg.rank_reward_need_title = tostring(cfg.rank_reward_need_title or "镇境武侯")
    return cfg
end

local function _bwcz_get_state()
    local raw = getsysvar(VarCfg["A_保卫村庄json"])
    if raw == "" then
        return {}
    end
    local tb = json2tbl(raw)
    return type(tb) == "table" and tb or {}
end

local function _bwcz_save_state(state)
    setsysvar(VarCfg["A_保卫村庄json"], tbl2json(state or {}))
end

local function _bwcz_build_mon_cache(cfg)
    _BWCZ_MON_LOOKUP = {}
    _BWCZ_HP_LOOKUP = {}
    _BWCZ_TYPE_LOOKUP = {}
    _BWCZ_MERIT_LOOKUP = {}
    for _, wave in ipairs(cfg.waves or {}) do
        for _, spawn in ipairs((wave and wave.spawn) or {}) do
            local monName = tostring(spawn.name or "")
            if monName ~= "" then
                _BWCZ_MON_LOOKUP[monName] = true
                _BWCZ_HP_LOOKUP[monName] = tonumber(spawn.hp) or 100
                _BWCZ_TYPE_LOOKUP[monName] = tostring(spawn.type or "small")
                _BWCZ_MERIT_LOOKUP[monName] = tonumber(spawn.merit) or 0
            end
        end
    end
end

local function _bwcz_ensure_mon_cache(cfg)
    if not _BWCZ_MON_LOOKUP then
        _bwcz_build_mon_cache(cfg)
    end
end

local function _bwcz_is_event_mon(monName, cfg)
    if not cfg then
        return false
    end
    _bwcz_ensure_mon_cache(cfg)
    return _BWCZ_MON_LOOKUP and _BWCZ_MON_LOOKUP[tostring(monName or "")] == true
end

local function _bwcz_get_mon_type(monName, cfg)
    _bwcz_ensure_mon_cache(cfg)
    return (_BWCZ_TYPE_LOOKUP and _BWCZ_TYPE_LOOKUP[tostring(monName or "")]) or "small"
end

local function _bwcz_get_mon_hp(monName, cfg)
    _bwcz_ensure_mon_cache(cfg)
    return tonumber((_BWCZ_HP_LOOKUP and _BWCZ_HP_LOOKUP[tostring(monName or "")]) or 100) or 100
end

local function _bwcz_get_mon_merit(monName, cfg)
    _bwcz_ensure_mon_cache(cfg)
    return tonumber((_BWCZ_MERIT_LOOKUP and _BWCZ_MERIT_LOOKUP[tostring(monName or "")]) or 0) or 0
end

local function _bwcz_get_player_data(play)
    local data = Player.getJsonTableByVar(play, VarCfg["T_保卫村庄"])
    data.merit = tonumber(data.merit) or 0
    data.total_merit = tonumber(data.total_merit) or 0
    data.title_idx = tonumber(data.title_idx) or 0
    data.title = tostring(data.title or "")
    data.kills = tonumber(data.kills) or 0
    data.last_rank = tonumber(data.last_rank) or 0
    data.last_score = tonumber(data.last_score) or 0
    return data
end

local function _bwcz_save_player_data(play, data)
    Player.setJsonVarByTable(play, VarCfg["T_保卫村庄"], data or {})
end

local function _bwcz_clear_legacy_hdjl(play)
    local hdjl = Player.getJsonTableByVar(play, VarCfg.T_hdjl) or {}
    if type(hdjl) == "table" and hdjl.bwcz ~= nil then
        hdjl.bwcz = nil
        Player.setJsonVarByTable(play, VarCfg.T_hdjl, hdjl)
    end
end

local function _bwcz_get_title_cfg_by_idx(cfg, idx)
    idx = tonumber(idx) or 0
    for _, one in ipairs((cfg and cfg.title_levels) or {}) do
        if tonumber(one.idx or 0) == idx then
            return one
        end
    end
    return nil
end

local function _bwcz_get_next_title_cfg(cfg, idx)
    idx = tonumber(idx) or 0
    for _, one in ipairs((cfg and cfg.title_levels) or {}) do
        if tonumber(one.idx or 0) > idx then
            return one
        end
    end
    return nil
end

local function _bwcz_refresh_title(play, cfg, data)
    if not play or not cfg then
        return
    end
    local currentCfg = _bwcz_get_title_cfg_by_idx(cfg, data.title_idx)
    if currentCfg then
        data.title = tostring(currentCfg.name or "")
        if data.title ~= "" and not checktitle(play, data.title) then
            Player.title_give(play, data.title, 1)
        end
        for _, one in ipairs(cfg.title_levels or {}) do
            local name = tostring(one.name or "")
            if name ~= "" and name ~= data.title and checktitle(play, name) then
                Player.title_del(play, name)
            end
        end
    else
        for _, one in ipairs(cfg.title_levels or {}) do
            local name = tostring(one.name or "")
            if name ~= "" and checktitle(play, name) then
                Player.title_del(play, name)
            end
        end
        data.title = ""
    end
end

local function _bwcz_refresh_title_by_total_merit(play, cfg, data)
    local totalMerit = tonumber(data.total_merit) or 0
    local targetIdx = 0
    for _, one in ipairs(cfg.title_levels or {}) do
        local need = tonumber(one.need) or 0
        if totalMerit >= need and tonumber(one.idx or 0) > targetIdx then
            targetIdx = tonumber(one.idx or 0) or targetIdx
        end
    end
    if targetIdx ~= (tonumber(data.title_idx) or 0) then
        data.title_idx = targetIdx
    end
    data.merit = totalMerit
    _bwcz_refresh_title(play, cfg, data)
end

local function _bwcz_add_activity_score(play, cfg)
    if not play or not cfg then
        return
    end
    local data = _bwcz_get_player_data(play)
    if tonumber(data.joined) == 1 then
        return
    end
    data.joined = 1
    data.join_score = (tonumber(data.join_score) or 0) + (tonumber(cfg.score_per_join) or 0)
    local scoreVar = tostring(cfg.score_var or _BWCZ_SCORE_VAR)
    setplayvar(play, "HUMAN", scoreVar, _safe_getplayvar_num(play, "HUMAN", scoreVar) + (tonumber(cfg.score_per_join) or 0), 1)
    _bwcz_save_player_data(play, data)
end

local function _bwcz_reset_online_scores(cfg)
    local scoreVar = tostring((cfg and cfg.score_var) or _BWCZ_SCORE_VAR)
    for _, player in ipairs(getplayerlst() or {}) do
        setplayvar(player, "HUMAN", scoreVar, 0, 1)
        local data = _bwcz_get_player_data(player)
        data.joined = 0
        _bwcz_save_player_data(player, data)
    end
end

local function _bwcz_clear_map_monsters(cfg)
    if not cfg then
        return
    end
    _bwcz_ensure_mon_cache(cfg)
    for monName in pairs(_BWCZ_MON_LOOKUP or {}) do
        killmonsters(cfg.map, monName, 0, false)
    end
end

local function _bwcz_count_alive_monsters(cfg)
    local total = 0
    _bwcz_ensure_mon_cache(cfg)
    for monName in pairs(_BWCZ_MON_LOOKUP or {}) do
        local mons = getmapmon(cfg.map, monName, 0, 0, 999)
        total = total + #(mons or {})
    end
    return total
end

local function _bwcz_spawn_mon(cfg, monName, hp)
    local mapName = tostring(cfg.map or "")
    if mapName == "" or monName == "" then
        return false
    end
    local mapW = tonumber(getmapinfo(mapName, 0) or 0) or 0
    local mapH = tonumber(getmapinfo(mapName, 1) or 0) or 0
    if mapW <= 0 or mapH <= 0 then
        return false
    end
    local cx = tonumber((cfg.spawn_pos and cfg.spawn_pos[1]) or 67) or 67
    local cy = tonumber((cfg.spawn_pos and cfg.spawn_pos[2]) or 76) or 76
    local radius = math.max(1, tonumber(cfg.spawn_radius) or 24)
    local tryCount = math.max(1, tonumber(cfg.spawn_try_count) or 60)
    local missionX = tonumber((cfg.center_pos and cfg.center_pos[1]) or 108) or 108
    local missionY = tonumber((cfg.center_pos and cfg.center_pos[2]) or 105) or 105
    for _ = 1, tryCount do
        local dx = math.random(-radius, radius)
        local dy = math.random(-radius, radius)
        if dx * dx + dy * dy <= radius * radius then
            local x = math.max(1, math.min(mapW, cx + dx))
            local y = math.max(1, math.min(mapH, cy + dy))
            if isemptyinmap(mapName, x, y) then
                local monList = genmonex(mapName, x, y, monName, 1, 1, 0, 54, "", 0)
                if type(monList) == "table" then
                    for _, mon in pairs(monList) do
                        humanhp(mon, "=", tonumber(hp) or 100)
                        monmission(mon, missionX, missionY, 0)
                        return true
                    end
                elseif monList then
                    humanhp(monList, "=", tonumber(hp) or 100)
                    monmission(monList, missionX, missionY, 0)
                    return true
                end
            end
        end
    end
    return false
end

local function _bwcz_spawn_wave(cfg, state, waveIdx)
    local wave = cfg.waves[waveIdx]
    if not wave then
        return false
    end
    _bwcz_clear_map_monsters(cfg)
    local spawned = 0
    for _, spawn in ipairs(wave.spawn or {}) do
        local count = tonumber(spawn.count) or 0
        local monName = tostring(spawn.name or "")
        local hp = tonumber(spawn.hp) or 100
        for _ = 1, count do
            if _bwcz_spawn_mon(cfg, monName, hp) then
                spawned = spawned + 1
            end
        end
    end
    state.current_wave = waveIdx
    state.current_wave_name = tostring(wave.name or waveIdx)
    state.spawn_done = spawned > 0 and 1 or 0
    state.wave_random = tonumber(state.wave_random) or 0
    _bwcz_save_state(state)
    sendmovemsg("0", 1, 254, 0, 300, 1, "活动：保卫村庄当前刷新【" .. tostring(wave.name or waveIdx) .. "】怪物，请尽快清理...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "活动：保卫村庄当前刷新【" .. tostring(wave.name or waveIdx) .. "】怪物，请尽快清理...")
    return spawned > 0
end

local function _bwcz_pick_wave_idx(cfg, state)
    local total = #(cfg.waves or {})
    if total <= 0 then
        return 0
    end
    local last = tonumber(state.wave_random) or 0
    if total == 1 then
        state.wave_random = 1
        return 1
    end
    local idx = math.random(total)
    if idx == last then
        idx = idx + 1
        if idx > total then
            idx = 1
        end
    end
    state.wave_random = idx
    return idx
end

local function _bwcz_on_login(play)
    local cfg = _bwcz_get_cfg()
    if not cfg then
        return
    end
    local data = _bwcz_get_player_data(play)
    _bwcz_refresh_title_by_total_merit(play, cfg, data)
    _bwcz_save_player_data(play, data)
    _bwcz_clear_legacy_hdjl(play)
end

local function _bwcz_is_active_map(play, cfg)
    return play and cfg and getbaseinfo(play, 3) == tostring(cfg.map or "")
end

local function _bwcz_build_rank_data(cfg)
    local rankRaw = sorthumvar(tostring(cfg.score_var or _BWCZ_SCORE_VAR), 1, 1, 10)
    local rankData = {}
    for i = 1, #rankRaw, 2 do
        local name = rankRaw[i]
        local score = tonumber(rankRaw[i + 1]) or 0
        if name and score > 0 then
            rankData[#rankData + 1] = {name = name, score = score}
        end
    end
    return rankData
end

local function _bwcz_start(dqfz, cfg, fromBot)
    if getsysvar(VarCfg["G_保卫村庄状态"]) == 1 then
        return false
    end
    local state = {
        open = 1,
        start_minute = dqfz,
        from_bot = fromBot and 1 or 0,
        map = cfg.map,
        current_wave = 0,
        current_wave_name = "",
        spawn_done = 0,
        wave_random = 0,
    }
    _bwcz_reset_online_scores(cfg)
    _bwcz_clear_map_monsters(cfg)
    setsysvar(VarCfg["G_保卫村庄状态"], 1)
    _bwcz_save_state(state)
    local waveIdx = _bwcz_pick_wave_idx(cfg, state)
    _bwcz_spawn_wave(cfg, state, waveIdx)
    sendmovemsg("0", 1, 254, 0, 300, 1, "活动：活动《保卫村庄》已开启，请尽快前往【" .. tostring(cfg.display_map or cfg.map or "村庄") .. "】参与...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "活动：活动《保卫村庄》已开启，请尽快前往【" .. tostring(cfg.display_map or cfg.map or "村庄") .. "】参与...")
    for _, player in ipairs(getplayerlst() or {}) do
        sendluamsg(player, 101, 12, 1, 1, '{"sk":' .. tostring(tonumber(cfg.duration_min) or 10) .. ',"kf":2,"idx":1}')
    end
    return true
end

local function _bwcz_finish(cfg, fromBot)
    if getsysvar(VarCfg["G_保卫村庄状态"]) ~= 1 then
        return false
    end
    local state = _bwcz_get_state()
    _bwcz_clear_map_monsters(cfg)
    local rankData = _bwcz_build_rank_data(cfg)
    local rewardTitle = tostring(cfg.rank_reward_need_title or "镇境武侯")
    local rewardNames = {}
    for i, one in ipairs(rankData) do
        local reward = cfg.rank_rewards[i]
        local playerObj = getplayerbyname(one.name)
        local data = playerObj and _bwcz_get_player_data(playerObj) or nil
        local titleName = data and tostring(data.title or "") or ""
        if reward and type(reward.items) == "table" and #reward.items > 0 and titleName == rewardTitle then
            sendmail("#" .. one.name, 0, cfg.mail_title or _BWCZ_EVENT_NAME, "恭喜你获得保卫村庄第[" .. tostring(i) .. "]名,奖励已下发!", Player.jl_mail(reward.items))
            rewardNames[one.name] = 1
        end
        if playerObj and data then
            data.last_rank = i
            data.last_score = tonumber(one.score) or 0
            _bwcz_refresh_title_by_total_merit(playerObj, cfg, data)
            _bwcz_save_player_data(playerObj, data)
            data.last = {rank = i, score = one.score, merit = tonumber(data.total_merit) or 0}
            _bwcz_save_player_data(playerObj, data)
        end
    end
    local topName = rankData[1] and rankData[1].name or "无人上榜"
    sendmovemsg("0", 1, 254, 0, 300, 1, "活动：活动《保卫村庄》已结束,本次第一名为【" .. topName .. "】...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "活动：活动《保卫村庄》已结束,本次第一名为【" .. topName .. "】...")
    state.open = 0
    state.finished = 1
    state.from_bot = fromBot and 1 or 0
    state.rank = rankData
    _bwcz_save_state(state)
    setsysvar(VarCfg["G_保卫村庄状态"], 0)
    for _, player in ipairs(getplayerlst() or {}) do
        sendluamsg(player, 101, 12, 4, 1, "")
    end
    return true
end

local function _bwcz_tick(dqfz, cfg)
    local state = _bwcz_get_state()
    if tonumber(state.force_end) == 1 then
        state.force_end = nil
        _bwcz_save_state(state)
        _bwcz_finish(cfg, true)
        return
    end
    if getsysvar(VarCfg["G_保卫村庄状态"]) == 1 then
        local startMinute = tonumber(state.start_minute) or dqfz
        if dqfz - startMinute >= tonumber(cfg.duration_min or 30) then
            _bwcz_finish(cfg, false)
        elseif _bwcz_count_alive_monsters(cfg) <= 0 then
            state.spawn_done = 0
            local waveIdx = _bwcz_pick_wave_idx(cfg, state)
            _bwcz_spawn_wave(cfg, state, waveIdx)
        end
        return
    end
    if tonumber(state.force_start) == 1 then
        state.force_start = nil
        _bwcz_save_state(state)
        _bwcz_start(dqfz, cfg, true)
        return
    end
    if dqfz >= ((tonumber(cfg.min_open_day) - 1) * 24 * 60) then
        local hour = tonumber(os.date("%H")) or 0
        local minute = tonumber(os.date("%M")) or 0
        if hour == tonumber(cfg.start_hour) and minute == tonumber(cfg.start_minute_clock) then
            _bwcz_start(dqfz, cfg, false)
        elseif hour == tonumber(cfg.start_hour) and minute == math.max(0, tonumber(cfg.start_minute_clock) - tonumber(cfg.prepare_notice_min or 5)) then
            sendmovemsg("0", 1, 254, 0, 300, 1, "活动：活动《保卫村庄》将在" .. tostring(cfg.prepare_notice_min or 5) .. "分钟后开启，请提前做好准备...")
            sendmovemsg("0", 1, 254, 0, 270, 1, "活动：活动《保卫村庄》将在" .. tostring(cfg.prepare_notice_min or 5) .. "分钟后开启，请提前做好准备...")
        end
    end
end

local function _bwcz_add_merit(play, monName, cfg)
    local merit = _bwcz_get_mon_merit(monName, cfg)
    if merit <= 0 then
        return
    end
    local data = _bwcz_get_player_data(play)
    data.merit = (tonumber(data.merit) or 0) + merit
    data.total_merit = (tonumber(data.total_merit) or 0) + merit
    data.kills = (tonumber(data.kills) or 0) + 1
    _bwcz_refresh_title_by_total_merit(play, cfg, data)
    _bwcz_save_player_data(play, data)
end

local function _bwcz_give_kill_reward(play, monName, cfg)
    local monType = _bwcz_get_mon_type(monName, cfg)
    local reward = cfg.kill_reward and cfg.kill_reward[monType] or nil
    if type(reward) == "table" and #reward > 0 then
        Player.rwjl(play, reward, _BWCZ_EVENT_NAME, 1, 0)
    end
end

BwczApi.get_cfg = _bwcz_get_cfg
BwczApi.get_state = _bwcz_get_state
BwczApi.save_state = _bwcz_save_state
BwczApi.get_player_data = _bwcz_get_player_data
BwczApi.save_player_data = _bwcz_save_player_data
BwczApi.get_title_cfg_by_idx = _bwcz_get_title_cfg_by_idx
BwczApi.get_next_title_cfg = _bwcz_get_next_title_cfg
BwczApi.refresh_title = _bwcz_refresh_title_by_total_merit
BwczApi.start = _bwcz_start
BwczApi.finish = _bwcz_finish
BwczApi.tick = _bwcz_tick
BwczApi.is_event_mon = _bwcz_is_event_mon
BwczApi.is_active_map = _bwcz_is_active_map
BwczApi.get_mon_hp = _bwcz_get_mon_hp
BwczApi.get_mon_merit = _bwcz_get_mon_merit
BwczApi.get_mon_type = _bwcz_get_mon_type
BwczApi.count_alive_monsters = _bwcz_count_alive_monsters
BwczApi.add_merit = _bwcz_add_merit
BwczApi.add_activity_score = _bwcz_add_activity_score
BwczApi.give_kill_reward = _bwcz_give_kill_reward
BwczApi.build_rank_data = _bwcz_build_rank_data

local function _bwcz_send_498_panel(play, cfg)
    if not play or not cfg then
        return
    end
    local state = _bwcz_get_state()
    local scoreVar = tostring(cfg.score_var or _BWCZ_SCORE_VAR)
    local payload = {
        pmsj = sorthumvar(scoreVar, 1, 1, 5),
        grjf = tonumber(getplayvar(play, "HUMAN", scoreVar) or 0) or 0,
        wave_name = tostring(state.current_wave_name or ""),
        left_mon = _bwcz_count_alive_monsters(cfg),
    }
    sendluamsg(play, 101, 498, 1, 0, tbl2json(payload))
end
BwczApi.send_498_panel = _bwcz_send_498_panel

local function _bwcz_on_login_event(play)
    _bwcz_on_login(play)
end

local function _bwcz_on_kill_mon(play, mob)
    local cfg = _bwcz_get_cfg()
    if not cfg or getsysvar(VarCfg["G_保卫村庄状态"]) ~= 1 then
        return
    end
    local mapName = tostring(getbaseinfo(mob, 3) or "")
    local monName = tostring(getbaseinfo(mob, 1) or "")
    if mapName ~= tostring(cfg.map or "") or not _bwcz_is_event_mon(monName, cfg) then
        return
    end
    setplayvar(play, "HUMAN", tostring(cfg.score_var or _BWCZ_SCORE_VAR), (_safe_getplayvar_num(play, "HUMAN", tostring(cfg.score_var or _BWCZ_SCORE_VAR)) + _bwcz_get_mon_merit(monName, cfg)), 1)
    _bwcz_add_merit(play, monName, cfg)
    _bwcz_give_kill_reward(play, monName, cfg)
    _bwcz_send_498_panel(play, cfg)
end
BwczApi.onKillMon = _bwcz_on_kill_mon

GameEvent.add(EventCfg.onLogin, _bwcz_on_login_event, "保卫村庄登录修正")
GameEvent.add(EventCfg.onKFLogin, _bwcz_on_login_event, "保卫村庄跨服登录修正")
local _MSKH_EVENT_NAME = "美食狂欢"
local _MSKH_SCORE_VAR = "美食狂欢"
local _MSKH_WEAPON_LEVEL_VAR = VarCfg["T_时光之杖等级"] or "T57"
local _MSKH_TITLE_ATTR_LIST = "title_mskh_gourmet"
local _MSKH_TITLE_ATTR = "3#242#1000|3#34#1000"
MskhApi = MskhApi or {}

local function _mskh_get_cfg()
    local cfg = teshudata and teshudata["anniu_507"] and teshudata["anniu_507"].mskh or nil
    if type(cfg) ~= "table" then
        return nil
    end
    if type(cfg.map) ~= "string" or cfg.map == "" then
        return nil
    end
    cfg.map = tostring(cfg.map)
    cfg.duration_min = tonumber(cfg.duration_min) or 30
    cfg.score_per_join = tonumber(cfg.score_per_join) or 10
    cfg.collect_sec = tonumber(cfg.collect_sec) or 8
    cfg.title_collect_sec = tonumber(cfg.title_collect_sec) or 4
    cfg.start_hour = tonumber(cfg.start_hour) or 16
    cfg.start_minute_clock = tonumber(cfg.start_minute_clock) or 0
    cfg.min_open_day = tonumber(cfg.min_open_day) or 2
    cfg.spawn_radius = tonumber(cfg.spawn_radius) or 16
    cfg.spawn_try_count = tonumber(cfg.spawn_try_count) or 40
    cfg.respawn_sec = tonumber(cfg.respawn_sec) or 8
    cfg.center_pos = type(cfg.center_pos) == "table" and cfg.center_pos or {18, 18}
    cfg.initial_spawn = type(cfg.initial_spawn) == "table" and cfg.initial_spawn or {}
    cfg.mon = type(cfg.mon) == "table" and cfg.mon or {}
    cfg.meats = type(cfg.meats) == "table" and cfg.meats or {}
    cfg.shop = type(cfg.shop) == "table" and cfg.shop or {}
    return cfg
end

local function _mskh_get_state()
    local raw = getsysvar(VarCfg["A_美食狂欢json"])
    if raw == "" then
        return {}
    end
    local tb = json2tbl(raw)
    return type(tb) == "table" and tb or {}
end

local function _mskh_save_state(state)
    setsysvar(VarCfg["A_美食狂欢json"], tbl2json(state or {}))
end

local function _mskh_get_player_data(play)
    local data = Player.getJsonTableByVar(play, VarCfg["T_美食狂欢"])
    data.point = tonumber(data.point) or 0
    data.joined = tonumber(data.joined) or 0
    data.collecting = tonumber(data.collecting) or 0
    data.collect_target = tostring(data.collect_target or "")
    data.collect_mon_name = tostring(data.collect_mon_name or "")
    data.last_rank = tonumber(data.last_rank) or 0
    data.last_score = tonumber(data.last_score) or 0
    data.shop_buy = type(data.shop_buy) == "table" and data.shop_buy or {}
    data.collect_total = tonumber(data.collect_total) or 0
    return data
end

local function _mskh_save_player_data(play, data)
    Player.setJsonVarByTable(play, VarCfg["T_美食狂欢"], data or {})
end

local function _mskh_get_player_name(play)
    return tostring(getbaseinfo(play, ConstCfg.gbase.name) or "")
end

local function _mskh_normalize_collect_state(state)
    state = type(state) == "table" and state or {}
    state.collect_claimed = type(state.collect_claimed) == "table" and state.collect_claimed or {}
    state.collect_locks = type(state.collect_locks) == "table" and state.collect_locks or {}
    return state
end

local function _mskh_reset_collect_data(data)
    data = type(data) == "table" and data or {}
    data.collecting = 0
    data.collect_target = ""
    data.collect_mon_name = ""
    return data
end

local function _mskh_release_collect_lock(state, targetKey, playerName, markClaimed)
    state = _mskh_normalize_collect_state(state)
    targetKey = tostring(targetKey or "")
    playerName = tostring(playerName or "")
    if targetKey == "" then
        return state
    end
    local lockOwner = tostring(state.collect_locks[targetKey] or "")
    if playerName == "" or lockOwner == "" or lockOwner == playerName then
        state.collect_locks[targetKey] = nil
        if markClaimed then
            state.collect_claimed[targetKey] = 1
        end
    end
    return state
end

local function _mskh_get_weapon_level(play)
    local recordLevel = tonumber(getplaydef(play, _MSKH_WEAPON_LEVEL_VAR) or 0) or 0
    local oldLevel = tonumber(getplaydef(play, VarCfg["T_时光之杖"]) or 0) or 0
    local equipLevel = tonumber(Player.getEquipFieldByPos(play, 71, 1) or 0) or 0
    local equipName = tostring(Player.getEquipNameByPos(play, 71) or "")
    local nameLevel = tonumber(string.match(equipName, "Lv%.(%d+)") or string.match(equipName, "Lv(%d+)") or string.match(equipName, "%[lv(%d+)%]")) or 0
    local finalLevel = math.max(recordLevel, oldLevel, equipLevel, nameLevel)
    if finalLevel > 0 and recordLevel ~= finalLevel then
        setplaydef(play, _MSKH_WEAPON_LEVEL_VAR, finalLevel)
    end
    return finalLevel
end

local function _mskh_set_weapon_level(play, level)
    level = math.max(0, math.min(10, tonumber(level) or 0))
    setplaydef(play, _MSKH_WEAPON_LEVEL_VAR, level)
end

local function _mskh_has_title(play, cfg)
    local titleName = tostring((cfg and cfg.title_name) or "美食家")
    return titleName ~= "" and checktitle(play, titleName)
end

local function _mskh_refresh_title_attr(play, cfg)
    -- 美食家基础属性已统一写入真实称号表，这里只清理旧版脚本附加属性，避免重复叠加。
    Player.del_attlist(play, _MSKH_TITLE_ATTR_LIST)
end

local function _mskh_get_event_attack_damage(play, target, cfg)
    local damage = 1
    if _mskh_has_title(play, cfg) then
        damage = damage + 1
    end
    return damage
end

local function _mskh_collect_sec(play, cfg)
    if _mskh_has_title(play, cfg) then
        return tonumber(cfg.title_collect_sec) or 4
    end
    return tonumber(cfg.collect_sec) or 8
end

local function _mskh_get_mon_cfg(monName, cfg)
    return cfg and cfg.mon and cfg.mon[tostring(monName or "")] or nil
end

local function _mskh_is_event_mon(monName, cfg)
    return _mskh_get_mon_cfg(monName, cfg) ~= nil
end

local function _mskh_is_active_map(play, cfg)
    return play and cfg and getbaseinfo(play, 3) == tostring(cfg.map or "")
end

local function _mskh_get_map_name(cfg, state)
    return (state and state.map and state.map ~= "") and state.map or (cfg and cfg.map) or ""
end

local function _mskh_add_activity_score(play, cfg)
    if not play or not cfg then
        return
    end
    local data = _mskh_get_player_data(play)
    if tonumber(data.joined) == 1 then
        return
    end
    data.joined = 1
    _mskh_save_player_data(play, data)
    setplayvar(play, "HUMAN", tostring(cfg.score_var or _MSKH_SCORE_VAR), _safe_getplayvar_num(play, "HUMAN", tostring(cfg.score_var or _MSKH_SCORE_VAR)) + (tonumber(cfg.score_per_join) or 0), 1)
end
local function _mskh_reset_online_scores(cfg)
    local scoreVar = tostring((cfg and cfg.score_var) or _MSKH_SCORE_VAR)
    for _, player in ipairs(getplayerlst() or {}) do
        setplayvar(player, "HUMAN", scoreVar, 0, 1)
        local data = _mskh_get_player_data(player)
        data.joined = 0
        data = _mskh_reset_collect_data(data)
        _mskh_save_player_data(player, data)
        _mskh_refresh_title_attr(player, cfg)
    end
end

local function _mskh_clear_map_monsters(cfg, state)
    if not cfg then
        return
    end
    local mapName = _mskh_get_map_name(cfg, state)
    for monName in pairs(cfg.mon or {}) do
        killmonsters(mapName, monName, 0, false)
    end
end

local function _mskh_count_alive_monsters(cfg, state)
    local total = 0
    local mapName = _mskh_get_map_name(cfg, state)
    for monName in pairs(cfg.mon or {}) do
        local mons = getmapmon(mapName, monName, 0, 0, 999)
        total = total + #(mons or {})
    end
    return total
end

local function _mskh_spawn_one_mon(cfg, state, monName, hpHits)
    local mapName = _mskh_get_map_name(cfg, state)
    if mapName == "" or monName == "" then
        return false
    end
    local mapW = tonumber(getmapinfo(mapName, 0) or 0) or 0
    local mapH = tonumber(getmapinfo(mapName, 1) or 0) or 0
    if mapW <= 0 or mapH <= 0 then
        return false
    end
    local cx = tonumber((cfg.center_pos and cfg.center_pos[1]) or 18) or 18
    local cy = tonumber((cfg.center_pos and cfg.center_pos[2]) or 18) or 18
    local radius = math.max(1, tonumber(cfg.spawn_radius) or 16)
    local tryCount = math.max(1, tonumber(cfg.spawn_try_count) or 40)
    for _ = 1, tryCount do
        local dx = math.random(-radius, radius)
        local dy = math.random(-radius, radius)
        if dx * dx + dy * dy <= radius * radius then
            local x = math.max(1, math.min(mapW, cx + dx))
            local y = math.max(1, math.min(mapH, cy + dy))
            if isemptyinmap(mapName, x, y) then
                local monList = genmonex(mapName, x, y, monName, 1, 1, 0, 54, "", 0)
                if type(monList) == "table" then
                    for _, mon in pairs(monList) do
                        humanhp(mon, "=", tonumber(hpHits) or 10)
                        return true
                    end
                elseif monList then
                    humanhp(monList, "=", tonumber(hpHits) or 10)
                    return true
                end
            end
        end
    end
    return false
end

local function _mskh_spawn_all(cfg, state)
    state = _mskh_normalize_collect_state(state)
    state.collect_claimed = {}
    state.collect_locks = {}
    local spawned = 0
    for _, one in ipairs(cfg.initial_spawn or {}) do
        local monName = tostring(one.name or "")
        local count = tonumber(one.count) or 0
        local monCfg = _mskh_get_mon_cfg(monName, cfg) or {}
        local hpHits = tonumber(monCfg.hp_hits) or 10
        for _ = 1, count do
            if _mskh_spawn_one_mon(cfg, state, monName, hpHits) then
                spawned = spawned + 1
            end
        end
    end
    state.spawn_done = spawned > 0 and 1 or 0
    state.last_spawn_ts = os.time()
    _mskh_save_state(state)
    return spawned
end

local function _mskh_tick_runtime(cfg, state)
    if not cfg or type(state) ~= "table" or getsysvar(VarCfg["G_美食狂欢状态"]) ~= 1 or tonumber(state.open) ~= 1 then
        return state
    end
    if tonumber(state.spawn_done) ~= 1 or _mskh_count_alive_monsters(cfg, state) <= 0 then
        _mskh_clear_map_monsters(cfg, state)
        _mskh_spawn_all(cfg, state)
    end
    return state
end

local function _mskh_interrupt_collect(play, reason)
    local cfg = _mskh_get_cfg()
    if not cfg then
        return
    end
    local data = _mskh_get_player_data(play)
    local targetName = tostring(data.collect_mon_name or getplaydef(play, "S$采集目标名字") or "")
    local targetKey = tostring(data.collect_target or getplaydef(play, "S$采集目标") or "")
    if tonumber(data.collecting) == 1 or _mskh_is_event_mon(targetName, cfg) then
        local state = _mskh_get_state()
        state = _mskh_release_collect_lock(state, targetKey, _mskh_get_player_name(play), false)
        _mskh_save_state(state)
        data = _mskh_reset_collect_data(data)
        _mskh_save_player_data(play, data)
        setplaydef(play, "N$iscaiji", 0)
        setplaydef(play, "S$采集目标", "")
        setplaydef(play, "S$采集目标名字", "")
        if reason and reason ~= "" then
            Player.sendmsgEx(play, reason .. "#57")
        end
    end
end

local function _mskh_on_actor_die(play)
    local cfg = _mskh_get_cfg()
    local state = _mskh_get_state()
    if _mskh_is_active_map(play, cfg) and tonumber(state.open) == 1 then
        _mskh_interrupt_collect(play, "你已死亡，割肉中断")
    end
end

local function _mskh_build_rank_data(cfg)
    local scoreVar = tostring((cfg and cfg.score_var) or _MSKH_SCORE_VAR)
    local rankRaw = sorthumvar(scoreVar, 1, 1, 10)
    local rankData = {}
    for i = 1, #rankRaw, 2 do
        local name = rankRaw[i]
        local score = tonumber(rankRaw[i + 1]) or 0
        if name and score > 0 then
            rankData[#rankData + 1] = {name = name, score = score}
        end
    end
    return rankData
end

local function _mskh_start(dqfz, cfg, fromBot)
    if getsysvar(VarCfg["G_美食狂欢状态"]) == 1 then
        return false
    end
    local state = {
        open = 1,
        start_minute = dqfz,
        from_bot = fromBot and 1 or 0,
        map = cfg.map,
        spawn_done = 0,
        last_spawn_ts = 0,
        collect_claimed = {},
        collect_locks = {},
    }
    _mskh_reset_online_scores(cfg)
    _mskh_clear_map_monsters(cfg, state)
    setsysvar(VarCfg["G_美食狂欢状态"], 1)
    _mskh_save_state(state)
    _mskh_tick_runtime(cfg, state)
    sendmovemsg("0", 1, 254, 0, 300, 1, "活动：活动《美食狂欢》已开启，请尽快前往【" .. tostring(cfg.map or "天材地宝") .. "】参与...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "活动：活动《美食狂欢》已开启，击杀鸡羊鹿会直接掉落对应肉类...")
    for _, player in ipairs(getplayerlst() or {}) do
        sendluamsg(player, 101, 12, 1, 6, '{"sk":' .. tostring(tonumber(cfg.duration_min) or 30) .. ',"kf":2,"idx":6}')
    end
    return true
end

local function _mskh_finish(cfg, fromBot)
    if getsysvar(VarCfg["G_美食狂欢状态"]) ~= 1 then
        return false
    end
    local state = _mskh_get_state()
    _mskh_clear_map_monsters(cfg, state)
    local rankData = _mskh_build_rank_data(cfg)
    for i, one in ipairs(rankData) do
        local playerObj = getplayerbyname(one.name)
        if playerObj then
            local data = _mskh_get_player_data(playerObj)
            data.last_rank = i
            data.last_score = tonumber(one.score) or 0
            _mskh_save_player_data(playerObj, data)
        end
    end
    local topName = rankData[1] and rankData[1].name or "无人上榜"
    sendmovemsg("0", 1, 254, 0, 300, 1, "活动：活动《美食狂欢》已结束,本次第一名为【" .. topName .. "】...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "活动：活动《美食狂欢》已结束...")
    state.open = 0
    state.finished = 1
    state.from_bot = fromBot and 1 or 0
    state.rank = rankData
    state.collect_claimed = {}
    state.collect_locks = {}
    _mskh_save_state(state)
    setsysvar(VarCfg["G_美食狂欢状态"], 0)
    for _, player in ipairs(getplayerlst() or {}) do
        sendluamsg(player, 101, 12, 4, 6, "")
    end
    return true
end

local function _mskh_tick(dqfz, cfg)
    local state = _mskh_get_state()
    if tonumber(state.force_end) == 1 then
        state.force_end = nil
        _mskh_save_state(state)
        _mskh_finish(cfg, true)
        return
    end
    if getsysvar(VarCfg["G_美食狂欢状态"]) == 1 then
        local startMinute = tonumber(state.start_minute) or dqfz
        if dqfz - startMinute >= tonumber(cfg.duration_min or 30) then
            _mskh_finish(cfg, false)
        else
            _mskh_tick_runtime(cfg, state)
        end
        return
    end
    if tonumber(state.force_start) == 1 then
        state.force_start = nil
        _mskh_save_state(state)
        _mskh_start(dqfz, cfg, true)
        return
    end
    if dqfz >= ((tonumber(cfg.min_open_day) - 1) * 24 * 60) then
        local hour = tonumber(os.date("%H")) or 0
        local minute = tonumber(os.date("%M")) or 0
        if hour == tonumber(cfg.start_hour) and minute == tonumber(cfg.start_minute_clock) then
            _mskh_start(dqfz, cfg, false)
        end
    end
end

local function _mskh_on_login(play)
    local cfg = _mskh_get_cfg()
    if not cfg then
        return
    end
    _mskh_get_weapon_level(play)
    local data = _mskh_get_player_data(play)
    local state = _mskh_get_state()
    state = _mskh_release_collect_lock(state, tostring(data.collect_target or ""), _mskh_get_player_name(play), false)
    _mskh_save_state(state)
    data = _mskh_reset_collect_data(data)
    _mskh_save_player_data(play, data)
    _mskh_refresh_title_attr(play, cfg)
end
local function _mskh_gain_meat(play, monName, cfg)
    local monCfg = _mskh_get_mon_cfg(monName, cfg)
    if not monCfg then
        return false
    end
    local meatName = tostring(monCfg.meat or "")
    if meatName == "" then
        return false
    end
    giveitem(play, meatName, 1)
    local data = _mskh_get_player_data(play)
    data.collect_total = (tonumber(data.collect_total) or 0) + 1
    _mskh_save_player_data(play, data)
    Player.sendmsgEx(play, "掉落获得#218|" .. meatName .. "*1#57")
    return true
end

local function _mskh_add_point(play, itemName, count, cfg)
    local meatCfg = cfg and cfg.meats and cfg.meats[tostring(itemName or "")] or nil
    if not meatCfg then
        return false
    end
    local addPoint = (tonumber(meatCfg.point) or 0) * math.max(1, tonumber(count) or 0)
    if addPoint <= 0 then
        return false
    end
    local data = _mskh_get_player_data(play)
    data.point = (tonumber(data.point) or 0) + addPoint
    _mskh_save_player_data(play, data)
    Player.sendmsgEx(play, "成功出售#218|" .. tostring(itemName) .. "*" .. tostring(count) .. "#57，获得#218|美食积分*" .. tostring(addPoint) .. "#57")
    return true
end

local function _mskh_buy_shop(play, idx, cfg)
    local shopCfg = cfg and cfg.shop and cfg.shop[idx] or nil
    if type(shopCfg) ~= "table" then
        Player.sendmsgEx(play, "兑换项不存在#57")
        return false
    end
    local data = _mskh_get_player_data(play)
    local point = tonumber(data.point) or 0
    local cost = tonumber(shopCfg.cost) or 0
    local limit = tonumber(shopCfg.limit) or 0
    local buyMap = type(data.shop_buy) == "table" and data.shop_buy or {}
    local buyNum = tonumber(buyMap[tostring(idx)] or 0) or 0
    if limit > 0 and buyNum >= limit then
        Player.sendmsgEx(play, "该奖励已达到兑换上限#57")
        return false
    end
    if point < cost then
        Player.sendmsgEx(play, "美食积分不足#57")
        return false
    end
    local reward = shopCfg.reward or {}
    if tostring(reward.kind or "") == "title" then
        local titleName = tostring(reward.name or shopCfg.name or "")
        if titleName == "" then
            Player.sendmsgEx(play, "称号配置缺失#57")
            return false
        end
        if checktitle(play, titleName) then
            Player.sendmsgEx(play, "你已拥有该称号#57")
            return false
        end
        Player.title_give(play, titleName, 1)
        _mskh_refresh_title_attr(play, cfg)
    else
        local give = type(reward.give) == "table" and reward.give or {}
        if #give <= 0 then
            Player.sendmsgEx(play, "奖励配置缺失#57")
            return false
        end
        if tostring(((give[1] or {})[1]) or "") == "时光之杖" then
            local lv = _mskh_get_weapon_level(play)
            if lv >= 10 then
                Player.sendmsgEx(play, "时光之杖已达到最高10级#57")
                return false
            end
            local nextItemName = string.format("时光之杖Lv.%d", lv + 1)
            local itemobj = linkbodyitem(play, 71)
            if itemobj and itemobj ~= "0" then
                changeitemidx(play, getiteminfo(play, itemobj, 1), getstditeminfo(nextItemName, ConstCfg.stditeminfo.idx))
                refreshitem(play, linkbodyitem(play, 71))
            else
                giveonitem(play, 71, nextItemName, 1)
            end
            _mskh_set_weapon_level(play, lv + 1)
        else
            Player.rwjl(play, give, _MSKH_EVENT_NAME, 1, 0)
        end
    end
    data.point = point - cost
    buyMap[tostring(idx)] = buyNum + 1
    data.shop_buy = buyMap
    _mskh_save_player_data(play, data)
    Player.sendmsgEx(play, "兑换成功#218")
    return true
end

MskhApi.get_cfg = _mskh_get_cfg
MskhApi.get_state = _mskh_get_state
MskhApi.save_state = _mskh_save_state
MskhApi.get_player_data = _mskh_get_player_data
MskhApi.save_player_data = _mskh_save_player_data
MskhApi.is_event_mon = _mskh_is_event_mon
MskhApi.is_active_map = _mskh_is_active_map
MskhApi.add_activity_score = _mskh_add_activity_score
MskhApi.start = _mskh_start
MskhApi.finish = _mskh_finish
MskhApi.tick = _mskh_tick
MskhApi.tick_runtime = _mskh_tick_runtime
MskhApi.before_collect = function(play, monName, monMakeIndex)
    local cfg = _mskh_get_cfg()
    if not cfg or not _mskh_is_event_mon(monName, cfg) then
        return "pass"
    end
    Player.sendmsgEx(play, "美食狂欢已改为击杀直接掉落肉，无需采集#57")
    return "blocked"
end
MskhApi.on_collect_success = function(play, monName, monMakeIndex)
    local cfg = _mskh_get_cfg()
    if not cfg or not _mskh_is_event_mon(monName, cfg) then
        return false
    end
    local state = _mskh_normalize_collect_state(_mskh_get_state())
    local data = _mskh_get_player_data(play)
    local playerName = _mskh_get_player_name(play)
    local targetKey = tostring(data.collect_target or monMakeIndex or "")
    data = _mskh_reset_collect_data(data)
    _mskh_save_player_data(play, data)
    if getsysvar(VarCfg["G_美食狂欢状态"]) ~= 1 or tonumber(state.open) ~= 1 or not _mskh_is_active_map(play, cfg) then
        state = _mskh_release_collect_lock(state, targetKey, playerName, false)
        _mskh_save_state(state)
        Player.sendmsgEx(play, "美食狂欢当前未开启#57")
        return true
    end
    if targetKey == "" then
        Player.sendmsgEx(play, "割肉目标异常#57")
        return true
    end
    if state.collect_claimed[targetKey] then
        Player.sendmsgEx(play, "该动物尸体已被他人割走#57")
        return true
    end
    local lockOwner = tostring(state.collect_locks[targetKey] or "")
    if lockOwner ~= "" and lockOwner ~= playerName then
        Player.sendmsgEx(play, "该动物尸体已被他人割走#57")
        return true
    end
    state = _mskh_release_collect_lock(state, targetKey, playerName, true)
    _mskh_save_state(state)
    local mapid = getbaseinfo(play, ConstCfg.gbase.mapid)
    local monobj = (targetKey ~= "") and getmonbyuserid(mapid, targetKey) or nil
    if monobj then
        killmonbyobj(play, monobj, false, false, false)
    end
    _mskh_gain_meat(play, monName, cfg)
    return true
end
MskhApi.on_collect_fail = function(play, monName)
    local cfg = _mskh_get_cfg()
    if not cfg or not _mskh_is_event_mon(monName, cfg) then
        return false
    end
    local data = _mskh_get_player_data(play)
    local state = _mskh_get_state()
    state = _mskh_release_collect_lock(state, tostring(data.collect_target or ""), _mskh_get_player_name(play), false)
    _mskh_save_state(state)
    data = _mskh_reset_collect_data(data)
    _mskh_save_player_data(play, data)
    return true
end
MskhApi.on_actor_hurt = _mskh_interrupt_collect
MskhApi.on_actor_move = function(play)
    _mskh_interrupt_collect(play, "你移动了，割肉中断")
end
MskhApi.on_actor_die = _mskh_on_actor_die
MskhApi.sell_meat = _mskh_add_point
MskhApi.buy_shop = _mskh_buy_shop
MskhApi.build_rank_data = _mskh_build_rank_data
MskhApi.has_title = _mskh_has_title
MskhApi.get_weapon_level = _mskh_get_weapon_level
MskhApi.set_weapon_level = _mskh_set_weapon_level
MskhApi.get_attack_damage = _mskh_get_event_attack_damage
MskhApi.refresh_title_attr = _mskh_refresh_title_attr

local function _mskh_on_login_event(play)
    _mskh_on_login(play)
end

GameEvent.add(EventCfg.onLogin, _mskh_on_login_event, "美食狂欢登录修正")
GameEvent.add(EventCfg.onKFLogin, _mskh_on_login_event, "美食狂欢跨服登录修正")
local _QMDK_EVENT_NAME = "全民夺矿"
local _WLMZ_EVENT_NAME = "武林盟主"
local _WLMZ_MAP_NAME = "比武大会"
local _WLMZ_SCORE_VAR = "比武大会"
function ontimerex1()
    local xqyz = tonumber(getsysvar(VarCfg["G_新区验证"])) or 0
    if xqyz > 0 and not checkkuafuserver() then
        local dqfz = (tonumber(getsysvar(VarCfg["G_开区分钟"])) or 0) + 1
        setsysvar(VarCfg["G_开区分钟"], dqfz)
        -- 在全局每分钟心跳中轮询血契之门真实编号的开放提示。
        if Npclib and Npclib[81] and Npclib[81].roll_open_notice then
            pcall(Npclib[81].roll_open_notice)
        end
        local txzr_round = tonumber(getsysvar(VarCfg["G_天选之人"][2])) or 0
        if txzr_round < 4 then
            local txsj = (tonumber(getsysvar(VarCfg["G_天选之人"][1])) or 0) + 1
            if txsj >= 30 then--30分钟一轮
                setsysvar(VarCfg["G_天选之人"][1], 0)
                txzr_round = txzr_round + 1
                setsysvar(VarCfg["G_天选之人"][2], txzr_round)
                local djl = txzr_round
                local wjlb, lins = getplayerlst(), {}
                for i, v in pairs(wjlb or {}) do
                    local sc_data = Player.getJsonTableByVar(v, VarCfg["T_首冲礼包"])
                    local canJoin = sc_data and sc_data["ok"] == 1
                    if canJoin then
                        table.insert(lins, {getbaseinfo(v, 1), _txzr_get_roll_point(v, djl)})
                    end
                end
                local txzz_data = getsysvar(VarCfg["A_天选之人json"]) or ""
                txzz_data = txzz_data == "" and {} or json2tbl(txzz_data)
                txzz_data["md" .. djl] = {}
                table.sort(lins, function(a, b)
                    return a[2] > b[2]
                end)
                for i = 1, 10, 1 do
                    if lins[i] then
                        table.insert(txzz_data["md" .. djl], lins[i])
                    end
                end
                local rewardList = _txzr_get_reward_list()
                local joinReward = _txzr_get_join_reward_cfg()
                local top10_name_map = {}
                for _, one in ipairs(txzz_data["md" .. djl]) do
                    top10_name_map[one[1]] = true
                end
                for i, v in ipairs(txzz_data["md" .. djl]) do
                    local rewardName = rewardList[i]
                    if rewardName and rewardName ~= "" then
                        txzz_data["jl" .. djl .. i] = rewardName
                        sendmail("#" .. v[1], 1, "天选之人", "恭喜您,获得天选之人第[" .. constant.pz_hanzi[i] .. "]名奖励！", rewardName .. "#1#850")
                    end
                    local shenqiName = nil
                    if i == 1 then
                        shenqiName = _txzr_pick_unique_shenqi(txzz_data, v[1])
                        if shenqiName then
                            sendmail("#" .. v[1], 1, "天选之人", "恭喜您,获得天选之人第一名额外背包神器奖励！", shenqiName .. "#1#850")
                            txzz_data["sq" .. djl] = {player = v[1], item = shenqiName}
                        end
                        local firstRewardName = rewardList[1] or "128元真实充值卷"
                        local firstMsg = "天选之人：玩家《" .. v[1] .. "》获得了天选之人第一名奖励：" .. firstRewardName
                        if shenqiName then
                            firstMsg = firstMsg .. "，额外获得背包神器《" .. shenqiName .. "》"
                        end
                        firstMsg = firstMsg .. "..."
                        sendmovemsg("0", 1, 253, 0, 300, 1, firstMsg)
                        sendmovemsg("0", 1, 249, 0, 250, 1, firstMsg)
                    end
                    local playerObj = getplayerbyname(v[1])
                    _txzr_save_player_history(playerObj, djl, i, v[2], rewardName, shenqiName)
                end
                if joinReward and (joinReward.count or 0) > 0 then
                    local joinRewardName = joinReward.desc ~= "" and joinReward.desc or (joinReward.item .. "*" .. tostring(joinReward.count))
                    for _, one in ipairs(lins) do
                        if one and one[1] and not top10_name_map[one[1]] then
                            sendmail("#" .. one[1], 1, "天选之人", "恭喜您,获得天选之人参与奖励！", joinReward.item .. "#" .. tostring(joinReward.count) .. "#850")
                            local joinPlayerObj = getplayerbyname(one[1])
                            _txzr_save_player_history(joinPlayerObj, djl, 0, one[2], joinRewardName, nil)
                        end
                    end
                end
                _txzr_broadcast_roll(djl, txzz_data["md" .. djl])
                _txzr_broadcast_reward_rollscreen(djl, txzz_data["md" .. djl], rewardList, txzz_data)
                txzz_data["notice"] = _txzr_get_notice_cfg()
                txzz_data["shenqi"] = _txzr_get_shenqi_cfg()
                setsysvar(VarCfg["A_天选之人json"], tbl2json(txzz_data))
            else
                setsysvar(VarCfg["G_天选之人"][1], txsj)
                if dqfz == 1 then
                    sendmovemsg("0", 1, 253, 0, 300, 1,"天选之人：活动《天选之人》已开启,请玩家尽快参与...")
                    sendmovemsg("0", 1, 249, 0, 250, 1,"天选之人：活动《天选之人》已开启,请玩家尽快参与...")
                    -- local player_list = getplayerlst()
                    -- for i, player  in ipairs(player_list or {}) do
                    --     sendluamsg(player,101,12,1,7,'{"sk":120,"kf":2,"idx":7}')
                    -- end
                elseif txsj == 29 then
                    sendmovemsg("0", 1, 253, 0, 300, 1,"天选之人：活动《天选之人》即将开启,请玩家做好准备...")
                    sendmovemsg("0", 1, 249, 0, 250, 1,"天选之人：活动《天选之人》即将开启,请玩家做好准备...")
                    local player_list = getplayerlst()
                    for i, player  in ipairs(player_list or {}) do
                        -- sendluamsg(player,101,1,13,0,"")
                        sendluamsg(player,101,12,1,7,'{"sk":2,"kf":2,"idx":7}')
                    end
                end
            end
            if dqfz == 5 then
                _tcppk_begin_round()
                _tcppk_set_activity_equip_count(0)
                setenvirontimer("xtc",1,3,"@hd_tcppk,xtc")
                local t = getplayerlst()
                for _, v in pairs(t) do
                    sendluamsg(v, 101, 1000, 1, 0,"")
                    setplaydef(v, "N$上次坐标x", 0)
                    setplaydef(v, "N$上次坐标y", 0)
                end
                sendmovemsg("0", 1, 254, 0, 300, 1,"活动：活动《土城跑酷》已开启奖励丰厚,请尽快参加活动...")
                sendmovemsg("0", 1, 254, 0, 270, 1,"活动：活动《土城跑酷》已开启奖励丰厚,请尽快参加活动...")
                sendmovemsg("0", 1, 254, 0, 240, 1,"活动：活动《土城跑酷》已开启奖励丰厚,请尽快参加活动...")
                local player_list = getplayerlst()
                for i, player  in ipairs(player_list or {}) do
                    sendluamsg(player,101,12,1,5,'{"sk":'..3 ..',"kf":'..2 ..',"idx":'..5 ..'}')
                end
            elseif dqfz == 8 then
                setenvirofftimer("xtc",1)
                local t = getplayerlst()
                for _, v in pairs(t) do
                    sendluamsg(v, 101, 1000, 2, 0,"")
                    sendluamsg(v, 101, 12, 4, 5,"")
                    setplaydef(v, "N$上次坐标x", 0)
                    setplaydef(v, "N$上次坐标y", 0)
                end
                sendmovemsg("0", 1, 254, 0, 300, 1,"活动：活动《土城跑酷》已关闭...")
                sendmovemsg("0", 1, 254, 0, 270, 1,"活动：活动《土城跑酷》已关闭...")
            end
            if dqfz == 15 then
                sendmovemsg("0", 1, 254, 0, 300, 1,"活动：活动《随机夺宝》已开启奖励丰厚,请尽快参加活动...")
                sendmovemsg("0", 1, 254, 0, 270, 1,"活动：活动《随机夺宝》已开启奖励丰厚,请尽快参加活动...")
                sendmovemsg("0", 1, 254, 0, 240, 1,"活动：活动《随机夺宝》已开启奖励丰厚,请尽快参加活动...")
                local sjdbCfg = _sjdb_get_cfg()
                local sjdbKeepMin = math.max(1, math.floor((((sjdbCfg and sjdbCfg.keep_sec) or 180) + 59) / 60))
                local player_list = getplayerlst()
                for i, player  in ipairs(player_list or {}) do
                    sendluamsg(player,101,1,13,0,"")
                    sendluamsg(player,101,12,1,13,'{"sk":' .. sjdbKeepMin .. ',"kf":2,"idx":13}')
                end
                local ok = _sjdb_throw_by_cfg(sjdbCfg)
                if not ok then
                    _sjdb_throw_fallback()
                end
            end
            local qmdtCfg = _qmdt_get_cfg()
            if qmdtCfg then
                if dqfz == qmdtCfg.start_minute then
                    _qmdt_start(dqfz, qmdtCfg)
                elseif getsysvar(VarCfg["G_全民答题状态"]) == 1 then
                    _qmdt_tick(dqfz, qmdtCfg)
                end
            end
            if dqfz == 25 then
                setenvirontimer(_WLMZ_MAP_NAME,2,10,"@hd_tcppk,".._WLMZ_MAP_NAME)
                sendmovemsg("0", 1, 254, 0, 300, 1,"活动：活动《".._WLMZ_EVENT_NAME.."》已开启奖励丰厚,请尽快参加活动...")
                sendmovemsg("0", 1, 254, 0, 270, 1,"活动：活动《".._WLMZ_EVENT_NAME.."》已开启奖励丰厚,请尽快参加活动...")
                local player_list = getplayerlst()
                for i, player  in ipairs(player_list or {}) do
                    sendluamsg(player,101,12,1,9,'{"sk":'..5 ..',"kf":'..2 ..',"idx":'..9 ..'}')
                end
            elseif dqfz == 30 then
                setenvirofftimer(_WLMZ_MAP_NAME,2)
                local wanjia = getobjectinmap(_WLMZ_MAP_NAME,25,29,65,1)
                for k, v in pairs(wanjia) do
                    local hsmy_px = sorthumvar(_WLMZ_SCORE_VAR,1,1,5)
                    local grjf = _safe_getplayvar_num(v, "HUMAN", _WLMZ_SCORE_VAR)
                    sendluamsg(v,101,498,1,0,'{"pmsj":'..tbl2json(hsmy_px)..',"grjf":'..grjf..'}')
                end
                local hsmy_px = sorthumvar(_WLMZ_SCORE_VAR,1,1,3)
                local index = 0
                for i = 1, #hsmy_px, 2 do
                    index = index + 1
                    if hsmy_px[i+1] and hsmy_px[i+1] > 0 then
                        setflagstatus(getplayerbyname(hsmy_px[i]),VarCfg.BS_tyrc,1)
                        sendmail("#"..hsmy_px[i],0,_WLMZ_EVENT_NAME,"恭喜你获得".._WLMZ_EVENT_NAME.."第["..constant.pz_hanzi[index].."]名,奖励已下发!",Player.jl_mail(constant.pz_wlmz[index]))
                        if i == 1 then
                            sendmovemsg("0", 1, 254, 0, 300, 1,"活动：活动《".._WLMZ_EVENT_NAME.."》已关闭,本次活动第一名为【"..hsmy_px[i].."】...")
                            sendmovemsg("0", 1, 254, 0, 270, 1,"活动：活动《".._WLMZ_EVENT_NAME.."》已关闭,本次活动第一名为【"..hsmy_px[i].."】...")
                            Player.title_give(getplayerbyname(hsmy_px[i]), "武林盟主")
                        end
                    end
                end
                local player_list = getplayerlst()
                for i, player  in ipairs(player_list or {}) do
                    if getflagstatus(player,VarCfg.BS_tyrc) == 0 then
                        if _safe_getplayvar_num(player, "HUMAN", _WLMZ_SCORE_VAR) > 0 then
                            setflagstatus(player,VarCfg.BS_tyrc,1)
                            sendmail(getbaseinfo(player,2),0,_WLMZ_EVENT_NAME,"恭喜你获得".._WLMZ_EVENT_NAME.."安慰奖,奖励已下发!","恭喜你获得,奖励已下发!",Player.jl_mail(constant.pz_wlmz[4]))
                        end
                    end
                end
            end
        end
        local mskhCfg = _mskh_get_cfg()
        if mskhCfg then
            _mskh_tick(dqfz, mskhCfg)
        end
        local qmdkCfg = _qmdk_get_cfg()
        if qmdkCfg then
            _qmdk_tick(dqfz, qmdkCfg)
        end
        local hdjdCfg = _hdjd_get_cfg()
        if hdjdCfg then
            _hdjd_tick(dqfz, hdjdCfg)
        end
        local bwczCfg = _bwcz_get_cfg()
        if bwczCfg then
            _bwcz_tick(dqfz, bwczCfg)
        end
    end
end
--跨服攻沙同步数据
function ontimerex2()
    GameEvent.push(EventCfg.goKFGongShaSync)
end
------------------------------------个人定时器begin---------------------------------
-----------------个人1号3秒定时器----------------一直开启
function ontimer1(play)
    --------------------------------------------------回收脚本
    if getbagblank(play) < 20 then -- 回收脚本
        Player.huishou(play)
    end
end
--攻沙个人定时器
function ontimer2(actor)
    GameEvent.push(EventCfg.gocastlewaring, actor)
end
-----------------个人4号定时器----------------60秒定时器
function ontimer4(play)
    local zxsj = getplaydef(play, VarCfg.U_fldt[1])
    setplaydef(play, VarCfg.U_fldt[1], zxsj + 1)
    setplaydef(play, VarCfg.J_zxsj,getplaydef(play, VarCfg.J_zxsj) + 1)
    local midExpire = tonumber(getplaydef(play, "N$xf_dan_mid_expire") or 0) or 0
    if midExpire > 0 and midExpire <= os.time() then
        setplaydef(play, "N$xf_dan_mid_expire", 0)
        Player.del_attlist(play, "仙府幸运丹")
    end
    local petNpc = Npclib and Npclib[64]
    if petNpc and type(petNpc.checkBabyHatch) == "function" then
        petNpc.checkBabyHatch(play, 60, false)
    end
end
-----------------个人5号定时器----------------1秒定时器AI挂机开启
function ontimer5(play)
end
-----------------个人6号定时器---------------红点系统--60s
function ontimer6(play)
    -- release_print("红点系统")
    -- 红点发送：客户端 npc[500] p2=10，p3 对应顶部 iconpx 槽位
    local function _send_top_red(icon_idx)
        sendluamsg(play, 101, 1, 10, icon_idx, "")
    end
    local function _is_marked(v)
        return v == true or (tonumber(v or 0) or 0) >= 1
    end
    local function _count_marked(tbl)
        local num = 0
        for _, v in pairs(tbl or {}) do
            if _is_marked(v) then
                num = num + 1
            end
        end
        return num
    end
    -- 首充礼包（p3=5）可领取判定
    local can_sc = false
    local sc_cfg = teshudata["anniu_501"] or {}
    local sc_data = Player.getJsonTableByVar(play, VarCfg["T_首冲礼包"]) or {}
    if tonumber(sc_data["ok"] or 0) == 1 then
        if tonumber(sc_data["首充"] or 0) == 1 then
            local day_list = (sc_cfg.details and sc_cfg.details["首充"]) or {}
            local max_day = #day_list
            if max_day > 0 then
                local claimed = tonumber(sc_data["other_lb"] or 0) or 0
                local next_idx = claimed + 1
                if next_idx <= max_day and Player.dl_sz_notip(play, next_idx) then
                    can_sc = true
                end
            end
        end
    end
    -- 福利大厅（p3=2）可领取判定：七日登录/在线/杀怪/首杀首爆任一可领则亮
    local can_fldt = false
    local fldt = teshudata["fldt"] or {}
    local fldt_data = Player.getJsonTableByVar(play, VarCfg.T_qrbq) or {}
    local login_days = tonumber(getplaydef(play, VarCfg["U_登录天数"]) or 0) or 0
    local kill_num = (tonumber(getplaydef(play, VarCfg.J_jsgw[1]) or 0) or 0) + (tonumber(getplaydef(play, VarCfg.J_jsgw[2]) or 0) or 0)
    local claimed_day = tonumber(fldt_data["7rqd"] or 0) or 0
    local next_day = claimed_day + 1
    if next_day <= 7 and next_day <= login_days then
        can_fldt = true
    end
    if not can_fldt then
        -- 福利大厅红点和 npc[511] 的领取条件保持一致：
        -- 首爆归属人可领；328 档位玩家即使不是首爆归属也可领一次。
        local zx_cfg = fldt["zxjl"] or {}
        local zx_claimed = tonumber(fldt_data["zxjl"] or 0) or 0
        local zx_next = zx_claimed + 1
        if zx_cfg[zx_next] and (tonumber(getplaydef(play, VarCfg.J_zxsj) or 0) or 0) >= (tonumber(zx_cfg[zx_next].time or 999999999) or 999999999) then
            can_fldt = true
        end
    end
    if not can_fldt then
        local sg_cfg = fldt["sgjl"] or {}
        local sg_claimed = tonumber(fldt_data["sgjl"] or 0) or 0
        local sg_next = sg_claimed + 1
        if sg_cfg[sg_next] and kill_num >= (tonumber(sg_cfg[sg_next].num or 999999999) or 999999999) then
            can_fldt = true
        end
    end
    if not can_fldt then
        local t_grss = Player.getJsonTableByVar(play, VarCfg.T_grss) or {}
        for _, st in pairs(t_grss) do
            if tonumber(st or 0) == 1 then
                can_fldt = true
                break
            end
        end
    end
    if not can_fldt then
        local t_grsb = Player.getJsonTableByVar(play, VarCfg.T_grsb) or {}
        for _, st in pairs(t_grsb) do
            if tonumber(st or 0) == 1 then
                can_fldt = true
                break
            end
        end
    end
    if not can_fldt then
        local qqsb = Player.getJsonTableByVar(nil, VarCfg["A_全区首曝json"]) or {}
        local fldt_self = Player.getJsonTableByVar(play, VarCfg.T_qrbq) or {}
        local qqsb_claim = type(fldt_self["qqsb_claim"]) == "table" and fldt_self["qqsb_claim"] or {}
        local grqqsb = Player.getJsonTableByVar(play, VarCfg.T_grqqsb) or {}
        local czlb = json2tbl(getplaydef(play, VarCfg.T_czlb))
        if type(czlb) ~= "table" then
            czlb = {}
        end
        local has_qqsb_privilege = tonumber(czlb["cz502_328"] or 0) == 1
        local player_name = tostring(getbaseinfo(play, 1) or "")
        local reward_cfg = (teshudata["fldt"] and teshudata["fldt"]["qqsb"]) or {}
        for idx in pairs(reward_cfg) do
            local key = tostring(idx)
            local global_owner = qqsb[key]
            if global_owner == nil then
                global_owner = qqsb[idx]
            end
            if global_owner ~= nil and tonumber(qqsb_claim[key] or qqsb_claim[idx] or 0) ~= 1 then
                local personal_ok = grqqsb[key]
                if personal_ok == nil then
                    personal_ok = grqqsb[idx]
                end
                local is_first_owner = type(global_owner) == "string" and global_owner == player_name
                if is_first_owner or (has_qqsb_privilege and tonumber(personal_ok or 0) == 1) then
                    can_fldt = true
                    break
                end
            end
        end
    end
    local can_zz = false
    local zz_data = Player.getJsonTableByVar(play, VarCfg["T_免费赞助"]) or {}
    local zz_cfg = (teshudata["anniu_516"] and teshudata["anniu_516"].details) or {}
    local zz_charge = math.max(tonumber(querymoney(play, 23) or 0) or 0, tonumber(getplaydef(play, VarCfg["U_真实充值"]) or 0) or 0)
    for i = 1, #zz_cfg do
        local cur_key = "zzlb_" .. i
        local pre_key = "zzlb_" .. (i - 1)
        local cur_claimed = tonumber(zz_data[cur_key] or 0) == 1
        local pre_ok = (i == 1) or (tonumber(zz_data[pre_key] or 0) == 1)
        local need_cz502 = tonumber(zz_cfg[i].need_cz502 or 0) or 0
        local can_charge = false
        if need_cz502 > 0 then
            local czlb = json2tbl(getplaydef(play, VarCfg.T_czlb))
            if type(czlb) ~= "table" then
                czlb = {}
            end
            can_charge = tonumber(czlb["cz502_" .. need_cz502] or 0) == 1
        else
            local need_charge = tonumber(zz_cfg[i].need_charge or zz_cfg[i].sgsl or 0) or 0
            local need_money23 = tonumber(zz_cfg[i].need_money23 or 0) or 0
            can_charge = (need_money23 > 0 and (tonumber(querymoney(play, 23) or 0) or 0) >= need_money23) or (need_money23 <= 0 and zz_charge >= need_charge)
        end
        if (not cur_claimed) and pre_ok and can_charge then
            can_zz = true
            break
        end
    end
    local can_jbp = false
    local jbp_cfg = teshudata["npc_106"] or {}
    local jbp_state = Player.getJsonTableByVar(play, VarCfg["T_聚宝盆"]) or {}
    local jbp_need = tonumber(jbp_cfg.fragment_count or 20) or 20
    local jbp_item = tostring(jbp_cfg.fragment_item or "聚宝盆碎片")
    if (tonumber(jbp_state.rebuilt or 0) or 0) < 1 and getbagitemcount(play, jbp_item) >= jbp_need then
        can_jbp = true
    end
    -- 仙途奇缘顶部红点：存在任一里程碑奖励可领取时点亮。
    local can_ff = false
    local ff_state = Player.getJsonTableByVar(play, "T40") or {}
    ff_state.done = type(ff_state.done) == "table" and ff_state.done or {}
    ff_state.milestone_claim = type(ff_state.milestone_claim) == "table" and ff_state.milestone_claim or {}
    local ff_done_count = _count_marked(ff_state.done)
    for _, milestone in ipairs((_fairy_fate_red_cfg and _fairy_fate_red_cfg.milestones) or {}) do
        local need_count = tonumber(milestone.count or 0) or 0
        if need_count > 0 and ff_done_count >= need_count then
            local claimed = ff_state.milestone_claim[tostring(need_count)]
            if claimed == nil then
                claimed = ff_state.milestone_claim[need_count]
            end
            if not _is_marked(claimed) then
                can_ff = true
                break
            end
        end
    end
    -- 马上发财顶部红点：免费兑换、里程碑奖励或日卡奖励可领取时点亮。
    local can_msfc = false
    local msfc_cfg = teshudata["npc_101"] or {}
    local msfc_data = Player.getJsonTableByVar(play, "T59") or {}
    msfc_data.claim_normal = type(msfc_data.claim_normal) == "table" and msfc_data.claim_normal or {}
    msfc_data.claim_crown = type(msfc_data.claim_crown) == "table" and msfc_data.claim_crown or {}
    local total_kills = (tonumber(getplaydef(play, VarCfg.J_jsgw[1]) or 0) or 0) + (tonumber(getplaydef(play, VarCfg.J_jsgw[2]) or 0) or 0)
    local kill_per_exchange = tonumber(msfc_cfg.kill_per_exchange or 188) or 188
    local exchange_daily_limit = tonumber(msfc_cfg.exchange_daily_limit or 50) or 50
    local exchange_used = tonumber(msfc_data.exchange_used or 0) or 0
    if tostring(msfc_data.exchange_date or "") ~= os.date("%Y%m%d") then
        exchange_used = 0
    end
    if kill_per_exchange > 0 then
        local max_can_exchange = math.floor(total_kills / kill_per_exchange)
        if exchange_used > exchange_daily_limit then
            exchange_used = exchange_daily_limit
        end
        if exchange_used > max_can_exchange then
            exchange_used = max_can_exchange
        end
        if math.max(0, math.min(exchange_daily_limit - exchange_used, max_can_exchange - exchange_used)) > 0 then
            can_msfc = true
        end
    end
    if not can_msfc then
        local draw_count = tonumber(msfc_data.draw_count or 0) or 0
        local has_crown = (tonumber(querymoney(play, 23) or 0) or 0) >= (tonumber(msfc_cfg.crown_cost or 0) or 0)
        if not has_crown then
            has_crown = checktitle(play, tostring(msfc_cfg.crown_title or "??"))
        end
        for idx, milestone in ipairs(msfc_cfg.milestones or {}) do
            local need_draw = tonumber(milestone.draw or 0) or 0
            if need_draw > 0 and draw_count >= need_draw then
                if not _is_marked(msfc_data.claim_normal[tostring(idx)]) then
                    can_msfc = true
                    break
                end
                if has_crown and not _is_marked(msfc_data.claim_crown[tostring(idx)]) then
                    can_msfc = true
                    break
                end
            end
        end
    end
    if not can_msfc then
        local day_card_cfg = msfc_cfg.day_card or {}
        local need_charge = tonumber(day_card_cfg.need_charge or 28) or 28
        local claimed_today = tostring(msfc_data.day_card_claim_date or "") == os.date("%Y%m%d")
        local today_charge = tonumber(getplaydef(play, VarCfg.J_zscz) or 0) or 0
        if (not claimed_today) and today_charge >= need_charge then
            can_msfc = true
        end
    end
    if can_fldt then
        _send_top_red(2)
    end
    if can_sc then
        _send_top_red(5)
    end
    if can_ff then
        _send_top_red(515)
    end
    if can_zz then
        _send_top_red(16)
    end
    if can_jbp then
        _send_top_red(17)
    end
    if can_msfc then
        _send_top_red(31)
    end
end
-----------------定时器----------------清空除魔  每天五点
function ql_smmrrw()
end
-----------------个人10号定时器----------------假人用-流程
function ontimer10(play)
    local dqlc = getplaydef(play,"N$当前流程")
    if dqlc == 0 then
        setplaydef(play,"N$当前流程",1)
        mapmove(play,"xtc",137,138,5)
    end
end
-----------------个人7号定时器---------------砍树--60min
function ontimer7(play)
    -- release_print("砍树系统")
    -- release_print(os.time())
    -- release_print(getplaydef(play,"N$自动砍树") + 59)
    if os.time() < getplaydef(play,"N$自动砍树") + 60*20-1 then
        return
    end
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_砍树系统"])
    local config = teshudata["anniu_30"]
    T_data.axe = T_data.axe or 1
    T_data.auto = T_data.auto or 0
    if not (T_data.auto > 0) then
        return
    end
    local jl = {}
    for i = 1,(60*20)/(config.updata[1].details[T_data.axe].ratio * config.updata[2].details[T_data.auto].ratio * config.base_time) do
        table.insert(jl, {ransjstr(config.updata[1].details[T_data.axe].jl, 1, 3),1})
    end
    -- 对 jl 处理 v[1] 相同的合并 增加v[2]
    local merged_jl = {}
    for _, v in ipairs(jl) do
        local found = false
        for _, mj in ipairs(merged_jl) do
            if mj[1] == v[1] then
                mj[2] = mj[2] + v[2]
                found = true
                break
            end
        end
        if not found then
            table.insert(merged_jl, {v[1], v[2]})
        end
    end
    T_data.num = (T_data.num or 0) + 60/config.updata[1].details[T_data.axe].ratio * config.updata[2].details[T_data.auto].ratio * config.base_time
    Player.setJsonVarByTable(play, VarCfg["T_砍树系统"], T_data)
    -- release_print("砍树系统奖励:",tbl2json(merged_jl))
    setplaydef(play,"N$自动砍树",os.time())
    sendmail(getbaseinfo(play,2),0,"砍树奖励","每20分钟砍树奖励",Player.jl_mail(merged_jl))
end
------------------------------------个人定时器end---------------------------------
-----------------地图定时器----------------
function hd_tcppk(xx,ditu)
    if ditu == "xtc" then
        local wanjia = getobjectinmap("xtc",137,138,20,1)
        for k, v in pairs(wanjia) do
            if math.random(2) == 1 then
                local x, y = getbaseinfo(v, 4), getbaseinfo(v, 5)
                if getplaydef(v, "N$上次坐标x") ~= x and getplaydef(v, "N$上次坐标y") ~= y then
                    setplaydef(v, "N$上次坐标x", x)
                    setplaydef(v, "N$上次坐标y", y)
                    local wpmz = _tcppk_pick_reward(v)
                    if wpmz and wpmz ~= "" then
                        sendmsg(v,1,'{"Msg":"<font color=\'#ff7700\'>[土城跑酷]</font><font color=\'#00ff00\'>恭喜你获得了['..wpmz..']...</font>","Type":9}')
                        sendmsg(v, 2, '{"BColor":249,"FColor":255,"Msg":"[土城跑酷]<font color=\'#00ff00\'>恭喜'..getbaseinfo(v, 1)..'获得了['..wpmz..']...</font>","Type":1}')
                        giveitem(v, wpmz,1,getflagstatus(v,VarCfg.BS_mztq) == 0 and 0 or 850)
                    end
                end
            end
        end
    elseif getsysvar(VarCfg["G_全民答题状态"]) == 1 and _qmdt_is_timer_map(ditu) then
        local qmdtCfg = _qmdt_get_cfg()
        local qmdtState = _qmdt_get_state()
        _qmdt_tick_runtime(qmdtCfg, qmdtState)
    elseif getsysvar(VarCfg["G_全民夺矿状态"]) == 1 then
        local qmdkCfg = _qmdk_get_cfg()
        local qmdkState = _qmdk_get_state()
        local qmdkMap = (qmdkState.map and qmdkState.map ~= "") and qmdkState.map or (qmdkCfg and qmdkCfg.map)
        if qmdkCfg and qmdkMap == ditu then
            qmdkState = _qmdk_tick_runtime(qmdkCfg, qmdkState)
            local wanjia = getobjectinmap(qmdkMap, 0, 0, 999, 1)
            for _, v in pairs(wanjia or {}) do
                _qmdk_tick_player(v, qmdkCfg, qmdkState)
            end
        end
    elseif getsysvar(VarCfg["G_黑暗禁地状态"]) == 1 then
        local hdjdCfg = _hdjd_get_cfg()
        local hdjdState = _hdjd_get_state()
        local hdjdMap = (hdjdState.map and hdjdState.map ~= "") and hdjdState.map or (hdjdCfg and hdjdCfg.map)
        if hdjdCfg and hdjdMap == ditu then
            _hdjd_tick_runtime(hdjdCfg, hdjdState)
            local wanjia = getobjectinmap(hdjdMap, 0, 0, 999, 1)
            for _, v in pairs(wanjia or {}) do
                _hdjd_refresh_actor(v)
            end
        end
    elseif ditu == "正邪大战" then
        if zxdz_map_tick then zxdz_map_tick() end
    elseif ditu == _WLMZ_MAP_NAME then
        local wanjia = getobjectinmap(_WLMZ_MAP_NAME,25,29,65,1)
        for k, v in pairs(wanjia) do
            local jf = _safe_getplayvar_num(v, "HUMAN", _WLMZ_SCORE_VAR) + 1
            setplayvar(v, "HUMAN", _WLMZ_SCORE_VAR, jf, 1)
            local hsmy_px = sorthumvar(_WLMZ_SCORE_VAR,1,1,5)
            sendluamsg(v,101,498,1,0,'{"pmsj":'..tbl2json(hsmy_px)..',"grjf":'..jf..'}')
        end
    end
end

