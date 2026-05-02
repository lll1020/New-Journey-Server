npc = {}
--npc名称：
--npc功能：
local _config = Guard.getConfig("npc_13")
local _reward_flag_key = "N$兰姐好感度奖励已发"
-- 计算当前好感度百分比，默认按最大等级线性换算。
local function _get_goodwill_percent(level)
    level = tonumber(level or 0) or 0
    local max_level = tonumber(_config and _config.max_level or 0) or 0
    local reward_percent = tonumber(_config and _config.reward_percent or 100) or 100
    if max_level <= 0 or reward_percent <= 0 then
        return 0
    end
    if level >= max_level then
        return reward_percent
    end
    return math.floor((level / max_level) * reward_percent)
end
-- 百分比满时补发一次最终奖励，避免重复领取。
local function _try_grant_final_reward(play)
    local reward_name = tostring((_config and _config.final_give) or (_config and _config.half_give) or "")
    if reward_name == "" then
        return
    end
    if (tonumber(getplaydef(play, _reward_flag_key) or 0) or 0) >= 1 then
        return
    end
    if getbagitemcount(play, reward_name) >= 1 or Player.hasEquipInArtifactSlot(play, reward_name) then
        setplaydef(play, _reward_flag_key, 1)
        return
    end
    local cur_level = tonumber(getplaydef(play, VarCfg["U_兰姐好感度"]) or 0) or 0
    if _get_goodwill_percent(cur_level) < (tonumber(_config and _config.reward_percent or 100) or 100) then
        return
    end
    Player.rwjl(play, {{reward_name, 1}}, "兰姐好感度", 1)
    setplaydef(play, _reward_flag_key, 1)
end
function npc.main(play,npcid)
    _try_grant_final_reward(play)
    local data = {}
    local level = tonumber(getplaydef(play, VarCfg["U_兰姐好感度"]) or 0) or 0
    data["dj_num"] = level
    data["percent"] = _get_goodwill_percent(level)
    sendluamsg(play,100,npcid,0,0,tbl2json(data))
end
function npc.link(play, npcid, p2, p3, msgData)
    -- npc_guard: 入参校验
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local __guardAction = Guard.normalizeAction(play, npcid, p2)
    if __guardAction == nil then
        return
    end
    p2 = __guardAction
    -- npc_guard: 操作白名单（优化：限定合法操作编号）
    local __guardAllowedActions = Guard.newActionSet({1, 2})
    if not Guard.ensureActionAllowed(play, npcid, p2, __guardAllowedActions) then
        return
    end
    if p2 == 1 then
        local dj_data = getplaydef(play, VarCfg["U_兰姐好感度"])
        if dj_data >= _config.max_level then
            Player.sendmsgEx(play,  "好感度已达到#57|【".._get_goodwill_percent(dj_data).."%】#249|，无需继续提升#57")
            return
        end
        dj_data = dj_data + 1
        local config = _config.config[dj_data]
        local name, num = Player.checkItemNumByTable(play, config.cost)
        if name then
            Player.sendmsgEx(play, string.format("你的#57|【%s】#249|不足：#57|【%d】#249|", name, num))
            return
        end
        Player.takeItemByTable(play, config.cost, ",兰姐好感度",nil)
        if FProbabilityHit(config.gl) then
            Player.sendmsgEx(play,  "很遗憾，好感度提升失败，请继续努力#57")
            return
        end
        setplaydef(play, VarCfg["U_兰姐好感度"], dj_data)
        Player.del_attlist(play, "兰姐好感度")
        Player.add_attlist(play, "兰姐好感度", "=", "3#".._config.attrID.."#".._config.config[dj_data].ratio, 1)
        local percent = _get_goodwill_percent(dj_data)
        sendluamsg(play,100,npcid,1,0,tbl2json({dj_num = dj_data, percent = percent}))
        _try_grant_final_reward(play)
        if getplaydef(play, VarCfg.U_zxrw[1]) == 7 then
            Player.zxrw_wancheng(play, 7, "兰姐")
            sendluamsg(play, 101, 9999, 0, 0, "npc_"..npcid)
        end
        if dj_data == _config.max_level then
            Player.sendmsgEx(play, "恭喜你，你的好感度已提升至|【"..percent.."%】#249|，并获得最终奖励")
        else
            Player.sendmsgEx(play, "恭喜你，你的好感度已提升至|【"..percent.."%】#249|")
        end
    elseif p2 == 2 then
    end
end
return npc
