npc = {}


--npc名称：
--npc功能：
local _config = Guard.getConfig("npc_14")
local attrwz = {
    [4] = 21,
    [1] = 20,
    [244] = 23,
    [255] = 22,
    [242] = 24,
}


local function _get_item_json(play, itemobj)
    local ok, item_json = pcall(json2tbl, getitemcustomabil(play, itemobj))
    item_json = ok and type(item_json) == "table" and item_json or {}
    item_json.abil = type(item_json.abil) == "table" and item_json.abil or {}
    item_json.name = tostring(item_json.name or "")
    return item_json
end

local function _build_attr_list(attrs)
    local attr_list = {}
    if type(attrs) == "table" then
        for attrId, attrValue in pairs(attrs) do
            attrId = tonumber(attrId)
            attrValue = tonumber(attrValue) or 0
            if attrId and attrValue ~= 0 then
                table.insert(attr_list, {254, attrId, attrValue, attrId == 242 and 1 or 0, attrwz[attrId] or 9999, 1, 1})
            end
        end
    end
    table.sort(attr_list, function(a, b)
        return (tonumber(a[2]) or 0) < (tonumber(b[2]) or 0)
    end)
    return attr_list
end
local function _apply_xianshifang_abil(play, itemobj, attrs)
    if not itemobj or itemobj == "0" then
        return false
    end
    local tagIndex = 2
    local attr_list = _build_attr_list(attrs)

    for attr_idx = 0, 9 do
        changecustomitemvalue(play, itemobj, attr_idx, "=", 0, tagIndex)
    end
    for i, one in ipairs(attr_list) do
        Player.addModifyCustomAttributes(
            play,
            itemobj,
            tagIndex,
            i - 1,
            2,
            20,
            tonumber(one[2]) or 0,
            tonumber(one[5]) or 0,
            tonumber(one[4]) or 0,
            tonumber(one[3]) or 0
        )
    end

    local item_json = _get_item_json(play, itemobj)
    local idx = tagIndex + 1
    for fill = 1, idx do
        if type(item_json.abil[fill]) ~= "table" then
            item_json.abil[fill] = {i = fill - 1, t = "", c = 251, v = {}}
        end
    end
    item_json.abil[idx] = item_json.abil[idx] or {i = tagIndex, t = "", c = 251, v = {}}
    item_json.abil[idx].i = tagIndex
    item_json.abil[idx].t = "[小二倒酒]"
    item_json.abil[idx].c = 251
    setitemcustomabil(play, itemobj, tbl2json(item_json))
    refreshitem(play, itemobj)
    recalcabilitys(play)
    return true
end

function npc.main(play,npcid)
    local equipLevel = Player.getEquipFieldByPos(play, _config.where, 1) or 0
    if equipLevel == 0 then
        Player.sendmsgEx(play,  "请先装备酒葫芦#57")
        return
    end
    local data = {}
    data["dj_data"] = Player.getJsonTableByVar(play, VarCfg["T_仙食坊"])
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
        local jsonData = json2tbl(msgData)

        local idx = tonumber(jsonData and jsonData.idx)
        if not idx or not _config.config[idx] then
            Player.sendmsgEx(play, "参数错误#57")
            return
        end
        jsonData.idx = idx

        
        local equipLevel = Player.getEquipFieldByPos(play, _config.where, 1) or 0
        if equipLevel == 0 then
            Player.sendmsgEx(play,  "请先装备酒葫芦#57")
            return
        end

        local dj_data = Player.getJsonTableByVar(play, VarCfg["T_仙食坊"]) or {}
        dj_data[""..jsonData.idx] = dj_data[""..jsonData.idx] or 0
        if dj_data[""..jsonData.idx] >= _config.config[jsonData.idx].max_level then
            Player.sendmsgEx(play,  "等级已达到#57|【"..dj_data[""..jsonData.idx].."级】#218|，无需再提升#57")
            return
        end
        local name, num = Player.checkItemNumByTable(play, _config.config[jsonData.idx].cost)
        if name then
            Player.sendmsgEx(play, string.format("你的#57|【%s】#218|不足#57", name))
            return
        end
        Player.takeItemByTable(play, _config.config[jsonData.idx].cost, ",仙食坊",nil)
        dj_data[""..jsonData.idx] = dj_data[""..jsonData.idx] + 1
        local attrs = {}
        local isall = true
        for i=1,5 do
            attrs[_config.config[i].attrID] = (dj_data[""..i] or 0) * _config.config[i].ratio
            if (dj_data[""..i] or 0) < _config.config[i].max_level then
                isall = false
            end
        end

        local itemobj = linkbodyitem(play,_config.where)
        _apply_xianshifang_abil(play, itemobj, attrs)

        Player.setJsonVarByTable(play, VarCfg["T_仙食坊"], dj_data)
        local data = {}
        data["dj_data"] = dj_data
        sendluamsg(play,100,npcid,1,0,tbl2json(data))
        Player.sendmsgEx(play,  string.format("成功，|【%s】#218|提升到了|【%d级】#218|", _config.config[jsonData.idx].cost[1][1], dj_data[""..jsonData.idx]))
        if isall then
            npc.AllMaxLevel(play)
        end
    elseif p2 == 2 then ---全部使用  多的也收了 （一键使用）
        local equipLevel = Player.getEquipFieldByPos(play, _config.where, 1) or 0
        if equipLevel == 0 then
            Player.sendmsgEx(play,  "请先装备酒葫芦#57")
            return
        end

        local dj_data = Player.getJsonTableByVar(play, VarCfg["T_仙食坊"]) or {}
        local hasTake = false
        local upCount = 0

        for i = 1, 5 do
            local cfg = _config.config[i]
            local curLv = dj_data[""..i] or 0
            local needLv = cfg.max_level - curLv
            local costName = cfg.cost[1][1]
            local costNum = tonumber(cfg.cost[1][2]) or 1
            local itemIdx = getstditeminfo(costName, 0)
            local bagNum = getbagitemcount(play, costName) or 0

            if needLv > 0 then
                local canLv = math.floor(math.min(bagNum, needLv * costNum) / costNum)
                if canLv > 0 then
                    dj_data[""..i] = curLv + canLv
                    upCount = upCount + canLv
                end
            end

            if bagNum > 0 then
                takeitem(play, costName, bagNum)
                hasTake = true
            end
        end

        if not hasTake then
            Player.sendmsgEx(play, "你背包里没有酒水#57")
            return
        end

        local attrs = {}
        local isall = true
        for i=1,5 do
            attrs[_config.config[i].attrID] = (dj_data[""..i] or 0) * _config.config[i].ratio
            if (dj_data[""..i] or 0) < _config.config[i].max_level then
                isall = false
            end
        end

        local itemobj = linkbodyitem(play,_config.where)
        _apply_xianshifang_abil(play, itemobj, attrs)

        Player.setJsonVarByTable(play, VarCfg["T_仙食坊"], dj_data)
        local data = {}
        data["dj_data"] = dj_data
        sendluamsg(play,100,npcid,1,0,tbl2json(data))

        if upCount > 0 then
            Player.sendmsgEx(play, string.format("饮用完成，本次共提升|【%d级】#218|", upCount))
        else
            Player.sendmsgEx(play, "一键饮用，酒水已全部消耗")
        end
    
        if isall then
            npc.AllMaxLevel(play)
        end
    end
end


function npc.AllMaxLevel(play)
    if checktitle(play, _config.title) then
        Player.sendmsgEx(play, "你已拥有#57|【该称号】#218|，无需重复领取#57")
        return
    end
    Player.title_give(play, _config.title)
    Player.sendmsgEx(play, "恭喜你获得称号：|【".._config.title.."】#218|，称号属性永久生效")

end



local function _onTakeOnEx(actor, itemobj, where, itemname, makeid)
    if where == _config.where then
         --仙食坊
        local data = Player.getJsonTableByVar(actor, VarCfg["T_仙食坊"])
        local attrs = {}
        for i=1,5 do
            attrs[teshudata["npc_14"].config[i].attrID] = (data[""..i] or 0) * teshudata["npc_14"].config[i].ratio
        end
        _apply_xianshifang_abil(actor, itemobj, attrs)
    end
end
--穿装备触发
GameEvent.add(EventCfg.onTakeOnEx, _onTakeOnEx, "酒葫芦附加属性")




return npc
