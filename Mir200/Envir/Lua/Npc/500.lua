npc = {}


--地图跳转npc

local _config = Guard.getConfig("sjdt")

function npc.main(play,npcid)
    sendluamsg(play,100,npcid,0,0,"")
end

function npc.link(play,npcid,ew,aid)
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
        if _config[npcid] and Player.dl_sz(play, _config[npcid][6]) then
            if getplaydef(play,"N$战斗状态") < os.time() then
                mapmove(play,_config[npcid][1],_config[npcid][2],_config[npcid][3],_config[npcid][7])
                if rwcf[npcid] then
                    Player.zxrw_wancheng(play, rwcf[npcid][1], "任务") --完成任务
                end
                sendluamsg(play,101,9999,0,0,"npc_sjdt")


            else
                Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0000\'>战斗状态无法使用...</font>","Type":9}')
            end
        end

    end
end

return npc