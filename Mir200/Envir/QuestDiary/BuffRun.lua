--------------------buff´¥·¢Âß¼­-------------------
function buffchufa(play, buffid, zid)
    if buffid == 19999 then
        if getbaseinfo(play, 6) < 30 then
            changelevel(play, '+', 1)
            humanhp(play,"+",getbaseinfo(play,10)-getbaseinfo(play,9))
        else
            delbuff(play, 19999)
        end
    elseif buffid == 20103 then
        local curzuiyi = getplaydef(play, VarCfg["J_×íÒâÖµ"])
        if curzuiyi < 100 then
            Player.sendmsgEx(play, string.format("ÄãµÄ×íÒâÖµÎ´´ïÉÏÏÞ|%d#218|£¬ÎÞ·¨Î¬³Ö|×í¾Æ¿ñÄ§Îè#57", _config.max_zuiyi))
            delbuff(play, 20103)
            return
        end
        local name, num = Player.checkItemNumByTable(play, {{"Ôª±¦",200}})
        if name then
            delbuff(play, 20103)
            return
        end
        Player.takeItemByTable(play, {{"Ôª±¦",200}}, ",×í¾Æ¿ñÄ§Îè",nil)
    elseif buffid == 20104 then --½ð
        local damage = tonumber(getobjintvar(play,22041) or 0) or 0
        local xx,yy,dqdt = getbaseinfo(play,4),getbaseinfo(play,5),getbaseinfo(play,3)
        local mons = getobjectinmap(dqdt, xx, yy, 3, 2) or {}
        if damage > 0 then
            for _, v in ipairs(mons) do
                humanhp(v,"-",damage,106,0,play,1)
            end
        end
        rangeharm(play,xx,yy,3,0,0,0,0,2,20310)
        playeffect(play,20301,0,0,1,1,0)
    elseif buffid == 20105 then --Ë®/»ð
        local waterDamage = tonumber(getobjintvar(play,22042) or 0) or 0
        if waterDamage > 0 and getbaseinfo(play,ConstCfg.gbase.isplayer) then
            local xx,yy,dqdt = getbaseinfo(play,4),getbaseinfo(play,5),getbaseinfo(play,3)
            local mons = getobjectinmap(dqdt, xx, yy, 5, 2) or {}
            for _, v in ipairs(mons) do
                if waterDamage > 0 then
                    humanhp(v,"-",waterDamage,112,0,play,1)
                end
                monmission(v,xx,yy,0)
            end
            playeffect(play,60454,0,0,1,1,0)
        else
            local fireDamage = tonumber(getobjintvar(play,22045) or 0) or 0
            if fireDamage > 0 then
                local ownerName = getobjstrvar(play,22045) or ""
                local owner = ownerName ~= "" and getplayerbyname(ownerName) or nil
                if owner == 0 then
                    owner = nil
                end
                humanhp(play,"-",fireDamage,112,0,owner)
                playeffect(play,60463,0,0,1,1,0)
            end
        end
    elseif buffid == 20107 then --À×
        local rateBp = tonumber(getobjintvar(play,22043) or 0) or 0
        if rateBp > 0 then
            local maxHp = tonumber(getbaseinfo(play,10) or 0) or 0
            local damage = math.floor(maxHp * rateBp / 10000)
            local ownerName = getobjstrvar(play,22043) or ""
            local owner = ownerName ~= "" and getplayerbyname(ownerName) or nil
            if owner == 0 then
                owner = nil
            end
            if damage > 0 then
                humanhp(play,"-",damage,112,0,owner)
            end
        end
    end
end
--------------------buff½áÊøÂß¼­-------------------
function buffchange(play, buffid, zid, lx)
    if buffid == 20060 then
        if lx == 4 then
            moneychange16(play)
        end
    elseif buffid == 20078 then
        if lx == 4 then
            if querymoney(play,15) < querymoney(play,14) then
                changemoney(play,15,"+",1,"¸´»î",true)
            end
            if querymoney(play,15) < querymoney(play,14) then
                addbuff(play,20078,180)
            end
        end
    elseif buffid == 20000 or buffid == 20001 or buffid == 20002 then
        -- Ô¤ÁôbuffÂß¼­
    elseif buffid == 20103 then
        if getbaseinfo(play,1) == "¾ÆÏÉÃØ¾³" then
            mapmove(play, "xtc",137,138,5)
            Player.sendmsgEx(play, "×í¾Æ¿ñÄ§ÎèÒÑÊ§Ð§#57|,ÒÑÀë¿ª|¾ÆÏÉÃØ¾³#218")
        end
    elseif buffid == 20104 and lx == 4 then
        setobjintvar(play,22041,0)
    elseif buffid == 20105 and lx == 4 then
        setobjintvar(play,22042,0)
        setobjintvar(play,22045,0)
        setobjstrvar(play,22045,"")
    elseif buffid == 20107 and lx == 4 then
        setobjintvar(play,22043,0)
        setobjstrvar(play,22043,"")
    end
end
