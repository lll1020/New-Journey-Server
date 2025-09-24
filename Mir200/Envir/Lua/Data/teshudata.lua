teshudata = {
    ["npc_1"] = {
        id = 1,
        name = "灵根鉴定",
        config = {
            --配置
            {name = "金灵根",attr_desc = "固定攻击",attr = 4,range = {1,10},redrange = 8},
            {name = "木灵根",attr_desc = "固定生命",attr = 1,range = {10,100},redrange = 80},
            {name = "水灵根",attr_desc = "固定魔法",attr = 2,range = {1,10},redrange = 8},
            {name = "火灵根",attr_desc = "固定物防",attr = 10,range = {1,10},redrange = 8},
            {name = "土灵根",attr_desc = "固定魔防",attr = 12,range = {1,10},redrange = 8},
        },
    },
    ["npc_6"] = {
        id = 6,
        name = "切割之斧",
        where = 9,
        max_level = 15,
        config = {
            --配置
            [1] = {give = "切割[lv2]",cost = { {"元宝",1} },},
            [2] = {give = "切割[lv3]",cost = { {"元宝",1} },},
            [3] = {give = "切割[lv4]",cost = { {"元宝",1} },},
            [4] = {give = "切割[lv5]",cost = { {"元宝",1} },},
            [5] = {give = "切割[lv6]",cost = { {"元宝",1} },},
            [6] = {give = "切割[lv7]",cost = { {"元宝",1} },},
            [7] = {give = "切割[lv8]",cost = { {"元宝",1} },},
            [8] = {give = "切割[lv9]",cost = { {"元宝",1} },},
            [9] = {give = "切割[lv10]",cost = { {"元宝",1} },},
            [10] = {give = "切割[lv11]",cost = { {"元宝",1} },},
            [11] = {give = "切割[lv12]",cost = { {"元宝",1} },},
            [12] = {give = "切割[lv13]",cost = { {"元宝",1} },},
            [13] = {give = "切割[lv14]",cost = { {"元宝",1} },},
            [14] = {give = "切割[lv15]",cost = { {"元宝",1} },},
            [15] = {give = "空",cost = { {"元宝",1} },},
        },
    },
    ["npc_7"] = {
        id = 7,
        name = "攻速",
        where = 15,
        max_level = 10,
        config = {
            --配置
            [1] = {give = "攻速[lv2]",cost = { {"元宝",1} },},
            [2] = {give = "攻速[lv3]",cost = { {"元宝",1} },},
            [3] = {give = "攻速[lv4]",cost = { {"元宝",1} },},
            [4] = {give = "攻速[lv5]",cost = { {"元宝",1} },},
            [5] = {give = "攻速[lv6]",cost = { {"元宝",1} },},
            [6] = {give = "攻速[lv7]",cost = { {"元宝",1} },},
            [7] = {give = "攻速[lv8]",cost = { {"元宝",1} },},
            [8] = {give = "攻速[lv9]",cost = { {"元宝",1} },},
            [9] = {give = "攻速[lv10]",cost = { {"元宝",1} },},
            [10] = {give = "空",cost = { {"元宝",1} },},

        },
    },

}

return teshudata
