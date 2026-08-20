npc = {}

--[[
仙府总览：
1. 所有玩法参数都来自 teshudata["npc_44"]，这里只读取配置并执行逻辑。
2. 玩家个人数据单独存放在 VarCfg.T_XianFuData，避免维护历史全服大表。
3. 当前仅保留新版仙府基础玩法，不再维护旧版排行榜逻辑。
]]

local _config = Guard.getConfig("npc_44")
local PlantCfg = _config.PlantCfg or {}
local StealCfg = _config.StealCfg or {}
local LikeCfg = _config.LikeCfg or {}
local RefineCfg = _config.RefineCfg or {}
local DecorateCfg = _config.DecorateCfg or {}
local DecorateplaceCfg = _config.DecorateplaceCfg or {}
local TitleCfg = _config.TitleCfg or {}
local PetCfg = _config.PetCfg or {}
local ShopCfg = _config.ShopCfg or {}
local DollCfg = _config.DollCfg or {}
local maxShopBuy = _config.shopMaxBuy or 9999
local visitorLimit = _config.visitorLogLimit or 20
local gridSize = _config.gridSize or 9
local DollAttrListName = tostring(DollCfg.attr_list_name or "仙府娃娃属性")
local levelMax = tonumber(_config.level_max or 4) or 4
local growthDailyLimit = tonumber(_config.growth_daily_limit or 300) or 300
local XIANFU_DAN_LOW_EXPIRE = "N$xf_dan_low_expire"
local XIANFU_DAN_MID_EXPIRE = "N$xf_dan_mid_expire"
local XIANFU_DAN_HIGH_EXPIRE = "N$xf_dan_high_expire"

---------------------------------------------------------------------
-- Common: 基础工具
---------------------------------------------------------------------
local Common = {}

function Common.now()
    return os.time()
end

function Common.today(ts)
    return os.date("%Y-%m-%d", ts or Common.now())
end

function Common.ensureDailyCounter(counter, today)
    counter = counter or {}
    if counter.date ~= today then
        counter.date = today
        counter.count = 0
        counter.map = {}
    end
    counter.map = counter.map or {}
    return counter
end

function Common.checkCost(play, cost)
    if not cost or #cost == 0 then
        return true
    end
    local name, num = Player.checkItemNumByTable(play, cost)
    if name then
        return false, name, num
    end
    return true
end

function Common.payCost(play, cost, reason)
    if not cost or #cost == 0 then
        return
    end
    Player.takeItemByTable(play, cost, reason or ",npc_44", nil)
end

-- 仙府等级固定解锁 1/3/6/9 块地，与神石槽位解锁分开维护。
local function getPlotUnlockCount(level)
    return gridSize
end

local function getLevelCfg(level)
    return (_config.level_cfg or {})[tonumber(level or 1) or 1] or {}
end

local function getGrowthRule(key)
    return (_config.growth_rules or {})[tostring(key or "")] or {}
end

local buildPlantReward

local function buildDecoPlaceIndex(cfg)
    local idx = {}
    for place, info in pairs(cfg or {}) do
        for _, id in ipairs(info.list or {}) do
            idx[tostring(id)] = place
            if type(id) == "number" then
                idx[id] = place
            end
        end
    end
    return idx
end

local DecoPlaceIndex = buildDecoPlaceIndex(DecorateplaceCfg)

local function calcDecorationXiangHua(equipped)
    local sum = 0
    for _, decoId in pairs(equipped or {}) do
        local entry = DecorateCfg[decoId] or DecorateCfg[tonumber(decoId)] or DecorateCfg[tostring(decoId)]
        if entry and entry.xiangHua then
            sum = sum + (entry.xiangHua or 0)
        end
    end

    return sum
end

local HerbAliasByName = {}
for key, cfg in pairs(PlantCfg) do
    if type(cfg) == "table" and cfg.name then
        HerbAliasByName[cfg.name] = key
    end
end

local function herbNameBySeed(seedId)
    local cfg = PlantCfg[seedId]
    return (cfg and cfg.name) or seedId
end

local function syncHerbAlias(record, herbName)
    if record.herbs[herbName] then
        return record.herbs[herbName]
    end
    local alias = HerbAliasByName[herbName]
    if alias and record.herbs[alias] then
        record.herbs[herbName] = record.herbs[alias]
        record.herbs[alias] = nil
        return record.herbs[herbName]
    end
    return 0
end

local function ensureHerbCount(record, herbName)
    record.herbs[herbName] = record.herbs[herbName] or 0
    return record.herbs[herbName]
end

local function ensureGrowth(record, now)
    local today = Common.today(now)
    record.growth = record.growth or {total = 0, daily_total = {date = today, count = 0}, daily = {}}
    record.growth.total = tonumber(record.growth.total or 0) or 0
    record.growth.daily_total = Common.ensureDailyCounter(record.growth.daily_total, today)
    record.growth.daily = record.growth.daily or {}
    return record.growth
end

local function ensureLevelStats(record)
    record.level_stats = record.level_stats or {
        harvest_low = 0,
        refine_low = 0,
        refine_mid = 0,
        refine_high = 0,
    }
    for key, _ in pairs(record.level_stats) do
        record.level_stats[key] = tonumber(record.level_stats[key] or 0) or 0
    end
    return record.level_stats
end

local function isDanActive(play, expireVar)
    if play == nil or play == 0 then
        return false, 0
    end
    local expireAt = tonumber(getplaydef(play, expireVar) or 0) or 0
    return expireAt > Common.now(), expireAt
end

local function applyGrowth(record, key, times, now)
    times = tonumber(times or 1) or 1
    if times <= 0 then
        return 0
    end
    local rule = getGrowthRule(key)
    local value = tonumber(rule.value or 0) or 0
    local dailyLimit = tonumber(rule.daily_limit or 0) or 0
    if value <= 0 or dailyLimit <= 0 then
        return 0
    end
    local growth = ensureGrowth(record, now)
    local today = Common.today(now)
    growth.daily[key] = Common.ensureDailyCounter(growth.daily[key], today)
    local totalCounter = Common.ensureDailyCounter(growth.daily_total, today)
    local added = 0
    for _ = 1, times do
        local curDailyValue = tonumber(growth.daily[key].count or 0) or 0
        local curTotalValue = tonumber(totalCounter.count or 0) or 0
        if curDailyValue + value > dailyLimit then
            break
        end
        if curTotalValue + value > growthDailyLimit then
            break
        end
        growth.daily[key].count = curDailyValue + value
        totalCounter.count = curTotalValue + value
        growth.total = (tonumber(growth.total or 0) or 0) + value
        added = added + value
    end
    return added
end

local PLAYER_DATA_VAR = VarCfg.T_XianFuData or "T47"

local function hasHerbCost(record, herbCost)
    for _, item in ipairs(herbCost or {}) do
        local name, need = item[1], item[2] or 0
        if (syncHerbAlias(record, name) or 0) < need then
            return false, name
        end
    end
    return true
end

local function consumeHerbCost(record, herbCost)
    for _, item in ipairs(herbCost or {}) do
        local name, need = item[1], item[2] or 0
        syncHerbAlias(record, name)
        record.herbs[name] = math.max(0, (record.herbs[name] or 0) - need)
    end
end

function Common.appendBounded(list, entry, limit)
    list = list or {}
    table.insert(list, 1, entry)
    local cap = limit or 20
    while #list > cap do
        table.remove(list)
    end
    return list
end

local function cloneRewardList(list)
    local result = {}
    for _, info in ipairs(list or {}) do
        result[#result + 1] = {info[1], info[2]}
    end
    return result
end

local function addProductStat(record, reward)
    for _, info in ipairs(reward or {}) do
        local name, amount = info[1], info[2] or 0
        record.herbs[name] = (record.herbs[name] or 0) + amount
    end
end

local function summarizeReward(reward)
    local parts = {}
    for _, info in ipairs(reward or {}) do
        table.insert(parts, string.format("%s*%d", info[1], info[2] or 0))
    end
    return table.concat(parts, "/")
end

local function cloneSimpleTable(src)
    local result = {}
    for key, value in pairs(src or {}) do
        result[key] = value
    end
    return result
end

---------------------------------------------------------------------
-- Storage: 玩家数据读写
---------------------------------------------------------------------
local Storage = {}

local function normalizeInventory(container)
    container = container or {}
    for key, value in pairs(container) do
        if type(value) ~= "number" then
            container[key] = tonumber(value) or value
        end
    end
    container.Low = tonumber(container.Low) or container.Low or 0
    container.Mid = tonumber(container.Mid) or container.Mid or 0
    container.High = tonumber(container.High) or container.High or 0
    return container
end

local function normalizeDecoration(decoration)
    decoration = decoration or {}
    local owned = {}
    for key, value in pairs(decoration.owned or {}) do
        owned[tostring(key)] = value and true or false
    end
    decoration.owned = owned

    local equipped = {}
    if type(decoration.equipped) == "table" then
        for place, id in pairs(decoration.equipped) do
            if id then
                local key = tostring(id)
                local pos = DecoPlaceIndex[key] or DecoPlaceIndex[tonumber(key)] or tostring(place)
                equipped[pos] = key
            end
        end
    elseif decoration.equipped then
        local key = tostring(decoration.equipped)
        local pos = DecoPlaceIndex[key] or DecoPlaceIndex[tonumber(key)] or "default"
        equipped[pos] = key
    end
    decoration.equipped = equipped
    decoration.xiangHua = calcDecorationXiangHua(decoration.equipped)
    return decoration
end

local function resetPlot(plot, id)
    plot.seedId = nil
    plot.state = "empty"
    plot.gridId = id
    plot.plantedAt = nil
    plot.finishAt = nil
    plot.canSteal = false
    plot.product = nil
end

function Storage.loadPlayer(play)
    return Player.getJsonTableByVar(play, PLAYER_DATA_VAR) or {}
end

function Storage.savePlayer(play, data)
    Player.setJsonVarByTable(play, PLAYER_DATA_VAR, data)
end

function Storage.ensureRecord(play, opts)
    local record = Storage.loadPlayer(play)
    if type(record) ~= "table" then
        record = {}
    end
    record.meta = record.meta or {}
    local playerName = (opts and opts.name) or Player.GetName(play) or record.meta.name or "unknown"
    record.meta.key = playerName
    record.meta.name = playerName
    record.meta.lastActive = opts and opts.now or Common.now()
    record.meta.play = nil
    record.opened = tonumber(record.opened or 0) or 0
    record.level = tonumber(record.level or 1) or 1
    if record.level < 1 then
        record.level = 1
    elseif record.level > levelMax then
        record.level = levelMax
    end
    record.plot_unlock = tonumber(record.plot_unlock or getPlotUnlockCount(record.level)) or getPlotUnlockCount(record.level)
    record.herbs = normalizeInventory(record.herbs)
    record.seeds = {}
    record.fields = record.fields or {}
    record.steal = record.steal or {}
    record.guard = record.guard or {}
    record.likes = record.likes or {received = {total = 0}, given = {}}
    record.likes.received = record.likes.received or {total = 0}
    record.likes.given = record.likes.given or {}
    record.decoration = normalizeDecoration(record.decoration)
    record.refine = record.refine or {lastTime = 0, collection = {}}
    record.pet = record.pet or {eggs = {}, beasts = {}, bestiary = {}, materials = {essence = 0}}
    record.pet.eggs = record.pet.eggs or {}
    record.pet.beasts = record.pet.beasts or {}
    record.pet.bestiary = record.pet.bestiary or {}
    record.pet.materials = record.pet.materials or {essence = 0}
    record.doll = record.doll or {
        draw_total = 0,
        pity_progress = 0,
        hidden_count = 0,
        owned = {},
        quality_count = {normal = 0, red = 0, hidden = 0},
        last_result = "",
        last_draw_time = 0,
    }
    record.doll.owned = record.doll.owned or {}
    record.doll.quality_count = record.doll.quality_count or {normal = 0, red = 0, hidden = 0}
    record.visitor = record.visitor or {log = {}}
    record.visitor.log = record.visitor.log or {}
    record.stats = record.stats or {xiangHua = 0}
    record.stats.likenum = tonumber(record.stats.likenum or 0) or 0
    ensureGrowth(record, opts and opts.now)
    ensureLevelStats(record)
    Storage.ensurePlots(record)
    return record
end

function Storage.ensurePlots(record)
    record.plot_unlock = getPlotUnlockCount(record.level)
    for i = 1, gridSize do
        local plot = record.fields[i]
        local oldState = type(plot) == "table" and plot.state or nil
        if type(plot) ~= "table" then
            plot = {gridId = i}
            record.fields[i] = plot
        end
        plot.gridId = i
        if oldState == "growing" or oldState == "mature" then
            plot.state = oldState
        else
            plot.state = "empty"
        end
        if plot.state == "empty" then
            resetPlot(plot, i)
        end
    end
end

function Storage.syncGrowth(record, now)
    now = now or Common.now()
    ensureGrowth(record, now)
    for _, plot in pairs(record.fields) do
        if plot.state == "growing" and plot.finishAt and now >= plot.finishAt then
            plot.state = "mature"
        end
        if plot.state ~= "empty" and plot.state ~= "locked" and plot.seedId and not PlantCfg[plot.seedId] then
            resetPlot(plot, plot.gridId)
        end
    end
end

function Storage.buildPublicSnapshot(record)
    return {
        key = record.meta.key,
        name = record.meta.name,
        xiangHua = record.stats.xiangHua or 0,
        likenum = record.stats.likenum or 0,
        herbs = record.herbs,
        fields = record.fields,
        level = record.level or 1,
        plot_unlock = record.plot_unlock or getPlotUnlockCount(record.level or 1),
        decoration = record.decoration,
        pet = {
            beasts = record.pet.beasts,
            bestiary = record.pet.bestiary,
        },
    }
end

---------------------------------------------------------------------
-- Planting
---------------------------------------------------------------------
local Planting = {}

buildPlantReward = function(play, plantCfg)
    local reward = {}
    -- 稳固丹生效时，种植产出的仙府币/神石碎片额外增加 20%。
    local lowDanActive = isDanActive(play, XIANFU_DAN_LOW_EXPIRE)
    for _, entry in ipairs(plantCfg.product or {}) do
        local rate = tonumber(entry.rate or 0) or 0
        if rate >= 100 or (rate > 0 and math.random(100) <= rate) then
            for _, info in ipairs(entry.give or {}) do
                local itemName = tostring(info[1] or "")
                local itemNum = tonumber(info[2] or 0) or 0
                if lowDanActive and (itemName == "仙府币" or itemName == "神石碎片") and itemNum > 0 then
                    itemNum = math.max(itemNum + math.floor(itemNum * 0.2), itemNum + 1)
                end
                if itemName ~= "" and itemNum > 0 then
                    reward[#reward + 1] = {itemName, itemNum}
                end
            end
        end
    end
    return reward
end

-- 播种共用逻辑：单块播种与一键种植都复用这里，确保成熟时间与可偷状态一致。
local function applyPlantToPlot(play, record, plot, seedId, now)
    local cfg = PlantCfg[seedId]
    if not cfg then
        return false, "灵草配置不存在"
    end
    if not plot then
        return false, "地块不存在"
    end
    if plot.state == "locked" then
        return false, "该地块尚未解锁"
    end
    if plot.state ~= "empty" then
        return false, "当前地块已占用"
    end
    local needLevel = tonumber(cfg.need_level or 1) or 1
    if (tonumber(record.level or 1) or 1) < needLevel then
        return false, string.format("仙府等级达到#57|【%d级】#218|后解锁该灵草", needLevel)
    end
    local startAt = now or Common.now()
    plot.seedId = seedId
    plot.state = "growing"
    plot.plantedAt = startAt
    local mature = tonumber(cfg.matureTime or 0) or 0
    if mature > 0 and getplaydef(play,"N$buff306") == 1 then
        -- 黑化肥会挥发：仙草成熟时间加快 30%。
        mature = math.ceil(mature * 0.7)
        if mature < 1 then
            mature = 1
        end
    end
    plot.finishAt = startAt + mature
    plot.canSteal = cfg.canSteal and true or false
    plot.product = nil
    return true, {plot = plot}
end

function Planting.plant(play, record, params, now)
    local gridId = tonumber(params.gridId)
    if not gridId or gridId < 1 or gridId > gridSize then
        return false, "参数错误"
    end
    local plot = record.fields[gridId]
    if not plot then
        return false, "地块不存在"
    end
    Storage.syncGrowth(record, now)
    return applyPlantToPlot(play, record, plot, params.seedId, now)
end

-- 一键种植：玩家选定灵草后，将当前所有已解锁空地一次性播满。
function Planting.plantAll(play, record, params, now)
    local seedId = tostring(params.seedId or "")
    local cfg = PlantCfg[seedId]
    if not cfg then
        return false, "灵草配置不存在"
    end
    local needLevel = tonumber(cfg.need_level or 1) or 1
    if (tonumber(record.level or 1) or 1) < needLevel then
        return false, string.format("仙府等级达到#57|【%d级】#218|后解锁该灵草", needLevel)
    end
    Storage.syncGrowth(record, now)
    local count = 0
    local plantedGridIds = {}
    for gridId = 1, gridSize do
        local plot = record.fields[gridId]
        if plot and plot.state == "empty" then
            local ok = applyPlantToPlot(play, record, plot, seedId, now)
            if ok then
                count = count + 1
                plantedGridIds[#plantedGridIds + 1] = gridId
            end
        end
    end
    if count <= 0 then
        return false, "当前没有可种植空地"
    end
    return true, {
        count = count,
        seedId = seedId,
        plantedGridIds = plantedGridIds,
    }
end

function Planting.harvest(play, record, params, now)
    local gridId = tonumber(params.gridId)
    local plot = record.fields[gridId]
    if not plot then
        return false, "地块不存在"
    end
    Storage.syncGrowth(record, now)
    if plot.state ~= "mature" then
        return false, "尚未成熟"
    end
    local plantCfg = PlantCfg[plot.seedId]
    if not plantCfg then
        resetPlot(plot, gridId)
        return false, "灵草配置不存在"
    end
    local reward = cloneRewardList(plot.product or {})
    if #reward <= 0 then
        reward = buildPlantReward(play, plantCfg)
        plot.product = cloneRewardList(reward)
    end
    if #reward <= 0 then
        resetPlot(plot, gridId)
        return false, "本次未收获到物品"
    end
    Player.rwjl(play, reward, "仙府收获", 1, 0)
    addProductStat(record, reward)
    local stats = ensureLevelStats(record)
    if plot.seedId == "Low" then
        stats.harvest_low = (tonumber(stats.harvest_low or 0) or 0) + 1
    end
    applyGrowth(record, "harvest", 1, now)
    resetPlot(plot, gridId)
    return true, {herbs = record.herbs, plot = plot, reward = reward, growth = record.growth, level_stats = record.level_stats}
end

---------------------------------------------------------------------
-- Shop
---------------------------------------------------------------------
local Shop = {}

local function indexShop(list)
    local dict = {}
    for _, item in ipairs(list or {}) do
        dict[item.id] = item
    end
    return dict
end

local ShopIndex = {
    seeds = indexShop(ShopCfg.seeds),
    eggs = indexShop(ShopCfg.eggs),
    materials = indexShop(ShopCfg.materials),
}

local function multiplyCost(cost, amount)
    local result = {}
    for _, info in ipairs(cost or {}) do
        result[#result + 1] = {info[1], (info[2] or 0) * amount}
    end
    return result
end

local function purchase(play, entry, amount, reason)
    if not entry then
        return false, "商品不存在"
    end
    amount = math.max(1, tonumber(amount) or 1)
    local cost = multiplyCost(entry.cost, amount)
    local ok, lack = Common.checkCost(play, cost)
    if not ok then
        return false, string.format("%s不足", lack or "cost")
    end
    Common.payCost(play, cost, reason or "xianfu_shop")
    return true, amount
end

function Shop.buySeed(play, record, params)
    -- 新版仙府已取消种子购买，空地可直接播种对应等级灵草。
    return false, "仙草种子功能已停用"
end

function Shop.buyEgg(play, record, params)
    local entry = ShopIndex.eggs[params.id]
    local ok, amountOrErr = purchase(play, entry, params.amount, "xianfu_egg_shop")
    if not ok then
        return false, amountOrErr
    end
    record.pet.eggs[entry.id] = (record.pet.eggs[entry.id] or 0) + amountOrErr
    return true, {eggs = record.pet.eggs}
end

function Shop.buyMaterial(play, record, params)
    local entry = ShopIndex.materials[params.id]
    local ok, amountOrErr = purchase(play, entry, params.amount, "xianfu_material")
    if not ok then
        return false, amountOrErr
    end
    record.pet.materials[entry.id] = (record.pet.materials[entry.id] or 0) + amountOrErr
    return true, {materials = record.pet.materials}
end

---------------------------------------------------------------------
-- Steal / Visitor / Like / Decoration / Refine / Pet 
---------------------------------------------------------------------
local Steal = {}

local function pickStealPlot(record, gridId)
    local function resolvePlot(id)
        id = tonumber(id)
        if not id then
            return nil, nil
        end
        local plot = record.fields[id]
        if type(plot) ~= "table" then
            return nil, nil
        end
        if plot.state ~= "mature" then
            return nil, nil
        end
        local cfg = PlantCfg[plot.seedId]
        if not (cfg and cfg.canSteal) then
            return nil, nil
        end
        return plot, cfg
    end

    local plot, cfg = resolvePlot(gridId)
    if plot then
        return plot, cfg
    end

    for candidateIndex, candidate in ipairs(record.fields or {}) do
        local candidatePlot, candidateCfg = resolvePlot(candidate and (candidate.gridId or candidateIndex))
        if candidatePlot then
            return candidatePlot, candidateCfg
        end
    end

    return nil, nil, "当前没有可偷取的成熟灵草"
end

local function ensureStealCooldown(stat)
    stat.cooldown = stat.cooldown or {}
    return stat.cooldown
end
local function splitStealReward(plot)
    local need = math.max(1, tonumber(StealCfg.stealAmount) or 1)
    local reward = {}
    local remain = need
    local left = {}
    for _, info in ipairs(plot.product or {}) do
        local name = info[1]
        local amount = math.max(0, tonumber(info[2]) or 0)
        if remain > 0 and amount > 0 then
            local take = math.min(amount, remain)
            if take > 0 then
                reward[#reward + 1] = {name, take}
                amount = amount - take
                remain = remain - take
            end
        end
        if amount > 0 then
            left[#left + 1] = {name, amount}
        end
    end
    if #reward == 0 then
        return nil, nil
    end
    return reward, left
end

function Steal.try(play, thiefRecord, targetRecord, now, gridId, targetActor)
    if thiefRecord.meta.key == targetRecord.meta.key then
        return false, "不能偷取自己"
    end
    Storage.syncGrowth(targetRecord, now)
    local plot, cfg, err = pickStealPlot(targetRecord, gridId)
    if not plot then
        return false, err or "没有可偷的灵草"
    end
    local today = Common.today(now)
    thiefRecord.steal.daily = Common.ensureDailyCounter(thiefRecord.steal.daily, today)
    if thiefRecord.steal.daily.count >= (StealCfg.dailyStealLimit or 0) then
        return false, "今日偷菜次数已满"
    end
    targetRecord.guard.daily = Common.ensureDailyCounter(targetRecord.guard.daily, today)
    if targetRecord.guard.daily.count >= (StealCfg.perTargetDailyLimit or 0) then
        return false, "对方今日被偷次数已满"
    end
    if not plot.product or #plot.product == 0 then
        local generated = buildPlantReward(targetActor or play, cfg)
        plot.product = cloneRewardList(generated)
    end
    local reward, left = splitStealReward(plot)
    if not reward then
        return false, "没有剩余灵草"
    end
    Player.rwjl(play, reward, "仙府偷菜", 1, 0)
    addProductStat(thiefRecord, reward)
    thiefRecord.steal.daily.count = thiefRecord.steal.daily.count + 1
    targetRecord.guard.daily.count = targetRecord.guard.daily.count + 1
    applyGrowth(thiefRecord, "steal", 1, now)
    if left and #left > 0 then
        plot.product = left
        plot.state = "mature"
        plot.canSteal = cfg and cfg.canSteal and true or false
    else
        resetPlot(plot, plot.gridId)
    end
    return true, {product = reward, plot = plot}
end

local Visitor = {}

function Visitor.push(record, fromName, action, detail, now)
    record.visitor.log = Common.appendBounded(record.visitor.log, {
        from = fromName,
        action = action,
        detail = detail,
        time = now or Common.now(),
    }, visitorLimit)
    return record.visitor.log
end

local Like = {}

function Like.perform(play, actorRecord, targetRecord, now)
    if actorRecord.meta.key == targetRecord.meta.key then
        return false, "不能给自己点赞"
    end
    local today = Common.today(now)
    actorRecord.likes.given[targetRecord.meta.key] = actorRecord.likes.given[targetRecord.meta.key] or {date = "", count = 0}
    local node = actorRecord.likes.given[targetRecord.meta.key]
    if node.date ~= today then
        node.date = today
        node.count = 0
    end
    if node.count >= (LikeCfg.dailyLikePerTarget or 0) then
        return false, "今日已点赞过TA"
    end
    node.count = node.count + 1
    targetRecord.likes.received.total = (targetRecord.likes.received.total or 0) + 1
    targetRecord.stats.xiangHua = (targetRecord.stats.xiangHua or 0) + (LikeCfg.likeValue or 0)
    targetRecord.stats.likenum = (targetRecord.stats.likenum or 0) + 1
    applyGrowth(actorRecord, "like", 1, now)
    return true, {xiangHua = targetRecord.stats.xiangHua, likenum = targetRecord.stats.likenum}
end

local Decoration = {}

local function decoKey(id)
    return id and tostring(id) or nil
end

local function decoEntry(decoId)
    local idNum = tonumber(decoId)
    return DecorateCfg[decoId] or (idNum and DecorateCfg[idNum]) or DecorateCfg[tostring(decoId)]
end

function Decoration.buy(play, record, decoId)
    local key = decoKey(decoId)
    local entry = decoEntry(key)
    if not entry then
        return false, "装扮不存在"
    end
    if record.decoration.owned[key] then
        return false, "已拥有该装扮"
    end
    local ok, lack = Common.checkCost(play, entry.cost)
    if not ok then
        return false, string.format("%s不足", lack or "cost")
    end
    Common.payCost(play, entry.cost, "xianfu_deco")
    record.decoration.owned[key] = true
    return true, {owned = record.decoration.owned}
end

function Decoration.equip(record, decoId)
    local key = decoKey(decoId)
    local entry = decoEntry(key)
    if not entry then
        return false, "装扮不存在"
    end
    if not record.decoration.owned[key] then
        return false, "请先购买"
    end
    local place = DecoPlaceIndex[key] or DecoPlaceIndex[tonumber(key)]
    if not place then
        return false, "装扮位置未配置"
    end
    local prev = record.decoration.xiangHua or 0
    record.decoration.equipped[place] = key
    local total = calcDecorationXiangHua(record.decoration.equipped)
    record.decoration.xiangHua = total
    record.stats.xiangHua = (record.stats.xiangHua or 0) - prev + total
    return true, {equipped = record.decoration.equipped, xiangHua = record.stats.xiangHua}
end

local Refine = {}

local function refineCostWithBuff(play, cost)
    if getplaydef(play,"N$buff306") ~= 1 then
        return cost
    end
    -- 黑化肥会挥发：炼丹消耗减少 50%。
    local out = {}
    for _, info in ipairs(cost or {}) do
        local name, num = info[1], info[2] or 0
        local n = math.ceil(num * 0.5)
        if num > 0 and n < 1 then
            n = 1
        end
        out[#out + 1] = {name, n}
    end
    return out
end

local function hasRefinePermit(play)
    local needEquip = RefineCfg.needEquip
    if not needEquip or needEquip == "" then
        return true
    end
    if Player.hasEquipInArtifactSlot(play, needEquip) then
        return true
    end
    for pos = 0, 20 do
        if Player.getEquipNameByPos(play, pos) == needEquip then
            return true
        end
    end
    return false
end

local function hasAllRecipes(record)
    for name in pairs(RefineCfg.recipes or {}) do
        if not record.refine.collection[name] then
            return false
        end
    end
    return true
end

function Refine.start(play, record, params, now)
    local recipe = RefineCfg.recipes and RefineCfg.recipes[params.recipeId]
    if not recipe then
        return false, "丹方不存在"
    end
    if not hasRefinePermit(play) then
        return false, string.format("请先装备#218|%s#255|后再炼丹", RefineCfg.needEquip or "炼丹许可证")
    end
    local cd = RefineCfg.furnaceCd or 0
    if (record.refine.lastTime or 0) + cd > now then
        return false, "炼丹炉冷却中"
    end
    local cost = refineCostWithBuff(play, recipe.cost or recipe.costCurrency)
    local ok, lack = Common.checkCost(play, cost)
    if not ok then
        return false, string.format("%s不足", lack or "cost")
    end
    Common.payCost(play, cost, "xianfu_refine")
    record.refine.lastTime = now
    record.refine.collection[params.recipeId] = true
    local reward = cloneRewardList(recipe.product or {{params.recipeId, 1}})
    Player.rwjl(play, reward, "仙府炼丹", 1, 0)
    local stats = ensureLevelStats(record)
    local statKey = tostring(recipe.stat_key or "")
    if statKey == "refine_low" then
        stats.refine_low = (tonumber(stats.refine_low or 0) or 0) + 1
    elseif statKey == "refine_mid" then
        stats.refine_mid = (tonumber(stats.refine_mid or 0) or 0) + 1
    elseif statKey == "refine_high" then
        stats.refine_high = (tonumber(stats.refine_high or 0) or 0) + 1
    end
    applyGrowth(record, "refine", 1, now)
    --暂时不用称号
    -- if hasAllRecipes(record) and TitleCfg.DanMaster then
    --     Player.title_give(play, TitleCfg.DanMaster.name)
    -- end
    return true, {reward = reward, collection = record.refine.collection, lastTime = record.refine.lastTime, growth = record.growth, level_stats = record.level_stats}
end

local function getOpenSlotCount(record)
    local cfg = getLevelCfg(record.level)
    return tonumber(cfg.open_slots or 0) or 0
end

local function checkLevelUp(play, record)
    local currentLevel = tonumber(record.level or 1) or 1
    if currentLevel >= levelMax then
        return false, "已达最高等级"
    end
    local nextCfg = getLevelCfg(currentLevel + 1)
    local growth = ensureGrowth(record)
    local stats = ensureLevelStats(record)
    if (tonumber(growth.total or 0) or 0) < (tonumber(nextCfg.need_growth or 0) or 0) then
        return false, "成长值不足"
    end
    if (tonumber(stats.harvest_low or 0) or 0) < (tonumber(nextCfg.need_harvest or 0) or 0) then
        return false, "低阶仙草收获次数不足"
    end
    local needRefineLow = tonumber(nextCfg.need_refine_low or 0) or 0
    local needRefineMid = tonumber(nextCfg.need_refine_mid or 0) or 0
    if (tonumber(stats.refine_low or 0) or 0) < needRefineLow then
        return false, "下品丹药炼制次数不足"
    end
    if (tonumber(stats.refine_mid or 0) or 0) < needRefineMid then
        return false, "中品丹药炼制次数不足"
    end
    local needCost = nextCfg.cost or {}
    if #needCost > 0 then
        local name, _ = Player.checkItemNumByTable(play, needCost)
        if name then
            return false, tostring(name) .. "不足"
        end
    end
    return true
end

local function levelUp(play, record)
    local ok, err = checkLevelUp(play, record)
    if not ok then
        return false, err
    end
    local nextLevel = (tonumber(record.level or 1) or 1) + 1
    local nextCfg = getLevelCfg(nextLevel)
    local needCost = nextCfg.cost or {}
    if #needCost > 0 then
        Player.takeItemByTable(play, needCost, ",仙府升级", nil)
    end
    record.level = nextLevel
    record.plot_unlock = getPlotUnlockCount(record.level)
    Storage.ensurePlots(record)


    return true, {
        level = record.level,
        plot_unlock = record.plot_unlock,
        open_slots = getOpenSlotCount(record),
        growth = record.growth,
        level_stats = record.level_stats,
    }
end

local function tryAutoLevelUp(play, record)
    return false
end

local Pet = {}

local function newPetId(eggId, now)
    return string.format("%s_%d", eggId or "pet", now)
end

local function getEggCfg(eggId)
    return PetCfg.eggs and PetCfg.eggs[eggId]
end

-- function Pet.hatch(play, record, params, now)
--     local cfg = getEggCfg(params.eggId)
--     if not cfg then
--         return false, "灵蛋不存??
--     end
--     record.pet.eggs[params.eggId] = record.pet.eggs[params.eggId] or 0
--     if record.pet.eggs[params.eggId] <= 0 then
--         return false, "灵蛋数量不足"
--     end
--     record.pet.eggs[params.eggId] = record.pet.eggs[params.eggId] - 1
--     local petId = newPetId(params.eggId, now)
--     record.pet.beasts[petId] = {
--         id = petId,
--         type = cfg.beast.type,
--         level = 1,
--         exp = 0,
--         maxLevel = cfg.beast.maxLevel,
--     }
--     record.pet.bestiary[cfg.beast.type] = true
--     if TitleCfg.BeastMaster then
--         local total, owned = 0, 0
--         for _ in pairs(PetCfg.eggs or {}) do total = total + 1 end
--         for _ in pairs(record.pet.bestiary) do owned = owned + 1 end
--         -- if total > 0 and owned >= total then
--         --     Player.title_give(play, TitleCfg.BeastMaster.name)
--         -- end
--     end
--     return true, {petId = petId, pets = record.pet.beasts}
-- end

-- function Pet.feed(play, record, params)
--     local pet = record.pet.beasts[params.petId]
--     if not pet then
--         return false, "灵兽不存??
--     end
--     local feedCfg = PetCfg.feed or {}
--     local need = (params.amount or 1) * (feedCfg.perFeed or 1)
--     record.pet.materials[feedCfg.resource or "essence"] = record.pet.materials[feedCfg.resource or "essence"] or 0
--     if record.pet.materials[feedCfg.resource or "essence"] < need then
--         return false, "材料不足"
--     end
--     record.pet.materials[feedCfg.resource or "essence"] = record.pet.materials[feedCfg.resource or "essence"] - need
--     pet.exp = pet.exp + (params.amount or 1) * (feedCfg.exp or 0)
--     local needExp = pet.level * 10
--     while pet.exp >= needExp and pet.level < (pet.maxLevel or 1) do
--         pet.exp = pet.exp - needExp
--         pet.level = pet.level + 1
--         needExp = pet.level * 10
--     end
--     return true, {pet = pet, materials = record.pet.materials}
-- end

-- function Pet.identify(play, record, params)
--     local pet = record.pet.beasts[params.petId]
--     if not pet then
--         return false, "灵兽不存??
--     end
--     local cost = PetCfg.identify and PetCfg.identify.cost
--     local ok, lack = Common.checkCost(play, cost)
--     if not ok then
--         return false, string.format("%s不足", lack or "cost")
--     end
--     Common.payCost(play, cost, "xianfu_pet_identify")
--     local pool = PetCfg.identify and PetCfg.identify.bloodlinePool or {"灵动"}
--     local affix = pool[math.random(1, #pool)]
--     pet.bloodline = {name = affix, rollAt = Common.now()}
--     if TitleCfg.BeastMaster and pet.bloodline and pet.bloodline.name then
--         record.pet.bestiary[pet.bloodline.name] = true
--     end
--     return true, {pet = pet}
-- end

---------------------------------------------------------------------
-- 状态加??/ 持久??
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Doll: 仙府娃娃??/ 收藏??
---------------------------------------------------------------------
local Doll = {}

local function dollResultCfg(resultId)
    return (DollCfg.results or {})[resultId]
end

local function dollPercentAttrMap()
    return DollCfg.percent_attrs or {}
end

local function dollSummaryLabel(attrId)
    return (DollCfg.summary_labels or {})[tonumber(attrId)]
end

local function dollRoll(base)
    base = tonumber(base) or 10000
    return math.random(1, base)
end

local function dollCopyOwned(owned)
    local result = {}
    for _, resultId in ipairs(DollCfg.cabinet_order or {}) do
        local count = tonumber((owned or {})[resultId]) or 0
        if count > 0 then
            result[resultId] = count
        end
    end
    return result
end

local function dollBuildSummary(record)
    local attrs = {}
    local owned = ((record or {}).doll or {}).owned or {}
    for resultId, count in pairs(owned) do
        count = tonumber(count) or 0
        local cfg = dollResultCfg(resultId)
        if cfg and count > 0 then
            for _, attr in ipairs(cfg.attr or {}) do
                local attrId = tonumber(attr[1])
                local attrValue = tonumber(attr[2]) or 0
                if attrId and attrValue ~= 0 then
                    attrs[attrId] = (attrs[attrId] or 0) + attrValue * count
                end
            end
        end
    end
    return attrs
end

local function dollCountOwnedByPool(record, pool)
    local total = 0
    local owned = ((record or {}).doll or {}).owned or {}
    for _, resultId in ipairs(pool or {}) do
        if (tonumber(owned[resultId]) or 0) > 0 then
            total = total + 1
        end
    end
    return total
end

local function dollRefreshAttr(play, record)
    Player.del_attlist(play, DollAttrListName)
    local attrs = dollBuildSummary(record)
    if next(attrs) then
        Player.add_attlist(play, DollAttrListName, "=", Player.getAttrTableToStr(attrs), 1)
    end
end

local function dollBuildSummaryList(record)
    local attrs = dollBuildSummary(record)
    local result = {}
    for attrId, value in pairs(attrs) do
        local label = dollSummaryLabel(attrId)
        if label then
            result[#result + 1] = {
                attr = tonumber(attrId),
                name = label,
                value = tonumber(value) or 0,
                percent = dollPercentAttrMap()[tonumber(attrId)] and true or false,
            }
        end
    end
    table.sort(result, function(a, b)
        return (a.attr or 0) < (b.attr or 0)
    end)
    return result
end

local function dollPickFromPool(pool)
    if type(pool) ~= "table" or #pool <= 0 then
        return nil
    end
    return pool[math.random(1, #pool)]
end

local function dollHiddenPool()
    return (DollCfg.hidden and DollCfg.hidden.pool) or {}
end

local function dollCanRollHidden(record)
    local hiddenCfg = DollCfg.hidden or {}
    local maxCount = tonumber(hiddenCfg.max_count) or 0
    if maxCount <= 0 then
        return false
    end
    return dollCountOwnedByPool(record, dollHiddenPool()) < maxCount
end

local function dollResolveCost(record)
    return cloneRewardList(DollCfg.normal_draw_cost or {})
end

local function dollPickHidden(record)
    local pool = dollHiddenPool()
    local unowned = {}
    local owned = ((record or {}).doll or {}).owned or {}
    for _, resultId in ipairs(pool) do
        if (tonumber(owned[resultId]) or 0) <= 0 then
            unowned[#unowned + 1] = resultId
        end
    end
    if #unowned > 0 then
        return dollPickFromPool(unowned)
    end
    return dollPickFromPool(pool)
end

local function dollRollResult(record)
    local hiddenCfg = DollCfg.hidden or {}
    if dollCanRollHidden(record) then
        local hiddenBase = tonumber(hiddenCfg.rate_base) or 10000
        local hiddenRate = tonumber(hiddenCfg.rate) or 0
        if hiddenRate > 0 and dollRoll(hiddenBase) <= hiddenRate then
            return dollPickHidden(record), "hidden"
        end
    end
    local pityNeed = tonumber(DollCfg.pity_need) or 0
    local pityProgress = tonumber((((record or {}).doll or {}).pity_progress) or 0) or 0
    if pityNeed > 0 and pityProgress + 1 >= pityNeed then
        return dollPickFromPool(DollCfg.red_pool or {}), "pity"
    end
    local redBase = tonumber(DollCfg.red_rate_base) or 10000
    local redRate = tonumber(DollCfg.red_rate) or 0
    if redRate > 0 and dollRoll(redBase) <= redRate then
        return dollPickFromPool(DollCfg.red_pool or {}), "red"
    end
    return dollPickFromPool(DollCfg.normal_pool or {}), "normal"
end

local function dollTryExtraBox(play)
    local rate = tonumber(DollCfg.extra_box_rate or 0) or 0
    local base = tonumber(DollCfg.extra_box_rate_base or 10000) or 10000
    if rate > 0 and math.random(base) <= rate then
        giveitem(play, "神石宝箱", 1)
        return {{"神石宝箱", 1}}
    end
    return nil
end

local function dollBuildView(record)
    local doll = ((record or {}).doll or {})
    local drawTotal = tonumber(doll.draw_total) or 0
    local firstCount = tonumber(DollCfg.first_draw_count) or 0
    local qualityCount = cloneSimpleTable(doll.quality_count or {})
    qualityCount.normal = tonumber(qualityCount.normal) or 0
    qualityCount.red = tonumber(qualityCount.red) or 0
    qualityCount.hidden = tonumber(qualityCount.hidden) or 0
    return {
        draw_total = drawTotal,
        pity_progress = tonumber(doll.pity_progress) or 0,
        pity_need = tonumber(DollCfg.pity_need) or 0,
        hidden_count = dollCountOwnedByPool(record, dollHiddenPool()),
        owned = dollCopyOwned(doll.owned),
        quality_count = qualityCount,
        last_result = tostring(doll.last_result or ""),
        last_draw_time = tonumber(doll.last_draw_time) or 0,
        newbie_left = math.max(0, firstCount - drawTotal),
        current_cost = dollResolveCost(record),
        summary = dollBuildSummaryList(record),
    }
end

function Doll.draw(play, record, now)
    if type(DollCfg) ~= "table" or type(DollCfg.results) ~= "table" then
        return false, "娃娃机配置缺失"
    end
    local cost = dollResolveCost(record)
    local ok, lack = Common.checkCost(play, cost)
    if not ok then
        return false, string.format("%s不足", lack or "cost")
    end
    Common.payCost(play, cost, "xianfu_doll_draw")
    local resultId, drawType = dollRollResult(record)
    local resultCfg = dollResultCfg(resultId)
    if not resultId or not resultCfg then
        return false, "娃娃机配置异常"
    end
    local fixedReward = cloneRewardList(DollCfg.every_draw_reward or {})
    if #fixedReward > 0 then
        Player.rwjl(play, fixedReward, "仙府娃娃机", 1, 0)
    end
    local doll = record.doll or {}
    doll.draw_total = (tonumber(doll.draw_total) or 0) + 1
    doll.owned = doll.owned or {}
    doll.quality_count = doll.quality_count or {normal = 0, red = 0, hidden = 0}
    doll.owned[resultId] = (tonumber(doll.owned[resultId]) or 0) + 1
    doll.last_result = resultId
    doll.last_draw_time = tonumber(now) or Common.now()
    local quality = tostring(resultCfg.quality or "normal")
    doll.quality_count[quality] = (tonumber(doll.quality_count[quality]) or 0) + 1
    if quality == "hidden" or quality == "red" then
        doll.pity_progress = 0
    else
        doll.pity_progress = (tonumber(doll.pity_progress) or 0) + 1
    end
    doll.hidden_count = dollCountOwnedByPool(record, dollHiddenPool())
    record.doll = doll
    dollRefreshAttr(play, record)
    local extraReward = dollTryExtraBox(play)
    return true, {
        resultId = resultId,
        name = resultCfg.name or resultId,
        quality = quality,
        qualityName = resultCfg.quality_name or quality,
        attrDesc = resultCfg.attr_desc or "",
        drawType = drawType,
        extra_reward = extraReward,
    }
end


-- count: 本次需要累计的抽取次数，用于十连前一次性汇总消耗。
local function dollMergeCost(totalCost, cost)
    totalCost = totalCost or {}
    if type(cost) ~= "table" then
        return totalCost
    end
    local indexMap = {}
    for idx, entry in ipairs(totalCost) do
        if type(entry) == "table" and entry[1] then
            indexMap[tostring(entry[1])] = idx
        end
    end
    for _, entry in ipairs(cost) do
        if type(entry) == "table" and entry[1] then
            local itemName = tostring(entry[1])
            local itemCount = tonumber(entry[2] or 0) or 0
            local existed = indexMap[itemName]
            if existed then
                totalCost[existed][2] = (tonumber(totalCost[existed][2] or 0) or 0) + itemCount
            else
                totalCost[#totalCost + 1] = {itemName, itemCount}
                indexMap[itemName] = #totalCost
            end
        end
    end
    return totalCost
end

-- count: 连抽次数。这里按真实抽取顺序汇总成本，确保新手价与常规价切换一致。
local function dollBuildBatchCost(record, count)
    local totalCost = {}
    local drawTotal = tonumber((((record or {}).doll or {}).draw_total) or 0) or 0
    local drawCount = math.max(1, tonumber(count) or 1)
    local firstCount = tonumber(DollCfg.first_draw_count) or 0
    local useFirstTenCost = drawTotal <= 0 and drawCount == firstCount and firstCount > 0
    for _ = 1, drawCount do
        local cost = nil
        if useFirstTenCost then
            cost = cloneRewardList(DollCfg.first_draw_cost or {})
        else
            cost = cloneRewardList(DollCfg.normal_draw_cost or {})
        end
        totalCost = dollMergeCost(totalCost, cost)
        drawTotal = drawTotal + 1
    end
    return totalCost
end

-- play: 玩家对象；record: 仙府记录；now: 当前时间；count: 连抽次数。
function Doll.drawBatch(play, record, now, count)
    if type(DollCfg) ~= "table" or type(DollCfg.results) ~= "table" then
        return false, "娃娃机配置缺失"
    end
    local drawCount = math.max(1, tonumber(count) or 1)
    local totalCost = dollBuildBatchCost(record, drawCount)
    local ok, lack = Common.checkCost(play, totalCost)
    if not ok then
        return false, string.format("%s不足", lack or "cost")
    end
    Common.payCost(play, totalCost, drawCount > 1 and "xianfu_doll_draw_batch" or "xianfu_doll_draw")
    local results = {}
    local doll = record.doll or {}
    doll.owned = doll.owned or {}
    doll.quality_count = doll.quality_count or {normal = 0, red = 0, hidden = 0}
    record.doll = doll
    for _ = 1, drawCount do
        local resultId, drawType = dollRollResult(record)
        local resultCfg = dollResultCfg(resultId)
        if not resultId or not resultCfg then
            return false, "娃娃机配置异常"
        end
        local fixedReward = cloneRewardList(DollCfg.every_draw_reward or {})
        if #fixedReward > 0 then
            Player.rwjl(play, fixedReward, "仙府娃娃机", 1, 0)
        end
        doll.draw_total = (tonumber(doll.draw_total) or 0) + 1
        doll.owned[resultId] = (tonumber(doll.owned[resultId]) or 0) + 1
        doll.last_result = resultId
        doll.last_draw_time = tonumber(now) or Common.now()
        local quality = tostring(resultCfg.quality or "normal")
        doll.quality_count[quality] = (tonumber(doll.quality_count[quality]) or 0) + 1
        if quality == "hidden" or quality == "red" then
            doll.pity_progress = 0
        else
            doll.pity_progress = (tonumber(doll.pity_progress) or 0) + 1
        end
        local extraReward = dollTryExtraBox(play)
        results[#results + 1] = {
            resultId = resultId,
            name = resultCfg.name or resultId,
            quality = quality,
            qualityName = resultCfg.quality_name or quality,
            attrDesc = resultCfg.attr_desc or "",
            drawType = drawType,
            extra_reward = extraReward,
        }
    end
    doll.hidden_count = dollCountOwnedByPool(record, dollHiddenPool())
    record.doll = doll
    dollRefreshAttr(play, record)
    return true, {
        count = drawCount,
        results = results,
        total_cost = totalCost,
    }
end

local function loadState(play)
    local now = Common.now()
    local record = Storage.ensureRecord(play, {name = Player.GetName(play), now = now})
    Storage.syncGrowth(record, now)
    return {
        now = now,
        player = play,
        record = record,
    }
end

local function persistState(state)
    Storage.savePlayer(state.player, state.record)
end

local function buildSnapshot(state)
    return {
        player = {
            key = state.record.meta.key,
            name = state.record.meta.name,
            xiangHua = state.record.stats.xiangHua or 0,
            likenum = state.record.stats.likenum or 0,
            herbs = state.record.herbs,
            fields = state.record.fields,
            steal = state.record.steal,
            guard = state.record.guard,
            likes = state.record.likes,
            decoration = state.record.decoration,
            refine = state.record.refine,
            pet = state.record.pet,
            doll = dollBuildView(state.record),
            visitor = state.record.visitor,
            level = state.record.level,
            plot_unlock = state.record.plot_unlock,
            growth = state.record.growth,
            level_stats = state.record.level_stats,
            opened = state.record.opened,
            open_slots = getOpenSlotCount(state.record),
        },
    }
end

local function buildPartialSnapshot(state, playerFields)
    local snapshot = {player = {}}
    if type(playerFields) ~= "table" then
        return snapshot
    end
    for _, fieldName in ipairs(playerFields) do
        if fieldName == "open_slots" then
            snapshot.player.open_slots = getOpenSlotCount(state.record)
        elseif fieldName == "doll" then
            snapshot.player.doll = dollBuildView(state.record)
        elseif fieldName == "key" then
            snapshot.player.key = state.record.meta.key
        elseif fieldName == "name" then
            snapshot.player.name = state.record.meta.name
        elseif fieldName == "xiangHua" then
            snapshot.player.xiangHua = state.record.stats.xiangHua or 0
        elseif fieldName == "likenum" then
            snapshot.player.likenum = state.record.stats.likenum or 0
        else
            snapshot.player[fieldName] = state.record[fieldName]
        end
    end
    return snapshot
end

local ACTION_SNAPSHOT_FIELDS = {
    sync = {
        "key", "name", "xiangHua", "likenum", "herbs", "fields", "steal", "guard",
        "likes", "decoration", "refine", "pet", "doll", "visitor", "level",
        "plot_unlock", "growth", "level_stats", "opened", "open_slots",
    },
    plant = {"fields", "herbs", "growth", "level_stats"},
    plantAll = {"fields", "herbs", "growth", "level_stats"},
    harvest = {"fields", "herbs", "growth", "level_stats"},
    buySeed = {"herbs"},
    buyEgg = {"pet", "herbs"},
    buyMaterial = {"pet", "herbs"},
    refine = {"refine", "herbs", "growth", "level_stats"},
    levelUp = {"level", "plot_unlock", "growth", "level_stats", "opened", "open_slots", "fields", "herbs"},
    buyDecoration = {"decoration", "xiangHua"},
    equipDecoration = {"decoration", "xiangHua"},
    hatch = {"pet", "herbs"},
    dollDraw = {"doll", "herbs"},
    like = {"likes", "visitor", "growth", "likenum"},
    steal = {"herbs", "steal", "growth"},
    visit = {"growth"},
}

local function pushAction(play, npcid, action, ok, msg, state, extra)
    local fields = ACTION_SNAPSHOT_FIELDS[action]
    local partial = (fields ~= nil and action ~= "sync") and 1 or 0
    local snapshot = partial == 1 and buildPartialSnapshot(state, fields) or buildSnapshot(state)
    sendluamsg(play, 100, npcid, 1, 0, tbl2json({
        action = action,
        ok = ok,
        message = msg or "",
        extra = extra,
        partial = partial,
        state = snapshot,
    }))
end
local function findOnlineTargetByName(targetName)
    if not targetName or targetName == "" then
        return nil, nil, "请输入玩家名字"
    end
    local actor = getplayerbyname and getplayerbyname(targetName)
    if actor == nil or actor == 0 then
        return nil, nil, "对方不在线或不存在"
    end
    local record = Storage.ensureRecord(actor, {name = Player.GetName(actor), now = Common.now()})
    Storage.syncGrowth(record, Common.now())
    return actor, record
end

---------------------------------------------------------------------
-- Action handlers
---------------------------------------------------------------------
local ActionHandler = {}

function ActionHandler.sync(play, npcid, state)
    dollRefreshAttr(play, state.record)
    persistState(state)
    pushAction(play, npcid, "sync", true, "", state)
end

function ActionHandler.plant(play, npcid, state, params)
    local ok, res = Planting.plant(play, state.record, params or {}, state.now)
    persistState(state)
    if not ok then
        Player.sendmsgEx(play, res or "播种失败#57")
        return
    end
    Player.sendmsgEx(play, "播种成功")
    pushAction(play, npcid, "plant", true, "播种成功", state, res)
end

function ActionHandler.plantAll(play, npcid, state, params)
    local ok, res = Planting.plantAll(play, state.record, params or {}, state.now)
    persistState(state)
    if not ok then
        Player.sendmsgEx(play, res or "一键种植失败#57")
        return
    end
    local seedName = tostring((PlantCfg[tostring((params or {}).seedId or "")] or {}).name or "灵草")
    local msg = string.format("一键种植完成，已播种%s块%s", tostring(res.count or 0), seedName)
    Player.sendmsgEx(play, msg)
    pushAction(play, npcid, "plantAll", true, msg, state, res)
end

function ActionHandler.harvest(play, npcid, state, params)
    local ok, res = Planting.harvest(play, state.record, params or {}, state.now)
    persistState(state)
    if not ok then
        Player.sendmsgEx(play, res or "尚未成熟#57")
        return
    end
    Player.sendmsgEx(play, "收获完成#57")
    pushAction(play, npcid, "harvest", true, "收获完成", state, res)
end

function ActionHandler.buySeed(play, npcid, state, params)
    local ok, res = Shop.buySeed(play, state.record, params or {})
    persistState(state)
    if not ok then
        Player.sendmsgEx(play, res or "购买失败#57")
        return
    end
    Player.sendmsgEx(play, "购买成功")
    pushAction(play, npcid, "buySeed", true, "购买成功", state, res)
end

function ActionHandler.buyEgg(play, npcid, state, params)
    local ok, res = Shop.buyEgg(play, state.record, params or {})
    persistState(state)
    if not ok then
        Player.sendmsgEx(play, res or "购买失败#57")
        return
    end
    Player.sendmsgEx(play, "购买成功")
    pushAction(play, npcid, "buyEgg", true, "购买成功", state, res)
end

function ActionHandler.buyMaterial(play, npcid, state, params)
    local ok, res = Shop.buyMaterial(play, state.record, params or {})
    persistState(state)
    if not ok then
        Player.sendmsgEx(play, res or "购买失败#57")
        return
    end
    Player.sendmsgEx(play, "购买成功")
    pushAction(play, npcid, "buyMaterial", true, "购买成功", state, res)
end

function ActionHandler.refine(play, npcid, state, params)
    local ok, res = Refine.start(play, state.record, params or {}, state.now)
    persistState(state)
    if not ok then
        Player.sendmsgEx(play, res or "炼丹失败#57")
        return
    end
    Player.sendmsgEx(play, "炼丹完成#57")
    pushAction(play, npcid, "refine", true, "炼丹完成", state, res)
end

function ActionHandler.levelUp(play, npcid, state, params)
    local ok, res = levelUp(play, state.record)
    persistState(state)
    if not ok then
        Player.sendmsgEx(play, tostring(res or "仙府升级失败") .. "#57")
        pushAction(play, npcid, "levelUp", false, tostring(res or "仙府升级失败"), state)
        return
    end
    Player.sendmsgEx(play, string.format("仙府升级成功，当前#57|【%d级】#218|", tonumber(state.record.level or 1) or 1))
    pushAction(play, npcid, "levelUp", true, "仙府升级成功", state, res)
end

function ActionHandler.buyDecoration(play, npcid, state, params)
    local ok, res = Decoration.buy(play, state.record, params and params.decoId)
    persistState(state)
    if not ok then
        Player.sendmsgEx(play, res or "购买失败#57")
        return
    end
    Player.sendmsgEx(play, "购买成功")
    pushAction(play, npcid, "buyDecoration", true, "购买成功", state, res)
end

function ActionHandler.equipDecoration(play, npcid, state, params)
    local ok, res = Decoration.equip(state.record, params and params.decoId)
    persistState(state)
    if not ok then
        Player.sendmsgEx(play, res or "装扮无法生效#57")
        return
    end
    Player.sendmsgEx(play, "装扮已生效#57")
    pushAction(play, npcid, "equipDecoration", true, "装扮已生效", state, res)
end

function ActionHandler.hatch(play, npcid, state, params)
    local ok, res = Pet.hatch(play, state.record, params or {}, state.now)
    persistState(state)
    if not ok then
        Player.sendmsgEx(play, res or "孵化失败#57")
        return
    end
    Player.sendmsgEx(play, "孵化成功")
    pushAction(play, npcid, "hatch", true, "孵化成功", state, res)
end

-- function ActionHandler.feed(play, npcid, state, params)
--     local ok, res = Pet.feed(play, state.record, params or {})
--     persistState(state)
--     if not ok then
--         Player.sendmsgEx(play, res or "喂养失败#57")
--         return
--     end
--     Player.sendmsgEx(play, "喂养完成#57")
--     pushAction(play, npcid, "feed", true, "喂养完成", state, res)
-- end

-- function ActionHandler.identify(play, npcid, state, params)
--     local ok, res = Pet.identify(play, state.record, params or {})
--     if not ok then
--         Player.sendmsgEx(play, res or "鉴定失败#57")
--         return
--     end
--     Player.sendmsgEx(play, "鉴定完成#57")
--     pushAction(play, npcid, "identify", true, "鉴定完成", state, res)
-- end

function ActionHandler.dollDraw(play, npcid, state)
    local ok, res = Doll.draw(play, state.record, state.now)
    persistState(state)
    if not ok then
        Player.sendmsgEx(play, res or "抓娃娃失败#57")
        return
    end
    Player.sendmsgEx(play, string.format("抓取成功：%s", tostring(res.name or "娃娃")))
    pushAction(play, npcid, "dollDraw", true, "抓取成功", state, res)
end

local function handleVisit(play, npcid, state, params, fn)
    local targetName = params and params.targetName
    if not targetName or targetName == "" then
        Player.sendmsgEx(play, "请输入要拜访的玩家名字#57")
        return
    end
    local actor, record, err = findOnlineTargetByName(targetName)
    if not actor then
        Player.sendmsgEx(play, (err or "对方不在线") .. "#57")
        return
    end
    fn(actor, record, params or {})
end

function ActionHandler.like(play, npcid, state, params)
    handleVisit(play, npcid, state, params or {}, function(actor, targetRecord)
        local ok, res = Like.perform(play, state.record, targetRecord, state.now)
        if ok then
            Visitor.push(targetRecord, state.record.meta.name, "like", "+" .. (LikeCfg.likeValue or 0), state.now)
            Storage.savePlayer(actor, targetRecord)
        end
        persistState(state)
        if not ok then
            Player.sendmsgEx(play, res or "点赞失败#57")
            return
        end
        Player.sendmsgEx(play, "点赞成功")
        pushAction(play, npcid, "like", true, "点赞成功", state, res)
    end)
end

function ActionHandler.steal(play, npcid, state, params)
    handleVisit(play, npcid, state, params or {}, function(actor, targetRecord, visitParams)
        local ok, res = Steal.try(play, state.record, targetRecord, state.now, tonumber(visitParams.gridId), actor)
        if ok then
            Visitor.push(targetRecord, state.record.meta.name, "steal", "-" .. summarizeReward(res.product), state.now)
            Storage.savePlayer(actor, targetRecord)
        end
        persistState(state)
        if not ok then
            Player.sendmsgEx(play, res or "偷取失败#57")
            return
        end
        Player.sendmsgEx(play, "偷取成功")
        pushAction(play, npcid, "steal", true, "偷取成功", state, res)
    end)
end

function ActionHandler.visit(play, npcid, state, params)
    handleVisit(play, npcid, state, params or {}, function(actor, targetRecord)
        applyGrowth(state.record, "visit", 1, state.now)
        local snapshot = Storage.buildPublicSnapshot(targetRecord)
        snapshot.isGuest = true
        Storage.savePlayer(actor, targetRecord)
        persistState(state)
        pushAction(play, npcid, "visit", true, "", state, {target = snapshot, visitMode = true})
    end)
end

---------------------------------------------------------------------
-- NPC 入口
---------------------------------------------------------------------
function npc.refreshDollAttr(play)
    local state = loadState(play)
    dollRefreshAttr(play, state.record)
    persistState(state)
end

-- 供外部功能在玩家真正开府时显式标记，避免仅因砍树或抓娃娃写入数据就被判定为已开辟仙府。
function npc.markOpened(play)
    local state = loadState(play)
    state.record.opened = 1
    persistState(state)
end

-- 供外部（砍树、拜访等）复用成长值累计。
function npc.touchGrowth(play, reason, times)
    local state = loadState(play)
    applyGrowth(state.record, tostring(reason or ""), tonumber(times or 1) or 1, state.now)
    persistState(state)
    return state.record.growth
end

function npc.getState(play)
    local state = loadState(play)
    persistState(state)
    return state.record
end

function npc.getDollPanelPayload(play)
    local state = loadState(play)
    dollRefreshAttr(play, state.record)
    persistState(state)
    return {
        doll = dollBuildView(state.record),
        ten_cost = dollBuildBatchCost(state.record, 10),
    }
end

function npc.drawDollFromWoodcut(play)
    local state = loadState(play)
    local ok, res = Doll.draw(play, state.record, state.now)
    persistState(state)
    return ok, res, {
        doll = dollBuildView(state.record),
        extra = ok and res or nil,
    }
end

-- count: 砍树娃娃机请求的抽取次数，当前只会传 1 或 10。
function npc.drawDollBatchFromWoodcut(play, count)
    local state = loadState(play)
    local ok, res = Doll.drawBatch(play, state.record, state.now, count)
    persistState(state)
    local extra = nil
    if ok and type(res) == "table" then
        local results = res.results or {}
        local last = results[#results]
        extra = {
            count = tonumber(res.count) or 1,
            results = results,
        }
        if type(last) == "table" then
            extra.resultId = last.resultId
            extra.name = last.name
            extra.quality = last.quality
            extra.qualityName = last.qualityName
            extra.attrDesc = last.attrDesc
            extra.drawType = last.drawType
            extra.extra_reward = last.extra_reward
        end
    end
    return ok, res, {
        doll = dollBuildView(state.record),
        ten_cost = dollBuildBatchCost(state.record, 10),
        extra = extra,
    }
end

function npc.main(play, npcid)
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    if not (jq_data["npc_55"] and jq_data["npc_55"] >= 2) then
        Player.sendmsgEx(play, "你还未开启相关剧情，暂无法使用#57")
        return
    end
    local state = loadState(play)
    dollRefreshAttr(play, state.record)
    persistState(state)
    sendluamsg(play, 100, npcid, 0, 0, tbl2json(buildSnapshot(state)))
    openhyperlink(play, 1, 2)
end

function npc.link(play, npcid, p2, p3, msgData)
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local action = Guard.normalizeAction(play, npcid, p2)
    if not action then
        return
    end
    if not Guard.ensureActionAllowed(play, npcid, action, Guard.newActionSet({1, 2})) then
        return
    end
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    if not (jq_data["npc_55"] and jq_data["npc_55"] >= 2) then
        Player.sendmsgEx(play, "你还未开启相关剧情，暂无法使用#57")
        return
    end
    local payload = Guard.safeJsonDecode(play, msgData, nil, {})
    payload.action = payload.action or payload.op or "sync"
    local state = loadState(play)
    local handler = ActionHandler[payload.action]
    if not handler then
        pushAction(play, npcid, payload.action, false, "未知操作", state)
        return
    end
    handler(play, npcid, state, payload.param or payload)
end

return npc
