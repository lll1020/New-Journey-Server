npc = {}
local _npcid = 102
local _config = Guard.getConfig("npc_102") or teshudata["npc_102"] or {}
local _global_var = VarCfg["A_新区冲级json"] or "A16"
local _player_var = VarCfg["T_新区冲级"] or "T71"

local function _toint(v, d)
    return tonumber(v or d or 0) or (d or 0)
end

local function _is_open()
    return _toint(globalinfo(3), 0) <= 0
end

local function _get_global_data()
    return Player.getJsonTableByVar(nil, _global_var) or {}
end

local function _save_global_data(data)
    Player.setJsonTableByVar(nil, _global_var, data or {})
end

local function _get_player_data(play)
    return Player.getJsonTableByVar(play, _player_var) or {}
end

local function _save_player_data(play, data)
    Player.setJsonTableByVar(play, _player_var, data or {})
end

local function _reward_cfg(idx)
    return (_config.rewards or {})[_toint(idx)]
end

local function _has_reward(cfg)
    if not cfg then
        return false
    end
    if tostring(cfg.title or "") ~= "" then
        return true
    end
    return type(cfg.items) == "table" and #cfg.items > 0
end

local function _is_prev_claimed(idx, claimed)
    claimed = type(claimed) == "table" and claimed or {}
    for i = _toint(idx) - 1, 1, -1 do
        local cfg = _reward_cfg(i)
        if _has_reward(cfg) then
            return _toint(claimed[tostring(_toint(cfg.level))]) == 1, cfg
        end
    end
    return true, nil
end

local function _remove_other_titles(play, keepTitle)
    if not _config.title_replace then
        return
    end
    for _, cfg in ipairs(_config.rewards or {}) do
        local title = tostring(cfg.title or "")
        if title ~= "" and title ~= keepTitle and checktitle(play, title) then
            Player.title_del(play, title)
        end
    end
end

local function _build_payload(play)
    local globalData = _get_global_data()
    local playerData = _get_player_data(play)
    local claimed = type(playerData.claimed) == "table" and playerData.claimed or {}
    local playerLevel = _toint(getbaseinfo(play, 6), 0)
    local rows = {}
    for i, cfg in ipairs(_config.rewards or {}) do
        local level = _toint(cfg.level)
        local limit = _toint(cfg.limit)
        local title = tostring(cfg.title or "")
        local used = _toint(globalData[tostring(level)])
        local isClaimed = _toint(claimed[tostring(level)]) == 1
        local enoughLevel = playerLevel >= level
        local hasQuota = limit <= 0 or used < limit
        local hasReward = _has_reward(cfg)
        local orderOk = _is_prev_claimed(i, claimed)
        local canClaim = _is_open() and hasReward and enoughLevel and hasQuota and orderOk and not isClaimed
        rows[#rows + 1] = {
            idx = i,

            used = used,
            remaining = limit > 0 and math.max(0, limit - used) or -1,
            claimed = isClaimed and 1 or 0,
            has_title = title ~= "" and checktitle(play, title) and 1 or 0,
            can_claim = canClaim and 1 or 0,
            order_ok = orderOk and 1 or 0,
            no_reward = hasReward and 0 or 1,
        }
    end
    return {

        is_open = _is_open() and 1 or 0,
        merge_count = _toint(globalinfo(3), 0),
        player_level = playerLevel,
        rows = rows,
    }
end

local function _refresh_panel(play, ew, aid)
    sendluamsg(play, 100, _npcid, ew or 0, aid or 0, tbl2json(_build_payload(play)))
end

function npc.main(play, npcid)
    _refresh_panel(play, 0, 0)
    openhyperlink(play, 1, 2)
end
local function _build_mail_items(cfg)
    local mailItems = {}
    if type(cfg.items) == "table" then
        for _, item in ipairs(cfg.items) do
            local name = tostring(item[1] or "")
            local count = _toint(item[2], 0)
            if name ~= "" and count > 0 then
                mailItems[#mailItems + 1] = {name, count}
            end
        end
    end
    return mailItems
end

local function _send_reward_mail(play, cfg)
    local mailItems = _build_mail_items(cfg)
    local title = tostring(cfg.title or "")
    if #mailItems <= 0 and title == "" then
        return false
    end
    local mailDesc = "恭喜你达到" .. tostring(_toint(cfg.level)) .. "级，新区冲级奖励已发放，请及时领取。"
    if title ~= "" then
        mailDesc = mailDesc .. "\n获得称号：" .. title
    end
    local attachments = #mailItems > 0 and Player.jl_mail(mailItems) or ""
    sendmail(getbaseinfo(play, 2), 0, "新区冲级", mailDesc, attachments)
    if title ~= "" then
        _remove_other_titles(play, title)
        if not checktitle(play, title) then
            Player.title_give(play, title)
        end
        Player.sendmsgEx(play, "新区冲级奖励已发送到邮件：#57|【" .. title .. "】#218|")
    else
        Player.sendmsgEx(play, "新区冲级奖励已发送到邮件，请及时领取。")
    end
    return true
end
function npc.tryAutoSend(play)
    if not play or not _is_open() then
        return false
    end
    local playerLevel = _toint(getbaseinfo(play, 6), 0)
    local playerData = _get_player_data(play)
    playerData.claimed = type(playerData.claimed) == "table" and playerData.claimed or {}
    local globalData = _get_global_data()
    local changedPlayer = false
    local changedGlobal = false
    local sent = false
    for i, cfg in ipairs(_config.rewards or {}) do
        local level = _toint(cfg.level)
        if _has_reward(cfg) and playerLevel >= level then
            local key = tostring(level)
            if _toint(playerData.claimed[key]) ~= 1 then
                local orderOk = _is_prev_claimed(i, playerData.claimed)
                local limit = _toint(cfg.limit)
                local used = _toint(globalData[key])
                if orderOk and (limit <= 0 or used < limit) then
                    if _send_reward_mail(play, cfg) then
                        local title = tostring(cfg.title or "")
                        playerData.claimed[key] = 1
                        if title ~= "" then
                            playerData.last_title = title
                        end
                        changedPlayer = true
                        sent = true
                        if limit > 0 then
                            globalData[key] = used + 1
                            changedGlobal = true
                        end
                    end
                end
            end
        end
    end
    if changedPlayer then
        _save_player_data(play, playerData)
    end
    if changedGlobal then
        _save_global_data(globalData)
    end
    return sent
end

function npc.link(play, npcid, ew, aid, data)
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    _refresh_panel(play, 1, ew)
end
return npc