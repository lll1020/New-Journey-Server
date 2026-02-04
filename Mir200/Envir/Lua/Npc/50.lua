-- npc = {}


-- --

-- local _config = Guard.getConfig("npc_50")

-- function npc.main(play,npcid)
--     local data = {}
--     data["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_锁妖塔"])
--     sendluamsg(play,100,npcid,0,0,tbl2json(data))
-- end

-- function npc.link(play,npcid,ew,aid,data)
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
--     local __guardAllowedActions = Guard.newActionSet({1})
--     if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
--         return
--     end

--     if ew == 1 then --
--         local T_data = Player.getJsonTableByVar(play, VarCfg["T_锁妖塔"])
--         ttt_jrdt(play)
--     end

        

-- end


-- function ttt_jrdt(play)
--     --创建镜像地图
--     local dtm = getbaseinfo(play,1).."_ttt"
--     if checkmirrormap(dtm) then
--         delmirrormap(dtm)
--     end
--     local syt_cs = 1
--     addmirrormap("D3804_2",dtm,"通天塔第"..syt_cs.."层",300,"xtc")
--     --设置玩家进入镜像地图
--     mapmove(play,dtm,29,27,2)
--     local gw = genmonex(dtm,29,31,"金灵根守护兽",2,1,0,54,"",0)

--     startautoattack(play)
--     setenvirontimer(dtm,1,1,"@ttt_dsq,"..play..","..dtm..","..syt_cs)
--     delaygoto(play,100,"@ttt_djs")
-- end

-- function ttt_djs(play)
--     senddelaymsg(play,"距离副本通关剩余%s",180,250,1,"@ttt_end")
-- end


-- function ttt_dsq(xt,play,dtm,data)
--     if getplaycount(dtm,false,true) == "0" then
--         setenvirofftimer(dtm,1)
--         delmirrormap(dtm)
--     elseif getmoncount(dtm,-1,true) < 1 then
--         setenvirofftimer(dtm,1)
--         ttt_end(play)
--         senddelaymsg(play,"距离副本通关剩余%s",5,250,1)
--     end
-- end


-- function ttt_end(play)
--     local dtm = getbaseinfo(play,1).."_ttt"
--     if getbaseinfo(play,3) == dtm then
--         if getmoncount(dtm,-1,true) < 1 then --副本怪物已经清空
--             setenvirofftimer(dtm,1)
            
--         else --副本怪物未清空  一个npc 重新挑战
--             setenvirofftimer(dtm,1)
--             sendmsg(play,1,'{"Msg":"<font color=\'#00ff00\'>未通过...</font>","Type":9}')
--             delmirrormap(dtm)
--         end
--     end
-- end


-- return npc