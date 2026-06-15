npc = {}
--地图跳转npc
local _config = {
    --{"地图名",x,y,限制fun,提示文字,所属大陆}
    [201] = {"山庄",0,0,nil,nil,1, mob_name = "枯灯客", mob_shape = 631, min_map = "010345"},
    [202] = {"幽谷",0,0,nil,nil,1, mob_name = "青苔妖", mob_shape = 200, min_map = "028561"},
    [203] = {"洞穴",0,0,nil,nil,1, mob_name = "石牙兽", mob_shape = 45, min_map = "027578"},
    [204] = {"古殿",0,0,nil,nil,1, mob_name = "破面俑", mob_shape = 12052, min_map = "027626"},
    -- [205] = {"隐藏地图二",0,0,nil,nil,2, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [206] = {"野火帮",100,100,nil,nil,2, mob_name = "「焚骨统领·赤狱」", mob_shape = 16236, min_map = "028614"},
    [207] = {"极光城郊",100,100,nil,nil,2, mob_name = "「辉域守护者·冰霄」", mob_shape = 12015, min_map = "028574"},
    [208] = {"杀伐道场",100,100,nil,nil,2, mob_name = "古兵执戟者", mob_shape = 16192, min_map = "028808",other_name = "兵道古藏"},
    [209] = {"夜魔洞",100,100,nil,nil,2, mob_name = "「深夜魔君·漆渊」", mob_shape = 12011, min_map = "029393"},
    -- [210] = {"特殊秘境副本二",0,0,nil,nil,2, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    -- [211] = {"隐藏地图三",0,0,nil,nil,3, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [212] = {"灰界",201,199,nil,nil,3, mob_name = "灰纹·潜噬者", mob_shape = 12033, min_map = "027907"},
    [213] = {"藏星海",100,100,nil,nil,3, mob_name = "≮群星渊皇≯", mob_shape = 16206, min_map = "027135",other_name = "葬星海"},
    [214] = {"苍云城",100,100,nil,nil,3, mob_name = "「红幕法皇」[咆哮]", mob_shape = 12054, min_map = "027198"},
    -- [215] = {"无主深渊",100,100,nil,nil,3, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [216] = {"草药谷",100,100,nil,nil,3, mob_name = "☆仙草大妖☆", mob_shape = 12079, min_map = "028854"},
    -- [217] = {"特殊秘境副本三",0,0,nil,nil,3, mob_name = "银爪收割者", mob_shape = 221, min_map = "000100"},
    [218] = {"酆都鬼城",100,100,nil,nil,4, mob_name = "「酆都之主·万魂冥君」", mob_shape = 16322, min_map = "027142"},
    [219] = {"大唐·长安城",100,100,nil,nil,4, mob_name = "「盛世暗面·长安城主」", mob_shape = 16247, min_map = "027166"},
    [220] = {"生肖灵域",100,100,nil,nil,4, mob_name = "★十二命相·生肖主宰★", mob_shape = 16251, min_map = "027231"},
    [221] = {"传说之地",100,100,nil,nil,4, mob_name = "≮万古传说·时代见证者≯", mob_shape = 16263, min_map = "027199"},
    [222] = {"灵兽谷",100,100,nil,nil,5, mob_name = "≮太古血脉·灵兽皇≯", mob_shape = 12100, min_map = "027246"},
    [223] = {"时空裂隙",100,100,nil,nil,5, mob_name = "★时空崩坏·裂界主★", mob_shape = 12100, min_map = "028125"},
    [224] = {"生命边界",100,100,nil,nil,5, mob_name = "≮生命终章·边界尊≯", mob_shape = 16121, min_map = "027242"},
    [225] = {"聊斋志异",100,100,nil,nil,5, mob_name = "≮书外真妖·异闻尊≯", mob_shape = 16121, min_map = "027146"},
    [226] = {"敦煌遗梦",100,100,nil,nil,5, mob_name = "≮文明余晖·敦煌尊≯", mob_shape = 16121, min_map = "010336"},
    [227] = {"世界禁墟",100,100,nil,nil,5, mob_name = "≮文明终点·禁墟尊≯", mob_shape = 16170, min_map = "027156"},
    [228] = {"登神之路",0,0,nil,nil,6, mob_name = "神庭执法者?圣光守卫", mob_shape = 16170, min_map = "10244", other_name = "登神之路"},
    [229] = {"血契之地",0,0,nil,nil,6, mob_name = "血契领主?血屠", mob_shape = 16170, min_map = "10244", other_name = "血契之地"},
    [230] = {"冰川雪域",0,0,nil,nil,6, mob_name = "雪域冰王?寒魄", mob_shape = 16170, min_map = "10244", other_name = "冰川雪域"},
    [231] = {"森罗魔域",0,0,nil,nil,6, mob_name = "森罗魔主?灭世", mob_shape = 16170, min_map = "10244", other_name = "森罗魔域"},
    [232] = {"边关烽城",0,0,nil,nil,6, mob_name = "镇关大将军?烈锋", mob_shape = 16170, min_map = "10244", other_name = "边关烽城"},
    [233] = {"盛世古城",0,0,nil,nil,6, mob_name = "古城守护神?天佑 [神圣]", mob_shape = 16170, min_map = "10244", other_name = "盛世古城"},
}
local _config_spa = {
    --{"地图名",x,y,限制fun,提示文字,所属大陆}
    [300] = {"虚妄山脉", 92, 50,nil,nil,3, mob_name = "★南境荒王★", mob_shape = 12057, min_map = "027343"},
    [301] = {"鬼嘲深渊", 273, 33,nil,nil,3, mob_name = "≮北寒碎霜王≯", mob_shape = 12059, min_map = "027960"},
    [302] = {"叹息旷野", 34, 41,nil,nil,3, mob_name = "「灰翼风痕主」", mob_shape = 12039, min_map = "027941"},
    [303] = {"禁忌之海", 33, 133,nil,nil,3, mob_name = "★西海古皇★[道法合一]", mob_shape = 12105, min_map = "027961"},
    [304] = {"葬星海滩", 184, 40,nil,nil,3, mob_name = "「海殇巨皇」[至高神灵]", mob_shape = 16166, min_map = "027241"},
    [305] = {"船长室", 40, 46,nil,nil,3, mob_name = "「幽航鬼主」[通灵]", mob_shape = 16147, min_map = "027802"},
    [306] = {"水手舱", 59, 11,nil,nil,3, mob_name = "≮水手怨皇≯[通灵]", mob_shape = 16150, min_map = "027975"},
    [307] = {"黄泉路", 49, 29,nil,nil,4, mob_name = "「黄泉尽头·忘川主宰」", mob_shape = 16131, min_map = "027825"},
    [308] = {"罗酆六天", 71, 78,nil,nil,4, mob_name = "★罗酆六天·冥律至尊★", mob_shape = 16131, min_map = "028802"},
    [309] = {"东海龙宫", 31, 83,nil,nil,4, mob_name = "≮东海真主·覆海龙皇≯", mob_shape = 16167, min_map = "027179"},
    [310] = {"黑风山", 158, 72,nil,nil,4, mob_name = "★黑风大王·裂山狂尊★", mob_shape = 16461, min_map = "028560"},
    [311] = {"黄风岭", 92, 368,nil,nil,4, mob_name = "≮黄风大圣·吞天妖尊≯", mob_shape = 16461, min_map = "028563"},
    [312] = {"女儿国", 161, 146,nil,nil,4, mob_name = "「红尘情劫·女国之主」", mob_shape = 16461, min_map = "027111"},
    [313] = {"通天河", 237, 39,nil,nil,4, mob_name = "≮通天河主·覆浪妖王≯", mob_shape = 16461, min_map = "028557"},
    [314] = {"狮驼岭", 17, 87,nil,nil,4, mob_name = "★狮驼三王·青狮★", mob_shape = 16461, min_map = "027295"},
    [315] = {"天竺山", 68, 66,nil,nil,4, mob_name = "≮梵天圣境·天竺尊主≯", mob_shape = 16461, min_map = "029407"},
    [316] = {"灵域·二层", 72, 25,nil,nil,4, mob_name = "≮灵域二层·秩序主宰≯", mob_shape = 16149, min_map = "027247"},
    [317] = {"灵域·三层", 63, 61,nil,nil,4, mob_name = "≮灵域三层·终序主宰≯", mob_shape = 16149, min_map = "029405"},
    [318] = {"灵域·秘境", 21, 20,nil,nil,4, mob_name = "★灵域秘境·原初主宰★", mob_shape = 16149, min_map = "027186"},
}
-- 三大陆地图统一拦截：未开辟仙府时，只允许通过 NPC 200 进入灰界。
local function _ensure_continent_map_access(play, continent, map_name)
    if continent == 3 then
        return Player.ensureThirdContinentMapAccess(
            play,
            map_name,
            "未开#57|【开辟仙府】#218|前，三大陆目前只能进入#57|【灰界】#218|#57"
        )
    end
    return true
end
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
            local target_map = _config[npcid][1] .. (aid == 1 and "?" or "")
            if not _ensure_continent_map_access(play, _config[npcid][6], target_map) then
                return
            end
            if not _ensure_continent_map_access(play, _config[npcid][6], _config[npcid][1]) then
                return
            end
            mapmove(play,target_map,_config[npcid][2],_config[npcid][3],5)
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
            if not _ensure_continent_map_access(play, config[6], config[1]) then
                return
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
