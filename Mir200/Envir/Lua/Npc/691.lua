npc = {}

-- reward_desc: 称号BUFF: LV+5 GMD-50-100

local _cfg_key = "npc_691"
local _config = Guard.getConfig(_cfg_key)
local _task_cfg = (_config and _config.task_cfg) or {}
local _attr_list_name = "重启世界"

-- 持久属性键：故意不使用 npc_691_ 前缀，绕过 Guard.clearTaskTemp(jq_data, "npc_691") 清理
local _persist_prefix = "npc691_"
local _attr_cache_key = _persist_prefix .. "attr_cache"

-- 兼容旧版本键（曾用 npc_691_ 前缀）
local function _legacy_attr_cnt_key(suffix)
    return _cfg_key .. "_attr_" .. tostring(suffix)
end
local _legacy_attr_cache_key = _cfg_key .. "_attr_cache"

-- 提交随机属性池：生命+10000 / 攻击+1000 / 打怪爆率+20%
local _submit_attr_pool = {
    {key = "hp", tip = "生命+10000", attrs = {{1,10000}}},
    {key = "atk", tip = "攻击+1000", attrs = {{3,1000},{4,1000}}},
    {key = "drop", tip = "打怪爆率+20%", attrs = {{242,2000}}},
}

local function _attr_cnt_key(suffix)
    return _persist_prefix .. "attr_" .. tostring(suffix)
end

local function _rebuild_attr_cache(jq_data)
    local attrs = {}
    for _, cfg in ipairs(_submit_attr_pool) do
        local cnt = tonumber(jq_data[_attr_cnt_key(cfg.key)] or jq_data[_legacy_attr_cnt_key(cfg.key)] or 0) or 0
        if cnt > 0 then
            for _, it in ipairs(cfg.attrs or {}) do
                local aid = tonumber(it[1] or 0) or 0
                local val = tonumber(it[2] or 0) or 0
                if aid > 0 and val ~= 0 then
                    attrs[aid] = (attrs[aid] or 0) + val * cnt
                end
            end
        end
    end
    local attrsstr = Player.getAttrTableToStr(attrs)
    if attrsstr and attrsstr ~= "" then
        jq_data[_attr_cache_key] = attrsstr
    else
        jq_data[_attr_cache_key] = nil
    end
    jq_data[_legacy_attr_cache_key] = nil
end

local function _grant_submit_attr(play, jq_data)
    if #_submit_attr_pool <= 0 then
        return
    end
    local pick = _submit_attr_pool[math.random(1, #_submit_attr_pool)]
    local key = _attr_cnt_key(pick.key)
    local legacy_key = _legacy_attr_cnt_key(pick.key)
    jq_data[key] = (tonumber(jq_data[key] or jq_data[legacy_key] or 0) or 0) + 1
    jq_data[legacy_key] = nil
    Player.sendmsgEx(play, "本次获得属性：|【"..pick.tip.."】#249|")
end

function npc.main(play,npcid)
    if not _config then
        return
    end
    local data = {}
    data["T_dljq"] = Player.getJsonTableByVar(play, VarCfg.T_dljq)
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
    local max_num = tonumber(_task_cfg.max_submit_times or 4) or 4
    local prog_key = _cfg_key .. "_a"
    local state = tonumber(jq_data[_cfg_key] or 0) or 0
    local cnt = tonumber(jq_data[prog_key] or 0) or 0
    if state >= 2 then
        Player.sendmsgEx(play, "你已经完成#57|【"..(_config.name or "该任务").."】#249|")
        return
    end

    if state < 1 then
        jq_data[_cfg_key] = 1
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
    end

    local req_map = _task_cfg.map or "红尘大陆"
    local cur_map = getbaseinfo(play,3)
    if cur_map ~= req_map and cur_map ~= "xtc" and not (req_map == "红尘大陆" and cur_map == "生命边界") then
        Player.sendmsgEx(play, "请前往#57|【"..req_map.."】#249|完成后再提交#57")
        return
    end

    local costs = _task_cfg.submit
    if not Guard.ensureCost(play, costs) then
        return
    end
    Guard.consumeCost(play, costs, ","..(_config.name or "剧情任务"))

    cnt = cnt + 1
    jq_data[prog_key] = cnt

    _grant_submit_attr(play, jq_data)
    _rebuild_attr_cache(jq_data)
    Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)

    Player.del_attlist(play, _attr_list_name)
    Login_jq_691(play)

    Player.sendmsgEx(play, string.format("提交进度：#57|【%d/%d】#249|", cnt, max_num))

    local submitRewards = _task_cfg.submit_rewards
    if type(submitRewards) == "table" and #submitRewards > 0 then
        local pick = submitRewards[math.random(1, #submitRewards)]
        if type(pick) == "table" and #pick > 0 and type(pick[1]) == "table" then
            Player.rwjl(play, pick, (_config.name or "剧情任务").."阶段奖励", 1)
        end
    end

    if cnt >= max_num then
        jq_data[prog_key] = nil
        jq_data[_cfg_key] = 2
        Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
        Player.sendmsgEx(play, "|【"..(_config.name or "任务").."】#249|完成#57")
        sendluamsg(play,101,1005,0,0,"rwwc")

        Guard.giveTaskReward(play, _config, (_config.name or "剧情任务").."奖励")
    end

    sendluamsg(play,100,npcid,1,cnt,"")
end

function Login_jq_691(play)
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local attrsstr = jq_data[_attr_cache_key] or jq_data[_legacy_attr_cache_key]
    Player.del_attlist(play, _attr_list_name)
    if attrsstr and attrsstr ~= "" then
        Player.addattlist(play, _attr_list_name, "=", attrsstr, 1)
    end
end
GameEvent.add(EventCfg.onLogin, Login_jq_691, "Login_重启世界")

return npc



