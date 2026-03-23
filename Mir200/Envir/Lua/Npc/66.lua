npc = {}


--福娃猜拳

local _config = Guard.getConfig("npc_66")

local function _refresh_fuwa_attr(play, T_data)
    local cut = tonumber(T_data and T_data.cut) or 0
    delattlist(play, "福娃猜拳切割")
    if cut > 0 then
        addattlist(play, "福娃猜拳切割", "=", "3#" .. (_config.cut_attr or 244) .. "#" .. cut, 1)
    end
end

local function _get_fuwa_data(play)
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_福娃猜拳"])
    T_data.count = tonumber(T_data.count) or 0
    T_data.wins = tonumber(T_data.wins) or 0
    T_data.losses = tonumber(T_data.losses) or 0
    T_data.cut = tonumber(T_data.cut) or 0
    T_data.last_cut_gain = tonumber(T_data.last_cut_gain) or 0
    return T_data
end

local function _build_panel_data(play)
    local T_data = _get_fuwa_data(play)
    local data = {}
    data["T_data"] = T_data
    data["cut"] = T_data.cut
    data["last_cut_gain"] = T_data.last_cut_gain
    data["cost"] = _config.cost or {{"金币",1000000}}
    return data, T_data
end

local function _on_fuwa_login(play)
    local _, T_data = _build_panel_data(play)
    _refresh_fuwa_attr(play, T_data)
end

function npc.main(play,npcid)
    local data = _build_panel_data(play)
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

        local T_data = _get_fuwa_data(play)

        -- 每日仅重置当日次数，不清累计奖励数据
        local today = os.date("%Y%m%d")
        if not T_data.date or T_data.date ~= today then
            T_data.date = today
            T_data.count = 0
            T_data.last_result = nil
            T_data.last_cut_gain = 0
        end

        if T_data.count >= 3 then
            Player.sendmsgEx(play, "今日福娃猜拳次数已用完，请明日再来#57")
            return
        end

        if not json_data.choice then
            return
        end

        local player_choice = tonumber(json_data.choice) or 0
        if player_choice < 1 or player_choice > 3 then
            Player.sendmsgEx(play, "请选择有效的出拳选项#57")
            return
        end

        local name, num = Player.checkItemNumByTable(play, _config.cost or {{"金币",1000000}})
        if name then
            Player.sendmsgEx(play, string.format("你的#57|【%s】#249|不足：#57|【%d】#249|", name, num))
            return
        end
        Player.takeItemByTable(play, _config.cost or {{"金币",1000000}}, ",福娃猜拳", nil)

        local choice_name = {
            [1] = "石头",
            [2] = "布",
            [3] = "剪刀",
        }
        local player_choice_name = choice_name[player_choice] or "未知"
        local npc_choice = math.random(1,3)
        local npc_choice_name = choice_name[npc_choice] or "未知"
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
            if player_choice == 1 then
                npc_choice = 3
            elseif player_choice == 2 then
                npc_choice = 1
            else
                npc_choice = 2
            end
            npc_choice_name = choice_name[npc_choice] or "未知"
        end

        local cut_min = tonumber(_config.cut_range and _config.cut_range[1]) or 300
        local cut_max = tonumber(_config.cut_range and _config.cut_range[2]) or 1000
        local cut_gain = math.random(cut_min, cut_max)
        T_data.cut = T_data.cut + cut_gain
        T_data.last_cut_gain = cut_gain
        T_data.last_result = {
            player_choice = player_choice,
            player_choice_name = player_choice_name,
            npc_choice = npc_choice,
            npc_choice_name = npc_choice_name,
            result = result,
        }
        if result == 1 then
            T_data.wins = T_data.wins + 1
            Player.sendmsgEx(play, string.format("恭喜你在本轮福娃猜拳中获胜，你出的是|【%s】#249|，福娃出的是|【%s】#249|，额外获得|【%d】#249|切割", player_choice_name, npc_choice_name, cut_gain))
        elseif result == 2 then
            T_data.losses = T_data.losses + 1
            Player.sendmsgEx(play, string.format("很遗憾你在本轮福娃猜拳中失败了#57，你出的是#57|【%s】#249|，福娃出的是#57|【%s】#249|，额外获得#57|【%d】#249|切割#57", player_choice_name, npc_choice_name, cut_gain))
        else
            Player.sendmsgEx(play, string.format("本轮福娃猜拳平局，你出的是|【%s】#249|，福娃出的是|【%s】#249|，额外获得|【%d】#249|切割", player_choice_name, npc_choice_name, cut_gain))
        end

        -- 记录当日已玩次数
        T_data.count = T_data.count + 1
        Player.setJsonTableByVar(play, VarCfg["T_福娃猜拳"], T_data)
        _refresh_fuwa_attr(play, T_data)
        local data = _build_panel_data(play)
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
        local T_data = _get_fuwa_data(play)
        if T_data.wins < shopItem.win_num then
            Player.sendmsgEx(play, string.format("你的胜利次数不足#57|【%d】#249|，无法兑换该奖励#57", shopItem.win_num))
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
            Player.sendmsgEx(play, string.format("你成功兑换了|【%s】#249|x%d", shopItem.item, (shopItem.give and shopItem.give[1] and shopItem.give[1][2]) or 1))
        elseif shopItem.ch then
            Player.title_give(play, shopItem.ch)
            Player.sendmsgEx(play, string.format("你成功兑换了|【%s】#249|称号", shopItem.ch))
        end
        local data = _build_panel_data(play)
        sendluamsg(play,100,npcid,2,0,tbl2json(data))


    end
end

GameEvent.add(EventCfg.onLogin, _on_fuwa_login, "Login_福娃猜拳")
GameEvent.add(EventCfg.onKFLogin, _on_fuwa_login, "Login_福娃猜拳")

return npc