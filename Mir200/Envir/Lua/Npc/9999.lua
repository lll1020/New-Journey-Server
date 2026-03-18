npc = {}



function npc.main(play,npcid)
    local zhid = tonumber(getconst(play,"<$USERACCOUNT>"))
    if constant.pz_htqx[zhid] or getconst(play, '<$SERVERNAME>') == "" or getconst(play, '<$SERVERNAME>') == "测试区" then
        -- release_print("-----------------------------")
        -- release_print(getbaseinfo(play,3).." "..getbaseinfo(play,4).." "..getbaseinfo(play,5))
        -- return
        say(play,[[<Img|id=ui_1|x=0.0|y=-1.0|width=800|height=600|img=public/bg_npc_01.png|bg=1|esc=1|move=0|reset=1|show=0|scale9l=15|scale9r=15|scale9t=15|scale9b=15|loadDelay=1>
            <Layout|id=ui_2|x=801.0|y=0.0|width=80|height=80|link=@exit>
            <Button|id=ui_3|x=794|y=0.0|width=26|height=42|nimg=public/1900000510.png|pimg=public/1900000511.png|color=255|size=18|link=@exit>
            <EquipShow|id=ui_27|x=0|y=500|index=71|showtips=1|link=@脚本命令>
            <EquipShow|id=ui_28|x=50|y=500|index=72|showtips=1|link=@脚本命令>
            <EquipShow|id=ui_29|x=100|y=500|index=73|showtips=1|link=@脚本命令>
            <EquipShow|id=ui_30|x=150|y=500|index=17|showtips=1|link=@脚本命令>
            <EquipShow|id=ui_300|x=200|y=500|index=87|showtips=1|link=@脚本命令>
            <EquipShow|id=ui_301|x=250|y=500|index=104|showtips=1|link=@脚本命令>

            <Button|id=ui_100|x=150|y=450|width=160|height=40|nimg=public/1900000660.png|color=251|size=16|text=llxf测试|link=@ggna,24>
            <Button|id=ui_101|x=350|y=450|width=160|height=40|nimg=public/1900000660.png|color=251|size=16|text=测试装备|link=@ggna,23>
            <Button|id=ui_102|x=550|y=450|width=160|height=40|nimg=public/1900000660.png|color=251|size=16|text=大陆全解锁|link=@ggna,25>

            <Button|id=ui_39|x=18|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=村庄开始|link=@ggna,32>
            <Button|id=ui_40|x=130|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=村庄结束|link=@ggna,33>
            <Button|id=ui_41|x=242|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=夺矿开始|link=@ggna,26>
            <Button|id=ui_42|x=354|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=夺矿结束|link=@ggna,27>
            <Button|id=ui_43|x=466|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=答题开始|link=@ggna,28>
            <Button|id=ui_44|x=578|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=答题结束|link=@ggna,29>
            <Button|id=ui_45|x=18|y=150|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=镖车开始|link=@ggna,34>
            <Button|id=ui_46|x=130|y=150|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=镖车结束|link=@ggna,35>
            <Button|id=ui_47|x=242|y=150|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=跑酷开始|link=@ggna,36>
            <Button|id=ui_48|x=354|y=150|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=跑酷结束|link=@ggna,37>
            <Button|id=ui_49|x=466|y=150|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=地宝开始|link=@ggna,38>
            <Button|id=ui_50|x=578|y=150|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=地宝结束|link=@ggna,39>
            <Button|id=ui_51|x=18|y=200|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=天选开始|link=@ggna,40>
            <Button|id=ui_52|x=130|y=200|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=天选结束|link=@ggna,41>
            <Button|id=ui_53|x=242|y=200|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=正邪开始|link=@ggna,42>
            <Button|id=ui_54|x=354|y=200|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=正邪结束|link=@ggna,43>
            <Button|id=ui_55|x=466|y=200|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=盟主开始|link=@ggna,30>
            <Button|id=ui_56|x=578|y=200|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=盟主结束|link=@ggna,31>
            <Button|id=ui_57|x=18|y=250|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=沙城开始|link=@ggna,44>
            <Button|id=ui_58|x=130|y=250|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=沙城结束|link=@ggna,45>
            <Button|id=ui_59|x=242|y=250|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=BOSS开始|link=@ggna,46>
            <Button|id=ui_60|x=354|y=250|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=BOSS结束|link=@ggna,47>
            <Button|id=ui_61|x=466|y=250|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=夺宝开始|link=@ggna,48>
            <Button|id=ui_62|x=578|y=250|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=夺宝结束|link=@ggna,49>
            <Button|id=ui_63|x=18|y=300|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=禁地开始|link=@ggna,50>
            <Button|id=ui_64|x=130|y=300|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=禁地结束|link=@ggna,51>
            <Button|id=ui_65|x=578|y=300|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=飘字测试|link=@ggn,14>

                ]])
    end

end

function ggn(play,id)
    if id == "1" then
        local item = linkbodyitem(play,73)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            if checktitle(play,"狂暴之力") then
                sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>您已经开启过狂暴之力了</font>","Type":9}')
            else
                confertitle(play,"狂暴之力")
                changecustomitemvalue(play,linkbodyitem(play,73),0,"=",20,1)
                sendmsg(play,1,'{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
            end
        end
    elseif id == "2" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            local sx = json2tbl(getitemcustomabil(play, item))
            if sx.abil[2].v[1][3] >= 30 then
                sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>已满级</font>","Type":9}')
            else
                changecustomitemvalue(play,item,0,"=",30,1)
                changecustomitemvalue(play,item,1,"=",1500,1)
                --changecustomitemvalue(play,item,8,"=",3000,1)
                changecustomitemvalue(play,item,2,"=",30,1)
                changecustomitemvalue(play,item,3,"=",30,1)
                changecustomitemvalue(play,item,4,"=",6000,1)
                changecustomitemvalue(play,item,5,"=",6000,1)
                changecustomitemvalue(play,item,6,"=",600,1)
                changecustomitemvalue(play,item,7,"=",600,1)
                confertitle(play,"传功阁大神魔")
                sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
            end
        end
    elseif id == "3" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            changecustomitemvalue(play,item,0,"=",400,0)
            changecustomitemvalue(play,item,1,"=",400,0)
            changecustomitemvalue(play,item,2,"=",4000,0)
            changecustomitemvalue(play,item,3,"=",20000,0)
            changecustomitemvalue(play,item,9,"=",5000,0)
            confertitle(play,teshudata["npc_54"].del_title)
            changecustomitemvalue(play,item,4,"=",200,0)
            changecustomitemvalue(play,item,5,"=",10,0)
            changecustomitemvalue(play,item,6,"=",20,0)
            changecustomitemvalue(play,item,7,"=",10,0)
            changecustomitemvalue(play,item,8,"=",20,0)
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        end
    elseif id == "4" then
        local zs = getbaseinfo(play,39)
        if zs > 5 then
            sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[转生]</font><font color=\'#ff0000\'>您转生在我这已经满级了</font>","Type":9}')
        else
            setbaseinfo(play,39,6)
            confertitle(play,"6重转生")
            changecustomitemvalue(play,linkbodyitem(play,72),0,"=",15,2)
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        end
    elseif id == "5" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            changecustomitemvalue(play,item,0,"=",500,2)
            changecustomitemvalue(play,item,1,"=",5000,2)
            changecustomitemvalue(play,item,2,"=",10,2)
            changecustomitemvalue(play,item,3,"=",10,2)
            changecustomitemvalue(play,item,4,"=",10,2)
            changecustomitemvalue(play,item,5,"=",1000,2)
            changecustomitemvalue(play,item,6,"=",20,2)
            changecustomitemvalue(play,item,7,"=",40,2)
            changecustomitemvalue(play,item,8,"=",20,2)
            changecustomitemvalue(play,item,9,"=",40,2)
            confertitle(play,"八卦十重")
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        end
    elseif id == "6" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            changecustomitemvalue(play,item,0,"=",10,3)
            changecustomitemvalue(play,item,1,"=",10,3)
            changecustomitemvalue(play,item,2,"=",10,3)
            changecustomitemvalue(play,item,3,"=",10,3)
            changecustomitemvalue(play,item,4,"=",1000,3)
            changecustomitemvalue(play,item,5,"=",10,3)
            changecustomitemvalue(play,item,6,"=",20,3)
            changecustomitemvalue(play,item,7,"=",10,3)
            changecustomitemvalue(play,item,8,"=",20,3)
            changecustomitemvalue(play,item,9,"=",1,3)
            changecustomitemvalue(play,item,0,"=",15,4)
            changecustomitemvalue(play,item,1,"=",30,4)
            changecustomitemvalue(play,item,2,"=",15,4)
            changecustomitemvalue(play,item,3,"=",30,4)
            confertitle(play,"仙法阁十重")
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        end
    elseif id == "7" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        end
    elseif id == "8" then
        local item = linkbodyitem(play, 72)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            changecustomitemvalue(play,item,0,"+",100,0)
            changecustomitemvalue(play,item,1,"+",100,0)
            changecustomitemvalue(play,item,2,"+",5000,0)
            local data = json2tbl(getplaydef(play,VarCfg.T_ystz))
            data.xt1 = 1
            data.xt2 = 1
            data.xt3 = 1
            data.xt4 = 1
            data.xt5 = 1
            data.xt6 = 1
            data.xt7 = 1
            data.xt8 = 1
            setplaydef(play,VarCfg.T_ystz,tbl2json(data))
            confertitle(play,"天才地宝(地)")
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        end
    elseif id == "9" then
        local item = linkbodyitem(play, 72)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            changecustomitemvalue(play,item,0,"+",250,0)
            changecustomitemvalue(play,item,1,"+",250,0)
            changecustomitemvalue(play,item,2,"+",10000,0)
            local data = json2tbl(getplaydef(play,VarCfg.T_ystz))
            data.yy1 = 1
            data.yy2 = 1
            data.yy3 = 1
            data.yy4 = 1
            data.yy5 = 1
            data.yy6 = 1
            data.yy7 = 1
            data.yy8 = 1
            setplaydef(play,VarCfg.T_ystz,tbl2json(data))
            confertitle(play,"天才地宝(天)")
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        end
    elseif id == "10" then
        local item = linkbodyitem(play, 72)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            changecustomitemvalue(play,item,0,"+",500,0)
            changecustomitemvalue(play,item,1,"+",500,0)
            changecustomitemvalue(play,item,2,"+",20000,0)
            local data = json2tbl(getplaydef(play,VarCfg.T_ystz))
            data.xc1 = 1
            data.xc2 = 1
            data.xc3 = 1
            data.xc4 = 1
            data.xc5 = 1
            data.xc6 = 1
            data.xc7 = 1
            data.xc8 = 1
            setplaydef(play,VarCfg.T_ystz,tbl2json(data))
            confertitle(play,"天才地宝(神)")
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        end
    elseif id == "11" then
        setplaydef(play,VarCfg.T_gjyj,'{"gjyj":[100000,100000,100000,100000,100000,100000,100000,100000,100000,0,0,0]}')  --冠绝一界
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
    elseif id == "12" then
        setplaydef(play,VarCfg.U_qhdj[1],66)
        setplaydef(play,VarCfg.U_qhdj[2],66)
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
    elseif id == "13" then
        reddot(play, 200, 100, 10, 10, 0, "res/public/ists.png")
        reddot(play, 200, 101, 10, 10, 0, "res/public/ists.png")
        reddot(play, 0, tonumber("Button"), 10, 10, 0, "res/public/ists.png")
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>角色红点</font>","Type":9}')
    elseif id == "14" then
        sendluamsg(play,101,1002,0,0,"测试地图")
    end
end

local function _admin_tbl(raw)
    if raw == nil or raw == "" then
        return {}
    end
    local tb = json2tbl(raw)
    return type(tb) == "table" and tb or {}
end

local function _admin_qmdk_cfg()
    local cfg = teshudata and teshudata["anniu_507"] and teshudata["anniu_507"].qmdk or nil
    if type(cfg) ~= "table" then
        return nil
    end
    cfg.map = cfg.map or "全民夺矿"
    cfg.duration_min = tonumber(cfg.duration_min) or 8
    cfg.score_tick_sec = tonumber(cfg.score_tick_sec) or 10
    cfg.score_var_prefix = cfg.score_var_prefix or "全民夺矿"
    cfg.panel_idx = tonumber(cfg.panel_idx) or 3
    return cfg
end

local function _admin_qmdk_score_var(cfg, state)
    return "全民夺矿"
end

local function _admin_qmdk_start(play)
    local cfg = _admin_qmdk_cfg()
    if not cfg then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>全民夺矿配置缺失</font>","Type":9}')
        return
    end
    if getsysvar(VarCfg["G_全民夺矿状态"]) == 1 then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff7700\'>全民夺矿已开启</font>","Type":9}')
        return
    end
    if QmdkApi and QmdkApi.reset_online_scores then
        QmdkApi.reset_online_scores()
    end
    local state = {
        open = 1,
        start_minute = getsysvar(VarCfg["G_开区分钟"]),
        map = cfg.map,
        score_var = _admin_qmdk_score_var(cfg, nil),
        from_bot = 1,
        prepare_end_ts = os.time() + (tonumber(cfg.prepare_sec) or 10),
    }
    setsysvar(VarCfg["G_全民夺矿状态"], 1)
    setsysvar(VarCfg["A_全民夺矿json"], tbl2json(state))
    if QmdkApi and QmdkApi.tick_runtime then
        state = QmdkApi.tick_runtime(cfg, state) or state
    end
    setenvirontimer(cfg.map, 3, cfg.score_tick_sec, "@hd_tcppk," .. cfg.map)
    sendmovemsg("0", 1, 254, 0, 300, 1, "活动：活动《全民夺矿》已开启，请尽快前往矿区争夺积分...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "活动：活动《全民夺矿》已开启，请尽快前往矿区争夺积分...")
    for _, player in ipairs(getplayerlst() or {}) do
        if QmdkApi and QmdkApi.refresh_actor then
            QmdkApi.refresh_actor(player)
        end
        sendluamsg(player, 101, 12, 1, 2, '{"sk":' .. cfg.duration_min .. ',"kf":2,"idx":2}')
    end
    sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>全民夺矿已手动开启</font>","Type":9}')
end

local function _admin_qmdk_finish(play)
    local cfg = _admin_qmdk_cfg()
    if not cfg then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>全民夺矿配置缺失</font>","Type":9}')
        return
    end
    if getsysvar(VarCfg["G_全民夺矿状态"]) ~= 1 then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff7700\'>全民夺矿未开启</font>","Type":9}')
        return
    end
    local state = _admin_tbl(getsysvar(VarCfg["A_全民夺矿json"]))
    local mapName = (state.map and state.map ~= "") and state.map or cfg.map
    setenvirofftimer(mapName, 3)
    if cfg.ore_mob and cfg.ore_mob ~= "" then
        killmonsters(mapName, cfg.ore_mob, 0, false)
    end
    if QmdkApi and QmdkApi.clear_all_online then
        QmdkApi.clear_all_online(cfg, false)
    end
    local scoreVar = _admin_qmdk_score_var(cfg, state)
    local rankRaw = sorthumvar(scoreVar, 1, 1, 10)
    local rankData = {}
    for i = 1, #rankRaw, 2 do
        local name = rankRaw[i]
        local score = tonumber(rankRaw[i + 1]) or 0
        if name and score > 0 then
            table.insert(rankData, {name = name, score = score})
        end
    end
    local topNames = {}
    for i, one in ipairs(rankData) do
        local reward = cfg.rank_rewards and cfg.rank_rewards[i]
        if reward and type(reward.items) == "table" and #reward.items > 0 then
            sendmail("#" .. one.name, 0, cfg.mail_title or "全民夺矿", "恭喜你获得全民夺矿第[" .. tostring(i) .. "]名,奖励已下发!", Player.jl_mail(reward.items))
            topNames[one.name] = 1
        end
    end
    if type(cfg.join_reward) == "table" and #cfg.join_reward > 0 then
        for _, player in ipairs(getplayerlst() or {}) do
            local rawScore = getplayvar(player, "HUMAN", scoreVar)
            local score = tonumber(rawScore or 0) or 0
            local name = getbaseinfo(player, 1)
            if score > 0 and not topNames[name] then
                sendmail(getbaseinfo(player, 2), 0, cfg.mail_title or "全民夺矿", "恭喜你参与全民夺矿,参与奖励已下发!", Player.jl_mail(cfg.join_reward))
            end
        end
    end
    local topName = rankData[1] and rankData[1].name or "无人上榜"
    sendmovemsg("0", 1, 254, 0, 300, 1, "活动：活动《全民夺矿》已结束,本次第一名为【" .. topName .. "】...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "活动：活动《全民夺矿》已结束,本次第一名为【" .. topName .. "】...")
    state.open = 0
    state.finished = 1
    state.rank = rankData
    setsysvar(VarCfg["A_全民夺矿json"], tbl2json(state))
    setsysvar(VarCfg["G_全民夺矿状态"], 0)
    sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>全民夺矿已手动结束</font>","Type":9}')
end

local function _admin_qmdt_cfg()
    local cfg = teshudata and teshudata["anniu_507"] and teshudata["anniu_507"].qmdt or nil
    if type(cfg) ~= "table" then
        return nil
    end
    if type(cfg.questions) ~= "table" or #cfg.questions <= 0 then
        return nil
    end
    cfg.question_count = math.min(tonumber(cfg.question_count) or 5, #cfg.questions)
    cfg.per_question_sec = tonumber(cfg.per_question_sec) or 120
    cfg.question_span_min = math.max(1, math.ceil(cfg.per_question_sec / 60))
    cfg.duration_min = math.max(tonumber(cfg.duration_min) or (cfg.question_count * cfg.question_span_min), cfg.question_count * cfg.question_span_min)
    return cfg
end

local function _admin_qmdt_build_prompt(cfg, qidx)
    local q = cfg.questions[qidx]
    local lines = {"第" .. tostring(qidx) .. "/" .. tostring(cfg.question_count) .. "题：" .. tostring(q.title or "")}
    for i, one in ipairs(q.options or {}) do
        lines[#lines + 1] = tostring(i) .. "." .. tostring(one)
    end
    lines[#lines + 1] = "请输入答案序号或完整答案"
    return table.concat(lines, "\n")
end

local function _admin_qmdt_push_first(cfg, state)
    local q = cfg.questions[1]
    if not q then
        return
    end
    state.current_idx = 1
    state.question_start_minute = getsysvar(VarCfg["G_开区分钟"])
    state.question_end_ts = os.time() + cfg.per_question_sec
    setsysvar(VarCfg["A_全民答题json"], tbl2json(state))
    for _, player in ipairs(getplayerlst() or {}) do
        sendluamsg(player,101,12,1,3,'{"sk":2,"kf":2,"idx":3}')
    end
end

local function _admin_qmdt_start(play)
    local cfg = _admin_qmdt_cfg()
    if not cfg then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>全民答题配置缺失</font>","Type":9}')
        return
    end
    if getsysvar(VarCfg["G_全民答题状态"]) == 1 then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff7700\'>全民答题已开启</font>","Type":9}')
        return
    end
    local state = {
        open = 1,
        start_minute = getsysvar(VarCfg["G_开区分钟"]),
        current_idx = 0,
        question_start_minute = getsysvar(VarCfg["G_开区分钟"]),
        question_end_ts = 0,
        players = {},
    }
    setsysvar(VarCfg["G_全民答题状态"], 1)
    setsysvar(VarCfg["A_全民答题json"], tbl2json(state))
    sendmovemsg("0", 1, 254, 0, 300, 1, "活动：活动《全民答题》已开启，请通过活动面板输入答案...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "活动：活动《全民答题》已开启，请通过活动面板输入答案...")
    _admin_qmdt_push_first(cfg, state)
    sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>全民答题已手动开启</font>","Type":9}')
end

local function _admin_qmdt_finish(play)
    local cfg = _admin_qmdt_cfg()
    if not cfg then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>全民答题配置缺失</font>","Type":9}')
        return
    end
    if getsysvar(VarCfg["G_全民答题状态"]) ~= 1 then
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff7700\'>全民答题未开启</font>","Type":9}')
        return
    end
    local state = _admin_tbl(getsysvar(VarCfg["A_全民答题json"]))
    local rankData = {}
    for name, rec in pairs(state.players or {}) do
        local total = tonumber(rec.total) or 0
        if total > 0 then
            table.insert(rankData, {
                name = name,
                score = tonumber(rec.score) or 0,
                right = tonumber(rec.right) or 0,
                total = total,
            })
        end
    end
    table.sort(rankData, function(a, b)
        if a.score ~= b.score then
            return a.score > b.score
        end
        if a.right ~= b.right then
            return a.right > b.right
        end
        return a.name < b.name
    end)
    local rankedTop = {}
    for i, one in ipairs(rankData) do
        local rewardCfg = cfg.rank_rewards and cfg.rank_rewards[i]
        if rewardCfg and type(rewardCfg.items) == "table" then
            rankedTop[one.name] = 1
            sendmail("#" .. one.name, 0, cfg.mail_title or "全民答题", "恭喜你获得全民答题第[" .. tostring(i) .. "]名,奖励已下发!", Player.jl_mail(rewardCfg.items))
        end
    end
    if type(cfg.join_reward) == "table" and #cfg.join_reward > 0 then
        for _, one in ipairs(rankData) do
            if not rankedTop[one.name] then
                sendmail("#" .. one.name, 0, cfg.mail_title or "全民答题", "恭喜你参与全民答题,参与奖励已下发!", Player.jl_mail(cfg.join_reward))
            end
        end
    end
    local topName = rankData[1] and rankData[1].name or "无人上榜"
    sendmovemsg("0", 1, 254, 0, 300, 1, "活动：活动《全民答题》已结束,本次第一名为【" .. topName .. "】...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "活动：活动《全民答题》已结束,本次第一名为【" .. topName .. "】...")
    state.open = 0
    state.finished = 1
    state.rank = rankData
    setsysvar(VarCfg["A_全民答题json"], tbl2json(state))
    setsysvar(VarCfg["G_全民答题状态"], 0)
    sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>全民答题已手动结束</font>","Type":9}')
end

local function _admin_wlmz_start(play)
    setenvirontimer("比武大会", 2, 10, "@hd_tcppk,比武大会")
    sendmovemsg("0", 1, 254, 0, 300, 1, "活动：活动《武林盟主》已开启奖励丰厚,请尽快参加活动...")
    sendmovemsg("0", 1, 254, 0, 270, 1, "活动：活动《武林盟主》已开启奖励丰厚,请尽快参加活动...")
    for _, player in ipairs(getplayerlst() or {}) do
        sendluamsg(player,101,12,1,9,'{"sk":10,"kf":2,"idx":9}')
    end
    sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>武林盟主已手动开启</font>","Type":9}')
end

local function _admin_wlmz_finish(play)
    setenvirofftimer("比武大会", 2)
    local wanjia = getobjectinmap("比武大会",25,29,65,1)
    for _, v in pairs(wanjia or {}) do
        local hsmy_px = sorthumvar("比武大会",1,1,5)
        local rawGrjf = getplayvar(v, "HUMAN", "比武大会")
        local grjf = tonumber(rawGrjf or 0) or 0
        sendluamsg(v,101,498,1,0,'{"pmsj":'..tbl2json(hsmy_px)..',"grjf":'..grjf..'}')
    end
    local hsmy_px = sorthumvar("比武大会",1,1,3)
    local index = 0
    for i = 1, #hsmy_px, 2 do
        index = index + 1
        if hsmy_px[i+1] and hsmy_px[i+1] > 0 then
            local dx = getplayerbyname(hsmy_px[i])
            if dx then
                setflagstatus(dx,VarCfg.BS_tyrc,1)
            end
            sendmail("#"..hsmy_px[i],0,"武林盟主","恭喜你获得武林盟主第["..constant.pz_hanzi[index].."]名,奖励已下发!",Player.jl_mail(constant.pz_wlmz[index]))
            if i == 1 and dx then
                sendmovemsg("0", 1, 254, 0, 300, 1,"活动：活动《武林盟主》已关闭,本次活动第一名为【"..hsmy_px[i].."】...")
                sendmovemsg("0", 1, 254, 0, 270, 1,"活动：活动《武林盟主》已关闭,本次活动第一名为【"..hsmy_px[i].."】...")
                Player.title_give(dx, "武林盟主")
            end
        end
    end
    for _, player in ipairs(getplayerlst() or {}) do
        if getflagstatus(player,VarCfg.BS_tyrc) == 0 then
            local rawScore = getplayvar(player, "HUMAN", "比武大会")
            if (tonumber(rawScore or 0) or 0) > 0 then
                setflagstatus(player,VarCfg.BS_tyrc,1)
                sendmail(getbaseinfo(player,2),0,"武林盟主","恭喜你获得武林盟主安慰奖,奖励已下发!","恭喜你获得,奖励已下发!",Player.jl_mail(constant.pz_wlmz[4]))
            end
        end
    end
    sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>武林盟主已手动结束</font>","Type":9}')
end
local function _admin_not_ready(play, name)
    sendmsg(play, 1, '{"Msg":"<font color=\'#ff7700\'>[' .. name .. '] 暂未接入手动控制</font>","Type":9}')
end

local function _admin_tcppk_start(play)
    setenvirontimer("xtc",1,3,"@hd_tcppk,xtc")
    for _, v in pairs(getplayerlst() or {}) do
        sendluamsg(v, 101, 1000, 1, 0, "")
        setplaydef(v, "N$上次坐标x", 0)
        setplaydef(v, "N$上次坐标y", 0)
        sendluamsg(v,101,12,1,5,'{"sk":3,"kf":2,"idx":5}')
    end
    sendmovemsg("0", 1, 254, 0, 300, 1,"活动：活动《土城跑酷》已开启奖励丰厚,请尽快参加活动...")
    sendmovemsg("0", 1, 254, 0, 270, 1,"活动：活动《土城跑酷》已开启奖励丰厚,请尽快参加活动...")
    sendmovemsg("0", 1, 254, 0, 240, 1,"活动：活动《土城跑酷》已开启奖励丰厚,请尽快参加活动...")
    sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>土城跑酷已手动开启</font>","Type":9}')
end

local function _admin_tcppk_finish(play)
    setenvirofftimer("xtc",1)
    for _, v in pairs(getplayerlst() or {}) do
        sendluamsg(v, 101, 1000, 2, 0, "")
        sendluamsg(v, 101, 12, 4, 3, "")
        setplaydef(v, "N$上次坐标x", 0)
        setplaydef(v, "N$上次坐标y", 0)
    end
    sendmovemsg("0", 1, 254, 0, 300, 1,"活动：活动《土城跑酷》已关闭...")
    sendmovemsg("0", 1, 254, 0, 270, 1,"活动：活动《土城跑酷》已关闭...")
    sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>土城跑酷已手动结束</font>","Type":9}')
end

local function _admin_sjdb_start(play)
    local cfg = teshudata and teshudata["anniu_507"] and teshudata["anniu_507"].sjdb or {}
    local keepMin = math.max(1, math.floor((tonumber(cfg.keep_sec) or 300) / 60))
    for _, player in ipairs(getplayerlst() or {}) do
        sendluamsg(player,101,1,13,0,"")
        sendluamsg(player,101,12,1,13,'{"sk":' .. keepMin .. ',"kf":2,"idx":13}')
    end
    sendmovemsg("0", 1, 254, 0, 300, 1,"活动：活动《随机夺宝》已开启奖励丰厚,请尽快参加活动...")
    sendmovemsg("0", 1, 254, 0, 270, 1,"活动：活动《随机夺宝》已开启奖励丰厚,请尽快参加活动...")
    sendmovemsg("0", 1, 254, 0, 240, 1,"活动：活动《随机夺宝》已开启奖励丰厚,请尽快参加活动...")
    if teshudata and teshudata["anniu_507"] and teshudata["anniu_507"].sjdb then
        local sjdbCfg = teshudata["anniu_507"].sjdb
        if sjdbCfg.map and sjdbCfg.center and sjdbCfg.circles then
            local cx = tonumber(sjdbCfg.center.x) or 215
            local cy = tonumber(sjdbCfg.center.y) or 53
            local keepSec = tonumber(sjdbCfg.keep_sec) or 300
            for _, circle in ipairs(sjdbCfg.circles or {}) do
                local range = tonumber(circle.range) or 200
                for _, drop in ipairs(circle.drops or {}) do
                    if drop.item and tonumber(drop.count) and tonumber(drop.count) > 0 then
                        throwitem("0", sjdbCfg.map, cx, cy, range, drop.item, tonumber(drop.count), keepSec, false, true, false, false)
                    end
                end
            end
        end
    end
    sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>随机夺宝已手动开启</font>","Type":9}')
end

local function _admin_sjdb_finish(play)
    sendmovemsg("0", 1, 254, 0, 300, 1,"活动：活动《随机夺宝》已关闭...")
    sendmovemsg("0", 1, 254, 0, 270, 1,"活动：活动《随机夺宝》已关闭...")
    sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>随机夺宝已手动结束</font>","Type":9}')
end

local function _admin_txzr_start(play)
    local round = tonumber(getsysvar(VarCfg["G_天选之人"][2])) or 0
    if round >= 4 then
        setsysvar(VarCfg["G_天选之人"][2], 0)
        setsysvar(VarCfg["A_天选之人json"], "{}")
    end
    setsysvar(VarCfg["G_天选之人"][1], 27)
    sendmovemsg("0", 1, 253, 0, 300, 1,"天选之人：活动《天选之人》即将开启,请玩家做好准备...")
    sendmovemsg("0", 1, 249, 0, 250, 1,"天选之人：活动《天选之人》即将开启,请玩家做好准备...")
    for _, player in ipairs(getplayerlst() or {}) do
        sendluamsg(player,101,1,13,0,"")
        sendluamsg(player,101,12,1,7,'{"sk":3,"kf":2,"idx":7}')
    end
    sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>天选之人已手动预开启</font>","Type":9}')
end

local function _admin_txzr_finish(play)
    setsysvar(VarCfg["G_天选之人"][1], 0)
    setsysvar(VarCfg["G_天选之人"][2], 4)
    sendmovemsg("0", 1, 253, 0, 300, 1,"天选之人：活动《天选之人》已手动结束...")
    sendmovemsg("0", 1, 249, 0, 250, 1,"天选之人：活动《天选之人》已手动结束...")
    sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>天选之人已手动结束</font>","Type":9}')
end

local function _admin_sbk_start(play)
    repaircastle()
    addattacksabakall()
    sendmovemsg("0", 1, 254, 0, 300, 1,"活动：活动《沙巴克》已手动开启...")
    sendmovemsg("0", 1, 254, 0, 270, 1,"活动：活动《沙巴克》已手动开启...")
    sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>沙巴克已手动开启</font>","Type":9}')
end

local function _admin_sbk_finish(play)
    _admin_not_ready(play, "沙巴克结束")
end
function ggna(play,id)
    if id == "1" then
        local item = linkbodyitem(play,73)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            deprivetitle(play,"狂暴之力")
            changecustomitemvalue(play,linkbodyitem(play,73),0,"=",0,1)
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        end
    elseif id == "2" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            changecustomitemvalue(play,item,0,"=",0,1)
            changecustomitemvalue(play,item,1,"=",0,1)
            changecustomitemvalue(play,item,2,"=",0,1)
            changecustomitemvalue(play,item,3,"=",0,1)
            changecustomitemvalue(play,item,4,"=",0,1)
            changecustomitemvalue(play,item,5,"=",0,1)
            changecustomitemvalue(play,item,6,"=",0,1)
            changecustomitemvalue(play,item,7,"=",0,1)
            changecustomitemvalue(play,item,8,"=",0,1)
            deprivetitle(play,"传功阁小神魔")
            deprivetitle(play,"传功阁大神魔")
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        end
    elseif id == "3" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            changecustomitemvalue(play,item,0,"=",0,0)
            changecustomitemvalue(play,item,1,"=",0,0)
            changecustomitemvalue(play,item,2,"=",0,0)
            changecustomitemvalue(play,item,3,"=",0,0)
            changecustomitemvalue(play,item,4,"=",0,0)
            changecustomitemvalue(play,item,5,"=",0,0)
            changecustomitemvalue(play,item,6,"=",0,0)
            changecustomitemvalue(play,item,7,"=",0,0)
            changecustomitemvalue(play,item,8,"=",0,0)
            changecustomitemvalue(play,item,9,"=",0,0)
            for i = 10, 200, 10 do
                deprivetitle(play,"神诀感悟："..i.."次")
            end
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        end
    elseif id == "4" then
        setbaseinfo(play,39,0)
        deprivetitle(play,"1重转生")
        deprivetitle(play,"2重转生")
        deprivetitle(play,"3重转生")
        deprivetitle(play,"4重转生")
        deprivetitle(play,"5重转生")
        deprivetitle(play,"6重转生")
        changecustomitemvalue(play,linkbodyitem(play,72),0,"=",0,2)
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
    elseif id == "5" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            changecustomitemvalue(play,item,0,"=",0,2)
            changecustomitemvalue(play,item,1,"=",0,2)
            changecustomitemvalue(play,item,2,"=",0,2)
            changecustomitemvalue(play,item,3,"=",0,2)
            changecustomitemvalue(play,item,4,"=",0,2)
            changecustomitemvalue(play,item,5,"=",0,2)
            changecustomitemvalue(play,item,6,"=",0,2)
            changecustomitemvalue(play,item,7,"=",0,2)
            changecustomitemvalue(play,item,8,"=",0,2)
            changecustomitemvalue(play,item,9,"=",0,2)
            deprivetitle(play,"八卦五重")
            deprivetitle(play,"八卦十重")
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        end
    elseif id == "6" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            changecustomitemvalue(play,item,0,"=",0,3)
            changecustomitemvalue(play,item,1,"=",0,3)
            changecustomitemvalue(play,item,2,"=",0,3)
            changecustomitemvalue(play,item,3,"=",0,3)
            changecustomitemvalue(play,item,4,"=",0,3)
            changecustomitemvalue(play,item,5,"=",0,3)
            changecustomitemvalue(play,item,6,"=",0,3)
            changecustomitemvalue(play,item,7,"=",0,3)
            changecustomitemvalue(play,item,8,"=",0,3)
            changecustomitemvalue(play,item,9,"=",0,3)
            changecustomitemvalue(play,item,0,"=",0,4)
            changecustomitemvalue(play,item,1,"=",0,4)
            changecustomitemvalue(play,item,2,"=",0,4)
            changecustomitemvalue(play,item,3,"=",0,4)
            deprivetitle(play,"仙法阁五重")
            deprivetitle(play,"仙法阁十重")
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        end
    elseif id == "7" then
        local item = linkbodyitem(play,71)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        end
    elseif id == "8" then
        local item = linkbodyitem(play,72)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            changecustomitemvalue(play,item,0,"-",100,0)
            changecustomitemvalue(play,item,1,"-",100,0)
            changecustomitemvalue(play,item,2,"-",5000,0)
            local data = json2tbl(getplaydef(play,VarCfg.T_ystz))
            data.xt1 = nil
            data.xt2 = nil
            data.xt3 = nil
            data.xt4 = nil
            data.xt5 = nil
            data.xt6 = nil
            data.xt7 = nil
            data.xt8 = nil
            setplaydef(play,VarCfg.T_ystz,tbl2json(data))
            deprivetitle(play,"天才地宝(地)")
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        end
    elseif id == "9" then
        local item = linkbodyitem(play,72)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            changecustomitemvalue(play,item,0,"-",250,0)
            changecustomitemvalue(play,item,1,"-",250,0)
            changecustomitemvalue(play,item,2,"-",10000,0)
            local data = json2tbl(getplaydef(play,VarCfg.T_ystz))
            data.yy1 = nil
            data.yy2 = nil
            data.yy3 = nil
            data.yy4 = nil
            data.yy5 = nil
            data.yy6 = nil
            data.yy7 = nil
            data.yy8 = nil
            setplaydef(play,VarCfg.T_ystz,tbl2json(data))
            deprivetitle(play,"天才地宝(天)")
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        end
    elseif id == "10" then
        local item = linkbodyitem(play,72)
        if item == "0" then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>数据异常</font>","Type":9}')
        else
            changecustomitemvalue(play,item,0,"-",500,0)
            changecustomitemvalue(play,item,1,"-",500,0)
            changecustomitemvalue(play,item,2,"-",20000,0)
            local data = json2tbl(getplaydef(play,VarCfg.T_ystz))
            data.xc1 = nil
            data.xc2 = nil
            data.xc3 = nil
            data.xc4 = nil
            data.xc5 = nil
            data.xc6 = nil
            data.xc7 = nil
            data.xc8 = nil
            setplaydef(play,VarCfg.T_ystz,tbl2json(data))
            deprivetitle(play,"天才地宝(神)")
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
        end
    elseif id == "11" then
        setplaydef(play,VarCfg.T_gjyj,'{"gjyj":[100000,100000,100000,100000,100000,100000,100000,100000,100000,0,0,0],"dhjl":[0,0,0,0,0,0,0,0,0]}')  --冠绝一界
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
    elseif id == "12" then
        setplaydef(play,VarCfg.T_gjyj,'{"gjyj":[100000,100000,100000,100000,100000,100000,100000,100000,100000,0,0,0],"dhjl":[1,1,1,1,1,0,0,0,0]}')  --冠绝一界
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
    elseif id == "13" then
        setbaseinfo(play,39,36)
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
    elseif id == "14" then
        callscriptex(play, "CHANGELEVEL", "=", 200)
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
    elseif id == "15" then
        local wpdx = linkbodyitem(play,76)
        local item = linkbodyitem(play,17)
        setitemcustomabil(play, wpdx,getitemcustomabil(play, item))
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
    elseif id == "16" then
        setplaydef(play,VarCfg.U_zllv,1)
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
    elseif id == "17" then
        local zl = json2tbl(getplaydef(play,VarCfg.T_zlxj))
        zl["dj"] = 1 + zl["dj"]
        setplaydef(play,VarCfg.T_zlxj,tbl2json(zl))
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>完成</font>","Type":9}')
    elseif id == "18" then
        if getplaydef(play,VarCfg.U_zxrw[1])then
            newdeletetask(play,getplaydef(play,VarCfg.U_zxrw[1]))
            playeffect(play,4011,25,-50,1,0,0)
        end
    elseif id == "19" then
        setplaydef(play,VarCfg.T_mjsj,'{"mjsj":[0,99,199,0,0,0,0,0,0,0,0,0]}')  --冠绝一界
    elseif id == "20" then
        setitemintparam(play,71,1,2)
    elseif id == "21" then
        repaircastle()
        addattacksabakall()
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>攻沙开始</font>","Type":9}')
    elseif id == "26" then
        _admin_qmdk_start(play)
    elseif id == "27" then
        _admin_qmdk_finish(play)
    elseif id == "28" then
        _admin_qmdt_start(play)
    elseif id == "29" then
        _admin_qmdt_finish(play)
    elseif id == "30" then
        _admin_wlmz_start(play)
    elseif id == "31" then
        _admin_wlmz_finish(play)
    elseif id == "32" then
        _admin_not_ready(play, "保卫村庄开始")
    elseif id == "33" then
        _admin_not_ready(play, "保卫村庄结束")
    elseif id == "34" then
        _admin_not_ready(play, "勇夺镖车开始")
    elseif id == "35" then
        _admin_not_ready(play, "勇夺镖车结束")
    elseif id == "36" then
        _admin_tcppk_start(play)
    elseif id == "37" then
        _admin_tcppk_finish(play)
    elseif id == "38" then
        _admin_not_ready(play, "天才地宝开始")
    elseif id == "39" then
        _admin_not_ready(play, "天才地宝结束")
    elseif id == "40" then
        _admin_txzr_start(play)
    elseif id == "41" then
        _admin_txzr_finish(play)
    elseif id == "42" then
        _admin_not_ready(play, "正邪大战开始")
    elseif id == "43" then
        _admin_not_ready(play, "正邪大战结束")
    elseif id == "44" then
        _admin_sbk_start(play)
    elseif id == "45" then
        _admin_sbk_finish(play)
    elseif id == "46" then
        _admin_not_ready(play, "讨伐BOSS开始")
    elseif id == "47" then
        _admin_not_ready(play, "讨伐BOSS结束")
    elseif id == "48" then
        _admin_sjdb_start(play)
    elseif id == "49" then
        _admin_sjdb_finish(play)
    elseif id == "50" then
        _admin_not_ready(play, "黑暗禁地开始")
    elseif id == "51" then
        _admin_not_ready(play, "黑暗禁地结束")
    elseif id == "25" then
        -- 大陆进入条件一键达成：主线进度、转生等级、剧情点
        local target_task = 21
        local target_zs = 40
        local target_jqd = 100

        local cur_task = tonumber(getplaydef(play, VarCfg.U_zxrw[1])) or 0
        if cur_task < target_task then
            setplaydef(play, VarCfg.U_zxrw[1], target_task)
        end

        local cur_zs_var = tonumber(getplaydef(play, VarCfg["U_转生等级"])) or 0
        if cur_zs_var < target_zs then
            setplaydef(play, VarCfg["U_转生等级"], target_zs)
        end

        local cur_zs_base = tonumber(getbaseinfo(play, 39)) or 0
        if cur_zs_base < target_zs then
            setbaseinfo(play, 39, target_zs)
        end

        local jqd_idx = tonumber(getstditeminfo("剧情点", 0)) or 0
        if jqd_idx > 0 then
            local cur_jqd = tonumber(querymoney(play, jqd_idx)) or 0
            if cur_jqd < target_jqd then
                changemoney(play, jqd_idx, "+", target_jqd - cur_jqd, "测试-大陆全解锁", true)
            end
        end

        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>大陆条件已一键解锁（主线>=21,转生>=40,剧情点>=100）</font>","Type":9}')
    elseif id == "23" then
        local cailiao = {
"山川神石【稀有】",
"海洋神石【稀有】",
"天空神石【稀有】",
"清风神石【稀有】",
"火焰神石【稀有】",
"满月神石【稀有】",
"大地神石【稀有】",
"雷电神石【稀有】",














        }
        for k, v in pairs(cailiao) do
            giveitem(play,v,1)
        end
    elseif id == "24" then
        -- 测试脚本：调整地图怪物密度（逐图刷小怪，9x9检测饱和）
--         local map_list = {
--             -- "山庄",
--             -- "幽谷",
--             -- "洞穴",
--             -- "古殿",
--             -- "山庄一",
--             -- "幽谷一",
--             -- "洞穴一",
--             -- "古殿一",
--             -- "隐藏地图二",
--             -- "野火帮",
--             -- "野火帮大营",
--             -- "极光城郊",
--             -- "神秘森林",
--             -- "兵道古藏",
--             -- "乱葬岗",
--             -- "夜魔洞",
--             -- "洞穴深处",
--             -- "洞穴秘境",

-- --             "灰界",
-- -- "灰界南部",
-- -- "灰界北部",
-- -- "灰界东部",
-- -- "灰界西部",
-- -- "虚妄山脉",
-- -- "鬼嘲深渊",
-- -- "叹息旷野",
-- -- "禁忌之海",
-- -- "藏星海",
-- -- "藏星外海",
-- -- "神秘岛屿",
-- -- "黑暗洞窟",
-- -- "千年沉船",
-- -- "船长室",
-- -- "水手舱",
-- -- "藏星内海",
-- -- "七星岛",
-- -- "葬星城",
-- -- "葬星海滩",
-- -- "葬星海滩1",
-- -- "苍云城",
-- -- "苍云城郊外",
-- -- "苍云内城",
-- -- "苍云客栈",
-- -- "草药谷",
-- -- "仙草田",
-- -- "草药古深处",
-- -- "丹道古藏",
-- -- "酆都鬼城",
-- -- "鬼门关",
-- -- "黄泉路",
-- -- "奈何桥",
-- -- "罗酆六天",
-- -- "十八层地狱",
-- -- "六道轮回",
-- -- "大唐·长安城",
-- -- "东海龙宫",
-- -- "黑风山",
-- -- "黄风岭",
-- -- "女儿国",
-- -- "通天河",
-- -- "狮驼岭",
-- -- "天竺山",
-- -- "火焰山",
-- -- "生肖灵域",
-- -- "灵域·一层",
-- -- "子鼠灵域",
-- -- "丑牛灵域",
-- -- "寅虎灵域",
-- -- "卯兔灵域",
-- -- "灵域·二层",
-- -- "辰龙灵域",
-- -- "巳蛇灵域",
-- -- "午马灵域",
-- -- "未羊灵域",
-- -- "灵域·三层",
-- -- "申猴灵域",
-- -- "酉鸡灵域",
-- -- "戌狗灵域",
-- -- "亥猪灵域",
-- -- "灵域·秘境",
-- -- "传说之地",
-- -- "盘古开天",
-- -- "羿射九日",
-- -- "不周山",
-- -- "女娲补天",
-- -- "黑白无常",
-- -- "后土娘娘",
-- -- "真假玉帝",
-- -- "白蛇传说",
-- -- "灵兽谷",
-- -- "青龙之境",
-- -- "朱雀之境",
-- -- "玄武之境",
-- -- "白虎之境",
-- -- "麒麟之境",
-- -- "时空裂隙",
-- -- "倚天江湖",
-- -- "冰火岛",
-- -- "光明顶",
-- -- "三国乱世",
-- -- "虎牢关",
-- -- "赤壁",
-- -- "水浒再临",
-- -- "景阳冈",
-- -- "狮子楼",
-- -- "生命边界",
-- -- "白骨神庙",
-- -- "神庙暗廊",
-- -- "诡冥墨河",
-- -- "河神寝宫",
-- -- "赤焰焚殿",
-- -- "赤焰焚殿二层",
-- -- "赤焰焚殿三层",
-- -- "葬天旧土",
-- -- "聊斋志异",
-- "兰若寺",
-- "画壁",
-- "崂山",
-- "罗刹海市",
-- "敦煌遗梦",
-- "莫高窟",
-- "月牙泉",
-- "玉门关",
-- "阳关道",
-- "世界禁墟",
-- "大地禁墟一层",
-- "大地禁墟二层",
-- "大地禁墟三层",
-- "天空禁墟一层",
-- "天空禁墟二层",
-- "天空禁墟三层",
-- "海洋禁墟一层",
-- "海洋禁墟二层",
-- "海洋禁墟三层",
-- "青铜禁墟一层",
-- "青铜禁墟二层",
-- "青铜禁墟三层",
--         } -- TODO: 填入要调整的地图名
--         local normal_mobs = {"枯灯客"} -- TODO: 普通怪列表

--         local range = 3 -- 刷怪点随机半径
--         local check_range = 6 -- 9x9检测半径(2*4+1)
--         local max_fail = 40 -- 连续失败上限(饱和)
--         local tries_per_spawn = 10 -- 每次刷怪找点尝试次数
--         local spawn_limit = 5000 -- 每张地图单次补怪上限

--         for _, map in ipairs(map_list) do
--             local w = getmapinfo(map, 0) or 0
--             local h = getmapinfo(map, 1) or 0
--             if w > 0 and h > 0 then
--                 -- 检测前先清空地图怪物
--                 killmonsters(map, "*", 0, false)

--                 local counter = {n = 0}
--                 local added_normal = 0
--                 local sample_count = 0
--                 local total_ncnt = 0

--                 local fail_streak = 0
--                 local used_points = {}

--                 while fail_streak < max_fail do
--                     local rx = math.random(1, w)
--                     local ry = math.random(1, h)

--                     local key = rx.."_"..ry
--                     if used_points[key] then
--                         fail_streak = fail_streak + 1
--                     else
--                         local ok = true
--                         for k, _ in pairs(used_points) do
--                             local sx, sy = k:match("(%d+)_([%d]+)")
--                             if sx and sy then
--                                 sx = tonumber(sx)
--                                 sy = tonumber(sy)
--                                 if math.abs(rx - sx) <= check_range and math.abs(ry - sy) <= check_range then
--                                     ok = false
--                                     break
--                                 end
--                             end
--                         end

--                         if ok then
--                             genmonex(map, rx, ry, normal_mobs[math.random(1, #normal_mobs)], 1, 1, 0, 54, "", 0)
--                             used_points[key] = true
--                             counter.n = counter.n + 1
--                             added_normal = added_normal + 1
--                             fail_streak = 0
--                         else
--                             fail_streak = fail_streak + 1
--                         end
--                     end

--                     sample_count = sample_count + 1
--                     total_ncnt = total_ncnt + (used_points[key] and 1 or 0)

--                     if counter.n >= spawn_limit then
--                         break
--                     end
--                 end
--                     local avg_n = math.floor(total_ncnt / math.max(1, sample_count) + 0.5)
--                     sendmsg(play, 1, "{\"Msg\":\"<font color=\\\"#00ff00\\\">地图["..map.."] 小怪补："..added_normal.." 当前平均："..avg_n.."</font>\",\"Type\":9}")
--                     release_print("地图["..map.."] 小怪补："..added_normal)
--                     release_print("当前平均 小怪："..avg_n)
--             else
--                 sendmsg(play, 1, '{"Msg":"<font color=\"#ff0000\">地图['..map..']尺寸获取失败</font>","Type":9}')
--             end
--         end
--         return
        -- local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
        -- jq_data["npc_714"] = nil
        -- Player.setJsonTableByVar(play, VarCfg.T_dljq, jq_data)
        -- local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
        -- sg_data["npc_696"] = sg_data["npc_696"] + 100
        -- Player.setJsonTableByVar(play, VarCfg["T_各剧情杀怪"], sg_data)
        		sendmsgnew(play, 255, 0, '狂暴之力：玩家{《' .. getbaseinfo(play, 1) .. '》/FCOLOR=251}成功开启{[狂暴之力]/FCOLOR=250},击杀此人可获得额外奖励...', 1, 3)



        -- Npclib[654].link(play, 654, 1, 0, "")

        -- local where = Player.hasEquipInArtifactSlot(play, "金箍棒")
        -- -- release_print(where)
        -- if not where then
        --     Player.sendmsgEx(play, "你需要装备金箍棒才能完成任务#57")
        --     return
        -- end
        -- local itemobj = linkbodyitem(play,where)
        -- local item_json = getitemcustomabil(play, itemobj)
        -- release_print(item_json)
        -- item_json = json2tbl(item_json)
        -- if item_json then
        --     item_json = json2tbl('{"abil":[{"i":0,"t":"[附加属性]","c":251,"v":[]}],"name":""}')
        -- end
        -- item_json.abil[1].v[1] = {1,253,200,1,13,1,1}
        -- item_json.abil[1].v[2] = {1,200,300,1,14,2,2}
        -- item_json.abil[1].v[3] = {1,244,8000,0,15,3,3}
        -- item_json.abil[1].v[4] = {1,30,5,1,16,4,4}
        -- item_json.abil[1].v[5] = {1,73,100,1,17,5,5}
        -- item_json.abil[1].v[6] = {1,89,100,1,18,6,6}
        -- item_json.abil[1].v[7] = {1,206,100,1,19,7,7}
        -- item_json = tbl2json(item_json)
        -- -- release_print(type(item_json))
        -- setitemcustomabil(play, itemobj, item_json)
        -- Player.setJsonVarByTable(play, VarCfg["T_砍树系统"], {})
        -- setplaydef(play, VarCfg.T_czlb,"{}")
        -- setplaydef(play,VarCfg.U_zxrw[1],21)
        -- setplaydef(play,VarCfg.T_hsdg, '{"1_1_1":1,"1_1_2":1,"1_1_3":1,"1_1_4":1,"1_1_5":1,"1_1_6":1,"1_1_7":1,"1_1_8":1,"1_1_9":1,"1_1_10":1,"1_1_11":1,"1_1_12":1}')--回收打勾

    end

end

return npc














