npc = {}


--npc名称：
--npc功能：
local _config = Guard.getConfig("npc_72")
local _weapon_level_var = VarCfg["T_时光之杖等级"] or "T57"

-- 统一读取时光之杖等级：优先新变量，其次兼容旧记录与装备字段。
local function _get_weapon_level(play)
    local recordLevel = tonumber(getplaydef(play, _weapon_level_var) or 0) or 0
    local oldLevel = tonumber(getplaydef(play, VarCfg["T_时光之杖"]) or 0) or 0
    local equipLevel = tonumber(Player.getEquipFieldByPos(play, _config.where, 1) or 0) or 0
    local equipName = tostring(Player.getEquipNameByPos(play, _config.where) or "")
    local nameLevel = tonumber(string.match(equipName, "Lv%.(%d+)") or string.match(equipName, "Lv(%d+)") or string.match(equipName, "%[lv(%d+)%]")) or 0
    local finalLevel = math.max(recordLevel, oldLevel, equipLevel, nameLevel)
    if finalLevel > 0 and recordLevel ~= finalLevel then
        setplaydef(play, _weapon_level_var, finalLevel)
    end
    return finalLevel
end

-- 重新挂载时光之杖附加属性，保证穿戴与鉴定后的属性一致。
local function _refresh_weapon_attr(play, itemobj)
    itemobj = itemobj or linkbodyitem(play, _config.where)
    if not itemobj or itemobj == "0" then
        return
    end
    local data = Player.getJsonTableByVar(play, VarCfg["T_时光之杖"]) or {}
    local attrs = {}
    for i = 1, 10 do
        attrs[teshudata["npc_72"].config[i].attrID] = (data["" .. i] or 0) * teshudata["npc_72"].config[i].ratio
    end
    local attrsstr = Player.getAttrTableToStr(attrs)
    setaddnewabil(play, -2, "=", attrsstr, itemobj)
    refreshitem(play, itemobj)
    recalcabilitys(play)
end

function npc.main(play,npcid)
    local data = {}
    data["dj_data"] = Player.getJsonTableByVar(play, VarCfg["T_时光之杖"])
    data["weapon_level"] = _get_weapon_level(play)
    sendluamsg(play,100,npcid,0,0,tbl2json(data))
end

function npc.link(play, npcid, p2, p3, msgData)

    -- npc_guard: 入参校验
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local __guardAction = Guard.normalizeAction(play, npcid, p2)
    if __guardAction == nil then
        return
    end
    p2 = __guardAction
    -- npc_guard: 操作白名单（优化：限定合法操作编号）
    local __guardAllowedActions = Guard.newActionSet({1, 2})
    if not Guard.ensureActionAllowed(play, npcid, p2, __guardAllowedActions) then
        return
    end

    if p2 == 1 then
        local jsonData = json2tbl(msgData) or {}

        local idx = tonumber(jsonData.idx)
        if not idx or not _config.config or not _config.config[idx] then
            Player.sendmsgEx(play, "参数错误#57")
            return
        end
        jsonData.idx = idx

        local itemobj = linkbodyitem(play, _config.where)
        if not itemobj or itemobj == "0" then
            Player.sendmsgEx(play, "请先装备时光之杖#57")
            return
        end

        local weaponLevel = _get_weapon_level(play)
        if weaponLevel < jsonData.idx then
            Player.sendmsgEx(play, "时光之杖等级不足，无法提升该属性#57")
            return
        end

        local dj_data = Player.getJsonTableByVar(play, VarCfg["T_时光之杖"]) or {}
        -- 记录每条属性的鉴定次数，限制前两次的随机上限。
        dj_data.__cnt = dj_data.__cnt or {}
        local idxStr = "" .. jsonData.idx
        dj_data[idxStr] = tonumber(dj_data[idxStr] or 0) or 0
        local curLevel = tonumber(dj_data[idxStr] or 0) or 0
        -- 没有历史次数但已有等级的，视为已完成至少三次，避免老玩家被强制降档。
        local identifyCnt = tonumber(dj_data.__cnt[idxStr])
        if identifyCnt == nil then
            identifyCnt = curLevel > 0 and 3 or 0
        end
        identifyCnt = identifyCnt + 1
        dj_data.__cnt[idxStr] = identifyCnt

        local maxLevel = tonumber(_config.config[jsonData.idx].max_level) or 1
        local limitRatio = 1
        if identifyCnt == 1 then
            limitRatio = 0.3
        elseif identifyCnt == 2 then
            limitRatio = 0.5
        end
        local maxRoll = math.floor(maxLevel * limitRatio)
        if maxRoll < 1 then
            maxRoll = 1
        elseif maxRoll > maxLevel then
            maxRoll = maxLevel
        end

        if dj_data[idxStr] >= maxLevel then
            Player.sendmsgEx(play, "等级已达到#57|【" .. dj_data[idxStr] .. "级】#218|，无需再提升#57")
            return
        end
        local name, num = Player.checkItemNumByTable(play, _config.cost)
        if name then
            Player.sendmsgEx(play, string.format("你的#57|【%s】#218|不足#57", name))
            return
        end
        Player.takeItemByTable(play, _config.cost, ",时光之杖", nil)
        dj_data[idxStr] = math.random(1, maxRoll)
        Player.setJsonVarByTable(play, VarCfg["T_时光之杖"], dj_data)

        _refresh_weapon_attr(play, itemobj)

        local data = {}
        data["dj_data"] = dj_data
        data["weapon_level"] = weaponLevel
        sendluamsg(play,100,npcid,1,0,tbl2json(data))
        Player.sendmsgEx(play, string.format("恭喜你，成功提升了|【%s】#218|到|【%d级】#218", _config.config[jsonData.idx].attr_desc, dj_data[idxStr]))
    elseif p2 == 2 then
    end
end

local function _onTakeOnEx(actor, itemobj, where, itemname, makeid)
    if where == _config.where then
        _get_weapon_level(actor)
        _refresh_weapon_attr(actor, itemobj)
    end
end
--穿装备触发
GameEvent.add(EventCfg.onTakeOnEx, _onTakeOnEx, "时光之杖附加属性")

return npc
