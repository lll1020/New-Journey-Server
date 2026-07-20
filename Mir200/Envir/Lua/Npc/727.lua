local npc = {}

local NPC_ID = 727
local _cfg_key = "npc_727"
local _config = Guard.getConfig(_cfg_key)

local function _story(play)
    return Player.getJsonTableByVar(play, VarCfg.T_dljq) or {}
end

local function _finish(play)
    local data = _story(play)
    if (tonumber(data[_cfg_key]) or 0) >= 2 then
        Player.sendmsgEx(play, "星象圣图封印已经解除#57")
        return
    end
    data[_cfg_key] = 2
    Player.setJsonVarByTable(play, VarCfg.T_dljq, data)
    Player.sendmsgEx(play, "帝星本源归位，星象圣图后续功能已经解锁#57")
    sendluamsg(play, 101, 1005, 0, 0, "rwwc")
end

function npc.main(play, npcid)
    if not Guard.ensureStoryPrerequisite(play, _config, NPC_ID) then
        return
    end
    _finish(play)
end

function npc.link(play, npcid, ew, aid, msgData)
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    if not Guard.ensureStoryPrerequisite(play, _config, NPC_ID) then
        return
    end
    _finish(play)
end

return npc