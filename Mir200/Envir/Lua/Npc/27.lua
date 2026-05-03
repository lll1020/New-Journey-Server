
npc = {}


--

local _config = Guard.getConfig("npc_27")


function npc.main(play,npcid)
    local data = {}
    data["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_技能升级"])
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
        local idx = tonumber(aid)
        if not idx or not _config.details[idx] or not VarCfg.N_jnsh[idx] then
            Player.sendmsgEx(play, "参数错误#57")
            return
        end
        aid = idx
        local T_data = Player.getJsonTableByVar(play, VarCfg["T_技能升级"])
        T_data.level = T_data.level or {}
        local skill_level = T_data.level[""..aid] or 0
        local next_level = skill_level + 1
        local skill_config = _config.details[aid]
        if not skill_config then
            Player.sendmsgEx(play, "该技能不存在#57")
            return
        end
        if next_level > skill_config.max_level then
            Player.sendmsgEx(play, "该技能已经达到最高等级#57")
            return
        end
        local name, num = Player.checkItemNumByTable(play, skill_config.cost)
        if name then
            Player.sendmsgEx(play, string.format("你的#57|【%s】#249|不足：#57|【%d】#249|", name, num))
            return
        end
        Player.takeItemByTable(play, skill_config.cost, ",技能升级",nil)
        T_data.level[""..aid] = next_level
        Player.setJsonVarByTable(play, VarCfg["T_技能升级"], T_data)
        sendluamsg(play,100,npcid,1,aid,"")
        Player.sendmsgEx(play, string.format("恭喜你，|【%s】#249|技能提升到了|【%d级】#249|",skill_config.name, next_level) )
        sendluamsg(play,101,1005,0,0,"qhcg")

        setplaydef(play,VarCfg.N_jnsh[aid],next_level*2)
        Login_jnsh(play)
        if next_level == 10 then
            Buff[skill_config.buff](play,1)
        end
    end
end

function Login_jnqh(play)
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_技能升级"])
    T_data.level = T_data.level or {}
    for v,k in ipairs(_config.details) do
        local level = T_data.level[""..v] or 0
        if level > 0 then
            setplaydef(play,VarCfg.N_jnsh[v],level*2)
            if level == 10 then
                Buff[k.buff](play,1)
            end
        end
    end
end
GameEvent.add(EventCfg.onLogin, Login_jnqh, "Login_jnqh")



return npc