VarCfg = {}

--引擎G变量
VarCfg["G_开区天数"]           = "G0"                                                                          --开区天数0点+1
VarCfg["G_开区分钟"]           = "G1"                                                                          --开区分钟
VarCfg["G_新区验证"]           = "G2"                                                                          --新区验证
VarCfg["G_天选之人"]           = {"G3","G4"}                                                                   --天选之人时间,次数
VarCfg["G_跑酷提示"]           = "G5"                                                                          --跑酷提示
VarCfg["G_合区次数对比"]           = "G6"                                                                          --合区次数对比

--引擎A变量
VarCfg["A_天选之人json"]           = "A0"                                                                          --天选之人json
VarCfg["A_全区首曝json"]           = "A1"                                                                          --全区首曝json
VarCfg["A_统计信息用"]           = "A3"                                                                          --统计信息用
VarCfg["A_行会积分记录"]           = "A4"                                                                          --A_行会积分记录
VarCfg["A_行会积分记录跨服"]                  = "A5"                    --A_行会积分记录跨服
VarCfg["A_违规人员名单"]          = "A300"                                                                          --违规人员名单


--引擎U变量
--个人U变量

VarCfg.U_create_actor_time                  = "U0"                  --创建角色时间戳
VarCfg.U_create_actor_openday               = "U1"                  --创建角色时已开服的天数
VarCfg["U_等级上限"]                         = "U2"                  --U_等级上限
VarCfg["U_虚拟充值"]                         = "U3"                  --U_虚拟充值
VarCfg["U_上次本日首次登录时间"]              = "U4"                  --U_上次本日首次登录时间
VarCfg["U_登录天数"]                     = "U5"                  --U_登录天数
VarCfg["U_杀人数"]                           = "U6"                  --U_杀人数
VarCfg["U_被杀数"]                           = "U7"                  --U_被杀数
VarCfg["U_足迹外观记录"]                           = "U8"
VarCfg["U_光环外观记录"]                           = "U9"
VarCfg["U_时装外观记录"]                           = "U10"


VarCfg.U_zxrw           = {"U11","U12"}                                                                 --任务ID,进度
VarCfg.U_czyz           = "U13"                                                                          --充值验证
VarCfg.U_czje           = "U14"                                                                          --充值金额中转
VarCfg.U_zjbh           = "U15"                                                                         --足迹编号记录
VarCfg.U_zhixrw         = "U17"                                                                          --支线任务ID
VarCfg.U_jskb           = "U16"                                                                         --击杀狂暴次数
VarCfg.U_zhixrwjd       = {"U18","U19","U20"}                                                           --支线任务进度
VarCfg.U_srsl           = "U21"                                                                        --杀人数量
VarCfg.U_fldt           = {"U22","U23"}                                                                --福利大厅在线,杀怪
VarCfg.U_hqtb           = "U24"                                                                        --玩家合区次数是否一致
VarCfg.U_dkb           = "U25"                                                                        --大狂暴--次数



VarCfg["U_灵根鉴定次数"]           = "U26"                                                                        --灵根鉴定次数
VarCfg["U_兰姐好感度"]              = "U27"

VarCfg["U_境界修炼"]              = {"U28","U29"}                                                  --U_境界修炼{等级,经验}
VarCfg["U_幸运强化"]              = "U30"
VarCfg["U_占卜次数"]              = "U31"

VarCfg["U_装备强化_衣服"]              = "U32"
VarCfg["U_装备强化_武器"]              = "U33"
VarCfg["U_装备强化_左手"]              = "U34"
VarCfg["U_装备强化_左戒"]              = "U35"
VarCfg["U_装备强化_腰带"]              = "U36"
VarCfg["U_装备强化_头盔"]              = "U37"
VarCfg["U_装备强化_项链"]              = "U38"
VarCfg["U_装备强化_右手"]              = "U39"
VarCfg["U_装备强化_右戒"]              = "U40"
VarCfg["U_装备强化_靴子"]              = "U41"
VarCfg["U_聚宝盆积分"]      =    "U42"                                                                     --J_聚宝盆积分
VarCfg["U_转生等级"]      =    "U43"                                                                     --U_转生等级
VarCfg["U_江湖称号"]      =    "U44"                                                                     --U江湖称号




VarCfg["U_战斗力"]                          = "U176"
VarCfg["U_真实充值"]                          = "U225"
--收集物品任务用



--引擎B变量 --大数值
VarCfg["B_记录战斗力"]                      = "B2"                 --B_记录战斗力

--引擎个人表示变量
VarCfg.F_is_global_alerts	                = 1	                    --是否过滤全服提示信息	引擎个人标识
VarCfg.F_is_open_kuangbao	                = 2	                    --是否开启狂暴之力	
VarCfg.F_is_has_revive	                    = 3	                    --死亡前触发标记,用于判断是否触发复活戒指	
VarCfg.F_is_auto_recovery	                = 4	                    --是否开启自动回收	
VarCfg.F_is_auto_money	                    = 5	                    --开启吃货币
VarCfg.F_is_auto_exp	                    = 6	                    --开启自动吃经验
VarCfg.F_is_first_login	                    = 7	                    --是否第一次登录	
VarCfg.F_is_auto_custom_attributes          = 10	                --是否回收鉴定和强化的装备
VarCfg["F_是否首充"]                         = 11	                 --F_是否首充


--个人标识
VarCfg.BS_huishou       =  {101,102,103,104,105}                                                                    --自动吃灵符,自动吃经验,自动捡物,自动回收开关
VarCfg.BS_AIgj          =  118                                                                           --AI挂机开关
VarCfg.BS_mztq          =  119                                                                           --快人一步激活
VarCfg.BS_xsth          =  120                                                                          --限时特惠

VarCfg.BS_ngkg          =  121                                                                           --内挂被人物攻击随机(CD30秒)
VarCfg.BS_dtcs          =  122                                                                          --地图参数，挂机用
VarCfg.BS_zcjfb         =  123                                                                          --真充积分
VarCfg.BS_tyrc         =  124                                                                          --奖励开关  --武林盟主

VarCfg.BS_zzchxf          =  402                                                                          --赞助称号--修复用

VarCfg["F_是否进入过跨服"]                     = 796                --F_是否进入过跨服
VarCfg["F_人物死亡"]                          = 797                --F_人物死亡
VarCfg["F_过滤全服信息"]                      = 798                --过滤全服提示信息
VarCfg["F_解绑状态"]                          = 799                --F_首充解绑_状态


--引擎J变量
--个人J变量
VarCfg.J_kill_boss_mum                      = "J1"                  --每日击杀Boss数量
VarCfg["J_今日真实充值"]                     = "J2"                  --J_今日真实充值

VarCfg.J_mrfhw          = "J11"                                                                          --每日使用复活丹次数
VarCfg.J_jsgw         =   {"J12","J13"}                                                                    --每日大小怪--数量
VarCfg.J_zxsj         =   "J14"                                                                         --今日在线时间
VarCfg.J_qrqd         =   "J15"                                                                         --七日签到记录
VarCfg.J_hbdh         =   {"J16","J17"}                                                                 --每日货币兑换
VarCfg.J_zscz         =  "J18"                                                                     --每日真实充值记录
VarCfg.J_isgs         =    "J19"                                                                     --是否进入过攻沙
VarCfg["J_今日材料兑换"]      =    "J20"                                                                     --每日材料兑换次数
VarCfg["J_攻沙积分"]      =    "J21"                                                                     --J_攻沙积分
VarCfg["J_聚宝盆领取次数"]      =    "J22"                                                                     --J_聚宝盆领取次数


--引擎Z变量
VarCfg["Z_位置1"]                     = "Z1"             --Z_位置1

--引擎T变量
--个人T变量
VarCfg.T_daily_date                         = "T0"                  --格式 20211103 年月日，  每日凌晨更新，如果凌晨不在线每日第一次登陆更新
VarCfg.T_selected_data                      = "T1"                  --回收勾选数据
VarCfg.T_huishou_group                      = "T2"                  --记录回收分组
VarCfg.T_tujian                             = "T3"                  --点亮图鉴的数据

VarCfg.T_sgcf           = "T11"                                                                         --需杀怪触发json
VarCfg.T_hsdg           = "T12"                                                                         --回收打勾配置
VarCfg.T_dljq          = "T13"                                                                          --各剧情JSON
VarCfg.T_czlb           = "T14"                                                                         --各种礼包
VarCfg.T_jls           = "T15"                                                                          --记录石
VarCfg.T_zxrw           =  "T16"                                                                            --支线任务序号
VarCfg.T_rwjl        = "T17"                                                                            --任务领取记录
VarCfg.T_xybl           = "T18"                                                                         --幸运爆率
VarCfg.T_grsb           = "T19"                                                                         --个人首爆
VarCfg.T_qrbq           = "T20"                                                                         --福利大厅
VarCfg.T_szjl           = "T21"                                                                         --时装记录
VarCfg.T_xldtsg           = "T22"                                                                           --系列地图杀怪
VarCfg.T_xldtsgjl           = "T23"                                                                         --系列地图杀怪奖励
VarCfg.T_aigj           = "T24"                                                                         --ai挂机
VarCfg.T_rwwp           = "T25"                                                                         --任务物品
VarCfg.T_ywl           = "T26"                                                                          --异闻录
VarCfg.T_hdjl           = "T27"                                                                         --活动奖励
VarCfg.T_zscl          =  "T28"                                                                         --转生材料掉落
VarCfg.T_txzr          =  "T29"                                                                         --天选之人点数
VarCfg.T_sq_jd     =  "T30"                                                                         --必爆神器计数
VarCfg.T_tshs     =  "T31"                                                                          --特殊回收
VarCfg.T_rwsg     =  "T32"                                                                          --特殊任务杀怪
VarCfg.T_dlsgjl     =  "T33"                                                                            --大陆杀怪数量

VarCfg["T_灵根鉴定"]           = "T34"                                                                          --灵根鉴定
VarCfg["T_各剧情杀怪"]           = "T35"                                                                         --各剧情杀怪JSON
VarCfg["T_灵根修炼"]           = "T36"                                                                          --灵根修炼
VarCfg["T_仙食坊"]           = "T37"                                                                           --T_仙食坊
VarCfg.T_grss           = "T38"                                                                         --个人首杀
VarCfg["T_首冲礼包"]           = "T39"                                                                         --首冲礼包
VarCfg["T_仙途奇缘"]           = "T40"                                                                         --仙途奇缘
VarCfg["T_灵根"]           = "T41"                                                                         --灵根
VarCfg["T_天书"]           = "T42"                                                                         --天书
VarCfg["T_免费赞助"]           = "T43"                                                                         --免费赞助
VarCfg["T_聚宝盆"]           = "T44"                                                                         --T_聚宝盆

VarCfg["T_飞剑"]           = "T45"                                                                         --T_飞剑
VarCfg["T_技能升级"]           = "T46"                                                                         --T_技能升级
VarCfg["T_仙府"]           = "T47"                                                                         --T_仙府




--引擎变量 S
VarCfg.S_cur_mapid                           = "S99"                 --当前所在地图id，切换地图时候获取上一次的地图id

--引擎变量 M
VarCfg["M_标识"]                  = "M1"                 --M_标识

--临时自定义变量
VarCfg.Die_Flag                             = "N$B死掉了"            --死亡触发之前处理 0 没死 1死掉了
VarCfg["N$是否被破复活"]                       = "N$是否被破复活"     --如果有复活，死亡之前记录1，复活就置0，如果死亡的时候给的是1，就提示破复活了
VarCfg.Die_Drop_item                        = "S$B死亡掉装备"        --死亡爆出的装备
VarCfg.Recharge_Temp                        = "N$B充值记录"          --充值临时记录
VarCfg.Hide_Attr_Miss                       = "N$B闪避记录"          --闪避临时记录

VarCfg.N_lbyz           = "N$礼包验证"                                                                   --充值礼包验证
VarCfg.N_rwlg           = "N$任务略过"                                                                   --任务验证


VarCfg.N_dqgs           = "N$当前攻速"                                                                   --当前攻速百分比
VarCfg.N_gscd           = "N$攻速CD"                                                                     --当前攻速切换CD
VarCfg.N_jnsh           = {"N$攻杀剑术伤害","N$刺杀伤害","N$半月伤害","N$烈火伤害","N$开天伤害","N$逐日伤害"}    --技能伤害加成
VarCfg.N_jmjnsh           = {"N$烈火伤害","N$逐日伤害","N$开天伤害"}    --减免技能伤害加成
VarCfg.N_jnjm           = "N$技能减免"                                                                   --技能伤害减免
VarCfg.N_Aigj           = {"N$被攻击随机","N$无怪随机","N$自动换图","N$土城随机","N$定时随机换图"}                          --AI挂机临时变量
VarCfg.N_jsys           = "N$溅射延时"                                                                   --溅射延时
VarCfg.N_znpc           = "N$找NPC"                                                                      --任务寻找NPC
VarCfg.N_ddcs           = "N$boss传送"                                                                      --boss定点传送
VarCfg.N_tyecmb         = "N$比武大会"                                                                   --比武大会面板



VarCfg.S_buffgjq                          = "S$攻击前buff"                                                                 --攻击前buff信息
VarCfg.S_buffgwq                          = "S$攻击怪物前buff"                                                             --攻击怪物前buff信息
VarCfg.S_buffrwq                          = "S$攻击人物前buff"                                                             --攻击人物前buff信息
VarCfg.S_buffgjh                          = "S$攻击后buff"                                                                 --攻击后buff信息
VarCfg.S_buffgwh                          = "S$攻击怪物后buff"                                                             --攻击怪物后buff信息
VarCfg.S_buffrwh                          = "S$攻击人物后buff"                                                             --攻击人物后buff信息
VarCfg.S_buffbgjq                         = "S$被攻击前buff"                                                               --被攻击前buff信息
VarCfg.S_buffbgwq                         = "S$被怪物攻击前buff"                                                           --被怪物攻击前buff信息
VarCfg.S_buffbrwq                         = "S$被人物攻击前buff"                                                           --被人物攻击前buff信息
VarCfg.S_buffsgcf                         = "S$杀怪触发buff"                                                               --杀怪触发buff信息
VarCfg.S_bufffuhuo                        = "S$复活触发buff"                                                               --复活触发buff信息
VarCfg.S_buffqiehuan                      = "S$切换地图buff"                                                               --切换地图buff信息
VarCfg.S_sdlmjdt                          = "S$秘境前地图"                                                                 --四大陆秘境记录传送前地图
VarCfg.S_houtaibf                         = "S$后台补发"                                                                      --后台补发人

--自定义个人变量
VarCfg.NB_Caiji_Num                          = "NB_Playcaiji_dayNum"        --今日采集次数变量名
VarCfg.NB_Shouling_Num                       = "NB_Playshouling_dayNum"     --今日首领击杀变量名
VarCfg.NB_Mowang_Num                         = "NB_Playmowang_dayNum"       --今日魔王击杀变量名
VarCfg.NB_JHMW_Lv                           = "NB_JiangHuMingWang_Lv"       --江湖名望/免费vip等级
VarCfg.NB_QD_useNum                         = "NB_SevenDay_gifgUseNum"       --虚充红包每日使用数量

--隐藏变量名                                                            --属性名字                  说明	            数值类型1固值 2万分比 3 百分比 
VarCfg.NB_hide_att_204                       = "NB_att_hide_204"	   --麻痹概率               麻痹对象的概率	                    2
VarCfg.NB_hide_att_205                       = "NB_att_hide_205"	   --复活冷却时间(秒)	     复活冷却时间（秒）	                 1
VarCfg.NB_hide_att_206                       = "NB_att_hide_206"	   --复活血量和蓝	        复活后恢复的血量	                 2
VarCfg.NB_hide_att_207                       = "NB_att_hide_207"	   --无视概率	            概率触发无视攻击	                 2
VarCfg.NB_hide_att_208                       = "NB_att_hide_208"	   --无视攻击	            概率闪避对方攻击	                 2
VarCfg.NB_hide_att_209                       = "NB_att_hide_209"	   --无视概率时间(秒）	    概率闪避对方攻击	                  1
VarCfg.NB_hide_att_210                       = "NB_att_hide_210"	   --护身系数	            万分比减伤，所受的伤害减扣在MP上	   2
VarCfg.NB_hide_att_211                       = "NB_att_hide_211"	   --抵抗吸血概率		                                        2
VarCfg.NB_hide_att_212                       = "NB_att_hide_212"	   --抵抗吸血		                                            1
VarCfg.NB_hide_att_213                       = "NB_att_hide_213"	   --抵抗吸血持续时间	单位：秒	                             1
VarCfg.NB_hide_att_214                       = "NB_att_hide_214"	   --抵抗吸血冷却时间	单位：秒	                             1

--引擎N变量
VarCfg.N_cur_level                          = "N$A_当前等级"                --当前等级(为了升级触发获取到上一次是多少级)

--引擎S变量
VarCfg["S$_追杀标记"]                        = "S$追杀标记"                 --标识玩家


--------------------------------------------------------------自定义变量-------------------------------------------------------------
-------------字符类型-------------

----------数字类型-------------


return VarCfg