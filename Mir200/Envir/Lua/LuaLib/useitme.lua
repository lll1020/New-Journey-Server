release_print("useitme.lua")
--------------------双击物品触发-------------------随机石
function stdmodefunc9(play, item)
    setplaydef(play,"S$dtm",getbaseinfo(play, 3))
    if getplaydef(play,"N$战斗状态") < os.time() then
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
        elseif daluditu[du] and daluditu[du] == 3 then mapmove(play, "三大陆主城",159,231,5) addhpper(play, '=', 100) addmpper(play, '=', 100)
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
--------------------双击物品触发-------------------经验通用
function stdmodefunc12(play, item)
    changeexp(play, '+', getstditeminfo(getiteminfo(play, item, 2), 8), false)
end
--------------------双击物品触发-------------------红名清洗卷
function stdmodefunc20(play, item)
    setbaseinfo(play,46,getbaseinfo(play,46)-100)
    sendmsg(play,1,'{"Msg":"pk值下降100了...","FColor":219,"BColor":255,"Type":1}')
    sendmsg(play,1,'{"Msg":"剩余'..getbaseinfo(play,46)..'...","FColor":219,"BColor":255,"Type":1}')
end
--------------------双击物品触发-------------------灵石通用
function stdmodefunc21(play, item)
    changemoney(play, getflagstatus(play,VarCfg.BS_mztq) == 1 and 7 or 8, '+', getstditeminfo(getiteminfo(play, item, 2), 8), '双击获得', true)
end

--------------------双击物品触发-------------------元宝通用
function stdmodefunc11(play, item)
    local sl = getiteminfo(play, item, 5)
    changemoney(play, getflagstatus(play,VarCfg.BS_mztq) == 1 and 2 or 4, '+', getstditeminfo(getiteminfo(play, item, 2), 8) * sl, '双击获得', true)
    delitembymakeindex(play, getiteminfo(play, item, 1), sl)
end
--------------------双击物品触发-------------------元宝通用
function stdmodefunc18(play, item)
    local sl = getiteminfo(play, item, 5)
    changemoney(play, getflagstatus(play,VarCfg.BS_mztq) == 1 and 1 or 3, '+', getstditeminfo(getiteminfo(play, item, 2), 8) * sl, '双击获得', true)
    delitembymakeindex(play, getiteminfo(play, item, 1), sl)
end

--------------------双击物品触发-------------------元宝红包
local itme_13 = {
    ["元宝(小)"] = {100,1000},
    ["元宝(中)"] = {1000,10000},
    ["元宝(大)"] = {10000,100000},
    ["元宝(超级)"] = {100000,1000000},
}
function stdmodefunc13(play, item)
    local itemName = getiteminfo(actor, item, ConstCfg.iteminfo.name)
    local min = itme_13[itemName][1]
    local max = itme_13[itemName][2]
    local num = math.random(min, max)
    changemoney(play, getflagstatus(play,VarCfg.BS_mztq) == 1 and 1 or 3, '+', num, '双击获得元宝红包', true)
    delitembymakeindex(play, getiteminfo(play, item, 1), 1)
end

--------------------双击物品触发-------------------元宝红包
local itme_14 = {
    ["元宝红包(小)"] = {10,20},
    ["元宝红包(中)"] = {30,50},
    ["元宝红包(大)"] = {100,200},
}
function stdmodefunc14(play, item)
    local itemName = getiteminfo(actor, item, ConstCfg.iteminfo.name)
    local min = itme_14[itemName][1]
    local max = itme_14[itemName][2]
    local num = math.random(min, max)
    changemoney(play, getflagstatus(play,VarCfg.BS_mztq) == 1 and 2 or 4, '+', num, '双击获得元宝红包', true)
    delitembymakeindex(play, getiteminfo(play, item, 1), 1)
end
function stdmodefunc48(play, item) -- 真实充值卷
    local wpid = getiteminfo(play,item,2)
    local sl = getiteminfo(play, item, 5)
    local wpjg = getstditeminfo(wpid,8)
    changemoney(play,23,"+",wpjg*sl,"真实充值卷",true)
    changemoney(play,8,"+",wpjg*100*sl,"真实充值卷",true)
    --changemoney(play,23,"+",wpjg*sl,"真实充值卷",true)  --累计充值
    --sendmsg(play, 1, '{"Msg":"真实充值增加:'..wpjg*sl..'","FColor":253,"BColor":255,"Type":1}')
    delitembymakeindex(play, getiteminfo(play, item, 1), sl)
    --release_print(getiteminfo(play,item,2))
end

---千里传音
function stdmodefunc234(play) ---千里传音 提示：使用50级
    if checkkuafu(play) then
        stop(play)
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>跨服不能使用该物品</font>","Type":9}')
        return
    end
    stop(play)
    if getbaseinfo(play,6) < 60 then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>使用千里传音需要达到60级！</font>","Type":9}')
        return
    end
    say(play, "<发送/@@InputString23(请输入传音内容：)>\\")
end
function inputstring23(play) ---
    if getbaseinfo(play,6) < 60 then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>使用千里传音需要达到60级！</font>","Type":9}')
        return
    end
    local text = getplaydef(play, "S23")
    local name_len = string.len(text)
    if name_len < 1 then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>请输入内容</font>","Type":9}')
        return
    end
    if name_len > 100 then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>内容过长</font>","Type":9}')
        return
    end
    if getbagitemcount(play, "千里传音") < 1 then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>千里传音不足</font>","Type":9}')
        return
    end
    local result, name = exisitssensitiveword(text)
    if result then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>内容包含敏感词</font>","Type":9}')
        return
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
        return
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
    

