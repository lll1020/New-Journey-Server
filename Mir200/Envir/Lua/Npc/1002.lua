
npc = {}


--

local _config = Guard.getConfig("npc_1002")
local TalentTree = rawget(_G, "TalentTree") or include("lua/LuaLib/talent_tree.lua")

local FASHION_ATTR_LIST_NAME = "时装属性"

local function initHaloData(T_data)
    T_data.gh = T_data.gh or {}
    T_data.dqgh = tonumber(T_data.dqgh or 0) or 0
end

local function getHaloConfig(index)
    return ((_config.details or {}).gh or {})[tonumber(index) or 0]
end

local function hasHalo(play, index)
    local cfg = getHaloConfig(index)
    if not cfg then
        return false
    end
    if cfg.need_core_level then
        return TalentTree and TalentTree.hasCoreLevel and TalentTree.hasCoreLevel(play, cfg.need_core_level)
    end
    if cfg.title and cfg.title ~= "" then
        return checktitle(play, cfg.title)
    end
    return false
end

local function clearHaloEffect(play, index)
    local cfg = getHaloConfig(index)
    if cfg and cfg.sEffect then
        clearplayeffect(play, cfg.sEffect)
    end
end

local function clearAllHaloEffects(play)
    for idx in ipairs((_config.details or {}).gh or {}) do
        clearHaloEffect(play, idx)
    end
end

local function playHaloEffect(play, index)
    local cfg = getHaloConfig(index)
    if cfg and cfg.sEffect then
        playeffect(play, cfg.sEffect, 0, 0, 0, 1, 0)
    end
end

local function refreshHaloState(play, T_data)
    initHaloData(T_data)
    for idx in ipairs((_config.details or {}).gh or {}) do
        T_data.gh[tostring(idx)] = hasHalo(play, idx) and 1 or 0
    end
    if T_data.dqgh > 0 and T_data.gh[tostring(T_data.dqgh)] ~= 1 then
        clearHaloEffect(play, T_data.dqgh)
        T_data.dqgh = 0
    end
end

local function syncHaloEffect(play, T_data)
    initHaloData(T_data)
    clearAllHaloEffects(play)
    if T_data.dqgh > 0 and T_data.gh[tostring(T_data.dqgh)] == 1 then
        playHaloEffect(play, T_data.dqgh)
    end
end
local function refreshFashionAttr(play)
    local T_data = Player.getJsonTableByVar(play, VarCfg.T_szjl)
    T_data.yjs = T_data.yjs or {}
    T_data.yjszj = T_data.yjszj or {}

    local attrs = {}
    for idx, cfg in ipairs(_config.details.sz or {}) do
        if T_data.yjs[tostring(idx)] == 1 then
            for _, attr in ipairs(cfg.attr or {}) do
                local attrId = tonumber(attr[1])
                local attrValue = tonumber(attr[2]) or 0
                if attrId and attrValue > 0 then
                    attrs[attrId] = (attrs[attrId] or 0) + attrValue
                end
            end
        end
    end
    for idx, cfg in ipairs(_config.details.zj or {}) do
        if T_data.yjszj[tostring(idx)] == 1 then
            for _, attr in ipairs(cfg.attr or {}) do
                local attrId = tonumber(attr[1])
                local attrValue = tonumber(attr[2]) or 0
                if attrId and attrValue > 0 then
                    attrs[attrId] = (attrs[attrId] or 0) + attrValue
                end
            end
        end
    end

    local attrsstr = Player.getAttrTableToStr(attrs)
    if attrsstr and attrsstr ~= "" then
        Player.add_attlist(play, FASHION_ATTR_LIST_NAME, "=", attrsstr, 1)
    else
        Player.del_attlist(play, FASHION_ATTR_LIST_NAME)
    end
    T_data.dqzj = T_data.dqzj or 0
    if T_data.dqzj > 0 then
        setmoveeff(play,_config.details.zj[T_data.dqzj].sEffect,0)
    end

end


function npc.main(play,npcid)
    local data = {}
    local T_data = Player.getJsonTableByVar(play, VarCfg.T_szjl)
    refreshHaloState(play, T_data)
    Player.setJsonVarByTable(play, VarCfg.T_szjl, T_data)
    data["T_data"] = T_data
    sendluamsg(play,100,npcid,0,0,tbl2json(data))
end

function npc.link(play,npcid,ew,aid,data)
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
    local __guardAllowedActions = Guard.newActionSet({1,2,3})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end
    local T_data = Player.getJsonTableByVar(play, VarCfg.T_szjl)
    refreshHaloState(play, T_data)

    if ew == 1 then ----更换装扮
        T_data.dqzb = T_data.dqzb or 0
        T_data.yjs = T_data.yjs or {}
        if T_data.dqzb == aid then
            Player.sendmsgEx(play, "当前装扮已是该装扮，无需更换#57")
            return
        else
            if not (aid > 0 and aid <= #_config.details.sz) then
                Player.sendmsgEx(play, "装扮不存在，无法更换#57")
                return
            end

            if not T_data.yjs[""..aid] or T_data.yjs[""..aid] ~= 1 then
                Player.sendmsgEx(play, "你还未拥有该装扮，无法更换#57")
                return
            end
            local config = _config.details.sz[aid]
            setfeature(play, 0, config.shape, 655350, 0, 0)
            setfeature(play, 1, 9999, 655350, 0, 0)
            local equipObj = linkbodyitem(play, 17)
            setitemaddvalue(play, equipObj, 1, 47, config.sEffect)
            refreshitem(play, equipObj)
            T_data.dqzb = aid
            Player.setJsonVarByTable(play, VarCfg.T_szjl, T_data)
            Player.sendmsgEx(play, "更换装扮成功，已切换到|【当前装扮】#218|")
            local data = {}
            data["T_data"] = T_data
            sendluamsg(play,100,npcid,1,0,tbl2json(data))
        end
    elseif ew == 2 then ----更换足迹
        T_data.dqzj = T_data.dqzj or 0
        T_data.yjszj = T_data.yjszj or {}
        if T_data.dqzj == aid then
            Player.sendmsgEx(play, "当前足迹已是该足迹，无需更换#57")
            return
        else
            if not (aid > 0 and aid <= #_config.details.zj) then
                Player.sendmsgEx(play, "足迹不存在，无法更换#57")
                return
            end

            if not T_data.yjszj[""..aid] or T_data.yjszj[""..aid] ~= 1 then
                Player.sendmsgEx(play, "你还未拥有该足迹，无法更换#57")
                return
            end
            if T_data.dqzj > 0 then
                clearplayeffect(play,_config.details.zj[T_data.dqzj].sEffect)
            end
            T_data.dqzj = aid

            setmoveeff(play,_config.details.zj[T_data.dqzj].sEffect,0)
            Player.setJsonVarByTable(play, VarCfg.T_szjl, T_data)
            Player.sendmsgEx(play, "更换足迹成功，已切换到|【当前足迹】#218|")
            local data = {}
            data["T_data"] = T_data
            sendluamsg(play,100,npcid,1,0,tbl2json(data))
        end
    elseif ew == 3 then ----更换光环
        initHaloData(T_data)
        aid = tonumber(aid) or 0
        if T_data.dqgh == aid then
            Player.sendmsgEx(play, "当前光环已是该光环，无需更换#57")
            return
        end
        if not getHaloConfig(aid) then
            Player.sendmsgEx(play, "光环不存在，无法更换#57")
            return
        end
        if T_data.gh[tostring(aid)] ~= 1 then
            Player.sendmsgEx(play, "你还未满足该光环条件，无法更换#57")
            return
        end
        if T_data.dqgh > 0 then
            clearHaloEffect(play, T_data.dqgh)
        end
        T_data.dqgh = aid
        playHaloEffect(play, T_data.dqgh)
        Player.setJsonVarByTable(play, VarCfg.T_szjl, T_data)
        Player.sendmsgEx(play, "更换光环成功，已切换到|【当前光环】#218|")
        local data = {}
        data["T_data"] = T_data
        sendluamsg(play,100,npcid,1,0,tbl2json(data))
    end
end
-- --登录触发
local function _onLoginEnd(play, logindatas)
    local T_data = Player.getJsonTableByVar(play, VarCfg.T_szjl)
    T_data.dqzb = T_data.dqzb or 0
    T_data.dqzj = T_data.dqzj or 0

    refreshHaloState(play, T_data)
    syncHaloEffect(play, T_data)
    Player.setJsonVarByTable(play, VarCfg.T_szjl, T_data)
    refreshFashionAttr(play)

end
--事件派发
GameEvent.add(EventCfg.onLoginEnd, _onLoginEnd, "装扮")
GameEvent.add(EventCfg.onKFLogin, _onLoginEnd, "装扮")


--显示时装触发
local function _onShowFashion(play)
    local T_data = Player.getJsonTableByVar(play, VarCfg.T_szjl)
    T_data.dqzb = T_data.dqzb or 0
    T_data.dqzj = T_data.dqzj or 0
    if T_data.dqzb > 0 then
        local config = _config.details.sz[T_data.dqzb]
        setfeature(play, 0, config.shape, 655350, 0, 0)
        setfeature(play, 1, 9999, 655350, 0, 0)
    end
end
GameEvent.add(EventCfg.onShowFashion, _onShowFashion, "装扮")
GameEvent.add(EventCfg.onLogin, _onShowFashion, "装扮")

--取消显示时装触发
local function _onNotShowFashion(actor)
    setfeature(actor, 0, -1, 655350, 0, 0)
    setfeature(actor, 1, -1, 655350, 0, 0)
end
GameEvent.add(EventCfg.onNotShowFashion, _onNotShowFashion, "装扮")




return npc
