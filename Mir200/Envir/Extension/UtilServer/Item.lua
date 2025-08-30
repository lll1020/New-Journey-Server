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

--����λ�û�ȡװ���Զ������Ե�����ֵ
---*  actor : ���˶���
---*  pos : λ��
---*  customAttrIndex : �Զ�����������
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
