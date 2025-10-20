npc = {}
--灵根

local _config = teshudata["npc_22"]

function npc.main(play,npcid)
    local data = {}
    data["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_灵根"])
    sendluamsg(play,100,npcid,0,0,tbl2json(data))
end

function npc.link(play,npcid,ew,aid)
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_灵根"])
    if ew == 1 then--抽取主灵根
        if not T_data.main then
            T_data.main = math.random(1, #_config.main_r)
            Player.setJsonVarByTable(play, VarCfg["T_灵根"], T_data)
            Player.sendmsgEx(play, "提示:#251|你获得了新的主灵根属性，请前往灵根升级界面查看")
        else
            Player.sendmsgEx(play, "提示:#251|你已经拥有主灵根属性，无法再次抽取")
            return
        end
    elseif ew == 2 then--抽取副灵根
        if not T_data.othen then
            T_data.othen = math.random(1, #_config.other_r)
            Player.setJsonVarByTable(play, VarCfg["T_灵根"], T_data)
            Player.sendmsgEx(play, "提示:#251|你获得了新的副灵根属性，请前往灵根升级界面查看")
        else
            Player.sendmsgEx(play, "提示:#251|你已经拥有副灵根属性，无法再次抽取")
            return
        end
    elseif ew == 3 then--洗练主灵根
        if not T_data.main then
            Player.sendmsgEx(play, "提示:#251|你还没有主灵根属性，无法进行洗练")
            return
        else
            local cost = _config.main_xl_cost
            local name, num = Player.checkItemNumByTable(play, cost)
            if name then
                Player.sendmsgEx(play, string.format("你的|%s#249|不足#249", name))
                return
            end
            Player.takeItemByTable(play, cost, ",灵根洗练",nil)
            T_data.main = math.random(1, #_config.main_r)
            Player.setJsonVarByTable(play, VarCfg["T_灵根"], T_data)
            Player.sendmsgEx(play, "提示:#251|你的主灵根属性洗练成功，请前往灵根升级界面查看")
        end
    elseif ew == 4 then--洗练副灵根
        if not T_data.othen then
            Player.sendmsgEx(play, "提示:#251|你还没有副灵根属性，无法进行洗练")
            return
        else
            local cost = _config.other_xl_cost
            local name, num = Player.checkItemNumByTable(play, cost)
            if name then
                Player.sendmsgEx(play, string.format("你的|%s#249|不足#249", name))
                return
            end
            Player.takeItemByTable(play, cost, ",灵根洗练",nil)
            T_data.othen = math.random(1, #_config.other_r)
            Player.setJsonVarByTable(play, VarCfg["T_灵根"], T_data)
            Player.sendmsgEx(play, "提示:#251|你的副灵根属性洗练成功，请前往灵根升级界面查看")
        end
    elseif ew == 5 then--主灵根升级
        if not T_data.othen then
            Player.sendmsgEx(play, "提示:#251|你还没有主灵根属性，无法进行升级")
            return
        else
            T_data.main.level = (T_data.main.level or 0) + 1
            if T_data.main.level > _config.main_updata.max_level then
                Player.sendmsgEx(play, "提示:#251|你的主灵根属性已经达到最高等级")
                return
            end
            local config = _config.main_updata[T_data.main.level]
            local name, num = Player.checkItemNumByTable(play, config.cost)
            if name then
                Player.sendmsgEx(play, string.format("你的|%s#249|不足#249", name))
                return
            end
            Player.takeItemByTable(play, config.cost, ",灵根升级",nil)
            Player.sendmsgEx(play, "提示:#251|你的主灵根属性升级成功")
            sendluamsg(play,101,1005,0,0,"jjcg")
        end
    elseif ew == 6 then--副灵根升级
        if not T_data.othen then
            Player.sendmsgEx(play, "提示:#251|你还没有副灵根属性，无法进行升级")
            return
        else
            T_data.othen.level = (T_data.othen.level or 0) + 1
            if T_data.othen.level > _config.other_updata.max_level then
                Player.sendmsgEx(play, "提示:#251|你的副灵根属性已经达到最高等级")
                return
            end
            local config = _config.other_updata[T_data.othen.level]
            local name, num = Player.checkItemNumByTable(play, config.cost)
            if name then
                Player.sendmsgEx(play, string.format("你的|%s#249|不足#249", name))
                return
            end
            Player.takeItemByTable(play, config.cost, ",灵根升级",nil)
            Player.sendmsgEx(play, "提示:#251|你的副灵根属性升级成功")
            sendluamsg(play,101,1005,0,0,"jjcg")
        end
    end
end

function Login_lg(play)
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_灵根"])
    --灵根技能
    --灵根属性
    --灵根特殊效果
    --灵根技能

end
GameEvent.add(EventCfg.onLogin, Login_lg, "Login_lg")


return npc