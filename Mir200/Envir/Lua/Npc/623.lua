npc = {}


--踏入·鬼嘲深渊

local _config = Guard.getConfig("npc_623")

local _target_npc = {map = "鬼嘲深渊", id = 625, x = 174, y = 460}

-- 任务完成后直接传到对应讨伐 NPC 附近，并给客户端发起引导点击。
local function _guide_to_target_npc(play)
    mapmove(play, _target_npc.map, _target_npc.x, _target_npc.y, 5)
    sendluamsg(play, 101, 0, 1, 1, '{"lx":2,"npcdt":"' .. _target_npc.map .. '","npcid":' .. _target_npc.id .. ',"xx":' .. _target_npc.x .. ',"yy":' .. _target_npc.y .. '}')
end




function npc.main(play,npcid)
    if not _config then
        return
    end
    local data = {}
    data["T_dljq"] = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    data["sg_data"] = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
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
        local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
        local key = "npc_623"
        if jq_data[key] and jq_data[key] >= 2 then
            _guide_to_target_npc(play)
            return
        end

        if not jq_data[key] or jq_data[key] == 0 then
            jq_data[key] = 1
            Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
            Player.sendmsgEx(play, "领取|【"..(_config.name or "任务").."】#249|")
            shaguai.jia(play, _config.shaguai_id or 623)
            sendluamsg(play,101,1005,0,0,"rwjs")
            sendluamsg(play,100,npcid,1,1,"")
            return
        end

        if jq_data[key] == 1 then
            if sg_data[key] and sg_data[key] >= (_config.num or 0) then
                jq_data[key] = 2
                if (jq_data[key] or 0) >= 2 then
                    Guard.clearTaskTemp(jq_data, key)
                    jq_data[key] = 2
                end
                Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
                Player.sendmsgEx(play, "|【"..(_config.name or "任务").."】#249|完成")
                sendluamsg(play,101,1005,0,0,"rwwc")
                Player.rwjl(play, _config.rwjl or {{"绑定元宝",1},{"绑定金币",1}}, (_config.name or "剧情任务").."奖励", 1)
                sendluamsg(play,100,npcid,1,2,"")
            else
                Player.sendmsgEx(play, "你还没有完成#57|【"..(_config.name or "该任务").."】#249|")
            end
        end
    end
end

return npc

