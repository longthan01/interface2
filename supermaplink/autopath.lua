local tbAutoPath		= Ui.tbLogic.tbAutoPath or {};	-- ֧������
Ui.tbLogic.tbAutoPath	= tbAutoPath;

------��������Լ�����-----
local nKGZD = 0		--0�ĳ�1�������ܵ㵽�󶼲�ս��
local nShangMa = 1	--1��0����ô�ٷ�Ѱ·�����ͼ�ܵ㣩�������������޸ģ�
local nTbClose = 1	--1Ѱ·��ʼʱ�ر�U��壬0�Ͳ��ر�Ѱ·���

--------------------------

local tbFastRunSkill	= { 115, 132, 177, 230, 3016};	-- ���м�������������

local self = tbAutoPath
self.nowM = 0
self.M = 0

-- ���ִ�Ŀ�ĵ�ʱ
function tbAutoPath:OnFinished()
	me.Msg("��ȫ�ִ�Ŀ�ĵء�");
	
	local tbCallBack	= self.tbCallBack;
	
	self:StopGoto("Finish");
	
	if (tbCallBack and tbCallBack[1]) then
		Lib:CallBack(tbCallBack);
	end
	local bIsOpenAutoF = 0;
	local bIsInDialogNpc = 0;
	local nNpcId = tbCallBack[3];
	
	--���npcѰ·
	if type(nNpcId) == "number" then
		local tbNpcList = KNpc.GetAroundNpcList(me,5,16);
		for _, ptmp in pairs(tbNpcList) do
			if ptmp.nKind == 3 then
				bIsInDialogNpc = 1;
				break;
			end
		end
	end


	local nM, nX, nY = me.GetWorldPos();
	--���ǶԻ�npc������Ѱ·���
	if bIsInDialogNpc == 0 then
		local tbNpcList = KNpc.GetAroundNpcList(me,20);
		for _, ptmp in pairs(tbNpcList) do
			if ptmp.nKind == 0 then
				if nKGZD == 0 then
					bIsOpenAutoF = 1;
				end	
				if nM == 2316 and nX>1840 and nY<3150 then --��ȸ��
					bIsOpenAutoF = 0;
				end
				break;
			end
		end
	end

	if bIsOpenAutoF == 1 then
		local tbDate =Ui.tbLogic.tbAutoFightData:ShortKey();
		tbDate.nAutoFight = 1;
		tbDate.nPvpMode = 0;
		AutoAi:UpdateCfg(tbDate);
	end
end

tbAutoPath.GotoPos_Bak = tbAutoPath.GotoPos_Bak or tbAutoPath.GotoPos;
function tbAutoPath:GotoPos(tbPos, ...)
	if (UiManager:WindowVisible(Ui.UI_SUPERMAPLINK_UI) == 1) and nTbClose == 1 then
		UiManager:CloseWindow(Ui.UI_SUPERMAPLINK_UI)
	end

	self.nowM = me.nTemplateMapId
	self.M = tbPos.nMapId
	self:GotoPos_Bak(tbPos, ...)
	self:SSgo(tbPos)
end

-- ���ͷ���ʱ����Ӧ
function tbAutoPath:OnTimer_TransTimeOut()
	local nM, nX, nY = me.GetWorldPos();
	if (nM <= 0 or nX <= 0) then
		return;
	end
	if nM ~= self.nowM then
		self:CloseTimer();
		me.Msg("��������������Ͽ���");
	else
		me.Msg("���ͷ��޷�ʹ�ã�����");
		self:StopGoto("Failed");
	end
end

--���������
function tbAutoPath:SSgo(tbPos)
	local nM1, nX1, nY1 = me.GetWorldPos();
	-- ��������
	if me.GetNpc().nIsRideHorse == 0 and me.GetEquip(Item.EQUIPPOS_HORSE) and nShangMa == 1 then -- ��û�������������
		if (((tbPos.nX-nX1)^2 + (tbPos.nY-nY1)^2) < 3500) and (nM1 == tbPos.nMapId) then
			--me.Msg("<color=yellow>�ܽ���������<color>")
		else
			Switch("horse");	-- ����������ȴ��ԭ��ᵼ������ʧ�ܣ�
			local function myhorse()
				if me.GetNpc().nIsRideHorse == 1 or me.nAutoFightState == 1 or self:IsMoving() == 0 then
					return 0
				end
				Switch("horse");
				return 0
			end
			Ui.tbLogic.tbTimer:Register(50, myhorse);
		end
	end

	-- ���Լ�����
	local function myclose()
		if nM1 <= 0 or nX1 <= 0 or UiManager:WindowVisible(Ui.UI_SKILLPROGRESS) == 1 or self:IsMoving() == 0 then
			return
		end
		for _, nSkillId in ipairs(tbFastRunSkill) do
			if (me.CanCastSkill(nSkillId) == 1) then	-- �����ͷ��������
				local _, _, nRestTime	= me.GetSkillState(nSkillId);
				if (not nRestTime or nRestTime < Env.GAME_FPS) then
					UseSkill(nSkillId)
				end
				break;
			end
		end
		return 0;
	end
	Ui.tbLogic.tbTimer:Register(20, myclose);
end

-- ���ܣ��Ƿ����ƶ�
function tbAutoPath:IsMoving()
	local nRunning = 0;
	if (me.GetNpc().nDoing == Npc.DO_WALK or me.GetNpc().nDoing == Npc.DO_RUN) then
		nRunning = 1;
	end
	return nRunning;
end