npc = {}

-- 屠夫：美食狂欢活动卖肉与积分兑换共用 NPC。
local _config = Guard.getConfig("npc_108") or teshudata["npc_108"] or {}
local _var_name = VarCfg["T_美食狂欢"]

local function _toint(v)
    return tonumber(v) or 0
end

local function _cfg()
    return MskhApi and MskhApi.get_cfg and MskhApi.get_cfg() or {}
end

local function _get_data(play)
    if MskhApi and MskhApi.get_player_data then
        return MskhApi.get_player_data(play)
    end
    local data = Player.getJsonTableByVar(play, _var_name) or {}
    data.point = _toint(data.point)
    data.shop_buy = type(data.shop_buy) == "table" and data.shop_buy or {}
    return data
end

local function _save_data(play, data)
    if MskhApi and MskhApi.save_player_data then
        MskhApi.save_player_data(play, data)
    else
        Player.setJsonVarByTable(play, _var_name, data)
    end
end

local function _get_buy_num(data, idx)
    return _toint((data.shop_buy or {})[tostring(idx)])
end

local function _count_item(play, itemName)
    return _toint(getbagitemcount(play, itemName, 0))
end

local function _has_title(play)
    local cfg = _cfg()
    local titleName = tostring((cfg and cfg.title_name) or "美食家")
    return titleName ~= "" and checktitle(play, titleName)
end

local function _build_meat_counts(play, cfg)
    local counts = {}
    for itemName, _ in pairs((cfg and cfg.meats) or {}) do
        counts[tostring(itemName)] = _count_item(play, itemName)
    end
    return counts
end

local function _build_payload(play, npcid, current_tab)
    local cfg = _cfg()
    local data = _get_data(play)
    local tab = tostring(current_tab or (_config and _config.default_tab) or "sell")
    return {
        default_tab = tostring((_config and _config.default_tab) or "sell"),
        current_tab = tab,
        point = _toint(data.point),
        score = _toint(getplayvar(play, "HUMAN", tostring((cfg and cfg.score_var) or "美食狂欢")) or 0),
        collect_total = _toint(data.collect_total),
        weapon_level = MskhApi and MskhApi.get_weapon_level and MskhApi.get_weapon_level(play) or 0,
        has_title = _has_title(play) and 1 or 0,
        meat_counts = _build_meat_counts(play, cfg),
        shop_buy = data.shop_buy or {},
        open = getsysvar(VarCfg["G_美食狂欢状态"]) == 1 and 1 or 0,
    }
end

function npc.main(play, npcid)
    sendluamsg(play, 100, npcid, 0, 0, tbl2json(_build_payload(play, npcid)))
    openhyperlink(play, 1, 2)
end

function npc.link(play, npcid, p2, p3, msgData)
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local action = Guard.normalizeAction(play, npcid, p2)
    if action == nil then
        return
    end
    p2 = action
    if not Guard.ensureActionAllowed(play, npcid, p2, Guard.newActionSet({1, 2, 9})) then
        return
    end
    local cfg = _cfg()
    local json_data = json2tbl(msgData) or {}
    if p2 == 1 then
        local itemName = tostring(json_data.name or json_data.item or "")
        local count = _toint(json_data.count or p3)
        if itemName == "" or count <= 0 then
            Player.sendmsgEx(play, "参数错误#57")
            return
        end
        if _count_item(play, itemName) < count then
            Player.sendmsgEx(play, "该肉类数量不足#57")
            return
        end
        if not MskhApi or not MskhApi.sell_meat or not MskhApi.sell_meat(play, itemName, count, cfg) then
            Player.sendmsgEx(play, "该物品无法出售#57")
            return
        end
        takeitem(play, itemName, count)
        sendluamsg(play, 100, npcid, 1, 0, tbl2json(_build_payload(play, npcid, "sell")))
    elseif p2 == 2 then
        local idx = _toint(json_data.idx or p3)
        if not MskhApi or not MskhApi.buy_shop or not MskhApi.buy_shop(play, idx, cfg) then
            return
        end
        sendluamsg(play, 100, npcid, 2, idx, tbl2json(_build_payload(play, npcid, "shop")))
    elseif p2 == 9 then
        sendluamsg(play, 100, npcid, 9, 0, tbl2json(_build_payload(play, npcid)))
    end
end

return npc
