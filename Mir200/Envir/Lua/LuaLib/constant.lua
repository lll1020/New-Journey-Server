constant = {}

--常用配置
constant.pz_xrjn =  {{3,3},{7,3},{26,3},{27,3},{12,3}}                                                    --新人技能
dofile("Envir/lua/Data/huishou.lua")                                                                      --回收物品配置
dofile("Envir/lua/Data/daluditu.lua")                                                                     --大陆地图配置
dofile("Envir/lua/Data/xilieditu.lua")                                                                    --系列地图区分
dofile("Envir/lua/Data/paokujl.lua")                                                                      --土城跑酷奖励
dofile("Envir/lua/Data/jinzhigj.lua")                                                                      --禁止记录地图
dofile("Envir/lua/Data/guaiwutype.lua")                                                                        --怪物类型
dofile("Envir/lua/Data/teshudata.lua")                                                                             --特殊数据



constant.pz_hanzi          = {"一","二","三","四","五","六","七","八","九","十",}                            --汉字
constant.pz_ldql          = {}        --每日清理称号
constant.pz_jndy          = {"基本剑术","施毒术","攻杀剑术","刺杀剑术","半月弯刀","烈火剑法","野蛮冲撞","逐日剑法","开天斩","十步一杀"}        --技能抵御
constant.pz_ddzbjl          = {  }                                          --武林盟主的奖励
constant.pz_zzdkjl          = { }                                          --阵营对抗的奖励

constant.pz_qrbq          = 
{{{5,10,20,30,60,120,180,360},{10,20,30,40,50,100,200,500,1000},{1,2,3,4,5,6,7},{10,20,30,40,50,60,70,80}},
{{1000,2000,3000,4000,5000,10000,20000,50000},{1000,2000,3000,4000,5000,10000,20000,50000},{10000,20000,30000,40000,50000,60000,70000},{10000,20000,30000,40000,50000,60000,70000,80000}}}        --七日变强配置  [1]=要求 [2]=奖励
constant.pz_txzrjl       = {"128元真实充值","40元真实充值","38元真实充值","36元真实充值","32元真实充值","30元真实充值","28元真实充值","26元真实充值","24元真实充值","22元真实充值"}

constant.zs_zhuangbeiwei = {
    [401] = 74,
    [402] = 75,
    [403] = 76,
    [404] = 85,
    [405] = 86,
    [406] = 88,
    [407] = 89,
    [408] = 90,
    [409] = 91,
    [410] = 92,
    [411] = 93,
    [412] = 94,
    [413] = 95,
    [414] = 96,
    [415] = 97,
    [416] = 98,
    [417] = 99,
    [418] = 100,
    [419] = 101,
    [420] = 102,
    [421] = 103,
    [422] = 115,
    [423] = 116,
    [424] = 117,
    [425] = 118,
    [426] = 119,
}
--禁止鞭尸怪物
constant.pz_jzbs          = {

}
constant.pz_tyrcjl          = {10,8,5,3}                                          --比武大会的奖励
constant.pz_bossys          = {[70] = true, [141] = true, [58] = true, [251] = true}                            --boss名字颜色
constant.cz_jeyz = {[18] = 1,[38] = 2,[68] = 3,[128] = 4,[288] = 5,[588] = 6,[888] = 7,[1188] = 8,[1588] = 9,[1888] = 10}

constant.pz_tgdssg          = {{"吾良老板",1,141,{37,41}},{"猪技术",1,141,{201,199}},{"猪技术",1,141,{198,84}},{"猪技术",1,141,{206,316}},{"猪技术",6,251,{{317,184},{337,205},{318,223},{298,203},{196,193},{208,205}}},{"狗策划",25,242},{"狗策划",70,255},{"猪技术",15,141}}                            --活动暴打够侧滑刷怪

constant.pz_htqx = {[1313760734] = "lll"}           --后台权限
constant.pz_zbqd = {}              --主播账号启动礼包上线直接给
constant.pz_zbfc = {[1313760734] = "lll"}                  --主播扶持权限




--任务类型 1.按钮  2.NPC  3.背包  4.直接奖励 5.双层NPC后刷新杀怪任务  6. 直传找NPC后刷新杀怪任务 任意怪  7.直传找NPC后刷新杀怪任务 BOSS  8.直传找NPC后刷新杀怪任务 小怪+BOSS 
--验证类型  1.字符串,变量,键值,数值   2.装备位置,装备IDX  3.称号名字  4.装备附加属性 位置,组别,比例,dj
--特殊任务类型，ts = {num,{}}
--1：提交次数类
--2：杀怪类  包括单只 + 多个
--3：提交多个  多次物品类
constant.rw_syb = {
    [1] = {99},

    [1300] = {50,"剑门外门",21,96,76}, --除魔天地间
}


--全局G变量
constant.G_kqts           = "G0"                                                                          --开区天数0点+1
constant.G_kqfz           = "G1"                                                                          --开区分钟
constant.G_kqyz           = "G2"                                                                          --新区验证
constant.G_txzz           = {"G3","G4"}                                                                   --天选之人时间,次数
constant.G_pkts           = "G5"                                                                          --跑酷提示
constant.G_hqcs           = "G6"                                                                          --合区次数对比


--全局A变量
constant.A_txzz           = "A0"                                                                          --天选之人json
constant.A_qqsb           = "A1"                                                                          --全区首曝json
constant.A_tjxx           = "A3"                                                                          --统计信息用
constant.A_csqmingdan           = "A4"                                                                          --测试使用
constant.A_wgrymd          = "A300"                                                                          --违规人员名单


--个人T变量
constant.T_sgcf           = "T1"                                                                          --需杀怪触发json
constant.T_hsdg           = "T2"                                                                          --回收打勾配置
constant.T_dljq          = "T3"                                                                          --各剧情JSON
constant.T_czlb           = "T4"                                                                         --各种礼包
constant.T_jls           = "T5"                                                                           --记录石
constant.T_zxrw           =  "T6"                                                                        --支线任务序号
constant.T_rwjl        = "T7"                                                                             --任务领取记录
constant.T_xybl           = "T8"                                                                         --幸运爆率
constant.T_grss           = "T9"                                                                         --个人首爆
constant.T_qrbq           = "T10"                                                                        --福利大厅
constant.T_szjl           = "T16"                                                                        --时装记录
constant.T_xldtsg           = "T17"                                                                        --系列地图杀怪
constant.T_xldtsgjl           = "T18"                                                                     --系列地图杀怪奖励
constant.T_aigj           = "T23"                                                                        --ai挂机
constant.T_rwwp           = "T24"                                                                        --任务物品
constant.T_ywl           = "T25"                                                                        --异闻录
constant.T_hdjl           = "T28"                                                                        --活动奖励
constant.T_zscl          =  "T29"                                                                      --转生材料掉落
constant.T_txzr          =  "T30"                                                                      --天选之人点数

constant.T_sq_jd     =  "T38"                                                                      --必爆神器计数
constant.T_tshs     =  "T41"                                                                      --特殊回收
constant.T_rwsg     =  "T42"                                                                      --特殊任务杀怪
constant.T_dlsgjl     =  "T45"                                                                      --大陆杀怪数量



--个人J变量
constant.J_mrfhw          = "J1"                                                                          --每日使用复活丹次数
constant.J_jsgw         =   {"J4","J5"}                                                                    --每日大小怪--数量
constant.J_zxsj         =   "J9"                                                                         --今日在线时间
constant.J_qrqd         =   "J11"                                                                         --七日签到记录
constant.J_hbdh         =   {"J13","J14"}                                                                 --每日货币兑换
constant.J_zscz         =  "J17"                                                                     --每日真实充值记录
constant.J_isgs         =    "J32"                                                                     --是否进入过攻沙


--个人U变量
constant.U_zxrw           = {"U1","U2"}                                                                 --任务ID,进度
constant.U_czyz           = "U3"                                                                          --充值验证
constant.U_czje           = "U4"                                                                          --充值金额中转
constant.U_zjbh           = "U5"                                                                         --足迹编号记录
constant.U_jskb           = "U6"                                                                         --击杀狂暴次数
constant.U_zhixrw         = "U7"                                                                          --支线任务ID
constant.U_zhixrwjd       = {"U8","U9","U10"}                                                           --支线任务进度
constant.U_srsl           = "U11"                                                                        --杀人数量
constant.U_fldt           = {"U12","U13"}                                                                --福利大厅在线,杀怪
constant.U_hqtb           = "U14"                                                                        --玩家合区次数是否一致

constant.U_dkb           = "U30"                                                                        --大狂暴--次数


--个人标识
constant.BS_huishou       =  {1,2,3,4,5}                                                                    --自动吃灵符,自动吃经验,自动捡物,自动回收开关
constant.BS_sckg          =  7                                                                            --首冲开关
constant.BS_AIgj          =  18                                                                           --AI挂机开关
constant.BS_mztq          =  19                                                                           --快人一步激活
constant.BS_xsth          =  21                                                                           --限时特惠

constant.BS_ngkg          =  299                                                                           --内挂被人物攻击随机(CD30秒)
constant.BS_dtcs          =  300                                                                          --地图参数，挂机用
constant.BS_zcjfb         =  302                                                                          --真充积分

constant.BS_zzchxf          =  402                                                                          --赞助称号--修复用

--扩展N$变量
constant.N_dqgs           = "N$当前攻速"                                                                   --当前攻速百分比
constant.N_gscd           = "N$攻速CD"                                                                     --当前攻速切换CD
constant.N_jnsh           = {"N$基本伤害","N$刺杀伤害","N$半月伤害","N$烈火伤害","N$逐日伤害","N$开天伤害"}    --技能伤害加成
constant.N_jmjnsh           = {"N$烈火伤害","N$逐日伤害","N$开天伤害"}    --减免技能伤害加成
constant.N_jnjm           = "N$技能减免"                                                                   --技能伤害减免
constant.N_Aigj           = {"N$被攻击随机","N$无怪随机","N$自动换图","N$土城随机","N$定时随机换图"}                          --AI挂机临时变量
constant.N_jsys           = "N$溅射延时"                                                                   --溅射延时
constant.N_znpc           = "N$找NPC"                                                                      --任务寻找NPC
constant.N_ddcs           = "N$boss传送"                                                                      --boss定点传送

constant.N_lbyz           = "N$礼包验证"                                                                   --充值礼包验证
constant.N_rwlg           = "N$任务略过"                                                                   --任务验证
constant.N_sqms           = "N$拾取模式"                                                                   --拾取模式
constant.N_qlscd          = "N$擒龙手CD"                                                                   --擒龙手
constant.N_gjms           = "N$挂机模式"                                                                   --挂机攻击模式切换
constant.N_tyecmb         = "N$比武大会"                                                                   --比武大会面板
--扩展S$变量

constant.S_buffgjq        = "S$攻击前buff"                                                                 --攻击前buff信息
constant.S_buffgwq        = "S$攻击怪物前buff"                                                             --攻击怪物前buff信息
constant.S_buffrwq        = "S$攻击人物前buff"                                                             --攻击人物前buff信息

constant.S_buffgjh        = "S$攻击后buff"                                                                 --攻击后buff信息
constant.S_buffgwh        = "S$攻击怪物后buff"                                                             --攻击怪物后buff信息
constant.S_buffrwh        = "S$攻击人物后buff"                                                             --攻击人物后buff信息

constant.S_buffbgjq       = "S$被攻击前buff"                                                               --被攻击前buff信息
constant.S_buffbgwq       = "S$被怪物攻击前buff"                                                           --被怪物攻击前buff信息
constant.S_buffbrwq       = "S$被人物攻击前buff"                                                           --被人物攻击前buff信息

constant.S_buffsgcf       = "S$杀怪触发buff"                                                               --杀怪触发buff信息
constant.S_bufffuhuo      = "S$复活触发buff"                                                               --复活触发buff信息

constant.S_buffqiehuan    = "S$切换地图buff"                                                               --切换地图buff信息

constant.S_sdlmjdt        = "S$秘境前地图"                                                                 --四大陆秘境记录传送前地图
constant.S_houtaibf       = "S$后台补发"                                                                      --后台补发人





return constant