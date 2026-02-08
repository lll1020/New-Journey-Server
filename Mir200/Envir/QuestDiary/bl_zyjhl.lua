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
                return true
            end
        end
    end
    return false
end
--------------------爆率监听触发-------------------八卦卷轴计数
function bl_zyjhl4(play,mingzi)
    local data = Player.getJsonTableByVar(play, VarCfg["T_八卦"])
    if not data then
        data = {}
    end
    data[mingzi] = (data[mingzi] or 0) + 1
    Player.setJsonVarByTable(play, VarCfg["T_八卦"], data)
    return true
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
        local data = Player.getJsonTableByVar(play, VarCfg["T_杀伐神石"])
        if not data then
            data = {}
        end
        local cnt = tonumber(data[mingzi]) or 0
        if cnt >= 2 then
            return false
        end
        data[mingzi] = cnt + 1
        Player.setJsonVarByTable(play, VarCfg["T_杀伐神石"], data)
        return true
    end

    -- 10级后爆率 1/888（表内为 1/200，按比例过滤）
    if math.random(888) <= 200 then
        return true
    end

    return false
end