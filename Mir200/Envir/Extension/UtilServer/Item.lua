Item = {}

--检查idx是否是货币
function Item.isCurrency(idx)
    local stdmode = getstditeminfo(idx, 2)
    return stdmode == 41
end

--获取idx通过where
function Item.getIdxByWhere(actor, where)
    local equipobj = linkbodyitem(actor, where)
    if equipobj == "0" then return end
    return getiteminfo(actor, equipobj, 2)
end

--获取物品Idx通过物品名字
---comment
---@param name any
---@return integer
function Item.getIdxByName(name)
    return getstditeminfo(name,0)--[[@as integer]] or 0
end

--根据位置获取装备自定义属性的属性值
---*  actor : 个人对象
---*  pos : 位置
---*  customAttrIndex : 自定义属性索引
function Item.getEquipCustomAttrValue(actor, pos, customAttrIndex)
    local itemobj = linkbodyitem(actor, pos)
    local customString = getitemcustomabil(actor, itemobj)
    if customString == "" then
        return {}
    end
    local customTable = json2tbl(customString)
    local abils = customTable["abil"]
    if not abils then
        return {}
    end
    local values = abils[customAttrIndex]
    if not values then
        return {}
    end
    if not values.v then
        return {}
    end
    local result = {}
    for i, v in ipairs(values.v) do
        table.insert(result, v[3])
    end
    return result
end
return Item
