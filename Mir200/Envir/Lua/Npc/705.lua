npc = {}

-- reward_desc: 两种称号：
-- A=以貌取人：LV+1、白天打怪增伤+10%
-- B=迟来的清醒：LV+1、夜晚打怪增伤+10%

local _cfg_key = "npc_705"
local _config = Guard.getConfig(_cfg_key)
local _task_cfg = (_config and _config.task_cfg) or {}

local _choice_key = _cfg_key .. "_b" -- 1=a, 2=b

local function _normalize_choice(raw)
    if raw == nil then
        return nil
    end
    if type(raw) == "string" then
        local s = string.lower(raw)
        if s == "a" then
            return 1
        elseif s == "b" then
            return 2
        end
    end
    local n = tonumber(raw)
    if n == 1 or n == 2 then
        return n
    end
    return nil
end

local function _choice_text(choice)
    if choice == 1 then
        return "A"
    elseif choice == 2 then
        return "B"
    end
    return "?"
end

local function _choice_title(choice)
    local ch = _config and _config.ch
    if type(ch) == "table" then
        return ch[choice]
    end
    if choice == 2 and type(ch) == "string" then
        return ch
    end
    return nil
end

-- 仅发放物品奖励，不额外处理称号（称号按 A/B 单独发）
local function _give_item_reward_only(play)
    local reward = _config.jl or _config.rwjl or _task_cfg.jl or _task_cfg.rwjl or _task_cfg.reward or _task_cfg.rewards
    if type(reward) ~= "table" or #reward == 0 then
        return
    end

    local reason = (_config.name or "剧情任务") .. "奖励"
    if type(reward[1]) == "table" and type(reward[1][1]) == "string" then
        Player.rwjl(play, reward, reason, 1)
        return
    end

    if type(reward[1]) == "table" and type(reward[1][1]) == "table" then
        for _, pack in ipairs(reward) do
            if type(pack) == "table" and #pack > 0 then
                Player.rwjl(play, pack, reason, 1)
            end
        end
    end
end

function npc.main(play,npcid)
    if not _config then
        return
    end
    local data = {}
    data["T_dljq"] = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    data["sg_data"] = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
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
    local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
    local max_num = 1
    local need_kill = tonumber(_task_cfg.kill_count or 1) or 1
    if need_kill < 1 then
        need_kill = 1
    end

    local prog_key = _cfg_key .. "_a"
    local state = tonumber(jq_data[_cfg_key] or 0) or 0
    local cnt = tonumber(jq_data[prog_key] or 0) or 0
    local cur_kill = tonumber(sg_data[_cfg_key] or 0) or 0

    if state >= 2 then
        Player.sendmsgEx(play, "你已经完成#57|【"..(_config.name or "该任务").."】#249|")
        return
    end

    -- 首次领取：按 p3(a/b) 记录分支
    if state < 1 then
        local choice = _normalize_choice(aid)
        if not choice then
            Player.sendmsgEx(play, "请选择分支后再领取（A=1 / B=2）#57")
            return
        end

        jq_data[_cfg_key] = 1
        jq_data[_choice_key] = choice
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)

        shaguai.jia(play, 705)
        Player.sendmsgEx(play, "领取#57|【"..(_config.name or "任务").."】#249|成功，当前分支：#57".._choice_text(choice).."#57")
        sendluamsg(play,101,1005,0,0,"rwjs")
        sendluamsg(play,100,npcid,1,0,"")
        return
    end

    local choice_for_reward = tonumber(jq_data[_choice_key] or 0) or 0
    if choice_for_reward ~= 1 and choice_for_reward ~= 2 then
        local repick = _normalize_choice(aid)
        if repick then
            jq_data[_choice_key] = repick
            choice_for_reward = repick
            Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        else
            Player.sendmsgEx(play, "分支数据缺失，请重新选择（A=1 / B=2）#57")
            return
        end
    end

    local req_map = _task_cfg.map or "罗刹海市"
    if getbaseinfo(play,3) ~= req_map and getbaseinfo(play,3) ~= "xtc" then
        Player.sendmsgEx(play, "请前往#57|【"..req_map.."】#249|完成后再提交#57")
        return
    end

    if cur_kill < need_kill then
        Player.sendmsgEx(play, string.format("击杀不足：#57|【%d/%d】#249|", cur_kill, need_kill))
        return
    end

    if type(_task_cfg.submit) == "table" and #_task_cfg.submit > 0 then
        if not Guard.ensureCost(play, _task_cfg.submit) then
            return
        end
        Guard.consumeCost(play, _task_cfg.submit, ","..(_config.name or "剧情任务"))
    end

    cnt = cnt + 1
    jq_data[prog_key] = cnt
    Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
    Player.sendmsgEx(play, string.format("提交进度：#57|【%d/%d】#249|", cnt, max_num))

    if cnt >= max_num then
        local choice = choice_for_reward

        Guard.clearTaskTemp(jq_data, _cfg_key)
        jq_data[_cfg_key] = 2
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        Player.sendmsgEx(play, "|【"..(_config.name or "任务").."】#249|完成#57")
        sendluamsg(play,101,1005,0,0,"rwwc")

        local title = _choice_title(choice)
        if type(title) == "string" and title ~= "" then
            Player.title_give(play, title)
            Player.sendmsgEx(play, "获得称号：|【"..title.."】#249|")
        end

        _give_item_reward_only(play)
    end

    sendluamsg(play,100,npcid,1,cnt,"")
end

return npc



