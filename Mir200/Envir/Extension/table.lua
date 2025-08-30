--[[
    函数名: table.isempty
    功能: 检查给定的表是否为空
    参数:
      - t (table): 要检查的表
    返回:
      - (boolean): 如果表为空则返回 true，否则返回 false
    说明:
      - 此函数使用 Lua 的内置函数 `next()` 来判断表是否为空。`next()` 会返回表中的第一个键值对。
      - 如果表中没有元素，`next()` 会返回 nil，函数返回 true。
]]
--- 检查表是否为空
--- @param t table 需要检查的表
--- @return boolean 如果表为空，返回 true；否则返回 false
function table.isempty(t)
    return next(t) == nil
end

--查询表数量
function table.nums(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

function table.keys(hashtable)
    local keys = {}
    for k, v in pairs(hashtable) do
        keys[#keys + 1] = k
    end
    return keys
end
    
function table.values(hashtable)
    local values = {}
    for k, v in pairs(hashtable) do
        values[#values + 1] = v
    end
    return values
end

function table.merge(dest, src)
    for k, v in pairs(src) do
        dest[k] = v
    end
end

--- 将第二个数组附加到第一个数组并返回一个新数组
-- @param array1 table 第一个数组
-- @param array2 table 第二个数组
-- @return table 附加后的新数组
function table.appendArray(array1, array2)
    local result = {}
    -- 将第一个数组的元素复制到结果数组
    for i = 1, #array1 do
        result[i] = array1[i]
    end
    -- 将第二个数组的元素追加到结果数组
    for i = 1, #array2 do
        result[#array1 + i] = array2[i]
    end
    return result
end


function table.insertto(dest, src, begin)
    begin = begin or 0
    if begin <= 0 then
        begin = #dest + 1
    end

    local len = #src
    for i = 0, len - 1 do
        dest[i + begin] = src[i + 1]
    end
end

function table.indexof(array, value, begin)
    for i = begin or 1, #array do
        if array[i] == value then return i end
    end
    return false
end

function table.keyof(hashtable, value)
    for k, v in pairs(hashtable) do
        if v == value then return k end
    end
    return nil
end

function table.removebyvalue(array, value, removeall)
    local c, i, max = 0, 1, #array
    while i <= max do
        if array[i] == value then
            table.remove(array, i)
            c = c + 1
            i = i - 1
            max = max - 1
            if not removeall then break end
        end
        i = i + 1
    end
    return c
end

function table.map(t, fn)
    for k, v in pairs(t) do
        t[k] = fn(v, k)
    end
end

function table.walk(t, fn)
    for k,v in pairs(t) do
        fn(v, k)
    end
end

function table.filter(t, fn)
    for k, v in pairs(t) do
        if not fn(v, k) then t[k] = nil end
    end
end
--删除重复的值
function table.unique(t, bArray)
    local check = {}
    local n = {}
    local idx = 1
    for k, v in pairs(t) do
        if not check[v] then
            if bArray then
                n[idx] = v
                idx = idx + 1
            else
                n[k] = v
            end
            check[v] = true
        end
    end
    return n
end

--删除重复的数组
function table.uniqueArray(t)
    if not t or #t == 0 then
        return
    end
    local seen = {}
    local len = #t
    local idx = 1

    for i = 1, len do
        local v = t[i]
        if not seen[v] then
            seen[v] = true
            t[idx] = v
            idx = idx + 1
        end
    end

    -- 清除多余的元素
    for i = idx, len do
        t[i] = nil
    end
end

function table.findtbykv(t, key, value)
    for _,v in pairs(t) do
        if v[key] == value then
            return v
        end
    end
end

function table.findarrvalue(t, fn, reverse)
    local size = #t
    local begin = reverse and size or 1
    local toend = reverse and 1 or size
    local change = reverse and -1 or 1

    local result
    for i=begin,toend,change do
        result = fn(t[i], i)
        if result then return result end
    end
end

function table.arrequal(arr1, arr2)
    local size1, size2 = #arr1, #arr2
    if size1 ~= size2 then return false end

    for k,v1 in ipairs(arr1) do
        local v2 = arr2[k]
        if v1 ~= v2 then return false end
    end

    return true
end

--查找数组是否包含某个元素
---* array：要查找的数组
---* element：要查找的元素
function table.contains(array, element)
    for _, value in ipairs(array) do
        if value == element then
            return true
        end
    end
    return false
end


--[[
    函数名: table.random
    功能: 从数组中随机返回一个元素。
    参数:
      - t (table): 要选择的数组。
    返回:
      - (any): 随机选中的元素。
    说明:
      - 如果数组为空，返回 `nil`。
]]
--- 从数组中随机返回一个元素
--- @param t table 要选择的数组
--- @return any 返回随机选中的元素
function table.random(t)
    if #t == 0 then return nil end
    local index = math.random(1, #t)
    return t[index]
end

--- 洗牌算法，打乱数组顺序
---@param array table 需要打乱的数组
function table.shuffle(array)
    local n = #array
    for i = n, 2, -1 do
        local j = math.random(1, i)
        array[i], array[j] = array[j], array[i]
    end
end