
npc = {}



local _fashionConfig = Guard.getConfig("npc_1002")
local _fashionAttrListName = "时装属性"

local function _refreshFashionAttr(play, T_data)
    T_data = T_data or Player.getJsonTableByVar(play, VarCfg.T_szjl)
    T_data.yjs = T_data.yjs or {}

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

    local attrsstr = Player.getAttrTableToStr(attrs)
    if attrsstr and attrsstr ~= "" then
        addattlist(play, _fashionAttrListName, "=", attrsstr, 1)
    else
        delattlist(play, _fashionAttrListName)
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
    local _config = Guard.getConfig("npc_"..tostring(npcid))
    if ew == 1 then ----更换装扮
        T_data.dqzb = T_data.dqzb or 0
        T_data.yjs = T_data.yjs or {}
        if T_data.yjs["".._config.idx] and T_data.yjs["".._config.idx] == 1 then
            Player.sendmsgEx(play, "你已拥有该时装，无需解锁#57")
            return
        end
        local name, num = Player.checkItemNumByTable(play, _config.cost)
        if name then
            Player.sendmsgEx(play, string.format("你的#57|【%s】#249|不足：#57|【%d】#249|", name, num))
            return
        end
        Player.takeItemByTable(play, _config.cost, ",时装解锁",nil)
        T_data.yjs["".._config.idx] = 1
        Player.setJsonVarByTable(play, VarCfg.T_szjl, T_data)
        _refreshFashionAttr(play, T_data)
        Player.sendmsgEx(play, "恭喜你，时装解锁成功，已解锁|【对应时装】#249|")
        local data = {}
        data["T_data"] = T_data
        sendluamsg(play,100,npcid,1,0,tbl2json(data))
    end
end



return npc
