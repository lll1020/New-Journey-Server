npc = {}


--地图跳转npc

local _config = {
    --{"地图名",x,y,限制fun,提示文字,所属大陆}
    [201] = {"山庄",0,0,nil,nil,1, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [202] = {"幽谷",0,0,nil,nil,1, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [203] = {"洞穴",0,0,nil,nil,1, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [204] = {"古殿",0,0,nil,nil,1, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},

    -- [205] = {"隐藏地图二",0,0,nil,nil,2, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [206] = {"野火帮",100,100,nil,nil,2, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [207] = {"极光城郊",100,100,nil,nil,2, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [208] = {"兵道古藏",100,100,nil,nil,2, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [209] = {"夜魔洞",100,100,nil,nil,2, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    -- [210] = {"特殊秘境副本二",0,0,nil,nil,2, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},

    -- [211] = {"隐藏地图三",0,0,nil,nil,3, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [212] = {"灰界",100,100,nil,nil,3, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [213] = {"藏星海",100,100,nil,nil,3, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [214] = {"苍云城",100,100,nil,nil,3, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    -- [215] = {"无主深渊",100,100,nil,nil,3, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [216] = {"草药谷",100,100,nil,nil,3, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    -- [217] = {"特殊秘境副本三",0,0,nil,nil,3, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},

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
local _config_spa = {
    --{"地图名",x,y,限制fun,提示文字,所属大陆}
    [300] = {"虚妄山脉", 92, 50,nil,nil,3, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [301] = {"鬼嘲深渊", 273, 33,nil,nil,3, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [302] = {"叹息旷野", 34, 41,nil,nil,3, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [303] = {"禁忌之海", 33, 133,nil,nil,3, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [304] = {"葬星海滩", 184, 40,nil,nil,3, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [305] = {"船长室", 40, 46,nil,nil,3, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [306] = {"水手舱", 59, 11,nil,nil,3, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},

    [307] = {"黄泉路", 49, 29,nil,nil,4, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [308] = {"罗酆六天", 71, 78,nil,nil,4, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [309] = {"东海龙宫", 31, 83,nil,nil,4, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [310] = {"黑风山", 158, 72,nil,nil,4, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [311] = {"黄风岭", 92, 368,nil,nil,4, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [312] = {"女儿国", 161, 146,nil,nil,4, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [313] = {"通天河", 237, 39,nil,nil,4, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [314] = {"狮驼岭", 17, 87,nil,nil,4, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [315] = {"天竺山", 68, 66,nil,nil,4, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [316] = {"灵域·二层", 72, 25,nil,nil,4, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [317] = {"灵域·三层", 63, 61,nil,nil,4, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [318] = {"灵域·秘境", 21, 20,nil,nil,4, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},

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
        if _config_spa[npcid] then
            local config = _config_spa[npcid]
            if not Player.dl_sz(play, config[6]) then
                return
            end
                        local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)
            if npcid == 300 then -- 虚妄山脉  621 对应的任务完成可以进入
                if not (jq_data["npc_621"] and jq_data["npc_621"] >= 2) then
                    Player.sendmsgEx(play, "任务未完成，无法进入#57")
                    return
                end
            elseif npcid == 301 then -- 鬼嘲深渊  623 对应的任务完成可以进入
                if not (jq_data["npc_623"] and jq_data["npc_623"] >= 2) then
                    Player.sendmsgEx(play, "任务未完成，无法进入#57")
                    return
                end
            elseif npcid == 302 then -- 叹息旷野  622 对应的任务完成可以进入
                if not (jq_data["npc_622"] and jq_data["npc_622"] >= 2) then
                    Player.sendmsgEx(play, "任务未完成，无法进入#57")
                    return
                end
            elseif npcid == 303 then -- 禁忌之海  624 对应的任务完成可以进入
                if not (jq_data["npc_624"] and jq_data["npc_624"] >= 2) then
                    Player.sendmsgEx(play, "任务未完成，无法进入#57")
                    return
                end
            elseif npcid == 304 then -- 葬星海滩  对应定时器的 切换地图触发
                local hour = tonumber(os.date("%H")) or 0
                mapmove(play,(hour % 2 == 0) and "葬星海滩" or "葬星海滩1",config[2],config[3],5)
                return
            elseif npcid == 305 then -- 船长室 629的任务完成 -a
                if jq_data["npc_629_a"] ~= 1 then
                    Player.sendmsgEx(play, "未完成对应提交，无法进入#57")
                    return
                end
            elseif npcid == 306 then -- 水手舱 629的任务完成 -b
                if jq_data["npc_629_b"] ~= 1 then
                    Player.sendmsgEx(play, "未完成对应提交，无法进入#57")
                    return
                end
            elseif npcid == 307 then -- 黄泉路 667的任务完成
                if not (jq_data["npc_667"] and jq_data["npc_667"] >= 2) then
                    Player.sendmsgEx(play, "任务未完成，无法进入#57")
                    return
                end
            elseif npcid == 308 then -- 罗酆六天 669的任务完成
                if not (jq_data["npc_669"] and jq_data["npc_669"] >= 2) then
                    Player.sendmsgEx(play, "任务未完成，无法进入#57")
                    return
                end
            elseif npcid == 309 then -- 东海龙宫 642的任务完成
                if not (jq_data["npc_642"] and jq_data["npc_642"] >= 2) then
                    Player.sendmsgEx(play, "任务未完成，无法进入#57")
                    return
                end
            elseif npcid == 310 then -- 黑风山 643的任务完成
                if not (jq_data["npc_643"] and jq_data["npc_643"] >= 2) then
                    Player.sendmsgEx(play, "任务未完成，无法进入#57")
                    return
                end
            elseif npcid == 311 then -- 黄风岭 644的任务完成
                if not (jq_data["npc_644"] and jq_data["npc_644"] >= 2) then
                    Player.sendmsgEx(play, "任务未完成，无法进入#57")
                    return
                end
            elseif npcid == 312 then -- 女儿国 645的任务完成
                if not (jq_data["npc_645"] and jq_data["npc_645"] >= 2) then
                    Player.sendmsgEx(play, "任务未完成，无法进入#57")
                    return
                end
            elseif npcid == 313 then -- 通天河 646的任务完成
                if not (jq_data["npc_646"] and jq_data["npc_646"] >= 2) then
                    Player.sendmsgEx(play, "任务未完成，无法进入#57")
                    return
                end
            elseif npcid == 314 then -- 狮驼岭 647的任务完成
                if not (jq_data["npc_647"] and jq_data["npc_647"] >= 2) then
                    Player.sendmsgEx(play, "任务未完成，无法进入#57")
                    return
                end
            elseif npcid == 315 then -- 天竺山 648的任务完成
                if not (jq_data["npc_648"] and jq_data["npc_648"] >= 2) then
                    Player.sendmsgEx(play, "任务未完成，无法进入#57")
                    return
                end
            elseif npcid == 316 then -- 灵域·二层 663的任务完成
                if not (jq_data["npc_663"] and jq_data["npc_663"] >= 2) then
                    Player.sendmsgEx(play, "任务未完成，无法进入#57")
                    return
                end
            elseif npcid == 317 then -- 灵域·三层 664的任务完成
                if not (jq_data["npc_664"] and jq_data["npc_664"] >= 2) then
                    Player.sendmsgEx(play, "任务未完成，无法进入#57")
                    return
                end
            elseif npcid == 318 then -- 灵域·秘境 665的任务完成
                if not (jq_data["npc_665"] and jq_data["npc_665"] >= 2) then
                    Player.sendmsgEx(play, "任务未完成，无法进入#57")
                    return
                end
            end
            mapmove(play,config[1],config[2],config[3],5)
        end

    end
end
---- 
function npc_200_fbjs(play)
    startautoattack(play) --自动攻击
end

return npc


