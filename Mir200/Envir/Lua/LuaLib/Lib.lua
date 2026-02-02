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
    elseif id == 10 then -- 回收
        if msg > 0 or leve > 0 then
            sendmsg(play, 2, '{"BColor":249,"FColor":255,"Msg":"<outline size=\'1\'><font color=\'#FFFF00\'>【装备回收】：</font>玩家<font color=\'#00ff00\'>[' .. getbaseinfo(play, 1) .. ']</font>成功回收装备,获得<font color=\'#00FFFF\'>[' .. msg .. ']</font>元宝，<font color=\'#00FFFF\'>[' .. leve .. ']</font>灵符！</outline>","Type":1}')
        end
	elseif id == 12 then -- 成功开启风暴提示
		sendmsgnew(play, 255, 0, '究极狂暴：玩家{《' .. getbaseinfo(play, 1) .. '》/FCOLOR=251}成功开启{[究极狂暴]/FCOLOR=250},击杀此人可获得额外奖励...', 1, 3)
    elseif id == 13 then -- 死亡掉狂暴提示
		sendmsgnew(play, 255, 0, '前方战报：风暴玩家{《' .. getbaseinfo(play, 1) .. '》/FCOLOR=251}被{《' .. getbaseinfo(msg, 1) .. '》/FCOLOR=250}手起刀落放倒在地...', 1, 3)
    elseif id == 15 then -- 实物回收
        sendmsgnew(play, 255, 0, '玩家{《' .. getbaseinfo(play, 1) .. '》/FCOLOR=251}实物回收{[' .. msg .. ']/FCOLOR=250}，获得元宝{[' .. leve .. ']/FCOLOR=250}', 1, 3)
    elseif id == 18 then -- 充值
        sendmsgnew(play, 255, 0, '玩家{《' .. string.sub(getbaseinfo(play, 1), 1, 2) .. '******》/FCOLOR=251}{通过充值获得了大量灵石/FCOLOR=250}', 1, 3)
    end
end

local jnsh_data = {"攻杀剑术","刺杀剑术","半月弯刀","烈火剑法","开天斩","逐日剑法"}
function Login_jnsh(play)
    for i, v in ipairs(VarCfg.N_jnsh) do
        local linshi = getplaydef(play,v)
        if linshi > 0 then
            setmagicpower(play,jnsh_data[i],linshi,1)
        end
    end
end
GameEvent.add(EventCfg.onLoginEnd, Login_jnsh, "Login_jnsh")

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
GameEvent.add(EventCfg.onLoginEnd, Login_jmjnsh, "Login_jmjnsh")


function login_fhsx(play)
    setranklevelname(play,"%s\\[踏月々沉默]\\击杀『"..getplaydef(play,VarCfg.U_srsl).."』")
end
GameEvent.add(EventCfg.onLoginEnd, login_fhsx, "login_fhsx")


-----------------------------各类定时器-------------------------
