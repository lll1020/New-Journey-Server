Login = {}
function Login.main(play)
    local weizhi = linkbodyitem(play,17)
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
        setplaydef(play,VarCfg.T_hsdg, '{"1_1_1":1,"1_1_2":1,"1_1_3":1,"1_2_1":1,"1_2_2":1,"1_3_1":1,"1_3_2":1,"1_3_3":1}')--回收打勾
        setplaydef(play,VarCfg.T_dljq,"{}")--各剧情JSON
        setplaydef(play,VarCfg.T_czlb,"{}")--各种礼包
        setplaydef(play,VarCfg.T_jls,"{}")--记录石
        setplaydef(play,VarCfg.T_zxrw,"{}")--支线任务序号
        setplaydef(play,VarCfg.T_rwjl,"{}")--任务领取记录
        setplaydef(play,VarCfg.T_xybl,"{}")--幸运爆率
        setplaydef(play,VarCfg.T_grss,"{}")--个人首爆
        setplaydef(play,VarCfg.T_qrbq,"{}")--福利大厅
        setplaydef(play,VarCfg.T_szjl,"{}")--时装记录
        setplaydef(play,VarCfg.T_xldtsg,"{}")--系列地图杀怪
        setplaydef(play,VarCfg.T_xldtsgjl,"{}")--系列地图杀怪奖励
        setplaydef(play,VarCfg.T_aigj,"{}")--ai挂机
        setplaydef(play,VarCfg.T_rwwp,"{}")--任务物品
        setplaydef(play,VarCfg.T_ywl,"{}")--异闻录
        setplaydef(play,VarCfg.T_hdjl,"{}")--活动奖励
        setplaydef(play,VarCfg.T_zscl,"{}")--转生材料掉落
        setplaydef(play,VarCfg.T_txzr,"{}")--天选之人点数
        setplaydef(play,VarCfg.T_sq_jd,"{}")--必爆神器计数
        setplaydef(play,VarCfg.T_tshs,"{}")--特殊回收
        setplaydef(play,VarCfg.T_rwsg,"{}")--特殊任务杀怪
        setplaydef(play,VarCfg.T_dlsgjl,"{}")--大陆杀怪数量

        if getsysvar(VarCfg["G_新区验证"]) == 0 then
            setsysvar(VarCfg["G_新区验证"],1)
            setsysvar(VarCfg["G_开区天数"],1)
            setsysvar(VarCfg["A_全区首曝json"],"{}")  --全区首爆
        end
        Login_msg(play,0)

        --TODO  初始化任务
        setplaydef(play,VarCfg.U_zxrw[1],1)
        mapmove(play,"新手地图",127,268,2)
    end

    --全区通报登录
    if checktitle(play,"踏月主宰") then
        sendmovemsg("0", 1, 253, 0, 200, 1,"[冠名]玩家《"..getbaseinfo(play, 1).."》登录，全服瞩目...")
    end

    if getconst(play, '<$SERVERNAME>') == "测试区" or getconst(play, '<$SERVERNAME>') == "直播区" or getconst(play, '<$SERVERNAME>') == "审核区1区" or getconst(play, '<$SERVERNAME>') == "" then
        setgmlevel(play, 10)
    end

    --------------------------------------------------临时脚本
    repairall(play)--修复全身
    setbaseinfo(play,33,0)----设置光头
    setflagstatus(play,300,0) --取消挂机配置标识
    pickupitems(play,0,5,800) --自动捡物
    login_fhsx(play) --封号刷新
    ---------------------------------------------------在线时间
    setontimer(play, 4, 60, 0, 1)

    ---------------------------------------------------客户端同步数据
    local zhid = tonumber(getconst(play,"<$USERACCOUNT>"))
    if constant.pz_zbfc[zhid] then
        sendluamsg(play,103,1,0,0,'{"kqfz":'..getsysvar(VarCfg["G_开区分钟"])..',"kqts":'..getsysvar(VarCfg["G_开区天数"])..',"rwid":'..(getplaydef(play,VarCfg.U_zxrw[1]))..',"ngkg":'..getflagstatus(play,VarCfg.BS_ngkg)..',"sczt":'..getflagstatus(play,VarCfg.BS_sckg)..',"hqcs":'..globalinfo(3)..',"zhuboma":'.. 1 ..',"tsqb":'..getflagstatus(play,VarCfg.BS_tsqb)..',"zbfc":1'..'}')
    else
        sendluamsg(play,103,1,0,0,'{"kqfz":'..getsysvar(VarCfg["G_开区分钟"])..',"kqts":'..getsysvar(VarCfg["G_开区天数"])..',"rwid":'..(getplaydef(play,VarCfg.U_zxrw[1]))..',"ngkg":'..getflagstatus(play,VarCfg.BS_ngkg)..',"sczt":'..getflagstatus(play,VarCfg.BS_sckg)..',"hqcs":'..globalinfo(3)..',"zhuboma":'.. 1 ..',"tsqb":'..getflagstatus(play,VarCfg.BS_tsqb)..',"U_dlxz_bc":'..getplaydef(play,VarCfg.U_dlxz_bc)..'}')
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
    Login_jnsh(play)  --技能伤害加载
    Login_jmjnsh(play)  --减免技能伤害加载


    GameEvent.push(EventCfg.onLogin, play)

end


return Login