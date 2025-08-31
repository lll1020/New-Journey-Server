npc = {}

npc[1] = function(play,p2,p3,msgData)  --兑换面板
    if p2 == 0 then
        sendluamsg(play,101,3,0,0,'{"hbdh1":'..getplaydef(play,VarCfg.J_hbdh[1])..',"hbdh2":'..getplaydef(play,VarCfg.J_hbdh[2])..'}')
    elseif p2 == 1 then
        if getplaydef(play,VarCfg.J_hbdh[1]) >= 10 then
            sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[货币兑换]</font><font color=\'#ff0000\'>每日兑换次数已达上限...</font>","Type":9}')
            return
        end
        if changemoney(play,3,"-",1000000,"货币兑换",true) then
            changemoney(play,4,"+",200000,"货币兑换",true)
            setplaydef(play,VarCfg.J_hbdh[1], getplaydef(play,VarCfg.J_hbdh[1]) + 1)
            sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[货币兑换]</font><font color=\'#00ff00\'>兑换成功...</font>","Type":9}')
            sendluamsg(play,101,3,1,1,'{"hbdh1":'..getplaydef(play,VarCfg.J_hbdh[1])..',"hbdh2":'..getplaydef(play,VarCfg.J_hbdh[2])..'}')

        else
            sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[货币兑换]</font><font color=\'#ff0000\'>元宝不足...</font>","Type":9}')
        end
    elseif p2 == 2 then
        if getplaydef(play,VarCfg.J_hbdh[2]) >= 10 then
            sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[货币兑换]</font><font color=\'#ff0000\'>每日兑换次数已达上限...</font>","Type":9}')
            return
        end
        if changemoney(play,1,"-",1000000,"货币兑换",true) then
            changemoney(play,2,"+",200000,"货币兑换",true)
            setplaydef(play,VarCfg.J_hbdh[2], getplaydef(play,VarCfg.J_hbdh[2]) + 1)
            sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[货币兑换]</font><font color=\'#00ff00\'>兑换成功...</font>","Type":9}')
            sendluamsg(play,101,3,1,2,'{"hbdh1":'..getplaydef(play,VarCfg.J_hbdh[1])..',"hbdh2":'..getplaydef(play,VarCfg.J_hbdh[2])..'}')

        else
            sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[货币兑换]</font><font color=\'#ff0000\'>绑定元宝不足...</font>","Type":9}')
        end
    elseif p2 == 3 then
        if changemoney(play,7,"-",1000,"货币兑换",true) then
            changemoney(play,1,"+",2000000,"货币兑换",true)
            sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[货币兑换]</font><font color=\'#00ff00\'>兑换成功...</font>","Type":9}')
        else
            sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[货币兑换]</font><font color=\'#ff0000\'>仙玉不足...</font>","Type":9}')
        end
    elseif p2 == 4 then
        if changemoney(play,8,"-",1000,"货币兑换",true) then
            changemoney(play,3,"+",2000000,"货币兑换",true)
            sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[货币兑换]</font><font color=\'#00ff00\'>兑换成功...</font>","Type":9}')
        else
            sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[货币兑换]</font><font color=\'#ff0000\'>绑定仙玉不足...</font>","Type":9}')
        end
    end
end

npc[2] = function(play,p2,p3,msgData)  --回收面板
    if p2 == 0 then
        sendluamsg(play, 101, 2, 2, 0, '{"xz":'..getplaydef(play,VarCfg.T_hsdg)..',"kg":['..getflagstatus(play,VarCfg.BS_huishou[1])..','..getflagstatus(play,VarCfg.BS_huishou[2])..','..getflagstatus(play,VarCfg.BS_huishou[3])..','..getflagstatus(play,VarCfg.BS_huishou[4])..','..getflagstatus(play,VarCfg.BS_huishou[5])..']}')
    elseif p2 == 1 then
        if p3 > 0 and p2 < 5 then
            msgData = tonumber(msgData)
            if msgData > 0 and msgData < 50 then
                local hspz = json2tbl(getplaydef(play,VarCfg.T_hsdg))
                hspz[p3.."_"..msgData] = 1
                setplaydef(play,VarCfg.T_hsdg,tbl2json(hspz))
            end
        end
    elseif p2 == 2 then
        local hspz = json2tbl(getplaydef(play,VarCfg.T_hsdg))
        if hspz[msgData] and hspz[msgData] == 1 then
            hspz[msgData] = nil
        else
            hspz[msgData] = 1
        end
        setplaydef(play,VarCfg.T_hsdg,tbl2json(hspz))
    elseif p2 == 3 then
    elseif p2 == 4 then
        if p3 == 1 then
            if msgData == "1" then
                sendmsg(play,1,'{"Msg":"<font color=\'#00ff00\'>自动吃灵符已开启...</font>","Type":9}')
            else
                sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>自动吃灵符已关闭...</font>","Type":9}')
            end
            setflagstatus(play,VarCfg.BS_huishou[1],msgData)
        elseif p3 == 2 then
            if msgData == "1" then
                sendmsg(play,1,'{"Msg":"<font color=\'#00ff00\'>自动吃元宝已开启...</font>","Type":9}')
            else
                sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>自动吃元宝已关闭...</font>","Type":9}')
            end
            setflagstatus(play,VarCfg.BS_huishou[2],msgData)
        elseif p3 == 3 then
            if msgData == "1" then
                sendmsg(play,1,'{"Msg":"<font color=\'#00ff00\'>自动吃经验已开启...</font>","Type":9}')
            else
                sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>自动吃经验已关闭...</font>","Type":9}')
            end
            setflagstatus(play,VarCfg.BS_huishou[3],msgData)
        elseif p3 == 4 then
            if msgData == "1" then
                sendmsg(play,1,'{"Msg":"<font color=\'#00ff00\'>自动回收已开启...</font>","Type":9}')
            else
                sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>自动回收已关闭...</font>","Type":9}')
            end
            setflagstatus(play,VarCfg.BS_huishou[4],msgData)
        elseif p3 == 5 then
            if msgData == "1" then
                sendmsg(play,1,'{"Msg":"<font color=\'#00ff00\'>可提升不回收已开启...</font>","Type":9}')
            else
                sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>可提升不回收已关闭...</font>","Type":9}')
            end
            setflagstatus(play,VarCfg.BS_huishou[5],msgData)
        end
    elseif p2 == 5 then
        if p3 == 1 then
            local hs = json2tbl(msgData)
            Player.huishou(play, hs)
        end
        Player.zxrw_wancheng(play, 4, "")
    elseif p2 == 6 then --销毁
        local hs = json2tbl(msgData)
        Player.huishou(play, hs)
        sendluamsg(play, 101, 2, 4, 0, '')
    elseif p2 == 7 then
        Player.huishou(play)
        refreshbag(play)
    end
end

npc[3] = function(play)  --仓库面板
    openstorage(play)
end


npc[5] = function(play,p2,p3,data) -- 内挂开关
    setflagstatus(play,VarCfg.BS_ngkg,p2)
    Buff[379](play,p2 == 1 and 1 or 2)
    sendluamsg(play, 103, 1, 0, 0, '{"ngkg":'..p2..'}')
end

npc[6] = function(play,p2,p3,data) -- 屏蔽系统消息
    if getplaydef(play,"N$是否屏蔽系统消息") == 0 then
        setplaydef(play,"N$是否屏蔽系统消息",1)
        filterglobalmsg(play,1)
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>不在接受系统提示消息...</font>","Type":9}')
    else
        setplaydef(play,"N$是否屏蔽系统消息",0)
        filterglobalmsg(play,0)
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>正常接收系统消息...</font>","Type":9}')
    end
end


---异闻录
local npc_xyl = {

}
npc[11] = function(play,p2,p3,data)  --异闻录
    if p2 == 0 then
        if not Player.dl_sz_notip(play, 2) then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>完成一大陆任务后开启。。。</font>","Type":9}')
            return false
        end
        sendluamsg(play, 101, 11, 0, 0,
                '{"dljq":'..getplaydef(play, VarCfg.T_dljq)
                        ..',"zxrw":'..getplaydef(play, VarCfg.T_zxrw)
                        ..',"ywl":'..getplaydef(play, VarCfg.T_ywl)
                        ..'}')
    elseif p2 == 1 then --传送
        local sj = json2tbl(data)
        if sj.i and sj.k and sj.j and sj.z and sj.i > 0 and sj.k > 0 and sj.j > 0 and sj.z > 0 and sj.i <= #npc_xyl and sj.j <= #npc_xyl[sj.i] and sj.k <= #npc_xyl[sj.i][sj.j] and sj.z <= #npc_xyl[sj.i][sj.j][sj.k] then
            if Player.dl_sz_notip(play, sj.i) then
                local shuju = npc_xyl[sj.i][sj.j][sj.k][sj.z]
                if shuju[2] == 999 and sj.i > 3 then
                    local T_ywl = json2tbl(getplaydef(play,VarCfg.T_ywl))
                    if not (T_ywl["rw_"..shuju[3][2]] and T_ywl["rw_"..shuju[3][2]] == 1) then
                        Player.zxrw_lingqu(play, shuju[3][2], "")
                    end
                end
                if shuju.yd[1] == 0 then
                    sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>无法传送...</font>","Type":9}')
                elseif shuju.yd[1] == 1 then
                    if getplaydef(play,"N$战斗状态") < os.time() then
                        mapmove(play,shuju.yd[2],shuju.yd[4],shuju.yd[5],2)
                        sendluamsg(play, 101, 0, 1, 1,'{"lx":2,"npcdt":"'..shuju.yd[2]..'","npcid":'..shuju.yd[3]..',"xx":'..shuju.yd[4]..',"yy":'..shuju.yd[5]..'}')
                        sendluamsg(play,101,9999,0,0,"npc_ywl")
                    else
                        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>战斗状态无法使用...</font>","Type":9}')
                    end
                elseif shuju.yd[1] == 2 then
                    sendluamsg(play, 101, 0, 1, 1,'{"lx":1,"fx":1,"an":'..shuju.yd[3]..',"ms":"点击按钮"}')
                    sendluamsg(play,101,9999,0,0,"npc_ywl")
                    sendluamsg(play,101,9999,0,0,"npc_ywl")
                elseif shuju.yd[1] == 3 then
                    sendluamsg(play, 101, 0, 1, 1,'{"lx":'..shuju.yd[2]..'}')
                    sendluamsg(play,101,9999,0,0,"npc_ywl")
                elseif shuju.yd[1] == 4 then
                    sendluamsg(play,shuju.yd[2],shuju.yd[3],shuju.yd[4],0,"")
                    sendluamsg(play,101,9999,0,0,"npc_ywl")
                end
            else
                sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>条件不足,无法传送...</font>","Type":9}')
            end
        end
    elseif p2 == 2 then --一页任务奖励
        local sj = json2tbl(data)
        if sj.i and sj.k and sj.j and sj.i > 0 and sj.k > 0 and sj.j > 0 and sj.i <= #npc_xyl and sj.j <= #npc_xyl[sj.i] and sj.k <= #npc_xyl[sj.i][sj.j] then
            local T_ywl = json2tbl(getplaydef(play,VarCfg.T_ywl))
            if T_ywl["jl_"..sj.i.."_".. sj.j .."_"..sj.k] and T_ywl["jl_"..sj.i.."_".. sj.j .."_"..sj.k] == 1 then
                sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>已领取过了...</font>","Type":9}')
                return
            end
            for i = 1, #npc_xyl[sj.i][sj.j][sj.k] do
                if T_ywl["jl_"..sj.i.."_".. sj.j .."_"..sj.k .."_" .. i] and T_ywl["jl_"..sj.i.."_".. sj.j .."_"..sj.k .."_" .. i] == 1 then
                    T_ywl["jl_"..sj.i.."_".. sj.j .."_"..sj.k .."_" .. i] = nil
                else
                    sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>未完成['..npc_xyl[sj.i][sj.j][sj.k][i][1]..']剧情...</font>","Type":9}')
                    return
                end
            end
            T_ywl["jl_"..sj.i.."_".. sj.j .."_"..sj.k] = 1
            setplaydef(play, VarCfg.T_ywl, tbl2json(T_ywl))
            Player.rwjl(play,npc_xyl[sj.i][sj.j][sj.k].jl,"剧情jl",nil)
            sendluamsg(play, 101, 11, 3, 0,
                    '{"dljq":'..getplaydef(play, VarCfg.T_dljq)
                            ..',"zxrw":'..getplaydef(play, VarCfg.T_zxrw)
                            ..',"ywl":'..getplaydef(play, VarCfg.T_ywl)
                            ..',"T_tj":'..getplaydef(play,VarCfg.T_tj)
                            ..'}')
            if (sj.i == 2 or sj.i == 3) and sj.k < 6 then
                for i = 1, #npc_xyl[sj.i][sj.j][sj.k + 1] do
                    if npc_xyl[sj.i][sj.j][sj.k + 1][i][2] == 999 and (npc_xyl[sj.i][sj.j][sj.k + 1][i][3][1] == 3 or npc_xyl[sj.i][sj.j][sj.k + 1][i][3][1] == 4) then
                        Player.zxrw_lingqu(play, npc_xyl[sj.i][sj.j][sj.k + 1][i][3][2], "")
                    end
                end
            elseif sj.i == 2 and sj.k == 6 then
                for i = 1, #npc_xyl[3][sj.j][1] do
                    if npc_xyl[3][sj.j][1][i][2] == 999 and (npc_xyl[3][sj.j][1][i][3][1] == 3 or npc_xyl[3][sj.j][1][i][3][1] == 4) then
                        Player.zxrw_lingqu(play, npc_xyl[3][sj.j][1][i][3][2], "")
                    end
                end
                sendluamsg(play, 101, 9999, 0, 0, "npc_ywl")
                mapmove(play, "剑门外门", 98, 84,1) --剑门外门
                sendluamsg(play, 101, 0, 1, 1,'{"lx":2,"npcdt":"'.."剑门外门"..'","npcid":'.. 132 ..',"xx":'.. 97 ..',"yy":'.. 85 ..'}')
            elseif sj.i == 3 and sj.k == 6 then
                sendluamsg(play, 101, 9999, 0, 0, "npc_ywl")
                mapmove(play, "剑门内门", 95, 129,1) --剑门内门
                sendluamsg(play, 101, 0, 1, 1,'{"lx":2,"npcdt":"'.."剑门内门"..'","npcid":'.. 37 ..',"xx":'.. 93 ..',"yy":'.. 131 ..'}')
            end
        end
    elseif p2 == 3 then --单个任务奖励
        local sj = json2tbl(data)
        if sj.i and sj.k and sj.j and sj.z and sj.i > 0 and sj.k > 0 and sj.j > 0 and sj.z > 0 and sj.i <= #npc_xyl and sj.j <= #npc_xyl[sj.i] and sj.k <= #npc_xyl[sj.i][sj.j] and sj.z <= #npc_xyl[sj.i][sj.j][sj.k] then
            local shuju = npc_xyl[sj.i][sj.j][sj.k][sj.z]
            local T_dljq = json2tbl(getplaydef(play,VarCfg.T_dljq))
            local T_ywl = json2tbl(getplaydef(play,VarCfg.T_ywl))
            if (T_ywl["jl_"..sj.i.."_".. sj.j .."_"..sj.k] and T_ywl["jl_"..sj.i.."_".. sj.j .."_"..sj.k] == 1) or (T_ywl["jl_"..sj.i.."_".. sj.j .."_"..sj.k .."_" .. sj.z] and T_ywl["jl_"..sj.i.."_".. sj.j .."_"..sj.k .."_" .. sj.z] == 1) then
                sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>已完成['..shuju[1]..']剧情...</font>","Type":9}')
                return
            end
            if (sj.i == 2 or sj.i == 3) and sj.k > 1 then
                if not (T_ywl["jl_"..sj.i.."_"..sj.j.."_"..(sj.k - 1)] and T_ywl["jl_"..sj.i.."_"..sj.j.."_"..(sj.k - 1)] == 1) then
                    sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>请先完成前一章节任务...</font>","Type":9}')
                    return
                end
            end
            if shuju[2] == 999 then
                if shuju[3][1] == 3 or shuju[3][1] == 4 then
                    if not (T_ywl["rw_"..shuju[3][2]] and T_ywl["rw_"..shuju[3][2]] == 1) then
                        sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>未完成['..shuju[1]..']剧情...</font>","Type":9}')
                        return
                    end
                end
            end
            T_ywl["jl_"..sj.i.."_".. sj.j .."_"..sj.k .."_" .. sj.z] = 1
            setplaydef(play, VarCfg.T_ywl, tbl2json(T_ywl))
            if shuju.jl then
                Player.rwjl(play,shuju.jl,"剧情jl",nil)
            end
            sendluamsg(play, 101, 11, 0, 0,
                    '{"dljq":'..getplaydef(play, VarCfg.T_dljq)
                            ..',"zxrw":'..getplaydef(play, VarCfg.T_zxrw)
                            ..',"ywl":'..getplaydef(play, VarCfg.T_ywl)
                            ..'}')
        end
    elseif p2 == 4 then --一整个大陆任务奖励
    elseif p2 == 5 then --专属追踪
        local sj = json2tbl(data)
        if sj.i and sj.k and sj.i > 0 and sj.k > 0 and sj.i <= #npc_xyl and sj.k <= #npc_xyl[sj.i][4] then
            if Player.dl_sz_notip(play, sj.i) then
                local shuju = npc_xyl[sj.i][4][sj.k]
                if shuju[3] and shuju[3][1] == 0 then
                    sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>无法传送...</font>","Type":9}')
                else
                    if shuju.jcch and not checktitle(play, shuju.jcch) then
                        sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>需要称号：['..shuju.jcch..']，您没有完成前置的任务...</font>","Type":9}')
                        return
                    end
                    if getplaydef(play,"N$战斗状态") < os.time() then
                        map(play,shuju[1])
                        sendluamsg(play,101,9999,0,0,"npc_ywl")
                    else
                        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>战斗状态无法使用...</font>","Type":9}')
                    end
                end
            else
                sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>条件不足,无法传送...</font>","Type":9}')
            end
        end
    elseif p2 == 6 then --专属追踪
        local sj = json2tbl(data)
        if sj.i and sj.k and sj.i > 0 and sj.k > 0 and sj.i <= #npc_xyl and sj.k <= #npc_xyl[sj.i][4] then
            if Player.dl_sz_notip(play, sj.i) and npc_xyl[sj.i][5] then
                local shuju = npc_xyl[sj.i][5][sj.k]
                if shuju[3] and shuju[3][1] == 0 then
                    sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>无法传送...</font>","Type":9}')
                else
                    if shuju.jcch and not checktitle(play, shuju.jcch) then
                        sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>需要称号：['..shuju.jcch..']，您没有完成前置的任务...</font>","Type":9}')
                        return
                    end
                    if getplaydef(play,"N$战斗状态") < os.time() then
                        map(play,shuju[1])
                        sendluamsg(play,101,9999,0,0,"npc_ywl")
                    else
                        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>战斗状态无法使用...</font>","Type":9}')
                    end
                end
            else
                sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>条件不足,无法传送...</font>","Type":9}')
            end
        end
    end
end
---记忆传送
npc[13] = function(play, p2, p3, data)  -- 记录石
    if p2 == 0 then
        -- 当 p3 为 0 时，进行记录石的初始化操作
        -- 向客户端发送消息，请求获取玩家的默认记录石信息
        sendluamsg(play, 101, 13, 1, 0, getplaydef(play, VarCfg.T_jls))
    elseif p2 == 1 then

        -- 当 p3 为 1 时，记录
        local jls = json2tbl(getplaydef(play,VarCfg.T_jls))
        --获取当前玩家坐标和地图
        local xx,yy,dt = getbaseinfo(play,4),getbaseinfo(play,5),getbaseinfo(play,3)
        if string.find(dt,"_") then
            --向客户端发送消息，通知玩家处于副本地图，无法记录
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>副本地图无法记录...</font>","Type":9}')
            return
        elseif checkkuafu(play) or jinzhigj[dt] then
            --向客户端发送消息，通知玩家处于禁止记录的地图，无法记录
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>当前地图无法记录...</font>","Type":9}')
            return
        end
        --将当前玩家的坐标和地图信息存入记录石信息中
        jls["dtm"..p3] = {p3,dt,xx,yy}
        --将记录石信息存入玩家的数据中
        setplaydef(play,VarCfg.T_jls,tbl2json(jls))
        --向客户端发送消息，通知记录石记录成功
        sendluamsg(play, 101, 13, 2, p3, getplaydef(play, VarCfg.T_jls))
    elseif p2 == 2 then
        -- 当 p2 为 2 时，进行记录石的传送
        local jls = json2tbl(getplaydef(play,VarCfg.T_jls))
        --获取当前玩家的记录石信息
        local jlsinfo = jls["dtm"..p3]
        --判断记录石信息是否存在
        if jlsinfo then
            --判断当前玩家是否处于战斗状态
            if getplaydef(play,"N$战斗状态") < os.time() then
                --是不是有足够的仙玉
                if getbindmoney(play,"仙玉") < 100 then
                    sendmsg(play,1,'{"Msg":"<font color=\'#ff0500\'>仙玉不足,无法传送...</font>","Type":9}')
                    return
                end
                consumebindmoney(play,"仙玉",100)
                --传送玩家到记录石的位置
                mapmove(play,jlsinfo[2],jlsinfo[3],jlsinfo[4],2)
                --向客户端发送消息，通知传送成功
                sendluamsg(play, 101, 13, 3, p3, "")
            else
                --向客户端发送消息，通知玩家处于战斗状态，无法传送
                sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>战斗状态无法使用...</font>","Type":9}')
            end
        else
            --向客户端发送消息，通知记录石不存在
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>记录石不存在...</font>","Type":9}')
        end
    end
end
---实力提升
npc[17] = function(play, p2, p3, data)  --实力提升
    if p2 == 0 then  --实力提升  --初始化页面
        sendluamsg(play, 101, 17, 0, 0, "")
    end
end
---首充礼包
npc[501] = function(play,p2,p3,data)  --首充礼包
    if p3 == 0 then
        sendluamsg(play, 101, 501, 0, 0,getflagstatus(play,VarCfg.BS_sckg))
    elseif p3 == 1 then
        if querymoney(play,20) >= 10 then
            if getflagstatus(play,VarCfg.BS_sckg) == 0 then
                setflagstatus(play,VarCfg.BS_sckg,1)
                local json = json2tbl(getplaydef(play,VarCfg.T_czlb))
                json["sclb"] = true
                setplaydef(play,VarCfg.T_czlb,tbl2json(json))
                sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[首充礼包]</font><font color=\'#28ef01\'>领取首充礼包成功!</font>","Type":9}')
                sendluamsg(play, 101, 501, 0, 1,"")
            else
                sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[首充礼包]</font><font color=\'#ff0500\'>已经领取过了,无法重复领取...</font>","Type":9}')
            end
        else
            sendluamsg(play, 101, 999, 10, 7,"")
        end
    end
end
---在线充值
npc[502] = function(play,p2,p3,data)  --在线充值
    if p3 == 0 then
        sendluamsg(play, 101, 502, 0, 0,getplaydef(play,VarCfg.T_czlb))
    elseif p3 == 2 then
        local je = tonumber(data)
        if je and constant.cz_jeyz[je] then
            setplaydef(play,VarCfg.U_czyz,constant.cz_jeyz[je])
            sendluamsg(play, 101, 999, je, 7,"")
        end
    elseif p3 == 3 then
        local je = tonumber(data)
        if je and je >= 10 then
            setplaydef(play,VarCfg.U_czyz,0)
            sendluamsg(play, 101, 999, je, 7,"")
        else
            sendmsg(play,1,'{"Msg":"<font color=\'#ff0500\'>充值金额不得小于10元...</font>","Type":9}')
        end
    elseif p3 == 4 then
        local json = json2tbl(getplaydef(play,VarCfg.T_czlb))
        if json.cz4 then
            if json.jskg then
                json.jskg = nil
                Buff[94](play,2)
                sendmsg(play,1,'{"Msg":"<font color=\'#ff0500\'>溅射功能已关闭...</font>","Type":9}')
            else
                Buff[94](play,1)
                json.jskg = true
                sendmsg(play,1,'{"Msg":"<font color=\'#28ef01\'>溅射功能已开启...</font>","Type":9}')
            end
            setplaydef(play,VarCfg.T_czlb,tbl2json(json))
        end
    end
end
---赞助礼包
local zzch,sg,qsx = {"黄金赞助","铂金赞助","钻石赞助"},{0,50,100},{1,2,3}
npc[503] = function(play,p2,p3,data)  --赞助礼包
    if p2 == 0 then
        sendluamsg(play, 101, 503, 0, getplaydef(play,VarCfg.U_fldt[2]),getplaydef(play,VarCfg.T_czlb))
    elseif p2 == 1 then
        local json = json2tbl(getplaydef(play,VarCfg.T_czlb))
        if not json["zzlb"..p3] then
            if getplaydef(play,VarCfg.U_fldt[2]) >= sg[p3] then
                json["zzlb"..p3] = 1
                setplaydef(play,VarCfg.T_czlb,tbl2json(json))
                sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[赞助礼包]</font><font color=\'#28ef01\'>领取成功...</font>","Type":9}')
                Player.title_give(play,zzch[p3])
                Player.qsx_give(play, qsx[p3], "赞助", nil)
                if getplaydef(play,VarCfg.U_zxrw[1]) == 2 and p3 == 1 then
                    newdeletetask(play,getplaydef(play,VarCfg.U_zxrw[1]))
                    playeffect(play,4011,25,-50,1,0,0)
                    sendluamsg(play, 101, 503, 2, p3,"")
                    return
                end
                if json["zzlb"..1] and json["zzlb"..2] and json["zzlb"..3] then
                    sendluamsg(play, 101, 503, 2, p3,"")
                    return
                end
                sendluamsg(play, 101, 503, 1, p3,"")
            else
                sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[赞助礼包]</font><font color=\'#ff0500\'>当前杀怪数量不足,无法领取...</font>","Type":9}')
                return
            end
        else
            sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[赞助礼包]</font><font color=\'#ff0500\'>已经领取过礼包了...</font>","Type":9}')
        end
    end
end
---快人一步
npc[504] = function(play,p2,p3,data)  --快人一步
    if p2 == 0 then
        sendluamsg(play, 101, 504, 0, 0,'{"mztq":'..getflagstatus(play,VarCfg.BS_mztq)..',"zjxz":'..getplaydef(play,VarCfg.U_jdgh)..'}')
    elseif p2 == 1 then
        if getflagstatus(play,VarCfg.BS_mztq) == 0 then
            sendluamsg(play, 101, 999, 98, 21,"")
        else
            sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>每人只能购买一次</font>","Type":9}')
        end
    elseif p2 == 2 then
        sendluamsg(play, 101, 504, 2, 0,'{"mztq":'..getflagstatus(play,VarCfg.BS_mztq)..',"zjxz":'..getplaydef(play,VarCfg.U_jdgh)..'}')
    end
end
---自动巡航
npc[505] = function(play,p2,p3,data)  --自动巡航
    if p2 == 0 then
        sendluamsg(play, 101, 505, 0, 0,"")
    elseif p2 == 1 then
        sendluamsg(play, 101, 505, 1, 0,getplaydef(play,VarCfg.T_aigj))
    elseif p2 == 2 then
        local dtmz = getbaseinfo(play,3)
        if jinzhigj[dtmz] or string.find(dtmz,"_") then
            sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[自动巡航]</font><font color=\'#ff0000\'>当前地图,无法记录...</font>","Type":9}')
        elseif checkkuafu(play) then
            sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[自动巡航]</font><font color=\'#ff0000\'>跨服地图,无法记录...</font>","Type":9}')
        else
            local json = json2tbl(getplaydef(play,VarCfg.T_aigj))
            json["dt"..p3] = getbaseinfo(play,45)
            json["dtid"..p3] = dtmz
            sendluamsg(play, 101, 505, 2, p3,getbaseinfo(play,45))
            setplaydef(play,VarCfg.T_aigj,tbl2json(json))
        end
    elseif p2 == 3 then
        local json = json2tbl(getplaydef(play,VarCfg.T_aigj))
        if json["fgx"..p3] then
            json["fgx"..p3] = nil
        elseif json["dtid"..p3] then
            json["fgx"..p3] = true
        else
            sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[自动巡航]</font><font color=\'#ff0500\'>当前未记录地图,无法勾选...</font>","Type":9}')
        end
        setplaydef(play,VarCfg.T_aigj,tbl2json(json))
        sendluamsg(play, 101, 505, 3, p3,getplaydef(play,VarCfg.T_aigj))
    elseif p2 == 4 then
        if getflagstatus(play,VarCfg.BS_18cz) == 1 then
            local json = json2tbl(getplaydef(play,VarCfg.T_aigj))
            if getflagstatus(play,VarCfg.BS_AIgj) == 0 then
                local yz = 0
                for i = 1, 10, 1 do
                    if json["fgx"..i] then
                        yz = 1
                        break
                    end
                end
                if yz == 1 then
                    startautoattack(play)
                    setflagstatus(play,VarCfg.BS_AIgj,1)
                    json.gjkg = true
                    setplaydef(play,VarCfg.N_Aigj[2],os.time())
                    setplaydef(play,VarCfg.N_Aigj[5],os.time())
                    setontimer(play, 5, 1, 0, 1)
                else
                    sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[自动巡航]</font><font color=\'#ff0500\'>未勾选任何地图,无法进行AI挂机...</font>","Type":9}')
                end
            else
                json.gjkg = nil
                stopautoattack(play)
                setflagstatus(play,VarCfg.BS_AIgj,0)
                setofftimer(play,5)
            end
            setplaydef(play,VarCfg.T_aigj,tbl2json(json))
            sendluamsg(play, 101, 505, 4,0,tbl2json(json))
        else
            sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[自动巡航]</font><font color=\'#ff0000\'>未激活【自动巡航】,无法使用，可在在线充值激活...</font>","Type":9}')
        end
    elseif p2 == 5 then
        if getflagstatus(play,VarCfg.BS_18cz) == 1 then
            local json = json2tbl(getplaydef(play,VarCfg.T_aigj))
            if p3 == 1 then
                if json.zgx1 then
                    json.zgx1 = nil
                    Buff[96](play,2)
                else
                    Buff[96](play,1)
                    json.zgx1 = true
                end
            elseif p3 == 2 then
                if json.zgx2 then
                    json.zgx2 = nil
                    shaguai.jian(play,23)
                else
                    shaguai.jia(play,23)
                    json.zgx2 = true
                end
            else
                if json["zgx"..p3] then
                    json["zgx"..p3] = nil
                else
                    json["zgx"..p3] = true
                end
            end
            setplaydef(play,VarCfg.T_aigj,tbl2json(json))
        end
    else
        sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[自动巡航]</font><font color=\'#ff0000\'>未激活【自动巡航】,无法使用，可在在线充值激活...</font>","Type":9}')
    end
end
---天选之人
npc[506] = function(play,p2,p3,msgData)  --天选之子
    if p2 == 0 then
        sendluamsg(play, 101, 506, 0, 0,
                '{"A_txzz":'..(getsysvar(VarCfg["A_天选之人json"]) == "" and "{}" or getsysvar(VarCfg["A_天选之人json"]))..
                        ',"T_txzr":'..getplaydef(play,VarCfg.T_txzr)..
                        ',"kqsj":'..getsysvar(VarCfg["G_开区分钟"])..
                        ',"G_txzz_2":'..getsysvar(VarCfg["G_天选之人时间"][2])..
                        '}')
    end
end

local hd_dtmz = {

}

npc[507] = function(play,p2,p3,msgData)  --游戏活动
    if p2 == 0 then
        sendluamsg(play, 101, 507, 0, 0,
                '{"kqfz":'..getsysvar(VarCfg["G_开区分钟"])..',"hdjl":'..getplaydef(play,VarCfg.T_hdjl)..'}')
    elseif p2 == 1  then

    elseif p2 == 2 then
        if  p3 > 0 and p3 < 4 then
            local kqsj = getsysvar(VarCfg["G_开区分钟"])
            if getplaydef(play,"N$战斗状态") < os.time() then
                if kqsj >= hd_dtmz[1][p3][2] and kqsj < hd_dtmz[1][p3][3] then
                    if p3 == 1 then
                        mapmove(play,"xtc",137,138,7)
                    elseif getbaseinfo(play,3) == hd_dtmz[1][p3][1] then
                        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>已在活动地图了...</font>","Type":9}')
                    elseif hd_dtmz[1][p3][1] == "比武大会" then
                        mapmove(play,hd_dtmz[1][p3][1],29,29,8)
                        sendluamsg(play,101,9999,0,0,"npc_yxhd")
                    else
                        map(play,hd_dtmz[1][p3][1])
                        sendluamsg(play,101,9999,0,0,"npc_yxhd")
                    end
                    local T_hdcjjl = json2tbl(getplaydef(play,VarCfg.T_hdcjjl))
                    if not T_hdcjjl["2_"..p3] then
                        setplaydef(play,VarCfg.U_hdjf,getplaydef(play,VarCfg.U_hdjf) + 10)
                        T_hdcjjl["2_"..p3] = 1
                        setplaydef(play,VarCfg.T_hdcjjl,tbl2json(T_hdcjjl))
                    end
                    delaymsggoto(play,100,"@Login_msg,1")
                else
                    sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>不在活动时间内无法传送...</font>","Type":9}')
                end
            else
                sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>战斗状态无法使用...</font>","Type":9}')
            end
        end
    elseif p2 == 3 then
        if p3 > 0 and p3 <= 4 then
            if getplaydef(play,"N$战斗状态") < os.time() then
                if getbaseinfo(play,3) == hd_dtmz[2][p3][1] then
                    sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>已在活动地图了...</font>","Type":9}')
                else
                    if p3 == 4 then
                        mapmove(play,hd_dtmz[2][p3][1],48,53,8)
                    else
                        map(play,hd_dtmz[2][p3][1])
                    end
                    sendluamsg(play,101,9999,0,0,"npc_yxhd")
                end
                local T_hdcjjl = json2tbl(getplaydef(play,VarCfg.T_hdcjjl))
                if not T_hdcjjl["3_"..p3] then
                    setplaydef(play,VarCfg.U_hdjf,getplaydef(play,VarCfg.U_hdjf) + 10)
                    T_hdcjjl["3_"..p3] = 1
                    setplaydef(play,VarCfg.T_hdcjjl,tbl2json(T_hdcjjl))
                end
                delaymsggoto(play,100,"@Login_msg,1")
            else
                sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>战斗状态无法使用...</font>","Type":9}')
            end
        elseif p3 == 5 then
            if getbaseinfo(play,3) == "阵营对抗" then
                sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>已在活动地图了...</font>","Type":9}')
                return
            end
            if getplaydef(play,VarCfg.J_zydkbs) == 0 then
                if getsysvar(constant.G_zydkbs) == 0 then
                    setplaydef(play,VarCfg.J_zydkbs,1)
                    setsysvar(constant.G_zydkbs,1)
                    mapmove(play,"阵营对抗",33,37,8)
                    setcamp(play,1)
                else
                    setplaydef(play,VarCfg.J_zydkbs,2)
                    setsysvar(constant.G_zydkbs,0)
                    mapmove(play,"阵营对抗",33,37,8)
                    setcamp(play,2)
                end
            else
                if getplaydef(play,VarCfg.J_zydkbs) == 1 then
                    mapmove(play,"阵营对抗",33,37,8)
                    setcamp(play,1)
                elseif getplaydef(play,VarCfg.J_zydkbs) == 2 then
                    mapmove(play,"阵营对抗",33,37,8)
                    setcamp(play,2)
                end
            end
        end
    end
end

---天天省钱
npc[509] = function(play,p2,p3,msgData) openhyperlink(play,111,0) end
---交易行
npc[510] = function(play,p2,p3,msgData) openhyperlink(play,35,0) end

npc[511] = function(play,p2,p3,msgData)  --福利大厅
end

npc[512] = function(play,p2,p3,msgData)  --游戏攻略
    if p2 == 0 then
        sendluamsg(play, 101, 512, 0, 0,"")
    end
end

local xlxl = {{1,2,3,4,7,8,23,22,24,25,26},{18,38,68,128,288,588,888,1188,1588,1888},{98,6,30,198,28,58,88,66,98}}
npc[998] = function(play,p2,p3,msg)  --后台
    local qfmz = getconst(play, '<$SERVERNAME>')
    if getplaydef(play,VarCfg.S_houtaibf) ~= "" or (qfmz == "" or qfmz == "测试区" )then
        if getplaydef(play,VarCfg.S_houtaibf) == "" and (qfmz == "" or qfmz == "测试区" ) then
            setplaydef(play,VarCfg.S_houtaibf,"本地测试区")
        end
        if p2 == 1 then
            if p3 == 0 then
                if getplayerbyname(msg) then
                    sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>['..msg..']玩家在线</font>","Type":9}')
                else
                    sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>['..msg..']玩家不在线</font>","Type":9}')
                end
            elseif p3 == 1 then
                local data = json2tbl(msg)
                if data and data.mz and data.hb and data.hb > 0 and data.hb < 9 then
                    local dx = getplayerbyname(data.mz)
                    if dx then
                        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>['..data.mz..']货币剩余：'..querymoney(dx,xlxl[1][data.hb])..'</font>","Type":9}')
                    else
                        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>['..data.mz..']玩家不在线</font>","Type":9}')
                    end
                end
            elseif p3 == 2 or p3 == 3 then
                local data = json2tbl(msg)
                if data and data.mz and data.hb and data.hb > 0 and data.hb < 12 and data.sl then
                    local dx = getplayerbyname(data.mz)
                    if dx then
                        local hbid = xlxl[1][data.hb]
                        if p3 == 2 then
                            changemoney(dx,hbid,"=",data.sl,"后台",true)
                            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>['..data.mz..']货币数量修改为['..data.sl..']</font>","Type":9}')
                        else
                            changemoney(dx,hbid,"+",data.sl,"后台",true)
                            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>['..data.mz..']增加['..data.sl..']当前货币剩余：'..querymoney(dx,xlxl[1][data.hb])..'</font>","Type":9}')
                        end
                    else
                        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>['..data.mz..']玩家不在线</font>","Type":9}')
                    end
                end
            elseif p3 == 4 then
                local data = json2tbl(msg)
                if data and data.mz and data.hb and data.hb > 0 and data.hb < 11 then
                    local dx,sy = getplayerbyname(data.mz),data.hb
                    if dx then
                        setplaydef(dx, VarCfg.U_czyz,data.hb)
                        changemoney(dx,7,"+",xlxl[2][data.hb]*100,"",true)
                        recharge(dx, xlxl[2][data.hb], "gm", 7, false)
                        sendmsg(play, 1, '{"Msg":"<font color=\'#28ef01\'>['..data.mz..']发送礼包成功</font>","Type":9}')
                    else
                        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>['..data.mz..']玩家不在线</font>","Type":9}')
                    end
                end
            elseif p3 == 5 then
                local data = json2tbl(msg)
                if data and data.mz and data.hb and data.hb > 0 and data.hb < 11 then
                    local dx,sy = getplayerbyname(data.mz),data.hb
                    if dx then
                        recharge(dx, xlxl[3][data.hb], "gm", 21, false)
                        sendmsg(play, 1, '{"Msg":"<font color=\'#28ef01\'>['..data.mz..']发送礼包成功</font>","Type":9}')
                    else
                        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>['..data.mz..']玩家不在线</font>","Type":9}')
                    end
                end
            end
        elseif p2 == 2 then
            local data = json2tbl(msg)
            if p3 == 5 then
                setcastleguild(data.ch, 0)
                return
            end
            if data and data.mz then
                local dx = getplayerbyname(data.mz)
                if dx then
                    if getstditeminfo(data.wp,1) == data.wp then
                        if p3 == 1 then
                            if data.lx then
                                giveitem(dx,data.wp,data.sl,data.lx == 1 and 850 or 0)
                                sendmsg(play, 1, '{"Msg":"<font color=\'#28ef01\'>['..data.wp..']增加完成</font>","Type":9}')
                            end
                        elseif p3 == 2 then
                            takeitem(dx,data.wp,data.sl)
                            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>['..data.wp..']扣除完成</font>","Type":9}')
                        elseif p3 == 4 then
                            if checktitle(dx,data.ch) then
                                sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>拿...</font>","Type":9}')
                                Player.title_del(dx,data.ch)
                            else
                                sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>给...</font>","Type":9}')
                                Player.title_give(dx,data.ch)
                            end
                        end
                    else
                        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>物品名字不正确</font>","Type":9}')
                    end
                else
                    sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>['..data.mz..']玩家不在线</font>","Type":9}')
                end
            end
        elseif p2 == 3 then
            local data = json2tbl(msg)
            if data and data.mz and data.bl and data.lx > 0 then
                local dx = getplayerbyname(data.mz)
                if data.lx ~= 4 then
                    if dx  then
                        if p3 == 1 then
                            if data.lx == 1 then
                                if data.bl == "积分" then
                                    sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>['..data.mz..']礼包积分剩余：'..querymoney(dx,22)..'</font>","Type":9}')
                                elseif string.find(data.bl,"t") or string.find(data.bl,"T") or string.find(data.bl,"S") then
                                    mircopy(play,getplaydef(dx,data.bl))
                                    messagebox(play,"["..data.bl.."]的值\\"..getplaydef(dx,data.bl).."")
                                else
                                    sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>['..data.bl..']的值['..getplaydef(dx,data.bl)..']</font>","Type":9}')
                                end
                            elseif data.lx == 2 then
                                sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>标识：['..data.bl..']的值['..getflagstatus(dx,data.bl)..']</font>","Type":9}')
                            elseif data.lx == 3 then
                                if hasbuff(dx,data.bl) then
                                    sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>buff:['..data.bl..']的值['..math.floor((getbuffinfo(dx,data.bl,2)/60))..'分钟]</font>","Type":9}')
                                else
                                    sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>['..data.mz..']玩家没有这个BUFF</font>","Type":9}')
                                end
                            end
                        else
                            if data.zhi then
                                if data.lx == 1 then
                                    if data.bl == "积分" then
                                        changemoney(dx,22,"+",data.zhi,"后台",true)
                                        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>['..data.mz..']增加['..data.zhi..']当前礼包积分剩余：'..querymoney(dx,22)..'</font>","Type":9}')
                                    else
                                        setplaydef(dx,data.bl,data.zhi)
                                        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>['..data.bl..']的值['..getplaydef(dx,data.bl)..']</font>","Type":9}')
                                    end
                                elseif data.lx == 2 then
                                    setflagstatus(dx,data.bl,data.zhi)
                                    sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>标识：['..data.bl..']的值['..getflagstatus(dx,data.bl)..']</font>","Type":9}')
                                elseif data.lx == 3 then
                                    sendmsg(play, 1, '{"Msg":"<font color=\'#ff0500\'>BUFF只能查询</font>","Type":9}')
                                end
                            end
                        end
                    else
                        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>['..data.mz..']玩家不在线</font>","Type":9}')
                    end
                elseif data.lx == 4 then
                    if p3 == 1 then
                        if string.find(data.bl,"A") or string.find(data.bl,"a") then
                            messagebox(play,"["..data.bl.."]的值\\"..getsysvar(data.bl).."")
                        else
                            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>['..data.bl..']的值['..getsysvar(data.bl)..']</font>","Type":9}')
                        end
                    elseif p3 == 2 then
                        if data.zhi then
                            setsysvar(data.bl,data.zhi)
                            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>['..data.bl..']的值['..getsysvar(data.bl)..']</font>","Type":9}')
                        end
                    end
                end
            end
        elseif p2 == 4 then
            if msg ~= "" then
                local dx = getplayerbyname(msg)
                if p3 == 1 then
                    if dx  then
                        kick(dx)
                        sendmsg(play, 1, '{"Msg":"<font color=\'#28ef01\'>['..msg..']踢下线</font>","Type":9}')
                    else
                        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>['..msg..']玩家不在线</font>","Type":9}')
                    end
                elseif p3 < 4 then
                    setgmlevel(play,10)
                    if p3 == 2 then
                        gmexecute(play,"DenyCharNameLogon",msg,1)
                        sendmsg(play, 1, '{"Msg":"<font color=\'#28ef01\'>['..msg..']加入封禁列表</font>","Type":9}')
                        if dx then
                            callscriptex(dx, "CHANGELEVEL", "=", 1)
                        end
                    elseif p3 == 3 then
                        gmexecute(play,"DelDenyCharNameLogon",msg)
                        sendmsg(play, 1, '{"Msg":"<font color=\'#28ef01\'>['..msg..']去除封禁列表</font>","Type":9}')
                    end
                    setgmlevel(play,0)
                end
            end
            if p3 == 4 then
                setgmlevel(play,10)
                gmexecute(play,"ShowDenyCharNameLogon")
                setgmlevel(play,0)
            end
        elseif p2 == 5 then
            local data = json2tbl(msg)
            if data and data.mz and data.hb and data.hb > 0 then
                local dx,sy = getplayerbyname(data.mz),data.hb
                if dx then
                    changemoney(dx,7,"+",data.hb*100,"",true)
                    recharge(dx, data.hb, "gm", 7, false)
                    sendmsg(play, 1, '{"Msg":"<font color=\'#28ef01\'>['..data.mz..']发送礼包成功</font>","Type":9}')
                else
                    sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>['..data.mz..']玩家不在线</font>","Type":9}')
                end
            end
        end
    end
end

npc[1004] = function(play,p2,p3,msg)  --排行榜查询
    if p2 == 1 then
        local dx = getplayerbyid(msg)
        if dx then
            sendmsg(dx, 1, '{"BColor":249,"FColor":255,"Msg":"<outline size=\'1\'><font color=\'#FFFF00\'></font>玩家<font color=\'#00ff00\'>[' .. getbaseinfo(play, 1) .. ']</font>在偷偷打量你</outline>","Type":1}')
            sendluamsg(play,101,1004,0,0,'{"userid":"'..msg..'","zdl":'..querymoney(dx,29)..'}')
        else
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>玩家不在线</font>","Type":9}')
        end
    end
end


return npc