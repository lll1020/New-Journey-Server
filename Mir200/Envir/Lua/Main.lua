--------------------lua��ʼ��--------------------
math.randomseed(tostring(os.time()):reverse():sub(1,6))--���������
--------------------��װ����--------------------
require("Envir/Lua/LuaLib/Lib.lua")
--------------------��¼�ӿ�--------------------
require("Envir/Lua/LuaLib/login.lua")
--------------------��������--------------------
dofile("Envir/Lua/LuaLib/constant.lua")
--------------------BUFFģ��--------------------
require("Envir/Lua/LuaLib/Buff.lua")
--------------------ɱ��ģ��--------------------
require("Envir/Lua/LuaLib/shaguai.lua")
--------------------����ģ��--------------------
require("Envir/Lua/LuaLib/rwcf.lua")
-------------------��Ʒʹ��ģ��--------------------
require("Envir/Lua/LuaLib/useitme.lua")

--��չ
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
            release_print("����NPC����ʧ��id:("..key..")")
            return nil
        end
    end
})