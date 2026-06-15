npc = {}
--��ͼ��תnpc
local _config = {
    --{"��ͼ��",x,y,����fun,��ʾ����,�����½}
    [201] = {"ɽׯ",0,0,nil,nil,1, mob_name = "�ݵƿ�", mob_shape = 631, min_map = "010345"},
    [202] = {"�Ĺ�",0,0,nil,nil,1, mob_name = "��̦��", mob_shape = 200, min_map = "028561"},
    [203] = {"��Ѩ",0,0,nil,nil,1, mob_name = "ʯ����", mob_shape = 45, min_map = "027578"},
    [204] = {"�ŵ�",0,0,nil,nil,1, mob_name = "����ٸ", mob_shape = 12052, min_map = "027626"},
    -- [205] = {"���ص�ͼ��",0,0,nil,nil,2, mob_name = "��צ�ո���", mob_shape = 221, min_map = "000100"},
    [206] = {"Ұ���",100,100,nil,nil,2, mob_name = "���ٹ�ͳ�졤������", mob_shape = 16236, min_map = "028614"},
    [207] = {"����ǽ�",100,100,nil,nil,2, mob_name = "�������ػ��ߡ�������", mob_shape = 12015, min_map = "028574"},
    [208] = {"ɱ������",100,100,nil,nil,2, mob_name = "�ű�ִ���", mob_shape = 16192, min_map = "028808",other_name = "�����Ų�"},
    [209] = {"ҹħ��",100,100,nil,nil,2, mob_name = "����ҹħ������Ԩ��", mob_shape = 12011, min_map = "029393"},
    -- [210] = {"�����ؾ�������",0,0,nil,nil,2, mob_name = "��צ�ո���", mob_shape = 221, min_map = "000100"},
    -- [211] = {"���ص�ͼ��",0,0,nil,nil,3, mob_name = "��צ�ո���", mob_shape = 221, min_map = "000100"},
    [212] = {"�ҽ�",201,199,nil,nil,3, mob_name = "���ơ�Ǳ����", mob_shape = 12033, min_map = "027907"},
    [213] = {"���Ǻ�",100,100,nil,nil,3, mob_name = "��Ⱥ��Ԩ�ʡ�", mob_shape = 16206, min_map = "027135",other_name = "���Ǻ�"},
    [214] = {"���Ƴ�",100,100,nil,nil,3, mob_name = "����Ļ���ʡ�[����]", mob_shape = 12054, min_map = "027198"},
    -- [215] = {"������Ԩ",100,100,nil,nil,3, mob_name = "��צ�ո���", mob_shape = 221, min_map = "000100"},
    [216] = {"��ҩ��",100,100,nil,nil,3, mob_name = "���ɲݴ�����", mob_shape = 12079, min_map = "028854"},
    -- [217] = {"�����ؾ�������",0,0,nil,nil,3, mob_name = "��צ�ո���", mob_shape = 221, min_map = "000100"},
    [218] = {"ۺ�����",100,100,nil,nil,4, mob_name = "��ۺ��֮�������ڤ����", mob_shape = 16322, min_map = "027142"},
    [219] = {"���ơ�������",100,100,nil,nil,4, mob_name = "��ʢ�����桤����������", mob_shape = 16247, min_map = "027166"},
    [220] = {"��Ф����",100,100,nil,nil,4, mob_name = "��ʮ�����ࡤ��Ф���ס�", mob_shape = 16251, min_map = "027231"},
    [221] = {"��˵֮��",100,100,nil,nil,4, mob_name = "����Ŵ�˵��ʱ����֤�ߡ�", mob_shape = 16263, min_map = "027199"},
    [222] = {"���޹�",100,100,nil,nil,5, mob_name = "��̫��Ѫ�������޻ʡ�", mob_shape = 12100, min_map = "027246"},
    [223] = {"ʱ����϶",100,100,nil,nil,5, mob_name = "��ʱ�ձ������ѽ�����", mob_shape = 12100, min_map = "028125"},
    [224] = {"�����߽�",100,100,nil,nil,5, mob_name = "���������¡��߽����", mob_shape = 16121, min_map = "027242"},
    [225] = {"��ի־��",100,100,nil,nil,5, mob_name = "�������������������", mob_shape = 16121, min_map = "027146"},
    [226] = {"�ػ�����",100,100,nil,nil,5, mob_name = "���������͡��ػ����", mob_shape = 16121, min_map = "010336"},
    [227] = {"�������",100,100,nil,nil,5, mob_name = "�������յ㡤�������", mob_shape = 16170, min_map = "027156"},
    [228] = {"登神之路",0,0,nil,nil,6, mob_name = "神庭执法者・圣光守卫", mob_shape = 16170, min_map = "10244", other_name = "登神之路"},
    [229] = {"血契之地",0,0,nil,nil,6, mob_name = "血契领主・血屠", mob_shape = 16170, min_map = "10244", other_name = "血契之地"},
    [230] = {"冰川雪域",0,0,nil,nil,6, mob_name = "雪域冰王・寒魄", mob_shape = 16170, min_map = "10244", other_name = "冰川雪域"},
    [231] = {"森罗魔域",0,0,nil,nil,6, mob_name = "森罗魔主・灭世", mob_shape = 16170, min_map = "10244", other_name = "森罗魔域"},
    [232] = {"边关烽城",0,0,nil,nil,6, mob_name = "镇关大将军・烈锋", mob_shape = 16170, min_map = "10244", other_name = "边关烽城"},
    [233] = {"盛世古城",0,0,nil,nil,6, mob_name = "古城守护神・天佑 [神圣]", mob_shape = 16170, min_map = "10244", other_name = "盛世古城"},
}
local _config_spa = {
    --{"��ͼ��",x,y,����fun,��ʾ����,�����½}
    [300] = {"����ɽ��", 92, 50,nil,nil,3, mob_name = "���Ͼ�������", mob_shape = 12057, min_map = "027343"},
    [301] = {"�����Ԩ", 273, 33,nil,nil,3, mob_name = "�ڱ�����˪����", mob_shape = 12059, min_map = "027960"},
    [302] = {"̾Ϣ��Ұ", 34, 41,nil,nil,3, mob_name = "������������", mob_shape = 12039, min_map = "027941"},
    [303] = {"����֮��", 33, 133,nil,nil,3, mob_name = "�������Żʡ�[������һ]", mob_shape = 12105, min_map = "027961"},
    [304] = {"���Ǻ�̲", 184, 40,nil,nil,3, mob_name = "������޻ʡ�[��������]", mob_shape = 16166, min_map = "027241"},
    [305] = {"������", 40, 46,nil,nil,3, mob_name = "���ĺ�������[ͨ��]", mob_shape = 16147, min_map = "027802"},
    [306] = {"ˮ�ֲ�", 59, 11,nil,nil,3, mob_name = "��ˮ��Թ�ʡ�[ͨ��]", mob_shape = 16150, min_map = "027975"},
    [307] = {"��Ȫ·", 49, 29,nil,nil,4, mob_name = "����Ȫ��ͷ���������ס�", mob_shape = 16131, min_map = "027825"},
    [308] = {"��ۺ����", 71, 78,nil,nil,4, mob_name = "����ۺ���졤ڤ�������", mob_shape = 16131, min_map = "028802"},
    [309] = {"��������", 31, 83,nil,nil,4, mob_name = "�ڶ����������������ʡ�", mob_shape = 16167, min_map = "027179"},
    [310] = {"�ڷ�ɽ", 158, 72,nil,nil,4, mob_name = "��ڷ��������ɽ�����", mob_shape = 16461, min_map = "028560"},
    [311] = {"�Ʒ���", 92, 368,nil,nil,4, mob_name = "�ڻƷ��ʥ�����������", mob_shape = 16461, min_map = "028563"},
    [312] = {"Ů����", 161, 146,nil,nil,4, mob_name = "���쳾��١�Ů��֮����", mob_shape = 16461, min_map = "027111"},
    [313] = {"ͨ���", 237, 39,nil,nil,4, mob_name = "��ͨ�����������������", mob_shape = 16461, min_map = "028557"},
    [314] = {"ʨ����", 17, 87,nil,nil,4, mob_name = "��ʨ����������ʨ��", mob_shape = 16461, min_map = "027295"},
    [315] = {"����ɽ", 68, 66,nil,nil,4, mob_name = "������ʥ��������������", mob_shape = 16461, min_map = "029407"},
    [316] = {"���򡤶���", 72, 25,nil,nil,4, mob_name = "��������㡤�������ס�", mob_shape = 16149, min_map = "027247"},
    [317] = {"��������", 63, 61,nil,nil,4, mob_name = "���������㡤�������ס�", mob_shape = 16149, min_map = "029405"},
    [318] = {"�����ؾ�", 21, 20,nil,nil,4, mob_name = "�������ؾ���ԭ�����ס�", mob_shape = 16149, min_map = "027186"},
}
-- ����½��ͼͳһ���أ�δ�����ɸ�ʱ��ֻ����ͨ�� NPC 200 ����ҽ硣
local function _ensure_continent_map_access(play, continent, map_name)
    if continent == 3 then
        return Player.ensureThirdContinentMapAccess(
            play,
            map_name,
            "δ��#57|�������ɸ���#218|ǰ������½Ŀǰֻ�ܽ���#57|���ҽ硿#218|#57"
        )
    end
    return true
end
function npc.main(play,npcid)
    sendluamsg(play,100,npcid,0,0,"")
end
function npc.link(play,npcid,ew,aid)
    -- npc_guard: ���У��
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local __guardAction = Guard.normalizeAction(play, npcid, ew)
    if __guardAction == nil then
        return
    end
    ew = __guardAction
    -- npc_guard: �������������Ż����޶��Ϸ�������ţ�
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
            if npcid == 300 then -- ����ɽ��  621 ��Ӧ��������ɿ��Խ���
                if not (jq_data["npc_621"] and jq_data["npc_621"] >= 2) then
                    Player.sendmsgEx(play, "����δ��ɣ��޷�����#57")
                    return
                end
            elseif npcid == 301 then -- �����Ԩ  623 ��Ӧ��������ɿ��Խ���
                if not (jq_data["npc_623"] and jq_data["npc_623"] >= 2) then
                    Player.sendmsgEx(play, "����δ��ɣ��޷�����#57")
                    return
                end
            elseif npcid == 302 then -- ̾Ϣ��Ұ  622 ��Ӧ��������ɿ��Խ���
                if not (jq_data["npc_622"] and jq_data["npc_622"] >= 2) then
                    Player.sendmsgEx(play, "����δ��ɣ��޷�����#57")
                    return
                end
            elseif npcid == 303 then -- ����֮��  624 ��Ӧ��������ɿ��Խ���
                if not (jq_data["npc_624"] and jq_data["npc_624"] >= 2) then
                    Player.sendmsgEx(play, "����δ��ɣ��޷�����#57")
                    return
                end
            elseif npcid == 304 then -- ���Ǻ�̲  ��Ӧ��ʱ���� �л���ͼ����
                local hour = tonumber(os.date("%H")) or 0
                mapmove(play,(hour % 2 == 0) and "���Ǻ�̲" or "���Ǻ�̲1",config[2],config[3],5)
                return
            elseif npcid == 305 then -- ������ 629��������� -a
                if jq_data["npc_629_a"] ~= 1 then
                    Player.sendmsgEx(play, "δ��ɶ�Ӧ�ύ���޷�����#57")
                    return
                end
            elseif npcid == 306 then -- ˮ�ֲ� 629��������� -b
                if jq_data["npc_629_b"] ~= 1 then
                    Player.sendmsgEx(play, "δ��ɶ�Ӧ�ύ���޷�����#57")
                    return
                end
            elseif npcid == 307 then -- ��Ȫ· 667���������
                if not (jq_data["npc_667"] and jq_data["npc_667"] >= 2) then
                    Player.sendmsgEx(play, "����δ��ɣ��޷�����#57")
                    return
                end
            elseif npcid == 308 then -- ��ۺ���� 669���������
                if not (jq_data["npc_669"] and jq_data["npc_669"] >= 2) then
                    Player.sendmsgEx(play, "����δ��ɣ��޷�����#57")
                    return
                end
            elseif npcid == 309 then -- �������� 642���������
                if not (jq_data["npc_642"] and jq_data["npc_642"] >= 2) then
                    Player.sendmsgEx(play, "����δ��ɣ��޷�����#57")
                    return
                end
            elseif npcid == 310 then -- �ڷ�ɽ 643���������
                if not (jq_data["npc_643"] and jq_data["npc_643"] >= 2) then
                    Player.sendmsgEx(play, "����δ��ɣ��޷�����#57")
                    return
                end
            elseif npcid == 311 then -- �Ʒ��� 644���������
                if not (jq_data["npc_644"] and jq_data["npc_644"] >= 2) then
                    Player.sendmsgEx(play, "����δ��ɣ��޷�����#57")
                    return
                end
            elseif npcid == 312 then -- Ů���� 645���������
                if not (jq_data["npc_645"] and jq_data["npc_645"] >= 2) then
                    Player.sendmsgEx(play, "����δ��ɣ��޷�����#57")
                    return
                end
            elseif npcid == 313 then -- ͨ��� 646���������
                if not (jq_data["npc_646"] and jq_data["npc_646"] >= 2) then
                    Player.sendmsgEx(play, "����δ��ɣ��޷�����#57")
                    return
                end
            elseif npcid == 314 then -- ʨ���� 647���������
                if not (jq_data["npc_647"] and jq_data["npc_647"] >= 2) then
                    Player.sendmsgEx(play, "����δ��ɣ��޷�����#57")
                    return
                end
            elseif npcid == 315 then -- ����ɽ 648���������
                if not (jq_data["npc_648"] and jq_data["npc_648"] >= 2) then
                    Player.sendmsgEx(play, "����δ��ɣ��޷�����#57")
                    return
                end
            elseif npcid == 316 then -- ���򡤶��� 663���������
                if not (jq_data["npc_663"] and jq_data["npc_663"] >= 2) then
                    Player.sendmsgEx(play, "����δ��ɣ��޷�����#57")
                    return
                end
            elseif npcid == 317 then -- �������� 664���������
                if not (jq_data["npc_664"] and jq_data["npc_664"] >= 2) then
                    Player.sendmsgEx(play, "����δ��ɣ��޷�����#57")
                    return
                end
            elseif npcid == 318 then -- �����ؾ� 665���������
                if not (jq_data["npc_665"] and jq_data["npc_665"] >= 2) then
                    Player.sendmsgEx(play, "����δ��ɣ��޷�����#57")
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
    startautoattack(play) --�Զ�����
end
return npc
