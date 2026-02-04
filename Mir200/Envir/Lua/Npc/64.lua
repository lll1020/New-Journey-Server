npc = {}


--灵兽

local _config = Guard.getConfig("npc_64")

function npc.main(play,npcid)
    if not Player.dl_sz(play, 4) then
        Player.sendMsg(play,1,'{"Msg":"<font color=\'#ff0000\'>灵兽系统需要达到四大陆后开启！</font>","Type":1}')
        return
    end
    local data = {}
    data["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_灵兽"])
    sendluamsg(play,100,npcid,0,0,tbl2json(data))
end

function npc.link(play,npcid,ew,aid,data)
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
    local __guardAllowedActions = Guard.newActionSet({1,2,3,4,5})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end
    local json_data = json2tbl(data) or {}
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_灵兽"])

    if ew ~= 1 then
        local idx = tonumber(json_data.idx)
        if not idx or not _config.config or not _config.config.ls or not _config.config.ls[idx] then
            Player.sendmsgEx(play, "????#57")
            return
        end
        json_data.idx = idx
    end

    if ew == 1 then -- 抽取灵兽
        local name, num = Player.checkItemNumByTable(play, _config.cost)
        if name then
            Player.sendmsgEx(play, string.format("你的|%s#249|不足|%d#249", name, num))
            return
        end
        Player.takeItemByTable(play, _config.cost, ",灵兽抽取",nil)
        local randomNum = ransjstr(_config.weight, 1, 3)
        randomNum = tonumber(randomNum)
        T_data.ls = T_data.ls or {}
        T_data.ls_sp = T_data.ls_sp or {}
        if not T_data.ls[""..randomNum] then
            T_data.ls[""..randomNum] = 1
            T_data.ls_sp[""..randomNum] = 1
            Player.sendmsgEx(play, string.format("你成功抽取到灵兽|%s#249|x1", _config.config.ls[randomNum].name))
            Player.sendmsgEx(play, "你已获得该灵兽的初始星级，快去召唤它吧#57")
            Player.setJsonTableByVar(play, VarCfg["T_灵兽"], T_data)
            sendluamsg(play,100,npcid,1,0,tbl2json({T_data = T_data}))
            Player.updateSomeAddr(play,nil, _config.config.ls[randomNum].attr_give)
            Player.updateSomeAddr(play,nil, _config.config.wy.det[T_data.ls[""..randomNum]].attr)
        else
        -- 最大星级4
            if T_data.ls_sp[""..randomNum] >= _config.max_star then
                Player.sendmsgEx(play, string.format("你抽取到的灵兽|%s#249|已达最大星级,转换为材料", _config.config.ls[randomNum].name))
                Player.rwjl(play, {{"灵兽丹",3},{"灵石",500},{"妖怪精魄",10}}, "灵兽抽取",1,1000)
                return
            end
            T_data.ls_sp[""..randomNum] = T_data.ls_sp[""..randomNum] + 1
            Player.sendmsgEx(play, string.format("你成功抽取到灵兽|%s#249|x1|已自动转换为星级", _config.config.ls[randomNum].name))
            Player.setJsonTableByVar(play, VarCfg["T_灵兽"], T_data)
            sendluamsg(play,100,npcid,1,0,tbl2json({T_data = T_data}))
        end
        -- T_data.ls_sp[randomNum] = (T_data.ls_sp[randomNum] or 0) + 1
        -- Player.setJsonTableByVar(play, VarCfg["T_灵兽"], T_data)
        -- sendluamsg(play, 100, npcid, 1, randomNum, "")
    elseif ew == 2 then -- 召唤灵兽
        T_data.ls = T_data.ls or {}
        -- T_data.ls_sp 
        T_data.ls_sp = T_data.ls_sp or {}
        if not T_data.ls[""..json_data.idx] or T_data.ls[""..json_data.idx] <= 0 then
            Player.sendmsgEx(play, "你没有该灵兽，请先抽取灵兽")
            return
        end
        local Tlg_data = Player.getJsonTableByVar(play, VarCfg["T_灵根"])
        T_data.dqzh = json_data.idx
        Player.setJsonTableByVar(play, VarCfg["T_灵兽"], T_data)
        Login_lszh(play)
        if Tlg_data.main and (Tlg_data.main == _config.config.ls[json_data.idx].yq[1] or Tlg_data.main == _config.config.ls[json_data.idx].yq[2]) then
            Player.sendmsgEx(play, string.format("你成功出战了灵兽|%s#249|，快去战斗吧！", _config.config.ls[json_data.idx].name))
        else
            Player.sendmsgEx(play, "你的主灵根与该灵兽的契约灵根冲突，可能无法出战该灵兽,请切换主灵根")
        end
        
    elseif ew == 3 then -- 灵兽升级 --喂养
        T_data.ls = T_data.ls or {}
        -- T_data.ls_sp 
        T_data.ls_sp = T_data.ls_sp or {}
        if not T_data.ls[""..json_data.idx] or T_data.ls[""..json_data.idx] <= 0 then
            Player.sendmsgEx(play, "你没有该灵兽，请先抽取灵兽")
            return
        end

        if T_data.ls[""..json_data.idx] >= _config.config.wy.max_level then
            Player.sendmsgEx(play, "该灵兽已达最大喂养次数，无法继续喂养")
            return
        end
        local name, num = Player.checkItemNumByTable(play, _config.config.wy.cost[T_data.ls[""..json_data.idx] + 1] or {})
        if name then
            Player.sendmsgEx(play, string.format("你的|%s#249|不足|%d#249", name, num))
            return
        end
        Player.takeItemByTable(play, _config.config.wy.cost[T_data.ls[""..json_data.idx] + 1] or {}, ",灵兽喂养",nil)
        T_data.ls[""..json_data.idx] = T_data.ls[""..json_data.idx] + 1
        Player.setJsonTableByVar(play, VarCfg["T_灵兽"], T_data)
        Player.updateSomeAddr(play,_config.config.wy.det[T_data.ls[""..json_data.idx] - 1] and _config.config.wy.det[T_data.ls[""..json_data.idx] - 1].attr or nil, _config.config.wy.det[T_data.ls[""..json_data.idx]].attr)
        sendluamsg(play,100,npcid,3,0,tbl2json({T_data = T_data}))
        Player.sendmsgEx(play, string.format("你成功喂养灵兽|%s#249|，当前喂养次数|%d#249|", _config.config.ls[json_data.idx].name, T_data.ls[""..json_data.idx]))
    elseif ew == 4 then -- 灵兽升星
    elseif ew == 5 then -- 灵兽装备圣遗物
        T_data.ls = T_data.ls or {}
        -- T_data.ls_sp 
        T_data.syw = T_data.syw or {}
        if not T_data.ls[""..json_data.idx] or T_data.ls[""..json_data.idx] <= 0 then
            Player.sendmsgEx(play, "你没有该灵兽，请先抽取灵兽")
            return
        end
        if T_data.syw[""..json_data.idx] and T_data.syw[""..json_data.idx] == 1 then
            Player.sendmsgEx(play, "该灵兽已装备圣遗物，无需重复装备#57")
            return
        end
        local name, num = Player.checkItemNumByTable(play, {{_config.config.ls[json_data.idx].syw,1}})
        if name then
            Player.sendmsgEx(play, string.format("你的|%s#249|不足|%d#249", name, num))
            return
        end
        Player.takeItemByTable(play, {{_config.config.ls[json_data.idx].syw,1},{"元宝",1880000}}, ",灵兽圣遗物",nil)
        T_data.syw[""..json_data.idx] = 1
        Player.setJsonTableByVar(play, VarCfg["T_灵兽"], T_data)
        sendluamsg(play, 100, npcid, 1, 0, tbl2json({T_data = T_data}))
        Player.sendmsgEx(play, string.format("你成功为灵兽|%s#249|装备了圣遗物|%s#249|", _config.config.ls[json_data.idx].name, _config.config.ls[json_data.idx].syw))

        if T_data.syw["1"] and T_data.syw["2"] and T_data.syw["3"] and T_data.syw["4"] and T_data.syw["5"] and not T_data.syw_all then
            T_data.syw_all = 1
            Player.setJsonTableByVar(play, VarCfg["T_灵兽"], T_data)
            Player.title_give(play, _config.syw_ch)
            Player.sendmsgEx(play, "恭喜你为所有灵兽装备了圣遗物，获得了|上古神兽掌控者#249|称号#57")
            sendluamsg(play,100,npcid,1,0,"")
        end

            
        
    end
end

function Login_lszh(play)
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_灵兽"])
    T_data.ls = T_data.ls or {}
    for i = 1,5 do
        T_data.ls[""..i] = T_data.ls[""..i] or 0
        if T_data.ls[""..i] > 0 then
            Player.updateSomeAddr(play,nil, _config.config.wy.det[T_data.ls[""..i]].attr)
        end
    end
    if T_data.dqzh and _config.config.ls[T_data.dqzh] then
        Player.updateSomeAddr(play,nil, _config.config.ls[T_data.dqzh].attr_give)
    end
    
    Buff[105](play,1)
end
GameEvent.add(EventCfg.onLogin, Login_lszh, "灵兽召唤")

function npc.lscf(play,zt,Damage,Target)

    local sj = os.time()
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_灵兽"])
    T_data.ls = T_data.ls or {}
    
    if not T_data.dqzh or not _config.config.ls[T_data.dqzh] then
        return 0
    end
    local Tlg_data = Player.getJsonTableByVar(play, VarCfg["T_灵根"])
    if Tlg_data.main and (Tlg_data.main == _config.config.ls[T_data.dqzh].yq[1] or Tlg_data.main == _config.config.ls[T_data.dqzh].yq[2]) then
        if sj - getplaydef(play,"N$buff_ls") >= 30 then
            local cw = recallmobex(play, _config.config.ls[T_data.dqzh].name,0,0,7,1,_config.config.wy.det[T_data.ls[""..T_data.dqzh]].time,0,0,0,0,0,0,"")
            sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[灵兽]</font><font color=\'#00ff00\'>成功召唤灵兽【'.._config.config.ls[T_data.dqzh].name..'】...</font>","Type":9}')
            setplaydef(play,"N$buff_ls",sj)
            Player.updateSomeAddr_time(play,nil, _config.config.ls[T_data.dqzh].b_attr,_config.config.wy.det[T_data.ls[""..T_data.dqzh]].time)
        end
    end
    return 0
end


return npc
