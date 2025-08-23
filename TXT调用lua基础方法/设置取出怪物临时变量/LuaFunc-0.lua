---���ù�����ʱint����
---@param actor string ��Ҷ���
---@param mapID number ��ͼID
---@param x number X����
---@param y number Y����
---@param range number ��Χ
---@param where number ������ʱ����λ��(1~5)
---@param value number ������ʱ����ֵ
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

---��ȡ������ʱint����
---@param actor string ��Ҷ���
---@param monMakeIndex number ����Ψһid
---@param where number ������ʱ����λ��(1~5)
function getmonintvar(actor,monMakeIndex,where)
    where = tonumber(where) or 0
    local mapID = getbaseinfo(actor,3)
    local mon = getmonbyuserid(mapID,monMakeIndex)
    if mon ~= "0" then
        return getobjintvar(mon,where)
    end
    return "nil"
end

---���ù�����ʱstr����
---@param actor string ��Ҷ���
---@param mapID number ��ͼID
---@param x number X����
---@param y number Y����
---@param range number ��Χ
---@param where number ������ʱ����λ��(1~5)
---@param value number ������ʱ����ֵ
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

---��ȡ������ʱstr����
---@param actor string ��Ҷ���
---@param monMakeIndex number ����Ψһid
---@param where number ������ʱ����λ��(1~5)
function getmonstrvar(actor,monMakeIndex,where)
    where = tonumber(where) or 0
    local mapID = getbaseinfo(actor,3)
    local mon = getmonbyuserid(mapID,monMakeIndex)
    if mon ~= "0" then
        return getobjstrvar(mon,where)
    end
    return "nil"
end