release_print("UtilServer Player.lua")
Player = {}
local bind_money = {
    {3,1},--金币 金币
    {4,2},--元宝 元宝
    {8,7},--灵石 灵石
    {9},--剧情点
    {30},--仙府币
}
local bind_m_tab = {}
for index, value in ipairs(bind_money) do
    for _, v in pairs(value) do
        bind_m_tab[v] = index
    end
end
-- 属性列表缓存：同一玩家、同一属性名、同一属性串重复下发时直接跳过
local _attlist_cache = setmetatable({}, {__mode = "k"})
local function _get_attlist_cache(actor)
    local cache = _attlist_cache[actor]
    if not cache then
        cache = {}
        _attlist_cache[actor] = cache
    end
    return cache
end
local function _build_attlist_cache_value(opt, attrsstr, idx)
    return table.concat({
        tostring(opt or ""),
        tostring(idx or 0),
        tostring(attrsstr or ""),
    }, "\1")
end
--- 自定义属性相关方法
--声明自定义个人变量
function Player.FIniPlayVar(actor, varname, isstr)
    local vartype = isstr and "string" or "integer"
    if type(varname) == "table" then
        varname = table.concat(varname, "|")
    end
    iniplayvar(actor, vartype, "HUMAN", varname)
end
--设置自定义个人变量
function Player.FSetPlayVar(actor, varname, value, save)
    value = value or 0
    save = save or 1
    if type(varname) == "table" then
        for _, vname in ipairs(varname) do
            setplayvar(actor, "HUMAN", vname, value, save)
        end
    else
        setplayvar(actor, "HUMAN", varname, value, save)
    end
end
--设置自定义个人变量
function Player.SetPlayDefEx(actor, varName, value)
    setplaydef(actor, varName, value)
end
-- 二大陆伏妖录：仅当当前追踪任务属于二大陆时，才在状态变更后自动同步并尝试结算奖励。
function Player.trySyncSecondContinentXyl(actor)
    -- 二大陆下雨了流程已迁移到主线，不再从通用 JSON 保存入口同步旧 xyl。
    return false
end
--设置json变量内容，返回table
---* actor:人物对象(填写nil获取全局变量)
---* varName:变量名
---* varValue:变量内容
---@param actor any|nil
---@param varName string
---@param varValue table
---@return table|nil
function Player.setJsonVarByTable(actor, varName, varValue)
    if not varValue then
        return
    end
    local varStr = tbl2json(varValue)
    if actor then
        setplaydef(actor, varName, varStr)
        Player.trySyncSecondContinentXyl(actor)
    else
        setsysvar(varName, varStr)
    end
end
function Player.setJsonTableByVar(actor, varName, varValue)
    if not varValue then
        return
    end
    local varStr = tbl2json(varValue)
    if actor then
        setplaydef(actor, varName, varStr)
        Player.trySyncSecondContinentXyl(actor)
    else
        setsysvar(varName, varStr)
    end
end
--获取json变量内容，返回table
---* actor:人物对象(填写nil获取全局变量)
---* varName:变量名
---@param actor any|nil
---@param varName string
---@return table
function Player.getJsonTableByVar(actor, varName)
    local varStr = ""
    if actor then
        varStr = getplaydef(actor, varName)
    else
        varStr = getsysvar(varName)
    end
    local ret = json2tbl(varStr)
    if ret == "" or type(ret) ~= "table" then ret = {} end
    return ret
end
--设置自定义变量json变量内容
---* actor:人物对象(填写nil获取全局变量)
---* varName:变量名
---* varValue:变量内容
---@param actor any|nil
---@param varName string
---@param varValue table
---@return table|nil
function Player.setJsonPlayVarByTable(actor, varName, varValue)
    if not varValue then
        return
    end
    local varStr = tbl2json(varValue)
    setplayvar(actor, "HUMAN", varName, varStr, 1)
end
--获取自定义变量json变量内容，返回table
---* actor:人物对象(填写nil获取全局变量)
---* varName:变量名
---@param actor any|nil
---@param varName string
---@return table
function Player.getJsonTableByPlayVar(actor, varName)
    local varStr = getplayvar(actor, "HUMAN", varName)
    local ret = json2tbl(varStr)
    if ret == "" or type(ret) ~= "table" then ret = {} end
    return ret
end
--设置全局自定义临时int变量
function Player.SetGlobalTempInt(varName, value)
    setplaydef(0, "N$" .. varName, value)
end
--获取全局自定义临时int变量
function Player.GetGlobalTempInt(varName)
    return getplaydef(0, "N$" .. varName)
end
--设置全局自定义临时str变量table
function Player.SetGlobalTempTable2(varName, value)
    setplaydef(0, "S$" .. varName, tbl2json(value))
end
--获取全局自定义临时str变量table
function Player.GetGlobalTempTable2(varName)
    local ret = getplaydef(0, "S$" .. varName)
    if ret ~= "" then
        return json2tbl(ret)
    end
    return {}
end
--- 自定义属性相关方法------end
function Player.getMoneyNum(actor, moneytype)
    local moneynum = 0
    if bind_m_tab[moneytype] then
        local index = bind_m_tab[moneytype]
        for _, value in ipairs(bind_money[index]) do
            moneynum = moneynum + querymoney(actor, value)
        end
    else
        moneynum = querymoney(actor, moneytype)
    end
    return moneynum
end
--检查货币数量
function Player.checkMoneyNum(actor, moneytype, num)
    local moneynum = 0
    if bind_m_tab[moneytype] then
        local index = bind_m_tab[moneytype]
        for _, value in ipairs(bind_money[index]) do
            moneynum = moneynum + querymoney(actor, value)
        end
    else
        moneynum = querymoney(actor, moneytype)
    end
    return moneynum >= num
end
--检查 物品 货币 装备是否满足数量(数量不足返回不足物品的名字)
function Player.checkItemNumByTable(actor, t, multiple)
    if not t then return end
    if t == {} then return end
    for _,item in ipairs(t) do
        local idx,num = getstditeminfo(item[1], 0),item[2]
        if multiple then num=num*multiple end
        local name = getstditeminfo(idx, 1) or "未知材料"
        if Item.isCurrency(idx) then        --货币
            if not Player.checkMoneyNum(actor, idx, num) then
                return name, num
            end
        else                                    --物品 装备
            if not Bag.checkItemNumByIdx(actor, idx, num) then
                return name, num
            end
        end
    end
end
function Player.getBatItemNum(actor,idx)
    if Item.isCurrency(idx) then        --货币
        return Player.getMoneyNum(actor, idx)
    else                                    --物品 装备
        return getbagitemcount(actor, idx)
    end
end
--拿走物品
function Player.takeItemByTable(actor, t, desc, multiple)
    for _,item in ipairs(t) do
        local idx,num = getstditeminfo(item[1], 0),item[2]
        if multiple then num=num*multiple end
        if Item.isCurrency(idx) then        --货币
            if bind_m_tab[idx] then  --游戏设定 绑定不足扣除正常
                local index = bind_m_tab[idx]
                for _, value in ipairs(bind_money[index]) do
                    if num == 0 then break end
                    local bdyb = querymoney(actor, value)
                    if num > bdyb then    --所需货币不够时 先扣除第一货币 然后循环第二 第三
                        changemoney(actor, value, "-", bdyb, desc, true)   --首先扣除所有绑定金币
                        num = num - bdyb
                    else
                        changemoney(actor, value, "-", num, desc, true)
                        num = 0
                    end
                end
                local bdyb = querymoney(actor, 4)
            end
            if num > 0 then
                changemoney(actor, idx, "-", num, desc, true)
            end
        else                                    --物品 装备
            local name = getstditeminfo(idx, 1)
            takeitem(actor, name, num)
        end
    end
end
--拿走物品idx
function Player.takeItemByTableIdxHs(actor, t)
    for _,item in ipairs(t) do
        local idx,num = item[1],item[2]
        local name = getstditeminfo(idx, 1)
        takeitem(actor, name, num)
    end
end
--给物品
function Player.giveItemByTable(actor, t, desc, multiple, isbind)
    multiple = multiple or 1         --倍数
    for _,item in ipairs(t) do
        local idx,num,bind = getstditeminfo(item[1], 0),item[2],item[3]
        if Item.isCurrency(idx) then        --货币
            changemoney(actor, idx, "+", num * multiple, desc, true)
        else                                    --物品 装备
            local name = getstditeminfo(idx, 1)
            if bind or isbind then
                giveitem(actor, name, num * multiple, 307)
            else
                giveitem(actor, name, num * multiple)
            end
        end
    end
end
--更新部分属性
function Player.updateSomeAddr(actor, cur_attr, next_attr)
    local newattr = {}
    if cur_attr then
        for _,attr in ipairs(cur_attr) do
            local attridx, attrvalue = attr[1], tonumber(attr[2] or 0) or 0
            local addvalue = tonumber(gethumnewvalue(actor, attridx) or 0) or 0
            newattr[attridx] = newattr[attridx] or addvalue
            newattr[attridx] = newattr[attridx] - attrvalue
            if newattr[attridx] < 0 then newattr[attridx] = 0 end
        end
    end
    if next_attr then
        for _,attr in ipairs(next_attr) do
            local attridx, attrvalue = attr[1], tonumber(attr[2] or 0) or 0
            local addvalue = tonumber(gethumnewvalue(actor, attridx) or 0) or 0
            newattr[attridx] = newattr[attridx] or addvalue
            newattr[attridx] = newattr[attridx] + attrvalue
        end
    end
    --cfg_att_score.xls 属性
    for attridx,attrvalue in pairs(newattr) do
        changehumnewvalue(actor, attridx, math.floor(attrvalue), 123456789)
    end
end
--更新部分属性  --带时间的
function Player.updateSomeAddr_time(actor, cur_attr, next_attr,time)
    local newattr = {}
    if cur_attr and #cur_attr > 0 then
        for _,attr in ipairs(cur_attr) do
            local attridx, attrvalue = attr[1], tonumber(attr[2] or 0) or 0
            local addvalue = tonumber(gethumnewvalue(actor, attridx) or 0) or 0
            newattr[attridx] = newattr[attridx] or addvalue
            newattr[attridx] = newattr[attridx] - attrvalue
            if newattr[attridx] < 0 then newattr[attridx] = 0 end
        end
    end
    if next_attr and #next_attr > 0 then
        for _,attr in ipairs(next_attr) do
            local attridx, attrvalue = attr[1], tonumber(attr[2] or 0) or 0
            local addvalue = tonumber(gethumnewvalue(actor, attridx) or 0) or 0
            newattr[attridx] = newattr[attridx] or addvalue
            newattr[attridx] = newattr[attridx] + attrvalue
        end
    end
    --cfg_att_score.xls 属性
    for attridx,attrvalue in pairs(newattr) do
        changehumnewvalue(actor, attridx, math.floor(attrvalue), 123456789)
    end
    local buff_time = os.time()
    setplaydef(actor,"S$updateSomeAddr_time_cur_attr_"..buff_time,tbl2json(cur_attr or {}))
    setplaydef(actor,"S$updateSomeAddr_time_next_attr_"..buff_time,tbl2json(next_attr or {}))
    delaygoto(actor,time * 1000,"updateSomeAddr_time_del,"..buff_time,0)
end
function updateSomeAddr_time_del(actor,time)
    local next_attr = getplaydef(actor,"S$updateSomeAddr_time_cur_attr_"..time)
    local cur_attr = getplaydef(actor,"S$updateSomeAddr_time_next_attr_"..time)
    setplaydef(actor,"S$updateSomeAddr_time_cur_attr_"..time,nil)
    setplaydef(actor,"S$updateSomeAddr_time_next_attr_"..time,nil)
    next_attr = (next_attr == "{}" and nil or json2tbl(next_attr))
    cur_attr = (cur_attr == "{}" and nil or json2tbl(cur_attr))
    local newattr = {}
    if cur_attr and #cur_attr > 0 then
        for _,attr in ipairs(cur_attr) do
            local attridx, attrvalue = attr[1], tonumber(attr[2] or 0) or 0
            local addvalue = tonumber(gethumnewvalue(actor, attridx) or 0) or 0
            newattr[attridx] = newattr[attridx] or addvalue
            newattr[attridx] = newattr[attridx] - attrvalue
            if newattr[attridx] < 0 then newattr[attridx] = 0 end
        end
    end
    if next_attr and #next_attr > 0 then
        for _,attr in ipairs(next_attr) do
            local attridx, attrvalue = attr[1], tonumber(attr[2] or 0) or 0
            local addvalue = tonumber(gethumnewvalue(actor, attridx) or 0) or 0
            newattr[attridx] = newattr[attridx] or addvalue
            newattr[attridx] = newattr[attridx] + attrvalue
        end
    end
    --cfg_att_score.xls 属性
    for attridx,attrvalue in pairs(newattr) do
        changehumnewvalue(actor, attridx, math.floor(attrvalue), 123456789)
    end
end
function Player.rwjl(actor, t, desc, multiple,gm)
    if type(t) ~= "table" then
        return
    end
    if multiple and multiple < 1 then
        return
    end
    local str = ""
    local rate = multiple or 1
    for _, v in ipairs(t) do
        local name = v[1]
        local amount = (tonumber(v[2]) or 0) * rate
        if name and amount > 0 then
            local idx = getstditeminfo(name, 0)
            if str ~= "" then
                str = str .. ","
            end
            str = str .. '["' .. name .. '",' .. amount .. ']'
            if idx and Item.isCurrency(idx) then        --货币
                changemoney(actor,idx,"+",amount,desc,true)
            else
                giveitem(actor,name,amount,850)
            end
        end
    end
    if str ~= "" and gm ~= 0 then
        sendluamsg(actor,101,0,9,gm and gm or 999,'{"item":['..str..']}')
    end
    release_print("Player.rwjl", desc, str, getbaseinfo(actor,1))
end
--发送消息个人
function Player.sendmsg(actor, msg)
    if type(msg) == "string" then
        Player.sendmsgEx(actor, ConstCfg.notice.own, '{"Msg":"' .. msg .. '","Type":9}')
    elseif type(msg) == "table" then
        local MsgStr = ""
        for _, v in ipairs(msg) do
            MsgStr = MsgStr .. "<font color='" .. v[1] .. "' size='14'>" .. v[2] .. "</font>"
        end
        Player.sendmsgEx(actor, ConstCfg.notice.own, '{"Msg":"' .. MsgStr .. '","Type":9}')
    end
end
--发送个人消息9
--* actor：个人对象
--* str：消息内容 格式 文本#颜色|文本#颜色 (颜色值0-255)
--* defaultColor：默认颜色 默认为白色
function Player.sendmsgEx(actor, arg2, arg3)
    if type(arg2) == "number" then
        local channel = arg2
        local payload = arg3
        if type(payload) ~= "string" or payload == "" then
            return
        end
        sendmsg(actor, channel, payload)
        return
    end
    local str = arg2
    if str == nil or str == "" then
        return
    end
    local defaultColor = arg3 or 250
    local content = ""
    local part = string.split(str, "|")
    for _, v in ipairs(part) do
        local text = string.split(v, "#")
        local colorNum = tonumber(text[2])
        colorNum = colorNum or defaultColor
        local hexColor = ColorCfg[colorNum] ~= nil and ColorCfg[colorNum].hexColor or ColorCfg[defaultColor].hexColor
        content = content .. "<font color='" .. hexColor .. "' size='14' >" .. text[1] .. "</font>"
    end
    if content ~= "" then
        sendmsg(actor, ConstCfg.notice.own, '{"Msg":"' .. content .. '","Type":9}')
    end
end
--在屏幕中间给自己播放特效
function Player.screffects(actor, effectId, offsetX, offsetY)
    offsetX = offsetX or 0
    offsetY = offsetY or 0
    local x = getconst(actor, "<$SCREENWIDTH>") / 2 + offsetX
    local y = getconst(actor, "<$SCREENHEIGHT>") / 2 + offsetY
    screffects(actor, 1, effectId, x, y, 1, 1, 0)
end
---@param actor userdata 玩家对象
function Player.GetName(actor)
    return getbaseinfo(actor, 1)
end
--获取人物/怪物当前地图代码
function Player.MapKey(actor)
    return getbaseinfo(actor, 3)
end
--获取目标坐标x
function Player.GetX(actor)
    return getbaseinfo(actor, 4)
end
--获取目标坐标y
function Player.GetY(actor)
    return getbaseinfo(actor, 5)
end
--根据属性ID获取属性值
function Player.GetAttr(actor, attrId)
    return getbaseinfo(actor, 51, attrId)
end
--获取人物唯一ID str
function Player.GetUUID(actor)
    return getbaseinfo(actor, 2)
end
----获得角色等级
---@param actor  --玩家对象
function Player.GetLevel(actor)
    return getbaseinfo(actor, 6)
end

local _role_level_cap = 150
local _role_level_fixing = setmetatable({}, {__mode = "k"})

-- 角色等级上限：统一控制所有人物等级成长入口。
function Player.getRoleLevelCap()
    return _role_level_cap
end

-- 经验类道具名称识别：统一给爆率监听、掉落清理、使用限制复用。
function Player.isExpPillName(itemName)
    itemName = tostring(itemName or "")
    if itemName == "" then
        return false
    end
    return string.find(itemName, "经验丹", 1, true) ~= nil
        or string.find(itemName, "经验卷", 1, true) ~= nil
end

-- 预留等级锁入口：当前不再使用 setlocklevel，仅保留函数壳避免旧调用报错。
function Player.applyRoleLevelCap(actor)
    return false
end

-- 是否已达到人物等级上限。
function Player.isRoleLevelLocked(actor)
    return (tonumber(Player.GetLevel(actor)) or 0) >= _role_level_cap
end

-- 150 级后经验丹不再保留掉落：按 StdMode=12 与经验丹名称双重识别。
function Player.isExpPillItemObj(actor, itemobj)
    if not actor or not itemobj or itemobj == "0" then
        return false
    end
    local itemIdx = tonumber(getiteminfo(actor, itemobj, 2) or 0) or 0
    if itemIdx <= 0 then
        return false
    end
    local stdmode = tonumber(getstditeminfo(itemIdx, 2) or -1) or -1
    local itemName = tostring(getiteminfo(actor, itemobj, 7) or "")
    return stdmode == 12 or Player.isExpPillName(itemName)
end

-- 检查当前是否还能继续获得人物等级经验；达到上限时返回 false。
function Player.canGainRoleLevel(actor, tip)
    if Player.isRoleLevelLocked(actor) then
        if tip ~= false then
            Player.sendmsgEx(actor, tip or string.format("当前等级已达#57|【%d级】#218|，无法继续获得人物等级经验#57", _role_level_cap))
        end
        return false
    end
    return true
end

-- 统一加人物等级：当前仅负责正向加级，不再限制非经验丹的升级途径。
function Player.addRoleLevel(actor, add, tip)
    add = tonumber(add) or 0
    if add <= 0 then
        return false, 0
    end
    callscriptex(actor, "CHANGELEVEL", "+", add)
    return true, add
end

-- 预留封顶入口：当前不再对非经验丹途径做等级回退。
function Player.clampRoleLevel(actor, tip)
    return false
end
function Player.zxrw_lingqu(actor, zxrw_id, desc) --领取支线任务
    if not json2tbl(getplaydef(actor, VarCfg.T_zxrw))[zxrw_id] then
        newpicktask(actor,zxrw_id)
        rwcf.jia(actor,zxrw_id)
        sendluamsg(actor,101,1005,0,0,getplaydef(actor, VarCfg.T_zxrw))
    end
end
function Player.zxrw_wancheng(actor, zxrw_id, desc) --完成任务
    if zxrw_id < 1000 then --主线
        if getplaydef(actor,VarCfg.U_zxrw[1]) == zxrw_id then
            newdeletetask(actor, zxrw_id)
        end
    else
        if json2tbl(getplaydef(actor, VarCfg.T_zxrw))[""..zxrw_id] then
            if constant.rw_syb[zxrw_id][1] == 0 then --无实体任务
                rwcf.jian(actor,zxrw_id)
                newdeletetask(actor, zxrw_id)
            else
                newdeletetask(actor, zxrw_id)
            end
        end
    end
end
function Player.zxrw_shuaxin(actor, zxrw_id,jd, desc) --刷新任务 -- 有参
    if zxrw_id < 500 and getplaydef(actor,VarCfg.U_zxrw[1]) ~= zxrw_id then
        return
    end
    newchangetask(actor, zxrw_id,unpack(jd))
end
function Player.zxrw_teshushuaxin(actor, zxrw_id, desc) --特殊刷新任务--无参
    if zxrw_id < 500 and getplaydef(actor,VarCfg.U_zxrw[1]) ~= zxrw_id then
        return
    end
    if constant.rw_syb[zxrw_id] and constant.rw_syb[zxrw_id].jd then
        local chuliwp = json2tbl(getplaydef(actor, VarCfg.T_rwwp))
        local db = json2tbl(getplaydef(actor,VarCfg.T_dljq))
        if db[constant.rw_syb[zxrw_id].jd[1]] and constant.rw_syb[zxrw_id].jd[2] == 1 then
            newchangetask(actor, zxrw_id,db[constant.rw_syb[zxrw_id].jd[1]][2])
        end
        if db[constant.rw_syb[zxrw_id].jd[1]] and db[constant.rw_syb[zxrw_id].jd[1]] == 1 and constant.rw_syb[zxrw_id].jd[2] == 0 then
            if constant.rw_syb[zxrw_id].sjwp then
                local sl = {}
                -- 获取表的键并排序
                local keys = {}
                for k in pairs(constant.rw_syb[zxrw_id].sjwp) do
                    table.insert(keys, k)
                end
                table.sort(keys)
                for i, y in ipairs(keys) do
                    if chuliwp[y] then
                        table.insert(sl,getbagitemcount(actor,y) >= constant.rw_syb[zxrw_id].sjwp[y] and constant.rw_syb[zxrw_id].sjwp[y] or getbagitemcount(actor,y))
                    else
                        table.insert(sl,constant.rw_syb[zxrw_id].sjwp[y])
                    end
                end
                -- 调用newpicktask函数，并将sj表中的元素作为参数传入
                newchangetask(actor, zxrw_id,unpack(sl))
            end
        end
    end
    if constant.rw_syb[zxrw_id] and constant.rw_syb[zxrw_id].ts then
        if constant.rw_syb[zxrw_id].ts[1] == 1 then
            local db = json2tbl(getplaydef(actor,VarCfg.T_dljq))
            local sl = {
                getbagitemcount(actor,constant.rw_syb[zxrw_id].ts.wp),
                (db[constant.rw_syb[zxrw_id].ts.cs[1]] and db[constant.rw_syb[zxrw_id].ts.cs[1]][constant.rw_syb[zxrw_id].ts.cs[2]])
                        and db[constant.rw_syb[zxrw_id].ts.cs[1]][constant.rw_syb[zxrw_id].ts.cs[2]] or 0
            }
            newchangetask(actor, zxrw_id,unpack(sl))
        elseif constant.rw_syb[zxrw_id].ts[1] == 2 then
            local db = json2tbl(getplaydef(actor,VarCfg.T_dljq))
            local sl = {}
            for v,k in pairs(constant.rw_syb[zxrw_id].ts.wp) do
                table.insert(sl,getbagitemcount(actor,k))
                table.insert(sl,
                        (db[constant.rw_syb[zxrw_id].ts.cs[1]] and
                                db[constant.rw_syb[zxrw_id].ts.cs[1]][constant.rw_syb[zxrw_id].ts.cs[2]] and
                                db[constant.rw_syb[zxrw_id].ts.cs[1]][constant.rw_syb[zxrw_id].ts.cs[2]][""..v])
                        and db[constant.rw_syb[zxrw_id].ts.cs[1]][constant.rw_syb[zxrw_id].ts.cs[2]][""..v] or 0)
            end
            newchangetask(actor, zxrw_id,unpack(sl))
        elseif constant.rw_syb[zxrw_id].ts[1] == 3 then
            local db = json2tbl(getplaydef(actor,VarCfg.T_dljq))
            local sl = {}
            for v,k in pairs(constant.rw_syb[zxrw_id].ts.cs[2]) do
                table.insert(sl,
                        (db[constant.rw_syb[zxrw_id].ts.cs[1]] and
                                db[constant.rw_syb[zxrw_id].ts.cs[1]][k])
                                and db[constant.rw_syb[zxrw_id].ts.cs[1]][k] or 0)
            end
            newchangetask(actor, zxrw_id,unpack(sl))
        elseif constant.rw_syb[zxrw_id].ts[1] == 4 then
            local db = json2tbl(getplaydef(actor,VarCfg.T_dljq))
            local sl = {}
            for v,k in pairs(constant.rw_syb[zxrw_id].ts.wp) do
                table.insert(sl,getbagitemcount(actor,k))
                table.insert(sl,
                        (db[constant.rw_syb[zxrw_id].ts.cs[1]] and
                                db[constant.rw_syb[zxrw_id].ts.cs[1]][constant.rw_syb[zxrw_id].ts.cs[2][v]])
                                and db[constant.rw_syb[zxrw_id].ts.cs[1]][constant.rw_syb[zxrw_id].ts.cs[2][v]] or 0)
            end
            newchangetask(actor, zxrw_id,unpack(sl))
        elseif constant.rw_syb[zxrw_id].ts[1] == 5 then
            if zxrw_id == 2007 then
                local sl = {}
                for v,k in pairs(constant.rw_syb[zxrw_id].ts.wp) do
                    table.insert(sl,getbagitemcount(actor,k))
                end
                newchangetask(actor, zxrw_id,unpack(sl))
            end
        end
    end
end
-- 战斗力权重：基于 cfg_att_score 属性说明手工定义（不使用 nbvalue）
-- 备注：已按需求补充 200~300 段扩展属性权重
local zdl_attr = {
    -- 战士核心输出
    {3, 9.0}, {4, 9.0}, -- 攻击下限/上限
    -- 基础生存
    {1, 1}, -- 生命值
    {9, 3.0}, {10, 3.2}, -- 防御下限/上限
    -- 基础命中/闪避与攻速
    {13, 2.5}, -- ??
    {14, 2.5}, -- 敏捷
    {20, 120}, -- 攻击速度
    -- 暴击与伤害向
    {21, 400.0}, -- 暴击几率增加
    {22, 200.0}, -- 暴击伤害增加
    {23, 200.0}, -- 暴击几率抵抗
    {24, 200.0}, -- 暴伤伤害抵抗
    {25, 300.0}, -- 增加攻击伤害
    {26, 200.0}, -- 物理伤害减少
    {30, 300.0}, -- 人物体力增加
    {34, 200.0}, -- 攻击吸血
    -- 高阶战斗属性
    {63, 2.0}, -- 格挡概率
    {64, 2.0}, -- 格挡伤害
    {67, 20}, -- 人物倍功
    {73, 35}, -- 最终攻击
    {76, 20.0}, -- PK增伤
    {77, 20.0}, -- PK减伤
    {78, 2.2}, -- 穿透
    {79, 30}, -- 神圣一击
    {82, 20.0}, -- 受怪减伤
    {89, 30.0}, -- 最终血量
    -- 200~300 扩展属性（cfg_att_score）
    {200, 30.0}, -- 对怪攻速
    {201, 30.0}, -- 对人攻速
    {202, 0}, -- 人物血量（展示加成）
    {203, 0}, -- 人物攻击（展示加成）
    {204, 10}, -- 金币回收
    {205, 10}, -- 元宝回收
    {206, 30.0}, -- 伤害吸收
    {207, 1.2}, -- 鞭尸几率
    {208, 3.5}, -- 最大血量
    {209, 4.0}, -- 最大攻击
    {210, 2.8}, -- 对人攻速（扩展）
    {242, 2.0}, -- 杀怪爆率
    {243, 2.2}, -- 移动速度
    {244, 1}, -- 打怪切割
    {245, 20.0}, -- 打怪增伤
    {246, 1.6}, -- 专属爆率
    {247, 1.4}, -- 剧情材料爆率
    {248, 1.0}, -- 对怪生命窃取
    {249, 1.0}, -- 生命窃取
    {250, 20.6}, -- 切割暴击几率
    {251, 20.2}, -- 切割暴击伤害
    {252, 1.2}, -- 巅峰等级
    {253, 30.0}, -- 切割百分比
    {254, 3.5}, -- 职业攻击
    {255, 20.4}, -- 怪物格挡
    {256, 3.0}, -- 技能伤害减免
    {280, 100.0}, -- 生命值百分比
    {281, 100.0}, -- 魔法值百分比
    {282, 400.0}, -- 攻击上限百分比
    {283, 0}, -- 魔法上限百分比
    {284, 0}, -- 道术上限百分比
    {285, 200.0}, -- 物防上限百分比
    {286, 0}, -- 魔防上限百分比
    {287, 300.0}, -- 攻击下限百分比
    {288, 0}, -- 魔法下限百分比
    {289, 0}, -- 道术下限百分比
    {290, 200.0}, -- 物防下限百分比
    {291, 0}, -- 魔防下限百分比
    {300, 0}, -- 全属性
}
function Player.updata_zdl(actor, desc) --战斗力更新
    local zdl = 0
    for _, k in ipairs(zdl_attr) do
        local v = getbaseinfo(actor, 51, k[1]) or 0
        if v > 0 then
            zdl = zdl + v * k[2]
        end
    end
    zdl = math.floor(zdl)
    if zdl ~= querymoney(actor, 29) then
        changemoney(actor, 29, "=", zdl, "战斗力更新", true)
        setplaydef(actor, VarCfg["B_记录战斗力"], zdl)
    end
end
local function _change_title_level(actor, title_name, op)
    local cfg = constant.title_level_change or {}
    local delta = tonumber(cfg[title_name] or 0) or 0
    if delta <= 0 then
        return
    end
    if op == "+" then
        Player.addRoleLevel(actor, delta, false)
    else
        callscriptex(actor, "CHANGELEVEL", op, delta)
    end
end
function Player.title_give(actor, title_name) --给称号
    if not checktitle(actor, title_name) then
        release_print("给称号",title_name,getbaseinfo(actor,1))
        confertitle(actor, title_name)
        if title_name == "白云苍狗" and (tonumber(getbaseinfo(actor, 6) or 0) or 0) < 150 then
            callscriptex(actor, "CHANGELEVEL", "=", 150)
        end
        _change_title_level(actor, title_name, "+")
        GameEvent.push(EventCfg.onGetTaskTitle, actor, title_name)
        local raw_idx = getstditeminfo(title_name,8)
        local idx = tonumber(raw_idx or 0) or 0
        if idx > 0 then
            Buff[idx](actor,1)
            -- Buff[idx](actor,5)
        end
        Player.trySyncSecondContinentXyl(actor)
        if title_name == "诸邪退散" and Login and Login.refreshGrayWorldVision then
            Login.refreshGrayWorldVision(actor)
        end
    end
end
function Player.title_del(actor, title_name) --删称号
    if checktitle(actor, title_name) then
        release_print("删称号",title_name,getbaseinfo(actor,1))
        deprivetitle(actor, title_name)
        _change_title_level(actor, title_name, "-")
        local raw_idx = getstditeminfo(title_name,8)
        local idx = tonumber(raw_idx or 0) or 0
        if idx > 0 then
            Buff[idx](actor,2)
            -- Buff[idx](actor,6)
        end
        if title_name == "诸邪退散" and Login and Login.refreshGrayWorldVision then
            Login.refreshGrayWorldVision(actor)
        end
    end
end
function Player.clear_attlist_cache(actor, attr_name)
    if not actor then
        return
    end
    local cache = _attlist_cache[actor]
    if not cache then
        return
    end
    if attr_name and attr_name ~= "" then
        cache[attr_name] = nil
    else
        _attlist_cache[actor] = nil
    end
end
function Player.del_attlist(actor, arrt_name) --删属性
    local cache = _get_attlist_cache(actor)
    if cache[arrt_name] == false then
        return
    end
    delattlist(actor, arrt_name)
    cache[arrt_name] = false
    -- release_print("删属性",arrt_name,getbaseinfo(actor,1))
end
function Player.add_attlist(actor, title_name,opt, attrsstr,idx) --给属性
    local cache = _get_attlist_cache(actor)
    local cache_value = _build_attlist_cache_value(opt, attrsstr, idx)
    if cache[title_name] == cache_value then
        return
    end
    addattlist(actor, title_name, opt, attrsstr, idx)
    cache[title_name] = cache_value
    -- release_print("给属性",title_name,attrsstr,getbaseinfo(actor,1),opt,idx)
end
function Player.jl_mail(table) --奖励转邮件
    local str = ""
    for v,k in pairs(table) do
        local idx = getstditeminfo(k[1], 0)
        if Item.isCurrency(idx) then        --货币
            str = str .. k[1] .. "#" .. k[2] .. "&"
        else                                    --物品 装备
            str = str .. k[1] .. "#" .. k[2] .. "#850&"
        end
    end
    -- release_print("jl_mail",str)
    return str
end
local function _dl_get_jqd(actor)
    local jqd_idx = getstditeminfo("剧情点", 0)
    if not jqd_idx or jqd_idx <= 0 then
        return 0
    end
    return querymoney(actor, jqd_idx) or 0
end
local _dl_xyl_cfg_cache
local function _dl_get_xyl_cfg()
    if _dl_xyl_cfg_cache ~= nil then
        return _dl_xyl_cfg_cache
    end
    local ok, cfg = pcall(dofile, 'Envir/Lua/Data/npc_xyl.lua')
    _dl_xyl_cfg_cache = (ok and type(cfg) == "table") and cfg or false
    return _dl_xyl_cfg_cache
end
local function _dl_get_task_story_point(task)
    local rewards = type(task) == "table" and task.jl or nil
    if type(rewards) ~= "table" then
        return 0
    end
    local total = 0
    for _, reward in ipairs(rewards) do
        if type(reward) == "table" and reward[1] == "剧情点" then
            total = total + (tonumber(reward[2]) or 0)
        end
    end
    return total
end
-- 大陆门槛：按已领取的伏妖录剧情点奖励计算本大陆剧情完成度。
local function _dl_has_story_progress(actor, continent, need_percent)
    local cfg = _dl_get_xyl_cfg()
    local chapters = type(cfg) == "table" and cfg[continent] or nil
    if type(chapters) ~= "table" then
        return false
    end
    local ywl = Player.getJsonTableByVar(actor, VarCfg.T_ywl) or {}
    local total = 0
    local received = 0
    for chapter_idx, chapter in ipairs(chapters) do
        local tasks = type(chapter) == "table" and chapter.jq or nil
        if type(tasks) == "table" then
            local chapter_key = "jl_" .. continent .. "_" .. chapter_idx
            local chapter_received = tonumber(ywl[chapter_key] or 0) == 1
            for task_idx, task in ipairs(tasks) do
                local point = _dl_get_task_story_point(task)
                total = total + point
                if point > 0 and (chapter_received or tonumber(ywl[chapter_key .. "_" .. task_idx] or 0) == 1) then
                    received = received + point
                end
            end
        end
    end
    if total <= 0 then
        return false
    end
    return received * 100 >= total * (tonumber(need_percent) or 100)
end
local function _dl_has_story_task_count(actor, continent, need_count, debug)
    local cfg = _dl_get_xyl_cfg()
    local chapters = type(cfg) == "table" and cfg[continent] or nil
    if type(chapters) ~= "table" then
        return false
    end
    local ywl = Player.getJsonTableByVar(actor, VarCfg.T_ywl) or {}
    local done = 0
    local miss = {}
    for chapter_idx, chapter in ipairs(chapters) do
        local tasks = type(chapter) == "table" and chapter.jq or nil
        if type(tasks) == "table" then
            local chapter_key = "jl_" .. continent .. "_" .. chapter_idx
            local chapter_received = tonumber(ywl[chapter_key] or 0) == 1
            for task_idx, task in ipairs(tasks) do
                if not (type(task) == "table" and tonumber(task.side_task or 0) == 1) then
                    local finished = chapter_received or tonumber(ywl[chapter_key .. "_" .. task_idx] or 0) == 1
                    if not finished and type(task) == "table" and type(task.fwdjy) == "function" then
                        local ok, ret = pcall(task.fwdjy, actor, task.tk, task)
                        finished = ok and ret and true or false
                    end
                    if finished then
                        done = done + 1
                    elseif debug then
                        miss[#miss + 1] = tostring(chapter_idx) .. "_" .. tostring(task_idx) .. ":" .. tostring(type(task) == "table" and task[1] or "?")
                    end
                end
            end
        end
    end
    local need = tonumber(need_count) or 0
    if debug then
    end
    return done >= need, done, need
end
local function _dl_has_story_point_count(actor, continent, need_count, debug)
    local cfg = _dl_get_xyl_cfg()
    local chapters = type(cfg) == "table" and cfg[continent] or nil
    if type(chapters) ~= "table" then
        return false
    end
    local ywl = Player.getJsonTableByVar(actor, VarCfg.T_ywl) or {}
    local done = 0
    local miss = {}
    for chapter_idx, chapter in ipairs(chapters) do
        local tasks = type(chapter) == "table" and chapter.jq or nil
        if type(tasks) == "table" then
            local chapter_key = "jl_" .. continent .. "_" .. chapter_idx
            local chapter_received = tonumber(ywl[chapter_key] or 0) == 1
            for task_idx, task in ipairs(tasks) do
                local point = _dl_get_task_story_point(task)
                if point > 0 and not (type(task) == "table" and tonumber(task.side_task or 0) == 1) then
                    local finished = chapter_received or tonumber(ywl[chapter_key .. "_" .. task_idx] or 0) == 1
                    if not finished and type(task) == "table" and type(task.fwdjy) == "function" then
                        local ok, ret = pcall(task.fwdjy, actor, task.tk, task)
                        finished = ok and ret and true or false
                    end
                    if finished then
                        done = done + point
                    elseif debug then
                        miss[#miss + 1] = tostring(chapter_idx) .. "_" .. tostring(task_idx) .. ":" .. tostring(type(task) == "table" and task[1] or "?") .. "(" .. tostring(point) .. ")"
                    end
                end
            end
        end
    end
    local need = tonumber(need_count) or 0
    if debug then
    end
    return done >= need, done, need
end
-- 五大陆门槛：10 种灵根均已激活。
local function _dl_has_all_linggen(actor)
    local data = Player.getJsonTableByVar(actor, VarCfg["T_灵根"]) or {}
    local levels = type(data.level) == "table" and data.level or {}
    for i = 1, 5 do
        if (tonumber(levels[tostring(i)] or levels[i] or 0) or 0) == 0 then
            return false
        end
    end
    return true
end
-- 五大陆门槛：本命灵根对应的基础灵根满级，且觉醒灵根达到 Lv.2。
local function _dl_has_linggen_gate(actor)
    local data = Player.getJsonTableByVar(actor, VarCfg["T_灵根"]) or {}
    local levels = type(data.level) == "table" and data.level or {}
    local cfg = (teshudata or {})["npc_22"] or {}
    local main = tonumber(data.main or 0) or 0
    local pair = tonumber((cfg.awaken_pairs or {})[main] or 0) or 0
    if main <= 0 or pair <= 0 then
        return false
    end
    local base = main <= 5 and main or pair
    local awaken = main <= 5 and pair or main
    if base <= 0 or base > 5 or awaken <= 5 then
        return false
    end
    return (tonumber(levels[tostring(base)] or 0) or 0) >= 10 and (tonumber(levels[tostring(awaken)] or 0) or 0) >= 2
end
-- 六大陆门槛：检查天道命盘是否已全部完成。
local function _dl_has_all_destiny(actor)
    local jq_data = Player.getJsonTableByVar(actor, VarCfg.T_dljq) or {}
    local state = type(jq_data["npc_74"]) == "table" and jq_data["npc_74"] or {}
    local need = tonumber((((teshudata or {})["npc_74"] or {}).all) or 4) or 4
    return (tonumber(state.all) or 0) >= need
end
-- 大陆门槛：统一读取基础状态。
local function _dl_get_base_state(actor)
    return {
        zslv = tonumber(getplaydef(actor, VarCfg["U_转生等级"]) or 0) or 0,
        jqd = _dl_get_jqd(actor),
        level = tonumber(getbaseinfo(actor, 6)) or 0,
        zxrw = tonumber(getplaydef(actor, VarCfg.U_zxrw[1]) or 0) or 0,
    }
end
local function _dl_check(actor, dl)
    if dl == 1 then
        return true
    end
    local admin_unlock = tonumber(getplaydef(actor, "U_全大陆解锁")) or 0
    -- 兼容旧值：1 代表全大陆解锁；2~6 代表后台逐步解锁到对应大陆。
    if admin_unlock == 1 or admin_unlock >= dl then
        return true
    end
    local state = _dl_get_base_state(actor)
    local zslv = state.zslv
    local jqd = state.jqd
    local level = state.level
    local zxrw = state.zxrw
    if dl == 2 then
        if zxrw >= 16 then
            return true
        end
        return false, "需完成主线引导后才可进入二大陆"
    elseif dl == 3 then
        if zxrw >= 35 then
            return true
        end
        return false, "需跟随主线引导后才可进入三大陆"
    elseif dl == 4 then
        local story_ok, story_done, story_need = _dl_has_story_point_count(actor, 3, 25, true)
        if story_ok and zslv >= 30 and level >= 150 then
            return true
        end
        return false, "需三大陆剧情点达到25点、完成三大陆转生且人物等级达到150级后才可进入四大陆"
    elseif dl == 5 then
        local story_ok, story_done, story_need = _dl_has_story_point_count(actor, 4, 69, true)
        local linggen_ok = _dl_has_all_linggen(actor)
        if story_ok and zslv >= 40 and linggen_ok then
            return true
        end
        return false, "需四大陆剧情点达到69点、完成四大陆转生且全部基础灵根达到Lv.1后才可进入五大陆"
    elseif dl == 6 then
        local story_ok, story_done, story_need = _dl_has_story_point_count(actor, 5, 61, true)
        local destiny_ok = _dl_has_all_destiny(actor)
        if story_ok and zslv >= 50 and destiny_ok then
            return true
        end
        return false, "需五大陆剧情点达到61点、完成五大陆转生且完成天道命盘后才可进入六大陆"
    elseif dl == 7 then
        local story_ok, story_done, story_need = _dl_has_story_point_count(actor, 6, 81, true)
        local pass_ok = Player.hasSeventhContinentPass(actor)
        if story_ok and zslv >= 60 and pass_ok then
            return true
        end
        return false, "需六大陆剧情点达到81点、完成六大陆转生且获得#57|【世界符文·[真我]】#218|后才可进入七大陆"
    elseif dl == 8 then
        if zslv >= 70 then
            return true
        end
        return false, "需完成七大陆转生后才可进入八大陆"
    end
    return true
end
function Player.dl_sz_notip(actor, dl) --大陆限制 -- 无提示
    local ok = _dl_check(actor, dl)
    return ok
end
function Player.dl_sz(actor, dl) --大陆限制 -- 有提示
    local ok, tip = _dl_check(actor, dl)
    if not ok and tip then
        Player.sendmsgEx(actor, tip .. "#57")
    end
    return ok
end
local _third_continent_frontier_map = {
    ["灰界"] = true,
}
-- 灰界系列地图统一判断，用于野外压制、视野等共用逻辑。
local _huijie_maps = {
    ["灰界"] = true,
    ["灰界南部"] = true,
    ["灰界北部"] = true,
    ["灰界东部"] = true,
    ["灰界西部"] = true,
    ["虚妄山脉"] = true,
    ["山脉入口"] = true,
    ["鬼嘲深渊"] = true,
    ["旷野之原"] = true,
    ["叹息旷野"] = true,
    ["恐怖裂隙"] = true,
    ["禁忌之海"] = true,
    ["海峰孤岛"] = true,
}
function Player.isHuiJieMap(map_name)
    return type(map_name) == "string" and _huijie_maps[map_name] == true
end
function Player.hasHuiJieImmunity(actor)
    return checktitle(actor, "诸邪退散")
end
-- 灰界压制判定：在灰界且没有【诸邪退散】时，受到灰界环境压制。
function Player.isHuiJieSuppressed(actor)
    if not actor then
        return false
    end
    local map_name = tostring(getbaseinfo(actor, 3) or "")
    return Player.isHuiJieMap(map_name) and not Player.hasHuiJieImmunity(actor)
end
-- 灰界压制下：对怪最终伤害降低50%。
function Player.getHuiJieMonsterDamageRate(actor)
    return Player.isHuiJieSuppressed(actor) and 0.5 or 1
end
-- 灰界压制下：受到怪物最终伤害增加10%。
function Player.getHuiJieMonsterHurtRate(actor)
    return Player.isHuiJieSuppressed(actor) and 1.1 or 1
end
-- 三大陆正式开启判定：完成“开辟仙府”后，才可进入灰界之外的三大陆地图并使用相关功能。
-- 兼容旧号：若历史上已经完成过任务、手动开辟等，也同样视为已正式开辟。
function Player.hasThirdContinentOpen(actor)
    local jq_data = Player.getJsonTableByVar(actor, VarCfg.T_dljq) or {}
    if tonumber(jq_data["npc_55"] or 0) >= 2 then
        return true
    end
    local task = jq_data["npc_46"]
    return type(task) == "table" and tonumber(task.wc) == 1
end
-- 三大陆地图限制：未开辟仙府时，只允许进入【灰界】，其余三大陆地图一律拦截。
function Player.canEnterThirdContinentMap(actor, map_name)
    if type(map_name) ~= "string" or map_name == "" then
        return true
    end
    if not (type(daluditu) == "table" and daluditu[map_name] == 3) then
        return true
    end
    if _third_continent_frontier_map[map_name] then
        return true
    end
    if Player.hasThirdContinentPass(actor) then
        return true
    end
    if map_name == "三大陆主城" then
        return false
    end
    return true
    -- return Player.hasThirdContinentOpen(actor)
end
-- 三大陆功能限制：完成“开辟仙府”后，才视为正式解锁三大陆功能。
function Player.ensureThirdContinentOpen(actor, tip)
    if Player.hasThirdContinentOpen(actor) then
        return true
    end
    Player.sendmsgEx(actor, tip or "请先#57|【开辟仙府】#218|后再使用该功能#57")
    return false
end
-- 三大陆地图限制：处理灰界放行、主城拦截与正式地图进入提示。
function Player.ensureThirdContinentMapAccess(actor, map_name, tip)
    if Player.canEnterThirdContinentMap(actor, map_name) then
        return true
    end
    if map_name == "三大陆主城" then
        Player.sendmsgEx(actor, tip or "请先#57|【开辟仙府】#218|后前往#57|【三大陆主城】#218|#57")
        return false
    end
    Player.sendmsgEx(actor, tip or ("请先#57|【开辟仙府】#218|后前往#57|【" .. map_name .. "】#218|#57"))
    return false
end
function Player.hasThirdContinentPass(actor)
    local jq_data = Player.getJsonTableByVar(actor, VarCfg.T_dljq)
    local task = jq_data and jq_data["npc_46"] or nil
    return type(task) == "table" and tonumber(task.wc) == 1
end
function Player.ensureThirdContinentPass(actor, tip)
    if Player.hasThirdContinentPass(actor) then
        return true
    end
    Player.sendmsgEx(actor, tip or "请先完成#57|【灾厄入侵】#218|后再使用该功能#57")
    return false
end
function Player.moveToThirdContinentFrontier(actor, tip)
    if tip and tip ~= "" then
        Player.sendmsgEx(actor, tip)
    end
    mapmove(actor, "灰界", 201, 199, 5)
    addhpper(actor, '=', 100)
    addmpper(actor, '=', 100)
end
-- 通用门槛：世界符文总奖励领取后视为已解锁。
-- 兜底保护：通过传图卷轴或传送到非法三大陆地图时，统一拉回灰界。
local function _third_continent_map_guard(actor)
    local map_name = tostring(getbaseinfo(actor, 3) or "")
    if map_name == "" then
        return
    end
    if Player.canEnterThirdContinentMap(actor, map_name) then
        return
    end
    if map_name == "三大陆主城" then
        Player.moveToThirdContinentFrontier(actor, "未开#57|【开辟仙府】#218|前暂时只能#57|【灰界】#218|活动#57")
        return
    end
    Player.moveToThirdContinentFrontier(actor, "未开#57|【开辟仙府】#218|前暂时只能#57|【灰界】#218|活动#57")
end
GameEvent.add(EventCfg.onLoginEnd, _third_continent_map_guard, "三大陆地图拦截")
GameEvent.add(EventCfg.goSwitchMap, _third_continent_map_guard, "三大陆地图拦截")
-- 七大陆通行：获得“世界符文·[真我]”称号后视为解锁。
function Player.hasSeventhContinentPass(actor)
    return checktitle(actor, "世界符文·[真我]")
end
-- 七大陆通用限制：未满足条件时拦截进入并返回统一提示。
function Player.ensureSeventhContinentPass(actor, tip)
    local ok, auto_tip = _dl_check(actor, 7)
    if ok then
        return true
    end
    Player.sendmsgEx(actor, ((auto_tip or tip or "请先满足七大陆进入条件后再使用该功能") .. "#57"))
    return false
end
function Player.hasZaiEPrep(actor, npcid)
    local jq_data = Player.getJsonTableByVar(actor, VarCfg.T_dljq)
    local key = "npc_" .. tostring(npcid) .. "_rw"
    return tonumber(jq_data[key] or 0) >= 2
end
--检查 物品 货币 装备是否满足数量(数量不足返回不足物品的名字)
function Player.checkItemNum(actor, t, multiple)
    for _,item in ipairs(t) do
        local idx,num = getstditeminfo(item[1], 0),item[2]
        if multiple then num=num*multiple end
        if Item.isCurrency(idx) then        --货币
            if not Player.checkMoneyNum(actor, idx, num) then
                return false
            end
        else                                    --物品 装备
            if not Bag.checkItemNumByIdx(actor, idx, num) then
                return false
            end
        end
    end
    return true
end
--回收
local fd_sjyb = {[10053] = {500,2000},[10054] = {1000,5000},[10055] = {5000,50000},[10056] = {10000,1000000}}
local hs_auto_gold_items = {
    ["金币(小)"] = {100, 1000},
    ["金币(中)"] = {1000, 10000},
    ["金币(大)"] = {10000, 100000},
    ["金币(超级)"] = {100000, 1000000},
}
local hs_name_hlsj = "辉耀水晶"
local hs_name_lingshi = "幻灵石"
-- 自动回收键匹配：按分组区分，并兼容旧前缀。
local hs_group_prefix = {
    zzhs = "1",
    zsfj = "2",
    sqhs = "3",
    gwfj = "4",
    ssfj = "5",
    clfj = "6",
    teshuhuihsou = "7",
}
local hs_group_prefix_compat = {
    zzhs = "1",
    sqhs = "1",
    zsfj = "2",
    gwfj = "5|2",
    ssfj = "6|2",
    clfj = "7|1",
    teshuhuihsou = "8|1",
}
local hs_default_recycle_keys = {"1_1_1", "1_1_2", "1_1_3", "3_3_1","3_3_2","3_3_3","2_2_1","1_1_4","1_1_5","1_2_1","1_2_2","1_2_3"}
local function hs_map_old_zzhs_key(subgroup)
    subgroup = tonumber(subgroup or 0) or 0
    if subgroup >= 1 and subgroup <= 5 then
        return "1_1_1"
    elseif subgroup >= 6 and subgroup <= 10 then
        return "1_1_2"
    elseif subgroup >= 11 and subgroup <= 15 then
        return "1_1_3"
    elseif subgroup >= 16 and subgroup <= 20 then
        return "1_1_4"
    elseif subgroup >= 21 then
        return "1_1_5"
    end
    return nil
end
-- 自动回收勾选配置迁移：
-- 1. 旧版制式装备 1~22 小组统一折算到新版大陆分组。
-- 2. 默认补齐前三组制式装备与生肖1，避免新旧配置错位。
function Player.ensureRecycleSelectConfig(play)
    local hspz = json2tbl(getplaydef(play, VarCfg.T_hsdg))
    if type(hspz) ~= "table" then
        hspz = {}
    end
    if tonumber(hspz.__hs_group_v2 or 0) == 1 then
        return hspz
    end
    local new_pz = {}
    local has_any_selection = false
    local has_old_zzhs = false
    for key, value in pairs(hspz) do
        if value == 1 then
            local old_subgroup = tostring(key):match("^1_1_(%d+)$")
            if old_subgroup then
                has_old_zzhs = true
                local new_key = hs_map_old_zzhs_key(old_subgroup)
                if new_key then
                    new_pz[new_key] = 1
                    has_any_selection = true
                end
            else
                new_pz[key] = 1
                has_any_selection = true
            end
        end
    end
    if not has_any_selection then
        for _, key in ipairs(hs_default_recycle_keys) do
            new_pz[key] = 1
        end
    else
        if new_pz["3_3_1"] == nil then
            new_pz["3_3_1"] = 1
            new_pz["3_3_2"] = 1
            new_pz["3_3_3"] = 1
            new_pz["2_2_1"] = 1
        end
        if (not has_old_zzhs)
            and new_pz["1_1_1"] == nil and new_pz["1_1_2"] == nil
            and new_pz["1_1_3"] == nil and new_pz["1_1_4"] == nil and new_pz["1_1_5"] == nil then
            new_pz["1_1_1"] = 1
            new_pz["1_1_2"] = 1
            new_pz["1_1_3"] = 1
            new_pz["1_1_4"] = 1
            new_pz["1_1_5"] = 1
        end
    end
    new_pz.__hs_group_v2 = 1
    setplaydef(play, VarCfg.T_hsdg, tbl2json(new_pz))
    return new_pz
end
-- 统一按配置优先级查找物品所属回收组，返回组名和配置。
local function hs_pick_cfg(idx)
    local cfg = huishou.zzhs[idx]
    if cfg then return "zzhs", cfg end
    cfg = huishou.sqhs[idx]
    if cfg then return "sqhs", cfg end
    cfg = huishou.zsfj[idx]
    if cfg then return "zsfj", cfg end
    cfg = huishou.ssfj[idx]
    if cfg then return "ssfj", cfg end
    cfg = huishou.gwfj[idx]
    if cfg then return "gwfj", cfg end
    cfg = huishou.clfj[idx]
    if cfg then return "clfj", cfg end
    cfg = huishou.teshuhuihsou[idx]
    if cfg then return "teshuhuihsou", cfg end
    return nil, nil
end
-- 判定该物品是否命中玩家的自动回收勾选配置。
-- 兼容顺序：精确 idx -> 新分组键 -> 新数字前缀 -> 旧前缀。
local function hs_match_pz(pz, idx, group_name, cfg)
    if pz["" .. idx] then
        return true
    end
    if not cfg then
        return false
    end
    local g1 = cfg[1]
    local g2 = cfg[2]
    if not g1 then
        return false
    end
    -- 新规则：支持 group_name + [1]/[2] 键，精确匹配自动回收配置。
    local key_group_1 = group_name .. "_" .. g1
    local key_group_2 = key_group_1 .. "_" .. g2
    if pz[key_group_1] or pz[key_group_2] then
        return true
    end
    -- 当前数字前缀规则。
    local prefix = hs_group_prefix[group_name]
    if prefix then
        if pz[prefix .. "_" .. g1] or pz[prefix .. "_" .. g1 .. "_" .. g2] then
            return true
        end
    end
    -- 旧前缀兼容兜底（支持多个前缀，例如 "5|2"）。
    local old_prefix = hs_group_prefix_compat[group_name]
    if old_prefix then
        for legacy_prefix in string.gmatch(old_prefix, "[^|]+") do
            if legacy_prefix ~= prefix then
                if pz[legacy_prefix .. "_" .. g1] or pz[legacy_prefix .. "_" .. g1 .. "_" .. g2] then
                    return true
                end
            end
        end
    end
    return false
end
local function hs_add_item_reward(reward, item_name, item_num)
    item_num = tonumber(item_num) or 0
    if item_num <= 0 or type(item_name) ~= "string" or item_name == "" then
        return
    end
    -- 旧回收材料统一折算为 5 个辉耀水晶。
    if item_name == hs_name_lingshi then
        item_name = hs_name_hlsj
        item_num = item_num * 5
    end
    if item_name == hs_name_lingshi then
        reward.lingshi = reward.lingshi + item_num
    elseif item_name == hs_name_hlsj then
        reward.hlsj = reward.hlsj + item_num
    else
        reward.items[item_name] = (reward.items[item_name] or 0) + item_num
    end
end
local function hs_get_zsfj_material_name(cfg)
    local direct_name = type(cfg[6]) == "string" and cfg[6] or nil
    if direct_name and direct_name ~= "" then
        return direct_name
    end
    -- zsfj 标记位：field5 表示辉耀水晶，field6 表示灵石。
    local flag_hlsj = tonumber(cfg[5]) or 0
    local flag_lingshi = tonumber(cfg[6]) or 0
    if flag_hlsj > 0 then
        return hs_name_hlsj
    end
    if flag_lingshi > 0 then
        return hs_name_lingshi
    end
    return nil
end
-- 按分组把回收产出累计到 reward，最后一次性发放。
local function hs_collect_reward(reward, group_name, idx, cfg)
    if not cfg then
        return
    end
    local v4 = tonumber(cfg[4]) or 0
    local v5 = tonumber(cfg[5]) or 0
    if group_name == "zzhs" or group_name == "sqhs" or group_name == "clfj" or group_name == "teshuhuihsou" then
        reward.coin = reward.coin + v4
        reward.yb = reward.yb + v5
    elseif group_name == "zsfj" then
        local material_name = hs_get_zsfj_material_name(cfg)
        if material_name then
            hs_add_item_reward(reward, material_name, v4)
        end
    elseif group_name == "ssfj" or group_name == "gwfj" then
        local material_name = type(cfg[6]) == "string" and cfg[6] or hs_name_lingshi
        hs_add_item_reward(reward, material_name, v4)
    end
end
-- 将累计奖励统一结算到玩家，减少重复调用和提示。
local function hs_apply_reward(play, reward, gz)
    if reward.coin > 0 then
        local coin = reward.coin + math.floor(reward.coin * getbaseinfo(play, 51, 204) / 10000)
        changemoney(play, getflagstatus(play, VarCfg.BS_mztq) == 1 and 1 or 3, '+', coin, '回收获得', true)
    end
    if reward.yb > 0 then
        local yb = reward.yb + math.floor(reward.yb * getbaseinfo(play, 51, 205) / 10000)
        changemoney(play, getflagstatus(play, VarCfg.BS_mztq) == 1 and 2 or 4, '+', yb, '回收获得', true)
    end
    if reward.lingshi > 0 then
        changemoney(play, getflagstatus(play, VarCfg.BS_mztq) == 1 and 7 or 8, '+', reward.lingshi, '回收获得', true)
    end
    if reward.hlsj > 0 then
        giveitem(play, hs_name_hlsj, reward.hlsj, gz)
    end
    for item_name, item_num in pairs(reward.items) do
        if item_num > 0 then
            giveitem(play, item_name, item_num, gz)
        end
    end
end
local function hs_auto_use_gold_items(play)
    if getflagstatus(play, VarCfg.BS_huishou[2]) ~= 1 then
        return
    end
    local total = 0
    for item_name, range in pairs(hs_auto_gold_items) do
        local list = getbagitems(play, item_name)
        if type(list) == "table" then
            for _, item_obj in ipairs(list) do
                if item_obj and item_obj ~= "0" then
                    local item_num = tonumber(getiteminfo(play, item_obj, 5) or 0) or 0
                    if item_num <= 0 then
                        item_num = 1
                    end
                    if delitembymakeindex(play, getiteminfo(play, item_obj, 1), item_num) then
                        for _ = 1, item_num do
                            total = total + math.random(range[1], range[2])
                        end
                    end
                end
            end
        end
    end
    if total > 0 then
        changemoney(play, getflagstatus(play, VarCfg.BS_mztq) == 1 and 1 or 3, '+', total, '回收自动吃金币', true)
    end
end
function Player.huishou(play, hs_constant)
    if hs_constant == nil then
        -- 模式1：全背包自动回收（由开关控制）。
        local kg1, kg2, kg3, kg4, kg5 = getflagstatus(play, VarCfg.BS_huishou[1]), getflagstatus(play, VarCfg.BS_huishou[2]), getflagstatus(play, VarCfg.BS_huishou[3]), getflagstatus(play, VarCfg.BS_huishou[4]), getflagstatus(play, VarCfg.BS_huishou[5])
        local pz = Player.ensureRecycleSelectConfig(play) or {}
        local reward = {coin = 0, yb = 0, lingshi = 0, hlsj = 0, items = {}}
        local sq = ''
        local item = getbagitems(play)
        for i, v in pairs(item or {}) do
            local idx = getiteminfo(play, v, 2)
            if idx > 10045 and idx <= 10063 then    --yuanbao
                if kg1 == 1 then
                    local sl = getiteminfo(play, v, 5)
                    changemoney(play, getflagstatus(play,VarCfg.BS_mztq) == 1 and 2 or 4, '+', getstditeminfo(idx, 8) * sl, '机器人吃', true)
                    delitembymakeindex(play, getiteminfo(play, v, 1), sl)
                end
            elseif idx > 10022 and idx <= 10035 then    --jinbi
                if kg2 == 1 then
                    if fd_sjyb[idx] then
                        local sl = getiteminfo(play, v, 5)
                        delitembymakeindex(play, getiteminfo(play, v, 1), sl)
                        for i = 1, sl, 1 do
                            changemoney(play, getflagstatus(play,VarCfg.BS_mztq) == 1 and 1 or 3, '+', math.random(fd_sjyb[idx][1], fd_sjyb[idx][2]), '机器人吃', true)
                        end
                    end
                end
            elseif idx > 10006 and idx <= 10021 then    --exp
                -- 注意：当前代码仅在 kg3 == 3 时生效（保持现有行为）。
                if kg3 == 3 and Player.canGainRoleLevel(play, false) then
                    local sl = getiteminfo(play, v, 5)
                    local useCount = 0
                    local addExp = getstditeminfo(idx, 8)
                    for i = 1, sl do
                        if not Player.canGainRoleLevel(play, false) then
                            break
                        end
                        changeexp(play, '+', addExp, false)
                        Player.clampRoleLevel(play, false)
                        useCount = useCount + 1
                    end
                    if useCount > 0 then
                        delitembymakeindex(play, getiteminfo(play, v, 1), useCount)
                    end
                end
            else
                -- 普通回收：命中开关+配置后，先记录 makeindex，最后批量删除。
                if kg4 == 1 then
                    local group_name, cfg = hs_pick_cfg(idx)
                    if cfg and hs_match_pz(pz, idx, group_name, cfg) then
                        sq = sq .. getiteminfo(play, v, 1) .. ','
                        hs_collect_reward(reward, group_name, idx, cfg)
                    end
                end
            end
        end
        if sq ~= '' then
            delitembymakeindex(play, sq)
            -- 魔族特权开启时使用非绑定渠道；否则走绑定奖励渠道。
            local gz = getflagstatus(play,VarCfg.BS_mztq) == 1 and 0 or 850
            hs_apply_reward(play, reward, gz)
            Login_msg(play,10,reward.coin,reward.yb)
        end
        hs_auto_use_gold_items(play)
    else
        -- 模式2：按传入 makeindex 列表进行定向回收/销毁。
        local hs = hs_constant
        local reward = {coin = 0, yb = 0, lingshi = 0, hlsj = 0, items = {}}
        local gz = getflagstatus(play,VarCfg.BS_mztq) == 1 and 0 or 850
        for k, v in pairs(hs) do
            local wp = getitembymakeindex(play,v)
            if wp then
                local idx = getiteminfo(play,wp,2)
                if huishou.kexiaohui and huishou.kexiaohui[idx] then
                    -- 可销毁物品：直接删除，不产生回收奖励。
                    delitembymakeindex(play,v,1)
                else
                    -- 可回收物品：删除成功后累计奖励。
                    local group_name, cfg = hs_pick_cfg(idx)
                    if cfg and delitembymakeindex(play,v,1) then
                        hs_collect_reward(reward, group_name, idx, cfg)
                    end
                end
            end
        end
        hs_apply_reward(play, reward, gz)
        Login_msg(play,10,reward.coin,reward.yb)
        hs_auto_use_gold_items(play)
    end
end
function Player.addteshuhuihsou(play, t)
    local T_tshs = json2tbl(getplaydef(play, VarCfg.T_tshs))
    local hspz = json2tbl(getplaydef(play,VarCfg.T_hsdg))
    for _,item in ipairs(t) do
        local idx = getstditeminfo(item[1], 0)
        if huishou.teshuhuihsou[idx] and not T_tshs[""..idx] then
            T_tshs[""..idx] = true
        end
        hspz[""..idx] = 1
    end
    setplaydef(play, VarCfg.T_tshs, tbl2json(T_tshs))
    setplaydef(play,VarCfg.T_hsdg,tbl2json(hspz))
end
-----------自定义属性相关---------
--增加修改自定义属性
---* actor：个人对象
---* itemobj：物品对象
---* group：属性分组
---* attrIndex：属性位置和索引
---* attrType：属性类型 1为cfg_att_score里面的属性 其他为cfg_custpro_caption属性
---* attrColor：属性颜色
---* realAttrId：真实属性
---* attrId：属性ID当attrType不为1时，为显示属性
---* isAttrPercent：属性是否为百分比（0不是百分比，1百分比）
---* attrValue：属性值
---@param actor any
---@param itemobj any
---@param group number?
---@param attrIndex number
---@param attrType number?
---@param attrColor number?
---@param realAttrId number
---@param attrId number
---@param isAttrPercent number
---@param attrValue number?
function Player.addModifyCustomAttributes(actor, itemobj, group, attrIndex, attrType, attrColor, realAttrId, attrId,
                                          isAttrPercent, attrValue)
    if itemobj == nil then return end
    attrColor = attrColor or 255
    if attrType == 1 then
        changecustomitemabil(actor, itemobj, attrIndex, 0, attrColor, group)
        changecustomitemabil(actor, itemobj, attrIndex, 1, realAttrId, group)
    else
        -- release_print(realAttrId, attrId)
        changecustomitemabil(actor, itemobj, attrIndex, 0, attrColor, group)
        changecustomitemabil(actor, itemobj, attrIndex, 1, realAttrId, group)
        changecustomitemabil(actor, itemobj, attrIndex, 2, attrId, group)
    end
    changecustomitemabil(actor, itemobj, attrIndex, 3, isAttrPercent, group)
    changecustomitemabil(actor, itemobj, attrIndex, 4, attrIndex, group)
    changecustomitemvalue(actor, itemobj, attrIndex, "=", attrValue, group)
    refreshitem(actor, itemobj)
end
--获取自定义属性值
function Player.getModifyCustomAttributes(actor, equipObj, index, childIndex)
    local t = json2tbl(getitemcustomabil(actor, equipObj))
    if not t then
        return 0
    end
    if not t["abil"] then
        return 0
    end
    if not t["abil"][index] then
        return 0
    end
    if not t["abil"][index]["v"] then
        return 0
    end
    if not t["abil"][index]["v"][childIndex] then
        return 0
    end
    return t["abil"][index]["v"][childIndex][3] or 0
end
--获取全部自定义属性值
function Player.getAllModifyCustomAttributes(actor, equipObj, index)
    local t = json2tbl(getitemcustomabil(actor, equipObj))
    if not t then
        return 0
    end
    if not t["abil"] then
        return 0
    end
    if not t["abil"][index] then
        return 0
    end
    local attrList = t["abil"][index]["v"]
    if not attrList then
        return 0
    end
    local result = {}
    for _, value in ipairs(attrList) do
        result[value[7]] = value[3]
    end
    return result
end
--获取数学组属性到字符串
function Player.getAttListToTable(actor, str)
    if not str or str == "" then
        return
    end
    local attStr = getattlist(actor, str)
    if not attStr or attStr == "" then
        return
    end
    local t = string.split(attStr, "|")
    local newt = {}
    for _, value in ipairs(t or {}) do
        local tmpT = string.split(value, "#")
        if #tmpT == 3 then
            newt[tonumber(tmpT[2])] = tonumber(tmpT[3])
        end
    end
    return newt
end
--数组属性变为字符串
function Player.getAttrTableToStr(attrs)
    local attrStr = ""
    local attrList = {}
    --计算切割加成
    for key, value in pairs(attrs) do
        table.insert(attrList, "3#" .. key .. "#" .. math.floor(value))
    end
    attrStr = table.concat(attrList, "|")
    return attrStr
end
--获取装备位idx
function Player.getEquipIdxByPos(actor, pos)
    local itemobj = linkbodyitem(actor, pos)
    if itemobj == "0" then return end
    local idx = getiteminfo(actor, itemobj, ConstCfg.iteminfo.idx)
    return idx
end
--通过位置获取装备名字
function Player.getEquipNameByPos(actor, pos)
    local itemobj = linkbodyitem(actor, pos)
    if itemobj == "0" then return end
    local name = getiteminfo(actor, itemobj, ConstCfg.iteminfo.name)
    return name
end
--通过位置获取字段
function Player.getEquipFieldByPos(actor, pos, type)
    local name = Player.getEquipNameByPos(actor, pos)
    if name then
        local field
        if type == 1 then
            field = getstditeminfo(name, ConstCfg.stditeminfo.custom29)
        elseif type == 2 then
            field = getstditeminfo(name, ConstCfg.stditeminfo.custom30)
        else
            field = getstditeminfo(name, ConstCfg.stditeminfo.custom29)
        end
        return field
    end
end
--统计背包神器位当前已穿戴的数量
function Player.countArtifactEquipSlots(actor)
    local n = 0
    for i = 77, 88 do
        local itemobj = linkbodyitem(actor, i)
        if itemobj and itemobj ~= "0" then
            n = n + 1
        end
    end
    return n
end
--查询背包神器位是否有对应装备
function Player.hasEquipInArtifactSlot(actor, itemname)
    for i = 77, 88 do
        local itemobj = linkbodyitem(actor, i)
        if itemobj and itemobj ~= "0" then
            local name = getiteminfo(actor, itemobj, ConstCfg.iteminfo.name)
            if name == itemname then
                return i
            end
        end
    end
    return nil
end
-- 检查指定装备位是否穿戴了某件装备。
function Player.hasEquipOnPos(actor, pos, itemname)
    if not actor or not pos or not itemname or itemname == "" then
        return false
    end
    local name = Player.getEquipNameByPos(actor, pos)
    return name == itemname
end

-- 登录预留：当前不再做人物等级封顶，仅保留函数壳避免旧事件报错。
local function _player_level_cap_on_login(actor)
    return
end

-- 升级预留：当前不再拦截非经验丹的升级来源。
local function _player_level_cap_on_level(actor, curLevel)
    return
end

GameEvent.add(EventCfg.onLogin, _player_level_cap_on_login, "角色等级上限")
GameEvent.add(EventCfg.onKFLogin, _player_level_cap_on_login, "角色等级上限")
GameEvent.add(EventCfg.onPlayLevelUp, _player_level_cap_on_level, "角色等级上限")

return Player
