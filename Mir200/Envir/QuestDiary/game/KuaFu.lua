
--进入跨服触发
function kflogin(actor)

    GameEvent.push(EventCfg.onKFLogin, actor, "进入跨服触发")

    release_print("跨服服务器进入")
    setbaseinfo(actor,57,0)
    addtocastlewarlistex(getguildinfo(getmyguild(actor),1))

    --跨服开启拾取小精灵
    pickupitems(actor, 0, 10, 500)


    setflagstatus(actor,VarCfg["F_是否进入过跨服"],1)

end
--跨服回来需要清理的buff
local function kuafuendDelBuff(actor)

end
--返回本服触发
function kuafuend(actor)
    GameEvent.push(EventCfg.onKuaFuEnd, actor)
    kuafuendDelBuff(actor)
end

--本服通知跨服
function bfsyscall1(actor, arg1, arg2)

end

function bfsyscall2(actor, arg1, arg2)

end

function bfsyscall3(actor, arg1, arg2)

end

function bfsyscall4(actor, arg1, arg2)

end

function bfsyscall5(actor, arg1, arg2)

end

function bfsyscall6(actor, arg1, arg2)

end

function bfsyscall7(actor, arg1, arg2)

end

function bfsyscall8(actor, arg1, arg2)

end

function bfsyscall9(actor, arg1, arg2)

end

function bfsyscall10(actor, arg1, arg2)

end

function bfsyscall11(actor, arg1, arg2)

end

function bfsyscall12(actor, arg1, arg2)

end

function bfsyscall13(actor, arg1, arg2)

end

function bfsyscall14(actor, arg1, arg2)

end

function bfsyscall15(actor, arg1, arg2)

end

function bfsyscall16(actor, arg1, arg2)

end

function bfsyscall17(actor, arg1, arg2)

end

function bfsyscall18(actor, arg1, arg2)

end

function bfsyscall19(actor, arg1, arg2)

end

function bfsyscall20(actor, arg1, arg2)

end

function bfsyscall21(actor, arg1, arg2)

end

function bfsyscall22(actor, arg1, arg2)

end

function bfsyscall23(actor, arg1, arg2)

end

function bfsyscall24(actor, arg1, arg2)

end

function bfsyscall25(actor, arg1, arg2)

end

function bfsyscall26(actor, arg1, arg2)

end

function bfsyscall27(actor, arg1, arg2)

end

function bfsyscall28(actor, arg1, arg2)

end

function bfsyscall29(actor, arg1, arg2)

end


function bfsyscall30(actor, arg1, arg2)
end


function bfsyscall31(actor, arg1, arg2)
end

function bfsyscall32(actor, arg1, arg2)

end

--本服到执行脚本
function bfsyscall33(actor, arg1, arg2)
    local index = tonumber(arg1) or 0
    local func = BenFutoKuaFuRunScript[index]
    if func then
        func(actor, arg2)
    end
end

function bfsyscall34(actor, arg1, arg2)

end

--本服到跨服执行事件派发
function bfsyscall35(actor, arg1, arg2)
    GameEvent.push(arg1, actor, arg2)
end

--本服到跨服执行事件派发 系统执行
function bfsyscall36(arg1, arg2)
    GameEvent.push(arg1, arg2)
end


--跨服通知本服
function kfsyscall1(actor, arg1, arg2)

end

function kfsyscall2(actor, arg1, arg2)

end

function kfsyscall3(actor, arg1, arg2)

end

function kfsyscall4(actor, arg1, arg2)

end

function kfsyscall5(actor, arg1, arg2)

end

function kfsyscall6(actor, arg1, arg2)

end

function kfsyscall7(actor, arg1, arg2)

end

function kfsyscall8(actor, arg1, arg2)

end

function kfsyscall9(actor, arg1, arg2)

end

function kfsyscall10(actor, arg1, arg2)

end

function kfsyscall11(actor, arg1, arg2)

end

function kfsyscall12(actor, arg1, arg2)

end

function kfsyscall13(actor, arg1, arg2)

end

function kfsyscall14(actor, arg1, arg2)

end

function kfsyscall15(actor, arg1, arg2)

end

function kfsyscall16(actor, arg1, arg2)

end

function kfsyscall17(actor, arg1, arg2)

end

function kfsyscall18(actor, arg1, arg2)

end

function kfsyscall19(actor, arg1, arg2)

end

function kfsyscall20(actor, arg1, arg2)

end

function kfsyscall21(actor, arg1, arg2)

end

function kfsyscall22(actor, arg1, arg2)

end

function kfsyscall23(actor, arg1, arg2)

end

function kfsyscall24(actor, arg1, arg2)

end

function kfsyscall25(actor, arg1, arg2)

end

function kfsyscall26(actor, arg1, arg2)

end

function kfsyscall27(actor, arg1, arg2)

end

function kfsyscall28(actor, arg1, arg2)

end

function kfsyscall29(actor, arg1, arg2)

end

function kfsyscall30(actor, arg1, arg2)

end
function kfsyscall49(actor, arg1, arg2)

end


function kfsyscall50(actor, arg1, arg2)

end

function kfsyscall51(actor, arg1, arg2)

end

--跨服到本服执行删除称号 狂暴
function kfsyscall52(actor, arg1, arg2)
    local titleName = arg1
    if titleName == "" then
        return
    end
    --删除技能
    local skillId = getskillindex("十步一杀")
    delskill(actor, skillId)
    deprivetitle(actor, titleName)
end

function kfsyscall53(actor, arg1, arg2)

end
function kfsyscall54(actor, arg1, arg2)
end

--跨服到本服执行事件派发 
function kfsyscall55(actor, arg1, arg2)
    GameEvent.push(arg1, actor, arg2)
end

--跨服到本服执行事件派发 系统触发
function kfsyscall56(obj, arg1, arg2)
    GameEvent.push(arg1, arg2)
end
