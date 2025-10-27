release_print("useitme.lua")
--------------------双击物品触发-------------------随机石
function stdmodefunc9(play, item)
    setplaydef(play,"S$dtm",getbaseinfo(play, 3))
    if getplaydef(play,"N$战斗状态") < os.time() then
        map(play,getbaseinfo(play,3))
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
        if du == "xtc" or du == "剑门外门" or du == "剑门内门" or du == "中州城" or du == "天玄界" or du == "北境仙域" or du == "中央仙域" or du == "诡异位面" or du == "叹息旷野" then
            mapmove(play, 'xtc', 137,138,8)
            addhpper(play, '=', 100)
            addmpper(play, '=', 100)
        elseif daluditu[du] and daluditu[du] == 1 then mapmove(play, "xtc",137,138,5) addhpper(play, '=', 100) addmpper(play, '=', 100)
        elseif daluditu[du] and daluditu[du] == 2 then mapmove(play, "剑门外门",104,85,4) addhpper(play, '=', 100) addmpper(play, '=', 100)
        elseif daluditu[du] and daluditu[du] == 3 then mapmove(play, "剑门内门",104,119,5) addhpper(play, '=', 100) addmpper(play, '=', 100)
        elseif daluditu[du] and daluditu[du] == 4 then mapmove(play, "中州城",649,183,3) addhpper(play, '=', 100) addmpper(play, '=', 100)
        elseif daluditu[du] and daluditu[du] == 5 then mapmove(play, "天玄界",47,46,4) addhpper(play, '=', 100) addmpper(play, '=', 100)
        elseif daluditu[du] and daluditu[du] == 6 then mapmove(play, "北境仙域",53,43,4) addhpper(play, '=', 100) addmpper(play, '=', 100)
        elseif daluditu[du] and daluditu[du] == 7 then mapmove(play, "中央仙域",24,22,5) addhpper(play, '=', 100) addmpper(play, '=', 100)
        elseif daluditu[du] and daluditu[du] == 8 then mapmove(play, "诡异位面",62,61,5) addhpper(play, '=', 100) addmpper(play, '=', 100)
        elseif daluditu[du] and daluditu[du] == 9 then mapmove(play, "叹息旷野",92,76,5) addhpper(play, '=', 100) addmpper(play, '=', 100)
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
--------------------双击物品触发-------------------红名清洗卷
function stdmodefunc20(play, item)
    setbaseinfo(play,46,getbaseinfo(play,46)-100)
    sendmsg(play,1,'{"Msg":"pk值下降100了...","FColor":219,"BColor":255,"Type":1}')
    sendmsg(play,1,'{"Msg":"剩余'..getbaseinfo(play,46)..'...","FColor":219,"BColor":255,"Type":1}')
end
--------------------双击物品触发-------------------仙玉通用
function stdmodefunc21(play, item)
    changemoney(play, getflagstatus(play,VarCfg.BS_mztq) == 1 and 7 or 8, '+', getstditeminfo(getiteminfo(play, item, 2), 8), '双击获得', true)
end

--------------------双击物品触发-------------------灵符通用
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

--------------------双击物品触发-------------------灵符红包
local itme_14 = {
    ["灵符红包(小)"] = {10,20},
    ["灵符红包(中)"] = {30,50},
    ["灵符红包(大)"] = {100,200},
}
function stdmodefunc13(play, item)
    local itemName = getiteminfo(actor, item, ConstCfg.iteminfo.name)
    local min = itme_14[itemName][1]
    local max = itme_14[itemName][2]
    local num = math.random(min, max)
    changemoney(play, getflagstatus(play,VarCfg.BS_mztq) == 1 and 2 or 4, '+', num, '双击获得灵符红包', true)
    delitembymakeindex(play, getiteminfo(play, item, 1), 1)
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