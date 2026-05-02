npc = {}

local _cfg = Guard.getConfig("anniu_501") or {}

local function _get_welfare_list()
    local details = _cfg.details or {}
    return details.welfare or {}
end

local function _get_data(play)
    local data = Player.getJsonTableByVar(play, VarCfg["T_首冲礼包"]) or {}
    data.main_claimed = tonumber(data.main_claimed or data.other_lb or 0) or 0
    data.welfare_claimed = tonumber(data.welfare_claimed or 0) or 0
    data.welfare_open_time = tonumber(data.welfare_open_time or 0) or 0
    return data
end

local function _set_data(play, data)
    data.other_lb = tonumber(data.main_claimed or 0) or 0
    Player.setJsonVarByTable(play, VarCfg["T_首冲礼包"], data)
end

-- 二大陆异闻录：记录玩家已主动打开过限时福利面板。
local function _mark_xyl_welfare_open(play)
    setplaydef(play, "N$XYL2_WELFARE_OPEN", 1)
    Player.trySyncSecondContinentXyl(play)
end

local function _has_first_charge(data)
    return tonumber(data.ok or 0) == 1 and tonumber(data["首充"] or 0) == 1
end

local function _ensure_stage_time(play, data)
    if (tonumber(data.welfare_open_time or 0) or 0) <= 0 then
        data.welfare_open_time = os.time()
        _set_data(play, data)
    end
end

local function _get_wait_left(data, idx)
    local welfare = _get_welfare_list()
    local cfg = welfare[idx]
    if not cfg then
        return 0
    end
    if _has_first_charge(data) then
        return 0
    end
    local openTs = tonumber(data.welfare_open_time or 0) or 0
    if openTs <= 0 then
        return tonumber(cfg.wait_sec or 0) or 0
    end
    local left = openTs + (tonumber(cfg.wait_sec or 0) or 0) - os.time()
    return left > 0 and left or 0
end

local function _build_payload(play, data)
    return {
        T_data = data,
        server_time = os.time(),
        welfare_count = #_get_welfare_list(),
        welfare_open_time = tonumber(data.welfare_open_time or 0) or 0,
        first_charge_ready = _has_first_charge(data) and 1 or 0,
    }
end

function npc.main(play, npcid)
    local data = _get_data(play)
    _ensure_stage_time(play, data)
    _mark_xyl_welfare_open(play)
    sendluamsg(play, 100, npcid, 0, 0, tbl2json(_build_payload(play, data)))
end

function npc.link(play, npcid, ew, aid)
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local __guardAction = Guard.normalizeAction(play, npcid, ew)
    if __guardAction == nil then
        return
    end
    ew = __guardAction
    local __guardAllowedActions = Guard.newActionSet({1, 2, 3, 4})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end

    local data = _get_data(play)
    _ensure_stage_time(play, data)
    local welfare = _get_welfare_list()
    if ew >= 1 and ew <= 4 then
        local idx = ew
        local expected = (tonumber(data.welfare_claimed or 0) or 0) + 1
        if idx ~= expected or idx < 1 or idx > #welfare then
            Player.sendmsgEx(play, "请按顺序领取限时福利#57")
            sendluamsg(play, 100, npcid, 1, idx, tbl2json(_build_payload(play, data)))
            return
        end

        local left = _get_wait_left(data, idx)
        if left > 0 then
            Player.sendmsgEx(play, "当前计时未完成#57")
            sendluamsg(play, 100, npcid, 1, idx, tbl2json(_build_payload(play, data)))
            return
        end

        local reward = welfare[idx] and welfare[idx].reward or {}
        if type(reward) == "table" and #reward > 0 then
            Player.rwjl(play, reward, "限时福利", 1, 1000)
        end
        data.welfare_claimed = idx
        if not _has_first_charge(data) and idx < #welfare then
            -- 当前档领取后，下一档才重新开始计时。
            data.welfare_open_time = os.time()
        end
        _set_data(play, data)
        sendluamsg(play, 100, npcid, 1, idx, tbl2json(_build_payload(play, data)))
        return
    end
end

return npc
