local YeHuo = {}

local DATA_VAR = (VarCfg and VarCfg["T_残魂商店"]) or "T66"
local MAX_FIRE = 100
local CITY_POS = {83, 121, 4}
local INSTANCE_PREFIX = "_tianfa_"
local INSTANCE_BASE_MAP = "mwsl"
local INSTANCE_TIME = 300
local TIMER_ID = 1
local NOTICE_COOLDOWN = 5

local function toNumber(value, defaultValue)
    local number = tonumber(value)
    if number == nil then
        return defaultValue or 0
    end
    return number
end

local function toInt(value)
    return math.floor(toNumber(value, 0))
end

local TEXT_HUNTER = "天罚·猎杀者"
local TEXT_HUNTER_TITLE = "顶级猎杀者"
local TEXT_FIRE_CRYSTAL = "业火结晶"
local TEXT_SHINE_CRYSTAL = "辉耀水晶"
local TEXT_BEGIN_DUST = "初阶星尘"
local TEXT_YUANBAO = "元宝"
local TEXT_SIX_CITY = "六大陆主城"
local TEXT_TIANFA_INSTANCE = "天罚猎杀者秘境"
local TEXT_WORLD = "世界"
local TEXT_DALU = "大陆"
local FIRE_BUFF_ID = 20183

local function getData(play)
    local data = Player.getJsonTableByVar(play, DATA_VAR) or {}
    data.fire = math.max(0, math.min(MAX_FIRE, toNumber(data.fire, 0)))
    data.point = math.max(0, toInt(data.point))
    data.tianfa_pending = toInt(data.tianfa_pending)
    data.tianfa_active = toInt(data.tianfa_active)
    data.tianfa_map = tostring(data.tianfa_map or "")
    data.tianfa_back = tostring(data.tianfa_back or "")
    data.tianfa_notice_at = toInt(data.tianfa_notice_at)
    return data
end

local function saveData(play, data)
    Player.setJsonVarByTable(play, DATA_VAR, data)
end

local function refreshFireBuff(play, fire)
    if not play then
        return
    end
    fire = math.max(0, math.min(MAX_FIRE, toNumber(fire, 0)))
    if fire <= 0 then
        if type(delbuff) == "function" then
            pcall(delbuff, play, FIRE_BUFF_ID)
        end
        return
    end
    local stack = math.floor(fire)
    if type(addbuff) == "function" then
        pcall(addbuff, play, FIRE_BUFF_ID)
    end
    if type(buffstack) == "function" then
        pcall(buffstack, play, FIRE_BUFF_ID, "=", stack, 1)
    end
end

local function mapOf(object, index)
    if not object then
        return ""
    end
    return tostring(getbaseinfo(object, index) or "")
end

local function isSixMap(mapName)
    return mapName ~= "" and daluditu and toInt(daluditu[mapName]) == 6
end

local function isSixContext(play)
    return isSixMap(mapOf(play, 3)) or isSixMap(mapOf(play, 45))
end

local function isSixCityMap(play)
    return mapOf(play, 3) == TEXT_SIX_CITY or mapOf(play, 45) == TEXT_SIX_CITY
end

local function findSixCity()
    if daluditu and daluditu[TEXT_SIX_CITY] then
        return TEXT_SIX_CITY
    end
    return ""
end

local function isMirrorMap(mapName)
    return mapName ~= "" and checkmirrormap(mapName)
end

local function sendEntrance(play)
    if not play then
        return
    end
    local data = getData(play)
    local now = os.time()
    if now - data.tianfa_notice_at < NOTICE_COOLDOWN then
        return
    end
    data.tianfa_notice_at = now
    saveData(play, data)
    messagebox(play, "业火值已达到100，请进入天罚猎杀者秘境完成挑战。", "@yehuo_tianfa_confirm,1", "@exit")
end

local function moveToCity(play)
    local city = findSixCity()
    if city ~= "" then
        mapmove(play, city, CITY_POS[1], CITY_POS[2], CITY_POS[3])
    else
        mapmove(play, "xtc", 137, 138, 7)
    end
end

local function enforceTianfaLimit(play, data)
    if not play then
        return data
    end
    data = data or getData(play)
    if data.fire < MAX_FIRE or data.tianfa_active == 1 then
        return data
    end

    data.fire = MAX_FIRE
    data.tianfa_pending = 1
    saveData(play, data)
    refreshFireBuff(play, data.fire)

    if isSixContext(play) and not isSixCityMap(play) then
        moveToCity(play)
    end
    sendEntrance(play)
    return data
end

local function removeInstance(mapName)
    if mapName == "" then
        return
    end
    setenvirofftimer(mapName, TIMER_ID)
    if checkmirrormap(mapName) then
        delmirrormap(mapName)
    end
end

local function resetChallenge(play, addPoint)
    local data = getData(play)
    local oldMap = data.tianfa_map
    data.fire = 0
    data.tianfa_pending = 0
    data.tianfa_active = 0
    data.tianfa_map = ""
    data.tianfa_back = ""
    if addPoint then
        data.point = data.point + 10
    end
    saveData(play, data)
    refreshFireBuff(play, data.fire)
    removeInstance(oldMap)
end

local function markPending(play)
    local data = getData(play)
    if data.fire < MAX_FIRE then
        return data
    end
    data.fire = MAX_FIRE
    data.tianfa_pending = 1
    saveData(play, data)
    refreshFireBuff(play, data.fire)
    if data.tianfa_active ~= 1 then
        enforceTianfaLimit(play, data)
    end
    return data
end

function YeHuo.notifyFireChanged(play)
    local data = getData(play)
    if data.fire >= MAX_FIRE then
        markPending(play)
    end
    return data.fire
end

function YeHuo.getData(play)
    return getData(play)
end

function YeHuo.buildPayload(play)
    local data = getData(play)
    return {
        fire = data.fire,
        fire_max = MAX_FIRE,
        tianfa_pending = data.tianfa_pending,
        tianfa_active = data.tianfa_active,
        tianfa_map = data.tianfa_map,
        tianfa_notice_at = data.tianfa_notice_at,
        can_enter_tianfa = data.tianfa_pending == 1 and data.tianfa_active ~= 1 and 1 or 0,
    }
end

function YeHuo.addFire(play, amount)
    amount = toNumber(amount, 0)
    if amount == 0 then
        return getData(play).fire
    end
    local data = getData(play)
    data.fire = math.max(0, math.min(MAX_FIRE, data.fire + amount))
    saveData(play, data)
    refreshFireBuff(play, data.fire)
    if data.fire >= MAX_FIRE then
        markPending(play)
    end
    return data.fire
end

function YeHuo.adjustHarm(play, damage, attacker)
    damage = toNumber(damage, 0)
    if damage <= 0 or not play or not attacker then
        return damage
    end
    if getbaseinfo(attacker, -1) or not isSixContext(play) then
        return damage
    end
    local fire = getData(play).fire
    local rate = 0
    if fire >= 91 then
        rate = 15
    elseif fire >= 61 then
        rate = 10
    elseif fire >= 31 then
        rate = 5
    end
    if rate <= 0 then
        return damage
    end
    return math.max(1, math.floor(damage * (100 + rate) / 100))
end

local function buildInstanceMap(play)
    return mapOf(play, 1) .. INSTANCE_PREFIX .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999))
end

function YeHuo.enter(play)
    if not play then
        return false
    end
    local data = getData(play)
    if data.tianfa_pending ~= 1 or data.fire < MAX_FIRE then
        Player.sendmsgEx(play, "业火值不足100，暂时无法进入天罚秘境。#57")
        return false
    end
    if data.tianfa_active == 1 and data.tianfa_map ~= "" then
        Player.sendmsgEx(play, "你正在天罚秘境中，不能重复进入。#57")
        return false
    end

    local instanceMap = buildInstanceMap(play)
    local backMap = mapOf(play, 3)
    local backX = toInt(getbaseinfo(play, 4))
    local backY = toInt(getbaseinfo(play, 5))
    addmirrormap(INSTANCE_BASE_MAP, instanceMap, TEXT_TIANFA_INSTANCE, INSTANCE_TIME, "xtc", 136, 136)

    data.tianfa_active = 1
    data.tianfa_map = instanceMap
    data.tianfa_back = backMap .. "," .. tostring(backX) .. "," .. tostring(backY)
    saveData(play, data)

    mapmove(play, instanceMap, 29, 27, 2)
    genmonex(instanceMap, 32, 36, TEXT_HUNTER, 1, 1, play, 54, "", 0)
    setenvirontimer(instanceMap, TIMER_ID, 1, "@yehuo_tianfa_tick," .. tostring(play) .. "," .. instanceMap)
    senddelaymsg(play, "天罚秘境挑战剩余时间：%s", INSTANCE_TIME, 250, 1, "@yehuo_tianfa_timeout")
    Player.sendmsgEx(play, "已进入天罚猎杀者秘境，击败猎杀者完成挑战。#57")
    return true
end

function yehuo_tianfa_confirm(play, code)
    if YeHuo and YeHuo.enter then
        YeHuo.enter(play)
    end
end

local function findHunter(instanceMap)
    local list = getobjectinmap(instanceMap, 0, 0, 999, 2)
    if type(list) ~= "table" then
        return nil
    end
    for _, mob in pairs(list) do
        if mapOf(mob, 1) == TEXT_HUNTER and toInt(getbaseinfo(mob, 9)) > 0 then
            return mob
        end
    end
    return nil
end

local function finishSuccess(play)
    local data = getData(play)
    local instanceMap = data.tianfa_map
    data.fire = 0
    data.tianfa_pending = 0
    data.tianfa_active = 0
    data.tianfa_map = ""
    data.tianfa_back = ""
    saveData(play, data)
    refreshFireBuff(play, data.fire)
    removeInstance(instanceMap)
    Player.rwjl(play, {
        {TEXT_FIRE_CRYSTAL, 5},
        {TEXT_SHINE_CRYSTAL, 10},
        {TEXT_YUANBAO, 100000},
        {TEXT_BEGIN_DUST, 10},
    }, "天罚猎杀者挑战奖励", 1, 1000)
    if not checktitle(play, TEXT_HUNTER_TITLE) then
        Player.title_give(play, TEXT_HUNTER_TITLE, 1)
    end
    Player.sendmsgEx(play, "天罚猎杀者挑战成功，业火值已清零并获得奖励。#57")
    moveToCity(play)
end

function yehuo_tianfa_tick(_, play, instanceMap)
    local data = getData(play)
    if data.tianfa_active ~= 1 or data.tianfa_map ~= instanceMap or mapOf(play, 3) ~= instanceMap then
        setenvirofftimer(instanceMap, TIMER_ID)
        return
    end
    if not findHunter(instanceMap) then
        finishSuccess(play)
    end
end

function yehuo_tianfa_timeout(play)
    local data = getData(play)
    if data.tianfa_active ~= 1 then
        return
    end
    local instanceMap = data.tianfa_map
    data.tianfa_active = 0
    data.tianfa_map = ""
    data.tianfa_back = ""
    data.tianfa_pending = 1
    data.fire = MAX_FIRE
    saveData(play, data)
    refreshFireBuff(play, data.fire)
    removeInstance(instanceMap)
    moveToCity(play)
    sendEntrance(play)
end

local function onLoginEnd(play)
    local data = getData(play)
    if data.tianfa_active == 1 then
        local oldMap = data.tianfa_map
        data.tianfa_active = 0
        data.tianfa_map = ""
        data.tianfa_back = ""
        data.tianfa_pending = data.fire >= MAX_FIRE and 1 or data.tianfa_pending
        saveData(play, data)
        removeInstance(oldMap)
    end
    if data.fire >= MAX_FIRE then
        markPending(play)
    else
        refreshFireBuff(play, data.fire)
    end
end

local function onSwitchMap(play)
    local data = getData(play)
    local mapName = mapOf(play, 3)
    if data.tianfa_active == 1 and data.tianfa_map ~= "" and mapName ~= data.tianfa_map then
        mapmove(play, data.tianfa_map, 29, 27, 2)
        return
    end
    if (data.tianfa_pending == 1 or data.fire >= MAX_FIRE) and isSixContext(play) then
        enforceTianfaLimit(play, data)
    end
end

local function onPlaydie(play)
    local data = getData(play)
    if data.tianfa_active ~= 1 or data.tianfa_map == "" or mapOf(play, 3) ~= data.tianfa_map then
        return
    end
    resetChallenge(play, true)
    Player.sendmsgEx(play, "你在天罚秘境中死亡，业火值已清零，残魂值+10。#57")
    moveToCity(play)
end

local function onKillMon(play, mob)
    local data = getData(play)
    if data.tianfa_active ~= 1 or data.tianfa_map == "" or mapOf(play, 3) ~= data.tianfa_map then
        return
    end
    if mob and mapOf(mob, 1) == TEXT_HUNTER then
        finishSuccess(play)
    end
end

local function onKillMonFire(play, mob)
    local playerName = play and mapOf(play, 1) or ""
    local playerMap = play and mapOf(play, 3) or ""
    local playerMapAlias = play and mapOf(play, 45) or ""
    local mobName = mob and mapOf(mob, 1) or ""
    local mobMap = mob and mapOf(mob, 3) or ""
    local mobMapAlias = mob and mapOf(mob, 45) or ""
    local playerIsSix = play and isSixContext(play) or false
    local mobIsSix = mob and (isSixMap(mobMap) or isSixMap(mobMapAlias)) or false
    -- if release_print then
    --     release_print(
    --         "[YEHUO_DEBUG]",
    --         "stage=onKillMonFire",
    --         "player=" .. tostring(playerName),
    --         "player_map=" .. tostring(playerMap),
    --         "player_map_alias=" .. tostring(playerMapAlias),
    --         "player_six=" .. tostring(playerIsSix),
    --         "mob=" .. tostring(mobName),
    --         "mob_map=" .. tostring(mobMap),
    --         "mob_map_alias=" .. tostring(mobMapAlias),
    --         "mob_six=" .. tostring(mobIsSix)
    --     )
    -- end
    if not play or not mob or not isSixContext(play) then
        -- if release_print then
        --     release_print("[YEHUO_DEBUG]", "stage=blocked", "reason=player_or_mob_missing_or_player_not_six")
        -- end
        return
    end
    local currentData = getData(play)
    if currentData.fire >= MAX_FIRE or currentData.tianfa_pending == 1 then
        enforceTianfaLimit(play, currentData)
        return
    end
    if not mobIsSix then
        -- if release_print then
        --     release_print("[YEHUO_DEBUG]", "stage=blocked", "reason=mob_not_six")
        -- end
        return
    end
    if mobName == TEXT_HUNTER then
        -- if release_print then
        --     release_print("[YEHUO_DEBUG]", "stage=blocked", "reason=tianfa_hunter")
        -- end
        return
    end
    local mobType = toInt((guaiwutype and guaiwutype[mobName]) or 0)
    local isWorldBoss = string.find(mobName, "BOSS", 1, true) ~= nil
        and (string.find(mobName, TEXT_WORLD, 1, true) ~= nil
            or string.find(mobName, TEXT_DALU, 1, true) ~= nil)
    local amount = isWorldBoss and 10 or (mobType >= 2 and 5 or (mobType == 1 and 2 or 0.5))
    local before = getData(play).fire
    local after = YeHuo.addFire(play, amount)
    -- if release_print then
    --     release_print(
    --         "[YEHUO_DEBUG]",
    --         "stage=add_fire",
    --         "player=" .. tostring(playerName),
    --         "mob=" .. tostring(mobName),
    --         "mob_type=" .. tostring(mobType),
    --         "world_boss=" .. tostring(isWorldBoss),
    --         "amount=" .. tostring(amount),
    --         "before=" .. tostring(before),
    --         "after=" .. tostring(after)
    --     )
    -- end
end

GameEvent.add(EventCfg.onLoginEnd, onLoginEnd, "yehuo.login")
GameEvent.add(EventCfg.goSwitchMap, onSwitchMap, "yehuo.switch_map")
GameEvent.add(EventCfg.onPlaydie, onPlaydie, "yehuo.play_die")
GameEvent.add(EventCfg.onKillMon, onKillMon, "yehuo.challenge_kill")
GameEvent.add(EventCfg.onKillMon, onKillMonFire, "yehuo.fire_kill")

rawset(_G, "YeHuo", YeHuo)
return YeHuo
