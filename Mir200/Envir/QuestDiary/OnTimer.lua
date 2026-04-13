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
    cfg.per_question_sec = tonumber(cfg.per_question_sec) or 120
    cfg.base_score = tonumber(cfg.base_score) or 100
    cfg.time_bonus_per_sec = tonumber(cfg.time_bonus_per_sec) or 1
    cfg.question_span_min = math.max(1, math.ceil(cfg.per_question_sec / 60))
    cfg.duration_min = math.max(tonumber(cfg.duration_min) or (cfg.question_count * cfg.question_span_min), cfg.question_count * cfg.question_span_min)
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
local function _qmdt_build_prompt(q, qidx, total)
    local lines = {"第" .. tostring(qidx) .. "/" .. tostring(total) .. "题：" .. tostring(q.title or "")}
    for i, one in ipairs(q.options or {}) do
        lines[#lines + 1] = tostring(i) .. "." .. tostring(one)
    end
    lines[#lines + 1] = "请输入答案序号或完整答案"
    return table.concat(lines, "\n")
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
        input_mode = 1,
        placeholder = "请输入答案序号或完整答案",
        limit_sec = remain,
        end_ts = tonumber(state.question_end_ts) or 0,
    }
end
local function _qmdt_push_question(state, cfg, qidx, dqfz)
    local q = cfg.questions[qidx]
    if not q then
        return false
    end
    state.current_idx = qidx
    state.question_start_minute = dqfz or tonumber(state.question_start_minute) or tonumber(state.start_minute) or getsysvar(VarCfg["G_开区分钟"])
    state.question_end_ts = os.time() + cfg.per_question_sec
    _qmdt_save_state(state)
    for _, player in ipairs(getplayerlst() or {}) do
        sendluamsg(player, 101, 12, 1, 3, '{"sk":2,"kf":2,"idx":3}')
    end
    sendmovemsg("0", 1, 254, 0, 300, 1, "活动：全民答题第" .. tostring(qidx) .. "题已发布，请点击活动面板输入答案...")
    return true
end
local function _qmdt_start(dqfz, cfg)
    local state = {
        open = 1,
        start_minute = dqfz,
        current_idx = 0,
        question_start_minute = dqfz,
        question_end_ts = 0,
        players = {},
    }
    setsysvar(VarCfg["G_全民答题状态"], 1)
    _qmdt_save_state(state)
    sendmovemsg("0", 1, 254, 0, 300, 1, "活动：活动《全民答题》已开启，请通过活动面板输入答案...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "活动：活动《全民答题》已开启，请通过活动面板输入答案...")
    _qmdt_push_question(state, cfg, 1, dqfz)
end
local function _qmdt_finish(cfg)
    if getsysvar(VarCfg["G_全民答题状态"]) ~= 1 then
        return
    end
    local state = _qmdt_get_state()
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
end
local function _qmdt_tick(dqfz, cfg)
    if getsysvar(VarCfg["G_全民答题状态"]) ~= 1 then
        return
    end
    local state = _qmdt_get_state()
    if tonumber(state.open) ~= 1 then
        return
    end
    local currentIdx = tonumber(state.current_idx) or 0
    if currentIdx <= 0 then
        _qmdt_push_question(state, cfg, 1, dqfz)
        return
    end
    local nowTs = os.time()
    local questionEndTs = tonumber(state.question_end_ts) or 0
    if questionEndTs > 0 then
        if nowTs < questionEndTs then
            return
        end
    else
        local questionStartMinute = tonumber(state.question_start_minute) or tonumber(state.start_minute) or dqfz
        if dqfz - questionStartMinute < cfg.question_span_min then
            return
        end
    end
    if currentIdx >= cfg.question_count then
        _qmdt_finish(cfg)
        return
    end
    _qmdt_push_question(state, cfg, currentIdx + 1, dqfz)
end
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
    Player.sendmsgEx(play, "成功运回一块矿石，积分+" .. cfg.deliver_score .. "#249")
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
    Player.sendmsgEx(play, "采集成功，运回矿石可获得" .. cfg.deliver_score .. "积分#249")
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
-- 武林盟主活动定义（单实体活动，地图与积分键统一管理）
local _QMDK_EVENT_NAME = "全民夺矿"
local _WLMZ_EVENT_NAME = "武林盟主"
local _WLMZ_MAP_NAME = "比武大会"
local _WLMZ_SCORE_VAR = "比武大会"
function ontimerex1()
    if getsysvar(VarCfg["G_新区验证"]) > 0 and not checkkuafuserver() then
        local dqfz = getsysvar(VarCfg["G_开区分钟"]) + 1
        setsysvar(VarCfg["G_开区分钟"], dqfz)
        if getsysvar(VarCfg["G_天选之人"][2]) < 4 then
            local txsj = getsysvar(VarCfg["G_天选之人"][1]) + 1
            if txsj >= 30 then--30分钟一轮
                setsysvar(VarCfg["G_天选之人"][1], 0)
                setsysvar(VarCfg["G_天选之人"][2], getsysvar(VarCfg["G_天选之人"][2]) + 1)
                local djl = getsysvar(VarCfg["G_天选之人"][2])
                local wjlb, lins = getplayerlst(), {}
                for i, v in pairs(wjlb or {}) do
                    local sc_data = Player.getJsonTableByVar(v, VarCfg["T_首冲礼包"])
                    local canJoin = sc_data and sc_data["ok"] == 1
                    if canJoin then
                        table.insert(lins, {getbaseinfo(v, 1), _txzr_get_roll_point(v, djl)})
                    end
                end
                local txzz_data = getsysvar(VarCfg["A_天选之人json"])
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
                    sendluamsg(v, 101, 12, 4, 3,"")
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
        local qmdkCfg = _qmdk_get_cfg()
        if qmdkCfg then
            _qmdk_tick(dqfz, qmdkCfg)
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
        local qqsb = Player.getJsonTableByVar(nil, VarCfg["A_????json"]) or {}
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
    local jbp_data = Player.getJsonTableByVar(play, "T44") or {}
    local jbp_level = tonumber(jbp_data.level or 1) or 1
    local jbp_cfg_all = (teshudata["anniu_517"] and teshudata["anniu_517"].details) or {}
    local jbp_cfg = jbp_cfg_all[jbp_level]
    if jbp_cfg then
        local jbp_jf = tonumber(getplaydef(play, "U42") or 0) or 0
        local jbp_cs = tonumber(getplaydef(play, "J22") or 0) or 0
        local need_jf = tonumber(jbp_cfg.jf or 999999999) or 999999999
        local max_cs = tonumber(jbp_cfg.maxcs or 0) or 0
        if jbp_cs < max_cs and jbp_jf >= need_jf then
            can_jbp = true
        end
    end
    -- FairyFate top red: any milestone reward can be claimed.
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
    -- MSFC top red: free exchange / milestone reward / day-card reward.
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
                    local wpmz = paokujl[math.random(#paokujl)]
                    sendmsg(v,1,'{"Msg":"<font color=\'#ff7700\'>[土城跑酷]</font><font color=\'#00ff00\'>恭喜你获得了['..wpmz..']...</font>","Type":9}')
                    sendmsg(v, 2, '{"BColor":249,"FColor":255,"Msg":"[土城跑酷]<font color=\'#00ff00\'>恭喜'..getbaseinfo(v, 1)..'获得了['..wpmz..']...</font>","Type":1}')
                    giveitem(v, wpmz,1,getflagstatus(v,VarCfg.BS_mztq) == 0 and 0 or 850)
                end
            end
        end
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
