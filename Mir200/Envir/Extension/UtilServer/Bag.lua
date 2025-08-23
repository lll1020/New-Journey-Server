Bag = {}

--获取物品数量
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
--检查物品数量
function Bag.checkItemNumByIdx(actor, idx, num)
	num = num or 1
	local count = Bag.getItemNumByIdx(actor, idx)
	return count >= num
end

--获取背包空格数量
function Bag.getBagEmptyNum(actor)
	local item_num = getbaseinfo(actor, 34)
	return 140 - item_num
end

--检查背包空格数量
function Bag.checkBagEmptyNum(actor, num)
	local empty_num = Bag.getBagEmptyNum(actor)
	return empty_num >= num
end

--检查背包是否足够给予物品 items
function Bag.checkBagEmptyItems(actor, items)
	local bagEmptyNum = Bag.getBagEmptyNum(actor)
	local needEmptyNum = 0
	for _,item in ipairs(items) do
        local idx,num = item[1],item[2]
        if not Item.isCurrency(idx) then    --物品 装备
			needEmptyNum = needEmptyNum + 1
        end
    end
	return bagEmptyNum >= needEmptyNum
end

--获取背包中某件物品对象
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
--获取背包中某件物品对象
function Bag.getItemObjByIdxNew(actor, idx)
	local _list = getbagitems(actor)
	for _, itemobj in ipairs(_list) do
		local itemidx = getiteminfo(actor, itemobj, 2)
		if itemidx == idx then
			return itemobj
		end
	end
end
---获取背包物品列表根据物品id新
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
---获取背包物品列表根据物品id
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

--获取背包中某件物品唯一id
function Bag.getItemMakeIdByIdx(actor, idx)
	local itemobj = Bag.getItemObjByIdx(actor, idx)
	if not itemobj then return end
	return getiteminfo(actor, itemobj, 1)
end

--检查背包是否有某件物品的数量通过唯一id
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

--获取背包中某件物品对象通过唯一ID
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