npc = {}

-- 灵兽（仓库模式）

local _config = Guard.getConfig("npc_64")
local FairyFate = include("lua/LuaLib/fairy_fate.lua")

-- 仓库容量与星级上限
local _warehouse_cap = 140
local _max_star = tonumber(_config and _config.max_star or 3) or 3
if _max_star > 3 then
    _max_star = 3
end

local function _ensure_warehouse(T_data)
    T_data.warehouse = T_data.warehouse or {}
    T_data.warehouse_seq = tonumber(T_data.warehouse_seq or 0) or 0
    return T_data.warehouse
end

local function _new_uid(T_data)
    T_data.warehouse_seq = (tonumber(T_data.warehouse_seq or 0) or 0) + 1
    return T_data.warehouse_seq
end

local function _find_by_uid(warehouse, uid)
    if not uid then return nil end
    for i, it in ipairs(warehouse) do
        if it and tonumber(it.uid or 0) == tonumber(uid) then
            return it, i
        end
    end
    return nil
end

local function _get_item_by_slot(warehouse, slot)
    local idx = tonumber(slot)
    if not idx or idx < 1 then
        return nil
    end
    return warehouse[idx], idx
end

local function _get_item_from_json(T_data, json_data)
    local warehouse = _ensure_warehouse(T_data)
    if json_data and json_data.uid then
        return _find_by_uid(warehouse, json_data.uid)
    end
    if json_data and json_data.idx then
        return _get_item_by_slot(warehouse, json_data.idx)
    end
    return nil
end

-- 同种灵兽取最高喂养等级，用于属性生效
local function _get_type_best_feed(warehouse, pet_id)
    local best = 0
    for _, it in ipairs(warehouse) do
        if it and it.id == pet_id then
            local lv = tonumber(it.feed or 0) or 0
            if lv > best then
                best = lv
            end
        end
    end
    return best
end

local function _apply_feed_diff(play, old_best, new_best)
    if not _config or not _config.config or not _config.config.wy or not _config.config.wy.det then
        return
    end
    old_best = tonumber(old_best or 0) or 0
    new_best = tonumber(new_best or 0) or 0
    if old_best == new_best then
        return
    end
    local old_attr = _config.config.wy.det[old_best] and _config.config.wy.det[old_best].attr or nil
    local new_attr = _config.config.wy.det[new_best] and _config.config.wy.det[new_best].attr or nil
    Player.updateSomeAddr(play, old_attr, new_attr)
end

-- 旧数据迁移：把老的 ls/ls_sp 迁入仓库
local function _migrate_legacy(play, T_data)
    if T_data.warehouse then
        return T_data
    end
    local has_legacy = (type(T_data.ls) == "table") or (type(T_data.ls_sp) == "table")
    if not has_legacy then
        _ensure_warehouse(T_data)
        return T_data
    end

    local warehouse = _ensure_warehouse(T_data)
    local ls = T_data.ls or {}
    local ls_sp = T_data.ls_sp or {}
    for i = 1, 5 do
        local feed = tonumber(ls[""..i] or 0) or 0
        if feed > 0 then
            local star = tonumber(ls_sp[""..i] or 1) or 1
            star = star - 1
            if star < 0 then star = 0 end
            if star > _max_star then star = _max_star end
            local uid = _new_uid(T_data)
            table.insert(warehouse, {uid = uid, id = i, star = star, feed = feed, syw = 0})
        end
    end

    T_data.ls = nil
    T_data.ls_sp = nil

    if T_data.dqzh then
        -- 旧数据：dqzh=灵兽id，迁移为仓库中对应灵兽的uid（取第一只）
        local old_id = tonumber(T_data.dqzh) or 0
        if old_id > 0 then
            for _, it in ipairs(warehouse) do
                if it.id == old_id then
                    T_data.dqzh_uid = it.uid
                    break
                end
            end
        end
        T_data.dqzh = nil
    end

    return T_data
end

local function _get_summon_item(T_data)
    local warehouse = _ensure_warehouse(T_data)
    if T_data.dqzh_uid then
        local it = _find_by_uid(warehouse, T_data.dqzh_uid)
        if it then
            return it
        end
    end
    return nil
end

local function _try_apply_best_feed(play, T_data)
    local warehouse = _ensure_warehouse(T_data)
    local applied = {}
    for _, it in ipairs(warehouse) do
        if it and it.id and not applied[it.id] then
            local best = _get_type_best_feed(warehouse, it.id)
            if best > 0 then
                local attr = _config.config.wy.det[best] and _config.config.wy.det[best].attr or nil
                Player.updateSomeAddr(play, nil, attr)
            end
            applied[it.id] = true
        end
    end
end

function npc.main(play,npcid)
    if not Player.dl_sz(play, 4) then
        Player.sendMsg(play,'{"Msg":"<font color=\'#ff0000\'>灵兽系统需要达到四大陆后开启！</font>","Type":1}')
        return
    end
    local data = {}
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_灵兽"])
    T_data = _migrate_legacy(play, T_data)
    _ensure_warehouse(T_data)
    Player.setJsonTableByVar(play, VarCfg["T_灵兽"], T_data)
    data["T_data"] = T_data
    sendluamsg(play,100,npcid,0,0,tbl2json(data))
end

function npc.link(play,npcid,ew,aid,data)
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local __guardAction = Guard.normalizeAction(play, npcid, ew)
    if __guardAction == nil then
        return
    end
    ew = __guardAction
    local __guardAllowedActions = Guard.newActionSet({1,2,3,4,5})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end

    local json_data = json2tbl(data) or {}
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_灵兽"])
    T_data = _migrate_legacy(play, T_data)
    local warehouse = _ensure_warehouse(T_data)

    if ew ~= 1 then
        local it = _get_item_from_json(T_data, json_data)
        if not it then
            Player.sendmsgEx(play, "参数错误#57")
            return
        end
    end

    if ew == 1 then -- 抽取灵兽（仓库）
        if #warehouse >= _warehouse_cap then
            Player.sendmsgEx(play, "灵兽仓库已满，请先合成清理空位#57")
            return
        end
        local name, num = Player.checkItemNumByTable(play, _config.cost)
        if name then
            Player.sendmsgEx(play, string.format("你的#57|【%s】#249|不足：#57|【%d】#249|", name, num))
            return
        end
        Player.takeItemByTable(play, _config.cost, ",灵兽抽取",nil)
        local randomNum = ransjstr(_config.weight, 1, 3)
        randomNum = tonumber(randomNum)

        local old_best_before = _get_type_best_feed(warehouse, randomNum)

        local uid = _new_uid(T_data)
        local new_item = {uid = uid, id = randomNum, star = 0, feed = 1, syw = 0}
        table.insert(warehouse, new_item)

        -- 属性按原逻辑：拥有灵兽即获得对应喂养属性（取该类型最佳喂养）
        local new_best = _get_type_best_feed(warehouse, randomNum)
        _apply_feed_diff(play, old_best_before, new_best)

        Player.setJsonTableByVar(play, VarCfg["T_灵兽"], T_data)
        if FairyFate and FairyFate.touch then FairyFate.touch(play, "pet") end
        Player.sendmsgEx(play, string.format("你成功抽取到灵兽|【%s】#249|x1（0星）", _config.config.ls[randomNum].name))
        sendluamsg(play,100,npcid,1,0,tbl2json({T_data = T_data}))

    elseif ew == 2 then -- 召唤灵兽（仓库）
        -- 只允许出战一只，记录仓库 uid
        local it = _get_item_from_json(T_data, json_data)
        if not it then
            Player.sendmsgEx(play, "你没有该灵兽，请先抽取灵兽#57")
            return
        end
        T_data.dqzh_uid = it.uid
        Player.setJsonTableByVar(play, VarCfg["T_灵兽"], T_data)
        if FairyFate and FairyFate.touch then FairyFate.touch(play, "pet") end
        Login_lszh(play)
        local Tlg_data = Player.getJsonTableByVar(play, VarCfg["T_灵根"])
        if Tlg_data.main and (Tlg_data.main == _config.config.ls[it.id].yq[1] or Tlg_data.main == _config.config.ls[it.id].yq[2]) then
            Player.sendmsgEx(play, string.format("你成功出战了灵兽|【%s】#249|，快去战斗吧！", _config.config.ls[it.id].name))
        else
            Player.sendmsgEx(play, "你的主灵根与该灵兽的契约灵根冲突，可能无法出战该灵兽,请切换主灵根#57")
        end

    elseif ew == 3 then -- 灵兽喂养升级（仓库）
        local it = _get_item_from_json(T_data, json_data)
        if not it then
            Player.sendmsgEx(play, "你没有该灵兽，请先抽取灵兽#57")
            return
        end
        it.feed = tonumber(it.feed or 0) or 0
        if it.feed <= 0 then it.feed = 1 end
        if it.feed >= _config.config.wy.max_level then
            Player.sendmsgEx(play, "该灵兽已达最大喂养次数，无法继续喂养#57")
            return
        end
        local old_best = _get_type_best_feed(warehouse, it.id)
        local name, num = Player.checkItemNumByTable(play, _config.config.wy.cost[it.feed + 1] or {})
        if name then
            Player.sendmsgEx(play, string.format("你的#57|【%s】#249|不足：#57|【%d】#249|", name, num))
            return
        end
        Player.takeItemByTable(play, _config.config.wy.cost[it.feed + 1] or {}, ",灵兽喂养",nil)
        it.feed = it.feed + 1
        Player.setJsonTableByVar(play, VarCfg["T_灵兽"], T_data)
        if FairyFate and FairyFate.touch then FairyFate.touch(play, "pet") end
        local new_best = _get_type_best_feed(warehouse, it.id)
        _apply_feed_diff(play, old_best, new_best)
        sendluamsg(play,100,npcid,3,0,tbl2json({T_data = T_data}))
        Player.sendmsgEx(play, string.format("你成功喂养灵兽|【%s】#249|，当前喂养次数|【%d】#249", _config.config.ls[it.id].name, it.feed))

    elseif ew == 4 then -- 灵兽升星（仓库内 3 合 1）
        -- 仅同种同星三合一，保留喂养等级最高的那只
        local it = _get_item_from_json(T_data, json_data)
        if not it then
            Player.sendmsgEx(play, "你没有该灵兽，请先抽取灵兽#57")
            return
        end
        it.star = tonumber(it.star or 0) or 0
        if it.star >= _max_star then
            Player.sendmsgEx(play, "该灵兽已达最高星级#57")
            return
        end
        -- 需要两只同类型同星级
        local same = {}
        for _, v in ipairs(warehouse) do
            if v and v.id == it.id and tonumber(v.star or 0) == it.star then
                table.insert(same, v)
            end
        end
        if #same < 3 then
            Player.sendmsgEx(play, "仅可同种同星三合一，当前不足3只#57")
            return
        end
        -- 选择属性最好的（喂养等级最高）
        local keep = same[1]
        for _, v in ipairs(same) do
            local f1 = tonumber(keep.feed or 0) or 0
            local f2 = tonumber(v.feed or 0) or 0
            if f2 > f1 then
                keep = v
            end
        end
        -- 移除另外两只
        local removed = 0
        for i = #warehouse, 1, -1 do
            local v = warehouse[i]
            if v and v.id == it.id and tonumber(v.star or 0) == it.star then
                if v.uid ~= keep.uid and removed < 2 then
                    if T_data.dqzh_uid and T_data.dqzh_uid == v.uid then
                        T_data.dqzh_uid = keep.uid
                    end
                    table.remove(warehouse, i)
                    removed = removed + 1
                end
            end
        end
        keep.star = keep.star + 1
        if keep.star > _max_star then keep.star = _max_star end
        Player.setJsonTableByVar(play, VarCfg["T_灵兽"], T_data)
        Player.sendmsgEx(play, string.format("灵兽|【%s】#249|升星成功，当前星级：%d", _config.config.ls[it.id].name, keep.star))
        sendluamsg(play,100,npcid,1,0,tbl2json({T_data = T_data}))

    elseif ew == 5 then -- 灵兽装备圣遗物（按类型）
        local it = _get_item_from_json(T_data, json_data)
        if not it then
            Player.sendmsgEx(play, "你没有该灵兽，请先抽取灵兽#57")
            return
        end
        T_data.syw_type = T_data.syw_type or {}
        if T_data.syw_type[""..it.id] == 1 then
            Player.sendmsgEx(play, "该灵兽已装备圣遗物，无需重复装备#57")
            return
        end
        local name, num = Player.checkItemNumByTable(play, {{_config.config.ls[it.id].syw,1}})
        if name then
            Player.sendmsgEx(play, string.format("你的#57|【%s】#249|不足：#57|【%d】#249|", name, num))
            return
        end
        Player.takeItemByTable(play, {{_config.config.ls[it.id].syw,1},{"元宝",1880000},{"辉耀水晶",88}}, ",灵兽圣遗物",nil)
        T_data.syw_type[""..it.id] = 1
        it.syw = 1
        Player.setJsonTableByVar(play, VarCfg["T_灵兽"], T_data)
        if FairyFate and FairyFate.touch then FairyFate.touch(play, "pet") end
        sendluamsg(play, 100, npcid, 1, 0, tbl2json({T_data = T_data}))
        Player.sendmsgEx(play, string.format("你成功为灵兽|【%s】#249|装备了圣遗物|【%s】#249", _config.config.ls[it.id].name, _config.config.ls[it.id].syw))

        local all = true
        for i = 1, 5 do
            if T_data.syw_type[""..i] ~= 1 then
                all = false
                break
            end
        end
        if all and not T_data.syw_all then
            T_data.syw_all = 1
            Player.setJsonTableByVar(play, VarCfg["T_灵兽"], T_data)
            if FairyFate and FairyFate.touch then FairyFate.touch(play, "pet") end
            Player.title_give(play, _config.syw_ch)
            Player.sendmsgEx(play, "恭喜你为所有灵兽装备了圣遗物，获得称号：|【上古神兽掌控者】#249|")
            sendluamsg(play,100,npcid,1,0,"")
        end
    end
end

function Login_lszh(play)
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_灵兽"])
    T_data = _migrate_legacy(play, T_data)
    local warehouse = _ensure_warehouse(T_data)

    -- 重新应用每种灵兽的最佳喂养属性
    local applied = {}
    for _, it in ipairs(warehouse) do
        if it and it.id and not applied[it.id] then
            local best = _get_type_best_feed(warehouse, it.id)
            if best > 0 then
                local attr = _config.config.wy.det[best] and _config.config.wy.det[best].attr or nil
                Player.updateSomeAddr(play,nil, attr)
            end
            applied[it.id] = true
        end
    end

    local cur = _get_summon_item(T_data)
    if cur and _config.config.ls[cur.id] then
        Player.updateSomeAddr(play,nil, _config.config.ls[cur.id].attr_give)
    end

    Player.setJsonTableByVar(play, VarCfg["T_灵兽"], T_data)
    Buff[105](play,1)
end
GameEvent.add(EventCfg.onLogin, Login_lszh, "灵兽召唤")

function npc.lscf(play,zt,Damage,Target)
    local sj = os.time()
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_灵兽"])
    T_data = _migrate_legacy(play, T_data)
    local cur = _get_summon_item(T_data)
    if not cur or not _config.config.ls[cur.id] then
        return 0
    end
    local Tlg_data = Player.getJsonTableByVar(play, VarCfg["T_灵根"])
    if Tlg_data.main and (Tlg_data.main == _config.config.ls[cur.id].yq[1] or Tlg_data.main == _config.config.ls[cur.id].yq[2]) then
        if sj - getplaydef(play,"N$buff_ls") >= 30 then
            local time = _config.config.wy.det[cur.feed or 1] and _config.config.wy.det[cur.feed or 1].time or 10
            local cw = recallmobex(play, _config.config.ls[cur.id].name,0,0,7,1,time,0,0,0,0,0,0,"")
            sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[灵兽]</font><font color=\'#00ff00\'>成功召唤灵兽【'.._config.config.ls[cur.id].name..'】...</font>","Type":9}')
            setplaydef(play,"N$buff_ls",sj)
            Player.updateSomeAddr_time(play,nil, _config.config.ls[cur.id].b_attr, time)
        end
    end
    return 0
end

return npc