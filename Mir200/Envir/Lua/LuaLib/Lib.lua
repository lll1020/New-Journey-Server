function split(str,reps)
    local resultStrList = {}
    string.gsub(str,'[^'..reps..']+',function (w)
        table.insert(resultStrList,w)
    end)
    return resultStrList
end

function Login_msg(play, id, msg, leve)
	id = tonumber(id)
	if id == 0 then -- 新人登录提示语句
		sendmsgnew(play, 255, 0, '玩家{《' .. getbaseinfo(play, 1) .. '》/FCOLOR=251}登录{[' .. getconst(play, '<$SERVERNAME>') .. ']/FCOLOR=250}，修真世界定将掀起一阵血雨腥风！！！', 1, 3)
	elseif id == 1 then -- 下地图提示语句
		sendmsg(play, 2, '{"BColor":249,"FColor":255,"Msg":"<outline size=\'1\'><font color=\'#FFFF00\'>【地图打宝】：</font>玩家<font color=\'#00ff00\'>[' .. getbaseinfo(play, 1) .. ']</font>前往地图<font color=\'#00FFFF\'>[' .. getbaseinfo(play, 45) .. ']</font>开始探险之旅！</outline>","Type":1}')
	elseif id == 2 then -- 转生成功提示
		sendmsg(play, 2, '{"BColor":249,"FColor":255,"Msg":"<outline size=\'1\'><font color=\'#FFFF00\'>【人物转生】：</font>玩家<font color=\'#00ff00\'>[' .. getbaseinfo(play, 1) .. ']</font>成功转生<font color=\'#00FFFF\'>[' .. msg .. ']</font>仙途畅通！</outline>","Type":1}')
	elseif id == 3 then -- 成功开启狂暴提示
		sendmsgnew(play, 255, 0, '狂暴之力：玩家{《' .. getbaseinfo(play, 1) .. '》/FCOLOR=251}成功开启{[狂暴之力]/FCOLOR=250},击杀此人可获得额外奖励...', 1, 3)
	elseif id == 4 then -- 死亡掉狂暴提示
		sendmsgnew(play, 255, 0, '前方战报：狂暴玩家{《' .. getbaseinfo(play, 1) .. '》/FCOLOR=251}被{《' .. getbaseinfo(msg, 1) .. '》/FCOLOR=250}斩杀，被碾碎在脚下。...', 1, 3)
	elseif id == 5 then -- 轩辕剑，切割之斧提示
		sendmsg(play, 2, '{"BColor":249,"FColor":255,"Msg":"<outline size=\'1\'><font color=\'#FFFF00\'>【' .. msg .. '晋升】：</font>玩家<font color=\'#00ff00\'>[' .. getbaseinfo(play, 1) .. ']</font>成功升级<font color=\'#00FFFF\'>[' .. msg .. ']</font>仙途畅通！</outline>","Type":1}')
	elseif id == 6 then -- 公用修炼提示
		sendmsg(play, 2, '{"BColor":249,"FColor":255,"Msg":"<outline size=\'1\'><font color=\'#FFFF00\'>【' .. msg .. '晋升】：</font>玩家<font color=\'#00ff00\'>[' .. getbaseinfo(play, 1) .. ']</font>成功<font color=\'#00FFFF\'>[' .. msg .. leve .. '级]</font>仙途畅通！</outline>","Type":1}')
	elseif id == 7 then -- 神魔习练招式提示
		sendmsg(play, 2, '{"BColor":249,"FColor":255,"Msg":"<outline size=\'1\'><font color=\'#FFFF00\'>【锻造】：</font>玩家<font color=\'#00ff00\'>[' .. getbaseinfo(play, 1) .. ']</font>成功锻造<font color=\'#00FFFF\'>[' ..msg .. '] 到达 '..leve.. '级</font>，仙途畅通！</outline>","Type":1}')
	elseif id == 8 then -- 星盘提升提示
		sendmsg(play, 2, '{"BColor":249,"FColor":255,"Msg":"<outline size=\'1\'><font color=\'#FFFF00\'>【星盘升级】：</font>玩家<font color=\'#00ff00\'>[' .. getbaseinfo(play, 1) .. ']</font>成功将<font color=\'#00FFFF\'>[' .. msg .. ']</font>修炼至<font color=\'#00FFFF\'>[LV.' .. leve .. ']</font>仙途畅通！</outline>","Type":1}')
	elseif id == 9 then -- 仙法阁提升提示
		sendmsg(play, 2, '{"BColor":249,"FColor":255,"Msg":"<outline size=\'1\'><font color=\'#FFFF00\'>【仙法阁升级】：</font>玩家<font color=\'#00ff00\'>[' .. getbaseinfo(play, 1) .. ']</font>成功将<font color=\'#00FFFF\'>[' .. msg .. ']</font>修炼至<font color=\'#00FFFF\'>[LV.' .. leve .. ']</font>仙途畅通！</outline>","Type":1}')
	elseif id == 10 then -- 回收
        if msg > 0 or leve > 0 then
            sendmsg(play, 2, '{"BColor":249,"FColor":255,"Msg":"<outline size=\'1\'><font color=\'#FFFF00\'>【装备回收】：</font>玩家<font color=\'#00ff00\'>[' .. getbaseinfo(play, 1) .. ']</font>成功回收装备,获得<font color=\'#00FFFF\'>[' .. msg .. ']</font>元宝，<font color=\'#00FFFF\'>[' .. leve .. ']</font>灵符！</outline>","Type":1}')
        end
	elseif id == 12 then -- 成功开启风暴提示
		sendmsgnew(play, 255, 0, '究极狂暴：玩家{《' .. getbaseinfo(play, 1) .. '》/FCOLOR=251}成功开启{[究极狂暴]/FCOLOR=250},击杀此人可获得额外奖励...', 1, 3)
    elseif id == 13 then -- 死亡掉狂暴提示
		sendmsgnew(play, 255, 0, '前方战报：风暴玩家{《' .. getbaseinfo(play, 1) .. '》/FCOLOR=251}被{《' .. getbaseinfo(msg, 1) .. '》/FCOLOR=250}手起刀落放倒在地...', 1, 3)
    elseif id == 14 then -- 天渊剑甲升级提示
        sendmsg(play, 2, '{"BColor":249,"FColor":255,"Msg":"<outline size=\'1\'><font color=\'#FFFF00\'>【天渊剑甲升级】：</font>玩家<font color=\'#00ff00\'>[' .. getbaseinfo(play, 1) .. ']</font>成功升级<font color=\'#00FFFF\'>[' .. msg .. ']</font>仙途畅通！</outline>","Type":1}')
    elseif id == 15 then -- 实物回收
        sendmsgnew(play, 255, 0, '玩家{《' .. getbaseinfo(play, 1) .. '》/FCOLOR=251}实物回收{[' .. msg .. ']/FCOLOR=250}，获得灵符{[' .. leve .. ']/FCOLOR=250}', 1, 3)
    elseif id == 16 then -- 小日卡
        sendmsgnew(play, 255, 0, '玩家{《' .. getbaseinfo(play, 1) .. '》/FCOLOR=251}小日卡{[' .. msg .. ']/FCOLOR=250}，获得仙玉{[1000]/FCOLOR=250}元宝{[300000]/FCOLOR=250}灵符{[100000]/FCOLOR=250}', 1, 3)
    elseif id == 17 then -- 大日卡
        sendmsgnew(play, 255, 0, '玩家{《' .. getbaseinfo(play, 1) .. '》/FCOLOR=251}大日卡{[' .. msg .. ']/FCOLOR=250}，获得仙玉{[3000]/FCOLOR=250}元宝{[1000000]/FCOLOR=250}灵符{[300000]/FCOLOR=250}', 1, 3)
    elseif id == 18 then -- 充值
        sendmsgnew(play, 255, 0, '玩家{《' .. string.sub(getbaseinfo(play, 1), 1, 2) .. '******》/FCOLOR=251}{通过充值获得了大量仙玉/FCOLOR=250}', 1, 3)
    end
end

local jnsh_data = {"基本剑术","刺杀剑术","半月弯刀","烈火剑法","逐日剑法","开天斩"}
function Login_jnsh(play)
    for i, v in ipairs(VarCfg.N_jnsh) do
        local linshi = getplaydef(play,v)
        if linshi > 0 then
            setmagicpower(play,jnsh_data[i],linshi,1)
        end
    end
end
GameEvent.add(EventCfg.onLogin, Login_jnsh, "Login_jnsh")

local jmjnsh_data = {"烈火剑法","逐日剑法","开天斩"}
function Login_jmjnsh(play)
    for i = 1,3 do
        setplaydef(play,VarCfg.N_jmjnsh[i], getbaseinfo(play, 51, 256))
    end
    for i, v in ipairs(VarCfg.N_jmjnsh) do
        local linshi = getplaydef(play,v)
        if linshi > 0 then
            setmagicdefpower(play,jmjnsh_data[i],linshi,1)
        end
    end
end
GameEvent.add(EventCfg.onLogin, Login_jmjnsh, "Login_jmjnsh")


function login_fhsx(play)
    local T_zzsj = json2tbl(getplaydef(play,VarCfg.T_zzsj))
    if T_zzsj.dqzy then
        if T_zzsj.sh and T_zzsj.sh[""..T_zzsj.dqzy] == 1 then
            setranklevelname(play,"%s\\[踏月々沉默]\\[极·".. constant.zzxg.zy[T_zzsj.dqzy].name.."]\\击杀『"..getplaydef(play,VarCfg.U_srsl).."』")
        else
            setranklevelname(play,"%s\\[踏月々沉默]\\["..constant.zzxg.zy[T_zzsj.dqzy].name.."]\\击杀『"..getplaydef(play,VarCfg.U_srsl).."』")
        end
    else
        setranklevelname(play,"%s\\[踏月々沉默]\\击杀『"..getplaydef(play,VarCfg.U_srsl).."』")
    end
end
GameEvent.add(EventCfg.onLogin, login_fhsx, "login_fhsx")


-----------------------------各类定时器-------------------------
