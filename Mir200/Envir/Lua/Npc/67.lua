npc = {}


--生肖守护

local _config = Guard.getConfig("npc_67")

function npc.main(play,npcid)
    local data = {}
    data["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_生肖守护"])
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
    local __guardAllowedActions = Guard.newActionSet({1,2})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end

    if data == "" then
        return
    end
    local json_data = json2tbl(data) or {}
    

    if ew == 1 then -- 

        local T_data = Player.getJsonTableByVar(play, VarCfg["T_生肖守护"])

        local idx = tonumber(json_data.idx)
        if not idx or not _config.details[idx] then
            Player.sendmsgEx(play, "参数错误#57")
            return
        end
        json_data.idx = idx



        if T_data[""..json_data.idx] and T_data[""..json_data.idx] == 1 then
            Player.sendmsgEx(play, "该生肖守护你已激活，无需重复激活#57")
            return
        end

        local name, num = Player.checkItemNumByTable(play, _config.details[json_data.idx].cost or {})
        if name then
            Player.sendmsgEx(play, string.format("你的|%s#249|不足|%d#249", name, num))
            return
        end
        Player.takeItemByTable(play, _config.details[json_data.idx].cost or {}, ",生肖守护",nil)

        T_data[""..json_data.idx] = 1
        Player.setJsonTableByVar(play, VarCfg["T_生肖守护"], T_data)
        Player.sendmsgEx(play, string.format("你成功激活了|%s#249|守护#57", _config.details[json_data.idx].name))
        sendluamsg(play,100,npcid,1,json_data.idx,"")

        if T_data["1"] and T_data["2"] and T_data["3"] and T_data["4"] and not T_data["jl1"] then
            -- 全部激活，发奖励
            T_data["jl1"] = 1
            Player.setJsonTableByVar(play, VarCfg["T_生肖守护"], T_data)
            Player.updateSomeAddr(play,nil, {{81,300}})
            Player.giveItemByTable(play, _config.details.jl[1].give or {}, "生肖守护全激活奖励", nil)
            Player.sendmsgEx(play, "恭喜你激活了第一层生肖守护，获得了|生肖守护神#249|奖励#57")
            sendluamsg(play,100,npcid,2,1,"")
        elseif T_data["5"] and T_data["6"] and T_data["7"] and T_data["8"] and not T_data["jl2"] then
            -- 全部激活，发奖励
            T_data["jl2"] = 1
            Player.setJsonTableByVar(play, VarCfg["T_生肖守护"], T_data)
            Player.updateSomeAddr(play,nil, {{79,300}})
            Player.giveItemByTable(play, _config.details.jl[2].give or {}, "生肖守护全激活奖励", nil)
            Player.sendmsgEx(play, "恭喜你激活了第二层生肖守护，获得了|生肖守护神#249|奖励#57")
            sendluamsg(play,100,npcid,2,2,"")
        elseif T_data["9"] and T_data["10"] and T_data["11"] and T_data["12"] and not T_data["jl3"] then
            -- 全部激活，发奖励
            T_data["jl3"] = 1
            Player.setJsonTableByVar(play, VarCfg["T_生肖守护"], T_data)
            Player.updateSomeAddr(play,nil, {{22,3}})
            Player.giveItemByTable(play, _config.details.jl[3].give or {}, "生肖守护全激活奖励", nil)
            Player.sendmsgEx(play, "恭喜你激活了第三层生肖守护，获得了|生肖守护神#249|奖励#57")
            sendluamsg(play,100,npcid,2,3,"")
           
        end
        if T_data["jl1"] and T_data["jl2"] and T_data["jl3"] and not T_data["jl_all"] then
            T_data["jl_all"] = 1
            Player.setJsonTableByVar(play, VarCfg["T_生肖守护"], T_data)
            Player.title_give(play, _config.ch)
            Player.sendmsgEx(play, "恭喜你激活了全部生肖守护，获得了|生肖守护神#249|奖励#57")
            sendluamsg(play,100,npcid,2,4,"")
        end


    end
end

function Login_sxsh(play)
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_生肖守护"])
    if T_data["jl1"] then Player.updateSomeAddr(play,nil, {{81,300}}) end
    if T_data["jl2"] then Player.updateSomeAddr(play,nil, {{79,300}}) end
    if T_data["jl3"] then Player.updateSomeAddr(play,nil, {{22,3}}) end
    
end
GameEvent.add(EventCfg.onLogin, Login_sxsh, "Login_生肖守护")


return npc

