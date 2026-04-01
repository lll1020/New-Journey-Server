npc = {}

--[[
仙府总览：
1. 所有玩法参数都来自 teshudata["npc_44"]，这里会读取 gridSize、currencyMap、PlantCfg 等子表，确保策划调表即可改玩法。
2. 玩家个人数据单独存放在 VarCfg.T_XianFuData，对他人访问时从在线角色实时拉取，避免历史全服大表。
3. 当前仅保留仙府基础玩法，不再维护仙府排行榜数据。
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
local maxShopBuy = _config.shopMaxBuy or 9999
local visitorLimit = _config.visitorLogLimit or 20
local gridSize = _config.gridSize or 9

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

local PLAYER_DATA_VAR = VarCfg.T_XianFuData or "T47"

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
    record.visitor = record.visitor or {log = {}}
    record.visitor.log = record.visitor.log or {}
    record.stats = record.stats or {xiangHua = 0}
    Storage.ensurePlots(record)
    return record
end

function Storage.ensurePlots(record)
    for i = 1, gridSize do
        local plot = record.fields[i]
        if type(plot) ~= "table" then
            plot = {gridId = i}
            record.fields[i] = plot
        end
        plot.gridId = i
        plot.state = plot.state or "empty"
        if plot.state == "empty" then
            resetPlot(plot, i)
        end
    end
end

function Storage.syncGrowth(record, now)
    now = now or Common.now()
    for _, plot in pairs(record.fields) do
        if plot.state == "growing" and plot.finishAt and now >= plot.finishAt then
            plot.state = "mature"
        end
        if plot.state ~= "empty" and plot.seedId and not PlantCfg[plot.seedId] then
            resetPlot(plot, plot.gridId)
        end
    end
end

function Storage.buildPublicSnapshot(record)
    return {
        key = record.meta.key,
        name = record.meta.name,
        xiangHua = record.stats.xiangHua or 0,
        herbs = record.herbs,
        fields = record.fields,
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

function Planting.plant(play, record, params, now)
    local gridId = tonumber(params.gridId)
    if not gridId or gridId < 1 or gridId > gridSize then
        return false, "?????"
    end
    local seedId = params.seedId
    local cfg = PlantCfg[seedId]
    if not cfg then
        return false, "种子配置不存在"
    end
    local plot = record.fields[gridId]
    if not plot then
        return false, "地块不存在"
    end
    Storage.syncGrowth(record, now)
    if plot.state ~= "empty" then
        return false, "当前地块已占用"
    end
    local ok, lack = Common.checkCost(play, cfg.cost)
    if not ok then
        return false, string.format("%s不足", lack or "cost")
    end
    Common.payCost(play, cfg.cost, "xianfu_seed")
    local startAt = now or Common.now()
    plot.seedId = seedId
    plot.state = "growing"
    plot.plantedAt = startAt
    local mature = (cfg.matureTime or 0)
    if mature > 0 and getplaydef(play,"N$buff306") == 1 then
        -- 黑化肥会挥发：仙草成熟时间加快30%
        mature = math.ceil(mature * 0.7)
        if mature < 1 then
            mature = 1
        end
    end
    plot.finishAt = startAt + mature
    plot.canSteal = cfg.canSteal and true or false
    plot.product = cloneRewardList(cfg.product)
    return true, {plot = plot}
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
    if not plot.product or #plot.product == 0 then
        resetPlot(plot, gridId)
        return false, "没有可收获的灵草"
    end
    Player.rwjl(play, plot.product, "仙府收获", 1, 0)
    addProductStat(record, plot.product)
    resetPlot(plot, gridId)
    return true, {herbs = record.herbs, plot = plot}
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
    local entry = ShopIndex.seeds[params.id]
    local ok, amountOrErr = purchase(play, entry, params.amount, "xianfu_seed_shop")
    if not ok then
        return false, amountOrErr
    end
    local reward = {{entry.seed, amountOrErr}}
    Player.rwjl(play, reward, "仙府购种", 1, 0)
    return true, {reward = reward}
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
    local id = tonumber(gridId)
    if not id then
        return nil, nil, "请指定可偷取的地块位置"
    end
    local plot = record.fields[id]
    if type(plot) ~= "table" then
        return nil, nil, "目标地块不存在"
    end
    if plot.state ~= "mature" then
        return nil, nil, "目标地块尚未成熟"
    end
    if not plot.product or #plot.product == 0 then
        return nil, nil, "目标地块没有可偷的灵草"
    end
    local cfg = PlantCfg[plot.seedId]
    if not (cfg and cfg.canSteal) then
        return nil, nil, "该地块禁止偷取"
    end
    return plot, cfg
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


function Steal.try(play, thiefRecord, targetRecord, now, gridId)
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
    local bucket = ensureStealCooldown(thiefRecord.steal)
    local cd = bucket[targetRecord.meta.key] or 0
    if cd > now then
        return false, "仍在冷却中"
    end
    if not plot.product or #plot.product == 0 then
        return false, "没有剩余灵草"
    end
    local reward, left = splitStealReward(plot)
    if not reward then
        return false, "没有剩余灵草"
    end
    Player.rwjl(play, reward, "仙府偷菜", 1, 0)
    addProductStat(thiefRecord, reward)
    thiefRecord.steal.daily.count = thiefRecord.steal.daily.count + 1
    targetRecord.guard.daily.count = targetRecord.guard.daily.count + 1
    bucket[targetRecord.meta.key] = now + (StealCfg.cooldown or 0)
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
    -- 黑化肥会挥发：炼丹消耗-50%
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
        return false, string.format("请先装备#249|%s#255|后再炼丹", RefineCfg.needEquip or "炼丹许可证")
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
    --暂时不用称号
    -- if hasAllRecipes(record) and TitleCfg.DanMaster then
    --     Player.title_give(play, TitleCfg.DanMaster.name)
    -- end
    return true, {reward = reward, collection = record.refine.collection, lastTime = record.refine.lastTime}
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
--         return false, "灵蛋不存在"
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
--         return false, "灵兽不存在"
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
--         return false, "灵兽不存在"
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
-- 状态加载 / 持久化
---------------------------------------------------------------------
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
            visitor = state.record.visitor,
        },
    }
end

local function pushAction(play, npcid, action, ok, msg, state, extra)
    sendluamsg(play, 100, npcid, 1, 0, tbl2json({
        action = action,
        ok = ok,
        message = msg or "",
        extra = extra,
        state = buildSnapshot(state),
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
        local ok, res = Steal.try(play, state.record, targetRecord, state.now, tonumber(visitParams.gridId))
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
function npc.main(play, npcid)
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    if not (jq_data["npc_55"] and jq_data["npc_55"] >= 2) then
        Player.sendmsgEx(play, "你还未开启相关剧情，暂无法使用#57")
        return
    end
    local state = loadState(play)
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

















