release_print("加载Buff模块")
local function _huti_set_trigger(play, varName, buffId, enable)
    local bl = getplaydef(play, varName)
    local data = json2tbl(bl == "" and {} or bl)
    if enable then
        data[tostring(buffId)] = true
    else
        data[tostring(buffId)] = nil
    end
    setplaydef(play, varName, tbl2json(data))
end
local function _huti_monster_type(obj)
    if not obj or getbaseinfo(obj, -1) then
        return nil
    end
    local name = getbaseinfo(obj, 1)
    if not name or name == "" then
        return nil
    end
    return guaiwutype and guaiwutype[name] or nil
end
local function _toggle_buff_var(play, varName, buffId, enable)
    local bl = getplaydef(play, varName)
    local data = json2tbl(bl == "" and {} or bl)
    if enable then
        data[tostring(buffId)] = true
    else
        data[tostring(buffId)] = nil
    end
    setplaydef(play, varName, tbl2json(data))
end
local function _set_title_buff_flag(play, buffId, enable)
    setplaydef(play, "N$buff" .. tostring(buffId), enable and 1 or 0)
end
local function _has_title_buff_flag(play, buffId)
    return (tonumber(getplaydef(play, "N$buff" .. tostring(buffId)) or 0) or 0) == 1
end
local function _title_all_percent_attr(percent)
    local ids = {280, 281, 282, 283, 284, 285, 286, 287, 288, 289, 290, 291, 300}
    local arr = {}
    for _, id in ipairs(ids) do
        arr[#arr + 1] = "3#" .. id .. "#" .. percent
    end
    return table.concat(arr, "|")
end
local function _title_sync_time_attr(play, buffId, attrListName, attrStr, mode)
    if not _has_title_buff_flag(play, buffId) then
        Player.del_attlist(play, attrListName)
        return false
    end
    local hour = tonumber(os.date("%H")) or 0
    local enable = false
    if mode == "day" then
        enable = hour >= 6 and hour < 18
    elseif mode == "night" then
        enable = not (hour >= 6 and hour < 18)
    else
        enable = true
    end
    if enable then
        Player.add_attlist(play, attrListName, "=", attrStr, 1)
    else
        Player.del_attlist(play, attrListName)
    end
    return enable
end
local function _title_sync_dadi_attr(play)
    local stack = tonumber(getplaydef(play, "N$buff328_stack") or 0) or 0
    if not _has_title_buff_flag(play, 328) then
        stack = 0
    end
    if stack < 0 then
        stack = 0
    elseif stack > 10 then
        stack = 10
    end
    setplaydef(play, "N$buff328_stack", stack)
    if stack > 0 then
        Player.add_attlist(play, "title_dadi_stack", "=", _title_all_percent_attr(stack), 1)
    else
        Player.del_attlist(play, "title_dadi_stack")
    end
end
local function _gcmp_refresh_item(play)
    local stack = tonumber(getplaydef(play, "N$buff340_stack") or 0) or 0
    if stack < 0 then
        stack = 0
    end
    setplaydef(play, "N$buff340_stack", stack)
    if not _has_title_buff_flag(play, 340) then
        return
    end
    local where = Player.hasEquipInArtifactSlot(play, "古刹魔瓶")
    if not where then
        return
    end
    local itemobj = linkbodyitem(play, where)
    if not itemobj or itemobj == "0" then
        return
    end
    local ok, item_json = pcall(json2tbl, getitemcustomabil(play, itemobj))
    item_json = ok and type(item_json) == "table" and item_json or nil
    if not item_json or type(item_json.abil) ~= "table" then
        item_json = json2tbl('{"abil":[{"i":0,"t":"[古刹切割]","c":251,"v":[]}],"name":""}')
    end
    item_json.name = tostring(item_json.name or "")
    local idx = nil
    local abil_i = nil
    for i, v in ipairs(item_json.abil) do
        if type(v) == "table" and tostring(v.t or "") == "[古刹切割]" then
            idx = i
            abil_i = tonumber(v.i) or (i - 1)
            break
        end
    end
    if not idx then
        for i, v in ipairs(item_json.abil) do
            if type(v) == "table" and tostring(v.t or "") == "" and next(v.v or {}) == nil then
                idx = i
                abil_i = tonumber(v.i) or (i - 1)
                break
            end
        end
    end
    if not idx then
        idx = #item_json.abil + 1
        abil_i = idx - 1
    end
    local attr_list = {}
    if stack > 0 then
        table.insert(attr_list, {254, 244, stack, 0, 20, 1, 1})
    end
    item_json.abil[idx] = {i = abil_i or (idx - 1), t = "[古刹切割]", c = 251, v = attr_list}
    setitemcustomabil(play, itemobj, tbl2json(item_json))
    setcustomitemprogressbar(play, itemobj, 0, tbl2json({
        ["open"] = 1,
        ["show"] = 0,
        ["name"] = string.format("古刹切割：+%d", stack),
        ["color"] = 251,
        ["imgcount"] = 1,
    }))
    refreshitem(play, itemobj)
end
local function _tianshu_buff_splash(play, Target)
    -- release_print("触发天书溅射buff")
    if not play or not Target or getbaseinfo(Target, ConstCfg.gbase.isplayer) then
        return
    end
    local cfg = teshudata and teshudata["npc_24"] or nil
    if not cfg then
        return
    end
    local T_data = Player.getJsonTableByVar(play, VarCfg["T_天书"]) or {}
    local level = tonumber(T_data.level) or 0
    if level <= 0 then
        return
    end
    local rate = (tonumber(cfg.splash_base_rate) or 10) + math.max(0, level - 1) * (tonumber(cfg.splash_add_rate) or 2)
    local maxRate = tonumber(cfg.splash_max_rate) or 110
    if rate > maxRate then
        rate = maxRate
    end
    local damage = math.floor((tonumber(getbaseinfo(play, ConstCfg.gbase.dc2) or 0) or 0) * rate / 100)
    if damage <= 0 then
        return
    end
    rangeharm(play, getbaseinfo(Target, ConstCfg.gbase.x), getbaseinfo(Target, ConstCfg.gbase.y), tonumber(cfg.splash_range) or 2, damage, 0, 0, 0, 2, tonumber(cfg.splash_effect) or 20310, tonumber(cfg.splash_max_targets) or 12)
    local splash_effect_cd = tonumber(getplaydef(play, "N$天书溅射特效CD") or 0) or 0
    local now = os.time()
    if now - splash_effect_cd >= 5 then
        setplaydef(play, "N$天书溅射特效CD", now)
        playeffect(Target, tonumber(cfg.splash_hit_effect) or 60463, 0, 0, 1, 1, 0)
    end
    -- Player.sendmsgEx(play,"【帝疆】#253|触发，范围造成"..damage.."点真实伤害")
end
Buff = {
    [70] = function(play,zt)      --被人物攻击随机(CD30秒)
        if zt == 3 then
            local sj = os.time()
            if sj - getplaydef(play,"N$buff70cd") > 30 then
                setplaydef(play,"N$buff70cd",sj)
                map(play,getbaseinfo(play,3))
            end
            return 0
        else
            local bl = getplaydef(play,VarCfg.S_buffbrwq)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["70"] = true
                setplaydef(play,"N$buff70cd",os.time())
            elseif zt == 2 then
                data["70"] = nil
            end
            setplaydef(play,VarCfg.S_buffbrwq,tbl2json(data))
        end
    end,
    [71] = function(play,zt,Damage,Target)      --溅射伤害  打怪时5%触发闪电，电击自身8*8范围内的所有敌人，造成500真实伤害拉取怪物仇恨。
        if zt == 3 then
            local sj = os.time()
            if sj - getplaydef(play,VarCfg.N_jsys) > 6 and math.random(100) > 5 then
                setplaydef(play,VarCfg.N_jsys,sj)
                local xx,yy,dqdt = getbaseinfo(play,4),getbaseinfo(play,5),getbaseinfo(play,3)
                local mons,gjsx = getobjectinmap(dqdt, xx,yy, 10, 2),500
                rangeharm(play,getbaseinfo(play,4),getbaseinfo(play,5),6,0,0,0,0,2,20310)
                if #mons > 1 then
                    for i, v in ipairs(mons) do
                        if i < 20 then
                            if Target ~= v then
                                humanhp(v,"-",500,108,0,play)
                                monmission(v,getbaseinfo(play,4)-3,getbaseinfo(play,5)-3,0)
                            end
                        end
                    end
                end
            end
        else
            local bl = getplaydef(play,VarCfg.S_buffgwh)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["71"] = true
            elseif zt == 2 then
                data["71"] = nil
            end
            setplaydef(play,VarCfg.S_buffgwh,tbl2json(data))
        end
    end,
    [72] = function(play,zt)      --AI挂机,被攻击自动随机
        if zt == 3 then
            local sj = os.time()
            local json = json2tbl(getplaydef(play,VarCfg.T_aigj))
            if sj - getplaydef(play,VarCfg.N_Aigj[1]) >= 60 and not getbaseinfo(play,0) and json.gjkg then
                setplaydef(play,VarCfg.N_Aigj[1],sj)
                map(play,getbaseinfo(play,3))
                sendmsg(play,1,'{"Msg":"<font color=\'#28ef01\'>AI挂机：被人物攻击自动随机！</font>","Type":9}')
                startautoattack(play)
            end
            return 0
        else
            local bl = getplaydef(play,VarCfg.S_buffbrwq)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["72"] = true
            elseif zt == 2 then
                data["72"] = nil
            end
            setplaydef(play,VarCfg.S_buffbrwq,tbl2json(data))
        end
    end,
    [73] = function(play,zt,Damage,Target)      --赠送属性,刀刀绿毒
        if zt == 3 then
            makeposion(Target,0,2,10)
        else
            local bl = getplaydef(play,VarCfg.S_buffgwh)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["73"] = true
            elseif zt == 2 then
                data["73"] = nil
            end
            setplaydef(play,VarCfg.S_buffgwh,tbl2json(data))
        end
    end,
    --
    --callscriptex(play,"SETMAGICSKILLEFFT","野蛮冲撞",2704)
    --callscriptex(play,"SETMAGICSKILLEFFT","烈火剑法",2604)
    --callscriptex(play,"SETMAGICSKILLEFFT","逐日剑法",5602)
    --callscriptex(play,"SETMAGICSKILLEFFT","开天斩",6604)
    [74] = function(play,zt,Damage,Target,MagicId)      --攻杀剑术额外附加自身攻击上限35%的真实伤害
        if zt == 3 then
            if MagicId == 7 then
                humanhp(Target,"-",math.floor(getbaseinfo(play, 20)*0.35))
            end
        else
            local bl = getplaydef(play,VarCfg.S_buffgjh)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["74"] = true
            elseif zt == 2 then
                data["74"] = nil
            end
            setplaydef(play,VarCfg.S_buffgjh,tbl2json(data))
        end
    end,
    [75] = function(play,zt,Damage,Target,MagicId)      --刺杀剑术有5%的几率使目标受到的伤害翻倍
        if zt == 3 then
            if MagicId == 12 then
                if math.random(100) <= 5 then
                    return Damage
                end
            end
            return 0
        else
            local bl = getplaydef(play,VarCfg.S_buffgjq)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["75"] = true
            elseif zt == 2 then
                data["75"] = nil
            end
            setplaydef(play,VarCfg.S_buffgjq,tbl2json(data))
        end
    end,
    [76] = function(play,zt,Damage,Target,MagicId)      --半月弯刀攻击目标时，有20%的几率使攻击速度+2.持续5秒
        if zt == 3 then
            if MagicId == 25 then
                if math.random(100) <= 20 then
                    addbuff(play, 20101)
                end
            end
        else
            local bl = getplaydef(play,VarCfg.S_buffgjh)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["76"] = true
            elseif zt == 2 then
                data["76"] = nil
            end
            setplaydef(play,VarCfg.S_buffgjh,tbl2json(data))
        end
    end,
    [77] = function(play,zt,Damage,Target,MagicId)      --烈火剑法点燃被击中的目标3秒，没秒减少等同于释放者攻击上限20%的生命
        if zt == 3 then
            if MagicId == 26 then
                humanhp(Target,"-",math.floor(getbaseinfo(play, 20)*0.2),112,1,play)
                humanhp(Target,"-",math.floor(getbaseinfo(play, 20)*0.2),112,2,play)
                humanhp(Target,"-",math.floor(getbaseinfo(play, 20)*0.2),112,3,play)
            end
        else
            local bl = getplaydef(play,VarCfg.S_buffgjh)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["77"] = true
            elseif zt == 2 then
                data["77"] = nil
            end
            setplaydef(play,VarCfg.S_buffgjh,tbl2json(data))
        end
    end,
    [78] = function(play,zt,Damage,Target,MagicId)      --开天斩命中目标后，使目标5秒内降低20%的防御
        if zt == 3 then
            if MagicId == 66 then
                addbuff(Target, 20102)
            end
        else
            local bl = getplaydef(play,VarCfg.S_buffgjh)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["78"] = true
            elseif zt == 2 then
                data["78"] = nil
            end
            setplaydef(play,VarCfg.S_buffgjh,tbl2json(data))
        end
    end,
    [79] = function(play,zt,Damage,Target,MagicId)      --逐日剑法击中的目标为玩家时，有35%的几率使其额外减少当前HP10%的生命
        if zt == 3 then
            if MagicId == 56 then
                if getbaseinfo(Target,ConstCfg.gbase.isplayer) then
                    if math.random(100) <= 35 then
                        humanhp(Target,"-",math.floor(getbaseinfo(Target,11)*0.1))
                    end
                end
            end
        else
            local bl = getplaydef(play,VarCfg.S_buffgjh)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["79"] = true
            elseif zt == 2 then
                data["79"] = nil
            end
            setplaydef(play,VarCfg.S_buffgjh,tbl2json(data))
        end
    end,
    [107] = function(play,zt,Damage,Target,MagicId) --护体光环1：每3刀额外造成1000伤害
        if zt == 3 then
            local cnt = (tonumber(getplaydef(play, 'N$buff107_hit') or 0) or 0) + 1
            setplaydef(play, 'N$buff107_hit', cnt)
            if cnt % 3 == 0 then
                return 1000
            end
            return 0
        else
            _huti_set_trigger(play, VarCfg.S_buffgwq, 107, zt == 1)
        end
    end,
    [108] = function(play,zt,Damage,Target,MagicId) --护体光环2：对白怪切割+8888
        if zt == 3 then
            if _huti_monster_type(Target) == 1 then
                return 8888
            end
            return 0
        else
            _huti_set_trigger(play, VarCfg.S_buffgwq, 108, zt == 1)
        end
    end,
    [109] = function(play,zt,Damage,Target,MagicId) --护体光环2：格挡怪物伤害+888
        if zt == 3 then
            if _huti_monster_type(Target) ~= nil then
                return 888
            end
            return 0
        else
            _huti_set_trigger(play, VarCfg.S_buffbgwq, 109, zt == 1)
        end
    end,
    [110] = function(play,zt,Damage,Target,MagicId) --护体光环3：BOSS血量低于3%直接斩杀
        if zt == 3 then
            if _huti_monster_type(Target) == 2 then
                local curhp = tonumber(getbaseinfo(Target, 9) or 0) or 0
                local maxhp = tonumber(getbaseinfo(Target, 10) or 0) or 0
                if curhp > 0 and maxhp > 0 and curhp * 100 <= maxhp * 3 then
                    humanhp(Target, "-", curhp, 107, 0, play, 1)
                end
            end
            return 0
        else
            _huti_set_trigger(play, VarCfg.S_buffgwq, 110, zt == 1)
        end
    end,
    [301] = function(play,zt,Damage,Target,MagicId,Model) --天书仙法攻击触发
        -- zt=1/2：注册或移除攻击触发；zt=3：攻击回调并返回额外伤害
        if zt == 3 then
            _tianshu_buff_splash(play, Target)
            if xianfa_attack_trigger then
                return xianfa_attack_trigger(play, Damage, Target, MagicId, Model) or 0
            end
            return 0
        else
            local bl = getplaydef(play,VarCfg.S_buffgjq)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["301"] = true
            elseif zt == 2 then
                data["301"] = nil
            end
            setplaydef(play,VarCfg.S_buffgjq,tbl2json(data))
        end
    end,
    [302] = function(play,zt) --天书仙法复活触发
        -- zt=1/2：注册或移除复活触发；zt=4：复活后回调
        if zt == 4 then
            if xianfa_revive_trigger then
                xianfa_revive_trigger(play)
            end
        else
            local bl = getplaydef(play,VarCfg.S_bufffuhuo)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["302"] = true
            elseif zt == 2 then
                data["302"] = nil
            end
            setplaydef(play,VarCfg.S_bufffuhuo,tbl2json(data))
        end
    end,
    [303] = function(play,zt,Damage,Target) --诅咒傀儡：攻击怪物触发(zt=3)，10%概率上绿毒，10秒内置CD
        if zt == 3 then
            local now = os.time()
            if now - (getplaydef(play,"N$buff303cd") or 0) < 10 then
                return 0
            end
            if Target and math.random(100) <= 10 then
                setplaydef(play,"N$buff303cd",now)
                makeposion(Target,0,2,10)
            end
        else
            local bl = getplaydef(play,VarCfg.S_buffgwh)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["303"] = true
            elseif zt == 2 then
                data["303"] = nil
            end
            setplaydef(play,VarCfg.S_buffgwh,tbl2json(data))
        end
    end,
    [304] = function(play,zt,Damage,Target) --已取真经：攻击怪物触发(zt=3)，1%概率按目标最大HP的10%切割，10秒内置CD
        if zt == 3 then
            local now = os.time()
            if now - (getplaydef(play,"N$buff304cd") or 0) < 10 then
                return 0
            end
            if Target and math.random(100) <= 1 then
                if not getbaseinfo(Target,ConstCfg.gbase.isplayer) then
                    setplaydef(play,"N$buff304cd",now)
                    humanhp(Target,"-",math.floor(getbaseinfo(Target,11)*0.1))
                end
            end
        else
            local bl = getplaydef(play,VarCfg.S_buffgjh)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["304"] = true
            elseif zt == 2 then
                data["304"] = nil
            end
            setplaydef(play,VarCfg.S_buffgjh,tbl2json(data))
        end
    end,
    [305] = function(play,zt) --天蛇的认可：隐身效果占位，仅记录开关，具体隐身逻辑待接入
        if zt == 1 then
            setplaydef(play,"N$buff305",1)
        elseif zt == 2 then
            setplaydef(play,"N$buff305",0)
        end
    end,
    [306] = function(play,zt) --黑化肥会挥发：仙草成熟/炼丹加成；仅记录开关，逻辑由炼丹/种植处读取
        if zt == 1 then
            setplaydef(play,"N$buff306",1)
        elseif zt == 2 then
            setplaydef(play,"N$buff306",0)
        end
    end,
    [307] = function(play,zt) --定风珠：黄风谷/风灵珠试炼通行占位，仅记录开关
        if zt == 1 then
            setplaydef(play,"N$buff307",1)
        elseif zt == 2 then
            setplaydef(play,"N$buff307",0)
        end
    end,
    [308] = function(play,zt) --金箍棒：击杀附魔记录占位，仅记录开关
        if zt == 1 then
            setplaydef(play,"N$buff308",1)
        elseif zt == 2 then
            setplaydef(play,"N$buff308",0)
        end
    end,
    [309] = function(play,zt) --我是许仙：复活触发(zt=4) 1%概率不消耗复活次数，10秒内置CD
        if zt == 4 then
            local now = os.time()
            if now - (getplaydef(play,"N$buff309cd") or 0) < 10 then
                return 0
            end
            if math.random(100) <= 1 then
                setplaydef(play,"N$buff309cd",now)
                -- 标记本次复活不消耗次数（由下方立即处理一次）
                setplaydef(play,"N$buff309_free",1)
            end
            if getplaydef(play,"N$buff309_free") == 1 then
                -- 直接补回一次复活次数（避免本次消耗）
                setplaydef(play,"N$buff309_free",0)
                local cur = querymoney(play,15)
                local max = querymoney(play,14)
                if cur < max then
                    changemoney(play,15,"+",1,"BUFF309",true)
                end
                changemode(play,23,999999999,querymoney(play,15))
            end
            return 0
        end
        if zt == 1 then
            setplaydef(play,"N$buff309",1)
        elseif zt == 2 then
            setplaydef(play,"N$buff309",0)
        end
    end,
    [310] = function(play,zt) --来去自如：传送冷却-5秒；仅记录开关，传送逻辑读取该标记
        if zt == 1 then
            setplaydef(play,"N$buff310",1)
        elseif zt == 2 then
            setplaydef(play,"N$buff310",0)
        end
    end,
    [311] = function(play,zt) --头号玩家：红色仙法概率+20%；仅记录开关，抽取逻辑读取该标记
        if zt == 1 then
            setplaydef(play,"N$buff311",1)
        elseif zt == 2 then
            setplaydef(play,"N$buff311",0)
        end
    end,
    [312] = function(play,zt) --丹仙秘辛：丹药持续+50%/炼丹消耗-50%；仅记录开关，丹药/炼丹逻辑读取
        if zt == 1 then
            setplaydef(play,"N$buff312",1)
        elseif zt == 2 then
            setplaydef(play,"N$buff312",0)
        end
    end,
    [313] = function(play,zt) --阴阳玉佩：按时间切换属性（06-18阳：对怪攻速+10%，18-06阴：打怪爆率+10%）
        local function _apply(mode)
            if mode == 1 then
                Player.add_attlist(play, "阴阳玉佩_阳", "=", "3#200#1000", 1)
                Player.del_attlist(play, "阴阳玉佩_阴")
            else
                Player.add_attlist(play, "阴阳玉佩_阴", "=", "3#242#1000", 1)
                Player.del_attlist(play, "阴阳玉佩_阳")
            end
        end
        if zt == 1 then
            local h = tonumber(os.date("%H")) or 0
            local mode = (h >= 6 and h < 18) and 1 or 2
            setplaydef(play,"N$buff313",1)
            setplaydef(play,"N$buff313mode",mode)
            _apply(mode)
        elseif zt == 2 then
            setplaydef(play,"N$buff313",0)
            Player.del_attlist(play, "阴阳玉佩_阳")
            Player.del_attlist(play, "阴阳玉佩_阴")
        elseif zt == 3 then
            if getplaydef(play,"N$buff313") == 1 then
                local h = tonumber(os.date("%H")) or 0
                local mode = (h >= 6 and h < 18) and 1 or 2
                if getplaydef(play,"N$buff313mode") ~= mode then
                    setplaydef(play,"N$buff313mode",mode)
                    _apply(mode)
                end
            end
        end
    end,
    [314] = function(play,zt) --胖娃的肚兜：奇遇概率+10%占位，仅记录开关
        if zt == 1 then
            setplaydef(play,"N$buff314",1)
        elseif zt == 2 then
            setplaydef(play,"N$buff314",0)
        end
    end,
    [315] = function(play,zt,Damage,Target) --打怪，单体目标 BUFF：攻击有5%的概率附带[打怪切割+攻击力]x Y%的真实伤害  切割之斧的buff
        if zt == 3 then
            if not Target or getbaseinfo(Target,ConstCfg.gbase.isplayer) then
                return 0
            end
            if math.random(100) > 5 then
                return 0
            end
            local cutDamage = tonumber(getbaseinfo(play, 51, 244) or 0) or 0
            local atkDamage = tonumber(getbaseinfo(play, 20) or 0) or 0
            local axeLevel = tonumber(Player.getEquipFieldByPos(play, 9, 1) or 0) or 0
            local axeRatio = axeLevel > 0 and (10 + (axeLevel - 1) * 5) or 0
            local extraDamage = math.floor((cutDamage + atkDamage) * axeRatio / 100)
            if extraDamage < 0 then
                extraDamage = 0
            end
            if extraDamage > 0 then
                Player.sendmsgEx(play,"【毁灭】#253|切割之斧触发，额外造成"..extraDamage.."点真实伤害")
                playeffect(Target,60456,0,0,1,0,0)
            end
            return extraDamage
        else
            local bl = getplaydef(play,VarCfg.S_buffgjq)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["315"] = true
            elseif zt == 2 then
                data["315"] = nil
            end
            setplaydef(play,VarCfg.S_buffgjq,tbl2json(data))
        end
    end,
    -- 316~338：称号/活动类 BUFF
    -- 说明：
    -- 1. zt == 1 表示获得称号或登录补挂时启用效果
    -- 2. zt == 2 表示失去称号时移除效果
    -- 3. zt == 3 表示战斗阶段的实时触发，用于追加伤害/回血等逻辑
    -- 4. 纯标记型称号只记录 N$buffxxx 状态，具体数值由称号属性表或其他流程处理
    [316] = function(play,zt) -- 镇杀幽魂：标记型BUFF，实际常驻属性由称号表提供
        if zt == 1 then
            _set_title_buff_flag(play, 316, true)
        elseif zt == 2 then
            _set_title_buff_flag(play, 316, false)
        end
    end,
    [317] = function(play,zt) -- 画中仙境：标记型BUFF，免控类判定可从该状态继续扩展
        if zt == 1 then
            _set_title_buff_flag(play, 317, true)
        elseif zt == 2 then
            _set_title_buff_flag(play, 317, false)
        end
    end,
    [318] = function(play,zt) -- 崂山秘法：标记型BUFF，常驻属性由称号表提供
        if zt == 1 then
            _set_title_buff_flag(play, 318, true)
        elseif zt == 2 then
            _set_title_buff_flag(play, 318, false)
        end
    end,
    [319] = function(play,zt,Damage,Target,MagicId) -- 赤焰天使：烈火剑法额外增伤10%
        if zt == 3 then
            if MagicId == 26 and Damage and Damage > 0 then
                return math.floor(Damage * 0.1)
            end
            return 0
        end
        -- 挂到 S_buffgjq，确保登录后能重新注册攻击增伤逻辑
        _set_title_buff_flag(play, 319, zt == 1)
        _toggle_buff_var(play, VarCfg.S_buffgjq, 319, zt == 1)
    end,
    [320] = function(play,zt,Damage) -- 葬众生：血量低于30%时，攻击伤害额外+20%
        if zt == 3 then
            local maxhp = tonumber(getbaseinfo(play, (ConstCfg and ConstCfg.gbase and ConstCfg.gbase.maxhp) or 10) or 0) or 0
            local curhp = tonumber(getbaseinfo(play, (ConstCfg and ConstCfg.gbase and ConstCfg.gbase.curhp) or 11) or maxhp) or 0
            if maxhp > 0 and curhp / maxhp <= 0.3 and Damage and Damage > 0 then
                return math.floor(Damage * 0.2)
            end
            return 0
        end
        _set_title_buff_flag(play, 320, zt == 1)
        _toggle_buff_var(play, VarCfg.S_buffgjq, 320, zt == 1)
    end,
    [321] = function(play,zt) -- 小倩的感谢：夜晚对怪增伤+1%，打怪爆率+10%
        if zt == 3 then
            -- 夜晚时补上限时属性，白天会自动移除，避免属性常驻
            _title_sync_time_attr(play, 321, "title_321_night", "3#245#100|3#242#1000", "night")
            return 0
        end
        if zt == 1 then
            _set_title_buff_flag(play, 321, true)
            _title_sync_time_attr(play, 321, "title_321_night", "3#245#100|3#242#1000", "night")
            _toggle_buff_var(play, VarCfg.S_buffgwq, 321, true)
        elseif zt == 2 then
            _set_title_buff_flag(play, 321, false)
            Player.del_attlist(play, "title_321_night")
            _toggle_buff_var(play, VarCfg.S_buffgwq, 321, false)
        end
    end,
    [322] = function(play,zt) -- 守护壁画：标记型BUFF，常驻切割属性由称号表提供
        if zt == 1 then
            _set_title_buff_flag(play, 322, true)
        elseif zt == 2 then
            _set_title_buff_flag(play, 322, false)
        end
    end,
    [323] = function(play,zt) -- 以貌取人：白天对怪增伤+10%
        if zt == 3 then
            _title_sync_time_attr(play, 323, "title_323_day", "3#245#1000", "day")
            return 0
        end
        if zt == 1 then
            _set_title_buff_flag(play, 323, true)
            _title_sync_time_attr(play, 323, "title_323_day", "3#245#1000", "day")
            _toggle_buff_var(play, VarCfg.S_buffgwq, 323, true)
        elseif zt == 2 then
            _set_title_buff_flag(play, 323, false)
            Player.del_attlist(play, "title_323_day")
            _toggle_buff_var(play, VarCfg.S_buffgwq, 323, false)
        end
    end,
    [324] = function(play,zt) -- 迟来的清醒：夜晚对怪增伤+10%
        if zt == 3 then
            _title_sync_time_attr(play, 324, "title_324_night", "3#245#1000", "night")
            return 0
        end
        if zt == 1 then
            _set_title_buff_flag(play, 324, true)
            _title_sync_time_attr(play, 324, "title_324_night", "3#245#1000", "night")
            _toggle_buff_var(play, VarCfg.S_buffgwq, 324, true)
        elseif zt == 2 then
            _set_title_buff_flag(play, 324, false)
            Player.del_attlist(play, "title_324_night")
            _toggle_buff_var(play, VarCfg.S_buffgwq, 324, false)
        end
    end,
    [325] = function(play,zt,Damage,Target) -- 沙海明珠：攻击3%概率雷击怪物，并切割其最大生命3%
        if zt == 3 then
            if not Target or getbaseinfo(Target, ConstCfg.gbase.isplayer) then
                return 0
            end
            local now = os.time()
            -- 10秒公共CD，避免同一称号效果过于频繁触发
            if now - (tonumber(getplaydef(play, "N$buff325cd") or 0) or 0) < 10 then
                return 0
            end
            if math.random(100) <= 3 then
                setplaydef(play, "N$buff325cd", now)
                local maxhp = tonumber(getbaseinfo(Target, (ConstCfg and ConstCfg.gbase and ConstCfg.gbase.maxhp) or 10) or 0) or 0
                local hurt = math.floor(maxhp * 0.03)
                if hurt > 0 then
                    humanhp(Target, "-", hurt, 106, 0, play, 1)
                    playeffect(Target, 60463, 0, 0, 1, 0, 0)
                end
            end
            return 0
        end
        -- 挂到 S_buffgwh，确保登录后能重新注册攻击附加伤害逻辑
        _set_title_buff_flag(play, 325, zt == 1)
        _toggle_buff_var(play, VarCfg.S_buffgwh, 325, zt == 1)
    end,
    [326] = function(play,zt,Damage,Target) -- 丝路往事：攻击等级高于自身的玩家时，额外造成5%伤害
        if zt == 3 then
            if Target and getbaseinfo(Target, ConstCfg.gbase.isplayer) and Damage and Damage > 0 then
                local myLevel = tonumber(getbaseinfo(play, ConstCfg.gbase.level) or 0) or 0
                local targetLevel = tonumber(getbaseinfo(Target, ConstCfg.gbase.level) or 0) or 0
                if targetLevel > myLevel then
                    return math.floor(Damage * 0.05)
                end
            end
            return 0
        end
        _set_title_buff_flag(play, 326, zt == 1)
        _toggle_buff_var(play, VarCfg.S_buffgjq, 326, zt == 1)
    end,
    [327] = function(play,zt,Damage,Target) -- 你的因果我来抗：攻击满血玩家时，额外造成5%伤害
        if zt == 3 then
            if Target and getbaseinfo(Target, ConstCfg.gbase.isplayer) and Damage and Damage > 0 then
                local maxhp = tonumber(getbaseinfo(Target, (ConstCfg and ConstCfg.gbase and ConstCfg.gbase.maxhp) or 10) or 0) or 0
                local curhp = tonumber(getbaseinfo(Target, (ConstCfg and ConstCfg.gbase and ConstCfg.gbase.curhp) or 11) or 0) or 0
                if maxhp > 0 and curhp >= maxhp then
                    return math.floor(Damage * 0.05)
                end
            end
            return 0
        end
        _set_title_buff_flag(play, 327, zt == 1)
        _toggle_buff_var(play, VarCfg.S_buffgjq, 327, zt == 1)
    end,
    [328] = function(play,zt) -- 大地之王祝福：击杀玩家后每层全属性+1%，最多10层
        if zt == 1 then
            _set_title_buff_flag(play, 328, true)
            _title_sync_dadi_attr(play)
        elseif zt == 2 then
            _set_title_buff_flag(play, 328, false)
            setplaydef(play, "N$buff328_stack", 0)
            _title_sync_dadi_attr(play)
        end
    end,
    [329] = function(play,zt) -- 天空之王祝福：生命+10%，并且每60秒恢复10%最大生命
        if zt == 3 then
            local now = os.time()
            if now - (tonumber(getplaydef(play, "N$buff329cd") or 0) or 0) >= 60 then
                setplaydef(play, "N$buff329cd", now)
                local maxhp = tonumber(getbaseinfo(play, (ConstCfg and ConstCfg.gbase and ConstCfg.gbase.maxhp) or 10) or 0) or 0
                local heal = math.floor(maxhp * 0.1)
                if heal > 0 then
                    humanhp(play, "+", heal, 5, 0, play)
                    playeffect(play, 60458, 0, 0, 1, 1, 0)
                end
            end
            return 0
        end
        -- 该效果既有常驻加成也有定时回血，因此保留登录重挂和CD状态
        if zt == 1 then
            _set_title_buff_flag(play, 329, true)
            _toggle_buff_var(play, VarCfg.S_buffgjh, 329, true)
            _toggle_buff_var(play, VarCfg.S_buffbgjq, 329, true)
        elseif zt == 2 then
            _set_title_buff_flag(play, 329, false)
            _toggle_buff_var(play, VarCfg.S_buffgjh, 329, false)
            _toggle_buff_var(play, VarCfg.S_buffbgjq, 329, false)
        end
    end,
    [340] = function(play,zt) -- 古刹魔瓶：装备背包神器后，击杀怪物有5%概率使打怪切割+1（常驻累计）
        if zt == 1 then
            _set_title_buff_flag(play, 340, true)
            if shaguai and shaguai.jia then
                shaguai.jia(play, 340)
            end
            _gcmp_refresh_item(play)
        elseif zt == 2 then
            _set_title_buff_flag(play, 340, false)
            if shaguai and shaguai.jian then
                shaguai.jian(play, 340)
            end
            _gcmp_refresh_item(play)
        end
    end,
    [341] = function(play,zt,Damage,Target) -- 首刀：首次命中满血怪物时，额外斩掉目标最大生命值15%
        if zt == 3 then
            if not Target or getbaseinfo(Target, ConstCfg.gbase.isplayer) then
                return 0
            end
            local maxhp = tonumber(getbaseinfo(Target, (ConstCfg and ConstCfg.gbase and ConstCfg.gbase.maxhp) or 10) or 0) or 0
            local curhp = tonumber(getbaseinfo(Target, (ConstCfg and ConstCfg.gbase and ConstCfg.gbase.hp) or 9) or 0) or 0
            if maxhp <= 0 or curhp <= 0 then
                return 0
            end
            -- attackdamage 里会先结算人物切割/对怪增伤，这里把那部分补回去后再判断是否为首刀。
            local pre_cut = tonumber(getbaseinfo(play, 51, 244) or 0) or 0
            local pre_hurt_up = 0
            if Damage and Damage > 0 then
                pre_hurt_up = Damage / 10000 * (tonumber(getbaseinfo(play, 51, 245) or 0) or 0)
            end
            if curhp + pre_cut + pre_hurt_up < maxhp then
                return 0
            end
            local hurt = math.floor(maxhp * 0.15)
            if hurt < 1 then
                hurt = 1
            end
            if hurt > curhp then
                hurt = curhp
            end
            return hurt
        end
        _set_title_buff_flag(play, 341, zt == 1)
        _toggle_buff_var(play, VarCfg.S_buffgwq, 341, zt == 1)
    end,
    [342] = function(play,zt,Damage,Target) -- 对玩家每次命中额外附加6666点真伤
        if zt == 3 then
            if Target and getbaseinfo(Target, ConstCfg.gbase.isplayer) then
                return 6666
            end
            return 0
        end
        _set_title_buff_flag(play, 342, zt == 1)
        _toggle_buff_var(play, VarCfg.S_buffrwq, 342, zt == 1)
    end,
    [330] = function(play,zt) -- 海洋之王祝福：标记型BUFF，冰冻相关数值由称号表或其他逻辑处理
        if zt == 1 then
            _set_title_buff_flag(play, 330, true)
        elseif zt == 2 then
            _set_title_buff_flag(play, 330, false)
        end
    end,
    [331] = function(play,zt,Damage,Target) -- 青铜之王祝福：攻击红名玩家时，额外造成10%伤害
        if zt == 3 then
            if Target and getbaseinfo(Target, ConstCfg.gbase.isplayer) and Damage and Damage > 0 then
                local pk = tonumber(getbaseinfo(Target, 46) or 0) or 0
                if pk > 0 then
                    return math.floor(Damage * 0.1)
                end
            end
            return 0
        end
        _set_title_buff_flag(play, 331, zt == 1)
        _toggle_buff_var(play, VarCfg.S_buffgjq, 331, zt == 1)
    end,
    [332] = function(play,zt,Damage,Target) -- 乾坤大挪移：5%概率对目标3x3范围造成最大魔法5%的范围伤害
        if zt == 3 then
            if not Target or math.random(100) > 5 then
                return 0
            end
            local now = os.time()
            -- 8秒公共CD，避免范围伤害效果连续触发
            if now - (tonumber(getplaydef(play, "N$buff332cd") or 0) or 0) < 8 then
                return 0
            end
            local maxmp = tonumber(getbaseinfo(play, (ConstCfg and ConstCfg.gbase and ConstCfg.gbase.maxmp) or 14) or 0) or 0
            local hurt = math.floor(maxmp * 0.05)
            if hurt > 0 then
                setplaydef(play, "N$buff332cd", now)
                rangeharm(play, getbaseinfo(Target, ConstCfg.gbase.x), getbaseinfo(Target, ConstCfg.gbase.y), 1, hurt, 0, 0, 0, 2, 20310, 12)
            end
            return 0
        end
        _set_title_buff_flag(play, 332, zt == 1)
        _toggle_buff_var(play, VarCfg.S_buffgwh, 332, zt == 1)
    end,
    [333] = function(play,zt) -- 吕布之力：标记型BUFF，激活外观或展示效果时可据此判定
        if zt == 1 then
            _set_title_buff_flag(play, 333, true)
        elseif zt == 2 then
            _set_title_buff_flag(play, 333, false)
        end
    end,
    [334] = function(play,zt,Damage,Target,MagicId) -- 火中取胜：受到烈火剑法伤害时减免5%
        if zt == 3 then
            if MagicId == 26 and Damage and Damage > 0 then
                return math.floor(Damage * 0.05)
            end
            return 0
        end
        _set_title_buff_flag(play, 334, zt == 1)
        _toggle_buff_var(play, VarCfg.S_buffbgjq, 334, zt == 1)
    end,
    [335] = function(play,zt) -- 打虎英雄：标记型BUFF，常驻攻速属性由称号表提供
        if zt == 1 then
            _set_title_buff_flag(play, 335, true)
        elseif zt == 2 then
            _set_title_buff_flag(play, 335, false)
        end
    end,
    [336] = function(play,zt) -- 侠义祝福：标记型BUFF，常驻全属性由称号表提供
        if zt == 1 then
            _set_title_buff_flag(play, 336, true)
        elseif zt == 2 then
            _set_title_buff_flag(play, 336, false)
        end
    end,
    [337] = function(play,zt) -- 马上发财：标记型BUFF，大奖励称号属性直接走称号表
        if zt == 1 then
            _set_title_buff_flag(play, 337, true)
        elseif zt == 2 then
            _set_title_buff_flag(play, 337, false)
        end
    end,
    [338] = function(play,zt) -- 日卡：标记型BUFF，常驻爆率属性由称号表提供
        if zt == 1 then
            _set_title_buff_flag(play, 338, true)
        elseif zt == 2 then
            _set_title_buff_flag(play, 338, false)
        end
    end,
    [101] = function(play,zt) --仙食坊全满
        if zt == 1 then
            Player.add_attlist(play, "仙食坊全满", "=", "3#1#8888|3#4#588|3#242#3800|3#244#4888", 1)
        elseif zt == 2 then
            Player.del_attlist(play, "仙食坊全满")
        end
    end,
    [102] = function(play,zt,Damage,Target) --轩辕剑传人  BUFF:每三刀附带额外最大攻击1%的真实伤害
        if zt == 3 then
            local cs = getplaydef(play,"N$buff102")
            if cs < 3 then
                cs = cs + 1
                setplaydef(play,"N$buff102",cs)
            else
                setplaydef(play,"N$buff102",0)
                humanhp(Target,"-",math.floor(getbaseinfo(play, 20)*0.01))
                --Player.sendmsgEx(play,"轩辕剑传人触发真实伤害，造成"..math.floor(getbaseinfo(play, 20)*0.01).."点真实伤害！")
            end
        else
            local bl = getplaydef(play,VarCfg.S_buffgjh)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["102"] = true
                setplaydef(play,"N$buff102",0)
            elseif zt == 2 then
                data["102"] = nil
            end
            setplaydef(play,VarCfg.S_buffgjh,tbl2json(data))
        end
    end,
    [103] = function(play,zt,Damage,Target) --触发攻击系的灵根
        if zt == 3 then
            Npclib[22].lgcf(play,zt,Damage,Target,1)
        else
            local bl = getplaydef(play,VarCfg.S_buffgjh)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["103"] = true
                setplaydef(play,"N$buff_lg",0)
            elseif zt == 2 then
                data["103"] = nil
            end
            setplaydef(play,VarCfg.S_buffgjh,tbl2json(data))
        end
    end,
    [104] = function(play,zt,Damage,Target) --触发被攻击系的灵根
        if zt == 3 then
            Npclib[22].lgcf(play,zt,Damage,Target,2)
            return 0
        else
            local bl = getplaydef(play,VarCfg.S_buffbgjq)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["104"] = true
                setplaydef(play,"N$buff_lg",os.time())
            elseif zt == 2 then
                data["104"] = nil
            end
            setplaydef(play,VarCfg.S_buffbgjq,tbl2json(data))
        end
    end,
    [105] = function(play,zt,Damage,Target) --触发灵兽
        if zt == 3 then
            Npclib[64].lscf(play,zt,Damage,Target)
            return 0
        else
            local bl = getplaydef(play,VarCfg.S_buffgjh)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["105"] = true
                setplaydef(play,"N$buff_ls",os.time())
            elseif zt == 2 then
                data["105"] = nil
            end
            setplaydef(play,VarCfg.S_buffgjh,tbl2json(data))
        end
    end,
    [106] = function(play,zt,Damage,Target) --攻击嘲灾  如果没有buff_106 则对玩家造成100%的伤害
        if zt == 3 then
            if Target == nil then
                return 0
            end
            -- release_print("嘲灾触发")
            -- release_print(getbaseinfo(Target,1))
            -- release_print(hasbuff(play,20110))
            if getbaseinfo(Target,1) == "嘲灾" then
                local hasWeapon = Player.hasEquipOnPos(play, 1, "嘲天笑地")
                if not hasWeapon then
                    humanhp(play, "-", Damage, 0, 0)
                    -- release_print("嘲灾触发，造成"..Damage.."点伤害")
                end
            end
        else
            local bl = getplaydef(play,VarCfg.S_buffgwq)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["106"] = true
            elseif zt == 2 then
                data["106"] = nil
            end
            setplaydef(play,VarCfg.S_buffgwq,tbl2json(data))
        end
    end,
    [339] = function(play,zt,Damage,Target,MagicId,Model) --天书仙法攻击触发
        -- zt=1/2：注册或移除攻击触发；zt=3：攻击回调并返回额外伤害
        if zt == 3 then
            _tianshu_buff_splash(play, Target)
            return 0
        else
            local bl = getplaydef(play,VarCfg.S_buffgjq)
            local data = json2tbl(bl == "" and {} or bl)
            if zt == 1 then
                data["339"] = true
            elseif zt == 2 then
                data["339"] = nil
            end
            setplaydef(play,VarCfg.S_buffgjq,tbl2json(data))
        end
    end,
}
local weizhi = {0,1,3,4,5,6,7,8,9,10,11,13,14,16,30,31,32,33,34,35,36,37,38,39,40,41}
function Buff.refreshHuTiGuangHuan(play)
    Buff[107](play, 2)
    Buff[108](play, 2)
    Buff[109](play, 2)
    Buff[110](play, 2)
    clearplayeffect(play,11502)
    clearplayeffect(play,11503)
    clearplayeffect(play,11504)
    local zs_level = tonumber(getplaydef(play, VarCfg["U_转生等级"]) or 0) or 0
    local sc_data = Player.getJsonTableByVar(play, VarCfg["T_首冲礼包"]) or {}
    local unlocked = {
        [1] = zs_level >= 10,
        [2] = tonumber(sc_data["首充"] or 0) == 1,
        [3] = getflagstatus(play, VarCfg.BS_mztq) == 1,
    }
    local active = tonumber(getplaydef(play, VarCfg["U_护体光环激活"]) or 0) or 0
    if active < 1 or active > 3 or not unlocked[active] then
        active = 0
        setplaydef(play, VarCfg["U_护体光环激活"], 0)
    end
    if active == 1 then
        Buff[107](play, 1)
        playeffect(play,11502,0,0,0,1,0)
    elseif active == 2 then
        Buff[108](play, 1)
        Buff[109](play, 1)
        playeffect(play,11503,0,0,0,1,0)
    elseif active == 3 then
        Buff[110](play, 1)
        playeffect(play,11504,0,0,0,1,0)
    end
    if active > 0 then
        if FSetGuangHuan then
            FSetGuangHuan(play, 20)
        else
            setplaydef(play, VarCfg["U_光环外观记录"], 20)
            seticon(play, ConstCfg.iconWhere.guangHuan, 1, 20, 0, 0, 0, 0, 1)
        end
    else
        setplaydef(play, VarCfg["U_光环外观记录"], 0)
        seticon(play, ConstCfg.iconWhere.guangHuan, -1)
    end
end
function Buff.login(play)
    -------------------------------------------------------------------装备BUFF登录初始化
    -- 登录时先清空属性下发缓存，避免跨上下线后同属性被误判为已挂载
    Player.clear_attlist_cache(play)
    for k, v in pairs(weizhi) do
        local item = linkbodyitem(play,v)
        if item ~= "0" then
            if v == 14 then
                changemoney(play,16,"=",1,"登录复活",true)
            end
            local id = getstditeminfo(getiteminfo(play,item,2),8)
            if id > 0 and Buff[id] then
                Buff[id](play,1)
            end
        end
    end
    -------------------------------------------------------------------称号BUFF登录初始化
    local ch = gettitlelist(play)
    for _, v in pairs(ch) do
        local idx = getstditeminfo(getiteminfo(play,v,1),8)
        if idx and idx > 0 then
            Buff[idx](play,1)
        end
    end
    -------------------------------------------------------------------护体光环
    -- 护体光环登录刷新
    Buff.refreshHuTiGuangHuan(play)
    -------------------------------------------------------------------额外附加属性登录初始化
    --灵根鉴定
    local data = Player.getJsonTableByVar(play, VarCfg["T_灵根鉴定"])
    if data["1"] then
        local attrs = {}
        local attrsstr = ""
        for i=1,5 do
            attrs[teshudata["npc_1"].config[i].attr] = data[""..i] or 0
        end
        attrsstr = Player.getAttrTableToStr(attrs)
        Player.add_attlist(play, "灵根鉴定", "=", attrsstr, 1)
    end
    --灵根修炼
    data = Player.getJsonTableByVar(play, VarCfg["T_灵根修炼"])
    local attrs = {}
    local attrsstr = ""
    for i=1,5 do
        attrs[teshudata["npc_11"].attrID[i]] = (data[""..i] or 0) * teshudata["npc_11"].config[i].ratio
    end
    attrsstr = Player.getAttrTableToStr(attrs)
    Player.add_attlist(play, "灵根修炼", "=", attrsstr, 1)
    --兰姐好感度
    if getplaydef(play, VarCfg["U_兰姐好感度"]) > 0 then
        Player.add_attlist(play, "兰姐好感度", "=", "3#"..teshudata["npc_13"].attrID.."#"..teshudata["npc_13"].config[getplaydef(play, VarCfg["U_兰姐好感度"])].ratio, 1)
    end
    --福娃猜拳切割
    data = Player.getJsonTableByVar(play, VarCfg["T_福娃猜拳"] )
    local fuwa_cut = tonumber(data.cut) or 0
    Player.del_attlist(play, "福娃猜拳切割")
    if fuwa_cut > 0 then
        Player.add_attlist(play, "福娃猜拳切割", "=", "3#" .. (teshudata["npc_66"].cut_attr or 244) .. "#" .. fuwa_cut, 1)
    end
    -- 古刹魔瓶：背包神器位不走常规装备位登录初始化，这里补一次。
    if Player.hasEquipInArtifactSlot(play, "古刹魔瓶") then
        Buff[340](play, 1)
    else
        Buff[340](play, 2)
    end
    ------------------------------------------------------------通用属性
    local attr = {}
    Player.updateSomeAddr(play,nil, attr)
end
GameEvent.add(EventCfg.onLogin, Buff.login, "buff")
-- 大地之王祝福：击杀玩家叠层事件
-- 该称号不走普通 Buff[328](zt=3) 分支，改为在 onkillplay 中直接累加层数并同步属性
GameEvent.add(EventCfg.onkillplay, function(play)
    if not _has_title_buff_flag(play, 328) then
        return
    end
    local stack = tonumber(getplaydef(play, "N$buff328_stack") or 0) or 0
    if stack < 10 then
        setplaydef(play, "N$buff328_stack", stack + 1)
        _title_sync_dadi_attr(play)
    end
end, "Buff_328_stack")
function Buff.chuan(play,item)
    local id = getstditeminfo(getiteminfo(play,item,2),8)
    if id > 0 and Buff[id]then
        Buff[id](play,1)
    end
end
function Buff.tuo(play,item)
    local id = getstditeminfo(getiteminfo(play,item,2),8)
    if id > 0 and Buff[id] then
        Buff[id](play,2)
    end
end
return Buff
