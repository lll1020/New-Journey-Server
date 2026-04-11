npc = {}

local _cfg_key = "npc_720"
local _config = Guard.getConfig(_cfg_key)
local _task_cfg = (_config and _config.task_cfg) or {}

local _pre_key = "npc_705"
local _choice_key = "npc_705_choice"

local function _get_choice(play)
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local choice = tonumber(jq_data[_choice_key] or 0) or 0
    if choice == 1 or choice == 2 then
        return choice
    end
    return 0
end

function npc.main(play,npcid)
    if not _config then
        return
    end
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local pre_state = tonumber(jq_data[_pre_key] or 0) or 0
    if pre_state < 2 then
        Player.sendmsgEx(play, "请先完成#57|【是非难辨】#249|再来#57")
        return
    end
    local data = {}
    data["T_dljq"] = jq_data
    sendluamsg(play,100,npcid,0,0,tbl2json(data))
end

function npc.link(play,npcid,ew,aid)
    if not _config then
        return
    end
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local __guardAction = Guard.normalizeAction(play, npcid, ew)
    if __guardAction == nil then
        return
    end
    ew = __guardAction
    local __guardAllowedActions = Guard.newActionSet({1})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end
    if ew ~= 1 then
        return
    end

    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local pre_state = tonumber(jq_data[_pre_key] or 0) or 0
    if pre_state < 2 then
        Player.sendmsgEx(play, "请先完成#57|【是非难辨】#249|再来#57")
        return
    end

    local state = tonumber(jq_data[_cfg_key] or 0) or 0
    if state >= 2 then
        Player.sendmsgEx(play, "你已经完成#57|【"..(_config.name or "该任务").."】#249|")
        return
    end

    local choice = _get_choice(play)
    if choice ~= 1 and choice ~= 2 then
        Player.sendmsgEx(play, "提交分支数据缺失，请返回#57|【是非难辨】#249|确认#57")
        return
    end

    if choice == 1 then
        local cost = _task_cfg.cost_a
        if type(cost) == "table" and #cost > 0 then
            if not Guard.ensureCost(play, cost) then
                return
            end
            Guard.consumeCost(play, cost, ","..(_config.name or "剧情任务"))
        end
    end

    jq_data[_cfg_key] = 2
    Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
    Player.sendmsgEx(play, "|【"..(_config.name or "任务").."】#249|完成#57")
    sendluamsg(play,101,1005,0,0,"rwwc")
    sendluamsg(play,100,npcid,1,0,"")
end

return npc