npc = {}


--功能21：狂暴之力

local _config = Guard.getConfig("npc_15")

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
        if checktitle(play,_config.give.ch) then
            Player.sendmsgEx(play,1,'{"Msg":"<font color=\'#ff7700\'>[狂暴之力]</font><font color=\'#ff0000\'>您已经开启过狂暴之力了</font>","Type":9}')
        else
            if changemoney(play,7,"-",1000,"开启狂暴",true) then
                Player.title_give(play,_config.give.ch)
                seticon(play,0,1,10294,0,0,0,0,0)
                sendluamsg(play,100,npcid,1,0,"")
                local skillId = getskillindex(_config.give.skill)
                addskill(play, skillId, 1)
                Player.sendmsgEx(play,1,'{"Msg":"<font color=\'#ff7700\'>[狂暴之力]</font><font color=\'#00ff00\'>恭喜您成功开启狂暴之力</font>","Type":9}')
                Login_msg(play,3)
            else
                Player.sendmsgEx(play,1,'{"Msg":"<font color=\'#ff7700\'>[狂暴之力]</font><font color=\'#ff0000\'>您没有1000仙玉，无法开启</font>","Type":9}')
            end
        end
    end
end


local function _playerkillplay(play, actor)
    --判断是否攻沙时间，攻沙不掉狂暴
    local isGongSha = castleinfo(5)
    if isGongSha then
        return
    end
    if actor == "0" or play == "0" then
        return
    end
    if not getbaseinfo(actor, -1) then return end --如果是怪物不执行任何操作
    if not getbaseinfo(play, -1) then return end  --如果是怪物不执行任何操作

    --判断安全地图
    local dt = getbaseinfo(play,3)
    if dt == "比武大会" or dt == "武林盟主" or dt == "阵营对抗" then
        return
    end
    if checktitle(play,"狂暴之力") then
        --掉狂暴后在本服删除称号
        if checkkuafu(play) then
            FKuaFuToBenFuDelTitle(play, "狂暴之力", "")
        else
            deprivetitle(play, "狂暴之力")
        end
        changemoney(actor, 7, '+', 688, '击杀狂暴', true)

        --删技能
        local skillId = getskillindex(_config.give.skill)
        delskill(play, skillId)
        seticon(play, 0, -1)
        sendcentermsg(play, 250, 249, "战报：【" ..
                getbaseinfo(actor, 1) .. "】干掉了拥有【狂暴之力】的[" ..
                getbaseinfo(play, 1) .. "]获得奖励！！", 1, 5)
    end
end

GameEvent.add(EventCfg.onPlaydie, _playerkillplay, "狂暴之力")


return npc