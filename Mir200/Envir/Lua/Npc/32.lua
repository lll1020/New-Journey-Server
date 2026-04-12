npc = {}


--转生

local _config = Guard.getConfig("npc_32")
local FairyFate = include("lua/LuaLib/fairy_fate.lua")

-- 备注：获取境界修炼等级
local function _zs_get_jingjie_level(play)
    local cfg = VarCfg["U_境界修炼"]
    if type(cfg) == "table" then
        return getplaydef(play, cfg[1]) or 0
    end
    return 0
end

-- 备注：检查灵根是否激活（from~to）
local function _zs_has_linggen(play, from, to)
    local data = Player.getJsonTableByVar(play, VarCfg["T_灵根"])
    local levels = data.level or {}
    for i = from, to do
        if levels[tostring(i)] == nil then
            return false
        end
    end
    return true
end

-- 备注：检查灵根是否达到指定等级（from~to）
local function _zs_has_linggen_level(play, from, to, minLevel)
    local data = Player.getJsonTableByVar(play, VarCfg["T_灵根"])
    local levels = data.level or {}
    for i = from, to do
        if (levels[tostring(i)] or 0) < minLevel then
            return false
        end
    end
    return true
end

-- 备注：转生阶段前置条件
local function _zs_check_stage_req(play, stage)
    if stage == 1 then
        if _zs_get_jingjie_level(play) < 9 then
            Player.sendmsgEx(play, "需境界达到#57|【炼气大圆满】#249|")
            return false
        end
    elseif stage == 2 then
        if (getbaseinfo(play, 6) or 0) < 60 then
            Player.sendmsgEx(play, "需等级达到#57|【60级】#249|")
            return false
        end
        if _zs_get_jingjie_level(play) < 10 then
            Player.sendmsgEx(play, "需境界达到#57|【筑基境】#249|")
            return false
        end
    elseif stage == 3 then
        local data = Player.getJsonTableByVar(play, VarCfg["T_灵根"])
        local levels = data.level or {}
        if (levels["4"] or 0) < 5 then
            Player.sendmsgEx(play, "需火灵根达到#57|【LV5】#249|")
            return false
        end
        if _zs_get_jingjie_level(play) < 14 then
            Player.sendmsgEx(play, "需境界达到#57|【金丹前期】#249|")
            return false
        end
    elseif stage == 4 then
        if not _zs_has_linggen(play, 1, 5) then
            Player.sendmsgEx(play, "需激活#57|【五行灵根】#249|")
            return false
        end
        if _zs_get_jingjie_level(play) < 17 then
            Player.sendmsgEx(play, "需境界达到#57|【金丹大圆满】#249|")
            return false
        end
    elseif stage == 5 then
        if not _zs_has_linggen(play, 1, 10) then
            Player.sendmsgEx(play, "需激活#57|【全部灵根】#249|")
            return false
        end
        if _zs_get_jingjie_level(play) < 19 then
            Player.sendmsgEx(play, "需境界达到#57|【元婴中期】#249|")
            return false
        end
    elseif stage == 6 then
        if not _zs_has_linggen_level(play, 1, 5, 10) then
            Player.sendmsgEx(play, "需#57|【五行灵根全部满级】#249|")
            return false
        end
        if _zs_get_jingjie_level(play) < 29 then
            Player.sendmsgEx(play, "需境界达到#57|【渡劫大圆满】#249|")
            return false
        end
    end
    return true
end

function npc.main(play,npcid)
    local data = {}
    local level = getplaydef(play, VarCfg["U_转生等级"])
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
        local level = getplaydef(play, VarCfg["U_转生等级"])
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
        if step == 1 then
            if not _zs_check_stage_req(play, stage) then
                return
            end
        end
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
    local level = getplaydef(play, VarCfg["U_转生等级"])
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
