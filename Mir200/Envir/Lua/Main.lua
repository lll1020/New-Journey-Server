--------------------lua初始化--------------------
math.randomseed(tostring(os.time()):reverse():sub(1,6))--随机数种子
--------------------封装函数--------------------
require("Envir/Lua/LuaLib/Lib.lua")
--------------------登录接口--------------------
require("Envir/Lua/LuaLib/login.lua")
--------------------常量声明--------------------
dofile("Envir/Lua/LuaLib/constant.lua")
--------------------BUFF模块--------------------
require("Envir/Lua/LuaLib/Buff.lua")
--------------------杀怪模块--------------------
require("Envir/Lua/LuaLib/shaguai.lua")
--------------------任务模块--------------------
require("Envir/Lua/LuaLib/rwcf.lua")
-------------------物品使用模块--------------------
require("Envir/Lua/LuaLib/useitme.lua")

--扩展
require("Envir/Extension/Utilserver/Bag.lua")
require("Envir/Extension/Utilserver/Player.lua")
require("Envir/Extension/Utilserver/Item.lua")



local npcliby = {}

npcliby["anniu"] = dofile("Envir/Lua/Npc/anniu.lua")
Npclib = setmetatable(npcliby,{__index = function(Npclib,key)
        local fun = require("Envir/lua/Npc/"..key..".lua")
        if fun then
            rawset(Npclib,key,fun)
            return Npclib[key]
        else
            release_print("调用NPC函数失败id:("..key..")")
            return nil
        end
    end
})