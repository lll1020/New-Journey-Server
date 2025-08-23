Item = {}

--���idx�Ƿ��ǻ���
function Item.isCurrency(idx)
    local stdmode = getstditeminfo(idx, 2)
    return stdmode == 41
end

--��ȡidxͨ��where
function Item.getIdxByWhere(actor, where)
    local equipobj = linkbodyitem(actor, where)
    if equipobj == "0" then return end
    return getiteminfo(actor, equipobj, 2)
end

--��ȡ��ƷIdxͨ����Ʒ����
---comment
---@param name any
---@return integer
function Item.getIdxByName(name)
    return getstditeminfo(name,0)--[[@as integer]] or 0
end
return Item