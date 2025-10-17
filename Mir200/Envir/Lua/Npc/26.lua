
npc = {}



--占卜

local _config = teshudata["npc_26"]

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
    if ew == 1 then
        local U_num = getplaydef(play, VarCfg["U_占卜次数"])

        if checktitle(play, _config.details[_config.max_level]) then
            Player.sendmsgEx(play, "你已经拥有最高等级的称号,无法继续占卜!#249")
            return
        end

        local weight = ""
        --20次以下不出5
        if U_num < 20 then
            weight = "1#30|2#30|3#20|4#15"
        else
            weight = "1#30|2#30|3#20|4#20|5#5"
        end

        local randomNum = ransjstr(weight, 1, 3)
        randomNum = tonumber(randomNum)
        if U_num >= 65 then
            randomNum = 5
        end
        local cfg = _config.details[randomNum]
        if not cfg then
            Player.sendmsgEx(play, "参数错误!#249")
            return
        end
        local name, num = Player.checkItemNumByTable(play, _config.cost)
        if name then
            Player.sendmsgEx(play, string.format("你的|%s#249|不足|%d#249", name, num))
            return
        end
        Player.takeItemByTable(play, _config.cost, ",占卜",nil)
        DeleteAllTitle(play)
        local titileName = cfg
        Player.title_give(play, titileName)
        setplaydef(play, VarCfg["U_占卜次数"], U_num + 1)
        Player.sendmsgEx(play, string.format("你获得了|%s#249", titileName))
        sendluamsg(play,100,npcid,1,0,"")
    end
end



return npc