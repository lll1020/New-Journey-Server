---设置怪物临时int变量
---@param actor string 玩家对象
---@param mapID number 地图ID
---@param x number X坐标
---@param y number Y坐标
---@param range number 范围
---@param where number 怪物临时变量位置(1~5)
---@param value number 怪物临时变量值
function setmonintvar(actor,mapID,x,y,range,where,value)
    x = tonumber(x) or 0
    y = tonumber(y) or 0
    where = tonumber(where) or 0
    value = tonumber(value) or 0
    local mons = getobjectinmap(mapID,x,y,range,2)
    for i, mon in ipairs(mons or {}) do
        setobjintvar(mon,where,value)
        release_print("setmonstrvar",getbaseinfo(mon,1),where,getobjintvar(mon,where))
    end
end

---获取怪物临时int变量
---@param actor string 玩家对象
---@param monMakeIndex number 怪物唯一id
---@param where number 怪物临时变量位置(1~5)
function getmonintvar(actor,monMakeIndex,where)
    where = tonumber(where) or 0
    local mapID = getbaseinfo(actor,3)
    local mon = getmonbyuserid(mapID,monMakeIndex)
    if mon ~= "0" then
        return getobjintvar(mon,where)
    end
    return "nil"
end

---设置怪物临时str变量
---@param actor string 玩家对象
---@param mapID number 地图ID
---@param x number X坐标
---@param y number Y坐标
---@param range number 范围
---@param where number 怪物临时变量位置(1~5)
---@param value number 怪物临时变量值
function setmonstrvar(actor,mapID,x,y,range,where,value)
    x = tonumber(x) or 0
    y = tonumber(y) or 0
    where = tonumber(where) or 0
    local mons = getobjectinmap(mapID,x,y,range,2)
    for i, mon in ipairs(mons or {}) do
        setobjstrvar(mon,where,value)
        release_print("setmonstrvar",getbaseinfo(mon,1),where,getobjstrvar(mon,where))
    end
end

---获取怪物临时str变量
---@param actor string 玩家对象
---@param monMakeIndex number 怪物唯一id
---@param where number 怪物临时变量位置(1~5)
function getmonstrvar(actor,monMakeIndex,where)
    where = tonumber(where) or 0
    local mapID = getbaseinfo(actor,3)
    local mon = getmonbyuserid(mapID,monMakeIndex)
    if mon ~= "0" then
        return getobjstrvar(mon,where)
    end
    return "nil"
end