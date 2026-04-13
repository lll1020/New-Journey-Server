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