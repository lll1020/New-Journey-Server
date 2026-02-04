-- npc = {}


-- --灵根使者

-- local _config = Guard.getConfig("npc_602")

-- function npc.main(play,npcid)
    if not _config then
        return
    end
--     local data = {}
--     data["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_灵根"])
--     data["T_dljq"] = Player.getJsonTableByVar(play, VarCfg.T_dljq)
--     sendluamsg(play,100,npcid,0,0,tbl2json(data))
-- end

-- function npc.link(play,npcid,ew,aid)
    if not _config then
        return
    end
--     -- npc_guard: 入参校验
--     if not Guard.ensurePlayer(play, npcid) then
--         return
--     end
--     local __guardAction = Guard.normalizeAction(play, npcid, ew)
--     if __guardAction == nil then
--         return
--     end
--     ew = __guardAction
--     -- npc_guard: 操作白名单（优化：限定合法操作编号）
--     local __guardAllowedActions = Guard.newActionSet({1, 2})
--     if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
--         return
--     end

--     if ew == 1 then--进入副本
--         local T_data = Player.getJsonTableByVar(play, VarCfg["T_灵根"])
--         local T_dljq = Player.getJsonTableByVar(play, VarCfg.T_dljq)
--         T_data.level = T_data.level or {}
--         if T_data.level[""..aid] then
--             Player.sendmsgEx(play, "你已经激活了该灵根#57")
--             return
--         end
--         T_dljq["npc_602"] = T_dljq["npc_602"] or {}
--         if T_dljq["npc_602"][""..aid] and T_dljq["npc_602"][""..aid] == 1 then
--             npc.link(play,npcid,2,aid)
--             return
--         end
--         if aid == 1 then --金 --无，跟引导开
--             if getplaydef(play,VarCfg.U_zxrw[1]) >= 20 then
--             else
--                 Player.sendmsgEx(play, "激活条件未达成，无法进入灵根试炼副本#57")
--                 return
--             end
--         elseif aid == 2 then --木 --江湖称号达到：崭露头角
--             if getplaydef(play, VarCfg["U_江湖称号"]) >= 2 then
--             else
--                 Player.sendmsgEx(play, "激活条件未达成，无法进入灵根试炼副本#57")
--                 return
--             end
--         elseif aid == 3 then --水 --江湖称号达到：名动一方
--             if getplaydef(play, VarCfg["U_江湖称号"]) >= 3 then
--             else
--                 Player.sendmsgEx(play, "激活条件未达成，无法进入灵根试炼副本#57")
--                 return
--             end
--         elseif aid == 4 then --火 --江湖称号达到：闯荡四海
--             if getplaydef(play, VarCfg["U_江湖称号"]) >= 4 then
--             else
--                 Player.sendmsgEx(play, "激活条件未达成，无法进入灵根试炼副本#57")
--                 return
--             end
--         elseif aid == 5 then --土 --天书拥有1个红色仙法
--             local T_ts_data = Player.getJsonTableByVar(play, VarCfg["T_天书"])
--             T_ts_data["caowei"] = T_ts_data["caowei"] or {}
--             local count = 0
--             for index, value in ipairs(T_ts_data["caowei"]) do
--                 if value[1] >= 5 then
--                     count = count + 1
--                 end
--             end
--             if count >= 1 then
--             else
--                 Player.sendmsgEx(play, "激活条件未达成，无法进入灵根试炼副本#57")
--                 return
--             end

--         end
--         T_dljq["npc_602"][""..aid] = 0
--         Player.setJsonVarByTable(play, VarCfg.T_dljq, T_dljq)
--         sendluamsg(play,100,npcid,1,aid,"")
--         Player.sendmsgEx(play, "你已进入灵根试炼副本，请完成相应的任务#57")
--         syt_jrdt_602(play,aid)
--     elseif ew == 2 then -- 激活灵根
--         local T_data = Player.getJsonTableByVar(play, VarCfg["T_灵根"])
--         local T_dljq = Player.getJsonTableByVar(play, VarCfg.T_dljq)
--         T_data.level = T_data.level or {}
--         if T_data.level[""..aid] then
--             Player.sendmsgEx(play, "你已经激活了该灵根#57")
--             return
--         end
--         T_dljq["npc_602"] = T_dljq["npc_602"] or {}
--         if T_dljq["npc_602"][""..aid] and T_dljq["npc_602"][""..aid] == 1 then
--             T_data.level[""..aid] = 0
--             T_dljq["npc_602"][""..aid] = 2
--             Player.setJsonVarByTable(play, VarCfg.T_dljq, T_dljq)
--             Player.setJsonVarByTable(play, VarCfg["T_灵根"], T_data)
--             Player.sendmsgEx(play, "恭喜你，成功激活了#249|灵根")
--             sendluamsg(play,100,npcid,2,aid,"")
--             sendluamsg(play,101,1005,0,0,"rwwc")
--         else
--             Player.sendmsgEx(play, "激活条件未达成，无法激活灵根#57")
--         end
--     end
-- end
-- function syt_jrdt_602(play,idx)
--     --创建镜像地图
--     local dtm = getbaseinfo(play,1).."_lgsz"
--     if checkmirrormap(dtm) then
--         delmirrormap(dtm)
--     end
--     addmirrormap("D3804_2",dtm,"灵根副本",300,"xtc")
--     --设置玩家进入镜像地图
--     mapmove(play,dtm,29,27,2)
--     local gw = genmonex(dtm,29,31,_config.details[idx].mob_name,2,1,0,54,"",0)

--     startautoattack(play)
--     delaygoto(play,100,"@npc_602_fbjs")
--     shaguai.jia(play,30)
-- end

-- --------------------天梯副本脚本-------------------
-- function npc_602_fbjs(play)
--     senddelaymsg(play,"距离副本通关剩余%s",180,250,1,"@npc_602_fb_end")
-- end

-- --------------------天梯副本脚本-------------------
-- function npc_602_fb_end(play)
--     local dtm = getbaseinfo(play,1).."_lgsz"
--     if getbaseinfo(play,3) == dtm then
--         if getmoncount(dtm,-1,true) < 1 then --副本怪物已经清空
--             delmirrormap(dtm)
--         else --副本怪物未清空
--             sendmsg(play,1,'{"Msg":"<font color=\'#00ff00\'>未通过本层,请继续修行吧...</font>","Type":9}')
--             delmirrormap(dtm)
--         end
--     end
-- end

-- return npc
