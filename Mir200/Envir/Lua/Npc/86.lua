local npc = {}

local _mijing_cfg = {
    [86] = {name = "极光秘境", map = "极光秘境", x = 100, y = 100, need_desc = "高级玩家赞助可进", need_titles = {"高级玩家", "高级玩家赞助", "至尊玩家", "至尊玩家赞助"}, artifact = "极光石", title_item = "极光使者[可使用]", title_name = "极光使者"},
    [87] = {name = "苍云秘境", map = "苍云秘境", x = 100, y = 100, need_desc = "高级玩家赞助可进", need_titles = {"高级玩家", "高级玩家赞助", "至尊玩家", "至尊玩家赞助"}, artifact = "苍云镜", title_item = "白云苍狗[可使用]", title_name = "白云苍狗"},
    [88] = {name = "若水秘境", map = "若水秘境", x = 100, y = 100, need_desc = "至尊玩家赞助可进", need_titles = {"至尊玩家", "至尊玩家赞助"}, artifact = "若水灵珠", title_item = "上善若水[可使用]", title_name = "上善若水"},
    [89] = {name = "红尘秘境", map = "红尘秘境", x = 100, y = 100, need_desc = "至尊玩家赞助可进", need_titles = {"至尊玩家", "至尊玩家赞助"}, artifact = "斩红尘", title_item = "看破红尘[可使用]", title_name = "看破红尘"},
    [90] = {name = "灵虚秘境", map = "灵虚秘境", x = 100, y = 100, need_desc = "激活5条红色仙法", need_red_xianfa = 5, artifact = "灵虚剑", title_item = "归入灵虚[可使用]", title_name = "归入灵虚"},
}

local function _get_cfg(npcid)
    return _mijing_cfg[tonumber(npcid or 0)]
end

local function _has_any_title(play, titles)
    for _, title in ipairs(titles or {}) do
        if title ~= "" and checktitle(play, title) then
            return true
        end
    end
    return false
end

local function _red_xianfa_count(play)
    local data = Player.getJsonTableByVar(play, VarCfg["T_天书"]) or {}
    local caowei = type(data.caowei) == "table" and data.caowei or {}
    local count = 0
    for _, value in pairs(caowei) do
        if type(value) == "table" and tonumber(value[1]) == 5 then
            count = count + 1
        end
    end
    return count
end

local function _can_enter(play, cfg)
    if not cfg then
        return false, "秘境配置不存在#57"
    end
    if cfg.need_titles and not _has_any_title(play, cfg.need_titles) then
        return false, "需要满足#57|【" .. tostring(cfg.need_desc or "进入条件") .. "】#249|才可进入秘境#57"
    end
    local needRed = tonumber(cfg.need_red_xianfa or 0) or 0
    if needRed > 0 and _red_xianfa_count(play) < needRed then
        return false, string.format("需要激活#57|【%d条红色仙法】#249|才可进入秘境#57", needRed)
    end
    return true, ""
end

local function _build_payload(play, cfg)
    local ok = _can_enter(play, cfg)
    return {
        name = cfg and cfg.name or "秘境",
        need_desc = cfg and cfg.need_desc or "",
        artifact = cfg and cfg.artifact or "",
        title_item = cfg and cfg.title_item or "",
        title_name = cfg and cfg.title_name or "",
        red_xianfa = _red_xianfa_count(play),
        can_enter = ok and 1 or 0,
    }
end
local function _enter_mijing(play, npcid, cfg)
    mapmove(play, cfg.map or cfg.name, cfg.x, cfg.y, 5)
    Guard.closeNpc(play, npcid)
    delaygoto(play, 500, "npc_86_start_auto", 0)
end

function npc.main(play, npcid)
    if getsysvar(VarCfg["G_合区次数对比"]) >= 1 or true then
        local cfg = _get_cfg(npcid)
        sendluamsg(play, 100, npcid, 0, 0, tbl2json(_build_payload(play, cfg)))
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
    local ok, err = _can_enter(play, cfg)
    if not ok then
        Player.sendmsgEx(play, err or "未满足秘境进入条件#57")
        return
    end
    if action == 1 then
        _enter_mijing(play, npcid, cfg)
    end
end

function npc_86_start_auto(play)
    startautoattack(play)
end

return npc
