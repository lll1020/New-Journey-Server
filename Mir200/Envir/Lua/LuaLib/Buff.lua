release_print("����Buffģ��")
Buff = {}

local weizhi = {0,1,3,4,5,6,7,8,9,10,11,13,14,16,30,31,32,33,34,35,36,37,38,39,40,41,74,75,76,78,85,86,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120}


function Buff.login(play)
    -------------------------------------------------------------------װ��BUFF��¼��ʼ��
    for k, v in pairs(weizhi) do
        local item = linkbodyitem(play,v)
        if item ~= "0" then
            if v == 14 then
                changemoney(play,16,"=",1,"��¼����",true)
            end
            local id = getstditeminfo(getiteminfo(play,item,2),8)
            if id > 0 and Buff[id] then
                Buff[id](play,1)
            end
        end
    end
    -------------------------------------------------------------------�ƺ�BUFF��¼��ʼ��
    local ch = gettitlelist(play)
    for _, v in pairs(ch) do
        local idx = getstditeminfo(getiteminfo(play,v,1),8)
        if idx and idx > 0 then
            Buff[idx](play,1)
        end
    end
    -------------------------------------------------------------------���⸽�����Ե�¼��ʼ��
    local attr = {}
    Player.updateSomeAddr(play,nil, attr)
end

GameEvent.add(EventCfg.onLogin, Buff.login, Buff)


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