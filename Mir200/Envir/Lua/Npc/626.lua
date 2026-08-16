npc = {}

local _config = Guard.getConfig("npc_626")
local _prep_key = "npc_626_rw"
local _main_key = "npc_626"

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
    return prep.item_name or "净化之泪"
end

local function _prep_item_name()
    local prep = _config and _config.prep_task or {}
    return prep.name or "净化宝石"
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

local function _auto_use_prep_item(play)
    if hasbuff(play, 20112) then
        return true
    end
    local item_name = _prep_item_name()
    if getbagitemcount(play, item_name) < 1 then
        return false
    end
    addbuff(play, 20112)
    Player.sendmsgEx(play, "检测到背包中拥有#57|【"..item_name.."】#249|，已自动获得净化效果#57")
    return true
end

local function _try_send_gray_entry_guide(play)    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
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
        npc_626_enter(play)
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
            shaguai.jia(play, 626)
            Player.sendmsgEx(play, "领取任务：#57|"..item_name.."#249|在#57|"..((_config.prep_task and (_config.prep_task.show_map or _config.prep_task.map)) or "海峰孤岛").."#249|收集#57|"..material_name.."#249|*"..need_num)
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
        shaguai.jian(play, 626)
        giveitem(play, item_name, 1)
        Player.sendmsgEx(play, "锻造成功，获得物品#57|"..item_name.."#249|#57")
        sendluamsg(play,100,npcid,1,2,"")
    end
end

function npc_626_savepos(play)
    local map = getbaseinfo(play,3)
    local x = getbaseinfo(play,4)
    local y = getbaseinfo(play,5)
    setplaydef(play, "S$npc626_back", map..","..x..","..y)
end

function npc_626_back(play)
    local back = getplaydef(play, "S$npc626_back")
    if back and back ~= "" then
        local parts = split(back, ",")
        local map = parts[1]
        local x = tonumber(parts[2]) or 0
        local y = tonumber(parts[3]) or 0
        if map and map ~= "" and x > 0 and y > 0 then
            mapmove(play, map, x, y, 2)
        end
    end
    setplaydef(play, "S$npc626_back", "")
end

function npc_626_delay_back(play)
    local dtm = getbaseinfo(play,1).."_npc626"
    if getbaseinfo(play,3) == dtm then
        npc_626_back(play)
    end
    if checkmirrormap(dtm) then
        setenvirofftimer(dtm, 1)
        delmirrormap(dtm)
    end
end

function npc_626_enter(play)
    npc_626_savepos(play)
    local dtm = getbaseinfo(play,1).."_npc626"
    if checkmirrormap(dtm) then
        delmirrormap(dtm)
    end
    local base_map = _config.fb_map or "mwsl"
    addmirrormap(base_map, dtm, "禁忌之海", 300,"xtc",136,136)
    mapmove(play, dtm, 29, 27, 2)
    _auto_use_prep_item(play)

    local mob_name = _config.mob or "怪物"
    genmonex(dtm, 32, 36, mob_name, 1, 1, 0, 54, "", 0)

    startautoattack(play)
    setenvirontimer(dtm, 1, 1, "@npc_626_dsq,"..play..","..dtm)
    senddelaymsg(play, "距离副本结束剩余%s", 300, 250, 1, "@npc_626_timeout")
end

function npc_626_dsq(xt,play,dtm,data)
    if getplaycount(dtm,false,true) == "0" then
        setenvirofftimer(dtm, 1)
        delmirrormap(dtm)
        return
    end

    if getbaseinfo(play,3) == dtm and not hasbuff(play, 20112) then
        local maxhp = getbaseinfo(play, 10)
        local hurt = math.floor(maxhp * 0.1)
        if hurt > 0 then
            humanhp(play, "-", hurt, 0, 0, play)
        end
    end

    if getmoncount(dtm,-1,true) < 1 then
        setenvirofftimer(dtm, 1)
        npc_626_finish(play)
        Player.sendmsgEx(play, "Boss已击败，5秒后离开副本#57")
        delaygoto(play, 5000, "@npc_626_delay_back")
    end
end

function npc_626_timeout(play)
    local dtm = getbaseinfo(play,1).."_npc626"
    if getbaseinfo(play,3) == dtm then
        if getmoncount(dtm,-1,true) < 1 then
            setenvirofftimer(dtm, 1)
            npc_626_finish(play)
            Player.sendmsgEx(play, "Boss已击败，5秒后离开副本#57")
            delaygoto(play, 5000, "@npc_626_delay_back")
            return
        else
            Player.sendmsgEx(play, "副本时间结束#57")
        end
        npc_626_back(play)
        if checkmirrormap(dtm) then
            setenvirofftimer(dtm, 1)
            delmirrormap(dtm)
        end
    end
end

function npc_626_finish(play)
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

    if hasbuff(play, 20112) then
        delbuff(play, 20112)
    end
    Player.sendmsgEx(play, "|"..(_config.name or "任务").."#249|完成#57")

    if npcid then Guard.closeNpc(play, npcid) end
    sendluamsg(play,101,1005,0,0,"rwwc")
    _try_send_gray_entry_guide(play)
    if _config.jl then
        Player.rwjl(play, _config.jl, (_config.name or "剧情任务").."奖励", 1)
    end
end

return npc


