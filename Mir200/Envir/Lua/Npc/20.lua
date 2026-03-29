npc = {}


--冠名

local _config = Guard.getConfig("npc_20")
local _fashionConfig = Guard.getConfig("npc_1002")
local _fashionAttrListName = "时装属性"

local function _refresh_fashion_attr(play, T_data)
    T_data = T_data or Player.getJsonTableByVar(play, VarCfg.T_szjl)
    T_data.yjs = T_data.yjs or {}
    T_data.yjszj = T_data.yjszj or {}

    local attrs = {}
    for idx, cfg in ipairs(((_fashionConfig and _fashionConfig.details and _fashionConfig.details.sz) or {})) do
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
    for idx, cfg in ipairs(((_fashionConfig and _fashionConfig.details and _fashionConfig.details.zj) or {})) do
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
        Player.addattlist(play, _fashionAttrListName, "=", attrsstr, 1)
    else
        Player.del_attlist(play, _fashionAttrListName)
    end
end

local function _grant_guanming_fashion(play)
    local szList = (_fashionConfig and _fashionConfig.details and _fashionConfig.details.sz) or {}
    local fashionIdx = 0
    for idx, cfg in ipairs(szList) do
        if cfg.name == "时装：冠名" then
            fashionIdx = idx
            break
        end
    end
    if fashionIdx <= 0 then
        return
    end

    local T_data = Player.getJsonTableByVar(play, VarCfg.T_szjl)
    T_data.yjs = T_data.yjs or {}
    if T_data.yjs[tostring(fashionIdx)] == 1 then
        return
    end
    T_data.yjs[tostring(fashionIdx)] = 1
    Player.setJsonVarByTable(play, VarCfg.T_szjl, T_data)
    GameEvent.push(EventCfg.onUPSkin, play, fashionIdx)
    _refresh_fashion_attr(play, T_data)
end

local function _set_first_guanming_player(play)
    local data = Player.getJsonTableByVar(nil, VarCfg["A_首个冠名json"])
    if data.name and data.name ~= "" then
        return
    end
    data.name = getbaseinfo(play, 1)
    data.account = tonumber(getconst(play, "<$USERACCOUNT>")) or 0
    data.charge = querymoney(play, 23)
    data.cost = _config.cost or 0
    data.kqts = getsysvar(VarCfg["G_开区天数"]) or 0
    data.kqfz = getsysvar(VarCfg["G_开区分钟"]) or 0
    data.time = os.time()
    Player.setJsonVarByTable(nil, VarCfg["A_首个冠名json"], data)
end


local function _get_guanming_panel_data(play)
    local data = {}
    data.first = Player.getJsonTableByVar(nil, VarCfg["A_首个冠名json"])
    data.has_title = checktitle(play, _config.ch) and 1 or 0
    data.charge = querymoney(play, 23)
    data.cost = _config.cost or 0
    return data
end
function npc.main(play,npcid)
    if checktitle(play, _config.ch) then
        _grant_guanming_fashion(play)
    end
    sendluamsg(play,100,npcid,0,0,tbl2json(_get_guanming_panel_data(play)))
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
        if querymoney(play,23) >= _config.cost then
            if not checktitle(play,_config.ch) then
                Player.title_give(play,_config.ch,1)
                _grant_guanming_fashion(play)
                _set_first_guanming_player(play)
                sendluamsg(play,100,npcid,0,0,tbl2json(_get_guanming_panel_data(play)))
            else
                Player.sendmsgEx(play, "您已拥有#57|【冠名称号】#249|，无需重复领取#57")
            end
        else
            Player.sendmsgEx(play, "您的充值金额不足#57|，无法领取#57|【冠名称号】#249|")
        end
    end
end

return npc
