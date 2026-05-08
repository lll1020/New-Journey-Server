npc = {}
local _npcid = 107
local _config = Guard.getConfig("npc_107") or teshudata["npc_107"] or {}

local function _bwcz_cfg()
    return BwczApi and BwczApi.get_cfg and BwczApi.get_cfg() or nil
end

local function _player_data(play)
    if BwczApi and BwczApi.get_player_data then
        return BwczApi.get_player_data(play)
    end
    return {merit = 0, total_merit = 0, title_idx = 0, title = "", kills = 0}
end

local function _title_cfg_by_idx(cfg, idx)
    return BwczApi and BwczApi.get_title_cfg_by_idx and BwczApi.get_title_cfg_by_idx(cfg, idx) or nil
end

local function _next_title_cfg(cfg, idx)
    return BwczApi and BwczApi.get_next_title_cfg and BwczApi.get_next_title_cfg(cfg, idx) or nil
end

local function _refresh_title(play, cfg, data)
    if BwczApi and BwczApi.refresh_title then
        BwczApi.refresh_title(play, cfg, data)
    end
end

local function _build_rank_payload(cfg)
    if BwczApi and BwczApi.build_rank_data then
        return BwczApi.build_rank_data(cfg)
    end
    local scoreVar = tostring((cfg and cfg.score_var) or "保卫村庄")
    local raw = sorthumvar(scoreVar, 1, 1, 10)
    local result = {}
    for i = 1, #raw, 2 do
        local name = raw[i]
        local score = tonumber(raw[i + 1]) or 0
        if name and score > 0 then
            result[#result + 1] = {name = name, score = score}
        end
    end
    return result
end

local function _build_panel_data(play)
    local cfg = _bwcz_cfg() or {}
    local data = _player_data(play)
    local curCfg = _title_cfg_by_idx(cfg, data.title_idx)
    local nextCfg = _next_title_cfg(cfg, data.title_idx)
    local totalMerit = tonumber(data.total_merit or 0) or 0
    local myScore = tonumber(getplayvar(play, "HUMAN", tostring(cfg.score_var or "保卫村庄")) or 0) or 0
    return {
        title = tostring((_config and _config.title) or "功勋称号"),
        desc = tostring((_config and _config.desc) or "参加保卫村庄活动，杀怪赢功勋，晋升称号！"),
        top_notice = tostring((_config and _config.top_notice) or "前三名达到镇境武侯的玩家！每人奖励50元真实充值！"),
        current = {
            idx = tonumber(data.title_idx) or 0,
            name = tostring((curCfg and curCfg.name) or "暂无称号"),
            need = tonumber((curCfg and curCfg.need) or 0) or 0,
            tip = tostring((curCfg and curCfg.tip) or "尚未获得功勋称号"),
        },
        next = {
            idx = tonumber((nextCfg and nextCfg.idx) or 0) or 0,
            name = tostring((nextCfg and nextCfg.name) or "已满级"),
            need = tonumber((nextCfg and nextCfg.need) or 0) or 0,
            tip = tostring((nextCfg and nextCfg.tip) or "当前已达到最高称号"),
        },
        merit = totalMerit,
        total_merit = totalMerit,
        kills = tonumber(data.kills) or 0,
        rank_score = myScore,
        rank_data = _build_rank_payload(cfg),
        can_upgrade = nextCfg and (totalMerit >= (tonumber(nextCfg.need) or 0)) and 1 or 0,
    }
end

local function _refresh_panel(play, ew, aid)
    sendluamsg(play, 100, _npcid, ew or 0, aid or 0, tbl2json(_build_panel_data(play)))
end

function npc.main(play, npcid)
    _refresh_panel(play, 0, 0)
    openhyperlink(play, 1, 2)
end

function npc.link(play, npcid, ew, aid, data)
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local action = Guard.normalizeAction(play, npcid, ew)
    if action == nil then
        return
    end
    ew = action
    if not Guard.ensureActionAllowed(play, npcid, ew, Guard.newActionSet({1})) then
        return
    end
    local cfg = _bwcz_cfg()
    if not cfg then
        Player.sendmsgEx(play, "保卫村庄配置缺失#57")
        return
    end
    local saveData = _player_data(play)
    local nextCfg = _next_title_cfg(cfg, saveData.title_idx)
    if not nextCfg then
        Player.sendmsgEx(play, "当前已达到最高功勋称号#57")
        _refresh_panel(play, 1, 0)
        return
    end
    local need = tonumber(nextCfg.need) or 0
    local totalMerit = tonumber(saveData.total_merit) or 0
    if totalMerit < need then
        Player.sendmsgEx(play, "累计功勋不足，无法晋升至#57|【" .. tostring(nextCfg.name or "") .. "】#249|")
        _refresh_panel(play, 1, 0)
        return
    end
    saveData.title_idx = tonumber(nextCfg.idx) or 0
    saveData.title = tostring(nextCfg.name or "")
    saveData.merit = totalMerit
    _refresh_title(play, cfg, saveData)
    if BwczApi and BwczApi.save_player_data then
        BwczApi.save_player_data(play, saveData)
    end
    Player.sendmsgEx(play, "成功晋升至#57|【" .. tostring(nextCfg.name or "") .. "】#249|")
    _refresh_panel(play, 1, 0)
end

return npc