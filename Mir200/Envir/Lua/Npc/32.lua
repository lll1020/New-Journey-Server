npc = {}

--转生

local _config = Guard.getConfig("npc_32")
local FairyFate = include("lua/LuaLib/fairy_fate.lua")

function npc.main(play,npcid)
    local data = {}
    local level = tonumber(getplaydef(play, VarCfg["U_转生等级"])) or 0
    data["level"] = level
    if level > 0 then
        local config = _config.details[level]
        if config then
            data["stage"] = config.level
            data["x_level"] = config.x_level
        else
            data["stage"] = math.floor((level - 1) / 10) + 1
            data["x_level"] = ((level - 1) % 10) + 1
        end
    end
    sendluamsg(play,100,npcid,0,0,tbl2json(data))
end

function npc.link(play,npcid,ew,aid)
    -- npc_guard: 入参校验
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local __guardAction = Guard.normalizeAction(play, npcid, ew)
    if __guardAction == nil then
        return
    end
    ew = __guardAction
    -- npc_guard: 操作白名单（优化：限定合法操作编号）
    local __guardAllowedActions = Guard.newActionSet({1})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end

    if ew == 1 then
        local level = tonumber(getplaydef(play, VarCfg["U_转生等级"])) or 0
        if level >= _config.max_level then
            Player.sendmsgEx(play, "已经满级")
            return
        end
        level = level + 1
        local config = _config.details[level]
        if not config then
            Player.sendmsgEx(play, "配置异常，请联系管理员#57")
            return
        end
        local stage = config.level or math.floor((level - 1) / 10) + 1
        local step = config.x_level or ((level - 1) % 10) + 1
        -- 转生现在只校验当前等级对应的材料与下一级配置，不再追加其他阶段前置。
        local name, num = Player.checkItemNumByTable(play, config.cost)
        if name then
            Player.sendmsgEx(play, string.format("你的#57|【%s】#249|不足：#57|【%d】#249|", name, num))
            return
        end
        Player.takeItemByTable(play, config.cost, ",转生",nil)
        setplaydef(play, VarCfg["U_转生等级"], level)
        Player.sendmsgEx(play, "升级成功，当前转生为|【"..stage.."阶"..step.."级】#249|")
        if FairyFate and FairyFate.touch then FairyFate.touch(play) end
        Player.del_attlist(play, "转生")
        Login_zsattr(play)
        if Buff and Buff.refreshHuTiGuangHuan then
            Buff.refreshHuTiGuangHuan(play)
        end
        sendluamsg(play,100,npcid,1,0,"")
        if step == 10 then
            renewlevel(play,1,0,0)
            GameEvent.push(EventCfg.onRenewlevelUP, play, 1)
            Player.sendmsgEx(play, "转生成功，当前转生为|【"..stage.."阶】#249|")
            if rwcf[npcid] then
                Player.zxrw_wancheng(play, rwcf[npcid][1], "任务") --完成任务
            end
            sendluamsg(play, 101, 9999, 0, 0, "npc_"..npcid)
        end
    end
end

function Login_zsattr(play)
    local level = tonumber(getplaydef(play, VarCfg["U_转生等级"])) or 0
    local attrs = {}
    local attrsstr = ""
    if level <= 0 then
        return
    end
    for i = 1, level do
        local config = _config.details[i]
        if config and config.attr then
            for v,k in ipairs(config.attr) do
                attrs[k[1]] = (attrs[k[1]] or 0) + k[2]
            end
        end
    end
    attrsstr = Player.getAttrTableToStr(attrs)
    Player.add_attlist(play, "转生", "=", attrsstr, 1)
end
GameEvent.add(EventCfg.onLogin, Login_zsattr, "Login_zsattr")

return npc
