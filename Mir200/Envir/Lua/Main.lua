release_print("--------------------加载Lua脚本--------------------")
--------------------lua初始化--------------------

local safeRequire = include("QuestDiary/game/safeRequire.lua") --安全的调用模块
math.randomseed(tostring(os.time()):reverse():sub(1,6))--随机数种子
--------------------封装函数--------------------
safeRequire("Lua/LuaLib/Lib.lua")
safeRequire("QuestDiary/util/GameEvent.lua")        --事件管理

--配置
safeRequire("QuestDiary/config/VarCfg.lua")   --变量配置
safeRequire("QuestDiary/config/EventCfg.lua") --事件配置
safeRequire("QuestDiary/config/ConstCfg.lua") --常量配置
safeRequire("QuestDiary/config/ColorCfg.lua") --颜色配置


--特殊数据
safeRequire("QuestDiary/BuffRun.lua")              --buff触发
safeRequire("QuestDiary/GMBox.lua")              --后台管理系统
safeRequire("QuestDiary/OnTimer.lua")              --定时器
safeRequire("QuestDiary/task.lua")              --任务相关

--------------------登录接口--------------------
safeRequire("Lua/LuaLib/login.lua")
--------------------常量声明--------------------
safeRequire("Lua/LuaLib/constant.lua")
--------------------BUFF模块--------------------
safeRequire("Lua/LuaLib/Buff.lua")
--------------------杀怪模块--------------------
safeRequire("Lua/LuaLib/shaguai.lua")
--------------------任务模块--------------------
safeRequire("Lua/LuaLib/rwcf.lua")
-------------------物品使用模块--------------------
safeRequire("Lua/LuaLib/useitme.lua")
--扩展
--release_print("--------------------背包接口--------------------")
safeRequire("Extension/UtilServer/Bag.lua")
--release_print("--------------------玩家接口--------------------")
safeRequire("Extension/UtilServer/Player.lua")
--release_print("--------------------物品接口--------------------")
safeRequire("Extension/UtilServer/Item.lua")

safeRequire("Extension/string.lua")
safeRequire("Extension/table.lua")
safeRequire("Extension/Function.lua")  --加载常用函数库

safeRequire("lua/Data/huishou.lua")                                                                      --回收物品配置
safeRequire("lua/Data/daluditu.lua")                                                                     --大陆地图配置
safeRequire("lua/Data/xilieditu.lua")                                                                    --系列地图区分
safeRequire("lua/Data/paokujl.lua")                                                                      --土城跑酷奖励
safeRequire("lua/Data/jinzhigj.lua")                                                                      --禁止记录地图
safeRequire("lua/Data/guaiwutype.lua")                                                                        --怪物类型
safeRequire("lua/Data/teshudata.lua")



--release_print("--------------------NPC模块--------------------")
local npcliby = {}

npcliby["anniu"] = safeRequire("Lua/Npc/anniu.lua")
Npclib = setmetatable(npcliby,{__index = function(Npclib,key)
        local fun = safeRequire("lua/Npc/"..key..".lua")
        if fun then
            rawset(Npclib,key,fun)
            return Npclib[key]
        else
            release_print("调用NPC函数失败id:("..key..")")
            return nil
        end
    end
})