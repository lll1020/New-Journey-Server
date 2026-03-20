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
            Player.sendmsgEx(play, "灵根配置异常#57")
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
local function _lg_extract_title(desc, fallback)
    if type(desc) == "string" then
        local title = string.match(desc, "【(.-)】")
        if title and title ~= "" then
            return title
        end
    end
    return fallback or "灵根之力"
end
local function _lg_effect_short(lgCfg, isMain)
    local effectMapMain = {
        ["金"] = "范围切割",
        ["木"] = "获得护盾",
        ["水"] = "漩涡吸怪",
        ["火"] = "火焰斩击",
        ["土"] = "护体强化",
        ["雷"] = "落雷轰击",
        ["风"] = "移速提升",
        ["冰"] = "寒冬减速",
        ["焚"] = "召唤魔王",
        ["岩"] = "短暂无敌",
    }
    local effectMapOther = {
        ["金"] = "追加切割",
        ["木"] = "持续复苏",
        ["水"] = "迟缓目标",
        ["火"] = "点燃目标",
        ["土"] = "双防提升",
        ["雷"] = "雷闪避伤",
        ["风"] = "攻速提升",
        ["冰"] = "概率冰冻",
        ["焚"] = "天火坠落",
        ["岩"] = "伤害减免",
    }
    local effectMap = isMain and effectMapMain or effectMapOther
    return effectMap[tostring(lgCfg and lgCfg.name or "")] or "灵根生效"
end
local function _lg_send_trigger_msg(play, lgCfg, isMain)
    local title = _lg_extract_title(isMain and lgCfg.wz1 or lgCfg.wz2, (lgCfg.name or "未知").."灵根")
    local effect = _lg_effect_short(lgCfg, isMain)
    Player.sendmsgEx(play, "【灵根觉醒】#253|【"..tostring(title).."】#249|"..tostring(effect).."#250")
end
function npc.lgcf(play,zt,Damage,Target,triggerType)
    --灵根触发
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
    local mainTriggered = false
    local otherTriggered = false
    -- 木灵根护盾在受击时优先结算
    if triggerType == 2 and T_data.main == 2 then
        local shieldEnd = tonumber(getplaydef(play,"N$buff_lg_mhd_end") or 0) or 0
        local shieldVal = tonumber(getplaydef(play,"N$buff_lg_mhd") or 0) or 0
        if shieldEnd < sj and shieldVal > 0 then
            setplaydef(play,"N$buff_lg_mhd",0)
            setplaydef(play,"N$buff_lg_mhd_end",0)
            shieldVal = 0
        end
        if shieldVal > 0 and shieldEnd >= sj and Damage and Damage > 0 then
            local absorb = math.min(shieldVal, Damage)
            if absorb > 0 then
                setplaydef(play,"N$buff_lg_mhd",shieldVal - absorb)
                humanhp(play,"+",absorb,5,0,play)
                if shieldVal - absorb <= 0 then
                    clearplayeffect(play,60460)
                end
            end
        end
    end
    -- 土灵根护盾在受击时优先结算
    if triggerType == 2 and T_data.main == 5 then
        local shieldEnd = tonumber(getplaydef(play,"N$buff_lg_tu_end") or 0) or 0
        local shieldVal = tonumber(getplaydef(play,"N$buff_lg_tu") or 0) or 0
        if shieldEnd < sj and shieldVal > 0 then
            setplaydef(play,"N$buff_lg_tu",0)
            setplaydef(play,"N$buff_lg_tu_end",0)
            shieldVal = 0
        end
        if shieldVal > 0 and shieldEnd >= sj and Damage and Damage > 0 then
            local absorb = math.min(shieldVal, Damage)
            if absorb > 0 then
                setplaydef(play,"N$buff_lg_tu",shieldVal - absorb)
                humanhp(play,"+",absorb,5,0,play)
            end
        end
    end
    -- 火灵根持续斩击在攻击时结算
    if triggerType == 1 and T_data.main == 4 then
        local huoEnd = tonumber(getplaydef(play,"N$buff_lg_huo_end") or 0) or 0
        local huoTick = tonumber(getplaydef(play,"N$buff_lg_huo_tick") or 0) or 0
        local huoLv = tonumber(getplaydef(play,"N$buff_lg_huo_lv") or 0) or 0
        if huoEnd >= sj and huoLv > 0 and Target and sj - huoTick >= 1 then
            local fireDamage = math.floor(huoLv * (tonumber(config.value1) or 0))
            if fireDamage > 0 then
                setplaydef(play,"N$buff_lg_huo_tick",sj)
                humanhp(Target,"-",fireDamage,110,0,play,1)
                playeffect(Target,60463,0,0,1,1,0)
            end
        end
    end
    -- 岩灵根无敌期间免疫一切伤害
    if triggerType == 2 and T_data.main == 10 then
        local yanEnd = tonumber(getplaydef(play,"N$buff_lg_yan_end") or 0) or 0
        if yanEnd >= sj and Damage and Damage > 0 then
            humanhp(play,"+",Damage,5,0,play)
        end
    end
    -- 雷副灵根闪避在受击时优先判定
    if triggerType == 2 and T_data.other == 6 then
        local leiEnd = tonumber(getplaydef(play,"N$buff_lg_lei_end") or 0) or 0
        local leiRate = tonumber(getplaydef(play,"N$buff_lg_lei_rate") or 0) or 0
        if leiEnd >= sj and leiRate > 0 and Damage and Damage > 0 and math.random(100) <= leiRate then
            humanhp(play,"+",Damage,5,0,play)
            playeffect(play,60458,0,0,1,1,0)
        end
    end
    if sj - (tonumber(getplaydef(play,"N$buff_lg") or 0) or 0) >= 30 then
        if T_data.main == 1 then -- 金
            setobjintvar(play,22041,level)
            addbuff(play,20104,10)
            mainTriggered = true
        elseif T_data.main == 2 then -- 木
            if triggerType == 2 then
                local maxHp = tonumber(getbaseinfo(play,10) or 0) or 0
                local shield = math.floor(maxHp * level * (tonumber(config.value1) or 0) / 100)
                if shield > 0 then
                    setplaydef(play,"N$buff_lg_mhd",shield)
                    setplaydef(play,"N$buff_lg_mhd_end",sj + 10)
                    playeffect(play,60460,0,0,0,1,0)
                    mainTriggered = true
                end
            end
        elseif T_data.main == 3 then -- 水
            setobjintvar(play,22042,level)
            addbuff(play,20105,10)
            mainTriggered = true
        elseif T_data.main == 4 then -- 火
            setplaydef(play,"N$buff_lg_huo_end",sj + 10)
            setplaydef(play,"N$buff_lg_huo_lv",level)
            setplaydef(play,"N$buff_lg_huo_tick",0)
            if Target then
                local fireDamage = math.floor(level * (tonumber(config.value1) or 0))
                if fireDamage > 0 then
                    humanhp(Target,"-",fireDamage,110,0,play,1)
                    playeffect(Target,60463,0,0,1,1,0)
                end
            end
            mainTriggered = true
        elseif T_data.main == 5 then -- 土
            if triggerType == 2 then
                local shield = math.floor(level * (tonumber(config.value1) or 0))
                if shield > 0 then
                    setplaydef(play,"N$buff_lg_tu",shield)
                    setplaydef(play,"N$buff_lg_tu_end",sj + 10)
                    playeffect(play,60458,0,0,10,1,0)
                    mainTriggered = true
                end
            end
        elseif T_data.main == 6 then -- 雷
            if Target then
                setobjintvar(Target,22043,level)
                setobjstrvar(Target,22043,getbaseinfo(play,1) or "")
                addbuff(Target,20107,10,level,play)
                mainTriggered = true
            end
        elseif T_data.main == 7 then -- 风
            Player.updateSomeAddr_time(play, nil, {{243, math.floor(level * (tonumber(config.value1) or 0) * 100)}},10)
            playeffect(play,60036,0,0,10,1,0)
            mainTriggered = true
        elseif T_data.main == 8 then -- 冰
            if Target then
                local tx, ty, dqdt = getbaseinfo(Target,4), getbaseinfo(Target,5), getbaseinfo(play,3)
                local mons = getobjectinmap(dqdt, tx, ty, 3, 2) or {}
                local plays = getobjectinmap(dqdt, tx, ty, 3, 1) or {}
                for _, v in ipairs(mons) do
                    if v ~= Target then
                        Player.updateSomeAddr_time(v, {{243, math.floor(level * (tonumber(config.value1) or 0) * 100)},{201, math.floor(level * (tonumber(config.value1) or 0))}}, nil,10)
                        playeffect(v,60459,0,0,10,1,0)
                    end
                end
                for _, v in ipairs(plays) do
                    if v ~= play then
                        Player.updateSomeAddr_time(v, {{243, math.floor(level * (tonumber(config.value1) or 0) * 100)},{201, math.floor(level * (tonumber(config.value1) or 0))}}, nil,10)
                        playeffect(v,60459,0,0,10,1,0)
                    end
                end
                mainTriggered = true
            end
        elseif T_data.main == 9 then -- 焚
            recallself(play,10,1,level * (tonumber(config.value1) or 0),0,0,0,0,0,0,"20108")
            mainTriggered = true
        elseif T_data.main == 10 then -- 岩
            setplaydef(play,"N$buff_lg_yan_end",sj + math.max(1, math.ceil(level * (tonumber(config.value1) or 0))))
            playeffect(play,60458,0,0,10,1,0)
            mainTriggered = true
        end
        setplaydef(play,"N$buff_lg",sj)
        if mainTriggered then
            _lg_send_trigger_msg(play, config, true)
        end
        if not T_data.other then
            return 0
        end
        -- 副灵根效果
        if not (T_data.level[""..T_data.other] and T_data.level[""..T_data.other] > 0) then
            return 0
        end
        level = T_data.level[""..T_data.other]
        config = _config.main_r[T_data.other]
        if T_data.other == 1 then -- 金
            if Target then
                humanhp(Target,"-",math.floor(level * (tonumber(config.value2) or 0)),110,1,play)
                otherTriggered = true
            end
        elseif T_data.other == 2 then -- 木
            local curHp = tonumber(getbaseinfo(play,9) or 0) or 0
            local maxHp = tonumber(getbaseinfo(play,10) or 0) or 0
            local heal = math.floor(math.max(0, maxHp - curHp) * level * (tonumber(config.value2) or 0) / 100)
            if heal > 0 then
                humanhp(play,"+",heal,5,0,play)
                otherTriggered = true
            end
        elseif T_data.other == 3 then -- 水
            if Target then
                Player.updateSomeAddr_time(Target, {{243, math.floor(level * (tonumber(config.value2) or 0) * 100)}}, nil,10)
                otherTriggered = true
            end
        elseif T_data.other == 4 then -- 火
            if Target then
                setobjintvar(Target,22045,math.floor(level * (tonumber(config.value2) or 0)))
                setobjstrvar(Target,22045,getbaseinfo(play,1) or "")
                addbuff(Target,20105,10,level,play)
                otherTriggered = true
            end
        elseif T_data.other == 5 then -- 土
            Player.updateSomeAddr_time(play, nil, {{26, math.floor(level * (tonumber(config.value2) or 0) * 100)},{27, math.floor(level * (tonumber(config.value2) or 0) * 100)}},10)
            otherTriggered = true
        elseif T_data.other == 6 then -- 雷
            setplaydef(play,"N$buff_lg_lei_end",sj + 10)
            setplaydef(play,"N$buff_lg_lei_rate",math.floor(level * (tonumber(config.value2) or 0)))
            otherTriggered = true
        elseif T_data.other == 7 then -- 风
            Player.updateSomeAddr_time(play, nil, {{200, math.floor(level * (tonumber(config.value2) or 0))},{201, math.floor(level * (tonumber(config.value2) or 0))}},10)
            otherTriggered = true
        elseif T_data.other == 8 then -- 冰
            if math.random(1,100) <= level * (tonumber(config.value2) or 0) then
                rangeharm(play,getbaseinfo(play,4),getbaseinfo(play,5),3,0,2,1,0,2,0)
                otherTriggered = true
            end
        elseif T_data.other == 9 then -- 焚
            rangeharm(play,getbaseinfo(play,4),getbaseinfo(play,5),3,level * (tonumber(config.value2) or 0),0,0,0,2,0)
            otherTriggered = true
        elseif T_data.other == 10 then -- 岩
            Player.updateSomeAddr_time(play, nil, {{206, math.floor(level * (tonumber(config.value2) or 0) * 100)}},10)
            otherTriggered = true
        end
        if otherTriggered then
            _lg_send_trigger_msg(play, config, false)
        end
        return 0
    end
    return 0
end
return npc
