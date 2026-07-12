local KuafuMapEntry = {}

local function _toint(v, default)
    return tonumber(v or default or 0) or default or 0
end

local function _msg(play, text)
    if Player and Player.sendmsgEx then
        Player.sendmsgEx(play, tostring(text or "") .. "#57")
    else
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff7700\'>[跨服]</font><font color=\'#ff0000\'>' .. tostring(text or "") .. '</font>","Type":9}')
    end
end

local function _has_any_title(play, titles)
    for _, title in ipairs(titles or {}) do
        if title ~= "" and checktitle(play, title) then
            return true
        end
    end
    return false
end

local function _open_day()
    local day = _toint(getsysvar(VarCfg["G_开区天数"]), 0)
    if day > 0 then
        return day
    end
    local minute = _toint(getsysvar(VarCfg["G_开区分钟"]), 0)
    if minute <= 0 then
        return 1
    end
    return math.floor(minute / 1440) + 1
end

local function _has_day_card(play)
    return checktitle(play, "日卡")
end

local function _has_all_linggen(play)
    local data = Player.getJsonTableByVar(play, VarCfg["T_灵根"]) or {}
    local levels = type(data.level) == "table" and data.level or {}
    for i = 1, 10 do
        if _toint(levels[tostring(i)] or levels[i], 0) <= 0 then
            return false
        end
    end
    return true
end

local function _has_all_destiny(play)
    local jq = Player.getJsonTableByVar(play, VarCfg.T_dljq) or {}
    local state = type(jq["npc_74"]) == "table" and jq["npc_74"] or {}
    local need = _toint((((teshudata or {})["npc_74"] or {}).all), 4)
    return _toint(state.all, 0) >= need
end

local _cfg = {
    [1013] = {
        name = "幽邃地窟",
        map = "幽邃地窟",
        open_day = 1,
        condition_desc = "玩家等级达到150级+日卡",
        check = function(play)
            if _toint(getbaseinfo(play, 6), 0) < 150 then
                return false, "玩家等级达到150级后才可进入"
            end
            return true
        end,
    },
    [1014] = {
        name = "摄魂红尘",
        map = "摄魂红尘",
        open_day = 5,
        condition_desc = "激活全部灵根+日卡",
        check = function(play)
            if not _has_all_linggen(play) then
                return false, "需要激活全部灵根后才可进入"
            end
            return true
        end,
    },
    [1015] = {
        name = "逆灵离心",
        map = "逆灵离心",
        open_day = 10,
        condition_desc = "完成天道命盘+日卡",
        check = function(play)
            if not _has_all_destiny(play) then
                return false, "需要完成天道命盘后才可进入"
            end
            return true
        end,
    },
    [1016] = {
        name = "生死之门",
        map = "生死之门",
        open_day = 15,
        condition_desc = "拥有称号：世界符文·[真我]+日卡",
        check = function(play)
            if not checktitle(play, "世界符文·[真我]") then
                return false, "需要获得世界符文·[真我]称号后才可进入"
            end
            return true
        end,
    },
    [1017] = {
        name = "跨服秘境",
        map = "跨服秘境",
        open_day = 3,
        condition_desc = "至尊赞助玩家+日卡",
        check = function(play)
            if not _has_any_title(play, {"至尊玩家", "至尊玩家赞助"}) then
                return false, "需要至尊玩家赞助后才可进入"
            end
            return true
        end,
    },
}

local function _get_cfg(npcid)
    return _cfg[_toint(npcid, 0)]
end

local function _check_enter(play, cfg)
    if not cfg then
        return false, "跨服地图配置不存在"
    end
    if not checkkuafuconnect() then
        return false, "跨服未开启，请稍后再试"
    end
    local needDay = _toint(cfg.open_day, 1)
    if _open_day() < needDay then
        return false, "地图暂未开放"
    end
    if not _has_day_card(play) then
        return false, "需要先领取日卡后才可进入"
    end
    if cfg.check then
        local ok, err = cfg.check(play)
        if not ok then
            return false, err or "未满足进入条件"
        end
    end
    return true
end

function KuafuMapEntry.main(play, npcid)
    local cfg = _get_cfg(npcid)
    local data = {
        name = cfg and cfg.name or "跨服地图",
        map = cfg and cfg.map or "",
        open_day = cfg and cfg.open_day or 0,
        condition_desc = cfg and cfg.condition_desc or "",
        open_day_now = _open_day(),
        has_day_card = _has_day_card(play) and 1 or 0,
    }
    local ok = _check_enter(play, cfg)
    data.can_enter = ok and 1 or 0
    sendluamsg(play, 100, npcid, 0, 0, tbl2json(data))
end

function KuafuMapEntry.link(play, npcid, action)
    if action ~= 1 then
        return
    end
    local cfg = _get_cfg(npcid)
    local ok, err = _check_enter(play, cfg)
    if not ok then
        _msg(play, err)
        return
    end
    mapmove(play, cfg.map, cfg.x or 45, cfg.y or 45, cfg.range or 4)
    sendmsg(play, 1, '{"Msg":"<font color=\'#ff7700\'>[跨服]</font><font color=\'#00ff00\'>跨服传送成功</font>","Type":9}')
end

return KuafuMapEntry
