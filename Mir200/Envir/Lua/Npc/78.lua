npc = {}

local _config = Guard.getConfig("npc_78") or {}

local function _toint(v)
    return tonumber(v) or 0
end

local function _build_payload(play)
    return {config = _config, equip = _config.equip or {}}
end

function npc.main(play, npcid)
    sendluamsg(play, 100, npcid, 0, 0, tbl2json(_build_payload(play)))
end

function npc.link(play, npcid, p2, p3, msgData)
    if not Guard.ensurePlayer(play, npcid) then return end
    local action = Guard.normalizeAction(play, npcid, p2)
    if action == nil then return end
    p2 = action
    if not Guard.ensureActionAllowed(play, npcid, p2, Guard.newActionSet({1,9})) then return end
    local req = json2tbl(msgData) or {}
    if p2 == 1 then
        local idx = _toint(req.idx or p3)
        local cfg = (_config.equip or {})[idx]
        if not cfg then Player.sendmsgEx(play, "装备参数错误#57") return end
        local itemName = tostring(cfg.name or "")
        if itemName == "" or _toint(getbagitemcount(play, itemName)) <= 0 then
            Player.sendmsgEx(play, string.format("背包中没有#57|【%s】#218|", itemName))
            return
        end
        takeitem(play, itemName, 1)
        changemoney(play, _toint(_config.recycle_money_id or 22), "+", _toint(_config.recycle_money or 500), "神道装备回收", true)
        Player.sendmsgEx(play, string.format("回收#57|【%s】#218|，获得%s*%d", itemName, tostring(_config.recycle_money_name or "灵符"), _toint(_config.recycle_money or 500)))
    end
    sendluamsg(play, 100, npcid, p2, p3 or 0, tbl2json(_build_payload(play)))
end

return npc
