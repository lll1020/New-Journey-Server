npc = {}
--功能21：沙巴克
local _config = Guard.getConfig("sbk") or {}
local _NPC_ID = 16 --攻沙面板NPC编号
--统一数值转换，避免变量为空时报错
local function _toint(value)
    return tonumber(value or 0) or 0
end
--统一字符串转换，兼容 nil
local function _tostr(value)
    if value == nil then
        return ""
    end
    return tostring(value)
end
--本服沙巴克地图名转跨服地图名
local function _to_kf_map_name(mapName)
    if mapName == "hjsbk" then
        return "kfhjsbk"
    end
    if mapName == "hg" then
        return "kfhg"
    end
    return mapName
end
--读取本服/跨服奖励配置
local function _get_reward_cfg(is_kf)
    return {
        minimum = _toint(_config.minimum ~= nil and _config.minimum or 600),
        killPoint = _toint(_config.killPoint ~= nil and _config.killPoint or 50),
        killedPoint = _toint(_config.killedPoint ~= nil and _config.killedPoint or 10),
        guaJiPoint = _toint(_config.guaJiPoint ~= nil and _config.guaJiPoint or 3),
        winReward = _toint(is_kf and (_config.kf_winReward or _config.winReward or 10000) or (_config.winReward or 10000)),
        loserReward = _toint(is_kf and (_config.kf_loserReward or _config.loserReward or 3000) or (_config.loserReward or 3000)),
        money = _tostr(_config.money ~= nil and _config.money or "绑定灵符#"),
    }
end
--读取本服/跨服可用传送点
local function _get_enter_map_list(is_kf)
    local maps = {}
    for _, mapInfo in ipairs(_config.map or {}) do
        maps[#maps + 1] = {
            mpa_name = is_kf and _to_kf_map_name(_tostr(mapInfo.mpa_name)) or _tostr(mapInfo.mpa_name),
            x = _toint(mapInfo.x),
            y = _toint(mapInfo.y),
        }
    end
    return maps
end
--根据模式选择个人积分变量
local function _get_points_var(is_kf)
    if is_kf then
        return VarCfg["U_攻沙积分跨服"]
    end
    return VarCfg["J_攻沙积分"]
end
--根据模式选择领奖状态变量
local function _get_claim_var(is_kf)
    if is_kf then
        return VarCfg["F_跨服攻沙是否领取"]
    end
    return VarCfg["J_是否领取沙奖励"]
end
--根据模式选择行会积分记录变量
local function _get_guild_var(is_kf)
    if is_kf then
        return VarCfg["A_行会积分记录跨服"]
    end
    return VarCfg["A_行会积分记录"]
end
local function _get_points(play, is_kf)
    return _toint(getplaydef(play, _get_points_var(is_kf)))
end
local function _set_points(play, is_kf, value)
    setplaydef(play, _get_points_var(is_kf), _toint(value))
end
local function _get_claimed(play, is_kf)
    if is_kf then
        return _toint(getflagstatus(play, _get_claim_var(true)))
    end
    return _toint(getplaydef(play, _get_claim_var(false)))
end
local function _set_claimed(play, is_kf, value)
    if is_kf then
        setflagstatus(play, _get_claim_var(true), _toint(value))
    else
        setplaydef(play, _get_claim_var(false), _toint(value))
    end
end
local _calculate_guild_points
local _add_player_points
local _KF_POINT_NAME = "跨服积分"
-- 跨服积分是持久化数值，不作为真实物品发放；奖励预览仍使用同名物品展示。
local function _get_kf_point_var()
    return VarCfg["U_跨服积分"] or "U49"
end
local function _add_kf_point(play, amount)
    amount = _toint(amount)
    if amount <= 0 then
        return
    end
    local varName = _get_kf_point_var()
    setplaydef(play, varName, _toint(getplaydef(play, varName)) + amount)
end
local function _split_kf_point_reward(reward)
    local mailItems = {}
    local point = 0
    for _, item in ipairs(reward or {}) do
        if type(item) == "table" and _tostr(item[1]) == _KF_POINT_NAME then
            point = point + _toint(item[2])
        else
            mailItems[#mailItems + 1] = item
        end
    end
    return mailItems, point
end
-- 首充礼包实际领取后才允许领取攻沙奖励。
local function _has_first_charge(play)
    local data = Player.getJsonTableByVar(play, VarCfg["T_首冲礼包"]) or {}
    return (tonumber(data.main_claimed or data.other_lb or data["首充"] or 0) or 0) >= 1
end
-- 固定奖励模式下，奖励表直接发邮件，避免继续按个人积分比例拆分。
local function _get_fixed_reward(camp, isChairman)
    local fixed = _config.fixed_rewards or {}
    local result = {}
    local base = camp == 0 and (fixed.loser or {}) or (fixed.winner or {})
    for _, item in ipairs(base) do
        result[#result + 1] = {item[1], _toint(item[2])}
    end
    if isChairman then
        for _, item in ipairs(fixed.chairman or {}) do
            result[#result + 1] = {item[1], _toint(item[2])}
        end
    end
    return result
end
local function _is_chairman(play, camp)
    if camp == 0 then
        return false
    end
    return _toint(castleidentity(play)) == 2 or _toint(getbaseinfo(play, ConstCfg.gbase.isboos)) == 1
end
local function _grant_chairman_title(play)
    local cfg = _config.chairman_title or {}
    local titleName = _tostr(cfg.name ~= nil and cfg.name or "沙城霸主")
    local seconds = _toint(cfg.seconds ~= nil and cfg.seconds or 48 * 3600)
    if titleName ~= "" and seconds > 0 then
        changetitletime(play, titleName, "=", seconds)
        confertitle(play, titleName, 0)
    end
end
--刷新攻沙面板运行数据
local function _refresh_panel(play, npcid, is_kf)
    local cfg = _get_reward_cfg(is_kf)
    local winnerGuildName, winnerPoints, loserPoints = _calculate_guild_points(is_kf)
    local data = {
        is_kf = is_kf and 1 or 0,
        minimum = cfg.minimum,
        myPoints = _get_points(play, is_kf),
        claimed = _get_claimed(play, is_kf),
        winReward = cfg.winReward,
        loserReward = cfg.loserReward,
        winnerGuildName = winnerGuildName,
        winnerPoints = winnerPoints,
        loserPoints = loserPoints,
        castleidentity = _toint(castleidentity(play)),
        reward_mode = _tostr(_config.reward_mode or "legacy"),
        need_first_charge = _toint(_config.need_first_charge or 0),
        has_first_charge = _has_first_charge(play) and 1 or 0,
        fixed_rewards = _config.fixed_rewards or {},
        chairman_title = _config.chairman_title or {},
        enter_maps = _get_enter_map_list(is_kf),
    }
    sendluamsg(play, 100, npcid or _NPC_ID, 0, 0, tbl2json(data))
end
--本服直接发放攻沙奖励邮件
local function _send_reward_mail(play, title, reward)
    if reward == nil or reward == "" then
        return
    end
    local userid = getbaseinfo(play, ConstCfg.gbase.id)
    sendmail(userid, 1, title, "请领取您的沙巴克奖励", reward)
end
-- 按当前阵营结算攻沙奖励：新配置为固定奖励，旧配置仍兼容积分比例拆分。
local function _claim_reward(play, is_kf)
    if castleinfo(5) then
        Player.sendmsgEx(play, "请在沙巴克攻城结束后领取奖励#57")
        return
    end
    if getmyguild(play) == "0" then
        Player.sendmsgEx(play, "你没有加入行会#57")
        return
    end
    if _get_claimed(play, is_kf) == 1 then
        Player.sendmsgEx(play, is_kf and "你已经领取过跨服沙巴克奖励了#57" or "你已经领取过沙巴克奖励了#57")
        return
    end
    if _toint(_config.need_first_charge or 0) == 1 and not _has_first_charge(play) then
        Player.sendmsgEx(play, "领取攻沙奖励需要先领取首充礼包#57")
        return
    end
    local cfg = _get_reward_cfg(is_kf)
    local myPoints = _get_points(play, is_kf)
    if myPoints < cfg.minimum then
        Player.sendmsgEx(play, "你的攻沙活跃度小于" .. tostring(cfg.minimum) .. "，无法领取奖励#57")
        return
    end
    local winnerGuildName, winnerPoints, loserPoints = _calculate_guild_points(is_kf)
    if winnerGuildName == "" then
        Player.sendmsgEx(play, "当前尚未产生沙巴克胜利行会#57")
        return
    end
    local camp = _toint(castleidentity(play))
    local rewardTitle = camp == 0 and "沙巴克失败方奖励" or "沙巴克胜利方奖励"
    local mailReward = ""
    local isChairman = _is_chairman(play, camp)
    if _tostr(_config.reward_mode or "legacy") == "fixed" then
        local reward = _get_fixed_reward(camp, isChairman)
        if #reward <= 0 then
            Player.sendmsgEx(play, "沙巴克固定奖励配置缺失#57")
            return
        end
        local mailItems, point = _split_kf_point_reward(reward)
        mailReward = Player.jl_mail(mailItems)
        if is_kf then
            mailReward = tbl2json({reward = mailReward, kf_point = point})
        else
            _add_kf_point(play, point)
        end
        if isChairman then
            rewardTitle = "沙巴克胜利方会长奖励"
        end
    else
        local rewardValue = 0
        if camp == 0 then
            if loserPoints <= 0 then
                Player.sendmsgEx(play, "失败方暂无可分配奖励#57")
                return
            end
            rewardValue = (cfg.loserReward / loserPoints) * myPoints
        else
            if winnerPoints <= 0 then
                Player.sendmsgEx(play, "胜利方暂无可分配奖励#57")
                return
            end
            rewardValue = (cfg.winReward / winnerPoints) * myPoints
        end
        mailReward = cfg.money .. tostring(numberRound(rewardValue))
    end
    _set_claimed(play, is_kf, 1)
    if isChairman then
        _grant_chairman_title(play)
    end
    if is_kf then
        FKuaFuToBenFuGongShaReward(play, rewardTitle, mailReward)
    else
        _send_reward_mail(play, rewardTitle, mailReward)
        if camp ~= 0 then
            GameEvent.push(EventCfg.GetCastleRewards, play)
        end
    end
    Player.sendmsgEx(play, "奖励已发送到邮件,请到邮件查收!#218")
    if _tostr(_config.reward_mode or "legacy") == "fixed" then
        Player.sendmsgEx(play, "跨服积分已直接计入角色数据#218")
    end
    _refresh_panel(play, _NPC_ID, is_kf)
end
function npc.main(play, npcid)
    _refresh_panel(play, npcid, checkkuafu(play))
end
function npc.link(play, npcid, ew, aid)
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local __guardAction = Guard.normalizeAction(play, npcid, ew)
    if __guardAction == nil then
        return
    end
    ew = __guardAction
    local __guardAllowedActions = Guard.newActionSet({1, 2, 3, 4})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end
    if ew == 3 then
        _refresh_panel(play, npcid, checkkuafu(play))
        return
    end
    if ew == 1 then
        if getmyguild(play) == "0" then
            Player.sendmsgEx(play, "你没有加入行会#57")
            return
        end
        if not castleinfo(5) then
            Player.sendmsgEx(play, "当前不是沙巴克攻城时间，无法进入沙巴克地图#57")
            return
        end
        local is_kf = checkkuafu(play)
        local maps = _get_enter_map_list(is_kf)
        local isInMap = false
        for _, mapInfo in ipairs(maps) do
            if FCheckMap(play, mapInfo.mpa_name) then
                isInMap = true
                break
            end
        end
        if isInMap then
            Player.sendmsgEx(play, "你已经在沙巴克地图中，无需重复传送#57")
            return
        end
        local targetMap = maps[aid] or maps[1]
        if not targetMap or targetMap.mpa_name == "" then
            Player.sendmsgEx(play, "沙巴克传送点配置缺失#57")
            return
        end
        mapmove(play, targetMap.mpa_name, targetMap.x, targetMap.y, 5)
        return
    end
    if ew == 2 or ew == 4 then
        _claim_reward(play, checkkuafu(play))
        return
    end
end
--统计达标成员后的胜负双方总积分
function _calculate_guild_points(is_kf)
    local cfg = _get_reward_cfg(is_kf)
    local winnerGuildName = _tostr(castleinfo(2))
    local winnerPoints = 0
    local loserPoints = 0
    local guildPoints = Player.getJsonTableByVar(nil, _get_guild_var(is_kf))
    if type(guildPoints) ~= "table" then
        guildPoints = {}
    end
    for guildName, players in pairs(guildPoints) do
        local totalPoints = 0
        if type(players) == "table" then
            for _, points in pairs(players) do
                points = _toint(points)
                if points >= cfg.minimum then
                    totalPoints = totalPoints + points
                end
            end
        end
        if guildName == winnerGuildName then
            winnerPoints = totalPoints
        else
            loserPoints = loserPoints + totalPoints
        end
    end
    return winnerGuildName, winnerPoints, loserPoints
end
npc.calculateGuildPoints = _calculate_guild_points
--写入个人积分并同步到对应的行会榜
function _add_player_points(guildName, playerName, points, is_kf)
    local guildPoints = Player.getJsonTableByVar(nil, _get_guild_var(is_kf))
    if type(guildPoints) ~= "table" then
        guildPoints = {}
    end
    if not guildPoints[guildName] then
        guildPoints[guildName] = {}
    end
    guildPoints[guildName][playerName] = _toint(points)
    Player.setJsonVarByTable(nil, _get_guild_var(is_kf), guildPoints)
    if is_kf then
        synzvar(2, "A5", "A5", 1)
    end
end
npc.addPlayerPoints = _add_player_points
--攻城开始前清空个人攻沙状态
local function _reset_actor_state(actor, is_kf)
    _set_points(actor, is_kf, 0)
    _set_claimed(actor, is_kf, 0)
end
--攻城开始：清空榜单并开启定时积分
local function _Castlewaract()
    setsysvar(VarCfg["A_行会积分记录"], "")
    setsysvar(VarCfg["A_行会积分记录跨服"], "")
    if checkkuafuserver() then
        setontimerex(2, 3)
    end
    for _, actor in ipairs(getplayerlst(1) or {}) do
        if checkkuafuserver() then
            if checkkuafu(actor) then
                _reset_actor_state(actor, true)
            end
            setontimer(actor, 2, 3, 0, 1)
        elseif not checkkuafu(actor) then
            _reset_actor_state(actor, false)
            setontimer(actor, 2, 3, 0, 1)
        end
    end
end
--攻城结束：关闭定时积分
local function _Castlewarend()
    for _, actor in ipairs(getplayerlst() or {}) do
        if checkkuafuserver() then
            setofftimer(actor, 2)
        elseif not checkkuafu(actor) then
            setofftimer(actor, 2)
        end
    end
    if checkkuafuserver() then
        setofftimerex(2)
    end
end
--攻城进行中：挂机持续加分
local function _Castlewaring(actor)
    if not castleinfo(5) then
        return
    end
    local is_kf = checkkuafu(actor)
    if checkkuafuserver() and not is_kf then
        return
    end
    if (not checkkuafuserver()) and is_kf then
        return
    end
    if not getbaseinfo(actor, ConstCfg.gbase.issbk) then
        return
    end
    local cfg = _get_reward_cfg(is_kf)
    local points = _get_points(actor, is_kf)
    local nextPoints = points + cfg.guaJiPoint
    _set_points(actor, is_kf, nextPoints)
    _add_player_points(getbaseinfo(actor, ConstCfg.gbase.guild), getbaseinfo(actor, ConstCfg.gbase.name), nextPoints, is_kf)
end
--本服登录时补开攻沙个人定时器
local function _onLoginEnd(actor)
    if checkkuafu(actor) then
        return
    end
    if castleinfo(5) then
        setontimer(actor, 2, 3, 0, 1)
    end
end
--跨服登录时补开攻沙个人定时器
local function _onKFLogin(actor)
    if not checkkuafu(actor) then
        return
    end
    if castleinfo(5) then
        setontimer(actor, 2, 3, 0, 1)
    end
end
--攻城击杀结算：杀人方和被杀方都计分
local function _Castlewarkill(actor, play)
    if not castleinfo(5) then
        return
    end
    if not getbaseinfo(actor, ConstCfg.gbase.issbk) then
        return
    end
    local is_kf = checkkuafu(actor)
    if checkkuafuserver() and not is_kf then
        return
    end
    if (not checkkuafuserver()) and is_kf then
        return
    end
    local cfg = _get_reward_cfg(is_kf)
    local points = _get_points(actor, is_kf)
    local nextPoints = points + cfg.killPoint
    _set_points(actor, is_kf, nextPoints)
    _add_player_points(getbaseinfo(actor, ConstCfg.gbase.guild), getbaseinfo(actor, ConstCfg.gbase.name), nextPoints, is_kf)
    local killedPoints = _get_points(play, is_kf)
    local killedNextPoints = killedPoints + cfg.killedPoint
    _set_points(play, is_kf, killedNextPoints)
    _add_player_points(getbaseinfo(play, ConstCfg.gbase.guild), getbaseinfo(play, ConstCfg.gbase.name), killedNextPoints, is_kf)
end
--跨服服返回奖励预览时刷新面板
local function _onKFGongShaRewardSync(actor)
    if checkkuafu(actor) then
        _refresh_panel(actor, _NPC_ID, true)
    end
end
--跨服服处理实际领奖请求
local function _onKFGongShaLinQu(actor)
    if checkkuafu(actor) then
        _claim_reward(actor, true)
    end
end
--跨服攻沙榜单同步到客户端
local function _goKFGongShaSync()
    if checkkuafuserver() then
        synzvar(2, "A5", "A5", 1)
    end
end
GameEvent.add(EventCfg.onLoginEnd, _onLoginEnd, "攻沙")
GameEvent.add(EventCfg.onKFLogin, _onKFLogin, "攻沙")
GameEvent.add(EventCfg.gocastlewaring, _Castlewaring, "攻沙")
GameEvent.add(EventCfg.gocastlewarstart, _Castlewaract, "攻沙")
GameEvent.add(EventCfg.goCastlewarend, _Castlewarend, "攻沙")
GameEvent.add(EventCfg.onkillplay, _Castlewarkill, "攻沙")
GameEvent.add(EventCfg.onKFGongShaRewardSync, _onKFGongShaRewardSync, "攻沙")
GameEvent.add(EventCfg.onKFGongShaLinQu, _onKFGongShaLinQu, "攻沙")
GameEvent.add(EventCfg.goKFGongShaSync, _goKFGongShaSync, "攻沙")
return npc