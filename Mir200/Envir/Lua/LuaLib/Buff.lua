release_print("加载Buff模块")
Buff = {

    [70] = function(play,zt)      --被人物攻击随机(CD30秒)
        if zt == 3 then
            local sj = os.time()
            if sj - getplaydef(play,"N$buff70cd") > 30 then
                setplaydef(play,"N$buff70cd",sj)
                map(play,getbaseinfo(play,3))
            end
            return 0
        else
            local bl = getplaydef(play,constant.S_buffbrwq)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["70"] = true
                setplaydef(play,"N$buff70cd",os.time())
            elseif zt == 2 then
                data["70"] = nil
            end
            setplaydef(play,constant.S_buffbrwq,tbl2json(data))
        end
    end,
    [71] = function(play,zt,Damage,Target)      --溅射伤害  打怪时5%触发闪电，电击自身8*8范围内的所有敌人，造成500真实伤害拉取怪物仇恨。
        if zt == 3 then
            local sj = os.time()
            if sj - getplaydef(play,constant.N_jsys) > 6 and math.random(100) > 5 then
                setplaydef(play,constant.N_jsys,sj)
                local xx,yy,dqdt = getbaseinfo(play,4),getbaseinfo(play,5),getbaseinfo(play,3)
                local mons,gjsx = getobjectinmap(dqdt, xx,yy, 10, 2),500
                rangeharm(play,getbaseinfo(play,4),getbaseinfo(play,5),6,0,0,0,0,2,20310)
                if #mons > 1 then
                    for i, v in ipairs(mons) do
                        if i < 20 then
                            if Target ~= v then
                                humanhp(v,"-",500,111,0,play)
                                monmission(v,getbaseinfo(play,4)-3,getbaseinfo(play,5)-3,0)
                            end
                        end
                    end
                end
            end
        else
            local bl = getplaydef(play,constant.S_buffgwh)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["71"] = true
            elseif zt == 2 then
                data["71"] = nil
            end
            setplaydef(play,constant.S_buffgwh,tbl2json(data))
        end
    end,
    [72] = function(play,zt)      --AI挂机,被攻击自动随机
        if zt == 3 then
            local sj = os.time()
            local json = json2tbl(getplaydef(play,constant.T_aigj))
            if sj - getplaydef(play,constant.N_Aigj[1]) >= 60 and not getbaseinfo(play,0) and json.gjkg then
                setplaydef(play,constant.N_Aigj[1],sj)
                map(play,getbaseinfo(play,3))
                sendmsg(play,1,'{"Msg":"<font color=\'#28ef01\'>AI挂机：被人物攻击自动随机！</font>","Type":9}')
                startautoattack(play)
            end
            return 0
        else
            local bl = getplaydef(play,constant.S_buffbrwq)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["72"] = true
            elseif zt == 2 then
                data["72"] = nil
            end
            setplaydef(play,constant.S_buffbrwq,tbl2json(data))
        end
    end,
    [73] = function(play,zt,Damage,Target)      --赠送属性,刀刀绿毒
        if zt == 3 then
            makeposion(Target,0,2,10)
        else
            local bl = getplaydef(play,constant.S_buffgwh)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["73"] = true
            elseif zt == 2 then
                data["73"] = nil
            end
            setplaydef(play,constant.S_buffgwh,tbl2json(data))
        end
    end,

    [101] = function(play,zt) --仙食坊全满
        if zt == 1 then
            addattlist(play, "仙食坊全满", "=", "3#1#8888|3#4#588|3#242#3800|3#244#4888", 1)
        elseif zt == 2 then
            delattlist(play, "仙食坊全满")
        end
    end,
    [102] = function(play,zt,Damage,Target) --轩辕剑传人  BUFF:每三刀附带额外最大攻击1%的真实伤害
        if zt == 3 then
            local cs = getplaydef(play,"N$buff102")
            if cs < 3 then
                cs = cs + 1
                setplaydef(play,"N$buff102",cs)
            else
                setplaydef(play,"N$buff102",0)
                humanhp(Target,"-",math.floor(getbaseinfo(play, 20)*0.01))
                --Player.sendmsgEx(play,"轩辕剑传人触发真实伤害，造成"..math.floor(getbaseinfo(play, 20)*0.01).."点真实伤害！")
            end
        else
            local bl = getplaydef(play,VarCfg.S_buffgjh)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["102"] = true
                setplaydef(play,"N$buff102",0)
            elseif zt == 2 then
                data["102"] = nil
            end
            setplaydef(play,VarCfg.S_buffgjh,tbl2json(data))
        end
    end,
}

local weizhi = {0,1,3,4,5,6,7,8,9,10,11,13,14,16,30,31,32,33,34,35,36,37,38,39,40,41}


function Buff.login(play)
    -------------------------------------------------------------------装备BUFF登录初始化
    for k, v in pairs(weizhi) do
        local item = linkbodyitem(play,v)
        if item ~= "0" then
            if v == 14 then
                changemoney(play,16,"=",1,"登录复活",true)
            end
            local id = getstditeminfo(getiteminfo(play,item,2),8)
            if id > 0 and Buff[id] then
                Buff[id](play,1)
            end
        end
    end
    -------------------------------------------------------------------称号BUFF登录初始化
    local ch = gettitlelist(play)
    for _, v in pairs(ch) do
        local idx = getstditeminfo(getiteminfo(play,v,1),8)
        if idx and idx > 0 then
            Buff[idx](play,1)
        end
    end

    -------------------------------------------------------------------飞剑系统
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_飞剑"])
    if T_data["open"] and T_data["open"] == 1 then
        local level = getbaseinfo(play,39)
        local count = 0
        if level >= 1 or hasbuff(play,20000) then
            count = count + 1
        end
        local T_data_cs = Player.getJsonTableByVar(play, VarCfg["T_首冲礼包"])
        if T_data["首充"] == 1 or T_data["补充"] == 1 or hasbuff(play,20001) then
            count = count + 1
        end
        if getflagstatus(play,VarCfg.BS_mztq) == 1 or hasbuff(play,20002) then
            count = count + 1
        end
        sendluamsg(play,101,19,1,0,tbl2json({ count = count,psData = {cd = (T_data.cd or (hasbuff(play,20002) and teshudata["anniu_19"].cd/2) or teshudata["anniu_19"].cd)}}))
    end
    -------------------------------------------------------------------额外附加属性登录初始化
    --灵根鉴定
    local data = Player.getJsonTableByVar(play, VarCfg["T_灵根鉴定"])
    if data["1"] then
        local attrs = {}
        local attrsstr = ""
        for i=1,5 do
            attrs[teshudata["npc_1"].config[i].attr] = data[""..i] or 0
        end
        attrsstr = Player.getAttrTableToStr(attrs)
        addattlist(play, "灵根鉴定", "=", attrsstr, 1)
    end
    --灵根修炼
    data = Player.getJsonTableByVar(play, VarCfg["T_灵根修炼"])
    local attrs = {}
    local attrsstr = ""
    for i=1,5 do
        attrs[teshudata["npc_11"].attrID[i]] = (data[""..i] or 0) * teshudata["npc_11"].config[i].ratio
    end
    attrsstr = Player.getAttrTableToStr(attrs)
    addattlist(play, "灵根修炼", "=", attrsstr, 1)
    --兰姐好感度
    if getplaydef(play, VarCfg["U_兰姐好感度"]) > 0 then
        addattlist(play, "兰姐好感度", "=", "3#"..teshudata["npc_13"].attrID.."#"..teshudata["npc_13"].config[getplaydef(play, VarCfg["U_兰姐好感度"])].ratio, 1)
    end
    --仙食坊
    data = Player.getJsonTableByVar(play, VarCfg["T_仙食坊"])
    attrs = {}
    attrsstr = ""
    for i=1,5 do
        attrs[teshudata["npc_14"].config[i].attrID] = (data[""..i] or 0) * teshudata["npc_14"].config[i].ratio
    end
    attrsstr = Player.getAttrTableToStr(attrs)
    addattlist(play, "仙食坊", "=", attrsstr, 1)


    ------------------------------------------------------------通用属性
    local attr = {}
    Player.updateSomeAddr(play,nil, attr)
end

GameEvent.add(EventCfg.onLogin, Buff.login, "buff")


function Buff.chuan(play,item)
    local id = getstditeminfo(getiteminfo(play,item,2),8)
    if id > 0 and Buff[id]then
        Buff[id](play,1)
    end
end

function Buff.tuo(play,item)
    local id = getstditeminfo(getiteminfo(play,item,2),8)
    if id > 0 and Buff[id] then
        Buff[id](play,2)
    end
end
return Buff