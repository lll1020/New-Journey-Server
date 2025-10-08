npc = {}
--地图跳转npc

local _config = {
    --{"地图名",x,y,限制fun,提示文字,所属大陆,范围}
    [501] = {"xtc",137,138,nil,nil,1,5},
    [502] = {"剑门外门",104,85,nil,nil,1,5},
    [503] = {"剑门内门",104,119,nil,nil,2,5},
    [504] = {"中州城",649,183,nil,nil,3,5},
    [505] = {"天玄界",47,46,nil,nil,4,5},
    [506] = {"北境仙域",53,43,nil,nil,5,5},
    [507] = {"中央仙域",24,22,nil,nil,6,5},
    [508] = {"诡异位面",62,61,nil,nil,7,5},
    [509] = {"叹息旷野",92,76,nil,nil,8,5},
}

function npc.main(play,npcid)
    sendluamsg(play,100,npcid,0,0,"")
end

function npc.link(play,npcid,ew,aid)
    if ew == 1 then
        if _config[npcid] and Player.dl_sz(play, _config[npcid][6]) then
            if getplaydef(play,"N$战斗状态") < os.time() then
                mapmove(play,_config[npcid][1],_config[npcid][2],_config[npcid][3],_config[npcid][7])
            else
                sendmsg(play, 1, '{"Msg":"<font color=\'#ff0000\'>战斗状态无法使用...</font>","Type":9}')
            end
        end

    end
end

return npc