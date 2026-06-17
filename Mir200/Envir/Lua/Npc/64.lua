npc = {}


--灵兽

local _config = Guard.getConfig("npc_64")
local FairyFate = include("lua/LuaLib/fairy_fate.lua")
local LINGSHOU_BABY_SECONDS = 48 * 3600
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

local function _real_charge(play)
    return math.max(_toint(querymoney(play, 23)), _toint(getplaydef(play, VarCfg["U_真实充值"])))
end

local function _ensure_pet_data(T_data)
    T_data = T_data or {}
    T_data.ls = T_data.ls or {}
    T_data.ls_sp = T_data.ls_sp or {}
    T_data.hatch = T_data.hatch or {}
    T_data.hatch_log = T_data.hatch_log or {}
    return T_data
end





local function _is_lingshou_contract_open(play, T_data)
    T_data = _ensure_pet_data(T_data)
    if _toint(T_data.dqzh) > 0 then
        return false, "已出战灵兽，无需再领取灵兽契约#57"
    end
    if _toint(T_data.baby_choice) > 0 then
        return true
    end
    local rwid = _toint(getplaydef(play, VarCfg.U_zxrw[1]))
    if rwid >= 28 then
        return true
    end
    return false, "请先推进主线至【灵兽孵化】#57"
end
local function _has_pet_linggen_synergy(play, T_data)
    T_data = T_data or {}
    local idx = tonumber(T_data.dqzh or 0) or 0
    local cfg = _config.config and _config.config.ls and _config.config.ls[idx]
    if not cfg then return false end
    if (tonumber((T_data.ls or {})[tostring(idx)] or 0) or 0) < 2 then return false end
    local lg = Player.getJsonTableByVar(play, VarCfg["T_灵根"]) or {}
    local main = tonumber(lg.main or 0) or 0
    return main > 0 and (main == cfg.yq[1] or main == cfg.yq[2])
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

local function _add_lingshou_star(play, idx, source, itemName)
    idx = tonumber(idx)
    local cfg = idx and LINGSHOU_BABY_CFG[idx]
    if not cfg or not _config.config or not _config.config.ls or not _config.config.ls[idx] then
        return false, "灵兽幼崽配置异常#57"
    end
    local T_data = _ensure_pet_data(Player.getJsonTableByVar(play, VarCfg["T_灵兽"]))
    local key = tostring(idx)
    local beforeStar = _toint(T_data.ls_sp[key])
    local maxStar = _toint(_config.max_star, 3)
    if beforeStar >= maxStar then
        return false, "该灵兽星级已满，无法继续孵化#57"
    end
    if _toint(T_data.ls[key]) <= 0 then
        T_data.ls[key] = 1
        Player.updateSomeAddr(play, nil, _config.config.wy.det[1] and _config.config.wy.det[1].attr or nil)
    end
    T_data.ls_sp[key] = math.min(maxStar, beforeStar + 1)
    if T_data.hatch and T_data.hatch[key] then
        T_data.hatch[key].status = "done"
        T_data.hatch[key].doneAt = os.time()
        T_data.hatch[key].source = source
    end
    _push_hatch_log(T_data, idx, itemName or cfg.item, source or "unknown", beforeStar, T_data.ls_sp[key])
    Player.setJsonTableByVar(play, VarCfg["T_灵兽"], T_data)
    if FairyFate and FairyFate.touch then FairyFate.touch(play, "pet") end
    TMLP_refresh_pet_bonus(play)
    return true, string.format("灵兽|【%s】#218|孵化成功，当前星级|【%d】#218", cfg.pet, T_data.ls_sp[key]), T_data
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
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_灵兽"]) or {}
    local ls = T_data.ls or {}
    local max_level = ((((teshudata or {})["npc_64"] or {}).config or {}).wy or {}).max_level or 0
    local attrs = {}
    Player.del_attlist(play, "天命道盘_灵兽加成")
    if max_level <= 0 then
        return
    end
    for idx, level in pairs(ls) do
        if (tonumber(level) or 0) >= max_level then
            local cfg = (_config.config and _config.config.ls and _config.config.ls[tonumber(idx)]) or nil
            local add = cfg and cfg.attr_give or nil
            for _, one in ipairs(add or {}) do
                local attr_id = tonumber(one[1])
                local value = tonumber(one[2]) or 0
                if attr_id and value ~= 0 then
                    attrs[attr_id] = (attrs[attr_id] or 0) + math.floor(value * 5 / 100)
                end
            end
        end
    end
    local attrsstr = Player.getAttrTableToStr(attrs)
    if attrsstr and attrsstr ~= "" then
        Player.add_attlist(play, "天命道盘_灵兽加成", "=", attrsstr, 1)
    end
end
function npc.main(play,npcid)
    local contractOnly = tonumber(npcid) == 1064
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_灵兽"])
    if contractOnly then
        _settle_due_hatch(play, 0, true)
        T_data = Player.getJsonTableByVar(play, VarCfg["T_灵兽"])
    end
    if (not contractOnly) and (not Player.dl_sz(play, 4)) then
        Player.sendmsgEx(play, "灵兽系统需要达到四大陆后开启！#57")
        return
    end
    if contractOnly then
        local ok, msg = _is_lingshou_contract_open(play, T_data)
        if not ok then
            Player.sendmsgEx(play, msg)
            return
        end
    end
    local data = {}
    data["T_data"] = T_data
    data["server_time"] = os.time()
    if contractOnly then data["open_contract"] = 1 end
    sendluamsg(play,100,64,0,0,tbl2json(data))
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
    local __guardAllowedActions = Guard.newActionSet({1,2,3,4,5,6})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end
    local json_data = json2tbl(data) or {}
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_灵兽"])

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
        Player.takeItemByTable(play, _config.cost, ",灵兽抽取",nil)
        local randomNum = ransjstr(_config.weight, 1, 3)
        randomNum = tonumber(randomNum)
        T_data.ls = T_data.ls or {}
        T_data.ls_sp = T_data.ls_sp or {}
        if not T_data.ls[""..randomNum] then
            T_data.ls[""..randomNum] = 1
            T_data.ls_sp[""..randomNum] = 1
            Player.sendmsgEx(play, string.format("你成功抽取到灵兽|【%s】#218|x1", _config.config.ls[randomNum].name))
            Player.sendmsgEx(play, "你已获得该灵兽的|【初始星级】#218|，快去召唤它吧")
            Player.setJsonTableByVar(play, VarCfg["T_灵兽"], T_data)
            if FairyFate and FairyFate.touch then FairyFate.touch(play, "pet") end
            sendluamsg(play,100,npcid,1,0,tbl2json({T_data = T_data, server_time = os.time()}))
            Player.updateSomeAddr(play,nil, _config.config.wy.det[T_data.ls[""..randomNum]].attr)
            TMLP_refresh_pet_bonus(play)
        else
        -- 最大星级4
            if T_data.ls_sp[""..randomNum] >= _config.max_star then
                Player.sendmsgEx(play, string.format("你抽取到的灵兽|【%s】#218|已达最大星级,转换为材料", _config.config.ls[randomNum].name))
                Player.rwjl(play, {{"若水宝玉",3},{"灵石",500},{"妖怪精魄",10}}, "灵兽抽取",1,1000)
                return
            end
            T_data.ls_sp[""..randomNum] = T_data.ls_sp[""..randomNum] + 1
            Player.sendmsgEx(play, string.format("你成功抽取到灵兽|【%s】#218|x1已自动转换为星级", _config.config.ls[randomNum].name))
            Player.setJsonTableByVar(play, VarCfg["T_灵兽"], T_data)
            if FairyFate and FairyFate.touch then FairyFate.touch(play, "pet") end
            sendluamsg(play,100,npcid,1,0,tbl2json({T_data = T_data, server_time = os.time()}))
        end
        -- T_data.ls_sp[randomNum] = (T_data.ls_sp[randomNum] or 0) + 1
        -- Player.setJsonTableByVar(play, VarCfg["T_灵兽"], T_data)
        -- sendluamsg(play, 100, npcid, 1, randomNum, "")
    elseif ew == 2 then -- 召唤灵兽
        T_data.ls = T_data.ls or {}
        T_data.ls_sp = T_data.ls_sp or {}
        if not T_data.ls[""..json_data.idx] or T_data.ls[""..json_data.idx] <= 0 then
            Player.sendmsgEx(play, "你没有该灵兽，请先抽取灵兽#57")
            return
        end
        local oldIdx = tonumber(T_data.dqzh)
        local oldAttr = oldIdx and _config.config.ls[oldIdx] and _config.config.ls[oldIdx].attr_give or nil
        local newAttr = _config.config.ls[json_data.idx].attr_give
        T_data.dqzh = json_data.idx
        Player.setJsonTableByVar(play, VarCfg["T_灵兽"], T_data)
        if FairyFate and FairyFate.touch then FairyFate.touch(play, "pet") end
        Player.updateSomeAddr(play, oldAttr, newAttr)
        Player.sendmsgEx(play, string.format("你成功出战了灵兽|【%s】#218|，快去战斗吧！", _config.config.ls[json_data.idx].name))
        _refresh_pet_panel(play, npcid, 2, T_data)
    elseif ew == 3 then -- 灵兽升级 --喂养
        T_data.ls = T_data.ls or {}
        -- T_data.ls_sp 
        T_data.ls_sp = T_data.ls_sp or {}
        if not T_data.ls[""..json_data.idx] or T_data.ls[""..json_data.idx] <= 0 then
            Player.sendmsgEx(play, "你没有该灵兽，请先抽取灵兽#57")
            return
        end

        if T_data.ls[""..json_data.idx] >= _config.config.wy.max_level then
            Player.sendmsgEx(play, "该灵兽已达最大喂养次数，无法继续喂养#57")
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
        Player.updateSomeAddr(play,_config.config.wy.det[T_data.ls[""..json_data.idx] - 1] and _config.config.wy.det[T_data.ls[""..json_data.idx] - 1].attr or nil, _config.config.wy.det[T_data.ls[""..json_data.idx]].attr)
        TMLP_refresh_pet_bonus(play)
        sendluamsg(play,100,npcid,3,0,tbl2json({T_data = T_data, server_time = os.time()}))
        Player.sendmsgEx(play, string.format("你成功喂养灵兽|【%s】#218|，当前喂养次数|【%d】#218", _config.config.ls[json_data.idx].name, T_data.ls[""..json_data.idx]))
    elseif ew == 4 then -- 灵兽升星
    elseif ew == 6 then -- 灵兽契约：领取48小时幼崽
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
        Player.sendmsgEx(play, string.format("已选择|【%s】#218|，48小时后自动孵化#57", cfg.item))
        _refresh_pet_panel(play, npcid, 6, T_data)
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
        Player.takeItemByTable(play, {{_config.config.ls[json_data.idx].syw,1},{"元宝",1880000},{"辉耀水晶",88}}, ",灵兽圣遗物",nil)
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
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_灵兽"])
    T_data.ls = T_data.ls or {}
    for i = 1,5 do
        T_data.ls[""..i] = T_data.ls[""..i] or 0
        if T_data.ls[""..i] > 0 then
            Player.updateSomeAddr(play,nil, _config.config.wy.det[T_data.ls[""..i]].attr)
        end
    end
    if T_data.dqzh and _config.config.ls[T_data.dqzh] then
        Player.updateSomeAddr(play,nil, _config.config.ls[T_data.dqzh].attr_give)
    end
    
    TMLP_refresh_pet_bonus(play)
    Buff[105](play,1)
    _settle_due_hatch(play, 60, true)
end
GameEvent.add(EventCfg.onLogin, Login_lszh, "灵兽召唤")

function npc.lscf(play,zt,Damage,Target)

    local sj = os.time()
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_灵兽"])
    T_data.ls = T_data.ls or {}
    
    if not T_data.dqzh or not _config.config.ls[T_data.dqzh] then
        return 0
    end
    do
        if sj - getplaydef(play,"N$buff_ls") >= 30 then
            local cw = recallmobex(play, _config.config.ls[T_data.dqzh].name,0,0,7,1,_config.config.wy.det[T_data.ls[""..T_data.dqzh]].time,0,0,0,0,0,0,"")
            sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[灵兽]</font><font color=\'#00ff00\'>成功召唤灵兽【'.._config.config.ls[T_data.dqzh].name..'】...</font>","Type":9}')
            setplaydef(play,"N$buff_ls",sj)
            if _has_pet_linggen_synergy(play, T_data) then
                Player.updateSomeAddr_time(play,nil, _config.config.ls[T_data.dqzh].b_attr,_config.config.wy.det[T_data.ls[""..T_data.dqzh]].time)
            end
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
