shaguai = {

}


shaguai.jia = function(play, id)
	local chuli = json2tbl(getplaydef(play, constant.T_sgcf))
	chuli["" .. id] = true
	setplaydef(play, constant.T_sgcf, tbl2json(chuli))
end

shaguai.jian = function(play, id)
	local chuli = json2tbl(getplaydef(play, constant.T_sgcf))
	chuli["" .. id] = nil
	setplaydef(play, constant.T_sgcf, tbl2json(chuli))
end

return shaguai