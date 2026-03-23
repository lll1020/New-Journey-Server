npc = {}


--升级1

local _config = Guard.getConfig("npc_70")

function npc.main(play,npcid)
    local equipname = Player.getEquipNameByPos(play, _config.where)
    if equipname ~= _config.now then
        Player.sendmsgEx(play, "请先装备#57|【".._config.now.."】#249|进行升级#57")
        return
    end
    sendluamsg(play,100,npcid,0,0,tbl2json({num = getplaydef(play, VarCfg["J_醉意值"])}))
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

    local equipname = Player.getEquipNameByPos(play, _config.where)
    if equipname ~= _config.now then
        Player.sendmsgEx(play, "请先装备#57|【".._config.now.."】#249|进行升级#57")
        return
    end

    local json_data = json2tbl(data) or {}

    if ew == 1 then -- 做酒水

        local idx = tonumber(json_data.idx)
        if not idx or not _config.cost or not _config.cost[idx] or not _config.weight or not _config.weight[idx] then
            Player.sendmsgEx(play, "参数错误#57")
            return
        end
        json_data.idx = idx


        local curzuiyi = getplaydef(play, VarCfg["J_醉意值"])
        if curzuiyi >= _config.max_zuiyi then
            Player.sendmsgEx(play, string.format("你的醉意值已达上限#57|【%d】#249|，无法继续饮用酒水#57", _config.max_zuiyi))
            return
        end

        local name, num = Player.checkItemNumByTable(play, _config.cost[json_data.idx] or {})
        if name then
            Player.sendmsgEx(play, string.format("你的#57|【%s】#249|不足：#57|【%d】#249|", name, num))
            return
        end
        Player.takeItemByTable(play, _config.cost[json_data.idx] or {}, ",做酒水",nil)

        local randomNum = ransjstr(_config.weight[json_data.idx], 1, 3)
        randomNum = tonumber(randomNum)

        -- Player.rwjl(play, _config.details[randomNum].cost, "做酒水")



        local addzuiyi = _config.details[randomNum].num
        setplaydef(play, VarCfg["J_醉意值"], curzuiyi + addzuiyi)
        Player.sendmsgEx(play, string.format("你饮用了|【%s】#249|，醉意值增加了|【%d】#249|，当前醉意值为|【%d】#249", _config.details[randomNum].cost[1][1], addzuiyi, curzuiyi + addzuiyi))
        sendluamsg(play,100,npcid,1,0,tbl2json({num = getplaydef(play, VarCfg["J_醉意值"])}))
        
    elseif ew == 2 then -- 开启吃货币
        if hasbuff(play,20103) then
            delbuff(play,20103)
            Player.sendmsgEx(play, "你关闭了|【醉酒狂魔舞】#249")
        else
            local curzuiyi = getplaydef(play, VarCfg["J_醉意值"])
            if curzuiyi < _config.max_zuiyi then
                Player.sendmsgEx(play, string.format("你的醉意值未达上限#57|【%d】#249|，无法开启醉酒狂魔舞#57", _config.max_zuiyi))
                return
            end

            local name, num = Player.checkItemNumByTable(play, {{"元宝",200}})
            if name then
                Player.sendmsgEx(play, string.format("你的#57|【%s】#249|不足：#57|【%d】#249|", name, num))
                return
            end
            addbuff(play, 20103)
            Player.sendmsgEx(play, "你开启了|【醉酒狂魔舞】#249|，接下来每秒钟将自动消耗|【200元宝】#249")
        end
        
    
    --     if curzuiyi >= _config.max_zuiyi then
    --         Player.sendmsgEx(play, string.format("你的醉意值已达上限|%d#249|，无法继续饮用酒水#57", _config.max_zuiyi))
    --         return
    --     end

    --     local name, num = Player.checkItemNumByTable(play, _config.details[json_data.idx].cost or {})
    --     if name then
    --         Player.sendmsgEx(play, string.format("你的|%s#249|不足|%d#249", name, num))
    --         return
    --     end
    --     Player.takeItemByTable(play, _config.details[json_data.idx].cost or {}, ",饮用酒水",nil)
    --     local addzuiyi = _config.details[json_data.idx].num
    --     setplaydef(play, VarCfg["J_醉意值"], curzuiyi + addzuiyi)
    --     Player.sendmsgEx(play, string.format("你饮用了|%s#249|，醉意值增加了|%d#249|，当前醉意值为|%d#249", _config.details[json_data.idx].name, addzuiyi, curzuiyi + addzuiyi))
    --     sendluamsg(play,100,npcid,1,0,tbl2json({num = getplaydef(play, VarCfg["J_醉意值"])}))
        
    end
end


return npc

