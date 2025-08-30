--全局定时器

-----------------全局1号60秒定时器----------------
function ontimerex1()
    if getsysvar(VarCfg["G_新区验证"]) > 0 and not checkkuafuserver() then
        local dqfz = getsysvar(VarCfg["G_开区分钟"]) + 1
        setsysvar(VarCfg["G_开区分钟"], dqfz)

    end
end



------------------------------------个人定时器begin---------------------------------
-----------------个人1号3秒定时器----------------一直开启
function ontimer1(play)
    --------------------------------------------------回收脚本
    if getbagblank(play) < 20 then -- 回收脚本
        Player.huishou(play)
    end
end

-----------------个人4号定时器----------------60秒定时器
function ontimer4(play)
    local zxsj = getplaydef(play, VarCfg.U_fldt[1])
    setplaydef(play, VarCfg.U_fldt[1], zxsj + 1)
    setplaydef(play, VarCfg.J_zxsj,getplaydef(play, VarCfg.J_zxsj) + 1)
end
-----------------个人5号定时器----------------1秒定时器AI挂机开启
function ontimer5(play)
    local json = json2tbl(getplaydef(play, VarCfg.T_aigj))
    if json.gjkg then
        if  getbaseinfo(play, 3) ~= "xtc" then
            local hdtsj,sgsj = getplaydef(play, VarCfg.N_Aigj[3]),getplaydef(play, VarCfg.N_Aigj[2])
            if json.zgx3 and os.time() - hdtsj >= 120  then
                ai_qhdt(play)
                setplaydef(play, VarCfg.N_Aigj[2], os.time())
                setplaydef(play, VarCfg.N_Aigj[3], os.time())
            elseif json.zgx2 and  os.time() - sgsj >= 120 then
                if getplaydef(play,"N$战斗状态") < os.time() and not getbaseinfo(play,0) then
                    map(play, getbaseinfo(play, 3))
                    setplaydef(play, VarCfg.N_Aigj[2], os.time())
                    sendmsg(play, 1, '{"Msg":"<font color=\'#28ef01\'>AI挂机：120秒无怪自动随机</font>","Type":9}')
                    startautoattack(play)
                else
                    setplaydef(play, VarCfg.N_Aigj[2], os.time())
                end
            end
        elseif getbaseinfo(play, 3) == "xtc" and json.zgx4 then
            local tcsj = getplaydef(play, VarCfg.N_Aigj[4])
            if tcsj >= 60 then
                ai_qhdt(play)
                setplaydef(play, VarCfg.N_Aigj[4], 0)
            else
                setplaydef(play, VarCfg.N_Aigj[4], tcsj + 1)
            end
        elseif json.zgx5 and os.time() - getplaydef(play, VarCfg.N_Aigj[5]) >= (60*20) then
            ai_qhdt(play)
            setplaydef(play, VarCfg.N_Aigj[5], os.time())
        end
    end
end
-----------------个人6号定时器---------------红点系统--60s
function ontimer6(play)
    --release_print("红点系统")
    --天上阁
    local ists = false
end

-----------------定时器----------------清空除魔  每天五点
function ql_smmrrw()

end

-----------------个人10号定时器----------------假人用-流程
function ontimer10(play)
    local dqlc = getplaydef(play,"N$当前流程")
    if dqlc == 0 then
        setplaydef(play,"N$当前流程",1)
        mapmove(play,"xtc",137,138,5)
    end
end

------------------------------------个人定时器end---------------------------------
-----------------地图定时器----------------
function hd_tcppk(xx,ditu)
    if ditu == "xtc" then
        local wanjia = getobjectinmap("xtc",137,138,20,1)
        for k, v in pairs(wanjia) do
            if math.random(2) == 1 then
                local x, y = getbaseinfo(v, 4), getbaseinfo(v, 5)
                if getplaydef(v, "N$上次坐标x") ~= x and getplaydef(v, "N$上次坐标y") ~= y then
                    setplaydef(v, "N$上次坐标x", x)
                    setplaydef(v, "N$上次坐标y", y)
                    local wpmz = paokujl[math.random(#paokujl)]
                    sendmsg(v,1,'{"Msg":"<font color=\'#ff7700\'>[土城跑酷]</font><font color=\'#00ff00\'>恭喜你获得了['..wpmz..']...</font>","Type":9}')
                    sendmsg(v, 2, '{"BColor":249,"FColor":255,"Msg":"[土城跑酷]<font color=\'#00ff00\'>恭喜'..getbaseinfo(v, 1)..'获得了['..wpmz..']...</font>","Type":1}')
                    giveitem(v, wpmz,1,getflagstatus(v,VarCfg.BS_mztq) == 0 and 0 or 850)
                end
            end
        end
    end
end
