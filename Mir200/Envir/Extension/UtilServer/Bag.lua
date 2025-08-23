Bag = {}

--��ȡ��Ʒ����
function Bag.getItemNumByIdx(actor, idx)
	local name = getstditeminfo(idx,1) or ""
 	local count = getbagitemcount(actor,name)
	return count
end
function Bag.getItemNumByIdx1(actor, idx)
	local count = 0
	 local item_num = getbaseinfo(actor, 34)
   for i=0, item_num-1 do
	   local itemobj = getiteminfobyindex(actor, i)
	   local itemidx = getiteminfo(actor, itemobj, 2)
	   if itemidx == idx then
		   local item_mun = getiteminfo(actor, itemobj, 5)
		   if item_mun == 0 then
			   item_mun = 1
		   end
		   count = count + item_mun
	   end
   end
	 return count
end
--�����Ʒ����
function Bag.checkItemNumByIdx(actor, idx, num)
	num = num or 1
	local count = Bag.getItemNumByIdx(actor, idx)
	return count >= num
end

--��ȡ�����ո�����
function Bag.getBagEmptyNum(actor)
	local item_num = getbaseinfo(actor, 34)
	return 140 - item_num
end

--��鱳���ո�����
function Bag.checkBagEmptyNum(actor, num)
	local empty_num = Bag.getBagEmptyNum(actor)
	return empty_num >= num
end

--��鱳���Ƿ��㹻������Ʒ items
function Bag.checkBagEmptyItems(actor, items)
	local bagEmptyNum = Bag.getBagEmptyNum(actor)
	local needEmptyNum = 0
	for _,item in ipairs(items) do
        local idx,num = item[1],item[2]
        if not Item.isCurrency(idx) then    --��Ʒ װ��
			needEmptyNum = needEmptyNum + 1
        end
    end
	return bagEmptyNum >= needEmptyNum
end

--��ȡ������ĳ����Ʒ����
function Bag.getItemObjByIdx(actor, idx)
	local item_num = getbaseinfo(actor, 34)
	for i=0, item_num-1 do
		local itemobj = getiteminfobyindex(actor, i)
		local itemidx = getiteminfo(actor, itemobj, 2)
		if itemidx == idx then
			return itemobj
		end
	end
end
--��ȡ������ĳ����Ʒ����
function Bag.getItemObjByIdxNew(actor, idx)
	local _list = getbagitems(actor)
	for _, itemobj in ipairs(_list) do
		local itemidx = getiteminfo(actor, itemobj, 2)
		if itemidx == idx then
			return itemobj
		end
	end
end
---��ȡ������Ʒ�б������Ʒid��
function Bag.getItemListByIdxNew(actor, idx)
	local itemlist = {}
	local _list = getbagitems(actor)
	for _, itemobj in ipairs(_list) do
		local itemidx = getiteminfo(actor, itemobj, 2)
		if itemidx == idx then
			table.insert(itemlist, itemobj)
		end
	end
	return itemlist
end
---��ȡ������Ʒ�б������Ʒid
function Bag.getItemListByIdx(actor, idx)
	local itemlist = {}
	local item_num = getbaseinfo(actor, 34)
	for i=0, item_num-1 do
		local itemobj = getiteminfobyindex(actor, i)
		local itemidx = getiteminfo(actor, itemobj, 2)
		if itemidx == idx then
			table.insert(itemlist, itemobj)
		end
	end
	return itemlist
end

--��ȡ������ĳ����ƷΨһid
function Bag.getItemMakeIdByIdx(actor, idx)
	local itemobj = Bag.getItemObjByIdx(actor, idx)
	if not itemobj then return end
	return getiteminfo(actor, itemobj, 1)
end

--��鱳���Ƿ���ĳ����Ʒ������ͨ��Ψһid
function Bag.checkItemNumByMakeIndex(actor, makeindex, num)
	num = num or 1

	local item_num = getbaseinfo(actor, 34)
	for i=0, item_num-1 do
		local itemobj = getiteminfobyindex(actor, i)
		local itemmakeid = getiteminfo(actor, itemobj, 1)
		if itemmakeid == makeindex then
			if num > 1 then
				local overlap = getiteminfo(actor, itemobj, 5)
				if overlap < num then return false end
			end
			return true
		end
	end

	return false
end

--��ȡ������ĳ����Ʒ����ͨ��ΨһID
function Bag.getItemObjByMakeIndex(actor, makeindex)
	local item_num = getbaseinfo(actor, 34)
	for i=0, item_num-1 do
		local itemobj = getiteminfobyindex(actor, i)
		local itemmakeindex = getiteminfo(actor, itemobj, 1)
		if itemmakeindex == makeindex then
			return itemobj
		end
	end
end

return Bag