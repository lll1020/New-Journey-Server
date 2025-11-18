npc = {}


--灵根

local _config = Guard.getConfig("npc_22")

function npc.main(play,npcid)
    local data = {}
    data["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_灵根"])
    sendluamsg(play,100,npcid,0,0,tbl2json(data))
end

function npc.link(play,npcid,ew,aid)
    -- npc_guard: 入参校验
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local __guardAction = Guard.normalizeAction(play, npcid, ew)
    if __guardAction == nil then
        return
    end
    ew = __guardAction
    -- npc_guard: 操作白名单（优化：限定合法操作编号）
    local __guardAllowedActions = Guard.newActionSet({1, 2, 3, 5})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end

    local T_data = Player.getJsonTableByVar(play, VarCfg["T_灵根"])
    T_data.level = T_data.level or {}
    if ew == 1 then--抽取低级灵根
        T_data.level[""..math.random(1, 5)] = 0
        Player.setJsonVarByTable(play, VarCfg["T_灵根"], T_data)
        Player.sendmsgEx(play, "提示:#251|你获得了新的灵根，请前往灵根升级界面查看")
        sendluamsg(play,100,npcid,1,0,tbl2json({["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_灵根"])}))

    elseif ew == 2 then--装配主灵根
        if aid == 0 then
            T_data.main = nil
            Player.setJsonVarByTable(play, VarCfg["T_灵根"], T_data)
            Player.sendmsgEx(play, "提示:#251|你的主灵根已卸下")
            sendluamsg(play,100,npcid,1,0,tbl2json({["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_灵根"])}))
            return
        end
        T_data.level = T_data.level or {}

        T_data.main = T_data.main or 0
        if T_data.main == aid then
            Player.sendmsgEx(play, "提示:#251|你已经装配该灵根属性，无需重复装配")
            return
        end
        if not T_data.level[""..aid] then
            Player.sendmsgEx(play, "提示:#251|你还没有该灵根属性，无法进行装配")
            return
        end
        if T_data.other and T_data.other == aid then
            Player.sendmsgEx(play, "提示:#251|该灵根属性已经被装配为副灵根，无法装配为主灵根")
            return
        end
        T_data.main = aid
        Player.setJsonVarByTable(play, VarCfg["T_灵根"], T_data)
        Player.sendmsgEx(play, "提示:#251|你的灵根装配成功")
        sendluamsg(play,100,npcid,1,0,tbl2json({["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_灵根"])}))

    elseif ew == 3 then--装配副灵根
        T_data.other = T_data.other or 0
        if aid == 0 then
            T_data.other = nil
            Player.setJsonVarByTable(play, VarCfg["T_灵根"], T_data)
            Player.sendmsgEx(play, "提示:#251|你的副灵根已卸下")
            sendluamsg(play,100,npcid,1,0,tbl2json({["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_灵根"])}))
            return
        end
        T_data.level = T_data.level or {}

        if T_data.other == aid then
            Player.sendmsgEx(play, "提示:#251|你已经装配该灵根属性，无需重复装配")
            return
        end
        if not T_data.level[""..aid] then
            Player.sendmsgEx(play, "提示:#251|你还没有该灵根属性，无法进行装配")
            return
        end
        if T_data.main and T_data.main == aid then
            Player.sendmsgEx(play, "提示:#251|该灵根属性已经被装配为主灵根，无法装配为副灵根")
            return
        end
        T_data.other = aid
        Player.setJsonVarByTable(play, VarCfg["T_灵根"], T_data)
        Player.sendmsgEx(play, "提示:#251|你的灵根装配成功")
        sendluamsg(play,100,npcid,1,0,tbl2json({["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_灵根"])}))

    elseif ew == 5 then--灵根升级
        T_data.level = T_data.level or {}

        if not T_data.level[""..aid] then
            Player.sendmsgEx(play, "提示:#251|你还没有该灵根属性，无法进行升级")
            return
        end
        T_data.level[""..aid] = (T_data.level[""..aid] or 0) + 1
        if T_data.level[""..aid] > _config.main_updata.max_level then
            Player.sendmsgEx(play, "提示:#251|你的主灵根属性已经达到最高等级")
            return
        end
        local config = aid < 6 and _config.main_updata.details.low[T_data.level[""..aid]] or _config.main_updata.details.up[T_data.level[""..aid]]
        local name, num = Player.checkItemNumByTable(play, config.cost)
        if name then
            Player.sendmsgEx(play, string.format("你的|%s#249|不足#249", name))
            return
        end
        Player.takeItemByTable(play, config.cost, ",灵根升级",nil)

        Player.setJsonVarByTable(play, VarCfg["T_灵根"], T_data)
        Player.sendmsgEx(play, "提示:#251|你的灵根升级成功")
        Player.updateSomeAddr(play,nil, _config.main_r[aid].attr)

        sendluamsg(play,101,1005,0,0,"tpcg")
        sendluamsg(play,100,npcid,1,0,tbl2json({["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_灵根"])}))

    end
end

function Login_lg(play)
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_灵根"])
    --灵根技能
    --灵根属性
    T_data.level = T_data.level or {}
    local attr = {}
    for i = 1, 5 do
        local level = T_data.level[""..i] or 0
        if level > 0 then
            for vv,kk in ipairs(_config.main_r[i].attr) do
                table.insert(attr,{kk[1],kk[2] * level})
            end
        end
    end
    Player.updateSomeAddr(play,nil, attr)

    --灵根特殊效果
    --灵根技能

end
GameEvent.add(EventCfg.onLogin, Login_lg, "Login_lg")


return npc