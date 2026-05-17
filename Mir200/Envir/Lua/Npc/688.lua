npc = {}

-- 时空之门：提交随机解锁三张地图，解锁后可直接传送
local _cfg_key = "npc_688"
local _config = Guard.getConfig(_cfg_key)
local _task_cfg = (_config and _config.task_cfg) or {}

local function _unlock_list()
    local list = _task_cfg.unlock_maps
    if type(list) == "table" and #list > 0 then
        return list
    end
    return {
        {name = "倚天江湖", key = "a", tp = {"倚天江湖",21,105}},
        {name = "三国乱世", key = "b", tp = {"三国乱世",156,86}},
        {name = "水浒再临", key = "c", tp = {"水浒再临",43,96}},
    }
end

local function _flag_key(suffix)
    return _cfg_key .. "_" .. tostring(suffix)
end

local function _is_unlocked(jq_data, suffix)
    return tonumber(jq_data[_flag_key(suffix)] or 0) == 1
end

local function _try_tp(play, jq_data, idx)
    local list = _unlock_list()
    local node = list[idx]
    if not node then
        Player.sendmsgEx(play, "传送目标不存在#57")
        return false
    end

    local state = tonumber(jq_data[_cfg_key] or 0) or 0
    local unlocked = state >= 2 or _is_unlocked(jq_data, node.key)
    if not unlocked then
        Player.sendmsgEx(play, "该地图未解锁#57")
        return false
    end

    local tp = node.tp
    if not (type(tp) == "table" and tp[1] and tp[2] and tp[3]) then
        Player.sendmsgEx(play, "传送配置缺失#57")
        if npcid then Guard.closeNpcAndAuto(play, npcid) end
        return false
    end

    mapmove(play, tp[1], tp[2], tp[3], 5)
    return true
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
    local __guardAllowedActions = Guard.newActionSet({1,2,3,4})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end

    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])

    -- ew=2/3/4：三张目标图传送（已解锁或任务已完成可进入）
    if ew >= 2 and ew <= 4 then
        _try_tp(play, jq_data, ew - 1)
        return
    end

    -- ew=1：提交并随机解锁一张图
    local state = tonumber(jq_data[_cfg_key] or 0) or 0
    if state < 1 then
        jq_data[_cfg_key] = 1
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        shaguai.jia(play, 688)
        Player.sendmsgEx(play, "领取|【"..(_config.name or "任务").."】#218|")
        if npcid then Guard.closeNpcAndAuto(play, npcid) end
        sendluamsg(play,101,1005,0,0,"rwjs")
        sendluamsg(play,100,npcid,1,0,"")
        return
    end

    if state >= 2 then
        Player.sendmsgEx(play, "|【"..(_config.name or "任务").."】#218|已完成，可直接传送#57")
        sendluamsg(play,100,npcid,1,3,"")
        return
    end

    local req_map = _task_cfg.map or "时空裂隙"
    if getbaseinfo(play,3) ~= req_map and getbaseinfo(play,3) ~= "xtc" then
        Player.sendmsgEx(play, "请前往#57|【"..req_map.."】#218|完成后再提交#57")
        if npcid then Guard.closeNpc(play, npcid) end
        return
    end

    local list = _unlock_list()
    local pending = {}
    local unlocked_count = 0
    for i, node in ipairs(list) do
        if _is_unlocked(jq_data, node.key) then
            unlocked_count = unlocked_count + 1
        else
            table.insert(pending, i)
        end
    end

    if #pending <= 0 then
        Guard.clearTaskTemp(jq_data, _cfg_key)
        jq_data[_cfg_key] = 2
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        shaguai.jian(play, 688)
        Player.sendmsgEx(play, "|【"..(_config.name or "任务").."】#218|完成#57")
        if npcid then Guard.closeNpc(play, npcid) end
        sendluamsg(play,101,1005,0,0,"rwwc")
        sendluamsg(play,100,npcid,1,#list,"")
        return
    end

    -- 击杀改为累计阈值：解锁第N张时要求累计击杀达到 N*kill_count
    local need_kill = tonumber(_task_cfg.kill_count or 0) or 0
    local kill_cur = tonumber(sg_data[_cfg_key] or 0) or 0
    local need_total = need_kill * (unlocked_count + 1)
    if need_total > 0 and kill_cur < need_total then
        Player.sendmsgEx(play, string.format("击杀不足：#57|【%d/%d】#218|（累计）#57", kill_cur, need_total))
        return
    end

    local costs = _task_cfg.submit or {}
    if not Guard.ensureCost(play, costs) then
        return
    end

    Guard.consumeCost(play, costs, ","..(_config.name or "剧情任务"))
    local pick = pending[math.random(1, #pending)]
    local node = list[pick]
    jq_data[_flag_key(node.key)] = 1

    local new_unlocked_count = unlocked_count + 1
    if new_unlocked_count >= #list then
        Guard.clearTaskTemp(jq_data, _cfg_key)
        jq_data[_cfg_key] = 2
        shaguai.jian(play, 688)
        Player.sendmsgEx(play, "随机解锁#57|【"..node.name.."】#218|成功，三图已全部解锁#57")
        Player.sendmsgEx(play, "|【"..(_config.name or "任务").."】#218|完成#57")
        if npcid then Guard.closeNpc(play, npcid) end
        sendluamsg(play,101,1005,0,0,"rwwc")
    else
        Player.sendmsgEx(play, "随机解锁#57|【"..node.name.."】#218|成功（#57"..new_unlocked_count.."/"..#list.."）#57")
    end

    Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
    sendluamsg(play,100,npcid,1,new_unlocked_count,"")
end

return npc