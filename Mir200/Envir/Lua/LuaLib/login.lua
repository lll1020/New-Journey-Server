Login = {}
function Login.main(play)
    local weizhi = linkbodyitem(play,17)
    if weizhi == "0" then
        setsndaitembox(play,1) --首饰盒
        setbagcount(play,126) --格子
        giveonitem(play,17,"时装衣服",1)
        setitemcustomabil(play,linkbodyitem(play,17),'{"abil":[{"i":0,"t":"[时装衣服]:","c":251,"v":[[-1,243,0,1,0,0,0],[-1,1,0,0,0,1,1],[-1,14,0,0,0,1,2],[-1,25,0,0,0,2,3],[-1,4,0,0,0,2,4],[-1,22,0,1,0,3,5],[-1,9,0,0,0,3,6],[-1,10,0,0,0,4,7],[-1,11,0,0,0,5,8]]},{"i":1,"t":"[时装衣服]:","c":251,"v":[[-1,12,0,0,0,0,0],[-1,89,0,2,0,1,1],[-1,245,0,2,0,2,2],[-1,76,0,2,0,3,3],[-1,79,0,2,0,3,4],[-1,25,0,2,0,4,5],[-1,73,0,2,0,5,6],[-1,242,0,2,0,6,7],[-1,73,0,2,0,7,8]]},{"i":2,"t":"[时装衣服]:","c":251,"v":[[-1,12,0,0,0,0,0],[-1,77,0,2,0,1,1],[-1,245,0,2,0,2,2],[-1,76,0,2,0,3,3],[-1,79,0,2,0,3,4],[-1,204,0,2,0,4,5],[-1,205,0,2,0,5,6],[-1,246,0,2,0,6,7],[-1,73,0,2,0,7,8]]}],"name":""}')
        giveonitem(play,71,"附加属性",1)
        setitemcustomabil(play,linkbodyitem(play,71),'{"abil":[{"i":0,"t":"[淬体属性]:","c":251,"v":[[-1,3,0,0,0,0,0],[-1,4,0,0,0,0,1],[-1,1,0,0,0,1,2],[-1,5,0,0,0,2,3],[-1,6,0,0,0,3,4],[-1,7,0,0,0,4,5],[-1,8,0,0,0,5,6]]},{"i":1,"t":"[吐纳]:","c":251,"v":[[-1,4,0,1,0,0,0],[-1,25,0,1,0,1,1],[-1,4,0,1,0,2,2],[-1,28,0,1,0,3,3],[-1,60,0,1,0,4,4],[-1,1,0,1,0,5,5],[-1,1,0,0,0,6,6],[-1,10,0,0,0,7,7],[-1,244,0,0,0,8,8],[-1,242,0,1,0,9,9]]},{"i":2,"t":"[剑匣]:","c":251,"v":[[-1,4,0,1,0,0,0],[-1,6,0,1,0,1,1],[-1,8,0,1,0,2,2],[-1,1,0,1,0,3,3],[-1,10,0,1,0,4,4],[-1,12,0,1,0,5,5],[-1,21,0,0,0,6,6],[-1,22,0,0,0,7,7],[-1,200,0,0,0,8,8]]},{"i":3,"t":"[吐纳]:","c":251,"v":[[-1,245,0,1,0,0,0],[-1,21,0,1,0,1,1],[-1,22,0,1,0,2,2],[-1,25,0,1,0,3,3],[-1,200,0,1,0,4,4],[-1,206,0,1,0,5,5],[-1,4,0,1,10,6,6],[-1,999,0,1,4,8,8],[-1,1,0,1,4,6,8],[-1,9999,0,0,5,7,9]]},{"i":4,"t":"[吐纳]:","c":251,"v":[[-1,999,0,1,10,0,0],[-1,4,0,1,10,0,1],[-1,999,0,1,4,1,2],[-1,1,0,1,4,1,3]]},{"i":5,"t":"[人物修为]:","c":251,"v":[[-1,1,0,0,0,0,0],[-1,3,0,0,0,1,1],[-1,4,0,0,0,2,2],[-1,5,0,0,0,3,3],[-1,6,0,0,0,4,4],[-1,7,0,0,0,5,5],[-1,8,0,0,0,6,6],[-1,245,0,0,0,7,7],[-1,242,0,0,0,8,8]]}],"name":""}')
        giveonitem(play,72,"额外属性",1)
        setitemcustomabil(play,linkbodyitem(play,72),'{"abil":[{"i":0,"t":"[吃属性]:","c":251,"v":[[-1,244,0,0,0,0,0],[-1,3,0,1,0,1,1],[-1,4,0,1,0,2,2],[-1,1,0,1,0,3,3],[-1,244,0,0,0,4,4]]},{"i":1,"t":"[八门]:","c":251,"v":[[-1,4,0,0,0,0,0],[-1,10,0,0,0,1,1],[-1,12,0,0,0,2,2],[-1,1,0,0,0,3,3],[-1,248,0,0,0,4,4],[-1,255,0,0,0,5,5],[-1,61,0,0,0,6,6],[-1,245,0,1,0,7,7],[-1,242,0,1,0,8,8],[-1,253,0,1,0,9,9]]}],"name":""}')
        giveonitem(play,73,"称号属性",1)
        setitemcustomabil(play,linkbodyitem(play,73),'{"abil":[{"i":0,"t":"[剧情称号属性]:","c":251,"v":[[-1,3,0,1,0,0,0],[-1,4,0,1,0,0,1],[-1,5,0,1,0,1,2],[-1,6,0,1,0,1,3],[-1,7,0,1,0,2,4],[-1,8,0,1,7,2,5],[-1,9,0,1,0,3,6],[-1,10,0,1,0,3,7],[-1,11,0,1,0,4,8],[-1,12,0,1,0,4,9]]},{"i":1,"t":"[剧情称号属性]:","c":251,"v":[[-1,1,0,1,0,0,0],[-1,253,0,1,0,1,1],[-1,3,0,0,2,2,2],[-1,4,0,0,2,2,3],[-1,25,0,1,0,3,4],[-1,30,0,1,0,4,5],[-1,22,0,1,0,5,6],[-1,21,0,1,0,6,7],[-1,1,0,0,0,7,8]]},{"i":2,"t":"[剧情称号属性]:","c":251,"v":[[-1,999,0,1,4,0,0],[-1,1,0,1,4,0,1],[-1,999,0,1,10,1,2],[-1,4,0,1,10,1,3],[-1,82,0,1,0,2,4],[-1,200,0,1,0,3,5],[-1,201,0,1,0,4,6],[-1,77,0,1,0,5,7],[-1,67,0,1,0,6,8]]},{"i":3,"t":"[命石属性]:","c":251,"v":[[-1,89,0,1,0,0,0],[-1,21,0,1,0,0,1],[-1,73,0,1,0,1,2],[-1,243,0,1,0,1,3],[-1,28,0,1,0,2,4],[-1,200,0,1,0,3,5],[-1,201,0,1,0,4,6],[-1,77,0,1,0,5,7],[-1,67,0,1,0,6,8]]}],"name":""}')
        giveonitem(play,87,"多余附加属性",1)
        setitemcustomabil(play,linkbodyitem(play,87),'{"abil":[{"i":0,"t":"[五行尊者]:","c":251,"v":[[-1,244,0,0,0,0,0],[-1,1,0,0,0,1,1],[-1,248,0,0,0,2,2],[-1,9,0,0,0,3,3],[-1,10,0,0,0,4,4],[-1,11,0,0,0,5,5],[-1,12,0,0,0,6,6],[-1,245,0,0,0,7,7]]},{"i":1,"t":"[淬体]:","c":251,"v":[[-1,244,0,0,0,0,0],[-1,1,0,0,0,1,1],[-1,248,0,0,0,2,2],[-1,3,0,0,0,3,3],[-1,4,0,0,0,4,4],[-1,242,0,0,0,5,5],[-1,12,0,0,0,6,6],[-1,245,0,0,0,7,7]]},{"i":2,"t":"[仙食房]:","c":251,"v":[[-1,9,0,0,0,0,0],[-1,10,0,0,0,1,1],[-1,11,0,0,0,2,2],[-1,12,0,0,0,3,3],[-1,1,0,0,0,4,4],[-1,244,0,0,0,5,5],[-1,4,0,0,0,6,6],[-1,242,0,0,0,7,7],[-1,245,0,0,0,8,8]]},{"i":3,"t":"[护体罡气]:","c":251,"v":[[-1,1,0,0,0,0,0],[-1,1,0,1,0,1,1],[-1,9,0,1,0,2,2],[-1,10,0,1,0,3,3],[-1,11,0,1,0,4,4],[-1,12,0,1,0,5,5]]},{"i":4,"t":"[仙莲]:","c":251,"v":[[-1,4,0,0,0,0,0],[-1,6,0,0,0,1,1],[-1,8,0,0,0,2,2],[-1,242,0,0,0,3,3],[-1,245,0,0,0,4,4]]}],"name":""}')
        giveonitem(play,104,"超多余附加属性",1)
        setitemcustomabil(play,linkbodyitem(play,104),'{"abil":[{"i":0,"t":"[技能强化]:","c":251,"v":[[-1,242,0,0,0,0,0],[-1,4,0,1,0,1,1],[-1,4,0,1,0,2,2],[-1,1,0,1,0,3,3],[-1,245,0,0,0,4,4],[-1,82,0,0,0,5,5],[-1,39,0,0,0,6,6],[-1,4,0,1,0,7,7]]},{"i":1,"t":"[丹药属性]:","c":251,"v":[[-1,4,0,0,0,0,0],[-1,1,0,0,0,1,1],[-1,4,0,1,0,2,2],[-1,1,0,1,0,3,3],[-1,242,0,1,0,4,4],[-1,244,0,0,0,5,5],[-1,67,0,1,0,6,6],[-1,21,0,1,0,7,7],[-1,25,0,1,0,8,8],[-1,22,0,1,0,9,9]]},{"i":2,"t":"[转生属性]:","c":251,"v":[[-1,1,0,1,0,0,0],[-1,3,0,1,0,1,1],[-1,4,0,1,0,2,2],[-1,9,0,1,0,3,3],[-1,10,0,1,0,4,4],[-1,11,0,1,0,5,5],[-1,12,0,1,0,6,6]]},{"i":3,"t":"[群切强化]:","c":251,"v":[[-1,1,0,1,0,0,0],[-1,3,0,1,0,1,1],[-1,4,0,1,0,2,2],[-1,5,0,1,0,3,3],[-1,6,0,1,0,4,4],[-1,7,0,1,0,5,5],[-1,8,0,1,0,6,6],[-1,245,0,0,0,7,7]]},{"i":4,"t":"[戮仙剑戮仙甲]:","c":251,"v":[[-1,3,0,0,0,0,0],[-1,4,0,1,0,1,1],[-1,245,0,0,0,2,2],[-1,1,0,0,0,3,3],[-1,1,0,1,0,4,4],[-1,89,0,0,0,5,5],[-1,36,0,0,0,6,6],[-1,37,0,0,0,7,7]]}],"name":""}')
        changemoney(play, 19, '=', 1000, '初始', true)
        addbuff(play,19999) --新手泡点buff
        setplaydef(play,constant.T_sgcf,"{}")--杀怪触发
        setplaydef(play,constant.T_hsdg, '{"1_1_1":1,"1_1_2":1,"1_1_3":1,"1_2_1":1,"1_2_2":1,"1_3_1":1,"1_3_2":1,"1_3_3":1}')--回收打勾
        setflagstatus(play,constant.BS_huishou[1],1)
        setflagstatus(play,constant.BS_huishou[2],1)
        setflagstatus(play,constant.BS_huishou[3],1)
        setflagstatus(play,constant.BS_huishou[4],1)
        setflagstatus(play,constant.BS_huishou[5],1)
        setplaydef(play,constant.T_dljq,"{}")--各剧情JSON
        setplaydef(play,constant.T_czlb,"{}")--各种礼包
        setplaydef(play,constant.T_jls,"{}")--记录石
        setplaydef(play,constant.T_zxrw,"{}")--支线任务序号
        setplaydef(play,constant.T_rwjl,"{}")--任务领取记录
        setplaydef(play,constant.T_xybl,"{}")--幸运爆率
        setplaydef(play,constant.T_grss,"{}")--个人首爆
        setplaydef(play,constant.T_qrbq,"{}")--福利大厅
        setplaydef(play,constant.T_szjl,"{}")--时装记录
        setplaydef(play,constant.T_xldtsg,"{}")--系列地图杀怪
        setplaydef(play,constant.T_xldtsgjl,"{}")--系列地图杀怪奖励
        setplaydef(play,constant.T_aigj,"{}")--ai挂机
        setplaydef(play,constant.T_rwwp,"{}")--任务物品
        setplaydef(play,constant.T_ywl,"{}")--异闻录
        setplaydef(play,constant.T_hdjl,"{}")--活动奖励
        setplaydef(play,constant.T_zscl,"{}")--转生材料掉落
        setplaydef(play,constant.T_txzr,"{}")--天选之人点数
        setplaydef(play,constant.T_sq_jd,"{}")--必爆神器计数
        setplaydef(play,constant.T_tshs,"{}")--特殊回收
        setplaydef(play,constant.T_rwsg,"{}")--特殊任务杀怪
        setplaydef(play,constant.T_dlsgjl,"{}")--大陆杀怪数量



        if getsysvar(constant.G_kqyz) == 0 then
            setsysvar(constant.G_kqyz,1)
            setsysvar(constant.G_kqts,1)
            setsysvar(constant.A_qqsb,"{}")  --全区首爆
            setsysvar(constant.A_bossss,"{}")  --boss首杀
        end
        Login_msg(play,0)

        --TODO  初始化任务
        setplaydef(play,constant.U_zxrw[1],1)
        mapmove(play,"新手地图",127,268,2)
    end



    --全区通报登录
    if checktitle(play,"踏月主宰") then
        sendmovemsg("0", 1, 253, 0, 200, 1,"[冠名]玩家《"..getbaseinfo(play, 1).."》登录，全服瞩目...")
    end

    if getconst(play, '<$SERVERNAME>') == "测试区" or getconst(play, '<$SERVERNAME>') == "直播区" or getconst(play, '<$SERVERNAME>') == "审核区1区" or getconst(play, '<$SERVERNAME>') == "" then
        setgmlevel(play, 10)
        if getconst(play, '<$SERVERNAME>') == "直播区" then
            shaguai.jia(play,99)   --直播杀怪c
            setplaydef(play,constant.U_zxrw[1],0)
            addskill(play,82,3)
            addskill(play,71,3)
            addskill(play,18,3)
        end
    end

    --------------------------------------------------临时脚本
    repairall(play)--修复全身
    setbaseinfo(play,33,0)----设置光头
    setflagstatus(play,300,0) --取消挂机配置标识
    pickupitems(play,0,5,500) --自动捡物
    login_fhsx(play) --封号刷新
    ---------------------------------------------------福利大厅杀怪数量
    ---------------------------------------------------在线时间
    setontimer(play, 4, 60, 0, 1)


    iniplayvar(play, "integer", "HUMAN", "武林盟主")
    iniplayvar(play, "integer", "HUMAN", "阵营对抗")
    iniplayvar(play, "integer", "HUMAN", "跨服对抗积分")

    iniplayvar(play, "integer","HUMAN","除魔大陆")
    iniplayvar(play, "integer","HUMAN","除魔大怪数量")
    iniplayvar(play, "integer","HUMAN","除魔小怪数量")
    iniplayvar(play, "integer","HUMAN","比武大会")
    iniplayvar(play, "integer","HUMAN","每日副本")
    -----------------------------------------------------任务初始化 --除魔
    local dl,boss,xg = getplayvar(play,"除魔大陆"),getplayvar(play,"除魔大怪数量"),getplayvar(play,"除魔小怪数量")
    if dl ~= 0 and dl ~= 100 then
        newpicktask(play,1300,dl,boss,xg)
    end
    ---------------------------------------------------任务初始化
    local rwid = getplaydef(play,constant.U_zxrw[1])
    local chuli = json2tbl(getplaydef(play, constant.T_zxrw))
    local chuliwp = json2tbl(getplaydef(play, constant.T_rwwp))
    if chuli ~= "{}" then
        for v,k in pairs(chuli) do
            newpicktask(play,tonumber(v),k and 0 or tonumber(k))
            if constant.rw_syb[tonumber(v)] and constant.rw_syb[tonumber(v)].sjwp then
                local sl = {}
                -- 获取表的键并排序
                local keys = {}
                for k in pairs(constant.rw_syb[tonumber(v)].sjwp) do
                    table.insert(keys, k)
                end
                table.sort(keys)
                for i, y in ipairs(keys) do
                    if chuliwp[y] then
                        table.insert(sl,getbagitemcount(play,y) >= constant.rw_syb[tonumber(v)].sjwp[y] and constant.rw_syb[tonumber(v)].sjwp[y] or getbagitemcount(play,y))
                    else
                        table.insert(sl,constant.rw_syb[tonumber(v)].sjwp[y])
                    end
                end
                -- 调用newpicktask函数，并将sj表中的元素作为参数传入
                newchangetask(play, tonumber(v),unpack(sl))
            end
            Player.zxrw_teshushuaxin(play, tonumber(v), nil)
        end
    end
    if constant.rw_syb[rwid] then
        local sy,sl = getplaydef(play,constant.U_zxrw[1]),getplaydef(play,constant.U_zxrw[2])
        newpicktask(play,sy,sl)
        if linkbodyitem(play,2) ~= "0" and rwid == 49 then
            newchangetask(play,sy,sl)
        end
        if constant.rw_syb[rwid].jd then
            local db = json2tbl(getplaydef(play,constant.T_dljq))
            if db[constant.rw_syb[rwid].jd[1]] and constant.rw_syb[rwid].jd[2] == 1 then
                newchangetask(play, rwid,db[constant.rw_syb[rwid].jd[1]][2])
                --release_print("任务初始化"..rwid..db[constant.rw_syb[rwid].jd[1]][2])
            elseif db[constant.rw_syb[rwid].jd[1]] and db[constant.rw_syb[rwid].jd[1]] == 1 and constant.rw_syb[rwid].jd[2] == 0 then
                if constant.rw_syb[rwid].sjwp then
                    local sl = {}
                    -- 获取表的键并排序
                    local keys = {}
                    for k in pairs(constant.rw_syb[rwid].sjwp) do
                        table.insert(keys, k)
                    end
                    table.sort(keys)
                    for i, y in ipairs(keys) do
                        if chuliwp[y] then
                            table.insert(sl,getbagitemcount(play,y) >= constant.rw_syb[rwid].sjwp[y] and constant.rw_syb[rwid].sjwp[y] or getbagitemcount(play,y))
                        else
                            table.insert(sl,constant.rw_syb[rwid].sjwp[y])
                        end
                    end
                    -- 调用newpicktask函数，并将sj表中的元素作为参数传入
                    newchangetask(play, rwid,unpack(sl))
                end
            end
        end
        if rwid == 1 then
            sendluamsg(play,101,28,0,getflagstatus(play,constant.BS_xslb),"")
        end
        if constant.rw_syb[sy] and constant.rw_syb[sy].sg then
            if sl > 0 then
                shaguai.jia(play,24)
                setplaydef(play,constant.N_znpc,1)
            end
        end
        Player.zxrw_teshushuaxin(play, rwid, nil)
    elseif rwid == 51 then
        --newpicktask(play,51,getplaydef(play,constant.U_zxrw[2]))
    end
    ---------------------------------------------------客户端同步数据
    local zhid = tonumber(getconst(play,"<$USERACCOUNT>"))
    if constant.pz_zbfc[zhid] then
        sendluamsg(play,103,1,0,0,'{"kqfz":'..getsysvar(constant.G_kqfz)..',"kqts":'..getsysvar(constant.G_kqts)..',"rwid":'..(getplaydef(play,constant.U_zxrw[1]))..',"ngkg":'..getflagstatus(play,constant.BS_ngkg)..',"sczt":'..getflagstatus(play,constant.BS_sckg)..',"hqcs":'..globalinfo(3)..',"zhuboma":'.. 1 ..',"tsqb":'..getflagstatus(play,constant.BS_tsqb)..',"zbfc":1'..'}')
    else
        sendluamsg(play,103,1,0,0,'{"kqfz":'..getsysvar(constant.G_kqfz)..',"kqts":'..getsysvar(constant.G_kqts)..',"rwid":'..(getplaydef(play,constant.U_zxrw[1]))..',"ngkg":'..getflagstatus(play,constant.BS_ngkg)..',"sczt":'..getflagstatus(play,constant.BS_sckg)..',"hqcs":'..globalinfo(3)..',"zhuboma":'.. 1 ..',"tsqb":'..getflagstatus(play,constant.BS_tsqb)..',"U_dlxz_bc":'..getplaydef(play,constant.U_dlxz_bc)..'}')
    end

    ---------------------------------------------------自动相关
    --if getflagstatus(play,constant.BS_huishou[1]) == 1 then
    --    sendmsg(play,1,'{"Msg":"[自动吃灵符已开启]","FColor":219,"BColor":255,"Type":1}')
    --else
    --    sendmsg(play,1,'{"Msg":"[自动吃灵符已关闭]","FColor":56,"BColor":255,"Type":1}')
    --end
    --if getflagstatus(play,constant.BS_huishou[2]) == 1 then
    --    sendmsg(play,1,'{"Msg":"[自动吃经验已开启]","FColor":219,"BColor":255,"Type":1}')
    --else
    --    sendmsg(play,1,'{"Msg":"[自动吃经验已关闭]","FColor":56,"BColor":255,"Type":1}')
    --end
    --if getflagstatus(play,constant.BS_huishou[3]) == 1 then
    --    sendmsg(play,1,'{"Msg":"[自动分解已开启]","FColor":219,"BColor":255,"Type":1}')
    --else
    --    sendmsg(play,1,'{"Msg":"[自动分解已关闭]","FColor":56,"BColor":255,"Type":1}')
    --end
    if getflagstatus(play,constant.BS_huishou[4]) == 1 then
        sendmsg(play,1,'{"Msg":"[自动回收已开启]","FColor":219,"BColor":255,"Type":1}')
    else
        sendmsg(play,1,'{"Msg":"[自动回收已关闭]","FColor":56,"BColor":255,"Type":1}')
    end
    ---------------------------------------------------时装记录
    --local szjl = json2tbl(getplaydef(play,constant.T_szjl))
    --if szjl["dqsz"] and szjl["dqsz"] > 0 then
    --    changeitemshape(play,linkbodyitem(play,17),sz["sz"][szjl["dqsz"]]["wx"])
    --end
    --if szjl["dqgh"] and szjl["dqgh"] > 0 then
    --    playeffect(play,sz["gh"][szjl["dqgh"]]["wx"],0,0,0,1,0)
    --end
    --if szjl["dqzj"] and szjl["dqzj"] > 0 then
    --    setmoveeff(play,sz["zj"][szjl["dqzj"]]["wx"],0)
    --end

    ---------------------------------------------------顶戴
    if checktitle(play,"狂暴之力") then
        seticon(play,0,1,10294,0,0,0,0,0)
    end

    ---------------------------------------------------复活次数
    if querymoney(play,15) < querymoney(play,14) and not hasbuff(play,20078) then
        changemoney(play,15,"=",querymoney(play,14),"初始化复活",true)
    elseif querymoney(play,16) > 0 and not hasbuff(play,20060) then
        changemode(play,23,999999999,querymoney(play,15)+1)
    else
        changemode(play,23,999999999,querymoney(play,15))
    end
    -----------------------------------------------------活动初始化

    Buff.login(play) --初始化buff
    Login_jnsh(play)  --技能伤害加载
    Login_jmjnsh(play)  --减免技能伤害加载
end


return Login