
npc = {}


--

local _config = Guard.getConfig("npc_1002")

local FASHION_ATTR_LIST_NAME = "时装属性"

local function refreshFashionAttr(play)
    local T_data = Player.getJsonTableByVar(play, VarCfg.T_szjl)
    T_data.yjs = T_data.yjs or {}

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

    local attrsstr = Player.getAttrTableToStr(attrs)
    if attrsstr and attrsstr ~= "" then
        addattlist(play, FASHION_ATTR_LIST_NAME, "=", attrsstr, 1)
    else
        delattlist(play, FASHION_ATTR_LIST_NAME)
    end
end


function npc.main(play,npcid)
    local data = {}
    data["T_data"] = Player.getJsonTableByVar(play, VarCfg.T_szjl)
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
    local __guardAllowedActions = Guard.newActionSet({1})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end
    local T_data = Player.getJsonTableByVar(play, VarCfg.T_szjl)

    if ew == 1 then ----更换装扮
        T_data.dqzb = T_data.dqzb or 0
        T_data.yjs = T_data.yjs or {}
        if T_data.dqzb == aid then
            Player.sendmsgEx(play, "当前装扮已是该装扮，无需更换")
            return
        else
            if not (aid > 0 and aid <= #_config.details.sz) then
                Player.sendmsgEx(play, "装扮不存在，无法更换")
                return
            end

            if not T_data.yjs[""..aid] or T_data.yjs[""..aid] ~= 1 then
                Player.sendmsgEx(play, "你还未拥有该装扮，无法更换")
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
            Player.sendmsgEx(play, "更换装扮成功")
            local data = {}
            data["T_data"] = T_data
            sendluamsg(play,100,npcid,1,0,tbl2json(data))
        end
    end
end


-- --登录触发
local function _onLoginEnd(play, logindatas)
    local T_data = Player.getJsonTableByVar(play, VarCfg.T_szjl)
    T_data.dqzb = T_data.dqzb or 0

    refreshFashionAttr(play)

end
--事件派发
GameEvent.add(EventCfg.onLoginEnd, _onLoginEnd, "装扮")
GameEvent.add(EventCfg.onKFLogin, _onLoginEnd, "装扮")


--显示时装触发
local function _onShowFashion(play)
    local T_data = Player.getJsonTableByVar(play, VarCfg.T_szjl)
    T_data.dqzb = T_data.dqzb or 0

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