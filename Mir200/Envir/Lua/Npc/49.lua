npc = {}


--

local _config = Guard.getConfig("npc_49")

function npc.main(play,npcid)
    if not Player.ensureThirdContinentPass(play, '请先完成#57|【灾厄入侵】#249|后再使用该功能#57') then
        return
    end
    local data = {}
    data["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_八卦"])
    sendluamsg(play,100,npcid,0,0,tbl2json(data))
end

function npc.link(play,npcid,ew,aid,data)
    if not Player.ensureThirdContinentPass(play, '请先完成#57|【灾厄入侵】#249|后再使用该功能#57') then
        return
    end
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
    local __guardAllowedActions = Guard.newActionSet({1})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end

    if ew == 1 then --
        local T_data = Player.getJsonTableByVar(play, VarCfg["T_八卦"])

        --从8个里面随机一个没有激活的
        local unactivated = {}
        for v,k in ipairs(_config.details) do
            if not T_data[""..v] or T_data[""..v] ~= 1 then
                table.insert(unactivated, v)
            end
        end
        if #unactivated == 0 then
            Player.sendmsgEx(play, "你已经激活完成了所有卦象")
            return
        end
        local random_index = math.random(1, #unactivated)
        local idx = unactivated[random_index]


        local name, num = Player.checkItemNumByTable(play, _config.cost)
        if name then
            Player.sendmsgEx(play, string.format("你的#57|【%s】#249|不足：#57|【%d】#249|", name, num))
            return
        end
        Player.takeItemByTable(play, _config.cost, ",八卦",nil)

        T_data[""..idx] = 1
        Player.setJsonVarByTable(play, VarCfg["T_八卦"], T_data)

        if #unactivated == 1 then
            Player.title_give(play, _config.ch)
            Player.sendmsgEx(play,  "恭喜你，获得称号：|【".._config.ch.."】#249|")
        end

        local data = {}
        data["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_八卦"])
        sendluamsg(play,100,npcid,0,0,tbl2json(data))
        delattlist(play, "八卦属性")
        Login_bg(play)

    end
end


function Login_bg(play)
    local attrs = {}
    local attrsstr = ""
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_八卦"])
    
    for v,k in ipairs(_config.details) do
        if T_data[""..v] and T_data[""..v] == 1 then
            for v,k in ipairs(k.attr) do
                attrs[k[1]] = k[2]
            end
            
        end
    end
    attrsstr = Player.getAttrTableToStr(attrs)
    addattlist(play, "八卦属性", "=", attrsstr, 1)
end
GameEvent.add(EventCfg.onLogin, Login_bg, "Login_bg")


return npc