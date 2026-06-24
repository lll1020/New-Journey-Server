npc = {}

local function _toint(v)
    return tonumber(v) or 0
end

local function _cfg(npcid)
    return Guard.getConfig("npc_" .. tostring(npcid)) or {}
end

local function _sd_data(play)
    return Player.getJsonTableByVar(play, VarCfg["T_登神之路"] or "T_登神之路") or {}
end

local function _has_cert(play, god)
    local data = _sd_data(play)
    local gods = type(data.gods) == "table" and data.gods or {}
    local info = gods[tostring(god)] or gods[god] or {}
    return _toint(info.cert) >= 1
end

local function _build_payload(play, npcid)
    local cfg = _cfg(npcid)
    return {has_cert = _has_cert(play, cfg.need_cert_god) and 1 or 0, has_item = (_toint(getbagitemcount(play, tostring(cfg.item_name or ""))) > 0) and 1 or 0}
end

local function _check_cost(play, cost)
    local missName, missNum = Player.checkItemNumByTable(play, cost)
    if missName then
        Player.sendmsgEx(play, string.format("材料不足：#57|【%s】#218| 需要 %d", tostring(missName), _toint(missNum)))
        return false
    end
    return true
end

function npc.main(play, npcid)
    sendluamsg(play, 100, npcid, 0, 0, tbl2json(_build_payload(play, npcid)))
end

function npc.link(play, npcid, p2, p3, msgData)
    if not Guard.ensurePlayer(play, npcid) then return end
    local action = Guard.normalizeAction(play, npcid, p2)
    if action == nil then return end
    p2 = action
    if not Guard.ensureActionAllowed(play, npcid, p2, Guard.newActionSet({1,9})) then return end
    local cfg = _cfg(npcid)
    if p2 == 1 then
        if _toint(getbagitemcount(play, tostring(cfg.item_name or ""))) > 0 then
            Player.sendmsgEx(play, "该秘宝已拥有，无需重复合成#57")
            return
        end
        if not _has_cert(play, cfg.need_cert_god) then
            Player.sendmsgEx(play, "需要先完成对应神道自证#57")
            return
        end
        if not _check_cost(play, cfg.cost or {}) then return end
        Player.takeItemByTable(play, cfg.cost or {}, "道基秘宝合成")
        giveitem(play, tostring(cfg.item_name or ""), 1)
        Player.sendmsgEx(play, string.format("合成成功，获得#57|【%s】#218|", tostring(cfg.item_name or "秘宝")))
    end
    sendluamsg(play, 100, npcid, p2, p3 or 0, tbl2json(_build_payload(play, npcid)))
end

return npc
