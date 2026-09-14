npc = {}


--谁是内鬼

local _config = Guard.getConfig("npc_631")

local _NPC631_ATTR_LIST = "npc631_search_reward"
local _NPC631_CUT_ATTR = 244
local _NPC631_CUT_PER_SEARCH = 666

local function _refresh_npc631_reward(play, search_count)
    search_count = math.max(0, math.min(4, tonumber(search_count or 0) or 0))
    Player.del_attlist(play, _NPC631_ATTR_LIST)
    if search_count > 0 then
        Player.add_attlist(
            play,
            _NPC631_ATTR_LIST,
            "=",
            "3#" .. _NPC631_CUT_ATTR .. "#" .. (search_count * _NPC631_CUT_PER_SEARCH),
            1
        )
    end
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
        local key = "npc_631"
        if jq_data[key] and jq_data[key] >= 2 then
            Player.sendmsgEx(play, "你已经完成#57|【"..(_config.name or "该任务").."】#218|")
            return
        end

        

        if not jq_data[key] or jq_data[key] == 0 then
            jq_data[key] = 1
            Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
            Player.sendmsgEx(play, "领取|【"..(_config.name or "任务").."】#218|")
            if npcid then Guard.closeNpcAndAuto(play, npcid) end
            shaguai.jia(play, _config.shaguai_id or 631)
            sendluamsg(play,101,1005,0,0,"rwjs")
            npc.main(play,npcid)
            return
        end

        local idx = tonumber(aid)
        if not idx or idx < 1 or idx > 4 then
            Player.sendmsgEx(play, "参数异常#57")
            return
        end

        local markKey = key.."_s"
        jq_data[markKey] = jq_data[markKey] or {}
        for i = 1, #jq_data[markKey] do
            if jq_data[markKey][i] == idx then
                Player.sendmsgEx(play, "这个水手已经确认身份了#57")
                return
            end
        end

        local need = (_config.jl_num or 0) * (#jq_data[markKey] + 1)
        local cur = sg_data[key] or 0
        if cur < need then
            Player.sendmsgEx(play, string.format("击杀不足：#57|【%d/%d】#218|", cur, need))
            return
        end

        table.insert(jq_data[markKey], idx)
        local reward_key = "npc631_cut_count"
        local old_reward_count = tonumber(jq_data[reward_key] or 0) or 0
        local search_count = math.min(#jq_data[markKey], 4)
        local new_reward_count = math.max(old_reward_count, search_count)
        jq_data[reward_key] = new_reward_count

        if #jq_data[markKey] >= 4 then
            jq_data[key] = 2
            if (jq_data[key] or 0) >= 2 then
                Guard.clearTaskTemp(jq_data, key)
                jq_data[key] = 2
            end
            Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
            _refresh_npc631_reward(play, new_reward_count)
            Player.sendmsgEx(play, "|【"..(_config.name or "任务").."】#218|完成，内鬼已经找到了#57")
            if npcid then Guard.closeNpc(play, npcid) end
            if _config.ch then
                Player.title_give(play, _config.ch)
            end
            sendluamsg(play,101,1005,0,0,"rwwc")
            shaguai.jian(play, _config.shaguai_id or 631)
            local data = {}
            data["T_dljq"] = Player.getJsonTableByVar(play, VarCfg.T_dljq)
            data["sg_data"] = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
            sendluamsg(play,100,npcid,0,0,tbl2json(data))
        else
            jq_data[key] = 1
            Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
            _refresh_npc631_reward(play, new_reward_count)
            Player.sendmsgEx(play, string.format("确认身份成功：|【%d/4】#218|", #jq_data[markKey]))
            local data = {}
            data["T_dljq"] = Player.getJsonTableByVar(play, VarCfg.T_dljq)
            data["sg_data"] = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
            sendluamsg(play,100,npcid,0,0,tbl2json(data))
        end
    end
end

local function Login_npc631(play)
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq) or {}
    local reward_key = "npc631_cut_count"
    local search_count = math.min(tonumber(jq_data[reward_key] or 0) or 0, 4)
    if search_count <= 0 and tonumber(jq_data["npc_631"] or 0) >= 2 then
        -- 老号完成任务后旧逻辑会清理搜查明细，按已完成任务迁移为4次奖励。
        search_count = 4
        jq_data[reward_key] = search_count
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
    end
    _refresh_npc631_reward(play, search_count)
end

GameEvent.add(EventCfg.onLogin, Login_npc631, "Login_npc631")
GameEvent.add(EventCfg.onKFLogin, Login_npc631, "Login_npc631_kf")

return npc




