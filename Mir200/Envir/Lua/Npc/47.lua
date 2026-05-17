npc = {}


--

local _config = Guard.getConfig("npc_47")
local FairyFate = include("lua/LuaLib/fairy_fate.lua")

function npc.main(play,npcid)
    if not Player.ensureThirdContinentPass(play, '请先完成#57|【灾厄入侵】#218|后再使用该功能#57') then
        return
    end
    local data = {}
    data["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_藏宝图"])
    data["J_cs"] = getplaydef(play, VarCfg["J_今日藏宝图次数"])
    sendluamsg(play,100,npcid,0,0,tbl2json(data))
end

function npc.link(play,npcid,ew,aid,data)
    if not Player.ensureThirdContinentPass(play, '请先完成#57|【灾厄入侵】#218|后再使用该功能#57') then
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
        local T_data = Player.getJsonTableByVar(play, VarCfg["T_藏宝图"])
        local J_cs = getplaydef(play, VarCfg["J_今日藏宝图次数"])
        if J_cs >= _config.max then
            Player.sendmsgEx(play, "今日藏宝图次数已达上限#57")
            return 
        end

        local name, num = Player.checkItemNumByTable(play, _config.cost)
        if name then
            Player.sendmsgEx(play, string.format("你的#57|【%s】#218|不足：#57|【%d】#218|", name, num))
            return
        end
        Player.takeItemByTable(play, _config.cost, ",藏宝图",nil)

        local level = ransjstr(_config.weight, 1, 3)
        level = tonumber(level)
        J_cs = J_cs + 1
        
        -- T_data["map_"..J_cs] = _config.details[level].map[math.random(1,#_config.details)]
        -- T_data["level_"..J_cs] = level
        local detail = _config.details[level]
        if not detail or not detail.map or #detail.map == 0 then
            Player.sendmsgEx(play, "配置异常，请联系管理员#57")
            return
        end
        local map = detail.map[math.random(1, #detail.map)]
        -- release_print("藏宝图详情:", tbl2json(detail))
        -- release_print("藏宝图生成:", tbl2json(map))
        -- local name, num = Player.checkItemNumByTable(play, {{"铲子",1}})
        -- if name then
        --     giveitem(play,"铲子",1,850)
        -- end


        local itemobj = giveitem(play,detail.item,1)
        changeitemname(play,-2,detail.item.."["..map.map_name..","..map.map_x..","..map.map_y.."]",itemobj)

        Player.setJsonVarByTable(play, VarCfg["T_藏宝图"], T_data)
        setplaydef(play, VarCfg["J_今日藏宝图次数"], J_cs)
        local times = (getplaydef(play, VarCfg["U_藏宝图次数"]) or 0) + 1
        setplaydef(play, VarCfg["U_藏宝图次数"], times)

        if FairyFate and FairyFate.touch then FairyFate.touch(play, "treasure", 1) end
        npc.main(play,npcid)
        
    end
end


return npc
