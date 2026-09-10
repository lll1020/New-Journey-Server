-- 图鉴静态配置只在客户端维护，用于界面展示。
-- 服务端只同步玩家激活状态、领取状态和局部变化。
--
-- 下面先放一套演示数据，方便直接测试界面层级、展开收回、卡片状态和领取按钮。
-- 正式配置时只需要替换本文件的 contents，不需要改 518.lua。
return {
    version = 1,
    demo = true,
    default_continent = "6",
    default_map = "6_map_1",
    continents = {
        {
            id = "1",
            name = "第一大陆",
            maps = {
                {
                    id = "1_map_1",
                    name = "盟重省",
                    monster = {
                        {id = "m_1_1_1", name = "盟重教主", model = 0, reward = {{"金币", 10000}}},
                        {id = "m_1_1_2", name = "赤月魔王", model = 0, reward = {{"千年玄铁", 1}}},
                        {id = "m_1_1_3", name = "暗影统领", model = 0, reward = {{"辉耀水晶", 1}}},
                        {id = "m_1_1_4", name = "远古巨龙", model = 0, reward = {{"绑定灵石", 10}}},
                    },
                    equip = {
                        {id = "e_1_1_1", name = "龙魂吊坠", reward = {{"辉耀水晶", 1}}},
                        {id = "e_1_1_2", name = "烈焰指环", reward = {{"辉耀水晶", 1}}},
                        {id = "e_1_1_3", name = "炽焰护腕", reward = {{"金币", 20000}}},
                        {id = "e_1_1_4", name = "月华流影", reward = {{"绑定灵石", 10}}},
                    },
                    chapter_reward = {{"金币", 100000}, {"千年玄铁", 5}},
                },
                {
                    id = "1_map_2",
                    name = "野火帮",
                    monster = {
                        {id = "m_1_2_1", name = "野火帮主", model = 0, reward = {{"金币", 15000}}},
                        {id = "m_1_2_2", name = "烈焰护法", model = 0, reward = {{"辉耀水晶", 1}}},
                        {id = "m_1_2_3", name = "野火长老", model = 0, reward = {{"绑定灵石", 15}}},
                    },
                    equip = {
                        {id = "e_1_2_1", name = "苍穹寂灭", reward = {{"辉耀水晶", 1}}},
                        {id = "e_1_2_2", name = "烬海残光", reward = {{"金币", 30000}}},
                        {id = "e_1_2_3", name = "惊雷震世", reward = {{"绑定灵石", 15}}},
                    },
                    chapter_reward = {{"金币", 150000}, {"斗笠碎片", 10}},
                },
            },
        },
        {
            id = "2",
            name = "二大陆",
            maps = {
                {
                    id = "2_map_1",
                    name = "二大陆主城",
                    monster = {
                        {id = "m_2_1_1", name = "天门守将", model = 0, reward = {{"金币", 20000}}},
                        {id = "m_2_1_2", name = "修罗统领", model = 0, reward = {{"辉耀水晶", 1}}},
                        {id = "m_2_1_3", name = "血影魔君", model = 0, reward = {{"神·五行石", 1}}},
                    },
                    equip = {
                        {id = "e_2_1_1", name = "雪隐残锋", reward = {{"辉耀水晶", 2}}},
                        {id = "e_2_1_2", name = "啸风逐电", reward = {{"金币", 50000}}},
                        {id = "e_2_1_3", name = "龙鳞震岳", reward = {{"神·五行石", 1}}},
                    },
                    chapter_reward = {{"金币", 200000}, {"辉耀水晶", 2}},
                },
                {
                    id = "2_map_2",
                    name = "修罗道场",
                    monster = {
                        {id = "m_2_2_1", name = "修罗战神", model = 0, reward = {{"金币", 25000}}},
                        {id = "m_2_2_2", name = "无间鬼王", model = 0, reward = {{"斗笠碎片", 10}}},
                        {id = "m_2_2_3", name = "炼狱使者", model = 0, reward = {{"辉耀水晶", 2}}},
                    },
                    equip = {
                        {id = "e_2_2_1", name = "霜雪之间", reward = {{"辉耀水晶", 2}}},
                        {id = "e_2_2_2", name = "烈焰焚天", reward = {{"金币", 60000}}},
                        {id = "e_2_2_3", name = "深渊游行", reward = {{"绑定灵石", 20}}},
                    },
                    chapter_reward = {{"金币", 250000}, {"斗笠碎片", 20}},
                },
            },
        },
        {
            id = "3",
            name = "三大陆",
            maps = {
                {
                    id = "3_map_1",
                    name = "三大陆主城",
                    monster = {
                        {id = "m_3_1_1", name = "灰界之主", model = 0, reward = {{"金币", 50000}}},
                        {id = "m_3_1_2", name = "灰界巡狩", model = 0, reward = {{"辉耀水晶", 2}}},
                        {id = "m_3_1_3", name = "灰界禁卫", model = 0, reward = {{"千年玄铁", 2}}},
                    },
                    equip = {
                        {id = "e_3_1_1", name = "烬痕", reward = {{"辉耀水晶", 3}}},
                        {id = "e_3_1_2", name = "长夜メ", reward = {{"金币", 80000}}},
                        {id = "e_3_1_3", name = "无尘", reward = {{"绑定灵石", 30}}},
                    },
                    chapter_reward = {{"金币", 500000}, {"辉耀水晶", 3}},
                },
                {
                    id = "3_map_2",
                    name = "六道轮回",
                    monster = {
                        {id = "m_3_2_1", name = "轮回天尊", model = 0, reward = {{"金币", 60000}}},
                        {id = "m_3_2_2", name = "六道使者", model = 0, reward = {{"辉耀水晶", 3}}},
                        {id = "m_3_2_3", name = "轮回守门人", model = 0, reward = {{"神·五行石", 2}}},
                    },
                    equip = {
                        {id = "e_3_2_1", name = "追云", reward = {{"辉耀水晶", 3}}},
                        {id = "e_3_2_2", name = "锁鳞", reward = {{"金币", 90000}}},
                        {id = "e_3_2_3", name = "裂天", reward = {{"绑定灵石", 30}}},
                    },
                    chapter_reward = {{"金币", 600000}, {"斗笠碎片", 30}},
                },
            },
        },
        {
            id = "4",
            name = "四大陆",
            maps = {
                {
                    id = "4_map_1",
                    name = "四大陆主城",
                    monster = {
                        {id = "m_4_1_1", name = "四象圣灵", model = 0, reward = {{"金币", 100000}}},
                        {id = "m_4_1_2", name = "天罚神将", model = 0, reward = {{"辉耀水晶", 4}}},
                        {id = "m_4_1_3", name = "玄天古魔", model = 0, reward = {{"千年玄铁", 4}}},
                    },
                    equip = {
                        {id = "e_4_1_1", name = "星陨", reward = {{"辉耀水晶", 4}}},
                        {id = "e_4_1_2", name = "寂照", reward = {{"金币", 120000}}},
                        {id = "e_4_1_3", name = "青冥幻影", reward = {{"绑定灵石", 40}}},
                    },
                    chapter_reward = {{"金币", 1000000}, {"辉耀水晶", 5}},
                },
                {
                    id = "4_map_2",
                    name = "天神禁地",
                    monster = {
                        {id = "m_4_2_1", name = "天神化身", model = 0, reward = {{"金币", 120000}}},
                        {id = "m_4_2_2", name = "禁地妖王", model = 0, reward = {{"辉耀水晶", 5}}},
                        {id = "m_4_2_3", name = "永恒守望者", model = 0, reward = {{"神·五行石", 3}}},
                    },
                    equip = {
                        {id = "e_4_2_1", name = "玄羽乘风", reward = {{"辉耀水晶", 5}}},
                        {id = "e_4_2_2", name = "曜天灵珑", reward = {{"金币", 150000}}},
                        {id = "e_4_2_3", name = "风云浩劫", reward = {{"绑定灵石", 50}}},
                    },
                    chapter_reward = {{"金币", 1200000}, {"斗笠碎片", 50}},
                },
            },
        },
        {
            id = "5",
            name = "五大陆",
            maps = {
                {
                    id = "5_map_1",
                    name = "深渊一层",
                    monster = {
                        {id = "m_5_1_1", name = "深渊领主·烬", model = 0, reward = {{"金币", 300000}}},
                        {id = "m_5_1_2", name = "血狱魔王", model = 0, reward = {{"深渊门票", 1}}},
                        {id = "m_5_1_3", name = "裂界行刑官", model = 0, reward = {{"辉耀水晶", 6}}},
                        {id = "m_5_1_4", name = "寒渊女皇", model = 0, reward = {{"中阶星尘", 1}}},
                    },
                    equip = {
                        {id = "e_5_1_1", name = "深渊凝视", reward = {{"辉耀水晶", 6}}},
                        {id = "e_5_1_2", name = "寒冰剑", reward = {{"金币", 300000}}},
                        {id = "e_5_1_3", name = "血祭残章", reward = {{"深渊门票", 1}}},
                        {id = "e_5_1_4", name = "虚空裂隙", reward = {{"中阶星尘", 1}}},
                    },
                    chapter_reward = {{"金币", 3000000}, {"深渊门票", 1}, {"辉耀水晶", 3}},
                },
                {
                    id = "5_map_2",
                    name = "深渊二层",
                    monster = {
                        {id = "m_5_2_1", name = "深渊巡游者", model = 0, reward = {{"金币", 350000}}},
                        {id = "m_5_2_2", name = "幽冥魔将", model = 0, reward = {{"深渊门票", 1}}},
                        {id = "m_5_2_3", name = "无光之王", model = 0, reward = {{"辉耀水晶", 7}}},
                    },
                    equip = {
                        {id = "e_5_2_1", name = "无情铁御", reward = {{"辉耀水晶", 7}}},
                        {id = "e_5_2_2", name = "褪色者", reward = {{"金币", 350000}}},
                        {id = "e_5_2_3", name = "七日杀", reward = {{"深渊门票", 1}}},
                    },
                    chapter_reward = {{"金币", 3500000}, {"深渊门票", 1}, {"辉耀水晶", 4}},
                },
            },
        },
        {
            id = "6",
            name = "六大陆",
            maps = {
                {
                    id = "6_map_1",
                    name = "六大陆系列地图一",
                    monster = {
                        {id = "m_6_1_1", name = "六道天魔", model = 0, reward = {{"金币", 500000}}},
                        {id = "m_6_1_2", name = "混沌古神", model = 0, reward = {{"辉耀水晶", 8}}},
                        {id = "m_6_1_3", name = "星海守望者", model = 0, reward = {{"千年玄铁", 8}}},
                        {id = "m_6_1_4", name = "终焉君主", model = 0, reward = {{"中阶星尘", 2}}},
                    },
                    equip = {
                        {id = "e_6_1_1", name = "永恒星辰", reward = {{"辉耀水晶", 8}}},
                        {id = "e_6_1_2", name = "炽焰灰烬", reward = {{"金币", 500000}}},
                        {id = "e_6_1_3", name = "紫琅", reward = {{"深渊门票", 1}}},
                        {id = "e_6_1_4", name = "逐浪", reward = {{"中阶星尘", 2}}},
                    },
                    chapter_reward = {{"金币", 5000000}, {"辉耀水晶", 5}, {"中阶星尘", 1}},
                },
                {
                    id = "6_map_2",
                    name = "六大陆系列地图二",
                    monster = {
                        {id = "m_6_2_1", name = "六界巡天使", model = 0, reward = {{"金币", 550000}}},
                        {id = "m_6_2_2", name = "苍穹古兽", model = 0, reward = {{"辉耀水晶", 9}}},
                        {id = "m_6_2_3", name = "万劫之门", model = 0, reward = {{"千年玄铁", 9}}},
                        {id = "m_6_2_4", name = "无极道尊", model = 0, reward = {{"中阶星尘", 2}}},
                    },
                    equip = {
                        {id = "e_6_2_1", name = "玄元道印", reward = {{"辉耀水晶", 9}}},
                        {id = "e_6_2_2", name = "诸神黄昏", reward = {{"金币", 550000}}},
                        {id = "e_6_2_3", name = "青冥道果", reward = {{"深渊门票", 1}}},
                        {id = "e_6_2_4", name = "噬仙印", reward = {{"中阶星尘", 2}}},
                    },
                    chapter_reward = {{"金币", 5500000}, {"辉耀水晶", 6}, {"中阶星尘", 1}},
                },
                {
                    id = "6_map_3",
                    name = "六大陆系列地图三",
                    monster = {
                        {id = "m_6_3_1", name = "鸿蒙初判", model = 0, reward = {{"金币", 600000}}},
                        {id = "m_6_3_2", name = "终末神凰", model = 0, reward = {{"辉耀水晶", 10}}},
                        {id = "m_6_3_3", name = "永恒星辰", model = 0, reward = {{"千年玄铁", 10}}},
                        {id = "m_6_3_4", name = "万法归宗", model = 0, reward = {{"中阶星尘", 3}}},
                    },
                    equip = {
                        {id = "e_6_3_1", name = "天痕", reward = {{"辉耀水晶", 10}}},
                        {id = "e_6_3_2", name = "破晓", reward = {{"金币", 600000}}},
                        {id = "e_6_3_3", name = "潜锋", reward = {{"深渊门票", 1}}},
                        {id = "e_6_3_4", name = "杀破狼", reward = {{"中阶星尘", 3}}},
                    },
                    chapter_reward = {{"金币", 6000000}, {"辉耀水晶", 7}, {"中阶星尘", 2}},
                },
            },
        },
    },
}
