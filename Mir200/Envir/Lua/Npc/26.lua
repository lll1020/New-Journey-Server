
npc = {}


--占卜

local _config = Guard.getConfig("npc_26")

local function DeleteAllTitle(actor)
    for index, value in ipairs(_config.details) do
        deprivetitle(actor, value)
    end
end

function npc.main(play,npcid)

    local data = {}
    data["U_num"] = getplaydef(play, VarCfg["U_占卜次数"])
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
    local __guardAllowedActions = Guard.newActionSet({1})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end

    if ew == 1 then
        local U_num = getplaydef(play, VarCfg["U_占卜次数"])

        if checktitle(play, _config.details[_config.max_level]) then
            Player.sendmsgEx(play, "你已拥有最高等级#57|【称号】#249|，无法继续占卜#57")
            return
        end

        local weight = ""
        --20次以下不出5
        if U_num < 20 then
            weight = "1#40|2#40|3#25|4#10"
        else
            weight = "1#30|2#30|3#20|4#20|5#5"
        end

        local randomNum = nil
        -- 第一次占卜固定只出第一个档位，避免开局直接跳高档
        if tonumber(U_num or 0) <= 0 then
            randomNum = 1
        else
            randomNum = ransjstr(weight, 1, 3)
        end
        randomNum = tonumber(randomNum)
        if U_num >= 65 then
            randomNum = 5
        end
        local cfg = _config.details[randomNum]
        if not cfg then
            Player.sendmsgEx(play, "参数错误!#57")
            return
        end
        if tonumber(U_num or 0) > 0 then
            local name, num = Player.checkItemNumByTable(play, _config.cost)
            if name then
                Player.sendmsgEx(play, string.format("你的#57|【%s】#249|不足：#57|【%d】#249|", name, num))
                return
            end
            Player.takeItemByTable(play, _config.cost, ",占卜",nil)
        end
        DeleteAllTitle(play)
        local titileName = cfg
        Player.title_give(play, titileName)
        setplaydef(play, VarCfg["U_占卜次数"], U_num + 1)
        -- 二大陆伏妖录：占卜成功后立即尝试自动结算当前任务。
        Player.trySyncSecondContinentXyl(play)
        -- Player.sendmsgEx(play, string.format("你获得了|【%s】#249", titileName))
        sendluamsg(play,100,npcid,1,0,"")
    end
end



return npc
