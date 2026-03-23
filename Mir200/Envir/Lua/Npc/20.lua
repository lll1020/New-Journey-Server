npc = {}


--冠名

local _config = Guard.getConfig("npc_20")

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
