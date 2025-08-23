lib996={};
---�ж������index�Ƿ����
---* id  number  id
---@param id  number 
---@return boolean   true���ɹ� | false�����ɹ�
---@nodiscard
function lib996:hassysindex(id) end;

---��ҷż���ʱ����
---* actor  userdata  �ͷ���
---* role  userdata �ܺ���(������ʱΪ��)
---* skillid  number  ����id
---* name  string  ��������
---* x  number  �����x����
---* y  number  �����y����
---@param actor  userdata 
---@param role  userdata
---@param skillid  number 
---@param name  string 
---@param x  number 
---@param y  number 
---@nodiscard
function on_spell(actor,role,skillid,name,x,y) end;

---��ȡ������id
---@return return number ���ط�����id
---@nodiscard
function lib996:getserverid() end;

---��ȡ��Ϸid
---@return return number ������Ϸid
---@nodiscard
function lib996:getgameid() end;

---��ȡ��ǰ�����
---@return return string ���ص�ǰ�����
---@nodiscard
function getm2version() end;

---����HTTPPost
---* url  string   ���ӵ�ַ
---* stringfun  fun   �ص�����
---* suffix  string   ������Ϣ
---* head  json�ַ�����ʽ   ����ͷ
---@param url  string 
---@param stringfun  fun 
---@param suffix  string 
---@param head  json�ַ�����ʽ 
---@nodiscard
function lib996:httprequestpost(url,strfun,suffix,head) end;

---����HTTPGet
---* url  string   ���ӵ�ַ
---* stringfun  fun   �ص�����
---@param url  string 
---@param stringfun  fun 
---@nodiscard
function lib996:httprequestget(url,strfun) end;

---��ȡ��Ʒģ������
---* Idx  number  ��Ʒid
---@param Idx  number 
---@return string | ������Ʒװ���������õ�����
---@nodiscard
function lib996:getstditemattr(Idx) end;

---��ȡ��ν
---* actor  userdata  ��Ҷ���
---* type  number  0.����ǰ  1.���ֺ�
---@param actor  userdata 
---@param type  number 
---@nodiscard
function lib996:getalias(actor,type) end;

---���ó�ν
---* actor  userdata  ��Ҷ���
---* string  string  ��ν
---* type  number  0.����ǰ  1.���ֺ�
---@param actor  userdata 
---@param string  string 
---@param type  number 
---@nodiscard
function lib996:setalias(actor,str,type) end;

---���ݼ������ƻ�ȡ����id
---* name string  	����name
---@param name string 
---@return ���ܶ���userdata
---@nodiscard
function lib996:getskillindex(name) end;

---���ݼ���id��ȡ��������
---* id number  	����id
---@param id number 
---@return �������ƣ�string
---@nodiscard
function lib996:getskillname(id) end;

---��ҷż���ǰ����
---* actor  userdata  �ͷ���
---* role  userdata �ܺ���(������ʱΪ��)
---* skillid  number  ����id
---* name  string  ��������
---* x  number  �����x����
---* y  number  �����y����
---@param actor  userdata 
---@param role  userdata
---@param skillid  number 
---@param name  string 
---@param x  number 
---@param y  number 
---@return boolean  true���������ͷ�|false����ֹ�ͷ�
---@nodiscard
function on_spell_pre(actor,role,skillid,name,x,y) end;

---�����Ƿ����
---*  actor  	userdata  ��Ҷ���
---@param  actor  	userdata 
---@return boolean   true������ | false��������
---@nodiscard
function lib996:isnotnull(actor) end;

---����ɱ����ɫ
---* aactor  userdata  �ܺ��߶���
---* bactor  userdata  ���ֶ��� ��nilΪϵͳɱ��
---@param aactor  userdata 
---@param bactor  userdata 
---@return boolean  true�����ɹ�|false����ʧ��
---@nodiscard
function lib996:kill(aactor,babtor) end;

---ʹ����Ʒǰ
---* actor  userdata  ����
---* itemmakeid  number   makeid(ΨһID)
---* itemname string   ��Ʒ����
---* itemid  number   ��Ʒid
---@param actor  userdata 
---@param itemmakeid  number 
---@param itemname string 
---@param itemid  number 
---@return boolean  true��������|false������
---@nodiscard
function stdmodefuncAnicount(actor,itemmakeid,itemname,itemid) end;

---����Ψһid������Ҳֿ���Ʒ
---* actor  userdata  ����
---* makeid  number  Ψһid
---* count  number  ������Ʒ�۳�����,����˲���,Ĭ��ȫ���۳�,���ɵ�����Ʒȫ���۳�
---@param actor  userdata 
---@param makeid  number 
---@param count  number 
---@return boolean  true�����ɹ�|false����ʧ��
---@nodiscard
function lib996:dessitems(actor,makeid,count) end;

---��Ŀ���ͷż���
---* actor  userdata  ��Ҷ���
---* skillid  number   ����ID
---* type number  	���ͣ�1-��ͨ����2-ǿ������
---* level  number  ���ܵȼ�
---* target  userdata   Ŀ�����
---* flag number  	�Ƿ���ʾʩ��������0-����ʾ,1-��ʾ
---@param actor  userdata 
---@param skillid  number 
---@param type number 
---@param level  number 
---@param target  userdata 
---@param flag number 
---@nodiscard
function lib996:releasemagic_target(actor,skillid,type,level,target,flag) end;

---ɾ����Ҳֿ�ָ����Ʒ
---* actor  userdata  ����
---* itemname  string  ��Ʒ����
---* qty  number  ����
---@param actor  userdata 
---@param itemname  string 
---@param qty  number 
---@return boolean  true�����ɹ�|false����ʧ��
---@nodiscard
function lib996:delsitems(actor,itemname,qty) end;

---�������ͷż���
---* actor  userdata  ��Ҷ���
---* skillid  number   ����ID
---* type number  	���ͣ�1-��ͨ����2-ǿ������
---* level  number  ���ܵȼ�
---* x  number   Ŀ���X����
---* y  number   Ŀ���Y����
---* flag number  	�Ƿ���ʾʩ��������0-����ʾ,1-��ʾ
---@param actor  userdata 
---@param skillid  number 
---@param type number 
---@param level  number 
---@param x  number 
---@param y  number 
---@param flag number 
---@nodiscard
function lib996:releasemagic_pos(actor,skillid,type,level,x,y,flag) end;

---����Ӣ������
---* actor  userdata  ��Ҷ���
---* name  string  Ӣ������
---@param actor  userdata 
---@param name  string 
---@nodiscard
function lib996:checkheroname(actor,name) end;

---��ȡ��Ҳֿ���������
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return number �ֿ���������|ʧ���򷵻�-1
---@nodiscard
function lib996:getssize(actor) end;

---��ȡ����������
---@return string | ����
---@nodiscard
function lib996:getservername() end;

---��ȡ��Ҳֿ�ָ����Ʒ������
---* actor  userdata  ����
---* itemname  string  ��Ʒ����
---* itype  number  ������ 0����,1�ǰ�,2��/�ǰ�
---@param actor  userdata 
---@param itemname  string 
---@param itype  number 
---@return number ָ����Ʒ������|ʧ���򷵻�-1
---@nodiscard
function lib996:sitemcount(actor,itemname,itype) end;

---��ȡ��ұ���ָ����Ʒ������
---* actor  userdata  ��Ҷ���
---* itemname  string  ��Ʒ����
---* itype  number  ������ 0����,1�ǰ�,2��/�ǰ�
---@param actor  userdata 
---@param itemname  string 
---@param itype  number 
---@return number  �ɹ�������Ʒ����|ʧ�ܡ���-1
---@nodiscard
function lib996:itemcount(actor,itemname,itype) end;

---��ȡ�ֿ�ʣ��ո���
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return number �ո���|ʧ���򷵻�-1
---@nodiscard
function lib996:getsblank(actor) end;

---����ʱ
---* attacks  userdata  �����߶���
---* roles  userdata �ܺ��߶���
---* skillid  number  ����id
---@param attacks  userdata 
---@param roles  userdata
---@param skillid  number 
---@nodiscard
function attack(attacks,roles,skillid) end;

---������Ʒmakeindex��ȡ��Ʒ����
---* makeindex  number  ��Ʒmakeindex
---@param makeindex  number 
---@return string
---@nodiscard
function lib996:getnamebymakeindex(makeindex) end;

---ɾ����ν
---* actor  userdata  ��Ҷ���
---* type  number  0.����ǰ  1.���ֺ�
---@param actor  userdata 
---@param type  number 
---@nodiscard
function lib996:delalias(actor,type) end;

---�������ת���ȼ�
---* actor  userdata  ��Ҷ���
---* n  number  ��ǰת���ȼ�
---@param actor  userdata 
---@param n  number 
---@nodiscard
function lib996:setrelevel(actor,n) end;

---��ȡ�������˶���
---* mon  userdata  �������
---@param mon  userdata 
---@return userdata | ���س��ﱦ�������˵Ķ���,����ַ���
---@nodiscard
function lib996:getmonplayer(mon) end;

---��ȡ������Ϊ����
---* monid   number  	����id
---@param monid   number 
---@return number  �ɹ� ���� ������Ϊ����|ʧ�� ���� -1
---@nodiscard
function lib996:getmonrace(monid)  end;

---����ʱ����
---* actor  userdata  ��Ҷ���
---* money  number  ����id
---* moneynum  number  ����
---* itemid  number  �������Ʒid
---* makeid  number  �������ƷΨһid
---* itemname  string  �������Ʒ����
---* num  number  �������Ʒ����
---@param actor  userdata 
---@param money  number 
---@param moneynum  number 
---@param itemid  number 
---@param makeid  number 
---@param itemname  string 
---@param num  number 
---@return boolean  true��������|false������
---@nodiscard
function biddingpaimaiitem(actor,money,moneynum,itemid,makeid,itemname,num) end;

---��Ŀ������ͷż�����Ч
---*  actor  	userdata  ��Ҷ���
---*  magicid  	number  ��Чid
---*  target  	userdata  Ŀ�����
---@param  actor  	userdata 
---@param  magicid  	number 
---@param  target  	userdata 
---@nodiscard
function lib996:releasemagiceffect(actor,magicid,target) end;

---��ȡ����id
---* mon  userdata  �������
---@param mon  userdata 
---@return number  ���ع���ģ��id
---@nodiscard
function lib996:getmonidx(mon) end;

---���ñ����ѱ�
---* mon  userdata  �������
---@param mon  userdata 
---@nodiscard
function lib996:betray(mon) end;

---��ȡ�Ѵ�������װ����
---* actor  userdata  ��Ҷ���
---* ID  number  ��װID
---@param actor  userdata 
---@param ID  number 
---@return number ��װ����
---@nodiscard
function lib996:getsuititemcount(actor, ID) end;

---�½�����ʱ����
---* actor  userdata  ��Ҷ���
---* id  number  �½�������id
---@param actor  userdata 
---@param id  number 
---@nodiscard
function picktask(actor,id) end;

---���ʼ�ʱ����
---* actor  userdata  ����
---@param actor  userdata 
---@nodiscard
function readmail(actor) end;

---���񱻵��ʱ
---* actor  userdata  ��Ҷ���
---* id  number  ����id
---@param actor  userdata 
---@param id  number 
---@nodiscard
function clicknewtask(actor,id) end;

---��װ��ǰ
---* actor  userdata  ����
---* itemid  number   ��Ʒid
---* pos number   λ��
---* itemname string   ��Ʒ����
---* itemmakeid  number   makeid(ΨһID)
---@param actor  userdata 
---@param itemid  number 
---@param pos number 
---@param itemname string 
---@param itemmakeid  number 
---@return boolean  true����������|false������
---@nodiscard
function on_take_on_pre(actor,itemid,pos,itemname,itemmakeid) end;

---�Զ�Ѱ·��ʼʱ����
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function findpathbegin(actor) end;

---�Զ�Ѱ·ֹͣʱ����
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function findpathstop(actor) end;

---�жϽ�ɫ�Ƿ��и���Ʒ
---* actor  userdata  ��Ҷ���
---* makeid  number  ��Ʒmakeindex
---@param actor  userdata 
---@param makeid  number 
---@return ���� 0-װ��,1-����,2-�ֿ�, -1-�����ڻ�ʧ��|
---@nodiscard
function lib996:hasitem(actor,makeid) end;

---����Ʒ(��չ)
---@return boolean   true���ɹ� | false��ʧ��
---@nodiscard
function lib996:takeitemex(actor,itme_name,item_num,bind,desc) end;

---�����л��Ա���л��е�ְλ
---* actor  userdata  ��Ҷ���
---* pos  number  ���л��е�ְλ 1���᳤2�����᳤3����ν34����ν45����ν5
---@param actor  userdata 
---@param pos  number 
---@return booleanean |true�������óɹ�|false��������ʧ��
---@nodiscard
function lib996:setplayguildlevel(actor,pos) end;

---�ж�ĳ������Ƿ��ڸ��л���
---* actor  userdata  ��Ҷ���
---* guiid  string  �л�id
---@param actor  userdata 
---@param guiid  string 
---@return booleanean |true��������|false����������
---@nodiscard
function lib996:isinguild(actor,guiid) end;

---�ж��л��Ƿ����
---* guiname  string  �л���
---@param guiname  string 
---@return booleanean |true��������|false����������
---@nodiscard
function lib996:hasguild(guiname) end;

---��ȡbuff��������
---* buffid  number buffid
---@param buffid  number
---@return table
---@nodiscard
function lib996:getbufftemattr(buffid) end;

---��ȡbuff����ʱ��
---* buffid  number buffid
---@param buffid  number
---@return number ʱ��
---@nodiscard
function lib996:getbufftemtime(buffid) end;

---��ȡ�����л�֮��Ĺ�ϵ
---* aguiid  string  A�л�����
---* bguiid  string  B�л�����
---@param aguiid  string 
---@param bguiid  string 
---@return �ɹ������л��ϵ|ʧ�ܡ���-1
---@nodiscard
function lib996:getguildrelation(aguiid,bguiid) end;

---�����л��ϵ
---* aguiid  number  A�л�id
---* bguiid  number  B�л�id
---* opt  string  �л��� 0����ͨ,1���ж�,2������
---@param aguiid  number 
---@param bguiid  number 
---@param opt  string 
---@return booleanean |true�����ɹ�|false����ʧ��
---@nodiscard
function lib996:setguildrelation(aguiid,bguiid,opt) end;

---��ȡbuff���
---* buffid  number buffid
---@param buffid  number
---@return number ���
---@nodiscard
function lib996:getbuffgroup(buffid) end;

---��ȡ�л�����
---* guiid  number  �л�id
---@param guiid  number 
---@return number �ɹ������л�����|ʧ�ܡ���nil
---@nodiscard
function lib996:getguildname(guiid) end;

---��ȡ��ƷΨһid
---* item  userdata  ��Ʒ����
---@param item  userdata 
---@return number �ɹ�������ƷΨһid|ʧ�ܡ���0
---@nodiscard
function lib996:getitemmakeid(item) end;

---��ȡ�л�id
---* guiname  string  �л���
---@param guiname  string 
---@return number �ɹ������л�id|ʧ�ܡ���-1
---@nodiscard
function lib996:getguildid(guiname) end;

---����id��ȡ��Ʒ�Զ��峣��(30��)
---* id  number  ��Ʒid
---@param id  number 
---@return string |�ɹ�������Ʒ�Զ��峣��(30��)|ʧ�ܡ���-1
---@nodiscard
function lib996:getitembvar(id) end;

---��ȡ��ͼ����ҵ�����
---*  mapid  	string  ��ͼid
---*  igndied  	boolean  �Ƿ����������ɫ true:���� false:������
---@param  mapid  	string 
---@param  igndied  	boolean 
---@return number �ɹ������������|ʧ�ܡ���-1
---@nodiscard
function lib996:getplaycount(mapid,igndied) end;

---����id��ȡ��Ʒ�Զ��峣��(29��)
---* id  number  ��Ʒid
---@param id  number 
---@return string |�ɹ�������Ʒ�Զ��峣��(29��)|ʧ�ܡ���-1
---@nodiscard
function lib996:getitemavar(id) end;

---��ȡ��ͼ�Ϲ��������
---*  mapid  	string  ��ͼid
---*  monid  	number  ����id,Ϊ-1ʱ��Ϊ����
---*  ignbb  	boolean  �Ƿ���Ա��� true:���� false:������
---@param  mapid  	string 
---@param  monid  	number 
---@param  ignbb  	boolean 
---@return number �ɹ�������������|ʧ�ܡ���-1
---@nodiscard
function lib996:getmoncount(mapid,monid,ignbb) end;

---����id��ȡ��Ʒʹ�õȼ�
---* id  number  ��Ʒid
---@param id  number 
---@return number �ɹ�������Ʒʹ�õȼ�|ʧ�ܡ���-1
---@nodiscard
function lib996:getitemneedlevel(id) end;

---�ж������Ƿ���ָ��������
---*  isx  	number  �ж϶���x����
---*  isy  	number  �ж϶���y����
---*  rx  	number  �������ĵ�x����
---*  ry  	number  �������ĵ�y����
---*  radius  	number  ����뾶
---@param  isx  	number 
---@param  isy  	number 
---@param  rx  	number 
---@param  ry  	number 
---@param  radius  	number 
---@return booleanean |true������������|false��������
---@nodiscard
function lib996:isinregion(isx,isy,rx,ry,radius) end;

---����id��ȡ��Ʒʹ������
---* id  number  ��Ʒid
---@param id  number 
---@return number �ɹ�������Ʒʹ������|ʧ�ܡ���-1
---@nodiscard
function lib996:getitemneed(id) end;

---��ȡ��ɫ���������ȴʱ��
---* actor userdata  	��Ҷ���
---* id number  	����id
---@param actor userdata 
---@param id number 
---@return �ɹ�����ʣ��CDʱ��-��λ����|ʧ�ܡ��� -1��number
---@nodiscard
function lib996:getskillmaxcd(actor,id) end;

---��ȡ����ʱ����
---* actor  userdata  ��Ҷ���
---* exp  number  ����ֵ
---@param actor  userdata 
---@param exp  number 
---@nodiscard
function gainexp(actor,exp) end;

---���Ҹı�ʱ����
---* actor  userdata  ��Ҷ���
---* id  number  ����id
---* beforenum  number  �ı�ǰ��������
---* afternum  number  �ı���������
---@param actor  userdata 
---@param id  number 
---@param beforenum  number 
---@param afternum  number 
---@nodiscard
function moneychangeex(actor,id,beforenum,afternum) end;

---�Ƿ���Ӣ��
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return boolean   true:�� | false:û��
---@nodiscard
function lib996:hashero(actor) end;

---���˽�����̯ʱ
---* actor  userdata  ���˶���
---* itemtab  json  ���˰�̯��Ʒ��
---@param actor  userdata 
---@param itemtab  json 
---@nodiscard
function on_stall_end(actor,itemtab) end;

---����Ӣ��
---* actor  userdata  ��Ҷ���
---* name  string  Ӣ������
---* job  number  ְҵ
---* sex  number  �Ա�
---@param actor  userdata 
---@param name  string 
---@param job  number 
---@param sex  number 
---@nodiscard
function lib996:createhero(actor,name,job,sex) end;

---��ȡ��ǰƽ̨
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return WINDOWS = 0|        LINUX   = 1|        MAC     = 2|        ANDROID = 3|        IPHONE  = 4|        IPAD    = 5|        BLACKBERRY = 6|        NACL    = 7|        EMSCRIPTEN = 8|        TIZEN   = 9|        WINRT   = 10|        WP8     = 11
---@nodiscard
function lib996:getplatform(actor) end;

---ɾ��Ӣ��
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function lib996:delhero(actor) end;

---���˵�¼ʱ
---* actor  userdata  ���˶���
---@param actor  userdata 
---@nodiscard
function dummylogin(actor) end;

---�ٻ�Ӣ��
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function lib996:recallhero(actor) end;

---��ȡ��������б�
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return table | �ɹ�������������б�|ʧ�ܡ���nil
---@nodiscard
function lib996:getslavelist(actor) end;

---��ȡ���м���id
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return table | ����id
---@nodiscard
function lib996:getallskills(actor) end;

---�ջ�Ӣ��
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function lib996:unrecallhero(actor) end;

---��ȡ�����������
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return table | �ɹ�����������|ʧ�ܣ�-1
---@nodiscard
function lib996:getslavenum(actor) end;

---��ȡӢ�۶���
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return userdata | ����Ӣ�۶���,���û�з��� nil �� "0"
---@nodiscard
function lib996:gethero(actor) end;

---��ӡ����������
---@nodiscard
function lib996:printscripttimereport() end;

---��ȡint�����ޱ���
---* type  number  ����0:���,1:�л�,2:��ͼ,3����Ʒ,4��NPC
---* actor  obj  ����
---* varname string  ������
---@param type  number 
---@param actor  obj 
---@param varname string 
---@return ��������:2 | number  |�������ޱ���ֵ ����ʱ���ء���0|number  |�������ޱ���ʣ��ˢ��ʱ�� ����ʱ���ء���0|
---@nodiscard
function lib996:gettlint(type,actor,varname) end;

---���ô��������ļ�¼
---@nodiscard
function lib996:resetscripttimereport() end;

---����int�����ޱ���
---* type  number  ����0:���,1:�л�,2:��ͼ,3����Ʒ,4��NPC
---* actor  obj  ����
---* varname  string  ������
---* value  number ����ֵ
---* cdtime  number ����ʱ��(��),0��nil����,-1�������
---@param type  number 
---@param actor  obj 
---@param varname  string 
---@param value  number
---@param cdtime  number
---@return boolean   true�����ɹ�|false����ʧ��|
---@nodiscard
function lib996:settlint(type,actor,varname,value,cdtime) end;

---��ȡ��ǰ��������
---@return number
---@nodiscard
function lib996:getsysindex() end;

---buff����Ѫ���ı�ʱ
---* actor  userdata  ����
---* buffID  number buffid
---* buffGroup number  buff��
---* HP number  hp
---* BUFFhost userdata  �ͷ���
---@param actor  userdata 
---@param buffID  number
---@param buffGroup number 
---@param HP number 
---@param BUFFhost userdata 
---@return number  hp
---@nodiscard
function bufftriggerhpchange(actor, buffID, buffGroup,HP,BUFFhost) end;

---Ӣ��ȡ���ɹ�����
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function checkusernameok(actor) end;

---Ӣ�۵�½����
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function herologin(actor) end;

---Ӣ��ȡ��ʧ�ܴ���
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function checkusernameno(actor) end;

---֪ͨ��ΧѪ���������仯
---* actor  userdata  ����
---@param actor  userdata 
---@nodiscard
function lib996:healthspellchanged(actor) end;

---��ȡ�л��Ա���л��е�ְλ
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return number �ɹ��������ص�ǰְλ|ʧ�ܡ���-1
---@nodiscard
function lib996:getplayguildlevel(actor) end;

---��ȡ������Ʒʱ
---* actor  userdata  ��Ҷ���
---* money  number  ����id
---* moneynum  number  ���Ļ�����
---* itemid  number  �������Ʒid
---* makeid  number  �������ƷΨһid
---* itemname  string  �������Ʒ����
---* num  number  �������Ʒ����
---@param actor  userdata 
---@param money  number 
---@param moneynum  number 
---@param itemid  number 
---@param makeid  number 
---@param itemname  string 
---@param num  number 
---@return boolean  true��������|false������
---@nodiscard
function getpaimaiitem(actor,money,moneynum,itemid,makeid,itemname,num) end;

---���������Ʒǰ����
---* actor  userdata  ��Ҷ���
---* DropItem  number  ��Ʒ����
---* mon  number  �������
---* x  number  X����
---* y  number  Y����
---@param actor  userdata 
---@param DropItem  number 
---@param mon  number 
---@param x  number 
---@param y  number 
---@return boolean   true���������,false��������
---@nodiscard
function mondropitemex(actor,DropItem, mon, x, y) end;

---ˢ����Ʒ������ǰ��
---* actor  userdata  ��Ҷ���
---* makeid  number  ��Ʒmakeindex(��ƷΨһid)
---@param actor  userdata 
---@param makeid  number 
---@nodiscard
function lib996:senditemvartoc(actor,makeid) end;

---�ڵ�ͼ�����ɵ�����Ʒ
---*  mapid  	number  ��ͼid
---*  actor  	userdata  �������� ��nil �޹��� ��ʰȡcdʱ��ᱻ����Ϊ0
---*  X  	number  x����
---*  Y  	number  y����
---*  json  	string  ����json
---*  data  	string  ��Ʒ��Դ(�ο�������Ʒ��Դ)
---@param  mapid  	number 
---@param  actor  	userdata 
---@param  X  	number 
---@param  Y  	number 
---@param  json  	string 
---@param  data  	string 
---@return table |�ɹ�����makeid��|ʧ�ܡ���nil
---@nodiscard
function lib996:gendropitem(mapid,actor,x,y,json,data) end;

---��������ֿ����
---* actor  userdata  ��Ҷ���
---* count  number   Ҫ���͵ĸ�����
---@param actor  userdata 
---@param count  number 
---@nodiscard
function lib996:changestorage(actor,count) end;

---ɱ������ʱ����
---* actor  userdata  ��������
---* play  userdata   ��ɱ���
---@param actor  userdata 
---@param play  userdata 
---@nodiscard
function killplay(actor, play) end;

---��ȡ���к�����
---@return number  ��ȡ1970��1��1�յ����ڵ��������ĺ�����UTC
---@nodiscard
function lib996:getalltimems() end;

---�����Զ��һ�
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function lib996:startautoattack(actor) end;

---��ȡ��Ʒװ��λ
---*  itemid  	number  ��Ʒid
---@param  itemid  	number 
---@return boolean  �ɹ�����װ��λ|ʧ�ܡ���-1
---@nodiscard
function lib996:getitemsite(itemid) end;

---��ȡint�����ڱ���
---* type  number  ����0:���,1:�л�,2:��ͼ,3����Ʒ,4��NPC
---* actor  obj  ����
---* varname string  ������
---@param type  number 
---@param actor  obj 
---@param varname string 
---@return ��������:2 | number  |�������ޱ���ֵ ����ʱ���ء���0|number  |�������ޱ���ʣ��ˢ��ʱ�� ����ʱ���ء���0|
---@nodiscard
function lib996:getcyint(type,actor,varname) end;

---��������
---* actor  userdata  ��Ҷ���
---* id  number   �����ļ���������Ӧ�������ñ�id(cfg_sound.xls)
---* count  number   ѭ�����Ŵ���
---* flag  number   0.���Ÿ��Լ�1.���Ÿ�ȫ��2.���Ÿ�ͬһ��ͼ4.���Ÿ�ͬ������
---@param actor  userdata 
---@param id  number 
---@param count  number 
---@param flag  number 
---@nodiscard
function lib996:playsound(actor,id,count,flag) end;

---���ý�ɫ���߹һ�(��չ)
---*  actor  	userdata  ��Ҷ���
---*  mapid  	number  Ŀ���ͼid
---*  X  	number  x����
---*  Y  	number  y����
---*  range  	number  ��Χ
---*  mon  	boolean  �Ƿ��ͷű�������(�ڳ�����)
---@param  actor  	userdata 
---@param  mapid  	number 
---@param  X  	number 
---@param  Y  	number 
---@param  range  	number 
---@param  mon  	boolean 
---@nodiscard
function lib996:setoffline(actor,mapid,x,y,range) end;

---����int�����ڱ���
---* type  number  ����0:���,1:�л�,2:��ͼ,3����Ʒ,4��NPC
---* actor  obj  ����
---* varname string  ������
---* value string  ����ֵ
---* cyclevar string ����ֵ -1�������
---* cycletype string �������� 0-��,1-��,2-��,3-Сʱ
---* acttime string ��ʼʱ�� ��ʽ��"2023-12-9 20:00:00" nil:Ϊ��ǰʱ��
---@param type  number 
---@param actor  obj 
---@param varname string 
---@param value string 
---@param cyclevar string
---@param cycletype string
---@param acttime string
---@return boolean   true�����ɹ�|false����ʧ��
---@nodiscard
function lib996:setcyint(type,actor,varname,value,cyclevar,cycletype,acttime) end;

---��ʧ�ڳ�����
---* actor  userdata  ��Ҷ���
---* monobj  userdata  �ڳ�����
---@param actor  userdata 
---@param monobj  userdata 
---@nodiscard
function losercar(actor, monobj) end;

---ֹͣ��ǰ����
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function lib996:stop(actor) end;

---��ȡstr�����ڱ���
---* type  number  ����0:���,1:�л�,2:��ͼ,3����Ʒ,4��NPC
---* actor  obj  ����
---* varname string  ������
---@param type  number 
---@param actor  obj 
---@param varname string 
---@return ��������:2 | string |�������ޱ���ֵ ����ʱ���ء���0|number  |�������ޱ���ʣ��ˢ��ʱ�� ����ʱ���ء���0|
---@nodiscard
function lib996:getcystr(type,actor,varname) end;

---��ȡ����buff
---* actor  userdata  ����
---@param actor  userdata 
---@return table | ���ص�ǰ������������buffid
---@nodiscard
function lib996:getallbuffid(actor) end;

---�޸���ǽ��������
---* param  number  param: 0- ȫ��1-�����ź�ǽ2-�������ֺ��������� Ĭ��Ϊ0
---@param param  number 
---@nodiscard
function lib996:repaircastle(param) end;

---������Ļ��Ч
---* actor  userdata  ��Ҷ���
---* id  number  ��Ч���
---* effectid  number  ��ЧID
---* x  number  ����Ļ�ϵ�X����
---* y  number  ����Ļ�ϵ�Y����
---* speed  number  �����ٶ�
---* times  number  ���Ŵ��� 0Ϊ����
---* itype  number  0:�Լ� 1:������
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

---����str�����ڱ���
---* type  number  ����0:���,1:�л�,2:��ͼ,3����Ʒ,4��NPC
---* actor  obj  ����
---* varname string  ������
---* value number  ����ֵ
---* cyclevar string ����ֵ -1�������
---* cycletype string �������� 0-��,1-��,2-��,3-Сʱ
---* acttime string ��ʼʱ�� ��ʽ��"2023-12-9 20:00:00" nil:Ϊ��ǰʱ��
---@param type  number 
---@param actor  obj 
---@param varname string 
---@param value number 
---@param cyclevar string
---@param cycletype string
---@param acttime string
---@return boolean   true�����ɹ�|false����ʧ��
---@nodiscard
function lib996:setcystr(type,actor,varname,value,cyclevar,cycletype,acttime) end;

---Ӣ�۴�������
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function createherook(actor) end;

---�ر���Ļ��Ч
---* actor  userdata  ��Ҷ���
---* id  number  ��Ч���
---* itype  number  0:�Լ� 1:������
---@param actor  userdata 
---@param id  number 
---@param itype  number 
---@nodiscard
function lib996:deleffects(actor,id,itype) end;

---ɱ�ڳ�����
---* actor  userdata  ��ɱ��
---* monobj  userdata  �ڳ�����
---@param actor  userdata 
---@param monobj  userdata 
---@nodiscard
function cardie(actor, monobj) end;

---���buff
---* actor  userdata  ����
---* buffid  number buffid
---* time number  ����ʱ��Ϊ����Ϊbuff����ʱ��
---* lap number  ���Ӳ���,Ĭ��1
---* player userdata  ʩ����
---* abil table  �޸�buff��att����{[1]=200, [4]=20},����id=ֵ
---* act  boolean  �Ƿ�������Ч,Ĭ��false(99%����²���Ҫʹ��)
---@param actor  userdata 
---@param buffid  number
---@param time number 
---@param lap number 
---@param player userdata 
---@param abil table 
---@param act  boolean 
---@return boolean   true���ɹ� | false�����ɹ�
---@nodiscard
function lib996:addbuff(actor,buffid,time,lap,player,abil,act) end;

---�ж�Ӣ���Ƿ�Ϊ����״̬
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return boolean   true��Ϊ����״̬ | false��Ϊ�ջ�״̬
---@nodiscard
function lib996:isherorecall(actor) end;

---�ж�ϵͳ�Ƿ��ж�ʱ��
---* id  number   ��ʱ��id
---@param id  number 
---@return boolean   true���иö�ʱ�� | false��û�иö�ʱ��
---@nodiscard
function lib996:hastimerex(id) end;

---��ȡ������ʱint�ͱ���
---* Type  number  ����0:���,1:�л�,2:��ͼ,3����Ʒ,4��NPC,5:����
---* actor  obj  ����=���-���������=�л�-���������=��Ʒ-��makeid����=��ͼ-���ͼID����=NPC-��NPCID����=����-�����
---* sVarName string  ������
---@param Type  number 
---@param actor  obj 
---@param sVarName string 
---@return number  ��������õı���,���δ�����򷵻�0
---@nodiscard
function lib996:gettempint(Type,actor,sVarName) end;

---��ȡ������
---*  actor  	userdata  ��� �� �������
---@param  actor  	userdata 
---@return number  �ɹ���������|ʧ�ܣ�-1
---@nodiscard
function lib996:getdir(actor) end;

---�ж϶����Ƿ��ж�ʱ��
---* actor  userdata   ��Ҷ���
---* id  number   ��ʱ��id
---@param actor  userdata 
---@param id  number 
---@return boolean   true���иö�ʱ�� | false��û�иö�ʱ��
---@nodiscard
function lib996:hastimer(actor,id) end;

---�Ƴ�ϵͳ��ʱ��
---* id  number   ��ʱ��id
---@param id  number 
---@nodiscard
function lib996:setofftimerex(id) end;

---���ö�����ʱint�ͱ���
---* Type  number  ����0:���,1:�л�,2:��ͼ,3����Ʒ,4��NPC,5:����
---* actor  obj  ����=���-���������=�л�-���������=��Ʒ-��makeid����=��ͼ-���ͼID����=NPC-��NPCID����=����-�����
---* sVarName string  ������
---* nValue number  ����ֵ
---@param Type  number 
---@param actor  obj 
---@param sVarName string 
---@param nValue number 
---@nodiscard
function lib996:settempint(Type,actor,sVarName,nValue) end;

---���ϵͳ��ʱ��
---* id  number   ��ʱ��id
---* tick  number   ִ�м��,��
---* count  number   ִ�д���,Ϊ0ʱ���޴���
---@param id  number 
---@param tick  number 
---@param count  number 
---@nodiscard
function lib996:setontimerex(id,tick,count) end;

---�Ƴ�����ʱ��
---* actor  userdata   ��Ҷ���
---* id  number   ��ʱ��id
---@param actor  userdata 
---@param id  number 
---@nodiscard
function lib996:setofftimer(actor,id) end;

---��Ӷ���ʱ��
---* actor  userdata   ��Ҷ���
---* id  number   ��ʱ��id
---* tick  number   ִ�м��,��
---* count  number   ִ�д���,Ϊ0ʱ���޴���
---@param actor  userdata 
---@param id  number 
---@param tick  number 
---@param count  number 
---@nodiscard
function lib996:setontimer(actor,id,tick,count) end;

---��ȡ�������HP
---* actor  userdata  ����
---@param actor  userdata 
---@return number  ���ض������Ѫ��
---@nodiscard
function lib996:getmaxhp(actor) end;

---ɾ��buff
---* actor  userdata  ����
---* buffid  number buffid
---* act  boolean  �Ƿ�������Ч,Ĭ��false
---@param actor  userdata 
---@param buffid  number
---@param act  boolean 
---@nodiscard
function lib996:delbuff(actor,buffid) end;

---��ȡ�������MP
---* actor  userdata  ����
---@param actor  userdata 
---@return number  ���ض����������
---@nodiscard
function lib996:getmaxmp(actor) end;

---�Ƿ���buff
---* actor  userdata  ����
---* buffid  number buffid
---@param actor  userdata 
---@param buffid  number
---@return boolean   true:�� | false:û��
---@nodiscard
function lib996:hasbuff(actor,buffid) end;

---��ȡ��������ֵ
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return number  ��������
---@nodiscard
function lib996:getmaxexp(actor) end;

---��ȡstr�����ޱ���
---* type  number  ����0:���,1:�л�,2:��ͼ,3����Ʒ,4��NPC
---* actor  obj  ����
---* varname  string  ������
---@param type  number 
---@param actor  obj 
---@param varname  string 
---@return ��������:2 | string  |�������ޱ���ֵ ����ʱ���ء���nil|number  |�������ޱ���ʣ��ʱ�� ����ʱ���ء���0|
---@nodiscard
function lib996:gettlstr(type,actor,varname) end;

---��ȡbuff��Ϣ
---* actor  userdata  ����
---* buffid  number buffid
---* itype number  1:���Ӳ��� 2:ʣ��ʱ��
---@param actor  userdata 
---@param buffid  number
---@param itype number 
---@return number  ��Ӧ����Ϣ
---@nodiscard
function lib996:getbuffinfo(actor,buffid,itype) end;

---��ȡ�ʼ�����Ʒʱ����
---* actor  userdata  ����
---@param actor  userdata 
---@nodiscard
function getmailitem(actor) end;

---MD5����
---@return string | MD5����ֵ
---@nodiscard
function lib996:md5str() end;

---�Զ����������
---* varname  string  ���������
---* itype  number   0-������� 1-������� 2-�л�
---* sort number  0-����,1-����
---* count number  ��ȡ�������� Ϊ�ջ�0ȡ����,ȡǰ����
---@param varname  string 
---@param itype  number 
---@param sort number 
---@param count number 
---@return table | {��������:����ֵ,��������:����ֵ,��}
---@nodiscard
function lib996:sorthumvar(varname,itype,sort,count) end;

---����str�����ޱ���
---* type  number  ����0:���,1:�л�,2:��ͼ,3����Ʒ,4��NPC
---* actor  obj  ����
---* varname  string  ������
---* value  string ����ֵ
---* cdtime  number ����ʱ��(��),0��nil����,-1�������
---@param type  number 
---@param actor  obj 
---@param varname  string 
---@param value  string
---@param cdtime  number
---@return boolean   true�����ɹ�|false����ʧ��|
---@nodiscard
function lib996:settlstr(type,actor,varname,value,cdtime) end;

---��ȡ��Ʒ���
---* makeid  number  ��ƷΨһid
---* itype  userdata  �������(0~5)
---@param makeid  number 
---@param itype  userdata 
---@return number  ������Ʒ���ֵ|
---@nodiscard
function lib996:getitemmar(makeid,itype) end;

---��������Զ������
---* actor  userdata  Ҫ������������,����  nil ��ʾ�����������
---* varname  string   ������ `* `��ʾ���б���
---@param actor  userdata 
---@param varname  string 
---@nodiscard
function lib996:clearhumcustvar(actor,varname) end;

---����װ����
---* actor  userdata  ����
---* suitid  number   ��װid
---@param actor  userdata 
---@param suitid  number 
---@nodiscard
function groupitemoffex(actor, suitid) end;

---������Ʒ���
---* makeid  number  ��ƷΨһid
---* itype  userdata  �������(0~5)
---* value  number ���ֵ
---@param makeid  number 
---@param itype  userdata 
---@param value  number
---@return boolean   true�����ɹ�|false����ʧ��|
---@nodiscard
function lib996:setitemmar(makeid,itype,value) end;

---����ϵͳ�Զ������
---* varname  string   ������ `* `��ʾ���б���
---@param varname  string 
---@nodiscard
function lib996:clearglobalcustvar(varname) end;

---����װ����
---* actor  userdata  ����
---* suitid  number   ��װid
---@param actor  userdata 
---@param suitid  number 
---@nodiscard
function groupitemonex(actor, suitid) end;

---�����Զ����л����
---* actor  userdata   �л����� nil ��ʾ�����л�
---* varname  string   ������ `* `��ʾ���б���
---@param actor  userdata 
---@param varname  string 
---@nodiscard
function lib996:clearguildcustvar(actor,varname) end;

---ȷ���������潻��ǰ
---* actor  userdata  ������
---* role  userdata  ������
---* a_item  json  �����߽���ȷ�Ͻ�����Ʒmakeid��table
---* r_item  json  �����߽���ȷ�Ͻ�����Ʒmakeid��table
---* a_gold  number  �����߽���ȷ�Ͻ��׻�������
---* r_gold  number  �����߽���ȷ�Ͻ��׻�������
---@param actor  userdata 
---@param role  userdata 
---@param a_item  json 
---@param r_item  json 
---@param a_gold  number 
---@param r_gold  number 
---@return boolean  true����������|false������ֹ����
---@nodiscard
function on_jiaoyi_trade_pre(actor,role,a_item,r_item,a_gold,r_gold) end;

---��ȡȫ����Ϣ
---* itype  number  0: ϵͳ����1:����ʼ ��������(���Ƽ�)2:����ʼ ����ʱ��(���Ƽ�)3: �Ϸ�����4: �Ϸ�ʱ��5: ������IP(���Ƽ�)6: �������7: �����������8: ����汾��9: ����������ʱ��10: ����������ʱ��11:��������ʽʱ��
---@param itype  number 
---@return ����id����Ӧֵ,ʱ����Ϊʱ���
---@nodiscard
function lib996:globalinfo(itype) end;

---��������潻��ǰ
---* actor  userdata  ������
---* role  userdata  ������
---@param actor  userdata 
---@param role  userdata 
---@return boolean  true����������|false������ֹ����
---@nodiscard
function on_jiaoyi_pre(actor, role) end;

---��ȡ��ɫ��������
---* actor  userdata  ��Ҷ���,����������
---@param actor  userdata 
---@return table | ��������ֵ
---@nodiscard
function lib996:attrtab(actor) end;

---��ȡ��������
---* actor  userdata  ����
---* attrid  number   ����id
---@param actor  userdata 
---@param attrid  number 
---@return number  ���������ֵ
---@nodiscard
function lib996:getaddattr(actor, attrid) end;

---�޸���Ʒ��ʾ
---* actor  userdata  ��Ҷ���
---* itemmakeid  number    ��ƷΨһid
---* json json   ��ʾjson
---@param actor  userdata 
---@param itemmakeid  number 
---@param json json 
---@nodiscard
function lib996:setitemlooksbyjson(actor,itemmakeid,json) end;

---���촥��
---* self  userdata  ��Ҷ���
---* msg  string   ����
---* chat number   1;ϵͳ2;����3;˽��4;�л�5;���6;����7;����
---@param self  userdata 
---@param msg  string 
---@param chat number 
---@return boolean   �Ƿ�����˵��
---@nodiscard
function triggerchat(self,msg,chat) end;

---���ò�������
---* actor  userdata  ����
---* attrid  number   ����id
---* char  string   ������ + - =
---* value number   ��Ӧ����ֵ
---@param actor  userdata 
---@param attrid  number 
---@param char  string 
---@param value number 
---@nodiscard
function lib996:setaddattr(actor, attrid, char, value) end;

---��ȡ����˺�
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return string |�ɹ���������˺�|ʧ�ܡ���nil
---@nodiscard
function lib996:getaccount(actor) end;

---�����������
---* mon  userdata  	�������
---@param mon  userdata 
---@return number  1��С�� 2��BOSS 3������(��������) 4��Ӣ�� 5�����ι�
---@nodiscard
function lib996:montype(mon) end;

---�����ͼ�й���
---* mapid   string  	��ͼid
---* monid   number  	����id -1ʱ�������й���
---@param mapid   string 
---@param monid   number 
---@return boolean  true�����ɹ�|false����ʧ��
---@nodiscard
function lib996:removemon(mapid,monid) end;

---ˢ����������
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function lib996:recalcabilitys(actor) end;

---����ǰ����
---* attack  userdata  �����߶���(number)
---* role  userdata  �ܺ��߶���(string)
---* ack  number  �����߱��δ���Ĺ�����
---* def  number  �ܺ��߱����ܻ��ķ�����
---* skillid  number  ����id
---* hurttype  number  �˺�����0�������˺�,1��ħ���˺�
---@param attack  userdata 
---@param role  userdata 
---@param ack  number 
---@param def  number 
---@param skillid  number 
---@param hurttype  number 
---@return number  ���ظ���Ϊ��Ѫ,����Ϊ��Ѫ
---@nodiscard
function on_hurt_pre(attack,role,ack,def,skillid,hurttype) end;

---��װ��ʱ
---* actor  userdata  ����
---* itemid  number   ��Ʒid
---* pos number   λ��
---* itemname string   ��Ʒ����
---* itemmakeid  number   makeid(ΨһID)
---@param actor  userdata 
---@param itemid  number 
---@param pos number 
---@param itemname string 
---@param itemmakeid  number 
---@nodiscard
function on_take_off(actor,itemid,pos,itemname,itemmakeid) end;

---��װ��ʱ
---* actor  userdata  ����
---* itemid  number   ��Ʒid
---* pos number   λ��
---* itemname string   ��Ʒ����
---* itemmakeid  number   makeid(ΨһID)
---@param actor  userdata 
---@param itemid  number 
---@param pos number 
---@param itemname string 
---@param itemmakeid  number 
---@nodiscard
function on_take_on(actor,itemid,pos,itemname,itemmakeid) end;

---���ö�����ʱstr�ͱ���
---* Type  number  ����0:���,1:�л�,2:��ͼ,3����Ʒ,4��NPC,5:����
---* actor  obj  ����=���-���������=�л�-���������=��Ʒ-��makeid����=��ͼ-���ͼID����=NPC-��NPCID����=����-�����
---* sVarName string  ������
---* nValue string  ����ֵ(���8000�ַ�)
---@param Type  number 
---@param actor  obj 
---@param sVarName string 
---@param nValue string 
---@nodiscard
function lib996:settempstr(Type,actor,sVarName,nValue) end;

---��Ʒ���뱳��ʱ
---* actor  userdata  ��Ҷ���
---* itemid  number   ��Ʒid
---* itemmakeid  number    makeid(ΨһID)
---@param actor  userdata 
---@param itemid  number 
---@param itemmakeid  number 
---@nodiscard
function addbag(actor,itemid,itemmakeid) end;

---��ȡ������ʱstr�ͱ���
---* Type  number  ����0:���,1:�л�,2:��ͼ,3����Ʒ,4��NPC,5:����
---* actor  obj  ����=���-���������=�л�-���������=��Ʒ-��makeid����=��ͼ-���ͼID����=NPC-��NPCID����=����-�����
---* sVarName string  ������
---@param Type  number 
---@param actor  obj 
---@param sVarName string 
---@return string | ��������õı���,���δ�����򷵻�nil �� ""
---@nodiscard
function lib996:gettempstr(Type,actor,sVarName) end;

---��ֵ����
---* actor  userdata  ��Ҷ���
---* gold  number   ��ֵrmb���
---* productid number   ��ƷID(ǰ�˵����ֵʱ�򴫵ݵĲ���)
---* moneyid number   ��ֵ��û���ID
---@param actor  userdata 
---@param gold  number 
---@param productid number 
---@param moneyid number 
---@nodiscard
function recharge(actor, gold, productid, moneyid) end;

---����ϵͳ��ʱint�ͱ���
---* sVarName string  ������
---* nValue number  ����ֵ
---* itype number  �������� Ĭ��00:��������1:��������(�ั�������һ��Ϊ׼)2:ȡ��(�ַ��Ͳ�����)3:ȡС(�ַ��Ͳ�����)4:���(�ַ��Ͳ�����)5:����(�����Ͳ�����)6:ɾ��
---@param sVarName string 
---@param nValue number 
---@param itype number 
---@nodiscard
function lib996:setsystempint(sVarName,nValue) end;

---NPC�������
---* actor  userdata  ��Ҷ���
---* npcid  number   npcid
---@param actor  userdata 
---@param npcid  number 
---@nodiscard
function clicknpc(actor, npcid) end;

---��ȡϵͳ��ʱint�ͱ���
---* sVarName string  ������
---@param sVarName string 
---@return number  ��������õı���,���δ�����򷵻�0
---@nodiscard
function lib996:getsystempint(sVarName) end;

---�����ת��ͼ����
---* actor  userdata  ��Ҷ���
---* mapid  string  �����ͼid
---* x  number  �����ͼx
---* y  number  �����ͼy
---@param actor  userdata 
---@param mapid  string 
---@param x  number 
---@param y  number 
---@nodiscard
function entermap(actor,mapid,x,y) end;

---����ϵͳ��ʱstr�ͱ���
---* sVarName string  ������
---* nValue string  ����ֵ
---* itype number  �������� Ĭ��00:��������1:��������(�ั�������һ��Ϊ׼)2:ȡ��(�ַ��Ͳ�����)3:ȡС(�ַ��Ͳ�����)4:���(�ַ��Ͳ�����)5:����(�����Ͳ�����)6:ɾ��
---@param sVarName string 
---@param nValue string 
---@param itype number 
---@nodiscard
function lib996:setsystempstr(sVarName,nValue) end;

---��ȡ����
---* actor  userdata  ��Ҷ���
---* makeid  number  ��ƷΨһid
---* itemname  number  ��Ʒ����
---* itemid  number  ��Ʒid
---@param actor  userdata 
---@param makeid  number 
---@param itemname  number 
---@param itemid  number 
---@nodiscard
function pickupitemex(actor, makeid,itemid,itemmakeid) end;

---��ȡϵͳ��ʱstr�ͱ���
---* sVarName string  ������
---@param sVarName string 
---@return string | ��������õı���,���δ�����򷵻�nil
---@nodiscard
function lib996:getsystempstr(sVarName) end;

---���ܴ���
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function run(actor) end;

---��·����
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function walk(actor) end;

---�ж��Ƿ����״̬
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return boolean   true�����ж���|false����û�ж���
---@nodiscard
function lib996:hasgroup(actor) end;

---����ȫ����ʾ��Ϣ
---* actor  userdata  ����
---* flag  userdata  �Ƿ����0-������1-����
---@param actor  userdata 
---@param flag  userdata 
---@nodiscard
function lib996:filterglobalmsg(actor, flag) end;

---��ȡ�����Ա����
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return number  ��Ա����|��û�ж��鷵��0
---@nodiscard
function lib996:getgroupnum(actor) end;

---������Ʒ�󶨹���
---* makeid  number  ��Ʒmakeindex
---* bind  number  �󶨹���
---@param makeid  number 
---@param bind  number 
---@return booleanean |true�������óɹ�|false��������ʧ��
---@nodiscard
function lib996:setitembind(makeid,bind)  end;

---�ж��Ƿ�Ϊ�Զ��һ�״̬
---* actor  userdata  ����
---@param actor  userdata 
---@return boolean true �һ� |false ���һ�
---@nodiscard
function lib996:isafk(actor) end;

---��ȡ��ͼ���
---* mapid  string   ��ͼid
---@param mapid  string 
---@return ���� number  height = height, width = width
---@nodiscard
function lib996:mapwh(mapid) end;

---�ջ�С����
---* player   userdata  	��Ҷ���
---@param player   userdata 
---@nodiscard
function lib996:releasesprite(player) end;

---���������رտͻ��˴���
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function playoffline(actor) end;

---���Ա仯ʱ����
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function sendability(actor) end;

---����ɫ�߳���Ϸ
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return boolean  true�����ɹ�|false����ʧ��
---@nodiscard
function lib996:getout(actor) end;

---���ǿ�ʼʱ����
---@nodiscard
function castlewarstart() end;

---���ǽ���ʱ����
---@nodiscard
function castlewarend() end;

---ռ��ɳ�Ϳ˴���
---@nodiscard
function getcastle0() end;

---��������ʱ
---@nodiscard
function startup() end;

---��¼ʱ����
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function login(actor) end;

---�л��ʼ��
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function loadguild(actor) end;

---ÿ���һ�ε�¼
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function setday(actor) end;

---����(��Χ)
---*  table  	table  Ŀ��table
---*  x  	number  x
---*  y  	number  y
---*  range  	number  �ݶ� range=0-3, �������Ĺ���
---@param  table  	table 
---@param  x  	number 
---@param  y  	number 
---@param  range  	number 
---@return boolean   �ɹ�����true|ʧ�ܡ���false
---@nodiscard
function lib996:suckmulobj(table, X, Y, range) end;

---����
---*  actor  	userdata  ֧����ҡ������
---*  x  	number  x
---*  y  	number  y
---@param  actor  	userdata 
---@param  x  	number 
---@param  y  	number 
---@return boolean   �ɹ�����true|ʧ�ܡ���false
---@nodiscard
function lib996:suckobj(obj, x, y) end;

---ɾ���ƺ�ʱ����
---* actor  userdata  ��Ҷ���
---* id  number  �ƺ�id
---@param actor  userdata 
---@param id  number 
---@nodiscard
function on_del_title(actor,id) end;

---��ӳƺ�ʱ����
---* actor  userdata  ��Ҷ���
---* id  number  �ƺ�id
---@param actor  userdata 
---@param id  number 
---@nodiscard
function on_add_title(actor,id) end;

---�����ҳƺ�
---* actor  userdata  ��Ҷ���
---* id  number  �ƺ�id
---@param actor  userdata 
---@param id  number 
---@return boolean  true�����ɹ�|false����ʧ��
---@nodiscard
function lib996:addtitle(actor,id) end;

---��̯�۳���Ʒʱ����
---* actor  userdata  ̯��
---* buyer  userdata ����
---* makeinde number  �۳���ƷΨһid
---* ItemId number  �۳���Ʒid
---* moneyid number  ����id
---* moneynum number  ��������
---@param actor  userdata 
---@param buyer  userdata
---@param makeinde number 
---@param ItemId number 
---@param moneyid number 
---@param moneynum number 
---@nodiscard
function on_stall_item(actor,buyer,makeinde,ItemId,moneyid,moneynum) end;

---��ȡ����ʱ��
---@return string |�ɹ�����������ʱռ����л�����|ʧ�ܡ���0
---@nodiscard
function lib996:castlestart() end;

---�жϹ���ս�Ƿ���
---@return boolean  true������ʼ|false����δ��ʼ
---@nodiscard
function lib996:iscastlewar() end;

---��ȡɳ�Ϳ˵�ӵ�����л�
---@return string |�ɹ���������ӵ�����л�����|ʧ�ܡ���nil
---@nodiscard
function lib996:getcastleownguild() end;

---����ɳ�Ϳ˵�ӵ�����л�
---* guiid  string   �л�idΪ"-1":string ʱ���
---@param guiid  string 
---@nodiscard
function lib996:setcastleownguild(guiid) end;

---�������֮ǰ
---* actor  userdata  ��Ҷ���
---* killer  userdata  ���ֶ���
---@param actor  userdata 
---@param killer  userdata 
---@nodiscard
function nextdie(actor) end;

---��Ӽƻ�����
---* id  number  ����ƻ�id,�����ظ�
---* name  string  ����ƻ�����
---* itype  number  0:ָ��ʱ��1:ÿ��ִ��2:ÿ��ִ��3:ÿ��ִ��
---* stringtime  string  ʱ��� ��ϸ��ʾ�� ��ʱ��#ƴ��
---* stringfun  string  �ص�����
---* param  string  �Զ������,�����#ƴ��
---@param id  number 
---@param name  string 
---@param itype  number 
---@param stringtime  string 
---@param stringfun  string 
---@param param  string 
---@return boolean   true����ӳɹ� | false�����ʧ��
---@nodiscard
function lib996:addscheduled(id,name,itype,strtime,strfun,param) end;

---�жϼƻ������Ƿ����
---* id  number  ����ƻ�id,�����ظ�
---@param id  number 
---@return boolean   true������ | false��������
---@nodiscard
function lib996:hasscheduled(id) end;

---ͨ����ƷΨһid������Ʒ
---* actor  userdata  ��Ҷ���
---* ids  number   	��ƷΨһID(makeindex)����(,)����
---* count number   	������Ʒ�۳�����,����˲���,Ĭ��ȫ���۳�,���ɵ�����Ʒȫ���۳�
---@param actor  userdata 
---@param ids  number 
---@param count number 
---@nodiscard
function lib996:delitembymakeindex(actor,ids,count) end;

---ɾ���ƻ�����
---* id  number  ����ƻ�id,�����ظ�
---@param id  number 
---@nodiscard
function lib996:delscheduled(id) end;

---ʹ����Ʒ(��ҩ��ʹ��������Ʒ��)
---* actor  userdata  ��Ҷ���
---* itemname  string   ��Ʒ����
---* count number   ����
---@param actor  userdata 
---@param itemname  string 
---@param count number 
---@nodiscard
function lib996:eatitem(actor,itemname,count) end;

---�������ʱ
---* actor  userdata  ��Ҷ���
---* player  userdata  ���ֶ���
---@param actor  userdata 
---@param player  userdata 
---@nodiscard
function playdie(actor) end;

---���дʻ���
---* string   string  Ҫ�����ı�
---* result1   boolean  true�������д�
---* result2   string  ���д�
---@param string   string 
---@param result1   boolean 
---@param result2   string 
---@return boolean
---@nodiscard
function lib996:exisitssensitiveword(str, result1, result2) end;

---���︴��ʱ
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function revival(actor) end;

---��ȡ�ͷż�������Ҫ��MP
---* actor  userdata  ��Ҷ���
---* magicid  number  magicid����ID
---@param actor  userdata 
---@param magicid  number 
---@return number--����mp | ��Ҳ����ڻ�������������(����Ӣ�ۡ����͹�),����nil|��Ҷ���δѧϰ�˼���,����nil
---@nodiscard
function lib996:getskillmp(actor, magicid) end;

---����С�˴���
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function playreconnection(actor) end;

---�������ָ���ɫ
---* mon  userdata  �������
---* ColorID  number  ��ɫid
---@param mon  userdata 
---@param ColorID  number 
---@nodiscard
function lib996:changemonnamecolor(mon, ColorID) end;

---��Ҹ�����
---* actor  userdata  ��Ҷ���
---* oname  string  ������
---* nname  string  ������
---@param actor  userdata 
---@param oname  string 
---@param nname  string 
---@nodiscard
function changehumnameok(actor) end;

---���ݹ�������ɱ������
---* mapid  string  	��ͼid
---* monname  string  ����ȫ��,nilʱ ɱ��ȫ��
---* count number  	����,0����
---* drop boolean  	�Ƿ������Ʒ,true����
---@param mapid  string 
---@param monname  string 
---@param count number 
---@param drop boolean 
---@nodiscard
function lib996:killmonsters(mapid,monname,count,drop) end;

---�����ѱ䴥��
---* actor  userdata  ��Ҷ���
---* mon  userdata  ��������
---* monname  string ��������
---@param actor  userdata 
---@param mon  userdata 
---@param monname  string
---@nodiscard
function mobtreachery(actor, mon, monname) end;

---���ݹ������ɱ������
---* actor  userdata  ��ɱ�߶���
---* mon  userdata  �������
---* drop boolean  �Ƿ������Ʒ,true����
---* trigger boolean  �Ƿ񴥷�killmon
---* showdie boolean  �Ƿ���ʾ��������
---@param actor  userdata 
---@param mon  userdata 
---@param drop boolean 
---@param trigger boolean 
---@param showdie boolean 
---@nodiscard
function lib996:killmonbyobj(actor,mon,drop,trigger,showdie) end;

---�뿪��ͼʱ
---* actor  userdata  ��Ҷ���
---* mapid  string  �뿪�ĵ�ͼid
---* x  number  �뿪��ͼx
---* y  number  �뿪��ͼy
---@param actor  userdata 
---@param mapid  string 
---@param x  number 
---@param y  number 
---@nodiscard
function leavemap(actor,mapid,x,y) end;

---ɱ����Ʒ�ٱ�
---* actor  userdata  ��Ҷ���
---* count  number  ������Ʒ�������Ӵ���
---@param actor  userdata 
---@param count  number 
---@nodiscard
function lib996:monitems(actor,count) end;

---�ѹ������óɱ���
---* mon  userdata  �������
---* player  userdata  ��Ҷ���
---* itime  number  �ѱ�ʱ�� Ĭ������,��λ�� M2�п��������ѱ�����
---@param mon  userdata 
---@param player  userdata 
---@param itime  number 
---@nodiscard
function lib996:setmonmaster(mon,player,itime) end;

---ɾ���Զ�����﹥������
---* custommon  userdata  �Զ���������
---* attackId  number  ��������id(��cfg_monattack��)
---@param custommon  userdata 
---@param attackId  number 
---@return booleanea | �ɹ�����true|ʧ�ܡ���false
---@nodiscard
function lib996:delmonattack(custommon, attackId) end;

---����Զ�����﹥������
---* custommon  userdata  �Զ���������
---* attackId  number  ��������id(��cfg_monattack��)
---@param custommon  userdata 
---@param attackId  number 
---@return booleanea | �ɹ�����true|ʧ�ܡ���false
---@nodiscard
function lib996:addmonattack(custommon, attackId) end;

---�ж��Զ�������Ƿ��иù�������
---* custommon  userdata  �Զ���������
---* attackId  number  ��������id(��cfg_monattack��)
---@param custommon  userdata 
---@param attackId  number 
---@return booleanea | �ɹ�����true|ʧ�ܡ���false
---@nodiscard
function lib996:monhasattack(custommon, attackId) end;

---�ж϶����Ƿ�ɱ�����
---*  actor  	userdata  ������
---*  role  	userdata  ��������
---@param  actor  	userdata 
---@param  role  	userdata 
---@return boolean   true���� | false����
---@nodiscard
function lib996:canattack(actor,role)  end;

---��װ��ǰ
---* actor  userdata  ����
---* itemid  number   ��Ʒid
---* pos number   λ��
---* itemname string   ��Ʒ����
---* itemmakeid  number   makeid(ΨһID)
---@param actor  userdata 
---@param itemid  number 
---@param pos number 
---@param itemname string 
---@param itemmakeid  number 
---@return boolean  true������������|false������
---@nodiscard
function on_take_off_pre(actor,itemid,pos,itemname,itemmakeid) end;

---�������������Ʒǰ����
---* actor  userdata  ��Ҷ���
---* makeid  number  ��ƷΨһid
---* itemid  number  ��Ʒid
---@param actor  userdata 
---@param makeid  number 
---@param itemid  number 
---@return boolean   true�������� false����������
---@nodiscard
function itemdropfrombagbefore(actor,makeid,itemid) end;

---�������Ʒǰ����
---* actor  userdata  ��Ҷ���
---* makeid  number  ��ƷΨһid
---* itemid  number  ��Ʒid
---@param actor  userdata 
---@param makeid  number 
---@param itemid  number 
---@return boolean   true�������� false����������
---@nodiscard
function itemthrowfrombagbefore(actor,makeid,itemid) end;

---����仯ʱ
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function changetask(actor) end;

---����ɾ��ʱ
---* actor  userdata  ��Ҷ���
---* id  number  ����id
---@param actor  userdata 
---@param id  number 
---@nodiscard
function deletetask(actor, id) end;

---���������б�
---* actor  userdata  ��Ҷ���
---* nIndex  number  ����(0��ʼ)
---@param actor  userdata 
---@param nIndex  number 
---@return userdata | �������
---@nodiscard
function lib996:getslavebyindex(actor,nIndex) end;

---�޸ı�������
---* mob  userdata  ��������(����������)
---* name  userdata  ����������
---@param mob  userdata 
---@param name  userdata 
---@nodiscard
function lib996:changemonname(mob,name) end;

---��ȡǰ����
---* actor  userdata  ��Ҷ���
---* makeid  number  ��ƷΨһid
---* itemid  number  ��Ʒid
---* itemx  number  ��Ʒx����
---* itemy  number  ��Ʒy����
---@param actor  userdata 
---@param makeid  number 
---@param itemid  number 
---@param itemx  number 
---@param itemy  number 
---@return boolean   true������ʰȡ false��������ʰȡ
---@nodiscard
function pickupitemfrontex(actor, makeid,itemid,x,y) end;

---��ȡ��Ʒ��ǰ�;ö�
---* actor  userdata  ��Ҷ���
---* makeindex  number   ��ƷΨһid
---@param actor  userdata 
---@param makeindex  number 
---@return number  ����װ��ʣ���;ö�
---@nodiscard
function lib996:getdura(actor,makeindex) end;

---������ҵ�ǰչʾ�ƺ�
---* actor  userdata  ��Ҷ���
---* id  number  �ƺ�id
---@param actor  userdata 
---@param id  number 
---@return boolean  true�����ɹ�|false����ʧ��
---@nodiscard
function lib996:setcurtitle(actor,id) end;

---�޸���Ʒ��ǰ�;ö�
---* actor  userdata  ��Ҷ���
---* makeindex  number   ��ƷΨһid
---* ope  string   ����� "+" "-"  "="
---* value  number   �޸ĵ��;�ֵ
---@param actor  userdata 
---@param makeindex  number 
---@param ope  string 
---@param value  number 
---@nodiscard
function lib996:setdura(actor,makeindex,ope,value) end;

---�޸ı����ȼ�
---* play  userdata  	��Ҷ���
---* mon  userdata  	��������
---* operate string  ��������(+,-,=)
---* nLevel number  	�ȼ�
---@param play  userdata 
---@param mon  userdata 
---@param operate string 
---@param nLevel number 
---@nodiscard
function lib996:changeslavelevel(play,mon,operate,nLevel) end;

---ɾ����ҳƺ�
---* actor  userdata  ��Ҷ���
---* id  number  �ƺ�id
---@param actor  userdata 
---@param id  number 
---@return boolean  true�����ɹ�|false����ʧ��
---@nodiscard
function lib996:deltitle(actor,id) end;

---����makeId���ع������
---* mapid  string  	��ͼid
---* monUserId  string  	����makeId(Ψһid)
---@param mapid  string 
---@param monUserId  string 
---@return userdata | ���ع������
---@nodiscard
function lib996:getmonbyuserid(mapid,monUserId) end;

---���������л����
---@return table | ���������л����
---@nodiscard
function lib996:getallguild() end;

---���ݹ���id���ع��������Ϣ
---* idx  userdata  �����IDX
---* id  string  id
---@param idx  userdata 
---@param id  string 
---@nodiscard
function lib996:getmonbaseinfo(idx,id) end;

---ָ���������ָ���л�
---* actor  userdata  ָ������Ҷ���
---* guiname  number  Ҫ������л�����
---@param actor  userdata 
---@param guiname  number 
---@return boolean   true���ɹ� | false��ʧ��
---@nodiscard
function lib996:addguildmember(actor,guiname) end;

---��ⷶΧ�ڹ�������
---* mapid  string  	��ͼid
---* monName  string  ��������,nil ������й�
---* nx number  	����X
---* ny number  ����Y
---* nRange number  ��Χ
---@param mapid  string 
---@param monName  string 
---@param nx number 
---@param ny number 
---@param nRange number 
---@return number  ,����
---@nodiscard
function lib996:checkrangemoncount(mapid,monName,nx,ny,nRange) end;

---�߳�ָ�����л��Ա
---* actor  userdata  Ҫ�߳���Ҷ���
---* guiname  number  �л�����
---@param actor  userdata 
---@param guiname  number 
---@return boolean   true���ɹ� | false��ʧ��
---@nodiscard
function lib996:delguildmember(actor,guiname) end;

---�ٻ�ʰȡС����
---* player  userdata  ��Ҷ���
---* monname  string  ��������
---@param player  userdata 
---@param monname  string 
---@nodiscard
function lib996:createsprite(player,monname) end;

---���þ����ͼʣ��ʱ��
---* MapId  string  �����ͼID
---* time  number  ʣ��ʱ��
---@param MapId  string 
---@param time  number 
---@nodiscard
function lib996:setmaptime(MapId,time) end;

---utf-8תgbk
---* string   string  utf-8
---@param string   string 
---@return string | ���� ת����ַ�
---@nodiscard
function lib996:utf8togbk(str) end;

---���ʰȡС����
---* player  userdata  ��Ҷ���
---* monname  string  ��������,Ϊnil ����ȫ��
---@param player  userdata 
---@param monname  string 
---@nodiscard
function lib996:checkspritelevel(player,monname) end;

---gbkתutf-8
---* string   string  gbk
---@param string   string 
---@return string | ���� ת����ַ�
---@nodiscard
function lib996:gbktoutf8(str) end;

---��ȡ���ip
---* actor  userdata  ����
---@param actor  userdata 
---@return �ɹ�:string | ʧ��nil
---@nodiscard
function lib996:getip(actor) end;

---���˿�ʼ�Զ�ս��ʱ
---* actor  userdata  ���˶���
---@param actor  userdata 
---@nodiscard
function on_dum_in_fight(actor) end;

---���˽����Զ�ս��ʱ
---* actor  userdata  ���˶���
---@param actor  userdata 
---@nodiscard
function on_dum_out_fight(actor) end;

---�ٻ�����ʱ����
---* actor  userdata  �ٻ��߶���
---* owner  userdata  ���˶���
---* mon  userdata  �������
---@param actor  userdata 
---@param owner  userdata 
---@param mon  userdata 
---@nodiscard
function slavebb(actor, owner, mon) end;

---���ޱ���ʱ����
---* actor  userdata  ���˶���
---* actor  userdata  ��������
---* actor  string  ����ǰ����
---* actor  string  ���������
---@param actor  userdata 
---@param actor  userdata 
---@param actor  string 
---@param actor  string 
---@nodiscard
function on_mythmon_transform(actor,mon,aname,bname) end;

---���ǰ����
---* actor  userdata  ��Ҷ�����ӳ���ͬһ��
---@param actor  userdata 
---@return boolean  true��������|false������
---@nodiscard
function startgroup(actor) end;

---�鿴����װ��ʱ
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function lookhuminfo(actor) end;

---Ӣ������ʱ
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function herodie(actor) end;

---Ӣ�۸���ʱ
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function herorevival(actor) end;

---ע�������index
---* idx  number  ��������QF:999999999,QM:999999996
---* scriptfile  string  �ļ�·��
---@param idx  number 
---@param scriptfile  string 
---@nodiscard
function lib996:setsysindex(idx,scriptfile) end;

---��ȡ�����ͼʣ��ʱ��
---* MapId  string  �����ͼID
---@param MapId  string 
---@return number  ʣ��ʱ��
---@nodiscard
function lib996:getmaptime(MapId) end;

---�ж϶����Ƿ�Ϊ���
---* actor  userdata  ����
---@param actor  userdata 
---@return boolean   true������� | false���������
---@nodiscard
function lib996:isplayer(actor) end;

---�ж϶����Ƿ�����
---* actor  userdata  ����
---@param actor  userdata 
---@return boolean   true������ | false�����
---@nodiscard
function lib996:isdeath(actor) end;

---ʰȡģʽ
---* player  userdata  ��Ҷ���
---* mode  number  ģʽ(0=������Ϊ���ļ�ȡ,1=��С����Ϊ���ļ�ȡ)
---* Range  number  ��Χ(1-10)
---* numbererval  number  ���,��С500ms
---@param player  userdata 
---@param mode  number 
---@param Range  number 
---@param numbererval  number 
---@nodiscard
function lib996:pickupitems(player,mode,Range,interval) end;

---��ȡ��������
---* actor  userdata  ����
---@param actor  userdata 
---@return string | ���ض�������
---@nodiscard
function lib996:getname(actor) end;

---�ر�ʰȡģʽ
---* player  userdata  ��Ҷ���
---@param player  userdata 
---@nodiscard
function lib996:stoppickupitems(player) end;

---��ȡ���Ψһid
---* actor  userdata  ��Ҷ���,�������
---@param actor  userdata 
---@return string | ������Ҷ���Ψһid
---@nodiscard
function lib996:getuserid(actor) end;

---�����������Զ�������
---* actor  userdata  ��Ҷ���
---* makeid  number   ����makeindex(Ψһid)
---* type number   ������
---* attid number   ����id
---* attvar number   ����ֵ
---@param actor  userdata 
---@param makeid  number 
---@param type number 
---@param attid number 
---@param attvar number 
---@nodiscard
function lib996:additemattr(actor,makeid,type,attid,attvar) end;

---��ָ��λ�����ȴ�ָ�����
---* player  userdata  ��Ҷ���
---* map  string  	��ͼ
---* X  string  X����
---* Y  string  	Y����
---* MonName  string  ���ȹ����Ĺ�������MonName֧�ֶ����������,���������� # ƴ��
---@param player  userdata 
---@param map  string 
---@param X  string 
---@param Y  string 
---@param MonName  string 
---@nodiscard
function lib996:killmobappoint(player,map,X,Y,MonName) end;

---��ȡ�������ڵĵ�ͼid
---* actor  userdata  ����
---@param actor  userdata 
---@return string | ���ص�ͼid
---@nodiscard
function lib996:getmapid(actor) end;

---ɾ�������Զ�������
---* actor  userdata  ��Ҷ���
---* makeid  number   ����makeindex(Ψһid)
---* type number   ������
---* attid number   ����id(Ϊ0ʱ���������������)
---@param actor  userdata 
---@param makeid  number 
---@param type number 
---@param attid number 
---@return boolean   true���ɹ� | false��ʧ��
---@nodiscard
function lib996:delitemattr(actor,makeid,type,attid) end;

---���ñ��ֵ
---* obj  userdata  ����������
---* index  string  �±�ID(0-9)
---* value  string  ���ֵ
---@param obj  userdata 
---@param index  string 
---@param value  string 
---@nodiscard
function lib996:setcurrent(
    obj,
    index,
	value
) end;

---�޸���������
---* actor  userdata  ��Ҷ���
---* name  string   Ҫ�޸ĵ�����
---@param actor  userdata 
---@param name  string 
---@return number  0-����ʹ�� 1��2��6-���Ʊ����� 3-�����Ѿ����� 5-���Ȳ�����Ҫ��
---@nodiscard
function lib996:changehumname(actor,name) end;

---��ȡ��ɫ����
---* actor  userdata  ��Ҷ���,����������
---* attid  number   ����id
---@param actor  userdata 
---@param attid  number 
---@return number  ����ֵ
---@nodiscard
function lib996:attr(actor,attid) end;

---��ȡ��ҵ�ǰ�ȼ�
---* actor  userdata  ��Ҷ���,��������
---@param actor  userdata 
---@return number  ��ҵ�ǰ�ȼ�
---@nodiscard
function lib996:getlevel(actor) end;

---��ȡ������ʱ����
---* actor  userdata  ��Ҷ���
---* nWhere  number  λ�� ��Ӧcfg_att_score ����ID
---@param actor  userdata 
---@param nWhere  number 
---@return number  ��Ӧ����ֵ
---@nodiscard
function lib996:gethumnewvalue(actor,nWhere) end;

---��ȡ����Ա�
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return number  ����Ա�
---@nodiscard
function lib996:getsex(actor) end;

---��ʱ���ӹ��ﱬ����Ʒ
---* obj  userdata  ����������
---* mon  userdata  �������
---* itemname  string  ��Ʒ����
---@param obj  userdata 
---@param mon  userdata 
---@param itemname  string 
---@nodiscard
function lib996:additemtodroplist(obj,mon,itemname) end;

---��ȡ����int�ͱ���
---* Type  number  ����0:���,1:�л�,2:��ͼ,3����Ʒ,4��NPC,5:����
---* actor  obj  ����=���-���������=�л�-���������=��Ʒ-��makeid����=��ͼ-���ͼID����=NPC-��NPCID����=����-�����
---* sVarName string  ������
---@param Type  number 
---@param actor  obj 
---@param sVarName string 
---@return number  ��������õı���,���δ�����򷵻�0
---@nodiscard
function lib996:getint(Type,actor,sVarName) end;

---��ȡ����xy����
---* actor  userdata  ����
---@param actor  userdata 
---@return number  1��x���� | 2��y����
---@nodiscard
function lib996:getxy(actor) end;

---�����л�
---* player  userdata  ��Ҷ���
---* name  string  	�л���
---@param player  userdata 
---@param name  string 
---@nodiscard
function lib996:buildguild(player,name) end;

---���ö���int�ͱ���
---* Type  number  ����0:���,1:�л�,2:��ͼ,3����Ʒ,4��NPC,5:����
---* actor  obj  ����=���-���������=�л�-���������=��Ʒ-��makeid����=��ͼ-���ͼID����=NPC-��NPCID����=����-�����
---* sVarName string  ������
---* nValue number  ����ֵ
---@param Type  number 
---@param actor  obj 
---@param sVarName string 
---@param nValue number 
---@nodiscard
function lib996:setint(Type,actor,sVarName,nValue) end;

---�޸�������ʱ����(����Ч��)
---* actor  userdata  ��Ҷ���
---* nWhere  number  λ�� ��Ӧcfg_att_score ����ID
---* nValue number  ��Ӧ����ֵ
---* nTime  number  ��Чʱ��,��
---@param actor  userdata 
---@param nWhere  number 
---@param nValue number 
---@param nTime  number 
---@nodiscard
function lib996:changehumnewvalue(actor,nWhere,nValue,nTime) end;

---��ȡ���ְҵ
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return number  ���ְҵ
---@nodiscard
function lib996:getjob(actor) end;

---�����л�
---* player  userdata  ��Ҷ���
---* name  string  	�л���
---@param player  userdata 
---@param name  string 
---@nodiscard
function lib996:guildaddmember(player,name) end;

---��ȡ����str�ͱ���
---* Type  number  ����0:���,1:�л�,2:��ͼ,3����Ʒ,4��NPC,5:����
---* actor  obj  ����=���-���������=�л�-���������=��Ʒ-��makeid����=��ͼ-���ͼID����=NPC-��NPCID����=����-�����
---* sVarName string  ������
---@param Type  number 
---@param actor  obj 
---@param sVarName string 
---@return string | ��������õı���,���δ�����򷵻�nil �� ""
---@nodiscard
function lib996:getstr(Type,actor,sVarName) end;

---ɾ��ħ����
---* actor userdata   ��Ҷ���
---@param actor userdata 
---@return boolean   �ɹ�����true|ʧ�ܡ�������false
---@nodiscard
function lib996:delams(actor) end;

---�˳��л�
---* player  userdata  ��Ҷ���
---* name  string  	�л���
---@param player  userdata 
---@param name  string 
---@nodiscard
function lib996:guilddelmember(player,name) end;

---���ö���str�ͱ���
---* Type  number  ����0:���,1:�л�,2:��ͼ,3����Ʒ,4��NPC,5:����
---* actor  obj  ����=���-���������=�л�-���������=��Ʒ-��makeid����=��ͼ-���ͼID����=NPC-��NPCID����=����-�����
---* sVarName string  ������
---* nValue string  ����ֵ(���8000�ַ�)
---@param Type  number 
---@param actor  obj 
---@param sVarName string 
---@param nValue string 
---@nodiscard
function lib996:setstr(Type,actor,sVarName,nValue) end;

---�Ƿ�ӵ��ħ����
---* actor userdata   ��Ҷ���
---@param actor userdata 
---@return boolean   true������|false����û��
---@nodiscard
function lib996:hasams(actor) end;

---�������ﾭ��ֵ
---@nodiscard
function lib996:changeexp(actor,char,count,addexp) end;

---��ɢ�л�
---* player  userdata  ��Ҷ���
---@param player  userdata 
---@nodiscard
function lib996:guildclosebefore(player) end;

---��������ȼ�
---* actor  userdata  ��Ҷ���
---* char  string   ������ + - =
---* count string   ����
---@param actor  userdata 
---@param char  string 
---@param count string 
---@nodiscard
function lib996:changelevel(actor,char,count) end;

---ǿ�ƿ���/�رչ���
---* data  number  	1-���̹���,0-���̽�������
---@param data  number 
---@nodiscard
function lib996:castlewarnow(data) end;

---�����ͼ��ת����תǰ
---* actor  userdata  ��Ҷ���
---* map  string  mapid
---* x  number  λ��x
---* y  number  λ��y
---* jumpMap  string  Ҫ��ת�ĵ�ͼid
---@param actor  userdata 
---@param map  string 
---@param x  number 
---@param y  number 
---@param jumpMap  string 
---@nodiscard
function on_route_pre(actor, map, x, y, jumpMap) end;

---����buff�ѵ�����
---* actor  userdata ����
---* buff  number buffid
---* opt  string ������ "+" "-" "="
---* stack  number buff���� ���ɳ�������������
---* itimer  boolean �Ƿ�����buff ʱ��
---@param actor  userdata
---@param buff  number
---@param opt  string
---@param stack  number
---@param itimer  boolean
---@return boolean  true�����ɹ�|false����ʧ��
---@nodiscard
function lib996:buffstack(actor,buff,opt,stack,itimer) end;

---�����л�ǰ����
---* actor  userdata  ��Ҷ���
---* name  string  �л���
---@param actor  userdata 
---@param name  string 
---@return boolean  true����������|false������ֹ����
---@nodiscard
function on_build_guild_pre(actor,name) end;

---�����л�ʱ����
---* actor  userdata  ��Ҷ���
---* name  string  �л����
---@param actor  userdata 
---@param name  string 
---@nodiscard
function buildguild(actor,name) end;

---��ʼ���˰�̯
---* actor  userdata  ���˶���
---* stallname  string  ̯λ����
---* pricetab  json  ̯λ��Ʒ�б�  �ο�ʾ��
---@param actor  userdata 
---@param stallname  string 
---@param pricetab  json 
---@return boolean   true�����ɹ�|false����ʧ��
---@nodiscard
function lib996:dumstartstall(actor,stallname,pricetab) end;

---�˳��л�ǰ����
---* actor  userdata  ��Ҷ���
---* name  string  �л���
---@param actor  userdata 
---@param name  string 
---@return boolean  true���������˳�|false������ֹ�˳�
---@nodiscard
function on_out_guild_pre(actor,name) end;

---��ȡ����ǰHP
---* actor  userdata  ����
---@param actor  userdata 
---@return number  ���ص�ǰ����Ѫ��
---@nodiscard
function lib996:gethp(actor) end;

---��ȡ����ǰMP
---* actor  userdata  ����
---@param actor  userdata 
---@return number  ���ص�ǰ��������
---@nodiscard
function lib996:getmp(actor) end;

---��ȡϵͳint�ͱ���
---* sVarName string  ������
---@param sVarName string 
---@return number  ��������õı���,���δ�����򷵻�0
---@nodiscard
function lib996:getsysint(sVarName) end;

---��ȡ��ҵ�ǰ����ֵ
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return number  ��ҵ�ǰ����
---@nodiscard
function lib996:getexp(actor) end;

---��ȡ���������л��Ա����
---* player  userdata  ��Ҷ���
---@param player  userdata 
---@return number  | ���������л��Ա����
---@nodiscard
function lib996:getguildmembercount(player) end;

---����ϵͳint�ͱ���
---* sVarName string  ������
---* nValue number  ����ֵ
---* itype number  �������� Ĭ��00:��������1:��������(�ั�������һ��Ϊ׼)2:ȡ��(�ַ��Ͳ�����)3:ȡС(�ַ��Ͳ�����)4:���(�ַ��Ͳ�����)5:����(�����Ͳ�����)6:ɾ��
---@param sVarName string 
---@param nValue number 
---@param itype number 
---@nodiscard
function lib996:setsysint(sVarName,nValue) end;

---��������
---* actor  userdata  ��Ҷ���
---* where  number   λ�� 0-9
---* effType number   	����Ч��(0ͼƬ���� 1��ЧID)
---* resName string  	ͼƬ��������ЧID
---* x number   X���� (Ϊ��ʱĬ��X=0)
---* y number   Y���� (Ϊ��ʱĬ��Y=0)
---* autoDrop number  �Զ���ȫ�հ�λ��0,1(0=�� 1=����)
---* selfSee number   �Ƿ�ֻ���Լ�����(0=�����˶��ɼ� 1=�����Լ��ɼ�)
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

---��ȡ���ת���ȼ�
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return number  ���ת���ȼ�
---@nodiscard
function lib996:getrelevel(actor) end;

---��ȡϵͳstr�ͱ���
---* sVarName string  ������
---@param sVarName string 
---@return string | ��������õı���,���δ�����򷵻�nil
---@nodiscard
function lib996:getsysstr(sVarName) end;

---���������ϲ�����Ч
---* actor  userdata  ��Ҷ����������
---* effectid  number   ��ЧID
---* offsetX number  ���������ƫ�Ƶ�X����
---* offsetY number  ���������ƫ�Ƶ�Y����
---* times number  ���Ŵ���--0-һֱ����
---* behind number  ����ģʽ-0-ǰ��-1-����
---* selfshow number  �ɼ�����0:��,��Ұ�ھ��ɼ�1:��,���Լ��ɼ�
---* dir number  0�����������﷽��ı�1���������﷽��ı�
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

---��ȡ��ұ�����������
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return number  ��ұ�����������
---@nodiscard
function lib996:getbagsize(actor) end;

---���л���ӵ������б�
---* name  string  �л���
---* day  number  	����
---@param name  string 
---@param day  number 
---@nodiscard
function lib996:addtocastlewarlistex(name,day) end;

---����ϵͳstr�ͱ���
---* sVarName string  ������
---* nValue string  ����ֵ
---* itype number  �������� Ĭ��00:��������1:��������(�ั�������һ��Ϊ׼)2:ȡ��(�ַ��Ͳ�����)3:ȡС(�ַ��Ͳ�����)4:���(�ַ��Ͳ�����)5:����(�����Ͳ�����)6:ɾ��
---@param sVarName string 
---@param nValue string 
---@param itype number 
---@nodiscard
function lib996:setsysstr(sVarName,nValue) end;

---���ת�����ַ���
---* tab  table  Ҫת���ı��
---* isfilter  boolean  �Ƿ����Υ���� Ĭ��Ϊtrue
---@param tab  table 
---@param isfilter  boolean 
---@return string | �����ַ���
---@nodiscard
function lib996:tbl2json(tab,isfilter) end;

---����������ϲ��ŵ���Ч
---* actor  userdata  ��Ҷ����������
---* effectid  number   ��ЧID
---@param actor  userdata 
---@param effectid  number 
---@nodiscard
function lib996:clearplayeffect(actor,effectid) end;

---�ж���Ҷ����Ƿ�Ϊ�л�᳤
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return boolean   true���ǻ᳤ | false�����ǻ᳤
---@nodiscard
function lib996:isguildmaster(actor) end;

---�����л��ڵ���ͬʱ����
---@nodiscard
function lib996:addattacksabakall() end;

---�ַ���ת���ɱ��
---* string  string  Ҫת�����ַ���
---* isfilter  boolean  �Ƿ����Υ���� Ĭ��Ϊtrue
---@param string  string 
---@param isfilter  boolean 
---@return table | ����table
---@nodiscard
function lib996:json2tbl(str,isfilter) end;

---��������lua���������
---* actor  userdata  ��Ҷ���
---* idx  number  npcidQF:999999999,QM:999999996
---* time  INT  �ӳ�ʱ��ms,0����ִ��
---* stringfun  string  ������
---* param  string  ����
---@param actor  userdata 
---@param idx  number 
---@param time  INT 
---@param stringfun  string 
---@param param  string 
---@nodiscard
function lib996:callfunbynpc(actor,idx,time,strfun,param) end;

---�޸����ﵱǰѪ��
---* actor  userdata  ����
---* char  string   ������ + - =
---* nvalue string   Ѫ��
---* effid boolean   �ز�ID,-1ʱ��Ʈ��
---* host userdata  �˺���Դ����
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

---��ȡ������ڵ��л����
---* player  userdata  ��Ҷ���
---@param player  userdata 
---@return userdata | �����л����
---@nodiscard
function lib996:getmyguild(player) end;

---��ȡ��ǰʱ��
---@return table | ��ǰʱ��� ��.��.�� ʱ.��.��.��
---@nodiscard
function lib996:gettime() end;

---�޸����ﵱǰ����
---* actor  userdata  ����
---* char  string   ������ + - =
---* nvalue string   ����
---@param actor  userdata 
---@param char  string 
---@param nvalue string 
---@nodiscard
function lib996:humanmp(actor,char,nvalue) end;

---�����л�
---* index  number  0:�л�ID1:�л�����
---* key  string  �����ؼ���
---@param index  number 
---@param key  string 
---@return userdata | �л����
---@nodiscard
function lib996:findguild(index,key) end;

---��ȡ�л���Ϣ
---* guild  number  �л����
---* index  number  	����
---@param guild  number 
---@param index  number 
---@return string | ��Ӧ�����ṹ
---@nodiscard
function lib996:getguildinfo(guild,index) end;

---��������
---* actor  userdata  ��Ҷ�����ӳ���ͬһ��
---@param actor  userdata 
---@nodiscard
function groupcreate(actor) end;

---�޸�����������ɫ
---* actor  userdata  ��Ҷ���
---* color  number  996m2 ��ɫ�б�
---@param actor  userdata 
---@param color  number 
---@nodiscard
function lib996:changenamecolor(actor,color) end;

---��ѯ�������
---* actor  userdata  ��Ҷ���
---* id  number   ����ID(1-100)
---@param actor  userdata 
---@param id  number 
---@return number  ��Ӧ�Ļ�������
---@nodiscard
function lib996:querymoney(actor,id) end;

---�����л���Ϣ
---* guild  userdata  �л����
---* index  number  ����
---* value  string  Ҫ���õ�����
---@param guild  userdata 
---@param index  number 
---@param value  string 
---@nodiscard
function lib996:setguildinfo(guild,index,value) end;

---�뿪����
---* actor  userdata  ��Ҷ���
---* groupOwner  userdata  �ӳ���Ҷ���
---@param actor  userdata 
---@param groupOwner  userdata 
---@nodiscard
function leavegroup(actor,groupOwner) end;

---��ȡ����ͨ�û�������(����Ҽ���)
---* actor  userdata  ��Ҷ���
---* moneyname  string  ��������
---@param actor  userdata 
---@param moneyname  string
---@return number  ��Ӧ�Ļ���ֵ
---@nodiscard
function lib996:getbindmoney(actor,moneyname) end;

---�����������
---* actor  userdata  ��Ҷ���
---* id  number   ����ID(1-100)
---* opt  string   ������ + - =
---* count  number   ����
---* msg  string   ��ע����
---* send  boolean   �Ƿ�����ˢ��
---@param actor  userdata 
---@param id  number 
---@param opt  string 
---@param count  number 
---@param msg  string 
---@param send  boolean 
---@return boolean   ture���ɹ�,false��ʧ��
---@nodiscard
function lib996:changemoney(actor,id,opt,count,msg,send) end;

---��������
---* player  userdata  ��Ҷ���
---@param player  userdata 
---@nodiscard
function lib996:creategroup(player) end;

---�߳�����
---* actor  userdata  ��Ҷ���
---* delPlayer  userdata  �߳�����
---@param actor  userdata 
---@param delPlayer  userdata 
---@nodiscard
function groupdelmember(actor) end;

---ǿ�Ʊ�����Ϸ����
---@nodiscard
function lib996:forcesaveplayerdata() end;

---�۳�����ͨ�û�������(��������μ���)
---* actor  userdata  ��Ҷ���
---* moneyname  string  ��������
---* count number   ��Ӧ����ֵ
---@param actor  userdata 
---@param moneyname  string
---@param count number 
---@nodiscard
function lib996:consumebindmoney(
    actor,
    moneyname,
    count
) end;

---��Ӷ�Ա
---* player  userdata  ��Ҷ���
---* memberId  string  	��ԱUserId(Ψһid)
---@param player  userdata 
---@param memberId  string 
---@nodiscard
function lib996:addgroupmember(player,memberId) end;

---����������ɹ�ʱ
---* actor  userdata  ��Ҷ���
---* addPlayer  userdata  �������
---@param actor  userdata 
---@param addPlayer  userdata 
---@nodiscard
function groupaddmember(actor) end;

---�������ﱳ��������
---* actor  userdata  ��Ҷ���
---* count number  ���Ӵ�С(��С��46,������126)
---@param actor  userdata 
---@param count number
---@nodiscard
function lib996:setbagcount(
    actor,
    count
) end;

---�Ƿ����
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return boolean   true��������|false�����Ǻ���
---@nodiscard
function lib996:ispkredname(actor) end;

---�Ƿ����
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return boolean   true��������|false�����ǻ���
---@nodiscard
function lib996:ispkyellowname(actor) end;

---�ж϶����Ƿ��Ǽ���
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return boolean   true��������|false�����Ǽ���
---@nodiscard
function lib996:isdum(actor) end;

---���Ͷ����������Ϣ
---* actor  userdata  ���˶���
---* itype  number   ����Ƶ�� 1:����2:˽��3:����4:����
---* msg  string  ��������
---* palyname  userdata  ����� ��˽����Ч
---@param actor  userdata 
---@param itype  number 
---@param msg  string 
---@param palyname  userdata 
---@return boolean   true�����ɹ�|false����ʧ��
---@nodiscard
function lib996:dumtalk(actor,itype,msg,palyname) end;

---��ȡ���������м�������
---@return number  ��������
---@nodiscard
function lib996:dumcount() end;

---���ý�ɫ���߹һ�
---* actor  userdata  ��Ҷ���
---* time  number  ����ʱ��(��)
---@param actor  userdata 
---@param time  number 
---@nodiscard
function lib996:offlineplay(actor,time) end;

---��ȡ����Զ�Ѱ·�յ�����
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return number  1��x���� | 2��y����
---@nodiscard
function lib996:gettargetxy(actor) end;

---��ȡ�����Զ���������
---* actor  userdata  ��Ҷ���
---* makeid  number   ����makeindex(Ψһid)
---@param actor  userdata 
---@param makeid  number 
---@return table | ���������Զ���������
---@nodiscard
function lib996:getitemattrtag(actor, makeid) end;

---���ݵ����Զ����������ȡ��������
---* actor  userdata  ��Ҷ���
---* makeid  number   ����makeindex(Ψһid)
---* nTag  number   ������
---@param actor  userdata 
---@param makeid  number 
---@param nTag  number 
---@return string | ���ݵ����Զ����������ȡ�������� | nTag=-1ʱ,���������Զ�������
---@nodiscard
function lib996:getitemattr(actor, makeid, nTag) end;

---ɾ����Ա
---* player  userdata  ��Ҷ���
---* memberId  string  ��ԱUserId(Ψһ��id)
---@param player  userdata 
---@param memberId  string 
---@nodiscard
function lib996:delgroupmember(player,memberId) end;

---��ȡϵͳ����
---@return userdata | ����ϵͳ����
---@nodiscard
function lib996:getsys() end;

---����������ѡ��Ʒ
---* actor  userdata  ��Ҷ���
---* makeindex  string   ѡ�е���ƷΨһID�����Ʒ�á�,���ָ�
---@param actor  userdata 
---@param makeindex  string 
---@nodiscard
function lib996:selectbagitems(
    actor,
    makeindex
) end;

---��ȡ��Ա�б�
---* player  userdata  ��Ҷ���
---@param player  userdata 
---@return table | ��Ա�����б�
---@nodiscard
function lib996:getgroupmember(player) end;

---��ӡ��־
---* string  string  Ҫ��ӡ����Ϣ
---* show  number  0��m2��ͬ����ʾ,1��m2ͬ����ʾ
---@param string  string 
---@param show  number 
---@nodiscard
function lib996:scriptlog(str,show) end;

---����װ��
---* actor  userdata  ��Ҷ���
---* where  number   λ��
---* makeindex number   ��ƷΨһID
---@param actor  userdata 
---@param where  number 
---@param makeindex number 
---@nodiscard
function lib996:takeonitem(
    actor,
    where,
    makeindex
) end;

---��Ӿ����ͼ
---* oldMap  string  ԭ��ͼID
---* NewMap  string  �µ�ͼID(��id����Ϊ��ʱ����ʹ��)
---* NewName  string  �µ�ͼ��
---* time  number  ��Чʱ��(��)
---* BackMap  string  	�سǵ�ͼ(��Чʱ�������,����ȥ�ĵ�ͼ)
---@param oldMap  string 
---@param NewMap  string 
---@param NewName  string 
---@param time  number 
---@param BackMap  string 
---@return boolean  true�����ɹ�|false����ʧ��
---@nodiscard
function lib996:addmirrormap(oldMap,NewMap,NewName,time,BackMap) end;

---����װ��
---* actor  userdata  ��Ҷ���
---* where  number   λ��
---* makeindex number   ��ƷΨһID
---@param actor  userdata 
---@param where  number 
---@param makeindex number 
---@nodiscard
function lib996:takeoffitem(
    actor,
    where,
    makeindex
) end;

---�޸��������·���Ч
---* actor  userdata  ��Ҷ���
---* where  number   λ�� 0,1
---* EffId number   ��ЧID
---* selfSee number   �Ƿ�ֻ���Լ�����(1=�����˶��ɼ� 0=�����Լ��ɼ�)
---@param actor  userdata 
---@param where  number 
---@param EffId number 
---@param selfSee number 
---@nodiscard
function lib996:changedresseffect(actor,where,EffId,selfSee) end;

---ɾ�������ͼ
---* MapId  string  ��ͼID
---@param MapId  string 
---@nodiscard
function lib996:delmirrormap(MapId) end;

---��/�����κ�
---* actor  userdata  ��Ҷ���
---* bState  number   0���ر�,1������
---@param actor  userdata 
---@param bState  number 
---@nodiscard
function lib996:setsndaitembox(actor,bState) end;

---ֹͣ�Զ��һ�
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function lib996:stopautoattack(actor) end;

---��ȡ/���þ����ͼʣ��ʱ��
---@nodiscard
function lib996:mirrormaptime(MapId,time) end;

---���buffʱ
---* actor  userdata  ����
---* buffid  number  buffid
---* time  number  buffʣ��ʱ��
---* host  userdata  �ͷ���
---@param actor  userdata 
---@param buffid  number 
---@param time  number 
---@param host  userdata 
---@nodiscard
function addbuffafter(actor,buffid,time,host) end;

---�޸��������·����
---* actor  userdata  ��Ҷ���
---* item  userdata   ��Ʒ����
---* looks number   ���ֵ
---@param actor  userdata 
---@param item  userdata 
---@param looks number 
---@nodiscard
function lib996:changeitemshape(actor,item,looks) end;

---������Ʒ��Ч
---* actor  userdata  ��Ҷ���
---* makeindex  number   ��ƷΨһid
---* bEffect  number   ������Ч
---* bWhere  number   ������Ч�ں�(0-��ǰ,1-�ں�)
---* sEffect  number   װ����Ч
---* sWhere  number   װ����Ч�ֺ�(0-��ǰ,1-�ں�)
---@param actor  userdata 
---@param makeindex  number 
---@param bEffect  number 
---@param bWhere  number 
---@param sEffect  number 
---@param sWhere  number 
---@nodiscard
function lib996:setitemeffect(actor, makeindex, bEffect, bWhere, sEffect, sWhere) end;

---��⾵���ͼ�Ƿ����
---* MapId  string  ��ͼID
---@param MapId  string 
---@return boolean   true������ | false��������
---@nodiscard
function lib996:checkmirrormap(MapId) end;

---ɾ��buffʱ
---* actor  userdata  ����
---* buffid  number  buffid
---* time  number  buffʣ��ʱ��
---* host  userdata  �ͷ���
---@param actor  userdata 
---@param buffid  number 
---@param time  number 
---@param host  userdata 
---@nodiscard
function delbuffafter(actor,buffid,time,host) end;

---������ƷΨһID�����Ʒ����
---* actor  userdata  ��Ҷ���
---* makeindex  number   	��ƷΨһID
---@param actor  userdata 
---@param makeindex  number 
---@return userdata | ���ض�Ӧ����Ʒ����,�����������,����nil
---@nodiscard
function lib996:getitembymakeindex(actor,makeindex) end;

---��ָ����ͼxy����ˢ�¹���
---* mapid  string  	��ͼid
---* x  number  	x����x,y��Ϊ0ʱΪȫͼ���
---* y  number  	y����x,y��Ϊ0ʱΪȫͼ���
---* monname  string  	��������
---* range  number  ��Χ
---* count  number  ����
---* color  number  ��ɫ
---@param mapid  string 
---@param x  number 
---@param y  number 
---@param monname  string 
---@param range  number 
---@param count  number 
---@param color  number 
---@return table | ��������б�
---@nodiscard
function lib996:genmon(mapid,x,y,monname,range,count,color) end;

---��ӵ�ͼ��Ч
---* Id  number  	��Ч����ID,�������ֶ����ͼ��Ч
---* MapId  string  ��ͼID
---* X  number  ����X
---* Y  number  ����Y
---* effId  number  ��ЧID
---* time  number  ����ʱ��(��)
---* mode  number  0:�����˿ɼ�1:�Լ��ɼ�2:��ӿɼ�3:�л��Ա�ɼ�4:�жԿɼ�
---@param Id  number 
---@param MapId  string 
---@param X  number 
---@param Y  number 
---@param effId  number 
---@param time  number 
---@param mode  number 
---@nodiscard
function lib996:mapeffect(Id,MapId,X,Y,effId,time,mode) end;

---�����޵�ģʽ
---* actor  userdata   ��Ҷ���
---* number  number   1���޵�,0�����޵�
---@param actor  userdata 
---@param number  number 
---@nodiscard
function lib996:superman(actor,int) end;

---��ȡ����ʣ��ո���
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return string | ����ʣ�������
---@nodiscard
function lib996:getbagblank(actor) end;

---ɾ����ͼ��Ч
---*  Id  	number  	��Ч����ID
---@param  Id  	number 
---@nodiscard
function lib996:delmapeffect(Id) end;

---��ȡ��ͼ��ָ����Χ�ڵĶ���
---* MapId  string  	��ͼID
---* x  number  x����
---* y  number  y����
---* range  number  ��Χ
---* flag  number  ���ֵ,������λ��ʾ��1:���,2:����4:NPC,8:��Ʒ16:��ͼ�¼�32:���ι�64:Ӣ��128:����
---@param MapId  string 
---@param x  number 
---@param y  number 
---@param range  number 
---@param flag  number 
---@return table | �����
---@nodiscard
function lib996:getobjectinmap(MapId,x,y,range,flag) end;

---�Ƿ�ӵ�е�ʿĬ�϶�
---* actor userdata   ��Ҷ���
---* type number   0:�춾,1:�̶�
---@param actor userdata 
---@param type number 
---@return boolean   true������|false����û��
---@nodiscard
function lib996:hasgas(actor,type) end;

---��ȡ����������Ʒ
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return table | ��Ʒ�����б�
---@nodiscard
function lib996:getbagitems(actor) end;

---�ڵ�ͼ�Ϸ�����Ʒ
---@return table | �ɹ�ʱ������Ʒmakeid,ʧ�ܷ��ؿ�
---@nodiscard
function lib996:throwitem(actor,MapId,X,Y,range,name,count,time,hint,take,self,order) end;

---��ȡ����λ�ü�����ʱ��
---* MapId  string  	��ͼID
---@param MapId  string 
---@return table | ����״̬�� | {"mon":[{"name":"������","x":476,"y":484,"time":0},{"name":"������","x":359,"y":409,"time":0}],"count":2}
---@nodiscard
function lib996:getmonrefresh(MapId) end;

---ɾ����ʿĬ�϶�
---* actor userdata   ��Ҷ���
---* type number   0:�춾,1:�̶�
---@param actor userdata 
---@param type number 
---@return boolean   �ɹ�����true|ʧ�ܡ�������false
---@nodiscard
function lib996:delgas(actor,type) end;

---�������˰�̯
---* actor  userdata  ���˶���
---@param actor  userdata 
---@return boolean   true�����ɹ�|false����ʧ��
---@nodiscard
function lib996:dumstopstall(actor) end;

---�Ƿ����
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return boolean   true��������|false�����ǻ���
---@nodiscard
function lib996:ispkgreyname(actor) end;

---�����ͼ��ָ�����ֵ���Ʒ
---* MapId  string  	��ͼID
---* X  number  	����X
---* Y  number  	����Y
---* range  number  	��Χ
---* itemName  string  		��Ʒ�� ����nil����������
---@param MapId  string 
---@param X  number 
---@param Y  number 
---@param range  number 
---@param itemName  string 
---@nodiscard
function lib996:clearitemmap(MapId,X,Y,range,itemName) end;

---��ȡ�ֿ�������Ʒ
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return table | ��Ʒ�����б�
---@nodiscard
function lib996:getstorageitems(actor) end;

---�������ƻ�ȡ��Ʒid
---* itemname  string  ��Ʒ����
---@param itemname  string 
---@return number �ɹ�������Ʒid|ʧ�ܡ���-1
---@nodiscard
function lib996:getitemid(itemname) end;

---���˿����Զ�ս��
---* actor  userdata  ���˶���
---@param actor  userdata 
---@return boolean   true�����ɹ�|false����ʧ��
---@nodiscard
function lib996:dumstart(actor) end;

---����ֹͣ�Զ�ս��
---* actor  userdata  ���˶���
---@param actor  userdata 
---@return boolean   true�����ɹ�|false����ʧ��
---@nodiscard
function lib996:dumstop(actor) end;

---����Ŀ����ʱ����
---* Type  number  ����0:���,1:�л�,2:��ͼ,3����Ʒ,4��NPC,5:����
---* actor  obj  ����=���-���������=�л�-���������=��Ʒ-��makeid����=��ͼ-���ͼID����=NPC-��NPCID����=����-�����
---@param Type  number 
---@param actor  obj 
---@nodiscard
function lib996:clrtempvar(Type,actor) end;

---�߳�����
---* actor  userdata  ���˶��� ��Ϊnilʱ��ȫ���߳�
---@param actor  userdata 
---@return boolean   true�����ɹ�|false����ʧ��
---@nodiscard
function lib996:dumkick(actor) end;

---����id��ȡ��Ʒ�۸�(price)
---* id  number  ��Ʒid
---@param id  number 
---@return number �ɹ�������Ʒ�۸�|ʧ�ܡ���-1
---@nodiscard
function lib996:getitemprice(id) end;

---������Ʒ��Դ
---* actor  userdata  ��Ҷ���
---* item  userdata  ��Ʒ����
---* json  userdata  json
---@param actor  userdata 
---@param item  userdata 
---@param json  userdata 
---@nodiscard
function lib996:setthrowitemly2(actor,item, json) end;

---����id��ȡ��Ʒ����������
---* id  number  ��Ʒid
---@param id  number 
---@return number �ɹ�������Ʒ����������|ʧ�ܡ���-1
---@nodiscard
function lib996:getitemoverlap(id) end;

---����id��ȡ��Ʒ����;�
---* id  number  ��Ʒid
---@param id  number 
---@return number �ɹ�������Ʒ����;�|ʧ�ܡ���-1
---@nodiscard
function lib996:getitemduramax(id) end;

---����id��ȡ��ƷAniCount
---* id  number  ��Ʒid
---@param id  number 
---@return number �ɹ�������ƷAniCount|ʧ�ܡ���-1
---@nodiscard
function lib996:getitemanicount(id) end;

---����id��ȡ��Ʒ����
---* id  number  ��Ʒid
---@param id  number 
---@return number �ɹ�������Ʒ����|ʧ�ܡ���-1
---@nodiscard
function lib996:getitemweight(id) end;

---����id��ȡ��ƷShape
---* id  number  ��Ʒid
---@param id  number 
---@return number �ɹ�������ƷShape|ʧ�ܡ���-1
---@nodiscard
function lib996:getitemshape(id) end;

---��������ģʽ
---* actor  userdata   ��Ҷ���
---* number  number   1������,0��������
---@param actor  userdata 
---@param number  number 
---@nodiscard
function lib996:observer(actor,int) end;

---����id��ȡ��ƷStdMode
---* id  number  ��Ʒid
---@param id  number 
---@return number �ɹ�������ƷStdMode|ʧ�ܡ���-1
---@nodiscard
function lib996:getitemstdmode(id) end;

---����������Ч��
---* actor  userdata  ��Ҷ���
---* time  number   ����ʱ��,��,-1ȡ��������Ч��
---@param actor  userdata 
---@param time  number 
---@nodiscard
function lib996:sethide(actor,time) end;

---����id��ȡ��Ʒ����
---* id  number  ��Ʒid
---@param id  number 
---@return string |�ɹ�������Ʒ����|ʧ�ܡ���nil
---@nodiscard
function lib996:getnamebyidx(id) end;

---���õ�ͼ��ת��
---* name  string  	��ת������
---* amapid  string  	��ڵ�ͼID
---* jx  number  	���x����
---* jy  number  	���y����
---* range  number  	��Χ
---* bmapid  string  	���ڵ�ͼID
---* cx  number  	����x����
---* cy  number  	����y����
---* time  number  	����ʱ��
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

---��ȡ���pk��
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return number  ���pk����
---@nodiscard
function lib996:getpkpoint(actor) end;

---��ȡ��ͼ��ת��
---* name  string      ��ת������
---* amapid  string      ��ڵ�ͼID
---@param name  string 
---@param amapid  string 
---@return table | {jx,jy,bmapid,cx,cy}
---@nodiscard
function lib996:getmapgate(name,amapid) end;

---�趨��ͼ��ʱ��
---* MapId  string  ��ͼID
---* Idx  number  	��ʱ��ID
---* second  number  	ʱ��(��)
---* func  string  	������ת�ĺ���
---@param MapId  string 
---@param Idx  number 
---@param second  number 
---@param func  string 
---@nodiscard
function lib996:setenvirontimer(MapId,Idx,second,func) end;

---�������pk��
---* actor  userdata  ��Ҷ���
---* opt  string  ������ + - =
---* n  number  ����
---@param actor  userdata 
---@param opt  string 
---@param n  number 
---@nodiscard
function lib996:setpkpoint(actor,opt, n) end;

---ɾ����ͼ��ת��
---* name  string  	��ת������
---* amapid  string  	��ڵ�ͼID
---@param name  string 
---@param amapid  string 
---@nodiscard
function lib996:delmapgate(name,amapid) end;

---�رյ�ͼ��ʱ��
---* MapId  string  	��ͼID
---* Idx  string  ��ʱ��ID
---@param MapId  string 
---@param Idx  string 
---@nodiscard
function lib996:setenvirofftimer(MapId,Idx) end;

---�����������Ʒ
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function lib996:refreshbag(actor) end;

---�ж��߼����Ƿ�Ϊ��ȫ��
---*  mapid  	string  ��ͼID
---*  x  	number  	x����
---*  y  	number  	y����
---@param  mapid  	string 
---@param  x  	number 
---@param  y  	number 
---@return boolean   true��Ϊ��ȫ�� | false����Ϊ��ȫ��
---@nodiscard
function lib996:isinsafe(mapid, x, y) end;

---��ȡ���ɳ�Ϳ����
---* actor  obj   ��Ҷ���
---@param actor  obj 
---@return number  0:��ɳ�Ϳ˳�Ա | 1:ɳ�Ϳ˳�Ա | 2:ɳ�Ϳ��ϴ�
---@nodiscard
function lib996:castleidentity(actor) end;

---������װ��������Ч
---* actor  userdata  ��Ҷ���
---* effectid  number   	��ЧID, 0-ɾ����Ч
---* position number   ��ʾλ�ã�0-ǰ�� 1-����
---@param actor  userdata 
---@param effectid  number 
---@param position number 
---@nodiscard
function lib996:updateequipeffect(actor,effectid,position) end;

---�ж��߼����Ƿ�Ϊ������
---*  mapid  	string  ��ͼID
---*  x  	number  	x����
---*  y  	number  	y����
---@param  mapid  	string 
---@param  x  	number 
---@param  y  	number 
---@return boolean   true��Ϊ������ | false����Ϊ������
---@nodiscard
function lib996:isincastle(mapid, x, y) end;

---��ȡɳ�Ϳ˻�����Ϣ
---* id  number   ����id
---@param id  number 
---@return number/string/boolean/table | ����id�� | 1  :  ɳ������[string] | 2  :  ɳ���л�����[string] | 3  :  ɳ���л�᳤����[string] | 4  :  ռ������[number] | 5  :  ��ǰ�Ƿ��ڹ�ɳ״̬[Bool] | 6  :  ɳ���лḱ�᳤�����б�[table]
---@nodiscard
function lib996:castleinfo(id) end;

---���ݵ�ͼid���ص�ͼ��
---*  mapid  	string  ��ͼID
---@param  mapid  	string 
---@return string | ��ͼ����
---@nodiscard
function lib996:getmapname(mapid) end;

---��ȡ������Ϣ
---* actor  userdata  ��Ҷ���
---* skillid  number ����ID
---* id number  	����ID,1:�ȼ�,2:ǿ���ȼ�,3:������
---@param actor  userdata 
---@param skillid  number
---@param id number 
---@return number  (��Ӧ����ֵ) ,û�м���,����nil
---@nodiscard
function lib996:getskillinfo(actor,skillid,id) end;

---������ʱNPC
---* mapid  userdata   ����
---* x  number   x����
---* y  number   y����
---* npc  string  json
---@param mapid  userdata 
---@param x  number 
---@param y  number 
---@param npc  string
---@nodiscard
function lib996:createnpc(mapid,x,y,npc) end;

---������ҵȼ�
---* actor  userdata  ��Ҷ���
---* opt  string  ������ + - =
---* n  number  ����
---* istringigg boolean �Ƿ񴥷������ص�,Ĭ��false
---@param actor  userdata 
---@param opt  string 
---@param n  number 
---@param istringigg boolean
---@nodiscard
function lib996:setlevel(actor,opt,n,istrigg) end;

---��Ӽ���
---* actor  userdata  ��Ҷ���
---* skillid  number   ����ID
---* level number  	�ȼ�
---@param actor  userdata 
---@param skillid  number 
---@param level number 
---@nodiscard
function lib996:addskill(actor,skillid,level) end;

---ɾ����ʱNPC
---* npcid  number   npcid
---* mapid  string   ��ͼid
---@param npcid  number 
---@param mapid  string 
---@nodiscard
function lib996:delnpc(npc,mapid) end;

---��������Ա�
---* actor  userdata  ��Ҷ���
---* n  number  �Ա� 0����,1��Ů
---@param actor  userdata 
---@param n  number 
---@nodiscard
function lib996:setsex(acto,n) end;

---ɾ������
---* actor  userdata  ��Ҷ���
---* cskillid  string   ����ID
---@param actor  userdata 
---@param cskillid  string 
---@nodiscard
function lib996:delskill(actor,skillidr) end;

---����ID��ȡNPC����
---* npcid  number   npcid
---@param npcid  number 
---@return userdata | npc����
---@nodiscard
function lib996:getnpcbyindex(npcid) end;

---�������ְҵ
---* actor  userdata  ��Ҷ���
---* n  number  0��սʿ,1����ʦ,2����ʿ
---@param actor  userdata 
---@param n  number 
---@nodiscard
function lib996:setjob(actor,n) end;

---������м���
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function lib996:clearskill(actor) end;

---��ת��ָ��NPC����
---* actor  userdata   ��Ҷ���
---* npcid  number   npcid
---* rangea  number   ��Χ�����ڴ˷�Χ�����ƶ���npc����
---* rangeb  number   ��Χ���ƶ���NPC�����ķ�Χ��
---@param actor  userdata 
---@param npcid  number 
---@param rangea  number 
---@param rangeb  number 
---@nodiscard
function lib996:opennpcshowex(actor,npc,rangea,rangeb) end;

---ɾ���Ǳ�ְҵ����
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function lib996:delnojobskill(actor) end;

---����NPC��Ч
---* actor  userdata   ��Ҷ���
---* npcid  number   npcid
---* Effect  number   ��ЧID5055-��̾�� 5056-�ʺ�
---* x  number   x����
---* y  number   y����
---@param actor  userdata 
---@param npcid  number 
---@param Effect  number 
---@param x  number 
---@param y  number 
---@nodiscard
function lib996:setnpceffect(actor,npcid,Effect,x,y) end;

---��ȡ��ͼ�м�������
---* mapid  string  ��ͼid
---@param mapid  string 
---@return number  ��������
---@nodiscard
function lib996:dumcountinmap(mapid) end;

---���ü��ܵȼ�
---* actor  userdata  ��Ҷ���
---* skillid  number   ����ID
---* flag number   	���ͣ�1-���ܵȼ�2-ǿ���ȼ�3-������
---* ponumber number   �ȼ������
---@param actor  userdata 
---@param skillid  number 
---@param flag number 
---@param ponumber number 
---@nodiscard
function lib996:setskillinfo(actor,skillid,flag,point) end;

---�̳����򴥷�
---@nodiscard
function buyshopitem(actor,money,moneynum,itemid,itemname,num) end;

---�ýű������ͷż���
---* actor  userdata  ��Ҷ���
---* skillid  number  ����ID
---* type number  	���ͣ�1-��ͨ����2-ǿ������
---* level number  ���ܵȼ�
---* target number  	���ܶ���1-����Ŀ��,2-����,3-Ŀ�����(��������),4-��ǰ��ͼ����(��������)
---* flag number   �Ƿ���ʾʩ��������0-����ʾ,1-��ʾ
---@param actor  userdata 
---@param skillid  number 
---@param type number 
---@param level number 
---@param target number 
---@param flag number 
---@nodiscard
function lib996:releasemagic(actor,skillid,type,level,target,flag) end;

---���õȼ���
---* actor  userdata  ��Ҷ���
---* itype  number  0:�������1�����������ȼ�ʱ���Ҳ���ȡ���ﾭ��2:�����������ȼ�ʱ�ۻ�����(number64)
---* level  number  ��ס���ȼ�
---@param actor  userdata 
---@param itype  number 
---@param level  number 
---@nodiscard
function lib996:setlocklevel(actor,itype,level) end;

---��������ǰ����
---* actor  userdata  ��Ҷ���
---* itemmakeid  number ��ƷΨһid
---* itemid  number  ��Ʒid
---* itemname  number  ��Ʒ����
---@param actor  userdata 
---@param itemmakeid  number
---@param itemid  number 
---@param itemname  number 
---@return boolean  true��������|false������
---@nodiscard
function dropbagitemsbefore(actor,itemmakeid,itemid,itemname) end;

---װ������ǰ����
---* actor  userdata  ��Ҷ���
---* itemmakeid  number ��ƷΨһid
---* itemid  number  ��Ʒid
---* itemname  number  ��Ʒ����
---@param actor  userdata 
---@param itemmakeid  number
---@param itemid  number 
---@param itemname  number 
---@return boolean  true��������|false������
---@nodiscard
function dropuseitemsbefore(actor,itemmakeid,itemid,itemname) end;

---ɾ��NPC��Ч
---* actor  userdata   ��Ҷ���
---* npcid  number   npcid
---@param actor  userdata 
---@param npcid  number 
---@nodiscard
function lib996:delnpceffect(actor,npcid) end;

---��ȡNPC�����Id
---* npc  userdata   npc����
---@param npc  userdata 
---@return number  npcid ʧ�ܷ���0
---@nodiscard
function lib996:getnpcindex(npc) end;

---�����ļ�
---* path  string  �ļ�·��
---@param path  string 
---@return ���ݼ����ļ� return ����
---@nodiscard
function lib996:include(path) end;

---�½�����
---* actor  userdata  ��Ҷ���
---* id  number  ����id
---* a  string  ����1�����滻�����������%s
---* b  string  ����2�����滻�����������%s
---* c  string  ����3�����滻�����������%s
---* d  string  ����4�����滻�����������%s
---* e  string  ����5�����滻�����������%s
---* f  string  ����6�����滻�����������%s
---* g  string  ����7�����滻�����������%s
---* h  string  ����8�����滻�����������%s
---* i  string  ����9�����滻�����������%s
---* j  string  ����10�����滻�����������%s
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

---�����������ȡ��Ҷ���
---* name  string  �������
---@param name  string 
---@return userdata | ��Ҷ���
---@nodiscard
function lib996:getplayerbyname(name) end;

---ˢ�½���������״̬
---* actor  userdata  ��Ҷ���
---* id  number  ����id
---* a  string  ����1�����滻�����������%s
---* b  string  ����2�����滻�����������%s
---* c  string  ����3�����滻�����������%s
---* d  string  ����4�����滻�����������%s
---* e  string  ����5�����滻�����������%s
---* f  string  ����6�����滻�����������%s
---* g  string  ����7�����滻�����������%s
---* h  string  ����8�����滻�����������%s
---* i  string  ����9�����滻�����������%s
---* j  string  ����10�����滻�����������%s
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

---�������ΨһID��ȡ��Ҷ���
---* id  string  	���Ψһid
---@param id  string 
---@return userdata | ��Ҷ���
---@nodiscard
function lib996:getplayerbyid(id) end;

---�������
---* actor  userdata  ��Ҷ���
---* id  number  ����id
---@param actor  userdata 
---@param id  number 
---@nodiscard
function lib996:newcompletetask(actor,id) end;

---ɾ������
---* actor  userdata  ��Ҷ���
---* id  number  ����id
---@param actor  userdata 
---@param id  number 
---@nodiscard
function lib996:newdeletetask(actor,id) end;

---�����ö���ʾ
---* actor  userdata  ��Ҷ���
---* id  number  ����id
---@param actor  userdata 
---@param id  number 
---@nodiscard
function lib996:tasktopshow(actor,id) end;

---�����ʼ�
---* userid  string  ���Ψһid����������� #����ȭ
---* type  number  �Զ����ʼ�����
---* title  number  �ʼ�����
---* string  number  �ʼ�����
---* rewards  number  ��������Ʒ1#����#�󶨱��&��Ʒ2#����#�󶨱��,&����,#�ָ�
---@param userid  string 
---@param type  number 
---@param title  number 
---@param string  number 
---@param rewards  number 
---@nodiscard
function lib996:sendmail(userid,type,title,str,rewards) end;

---�ڳ��Զ�Ѱ·��ָ������
---* actor  userdata  ��Ҷ���
---* x  number  x����
---* y  number  y����
---* range  number  ������˾��������뷶Χ:0-12 ��0�򲻼��
---@param actor  userdata 
---@param x  number 
---@param y  number 
---@param range  number 
---@nodiscard
function lib996:dartmap(actor,x,y,range) end;

---�޸Ĺ���ģʽ
---* actor  userdata  ��Ҷ���
---* attackmode  number   ����ģʽ
---@param actor  userdata 
---@param attackmode  number 
---@nodiscard
function lib996:changeattackmode(actor,attackmode) end;

---�������ϼ�ǰ
---* actor  userdata  ��Ҷ���
---* itemid  number  ��Ʒid
---* makeid  number  ��ƷΨһid
---* itemname  string  ��Ʒ����
---* itemnum number  ��Ʒ����
---* mtype number  ��������
---* jhuob number  ���۽��
---* yhuob number  һ�ڼ۽��
---@param actor  userdata 
---@param itemid  number 
---@param makeid  number 
---@param itemname  string 
---@param itemnum number 
---@param mtype number 
---@param jhuob number 
---@param yhuob number 
---@return boolean  true���������ϼ�|false������
---@nodiscard
function on_pre_paimai(actor,itemid,makeid,itemname,itemnum,mtype,jhuob,yhuob) end;

---���˿�ʼ��̯ʱ
---* actor  userdata  ���˶���
---* itemtab  json  ���˰�̯��Ʒ��
---@param actor  userdata 
---@param itemtab  json 
---@nodiscard
function on_stall_act(actor,itemtab) end;

---��ȡ�ļ��б�
---* file   string  �ļ���
---@param file   string 
---@return table
---@nodiscard
function lib996:getfilelist(file) end;

---ǿ���޸Ĺ���ģʽ
---* actor  userdata  ��Ҷ���
---* attackmode  number  ����ģʽ-1=��ǰ����ǿ��״̬
---* time number   ǿ���л�ʱ��(��)
---@param actor  userdata 
---@param attackmode  number 
---@param time number 
---@nodiscard
function lib996:setattackmode(actor,attackmode,time) end;

---�����й�����Ʒ����
---* actor  userdata  ��Ҷ���
---* money  number  ����id
---* moneynum  number  ���Ļ�����
---* itemid  number  �������Ʒid
---* makeid  number  �������ƷΨһid
---* itemname  string  �������Ʒ����
---* num  number  �������Ʒ����
---@param actor  userdata 
---@param money  number 
---@param moneynum  number 
---@param itemid  number 
---@param makeid  number 
---@param itemname  string 
---@param num  number 
---@return boolean  true����������|false������
---@nodiscard
function buypaimaiitem(actor,money,moneynum,itemid,makeid,itemname,num) end;

---��ʼ�һ�����
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function startautoplaygame(actor) end;

---�������ǰ����
---* actor  userdata  ������
---* invitee  userdata  ��������
---@param actor  userdata 
---@param invitee  userdata 
---@return boolean  true��������|false������
---@nodiscard
function invitegroup(actor, invitee) end;

---���ڳ����������ƶ�
---@nodiscard
function lib996:pulldart(actor, range) end;

---����ǰ����
---* actor  userdata  ʩ����
---* target  userdata  �ܻ���
---* skillid  number  ����id
---* SysCanPush  boolean  �����ж������Ƿ���Ի���
---@param actor  userdata 
---@param target  userdata 
---@param skillid  number 
---@param SysCanPush  boolean 
---@return boolean   ���Ի��ˡ���true|�����Ի��ˡ���false
---@nodiscard
function on_push_pre(actor, target, skillid, SysCanPush) end;

---��������ʱ�ڳ��������
---* actor  userdata  ��Ҷ���
---* time  number  �ڳ����ʱ��,��
---* aim  number  0-��ʧ,1-ʱ�䵽����ʧ
---@param actor  userdata 
---@param time  number 
---@param aim  number 
---@nodiscard
function lib996:darttime(actor,time,aim) end;

---�̳��Ƿ�����ָ��������ʾ
---* actor  userdata  ��Ҷ���
---* show  number  1-����ʾ,0-��ʾ
---@param actor  userdata 
---@param show  number 
---@nodiscard
function lib996:notallowshow(actor,show) end;

---��־�ϱ�
---* actor   obj  ��Ҷ���
---* eventTag   string  �¼�����
---* eventMSG   string  �¼�����
---@param actor   obj 
---@param eventTag   string 
---@param eventMSG   string 
---@nodiscard
function lib996:postlog(actro,eventTag,eventMSG) end;

---�̳��Ƿ�����ָ����������
---* actor  userdata  ��Ҷ���
---* buy  number  1-��������,0-������
---@param actor  userdata 
---@param buy  number 
---@nodiscard
function lib996:notallowbuy(actor,buy) end;

---��ȡ��ǰ����ģʽ
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return number  0-ȫ�幥�� | 1-��ƽ���� | 2-���޹��� | 3-ʦͽ���� | 4-���鹥�� | 5-�лṥ�� | 6-�������� | 7-���ҹ���
---@nodiscard
function lib996:getattackmode(actor) end;

---��ת����ͼ�������
---* actor  userdata  ��Ҷ���
---* mapid  string  ��ͼid
---@param actor  userdata 
---@param mapid  string 
---@nodiscard
function lib996:map(actor,mapid) end;

---�����������Ϣ
---* actor  userdata  ��Ҷ���
---* type  number   1:�Լ�2:ȫ��3:�л�4:��ǰ��ͼ5:���
---* msg  string   ��Ϣ����
---@param actor  userdata 
---@param type  number 
---@param msg  string 
---@nodiscard
function lib996:sendmsg(actor,tye,msg) end;

---�����Ϣ������̨
---* string  string  Ҫ�������Ϣ
---@param string  string 
---@nodiscard
function lib996:release_print(str) end;

---��ת����ͼָ������
---* actor  userdata  ��Ҷ���
---* mapid  string  ��ͼid
---* nX  number  X����
---* nY  number  Y����
---* nRange  number  ��Χ
---@param actor  userdata 
---@param mapid  string 
---@param nX  number 
---@param nY  number 
---@param nRange  number 
---@return boolean   �ɹ�����true,����false
---@nodiscard
function lib996:mapmove(actor,mapid,nX,nY,nRange) end;

---������ҵ�ָ��λ��
---* actor  userdata  ��Ҷ���
---* X  string   X����
---* Y string   Y����
---@param actor  userdata 
---@param X  string 
---@param Y string 
---@nodiscard
function lib996:gotonow(actor,X,Y) end;

---������Ļ�м��������Ϣ
---* actor  userdata  ��Ҷ���
---* FColor  number   ǰ��ɫ
---* BColor  number   ����ɫ
---* msg  string   ��Ϣ����
---* flag  string  0:���͸��Լ�1:������������2:�����л�3:���͹���4:���͵�ǰ��ͼ5:�滻ģʽ7:���
---* time  number   ��ʾʱ��
---* func  string   ����ʱ��������ת�Ľű�λ��,��Ӧ�ű���Ҫ��QFunction�ű���,ʹ����תʱ,��Ϣ������ʾ�б������%d,������ʾ����ʱʱ��
---@param actor  userdata 
---@param FColor  number 
---@param BColor  number 
---@param msg  string 
---@param flag  string 
---@param time  number 
---@param func  string 
---@nodiscard
function lib996:sendcentermsg(actor,FColor,BColor,msg,flag,time,func) end;

---��������б�
---@return table | ��������������Ҷ����б�
---@nodiscard
function lib996:getplayerlst() end;

---���������̶���Ϣ
---* actor  userdata  ��Ҷ���
---* flag  string  0:������������1:���͸��Լ�2:�����л�3:���͵�ǰ��ͼ4:���
---* FColor  number   ǰ��ɫ
---* BColor  number   ����ɫ
---* time  number   ��ʾʱ��
---* msg  string   ��Ϣ����
---* show  string  �Ƿ���ʾ��������0-��1-��
---@param actor  userdata 
---@param flag  string 
---@param FColor  number 
---@param BColor  number 
---@param time  number 
---@param msg  string 
---@param show  string 
---@nodiscard
function lib996:sendtopchatboardmsg(actor,flag,FColor,BColor,msg,time,show) end;

---��ȡ���GMȨ�޵ȼ�
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return number  GMȨ�޵ȼ�
---@nodiscard
function lib996:getgmlevel(actor) end;

---������Ļ������Ϣ
---* actor  userdata  ��Ҷ���
---* flag  string  0:���͸��Լ�1:������������2:�����л�3:���͵�ǰ��ͼ4:���
---* FColor  number   ǰ��ɫ
---* BColor  number   ����ɫ
---* higjt  number   �߶�
---* show  number  ��������
---* msg  string   ��Ϣ����
---@param actor  userdata 
---@param flag  string 
---@param FColor  number 
---@param BColor  number 
---@param higjt  number 
---@param show  number 
---@param msg  string 
---@nodiscard
function lib996:sendmovemsg(actor,flag,FColor,BColor,higjt,show,msg) end;

---����
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function lib996:realive(actor) end;

---����������Ϣ
---* actor  userdata  ��Ҷ���
---* msg  string   ��Ϣ����
---* afun  string   ȷ������ת�Ľӿ�
---* bfun  string   ȡ������ת�Ľӿ�
---@param actor  userdata 
---@param msg  string 
---@param afun  string 
---@param bfun  string 
---@nodiscard
function lib996:messagebox(actor,msg,afun,bfun) end;

---��ʱ��ת
---* actor  userdata  ��Ҷ���
---* time  number   ʱ��(����)
---* func string   ��������
---* del number  ����ͼ�Ƿ�ɾ������ʱ(0��Ϊ��ʱ=��ɾ�� 1=ɾ��)
---* param string  �������#��ƴ��
---@param actor  userdata 
---@param time  number 
---@param func string 
---@param del number 
---@param param string 
---@nodiscard
function lib996:delaygoto(actor,time,func,del) end;

---���ô���
---* actor  userdata  ��Ҷ���
---* info  number  0:С���Ա1:�л��Ա2:��ǰ��ͼ������3:���Լ�Ϊ���ķ�Χ���
---* stringfun  string   �ص�����
---* range  string   ����ģʽ=3ʱָ���ķ�Χ��С
---@param actor  userdata 
---@param info  number 
---@param stringfun  string 
---@param range  string 
---@nodiscard
function lib996:gotolabel(actor,info,strfun,range) end;

---ɾ���ӳ�
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function lib996:cleardelaygoto(actor) end;

---��ʱ��Ϣ��ת
---@nodiscard
function lib996:delaymsggoto(actor,time,func) end;

---��ȡ�ȼ���
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return number ������ס�����ȼ�,����������0,ʧ�ܷ���-1
---@nodiscard
function lib996:getlocklevel(actor) end;

---����ƮѪƮ����Ч
---* target  userdata  ƮѪƮ�ֵ�����,һ��Ϊ�ܹ�����
---* type  	numbereger   ��ʾ���� ��ϸ���·�˵����
---* damage numbereger   	��ʾ�ĵ���
---* hitter 	userdata  "*"��Ϊ�����˿ɿ���ƮѪƮ�ֵ�����,һ��Ϊ������
---@param target  userdata 
---@param type  	numbereger 
---@param damage numbereger 
---@param hitter 	userdata
---@nodiscard
function lib996:sendattackeff(target,type,damage,hitter) end;

---֪ͨ�ͻ�����ʾ��
---* actor  userdata  ��Ҷ���
---* FormName  string   �ļ���
---* Content string   Win_Create�ڵ�ID(������#��ƴ��)
---@param actor  userdata 
---@param FormName  string 
---@param Content string 
---@nodiscard
function lib996:showformwithcontent(actor,FormName,Content) end;

---�趨���﹥��ƮѪƮ������
---* actor  userdata  ��Ҷ���
---* type  number  ��ʾ����
---@param actor  userdata 
---@param type  number 
---@nodiscard
function lib996:setattackefftype(actor,type) end;

---�޳����߹һ���ɫ
---* mapid  string  ��ͼ��,��*����ʾȫ����ͼ
---* level  number  �޳��ȼ����ڴ˵ȼ����޳���*����ʾ����
---* count number   	����޳��������*����ʾ����
---@param mapid  string 
---@param level  number 
---@param count number 
---@nodiscard
function lib996:tdummy(mapID,level,count) end;

---�ɼ��ڿ�Ƚ���������
---* actor  userdata  ��Ҷ���
---* time  number   ������ʱ��`�뼶`
---* succ string   �ɹ�����ת�ĺ���
---* msg string   ��ʾ��Ϣ
---* canstop number    	�ܷ��ж�0-�����ж�1-�����ж�
---* fail string   �жϴ����ĺ���
---@param actor  userdata 
---@param time  number 
---@param succ string 
---@param msg string 
---@param canstop number  
---@param fail string 
---@nodiscard
function lib996:showprogressbardlg(actor,time,succ,msg,canstop,fail) end;

---������Ҵ��˴���
---* actor  userdata  ��Ҷ���
---* type  number   ģʽ��0-�ָ�Ĭ��;1-����;2-����;3-���˴���
---* time number   ʱ��(��)
---* objtype number   ���� ��0-���;1-����
---@param actor  userdata 
---@param type  number 
---@param time number 
---@param objtype number 
---@nodiscard
function lib996:throughhum(actor,type,time,objtype) end;

---���õ�ǰ����Ŀ��
---* obj1  userdata  ��һ�Ӣ�ۻ�������1
---* obj2  string   ��һ�Ӣ�ۻ�������2
---@param obj1  userdata 
---@param obj2  string 
---@nodiscard
function lib996:settargetcert(obj1,obj2) end;

---�Ƿ�����趨Ϊ����Ŀ��
---* obj1  userdata  ��һ�Ӣ�ۻ�������1
---* obj2  userdata   ��һ�Ӣ�ۻ�������2
---@param obj1  userdata 
---@param obj2  userdata 
---@return boolean   obj1�Ƿ���Խ�obj2��Ϊ����Ŀ��
---@nodiscard
function lib996:ispropertarget(obj1,obj2) end;

---ֹͣ��̯
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function lib996:forbidmyshop(
    actor
) end;

---��������
---* actor  userdata  ��Ҷ���
---* ID  number   	ID
---* name string   ��ʾ����
---* fun fun  ������(������ö��ŷָ�)
---@param actor  userdata 
---@param ID  number 
---@param name string 
---@param fun fun
---@nodiscard
function lib996:addbutshow(actor,ID,name,bool) end;

---��ȡ��Ʒ��ɫ
---* makeid  number  ��Ʒid
---@param makeid  number 
---@return boolean   �ɹ�������ɫֵ|ʧ�ܡ���0|
---@nodiscard
function lib996:getitemcolor(itemid) end;

---ɾ������
---* actor  userdata  ��Ҷ���
---* ID  number   ID
---@param actor  userdata 
---@param ID  number 
---@nodiscard
function lib996:delbutshow(actor,ID) end;

---��ȡ��Ʒְҵ����
---* makeid  number  ��Ʒid
---@param makeid  number 
---@return ����ְҵ���� ||
---@nodiscard
function lib996:getitemjob(itemid) end;

---����Ʒ
---* actor  userdata  ��Ҷ���
---* itemname  string   	��Ʒ����
---* qty number   ����
---* bind 	number   	��Ʒ����
---@param actor  userdata 
---@param itemname  string 
---@param qty number 
---@param bind 	number 
---@return ��userdata | ���һ����Ʒ����,������ʹ���ڵ�����Ʒ,һ���Ը������Ʒ�����,����Ʒ����ӱ���������,ע����ܱ����յ����
---@nodiscard
function lib996:giveitem(actor,itemname,qty,bind) end;

---����Ʒֱ��װ��
---* actor  userdata  ��Ҷ���
---* where  number   װ��λ��
---* itemname string   ��Ʒ����
---* qty number   	����
---* bind number  	��Ʒ����
---@param actor  userdata 
---@param where  number 
---@param itemname string 
---@param qty number 
---@param bind number 
---@return boolean   true���ɹ� | false�����ɹ�
---@nodiscard
function lib996:giveonitem(actor,where,itemname,qty,bind) end;

---���ñ�����Ϊ
---* actor  userdata  �������
---* act  number  ����Ϊ��� 1����ֹ�������,2�����ɱ�����,4�����ȹ��� ��ҹ�������,8�����ȹ��� ����ܻ�����,16�����ɱ���ҹ��� �����ֹ���
---@param actor  userdata 
---@param act  number 
---@return boolean   �ɹ�����true|ʧ�ܡ���false
---@nodiscard
function lib996:setslaveattack(actor,act) end;

---��ȡ������Ϊ
---* actor  userdata  �������
---@param actor  userdata 
---@return number  �ɹ�����������Ϊ|ʧ�ܡ���-1
---@nodiscard
function lib996:getslaveattack(actor) end;

---��ȡ����
---*  actor  	userdata  ��Ҷ���
---@param  actor  	userdata 
---@return number  �ɹ��������ͱ��|ʧ�ܡ���-1
---@nodiscard
function lib996:gethair(actor) end;

---���÷���
---*  actor  	userdata  ��Ҷ���
---*  hair  	number  ���ͱ��0��Ϊ�޷���
---@param  actor  	userdata 
---@param  hair  	number 
---@return number  �ɹ��������ͱ��|ʧ�ܡ���-1
---@nodiscard
function lib996:sethair(actor,hair) end;

---����Ʒ
---@return boolean   true���ɹ� | false��ʧ��
---@nodiscard
function lib996:takeitem(actor,itemname,qty,IgnoreJP) end;

---����װ��λ��ȡװ������
---* actor  userdata  ��Ҷ���
---* where  number   	װ��λ��
---@param actor  userdata 
---@param where  number 
---@return userdata  | �ɹ�������װ������ | ʧ�ܣ�����`"0"` �� nil
---@nodiscard
function lib996:linkbodyitem(actor,where) end;

---��ȡ��Ʒʵ����Ϣ
---* actor  userdata  ��Ҷ���
---* item  userdata   	��Ʒ����
---* id number   	1:ΨһID2:��ƷID3:ʣ��־�4:���־�5:��������6:��״̬
---@param actor  userdata 
---@param item  userdata 
---@param id number 
---@return number  | ��Ӧ��ֵ,������Ϊ0
---@nodiscard
function lib996:getiteminfo(actor,item,id) end;

---��ȡ��Ʒ��¼��Ϣ
---* actor  userdata  ��Ҷ���
---* item  userdata   ��Ʒ����
---* type number  	[1,2,3]
---* position number   	��type=1,ȡֵ��Χ[0..49]type=2,ȡֵ��Χ[0..19]
---@param actor  userdata 
---@param item  userdata 
---@param type number 
---@param position number 
---@nodiscard
function lib996:getitemaddvalue(actor,item,type,position) end;

---�˳�ǰ����
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return boolean   true ����  false ��ֹ
---@nodiscard
function on_pre_logout(actor) end;

---�������GMȨ�޵ȼ�
---* actor  userdata  ��Ҷ���
---* level  number  GMȨ�޵ȼ�
---@param actor  userdata 
---@param level  number 
---@nodiscard
function lib996:setgmlevel(actor,level) end;

---������Ʒ��¼��Ϣ
---* actor  userdata  ��Ҷ���
---* item  userdata  ��Ʒ����
---* type number   [1,2,3]
---* position number   	��type=1,ȡֵ��Χ[0..49]type=2,ȡֵ��Χ[0..19]
---* value number  ������Ʒ��Ӧλ��ֵ
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

---ˢ����Ʒ��Ϣ��ǰ��
---* actor  userdata  ��Ҷ���
---* item  userdata  ��Ʒ����
---@param actor  userdata 
---@param item  userdata 
---@nodiscard
function lib996:refreshitem(actor,item) end;

---�����л�ǰ
---* actor  userdata  ��Ҷ���
---* guild  userdata  �л����
---* name  string  �л�����
---@param actor  userdata 
---@param guild  userdata 
---@param name  string 
---@return boolean  true��������|false������ֹ
---@nodiscard
function on_add_guild_pre(actor,guild,name) end;

---��ʱ�ص�(��ͼ)
---@nodiscard
function lib996:delaymapgoto(mapid,time,strfun,param,vmID) end;

---�жϳ�ǽ�Ƿ����
---* param  number  param: 1-���,2-�м�,3-�ұ�
---@param param  number 
---@return boolean   ��١���true|û����١���false
---@nodiscard
function lib996:iscastlewallbroken(param) end;

---�޸���ǽ
---* param  number  param: 1-���,2-�м�,3-�ұ�
---@param param  number 
---@nodiscard
function lib996:repaircastlewall(param) end;

---�����ͼɱ������
---* actor  userdata  ��Ҷ���(����)
---* monobj  userdata  �������
---* killer  userdata  ��ɱ�߶���
---@param actor  userdata 
---@param monobj  userdata 
---@param killer  userdata 
---@nodiscard
function killmon(actor,monobj,killer) end;

---�ͻ���������Ϣ����ʱ����
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function jsonrequestexcept(actor) end;

---�жϴ����Ƿ����
---@return boolean   ��١���true|û����١���false
---@nodiscard
function lib996:iscastledoorbroken() end;

---�������ʱ����
---* actor  userdata  ��Ҷ���
---* id  number  ����id
---@param actor  userdata 
---@param id  number 
---@nodiscard
function completetask(actor,id) end;

---ֹͣ�һ�����
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function stopautoplaygame(actor) end;

---���ɱ�ִ���
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function groupkillmon(actor) end;

---�ڳ�����ָ��Ѱ·�㴥��
---@nodiscard
function carpathend() end;

---�޸�����
---@nodiscard
function lib996:repaircastledoor() end;

---��ѯ���������Ƿ����
---* actor  userdata  ��Ҷ���
---* name  string   Ҫ��ѯ������
---@param actor  userdata 
---@param name  string 
---@return number  0-����ʹ�� 1��2��6-���Ʊ����� 3-�����Ѿ����� 5-���Ȳ�����Ҫ��
---@nodiscard
function lib996:queryhumnameexist(actor,name) end;

---�ж������Ƿ����
---* param  number  param: 0-3
---@param param  number 
---@return boolean   ��١���true|û����١���false
---@nodiscard
function lib996:iscastleguarddeath(param) end;

---�޸�����
---* param  number  param: 0-3
---@param param  number 
---@nodiscard
function lib996:repaircastleguard(param) end;

---�жϹ������Ƿ����
---* param  number  param: 0-11
---@param param  number 
---@return boolean   ��١���true|û����١���false
---@nodiscard
function lib996:iscastlearcherdeath(param) end;

---�޸�������
---* param  number  param: 0-11
---@param param  number 
---@nodiscard
function lib996:repaircastlearcher(param) end;

---������������
---* actor  userdata  ���˶���
---* mon  userdata  ��������
---@param actor  userdata 
---@param mon  userdata 
---@nodiscard
function selfkillslave(actor, mon) end;

---ɱ����������
---* actor  userdata  �����߶���
---* mon  userdata  ��������
---* monname  userdata  ��������
---@param actor  userdata 
---@param mon  userdata 
---@param monname  userdata 
---@nodiscard
function killslave(attacks, mon, monname) end;

---��ȡʵ����Ʒ��ʾ����
---* makeid  number    ��ƷΨһid
---@param makeid  number 
---@return string  | ��ʾ����|
---@nodiscard
function lib996:getitemshowname(makeid) end;

---����ʵ����Ʒ��ʾ����
---* actor  userdata  ��Ҷ���
---* makeid  number    ��ƷΨһid
---* name string   ��ʾ����
---@param actor  userdata 
---@param makeid  number 
---@param name string 
---@return boolean   true�����޸ĳɹ�|false����ʧ��|
---@nodiscard
function lib996:setitemshowname(actor,makeid,name) end;

---��ȡʵ����Ʒ������ɫ
---* makeid  number    ��ƷΨһid
---@param makeid  number 
---@return number  | ��ʾ��ɫ|
---@nodiscard
function lib996:getitemnamecolor(makeid) end;

---����ʵ����Ʒ������ɫ
---* actor  userdata  ��Ҷ���
---* makeid  number    ��ƷΨһid
---* color number    ��ɫ(0-255)
---@param actor  userdata 
---@param makeid  number 
---@param color number 
---@return boolean   true�����޸ĳɹ�|false����ʧ��|
---@nodiscard
function lib996:setitemnamecolor(actor,makeid,color) end;

---��̯����
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return boolean   true������,false��������
---@nodiscard
function startmyshop(actor) end;

---���ö�����Ӫ
---*  actor  	userdata  ��Ҷ���or�������
---*  camp 	number  ��Ӫ
---@param  actor  	userdata 
---@param  camp 	number 
---@nodiscard
function lib996:setcamp(actor,camp) end;

---��ȡ������Ӫ
---*  actor  	userdata  ��Ҷ���or�������
---@param  actor  	userdata 
---@return number  ���ؽ�ɫ��Ӫ
---@nodiscard
function lib996:getcamp(actor) end;

---�жϸõ�ͼ�Ƿ��иö�ʱ��
---* mapid  string  	��ͼID
---* timeid  number  ��ʱ��ID
---@param mapid  string 
---@param timeid  number 
---@return boolean   true������|false������
---@nodiscard
function lib996:hasenvirtimer(mapid,timeid) end;

---����Զ����������·��
---* group  string  ·��ID
---* json  string  ·��json
---@param group  string 
---@param json  string 
---@nodiscard
function lib996:addmonactgroup(group,json) end;

---�ù����ͷ��Զ��弼��
---* player   userdata  	�������
---* skillid   userdata  	�Զ��弼��id
---* x   number  	x����
---* y   number  	y����
---* actor   userdata  	Ŀ�����
---@param player   userdata 
---@param skillid   userdata 
---@param x   number 
---@param y   number 
---@param actor   userdata 
---@nodiscard
function lib996:mon_docustommagic(player,skillid,x,y,actor)  end;

---���ü�����Ч
---* actor userdata  	��Ҷ���
---* skillname string  	��������
---* groupid number  ��Чid
---@param actor userdata 
---@param skillname string 
---@param groupid number 
---@nodiscard
function lib996:setskilleffgroup(actor,skillname,groupid) end;

---���ü�����Ч
---* actor userdata  	��Ҷ���
---* skillname string  	�������� Ϊ" * " ��Ϊ���м���
---@param actor userdata 
---@param skillname string 
---@nodiscard
function lib996:resumeskilleffgroup(actor,skillname) end;

---������ʱNPC(��չ)
---* mapid  string   ��ͼid
---* x  number   x����
---* y  number   y����
---* npcjson  string  npc��Ϣ
---@param mapid  string 
---@param x  number 
---@param y  number 
---@param npcjson  string
---@return number  ������npcid
---@nodiscard
function lib996:createnpcex(mapid,x,y,npcjson) end;

---ɾ���Զ����������·��
---* group  string  ·��ID
---@param group  string 
---@nodiscard
function lib996:delmonactgroup(group) end;

---����·��ID�����Զ����������·��
---* mon   userdata  �Զ���������
---* group  string  ·��ID
---* route  number  ��N��·����ʼִ��
---@param mon   userdata 
---@param group  string 
---@param route  number 
---@nodiscard
function lib996:monsetactgroup(mon,group,route) end;

---�����Զ��������ʱ����·��
---* mon   userdata   �Զ���������
---* X  number  X����
---* Y  number  Y����
---* Range  number  Ŀ����С(�ߵ��˷�Χ��Ҳ��Ϊ����Ŀ���)
---* AtkType  number   0-������/1-��������/2-��������
---* Guard  number  �ػ���Χ(�����˷�Χ����·����,·������ݹ����ж����ȶ�̬����,�����������Ŀ��㷽���,������Ȼ��ͷ�����)
---* ArriveLbl  string  ���������֮����õĴ���
---@param mon   userdata 
---@param X  number 
---@param Y  number 
---@param Range  number 
---@param AtkType  number 
---@param Guard  number 
---@param ArriveLbl  string 
---@nodiscard
function lib996:monsetact(mon,X,Y,Range,AtkType,Guard,ArriveLbl) end;

---����Զ����������·��(������ʱ)
---* mon   userdata   �Զ���������
---@param mon   userdata 
---@nodiscard
function lib996:monclractgroup(mon) end;

---��������
---* actor  userdata  ��Ҷ���
---* level  number  ��ǰ�ȼ�
---@param actor  userdata 
---@param level  number 
---@nodiscard
function on_level_up(actor,level) end;

---��ȡ������гƺ�
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return table |�ɹ������ƺ�id��|ʧ�ܡ�������"" ������󷵻� nil
---@nodiscard
function lib996:getalltitle(actor) end;

---ж����ҵ�ǰչʾ�ƺ�
---* actor  userdata  ��Ҷ���
---* id  number  �ƺ�id
---@param actor  userdata 
---@param id  number 
---@return boolean  true�����ɹ�|false����ʧ��
---@nodiscard
function lib996:discurtitle(actor,id) end;

---��ȡ��ҵ�ǰչʾ�ƺ�
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return number �ɹ��������سƺ�id|ʧ�ܡ�������-1
---@nodiscard
function lib996:getcurtitle(actor) end;

---����Զ��尲ȫ��
---*  map  	string  ��ͼID
---*  safeid  	number  �Զ��尲ȫ��ID
---*  itype  	number  ���� �ο�cfg_startponumber���� ����
---*  ponumberjson  	string  ��ȫ��json �ο�cfg_startponumber�� ����
---@param  map  	string 
---@param  safeid  	number 
---@param  itype  	number 
---@param  ponumberjson  	string 
---@nodiscard
function lib996:addsafezone(map,safeid,itype,pointjson) end;

---�жϸõ�ͼ�Ƿ��и��Զ��尲ȫ��
---*  map  	string  ��ͼID
---*  safeid  	number  �Զ��尲ȫ��ID
---@param  map  	string 
---@param  safeid  	number 
---@return boolean   true������|false������
---@nodiscard
function lib996:hassafezone(map,safeid) end;

---���������ϸ��־
---* UserID   string  ���ΨһID
---* Minute  number  ������¼ʱ�� ��λ������
---@param UserID   string 
---@param Minute  number 
---@nodiscard
function lib996:setdetaillog(UserID,Minute) end;

---ɾ���õ�ͼ���Զ��尲ȫ��
---*  map  	string  ��ͼID
---*  safeid  	number  �Զ��尲ȫ��ID
---@param  map  	string 
---@param  safeid  	number 
---@nodiscard
function lib996:delsafezone(map,safeid) end;

---����һ������
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return userdata | �������
---@nodiscard
function lib996:newclone(actor) end;

---���ɼ���
---* map  ostringject  ��¼��ͼ
---* x  number  X����
---* y  number  Y����
---* range  number  ��Χ
---* job  number  ְҵ(0=սʿ 1=��ʦ 2=��ʿ 3=���)
---* num  number  ����
---* login  number  ��¼ģʽ(0=˳�� 1=��˳ 2=���)
---* sex  number  �Ա�(0=�� 1=Ů)
---* attack  boolean  �Ƿ����Զ�ս��
---@param map  ostringject 
---@param x  number 
---@param y  number 
---@param range  number 
---@param job  number 
---@param num  number 
---@param login  number 
---@param sex  number 
---@param attack  boolean 
---@return number  �ɹ���¼���� | ȫʧ�ܷ���-1
---@nodiscard
function lib996:dumlogon(map,x,y,range,job,num,login,sex,attack) end;

---��ȡ�ƺ�ʣ��ʱ��
---* actor  userdata  ��Ҷ���
---* id  number  �ƺ�id
---@param actor  userdata 
---@param id  number 
---@return number  -2����ȡʧ��,�����޴˳ƺ� | -1�����ô��� | ����ʣ��ʱ��
---@nodiscard
function lib996:gettitletime(actor,id) end;

---�ж�����Ƿ�ӵ�иóƺ�
---* actor  userdata  ��Ҷ���
---* id  number  �ƺ�id
---@param actor  userdata 
---@param id  number 
---@return boolean   true���� | false����
---@nodiscard
function lib996:hastitle(actor,id) end;

---�ж϶����ܷ���·
---*  actor  	userdata  ����
---@param  actor  	userdata 
---@return boolean   true������ | false��������
---@nodiscard
function lib996:iswalk(actor) end;

---�ж϶����ܷ��ܲ�
---*  actor  	userdata  ����
---@param  actor  	userdata 
---@return boolean   true������ | false��������
---@nodiscard
function lib996:isrun(actor) end;

---�ж��߼����Ƿ�Ϊ��
---*  mapid  	string  ��ͼID
---*  x  	number  	x����
---*  y  	number  	y����
---@param  mapid  	string 
---@param  x  	number 
---@param  y  	number 
---@return boolean   true��Ϊ�� | false����Ϊ��
---@nodiscard
function lib996:isempty(mapid, x, y) end;

---buff�ı�ʱ
---* actor  userdata  ����
---* buffid  number  buffid
---* buffgroupid  number  �ı��buffid
---* operation  userdata  �������ͣ�number  1����� 2������ 4��ɾ��
---* actObj  userdata  �ͷ���
---@param actor  userdata 
---@param buffid  number 
---@param buffgroupid  number 
---@param operation  userdata 
---@param actObj  userdata 
---@nodiscard
function buffchange(actor,buffid,buffgroupid,operation, actObj) end;

---����һ��ʰȡ
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function lib996:autopickitembybtn(actor) end;

---�ر�һ��ʰȡ
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@nodiscard
function lib996:stopautopickitembybtn(actor) end;

---��ȡ��ͼ�����й���
---*  mapid  	string  ��ͼid
---*  monid  	number  ����id,Ϊ-1ʱ��Ϊ����(-1��δ����)
---*  ignbb  	boolean  �Ƿ���Ա��� true:���� false:������
---@param  mapid  	string 
---@param  monid  	number 
---@param  ignbb  	boolean 
---@return table  |�ɹ������������|ʧ�ܡ���nil
---@nodiscard
function lib996:getmon(mapid,monid,ignbb) end;

---��ȡ��ͼ���������
---*  mapid  	string  ��ͼid
---*  igndied  	number  �Ƿ����������ɫ true:���� false:������
---*  isdum  	boolean  �Ƿ���Լ��� true:���� false:������
---@param  mapid  	string 
---@param  igndied  	number 
---@param  isdum  	boolean 
---@return table |�ɹ�������Ҷ���|ʧ�ܡ���nil
---@nodiscard
function lib996:getplay(mapid,igndied,isdum) end;

---���ط����б�
---* actor  userdata  ��Ҷ���
---@param actor  userdata 
---@return table | �б�
---@nodiscard
function lib996:clonelist(actor) end;

---���ý�ɫ����ʣ����ȴʱ��
---* actor userdata  	��Ҷ���
---* id number  	����id
---* time number  cdʱ��(����)0������ˢ��
---@param actor userdata 
---@param id number 
---@param time number 
---@nodiscard
function lib996:setskillcd(actor,id,time) end;

---��ȡ��ɫ����ʣ����ȴʱ��
---* actor userdata  	��Ҷ���
---* id number  	����id
---@param actor userdata 
---@param id number 
---@return number  �ɹ���ʣ��CDʱ��-��λ����,ʧ�ܣ�-1
---@nodiscard
function lib996:getskillcd(actor,id) end;

---���ý�ɫ���������ȴʱ��
---* actor userdata  	��Ҷ���
---* id number  	����id
---* time number  cdʱ��(����)
---@param actor userdata 
---@param id number 
---@param time number 
---@nodiscard
function lib996:setskillmaxcd(actor,id,time) end;

---����ɼ���ʱ����
---* actor  userdata  ��Ҷ���
---* mon  number  �������
---* monid  number  ����id
---@param actor  userdata 
---@param mon  number 
---@param monid  number 
---@nodiscard
function collectmon(actor,mon,monid) end;

---΢�Ź��ں�KEY��֤�ɹ�ʱ
---* actor  userdata  ��Ҷ���
---* wechatkey  number  �����΢�Ź��ں�key
---* openid  number  openid
---@param actor  userdata 
---@param wechatkey  number 
---@param openid  number 
---@nodiscard
function on_bindrewechat(actor,wechatkey,openid) end;

---����΢�Ź��ں�KEYʱ
---* actor  userdata  ��Ҷ���
---* wechatkey  number  �����΢�Ź��ں�key
---@param actor  userdata 
---@param wechatkey  number 
---@nodiscard
function on_bindwechat(actor,wechatkey) end;

---����΢�Ź��ں�KEY
---* actor   userdata  ��Ҷ���
---* wtype  number  ��������,1����,2�����,3����֤
---@param actor   userdata 
---@param wtype  number 
---@nodiscard
function lib996:bindwechat(actor,wtype) end;

---���΢�Ź��ں�KEY
---* actor   userdata  ��Ҷ���
---@param actor   userdata 
---@nodiscard
function lib996:clearwechat(actor) end;

---��ȡ��Ʒ�󶨹���
---* makeid  number  ��Ʒmakeindex
---@param makeid  number 
---@return number ���ذ󶨹���
---@nodiscard
function lib996:getitembind(makeid)  end;

---��Ʒ���뱳��ǰ����
---* actor  userdata  ��Ҷ���
---* itemid  number   ��Ʒid
---* itemmakeid  number    makeid(ΨһID)
---@param actor  userdata 
---@param itemid  number 
---@param itemmakeid  number 
---@return boolean   true:�������,false:ϵͳ����
---@nodiscard
function on_addbag_pre(actor,itemid,itemmakeid) end;

---��ȡ��ǽ����
---* param  number  param: 1-���,2-�м�,3-�ұ�
---@param param  number 
---@return userdata | ���س�ǽ����
---@nodiscard
function lib996:getcastlewall(param) end;

---��ȡ��Ʒ�󶨹���
---* makeid  number  ��Ʒmakeindex
---@param makeid  number 
---@return number ��Ʒ�󶨹���
---@nodiscard
function lib996:getitembind(makeid,bind)  end;

---��ȡ��������
---* param  number  param: 0-3
---@param param  number 
---@return userdata | ������������
---@nodiscard
function lib996:getcastleguard(param) end;

---��ȡ���Ŷ���
---@return userdata | ���س��Ŷ���
---@nodiscard
function lib996:getcastledoor() end;

---��ȡ�����ֶ���
---* param  number  param: 0-11
---@param param  number 
---@return userdata | ���ع����ֶ���
---@nodiscard
function lib996:getcastlearcher(param) end;

---�Ӷ�������
---* actor  userdata  ��Ҷ���
---* itemmakeid  number    makeid(ΨһID)
---* itemid  number   ��Ʒid
---@param actor  userdata 
---@param itemmakeid  number 
---@param itemid  number 
---@nodiscard
function dropitemex(actor, itemmakeid, itemid) end;

---��������������Χ
---* actor  userdata  ��Ҷ���
---* nType  number  ����0:װ����ӿ�ȡ��ֵ1:����+�ӿ�(����װ��)2:����+װ��+�ӿ�
---* nValue  number  ����������Χֵ
---@param actor  userdata 
---@param nType  number 
---@param nValue  number 
---@nodiscard
function lib996:setchrcandle(actor, nType, nValue) end;

return lib996;