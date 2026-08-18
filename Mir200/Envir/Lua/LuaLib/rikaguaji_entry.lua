local RiKaGuaJiEntry = {}

local function _toint(v, default)
    return tonumber(v or default or 0) or default or 0
end

local _cfg = {
    [1018] = {name = "极光[挂机]", map = "极光挂机", img = "极光"},
    [1019] = {name = "苍云[挂机]", map = "苍云挂机", img = "苍云"},
    [1020] = {name = "若水[挂机]", map = "若水挂机", img = "若水"},
    [1021] = {name = "红尘[挂机]", map = "红尘挂机", img = "红尘"},
    [1022] = {name = "灵虚[挂机]", map = "灵虚挂机", img = "灵虚"},
    [1023] = {name = "万灵[挂机]", map = "万灵挂机", img = "万灵"},
    [1024] = {name = "诸天[挂机]", map = "诸天挂机", img = "诸天"},
}

local function _get_cfg(npcid)
    return _cfg[_toint(npcid)]
end

local function _has_day_card(play)
    return checktitle(play, "日卡")
end

local function _check_enter(play, cfg)
    if not cfg then
        return false, "挂机地图配置不存在"
    end
    if not _has_day_card(play) then
        return false, "开通日卡后才可进入挂机地图"
    end
    return true
end

function RiKaGuaJiEntry.main(play, npcid)
    local cfg = _get_cfg(npcid)
    local ok, err = _check_enter(play, cfg)
    sendluamsg(play, 100, npcid, 0, 0, tbl2json({
        name = cfg and cfg.name or "日卡挂机",
        map = cfg and cfg.map or "",
        img = cfg and cfg.img or "",
        need_desc = "开通日卡",
        can_enter = ok and 1 or 0,
        error = err or "",
    }))
end

function RiKaGuaJiEntry.link(play, npcid, action)
    if _toint(action) ~= 1 then
        return
    end
    local cfg = _get_cfg(npcid)
    local ok, err = _check_enter(play, cfg)
    if not ok then
        Player.sendmsgEx(play, (err or "未满足进入条件") .. "#57")
        return
    end
    -- release_print("日卡挂机地图进入", play.pid, npcid, cfg.map)
    mapmove(play, cfg.map, cfg.x or 45, cfg.y or 45, cfg.range or 5)
    Guard.closeNpcAndAuto(play, npcid)
end

return RiKaGuaJiEntry
