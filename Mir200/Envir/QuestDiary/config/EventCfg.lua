EventCfg = {}

--�����¼�
EventCfg.onTest                     = "onTest"                        --��������
EventCfg.onStartUp                  = "onStartUp"                     --m2����
EventCfg.onNewHuman                 = "onNewHuman"                    --�½�ɫ��һ�ε�¼    (������actor)
EventCfg.onLogin                    = "onLogin"                       --��¼    (������actor)
EventCfg.onLoginAttr                = "onLoginAttr"                   --��¼��������    (������actor, ��¼��������)
EventCfg.onOtherAttr                = "onOtherAttr"                   --��¼��������    (������actor, ��¼��������)
EventCfg.onLoginEnd                 = "onLoginEnd"                    --��¼���    (������actor, ��¼ͬ������)
EventCfg.onKFLogin                  = "onKFLogin"                    --�����½����
EventCfg.onKuaFuEnd                 = "onKuaFuEnd"                    --����ر�������
EventCfg.onKillMon                  = "onKillMon"                     --�����ͼɱ��    (������actor, �����������, ��������idx)
EventCfg.onkillplay                 = "onkillplay"                    --�����ͼɱ��
EventCfg.onkillplayQiYu             = "onkillplayQiYu"                --ɱ����������
EventCfg.onPlaydie                  = "onPlaydie"                     --��������
EventCfg.onPlaydieQiYu              = "onPlaydieQiYu"                 --������������
EventCfg.onNextDie                 = "onNextDie"                     --����ǰ����
EventCfg.onPlayLevelUp              = "onPlayLevelUp"                 --�������    (������actor, ��ǰ�ȼ�, ֮ǰ�ȼ�)
EventCfg.onTakeOnEx                 = "onTakeOnEx"                    --��װ��goPlayerVar
EventCfg.onTakeOffEx                = "onTakeOffEx"                   --��װ��
EventCfg.onPickUpItemfrontex        = "onPickUpItemfrontex"           --ʰȡ����ǰ����
EventCfg.onGuildAddMemberAfter      = "onGuildAddMemberAfter"         --�л���ӳ�Ա�󴥷�
EventCfg.onCloseGuild               = "onCloseGuild"                  --��ɢ�л�
EventCfg.onLoadGuild                = "onLoadGuild"                   --�����л�
EventCfg.onGuilddelMember           = "onGuilddelMember"              --�˳��л�ʱ����
EventCfg.onMondropItemex            = "onMondropItemex"               --���ﱬ��װ������
EventCfg.onAttackDamageBB           = "onAttackDamageBB"              --��������ǰ����
EventCfg.onPlayItemExpired          = "onPlayItemExpired"             --�����ʱװ�����ڴ���


EventCfg.Myonlookhuminfo            = "Myonlookhuminfo"               --�鿴װ������--�Լ�
EventCfg.Tgtonlookhuminfo           = "Tgtonlookhuminfo"              --�鿴װ������--����
EventCfg.onCheckDropUseItems        = "onCheckDropUseItems"           --������װ��ǰ����

EventCfg.ReliveCountdown_1          = "ReliveCountdown_1"             --�����ʱ  ��ÿ��ִ��1�Σ� ��ʱ�� 101
EventCfg.ReliveCountdown_2          = "ReliveCountdown_2"             --�����ʱ  ��ÿ��ִ��1�Σ� ��ʱ�� 102
EventCfg.ReliveCountdown_3          = "ReliveCountdown_3"             --�����ʱ  ��ÿ��ִ��1�Σ� ��ʱ�� 103

EventCfg.onTakeOn0                  = "ontakeon0"                    --�·�λ��----��   (����װ��)
EventCfg.onTakeOff0                 = "onTakeOff0"                   --�·�λ��----��   (����װ��)

EventCfg.onTakeOn9                  = "onTakeOn9"                    --����λ��----��   (����װ��)
EventCfg.onTakeOff9                 = "onTakeOff9"                   --����λ��----��   (����װ��)

EventCfg.onTakeOn11                  = "onTakeOn11"                  --����λ��----��   (����װ��)
EventCfg.onTakeOff11                 = "onTakeOff11"                   --����λ��----��   (����װ��)


EventCfg.onTakeOn40                  = "onTakeOn40"                    --���κ�λ��11----��
EventCfg.onTakeOff40                 = "onTakeOff40"                   --���κ�λ��11----��


EventCfg.onTakeOn72                  = "onTakeOn72"                    --���κ�λ��72----��   
EventCfg.onTakeOff72                 = "onTakeOff72"                   --���κ�λ��72----��   

EventCfg.onBuffChange              = "onBuffChange"                  --Buff����

EventCfg.onAddBag                   = "onAddBag"                      --��Ʒ������
EventCfg.onExitGame                 = "onExitGame"                    --С�˻������Ϸ
EventCfg.onTriggerChat              = "onTriggerChat"                 --������������Ϣ
EventCfg.onClicknpc                 = "onClicknpc"                    --���ĳNPC
EventCfg.onRechargeBefore           = "onRechargeBefore"              --��ֵǰ����,�޸�ʵ����(������actor, ��ֵrmb���, ��ƷID��������, ����ID)
EventCfg.onRecharge                 = "onRecharge"                    --��ֵ     (������actor, ��ֵrmb���, ��ƷID��������, ����ID)
EventCfg.onVirtualRecharge          = "onVirtualRecharge"             --�����ֵ     (������actor, ��ֵrmb���, ��ƷID��������, ����ID)
EventCfg.goEnterMap                 = "goEnterMap"                    --�����ͼ
EventCfg.goSwitchMap                = "goSwitchMap"                   --�л���ͼ
EventCfg.goLeaveMap                 = "goLeaveMap"                    --�뿪��ͼ
EventCfg.onMove                     = "onMove"                        --�ƶ����� (������actor, 0��/1��)
EventCfg.onBeginMagic               = "onBeginMagic"                  --ʹ�ü��ܴ���
EventCfg.onProHarm                  = "onProHarm"                     --����ܵ��˺����� (������actor, �˺�ֵ)

EventCfg.onAttackDamage             = "onAttackDamage"                --����ǰ����
EventCfg.onAttackDamagePlayer       = "onAttackDamagePlayer"          --����ǰ����
EventCfg.onAttackDamageMonster      = "onAttackDamageMonster"         --����ǰ����

EventCfg.onAttack                   = "onAttack"                      --��������
EventCfg.onAttackPlayer             = "onAttackPlayer"                --�������ﴥ������
EventCfg.onAttackMonster            = "onAttackMonster"               --�������ﴥ��

EventCfg.onStruck                   = "onStruck"                      --������������
EventCfg.onStruckPlayer             = "onStruckPlayer"                --�����﹥������
EventCfg.onStruckMonster            = "onStruckMonster"               --�����﹥������

EventCfg.onStruckDamage             = "onStruckDamage"                --��������ǰ����
EventCfg.onStruckDamagePlayer       = "onStruckDamagePlayer"          --�����﹥��ǰ����
EventCfg.onStruckDamageMonster      = "onStruckDamageMonster"         --�����﹥��ǰ����

EventCfg.onEnterGroup               = "onEnterGroup"                  --������鴥��
EventCfg.onLeaveGroup               = "onLeaveGroup"                  --�뿪���鴥��
EventCfg.onSendAbility              = "onSendAbility"                 --���Ըı䴥��

EventCfg.onAddSkillPower            = "onAddSkillPower"               --���Ӽ�������


EventCfg.goBill                     = "goBill"                        --��ֵ���(�¿����������۳��������ֹ�ۼƳ�ֵ)
EventCfg.onBagChange                = "onBagChange"                   --�������������ͱ仯
EventCfg.onRevive                   = "onRevive"                      --�����
EventCfg.onRecycling                = "onRecycling"                   --���մ���
EventCfg.onTakeOnNecklace           = "onTakeOnNecklace"              --������ǰ����
EventCfg.onTakeOffNecklace          = "onTakeOffNecklace"             --������ǰ����
EventCfg.onTakeOnWeapon             = "onTakeOnWeapon"                --������ǰ����
EventCfg.onTakeOffWeapon            = "onTakeOffWeapon"               --������ǰ����
EventCfg.onTakeOnDress              = "onTakeOnDress"                 --���·�ǰ����
EventCfg.onTakeOffDress             = "onTakeOffDress"                --���·�ǰ����
EventCfg.onGroupItemOnEx            = "onGroupItemOnEx"               --����װ����
EventCfg.onGroupItemOffEx           = "onGroupItemOffEx"              --����װ����

EventCfg.onShowFashion              = "onShowFashion"                 --ʱװ���Դ���
EventCfg.onNotShowFashion           = "onNotShowFashion"              --ȡ��ʱװ���Դ���

--����
EventCfg.onPickTask                 = "onPickTask"                    --��ȡ���񴥷�
EventCfg.onClickNewTask             = "onClickNewTask"                --������񴥷�
EventCfg.onChangeTask               = "onChangeTask"                  --ˢ�����񴥷�
EventCfg.onCompleteTask             = "onCompleteTask"                --������񴥷�
EventCfg.onDeleteTask               = "onDeleteTask"                  --ɾ�����񴥷�
EventCfg.onCollectTask              = "onCollectTask"                 --�ɼ�����
EventCfg.onBeforerOute              = "onBeforerOute"                 --�������ӵ�(��ת��)ǰ����

--��Ϸ�¼�
EventCfg.goPlayerVar                = "goPlayerVar"                   --�������˱���    (������actor)
EventCfg.goZSLevelChange            = "goZSLevelChange"               --ת���ȼ������仯 (������actor, ��ǰת���ȼ��� ֮ǰ��ת���ȼ�)
EventCfg.goBeforedawn               = "goBeforedawn"                  --�����˽ű�ÿ���賿����  (������actor, �賿ͬ������)
EventCfg.roBeforedawn               = "roBeforedawn"                  --�����˽ű�ÿ���賿���� (�ѿ�������)
EventCfg.goDailyUpdate              = "goDailyUpdate"                 --ÿ�ո���(�賿��ÿ�յ�һ�ε�¼)(������actor, �Ƿ�ÿ�յ�һ�ε�¼, ͬ������)
EventCfg.goCheckModule              = "goCheckModule"                 --����Ƿ���ģ��ﵽ����Ҫ��
EventCfg.goOpenModule               = "goOpenModule"                  --ĳģ��ﵽ����Ҫ��(������actor, ģ��ID)
EventCfg.goSetGem                   = "goSetGem"                      --��Ƕ��ʯ(������actor)
EventCfg.goBaoWu                    = "goBaoWu"                       --��������(������actor)
EventCfg.goNiTian                   = "goNiTian"                      --�����������(������actor)
EventCfg.goShenShou                 = "goShenShou"                    --��������(������actor)
EventCfg.goKuangBao                 = "goKuangBao"                    --������(������actor)
EventCfg.goPickUpItemEx             = "goPickUpItemEx"                --ʰȡ��Ʒ�󴥷�(������actor, item��--�ȴ�֧��num)
EventCfg.goDropItemEx               = "goDropItemEx"                  --�ӵ�������Ʒ�󴥷�
EventCfg.goCastlewarend             = "goCastlewarend"                --���ǽ���ʱ����
EventCfg.gocastlewarstart           = "gocastlewarstart"              --���ǿ�ʼʱ����
EventCfg.gocastlewaring             = "gocastlewaring"                --�����д���
EventCfg.gomapeventwalk             = "gomapeventwalk"                --ɳ�Ϳ˽��ʹ��߲�����
EventCfg.goGuild                    = "goGuild"                       --�����л�
EventCfg.goActivityState            = "goActivityState"               --�������ر�չʾ���(���� �idx,�state)

EventCfg.goActivityMap              = "goActivityMap"                 --������ͼ����(�������������Ϣ)
EventCfg.goBackMap                  = "goBackMap"                     --�뿪���ͼ����(ˢ������������Ϣ)

EventCfg.goVIPlvelup                = "goVIPlvelup"                   --����vipʱ��������(������1actor, 2viplevel)
EventCfg.goADDFashion               = "goADDFashion"                  --������Զ���ʱװ����

EventCfg.goRongHe                   = "goRongHe"                      --װ���ں�(������actor)
EventCfg.goJinJie                   = "goJinJie"                      --װ������(������actor)
EventCfg.goHecheng1                 = "goHecheng1"                    --����ϳ�
EventCfg.goHecheng2                 = "goHecheng2"                    --��Ժϳ�

EventCfg.goQuickAccess              = "goQuickAccess"                 --�򿪲����������(itemidx)
EventCfg.goItemZXBX                 = "goItemZXBX"                    --�򿪱���ѡ�����(itemidx)

EventCfg.onSelfKillSlave            = "onSelfKillSlave"                  --������������


EventCfg.onProTakeOn                = "onProTakeOn"                   --��װ������/�������������
EventCfg.onProTakeOff               = "onProTakeOff"                  --��װ������/ɾ������������
EventCfg.onProEquipDel              = "onProEquipDel"                 --�ϳ�ʱ�����ٵ���ʱ����/��������������

---------------------------------����------------------------------------------


EventCfg.onCalcAttr                 = "onCalcAttr"                    --��������
EventCfg.onCalcBeiGong              = "onCalcBeiGong"                 --���㱶��
EventCfg.onCalcBaoLv                = "onCalcBaoLv"                   --���㱬��
EventCfg.onCalcAttackSpeed          = "onCalcAttackSpeed"             --���㹥��




EventCfg.onStartingDark             = "onStartingDark"                --ҹ��ʼ����
EventCfg.onStartingDay              = "onStartingDay"                 --���쿪ʼ����

EventCfg.onChangeBaoLv              = "onChangeBaoLv"                 --���ʸı䴥��
EventCfg.onChangeBaoLvAddtion       = "onChangeBaoLvAddtion"          --���ʼӳɸı䴥��

EventCfg.onXunHangOnTime            = "onXunHangOnTime"               --Ѳ���һ���ʱ������


EventCfg.GetCastleRewards           = "GetCastleRewards"               --��ȡɳ�ǽ���
EventCfg.OpenKuangBao               = "OpenKuangBao"                   --������
EventCfg.OverloadBaoLv              = "OverloadBaoLv"                  --���ʼ������----����
EventCfg.OverloadPower              = "OverloadPower"                  --ս���������----����
EventCfg.OverloadGongSu             = "OverloadGongSu"                 --���ټ������----����
EventCfg.OverloadMoneyJinBi         = "OverloadMoneyJinBi"             --��Ҹı��----����
EventCfg.OverloadMoneyYuanBao       = "OverloadMoneyYuanBao"           --Ԫ���ı��----����
EventCfg.OverloadMoneyLingFu        = "OverloadMoneyLingFu"            --����ı��----����
EventCfg.OverloadMoneyJiFen         = "OverloadMoneyJiFen"             --��ֵ���ָı��----����
EventCfg.onHuiShouFinish            = "onHuiShouFinish"                --������ɴ���
EventCfg.onCostMoney                = "onCostMoney"                    --���Ļ��Ҵ���
EventCfg.onUseJiLuShi               = "onUseJiLuShi"                   --ʹ�ü�¼ʯ�󴥷�
EventCfg.onUPSkin                   = "onUPSkin"                       --�ռ�װ�紥��
EventCfg.onOpenJiXianQianNeng       = "onOpenJiXianQianNeng"           --��������Ǳ�ܴ���
EventCfg.onNewDay                   = "onNewDay"                       --�µ�һ�촥��
EventCfg.onEntetMirrorMap           = "onEntetMirrorMap"               --���뾵���ͼ����
EventCfg.onUseHongMingQingXiKa      = "onUseHongMingQingXiKa"          --ʹ�ú�����ϴ������
EventCfg.onUseGaiMingKa             = "onUseGaiMingKa"                 --ʹ�ø������󴥷�
EventCfg.onContinuousKillPlayer     = "onContinuousKillPlayer"         --����ɱ�˴���
EventCfg.onDuJieOnTiemr             = "onDuJieOnTiemr"                 --�ɽ��ɷ�
EventCfg.onTiZhiXiuLianUP           = "onTiZhiXiuLianUP"               --������������
EventCfg.onIntensifySkill           = "onIntensifySkill"               --ǿ�����ܴ���
EventCfg.onRenewlevelUP             = "onRenewlevelUP"                 --ת������
EventCfg.onJianJiaKaiGuan           = "onJianJiaKaiGuan"               --�����۹����׿�������
EventCfg.onRechargeEnd              = "onRechargeEnd"                  --��ֵ��ɴ���
EventCfg.onGetTaskTitle             = "onGetTaskTitle"                 --�����óƺŴ���
EventCfg.onTeQuankaiTong            = "onTeQuankaiTong"                --��Ȩ��ͨ����

EventCfg.onRliveNotice              = "onRliveNotice"                  --֪ͨ����״̬����

--������
EventCfg.goKFGongShaSync            = "goKFGongShaSync"                --��ɳ����ͬ��

EventCfg.onKFGongShaRewardSync      = "onKFGongShaRewardSync"          --��ɳ����ͬ��
EventCfg.onKFGongShaLinQu           = "onKFGongShaLinQu"               --��ɳ��ȡ����




return EventCfg