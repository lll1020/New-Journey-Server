npc = {}


--

local _config = Guard.getConfig("npc_46")

function npc.main(play,npcid)
    local data = {}
    data["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_dljq"])
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
    local __guardAllowedActions = Guard.newActionSet({1})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end

    if ew == 1 then --
        local T_data = Player.getJsonTableByVar(play, VarCfg["T_dljq"])
        T_data["npc_46"] = T_data["npc_46"] or {}
        if not Guard.ensureCost(play, _config.cost) then
            return
        end
        Guard.consumeCost(play, _config.cost, ","..(_config.name or "剧情任务"))

        -- for i = 1, 4 do
        --     if not (T_data["npc_46"][""..i] and T_data["npc_46"][""..i] == 2) then
        --         Player.sendmsgEx(play, "你还有未完成的试炼任务，无法领取奖励#57")
        --         return
        --     end
        -- end
        T_data["npc_46"]["wc"] = 1
        Player.setJsonVarByTable(play, VarCfg["T_dljq"], T_data)
        Player.title_give(play, _config.ch)
        Player.sendmsgEx(play,  "恭喜你，获得称号：|【".._config.ch.."】#249|")
        sendluamsg(play,100,npcid,1,0,"")
    
        
    end
end


return npc