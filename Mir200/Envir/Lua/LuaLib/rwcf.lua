rwcf = {

}

rwcf.jia = function(play, id)
	local chuli = json2tbl(getplaydef(play, constant.T_zxrw))
	chuli[""..id] = true
	setplaydef(play, constant.T_zxrw, tbl2json(chuli))
end

rwcf.jian = function(play, id)
	local chuli = json2tbl(getplaydef(play, constant.T_zxrw))
	chuli[""..id] = nil
	setplaydef(play, constant.T_zxrw, tbl2json(chuli))
end

rwcf.wpjia = function(play, id,rwid,sl)
	local chuli = json2tbl(getplaydef(play, constant.T_rwwp))
	chuli[""..id] = {rwid,sl}
	setplaydef(play, constant.T_rwwp, tbl2json(chuli))
end

rwcf.wpjian = function(play, id)
	local chuli = json2tbl(getplaydef(play, constant.T_rwwp))
	chuli[""..id] = nil
	setplaydef(play, constant.T_rwwp, tbl2json(chuli))
end

return rwcf