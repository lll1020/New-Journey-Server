npc = {}


--古玩鉴定

local _config = Guard.getConfig("npc_65")

function npc.main(play,npcid)
    sendluamsg(play,100,npcid,0,0,"{}")
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
    local __guardAllowedActions = Guard.newActionSet({1})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end
    

    if ew == 1 then -- 鉴定古玩
        if data == "" then
            return
        end
        local json_data = json2tbl(data) or {}
        local idx = tonumber(json_data.idx)
        if not idx or idx < 1 or idx > #_config.config then
            Player.sendmsgEx(play, "参数错误#57")
            return
        end
        json_data.idx = idx
        local name, num = Player.checkItemNumByTable(play, _config.config[json_data.idx].cost or {})
        if name then
            Player.sendmsgEx(play, string.format("你的#57|【%s】#249|不足：#57|【%d】#249|", name, num))
            return
        end
        Player.takeItemByTable(play, _config.config[json_data.idx].cost or {}, ",古玩鉴定",nil)
        local randomNum = ransjstr(_config.config[json_data.idx].weight, 1, 3)
        randomNum = tonumber(randomNum)

        local awardItem = _config.config[json_data.idx].jl[randomNum]
        -- Player.rwjl(play,{awardItem},"古玩鉴定",nil)

        local itemobj = giveitem(play, awardItem[1], 1,850)
        Player.sendmsgEx(play, string.format("你成功鉴定出|【%s】#249|x%d", awardItem[1], awardItem[2]))
        sendluamsg(play,100,npcid,1,0,tbl2json({item = awardItem[1]}))
        

        local attrs = {}
        local attrsstr = ""
        for k,v in ipairs(_config.config[json_data.idx].ex_attr or {}) do
            attrs[v[1]] = v[2] * _config.ex_attr_ratio[randomNum]
        end
        attrsstr = Player.getAttrTableToStr(attrs)
        setaddnewabil(play, -2, "=",attrsstr, itemobj)
        refreshitem(play, itemobj)
        


        
    end
end


return npc
