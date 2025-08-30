ConstCfg = {

    --全局信息
    global = {
        openday    = 1,      --开服天数
        opendate   = 2,      --开服时间
        mergecount = 3,      --合服次数
        mergedate  = 4,      --合服时间
        serverip   = 5,      --服务器IP
        actornum   = 6,      --玩家数量
        maxbagnum  = 7,      --背包最大数量
    },

    --设置人物，怪物，base字段
    gbase = {
        isplayer        = -1, --是否玩家
        isdie           = 0,  --是否死亡(true:死亡状态)
        name            = 1,  --角色名 （返回值字符型）
        id              = 2,  --角色唯一ID （返回值字符型）
        mapid           = 3,  --角色当前地图ID （返回值字符型）
        x               = 4,  --角色X坐标
        y               = 5,  --角色Y坐标
        level           = 6,  --角色等级
        job             = 7,  --角色职业 （0-战 1-法 2-道）
        sex             = 8,  --角色性别
        curhp           = 9,  --角色当前HP
        maxhp           = 10, --角色当前MAXHP
        curmp           = 11, --角色当前MP
        maxmp           = 12, --角色当前MAXMP
        curexp          = 13, --角色当前Exp
        maxexp          = 14, --角色当前MaxExp
        ac              = 15, --角色物防下限
        ac2             = 16, --角色物防上限
        mac             = 17, --角色魔防下限
        mac2            = 18, --角色魔防上限
        dc              = 19, --角色物攻下限
        dc2             = 20, --角色物攻上限
        mc              = 21, --角色魔攻下限
        mc2             = 22, --角色魔攻上限
        sc              = 23, --角色道攻下限
        sc2             = 24, --角色道攻上限
        lucky           = 25, --角色幸运值
        hpadd           = 26, --角色HP恢复
        mpadd           = 27, --角色MP恢复
        poison_add      = 28, --角色中毒恢复
        poison_avoid    = 29, --毒物躲避
        magic_avoid     = 30, --角色魔法躲避
        accuracy        = 31, --角色准确
        agile           = 32, --角色敏捷
        hair            = 33, --发型
        bag_num         = 34, --背包物品数量（仅人物）
        team_num        = 35, --队伍成员数量（仅人物）
        guild           = 36, --行会名（仅人物）
        isboos          = 37, --是否会长（仅人物）
        pets_num        = 38, --宠物数量
        renew_level     = 39, --转生等级（仅人物）
        exp_rate        = 40, --杀怪经验倍数（仅人物）
        exp_time        = 41, --杀怪经验时间（仅人物）
        delay_call_time = 42, --显示延时TIMERECALL还剩多少秒（仅人物）
        drop_rate       = 43, --人物杀怪爆率倍数（仅人物）
        revive_time     = 44, --复活时间
        map_title       = 45, --地图名MAPTITLE
        pkvalue         = 46, --PK点
        isnewhuman      = 47, --是否新人（仅人物）
        issaferect      = 48, --是否安全区
        isstall         = 49, --是否摆摊中（仅人物）
        istrade         = 50, --是否交易中（仅人物）
        custom_attr     = 51, --自定义扩展属性，需要提供 参数3:属性ID（cfg_att_score.xls设置：1-91，200~249）
        behavior        = 52, --穿人/怪方式 0=恢复/1=穿人/2=穿怪/3=穿人穿怪
        login           = 53, --登录状态，0：正常，1：断线重连（仅人物）
        userid          = 54, --主人UserId
        idx             = 55, --Idx
        color           = 56, --颜色（0~255）
        fashion         = 58, --时装显示状态(仅人物)  0=不显示 1=显示
        issbk           = 60, --是否在攻城区域(bool)
        offline         = 61  --是否为离线挂机状态(bool)
    },
    --顶戴位置
    iconWhere = {
        kuangbao = 1,        --狂暴
        vip      = 2,        --VIP等级
        title    = 3,        --正常称号
        faBao    = 4,        --法宝
        guangHuan = 5,       --光环
    },
    customAttrWhere = {

    },
    --设置人物，怪物，base字段
    sbase = {
        level        = 6,     --设置等级
        job          = 7,     --职业
        sex          = 8,     --性别
        curhp        = 9,     --当前HP
        curmp        = 11,    --当前MP
        ac           = 15,    --物防下限
        ac2          = 16,    --物防上限
        mac          = 17,    --魔防下限
        mac2         = 18,    --魔防上限
        dc           = 19,    --物攻下限
        dc2          = 20,    --物攻上限
        mc           = 21,    --魔攻下限
        mc2          = 22,    --魔攻上限
        sc           = 23,    --道攻下限
        sc2          = 24,    --道攻上限
        lucky        = 25,    --幸运值
        hpadd        = 26,    --HP恢复
        mpadd        = 27,    --MP恢复
        poison_add   = 28,    --中毒恢复
        poison_avoid = 29,    --毒物躲避
        magic_avoid  = 30,    --魔法躲避
        accuracy     = 31,    --准确
        agile        = 32,    --敏捷
        hair         = 33,    --发型
        renew_level  = 39,    --转生等级（仅人物）
        exp_rate     = 40,    --杀怪经验倍数（仅人物）
        exp_time     = 41,    --杀怪经验时间（仅人物）
        drop_rate    = 43,    --人物杀怪爆率倍数（仅人物）
        pkvalue      = 46,    --人物PK点（仅人物）
        behavior     = 50,    --行为方式，只针对宠物，包含多个行为时，求和（1：禁止攻击玩家，2：不可被攻击，4：优先攻击 玩家攻击对象，8：优先攻击 玩家受击对象 ）
        mutiny       = 51,    --叛变（仅怪物）
        through      = 52,    --穿人/怪方式 0=恢复/1=穿人/2=穿怪/3=穿人穿怪
        color        = 56,    --颜色（0~255）
        fashion      = 57,    --时装显示状态(仅人物)  0=不显示 1=显示
    },

    adminPassword = "qianchanglll",
    --打开内置面板
    openlink             = {
        Equip              = 1,     -- 角色-装备
        State              = 2,     -- 角色-状态
        Attri              = 3,     -- 角色-属性
        Skill              = 4,     -- 角色-技能
        Title              = 5,     -- 角色-装备
        BestRing           = 6,     -- 角色-首饰盒
        Bag                = 7,     -- 背包
        Stall              = 8,     -- 摆摊
        StoreHot           = 9,     -- 商城-热销
        StoreBeauty        = 10,    -- 商城-装饰
        StoreEngine        = 11,    -- 商城-功能
        StoreFestival      = 12,    -- 商城-节日
        GuildMain          = 13,    -- 行会-主界面
        GuildMember        = 14,    -- 行会成员列表
        GuildList          = 15,    -- 行会列表
        Mail               = 16,    -- 邮件
        Team               = 17,    -- 组队
        NearPlayer         = 18,    -- 附近玩家
        Setting            = 23,    -- 设置
        MiniMap            = 24,    -- 小地图
        SkillSetting       = 25,    -- 技能设置
        StoreRecharge      = 26,    -- 充值
        Auction            = 27,    -- 拍卖行
        Friend             = 28,    -- 好友
        ExitToRole         = 29,    -- 小退
        GuildCreate        = 30,    -- 行会创建
        Guild              = 31,    -- 智能行会界面
        Rank               = 32,    -- 排行榜
        Trade              = 33,    -- 面对面交易 请求
        ForceExitToRole    = 34,    -- 强制小退
        TradingBank        = 35,    -- 交易行
        GuideEnter         = 36,    -- 引导进入
        SuperEquip         = 37,    -- 角色-神装
        HeroEquip          = 41,    -- 英雄-装备
        HeroState          = 42,    -- 英雄-状态
        HeroAttri          = 43,    -- 英雄-属性
        HeroSkill          = 44,    -- 英雄-技能
        HeroTitle          = 45,    -- 英雄-称号
        HeroBestRing       = 46,    -- 英雄-首饰盒
        HeroBag            = 47,    -- 英雄-背包
        HeroSuperEquip     = 48,    -- 英雄-神装
        ReinAttrPoint      = 51,    -- 转生属性点
        Chat               = 52,    -- 聊天
        PCPrivate          = 53,    -- PC 私聊记录页
        MagicJointAttack   = 99,    -- 释放合击
        AssistChange       = 110,   -- 主界面-任务栏
        Box996             = 111,   -- 盒子称号
        MainMiniMapChange  = 112,   -- 小地图伸缩
        PCResolution       = 113,   -- PC 分辨率设置
        ChatExtendEmoj     = 114,   -- 角色-表情
        ChatExtendBag      = 115,   -- 聊天小框-背包
        MainNear           = 116,   -- 主界面-附近列表
        CallPay            = 117,   -- 调用-支付
        SettingBasic       = 300,   -- 基础设置
        SettingWindowRange = 301,   -- 视距
        SettingFight       = 302,   -- 战斗
        SettingProtect     = 303,   -- 保护
        SettingAuto        = 304,   -- 挂机
        SettingHelp        = 305,   -- 帮助
        KeFu               = 310,   -- 调用客服界面
        Compound           = 2201,  -- 合成
    },

    --永久属性
    forever_attr         = {
        dc       = 1,         --攻击下限（0~65535）
        dc2      = 2,         --攻击上限（0~65535）
        mc       = 3,         --魔法下限（0~65535）
        mc2      = 4,         --魔法上限（0~65535）
        sc       = 5,         --道术下限（0~65535）
        sc2      = 6,         --道术上限（0~65535）
        ac       = 7,         --防御下限（0~65535）
        ac2      = 8,         --防御上限（0~65535）
        mac      = 9,         --魔防下限（0~65535）
        mac2     = 10,        --魔防上限（0~65535）
        maxhp    = 11,        --生命值（支持21亿）
        maxmp    = 12,        --魔法值（支持21亿）
        accuracy = 13,        --准确（支持21亿）
        agile    = 14,        --躲避就是准确（支持21亿）
    },

    --自定义属性
    custom_attr          = {
        attr200 = 200,         --减少受到来自怪物的固定伤害
    },

    --人物模式
    --第三个参数无敌,隐身,禁止攻击时没有使用.
    --如果是禁锢时，第三个参数表示禁锢范围
    pmode                = {
        god       = 1,            --无敌
        unsee     = 2,            --隐身
        hp        = 3,            --HP
        mp        = 4,            --MP
        dc2       = 5,            --攻击力
        mc2       = 6,            --魔法力
        sc2       = 7,            --道术力
        ias       = 8,            --攻击速度
        ban_act   = 9,            --禁止攻击
        lock      = 10,           --锁定
        trap      = 11,           -- 禁锢(释放一个类似困魔咒的光圈，敌对人物或怪物只能在这个圈子里移动，无法走出圈子外面，所有传送失效，不能小退)
        frost     = 12,           -- 冰冻
        stick     = 13,           -- 蛛网
        nopalsy   = 14,           -- 防麻痹
        mptrap    = 15,           -- 防禁锢
        nofrost   = 16,           -- 防冰冻
        nostick   = 17,           -- 防蛛网
        palsy     = 18,           -- 麻痹
        protect   = 19,           -- 护身
        inblood   = 20,           -- 吸血
        inblue    = 21,           -- 吸蓝
        lucent    = 22,           -- 隐身(类似隐身戒指)
        realive   = 23,           -- 复活
        norealive = 24,           -- 破复活
    },

    --攻击模式
    amode                = {
        qt = 0,                  --全体攻击
        hp = 1,                  --和平攻击
        fq = 2,                  --夫妻攻击
        st = 3,                  --师徒攻击
        bz = 4,                  --编组攻击
        hh = 5,                  --行会攻击
        hm = 6,                  --红名攻击
        gg = 7,                  --国家攻击
    },

    --怪物表
    stdmoninfo           = {
        name  = 1,               --怪物名 （返回值字符型）
        color = 2,               --怪物名颜色
    },

    --货币
    money                = {
        yb      = 2,              --元宝
        bindyb  = 4,              --绑定元宝
        lingfu  = 5,              --灵符
        zuanshi = 12,             --钻石
        ryd     = 9,              --荣誉点
        czd     = 10,             --充值点 1rmb = 1充值点
        jifen   = 14,             --积分
        xfd     = 16,             --消费点
    },

    --物品信息
    iteminfo             = {
        id      = 1,             --唯一ID
        idx     = 2,             --物品ID
        curdura = 3,             --剩余持久
        maxdura = 4,             --最大持久
        overlap = 5,             --叠加数量
        bind    = 6,             --绑定状态值
        name    = 7,             --名字
    },

    --物品基础信息
    stditeminfo          = {
        idx       = 0,            --0:idx
        name      = 1,            --1:名称
        stdmode   = 2,            --2:StdMode
        shape     = 3,            --3:Shape
        weight    = 4,            --4:重量
        anicount  = 5,            --5:AniCount
        maxdura   = 6,            --6:最大持久
        overlap   = 7,            --7:叠加数量
        price     = 8,            --8:价格（price）
        need      = 9,            --9:使用条件
        needlevel = 10,           --10:使用等级
        custom29  = 11,           --11:道具表自定义常量(25列)
        custom30  = 12,           --12:道具表自定义常量（26列）
        color     = 13,           --13:颜色
    },

    --技能
    skill                = {
        level       = 1,         --技能等级
        superlevel  = 2,         --技能强化等级
        proficiency = 3,         --熟练度
    },

    --公告
    notice               = {
        own   = 1,               --发送给自己
        all   = 2,               --发送给全服
        guild = 3,               --发送给行会
        map   = 4,               --发送给地图
        team  = 5,               --发送给组队
    },

    --获取沙巴克信息返回值
    castle               = {
        info = {                 --castleinfo
            name        = 1,     --沙城名称
            guildname   = 2,     --沙城行会名称
            guildmgr    = 3,     --沙城城主
            day         = 4,     --占领天数，返回number
            state       = 5,     --当前是否在攻沙状态，返回Bool
            guilddeputy = 6,     --沙城多个副城主 (返回类型table)
        },
        identity = {             --castleidentity
            no   = 0,            --非沙巴克成员
            yes  = 1,            --沙巴克成员
            boos = 2,            --沙巴克老大
        }
    },

    --stdmode 与 where 的映射关系
    stdmodewheremap      = {
        [10]    = { 0 },        --衣服(男)
        [11]    = { 0 },        --衣服(女)
        [5]     = { 1 },        --武器(男)
        [6]     = { 1 },        --武器(女)
        [30]    = { 2 },        --勋章
        [19]    = { 3 },        --项链
        [20]    = { 3 },        --项链
        [21]    = { 3 },        --项链
        [15]    = { 4 },        --头盔
        [24]    = { 5, 6 },     --手镯
        [26]    = { 5, 6 },     --手镯
        [22]    = { 7, 8 },     --戒指
        [23]    = { 7, 8 },     --戒指
        [25]    = { 9 },        --符、毒药
        [54]    = { 10 },       --腰带
        [64]    = { 10 },       --腰带
        [52]    = { 11 },       --靴子
        [62]    = { 11 },       --靴子
        [53]    = { 12 },       --宝石、魔血石
        [63]    = { 12 },       --宝石、魔血石
        [7]     = { 12 },       --宝石、魔血石
        [16]    = { 13 },       --斗笠
        [65]    = { 14 },       --军鼓
        [28]    = { 15 },       --马牌
        [48]    = { 16 },       --盾牌
        [50]    = { 55 },       --面巾

        [66]    = { 17 },       --时装衣服(男)
        [67]    = { 17 },       --时装衣服(男)
        [68]    = { 18 },       --时装衣服(女)
        [69]    = { 18 },       --时装衣服(女)
        [71]    = { 19 },       --时装斗笠
        [75]    = { 20 },       --时装项链
        [76]    = { 20 },       --时装项链
        [77]    = { 20 },       --时装项链
        [78]    = { 21 },       --时装头盔
        [79]    = { 22, 23 },   --时装手镯
        [80]    = { 22, 23 },   --时装手镯
        [81]    = { 24, 25 },   --时装戒指
        [82]    = { 24, 25 },   --时装戒指
        [83]    = { 26 },       --时装勋章
        [84]    = { 27 },       --时装腰带
        [85]    = { 27 },       --时装腰带
        [86]    = { 28 },       --时装靴子
        [87]    = { 28 },       --时装靴子
        [88]    = { 29 },       --时装宝石
        [89]    = { 29 },       --时装宝石

        [100]   = { 30 },       --首饰盒位置1
        [101]   = { 31 },       --首饰盒位置2
        [102]   = { 32 },       --首饰盒位置3
        [103]   = { 33 },       --首饰盒位置4
        [104]   = { 34 },       --首饰盒位置5
        [105]   = { 35 },       --首饰盒位置6
        [106]   = { 36 },       --首饰盒位置7
        [107]   = { 37 },       --首饰盒位置8
        [108]   = { 38 },       --首饰盒位置9
        [109]   = { 39 },       --首饰盒位置10
        [110]   = { 40 },       --首饰盒位置11
        [111]   = { 41 },       --首饰盒位置12

        [90]    = { 42 },       --时装马牌
        [91]    = { 43 },       --时装符印
        [92]    = { 44 },       --时装军鼓
        [93]    = { 45 },       --时装盾牌
        [94]    = { 46 },       --时装面巾

        --自定义装备位

    },
    --使用的装备位置
    equipWhere           = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89 },
    --战士技能
    skillIdList          = { 3, 7, 12, 25, 26, 27, 36, 39, 40, 41, 42, 43, 56, 66, 71, 81, 82 },
    --装备位置名字常量
    equipconst           = {
        ["武器"] = "<$WEAPON>",
        ["衣服"] = "<$DRESS>",
        ["勋章"] = "<$RIGHTHAND>",
        ["项链"] = "<$NECKLACE>",
        ["头盔"] = "<$HELMET>",
        ["右手镯"] = "<$ARMRING_R>",
        ["左手镯"] = "<$ARMRING_L>",
        ["右戒指"] = "<$RING_R>",
        ["左戒指"] = "<$RING_L>",
        ["毒符"] = "<$BUJUK>",
        ["腰带"] = "<$BELT>",
        ["靴子"] = "<$BOOTS>",
        ["宝石"] = "<$CHARM>",
        ["斗笠"] = "<$HAT>",
        ["军鼓"] = "<$DRUM>",
        ["马牌"] = "<$HORSE>",
        ["盾牌"] = "<$SHIELD>",
        ["面巾"] = "<$FTOWEL>",
        ["时装武器"] = "<$SWEAPON>",
        ["时装衣服"] = "<$SDRESS>",
        ["时装斗笠"] = "<$SHAT>",
        ["时装项链"] = "<$SNECKLACE>",
        ["时装头盔"] = "<$SHELMET>",
        ["时装右手镯"] = "<$SARMRING_L>",
        ["时装左手镯"] = "<$SARMRING_R>",
        ["时装左戒指"] = "<$SRING_R>",
        ["时装右戒指"] = "<$SRING_L>",
        ["时装勋章"] = "<$SRIGHTHAND>",
        ["时装腰带"] = "<$SBELT>",
        ["时装靴子"] = "<$SBOOTS>",
        ["时装宝石"] = "<$SCHARM>",
        ["时装马牌"] = "<$SHORSE>",
        ["时装符印"] = "<$SBUJUK>",
        ["时装军鼓"] = "<$SDRUM>",
        ["时装盾牌"] = "<$SSHIELD>",
        ["时装面巾"] = "<$SFTOWEL>",
        ["首饰盒位置1"] = "<$GODBLESSITEM1>",
        ["首饰盒位置2"] = "<$GODBLESSITEM2>",
        ["首饰盒位置3"] = "<$GODBLESSITEM3>",
        ["首饰盒位置4"] = "<$GODBLESSITEM4>",
        ["首饰盒位置5"] = "<$GODBLESSITEM5>",
        ["首饰盒位置6"] = "<$GODBLESSITEM6>",
        ["首饰盒位置7"] = "<$GODBLESSITEM7>",
        ["首饰盒位置8"] = "<$GODBLESSITEM8>",
        ["首饰盒位置9"] = "<$GODBLESSITEM9>",
        ["首饰盒位置10"] = "<$GODBLESSITEM10>",
        ["首饰盒位置11"] = "<$GODBLESSITEM11>",
        ["首饰盒位置12"] = "<$GODBLESSITEM12>",
    },

    TM                   = {
        ["凡品"] = 1,
        ["灵品"] = 2,
        ["仙品"] = 3,
        ["圣品"] = 4,
        ["帝品"] = 5,
    },

    activitystate        = {
        closing = 0,         --关闭中
        opening = 1,         --进行中
        ended   = 2,         --已结束
    },

    flag                 = {
        no  = 0,
        yes = 1,
    },
    --初次登陆给予的技能id
    first_login_addskill = {
        3,      --基本剑术
        7,      --攻杀剑术
        12,     --刺杀剑术
        26,     --烈火剑法
        27,     --野蛮冲撞
    },
    --新人登录赠送装备
    first_give_equip     = {

    },
    --新人登录赠送物品
    first_give_item      = {
    },
    --回收过滤
    HuiShouFilter        = {
        "1",     --金币
        "2",     --元宝
    },
    --自定义创建的NPC列表
    customNpc            = {
    },
    GuideTaskInfo       = {
    },
    main_city            = "xtc", --脱离战斗时间
    disengageFight       = 6, --脱离战斗时间
    binding              = 1363, --绑定物品规则
    daysec               = 86400, --一天的秒数
    attrtime             = 123456789, --附加属性时间
    bagcellnum           = 126, --固定背包有120个格子
    warehousecellnum     = 240, --仓库开启格子数量
    -- pickuptime              = 1000,             --物品掉落只有自己可捡取时间
    paoDian              = 2000, --泡点经验
    DEBUG                = false , --调试模式
}

return ConstCfg
