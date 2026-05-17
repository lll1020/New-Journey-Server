npc = {}

-- drop_hint: 冰火龙鳞：1/1000

local _cfg_key = "npc_714"
local _config = Guard.getConfig(_cfg_key)
local _task_cfg = (_config and _config.task_cfg) or {}
local _shaguai_id = tonumber(_config and (_config.shaguai_id or string.match(_cfg_key, "%d+")) or 0) or 0

local function _req_map()
    return _task_cfg.map or "冰火岛"
end

local function _need_kill()
    local n = tonumber(_task_cfg.kill_count or 10) or 10
    if n < 1 then
        n = 1
    end
    return n
end

local function _artifact_item()
    return _task_cfg.artifact_item or "屠龙刀"
end

local function _artifact_upgrade_item()
    return _task_cfg.artifact_upgrade_item or "真·屠龙刀(BBSQ)"
end

-- 额外功能：屠龙刀升级（不影响任务完成）
local function _try_upgrade_artifact(play)
    local src_item = _artifact_item()
    local dst_item = _artifact_upgrade_item()
    local costs = _task_cfg.upgrade_submit or {{"冰火龙鳞",100},{"元宝",1000000}}

    -- 保证升级阶段仍可继续刷冰火龙鳞
    if _shaguai_id > 0 then
        shaguai.jia(play, _shaguai_id)
    end

    if getbagitemcount(play, dst_item) >= 1 then
        Player.sendmsgEx(play, "你已拥有#57|【"..dst_item.."】#218|，无需重复升级#57")
        return
    end

    if getbagitemcount(play, src_item) < 1 then
        Player.sendmsgEx(play, "缺少背包神器：#57|【"..src_item.."】#218|")
        return
    end

    if not Guard.ensureCost(play, costs) then
        return
    end

    takeitem(play, src_item, 1)
    Guard.consumeCost(play, costs, ","..(_config.name or "剧情任务").."升级")
    giveitem(play, dst_item, 1)

    Player.sendmsgEx(play, "升级成功：|【"..src_item.."】#218| -> |【"..dst_item.."】#218|")
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
    local __guardAllowedActions = Guard.newActionSet({1,2})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end

    -- ew=2：屠龙刀升级（额外功能）
    if ew == 2 then
        _try_upgrade_artifact(play)
        return
    end

    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])

    local max_num = 1
    local prog_key = _cfg_key .. "_a"
    local state = tonumber(jq_data[_cfg_key] or 0) or 0
    local cnt = tonumber(jq_data[prog_key] or 0) or 0

    if state >= 2 then
        -- 完成后保留杀怪监听，支持继续刷冰火龙鳞做升级
        if _shaguai_id > 0 then
            shaguai.jia(play, _shaguai_id)
        end
        Player.sendmsgEx(play, "你已经完成#57|【"..(_config.name or "该任务").."】#218|")
        return
    end

    if state < 1 then
        jq_data[_cfg_key] = 1
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        Player.sendmsgEx(play, "领取|【"..(_config.name or "任务").."】#218|")
        if npcid then Guard.closeNpcAndAuto(play, npcid) end
        if _shaguai_id > 0 then
            shaguai.jia(play, _shaguai_id)
        end
        sendluamsg(play,101,1005,0,0,"rwjs")
        sendluamsg(play,100,npcid,1,cnt,"")
        return
    end

    local req_map = _req_map()
    if getbaseinfo(play,3) ~= req_map and getbaseinfo(play,3) ~= "xtc" then
        Player.sendmsgEx(play, "请前往#57|【"..req_map.."】#218|完成后再提交#57")
        if npcid then Guard.closeNpc(play, npcid) end
        return
    end

    local need = _need_kill()
    local kill_cur = tonumber(sg_data[_cfg_key] or 0) or 0
    if kill_cur < need then
        Player.sendmsgEx(play, string.format("击杀不足：#57|【%d/%d】#218|", kill_cur, need))
        return
    end

    cnt = cnt + 1
    jq_data[prog_key] = cnt
    Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
    Player.sendmsgEx(play, string.format("提交进度：#57|【%d/%d】#218|", cnt, max_num))

    if cnt >= max_num then
        Guard.clearTaskTemp(jq_data, _cfg_key)
        jq_data[_cfg_key] = 2
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        Player.sendmsgEx(play, "|【"..(_config.name or "任务").."】#218|完成#57")
        if npcid then Guard.closeNpc(play, npcid) end
        sendluamsg(play,101,1005,0,0,"rwwc")

        -- 任务完成固定发放背包神器：屠龙刀
        giveitem(play, _artifact_item(), 1)
        Player.sendmsgEx(play, "获得背包神器：|【".._artifact_item().."】#218|")

        Guard.giveTaskReward(play, _config, (_config.name or "剧情任务").."奖励")
    end

    sendluamsg(play,100,npcid,1,cnt,"")
end

return npc



