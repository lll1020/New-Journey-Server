npc = {}

-- reward_desc: 称号BUFF: LV+5 GMD-50-100

local _cfg_key = "npc_692"
local _config = Guard.getConfig(_cfg_key)
local _task_cfg = (_config and _config.task_cfg) or {}

-- 生命边界之谜前置：必须完成以下六个任务
local _required_tasks = {
    {key = "npc_696", name = "神庙逃亡"},
    {key = "npc_697", name = "神庙秘宝"},
    {key = "npc_698", name = "祭祀河神"},
    {key = "npc_699", name = "墨河秘宝"},
    {key = "npc_700", name = "赤焰试炼"},
    {key = "npc_701", name = "葬天试炼"},
}

local function _missing_required_tasks(jq_data)
    local miss = {}
    for _, task in ipairs(_required_tasks) do
        local wrap = teshudata and teshudata[task.key] or nil
        local task_cfg = wrap and wrap.task_cfg or nil
        local is_preview_board = type(task_cfg) == "table" and task_cfg.task_type == "preview_board"
        if not is_preview_board and (tonumber(jq_data[task.key] or 0) or 0) < 2 then
            table.insert(miss, task.name)
        end
    end
    return miss
end

local function _in_submit_map(play)
    local req_map = _task_cfg.map or "红尘大陆"
    local cur_map = getbaseinfo(play,3)
    if cur_map == "xtc" then
        return true, req_map
    end
    if cur_map == req_map then
        return true, req_map
    end
    if req_map == "红尘大陆" and cur_map == "生命边界" then
        return true, req_map
    end
    return false, req_map
end

function npc.main(play,npcid)
    if not _config then
        return
    end
    local data = {}
    data["T_dljq"] = Player.getJsonTableByVar(play, VarCfg.T_dljq)
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
    local max_num = 1
    local prog_key = _cfg_key .. "_a"
    local state = tonumber(jq_data[_cfg_key] or 0) or 0
    local cnt = tonumber(jq_data[prog_key] or 0) or 0
    if state >= 2 then
        Player.sendmsgEx(play, "你已经完成【"..(_config.name or "该任务").."】#57")
        return
    end

    local miss = _missing_required_tasks(jq_data)
    if #miss > 0 then
        Player.sendmsgEx(play, "请先完成："..table.concat(miss, "、").."#57")
        return
    end

    if state < 1 then
        jq_data[_cfg_key] = 1
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
    end

    local ok_map, req_map = _in_submit_map(play)
    if not ok_map then
        Player.sendmsgEx(play, "请前往【"..req_map.."】完成后再提交#57")
        return
    end
    local costs = _task_cfg.submit or _config.cost
    if type(costs) == "table" and #costs > 0 then
        if not Guard.ensureCost(play, costs) then
            return
        end
        Guard.consumeCost(play, costs, ","..(_config.name or "剧情任务"))
    end

    cnt = cnt + 1
    jq_data[prog_key] = cnt
    Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
    Player.sendmsgEx(play, string.format("提交进度：%d/%d#57", cnt, max_num))

    if cnt >= max_num then
        Guard.clearTaskTemp(jq_data, _cfg_key)
        jq_data[_cfg_key] = 2
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        Player.sendmsgEx(play, "【"..(_config.name or "任务").."】完成#57")
        sendluamsg(play,101,1005,0,0,"rwwc")

        Guard.giveTaskReward(play, _config, (_config.name or "剧情任务").."奖励")
    end

    sendluamsg(play,100,npcid,1,cnt,"")
end

return npc








