--------------------���ʼ�������-------------------���˱���
function bl_zyjhl2(play,mingzi)
    local sj = json2tbl(getplaydef(play,VarCfg.T_xybl))
    if sj and not sj[mingzi] then
        sj[mingzi] = 1
        setplaydef(play,VarCfg.T_xybl,tbl2json(sj))
        return true
    end
    return false
end