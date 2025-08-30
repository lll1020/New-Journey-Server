release_print("--------------------����Lua�ű�--------------------")
--------------------lua��ʼ��--------------------

local safeRequire = include("QuestDiary/game/safeRequire.lua") --��ȫ�ĵ���ģ��
math.randomseed(tostring(os.time()):reverse():sub(1,6))--���������
--------------------��װ����--------------------
safeRequire("Lua/LuaLib/Lib.lua")
safeRequire("QuestDiary/util/GameEvent.lua")        --�¼�����

--����
safeRequire("QuestDiary/config/VarCfg.lua")   --��������
safeRequire("QuestDiary/config/EventCfg.lua") --�¼�����
safeRequire("QuestDiary/config/ConstCfg.lua") --��������
safeRequire("QuestDiary/config/ColorCfg.lua") --��ɫ����


--��������
safeRequire("QuestDiary/BuffRun.lua")              --buff����
safeRequire("QuestDiary/GMBox.lua")              --��̨����ϵͳ
safeRequire("QuestDiary/OnTimer.lua")              --��ʱ��
safeRequire("QuestDiary/task.lua")              --�������

--------------------��¼�ӿ�--------------------
safeRequire("Lua/LuaLib/login.lua")
--------------------��������--------------------
safeRequire("Lua/LuaLib/constant.lua")
--------------------BUFFģ��--------------------
safeRequire("Lua/LuaLib/Buff.lua")
--------------------ɱ��ģ��--------------------
safeRequire("Lua/LuaLib/shaguai.lua")
--------------------����ģ��--------------------
safeRequire("Lua/LuaLib/rwcf.lua")
-------------------��Ʒʹ��ģ��--------------------
safeRequire("Lua/LuaLib/useitme.lua")
--��չ
--release_print("--------------------�����ӿ�--------------------")
safeRequire("Extension/UtilServer/Bag.lua")
--release_print("--------------------��ҽӿ�--------------------")
safeRequire("Extension/UtilServer/Player.lua")
--release_print("--------------------��Ʒ�ӿ�--------------------")
safeRequire("Extension/UtilServer/Item.lua")

safeRequire("Extension/string.lua")
safeRequire("Extension/table.lua")
safeRequire("Extension/Function.lua")  --���س��ú�����

safeRequire("lua/Data/huishou.lua")                                                                      --������Ʒ����
safeRequire("lua/Data/daluditu.lua")                                                                     --��½��ͼ����
safeRequire("lua/Data/xilieditu.lua")                                                                    --ϵ�е�ͼ����
safeRequire("lua/Data/paokujl.lua")                                                                      --�����ܿά��
safeRequire("lua/Data/jinzhigj.lua")                                                                      --��ֹ��¼��ͼ
safeRequire("lua/Data/guaiwutype.lua")                                                                        --��������
safeRequire("lua/Data/teshudata.lua")



--release_print("--------------------NPCģ��--------------------")
local npcliby = {}

npcliby["anniu"] = safeRequire("Lua/Npc/anniu.lua")
Npclib = setmetatable(npcliby,{__index = function(Npclib,key)
        local fun = safeRequire("lua/Npc/"..key..".lua")
        if fun then
            rawset(Npclib,key,fun)
            return Npclib[key]
        else
            release_print("����NPC����ʧ��id:("..key..")")
            return nil
        end
    end
})