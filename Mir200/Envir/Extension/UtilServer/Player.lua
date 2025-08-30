release_print("UtilServer Player.lua")
Player = {}
local bind_money = {
    {3,1},--Ԫ��
    {4,2},--���
    {8,7},--����
}
local bind_m_tab = {}
for index, value in ipairs(bind_money) do
    for _, v in pairs(value) do
        bind_m_tab[v] = index
    end
end
function Player.getMoneyNum(actor, moneytype)
    local moneynum = 0
    if bind_m_tab[moneytype] then
        local index = bind_m_tab[moneytype]
        for _, value in ipairs(bind_money[index]) do
            moneynum = moneynum + querymoney(actor, value)
        end
    else
        moneynum = querymoney(actor, moneytype)
    end
    return moneynum
end
--����������
function Player.checkMoneyNum(actor, moneytype, num)
    local moneynum = 0
    if bind_m_tab[moneytype] then
        local index = bind_m_tab[moneytype]
        for _, value in ipairs(bind_money[index]) do
            moneynum = moneynum + querymoney(actor, value)
        end
    else
        moneynum = querymoney(actor, moneytype)
    end
    return moneynum >= num
end
--��� ��Ʒ ���� װ���Ƿ���������(�������㷵�ز�����Ʒ������)
function Player.checkItemNumByTable(actor, t, multiple)
    for _,item in ipairs(t) do
        local idx,num = getstditeminfo(item[1], 0),item[2]
        if multiple then num=num*multiple end
        
        local name = getstditeminfo(idx, 1) or "δ֪����"
        if Item.isCurrency(idx) then        --����
            if not Player.checkMoneyNum(actor, idx, num) then
                return name, num
            end
        else                                    --��Ʒ װ��
            if not Bag.checkItemNumByIdx(actor, idx, num) then
                return name, num
            end
        end
    end
end
function Player.getBatItemNum(actor,idx)
    if Item.isCurrency(idx) then        --����
        return Player.getMoneyNum(actor, idx)
    else                                    --��Ʒ װ��
        return getbagitemcount(actor, idx)
    end
end
--������Ʒ
function Player.takeItemByTable(actor, t, desc, multiple)
    for _,item in ipairs(t) do
        local idx,num = getstditeminfo(item[1], 0),item[2]
        if multiple then num=num*multiple end
        if Item.isCurrency(idx) then        --����
            if bind_m_tab[idx] then  --��Ϸ�趨 �󶨲���۳�����
                local index = bind_m_tab[idx]
                for _, value in ipairs(bind_money[index]) do
                    if num == 0 then break end
                    local bdyb = querymoney(actor, value)
                    if num > bdyb then    --������Ҳ���ʱ �ȿ۳���һ���� Ȼ��ѭ���ڶ� ����
                        changemoney(actor, value, "-", bdyb, desc, true)   --���ȿ۳����а�Ԫ��
                        num = num - bdyb
                    else
                        changemoney(actor, value, "-", num, desc, true)
                        num = 0
                    end
                end
                local bdyb = querymoney(actor, 4)
            end
            if num > 0 then
                changemoney(actor, idx, "-", num, desc, true)
            end
        else                                    --��Ʒ װ��
            local name = getstditeminfo(idx, 1)
            takeitem(actor, name, num)
        end
    end
end
--������Ʒidx
function Player.takeItemByTableIdxHs(actor, t)
    for _,item in ipairs(t) do
        local idx,num = item[1],item[2]
        local name = getstditeminfo(idx, 1)
        takeitem(actor, name, num)
    end
end
--����Ʒ
function Player.giveItemByTable(actor, t, desc, multiple, isbind)
    multiple = multiple or 1         --����
    for _,item in ipairs(t) do
        local idx,num,bind = getstditeminfo(item[1], 0),item[2],item[3]
        if Item.isCurrency(idx) then        --����
            changemoney(actor, idx, "+", num * multiple, desc, true)
        else                                    --��Ʒ װ��
            local name = getstditeminfo(idx, 1)
            if bind or isbind then
                giveitem(actor, name, num * multiple, 307)
            else
                giveitem(actor, name, num * multiple)
            end
        end
    end
end

--���²�������
function Player.updateSomeAddr(actor, cur_attr, next_attr)
    local newattr = {}
    if cur_attr then
        for _,attr in ipairs(cur_attr) do
            local attridx, attrvalue = attr[1], attr[2]
            local addvalue = 0
            addvalue = gethumnewvalue(actor, attridx)
            newattr[attridx] = newattr[attridx] or addvalue
            newattr[attridx] = newattr[attridx] - attrvalue
            if newattr[attridx] < 0 then newattr[attridx] = 0 end
        end
    end

    if next_attr then
        for _,attr in ipairs(next_attr) do
            local attridx, attrvalue = attr[1], attr[2]
            local addvalue = 0
            addvalue = gethumnewvalue(actor, attridx)
            newattr[attridx] = newattr[attridx] or addvalue
            newattr[attridx] = newattr[attridx] + attrvalue
        end
    end
    --cfg_att_score.xls ����
    for attridx,attrvalue in pairs(newattr) do
        changehumnewvalue(actor, attridx, math.floor(attrvalue), 123456789)
    end
end

--���²�������  --��ʱ���
function Player.updateSomeAddr_time(actor, cur_attr, next_attr,time)
    local newattr = {}
    if cur_attr and #cur_attr > 0 then
        for _,attr in ipairs(cur_attr) do
            local attridx, attrvalue = attr[1], attr[2]
            local addvalue = 0
            addvalue = gethumnewvalue(actor, attridx)
            newattr[attridx] = newattr[attridx] or addvalue
            newattr[attridx] = newattr[attridx] - attrvalue
            if newattr[attridx] < 0 then newattr[attridx] = 0 end
        end
    end

    if next_attr and #next_attr > 0 then
        for _,attr in ipairs(next_attr) do
            local attridx, attrvalue = attr[1], attr[2]
            local addvalue = 0
            addvalue = gethumnewvalue(actor, attridx)
            newattr[attridx] = newattr[attridx] or addvalue
            newattr[attridx] = newattr[attridx] + attrvalue
        end
    end
    --cfg_att_score.xls ����
    for attridx,attrvalue in pairs(newattr) do
        changehumnewvalue(actor, attridx, math.floor(attrvalue), 123456789)
    end
    local buff_time = os.time()
    setplaydef(actor,"S$updateSomeAddr_time_cur_attr_"..buff_time,tbl2json(cur_attr or {}))
    setplaydef(actor,"S$updateSomeAddr_time_next_attr_"..buff_time,tbl2json(next_attr or {}))
    delaygoto(actor,time * 1000,"updateSomeAddr_time_del,"..buff_time,0)
end
function updateSomeAddr_time_del(actor,time)

    local next_attr = getplaydef(actor,"S$updateSomeAddr_time_cur_attr_"..time)
    local cur_attr = getplaydef(actor,"S$updateSomeAddr_time_next_attr_"..time)

    setplaydef(actor,"S$updateSomeAddr_time_cur_attr_"..time,nil)
    setplaydef(actor,"S$updateSomeAddr_time_next_attr_"..time,nil)

    next_attr = (next_attr == "{}" and nil or json2tbl(next_attr))
    cur_attr = (cur_attr == "{}" and nil or json2tbl(cur_attr))
    local newattr = {}
    if cur_attr and #cur_attr > 0 then
        for _,attr in ipairs(cur_attr) do
            local attridx, attrvalue = attr[1], attr[2]
            local addvalue = 0
            addvalue = gethumnewvalue(actor, attridx)
            newattr[attridx] = newattr[attridx] or addvalue
            newattr[attridx] = newattr[attridx] - attrvalue
            if newattr[attridx] < 0 then newattr[attridx] = 0 end
        end
    end

    if next_attr and #next_attr > 0 then
        for _,attr in ipairs(next_attr) do
            local attridx, attrvalue = attr[1], attr[2]
            local addvalue = 0
            addvalue = gethumnewvalue(actor, attridx)
            newattr[attridx] = newattr[attridx] or addvalue
            newattr[attridx] = newattr[attridx] + attrvalue
        end
    end
    --cfg_att_score.xls ����
    for attridx,attrvalue in pairs(newattr) do
        changehumnewvalue(actor, attridx, math.floor(attrvalue), 123456789)
    end
end

function Player.rwjl(actor, t, desc, multiple,gm)
    local str = ""
    if (multiple and multiple >= 1) or not multiple then
        for i, v in ipairs(t) do
            local idx = getstditeminfo(v[1], 0)
            if Item.isCurrency(idx) then        --����
                if multiple then v[2]=v[2]*multiple end
                if str ~= "" then
                    str = str..",[\""..v[1].."\","..v[2].."]"
                else
                    str = str.."[\""..v[1].."\","..v[2].."]"
                end
                changemoney(actor,v[1],"+",v[2],desc,true)
            else
                if multiple then v[2]=v[2]*multiple end
                if str ~= "" then
                    str = str..",[\""..v[1].."\","..v[2].."]"
                else
                    str = str.."[\""..v[1].."\","..v[2].."]"
                end
                giveitem(actor,v[1],v[2],850)
            end
        end
        if str ~= "" and gm ~= 0 then
            sendluamsg(actor,101,0,9,gm and gm or 999,'{"item":['..str..']}')
        end
    end
end

--������Ϣ����
function Player.sendmsg(actor, msg)
    if type(msg) == "string" then
        sendmsg(actor, ConstCfg.notice.own, '{"Msg":"' .. msg .. '","Type":9}')
    elseif type(msg) == "table" then
        local MsgStr = ""
        for _, v in ipairs(msg) do
            MsgStr = MsgStr .. "<font color='" .. v[1] .. "'>" .. v[2] .. "</font>"
        end
        sendmsg(actor, ConstCfg.notice.own, '{"Msg":"' .. MsgStr .. '","Type":9}')
    end
end

--���͸�����Ϣ9
--* actor�����˶���
--* str����Ϣ���� ��ʽ �ı�#��ɫ|�ı�#��ɫ (��ɫֵ0-255)
--* defaultColor��Ĭ����ɫ Ĭ��Ϊ��ɫ
function Player.sendmsgEx(actor, str, defaultColor)
    if str == nil or str == "" then
        return
    end
    defaultColor = defaultColor or 250
    local content = ""
    local part = string.split(str, "|")
    for _, v in ipairs(part) do
        local text = string.split(v, "#")
        local colorNum = tonumber(text[2])
        colorNum = colorNum or defaultColor
        local hexColor = ColorCfg[colorNum] ~= nil and ColorCfg[colorNum].hexColor or ColorCfg[defaultColor].hexColor
        content = content .. "<font color='" .. hexColor .. "'>" .. text[1] .. "</font>"
    end
    if content ~= "" then
        sendmsg(actor, ConstCfg.notice.own, '{"Msg":"' .. content .. '","Type":9}')
    else
        return
    end
end
--����Ļ�м���Լ�������Ч
function Player.screffects(actor, effectId, offsetX, offsetY)
    offsetX = offsetX or 0
    offsetY = offsetY or 0
    local x = getconst(actor, "<$SCREENWIDTH>") / 2 + offsetX
    local y = getconst(actor, "<$SCREENHEIGHT>") / 2 + offsetY
    screffects(actor, 1, effectId, x, y, 1, 1, 0)
end

---@param actor userdata ��Ҷ���
function Player.GetName(actor)
    return getbaseinfo(actor, 1)
end

--��ȡ����/���ﵱǰ��ͼ����
function Player.MapKey(actor)
    return getbaseinfo(actor, 3)
end

--��ȡĿ������x
function Player.GetX(actor)
    return getbaseinfo(actor, 4)
end
--��ȡĿ������y
function Player.GetY(actor)
    return getbaseinfo(actor, 5)
end
--��������ID��ȡ����ֵ
function Player.GetAttr(actor, attrId)
    return getbaseinfo(actor, 51, attrId)
end

--��ȡ����ΨһID str
function Player.GetUUID(actor)
    return getbaseinfo(actor, 2)
end

----��ý�ɫ�ȼ�
---@param actor  --��Ҷ���
function Player.GetLevel(actor)
    return getbaseinfo(actor, 6)
end


function Player.qsx_give(actor, t, desc, multiple) --ȫ���Ը���
    --TODO
end
function Player.zxrw_lingqu(actor, zxrw_id, desc) --��ȡ֧������
    if not json2tbl(getplaydef(actor, VarCfg.T_zxrw))[zxrw_id] then
        newpicktask(actor,zxrw_id)
        rwcf.jia(actor,zxrw_id)
        sendluamsg(actor,101,1005,0,0,getplaydef(actor, VarCfg.T_zxrw))
    end
end
function Player.zxrw_wancheng(actor, zxrw_id, desc) --�������
    if zxrw_id < 1000 then --����
        if getplaydef(actor,VarCfg.U_zxrw[1]) == zxrw_id then
            newdeletetask(actor, zxrw_id)
        end
    else
        if json2tbl(getplaydef(actor, VarCfg.T_zxrw))[""..zxrw_id] then
            if constant.rw_syb[zxrw_id][1] == 0 then --��ʵ������
                rwcf.jian(actor,zxrw_id)
                newdeletetask(actor, zxrw_id)
            else
                newdeletetask(actor, zxrw_id)
            end
        end
    end
end
function Player.zxrw_shuaxin(actor, zxrw_id,jd, desc) --ˢ������ -- �в�
    if zxrw_id < 500 and getplaydef(actor,VarCfg.U_zxrw[1]) ~= zxrw_id then
        return
    end
    newchangetask(actor, zxrw_id,unpack(jd))
end
function Player.zxrw_teshushuaxin(actor, zxrw_id, desc) --����ˢ������--�޲�
    if zxrw_id < 500 and getplaydef(actor,VarCfg.U_zxrw[1]) ~= zxrw_id then
        return
    end
    if constant.rw_syb[zxrw_id] and constant.rw_syb[zxrw_id].jd then
        local chuliwp = json2tbl(getplaydef(actor, VarCfg.T_rwwp))
        local db = json2tbl(getplaydef(actor,VarCfg.T_dljq))
        if db[constant.rw_syb[zxrw_id].jd[1]] and constant.rw_syb[zxrw_id].jd[2] == 1 then
            newchangetask(actor, zxrw_id,db[constant.rw_syb[zxrw_id].jd[1]][2])
        end
        if db[constant.rw_syb[zxrw_id].jd[1]] and db[constant.rw_syb[zxrw_id].jd[1]] == 1 and constant.rw_syb[zxrw_id].jd[2] == 0 then
            if constant.rw_syb[zxrw_id].sjwp then
                local sl = {}
                -- ��ȡ��ļ�������
                local keys = {}
                for k in pairs(constant.rw_syb[zxrw_id].sjwp) do
                    table.insert(keys, k)
                end
                table.sort(keys)
                for i, y in ipairs(keys) do
                    if chuliwp[y] then
                        table.insert(sl,getbagitemcount(actor,y) >= constant.rw_syb[zxrw_id].sjwp[y] and constant.rw_syb[zxrw_id].sjwp[y] or getbagitemcount(actor,y))
                    else
                        table.insert(sl,constant.rw_syb[zxrw_id].sjwp[y])
                    end
                end
                -- ����newpicktask����������sj���е�Ԫ����Ϊ��������
                newchangetask(actor, zxrw_id,unpack(sl))
            end
        end
    end
    if constant.rw_syb[zxrw_id] and constant.rw_syb[zxrw_id].ts then
        if constant.rw_syb[zxrw_id].ts[1] == 1 then
            local db = json2tbl(getplaydef(actor,VarCfg.T_dljq))
            local sl = {
                getbagitemcount(actor,constant.rw_syb[zxrw_id].ts.wp),
                (db[constant.rw_syb[zxrw_id].ts.cs[1]] and db[constant.rw_syb[zxrw_id].ts.cs[1]][constant.rw_syb[zxrw_id].ts.cs[2]])
                        and db[constant.rw_syb[zxrw_id].ts.cs[1]][constant.rw_syb[zxrw_id].ts.cs[2]] or 0
            }
            newchangetask(actor, zxrw_id,unpack(sl))
        elseif constant.rw_syb[zxrw_id].ts[1] == 2 then
            local db = json2tbl(getplaydef(actor,VarCfg.T_dljq))
            local sl = {}
            for v,k in pairs(constant.rw_syb[zxrw_id].ts.wp) do
                table.insert(sl,getbagitemcount(actor,k))
                table.insert(sl,
                        (db[constant.rw_syb[zxrw_id].ts.cs[1]] and
                                db[constant.rw_syb[zxrw_id].ts.cs[1]][constant.rw_syb[zxrw_id].ts.cs[2]] and
                                db[constant.rw_syb[zxrw_id].ts.cs[1]][constant.rw_syb[zxrw_id].ts.cs[2]][""..v])
                        and db[constant.rw_syb[zxrw_id].ts.cs[1]][constant.rw_syb[zxrw_id].ts.cs[2]][""..v] or 0)
            end
            newchangetask(actor, zxrw_id,unpack(sl))
        elseif constant.rw_syb[zxrw_id].ts[1] == 3 then
            local db = json2tbl(getplaydef(actor,VarCfg.T_dljq))
            local sl = {}
            for v,k in pairs(constant.rw_syb[zxrw_id].ts.cs[2]) do
                table.insert(sl,
                        (db[constant.rw_syb[zxrw_id].ts.cs[1]] and
                                db[constant.rw_syb[zxrw_id].ts.cs[1]][k])
                                and db[constant.rw_syb[zxrw_id].ts.cs[1]][k] or 0)
            end
            newchangetask(actor, zxrw_id,unpack(sl))
        elseif constant.rw_syb[zxrw_id].ts[1] == 4 then
            local db = json2tbl(getplaydef(actor,VarCfg.T_dljq))
            local sl = {}
            for v,k in pairs(constant.rw_syb[zxrw_id].ts.wp) do
                table.insert(sl,getbagitemcount(actor,k))
                table.insert(sl,
                        (db[constant.rw_syb[zxrw_id].ts.cs[1]] and
                                db[constant.rw_syb[zxrw_id].ts.cs[1]][constant.rw_syb[zxrw_id].ts.cs[2][v]])
                                and db[constant.rw_syb[zxrw_id].ts.cs[1]][constant.rw_syb[zxrw_id].ts.cs[2][v]] or 0)
            end
            newchangetask(actor, zxrw_id,unpack(sl))
        elseif constant.rw_syb[zxrw_id].ts[1] == 5 then
            if zxrw_id == 2007 then
                local sl = {}
                for v,k in pairs(constant.rw_syb[zxrw_id].ts.wp) do
                    table.insert(sl,getbagitemcount(actor,k))
                end
                newchangetask(actor, zxrw_id,unpack(sl))
            end
        end
    end
end
local zdl_attr = {
    {1,1},
    {4,1},
    {6,1},
    {8,1},
    {10,1},
    {12,1},
}
function Player.updata_zdl(actor, desc) --ս��������
    local zdl = 0
    for v,k in ipairs(zdl_attr) do
        zdl = zdl + getbaseinfo(actor, 51, k[1]) * k[2]
    end
    if zdl ~= querymoney(actor, 29) then
        changemoney(actor,29,"=",zdl,"ս��������",true)
    end
end
function Player.title_give(actor, title_name) --���ƺ�
    if not checktitle(actor, title_name) then
        release_print("���ƺ�",title_name,getbaseinfo(actor,1))
        confertitle(actor, title_name)
        local idx = getstditeminfo(title_name,8)
        if idx > 0 then
            Buff[idx](actor,1)
            Buff[idx](actor,5)
        end
    end
end
function Player.title_del(actor, title_name) --ɾ�ƺ�
    if checktitle(actor, title_name) then
        release_print("ɾ�ƺ�",title_name,getbaseinfo(actor,1))
        deprivetitle(actor, title_name)
        local idx = getstditeminfo(title_name,8)
        if idx > 0 then
            Buff[idx](actor,2)
            Buff[idx](actor,6)
        end
    end

end

function Player.jl_mail(table) --����ת�ʼ�
    local str = ""
    for v,k in pairs(table) do
        if v == "wp" then
            for i = 1,#k do
                str = str .. k[i][1] .. "#" .. k[i][2] .. "#850&"
            end
        end
        if v == "hb" then
            for i = 1,#k do
                str = str .. k[i][1] .. "#" .. k[i][2] .. "&"
            end
        end
    end
    --release_print("jl_mail",str)
    return str
end
function Player.dl_sz_notip(actor, dl) --��½���� -- ����ʾ
    if dl == 1 then
        if getplaydef(actor,VarCfg.U_zxrw[1]) < 8 then
            return false
        end
    end
    return true
end
function Player.dl_sz(actor, dl) --��½���� -- ����ʾ
    if dl == 1 then
        if getplaydef(actor,VarCfg.U_zxrw[1]) < 8 then
            sendmsg(actor, 1, '{"Msg":"<font color=\'#ff0000\'>����ɸô�½��������������������</font>","Type":9}')
            return false
        end
    end
    return true
end
--��� ��Ʒ ���� װ���Ƿ���������(�������㷵�ز�����Ʒ������)
function Player.checkItemNum(actor, t, multiple)
    for _,item in ipairs(t) do
        local idx,num = getstditeminfo(item[1], 0),item[2]
        if multiple then num=num*multiple end
        if Item.isCurrency(idx) then        --����
            if not Player.checkMoneyNum(actor, idx, num) then
                return false
            end
        else                                    --��Ʒ װ��
            if not Bag.checkItemNumByIdx(actor, idx, num) then
                return false
            end
        end
    end
    return true
end
--����
local fd_sjyb = {[10053] = {500,2000},[10054] = {1000,5000},[10055] = {5000,50000},[10056] = {10000,1000000}}

function Player.huishou(play, hs_constant)
    if hs_constant == nil then
        local kg1, kg2, kg3, kg4, kg5, pz, cl, sq = getflagstatus(play, VarCfg.BS_huishou[1]), getflagstatus(play, VarCfg.BS_huishou[2]), getflagstatus(play, VarCfg.BS_huishou[3]),getflagstatus(play, VarCfg.BS_huishou[4]),getflagstatus(play, VarCfg.BS_huishou[5]), json2tbl(getplaydef(play, VarCfg.T_hsdg)), {0,0,0,0,0,0,0,0,0}, ''
        local T_tshs = json2tbl(getplaydef(play, VarCfg.T_tshs))
        local item = getbagitems(play)

        for i, v in pairs(item or {}) do
            local idx = getiteminfo(play, v, 2)
            if idx > 10022 and idx < 10034 then    --���
                if kg1 == 1 then
                    local sl = getiteminfo(play, v, 5)
                    changemoney(play, getflagstatus(play,VarCfg.BS_mztq) == 1 and 2 or 4, '+', getstditeminfo(idx, 8) * sl, '�����˳�', true)
                    delitembymakeindex(play, getiteminfo(play, v, 1), sl)
                end
            elseif idx > 10018 and idx < 10023 then    --Ԫ��
                if kg2 == 1 then
                    if fd_sjyb[idx] then
                        local sl = getiteminfo(play, v, 5)
                        delitembymakeindex(play, getiteminfo(play, v, 1), sl)
                        for i = 1, sl, 1 do
                            changemoney(play, getflagstatus(play,VarCfg.BS_mztq) == 1 and 1 or 3, '+', math.random(fd_sjyb[idx][1], fd_sjyb[idx][2]), '�����˳�', true)
                        end
                    end
                end
            elseif idx > 10010 and idx < 10019 then    --���鵤
                if kg3 == 3 then
                    local sl = getiteminfo(play, v, 5)
                    changeexp(play, '+', getstditeminfo(idx, 8) * sl, false)
                    delitembymakeindex(play, getiteminfo(play, v, 1), sl)
                end
            else
                if kg4 == 1 then
                    if not huishou.teshuhuihsou[idx] or (huishou.teshuhuihsou[idx] and T_tshs[""..idx]) then
                        if huishou.zzhs[idx] then
                            if pz['1_'..huishou.zzhs[idx][1]] or pz['1_'..huishou.zzhs[idx][1].."_"..huishou.zzhs[idx][2]] or pz[""..idx] then
                                sq = sq .. getiteminfo(play, v, 1) .. ','
                                cl[1] = cl[1] + huishou.zzhs[idx][4]
                                cl[2] = cl[2] + huishou.zzhs[idx][5]
                            end
                        elseif huishou.zsfj[idx] then
                            if pz['2_'..huishou.zsfj[idx][1]] or pz['2_'..huishou.zsfj[idx][1].."_"..huishou.zsfj[idx][2]] or pz[""..idx] then
                                sq = sq .. getiteminfo(play, v, 1) .. ','
                                if huishou.zsfj[idx][1] == 9 then
                                    cl[3] = cl[3] + huishou.zsfj[idx][4]
                                else
                                    cl[1] = cl[1] + huishou.zsfj[idx][4]
                                    cl[2] = cl[2] + huishou.zsfj[idx][5]
                                end
                            end
                        elseif huishou.clfj[idx] then
                            if pz['3_'..huishou.clfj[idx][1]] or pz['3_'..huishou.clfj[idx][1].."_"..huishou.clfj[idx][2]] or pz[""..idx] then
                                sq = sq .. getiteminfo(play, v, 1) .. ','
                                cl[1] = cl[1] + huishou.clfj[idx][4]
                                cl[2] = cl[2] + huishou.clfj[idx][5]
                            end
                        end
                    end
                end
            end
        end
        if sq ~= '' then
            delitembymakeindex(play, sq)
            if cl[1] > 0 then
                changemoney(play, getflagstatus(play,VarCfg.BS_mztq) == 1 and 1 or 3, '+', cl[1] + math.floor(cl[1] * getbaseinfo(play,51,204) / 10000), '���ջ��', true)
            end
            if cl[2] > 0 then
                changemoney(play, getflagstatus(play,VarCfg.BS_mztq) == 1 and 2 or 4, '+', cl[2] + math.floor(cl[2] * getbaseinfo(play,51,205) / 10000), '���ջ��', true)
            end
            if cl[3] > 0 then
                changemoney(play, getflagstatus(play,VarCfg.BS_mztq) == 1 and 7 or 8, '+', cl[3], '���ջ��', true)
            end
            local gz = getflagstatus(play,VarCfg.BS_mztq) == 1 and 0 or 850
            if cl[9] > 0 then
                giveitem(play,"��װ��Ƭ",cl[9],gz)
            end
        end
    else
        local hs = hs_constant
        local cl = {0,0,0,0,0}--����
        local yb,jb = 0,0 --Ԫ�����
        local xy = 0  --����
        local jc = 0 --��װ
        local T_tshs = json2tbl(getplaydef(play, VarCfg.T_tshs))
        local gz = getflagstatus(play,VarCfg.BS_mztq) == 1 and 0 or 850
        for k, v in pairs(hs) do
            local wp = getitembymakeindex(play,v)
            if wp then
                local idx = getiteminfo(play,wp,2)
                if not huishou.teshuhuihsou[idx] or (huishou.teshuhuihsou[idx] and T_tshs[""..idx]) then
                    if huishou.kexiaohui[idx] then
                        delitembymakeindex(play,v,1)
                    elseif huishou.zzhs[idx] then
                        if delitembymakeindex(play,v,1) then
                            yb = yb + huishou.zzhs[idx][4]
                            jb = jb + huishou.zzhs[idx][5]
                        end
                    elseif huishou.clfj[idx] then
                        if delitembymakeindex(play,v,1) then
                            yb = yb + huishou.clfj[idx][4]
                            jb = jb + huishou.clfj[idx][5]
                        end
                    elseif huishou.zsfj[idx] then
                        if huishou.zsfj[idx][1] == 9 then
                            if delitembymakeindex(play,v,1) then
                                xy = xy + huishou.zsfj[idx][4]
                            end
                        else
                            if delitembymakeindex(play,v,1) then
                                yb = yb + huishou.zsfj[idx][4]
                                jb = jb + huishou.zsfj[idx][5]
                            end
                        end
                    elseif huishou.fzfj[idx] then
                        if delitembymakeindex(play,v,1) then
                            jc = jc + huishou.fzfj[idx][4]
                        end
                    end
                end
            end
        end
        if yb > 0 then
            changemoney(play, getflagstatus(play,VarCfg.BS_mztq) == 1 and 1 or 3, '+', yb + math.floor(yb * getbaseinfo(play,51,204) / 10000), '���ջ��', true)
        end
        if jb > 0 then
            changemoney(play, getflagstatus(play,VarCfg.BS_mztq) == 1 and 2 or 4, '+', jb + math.floor(jb * getbaseinfo(play,51,205) / 10000), '���ջ��', true)
        end
        if xy > 0 then
            changemoney(play, getflagstatus(play,VarCfg.BS_mztq) == 1 and 7 or 8, '+', xy, '���ջ��', true)
        end
        if jc > 0 then
            giveitem(play,"��װ��Ƭ",jc,gz)
        end
        Login_msg(play,10,yb,jb)
    end

end
function Player.addteshuhuihsou(play, t)
    local T_tshs = json2tbl(getplaydef(play, VarCfg.T_tshs))
    local hspz = json2tbl(getplaydef(play,VarCfg.T_hsdg))
    for _,item in ipairs(t) do
        local idx = getstditeminfo(item[1], 0)
        if huishou.teshuhuihsou[idx] and not T_tshs[""..idx] then
            T_tshs[""..idx] = true
        end
        hspz[""..idx] = 1
    end
    setplaydef(play, VarCfg.T_tshs, tbl2json(T_tshs))
    setplaydef(play,VarCfg.T_hsdg,tbl2json(hspz))
end



return Player