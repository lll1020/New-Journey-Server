npc = {}

local _config = Guard.getConfig("npc_628")
local _prep_key = "npc_628_rw"
local _main_key = "npc_628"

local function _get_task_data(play)
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
    return jq_data, sg_data
end

local function _left_eye_name()
    local prep = _config and _config.prep_task or {}
    return prep.left_name or "真视之眼左"
end

local function _right_eye_name()
    local prep = _config and _config.prep_task or {}
    return prep.right_name or "真视之眼右"
end

local function _prep_item_name()
    local prep = _config and _config.prep_task or {}
    return prep.name or "真视之眼"
end

local function _has_prep_item_equipped(play)
    local need_name = _prep_item_name()
    if not need_name or need_name == "" then
        return false
    end
    -- 真视之眼属于背包神器，只认神器位穿戴。
    return Player.hasEquipInArtifactSlot(play, need_name) ~= nil
end

local function _has_left_eye(play)
    return getbagitemcount(play, _left_eye_name()) >= 1
end

local function _has_right_eye(play)
    return getbagitemcount(play, _right_eye_name()) >= 1
end

local function _remove_finish_item(play, item_name)
    if not item_name or item_name == "" then
        return false
    end
    for pos = 0, 120 do
        local itemobj = linkbodyitem(play, pos)
        if itemobj and itemobj ~= "0" then
            local name = getiteminfo(play, itemobj, ConstCfg.iteminfo.name)
            if name == item_name then
                return delitembymakeindex(play, getiteminfo(play, itemobj, 1), 1)
            end
        end
    end
    if getbagitemcount(play, item_name) > 0 then
        takeitem(play, item_name, 1)
        return true
    end
    return false
end

function npc.main(play,npcid)
    if not _config then
        return
    end
    local jq_data, sg_data = _get_task_data(play)
    local data = {}
    data["T_dljq"] = jq_data
    data["sg_data"] = sg_data
    sendluamsg(play,100,npcid,0,0,tbl2json(data))
end

local function npc_628_spawn_main(dtm)
    local mob_name = _config.mob or "怪物"
    genmonex(dtm, 32, 36, mob_name, 1, 1, 0, 54, "", 0)
end

local function npc_628_spawn_x(dtm)
    local mob_name = _config.mob_x or "怪物[目标]"
    genmonex(dtm, 32, 36, mob_name, 1, 1, 0, 54, "", 0)
end

local function npc_628_count_by_name(dtm, name)
    if not name or name == "" then
        return 0
    end
    local list = getobjectinmap(dtm, 0, 0, 999, 2)
    local cnt = 0
    if list then
        for _, v in ipairs(list) do
            if getbaseinfo(v,1) == name then
                cnt = cnt + 1
            end
        end
    end
    return cnt
end

local function npc_628_kill_by_name(play, dtm, name)
    if not name or name == "" then
        return
    end
    local list = getobjectinmap(dtm, 0, 0, 999, 2)
    if list then
        for _, v in ipairs(list) do
            if getbaseinfo(v,1) == name then
                humanhp(v, "-", 999999999, 107, 0, play)
            end
        end
    end
end

function npc.link(play,npcid,ew,aid)
    if not _config then
        return
    end
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local __guardAction = Guard.normalizeAction(play, npcid, ew)
    if __guardAction == nil then
        return
    end
    ew = __guardAction
    local __guardAllowedActions = Guard.newActionSet({1, 2})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end

    local jq_data, sg_data = _get_task_data(play)
    if ew == 1 then
        if jq_data[_main_key] and jq_data[_main_key] >= 2 then
            Player.sendmsgEx(play, "任务已完成，无法再次进入#57")
            return
        end
        -- 允许玩家跳过前置任务直接进入该讨伐副本，前置任务改为独立可选线路。
        if not Guard.ensureCost(play, _config.cost) then
            return
        end
        Guard.consumeCost(play, _config.cost, ","..(_config.name or "剧情任务"))
        jq_data[_main_key] = 1
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        npc_628_enter(play)
        return
    end

    if ew == 2 then
        local state = tonumber(jq_data[_prep_key] or 0) or 0
        local item_name = _prep_item_name()
        local left_name = _left_eye_name()
        local right_name = _right_eye_name()
        if state >= 2 then
            Player.sendmsgEx(play, "你已经完成了#57|"..item_name.."#249|#57")
            return
        end
        if state == 0 then
            jq_data[_prep_key] = 1
            Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
            shaguai.jia(play, 628)
            Player.sendmsgEx(play, "领取任务：#57|"..item_name.."#249|在#57|"..((_config.prep_task and _config.prep_task.map) or "虚妄山脉").."#249|分别找回左右眼")
            if npcid then Guard.closeNpcAndAuto(play, npcid) end
            sendluamsg(play,100,npcid,1,1,"")
            return
        end
        if not _has_left_eye(play) or not _has_right_eye(play) then
            local left = _has_left_eye(play) and 1 or 0
            local right = _has_right_eye(play) and 1 or 0
            Player.sendmsgEx(play, "当前进度："..left_name.."#57|"..left.."/1#249| "..right_name.."#57|"..right.."/1#249|")
            return
        end
        takeitem(play, left_name, 1)
        takeitem(play, right_name, 1)
        jq_data[_prep_key] = 2
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        shaguai.jian(play, 628)
        giveitem(play, item_name, 1)
        Player.sendmsgEx(play, "任务完成，获得物品#57|"..item_name.."#249|#57")
        sendluamsg(play,100,npcid,1,2,"")
    end
end

function npc_628_savepos(play)
    local map = getbaseinfo(play,3)
    local x = getbaseinfo(play,4)
    local y = getbaseinfo(play,5)
    setplaydef(play, "S$npc628_back", map..","..x..","..y)
end

function npc_628_back(play)
    local back = getplaydef(play, "S$npc628_back")
    if back and back ~= "" then
        local parts = split(back, ",")
        local map = parts[1]
        local x = tonumber(parts[2]) or 0
        local y = tonumber(parts[3]) or 0
        if map and map ~= "" and x > 0 and y > 0 then
            mapmove(play, map, x, y, 2)
        end
    end
    setplaydef(play, "S$npc628_back", "")
end

function npc_628_enter(play)
    npc_628_savepos(play)
    local dtm = getbaseinfo(play,1).."_npc628"
    if checkmirrormap(dtm) then
        delmirrormap(dtm)
    end
    local base_map = _config.fb_map or "mwsl"
    addmirrormap(base_map, dtm, _config.name or "副本", 300, "xtc")
    mapmove(play, dtm, 29, 27, 2)

    if _has_prep_item_equipped(play) then
        npc_628_spawn_main(dtm)
    else
        npc_628_spawn_x(dtm)
        Player.sendmsgEx(play, "未装备#57|真视之眼#249|时无法看见妄灾本体#57")
    end

    startautoattack(play)
    setenvirontimer(dtm, 1, 1, "@npc_628_dsq,"..play..","..dtm)
    senddelaymsg(play, "距离副本结束剩余%s", 300, 250, 1, "@npc_628_timeout")
end

function npc_628_dsq(xt,play,dtm,data)
    if getplaycount(dtm,false,true) == "0" then
        setenvirofftimer(dtm, 1)
        delmirrormap(dtm)
        return
    end

    local main_name = _config.mob or "怪物"
    local x_name = _config.mob_x or "怪物[目标]"
    local can_see = _has_prep_item_equipped(play)
    local main_count = npc_628_count_by_name(dtm, main_name)
    local x_count = npc_628_count_by_name(dtm, x_name)

    -- 先判定妄灾是否已经被击杀，避免本体死亡后又因为显隐切换逻辑被重新补刷。
    if main_count + x_count < 1 then
        setenvirofftimer(dtm, 1)
        npc_628_finish(play)
        if getbaseinfo(play,3) == dtm then
            npc_628_back(play)
        end
        delmirrormap(dtm)
        return
    end

    if can_see then
        if x_count >= 1 then
            npc_628_kill_by_name(play, dtm, x_name)
            if main_count < 1 then
                npc_628_spawn_main(dtm)
            end
        end
    else
        if main_count >= 1 then
            npc_628_kill_by_name(play, dtm, main_name)
            if x_count < 1 then
                npc_628_spawn_x(dtm)
            end
        end
    end
end

function npc_628_timeout(play)
    local dtm = getbaseinfo(play,1).."_npc628"
    if getbaseinfo(play,3) == dtm then
        if getmoncount(dtm,-1,true) < 1 then
            npc_628_finish(play)
        else
            Player.sendmsgEx(play, "副本时间结束#57")
        end
        npc_628_back(play)
        if checkmirrormap(dtm) then
            setenvirofftimer(dtm, 1)
            delmirrormap(dtm)
        end
    end
end

function npc_628_finish(play)
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    if jq_data[_main_key] and jq_data[_main_key] >= 2 then
        return
    end
    jq_data[_main_key] = 2
    if (jq_data[_main_key] or 0) >= 2 then
        Guard.clearTaskTemp(jq_data, _main_key)
        jq_data[_main_key] = 2
    end
    Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
    _remove_finish_item(play, _prep_item_name())
    Player.sendmsgEx(play, "|"..(_config.name or "任务").."#249|完成#57")
    if npcid then Guard.closeNpc(play, npcid) end
    sendluamsg(play,101,1005,0,0,"rwwc")
    if _config.jl then
        Player.rwjl(play, _config.jl, (_config.name or "剧情任务").."奖励", 1)
    end
end

return npc



