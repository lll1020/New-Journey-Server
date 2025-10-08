npc = {}
--地图跳转npc

local _config = {
    --{"地图名",x,y,限制fun,提示文字,所属大陆}
    [201] = {"山庄",100,100,nil,nil,1},
    [202] = {"幽谷",100,100,nil,nil,1},
    [203] = {"洞穴",100,100,nil,nil,1},
    [204] = {"古殿",100,100,nil,nil,1},

    [205] = {"隐藏地图二",100,100,nil,nil,2},
    [206] = {"野火帮",100,100,nil,nil,2},
    [207] = {"xx城郊",100,100,nil,nil,2},
    [208] = {"兵道古藏",100,100,nil,nil,2},
    [209] = {"夜魔洞",100,100,nil,nil,2},
    [210] = {"特殊秘境副本二",100,100,nil,nil,2},

    [211] = {"隐藏地图三",100,100,nil,nil,3},
    [212] = {"灰界",100,100,nil,nil,3},
    [213] = {"群星海",100,100,nil,nil,3},
    [214] = {"红尘城",100,100,nil,nil,3},
    [215] = {"无主深渊",100,100,nil,nil,3},
    [216] = {"草药谷",100,100,nil,nil,3},
    [217] = {"特殊秘境副本三",100,100,nil,nil,3},

}

function npc.main(play,npcid)
    sendluamsg(play,100,npcid,0,0,"")
end

function npc.link(play,npcid,ew,aid)
    if ew == 1 then
        if _config[npcid] then
            if not Player.dl_sz(play, _config[npcid][6]) then
                return
            end
            mapmove(play,_config[npcid][1],_config[npcid][2],_config[npcid][3],1)
        end

    end
end

return npc