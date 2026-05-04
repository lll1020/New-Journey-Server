npc = {}

local _config = Guard.getConfig("npc_627")
local _prep_key = "npc_627_rw"
local _main_key = "npc_627"

local function _get_task_data(play)
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
    return jq_data, sg_data
end

local function _prep_need_num()
    local prep = _config and _config.prep_task or {}
    return tonumber(prep.need or 0) or 0
end

local function _prep_material_name()
    local prep = _config and _config.prep_task or {}
    return prep.item_name or "定身符碎片"
end

local function _prep_item_name()
    local prep = _config and _config.prep_task or {}
    return prep.name or "定身符"
end

local function _prep_piece_count(play)
    return getbagitemcount(play, _prep_material_name())
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

local function _count_main_mob(dtm)
    local name = _config.mob or "怪物"
    local list = getobjectinmap(dtm, 0, 0, 999, 2)
    local cnt = 0
    if list then
        for _, v in ipairs(list) do
            if getbaseinfo(v, 1) == name then
                cnt = cnt + 1
            end
        end
    end
    return cnt
end

local function _kill_main_mob(play, dtm)
    local name = _config.mob or "怪物"
    local list = getobjectinmap(dtm, 0, 0, 999, 2)
    if list then
        for _, v in ipairs(list) do
            if getbaseinfo(v, 1) == name then
                humanhp(v, "-", 999999999, 107, 0, play)
            end
        end
    end
end

local function _spawn_main_mob(dtm)
    local mob_name = _config.mob or "怪物"
    local pos = {
        {32, 36}, {28, 33}, {36, 33}, {29, 40}, {35, 40}, {25, 36}, {39, 36}, {32, 30}
    }
    local pick = pos[math.random(1, #pos)]
    genmonex(dtm, pick[1], pick[2], mob_name, 1, 1, 0, 54, "", 0)
end

local function _try_escape_main_mob(play, dtm)
    if hasbuff(play, 20111) then
        return
    end
    if _count_main_mob(dtm) < 1 then
        return
    end
    local nextTime = tonumber(getplaydef(play, "N$npc627_escape_time") or 0) or 0
    if os.time() < nextTime then
        return
    end
    -- 息灾的原机制是被攻击时迅速逃离；未使用定身符时，这里定时闪走并重新出现。
    setplaydef(play, "N$npc627_escape_time", os.time() + 2)
    _kill_main_mob(play, dtm)
    _spawn_main_mob(dtm)
    Player.sendmsgEx(play, "#57|息灾迅速逃离了你的攻击，使用【定身符】后才能将其困在原地#249|")
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
        npc_627_enter(play)
        return
    end

    if ew == 2 then
        local state = tonumber(jq_data[_prep_key] or 0) or 0
        local material_name = _prep_material_name()
        local item_name = _prep_item_name()
        local need_num = _prep_need_num()
        if state >= 2 then
            Player.sendmsgEx(play, "你已经完成了#57|"..item_name.."#249|#57")
            return
        end
        if state == 0 then
            jq_data[_prep_key] = 1
            Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
            shaguai.jia(play, 627)
            Player.sendmsgEx(play, "领取任务：#57|"..item_name.."#249|在#57|"..((_config.prep_task and _config.prep_task.map) or "叹息旷野").."#249|收集#57|"..material_name.."#249|*"..need_num)
            if npcid then Guard.closeNpcAndAuto(play, npcid) end
            sendluamsg(play,100,npcid,1,1,"")
            return
        end
        if _prep_piece_count(play) < need_num then
            Player.sendmsgEx(play, "当前已收集#57|"..material_name.."#249|#57|".._prep_piece_count(play).."/"..need_num.."#249|")
            return
        end
        takeitem(play, material_name, need_num)
        jq_data[_prep_key] = 2
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        shaguai.jian(play, 627)
        giveitem(play, item_name, 1)
        Player.sendmsgEx(play, "合成成功，获得物品#57|"..item_name.."#249|#57")
        sendluamsg(play,100,npcid,1,2,"")
    end
end

function npc_627_savepos(play)
    local map = getbaseinfo(play,3)
    local x = getbaseinfo(play,4)
    local y = getbaseinfo(play,5)
    setplaydef(play, "S$npc627_back", map..","..x..","..y)
end

function npc_627_back(play)
    local back = getplaydef(play, "S$npc627_back")
    if back and back ~= "" then
        local parts = split(back, ",")
        local map = parts[1]
        local x = tonumber(parts[2]) or 0
        local y = tonumber(parts[3]) or 0
        if map and map ~= "" and x > 0 and y > 0 then
            mapmove(play, map, x, y, 2)
        end
    end
    setplaydef(play, "S$npc627_back", "")
end

function npc_627_enter(play)
    npc_627_savepos(play)
    local dtm = getbaseinfo(play,1).."_npc627"
    if checkmirrormap(dtm) then
        delmirrormap(dtm)
    end
    local base_map = _config.fb_map or "mwsl"
    addmirrormap(base_map, dtm, _config.name or "副本", 300, "xtc")
    mapmove(play, dtm, 29, 27, 2)

    local mob_name = _config.mob or "怪物"
    genmonex(dtm, 32, 36, mob_name, 1, 1, 0, 54, "", 0)
    setplaydef(play, "N$npc627_escape_time", 0)

    startautoattack(play)
    setenvirontimer(dtm, 1, 1, "@npc_627_dsq,"..play..","..dtm)
    senddelaymsg(play, "距离副本结束剩余%s", 300, 250, 1, "@npc_627_timeout")
end

function npc_627_dsq(xt,play,dtm,data)
    if getplaycount(dtm,false,true) == "0" then
        setenvirofftimer(dtm, 1)
        delmirrormap(dtm)
        return
    end

    if getbaseinfo(play,3) == dtm then
        _try_escape_main_mob(play, dtm)
    end

    if getmoncount(dtm,-1,true) < 1 then
        setenvirofftimer(dtm, 1)
        npc_627_finish(play)
        if getbaseinfo(play,3) == dtm then
            npc_627_back(play)
        end
        delmirrormap(dtm)
    end
end

function npc_627_timeout(play)
    local dtm = getbaseinfo(play,1).."_npc627"
    if getbaseinfo(play,3) == dtm then
        if getmoncount(dtm,-1,true) < 1 then
            npc_627_finish(play)
        else
            Player.sendmsgEx(play, "副本时间结束#57")
        end
        npc_627_back(play)
        if checkmirrormap(dtm) then
            setenvirofftimer(dtm, 1)
            delmirrormap(dtm)
        end
    end
end

function npc_627_finish(play)
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
    if hasbuff(play, 20111) then
        delbuff(play, 20111)
    end
    setplaydef(play, "N$npc627_escape_time", 0)
    Player.sendmsgEx(play, "|"..(_config.name or "任务").."#249|完成#57")
    if npcid then Guard.closeNpc(play, npcid) end
    sendluamsg(play,101,1005,0,0,"rwwc")
    if _config.jl then
        Player.rwjl(play, _config.jl, (_config.name or "剧情任务").."奖励", 1)
    end
end

return npc

