--------------------爆率监听触发-------------------幸运爆率
function bl_zyjhl2(play,mingzi)
    local sj = json2tbl(getplaydef(play,VarCfg.T_xybl))
    if sj and not sj[mingzi] then
        sj[mingzi] = 1
        setplaydef(play,VarCfg.T_xybl,tbl2json(sj))
        return true
    end
    return false
end
--------------------爆率监听触发-------------------全服孤品
function bl_zyjhl3(play,mingzi)
    local data = Player.getJsonTableByVar(nil, VarCfg["A_全服孤品"])
    local hqcs = globalinfo(3)
    if querymoney(play,23) >= 1000 then
        if hqcs >= 3 then
            if data and not data[mingzi] then
                data[mingzi] = getbaseinfo(play,1)
                Player.setJsonVarByTable(nil, VarCfg["A_全服孤品"], data)
                if FairyFate and FairyFate.touch then
                    FairyFate.touch(play, "global_unique")
                end
                return true
            end
        end
    end
    return false
end
--------------------爆率监听触发-------------------八卦卷轴计数
function bl_zyjhl4(play,mingzi)
    local data = Player.getJsonTableByVar(play, VarCfg["T_物品掉落记录"])
    if not data then
        data = {}
    end
    local cnt = tonumber(data[mingzi]) or 0
    -- 前4个正常给；第5个起 50% 放行（表内命中后再二次判定）
    if cnt < 4 then
        data[mingzi] = cnt + 1
        Player.setJsonVarByTable(play, VarCfg["T_物品掉落记录"], data)
        return true
    end
    if math.random(100) > 50 then
        data[mingzi] = cnt + 1
        Player.setJsonVarByTable(play, VarCfg["T_物品掉落记录"], data)
        return true
    end
    return false
end
--------------------爆率监听触发-------------------杀伐神石
function bl_zyjhl5(play,mingzi)
    -- 大：真实充值>200才可爆（表内已配置 1/1555）
    if mingzi == "杀伐神石[大]" then
        if getplaydef(play, VarCfg["U_真实充值"]) <= 200 then
            return false
        end
        return true
    end
    -- 小：天书等级条件
    local tdata = Player.getJsonTableByVar(play, VarCfg["T_天书"])
    local level = 0
    if tdata and tdata.level then
        level = tonumber(tdata.level) or 0
    end
    if level < 10 then
        -- 10级前最多给2颗（表内爆率 1/200）
        local data = Player.getJsonTableByVar(play, VarCfg["T_物品掉落记录"])
        if not data then
            data = {}
        end
        local cnt = tonumber(data[mingzi]) or 0
        if cnt >= 2 then
            return false
        end
        data[mingzi] = cnt + 1
        Player.setJsonVarByTable(play, VarCfg["T_物品掉落记录"], data)
        return true
    end
    -- 10级后爆率 1/888（表内为 1/200，按比例过滤）
    if math.random(888) <= 200 then
        return true
    end
    return false
end
--------------------爆率监听触发-------------------五行石（前5个增强）
function bl_zyjhl6(play,mingzi)
    if mingzi ~= "五行石" then
        return true
    end
    local data = Player.getJsonTableByVar(play, VarCfg["T_物品掉落记录"])
    if not data then
        data = {}
    end
    local cnt = tonumber(data[mingzi]) or 0
    -- 表内配置 1/10：前5个直接放行；第6个起按比例过滤到等效 1/50
    if cnt < 13 then
        data[mingzi] = cnt + 1
        Player.setJsonVarByTable(play, VarCfg["T_物品掉落记录"], data)
        return true
    end
    if math.random(5) == 1 then
        data[mingzi] = cnt + 1
        Player.setJsonVarByTable(play, VarCfg["T_物品掉落记录"], data)
        return true
    end
    return false
end
--------------------爆率监听触发-------------------限量掉落（超过20次失效）
function bl_zyjhl7(play,mingzi)
    if not mingzi or mingzi == "" then
        return false
    end
    local data = Player.getJsonTableByVar(play, VarCfg["T_物品掉落记录"])
    if not data then
        data = {}
    end
    local cnt = tonumber(data[mingzi]) or 0
    if cnt >= 20 then
        return false
    end
    data[mingzi] = cnt + 1
    Player.setJsonVarByTable(play, VarCfg["T_物品掉落记录"], data)
    return true
end
--------------------爆率监听触发-------------------仙法卷轴残页
function bl_zyjhl8(play,mingzi)
    if mingzi ~= "仙法卷轴残页" then
        return false
    end
    local cur_map = getbaseinfo(play, 3)
    local dl = 0
    if cur_map and daluditu then
        dl = tonumber(daluditu[cur_map] or 0) or 0
    end
    -- 只允许二大陆及以上地图掉落；真实概率固定 1/500，不吃人物爆率加成
    if dl < 2 then
        return false
    end
    return math.random(500) == 1
end
--------------------爆率监听触发-------------------二大陆材料保底
function bl_zyjhl9(play,mingzi)
    if not mingzi or mingzi == "" then
        return false
    end
    local targets = {
        ["首山之铜"] = 100,
        ["天女纯阳之力"] = 150,
        ["五色神石"] = 200,
    }
    local need = targets[mingzi]
    if not need then
        return false
    end
    local data = Player.getJsonTableByVar(play, VarCfg["T_物品掉落记录"])
    if not data then
        data = {}
    end
    local key = "pity_" .. mingzi
    local cnt = tonumber(data[key]) or 0
    cnt = cnt + 1
    data[key] = cnt
    Player.setJsonVarByTable(play, VarCfg["T_物品掉落记录"], data)
    -- 不清零：达到阈值后，之后每满1000的倍数再掉落
    if cnt == need or (cnt > need and cnt % (need * 5) == 0) then
        return true
    end
    return false
end
--------------------爆率监听触发-------------------斗笠碎片分R
function bl_zyjhl10(play,mingzi)
    if mingzi ~= "斗笠碎片" then
        return false
    end
    local total_charge = math.max(tonumber(querymoney(play,23) or 0) or 0, tonumber(getplaydef(play, VarCfg["U_真实充值"]) or 0) or 0)
    if total_charge > 0 then
        return true
    end
    local sc_data = Player.getJsonTableByVar(play, VarCfg["T_首冲礼包"]) or {}
    if tonumber(sc_data["首充"] or 0) == 1 then
        return true
    end
    -- 免费玩家在原始爆率命中后，再做一次 70% 放行
    return math.random(100) <= 70
end
--------------------碎岩锤保底监听-------------------灰界阶段爆率；
function bl_zyjhl11(play,mingzi)
    if mingzi ~= "碎岩锤" then
        return false
    end
    -- 小：天书等级条件
    local cur_map = tostring(getbaseinfo(play, 3) or "")
    if xilieditu[cur_map] ~= 3 then
        return false
    end
    local data = Player.getJsonTableByVar(play, VarCfg["T_物品掉落记录"])
    if not data then
        data = {}
    end
    -- 小：天书等级条件
    -- 前8次：1/30
    -- 后12次：1/300
    -- 20次之后：恢复常规 1/50
    local key = "drop_碎岩锤_灰界"
    local cnt = tonumber(data[key]) or 0
    local rate = 50
    if cnt < 8 then
        rate = 30
    elseif cnt < 20 then
        rate = 300
    end
    if math.random(rate) ~= 1 then
        return false
    end
    data[key] = cnt + 1
    Player.setJsonVarByTable(play, VarCfg["T_物品掉落记录"], data)
    return true
end
--------------------爆率监听触发-------------------150级经验类掉落限制
function bl_zyjhl12(play,mingzi)
    if not Player.isExpPillName(mingzi) then
        return false
    end
    return not Player.isRoleLevelLocked(play)
end
--------------------爆率监听触发-------------------二大陆修为丹额外一次掉落
function bl_zyjhl13(play,mingzi)
    if mingzi ~= "修为丹（小）" and mingzi ~= "修为丹（大）" then
        return false
    end
    local cur_map = tostring(getbaseinfo(play, 3) or "")
    local dl = 0
    if cur_map ~= "" and daluditu then
        dl = tonumber(daluditu[cur_map] or 0) or 0
    end
    if dl ~= 2 then
        return false
    end
    local data = Player.getJsonTableByVar(play, VarCfg["T_物品掉落记录"])
    if not data then
        data = {}
    end
    local key = mingzi == "修为丹（小）" and "once_drop_修为丹小" or "once_drop_修为丹大"
    if tonumber(data[key] or 0) >= 1 then
        return false
    end
    data[key] = 1
    Player.setJsonVarByTable(play, VarCfg["T_物品掉落记录"], data)
    return true
end
