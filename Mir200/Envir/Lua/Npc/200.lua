npc = {}


--地图跳转npc

local _config = {
    --{"地图名",x,y,限制fun,提示文字,所属大陆}
    [201] = {"山庄",0,0,nil,nil,1, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [202] = {"幽谷",0,0,nil,nil,1, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [203] = {"洞穴",0,0,nil,nil,1, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [204] = {"古殿",0,0,nil,nil,1, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},

    [205] = {"隐藏地图二",0,0,nil,nil,2, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [206] = {"野火帮",100,100,nil,nil,2, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [207] = {"极光城郊",100,100,nil,nil,2, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [208] = {"兵道古藏",100,100,nil,nil,2, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [209] = {"夜魔洞",100,100,nil,nil,2, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [210] = {"特殊秘境副本二",0,0,nil,nil,2, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},

    [211] = {"隐藏地图三",0,0,nil,nil,3, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [212] = {"灰界",100,100,nil,nil,3, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [213] = {"藏星海",100,100,nil,nil,3, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [214] = {"苍云城",100,100,nil,nil,3, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    -- [215] = {"无主深渊",100,100,nil,nil,3, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [216] = {"草药谷",100,100,nil,nil,3, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [217] = {"特殊秘境副本三",0,0,nil,nil,3, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},

    [218] = {"酆都鬼城",100,100,nil,nil,4, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [219] = {"大唐·长安城",100,100,nil,nil,4, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [220] = {"生肖灵域",100,100,nil,nil,4, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [221] = {"传说之地",100,100,nil,nil,4, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},

    [222] = {"灵兽谷",100,100,nil,nil,5, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [223] = {"时空裂隙",100,100,nil,nil,5, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [224] = {"生命边界",100,100,nil,nil,5, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [225] = {"聊斋志异",100,100,nil,nil,5, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [226] = {"敦煌遗梦",100,100,nil,nil,5, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [227] = {"世界禁墟",100,100,nil,nil,5, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},


}

function npc.main(play,npcid)
    sendluamsg(play,100,npcid,0,0,"")
end
local spa = {
    [6] = 1,
    [10] = 2,
    [14] = 3,
    [18] = 4,
}

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
                map(play,_config[npcid][1] .. (spa[getplaydef(play,VarCfg.U_zxrw[1])] and "一" or ""))
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