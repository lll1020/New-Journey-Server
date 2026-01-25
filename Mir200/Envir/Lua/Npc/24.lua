npc = {}


--天书

local _config = Guard.getConfig("npc_24")

function npc.main(play,npcid)
    local data = {}
    data["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_天书"])
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
    local __guardAllowedActions = Guard.newActionSet({1, 2})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end

    local T_data = Player.getJsonTableByVar(play, VarCfg["T_天书"])
    local json_data = json2tbl(data)
    if ew == 1 then -- 强化
        local itemobj = linkbodyitem(play, _config.where)
        if itemobj then
            T_data.level = (T_data.level or 0) + 1
            if T_data.level > _config.details[1].max_level then
                Player.sendmsgEx(play, "天书已经达到最高等级，无需再强化#57")
                return
            end
            local config = _config.details[1].details[T_data.level]
            -- release_print("天书强化配置:", T_data.level)
            -- release_print("天书强化配置:", tbl2json(config))
            if (T_data.jf or 0) < config.jf then
                Player.sendmsgEx(play, "你的天书杀意值不足，无法进行强化#57")
                return
            end
            Player.sendmsgEx(play, "恭喜你，天书强化成功，当前天书等级为|"..T_data.level.."级#249|")
            Player.setJsonVarByTable(play, VarCfg["T_天书"], T_data)

            local tbl = {
                ["open"] = 1,
                ["show"] = 2,
                ["name"] = string.format("天书等级：%d级", T_data.level),
                ["color"] = 223,
                ["imgcount"] = 1,
                --["cur"] = 1,
                --["max"] = 1,
                --["level"] = 1,
            }
            setcustomitemprogressbar(play, itemobj, 0, tbl2json(tbl))
            tbl = {
                ["open"] = 1,
                ["show"] = 2,
                ["name"] = "杀意值",
                ["color"] = 249,
                ["imgcount"] = 1,
                ["cur"] = (T_data.jf or 0),
                ["max"] = _config.details[1].details[T_data.level + 1] and _config.details[1].details[T_data.level + 1].jf or _config.details[1].details[T_data.level].jf,
                ["level"] = T_data.level,
            }
            setcustomitemprogressbar(play, itemobj, 1, tbl2json(tbl))
            --强化属性
            local attrs = {}
            local attrsstr = ""
            for k,v in ipairs(config.attr) do
                attrs[v[1]] = v[2]
            end
            attrsstr = Player.getAttrTableToStr(attrs)
            setaddnewabil(play, -2, "=",attrsstr, itemobj)
            refreshitem(play, itemobj)
            recalcabilitys(play)


            sendluamsg(play,100,npcid,1,0,tbl2json({ ["T_data"] = T_data} ))
        else
            Player.sendmsgEx(play, "请先穿戴对应部位的装备#249")
            return
        end
    elseif ew == 2 then --仙法
        if json_data["caowei"] and json_data["caowei"] <= 10 then
            local randomNum = ransjstr(_config.details[2].weight, 1, 3)
            randomNum = tonumber(randomNum)

            local idx = math.random(1,#_config.details[2].details[randomNum])
            T_data["caowei"] = T_data["caowei"] or {}
            if T_data["caowei"][""..json_data["caowei"]] then
                xianfa_del(play,T_data["caowei"][""..json_data["caowei"]][1],T_data["caowei"][""..json_data["caowei"]][2])
            end
            T_data["caowei"][""..json_data["caowei"]] = {randomNum,idx}
            T_data["tj"] = T_data["tj"] or {}
            T_data["tj"][randomNum.."_"..idx] = 1
            Player.setJsonVarByTable(play, VarCfg["T_天书"], T_data)

            xianfa_add(play,randomNum,idx)
            sendluamsg(play,100,npcid,2,0,tbl2json({ ["T_data"] = T_data} ))
        else
        end
    end
end

function npc.wangshi(play,idx,data)
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_天书"])
    T_data.wangshi = T_data.wangshi or {}
    if T_data.wangshi[""..idx] then
        -- Player.sendmsgEx(play, "你已经记录过该往事#57")
        return
    end
    T_data.wangshi[""..idx] = data
    Player.setJsonVarByTable(play, VarCfg["T_天书"], T_data)
end


function xianfa_del(actor, group ,idx)
    --TODO 删除仙法属性

end
function xianfa_add(actor, group ,idx)
    --TODO 添加仙法属性

end

local function _onTakeOnEx(actor, itemobj, where, itemname, makeid)
    if where == _config.where then
        local T_data = Player.getJsonTableByVar(actor, VarCfg["T_天书"])
        local tbl = {
            ["open"] = 1,
            ["show"] = 2,
            ["name"] = string.format("天书等级：%d级", T_data.level or 0),
            ["color"] = 223,
            ["imgcount"] = 1,
            --["cur"] = 1,
            --["max"] = 1,
            --["level"] = 1,
        }
        setcustomitemprogressbar(actor, itemobj, 0, tbl2json(tbl))
        tbl = {
            ["open"] = 1,
            ["show"] = 2,
            ["name"] = "杀意值",
            ["color"] = 249,
            ["imgcount"] = 1,
            ["cur"] = (T_data.jf or 0),
            ["max"] = _config.details[1].details[(T_data.level or 0) + 1] and _config.details[1].details[(T_data.level or 0) + 1].jf or _config.details[1].details[(T_data.level or 0)].jf,
            ["level"] = T_data.level or 0,
        }
        setcustomitemprogressbar(actor, itemobj, 1, tbl2json(tbl))
        refreshitem(actor, itemobj)
    end
end
--穿装备触发
GameEvent.add(EventCfg.onTakeOnEx, _onTakeOnEx, "天书初始化")

return npc