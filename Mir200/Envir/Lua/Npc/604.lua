npc = {}

local COST = {{"筑基丹碎片", 10}, {"灵气符文", 5}, {"金币", 500000}}

local function _get_count(play, name)
    return tonumber(getbagitemcount(play, name) or 0) or 0
end

local function _build_data(play)
    return {
        fragment = _get_count(play, "筑基丹碎片"),
        rune = _get_count(play, "灵气符文"),
        gold = _get_count(play, "金币"),
        need = {fragment = 10, rune = 5, gold = 500000},
    }
end

local function _send_data(play, npcid, p2)
    sendluamsg(play, 100, npcid, p2 or 0, 0, tbl2json(_build_data(play)))
end

function npc.main(play, npcid)
    _send_data(play, npcid, 0)
end

function npc.link(play, npcid, ew)
    if tonumber(ew or 0) ~= 1 then
        return
    end
    local name, num = Player.checkItemNumByTable(play, COST)
    if name then
        Player.sendmsgEx(play, string.format("你的#57|【%s】#218|不足，需求数量：#57|【%d】#218|", name, num))
        _send_data(play, npcid, 1)
        return
    end
    Player.takeItemByTable(play, COST, ",合成筑基丹", nil)
    giveitem(play, "筑基丹", 1)
    local record = Player.getJsonTableByVar(play, VarCfg["T_物品使用记录"]) or {}
    if tonumber(record.jz_dan_crafted or 0) ~= 1 then
        record.jz_dan_crafted = 1
        Player.setJsonVarByTable(play, VarCfg["T_物品使用记录"], record)
    end
    Player.sendmsgEx(play, "合成成功，获得#250|【筑基丹*1】#218|")
    if zxrw_try_finish_current_mainline then
        zxrw_try_finish_current_mainline(play, "任务")
    end
    _send_data(play, npcid, 1)
end

return npc
