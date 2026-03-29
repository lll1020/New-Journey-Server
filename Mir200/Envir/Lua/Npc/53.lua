npc = {}



local _config = Guard.getConfig("npc_53")

-- 构建指定等级的槽位列表及映射，用于快速校验材料是否合法
local function buildSlotLookup(level)
    local slotList = _config.cost[level]
    if not slotList then
        return
    end
    local lookup = {}
    for idx, name in ipairs(slotList) do
        lookup[name] = idx
    end
    return slotList, lookup
end

-- 根据各槽位投入数量计算权重，返回最终的目标槽位及是否 100%
local function chooseSlot(slotCounts, needItemNum)
    local unique = 0
    local onlySlot
    for slotIndex in pairs(slotCounts) do
        unique = unique + 1
        onlySlot = slotIndex
    end
    if unique == 0 then
        return
    end
    if unique == 1 then
        return onlySlot, true, slotCounts[onlySlot]
    end
    local total = 0
    for _, count in pairs(slotCounts) do
        total = total + count
    end
    if total ~= needItemNum then
        return
    end
    local roll = math.random(total)
    local acc = 0
    for slotIndex, count in pairs(slotCounts) do
        acc = acc + count
        if roll <= acc then
            return slotIndex, false, count
        end
    end
end

-- 获取指定物品堆叠数量（非堆叠返回 1）
local function getStackCount(play, itemObj)
    local count = getiteminfo(play, itemObj, ConstCfg.iteminfo.overlap)
    if not count or count <= 0 then
        count = 1
    end
    return count
end

function npc.main(play,npcid)
    if not Player.ensureThirdContinentPass(play, '请先完成#57|【灾厄入侵】#249|后再使用该功能#57') then
        return
    end
    sendluamsg(play,100,npcid,0,0,"")
end

function npc.link(play,npcid,ew,aid,data)
    if not Player.ensureThirdContinentPass(play, '请先完成#57|【灾厄入侵】#249|后再使用该功能#57') then
        return
    end
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

    if ew == 1 then -- 合成主流程
        local ok, jsondata = pcall(json2tbl, data or "{}")
        if not ok or type(jsondata) ~= "table" then
            Player.sendmsgEx(play,"合成失败：请重新提交数据#57")
            return
        end

        if type(jsondata.itemlist) ~= "table" then
            Player.sendmsgEx(play,"合成失败：无法判断物品#57")
            return
        end

        local totalItems = #jsondata.itemlist
        if totalItems ~= _config.needitemnum then
            Player.sendmsgEx(play,"合成失败：请放入正确物品数量#57")
            return
        end

        local level = tonumber(jsondata.item_level)
        if not level or level < 1 then
            Player.sendmsgEx(play,"合成失败：物品等级无效#57")
            return
        end

        -- 当前等级与下一等级的配置必须存在
        local currentLevelList, slotLookup = buildSlotLookup(level)
        if level >= 3 then
            Player.sendmsgEx(play,"合成失败：已达最高等级#57")
            return
        end
        local nextLevelList = _config.cost[level + 1]
        if not currentLevelList or not slotLookup or not nextLevelList then
            Player.sendmsgEx(play,"合成失败：对应等级配置缺失#57")
            return
        end

        -- 校验每件材料：允许同一件堆叠物品多次选择，但需保证数量足够
        local consumeMap = {}
        local slotCounts = {}
        for _, rawMakeIdx in ipairs(jsondata.itemlist) do
            local makeIdx = tostring(rawMakeIdx)
            local itemObj = getitembymakeindex(play, makeIdx)
            if not itemObj then
                Player.sendmsgEx(play,"合成失败：存在材料已被使用#57")
                return
            end

            local itemName = getiteminfo(play, itemObj, ConstCfg.iteminfo.name)
            local slotIndex = slotLookup[itemName]
            if not slotIndex then
                Player.sendmsgEx(play,"合成失败：存在非当前等级材料#57")
                return
            end

            local info = consumeMap[makeIdx]
            if not info then
                info = {count = 0, total = getStackCount(play, itemObj)}
                consumeMap[makeIdx] = info
            end
            info.count = info.count + 1
            if info.count > info.total then
                Player.sendmsgEx(play,"合成失败：材料数量不足#57")
                return
            end

            slotCounts[slotIndex] = (slotCounts[slotIndex] or 0) + 1
        end

        -- 计算目标槽位：同槽位 10 件必定成功，否则按数量/10 概率
        local chosenSlot, guaranteed, slotWeight = chooseSlot(slotCounts, _config.needitemnum)
        if not chosenSlot then
            Player.sendmsgEx(play,"合成失败：未找到可用槽位#57")
            return
        end

        local rewardName = nextLevelList[chosenSlot]
        if not rewardName then
            Player.sendmsgEx(play,"合成失败：未找到对应上一级#57")
            return
        end

        -- 正式扣除所有材料（堆叠数量一次性扣除）
        for makeIdx, info in pairs(consumeMap) do
            delitembymakeindex(play, makeIdx, info.count)
        end

        giveitem(play, rewardName, 1)

        -- 反馈提示：100% 或显示权重占比（X/10）
        local weightDesc = guaranteed and " (100%)" or string.format(" (%d/%d)", slotWeight or 0, _config.needitemnum)
        Player.sendmsgEx(play, string.format("合成成功，获得：|【%s%s】#249|", rewardName, weightDesc))
        sendluamsg(play,100,npcid,1,0,"")
    end
end

local yz_where = {
    [103] = true,
    [104] = true,
    [105] = true,
    [106] = true,
    [107] = true,
    [108] = true,
    [109] = true,
    [110] = true,
}
local qsx = {5,10,50,100}
function Login_lignshi(actor)
    
    local min_level = 999
    for v,k in pairs(yz_where) do
        local equipLevel = Player.getEquipFieldByPos(actor, v, 1) or 0
        if equipLevel == 0 then
            return
        end
        equipLevel = tonumber(equipLevel)
        if equipLevel < min_level then
            min_level = equipLevel
        end
    end
    if min_level == 0 or min_level == 999 then
        return
    end

    local attrs = {}
    local attrsstr = ""
    for v,k in pairs(constant.pz_qsx) do
        attrs[k] = qsx[min_level] 
    end
    attrsstr = Player.getAttrTableToStr(attrs)
    -- release_print("登录触发神石属性"..attrsstr)
    addattlist(actor, "神石属性", "=", attrsstr, 1)

end
GameEvent.add(EventCfg.onLogin, Login_lignshi, "Login_lignshi")

--------------------穿戴后触发-------------------
function takeonex_lignshi(actor, itemobj, where, itemname, makeid)
    if not yz_where[where] then
        return
    else
        local min_level = 999
        for v,k in pairs(yz_where) do
            local equipLevel = Player.getEquipFieldByPos(actor, v, 1) or 0
            if equipLevel == 0 then
                return
            end
            equipLevel = tonumber(equipLevel)
            if equipLevel < min_level then
                min_level = equipLevel
            end
        end
        if min_level == 0 or min_level == 999 then
            return
        end

        local attrs = {}
        local attrsstr = ""
        for v,k in pairs(constant.pz_qsx) do
            attrs[k] = qsx[min_level] 
        end
        attrsstr = Player.getAttrTableToStr(attrs)
        -- release_print("穿戴触发神石属性"..attrsstr)
        addattlist(actor, "神石属性", "=", attrsstr, 1)
    end
	
end
GameEvent.add(EventCfg.onTakeOnEx, takeonex_lignshi, "takeonex_lignshi")

--------------------脱下后触发-------------------
function takeoffex_lignshi(actor, itemobj, where, itemname, makeid)
    if not yz_where[where] then
        return
    else
        delattlist(actor, "神石属性")
    end
end
GameEvent.add(EventCfg.onTakeOffEx, takeoffex_lignshi, "takeoffex_lignshi")


return npc