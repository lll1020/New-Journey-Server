
npc = {}
--装备强化

local _config = teshudata["npc_28"]


function npc.main(play,npcid)
    local data = {}
    for k,v in pairs(_config.where) do
        data[k] = getplaydef(play, VarCfg["U_装备强化_"..v[1]])
    end
    sendluamsg(play,100,npcid,0,0,tbl2json(data))
end

function npc.link(play,npcid,ew,aid)
    if ew == 1 then
        if _config.where[aid] then
            local itemobj = linkbodyitem(play, aid)
            if itemobj then
                --getitemaddvalue(play, itemobj, 2, 3)
                local level = getplaydef(play, VarCfg["U_装备强化_".._config.where[aid][1]])
                if level >= _config.max_level then
                    Player.sendmsgEx(play, "该部位装备强化已达最高等级#249")
                    return
                end
                local nextLevel = level + 1
                local cfg = _config.details[nextLevel]
                local name, num = Player.checkItemNumByTable(play, cfg.cost)
                if name then
                    Player.sendmsgEx(play, string.format("你的|%s#249|不足|%d#249", name, num))
                    return
                end
                Player.takeItemByTable(play, cfg.cost, ",装备强化",nil)
                setplaydef(play, VarCfg["U_装备强化_".._config.where[aid][1]], nextLevel)
                setitemaddvalue(play, itemobj, 2, 3, nextLevel) --星星
                --强化属性
                local attrs = {}
                local attrsstr = ""
                for k,v in ipairs(cfg.attr) do
                    attrs[v[1]] = v[2]
                end
                attrsstr = Player.getAttrTableToStr(attrs)
                setaddnewabil(play, -2, "=",attrsstr, itemobj)
                refreshitem(play, itemobj)
                recalcabilitys(play)
                sendluamsg(play,100,npcid,1,aid,"")

                if nextLevel == 10 or nextLevel == 20 or nextLevel ==30 then
                    Player.sendmsgEx(play, "恭喜你，|".._config.where[aid][1].."#249|部位的装备强化提升到了|"..nextLevel.."级#249|，属性大幅提升！")
                    delattlist(play, "装备强化")
                    Login_zbqh(play)
                else
                    Player.sendmsgEx(play, "恭喜你，|".._config.where[aid][1].."#249|部位的装备强化提升到了|"..nextLevel.."级#249|")
                end
            else
                Player.sendmsgEx(play, "请先穿戴对应部位的装备#249")
                return
            end
        else
            Player.sendmsgEx(play, "参数错误!#249")
            return
        end

    end
end


--清理附加属性封装
local function convert_str(str)
    local result = {}
    for pair in string.gmatch(str, "([^,]+)") do
        local key, value = string.match(pair, "(%d+)=(%d+)")
        table.insert(result, "3#" .. key .. "#0")
    end
    return table.concat(result, "|")
end

--穿装备
local function _onTakeOnEx(actor, itemobj, where, itemname, makeid)
    if _config.where[where] then
        local level = getplaydef(actor, VarCfg["U_装备强化_".._config.where[where][1]])
        local cfg = _config.details[level]
        if level <= 0 then
            return
        end
        --强化属性
        local attrs = {}
        local attrsstr = ""
        for k,v in ipairs(cfg.attr) do
            attrs[v[1]] = v[2]
        end
        attrsstr = Player.getAttrTableToStr(attrs)
        setaddnewabil(actor, -2, "=",attrsstr, itemobj)
        refreshitem(actor, itemobj)
        recalcabilitys(actor)
    end
end

--脱装备
local function _onTakeOffEx(actor, itemobj, where, itemname, makeid)
    if _config.where[where] then
        local attr = json2tbl(getitemcustomabil(actor,itemobj))
        local temp_str = convert_str(attr.abilex)
        release_print("temp_str",temp_str)
        setaddnewabil(actor, -2, "=",temp_str, itemobj)
        refreshitem(actor, itemobj)
    end
end

function Login_zbqh(play)
    local data = {}
    local min = 99
    for k,v in pairs(_config.where) do
        data[k] = getplaydef(play, VarCfg["U_装备强化_"..v[1]])
        if min > data[k] then
            min = data[k]
        end
    end
    if min ~= 99 and min > 0 then
        local attrs = {}
        local attrsstr = ""
        local idx = 0
        if min >= 30 then
            idx = 3
        elseif min >= 20 then
            idx = 2
        elseif min >= 10 then
            idx = 1
        end
        if idx == 0 then
            return
        end
        for v,k in ipairs(_config.other_attr[idx]) do
            attrs[k[1]] = k[2]
        end
        attrsstr = Player.getAttrTableToStr(attrs)
        addattlist(play, "装备强化", "=", attrsstr, 1)
    end
end
GameEvent.add(EventCfg.onLogin, Login_zbqh, "Login_zbqh")

--穿装备触发
GameEvent.add(EventCfg.onTakeOnEx, _onTakeOnEx, "装备强化")

--脱装备触发
GameEvent.add(EventCfg.onTakeOffEx, _onTakeOffEx, "装备强化")


return npc