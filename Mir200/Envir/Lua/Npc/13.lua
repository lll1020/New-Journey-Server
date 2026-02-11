npc = {}


--npc名称：
--npc功能：
local _config = Guard.getConfig("npc_13")

function npc.main(play,npcid)
    local data = {}
    data["dj_num"] = getplaydef(play, VarCfg["U_兰姐好感度"])
    sendluamsg(play,100,npcid,0,0,tbl2json(data))
end

function npc.link(play, npcid, p2, p3, msgData)

    -- npc_guard: 入参校验
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local __guardAction = Guard.normalizeAction(play, npcid, p2)
    if __guardAction == nil then
        return
    end
    p2 = __guardAction
    -- npc_guard: 操作白名单（优化：限定合法操作编号）
    local __guardAllowedActions = Guard.newActionSet({1, 2})
    if not Guard.ensureActionAllowed(play, npcid, p2, __guardAllowedActions) then
        return
    end

    if p2 == 1 then
        local dj_data = getplaydef(play, VarCfg["U_兰姐好感度"])
        if dj_data >= _config.max_level then
            Player.sendmsgEx(play,  "好感度等级已经达到了"..dj_data.."级，无需再提升#57")
            return
        end
        dj_data = dj_data + 1
        local config = _config.config[dj_data]

        local name, num = Player.checkItemNumByTable(play, config.cost)
        if name then
            Player.sendmsgEx(play, string.format("你的|%s#249|不足|%d#249", name, num))
            return
        end
        Player.takeItemByTable(play, config.cost, ",兰姐好感度",nil)
        if FProbabilityHit(config.gl) then
            Player.sendmsgEx(play,  "很遗憾，好感度提升失败，请继续努力#57")
            return
        end

        setplaydef(play, VarCfg["U_兰姐好感度"], dj_data)

        delattlist(play, "兰姐好感度")
        addattlist(play, "兰姐好感度", "=", "3#".._config.attrID.."#".._config.config[dj_data].ratio, 1)
        sendluamsg(play,100,npcid,1,0,"")
        Player.zxrw_wancheng(play, rwcf[npcid][1], "任务") --完成任务

        if dj_data == 5 then
            Player.rwjl(play,{{_config.half_give,1}},"兰姐好感度",1)
        end

        if dj_data == _config.max_level then
            Player.sendmsgEx(play, "恭喜你，你的好感度提升到了|"..dj_data.."级#249|，已满级")
        else
            Player.sendmsgEx(play, "恭喜你，你的好感度提升到了|"..dj_data.."级#249|")
        end
    elseif p2 == 2 then
    end
end


return npc