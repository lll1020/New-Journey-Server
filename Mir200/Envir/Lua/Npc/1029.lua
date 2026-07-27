npc = {}

local function _toint(v)
    return tonumber(v or 0) or 0
end

local function _rebirth_level(play)
    return _toint(getplaydef(play, VarCfg["U_转生等级"]))
end

local function _send_contract_window(play)
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_灵兽"])
    local data = {
        T_data = T_data,
        server_time = os.time(),
        open_contract = 1,
        main_unlocked = Player.dl_sz_notip(play, 4) and 1 or 0,
    }
    sendluamsg(play, 100, 64, 0, 0, tbl2json(data))
end

function npc.main(play, npcid)
    if _rebirth_level(play) < 25 then
        Player.sendmsgEx(play, "完成三阶转生·五重后，才可领取灵兽蛋#57")
        return
    end
    _send_contract_window(play)
end

function npc.link(play, npcid, ew, aid, data)
    npc.main(play, npcid)
end

return npc
