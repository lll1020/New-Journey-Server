--[[
工具库
]]
--判断成功率:如果成功返回false
--suc_rate:成功率
--ratio:比率
--return:返回true没成功
function FProbabilityHit(suc_rate, ratio)
    ratio = ratio or 100
    local rate = math.random(1, ratio)
    return rate > suc_rate
end

--检查一个对象的范围
function UCheckRange(x, y, range, obj)
    local min_x, max_x = x - range, x + range
    local min_y, max_y = y - range, y + range
    local cur_x, cur_y = getbaseinfo(obj, ConstCfg.gbase.x), getbaseinfo(obj, ConstCfg.gbase.y)

    if (cur_x >= min_x) and (cur_x <= max_x) and
        (cur_y >= min_y) and (cur_y <= max_y) then
        return true
    end

    return false
end

--检查自己与npc的距离
function UCheckNPCRange(actor, moduleid, npcidx, range)
    range = range or 10
    local npcobj = getnpcbyindex(npcidx)
    local npc_mapid = getbaseinfo(npcobj, ConstCfg.gbase.mapid)
    local my_mapid = getbaseinfo(actor, ConstCfg.gbase.mapid)
    if npc_mapid ~= my_mapid then return false end

    local npc_x = getbaseinfo(npcobj, ConstCfg.gbase.x)
    local npc_y = getbaseinfo(npcobj, ConstCfg.gbase.y)
    return UCheckRange(npc_x, npc_y, range, actor)
end

--回城

--飞地图固定随机点
function FMapMove(actor, mapid, x, y, x_ran, y_ran)
    if type(mapid) ~= "string" then mapid = mapid .. "" end
    if x and y then
        if x_ran then x = math.random(x - x_ran, x + x_ran) end
        if y_ran then y = math.random(y - y_ran, y + y_ran) end
        mapmove(actor, mapid, x, y)
    else
        map(actor, mapid)
    end
end

--发送全服顶部弹出公告
--默认底色绿色
function FSendMsgNew(actor, msg)
    sendmsgnew(actor, 250, 0, msg, 1, 3)
end

--发送邮件
function FSendmail(sender, id, ...)
    local cfg = cfg_mail[id]
    if not cfg then return end

    --邮件内容
    local content
    if cfg.content then
        if cfg.parameter then
            content = string.format(cfg.content, ...)
        else
            content = cfg.content
        end
    end

    --邮件物品
    local stritem
    if cfg.items then
        if type(cfg.items) == "table" then
            local items
            for _, item in ipairs(cfg.items) do
                if type(item) == "table" then
                    items = items or {}
                    if item[3] == 1 then item[3] = ConstCfg.binding end
                    table.insert(items, table.concat(item, "#"))
                else
                    stritem = table.concat(cfg.items, "&")
                    break
                end
            end

            if items then stritem = table.concat(items, "&") end
        else
            stritem = cfg.items .. "#1"
        end
    end
    --发送
    sendmail(sender, 1, cfg.title, content, stritem)
end

--发送邮件2
function _Fsendmail(name, id, reward, ...)
    local cfg = cfg_mail[id]
    if not cfg then return end
    --邮件内容
    local content
    if cfg.content then
        if cfg.parameter then
            content = string.format(cfg.content, ...)
        else
            content = cfg.content
        end
    end
    local stritem
    --邮件物品
    if reward then
        if type(reward) == "table" then
            local items
            for _, item in ipairs(reward) do
                if type(item) == "table" then
                    items = items or {}
                    if item[3] == 1 then item[3] = ConstCfg.binding end
                    table.insert(items, table.concat(item, "#"))
                else
                    stritem = table.concat(reward, "&")
                    break
                end
            end

            if items then stritem = table.concat(items, "&") end
        else
            stritem = reward .. "#1"
        end
    end
    sendmail("#" .. name, 1, cfg.title, content, stritem)
end

--深拷贝
---* object：拷贝对象
function clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

function getRanomByWeight(t, weights)
    local sum = 0
    for i = 1, #weights do
        sum = sum + weights[i]
    end
    local compareWeight = math.random(1, sum)
    local weightIndex = 1
    while sum > 0 do
        sum = sum - weights[weightIndex]
        if sum < compareWeight then
            return t[weightIndex]
        end
        weightIndex = weightIndex + 1
    end
    return weightIndex
end

--秒转时分秒  100 = 00:01:40
function ssrSecToHMS(sec)
    sec = sec or 0

    local h, m, s = 0, 0, 0
    if sec > 3600 then
        h = math.floor(sec / 3600)
    end
    sec = sec % 3600
    if sec > 60 then
        m = math.floor(sec / 60)
    end
    s = sec % 60

    return string.format("%02d:%02d:%02d", h, m, s)
end

--时间转换
function getTodayTimeStamp(hour, min, sec)
    local cDateCurrectTime = os.date("*t")
    local cDateTodayTime = os.time({ year = cDateCurrectTime.year, month = cDateCurrectTime.month, day = cDateCurrectTime
    .day, hour = hour, min = min, sec = sec })
    return cDateTodayTime
end

--将996键值对格式转换成table
function parseStringToTable(str)
    local t = {}
    for key, value in string.gmatch(str, "([^,=]+)=([^,=]+)") do
        t[key] = value
    end
    return t
end

--位与运算
function BitAND(a, b)
    local p, c = 1, 0
    while a > 0 and b > 0 do
        local ra, rb = a % 2, b % 2
        if ra + rb > 1 then c = c + p end
        a, b, p = (a - ra) / 2, (b - rb) / 2, p * 2
    end
    return c
end

--使用字符串比较
function compareValues(value1, operator, value2)
    if operator == ">" then
        return value1 > value2
    elseif operator == "<" then
        return value1 < value2
    elseif operator == ">=" then
        return value1 >= value2
    elseif operator == "<=" then
        return value1 <= value2
    elseif operator == "==" then
        return value1 == value2
    elseif operator == "~=" then
        return value1 ~= value2
    else
        return false
    end
end

function dump(t)
    release_print(tbl2json(t))
end

--把物品数组转换成发送邮件的格式
---imemTable:物品数组
---@return string
function itemToMailStr(itemTable)
    if type(itemTable) ~= "table" then
        return
    end
    local itemList = {}
    for index, value in ipairs(itemTable) do
        if type(value) ~= "table" then
            return
        end
        table.insert(itemList, table.concat(value, "#"))
    end
    local str = table.concat(itemList, "&")
    return str
end

--判断都是在某个时间之间，支持夸午夜
---* startHour: 开始小时
---* startMinute: 开始分钟
---* endHour: 结束小时
---* endMinute: 结束分钟
function isTimeInRange(startHour, startMinute, endHour, endMinute)
    local now = os.date("*t") -- 获取当前时间的表格形式
    local startTime = os.time({ year = now.year, month = now.month, day = now.day, hour = startHour, min = startMinute })
    local endTime = os.time({ year = now.year, month = now.month, day = now.day, hour = endHour, min = endMinute })
    local currentTime = os.time(now)

    -- 如果结束时间小于开始时间，则说明跨越了午夜
    if endTime < startTime then
        endTime = os.time({ year = now.year, month = now.month, day = now.day + 1, hour = endHour, min = endMinute })
    end

    return currentTime >= startTime and currentTime <= endTime
end


--获取到凌晨的秒数
function GetReaminSecondsTo24()
	local toYear=os.date("*t").year
	local toMonth=os.date("*t").month
	local toDay=os.date("*t").day
	local toTime = os.time({year =toYear, month = toMonth, day =toDay, hour =23, min =59, sec = 59})
	local time=os.time()
	return toTime-time+1
end

-- 获取到 21:00 的剩余秒数，如果过了 21:00 返回 0
function GetSecondsUntil21()
    local current_time = os.time()
    -- 获取今天 21:00 的时间戳
    local current_date = os.date("*t", current_time)
    current_date.hour = 21
    current_date.min = 0
    current_date.sec = 0
    local target_time = os.time(current_date)
    local remaining_seconds = target_time - current_time
    if remaining_seconds < 0 then
        remaining_seconds = 0
    end
    return remaining_seconds
end

--成功率
---successRate：成功率（分子）
---range：范围(分母)
function randomex(successRate, range)
    range = range or 100
    local randomNumber = math.random(1, range)
    if randomNumber <= successRate then
        return true
    else
        return false
    end
end

--计算百分比具体数值
function calculatePercentageResult(total, num)
    if total == 0 then
        return 0
    end
    local value = (num / 100) * total
    return math.floor(value + 0.5) -- 四舍五入
end

--计算百分比值
---* numerator：分子
---* denominator：分母
function calculatePercentage(numerator, denominator)
    if denominator == 0 then
        return 0
    end
    local percentage = (numerator / denominator) * 100
    return percentage
end

--将一个数字拆分为多个部分
---* limit：拆分上限
---* num：拆分数字
--- @param limit integer
--- @param num integer
--- @return any
function splitLargeNumber(limit, num)
    if limit == nil or num == nil or limit == 0 or num == 0 then
        return
    end
    local parts = {}
    while num > limit do
        table.insert(parts, limit)
        num = num - limit
    end
    if num > 0 then
        table.insert(parts, num)
    end
    return parts
end

--把键值对拼接成字符串
function concatenateKeyValuePairs(tbl)
    local result = {}
    for key, value in pairs(tbl) do
        table.insert(result, key .. "=" .. tostring(value))
    end
    return table.concat(result, ", ")
end

--计算累加属性
function calcAtts(attrs, currAttrs, desc)
    -- release_print(desc,concatenateKeyValuePairs(currAttrs))
    for key, value in pairs(currAttrs) do
        if attrs[key] then
            attrs[key] = attrs[key] + value
        else
            attrs[key] = value
        end
    end
end

--属性合并
function attsMerge(currAtt,attrs)
    for index, value in pairs(currAtt) do
        if not attrs[index] then
            attrs[index] = value
        else
            attrs[index] = attrs[index] + value
        end
    end
end

--查找数组中最小的值
function findMinValue(array)
    if #array == 0 then
        return nil
    end
    return math.min(unpack(array))
end

-- 判断当前时间是否在指定时间段内
---* sethour_1：起始小时
---* setmin_1：起始分钟
---* sethour_2：结束小时
---* setmin_2：结束分钟(不得大于59分)
function checktimeInPeriod(sethour_1, setmin_1, sethour_2, setmin_2)
    local current_time = os.date("*t") -- 获取当前时间
    local hour = current_time.hour     -- 当前小时
    local min = current_time.min       -- 当前分钟
    -- 判断当前时间是否在指定范围内
    if (hour > sethour_1) or (hour == sethour_1 and min >= setmin_1) or (hour < sethour_2) or (hour == sethour_2 and min < setmin_2) then
        return true
    else
        return false
    end
end

--生成一个排除数组里面的随机数
---* exclude:排除的数组
---* upperNum:排除的上限是数字
---@param exclude table
---@param upperNum number
---@return number|boolean
function generateRandomExclude(exclude, upperNum)
    if #exclude >= upperNum then
        return false
    end
    local randomNum
    local found
    repeat
        randomNum = math.random(upperNum)
        found = false
        for _, v in ipairs(exclude) do
            if v == randomNum then
                found = true
                break
            end
        end
    until not found
    return randomNum
end


-- 用于计算 GBK 字符串的字符数量
function GbkLength(str)
    local len = 0
    local i = 1

    while i <= #str do
        local charByte = string.byte(str, i)

        if charByte > 0 and charByte <= 127 then
            -- 单字节字符（ASCII 字符）
            i = i + 1
        else
            -- 双字节字符（GBK 汉字）
            i = i + 2
        end

        len = len + 1
    end

    return len
end


-- 定义一个函数，用于生成浮动结果
function getRandomDifference(baseNumber)
    -- 设置浮动范围
    local minRange = 0.9
    local maxRange = 1.2
    
    -- 生成随机数
    local randomFactor = math.random() * (maxRange - minRange) + minRange
    
    -- 计算浮动结果
    local result = baseNumber * randomFactor
    
    -- 计算差值
    local difference = result - baseNumber
    
    -- 四舍五入浮动结果和差值为整数
    local roundedResult = math.floor(result + 0.5)
    local roundedDifference = math.floor(difference + 0.5)
    
    return roundedResult, roundedDifference
end
--物品数组转成物品*数量字符
function getItemArrToStr(items)
    local itemStrArray = {}
    for _, value in ipairs(items) do
        local tmpStr = table.concat(value, "*")
        table.insert(itemStrArray, tmpStr)
    end
    local msgStr = table.concat(itemStrArray, ",")
    return msgStr
end
--Lua 数字换算中文数字
function formatNumberToChinese(num)
    local chineseNum = {"零", "一", "二", "三", "四", "五", "六", "七", "八", "九"}
    local units = {"", "十", "百", "千", "万"}

    if num == 0 then
        return chineseNum[1]
    end

    local numStr = tostring(num)
    local numLen = #numStr
    local result = {}
    local lastDigitZero = false

    for i = 1, numLen do
        local digit = tonumber(string.sub(numStr, i, i))
        local unitIndex = numLen - i + 1
        local unit = units[unitIndex]

        if digit ~= 0 then
            if lastDigitZero then
                table.insert(result, chineseNum[1])  -- 添加“零”
                lastDigitZero = false
            end
            table.insert(result, chineseNum[digit + 1])  -- 添加数字
            if unit ~= "" then
                table.insert(result, unit)  -- 添加单位
            end
        else
            lastDigitZero = true
        end
    end

    -- 移除结果末尾的“零”
    if result[#result] == chineseNum[1] then
        table.remove(result)
    end

    -- 处理特殊情况：当结果以"一十"开头时，去除前面的"一"
    if result[1] == "一" and result[2] == "十" then
        table.remove(result, 1)
    end

    local resultStr = table.concat(result)

    return resultStr
end


-- 计算当天剩余秒数的函数
function getSecondsLeftInDay()
    -- 获取当前时间戳
    local current_time = os.time()

    -- 获取当前日期的信息
    local date_info = os.date("*t")

    -- 构造当天午夜 00:00:00 的时间戳
    local midnight_today = os.time({
        year = date_info.year,
        month = date_info.month,
        day = date_info.day,
        hour = 0,
        min = 0,
        sec = 0
    })

    -- 构造第二天午夜 00:00:00 的时间戳
    local midnight_tomorrow = midnight_today + 24 * 60 * 60

    -- 计算当天剩余的秒数
    local seconds_left = midnight_tomorrow - current_time

    return seconds_left
end


function GetCurrentDateAsNumber()
    return tonumber(os.date("%Y%m%d"))
end

--四舍五入
function numberRound(num)
    local decimal = num % 1 -- 获取小数部分
    if decimal >= 0.5 then
        return math.ceil(num)
    else
        return math.floor(num)
    end
end

--计算天数差
function getDaysDiff(startDate, endDate)
    local sy = math.floor(startDate / 10000)
    local sm = math.floor((startDate % 10000) / 100)
    local sd = startDate % 100
    local ey = math.floor(endDate / 10000)
    local em = math.floor((endDate % 10000) / 100)
    local ed = endDate % 100
    local startTime = os.time({year = sy, month = sm, day = sd})
    local endTime = os.time({year = ey, month = em, day = ed})
    return math.floor((endTime - startTime) / (24 * 60 * 60))
end