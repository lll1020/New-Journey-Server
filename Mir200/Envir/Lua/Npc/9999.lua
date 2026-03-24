npc = {}
local function _ff9999_parse_reward(text) -- 9999测试：解析成就奖励中的物品/称号/修为
    local ret = {items = {}, title = "", realm_exp = 0}
    text = tostring(text or ""):gsub("固定生命、固定魔法%+(%d+)", "固定生命+%1、固定魔法+%1"):gsub("，", "、"):gsub(",", "、")
    for part in string.gmatch(text, "[^、]+") do
        part = tostring(part):gsub("^%s+", ""):gsub("%s+$", "")
        if part ~= "" then
            local itemName, itemNum = string.match(part, "^(.-)%*(%d+)$")
            if itemName and itemNum then
                ret.items[#ret.items + 1] = {itemName, tonumber(itemNum) or 0}
            elseif string.find(part, "^称号：") then
                ret.title = string.gsub(part, "^称号：", "")
            else
                local n = string.match(part, "^修为%+(%d+)$")
                if n then ret.realm_exp = tonumber(n) or 0 end
            end
        end
    end
    return ret
end
local function _ff9999_random_finish(play) -- 9999测试：随机完成一个未完成成就
    local cfg = include("lua/Data/fairy_fate_cfg.lua") or {}
    local state = Player.getJsonTableByVar(play, VarCfg["T_仙途奇缘"])
    state.done = type(state.done) == "table" and state.done or {}
    local pending = {}
    for _, detail in ipairs(cfg.details or {}) do
        if tonumber(state.done[tostring(detail.id)] or 0) < 1 then
            pending[#pending + 1] = detail
        end
    end
    if #pending <= 0 then
        Player.sendmsgEx(play, "已无未完成成就#57")
        return
    end
    local detail = pending[math.random(1, #pending)]
    local reward = _ff9999_parse_reward(detail.reward)
    state.done[tostring(detail.id)] = 1
    Player.setJsonVarByTable(play, VarCfg["T_仙途奇缘"], state)
    if #reward.items > 0 then Player.rwjl(play, reward.items, "9999成就测试", 1, 0) end
    if reward.title ~= "" then Player.title_give(play, reward.title) end
    if reward.realm_exp > 0 then
        setplaydef(play, VarCfg["U_境界修炼"][2], (tonumber(getplaydef(play, VarCfg["U_境界修炼"][2])) or 0) + reward.realm_exp)
    end
    if FairyFate and FairyFate.touch then FairyFate.touch(play, "title") end
    sendluamsg(play, 101, 515, 2, tonumber(detail.id) or 0, tbl2json({tp = "cjdc", id = detail.id, name = detail.name, tip = "达成成就[" .. tostring(detail.name or detail.id) .. "]"}))
    -- Player.sendmsgEx(play, "已随机完成|【" .. tostring(detail.name or detail.id) .. "】#249|成就")
end
function npc.main(play,npcid)
    local zhid = tonumber(getconst(play,"<$USERACCOUNT>"))
    if constant.pz_htqx[zhid] or getconst(play, '<$SERVERNAME>') == "" or getconst(play, '<$SERVERNAME>') == "测试区" then
        -- release_print("-----------------------------")
        -- release_print(getbaseinfo(play,3).." "..getbaseinfo(play,4).." "..getbaseinfo(play,5))
        -- return
        say(play,[[<Img|id=ui_1|x=0.0|y=-1.0|width=800|height=600|img=public/bg_npc_01.png|bg=1|esc=1|move=0|reset=1|show=0|scale9l=15|scale9r=15|scale9t=15|scale9b=15|loadDelay=1>
            <Layout|id=ui_2|x=801.0|y=0.0|width=80|height=80|link=@exit>
            <Button|id=ui_3|x=794|y=0.0|width=26|height=42|nimg=public/1900000510.png|pimg=public/1900000511.png|color=255|size=18|link=@exit>
            <EquipShow|id=ui_27|x=0|y=500|index=71|showtips=1|link=@脚本命令>
            <EquipShow|id=ui_28|x=50|y=500|index=72|showtips=1|link=@脚本命令>
            <EquipShow|id=ui_29|x=100|y=500|index=73|showtips=1|link=@脚本命令>
            <EquipShow|id=ui_30|x=150|y=500|index=17|showtips=1|link=@脚本命令>
            <EquipShow|id=ui_300|x=200|y=500|index=87|showtips=1|link=@脚本命令>
            <EquipShow|id=ui_301|x=250|y=500|index=104|showtips=1|link=@脚本命令>

            <Button|id=ui_100|x=150|y=450|width=160|height=40|nimg=public/1900000660.png|color=251|size=16|text=llxf测试|link=@ggna,24>
            <Button|id=ui_101|x=350|y=450|width=160|height=40|nimg=public/1900000660.png|color=251|size=16|text=测试装备|link=@ggna,23>
            <Button|id=ui_102|x=550|y=450|width=160|height=40|nimg=public/1900000660.png|color=251|size=16|text=大陆全解锁|link=@ggna,25>

            <Button|id=ui_39|x=18|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=村庄开始|link=@ggna,32>
            <Button|id=ui_40|x=130|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=村庄结束|link=@ggna,33>
            <Button|id=ui_41|x=242|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=夺矿开始|link=@ggna,26>
            <Button|id=ui_42|x=354|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=夺矿结束|link=@ggna,27>
            <Button|id=ui_43|x=466|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=答题开始|link=@ggna,28>
            <Button|id=ui_44|x=578|y=100|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=答题结束|link=@ggna,29>
            <Button|id=ui_45|x=18|y=150|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=镖车开始|link=@ggna,34>
            <Button|id=ui_46|x=130|y=150|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=镖车结束|link=@ggna,35>
            <Button|id=ui_47|x=242|y=150|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=跑酷开始|link=@ggna,36>
            <Button|id=ui_48|x=354|y=150|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=跑酷结束|link=@ggna,37>
            <Button|id=ui_49|x=466|y=150|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=地宝开始|link=@ggna,38>
            <Button|id=ui_50|x=578|y=150|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=地宝结束|link=@ggna,39>
            <Button|id=ui_51|x=18|y=200|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=天选开始|link=@ggna,40>
            <Button|id=ui_52|x=130|y=200|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=天选结束|link=@ggna,41>
            <Button|id=ui_53|x=242|y=200|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=正邪开始|link=@ggna,42>
            <Button|id=ui_54|x=354|y=200|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=正邪结束|link=@ggna,43>
            <Button|id=ui_55|x=466|y=200|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=盟主开始|link=@ggna,30>
            <Button|id=ui_56|x=578|y=200|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=盟主结束|link=@ggna,31>
            <Button|id=ui_57|x=18|y=250|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=沙城开始|link=@ggna,44>
            <Button|id=ui_58|x=130|y=250|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=沙城结束|link=@ggna,45>
            <Button|id=ui_59|x=242|y=250|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=BOSS开始|link=@ggna,46>
            <Button|id=ui_60|x=354|y=250|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=BOSS结束|link=@ggna,47>
            <Button|id=ui_61|x=466|y=250|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=夺宝开始|link=@ggna,48>
            <Button|id=ui_62|x=578|y=250|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=夺宝结束|link=@ggna,49>
            <Button|id=ui_63|x=18|y=300|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=禁地开始|link=@ggna,50>
            <Button|id=ui_64|x=130|y=300|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=禁地结束|link=@ggna,51>
            <Button|id=ui_66|x=242|y=300|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=成就测试|link=@ggna,52>
            <Button|id=ui_65|x=578|y=300|width=106|height=40|nimg=public/1900000660.png|color=251|size=16|text=飘字测试|link=@ggn,14>

                ]])
    end

end

function ggna(play,id)
    if id == "1" then
        local item = linkbodyitem(play,73)
        if item == "0" then
            Player.sendmsgEx(play, "数据异常#57")
        else
            if checktitle(play,"狂暴之力") then
                Player.sendmsgEx(play, "你已经开启过#57|【狂暴之力】#249|了#57")
            else
                confertitle(play,"狂暴之力")
                changecustomitemvalue(play,linkbodyitem(play,73),0,"=",20,1)
                Player.sendmsgEx(play, "完成")
            end
        end
    elseif id == "2" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            Player.sendmsgEx(play, "数据异常#57")
        else
            local sx = json2tbl(getitemcustomabil(play, item))
            if sx.abil[2].v[1][3] >= 30 then
                Player.sendmsgEx(play, "已满级#57")
            else
                changecustomitemvalue(play,item,0,"=",30,1)
                changecustomitemvalue(play,item,1,"=",1500,1)
                --changecustomitemvalue(play,item,8,"=",3000,1)
                changecustomitemvalue(play,item,2,"=",30,1)
                changecustomitemvalue(play,item,3,"=",30,1)
                changecustomitemvalue(play,item,4,"=",6000,1)
                changecustomitemvalue(play,item,5,"=",6000,1)
                changecustomitemvalue(play,item,6,"=",600,1)
                changecustomitemvalue(play,item,7,"=",600,1)
                confertitle(play,"传功阁大神魔")
                Player.sendmsgEx(play, "完成")
            end
        end
    elseif id == "3" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            Player.sendmsgEx(play, "数据异常#57")
        else
            changecustomitemvalue(play,item,0,"=",400,0)
            changecustomitemvalue(play,item,1,"=",400,0)
            changecustomitemvalue(play,item,2,"=",4000,0)
            changecustomitemvalue(play,item,3,"=",20000,0)
            changecustomitemvalue(play,item,9,"=",5000,0)
            confertitle(play,teshudata["npc_54"].del_title)
            changecustomitemvalue(play,item,4,"=",200,0)
            changecustomitemvalue(play,item,5,"=",10,0)
            changecustomitemvalue(play,item,6,"=",20,0)
            changecustomitemvalue(play,item,7,"=",10,0)
            changecustomitemvalue(play,item,8,"=",20,0)
            Player.sendmsgEx(play, "完成")
        end
    elseif id == "4" then
        local zs = getbaseinfo(play,39)
        if zs > 5 then
            Player.sendmsgEx(play, "【转生】#249|你转生在我这已经满级了#57")
        else
            setbaseinfo(play,39,6)
            confertitle(play,"6重转生")
            changecustomitemvalue(play,linkbodyitem(play,72),0,"=",15,2)
            Player.sendmsgEx(play, "完成")
        end
    elseif id == "5" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            Player.sendmsgEx(play, "数据异常#57")
        else
            changecustomitemvalue(play,item,0,"=",500,2)
            changecustomitemvalue(play,item,1,"=",5000,2)
            changecustomitemvalue(play,item,2,"=",10,2)
            changecustomitemvalue(play,item,3,"=",10,2)
            changecustomitemvalue(play,item,4,"=",10,2)
            changecustomitemvalue(play,item,5,"=",1000,2)
            changecustomitemvalue(play,item,6,"=",20,2)
            changecustomitemvalue(play,item,7,"=",40,2)
            changecustomitemvalue(play,item,8,"=",20,2)
            changecustomitemvalue(play,item,9,"=",40,2)
            confertitle(play,"八卦十重")
            Player.sendmsgEx(play, "完成")
        end
    elseif id == "6" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            Player.sendmsgEx(play, "数据异常#57")
        else
            changecustomitemvalue(play,item,0,"=",10,3)
            changecustomitemvalue(play,item,1,"=",10,3)
            changecustomitemvalue(play,item,2,"=",10,3)
            changecustomitemvalue(play,item,3,"=",10,3)
            changecustomitemvalue(play,item,4,"=",1000,3)
            changecustomitemvalue(play,item,5,"=",10,3)
            changecustomitemvalue(play,item,6,"=",20,3)
            changecustomitemvalue(play,item,7,"=",10,3)
            changecustomitemvalue(play,item,8,"=",20,3)
            changecustomitemvalue(play,item,9,"=",1,3)
            changecustomitemvalue(play,item,0,"=",15,4)
            changecustomitemvalue(play,item,1,"=",30,4)
            changecustomitemvalue(play,item,2,"=",15,4)
            changecustomitemvalue(play,item,3,"=",30,4)
            confertitle(play,"仙法阁十重")
            Player.sendmsgEx(play, "完成")
        end
    elseif id == "7" then
        local item = linkbodyitem(play, 71)
        if item == "0" then
            Player.sendmsgEx(play, "数据异常#57")
        else
            Player.sendmsgEx(play, "完成")
        end
    elseif id == "8" then
        local item = linkbodyitem(play, 72)
        if item == "0" then
            Player.sendmsgEx(play, "数据异常#57")
        else
            changecustomitemvalue(play,item,0,"+",100,0)
            changecustomitemvalue(play,item,1,"+",100,0)
            changecustomitemvalue(play,item,2,"+",5000,0)
            local data = json2tbl(getplaydef(play,VarCfg.T_ystz))
            data.xt1 = 1
            data.xt2 = 1
            data.xt3 = 1
            data.xt4 = 1
            data.xt5 = 1
            data.xt6 = 1
            data.xt7 = 1
            data.xt8 = 1
            setplaydef(play,VarCfg.T_ystz,tbl2json(data))
            confertitle(play,"天才地宝(地)")
            Player.sendmsgEx(play, "完成")
        end
    elseif id == "9" then
        local item = linkbodyitem(play, 72)
        if item == "0" then
            Player.sendmsgEx(play, "数据异常#57")
        else
            changecustomitemvalue(play,item,0,"+",250,0)
            changecustomitemvalue(play,item,1,"+",250,0)
            changecustomitemvalue(play,item,2,"+",10000,0)
            local data = json2tbl(getplaydef(play,VarCfg.T_ystz))
            data.yy1 = 1
            data.yy2 = 1
            data.yy3 = 1
            data.yy4 = 1
            data.yy5 = 1
            data.yy6 = 1
            data.yy7 = 1
            data.yy8 = 1
            setplaydef(play,VarCfg.T_ystz,tbl2json(data))
            confertitle(play,"天才地宝(天)")
            Player.sendmsgEx(play, "完成")
        end
    elseif id == "10" then
        local item = linkbodyitem(play, 72)
        if item == "0" then
            Player.sendmsgEx(play, "数据异常#57")
        else
            changecustomitemvalue(play,item,0,"+",500,0)
            changecustomitemvalue(play,item,1,"+",500,0)
            changecustomitemvalue(play,item,2,"+",20000,0)
            local data = json2tbl(getplaydef(play,VarCfg.T_ystz))
            data.xc1 = 1
            data.xc2 = 1
            data.xc3 = 1
            data.xc4 = 1
            data.xc5 = 1
            data.xc6 = 1
            data.xc7 = 1
            data.xc8 = 1
            setplaydef(play,VarCfg.T_ystz,tbl2json(data))
            confertitle(play,"天才地宝(神)")
            Player.sendmsgEx(play, "完成")
        end
    elseif id == "11" then
        setplaydef(play,VarCfg.T_gjyj,'{"gjyj":[100000,100000,100000,100000,100000,100000,100000,100000,100000,0,0,0]}')  --冠绝一界
        Player.sendmsgEx(play, "完成")
    elseif id == "12" then
        setplaydef(play,VarCfg.U_qhdj[1],66)
        setplaydef(play,VarCfg.U_qhdj[2],66)
        Player.sendmsgEx(play, "完成")
    elseif id == "13" then
        reddot(play, 200, 100, 10, 10, 0, "res/public/ists.png")
        reddot(play, 200, 101, 10, 10, 0, "res/public/ists.png")
        reddot(play, 0, tonumber("Button"), 10, 10, 0, "res/public/ists.png")
        Player.sendmsgEx(play, "完成")
        Player.sendmsgEx(play, "角色红点")
    elseif id == "14" then
        Player.sendmsgEx(play, "【灵根觉醒】#249|【金之力】#249|【范围切割】#249")
        Player.sendmsgEx(play, "【极冰寒冬】#249|【极冰寒冬】#249|【寒冬减速】#249")
        Player.sendmsgEx(play, "【冰冻】#249|【冰冻】#249|【概率冰冻】#249")
        Player.sendmsgEx(play, "【天火】#249|【天火】#249|【天火坠落】#249")
        Player.sendmsgEx(play, "颜色测试完成")
    elseif id == "15" then
        local wpdx = linkbodyitem(play,76)
        local item = linkbodyitem(play,17)
        setitemcustomabil(play, wpdx,getitemcustomabil(play, item))
        Player.sendmsgEx(play, "完成")
    elseif id == "16" then
        setplaydef(play,VarCfg.U_zllv,1)
        Player.sendmsgEx(play, "完成")
    elseif id == "17" then
        local zl = json2tbl(getplaydef(play,VarCfg.T_zlxj))
        zl["dj"] = 1 + zl["dj"]
        setplaydef(play,VarCfg.T_zlxj,tbl2json(zl))
        Player.sendmsgEx(play, "完成")
    elseif id == "18" then
        if getplaydef(play,VarCfg.U_zxrw[1])then
            newdeletetask(play,getplaydef(play,VarCfg.U_zxrw[1]))
            playeffect(play,4011,25,-50,1,0,0)
        end
    elseif id == "19" then
        setplaydef(play,VarCfg.T_mjsj,'{"mjsj":[0,99,199,0,0,0,0,0,0,0,0,0]}')  --冠绝一界
    elseif id == "20" then
        setitemintparam(play,71,1,2)
    elseif id == "21" then
        repaircastle()
        addattacksabakall()
        Player.sendmsgEx(play, "攻沙开始")
    elseif id == "26" then
        _admin_qmdk_start(play)
    elseif id == "27" then
        _admin_qmdk_finish(play)
    elseif id == "28" then
        _admin_qmdt_start(play)
    elseif id == "29" then
        _admin_qmdt_finish(play)
    elseif id == "30" then
        _admin_wlmz_start(play)
    elseif id == "31" then
        _admin_wlmz_finish(play)
    elseif id == "32" then
        _admin_not_ready(play, "保卫村庄开始")
    elseif id == "33" then
        _admin_not_ready(play, "保卫村庄结束")
    elseif id == "34" then
        _admin_not_ready(play, "勇夺镖车开始")
    elseif id == "35" then
        _admin_not_ready(play, "勇夺镖车结束")
    elseif id == "36" then
        _admin_tcppk_start(play)
    elseif id == "37" then
        _admin_tcppk_finish(play)
    elseif id == "38" then
        _admin_not_ready(play, "天才地宝开始")
    elseif id == "39" then
        _admin_not_ready(play, "天才地宝结束")
    elseif id == "40" then
        _admin_txzr_start(play)
    elseif id == "41" then
        _admin_txzr_finish(play)
    elseif id == "42" then
        _admin_not_ready(play, "正邪大战开始")
    elseif id == "43" then
        _admin_not_ready(play, "正邪大战结束")
    elseif id == "44" then
        _admin_sbk_start(play)
    elseif id == "45" then
        _admin_sbk_finish(play)
    elseif id == "46" then
        _admin_not_ready(play, "讨伐BOSS开始")
    elseif id == "47" then
        _admin_not_ready(play, "讨伐BOSS结束")
    elseif id == "48" then
        _admin_sjdb_start(play)
    elseif id == "49" then
        _admin_sjdb_finish(play)
    elseif id == "50" then
        _admin_not_ready(play, "黑暗禁地开始")
    elseif id == "51" then
        _admin_not_ready(play, "黑暗禁地结束")
    elseif id == "52" then
        _ff9999_random_finish(play)
    elseif id == "25" then
        -- 大陆进入条件一键达成：主线进度、转生等级、剧情点
        local target_task = 21
        local target_zs = 40
        local target_jqd = 100

        local cur_task = tonumber(getplaydef(play, VarCfg.U_zxrw[1])) or 0
        if cur_task < target_task then
            setplaydef(play, VarCfg.U_zxrw[1], target_task)
        end

        local cur_zs_var = tonumber(getplaydef(play, VarCfg["U_转生等级"])) or 0
        if cur_zs_var < target_zs then
            setplaydef(play, VarCfg["U_转生等级"], target_zs)
        end

        local cur_zs_base = tonumber(getbaseinfo(play, 39)) or 0
        if cur_zs_base < target_zs then
            setbaseinfo(play, 39, target_zs)
        end

        local jqd_idx = tonumber(getstditeminfo("剧情点", 0)) or 0
        if jqd_idx > 0 then
            local cur_jqd = tonumber(querymoney(play, jqd_idx)) or 0
            if cur_jqd < target_jqd then
                changemoney(play, jqd_idx, "+", target_jqd - cur_jqd, "测试-大陆全解锁", true)
            end
        end

        Player.sendmsgEx(play, "大陆条件已一键解锁：主线>=21，转生>=40，剧情点>=100")
    elseif id == "23" then
        release_print("测试装备")
        local cailiao = {
"噬魂夺魄",
"九幽魔音",
"焚霄",
"镇渊",
"逆命",
"斩仙令",
"焚天印",
"渡魂舟",
"碎星刃",
"九霄龙吟",
"万法归宗",
"天罚",
"神寂",
"劫烬",
"道陨",
"无情铁御",
"褪色者",
"七日杀",
"长生",
"狱門疆",
"伏魔御厨子",
"嵌合暗翳庭",
"裂穹",
"弑道",
"封魔",
"碎星",
"玄元道印",
"诸神黄昏",
"青冥道果",
"噬仙印",
"·---特殊掉落（六）---",
"圣光誓约",
"天恩圣符",
"净世真言",
"荣耀之证",
"深渊凝视",
"亡语回响",
"血祭残章",
"混沌余烬",
"古神语",
"虚空裂隙",
"禁忌之书",
"旧日契约",
"幻梦之钥",
"残响",
"虚骸",
"蚀骨",
"冥契",
"罪印",
"魂锁",
"暗核",
"星骸",
"异星之骸",
"虚空之光",
"界域之核",
"空界之芯",
"·---特殊掉落（七）---",
"封龙劍メ驱逐之刃",
"安晓的右眼",
"安晓的左眼",
"异空：千年之光",
"狂怒护手",
"狂意之怒",
"魔渊面具",
"「无情」",
"咆哮之意",
"抉择",
"啸之戒指",
"时间锁",
"轮回沙漏",
"法师拳套",
"半兽人之心",
"天启星魂",
"恶之握",
"戰場之靴",
"禁言",
"无面恐惧",
"命运的轮转",
"起源·无尽幻境",
"厄运代言人",
"龙之力·不灭光剑!",
"黄昏落幕ぁ",
"·---特殊掉落（八）---",
"群星之怒★★★",
"夜风·不败剑意",
"星辉的祷告乀",
"御天机",
"哨兵之首",
"无序战盔",
"生灵·屠杀",
"星神之坠",
"新月领域△核心",
"幕轮",
"狂魔·永夜",
"贪婪之噬",
"影幕之指",
"★★星魂永燃★★",
"无序的邪力",
"无序的凝视",
"刺·束缚之隐",
"无序◎奥秘",
"『神耀』",
"悟道神带",
"原初■混乱■",
"血奴印记",
"混乱制造者",
"诛伏赐死",
"新月头盔[月灵]",
"新月项链[月灵]",
"醉月手镯[魂灭]",
"醉月戒指[魂灭]",
"风月腰带[魂生]",
"风月鞋子[魂生]",
"·---特殊掉落（九）---",
"巨象之环",
"悸动★飞沙",
"天魁＂湮灭",
"地苍·岩落",
"水泽·魂之护",
"「恆古·碧波」",
"自作·无铭",
"诸神之智·暗靈",
"奇迹之金刃圣剑",
"咒怨劫·镜铁戒",
"『巨兽之威』",
"统御之灵「融合」",
"暴怒の罪",
"风息ぺ漩涡",
"★天之苍·碧落★",
"风暴之心·穹霄",
"べ雷王之冠★",
"极乐之界",
"色欲の罪",
"九霄雷动·氤氲之行",
"山岳の指环",
"靈-末日浮屠",
"山之护·星际瑰宝",
"無穹￠焚天",
"無穹￠寒祇",
"贪婪の罪",
"傲慢の罪",
"暴食の罪",
"嫉妒の罪",

        }
        for k, v in pairs(cailiao) do
            giveitem(play,v,1)
        end
    elseif id == "24" then
        -- 测试脚本：调整地图怪物密度（逐图刷小怪，9x9检测饱和）
--         local map_list = {
--             -- "山庄",
--             -- "幽谷",
--             -- "洞穴",
--             -- "古殿",
--             -- "山庄一",
--             -- "幽谷一",
--             -- "洞穴一",
--             -- "古殿一",
--             -- "隐藏地图二",
--             -- "野火帮",
--             -- "野火帮大营",
--             -- "极光城郊",
--             -- "神秘森林",
--             -- "兵道古藏",
--             -- "乱葬岗",
--             -- "夜魔洞",
--             -- "洞穴深处",
--             -- "洞穴秘境",

-- --             "灰界",
-- -- "灰界南部",
-- -- "灰界北部",
-- -- "灰界东部",
-- -- "灰界西部",
-- -- "虚妄山脉",
-- -- "鬼嘲深渊",
-- -- "叹息旷野",
-- -- "禁忌之海",
-- -- "藏星海",
-- -- "藏星外海",
-- -- "神秘岛屿",
-- -- "黑暗洞窟",
-- -- "千年沉船",
-- -- "船长室",
-- -- "水手舱",
-- -- "藏星内海",
-- -- "七星岛",
-- -- "葬星城",
-- -- "葬星海滩",
-- -- "葬星海滩1",
-- -- "苍云城",
-- -- "苍云城郊外",
-- -- "苍云内城",
-- -- "苍云客栈",
-- -- "草药谷",
-- -- "仙草田",
-- -- "草药古深处",
-- -- "丹道古藏",
-- -- "酆都鬼城",
-- -- "鬼门关",
-- -- "黄泉路",
-- -- "奈何桥",
-- -- "罗酆六天",
-- -- "十八层地狱",
-- -- "六道轮回",
-- -- "大唐·长安城",
-- -- "东海龙宫",
-- -- "黑风山",
-- -- "黄风岭",
-- -- "女儿国",
-- -- "通天河",
-- -- "狮驼岭",
-- -- "天竺山",
-- -- "火焰山",
-- -- "生肖灵域",
-- -- "灵域·一层",
-- -- "子鼠灵域",
-- -- "丑牛灵域",
-- -- "寅虎灵域",
-- -- "卯兔灵域",
-- -- "灵域·二层",
-- -- "辰龙灵域",
-- -- "巳蛇灵域",
-- -- "午马灵域",
-- -- "未羊灵域",
-- -- "灵域·三层",
-- -- "申猴灵域",
-- -- "酉鸡灵域",
-- -- "戌狗灵域",
-- -- "亥猪灵域",
-- -- "灵域·秘境",
-- -- "传说之地",
-- -- "盘古开天",
-- -- "羿射九日",
-- -- "不周山",
-- -- "女娲补天",
-- -- "黑白无常",
-- -- "后土娘娘",
-- -- "真假玉帝",
-- -- "白蛇传说",
-- -- "灵兽谷",
-- -- "青龙之境",
-- -- "朱雀之境",
-- -- "玄武之境",
-- -- "白虎之境",
-- -- "麒麟之境",
-- -- "时空裂隙",
-- -- "倚天江湖",
-- -- "冰火岛",
-- -- "光明顶",
-- -- "三国乱世",
-- -- "虎牢关",
-- -- "赤壁",
-- -- "水浒再临",
-- -- "景阳冈",
-- -- "狮子楼",
-- -- "生命边界",
-- -- "白骨神庙",
-- -- "神庙暗廊",
-- -- "诡冥墨河",
-- -- "河神寝宫",
-- -- "赤焰焚殿",
-- -- "赤焰焚殿二层",
-- -- "赤焰焚殿三层",
-- -- "葬天旧土",
-- -- "聊斋志异",
-- "兰若寺",
-- "画壁",
-- "崂山",
-- "罗刹海市",
-- "敦煌遗梦",
-- "莫高窟",
-- "月牙泉",
-- "玉门关",
-- "阳关道",
-- "世界禁墟",
-- "大地禁墟一层",
-- "大地禁墟二层",
-- "大地禁墟三层",
-- "天空禁墟一层",
-- "天空禁墟二层",
-- "天空禁墟三层",
-- "海洋禁墟一层",
-- "海洋禁墟二层",
-- "海洋禁墟三层",
-- "青铜禁墟一层",
-- "青铜禁墟二层",
-- "青铜禁墟三层",
--         } -- TODO: 填入要调整的地图名
--         local normal_mobs = {"枯灯客"} -- TODO: 普通怪列表

--         local range = 3 -- 刷怪点随机半径
--         local check_range = 6 -- 9x9检测半径(2*4+1)
--         local max_fail = 40 -- 连续失败上限(饱和)
--         local tries_per_spawn = 10 -- 每次刷怪找点尝试次数
--         local spawn_limit = 5000 -- 每张地图单次补怪上限

--         for _, map in ipairs(map_list) do
--             local w = getmapinfo(map, 0) or 0
--             local h = getmapinfo(map, 1) or 0
--             if w > 0 and h > 0 then
--                 -- 检测前先清空地图怪物
--                 killmonsters(map, "*", 0, false)

--                 local counter = {n = 0}
--                 local added_normal = 0
--                 local sample_count = 0
--                 local total_ncnt = 0

--                 local fail_streak = 0
--                 local used_points = {}

--                 while fail_streak < max_fail do
--                     local rx = math.random(1, w)
--                     local ry = math.random(1, h)

--                     local key = rx.."_"..ry
--                     if used_points[key] then
--                         fail_streak = fail_streak + 1
--                     else
--                         local ok = true
--                         for k, _ in pairs(used_points) do
--                             local sx, sy = k:match("(%d+)_([%d]+)")
--                             if sx and sy then
--                                 sx = tonumber(sx)
--                                 sy = tonumber(sy)
--                                 if math.abs(rx - sx) <= check_range and math.abs(ry - sy) <= check_range then
--                                     ok = false
--                                     break
--                                 end
--                             end
--                         end

--                         if ok then
--                             genmonex(map, rx, ry, normal_mobs[math.random(1, #normal_mobs)], 1, 1, 0, 54, "", 0)
--                             used_points[key] = true
--                             counter.n = counter.n + 1
--                             added_normal = added_normal + 1
--                             fail_streak = 0
--                         else
--                             fail_streak = fail_streak + 1
--                         end
--                     end

--                     sample_count = sample_count + 1
--                     total_ncnt = total_ncnt + (used_points[key] and 1 or 0)

--                     if counter.n >= spawn_limit then
--                         break
--                     end
--                 end
--                     local avg_n = math.floor(total_ncnt / math.max(1, sample_count) + 0.5)
--                     sendmsg(play, 1, "{\"Msg\":\"<font color=\\\"#00ff00\\\">地图["..map.."] 小怪补："..added_normal.." 当前平均："..avg_n.."</font>\",\"Type\":9}")
--                     release_print("地图["..map.."] 小怪补："..added_normal)
--                     release_print("当前平均 小怪："..avg_n)
--             else
--                 sendmsg(play, 1, '{"Msg":"<font color=\"#ff0000\">地图['..map..']尺寸获取失败</font>","Type":9}')
--             end
--         end
--         return
        -- local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
        -- jq_data["npc_714"] = nil
        -- Player.setJsonTableByVar(play, VarCfg.T_dljq, jq_data)
        -- local sg_data = Player.getJsonTableByVar(play, VarCfg["T_各剧情杀怪"])
        -- sg_data["npc_696"] = sg_data["npc_696"] + 100
        -- Player.setJsonTableByVar(play, VarCfg["T_各剧情杀怪"], sg_data)
        		-- sendmsgnew(play, 255, 0, '狂暴之力：玩家{《' .. getbaseinfo(play, 1) .. '》/FCOLOR=251}成功开启{[狂暴之力]/FCOLOR=250},击杀此人可获得额外奖励...', 1, 3)

        ---文字测试 
        -- 飘字测试请点上方按钮：@ggn,14
        -- Npclib[654].link(play, 654, 1, 0, "")

        -- local where = Player.hasEquipInArtifactSlot(play, "金箍棒")
        -- -- release_print(where)
        -- if not where then
        --     Player.sendmsgEx(play, "你需要装备金箍棒才能完成任务#57")
        --     return
        -- end
        -- local itemobj = linkbodyitem(play,where)
        -- local item_json = getitemcustomabil(play, itemobj)
        -- release_print(item_json)
        -- item_json = json2tbl(item_json)
        -- if item_json then
        --     item_json = json2tbl('{"abil":[{"i":0,"t":"[附加属性]","c":251,"v":[]}],"name":""}')
        -- end
        -- item_json.abil[1].v[1] = {1,253,200,1,13,1,1}
        -- item_json.abil[1].v[2] = {1,200,300,1,14,2,2}
        -- item_json.abil[1].v[3] = {1,244,8000,0,15,3,3}
        -- item_json.abil[1].v[4] = {1,30,5,1,16,4,4}
        -- item_json.abil[1].v[5] = {1,73,100,1,17,5,5}
        -- item_json.abil[1].v[6] = {1,89,100,1,18,6,6}
        -- item_json.abil[1].v[7] = {1,206,100,1,19,7,7}
        -- item_json = tbl2json(item_json)
        -- -- release_print(type(item_json))
        -- setitemcustomabil(play, itemobj, item_json)
        -- Player.setJsonVarByTable(play, VarCfg["T_砍树系统"], {})
        -- setplaydef(play, VarCfg.T_czlb,"{}")
        -- setplaydef(play,VarCfg.U_zxrw[1],21)
        -- setplaydef(play,VarCfg.T_hsdg, '{"1_1_1":1,"1_1_2":1,"1_1_3":1,"1_1_4":1,"1_1_5":1,"1_1_6":1,"1_1_7":1,"1_1_8":1,"1_1_9":1,"1_1_10":1,"1_1_11":1,"1_1_12":1}')--回收打勾

    end

end

return npc














