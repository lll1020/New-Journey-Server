npc = {}

npc[2] = function(play, p2, p3, msgData) --背包  面板
    if p2 == 0 then
        -- 回收面板
        sendluamsg(play, 101, 2, 2, 0, '{"xz":' .. getplaydef(play, VarCfg.T_hsdg) .. ',"kg":[' .. getflagstatus(play, VarCfg.BS_huishou[1]) .. "," .. getflagstatus(play, VarCfg.BS_huishou[2]) .. "," .. getflagstatus(play, VarCfg.BS_huishou[3]) .. "," .. getflagstatus(play, VarCfg.BS_huishou[4]) .. "," .. getflagstatus(play, VarCfg.BS_huishou[5]) .. "]}")
    elseif p2 == 1 then
        if p3 > 0 and p2 < 5 then
            msgData = tonumber(msgData)
            if msgData > 0 and msgData < 50 then
                local hspz = json2tbl(getplaydef(play, VarCfg.T_hsdg))
                hspz[p3 .. "_" .. msgData] = 1
                setplaydef(play, VarCfg.T_hsdg, tbl2json(hspz))
            end
        end
    elseif p2 == 2 then
        local hspz = json2tbl(getplaydef(play, VarCfg.T_hsdg))
        if hspz[msgData] and hspz[msgData] == 1 then
            hspz[msgData] = nil
        else
            hspz[msgData] = 1
        end
        setplaydef(play, VarCfg.T_hsdg, tbl2json(hspz))
    elseif p2 == 3 then
    elseif p2 == 4 then
        if p3 == 1 then
            if msgData == "1" then
                sendmsg(play,1,'{"Msg":"<font color=\'#00ff00\'>自动吃元宝已开启...</font>","Type":9}' )
            else
                sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>自动吃元宝已关闭...</font>","Type":9}' )
            end
            setflagstatus(play, VarCfg.BS_huishou[1], msgData)
        elseif p3 == 2 then
            if msgData == "1" then
                sendmsg(play,1,'{"Msg":"<font color=\'#00ff00\'>自动吃元宝已开启...</font>","Type":9}' )
            else
                sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>自动吃元宝已关闭...</font>","Type":9}' )
            end
            setflagstatus(play, VarCfg.BS_huishou[2], msgData)
        elseif p3 == 3 then
            if msgData == "1" then
                sendmsg(play,1,'{"Msg":"<font color=\'#00ff00\'>自动吃经验已开启...</font>","Type":9}' )
            else
                sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>自动吃经验已关闭...</font>","Type":9}' )
            end
            setflagstatus(play, VarCfg.BS_huishou[3], msgData)
        elseif p3 == 4 then
            if msgData == "1" then
                sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>自动回收已开启...</font>","Type":9}')
            else
                sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>自动回收已关闭...</font>","Type":9}')
            end
            setflagstatus(play, VarCfg.BS_huishou[4], msgData)
        elseif p3 == 5 then
            if msgData == "1" then
                sendmsg(play,1,'{"Msg":"<font color=\'#00ff00\'>可提升不回收已开启...</font>","Type":9}' )
            else
                sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>可提升不回收已关闭...</font>","Type":9}' )
            end
            setflagstatus(play, VarCfg.BS_huishou[5], msgData)
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
        sendluamsg(play, 101, 2, 4, 0, "")
    elseif p2 == 7 then
        Player.huishou(play)
        refreshbag(play)
    elseif p2 == 999 then --销毁 单个
        if type(p3) ~= "number" then
            Player.sendmsgEx(play, "参数错误!")
            return
        end
        local itemName = Item.getNameMakeid(play, p3)
        local isSuccess = delitembymakeindex(play, tostring(p3), 0, "物品销毁")
        if not isSuccess then
            Player.sendmsgEx(play, "物品销毁失败,请检查!#249")
        else
            if itemName then
                Player.sendmsgEx(play, "【" .. itemName .. "】物品销毁成功!")
            end
        end
    elseif p2 == 998 then --屏蔽全服掉落信息
        local state = getflagstatus(play, VarCfg["F_过滤全服信息"])
        if state == 0 then
            filterglobalmsg(play, 1)
            setflagstatus(play, VarCfg["F_过滤全服信息"], 1)
            Player.sendmsgEx(play, "开启过滤全服掉落提示信息。#249")
        else
            filterglobalmsg(play, 0)
            setflagstatus(play, VarCfg["F_过滤全服信息"], 0)
            Player.sendmsgEx(play, "关闭过滤全服掉落提示信息。#249")
        end
    end
end

npc[3] = function(play) --仓库面板
    openstorage(play)
end

npc[5] = function(play, p2, p3, data) -- 内挂开关
    setflagstatus(play, VarCfg.BS_ngkg, p2)
    Buff[70](play, p2 == 1 and 1 or 2)
    sendluamsg(play, 103, 1, 0, 0, '{"ngkg":' .. p2 .. "}")
end

npc[6] = function(play, p2, p3, data) -- 屏蔽系统消息
    if getplaydef(play, "N$是否屏蔽系统消息") == 0 then
        setplaydef(play, "N$是否屏蔽系统消息", 1)
        filterglobalmsg(play, 1)
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>不在接受系统提示消息...</font>","Type":9}')
    else
        setplaydef(play, "N$是否屏蔽系统消息", 0)
        filterglobalmsg(play, 0)
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>正常接收系统消息...</font>","Type":9}')
    end
end

---异闻录
local npc_xyl = dofile('Envir/Lua/Data/npc_xyl.lua')

-- 
local function _ywl_activate_linggen(play, idx)
    local data = Player.getJsonTableByVar(play, VarCfg["T_灵根"])
    data.level = data.level or {}
    local key = tostring(idx)
    if data.level[key] then
        return true
    end
    data.level[key] = 0
    Player.setJsonVarByTable(play, VarCfg["T_灵根"], data)
    -- 按 602 的激活逻辑，这里只做激活与提示，不走副本流程
    Player.sendmsgEx(play, "恭喜你，成功激活了灵根#249")
    return true
end

local function _ywl_apply_special_reward(play, name, count)
    if name == "激活金灵根" then
        return _ywl_activate_linggen(play, 1)
    elseif name == "激活木灵根" then
        return _ywl_activate_linggen(play, 2)
    elseif name == "激活水灵根" then
        return _ywl_activate_linggen(play, 3)
    elseif name == "激活火灵根" then
        return _ywl_activate_linggen(play, 4)
    elseif name == "激活土灵根" then
        return _ywl_activate_linggen(play, 5)
    end
    return false
end

local function _ywl_filter_rewards(play, list)
    if type(list) ~= "table" then
        return list
    end
    local out = {}
    for _, v in ipairs(list) do
        if type(v) == "table" and type(v[1]) == "string" then
            if not _ywl_apply_special_reward(play, v[1], v[2]) then
                out[#out + 1] = v
            end
        else
            out[#out + 1] = v
        end
    end
    return out
end
--功能:检查章节是否解锁
local function _ywl_is_chapter_open(play, i, j)
    if not i or not j or j <= 1 then
        return true
    end
    local T_ywl = json2tbl(getplaydef(play, VarCfg.T_ywl))
    return T_ywl["jl_" .. i .. "_" .. (j - 1)] == 1
end

npc[11] = function(play, p2, p3, data) --异闻录
    -- sj.i 大陆  sj.j 章节  sj.k 暂时不用  sj.z 剧情
    if p2 == 0 then
        sendluamsg(play, 101, 11, 0, 0, '{"dljq":' .. getplaydef(play, VarCfg.T_dljq) .. ',"zxrw":' .. getplaydef(play, VarCfg.T_zxrw) .. ',"ywl":' .. getplaydef(play, VarCfg.T_ywl) .. "}")
    elseif p2 == 1 then
        --传送
        local sj = json2tbl(data)
        if
            sj.i
            and sj.j
            and sj.z
            and sj.i > 0
            and sj.j > 0
            and sj.z > 0
            and sj.i <= #npc_xyl
            and sj.j <= #npc_xyl[sj.i]
            and sj.z <= #npc_xyl[sj.i][sj.j].jq
        then
            if not _ywl_is_chapter_open(play, sj.i, sj.j) then
                sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>章节未解锁...</font>","Type":9}')
                return
            end
            if Player.dl_sz_notip(play, sj.i) then
                local shuju = npc_xyl[sj.i][sj.j].jq[sj.z]
                if shuju.yd[1] == 0 then
                    sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>无法传送...</font>","Type":9}')
                elseif shuju.yd[1] == 1 then
                    if getplaydef(play, "N$战斗状态") < os.time() then
                        mapmove(play, shuju.yd[2], shuju.yd[4], shuju.yd[5], 2)
                        sendluamsg(play, 101, 0, 1, 1, '{"lx":2,"npcdt":"' .. shuju.yd[2] .. '","npcid":' .. shuju.yd[3] .. ',"xx":' .. shuju.yd[4] .. ',"yy":' .. shuju.yd[5] .. "}")
                        sendluamsg(play, 101, 9999, 0, 0, "npc_ywl")
                    else
                        Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0000\'>战斗状态无法使用...</font>","Type":9}')
                    end
                elseif shuju.yd[1] == 2 then
                    sendluamsg(play, 101, 0, 1, 1, '{"lx":1,"fx":1,"an":' .. shuju.yd[3] .. ',"ms":"点击按钮"}')
                    sendluamsg(play, 101, 9999, 0, 0, "npc_ywl")
                    sendluamsg(play, 101, 9999, 0, 0, "npc_ywl")
                elseif shuju.yd[1] == 3 then
                    sendluamsg(play, 101, 0, 1, 1, '{"lx":' .. shuju.yd[2] .. "}")
                    sendluamsg(play, 101, 9999, 0, 0, "npc_ywl")
                elseif shuju.yd[1] == 4 then
                    sendluamsg(play, shuju.yd[2], shuju.yd[3], shuju.yd[4], 0, "")
                    sendluamsg(play, 101, 9999, 0, 0, "npc_ywl")
                end
            else
                sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>条件不足,无法传送...</font>","Type":9}' )
            end
        end
    elseif p2 == 2 then --一页任务奖励
        local sj = json2tbl(data)
        if sj.i and sj.j and sj.i > 0 and sj.j > 0 and sj.i <= #npc_xyl and sj.j <= #npc_xyl[sj.i] then
            if not _ywl_is_chapter_open(play, sj.i, sj.j) then
                sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>章节未解锁...</font>","Type":9}')
                return
            end
            local T_ywl = json2tbl(getplaydef(play, VarCfg.T_ywl))
            if T_ywl["jl_" .. sj.i .. "_" .. sj.j] and T_ywl["jl_" .. sj.i .. "_" .. sj.j] == 1 then
                sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>已领取过了...</font>","Type":9}')
                return
            end
            for i = 1, #npc_xyl[sj.i][sj.j].jq do
                if
                    T_ywl["jl_" .. sj.i .. "_" .. sj.j .. "_" .. i]
                    and T_ywl["jl_" .. sj.i .. "_" .. sj.j .. "_" .. i] == 1
                then
                    T_ywl["jl_" .. sj.i .. "_" .. sj.j .. "_" .. i] = nil
                else
                    Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0000\'>未完成[' .. npc_xyl[sj.i][sj.j].jq[i][1] .. ']剧情...</font>","Type":9}')
                    return
                end
            end
            T_ywl["jl_" .. sj.i .. "_" .. sj.j] = 1
            setplaydef(play, VarCfg.T_ywl, tbl2json(T_ywl))
            local _jl = _ywl_filter_rewards(play, npc_xyl[sj.i][sj.j].jl)
            if _jl and #_jl > 0 then
                Player.rwjl(play, _jl, "剧情jl", 1)
            end
            sendluamsg(play, 101, 11, 3, 0, '{"dljq":' .. getplaydef(play, VarCfg.T_dljq) .. ',"zxrw":' .. getplaydef(play, VarCfg.T_zxrw) .. ',"ywl":' .. getplaydef(play, VarCfg.T_ywl) .. ',"T_tj":' .. getplaydef(play, VarCfg.T_tj) .. "}")
        end
    elseif p2 == 3 then --单个任务奖励
        local sj = json2tbl(data)
        if
            sj.i
            and sj.j
            and sj.z
            and sj.i > 0
            and sj.j > 0
            and sj.z > 0
            and sj.i <= #npc_xyl
            and sj.j <= #npc_xyl[sj.i]
            and sj.z <= #npc_xyl[sj.i][sj.j].jq
        then
            if not _ywl_is_chapter_open(play, sj.i, sj.j) then
                sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>章节未解锁...</font>","Type":9}')
                return
            end
            local shuju = npc_xyl[sj.i][sj.j].jq[sj.z]
            local T_dljq = json2tbl(getplaydef(play, VarCfg.T_dljq))
            local T_ywl = json2tbl(getplaydef(play, VarCfg.T_ywl))
            -- 查这个货币的数量（只查这一种，不合并绑/非绑）
            local num = querymoney(play, getstditeminfo("剧情点", 0))
            if num < npc_xyl[sj.i][sj.j].jqd then
                sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>剧情点不足...</font>","Type":9}')
                return
            end
            if
                (T_ywl["jl_" .. sj.i .. "_" .. sj.j] and T_ywl["jl_" .. sj.i .. "_" .. sj.j] == 1)
                or (
                    T_ywl["jl_" .. sj.i .. "_" .. sj.j .. "_" .. sj.z]
                    and T_ywl["jl_" .. sj.i .. "_" .. sj.j .. "_" .. sj.z] == 1
                )
            then
                sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>已完成[' .. shuju[1] .. ']剧情...</font>","Type":9}' )
                return
            end
            if shuju.id == 999 then
                if shuju.fwdjy(play, shuju.tk, shuju) then
                    --可以完成
                    T_ywl["jl_" .. sj.i .. "_" .. sj.j .. "_" .. sj.z] = 1
                    setplaydef(play, VarCfg.T_ywl, tbl2json(T_ywl))
                    if shuju.jl then
                        Player.rwjl(play, shuju.jl, "剧情jl", 1,0)
                    end
                    sendluamsg(play, 101, 11, 0, 0, '{"dljq":' .. getplaydef(play, VarCfg.T_dljq) .. ',"zxrw":' .. getplaydef(play, VarCfg.T_zxrw) .. ',"ywl":' .. getplaydef(play, VarCfg.T_ywl) .. "}")
                else
                    Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0000\'>未完成[' .. shuju[1] .. ']剧情...</font>","Type":9}')
                    return
                end
            end
        end
    elseif p2 == 4 then --一整个大陆任务奖励
    end
end
---记忆传送
npc[13] = function(play, p2, p3, data) -- 记录石
    if p2 == 0 then
        -- 当 p3 为 0 时，进行记录石的初始化操作
        -- 向客户端发送消息，请求获取玩家的默认记录石信息
        sendluamsg(play, 101, 13, 1, 0, getplaydef(play, VarCfg.T_jls))
    elseif p2 == 1 then
        -- 当 p3 为 1 时，记录
        local jls = json2tbl(getplaydef(play, VarCfg.T_jls))
        --获取当前玩家坐标和地图
        local xx, yy, dt = getbaseinfo(play, 4), getbaseinfo(play, 5), getbaseinfo(play, 3)
        if string.find(dt, "_") then
            --向客户端发送消息，通知玩家处于副本地图，无法记录
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>副本地图无法记录...</font>","Type":9}')
            return
        elseif checkkuafu(play) or jinzhigj[dt] then
            --向客户端发送消息，通知玩家处于禁止记录的地图，无法记录
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>当前地图无法记录...</font>","Type":9}')
            return
        end
        --将当前玩家的坐标和地图信息存入记录石信息中
        jls["dtm" .. p3] = { p3, dt, xx, yy }
        --将记录石信息存入玩家的数据中
        setplaydef(play, VarCfg.T_jls, tbl2json(jls))
        --向客户端发送消息，通知记录石记录成功
        sendluamsg(play, 101, 13, 2, p3, getplaydef(play, VarCfg.T_jls))
    elseif p2 == 2 then
        -- 当 p2 为 2 时，进行记录石的传送
        local jls = json2tbl(getplaydef(play, VarCfg.T_jls))
        --获取当前玩家的记录石信息
        local jlsinfo = jls["dtm" .. p3]
        --判断记录石信息是否存在
        if jlsinfo then
            --判断当前玩家是否处于战斗状态
            if getplaydef(play, "N$战斗状态") < os.time() then
                --是不是有足够的灵石
                if getbindmoney(play, "灵石") < 100 then
                    Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0500\'>灵石不足,无法传送...</font>","Type":9}')
                    return
                end
                consumebindmoney(play, "仙玉", 100)
                --传送玩家到记录石的位置
                mapmove(play, jlsinfo[2], jlsinfo[3], jlsinfo[4], 2)
                --向客户端发送消息，通知传送成功
                sendluamsg(play, 101, 13, 3, p3, "")
            else
                --向客户端发送消息，通知玩家处于战斗状态，无法传送
                sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>战斗状态无法使用...</font>","Type":9}' )
            end
        else
            --向客户端发送消息，通知记录石不存在
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>记录石不存在...</font>","Type":9}')
        end
    end
end
---实力提升
npc[17] = function(play, p2, p3, data) --实力提升
    if p2 == 0 then
        --实力提升  --初始化页面
        sendluamsg(play, 101, 17, 0, 0, "")
    end
end

---新手礼包
npc[18] = function(play, p2, p3, data) --新手礼包
    if p2 == 0 then
        --新手礼包  --初始化页面
        sendluamsg(play, 101, 18, 0, 0, "")
    elseif p2 == 1 then
        --领取礼包
        local rwid = getplaydef(play, VarCfg.U_zxrw[1])
        if rwid == 1 then
            Player.zxrw_wancheng(play, getplaydef(play, VarCfg.U_zxrw[1]), "新手礼包") --完成任务

            Player.rwjl(
                play,
                {{"复活戒指",1},{"麻痹戒指",1},{"斗笠",1},{"攻速之镰[lv1]",1}, {"切割之斧[lv1]",1},{ "盟重回城石", 1 }, { "随机传送石", 1 }, { "龙骨刀", 1 }, { "龙骨甲", 1 } },
                "新手礼包",
                nil
            )
            addbuff(play, 20000)
            addbuff(play, 20001)
            addbuff(play, 20002)
            Npclib["anniu"][19](play, 1, 0, "")

            --新手技能
            for _, v in pairs(constant.pz_xrjn) do
                addskill(play,v[1],v[2])
            end

            sendluamsg(play, 101, 1005, 0, 0, "lqcg")
            sendluamsg(play, 101, 18, 1, 0, "")
        else --已完成
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0500\'>已经领取过礼包了...</font>","Type":9}')
            return
        end
    end
end
function feijian(play, msgData) ---飞剑
    local msgdata = json2tbl(msgData)
    local mapid = getbaseinfo(play, 3)
    local monobj = getmonbyuserid(mapid, msgdata.paramList[1])
    local nvalue = 0
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_飞剑"])
    if monobj then
        if msgdata.paramList[2] == 1 then
            if getbaseinfo(play, 39) >= 1 or hasbuff(play, 20000) then
                nvalue = (nvalue + 500)
                    * (
                        1
                        + ((T_data.cd or hasbuff(play, 20002)) and 1 or 0)
                        + ((T_data.ratio or hasbuff(play, 20001)) and 1 or 0)
                    )
            else
                return
            end
        elseif msgdata.paramList[2] == 2 then
            if T_data.ratio or hasbuff(play, 20001) then
                nvalue = (nvalue + 1000)
            else
                return
            end
        elseif msgdata.paramList[2] == 3 then
            if T_data.cd or hasbuff(play, 20002) then
                nvalue = (nvalue + 5000)
            else
                return
            end
        elseif msgdata.paramList[2] == 4 then
            if T_data.num and T_data.num >= teshudata["anniu_19"].num then
                nvalue = (nvalue + 1000)
            else
                return
            end
        end
        nvalue = nvalue + ((T_data.num and T_data.num >= teshudata["anniu_19"].num) and 10000 or 0)

        local cd = (T_data.cd or (hasbuff(play, 20002) and teshudata["anniu_19"].cd / 2) or teshudata["anniu_19"].cd) - 0.1
        local time = os.time()
        if getplaydef(play, "N$飞剑_" .. msgdata.paramList[2]) + cd < time then
            setplaydef(play, "N$飞剑_" .. msgdata.paramList[2], time)
            humanhp(monobj, "-", nvalue, 107, 0, play, 1)
            healthspellchanged(monobj)
            T_data.num = (T_data.num or 0) + 1
            Player.setJsonVarByTable(play, VarCfg["T_飞剑"], T_data)
        else
            --sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>飞剑冷却中...</font>","FColor":219,"BColor":255,"Type":1}')
            return
        end
    end
end

npc[19] = function(play, p2, p3, data) --飞剑系统
    if p2 == 0 then
        --飞剑系统  --初始化页面
        local tmp_data = {}
        tmp_data["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_飞剑"])
        sendluamsg(play, 101, 19, 0, 0, tbl2json(tmp_data))
    elseif p2 == 1 then
        --飞剑系统激活飞剑--取消激活
        local T_data = Player.getJsonTableByVar(play, VarCfg["T_飞剑"])
        if T_data["open"] and T_data["open"] == 1 then
            Player.sendmsgEx(play, "飞剑已激活，无需重复激活...")
        else
            T_data["open"] = 1
            Player.setJsonVarByTable(play, VarCfg["T_飞剑"], T_data)

            local count = {}
            if getbaseinfo(play, 39) >= 1 or hasbuff(play, 20000) then
                count["1"] = 1
            end
            local T_data_cs = Player.getJsonTableByVar(play, VarCfg["T_首冲礼包"])
            if T_data_cs["首充"] == 1 or T_data_cs["补充"] == 1 or hasbuff(play, 20001) then
                count["2"] = 1
            end
            if getflagstatus(play, VarCfg.BS_mztq) == 1 or hasbuff(play, 20002) then
                count["3"] = 1
            end
            if T_data.num and T_data.num >= teshudata["anniu_19"].num then
                count["4"] = 1
            end

            sendluamsg(play, 101, 19, 1, 0, tbl2json({ count = count, psData = { cd = (T_data.cd or (hasbuff(play, 20002) and teshudata["anniu_19"].cd / 2) or teshudata["anniu_19"].cd), }, }))
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>飞剑已激活...</font>","Type":9}')
        end
    elseif p2 == 2 then --飞剑伤害计算
        feijian(play, data)
    elseif p2 == 3 then --飞剑取消
        local T_data = Player.getJsonTableByVar(play, VarCfg["T_飞剑"])
        if T_data["open"] and T_data["open"] == 1 then
            T_data["open"] = 0
            Player.setJsonVarByTable(play, VarCfg["T_飞剑"], T_data)
            sendluamsg(play, 101, 19, 1, 1, "")
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>飞剑已取消激活...</font>","Type":9}')
        end
    elseif p2 == 4 then --飞剑开关
        local T_data = Player.getJsonTableByVar(play, VarCfg["T_飞剑"])
        if T_data["open"] and T_data["open"] == 1 then
            Npclib['anniu'][19](play, 3, 0, "")
        else
            Npclib['anniu'][19](play, 1, 0, "")
        end

    end
end

npc[30] = function(play, p2, p3, data) --砍树系统
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    if not (jq_data["npc55"] and jq_data["npc55"] >= 2) then
        Player.sendmsgEx(play, "你还未开启相关剧情，暂无法使用#57")
        return
    end
    
    if p2 == 0 then
        --砍树系统  --初始化页面
        local tmp_data = {}
        tmp_data["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_砍树系统"])
        sendluamsg(play, 101, 30, 0, 0, tbl2json(tmp_data))
    elseif p2 == 1 then --升级
        local T_data = Player.getJsonTableByVar(play, VarCfg["T_砍树系统"])
        local config = teshudata["anniu_30"]
        if p3 == 1 then  --升级斧子
            T_data.axe = T_data.axe or 1
            if T_data.axe >= config.updata[1].max_level then
                Player.sendmsgEx(play, "斧子已满级，无需升级...")
                return
            end
            local name, num = Player.checkItemNumByTable(play, config.updata[1].details[T_data.axe].cost)
            if name then
                Player.sendmsgEx(play, string.format("你的|%s#249|不足|%d#249", name, num))
                return
            end
            Player.takeItemByTable(play, config.updata[1].details[T_data.axe].cost, ",砍树系统",nil)
            T_data.axe = T_data.axe + 1
            Player.setJsonVarByTable(play, VarCfg["T_砍树系统"], T_data)
            Player.sendmsgEx(play, "斧子升级成功，当前斧子等级为|"..T_data.axe.."#249|")
            sendluamsg(play, 101, 30, 2, 1, tbl2json({T_data = T_data}))

        elseif p3 == 2 then--升级自动升级
            T_data.auto = T_data.auto or 1
            if T_data.auto >= config.updata[2].max_level then
                Player.sendmsgEx(play, "自动砍树已满级，无需升级...")
                return
            end
            local name, num = Player.checkItemNumByTable(play, config.updata[2].details[T_data.auto].cost)
            if name then
                Player.sendmsgEx(play, string.format("你的|%s#249|不足|%d#249", name, num))
                return
            end
            Player.takeItemByTable(play, config.updata[2].details[T_data.auto].cost, ",砍树系统",nil)
            T_data.auto = T_data.auto + 1
            Player.setJsonVarByTable(play, VarCfg["T_砍树系统"], T_data)
            Player.sendmsgEx(play, "自动砍树升级成功，当前自动砍树等级为|"..T_data.auto.."#249|")
            sendluamsg(play, 101, 30, 2, 2, tbl2json({T_data = T_data}))
        end
    elseif p2 == 2 then --获得奖励
        local config = teshudata["anniu_30"]
        local T_data = Player.getJsonTableByVar(play, VarCfg["T_砍树系统"])
        T_data.axe = T_data.axe or 1
        T_data.num = T_data.num or 0

        if p3 == 1 then -- 打开页面时自动的奖励
            -- release_print("砍树系统自动奖励触发")
            -- release_print(os.time())
            -- release_print(getplaydef(play,"N$自动砍树") + config.updata[1].details[T_data.axe].ratio * config.updata[2].details[T_data.auto].ratio * config.base_time)
            if os.time() >= getplaydef(play,"N$自动砍树") + (config.updata[1].details[T_data.axe].ratio * config.updata[2].details[T_data.auto or 1].ratio * config.base_time) then
                local jl = ransjstr(config.updata[1].details[T_data.axe].jl, 1, 3)
                setplaydef(play,"N$自动砍树",os.time())
                T_data.num = T_data.num + 1
                Player.setJsonVarByTable(play, VarCfg["T_砍树系统"], T_data)
                sendluamsg(play, 101, 30, 1, 0, tbl2json({T_data = T_data}))
                Player.rwjl(play, {{jl,1}}, "砍树系统自动奖励", 1,0)
                sendluamsg(play, 101, 30, 3, 0, tbl2json({{jl,1}}))   
            else
                return
            end
        elseif p3 == 2 then -- 打开页面时手动点击的奖励
            local name, num = Player.checkItemNumByTable(play, config.click.cost)
            if name then
                Player.sendmsgEx(play, string.format("你的|%s#249|不足|%d#249", name, num))
                return
            end
            Player.takeItemByTable(play, config.click.cost, ",砍树系统",nil)

            T_data.num = T_data.num + 1
            Player.setJsonVarByTable(play, VarCfg["T_砍树系统"], T_data)
            sendluamsg(play, 101, 30, 1, 0, tbl2json({T_data = T_data}))

            local jl = ransjstr(config.updata[1].details[T_data.axe].jl, 1, 3)
            release_print("砍树系统奖励:",tbl2json(jl))
            Player.rwjl(play, {{jl,1}}, "砍树系统自动奖励", 1,0)
            sendluamsg(play, 101, 30, 3, 0, tbl2json({{jl,1}}))
        end
    elseif p2 == 3 then --定时器开关
        local T_data = Player.getJsonTableByVar(play, VarCfg["T_砍树系统"])
        if not (getplaydef(play,"N$自动砍树") == 1) or true then
            T_data.auto = T_data.auto or 1
            Player.setJsonVarByTable(play, VarCfg["T_砍树系统"], T_data)
            setontimer(play,7,60*20,0,1)
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>自动砍树已开启...</font>","Type":9}')
            setplaydef(play,"N$自动砍树",os.time())
            if p2 == 1 then
                local tmp_data = {}
                tmp_data["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_砍树系统"])
                sendluamsg(play, 101, 30, 0, 0, tbl2json(tmp_data))
            end
        -- else
        --     Player.setJsonVarByTable(play, VarCfg["T_砍树系统"], T_data)
        --     setofftimer(play,7)
        --     sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>自动砍树已关闭...</font>","Type":9}')
        --     setplaydef(play,"N$自动砍树",os.time())
        end
    elseif p2 == 4 then --兑换盲盒
        local config = teshudata["anniu_30"]
        local T_data = Player.getJsonTableByVar(play, VarCfg["T_砍树系统"])
        T_data.dh_num = T_data.dh_num or 1
        local name, num = Player.checkItemNumByTable(play, T_data.dh_num > #config.dh.details and config.dh.cost or config.dh.details[T_data.dh_num].cost)
        if name then
            Player.sendmsgEx(play, string.format("你的|%s#249|不足|%d#249", name, num))
            return
        end
        Player.takeItemByTable(play, T_data.dh_num > #config.dh.details and config.dh.cost or config.dh.details[T_data.dh_num].cost, ",砍树系统",nil)
        T_data.dh_num = T_data.dh_num + 1
        Player.setJsonVarByTable(play, VarCfg["T_砍树系统"], T_data)
        Player.rwjl(play, {{"砍树盲盒",1}}, "砍树系统盲盒兑换", 1,1000)
        sendluamsg(play, 101, 30, 4, 0, tbl2json({T_data = T_data}))
    end
end
---首充礼包
npc[501] = function(play, p2, p3, data) --首充礼包
    if p2 == 0 then
        local tmp_data = {}
        tmp_data["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_首冲礼包"])
        tmp_data["time_data"] = getsysvar(VarCfg["G_开区天数"])
        sendluamsg(play, 101, 501, 0, 0, tbl2json(tmp_data))
    elseif p2 == 1 then
        local cfg = teshudata["anniu_501"]
        local T_data = Player.getJsonTableByVar(play, VarCfg["T_首冲礼包"])
        local time_data = getsysvar(VarCfg["G_开区天数"])
        if not (T_data["ok"] and T_data["ok"] == 1) then
            if cfg and cfg.endtime and cfg.endtime < time_data then
                sendluamsg(play, 101, 999, 3, 21, "")
            else
                sendluamsg(play, 101, 999, 6, 21, "")
            end
            return
        end

        local endtime = cfg and cfg.endtime or 0
        if T_data["首充"] == 1 and time_data <= endtime then
            local list = cfg and cfg.details and cfg.details["首充"] or {}
            local max = #list
            if max <= 0 then
                Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0500\'>礼包配置异常...</font>","Type":9}')
                return
            end
            if not T_data["buy_day"] then
                T_data["buy_day"] = time_data
            end
            local idx = (time_data - (T_data["buy_day"] or time_data)) + 1
            if idx < 1 then idx = 1 end
            if idx > max then
                Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0500\'>首充礼包已领取...</font>","Type":9}')
                return
            end
            if T_data["jq_time"] and T_data["jq_time"] == time_data then
                Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0500\'>今日已领取...</font>","Type":9}')
                return
            end
            T_data["other_lb"] = idx
            T_data["jq_time"] = time_data
            Player.setJsonVarByTable(play, VarCfg["T_首冲礼包"], T_data)

            local reward = list[idx]
            if reward and #reward > 0 then
                Player.rwjl(play, reward, "首充礼包", 1, 1000)
            end
            if idx == 1 then
                addskill(play, 25, 3)
                local T_data_fj = Player.getJsonTableByVar(play, VarCfg["T_飞剑"])
                T_data_fj.ratio = 2
                Player.setJsonVarByTable(play, VarCfg["T_飞剑"], T_data_fj)
            end

            sendluamsg(play, 101, 1005, 0, 0, "lqcg")
            return
        end

        if T_data["补充"] == 1 and time_data > endtime then
            local list = cfg and cfg.details and cfg.details["补充"] or {}
            if not list or #list <= 0 then
                Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0500\'>礼包配置异常...</font>","Type":9}')
                return
            end
            if T_data["bc_ok"] == 1 then
                Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0500\'>首充礼包已领取...</font>","Type":9}')
                return
            end
            T_data["bc_ok"] = 1
            T_data["jq_time"] = time_data
            Player.setJsonVarByTable(play, VarCfg["T_首冲礼包"], T_data)

            local reward = list[1]
            if reward and #reward > 0 then
                Player.rwjl(play, reward, "首充补充礼包", 1, 1000)
            end
            addskill(play, 25, 3)
            local T_data_fj = Player.getJsonTableByVar(play, VarCfg["T_飞剑"])
            T_data_fj.ratio = 2
            Player.setJsonVarByTable(play, VarCfg["T_飞剑"], T_data_fj)
            
            sendluamsg(play, 101, 1005, 0, 0, "lqcg")
            return
        end

        Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0500\'>未满足领取条件...</font>","Type":9}')
    end
end
---在线充值
npc[502] = function(play, p2, p3, data) --在线充值
    if p3 == 0 then
        sendluamsg(play, 101, 502, 0, 0, getplaydef(play, VarCfg.T_czlb))
    elseif p3 == 2 then
        local je = tonumber(data)
        if je and constant.cz_jeyz[je] then
            local czlb = json2tbl(getplaydef(play, VarCfg.T_czlb))
            if type(czlb) ~= "table" then
                czlb = {}
            end
            if not czlb["cz502_" .. tostring(je)] and querymoney(play, 22) >= je then
                changemoney(play, 22, "-", je, "礼包积分", true)
                czlb = _cz502_apply_reward(play, je, nil, czlb)
                setplaydef(play, VarCfg.T_czlb, tbl2json(czlb))
                sendluamsg(play, 101, 502, 0, 0, getplaydef(play, VarCfg.T_czlb))
            else
                setplaydef(play, VarCfg.U_czyz, constant.cz_jeyz[je])
                sendluamsg(play, 101, 999, je, 7, "")
            end
        end
    elseif p3 == 3 then
        local je = tonumber(data)
        if je and je >= 10 then
            setplaydef(play, VarCfg.U_czyz, 0)
            sendluamsg(play, 101, 999, je, 7, "")
        else
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0500\'>充值金额不得小于10元...</font>","Type":9}')
        end
    elseif p3 == 4 then
        local json = json2tbl(getplaydef(play, VarCfg.T_czlb))
        if json.cz4 then
            if json.jskg then
                json.jskg = nil
                Buff[71](play, 2)
                sendmsg(play, 1, '{"Msg":"<font color=\'#ff0500\'>溅射功能已关闭...</font>","Type":9}')
            else
                Buff[71](play, 1)
                json.jskg = true
                sendmsg(play, 1, '{"Msg":"<font color=\'#28ef01\'>溅射功能已开启...</font>","Type":9}')
            end
            setplaydef(play, VarCfg.T_czlb, tbl2json(json))
        end
    end
end
---快人一步
npc[504] = function(play, p2, p3, data) --快人一步
    if p2 == 0 then
        sendluamsg(play, 101, 504, 0, 0, '{"mztq":' .. getflagstatus(play, VarCfg.BS_mztq) .. "}")
    elseif p2 == 1 then
        if getflagstatus(play, VarCfg.BS_mztq) == 0 then
            sendluamsg(play, 101, 999, 88, 21, "")
        else
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>每人只能购买一次</font>","Type":9}')
        end
    end
end
---自动巡航
npc[505] = function(play, p2, p3, data) --自动巡航
    if p2 == 0 then
        sendluamsg(play, 101, 505, 0, 0, "")
    elseif p2 == 1 then
        sendluamsg(play, 101, 505, 1, 0, getplaydef(play, VarCfg.T_aigj))
    elseif p2 == 2 then
        local dtmz = getbaseinfo(play, 3)
        if jinzhigj[dtmz] or string.find(dtmz, "_") then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff7700\'>[自动巡航]</font><font color=\'#ff0000\'>当前地图,无法记录...</font>","Type":9}')
        elseif checkkuafu(play) then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff7700\'>[自动巡航]</font><font color=\'#ff0000\'>跨服地图,无法记录...</font>","Type":9}')
        else
            local json = json2tbl(getplaydef(play, VarCfg.T_aigj))
            json["dt" .. p3] = getbaseinfo(play, 45)
            json["dtid" .. p3] = dtmz
            sendluamsg(play, 101, 505, 2, p3, getbaseinfo(play, 45))
            setplaydef(play, VarCfg.T_aigj, tbl2json(json))
        end
    elseif p2 == 3 then
        local json = json2tbl(getplaydef(play, VarCfg.T_aigj))
        if json["fgx" .. p3] then
            json["fgx" .. p3] = nil
        elseif json["dtid" .. p3] then
            json["fgx" .. p3] = true
        else
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff7700\'>[自动巡航]</font><font color=\'#ff0500\'>当前未记录地图,无法勾选...</font>","Type":9}')
        end
        setplaydef(play, VarCfg.T_aigj, tbl2json(json))
        sendluamsg(play, 101, 505, 3, p3, getplaydef(play, VarCfg.T_aigj))
    elseif p2 == 4 then
        local json = json2tbl(getplaydef(play, VarCfg.T_aigj))
        if getflagstatus(play, VarCfg.BS_AIgj) == 0 then
            local yz = 0
            for i = 1, 10, 1 do
                if json["fgx" .. i] then
                    yz = 1
                    break
                end
            end
            if yz == 1 then
                startautoattack(play)
                setflagstatus(play, VarCfg.BS_AIgj, 1)
                json.gjkg = true
                setplaydef(play, VarCfg.N_Aigj[5], os.time())
            else
                sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[自动巡航]</font><font color=\'#ff0500\'>未勾选任何地图,无法进行AI挂机...</font>","Type":9}' )
            end
        else
            json.gjkg = nil
            stopautoattack(play)
            setflagstatus(play, VarCfg.BS_AIgj, 0)
        end
        setplaydef(play, VarCfg.T_aigj, tbl2json(json))
        sendluamsg(play, 101, 505, 4, 0, tbl2json(json))
    elseif p2 == 5 then
        local json = json2tbl(getplaydef(play, VarCfg.T_aigj))
        if p3 == 1 then
            if json.zgx1 then
                json.zgx1 = nil
                Buff[72](play, 2)
            else
                Buff[72](play, 1)
                json.zgx1 = true
            end
        else
            if json["zgx" .. p3] then
                json["zgx" .. p3] = nil
            else
                json["zgx" .. p3] = true
            end
        end
        setplaydef(play, VarCfg.T_aigj, tbl2json(json))
    end
end
---天选之人
npc[506] = function(play, p2, p3, msgData) --天选之子
    if p2 == 0 then
        sendluamsg(play, 101, 506, 0, 0, '{"A_txzz":' .. (getsysvar(VarCfg["A_天选之人json"]) == "" and "{}" or getsysvar(VarCfg["A_天选之人json"])) .. ',"T_txzr":' .. getplaydef(play, VarCfg.T_txzr) .. ',"kqsj":' .. getsysvar(VarCfg["G_开区分钟"]) .. ',"G_txzz_2":' .. getsysvar(VarCfg["G_天选之人"][2]) .. "}")
    end
end

local hd_dtmz = {}

npc[507] = function(play, p2, p3, msgData) --游戏活动
    if p2 == 0 then
        sendluamsg(play, 101, 507, 0, 0, '{"kqfz":' .. getsysvar(VarCfg["G_开区分钟"]) .. ',"hdjl":' .. getplaydef(play, VarCfg.T_hdjl) .. "}")
    elseif p2 == 1 then
        if p3 == 1 then
            Npclib["anniu"][506](play, 0, 0, "")
        elseif p3 == 2 then
            map(play, "xtc")
        elseif p3 == 3 then
            map(play, "天降财宝")
        elseif p3 == 4 then
            map(play, "比武大会")
        end
    end
end

---天天省钱
npc[509] = function(play, p2, p3, msgData)
    openhyperlink(play, 111, 0)
end
---交易行
npc[510] = function(play, p2, p3, msgData)
    openhyperlink(play, 35, 0)
end

-- 福利大厅七日登录读取配置
local fldt_cfg_table = teshudata["fldt"] and teshudata["fldt"]["fldt_cfg"]
local fldt_seven_login_cfg = (fldt_cfg_table and fldt_cfg_table["seven_login"]) or {}
local fldt_online_minutes_limit = fldt_seven_login_cfg.online_limit or 10
local fldt_digit_cfg = fldt_seven_login_cfg.digit or {}
local fldt_privilege_no_zero = fldt_seven_login_cfg.privilege_no_zero ~= false
local fldt_privilege_final_multiple = fldt_seven_login_cfg.privilege_final_multiple or 2

-- 是否拥有麦尊特权（用于所有特权判断）
local function fldt_is_privilege(play)
    return getflagstatus(play, VarCfg.BS_mztq) == 1
end

-- 根据配置生成当日翻牌数字，并处理特权玩家的避零逻辑
local function fldt_pick_seven_login_digit(day, privilege)
    local cfg = fldt_digit_cfg[day] or {}
    local minv = cfg.min or 0
    local maxv = cfg.max or 9
    local pool = cfg.pool
    local digit
    if pool and #pool > 0 then
        digit = pool[math.random(1, #pool)]
    else
        digit = math.random(minv, maxv)
    end
    if privilege and fldt_privilege_no_zero and digit == 0 then
        if pool and #pool > 0 then
            local filtered = {}
            for _, v in ipairs(pool) do
                if v ~= 0 then
                    table.insert(filtered, v)
                end
            end
            if #filtered > 0 then
                digit = filtered[math.random(1, #filtered)]
            else
                digit = 1
            end
        else
            if maxv == minv then
                digit = (minv == 0) and 1 or minv
            else
                local attempts = 0
                repeat
                    digit = math.random(minv, maxv)
                    attempts = attempts + 1
                    if attempts > 20 then
                        digit = (minv == 0) and 1 or minv
                        break
                    end
                until digit ~= 0
            end
        end
    end
    return digit
end

-- 获取/初始化翻牌记录表，用于保存七天的各位数
local function fldt_prepare_flip_table(T_qrbq)
    if type(T_qrbq["7rqd_fp"]) ~= "table" then
        T_qrbq["7rqd_fp"] = {}
    end
    return T_qrbq["7rqd_fp"]
end

-- 将记录表中个位~百万位拼成最终元宝数
local function fldt_calculate_flip_reward(fp)
    local total = 0
    if type(fp) ~= "table" then
        return total
    end
    for i = 1, 7 do
        local value = fp[i]
        if value == nil then
            value = fp[tostring(i)]
        end
        total = total + (tonumber(value) or 0) * (10 ^ (i - 1))
    end
    return total
end
npc[511] = function(play, p2, p3, msgData) --福利大厅
    -- p2 用于区分界面打开(0)、奖励领取(1)及数据下发(2)
    -- p3 则在 p2==1/2 时作为具体子功能编号（1=七日登录、2=在线奖励、3=杀怪等）
    if p2 == 0 then
        local data = {}
        data["T_qrbq"] = Player.getJsonTableByVar(play, VarCfg.T_qrbq)
        data["U_dlts"] = getplaydef(play, VarCfg["U_登录天数"])
        data["J_zxsj"] = getplaydef(play, VarCfg.J_zxsj)
        data["U_sgsl"] = getplaydef(play, VarCfg.J_jsgw[1]) + getplaydef(play, VarCfg.J_jsgw[2])
        sendluamsg(play, 101, 511, 0, 0, tbl2json(data))
    elseif p2 == 1 then
        -- 福利大厅任务进度存放在玩家 T_qrbq 变量中，包含七日登录/在线/杀怪等字段
        local T_qrbq = Player.getJsonTableByVar(play, VarCfg.T_qrbq)
        if p3 == 1 then --七日登录
            local jsonData = json2tbl(msgData) or {}
            local requestDay = tonumber(jsonData["7rqd"]) or 0
            local loginDays = tonumber(getplaydef(play, VarCfg["U_登录天数"])) or 0
            if requestDay > loginDays then
                Player.sendmsgEx(play, "登录天数不足#57")
                return
            end
            local claimed = tonumber(T_qrbq["7rqd"]) or 0
            local targetDay = claimed + 1
            if targetDay > requestDay then
                Player.sendmsgEx(play, "已经领取完毕#57")
                return
            end
            if targetDay ~= requestDay then
                Player.sendmsgEx(play, "请按照顺序领取#57")
                return
            end
            if requestDay <= 0 or requestDay > 7 then
                Player.sendmsgEx(play, "七日登录奖励已经全部领取完毕#57")
                return
            end
            local onlineMinutes = tonumber(getplaydef(play, VarCfg.J_zxsj)) or 0
            if onlineMinutes < fldt_online_minutes_limit then
                Player.sendmsgEx(play, "在线满" .. fldt_online_minutes_limit .. "分钟后可领取#57")
                return
            end
            local dayReward = teshudata["fldt"]["7rqd"][targetDay]
            if not dayReward then
                Player.sendmsgEx(play, "奖励配置缺失#57")
                return
            end
            local privilege = fldt_is_privilege(play)
            local flipDigits = fldt_prepare_flip_table(T_qrbq)
            local digit = fldt_pick_seven_login_digit(targetDay, privilege)
            flipDigits[targetDay] = digit
            T_qrbq["7rqd"] = targetDay
            local finalAwardToGive = 0
            if targetDay == 7 then
                local finalSum = fldt_calculate_flip_reward(flipDigits)
                T_qrbq["7rqd_final_yb"] = finalSum
                local finalMultiple = privilege and fldt_privilege_final_multiple or 1
                T_qrbq["7rqd_final_mul"] = finalMultiple
                local awardValue = math.floor((finalSum or 0) * finalMultiple)
                if awardValue < 0 then
                    awardValue = 0
                end
                T_qrbq["7rqd_final_award"] = awardValue
                if T_qrbq["7rqd_final_awarded"] ~= 1 then
                    T_qrbq["7rqd_final_awarded"] = 1
                    finalAwardToGive = awardValue
                end
            end
            Player.setJsonVarByTable(play, VarCfg.T_qrbq, T_qrbq)
            sendmail(getbaseinfo(play,2),0,"七日登录奖励","七日登录奖励,奖励已下发!",Player.jl_mail(dayReward.jl))


            if finalAwardToGive > 0 then
                Player.rwjl(play, { { "绑定元宝", finalAwardToGive } }, "七日翻牌幸运奖励", 1)
            end
            sendluamsg(play, 101, 511, 1, 1, tbl2json(T_qrbq))
        elseif p3 == 2 then --在线奖励
            -- 累计在线分钟数存储在 VarCfg.J_zxsj，对应配置 teshudata["fldt"]["zxjl"]
            local jsonData = json2tbl(msgData)
            T_qrbq["zxjl"] = T_qrbq["zxjl"] or 0
            T_qrbq["zxjl"] = T_qrbq["zxjl"] + 1
            if teshudata["fldt"]["zxjl"][T_qrbq["zxjl"]].time > getplaydef(play, VarCfg.J_zxsj) then
                Player.sendmsgEx(play, "在线时间不足#57")
                return
            elseif T_qrbq["zxjl"] > jsonData["zxjl"] then
                Player.sendmsgEx(play, "已经领取完毕#57")
                return
            end
            if T_qrbq["zxjl"] == jsonData["zxjl"] then
                if jsonData["zxjl"] <= #teshudata["fldt"]["zxjl"] then
                    Player.setJsonVarByTable(play, VarCfg.T_qrbq, T_qrbq)
                    Player.rwjl(play, teshudata["fldt"]["zxjl"][T_qrbq["zxjl"]].jl, "在线奖励", 1)
                    sendluamsg(play, 101, 511, 1, 1, tbl2json(T_qrbq))
                else
                    Player.sendmsgEx(play, "在线奖励已经全部领取完毕#57")
                end
            else
                Player.sendmsgEx(play, "请按照顺序领取#57")
            end
        elseif p3 == 3 then --杀怪奖励
            -- VarCfg.U_fldt[2] 记录玩家今日杀怪量，对应 teshudata["fldt"]["sgjl"] 的领取进度
            local jsonData = json2tbl(msgData) or {}
            T_qrbq["sgjl"] = T_qrbq["sgjl"] or 0
            T_qrbq["sgjl"] = T_qrbq["sgjl"] + 1
            if teshudata["fldt"]["sgjl"][T_qrbq["sgjl"]].num > getplaydef(play, VarCfg.J_jsgw[1]) + getplaydef(play, VarCfg.J_jsgw[2]) then
                Player.sendmsgEx(play, "杀怪数量不足#57")
                return
            elseif T_qrbq["sgjl"] > jsonData["sgjl"] then
                Player.sendmsgEx(play, "已经领取完毕#57")
                return
            end
            if T_qrbq["sgjl"] == jsonData["sgjl"] then
                if jsonData["sgjl"] <= #teshudata["fldt"]["sgjl"] then
                    Player.setJsonVarByTable(play, VarCfg.T_qrbq, T_qrbq)
                    Player.rwjl(play, teshudata["fldt"]["sgjl"][T_qrbq["sgjl"]].jl, "杀怪奖励", 1)
                    sendluamsg(play, 101, 511, 1, 1, tbl2json(T_qrbq))
                else
                    Player.sendmsgEx(play, "杀怪奖励已经全部领取完毕#57")
                end
            else
                Player.sendmsgEx(play, "请按照顺序领取#57")
            end
        elseif p3 == 4 then --个人首杀
            -- T_grss 保存个人首杀任务状态：1=已完成待领，2=已领取，键为怪物ID
            local jsonData = json2tbl(msgData) or {}
            local T_grss = Player.getJsonTableByVar(play, VarCfg.T_grss)
            if tonumber(jsonData["isall"]) == 1 then
                if type(T_grss) ~= "table" then
                    T_grss = {}
                end
                local rewardCfg = teshudata["fldt"] and teshudata["fldt"]["grss"] or {}
                local rewardList = {}
                for key, status in pairs(T_grss) do
                    if status == 1 then
                        local index = tonumber(key)
                        local cfg = index and rewardCfg[index]
                        if cfg then
                            T_grss[key] = 2
                            rewardList[#rewardList + 1] = cfg.give
                        end
                    end
                end
                if #rewardList > 0 then
                    Player.setJsonVarByTable(play, VarCfg.T_grss, T_grss)
                    sendluamsg(play, 101, 511, 2, 4, tbl2json(T_grss))
                    for _, give in ipairs(rewardList) do
                        Player.rwjl(play, give, "个人首杀奖励", 1, 0)
                    end
                else
                    Player.sendmsgEx(play, "未完成该首杀任务#57")
                end
                return
            end
            if T_grss[jsonData["grss"]] and T_grss[jsonData["grss"]] == 2 then
                Player.sendmsgEx(play, "该首杀奖励已经领取完毕#57")
                return
            end
            if T_grss[jsonData["grss"]] and T_grss[jsonData["grss"]] == 1 then
                T_grss[jsonData["grss"]] = 2
                Player.setJsonVarByTable(play, VarCfg.T_grss, T_grss)
                Player.rwjl(
                    play,
                    teshudata["fldt"]["grss"][tonumber(jsonData["grss"])].give,
                    "个人首杀奖励",
                    1,
                    0
                )
                sendluamsg(play, 101, 511, 2, 4, tbl2json(T_grss))
            else --未完成
                Player.sendmsgEx(play, "未完成该首杀任务#57")
                return
            end
        elseif p3 == 5 then --个人首爆
            -- T_grsb 结构与首杀类似，表示个人首爆奖励的完成/领取状态
            local jsonData = json2tbl(msgData) or {}
            local T_grsb = Player.getJsonTableByVar(play, VarCfg.T_grsb)
            if tonumber(jsonData["isall"]) == 1 then
                if type(T_grsb) ~= "table" then
                    T_grsb = {}
                end
                local rewardCfg = teshudata["fldt"] and teshudata["fldt"]["grsb"] or {}
                local rewardList = {}
                for key, status in pairs(T_grsb) do
                    if status == 1 then
                        local index = tonumber(key)
                        local cfg = index and rewardCfg[index]
                        if cfg then
                            T_grsb[key] = 2
                            rewardList[#rewardList + 1] = cfg.give
                        end
                    end
                end
                if #rewardList > 0 then
                    Player.setJsonVarByTable(play, VarCfg.T_grsb, T_grsb)
                    sendluamsg(play, 101, 511, 2, 5, tbl2json(T_grsb))
                    for _, give in ipairs(rewardList) do
                        Player.rwjl(play, give, "个人首爆奖励", 1, 0)
                    end
                else
                    Player.sendmsgEx(play, "未完成该首爆任务#57")
                end
                return
            end
            if T_grsb[jsonData["grsb"]] and T_grsb[jsonData["grsb"]] == 2 then
                Player.sendmsgEx(play, "该首爆奖励已经领取完毕#57")
                return
            end
            if T_grsb[jsonData["grsb"]] and T_grsb[jsonData["grsb"]] == 1 then
                T_grsb[jsonData["grsb"]] = 2
                Player.setJsonVarByTable(play, VarCfg.T_grsb, T_grsb)
                Player.rwjl(
                    play,
                    teshudata["fldt"]["grsb"][tonumber(jsonData["grsb"])].give,
                    "个人首爆奖励",
                    1,
                    0
                )
                sendluamsg(play, 101, 511, 2, 5, tbl2json(T_grsb))
            else --未完成
                Player.sendmsgEx(play, "未完成该首爆任务#57")
                return
            end
        elseif p3 == 6 then --全区首曝
            -- A_全区首曝json 为全局变量，需要以 nil actor 读取，逻辑与个人首爆一致但作用于全服
            local jsonData = json2tbl(msgData) or {}
            local qqsb = Player.getJsonTableByVar(nil, VarCfg["A_全区首曝json"])
            if tonumber(jsonData["isall"]) == 1 then
                if type(qqsb) ~= "table" then
                    qqsb = {}
                end
                local rewardCfg = teshudata["fldt"] and teshudata["fldt"]["qqsb"] or {}
                local rewardList = {}
                for key, status in pairs(qqsb) do
                    if status == 1 then
                        local index = tonumber(key)
                        local cfg = index and rewardCfg[index]
                        if cfg then
                            qqsb[key] = 2
                            rewardList[#rewardList + 1] = cfg.give
                        end
                    end
                end
                if #rewardList > 0 then
                    Player.setJsonVarByTable(nil, VarCfg["A_全区首曝json"], qqsb)
                    sendluamsg(play, 101, 511, 2, 6, tbl2json(qqsb))
                    for _, give in ipairs(rewardList) do
                        Player.rwjl(play, give, "全区首曝奖励", 1, 0)
                    end
                else
                    Player.sendmsgEx(play, "未完成该首曝任务#57")
                end
                return
            end
            if qqsb[jsonData["qqsb"]] and qqsb[jsonData["qqsb"]] == 2 then
                Player.sendmsgEx(play, "该首爆奖励已经领取完毕#57")
                return
            end
            if qqsb[jsonData["qqsb"]] and qqsb[jsonData["qqsb"]] == 1 then
                qqsb[jsonData["qqsb"]] = 2
                Player.setJsonVarByTable(nil, VarCfg["A_全区首曝json"], qqsb)
                Player.rwjl(
                    play,
                    teshudata["fldt"]["qqsb"][tonumber(jsonData["qqsb"])].give,
                    "全区首爆奖励",
                    1,
                    0
                )
                sendluamsg(play, 101, 511, 2, 6, tbl2json(qqsb))
            else --未完成
                Player.sendmsgEx(play, "未完成该首爆任务#57")
                return
            end
        end
    elseif p2 == 2 then
        if p3 == 4 then --个人首杀
            local T_grss = Player.getJsonTableByVar(play, VarCfg.T_grss)
            sendluamsg(play, 101, 511, 2, 4, tbl2json(T_grss))
        elseif p3 == 5 then
            local T_grsb = Player.getJsonTableByVar(play, VarCfg.T_grsb)
            sendluamsg(play, 101, 511, 2, 5, tbl2json(T_grsb))
        elseif p3 == 6 then
            local data = Player.getJsonTableByVar(nil, VarCfg["A_全区首曝json"])
            sendluamsg(play, 101, 511, 2, 6, tbl2json(data))
        end
    end
end

npc[512] = function(play, p2, p3, msgData) --游戏攻略
    if p2 == 0 then
        sendluamsg(play, 101, 512, 0, 0, "")
    end
end

npc[513] = function(play, p2, p3, msgData) --狂暴
    if p2 == 0 then
        sendluamsg(play, 100, 15, 0, 0, "")
    end
end
npc[514] = function(play, p2, p3, msgData) --世界地图
    if p2 == 0 then
        sendluamsg(play, 101, 514, 0, 0, "")
    end
end
npc[515] = function(play, p2, p3, msgData) --仙途奇缘（成就）
    if p2 == 0 then
        local data = {}
        data["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_仙途奇缘"])
        sendluamsg(play, 101, 515, 0, 0, tbl2json(data))
    end
end
--免费赞助
npc[516] = function(play, p2, p3, msgData) --免费赞助
    local function DeleteAllTitle(actor)
        for index, value in ipairs(teshudata["anniu_516"].details) do
            deprivetitle(actor, value.ch)
        end
    end

    if p2 == 0 then
        local data = {}
        data["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_免费赞助"])
        data["sgsl"] = getplaydef(play, VarCfg.U_fldt[2])
        sendluamsg(play, 101, 516, 0, 0, tbl2json(data))
    elseif p2 == 1 then
        local T_data = Player.getJsonTableByVar(play, VarCfg["T_免费赞助"])
        local config = Guard.getConfig("anniu_516").details[p3]
        if not T_data["zzlb_" .. p3] then
            if p3 > 1 then
                if not T_data["zzlb_" .. (p3 - 1)] then
                    Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff7700\'>[赞助礼包]</font><font color=\'#ff0500\'>请先领取前置礼包...</font>","Type":9}')
                    return
                end
            end
            if getplaydef(play, VarCfg.U_fldt[2]) >= config.sgsl then
                T_data["zzlb_" .. p3] = 1
                Player.setJsonVarByTable(play, VarCfg["T_免费赞助"], T_data)
                Player.zxrw_wancheng(play, rwcf[516][1], "任务") --完成任务
                DeleteAllTitle(play)
                Player.title_give(play, config.ch)
                sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[赞助礼包]</font><font color=\'#28ef01\'>领取成功...</font>","Type":9}' )
                sendluamsg(play, 101, 516, 1, p3, "")
            else
                sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[赞助礼包]</font><font color=\'#ff0500\'>当前杀怪数量不足,无法领取...</font>","Type":9}' )
                return
            end
        else
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff7700\'>[赞助礼包]</font><font color=\'#ff0500\'>已经领取过礼包了...</font>","Type":9}')
        end
    end
end
--聚宝盆
npc[517] = function(play, p2, p3, msgData) --聚宝盆
    if p2 == 0 then
        local data = {}
        data["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_聚宝盆"])
        data["T_data"].level = data["T_data"].level or 1
        data["jf"] = getplaydef(play, VarCfg["U_聚宝盆积分"])
        data["cs"] = getplaydef(play, VarCfg["J_聚宝盆领取次数"])
        sendluamsg(play, 101, 517, 0, 0, tbl2json(data))
    elseif p2 == 1 then
        -- 聚宝盆升级
        local T_data = Player.getJsonTableByVar(play, VarCfg["T_聚宝盆"])
        T_data.level = T_data.level or 1
        if T_data.level == 1 then
            local T_sc_data = Player.getJsonTableByVar(play, VarCfg["T_首冲礼包"])
            if T_sc_data["首充"] == 1 or T_sc_data["补充"] == 1 then
                T_data.level = 2
                Player.setJsonVarByTable(play, VarCfg["T_聚宝盆"], T_data)
                sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[聚宝盆]</font><font color=\'#28ef01\'>升级成功...</font>","Type":9}' )
                sendluamsg(play, 101, 517, 1, 2, "")
            else
                sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[聚宝盆]</font><font color=\'#ff0500\'>只有首充或补充过首充才可升级聚宝盆...</font>","Type":9}' )
                return
            end
        elseif T_data.level == 2 then
            if getflagstatus(play, VarCfg.BS_mztq) == 1 then
                T_data.level = 3
                Player.setJsonVarByTable(play, VarCfg["T_聚宝盆"], T_data)
                sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[聚宝盆]</font><font color=\'#28ef01\'>升级成功...</font>","Type":9}' )
                sendluamsg(play, 101, 517, 1, 3, "")
            else
                sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[聚宝盆]</font><font color=\'#ff0500\'>未激活【解绑特权】,无法升级聚宝盆...</font>","Type":9}' )
                return
            end
        elseif T_data.level == 3 then --累计充值 200
            if querymoney(play, 23) >= 200 then
                T_data.level = 4
                Player.setJsonVarByTable(play, VarCfg["T_聚宝盆"], T_data)
                sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[聚宝盆]</font><font color=\'#28ef01\'>升级成功...</font>","Type":9}' )
                sendluamsg(play, 101, 517, 1, 4, "")
            else
                sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[聚宝盆]</font><font color=\'#ff0500\'>累计充值200元才能升级聚宝盆...</font>","Type":9}' )
                return
            end
        elseif T_data.level == 4 then --累计充值 300
            if querymoney(play, 23) >= 300 then
                T_data.level = 5
                Player.setJsonVarByTable(play, VarCfg["T_聚宝盆"], T_data)
                sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[聚宝盆]</font><font color=\'#28ef01\'>升级成功...</font>","Type":9}' )
                sendluamsg(play, 101, 517, 1, 5, "")
            else
                sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[聚宝盆]</font><font color=\'#ff0500\'>累计充值300元才能升级聚宝盆...</font>","Type":9}' )
                return
            end
        elseif T_data.level == 5 then --满级
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff7700\'>[聚宝盆]</font><font color=\'#ff0500\'>聚宝盆已经满级...</font>","Type":9}')
            return
        end
    elseif p2 == 2 then -- 聚宝盆领取奖励
        local T_data = Player.getJsonTableByVar(play, VarCfg["T_聚宝盆"])
        T_data.level = T_data.level or 1
        local config = Guard.getConfig("anniu_517").details[T_data.level]
        local jf = getplaydef(play, VarCfg["U_聚宝盆积分"])
        local cs = getplaydef(play, VarCfg["J_聚宝盆领取次数"])
        if cs < config.maxcs then
            if jf >= config.jf then
                setplaydef(play, VarCfg["U_聚宝盆积分"], 0)
                setplaydef(play, VarCfg["J_聚宝盆领取次数"], cs + 1)
                Player.rwjl(play, config.give, "聚宝盆奖励", 1)
                sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[聚宝盆]</font><font color=\'#28ef01\'>领取成功...</font>","Type":9}' )
                sendluamsg(play, 101, 517, 2, 0, "")
            else
                sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[聚宝盆]</font><font color=\'#ff0500\'>积分不足,无法领取奖励...</font>","Type":9}' )
                return
            end
        else
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff7700\'>[聚宝盆]</font><font color=\'#ff0500\'>当前等级领取次数已达上限...</font>","Type":9}')
            return
        end
    end
end

local xlxl =
    { { 1, 2, 3, 4, 7, 8, 23, 22, 24, 25, 26 }, constant.cz_je, { 98, 6, 3 } }
npc[998] = function(play, p2, p3, msg) --后台
    local qfmz = getconst(play, "<$SERVERNAME>")
    if getplaydef(play, VarCfg.S_houtaibf) ~= "" or (qfmz == "" or qfmz == "测试区") then
        if getplaydef(play, VarCfg.S_houtaibf) == "" and (qfmz == "" or qfmz == "测试区") then
            setplaydef(play, VarCfg.S_houtaibf, "本地测试区")
        end
        if p2 == 1 then
            if p3 == 0 then
                if getplayerbyname(msg) then
                    Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#00ff00\'>[' .. msg .. ']玩家在线</font>","Type":9}')
                else
                    Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0000\'>[' .. msg .. ']玩家不在线</font>","Type":9}')
                end
            elseif p3 == 1 then
                local data = json2tbl(msg)
                if data and data.mz and data.hb and data.hb > 0 and data.hb < 9 then
                    local dx = getplayerbyname(data.mz)
                    if dx then
                        Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#00ff00\'>[' .. data.mz .. "]货币剩余：" .. querymoney(dx, xlxl[1][data.hb]) .. '</font>","Type":9}')
                    else
                        Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0000\'>[' .. data.mz .. ']玩家不在线</font>","Type":9}')
                    end
                end
            elseif p3 == 2 or p3 == 3 then
                local data = json2tbl(msg)
                if data and data.mz and data.hb and data.hb > 0 and data.hb < 12 and data.sl then
                    local dx = getplayerbyname(data.mz)
                    if dx then
                        local hbid = xlxl[1][data.hb]
                        if p3 == 2 then
                            changemoney(dx, hbid, "=", data.sl, "后台", true)
                            Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#00ff00\'>[' .. data.mz .. "]货币数量修改为[" .. data.sl .. ']</font>","Type":9}')
                        else
                            changemoney(dx, hbid, "+", data.sl, "后台", true)
                            Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#00ff00\'>[' .. data.mz .. "]增加[" .. data.sl .. "]当前货币剩余：" .. querymoney(dx, xlxl[1][data.hb]) .. '</font>","Type":9}')
                        end
                    else
                        Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0000\'>[' .. data.mz .. ']玩家不在线</font>","Type":9}')
                    end
                end
            elseif p3 == 4 then
                local data = json2tbl(msg)
                if data and data.mz and data.hb and data.hb > 0 and data.hb < 11 then
                    local dx, sy = getplayerbyname(data.mz), data.hb
                    if dx then
                        setplaydef(dx, VarCfg.U_czyz, data.hb)
                        changemoney(dx, 7, "+", xlxl[2][data.hb] * 100, "", true)
                        recharge(dx, xlxl[2][data.hb], "gm", 7, false)
                        Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#28ef01\'>[' .. data.mz .. ']发送礼包成功</font>","Type":9}')
                    else
                        Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0000\'>[' .. data.mz .. ']玩家不在线</font>","Type":9}')
                    end
                end
            elseif p3 == 5 then
                local data = json2tbl(msg)
                if data and data.mz and data.hb and data.hb > 0 and data.hb < 11 then
                    local dx, sy = getplayerbyname(data.mz), data.hb
                    if dx then
                        recharge(dx, xlxl[3][data.hb], "gm", 21, false)
                        Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#28ef01\'>[' .. data.mz .. ']发送礼包成功</font>","Type":9}')
                    else
                        Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0000\'>[' .. data.mz .. ']玩家不在线</font>","Type":9}')
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
                    if getstditeminfo(data.wp, 1) == data.wp then
                        if p3 == 1 then
                            if data.lx then
                                giveitem(dx, data.wp, data.sl, data.lx == 1 and 850 or 0)
                                Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#28ef01\'>[' .. data.wp .. ']增加完成</font>","Type":9}')
                            end
                        elseif p3 == 2 then
                            takeitem(dx, data.wp, data.sl)
                            Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#00ff00\'>[' .. data.wp .. ']扣除完成</font>","Type":9}')
                        elseif p3 == 4 then
                            if checktitle(dx, data.ch) then
                                sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>拿...</font>","Type":9}')
                                Player.title_del(dx, data.ch)
                            else
                                sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>给...</font>","Type":9}')
                                Player.title_give(dx, data.ch)
                            end
                        end
                    else
                        Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0000\'>物品名字不正确</font>","Type":9}')
                    end
                else
                    Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0000\'>[' .. data.mz .. ']玩家不在线</font>","Type":9}')
                end
            end
        elseif p2 == 3 then
            local data = json2tbl(msg)
            if data and data.mz and data.bl and data.lx > 0 then
                local dx = getplayerbyname(data.mz)
                if data.lx ~= 4 then
                    if dx then
                        if p3 == 1 then
                            if data.lx == 1 then
                                if data.bl == "积分" then
                                    Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#00ff00\'>[' .. data.mz .. "]礼包积分剩余：" .. querymoney(dx, 22) .. '</font>","Type":9}')
                                elseif
                                    string.find(data.bl, "t")
                                    or string.find(data.bl, "T")
                                    or string.find(data.bl, "S")
                                then
                                    mircopy(play, getplaydef(dx, data.bl))
                                    messagebox(play, "[" .. data.bl .. "]的值\\" .. getplaydef(dx, data.bl) .. "")
                                else
                                    Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#00ff00\'>[' .. data.bl .. "]的值[" .. getplaydef(dx, data.bl) .. ']</font>","Type":9}')
                                end
                            elseif data.lx == 2 then
                                Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#00ff00\'>标识：[' .. data.bl .. "]的值[" .. getflagstatus(dx, data.bl) .. ']</font>","Type":9}')
                            elseif data.lx == 3 then
                                if hasbuff(dx, data.bl) then
                                    Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#00ff00\'>buff:[' .. data.bl .. "]的值[" .. math.floor((getbuffinfo(dx, data.bl, 2) / 60)) .. '分钟]</font>","Type":9}')
                                else
                                    Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0000\'>[' .. data.mz .. ']玩家没有这个BUFF</font>","Type":9}')
                                end
                            end
                        else
                            if data.zhi then
                                if data.lx == 1 then
                                    if data.bl == "积分" then
                                        changemoney(dx, 22, "+", data.zhi, "后台", true)
                                        Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#00ff00\'>[' .. data.mz .. "]增加[" .. data.zhi .. "]当前礼包积分剩余：" .. querymoney(dx, 22) .. '</font>","Type":9}')
                                    else
                                        setplaydef(dx, data.bl, data.zhi)
                                        Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#00ff00\'>[' .. data.bl .. "]的值[" .. getplaydef(dx, data.bl) .. ']</font>","Type":9}')
                                    end
                                elseif data.lx == 2 then
                                    setflagstatus(dx, data.bl, data.zhi)
                                    Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#00ff00\'>标识：[' .. data.bl .. "]的值[" .. getflagstatus(dx, data.bl) .. ']</font>","Type":9}')
                                elseif data.lx == 3 then
                                    Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0500\'>BUFF只能查询</font>","Type":9}')
                                end
                            end
                        end
                    else
                        Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0000\'>[' .. data.mz .. ']玩家不在线</font>","Type":9}')
                    end
                elseif data.lx == 4 then
                    if p3 == 1 then
                        if string.find(data.bl, "A") or string.find(data.bl, "a") then
                            messagebox(play, "[" .. data.bl .. "]的值\\" .. getsysvar(data.bl) .. "")
                        else
                            Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#00ff00\'>[' .. data.bl .. "]的值[" .. getsysvar(data.bl) .. ']</font>","Type":9}')
                        end
                    elseif p3 == 2 then
                        if data.zhi then
                            setsysvar(data.bl, data.zhi)
                            Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#00ff00\'>[' .. data.bl .. "]的值[" .. getsysvar(data.bl) .. ']</font>","Type":9}')
                        end
                    end
                end
            end
        elseif p2 == 4 then
            if msg ~= "" then
                local dx = getplayerbyname(msg)
                if p3 == 1 then
                    if dx then
                        kick(dx)
                        Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#28ef01\'>[' .. msg .. ']踢下线</font>","Type":9}')
                    else
                        Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0000\'>[' .. msg .. ']玩家不在线</font>","Type":9}')
                    end
                elseif p3 < 4 then
                    setgmlevel(play, 10)
                    if p3 == 2 then
                        gmexecute(play, "DenyCharNameLogon", msg, 1)
                        Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#28ef01\'>[' .. msg .. ']加入封禁列表</font>","Type":9}')
                        if dx then
                            callscriptex(dx, "CHANGELEVEL", "=", 1)
                        end
                    elseif p3 == 3 then
                        gmexecute(play, "DelDenyCharNameLogon", msg)
                        Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#28ef01\'>[' .. msg .. ']去除封禁列表</font>","Type":9}')
                    end
                    setgmlevel(play, 0)
                end
            end
            if p3 == 4 then
                setgmlevel(play, 10)
                gmexecute(play, "ShowDenyCharNameLogon")
                setgmlevel(play, 0)
            end
        elseif p2 == 5 then
            local data = json2tbl(msg)
            if data and data.mz and data.hb and data.hb > 0 then
                local dx, sy = getplayerbyname(data.mz), data.hb
                if dx then
                    changemoney(dx, 7, "+", data.hb * 100, "", true)
                    recharge(dx, data.hb, "gm", 7, false)
                    Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#28ef01\'>[' .. data.mz .. ']发送礼包成功</font>","Type":9}')
                else
                    Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0000\'>[' .. data.mz .. ']玩家不在线</font>","Type":9}')
                end
            end
        end
    end
end

npc[1004] = function(play, p2, p3, msg) --排行榜查询
    if p2 == 1 then
        local dx = getplayerbyid(msg)
        if dx then
            Player.sendmsgEx(dx, 1, '{"BColor":249,"FColor":255,"Msg":"<outline size=\'1\'><font color=\'#FFFF00\'></font>玩家<font color=\'#00ff00\'>[' .. getbaseinfo(play, 1) .. ']</font>在偷偷打量你</outline>","Type":1}')
            sendluamsg(play, 101, 1004, 0, 0, '{"userid":"' .. msg .. '","zdl":' .. querymoney(dx, 29) .. "}")
        else
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>玩家不在线</font>","Type":9}')
        end
    end
end

-- npc_guard: 自动加固按钮入口，所有按钮接口统一做玩家及参数校验。
local _npcGuardUnpack = (table and table.unpack) or unpack
for npcId, handler in pairs(npc) do
    if type(npcId) == "number" and type(handler) == "function" then
        npc[npcId] = (function(id, fn)
            return function(play, ...)
                if not Guard.ensurePlayer(play, id) then
                    return
                end
                local argc = select("#", ...)
                if argc >= 1 then
                    local args = { ... }
                    local normalized = Guard.normalizeAction(play, id, args[1])
                    if normalized == nil then
                        return
                    end
                    args[1] = normalized
                    if _npcGuardUnpack then
                        return fn(play, _npcGuardUnpack(args))
                    end
                    return fn(play, ...)
                end
                return fn(play, ...)
            end
        end)(npcId, handler)
    end
end

return npc































