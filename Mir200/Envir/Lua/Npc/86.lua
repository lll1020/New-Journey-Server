local npc = {}

local _title_name = "日卡"
local _mijing_cfg = {
    [86] = {name = "苍云秘境", x = 100, y = 100},
    [87] = {name = "若水秘境", x = 100, y = 100},
    [88] = {name = "红尘秘境", x = 100, y = 100},
    [89] = {name = "灵虚秘境", x = 100, y = 100},
    [90] = {name = "万灵秘境", x = 100, y = 100},
    [91] = {name = "诸天秘境", x = 100, y = 100},
}

local function _get_cfg(npcid)
    return _mijing_cfg[tonumber(npcid or 0)]
end

local function _has_day_card(play)
    return checktitle(play, _title_name)
end

function npc.main(play, npcid)
    if getsysvar(VarCfg["G_合区次数对比"]) >= 1 then
        local cfg = _get_cfg(npcid)
        sendluamsg(play, 100, npcid, 0, 0, tbl2json({
            name = cfg and cfg.name or "秘境",
            need_title = _title_name,
            has_title = _has_day_card(play) and 1 or 0,
        }))
    else
        Player.sendmsgEx(play, "合区后开启#57")
    end

    
end

function npc.link(play, npcid, ew, aid, msgData)
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
    local cfg = _get_cfg(npcid)
    if not cfg then
        Player.sendmsgEx(play, "秘境配置不存在#57")
        return
    end
    if action == 1 then
        if not _has_day_card(play) then
            Player.sendmsgEx(play, "需要拥有#57|【日卡】#249|称号才可进入秘境#57")
            return
        end
        mapmove(play, cfg.name, cfg.x, cfg.y, 5)
        delaygoto(play, 200, "npc_86_start_auto", 0)
    end
end

function npc_86_start_auto(play)
    startautoattack(play)
end

return npc