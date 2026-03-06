--全局定时器

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
    cfg.duration_min = tonumber(cfg.duration_min) or 5
    cfg.question_count = math.min(tonumber(cfg.question_count) or 5, #cfg.questions)
    cfg.per_question_sec = tonumber(cfg.per_question_sec) or 60
    return cfg
end

-- 读取全民答题运行态
local function _qmdt_get_state()
    local raw = getsysvar(VarCfg["A_全民答题json"])
    if raw == "" then
        return {}
    end
    local tb = json2tbl(raw)
    return type(tb) == "table" and tb or {}
end

-- 保存全民答题运行态
local function _qmdt_save_state(state)
    setsysvar(VarCfg["A_全民答题json"], tbl2json(state or {}))
end

-- 推送题目到所有在线玩家（客户端答题提交走 npc[507]）
local function _qmdt_push_question(state, cfg, qidx)
    local q = cfg.questions[qidx]
    if not q then
        return false
    end
    state.current_idx = qidx
    _qmdt_save_state(state)
    local payload = {
        open = 1,
        idx = qidx,
        total = cfg.question_count,
        title = q.title,
        options = q.options or {},
        limit_sec = cfg.per_question_sec,
    }
    for _, player in ipairs(getplayerlst() or {}) do
        sendluamsg(player, 101, 507, 2, 1, tbl2json(payload))
    end
    sendmovemsg("0", 1, 254, 0, 300, 1, "活动：全民答题第" .. tostring(qidx) .. "题已发布，请在活动面板作答...")
    return true
end

-- 开启全民答题
local function _qmdt_start(dqfz, cfg)
    local state = {
        open = 1,
        start_minute = dqfz,
        current_idx = 0,
        players = {},
    }
    setsysvar(VarCfg["G_全民答题状态"], 1)
    _qmdt_save_state(state)
    sendmovemsg("0", 1, 254, 0, 300, 1, "活动：活动《全民答题》已开启，请通过活动面板参与答题...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "活动：活动《全民答题》已开启，请通过活动面板参与答题...")
    _qmdt_push_question(state, cfg, 1)
end

-- 结算全民答题奖励（名次奖励 + 参与奖励）
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

    local payload = {open = 0, rank = rankData}
    for _, player in ipairs(getplayerlst() or {}) do
        sendluamsg(player, 101, 507, 2, 3, tbl2json(payload))
    end
end

-- 全民答题分钟驱动（每分钟推进到下一题）
local function _qmdt_tick(dqfz, cfg)
    if getsysvar(VarCfg["G_全民答题状态"]) ~= 1 then
        return
    end
    local state = _qmdt_get_state()
    if tonumber(state.open) ~= 1 then
        return
    end
    local startMinute = tonumber(state.start_minute) or dqfz
    local elapsed = dqfz - startMinute
    if elapsed >= cfg.duration_min then
        _qmdt_finish(cfg)
        return
    end
    local shouldIdx = math.min(cfg.question_count, elapsed + 1)
    local currentIdx = tonumber(state.current_idx) or 0
    if shouldIdx > currentIdx then
        _qmdt_push_question(state, cfg, shouldIdx)
    end
end


-- 获取全民夺矿配置（单源：teshudata.anniu_507.qmdk）
local function _qmdk_get_cfg()
    local cfg = teshudata and teshudata["anniu_507"] and teshudata["anniu_507"].qmdk or nil
    if type(cfg) ~= "table" then
        return nil
    end
    if type(cfg.map) ~= "string" or cfg.map == "" then
        return nil
    end
    cfg.start_minute = tonumber(cfg.start_minute) or 26
    cfg.duration_min = tonumber(cfg.duration_min) or 8
    cfg.score_tick_sec = tonumber(cfg.score_tick_sec) or 10
    cfg.score_per_tick = tonumber(cfg.score_per_tick) or 1
    cfg.score_var_prefix = cfg.score_var_prefix or "全民夺矿"
    cfg.panel_idx = tonumber(cfg.panel_idx) or 3
    return cfg
end

-- 读取全民夺矿运行态
local function _qmdk_get_state()
    local raw = getsysvar(VarCfg["A_全民夺矿json"])
    if raw == "" then
        return {}
    end
    local tb = json2tbl(raw)
    return type(tb) == "table" and tb or {}
end

-- 保存全民夺矿运行态
local function _qmdk_save_state(state)
    setsysvar(VarCfg["A_全民夺矿json"], tbl2json(state or {}))
end

-- 根据配置和运行态计算当前积分变量名（按天隔离）
local function _qmdk_get_score_var(cfg, state)
    if state and type(state.score_var) == "string" and state.score_var ~= "" then
        return state.score_var
    end
    local prefix = (cfg and cfg.score_var_prefix) or "全民夺矿"
    return prefix .. "_" .. os.date("%Y%m%d")
end

-- 开启全民夺矿活动
local function _qmdk_start(dqfz, cfg, fromBot)
    if getsysvar(VarCfg["G_全民夺矿状态"]) == 1 then
        return false
    end
    local state = {
        open = 1,
        start_minute = dqfz,
        map = cfg.map,
        score_var = _qmdk_get_score_var(cfg, nil),
        from_bot = fromBot and 1 or 0,
    }
    setsysvar(VarCfg["G_全民夺矿状态"], 1)
    _qmdk_save_state(state)

    setenvirontimer(cfg.map, 3, cfg.score_tick_sec, "@hd_tcppk," .. cfg.map)
    sendmovemsg("0", 1, 254, 0, 300, 1, "活动：活动《全民夺矿》已开启，请尽快前往矿区争夺积分...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "活动：活动《全民夺矿》已开启，请尽快前往矿区争夺积分...")

    local player_list = getplayerlst()
    for _, player in ipairs(player_list or {}) do
        sendluamsg(player, 101, 12, 1, cfg.panel_idx, '{"sk":' .. cfg.duration_min .. ',"kf":2,"idx":' .. cfg.panel_idx .. '}')
    end
    return true
end

-- 结束全民夺矿活动并发放奖励
local function _qmdk_finish(cfg, fromBot)
    if getsysvar(VarCfg["G_全民夺矿状态"]) ~= 1 then
        return false
    end
    local state = _qmdk_get_state()
    local mapName = (state.map and state.map ~= "") and state.map or cfg.map
    setenvirofftimer(mapName, 3)

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
            local score = tonumber(getplayvar(player, "HUMAN", scoreVar)) or 0
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
    return true
end

-- 全民夺矿分钟驱动（支持 bot 强制开始/结束）
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
                _txzr_broadcast_roll(djl, txzz_data["md" .. djl])
                txzz_data["notice"] = _txzr_get_notice_cfg()
                txzz_data["shenqi"] = _txzr_get_shenqi_cfg()
                setsysvar(VarCfg["A_天选之人json"], tbl2json(txzz_data))
            else
                setsysvar(VarCfg["G_天选之人"][1], txsj)
                if txsj == 27 then
                    sendmovemsg("0", 1, 253, 0, 300, 1,"天选之人：活动《天选之人》即将开启,请玩家做好准备...")
                    sendmovemsg("0", 1, 249, 0, 250, 1,"天选之人：活动《天选之人》即将开启,请玩家做好准备...")
                    local player_list = getplayerlst()
                    for i, player  in ipairs(player_list or {}) do
                        sendluamsg(player,101,1,13,0,"")
                    end
                end
            end

            if dqfz == 20 then
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
                    sendluamsg(player,101,12,1,5,'{"sk":'..3 ..',"kf":'..2 ..',"idx":'..1 ..'}')
                end
            elseif dqfz == 23 then
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
                local player_list = getplayerlst()
                for i, player  in ipairs(player_list or {}) do
                    sendluamsg(player,101,1,13,0,"")
                end
                local sjdbCfg = _sjdb_get_cfg()
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
            if dqfz == 40 then
                setenvirontimer(_WLMZ_MAP_NAME,2,10,"@hd_tcppk,".._WLMZ_MAP_NAME)
                sendmovemsg("0", 1, 254, 0, 300, 1,"活动：活动《".._WLMZ_EVENT_NAME.."》已开启奖励丰厚,请尽快参加活动...")
                sendmovemsg("0", 1, 254, 0, 270, 1,"活动：活动《".._WLMZ_EVENT_NAME.."》已开启奖励丰厚,请尽快参加活动...")
                local player_list = getplayerlst()
                for i, player  in ipairs(player_list or {}) do
                    sendluamsg(player,101,12,1,2,'{"sk":'..10 ..',"kf":'..2 ..',"idx":'..2 ..'}')
                end
            elseif dqfz == 50 then
                setenvirofftimer(_WLMZ_MAP_NAME,2)
                local wanjia = getobjectinmap(_WLMZ_MAP_NAME,25,29,65,1)
                for k, v in pairs(wanjia) do
                    local hsmy_px = sorthumvar(_WLMZ_SCORE_VAR,1,1,5)
                    sendluamsg(v,101,498,1,0,'{"pmsj":'..tbl2json(hsmy_px)..',"grjf":'..getplayvar(v, "HUMAN", _WLMZ_SCORE_VAR)..'}')
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
                        if getplayvar(player, "HUMAN", _WLMZ_SCORE_VAR) > 0 then
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
    release_print("红点系统")

    -- 红点发送：客户端 npc[500] p2=10，p3 对应顶部 iconpx 槽位
    local function _send_top_red(icon_idx)
        sendluamsg(play, 101, 1, 10, icon_idx, "")
    end

    -- 首充礼包（p3=5）可领取判定
    local can_sc = false
    local sc_cfg = teshudata["anniu_501"] or {}
    local sc_data = Player.getJsonTableByVar(play, VarCfg["T_首冲礼包"]) or {}
    local open_day = tonumber(getsysvar(VarCfg["G_开区天数"]) or 0) or 0
    if tonumber(sc_data["ok"] or 0) == 1 then
        local endtime = tonumber(sc_cfg.endtime or 0) or 0
        if tonumber(sc_data["首充"] or 0) == 1 and open_day <= endtime then
            local day_list = (sc_cfg.details and sc_cfg.details["首充"]) or {}
            local max_day = #day_list
            if max_day > 0 then
                local buy_day = tonumber(sc_data["buy_day"] or open_day) or open_day
                local idx = (open_day - buy_day) + 1
                if idx < 1 then
                    idx = 1
                end
                if idx <= max_day and tonumber(sc_data["jq_time"] or 0) ~= open_day then
                    can_sc = true
                end
            end
        elseif tonumber(sc_data["补充"] or 0) == 1 and open_day > endtime then
            local extra_list = (sc_cfg.details and sc_cfg.details["补充"]) or {}
            if #extra_list > 0 and tonumber(sc_data["bc_ok"] or 0) ~= 1 then
                can_sc = true
            end
        end
    end

    -- 福利大厅（p3=2）可领取判定：七日登录/在线/杀怪/首杀首爆任一可领则亮
    local can_fldt = false
    local fldt = teshudata["fldt"] or {}
    local fldt_data = Player.getJsonTableByVar(play, VarCfg.T_qrbq) or {}
    local login_days = tonumber(getplaydef(play, VarCfg["U_登录天数"]) or 0) or 0
    local online_min = tonumber(getplaydef(play, VarCfg.J_zxsj) or 0) or 0
    local kill_num = (tonumber(getplaydef(play, VarCfg.J_jsgw[1]) or 0) or 0) + (tonumber(getplaydef(play, VarCfg.J_jsgw[2]) or 0) or 0)
    local fldt_cfg = (fldt.fldt_cfg and fldt.fldt_cfg.seven_login) or {}
    local online_limit = tonumber(fldt_cfg.online_limit or 10) or 10

    local claimed_day = tonumber(fldt_data["7rqd"] or 0) or 0
    local next_day = claimed_day + 1
    if next_day <= 7 and next_day <= login_days and online_min >= online_limit then
        can_fldt = true
    end
    if not can_fldt then
        local zx_cfg = fldt["zxjl"] or {}
        local zx_claimed = tonumber(fldt_data["zxjl"] or 0) or 0
        local zx_next = zx_claimed + 1
        if zx_cfg[zx_next] and online_min >= (tonumber(zx_cfg[zx_next].time or 999999999) or 999999999) then
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
        for _, st in pairs(qqsb) do
            if tonumber(st or 0) == 1 then
                can_fldt = true
                break
            end
        end
    end

    -- 免费赞助（p3=16）可领取判定：顺序礼包中存在“前置已领 + 当前未领 + 杀怪达标”
    local can_zz = false
    local zz_data = Player.getJsonTableByVar(play, VarCfg["T_免费赞助"]) or {}
    local zz_cfg = (teshudata["anniu_516"] and teshudata["anniu_516"].details) or {}
    local zz_kill = tonumber(getplaydef(play, VarCfg.U_fldt[2]) or 0) or 0
    for i = 1, #zz_cfg do
        local cur_key = "zzlb_" .. i
        local pre_key = "zzlb_" .. (i - 1)
        local cur_claimed = tonumber(zz_data[cur_key] or 0) == 1
        local pre_ok = (i == 1) or (tonumber(zz_data[pre_key] or 0) == 1)
        local need_kill = tonumber(zz_cfg[i].sgsl or 0) or 0
        if (not cur_claimed) and pre_ok and zz_kill >= need_kill then
            can_zz = true
            break
        end
    end

    -- 聚宝盆（p3=17）可领取判定：当前等级次数未满 + 积分达标
    local can_jbp = false
    local jbp_data = Player.getJsonTableByVar(play, VarCfg["T_聚宝盆"]) or {}
    local jbp_level = tonumber(jbp_data.level or 1) or 1
    local jbp_cfg_all = (teshudata["anniu_517"] and teshudata["anniu_517"].details) or {}
    local jbp_cfg = jbp_cfg_all[jbp_level]
    if jbp_cfg then
        local jbp_jf = tonumber(getplaydef(play, VarCfg["U_聚宝盆积分"]) or 0) or 0
        local jbp_cs = tonumber(getplaydef(play, VarCfg["J_聚宝盆领取次数"]) or 0) or 0
        local need_jf = tonumber(jbp_cfg.jf or 999999999) or 999999999
        local max_cs = tonumber(jbp_cfg.maxcs or 0) or 0
        if jbp_cs < max_cs and jbp_jf >= need_jf then
            can_jbp = true
        end
    end

    if can_fldt then
        _send_top_red(2)
    end
    if can_sc then
        _send_top_red(5)
    end
    if can_zz then
        _send_top_red(16)
    end
    if can_jbp then
        _send_top_red(17)
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
            local scoreVar = _qmdk_get_score_var(qmdkCfg, qmdkState)
            local addScore = tonumber(qmdkCfg.score_per_tick) or 1
            local wanjia = getobjectinmap(qmdkMap, 0, 0, 999, 1)
            for _, v in pairs(wanjia or {}) do
                local jf = (tonumber(getplayvar(v, "HUMAN", scoreVar)) or 0) + addScore
                setplayvar(v, "HUMAN", scoreVar, jf, 1)
            end
        end
    elseif ditu == _WLMZ_MAP_NAME then
        local wanjia = getobjectinmap(_WLMZ_MAP_NAME,25,29,65,1)
        for k, v in pairs(wanjia) do
            local jf = getplayvar(v, "HUMAN", _WLMZ_SCORE_VAR) + 1
            setplayvar(v, "HUMAN", _WLMZ_SCORE_VAR, jf, 1)
            local hsmy_px = sorthumvar(_WLMZ_SCORE_VAR,1,1,5)
            sendluamsg(v,101,498,1,0,'{"pmsj":'..tbl2json(hsmy_px)..',"grjf":'..getplayvar(v, "HUMAN", _WLMZ_SCORE_VAR)..'}')
        end

    end
end













