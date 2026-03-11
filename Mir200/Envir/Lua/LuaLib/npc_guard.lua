-- npc_guard.lua
-- NPC脚本公用的安全辅助库，集中处理参数校验与异常记录。
local Guard = {}

-- JSON长度默认上限，避免被超长数据刷爆内存。
local DEFAULT_MAX_JSON = 2048

-- 优先取玩家名字，用于日志输出时定位角色。
local function safePlayerName(play)
    if Player and Player.getname then
        local ok, res = pcall(Player.getname, play)
        if ok and res then
            return res
        end
    end
    return "unknown"
end

-- 统一的日志入口，便于排查。
local function log(msg)
    if release_print then
        release_print("[NpcGuard] " .. msg)
    end
end

-- 记录异常行为，便于后台查询。
function Guard.logSuspicious(play, npcId, detail)
    local playerName = safePlayerName(play)
    log(string.format("npc=%s player=%s detail=%s", tostring(npcId), playerName, detail or ""))
end

-- 基础的玩家句柄校验，防止 nil 透传。
function Guard.ensurePlayer(play, npcId)
    if play ~= nil then
        return true
    end
    Guard.logSuspicious(nil, npcId, "missing player handle")
    return false
end

-- 读取 NPC 配置，若缺失则返回空表避免脚本报错。
function Guard.getConfig(configKey)
    local cfgTable = (teshudata or {})[configKey]
    if type(cfgTable) ~= "table" then
        Guard.logSuspicious(nil, configKey, "config missing")
        return {
            id = configKey,
            config = {},
        }
    end
    cfgTable.config = cfgTable.config or {}
    return cfgTable
end

-- 校验分步骤配置，提示玩家当前功能不可用。
function Guard.requireStepConfig(container, idx, play, npcId)
    if type(container) ~= "table" then
        Guard.logSuspicious(play, npcId, "step container missing")
        Player.sendmsgEx(play, "数据不完整, 请返回.#57")
        return nil
    end
    local cfg = container[idx]
    if not cfg then
        Guard.logSuspicious(play, npcId, "step config missing: " .. tostring(idx))
        Player.sendmsgEx(play, "当前步骤暂未开放, 请注意公告.#57")
        return nil
    end
    return cfg
end

local function toActionNumber(raw)
    if type(raw) == "number" then
        return raw
    end
    if raw == nil then
        return nil
    end
    local num = tonumber(raw)
    return num
end

-- 构建一个简单的白名单集合，用于动作判断。
function Guard.newActionSet(list)
    local tbl = {}
    for _, action in ipairs(list or {}) do
        tbl[action] = true
    end
    return tbl
end

-- 将外部参数转成数字，不合法则提醒玩家。
function Guard.normalizeAction(play, npcId, rawAction)
    local action = toActionNumber(rawAction)
    if not action then
        Guard.logSuspicious(play, npcId, "action is not numeric")
        Player.sendmsgEx(play, "参数异常, 请重新操作.#57")
        return nil
    end
    return action
end

-- 如果提供了允许列表，则限制操作范围。
function Guard.ensureActionAllowed(play, npcId, action, allowedSet)
    if not allowedSet or allowedSet[action] then
        return true
    end
    Guard.logSuspicious(play, npcId, "illegal action: " .. tostring(action))
    Player.sendmsgEx(play, "操作超出允许范围, 请按流程执行.#57")
    return false
end

-- 统一的材料检测提示。
function Guard.ensureCost(play, cost)
    if not cost or #cost == 0 then
        return true
    end
    local name, num = Player.checkItemNumByTable(play, cost)
    if name then
        Player.sendmsgEx(play, string.format("缺少|%s#249|数量|%d#249", name, num))
        return false
    end
    return true
end

-- 扣除材料时统一入口，方便附加说明。
function Guard.consumeCost(play, cost, reason)
    if not cost or #cost == 0 then
        return
    end
    Player.takeItemByTable(play, cost, reason or ",npc_guard", nil)
end

-- 任务完成后清理临时字段（如 key_a/key_b/key_c）。
-- stateVal 可选：传入后会同步写回主状态（例如 2=完成）。
function Guard.clearTaskTemp(tbl, key, stateVal)
    if type(tbl) ~= "table" then
        return
    end
    if type(key) ~= "string" or key == "" then
        return
    end
    local prefix = key .. "_"
    for k, _ in pairs(tbl) do
        if type(k) == "string" and string.sub(k, 1, #prefix) == prefix then
            tbl[k] = nil
        end
    end
    if stateVal ~= nil then
        tbl[key] = stateVal
    end
end

-- 统一任务奖励发放：支持单称号/多称号，支持单组奖励/多组奖励。
function Guard.giveTaskReward(play, config, rewardReason)
    if type(config) ~= "table" then
        return
    end
    local reason = rewardReason or ((config.name or "剧情任务") .. "奖励")
    local taskCfg = type(config.task_cfg) == "table" and config.task_cfg or {}

    local titleSet = {}
    local function collectTitle(src)
        if type(src) == "string" and src ~= "" then
            titleSet[src] = true
            return
        end
        if type(src) == "table" then
            for _, t in ipairs(src) do
                if type(t) == "string" and t ~= "" then
                    titleSet[t] = true
                end
            end
        end
    end

    collectTitle(config.ch)
    collectTitle(config.chs)
    collectTitle(taskCfg.ch)
    collectTitle(taskCfg.chs)

    for t, _ in pairs(titleSet) do
        Player.title_give(play, t)
    end

    local reward = config.jl or config.rwjl or taskCfg.jl or taskCfg.rwjl or taskCfg.reward or taskCfg.rewards
    if type(reward) ~= "table" or #reward == 0 then
        return
    end

    if type(reward[1]) == "table" and type(reward[1][1]) == "string" then
        Player.rwjl(play, reward, reason, 1)
        return
    end

    if type(reward[1]) == "table" and type(reward[1][1]) == "table" then
        for _, pack in ipairs(reward) do
            if type(pack) == "table" and #pack > 0 then
                Player.rwjl(play, pack, reason, 1)
            end
        end
    end
end
-- JSON 解码增加长度限制与异常提示，防止卡死。
function Guard.safeJsonDecode(play, raw, maxLength, fallback)
    fallback = fallback or {}
    if raw == nil then
        return fallback
    end
    if type(raw) ~= "string" then
        Guard.logSuspicious(play, 0, "json raw data not string")
        Player.sendmsgEx(play, "数据格式不正确.#57")
        return fallback
    end
    local limit = maxLength or DEFAULT_MAX_JSON
    if #raw > limit then
        Guard.logSuspicious(play, 0, "json too long: " .. #raw)
        Player.sendmsgEx(play, "数据过长, 已被系统拒绝.#57")
        return fallback
    end
    local ok, data = pcall(json2tbl, raw)
    if not ok then
        Guard.logSuspicious(play, 0, "json decode failed")
        Player.sendmsgEx(play, "数据解析失败, 请稍后重试.#57")
        return fallback
    end
    return data
end

_G.Guard = Guard

return Guard
