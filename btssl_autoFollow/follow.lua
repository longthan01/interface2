local tbAutoAim  = Ui(Ui.UI_tbAutoAim);
local tbAutoAim	= Map.tbAutoAim or {};
Map.tbAutoAim	= tbAutoAim;

local tbTimer = Ui.tbLogic.tbTimer;
local tbMsgInfo = Ui.tbLogic.tbMsgInfo;
local tbSelectNpc    = Ui(Ui.UI_SELECTNPC);

function tbAutoAim:Init()
	self.nFollowTime    	= 0.8; 
	self.nFollowState 	= 0;
	self.nPID 		= 0;
	self.nPlayerID		= 0;
	self.nszName		= nil;
	self.nHorseRange		= 400; 	
	self.nFRange		= 0.9; 	
	self.nEmFRange		= 0.5; 	
	self.EatFood 		= 70;	
	self.DelayStat 		= 0;	
	self.nInitPlayerId  = 0;   
	self.nInitPlayerName = nil;
	self.nOut = 0;	
end

function tbAutoAim:UpdateSetting(AimCfg)
	self.EMHealDelay = AimCfg.nHealDelay;
	self.bAutoEat = AimCfg.nAutoEat;
	self.bZhanDou = AimCfg.nZhanDou;
	self.bHaiSan = AimCfg.nHaiSan;
	self.bQingGuai = AimCfg.nQingGuai;
end

function tbAutoAim:FollowData(szName,nItemData)
	if (nItemData >0) then
		self.nPID = 1;
		self.nPlayerID = nItemData;
		local tbSplit	= Lib:SplitStr(szName, " ");
		self.nszName = tbSplit[1];
		self.nPType = 1;
		self.nInitPlayerId = self.nPlayerID;			   
		self.nInitPlayerName = self.nszName;
		me.Msg("<color=green>Không có mục tiêu chính xác<color>");
	else
		self.nPID = 0;
	end
	self:AutoFollow()
end


function tbAutoAim:AutoFollow()
	if (me.nFaction == 5 and me.CanCastSkill(98) == 1 and me.nRouteId == 2) then
		self.nRange = self.nEmFRange; 
	else
		self.nRange = self.nFRange;
	end

	if self.nFollowState == 0 then
		self.nFollowState = 1;
		if self.nPID == 0 then 
			local playerInfo = tbSelectNpc.pPlayerInfo;
			if playerInfo then
				self.nPlayerID = tbSelectNpc.pPlayerInfo.dwId;
				self.nszName = tbSelectNpc.pPlayerInfo.szName;
				self.nPType = 2;
			else
				local nAllotModel, tbMemberList = me.GetTeamInfo();
				if nAllotModel and tbMemberList then
    			local tLeader = tbMemberList[1];
					if tLeader.szName == me.szName then
						me.Msg("<color=Yellow>Bạn là đội trưởng, không thể theo bạn được!<color>");
						return;
					else
						self.nPlayerID = tLeader.nPlayerID;
						self.nszName = tLeader.szName;
						self.nInitPlayerId = self.nPlayerID;			  
						self.nInitPlayerName = self.nszName;
						me.Msg("<color=green>Không có mục tiêu chính xác<color>");
						self.nPType = 3;
					end
				end
			end
		end
		if (self.nPlayerID == 0) then
			me.Msg("<color=Yellow>Không có mục tiêu chính xác<color>");
			return;
		end
		if Map.tbSuperMapLink.tbUserData.bHorseLock == 1 then
			Map.tbSuperMapLink:nSwitch();
		end
		Ui(Ui.UI_TASKTIPS):Begin("<bclr=red><color=yellow>Theo sau: <color> ["..self.nszName.."<color>]");
		me.Msg("Bắt đầu theo sau:[<color=Yellow>"..self.nszName.."<color>]");
		nFTimer1 = Timer:Register(self.nFollowTime * Env.GAME_FPS, self.OnFollow1, self);
	else
		if Map.tbSuperMapLink.tbUserData.bHorseLock ~= 1 then
			Map.tbSuperMapLink:nSwitch();
		end
		self.nFollowState = 0;
		Timer:Close(nFTimer1);
		me.Msg("<color=Yellow>Ngừng theo sau - Hộ tống<color>");
		Ui(Ui.UI_TASKTIPS):Begin("<bclr=blue><color=yellow>Ngừng theo sau - Hộ tống<color>");
		self.nPID = 0;
		self.nPosX = 0;
		self.nPosY = 0;
		self.nInitPlayerId  = 0;   
		self.nInitPlayerName = nil;
		Map.tbSuperMapLink:CloseGo();
		if (me.nAutoFightState == 1) then
			AutoAi.ProcessHandCommand("auto_fight", 0);
		end
		AutoAi.SetTargetIndex(0);
	end
end
function tbAutoAim:AutoFollowStart()
	if self.nFollowState == 0 then
		tbAutoAim:AutoFollow();
		return;
	end
end

function tbAutoAim:AutoFollowStop()
	if self.nFollowState == 1 then
		tbAutoAim:AutoFollow();
	end
end

function tbAutoAim:OnFollow1()
	local nMyMapId, nMyPosX, nMyPosY	= me.GetWorldPos();
	if (nMyMapId <= 0 or nMyPosX <= 0) then	
		return;	
	end

	if (me.IsDead() == 1) then
		return;
	end

	if me.nTeamId <= 0 then
		me.Msg("Bạn có tổ đội, không thể tự theo sau!");
		self:AutoFollow()
	end
	if self.bAutoEat == 1 and ((me.nCurLife*100/me.nMaxLife < self.EatFood) or (me.nCurMana*100/me.nMaxMana < self.EatFood)) then
		if me.IsCDTimeUp(3) == 1 and 0 == AutoAi.Eat(3) then	
			local nLevel, nState, nTime = me.GetSkillState(AutoAi.FOOD_SKILL_ID);
			if (not nTime or nTime < 36) then
				if 0 == AutoAi.Eat(4) then 
					print("AutoAi- No Food...");
				end
			end
		end
	end
	if UiManager:WindowVisible(Ui.UI_SKILLPROGRESS) == 1 then
		return
	end
	if self.nFollowState == 0 then
		AutoAi.ProcessHandCommand("auto_fight", 0);
		return 0;
	end
	if (me.IsDead() == 1) then
		me.SendClientCmdRevive(0);
		if me.nAutoFightState == 1 then
			AutoAi:UpdateCfg(Ui.tbLogic.tbAutoFightData:ShortKey());
			Ui(Ui.UI_SYSTEM):UpdateOnlineState();
		end
	end
	local nOnlineState = Player.tbOnlineExp:GetOnlineState(me);
	if (1 == nOnlineState) then
		me.CallServerScript({"ApplyUpdateOnlineState", 0});
	end
	local nMyMaps, nMyX, nMyY = me.GetWorldPos();
	local nMyMap = me.nTemplateMapId;
	self.nMMap = nMyMap;
	self.nLMyPosX = nMyX;
	self.nLMyPosY = nMyY;
	self.nMyPosX = nMyX / 8;
	self.nMyPosY = nMyY / 16;
	if self.nLMyPosX <= 0 or self.nMMap <= 0 then
		return;
	end
	local tbMember = me.GetTeamMemberInfo();
	for i = 1, #tbMember do
		if tbMember[i].szName and tbMember[i].szName == self.nInitPlayerName then
			self.nYPMap = tbMember[i].nMapId;
		end
	end
	if self.nYPMap == self.nMMap then
		self.nPlayerID = self.nInitPlayerId;
		self.nszName = self.nInitPlayerName;
	end
	local tbMember = me.GetTeamMemberInfo();
	for i = 1, #tbMember do
		if tbMember[i].szName and tbMember[i].szName == self.nszName then
			self.nPMap = tbMember[i].nMapId;
			if self.nPMap > 10000 and nMyMaps == self.nPMap then 
				self.nPMap = self.nMMap;
			end
		end
	end
	if self.nPType == 2 then
		self:FLFight();
	elseif self.nPMap == self.nMMap then
		self:FLFight();
	else
		local szMapType = AutoAi:GetMapTypeByMapId(nMyMapId);
		local nMapId = me.GetMapTemplateId();
		local szMapName, szMapPath = GetMapPath(nMapId);
		if (string.find(szMapName,"Happy Valley"))
		or (string.find(szMapName,"City "))
		or (me.GetSkillState(891) > 0) then
			me.Msg("※无痕※提示:<color=Yellow>默认逍遥谷、跨服城战、领土状态最初跟随对象死亡后选择同图队友，待与最初跟随对象同图后再跟随最初跟随对象!<color>");
			self:GetAnotherMember();
			return;
		elseif self.nPMap == 90 then 
			self.PlayX = "1900";
			self.PlayY = "3900";
		elseif self.nPMap == 97 and self.nMMap ~=90 then 
			self.PlayX = "1920";
			self.PlayY = "3620";
		elseif self.nPMap == 119 then
			self.PlayX = "1534";
			self.PlayY = "3726";
		elseif self.nPMap == 26 then
			self.PlayX = "1642";
			self.PlayY = "3280";			
		elseif self.nPMap == 132 then 
			self.PlayX = "1966";
			self.PlayY = "3763";
		elseif self.nPMap == 103 then 
			self.PlayX = "1795";
			self.PlayY = "3722";
		elseif self.nPMap == 24 then
			self.PlayX = "1766";
			self.PlayY = "3539";
		elseif self.nPMap == 100 and self.nMMap ==101 then 
			self.PlayX = "1610";
			self.PlayY = "3348";
			elseif self.nPMap == 25 then
			self.PlayX = "1630";
			self.PlayY = "3171";
		elseif self.nPMap == 88 then
			self.PlayX = "1756";
			self.PlayY = "3637";
		elseif self.nPMap == 95 then
			self.PlayX = "1747";
			self.PlayY = "3589";
		elseif self.nPMap == 1769 then
			self.PlayX = "1609";
			self.PlayY = "3183";			
		elseif self.nPMap == 114 then 
			self.PlayX = "1929";
			self.PlayY = "3818";
		elseif self.nPMap == 29 and self.nMMap == 92 then 
			self.PlayX = "1429";
			self.PlayY = "4116";
		elseif self.nPMap == 92 and self.nMMap == 29 then 
			self.PlayX = "2069";
			self.PlayY = "3447";
		else
			self.PlayX = "1500";
			self.PlayY = "3000";
		end
		self:GotoPmap(self.PlayX,self.PlayY);
	end
end

function tbAutoAim:GotoPmap(PlayX,PlayY)
	if UiManager:WindowVisible(Ui.UI_SKILLPROGRESS) == 1 then
		return
	end
	if (me.nAutoFightState == 1) then
		AutoAi.ProcessHandCommand("auto_fight", 0);
		AutoAi.SetTargetIndex(0);
	end
	if (me.GetNpc().nIsRideHorse ~= 1) then	
		Switch("horse");
	end
	local sznMap = GetMapNameFormId(self.nPMap)
	if (self.nPMap>=225 and self.nPMap<=232) and (self.nMMap<225 or self.nMMap>232) then
		local nRegisterMapId = 28
		local szLink = ","..nRegisterMapId..",2654,1";
		UiManager.tbLinkClass["npcpos"]:OnClick(szLink);
		return
	end
	if (self.nPMap>225 and self.nPMap<230) and self.nMMap==225 then
		local nRegisterMapId = 225
		local szLink
		if self.nPMap==226 then 
			szLink = ","..nRegisterMapId..",2655,1";
		end
		if self.nPMap==227 then 
			szLink = ","..nRegisterMapId..",2656,1";
		end
		if self.nPMap==228 then 
			szLink = ","..nRegisterMapId..",2657,1";
		end
		if self.nPMap==229 then 
			szLink = ","..nRegisterMapId..",2658,1";
		end
		UiManager.tbLinkClass["npcpos"]:OnClick(szLink);
		return
	end
	if (self.nPMap==230 or self.nPMap==231) and (self.nMMap>225 or self.nMMap<230) then
		me.StartAutoPath(203*8, 194*16);
		return
	end
	if self.nPMap==232 and (self.nMMap==230 or self.nMMap==231) then
		me.StartAutoPath(203*8, 194*16);
		return
	end
	if self.nPMap==225 and self.nMMap==232 then
		me.StartAutoPath(203*8, 194*16);
		return
	end
	if (self.nPMap<225 or self.nPMap>232) and self.nMMap==225 then
		local nRegisterMapId = 225
		local szLink = ","..nRegisterMapId..",2659,5";
		UiManager.tbLinkClass["npcpos"]:OnClick(szLink);
		return
	end
	if (self.nPMap>=233 and self.nPMap<=240) and (self.nMMap<233 or self.nMMap>240) then
		local nRegisterMapId = 28
		local szLink = ","..nRegisterMapId..",2654,2";
		UiManager.tbLinkClass["npcpos"]:OnClick(szLink);
		return
	end
	if (self.nPMap>233 and self.nPMap<238) and self.nMMap==233 then
		local nRegisterMapId = 233
		local szLink
		if self.nPMap==234 then 
			szLink = ","..nRegisterMapId..",2655,1";
		end
		if self.nPMap==235 then 
			szLink = ","..nRegisterMapId..",2656,1";
		end
		if self.nPMap==236 then
			szLink = ","..nRegisterMapId..",2657,1";
		end
		if self.nPMap==237 then 
			szLink = ","..nRegisterMapId..",2658,1";
		end
		UiManager.tbLinkClass["npcpos"]:OnClick(szLink);
		return
	end
	if (self.nPMap==238 or self.nPMap==239) and (self.nMMap>233 or self.nMMap<238) then
		me.StartAutoPath(203*8, 194*16);
		return
	end
	if self.nPMap==240 and (self.nMMap==238 or self.nMMap==239) then
		me.StartAutoPath(203*8, 194*16);
		return
	end
	if self.nPMap==233 and self.nMMap==240 then
		me.StartAutoPath(203*8, 194*16);
		return
	end
	if (self.nPMap<233 or self.nPMap>240) and self.nMMap==233 then
		local nRegisterMapId = 233
		local szLink = ","..nRegisterMapId..",2659,5";
		UiManager.tbLinkClass["npcpos"]:OnClick(szLink);
		return
	end
	if self.nPMap >= 821 and self.nPMap <= 828 and (self.nMMap < 821 or self.nMMap> 828) then
		local nRegisterMapId = 28
		local szLink = "," .. nRegisterMapId .. ",2654,3"
		UiManager.tbLinkClass.npcpos:OnClick(szLink)
		return
	end
	if self.nPMap > 821 and self.nPMap < 826 and self.nMMap == 821 then
		local nRegisterMapId = 821
		local szLink = nil
		if self.nPMap == 822 then
			szLink = "," .. nRegisterMapId .. ",2655,1"
		end
		if self.nPMap == 823 then
			szLink = "," .. nRegisterMapId .. ",2656,1"
		end
		if self.nPMap == 824 then
			szLink = "," .. nRegisterMapId .. ",2657,1"
		end
		if self.nPMap == 825 then
			szLink = "," .. nRegisterMapId .. ",2658,1"
		end
		UiManager.tbLinkClass.npcpos:OnClick(szLink)
		return
	end
	if (self.nPMap == 826 or self.nPMap == 827) and (self.nMMap > 821 or self.nMMa < 826) then
		me.StartAutoPath(1624, 3104)
		return
	end
	if self.nPMap == 828 and (self.nMMap == 826 or self.nMMap == 827) then
		me.StartAutoPath(1624, 3104)
		return
	end
	if self.nPMap == 821 and self.nMMap == 828 then
		me.StartAutoPath(1624, 3104)
		return
	end
	if (self.nPMap < 821 or self.nPMap > 828) and self.nMMap == 821 then
		local nRegisterMapId = 821
		local szLink = "," .. nRegisterMapId .. ",2659,5"
		UiManager.tbLinkClass.npcpos:OnClick(szLink)
		return
	end
	--逍遥
	if self.nPMap==341 and self.nMMap~=341 then
		local nRegisterMapId = 23
		local szLink = "," .. nRegisterMapId .. ",3237,1"
		UiManager.tbLinkClass.npcpos:OnClick(szLink)
		return
	end
	if self.nPMap==342 and self.nMMap~=342 then
		local nRegisterMapId = 23
		local szLink = "," .. nRegisterMapId .. ",3237,2"
		UiManager.tbLinkClass.npcpos:OnClick(szLink)
		return
	end
	if (self.nPMap>1536 and self.nPMap<=1540) and self.nMMap==1536 then
		if self.nLMyPosY<3675 then
			Map.tbSuperMapLink:move(1600,3675)
		else
			me.StartAutoPath(1930,3850);
		end
		return
	end
	if self.nPMap>=1538 and self.nPMap<=1540 and self.nMMap==1537 then
		me.StartAutoPath(2176,3476);
		return
	end
	if self.nPMap>=1539 and self.nPMap<=1540 and self.nMMap==1538 then
		if me.nFightState ~= 1 then
			if self.nLMyPosX<1788 then
				Map.tbSuperMapLink:move(1788,3190)
			elseif self.nLMyPosY<3216 then
				Map.tbSuperMapLink:move(1812,3216)
			else
				Map.tbSuperMapLink:move(1800,3228)
			end
			return
		end
		me.StartAutoPath(1810,3480);
		return
	end
	if self.nPMap==1540 and self.nMMap==1539 then
		me.StartAutoPath(1950,3823);
		return
	end
	if (self.nPMap>1535 and self.nPMap<=1539) and self.nMMap==1540 then
		me.StartAutoPath(1563,3188);
		return
	end
	if (self.nPMap>1535 and self.nPMap<=1538) and self.nMMap==1539 then
		me.StartAutoPath(1693,3341);
		return
	end
	if (self.nPMap>1535 and self.nPMap<=1537) and self.nMMap==1538 then
		if me.nFightState ~= 1 then
			local _,nMyX, nMyY = me.GetWorldPos();
			if self.nOut == 0 then
				if nMyX == 1786 and nMyY == 3190 then
					self.nOut = 1;
					return;
				else
					Map.tbSuperMapLink:move(1786,3190);
				end
			elseif self.nOut == 1 then
				if nMyX == 1813 and nMyY == 3216 then
					self.nOut = 2;
					return;
				else
					Map.tbSuperMapLink:move(1813,3216);
				end
			elseif self.nOut == 2 then
				Map.tbSuperMapLink:move(1800,3228);
			end
		else
			me.StartAutoPath(1545,3168);
			return
		end
	end
	if self.nPMap == 1536 and self.nMMap==1537 then
		me.StartAutoPath(1883,3125);
		return
	end
	if self.nPMap < 1536 and self.nMMap==1536 then
		if me.nFightState ~= 1 then
			local _,nMyX, nMyY = me.GetWorldPos();
			if nMyX == 1579 and nMyY == 3649 then
				if UiManager:WindowVisible(Ui.UI_SAYPANEL) == 1 then
					me.AnswerQestion(0);
					UiManager:CloseWindow(Ui.UI_SAYPANEL);
					return;
				end
				for _, pNpc in ipairs(KNpc.GetAroundNpcList(me, 60)) do
					if (pNpc.nTemplateId == 2445) then
						AutoAi.SetTargetIndex(pNpc.nIndex);
						return;
					end
				end
			else
				Map.tbSuperMapLink:move(1579,3649);
			end
		else
			me.StartAutoPath(1590,3663);
			return
		end
	end
	if self.nPMap < 1536 and self.nMMap==1537 then
		me.StartAutoPath(1883,3125);
		return
	end
	if self.nPMap < 1536 and self.nMMap==1538 then
		if me.nFightState ~= 1 then
			local _,nMyX, nMyY = me.GetWorldPos();
			if self.nOut == 0 then
				if nMyX == 1786 and nMyY == 3190 then
					self.nOut = 1;
					return;
				else
					Map.tbSuperMapLink:move(1786,3190);
				end
			elseif self.nOut == 1 then
				if nMyX == 1813 and nMyY == 3216 then
					self.nOut = 2;
					return;
				else
					Map.tbSuperMapLink:move(1813,3216);
				end
			elseif self.nOut == 2 then
				Map.tbSuperMapLink:move(1800,3228);
			end
		else
			me.StartAutoPath(1545,3168);
			return
		end
	end
	if self.nPMap < 1536 and self.nMMap==1539 then
		me.StartAutoPath(1693,3341);
		return
	end
	if self.nPMap < 1536 and self.nMMap==1540 then
		me.StartAutoPath(1563,3188);
		return
	end
	if self.nPMap>=1536 and self.nPMap<=1539 and (self.nMMap<1536 or self.nMMap>1540) then
		local szLink = ",132,2441,1";
		UiManager.tbLinkClass["npcpos"]:OnClick(szLink);
		return
	end
	if self.nPMap==24 and self.nMMap~=24 then
		Ui.tbLogic.tbAutoPath:GotoPos({nMapId=24,nX=1767,nY=3540});
		return
	end
	if self.nPMap==342 and self.nMMap~=342 then
		local nRegisterMapId = 23
		local szLink = "," .. nRegisterMapId .. ",3237,2"
		UiManager.tbLinkClass.npcpos:OnClick(szLink)
		return
	end
	if self.nPMap==2086 and self.nMMap < 2086 then
		local nRegisterMapId = 24
		local szLink = "," .. nRegisterMapId .. ",2955,2,1"
		UiManager.tbLinkClass.npcpos:OnClick(szLink)
		return
	end
	if self.nPMap==2087 and self.nMMap~=2086 then
		local szLink = "," .. nRegisterMapId .. ",2955,1,1"
		UiManager.tbLinkClass.npcpos:OnClick(szLink)
		return
	end	
	me.Msg("Bản đồ:<color=Blue>["..sznMap.."]<color>Theo sau: <color=Yellow>"..self.nszName.."<color>")
	local nPlayPosInfo ={}
	nPlayPosInfo.szType = "pos"
	nPlayPosInfo.szLink = sznMap..","..self.nPMap..","..PlayX..","..PlayY;
--	Ui.tbLogic.tbAutoPath:GotoPos({nMapId=self.nPMap,nX=PlayX,nY=PlayY});
	me.Msg(nPlayPosInfo.szLink)
	Map.tbSuperMapLink.StartGoto(Map.tbSuperMapLink,nPlayPosInfo);
end

function tbAutoAim:FLFight()
	if self.nPType == 2 then
		me.Msg("Theo sau:[<color=Gold>"..self.nszName.."<color>]")
		me.Msg(self.nFollowState)
		local tbAroundNpc	= KNpc.GetAroundNpcList(me, 300);
		for _, pNpc in ipairs(tbAroundNpc) do
			if (pNpc.szName == self.nszName) then
				local _, nNpcX, nNpcY	= pNpc.GetWorldPos();
				self.nPosX = nNpcX/8;
				self.nPosY = nNpcY/16;
			end
		end
	else
		local tbNpc = SyncNpcInfo();
		if tbNpc then
			for _, tbNpcInfo in ipairs(tbNpc) do
				if tbNpcInfo.szName == self.nszName then
					self.nPosX = tbNpcInfo.nX/16;
					self.nPosY = tbNpcInfo.nY/16;
				end
			end
		end
	end

	local TargetDis = math.sqrt((self.nMyPosX-self.nPosX)^2 + (self.nMyPosY-self.nPosY)^2);
	if (TargetDis < self.nRange) then
		Map.tbSuperMapLink:CloseGo();
		if (me.nFaction == 5 and me.CanCastSkill(98) == 1) then
			if (self.DelayStat == 0 and me.nFightState == 1) then
				UseSkill(98,GetCursorPos());
				self:MyDelay(self.EMHealDelay);
			else
				return;
			end
		else
			local IsDangerous,nId = tbAutoAim:IsDangerous();
			if IsDangerous == 1 then
				me.Msg("Có đồ sát");
				if (me.nAutoFightState == 1) then
					AutoAi.ProcessHandCommand("auto_fight", 0);
					AutoAi.SetTargetIndex(0);
				end
				self:TongMapGo();
			elseif IsDangerous == 2 then
				me.Msg("我是天忍!不怕反弹");
				AutoAi.SetTargetIndex(nId);
			else
				if (me.nAutoFightState ~= 1 and me.nFightState == 1) then
					AutoAi:UpdateCfg(Ui.tbLogic.tbAutoFightData:ShortKey());
				end
			end
		end
	else
		if (TargetDis > self.nHorseRange) and (me.GetNpc().nIsRideHorse ~= 1) then	
			Switch("horse");
		end
		if (me.nFaction == 5 and me.CanCastSkill(98) == 1 and me.nRouteId == 2) then  
			if (me.nAutoFightState == 1) then
				AutoAi.ProcessHandCommand("auto_fight", 0);
				AutoAi.SetTargetIndex(0);
			end
			self:TongMapGo();
		else
			self:StopFight();
		end
	end
end

function tbAutoAim:StopFight()
	local nMap = me.nTemplateMapId;
	local IsDangerous,nId = tbAutoAim:IsDangerous();
	if not ((nMap > 297 and nMap < 333)
			or (nMap > 828 and nMap < 955)
			or (nMap > 2013 and nMap < 2056)
			or (nMap > 1541 and nMap < 1549)
			or (nMap == 273)) or self.nPType == 2 or IsDangerous == 1 then 
		if (me.nAutoFightState == 1) then
			AutoAi.ProcessHandCommand("auto_fight", 0);
			AutoAi.SetTargetIndex(0);
		end
		self:TongMapGo();
	else
		if self.bQingGuai == 1 then
			local tbAroundNpc = KNpc.GetAroundNpcList(me, 20);
			for _, pNpc in ipairs(tbAroundNpc) do
				if (pNpc.nKind == 0) then  
					me.Msg("<color=Yellow>周围还有怪<color>");
					AutoAi.ProcessHandCommand("auto_fight", 1);
					return;
				else
					me.Msg("<color=Yellow>theo sau : "..self.nszName.."<color>");
					AutoAi.ProcessHandCommand("auto_fight", 0);
					AutoAi.SetTargetIndex(0);
					local nX = math.floor(self.nPosX);
					local nY = math.floor(self.nPosY);
					me.Msg("Tọa độ: <color=Blue>"..nX.."/"..nY.."<color>");
					self:TongMapGo();
				end
			end
		else
			if (me.nAutoFightState == 1) then
				AutoAi.ProcessHandCommand("auto_fight", 0);
				AutoAi.SetTargetIndex(0);
			end
			self:TongMapGo();
		end
	end
end

function tbAutoAim:TongMapGo()
	local x,y,world = me.GetNpc().GetMpsPos();
	local nMyPosX   = math.floor(x/32);
	local nMyPosY   = math.floor(y/32);
	if me.nTemplateMapId == 287 and nMyPosX > 1724 and nMyPosX < 1865 and nMyPosY > 2864 and nMyPosY < 2967 then
		Map.tbSuperMapLink:move(self.nPosX*8, self.nPosY*16);
	elseif me.nTemplateMapId == 493 and me.nFightState ~= 1 then
		if self.nPosX*8 >= 1814 and self.nPosX*8 <= 1874 and self.nPosY*16 >= 3586 and self.nPosY*16 <= 3663 then
			if self.bHaiSan == 1 then
				Map.tbSuperMapLink:StartGoto({szType = "npcpos", szLink = ","..me.nTemplateMapId..",4210,3"});
			else
				return;
			end
		end
	elseif me.nTemplateMapId == 493 and nMyPosX >= 1814 and nMyPosX <= 1874 and nMyPosY >= 3586 and nMyPosY <= 3663 then
		Map.tbSuperMapLink:move(self.nPosX*8, self.nPosY*16);
	elseif me.nTemplateMapId == 2091 and nMyPosX >= 1257 and nMyPosX <= 1362 and nMyPosY >= 3017 and nMyPosY <= 3121 then
		Map.tbSuperMapLink:move(self.nPosX*8, self.nPosY*16);
	elseif me.nTemplateMapId == 1536 and me.nFightState ~= 1 then
		if self.nPosX*8 > 1590 and self.nPosY*16 < 3611 then
			Map.tbSuperMapLink:move(1585,3610);
		elseif self.nPosX*8 > 1594 and self.nPosY*16 > 3663 then
			Map.tbSuperMapLink:move(1586,3657);
		elseif self.nPosX*8 < 1542 and self.nPosY*16 > 3601 then
			Map.tbSuperMapLink:move(1548,3648);
		else
			Map.tbSuperMapLink:move(self.nPosX*8, self.nPosY*16);
		end
	elseif me.nTemplateMapId == 1538 and me.nFightState ~= 1 then
		if self.nPosY*16 > 3233 then
			if self.nOut == 0 then
				if nMyPosX == 1786 and nMyPosY == 3190 then
					self.nOut = 1;
					return;
				else
					Map.tbSuperMapLink:move(1786,3190);
				end
			elseif self.nOut == 1 then
				if nMyPosX == 1813 and nMyPosY == 3216 then
					self.nOut = 2;
					return;
				else
					Map.tbSuperMapLink:move(1813,3216);
				end
			elseif self.nOut == 2 then
				Map.tbSuperMapLink:move(1800,3228);
			end
		else
			Map.tbSuperMapLink:move(self.nPosX*8, self.nPosY*16);
		end
	elseif me.nTemplateMapId == 2013 and me.nFightState ~= 1 then
		if nMyPosX > 1765 and nMyPosX < 1822 then
			Map.tbSuperMapLink:move(1813,3470);
		elseif nMyPosX > 1830 and nMyPosX < 1889 then
			Map.tbSuperMapLink:move(1838,3188);
		elseif nMyPosX > 2030 then
			Map.tbSuperMapLink:move(2033,3388);
		end
	else
		self.nOut = 0;
		local nXx =  math.floor(self.nPosX*8);
		local nYy =  math.floor(self.nPosY*16);
		if me.nTemplateMapId == 1536 and nXx >= 1545 and nXx <= 1589 and nYy >= 3601 and nYy <= 3660 then
			me.StartAutoPath(1590,3663);
		elseif me.nTemplateMapId == 1538 and nXx >= 1735 and nXx <= 1813 and nYy >= 3161 and nYy <= 3223 then
			me.StartAutoPath(1792,3233);
		else
			Ui.tbLogic.tbAutoPath:GotoPos({nMapId = me.nTemplateMapId, nX = self.nPosX*8, nY = self.nPosY*16});
		end
	end
end

function tbAutoAim:GetAnotherMember()
	local tbMemberList = me.GetTeamMemberInfo();
	if tbMemberList then
		for i = 1, #tbMemberList do
			if tbMemberList[i].szName and tbMemberList[i].nPlayerID then
				local tbMember = tbMemberList[i];
				local pNpc = KNpc.GetByPlayerId(tbMember.nPlayerID);
				if (pNpc and pNpc.nMapId == me.nMapId and pNpc.szName ~= me.szName)then
					self.nPlayerID = pNpc.nPlayerID;
					self.nszName = pNpc.szName;
					self.nPType = 3;
					me.Msg("<color=Yellow>取得同地图其他队友信息成功<color>");
				end
			end
		end
	end
end

function tbAutoAim:IsDangerous()
	local isDangerous = 0;
	local tbAroundNpc	= KNpc.GetAroundNpcList(me, 200);
	for _, pNpc in ipairs(tbAroundNpc) do
		local id = pNpc.nTemplateId;
		if (id == 3146 or id == 3149 or id == 3152 or id == 3157 or id == 3177 or id == 3193 or id == 3277 ) then
			-- 反弹怪ID
			-- 慕容家虎:3146;姑苏大鳄鱼:3149;慕容家豹:3152;弹性机璜:3157;慕容氏鬼魂:3177;强力机璜:3193;木桩反弹:3277;碧水蜈:7348
			-- 门派宝箱(门派竞技):2700;寻宝旗帜(门派竞技):2701
			if me.nFaction == 8 then
				isDangerous = 2;
			else
				isDangerous = 1;
			end
			break;
		end
	end
	return isDangerous,id;
end

function tbAutoAim:MyDelay(DelayTime)
	self.nTest = 0;
	self.nDtime = DelayTime;
	self.DelayStat = 1;
	local DelayStart = tbTimer:Register(0.2 * Env.GAME_FPS, self.DelayClock, self);
end

function tbAutoAim:DelayClock()
	local nDelay = self.nDtime*5;
	self.nTest = self.nTest + 1;
	if self.nTest >= nDelay+5 then
		self.DelayStat = 0;
		return 0;
	end
end

function tbAutoAim:KaiGuanTBGJ()
	if self.nTBGJ == 0 then 
		self.nTBGJ = 1;
		UiManager:OpenWindow("UI_INFOBOARD", "<bclr=pink><color=white>Mở tấn công");		
		nPickTimerId = Timer:Register(Env.GAME_FPS * 1, self.TongBuGongJi, self);
	else
		--Btn_SetTxt(Ui.UI_POPBAR, "BtnTTB2", "khóa");
		self.nTBGJ = 0;
		UiManager:OpenWindow("UI_INFOBOARD", "<bclr=blue><color=white>Tắt tấn công");
		Timer:Close(nPickTimerId);
		nPickTimerId = 0;
	end
end

function tbAutoAim:TongBuGongJi()
	--Btn_SetTxt(Ui.UI_POPBAR, "BtnTTB2", "tắt");
	if self.nTBGJ == 0 then
		return
	end
	local nMyMapId, nMyPosX, nMyPosY	= me.GetWorldPos();
	if (nMyMapId <= 0 or nMyPosX <= 0) then	-- 登入中，数据不完整
		return;	-- 先等一等
	end
	local n   = 0;
	local nTargetId = 0;
	local nTargetIndex = 0;
	local pPlayerInfo = me.GetSelectNpc()
	if (pPlayerInfo and pPlayerInfo.nKind == 1) then		-- 鼠标选中游戏玩家
		nTargetId = pPlayerInfo.dwId;
		if nTargetId and nTargetId >0 then
			n = nTargetId
		else
			n = 0;
		end
		SendChannelMsg("Team","attack"..n);
	elseif (pPlayerInfo and pPlayerInfo.nKind ~= 1) then     -- 鼠标选中Npc
		nTargetIndex = pPlayerInfo.nIndex;
		if nTargetIndex and nTargetIndex >0 then
			n = KNpc.GetByIndex(nTargetIndex).dwId;
		else
			n = 0;
		end
		SendChannelMsg("Team","attack"..n);
	end
end

tbAutoAim:Init();

me.Msg("※无痕※提示：<color=green>跨图跟随<color>加载OK");
