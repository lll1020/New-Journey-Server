npc = {}

-- reward_desc: 称号BUFF: LV+5 GMD-50-100

local _cfg_key = "npc_690"
local _config = Guard.getConfig(_cfg_key)
local _task_cfg = (_config and _config.task_cfg) or {}

-- 时空守护者前置：必须完成以下六个任务
local _required_tasks = {
    {key = "npc_714", name = "屠龙宝刀"},
    {key = "npc_715", name = "围攻光明顶"},
    {key = "npc_716", name = "孤身战吕布"},
    {key = "npc_717", name = "火烧赤壁"},
    {key = "npc_718", name = "景阳冈打虎"},
    {key = "npc_719", name = "血溅狮子楼"},
}

local function _missing_required_tasks(jq_data)
    local miss = {}
    for _, task in ipairs(_required_tasks) do
        if (tonumber(jq_data[task.key] or 0) or 0) < 2 then
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
    -- 兼容旧配置：红尘大陆在当前服对应生命边界
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
        Player.sendmsgEx(play, "你已经完成#57|【"..(_config.name or "该任务").."】#249|")
        return
    end

    local miss = _missing_required_tasks(jq_data)
    if #miss > 0 then
        Player.sendmsgEx(play, "请先完成：#57|【"..table.concat(miss, "、").."】#249|")
        if npcid then Guard.closeNpcAndAuto(play, npcid) end
        return
    end

    if state < 1 then
        jq_data[_cfg_key] = 1
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
    end

    local ok_map, req_map = _in_submit_map(play)
    if not ok_map then
        Player.sendmsgEx(play, "请前往#57|【"..req_map.."】#249|完成后再提交#57")
        if npcid then Guard.closeNpc(play, npcid) end
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
    Player.sendmsgEx(play, string.format("提交进度：#57|【%d/%d】#249|", cnt, max_num))

    if cnt >= max_num then
        Guard.clearTaskTemp(jq_data, _cfg_key)
        jq_data[_cfg_key] = 2
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        Player.sendmsgEx(play, "|【"..(_config.name or "任务").."】#249|完成#57")
        if npcid then Guard.closeNpc(play, npcid) end
        sendluamsg(play,101,1005,0,0,"rwwc")

        Guard.giveTaskReward(play, _config, (_config.name or "剧情任务").."奖励")
    end

    sendluamsg(play,100,npcid,1,cnt,"")
end

return npc







