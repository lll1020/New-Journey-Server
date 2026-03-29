npc = {}

-- 神庙逃亡
-- 1) 每击杀100只怪可前进一步
-- 2) 一共12格，最多移动4次，每次随机1~5格（并强约束第4次到终点）
-- 3) 奖励分离：属性奖励与物品奖励分开结算
-- 4) 属性采用登录监听回灌，并使用 npc696_ 前缀绕过清理

local _cfg_key = "npc_696"
local _config = Guard.getConfig(_cfg_key)
local _task_cfg = (_config and _config.task_cfg) or {}
local _shaguai_id = tonumber(_config and (_config.shaguai_id or string.match(_cfg_key, "%d+")) or 0) or 0

local _attr_list_name = "神庙逃亡奖励"

-- 持久字段：故意不使用 npc_696_ 前缀，绕过 Guard.clearTaskTemp(jq_data, "npc_696")
local _persist_prefix = "npc696_"
local _pos_key = _persist_prefix .. "pos"
local _move_key = _persist_prefix .. "move"
local _attr_cache_key = _persist_prefix .. "attr_cache"

local function _toint(v, d)
    local n = tonumber(v)
    if n == nil then
        return d
    end
    return math.floor(n)
end

local function _grid_goal()
    return _toint(_task_cfg.grid_goal or 12, 12)
end

local function _max_moves()
    return _toint(_task_cfg.max_moves or _task_cfg.max_reward_round or 4, 4)
end

local function _kill_per_step()
    return _toint(_task_cfg.kill_per_step or 100, 100)
end

local function _move_min()
    return _toint(_task_cfg.move_min or 1, 1)
end

local function _move_max()
    return _toint(_task_cfg.move_max or 5, 5)
end

local function _attr_cnt_key(attr_id)
    return _persist_prefix .. "attr_" .. tostring(attr_id)
end

local function _rebuild_attr_cache(jq_data)
    local attrs = {}
    for k, v in pairs(jq_data) do
        if type(k) == "string" and string.sub(k, 1, #(_persist_prefix .. "attr_")) == (_persist_prefix .. "attr_") then
            local aid = tonumber(string.match(k, "(%d+)$") or 0) or 0
            local val = tonumber(v or 0) or 0
            if aid > 0 and val ~= 0 then
                attrs[aid] = (attrs[aid] or 0) + val
            end
        end
    end

    local attrsstr = Player.getAttrTableToStr(attrs)
    if attrsstr and attrsstr ~= "" then
        jq_data[_attr_cache_key] = attrsstr
    else
        jq_data[_attr_cache_key] = nil
    end
end

local function _apply_attr_cache(play)
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local attrsstr = jq_data[_attr_cache_key]

    Player.del_attlist(play, _attr_list_name)
    if attrsstr and attrsstr ~= "" then
        Player.addattlist(play, _attr_list_name, "=", attrsstr, 1)
    end
end

local function _add_attr_pack(jq_data, attr_pack)
    if type(attr_pack) ~= "table" or #attr_pack <= 0 then
        return false
    end

    local changed = false
    for _, it in ipairs(attr_pack) do
        local aid = tonumber(it[1] or 0) or 0
        local val = tonumber(it[2] or 0) or 0
        if aid > 0 and val ~= 0 then
            local key = _attr_cnt_key(aid)
            jq_data[key] = (tonumber(jq_data[key] or 0) or 0) + val
            changed = true
        end
    end

    if changed then
        _rebuild_attr_cache(jq_data)
    end
    return changed
end

local function _attr_pack_desc(attr_pack)
    if type(attr_pack) ~= "table" or #attr_pack <= 0 then
        return ""
    end
    local list = {}
    for _, it in ipairs(attr_pack) do
        local aid = tonumber(it[1] or 0) or 0
        local val = tonumber(it[2] or 0) or 0
        if aid > 0 and val ~= 0 then
            if aid == 244 then
                table.insert(list, "切割+"..val)
            else
                table.insert(list, "属性"..aid.."+"..val)
            end
        end
    end
    return table.concat(list, "、")
end

local function _give_item_pack(play, item_pack)
    if type(item_pack) ~= "table" or #item_pack <= 0 then
        return false
    end
    Player.rwjl(play, item_pack, (_config.name or "剧情任务") .. "阶段奖励", 1)
    return true
end

-- 随机步数（强约束：当前步选择后，剩余步数必须可达终点）
local function _roll_step(pos, used_moves)
    local goal = _grid_goal()
    local max_moves = _max_moves()
    local mn = _move_min()
    local mx = _move_max()

    local moves_left = max_moves - used_moves
    local remain = goal - pos
    if moves_left <= 0 or remain <= 0 then
        return 0
    end

    local cands = {}
    for s = mn, mx do
        if s <= remain then
            local remain_after = remain - s
            local min_possible = (moves_left - 1) * mn
            local max_possible = (moves_left - 1) * mx
            if remain_after >= min_possible and remain_after <= max_possible then
                table.insert(cands, s)
            end
        end
    end

    if #cands <= 0 then
        local fallback = remain
        if fallback < mn then
            fallback = mn
        elseif fallback > mx then
            fallback = mx
        end
        return fallback
    end

    return cands[math.random(1, #cands)]
end

local function _ensure_kill_listener(play, jq_data)
    local state = tonumber(jq_data[_cfg_key] or 0) or 0
    if state ~= 1 then
        return
    end
    local moves = tonumber(jq_data[_move_key] or 0) or 0
    if moves >= _max_moves() then
        return
    end
    if _shaguai_id > 0 then
        shaguai.jia(play, _shaguai_id)
    end
end

local function _complete_task(play, jq_data)
    jq_data[_cfg_key] = 2
    jq_data[_cfg_key .. "_a"] = nil
    Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)

    if _shaguai_id > 0 then
        shaguai.jian(play, _shaguai_id)
    end

    Player.sendmsgEx(play, "|【"..(_config.name or "任务").."】#249|完成#57")
    sendluamsg(play,101,1005,0,0,"rwwc")
    Guard.giveTaskReward(play, _config, (_config.name or "剧情任务").."奖励")
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
    if state >= 2 then
        Player.sendmsgEx(play, "你已经完成#57|【"..(_config.name or "该任务").."】#249|")
        return
    end

    if state < 1 then
        jq_data[_cfg_key] = 1
        jq_data[_pos_key] = tonumber(jq_data[_pos_key] or 0) or 0
        jq_data[_move_key] = tonumber(jq_data[_move_key] or 0) or 0
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)

        Player.sendmsgEx(play, "领取|【"..(_config.name or "任务").."】#249|")
        _ensure_kill_listener(play, jq_data)
        sendluamsg(play,101,1005,0,0,"rwjs")
        sendluamsg(play,100,npcid,1,0,"")
        return
    end

    local req_map = _task_cfg.map or "白骨神庙"
    if req_map ~= "" and getbaseinfo(play,3) ~= req_map and getbaseinfo(play,3) ~= "xtc" then
        Player.sendmsgEx(play, "请前往#57|【"..req_map.."】#249|击杀怪物后再前进#57")
        return
    end

    local pos = tonumber(jq_data[_pos_key] or 0) or 0
    local moves = tonumber(jq_data[_move_key] or 0) or 0
    local max_moves = _max_moves()
    local goal = _grid_goal()

    if moves >= max_moves then
        if pos >= goal then
            _complete_task(play, jq_data)
        else
            Player.sendmsgEx(play, "移动次数已用尽，未到终点，请检查配置参数#57")
        end
        return
    end

    local kill_cur = tonumber(sg_data[_cfg_key] or 0) or 0
    local need_kill = (moves + 1) * _kill_per_step()
    if kill_cur < need_kill then
        Player.sendmsgEx(play, string.format("击杀不足：#57|【%d/%d】#249|（下一步）#57", kill_cur, need_kill))
        return
    end

    local step = _roll_step(pos, moves)
    if step <= 0 then
        Player.sendmsgEx(play, "当前无法前进，请检查步数配置#57")
        return
    end

    moves = moves + 1
    pos = pos + step
    if pos > goal then
        pos = goal
    end

    jq_data[_move_key] = moves
    jq_data[_pos_key] = pos

    -- 阶段奖励：属性奖励与物品奖励分开结算
    local attr_pack = (_task_cfg.step_attr_rewards and _task_cfg.step_attr_rewards[moves]) or nil
    local item_pack = (_task_cfg.step_item_rewards and _task_cfg.step_item_rewards[moves]) or nil

    local attr_changed = _add_attr_pack(jq_data, attr_pack)
    Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)

    if attr_changed then
        _apply_attr_cache(play)
        local desc = _attr_pack_desc(attr_pack)
        if desc ~= "" then
            Player.sendmsgEx(play, "获得属性奖励：|【"..desc.."】#249|")
        end
    end

    if _give_item_pack(play, item_pack) then
        Player.sendmsgEx(play, "获得|【物品奖励】#249|")
    end

    Player.sendmsgEx(play, string.format("前进|【%d格】#249|，当前位置：|【%d/%d】#249|（第|【%d/%d次】#249|）", step, pos, goal, moves, max_moves))

    if moves >= max_moves and pos >= goal then
        _complete_task(play, jq_data)
        sendluamsg(play,100,npcid,1,moves,"")
        return
    end

    _ensure_kill_listener(play, jq_data)
    sendluamsg(play,100,npcid,1,moves,"")
end

-- 登录监听：1) 回灌属性 2) 恢复击杀监听
function Login_jq_696(play)
    _apply_attr_cache(play)

    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    _ensure_kill_listener(play, jq_data)
end
GameEvent.add(EventCfg.onLogin, Login_jq_696, "Login_神庙逃亡")

return npc



