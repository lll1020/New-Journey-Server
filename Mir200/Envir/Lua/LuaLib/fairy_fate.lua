FairyFate = FairyFate or {}
local _cfg = include("lua/Data/fairy_fate_cfg.lua") or {}
if type(_cfg.name) ~= "string" or _cfg.name == "" or string.find(_cfg.name, "%?") then _cfg.name = "仙途奇缘" end
_cfg.groups = (type(_cfg.groups) == "table" and #_cfg.groups > 0) and _cfg.groups or {"总览","角色","PVE","PVP","其他"}
local _attr_list_name = "仙途奇缘成就" -- 属性列表名：已达成成就换算后的最终属性挂载点
local _sys_first_login_key = "FF_仙途奇缘_首个注册" -- 系统变量：记录全服首个注册成就是否已触发
local _sys_castle_first_blood_key = "FF_仙途奇缘_攻沙首杀" -- 系统变量：记录攻沙首杀成就是否已触发
local _prepared = false -- 配置缓存是否已初始化
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
local function _parse_big_num(text)
    text = tostring(text or "")
    local n = tonumber(text)
    if n then return n end
    local raw = string.lower(text)
    local base = tonumber((raw:gsub("w", ""))) or 0
    if string.find(raw, "w") then return base * 10000 end
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
                if n then _add_attr(cfg.attrs, 248, n) end
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
local function _parse_condition(detail)
    local cond = tostring(detail.cond or "")
    local name = tostring(detail.name or "")
    local prefix = string.match(name, "^(.-)Lv%.%d+") or name
    local n = string.match(cond, "^角色等级达到：(%d+)级$")
    if n then return {kind = "level", target = _toint(n)} end
    n = string.match(cond, "^角色完成(%d+)大陆转生$")
    if n then return {kind = "rebirth_stage", target = _toint(n)} end
    n = string.match(cond, "^战斗力达到(.+)$")
    if n then return {kind = "power", target = _parse_big_num(n)} end
    n = string.match(cond, "^天书等级达到(%d+)级$")
    if n then return {kind = "tianshu_level", target = _toint(n)} end
    n = string.match(cond, "^累计收集(%d+)个不同的装扮$")
    if n then return {kind = "fashion_count", target = _toint(n)} end
    n = string.match(cond, "^激活(%d+)个灵根$")
    if n then return {kind = "linggen_count", target = _toint(n)} end
    if cond == "激活金木水火土灵根" then return {kind = "linggen_group", list = {1,2,3,4,5}} end
    if cond == "激活雷风冰焚岩灵根" then return {kind = "linggen_group", list = {6,7,8,9,10}} end
    if cond == "X灵根等级达到10级" then return {kind = "linggen_level", idx = _linggen_name_index[string.sub(prefix, 1, 1)], target = 10} end
    if cond == "第一次提升境界" then return {kind = "realm_up", target = 1} end
    if cond == "境界达到X境" then return {kind = "realm_level", target = _realm_name_level[name] or 0} end
    if cond == "第一次加入行会" then return {kind = "guild_joined", target = 1} end
    n = string.match(cond, "^累计获得(%d+)个称号$")
    if n then return {kind = "title_count", target = _toint(n)} end
    n = string.match(cond, "^累计获得(%d+)个背包神器$")
    if n then return {kind = "artifact_count", target = _toint(n)} end
    n = string.match(cond, "^累计砍树(%d+)次$")
    if n then return {kind = "woodcut_count", target = _toint(n)} end
    local dlText, countText = string.match(cond, "^击杀([一二三四五六])大陆怪物(%d+)只$")
    if dlText and countText then
        local dlMap = { ["一"] = 1, ["二"] = 2, ["三"] = 3, ["四"] = 4, ["五"] = 5, ["六"] = 6 }
        return {kind = "kill_dl", dl = dlMap[dlText] or 0, target = _toint(countText)}
    end
    countText = string.match(cond, "^击杀极光秘境中怪物(%d+)只$")
    if countText then return {kind = "kill_secret", dl = 2, target = _toint(countText)} end
    countText = string.match(cond, "^击杀XX秘境中怪物(%d+)只$")
    if countText then return {kind = "kill_secret", dl = _secret_name_dl[prefix] or 0, target = _toint(countText)} end
    countText = string.match(cond, "^击杀跨服怪物(%d+)只$")
    if countText then return {kind = "kill_cross_mon", target = _toint(countText)} end
    if cond == "在世界频道连续发言50次" then return {kind = "chat_streak", target = 50} end
    if cond == "在安全区死亡" then return {kind = "safe_death", target = 1} end
    if cond == "强化失败1次" then return {kind = "enhance_fail_total", target = 1} end
    n = string.match(cond, "^连续强化失败(%d+)次$")
    if n then return {kind = "enhance_fail_streak", target = _toint(n)} end
    if cond == "被怪物打死时，自己没有造成任何伤害" then return {kind = "mon_kill_without_damage", target = 1} end
    n = string.match(cond, "^拥有(%d+)个好友$")
    if n then return {kind = "friend_count", target = _toint(n)} end
    if cond == "第一次攻沙胜利时" then return {kind = "castle_win_once", target = 1} end
    n = string.match(cond, "^累计充值(.+)$")
    if n then return {kind = "recharge_total", target = _parse_big_num(n)} end
    local story = string.match(cond, "^完成剧情%[(.+)%]$")
    if story then return {kind = "story_complete", name = story} end
    n = string.match(cond, "^仙府仙华值达到：(%d+)$")
    if n then return {kind = "xianfu_xianghua", target = _toint(n)} end
    if cond == "炼制全部丹药各1次" then return {kind = "xianfu_refine_all"} end
    n = string.match(cond, "^灵兽全部(%d+)星$")
    if n then return {kind = "pet_all_star", target = _toint(n)} end
    n = string.match(cond, "^藏宝图寻宝累计(%d+)次$")
    if n then return {kind = "treasure_total", target = _toint(n)} end
    if cond == "获得1件全服孤品" then return {kind = "global_unique", target = 1} end
    if cond == "全服第一个注册登陆上线" then return {kind = "first_create_login", target = 1} end
    if cond == "连续挂机10小时" then return {kind = "auto_online", target = 600} end
    n = string.match(cond, "^累计死亡(%d+)次$")
    if n then return {kind = "death_total", target = _toint(n)} end
    n = string.match(cond, "^击杀玩家(%d+)次$")
    if n then return {kind = "player_kill_total", target = _toint(n)} end
    n = string.match(cond, "^死亡后成功复仇击杀者(%d+)次$")
    if n then return {kind = "revenge_total", target = _toint(n)} end
    n = string.match(cond, "^击杀狂暴玩家(%d+)次$")
    if n then return {kind = "kill_kuangbao_total", target = _toint(n)} end
    n = string.match(cond, "^死亡爆装(%d+)次$")
    if n then return {kind = "death_drop_total", target = _toint(n)} end
    n = string.match(cond, "^爆出别人装备(%d+)次$")
    if n then return {kind = "loot_player_equip_total", target = _toint(n)} end
    if cond == "攻沙时，第一个击杀玩家" then return {kind = "castle_first_blood", target = 1} end
    n = string.match(cond, "^攻沙期间，击杀(%d+)名玩家$")
    if n then return {kind = "castle_kill_total", target = _toint(n)} end
    n = string.match(cond, "^在皇宫内，连续击杀(%d+)名玩家，中途没死亡、回城$")
    if n then return {kind = "palace_streak", target = _toint(n)} end
    n = string.match(cond, "^跨服武道大会活动中，击杀(%d+)名玩家$")
    if n then return {kind = "bwdh_kill_total", target = _toint(n)} end
    if cond == "其他玩家攻击目标是怪物时，顺手把你杀死，概率获得" then return {kind = "collateral_death", target = 1} end
    if cond == "被其他玩家1刀击杀" then return {kind = "one_hit_killed", target = 1} end
    if cond == "一刀杀死其他玩家" then return {kind = "one_hit_kill", target = 1} end
    return {kind = "unknown"}
end
local function _prepare()
    if _prepared then return end
    for _, detail in ipairs(_cfg.details or {}) do detail.rule = _parse_condition(detail) detail.reward_cfg = _parse_reward(detail.reward) end
    for _, milestone in ipairs(_cfg.milestones or {}) do milestone.reward_cfg = _parse_milestone_reward(milestone.reward) end
    _cfg_44 = Guard.getConfig("npc_44") or {}
    _prepared = true
end
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
local function _is_secret_map(play)
    local mapId = tostring(getbaseinfo(play, ConstCfg.gbase.mapid) or "")
    local title = tostring(getbaseinfo(play, ConstCfg.gbase.map_title) or "")
    if mapId == "特殊秘境副本二" or mapId == "特殊秘境副本三" then return true end
    return string.find(mapId, "秘境") ~= nil or string.find(title, "秘境") ~= nil
end
local function _count_artifacts(play)
    local n = 0
    for where = 77, 88 do local itemobj = linkbodyitem(play, where) if itemobj and itemobj ~= "0" and getiteminfo(play, itemobj, 7) ~= "" then n = n + 1 end end
    return n
end
local function _get_pet_all_star(play)
    local data = Player.getJsonTableByVar(play, VarCfg["T_灵兽"])
    local minStar = 999
    for i = 1, 5 do local star = _toint((data.ls_sp or {})[tostring(i)]) if star <= 0 then return 0 end if star < minStar then minStar = star end end
    return minStar == 999 and 0 or minStar
end
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
local function _save_state(play, state) Player.setJsonVarByTable(play, VarCfg["T_仙途奇缘"], state) end
local function _build_snapshot(play, state)
    local linggen = Player.getJsonTableByVar(play, VarCfg["T_灵根"])
    linggen.level = linggen.level or {}
    local xianfu = Player.getJsonTableByVar(play, VarCfg.T_XianFuData)
    xianfu.stats = xianfu.stats or {}
    xianfu.refine = xianfu.refine or {collection = {}}
    local recipes = ((_cfg_44.RefineCfg or {}).recipes or {})
    return {
        level = _toint(getbaseinfo(play, ConstCfg.gbase.level)), rebirth_stage = math.floor(_toint(getplaydef(play, VarCfg["U_转生等级"])) / 10),
        power = math.max(_toint(querymoney(play, 29)), _toint(getplaydef(play, VarCfg["B_记录战斗力"]))), tianshu_level = _toint((Player.getJsonTableByVar(play, VarCfg["T_天书"]) or {}).level),
        fashion_count = _count_true((Player.getJsonTableByVar(play, VarCfg.T_szjl) or {}).yjs or {}), linggen_count = _count_pairs(linggen.level), linggen_levels = linggen.level,
        realm_level = _toint(getplaydef(play, VarCfg["U_境界修炼"][1])), guild_joined = math.max(_toint(state.counter.guild_joined), tostring(getbaseinfo(play, ConstCfg.gbase.guild) or "0") ~= "0" and 1 or 0),
        title_count = _count_pairs(gettitlelist(play)), artifact_count = _count_artifacts(play), woodcut_count = _toint((Player.getJsonTableByVar(play, VarCfg["T_砍树系统"]) or {}).num),
        kill_dl = state.counter.kill_dl, kill_secret = state.counter.kill_secret, kill_cross_mon = _toint(state.counter.kill_cross_mon), chat_streak = _toint(state.counter.chat_streak),
        safe_death = _toint(state.counter.safe_death), enhance_fail_total = _toint(state.counter.enhance_fail_total), enhance_fail_streak = _toint(state.counter.enhance_fail_streak),
        mon_kill_without_damage = _toint(state.counter.mon_kill_without_damage), friend_count = _count_pairs(getfriendnamelist(play)), castle_win_once = _toint(state.counter.castle_win_once),
        recharge_total = math.max(_toint(querymoney(play, 23)), _toint(getplaydef(play, VarCfg["U_真实充值"]))), xianfu_xianghua = _toint(xianfu.stats.xiangHua),
        xianfu_refine_all = _count_true(xianfu.refine.collection) >= _count_pairs(recipes) and _count_pairs(recipes) > 0, pet_all_star = _get_pet_all_star(play),
        treasure_total = math.max(_toint(state.counter.treasure_total), _toint(getplaydef(play, VarCfg["U_藏宝图次数"]))), global_unique = math.max(_toint(state.counter.global_unique), _count_true(Player.getJsonTableByVar(play, VarCfg.T_grss) or {}) > 0 and 1 or 0),
        first_create_login = _toint(state.counter.first_create_login), auto_online = _toint(getplaydef(play, VarCfg.J_zxsj)),
        death_total = math.max(_toint(state.counter.death_total), _toint(getplaydef(play, VarCfg["U_被杀数"]))), player_kill_total = math.max(_toint(state.counter.player_kill_total), _toint(getplaydef(play, VarCfg.U_srsl)), _toint(getplaydef(play, VarCfg["U_杀人数"]))),
        revenge_total = _toint(state.counter.revenge_total), kill_kuangbao_total = math.max(_toint(state.counter.kill_kuangbao_total), _toint(getplaydef(play, VarCfg.U_jskb))), death_drop_total = _toint(state.counter.death_drop_total),
        loot_player_equip_total = _toint(state.counter.loot_player_equip_total), castle_first_blood = _toint(state.counter.castle_first_blood), castle_kill_total = _toint(state.counter.castle_kill_total), palace_streak = _toint(state.counter.palace_best),
        bwdh_kill_total = _toint(state.counter.bwdh_kill_total), collateral_death = _toint(state.counter.collateral_death), one_hit_killed = _toint(state.counter.one_hit_killed), one_hit_kill = _toint(state.counter.one_hit_kill),
        story_complete = function(storyName) return _story_complete(play, storyName) end,
    }
end
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
local function _refresh_attr(play, state)
    local attrs, special = {}, {}
    for _, detail in ipairs(_cfg.details or {}) do
        if _toint(state.done[tostring(detail.id)]) >= 1 then
            for attrId, value in pairs((detail.reward_cfg or {}).attrs or {}) do attrs[attrId] = (attrs[attrId] or 0) + _toint(value) end
            for _, info in ipairs((detail.reward_cfg or {}).special or {}) do special[info.key] = (special[info.key] or 0) + _toint(info.value) end
        end
    end
    local attrsStr = Player.getAttrTableToStr(attrs)
    if attrsStr and attrsStr ~= "" then addattlist(play, _attr_list_name, "=", attrsStr, 1) else delattlist(play, _attr_list_name) end
    state.special = special
end
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
local function _done_count(state) return _count_true(state.done) end
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
local function _payload(play, state) -- 仅传运行态数据，客户端配置走本地副本
    local special = state.special or {}
    local snap = _build_snapshot(play, state)
    return {T_data = state, done_count = _done_count(state), special = special, fake_attr = _build_fake_attr(special), now = {level = snap.level, power = snap.power}}
end
local function _touch(play, updater, refresh)
    if not play then return end
    _prepare()
    local state = _get_state(play)
    local changed = updater and updater(state) or false
    local unlocked = _evaluate(play, state)
    if changed or unlocked or refresh then _refresh_attr(play, state) _save_state(play, state) end
end
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
                _save_state(play, state)
                sendluamsg(play, 101, 515, 1, target, tbl2json(_payload(play, state)))
                return
            end
        end
        Player.sendmsgEx(play, "奖励不存在#57")
        return
    end
    _evaluate(play, state)
    _refresh_attr(play, state)
    _save_state(play, state)
    sendluamsg(play, 101, 515, _toint(p2), _toint(p3), tbl2json(_payload(play, state)))
end
function FairyFate.getStrengthFreeChance(play)
    _prepare()
    local state = _get_state(play)
    _refresh_attr(play, state)
    return _toint((state.special or {}).strength_free)
end
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
    elseif reason == "linggen" or reason == "pet" or reason == "title" or reason == "fashion_unlock" or reason == "story" or reason == "xianfu" then
        _touch(play, nil, true)
    else
        _touch(play, nil, true)
    end
end
GameEvent.add(EventCfg.onLogin, function(play) _touch(play, function(state) if _toint(state.counter.guild_joined) <= 0 and tostring(getbaseinfo(play, ConstCfg.gbase.guild) or "0") ~= "0" then state.counter.guild_joined = 1 return true end return false end, true) end, "仙途奇缘")
GameEvent.add(EventCfg.onKFLogin, function(play) _touch(play, nil, true) end, "仙途奇缘")
GameEvent.add(EventCfg.onLoginEnd, function(play) _touch(play, nil, true) end, "仙途奇缘")
GameEvent.add(EventCfg.onSendAbility, function(play) _touch(play, nil, false) end, "仙途奇缘")
GameEvent.add(EventCfg.onProHarm, function(play, harm) _touch(play, function(state) local curHp = _toint(getbaseinfo(play, ConstCfg.gbase.curhp)) if _toint(harm) >= curHp and curHp > 0 then state.counter.one_hit_killed_pending = 1 return true end return false end, false) end, "仙途奇缘")
GameEvent.add(EventCfg.onAttackDamagePlayer, function(play, target, damage) _touch(play, function(state) if type(target) == "string" and getbaseinfo(target, ConstCfg.gbase.isplayer) and _toint(damage) >= _toint(getbaseinfo(target, ConstCfg.gbase.curhp)) and _toint(getbaseinfo(target, ConstCfg.gbase.curhp)) > 0 then state.counter.one_hit_kill_pending = 1 return true end return false end, false) end, "仙途奇缘")
GameEvent.add(EventCfg.onAttackDamageMonster, function(play) _touch(play, function(state) state.counter.life_hurt_mon = 1 state.counter.last_attack_mon_at = os.time() return true end, false) end, "仙途奇缘")
GameEvent.add(EventCfg.onKillMon, function(play, mob, mobIdx) _touch(play, function(state) local mapId = tostring(getbaseinfo(play, ConstCfg.gbase.mapid) or "") local dl = _toint(daluditu and daluditu[mapId]) if dl >= 1 and dl <= 6 then local key = tostring(dl) state.counter.kill_dl[key] = _toint(state.counter.kill_dl[key]) + 1 if _is_secret_map(play) then state.counter.kill_secret[key] = _toint(state.counter.kill_secret[key]) + 1 end end if checkkuafu(play) then state.counter.kill_cross_mon = _toint(state.counter.kill_cross_mon) + 1 end return true end, false) end, "仙途奇缘")
GameEvent.add(EventCfg.onkillplay, function(play, target) _touch(play, function(state) state.counter.player_kill_total = math.max(_toint(state.counter.player_kill_total) + 1, _toint(getplaydef(play, VarCfg.U_srsl))) if _toint(state.counter.one_hit_kill_pending) > 0 then state.counter.one_hit_kill = _toint(state.counter.one_hit_kill) + 1 state.counter.one_hit_kill_pending = 0 end if state.counter.revenge_target ~= "" and state.counter.revenge_target == tostring(getbaseinfo(target, ConstCfg.gbase.name) or "") then state.counter.revenge_target = "" state.counter.revenge_total = _toint(state.counter.revenge_total) + 1 end if checktitle(target, "狂暴之力") then state.counter.kill_kuangbao_total = math.max(_toint(state.counter.kill_kuangbao_total) + 1, _toint(getplaydef(play, VarCfg.U_jskb))) end if castleinfo and castleinfo(5) and getbaseinfo(play, ConstCfg.gbase.issbk) then state.counter.castle_kill_total = _toint(state.counter.castle_kill_total) + 1 if tostring(getsysvarex(_sys_castle_first_blood_key) or "") == "" then setsysvarex(_sys_castle_first_blood_key, tostring(getbaseinfo(play, ConstCfg.gbase.name) or ""), true) state.counter.castle_first_blood = 1 end local mapId = tostring(getbaseinfo(play, ConstCfg.gbase.mapid) or "") if mapId == "new0150" or mapId == "kuafu0150" then state.counter.palace_current = _toint(state.counter.palace_current) + 1 if _toint(state.counter.palace_current) > _toint(state.counter.palace_best) then state.counter.palace_best = state.counter.palace_current end end end local kqfz = _toint(getsysvar(constant.G_kqfz)) if kqfz >= 40 and kqfz <= 50 then state.counter.bwdh_kill_total = _toint(state.counter.bwdh_kill_total) + 1 end return true end, false) end, "仙途奇缘")
GameEvent.add(EventCfg.onPlaydie, function(play, killer) _touch(play, function(state) state.counter.death_total = _toint(state.counter.death_total) + 1 if getbaseinfo(play, ConstCfg.gbase.issaferect) then state.counter.safe_death = _toint(state.counter.safe_death) + 1 end state.counter.palace_current = 0 if killer and getbaseinfo(killer, ConstCfg.gbase.isplayer) then state.counter.revenge_target = tostring(getbaseinfo(killer, ConstCfg.gbase.name) or "") if _toint(state.counter.one_hit_killed_pending) > 0 then state.counter.one_hit_killed = _toint(state.counter.one_hit_killed) + 1 state.counter.one_hit_killed_pending = 0 end if os.time() - _toint(state.counter.last_attack_mon_at) <= 3 then state.counter.collateral_death = _toint(state.counter.collateral_death) + 1 end else if _toint(state.counter.life_hurt_mon) <= 0 then state.counter.mon_kill_without_damage = _toint(state.counter.mon_kill_without_damage) + 1 end state.counter.revenge_target = "" state.counter.one_hit_killed_pending = 0 end state.counter.life_hurt_mon = 0 return true end, false) end, "仙途奇缘")
GameEvent.add(EventCfg.onTriggerChat, function(play, text) _touch(play, function(state) state.counter.chat_streak = _toint(state.counter.chat_streak) + 1 return true end, false) end, "仙途奇缘")
GameEvent.add(EventCfg.goSwitchMap, function(play) _touch(play, function(state) local mapId = tostring(getbaseinfo(play, ConstCfg.gbase.mapid) or "") if mapId ~= "new0150" and mapId ~= "kuafu0150" and _toint(state.counter.palace_current) > 0 then state.counter.palace_current = 0 return true end return false end, false) end, "仙途奇缘")
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
