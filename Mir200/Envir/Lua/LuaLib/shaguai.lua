shaguai = {

}


shaguai.jia = function(play, id)
	local chuli = json2tbl(getplaydef(play, VarCfg.T_sgcf))
	chuli["" .. id] = true
	setplaydef(play, VarCfg.T_sgcf, tbl2json(chuli))
end

shaguai.jian = function(play, id)
	local chuli = json2tbl(getplaydef(play, VarCfg.T_sgcf))
	chuli["" .. id] = nil
	setplaydef(play, VarCfg.T_sgcf, tbl2json(chuli))
end

return shaguai