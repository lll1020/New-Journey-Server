npc = {}
local function _ff9999_parse_reward(text) -- 9999测试：解析成就奖励中的物品/称号/修为
    local ret = {items = {}, title = "", realm_exp = 0}
    text = tostring(text or ""):gsub("固定生命、固定魔法%+(%d+)", "固定生命+%1、固定魔法+%1"):gsub("，", "、"):gsub(",", "、")
    for part in string.gmatch(text, "[^、]+") do
        part = tostring(part):gsub("^%s+", ""):gsub("%s+$", "")
        if part ~= "" then
            local itemName, itemNum = string.match(part, "^(.-)%*(%d+)$")
            if itemName and itemNum then
                ret.items[#ret.items + 1] = {itemName, tonumber(itemNum) or 0}
            elseif string.find(part, "^称号：") then
                ret.title = string.gsub(part, "^称号：", "")
            else
                local n = string.match(part, "^修为%+(%d+)$")
                if n then ret.realm_exp = tonumber(n) or 0 end
            end
        end
    end
    return ret
end
local function _ff9999_random_finish(play) -- 9999测试：随机完成一个未完成成就
    local cfg = include("lua/Data/fairy_fate_cfg.lua") or {}
    local state = Player.getJsonTableByVar(play, VarCfg["T_仙途奇缘"])
    state.done = type(state.done) == "table" and state.done or {}
    local pending = {}
    for _, detail in ipairs(cfg.details or {}) do
        if tonumber(state.done[tostring(detail.id)] or 0) < 1 then
            pending[#pending + 1] = detail
        end
    end
    if #pending <= 0 then
        Player.sendmsgEx(play, "已无未完成成就#57")
        return
    end
    local detail = pending[math.random(1, #pending)]
    local reward = _ff9999_parse_reward(detail.reward)
    state.done[tostring(detail.id)] = 1
    Player.setJsonVarByTable(play, VarCfg["T_仙途奇缘"], state)
    if #reward.items > 0 then Player.rwjl(play, reward.items, "9999成就测试", 1, 0) end
    if reward.title ~= "" then Player.title_give(play, reward.title) end
    if reward.realm_exp > 0 then
        setplaydef(play, VarCfg["U_境界修炼"][2], (tonumber(getplaydef(play, VarCfg["U_境界修炼"][2])) or 0) + reward.realm_exp)
    end
    if FairyFate and FairyFate.touch then FairyFate.touch(play, "title") end
    sendluamsg(play, 101, 515, 2, tonumber(detail.id) or 0, tbl2json({tp = "cjdc", id = detail.id, name = detail.name, tip = "达成成就[" .. tostring(detail.name or detail.id) .. "]"}))
    -- Player.sendmsgEx(play, "已随机完成|【" .. tostring(detail.name or detail.id) .. "】#249|成就")
end
local _admin_test_monsters = {
    -- "测试怪物名",
---灰界---
-- "枯沫伥",
-- "灰纹·潜噬者",
-- "霾息·巡界使",
-- "腐沼怪",
-- "南荒·狩影者",
-- "★南境荒王★",
-- "霜痕魅",
-- "北霜·裂牙者",
-- "≮北寒碎霜王≯",
-- "斑风怪",
-- "东纱·巡风者",
-- "「灰翼风痕主」",
-- "海骨魅",
-- "西潮·深潜者",
-- "★西海古皇★[道法合一]",
"---藏星海---",
"潮纹兽",
"星潮·逐星者",
"≮群星渊皇≯",
"海咬怪",
"外渊·巡海者",
"☆溟海咒皇☆[沉寂]",
"古藤魅",
"岛影·窥行者",
"★岛心梦主★[沉寂]",
"暮蝠",
"暗渊·裂壁者",
"≮黑洞魔皇≯",
"船咒灵",
"黑纱魅",
"「幽航鬼主」[通灵]",
"舱鼠",
"舱影·疾行者",
"≮水手怨皇≯[通灵]",
"静潮兽",
"溟光·摄海使",
"「玄溟古君」",
"七星鸦",
"星沙怪",
"七星·巡星者",
"★七星海皇★[至高神灵]",
"星痕魅",
"殁羽妖",
"葬城·殓灵者",
"≮葬星皇≯",
"砂潮怪",
"海咒兽",
"海滩·觅潮者",
"咒砂·潜灵将",
"「海殇巨皇」[至高神灵]",
"海盗头目",
-- "---苍云城--",
-- "城影客",
-- "红尘·夜巡者",
-- "「红幕法皇」[咆哮]",
-- "藤裂怪",
-- "荒镜魅",
-- "外郊·影渡者",
-- "雾裂·狩行将",
-- "≮红尘荒皇≯·赤虚[掌控]",
-- "「外廓冥君」",
-- "内街俑",
-- "红痕妖",
-- "内殿·巡禁者",
-- "☆红殿古皇☆命运之神",
-- "木偶俑",
-- "客栈·巡夜者",
-- "★红尘店主★",
-- "塔隙兽",
-- "石翼怪",
-- "通塔·巡禁者",
-- "≮通天塔主≯",
-- "「通天夜皇」",
-- "底隙怪",
-- "深基·巡守者",
-- "☆塔底冥皇☆·≮巨龙之魂≯",
-- "风痕妖",
-- "塔翼魅",
-- "塔巅·巡天者",
-- "★塔巅天皇★",
-- "「天极古君」[魔狱]",
-- "---草药谷---",
-- "灵草伥",
-- "藤骨怪",
-- "仙田·潜灵者",
-- "草纹·巡守使",
-- "☆仙草大妖☆",
-- "「田中药皇」[神话]",
-- "深藤魅",
-- "古谷·巡林者",
-- "★古谷药皇★",
-- "丹影兽",
-- "灰火怪",
-- "丹炉·巡执者",
-- "≮丹藏古皇≯[神话]",
-- "---三大陆boss---",
-- "被封印的愤怒·天劫",
-- "命运古神的低语[无上威严]",
-- "来自其他位面的强者",
-- "大天使安提罗科斯·命运之神",
-- "沉迷暗黑世界的神·魔神降临",


}

local function _admin_spawn_test_monsters(play)
    if type(_admin_test_monsters) ~= "table" or #_admin_test_monsters <= 0 then
        Player.sendmsgEx(play, "测试怪物列表为空#57")
        return
    end
    local mapName = tostring(getbaseinfo(play, 3) or "")
    local px = tonumber(getbaseinfo(play, 4) or 0) or 0
    local py = tonumber(getbaseinfo(play, 5) or 0) or 0
    if mapName == "" then
        Player.sendmsgEx(play, "当前地图异常#57")
        return
    end
    killmonsters(mapName, "*", 0, false)
    local spawned = 0
    for _, monName in ipairs(_admin_test_monsters) do
        if type(monName) == "string" and monName ~= "" then
            local dx = ((spawned % 8) - 3.5) * 3
            local dy = (math.floor(spawned / 8) - 3.5) * 3
            dx = math.floor(dx + 0.5)
            dy = math.floor(dy + 0.5)
            if dx == 0 and dy == 0 then
                dx = 6
            end
            genmonex(mapName, px + dx, py + dy, monName, 1, 1, 0, 254, "", 0)
            spawned = spawned + 1
        end
    end
    Player.sendmsgEx(play, "已清空当前地图怪物，并刷出|【" .. tostring(spawned) .. "】#249|只测试怪")
end
local function _admin_simple_activity_start(play, idx, name, minutes)
    idx = tonumber(idx) or 0
    minutes = tonumber(minutes) or 5
    local actName = tostring(name or "测试活动")
    sendmovemsg("0", 1, 254, 0, 300, 1, "活动：活动《" .. actName .. "》已开启奖励丰厚,请尽快参加活动...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "活动：活动《" .. actName .. "》已开启奖励丰厚,请尽快参加活动...")
    for _, playerObj in ipairs(getplayerlst() or {}) do
        sendluamsg(playerObj, 101, 12, 1, idx, '{"sk":' .. minutes .. ',"kf":2,"idx":' .. idx .. '}')
    end
    Player.sendmsgEx(play, actName .. "测试开始#249")
end

local function _admin_simple_activity_finish(play, idx, name)
    idx = tonumber(idx) or 0
    local actName = tostring(name or "测试活动")
    sendmovemsg("0", 1, 254, 0, 300, 1, "活动：活动《" .. actName .. "》已关闭...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "活动：活动《" .. actName .. "》已关闭...")
    for _, playerObj in ipairs(getplayerlst() or {}) do
        sendluamsg(playerObj, 101, 12, 4, idx, "")
    end
    Player.sendmsgEx(play, actName .. "测试结束#249")
end

local function _admin_not_ready(play, name)
    _admin_simple_activity_start(play, 0, tostring(name or "测试活动"), 5)
end

local function _admin_qmdk_start(play)
    local cfg = QmdkApi and QmdkApi.get_cfg and QmdkApi.get_cfg() or nil
    if not cfg then
        Player.sendmsgEx(play, "全民夺矿配置缺失#57")
        return
    end
    if getsysvar(VarCfg["G_全民夺矿状态"]) == 1 then
        Player.sendmsgEx(play, "全民夺矿当前已开启#57")
        return
    end
    if QmdkApi and QmdkApi.reset_online_scores then
        QmdkApi.reset_online_scores()
    end
    local dqfz = tonumber(getsysvar(VarCfg["G_开区分钟"]) or 0) or 0
    local state = {
        open = 1,
        start_minute = dqfz,
        map = cfg.map,
        score_var = cfg.score_var_prefix or "全民夺矿",
        from_bot = 1,
        prepare_end_ts = os.time() + (tonumber(cfg.prepare_sec) or 10),
    }
    setsysvar(VarCfg["G_全民夺矿状态"], 1)
    if QmdkApi and QmdkApi.save_state then
        QmdkApi.save_state(state)
    else
        setsysvar(VarCfg["A_全民夺矿json"], tbl2json(state))
    end
    if QmdkApi and QmdkApi.tick_runtime then
        state = QmdkApi.tick_runtime(cfg, state) or state
    end
    setenvirontimer(cfg.map, 3, tonumber(cfg.score_tick_sec) or 1, "@hd_tcppk," .. cfg.map)
    sendmovemsg("0", 1, 254, 0, 300, 1, "活动：活动《全民夺矿》已开启，10秒后开始采矿搬运...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "活动：活动《全民夺矿》已开启，10秒后开始采矿搬运...")
    for _, playerObj in ipairs(getplayerlst() or {}) do
        sendluamsg(playerObj, 101, 12, 1, 2, '{"sk":' .. (tonumber(cfg.duration_min) or 20) .. ',"kf":2,"idx":2}')
        if QmdkApi and QmdkApi.refresh_actor then
            QmdkApi.refresh_actor(playerObj)
        end
    end
    Player.sendmsgEx(play, "全民夺矿已立即开启#249")
end

local function _admin_qmdk_finish(play)
    local cfg = QmdkApi and QmdkApi.get_cfg and QmdkApi.get_cfg() or nil
    if not cfg then
        Player.sendmsgEx(play, "全民夺矿配置缺失#57")
        return
    end
    if getsysvar(VarCfg["G_全民夺矿状态"]) ~= 1 then
        Player.sendmsgEx(play, "全民夺矿当前未开启#57")
        return
    end
    local state = QmdkApi and QmdkApi.get_state and QmdkApi.get_state() or {}
    local mapName = (type(state) == "table" and state.map and state.map ~= "") and state.map or cfg.map
    setenvirofftimer(mapName, 3)
    if cfg.ore_mob and cfg.ore_mob ~= "" then
        killmonsters(mapName, cfg.ore_mob, 0, false)
    end
    if QmdkApi and QmdkApi.clear_all_online then
        QmdkApi.clear_all_online(cfg, false)
    end
    for _, playerObj in ipairs(getplayerlst() or {}) do
        sendluamsg(playerObj, 101, 498, 2, 0, "")
        setplaydef(playerObj, "N$qmdk_panel", 0)
    end
    sendmovemsg("0", 1, 254, 0, 300, 1, "活动：活动《全民夺矿》已结束,本次第一名为【测试玩家】...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "活动：活动《全民夺矿》已结束,本次第一名为【测试玩家】...")
    state.open = 0
    state.finished = 1
    state.from_bot = 1
    state.rank = state.rank or {}
    if QmdkApi and QmdkApi.save_state then
        QmdkApi.save_state(state)
    else
        setsysvar(VarCfg["A_全民夺矿json"], tbl2json(state))
    end
    setsysvar(VarCfg["G_全民夺矿状态"], 0)
    Player.sendmsgEx(play, "全民夺矿已立即关闭#249")
end

local function _admin_qmdt_build_prompt(q, qidx, total)
    local lines = {"第" .. tostring(qidx) .. "/" .. tostring(total) .. "题：" .. tostring(q.title or "")}
    for i, one in ipairs(q.options or {}) do
        lines[#lines + 1] = tostring(i) .. "." .. tostring(one)
    end
    lines[#lines + 1] = "请输入答案序号或完整答案"
    return table.concat(lines, "\n")
end

local function _admin_qmdt_start(play)
    local cfg = teshudata and teshudata["anniu_507"] and teshudata["anniu_507"].qmdt or nil
    if type(cfg) ~= "table" or type(cfg.questions) ~= "table" or #cfg.questions <= 0 then
        Player.sendmsgEx(play, "全民答题配置缺失#57")
        return
    end
    local dqfz = tonumber(getsysvar(VarCfg["G_开区分钟"]) or 0) or 0
    local qidx = 1
    local perSec = tonumber(cfg.per_question_sec) or 120
    local state = {
        open = 1,
        start_minute = dqfz,
        current_idx = qidx,
        question_start_minute = dqfz,
        question_end_ts = os.time() + perSec,
        players = {},
    }
    setsysvar(VarCfg["G_全民答题状态"], 1)
    setsysvar(VarCfg["A_全民答题json"], tbl2json(state))
    for _, playerObj in ipairs(getplayerlst() or {}) do
        sendluamsg(playerObj, 101, 12, 1, 3, '{"sk":2,"kf":2,"idx":3}')
    end
    sendmovemsg("0", 1, 254, 0, 300, 1, "活动：活动《全民答题》已开启，请通过活动面板输入答案...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "活动：活动《全民答题》已开启，请通过活动面板输入答案...")
    Player.sendmsgEx(play, _admin_qmdt_build_prompt(cfg.questions[qidx], qidx, math.min(tonumber(cfg.question_count) or #cfg.questions, #cfg.questions)))
end

local function _admin_qmdt_finish(play)
    local raw = getsysvar(VarCfg["A_全民答题json"])
    local state = raw ~= "" and json2tbl(raw) or {}
    state.open = 0
    state.finished = 1
    setsysvar(VarCfg["A_全民答题json"], tbl2json(state))
    setsysvar(VarCfg["G_全民答题状态"], 0)
    sendmovemsg("0", 1, 254, 0, 300, 1, "活动：活动《全民答题》已结束,本次第一名为【测试玩家】...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "活动：活动《全民答题》已结束,本次第一名为【测试玩家】...")
    Player.sendmsgEx(play, "全民答题已手动关闭#249")
end

local function _admin_wlmz_start(play)
    setenvirontimer("比武大会", 2, 10, "@hd_tcppk,比武大会")
    sendmovemsg("0", 1, 254, 0, 300, 1, "活动：活动《武林盟主》已开启奖励丰厚,请尽快参加活动...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "活动：活动《武林盟主》已开启奖励丰厚,请尽快参加活动...")
    for _, playerObj in ipairs(getplayerlst() or {}) do
        sendluamsg(playerObj, 101, 12, 1, 9, '{"sk":5,"kf":2,"idx":9}')
    end
    Player.sendmsgEx(play, "武林盟主测试开始#249")
end

local function _admin_wlmz_finish(play)
    setenvirofftimer("比武大会", 2)
    sendmovemsg("0", 1, 254, 0, 300, 1, "活动：活动《武林盟主》已关闭,本次活动第一名为【测试玩家】...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "活动：活动《武林盟主》已关闭,本次活动第一名为【测试玩家】...")
    Player.sendmsgEx(play, "武林盟主测试结束#249")
end

local function _admin_tcppk_start(play)
    setenvirontimer("xtc", 1, 3, "@hd_tcppk,xtc")
    for _, playerObj in ipairs(getplayerlst() or {}) do
        sendluamsg(playerObj, 101, 1000, 1, 0, "")
        setplaydef(playerObj, "N$上次坐标x", 0)
        setplaydef(playerObj, "N$上次坐标y", 0)
        sendluamsg(playerObj, 101, 12, 1, 5, '{"sk":3,"kf":2,"idx":5}')
    end
    sendmovemsg("0", 1, 254, 0, 300, 1, "活动：活动《土城跑酷》已开启奖励丰厚,请尽快参加活动...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "活动：活动《土城跑酷》已开启奖励丰厚,请尽快参加活动...")
    sendmovemsg("0", 1, 254, 0, 240, 1, "活动：活动《土城跑酷》已开启奖励丰厚,请尽快参加活动...")
    Player.sendmsgEx(play, "土城跑酷测试开始#249")
end

local function _admin_tcppk_finish(play)
    setenvirofftimer("xtc", 1)
    for _, playerObj in ipairs(getplayerlst() or {}) do
        sendluamsg(playerObj, 101, 1000, 2, 0, "")
        sendluamsg(playerObj, 101, 12, 4, 3, "")
        setplaydef(playerObj, "N$上次坐标x", 0)
        setplaydef(playerObj, "N$上次坐标y", 0)
    end
    sendmovemsg("0", 1, 254, 0, 300, 1, "活动：活动《土城跑酷》已关闭...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "活动：活动《土城跑酷》已关闭...")
    Player.sendmsgEx(play, "土城跑酷测试结束#249")
end

local function _admin_txzr_start(play)
    sendmovemsg("0", 1, 253, 0, 300, 1, "天选之人：活动《天选之人》已开启,请玩家尽快参与...")
    sendmovemsg("0", 1, 249, 0, 250, 1, "天选之人：活动《天选之人》已开启,请玩家尽快参与...")
    for _, playerObj in ipairs(getplayerlst() or {}) do
        sendluamsg(playerObj, 101, 12, 1, 7, '{"sk":120,"kf":2,"idx":7}')
    end
    Player.sendmsgEx(play, "天选之人测试开始#249")
end

local function _admin_txzr_finish(play)
    sendmovemsg("0", 1, 253, 0, 300, 1, "天选之人：测试轮次已结束...")
    sendmovemsg("0", 1, 249, 0, 250, 1, "天选之人：测试轮次已结束...")
    Player.sendmsgEx(play, "天选之人测试结束#249")
end

local function _admin_sbk_start(play)
    repaircastle()
    addattacksabakall()
    Player.sendmsgEx(play, "攻沙测试开始#249")
end

local function _admin_sbk_finish(play)
    Player.sendmsgEx(play, "攻沙测试结束#249")
end

local function _admin_sjdb_start(play)
    local cfg = teshudata and teshudata["anniu_507"] and teshudata["anniu_507"].sjdb or {}
    local keepSec = tonumber(cfg.keep_sec) or 180
    local keepMin = math.max(1, math.floor((keepSec + 59) / 60))
    local mapName = tostring(cfg.map or "天降财宝")
    local center = type(cfg.center) == "table" and cfg.center or {x = 215, y = 53}
    sendmovemsg("0", 1, 254, 0, 300, 1, "活动：活动《随机夺宝》已开启奖励丰厚,请尽快参加活动...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "活动：活动《随机夺宝》已开启奖励丰厚,请尽快参加活动...")
    sendmovemsg("0", 1, 254, 0, 240, 1, "活动：活动《随机夺宝》已开启奖励丰厚,请尽快参加活动...")
    for _, playerObj in ipairs(getplayerlst() or {}) do
        sendluamsg(playerObj, 101, 12, 1, 13, '{"sk":' .. keepMin .. ',"kf":2,"idx":13}')
    end
    for _, circle in ipairs(cfg.circles or {}) do
        local range = tonumber(circle and circle.range) or 200
        for _, drop in ipairs((circle and circle.drops) or {}) do
            local itemName = drop and drop.item or ""
            local dropCount = tonumber(drop and drop.count) or 0
            if itemName ~= "" and dropCount > 0 then
                throwitem("0", mapName, tonumber(center.x) or 215, tonumber(center.y) or 53, range, itemName, dropCount, keepSec, false, true, false, false)
            end
        end
    end
    Player.sendmsgEx(play, "随机夺宝测试开始#249")
end

local function _admin_sjdb_finish(play)
    sendmovemsg("0", 1, 254, 0, 300, 1, "活动：活动《随机夺宝》已关闭...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "活动：活动《随机夺宝》已关闭...")
    Player.sendmsgEx(play, "随机夺宝测试结束#249")
end
function npc.main(play,npcid)
    local zhid = tonumber(getconst(play,"<$USERACCOUNT>"))
    if constant.pz_htqx[zhid] or getconst(play, '<$SERVERNAME>') == "" or getconst(play, '<$SERVERNAME>') == "测试区" then
        -- release_print("-----------------------------")
        -- release_print(getbaseinfo(play,3).." "..getbaseinfo(play,4).." "..getbaseinfo(play,5))
        -- return
        say(play,[[<Img|id=ui_1|x=0.0|y=-1.0|width=800|height=600|img=public/bg_npc_01.png|bg=1|esc=1|move=0|reset=1|show=0|scale9l=15|scale9r=15|scale9t=15|scale9b=15|loadDelay=1>
            <Layout|id=ui_2|x=801.0|y=0.0|width=80|height=80|link=@exit>
            <Button|id=ui_3|x=794|y=0.0|width=26|height=42|nimg=public/1900000510.png|pimg=public/1900000511.png|color=255|size=18|link=@exit>
            <EquipShow|id=ui_27|x=0|y=500|index=71|showtips=1|link=@脚本命令>
            <EquipShow|id=ui_28|x=50|y=500|index=72|showtips=1|link=@脚本命令>
            <EquipShow|id=ui_29|x=100|y=500|index=73|showtips=1|link=@脚本命令>
            <EquipShow|id=ui_30|x=150|y=500|index=17|showtips=1|link=@脚本命令>
            <EquipShow|id=ui_300|x=200|y=500|index=87|showtips=1|link=@脚本命令>
            <EquipShow|id=ui_301|x=250|y=500|index=104|showtips=1|link=@脚本命令>

            <Button|id=ui_100|x=150|y=450|width=160|height=40|nimg=public/1900000660.png|color=251|size=16|text=llxf测试|link=@ggna,24>
            <Button|id=ui_101|x=350|y=450|width=160|height=40|nimg=public/1900000660.png|color=251|size=16|text=测试装备|link=@ggna,23>
            <Button|id=ui_102|x=550|y=450|width=160|height=40|nimg=public/1900000660.png|color=251|size=16|text=大陆全解锁|link=@ggna,25>

            <Button|id=ui_39|x=18|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=村庄开始|link=@ggna,32>
            <Button|id=ui_40|x=130|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=村庄结束|link=@ggna,33>
            <Button|id=ui_41|x=242|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=夺矿开始|link=@ggna,26>
            <Button|id=ui_42|x=354|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=夺矿结束|link=@ggna,27>
            <Button|id=ui_43|x=466|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=答题开始|link=@ggna,28>
            <Button|id=ui_44|x=578|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=答题结束|link=@ggna,29>
            <Button|id=ui_45|x=18|y=150|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=镖车开始|link=@ggna,34>
            <Button|id=ui_46|x=130|y=150|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=镖车结束|link=@ggna,35>
            <Button|id=ui_47|x=242|y=150|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=跑酷开始|link=@ggna,36>
            <Button|id=ui_48|x=354|y=150|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=跑酷结束|link=@ggna,37>
            <Button|id=ui_49|x=466|y=150|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=地宝开始|link=@ggna,38>
            <Button|id=ui_50|x=578|y=150|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=地宝结束|link=@ggna,39>
            <Button|id=ui_51|x=18|y=200|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=天选开始|link=@ggna,40>
            <Button|id=ui_52|x=130|y=200|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=天选结束|link=@ggna,41>
            <Button|id=ui_53|x=242|y=200|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=正邪开始|link=@ggna,42>
            <Button|id=ui_54|x=354|y=200|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=正邪结束|link=@ggna,43>
            <Button|id=ui_55|x=466|y=200|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=盟主开始|link=@ggna,30>
            <Button|id=ui_56|x=578|y=200|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=盟主结束|link=@ggna,31>
            <Button|id=ui_57|x=18|y=250|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=沙城开始|link=@ggna,44>
            <Button|id=ui_58|x=130|y=250|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=沙城结束|link=@ggna,45>
            <Button|id=ui_59|x=242|y=250|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=BOSS开始|link=@ggna,46>
            <Button|id=ui_60|x=354|y=250|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=BOSS结束|link=@ggna,47>
            <Button|id=ui_61|x=466|y=250|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=夺宝开始|link=@ggna,48>
            <Button|id=ui_62|x=578|y=250|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=夺宝结束|link=@ggna,49>
            <Button|id=ui_63|x=18|y=300|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=禁地开始|link=@ggna,50>
            <Button|id=ui_64|x=130|y=300|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=禁地结束|link=@ggna,51>
            <Button|id=ui_66|x=242|y=300|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=成就测试|link=@ggna,52>
            <Button|id=ui_67|x=354|y=300|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=刷怪测试|link=@ggna,53>
            <Button|id=ui_65|x=578|y=300|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=飘字测试|link=@ggna,14>

                ]])
    end

end

function ggna(play,id)
    if id == "1" then
        local item = linkbodyitem(play,73)
        if item == "0" then
            Player.sendmsgEx(play, "数据异常#57")
        else
            if checktitle(play,"狂暴之力") then
                Player.sendmsgEx(play, "你已经开启过#57|【狂暴之力】#249|了#57")
            else
                confertitle(play,"狂暴之力")
                changecustomitemvalue(play,linkbodyitem(play,73),0,"=",20,1)
                Player.sendmsgEx(play, "完成")
            end
        end
    elseif id == "2" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            Player.sendmsgEx(play, "数据异常#57")
        else
            local sx = json2tbl(getitemcustomabil(play, item))
            if sx.abil[2].v[1][3] >= 30 then
                Player.sendmsgEx(play, "已满级#57")
            else
                changecustomitemvalue(play,item,0,"=",30,1)
                changecustomitemvalue(play,item,1,"=",1500,1)
                --changecustomitemvalue(play,item,8,"=",3000,1)
                changecustomitemvalue(play,item,2,"=",30,1)
                changecustomitemvalue(play,item,3,"=",30,1)
                changecustomitemvalue(play,item,4,"=",6000,1)
                changecustomitemvalue(play,item,5,"=",6000,1)
                changecustomitemvalue(play,item,6,"=",600,1)
                changecustomitemvalue(play,item,7,"=",600,1)
                confertitle(play,"传功阁大神魔")
                Player.sendmsgEx(play, "完成")
            end
        end
    elseif id == "3" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            Player.sendmsgEx(play, "数据异常#57")
        else
            changecustomitemvalue(play,item,0,"=",400,0)
            changecustomitemvalue(play,item,1,"=",400,0)
            changecustomitemvalue(play,item,2,"=",4000,0)
            changecustomitemvalue(play,item,3,"=",20000,0)
            changecustomitemvalue(play,item,9,"=",5000,0)
            confertitle(play,teshudata["npc_54"].del_title)
            changecustomitemvalue(play,item,4,"=",200,0)
            changecustomitemvalue(play,item,5,"=",10,0)
            changecustomitemvalue(play,item,6,"=",20,0)
            changecustomitemvalue(play,item,7,"=",10,0)
            changecustomitemvalue(play,item,8,"=",20,0)
            Player.sendmsgEx(play, "完成")
        end
    elseif id == "4" then
        local zs = getbaseinfo(play,39)
        if zs > 5 then
            Player.sendmsgEx(play, "【转生】#249|你转生在我这已经满级了#57")
        else
            setbaseinfo(play,39,6)
            confertitle(play,"6重转生")
            changecustomitemvalue(play,linkbodyitem(play,72),0,"=",15,2)
            Player.sendmsgEx(play, "完成")
        end
    elseif id == "5" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            Player.sendmsgEx(play, "数据异常#57")
        else
            changecustomitemvalue(play,item,0,"=",500,2)
            changecustomitemvalue(play,item,1,"=",5000,2)
            changecustomitemvalue(play,item,2,"=",10,2)
            changecustomitemvalue(play,item,3,"=",10,2)
            changecustomitemvalue(play,item,4,"=",10,2)
            changecustomitemvalue(play,item,5,"=",1000,2)
            changecustomitemvalue(play,item,6,"=",20,2)
            changecustomitemvalue(play,item,7,"=",40,2)
            changecustomitemvalue(play,item,8,"=",20,2)
            changecustomitemvalue(play,item,9,"=",40,2)
            confertitle(play,"八卦十重")
            Player.sendmsgEx(play, "完成")
        end
    elseif id == "6" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            Player.sendmsgEx(play, "数据异常#57")
        else
            changecustomitemvalue(play,item,0,"=",10,3)
            changecustomitemvalue(play,item,1,"=",10,3)
            changecustomitemvalue(play,item,2,"=",10,3)
            changecustomitemvalue(play,item,3,"=",10,3)
            changecustomitemvalue(play,item,4,"=",1000,3)
            changecustomitemvalue(play,item,5,"=",10,3)
            changecustomitemvalue(play,item,6,"=",20,3)
            changecustomitemvalue(play,item,7,"=",10,3)
            changecustomitemvalue(play,item,8,"=",20,3)
            changecustomitemvalue(play,item,9,"=",1,3)
            changecustomitemvalue(play,item,0,"=",15,4)
            changecustomitemvalue(play,item,1,"=",30,4)
            changecustomitemvalue(play,item,2,"=",15,4)
            changecustomitemvalue(play,item,3,"=",30,4)
            confertitle(play,"仙法阁十重")
            Player.sendmsgEx(play, "完成")
        end
    elseif id == "7" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            Player.sendmsgEx(play, "数据异常#57")
        else
            Player.sendmsgEx(play, "完成")
        end
    elseif id == "8" then
        local item = linkbodyitem(play, 72)
        if item == "0" then
            Player.sendmsgEx(play, "数据异常#57")
        else
            changecustomitemvalue(play,item,0,"+",100,0)
            changecustomitemvalue(play,item,1,"+",100,0)
            changecustomitemvalue(play,item,2,"+",5000,0)
            local data = json2tbl(getplaydef(play,VarCfg.T_ystz))
            data.xt1 = 1
            data.xt2 = 1
            data.xt3 = 1
            data.xt4 = 1
            data.xt5 = 1
            data.xt6 = 1
            data.xt7 = 1
            data.xt8 = 1
            setplaydef(play,VarCfg.T_ystz,tbl2json(data))
            confertitle(play,"天才地宝(地)")
            Player.sendmsgEx(play, "完成")
        end
    elseif id == "9" then
        local item = linkbodyitem(play, 72)
        if item == "0" then
            Player.sendmsgEx(play, "数据异常#57")
        else
            changecustomitemvalue(play,item,0,"+",250,0)
            changecustomitemvalue(play,item,1,"+",250,0)
            changecustomitemvalue(play,item,2,"+",10000,0)
            local data = json2tbl(getplaydef(play,VarCfg.T_ystz))
            data.yy1 = 1
            data.yy2 = 1
            data.yy3 = 1
            data.yy4 = 1
            data.yy5 = 1
            data.yy6 = 1
            data.yy7 = 1
            data.yy8 = 1
            setplaydef(play,VarCfg.T_ystz,tbl2json(data))
            confertitle(play,"天才地宝(天)")
            Player.sendmsgEx(play, "完成")
        end
    elseif id == "10" then
        local item = linkbodyitem(play, 72)
        if item == "0" then
            Player.sendmsgEx(play, "数据异常#57")
        else
            changecustomitemvalue(play,item,0,"+",500,0)
            changecustomitemvalue(play,item,1,"+",500,0)
            changecustomitemvalue(play,item,2,"+",20000,0)
            local data = json2tbl(getplaydef(play,VarCfg.T_ystz))
            data.xc1 = 1
            data.xc2 = 1
            data.xc3 = 1
            data.xc4 = 1
            data.xc5 = 1
            data.xc6 = 1
            data.xc7 = 1
            data.xc8 = 1
            setplaydef(play,VarCfg.T_ystz,tbl2json(data))
            confertitle(play,"天才地宝(神)")
            Player.sendmsgEx(play, "完成")
        end
    elseif id == "11" then
        setplaydef(play,VarCfg.T_gjyj,'{"gjyj":[100000,100000,100000,100000,100000,100000,100000,100000,100000,0,0,0]}')  --冠绝一界
        Player.sendmsgEx(play, "完成")
    elseif id == "12" then
        setplaydef(play,VarCfg.U_qhdj[1],66)
        setplaydef(play,VarCfg.U_qhdj[2],66)
        Player.sendmsgEx(play, "完成")
    elseif id == "13" then
        reddot(play, 200, 100, 10, 10, 0, "res/public/ists.png")
        reddot(play, 200, 101, 10, 10, 0, "res/public/ists.png")
        reddot(play, 0, tonumber("Button"), 10, 10, 0, "res/public/ists.png")
        Player.sendmsgEx(play, "完成")
        Player.sendmsgEx(play, "角色红点")
    elseif id == "14" then
        local activity_names = {"全民夺矿", "全民答题", "土城跑酷", "天选之人", "武林盟主", "随机夺宝"}
        local base_row = tonumber(getsysvar("N$9999ActivityNoticeRow") or 0) or 0
        for idx, actName in ipairs(activity_names) do
            local row = (base_row + idx - 1) % 30
            local x = 100
            local y = 700 - row * 18
            local payload = getbaseinfo(play, 1) .. "参与了[" .. actName .. "]活动"
            for _, playerObj in ipairs(getplayerlst() or {}) do
                sendcustommsg(playerObj, 1, payload, 251, 0, x, y)
            end
        end
        setsysvar("N$9999ActivityNoticeRow", (base_row + #activity_names) % 30)
        Player.sendmsgEx(play, "活动进入飘字测试完成")
    elseif id == "15" then
        local wpdx = linkbodyitem(play,76)
        local item = linkbodyitem(play,17)
        setitemcustomabil(play, wpdx,getitemcustomabil(play, item))
        Player.sendmsgEx(play, "完成")
    elseif id == "16" then
        setplaydef(play,VarCfg.U_zllv,1)
        Player.sendmsgEx(play, "完成")
    elseif id == "17" then
        local zl = json2tbl(getplaydef(play,VarCfg.T_zlxj))
        zl["dj"] = 1 + zl["dj"]
        setplaydef(play,VarCfg.T_zlxj,tbl2json(zl))
        Player.sendmsgEx(play, "完成")
    elseif id == "18" then
        if getplaydef(play,VarCfg.U_zxrw[1])then
            newdeletetask(play,getplaydef(play,VarCfg.U_zxrw[1]))
            playeffect(play,4011,25,-50,1,0,0)
        end
    elseif id == "19" then
        setplaydef(play,VarCfg.T_mjsj,'{"mjsj":[0,99,199,0,0,0,0,0,0,0,0,0]}')  --冠绝一界
    elseif id == "20" then
        setitemintparam(play,71,1,2)
    elseif id == "21" then
        repaircastle()
        addattacksabakall()
        Player.sendmsgEx(play, "攻沙开始")
    elseif id == "26" then
        _admin_qmdk_start(play)
    elseif id == "27" then
        _admin_qmdk_finish(play)
    elseif id == "28" then
        _admin_qmdt_start(play)
    elseif id == "29" then
        _admin_qmdt_finish(play)
    elseif id == "30" then
        _admin_wlmz_start(play)
    elseif id == "31" then
        _admin_wlmz_finish(play)
    elseif id == "32" then
        _admin_simple_activity_start(play, 1, "保卫村庄", 5)
    elseif id == "33" then
        _admin_simple_activity_finish(play, 1, "保卫村庄")
    elseif id == "34" then
        _admin_simple_activity_start(play, 4, "勇夺镖车", 5)
    elseif id == "35" then
        _admin_simple_activity_finish(play, 4, "勇夺镖车")
    elseif id == "36" then
        _admin_tcppk_start(play)
    elseif id == "37" then
        _admin_tcppk_finish(play)
    elseif id == "38" then
        _admin_simple_activity_start(play, 6, "天才地宝", 5)
    elseif id == "39" then
        _admin_simple_activity_finish(play, 6, "天才地宝")
    elseif id == "40" then
        _admin_txzr_start(play)
    elseif id == "41" then
        _admin_txzr_finish(play)
    elseif id == "42" then
        _admin_simple_activity_start(play, 8, "正邪大战", 5)
    elseif id == "43" then
        _admin_simple_activity_finish(play, 8, "正邪大战")
    elseif id == "44" then
        _admin_sbk_start(play)
    elseif id == "45" then
        _admin_sbk_finish(play)
    elseif id == "46" then
        _admin_simple_activity_start(play, 12, "讨伐BOSS", 5)
    elseif id == "47" then
        _admin_simple_activity_finish(play, 12, "讨伐BOSS")
    elseif id == "48" then
        _admin_sjdb_start(play)
    elseif id == "49" then
        _admin_sjdb_finish(play)
    elseif id == "50" then
        _admin_simple_activity_start(play, 14, "黑暗禁地", 5)
    elseif id == "51" then
        _admin_simple_activity_finish(play, 14, "黑暗禁地")
    elseif id == "52" then
        _ff9999_random_finish(play)
    elseif id == "53" then
        _admin_spawn_test_monsters(play)
    elseif id == "25" then
        -- 大陆进入条件一键达成：主线进度、转生等级、剧情点
        local target_task = 21
        local target_zs = 40
        local target_jqd = 100

        local cur_task = tonumber(getplaydef(play, VarCfg.U_zxrw[1])) or 0
        if cur_task < target_task then
            setplaydef(play, VarCfg.U_zxrw[1], target_task)
        end

        local cur_zs_var = tonumber(getplaydef(play, VarCfg["U_转生等级"])) or 0
        if cur_zs_var < target_zs then
            setplaydef(play, VarCfg["U_转生等级"], target_zs)
        end

        local cur_zs_base = tonumber(getbaseinfo(play, 39)) or 0
        if cur_zs_base < target_zs then
            setbaseinfo(play, 39, target_zs)
        end

        local jqd_idx = tonumber(getstditeminfo("剧情点", 0)) or 0
        if jqd_idx > 0 then
            local cur_jqd = tonumber(querymoney(play, jqd_idx)) or 0
            if cur_jqd < target_jqd then
                changemoney(play, jqd_idx, "+", target_jqd - cur_jqd, "测试-大陆全解锁", true)
            end
        end

        Player.sendmsgEx(play, "大陆条件已一键解锁：主线>=21，转生>=40，剧情点>=100")
    elseif id == "23" then
        release_print("测试装备")
        local cailiao = {
"龙骨刀",
"龙骨甲",
"辰星战刃",
"辰星战甲",
"古月彻地斩",
"古月战狂甲",
"青天怒斩",
"青天战幻甲",
"凌风七色刃",
"凌风战影甲",
"冥海圣刃",
"冥海圣武甲",
"苍月圣狂斩",
"苍月圣魂甲",
"吟龍圣者剑",
"吟龍圣甲",
"殘魂必殺刃",
"殘魂必殺甲",
"黄金霸王斩",
"黄金锁子甲",
"霸者神兵",
"狂王披风",
"审判之刃",
"天使羽衣",
"天崩地裂斩",
"毁天灭地甲",
"神·暴风",
"神·战甲",
"圣·暴风",
"圣·战甲",
"血杀",
"雄霸",
"梦回",
"心梦碎光",
"千年",
"深蓝传说",
"转瞬",
"深蓝之恋",
"轮回",
"万里追云",
"碧血",
"金丝羽灵",
"妖异",
"碎梦涵光",
"啸风逐电",
"龙鳞震岳",
"雷霆幻",
"永恒星辰",
"霜雪之间",
"烈焰焚天",
"天罚雷击",
"炽焰灰烬",
"锁鳞",
"裂天",
"星陨",
"寂照",
"青衿",
"鸿蒙初启",
"封魔镇狱",
"赤焰戒",
"嘲天笑地",
"冥火",
"紫电",
"破界",
"月上影",
"叶知秋",
"虚空回响",
"灵犀一点",
"三生石影",
"渡世莲华",
"噬魂夺魄",
"焚霄",
"神寂",
"道陨",
"净世真言",
"深渊凝视",
"魂锁",
"空界之芯",
"封龙劍メ驱逐之刃",
"异空：千年之光",
"龙之力·不灭光剑!",
"黄昏落幕ぁ",
"群星之怒★★★",
"夜风·不败剑意",
"星辉的祷告乀",
"御天机",
"地苍·岩落",
"水泽·魂之护",
"奇迹之金刃圣剑",
"风暴之心·穹霄",


        }
        for k, v in pairs(cailiao) do
            giveitem(play,v,1)
        end
    elseif id == "24" then
        -- 测试脚本：调整地图怪物密度（逐图刷小怪，9x9检测饱和）
--         local map_list = {
--             -- "山庄",
--             -- "幽谷",
--             -- "洞穴",
--             -- "古殿",
--             -- "山庄一",
--             -- "幽谷一",
--             -- "洞穴一",
--             -- "古殿一",
--             -- "隐藏地图二",
--             -- "野火帮",
--             -- "野火帮大营",
--             -- "极光城郊",
--             -- "神秘森林",
--             -- "兵道古藏",
--             -- "乱葬岗",
--             -- "夜魔洞",
--             -- "洞穴深处",
--             -- "洞穴秘境",

-- --             "灰界",
-- -- "灰界南部",
-- -- "灰界北部",
-- -- "灰界东部",
-- -- "灰界西部",
-- -- "虚妄山脉",
-- -- "鬼嘲深渊",
-- -- "叹息旷野",
-- -- "禁忌之海",
-- -- "藏星海",
-- -- "藏星外海",
-- -- "神秘岛屿",
-- -- "黑暗洞窟",
-- -- "千年沉船",
-- -- "船长室",
-- -- "水手舱",
-- -- "藏星内海",
-- -- "七星岛",
-- -- "葬星城",
-- -- "葬星海滩",
-- -- "葬星海滩1",
-- -- "苍云城",
-- -- "苍云城郊外",
-- -- "苍云内城",
-- -- "苍云客栈",
-- -- "草药谷",
-- -- "仙草田",
-- -- "草药古深处",
-- -- "丹道古藏",
-- -- "酆都鬼城",
-- -- "鬼门关",
-- -- "黄泉路",
-- -- "奈何桥",
-- -- "罗酆六天",
-- -- "十八层地狱",
-- -- "六道轮回",
-- -- "大唐·长安城",
-- -- "东海龙宫",
-- -- "黑风山",
-- -- "黄风岭",
-- -- "女儿国",
-- -- "通天河",
-- -- "狮驼岭",
-- -- "天竺山",
-- -- "火焰山",
-- -- "生肖灵域",
-- -- "灵域·一层",
-- -- "子鼠灵域",
-- -- "丑牛灵域",
-- -- "寅虎灵域",
-- -- "卯兔灵域",
-- -- "灵域·二层",
-- -- "辰龙灵域",
-- -- "巳蛇灵域",
-- -- "午马灵域",
-- -- "未羊灵域",
-- -- "灵域·三层",
-- -- "申猴灵域",
-- -- "酉鸡灵域",
-- -- "戌狗灵域",
-- -- "亥猪灵域",
-- -- "灵域·秘境",
-- -- "传说之地",
-- -- "盘古开天",
-- -- "羿射九日",
-- -- "不周山",
-- -- "女娲补天",
-- -- "黑白无常",
-- -- "后土娘娘",
-- -- "真假玉帝",
-- -- "白蛇传说",
-- -- "灵兽谷",
-- -- "青龙之境",
-- -- "朱雀之境",
-- -- "玄武之境",
-- -- "白虎之境",
-- -- "麒麟之境",
-- -- "时空裂隙",
-- -- "倚天江湖",
-- -- "冰火岛",
-- -- "光明顶",
-- -- "三国乱世",
-- -- "虎牢关",
-- -- "赤壁",
-- -- "水浒再临",
-- -- "景阳冈",
-- -- "狮子楼",
-- -- "生命边界",
-- -- "白骨神庙",
-- -- "神庙暗廊",
-- -- "诡冥墨河",
-- -- "河神寝宫",
-- -- "赤焰焚殿",
-- -- "赤焰焚殿二层",
-- -- "赤焰焚殿三层",
-- -- "葬天旧土",
-- -- "聊斋志异",
-- "兰若寺",
-- "画壁",
-- "崂山",
-- "罗刹海市",
-- "敦煌遗梦",
-- "莫高窟",
-- "月牙泉",
-- "玉门关",
-- "阳关道",
-- "世界禁墟",
-- "大地禁墟一层",
-- "大地禁墟二层",
-- "大地禁墟三层",
-- "天空禁墟一层",
-- "天空禁墟二层",
-- "天空禁墟三层",
-- "海洋禁墟一层",
-- "海洋禁墟二层",
-- "海洋禁墟三层",
-- "青铜禁墟一层",
-- "青铜禁墟二层",
-- "青铜禁墟三层",
--         } -- TODO: 填入要调整的地图名
--         local normal_mobs = {"枯灯客"} -- TODO: 普通怪列表

--         local range = 3 -- 刷怪点随机半径
--         local check_range = 6 -- 9x9检测半径(2*4+1)
--         local max_fail = 40 -- 连续失败上限(饱和)
--         local tries_per_spawn = 10 -- 每次刷怪找点尝试次数
--         local spawn_limit = 5000 -- 每张地图单次补怪上限

--         for _, map in ipairs(map_list) do
--             local w = getmapinfo(map, 0) or 0
--             local h = getmapinfo(map, 1) or 0
--             if w > 0 and h > 0 then
--                 -- 检测前先清空地图怪物
--                 killmonsters(map, "*", 0, false)

--                 local counter = {n = 0}
--                 local added_normal = 0
--                 local sample_count = 0
--                 local total_ncnt = 0

--                 local fail_streak = 0
--                 local used_points = {}

--                 while fail_streak < max_fail do
--                     local rx = math.random(1, w)
--                     local ry = math.random(1, h)

--                     local key = rx.."_"..ry
--                     if used_points[key] then
--                         fail_streak = fail_streak + 1
--                     else
--                         local ok = true
--                         for k, _ in pairs(used_points) do
--                             local sx, sy = k:match("(%d+)_([%d]+)")
--                             if sx and sy then
--                                 sx = tonumber(sx)
--                                 sy = tonumber(sy)
--                                 if math.abs(rx - sx) <= check_range and math.abs(ry - sy) <= check_range then
--                                     ok = false
--                                     break
--                                 end
--                             end
--                         end

--                         if ok then
--                             genmonex(map, rx, ry, normal_mobs[math.random(1, #normal_mobs)], 1, 1, 0, 54, "", 0)
--                             used_points[key] = true
--                             counter.n = counter.n + 1
--                             added_normal = added_normal + 1
--                             fail_streak = 0
--                         else
--                             fail_streak = fail_streak + 1
--                         end
--                     end

--                     sample_count = sample_count + 1
--                     total_ncnt = total_ncnt + (used_points[key] and 1 or 0)

--                     if counter.n >= spawn_limit then
--                         break
--                     end
--                 end
--                     local avg_n = math.floor(total_ncnt / math.max(1, sample_count) + 0.5)
--                     sendmsg(play, 1, "{\"Msg\":\"<font color=\\\"#00ff00\\\">地图["..map.."] 小怪补："..added_normal.." 当前平均："..avg_n.."</font>\",\"Type\":9}")
--                     release_print("地图["..map.."] 小怪补："..added_normal)
--                     release_print("当前平均 小怪："..avg_n)
--             else
--                 sendmsg(play, 1, '{"Msg":"<font color=\"#ff0000\">地图['..map..']尺寸获取失败</font>","Type":9}')
--             end
--         end
--         return
        -- local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
        -- jq_data["npc_714"] = nil
        -- Player.setJsonTableByVar(play, VarCfg.T_dljq, jq_data)
        -- local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
        -- sg_data["npc_696"] = sg_data["npc_696"] + 100
        -- Player.setJsonTableByVar(play, VarCfg["T_各剧情杀怪"], sg_data)
        		-- sendmsgnew(play, 255, 0, '狂暴之力：玩家{《' .. getbaseinfo(play, 1) .. '》/FCOLOR=251}成功开启{[狂暴之力]/FCOLOR=250},击杀此人可获得额外奖励...', 1, 3)

        ---文字测试 
        -- 飘字测试请点上方按钮：@ggn,14
        -- Npclib[654].link(play, 654, 1, 0, "")

        -- local where = Player.hasEquipInArtifactSlot(play, "金箍棒")
        -- -- release_print(where)
        -- if not where then
        --     Player.sendmsgEx(play, "你需要装备金箍棒才能完成任务#57")
        --     return
        -- end
        -- local itemobj = linkbodyitem(play,where)
        -- local item_json = getitemcustomabil(play, itemobj)
        -- release_print(item_json)
        -- item_json = json2tbl(item_json)
        -- if item_json then
        --     item_json = json2tbl('{"abil":[{"i":0,"t":"[附加属性]","c":251,"v":[]}],"name":""}')
        -- end
        -- item_json.abil[1].v[1] = {1,253,200,1,13,1,1}
        -- item_json.abil[1].v[2] = {1,200,300,1,14,2,2}
        -- item_json.abil[1].v[3] = {1,244,8000,0,15,3,3}
        -- item_json.abil[1].v[4] = {1,30,5,1,16,4,4}
        -- item_json.abil[1].v[5] = {1,73,100,1,17,5,5}
        -- item_json.abil[1].v[6] = {1,89,100,1,18,6,6}
        -- item_json.abil[1].v[7] = {1,206,100,1,19,7,7}
        -- item_json = tbl2json(item_json)
        -- -- release_print(type(item_json))
        -- setitemcustomabil(play, itemobj, item_json)
        -- Player.setJsonVarByTable(play, VarCfg["T_砍树系统"], {})
        -- setplaydef(play, VarCfg.T_czlb,"{}")
        -- setplaydef(play,VarCfg.U_zxrw[1],21)
        -- setplaydef(play,VarCfg.T_hsdg, '{"1_1_1":1,"1_1_2":1,"1_1_3":1,"1_1_4":1,"1_1_5":1,"1_1_6":1,"1_1_7":1,"1_1_8":1,"1_1_9":1,"1_1_10":1,"1_1_11":1,"1_1_12":1}')--回收打勾
        local T_data = Player.getJsonTableByVar(play, VarCfg["T_灵根"])
    T_data.level = T_data.level or {}
T_data.level[""..math.random(1, 5)] = 0
        Player.setJsonVarByTable(play, VarCfg["T_灵根"], T_data)
        Player.sendmsgEx(play, "提示：你获得了新的|【灵根】#249|，请前往灵根升级界面查看")
        sendluamsg(play,100,npcid,1,0,tbl2json({["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_灵根"])}))

    end

end

return npc














