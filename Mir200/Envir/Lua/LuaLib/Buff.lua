release_print("加载Buff模块")
Buff = {}

local weizhi = {0,1,3,4,5,6,7,8,9,10,11,13,14,16,30,31,32,33,34,35,36,37,38,39,40,41,74,75,76,78,85,86,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120}


function Buff.login(play)
    -------------------------------------------------------------------装备BUFF登录初始化
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
    -------------------------------------------------------------------额外附加属性登录初始化
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