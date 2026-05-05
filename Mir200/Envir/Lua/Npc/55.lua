npc = {}
local _config = {
    id = 55,
    shaguai_id = 3,
    name = "开辟仙府",
    -- rwjl = {{"仙草种子",9},{"绑定元宝",200000}},
    permit_item = "开辟许可证",   -- 许可证开辟：消耗 1 个开辟许可证
    force_cost = {{"碎岩锤",2}},  -- 强行开辟：消耗碎岩锤*2
}
local function _has_permit(play)
    return getbagitemcount(play, _config.permit_item) > 0
end
-- 开辟许可证为普通物品，点击按钮时直接扣除 1 个。
local function _consume_permit(play)
    if not _has_permit(play) then
        return false
    end
    Player.takeItemByTable(play, {{_config.permit_item, 1}}, ",开辟许可证开辟", nil)
    return true
end
local function _build_main_data(play)
    local data = {}
    data["sg_data"] = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
    data["jq_data"] = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    data["open_cfg"] = {
        permit_item = _config.permit_item,
        has_permit = _has_permit(play) and 1 or 0,
        permit_count = getbagitemcount(play, _config.permit_item),
        force_cost = _config.force_cost,
        hammer_count = getbagitemcount(play, "碎岩锤"),
    }
    return data
end
local function _finish_open(play, npcid, jq_data, sg_data, open_way)
    jq_data["npc_55"] = 2
    if (jq_data["npc_55"] or 0) >= 2 then
        Guard.clearTaskTemp(jq_data, "npc_55")
        jq_data["npc_55"] = 2
    end
    jq_data["npc_55_way"] = open_way
    Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
-- 开辟完成后清掉旧杀怪进度，兼容历史脏数据。
    sg_data["npc_55"] = nil
    Player.setJsonVarByTable(play, VarCfg["T_各剧情杀怪"], sg_data)
    shaguai.jian(play, _config.shaguai_id)
    if Npclib and Npclib[44] and Npclib[44].markOpened then
        Npclib[44].markOpened(play)
    end
    Player.sendmsgEx(play, "开辟成功#57")
    sendluamsg(play,101,1005,0,0,"rwwc")
    -- Player.rwjl(play, _config.rwjl, "开辟仙府任务奖励",1)
    sendluamsg(play,100,npcid,1,2,tbl2json(_build_main_data(play)))
    sendluamsg(play, 101, 9999, 0, 0, "npc_"..npcid)
    Npclib[44].main(play, 44)
end
function npc.main(play,npcid)
    sendluamsg(play,100,npcid,0,0,tbl2json(_build_main_data(play)))
end
function npc.link(play, npcid, p2, p3, msgData)
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local __guardAction = Guard.normalizeAction(play, npcid, p2)
    if __guardAction == nil then
        return
    end
    p2 = __guardAction
    local __guardAllowedActions = Guard.newActionSet({1, 2})
    if not Guard.ensureActionAllowed(play, npcid, p2, __guardAllowedActions) then
        return
    end
    local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    if jq_data["npc_55"] and jq_data["npc_55"] >= 2 then
        Player.sendmsgEx(play, "你已经完成过开辟仙府#57")
        return
    end
    if p2 == 1 then
        if not _has_permit(play) then
            Player.sendmsgEx(play, "未拥有#57|【".._config.permit_item.."】#249|，无法进行许可证开辟#57")
            return
        end
        if not _consume_permit(play) then
            Player.sendmsgEx(play, "扣除#57|【".._config.permit_item.."】#249|失败，请检查物品状态#57")
            return
        end
        _finish_open(play, npcid, jq_data, sg_data, 1)
    elseif p2 == 2 then
        local name, num = Player.checkItemNumByTable(play, _config.force_cost)
        if name then
            Player.sendmsgEx(play, string.format("你的#57|【%s】#249|不足：#57|【%d】#249|", name, num))
            return
        end
        Player.takeItemByTable(play, _config.force_cost, ",强行开辟仙府", nil)
        _finish_open(play, npcid, jq_data, sg_data, 2)
    end
end
return npc
