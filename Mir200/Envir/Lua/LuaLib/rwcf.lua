rwcf = {}

rwcf.jia = function(play, id)
	local chuli = json2tbl(getplaydef(play, VarCfg.T_zxrw))
	chuli[""..id] = true
	setplaydef(play, VarCfg.T_zxrw, tbl2json(chuli))
end

rwcf.jian = function(play, id)
	local chuli = json2tbl(getplaydef(play, VarCfg.T_zxrw))
	chuli[""..id] = nil
	setplaydef(play, VarCfg.T_zxrw, tbl2json(chuli))
end

rwcf.wpjia = function(play, id,rwid,sl)
	local chuli = json2tbl(getplaydef(play, VarCfg.T_rwwp))
	chuli[""..id] = {rwid,sl}
	setplaydef(play, VarCfg.T_rwwp, tbl2json(chuli))
end

rwcf.wpjian = function(play, id)
	local chuli = json2tbl(getplaydef(play, VarCfg.T_rwwp))
	chuli[""..id] = nil
	setplaydef(play, VarCfg.T_rwwp, tbl2json(chuli))
end

return rwcf