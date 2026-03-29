-- npc = {}


-- --npc名称：灵根鉴定
-- --npc功能：鉴定灵根 最多可以鉴定5次每次坚定五个随机
-- local _config = Guard.getConfig("npc_1")


-- function npc.main(play,npcid)
--     local data = {}
--     data["cs"] = getplaydef(play, VarCfg["U_灵根鉴定次数"])
--     data["data"] = Player.getJsonTableByVar(play, VarCfg["T_灵根鉴定"])
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

--     if p2 == 1 then
--         local cs = getplaydef(play, VarCfg["U_灵根鉴定次数"])
--         local data = Player.getJsonTableByVar(play, VarCfg["T_灵根鉴定"])
--         if cs >= 5 then
--             Player.sendmsgEx(play, "提示:#251|你的鉴定次数已经用完了...")
--             return
--         end
--         local attrs = {}
--         local attrsstr = ""
--         for i=1,5 do
--             data[""..i] = math.random(_config.config[i].range[1],_config.config[i].range[2])
--             attrs[_config.config[i].attr] = data[""..i]
--         end
--         attrsstr = Player.getAttrTableToStr(attrs)
--         Player.addattlist(play, "灵根鉴定", "=", attrsstr, 1)

--         setplaydef(play, VarCfg["U_灵根鉴定次数"], cs + 1)
--         Player.setJsonVarByTable(play, VarCfg["T_灵根鉴定"], data)
--         sendluamsg(play,100,npcid,1,0,tbl2json(data))
--     elseif p2 == 2 then

--     end
-- end

-- return npc