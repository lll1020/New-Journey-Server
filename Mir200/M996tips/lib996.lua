lib996={};
---判断虚拟机index是否存在
---* id  number  id
---@param id  number 
---@return boolean   true：成功 | false：不成功
---@nodiscard
function lib996:hassysindex(id) end;

---玩家放技能时触发
---* actor  userdata  释放者
---* role  userdata 受害者(不存在时为空)
---* skillid  number  技能id
---* name  string  技能名称
---* x  number  打击点x坐标
---* y  number  打击点y坐标
---@param actor  userdata 
---@param role  userdata
---@param skillid  number 
---@param name  string 
---@param x  number 
---@param y  number 
---@nodiscard
function on_spell(actor,role,skillid,name,x,y) end;

---获取服务器id
---@return return number 返回服务器id
---@nodiscard
function lib996:getserverid() end;

---获取游戏id
---@return return number 返回游戏id
---@nodiscard
function lib996:getgameid() end;

---获取当前引擎号
---@return return string 返回当前引擎号
---@nodiscard
function getm2version() end;

---请求HTTPPost
---* url  string   链接地址
---* stringfun  fun   回调函数
---* suffix  string   请求信息
---* head  json字符串格式   请求头
---@param url  string 
---@param stringfun  fun 
---@param suffix  string 
---@param head  json字符串格式 
---@nodiscard
function lib996:httprequestpost(url,strfun,suffix,head) end;

---请求HTTPGet
---* url  string   链接地址
---* stringfun  fun   回调函数
---@param url  string 
---@param stringfun  fun 
---@nodiscard
function lib996:httprequestget(url,strfun) end;

---获取物品模板属性
---* Idx  number  物品id
---@param Idx  number 
---@return string | 返回物品装备表中配置的属性
---@nodiscard
function lib996:getstditemattr(Idx) end;

---获取称谓
---* actor  userdata  玩家对象
---* type  number  0.名字前  1.名字后
---@param actor  userdata 
---@param type  number 
---@nodiscard
function lib996:getalias(actor,type) end;

---设置称谓
---* actor  userdata  玩家对象
---* string  string  称谓
---* type  number  0.名字前  1.名字后
---@param actor  userdata 
---@param string  string 
---@param type  number 
---@nodiscard
function lib996:setalias(actor,str,type) end;

---根据技能名称获取技能id
---* name string  	技能name
---@param name string 
---@return 技能对象：userdata
---@nodiscard
function lib996:getskillindex(name) end;

---根据技能id获取技能名称
---* id number  	技能id
---@param id number 
---@return 技能名称：string
---@nodiscard
function lib996:getskillname(id) end;

---玩家放技能前触发
---* actor  userdata  释放者
---* role  userdata 受害者(不存在时为空)
---* skillid  number  技能id
---* name  string  技能名称
---* x  number  打击点x坐标
---* y  number  打击点y坐标
---@param actor  userdata 
---@param role  userdata
---@param skillid  number 
---@param name  string 
---@param x  number 
---@param y  number 
---@return boolean  true——允许释放|false—阻止释放
---@nodiscard
function on_spell_pre(actor,role,skillid,name,x,y) end;

---对象是否存在
---*  actor  	userdata  玩家对象
---@param  actor  	userdata 
---@return boolean   true：存在 | false：不存在
---@nodiscard
function lib996:isnotnull(actor) end;

---立即杀死角色
---* aactor  userdata  受害者对象
---* bactor  userdata  凶手对象 填nil为系统杀死
---@param aactor  userdata 
---@param bactor  userdata 
---@return boolean  true——成功|false——失败
---@nodiscard
function lib996:kill(aactor,babtor) end;

---使用物品前
---* actor  userdata  对象
---* itemmakeid  number   makeid(唯一ID)
---* itemname string   物品名称
---* itemid  number   物品id
---@param actor  userdata 
---@param itemmakeid  number 
---@param itemname string 
---@param itemid  number 
---@return boolean  true——允许|false—不许
---@nodiscard
function stdmodefuncAnicount(actor,itemmakeid,itemname,itemid) end;

---根据唯一id销毁玩家仓库物品
---* actor  userdata  对象
---* makeid  number  唯一id
---* count  number  叠加物品扣除数量,不填此参数,默认全部扣除,不可叠加物品全部扣除
---@param actor  userdata 
---@param makeid  number 
---@param count  number 
---@return boolean  true——成功|false——失败
---@nodiscard
function lib996:dessitems(actor,makeid,count) end;

---对目标释放技能
---* actor  userdata  玩家对象
---* skillid  number   技能ID
---* type number  	类型：1-普通技能2-强化技能
---* level  number  技能等级
---* target  userdata   目标对象
---* flag number  	是否显示施法动作：0-不显示,1-显示
---@param actor  userdata 
---@param skillid  number 
---@param type number 
---@param level  number 
---@param target  userdata 
---@param flag number 
---@nodiscard
function lib996:releasemagic_target(actor,skillid,type,level,target,flag) end;

---删除玩家仓库指定物品
---* actor  userdata  对象
---* itemname  string  物品名称
---* qty  number  数量
---@param actor  userdata 
---@param itemname  string 
---@param qty  number 
---@return boolean  true——成功|false——失败
---@nodiscard
function lib996:delsitems(actor,itemname,qty) end;

---对坐标释放技能
---* actor  userdata  玩家对象
---* skillid  number   技能ID
---* type number  	类型：1-普通技能2-强化技能
---* level  number  技能等级
---* x  number   目标点X坐标
---* y  number   目标点Y坐标
---* flag number  	是否显示施法动作：0-不显示,1-显示
---@param actor  userdata 
---@param skillid  number 
---@param type number 
---@param level  number 
---@param x  number 
---@param y  number 
---@param flag number 
---@nodiscard
function lib996:releasemagic_pos(actor,skillid,type,level,x,y,flag) end;

---设置英雄名称
---* actor  userdata  玩家对象
---* name  string  英雄名称
---@param actor  userdata 
---@param name  string 
---@nodiscard
function lib996:checkheroname(actor,name) end;

---获取玩家仓库最大格子数
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return number 仓库最大格子数|失败则返回-1
---@nodiscard
function lib996:getssize(actor) end;

---获取服务器名称
---@return string | 名称
---@nodiscard
function lib996:getservername() end;

---获取玩家仓库指定物品的数量
---* actor  userdata  对象
---* itemname  string  物品名称
---* itype  number  绑定类型 0：绑定,1非绑定,2绑定/非绑定
---@param actor  userdata 
---@param itemname  string 
---@param itype  number 
---@return number 指定物品的数量|失败则返回-1
---@nodiscard
function lib996:sitemcount(actor,itemname,itype) end;

---获取玩家背包指定物品的数量
---* actor  userdata  玩家对象
---* itemname  string  物品名称
---* itype  number  绑定类型 0：绑定,1非绑定,2绑定/非绑定
---@param actor  userdata 
---@param itemname  string 
---@param itype  number 
---@return number  成功——物品数量|失败——-1
---@nodiscard
function lib996:itemcount(actor,itemname,itype) end;

---获取仓库剩余空格数
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return number 空格数|失败则返回-1
---@nodiscard
function lib996:getsblank(actor) end;

---攻击时
---* attacks  userdata  攻击者对象
---* roles  userdata 受害者对象
---* skillid  number  技能id
---@param attacks  userdata 
---@param roles  userdata
---@param skillid  number 
---@nodiscard
function attack(attacks,roles,skillid) end;

---根据物品makeindex获取物品名称
---* makeindex  number  物品makeindex
---@param makeindex  number 
---@return string
---@nodiscard
function lib996:getnamebymakeindex(makeindex) end;

---删除称谓
---* actor  userdata  玩家对象
---* type  number  0.名字前  1.名字后
---@param actor  userdata 
---@param type  number 
---@nodiscard
function lib996:delalias(actor,type) end;

---设置玩家转生等级
---* actor  userdata  玩家对象
---* n  number  当前转生等级
---@param actor  userdata 
---@param n  number 
---@nodiscard
function lib996:setrelevel(actor,n) end;

---获取怪物主人对象
---* mon  userdata  怪物对象
---@param mon  userdata 
---@return userdata | 返回宠物宝宝等主人的对象,或空字符串
---@nodiscard
function lib996:getmonplayer(mon) end;

---获取怪物行为代码
---* monid   number  	怪物id
---@param monid   number 
---@return number  成功 —— 怪物行为代码|失败 —— -1
---@nodiscard
function lib996:getmonrace(monid)  end;

---竞价时触发
---* actor  userdata  玩家对象
---* money  number  货币id
---* moneynum  number  竞价
---* itemid  number  购买的物品id
---* makeid  number  购买的物品唯一id
---* itemname  string  购买的物品名称
---* num  number  购买的物品数量
---@param actor  userdata 
---@param money  number 
---@param moneynum  number 
---@param itemid  number 
---@param makeid  number 
---@param itemname  string 
---@param num  number 
---@return boolean  true——允许|false—不许
---@nodiscard
function biddingpaimaiitem(actor,money,moneynum,itemid,makeid,itemname,num) end;

---对目标对象释放技能特效
---*  actor  	userdata  玩家对象
---*  magicid  	number  特效id
---*  target  	userdata  目标对象
---@param  actor  	userdata 
---@param  magicid  	number 
---@param  target  	userdata 
---@nodiscard
function lib996:releasemagiceffect(actor,magicid,target) end;

---获取怪物id
---* mon  userdata  怪物对象
---@param mon  userdata 
---@return number  返回怪物模板id
---@nodiscard
function lib996:getmonidx(mon) end;

---设置宝宝叛变
---* mon  userdata  怪物对象
---@param mon  userdata 
---@nodiscard
function lib996:betray(mon) end;

---获取已穿戴的套装件数
---* actor  userdata  玩家对象
---* ID  number  套装ID
---@param actor  userdata 
---@param ID  number 
---@return number 套装件数
---@nodiscard
function lib996:getsuititemcount(actor, ID) end;

---新建任务时触发
---* actor  userdata  玩家对象
---* id  number  新建的任务id
---@param actor  userdata 
---@param id  number 
---@nodiscard
function picktask(actor,id) end;

---读邮件时触发
---* actor  userdata  对象
---@param actor  userdata 
---@nodiscard
function readmail(actor) end;

---任务被点击时
---* actor  userdata  玩家对象
---* id  number  任务id
---@param actor  userdata 
---@param id  number 
---@nodiscard
function clicknewtask(actor,id) end;

---穿装备前
---* actor  userdata  对象
---* itemid  number   物品id
---* pos number   位置
---* itemname string   物品名称
---* itemmakeid  number   makeid(唯一ID)
---@param actor  userdata 
---@param itemid  number 
---@param pos number 
---@param itemname string 
---@param itemmakeid  number 
---@return boolean  true——允许穿戴|false—不许
---@nodiscard
function on_take_on_pre(actor,itemid,pos,itemname,itemmakeid) end;

---自动寻路开始时触发
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function findpathbegin(actor) end;

---自动寻路停止时触发
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function findpathstop(actor) end;

---判断角色是否有该物品
---* actor  userdata  玩家对象
---* makeid  number  物品makeindex
---@param actor  userdata 
---@param makeid  number 
---@return 返回 0-装备,1-背包,2-仓库, -1-不存在或失败|
---@nodiscard
function lib996:hasitem(actor,makeid) end;

---拿物品(拓展)
---@return boolean   true：成功 | false：失败
---@nodiscard
function lib996:takeitemex(actor,itme_name,item_num,bind,desc) end;

---设置行会成员在行会中的职位
---* actor  userdata  玩家对象
---* pos  number  在行会中的职位 1：会长2：副会长3：称谓34：称谓45：称谓5
---@param actor  userdata 
---@param pos  number 
---@return booleanean |true——设置成功|false——设置失败
---@nodiscard
function lib996:setplayguildlevel(actor,pos) end;

---判断某个玩家是否在该行会中
---* actor  userdata  玩家对象
---* guiid  string  行会id
---@param actor  userdata 
---@param guiid  string 
---@return booleanean |true——存在|false——不存在
---@nodiscard
function lib996:isinguild(actor,guiid) end;

---判断行会是否存在
---* guiname  string  行会名
---@param guiname  string 
---@return booleanean |true——存在|false——不存在
---@nodiscard
function lib996:hasguild(guiname) end;

---获取buff配置属性
---* buffid  number buffid
---@param buffid  number
---@return table
---@nodiscard
function lib996:getbufftemattr(buffid) end;

---获取buff配置时间
---* buffid  number buffid
---@param buffid  number
---@return number 时间
---@nodiscard
function lib996:getbufftemtime(buffid) end;

---获取两个行会之间的关系
---* aguiid  string  A行会名称
---* bguiid  string  B行会名称
---@param aguiid  string 
---@param bguiid  string 
---@return 成功——行会关系|失败——-1
---@nodiscard
function lib996:getguildrelation(aguiid,bguiid) end;

---设置行会关系
---* aguiid  number  A行会id
---* bguiid  number  B行会id
---* opt  string  行会名 0：普通,1：敌对,2：盟友
---@param aguiid  number 
---@param bguiid  number 
---@param opt  string 
---@return booleanean |true——成功|false——失败
---@nodiscard
function lib996:setguildrelation(aguiid,bguiid,opt) end;

---获取buff组别
---* buffid  number buffid
---@param buffid  number
---@return number 组别
---@nodiscard
function lib996:getbuffgroup(buffid) end;

---获取行会名称
---* guiid  number  行会id
---@param guiid  number 
---@return number 成功——行会名称|失败——nil
---@nodiscard
function lib996:getguildname(guiid) end;

---获取物品唯一id
---* item  userdata  物品对象
---@param item  userdata 
---@return number 成功——物品唯一id|失败——0
---@nodiscard
function lib996:getitemmakeid(item) end;

---获取行会id
---* guiname  string  行会名
---@param guiname  string 
---@return number 成功——行会id|失败——-1
---@nodiscard
function lib996:getguildid(guiname) end;

---根据id获取物品自定义常量(30列)
---* id  number  物品id
---@param id  number 
---@return string |成功——物品自定义常量(30列)|失败——-1
---@nodiscard
function lib996:getitembvar(id) end;

---获取地图上玩家的数量
---*  mapid  	string  地图id
---*  igndied  	boolean  是否忽略死亡角色 true:忽略 false:不忽略
---@param  mapid  	string 
---@param  igndied  	boolean 
---@return number 成功——玩家数量|失败——-1
---@nodiscard
function lib996:getplaycount(mapid,igndied) end;

---根据id获取物品自定义常量(29列)
---* id  number  物品id
---@param id  number 
---@return string |成功——物品自定义常量(29列)|失败——-1
---@nodiscard
function lib996:getitemavar(id) end;

---获取地图上怪物的数量
---*  mapid  	string  地图id
---*  monid  	number  怪物id,为-1时即为所有
---*  ignbb  	boolean  是否忽略宝宝 true:忽略 false:不忽略
---@param  mapid  	string 
---@param  monid  	number 
---@param  ignbb  	boolean 
---@return number 成功——怪物数量|失败——-1
---@nodiscard
function lib996:getmoncount(mapid,monid,ignbb) end;

---根据id获取物品使用等级
---* id  number  物品id
---@param id  number 
---@return number 成功——物品使用等级|失败——-1
---@nodiscard
function lib996:getitemneedlevel(id) end;

---判断坐标是否在指定区域中
---*  isx  	number  判断定的x坐标
---*  isy  	number  判断定的y坐标
---*  rx  	number  区域中心的x坐标
---*  ry  	number  区域中心的y坐标
---*  radius  	number  区域半径
---@param  isx  	number 
---@param  isy  	number 
---@param  rx  	number 
---@param  ry  	number 
---@param  radius  	number 
---@return booleanean |true——在区域中|false——不在
---@nodiscard
function lib996:isinregion(isx,isy,rx,ry,radius) end;

---根据id获取物品使用条件
---* id  number  物品id
---@param id  number 
---@return number 成功——物品使用条件|失败——-1
---@nodiscard
function lib996:getitemneed(id) end;

---获取角色技能最大冷却时间
---* actor userdata  	玩家对象
---* id number  	技能id
---@param actor userdata 
---@param id number 
---@return 成功——剩余CD时间-单位毫秒|失败—— -1：number
---@nodiscard
function lib996:getskillmaxcd(actor,id) end;

---获取经验时触发
---* actor  userdata  玩家对象
---* exp  number  经验值
---@param actor  userdata 
---@param exp  number 
---@nodiscard
function gainexp(actor,exp) end;

---货币改变时触发
---* actor  userdata  玩家对象
---* id  number  货币id
---* beforenum  number  改变前货币数量
---* afternum  number  改变后货币数量
---@param actor  userdata 
---@param id  number 
---@param beforenum  number 
---@param afternum  number 
---@nodiscard
function moneychangeex(actor,id,beforenum,afternum) end;

---是否有英雄
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return boolean   true:有 | false:没有
---@nodiscard
function lib996:hashero(actor) end;

---假人结束摆摊时
---* actor  userdata  假人对象
---* itemtab  json  假人摆摊物品表
---@param actor  userdata 
---@param itemtab  json 
---@nodiscard
function on_stall_end(actor,itemtab) end;

---创建英雄
---* actor  userdata  玩家对象
---* name  string  英雄名字
---* job  number  职业
---* sex  number  性别
---@param actor  userdata 
---@param name  string 
---@param job  number 
---@param sex  number 
---@nodiscard
function lib996:createhero(actor,name,job,sex) end;

---获取当前平台
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return WINDOWS = 0|        LINUX   = 1|        MAC     = 2|        ANDROID = 3|        IPHONE  = 4|        IPAD    = 5|        BLACKBERRY = 6|        NACL    = 7|        EMSCRIPTEN = 8|        TIZEN   = 9|        WINRT   = 10|        WP8     = 11
---@nodiscard
function lib996:getplatform(actor) end;

---删除英雄
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function lib996:delhero(actor) end;

---假人登录时
---* actor  userdata  假人对象
---@param actor  userdata 
---@nodiscard
function dummylogin(actor) end;

---召唤英雄
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function lib996:recallhero(actor) end;

---获取宠物对象列表
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return table | 成功——宠物对象列表|失败——nil
---@nodiscard
function lib996:getslavelist(actor) end;

---获取所有技能id
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return table | 技能id
---@nodiscard
function lib996:getallskills(actor) end;

---收回英雄
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function lib996:unrecallhero(actor) end;

---获取宠物对象数量
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return table | 成功：宠物数量|失败：-1
---@nodiscard
function lib996:getslavenum(actor) end;

---获取英雄对象
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return userdata | 返回英雄对象,如果没有返回 nil 或 "0"
---@nodiscard
function lib996:gethero(actor) end;

---打印触发器消耗
---@nodiscard
function lib996:printscripttimereport() end;

---获取int型期限变量
---* type  number  类型0:玩家,1:行会,2:地图,3：物品,4：NPC
---* actor  obj  对象
---* varname string  变量名
---@param type  number 
---@param actor  obj 
---@param varname string 
---@return 返回数量:2 | number  |返回期限变量值 过期时返回——0|number  |返回期限变量剩余刷新时间 过期时返回——0|
---@nodiscard
function lib996:gettlint(type,actor,varname) end;

---重置触发器消耗记录
---@nodiscard
function lib996:resetscripttimereport() end;

---设置int型期限变量
---* type  number  类型0:玩家,1:行会,2:地图,3：物品,4：NPC
---* actor  obj  对象
---* varname  string  变量名
---* value  number 变量值
---* cdtime  number 期限时间(秒),0或nil不变,-1立即清除
---@param type  number 
---@param actor  obj 
---@param varname  string 
---@param value  number
---@param cdtime  number
---@return boolean   true——成功|false——失败|
---@nodiscard
function lib996:settlint(type,actor,varname,value,cdtime) end;

---获取当前虚拟机编号
---@return number
---@nodiscard
function lib996:getsysindex() end;

---buff触发血量改变时
---* actor  userdata  对象
---* buffID  number buffid
---* buffGroup number  buff组
---* HP number  hp
---* BUFFhost userdata  释放者
---@param actor  userdata 
---@param buffID  number
---@param buffGroup number 
---@param HP number 
---@param BUFFhost userdata 
---@return number  hp
---@nodiscard
function bufftriggerhpchange(actor, buffID, buffGroup,HP,BUFFhost) end;

---英雄取名成功触发
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function checkusernameok(actor) end;

---英雄登陆触发
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function herologin(actor) end;

---英雄取名失败触发
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function checkusernameno(actor) end;

---通知周围血量与蓝量变化
---* actor  userdata  对象
---@param actor  userdata 
---@nodiscard
function lib996:healthspellchanged(actor) end;

---获取行会成员在行会中的职位
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return number 成功——返回当前职位|失败——-1
---@nodiscard
function lib996:getplayguildlevel(actor) end;

---领取竞价物品时
---* actor  userdata  玩家对象
---* money  number  货币id
---* moneynum  number  消耗货币量
---* itemid  number  购买的物品id
---* makeid  number  购买的物品唯一id
---* itemname  string  购买的物品名称
---* num  number  购买的物品数量
---@param actor  userdata 
---@param money  number 
---@param moneynum  number 
---@param itemid  number 
---@param makeid  number 
---@param itemname  string 
---@param num  number 
---@return boolean  true——允许|false—不许
---@nodiscard
function getpaimaiitem(actor,money,moneynum,itemid,makeid,itemname,num) end;

---怪物掉落物品前触发
---* actor  userdata  玩家对象
---* DropItem  number  物品对象
---* mon  number  怪物对象
---* x  number  X坐标
---* y  number  Y坐标
---@param actor  userdata 
---@param DropItem  number 
---@param mon  number 
---@param x  number 
---@param y  number 
---@return boolean   true：允许掉落,false：不允许
---@nodiscard
function mondropitemex(actor,DropItem, mon, x, y) end;

---刷新物品变量到前端
---* actor  userdata  玩家对象
---* makeid  number  物品makeindex(物品唯一id)
---@param actor  userdata 
---@param makeid  number 
---@nodiscard
function lib996:senditemvartoc(actor,makeid) end;

---在地图上生成掉落物品
---*  mapid  	number  地图id
---*  actor  	userdata  归属对象 填nil 无归属 且拾取cd时间会被设置为0
---*  X  	number  x坐标
---*  Y  	number  y坐标
---*  json  	string  掉落json
---*  data  	string  物品来源(参考设置物品来源)
---@param  mapid  	number 
---@param  actor  	userdata 
---@param  X  	number 
---@param  Y  	number 
---@param  json  	string 
---@param  data  	string 
---@return table |成功——makeid表|失败——nil
---@nodiscard
function lib996:gendropitem(mapid,actor,x,y,json,data) end;

---额外解锁仓库格子
---* actor  userdata  玩家对象
---* count  number   要解释的格子数
---@param actor  userdata 
---@param count  number 
---@nodiscard
function lib996:changestorage(actor,count) end;

---杀死人物时触发
---* actor  userdata  触发对象
---* play  userdata   被杀玩家
---@param actor  userdata 
---@param play  userdata 
---@nodiscard
function killplay(actor, play) end;

---获取所有毫秒数
---@return number  获取1970年1月1日到现在的所经过的毫秒数UTC
---@nodiscard
function lib996:getalltimems() end;

---开启自动挂机
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function lib996:startautoattack(actor) end;

---获取物品装备位
---*  itemid  	number  物品id
---@param  itemid  	number 
---@return boolean  成功——装备位|失败——-1
---@nodiscard
function lib996:getitemsite(itemid) end;

---获取int型周期变量
---* type  number  类型0:玩家,1:行会,2:地图,3：物品,4：NPC
---* actor  obj  对象
---* varname string  变量名
---@param type  number 
---@param actor  obj 
---@param varname string 
---@return 返回数量:2 | number  |返回期限变量值 过期时返回——0|number  |返回期限变量剩余刷新时间 过期时返回——0|
---@nodiscard
function lib996:getcyint(type,actor,varname) end;

---播放声音
---* actor  userdata  玩家对象
---* id  number   播放文件的索引对应声音配置表id(cfg_sound.xls)
---* count  number   循环播放次数
---* flag  number   0.播放给自己1.播放给全服2.播放给同一地图4.播放给同屏人物
---@param actor  userdata 
---@param id  number 
---@param count  number 
---@param flag  number 
---@nodiscard
function lib996:playsound(actor,id,count,flag) end;

---设置角色离线挂机(拓展)
---*  actor  	userdata  玩家对象
---*  mapid  	number  目标地图id
---*  X  	number  x坐标
---*  Y  	number  y坐标
---*  range  	number  范围
---*  mon  	boolean  是否释放宝宝宠物(镖车除外)
---@param  actor  	userdata 
---@param  mapid  	number 
---@param  X  	number 
---@param  Y  	number 
---@param  range  	number 
---@param  mon  	boolean 
---@nodiscard
function lib996:setoffline(actor,mapid,x,y,range) end;

---设置int型周期变量
---* type  number  类型0:玩家,1:行会,2:地图,3：物品,4：NPC
---* actor  obj  对象
---* varname string  变量名
---* value string  变量值
---* cyclevar string 周期值 -1立即清除
---* cycletype string 周期类型 0-天,1-周,2-月,3-小时
---* acttime string 开始时间 格式："2023-12-9 20:00:00" nil:为当前时间
---@param type  number 
---@param actor  obj 
---@param varname string 
---@param value string 
---@param cyclevar string
---@param cycletype string
---@param acttime string
---@return boolean   true——成功|false——失败
---@nodiscard
function lib996:setcyint(type,actor,varname,value,cyclevar,cycletype,acttime) end;

---丢失镖车触发
---* actor  userdata  玩家对象
---* monobj  userdata  镖车对象
---@param actor  userdata 
---@param monobj  userdata 
---@nodiscard
function losercar(actor, monobj) end;

---停止当前动作
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function lib996:stop(actor) end;

---获取str型周期变量
---* type  number  类型0:玩家,1:行会,2:地图,3：物品,4：NPC
---* actor  obj  对象
---* varname string  变量名
---@param type  number 
---@param actor  obj 
---@param varname string 
---@return 返回数量:2 | string |返回期限变量值 过期时返回——0|number  |返回期限变量剩余刷新时间 过期时返回——0|
---@nodiscard
function lib996:getcystr(type,actor,varname) end;

---获取所有buff
---* actor  userdata  对象
---@param actor  userdata 
---@return table | 返回当前对象身上所有buffid
---@nodiscard
function lib996:getallbuffid(actor) end;

---修复城墙城门守卫
---* param  number  param: 0- 全部1-仅城门和墙2-仅弓箭手和守卫不填 默认为0
---@param param  number 
---@nodiscard
function lib996:repaircastle(param) end;

---播放屏幕特效
---* actor  userdata  玩家对象
---* id  number  特效编号
---* effectid  number  特效ID
---* x  number  在屏幕上的X坐标
---* y  number  在屏幕上的Y坐标
---* speed  number  播放速度
---* times  number  播放次数 0为持续
---* itype  number  0:自己 1:所有人
---@param actor  userdata 
---@param id  number 
---@param effectid  number 
---@param x  number 
---@param y  number 
---@param speed  number 
---@param times  number 
---@param itype  number 
---@nodiscard
function lib996:screffects(actor,id,effectid,x,y,speed,times,itype) end;

---设置str型周期变量
---* type  number  类型0:玩家,1:行会,2:地图,3：物品,4：NPC
---* actor  obj  对象
---* varname string  变量名
---* value number  变量值
---* cyclevar string 周期值 -1立即清除
---* cycletype string 周期类型 0-天,1-周,2-月,3-小时
---* acttime string 开始时间 格式："2023-12-9 20:00:00" nil:为当前时间
---@param type  number 
---@param actor  obj 
---@param varname string 
---@param value number 
---@param cyclevar string
---@param cycletype string
---@param acttime string
---@return boolean   true——成功|false——失败
---@nodiscard
function lib996:setcystr(type,actor,varname,value,cyclevar,cycletype,acttime) end;

---英雄创建触发
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function createherook(actor) end;

---关闭屏幕特效
---* actor  userdata  玩家对象
---* id  number  特效编号
---* itype  number  0:自己 1:所有人
---@param actor  userdata 
---@param id  number 
---@param itype  number 
---@nodiscard
function lib996:deleffects(actor,id,itype) end;

---杀镖车触发
---* actor  userdata  击杀者
---* monobj  userdata  镖车对象
---@param actor  userdata 
---@param monobj  userdata 
---@nodiscard
function cardie(actor, monobj) end;

---添加buff
---* actor  userdata  对象
---* buffid  number buffid
---* time number  持续时间为空则为buff表中时间
---* lap number  叠加层数,默认1
---* player userdata  施放者
---* abil table  修改buff表att属性{[1]=200, [4]=20},属性id=值
---* act  boolean  是否立即生效,默认false(99%情况下不需要使用)
---@param actor  userdata 
---@param buffid  number
---@param time number 
---@param lap number 
---@param player userdata 
---@param abil table 
---@param act  boolean 
---@return boolean   true：成功 | false：不成功
---@nodiscard
function lib996:addbuff(actor,buffid,time,lap,player,abil,act) end;

---判断英雄是否为唤出状态
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return boolean   true：为唤出状态 | false：为收回状态
---@nodiscard
function lib996:isherorecall(actor) end;

---判断系统是否有定时器
---* id  number   定时器id
---@param id  number 
---@return boolean   true：有该定时器 | false：没有该定时器
---@nodiscard
function lib996:hastimerex(id) end;

---获取对象临时int型变量
---* Type  number  类型0:玩家,1:行会,2:地图,3：物品,4：NPC,5:怪物
---* actor  obj  类型=玩家-填对象类型=行会-填对象类型=物品-填makeid类型=地图-填地图ID类型=NPC-填NPCID类型=怪物-填对象
---* sVarName string  变量名
---@param Type  number 
---@param actor  obj 
---@param sVarName string 
---@return number  获得已设置的变量,如果未设置则返回0
---@nodiscard
function lib996:gettempint(Type,actor,sVarName) end;

---获取对象方向
---*  actor  	userdata  玩家 或 怪物对象
---@param  actor  	userdata 
---@return number  成功：对象方向|失败：-1
---@nodiscard
function lib996:getdir(actor) end;

---判断对象是否有定时器
---* actor  userdata   玩家对象
---* id  number   定时器id
---@param actor  userdata 
---@param id  number 
---@return boolean   true：有该定时器 | false：没有该定时器
---@nodiscard
function lib996:hastimer(actor,id) end;

---移除系统定时器
---* id  number   定时器id
---@param id  number 
---@nodiscard
function lib996:setofftimerex(id) end;

---设置对象临时int型变量
---* Type  number  类型0:玩家,1:行会,2:地图,3：物品,4：NPC,5:怪物
---* actor  obj  类型=玩家-填对象类型=行会-填对象类型=物品-填makeid类型=地图-填地图ID类型=NPC-填NPCID类型=怪物-填对象
---* sVarName string  变量名
---* nValue number  变量值
---@param Type  number 
---@param actor  obj 
---@param sVarName string 
---@param nValue number 
---@nodiscard
function lib996:settempint(Type,actor,sVarName,nValue) end;

---添加系统定时器
---* id  number   定时器id
---* tick  number   执行间隔,秒
---* count  number   执行次数,为0时不限次数
---@param id  number 
---@param tick  number 
---@param count  number 
---@nodiscard
function lib996:setontimerex(id,tick,count) end;

---移除对象定时器
---* actor  userdata   玩家对象
---* id  number   定时器id
---@param actor  userdata 
---@param id  number 
---@nodiscard
function lib996:setofftimer(actor,id) end;

---添加对象定时器
---* actor  userdata   玩家对象
---* id  number   定时器id
---* tick  number   执行间隔,秒
---* count  number   执行次数,为0时不限次数
---@param actor  userdata 
---@param id  number 
---@param tick  number 
---@param count  number 
---@nodiscard
function lib996:setontimer(actor,id,tick,count) end;

---获取对象最大HP
---* actor  userdata  对象
---@param actor  userdata 
---@return number  返回对象最大血量
---@nodiscard
function lib996:getmaxhp(actor) end;

---删除buff
---* actor  userdata  对象
---* buffid  number buffid
---* act  boolean  是否立即生效,默认false
---@param actor  userdata 
---@param buffid  number
---@param act  boolean 
---@nodiscard
function lib996:delbuff(actor,buffid) end;

---获取对象最大MP
---* actor  userdata  对象
---@param actor  userdata 
---@return number  返回对象最大蓝量
---@nodiscard
function lib996:getmaxmp(actor) end;

---是否有buff
---* actor  userdata  对象
---* buffid  number buffid
---@param actor  userdata 
---@param buffid  number
---@return boolean   true:有 | false:没有
---@nodiscard
function lib996:hasbuff(actor,buffid) end;

---获取玩家最大经验值
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return number  玩家最大经验
---@nodiscard
function lib996:getmaxexp(actor) end;

---获取str型期限变量
---* type  number  类型0:玩家,1:行会,2:地图,3：物品,4：NPC
---* actor  obj  对象
---* varname  string  变量名
---@param type  number 
---@param actor  obj 
---@param varname  string 
---@return 返回数量:2 | string  |返回期限变量值 过期时返回——nil|number  |返回期限变量剩余时间 过期时返回——0|
---@nodiscard
function lib996:gettlstr(type,actor,varname) end;

---获取buff信息
---* actor  userdata  对象
---* buffid  number buffid
---* itype number  1:叠加层数 2:剩余时间
---@param actor  userdata 
---@param buffid  number
---@param itype number 
---@return number  对应的信息
---@nodiscard
function lib996:getbuffinfo(actor,buffid,itype) end;

---获取邮件内物品时触发
---* actor  userdata  对象
---@param actor  userdata 
---@nodiscard
function getmailitem(actor) end;

---MD5加密
---@return string | MD5加密值
---@nodiscard
function lib996:md5str() end;

---自定义变量排序
---* varname  string  排序变量名
---* itype  number   0-所有玩家 1-在线玩家 2-行会
---* sort number  0-升序,1-降序
---* count number  获取的数据量 为空或0取所有,取前几名
---@param varname  string 
---@param itype  number 
---@param sort number 
---@param count number 
---@return table | {人物名称:变量值,人物名称:变量值,…}
---@nodiscard
function lib996:sorthumvar(varname,itype,sort,count) end;

---设置str型期限变量
---* type  number  类型0:玩家,1:行会,2:地图,3：物品,4：NPC
---* actor  obj  对象
---* varname  string  变量名
---* value  string 变量值
---* cdtime  number 期限时间(秒),0或nil不变,-1立即清除
---@param type  number 
---@param actor  obj 
---@param varname  string 
---@param value  string
---@param cdtime  number
---@return boolean   true——成功|false——失败|
---@nodiscard
function lib996:settlstr(type,actor,varname,value,cdtime) end;

---获取物品标记
---* makeid  number  物品唯一id
---* itype  userdata  标记类型(0~5)
---@param makeid  number 
---@param itype  userdata 
---@return number  返回物品标记值|
---@nodiscard
function lib996:getitemmar(makeid,itype) end;

---清理个人自定义变量
---* actor  userdata  要清理的人物对象,传入  nil 表示清理所有玩家
---* varname  string   变量名 `* `表示所有变量
---@param actor  userdata 
---@param varname  string 
---@nodiscard
function lib996:clearhumcustvar(actor,varname) end;

---脱套装触发
---* actor  userdata  对象
---* suitid  number   套装id
---@param actor  userdata 
---@param suitid  number 
---@nodiscard
function groupitemoffex(actor, suitid) end;

---设置物品标记
---* makeid  number  物品唯一id
---* itype  userdata  标记类型(0~5)
---* value  number 标记值
---@param makeid  number 
---@param itype  userdata 
---@param value  number
---@return boolean   true——成功|false——失败|
---@nodiscard
function lib996:setitemmar(makeid,itype,value) end;

---清理系统自定义变量
---* varname  string   变量名 `* `表示所有变量
---@param varname  string 
---@nodiscard
function lib996:clearglobalcustvar(varname) end;

---穿套装触发
---* actor  userdata  对象
---* suitid  number   套装id
---@param actor  userdata 
---@param suitid  number 
---@nodiscard
function groupitemonex(actor, suitid) end;

---清理自定义行会变量
---* actor  userdata   行会名称 nil 表示所有行会
---* varname  string   变量名 `* `表示所有变量
---@param actor  userdata 
---@param varname  string 
---@nodiscard
function lib996:clearguildcustvar(actor,varname) end;

---确认完成面对面交易前
---* actor  userdata  发起者
---* role  userdata  接受者
---* a_item  json  发起者交易确认交易物品makeid的table
---* r_item  json  接受者交易确认交易物品makeid的table
---* a_gold  number  发起者交易确认交易货币数量
---* r_gold  number  接受者交易确认交易货币数量
---@param actor  userdata 
---@param role  userdata 
---@param a_item  json 
---@param r_item  json 
---@param a_gold  number 
---@param r_gold  number 
---@return boolean  true——允许交易|false——阻止交易
---@nodiscard
function on_jiaoyi_trade_pre(actor,role,a_item,r_item,a_gold,r_gold) end;

---获取全局信息
---* itype  number  0: 系统对象1:部署开始 开服天数(不推荐)2:部署开始 开服时间(不推荐)3: 合服次数4: 合服时间5: 服务器IP(不推荐)6: 玩家数量7: 背包最大数量8: 引擎版本号9: 服务器部署时间10: 服务器测试时间11:服务器正式时间
---@param itype  number 
---@return 返回id所对应值,时间类为时间戳
---@nodiscard
function lib996:globalinfo(itype) end;

---发起面对面交易前
---* actor  userdata  发起者
---* role  userdata  接受者
---@param actor  userdata 
---@param role  userdata 
---@return boolean  true——允许发起|false——阻止发起
---@nodiscard
function on_jiaoyi_pre(actor, role) end;

---获取角色所有属性
---* actor  userdata  玩家对象,允许怪物对象
---@param actor  userdata 
---@return table | 所有属性值
---@nodiscard
function lib996:attrtab(actor) end;

---获取插入属性
---* actor  userdata  对象
---* attrid  number   属性id
---@param actor  userdata 
---@param attrid  number 
---@return number  插入的属性值
---@nodiscard
function lib996:getaddattr(actor, attrid) end;

---修改物品显示
---* actor  userdata  玩家对象
---* itemmakeid  number    物品唯一id
---* json json   显示json
---@param actor  userdata 
---@param itemmakeid  number 
---@param json json 
---@nodiscard
function lib996:setitemlooksbyjson(actor,itemmakeid,json) end;

---聊天触发
---* self  userdata  玩家对象
---* msg  string   内容
---* chat number   1;系统2;喊话3;私聊4;行会5;组队6;附近7;世界
---@param self  userdata 
---@param msg  string 
---@param chat number 
---@return boolean   是否允许说话
---@nodiscard
function triggerchat(self,msg,chat) end;

---设置插入属性
---* actor  userdata  对象
---* attrid  number   属性id
---* char  string   操作符 + - =
---* value number   对应属性值
---@param actor  userdata 
---@param attrid  number 
---@param char  string 
---@param value number 
---@nodiscard
function lib996:setaddattr(actor, attrid, char, value) end;

---获取玩家账号
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return string |成功——玩家账号|失败——nil
---@nodiscard
function lib996:getaccount(actor) end;

---检测怪物的类型
---* mon  userdata  	怪物对象
---@param mon  userdata 
---@return number  1：小怪 2：BOSS 3：宝宝(包括宠物) 4：英雄 5：人形怪
---@nodiscard
function lib996:montype(mon) end;

---清理地图中怪物
---* mapid   string  	地图id
---* monid   number  	怪物id -1时清理所有怪物
---@param mapid   string 
---@param monid   number 
---@return boolean  true——成功|false——失败
---@nodiscard
function lib996:removemon(mapid,monid) end;

---刷新人物属性
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function lib996:recalcabilitys(actor) end;

---受伤前触发
---* attack  userdata  攻击者对象(number)
---* role  userdata  受害者对象(string)
---* ack  number  攻击者本次打出的攻击力
---* def  number  受害者本次受击的防御力
---* skillid  number  技能id
---* hurttype  number  伤害类型0：物理伤害,1：魔法伤害
---@param attack  userdata 
---@param role  userdata 
---@param ack  number 
---@param def  number 
---@param skillid  number 
---@param hurttype  number 
---@return number  返回负数为扣血,正数为加血
---@nodiscard
function on_hurt_pre(attack,role,ack,def,skillid,hurttype) end;

---脱装备时
---* actor  userdata  对象
---* itemid  number   物品id
---* pos number   位置
---* itemname string   物品名称
---* itemmakeid  number   makeid(唯一ID)
---@param actor  userdata 
---@param itemid  number 
---@param pos number 
---@param itemname string 
---@param itemmakeid  number 
---@nodiscard
function on_take_off(actor,itemid,pos,itemname,itemmakeid) end;

---穿装备时
---* actor  userdata  对象
---* itemid  number   物品id
---* pos number   位置
---* itemname string   物品名称
---* itemmakeid  number   makeid(唯一ID)
---@param actor  userdata 
---@param itemid  number 
---@param pos number 
---@param itemname string 
---@param itemmakeid  number 
---@nodiscard
function on_take_on(actor,itemid,pos,itemname,itemmakeid) end;

---设置对象临时str型变量
---* Type  number  类型0:玩家,1:行会,2:地图,3：物品,4：NPC,5:怪物
---* actor  obj  类型=玩家-填对象类型=行会-填对象类型=物品-填makeid类型=地图-填地图ID类型=NPC-填NPCID类型=怪物-填对象
---* sVarName string  变量名
---* nValue string  变量值(最大8000字符)
---@param Type  number 
---@param actor  obj 
---@param sVarName string 
---@param nValue string 
---@nodiscard
function lib996:settempstr(Type,actor,sVarName,nValue) end;

---物品进入背包时
---* actor  userdata  玩家对象
---* itemid  number   物品id
---* itemmakeid  number    makeid(唯一ID)
---@param actor  userdata 
---@param itemid  number 
---@param itemmakeid  number 
---@nodiscard
function addbag(actor,itemid,itemmakeid) end;

---获取对象临时str型变量
---* Type  number  类型0:玩家,1:行会,2:地图,3：物品,4：NPC,5:怪物
---* actor  obj  类型=玩家-填对象类型=行会-填对象类型=物品-填makeid类型=地图-填地图ID类型=NPC-填NPCID类型=怪物-填对象
---* sVarName string  变量名
---@param Type  number 
---@param actor  obj 
---@param sVarName string 
---@return string | 获得已设置的变量,如果未设置则返回nil 或 ""
---@nodiscard
function lib996:gettempstr(Type,actor,sVarName) end;

---充值触发
---* actor  userdata  玩家对象
---* gold  number   充值rmb金额
---* productid number   商品ID(前端调起充值时候传递的参数)
---* moneyid number   充值获得货币ID
---@param actor  userdata 
---@param gold  number 
---@param productid number 
---@param moneyid number 
---@nodiscard
function recharge(actor, gold, productid, moneyid) end;

---设置系统临时int型变量
---* sVarName string  变量名
---* nValue number  变量值
---* itype number  合区类型 默认00:保留主区1:保留副区(多副区以最后一个为准)2:取大(字符型不可用)3:取小(字符型不可用)4:相加(字符型不可用)5:相连(整数型不可用)6:删除
---@param sVarName string 
---@param nValue number 
---@param itype number 
---@nodiscard
function lib996:setsystempint(sVarName,nValue) end;

---NPC点击触发
---* actor  userdata  玩家对象
---* npcid  number   npcid
---@param actor  userdata 
---@param npcid  number 
---@nodiscard
function clicknpc(actor, npcid) end;

---获取系统临时int型变量
---* sVarName string  变量名
---@param sVarName string 
---@return number  获得已设置的变量,如果未设置则返回0
---@nodiscard
function lib996:getsystempint(sVarName) end;

---玩家跳转地图触发
---* actor  userdata  玩家对象
---* mapid  string  进入地图id
---* x  number  进入地图x
---* y  number  进入地图y
---@param actor  userdata 
---@param mapid  string 
---@param x  number 
---@param y  number 
---@nodiscard
function entermap(actor,mapid,x,y) end;

---设置系统临时str型变量
---* sVarName string  变量名
---* nValue string  变量值
---* itype number  合区类型 默认00:保留主区1:保留副区(多副区以最后一个为准)2:取大(字符型不可用)3:取小(字符型不可用)4:相加(字符型不可用)5:相连(整数型不可用)6:删除
---@param sVarName string 
---@param nValue string 
---@param itype number 
---@nodiscard
function lib996:setsystempstr(sVarName,nValue) end;

---捡取触发
---* actor  userdata  玩家对象
---* makeid  number  物品唯一id
---* itemname  number  物品名称
---* itemid  number  物品id
---@param actor  userdata 
---@param makeid  number 
---@param itemname  number 
---@param itemid  number 
---@nodiscard
function pickupitemex(actor, makeid,itemid,itemmakeid) end;

---获取系统临时str型变量
---* sVarName string  变量名
---@param sVarName string 
---@return string | 获得已设置的变量,如果未设置则返回nil
---@nodiscard
function lib996:getsystempstr(sVarName) end;

---奔跑触发
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function run(actor) end;

---走路触发
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function walk(actor) end;

---判断是否组队状态
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return boolean   true——有队伍|false——没有队伍
---@nodiscard
function lib996:hasgroup(actor) end;

---过滤全服提示信息
---* actor  userdata  对象
---* flag  userdata  是否过滤0-不过滤1-过滤
---@param actor  userdata 
---@param flag  userdata 
---@nodiscard
function lib996:filterglobalmsg(actor, flag) end;

---获取队伍成员数量
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return number  成员数量|若没有队伍返回0
---@nodiscard
function lib996:getgroupnum(actor) end;

---设置物品绑定规则
---* makeid  number  物品makeindex
---* bind  number  绑定规则
---@param makeid  number 
---@param bind  number 
---@return booleanean |true——设置成功|false——设置失败
---@nodiscard
function lib996:setitembind(makeid,bind)  end;

---判断是否为自动挂机状态
---* actor  userdata  对象
---@param actor  userdata 
---@return boolean true 挂机 |false 不挂机
---@nodiscard
function lib996:isafk(actor) end;

---获取地图宽高
---* mapid  string   地图id
---@param mapid  string 
---@return 两个 number  height = height, width = width
---@nodiscard
function lib996:mapwh(mapid) end;

---收回小精灵
---* player   userdata  	玩家对象
---@param player   userdata 
---@nodiscard
function lib996:releasesprite(player) end;

---人物大退与关闭客户端触发
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function playoffline(actor) end;

---属性变化时触发
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function sendability(actor) end;

---将角色踢出游戏
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return boolean  true——成功|false——失败
---@nodiscard
function lib996:getout(actor) end;

---攻城开始时触发
---@nodiscard
function castlewarstart() end;

---攻城结束时触发
---@nodiscard
function castlewarend() end;

---占领沙巴克触发
---@nodiscard
function getcastle0() end;

---引擎启动时
---@nodiscard
function startup() end;

---登录时触发
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function login(actor) end;

---行会初始化
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function loadguild(actor) end;

---每天第一次登录
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function setday(actor) end;

---吸怪(范围)
---*  table  	table  目标table
---*  x  	number  x
---*  y  	number  y
---*  range  	number  暂定 range=0-3, 放置消耗过大
---@param  table  	table 
---@param  x  	number 
---@param  y  	number 
---@param  range  	number 
---@return boolean   成功——true|失败——false
---@nodiscard
function lib996:suckmulobj(table, X, Y, range) end;

---吸怪
---*  actor  	userdata  支持玩家、怪物等
---*  x  	number  x
---*  y  	number  y
---@param  actor  	userdata 
---@param  x  	number 
---@param  y  	number 
---@return boolean   成功——true|失败——false
---@nodiscard
function lib996:suckobj(obj, x, y) end;

---删除称号时触发
---* actor  userdata  玩家对象
---* id  number  称号id
---@param actor  userdata 
---@param id  number 
---@nodiscard
function on_del_title(actor,id) end;

---添加称号时触发
---* actor  userdata  玩家对象
---* id  number  称号id
---@param actor  userdata 
---@param id  number 
---@nodiscard
function on_add_title(actor,id) end;

---添加玩家称号
---* actor  userdata  玩家对象
---* id  number  称号id
---@param actor  userdata 
---@param id  number 
---@return boolean  true——成功|false——失败
---@nodiscard
function lib996:addtitle(actor,id) end;

---摆摊售出物品时触发
---* actor  userdata  摊主
---* buyer  userdata 买主
---* makeinde number  售出物品唯一id
---* ItemId number  售出物品id
---* moneyid number  货币id
---* moneynum number  货币数量
---@param actor  userdata 
---@param buyer  userdata
---@param makeinde number 
---@param ItemId number 
---@param moneyid number 
---@param moneynum number 
---@nodiscard
function on_stall_item(actor,buyer,makeinde,ItemId,moneyid,moneynum) end;

---获取攻城时间
---@return string |成功——返回临时占领的行会名称|失败——0
---@nodiscard
function lib996:castlestart() end;

---判断攻城战是否开启
---@return boolean  true——开始|false——未开始
---@nodiscard
function lib996:iscastlewar() end;

---获取沙巴克的拥有者行会
---@return string |成功——返回拥有者行会名称|失败——nil
---@nodiscard
function lib996:getcastleownguild() end;

---设置沙巴克的拥有者行会
---* guiid  string   行会id为"-1":string 时清除
---@param guiid  string 
---@nodiscard
function lib996:setcastleownguild(guiid) end;

---玩家死亡之前
---* actor  userdata  玩家对象
---* killer  userdata  凶手对象
---@param actor  userdata 
---@param killer  userdata 
---@nodiscard
function nextdie(actor) end;

---添加计划任务
---* id  number  任务计划id,不可重复
---* name  string  任务计划名称
---* itype  number  0:指定时间1:每天执行2:每周执行3:每月执行
---* stringtime  string  时间表 详细见示例 多时间#拼接
---* stringfun  string  回调函数
---* param  string  自定义参数,多参数#拼接
---@param id  number 
---@param name  string 
---@param itype  number 
---@param stringtime  string 
---@param stringfun  string 
---@param param  string 
---@return boolean   true：添加成功 | false：添加失败
---@nodiscard
function lib996:addscheduled(id,name,itype,strtime,strfun,param) end;

---判断计划任务是否存在
---* id  number  任务计划id,不可重复
---@param id  number 
---@return boolean   true：存在 | false：不存在
---@nodiscard
function lib996:hasscheduled(id) end;

---通过物品唯一id销毁物品
---* actor  userdata  玩家对象
---* ids  number   	物品唯一ID(makeindex)逗号(,)串联
---* count number   	叠加物品扣除数量,不填此参数,默认全部扣除,不可叠加物品全部扣除
---@param actor  userdata 
---@param ids  number 
---@param count number 
---@nodiscard
function lib996:delitembymakeindex(actor,ids,count) end;

---删除计划任务
---* id  number  任务计划id,不可重复
---@param id  number 
---@nodiscard
function lib996:delscheduled(id) end;

---使用物品(吃药、使用特殊物品等)
---* actor  userdata  玩家对象
---* itemname  string   物品名称
---* count number   数量
---@param actor  userdata 
---@param itemname  string 
---@param count number 
---@nodiscard
function lib996:eatitem(actor,itemname,count) end;

---玩家死亡时
---* actor  userdata  玩家对象
---* player  userdata  凶手对象
---@param actor  userdata 
---@param player  userdata 
---@nodiscard
function playdie(actor) end;

---敏感词汇检测
---* string   string  要检测的文本
---* result1   boolean  true：有敏感词
---* result2   string  敏感词
---@param string   string 
---@param result1   boolean 
---@param result2   string 
---@return boolean
---@nodiscard
function lib996:exisitssensitiveword(str, result1, result2) end;

---人物复活时
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function revival(actor) end;

---获取释放技能所需要的MP
---* actor  userdata  玩家对象
---* magicid  number  magicid技能ID
---@param actor  userdata 
---@param magicid  number 
---@return number--所需mp | 玩家不存在或传入对象不是玩家类(包括英雄、人型怪),返回nil|玩家对象未学习此技能,返回nil
---@nodiscard
function lib996:getskillmp(actor, magicid) end;

---人物小退触发
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function playreconnection(actor) end;

---怪物名字改颜色
---* mon  userdata  怪物对象
---* ColorID  number  颜色id
---@param mon  userdata 
---@param ColorID  number 
---@nodiscard
function lib996:changemonnamecolor(mon, ColorID) end;

---玩家改名后
---* actor  userdata  玩家对象
---* oname  string  旧名字
---* nname  string  新名字
---@param actor  userdata 
---@param oname  string 
---@param nname  string 
---@nodiscard
function changehumnameok(actor) end;

---根据怪物名称杀死怪物
---* mapid  string  	地图id
---* monname  string  怪物全名,nil时 杀死全部
---* count number  	数量,0所有
---* drop boolean  	是否掉落物品,true掉落
---@param mapid  string 
---@param monname  string 
---@param count number 
---@param drop boolean 
---@nodiscard
function lib996:killmonsters(mapid,monname,count,drop) end;

---宝宝叛变触发
---* actor  userdata  玩家对象
---* mon  userdata  宝宝对象
---* monname  string 宝宝名称
---@param actor  userdata 
---@param mon  userdata 
---@param monname  string
---@nodiscard
function mobtreachery(actor, mon, monname) end;

---根据怪物对象杀死怪物
---* actor  userdata  击杀者对象
---* mon  userdata  怪物对象
---* drop boolean  是否掉落物品,true掉落
---* trigger boolean  是否触发killmon
---* showdie boolean  是否显示死亡动画
---@param actor  userdata 
---@param mon  userdata 
---@param drop boolean 
---@param trigger boolean 
---@param showdie boolean 
---@nodiscard
function lib996:killmonbyobj(actor,mon,drop,trigger,showdie) end;

---离开地图时
---* actor  userdata  玩家对象
---* mapid  string  离开的地图id
---* x  number  离开地图x
---* y  number  离开地图y
---@param actor  userdata 
---@param mapid  string 
---@param x  number 
---@param y  number 
---@nodiscard
function leavemap(actor,mapid,x,y) end;

---杀怪物品再爆
---* actor  userdata  玩家对象
---* count  number  怪物物品掉落增加次数
---@param actor  userdata 
---@param count  number 
---@nodiscard
function lib996:monitems(actor,count) end;

---把怪物设置成宝宝
---* mon  userdata  怪物对象
---* player  userdata  玩家对象
---* itime  number  叛变时间 默认永久,单位秒 M2中可以配置叛变死亡
---@param mon  userdata 
---@param player  userdata 
---@param itime  number 
---@nodiscard
function lib996:setmonmaster(mon,player,itime) end;

---删除自定义怪物攻击表现
---* custommon  userdata  自定义怪物对象
---* attackId  number  攻击表现id(看cfg_monattack表)
---@param custommon  userdata 
---@param attackId  number 
---@return booleanea | 成功——true|失败——false
---@nodiscard
function lib996:delmonattack(custommon, attackId) end;

---添加自定义怪物攻击表现
---* custommon  userdata  自定义怪物对象
---* attackId  number  攻击表现id(看cfg_monattack表)
---@param custommon  userdata 
---@param attackId  number 
---@return booleanea | 成功——true|失败——false
---@nodiscard
function lib996:addmonattack(custommon, attackId) end;

---判断自定义怪物是否有该攻击表现
---* custommon  userdata  自定义怪物对象
---* attackId  number  攻击表现id(看cfg_monattack表)
---@param custommon  userdata 
---@param attackId  number 
---@return booleanea | 成功——true|失败——false
---@nodiscard
function lib996:monhasattack(custommon, attackId) end;

---判断对象是否可被攻击
---*  actor  	userdata  攻击者
---*  role  	userdata  被攻击者
---@param  actor  	userdata 
---@param  role  	userdata 
---@return boolean   true：能 | false：不
---@nodiscard
function lib996:canattack(actor,role)  end;

---脱装备前
---* actor  userdata  对象
---* itemid  number   物品id
---* pos number   位置
---* itemname string   物品名称
---* itemmakeid  number   makeid(唯一ID)
---@param actor  userdata 
---@param itemid  number 
---@param pos number 
---@param itemname string 
---@param itemmakeid  number 
---@return boolean  true——允许脱下|false—不许
---@nodiscard
function on_take_off_pre(actor,itemid,pos,itemname,itemmakeid) end;

---玩家死亡被爆物品前触发
---* actor  userdata  玩家对象
---* makeid  number  物品唯一id
---* itemid  number  物品id
---@param actor  userdata 
---@param makeid  number 
---@param itemid  number 
---@return boolean   true：允许丢弃 false：不允许丢弃
---@nodiscard
function itemdropfrombagbefore(actor,makeid,itemid) end;

---玩家扔物品前触发
---* actor  userdata  玩家对象
---* makeid  number  物品唯一id
---* itemid  number  物品id
---@param actor  userdata 
---@param makeid  number 
---@param itemid  number 
---@return boolean   true：允许丢弃 false：不允许丢弃
---@nodiscard
function itemthrowfrombagbefore(actor,makeid,itemid) end;

---任务变化时
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function changetask(actor) end;

---任务删除时
---* actor  userdata  玩家对象
---* id  number  任务id
---@param actor  userdata 
---@param id  number 
---@nodiscard
function deletetask(actor, id) end;

---遍历宠物列表
---* actor  userdata  玩家对象
---* nIndex  number  索引(0开始)
---@param actor  userdata 
---@param nIndex  number 
---@return userdata | 怪物对象
---@nodiscard
function lib996:getslavebyindex(actor,nIndex) end;

---修改宝宝名称
---* mob  userdata  宝宝对象(怪物对象可用)
---* name  userdata  宝宝新名字
---@param mob  userdata 
---@param name  userdata 
---@nodiscard
function lib996:changemonname(mob,name) end;

---捡取前触发
---* actor  userdata  玩家对象
---* makeid  number  物品唯一id
---* itemid  number  物品id
---* itemx  number  物品x坐标
---* itemy  number  物品y坐标
---@param actor  userdata 
---@param makeid  number 
---@param itemid  number 
---@param itemx  number 
---@param itemy  number 
---@return boolean   true：允许拾取 false：不允许拾取
---@nodiscard
function pickupitemfrontex(actor, makeid,itemid,x,y) end;

---获取物品当前耐久度
---* actor  userdata  玩家对象
---* makeindex  number   物品唯一id
---@param actor  userdata 
---@param makeindex  number 
---@return number  返回装备剩余耐久度
---@nodiscard
function lib996:getdura(actor,makeindex) end;

---设置玩家当前展示称号
---* actor  userdata  玩家对象
---* id  number  称号id
---@param actor  userdata 
---@param id  number 
---@return boolean  true——成功|false——失败
---@nodiscard
function lib996:setcurtitle(actor,id) end;

---修改物品当前耐久度
---* actor  userdata  玩家对象
---* makeindex  number   物品唯一id
---* ope  string   运算符 "+" "-"  "="
---* value  number   修改的耐久值
---@param actor  userdata 
---@param makeindex  number 
---@param ope  string 
---@param value  number 
---@nodiscard
function lib996:setdura(actor,makeindex,ope,value) end;

---修改宝宝等级
---* play  userdata  	玩家对象
---* mon  userdata  	宝宝对象
---* operate string  操作符号(+,-,=)
---* nLevel number  	等级
---@param play  userdata 
---@param mon  userdata 
---@param operate string 
---@param nLevel number 
---@nodiscard
function lib996:changeslavelevel(play,mon,operate,nLevel) end;

---删除玩家称号
---* actor  userdata  玩家对象
---* id  number  称号id
---@param actor  userdata 
---@param id  number 
---@return boolean  true——成功|false——失败
---@nodiscard
function lib996:deltitle(actor,id) end;

---根据makeId返回怪物对象
---* mapid  string  	地图id
---* monUserId  string  	怪物makeId(唯一id)
---@param mapid  string 
---@param monUserId  string 
---@return userdata | 返回怪物对象
---@nodiscard
function lib996:getmonbyuserid(mapid,monUserId) end;

---返回所有行会对象
---@return table | 返回所有行会对象
---@nodiscard
function lib996:getallguild() end;

---根据怪物id返回怪物基础信息
---* idx  userdata  怪物的IDX
---* id  string  id
---@param idx  userdata 
---@param id  string 
---@nodiscard
function lib996:getmonbaseinfo(idx,id) end;

---指定对象加入指定行会
---* actor  userdata  指定的玩家对象
---* guiname  number  要加入的行会名称
---@param actor  userdata 
---@param guiname  number 
---@return boolean   true：成功 | false：失败
---@nodiscard
function lib996:addguildmember(actor,guiname) end;

---检测范围内怪物数量
---* mapid  string  	地图id
---* monName  string  怪物名称,nil 检测所有怪
---* nx number  	坐标X
---* ny number  坐标Y
---* nRange number  范围
---@param mapid  string 
---@param monName  string 
---@param nx number 
---@param ny number 
---@param nRange number 
---@return number  ,数量
---@nodiscard
function lib996:checkrangemoncount(mapid,monName,nx,ny,nRange) end;

---踢出指定的行会成员
---* actor  userdata  要踢出玩家对象
---* guiname  number  行会名称
---@param actor  userdata 
---@param guiname  number 
---@return boolean   true：成功 | false：失败
---@nodiscard
function lib996:delguildmember(actor,guiname) end;

---召唤拾取小精灵
---* player  userdata  玩家对象
---* monname  string  精灵名称
---@param player  userdata 
---@param monname  string 
---@nodiscard
function lib996:createsprite(player,monname) end;

---设置镜像地图剩余时间
---* MapId  string  镜像地图ID
---* time  number  剩余时间
---@param MapId  string 
---@param time  number 
---@nodiscard
function lib996:setmaptime(MapId,time) end;

---utf-8转gbk
---* string   string  utf-8
---@param string   string 
---@return string | 返回 转码后字符
---@nodiscard
function lib996:utf8togbk(str) end;

---检测拾取小精灵
---* player  userdata  玩家对象
---* monname  string  精灵名称,为nil 则检测全部
---@param player  userdata 
---@param monname  string 
---@nodiscard
function lib996:checkspritelevel(player,monname) end;

---gbk转utf-8
---* string   string  gbk
---@param string   string 
---@return string | 返回 转码后字符
---@nodiscard
function lib996:gbktoutf8(str) end;

---获取玩家ip
---* actor  userdata  对象
---@param actor  userdata 
---@return 成功:string | 失败nil
---@nodiscard
function lib996:getip(actor) end;

---假人开始自动战斗时
---* actor  userdata  假人对象
---@param actor  userdata 
---@nodiscard
function on_dum_in_fight(actor) end;

---假人结束自动战斗时
---* actor  userdata  假人对象
---@param actor  userdata 
---@nodiscard
function on_dum_out_fight(actor) end;

---召唤宝宝时触发
---* actor  userdata  召唤者对象
---* owner  userdata  主人对象
---* mon  userdata  宠物对象
---@param actor  userdata 
---@param owner  userdata 
---@param mon  userdata 
---@nodiscard
function slavebb(actor, owner, mon) end;

---神兽变身时触发
---* actor  userdata  主人对象
---* actor  userdata  宝宝对象
---* actor  string  变身前名称
---* actor  string  变身后名称
---@param actor  userdata 
---@param actor  userdata 
---@param actor  string 
---@param actor  string 
---@nodiscard
function on_mythmon_transform(actor,mon,aname,bname) end;

---组队前触发
---* actor  userdata  玩家对象与队长是同一人
---@param actor  userdata 
---@return boolean  true——允许|false—不许
---@nodiscard
function startgroup(actor) end;

---查看人物装备时
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function lookhuminfo(actor) end;

---英雄死亡时
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function herodie(actor) end;

---英雄复活时
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function herorevival(actor) end;

---注册虚拟机index
---* idx  number  虚拟机编号QF:999999999,QM:999999996
---* scriptfile  string  文件路径
---@param idx  number 
---@param scriptfile  string 
---@nodiscard
function lib996:setsysindex(idx,scriptfile) end;

---获取镜像地图剩余时间
---* MapId  string  镜像地图ID
---@param MapId  string 
---@return number  剩余时间
---@nodiscard
function lib996:getmaptime(MapId) end;

---判断对象是否为玩家
---* actor  userdata  对象
---@param actor  userdata 
---@return boolean   true：是玩家 | false：不是玩家
---@nodiscard
function lib996:isplayer(actor) end;

---判断对象是否死亡
---* actor  userdata  对象
---@param actor  userdata 
---@return boolean   true：死亡 | false：存活
---@nodiscard
function lib996:isdeath(actor) end;

---拾取模式
---* player  userdata  玩家对象
---* mode  number  模式(0=以人物为中心捡取,1=以小精灵为中心捡取)
---* Range  number  范围(1-10)
---* numbererval  number  间隔,最小500ms
---@param player  userdata 
---@param mode  number 
---@param Range  number 
---@param numbererval  number 
---@nodiscard
function lib996:pickupitems(player,mode,Range,interval) end;

---获取对象名称
---* actor  userdata  对象
---@param actor  userdata 
---@return string | 返回对象名称
---@nodiscard
function lib996:getname(actor) end;

---关闭拾取模式
---* player  userdata  玩家对象
---@param player  userdata 
---@nodiscard
function lib996:stoppickupitems(player) end;

---获取玩家唯一id
---* actor  userdata  玩家对象,怪物对象
---@param actor  userdata 
---@return string | 返回玩家对象唯一id
---@nodiscard
function lib996:getuserid(actor) end;

---给道具增加自定义属性
---* actor  userdata  玩家对象
---* makeid  number   道具makeindex(唯一id)
---* type number   属性组
---* attid number   属性id
---* attvar number   属性值
---@param actor  userdata 
---@param makeid  number 
---@param type number 
---@param attid number 
---@param attvar number 
---@nodiscard
function lib996:additemattr(actor,makeid,type,attid,attvar) end;

---在指定位置优先打指定打怪
---* player  userdata  玩家对象
---* map  string  	地图
---* X  string  X坐标
---* Y  string  	Y坐标
---* MonName  string  优先攻击的怪物名称MonName支持多个怪物名称,怪物名称用 # 拼接
---@param player  userdata 
---@param map  string 
---@param X  string 
---@param Y  string 
---@param MonName  string 
---@nodiscard
function lib996:killmobappoint(player,map,X,Y,MonName) end;

---获取对象所在的地图id
---* actor  userdata  对象
---@param actor  userdata 
---@return string | 返回地图id
---@nodiscard
function lib996:getmapid(actor) end;

---删除道具自定义属性
---* actor  userdata  玩家对象
---* makeid  number   道具makeindex(唯一id)
---* type number   属性组
---* attid number   属性id(为0时清除该组所有属性)
---@param actor  userdata 
---@param makeid  number 
---@param type number 
---@param attid number 
---@return boolean   true：成功 | false：失败
---@nodiscard
function lib996:delitemattr(actor,makeid,type,attid) end;

---设置标记值
---* obj  userdata  人物、怪物对象
---* index  string  下标ID(0-9)
---* value  string  标记值
---@param obj  userdata 
---@param index  string 
---@param value  string 
---@nodiscard
function lib996:setcurrent(
    obj,
    index,
	value
) end;

---修改人物名称
---* actor  userdata  玩家对象
---* name  string   要修改的名字
---@param actor  userdata 
---@param name  string 
---@return number  0-可以使用 1、2、6-名称被过滤 3-名字已经存在 5-长度不符合要求
---@nodiscard
function lib996:changehumname(actor,name) end;

---获取角色属性
---* actor  userdata  玩家对象,允许怪物对象
---* attid  number   属性id
---@param actor  userdata 
---@param attid  number 
---@return number  属性值
---@nodiscard
function lib996:attr(actor,attid) end;

---获取玩家当前等级
---* actor  userdata  玩家对象,或怪物对象
---@param actor  userdata 
---@return number  玩家当前等级
---@nodiscard
function lib996:getlevel(actor) end;

---获取人物临时属性
---* actor  userdata  玩家对象
---* nWhere  number  位置 对应cfg_att_score 属性ID
---@param actor  userdata 
---@param nWhere  number 
---@return number  对应属性值
---@nodiscard
function lib996:gethumnewvalue(actor,nWhere) end;

---获取玩家性别
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return number  玩家性别
---@nodiscard
function lib996:getsex(actor) end;

---临时增加怪物爆出物品
---* obj  userdata  人物、怪物对象
---* mon  userdata  怪物对象
---* itemname  string  物品名称
---@param obj  userdata 
---@param mon  userdata 
---@param itemname  string 
---@nodiscard
function lib996:additemtodroplist(obj,mon,itemname) end;

---获取对象int型变量
---* Type  number  类型0:玩家,1:行会,2:地图,3：物品,4：NPC,5:怪物
---* actor  obj  类型=玩家-填对象类型=行会-填对象类型=物品-填makeid类型=地图-填地图ID类型=NPC-填NPCID类型=怪物-填对象
---* sVarName string  变量名
---@param Type  number 
---@param actor  obj 
---@param sVarName string 
---@return number  获得已设置的变量,如果未设置则返回0
---@nodiscard
function lib996:getint(Type,actor,sVarName) end;

---获取对象xy坐标
---* actor  userdata  对象
---@param actor  userdata 
---@return number  1：x坐标 | 2：y坐标
---@nodiscard
function lib996:getxy(actor) end;

---创建行会
---* player  userdata  玩家对象
---* name  string  	行会名
---@param player  userdata 
---@param name  string 
---@nodiscard
function lib996:buildguild(player,name) end;

---设置对象int型变量
---* Type  number  类型0:玩家,1:行会,2:地图,3：物品,4：NPC,5:怪物
---* actor  obj  类型=玩家-填对象类型=行会-填对象类型=物品-填makeid类型=地图-填地图ID类型=NPC-填NPCID类型=怪物-填对象
---* sVarName string  变量名
---* nValue number  变量值
---@param Type  number 
---@param actor  obj 
---@param sVarName string 
---@param nValue number 
---@nodiscard
function lib996:setint(Type,actor,sVarName,nValue) end;

---修改人物临时属性(带有效期)
---* actor  userdata  玩家对象
---* nWhere  number  位置 对应cfg_att_score 属性ID
---* nValue number  对应属性值
---* nTime  number  有效时间,秒
---@param actor  userdata 
---@param nWhere  number 
---@param nValue number 
---@param nTime  number 
---@nodiscard
function lib996:changehumnewvalue(actor,nWhere,nValue,nTime) end;

---获取玩家职业
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return number  玩家职业
---@nodiscard
function lib996:getjob(actor) end;

---加入行会
---* player  userdata  玩家对象
---* name  string  	行会名
---@param player  userdata 
---@param name  string 
---@nodiscard
function lib996:guildaddmember(player,name) end;

---获取对象str型变量
---* Type  number  类型0:玩家,1:行会,2:地图,3：物品,4：NPC,5:怪物
---* actor  obj  类型=玩家-填对象类型=行会-填对象类型=物品-填makeid类型=地图-填地图ID类型=NPC-填NPCID类型=怪物-填对象
---* sVarName string  变量名
---@param Type  number 
---@param actor  obj 
---@param sVarName string 
---@return string | 获得已设置的变量,如果未设置则返回nil 或 ""
---@nodiscard
function lib996:getstr(Type,actor,sVarName) end;

---删除魔法盾
---* actor userdata   玩家对象
---@param actor userdata 
---@return boolean   成功——true|失败——返回false
---@nodiscard
function lib996:delams(actor) end;

---退出行会
---* player  userdata  玩家对象
---* name  string  	行会名
---@param player  userdata 
---@param name  string 
---@nodiscard
function lib996:guilddelmember(player,name) end;

---设置对象str型变量
---* Type  number  类型0:玩家,1:行会,2:地图,3：物品,4：NPC,5:怪物
---* actor  obj  类型=玩家-填对象类型=行会-填对象类型=物品-填makeid类型=地图-填地图ID类型=NPC-填NPCID类型=怪物-填对象
---* sVarName string  变量名
---* nValue string  变量值(最大8000字符)
---@param Type  number 
---@param actor  obj 
---@param sVarName string 
---@param nValue string 
---@nodiscard
function lib996:setstr(Type,actor,sVarName,nValue) end;

---是否拥有魔法盾
---* actor userdata   玩家对象
---@param actor userdata 
---@return boolean   true——有|false——没有
---@nodiscard
function lib996:hasams(actor) end;

---设置人物经验值
---@nodiscard
function lib996:changeexp(actor,char,count,addexp) end;

---解散行会
---* player  userdata  玩家对象
---@param player  userdata 
---@nodiscard
function lib996:guildclosebefore(player) end;

---调整人物等级
---* actor  userdata  玩家对象
---* char  string   操作符 + - =
---* count string   数量
---@param actor  userdata 
---@param char  string 
---@param count string 
---@nodiscard
function lib996:changelevel(actor,char,count) end;

---强制开启/关闭攻城
---* data  number  	1-立刻攻城,0-立刻结束攻城
---@param data  number 
---@nodiscard
function lib996:castlewarnow(data) end;

---进入地图跳转点跳转前
---* actor  userdata  玩家对象
---* map  string  mapid
---* x  number  位置x
---* y  number  位置y
---* jumpMap  string  要跳转的地图id
---@param actor  userdata 
---@param map  string 
---@param x  number 
---@param y  number 
---@param jumpMap  string 
---@nodiscard
function on_route_pre(actor, map, x, y, jumpMap) end;

---设置buff堆叠层数
---* actor  userdata 对象
---* buff  number buffid
---* opt  string 操作符 "+" "-" "="
---* stack  number buff层数 不可超出表中最大层数
---* itimer  boolean 是否重置buff 时间
---@param actor  userdata
---@param buff  number
---@param opt  string
---@param stack  number
---@param itimer  boolean
---@return boolean  true——成功|false——失败
---@nodiscard
function lib996:buffstack(actor,buff,opt,stack,itimer) end;

---创建行会前触发
---* actor  userdata  玩家对象
---* name  string  行会名
---@param actor  userdata 
---@param name  string 
---@return boolean  true——允许创建|false——阻止创建
---@nodiscard
function on_build_guild_pre(actor,name) end;

---创建行会时触发
---* actor  userdata  玩家对象
---* name  string  行会对象
---@param actor  userdata 
---@param name  string 
---@nodiscard
function buildguild(actor,name) end;

---开始假人摆摊
---* actor  userdata  假人对象
---* stallname  string  摊位名称
---* pricetab  json  摊位商品列表  参考示例
---@param actor  userdata 
---@param stallname  string 
---@param pricetab  json 
---@return boolean   true——成功|false——失败
---@nodiscard
function lib996:dumstartstall(actor,stallname,pricetab) end;

---退出行会前触发
---* actor  userdata  玩家对象
---* name  string  行会名
---@param actor  userdata 
---@param name  string 
---@return boolean  true——允许退出|false——阻止退出
---@nodiscard
function on_out_guild_pre(actor,name) end;

---获取对象当前HP
---* actor  userdata  对象
---@param actor  userdata 
---@return number  返回当前对象血量
---@nodiscard
function lib996:gethp(actor) end;

---获取对象当前MP
---* actor  userdata  对象
---@param actor  userdata 
---@return number  返回当前对象蓝量
---@nodiscard
function lib996:getmp(actor) end;

---获取系统int型变量
---* sVarName string  变量名
---@param sVarName string 
---@return number  获得已设置的变量,如果未设置则返回0
---@nodiscard
function lib996:getsysint(sVarName) end;

---获取玩家当前经验值
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return number  玩家当前经验
---@nodiscard
function lib996:getexp(actor) end;

---获取人物所在行会成员数量
---* player  userdata  玩家对象
---@param player  userdata 
---@return number  | 人物所在行会成员数量
---@nodiscard
function lib996:getguildmembercount(player) end;

---设置系统int型变量
---* sVarName string  变量名
---* nValue number  变量值
---* itype number  合区类型 默认00:保留主区1:保留副区(多副区以最后一个为准)2:取大(字符型不可用)3:取小(字符型不可用)4:相加(字符型不可用)5:相连(整数型不可用)6:删除
---@param sVarName string 
---@param nValue number 
---@param itype number 
---@nodiscard
function lib996:setsysint(sVarName,nValue) end;

---顶戴花翎
---* actor  userdata  玩家对象
---* where  number   位置 0-9
---* effType number   	播放效果(0图片名称 1特效ID)
---* resName string  	图片名或者特效ID
---* x number   X坐标 (为空时默认X=0)
---* y number   Y坐标 (为空时默认Y=0)
---* autoDrop number  自动补全空白位置0,1(0=掉 1=不掉)
---* selfSee number   是否只有自己看见(0=所有人都可见 1=仅仅自己可见)
---@param actor  userdata 
---@param where  number 
---@param effType number 
---@param resName string 
---@param x number 
---@param y number 
---@param autoDrop number 
---@param selfSee number 
---@nodiscard
function lib996:seticon(actor,where,effType,resName,x,y,autoDrop,selfSee) end;

---获取玩家转生等级
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return number  玩家转生等级
---@nodiscard
function lib996:getrelevel(actor) end;

---获取系统str型变量
---* sVarName string  变量名
---@param sVarName string 
---@return string | 获得已设置的变量,如果未设置则返回nil
---@nodiscard
function lib996:getsysstr(sVarName) end;

---在人物身上播放特效
---* actor  userdata  玩家对象或怪物对象
---* effectid  number   特效ID
---* offsetX number  相对于人物偏移的X坐标
---* offsetY number  相对于人物偏移的Y坐标
---* times number  播放次数--0-一直播放
---* behind number  播放模式-0-前面-1-后面
---* selfshow number  可见类型0:否,视野内均可见1:是,仅自己可见
---* dir number  0：不跟随人物方向改变1：跟随人物方向改变
---@param actor  userdata 
---@param effectid  number 
---@param offsetX number 
---@param offsetY number 
---@param times number 
---@param behind number 
---@param selfshow number 
---@param dir number 
---@nodiscard
function lib996:playeffect(actor,effectid,offsetX,offsetY,times,behind,selfshow,dir) end;

---获取玩家背包最大格子数
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return number  玩家背包最大格子数
---@nodiscard
function lib996:getbagsize(actor) end;

---把行会添加到攻城列表
---* name  string  行会名
---* day  number  	天数
---@param name  string 
---@param day  number 
---@nodiscard
function lib996:addtocastlewarlistex(name,day) end;

---设置系统str型变量
---* sVarName string  变量名
---* nValue string  变量值
---* itype number  合区类型 默认00:保留主区1:保留副区(多副区以最后一个为准)2:取大(字符型不可用)3:取小(字符型不可用)4:相加(字符型不可用)5:相连(整数型不可用)6:删除
---@param sVarName string 
---@param nValue string 
---@param itype number 
---@nodiscard
function lib996:setsysstr(sVarName,nValue) end;

---表格转换成字符串
---* tab  table  要转换的表格
---* isfilter  boolean  是否过滤违禁词 默认为true
---@param tab  table 
---@param isfilter  boolean 
---@return string | 返还字符串
---@nodiscard
function lib996:tbl2json(tab,isfilter) end;

---清除人物身上播放的特效
---* actor  userdata  玩家对象或怪物对象
---* effectid  number   特效ID
---@param actor  userdata 
---@param effectid  number 
---@nodiscard
function lib996:clearplayeffect(actor,effectid) end;

---判断玩家对象是否为行会会长
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return boolean   true：是会长 | false：不是会长
---@nodiscard
function lib996:isguildmaster(actor) end;

---所有行会在当晚同时攻城
---@nodiscard
function lib996:addattacksabakall() end;

---字符串转换成表格
---* string  string  要转换的字符串
---* isfilter  boolean  是否过滤违禁词 默认为true
---@param string  string 
---@param isfilter  boolean 
---@return table | 返还table
---@nodiscard
function lib996:json2tbl(str,isfilter) end;

---调用其他lua虚拟机函数
---* actor  userdata  玩家对象
---* idx  number  npcidQF:999999999,QM:999999996
---* time  INT  延迟时间ms,0立即执行
---* stringfun  string  函数名
---* param  string  参数
---@param actor  userdata 
---@param idx  number 
---@param time  INT 
---@param stringfun  string 
---@param param  string 
---@nodiscard
function lib996:callfunbynpc(actor,idx,time,strfun,param) end;

---修改人物当前血量
---* actor  userdata  对象
---* char  string   操作符 + - =
---* nvalue string   血量
---* effid boolean   素材ID,-1时不飘字
---* host userdata  伤害来源对象
---@param actor  userdata 
---@param char  string 
---@param nvalue string 
---@param effid boolean 
---@param host userdata 
---@nodiscard
function lib996:humanhp(
    actor,
    char,
    nvalue,
	effid
) end;

---获取玩家所在的行会对象
---* player  userdata  玩家对象
---@param player  userdata 
---@return userdata | 返回行会对象
---@nodiscard
function lib996:getmyguild(player) end;

---获取当前时间
---@return table | 当前时间的 年.月.日 时.分.秒.周
---@nodiscard
function lib996:gettime() end;

---修改人物当前蓝量
---* actor  userdata  对象
---* char  string   操作符 + - =
---* nvalue string   蓝量
---@param actor  userdata 
---@param char  string 
---@param nvalue string 
---@nodiscard
function lib996:humanmp(actor,char,nvalue) end;

---搜索行会
---* index  number  0:行会ID1:行会名称
---* key  string  搜索关键词
---@param index  number 
---@param key  string 
---@return userdata | 行会对象
---@nodiscard
function lib996:findguild(index,key) end;

---获取行会信息
---* guild  number  行会对象
---* index  number  	索引
---@param guild  number 
---@param index  number 
---@return string | 对应索引结构
---@nodiscard
function lib996:getguildinfo(guild,index) end;

---创建队伍
---* actor  userdata  玩家对象与队长是同一人
---@param actor  userdata 
---@nodiscard
function groupcreate(actor) end;

---修改人物名字颜色
---* actor  userdata  玩家对象
---* color  number  996m2 颜色列表
---@param actor  userdata 
---@param color  number 
---@nodiscard
function lib996:changenamecolor(actor,color) end;

---查询人物货币
---* actor  userdata  玩家对象
---* id  number   货币ID(1-100)
---@param actor  userdata 
---@param id  number 
---@return number  对应的货币数量
---@nodiscard
function lib996:querymoney(actor,id) end;

---设置行会信息
---* guild  userdata  行会对象
---* index  number  索引
---* value  string  要设置的内容
---@param guild  userdata 
---@param index  number 
---@param value  string 
---@nodiscard
function lib996:setguildinfo(guild,index,value) end;

---离开队伍
---* actor  userdata  玩家对象
---* groupOwner  userdata  队长玩家对象
---@param actor  userdata 
---@param groupOwner  userdata 
---@nodiscard
function leavegroup(actor,groupOwner) end;

---获取人物通用货币数量(多货币计算)
---* actor  userdata  玩家对象
---* moneyname  string  货币名称
---@param actor  userdata 
---@param moneyname  string
---@return number  对应的货币值
---@nodiscard
function lib996:getbindmoney(actor,moneyname) end;

---设置人物货币
---* actor  userdata  玩家对象
---* id  number   货币ID(1-100)
---* opt  string   操作符 + - =
---* count  number   数量
---* msg  string   备注内容
---* send  boolean   是否立即刷新
---@param actor  userdata 
---@param id  number 
---@param opt  string 
---@param count  number 
---@param msg  string 
---@param send  boolean 
---@return boolean   ture：成功,false：失败
---@nodiscard
function lib996:changemoney(actor,id,opt,count,msg,send) end;

---创建队伍
---* player  userdata  玩家对象
---@param player  userdata 
---@nodiscard
function lib996:creategroup(player) end;

---踢出队伍
---* actor  userdata  玩家对象
---* delPlayer  userdata  踢出对象
---@param actor  userdata 
---@param delPlayer  userdata 
---@nodiscard
function groupdelmember(actor) end;

---强制保存游戏数据
---@nodiscard
function lib996:forcesaveplayerdata() end;

---扣除人物通用货币数量(多货币依次计算)
---* actor  userdata  玩家对象
---* moneyname  string  货币名称
---* count number   对应货币值
---@param actor  userdata 
---@param moneyname  string
---@param count number 
---@nodiscard
function lib996:consumebindmoney(
    actor,
    moneyname,
    count
) end;

---添加队员
---* player  userdata  玩家对象
---* memberId  string  	组员UserId(唯一id)
---@param player  userdata 
---@param memberId  string 
---@nodiscard
function lib996:addgroupmember(player,memberId) end;

---申请加入队伍成功时
---* actor  userdata  玩家对象
---* addPlayer  userdata  加入对象
---@param actor  userdata 
---@param addPlayer  userdata 
---@nodiscard
function groupaddmember(actor) end;

---设置人物背包格子数
---* actor  userdata  玩家对象
---* count number  格子大小(不小于46,不大于126)
---@param actor  userdata 
---@param count number
---@nodiscard
function lib996:setbagcount(
    actor,
    count
) end;

---是否红名
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return boolean   true——红名|false——非红名
---@nodiscard
function lib996:ispkredname(actor) end;

---是否黄名
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return boolean   true——黄名|false——非黄名
---@nodiscard
function lib996:ispkyellowname(actor) end;

---判断对象是否是假人
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return boolean   true——假人|false——非假人
---@nodiscard
function lib996:isdum(actor) end;

---发送对象聊天框消息
---* actor  userdata  假人对象
---* itype  number   聊天频道 1:喊话2:私聊3:附近4:世界
---* msg  string  聊天内容
---* palyname  userdata  玩家名 仅私聊有效
---@param actor  userdata 
---@param itype  number 
---@param msg  string 
---@param palyname  userdata 
---@return boolean   true——成功|false——失败
---@nodiscard
function lib996:dumtalk(actor,itype,msg,palyname) end;

---获取服务器所有假人数量
---@return number  假人数量
---@nodiscard
function lib996:dumcount() end;

---设置角色离线挂机
---* actor  userdata  玩家对象
---* time  number  离线时间(分)
---@param actor  userdata 
---@param time  number 
---@nodiscard
function lib996:offlineplay(actor,time) end;

---获取玩家自动寻路终点坐标
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return number  1：x坐标 | 2：y坐标
---@nodiscard
function lib996:gettargetxy(actor) end;

---获取道具自定义属性组
---* actor  userdata  玩家对象
---* makeid  number   道具makeindex(唯一id)
---@param actor  userdata 
---@param makeid  number 
---@return table | 返回所有自定义属性组
---@nodiscard
function lib996:getitemattrtag(actor, makeid) end;

---根据道具自定义属性组获取该组属性
---* actor  userdata  玩家对象
---* makeid  number   道具makeindex(唯一id)
---* nTag  number   属性组
---@param actor  userdata 
---@param makeid  number 
---@param nTag  number 
---@return string | 根据道具自定义属性组获取该组属性 | nTag=-1时,返回所有自定义属性
---@nodiscard
function lib996:getitemattr(actor, makeid, nTag) end;

---删除队员
---* player  userdata  玩家对象
---* memberId  string  组员UserId(唯一性id)
---@param player  userdata 
---@param memberId  string 
---@nodiscard
function lib996:delgroupmember(player,memberId) end;

---获取系统对象
---@return userdata | 返回系统对象
---@nodiscard
function lib996:getsys() end;

---遍历背包勾选物品
---* actor  userdata  玩家对象
---* makeindex  string   选中的物品唯一ID多个物品用“,”分隔
---@param actor  userdata 
---@param makeindex  string 
---@nodiscard
function lib996:selectbagitems(
    actor,
    makeindex
) end;

---获取队员列表
---* player  userdata  玩家对象
---@param player  userdata 
---@return table | 队员对象列表
---@nodiscard
function lib996:getgroupmember(player) end;

---打印日志
---* string  string  要打印的信息
---* show  number  0：m2不同步显示,1：m2同步显示
---@param string  string 
---@param show  number 
---@nodiscard
function lib996:scriptlog(str,show) end;

---穿戴装备
---* actor  userdata  玩家对象
---* where  number   位置
---* makeindex number   物品唯一ID
---@param actor  userdata 
---@param where  number 
---@param makeindex number 
---@nodiscard
function lib996:takeonitem(
    actor,
    where,
    makeindex
) end;

---添加镜像地图
---* oldMap  string  原地图ID
---* NewMap  string  新地图ID(此id可作为临时对象使用)
---* NewName  string  新地图名
---* time  number  有效时间(秒)
---* BackMap  string  	回城地图(有效时间结束后,传回去的地图)
---@param oldMap  string 
---@param NewMap  string 
---@param NewName  string 
---@param time  number 
---@param BackMap  string 
---@return boolean  true——成功|false——失败
---@nodiscard
function lib996:addmirrormap(oldMap,NewMap,NewName,time,BackMap) end;

---脱下装备
---* actor  userdata  玩家对象
---* where  number   位置
---* makeindex number   物品唯一ID
---@param actor  userdata 
---@param where  number 
---@param makeindex number 
---@nodiscard
function lib996:takeoffitem(
    actor,
    where,
    makeindex
) end;

---修改武器、衣服特效
---* actor  userdata  玩家对象
---* where  number   位置 0,1
---* EffId number   特效ID
---* selfSee number   是否只有自己看见(1=所有人都可见 0=仅仅自己可见)
---@param actor  userdata 
---@param where  number 
---@param EffId number 
---@param selfSee number 
---@nodiscard
function lib996:changedresseffect(actor,where,EffId,selfSee) end;

---删除镜像地图
---* MapId  string  地图ID
---@param MapId  string 
---@nodiscard
function lib996:delmirrormap(MapId) end;

---开/关首饰盒
---* actor  userdata  玩家对象
---* bState  number   0：关闭,1：开启
---@param actor  userdata 
---@param bState  number 
---@nodiscard
function lib996:setsndaitembox(actor,bState) end;

---停止自动挂机
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function lib996:stopautoattack(actor) end;

---获取/设置镜像地图剩余时间
---@nodiscard
function lib996:mirrormaptime(MapId,time) end;

---添加buff时
---* actor  userdata  对象
---* buffid  number  buffid
---* time  number  buff剩余时间
---* host  userdata  释放者
---@param actor  userdata 
---@param buffid  number 
---@param time  number 
---@param host  userdata 
---@nodiscard
function addbuffafter(actor,buffid,time,host) end;

---修改武器、衣服外观
---* actor  userdata  玩家对象
---* item  userdata   物品对象
---* looks number   外观值
---@param actor  userdata 
---@param item  userdata 
---@param looks number 
---@nodiscard
function lib996:changeitemshape(actor,item,looks) end;

---设置物品特效
---* actor  userdata  玩家对象
---* makeindex  number   物品唯一id
---* bEffect  number   背包特效
---* bWhere  number   背包特效在后(0-在前,1-在后)
---* sEffect  number   装备特效
---* sWhere  number   装备特效灾后(0-在前,1-在后)
---@param actor  userdata 
---@param makeindex  number 
---@param bEffect  number 
---@param bWhere  number 
---@param sEffect  number 
---@param sWhere  number 
---@nodiscard
function lib996:setitemeffect(actor, makeindex, bEffect, bWhere, sEffect, sWhere) end;

---检测镜像地图是否存在
---* MapId  string  地图ID
---@param MapId  string 
---@return boolean   true：存在 | false：不存在
---@nodiscard
function lib996:checkmirrormap(MapId) end;

---删除buff时
---* actor  userdata  对象
---* buffid  number  buffid
---* time  number  buff剩余时间
---* host  userdata  释放者
---@param actor  userdata 
---@param buffid  number 
---@param time  number 
---@param host  userdata 
---@nodiscard
function delbuffafter(actor,buffid,time,host) end;

---根据物品唯一ID获得物品对象
---* actor  userdata  玩家对象
---* makeindex  number   	物品唯一ID
---@param actor  userdata 
---@param makeindex  number 
---@return userdata | 返回对应的物品对象,如果检索不到,返回nil
---@nodiscard
function lib996:getitembymakeindex(actor,makeindex) end;

---在指定地图xy坐标刷新怪物
---* mapid  string  	地图id
---* x  number  	x坐标x,y都为0时为全图随机
---* y  number  	y坐标x,y都为0时为全图随机
---* monname  string  	怪物名称
---* range  number  范围
---* count  number  数量
---* color  number  颜色
---@param mapid  string 
---@param x  number 
---@param y  number 
---@param monname  string 
---@param range  number 
---@param count  number 
---@param color  number 
---@return table | 怪物对象列表
---@nodiscard
function lib996:genmon(mapid,x,y,monname,range,count,color) end;

---添加地图特效
---* Id  number  	特效播放ID,用于区分多个地图特效
---* MapId  string  地图ID
---* X  number  坐标X
---* Y  number  坐标Y
---* effId  number  特效ID
---* time  number  持续时间(秒)
---* mode  number  0:所有人可见1:自己可见2:组队可见3:行会成员可见4:敌对可见
---@param Id  number 
---@param MapId  string 
---@param X  number 
---@param Y  number 
---@param effId  number 
---@param time  number 
---@param mode  number 
---@nodiscard
function lib996:mapeffect(Id,MapId,X,Y,effId,time,mode) end;

---设置无敌模式
---* actor  userdata   玩家对象
---* number  number   1：无敌,0：不无敌
---@param actor  userdata 
---@param number  number 
---@nodiscard
function lib996:superman(actor,int) end;

---获取背包剩余空格数
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return string | 背包剩余格子数
---@nodiscard
function lib996:getbagblank(actor) end;

---删除地图特效
---*  Id  	number  	特效播放ID
---@param  Id  	number 
---@nodiscard
function lib996:delmapeffect(Id) end;

---获取地图上指定范围内的对象
---* MapId  string  	地图ID
---* x  number  x坐标
---* y  number  y坐标
---* range  number  范围
---* flag  number  标记值,二进制位表示：1:玩家,2:怪物4:NPC,8:物品16:地图事件32:人形怪64:英雄128:分身
---@param MapId  string 
---@param x  number 
---@param y  number 
---@param range  number 
---@param flag  number 
---@return table | 对象表
---@nodiscard
function lib996:getobjectinmap(MapId,x,y,range,flag) end;

---是否拥有道士默认毒
---* actor userdata   玩家对象
---* type number   0:红毒,1:绿毒
---@param actor userdata 
---@param type number 
---@return boolean   true——有|false——没有
---@nodiscard
function lib996:hasgas(actor,type) end;

---获取背包所有物品
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return table | 物品对象列表
---@nodiscard
function lib996:getbagitems(actor) end;

---在地图上放置物品
---@return table | 成功时返回物品makeid,失败返回空
---@nodiscard
function lib996:throwitem(actor,MapId,X,Y,range,name,count,time,hint,take,self,order) end;

---获取怪物位置及复活时间
---* MapId  string  	地图ID
---@param MapId  string 
---@return table | 怪物状态表 | {"mon":[{"name":"火龙神","x":476,"y":484,"time":0},{"name":"火龙神","x":359,"y":409,"time":0}],"count":2}
---@nodiscard
function lib996:getmonrefresh(MapId) end;

---删除道士默认毒
---* actor userdata   玩家对象
---* type number   0:红毒,1:绿毒
---@param actor userdata 
---@param type number 
---@return boolean   成功——true|失败——返回false
---@nodiscard
function lib996:delgas(actor,type) end;

---结束假人摆摊
---* actor  userdata  假人对象
---@param actor  userdata 
---@return boolean   true——成功|false——失败
---@nodiscard
function lib996:dumstopstall(actor) end;

---是否灰名
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return boolean   true——灰名|false——非灰名
---@nodiscard
function lib996:ispkgreyname(actor) end;

---清理地图上指定名字的物品
---* MapId  string  	地图ID
---* X  number  	坐标X
---* Y  number  	坐标Y
---* range  number  	范围
---* itemName  string  		物品名 传入nil则清理所有
---@param MapId  string 
---@param X  number 
---@param Y  number 
---@param range  number 
---@param itemName  string 
---@nodiscard
function lib996:clearitemmap(MapId,X,Y,range,itemName) end;

---获取仓库所有物品
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return table | 物品对象列表
---@nodiscard
function lib996:getstorageitems(actor) end;

---根据名称获取物品id
---* itemname  string  物品名称
---@param itemname  string 
---@return number 成功——物品id|失败——-1
---@nodiscard
function lib996:getitemid(itemname) end;

---假人开启自动战斗
---* actor  userdata  假人对象
---@param actor  userdata 
---@return boolean   true——成功|false——失败
---@nodiscard
function lib996:dumstart(actor) end;

---假人停止自动战斗
---* actor  userdata  假人对象
---@param actor  userdata 
---@return boolean   true——成功|false——失败
---@nodiscard
function lib996:dumstop(actor) end;

---清理目标临时变量
---* Type  number  类型0:玩家,1:行会,2:地图,3：物品,4：NPC,5:怪物
---* actor  obj  类型=玩家-填对象类型=行会-填对象类型=物品-填makeid类型=地图-填地图ID类型=NPC-填NPCID类型=怪物-填对象
---@param Type  number 
---@param actor  obj 
---@nodiscard
function lib996:clrtempvar(Type,actor) end;

---踢出假人
---* actor  userdata  假人对象 若为nil时则全部踢出
---@param actor  userdata 
---@return boolean   true——成功|false——失败
---@nodiscard
function lib996:dumkick(actor) end;

---根据id获取物品价格(price)
---* id  number  物品id
---@param id  number 
---@return number 成功——物品价格|失败——-1
---@nodiscard
function lib996:getitemprice(id) end;

---设置物品来源
---* actor  userdata  玩家对象
---* item  userdata  物品对象
---* json  userdata  json
---@param actor  userdata 
---@param item  userdata 
---@param json  userdata 
---@nodiscard
function lib996:setthrowitemly2(actor,item, json) end;

---根据id获取物品最大叠加数量
---* id  number  物品id
---@param id  number 
---@return number 成功——物品最大叠加数量|失败——-1
---@nodiscard
function lib996:getitemoverlap(id) end;

---根据id获取物品最大耐久
---* id  number  物品id
---@param id  number 
---@return number 成功——物品最大耐久|失败——-1
---@nodiscard
function lib996:getitemduramax(id) end;

---根据id获取物品AniCount
---* id  number  物品id
---@param id  number 
---@return number 成功——物品AniCount|失败——-1
---@nodiscard
function lib996:getitemanicount(id) end;

---根据id获取物品重量
---* id  number  物品id
---@param id  number 
---@return number 成功——物品重量|失败——-1
---@nodiscard
function lib996:getitemweight(id) end;

---根据id获取物品Shape
---* id  number  物品id
---@param id  number 
---@return number 成功——物品Shape|失败——-1
---@nodiscard
function lib996:getitemshape(id) end;

---设置隐身模式
---* actor  userdata   玩家对象
---* number  number   1：隐身,0：不隐身
---@param actor  userdata 
---@param number  number 
---@nodiscard
function lib996:observer(actor,int) end;

---根据id获取物品StdMode
---* id  number  物品id
---@param id  number 
---@return number 成功——物品StdMode|失败——-1
---@nodiscard
function lib996:getitemstdmode(id) end;

---设置隐身术效果
---* actor  userdata  玩家对象
---* time  number   持续时间,秒,-1取消隐身术效果
---@param actor  userdata 
---@param time  number 
---@nodiscard
function lib996:sethide(actor,time) end;

---根据id获取物品名称
---* id  number  物品id
---@param id  number 
---@return string |成功——物品名称|失败——nil
---@nodiscard
function lib996:getnamebyidx(id) end;

---设置地图跳转点
---* name  string  	跳转点名称
---* amapid  string  	入口地图ID
---* jx  number  	入口x坐标
---* jy  number  	入口y坐标
---* range  number  	范围
---* bmapid  string  	出口地图ID
---* cx  number  	出口x坐标
---* cy  number  	出口y坐标
---* time  number  	存在时间
---@param name  string 
---@param amapid  string 
---@param jx  number 
---@param jy  number 
---@param range  number 
---@param bmapid  string 
---@param cx  number 
---@param cy  number 
---@param time  number 
---@nodiscard
function lib996:addmapgate(name,amapid,jx,jy,range,bmapid,cx,cy,time) end;

---获取玩家pk点
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return number  玩家pk点数
---@nodiscard
function lib996:getpkpoint(actor) end;

---获取地图跳转点
---* name  string      跳转点名称
---* amapid  string      入口地图ID
---@param name  string 
---@param amapid  string 
---@return table | {jx,jy,bmapid,cx,cy}
---@nodiscard
function lib996:getmapgate(name,amapid) end;

---设定地图计时器
---* MapId  string  地图ID
---* Idx  number  	计时器ID
---* second  number  	时长(秒)
---* func  string  	触发跳转的函数
---@param MapId  string 
---@param Idx  number 
---@param second  number 
---@param func  string 
---@nodiscard
function lib996:setenvirontimer(MapId,Idx,second,func) end;

---设置玩家pk点
---* actor  userdata  玩家对象
---* opt  string  操作符 + - =
---* n  number  数量
---@param actor  userdata 
---@param opt  string 
---@param n  number 
---@nodiscard
function lib996:setpkpoint(actor,opt, n) end;

---删除地图跳转点
---* name  string  	跳转点名称
---* amapid  string  	入口地图ID
---@param name  string 
---@param amapid  string 
---@nodiscard
function lib996:delmapgate(name,amapid) end;

---关闭地图计时器
---* MapId  string  	地图ID
---* Idx  string  计时器ID
---@param MapId  string 
---@param Idx  string 
---@nodiscard
function lib996:setenvirofftimer(MapId,Idx) end;

---整理背包里的物品
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function lib996:refreshbag(actor) end;

---判断逻辑格是否为安全区
---*  mapid  	string  地图ID
---*  x  	number  	x坐标
---*  y  	number  	y坐标
---@param  mapid  	string 
---@param  x  	number 
---@param  y  	number 
---@return boolean   true：为安全区 | false：不为安全区
---@nodiscard
function lib996:isinsafe(mapid, x, y) end;

---获取玩家沙巴克身份
---* actor  obj   玩家对象
---@param actor  obj 
---@return number  0:非沙巴克成员 | 1:沙巴克成员 | 2:沙巴克老大
---@nodiscard
function lib996:castleidentity(actor) end;

---给人物装备面板加特效
---* actor  userdata  玩家对象
---* effectid  number   	特效ID, 0-删除特效
---* position number   显示位置：0-前面 1-后面
---@param actor  userdata 
---@param effectid  number 
---@param position number 
---@nodiscard
function lib996:updateequipeffect(actor,effectid,position) end;

---判断逻辑格是否为攻城区
---*  mapid  	string  地图ID
---*  x  	number  	x坐标
---*  y  	number  	y坐标
---@param  mapid  	string 
---@param  x  	number 
---@param  y  	number 
---@return boolean   true：为攻城区 | false：不为攻城区
---@nodiscard
function lib996:isincastle(mapid, x, y) end;

---获取沙巴克基本信息
---* id  number   索引id
---@param id  number 
---@return number/string/boolean/table | 索引id与 | 1  :  沙城名称[string] | 2  :  沙城行会名称[string] | 3  :  沙城行会会长名字[string] | 4  :  占领天数[number] | 5  :  当前是否在攻沙状态[Bool] | 6  :  沙城行会副会长名字列表[table]
---@nodiscard
function lib996:castleinfo(id) end;

---根据地图id返回地图名
---*  mapid  	string  地图ID
---@param  mapid  	string 
---@return string | 地图名称
---@nodiscard
function lib996:getmapname(mapid) end;

---获取技能信息
---* actor  userdata  玩家对象
---* skillid  number 技能ID
---* id number  	属性ID,1:等级,2:强化等级,3:熟练度
---@param actor  userdata 
---@param skillid  number
---@param id number 
---@return number  (对应属性值) ,没有技能,返回nil
---@nodiscard
function lib996:getskillinfo(actor,skillid,id) end;

---创建临时NPC
---* mapid  userdata   对象
---* x  number   x坐标
---* y  number   y坐标
---* npc  string  json
---@param mapid  userdata 
---@param x  number 
---@param y  number 
---@param npc  string
---@nodiscard
function lib996:createnpc(mapid,x,y,npc) end;

---设置玩家等级
---* actor  userdata  玩家对象
---* opt  string  操作符 + - =
---* n  number  数量
---* istringigg boolean 是否触发升级回调,默认false
---@param actor  userdata 
---@param opt  string 
---@param n  number 
---@param istringigg boolean
---@nodiscard
function lib996:setlevel(actor,opt,n,istrigg) end;

---添加技能
---* actor  userdata  玩家对象
---* skillid  number   技能ID
---* level number  	等级
---@param actor  userdata 
---@param skillid  number 
---@param level number 
---@nodiscard
function lib996:addskill(actor,skillid,level) end;

---删除临时NPC
---* npcid  number   npcid
---* mapid  string   地图id
---@param npcid  number 
---@param mapid  string 
---@nodiscard
function lib996:delnpc(npc,mapid) end;

---设置玩家性别
---* actor  userdata  玩家对象
---* n  number  性别 0：男,1：女
---@param actor  userdata 
---@param n  number 
---@nodiscard
function lib996:setsex(acto,n) end;

---删除技能
---* actor  userdata  玩家对象
---* cskillid  string   技能ID
---@param actor  userdata 
---@param cskillid  string 
---@nodiscard
function lib996:delskill(actor,skillidr) end;

---根据ID获取NPC对象
---* npcid  number   npcid
---@param npcid  number 
---@return userdata | npc对象
---@nodiscard
function lib996:getnpcbyindex(npcid) end;

---设置玩家职业
---* actor  userdata  玩家对象
---* n  number  0：战士,1：法师,2：道士
---@param actor  userdata 
---@param n  number 
---@nodiscard
function lib996:setjob(actor,n) end;

---清空所有技能
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function lib996:clearskill(actor) end;

---跳转到指定NPC附近
---* actor  userdata   玩家对象
---* npcid  number   npcid
---* rangea  number   范围：不在此范围内则移动到npc附近
---* rangeb  number   范围：移动到NPC附近的范围内
---@param actor  userdata 
---@param npcid  number 
---@param rangea  number 
---@param rangeb  number 
---@nodiscard
function lib996:opennpcshowex(actor,npc,rangea,rangeb) end;

---删除非本职业技能
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function lib996:delnojobskill(actor) end;

---设置NPC特效
---* actor  userdata   玩家对象
---* npcid  number   npcid
---* Effect  number   特效ID5055-感叹号 5056-问号
---* x  number   x坐标
---* y  number   y坐标
---@param actor  userdata 
---@param npcid  number 
---@param Effect  number 
---@param x  number 
---@param y  number 
---@nodiscard
function lib996:setnpceffect(actor,npcid,Effect,x,y) end;

---获取地图中假人数量
---* mapid  string  地图id
---@param mapid  string 
---@return number  假人数量
---@nodiscard
function lib996:dumcountinmap(mapid) end;

---设置技能等级
---* actor  userdata  玩家对象
---* skillid  number   技能ID
---* flag number   	类型：1-技能等级2-强化等级3-熟练度
---* ponumber number   等级或点数
---@param actor  userdata 
---@param skillid  number 
---@param flag number 
---@param ponumber number 
---@nodiscard
function lib996:setskillinfo(actor,skillid,flag,point) end;

---商场购买触发
---@nodiscard
function buyshopitem(actor,money,moneynum,itemid,itemname,num) end;

---用脚本命令释放技能
---* actor  userdata  玩家对象
---* skillid  number  技能ID
---* type number  	类型：1-普通技能2-强化技能
---* level number  技能等级
---* target number  	技能对象：1-攻击目标,2-自身,3-目标对象(即将开放),4-当前地图坐标(即将开放)
---* flag number   是否显示施法动作：0-不显示,1-显示
---@param actor  userdata 
---@param skillid  number 
---@param type number 
---@param level number 
---@param target number 
---@param flag number 
---@nodiscard
function lib996:releasemagic(actor,skillid,type,level,target,flag) end;

---设置等级锁
---* actor  userdata  玩家对象
---* itype  number  0:解除锁定1锁定到达最大等级时并且不获取怪物经验2:锁定到达最大等级时累积经验(number64)
---* level  number  锁住最大等级
---@param actor  userdata 
---@param itype  number 
---@param level  number 
---@nodiscard
function lib996:setlocklevel(actor,itype,level) end;

---背包掉落前触发
---* actor  userdata  玩家对象
---* itemmakeid  number 物品唯一id
---* itemid  number  物品id
---* itemname  number  物品名称
---@param actor  userdata 
---@param itemmakeid  number
---@param itemid  number 
---@param itemname  number 
---@return boolean  true——允许|false—不许
---@nodiscard
function dropbagitemsbefore(actor,itemmakeid,itemid,itemname) end;

---装备掉落前触发
---* actor  userdata  玩家对象
---* itemmakeid  number 物品唯一id
---* itemid  number  物品id
---* itemname  number  物品名称
---@param actor  userdata 
---@param itemmakeid  number
---@param itemid  number 
---@param itemname  number 
---@return boolean  true——允许|false—不许
---@nodiscard
function dropuseitemsbefore(actor,itemmakeid,itemid,itemname) end;

---删除NPC特效
---* actor  userdata   玩家对象
---* npcid  number   npcid
---@param actor  userdata 
---@param npcid  number 
---@nodiscard
function lib996:delnpceffect(actor,npcid) end;

---获取NPC对象的Id
---* npc  userdata   npc对象
---@param npc  userdata 
---@return number  npcid 失败返回0
---@nodiscard
function lib996:getnpcindex(npc) end;

---加载文件
---* path  string  文件路径
---@param path  string 
---@return 根据加载文件 return 返回
---@nodiscard
function lib996:include(path) end;

---新建任务
---* actor  userdata  玩家对象
---* id  number  任务id
---* a  string  参数1用来替换任务内容里的%s
---* b  string  参数2用来替换任务内容里的%s
---* c  string  参数3用来替换任务内容里的%s
---* d  string  参数4用来替换任务内容里的%s
---* e  string  参数5用来替换任务内容里的%s
---* f  string  参数6用来替换任务内容里的%s
---* g  string  参数7用来替换任务内容里的%s
---* h  string  参数8用来替换任务内容里的%s
---* i  string  参数9用来替换任务内容里的%s
---* j  string  参数10用来替换任务内容里的%s
---@param actor  userdata 
---@param id  number 
---@param a  string 
---@param b  string 
---@param c  string 
---@param d  string 
---@param e  string 
---@param f  string 
---@param g  string 
---@param h  string 
---@param i  string 
---@param j  string 
---@nodiscard
function lib996:newpicktask(actor,id,a,b,c,d,e,f,g,h,i,j) end;

---根据玩家名获取玩家对象
---* name  string  玩家名字
---@param name  string 
---@return userdata | 玩家对象
---@nodiscard
function lib996:getplayerbyname(name) end;

---刷新进行中任务状态
---* actor  userdata  玩家对象
---* id  number  任务id
---* a  string  参数1用来替换任务内容里的%s
---* b  string  参数2用来替换任务内容里的%s
---* c  string  参数3用来替换任务内容里的%s
---* d  string  参数4用来替换任务内容里的%s
---* e  string  参数5用来替换任务内容里的%s
---* f  string  参数6用来替换任务内容里的%s
---* g  string  参数7用来替换任务内容里的%s
---* h  string  参数8用来替换任务内容里的%s
---* i  string  参数9用来替换任务内容里的%s
---* j  string  参数10用来替换任务内容里的%s
---@param actor  userdata 
---@param id  number 
---@param a  string 
---@param b  string 
---@param c  string 
---@param d  string 
---@param e  string 
---@param f  string 
---@param g  string 
---@param h  string 
---@param i  string 
---@param j  string 
---@nodiscard
function lib996:newchangetask(actor,id,a,b,c,d,e,f,g,h,i,j) end;

---根据玩家唯一ID获取玩家对象
---* id  string  	玩家唯一id
---@param id  string 
---@return userdata | 玩家对象
---@nodiscard
function lib996:getplayerbyid(id) end;

---完成任务
---* actor  userdata  玩家对象
---* id  number  任务id
---@param actor  userdata 
---@param id  number 
---@nodiscard
function lib996:newcompletetask(actor,id) end;

---删除任务
---* actor  userdata  玩家对象
---* id  number  任务id
---@param actor  userdata 
---@param id  number 
---@nodiscard
function lib996:newdeletetask(actor,id) end;

---任务置顶显示
---* actor  userdata  玩家对象
---* id  number  任务id
---@param actor  userdata 
---@param id  number 
---@nodiscard
function lib996:tasktopshow(actor,id) end;

---发送邮件
---* userid  string  玩家唯一id填入玩家名则 #七伤拳
---* type  number  自定义邮件类型
---* title  number  邮件标题
---* string  number  邮件内容
---* rewards  number  附件：物品1#数量#绑定标记&物品2#数量#绑定标记,&分组,#分隔
---@param userid  string 
---@param type  number 
---@param title  number 
---@param string  number 
---@param rewards  number 
---@nodiscard
function lib996:sendmail(userid,type,title,str,rewards) end;

---镖车自动寻路到指定坐标
---* actor  userdata  玩家对象
---* x  number  x坐标
---* y  number  y坐标
---* range  number  检测主人距离跟随距离范围:0-12 填0则不检测
---@param actor  userdata 
---@param x  number 
---@param y  number 
---@param range  number 
---@nodiscard
function lib996:dartmap(actor,x,y,range) end;

---修改攻击模式
---* actor  userdata  玩家对象
---* attackmode  number   攻击模式
---@param actor  userdata 
---@param attackmode  number 
---@nodiscard
function lib996:changeattackmode(actor,attackmode) end;

---拍卖行上架前
---* actor  userdata  玩家对象
---* itemid  number  物品id
---* makeid  number  物品唯一id
---* itemname  string  物品名称
---* itemnum number  物品数量
---* mtype number  货币类型
---* jhuob number  竞价金额
---* yhuob number  一口价金额
---@param actor  userdata 
---@param itemid  number 
---@param makeid  number 
---@param itemname  string 
---@param itemnum number 
---@param mtype number 
---@param jhuob number 
---@param yhuob number 
---@return boolean  true——允许上架|false—不许
---@nodiscard
function on_pre_paimai(actor,itemid,makeid,itemname,itemnum,mtype,jhuob,yhuob) end;

---假人开始摆摊时
---* actor  userdata  假人对象
---* itemtab  json  假人摆摊物品表
---@param actor  userdata 
---@param itemtab  json 
---@nodiscard
function on_stall_act(actor,itemtab) end;

---获取文件列表
---* file   string  文件名
---@param file   string 
---@return table
---@nodiscard
function lib996:getfilelist(file) end;

---强制修改攻击模式
---* actor  userdata  玩家对象
---* attackmode  number  攻击模式-1=提前结束强制状态
---* time number   强制切换时间(秒)
---@param actor  userdata 
---@param attackmode  number 
---@param time number 
---@nodiscard
function lib996:setattackmode(actor,attackmode,time) end;

---拍卖行购买物品触发
---* actor  userdata  玩家对象
---* money  number  货币id
---* moneynum  number  消耗货币量
---* itemid  number  购买的物品id
---* makeid  number  购买的物品唯一id
---* itemname  string  购买的物品名称
---* num  number  购买的物品数量
---@param actor  userdata 
---@param money  number 
---@param moneynum  number 
---@param itemid  number 
---@param makeid  number 
---@param itemname  string 
---@param num  number 
---@return boolean  true——允许购买|false—不许
---@nodiscard
function buypaimaiitem(actor,money,moneynum,itemid,makeid,itemname,num) end;

---开始挂机触发
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function startautoplaygame(actor) end;

---邀请组队前触发
---* actor  userdata  邀请者
---* invitee  userdata  被邀请者
---@param actor  userdata 
---@param invitee  userdata 
---@return boolean  true——允许|false—不许
---@nodiscard
function invitegroup(actor, invitee) end;

---让镖车跟随主人移动
---@nodiscard
function lib996:pulldart(actor, range) end;

---击退前触发
---* actor  userdata  施法者
---* target  userdata  受击者
---* skillid  number  技能id
---* SysCanPush  boolean  引擎判断流程是否可以击退
---@param actor  userdata 
---@param target  userdata 
---@param skillid  number 
---@param SysCanPush  boolean 
---@return boolean   可以击退——true|不可以击退——false
---@nodiscard
function on_push_pre(actor, target, skillid, SysCanPush) end;

---人物下线时镖车存活设置
---* actor  userdata  玩家对象
---* time  number  镖车存活时间,秒
---* aim  number  0-消失,1-时间到达消失
---@param actor  userdata 
---@param time  number 
---@param aim  number 
---@nodiscard
function lib996:darttime(actor,time,aim) end;

---商城是否满足指定条件显示
---* actor  userdata  玩家对象
---* show  number  1-不显示,0-显示
---@param actor  userdata 
---@param show  number 
---@nodiscard
function lib996:notallowshow(actor,show) end;

---日志上报
---* actor   obj  玩家对象
---* eventTag   string  事件描述
---* eventMSG   string  事件内容
---@param actor   obj 
---@param eventTag   string 
---@param eventMSG   string 
---@nodiscard
function lib996:postlog(actro,eventTag,eventMSG) end;

---商城是否满足指定条件购买
---* actor  userdata  玩家对象
---* buy  number  1-不允许购买,0-允许购买
---@param actor  userdata 
---@param buy  number 
---@nodiscard
function lib996:notallowbuy(actor,buy) end;

---获取当前攻击模式
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return number  0-全体攻击 | 1-和平攻击 | 2-夫妻攻击 | 3-师徒攻击 | 4-编组攻击 | 5-行会攻击 | 6-红名攻击 | 7-国家攻击
---@nodiscard
function lib996:getattackmode(actor) end;

---跳转到地图随机坐标
---* actor  userdata  玩家对象
---* mapid  string  地图id
---@param actor  userdata 
---@param mapid  string 
---@nodiscard
function lib996:map(actor,mapid) end;

---发送聊天框消息
---* actor  userdata  玩家对象
---* type  number   1:自己2:全服3:行会4:当前地图5:组队
---* msg  string   消息内容
---@param actor  userdata 
---@param type  number 
---@param msg  string 
---@nodiscard
function lib996:sendmsg(actor,tye,msg) end;

---输出消息到控制台
---* string  string  要输出的信息
---@param string  string 
---@nodiscard
function lib996:release_print(str) end;

---跳转到地图指定坐标
---* actor  userdata  玩家对象
---* mapid  string  地图id
---* nX  number  X坐标
---* nY  number  Y坐标
---* nRange  number  范围
---@param actor  userdata 
---@param mapid  string 
---@param nX  number 
---@param nY  number 
---@param nRange  number 
---@return boolean   成功返回true,否则false
---@nodiscard
function lib996:mapmove(actor,mapid,nX,nY,nRange) end;

---导航玩家到指定位置
---* actor  userdata  玩家对象
---* X  string   X坐标
---* Y string   Y坐标
---@param actor  userdata 
---@param X  string 
---@param Y string 
---@nodiscard
function lib996:gotonow(actor,X,Y) end;

---发送屏幕中间大字体信息
---* actor  userdata  玩家对象
---* FColor  number   前景色
---* BColor  number   背景色
---* msg  string   消息内容
---* flag  string  0:发送给自己1:发送所有人物2:发送行会3:发送国家4:发送当前地图5:替换模式7:组队
---* time  number   显示时间
---* func  string   倒计时结束后跳转的脚本位置,对应脚本需要放QFunction脚本中,使用跳转时,消息文字提示中必须包含%d,用于显示倒计时时间
---@param actor  userdata 
---@param FColor  number 
---@param BColor  number 
---@param msg  string 
---@param flag  string 
---@param time  number 
---@param func  string 
---@nodiscard
function lib996:sendcentermsg(actor,FColor,BColor,msg,flag,time,func) end;

---遍历玩家列表
---@return table | 返回所有在线玩家对象列表
---@nodiscard
function lib996:getplayerlst() end;

---发送聊天框固顶信息
---* actor  userdata  玩家对象
---* flag  string  0:发送所有人物1:发送给自己2:发送行会3:发送当前地图4:组队
---* FColor  number   前景色
---* BColor  number   背景色
---* time  number   显示时间
---* msg  string   消息内容
---* show  string  是否显示人物名称0-是1-否
---@param actor  userdata 
---@param flag  string 
---@param FColor  number 
---@param BColor  number 
---@param time  number 
---@param msg  string 
---@param show  string 
---@nodiscard
function lib996:sendtopchatboardmsg(actor,flag,FColor,BColor,msg,time,show) end;

---获取玩家GM权限等级
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return number  GM权限等级
---@nodiscard
function lib996:getgmlevel(actor) end;

---发送屏幕滚动信息
---* actor  userdata  玩家对象
---* flag  string  0:发送给自己1:发送所有人物2:发送行会3:发送当前地图4:组队
---* FColor  number   前景色
---* BColor  number   背景色
---* higjt  number   高度
---* show  number  滚动次数
---* msg  string   消息内容
---@param actor  userdata 
---@param flag  string 
---@param FColor  number 
---@param BColor  number 
---@param higjt  number 
---@param show  number 
---@param msg  string 
---@nodiscard
function lib996:sendmovemsg(actor,flag,FColor,BColor,higjt,show,msg) end;

---复活
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function lib996:realive(actor) end;

---弹出窗口消息
---* actor  userdata  玩家对象
---* msg  string   消息内容
---* afun  string   确定后跳转的接口
---* bfun  string   取消后跳转的接口
---@param actor  userdata 
---@param msg  string 
---@param afun  string 
---@param bfun  string 
---@nodiscard
function lib996:messagebox(actor,msg,afun,bfun) end;

---延时跳转
---* actor  userdata  玩家对象
---* time  number   时间(毫秒)
---* func string   触发函数
---* del number  换地图是否删除此延时(0或为空时=不删除 1=删除)
---* param string  多参数用#号拼接
---@param actor  userdata 
---@param time  number 
---@param func string 
---@param del number 
---@param param string 
---@nodiscard
function lib996:delaygoto(actor,time,func,del) end;

---调用触发
---* actor  userdata  玩家对象
---* info  number  0:小组成员1:行会成员2:当前地图的人物3:以自己为中心范围玩家
---* stringfun  string   回调函数
---* range  string   触发模式=3时指定的范围大小
---@param actor  userdata 
---@param info  number 
---@param stringfun  string 
---@param range  string 
---@nodiscard
function lib996:gotolabel(actor,info,strfun,range) end;

---删除延迟
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function lib996:cleardelaygoto(actor) end;

---延时消息跳转
---@nodiscard
function lib996:delaymsggoto(actor,time,func) end;

---获取等级锁
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return number 返回锁住的最大等级,无锁定返回0,失败返回-1
---@nodiscard
function lib996:getlocklevel(actor) end;

---人物飘血飘字特效
---* target  userdata  飘血飘字的主体,一般为受攻击者
---* type  	numbereger   显示类型 详细在下方说明中
---* damage numbereger   	显示的点数
---* hitter 	userdata  "*"则为所有人可看到飘血飘字的主体,一般为攻击者
---@param target  userdata 
---@param type  	numbereger 
---@param damage numbereger 
---@param hitter 	userdata
---@nodiscard
function lib996:sendattackeff(target,type,damage,hitter) end;

---通知客户端显示表单
---* actor  userdata  玩家对象
---* FormName  string   文件名
---* Content string   Win_Create节点ID(参数用#号拼接)
---@param actor  userdata 
---@param FormName  string 
---@param Content string 
---@nodiscard
function lib996:showformwithcontent(actor,FormName,Content) end;

---设定人物攻击飘血飘字类型
---* actor  userdata  玩家对象
---* type  number  显示类型
---@param actor  userdata 
---@param type  number 
---@nodiscard
function lib996:setattackefftype(actor,type) end;

---剔除离线挂机角色
---* mapid  string  地图号,“*”表示全部地图
---* level  number  剔除等级低于此等级均剔除“*”表示所有
---* count number   	最大剔除玩家数“*”表示所有
---@param mapid  string 
---@param level  number 
---@param count number 
---@nodiscard
function lib996:tdummy(mapID,level,count) end;

---采集挖矿等进度条操作
---* actor  userdata  玩家对象
---* time  number   进度条时间`秒级`
---* succ string   成功后跳转的函数
---* msg string   提示消息
---* canstop number    	能否中断0-不可中断1-可以中断
---* fail string   中断触发的函数
---@param actor  userdata 
---@param time  number 
---@param succ string 
---@param msg string 
---@param canstop number  
---@param fail string 
---@nodiscard
function lib996:showprogressbardlg(actor,time,succ,msg,canstop,fail) end;

---设置玩家穿人穿怪
---* actor  userdata  玩家对象
---* type  number   模式：0-恢复默认;1-穿人;2-穿怪;3-穿人穿怪
---* time number   时间(秒)
---* objtype number   对象 ：0-玩家;1-宝宝
---@param actor  userdata 
---@param type  number 
---@param time number 
---@param objtype number 
---@nodiscard
function lib996:throughhum(actor,type,time,objtype) end;

---设置当前攻击目标
---* obj1  userdata  玩家或英雄或怪物对象1
---* obj2  string   玩家或英雄或怪物对象2
---@param obj1  userdata 
---@param obj2  string 
---@nodiscard
function lib996:settargetcert(obj1,obj2) end;

---是否可以设定为攻击目标
---* obj1  userdata  玩家或英雄或怪物对象1
---* obj2  userdata   玩家或英雄或怪物对象2
---@param obj1  userdata 
---@param obj2  userdata 
---@return boolean   obj1是否可以将obj2设为攻击目标
---@nodiscard
function lib996:ispropertarget(obj1,obj2) end;

---停止摆摊
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function lib996:forbidmyshop(
    actor
) end;

---增加气泡
---* actor  userdata  玩家对象
---* ID  number   	ID
---* name string   显示名称
---* fun fun  函数名(多参数用逗号分割)
---@param actor  userdata 
---@param ID  number 
---@param name string 
---@param fun fun
---@nodiscard
function lib996:addbutshow(actor,ID,name,bool) end;

---获取物品颜色
---* makeid  number  物品id
---@param makeid  number 
---@return boolean   成功——颜色值|失败——0|
---@nodiscard
function lib996:getitemcolor(itemid) end;

---删除气泡
---* actor  userdata  玩家对象
---* ID  number   ID
---@param actor  userdata 
---@param ID  number 
---@nodiscard
function lib996:delbutshow(actor,ID) end;

---获取物品职业限制
---* makeid  number  物品id
---@param makeid  number 
---@return 返回职业限制 ||
---@nodiscard
function lib996:getitemjob(itemid) end;

---给物品
---* actor  userdata  玩家对象
---* itemname  string   	物品名称
---* qty number   数量
---* bind 	number   	物品规则
---@param actor  userdata 
---@param itemname  string 
---@param qty number 
---@param bind 	number 
---@return ：userdata | 最后一个物品对象,不建议使用在叠加物品,一次性给多个物品的情况,此物品在添加背包触发后,注意可能被回收的情况
---@nodiscard
function lib996:giveitem(actor,itemname,qty,bind) end;

---给物品直接装备
---* actor  userdata  玩家对象
---* where  number   装备位置
---* itemname string   物品名称
---* qty number   	数量
---* bind number  	物品规则
---@param actor  userdata 
---@param where  number 
---@param itemname string 
---@param qty number 
---@param bind number 
---@return boolean   true：成功 | false：不成功
---@nodiscard
function lib996:giveonitem(actor,where,itemname,qty,bind) end;

---设置宝宝行为
---* actor  userdata  怪物对象
---* act  number  多行为相加 1：禁止攻击玩家,2：不可被攻击,4：优先攻击 玩家攻击对象,8：优先攻击 玩家受击对象,16：不可被玩家攻击 允许被怪攻击
---@param actor  userdata 
---@param act  number 
---@return boolean   成功——true|失败——false
---@nodiscard
function lib996:setslaveattack(actor,act) end;

---获取宝宝行为
---* actor  userdata  怪物对象
---@param actor  userdata 
---@return number  成功——怪物行为|失败——-1
---@nodiscard
function lib996:getslaveattack(actor) end;

---获取发型
---*  actor  	userdata  玩家对象
---@param  actor  	userdata 
---@return number  成功——发型编号|失败——-1
---@nodiscard
function lib996:gethair(actor) end;

---设置发型
---*  actor  	userdata  玩家对象
---*  hair  	number  发型编号0：为无发型
---@param  actor  	userdata 
---@param  hair  	number 
---@return number  成功——发型编号|失败——-1
---@nodiscard
function lib996:sethair(actor,hair) end;

---拿物品
---@return boolean   true：成功 | false：失败
---@nodiscard
function lib996:takeitem(actor,itemname,qty,IgnoreJP) end;

---根据装备位获取装备对象
---* actor  userdata  玩家对象
---* where  number   	装备位置
---@param actor  userdata 
---@param where  number 
---@return userdata  | 成功：返回装备对象 | 失败：返回`"0"` 或 nil
---@nodiscard
function lib996:linkbodyitem(actor,where) end;

---获取物品实体信息
---* actor  userdata  玩家对象
---* item  userdata   	物品对象
---* id number   	1:唯一ID2:物品ID3:剩余持久4:最大持久5:叠加数量6:绑定状态
---@param actor  userdata 
---@param item  userdata 
---@param id number 
---@return number  | 对应数值,不存在为0
---@nodiscard
function lib996:getiteminfo(actor,item,id) end;

---获取物品记录信息
---* actor  userdata  玩家对象
---* item  userdata   物品对象
---* type number  	[1,2,3]
---* position number   	当type=1,取值范围[0..49]type=2,取值范围[0..19]
---@param actor  userdata 
---@param item  userdata 
---@param type number 
---@param position number 
---@nodiscard
function lib996:getitemaddvalue(actor,item,type,position) end;

---退出前触发
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return boolean   true 允许  false 禁止
---@nodiscard
function on_pre_logout(actor) end;

---设置玩家GM权限等级
---* actor  userdata  玩家对象
---* level  number  GM权限等级
---@param actor  userdata 
---@param level  number 
---@nodiscard
function lib996:setgmlevel(actor,level) end;

---设置物品记录信息
---* actor  userdata  玩家对象
---* item  userdata  物品对象
---* type number   [1,2,3]
---* position number   	当type=1,取值范围[0..49]type=2,取值范围[0..19]
---* value number  设置物品对应位置值
---@param actor  userdata 
---@param item  userdata 
---@param type number 
---@param position number 
---@param value number 
---@nodiscard
function lib996:setitemaddvalue(
    actor,
    item,
    type,
	position,
	value
) end;

---刷新物品信息到前端
---* actor  userdata  玩家对象
---* item  userdata  物品对象
---@param actor  userdata 
---@param item  userdata 
---@nodiscard
function lib996:refreshitem(actor,item) end;

---加入行会前
---* actor  userdata  玩家对象
---* guild  userdata  行会对象
---* name  string  行会名称
---@param actor  userdata 
---@param guild  userdata 
---@param name  string 
---@return boolean  true——允许|false——阻止
---@nodiscard
function on_add_guild_pre(actor,guild,name) end;

---延时回调(地图)
---@nodiscard
function lib996:delaymapgoto(mapid,time,strfun,param,vmID) end;

---判断城墙是否损毁
---* param  number  param: 1-左边,2-中间,3-右边
---@param param  number 
---@return boolean   损毁——true|没有损毁——false
---@nodiscard
function lib996:iscastlewallbroken(param) end;

---修复城墙
---* param  number  param: 1-左边,2-中间,3-右边
---@param param  number 
---@nodiscard
function lib996:repaircastlewall(param) end;

---任意地图杀死怪物
---* actor  userdata  玩家对象(归属)
---* monobj  userdata  怪物对象
---* killer  userdata  击杀者对象
---@param actor  userdata 
---@param monobj  userdata 
---@param killer  userdata 
---@nodiscard
function killmon(actor,monobj,killer) end;

---客户端请求消息超量时触发
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function jsonrequestexcept(actor) end;

---判断大门是否损毁
---@return boolean   损毁——true|没有损毁——false
---@nodiscard
function lib996:iscastledoorbroken() end;

---任务完成时触发
---* actor  userdata  玩家对象
---* id  number  任务id
---@param actor  userdata 
---@param id  number 
---@nodiscard
function completetask(actor,id) end;

---停止挂机触发
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function stopautoplaygame(actor) end;

---组队杀怪触发
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function groupkillmon(actor) end;

---镖车到达指定寻路点触发
---@nodiscard
function carpathend() end;

---修复大门
---@nodiscard
function lib996:repaircastledoor() end;

---查询人物名称是否存在
---* actor  userdata  玩家对象
---* name  string   要查询的名字
---@param actor  userdata 
---@param name  string 
---@return number  0-可以使用 1、2、6-名称被过滤 3-名字已经存在 5-长度不符合要求
---@nodiscard
function lib996:queryhumnameexist(actor,name) end;

---判断守卫是否损毁
---* param  number  param: 0-3
---@param param  number 
---@return boolean   损毁——true|没有损毁——false
---@nodiscard
function lib996:iscastleguarddeath(param) end;

---修复守卫
---* param  number  param: 0-3
---@param param  number 
---@nodiscard
function lib996:repaircastleguard(param) end;

---判断弓箭手是否损毁
---* param  number  param: 0-11
---@param param  number 
---@return boolean   损毁——true|没有损毁——false
---@nodiscard
function lib996:iscastlearcherdeath(param) end;

---修复弓箭手
---* param  number  param: 0-11
---@param param  number 
---@nodiscard
function lib996:repaircastlearcher(param) end;

---宝宝死亡触发
---* actor  userdata  主人对象
---* mon  userdata  宝宝对象
---@param actor  userdata 
---@param mon  userdata 
---@nodiscard
function selfkillslave(actor, mon) end;

---杀掉宝宝触发
---* actor  userdata  攻击者对象
---* mon  userdata  宝宝对象
---* monname  userdata  宝宝名称
---@param actor  userdata 
---@param mon  userdata 
---@param monname  userdata 
---@nodiscard
function killslave(attacks, mon, monname) end;

---获取实体物品显示名称
---* makeid  number    物品唯一id
---@param makeid  number 
---@return string  | 显示名称|
---@nodiscard
function lib996:getitemshowname(makeid) end;

---设置实体物品显示名称
---* actor  userdata  玩家对象
---* makeid  number    物品唯一id
---* name string   显示名称
---@param actor  userdata 
---@param makeid  number 
---@param name string 
---@return boolean   true——修改成功|false——失败|
---@nodiscard
function lib996:setitemshowname(actor,makeid,name) end;

---获取实体物品名称颜色
---* makeid  number    物品唯一id
---@param makeid  number 
---@return number  | 显示颜色|
---@nodiscard
function lib996:getitemnamecolor(makeid) end;

---设置实体物品名称颜色
---* actor  userdata  玩家对象
---* makeid  number    物品唯一id
---* color number    颜色(0-255)
---@param actor  userdata 
---@param makeid  number 
---@param color number 
---@return boolean   true——修改成功|false——失败|
---@nodiscard
function lib996:setitemnamecolor(actor,makeid,color) end;

---摆摊触发
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return boolean   true：允许,false：不允许
---@nodiscard
function startmyshop(actor) end;

---设置对象阵营
---*  actor  	userdata  玩家对象or怪物对象
---*  camp 	number  阵营
---@param  actor  	userdata 
---@param  camp 	number 
---@nodiscard
function lib996:setcamp(actor,camp) end;

---获取对象阵营
---*  actor  	userdata  玩家对象or怪物对象
---@param  actor  	userdata 
---@return number  返回角色阵营
---@nodiscard
function lib996:getcamp(actor) end;

---判断该地图是否有该定时器
---* mapid  string  	地图ID
---* timeid  number  定时器ID
---@param mapid  string 
---@param timeid  number 
---@return boolean   true——有|false——无
---@nodiscard
function lib996:hasenvirtimer(mapid,timeid) end;

---添加自定义怪物行走路径
---* group  string  路径ID
---* json  string  路径json
---@param group  string 
---@param json  string 
---@nodiscard
function lib996:addmonactgroup(group,json) end;

---让怪物释放自定义技能
---* player   userdata  	怪物对象
---* skillid   userdata  	自定义技能id
---* x   number  	x坐标
---* y   number  	y坐标
---* actor   userdata  	目标对象
---@param player   userdata 
---@param skillid   userdata 
---@param x   number 
---@param y   number 
---@param actor   userdata 
---@nodiscard
function lib996:mon_docustommagic(player,skillid,x,y,actor)  end;

---设置技能特效
---* actor userdata  	玩家对象
---* skillname string  	技能名称
---* groupid number  特效id
---@param actor userdata 
---@param skillname string 
---@param groupid number 
---@nodiscard
function lib996:setskilleffgroup(actor,skillname,groupid) end;

---重置技能特效
---* actor userdata  	玩家对象
---* skillname string  	技能名称 为" * " 则为所有技能
---@param actor userdata 
---@param skillname string 
---@nodiscard
function lib996:resumeskilleffgroup(actor,skillname) end;

---创建临时NPC(拓展)
---* mapid  string   地图id
---* x  number   x坐标
---* y  number   y坐标
---* npcjson  string  npc信息
---@param mapid  string 
---@param x  number 
---@param y  number 
---@param npcjson  string
---@return number  返回新npcid
---@nodiscard
function lib996:createnpcex(mapid,x,y,npcjson) end;

---删除自定义怪物行走路径
---* group  string  路径ID
---@param group  string 
---@nodiscard
function lib996:delmonactgroup(group) end;

---根据路径ID设置自定义怪物行走路径
---* mon   userdata  自定义怪物对象
---* group  string  路径ID
---* route  number  第N条路径开始执行
---@param mon   userdata 
---@param group  string 
---@param route  number 
---@nodiscard
function lib996:monsetactgroup(mon,group,route) end;

---设置自定义怪物临时行走路径
---* mon   userdata   自定义怪物对象
---* X  number  X坐标
---* Y  number  Y坐标
---* Range  number  目标点大小(走到此范围内也视为到达目标点)
---* AtkType  number   0-不攻击/1-被动攻击/2-主动攻击
---* Guard  number  守护范围(超过此范围返回路径点,路径点根据怪物行动进度动态更新,不会出现拉往目标点方向后,怪物仍然掉头的情况)
---* ArriveLbl  string  到达出发点之后调用的触发
---@param mon   userdata 
---@param X  number 
---@param Y  number 
---@param Range  number 
---@param AtkType  number 
---@param Guard  number 
---@param ArriveLbl  string 
---@nodiscard
function lib996:monsetact(mon,X,Y,Range,AtkType,Guard,ArriveLbl) end;

---清除自定义怪物行走路径(包括临时)
---* mon   userdata   自定义怪物对象
---@param mon   userdata 
---@nodiscard
function lib996:monclractgroup(mon) end;

---升级触发
---* actor  userdata  玩家对象
---* level  number  当前等级
---@param actor  userdata 
---@param level  number 
---@nodiscard
function on_level_up(actor,level) end;

---获取玩家所有称号
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return table |成功——称号id表|失败——返回"" 对象错误返回 nil
---@nodiscard
function lib996:getalltitle(actor) end;

---卸下玩家当前展示称号
---* actor  userdata  玩家对象
---* id  number  称号id
---@param actor  userdata 
---@param id  number 
---@return boolean  true——成功|false——失败
---@nodiscard
function lib996:discurtitle(actor,id) end;

---获取玩家当前展示称号
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return number 成功——返回称号id|失败——返回-1
---@nodiscard
function lib996:getcurtitle(actor) end;

---添加自定义安全区
---*  map  	string  地图ID
---*  safeid  	number  自定义安全区ID
---*  itype  	number  类型 参考cfg_startponumber表中 类型
---*  ponumberjson  	string  安全区json 参考cfg_startponumber表 坐标
---@param  map  	string 
---@param  safeid  	number 
---@param  itype  	number 
---@param  ponumberjson  	string 
---@nodiscard
function lib996:addsafezone(map,safeid,itype,pointjson) end;

---判断该地图是否有该自定义安全区
---*  map  	string  地图ID
---*  safeid  	number  自定义安全区ID
---@param  map  	string 
---@param  safeid  	number 
---@return boolean   true——有|false——无
---@nodiscard
function lib996:hassafezone(map,safeid) end;

---开启玩家详细日志
---* UserID   string  玩家唯一ID
---* Minute  number  持续记录时间 单位：分钟
---@param UserID   string 
---@param Minute  number 
---@nodiscard
function lib996:setdetaillog(UserID,Minute) end;

---删除该地图的自定义安全区
---*  map  	string  地图ID
---*  safeid  	number  自定义安全区ID
---@param  map  	string 
---@param  safeid  	number 
---@nodiscard
function lib996:delsafezone(map,safeid) end;

---创建一个分身
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return userdata | 分身对象
---@nodiscard
function lib996:newclone(actor) end;

---生成假人
---* map  ostringject  登录地图
---* x  number  X坐标
---* y  number  Y坐标
---* range  number  范围
---* job  number  职业(0=战士 1=法师 2=道士 3=随机)
---* num  number  数量
---* login  number  登录模式(0=顺序 1=倒顺 2=随机)
---* sex  number  性别(0=男 1=女)
---* attack  boolean  是否开启自动战斗
---@param map  ostringject 
---@param x  number 
---@param y  number 
---@param range  number 
---@param job  number 
---@param num  number 
---@param login  number 
---@param sex  number 
---@param attack  boolean 
---@return number  成功登录数量 | 全失败返回-1
---@nodiscard
function lib996:dumlogon(map,x,y,range,job,num,login,sex,attack) end;

---获取称号剩余时间
---* actor  userdata  玩家对象
---* id  number  称号id
---@param actor  userdata 
---@param id  number 
---@return number  -2：获取失败,可能无此称号 | -1：永久存在 | 正常剩余时间
---@nodiscard
function lib996:gettitletime(actor,id) end;

---判断玩家是否拥有该称号
---* actor  userdata  玩家对象
---* id  number  称号id
---@param actor  userdata 
---@param id  number 
---@return boolean   true：有 | false：无
---@nodiscard
function lib996:hastitle(actor,id) end;

---判断对象能否走路
---*  actor  	userdata  对象
---@param  actor  	userdata 
---@return boolean   true：能跑 | false：不能跑
---@nodiscard
function lib996:iswalk(actor) end;

---判断对象能否跑步
---*  actor  	userdata  对象
---@param  actor  	userdata 
---@return boolean   true：能跑 | false：不能跑
---@nodiscard
function lib996:isrun(actor) end;

---判断逻辑格是否为空
---*  mapid  	string  地图ID
---*  x  	number  	x坐标
---*  y  	number  	y坐标
---@param  mapid  	string 
---@param  x  	number 
---@param  y  	number 
---@return boolean   true：为空 | false：不为空
---@nodiscard
function lib996:isempty(mapid, x, y) end;

---buff改变时
---* actor  userdata  对象
---* buffid  number  buffid
---* buffgroupid  number  改变后buffid
---* operation  userdata  操作类型：number  1：添加 2：更新 4：删除
---* actObj  userdata  释放者
---@param actor  userdata 
---@param buffid  number 
---@param buffgroupid  number 
---@param operation  userdata 
---@param actObj  userdata 
---@nodiscard
function buffchange(actor,buffid,buffgroupid,operation, actObj) end;

---开启一键拾取
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function lib996:autopickitembybtn(actor) end;

---关闭一键拾取
---* actor  userdata  玩家对象
---@param actor  userdata 
---@nodiscard
function lib996:stopautopickitembybtn(actor) end;

---获取地图上所有怪物
---*  mapid  	string  地图id
---*  monid  	number  怪物id,为-1时即为所有(-1暂未更新)
---*  ignbb  	boolean  是否忽略宝宝 true:忽略 false:不忽略
---@param  mapid  	string 
---@param  monid  	number 
---@param  ignbb  	boolean 
---@return table  |成功——怪物对象|失败——nil
---@nodiscard
function lib996:getmon(mapid,monid,ignbb) end;

---获取地图上所有玩家
---*  mapid  	string  地图id
---*  igndied  	number  是否忽略死亡角色 true:忽略 false:不忽略
---*  isdum  	boolean  是否忽略假人 true:忽略 false:不忽略
---@param  mapid  	string 
---@param  igndied  	number 
---@param  isdum  	boolean 
---@return table |成功——玩家对象|失败——nil
---@nodiscard
function lib996:getplay(mapid,igndied,isdum) end;

---返回分身列表
---* actor  userdata  玩家对象
---@param actor  userdata 
---@return table | 列表
---@nodiscard
function lib996:clonelist(actor) end;

---设置角色技能剩余冷却时间
---* actor userdata  	玩家对象
---* id number  	技能id
---* time number  cd时间(毫秒)0：立即刷新
---@param actor userdata 
---@param id number 
---@param time number 
---@nodiscard
function lib996:setskillcd(actor,id,time) end;

---获取角色技能剩余冷却时间
---* actor userdata  	玩家对象
---* id number  	技能id
---@param actor userdata 
---@param id number 
---@return number  成功：剩余CD时间-单位毫秒,失败：-1
---@nodiscard
function lib996:getskillcd(actor,id) end;

---设置角色技能最大冷却时间
---* actor userdata  	玩家对象
---* id number  	技能id
---* time number  cd时间(毫秒)
---@param actor userdata 
---@param id number 
---@param time number 
---@nodiscard
function lib996:setskillmaxcd(actor,id,time) end;

---点击采集怪时触发
---* actor  userdata  玩家对象
---* mon  number  怪物对象
---* monid  number  怪物id
---@param actor  userdata 
---@param mon  number 
---@param monid  number 
---@nodiscard
function collectmon(actor,mon,monid) end;

---微信公众号KEY验证成功时
---* actor  userdata  玩家对象
---* wechatkey  number  请求的微信公众号key
---* openid  number  openid
---@param actor  userdata 
---@param wechatkey  number 
---@param openid  number 
---@nodiscard
function on_bindrewechat(actor,wechatkey,openid) end;

---请求微信公众号KEY时
---* actor  userdata  玩家对象
---* wechatkey  number  请求的微信公众号key
---@param actor  userdata 
---@param wechatkey  number 
---@nodiscard
function on_bindwechat(actor,wechatkey) end;

---请求微信公众号KEY
---* actor   userdata  玩家对象
---* wtype  number  请求类型,1：绑定,2：解绑,3：验证
---@param actor   userdata 
---@param wtype  number 
---@nodiscard
function lib996:bindwechat(actor,wtype) end;

---清除微信公众号KEY
---* actor   userdata  玩家对象
---@param actor   userdata 
---@nodiscard
function lib996:clearwechat(actor) end;

---获取物品绑定规则
---* makeid  number  物品makeindex
---@param makeid  number 
---@return number 返回绑定规则
---@nodiscard
function lib996:getitembind(makeid)  end;

---物品进入背包前触发
---* actor  userdata  玩家对象
---* itemid  number   物品id
---* itemmakeid  number    makeid(唯一ID)
---@param actor  userdata 
---@param itemid  number 
---@param itemmakeid  number 
---@return boolean   true:允许进入,false:系统回收
---@nodiscard
function on_addbag_pre(actor,itemid,itemmakeid) end;

---获取城墙对象
---* param  number  param: 1-左边,2-中间,3-右边
---@param param  number 
---@return userdata | 返回城墙对象
---@nodiscard
function lib996:getcastlewall(param) end;

---获取物品绑定规则
---* makeid  number  物品makeindex
---@param makeid  number 
---@return number 物品绑定规则
---@nodiscard
function lib996:getitembind(makeid,bind)  end;

---获取守卫对象
---* param  number  param: 0-3
---@param param  number 
---@return userdata | 返回守卫对象
---@nodiscard
function lib996:getcastleguard(param) end;

---获取城门对象
---@return userdata | 返回城门对象
---@nodiscard
function lib996:getcastledoor() end;

---获取弓箭手对象
---* param  number  param: 0-11
---@param param  number 
---@return userdata | 返回弓箭手对象
---@nodiscard
function lib996:getcastlearcher(param) end;

---扔东西触发
---* actor  userdata  玩家对象
---* itemmakeid  number    makeid(唯一ID)
---* itemid  number   物品id
---@param actor  userdata 
---@param itemmakeid  number 
---@param itemid  number 
---@nodiscard
function dropitemex(actor, itemmakeid, itemid) end;

---设置人物照亮范围
---* actor  userdata  玩家对象
---* nType  number  类型0:装备与接口取大值1:基础+接口(忽视装备)2:基础+装备+接口
---* nValue  number  人物照亮范围值
---@param actor  userdata 
---@param nType  number 
---@param nValue  number 
---@nodiscard
function lib996:setchrcandle(actor, nType, nValue) end;

return lib996;