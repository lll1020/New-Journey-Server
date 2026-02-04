npc = {}


--福娃猜拳

local _config = Guard.getConfig("npc_66")

function npc.main(play,npcid)
    local data = {}
    data["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_福娃猜拳"])
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
    

    if ew == 1 then -- 福娃猜拳
        
        local T_data = Player.getJsonTableByVar(play, VarCfg["T_福娃猜拳"])

        -- 每日重置数据，并校验当日剩余次数
        local today = os.date("%Y%m%d")
        if not T_data.date or T_data.date ~= today then
            T_data = {date = today, count = 0}
        end
        T_data.count = T_data.count or 0
        T_data.wins = T_data.wins or 0
        T_data.losses = T_data.losses or 0

        if T_data.count >= 3 then
            Player.sendmsgEx(play, "今日福娃猜拳次数已用完，请明日再来#57")
            return
        end

        if not json_data.choice then
            return
        end

        local player_choice = json_data.choice or 0
        if player_choice < 1 or player_choice > 3 then
            Player.sendmsgEx(play, "请选择有效的出拳选项#57")
            return
        end

        local npc_choice = math.random(1,3)
        local result = 0 -- 0平局 1玩家胜利 2NPC胜利
        if player_choice == npc_choice then
            result = 0
        elseif (player_choice == 1 and npc_choice == 3) or (player_choice == 2 and npc_choice == 1) or (player_choice == 3 and npc_choice == 2) then
            result = 1
        else
            result = 2
        end

        -- 保证每日三局内至少胜利一次：到第三局仍未胜利则强制为胜
        if result ~= 1 and T_data.wins == 0 and T_data.count == 2 then
            result = 1
        end

        if result == 1 then
            T_data.wins = T_data.wins + 1
            Player.sendmsgEx(play, "恭喜你在本轮福娃猜拳中获胜")
        elseif result == 2 then
            T_data.losses = T_data.losses + 1
            Player.sendmsgEx(play, "很遗憾你在本轮福娃猜拳中失败了#57")
        else
            Player.sendmsgEx(play, "本轮福娃猜拳平局")
        end

        -- 记录当日已玩次数
        T_data.count = T_data.count + 1
        Player.setJsonTableByVar(play, VarCfg["T_福娃猜拳"], T_data)
        local data = {}
        data["T_data"] = T_data
        sendluamsg(play,100,npcid,1,0,tbl2json(data))
    elseif ew == 2 then -- 兑换奖励

        _config.shop = _config.shop or {}
        local idx = tonumber(json_data.idx)
        if not idx or idx < 1 or idx > #_config.shop then
            Player.sendmsgEx(play, "参数错误#57")
            return
        end
        json_data.idx = idx
        local shopItem = _config.shop[idx]
        local T_data = Player.getJsonTableByVar(play, VarCfg["T_福娃猜拳"])
        T_data.wins = T_data.wins or 0
        if T_data.wins < shopItem.win_num then
            Player.sendmsgEx(play, string.format("你的胜利次数不足|%d#249|，无法兑换该奖励#57", shopItem.win_num))
            return
        end
        T_data["dh"] = T_data["dh"] or {}
        if T_data["dh"][""..json_data.idx] then
            Player.sendmsgEx(play, "你已兑换过该奖励，无法重复兑换#57")
            return
        end
        T_data["dh"][""..json_data.idx] = 1

        Player.setJsonTableByVar(play, VarCfg["T_福娃猜拳"], T_data)
        if shopItem.give then
            Player.rwjl(play, shopItem.give, "福娃猜拳兑换奖励", 1)
            Player.sendmsgEx(play, string.format("你成功兑换了|%s#249|x%d", shopItem.item, (shopItem.give and shopItem.give[1] and shopItem.give[1][2]) or 1))
        elseif shopItem.ch then
            Player.title_give(play, shopItem.ch)
            Player.sendmsgEx(play, string.format("你成功兑换了|%s#249|称号", shopItem.ch))
        end
        local data = {}
        data["T_data"] = T_data
        sendluamsg(play,100,npcid,2,0,tbl2json(data))


    end
end


return npc
