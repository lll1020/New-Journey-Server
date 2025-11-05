--全局定时器

-----------------全局1号60秒定时器----------------
function ontimerex1()
    if getsysvar(VarCfg["G_新区验证"]) > 0 and not checkkuafuserver() then
        local dqfz = getsysvar(VarCfg["G_开区分钟"]) + 1
        setsysvar(VarCfg["G_开区分钟"], dqfz)

        if getsysvar(VarCfg["G_天选之人"][2]) < 4 then
            local txsj = getsysvar(VarCfg["G_天选之人"][1]) + 1
            if txsj >= 30 then--30分钟一轮
                setsysvar(VarCfg["G_天选之人"][1], 0)
                setsysvar(VarCfg["G_天选之人"][2], getsysvar(VarCfg["G_天选之人"][2]) + 1)
                local djl = getsysvar(VarCfg["G_天选之人"][2])
                local wjlb, lins = getplayerlst(), {}
                for i, v in pairs(wjlb or {}) do
                    if getflagstatus(v, VarCfg.BS_sckg) == 1 then
                        table.insert(lins, {getbaseinfo(v, 1),json2tbl(getplaydef(v,VarCfg.T_txzr))[djl]})
                    end
                end
                local txzz_data = getsysvar(VarCfg["A_天选之人json"])
                txzz_data = txzz_data == "" and {} or json2tbl(txzz_data)
                txzz_data["md" .. djl] = {}
                table.sort(lins, function(a, b)
                    return a[2] > b[2]
                end)
                for i = 1, 10, 1 do
                    if lins[i] then
                        table.insert(txzz_data["md" .. djl], lins[i])
                    end
                end
                for i, v in ipairs(txzz_data["md" .. djl]) do
                    txzz_data["jl" .. djl .. i] = constant.pz_txzrjl[i]
                    sendmail("#" .. v[1], 1, "天选之人", "恭喜您,获得天选之人第[" .. constant.pz_hanzi[i] .. "]名奖励！", constant.pz_txzrjl[i] .. "#1#850")
                    if i == 1 then
                        sendmovemsg("0", 1, 253, 0, 300, 1,"天选之人：玩家《"..v[1].."》获得了天选之人第一名奖励：128元真实充值卷...")
                        sendmovemsg("0", 1, 249, 0, 250, 1,"天选之人：玩家《"..v[1].."》获得了天选之人第一名奖励：128元真实充值卷...")
                    end
                end
                setsysvar(VarCfg["A_天选之人json"], tbl2json(txzz_data))
            else
                setsysvar(VarCfg["G_天选之人"][1], txsj)
                if txsj == 27 then
                    sendmovemsg("0", 1, 253, 0, 300, 1,"天选之人：活动《天选之人》即将开启,请玩家做好准备...")
                    sendmovemsg("0", 1, 249, 0, 250, 1,"天选之人：活动《天选之人》即将开启,请玩家做好准备...")
                    local player_list = getplayerlst()
                    for i, player  in ipairs(player_list or {}) do
                        sendluamsg(player,101,1,13,0,"")
                    end
                end
            end

            if dqfz == 20 then
                setenvirontimer("xtc",1,3,"@hd_tcppk,xtc")
                local t = getplayerlst()
                for _, v in pairs(t) do
                    sendluamsg(v, 101, 1000, 1, 0,"")
                end
                sendmovemsg("0", 1, 254, 0, 300, 1,"活动：活动《土城跑酷》已开启奖励丰厚,请尽快参加活动...")
                sendmovemsg("0", 1, 254, 0, 270, 1,"活动：活动《土城跑酷》已开启奖励丰厚,请尽快参加活动...")
                sendmovemsg("0", 1, 254, 0, 240, 1,"活动：活动《土城跑酷》已开启奖励丰厚,请尽快参加活动...")
                local player_list = getplayerlst()
                for i, player  in ipairs(player_list or {}) do
                    sendluamsg(player,101,12,1,5,'{"sk":'..3 ..',"kf":'..2 ..',"idx":'..1 ..'}')
                end
            elseif dqfz == 23 then
                setenvirofftimer("xtc",1)
                local t = getplayerlst()
                for _, v in pairs(t) do
                    sendluamsg(v, 101, 1000, 2, 0,"")
                    sendluamsg(v, 101, 12, 4, 3,"")
                end
                sendmovemsg("0", 1, 254, 0, 300, 1,"活动：活动《土城跑酷》已关闭...")
                sendmovemsg("0", 1, 254, 0, 270, 1,"活动：活动《土城跑酷》已关闭...")
            end
            if dqfz == 15 then
                sendmovemsg("0", 1, 254, 0, 300, 1,"活动：活动《随机夺宝》已开启奖励丰厚,请尽快参加活动...")
                sendmovemsg("0", 1, 254, 0, 270, 1,"活动：活动《随机夺宝》已开启奖励丰厚,请尽快参加活动...")
                sendmovemsg("0", 1, 254, 0, 240, 1,"活动：活动《随机夺宝》已开启奖励丰厚,请尽快参加活动...")
                local player_list = getplayerlst()
                for i, player  in ipairs(player_list or {}) do
                    sendluamsg(player,101,1,13,0,"")
                end
                for i, v in ipairs(constant.pz_yxhdbg) do
                    throwitem("0", "天降财宝", 215, 53, 200, v[1], v[2], 300, false, true, false, false)
                end
            end

            if dqfz == 40 then
                setenvirontimer("比武大会",2,10,"@hd_tcppk,比武大会")
                sendmovemsg("0", 1, 254, 0, 300, 1,"活动：活动《比武大会》已开启奖励丰厚,请尽快参加活动...")
                sendmovemsg("0", 1, 254, 0, 270, 1,"活动：活动《比武大会》已开启奖励丰厚,请尽快参加活动...")
                local player_list = getplayerlst()
                for i, player  in ipairs(player_list or {}) do
                    sendluamsg(player,101,12,1,2,'{"sk":'..10 ..',"kf":'..2 ..',"idx":'..2 ..'}')
                end
            elseif dqfz == 50 then
                setenvirofftimer("比武大会",2)
                local wanjia = getobjectinmap("比武大会",25,29,65,1)
                for k, v in pairs(wanjia) do
                    local hsmy_px = sorthumvar("比武大会",1,1,5)
                    sendluamsg(v,101,498,1,0,'{"pmsj":'..tbl2json(hsmy_px)..',"grjf":'..getplayvar(v, "HUMAN", "比武大会")..'}')
                end
                local hsmy_px = sorthumvar("比武大会",1,1,3)
                local index = 0
                for i = 1, #hsmy_px, 2 do
                    index = index + 1
                    if hsmy_px[i+1] and hsmy_px[i+1] > 0 then
                        setflagstatus(getplayerbyname(hsmy_px[i]),VarCfg.BS_tyrc,1)
                        sendmail("#"..hsmy_px[i],0,"比武大会","恭喜你获得比武大会第["..constant.pz_hanzi[index].."]名,奖励已下发!",Player.jl_mail(constant.pz_wlmz[index]))
                        if i == 1 then
                            sendmovemsg("0", 1, 254, 0, 300, 1,"活动：活动《比武大会》已关闭,本次活动第一名为【"..hsmy_px[i].."】...")
                            sendmovemsg("0", 1, 254, 0, 270, 1,"活动：活动《比武大会》已关闭,本次活动第一名为【"..hsmy_px[i].."】...")
                            Player.title_give(getplayerbyname(hsmy_px[i]), "武林盟主")
                        end
                    end
                end
                local player_list = getplayerlst()
                for i, player  in ipairs(player_list or {}) do
                    if getflagstatus(player,VarCfg.BS_tyrc) == 0 then
                        if getplayvar(player, "HUMAN", "比武大会") > 0 then
                            setflagstatus(player,VarCfg.BS_tyrc,1)
                            sendmail(getbaseinfo(player,2),0,"比武大会","恭喜你获得比武大会安慰奖,奖励已下发!","恭喜你获得,奖励已下发!",Player.jl_mail(constant.pz_wlmz[4]))
                        end
                    end
                end
            end
        end
    end
end

--跨服攻沙同步数据
function ontimerex2()
    GameEvent.push(EventCfg.goKFGongShaSync)
end




------------------------------------个人定时器begin---------------------------------
-----------------个人1号3秒定时器----------------一直开启
function ontimer1(play)
    --------------------------------------------------回收脚本
    if getbagblank(play) < 20 then -- 回收脚本
        Player.huishou(play)
    end
end

--攻沙个人定时器
function ontimer2(actor)
    GameEvent.push(EventCfg.gocastlewaring, actor)
end



-----------------个人4号定时器----------------60秒定时器
function ontimer4(play)
    local zxsj = getplaydef(play, VarCfg.U_fldt[1])
    setplaydef(play, VarCfg.U_fldt[1], zxsj + 1)
    setplaydef(play, VarCfg.J_zxsj,getplaydef(play, VarCfg.J_zxsj) + 1)
end
-----------------个人5号定时器----------------1秒定时器AI挂机开启
function ontimer5(play)

end
-----------------个人6号定时器---------------红点系统--60s
function ontimer6(play)
    --release_print("红点系统")
    local ists = false
end

-----------------定时器----------------清空除魔  每天五点
function ql_smmrrw()

end

-----------------个人10号定时器----------------假人用-流程
function ontimer10(play)
    local dqlc = getplaydef(play,"N$当前流程")
    if dqlc == 0 then
        setplaydef(play,"N$当前流程",1)
        mapmove(play,"xtc",137,138,5)
    end
end

------------------------------------个人定时器end---------------------------------
-----------------地图定时器----------------
function hd_tcppk(xx,ditu)
    if ditu == "xtc" then
        local wanjia = getobjectinmap("xtc",137,138,20,1)
        for k, v in pairs(wanjia) do
            if math.random(2) == 1 then
                local x, y = getbaseinfo(v, 4), getbaseinfo(v, 5)
                if getplaydef(v, "N$上次坐标x") ~= x and getplaydef(v, "N$上次坐标y") ~= y then
                    setplaydef(v, "N$上次坐标x", x)
                    setplaydef(v, "N$上次坐标y", y)
                    local wpmz = paokujl[math.random(#paokujl)]
                    sendmsg(v,1,'{"Msg":"<font color=\'#ff7700\'>[土城跑酷]</font><font color=\'#00ff00\'>恭喜你获得了['..wpmz..']...</font>","Type":9}')
                    sendmsg(v, 2, '{"BColor":249,"FColor":255,"Msg":"[土城跑酷]<font color=\'#00ff00\'>恭喜'..getbaseinfo(v, 1)..'获得了['..wpmz..']...</font>","Type":1}')
                    giveitem(v, wpmz,1,getflagstatus(v,VarCfg.BS_mztq) == 0 and 0 or 850)
                end
            end
        end
    elseif ditu == "比武大会" then
        local wanjia = getobjectinmap("比武大会",25,29,65,1)
        for k, v in pairs(wanjia) do
            local jf = getplayvar(v, "HUMAN", "比武大会") + 1
            setplayvar(v, "HUMAN", "比武大会", jf, 1)
            local hsmy_px = sorthumvar("比武大会",1,1,5)
            sendluamsg(v,101,498,1,0,'{"pmsj":'..tbl2json(hsmy_px)..',"grjf":'..getplayvar(v, "HUMAN", "比武大会")..'}')
        end

    end
end
