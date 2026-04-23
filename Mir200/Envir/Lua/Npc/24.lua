npc = {}


--天书

local _config = Guard.getConfig("npc_24")

local function _get_jf_need_kill_text(jf)
    jf = tonumber(jf) or 0
    if jf > 130000 then
        return "已达上限"
    elseif jf >= 36001 then
        return "需击杀五大陆及以上怪物"
    elseif jf >= 16001 then
        return "需击杀四大陆及以上怪物"
    elseif jf >= 6001 then
        return "需击杀三大陆及以上怪物"
    elseif jf >= 1001 then
        return "需击杀二大陆及以上怪物"
    else
        return "需击杀一大陆及以上怪物"
    end
end
local function _tianshu_fix_data(T_data)
    T_data = type(T_data) == "table" and T_data or {}
    T_data.level = tonumber(T_data.level) or 0
    T_data.jf = tonumber(T_data.jf) or 0
    T_data.shaqi = tonumber(T_data.shaqi) or 0
    T_data.caowei = T_data.caowei or {}
    return T_data
end
local function _get_tianshu_jf_max(level)
    level = tonumber(level) or 0
    local details = _config.details and _config.details[1] and _config.details[1].details or {}
    local cfg = details[level + 1] or details[level] or details[1] or {}
    return tonumber(cfg.jf) or 0
end
local function _get_tianshu_prompt_text(T_data)
    T_data = _tianshu_fix_data(T_data)
    return string.format("提示：%s 杀气：%d/%d", _get_jf_need_kill_text(T_data.jf), T_data.shaqi, tonumber(_config.shaqi_max) or 1000)
end

local XIANFA_UNLOCK_ARTIFACT = "雷霆双子剑"
local XIANFA_UNLOCK_POS = 72

-- 装备位72穿上雷霆双子剑时，仙法10个槽位都视为已解锁。
local function _xianfa_unlock_all_slots(actor)
    return Player and Player.hasEquipOnPos and Player.hasEquipOnPos(actor, XIANFA_UNLOCK_POS, XIANFA_UNLOCK_ARTIFACT)
end

local function _xianfa_get_slot_need_lv(actor, cfg, slot)
    if _xianfa_unlock_all_slots(actor) then
        return 1, true
    end
    local unlock_lv = cfg.unlock_lv or {}
    return tonumber(unlock_lv[slot]) or 1, false
end

local function _build_npc24_payload(actor, T_data)
    return {
        ["T_data"] = _tianshu_fix_data(T_data),
        ["xianfa_all_unlock"] = _xianfa_unlock_all_slots(actor) and 1 or 0,
    }
end

local function _xianfa_parse_weight_map(weight)
    local map = {}
    for token in string.gmatch(weight or "", "[^|]+") do
        local k, v = token:match("(%d+)#(%d+)")
        if k and v then
            map[tonumber(k)] = tonumber(v)
        end
    end
    return map
end

local function _xianfa_build_block_map(T_data, slot)
    T_data = _tianshu_fix_data(T_data)
    local block_map = {}
    local slot_key = tostring(slot or "")
    local caowei = T_data.caowei or {}

    for key, value in pairs(caowei) do
        if tostring(key) ~= slot_key and type(value) == "table" then
            local group = tonumber(value[1])
            local idx = tonumber(value[2])
            if group and idx then
                block_map[group .. "_" .. idx] = true
            end
        end
    end

    local last_slot = caowei[slot_key]
    if type(last_slot) == "table" then
        local group = tonumber(last_slot[1])
        local idx = tonumber(last_slot[2])
        if group and idx then
            block_map[group .. "_" .. idx] = true
        end
    end

    local last_draw = T_data.last_xianfa_draw
    if type(last_draw) == "table" then
        local group = tonumber(last_draw[1])
        local idx = tonumber(last_draw[2])
        if group and idx then
            block_map[group .. "_" .. idx] = true
        end
    end
    return block_map
end

local function _xianfa_pick_group(weight_map, group_candidates)
    local total_weight = 0
    for group = 1, 5 do
        local list = group_candidates[group]
        if list and #list > 0 then
            total_weight = total_weight + (tonumber(weight_map[group]) or 0)
        end
    end

    if total_weight <= 0 then
        local groups = {}
        for group = 1, 5 do
            local list = group_candidates[group]
            if list and #list > 0 then
                table.insert(groups, group)
            end
        end
        if #groups == 0 then
            return nil
        end
        return groups[math.random(1, #groups)]
    end

    local roll = math.random(1, total_weight)
    local cur = 0
    for group = 1, 5 do
        local list = group_candidates[group]
        if list and #list > 0 then
            cur = cur + (tonumber(weight_map[group]) or 0)
            if roll <= cur then
                return group
            end
        end
    end
    return nil
end

local function _xianfa_roll_non_repeat(T_data, slot, weight, max_group, force_group)
    local details = _config.details[2].details or {}
    local block_map = _xianfa_build_block_map(T_data, slot)
    local group_candidates = {}
    local group_limit = tonumber(force_group or max_group) or 0

    for group = 1, group_limit do
        if not force_group or group == force_group then
            local group_cfg = details[group] or {}
            for idx, _ in ipairs(group_cfg) do
                if not block_map[group .. "_" .. idx] then
                    group_candidates[group] = group_candidates[group] or {}
                    table.insert(group_candidates[group], idx)
                end
            end
        end
    end

    local group = nil
    if force_group then
        local list = group_candidates[force_group]
        if not list or #list == 0 then
            return nil, nil
        end
        group = force_group
    else
        group = _xianfa_pick_group(_xianfa_parse_weight_map(weight), group_candidates)
    end

    local list = group and group_candidates[group] or nil
    if not list or #list == 0 then
        return nil, nil
    end
    return group, list[math.random(1, #list)]
end
local function _set_tianshu_shaqi_customabil(play, itemobj, T_data)
    itemobj = itemobj or linkbodyitem(play, _config.where)
    if not itemobj or itemobj == "0" then
        return
    end
    T_data = _tianshu_fix_data(T_data)
    local ok, item_json = pcall(json2tbl, getitemcustomabil(play, itemobj))
    item_json = ok and type(item_json) == "table" and item_json or nil
    if not item_json or type(item_json.abil) ~= "table" then
        item_json = json2tbl('{"abil":[{"i":0,"t":"[杀气属性]","c":251,"v":[]}],"name":""}')
    end
    item_json.name = tostring(item_json.name or "")
    local idx = nil
    local abil_i = nil
    for i, v in ipairs(item_json.abil) do
        if type(v) == "table" and tostring(v.t or "") == "[杀气属性]" then
            idx = i
            abil_i = tonumber(v.i) or (i - 1)
            break
        end
    end
    if not idx then
        for i, v in ipairs(item_json.abil) do
            if type(v) == "table" and tostring(v.t or "") == "" and next(v.v or {}) == nil then
                idx = i
                abil_i = tonumber(v.i) or (i - 1)
                break
            end
        end
    end
    if not idx then
        idx = #item_json.abil + 1
        abil_i = idx - 1
    end
    local attr_list = {}
    local attack_value = T_data.shaqi * (tonumber(_config.shaqi_attack_per) or 1)
    local hp_value = T_data.shaqi * (tonumber(_config.shaqi_hp_per) or 20)
    if attack_value > 0 then
        table.insert(attr_list, {254, tonumber(_config.shaqi_attack_attr) or 4, attack_value, 0, 20, 1, 1})
    end
    if hp_value > 0 then
        table.insert(attr_list, {254, tonumber(_config.shaqi_hp_attr) or 1, hp_value, 0, 21, 2, 2})
    end
    item_json.abil[idx] = {i = abil_i or (idx - 1), t = "[杀气属性]", c = 251, v = attr_list}
    setitemcustomabil(play, itemobj, tbl2json(item_json))
end
function tianshu_refresh_item(play, T_data, itemobj)
    itemobj = itemobj or linkbodyitem(play, _config.where)
    if not itemobj or itemobj == "0" then
        return
    end
    T_data = _tianshu_fix_data(T_data)
    setcustomitemprogressbar(play, itemobj, 0, tbl2json({
        ["open"] = 1,
        ["show"] = 0,
        ["name"] = string.format("天书等级：%d级", T_data.level),
        ["color"] = 223,
        ["imgcount"] = 1,
    }))
    setcustomitemprogressbar(play, itemobj, 1, tbl2json({
        ["open"] = 1,
        ["show"] = 2,
        ["name"] = "杀意值",
        ["color"] = 249,
        ["imgcount"] = 1,
        ["cur"] = T_data.jf,
        ["max"] = _get_tianshu_jf_max(T_data.level),
        ["level"] = T_data.level,
    }))
    setcustomitemprogressbar(play, itemobj, 2, tbl2json({
        ["open"] = 1,
        ["show"] = 0,
        ["name"] = _get_tianshu_prompt_text(T_data),
        ["color"] = 251,
        ["imgcount"] = 1,
    }))
    _set_tianshu_shaqi_customabil(play, itemobj, T_data)
    refreshitem(play, itemobj)
end

function npc.main(play,npcid)
    local itemobj = linkbodyitem(play, _config.where)
    if not itemobj or itemobj == "0" then
        Player.sendmsgEx(play, "请先装备#57|【天书】#249|后再打开#57")
        return
    end
    local T_data = _tianshu_fix_data(Player.getJsonTableByVar(play, VarCfg["T_天书"]))
    sendluamsg(play,100,npcid,0,0,tbl2json(_build_npc24_payload(play, T_data)))
    openhyperlink(play, 1, 2)
end

function npc.link(play,npcid,ew,aid,data)
    -- npc_guard: 入参校验
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local __guardAction = Guard.normalizeAction(play, npcid, ew)
    if __guardAction == nil then
        return
    end
    ew = __guardAction
    -- npc_guard: 操作白名单（优化：限定合法操作编号）
    local __guardAllowedActions = Guard.newActionSet({1, 2})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end

    local itemobj = linkbodyitem(play, _config.where)
    if not itemobj or itemobj == "0" then
        Player.sendmsgEx(play, "请先装备#57|【天书】#249|后再操作#57")
        return
    end
    local T_data = _tianshu_fix_data(Player.getJsonTableByVar(play, VarCfg["T_天书"]))
    local json_data = json2tbl(data)
    if ew == 1 then -- 强化
        local itemobj = linkbodyitem(play, _config.where)
        if itemobj then
            T_data.level = (T_data.level or 0) + 1
            if T_data.level > _config.details[1].max_level then
                Player.sendmsgEx(play, "天书已达到#57|【最高等级】#249|，无需再强化#57")
                return
            end
            local config = _config.details[1].details[T_data.level]
            -- release_print("天书强化配置:", T_data.level)
            -- release_print("天书强化配置:", tbl2json(config))
            if (T_data.jf or 0) < config.jf then
                Player.sendmsgEx(play, "你的#57|【天书杀意值】#249|不足，无法进行强化#57")
                return
            end
            Player.sendmsgEx(play, "恭喜你，天书强化成功，当前天书等级为|【"..T_data.level.."级】#249|")
            Player.setJsonVarByTable(play, VarCfg["T_天书"], T_data)
            xianfa_refresh(play)
            tianshu_refresh_item(play, T_data, itemobj)
            --强化属性
            local attrs = {}
            local attrsstr = ""
            for k,v in ipairs(config.attr) do
                attrs[v[1]] = v[2]
            end
            attrsstr = Player.getAttrTableToStr(attrs)
            setaddnewabil(play, -2, "=",attrsstr, itemobj)
            refreshitem(play, itemobj)
            recalcabilitys(play)


            sendluamsg(play,100,npcid,1,0,tbl2json(_build_npc24_payload(play, T_data)))
        else
            Player.sendmsgEx(play, "请先穿戴#57|【对应部位装备】#249|")
            return
        end
    elseif ew == 2 then --仙法
        if json_data["caowei"] then
            local slot = tonumber(json_data["caowei"]) or 0
            if slot < 1 or slot > 10 then
                return
            end

            local cfg = _config.details[2]
            local need_lv, unlock_by_artifact = _xianfa_get_slot_need_lv(play, cfg, slot)
            local cur_lv = T_data.level or 0
            if not unlock_by_artifact and cur_lv < need_lv then
                Player.sendmsgEx(play, string.format("天书等级达到#57|【%d级】#249|才可解锁该仙法槽位#57", need_lv))
                return
            end

            T_data["caowei"] = T_data["caowei"] or {}
            local slot_key = ""..slot

            local force_xianpin = tonumber(aid) == 2
            local weight = cfg.weight
            if getplaydef(play, "N$buff311") == 1 then
                local wmap = _xianfa_parse_weight_map(weight)
                if next(wmap) ~= nil then
                    wmap[5] = (wmap[5] or 0) + 20 -- 红色仙法概率+20%
                    local parts = {}
                    for i = 1, 5 do
                        if wmap[i] then
                            table.insert(parts, i .. "#" .. wmap[i])
                        end
                    end
                    weight = table.concat(parts, "|")
                end
            end

            local max_group = (getplaydef(play, "N$buff311") == 1) and 5 or 3
            local randomNum, idx = _xianfa_roll_non_repeat(T_data, slot, weight, max_group, force_xianpin and 5 or nil)
            if not randomNum or not idx then
                Player.sendmsgEx(play, "当前已没有可抽取的新仙法，请先更换槽位或调整已有仙法#57")
                return
            end

            if force_xianpin then
                local need = {{"仙品仙法卷轴",1}}
                local name, num = Player.checkItemNumByTable(play, need)
                if name then
                    Player.sendmsgEx(play, string.format("你的#57|【%s】#249|不足：#57|【%d】#249|", name, num))
                    return
                end
                Player.takeItemByTable(play, need, ",天书仙法", nil)
            else
                local cost_cfg = cfg.cost
                if cost_cfg then
                    local name, num = Player.checkItemNumByTable(play, cost_cfg[1])
                    if name then
                        local name2, num2 = Player.checkItemNumByTable(play, cost_cfg[2])
                        if name2 then
                            Player.sendmsgEx(play, string.format("你的#57|【%s】#249|不足：#57|【%d】#249|", name2, num2))
                            return
                        end
                        Player.sendmsgEx(play, "#57|【仙法卷轴】#249|不足，改用|【灵石】#249|消耗#57")
                        Player.takeItemByTable(play, cost_cfg[2], ",天书仙法", nil)
                    else
                        Player.takeItemByTable(play, cost_cfg[1], ",天书仙法", nil)
                    end
                end
            end

            local list_cfg = cfg.details and cfg.details[randomNum]
            if not list_cfg or not list_cfg[idx] then
                Player.sendmsgEx(play, "配置异常，请联系管理员#57")
                return
            end
            if T_data["caowei"][slot_key] then
                xianfa_del(play, T_data["caowei"][slot_key][1], T_data["caowei"][slot_key][2])
            end
            T_data["caowei"][slot_key] = {randomNum,idx}
            T_data["tj"] = T_data["tj"] or {}
            T_data["tj"][randomNum.."_"..idx] = 1
            T_data.last_xianfa_draw = {randomNum,idx}
            Player.setJsonVarByTable(play, VarCfg["T_天书"], T_data)
            xianfa_refresh(play)

            xianfa_add(play,randomNum,idx)
            sendluamsg(play,100,npcid,2,0,tbl2json(_build_npc24_payload(play, T_data)))
            sendluamsg(play,100,npcid,10,0,tbl2json({ ["group"] = randomNum,["idx"] = idx} ))
        else
        end
    end
end

function npc.wangshi(play,idx,data)
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_天书"])
    T_data.wangshi = T_data.wangshi or {}
    if T_data.wangshi[""..idx] then
        -- Player.sendmsgEx(play, "你已经记录过该往事#57")
        return
    end
    T_data.wangshi[""..idx] = data
    Player.setJsonVarByTable(play, VarCfg["T_天书"], T_data)
end


-- 天书仙法系统：统一管理常量/标记/BUFF ID，供后续逻辑复用
local XIANFA_ATTR_NAME = "天书仙法"
local XIANFA_REVIVE_ATTR_NAME = "天书仙法_复活"
local XIANFA_HP_ATTR_NAME = "天书仙法_低血量"
local XIANFA_ATTACK_BUFF = 301
local XIANFA_REVIVE_BUFF = 302
local XIANFA_STEAL_MONEY_ID = 1
local XIANFA_STEAL_DAILY_MAX = 20000000
local XIANFA_STEAL_ONCE_MAX = 1000000
local XIANFA_HP_TIMER_FLAG = "N$天书低血监控"
local XIANFA_INVIS_FLAG = "N$天书六娃"
local XIANFA_DROP_DATE = "S$天书守财奴日期"
local XIANFA_DROP_USED = "N$天书守财奴已用"
local XIANFA_DROP_ACTIVE = "N$天书守财奴保护"
local XIANFA_YUANSHEN_NAME = "元神"
local XIANFA_YUANSHEN_CD = "N$天书元神CD"

-- 收集玩家已激活的仙法列表（group/idx/cfg），并返回天书数据
local function _xianfa_iter(actor)
    local T_data = _tianshu_fix_data(Player.getJsonTableByVar(actor, VarCfg["T_天书"]))
    local list = {}
    for _, v in pairs(T_data["caowei"]) do
        if type(v) == "table" then
            local g = tonumber(v[1])
            local idx = tonumber(v[2])
            local cfg_group = teshudata["npc_24"].details[2].details[g]
            if cfg_group and cfg_group[idx] then
                table.insert(list, {group = g, idx = idx, cfg = cfg_group[idx]})
            end
        end
    end
    return list, T_data
end

-- 按名称判断是否拥有某仙法，返回配置（存在）或 nil（不存在）
local function _xianfa_has(actor, name)
    local list = _xianfa_iter(actor)
    for _, it in ipairs(list) do
        if it.cfg and it.cfg.name == name then
            return it.cfg
        end
    end
    return nil
end

-- 属性叠加工具：累加到 attrs 表（id -> value）
local function _add_attr(attrs, id, val)
    if id and val and val ~= 0 then
        attrs[id] = (attrs[id] or 0) + val
    end
end

-- 批量叠加属性列表，支持倍数系数（用于随条件放大）
local function _add_attr_list(attrs, list, mult)
    if not list then
        return
    end
    mult = mult or 1
    for _, v in ipairs(list) do
        _add_attr(attrs, v[1], (v[2] or 0) * mult)
    end
end

-- 技能伤害加成：在技能升级基础值上叠加仙法额外百分比，并刷新引擎倍率
local function _xianfa_apply_skill_bonus(actor, bonus)
    local skill_data = Player.getJsonTableByVar(actor, VarCfg["T_技能升级"])
    skill_data.level = skill_data.level or {}
    for i, v in ipairs(VarCfg.N_jnsh) do
        local base = (skill_data.level[""..i] or 0) * 2
        setplaydef(actor, v, base + bonus)
    end
    Login_jnsh(actor)
end
-- 名字长度计算：优先使用 GBK 字节长度，保证中英混排比较更公平
local function _xianfa_name_len(name)
    if not name then
        return 0
    end
    if GbkLength then
        return GbkLength(name)
    end
    return string.len(name)
end
-- 方向计算：根据坐标差值推断8方向（0上 1右上 2右 3右下 4下 5左下 6左 7左上）
local function _xianfa_dir_to(dx, dy)
    if dx == 0 and dy == 0 then
        return nil
    end
    if dx > 0 and dy == 0 then
        return 2
    end
    if dx < 0 and dy == 0 then
        return 6
    end
    if dx == 0 and dy > 0 then
        return 4
    end
    if dx == 0 and dy < 0 then
        return 0
    end
    if dx > 0 and dy > 0 then
        return 3
    end
    if dx > 0 and dy < 0 then
        return 1
    end
    if dx < 0 and dy > 0 then
        return 5
    end
    if dx < 0 and dy < 0 then
        return 7
    end
    return nil
end

-- 背后攻击判定：攻击者在目标“背后扇区”时返回 true
local function _xianfa_is_back_attack(attacker, target)
    if not attacker or not target or not ConstCfg or not ConstCfg.gbase then
        return false
    end
    local tdir = getbaseinfo(target, ConstCfg.gbase.dir)
    if tdir == nil then
        return false
    end
    tdir = tonumber(tdir) or 0
    tdir = tdir % 8

    local tx = getbaseinfo(target, ConstCfg.gbase.x)
    local ty = getbaseinfo(target, ConstCfg.gbase.y)
    local ax = getbaseinfo(attacker, ConstCfg.gbase.x)
    local ay = getbaseinfo(attacker, ConstCfg.gbase.y)
    if not tx or not ty or not ax or not ay then
        return false
    end

    local dir_to_attacker = _xianfa_dir_to(ax - tx, ay - ty)
    if dir_to_attacker == nil then
        return false
    end

    local back_dir = (tdir + 4) % 8
    -- 放宽为背后扇区（背后方向及其相邻方向）
    if dir_to_attacker == back_dir then
        return true
    end
    if dir_to_attacker == (back_dir + 1) % 8 then
        return true
    end
    if dir_to_attacker == (back_dir + 7) % 8 then
        return true
    end
    return false
end

-- 攻沙判定：处于沙巴克状态且在攻沙地图内
local function _xianfa_in_siege(actor)
    if castleinfo and castleinfo(5) then
        if getbaseinfo(actor, ConstCfg.gbase.issbk) then
            return true
        end
    end
    return false
end

-- 我是六娃隐身处理：只在状态变化时切换模式，避免频繁设置
local function _xianfa_set_invis(actor, enable)
    if enable then
        if getplaydef(actor, XIANFA_INVIS_FLAG) ~= 1 then
            setplaydef(actor, XIANFA_INVIS_FLAG, 1)
            if ConstCfg and ConstCfg.pmode and ConstCfg.pmode.lucent then
                changemode(actor, ConstCfg.pmode.lucent, 999999999)
            end
        end
    else
        if getplaydef(actor, XIANFA_INVIS_FLAG) == 1 then
            setplaydef(actor, XIANFA_INVIS_FLAG, 0)
            if ConstCfg and ConstCfg.pmode and ConstCfg.pmode.lucent then
                changemode(actor, ConstCfg.pmode.lucent, 0)
            end
        end
    end
end

-- 低血量效果处理：愈战愈勇(50%以下加双防)，不死族(30%以下每秒回血)
-- 返回值：是否还需要持续监控
local function _xianfa_apply_hp_state(actor)
    if getbaseinfo(actor, ConstCfg.gbase.isdie) then
        Player.del_attlist(actor, XIANFA_HP_ATTR_NAME)
        return _xianfa_has(actor, "不死族") or _xianfa_has(actor, "愈战愈勇")
    end
    local has_undead = _xianfa_has(actor, "不死族")
    local has_berserk = _xianfa_has(actor, "愈战愈勇")
    if not has_undead and not has_berserk then
        Player.del_attlist(actor, XIANFA_HP_ATTR_NAME)
        return false
    end
    local maxhp = getbaseinfo(actor, ConstCfg.gbase.maxhp)
    local hp = getbaseinfo(actor, ConstCfg.gbase.curhp)
    local hp_rate = (maxhp > 0) and (hp / maxhp) or 1

    if has_berserk and hp_rate < 0.5 then
        local attrs = { [36] = 2000, [37] = 2000 }
        local attrsstr = Player.getAttrTableToStr(attrs)
        if attrsstr and attrsstr ~= "" then
            Player.add_attlist(actor, XIANFA_HP_ATTR_NAME, "=", attrsstr, 1)
        end
    else
        Player.del_attlist(actor, XIANFA_HP_ATTR_NAME)
    end

    if has_undead and hp_rate < 0.3 then
        local heal = math.floor(maxhp * 0.03)
        if heal > 0 then
            humanhp(actor, "+", heal)
        end
    end
    return true
end

-- 启动低血量监控定时器（每秒回调一次）
local function _xianfa_start_hp_timer(actor)
    if getplaydef(actor, XIANFA_HP_TIMER_FLAG) == 1 then
        return
    end
    setplaydef(actor, XIANFA_HP_TIMER_FLAG, 1)
    delaygoto(actor, 1000, "@xianfa_hp_tick")
end

-- 定时器回调：持续监控低血量效果，直到无需监控为止
function xianfa_hp_tick(actor)
    if _xianfa_apply_hp_state(actor) then
        delaygoto(actor, 1000, "@xianfa_hp_tick")
    else
        setplaydef(actor, XIANFA_HP_TIMER_FLAG, 0)
    end
end

-- 对外查询接口：其它脚本可直接判断是否拥有某仙法
function xianfa_has(actor, name)
    return _xianfa_has(actor, name) ~= nil
end

-- 仙法刷新入口：
-- 1) 清空旧属性
-- 2) 重新计算常驻/条件属性
-- 3) 处理一次性触发（捡钱啦/天降横财）
-- 4) 维护BUFF开关、隐身、低血监控、等级上限、技能伤害等
-- new_group/new_idx 用于判断本次新选择的仙法
function xianfa_refresh(actor, new_group, new_idx)
    local list, T_data = _xianfa_iter(actor)
    T_data = _tianshu_fix_data(T_data)
    Player.del_attlist(actor, XIANFA_ATTR_NAME)

    local attrs = {}
    local need_attack_buff = false
    local need_revive_buff = false
    local skill_bonus = 0
    local cap_bonus = 0
    local need_invis = false
    local need_hp_timer = false
    -- 条件计算：组队/挂机/开服天数/天书等级/仙法品质计数/攻沙状态

    local in_group = (#(getgroupmember(actor) or {})) > 0
    local auto_hang = false
    local ai_json = json2tbl(getplaydef(actor, VarCfg.T_aigj) == "" and {} or getplaydef(actor, VarCfg.T_aigj))
    if ai_json and ai_json.gjkg then
        auto_hang = true
    end

    local open_day = 0
    local kfday = getconst(actor, "<$KFDAY>")
    if kfday and tonumber(kfday) then
        open_day = tonumber(kfday)
    else
        open_day = tonumber(grobalinfo(ConstCfg.global.openday) or 0)
    end
    if open_day < 0 then
        open_day = 0
    end
    local level = getbaseinfo(actor, ConstCfg.gbase.level)

    local ts_level = T_data.level or 0

    local lg_count5
    local ls_count2
    local ls_count3

    local function get_lg_count5()
        if lg_count5 ~= nil then
            return lg_count5
        end
        local T_lg = Player.getJsonTableByVar(actor, VarCfg["T_灵根"])
        local cnt = 0
        if T_lg and T_lg.level then
            for _, v in pairs(T_lg.level) do
                if tonumber(v) and tonumber(v) >= 5 then
                    cnt = cnt + 1
                end
            end
        end
        lg_count5 = cnt
        return cnt
    end

    local function get_ls_count(min_star)
        local T_ls = Player.getJsonTableByVar(actor, VarCfg["T_灵兽"])
        local cnt = 0
        if T_ls and T_ls.ls_sp then
            for _, v in pairs(T_ls.ls_sp) do
                if tonumber(v) and tonumber(v) >= min_star then
                    cnt = cnt + 1
                end
            end
        end
        return cnt
    end

    local high_count = 0
    for _, item in ipairs(list) do
        if item.group and item.group >= 4 then
            high_count = high_count + 1
        end
    end
    local in_siege = _xianfa_in_siege(actor)

    for _, item in ipairs(list) do
        local cfg = item.cfg
        if cfg.attr then
            _add_attr_list(attrs, cfg.attr)
        end
        local name = cfg.name or ""

        if name == "捡钱啦" then
            if new_group == item.group and new_idx == item.idx then
                changemoney(actor, XIANFA_STEAL_MONEY_ID, "+", 100000, "天书仙法", true)
            end
        elseif name == "天降横财" then
            if new_group == item.group and new_idx == item.idx then
                changemoney(actor, 3, "+", 30000000, "天书仙法", true)
            end
        elseif name == "狂暴到底" then
            if checktitle(actor, "狂暴之力") then
                _add_attr_list(attrs, cfg.spa_attr)
            end
        elseif name == "溜了溜了" then
            need_revive_buff = true
        elseif name == "朋友多多" then
            if in_group then
                _add_attr_list(attrs, cfg.spa_attr)
            end
        elseif name == "挂机佬" then
            if auto_hang then
                _add_attr_list(attrs, cfg.spa_attr)
            end
        elseif name == "开服元老" then
            local days = open_day
            if days > 40 then
                days = 40
            end
            _add_attr_list(attrs, cfg.spa_attr, days)
        elseif name == "灵根之主" then
            local cnt = get_lg_count5()
            if cnt > 0 then
                _add_attr_list(attrs, cfg.spa_attr, cnt)
            end
        elseif name == "灵兽之王" then
            ls_count2 = ls_count2 or get_ls_count(2)
            if ls_count2 > 0 then
                _add_attr(attrs, 1, 1000 * ls_count2)
                _add_attr(attrs, 3, 100 * ls_count2)
                _add_attr(attrs, 4, 100 * ls_count2)
            end
        elseif name == "神兽大帝" then
            ls_count3 = ls_count3 or get_ls_count(3)
            _add_attr(attrs, 73, 300 + (ls_count3 * 500))
            _add_attr(attrs, 89, 300 + (ls_count3 * 500))
        elseif name == "独狼" then
            if not in_group then
                _add_attr(attrs, 245, 1000)
            end
        elseif name == "愈战愈勇" or name == "不死族" then
            need_hp_timer = true
        elseif name == "读书人" then
            if ts_level > 0 then
                _add_attr(attrs, 242, ts_level * 200)
            end
        elseif name == "天胡" then
            if level > 0 then
                _add_attr(attrs, 244, level * 100)
            end
        elseif name == "熟能生巧" then
            skill_bonus = skill_bonus + 3
        elseif name == "技能导师" then
            skill_bonus = skill_bonus + 20
        elseif name == "诅咒冠冕" then
            cap_bonus = cap_bonus + 2
        elseif name == "打破枷锁" then
            if level >= 150 then
                cap_bonus = cap_bonus + 5
            end
        elseif name == "我是六娃" then
            need_invis = true
        elseif name == "沙老大" then
            if in_siege then
                _add_attr(attrs, 76, 5000)
                _add_attr(attrs, 77, 5000)
            end
        elseif name == "仙法大佬" then
            if high_count > 1 then
                -- 300仅展示，全属性百分比需叠加 280-291
                local all_pct = 2 * (high_count - 1)
                _add_attr(attrs, 300, all_pct)
                _add_attr(attrs, 280, all_pct)
                _add_attr(attrs, 281, all_pct)
                _add_attr(attrs, 282, all_pct)
                _add_attr(attrs, 283, all_pct)
                _add_attr(attrs, 284, all_pct)
                _add_attr(attrs, 285, all_pct)
                _add_attr(attrs, 286, all_pct)
                _add_attr(attrs, 287, all_pct)
                _add_attr(attrs, 288, all_pct)
                _add_attr(attrs, 289, all_pct)
                _add_attr(attrs, 290, all_pct)
                _add_attr(attrs, 291, all_pct)
            end
        elseif name == "富可敌国" or name == "欺负弱小" or name == "扼雷指" or name == "神偷" or name == "魅惑" or name == "咒术回响" or name == "吸蓝刀" or name == "跪下" or name == "名字长就牛比" or name == "名字短就牛比" or name == "睚眦必报" or name == "蜘蛛侠" or name == "刺客信条" or name == "元神助战" then
            need_attack_buff = true
        end
    end

    local prev_bonus = getplaydef(actor, "N$天书等级上限加成")
    local base_cap = getplaydef(actor, VarCfg["U_等级上限"]) - prev_bonus
    if base_cap < 0 then
        base_cap = 0
    end
    setplaydef(actor, VarCfg["U_等级上限"], base_cap + cap_bonus)
    setplaydef(actor, "N$天书等级上限加成", cap_bonus)

    _xianfa_apply_skill_bonus(actor, skill_bonus)

    local attrsstr = Player.getAttrTableToStr(attrs)
    if attrsstr and attrsstr ~= "" then
        Player.add_attlist(actor, XIANFA_ATTR_NAME, "=", attrsstr, 1)
    end

    _xianfa_set_invis(actor, need_invis)

    if need_hp_timer then
        _xianfa_apply_hp_state(actor)
        _xianfa_start_hp_timer(actor)
    else
        Player.del_attlist(actor, XIANFA_HP_ATTR_NAME)
        setplaydef(actor, XIANFA_HP_TIMER_FLAG, 0)
    end

    if Buff and Buff[XIANFA_ATTACK_BUFF] then
        Buff[XIANFA_ATTACK_BUFF](actor, need_attack_buff and 1 or 2)
    end
    if Buff and Buff[XIANFA_REVIVE_BUFF] then
        Buff[XIANFA_REVIVE_BUFF](actor, need_revive_buff and 1 or 2)
    end
    Buff[339](actor, 1)
    tianshu_refresh_item(actor, T_data)
end


-- 复活触发：溜了溜了，给予临时移速加成（30秒）
function xianfa_revive_trigger(play)
    if not _xianfa_has(play, "溜了溜了") then
        return
    end
    Player.del_attlist(play, XIANFA_REVIVE_ATTR_NAME)
    Player.add_attlist(play, XIANFA_REVIVE_ATTR_NAME, "=", "3#243#5", 1)
    delaygoto(play, 30000, "@xianfa_revive_remove")
end

function xianfa_revive_remove(play)
    Player.del_attlist(play, XIANFA_REVIVE_ATTR_NAME)
end

-- 攻击触发：由 Buff[301] 回调，返回额外伤害值（叠加到最终伤害）
-- 同时可施加控制/偷钱/召唤等附加效果
function xianfa_attack_trigger(play, Damage, Target, MagicId, Model)
    local list = _xianfa_iter(play)
    if not list or #list == 0 then
        return 0
    end
    local has = {}
    for _, it in ipairs(list) do
        if it.cfg and it.cfg.name then
            has[it.cfg.name] = true
        end
    end

    local extra = 0
    local dmg = Damage or 0
    local is_player = getbaseinfo(Target, ConstCfg.gbase.isplayer)

    if has["欺负弱小"] and not is_player then
        local cur = getbaseinfo(Target, ConstCfg.gbase.curhp)
        local max = getbaseinfo(Target, ConstCfg.gbase.maxhp)
        if max > 0 and cur / max <= 0.3 then
            extra = extra + math.floor(max * 0.75)
        end
    end

    if has["扼雷指"] then
        if math.random(100) <= 3 then
            extra = extra + math.floor(getbaseinfo(play, ConstCfg.gbase.dc2) * 0.5)
        end
    end

    if has["富可敌国"] then
        local gold = querymoney(play, XIANFA_STEAL_MONEY_ID) or 0
        local pct = math.floor(gold / 10000000)
        if pct > 10 then
            pct = 10
        end
        if pct > 0 then
            extra = extra + math.floor(dmg * pct / 100)
        end
    end

    if has["刺客信条"] then
        -- 背后攻击判定：仅在背后扇区时触发增伤
        if _xianfa_is_back_attack(play, Target) then
            if MagicId and MagicId > 0 then
                extra = extra + math.floor(dmg * 0.5)
            else
                extra = extra + math.floor(dmg * 0.2)
            end
        end
    end

    if has["蜘蛛侠"] then
        if math.random(100) <= 2 then
            if ConstCfg and ConstCfg.pmode and ConstCfg.pmode.stick then
                changemode(Target, ConstCfg.pmode.stick, 3)
            end
        end
    end

    if has["咒术回响"] then
        if MagicId and MagicId > 0 then
            setplaydef(play, "N$天书咒术回响", 1)
        else
            if getplaydef(play, "N$天书咒术回响") == 1 then
                setplaydef(play, "N$天书咒术回响", 0)
                extra = extra + math.floor(dmg * 0.3)
            end
        end
    end

    if is_player then
        if has["神偷"] then
            local today = os.date("%Y%m%d")
            if getplaydef(play, "S$天书神偷日期") ~= today then
                setplaydef(play, "S$天书神偷日期", today)
                setplaydef(play, "N$天书神偷金额", 0)
            end
            local stolen = tonumber(getplaydef(play, "N$天书神偷金额")) or 0
            if stolen < XIANFA_STEAL_DAILY_MAX and math.random(100) <= 1 then
                local target_gold = querymoney(Target, XIANFA_STEAL_MONEY_ID) or 0
                local steal = math.floor(target_gold * 0.01)
                if steal > XIANFA_STEAL_ONCE_MAX then
                    steal = XIANFA_STEAL_ONCE_MAX
                end
                if steal > 0 then
                    if stolen + steal > XIANFA_STEAL_DAILY_MAX then
                        steal = XIANFA_STEAL_DAILY_MAX - stolen
                    end
                end
                if steal > 0 then
                    changemoney(Target, XIANFA_STEAL_MONEY_ID, "-", steal, "天书神偷", true)
                    changemoney(play, XIANFA_STEAL_MONEY_ID, "+", steal, "天书神偷", true)
                    setplaydef(play, "N$天书神偷金额", stolen + steal)
                end
            end
        end

        if has["魅惑"] then
            local now = os.time()
            if now - getplaydef(play, "N$天书魅惑CD") >= 60 then
                if getbaseinfo(Target, ConstCfg.gbase.level) < getbaseinfo(play, ConstCfg.gbase.level) then
                    if math.random(100) <= 1 then
                        setplaydef(play, "N$天书魅惑CD", now)
                        changemode(Target, ConstCfg.pmode.ban_act, 3)
                    end
                end
            end
        end

        if has["吸蓝刀"] then
            local maxmp = getbaseinfo(Target, ConstCfg.gbase.maxmp)
            if maxmp > 0 then
                local mp = math.floor(maxmp * 0.03)
                if mp > 0 then
                    humanmp(Target, "-", mp)
                    humanmp(play, "+", mp)
                end
            end
        end

        if has["跪下"] then
            if math.random(100) <= 2 then
                changemode(Target, ConstCfg.pmode.trap, 2, 1)
            end
        end

        local pname = getbaseinfo(play, ConstCfg.gbase.name)
        local tname = getbaseinfo(Target, ConstCfg.gbase.name)
        local plen = _xianfa_name_len(pname)
        local tlen = _xianfa_name_len(tname)
        if has["名字长就牛比"] and plen > tlen then
            extra = extra + math.floor(dmg * 0.2)
        end
        if has["名字短就牛比"] and plen < tlen then
            extra = extra + math.floor(dmg * 0.2)
        end

        if has["睚眦必报"] then
            local veng = getplaydef(play, "N$天书仇人")
            if veng ~= "" and veng == tname then
                extra = extra + math.floor(dmg * 0.2)
            end
        end
    end

    if has["元神助战"] then
        if math.random(100) <= 2 then
            local now = os.time()
            local last = tonumber(getplaydef(play, XIANFA_YUANSHEN_CD)) or 0
            if now - last >= 50 then
                setplaydef(play, XIANFA_YUANSHEN_CD, now)
                recallself(play,50,1,100,0,0,0,0,0,0,"")
                -- recallmobex(play, XIANFA_YUANSHEN_NAME, 0, 0, 7, 1, 50, 0, 0, 0, 0, 0, 0, "")
            end
        end
    end

    return extra
end

-- 被攻击最终伤害修正：双刃剑/诅咒冠冕副作用在此叠加
function xianfa_struck_adjust(play, Damage, Hiter, MagicId)
    if not Damage or Damage <= 0 then
        return Damage
    end
    local mult = 1
    if _xianfa_has(play, "双刃剑") then
        mult = mult + 0.08
    end
    if _xianfa_has(play, "诅咒冠冕") then
        mult = mult + 0.10
    end
    if mult == 1 then
        return Damage
    end
    return math.floor(Damage * mult)
end

-- 守财奴保护结束（用于限制一次掉落窗口）
function xianfa_drop_protect_end(play)
    setplaydef(play, XIANFA_DROP_ACTIVE, 0)
end

-- 守财奴：每天一次防掉落，触发后短暂保护以避免多件掉落
function xianfa_check_drop(play)
    if not _xianfa_has(play, "守财奴") then
        return true
    end
    local today = os.date("%Y%m%d")
    if getplaydef(play, XIANFA_DROP_DATE) ~= today then
        setplaydef(play, XIANFA_DROP_DATE, today)
        setplaydef(play, XIANFA_DROP_USED, 0)
        setplaydef(play, XIANFA_DROP_ACTIVE, 0)
    end
    local active = tonumber(getplaydef(play, XIANFA_DROP_ACTIVE)) or 0
    if active == 1 then
        return false
    end
    local used = tonumber(getplaydef(play, XIANFA_DROP_USED)) or 0
    if used == 0 then
        setplaydef(play, XIANFA_DROP_USED, 1)
        setplaydef(play, XIANFA_DROP_ACTIVE, 1)
        delaygoto(play, 1000, "@xianfa_drop_protect_end")
        return false
    end
    return true
end
-- 击杀玩家触发：饮血剑/修罗血衣回血
local function _xianfa_on_killplay(play, hiter)
    local maxhp = getbaseinfo(play, ConstCfg.gbase.maxhp)
    if maxhp > 0 then
        if _xianfa_has(play, "饮血剑") then
            humanhp(play, "+", math.floor(maxhp * 0.05))
        end
        if _xianfa_has(play, "修罗血衣") then
            humanhp(play, "+", math.floor(maxhp * 0.20))
        end
    end
end

-- 玩家死亡触发：自爆伤害、记录仇人、刷新仙法状态
local function _xianfa_on_playdie(play, hiter)
    if hiter and getbaseinfo(hiter, ConstCfg.gbase.isplayer) then
        if _xianfa_has(play, "自爆") then
            local maxhp = getbaseinfo(hiter, ConstCfg.gbase.maxhp)
            if maxhp > 0 then
                humanhp(hiter, "-", math.floor(maxhp * 0.30), 107, 0, play, 1)
            end
        end
        if _xianfa_has(play, "睚眦必报") then
            setplaydef(play, "N$天书仇人", getbaseinfo(hiter, ConstCfg.gbase.name))
        end
    end
    xianfa_refresh(play)
end

-- 登录/组队/升级/切图等统一刷新入口
local function _xianfa_on_login(play)
    xianfa_refresh(play)
end

-- 事件绑定：登录/组队/升级/切图/狂暴/击杀/死亡等触发刷新或特殊效果
-- onLogin: 登录初始化刷新
-- onEnterGroup/onLeaveGroup: 组队状态变化刷新（朋友多多/独狼等条件）
-- onPlayLevelUp: 等级变化刷新（天胡/打破枷锁等条件）
-- goSwitchMap: 切换地图刷新（攻沙/隐身/低血监控等）
-- onkillplay/onPlaydie: 击杀/死亡触发回血、仇人标记、反伤等
-- goKuangBao/OpenKuangBao: 狂暴状态变化刷新（狂暴到底等）
GameEvent.add(EventCfg.onLogin, _xianfa_on_login, "天书仙法")
GameEvent.add(EventCfg.onEnterGroup, _xianfa_on_login, "天书仙法")
GameEvent.add(EventCfg.onLeaveGroup, _xianfa_on_login, "天书仙法")
GameEvent.add(EventCfg.onPlayLevelUp, _xianfa_on_login, "天书仙法")
GameEvent.add(EventCfg.goSwitchMap, _xianfa_on_login, "天书仙法")
GameEvent.add(EventCfg.onkillplay, _xianfa_on_killplay, "天书仙法")
GameEvent.add(EventCfg.onPlaydie, _xianfa_on_playdie, "天书仙法")
GameEvent.add(EventCfg.goKuangBao, _xianfa_on_login, "天书仙法")
GameEvent.add(EventCfg.OpenKuangBao, _xianfa_on_login, "天书仙法")

-- 清空仙法属性与状态（切换/重抽时调用）
function xianfa_del(actor, group ,idx)
    Player.del_attlist(actor, XIANFA_ATTR_NAME)
    Player.del_attlist(actor, XIANFA_REVIVE_ATTR_NAME)
    Player.del_attlist(actor, XIANFA_HP_ATTR_NAME)
    setplaydef(actor, XIANFA_HP_TIMER_FLAG, 0)
    _xianfa_set_invis(actor, false)
    -- 删除仙法时回收等级上限加成（如：打破枷锁/诅咒冠冕）
    local prev_bonus = getplaydef(actor, "N$天书等级上限加成")
    if prev_bonus and prev_bonus ~= 0 then
        local base_cap = getplaydef(actor, VarCfg["U_等级上限"]) - prev_bonus
        if base_cap < 0 then
            base_cap = 0
        end
        setplaydef(actor, VarCfg["U_等级上限"], base_cap)
        setplaydef(actor, "N$天书等级上限加成", 0)
    end
    if Buff and Buff[XIANFA_ATTACK_BUFF] then
        Buff[XIANFA_ATTACK_BUFF](actor, 2)
    end
    if Buff and Buff[XIANFA_REVIVE_BUFF] then
        Buff[XIANFA_REVIVE_BUFF](actor, 2)
    end
end
-- 添加仙法：统一走刷新流程（包含一次性奖励判断）
function xianfa_add(actor, group ,idx)
    xianfa_refresh(actor, group, idx)
end

-- 穿戴天书时刷新进度条显示（等级/杀意值）
local function _onTakeOnEx(actor, itemobj, where, itemname, makeid)
    if where == _config.where then
        local T_data = _tianshu_fix_data(Player.getJsonTableByVar(actor, VarCfg["T_天书"]))
        tianshu_refresh_item(actor, T_data, itemobj)
    end
end
--穿装备触发
GameEvent.add(EventCfg.onTakeOnEx, _onTakeOnEx, "天书初始化")

return npc
