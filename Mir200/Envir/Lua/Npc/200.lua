npc = {}


--地图跳转npc

local _config = {
    --{"地图名",x,y,限制fun,提示文字,所属大陆}
    [201] = {"山庄",0,0,nil,nil,1},
    [202] = {"幽谷",0,0,nil,nil,1},
    [203] = {"洞穴",0,0,nil,nil,1},
    [204] = {"古殿",0,0,nil,nil,1},

    [205] = {"隐藏地图二",100,100,nil,nil,2},
    [206] = {"野火帮",100,100,nil,nil,2},
    [207] = {"极光城郊",100,100,nil,nil,2},
    [208] = {"兵道古藏",100,100,nil,nil,2},
    [209] = {"夜魔洞",100,100,nil,nil,2},
    [210] = {"特殊秘境副本二",100,100,nil,nil,2},

    [211] = {"隐藏地图三",100,100,nil,nil,3},
    [212] = {"灰界",100,100,nil,nil,3},
    [213] = {"藏星海",100,100,nil,nil,3},
    [214] = {"苍云城",100,100,nil,nil,3},
    -- [215] = {"无主深渊",100,100,nil,nil,3},
    [216] = {"草药谷",100,100,nil,nil,3},
    [217] = {"特殊秘境副本三",100,100,nil,nil,3},

}

function npc.main(play,npcid)
    sendluamsg(play,100,npcid,0,0,"")
end

function npc.link(play,npcid,ew,aid)
    -- npc_guard: 入参校验
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local __guardAction = Guard.normalizeAction(play, npcid, ew)
    if __guardAction == nil then
        return
    end
    ew = __guardAction
    -- npc_guard: 操作白名单（优化：限定合法操作编号）
    local __guardAllowedActions = Guard.newActionSet({1})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end

    if ew == 1 then
        if _config[npcid] then
            if not Player.dl_sz(play, _config[npcid][6]) then
                return
            end
            if _config[npcid][2] > 0 then
                mapmove(play,_config[npcid][1] .. (aid == 1 and "一" or ""),_config[npcid][2],_config[npcid][3],5)
            else
                map(play,_config[npcid][1] .. (aid == 1 and "一" or ""))
            end
            delaygoto(play,200,"npc_200_fbjs",0)
        end

    end
end
---- 
function npc_200_fbjs(play)
    startautoattack(play) --自动攻击
end

return npc