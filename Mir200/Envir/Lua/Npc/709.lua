npc = {}

-- 故人远行：
-- 1) 提交“裂开的酒壶”后获得“完好的酒壶”
-- 2) 到指定坐标使用“完好的酒壶”召唤BOSS
-- 3) 击杀后回NPC复命完成任务

local _cfg_key = "npc_709"
local _config = Guard.getConfig(_cfg_key)
local _task_cfg = (_config and _config.task_cfg) or {}

local _stage_key = _cfg_key .. "_a"     -- 1=已领取并提交裂酒壶
local _summon_key = _cfg_key .. "_b"    -- 1=已召唤BOSS（本轮）

local function _use_item_name()
    return _task_cfg.use_item or "完好的酒壶"
end

local function _need_kill()
    local n = tonumber(_task_cfg.kill_count or 1) or 1
    if n < 1 then
        n = 1
    end
    return n
end

local function _boss_name()
    return _task_cfg.boss or "请配置709任务BOSS名"
end

local function _use_pos()
    local p = _task_cfg.use_pos
    if type(p) == "table" then
        local map = p[1] or (_task_cfg.map or "阳关道")
        local x = tonumber(p[2] or 0) or 0
        local y = tonumber(p[3] or 0) or 0
        local r = tonumber(p[4] or 1) or 1
        if r < 0 then
            r = 0
        end
        return map, x, y, r
    end
    return _task_cfg.map or "阳关道", 0, 0, 1
end

local function _boss_pos()
    local p = _task_cfg.boss_pos
    if type(p) == "table" then
        local x = tonumber(p[1] or 0) or 0
        local y = tonumber(p[2] or 0) or 0
        if x > 0 and y > 0 then
            return x, y
        end
    end
    local _, ux, uy = _use_pos()
    return ux > 0 and ux or 32, uy > 0 and uy or 32
end

-- 校验是否在任务指定使用坐标
local function _check_use_pos(play)
    local map, x, y, r = _use_pos()
    local cur_map = getbaseinfo(play, 3)
    if cur_map ~= map then
        Player.sendmsgEx(play, "请前往#57|【"..map.."】#249|指定位置使用#57")
        return false
    end
    if x > 0 and y > 0 then
        local px = tonumber(getbaseinfo(play,4) or 0) or 0
        local py = tonumber(getbaseinfo(play,5) or 0) or 0
        if math.abs(px - x) > r or math.abs(py - y) > r then
            Player.sendmsgEx(play, string.format("请在坐标|【(%d,%d)】#249|附近使用，容差|【%d格】#249|#57", x, y, r))
            return false
        end
    end
    return true
end

function npc.main(play,npcid)
    if not _config then
        return
    end
    local data = {}
    data["T_dljq"] = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    data["sg_data"] = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
    sendluamsg(play,100,npcid,0,0,tbl2json(data))
end

function npc.link(play,npcid,ew,aid)
    if not _config then
        return
    end
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local __guardAction = Guard.normalizeAction(play, npcid, ew)
    if __guardAction == nil then
        return
    end
    ew = __guardAction
    local __guardAllowedActions = Guard.newActionSet({1})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end
    if ew ~= 1 then
        return
    end

    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
    local state = tonumber(jq_data[_cfg_key] or 0) or 0
    local kill_cur = tonumber(sg_data[_cfg_key] or 0) or 0
    local need = _need_kill()

    if state >= 2 then
        Player.sendmsgEx(play, "你已经完成#57|【"..(_config.name or "该任务").."】#249|")
        return
    end

    -- 第一步：提交裂开的酒壶，发放完好的酒壶
    if state < 1 then
        local req_map = _task_cfg.map or "阳关道"
        if getbaseinfo(play,3) ~= req_map and getbaseinfo(play,3) ~= "xtc" then
            Player.sendmsgEx(play, "请前往#57|【"..req_map.."】#249|接取该任务#57")
            return
        end

        local costs = _task_cfg.submit
        if not Guard.ensureCost(play, costs) then
            return
        end
        Guard.consumeCost(play, costs, ","..(_config.name or "剧情任务"))

        jq_data[_cfg_key] = 1
        jq_data[_stage_key] = 1
        jq_data[_summon_key] = nil
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)

        giveitem(play, _use_item_name(), 1)
        shaguai.jia(play, 709)

        Player.sendmsgEx(play, "已提交|【裂开的酒壶】#249|，获得|【".._use_item_name().."】#249|")
        Player.sendmsgEx(play, "请前往指定坐标使用道具召唤BOSS（完好的酒壶可重复使用）#57")
        sendluamsg(play,101,1005,0,0,"rwjs")
        sendluamsg(play,100,npcid,1,0,"")
        return
    end

    -- 第二步/第三步：未击杀前提示去使用；击杀后复命完成
    if kill_cur < need then
        Player.sendmsgEx(play, "请先在指定坐标使用#57|【".._use_item_name().."】#249|召唤并击杀BOSS#57")
        return
    end

    Guard.clearTaskTemp(jq_data, _cfg_key)
    jq_data[_cfg_key] = 2
    Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)

    Player.sendmsgEx(play, "|【"..(_config.name or "任务").."】#249|完成#57")
    sendluamsg(play,101,1005,0,0,"rwwc")
    Guard.giveTaskReward(play, _config, (_config.name or "剧情任务").."奖励")
    sendluamsg(play,100,npcid,1,1,"")
end

-- 供 useitme.lua 调用：使用“完好的酒壶”召唤BOSS
function npc_709_use_item(play, item)
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])

    local state = tonumber(jq_data[_cfg_key] or 0) or 0
    if state ~= 1 then
        Player.sendmsgEx(play, "当前任务状态不可使用该道具#57")
        return false
    end

    local need = _need_kill()
    local kill_cur = tonumber(sg_data[_cfg_key] or 0) or 0
    if kill_cur >= need then
        Player.sendmsgEx(play, "你已完成击杀，请回NPC复命#57")
        return false
    end

    if not _check_use_pos(play) then
        return false
    end

    local mk = getiteminfo(play, item, 1)
    if not mk or mk == 0 then
        Player.sendmsgEx(play, "道具不存在或已失效#57")
        return false
    end

    local item_name = getiteminfo(play, item, ConstCfg.iteminfo.name) or getiteminfo(play, item, 8)
    if item_name ~= _use_item_name() then
        Player.sendmsgEx(play, "该道具不可用于此任务#57")
        return false
    end

    local boss = _boss_name()
    if not boss or boss == "" or boss == "请配置709任务BOSS名" then
        Player.sendmsgEx(play, "BOSS配置缺失，请先配置 npc_709.task_cfg.boss#57")
        return false
    end

    -- 防止短时间重复召唤
    if tonumber(jq_data[_summon_key] or 0) == 1 then
        Player.sendmsgEx(play, "BOSS已召唤，请先完成击杀#57")
        return false
    end

    -- 完好的酒壶为任务道具：不消耗，可重复使用

    local map = getbaseinfo(play,3)
    local sx, sy = _boss_pos()
    genmonex(map, sx, sy, boss, 1, 1, 0, 54, "", 0)

    jq_data[_summon_key] = 1
    Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
    shaguai.jia(play, 709)

    Player.sendmsgEx(play, "你使用#57|【".._use_item_name().."】#249|召唤了BOSS【#57"..boss.."】#57")
    return true
end

return npc



