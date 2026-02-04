-- npc = {}


-- --npc名称：杀怪1
-- --npc功能：5只怪
-- local _config = {
--     id = 4,
--     shaguai_id = 2,
--     name = "杀怪2",
--     num = 5
-- }


-- function npc.main(play,npcid)
--     local data = {}
--     data["sg_data"] = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
--     data["jq_data"] = Player.getJsonTableByVar(play, VarCfg.T_dljq)
--     sendluamsg(play,100,npcid,0,0,tbl2json(data))
-- end

-- function npc.link(play, npcid, p2, p3, msgData)
--     -- npc_guard: 入参校验
--     if not Guard.ensurePlayer(play, npcid) then
--         return
--     end
--     local __guardAction = Guard.normalizeAction(play, npcid, p2)
--     if __guardAction == nil then
--         return
--     end
--     p2 = __guardAction
--     -- npc_guard: 操作白名单（优化：限定合法操作编号）
--     local __guardAllowedActions = Guard.newActionSet({1, 2})
--     if not Guard.ensureActionAllowed(play, npcid, p2, __guardAllowedActions) then
--         return
--     end

--     local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
--     local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
--     if jq_data["npc4"] and jq_data["npc4"] >= 2 then
--         Player.sendmsgEx(play,  "你已经完成了该任务#57")
--         return
--     end
--     if p2 == 1 then
--         if jq_data["npc4"] and jq_data["npc4"] == 1 then --已领取
--             Player.sendmsgEx(play,  "你已经领取了该任务#57")
--             return
--         else
--             jq_data["npc4"] = 1
--             Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
--             Player.sendmsgEx(play,  "领取任务")
--             shaguai.jia(play,_config.shaguai_id)
--             sendluamsg(play,101,1005,0,0,"rwjs")
--         end
--     elseif p2 == 2 then
--         if jq_data["npc4"] and jq_data["npc4"] == 1 then --已领取
--             if sg_data["npc4"] and sg_data["npc4"] >= _config.num then
--                 jq_data["npc4"] = 2
--                 Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
--                 Player.sendmsgEx(play,  "任务完成")
--                 sendluamsg(play,101,1005,0,0,"rwwc")
--             else
--                 Player.sendmsgEx(play,  "你还没有完成任务#57")
--                 return
--             end
--         else
--             Player.sendmsgEx(play,  "你还没有领取任务#57")
--             return
--         end

--     end
-- end


-- return npc