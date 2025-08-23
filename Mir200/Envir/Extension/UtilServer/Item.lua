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
return Item