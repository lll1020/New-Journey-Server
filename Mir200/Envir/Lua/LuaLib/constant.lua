constant = {}

--��������
constant.pz_xrjn =  {{3,3},{7,3},{26,3},{27,3},{12,3}}                                                    --���˼���
dofile("Envir/lua/Data/huishou.lua")                                                                      --������Ʒ����
dofile("Envir/lua/Data/daluditu.lua")                                                                     --��½��ͼ����
dofile("Envir/lua/Data/xilieditu.lua")                                                                    --ϵ�е�ͼ����
dofile("Envir/lua/Data/paokujl.lua")                                                                      --�����ܿά��
dofile("Envir/lua/Data/jinzhigj.lua")                                                                      --��ֹ��¼��ͼ
dofile("Envir/lua/Data/guaiwutype.lua")                                                                        --��������
dofile("Envir/lua/Data/teshudata.lua")                                                                             --��������



constant.pz_hanzi          = {"һ","��","��","��","��","��","��","��","��","ʮ",}                            --����
constant.pz_ldql          = {}        --ÿ������ƺ�
constant.pz_jndy          = {"��������","ʩ����","��ɱ����","��ɱ����","�����䵶","�һ𽣷�","Ұ����ײ","���ս���","����ն","ʮ��һɱ"}        --���ܵ���
constant.pz_ddzbjl          = {  }                                          --���������Ľ���
constant.pz_zzdkjl          = { }                                          --��Ӫ�Կ��Ľ���

constant.pz_qrbq          = 
{{{5,10,20,30,60,120,180,360},{10,20,30,40,50,100,200,500,1000},{1,2,3,4,5,6,7},{10,20,30,40,50,60,70,80}},
{{1000,2000,3000,4000,5000,10000,20000,50000},{1000,2000,3000,4000,5000,10000,20000,50000},{10000,20000,30000,40000,50000,60000,70000},{10000,20000,30000,40000,50000,60000,70000,80000}}}        --���ձ�ǿ����  [1]=Ҫ�� [2]=����
constant.pz_txzrjl       = {"128Ԫ��ʵ��ֵ","40Ԫ��ʵ��ֵ","38Ԫ��ʵ��ֵ","36Ԫ��ʵ��ֵ","32Ԫ��ʵ��ֵ","30Ԫ��ʵ��ֵ","28Ԫ��ʵ��ֵ","26Ԫ��ʵ��ֵ","24Ԫ��ʵ��ֵ","22Ԫ��ʵ��ֵ"}

constant.zs_zhuangbeiwei = {
    [401] = 74,
    [402] = 75,
    [403] = 76,
    [404] = 85,
    [405] = 86,
    [406] = 88,
    [407] = 89,
    [408] = 90,
    [409] = 91,
    [410] = 92,
    [411] = 93,
    [412] = 94,
    [413] = 95,
    [414] = 96,
    [415] = 97,
    [416] = 98,
    [417] = 99,
    [418] = 100,
    [419] = 101,
    [420] = 102,
    [421] = 103,
    [422] = 115,
    [423] = 116,
    [424] = 117,
    [425] = 118,
    [426] = 119,
}
--��ֹ��ʬ����
constant.pz_jzbs          = {

}
constant.pz_tyrcjl          = {10,8,5,3}                                          --������Ľ���
constant.pz_bossys          = {[70] = true, [141] = true, [58] = true, [251] = true}                            --boss������ɫ
constant.cz_jeyz = {[18] = 1,[38] = 2,[68] = 3,[128] = 4,[288] = 5,[588] = 6,[888] = 7,[1188] = 8,[1588] = 9,[1888] = 10}

constant.pz_tgdssg          = {{"�����ϰ�",1,141,{37,41}},{"����",1,141,{201,199}},{"����",1,141,{198,84}},{"����",1,141,{206,316}},{"����",6,251,{{317,184},{337,205},{318,223},{298,203},{196,193},{208,205}}},{"���߻�",25,242},{"���߻�",70,255},{"����",15,141}}                            --����򹻲໬ˢ��

constant.pz_htqx = {[1313760734] = "lll"}           --��̨Ȩ��
constant.pz_zbqd = {}              --�����˺������������ֱ�Ӹ�
constant.pz_zbfc = {[1313760734] = "lll"}                  --��������Ȩ��




--�������� 1.��ť  2.NPC  3.����  4.ֱ�ӽ��� 5.˫��NPC��ˢ��ɱ������  6. ֱ����NPC��ˢ��ɱ������ �����  7.ֱ����NPC��ˢ��ɱ������ BOSS  8.ֱ����NPC��ˢ��ɱ������ С��+BOSS 
--��֤����  1.�ַ���,����,��ֵ,��ֵ   2.װ��λ��,װ��IDX  3.�ƺ�����  4.װ���������� λ��,���,����,dj
--�����������ͣ�ts = {num,{}}
--1���ύ������
--2��ɱ����  ������ֻ + ���
--3���ύ���  �����Ʒ��
constant.rw_syb = {
    [1] = {99},

    [1300] = {50,"��������",21,96,76}, --��ħ��ؼ�
}


--ȫ��G����
constant.G_kqts           = "G0"                                                                          --��������0��+1
constant.G_kqfz           = "G1"                                                                          --��������
constant.G_kqyz           = "G2"                                                                          --������֤
constant.G_txzz           = {"G3","G4"}                                                                   --��ѡ֮��ʱ��,����
constant.G_pkts           = "G5"                                                                          --�ܿ���ʾ
constant.G_hqcs           = "G6"                                                                          --���������Ա�


--ȫ��A����
constant.A_txzz           = "A0"                                                                          --��ѡ֮��json
constant.A_qqsb           = "A1"                                                                          --ȫ������json
constant.A_tjxx           = "A3"                                                                          --ͳ����Ϣ��
constant.A_csqmingdan           = "A4"                                                                          --����ʹ��
constant.A_wgrymd          = "A300"                                                                          --Υ����Ա����


--����T����
constant.T_sgcf           = "T1"                                                                          --��ɱ�ִ���json
constant.T_hsdg           = "T2"                                                                          --���մ�����
constant.T_dljq          = "T3"                                                                          --������JSON
constant.T_czlb           = "T4"                                                                         --�������
constant.T_jls           = "T5"                                                                           --��¼ʯ
constant.T_zxrw           =  "T6"                                                                        --֧���������
constant.T_rwjl        = "T7"                                                                             --������ȡ��¼
constant.T_xybl           = "T8"                                                                         --���˱���
constant.T_grss           = "T9"                                                                         --�����ױ�
constant.T_qrbq           = "T10"                                                                        --��������
constant.T_szjl           = "T16"                                                                        --ʱװ��¼
constant.T_xldtsg           = "T17"                                                                        --ϵ�е�ͼɱ��
constant.T_xldtsgjl           = "T18"                                                                     --ϵ�е�ͼɱ�ֽ���
constant.T_aigj           = "T23"                                                                        --ai�һ�
constant.T_rwwp           = "T24"                                                                        --������Ʒ
constant.T_ywl           = "T25"                                                                        --����¼
constant.T_hdjl           = "T28"                                                                        --�����
constant.T_zscl          =  "T29"                                                                      --ת�����ϵ���
constant.T_txzr          =  "T30"                                                                      --��ѡ֮�˵���

constant.T_sq_jd     =  "T38"                                                                      --�ر���������
constant.T_tshs     =  "T41"                                                                      --�������
constant.T_rwsg     =  "T42"                                                                      --��������ɱ��
constant.T_dlsgjl     =  "T45"                                                                      --��½ɱ������



--����J����
constant.J_mrfhw          = "J1"                                                                          --ÿ��ʹ�ø������
constant.J_jsgw         =   {"J4","J5"}                                                                    --ÿ�մ�С��--����
constant.J_zxsj         =   "J9"                                                                         --��������ʱ��
constant.J_qrqd         =   "J11"                                                                         --����ǩ����¼
constant.J_hbdh         =   {"J13","J14"}                                                                 --ÿ�ջ��Ҷһ�
constant.J_zscz         =  "J17"                                                                     --ÿ����ʵ��ֵ��¼
constant.J_isgs         =    "J32"                                                                     --�Ƿ�������ɳ


--����U����
constant.U_zxrw           = {"U1","U2"}                                                                 --����ID,����
constant.U_czyz           = "U3"                                                                          --��ֵ��֤
constant.U_czje           = "U4"                                                                          --��ֵ�����ת
constant.U_zjbh           = "U5"                                                                         --�㼣��ż�¼
constant.U_jskb           = "U6"                                                                         --��ɱ�񱩴���
constant.U_zhixrw         = "U7"                                                                          --֧������ID
constant.U_zhixrwjd       = {"U8","U9","U10"}                                                           --֧���������
constant.U_srsl           = "U11"                                                                        --ɱ������
constant.U_fldt           = {"U12","U13"}                                                                --������������,ɱ��
constant.U_hqtb           = "U14"                                                                        --��Һ��������Ƿ�һ��

constant.U_dkb           = "U30"                                                                        --���--����


--���˱�ʶ
constant.BS_huishou       =  {1,2,3,4,5}                                                                    --�Զ������,�Զ��Ծ���,�Զ�����,�Զ����տ���
constant.BS_sckg          =  7                                                                            --�׳忪��
constant.BS_AIgj          =  18                                                                           --AI�һ�����
constant.BS_mztq          =  19                                                                           --����һ������
constant.BS_xsth          =  21                                                                           --��ʱ�ػ�

constant.BS_ngkg          =  299                                                                           --�ڹұ����﹥�����(CD30��)
constant.BS_dtcs          =  300                                                                          --��ͼ�������һ���
constant.BS_zcjfb         =  302                                                                          --������

constant.BS_zzchxf          =  402                                                                          --�����ƺ�--�޸���

--��չN$����
constant.N_dqgs           = "N$��ǰ����"                                                                   --��ǰ���ٰٷֱ�
constant.N_gscd           = "N$����CD"                                                                     --��ǰ�����л�CD
constant.N_jnsh           = {"N$�����˺�","N$��ɱ�˺�","N$�����˺�","N$�һ��˺�","N$�����˺�","N$�����˺�"}    --�����˺��ӳ�
constant.N_jmjnsh           = {"N$�һ��˺�","N$�����˺�","N$�����˺�"}    --���⼼���˺��ӳ�
constant.N_jnjm           = "N$���ܼ���"                                                                   --�����˺�����
constant.N_Aigj           = {"N$���������","N$�޹����","N$�Զ���ͼ","N$�������","N$��ʱ�����ͼ"}                          --AI�һ���ʱ����
constant.N_jsys           = "N$������ʱ"                                                                   --������ʱ
constant.N_znpc           = "N$��NPC"                                                                      --����Ѱ��NPC
constant.N_ddcs           = "N$boss����"                                                                      --boss���㴫��

constant.N_lbyz           = "N$�����֤"                                                                   --��ֵ�����֤
constant.N_rwlg           = "N$�����Թ�"                                                                   --������֤
constant.N_sqms           = "N$ʰȡģʽ"                                                                   --ʰȡģʽ
constant.N_qlscd          = "N$������CD"                                                                   --������
constant.N_gjms           = "N$�һ�ģʽ"                                                                   --�һ�����ģʽ�л�
constant.N_tyecmb         = "N$������"                                                                   --���������
--��չS$����

constant.S_buffgjq        = "S$����ǰbuff"                                                                 --����ǰbuff��Ϣ
constant.S_buffgwq        = "S$��������ǰbuff"                                                             --��������ǰbuff��Ϣ
constant.S_buffrwq        = "S$��������ǰbuff"                                                             --��������ǰbuff��Ϣ

constant.S_buffgjh        = "S$������buff"                                                                 --������buff��Ϣ
constant.S_buffgwh        = "S$���������buff"                                                             --���������buff��Ϣ
constant.S_buffrwh        = "S$���������buff"                                                             --���������buff��Ϣ

constant.S_buffbgjq       = "S$������ǰbuff"                                                               --������ǰbuff��Ϣ
constant.S_buffbgwq       = "S$�����﹥��ǰbuff"                                                           --�����﹥��ǰbuff��Ϣ
constant.S_buffbrwq       = "S$�����﹥��ǰbuff"                                                           --�����﹥��ǰbuff��Ϣ

constant.S_buffsgcf       = "S$ɱ�ִ���buff"                                                               --ɱ�ִ���buff��Ϣ
constant.S_bufffuhuo      = "S$�����buff"                                                               --�����buff��Ϣ

constant.S_buffqiehuan    = "S$�л���ͼbuff"                                                               --�л���ͼbuff��Ϣ

constant.S_sdlmjdt        = "S$�ؾ�ǰ��ͼ"                                                                 --�Ĵ�½�ؾ���¼����ǰ��ͼ
constant.S_houtaibf       = "S$��̨����"                                                                      --��̨������





return constant