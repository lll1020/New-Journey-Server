npc = {}

--境界提升

local _config = Guard.getConfig("npc_21")
local FairyFate = include("lua/LuaLib/fairy_fate.lua")

local function _get_jz_dan_count(play)
    local rec = json2tbl(getplaydef(play, VarCfg["T_物品使用记录"]))
    if type(rec) ~= "table" then
        rec = {}
    end
    return tonumber(rec.jz_dan_count or 0) or 0
end

local function _build_sync_data(play)
    local data = {}
    local jz_count = _get_jz_dan_count(play)
    --{等级,经验}
    data["level"] = getplaydef(play, VarCfg["U_境界修炼"][1])
    data["exp"] = getplaydef(play, VarCfg["U_境界修炼"][2])
    data["jz_dan_count"] = jz_count
    data["jz_dan_ready"] = jz_count >= 1 and 1 or 0
    data["jz_dan_text"] = jz_count >= 1 and "已服用" or "未服用"
    data["jz_dan_color"] = jz_count >= 1 and 250 or 249
    return data
end

local function _send_sync_data(play, npcid, p2)
    sendluamsg(play,100,npcid,p2 or 0,0,tbl2json(_build_sync_data(play)))
end
local function _get_bag_item_make_id(play, itemName)
    local list = getbagitems(play, itemName)
    if type(list) == "table" then
        for _, itemObj in ipairs(list) do
            if itemObj and itemObj ~= "0" and tostring(getiteminfo(play, itemObj, 7) or "") == itemName then
                return getiteminfo(play, itemObj, 1)
            end
        end
    end
    local item_num = tonumber(getbaseinfo(play, 34) or 0) or 0
    for i = 0, item_num - 1 do
        local itemObj = getiteminfobyindex(play, i)
        if itemObj and itemObj ~= "0" and tostring(getiteminfo(play, itemObj, 7) or "") == itemName then
            return getiteminfo(play, itemObj, 1)
        end
    end
    return nil
end

local function _guide_bag_item(play, makeId, msg)
    sendluamsg(play, 101, 2, 8, 0, "")
    navigation(play, 1, makeId, msg)
end
local function _guide_foundation_dan(play)
    local danMakeId = _get_bag_item_make_id(play, "筑基丹")
    if danMakeId then
        _guide_bag_item(play, danMakeId, "使用筑基丹后再提升境界")
        return
    end
    if (tonumber(getbagitemcount(play, "筑基丹碎片") or 0) or 0) >= 10 then
        local fragMakeId = _get_bag_item_make_id(play, "筑基丹碎片")
        if fragMakeId then
            _guide_bag_item(play, fragMakeId, "使用筑基丹碎片合成筑基丹")
            return
        end
    end
    sendluamsg(play, 100, 21, 2, 0, "")
end

local function _guide_cultivation_pill(play)
    local bigMakeId = _get_bag_item_make_id(play, "修为丹（大）")
    if bigMakeId then
        _guide_bag_item(play, bigMakeId, "使用修为丹（大）增加修为")
        return true
    end
    local smallMakeId = _get_bag_item_make_id(play, "修为丹（小）")
    if smallMakeId then
        _guide_bag_item(play, smallMakeId, "使用修为丹（小）增加修为")
        return true
    end
    return false
end
function npc.main(play,npcid)
    _send_sync_data(play, npcid, 0)
    openhyperlink(play, 1, 2)
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
    local __guardAllowedActions = Guard.newActionSet({1, 2})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end

    if ew == 2 then
        sendluamsg(play, 101, 502, 8, 30, getplaydef(play, VarCfg.T_czlb))
        return
    end

    if ew == 1 then
        local level = getplaydef(play, VarCfg["U_境界修炼"][1])
        local exp = getplaydef(play, VarCfg["U_境界修炼"][2])
        if level >= _config.max_level then
            Player.sendmsgEx(play,  "你的境界已达到#57|【".._config.details[level].title.."级】#218|，无需再提升#57")
            return
        end
        level = level + 1

        local config = _config.details[level]
        if not config then
            Player.sendmsgEx(play, "配置异常，请联系管理员#57")
            return
        end

        if exp >= config.need_xxz then
            if level == 10 and _get_jz_dan_count(play) < 1 then
                Player.sendmsgEx(play, "你的#57|【筑基丹】#218|不足，需要服用#57|【1颗筑基丹】#218|后方可突破")
                _guide_foundation_dan(play)
                return
            end
            local name, num = Player.checkItemNumByTable(play, config.cost)
            if name then
                Player.sendmsgEx(play, string.format("你的#57|【%s】#218|不足：#57|【%d】#218|", name, num))
                return
            end
            Player.takeItemByTable(play, config.cost, ",境界提升",nil)

            if FProbabilityHit(config.gl) then
                Player.sendmsgEx(play,  "很遗憾，境界提升失败，请继续努力#57")
                return
            end

            setplaydef(play, VarCfg["U_境界修炼"][1], level)
            -- 二大陆伏妖录：境界突破成功后立即尝试自动结算当前任务。
            Player.trySyncSecondContinentXyl(play)
            if zxrw_try_finish_current_mainline then zxrw_try_finish_current_mainline(play, "任务") end
            Player.sendmsgEx(play,  "恭喜你，境界提升成功，当前境界等级为|【".._config.details[level].title.."级】#218|")
            if FairyFate and FairyFate.touch then FairyFate.touch(play, "realm_up") end
            Player.del_attlist(play, "境界修为")
            Login_jjxw(play)
            if TianshuWangshiTryRecordProgress then TianshuWangshiTryRecordProgress(play) end
            if level == 10 then
                -- 兼容未配置主线映射的场景，避免完成境界时直接索引空表报错。
                if rwcf and rwcf[npcid] then
                    Player.zxrw_wancheng(play, rwcf[npcid][1], "任务") --完成任务
                end
                sendluamsg(play, 101, 9999, 0, 0, "npc_"..npcid)
            end

            sendluamsg(play,101,1005,0,0,"tpcg")
            _send_sync_data(play, npcid, 1)
        else
            Player.sendmsgEx(play,  "你的修为不足，无法提升境界#57")
            _guide_cultivation_pill(play)
            return
        end
    end
end

function Login_jjxw(play)
    local attrs = {}
    local attrsstr = ""
    local level = getplaydef(play, VarCfg["U_境界修炼"][1])
    if level <= 0 then
        return
    end
    local config = _config.details[level]
    if not config then
        return
    end
    for v,k in ipairs(config.attr) do
        attrs[k[1]] = k[2]
    end
    attrsstr = Player.getAttrTableToStr(attrs)
    Player.add_attlist(play, "境界修为", "=", attrsstr, 1)
end
GameEvent.add(EventCfg.onLogin, Login_jjxw, "Login_jjxw")

return npc

