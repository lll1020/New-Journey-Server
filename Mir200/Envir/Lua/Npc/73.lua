npc = {}


--npc名称：
--npc功能：
local _config = Guard.getConfig("npc_73")

function npc.main(play,npcid)
    sendluamsg(play,100,npcid,0,0,tbl2json({num = getplaydef(play, VarCfg["U_深渊次数"])}))
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

        local name, num = Player.checkItemNumByTable(play, _config.cost)
        if name then
            Player.sendmsgEx(play, string.format("你的#57|【%s】#249|不足#57", name))
            return
        end
        Player.takeItemByTable(play, _config.cost, ",深渊",nil)

        local curCnt = getplaydef(play, VarCfg["U_深渊次数"]) or 0
        local newCnt = curCnt + 1
        setplaydef(play, VarCfg["U_深渊次数"], newCnt)

        -- 仅在 5 的倍数次进入第二套怪物，否则进入第一套
        fbtz_73(play, newCnt % 5 == 0 and 2 or 1)
        
        
    elseif p2 == 2 then
    end
end

function fbtz_73(play,idx)
    --创建镜像地图
    local dtm = getbaseinfo(play,1).."_fbtz"
    if checkmirrormap(dtm) then
        delmirrormap(dtm)
    end
    addmirrormap("D3804_2",dtm,"深渊",300,"xtc")
    --设置玩家进入镜像地图
    mapmove(play,dtm,29,27,2)
    local gw = genmonex(dtm,29,31,_config.mob[idx][1],10,_config.mob[idx][2],0,54,"",0)

    startautoattack(play)
    delaygoto(play,100,"@npc_73_fbjs")
    shaguai.jia(play,30)
end

--------------------天梯副本脚本-------------------
function npc_73_fbjs(play)
    senddelaymsg(play,"距离副本通关剩余%s",180,250,1,"@npc_73_fb_end")
end

--------------------天梯副本脚本-------------------
function npc_73_fb_end(play)
    local dtm = getbaseinfo(play,1).."_fbtz"
    if getbaseinfo(play,3) == dtm then
        if getmoncount(dtm,-1,true) < 1 then --副本怪物已经清空
            delmirrormap(dtm)
        else --副本怪物未清空
            delmirrormap(dtm)
        end
    end
end


return npc

