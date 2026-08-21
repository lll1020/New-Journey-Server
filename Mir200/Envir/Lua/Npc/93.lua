npc = {}
-- 通天塔：每次从1层开始连续挑战，按本次爬到的层数累计通天积分，并记录历史最高层。

local _config = {
    max_floor = 10,
    map_src = "D3804_2",
    map_x = 29,
    map_y = 27,
    mob_x = 29,
    mob_y = 31,
    free_daily = 2,
    paid_daily = 1,
    paid_cost = {{"灵石", 500}},
    floor_points = {
        [1] = 2,
        [2] = 4,
        [3] = 6,
        [4] = 8,
        [5] = 10,
        [6] = 20,
        [7] = 50,
        [8] = 80,
        [9] = 120,
        [10] = 200,
    },
    floor_mobs = {
        [1] = "潮纹兽",                    -- 四大陆中怪属性*1
        [2] = "长安·夜巡使",                    -- 四大陆中怪属性*2
        [3] = "阴司·巡夜判",                    -- 四大陆中怪属性*4
        [4] = "生死·界限者",                        -- 四大陆中怪属性*6
        [5] = "神风行者",                        -- 四大陆中怪属性*8
        [6] = "丛林僵尸",                        -- 四大陆中怪属性*10
        [7] = "火焰幼龙",                        -- 四大陆中怪属性*12
        [8] = "≮生命终章·边界尊≯",              -- 四大陆中怪属性*14
        [9] = "恶魔巫师",                        -- 四大陆中怪属性*16
        [10] = "毁灭骑士·贝利亚斯(Boss)",        -- 四大陆中怪属性*20
    },
    exchange = {
        [1] = {name = "神·五行石", count = 1, cost = 10, limit_type = "daily", limit = 1},
        [2] = {name = "灵兽蛋", count = 1, cost = 50, limit_type = "daily", limit = 1},
        [3] = {title = "通天能手", cost = 200, limit_type = "life", limit = 1, desc = "全属性+1%，PK增伤+1%，打怪暴率+38%，攻击速度+10%"},
        [4] = {title = "通天老祖", cost = 500, limit_type = "life", limit = 1, desc = "全属性+2%，PK增伤+3%，打怪暴率+68%，攻击速度+20%"},
        [5] = {title = "通天仙尊", cost = 1000, limit_type = "life", limit = 1, desc = "全属性+3%，PK增伤+5%，打怪暴率+98%，冰冻概率+1%，攻击速度+30%"},
    },
    title_order = {"通天能手", "通天老祖", "通天仙尊"},
}

local function _tower_var()
    return VarCfg["T_锁妖塔"] or "T51"
end

local function _today()
    return os.date("%Y%m%d")
end

local function _reset_daily(data)
    local today = _today()
    data.daily = data.daily or {}
    if data.daily.date ~= today then
        data.daily = {date = today, free = 0, paid = 0}
        data.exchange_daily = {date = today}
    end
    data.daily.free = tonumber(data.daily.free or 0) or 0
    data.daily.paid = tonumber(data.daily.paid or 0) or 0
    data.exchange_daily = data.exchange_daily or {date = today}
    if data.exchange_daily.date ~= today then
        data.exchange_daily = {date = today}
    end
end

local function _get_data(play)
    local data = Player.getJsonTableByVar(play, _tower_var()) or {}
    local best = tonumber(data.best_floor or data.floor or 0) or 0
    data.best_floor = best
    data.floor = best
    data.run_floor = tonumber(data.run_floor or 0) or 0
    data.active_floor = tonumber(data.active_floor or 0) or 0
    data.in_run = tonumber(data.in_run or 0) or 0
    data.points = tonumber(data.points or 0) or 0
    data.total_runs = tonumber(data.total_runs or 0) or 0
    data.exchange_life = data.exchange_life or {}
    _reset_daily(data)
    return data
end

local function _save_data(play, data)
    Player.setJsonVarByTable(play, _tower_var(), data or {})
end

local function _public_exchange_cfg()
    local list = {}
    for id, cfg in pairs(_config.exchange) do
        list[id] = {
            id = id,
            name = cfg.name,
            title = cfg.title,
            count = cfg.count,
            cost = cfg.cost,
            limit_type = cfg.limit_type,
            limit = cfg.limit,
            desc = cfg.desc,
        }
    end
    return list
end

local function _payload(play)
    local data = _get_data(play)
    _save_data(play, data)
    return {
        data = data,
        cfg = {
            max_floor = _config.max_floor,
            free_daily = _config.free_daily,
            paid_daily = _config.paid_daily,
            paid_cost = _config.paid_cost,
            floor_points = _config.floor_points,
            exchange = _public_exchange_cfg(),
        }
    }
end

local function _consume_challenge_count(play, data)
    _reset_daily(data)
    if data.daily.free < _config.free_daily then
        data.daily.free = data.daily.free + 1
        data.total_runs = (tonumber(data.total_runs or 0) or 0) + 1
        _save_data(play, data)
        return true
    end
    if data.daily.paid < _config.paid_daily then
        if not Guard.ensureCost(play, _config.paid_cost) then
            return false
        end
        Guard.consumeCost(play, _config.paid_cost, ",通天塔付费挑战")
        data.daily.paid = data.daily.paid + 1
        data.total_runs = (tonumber(data.total_runs or 0) or 0) + 1
        _save_data(play, data)
        return true
    end
    Player.sendmsgEx(play, "今日通天塔挑战次数已用完#57")
    return false
end

local function _exchange_count(data, id, cfg)
    if cfg.limit_type == "daily" then
        return tonumber((data.exchange_daily or {})[tostring(id)] or 0) or 0
    end
    return tonumber((data.exchange_life or {})[tostring(id)] or 0) or 0
end

local function _add_exchange_count(data, id, cfg)
    local key = tostring(id)
    if cfg.limit_type == "daily" then
        data.exchange_daily[key] = (tonumber(data.exchange_daily[key] or 0) or 0) + 1
    else
        data.exchange_life[key] = (tonumber(data.exchange_life[key] or 0) or 0) + 1
    end
end

local function _give_exchange_reward(play, cfg)
    if cfg.name then
        Player.rwjl(play, {{cfg.name, cfg.count or 1}}, "通天塔兑换", 1, 0)
        return
    end
    if cfg.title then
        for _, title in ipairs(_config.title_order) do
            if title ~= cfg.title and checktitle(play, title) then
                Player.title_del(play, title)
            end
        end
        if not checktitle(play, cfg.title) then
            Player.title_give(play, cfg.title, 1)
        end
        Player.sendmsgEx(play, "获得称号：|【" .. cfg.title .. "】#218|")
    end
end

local function _do_exchange(play, npcid, id)
    id = tonumber(id or 0) or 0
    local cfg = _config.exchange[id]
    if not cfg then
        Player.sendmsgEx(play, "兑换配置不存在#57")
        return
    end
    local data = _get_data(play)
    local used = _exchange_count(data, id, cfg)
    if used >= (tonumber(cfg.limit or 0) or 0) then
        Player.sendmsgEx(play, "该奖励已达到限购次数#57")
        return
    end
    if data.points < (tonumber(cfg.cost or 0) or 0) then
        Player.sendmsgEx(play, "通天积分不足#57")
        return
    end
    data.points = data.points - cfg.cost
    _add_exchange_count(data, id, cfg)
    _give_exchange_reward(play, cfg)
    _save_data(play, data)
    sendluamsg(play, 100, npcid, 0, 0, tbl2json(_payload(play)))
end

function npc.main(play, npcid)
    sendluamsg(play, 100, npcid, 0, 0, tbl2json(_payload(play)))
end

function npc.link(play, npcid, ew, aid, msgData)
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local action = Guard.normalizeAction(play, npcid, ew)
    if action == nil then
        return
    end
    if not Guard.ensureActionAllowed(play, npcid, action, Guard.newActionSet({1, 2, 3})) then
        return
    end
    if action == 1 then
        local data = _get_data(play)
        local canResume = data.in_run == 1 and data.active_floor <= 0 and data.run_floor > 0 and data.run_floor < _config.max_floor
        if not canResume then
            if not _consume_challenge_count(play, data) then
                return
            end
            data.run_floor = 0
            data.active_floor = 0
            data.in_run = 1
            _save_data(play, data)
        end
        setplaydef(play, VarCfg.S_sdlmjdt, tbl2json({dt = getbaseinfo(play, 3), xx = getbaseinfo(play, 4), yy = getbaseinfo(play, 5)}))
        syt_jrdt_93(play)
    elseif action == 2 then
        _do_exchange(play, npcid, aid)
    elseif action == 3 then
        local data = _get_data(play)
        if not _consume_challenge_count(play, data) then
            return
        end
        data.run_floor = 0
        data.active_floor = 0
        data.in_run = 1
        _save_data(play, data)
        setplaydef(play, VarCfg.S_sdlmjdt, tbl2json({dt = getbaseinfo(play, 3), xx = getbaseinfo(play, 4), yy = getbaseinfo(play, 5)}))
        syt_jrdt_93(play)
    end
end

function npc_93_fbjs(play)
    senddelaymsg(play, "距离副本通关剩余%s", 180, 250, 1, "@npc_93_fb_end")
end

function npc_93_fb_end(play)
    local dtm = getbaseinfo(play, 1) .. "_ttt"
    if getbaseinfo(play, 3) ~= dtm then
        return
    end
    if getmoncount(dtm, -1, true) < 1 then
        setenvirofftimer(dtm, 1)
        local data = _get_data(play)
        local passFloor = tonumber(data.active_floor or 0) or 0
        if passFloor <= 0 then
            passFloor = (tonumber(data.run_floor or 0) or 0) + 1
        end
        passFloor = math.min(passFloor, _config.max_floor)
        data.run_floor = passFloor
        data.active_floor = 0
        if passFloor > data.best_floor then
            data.best_floor = passFloor
            data.floor = passFloor
        end
        data.points = data.points + (tonumber(_config.floor_points[passFloor] or 0) or 0)
        _save_data(play, data)
        Player.sendmsgEx(play, "成功通过通天塔第" .. tostring(passFloor) .. "层，获得通天积分+" .. tostring(_config.floor_points[passFloor] or 0) .. "#57")
        if passFloor >= _config.max_floor then
            data.in_run = 0
            data.run_floor = 0
            data.active_floor = 0
            _save_data(play, data)
            delmirrormap(dtm)
            rw_exit(play)
        else
            local nextFloor = passFloor + 1
            say(play, string.format([[<Img|id=ui_1|x=296|y=231|width=540|height=230|img=wy\public\ts_bj.png|bg=1|move=0|reset=1|show=0|loadDelay=1>
<Layout|id=ui_2|x=796|y=225|width=80|height=80|link=@exit>
<Text|id=ui_4|x=465|y=253|outlinecolor=75|color=244|size=25|text=成功通过第%d层>
<Text|id=ui_10|x=405|y=292|outlinecolor=75|color=250|size=18|text=继续挑战第%d层>
<Text|id=ui_11|x=405|y=320|outlinecolor=75|color=254|size=16|text=退出后下次可从第%d层继续>
<Button|id=ui_3|x=730|y=237|width=58|height=56|nimg=wy/public/999.png|color=255|size=18|link=@exit>
<Button|id=ui_6|children={ui_7,ui_9}|x=552|y=342|width=204|height=88|nimg=wy/public/an_tongyong.png|pimg=wy/public/an_tongyong.png|color=251|size=18|link=@syt_jrdt_93>
<Text|id=ui_7|x=51|y=28|color=255|size=18|text=继续挑战>
<TIMETIPS|id=ui_9|x=148|y=28|time=5|color=255|size=18|count=1|link=@syt_jrdt_93>
<Button|id=ui_5|children={ui_8}|x=323|y=342|width=204|height=88|nimg=wy/public/an_tongyong.png|pimg=wy/public/an_tongyong.png|color=251|size=18|link=@tt_exit_93>
<Text|id=ui_8|x=95|y=28|color=255|size=18|text=退出>]], passFloor, nextFloor, nextFloor))
        end
    else
        setenvirofftimer(dtm, 1)
        local data = _get_data(play)
        data.in_run = 0
        data.run_floor = 0
        data.active_floor = 0
        _save_data(play, data)
        Player.sendmsgEx(play, "未通过本层，请继续修行吧#57")
        delmirrormap(dtm)
        rw_exit(play)
    end
end

function npc_93_fb_dsq(xt, play, dtm)
    if getplaycount(dtm, false, true) == "0" then
        setenvirofftimer(dtm, 1)
        local data = _get_data(play)
        if data.active_floor > 0 then
            data.in_run = 0
            data.run_floor = 0
            data.active_floor = 0
            _save_data(play, data)
        end
        delmirrormap(dtm)
        return
    end
    if getmoncount(dtm, -1, true) < 1 then
        npc_93_fb_end(play)
    end
end

function tt_exit_93(play)
    local dtm = getbaseinfo(play, 1) .. "_ttt"
    if checkmirrormap(dtm) then
        delmirrormap(dtm)
    end
    local data = _get_data(play)
    if data.active_floor > 0 or data.run_floor <= 0 then
        data.in_run = 0
        data.run_floor = 0
        data.active_floor = 0
    else
        data.in_run = 1
        data.active_floor = 0
    end
    _save_data(play, data)
    rw_exit(play)
end

function syt_jrdt_93(play)
    local data = _get_data(play)
    if data.in_run ~= 1 then
        data.in_run = 1
        data.run_floor = 0
        data.active_floor = 0
    end
    local nextFloor = (tonumber(data.run_floor or 0) or 0) + 1
    if nextFloor > _config.max_floor then
        Player.sendmsgEx(play, "通天塔已全部通关#57")
        data.in_run = 0
        data.run_floor = 0
        data.active_floor = 0
        _save_data(play, data)
        return
    end
    data.active_floor = nextFloor
    data.in_run = 1
    _save_data(play, data)
    local dtm = getbaseinfo(play, 1) .. "_ttt"
    if checkmirrormap(dtm) then
        delmirrormap(dtm)
    end
    addmirrormap(_config.map_src, dtm, "通天塔第" .. tostring(nextFloor) .. "层", 300,"xtc",136,136)
    mapmove(play, dtm, _config.map_x, _config.map_y, 2)
    local mobName = _config.floor_mobs[nextFloor] or "≮通天塔主≯"
    genmonex(dtm, _config.mob_x, _config.mob_y, mobName, 2, 1, 0, 54, "", 0)
    if getmoncount(dtm, -1, true) < 1 then
        data.in_run = 0
        data.run_floor = 0
        data.active_floor = 0
        _save_data(play, data)
        Player.sendmsgEx(play, "通天塔怪物刷新失败，请检查怪物配置：" .. tostring(mobName) .. "#57")
        delmirrormap(dtm)
        rw_exit(play)
        return
    end
    startautoattack(play)
    setenvirontimer(dtm, 1, 1, "@npc_93_fb_dsq," .. play .. "," .. dtm)
    delaygoto(play, 100, "@npc_93_fbjs")
end

return npc
