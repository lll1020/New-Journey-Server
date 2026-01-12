npc = {}


--npc名称：
--npc功能：
local _config = Guard.getConfig("npc_76")

function npc.main(play,npcid)
    local data = {}
    data["T_data"] = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    sendluamsg(play,100,npcid,0,0,tbl2json(data))
end

function npc.link(play, npcid, p2, p3, msgData)

    -- npc_guard: 入参校验
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local __guardAction = Guard.normalizeAction(play, npcid, p2)
    if __guardAction == nil then
        return
    end
    p2 = __guardAction
    -- npc_guard: 操作白名单（优化：限定合法操作编号）
    local __guardAllowedActions = Guard.newActionSet({1, 2})
    if not Guard.ensureActionAllowed(play, npcid, p2, __guardAllowedActions) then
        return
    end
    local json_data = json2tbl(msgData)
    local T_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    T_data["npc_74"] = T_data["npc_74"] or {}
    T_data["npc_76"] = T_data["npc_76"] or {}
    if p2 == 1 then
        if not (T_data["npc_74"][""..json_data.idx] and T_data["npc_74"][""..json_data.idx] == 1) then
            Player.sendmsgEx(play,  "你未完成前置任务#57")
            return
        end
        if T_data["npc_76"][""..json_data.idx] and T_data["npc_76"][""..json_data.idx] == 1 then
            Player.sendmsgEx(play,  "你已经完成了该试炼#57")
            return
        end
        local name, num = Player.checkItemNumByTable(play, _config.details[json_data.idx].cost)
        if name then
            Player.sendmsgEx(play, string.format("你的|%s#249|不足#249", name))
            return
        end
        Player.takeItemByTable(play, _config.details[json_data.idx].cost, ",天命试炼",nil)

        if json_data.idx == 1 then 
            
        elseif json_data.idx == 2 then 
            
        elseif json_data.idx == 3 then 
            
        elseif json_data.idx == 4 then 
        end
        T_data["npc_76"][""..json_data.idx] = 1
    
        Player.setJsonVarByTable(play, VarCfg.T_dljq, T_data)
        Player.sendmsgEx(play,  "你完成了该任务#57")
        Player.rwjl(play, _config.details[json_data.idx].reward, "天命试炼")
        sendluamsg(play,100,npcid,1,0,tbl2json({T_data = T_data}))

    elseif p2 == 2 then
    end
end


return npc

