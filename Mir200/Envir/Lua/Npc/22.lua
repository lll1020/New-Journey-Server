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
    if ew == 1 and false then--抽取低级灵根
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
            Player.sendmsgEx(play, "提示:#251|你的灵根等级已经达到最高等级")
            return
        end
        local config = aid < 6 and _config.main_updata.details.low[T_data.level[""..aid]] or _config.main_updata.details.up[T_data.level[""..aid]]
        if not config then
            Player.sendmsgEx(play, "???????????#57")
            return
        end
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
        sendluamsg(play,100,npcid,2,0,tbl2json({["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_灵根"])}))

    end
end

function Login_lg(play)
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_灵根"])
    --灵根技能
    --灵根属性
    T_data.level = T_data.level or {}
    local attr = {}
    for i = 1, 10 do
        local level = T_data.level[""..i] or 0
        if level > 0 then
            for vv,kk in ipairs(_config.main_r[i].attr) do
                table.insert(attr,{kk[1],kk[2] * level})
            end
        end
    end
    Player.updateSomeAddr(play,nil, attr)

    --灵根特殊效果
    Buff[103](play,1)
    Buff[104](play,1)
    --灵根技能

end
GameEvent.add(EventCfg.onLogin, Login_lg, "Login_lg")

function npc.lgcf(play,zt,Damage,Target,triggerType)
    --灵根效果触发
    local sj = os.time()
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_灵根"])
    T_data.level = T_data.level or {}
    
    if not T_data.main then
        return 0
    end
    if not (T_data.level[""..T_data.main] and T_data.level[""..T_data.main] > 0) then
        return 0
    end
    local level = T_data.level[""..T_data.main]
    local config = _config.main_r[T_data.main]
    -- 木灵根护盾吸收逻辑：仅在受击触发时生效
    if triggerType == 2 and T_data.main == 2 then
        local shieldEnd = getplaydef(play,"N$buff_lg_mhd_end")
        local shieldVal = getplaydef(play,"N$buff_lg_mhd")
        if shieldEnd and shieldEnd < sj and shieldVal and shieldVal > 0 then
            setplaydef(play,"N$buff_lg_mhd",0)
            setplaydef(play,"N$buff_lg_mhd_end",0)
            shieldVal = 0
        end
        if shieldVal and shieldVal > 0 and shieldEnd and shieldEnd >= sj and Damage and Damage > 0 then
            local absorb = math.min(shieldVal, Damage)
            if absorb > 0 then
                setplaydef(play,"N$buff_lg_mhd",shieldVal - absorb)
                -- 通过同值回血抵消本次伤害，实现护盾吸收
                humanhp(play,"+",absorb,0,0,play)
            end
        end
    end
    if sj - getplaydef(play,"N$buff_lg") >= 30 then
        if T_data.main == 1 then--金
            addbuff(play,20104)
        elseif T_data.main == 2 then--木
            if triggerType == 2 then
                local shield = math.floor(level*config.value1*getbaseinfo(play, 20))
                setplaydef(play,"N$buff_lg_mhd",shield)
                setplaydef(play,"N$buff_lg_mhd_end",sj + 10)
            end
        elseif T_data.main == 3 then--水
            addbuff(play,20105)
        elseif T_data.main == 4 then--火
            addbuff(Target,20105,10,level,play)
        elseif T_data.main == 5 then--土
        elseif T_data.main == 6 then--雷
            addbuff(Target,20107,10,level,play)
        elseif T_data.main == 7 then--风
            Player.updateSomeAddr_time(play, nil, {{243, math.floor(level*config.value1*100)}},10)
        elseif T_data.main == 8 then--冰
            local xx,yy,dqdt = getbaseinfo(play,4),getbaseinfo(play,5),getbaseinfo(play,3)
            local mons,plays = getobjectinmap(dqdt, xx,yy, 3, 2),getobjectinmap(dqdt, xx,yy, 3, 1)
            -- if #mons > 1 then
            --     for i, v in ipairs(mons) do
            --         if i < 20 then
                        
            --         end
            --     end
            -- end
            if #plays > 1 then
                for i, v in ipairs(plays) do
                    if i < 20 then
                        Player.updateSomeAddr_time(v, {{243, math.floor(level*config.value1*100)}}, nil,10)
                        Player.updateSomeAddr_time(v, {{201, math.floor(level*config.value1)}}, nil,10)
                    end
                end
            end
        elseif T_data.main == 9 then--焚
            recallself(play,10,1,level*config.value1,0,0,0,0,0,0,"20108")
        elseif T_data.main == 10 then--岩
            addbuff(play,20109,level * 0.5,level,play)
        end
        setplaydef(play,"N$buff_lg",sj)
        if not T_data.other then
            return 0
        end
        --副灵根效果触发
        if not (T_data.level[""..T_data.other] and T_data.level[""..T_data.other] > 0) then
            return 0
        end
        level = T_data.level[""..T_data.other]
        config = _config.main_r[T_data.other]
        if T_data.other == 1 then--金
            humanhp(Target,"-",math.floor(level*config.value2),0,1,play)
        elseif T_data.other == 2 then--木
            Player.updateSomeAddr_time(play, nil, {{71, math.floor(level*config.value1*(getbaseinfo(play, 20) - getbaseinfo(play, 19))/10)}},10)
        elseif T_data.other == 3 then--水
            -- Player.updateSomeAddr_time(Target, {{243, 1000}}, nil,10)
        elseif T_data.other == 4 then--火
            addbuff(Target,20105,10,level,play)
        elseif T_data.other == 5 then--土
            Player.updateSomeAddr_time(play, nil, {{26, math.floor(level*config.value1*100)},{27, math.floor(level*config.value1*100)}},10)
        elseif T_data.other == 6 then--雷
            
        elseif T_data.other == 7 then--风
            Player.updateSomeAddr_time(play, nil, {{200, math.floor(level*config.value1)},{201, math.floor(level*config.value1)}},10)
        elseif T_data.other == 8 then--冰  有[冰灵根等级*2%]概率冰冻周围单位1秒
            if math.random(1,100) <= level * config.value2 then
                rangeharm(play,getbaseinfo(play,4),getbaseinfo(play,5),3,0,2,1,0,2,0)
            end
            
        elseif T_data.other == 9 then--焚
            rangeharm(play,getbaseinfo(play,4),getbaseinfo(play,5),3,level * config.value2,0,0,0,2,0)
        elseif T_data.other == 10 then--岩
            Player.updateSomeAddr_time(play, nil, {{206, math.floor(level*config.value1)}},10)
        end
            
        return 0
    end
    return 0

end


return npc