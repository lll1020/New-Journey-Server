release_print("--------------------加载Lua脚本--------------------")
--------------------lua初始化--------------------

local safeRequire = include("QuestDiary/game/safeRequire.lua") --安全的调用模块
math.randomseed(tostring(os.time()):reverse():sub(1,6))--随机数种子
--------------------封装函数--------------------
safeRequire("Envir/QuestDiary/util/GameEvent.lua")        --事件管理
safeRequire("Envir/QuestDiary/util/util.lua")        --通用函数

--配置
safeRequire("Envir/QuestDiary/config/VarCfg.lua")   --变量配置
safeRequire("Envir/QuestDiary/config/EventCfg.lua") --事件配置
safeRequire("Envir/QuestDiary/config/ConstCfg.lua") --常量配置
safeRequire("Envir/QuestDiary/config/ColorCfg.lua") --颜色配置

safeRequire("Envir/Lua/LuaLib/Lib.lua")
--特殊数据
safeRequire("Envir/QuestDiary/BuffRun.lua")              --buff触发
safeRequire("Envir/QuestDiary/GMBox.lua")              --后台管理系统
safeRequire("Envir/QuestDiary/OnTimer.lua")              --定时器
safeRequire("Envir/QuestDiary/task.lua")              --任务相关
safeRequire("Envir/QuestDiary/skill.lua")              --技能相关
safeRequire("Envir/QuestDiary/bl_zyjhl.lua")              --爆率触发相关

--------------------登录接口--------------------
safeRequire("Envir/Lua/LuaLib/login.lua")
--------------------常量声明--------------------
safeRequire("Envir/Lua/LuaLib/constant.lua")
--------------------BUFF模块--------------------
safeRequire("Envir/Lua/LuaLib/Buff.lua")
--------------------杀怪模块--------------------
safeRequire("Envir/Lua/LuaLib/shaguai.lua")
-------------------物品使用模块--------------------
safeRequire("Envir/Lua/LuaLib/useitme.lua")
--------------------套装属性模块--------------------
safeRequire("Envir/Lua/LuaLib/itemattr.lua")

--------------------安全辅助库模块--------------------
safeRequire("Envir/Lua/LuaLib/npc_guard.lua")


--扩展
--release_print("--------------------背包接口--------------------")
safeRequire("Envir/Extension/UtilServer/Bag.lua")
--release_print("--------------------玩家接口--------------------")
safeRequire("Envir/Extension/UtilServer/Player.lua")
safeRequire("Envir/Lua/LuaLib/cross_server_guard.lua")
--release_print("--------------------物品接口--------------------")
safeRequire("Envir/Extension/UtilServer/Item.lua")

safeRequire("Envir/Extension/string.lua")
safeRequire("Envir/Extension/table.lua")
safeRequire("Envir/Extension/Function.lua")  --加载常用函数库

safeRequire("Envir/lua/Data/huishou.lua")                                                                      --回收物品配置
safeRequire("Envir/lua/Data/daluditu.lua")                                                                     --大陆地图配置
safeRequire("Envir/lua/Data/xilieditu.lua")                                                                    --系列地图区分
safeRequire("Envir/lua/Data/paokujl.lua")                                                                      --土城跑酷奖励
safeRequire("Envir/lua/Data/jinzhigj.lua")                                                                      --禁止记录地图
safeRequire("Envir/lua/Data/guaiwutype.lua")                                                                        --怪物类型
safeRequire("Envir/lua/Data/teshudata.lua")
-- 聚宝盆需要在脚本启动时就注册登录/穿戴/杀怪监听，不能等打开 106 NPC 后再加载。
-- 同时清掉旧模块实例，确保热重载脚本时不会复用旧监听。
_G.__treasure_basin_module = nil
safeRequire("Envir/Lua/LuaLib/treasure_basin.lua")



--release_print("--------------------NPC模块--------------------")
local npcliby = {}

-- 预先直接加载的模块列表
local preloadModules = {
    "anniu",   -- 想直接加载的模块
    -- 如果以后有其他模块，也可以加在这里
    14,
    15,
    16,
    21,
    22,
    24,
    25,
    27,
    28,
    32,
    44,
    46,
    49,
    50,
    53,
    64,
    66,
    67,
    68,
    72,
    73,
    74,
    76,
    81,
    82,
    83,
    84,
    85,
    101,
    103,
    104,
    602,
    625,
    626,
    627,
    628,
    654,
    671,
    675,
    678,
    691,
    696,
    702,
    709,
    716,
    717,
    718,
    719,
    1002,
}

-- 直接加载预置模块
for _, name in ipairs(preloadModules) do
    local success, module = pcall(safeRequire, "Envir/lua/Npc/" .. name .. ".lua")
    if success and module then
        npcliby[name] = module
    else
        release_print("预加载NPC模块失败: " .. name)
    end
end

-- 动态加载其余模块
Npclib = setmetatable(npcliby, {
    __index = function(Npclib, key)
        local fun = safeRequire("Envir/lua/Npc/" .. key .. ".lua")
        if fun then
            rawset(Npclib, key, fun)
            return Npclib[key]
        else
            release_print("调用NPC函数失败id:(" .. key .. ")")
            return nil
        end
    end
})



