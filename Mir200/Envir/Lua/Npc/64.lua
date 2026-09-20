npc = {}


--灵兽

local _config = Guard.getConfig("npc_64")
local FairyFate = include("lua/LuaLib/fairy_fate.lua")
local LINGSHOU_BABY_SECONDS = 36 * 3600
local LINGSHOU_BABY_CFG = {
    [1] = {pet = "麒麟", item = "麒麟幼崽"},
    [2] = {pet = "青龙", item = "青龙幼崽"},
    [3] = {pet = "朱雀", item = "朱雀幼崽"},
    [4] = {pet = "白虎", item = "白虎幼崽"},
    [5] = {pet = "玄武", item = "玄武幼崽"},
}
local LINGSHOU_BABY_ITEM_TO_IDX = {
    ["麒麟幼崽"] = 1,
    ["青龙幼崽"] = 2,
    ["朱雀幼崽"] = 3,
    ["白虎幼崽"] = 4,
    ["玄武幼崽"] = 5,
}

local function _toint(v, d)
    return tonumber(v or d or 0) or (d or 0)
end

local function _star_upgrade_need()
    local need = _config.star_upgrade_need or {}
    local to2 = _toint(need[1], 3)
    local to3 = _toint(need[2], 9)
    if to2 < 1 then to2 = 1 end
    if to3 < to2 then to3 = to2 end
    return to2, to3
end

local function _get_star_progress(T_data, key, star)
    T_data.ls_star_progress = T_data.ls_star_progress or {}
    local progress = tonumber(T_data.ls_star_progress[key] or T_data.ls_star_progress[tonumber(key)])
    if progress == nil then
        local to2, to3 = _star_upgrade_need()
        if _toint(star) >= 3 then
            progress = to3
        elseif _toint(star) >= 2 then
            progress = to2
        elseif _toint(star) >= 1 then
            progress = 1
        else
            progress = 0
        end
    elseif progress <= 0 and _toint(star) >= 1 then
        -- 旧版本首次获得时记录为 0，这里迁移为首抽计入 1 次进度。
        progress = 1
    end
    local _, to3 = _star_upgrade_need()
    return math.max(0, math.min(to3, progress))
end

local function _star_from_progress(progress)
    local to2, to3 = _star_upgrade_need()
    if progress >= to3 then
        return 3
    elseif progress >= to2 then
        return 2
    end
    return 1
end

local function _star_progress_text(progress)
    local to2, to3 = _star_upgrade_need()
    progress = math.max(0, math.min(to3, _toint(progress)))
    if progress >= to3 then
        return string.format("%d/%d", to3, to3)
    elseif progress < to2 then
        return string.format("%d/%d", progress, to2)
    end
    return string.format("%d/%d", progress, to3)
end
local function _real_charge(play)
    return _toint(getplaydef(play, VarCfg["U_真实充值"]))
end

local function _rebirth_level(play)
    return _toint(getplaydef(play, VarCfg["U_转生等级"]))
end

local function _ensure_pet_data(T_data)
    T_data = T_data or {}
    T_data.ls = T_data.ls or {}
    T_data.ls_sp = T_data.ls_sp or {}
    T_data.ls_star_progress = T_data.ls_star_progress or {}
    T_data.hatch = T_data.hatch or {}
    T_data.hatch_log = T_data.hatch_log or {}
    for i = 1, 5 do
        local key = tostring(i)
        if T_data.ls[key] == nil and T_data.ls[i] ~= nil then
            T_data.ls[key] = T_data.ls[i]
        end
        if T_data.ls_sp[key] == nil and T_data.ls_sp[i] ~= nil then
            T_data.ls_sp[key] = T_data.ls_sp[i]
        end
        if T_data.ls_star_progress[key] == nil and T_data.ls_star_progress[i] ~= nil then
            T_data.ls_star_progress[key] = T_data.ls_star_progress[i]
        end
    end
    return T_data
end

local function _init_lingshou_pool(T_data)
    T_data.ls_pool = T_data.ls_pool or {}
    local total = 0
    local perPet = _toint(_config.pool_per_pet, 9)
    for i = 1, 5 do
        local key = tostring(i)
        local left = tonumber(T_data.ls_pool[key])
        if left == nil then left = tonumber(T_data.ls_pool[i]) end
        if left == nil then left = perPet end
        if left < 0 then left = 0 end
        T_data.ls_pool[key] = left
        total = total + left
    end
    T_data.ls_pool_total = total
    return T_data
end

local function _draw_lingshou_pool(T_data)
    _init_lingshou_pool(T_data)
    local total = tonumber(T_data.ls_pool_total or 0) or 0
    if total <= 0 then
        return nil
    end
    local pick = math.random(total)
    local cursor = 0
    for i = 1, 5 do
        local key = tostring(i)
        cursor = cursor + (tonumber(T_data.ls_pool[key] or 0) or 0)
        if pick <= cursor then
            T_data.ls_pool[key] = math.max(0, (tonumber(T_data.ls_pool[key] or 0) or 0) - 1)
            T_data.ls_pool_total = total - 1
            return i
        end
    end
    return nil
end
local function _is_lingshou_contract_open(play, T_data)
    T_data = _ensure_pet_data(T_data)
    if _toint(T_data.dqzh) > 0 then
        return false, "已出战灵兽，无需再领取灵兽契约#57"
    end
    if _toint(T_data.baby_choice) > 0 then
        return true
    end
    if _rebirth_level(play) >= 25 then
        return true
    end
    return false, "完成三阶转生·五重后，才可领取灵兽蛋"
end
local function _has_pet_synergy(play, T_data)
    T_data = T_data or {}
    local idx = tonumber(T_data.dqzh or 0) or 0
    local cfg = _config.config and _config.config.ls and _config.config.ls[idx]
    if not cfg then return false end
    if (tonumber((T_data.ls or {})[tostring(idx)] or 0) or 0) <= 0 then return false end
    local syw = T_data.syw or {}
    if (tonumber(syw[tostring(idx)] or syw[idx] or 0) or 0) ~= 1 then return false end
    return true
end
local function _push_hatch_log(T_data, idx, itemName, source, beforeStar, afterStar)
    T_data.hatch_log = T_data.hatch_log or {}
    table.insert(T_data.hatch_log, 1, {
        idx = idx,
        item = itemName,
        source = source,
        time = os.time(),
        before = beforeStar,
        after = afterStar,
    })
    while #T_data.hatch_log > 20 do
        table.remove(T_data.hatch_log)
    end
end

local function _refresh_pet_panel(play, npcid, p2, T_data)
    sendluamsg(play, 100, npcid or 64, p2 or 1, 0, tbl2json({T_data = T_data, server_time = os.time()}))
end

local LINGSHOU_SUMMON_IDX_VAR = 'N$lingshou_summoned_idx'
local LINGSHOU_SUMMON_UNTIL_VAR = 'N$lingshou_summoned_until'

local function _clear_lingshou_summon(play)
    setplaydef(play, LINGSHOU_SUMMON_IDX_VAR, 0)
    setplaydef(play, LINGSHOU_SUMMON_UNTIL_VAR, 0)
end

local function _check_lingshou_summon_expired(play)
    local summonUntil = tonumber(getplaydef(play, LINGSHOU_SUMMON_UNTIL_VAR) or 0) or 0
    if summonUntil > 0 and summonUntil <= os.time() then
        _clear_lingshou_summon(play)
        return true
    end
    return false
end

local function _start_lingshou_summon(play, petIdx, duration)
    local summonTime = math.max(0, _toint(duration))
    if summonTime <= 0 then
        _clear_lingshou_summon(play)
        return
    end
    setplaydef(play, LINGSHOU_SUMMON_IDX_VAR, petIdx)
    setplaydef(play, LINGSHOU_SUMMON_UNTIL_VAR, os.time() + summonTime)
    delaygoto(play, summonTime * 1000 + 100, "@lingshou_summon_timeout")
end

function lingshou_summon_timeout(play)
    local summonUntil = tonumber(getplaydef(play, LINGSHOU_SUMMON_UNTIL_VAR) or 0) or 0
    local leftTime = summonUntil - os.time()
    if leftTime <= 0 then
        _clear_lingshou_summon(play)
    else
        delaygoto(play, leftTime * 1000 + 100, "@lingshou_summon_timeout")
    end
end
local PET_INTIMACY_ATTR_LIST = "灵兽亲密度"

local PET_BASE_ATTR_LIST = "灵兽本体属性"

local function _refresh_pet_base_bonus(play, T_data)
    T_data = _ensure_pet_data(T_data)
    local attrs = {}
    local petCfgList = _config.config and _config.config.ls or {}
    for i = 1, 5 do
        local key = tostring(i)
        if _toint(T_data.ls[key] or T_data.ls[i]) > 0 then
            local petCfg = petCfgList[i] or {}
            for _, one in ipairs(petCfg.attr_give or {}) do
                local attrId = tonumber(one[1])
                local value = tonumber(one[2]) or 0
                if attrId and value ~= 0 then
                    attrs[attrId] = (attrs[attrId] or 0) + value
                end
            end
        end
    end
    Player.del_attlist(play, PET_BASE_ATTR_LIST)
    local attrsStr = Player.getAttrTableToStr(attrs)
    if attrsStr and attrsStr ~= "" then
        Player.add_attlist(play, PET_BASE_ATTR_LIST, "=", attrsStr, 1)
    end
end

local function _refresh_pet_intimacy_bonus(play, T_data)
    T_data = _ensure_pet_data(T_data)
    local attrs = {}
    local det = _config.config and _config.config.wy and _config.config.wy.det or {}
    for i = 1, 5 do
        local level = _toint(T_data.ls[tostring(i)] or T_data.ls[i])
        local levelCfg = det[level]
        for _, one in ipairs((levelCfg and levelCfg.attr) or {}) do
            local attrId = tonumber(one[1])
            local value = tonumber(one[2]) or 0
            if attrId and value ~= 0 then
                attrs[attrId] = (attrs[attrId] or 0) + value
            end
        end
    end
    Player.del_attlist(play, PET_INTIMACY_ATTR_LIST)
    local attrsStr = Player.getAttrTableToStr(attrs)
    if attrsStr and attrsStr ~= "" then
        Player.add_attlist(play, PET_INTIMACY_ATTR_LIST, "=", attrsStr, 1)
    end
end

local function _add_lingshou_star(play, idx, source, itemName)
    idx = tonumber(idx)
    local cfg = idx and LINGSHOU_BABY_CFG[idx]
    if not cfg or not _config.config or not _config.config.ls or not _config.config.ls[idx] then
        return false, "灵兽幼崽配置异常#57"
    end
    local T_data = _ensure_pet_data(Player.getJsonTableByVar(play, VarCfg["T_灵兽"]))
    local key = tostring(idx)
    local beforeStar = _toint(T_data.ls_sp[key])
    local beforeProgress = _get_star_progress(T_data, key, beforeStar)
    local maxStar = _toint(_config.max_star, 3)
    if beforeStar >= maxStar then
        return false, "该灵兽星级已满，无法继续孵化#57"
    end
    if _toint(T_data.ls[key]) <= 0 then
        T_data.ls[key] = 1
    end
    local _, to3 = _star_upgrade_need()
    local progress = beforeStar > 0 and math.min(to3, beforeProgress + 1) or 1
    T_data.ls_star_progress[key] = progress
    T_data.ls_sp[key] = math.min(maxStar, beforeStar > 0 and _star_from_progress(progress) or 1)
    if T_data.hatch and T_data.hatch[key] then
        T_data.hatch[key].status = "done"
        T_data.hatch[key].doneAt = os.time()
        T_data.hatch[key].source = source
    end
    _push_hatch_log(T_data, idx, itemName or cfg.item, source or "unknown", beforeStar, T_data.ls_sp[key])
    Player.setJsonTableByVar(play, VarCfg["T_灵兽"], T_data)
    if FairyFate and FairyFate.touch then FairyFate.touch(play, "pet") end
    _refresh_pet_base_bonus(play, T_data)
    _refresh_pet_intimacy_bonus(play, T_data)
    TMLP_refresh_pet_bonus(play)
    _clear_lingshou_summon(play)
    return true, string.format("灵兽|【%s】#218|孵化成功，当前星级|【%d】#218|%s", cfg.pet, T_data.ls_sp[key], _star_progress_text(progress)), T_data
end


local function _settle_due_hatch(play, aheadSeconds, silent)
    local T_data = _ensure_pet_data(Player.getJsonTableByVar(play, VarCfg["T_灵兽"]))
    local now = os.time()
    local deadline = now + math.max(0, _toint(aheadSeconds, 0))
    local changed = false
    local lastMsg = nil
    for key, hatch in pairs(T_data.hatch or {}) do
        if type(hatch) == "table" and hatch.status == "hatching" then
            local expireAt = _toint(hatch.expireAt, 0)
            local idx = _toint(key, 0)
            if idx > 0 and expireAt > 0 and expireAt <= deadline then
                local ok, msg, newData = _add_lingshou_star(play, idx, "timer", hatch.item)
                if ok and newData then
                    T_data = _ensure_pet_data(newData)
                    changed = true
                    lastMsg = msg
                else
                    hatch.status = "failed"
                    hatch.doneAt = now
                    hatch.failMsg = msg or "孵化失败"
                    changed = true
                end
            end
        end
    end
    if changed then
        Player.setJsonTableByVar(play, VarCfg["T_灵兽"], T_data)
        _refresh_pet_panel(play, 64, 6, T_data)
        if not silent then
            Player.sendmsgEx(play, lastMsg or "灵兽幼崽孵化完成#57")
        end
    end
    return changed
end

function npc.checkBabyHatch(play, aheadSeconds, silent)
    return _settle_due_hatch(play, aheadSeconds, silent)
end
function TMLP_refresh_pet_bonus(play)
    local T_data = _ensure_pet_data(Player.getJsonTableByVar(play, VarCfg["T_灵兽"]))
    local stars = T_data.ls_sp or {}
    local minStar = 3
    for i = 1, 5 do
        local star = tonumber(stars[tostring(i)] or stars[i] or 0) or 0
        if star < minStar then minStar = star end
    end
    local attrs = {}
    Player.del_attlist(play, "lingshou_bond")
    Player.del_attlist(play, "灵兽_星级加成")
    local bond = _config.bond_attr and _config.bond_attr[minStar] or nil
    for _, one in ipairs(bond or {}) do
        local attrId = tonumber(one[1])
        local value = tonumber(one[2]) or 0
        if attrId and value ~= 0 then
            attrs[attrId] = (attrs[attrId] or 0) + value
        end
    end
    local attrsstr = Player.getAttrTableToStr(attrs)
    if attrsstr and attrsstr ~= "" then
        Player.add_attlist(play, "lingshou_bond", "=", attrsstr, 1)
    end
end
function npc.syncContractState(play)
    _settle_due_hatch(play, 0, true)
    local T_data = _ensure_pet_data(Player.getJsonTableByVar(play, VarCfg["T_灵兽"]))
    _init_lingshou_pool(T_data)
    Player.setJsonTableByVar(play, VarCfg["T_灵兽"], T_data)
    sendluamsg(play,100,64,0,0,tbl2json({T_data = T_data, server_time = os.time(), sync_only = 1, main_unlocked = Player.dl_sz_notip(play, 4) and 1 or 0}))
end
function npc.main(play,npcid)
    local contractOnly = tonumber(npcid) == 1064
    local T_data = _ensure_pet_data(Player.getJsonTableByVar(play, VarCfg["T_灵兽"]))
    _init_lingshou_pool(T_data)
    Player.setJsonTableByVar(play, VarCfg["T_灵兽"], T_data)
    if contractOnly then
        _settle_due_hatch(play, 0, true)
        T_data = Player.getJsonTableByVar(play, VarCfg["T_灵兽"])
    end
    local mainUnlocked = Player.dl_sz_notip(play, 4) and 1 or 0
    if not contractOnly and mainUnlocked ~= 1 then
        Player.sendmsgEx(play, "四大陆解锁后，才可打开灵兽主界面#57")
        return
    end
    if contractOnly then
        local ok, msg = _is_lingshou_contract_open(play, T_data)
        if not ok then
            local syncData = {}
            syncData["T_data"] = T_data
            syncData["server_time"] = os.time()
            syncData["main_unlocked"] = mainUnlocked
            sendluamsg(play,100,64,0,0,tbl2json(syncData))
            if not ((tonumber(T_data and T_data.dqzh or 0) or 0) > 0) then
                Player.sendmsgEx(play, msg)
            end
            return
        end
    end
    local data = {}
    data["T_data"] = T_data
    data["server_time"] = os.time()
    data["main_unlocked"] = mainUnlocked
    if contractOnly then data["open_contract"] = 1 end
    sendluamsg(play,100,npcid == 69 and 69 or 64,0,0,tbl2json(data))
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
    local __guardAllowedActions = Guard.newActionSet({1,2,3,4,5,6,7,8})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end
    if ew == 8 then -- 灵兽静默同步：只回传数据，不打开界面
        _settle_due_hatch(play, 0, true)
        local syncData = Player.getJsonTableByVar(play, VarCfg["T_灵兽"])
        sendluamsg(play,100,64,0,0,tbl2json({T_data = syncData, server_time = os.time(), sync_only = 1, main_unlocked = Player.dl_sz_notip(play, 4) and 1 or 0}))
        return
    end
    local json_data = json2tbl(data) or {}
    local T_data = _ensure_pet_data(Player.getJsonTableByVar(play, VarCfg["T_灵兽"]))

    if ew ~= 1 then
        local idx = tonumber(json_data.idx)
        if not idx or not _config.config or not _config.config.ls or not _config.config.ls[idx] then
            Player.sendmsgEx(play, "参数错误#57")
            return
        end
        json_data.idx = idx
    end

    if ew == 1 then -- 抽取灵兽
        local name, num = Player.checkItemNumByTable(play, _config.cost)
        if name then
            Player.sendmsgEx(play, string.format("你的#57|【%s】#218|不足：#57|【%d】#218|", name, num))
            return
        end
        local randomNum = _draw_lingshou_pool(T_data)
        if not randomNum then
            Player.sendmsgEx(play, "已经集齐所有灵兽了#57")
            return
        end
        Player.takeItemByTable(play, _config.cost, "灵兽抽取", nil)
        local to2, to3 = _star_upgrade_need()
        T_data.ls = T_data.ls or {}
        T_data.ls_sp = T_data.ls_sp or {}
        T_data.ls_star_progress = T_data.ls_star_progress or {}
        if _toint(T_data.ls[""..randomNum]) <= 0 then
            T_data.ls[""..randomNum] = 1
            T_data.ls_sp[""..randomNum] = 1
            T_data.ls_star_progress[""..randomNum] = 1
            Player.setJsonTableByVar(play, VarCfg["T_灵兽"], T_data)
            _refresh_pet_base_bonus(play, T_data)
            _refresh_pet_intimacy_bonus(play, T_data)
            TMLP_refresh_pet_bonus(play)
            Player.sendmsgEx(play, string.format("你成功抽取到灵兽|【%s】#218|%s", _config.config.ls[randomNum].name, _star_progress_text(1)))
            Player.sendmsgEx(play, "你已获得该灵兽的|【初始星级】#218|，快去召唤它吧")
            if FairyFate and FairyFate.touch then FairyFate.touch(play, "pet") end
            sendluamsg(play,100,npcid,1,0,tbl2json({T_data = T_data, server_time = os.time()}))
        else
        -- 最大星级以配置 max_star 为准
            local starKey = ""..randomNum
            local curStar = _toint(T_data.ls_sp[starKey], 1)
            local currentProgress = _get_star_progress(T_data, starKey, curStar)
            local maxStar = _toint(_config.max_star, 3)
            if curStar >= maxStar then
                Player.setJsonTableByVar(play, VarCfg["T_灵兽"], T_data)
                Player.sendmsgEx(play, string.format("你抽取到的灵兽|【%s】#218", _config.config.ls[randomNum].name))
                Player.rwjl(play, {{"灵石",500},{"妖怪精魄",10}}, "灵兽抽取",1,1000)
                return
            end

            local progress = math.min(to3, currentProgress + 1)
            T_data.ls_star_progress[starKey] = progress
            T_data.ls_sp[starKey] = math.min(maxStar, _star_from_progress(progress))
            Player.setJsonTableByVar(play, VarCfg["T_灵兽"], T_data)
            _refresh_pet_base_bonus(play, T_data)
            _refresh_pet_intimacy_bonus(play, T_data)
            TMLP_refresh_pet_bonus(play)
            Player.sendmsgEx(play, string.format("你成功抽取到灵兽|【%s】#218|%s", _config.config.ls[randomNum].name, _star_progress_text(progress)))
            if FairyFate and FairyFate.touch then FairyFate.touch(play, "pet") end
            sendluamsg(play,100,npcid,1,0,tbl2json({T_data = T_data, server_time = os.time()}))
        end
        -- T_data.ls_sp[randomNum] = (T_data.ls_sp[randomNum] or 0) + 1
        -- Player.setJsonTableByVar(play, VarCfg["T_灵兽"], T_data)
        -- sendluamsg(play, 100, npcid, 1, randomNum, "")
    elseif ew == 2 then -- 召唤灵兽
        T_data.ls = T_data.ls or {}
        T_data.ls_sp = T_data.ls_sp or {}
        T_data.ls_star_progress = T_data.ls_star_progress or {}
        if not T_data.ls[""..json_data.idx] or T_data.ls[""..json_data.idx] <= 0 then
            Player.sendmsgEx(play, "你没有该灵兽，请先抽取灵兽#57")
            return
        end
        T_data.dqzh = json_data.idx
        _clear_lingshou_summon(play)
        Player.setJsonTableByVar(play, VarCfg["T_灵兽"], T_data)
        if FairyFate and FairyFate.touch then FairyFate.touch(play, "pet") end
        Player.sendmsgEx(play, string.format("你成功出战了灵兽|【%s】#218|，快去战斗吧！", _config.config.ls[json_data.idx].name))
        _refresh_pet_panel(play, npcid, 2, T_data)
    elseif ew == 3 then -- 灵兽升级 --喂养
        T_data.ls = T_data.ls or {}
        -- T_data.ls_sp 
        T_data.ls_sp = T_data.ls_sp or {}
        T_data.ls_star_progress = T_data.ls_star_progress or {}
        if not T_data.ls[""..json_data.idx] or T_data.ls[""..json_data.idx] <= 0 then
            Player.sendmsgEx(play, "你没有该灵兽，请先抽取灵兽#57")
            return
        end

        if T_data.ls[""..json_data.idx] >= _config.config.wy.max_level then
            Player.sendmsgEx(play, "该灵兽已达最大亲密度，无法继续培养#57")
            return
        end
        local name, num = Player.checkItemNumByTable(play, _config.config.wy.cost[T_data.ls[""..json_data.idx] + 1] or {})
        if name then
            Player.sendmsgEx(play, string.format("你的#57|【%s】#218|不足：#57|【%d】#218|", name, num))
            return
        end
        Player.takeItemByTable(play, _config.config.wy.cost[T_data.ls[""..json_data.idx] + 1] or {}, ",灵兽喂养",nil)
        T_data.ls[""..json_data.idx] = T_data.ls[""..json_data.idx] + 1
        Player.setJsonTableByVar(play, VarCfg["T_灵兽"], T_data)
        if FairyFate and FairyFate.touch then FairyFate.touch(play, "pet") end
        _refresh_pet_intimacy_bonus(play, T_data)
        TMLP_refresh_pet_bonus(play)
        sendluamsg(play,100,npcid,3,0,tbl2json({T_data = T_data, server_time = os.time()}))
        Player.sendmsgEx(play, string.format("你成功喂养灵兽|【%s】#218|，当前亲密度|【%d】#218", _config.config.ls[json_data.idx].name, T_data.ls[""..json_data.idx]))
    elseif ew == 4 then -- 灵兽升星
    elseif ew == 6 then -- 灵兽契约：领取36小时幼崽
        T_data = _ensure_pet_data(T_data)
        local openOk, openMsg = _is_lingshou_contract_open(play, T_data)
        if not openOk then
            Player.sendmsgEx(play, openMsg)
            return
        end
        local cfg = LINGSHOU_BABY_CFG[json_data.idx]
        if not cfg then
            Player.sendmsgEx(play, "灵兽幼崽配置异常#57")
            return
        end
        local key = tostring(json_data.idx)
        if T_data.baby_choice then
            Player.sendmsgEx(play, "灵兽契约只能领取一次，无法重复选择幼崽#57")
            return
        end
        local maxStar = _toint(_config.max_star, 3)
        if _toint(T_data.ls_sp[key]) >= maxStar then
            Player.sendmsgEx(play, "该灵兽星级已满，无法继续领取幼崽#57")
            return
        end
        T_data.baby_choice = json_data.idx
        T_data.hatch[key] = {item = cfg.item, startAt = os.time(), expireAt = os.time() + LINGSHOU_BABY_SECONDS, status = "hatching"}
        Player.setJsonTableByVar(play, VarCfg["T_灵兽"], T_data)
        if Player.trySyncSecondContinentXyl then Player.trySyncSecondContinentXyl(play) end
        if zxrw_try_finish_current_mainline then zxrw_try_finish_current_mainline(play, "任务") end
        Player.sendmsgEx(play, string.format("已选择|【%s】#218|，36小时后自动孵化#57", cfg.item))
        _refresh_pet_panel(play, npcid, 6, T_data)
    elseif ew == 7 then -- 灵兽契约：真实累计充值99元立即点化
        T_data = _ensure_pet_data(T_data)
        local choice = _toint(T_data.baby_choice)
        if choice <= 0 then
            Player.sendmsgEx(play, "请先选择灵兽幼崽后再点化#57")
            return
        end
        if json_data.idx ~= choice then
            Player.sendmsgEx(play, "当前点化灵兽与已选择幼崽不一致#57")
            return
        end
        if _real_charge(play) < 99 then
            Player.sendmsgEx(play, string.format("真实累计充值达到99元后，才可立即点化灵兽幼崽，当前%d元#57", _real_charge(play)))
            return
        end
        local key = tostring(choice)
        local hatch = T_data.hatch and T_data.hatch[key]
        if type(hatch) ~= "table" or hatch.status ~= "hatching" then
            Player.sendmsgEx(play, "当前灵兽幼崽已完成孵化，无需重复点化#57")
            return
        end
        local ok, msg, newData = _add_lingshou_star(play, choice, "quick", hatch.item)
        Player.sendmsgEx(play, msg or (ok and "灵兽幼崽点化成功#57" or "灵兽幼崽点化失败#57"))
        if ok and newData then
            _refresh_pet_panel(play, npcid, 6, newData)
        end
    elseif ew == 5 then -- 灵兽装备圣遗物
        T_data.ls = T_data.ls or {}
        -- T_data.ls_sp 
        T_data.syw = T_data.syw or {}
        if not T_data.ls[""..json_data.idx] or T_data.ls[""..json_data.idx] <= 0 then
            Player.sendmsgEx(play, "你没有该灵兽，请先抽取灵兽#57")
            return
        end
        if T_data.syw[""..json_data.idx] and T_data.syw[""..json_data.idx] == 1 then
            Player.sendmsgEx(play, "该灵兽已装备圣遗物，无需重复装备#57")
            return
        end
        local name, num = Player.checkItemNumByTable(play, {{_config.config.ls[json_data.idx].syw,1}})
        if name then
            Player.sendmsgEx(play, string.format("你的#57|【%s】#218|不足：#57|【%d】#218|", name, num))
            return
        end
        -- 圣遗物装备额外增加辉耀水晶消耗，和配置表要求保持一致。
        Player.takeItemByTable(play, {{_config.config.ls[json_data.idx].syw,1}}, ",灵兽圣遗物",nil)
        T_data.syw[""..json_data.idx] = 1
        Player.setJsonTableByVar(play, VarCfg["T_灵兽"], T_data)
        if FairyFate and FairyFate.touch then FairyFate.touch(play, "pet") end
        sendluamsg(play, 100, npcid, 1, 0, tbl2json({T_data = T_data, server_time = os.time()}))
        Player.sendmsgEx(play, string.format("你成功为灵兽|【%s】#218|装备了圣遗物|【%s】#218", _config.config.ls[json_data.idx].name, _config.config.ls[json_data.idx].syw))

        if T_data.syw["1"] and T_data.syw["2"] and T_data.syw["3"] and T_data.syw["4"] and T_data.syw["5"] and not T_data.syw_all then
            T_data.syw_all = 1
            Player.setJsonTableByVar(play, VarCfg["T_灵兽"], T_data)
            if FairyFate and FairyFate.touch then FairyFate.touch(play, "pet") end
            Player.title_give(play, _config.syw_ch)
            Player.sendmsgEx(play, "恭喜你为所有灵兽装备了圣遗物，获得称号：|【上古神兽掌控者】#218|")
            sendluamsg(play,100,npcid,1,0,"")
        end



    end
end

function Login_lszh(play)
    local T_data = _ensure_pet_data(Player.getJsonTableByVar(play, VarCfg["T_灵兽"]))
    T_data.ls = T_data.ls or {}
    for i = 1,5 do
        T_data.ls[""..i] = T_data.ls[""..i] or 0
    end
    _init_lingshou_pool(T_data)
    Player.setJsonTableByVar(play, VarCfg["T_灵兽"], T_data)
    _refresh_pet_base_bonus(play, T_data)
    _refresh_pet_intimacy_bonus(play, T_data)
    TMLP_refresh_pet_bonus(play)
    _clear_lingshou_summon(play)
    Buff[105](play,1)
    _settle_due_hatch(play, 60, true)
end
GameEvent.add(EventCfg.onLogin, Login_lszh, "灵兽召唤")

function npc.lscf(play,zt,Damage,Target)

    local sj = os.time()
    _check_lingshou_summon_expired(play)
    local T_data = _ensure_pet_data(Player.getJsonTableByVar(play, VarCfg["T_灵兽"]))
    T_data.ls = T_data.ls or {}
    local petIdx = tonumber(T_data.dqzh or 0) or 0
    local petCfg = _config.config and _config.config.ls and _config.config.ls[petIdx]
    local petLevel = _toint(T_data.ls[tostring(petIdx)])
    local levelCfg = _config.config and _config.config.wy and _config.config.wy.det and _config.config.wy.det[petLevel]
    if petIdx <= 0 or not petCfg or petLevel <= 0 or not levelCfg then
        return 0
    end
    do
        if sj - getplaydef(play,"N$buff_ls") >= 30 then
            local cw = recallmobex(play, petCfg.name,0,0,7,1,levelCfg.time,0,0,0,0,0,0,"")
            _start_lingshou_summon(play, petIdx, levelCfg.time)
            sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[灵兽]</font><font color=\'#00ff00\'>成功召唤灵兽【'..petCfg.name..'】...</font>","Type":9}')
            setplaydef(play,"N$buff_ls",sj)
        end
    end
    return 0
end


local function _get_baby_index_by_item_name(itemName)
    return LINGSHOU_BABY_ITEM_TO_IDX[tostring(itemName or "")]
end

function npc.getBabyIndexByItemName(itemName)
    return _get_baby_index_by_item_name(itemName)
end

function npc.useBabyItem(play, itemName)
    local idx = _get_baby_index_by_item_name(itemName)
    if not idx then
        return false, "该灵兽幼崽暂未配置#57"
    end
    if _real_charge(play) < 99 then
        return false, "真实累计充值达到99元后，才可立即孵化灵兽幼崽#57"
    end
    local ok, msg, T_data = _add_lingshou_star(play, idx, "use", itemName)
    if ok and T_data then
        _refresh_pet_panel(play, 64, 6, T_data)
    end
    return ok, msg
end

function npc.onBabyExpired(play, itemobj)
    local itemName = ""
    local okName, gotName = pcall(function()
        return getiteminfo(play, itemobj, ConstCfg.iteminfo.name) or getiteminfo(play, itemobj, 7)
    end)
    if okName and gotName then
        itemName = tostring(gotName)
    end
    if itemName == "" then
        local okBase, baseName = pcall(function()
            return getbaseinfo(itemobj, 1)
        end)
        if okBase and baseName then
            itemName = tostring(baseName)
        end
    end
    local idx = _get_baby_index_by_item_name(itemName)
    if not idx then
        return false
    end
    local ok, msg, T_data = _add_lingshou_star(play, idx, "expired", itemName)
    Player.sendmsgEx(play, msg or (ok and "灵兽幼崽孵化完成#57" or "灵兽幼崽孵化失败#57"))
    if ok and T_data then
        _refresh_pet_panel(play, 64, 6, T_data)
    end
    return ok
end
return npc
