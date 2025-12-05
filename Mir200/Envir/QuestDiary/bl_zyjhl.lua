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