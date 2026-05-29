release_print("useitme.lua")
local RANDOM_TRANSFER_CD = 3
local _equip_slots = {0,1,3,4,5,6,7,8,9,10,11,13,14,16,30,31,32,33,34,35,36,37,38,39,40,41}
local function _has_equip_name(play, itemname)
    if not play or not itemname or itemname == "" then
        return false
    end
    for _, pos in ipairs(_equip_slots) do
        if Player.hasEquipOnPos(play, pos, itemname) then
            return true
        end
    end
    return false
end
local function _random_transfer_cd_left(play, now)
    local nextTime = tonumber(getplaydef(play, "N$随机传送CD") or 0) or 0
    local left = nextTime - (now or os.time())
    return left > 0 and left or 0
end
--------------------双击物品触发-------------------随机石
function stdmodefunc9(play, item)
    setplaydef(play,"S$dtm",getbaseinfo(play, 3))
    release_print("随机石")
    local now = os.time()
    local cdLeft = _random_transfer_cd_left(play, now)
    if cdLeft > 0 then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>随机传送冷却中，请稍后...</font>","Type":9}')
        return false
    end
    if getplaydef(play,"N$战斗状态") < now or _has_equip_name(play, "遮云日") then
        map(play,getbaseinfo(play,3))
        setplaydef(play, "N$随机传送CD", now + RANDOM_TRANSFER_CD)
        -- if getflagstatus(play, 300) == 1 then
        --     startautoattack(play)
        -- end
    else
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>战斗状态无法使用，脱战3秒后可用...</font>","Type":9}')
    end
    return false
end
--------------------双击物品触发-------------------回城石
-- 灰界系列地图是否需要回到【灰界】统一通过 xilieditu 映射判断，避免这里再维护一份重复地图表。
local function _is_huijie_return_map(map_name)
    return type(xilieditu) == "table" and xilieditu[map_name] == 3
end
function stdmodefunc10(play, item)
    setplaydef(play,"S$dtm",getbaseinfo(play, 3))
    local du = getbaseinfo(play, 3)
    if getplaydef(play,"N$战斗状态") < os.time() then
        if du == "xtc" or du == "二大陆主城" or du == "三大陆主城" or du == "四大陆主城" or du == "五大陆主城" or du == "六大陆主城" or du == "七大陆主城" or du == "八大陆主城" or du == "九大陆主城" then
            mapmove(play, 'xtc', 137,138,8)
            addhpper(play, '=', 100)
            addmpper(play, '=', 100)
        elseif daluditu[du] and daluditu[du] == 1 then mapmove(play, "xtc",137,138,5) addhpper(play, '=', 100) addmpper(play, '=', 100)
        elseif daluditu[du] and daluditu[du] == 2 then mapmove(play, "二大陆主城",105,120,4) addhpper(play, '=', 100) addmpper(play, '=', 100)
        elseif daluditu[du] and daluditu[du] == 3 then
            if du == "灰界" and Player.hasThirdContinentPass(play) then
                mapmove(play, "三大陆主城",159,231,5)
                addhpper(play, '=', 100)
                addmpper(play, '=', 100)
            elseif du == "灰界" and not Player.hasThirdContinentPass(play) then
                mapmove(play, "xtc",137,138,5) addhpper(play, '=', 100) addmpper(play, '=', 100)
            elseif _is_huijie_return_map(du) then
                mapmove(play, "灰界",201,199,5)
                addhpper(play, '=', 100)
                addmpper(play, '=', 100)
            elseif Player.hasThirdContinentPass(play) then
                mapmove(play, "三大陆主城",159,231,5)
                addhpper(play, '=', 100)
                addmpper(play, '=', 100)
            else
                Player.moveToThirdContinentFrontier(play)
            end
        elseif daluditu[du] and daluditu[du] == 4 then mapmove(play, "四大陆主城",37,33,3) addhpper(play, '=', 100) addmpper(play, '=', 100)
        elseif daluditu[du] and daluditu[du] == 5 then mapmove(play, "五大陆主城",30,28,4) addhpper(play, '=', 100) addmpper(play, '=', 100)
        elseif daluditu[du] and daluditu[du] == 6 then mapmove(play, "六大陆主城",90,69,4) addhpper(play, '=', 100) addmpper(play, '=', 100)
        elseif daluditu[du] and daluditu[du] == 7 then
            -- 世界符文总奖励是第七大陆通行的统一门槛。
            if not Player.ensureSeventhContinentPass(play, "请先满足七大陆进入条件后再前往七大陆#57") then
                return
            end
            mapmove(play, "七大陆主城",92,76,5)
            addhpper(play, '=', 100)
            addmpper(play, '=', 100)
        elseif daluditu[du] and daluditu[du] == 8 then mapmove(play, "八大陆主城",92,76,5) addhpper(play, '=', 100) addmpper(play, '=', 100)
        elseif daluditu[du] and daluditu[du] == 9 then mapmove(play, "九大陆主城",92,76,5) addhpper(play, '=', 100) addmpper(play, '=', 100)
        else
            mapmove(play, 'xtc', 137,138,8)
            addhpper(play, '=', 100)
            addmpper(play, '=', 100)
        end
    else
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>战斗状态无法使用...</font>","Type":9}')
    end
    return false
end
local function _get_use_all_info(play, item)
    local itemName = getiteminfo(play, item, ConstCfg.iteminfo.name)
    local sl = 0
    if itemName and itemName ~= "" then
        sl = getbagitemcount(play, itemName)
    end
    if sl < 1 then
        sl = getiteminfo(play, item, 5)
    end
    return sl, itemName
end
local function _take_use_all_item(play, item, sl, itemName)
    if sl < 1 then
        return false
    end
    if itemName and itemName ~= "" then
        takeitem(play, itemName, sl)
    else
        delitembymakeindex(play, getiteminfo(play, item, 1), sl)
    end
end
function stdmodefunc12(play, item)
    local sl, itemName = _get_use_all_info(play, item)
    if sl < 1 then
        return false
    end
    if not Player.canGainRoleLevel(play, string.format("当前等级已达#57|【%d级】#218|，经验丹无法继续使用#57", Player.getRoleLevelCap())) then
        return false
    end
    local wpid = getiteminfo(play, item, 2)
    local wpjg = getstditeminfo(wpid, 8)
    local useCount = 0
    for i = 1, sl do
        if not Player.canGainRoleLevel(play, false) then
            break
        end
        changeexp(play, '+', wpjg, false)
        Player.clampRoleLevel(play, false)
        useCount = useCount + 1
    end
    if useCount <= 0 then
        return false
    end
    _take_use_all_item(play, item, useCount, itemName)
end
--------------------双击物品触发-------------------红名清洗卷
function stdmodefunc20(play, item)
    local sl, itemName = _get_use_all_info(play, item)
    if sl < 1 then
        return false
    end
    local pk = getbaseinfo(play,46) - 100 * sl
    if pk < 0 then
        pk = 0
    end
    setbaseinfo(play,46,pk)
    sendmsg(play,1,'{"Msg":"pk值下降100了...","FColor":219,"BColor":255,"Type":1}')
    sendmsg(play,1,'{"Msg":"剩余'..getbaseinfo(play,46)..'...","FColor":219,"BColor":255,"Type":1}')
    _take_use_all_item(play, item, sl, itemName)
end
--------------------双击物品触发-------------------灵石通用
function stdmodefunc21(play, item)
    local sl, itemName = _get_use_all_info(play, item)
    if sl < 1 then
        return false
    end
    local wpid = getiteminfo(play, item, 2)
    local wpjg = getstditeminfo(wpid, 8)
    changemoney(play, getflagstatus(play,VarCfg.BS_mztq) == 1 and 7 or 8, '+', wpjg * sl, '双击获得', true)
    _take_use_all_item(play, item, sl, itemName)
end
--------------------双击物品触发-------------------元宝通用
function stdmodefunc11(play, item)
    local sl, itemName = _get_use_all_info(play, item)
    if sl < 1 then
        return false
    end
    changemoney(play, getflagstatus(play,VarCfg.BS_mztq) == 1 and 2 or 4, '+', getstditeminfo(getiteminfo(play, item, 2), 8) * sl, '双击获得', true)
    _take_use_all_item(play, item, sl, itemName)
end
--------------------双击物品触发-------------------元宝通用
function stdmodefunc18(play, item)
    local sl, itemName = _get_use_all_info(play, item)
    if sl < 1 then
        return false
    end
    changemoney(play, getflagstatus(play,VarCfg.BS_mztq) == 1 and 1 or 3, '+', getstditeminfo(getiteminfo(play, item, 2), 8) * sl, '双击获得', true)
    _take_use_all_item(play, item, sl, itemName)
end
--------------------双击物品触发-------------------元宝红包
local itme_13 = {
    ["金币(小)"] = {100,1000},
    ["金币(中)"] = {1000,10000},
    ["金币(大)"] = {10000,100000},
    ["金币(超级)"] = {100000,1000000},
}
function stdmodefunc13(play, item)
    local sl, itemName = _get_use_all_info(play, item)
    -- release_print(itemName)
    if sl < 1 then
        return false
    end
    local min = itme_13[itemName][1]
    local max = itme_13[itemName][2]
    local num = 0
    for i = 1, sl do
        num = num + math.random(min, max)
    end
    changemoney(play, getflagstatus(play,VarCfg.BS_mztq) == 1 and 1 or 3, '+', num, '双击获得元宝红包', true)
    _take_use_all_item(play, item, sl, itemName)
end
--------------------双击物品触发-------------------元宝红包
local itme_14 = {
    ["元宝红包(小)"] = {10,20},
    ["元宝红包(中)"] = {30,50},
    ["元宝红包(大)"] = {100,200},
}
function stdmodefunc14(play, item)
    local sl, itemName = _get_use_all_info(play, item)
    if sl < 1 then
        return false
    end
    local min = itme_14[itemName][1]
    local max = itme_14[itemName][2]
    local num = 0
    for i = 1, sl do
        num = num + math.random(min, max)
    end
    changemoney(play, getflagstatus(play,VarCfg.BS_mztq) == 1 and 2 or 4, '+', num, '双击获得元宝红包', true)
    _take_use_all_item(play, item, sl, itemName)
end
function stdmodefunc48(play, item) -- 真实充值卷
    local sl, itemName = _get_use_all_info(play, item)
    if sl < 1 then
        return false
    end
    local wpid = getiteminfo(play,item,2)
    local wpjg = getstditeminfo(wpid,8)
    changemoney(play,23,"+",wpjg*sl,"真实充值卷",true)
    changemoney(play,8,"+",wpjg*10*sl,"真实充值卷",true)
    --changemoney(play,23,"+",wpjg*sl,"真实充值卷",true)  --累计充值
    --sendmsg(play, 1, '{"Msg":"真实充值增加:'..wpjg*sl..'","FColor":253,"BColor":255,"Type":1}')
    _take_use_all_item(play, item, sl, itemName)
    --release_print(getiteminfo(play,item,2))
end
---千里传音
function stdmodefunc234(play) ---千里传音 提示：使用50级
    if checkkuafu(play) then
        stop(play)
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>跨服不能使用该物品</font>","Type":9}')
        return false
    end
    stop(play)
    if getbaseinfo(play,6) < 60 then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>使用千里传音需要达到60级！</font>","Type":9}')
        return false
    end
    say(play, "<发送/@@InputString23(请输入传音内容：)>\\")
end
function inputstring23(play) ---
    if getbaseinfo(play,6) < 60 then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>使用千里传音需要达到60级！</font>","Type":9}')
        return false
    end
    local text = getplaydef(play, "S23")
    local name_len = string.len(text)
    if name_len < 1 then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>请输入内容</font>","Type":9}')
        return false
    end
    if name_len > 100 then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>内容过长</font>","Type":9}')
        return false
    end
    if getbagitemcount(play, "千里传音") < 1 then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>千里传音不足</font>","Type":9}')
        return false
    end
    local result, name = exisitssensitiveword(text)
    if result then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>内容包含敏感词</font>","Type":9}')
        return false
    end
    takeitem(play, "千里传音", 1)
    FsendQfPz(play, "【千里传音】" .. getbaseinfo(play, 1) .. "：" .. text, 1)
end
function FsendQfPz(actor,str,count)
    for i = 1, count, 1 do
        sendmsg(actor, 2, '{"Msg":"'..str..'","FColor":250,"BColor":0,"Y":'..(90+i*30)..',"Type":5}')
    end
end
---千里传音 --end
function stdmodefunc30(play, item)
    local sl, itemName = _get_use_all_info(play, item)
    if sl < 1 then
        return false
    end
    local exp = tonumber(getplaydef(play, VarCfg["U_境界修炼"][2]) or 0) or 0
    local maxExp = 10000000
    if exp >= maxExp then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>境界修炼已满级</font>","Type":9}')
        return false
    end
    local addOne = tonumber(getstditeminfo(getiteminfo(play, item, 2), 8) or 0) or 0
    if addOne <= 0 then
        return false
    end
    local useCount = math.min(sl, math.ceil((maxExp - exp) / addOne))
    local addTotal = math.min(maxExp - exp, addOne * useCount)
    setplaydef(play, VarCfg["U_境界修炼"][2], exp + addTotal)
    _take_use_all_item(play, item, useCount, itemName)
    sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>境界修炼【修为】+'..addTotal..'</font>","Type":9}')
    return false
end
function stdmodefunc31(play, item)
    local sl, itemName = _get_use_all_info(play, item)
    if sl < 1 then
        return false
    end
    local addOne = tonumber(getstditeminfo(getiteminfo(play, item, 2), 8) or 0) or 0
    if addOne <= 0 then
        return false
    end
    local addTotal = addOne * sl
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_天书"])
    T_data.jf = (tonumber(T_data.jf or 0) or 0) + addTotal
    Player.setJsonVarByTable(play, VarCfg["T_天书"], T_data)
    local itemobj = linkbodyitem(play, teshudata["npc_24"].where)
    if itemobj and itemobj ~= "0" then
        setcustomitemprogressbar(play, itemobj, 1, tbl2json({["cur"] = T_data.jf}))
        refreshitem(play, itemobj)
    end
    _take_use_all_item(play, item, sl, itemName)
    sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>天书杀意值+'..addTotal..'</font>","Type":9}')
    return false
end
-- 仙府丹药统一使用到期时间驱动；同类丹药只延长持续时间，不重复叠加效果。
local function _xianfu_dan_set_expire(play, varName, seconds)
    seconds = tonumber(seconds or 0) or 0
    if seconds <= 0 then
        setplaydef(play, varName, 0)
        return 0
    end
    local now = os.time()
    local currentExpire = tonumber(getplaydef(play, varName) or 0) or 0
    local startAt = currentExpire > now and currentExpire or now
    local expireAt = startAt + seconds
    setplaydef(play, varName, expireAt)
    return expireAt
end

local function _xianfu_dan_left(play, varName)
    local expireAt = tonumber(getplaydef(play, varName) or 0) or 0
    local left = expireAt - os.time()
    return left > 0 and left or 0
end

local function _xianfu_dan_is_active(play, varName)
    return _xianfu_dan_left(play, varName) > 0
end

local function _xianfu_dan_format_left(seconds)
    seconds = tonumber(seconds or 0) or 0
    if seconds <= 0 then
        return "0秒"
    end
    local minute = math.floor(seconds / 60)
    local sec = seconds % 60
    if minute <= 0 then
        return tostring(sec) .. "秒"
    end
    if sec <= 0 then
        return tostring(minute) .. "分钟"
    end
    return string.format("%d分%d秒", minute, sec)
end

local function _godstone_pick_quality_config(boxName)
    local cfg = teshudata["npc_53"] or {}
    local cost = cfg.cost or {}
    local openRate = cfg.open_rate or {}
    if boxName == "神石宝箱[史诗级]" then
        return {
            title = "史诗",
            list = cost[2] or {},
        }
    end
    if boxName == "神石宝箱[传说级]" then
        return {
            title = "传说",
            list = cost[3] or {},
        }
    end
    return {
        title = nil,
        pool = {
            {weight = tonumber(openRate.rare or 0) or 0, list = cost[1] or {}, title = "稀有"},
            {weight = tonumber(openRate.epic or 0) or 0, list = cost[2] or {}, title = "史诗"},
            {weight = tonumber(openRate.legendary or 0) or 0, list = cost[3] or {}, title = "传说"},
            {weight = tonumber(openRate.myth or 0) or 0, list = cost[4] or {}, title = "神话"},
        },
    }
end

local function _godstone_pick_reward(boxName)
    local qualityCfg = _godstone_pick_quality_config(boxName)
    if qualityCfg.list then
        if #qualityCfg.list <= 0 then
            return nil, qualityCfg.title
        end
        return qualityCfg.list[math.random(#qualityCfg.list)], qualityCfg.title
    end
    local pool = qualityCfg.pool or {}
    local totalWeight = 0
    for _, entry in ipairs(pool) do
        if entry.list and #entry.list > 0 and (tonumber(entry.weight or 0) or 0) > 0 then
            totalWeight = totalWeight + (tonumber(entry.weight or 0) or 0)
        end
    end
    if totalWeight <= 0 then
        return nil, nil
    end
    local roll = math.random(totalWeight)
    local acc = 0
    for _, entry in ipairs(pool) do
        local weight = tonumber(entry.weight or 0) or 0
        if entry.list and #entry.list > 0 and weight > 0 then
            acc = acc + weight
            if roll <= acc then
                return entry.list[math.random(#entry.list)], entry.title
            end
        end
    end
    local last = pool[#pool]
    if last and last.list and #last.list > 0 then
        return last.list[math.random(#last.list)], last.title
    end
    return nil, nil
end

local function _is_godstone_red_boss(mon)
    local mobName = tostring(getbaseinfo(mon, 1) or "")
    if mobName == "" then
        return false
    end
    return string.find(mobName, "★", 1, true) ~= nil
        or string.find(mobName, "≮", 1, true) ~= nil
        or string.find(mobName, "红", 1, true) ~= nil
end

local function _is_kuafu_boss(mon)
    local mapName = tostring(getbaseinfo(mon, 3) or "")
    if mapName == "" then
        return false
    end
    return string.find(mapName, "跨服", 1, true) ~= nil
        or string.find(mapName, "kuafu", 1, true) ~= nil
end

--[[
stdmodefunc32(play, item)
用途：神石宝箱双击使用入口，优先转发到 npc_53.openBoxByName，保证“背包双击开箱”和“NPC 界面开箱”走同一套概率、扣除和回包逻辑。
参数：
1. play：玩家对象。
2. item：当前双击使用的神石宝箱物品对象。
说明：
1. 若 npc_53 已加载，则直接调用统一开箱接口。
2. 若 npc_53 未加载，则继续走本地兜底开奖逻辑，避免物品失效。
]]
function stdmodefunc32(play, item) --神石召唤
    local boxName = tostring(getiteminfo(play, item, ConstCfg.iteminfo.name) or "神石宝箱")
    if Npclib and Npclib[53] and Npclib[53].openBoxByName then
        Npclib[53].openBoxByName(play, boxName)
        return false
    end
    local keyCost = {{"神石宝箱钥匙", 1}}
    local name, num = Player.checkItemNumByTable(play, keyCost)
    if name then
        Player.sendmsgEx(play, string.format("缺少|%s#218|数量|%d#218", name, num))
        return false
    end
    local rewardName, qualityTitle = _godstone_pick_reward(boxName)
    if not rewardName then
        Player.sendmsgEx(play, "神石宝箱开启失败：奖池为空#57")
        return false
    end
    Player.takeItemByTable(play, keyCost, ",神石宝箱开启", nil)
    delitembymakeindex(play, getiteminfo(play, item, 1), 1)
    giveitem(play, rewardName, 1)
    if Npclib and Npclib[53] and Npclib[53].markOwned then
        Npclib[53].markOwned(play, rewardName)
    end
    Player.sendmsgEx(play, string.format("开启|%s#218|成功，获得#57|【%s】#218|%s#57", boxName, rewardName, qualityTitle and ("（" .. qualityTitle .. "）") or ""))
    return false
end
function stdmodefunc33(play, item) --灵兽圣遗物自选礼盒
end
function stdmodefunc34(play, item) --随机盲盒
end
function stdmodefunc35(play, item) --藏宝图
    -- release_print("藏宝图物品使用逻辑待实现")
    local name = getiteminfo(play, item, 8)
    local map_info = string.match(name or "", "%[(.-)%]")
    if not map_info then
        release_print("藏宝图地图信息解析失败:", name or "")
        return false
    end
    local parts = split(map_info, ",")
    local map_name = parts[1]
    local map_x = tonumber(parts[2])
    local map_y = tonumber(parts[3])
    release_print("藏宝图地图信息:", map_name or "", map_x or 0, map_y or 0)
    if not map_name or not map_x or not map_y then
        release_print("藏宝图地图信息不完整:", map_info or "")
        return false
    end
    if getbaseinfo(play, 3) == map_name then
        if math.abs(getbaseinfo(play,4) - map_x) <= 1 and math.abs(getbaseinfo(play,5) - map_y) <= 1 then
            -- 触发挖宝逻辑
            release_print("触发挖宝逻辑")
            -- local name, num = Player.checkItemNumByTable(play, {{"铲子",1}})
            -- if name then
            --     Player.sendmsgEx(play, string.format("你的|%s#218|不足|%d#218", name, num))
            --     return false
            -- end
            local gw = genmonex(map_name,map_x,map_y,teshudata["npc_47"].details[getstditeminfo(getiteminfo(play, item, 2), 8)].mob_name,1,1,0,54,"",0)
            return true
        else
            Player.sendmsgEx(play, "当前位置不是藏宝图指定的坐标，无法使用！#218")
            return false
        end
    else
        Player.sendmsgEx(play, "当前地图不是藏宝图指定的地图，无法使用！#218")
        return false
    end
    -- changeitemname(play,-2,detail.item.."["..map.map_name..","..map.map_x..","..map.map_y.."]",itemobj)
end
function stdmodefunc36(play, item) --海盗宝箱  海盗眼罩  海盗眼罩 10%、90% 金币*1w  10抽必出也只能出一个海盗眼罩
    local rec = json2tbl(getplaydef(play, VarCfg["T_物品使用记录"]))
    if type(rec) ~= "table" then
        rec = {}
    end
    rec.box36_count = (rec.box36_count or 0) + 1
    local gotMask = rec.box36_mask == 1
    local giveMask = false
    if not gotMask then
        if (rec.box36_count % 10) == 0 then
            giveMask = true
        else
            giveMask = math.random(100) <= 10
        end
    end
    if giveMask then
        rec.box36_mask = 1
        giveitem(play, "海盗眼罩", 1)
        Player.sendmsgEx(play, "恭喜获得 海盗眼罩#57")
    else
        changemoney(play, getflagstatus(play,VarCfg.BS_mztq) == 1 and 1 or 3, "+", 10000, "海盗宝箱", true)
    end
    setplaydef(play, VarCfg["T_物品使用记录"], tbl2json(rec))
    delitembymakeindex(play, getiteminfo(play, item, 1), 1)
    return false
end
function stdmodefunc37(play, item) --船长的宝藏  开启随机获得以下奖励之一：金币88w、元宝8w、五行石*5
    local roll = math.random(3)
    if roll == 1 then
        changemoney(play, getflagstatus(play,VarCfg.BS_mztq) == 1 and 1 or 3, "+", 880000, "船长的宝藏", true)
    elseif roll == 2 then
        changemoney(play, getflagstatus(play,VarCfg.BS_mztq) == 1 and 2 or 4, "+", 80000, "船长的宝藏", true)
    else
        giveitem(play, "五行石", 5)
    end
    delitembymakeindex(play, getiteminfo(play, item, 1), 1)
    return false
end
function stdmodefunc38(play, item) --海贼王装备随机宝箱  路飞的草帽 索隆的佩刀 乌索普的弹弓 每个开一个不会重复
    local rec = json2tbl(getplaydef(play, VarCfg["T_物品使用记录"]))
    if type(rec) ~= "table" then
        rec = {}
    end
    rec.box38 = type(rec.box38) == "table" and rec.box38 or {}
    local pool = {"路飞的帽子", "索隆的刀", "乌索普的弹弓"}
    local missing = {}
    for _, name in ipairs(pool) do
        if not rec.box38[name] then
            table.insert(missing, name)
        end
    end
    if #missing == 0 then
        Player.sendmsgEx(play, "已获得全部海贼王装备，无法再开启#57")
        return false
    end
    local reward = missing[math.random(#missing)]
    giveitem(play, reward, 1)
    rec.box38[reward] = 1
    setplaydef(play, VarCfg["T_物品使用记录"], tbl2json(rec))
    delitembymakeindex(play, getiteminfo(play, item, 1), 1)
    return false
end
function stdmodefunc39(play, item) --特殊丹药
    local itemName = tostring(getiteminfo(play, item, ConstCfg.iteminfo.name) or "")
    if itemName == "稳固丹" then
        local expireAt = _xianfu_dan_set_expire(play, "N$xf_dan_low_expire", 30 * 60)
        delitembymakeindex(play, getiteminfo(play, item, 1), 1)
        Player.sendmsgEx(play, string.format("已服用#57|【稳固丹】#218|，持续至#57|【%s】#218|#57", os.date("%H:%M:%S", expireAt)))
        return false
    elseif itemName == "幸运丹" then
        local expireAt = _xianfu_dan_set_expire(play, "N$xf_dan_mid_expire", 30 * 60)
        Player.add_attlist(play, "仙府幸运丹", "=", Player.getAttrTableToStr({[246] = 1000, [245] = 500}), 1)
        delitembymakeindex(play, getiteminfo(play, item, 1), 1)
        Player.sendmsgEx(play, string.format("已服用#57|【幸运丹】#218|，持续至#57|【%s】#218|#57", os.date("%H:%M:%S", expireAt)))
        return false
    elseif itemName == "凝萃神丹" then
        local expireAt = _xianfu_dan_set_expire(play, "N$xf_dan_high_expire", 30 * 60)
        delitembymakeindex(play, getiteminfo(play, item, 1), 1)
        Player.sendmsgEx(play, string.format("已服用#57|【凝萃神丹】#218|，持续至#57|【%s】#218|#57", os.date("%H:%M:%S", expireAt)))
        return false
    end
    local idx = getstditeminfo(getiteminfo(play, item, 2), 8)
    if idx == 5 and Npclib and Npclib[76] and Npclib[76].use_dujie_dan then
        return Npclib[76].use_dujie_dan(play, item)
    end
end
local function _apply_dan40_attr(play, rec)
    if type(rec) ~= "table" then
        Player.del_attlist(play, "特殊丹药")
        return
    end
    local attrs = {}
    local v1 = rec["dan40_1"] or 0
    local v2 = rec["dan40_2"] or 0
    local v3 = rec["dan40_3"] or 0
    local v4 = rec["dan40_4"] or 0
    local v5 = rec["dan40_5"] or 0
    local v6 = rec["dan40_6"] or 0
    local v7 = rec["dan40_7"] or 0
    if v1 > 0 then attrs[4] = v1 end                  --攻击
    if v2 > 0 then attrs[36] = v2 end                 --防御
    if v3 > 0 then attrs[1] = v3 * 10 end             --生命
    if v4 > 0 then attrs[242] = v4 end                --打怪爆率
    if v5 > 0 then attrs[22] = v5 end                 --暴击伤害
    if v6 > 0 then
        attrs[200] = v6                               --对怪攻速
        attrs[201] = v6                               --对人攻速
    end
    if v7 > 0 then attrs[244] = v7 * 100 end          --切割
    if next(attrs) then
        local attrsstr = Player.getAttrTableToStr(attrs)
        Player.add_attlist(play, "特殊丹药", "=", attrsstr, 1)
    else
        Player.del_attlist(play, "特殊丹药")
    end
end
local function Login_dan40(play)
    local rec = json2tbl(getplaydef(play, VarCfg["T_物品使用记录"]))
    _apply_dan40_attr(play, rec)
    rec = type(rec) == "table" and rec or {}
    local jz_count = tonumber(rec.jz_dan_count or 0) or 0
    if jz_count > 0 then
        Player.add_attlist(play, "筑基丹", "=", "3#244#" .. tostring(jz_count * 1000) .. "|3#4#" .. tostring(jz_count * 50), 1)
    else
        Player.del_attlist(play, "筑基丹")
    end
    if Buff and Buff.refreshRechargeBlade then
        Buff.refreshRechargeBlade(play)
    else
        Player.del_attlist(play, "充值切割刀")
    end
    if _xianfu_dan_is_active(play, "N$xf_dan_mid_expire") then
        Player.add_attlist(play, "仙府幸运丹", "=", Player.getAttrTableToStr({[246] = 1000, [245] = 500}), 1)
    else
        Player.del_attlist(play, "仙府幸运丹")
    end
end
GameEvent.add(EventCfg.onLogin, Login_dan40, "Login_dan40")
local function _yybg45_get_rec(play)
    local rec = json2tbl(getplaydef(play, VarCfg["T_物品使用记录"]))
    if type(rec) ~= "table" then
        rec = {}
    end
    rec.yybg45_count = tonumber(rec.yybg45_count) or 0
    rec.yybg45_free_date = tostring(rec.yybg45_free_date or "")
    rec.yybg45_full = tonumber(rec.yybg45_full) or 0
    return rec
end
local function _yybg45_save_rec(play, rec)
    setplaydef(play, VarCfg["T_物品使用记录"], tbl2json(rec or {}))
end
local _yybg45_clear_temp
local function _yybg45_apply_full(play, rec)
    if tonumber((rec or {}).yybg45_full) >= 1 then
        _yybg45_clear_temp(play)
        if not hasbuff(play, 20123) then
            Player.addRoleLevel(play, 1, false)
            addbuff(play, 20123)
        end
    elseif hasbuff(play, 20123) then
        Player.addRoleLevel(play, 1, false)
        delbuff(play, 20123)
    end
end
local function _yybg45_login(play)
    _yybg45_apply_full(play, _yybg45_get_rec(play))
end
GameEvent.add(EventCfg.onLogin, _yybg45_login, "Login_yybg45")
_yybg45_clear_temp = function(play)
    for _, buffId in ipairs({20116, 20117, 20118, 20119, 20120, 20121, 20122}) do
        if hasbuff(play, buffId) then
            delbuff(play, buffId)
        end
    end
end
local function _yybg45_roll(totalCount)
    local pool = {
        {id = 20116, name = "幸运"},
        {id = 20118, name = "急速"},
        {id = 20121, name = "杀伐"},
        {id = 20117, name = "爆破"},
        {id = 20119, name = "体魄"},
        {id = 20122, name = "嗜血"},
    }
    if tonumber(totalCount) >= 30 then
        pool[#pool + 1] = {id = 20120, name = "猎杀"}
    end
    return pool[math.random(1, #pool)]
end
local function _yybg45_open_confirm(play, rec)
    setplaydef(play, "S$yybg45_confirm", "1")
    local today = os.date("%Y%m%d")
    local msg = "今日首次使用免费，确认后将随机获得1个BUFF"
    if tostring((rec or {}).yybg45_free_date or "") == today then
        msg = "本次使用将消耗200灵石，确认后才会扣除并随机获得1个BUFF"
    end
    messagebox(play, msg, "@yybg45confirm,1", "@exit")
end
local function _yybg45_do_use(play, rec)
    local reward = _yybg45_roll(rec.yybg45_count)
    addbuff(play, reward.id)
    rec.yybg45_count = rec.yybg45_count + 1
    local msg = "本次获得【" .. tostring(reward.name) .. "】，持续8小时；当前阴阳点数：【" .. tostring(rec.yybg45_count) .. "/66】"
    if rec.yybg45_count >= 66 then
        rec.yybg45_full = 1
        _yybg45_apply_full(play, rec)
        msg = msg .. "；已激活【圆满】"
    end
    _yybg45_save_rec(play, rec)
    messagebox(play, msg)
    return false
end
function yybg45confirm(play, code)
    if tostring(code) ~= "1" then
        return false
    end
    if getplaydef(play, "S$yybg45_confirm") ~= "1" then
        return false
    end
    setplaydef(play, "S$yybg45_confirm", "")
    local rec = _yybg45_get_rec(play)
    if rec.yybg45_full >= 1 then
        _yybg45_apply_full(play, rec)
        messagebox(play, "阴阳八卦境已圆满，无需重复使用")
        return false
    end
    local today = os.date("%Y%m%d")
    if rec.yybg45_free_date ~= today then
        rec.yybg45_free_date = today
        _yybg45_do_use(play, rec)
        return false
    end
    local cost = {{"灵石", 200}}
    local name, num = Player.checkItemNumByTable(play, cost)
    if name then
        messagebox(play, string.format("%s不足：%d", name, num))
        return false
    end
    Player.takeItemByTable(play, cost, ",阴阳八卦境", nil)
    _yybg45_do_use(play, rec)
    return false
end
function stdmodefunc40(play, item) --特殊丹药
    local idx = getstditeminfo(getiteminfo(play, item, 2), 8)
    local rec = json2tbl(getplaydef(play, VarCfg["T_物品使用记录"]))
    if type(rec) ~= "table" then
        rec = {}
    end
    local max_map = { [1]=1000, [2]=300, [3]=1000, [4]=100, [5]=10, [6]=10, [7]=1000 }
    local key = "dan40_" .. tostring(idx)
    local max = max_map[idx]
    if not max then
        return false
    end
    local cur = tonumber(rec[key] or 0) or 0
    if cur >= max then
        Player.sendmsgEx(play, "已达到该丹药使用上限#57")
        return true
    end
    local count_key = key .. "_count"
    -- 前4个丹药保留累计成长，最后3个丹药改为每次固定+1。
    local use_count = tonumber(rec[count_key] or cur) or 0
    local add_value = (idx >= 5 and idx <= 7) and 1 or (use_count + 1)
    if cur + add_value > max then
        add_value = max - cur
    end
    rec[key] = cur + add_value
    rec[count_key] = use_count + 1
    _apply_dan40_attr(play, rec)
    setplaydef(play, VarCfg["T_物品使用记录"], tbl2json(rec))
    delitembymakeindex(play, getiteminfo(play, item, 1), 1)
end
local function _msfc_get_box_pool(poolKey)
    local cfg = teshudata and teshudata["npc_101"] or {}
    local boxPool = cfg.box_pool or {}
    return boxPool[poolKey] or {}
end
local function _msfc_reward_label(reward)
    if not reward then
        return ""
    end
    if reward.label and reward.label ~= "" then
        return reward.label
    end
    if reward.give and reward.give[1] then
        return tostring(reward.give[1][1]) .. "*" .. tostring(reward.give[1][2] or 1)
    end
    return tostring(reward.name or "")
end
local function _msfc_box_code(poolKey, idx)
    local map = {low = 100, high = 200, super = 300, relic = 400}
    return (map[poolKey] or 0) + (tonumber(idx) or 0)
end
local function _msfc_parse_box_code(code)
    code = tonumber(code) or 0
    local poolKey = nil
    if code >= 400 then
        poolKey = "relic"
        code = code - 400
    elseif code >= 300 then
        poolKey = "super"
        code = code - 300
    elseif code >= 200 then
        poolKey = "high"
        code = code - 200
    elseif code >= 100 then
        poolKey = "low"
        code = code - 100
    end
    return poolKey, code
end
local function _msfc_open_box_say(play, boxName, poolKey)
    local pool = _msfc_get_box_pool(poolKey)
    if not pool or #pool < 1 then
        Player.sendmsgEx(play, "材料自选箱配置不存在#57")
        return false
    end
    local height = math.max(180, 92 + #pool * 30)
    local lines = {
        '<Img|id=ui_msfc_bg|x=0|y=0|width=332|height=' .. tostring(height) .. '|img=public/bg_npc_01.png|bg=1|esc=1|move=0|reset=1|show=0|scale9l=15|scale9r=15|scale9t=15|scale9b=15>',
        '<Layout|id=ui_msfc_close_area|x=329|y=3|width=30|height=40|link=@exit>',
        '<Button|id=ui_msfc_close|x=332|y=3|width=26|height=40|nimg=public/1900000510.png|pimg=public/1900000511.png|color=255|size=18|link=@exit>',
        '<Text|id=ui_msfc_title|x=27|y=23|color=251|size=18|text=' .. tostring(boxName) .. '：点击奖励直接领取>',
    }
    for i, reward in ipairs(pool) do
        local y = 60 + (i - 1) * 30
        lines[#lines + 1] = '<Text|id=ui_' .. tostring(i) .. '|x=45|y=' .. tostring(y) .. '|color=255|size=18|text=' .. _msfc_reward_label(reward) .. '|link=@msfcbox,' .. tostring(_msfc_box_code(poolKey, i)) .. '>'
    end
    lines[#lines + 1] = '</Img>'
    -- release_print("打开自选箱界面，奖励列表长度:", table.concat(lines, "\r\n"))
    say(play, table.concat(lines, "\r\n"))
end
local function _msfc_submit_box_choice(play, boxName, poolKey, choiceIdx)
    local pool = _msfc_get_box_pool(poolKey)
    local reward = tonumber(choiceIdx) and pool[tonumber(choiceIdx)] or nil
    if not reward then
        Player.sendmsgEx(play, "选择的奖励无效#57")
        return false
    end
    if getbagitemcount(play, boxName) < 1 then
        Player.sendmsgEx(play, tostring(boxName) .. "不足#57")
        return false
    end
    if reward.kind ~= "item" or type(reward.give) ~= "table" then
        Player.sendmsgEx(play, "该奖励暂不支持通过自选箱领取#57")
        return false
    end
    takeitem(play, boxName, 1)
    Player.rwjl(play, reward.give, tostring(boxName), 1)
    Player.sendmsgEx(play, "开启成功，获得|" .. _msfc_reward_label(reward) .. "#218")
end
function msfcbox(play, code)
    local poolKey, choiceIdx = _msfc_parse_box_code(code)
    local boxMap = {
        low = "低级材料自选箱",
        high = "高级材料自选箱",
        super = "特级材料自选箱",
        relic = "灵兽圣遗物自选礼盒",
    }
    local boxName = boxMap[poolKey]
    if not boxName or not choiceIdx or choiceIdx <= 0 then
        Player.sendmsgEx(play, "选择的奖励无效#57")
        return false
    end
    _msfc_submit_box_choice(play, boxName, poolKey, choiceIdx)
end
function stdmodefunc41(play, item) --仙法卷轴残页  -- 10合一  仙法卷轴
    local sl, itemName = _get_use_all_info(play, item)
    itemName = itemName or "仙法卷轴残页"
    local needNum = 10
    if sl < needNum then
        Player.sendmsgEx(play, itemName .. "不足" .. needNum .. "个#57")
        return false
    end
    local makeCount = math.floor(sl / needNum)
    _take_use_all_item(play, item, makeCount * needNum, itemName)
    Player.rwjl(play, {{"仙法卷轴", makeCount}}, "仙法卷轴残页合成", 1)
    Player.sendmsgEx(play, "合成成功，获得|仙法卷轴*" .. makeCount .. "#218")
    return false
end
function stdmodefunc42(play, item) --低级材料自选箱  --5选1材料
    _msfc_open_box_say(play, "低级材料自选箱", "low")
    return false
end
function stdmodefunc43(play, item) --高级材料自选箱  --5选1材料
    _msfc_open_box_say(play, "高级材料自选箱", "high")
    return false
end
function stdmodefunc44(play, item) --特级材料自选箱  --5选1材料
    _msfc_open_box_say(play, "特级材料自选箱", "super")
    return false
end
function stdmodefunc52(play, item) --灵兽圣遗物自选礼盒
    _msfc_open_box_say(play, "灵兽圣遗物自选礼盒", "relic")
    return false
end
function stdmodefunc45(play, item) --"背包道具（不可回收不可分解不可丢弃不可爆出）
-- 每天第一次免费使用，双击使用获得限时BUFF8小时（合理的话每天用2-3次）
-- 免费之后在次使用需消耗200灵石（用的时候系统弹框确认）
-- 1.幸运  打怪爆率+100% 4.爆破  暴击伤害+10% 7.轮回  人物等级+2级
-- 2.急速  攻击速度+10%   5.体魄  最大生命+10% 8.猎杀  打怪切割+66666
-- 3.杀伐  攻击伤害+10%   6.嗜血  最大攻击+10% 9.重生  复活次数+1
-- 每次使用后，可积攒1阴阳点数，阴阳点数达到66次后，以上属性全部永久激活"
-- 7和9永远都抽不到  只有在抽到66次阴阳点数后才会直接加上属性
-- 20116	阴阳八卦境：幸运
-- 20117	阴阳八卦境：爆破
-- 20118	阴阳八卦境：急速
-- 20119	阴阳八卦境：体魄
-- 20120	阴阳八卦境：猎杀
-- 20121	阴阳八卦境：杀伐
-- 20122	阴阳八卦境：嗜血
-- 20123	阴阳八卦境：圆满
    local rec = _yybg45_get_rec(play)
    if rec.yybg45_full >= 1 then
        _yybg45_apply_full(play, rec)
        messagebox(play, "阴阳八卦境已圆满，无需重复使用")
        return false
    end
    _yybg45_open_confirm(play, rec)
    return false
end
function stdmodefunc46(play, item) --等级卷轴  等级 + 1
    local sl, itemName = _get_use_all_info(play, item)
    if sl < 1 then
        return false
    end
    local useCount = 0
    for i = 1, sl do
        local ok = select(1, Player.addRoleLevel(play, 1, i == 1 and string.format("当前等级已达#57|【%d级】#218|，等级卷轴无法继续使用#57", Player.getRoleLevelCap()) or false))
        if not ok then
            break
        end
        useCount = useCount + 1
    end
    if useCount > 0 then
        _take_use_all_item(play, item, useCount, itemName)
        Player.sendmsgEx(play, "等级卷轴使用成功，等级提升#57|【" .. useCount .. "】#218|级#57")
    end
    return false
end
function stdmodefunc47(play, item) --天道·渡劫丹
    if not Npclib or not Npclib[76] or type(Npclib[76].use_dujie_dan) ~= "function" then
        Player.sendmsgEx(play, "天道试炼逻辑未加载#57")
        return false
    end
    return Npclib[76].use_dujie_dan(play, item)
end
function stdmodefunc51(play, item) --酒葫芦材料
    local equipLevel = Player.getEquipFieldByPos(play, 16, 1) or 0
    if equipLevel == 0 then
        Player.sendmsgEx(play,  "请先装备酒葫芦#57")
        return
    end
    local data = {}
    data["dj_data"] = Player.getJsonTableByVar(play, VarCfg["T_仙食坊"])
    sendluamsg(play,100,14,0,0,tbl2json(data))
    return false
end
-- 倩女幽魂召唤道具（预留）：仅副本中可用
-- 后续将对应道具 StdMode 指向 49 即可生效
function stdmodefunc49(play, item)
    local curMap = getbaseinfo(play, 3)
    local dtm = getplaydef(play, "S$npc702_map")
    if not dtm or dtm == "" or curMap ~= dtm then
        Player.sendmsgEx(play, "该道具仅可在倩女幽魂副本中使用#57")
        return false
    end
    if type(_G.npc_702_use_item) ~= "function" then
        Player.sendmsgEx(play, "倩女幽魂逻辑未加载#57")
        return false
    end
    return _G.npc_702_use_item(play, item)
end
-- 故人远行召唤道具（预留）：仅任务进行中并在指定坐标可用
-- 后续将“完好的酒壶”StdMode 指向 50 即可生效
function stdmodefunc50(play, item)
    if type(_G.npc_709_use_item) ~= "function" then
        Player.sendmsgEx(play, "故人远行逻辑未加载#57")
        return false
    end
    return _G.npc_709_use_item(play, item)
end
local function _refresh_1002_attr(play, T_data)
    local cfg1002 = teshudata and teshudata["npc_1002"]
    local details = cfg1002 and cfg1002.details or {}
    T_data = T_data or Player.getJsonTableByVar(play, VarCfg.T_szjl)
    T_data.yjs = T_data.yjs or {}
    T_data.yjszj = T_data.yjszj or {}
    local attrs = {}
    for idx, cfg in ipairs(details.sz or {}) do
        if T_data.yjs[tostring(idx)] == 1 then
            for _, attr in ipairs(cfg.attr or {}) do
                local attrId = tonumber(attr[1])
                local attrValue = tonumber(attr[2]) or 0
                if attrId and attrValue > 0 then
                    attrs[attrId] = (attrs[attrId] or 0) + attrValue
                end
            end
        end
    end
    for idx, cfg in ipairs(details.zj or {}) do
        if T_data.yjszj[tostring(idx)] == 1 then
            for _, attr in ipairs(cfg.attr or {}) do
                local attrId = tonumber(attr[1])
                local attrValue = tonumber(attr[2]) or 0
                if attrId and attrValue > 0 then
                    attrs[attrId] = (attrs[attrId] or 0) + attrValue
                end
            end
        end
    end
    local attrsstr = Player.getAttrTableToStr(attrs)
    if attrsstr and attrsstr ~= "" then
        Player.add_attlist(play, "时装属性", "=", attrsstr, 1)
    else
        Player.del_attlist(play, "时装属性")
    end
end
local function _use_1002_unlock(play, item, keyName, listName, label)
    local idx = tonumber(getstditeminfo(getiteminfo(play, item, 2), 8) or 0) or 0
    local cfg1002 = teshudata and teshudata["npc_1002"]
    local details = cfg1002 and cfg1002.details or {}
    local cfgList = details[listName] or {}
    if idx <= 0 or not cfgList[idx] then
        Player.sendmsgEx(play, label .. "序号不存在#57")
        return false
    end
    local T_data = Player.getJsonTableByVar(play, VarCfg.T_szjl)
    T_data[keyName] = T_data[keyName] or {}
    if T_data[keyName][tostring(idx)] == 1 then
        Player.sendmsgEx(play, "你已拥有该" .. label .. "，无需重复使用#57")
        return false
    end
    T_data[keyName][tostring(idx)] = 1
    Player.setJsonVarByTable(play, VarCfg.T_szjl, T_data)
    GameEvent.push(EventCfg.onUPSkin, play, idx)
    _refresh_1002_attr(play, T_data)
    delitembymakeindex(play, getiteminfo(play, item, 1), 1)
    Player.sendmsgEx(play, "恭喜你成功激活|【" .. (cfgList[idx].name or label) .. "】#218|")
    return false
end
function stdmodefunc53(play, item)  --使用时装  getstditeminfo(getiteminfo(play, item, 2), 8)  通过这个来获取对应的序号
    _use_1002_unlock(play, item, "yjs", "sz", "??")
end
function stdmodefunc54(play, item)  --使用足迹  getstditeminfo(getiteminfo(play, item, 2), 8)  通过这个来获取对应的序号
    _use_1002_unlock(play, item, "yjszj", "zj", "足迹")
end
function stdmodefunc55(play, item) --净化宝石
    addbuff(play, 20112)
    Player.sendmsgEx(play, "使用成功，已获得净化宝石效果#57")
    return false
end
function stdmodefunc56(play, item) --定身符
    addbuff(play, 20111)
    Player.sendmsgEx(play, "使用成功，已获得定身符效果#57")
    return false
end
local function _box57_pick_reward(pool)
    if type(pool) ~= "table" or #pool == 0 then
        return nil
    end
    local totalWeight = 0
    for _, cfg in ipairs(pool) do
        if type(cfg) == "table" then
            totalWeight = totalWeight + (tonumber(cfg.weight) or 1)
        else
            totalWeight = totalWeight + 1
        end
    end
    if totalWeight <= 0 then
        return nil
    end
    local roll = math.random(1, totalWeight)
    local acc = 0
    for _, cfg in ipairs(pool) do
        local weight = 1
        local reward = cfg
        if type(cfg) == "table" then
            weight = tonumber(cfg.weight) or 1
            reward = cfg.name
        end
        acc = acc + weight
        if reward and reward ~= "" and roll <= acc then
            return cfg
        end
    end
    return pool[#pool]
end
function stdmodefunc57(play, item) --大陆专属装备随机宝箱 getstditeminfo(getiteminfo(play, item, 2), 8)  通过这个来获取对应的大陆
    local dl = tonumber(getstditeminfo(getiteminfo(play, item, 2), 8) or 0) or 0
    local pool = constant and constant.dalu_zszb_box57 and constant.dalu_zszb_box57[dl]
    if dl <= 0 then
        Player.sendmsgEx(play, "大陆参数错误，无法开启#57")
        return false
    end
    if type(pool) ~= "table" or #pool == 0 then
        Player.sendmsgEx(play, "该大陆专属装备奖池未配置#57")
        return false
    end
    local rewardCfg = _box57_pick_reward(pool)
    if not rewardCfg then
        Player.sendmsgEx(play, "随机奖励失败，请检查奖池配置#57")
        return false
    end
    local rewardName = rewardCfg
    local rewardNum = 1
    local rewardBind = 0
    if type(rewardCfg) == "table" then
        rewardName = rewardCfg.name
        rewardNum = tonumber(rewardCfg.num) or 1
        rewardBind = tonumber(rewardCfg.bind) or 0
    end
    if not rewardName or rewardName == "" then
        Player.sendmsgEx(play, "随机奖励失败，奖励名称为空#57")
        return false
    end
    giveitem(play, rewardName, rewardNum, rewardBind)
    delitembymakeindex(play, getiteminfo(play, item, 1), 1)
    Player.sendmsgEx(play, "恭喜获得|【" .. rewardName .. "】#218|")
    return false
end
-- 消耗品入口：净业符直接走残魂商店真实编号逻辑。
function stdmodefunc58(play, item) --净业符
    local cfg = ((teshudata or {})["npc_83"] or {}).cleanse or {}
    local reduce = tonumber(cfg.reduce or 30) or 30
    local shopNpc = Npclib and Npclib[83] or nil
    if not shopNpc or type(shopNpc.reduce_fire) ~= "function" then
        Player.sendmsgEx(play, "残魂商店逻辑未加载#57")
        return false
    end
    local data = shopNpc.get_data and shopNpc.get_data(play) or {}
    local before = tonumber(data.fire or 0) or 0
    if before <= 0 then
        Player.sendmsgEx(play, "当前业火值为0，无需使用#57")
        return false
    end
    local after = shopNpc.reduce_fire(play, reduce) or 0
    delitembymakeindex(play, getiteminfo(play, item, 1), 1)
    Player.sendmsgEx(play, string.format("使用成功，业火值从#57|【%d】#218|降至#57|【%d】#218|", before, tonumber(after) or 0))
    return false
end
function stdmodefunc59(play, item) --至尊黑卡
    local rec = json2tbl(getplaydef(play, VarCfg["T_物品使用记录"]))
    if type(rec) ~= "table" then
        rec = {}
    end
    local today = os.date("%Y%m%d")
    if tostring(rec.zzhk_date or "") == today then
        Player.sendmsgEx(play, "至尊黑卡今日已使用过#57")
        return false
    end
    rec.zzhk_date = today
    setplaydef(play, VarCfg["T_物品使用记录"], tbl2json(rec))
    Player.rwjl(play, {{"绑定金币",300000},{"绑定元宝",3000},{"绑定灵石",60}}, "至尊黑卡", 1)
    Player.sendmsgEx(play, "至尊黑卡使用成功，今日奖励已发放#57")
    return false
end
function stdmodefunc60(play, item) --筑基丹碎片
    local sl, itemName = _get_use_all_info(play, item)
    itemName = itemName or "筑基丹碎片"
    local needNum = 10
    if sl < needNum then
        Player.sendmsgEx(play, itemName .. "不足" .. needNum .. "个#57")
        return false
    end
    local makeCount = math.floor(sl / needNum)
    _take_use_all_item(play, item, makeCount * needNum, itemName)
    giveitem(play, "筑基丹", makeCount)
    Player.sendmsgEx(play, "成功合成#57|【筑基丹*" .. makeCount .. "】#218|#57")
    return false
end
function stdmodefunc61(play, item) --筑基丹
    local rec = json2tbl(getplaydef(play, VarCfg["T_物品使用记录"]))
    if type(rec) ~= "table" then
        rec = {}
    end
    local cur = tonumber(rec.jz_dan_count or 0) or 0
    delitembymakeindex(play, getiteminfo(play, item, 1), 1)
    if cur >= 3 then
        Player.sendmsgEx(play, "筑基丹已达到计数上限，本次仅消耗物品，不再增加属性#57")
        return false
    end
    rec.jz_dan_count = cur + 1
    setplaydef(play, VarCfg["T_物品使用记录"], tbl2json(rec))
    Player.add_attlist(play, "筑基丹", "=", "3#244#" .. tostring((tonumber(rec.jz_dan_count) or 0) * 1000) .. "|3#4#" .. tostring((tonumber(rec.jz_dan_count) or 0) * 50), 1)
    Player.sendmsgEx(play, "筑基丹服用成功，当前已服用|" .. tostring(rec.jz_dan_count) .. "/3#218")
    return false
end
function stdmodefunc62(play, item) --神石碎片
    local sl, itemName = _get_use_all_info(play, item)
    itemName = itemName or "神石碎片"
    local needNum = 88
    if sl < needNum then
        Player.sendmsgEx(play, itemName .. "不足" .. needNum .. "个#57")
        return false
    end
    local makeCount = math.floor(sl / needNum)
    _take_use_all_item(play, item, makeCount * needNum, itemName)
    giveitem(play, "神石宝箱", makeCount)
    Player.sendmsgEx(play, "成功合成#57|【神石宝箱*" .. makeCount .. "】#218|#57")
    return false
end

function stdmodefunc63(play, item) --仙酒：使用后增加醉意值
    local itemName = tostring(getiteminfo(play, item, ConstCfg.iteminfo.name) or "")
    local cfg = Guard.getConfig("npc_70") or {}
    local addzuiyi = 0
    for _, detail in ipairs(cfg.details or {}) do
        local reward = detail.cost and detail.cost[1]
        if reward and tostring(reward[1] or "") == itemName then
            addzuiyi = tonumber(detail.num or 0) or 0
            break
        end
    end
    if addzuiyi <= 0 then
        Player.sendmsgEx(play, "该酒水配置异常，无法使用#57")
        return false
    end
    local maxZuiyi = tonumber(cfg.max_zuiyi or 100) or 100
    local cur = tonumber(getplaydef(play, VarCfg["J_醉意值"]) or 0) or 0
    if cur >= maxZuiyi then
        Player.sendmsgEx(play, string.format("你的醉意值已达上限#57|【%d】#218|，无法继续饮用酒水#57", maxZuiyi))
        return false
    end
    local newValue = math.min(maxZuiyi, cur + addzuiyi)
    local realAdd = newValue - cur
    delitembymakeindex(play, getiteminfo(play, item, 1), 1)
    setplaydef(play, VarCfg["J_醉意值"], newValue)
    Player.sendmsgEx(play, string.format("你饮用了|【%s】#218|，醉意值增加了|【%d】#218|，当前醉意值为|【%d】#218", itemName, realAdd, newValue))
    -- sendluamsg(play,100,70,1,0,tbl2json({num = newValue}))
    return false
end
-- 沙巴克攻防药剂入口。
-- 参数说明：
-- play: 使用药剂的玩家对象。
-- item: 双击使用的物品对象。
-- itemName: 物品名称，用于区分“沙城征服者秘药 / 沙城霸主秘药 / 沙城勇士药剂”等具体效果。
-- 返回值：true 表示已处理并消耗道具；false 表示未处理或配置缺失。
local SBK_POTION_EFFECT_HANDLERS = {
    ["沙城征服者秘药"] = function(play, item, itemName)
        -- TODO: 在这里补“沙城征服者秘药”的实际效果逻辑。
        return true
    end,
    ["沙城霸主秘药"] = function(play, item, itemName)
        -- TODO: 在这里补“沙城霸主秘药”的实际效果逻辑。
        return true
    end,
    ["沙城勇士药剂"] = function(play, item, itemName)
        -- TODO: 在这里补“沙城勇士药剂”的实际效果逻辑。
        return true
    end,
}


local MIJING_TITLE_USE_ITEMS = {
    ["极光使者"] = "极光使者",
    ["白云苍狗"] = "白云苍狗",
    ["上善若水"] = "上善若水",
    ["看破红尘"] = "看破红尘",
    ["归入灵虚"] = "归入灵虚",
}
function stdmodefunc65(play, item) --沙巴克攻防药剂
    local itemName = tostring(getiteminfo(play, item, ConstCfg.iteminfo.name) or "")
    if itemName == "" then
        Player.sendmsgEx(play, "沙城药剂名称异常，无法使用#57")
        return false
    end

    local handler = SBK_POTION_EFFECT_HANDLERS[itemName]
    if type(handler) ~= "function" then
        Player.sendmsgEx(play, "该沙城药剂暂未配置使用效果#57")
        return false
    end
    local ok, result = pcall(handler, play, item, itemName)
    if not ok then
        release_print("[stdmodefunc65] 沙城药剂使用错误", itemName, result)
        Player.sendmsgEx(play, "沙城药剂使用失败，请检查配置#57")
        return false
    end
    if result == false then
        return false
    end
    delitembymakeindex(play, getiteminfo(play, item, 1), 1)
    Player.sendmsgEx(play, "使用成功：|【" .. itemName .. "】#218|#57")
    return false
end
function stdmodefunc66(play, item) --秘境称号道具
    local itemName = tostring(getiteminfo(play, item, ConstCfg.iteminfo.name) or "")
    if itemName == "" then
        Player.sendmsgEx(play, "秘境称号道具名称异常，无法使用#57")
        return false
    end
    local titleKey = string.gsub(itemName, "%[可使用%]", "")
    local titleName = MIJING_TITLE_USE_ITEMS[titleKey]
    if not titleName then
        Player.sendmsgEx(play, "该秘境称号道具暂未配置使用效果#57")
        return false
    end
    if checktitle(play, titleName) then
        Player.sendmsgEx(play, "你已经拥有|【" .. titleName .. "】#218|称号#57")
        return false
    end
    Player.title_give(play, titleName)
    delitembymakeindex(play, getiteminfo(play, item, 1), 1)
    Player.sendmsgEx(play, "恭喜你获得|【" .. titleName .. "】#218|称号#57")
    return false
end
function stdmodefunc64(play, item) --改名卡
    local itemName = tostring(getiteminfo(play, item, ConstCfg.iteminfo.name) or "改名卡")
    if itemName == "" then
        itemName = "改名卡"
    end
    if getbagitemcount(play, itemName) < 1 then
        Player.sendmsgEx(play, itemName .. "不足#57")
        return false
    end
    if tonumber(getplaydef(play, "N$改名卡处理中") or 0) == 1 then
        Player.sendmsgEx(play, "正在处理改名请求，请稍后#57")
        return false
    end
    setplaydef(play, "S$改名卡道具", itemName)
    say(play, "<确认改名/@@InputString68(请输入新的角色名称：)>\\")
    return false
end

local function _rename_card_submit(play, inputText, inputVar)
    local newName = tostring(inputText or "")
    if newName == "" and inputVar and inputVar ~= "" then
        newName = tostring(getplaydef(play, inputVar) or "")
    end
    if newName == "" then
        newName = tostring(getconst(play, "<$NPCPARAMS(1,S68)>") or "")
    end
    if newName == "" then
        newName = tostring(getplaydef(play, "S68") or getplaydef(play, "S64") or "")
    end
    if newName == "" then
        Player.sendmsgEx(play, "请输入新的角色名称#57")
        return false
    end
    if tonumber(getplaydef(play, "N$改名卡处理中") or 0) == 1 then
        Player.sendmsgEx(play, "正在处理改名请求，请稍后#57")
        return false
    end
    local itemName = tostring(getplaydef(play, "S$改名卡道具") or "改名卡")
    if itemName == "" then
        itemName = "改名卡"
    end
    if getbagitemcount(play, itemName) < 1 then
        Player.sendmsgEx(play, itemName .. "不足#57")
        return false
    end
    takeitem(play, itemName, 1)
    setplaydef(play, "N$改名卡处理中", 1)
    setplaydef(play, "S$改名卡道具", itemName)
    setplaydef(play, "S$改名卡目标名称", newName)
    changehumname(play, newName)
    return false
end


function inputstring68(play, inputText)
    return _rename_card_submit(play, inputText, "S68")
end

function inputstring64(play, inputText)
    return _rename_card_submit(play, inputText, "S64")
end
local function _get_zhuji_dan_record(play)
    local rec = json2tbl(getplaydef(play, VarCfg["T_物品使用记录"]))
    if type(rec) ~= "table" then
        rec = {}
    end
    return rec
end

