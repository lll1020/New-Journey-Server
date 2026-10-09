
npc = {}


--装备强化

local _config = Guard.getConfig("npc_28")
local FairyFate = include("lua/LuaLib/fairy_fate.lua")


function npc.main(play,npcid)
    local data = {}
    for k,v in pairs(_config.where) do
        data[k] = tonumber(getplaydef(play, VarCfg["U_装备强化_"..v[1]]) or 0) or 0
    end
    sendluamsg(play,100,npcid,0,0,tbl2json(data))
end

function npc.link(play,npcid,ew,aid)
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
    local __guardAllowedActions = Guard.newActionSet({1})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end

    if ew == 1 then
        if _config.where[aid] then
            local itemobj = linkbodyitem(play, aid)
            if itemobj then
                --getitemaddvalue(play, itemobj, 2, 3)
                local level = getplaydef(play, VarCfg["U_装备强化_".._config.where[aid][1]])
                if level >= _config.max_level then
                    Player.sendmsgEx(play, "该部位装备强化已达最高等级")
                    return
                end
                local nextLevel = level + 1
                local cfg = _config.details[nextLevel]
                local freeChance = FairyFate and FairyFate.getStrengthFreeChance and FairyFate.getStrengthFreeChance(play) or 0
                local isFree = freeChance > 0 and math.random(10000) <= tonumber(freeChance)
                if not isFree then
                    local name, num = Player.checkItemNumByTable(play, cfg.cost)
                    if name then
                        Player.sendmsgEx(play, string.format("你的#57|【%s】#218|不足：#57|【%d】#218|", name, num))
                        return
                    end
                    Player.takeItemByTable(play, cfg.cost, ",装备强化",nil)
                end
                setplaydef(play, VarCfg["U_装备强化_".._config.where[aid][1]], nextLevel)
                setitemaddvalue(play, itemobj, 2, 3, nextLevel) --星星
                --强化属性
                local attrs = {}
                local attrsstr = ""
                for k,v in ipairs(cfg.attr) do
                    attrs[v[1]] = v[2]
                end
                attrsstr = Player.getAttrTableToStr(attrs)
                _set_strength_custom_abil(play, itemobj, nextLevel, cfg.attr)
                refreshitem(play, itemobj)
                recalcabilitys(play)
                -- 二大陆伏妖录：装备强化成功后立即尝试自动结算当前任务。
                local xylCompleted = Player.trySyncSecondContinentXyl(play)
                if zxrw_try_finish_current_mainline then zxrw_try_finish_current_mainline(play, "任务") end
                if FairyFate and FairyFate.touch then FairyFate.touch(play, "strength_success") end
                sendluamsg(play,100,npcid,1,aid,"")
                if xylCompleted then
                    sendluamsg(play, 101, 9999, 0, 0, "npc_28")
                end

                if nextLevel == 10 or nextLevel == 20 or nextLevel == 30 then
                    Player.sendmsgEx(play, "恭喜你，|【".._config.where[aid][1].."】#218|部位的装备强化提升到了【"..nextLevel.."级】，属性大幅提升！")
                    Player.del_attlist(play, "装备强化")
                    Login_zbqh(play)
                else
                    Player.sendmsgEx(play, "恭喜你，|【".._config.where[aid][1].."】#218|部位的装备强化提升到了【"..nextLevel.."级】")
                end
            else
                Player.sendmsgEx(play, "请先穿戴#57|【对应部位装备】#218|")
                return
            end
        else
            Player.sendmsgEx(play, "参数错误!#57")
            return
        end

    end
end


--清理附加属性封装
local function _set_strength_custom_abil(actor, itemobj, level, attr)
    local ok, item_json = pcall(json2tbl, getitemcustomabil(actor, itemobj))
    item_json = ok and type(item_json) == "table" and item_json or {}
    item_json.abil = type(item_json.abil) == "table" and item_json.abil or {}
    local target = nil
    for index, one in ipairs(item_json.abil) do
        if type(one) == "table" and tonumber(one.i) == 5 then target = index break end
    end
    local values = {}
    local row_by_attr = {
        [1] = 1,
        [3] = 2, [4] = 2,
        [5] = 3, [6] = 3,
        [7] = 4, [8] = 4,
        [9] = 5, [10] = 5,
    }
    local next_row = 6
    for _, one in ipairs(attr or {}) do
        local attr_id = tonumber(one[1]) or 0
        local row = row_by_attr[attr_id]
        if not row then
            row = next_row
            next_row = next_row + 1
        end
        table.insert(values, {254, attr_id, tonumber(one[2]) or 0, 0, 0, row, #values})
    end
    target = target or (#item_json.abil + 1)
    item_json.abil[target] = {i = 5, t = "[强化属性]\\<IMG:3>\\强化等级:" .. tostring(level), c = 251, v = values}
    setitemcustomabil(actor, itemobj, tbl2json(item_json))
end
local function _clear_strength_custom_abil(actor, itemobj)
    local ok, item_json = pcall(json2tbl, getitemcustomabil(actor, itemobj))
    if not ok or type(item_json) ~= "table" or type(item_json.abil) ~= "table" then return end
    local kept = {}
    for _, one in ipairs(item_json.abil) do if not (type(one) == "table" and tonumber(one.i) == 5) then table.insert(kept, one) end end
    item_json.abil = kept
    setitemcustomabil(actor, itemobj, tbl2json(item_json))
end
--穿装备
local function _onTakeOnEx(actor, itemobj, where, itemname, makeid)
    if _config.where[where] then
        local level = getplaydef(actor, VarCfg["U_装备强化_".._config.where[where][1]])
        setitemaddvalue(actor, itemobj, 2, 3, level) --星星
        local cfg = _config.details[level]
        if level <= 0 then
            return
        end
        --强化属性
        local attrs = {}
        local attrsstr = ""
        for k,v in ipairs(cfg.attr) do
            attrs[v[1]] = v[2]
        end
        attrsstr = Player.getAttrTableToStr(attrs)
        _set_strength_custom_abil(actor, itemobj, level, cfg.attr)
        refreshitem(actor, itemobj)
        recalcabilitys(actor)
    end
end

--脱装备
local function _onTakeOffEx(actor, itemobj, where, itemname, makeid)
    setitemaddvalue(actor, itemobj, 2, 3, 0) --星星
    if _config.where[where] then
        _clear_strength_custom_abil(actor, itemobj)
        refreshitem(actor, itemobj)    end
end

function Login_zbqh(play)
    local data = {}
    local min = 99
    for k,v in pairs(_config.where) do
        data[k] = tonumber(getplaydef(play, VarCfg["U_装备强化_"..v[1]]) or 0) or 0
        if min > data[k] then
            min = data[k]
        end
    end
    if min ~= 99 and min > 0 then
        local attrs = {}
        local attrsstr = ""
        local idx = 0
        if min >= 30 then
            idx = 3
        elseif min >= 20 then
            idx = 2
        elseif min >= 10 then
            idx = 1
        end
        if idx == 0 then
            return
        end
        for v,k in ipairs(_config.other_attr[idx]) do
            attrs[k[1]] = k[2]
        end
        attrsstr = Player.getAttrTableToStr(attrs)
        Player.add_attlist(play, "装备强化", "=", attrsstr, 1)
    end
end
GameEvent.add(EventCfg.onLogin, Login_zbqh, "Login_zbqh")

--穿装备触发
GameEvent.add(EventCfg.onTakeOnEx, _onTakeOnEx, "装备强化")

--脱装备触发
GameEvent.add(EventCfg.onTakeOffEx, _onTakeOffEx, "装备强化")


return npc
