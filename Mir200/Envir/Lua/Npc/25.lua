npc = {}


--幸运强化

local _config = Guard.getConfig("npc_25")
local FairyFate = include("lua/LuaLib/fairy_fate.lua")

function npc.main(play,npcid)

    local data = {}
    data["level"] = getplaydef(play, VarCfg["U_幸运强化"])
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
        local level = getplaydef(play, VarCfg["U_幸运强化"])
        if level >= _config.max_level then
            Player.sendmsgEx(play,  "你的幸运强化已达到#57|【"..level.."级】#249|，无需再提升#57")
            return
        end
        level = level + 1
        local config = _config.details[level]
        local gl = config.gl
        if xianfa_has and xianfa_has(play, "无比幸运") then
            -- 天书仙法无比幸运：提升幸运强化成功率（上限100%）
            gl = gl + 10
            if gl > 100 then
                gl = 100
            end
        end
        local name, num = Player.checkItemNumByTable(play, config.cost)
        if name then
            Player.sendmsgEx(play, string.format("你的#57|【%s】#249|不足：#57|【%d】#249|", name, num))
            return
        end
        Player.takeItemByTable(play, config.cost, ",幸运强化",nil)

        if FProbabilityHit(gl) then
            if FairyFate and FairyFate.touch then FairyFate.touch(play, "strength_fail") end
            Player.sendmsgEx(play,  "很遗憾，幸运强化失败，请继续努力#57")
            return
        end

        setplaydef(play, VarCfg["U_幸运强化"], level)
        if FairyFate and FairyFate.touch then FairyFate.touch(play, "strength_success") end
        Player.sendmsgEx(play,  "恭喜你，幸运强化成功，当前等级为|【"..level.."级】#249|")
        sendluamsg(play,100,npcid,1,0,"")
        Player.del_attlist(play, "幸运强化")
        Login_xxqh(play)

        sendluamsg(play,101,1005,0,0,"tpcg")
    end
end

function Login_xxqh(play)
    local attrs = {}
    local attrsstr = ""
    local level = getplaydef(play, VarCfg["U_幸运强化"])
    if level <= 0 then
        return
    end
    local config = _config.details[level]
    for v,k in ipairs(config.attr) do
        attrs[k[1]] = k[2]
    end
    attrsstr = Player.getAttrTableToStr(attrs)
    Player.add_attlist(play, "幸运强化", "=", attrsstr, 1)
end
GameEvent.add(EventCfg.onLogin, Login_xxqh, "Login_xxqh")



return npc



