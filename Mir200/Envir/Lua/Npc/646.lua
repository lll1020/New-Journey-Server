npc = {}


--你竟是女王？

local _config = Guard.getConfig("npc_646")




function npc.main(play,npcid)
    if not _config then
        return
    end
    local data = {}
    data["T_dljq"] = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    sendluamsg(play,100,npcid,0,0,tbl2json(data))
end

function npc.link(play,npcid,ew,aid)
    if not _config then
        return
    end
    -- npc_guard: 入参校验
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local __guardAction = Guard.normalizeAction(play, npcid, ew)
    if __guardAction == nil then
        return
    end
    ew = __guardAction
    -- npc_guard: 操作白名单（优化：限定合法操作编号）
    local __guardAllowedActions = Guard.newActionSet({1})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end

    if ew == 1 then
        local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
        local key = "npc_646"
        if jq_data[key] and jq_data[key] >= 2 then
            Player.sendmsgEx(play, "你已经完成#57|【"..(_config.name or "该任务").."】#249|")
            return
        end

        local fg_cfg = Guard.getConfig("npc_13")
        local max_lv = fg_cfg and fg_cfg.max_level or 0
        local cur_lv = getplaydef(play, VarCfg["U_兰姐好感度"])
        if cur_lv < max_lv then
            Player.sendmsgEx(play, "小兰好感度未满级#57")
            return
        end
        local where = Player.hasEquipInArtifactSlot(play, "金箍棒")
        if not where then
            Player.sendmsgEx(play, "你需要装备金箍棒才能完成任务#57")
            return
        end
        if not Guard.ensureCost(play, _config.cost) then
            return
        end
        Guard.consumeCost(play, _config.cost, ","..(_config.name or "剧情任务"))

        jq_data[key] = 2
        if (jq_data[key] or 0) >= 2 then
            Guard.clearTaskTemp(jq_data, key)
            jq_data[key] = 2
        end
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        Player.sendmsgEx(play, "|【"..(_config.name or "任务").."】#249|完成")
        if npcid then Guard.closeNpc(play, npcid) end
        sendluamsg(play,101,1005,0,0,"rwwc")
        Player.rwjl(play, _config.rwjl or {{"绑定元宝",1},{"绑定金币",1}}, (_config.name or "剧情任务").."奖励", 1)
        local itemobj = linkbodyitem(play,where)
        local item_json = getitemcustomabil(play, itemobj)
        release_print(item_json)
        local ok, parsed = pcall(json2tbl, item_json)

        item_json = ok and parsed or nil
        if not item_json or not item_json.abil then
            item_json = json2tbl('{"abil":[{"i":0,"t":"[九九八十难]","c":251,"v":[]}],"name":""}')
        end
        item_json.abil[1].v[3] = {1,244,8000,0,15,3,3}
        item_json = tbl2json(item_json)
        setitemcustomabil(play, itemobj, item_json)
        sendluamsg(play,100,npcid,1,2,"")
    end
end

return npc




