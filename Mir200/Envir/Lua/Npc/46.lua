npc = {}

local _config = Guard.getConfig("npc_46")
local _need_keys = {621, 622, 623, 624, 625, 626, 627, 628}
local _route_map = {
    [1] = {
        step_id = 623,
        boss_id = 625,
        step_map = "灰界东部",
        step_x = 10,
        step_y = 66,
        boss_map = "鬼嘲深渊",
        boss_x = 174,
        boss_y = 460,
    },
    [2] = {
        step_id = 622,
        boss_id = 627,
        step_map = "灰界北部",
        step_x = 41,
        step_y = 43,
        boss_map = "叹息旷野",
        boss_x = 85,
        boss_y = 126,
    },
    [3] = {
        step_id = 624,
        boss_id = 626,
        step_map = "灰界西部",
        step_x = 21,
        step_y = 77,
        boss_map = "禁忌之海",
        boss_x = 74,
        boss_y = 67,
    },
    [4] = {
        step_id = 621,
        boss_id = 628,
        step_map = "灰界南部",
        step_x = 229,
        step_y = 144,
        boss_map = "虚妄山脉",
        boss_x = 107,
        boss_y = 97,
    },
    [5] = {
        guide_self = true,
        step_id = 46,
        step_map = "灰界",
        step_x = 205,
        step_y = 196,
    },
}

local function _get_missing_task_name(jq_data)
    for _, id in ipairs(_need_keys) do
        local key = "npc_" .. id
        if tonumber(jq_data[key] or 0) < 2 then
            local cfg = Guard.getConfig(key)
            return (cfg and cfg.name) or key
        end
    end
end

local function _guide_to_npc(play, map_name, target_id, xx, yy)
    mapmove(play, map_name, xx, yy, 2)
    sendluamsg(play, 101, 0, 1, 1, '{"lx":2,"npcdt":"' .. map_name .. '","npcid":' .. target_id .. ',"xx":' .. xx .. ',"yy":' .. yy .. '}')
end

local function _jump_to_route(play, route_idx)
    local route = _route_map[route_idx]
    if not route then
        Player.sendmsgEx(play, "分线参数错误")
        return
    end

    -- 入口面板补一个“回到灾厄入口”引导，直接跳回 46 号 NPC 自己。
    if route.guide_self then
        _guide_to_npc(play, route.step_map, route.step_id, route.step_x, route.step_y)
        return
    end

    local T_data = Player.getJsonTableByVar(play, VarCfg["T_dljq"])
    local step_key = "npc_" .. route.step_id
    local step_done = tonumber(T_data[step_key] or 0) >= 2

    if step_done then
        _guide_to_npc(play, route.boss_map, route.boss_id, route.boss_x, route.boss_y)
    else
        _guide_to_npc(play, route.step_map, route.step_id, route.step_x, route.step_y)
    end
end

function npc.main(play,npcid)
    local data = {}
    data["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_dljq"])
    sendluamsg(play,100,npcid,0,0,tbl2json(data))
end

function npc.link(play,npcid,ew,aid,data)
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local __guardAction = Guard.normalizeAction(play, npcid, ew)
    if __guardAction == nil then
        return
    end
    ew = __guardAction
    local __guardAllowedActions = Guard.newActionSet({1,2})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end

    if ew == 1 then
        local T_data = Player.getJsonTableByVar(play, VarCfg["T_dljq"])
        T_data["npc_46"] = T_data["npc_46"] or {}

        local missing_name = _get_missing_task_name(T_data)
        if missing_name then
            Player.sendmsgEx(play, "请先完成#57|【"..missing_name.."】#218|后再来提交灾厄入侵#57")
            return
        end

        if not Guard.ensureCost(play, _config.cost) then
            return
        end
        Guard.consumeCost(play, _config.cost, ","..(_config.name or "剧情任务"))

        T_data["npc_46"]["wc"] = 1
        Player.setJsonVarByTable(play, VarCfg["T_dljq"], T_data)
        Player.title_give(play, _config.ch)
        Player.sendmsgEx(play,  "恭喜你，获得称号：|【".._config.ch.."】#218|")
        sendluamsg(play,100,npcid,1,0,"")
        if rwcf and rwcf[npcid] then
            Player.zxrw_wancheng(play, rwcf[npcid][1], "任务") --完成任务
        end
    elseif ew == 2 then
        _jump_to_route(play, tonumber(aid or 0) or 0)
    end
end

return npc
