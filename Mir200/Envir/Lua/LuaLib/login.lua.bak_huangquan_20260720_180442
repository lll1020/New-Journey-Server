Login = {}

-- 灰界视野限制：无【诸邪退散】时缩小照明范围。
function Login.isGrayWorldMap(mapName)
    if Player and Player.isHuiJieMap then
        return Player.isHuiJieMap(mapName)
    end
    mapName = tostring(mapName or "")
    return mapName == "灰界"
        or mapName == "灰界南部"
        or mapName == "灰界北部"
        or mapName == "灰界东部"
        or mapName == "灰界西部"
        or mapName == "虚妄山脉"
        or mapName == "山脉入口"
        or mapName == "鬼嘲深渊"
        or mapName == "旷野之原"
        or mapName == "叹息旷野"
        or mapName == "恐怖裂隙"
        or mapName == "禁忌之海"
        or mapName == "海峰孤岛"
end
function Login.refreshGrayWorldVision(play)
    local cur_map = tostring(getbaseinfo(play, 3) or "")
    if Login.isGrayWorldMap(cur_map) and not checktitle(play, "诸邪退散") then
        setcandlevalue(play, 10)
    else
        setcandlevalue(play, 20)
    end
end
function Login.main(play)
    local weizhi = linkbodyitem(play,17)
    local isnewhuman = false
    if weizhi == "0" then
        setsndaitembox(play,1) --首饰盒
        setbagcount(play,126) --格子
        giveonitem(play,17,"时装衣服",1)
        addbuff(play,19999) --新手泡点buff
        setflagstatus(play,VarCfg.BS_huishou[1],1)
        setflagstatus(play,VarCfg.BS_huishou[2],1)
        setflagstatus(play,VarCfg.BS_huishou[3],1)
        setflagstatus(play,VarCfg.BS_huishou[4],1)
        setflagstatus(play,VarCfg.BS_huishou[5],1)
        setplaydef(play,VarCfg.T_sgcf,"{}")--杀怪触发
        setplaydef(play,VarCfg.T_hsdg,"{}")--回收打勾
        setplaydef(play,VarCfg.T_dljq,"{}")--各剧情JSON
        setplaydef(play,VarCfg.T_czlb,"{}")--各种礼包
        setplaydef(play,VarCfg["T_首冲礼包"],"{}")--首冲礼包
        setplaydef(play,VarCfg.T_jls,"{}")--记录石
        setplaydef(play,VarCfg.T_zxrw,"{}")--支线任务序号
        setplaydef(play,VarCfg.T_rwjl,"{}")--任务领取记录
        setplaydef(play,VarCfg.T_xybl,"{}")--幸运爆率
        setplaydef(play,VarCfg.T_qrbq,"{}")--福利大厅
        setplaydef(play,VarCfg.T_szjl,"{}")--时装记录
        setplaydef(play,VarCfg.T_xldtsg,"{}")--系列地图杀怪
        setplaydef(play,VarCfg.T_xldtsgjl,"{}")--系列地图杀怪奖励
        setplaydef(play,VarCfg.T_aigj,"{}")--ai挂机
        setplaydef(play,VarCfg.T_rwwp,"{}")--任务物品
        setplaydef(play,VarCfg.T_ywl,"{}")--异闻录
        setplaydef(play,VarCfg.T_hdjl,"{}")--活动奖励
        setplaydef(play,VarCfg.T_zscl,"{}")--转生材料掉落
        setplaydef(play,VarCfg.T_sq_jd,"{}")--必爆神器计数
        setplaydef(play,VarCfg.T_tshs,"{}")--特殊回收
        setplaydef(play,VarCfg.T_rwsg,"{}")--特殊任务杀怪
        setplaydef(play,VarCfg.T_dlsgjl,"{}")--大陆杀怪数量
        setplaydef(play, VarCfg["U_登录天数"], 1)
        local T_txzr = {}
        for i = 1 ,4 do
            table.insert(T_txzr,math.random(100000))
        end
        setplaydef(play,VarCfg.T_txzr,tbl2json(T_txzr))  --天选之人点数
        if getsysvar(VarCfg["G_新区验证"]) == 0 then
            setsysvar(VarCfg["G_新区验证"],1)
            setsysvar(VarCfg["G_开区天数"],1)
            setsysvar(VarCfg["A_全区首曝json"],"{}")  --全区首爆
            isnewhuman = true
        end
        Login_msg(play,0)
        --TODO  初始化任务
        setplaydef(play,VarCfg.U_zxrw[1],1)
        mapmove(play,"xtc",137,138,7)
        setbaseinfo(play,57,0)
        sendluamsg(play, 101, 18, 0, 0, "")
    end
    -- 统一迁移自动回收勾选，保证新区默认项和旧号兼容规则一致。
    Player.ensureRecycleSelectConfig(play)
    -- 首充礼包状态：领取任意 1 格后同步天选资格。
    local sc_data = Player.getJsonTableByVar(play, VarCfg["T_首充礼包"]) or {}
    local sc_claimed = tonumber(sc_data.main_claimed or sc_data.other_lb or 0) or 0
    setflagstatus(play,VarCfg.BS_sckg,(sc_claimed >= 1) and 1 or 0)
    iniplayvar(play, "integer","HUMAN","比武大会")
    iniplayvar(play, "integer","HUMAN","全民夺矿")
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    if (jq_data["npc_55"] and jq_data["npc_55"] >= 2) and getflagstatus(play, VarCfg.BS_mztq) == 1 then
        Npclib['anniu'][30](play, 3, 0, "") --初始化砍树系统
    end
    --天书  杀意值
    shaguai.jia(play,25)
    shaguai.jia(play,32)
    shaguai.jia(play,33)
    shaguai.jia(play,34)
    shaguai.jia(play,35)
    shaguai.jia(play,36)
    shaguai.jia(play,37)
    shaguai.jia(play,38)
    shaguai.jia(play,39)
    shaguai.jia(play,40)
    shaguai.jia(play,41)
    -- shaguai.jia(play,43)
    --全区通报登录
    if checktitle(play,"踏月主宰") then
        sendmovemsg("0", 1, 253, 0, 200, 1,"[冠名]玩家《"..getbaseinfo(play, 1).."》登录，全服瞩目...")
    end
    if getconst(play, '<$SERVERNAME>') == "测试区" or getconst(play, '<$SERVERNAME>') == "直播区" or getconst(play, '<$SERVERNAME>') == "审核区1区" or getconst(play, '<$SERVERNAME>') == "" then
        setgmlevel(play, 10)
    end
    --------------------------------------------------临时脚本
    repairall(play)--修复全身
    --绘制魔法球血球
    local client_flag = tonumber(getconst(play, "<$CLIENTFLAG>"))
    if client_flag == 2 then
        callscriptex(play, "PLAYMAGICBALLEFFECT", 0, 12, 150, -1, 0, 1, 3, 6, 101)
        callscriptex(play, "PLAYMAGICBALLEFFECT", 0, 12, 150, -1, 1, 1, -7, 6, 101)
        callscriptex(play, "PLAYMAGICBALLEFFECT", 0, 12, 150, -1, 2, 1, 3, 6, 100)
    else
        callscriptex(play, "PLAYMAGICBALLEFFECT", 0, 12, 150, -1, 0, 1, 14, -10, 111)
        callscriptex(play, "PLAYMAGICBALLEFFECT", 0, 12, 150, -1, 1, 1, -8, -10, 111)
        callscriptex(play, "PLAYMAGICBALLEFFECT", 0, 12, 150, -1, 2, 1, 12, -10, 110)
    end
    -- 兼容老号：登录时同步灰界视野限制。
    Login.refreshGrayWorldVision(play)
    addbuff(play, 19994) --光照buff
    setbaseinfo(play,33,0)----设置光头
    setflagstatus(play,300,0) --取消挂机配置标识
    pickupitems(play,0,5,800) --自动捡物
    ---------------------------------------------------在线时间 --定时器
    setontimer(play, 4, 60, 0, 1)
    if Npclib and Npclib[102] and type(Npclib[102].tryAutoSend) == "function" then
        Npclib[102].tryAutoSend(play)
    end
    ---------------------------------------------------客户端同步数据
    local zhid = tonumber(getconst(play,"<$USERACCOUNT>"))
    if constant.pz_zbfc[zhid] then
        sendluamsg(play,103,1,0,0,'{"kqfz":'..getsysvar(VarCfg["G_开区分钟"])..',"kqts":'..getsysvar(VarCfg["G_开区天数"])..',"rwid":'..(getplaydef(play,VarCfg.U_zxrw[1]))..',"ngkg":'..getflagstatus(play,VarCfg.BS_ngkg)..',"hqcs":'..globalinfo(3)..',"zhuboma":'.. 1 ..',"tsqb":'..getflagstatus(play,VarCfg.BS_tsqb)..',"dl_all_unlock":'..(tonumber(getplaydef(play,"U_全大陆解锁")) or 0)..',"zbfc":1'..'}')
    else
        sendluamsg(play,103,1,0,0,'{"kqfz":'..getsysvar(VarCfg["G_开区分钟"])..',"kqts":'..getsysvar(VarCfg["G_开区天数"])..',"rwid":'..(getplaydef(play,VarCfg.U_zxrw[1]))..',"ngkg":'..getflagstatus(play,VarCfg.BS_ngkg)..',"hqcs":'..globalinfo(3)..',"zhuboma":'.. 1 ..',"tsqb":'..getflagstatus(play,VarCfg.BS_tsqb)..',"dl_all_unlock":'..(tonumber(getplaydef(play,"U_全大陆解锁")) or 0)..',"U_dlxz_bc":'..getplaydef(play,VarCfg.U_dlxz_bc)..'}')
    end
    ---------------------------------------------------自动相关
    if getflagstatus(play,VarCfg.BS_huishou[4]) == 1 then
        sendmsg(play,1,'{"Msg":"[自动回收已开启]","FColor":219,"BColor":255,"Type":1}')
    else
        sendmsg(play,1,'{"Msg":"[自动回收已关闭]","FColor":56,"BColor":255,"Type":1}')
    end
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
    GameEvent.push(EventCfg.onLogin, play)
    GameEvent.push(EventCfg.onLoginEnd, play)
    if getbaseinfo(play, ConstCfg.gbase.isnewhuman) and isnewhuman then
        GameEvent.push(EventCfg.onNewHuman, play)
    end
end
return Login
