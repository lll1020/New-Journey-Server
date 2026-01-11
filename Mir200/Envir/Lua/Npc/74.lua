npc = {}


--npc名称：
--npc功能：
local _config = Guard.getConfig("npc_74")

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
    if p2 == 1 then
        if T_data["npc_74"]["all"] and T_data["npc_74"]["all"] >= _config.all then
            Player.sendmsgEx(play,  "你已经完成了该任务#57")
            return
        end
        if T_data["npc_74"][""..json_data.idx] and T_data["npc_74"][""..json_data.idx] == 1 then
            Player.sendmsgEx(play,  "你已经完成了该任务#57")
            return
        end
        if json_data.idx == 1 then 
            
        elseif json_data.idx == 2 then 
            
        elseif json_data.idx == 3 then 
            
        elseif json_data.idx == 4 then 
        end
        T_data["npc_74"][""..json_data.idx] = 1
        local cnt = 0
        for k,v in pairs(T_data["npc_74"]) do
            if v == 1 then
                cnt = cnt + 1
            end
        end
        T_data["npc_74"]["all"] = cnt
        if T_data["npc_74"]["all"] >= _config.all then
            Player.sendmsgEx(play,  "你完成了【天道命盘】全部任务，获得奖励#57")
            -- 发奖励
        end
        Player.setJsonVarByTable(play, VarCfg.T_dljq, T_data)
        Player.updateSomeAddr(play,nil, _config.details[json_data.idx].attr)
        Player.sendmsgEx(play,  "你完成了该任务#57")
        sendluamsg(play,100,npcid,1,0,tbl2json({T_data = T_data}))

    elseif p2 == 2 then
    end
end

function Login_tmlp(play)
    local attrs = {}
    local attrsstr = ""
    local T_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    T_data["npc_74"] = T_data["npc_74"] or {}
    for k, v in pairs(_config.details) do
        if T_data["npc_74"][""..k] and T_data["npc_74"][""..k] == 1 then
            for _, attr in pairs(v.attr or {}) do
                attrs[attr.attrID] = (attrs[attr.attrID] or 0) + attr.value
            end
        end
    end
    attrsstr = Player.getAttrTableToStr(attrs)
    addattlist(play, "天道命盘", "=", attrsstr, 1)
end

GameEvent.add(EventCfg.onLogin, Login_tmlp, "Login_tmlp")


return npc

