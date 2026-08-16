npc = {}

local _config = Guard.getConfig("npc_625")
local _prep_key = "npc_625_rw"
local _main_key = "npc_625"

local function _get_task_data(play)
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
    return jq_data, sg_data
end

local function _prep_progress(sg_data)
    return tonumber(sg_data[_prep_key] or 0) or 0
end

local function _prep_item_name()
    return (_config and _config.prep_task and _config.prep_task.name) or "嘲天笑地"
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

local function _try_send_gray_entry_guide(play)
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    if tonumber(jq_data["npc_625"] or 0) >= 2
        and tonumber(jq_data["npc_626"] or 0) >= 2
        and tonumber(jq_data["npc_627"] or 0) >= 2
        and tonumber(jq_data["npc_628"] or 0) >= 2 then
        mapmove(play, "灰界", 205, 196, 2)
        sendluamsg(play, 101, 0, 1, 1, '{"lx":2,"npcdt":"灰界","npcid":46,"xx":205,"yy":196}')
    end
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
        npc_625_enter(play)
        return
    end

    if ew == 2 then
        local state = tonumber(jq_data[_prep_key] or 0) or 0
        local prep_item = _prep_item_name()
        if state >= 2 then
            Player.sendmsgEx(play, "你已经完成了#57|"..prep_item.."#249|#57")
            return
        end
        if state == 0 then
            jq_data[_prep_key] = 1
            Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
            shaguai.jia(play, 625)
            Player.sendmsgEx(play, "领取任务：#57|"..prep_item.."#249|在#57|"..((_config.prep_task and (_config.prep_task.show_map or _config.prep_task.map)) or "旷野之原").."#249|击杀50只怪物")
            if npcid then Guard.closeNpcAndAuto(play, npcid) end
            sendluamsg(play,100,npcid,1,1,"")
            return
        end
        if _prep_progress(sg_data) < 50 then
            Player.sendmsgEx(play, "当前进度：#57|".._prep_progress(sg_data).."/50#249|尚未完成#57")
            if npcid then Guard.closeNpcAndAuto(play, npcid) end
            return
        end
        jq_data[_prep_key] = 2
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        shaguai.jian(play, 625)
        giveitem(play, prep_item, 1)
        Player.sendmsgEx(play, "任务完成，获得物品#57|"..prep_item.."#249|#57")
        sendluamsg(play,100,npcid,1,2,"")
    end
end

function npc_625_savepos(play)
    local map = getbaseinfo(play,3)
    local x = getbaseinfo(play,4)
    local y = getbaseinfo(play,5)
    setplaydef(play, "S$npc625_back", map..","..x..","..y)
end

function npc_625_back(play)
    local back = getplaydef(play, "S$npc625_back")
    if back and back ~= "" then
        local parts = split(back, ",")
        local map = parts[1]
        local x = tonumber(parts[2]) or 0
        local y = tonumber(parts[3]) or 0
        if map and map ~= "" and x > 0 and y > 0 then
            mapmove(play, map, x, y, 2)
        end
    end
    setplaydef(play, "S$npc625_back", "")
end

function npc_625_delay_back(play)
    local dtm = getbaseinfo(play,1).."_npc625"
    if getbaseinfo(play,3) == dtm then
        npc_625_back(play)
    end
    if checkmirrormap(dtm) then
        setenvirofftimer(dtm, 1)
        delmirrormap(dtm)
    end
end

function npc_625_enter(play)
    npc_625_savepos(play)

    local dtm = getbaseinfo(play,1).."_npc625"
    if checkmirrormap(dtm) then
        delmirrormap(dtm)
    end
    local base_map = _config.fb_map or "mwsl"
    addmirrormap(base_map, dtm, "鬼嘲深渊", 300,"xtc",136,136)
    mapmove(play, dtm, 29, 27, 2)

    local mob_name = _config.mob or "怪物"
    genmonex(dtm, 32, 36, mob_name, 1, 1, 0, 54, "", 0)
    Buff[106](play,1)

    startautoattack(play)
    setenvirontimer(dtm, 1, 1, "@npc_625_dsq,"..play..","..dtm)
    senddelaymsg(play, "距离副本结束剩余%s", 300, 250, 1, "@npc_625_timeout")
end

function npc_625_dsq(xt,play,dtm,data)
    if getplaycount(dtm,false,true) == "0" then
        setenvirofftimer(dtm, 1)
        delmirrormap(dtm)
        return
    end
    if getmoncount(dtm,-1,true) < 1 then
        setenvirofftimer(dtm, 1)
        npc_625_finish(play)
        Player.sendmsgEx(play, "Boss已击败，5秒后离开副本#57")
        delaygoto(play, 5000, "@npc_625_delay_back")
    end
end

function npc_625_timeout(play)
    local dtm = getbaseinfo(play,1).."_npc625"
    if getbaseinfo(play,3) == dtm then
        if getmoncount(dtm,-1,true) < 1 then
            setenvirofftimer(dtm, 1)
            npc_625_finish(play)
            Player.sendmsgEx(play, "Boss已击败，5秒后离开副本#57")
            delaygoto(play, 5000, "@npc_625_delay_back")
            return
        else
            Player.sendmsgEx(play, "副本时间结束#57")
        end
        npc_625_back(play)
        if checkmirrormap(dtm) then
            setenvirofftimer(dtm, 1)
            delmirrormap(dtm)
        end
    end
end

function npc_625_finish(play)
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
    Player.sendmsgEx(play, "|"..(_config.name or "任务").."#249|完成#57")
    if npcid then Guard.closeNpc(play, npcid) end
    sendluamsg(play,101,1005,0,0,"rwwc")
    _try_send_gray_entry_guide(play)
    if _config.jl then
        Player.rwjl(play, _config.jl, (_config.name or "剧情任务").."奖励", 1)
    end
end

return npc





