npc = {}


--驮我过河

local _config = Guard.getConfig("npc_647")


function npc.main(play,npcid)
    local data = {}
    data["T_dljq"] = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    data["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_灵兽"])
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
        local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
        local key = "npc_647"
        if jq_data[key] and jq_data[key] >= 2 then
            Player.sendmsgEx(play, "你已经完成了该任务#57")
            return
        end

        local T_data = Player.getJsonTableByVar(play, VarCfg["T_灵兽"])
        T_data.ls = T_data.ls or {}
        local lv = T_data.ls["5"] or 0  -- 玄武
        if lv <= 0 then
            Player.sendmsgEx(play, "你未拥有灵兽玄武#57")
            return
        end
        if lv < 3 then
            Player.sendmsgEx(play, "玄武喂养未达到3级#57")
            return
        end

        jq_data[key] = 2
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        Player.sendmsgEx(play, "任务完成")
        sendluamsg(play,101,1005,0,0,"rwwc")
        Player.rwjl(play, _config.rwjl or {{"元宝",1},{"金币",1}}, (_config.name or "剧情任务").."奖励", 1)
        sendluamsg(play,100,npcid,1,2,"")
    end
end

return npc