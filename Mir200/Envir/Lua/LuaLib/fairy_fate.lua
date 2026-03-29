FairyFate = FairyFate or {}
local _cfg = include("lua/Data/fairy_fate_cfg.lua") or {}
if type(_cfg.name) ~= "string" or _cfg.name == "" or string.find(_cfg.name, "%?") then _cfg.name = "仙途奇缘" end
_cfg.groups = (type(_cfg.groups) == "table" and #_cfg.groups > 0) and _cfg.groups or {"总览","角色","PVE","PVP","其他"}
local _attr_list_name = "仙途奇缘成就" -- 属性列表名：已达成成就换算后的最终属性挂载点
local _sys_first_login_key = "FF_仙途奇缘_首个注册" -- 系统变量：记录全服首个注册成就是否已触发
local _sys_castle_first_blood_key = "FF_仙途奇缘_攻沙首杀" -- 系统变量：记录攻沙首杀成就是否已触发
local _prepared = false -- 配置缓存是否已初始化
-- 这一套成就逻辑改成了"配置驱动"：
-- 1. fairy_fate_cfg.lua 里的 cond 仅作为展示文案保留给客户端/策划查看。
-- 2. 服务端真正参与判定的条件统一写入 detail.rule，避免中文字符、标点、空格变动后正则失效。
-- 3. 这里的代码只消费 rule/snapshot/counter 三层数据，不再反向解析 cond。
local _cfg_44 = nil -- 44号配置缓存：读取灵根/境界等扩展配置
local _realm_name_level = { ["筑基境"] = 10, ["金丹境"] = 14, ["元婴境"] = 18, ["大乘境"] = 22, ["渡劫境"] = 26, ["仙人境"] = 30 } -- 境界名称映射到内部等级
local _linggen_name_index = { ["金"] = 1, ["木"] = 2, ["水"] = 3, ["火"] = 4, ["土"] = 5, ["雷"] = 6, ["风"] = 7, ["冰"] = 8, ["焚"] = 9, ["岩"] = 10 } -- 灵根名称映射到存档索引
local _secret_name_dl = { ["极光秘境"] = 2, ["苍云秘境"] = 3, ["若水秘境"] = 4, ["红尘秘境"] = 5, ["灵虚秘境"] = 6 } -- 秘境名称映射大陆编号
local _reward_percent_attr = { -- 百分比类奖励映射到属性编号
    ["人物攻击"] = 282,["攻击伤害"] = 25,["造成伤害"] = 25,["暴击伤害"] = 22,["暴击几率"] = 21,["神力倍功"] = 67,["神圣一击概率"] = 79,
    ["对怪增伤"] = 245,["打怪增伤"] = 245,["打怪爆率"] = 242,["金币回收"] = 204,["伤害吸收"] = 206,["PK增伤"] = 76,["PK减伤"] = 77,
    ["移动速度"] = 243,["防御加成"] = 36,["魔法伤害减少"] = 27,["魔法伤害增加"] = 25,["对怪攻速"] = 200,
}
-- 仅用于客户端展示的假属性，不参与真实战斗计算
local _fake_attr_cfg = {
    cross_mon_damage_up = {name = "跨服怪物额外增伤", percent = true},
    popularity = {name = "人缘", percent = false},
    charm = {name = "魅力", percent = false},
}
local function _toint(v) return tonumber(v or 0) or 0 end
local function _count_pairs(t) local n = 0 for _ in pairs(t or {}) do n = n + 1 end return n end
local function _count_true(t) local n = 0 for _, v in pairs(t or {}) do if v and v ~= 0 and v ~= "0" and v ~= false then n = n + 1 end end return n end
-- 判断玩家是否拥有“全服孤品”对应资格。
-- 这里读取的是全服共享变量 A_全服孤品，而不是玩家个人局部变量。
-- 目的有两个：
-- 1. 让“全服孤品”成就真正绑定到全服唯一归属，而不是本地缓存；
-- 2. 玩家重新登录时，可以直接根据全服数据补算，不依赖当次掉落事件是否在线触发。
local function _has_global_unique(play)
    local data = Player.getJsonTableByVar(nil, VarCfg["A_全服孤品"]) or {}
    local playerName = tostring(getbaseinfo(play, ConstCfg.gbase.name) or "")
    if playerName == "" then return 0 end
    for _, owner in pairs(data) do
        if tostring(owner or "") == playerName then
            return 1
        end
    end
    return 0
end
-- 判断当前玩家是否就是“全服第一个注册/创建角色的人”。
-- 这里只做只读比对：真正写入首名的是 onNewHuman 事件。
-- 这样分离后，首名判定逻辑就固定为“谁先占到系统变量”，
-- 而不是谁先打开面板、谁先登录补判。
local function _is_first_create_login(play)
    local playerName = tostring(getbaseinfo(play, ConstCfg.gbase.name) or "")
    if playerName == "" then return 0 end
    return tostring(getsysvarex(_sys_first_login_key) or "") == playerName and 1 or 0
end
-- 判断玩家当前是否已经加入行会。
-- 这里专门做了一层脏值过滤，因为部分底层接口会返回 "0"、"无"、"nil" 这类假值。
-- 成就系统统一走这个函数，避免不同地方各自判断导致标准不一致。
local function _has_guild(play)
    local guildName = tostring(getbaseinfo(play, ConstCfg.gbase.guild) or "")
    return guildName ~= "" and guildName ~= "0" and guildName ~= "无" and guildName ~= "None" and guildName ~= "nil" and 1 or 0
end
-- 纠偏：如果历史脏数据把“第一名”成就错误发给了非首名玩家，这里会在重算前清掉。
-- 这一步不是正常达成流程的一部分，而是旧数据兼容层。
-- 为什么要单独做：
-- 1. 首名成就天然只能有一个人拥有；
-- 2. 一旦旧逻辑发错，单靠 _evaluate 不会自动回收；
-- 3. 所以进入 _evaluate 前要先做一次修正。
local function _normalize_unique_done(play, state)
    local changed = false
    local firstOwner = tostring(getsysvarex(_sys_first_login_key) or "")
    local playerName = tostring(getbaseinfo(play, ConstCfg.gbase.name) or "")
    if firstOwner == "" or playerName == "" then
        return false
    end
    local isFirst = firstOwner == playerName and 1 or 0
    for _, detail in ipairs(_cfg.details or {}) do
        if (detail.rule or {}).kind == "first_create_login" then
            local key = tostring(detail.id)
            if isFirst <= 0 and _toint(state.done[key]) > 0 then
                state.done[key] = 0
                changed = true
            end
            break
        end
    end
    if isFirst <= 0 and _toint(state.counter.first_create_login) > 0 then
        state.counter.first_create_login = 0
        changed = true
    end
    return changed
end
-- 纠偏：累计充值类成就重新按“真实充值总额”回收错误完成状态。
-- 这里主要防御两类历史问题：
-- 1. 旧版 cond 正则解析错误，把门槛算错；
-- 2. 玩家本地变量和 money23 有过不同步，导致面板提前点亮。
-- 逻辑上这里是“上限回收”，只会清掉不该完成的，不会主动发奖励。
local function _normalize_recharge_done(play, state)
    local changed = false
    local rechargeTotal = math.max(_toint(querymoney(play, 23)), _toint(getplaydef(play, VarCfg["U_真实充值"])))
    for _, detail in ipairs(_cfg.details or {}) do
        local rule = detail.rule or {}
        if rule.kind == "recharge_total" then
            local key = tostring(detail.id)
            if rechargeTotal < _toint(rule.target) and _toint(state.done[key]) > 0 then
                state.done[key] = 0
                changed = true
            end
        end
    end
    return changed
end
-- 把策划文案里的大数字统一转成纯整数。
-- 支持 1W/1w/1万/3000元/30,000 这类混合写法。
-- 虽然成就条件现在主要读 rule.target，但奖励文本解析仍然会复用这个工具。
local function _parse_big_num(text)
    text = tostring(text or "")
    local n = tonumber(text)
    if n then return n end
    local raw = string.lower(text)
    raw = raw:gsub("%s+", ""):gsub(",", ""):gsub("，", ""):gsub("元", ""):gsub("块", "")
    local has_w = string.find(raw, "w") ~= nil or string.find(raw, "万") ~= nil
    raw = raw:gsub("w", ""):gsub("万", "")
    local base = tonumber(raw) or 0
    if has_w then return base * 10000 end
    return 0
end
local function _split_text(text)
    local ret = {}
    text = tostring(text or ""):gsub("固定生命、固定魔法%+(%d+)", "固定生命+%1、固定魔法+%1"):gsub("，", "、"):gsub(",", "、")
    for part in string.gmatch(text, "[^、]+") do
        part = tostring(part):gsub("^%s+", ""):gsub("%s+$", "")
        if part ~= "" then ret[#ret + 1] = part end
    end
    return ret
end
local function _add_attr(list, attrId, value)
    attrId = _toint(attrId)
    value = _toint(value)
    if attrId > 0 and value ~= 0 then list[attrId] = (list[attrId] or 0) + value end
end
local function _push_special(list, key, value) list[#list + 1] = {key = key, value = _toint(value)} end
local function _reward_percent_value(v) return _toint(v) * 100 end
-- 把 reward 文案预解析成可执行奖励结构。
-- 输出分成三类：
-- 1. attrs: 真正挂到属性列表里的数值；
-- 2. items/title: 达成时直接发放的物品或称号；
-- 3. special: 不能直接映射到常规属性表、但面板和逻辑仍需展示/累计的特殊值。
-- 这样做的目的，是让成就达成时不再重新拆文案，而是直接消费结构化缓存。
local function _apply_detail_attr(rewardCfg, attrList)
    if type(attrList) ~= "table" or #attrList <= 0 then
        return rewardCfg
    end
    rewardCfg.attrs = {}
    rewardCfg.special = {}
    rewardCfg.realm_exp = nil
    for _, attr in ipairs(attrList) do
        local key = attr[1]
        local value = _toint(attr[2])
        if type(key) == "number" then
            _add_attr(rewardCfg.attrs, key, value)
        else
            key = tostring(key or "")
            if key == "realm_exp" then
                rewardCfg.realm_exp = (rewardCfg.realm_exp or 0) + value
            elseif key ~= "" then
                _push_special(rewardCfg.special, key, value)
            end
        end
    end
    return rewardCfg
end
local function _parse_reward(text)
    local cfg = {attrs = {}, items = {}, special = {}, raw = tostring(text or "")}
    for _, part in ipairs(_split_text(text)) do
        local itemName, itemNum = string.match(part, "^(.-)%*(%d+)$")
        if itemName and itemNum then
            cfg.items[#cfg.items + 1] = {itemName, _toint(itemNum)}
        elseif string.find(part, "^称号：") then
            cfg.title = string.gsub(part, "^称号：", "")
        elseif string.find(part, "宝箱") then
            cfg.items[#cfg.items + 1] = {part, 1}
        else
            local n = string.match(part, "^之后任何强化有(%d+)%%几率不消耗道具$")
            if n then
                _push_special(cfg.special, "strength_free", _reward_percent_value(n))
            else
                local atkMin, atkMax = string.match(part, "^攻击%+(%d+)%-(%d+)$")
                if atkMin and atkMax then
                    _add_attr(cfg.attrs, 3, atkMin)
                    _add_attr(cfg.attrs, 4, atkMax)
                else
                    n = string.match(part, "^攻击%+(%d+)$") or string.match(part, "^攻击力%+(%d+)$") or string.match(part, "^固定攻击%+(%d+)$")
                    if n then _add_attr(cfg.attrs, 4, n) end
                end
                n = string.match(part, "^攻魔道%+(%d+)$")
                if n then for _, id in ipairs({3,4,5,6,7,8}) do _add_attr(cfg.attrs, id, n) end end
                n = string.match(part, "^生命值%+(%d+)$") or string.match(part, "^固定生命%+(%d+)$")
                if n then _add_attr(cfg.attrs, 1, n) end
                n = string.match(part, "^固定魔法%+(%d+)$")
                if n then _add_attr(cfg.attrs, 2, n) end
                n = string.match(part, "^修为%+(%d+)$")
                if n then cfg.realm_exp = _toint(n) end
                local defMin, defMax = string.match(part, "^防御%+(%d+)%-(%d+)$")
                if defMin and defMax then
                    _add_attr(cfg.attrs, 8, defMin)
                    _add_attr(cfg.attrs, 9, defMax)
                else
                    n = string.match(part, "^防御%+(%d+)$")
                    if n then _add_attr(cfg.attrs, 9, n) end
                end
                n = string.match(part, "^对怪切割%+(.+)$") or string.match(part, "^打怪切割%+(.+)$")
                if n then _add_attr(cfg.attrs, 244, _parse_big_num(n)) end
                n = string.match(part, "^对怪固定吸血%+(%d+)$")
                if n then _add_attr(cfg.attrs, 81, n) end
                n = string.match(part, "^怪物格挡%+(%d+)$")
                if n then _add_attr(cfg.attrs, 255, n) end
                n = string.match(part, "^死亡爆装概率%-(%d+)%%$")
                if n then _add_attr(cfg.attrs, 33, _reward_percent_value(n)) end
                n = string.match(part, "^人缘%+(%d+)$")
                if n then _push_special(cfg.special, "popularity", n) end
                n = string.match(part, "^魅力%+(%d+)$")
                if n then _push_special(cfg.special, "charm", n) end
                local attrName, attrValue = string.match(part, "^(.-)%+(%d+)%%$")
                if attrName and attrValue and _reward_percent_attr[attrName] then _add_attr(cfg.attrs, _reward_percent_attr[attrName], _reward_percent_value(attrValue)) end
                local hurtValue = string.match(part, "^受到伤害%+(%d+)%%$")
                if hurtValue then _push_special(cfg.special, "hurt_taken_up", _reward_percent_value(hurtValue)) end
                local crossValue = string.match(part, "^对跨服怪物额外增伤%+(%d+)%%$")
                if crossValue then _push_special(cfg.special, "cross_mon_damage_up", _reward_percent_value(crossValue)) end
            end
        end
    end
    return cfg
end
local function _parse_milestone_reward(text)
    text = tostring(text or "")
    local title = string.match(text, "^称号：(.*)$")
    if title and title ~= "" then return {title = title} end
    local name, num = string.match(text, "^(.-)%*(%d+)$")
    if name and num then return {items = {{name, _toint(num)}}} end
    return text ~= "" and {items = {{text, 1}}} or {}
end
local function _build_reward_attr_list(rewardCfg) -- 组装成就属性展示数据
    local ret = {}
    for attrId, value in pairs((rewardCfg or {}).attrs or {}) do
        ret[#ret + 1] = {idx = _toint(attrId), value = _toint(value)}
    end
    for _, info in ipairs((rewardCfg or {}).special or {}) do
        ret[#ret + 1] = {key = tostring(info.key or ""), value = _toint(info.value)}
    end
    if _toint((rewardCfg or {}).realm_exp) > 0 then
        ret[#ret + 1] = {key = "realm_exp", value = _toint(rewardCfg.realm_exp)}
    end
    table.sort(ret, function(a, b) return tostring(a.idx or a.key or "") < tostring(b.idx or b.key or "") end)
    return ret
end
local function _build_reward_item_list(rewardCfg) -- 组装成就物品奖励展示数据
    local ret = {}
    for _, item in ipairs((rewardCfg or {}).items or {}) do
        ret[#ret + 1] = {name = tostring(item[1] or ""), count = _toint(item[2])}
    end
    return ret
end
local function _get_milestone_title_chain()
    local ret = {}
    for _, milestone in ipairs(_cfg.milestones or {}) do
        local rewardCfg = milestone.reward_cfg or {}
        local title = tostring(rewardCfg.title or "")
        if title ~= "" and string.find(title, "^成就卷轴Lv%.%d+$") then
            ret[#ret + 1] = {count = _toint(milestone.count), title = title}
        end
    end
    table.sort(ret, function(a, b) return a.count < b.count end)
    return ret
end
-- 里程碑称号发放有顺序约束。
-- 比如成就卷轴 Lv.2 不能跳过 Lv.1 直接领取，且同链路上只保留当前阶称号。
-- 这里专门处理：
-- 1. 前置里程碑是否已领取；
-- 2. 旧称号是否需要删除；
-- 3. 最终把目标称号发给玩家。
local function _grant_milestone_title(play, state, target, titleName)
    for _, node in ipairs(_get_milestone_title_chain()) do
        if node.count < target and _toint(state.milestone_claim[tostring(node.count)]) < 1 then
            return false, "请按顺序领取前置成就卷轴称号#57"
        end
    end
    for _, node in ipairs(_get_milestone_title_chain()) do
        if node.title ~= titleName and checktitle(play, node.title) then
            Player.title_del(play, node.title)
        end
    end
    Player.title_give(play, titleName)
    return true
end
-- 读取单条成就的规则配置。
-- 注意：这里不再根据 cond 文案做任何正则推导，cond 现在只是显示文本。
-- 如果某条成就忘了补 rule，会被标成 unknown，并在服务端打印，便于直接定位配置缺口。
local function _parse_condition(detail)
    local rule = type((detail or {}).rule) == "table" and detail.rule or {}
    if tostring(rule.kind or "") == "" then
        print("FairyFateMissingRule", tostring((detail or {}).id or 0), tostring((detail or {}).name or ""))
        return {kind = "unknown"}
    end
    return rule
end
-- 首次初始化时，把配置里的 rule/reward 预编译到运行缓存中。
-- 后续所有达成判定都只读缓存，避免每次事件触发都重新解析配置字符串。
local function _prepare()
    if _prepared then return end
    for _, detail in ipairs(_cfg.details or {}) do
        detail.rule = _parse_condition(detail)
        detail.reward_cfg = _parse_reward(detail.reward)
        _apply_detail_attr(detail.reward_cfg, detail.attr)
    end
    for _, milestone in ipairs(_cfg.milestones or {}) do milestone.reward_cfg = _parse_milestone_reward(milestone.reward) end
    _cfg_44 = Guard.getConfig("npc_44") or {}
    _prepared = true
end
-- 判断剧情类成就是否完成。
-- 剧情系统历史包袱比较重：有的剧情靠称号结算，有的靠数值节点，有的靠 table 结构写完成标记。
-- 所以这里做统一适配，把“剧情完成”抽象成一个布尔结果，供成就系统直接调用。
local function _story_complete(play, storyName)
    local keyMap = { ["重走西游"] = "npc_641", ["生肖守护"] = "npc_67", ["传说修复局"] = "npc_673" }
    local key = keyMap[storyName]
    if not key then return false end
    local cfg = teshudata and teshudata[key]
    if cfg and cfg.ch and checktitle(play, cfg.ch) then return true end
    local jqData = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local node = jqData[key]
    local maxNum = cfg and cfg.max_num
    if type(node) == "number" then if maxNum and maxNum > 0 then return node >= maxNum end return node >= 2 end
    if type(node) == "table" then
        if maxNum and maxNum > 0 and _toint(node.cnt or node.num) >= maxNum then return true end
        return _toint(node.wc) >= 1 or _toint(node.finish) >= 1 or _toint(node.done) >= 1 or _toint(node.ok) >= 1
    end
    return false
end
-- 判断当前地图是否属于“秘境”系列地图。
-- 这里同时看 mapid 和地图标题，是因为不同副本的底层命名不完全统一。
-- 该判断只影响 kill_secret 这类成就的累计分流，不影响普通大陆击杀统计。
local function _is_secret_map(play)
    local mapId = tostring(getbaseinfo(play, ConstCfg.gbase.mapid) or "")
    local title = tostring(getbaseinfo(play, ConstCfg.gbase.map_title) or "")
    if mapId == "特殊秘境副本二" or mapId == "特殊秘境副本三" then return true end
    return string.find(mapId, "秘境") ~= nil or string.find(title, "秘境") ~= nil
end
-- 统计背包神器数量。
-- 当前实现按 77~88 这组穿戴位扫描，只有格子里真的有物品名时才记为已拥有。
-- 这是快照阶段的数据来源，成就本身不保存该值，只在重算时即时读取。
local function _count_artifacts(play)
    -- 背包神器数量按 77~88 神器槽当前实际穿戴数量计算。
    -- 这里只看槽位是否有物品，不再额外校验名字，避免空名/改名物品造成漏算。
    return Player.countArtifactEquipSlots(play)
end
-- 取灵兽系统的“全体最低星级”。
-- 成就要求是“灵兽全部 X 星”，所以不是看最高星，也不是看总星数，
-- 而是 1~5 号灵兽里最低的那一只达到目标即可视为全体达标。
local function _get_pet_all_star(play)
    local data = Player.getJsonTableByVar(play, VarCfg["T_灵兽"])
    local minStar = 999
    for i = 1, 5 do local star = _toint((data.ls_sp or {})[tostring(i)]) if star <= 0 then return 0 end if star < minStar then minStar = star end end
    return minStar == 999 and 0 or minStar
end
-- 合并大陆击杀总数。
-- 数据来源分两层：
-- 1. state.counter.kill_dl: 本成就系统运行期累计；
-- 2. VarCfg.T_dlsgjl: 老系统/其他模块持久化的大陆杀怪记录。
-- 取两边最大值，是为了兼容历史数据，不让老玩家因为切换统计口径而丢进度。
local function _get_dl_kill_total(play, stateKillDl)
    local ret = {}
    local saved = Player.getJsonTableByVar(play, VarCfg.T_dlsgjl) or {}
    for i = 1, 6 do
        local key = tostring(i)
        ret[key] = math.max(_toint((stateKillDl or {})[key] or (stateKillDl or {})[i]), _toint(saved[key] or saved[i]))
    end
    return ret
end
-- 读取并整理仙途奇缘的存档结构。
-- 这里会保证 done / milestone_claim / counter / special 等关键字段一定存在，
-- 这样后面的逻辑就可以默认这些表可用，不必在每个地方再判空。
local function _get_state(play)
    local state = Player.getJsonTableByVar(play, VarCfg["T_仙途奇缘"])
    state.done = type(state.done) == "table" and state.done or {}
    state.milestone_claim = type(state.milestone_claim) == "table" and state.milestone_claim or {}
    state.counter = type(state.counter) == "table" and state.counter or {}
    state.counter.kill_dl = type(state.counter.kill_dl) == "table" and state.counter.kill_dl or {}
    state.counter.kill_secret = type(state.counter.kill_secret) == "table" and state.counter.kill_secret or {}
    state.special = type(state.special) == "table" and state.special or {}
    return state
end
-- 统一存档出口。
-- 所有会修改成就状态的逻辑，最终都应该通过这里落盘，避免未来改存储位置时需要全文件逐个替换。
local function _save_state(play, state) Player.setJsonVarByTable(play, VarCfg["T_仙途奇缘"], state) end
-- 构建一次完整的成就判定快照。
-- 这里会把“角色当前真实状态”和“成就系统自己累计的计数器”合并成统一视图，
-- 后面的 _reached 只和这份快照交互，避免每个条件都各自去查一遍玩家数据。
local function _build_snapshot(play, state)
    local linggen = Player.getJsonTableByVar(play, VarCfg["T_灵根"])
    linggen.level = linggen.level or {}
    local xianfu = Player.getJsonTableByVar(play, VarCfg.T_XianFuData)
    xianfu.stats = xianfu.stats or {}
    xianfu.refine = xianfu.refine or {collection = {}}
    local recipes = ((_cfg_44.RefineCfg or {}).recipes or {})
    local killDl = _get_dl_kill_total(play, state.counter.kill_dl)
    return {
        level = _toint(getbaseinfo(play, ConstCfg.gbase.level)), rebirth_stage = math.floor(_toint(getplaydef(play, VarCfg["U_转生等级"])) / 10),
        power = math.max(_toint(querymoney(play, 29)), _toint(getplaydef(play, VarCfg["B_记录战斗力"]))), tianshu_level = _toint((Player.getJsonTableByVar(play, VarCfg["T_天书"]) or {}).level),
        fashion_count = _count_true((Player.getJsonTableByVar(play, VarCfg.T_szjl) or {}).yjs or {}), linggen_count = _count_pairs(linggen.level), linggen_levels = linggen.level,
        realm_level = _toint(getplaydef(play, VarCfg["U_境界修炼"][1])), guild_joined = math.max(_toint(state.counter.guild_joined), _has_guild(play)),
        title_count = _count_pairs(gettitlelist(play)), artifact_count = _count_artifacts(play), woodcut_count = _toint((Player.getJsonTableByVar(play, VarCfg["T_砍树系统"]) or {}).num),
        kill_dl = killDl, kill_secret = state.counter.kill_secret, kill_cross_mon = _toint(state.counter.kill_cross_mon), chat_streak = _toint(state.counter.chat_streak),
        safe_death = _toint(state.counter.safe_death), enhance_fail_total = _toint(state.counter.enhance_fail_total), enhance_fail_streak = _toint(state.counter.enhance_fail_streak),
        mon_kill_without_damage = _toint(state.counter.mon_kill_without_damage), friend_count = _count_pairs(getfriendnamelist(play)), castle_win_once = _toint(state.counter.castle_win_once),
        recharge_total = math.max(_toint(querymoney(play, 23)), _toint(getplaydef(play, VarCfg["U_真实充值"]))), xianfu_xianghua = _toint(xianfu.stats.xiangHua),
        xianfu_refine_all = _count_true(xianfu.refine.collection) >= _count_pairs(recipes) and _count_pairs(recipes) > 0, pet_all_star = _get_pet_all_star(play),
        treasure_total = math.max(_toint(state.counter.treasure_total), _toint(getplaydef(play, VarCfg["U_藏宝图次数"]))), global_unique = math.max(_toint(state.counter.global_unique), _has_global_unique(play)),
        first_create_login = math.max(_is_first_create_login(play), _toint(state.counter.first_create_login)), auto_online = _toint(getplaydef(play, VarCfg.J_zxsj)),
        death_total = math.max(_toint(state.counter.death_total), _toint(getplaydef(play, VarCfg["U_被杀数"]))), player_kill_total = math.max(_toint(state.counter.player_kill_total), _toint(getplaydef(play, VarCfg.U_srsl)), _toint(getplaydef(play, VarCfg["U_杀人数"]))),
        revenge_total = _toint(state.counter.revenge_total), kill_kuangbao_total = math.max(_toint(state.counter.kill_kuangbao_total), _toint(getplaydef(play, VarCfg.U_jskb))), death_drop_total = _toint(state.counter.death_drop_total),
        loot_player_equip_total = _toint(state.counter.loot_player_equip_total), castle_first_blood = _toint(state.counter.castle_first_blood), castle_kill_total = _toint(state.counter.castle_kill_total), palace_streak = _toint(state.counter.palace_best),
        bwdh_kill_total = _toint(state.counter.bwdh_kill_total), collateral_death = _toint(state.counter.collateral_death), one_hit_killed = _toint(state.counter.one_hit_killed), one_hit_kill = _toint(state.counter.one_hit_kill),
        story_complete = function(storyName) return _story_complete(play, storyName) end,
    }
end
-- 按 rule.kind 执行最终比较。
-- rule 负责描述“判定什么”，snapshot/counter 负责提供“当前值是多少”。
-- 两者分离后，后续新增成就时只需要补配置和少量 kind 分支，不需要再碰 cond 文案。
local function _reached(play, state, snap, detail)
    local r = detail.rule or {}
    local kind = r.kind
    if kind == "level" then return snap.level >= r.target end
    if kind == "rebirth_stage" then return snap.rebirth_stage >= r.target end
    if kind == "power" then return snap.power >= r.target end
    if kind == "tianshu_level" then return snap.tianshu_level >= r.target end
    if kind == "fashion_count" then return snap.fashion_count >= r.target end
    if kind == "linggen_count" then return snap.linggen_count >= r.target end
    if kind == "linggen_group" then for _, idx in ipairs(r.list or {}) do if snap.linggen_levels[tostring(idx)] == nil then return false end end return true end
    if kind == "linggen_level" then return _toint(snap.linggen_levels[tostring(r.idx)]) >= r.target end
    if kind == "realm_up" then return _toint(state.counter.realm_up) >= r.target or snap.realm_level > 0 end
    if kind == "realm_level" then return snap.realm_level >= r.target end
    if kind == "guild_joined" then return snap.guild_joined >= r.target end
    if kind == "title_count" then return snap.title_count >= r.target end
    if kind == "artifact_count" then return snap.artifact_count >= r.target end
    if kind == "woodcut_count" then return snap.woodcut_count >= r.target end
    if kind == "kill_dl" then return _toint(snap.kill_dl[tostring(r.dl)] or snap.kill_dl[r.dl]) >= r.target end
    if kind == "kill_secret" then return _toint(snap.kill_secret[tostring(r.dl)] or snap.kill_secret[r.dl]) >= r.target end
    if kind == "kill_cross_mon" then return snap.kill_cross_mon >= r.target end
    if kind == "chat_streak" then return snap.chat_streak >= r.target end
    if kind == "safe_death" then return snap.safe_death >= r.target end
    if kind == "enhance_fail_total" then return snap.enhance_fail_total >= r.target end
    if kind == "enhance_fail_streak" then return snap.enhance_fail_streak >= r.target end
    if kind == "mon_kill_without_damage" then return snap.mon_kill_without_damage >= r.target end
    if kind == "friend_count" then return snap.friend_count >= r.target end
    if kind == "castle_win_once" then return snap.castle_win_once >= r.target end
    if kind == "recharge_total" then return snap.recharge_total >= r.target end
    if kind == "story_complete" then return snap.story_complete(r.name) end
    if kind == "xianfu_xianghua" then return snap.xianfu_xianghua >= r.target end
    if kind == "xianfu_refine_all" then return snap.xianfu_refine_all end
    if kind == "pet_all_star" then return snap.pet_all_star >= r.target end
    if kind == "treasure_total" then return snap.treasure_total >= r.target end
    if kind == "global_unique" then return snap.global_unique >= r.target end
    if kind == "first_create_login" then return snap.first_create_login >= r.target end
    if kind == "auto_online" then return snap.auto_online >= r.target end
    if kind == "death_total" then return snap.death_total >= r.target end
    if kind == "player_kill_total" then return snap.player_kill_total >= r.target end
    if kind == "revenge_total" then return snap.revenge_total >= r.target end
    if kind == "kill_kuangbao_total" then return snap.kill_kuangbao_total >= r.target end
    if kind == "death_drop_total" then return snap.death_drop_total >= r.target end
    if kind == "loot_player_equip_total" then return snap.loot_player_equip_total >= r.target end
    if kind == "castle_first_blood" then return snap.castle_first_blood >= r.target end
    if kind == "castle_kill_total" then return snap.castle_kill_total >= r.target end
    if kind == "palace_streak" then return snap.palace_streak >= r.target end
    if kind == "bwdh_kill_total" then return snap.bwdh_kill_total >= r.target end
    if kind == "collateral_death" then return snap.collateral_death >= r.target end
    if kind == "one_hit_killed" then return snap.one_hit_killed >= r.target end
    if kind == "one_hit_kill" then return snap.one_hit_kill >= r.target end
    return false
end
-- 老版 515 面板仍然读 state["1"], state["2"] 这种平铺字段。
-- 新版服务端内部已经切到 state.done[id]，所以这里做一次兼容回写：
-- 1. 优先按配置里的 legacy_idx 精确回写，避免名称改动导致老面板失联。
-- 2. 没配 legacy_idx 的老槽位，再退回到名称匹配，兼容历史数据。
local function _sync_legacy_panel_flags(state)
    local legacy = ((teshudata or {})["anniu_515"] or {}).details or {}
    local nameDone = {}
    local mapped = {}
    for _, detail in ipairs(_cfg.details or {}) do
        local done = _toint((state.done or {})[tostring(detail.id)]) >= 1 and 1 or 0
        local legacyIdx = _toint(detail.legacy_idx)
        if done > 0 then
            nameDone[tostring(detail.name or "")] = 1
        end
        if legacyIdx > 0 then
            local key = tostring(legacyIdx)
            mapped[key] = 1
            state[key] = done > 0 and 1 or nil
        end
    end
    for idx, info in pairs(legacy) do
        local key = tostring(idx)
        if mapped[key] == nil then
            local name = tostring((info or {}).tt or "")
            if name ~= "" then
                if _toint(nameDone[name]) >= 1 then
                    state[key] = 1
                else
                    state[key] = nil
                end
            end
        end
    end
end
-- 根据当前已完成成就，重新汇总最终属性列表。
-- 注意这里不是“本次新达成奖励”，而是“所有已达成成就的总和重算”：
-- 1. attrs 会挂到 Player.add_attlist；
-- 2. special 会缓存到 state.special，给面板显示和其他逻辑读取；
-- 3. 如果玩家失去某个成就资格，重算后属性也会自然回退。
local function _refresh_attr(play, state)
    local attrs, special = {}, {}
    for _, detail in ipairs(_cfg.details or {}) do
        if _toint(state.done[tostring(detail.id)]) >= 1 then
            for attrId, value in pairs((detail.reward_cfg or {}).attrs or {}) do attrs[attrId] = (attrs[attrId] or 0) + _toint(value) end
            for _, info in ipairs((detail.reward_cfg or {}).special or {}) do special[info.key] = (special[info.key] or 0) + _toint(info.value) end
        end
    end
    local attrsStr = Player.getAttrTableToStr(attrs)
    if attrsStr and attrsStr ~= "" then Player.add_attlist(play, _attr_list_name, "=", attrsStr, 1) else Player.del_attlist(play, _attr_list_name) end
    state.special = special
end
-- 扫描全部成就。
-- 这里不负责累计计数，计数由各类事件先写进 state.counter；
-- _evaluate 只负责拿快照逐条比较，达成后发奖、落盘、刷新属性。
local function _evaluate(play, state) -- 扫描全部成就条件，达成后即时发奖励与提示
    local snap = _build_snapshot(play, state)
    local changed = false
    for _, detail in ipairs(_cfg.details or {}) do
        local key = tostring(detail.id)
        if _toint(state.done[key]) < 1 and _reached(play, state, snap, detail) then
            state.done[key] = 1
            if detail.reward_cfg and detail.reward_cfg.items and #detail.reward_cfg.items > 0 then Player.rwjl(play, detail.reward_cfg.items, "仙途奇缘成就", 1, 0) end
            if detail.reward_cfg and detail.reward_cfg.title and detail.reward_cfg.title ~= "" then Player.title_give(play, detail.reward_cfg.title) end
            if detail.reward_cfg and _toint(detail.reward_cfg.realm_exp) > 0 then
                setplaydef(play, VarCfg["U_境界修炼"][2], _toint(getplaydef(play, VarCfg["U_境界修炼"][2])) + _toint(detail.reward_cfg.realm_exp))
            end
            -- Player.sendmsgEx(play, "恭喜达成|【" .. tostring(detail.name or detail.id) .. "】#249|成就")
            sendluamsg(play, 101, 515, 2, _toint(detail.id), tbl2json({id = detail.id, name = detail.name, reward = detail.reward, tip = "达成成就[" .. tostring(detail.name or detail.id) .. "]"}))
            -- 成就完成后额外通知 1005 小界面，传递本次成就 id/名称
            changed = true
        end
    end
    if changed then _refresh_attr(play, state) end
    return changed
end
-- 已完成成就数量。
-- 这个值主要给里程碑奖励和客户端数量展示使用。
local function _done_count(state) return _count_true(state.done) end
-- 组装“假属性”展示列表。
-- 这类值不一定直接参与战斗属性换算，但客户端面板仍然需要展示给玩家看。
-- 例如跨服额外增伤、人缘、魅力，都走这里转成统一显示结构。
local function _build_fake_attr(special)
    local ret = {}
    for key, cfg in pairs(_fake_attr_cfg) do
        local value = _toint((special or {})[key])
        if value > 0 then
            local showValue = cfg.percent and (value / 100) or value
            local text = cfg.percent and (cfg.name .. "+" .. tostring(showValue) .. "%") or (cfg.name .. "+" .. tostring(showValue))
            ret[#ret + 1] = {key = key, name = cfg.name, value = showValue, raw = value, percent = cfg.percent and 1 or 0, text = text}
        end
    end
    table.sort(ret, function(a, b) return tostring(a.key) < tostring(b.key) end)
    return ret
end
-- 下发给客户端的运行时数据。
-- 这里只传“玩家当前状态”，不再传整套成就配置：
-- 1. 配置由客户端本地副本负责；
-- 2. 服务端只负责传达成状态、特殊属性和少量实时数值；
-- 3. 这样可以减少传输量，也避免服务端配置被客户端直接依赖。
local function _payload(play, state) -- 仅传运行态数据，客户端配置走本地副本
    local special = state.special or {}
    local snap = _build_snapshot(play, state)
    return {T_data = state, done_count = _done_count(state), special = special, fake_attr = _build_fake_attr(special), now = {level = snap.level, power = snap.power}}
end
-- 成就系统的统一刷新入口。
-- 所有事件最终都会汇聚到这里，处理顺序固定为：
-- 1. 先执行 updater，把本次事件对应的 counter 改掉；
-- 2. 再做历史脏数据纠偏；
-- 3. 然后跑 _evaluate 看是否有新成就完成；
-- 4. 最后按需要同步旧面板、刷新属性并落盘。
-- 统一入口的好处是，后续排查问题时只要看这里，就能知道一次事件完整走了哪些阶段。
local function _touch(play, updater, refresh)
    if not play then return end
    _prepare()
    local state = _get_state(play)
    local changed = updater and updater(state) or false
    if _normalize_unique_done(play, state) then changed = true end
    if _normalize_recharge_done(play, state) then changed = true end
    local unlocked = _evaluate(play, state)
    if changed or unlocked or refresh then _sync_legacy_panel_flags(state) _refresh_attr(play, state) _save_state(play, state) end
end
-- 515 主入口。
-- p2/p3 的语义：
-- 1. p2 == 1: 领取里程碑数量奖励；
-- 2. 其他情况: 仅打开/刷新面板；
-- msgData 主要用于兼容部分客户端把目标数量包在 json 里传上来的情况。
function FairyFate.handle(play, p2, p3, msgData) -- 515主入口：打开面板/领取数量奖励/领取单项奖励
    _prepare()
    local state = _get_state(play)
    if _toint(p2) == 1 then
        local target = _toint(p3)
        if target <= 0 and msgData and msgData ~= "" then local ok, data = pcall(json2tbl, msgData) if ok and type(data) == "table" then target = _toint(data.count or data.idx or data.id) end end
        for _, milestone in ipairs(_cfg.milestones or {}) do
            if _toint(milestone.count) == target then
                if _toint(state.milestone_claim[tostring(target)]) >= 1 then Player.sendmsgEx(play, "该成就数量奖励已领取#57") return end
                if _done_count(state) < target then Player.sendmsgEx(play, "当前成就数量不足，无法领取#57") return end
                if milestone.reward_cfg and milestone.reward_cfg.title and milestone.reward_cfg.title ~= "" then local ok, err = _grant_milestone_title(play, state, target, milestone.reward_cfg.title) if not ok then Player.sendmsgEx(play, err or "称号领取失败#57") return end end
                if milestone.reward_cfg and milestone.reward_cfg.items and #milestone.reward_cfg.items > 0 then Player.rwjl(play, milestone.reward_cfg.items, "仙途奇缘里程碑", 1, 0) end
                state.milestone_claim[tostring(target)] = 1
                _sync_legacy_panel_flags(state)
                _save_state(play, state)
                sendluamsg(play, 101, 515, 1, target, tbl2json(_payload(play, state)))
                return
            end
        end
        Player.sendmsgEx(play, "奖励不存在#57")
        return
    end
    _evaluate(play, state)
    _sync_legacy_panel_flags(state)
    _refresh_attr(play, state)
    _save_state(play, state)
    sendluamsg(play, 101, 515, _toint(p2), _toint(p3), tbl2json(_payload(play, state)))
end
-- 提供给强化系统读取“强化免耗概率”。
-- 这个值本质来自成就 reward.special 的累计结果，所以每次取值前都会先刷新一次属性缓存。
function FairyFate.getStrengthFreeChance(play)
    _prepare()
    local state = _get_state(play)
    _refresh_attr(play, state)
    return _toint((state.special or {}).strength_free)
end
-- 对外暴露的事件写入口。
-- 外部模块不要直接改 state.counter，而是统一调用 FairyFate.touch：
-- 1. reason 决定本次属于哪种行为；
-- 2. a/b 作为附加参数传给对应分支；
-- 3. 最终还是回到 _touch 完成整轮重算。
function FairyFate.touch(play, reason, a, b)
    if reason == "treasure" then
        _touch(play, function(state) state.counter.treasure_total = _toint(state.counter.treasure_total) + _toint(a ~= nil and a or 1) return true end, true)
    elseif reason == "realm_up" then
        _touch(play, function(state) state.counter.realm_up = _toint(state.counter.realm_up) + 1 return true end, true)
    elseif reason == "strength_fail" then
        _touch(play, function(state) state.counter.enhance_fail_total = _toint(state.counter.enhance_fail_total) + 1 state.counter.enhance_fail_streak = _toint(state.counter.enhance_fail_streak) + 1 return true end, true)
    elseif reason == "strength_success" then
        _touch(play, function(state) if _toint(state.counter.enhance_fail_streak) > 0 then state.counter.enhance_fail_streak = 0 return true end return false end, true)
    elseif reason == "woodcut" then
        _touch(play, function(state) state.counter.woodcut_count = _toint(state.counter.woodcut_count) + _toint(a ~= nil and a or 1) return true end, true)
    elseif reason == "global_unique" then
        _touch(play, function(state)
            local cur = _has_global_unique(play)
            if cur > _toint(state.counter.global_unique) then
                state.counter.global_unique = cur
                return true
            end
            return false
        end, true)
    -- kill_mon 比较特殊：
    -- 1. 要同时更新大陆击杀、秘境击杀、跨服击杀三套计数；
    -- 2. 还要同步写回 T_dlsgjl，兼容历史统计口径；
    -- 3. 所以这里单独展开，不走简单的 +1 模板。
    elseif reason == "kill_mon" then
        _touch(play, function(state)
            local mapId = tostring(a or getbaseinfo(play, 3) or "")
            local dl = _toint(daluditu and daluditu[mapId])
            local changed = false
            if dl >= 1 and dl <= 6 then
                local key = tostring(dl)
                state.counter.kill_dl[key] = _toint(state.counter.kill_dl[key]) + 1
                local dlData = Player.getJsonTableByVar(play, VarCfg.T_dlsgjl) or {}
                dlData[key] = _toint(dlData[key] or dlData[dl]) + 1
                Player.setJsonVarByTable(play, VarCfg.T_dlsgjl, dlData)
                if _is_secret_map(play) then
                    state.counter.kill_secret[key] = _toint(state.counter.kill_secret[key]) + 1
                end
                changed = true
            end
            if checkkuafu(play) then
                state.counter.kill_cross_mon = _toint(state.counter.kill_cross_mon) + 1
                changed = true
            end
            return changed
        end, false)
    elseif reason == "linggen" or reason == "pet" or reason == "title" or reason == "fashion_unlock" or reason == "story" or reason == "xianfu" then
        _touch(play, nil, true)
    else
        _touch(play, nil, true)
    end
end

-- 事件绑定区：
-- 1. 事件层只负责记录行为，不直接判断成就是否完成。
-- 2. 登录时会补判一次行会首入，避免老角色已经入会但没经过当前事件链。
-- 3. 真正通过 guildaddmemberafter 入会时，QFunction-0.lua 会推送 goGuild/onGuildAddMemberAfter，两边都会落到这里的统一重算。
GameEvent.add(EventCfg.onLogin, function(play) _touch(play, function(state) if _toint(state.counter.guild_joined) <= 0 and _has_guild(play) > 0 then state.counter.guild_joined = 1 return true end return false end, true) end, "仙途奇缘")
GameEvent.add(EventCfg.onKFLogin, function(play) _touch(play, nil, true) end, "仙途奇缘")
GameEvent.add(EventCfg.onLoginEnd, function(play) _touch(play, nil, true) end, "仙途奇缘")
GameEvent.add(EventCfg.onSendAbility, function(play) _touch(play, nil, false) end, "仙途奇缘")
GameEvent.add(EventCfg.onProHarm, function(play, harm) _touch(play, function(state) local curHp = _toint(getbaseinfo(play, ConstCfg.gbase.curhp)) if _toint(harm) >= curHp and curHp > 0 then state.counter.one_hit_killed_pending = 1 return true end return false end, false) end, "仙途奇缘")
GameEvent.add(EventCfg.onAttackDamagePlayer, function(play, target, damage) _touch(play, function(state) if type(target) == "string" and getbaseinfo(target, ConstCfg.gbase.isplayer) and _toint(damage) >= _toint(getbaseinfo(target, ConstCfg.gbase.curhp)) and _toint(getbaseinfo(target, ConstCfg.gbase.curhp)) > 0 then state.counter.one_hit_kill_pending = 1 return true end return false end, false) end, "仙途奇缘")
GameEvent.add(EventCfg.onAttackDamageMonster, function(play) _touch(play, function(state) state.counter.life_hurt_mon = 1 state.counter.last_attack_mon_at = os.time() return true end, false) end, "仙途奇缘")
GameEvent.add(EventCfg.onKillMon, function(play, mob, mobIdx) end, "仙途奇缘")
GameEvent.add(EventCfg.onkillplay, function(play, target) _touch(play, function(state) state.counter.player_kill_total = math.max(_toint(state.counter.player_kill_total) + 1, _toint(getplaydef(play, VarCfg.U_srsl))) if _toint(state.counter.one_hit_kill_pending) > 0 then state.counter.one_hit_kill = _toint(state.counter.one_hit_kill) + 1 state.counter.one_hit_kill_pending = 0 end if state.counter.revenge_target ~= "" and state.counter.revenge_target == tostring(getbaseinfo(target, ConstCfg.gbase.name) or "") then state.counter.revenge_target = "" state.counter.revenge_total = _toint(state.counter.revenge_total) + 1 end if checktitle(target, "狂暴之力") then state.counter.kill_kuangbao_total = math.max(_toint(state.counter.kill_kuangbao_total) + 1, _toint(getplaydef(play, VarCfg.U_jskb))) end if castleinfo and castleinfo(5) and getbaseinfo(play, ConstCfg.gbase.issbk) then state.counter.castle_kill_total = _toint(state.counter.castle_kill_total) + 1 if tostring(getsysvarex(_sys_castle_first_blood_key) or "") == "" then setsysvarex(_sys_castle_first_blood_key, tostring(getbaseinfo(play, ConstCfg.gbase.name) or ""), true) state.counter.castle_first_blood = 1 end local mapId = tostring(getbaseinfo(play, ConstCfg.gbase.mapid) or "") if mapId == "new0150" or mapId == "kuafu0150" then state.counter.palace_current = _toint(state.counter.palace_current) + 1 if _toint(state.counter.palace_current) > _toint(state.counter.palace_best) then state.counter.palace_best = state.counter.palace_current end end end local kqfz = _toint(getsysvar(constant.G_kqfz)) if kqfz >= 40 and kqfz <= 50 then state.counter.bwdh_kill_total = _toint(state.counter.bwdh_kill_total) + 1 end return true end, false) end, "仙途奇缘")
GameEvent.add(EventCfg.onPlaydie, function(play, killer) _touch(play, function(state) state.counter.death_total = _toint(state.counter.death_total) + 1 if getbaseinfo(play, ConstCfg.gbase.issaferect) then state.counter.safe_death = _toint(state.counter.safe_death) + 1 end state.counter.palace_current = 0 if killer and getbaseinfo(killer, ConstCfg.gbase.isplayer) then state.counter.revenge_target = tostring(getbaseinfo(killer, ConstCfg.gbase.name) or "") if _toint(state.counter.one_hit_killed_pending) > 0 then state.counter.one_hit_killed = _toint(state.counter.one_hit_killed) + 1 state.counter.one_hit_killed_pending = 0 end if os.time() - _toint(state.counter.last_attack_mon_at) <= 3 then state.counter.collateral_death = _toint(state.counter.collateral_death) + 1 end else if _toint(state.counter.life_hurt_mon) <= 0 then state.counter.mon_kill_without_damage = _toint(state.counter.mon_kill_without_damage) + 1 end state.counter.revenge_target = "" state.counter.one_hit_killed_pending = 0 end state.counter.life_hurt_mon = 0 return true end, false) end, "仙途奇缘")
GameEvent.add(EventCfg.onTriggerChat, function(play, text) _touch(play, function(state) state.counter.chat_streak = _toint(state.counter.chat_streak) + 1 return true end, false) end, "仙途奇缘")
GameEvent.add(EventCfg.goSwitchMap, function(play) _touch(play, function(state) local mapId = tostring(getbaseinfo(play, ConstCfg.gbase.mapid) or "") if mapId ~= "new0150" and mapId ~= "kuafu0150" and _toint(state.counter.palace_current) > 0 then state.counter.palace_current = 0 return true end return false end, false) end, "仙途奇缘")
-- goGuild / onGuildAddMemberAfter 都会落到同一个 counter，
-- 原因是底层不同入口可能推不同事件名，但对成就系统来说语义都是“玩家完成了首次入会”。
GameEvent.add(EventCfg.goGuild, function(play) _touch(play, function(state) if _toint(state.counter.guild_joined) <= 0 then state.counter.guild_joined = 1 return true end return false end, true) end, "仙途奇缘")
GameEvent.add(EventCfg.onGuildAddMemberAfter, function(play) _touch(play, function(state) if _toint(state.counter.guild_joined) <= 0 then state.counter.guild_joined = 1 return true end return false end, true) end, "仙途奇缘")
GameEvent.add(EventCfg.onGetTaskTitle, function(play) _touch(play, nil, true) end, "仙途奇缘")
GameEvent.add(EventCfg.onRenewlevelUP, function(play) _touch(play, nil, true) end, "仙途奇缘")
GameEvent.add(EventCfg.onUPSkin, function(play) _touch(play, nil, true) end, "仙途奇缘")
GameEvent.add(EventCfg.GetCastleRewards, function(play) _touch(play, function(state) if _toint(state.counter.castle_win_once) > 0 then return false end state.counter.castle_win_once = 1 return true end, true) end, "仙途奇缘")
GameEvent.add(EventCfg.onRechargeEnd, function(play) _touch(play, nil, false) end, "仙途奇缘")
GameEvent.add(EventCfg.onNewHuman, function(play) if tostring(getsysvarex(_sys_first_login_key) or "") == "" then setsysvarex(_sys_first_login_key, tostring(getbaseinfo(play, ConstCfg.gbase.name) or ""), true) _touch(play, function(state) state.counter.first_create_login = 1 return true end, true) end end, "仙途奇缘")
GameEvent.add(EventCfg.onTakeOnEx, function(play) _touch(play, nil, false) end, "仙途奇缘")
GameEvent.add(EventCfg.onTakeOffEx, function(play) _touch(play, nil, false) end, "仙途奇缘")
GameEvent.add(EventCfg.onCheckDropUseItems, function(play) _touch(play, function(state) state.counter.death_drop_total = _toint(state.counter.death_drop_total) + 1 return true end, false) end, "仙途奇缘")
GameEvent.add(EventCfg.gocastlewarstart, function() setsysvarex(_sys_castle_first_blood_key, "", true) end, "仙途奇缘")
return FairyFate
