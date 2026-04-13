release_print("useitme.lua")
--------------------双击物品触发-------------------随机石
function stdmodefunc9(play, item)
    setplaydef(play,"S$dtm",getbaseinfo(play, 3))
    release_print("随机石")
    if getplaydef(play,"N$战斗状态") < os.time() or _has_equip_name(play, "遮云日") then
        map(play,getbaseinfo(play,3))
        -- if getflagstatus(play, 300) == 1 then
        --     startautoattack(play)
        -- end
    else
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>战斗状态无法使用...</font>","Type":9}')
    end
    return false
end
--------------------双击物品触发-------------------回城石
-- 灰界系列地图是否需要回到【灰界】统一通过 xilieditu 映射判断，避免这里再维护一份重复地图表。
local function _is_huijie_return_map(map_name)
    return type(xilieditu) == "table" and xilieditu[map_name] == 3
end

    
function stdmodefunc10(play, item)

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
        elseif daluditu[du] and daluditu[du] == 7 then mapmove(play, "七大陆主城",92,76,5) addhpper(play, '=', 100) addmpper(play, '=', 100)
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
    local wpid = getiteminfo(play, item, 2)
    local wpjg = getstditeminfo(wpid, 8)
    changeexp(play, '+', wpjg * sl, false)
    _take_use_all_item(play, item, sl, itemName)
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
    local exp = getplaydef(play, VarCfg["U_境界修炼"][2])
    if exp >= 10000000 then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>境界修炼已满级</font>","Type":9}')
        return false
    end
    exp = exp + getstditeminfo(getiteminfo(play, item, 2), 8)
    if exp > 10000000 then exp = 10000000 end
    setplaydef(play, VarCfg["U_境界修炼"][2], exp)
    sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>境界修炼经验+'..getstditeminfo(getiteminfo(play, item, 2), 8)..'</font>","Type":9}')
end

function stdmodefunc31(play, item)
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_天书"])
    T_data.jf = (T_data.jf or 0) + getstditeminfo(getiteminfo(play, item, 2), 8)
    Player.setJsonVarByTable(play, VarCfg["T_天书"], T_data)

    local itemobj = linkbodyitem(play, teshudata["npc_24"].where)
    setcustomitemprogressbar(play, itemobj, 1, tbl2json({["cur"] = T_data.jf}))
    refreshitem(play, itemobj)
    sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>天书杀意值+'..getstditeminfo(getiteminfo(play, item, 2), 8)..'</font>","Type":9}')
end




function stdmodefunc32(play, item) --神石召唤
    local config = teshudata["npc_53"]
    if not config or type(config.cost) ~= "table" then
        Player.sendmsgEx(play,"神石召唤失败:缺少配置#57")
        return false
    end

    local keyCost = {{"神石宝箱钥匙",1}}
    local name, num = Player.checkItemNumByTable(play, keyCost)
    if name then
        Player.sendmsgEx(play, string.format("缺少|%s#249|数量|%d#249", name, num))
        return false
    end
    Player.takeItemByTable(play, keyCost, ",神石召唤",nil)

    local rarityPool = {
        {weight = 7600, list = config.cost[1], tip = "稀有"},
        {weight = 1800, list = config.cost[2], tip = "史诗"},
        {weight = 500, list = config.cost[3], tip = "神话"},
        {weight = 100, list = config.cost[4], tip = "传说"},
    }
    local rand = math.random(1,10000)
    local acc = 0
    local target
    for _, entry in ipairs(rarityPool) do
        if entry.list and #entry.list > 0 and entry.weight > 0 then
            acc = acc + entry.weight
            if rand <= acc then
                target = entry
                break
            end
        end
    end
    if not target then
        target = rarityPool[#rarityPool]
    end
    if not target or not target.list or #target.list == 0 then
        Player.sendmsgEx(play,"神石召唤失败:奖池为空#57")
        return false
    end

    local rewardName = target.list[math.random(#target.list)]
    if not rewardName then
        Player.sendmsgEx(play,"神石召唤失败:奖品不存在#57")
        return false
    end

    giveitem(play, rewardName, 1)
    Player.sendmsgEx(play, string.format("神石召唤#250|稀有度:%s#249|获得:%s#218", target.tip or "", rewardName))
end

function stdmodefunc33(play, item) --灵兽圣遗物自选礼盒
    
end
function stdmodefunc34(play, item) --砍树盲盒 
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
            local name, num = Player.checkItemNumByTable(play, {{"铲子",1}})
            if name then
                Player.sendmsgEx(play, string.format("你的|%s#249|不足|%d#249", name, num))
                return false
            end
            local gw = genmonex(map_name,map_x,map_y,teshudata["npc_47"].details[getstditeminfo(getiteminfo(play, item, 2), 8)].mob_name,1,1,0,54,"",0)
            
            return true
        else
            Player.sendmsgEx(play, "当前位置不是藏宝图指定的坐标，无法使用！#249")
            return false
        end
    else
        Player.sendmsgEx(play, "当前地图不是藏宝图指定的地图，无法使用！#249")
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
    local idx = getstditeminfo(getiteminfo(play, item, 2), 8)
    if idx == 1 then
        addbuff(play, 20110)
    elseif idx == 2 then
        addbuff(play, 20111)
    elseif idx == 3 then
        addbuff(play, 20112)
    elseif idx == 4 then
        addbuff(play, 20113)
    elseif idx == 5 and Npclib and Npclib[76] and Npclib[76].use_dujie_dan then
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
            callscriptex(play, "CHANGELEVEL", "+", 1)
            addbuff(play, 20123)
        end
    elseif hasbuff(play, 20123) then
        callscriptex(play, "CHANGELEVEL", "+", 1)
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
    -- 兼容旧数据：以前每次固定+1，老数据里的总值可直接当作已服用次数。
    local use_count = tonumber(rec[count_key] or cur) or 0
    local add_value = use_count + 1
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
    Player.sendmsgEx(play, "开启成功，获得|" .. _msfc_reward_label(reward) .. "#249")
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
    local itemName = getiteminfo(play, item, ConstCfg.iteminfo.name) or "仙法卷轴残页"
    if getbagitemcount(play, itemName) < 10 then
        Player.sendmsgEx(play, itemName .. "不足10个#57")
        return false
    end
    takeitem(play, itemName, 10)
    Player.rwjl(play, {{"仙法卷轴",1}}, "仙法卷轴残页合成", 1)
    Player.sendmsgEx(play, "合成成功，获得|仙法卷轴*1#249")
    return false
end
function stdmodefunc42(play, item) --低级材料自选箱  --5个基础材料  
    _msfc_open_box_say(play, "低级材料自选箱", "low")
    return false

end
function stdmodefunc43(play, item) --高级材料自选箱  --5个基础材料  
    _msfc_open_box_say(play, "高级材料自选箱", "high")
    return false

end
function stdmodefunc44(play, item) --特级材料自选箱  --5个基础材料  
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
    callscriptex(play, "CHANGELEVEL", "+", 1)
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
    Player.sendmsgEx(play, "恭喜你成功激活|【" .. (cfgList[idx].name or label) .. "】#249|")
    return false
end

function stdmodefunc53(play, item)  --使用时装  getstditeminfo(getiteminfo(play, item, 2), 8)  通过这个来获取对应的序号
    _use_1002_unlock(play, item, "yjs", "sz", "时装")
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
    Player.sendmsgEx(play, "恭喜获得|【" .. rewardName .. "】#249|")
    return false
end






