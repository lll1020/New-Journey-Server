npc = {}

-- 任务：是非难辨
-- 阶段1：击杀小怪+BOSS
-- 阶段2：提交两种材料二选一（记录选择）

local _cfg_key = "npc_705"
local _config = Guard.getConfig(_cfg_key)
local _task_cfg = (_config and _config.task_cfg) or {}

local _choice_key = _cfg_key .. "_choice" -- 1=赤血花，2=紫梦花
local _step_key = _cfg_key .. "_step" -- 1=击杀阶段提交完成

local function _normalize_choice(raw)
    if raw == nil then
        return nil
    end
    local n = tonumber(raw)
    if n == 1 or n == 2 then
        return n
    end
    if type(raw) == "string" then
        local s = string.lower(raw)
        if s == "a" then
            return 1
        elseif s == "b" then
            return 2
        end
    end
    return nil
end

local function _choice_text(choice)
    if choice == 1 then
        return "赤血花"
    elseif choice == 2 then
        return "紫梦花"
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

-- 仅发放物品奖励，不额外处理称号（称号按提交分支发）
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

local function _get_progress(play)
    local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
    local key_small = _cfg_key .. "_small"
    local key_boss = _cfg_key .. "_boss"
    local cur_small = tonumber(sg_data[key_small] or 0) or 0
    local cur_boss = tonumber(sg_data[key_boss] or 0) or 0
    return sg_data, key_small, key_boss, cur_small, cur_boss
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
    local state = tonumber(jq_data[_cfg_key] or 0) or 0

    if state >= 2 then
        Player.sendmsgEx(play, "你已经完成#57|【"..(_config.name or "该任务").."】#218|")
        return
    end

    -- 首次领取任务
    if state < 1 then
        jq_data[_cfg_key] = 1
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        shaguai.jia(play, 705)
        Player.sendmsgEx(play, "领取#57|【"..(_config.name or "任务").."】#218|成功")
        sendluamsg(play,101,1005,0,0,"rwjs")
        sendluamsg(play,100,npcid,1,0,"")
        return
    end

    local req_map = _task_cfg.map or "罗刹海市"
    if req_map ~= "" and getbaseinfo(play,3) ~= req_map and getbaseinfo(play,3) ~= "xtc" then
        Player.sendmsgEx(play, "请前往#57|【"..req_map.."】#218|完成后再提交#57")
        if npcid then Guard.closeNpc(play, npcid) end
        return
    end

    -- 阶段1：击杀进度检查
    local need_small = tonumber(_task_cfg.kill_small or 0) or 0
    local need_boss = tonumber(_task_cfg.kill_boss or 0) or 0
    local sg_data, key_small, key_boss, cur_small, cur_boss = _get_progress(play)
    local small_done = (need_small <= 0) or (cur_small >= need_small)
    local boss_done = (need_boss <= 0) or (cur_boss >= need_boss)

    if not (small_done and boss_done) then
        local msg = string.format("击杀进度：小怪#57|【%d/%d】#218|，BOSS#57|【%d/%d】#218|", cur_small, need_small, cur_boss, need_boss)
        Player.sendmsgEx(play, msg)
        return
    end

    local step = tonumber(jq_data[_step_key] or 0) or 0
    if step < 1 then
        jq_data[_step_key] = 1
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        Player.sendmsgEx(play, "委托已提交，继续完成下一步#57")
        sendluamsg(play,100,npcid,1,0,"")
        return
    end

    -- 阶段2：提交二选一
    local choice = tonumber(jq_data[_choice_key] or 0) or 0
    local pick = _normalize_choice(aid)
    if choice ~= 1 and choice ~= 2 then
        if not pick then
            Player.sendmsgEx(play, "请选择提交分支：1=赤血花 / 2=紫梦花#57")
            return
        end
        choice = pick
        jq_data[_choice_key] = choice
    elseif pick and pick ~= choice then
        Player.sendmsgEx(play, "已选择提交#57|".._choice_text(choice).."#218|，不可更改#57")
        return
    end

    local submit = nil
    if choice == 1 then
        submit = _task_cfg.submit_a
    elseif choice == 2 then
        submit = _task_cfg.submit_b
    end
    if type(submit) == "table" and #submit > 0 then
        if not Guard.ensureCost(play, submit) then
            return
        end
        Guard.consumeCost(play, submit, ","..(_config.name or "剧情任务"))
    end

    -- 完成 705（奖励仍在此发放）
    jq_data[_cfg_key] = 2
    jq_data[_step_key] = nil
    Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)

    -- 清理击杀进度
    sg_data[key_small] = nil
    sg_data[key_boss] = nil
    Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)

    Player.sendmsgEx(play, "|【"..(_config.name or "任务").."】#218|完成#57")
    if npcid then Guard.closeNpc(play, npcid) end
    sendluamsg(play,101,1005,0,0,"rwwc")

    local title = _choice_title(choice)
    if type(title) == "string" and title ~= "" then
        Player.title_give(play, title)
        Player.sendmsgEx(play, "获得称号：|【"..title.."】#218|")
    end

    _give_item_reward_only(play)
    sendluamsg(play,100,npcid,1,0,"")
end

return npc