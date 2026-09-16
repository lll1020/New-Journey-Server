npc = {}

local NPC_KEY = "npc_1030"
local TITLE_NAME = "诸邪退散"
local TITLE_SHOW = "诸邪退散[称号]"
local DEFAULT_COST = {
    {"夜明珠", 1},
    {"金币", 880000},
    {"千年玄铁", 38},
}

local function _cfg()
    return Guard.getConfig(NPC_KEY) or {}
end

local function _cost()
    local cfg = _cfg()
    return cfg.cost or DEFAULT_COST
end

local function _title()
    local cfg = _cfg()
    return cfg.ch or TITLE_NAME
end

local function _done(play, data)
    data = data or Player.getJsonTableByVar(play, VarCfg.T_dljq)
    return tonumber(data[NPC_KEY] or 0) >= 2
        or tonumber(data["npc_1029"] or 0) >= 2
        or checktitle(play, _title())
        or checktitle(play, TITLE_SHOW)
end

local function _sync(play, npcid, mode, done)
    local data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    sendluamsg(play, 100, npcid or 1030, mode or 0, done and 2 or 0, tbl2json({
        T_dljq = data,
        done = done and 1 or 0,
    }))
end

function npc.main(play, npcid)
    local data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local current = tonumber(getplaydef(play, VarCfg.U_zxrw[1]) or 0) or 0
    if current == 36 and (tonumber(data[NPC_KEY] or 0) or 0) < 1 then
        data[NPC_KEY] = 1
        local ok = pcall(Player.setJsonVarByTable, play, VarCfg.T_dljq, data)
        if not ok then
            Player.sendmsgEx(play, "save data failed#57")
            return
        end
    end
    if current == 36 and zxrw_try_finish_current_mainline then
        zxrw_try_finish_current_mainline(play, "gray_pearl_visit")
    end
    _sync(play, npcid, 0, _done(play))
end

function npc.link(play, npcid, ew, aid, data)
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local action = Guard.normalizeAction(play, npcid, ew)
    if action == nil then
        return
    end
    if not Guard.ensureActionAllowed(play, npcid, action, Guard.newActionSet({1})) then
        return
    end

    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    if _done(play, jq_data) then
        jq_data[NPC_KEY] = 2
        pcall(Player.setJsonVarByTable, play, VarCfg.T_dljq, jq_data)
        Player.sendmsgEx(play, "已完成，无法重复合成#57")
        _sync(play, npcid, 1, true)
        return
    end

    if not Guard.ensureCost(play, _cost()) then
        return
    end

    Guard.consumeCost(play, _cost(), "," .. ((_cfg().name) or "合成夜明珠"))
    jq_data[NPC_KEY] = 2
    local ok = pcall(Player.setJsonVarByTable, play, VarCfg.T_dljq, jq_data)
    if not ok then
        Player.sendmsgEx(play, "save data failed#57")
        return
    end

    local titleName = _title()
    if not checktitle(play, titleName) then
        Player.title_give(play, titleName, 1)
    end
    Player.sendmsgEx(play, "合成成功，获得称号：诸邪退散#57")
    _sync(play, npcid, 1, true)
end

return npc
