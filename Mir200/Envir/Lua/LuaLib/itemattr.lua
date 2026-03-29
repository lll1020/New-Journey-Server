local cfg_TaoZhuangAttr = {
  
}
--穿套装触发
local function _onGroupItemOnEx(actor ,idx)
  if cfg_TaoZhuangAttr[tonumber(idx)] then
    local attrs = {}
    local attrsstr = ""
    for v,k in ipairs(cfg_TaoZhuangAttr[tonumber(idx)].attr) do
      attrs[k[1]] = k[2]
    end
    attrsstr = Player.getAttrTableToStr(attrs)
    Player.addattlist(actor,"套装"..idx,"=",attrsstr,1)

  end
end
GameEvent.add(EventCfg.onGroupItemOnEx,_onGroupItemOnEx,"套装属性触发")

--脱套装触发
local function onGroupItemOffEx(actor ,idx)
  if cfg_TaoZhuangAttr[tonumber(idx)] then
    Player.del_attlist(actor,"套装"..idx)
  end
end
GameEvent.add(EventCfg.onGroupItemOffEx,onGroupItemOffEx,"套装属性触发")