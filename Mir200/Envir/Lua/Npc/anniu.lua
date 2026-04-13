npc = {}
local _fashionConfig1002 = Guard.getConfig("npc_1002")
local _linggenConfig22 = Guard.getConfig("npc_22")
local FairyFate = include("lua/LuaLib/fairy_fate.lua")
local _fashionAttrListName = "时装属性"
local function _refreshFashionAttr(play, T_data)
    T_data = T_data or Player.getJsonTableByVar(play, VarCfg.T_szjl)
    T_data.yjs = T_data.yjs or {}
    local attrs = {}
    for idx, cfg in ipairs(((_fashionConfig1002 and _fashionConfig1002.details and _fashionConfig1002.details.sz) or {})) do
        if T_data.yjs[tostring(idx)] == 1 then
            for _, attr in ipairs(cfg.attr or {}) do
                local attrId = tonumber(attr[1])
                local attrValue = tonumber(attr[2]) or 0
                if attrId and attrValue > 0 then
                    attrs[attrId] = (attrs[attrId] or 0) + attrValue
                end
            end
        end
    end
    local attrsstr = Player.getAttrTableToStr(attrs)
    if attrsstr and attrsstr ~= "" then
        Player.add_attlist(play, _fashionAttrListName, "=", attrsstr, 1)
    else
        Player.del_attlist(play, _fashionAttrListName)
    end
end
npc[2] = function(play, p2, p3, msgData) --背包  面板
    if p2 == 0 then
        -- 回收面板
        sendluamsg(play, 101, 2, 2, 0, '{"xz":' .. getplaydef(play, VarCfg.T_hsdg) .. ',"kg":[' .. getflagstatus(play, VarCfg.BS_huishou[1]) .. "," .. getflagstatus(play, VarCfg.BS_huishou[2]) .. "," .. getflagstatus(play, VarCfg.BS_huishou[3]) .. "," .. getflagstatus(play, VarCfg.BS_huishou[4]) .. "," .. getflagstatus(play, VarCfg.BS_huishou[5]) .. "]}")
    elseif p2 == 1 then
        if p3 > 0 and p2 < 5 then
            msgData = tonumber(msgData)
            if msgData > 0 and msgData < 50 then
                local hspz = json2tbl(getplaydef(play, VarCfg.T_hsdg))
                hspz[p3 .. "_" .. msgData] = 1
                setplaydef(play, VarCfg.T_hsdg, tbl2json(hspz))
            end
        end
    elseif p2 == 2 then
        local hspz = json2tbl(getplaydef(play, VarCfg.T_hsdg))
        if hspz[msgData] and hspz[msgData] == 1 then
            hspz[msgData] = nil
        else
            hspz[msgData] = 1
        end
        setplaydef(play, VarCfg.T_hsdg, tbl2json(hspz))
    elseif p2 == 3 then
    elseif p2 == 4 then
        if p3 == 1 then
            if msgData == "1" then
                sendmsg(play,1,'{"Msg":"<font color=\'#00ff00\'>自动吃元宝已开启...</font>","Type":9}' )
            else
                sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>自动吃元宝已关闭...</font>","Type":9}' )
            end
            setflagstatus(play, VarCfg.BS_huishou[1], msgData)
        elseif p3 == 2 then
            if msgData == "1" then
                sendmsg(play,1,'{"Msg":"<font color=\'#00ff00\'>自动吃元宝已开启...</font>","Type":9}' )
            else
                sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>自动吃元宝已关闭...</font>","Type":9}' )
            end
            setflagstatus(play, VarCfg.BS_huishou[2], msgData)
        elseif p3 == 3 then
            if msgData == "1" then
                sendmsg(play,1,'{"Msg":"<font color=\'#00ff00\'>自动吃经验已开启...</font>","Type":9}' )
            else
                sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>自动吃经验已关闭...</font>","Type":9}' )
            end
            setflagstatus(play, VarCfg.BS_huishou[3], msgData)
        elseif p3 == 4 then
            if msgData == "1" then
                sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>自动回收已开启...</font>","Type":9}')
            else
                sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>自动回收已关闭...</font>","Type":9}')
            end
            setflagstatus(play, VarCfg.BS_huishou[4], msgData)
        elseif p3 == 5 then
            if msgData == "1" then
                sendmsg(play,1,'{"Msg":"<font color=\'#00ff00\'>可提升不回收已开启...</font>","Type":9}' )
            else
                sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>可提升不回收已关闭...</font>","Type":9}' )
            end
            setflagstatus(play, VarCfg.BS_huishou[5], msgData)
        end
    elseif p2 == 5 then
        if p3 == 1 then
            local hs = json2tbl(msgData)
            Player.huishou(play, hs)
        end
        
        if 10 == getplaydef(play,VarCfg.U_zxrw[1]) then 
            Player.zxrw_wancheng(play, 10, "")
            sendluamsg(play, 101, 9999, 0, 0, "npc_huishou")
            openhyperlink(play, 7, 2)
        end
    elseif p2 == 6 then --销毁
        local hs = json2tbl(msgData)
        Player.huishou(play, hs)
        sendluamsg(play, 101, 2, 4, 0, "")
    elseif p2 == 7 then
        Player.huishou(play)
        refreshbag(play)
    elseif p2 == 999 then --销毁 单个
        if type(p3) ~= "number" then
            Player.sendmsgEx(play, "参数错误!#57")
            return
        end
        local itemName = Item.getNameMakeid(play, p3)
        local isSuccess = delitembymakeindex(play, tostring(p3), 0, "物品销毁")
        if not isSuccess then
            Player.sendmsgEx(play, "物品销毁失败,请检查!#57")
        else
            if itemName then
                Player.sendmsgEx(play, "|【"..itemName.."】#249|物品销毁成功!")
            end
        end
    elseif p2 == 998 then --屏蔽全服掉落信息
        local state = getflagstatus(play, VarCfg["F_过滤全服信息"])
        if state == 0 then
            filterglobalmsg(play, 1)
            setflagstatus(play, VarCfg["F_过滤全服信息"], 1)
            Player.sendmsgEx(play, "开启过滤全服掉落提示信息。")
        else
            filterglobalmsg(play, 0)
            setflagstatus(play, VarCfg["F_过滤全服信息"], 0)
            Player.sendmsgEx(play, "关闭过滤全服掉落提示信息。")
        end
    end
end
npc[3] = function(play) --仓库面板
    openstorage(play)
end
npc[5] = function(play, p2, p3, data) -- 内挂开关
    setflagstatus(play, VarCfg.BS_ngkg, p2)
    Buff[70](play, p2 == 1 and 1 or 2)
    sendluamsg(play, 103, 1, 0, 0, '{"ngkg":' .. p2 .. "}")
end
npc[6] = function(play, p2, p3, data) -- 屏蔽系统消息
    if getplaydef(play, "N$是否屏蔽系统消息") == 0 then
        setplaydef(play, "N$是否屏蔽系统消息", 1)
        filterglobalmsg(play, 1)
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>不在接受系统提示消息...</font>","Type":9}')
    else
        setplaydef(play, "N$是否屏蔽系统消息", 0)
        filterglobalmsg(play, 0)
        sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>正常接收系统消息...</font>","Type":9}')
    end
end
---异闻录
local npc_xyl = dofile('Envir/Lua/Data/npc_xyl.lua')
local daluditu = dofile('Envir/Lua/Data/daluditu.lua')
-- 
local function _ywl_activate_linggen(play, idx)
    local data = Player.getJsonTableByVar(play, VarCfg["T_灵根"])
    data.level = data.level or {}
    local key = tostring(idx)
    if data.level[key] then
        return true
    end
    data.level[key] = 0
    Player.setJsonVarByTable(play, VarCfg["T_灵根"], data)
    local baseRatio = tonumber(_linggenConfig22 and _linggenConfig22.base_ratio or 0.4) or 0.4
    local rootCfg = _linggenConfig22 and _linggenConfig22.main_r and _linggenConfig22.main_r[idx]
    local addAttrs = {}
    for _, one in ipairs(rootCfg and rootCfg.attr or {}) do
        addAttrs[#addAttrs + 1] = {one[1], math.max(1, math.floor((tonumber(one[2]) or 0) * baseRatio + 0.5))}
    end
    if #addAttrs > 0 then
        Player.updateSomeAddr(play, nil, addAttrs)
    end
    -- 按 602 的激活逻辑，这里只做激活与提示，不走副本流程
    Player.sendmsgEx(play, "恭喜你，成功激活|【灵根】#249|")
    return true
end
local function _ywl_apply_special_reward(play, name, count)
    if name == "激活金灵根" then
        return _ywl_activate_linggen(play, 1)
    elseif name == "激活木灵根" then
        return _ywl_activate_linggen(play, 2)
    elseif name == "激活水灵根" then
        return _ywl_activate_linggen(play, 3)
    elseif name == "激活火灵根" then
        return _ywl_activate_linggen(play, 4)
    elseif name == "激活土灵根" then
        return _ywl_activate_linggen(play, 5)
    end
    return false
end
local function _ywl_filter_rewards(play, list)
    if type(list) ~= "table" then
        return list
    end
    local out = {}
    for _, v in ipairs(list) do
        if type(v) == "table" and type(v[1]) == "string" then
            if not _ywl_apply_special_reward(play, v[1], v[2]) then
                out[#out + 1] = v
            end
        else
            out[#out + 1] = v
        end
    end
    return out
end
--功能:检查章节是否解锁（仅校验剧情点）
local function _ywl_is_chapter_open(play, i, j)
    if not i or not j or i <= 0 or j <= 0 then
        return false
    end
    if not npc_xyl[i] or not npc_xyl[i][j] then
        return false
    end
    local need_jqd = tonumber(npc_xyl[i][j].jqd) or 0
    if need_jqd <= 0 then
        return true
    end
    local cur_jqd = querymoney(play, getstditeminfo("剧情点", 0))
    return cur_jqd >= need_jqd
end
local function _ywl_get_target_dl(sj, shuju)
    if type(shuju) == "table" and type(shuju.yd) == "table" then
        local target_map = shuju.yd[2]
        local dl = target_map and daluditu[target_map] or nil
        if dl and dl > 0 then
            return dl
        end
    end
    return tonumber(sj and sj.i) or 0
end
local _ywl_map_gate = {
    ["虚妄山脉"] = {mode = "ge", key = "npc_621", value = 2, tip = "踏入·虚妄山脉"},
    ["鬼嘲深渊"] = {mode = "ge", key = "npc_623", value = 2, tip = "踏入·鬼嘲深渊"},
    ["叹息旷野"] = {mode = "ge", key = "npc_622", value = 2, tip = "踏入·叹息旷野"},
    ["禁忌之海"] = {mode = "ge", key = "npc_624", value = 2, tip = "踏入·禁忌之海"},
    ["船长室"] = {mode = "eq", key = "npc_629_a", value = 1, tip = "沉船之谜·船长室提交"},
    ["水手舱"] = {mode = "eq", key = "npc_629_b", value = 1, tip = "沉船之谜·水手舱提交"},
    ["黄泉路"] = {mode = "ge", key = "npc_667", value = 2, tip = "买路钱"},
    ["罗酆六天"] = {mode = "ge", key = "npc_669", value = 2, tip = "忘却前生情"},
    ["东海龙宫"] = {mode = "ge", key = "npc_642", value = 2, tip = "资格考验"},
    ["黑风山"] = {mode = "ge", key = "npc_643", value = 2, tip = "龙王的噩梦"},
    ["黄风岭"] = {mode = "ge", key = "npc_644", value = 2, tip = "我的袈裟！"},
    ["女儿国"] = {mode = "ge", key = "npc_645", value = 2, tip = "黄风大圣"},
    ["通天河"] = {mode = "ge", key = "npc_646", value = 2, tip = "你竟是女王？"},
    ["狮驼岭"] = {mode = "ge", key = "npc_647", value = 2, tip = "驮我过河"},
    ["天竺山"] = {mode = "ge", key = "npc_648", value = 2, tip = "大闹狮驼岭"},
    ["辰龙灵域"] = {mode = "ge", key = "npc_663", value = 2, tip = "灵域使者·一"},
    ["巳蛇灵域"] = {mode = "ge", key = "npc_663", value = 2, tip = "灵域使者·一"},
    ["午马灵域"] = {mode = "ge", key = "npc_663", value = 2, tip = "灵域使者·一"},
    ["未羊灵域"] = {mode = "ge", key = "npc_663", value = 2, tip = "灵域使者·一"},
    ["灵域·二层"] = {mode = "ge", key = "npc_663", value = 2, tip = "灵域使者·一"},
    ["申猴灵域"] = {mode = "ge", key = "npc_664", value = 2, tip = "灵域使者·二"},
    ["酉鸡灵域"] = {mode = "ge", key = "npc_664", value = 2, tip = "灵域使者·二"},
    ["戌狗灵域"] = {mode = "ge", key = "npc_664", value = 2, tip = "灵域使者·二"},
    ["亥猪灵域"] = {mode = "ge", key = "npc_664", value = 2, tip = "灵域使者·二"},
    ["灵域·三层"] = {mode = "ge", key = "npc_664", value = 2, tip = "灵域使者·二"},
    ["灵域·秘境"] = {mode = "ge", key = "npc_665", value = 2, tip = "灵域使者·三"},
}
local function _ywl_check_map_gate(play, shuju)
    if type(shuju) ~= "table" or type(shuju.yd) ~= "table" then
        return true
    end
    local target_map = shuju.yd[2]
    local cfg = target_map and _ywl_map_gate[target_map] or nil
    if not cfg then
        return true
    end
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    local cur = jq_data[cfg.key]
    local ok = false
    if cfg.mode == "eq" then
        ok = cur == cfg.value
    else
        ok = (tonumber(cur) or 0) >= (cfg.value or 0)
    end
    if ok then
        return true
    end
    Player.sendmsgEx(play, "请先完成#57|【" .. cfg.tip .. "】#249|")
    return false
end
local function _ywl_can_transfer(play, sj, shuju)
    local need_dl = _ywl_get_target_dl(sj, shuju)
    if need_dl > 0 and not Player.dl_sz(play, need_dl) then
        return false
    end
    -- 三大陆相关异闻录功能必须在玩家真正完成【灾厄入侵】并实际进入三大陆后才能使用。
    -- 仅保留仙府、灾厄主线入口等例外 NPC（44、46、55），避免通过异闻录提前绕进三大陆功能。
    if need_dl == 3 and not Player.hasThirdContinentPass(play) then
        local targetNpc = shuju and shuju.yd and shuju.yd[3] or 0
        if targetNpc ~= 44 and targetNpc ~= 46 and targetNpc ~= 55 then
            Player.sendmsgEx(play, "请先真正完成#57|【灾厄入侵】#249|并进入#57|【三大陆】#249|后再使用该异闻录功能")
            return false
        end
    end
    if not _ywl_check_map_gate(play, shuju) then
        return false
    end
    if shuju.ydtk and shuju.fwdjy and not shuju.fwdjy(play, shuju.ydtk, shuju) then
        local ydtip = shuju.ydtip or "进入地图前置任务"
        Player.sendmsgEx(play, "请先完成#57|【" .. ydtip .. "】#249|")
        return false
    end
    return true
end
local function _ywl_send_current_task(play)
    local T_ywl = json2tbl(getplaydef(play, VarCfg.T_ywl))
    local dq = T_ywl.dq or ""
    sendluamsg(play, 101, 11, 9, 0, '{"dq":"' .. dq .. '"}')
end
local function _ywl_set_current_task(play, sj)
    local T_ywl = json2tbl(getplaydef(play, VarCfg.T_ywl))
    T_ywl.dq = sj.i .. "_" .. sj.j .. "_" .. sj.z
    T_ywl.dq_i = nil
    T_ywl.dq_j = nil
    T_ywl.dq_z = nil
    T_ywl.dq_id = nil
    setplaydef(play, VarCfg.T_ywl, tbl2json(T_ywl))
    _ywl_send_current_task(play)
end
local function _ywl_try_clear_current_task(play, T_ywl, sj)
    T_ywl = T_ywl or json2tbl(getplaydef(play, VarCfg.T_ywl))
    if not sj or not sj.i or not sj.j or not sj.z then
        return T_ywl, false
    end
    local cur = T_ywl.dq or ""
    local taskKey = tostring(sj.i) .. "_" .. tostring(sj.j) .. "_" .. tostring(sj.z)
    if cur == taskKey then
        T_ywl.dq = ""
        T_ywl.dq_i = nil
        T_ywl.dq_j = nil
        T_ywl.dq_z = nil
        T_ywl.dq_id = nil
        return T_ywl, true
    end
    return T_ywl, false
end
npc[11] = function(play, p2, p3, data) --异闻录
    -- sj.i 大陆  sj.j 章节  sj.k 暂时不用  sj.z 剧情
    if p2 == 0 then
        sendluamsg(play, 101, 11, 0, 0, '{"dljq":' .. getplaydef(play, VarCfg.T_dljq) .. ',"zxrw":' .. getplaydef(play, VarCfg.T_zxrw) .. ',"ywl":' .. getplaydef(play, VarCfg.T_ywl) .. "}")
        _ywl_send_current_task(play)
    elseif p2 == 1 then
        --传送
        local sj = json2tbl(data)
        if
            sj.i
            and sj.j
            and sj.z
            and sj.i > 0
            and sj.j > 0
            and sj.z > 0
            and sj.i <= #npc_xyl
            and sj.j <= #npc_xyl[sj.i]
            and sj.z <= #npc_xyl[sj.i][sj.j].jq
        then
            if not _ywl_is_chapter_open(play, sj.i, sj.j) then
                sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>剧情点不足...</font>","Type":9}')
                return
            end
            local shuju = npc_xyl[sj.i][sj.j].jq[sj.z]
            local use_shuju = shuju
            if shuju and shuju.tk == "npc_720" and shuju.yd2 then
                local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
                local state705 = tonumber(jq_data["npc_705"] or 0) or 0
                if state705 >= 2 then
                    use_shuju = {}
                    for k, v in pairs(shuju) do
                        use_shuju[k] = v
                    end
                    use_shuju.yd = shuju.yd2
                end
            end
            if _ywl_can_transfer(play, sj, use_shuju) then
                    local shuju = use_shuju
                local is_transfer_ok = false
                if shuju.yd[1] == 0 then
                    sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>当前剧情未配置传送坐标...</font>","Type":9}')
                elseif shuju.yd[1] == 1 then
                    if getplaydef(play, "N$战斗状态") < os.time() then
                        local targetMap = shuju.yd[2]
                        local targetNpc = shuju.yd[3]
                        local targetX = shuju.yd[4]
                        local targetY = shuju.yd[5]
                        -- 这里不再对未完成三大陆主线的玩家自动兜底传送到灰界，是否可传送统一前置到 _ywl_can_transfer 里拦截。
                        mapmove(play, targetMap, targetX, targetY, 5)
                        sendluamsg(play, 101, 0, 1, 1, '{"lx":2,"npcdt":"' .. targetMap .. '","npcid":' .. targetNpc .. ',"xx":' .. targetX .. ',"yy":' .. targetY .. '}')
                        sendluamsg(play, 101, 9999, 0, 0, "npc_ywl")
                        is_transfer_ok = true
                    else
                        Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0000\'>战斗状态无法使用...</font>","Type":9}')
                    end
                elseif shuju.yd[1] == 2 then
                    sendluamsg(play, 101, 0, 1, 1, '{"lx":1,"fx":1,"an":' .. shuju.yd[3] .. ',"ms":"点击按钮"}')
                    sendluamsg(play, 101, 9999, 0, 0, "npc_ywl")
                    sendluamsg(play, 101, 9999, 0, 0, "npc_ywl")
                    is_transfer_ok = true
                elseif shuju.yd[1] == 3 then
                    sendluamsg(play, 101, 0, 1, 1, '{"lx":' .. shuju.yd[2] .. '}')
                    sendluamsg(play, 101, 9999, 0, 0, "npc_ywl")
                    is_transfer_ok = true
                elseif shuju.yd[1] == 4 then
                    sendluamsg(play, shuju.yd[2], shuju.yd[3], shuju.yd[4], 0, "")
                    sendluamsg(play, 101, 9999, 0, 0, "npc_ywl")
                    is_transfer_ok = true
                end
                if is_transfer_ok then
                    _ywl_set_current_task(play, sj)
                end
            end
        end
    elseif p2 == 2 then --一页任务奖励
        local sj = json2tbl(data)
        if sj.i and sj.j and sj.i > 0 and sj.j > 0 and sj.i <= #npc_xyl and sj.j <= #npc_xyl[sj.i] then
            if not _ywl_is_chapter_open(play, sj.i, sj.j) then
                sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>剧情点不足...</font>","Type":9}')
                return
            end
            local T_ywl = json2tbl(getplaydef(play, VarCfg.T_ywl))
            if T_ywl["jl_" .. sj.i .. "_" .. sj.j] and T_ywl["jl_" .. sj.i .. "_" .. sj.j] == 1 then
                sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>已领取过了...</font>","Type":9}')
                return
            end
            for i = 1, #npc_xyl[sj.i][sj.j].jq do
                if
                    T_ywl["jl_" .. sj.i .. "_" .. sj.j .. "_" .. i]
                    and T_ywl["jl_" .. sj.i .. "_" .. sj.j .. "_" .. i] == 1
                then
                    T_ywl["jl_" .. sj.i .. "_" .. sj.j .. "_" .. i] = nil
                else
                    Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0000\'>未完成[' .. npc_xyl[sj.i][sj.j].jq[i][1] .. ']剧情...</font>","Type":9}')
                    return
                end
            end
            T_ywl["jl_" .. sj.i .. "_" .. sj.j] = 1
            setplaydef(play, VarCfg.T_ywl, tbl2json(T_ywl))
            local _jl = _ywl_filter_rewards(play, npc_xyl[sj.i][sj.j].jl)
            if _jl and #_jl > 0 then
                Player.rwjl(play, _jl, "剧情jl", 1)
            end
            if sj.i == 2 and sj.j == 4 then 
                Player.zxrw_wancheng(play, 23, "任务") --完成任务
                sendluamsg(play, 101, 9999, 0, 0, "npc_ywl")
            else
                sendluamsg(play, 101, 11, 2, 2, tbl2json(sj) )
                _ywl_send_current_task(play)
            end
            
        end
    elseif p2 == 3 then --单个任务奖励
        local sj = json2tbl(data)
        if
            sj.i
            and sj.j
            and sj.z
            and sj.i > 0
            and sj.j > 0
            and sj.z > 0
            and sj.i <= #npc_xyl
            and sj.j <= #npc_xyl[sj.i]
            and sj.z <= #npc_xyl[sj.i][sj.j].jq
        then
            if not _ywl_is_chapter_open(play, sj.i, sj.j) then
                sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>剧情点不足...</font>","Type":9}')
                return
            end
            local shuju = npc_xyl[sj.i][sj.j].jq[sj.z]
            local T_dljq = json2tbl(getplaydef(play, VarCfg.T_dljq))
            local T_ywl = json2tbl(getplaydef(play, VarCfg.T_ywl))
            if
                (T_ywl["jl_" .. sj.i .. "_" .. sj.j] and T_ywl["jl_" .. sj.i .. "_" .. sj.j] == 1)
                or (
                    T_ywl["jl_" .. sj.i .. "_" .. sj.j .. "_" .. sj.z]
                    and T_ywl["jl_" .. sj.i .. "_" .. sj.j .. "_" .. sj.z] == 1
                )
            then
                sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>已完成[' .. shuju[1] .. ']剧情...</font>","Type":9}' )
                return
            end
            if shuju.id == 999 then
                if shuju.fwdjy(play, shuju.tk, shuju) then
                    --可以完成
                    T_ywl["jl_" .. sj.i .. "_" .. sj.j .. "_" .. sj.z] = 1
                    T_ywl = select(1, _ywl_try_clear_current_task(play, T_ywl, sj))
                    setplaydef(play, VarCfg.T_ywl, tbl2json(T_ywl))
                    if shuju.jl then
                        Player.rwjl(play, shuju.jl, "剧情jl", 1,0)
                    end
                    sendluamsg(play, 101, 11, 2, 3, tbl2json(sj) )
                    _ywl_send_current_task(play)
                else
                    Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0000\'>未完成[' .. shuju[1] .. ']剧情...</font>","Type":9}')
                    return
                end
            end
        end
    elseif p2 == 4 then --一整个大陆任务奖励
    end
end
---记忆传送
npc[13] = function(play, p2, p3, data) -- 记录石
    if p2 == 0 then
        -- 当 p3 为 0 时，进行记录石的初始化操作
        -- 向客户端发送消息，请求获取玩家的默认记录石信息
        sendluamsg(play, 101, 13, 1, 0, getplaydef(play, VarCfg.T_jls))
    elseif p2 == 1 then
        -- 当 p3 为 1 时，记录
        local jls = json2tbl(getplaydef(play, VarCfg.T_jls))
        --获取当前玩家坐标和地图
        local xx, yy, dt = getbaseinfo(play, 4), getbaseinfo(play, 5), getbaseinfo(play, 3)
        if string.find(dt, "_") then
            --向客户端发送消息，通知玩家处于副本地图，无法记录
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>副本地图无法记录...</font>","Type":9}')
            return
        elseif checkkuafu(play) or jinzhigj[dt] then
            --向客户端发送消息，通知玩家处于禁止记录的地图，无法记录
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>当前地图无法记录...</font>","Type":9}')
            return
        end
        --将当前玩家的坐标和地图信息存入记录石信息中
        jls["dtm" .. p3] = { p3, dt, xx, yy }
        --将记录石信息存入玩家的数据中
        setplaydef(play, VarCfg.T_jls, tbl2json(jls))
        --向客户端发送消息，通知记录石记录成功
        sendluamsg(play, 101, 13, 2, p3, getplaydef(play, VarCfg.T_jls))
    elseif p2 == 2 then
        -- 当 p2 为 2 时，进行记录石的传送
        local jls = json2tbl(getplaydef(play, VarCfg.T_jls))
        --获取当前玩家的记录石信息
        local jlsinfo = jls["dtm" .. p3]
        --判断记录石信息是否存在
        if jlsinfo then
            --判断当前玩家是否处于战斗状态
            if getplaydef(play, "N$战斗状态") < os.time() then
                --是不是有足够的灵石
                if getbindmoney(play, "灵石") < 100 then
                    Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0500\'>灵石不足,无法传送...</font>","Type":9}')
                    return
                end
                consumebindmoney(play, "仙玉", 100)
                --传送玩家到记录石的位置
                mapmove(play, jlsinfo[2], jlsinfo[3], jlsinfo[4], 2)
                --向客户端发送消息，通知传送成功
                sendluamsg(play, 101, 13, 3, p3, "")
            else
                --向客户端发送消息，通知玩家处于战斗状态，无法传送
                sendmsg(play,1,'{"Msg":"<font color=\'#ff0000\'>战斗状态无法使用...</font>","Type":9}' )
            end
        else
            --向客户端发送消息，通知记录石不存在
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>记录石不存在...</font>","Type":9}')
        end
    end
end
---实力提升
npc[17] = function(play, p2, p3, data) --实力提升
    if p2 == 0 then
        --实力提升  --初始化页面
        sendluamsg(play, 101, 17, 0, 0, "")
    end
end
---新手礼包
npc[18] = function(play, p2, p3, data) --新手礼包
    if p2 == 0 then
        --新手礼包  --初始化页面
        sendluamsg(play, 101, 18, 0, 0, "")
    elseif p2 == 1 then
        --领取礼包
        local rwid = getplaydef(play, VarCfg.U_zxrw[1])
        if rwid == 1 then
            
            Player.rwjl(
                play,
                {{"复活戒指",1},{"麻痹戒指",1},{"斗笠",1},{"攻速之镰[lv1]",1}, {"切割之斧[lv1]",1},{ "盟重回城石", 1 }, { "随机传送石", 1 }, { "龙骨刀", 1 }, { "龙骨甲", 1 },{"酒葫芦",1},},
                "新手礼包",
                nil
            )
            addbuff(play, 20000)
            addbuff(play, 20001)
            addbuff(play, 20002)
            -- 飞剑功能临时下线：关闭新手礼包自动激活飞剑
            -- Npclib["anniu"][19](play, 1, 0, "")
            
            --新手技能
            for _, v in pairs(constant.pz_xrjn) do
                addskill(play,v[1],v[2])
            end
            Player.zxrw_wancheng(play, getplaydef(play, VarCfg.U_zxrw[1]), "新手礼包") --完成任务
            sendluamsg(play, 101, 1005, 0, 0, "lqcg")
            sendluamsg(play, 101, 9999, 0, 0, "npc_xslb")
            sendluamsg(play, 101, 18, 1, 0, "")
        else --已完成
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0500\'>已经领取过礼包了...</font>","Type":9}')
            return
        end
    end
end
function feijian(play, msgData) ---飞剑
    -- 飞剑功能临时下线
    return
end
npc[19] = function(play, p2, p3, data) --飞剑系统
    -- 飞剑功能临时下线
    return
end
npc[23] = function(play, p2, p3, data) --护体光环
    local zs_level = tonumber(getplaydef(play, VarCfg["U_转生等级"]) or 0) or 0
    local sc_data = Player.getJsonTableByVar(play, VarCfg["T_首冲礼包"]) or {}
    local active = tonumber(getplaydef(play, VarCfg["U_护体光环激活"]) or 0) or 0
    local aura = {
        [1] = {open = zs_level >= 10 and 1 or 0},
        [2] = {open = tonumber(sc_data["首充"] or 0) == 1 and 1 or 0},
        [3] = {open = getflagstatus(play, VarCfg.BS_mztq) == 1 and 1 or 0},
    }
    if active < 1 or active > 3 or aura[active].open ~= 1 then
        active = 0
    end
    if p2 == 0 then
        for i = 1, 3 do
            aura[i].active = active == i and 1 or 0
        end
        sendluamsg(play, 101, 23, 0, 0, tbl2json({aura = aura, active = active}))
    elseif p2 == 1 then
        local idx = tonumber(data) or tonumber(p3) or 0
        if idx < 0 or idx > 3 then
            Player.sendmsgEx(play, "参数错误#57")
            return
        end
        if idx > 0 and aura[idx].open ~= 1 then
            Player.sendmsgEx(play, "该光环尚未解锁#57")
            return
        end
        setplaydef(play, VarCfg["U_护体光环激活"], idx)
        if Buff and Buff.refreshHuTiGuangHuan then
            Buff.refreshHuTiGuangHuan(play)
        end
        for i = 1, 3 do
            aura[i].active = idx == i and 1 or 0
        end
        sendluamsg(play, 101, 23, 1, idx, tbl2json({aura = aura, active = idx}))
    end
end
npc[30] = function(play, p2, p3, data) --砍树系统
    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    if not (jq_data["npc_55"] and jq_data["npc_55"] >= 2) then
        Player.sendmsgEx(play, "你还未开启相关剧情，暂无法使用#57")
        return
    end
    
    if p2 == 0 then
        --砍树系统  --初始化页面
        local tmp_data = {}
        tmp_data["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_砍树系统"])
        sendluamsg(play, 101, 30, 0, 0, tbl2json(tmp_data))
    elseif p2 == 1 then --升级
        local T_data = Player.getJsonTableByVar(play, VarCfg["T_砍树系统"])
        local config = teshudata["anniu_30"]
        if p3 == 1 then  --升级斧子
            T_data.axe = T_data.axe or 1
            if T_data.axe >= config.updata[1].max_level then
                Player.sendmsgEx(play, "斧子已满级，无需升级...#57")
                return
            end
            local name, num = Player.checkItemNumByTable(play, config.updata[1].details[T_data.axe].cost)
            if name then
                Player.sendmsgEx(play, string.format("你的#57|【%s】#249|不足：#57|【%d】#249|", name, num))
                return
            end
            Player.takeItemByTable(play, config.updata[1].details[T_data.axe].cost, ",砍树系统",nil)
            T_data.axe = T_data.axe + 1
            Player.setJsonVarByTable(play, VarCfg["T_砍树系统"], T_data)
            Player.sendmsgEx(play, "斧子升级成功，当前斧子等级为|【"..T_data.axe.."】#249|")
            sendluamsg(play, 101, 30, 2, 1, tbl2json({T_data = T_data}))
        elseif p3 == 2 then--升级自动升级
            T_data.auto = T_data.auto or 1
            if T_data.auto >= config.updata[2].max_level then
                Player.sendmsgEx(play, "自动砍树已满级，无需升级...#57")
                return
            end
            local name, num = Player.checkItemNumByTable(play, config.updata[2].details[T_data.auto].cost)
            if name then
                Player.sendmsgEx(play, string.format("你的#57|【%s】#249|不足：#57|【%d】#249|", name, num))
                return
            end
            Player.takeItemByTable(play, config.updata[2].details[T_data.auto].cost, ",砍树系统",nil)
            T_data.auto = T_data.auto + 1
            Player.setJsonVarByTable(play, VarCfg["T_砍树系统"], T_data)
            Player.sendmsgEx(play, "自动砍树升级成功，当前自动砍树等级为|【"..T_data.auto.."】#249|")
            sendluamsg(play, 101, 30, 2, 2, tbl2json({T_data = T_data}))
        end
    elseif p2 == 2 then --获得奖励
        local config = teshudata["anniu_30"]
        local T_data = Player.getJsonTableByVar(play, VarCfg["T_砍树系统"])
        T_data.axe = T_data.axe or 1
        T_data.num = T_data.num or 0
        if p3 == 1 then -- 打开页面时自动的奖励
            -- release_print("砍树系统自动奖励触发")
            -- release_print(os.time())
            -- release_print(getplaydef(play,"N$自动砍树") + config.updata[1].details[T_data.axe].ratio * config.updata[2].details[T_data.auto].ratio * config.base_time)
            if os.time() >= getplaydef(play,"N$自动砍树") + (config.updata[1].details[T_data.axe].ratio * config.updata[2].details[T_data.auto or 1].ratio * config.base_time) then
                local jl = ransjstr(config.updata[1].details[T_data.axe].jl, 1, 3)
                setplaydef(play,"N$自动砍树",os.time())
                T_data.num = T_data.num + 1
                Player.setJsonVarByTable(play, VarCfg["T_砍树系统"], T_data)
                if FairyFate and FairyFate.touch then FairyFate.touch(play, "woodcut", 1) end
                sendluamsg(play, 101, 30, 1, 0, tbl2json({T_data = T_data}))
                Player.rwjl(play, {{jl,1}}, "砍树系统自动奖励", 1,0)
                sendluamsg(play, 101, 30, 3, 0, tbl2json({{jl,1}}))   
            else
                return
            end
        elseif p3 == 2 then -- 打开页面时手动点击的奖励
            local name, num = Player.checkItemNumByTable(play, config.click.cost)
            if name then
                Player.sendmsgEx(play, string.format("你的#57|【%s】#249|不足：#57|【%d】#249|", name, num))
                return
            end
            Player.takeItemByTable(play, config.click.cost, ",砍树系统",nil)
            T_data.num = T_data.num + 1
            Player.setJsonVarByTable(play, VarCfg["T_砍树系统"], T_data)
            if FairyFate and FairyFate.touch then FairyFate.touch(play, "woodcut", 1) end
            sendluamsg(play, 101, 30, 1, 0, tbl2json({T_data = T_data}))
            local jl = ransjstr(config.updata[1].details[T_data.axe].jl, 1, 3)
            release_print("砍树系统奖励:",tbl2json(jl))
            Player.rwjl(play, {{jl,1}}, "砍树系统自动奖励", 1,0)
            sendluamsg(play, 101, 30, 3, 0, tbl2json({{jl,1}}))
        end
    elseif p2 == 3 then --定时器开关
        local T_data = Player.getJsonTableByVar(play, VarCfg["T_砍树系统"])
        if getflagstatus(play, VarCfg.BS_mztq) ~= 1 then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff7700\'>[自动砍树]</font><font color=\'#ff0500\'>未激活特权，无法开启自动砍树...</font>","Type":9}')
            return
        end
        if not (getplaydef(play,"N$自动砍树") == 1) then
            T_data.auto = T_data.auto or 1
            Player.setJsonVarByTable(play, VarCfg["T_砍树系统"], T_data)
            setontimer(play,7,60*20,0,1)
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>自动砍树已开启...</font>","Type":9}')
            setplaydef(play,"N$自动砍树",os.time())
            if p2 == 1 then
                local tmp_data = {}
                tmp_data["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_砍树系统"])
                sendluamsg(play, 101, 30, 0, 0, tbl2json(tmp_data))
            end
        -- else
        --     Player.setJsonVarByTable(play, VarCfg["T_砍树系统"], T_data)
        --     setofftimer(play,7)
        --     sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>自动砍树已关闭...</font>","Type":9}')
        --     setplaydef(play,"N$自动砍树",os.time())
        end
    elseif p2 == 4 then --兑换盲盒
        local config = teshudata["anniu_30"]
        local T_data = Player.getJsonTableByVar(play, VarCfg["T_砍树系统"])
        T_data.dh_num = T_data.dh_num or 1
        local name, num = Player.checkItemNumByTable(play, T_data.dh_num > #config.dh.details and config.dh.cost or config.dh.details[T_data.dh_num].cost)
        if name then
            Player.sendmsgEx(play, string.format("你的#57|【%s】#249|不足：#57|【%d】#249|", name, num))
            return
        end
        Player.takeItemByTable(play, T_data.dh_num > #config.dh.details and config.dh.cost or config.dh.details[T_data.dh_num].cost, ",砍树系统",nil)
        T_data.dh_num = T_data.dh_num + 1
        Player.setJsonVarByTable(play, VarCfg["T_砍树系统"], T_data)
        Player.rwjl(play, {{"砍树盲盒",1}}, "砍树系统盲盒兑换", 1,1000)
        sendluamsg(play, 101, 30, 4, 0, tbl2json({T_data = T_data}))
    end
end
npc[31] = function(play, p2, p3, data) --马上发财
    Npclib[101].main(play, 101)
end
---首充礼包
npc[501] = function(play, p2, p3, data) --首充礼包
    if p2 == 0 then
        local tmp_data = {}
        tmp_data["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_首冲礼包"])
        local list = ((teshudata["anniu_501"] or {}).details or {})["首充"] or {}
        local dl_progress = 1
        for i = 2, #list do
            if Player.dl_sz_notip(play, i) then
                dl_progress = i
            else
                break
            end
        end
        tmp_data["dl_progress"] = dl_progress
        tmp_data["time_data"] = dl_progress
        sendluamsg(play, 101, 501, 0, 0, tbl2json(tmp_data))
    elseif p2 == 1 then
        local cfg = teshudata["anniu_501"]
        local T_data = Player.getJsonTableByVar(play, VarCfg["T_首冲礼包"])
        local time_data = getsysvar(VarCfg["G_开区天数"])
        if not (T_data["ok"] and T_data["ok"] == 1) then
            sendluamsg(play, 101, 999, 6, 21, "")
            return
        end
        if T_data["首充"] == 1 then
            local list = cfg and cfg.details and cfg.details["首充"] or {}
            local max = #list
            if max <= 0 then
                Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0500\'>礼包配置异常...</font>","Type":9}')
                return
            end
            local claimed = tonumber(T_data["other_lb"] or 0) or 0
            local idx = claimed + 1
            if idx > max then
                Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0500\'>首充礼包已领取...</font>","Type":9}')
                return
            end
            if not Player.dl_sz(play, idx) then
                return
            end
            T_data["other_lb"] = idx
            T_data["jq_time"] = time_data
            Player.setJsonVarByTable(play, VarCfg["T_首冲礼包"], T_data)
            local reward = list[idx].jl
            if reward and #reward > 0 then
                Player.rwjl(play, reward, "首充礼包", 1, 1000)
            end
            if idx == 1 then
                addskill(play, 25, 3)
                -- 飞剑功能临时下线：首充不再改动飞剑参数
                -- local T_data_fj = Player.getJsonTableByVar(play, VarCfg["T_飞剑"])
                -- T_data_fj.ratio = 2
                -- Player.setJsonVarByTable(play, VarCfg["T_飞剑"], T_data_fj)
                local T_data = Player.getJsonTableByVar(play, VarCfg.T_szjl)
                T_data.yjs = T_data.yjs or {}
                T_data.yjs[""..1] = 1
                Player.setJsonVarByTable(play, VarCfg.T_szjl, T_data)
                GameEvent.push(EventCfg.onUPSkin, play, 1)
                _refreshFashionAttr(play, T_data)
            elseif idx == 2 then
                addskill(play, 51, 3)
            end
            sendluamsg(play, 101, 1005, 0, 0, "lqcg")
            return
        end
        Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0500\'>未满足领取条件...</font>","Type":9}')
    end
end
---在线充值
npc[502] = function(play, p2, p3, data) --在线充值
    if p3 == 0 then
        sendluamsg(play, 101, 502, 0, 0, getplaydef(play, VarCfg.T_czlb))
    elseif p3 == 2 then
        local je = tonumber(data)
        if je and constant.cz_jeyz[je] then
            local czlb = json2tbl(getplaydef(play, VarCfg.T_czlb))
            if type(czlb) ~= "table" then
                czlb = {}
            end
            if not czlb["cz502_" .. tostring(je)] and querymoney(play, 22) >= je then
                changemoney(play, 22, "-", je, "礼包积分", true)
                czlb = _cz502_apply_reward(play, je, nil, czlb)
                setplaydef(play, VarCfg.T_czlb, tbl2json(czlb))
                sendluamsg(play, 101, 502, 0, 0, getplaydef(play, VarCfg.T_czlb))
            else
                setplaydef(play, VarCfg.U_czyz, constant.cz_jeyz[je])
                sendluamsg(play, 101, 999, je, 7, "")
            end
        end
    elseif p3 == 3 then
        local je = tonumber(data)
        if je and je >= 10 then
            setplaydef(play, VarCfg.U_czyz, 0)
            sendluamsg(play, 101, 999, je, 7, "")
        else
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0500\'>充值金额不得小于10元...</font>","Type":9}')
        end
    elseif p3 == 4 then
        local json = json2tbl(getplaydef(play, VarCfg.T_czlb))
        if json.cz4 then
            if json.jskg then
                json.jskg = nil
                Buff[71](play, 2)
                sendmsg(play, 1, '{"Msg":"<font color=\'#ff0500\'>溅射功能已关闭...</font>","Type":9}')
            else
                Buff[71](play, 1)
                json.jskg = true
                sendmsg(play, 1, '{"Msg":"<font color=\'#28ef01\'>溅射功能已开启...</font>","Type":9}')
            end
            setplaydef(play, VarCfg.T_czlb, tbl2json(json))
        end
    end
end
---快人一步
npc[504] = function(play, p2, p3, data) --快人一步
    if p2 == 0 then
        sendluamsg(play, 101, 504, 0, 0, '{"mztq":' .. getflagstatus(play, VarCfg.BS_mztq) .. "}")
    elseif p2 == 1 then
        if getflagstatus(play, VarCfg.BS_mztq) == 0 then
            sendluamsg(play, 101, 999, 88, 21, "")
        else
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>每人只能购买一次</font>","Type":9}')
        end
    end
end
---自动巡航
npc[505] = function(play, p2, p3, data) --自动巡航
    if p2 == 0 then
        sendluamsg(play, 101, 505, 0, 0, "")
    elseif p2 == 1 then
        sendluamsg(play, 101, 505, 1, 0, getplaydef(play, VarCfg.T_aigj))
    elseif p2 == 2 then
        local dtmz = getbaseinfo(play, 3)
        if jinzhigj[dtmz] or string.find(dtmz, "_") then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff7700\'>[自动巡航]</font><font color=\'#ff0000\'>当前地图,无法记录...</font>","Type":9}')
        elseif checkkuafu(play) then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff7700\'>[自动巡航]</font><font color=\'#ff0000\'>跨服地图,无法记录...</font>","Type":9}')
        else
            local json = json2tbl(getplaydef(play, VarCfg.T_aigj))
            json["dt" .. p3] = getbaseinfo(play, 45)
            json["dtid" .. p3] = dtmz
            sendluamsg(play, 101, 505, 2, p3, getbaseinfo(play, 45))
            setplaydef(play, VarCfg.T_aigj, tbl2json(json))
        end
    elseif p2 == 3 then
        local json = json2tbl(getplaydef(play, VarCfg.T_aigj))
        if json["fgx" .. p3] then
            json["fgx" .. p3] = nil
        elseif json["dtid" .. p3] then
            json["fgx" .. p3] = true
        else
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff7700\'>[自动巡航]</font><font color=\'#ff0500\'>当前未记录地图,无法勾选...</font>","Type":9}')
        end
        setplaydef(play, VarCfg.T_aigj, tbl2json(json))
        sendluamsg(play, 101, 505, 3, p3, getplaydef(play, VarCfg.T_aigj))
    elseif p2 == 4 then
        local json = json2tbl(getplaydef(play, VarCfg.T_aigj))
        if getflagstatus(play, VarCfg.BS_AIgj) == 0 then
            local yz = 0
            for i = 1, 10, 1 do
                if json["fgx" .. i] then
                    yz = 1
                    break
                end
            end
            if yz == 1 then
                startautoattack(play)
                setflagstatus(play, VarCfg.BS_AIgj, 1)
                json.gjkg = true
                setplaydef(play, VarCfg.N_Aigj[5], os.time())
            else
                sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[自动巡航]</font><font color=\'#ff0500\'>未勾选任何地图,无法进行AI挂机...</font>","Type":9}' )
            end
        else
            json.gjkg = nil
            stopautoattack(play)
            setflagstatus(play, VarCfg.BS_AIgj, 0)
        end
        setplaydef(play, VarCfg.T_aigj, tbl2json(json))
        sendluamsg(play, 101, 505, 4, 0, tbl2json(json))
    elseif p2 == 5 then
        local json = json2tbl(getplaydef(play, VarCfg.T_aigj))
        if p3 == 1 then
            if json.zgx1 then
                json.zgx1 = nil
                Buff[72](play, 2)
            else
                Buff[72](play, 1)
                json.zgx1 = true
            end
        else
            if json["zgx" .. p3] then
                json["zgx" .. p3] = nil
            else
                json["zgx" .. p3] = true
            end
        end
        setplaydef(play, VarCfg.T_aigj, tbl2json(json))
    end
end
---天选之人
npc[506] = function(play, p2, p3, msgData) --天选之子
    if p2 == 0 then
        local sc_data = Player.getJsonTableByVar(play, VarCfg["T_首冲礼包"])
        local tx_cfg = teshudata["anniu_506"] or {}
        setflagstatus(play, VarCfg.BS_sckg, (sc_data["ok"] and sc_data["ok"] == 1) and 1 or 0)
        sendluamsg(play, 101, 506, 0, 0, '{"A_txzz":' .. (getsysvar(VarCfg["A_天选之人json"]) == "" and "{}" or getsysvar(VarCfg["A_天选之人json"])) .. ',"T_txzr":' .. getplaydef(play, VarCfg.T_txzr) .. ',"kqsj":' .. getsysvar(VarCfg["G_开区分钟"]) .. ',"G_txzz_2":' .. getsysvar(VarCfg["G_天选之人"][2]) .. ',"bmkg":' .. getflagstatus(play, VarCfg.BS_sckg) .. ',"cfg_sq":' .. tbl2json(tx_cfg.shenqi or {}) .. ',"cfg_notice":' .. tbl2json(tx_cfg.notice or {}) .. "}")
    elseif p2 == 1 then
        -- 天选报名改为“首充礼包后自动报名”，此处仅回传当前状态
        if getflagstatus(play, VarCfg.BS_sckg) == 1 then
            sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>天选之人：已达成首充礼包，自动报名成功...</font>","Type":9}')
        else
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>天选之人：完成首充礼包后将自动报名...</font>","Type":9}')
        end
        sendluamsg(play, 101, 506, 1, getflagstatus(play, VarCfg.BS_sckg), "")
    end
end
local hd_dtmz = {}
-- 读取全民答题配置（提交入口固定走 npc[507]）
local function _qmdt_get_cfg_507()
    local cfg = teshudata and teshudata["anniu_507"] and teshudata["anniu_507"].qmdt or nil
    if type(cfg) ~= "table" then
        return nil
    end
    if type(cfg.questions) ~= "table" or #cfg.questions <= 0 then
        return nil
    end
    cfg.question_count = math.min(tonumber(cfg.question_count) or 5, #cfg.questions)
    cfg.per_question_sec = tonumber(cfg.per_question_sec) or 120
    cfg.base_score = tonumber(cfg.base_score) or 100
    cfg.time_bonus_per_sec = tonumber(cfg.time_bonus_per_sec) or 1
    return cfg
end
local function _qmdt_get_state_507()
    local raw = getsysvar(VarCfg["A_全民答题json"])
    if raw == "" then
        return {}
    end
    local tb = json2tbl(raw)
    return type(tb) == "table" and tb or {}
end
local function _qmdt_save_state_507(state)
    setsysvar(VarCfg["A_全民答题json"], tbl2json(state or {}))
end
local function _qmdt_build_prompt_507(q, qidx, total)
    local lines = {"第" .. tostring(qidx) .. "/" .. tostring(total) .. "题：" .. tostring(q.title or "")}
    for i, one in ipairs(q.options or {}) do
        lines[#lines + 1] = tostring(i) .. "." .. tostring(one)
    end
    lines[#lines + 1] = "请输入答案序号或完整答案"
    return table.concat(lines, "\n")
end
local function _qmdt_make_payload_507(state, cfg, qidx)
    local q = cfg and cfg.questions and cfg.questions[qidx]
    if not q then
        return {open = 0}
    end
    local remain = math.max(0, (tonumber(state.question_end_ts) or 0) - os.time())
    return {
        open = tonumber(state.open) or 0,
        idx = qidx,
        total = cfg.question_count,
        title = _qmdt_build_prompt_507(q, qidx, cfg.question_count),
        question_title = q.title,
        options = q.options or {},
        input_mode = 1,
        placeholder = "请输入答案序号或完整答案",
        limit_sec = remain,
        end_ts = tonumber(state.question_end_ts) or 0,
    }
end
local function _qmdt_build_say_507(state, cfg, qidx)
    local q = cfg and cfg.questions and cfg.questions[qidx]
    if not q then
        return nil
    end
    local remain = math.max(0, (tonumber(state.question_end_ts) or 0) - os.time())
    local lines = {
        '第' .. tostring(qidx) .. '/' .. tostring(cfg.question_count) .. '题：' .. tostring(q.title or ''),
    }
    for i, one in ipairs(q.options or {}) do
        lines[#lines + 1] = tostring(i) .. '.' .. tostring(one)
    end
    -- lines[#lines + 1] = '剩余时间：' .. tostring(remain) .. '秒'
    lines[#lines + 1] = '<发送/@@InputString24(请输入答案序号或完整答案：)>'
    return table.concat(lines, '\\') .. '\\'
end
local function _qmdt_is_active_507(state, cfg, qidx)
    if not cfg or tonumber(state.open) ~= 1 then
        return false
    end
    if not qidx or qidx <= 0 or not cfg.questions[qidx] then
        return false
    end
    local endTs = tonumber(state.question_end_ts) or 0
    if endTs > 0 and os.time() > endTs then
        return false
    end
    return true
end
local function _qmdt_parse_answer_507(q, answerRaw, p3)
    local raw = tostring(answerRaw or "")
    raw = string.gsub(raw, "^%s+", "")
    raw = string.gsub(raw, "%s+$", "")
    raw = string.gsub(raw, "１", "1")
    raw = string.gsub(raw, "２", "2")
    raw = string.gsub(raw, "３", "3")
    raw = string.gsub(raw, "４", "4")
    raw = string.gsub(raw, "５", "5")
    raw = string.gsub(raw, "６", "6")
    raw = string.gsub(raw, "７", "7")
    raw = string.gsub(raw, "８", "8")
    raw = string.gsub(raw, "９", "9")
    raw = string.gsub(raw, "０", "0")
    if raw == "" and tonumber(p3) and tonumber(p3) > 0 then
        raw = tostring(p3)
    end
    if raw == "" then
        return nil
    end
    local num = tonumber(raw)
    if num and q.options and q.options[num] then
        return num
    end
    local firstNum = string.match(raw, "^(%d+)")
    if firstNum then
        num = tonumber(firstNum)
        if num and q.options and q.options[num] then
            return num
        end
    end
    local letterMap = {A = 1, B = 2, C = 3, D = 4, E = 5, F = 6}
    local upper = string.upper(raw)
    if letterMap[upper] and q.options and q.options[letterMap[upper]] then
        return letterMap[upper]
    end
    local firstLetter = string.match(upper, "^([A-F])")
    if firstLetter and letterMap[firstLetter] and q.options and q.options[letterMap[firstLetter]] then
        return letterMap[firstLetter]
    end
    for i, one in ipairs(q.options or {}) do
        if tostring(one) == raw then
            return i
        end
    end
    return nil
end
local function _qmdt_submit_answer_507(play, answerRaw, p3)
    local cfg = _qmdt_get_cfg_507()
    if not cfg then
        Player.sendmsgEx(play, "全民答题配置缺失#57")
        return
    end
    if getsysvar(VarCfg["G_全民答题状态"]) ~= 1 then
        Player.sendmsgEx(play, "全民答题未开启#57")
        return
    end
    local state = _qmdt_get_state_507()
    if tonumber(state.open) ~= 1 then
        Player.sendmsgEx(play, "全民答题未开启#57")
        return
    end
    local qidx = tonumber(state.current_idx) or 0
    if qidx <= 0 or qidx > cfg.question_count then
        Player.sendmsgEx(play, "当前暂无可答题目#57")
        return
    end
    if (tonumber(state.question_end_ts) or 0) > 0 and os.time() > tonumber(state.question_end_ts) then
        Player.sendmsgEx(play, "本题答题时间已结束#57")
        return
    end
    local q = cfg.questions[qidx]
    local answerNum = _qmdt_parse_answer_507(q, answerRaw, p3)
    if not q or not answerNum then
        Player.sendmsgEx(play, "请输入答案序号或完整答案#57")
        return
    end
    local playerName = getbaseinfo(play, 1)
    state.players = state.players or {}
    local rec = state.players[playerName] or {score = 0, right = 0, total = 0, questions = {}}
    rec.questions = rec.questions or {}
    local ansKey = tostring(qidx)
    local qrec = rec.questions[ansKey] or {tries = 0, done = 0, joined = 0}
    if tonumber(qrec.done) == 1 then
        Player.sendmsgEx(play, "本题你已经答对了#57")
        return
    end
    if tonumber(qrec.joined) ~= 1 then
        qrec.joined = 1
        rec.total = (tonumber(rec.total) or 0) + 1
    end
    qrec.tries = (tonumber(qrec.tries) or 0) + 1
    qrec.answer = answerNum
    local isRight = 0
    local gainScore = 0
    local timeBonus = 0
    local baseScore = tonumber(cfg.base_score) or tonumber(q.score) or 100
    if tonumber(q.answer) == answerNum then
        isRight = 1
        qrec.done = 1
        rec.right = (tonumber(rec.right) or 0) + 1
        timeBonus = math.max(0, math.floor(math.max(0, (tonumber(state.question_end_ts) or 0) - os.time()) * (tonumber(cfg.time_bonus_per_sec) or 1)))
        gainScore = baseScore + timeBonus
        rec.score = (tonumber(rec.score) or 0) + gainScore
    end
    rec.questions[ansKey] = qrec
    state.players[playerName] = rec
    _qmdt_save_state_507(state)
    if isRight == 1 then
        sendluamsg(play, 101, 12, 4, 3, "")
        Player.sendmsgEx(play, "回答正确，当前积分+|【"..tostring(gainScore) .. "（基础" .. tostring(baseScore) .. "+时间奖励" .. tostring(timeBonus).."）】#249|")
    else
        Player.sendmsgEx(play, "回答错误，可继续作答直到本题结束#57")
    end
end
function inputstring24(play)
-- release_print("inputstring24:", getplaydef(play, "S24"))
-- release_print("inputstring24:", getconst(play, "<$NPCPARAMS(1,S24)>"))
    local answerRaw = getconst(play, "<$NPCPARAMS(1,S24)>")
    if answerRaw == nil then
        answerRaw = ""
    end
    answerRaw = tostring(answerRaw)
    answerRaw = string.gsub(answerRaw, "^%s+", "")
    answerRaw = string.gsub(answerRaw, "%s+$", "")
    _qmdt_submit_answer_507(play, answerRaw, 0)
end
local function _activity507_enter_notice(play, actIdx, actName)
    if not play or not actName or actName == "" then
        return
    end
    local idx = tonumber(actIdx) or 0
    local rowVar = "N$507NoticeRow_" .. tostring(idx)
    local row = tonumber(getsysvar(rowVar) or 0) or 0
    local x = 100
    local y = 700 - (row % 30) * 18
    local payload = getbaseinfo(play, 1) .. "参与了[" .. actName .. "]活动"
    for _, player in ipairs(getplayerlst() or {}) do
        sendcustommsg(player, 1, payload, 251, 0, x, y)
    end
    setsysvar(rowVar, (row + 1) % 30)
end
local function _activity507_is_open(p3)
    local dqfz = tonumber(getsysvar(VarCfg["G_开区分钟"]) or 0) or 0
    if p3 == 2 then
        local state = getsysvar(VarCfg["A_全民夺矿json"])
        local tb = state ~= "" and json2tbl(state) or {}
        return getsysvar(VarCfg["G_全民夺矿状态"]) == 1 and type(tb) == "table" and tonumber(tb.open) == 1
    elseif p3 == 3 then
        local cfg = _qmdt_get_cfg_507()
        local state = _qmdt_get_state_507()
        local idx = tonumber(state.current_idx) or 0
        return cfg and tonumber(state.open) == 1 and idx > 0 and _qmdt_is_active_507(state, cfg, idx)
    elseif p3 == 5 then
        -- 土城跑酷：OnTimer 在开服第 5 分钟开启，第 8 分钟关闭。
        return dqfz >= 5 and dqfz < 8
    elseif p3 == 9 then
        -- 武林盟主：OnTimer 在开服第 25 分钟开启，第 30 分钟关闭。
        return dqfz >= 25 and dqfz < 30
    elseif p3 == 13 then
        local cfg = teshudata and teshudata["anniu_507"] and teshudata["anniu_507"].sjdb or {}
        local keepMin = math.max(1, math.ceil((tonumber(cfg.keep_sec) or 300) / 60))
        return dqfz >= 15 and dqfz < (15 + keepMin)
    end
    return false
end
local function _activity507_open_state_payload()
    return tbl2json({
        [2] = _activity507_is_open(2) and 1 or 0,
        [3] = _activity507_is_open(3) and 1 or 0,
        [5] = _activity507_is_open(5) and 1 or 0,
        [9] = _activity507_is_open(9) and 1 or 0,
        [13] = _activity507_is_open(13) and 1 or 0,
    })
end
npc[507] = function(play, p2, p3, msgData) --游戏活动
    if p2 == 0 then
        local qmdt_state = getsysvar(VarCfg["A_全民答题json"])
        if qmdt_state == "" then
            qmdt_state = "{}"
        end
        local qmdk_state = getsysvar(VarCfg["A_全民夺矿json"])
        local qmdk_tb = qmdk_state ~= "" and json2tbl(qmdk_state) or {}
        if type(qmdk_tb) ~= "table" then
            qmdk_tb = {}
        end
        local qmdk_cfg = teshudata and teshudata["anniu_507"] and teshudata["anniu_507"].qmdk or {}
        local qmdk_score_var = nil
        if QmdkApi and QmdkApi.get_score_var then
            qmdk_score_var = QmdkApi.get_score_var(qmdk_cfg, qmdk_tb)
        end
        if qmdk_score_var and qmdk_score_var ~= "" then
            qmdk_tb.grjf = tonumber(getplayvar(play, "HUMAN", qmdk_score_var) or 0) or 0
            qmdk_tb.pmsj = sorthumvar(qmdk_score_var, 1, 1, 5)
        else
            qmdk_tb.grjf = 0
            qmdk_tb.pmsj = {}
        end
        qmdk_state = tbl2json(qmdk_tb)
        sendluamsg(play, 101, 507, 0, 0, '{"kqfz":' .. getsysvar(VarCfg["G_开区分钟"]) .. ',"hdjl":' .. getplaydef(play, VarCfg.T_hdjl) .. ',"qmdt":' .. qmdt_state .. ',"qmdk":' .. qmdk_state .. ',"open_state":' .. _activity507_open_state_payload() .. "}")
    elseif p2 == 1 then
        if p3 == 1 then
            Player.sendmsgEx(play, "保卫村庄暂未接入活动入口#57")
        elseif p3 == 2 then
            if not _activity507_is_open(p3) then
                Player.sendmsgEx(play, "不是活动时间，无法进入#57")
                return
            end
            local qmdk_cfg = teshudata and teshudata["anniu_507"] and teshudata["anniu_507"].qmdk or {}
            local qmdk_map = qmdk_cfg.map or "全民夺矿"
            map(play, qmdk_map)
            _activity507_enter_notice(play, 2, "全民夺矿")
        elseif p3 == 3 then
            if not _activity507_is_open(p3) then
                Player.sendmsgEx(play, "不是活动时间，无法进入#57")
                return
            end
            local cfg = _qmdt_get_cfg_507()
            local state = _qmdt_get_state_507()
            local idx = tonumber(state.current_idx) or 0
            if _qmdt_is_active_507(state, cfg, idx) then
                local sayText = _qmdt_build_say_507(state, cfg, idx)
                if sayText and sayText ~= "" then
                    say(play, sayText)
                end
            elseif cfg and tonumber(state.open) == 1 and idx > 0 and cfg.questions[idx] then
                Player.sendmsgEx(play, "本题答题时间已结束，请等待下一题#57")
            else
                Player.sendmsgEx(play, "全民答题当前未开启#57")
            end
        elseif p3 == 4 then
            Player.sendmsgEx(play, "勇夺镖车暂未接入活动入口#57")
        elseif p3 == 5 then
            if not _activity507_is_open(p3) then
                Player.sendmsgEx(play, "不是活动时间，无法进入#57")
                return
            end
            mapmove(play, "xtc",137,138)
            _activity507_enter_notice(play, 5, "土城跑酷")
        elseif p3 == 6 then
            Player.sendmsgEx(play, "天才地宝暂未接入活动入口#57")
        elseif p3 == 7 then
            Npclib["anniu"][506](play, 0, 0, "")
        elseif p3 == 8 then
            Player.sendmsgEx(play, "正邪大战暂未接入活动入口#57")
        elseif p3 == 9 then
            if not _activity507_is_open(p3) then
                Player.sendmsgEx(play, "不是活动时间，无法进入#57")
                return
            end
            map(play, "比武大会")
            _activity507_enter_notice(play, 9, "武林盟主")
        elseif p3 == 10 then
            Player.sendmsgEx(play, "该活动入口暂未开放#57")
        elseif p3 == 11 then
            Player.sendmsgEx(play, "沙巴克请通过专用入口参与#57")
        elseif p3 == 12 then
            Player.sendmsgEx(play, "讨伐BOSS暂未接入活动入口#57")
        elseif p3 == 13 then
            if not _activity507_is_open(p3) then
                Player.sendmsgEx(play, "不是活动时间，无法进入#57")
                return
            end
            map(play, "天降财宝")
            _activity507_enter_notice(play, 13, "随机夺宝")
        elseif p3 == 14 then
            Player.sendmsgEx(play, "黑暗禁地暂未接入活动入口#57")
        end
    elseif p2 == 2 then
        local data = json2tbl(msgData or "") or {}
        local answerRaw = nil
        if type(data) == "table" then
            answerRaw = data.answer or data.ans or data.text or data.msg or data.input
        end
        if answerRaw == nil or answerRaw == "" then
            answerRaw = msgData
        end
        _qmdt_submit_answer_507(play, answerRaw, p3)
    elseif p2 == 3 then
        return
    end
end
local function _qmdk_event_refresh(play)
    if QmdkApi and QmdkApi.refresh_actor then
        QmdkApi.refresh_actor(play)
    end
end
local function _qmdk_event_hurt(play)
    if QmdkApi and QmdkApi.on_actor_hurt then
        QmdkApi.on_actor_hurt(play, "你受到攻击，采集中断")
    end
end
local function _qmdk_event_move(play)
    if QmdkApi and QmdkApi.on_actor_move then
        QmdkApi.on_actor_move(play)
    end
end
local function _qmdk_event_die(play)
    if QmdkApi and QmdkApi.on_actor_die then
        QmdkApi.on_actor_die(play)
    end
end
GameEvent.add(EventCfg.onLogin, _qmdk_event_refresh, "全民夺矿")
GameEvent.add(EventCfg.onKFLogin, _qmdk_event_refresh, "全民夺矿")
GameEvent.add(EventCfg.goSwitchMap, _qmdk_event_refresh, "全民夺矿")
GameEvent.add(EventCfg.onProHarm, _qmdk_event_hurt, "全民夺矿")
GameEvent.add(EventCfg.onMove, _qmdk_event_move, "全民夺矿")
GameEvent.add(EventCfg.onPlaydie, _qmdk_event_die, "全民夺矿")
---天天省钱
npc[509] = function(play, p2, p3, msgData)
    openhyperlink(play, 111, 0)
    Player.zxrw_wancheng(play, 3, "任务") --完成任务
end
---交易行
npc[510] = function(play, p2, p3, msgData)
    openhyperlink(play, 35, 0)
end
-- 福利大厅七日登录读取配置
-- 福利大厅七日登录读取配置
local fldt_cfg_table = teshudata["fldt"] and teshudata["fldt"]["fldt_cfg"]
local fldt_seven_login_cfg = (fldt_cfg_table and fldt_cfg_table["seven_login"]) or {}
local fldt_online_minutes_limit = tonumber(fldt_seven_login_cfg.online_limit or 0) or 0
local fldt_number_days = tonumber(fldt_seven_login_cfg.number_days or 4) or 4
if fldt_number_days < 1 then fldt_number_days = 1 end
if fldt_number_days > 7 then fldt_number_days = 7 end
local fldt_digit_prob = fldt_seven_login_cfg.digit_prob or {}
local fldt_material_pool = fldt_seven_login_cfg.material_pool or {}
local fldt_privilege_final_multiple = tonumber(fldt_seven_login_cfg.privilege_final_multiple or 2) or 2
local fldt_final_reward_multiplier = tonumber(fldt_seven_login_cfg.final_reward_multiplier or 100) or 100
local fldt_final_reward_cap = tonumber(fldt_seven_login_cfg.final_reward_cap or 1000000) or 1000000
local fldt_final_reward_cap_privilege = tonumber(fldt_seven_login_cfg.final_reward_cap_privilege or 2000000) or 2000000
-- 是否拥有麦尊特权（用于所有特权判断）
local function fldt_is_privilege(play)
    return getflagstatus(play, VarCfg.BS_mztq) == 1
end
-- 根据配置生成当日翻牌数字，并处理特权玩家的避零逻辑
-- 权重随机工具
local function fldt_pick_weighted_entry(entries)
    if type(entries) ~= "table" or #entries <= 0 then
        return nil
    end
    local total = 0
    for _, e in ipairs(entries) do
        total = total + (tonumber(e.weight or 0) or 0)
    end
    if total <= 0 then
        return entries[math.random(1, #entries)]
    end
    local roll = math.random(1, total)
    local acc = 0
    for _, e in ipairs(entries) do
        acc = acc + (tonumber(e.weight or 0) or 0)
        if roll <= acc then
            return e
        end
    end
    return entries[#entries]
end
-- 根据新版概率生成当日翻牌数字（绝不出现0）
local function fldt_pick_seven_login_digit(day)
    local probKey = (day <= 3) and "front3" or "tail"
    local probEntries = fldt_digit_prob[probKey] or {}
    local pick = fldt_pick_weighted_entry(probEntries)
    if not pick then
        return math.random(1, 9)
    end
    local minv = tonumber(pick.min or 1) or 1
    local maxv = tonumber(pick.max or 9) or 9
    if minv < 1 then minv = 1 end
    if maxv < minv then maxv = minv end
    if minv == maxv then
        return minv
    end
    return math.random(minv, maxv)
end
-- 后三天神秘奖励（占位版）；PlanB可在此按玩家缺口动态替换 give
local function fldt_pick_material_reward(day, play, privilege)
    local pool = fldt_material_pool[day] or fldt_material_pool["default"] or {}
    local pick = fldt_pick_weighted_entry(pool)
    if not pick then
        return nil, nil
    end
    local tag = pick.tag or pick.name or ("神秘奖励_" .. tostring(day))
    local give = pick.give or {}
    return give, tag
end
-- 深拷贝奖励列表，避免后续修改原配置表
local function fldt_clone_reward_list(give)
    local out = {}
    if type(give) ~= "table" then
        return out
    end
    for _, one in ipairs(give) do
        if type(one) == "table" then
            local row = {}
            for i, v in ipairs(one) do
                row[i] = v
            end
            out[#out + 1] = row
        end
    end
    return out
end
-- 统一七日材料奖励记录结构，兼容旧版本字符串记录
local function fldt_prepare_material_table(T_qrbq)
    local changed = false
    local matData = T_qrbq["7rqd_mat"]
    if type(matData) ~= "table" then
        matData = {}
        T_qrbq["7rqd_mat"] = matData
        changed = true
    end
    for day, record in pairs(matData) do
        local dayNum = tonumber(day) or day
        if type(record) == "string" then
            matData[day] = {day = dayNum, tag = record, give = {}, ts = 0}
            changed = true
        elseif type(record) == "table" then
            if record.day == nil then
                record.day = dayNum
                changed = true
            end
            if record.tag == nil then
                record.tag = record.name or "神秘奖励"
                changed = true
            end
            if type(record.give) ~= "table" then
                record.give = {}
                changed = true
            end
            if record.ts == nil then
                record.ts = 0
                changed = true
            end
        else
            matData[day] = {day = dayNum, tag = "神秘奖励", give = {}, ts = 0}
            changed = true
        end
    end
    return matData, changed
end
-- 获取/初始化翻牌记录表，用于保存七天的各位数
local function fldt_prepare_flip_table(T_qrbq)
    if type(T_qrbq["7rqd_fp"]) ~= "table" then
        T_qrbq["7rqd_fp"] = {}
    end
    return T_qrbq["7rqd_fp"]
end
-- 将记录表中个位~百万位拼成最终元宝数
-- 将记录表中前N天数字拼成最终数字（默认前4天，最高9999）
local function fldt_calculate_flip_reward(fp, maxDays)
    local total = 0
    if type(fp) ~= "table" then
        return total
    end
    local n = tonumber(maxDays or fldt_number_days) or fldt_number_days
    if n < 1 then n = 1 end
    if n > 7 then n = 7 end
    for i = 1, n do
        local value = fp[i]
        if value == nil then
            value = fp[tostring(i)]
        end
        total = total + (tonumber(value) or 0) * (10 ^ (i - 1))
    end
    return total
end
-- 充值达到328档位的玩家，也可以领取全区首爆奖励。
local function fldt_has_qqsb_privilege(play)
    local czlb = json2tbl(getplaydef(play, VarCfg.T_czlb))
    if type(czlb) ~= "table" then
        czlb = {}
    end
    return tonumber(czlb["cz502_328"] or 0) == 1
end
-- 玩家自己的全区首爆达成记录。
local function fldt_get_qqsb_personal_map(play)
    local data = Player.getJsonTableByVar(play, VarCfg.T_grqqsb)
    if type(data) ~= "table" then
        data = {}
    end
    return data
end
-- 玩家自己的全区首爆领取记录，防止重复领取。
local function fldt_get_qqsb_claim_map(T_qrbq)
    if type(T_qrbq) ~= "table" then
        T_qrbq = {}
    end
    if type(T_qrbq["qqsb_claim"]) ~= "table" then
        T_qrbq["qqsb_claim"] = {}
    end
    return T_qrbq["qqsb_claim"]
end
-- 按当前玩家视角构建全区首爆奖励状态。
-- 0=未达成，1=可领取，2=已领取。
-- 领取规则：
-- 1. 该装备的全区首爆归属人可以直接领取。
-- 2. 不是首爆归属人时，必须自己打到过该装备，且达到328档位才可领取。
local function fldt_build_qqsb_view(play, T_qrbq, qqsb)
    local reward_cfg = (teshudata["fldt"] and teshudata["fldt"]["qqsb"]) or {}
    local claim_map = fldt_get_qqsb_claim_map(T_qrbq)
    local personal_map = fldt_get_qqsb_personal_map(play)
    local has_privilege = fldt_has_qqsb_privilege(play)
    local player_name = tostring(getbaseinfo(play, 1) or "")
    local view = {}
    local can_claim = false
    for idx in pairs(reward_cfg) do
        local key = tostring(idx)
        local global_owner = qqsb[key]
        if global_owner == nil then
            global_owner = qqsb[idx]
        end
        local claimed = claim_map[key]
        if claimed == nil then
            claimed = claim_map[idx]
        end
        local personal_ok = personal_map[key]
        if personal_ok == nil then
            personal_ok = personal_map[idx]
        end
        local is_first_owner = type(global_owner) == "string" and global_owner == player_name
        local can_take = false
        if global_owner ~= nil and tonumber(claimed or 0) ~= 1 then
            if is_first_owner then
                can_take = true
            elseif has_privilege and tonumber(personal_ok or 0) == 1 then
                can_take = true
            end
        end
        local status = 0
        if global_owner ~= nil then
            if tonumber(claimed or 0) == 1 then
                status = 2
            elseif can_take then
                status = 1
                can_claim = true
            end
        end
        view[key] = status
    end
    return view, can_claim, claim_map
end
npc[511] = function(play, p2, p3, msgData) --福利大厅
    -- p2 用于区分界面打开(0)、奖励领取(1)及数据下发(2)
    -- p3 则在 p2==1/2 时作为具体子功能编号（1=七日登录、2=在线奖励、3=杀怪等）
    if p2 == 0 then
        local data = {}
        local T_qrbq = Player.getJsonTableByVar(play, VarCfg.T_qrbq)
        local _, matChanged = fldt_prepare_material_table(T_qrbq)
        if matChanged then
            Player.setJsonVarByTable(play, VarCfg.T_qrbq, T_qrbq)
        end
        data["T_qrbq"] = T_qrbq
        data["U_dlts"] = getplaydef(play, VarCfg["U_登录天数"])
        data["J_zxsj"] = getplaydef(play, VarCfg.J_zxsj)
        data["U_sgsl"] = getplaydef(play, VarCfg.J_jsgw[1]) + getplaydef(play, VarCfg.J_jsgw[2])
        local T_grss = Player.getJsonTableByVar(play, VarCfg.T_grss) or {}
        local T_grsb = Player.getJsonTableByVar(play, VarCfg.T_grsb) or {}
        local grss_can_claim = false
        local grsb_can_claim = false
        for _, status in pairs(T_grss) do
            if tonumber(status or 0) == 1 then
                grss_can_claim = true
                break
            end
        end
        for _, status in pairs(T_grsb) do
            if tonumber(status or 0) == 1 then
                grsb_can_claim = true
                break
            end
        end
        local T_qqsb = Player.getJsonTableByVar(nil, VarCfg["A_全区首曝json"]) or {}
        local _, qqsb_can_claim = fldt_build_qqsb_view(play, T_qrbq, T_qqsb)
        data["grss_can_claim"] = grss_can_claim
        data["grsb_can_claim"] = grsb_can_claim
        data["qqsb_can_claim"] = qqsb_can_claim
        data["qqsb_has_328"] = fldt_has_qqsb_privilege(play) and 1 or 0
        sendluamsg(play, 101, 511, 0, 0, tbl2json(data))
        sendluamsg(play, 101, 511, 10, 0, tbl2json(T_qqsb))
    elseif p2 == 1 then
        -- 福利大厅任务进度存放在玩家 T_qrbq 变量中，包含七日登录/在线/杀怪等字段
        local T_qrbq = Player.getJsonTableByVar(play, VarCfg.T_qrbq)
        if p3 == 1 then --七日登录
            local jsonData = json2tbl(msgData) or {}
            local requestDay = tonumber(jsonData["7rqd"]) or 0
            local loginDays = tonumber(getplaydef(play, VarCfg["U_登录天数"])) or 0
            if requestDay > loginDays then
                Player.sendmsgEx(play, "登录天数不足#57")
                return
            end
            local claimed = tonumber(T_qrbq["7rqd"]) or 0
            local targetDay = claimed + 1
            if targetDay > requestDay then
                Player.sendmsgEx(play, "已经领取完毕#57")
                return
            end
            if targetDay ~= requestDay then
                Player.sendmsgEx(play, "请按照顺序领取#57")
                return
            end
            if requestDay <= 0 or requestDay > 7 then
                Player.sendmsgEx(play, "七日登录奖励已经全部领取完毕#57")
                return
            end
            local dayReward = teshudata["fldt"]["7rqd"][targetDay]
            if not dayReward then
                Player.sendmsgEx(play, "奖励配置缺失#57")
                return
            end
            local privilege = fldt_is_privilege(play)
            local flipDigits = fldt_prepare_flip_table(T_qrbq)
            local finalAwardToGive = 0
            if targetDay <= fldt_number_days then
                local digit = fldt_pick_seven_login_digit(targetDay)
                flipDigits[targetDay] = digit
            else
                local matData = fldt_prepare_material_table(T_qrbq)
                local matRecord = matData[targetDay]
                if matRecord == nil then
                    local oldKey = tostring(targetDay)
                    matRecord = matData[oldKey]
                    if matRecord ~= nil then
                        matData[oldKey] = nil
                    end
                end
                if type(matRecord) ~= "table" then
                    local matReward, matTag = fldt_pick_material_reward(targetDay, play, privilege)
                    matRecord = {
                        day = targetDay,
                        tag = matTag or "神秘奖励",
                        give = fldt_clone_reward_list(matReward),
                        ts = os.time(),
                    }
                else
                    matRecord.day = tonumber(matRecord.day) or targetDay
                    matRecord.tag = matRecord.tag or matRecord.name or "神秘奖励"
                    if type(matRecord.give) ~= "table" then
                        matRecord.give = {}
                    end
                    if matRecord.ts == nil then
                        matRecord.ts = os.time()
                    end
                end
                matData[targetDay] = matRecord
                if type(matRecord.give) == "table" and #matRecord.give > 0 then
                    Player.rwjl(play, matRecord.give, "七日翻牌神秘奖励", 1)
                end
            end
            T_qrbq["7rqd"] = targetDay
            if targetDay == fldt_number_days then
                local finalSum = fldt_calculate_flip_reward(flipDigits, fldt_number_days)
                T_qrbq["7rqd_final_yb"] = finalSum
                local finalMultiple = privilege and fldt_privilege_final_multiple or 1
                T_qrbq["7rqd_final_mul"] = finalMultiple
                local awardValue = math.floor((finalSum or 0) * fldt_final_reward_multiplier * finalMultiple)
                local cap = privilege and fldt_final_reward_cap_privilege or fldt_final_reward_cap
                if cap > 0 and awardValue > cap then
                    awardValue = cap
                end
                if awardValue < 0 then
                    awardValue = 0
                end
                T_qrbq["7rqd_final_award"] = awardValue
                if T_qrbq["7rqd_final_awarded"] ~= 1 then
                    T_qrbq["7rqd_final_awarded"] = 1
                    finalAwardToGive = awardValue
                end
            end
            Player.setJsonVarByTable(play, VarCfg.T_qrbq, T_qrbq)
            sendmail(getbaseinfo(play,2),0,"七日登录奖励","七日登录奖励,奖励已下发!",Player.jl_mail(dayReward.jl))
            if finalAwardToGive > 0 then
                Player.rwjl(play, { { "绑定元宝", finalAwardToGive } }, "七日翻牌幸运奖励", 1)
            end
            sendluamsg(play, 101, 511, 1, 1, tbl2json(T_qrbq))
        elseif p3 == 2 then --在线奖励
            -- 累计在线分钟数存储在 VarCfg.J_zxsj，对应配置 teshudata["fldt"]["zxjl"]
            local jsonData = json2tbl(msgData)
            T_qrbq["zxjl"] = T_qrbq["zxjl"] or 0
            T_qrbq["zxjl"] = T_qrbq["zxjl"] + 1
            if teshudata["fldt"]["zxjl"][T_qrbq["zxjl"]].time > getplaydef(play, VarCfg.J_zxsj) then
                Player.sendmsgEx(play, "在线时间不足#57")
                return
            elseif T_qrbq["zxjl"] > jsonData["zxjl"] then
                Player.sendmsgEx(play, "已经领取完毕#57")
                return
            end
            if T_qrbq["zxjl"] == jsonData["zxjl"] then
                if jsonData["zxjl"] <= #teshudata["fldt"]["zxjl"] then
                    Player.setJsonVarByTable(play, VarCfg.T_qrbq, T_qrbq)
                    Player.rwjl(play, teshudata["fldt"]["zxjl"][T_qrbq["zxjl"]].jl, "在线奖励", 1)
                    sendluamsg(play, 101, 511, 1, 1, tbl2json(T_qrbq))
                else
                    Player.sendmsgEx(play, "在线奖励已经全部领取完毕#57")
                end
            else
                Player.sendmsgEx(play, "请按照顺序领取#57")
            end
        elseif p3 == 3 then --杀怪奖励
            -- VarCfg.U_fldt[2] 记录玩家今日杀怪量，对应 teshudata["fldt"]["sgjl"] 的领取进度
            local jsonData = json2tbl(msgData) or {}
            T_qrbq["sgjl"] = T_qrbq["sgjl"] or 0
            T_qrbq["sgjl"] = T_qrbq["sgjl"] + 1
            if teshudata["fldt"]["sgjl"][T_qrbq["sgjl"]].num > getplaydef(play, VarCfg.J_jsgw[1]) + getplaydef(play, VarCfg.J_jsgw[2]) then
                Player.sendmsgEx(play, "杀怪数量不足#57")
                return
            elseif T_qrbq["sgjl"] > jsonData["sgjl"] then
                Player.sendmsgEx(play, "已经领取完毕#57")
                return
            end
            if T_qrbq["sgjl"] == jsonData["sgjl"] then
                if jsonData["sgjl"] <= #teshudata["fldt"]["sgjl"] then
                    Player.setJsonVarByTable(play, VarCfg.T_qrbq, T_qrbq)
                    Player.rwjl(play, teshudata["fldt"]["sgjl"][T_qrbq["sgjl"]].jl, "杀怪奖励", 1)
                    sendluamsg(play, 101, 511, 1, 1, tbl2json(T_qrbq))
                else
                    Player.sendmsgEx(play, "杀怪奖励已经全部领取完毕#57")
                end
            else
                Player.sendmsgEx(play, "请按照顺序领取#57")
            end
        elseif p3 == 4 then --个人首杀
            -- T_grss 保存个人首杀任务状态：1=已完成待领，2=已领取，键为怪物ID
            local jsonData = json2tbl(msgData) or {}
            local T_grss = Player.getJsonTableByVar(play, VarCfg.T_grss)
            if tonumber(jsonData["isall"]) == 1 then
                if type(T_grss) ~= "table" then
                    T_grss = {}
                end
                local rewardCfg = teshudata["fldt"] and teshudata["fldt"]["grss"] or {}
                local rewardList = {}
                for key, status in pairs(T_grss) do
                    if status == 1 then
                        local index = tonumber(key)
                        local cfg = index and rewardCfg[index]
                        if cfg then
                            T_grss[key] = 2
                            rewardList[#rewardList + 1] = cfg.give
                        end
                    end
                end
                if #rewardList > 0 then
                    Player.setJsonVarByTable(play, VarCfg.T_grss, T_grss)
                    sendluamsg(play, 101, 511, 2, 4, tbl2json(T_grss))
                    for _, give in ipairs(rewardList) do
                        Player.rwjl(play, give, "个人首杀奖励", 1, 0)
                    end
                else
                    Player.sendmsgEx(play, "未完成该首杀任务#57")
                end
                return
            end
            if T_grss[jsonData["grss"]] and T_grss[jsonData["grss"]] == 2 then
                Player.sendmsgEx(play, "该首杀奖励已经领取完毕#57")
                return
            end
            if T_grss[jsonData["grss"]] and T_grss[jsonData["grss"]] == 1 then
                T_grss[jsonData["grss"]] = 2
                Player.setJsonVarByTable(play, VarCfg.T_grss, T_grss)
                Player.rwjl(
                    play,
                    teshudata["fldt"]["grss"][tonumber(jsonData["grss"])].give,
                    "个人首杀奖励",
                    1,
                    0
                )
                sendluamsg(play, 101, 511, 2, 4, tbl2json(T_grss))
            else --未完成
                Player.sendmsgEx(play, "未完成该首杀任务#57")
                return
            end
        elseif p3 == 5 then --个人首爆
            -- T_grsb 结构与首杀类似，表示个人首爆奖励的完成/领取状态
            local jsonData = json2tbl(msgData) or {}
            local T_grsb = Player.getJsonTableByVar(play, VarCfg.T_grsb)
            if tonumber(jsonData["isall"]) == 1 then
                if type(T_grsb) ~= "table" then
                    T_grsb = {}
                end
                local rewardCfg = teshudata["fldt"] and teshudata["fldt"]["grsb"] or {}
                local rewardList = {}
                for key, status in pairs(T_grsb) do
                    if status == 1 then
                        local index = tonumber(key)
                        local cfg = index and rewardCfg[index]
                        if cfg then
                            T_grsb[key] = 2
                            rewardList[#rewardList + 1] = cfg.give
                        end
                    end
                end
                if #rewardList > 0 then
                    Player.setJsonVarByTable(play, VarCfg.T_grsb, T_grsb)
                    sendluamsg(play, 101, 511, 2, 5, tbl2json(T_grsb))
                    for _, give in ipairs(rewardList) do
                        Player.rwjl(play, give, "个人首爆奖励", 1, 0)
                    end
                else
                    Player.sendmsgEx(play, "未完成该首爆任务#57")
                end
                return
            end
            if T_grsb[jsonData["grsb"]] and T_grsb[jsonData["grsb"]] == 2 then
                Player.sendmsgEx(play, "该首爆奖励已经领取完毕#57")
                return
            end
            if T_grsb[jsonData["grsb"]] and T_grsb[jsonData["grsb"]] == 1 then
                T_grsb[jsonData["grsb"]] = 2
                Player.setJsonVarByTable(play, VarCfg.T_grsb, T_grsb)
                Player.rwjl(
                    play,
                    teshudata["fldt"]["grsb"][tonumber(jsonData["grsb"])].give,
                    "个人首爆奖励",
                    1,
                    0
                )
                sendluamsg(play, 101, 511, 2, 5, tbl2json(T_grsb))
            else --未完成
                Player.sendmsgEx(play, "未完成该首爆任务#57")
                return
            end
        elseif p3 == 6 then --全区首爆
            local jsonData = json2tbl(msgData) or {}
            local qqsb = Player.getJsonTableByVar(nil, VarCfg["A_全区首曝json"])
            if type(qqsb) ~= "table" then
                qqsb = {}
            end
            local rewardCfg = teshudata["fldt"] and teshudata["fldt"]["qqsb"] or {}
            local qqsb_view, _, qqsb_claim_map = fldt_build_qqsb_view(play, T_qrbq, qqsb)
            if tonumber(jsonData["isall"]) == 1 then
                local rewardList = {}
                for idx, cfg in pairs(rewardCfg) do
                    local key = tostring(idx)
                    if tonumber(qqsb_view[key] or 0) == 1 then
                        qqsb_claim_map[key] = 1
                        rewardList[#rewardList + 1] = cfg.give
                    end
                end
                if #rewardList > 0 then
                    Player.setJsonVarByTable(play, VarCfg.T_qrbq, T_qrbq)
                    local new_view = fldt_build_qqsb_view(play, T_qrbq, qqsb)
                    sendluamsg(play, 101, 511, 2, 6, tbl2json(new_view))
                    for _, give in ipairs(rewardList) do
                        Player.rwjl(play, give, "全区首爆奖励", 1, 0)
                    end
                else
                    Player.sendmsgEx(play, "当前没有可领取的全区首爆奖励#57")
                end
                return
            end
-- 单个领取时，只更新当前玩家自己的领取记录。
            local qqsb_idx = tostring(jsonData["qqsb"] or "")
            if qqsb_idx == "" or tonumber(qqsb_view[qqsb_idx] or 0) ~= 1 then
                if tonumber(qqsb_view[qqsb_idx] or 0) == 2 then
                    Player.sendmsgEx(play, "该全区首爆奖励已经领取完毕#57")
                else
                    Player.sendmsgEx(play, "未完成该全区首爆任务#57")
                end
                return
            end
            qqsb_claim_map[qqsb_idx] = 1
            Player.setJsonVarByTable(play, VarCfg.T_qrbq, T_qrbq)
            Player.rwjl(
                play,
                teshudata["fldt"]["qqsb"][tonumber(qqsb_idx)].give,
                "全区首爆奖励",
                1,
                0
            )
            local new_view = fldt_build_qqsb_view(play, T_qrbq, qqsb)
            sendluamsg(play, 101, 511, 2, 6, tbl2json(new_view))
        end
    elseif p2 == 2 then
        if p3 == 4 then --个人首杀
            local T_grss = Player.getJsonTableByVar(play, VarCfg.T_grss)
            sendluamsg(play, 101, 511, 2, 4, tbl2json(T_grss))
        elseif p3 == 5 then
            local T_grsb = Player.getJsonTableByVar(play, VarCfg.T_grsb)
            sendluamsg(play, 101, 511, 2, 5, tbl2json(T_grsb))
        elseif p3 == 6 then
            local T_qrbq = Player.getJsonTableByVar(play, VarCfg.T_qrbq) or {}
            local qqsb = Player.getJsonTableByVar(nil, VarCfg["A_全区首曝json"])
            if type(qqsb) ~= "table" then
                qqsb = {}
            end
            local data = fldt_build_qqsb_view(play, T_qrbq, qqsb)
            sendluamsg(play, 101, 511, 2, 6, tbl2json(data))
        end
    end
end
npc[512] = function(play, p2, p3, msgData) --游戏攻略
    if p2 == 0 then
        sendluamsg(play, 101, 512, 0, 0, "")
    end
end
npc[513] = function(play, p2, p3, msgData) --狂暴
    if p2 == 0 then
        sendluamsg(play, 100, 15, 0, 0, "")
    end
end
npc[514] = function(play, p2, p3, msgData) --世界地图
    if p2 == 0 then
        sendluamsg(play, 101, 514, 0, 0, "")
    end
end
npc[515] = function(play, p2, p3, msgData)
    FairyFate.handle(play, p2, p3, msgData)
end
local function _zz516_get_cfg()
    return (teshudata["anniu_516"] and teshudata["anniu_516"].details) or {}
end
local function _zz516_get_data(play)
    local data = Player.getJsonTableByVar(play, VarCfg["T_免费赞助"])
    if type(data) ~= "table" then
        data = {}
    end
    return data
end
local function _zz516_get_charge(play)
    local charge23 = tonumber(querymoney(play, 23) or 0) or 0
    local realCharge = tonumber(getplaydef(play, VarCfg["U_真实充值"]) or 0) or 0
    return math.max(charge23, realCharge), charge23
end
local function _zz516_check_cfg(play, config)
    local needCz502 = tonumber((config or {}).need_cz502 or 0) or 0
    if needCz502 > 0 then
        local czlb = json2tbl(getplaydef(play, VarCfg.T_czlb))
        if type(czlb) ~= "table" then
            czlb = {}
        end
        return tonumber(czlb["cz502_" .. needCz502] or 0) == 1
    end
    local totalCharge, charge23 = _zz516_get_charge(play)
    local needCharge = tonumber((config or {}).need_charge or (config or {}).sgsl or 0) or 0
    local needMoney23 = tonumber((config or {}).need_money23 or 0) or 0
    return (needMoney23 > 0 and charge23 >= needMoney23) or (needMoney23 <= 0 and totalCharge >= needCharge)
end
local function _zz516_get_claim_tier(T_data)
    local cfg = _zz516_get_cfg()
    for i = #cfg, 1, -1 do
        if tonumber((T_data or {})["zzlb_" .. i] or 0) == 1 then
            return i, cfg[i]
        end
    end
    return 0, nil
end
local function _zz516_clear_titles(play, keep_title)
    local cfg = _zz516_get_cfg()
    keep_title = tostring(keep_title or "")
    for i = 1, #cfg do
        local titleName = tostring((cfg[i] or {}).ch or "")
        if titleName ~= "" and titleName ~= keep_title and checktitle(play, titleName) then
            deprivetitle(play, titleName)
        end
    end
end
local function _zz516_apply_title(play, T_data)
    local _, cfg = _zz516_get_claim_tier(T_data or _zz516_get_data(play))
    local keep_title = cfg and tostring(cfg.ch or "") or ""
    _zz516_clear_titles(play, keep_title)
    if keep_title ~= "" and not checktitle(play, keep_title) then
        Player.title_give(play, keep_title)
    end
end
local function _zz516_panel_data(play)
    local data = {}
    local T_data = _zz516_get_data(play)
    local charge, charge23 = _zz516_get_charge(play)
    data["T_data"] = T_data
    data["sgsl"] = charge
    data["charge"] = charge
    data["money23"] = charge23
    data["tier"] = _zz516_get_claim_tier(T_data)
    return data
end
local function _zz516_send_panel(play, p2, p3)
    sendluamsg(play, 101, 516, p2 or 0, p3 or 0, tbl2json(_zz516_panel_data(play)))
end
local function _zz516_login(play)
    _zz516_apply_title(play, _zz516_get_data(play))
end
GameEvent.add(EventCfg.onLogin, _zz516_login, "至尊赞助")
--至尊赞助
npc[516] = function(play, p2, p3, msgData) --至尊赞助
    if p2 == 0 then
        _zz516_send_panel(play, 0, 0)
    elseif p2 == 1 then
        local idx = tonumber(p3 or 0) or 0
        local cfg = _zz516_get_cfg()
        local config = cfg[idx]
        local T_data = _zz516_get_data(play)
        local key = "zzlb_" .. idx
        if not config then
            return
        end
        if tonumber(T_data[key] or 0) == 1 then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff7700\'>[至尊赞助]</font><font color=\'#ff0500\'>已经领取过该档奖励...</font>","Type":9}')
            return
        end
        if idx > 1 and tonumber(T_data["zzlb_" .. (idx - 1)] or 0) ~= 1 then
            Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff7700\'>[至尊赞助]</font><font color=\'#ff0500\'>请先领取前一档奖励...</font>","Type":9}')
            return
        end
        local canClaim = _zz516_check_cfg(play, config)
        if not canClaim then
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff7700\'>[至尊赞助]</font><font color=\'#ff0500\'>当前条件不足,无法领取...</font>","Type":9}')
            return
        end
        T_data[key] = 1
        Player.setJsonVarByTable(play, VarCfg["T_免费赞助"], T_data)
        if rwcf[516] and rwcf[516][1] == getplaydef(play, VarCfg.U_zxrw[1]) then
            Player.zxrw_wancheng(play, rwcf[516][1], "任务")
            sendluamsg(play, 101, 9999, 0, 0, "npc_anniu_516")
        end
        _zz516_apply_title(play, T_data)
        if type(config.jl) == "table" and #config.jl > 0 then
            Player.rwjl(play, config.jl, "至尊赞助奖励", 1)
        end
        sendmsg(play, 1, '{"Msg":"<font color=\'#ff7700\'>[至尊赞助]</font><font color=\'#28ef01\'>领取成功...</font>","Type":9}')
        _zz516_send_panel(play, 1, idx)
    end
end
--聚宝盆
npc[517] = function(play, p2, p3, msgData) --聚宝盆
    if p2 == 0 then
        local data = {}
        data["T_data"] = Player.getJsonTableByVar(play, VarCfg["T_聚宝盆"])
        data["T_data"].level = data["T_data"].level or 1
        data["jf"] = getplaydef(play, VarCfg["U_聚宝盆积分"])
        data["cs"] = getplaydef(play, VarCfg["J_聚宝盆领取次数"])
        sendluamsg(play, 101, 517, 0, 0, tbl2json(data))
    elseif p2 == 1 then
        -- 聚宝盆升级
        local T_data = Player.getJsonTableByVar(play, VarCfg["T_聚宝盆"])
        T_data.level = T_data.level or 1
        if T_data.level == 1 then
            local T_sc_data = Player.getJsonTableByVar(play, VarCfg["T_首冲礼包"])
            if T_sc_data["首充"] == 1 then
                T_data.level = 2
                Player.setJsonVarByTable(play, VarCfg["T_聚宝盆"], T_data)
                sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[聚宝盆]</font><font color=\'#28ef01\'>升级成功...</font>","Type":9}' )
                sendluamsg(play, 101, 517, 1, 2, "")
            else
                sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[聚宝盆]</font><font color=\'#ff0500\'>只有首充后才可升级聚宝盆...</font>","Type":9}' )
                return
            end
        elseif T_data.level == 2 then
            if getflagstatus(play, VarCfg.BS_mztq) == 1 then
                T_data.level = 3
                Player.setJsonVarByTable(play, VarCfg["T_聚宝盆"], T_data)
                sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[聚宝盆]</font><font color=\'#28ef01\'>升级成功...</font>","Type":9}' )
                sendluamsg(play, 101, 517, 1, 3, "")
            else
                sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[聚宝盆]</font><font color=\'#ff0500\'>未激活【超级特权】,无法升级聚宝盆...</font>","Type":9}' )
                return
            end
        elseif T_data.level == 3 then --累计充值 200
            if querymoney(play, 23) >= 200 then
                T_data.level = 4
                Player.setJsonVarByTable(play, VarCfg["T_聚宝盆"], T_data)
                sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[聚宝盆]</font><font color=\'#28ef01\'>升级成功...</font>","Type":9}' )
                sendluamsg(play, 101, 517, 1, 4, "")
            else
                sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[聚宝盆]</font><font color=\'#ff0500\'>累计充值200元才能升级聚宝盆...</font>","Type":9}' )
                return
            end
        elseif T_data.level == 4 then --累计充值 300
            if querymoney(play, 23) >= 300 then
                T_data.level = 5
                Player.setJsonVarByTable(play, VarCfg["T_聚宝盆"], T_data)
                sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[聚宝盆]</font><font color=\'#28ef01\'>升级成功...</font>","Type":9}' )
                sendluamsg(play, 101, 517, 1, 5, "")
            else
                sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[聚宝盆]</font><font color=\'#ff0500\'>累计充值300元才能升级聚宝盆...</font>","Type":9}' )
                return
            end
        elseif T_data.level == 5 then --满级
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff7700\'>[聚宝盆]</font><font color=\'#ff0500\'>聚宝盆已经满级...</font>","Type":9}')
            return
        end
    elseif p2 == 2 then -- 聚宝盆领取奖励
        local T_data = Player.getJsonTableByVar(play, VarCfg["T_聚宝盆"])
        T_data.level = T_data.level or 1
        local config = Guard.getConfig("anniu_517").details[T_data.level]
        local jf = getplaydef(play, VarCfg["U_聚宝盆积分"])
        local cs = getplaydef(play, VarCfg["J_聚宝盆领取次数"])
        if cs < config.maxcs then
            if jf >= config.jf then
                setplaydef(play, VarCfg["U_聚宝盆积分"], 0)
                setplaydef(play, VarCfg["J_聚宝盆领取次数"], cs + 1)
                Player.rwjl(play, config.give, "聚宝盆奖励", 1)
                sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[聚宝盆]</font><font color=\'#28ef01\'>领取成功...</font>","Type":9}' )
                sendluamsg(play, 101, 517, 2, 0, "")
            else
                sendmsg(play,1,'{"Msg":"<font color=\'#ff7700\'>[聚宝盆]</font><font color=\'#ff0500\'>积分不足,无法领取奖励...</font>","Type":9}' )
                return
            end
        else
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff7700\'>[聚宝盆]</font><font color=\'#ff0500\'>当前等级领取次数已达上限...</font>","Type":9}')
            return
        end
    end
end
local xlxl =
    { { 1, 2, 3, 4, 7, 8, 23, 22, 24, 25, 26 }, constant.cz_je, { 98, 6, 3 } }
npc[998] = function(play, p2, p3, msg) --后台
    local qfmz = getconst(play, "<$SERVERNAME>")
    if getplaydef(play, VarCfg.S_houtaibf) ~= "" or (qfmz == "" or qfmz == "测试区") then
        if getplaydef(play, VarCfg.S_houtaibf) == "" and (qfmz == "" or qfmz == "测试区") then
            setplaydef(play, VarCfg.S_houtaibf, "本地测试区")
        end
        if p2 == 1 then
            if p3 == 0 then
                if getplayerbyname(msg) then
                    Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#00ff00\'>[' .. msg .. ']玩家在线</font>","Type":9}')
                else
                    Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0000\'>[' .. msg .. ']玩家不在线</font>","Type":9}')
                end
            elseif p3 == 1 then
                local data = json2tbl(msg)
                if data and data.mz and data.hb and data.hb > 0 and data.hb < 9 then
                    local dx = getplayerbyname(data.mz)
                    if dx then
                        Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#00ff00\'>[' .. data.mz .. "]货币剩余：" .. querymoney(dx, xlxl[1][data.hb]) .. '</font>","Type":9}')
                    else
                        Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0000\'>[' .. data.mz .. ']玩家不在线</font>","Type":9}')
                    end
                end
            elseif p3 == 2 or p3 == 3 then
                local data = json2tbl(msg)
                if data and data.mz and data.hb and data.hb > 0 and data.hb < 12 and data.sl then
                    local dx = getplayerbyname(data.mz)
                    if dx then
                        local hbid = xlxl[1][data.hb]
                        if p3 == 2 then
                            changemoney(dx, hbid, "=", data.sl, "后台", true)
                            Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#00ff00\'>[' .. data.mz .. "]货币数量修改为[" .. data.sl .. ']</font>","Type":9}')
                        else
                            changemoney(dx, hbid, "+", data.sl, "后台", true)
                            Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#00ff00\'>[' .. data.mz .. "]增加[" .. data.sl .. "]当前货币剩余：" .. querymoney(dx, xlxl[1][data.hb]) .. '</font>","Type":9}')
                        end
                    else
                        Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0000\'>[' .. data.mz .. ']玩家不在线</font>","Type":9}')
                    end
                end
            elseif p3 == 4 then
                local data = json2tbl(msg)
                if data and data.mz and data.hb and data.hb > 0 and data.hb < 11 then
                    local dx, sy = getplayerbyname(data.mz), data.hb
                    if dx then
                        setplaydef(dx, VarCfg.U_czyz, data.hb)
                        changemoney(dx, 7, "+", xlxl[2][data.hb] * 10, "", true)
                        recharge(dx, xlxl[2][data.hb], "gm", 7, false)
                        Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#28ef01\'>[' .. data.mz .. ']发送礼包成功</font>","Type":9}')
                    else
                        Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0000\'>[' .. data.mz .. ']玩家不在线</font>","Type":9}')
                    end
                end
            elseif p3 == 5 then
                local data = json2tbl(msg)
                if data and data.mz and data.hb and data.hb > 0 and data.hb < 11 then
                    local dx, sy = getplayerbyname(data.mz), data.hb
                    if dx then
                        recharge(dx, xlxl[3][data.hb], "gm", 21, false)
                        Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#28ef01\'>[' .. data.mz .. ']发送礼包成功</font>","Type":9}')
                    else
                        Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0000\'>[' .. data.mz .. ']玩家不在线</font>","Type":9}')
                    end
                end
            end
        elseif p2 == 2 then
            local data = json2tbl(msg)
            if p3 == 5 then
                setcastleguild(data.ch, 0)
                return
            end
            if data and data.mz then
                local dx = getplayerbyname(data.mz)
                if dx then
                    if getstditeminfo(data.wp, 1) == data.wp then
                        if p3 == 1 then
                            if data.lx then
                                giveitem(dx, data.wp, data.sl, data.lx == 1 and 850 or 0)
                                Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#28ef01\'>[' .. data.wp .. ']增加完成</font>","Type":9}')
                            end
                        elseif p3 == 2 then
                            takeitem(dx, data.wp, data.sl)
                            Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#00ff00\'>[' .. data.wp .. ']扣除完成</font>","Type":9}')
                        elseif p3 == 4 then
                            if checktitle(dx, data.ch) then
                                sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>拿...</font>","Type":9}')
                                Player.title_del(dx, data.ch)
                            else
                                sendmsg(play, 1, '{"Msg":"<font color=\'#00ff00\'>给...</font>","Type":9}')
                                Player.title_give(dx, data.ch)
                            end
                        end
                    else
                        Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0000\'>物品名字不正确</font>","Type":9}')
                    end
                else
                    Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0000\'>[' .. data.mz .. ']玩家不在线</font>","Type":9}')
                end
            end
        elseif p2 == 3 then
            local data = json2tbl(msg)
            if data and data.mz and data.bl and data.lx > 0 then
                local dx = getplayerbyname(data.mz)
                if data.lx ~= 4 then
                    if dx then
                        if p3 == 1 then
                            if data.lx == 1 then
                                if data.bl == "积分" then
                                    Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#00ff00\'>[' .. data.mz .. "]礼包积分剩余：" .. querymoney(dx, 22) .. '</font>","Type":9}')
                                elseif
                                    string.find(data.bl, "t")
                                    or string.find(data.bl, "T")
                                    or string.find(data.bl, "S")
                                then
                                    mircopy(play, getplaydef(dx, data.bl))
                                    messagebox(play, "[" .. data.bl .. "]的值\\" .. getplaydef(dx, data.bl) .. "")
                                else
                                    Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#00ff00\'>[' .. data.bl .. "]的值[" .. getplaydef(dx, data.bl) .. ']</font>","Type":9}')
                                end
                            elseif data.lx == 2 then
                                Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#00ff00\'>标识：[' .. data.bl .. "]的值[" .. getflagstatus(dx, data.bl) .. ']</font>","Type":9}')
                            elseif data.lx == 3 then
                                if hasbuff(dx, data.bl) then
                                    Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#00ff00\'>buff:[' .. data.bl .. "]的值[" .. math.floor((getbuffinfo(dx, data.bl, 2) / 60)) .. '分钟]</font>","Type":9}')
                                else
                                    Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0000\'>[' .. data.mz .. ']玩家没有这个BUFF</font>","Type":9}')
                                end
                            end
                        else
                            if data.zhi then
                                if data.lx == 1 then
                                    if data.bl == "积分" then
                                        changemoney(dx, 22, "+", data.zhi, "后台", true)
                                        Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#00ff00\'>[' .. data.mz .. "]增加[" .. data.zhi .. "]当前礼包积分剩余：" .. querymoney(dx, 22) .. '</font>","Type":9}')
                                    else
                                        setplaydef(dx, data.bl, data.zhi)
                                        Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#00ff00\'>[' .. data.bl .. "]的值[" .. getplaydef(dx, data.bl) .. ']</font>","Type":9}')
                                    end
                                elseif data.lx == 2 then
                                    setflagstatus(dx, data.bl, data.zhi)
                                    Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#00ff00\'>标识：[' .. data.bl .. "]的值[" .. getflagstatus(dx, data.bl) .. ']</font>","Type":9}')
                                elseif data.lx == 3 then
                                    Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0500\'>BUFF只能查询</font>","Type":9}')
                                end
                            end
                        end
                    else
                        Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0000\'>[' .. data.mz .. ']玩家不在线</font>","Type":9}')
                    end
                elseif data.lx == 4 then
                    if p3 == 1 then
                        if string.find(data.bl, "A") or string.find(data.bl, "a") then
                            messagebox(play, "[" .. data.bl .. "]的值\\" .. getsysvar(data.bl) .. "")
                        else
                            Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#00ff00\'>[' .. data.bl .. "]的值[" .. getsysvar(data.bl) .. ']</font>","Type":9}')
                        end
                    elseif p3 == 2 then
                        if data.zhi then
                            setsysvar(data.bl, data.zhi)
                            Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#00ff00\'>[' .. data.bl .. "]的值[" .. getsysvar(data.bl) .. ']</font>","Type":9}')
                        end
                    end
                end
            end
        elseif p2 == 4 then
            if msg ~= "" then
                local dx = getplayerbyname(msg)
                if p3 == 1 then
                    if dx then
                        kick(dx)
                        Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#28ef01\'>[' .. msg .. ']踢下线</font>","Type":9}')
                    else
                        Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0000\'>[' .. msg .. ']玩家不在线</font>","Type":9}')
                    end
                elseif p3 < 4 then
                    setgmlevel(play, 10)
                    if p3 == 2 then
                        gmexecute(play, "DenyCharNameLogon", msg, 1)
                        Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#28ef01\'>[' .. msg .. ']加入封禁列表</font>","Type":9}')
                        if dx then
                            callscriptex(dx, "CHANGELEVEL", "=", 1)
                        end
                    elseif p3 == 3 then
                        gmexecute(play, "DelDenyCharNameLogon", msg)
                        Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#28ef01\'>[' .. msg .. ']去除封禁列表</font>","Type":9}')
                    end
                    setgmlevel(play, 0)
                end
            end
            if p3 == 4 then
                setgmlevel(play, 10)
                gmexecute(play, "ShowDenyCharNameLogon")
                setgmlevel(play, 0)
            end
        elseif p2 == 5 then
            local data = json2tbl(msg)
            if data and data.mz and data.hb and data.hb > 0 then
                local dx, sy = getplayerbyname(data.mz), data.hb
                if dx then
                    changemoney(dx, 7, "+", data.hb * 10, "", true)
                    recharge(dx, data.hb, "gm", 7, false)
                    Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#28ef01\'>[' .. data.mz .. ']发送礼包成功</font>","Type":9}')
                else
                    Player.sendmsgEx(play, 1, '{"Msg":"<font color=\'#ff0000\'>[' .. data.mz .. ']玩家不在线</font>","Type":9}')
                end
            end
        end
    end
end
npc[1004] = function(play, p2, p3, msg) --排行榜查询
    if p2 == 1 then
        local dx = getplayerbyid(msg)
        if dx then
            Player.sendmsgEx(dx, 1, '{"BColor":249,"FColor":255,"Msg":"<outline size=\'1\'><font color=\'#FFFF00\'></font>玩家<font color=\'#00ff00\'>[' .. getbaseinfo(play, 1) .. ']</font>在偷偷打量你</outline>","Type":1}')
            sendluamsg(play, 101, 1004, 0, 0, '{"userid":"' .. msg .. '","zdl":' .. querymoney(dx, 29) .. "}")
        else
            sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>玩家不在线</font>","Type":9}')
        end
    end
end
-- npc_guard: 自动加固按钮入口，所有按钮接口统一做玩家及参数校验。
local _npcGuardUnpack = (table and table.unpack) or unpack
for npcId, handler in pairs(npc) do
    if type(npcId) == "number" and type(handler) == "function" then
        npc[npcId] = (function(id, fn)
            return function(play, ...)
                if not Guard.ensurePlayer(play, id) then
                    return
                end
                local argc = select("#", ...)
                if argc >= 1 then
                    local args = { ... }
                    local normalized = Guard.normalizeAction(play, id, args[1])
                    if normalized == nil then
                        return
                    end
                    args[1] = normalized
                    if _npcGuardUnpack then
                        return fn(play, _npcGuardUnpack(args))
                    end
                    return fn(play, ...)
                end
                return fn(play, ...)
            end
        end)(npcId, handler)
    end
end
return npc

