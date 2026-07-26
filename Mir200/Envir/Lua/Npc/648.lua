npc = {}


--大闹狮驼岭

local _config = Guard.getConfig("npc_648")




function npc.main(play,npcid)
    if not _config then
        return
    end
    local data = {}
    data["sg_data"] = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
    data["jq_data"] = Player.getJsonTableByVar(play, VarCfg.T_dljq)
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
    local __guardAllowedActions = Guard.newActionSet({1, 2})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end

    local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local key = "npc_648"
    if jq_data[key] and jq_data[key] >= 2 then
        Player.sendmsgEx(play, "你已经完成#57|【"..(_config.name or "该任务").."】#218|")
        return
    end

    if ew == 1 then
        if jq_data[key] and jq_data[key] == 1 then
            Player.sendmsgEx(play, "你已经领取#57|【"..(_config.name or "该任务").."】#218|")
            return
        end
        jq_data[key] = 1
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        Player.sendmsgEx(play, "领取|【"..(_config.name or "任务").."】#218|")
        if npcid then Guard.closeNpcAndAuto(play, npcid) end
        shaguai.jia(play, _config.shaguai_id or 648)
        sendluamsg(play,101,1005,0,0,"rwjs")
        sendluamsg(play,100,npcid,1,1,"")
    elseif ew == 2 then
        if jq_data[key] and jq_data[key] == 1 then
            local a = sg_data[key.."_a"] or 0
            local b = sg_data[key.."_b"] or 0
            local c = sg_data[key.."_c"] or 0
            if a >= (_config.num_a or 0) and b >= (_config.num_b or 0) and c >= (_config.num_c or 0) then
                local where = Player.hasEquipInArtifactSlot(play, "金箍棒")
                if not where then
                    Player.sendmsgEx(play, "你需要装备金箍棒才能完成任务#57")
                    return
                end
                jq_data[key] = 2
                if (jq_data[key] or 0) >= 2 then
                    Guard.clearTaskTemp(jq_data, key)
                    jq_data[key] = 2
                end
                Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
                Player.sendmsgEx(play, "|【"..(_config.name or "任务").."】#218|完成")
                if npcid then Guard.closeNpc(play, npcid) end
                sendluamsg(play,101,1005,0,0,"rwwc")
                local rewards = type(_config.rwjl) == "table" and #_config.rwjl > 0 and _config.rwjl or nil
                if rewards then
                    Player.rwjl(play, rewards, (_config.name or "剧情任务").."奖励", 1)
                end
                local itemobj = linkbodyitem(play,where)
                local item_json = getitemcustomabil(play, itemobj)
                release_print(item_json)
                local ok, parsed = pcall(json2tbl, item_json)

                item_json = ok and parsed or nil
                if not item_json or not item_json.abil then
                    item_json = json2tbl('{"abil":[{"i":0,"t":"[九九八十难]","c":251,"v":[]}],"name":""}')
                end
                item_json.abil[1].v[5] = {1,73,100,1,17,5,5}
                item_json.abil[1].v[6] = {1,89,100,1,18,6,6}
                item_json.abil[1].v[7] = {1,206,100,1,19,7,7}
                item_json = tbl2json(item_json)
                setitemcustomabil(play, itemobj, item_json)
                sendluamsg(play,100,npcid,1,2,"")
            else
                Player.sendmsgEx(play, "你还没有完成#57|【"..(_config.name or "该任务").."】#218|")
                if npcid then Guard.closeNpcAndAuto(play, npcid) end
                return
            end
        else
            Player.sendmsgEx(play, "你还没有领取#57|【"..(_config.name or "任务").."】#218|")
            return
        end
    end
end

return npc




