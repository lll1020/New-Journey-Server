npc = {}

-- 进图传送NPC：前置完成灵兽奥秘且需召唤正确灵兽
local _cfg_key = "npc_684"
local _config = Guard.getConfig(_cfg_key)

-- 读取当前任务配置，统一走 teshudata 单源
local function _task_cfg()
    return (_config and _config.task_cfg) or {}
end

-- 按灵兽编号解析灵兽名称（优先读取 npc_64 配置）
local function _lingshou_name(idx)
    local ls_cfg = Guard.getConfig("npc_64")
    local ls_list = ls_cfg and ls_cfg.config and ls_cfg.config.ls
    if ls_list and ls_list[idx] and ls_list[idx].name then
        return ls_list[idx].name
    end
    return tostring(idx or 0)
end

function npc.main(play,npcid)
    if not _config then
        return
    end
    local data = {}
    data["T_dljq"] = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    data["T_灵兽"] = Player.getJsonTableByVar(play, VarCfg["T_灵兽"])
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

    local cfg = _task_cfg()
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local need_task = cfg.need_task or "npc_682"
    if (tonumber(jq_data[need_task] or 0) or 0) < 2 then
        Player.sendmsgEx(play, "请先完成#57|【灵兽奥秘】#249|后再进入#57")
        if npcid then Guard.closeNpcAndAuto(play, npcid) end
        return
    end

    local need_ls = tonumber(cfg.need_lingshou or 0) or 0
    if need_ls > 0 then
        local ls_data = Player.getJsonTableByVar(play, VarCfg["T_灵兽"])
        local cur_ls = tonumber(ls_data and ls_data.dqzh or 0) or 0
        if cur_ls ~= need_ls then
            local need_name = cfg.need_lingshou_name or _lingshou_name(need_ls)
            Player.sendmsgEx(play, "请先召唤#57|【"..need_name.."】#249|后再进入#57")
            if npcid then Guard.closeNpcAndAuto(play, npcid) end
            return
        end
    end

    local tp = cfg.tp_map or _config.tp_map
    if not (type(tp) == "table" and tp[1] and tp[2] and tp[3]) then
        Player.sendmsgEx(play, "传送配置缺失#57")
        if npcid then Guard.closeNpcAndAuto(play, npcid) end
        return
    end

    mapmove(play, tp[1], tp[2], tp[3], 5)
end

return npc