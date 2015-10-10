-----------------------------------------------------------
-- 作  者   ：  骑虎难下
-- 格  言   ：  相濡以沫，未若相忘于江湖(太上忘情)
-- 优化者   ：  耍耍（哈，这位置我要了）
-- 功能描述 ：  各职业左键全自动发连招
-----------------------------------------------------------
--local tbSelectNpc= Ui:GetClass("selectnpc");
local tbSelectNpc= Ui(Ui.UI_SELECTNPC);
local tbTimer = Ui.tbLogic.tbTimer;
local self = tbSelectNpc

------------------------------------------------------------start
local attack_skill = {
	[0]		= {};	 	        -- 无门派
	[1]		= {821,31,36,33,29};	-- 少林
	[2]		= {41,47,43,38};	-- 天王
	[3]		= {};		        -- 唐门
	[4]		= {};		        -- 五毒
	[5]		= {};		        -- 峨嵋
	[6]		= {};	                -- 翠烟
	[7]		= {489,134,131,128};	-- 丐帮
	[8]		= {151,156};-- 天忍
	[9]		= {1216};	                -- 武当
	[10]		= {192,190,188};	-- 昆仑
	[11]		= {211,208,205,198,199,202,194};	-- 明教210,
	[12]		= {216,223,217,213};	-- 大理
	[13]		= {2827,2823};	                -- 古墓
	[14]		= {3043,3053,3047,3041,3017,3022,3028,3033,3015,3013}; --逍遥 掌3043,3053,3047,3041剑3017,3022,3028,3033,3015,3013
};

local nActTime = 0; --连招攻击定时器
self.nLZFlg = 0; --连招攻击开关，0为默认关闭，1为默认开启

local nTtime = 0.17	--无需设置

--连招攻击状态开启/关闭
function tbSelectNpc:SwitchLZ()
	if self.nLZFlg == 0 then
		UiManager:OpenWindow("UI_INFOBOARD", "<bclr=pink><color=white>Mở chế độ liên tục [ CTRL + 7 ]");
		me.Msg("<color=yellow>Xem chi tiết thiết lập cá nhân thậm chí đột quỵ tải bài tầng 3 !<color>")
		self.nLZFlg = 1;
	else
		UiManager:OpenWindow("UI_INFOBOARD", "<bclr=blue><color=white>Đóng chế độ liên tục [ CTRL + 7 ]");
		self.nLZFlg = 0;
	end
end

--金山有更新要改
function tbSelectNpc:OnOpen(pNpc)
	if (not pNpc) then
		return 0;
	end
	if pNpc.GetPlayerKinBadge() > 0 then
		Img_SetImage(self.UIGROUP, "Main", 1, self.szMainPage.."2.spr");
	else
		Img_SetImage(self.UIGROUP, "Main", 1, self.szMainPage.."1.spr");
	end
	Wnd_Hide(self.UIGROUP, self.IMG_PARTNER);
	self.pPlayerInfo = pNpc;
	if (self.pPlayerInfo and self.pPlayerInfo.nKind >= 0 and self.pPlayerInfo.nKind <= 3) then
		if self.pPlayerInfo.nKind == 1 then
			Wnd_SetEnable(self.UIGROUP, self.BTN_INTERACT, 1);
			self.nIsPlayer = 1;
			Ui(Ui.UI_CHECKTEACHER):SetPlayerID(self.pPlayerInfo.dwId);	--连接CTRL+A
		else
			Wnd_SetEnable(self.UIGROUP, self.BTN_INTERACT, 0);
			self.nIsPlayer = 0;
			local nType = self:GetPartnerType(pNpc);
			if nType ~= 0 then
				Img_SetImage(self.UIGROUP, self.IMG_PARTNER, 1, self.tbTZSPR[nType]);
				Wnd_Show(self.UIGROUP, self.IMG_PARTNER);
			end
		end
	end
	--NPC是载具，如果跟载具阵营相同，则显示上下载具按钮
	if pNpc.IsCarrier() == 1 then
		--搞成这样真蛋疼，啊啊啊看着难受一定要改。。
		local bBjzd = me.GetTask(2220, 22);
		local bNewBattle = me.GetTask(2200, 1);
		if (bNewBattle==1 and pNpc.GetCamp() == me.GetCurCamp() ) or (bBjzd==1 and pNpc.dwExtensionGroupId == me.nExtensionGroupId )then
			local bShow = 1;	
			if Bjzd.bFight == 1 then 
				local szMyTong = me.GetTaskStr(2220, 2);
				local szTongName = Lib:ClearAllLable(pNpc.GetTitle());
				if szMyTong ~=  szTongName then
					bShow = 0;
				end
			end
			if me.IsInCarrier() ~= 1 or me.GetCarrierNpc().dwId == pNpc.dwId and bShow == 1 then
				Wnd_Show(self.UIGROUP, self.BTN_CARRIERACTION);
				local _,_,nAbsX,nAbsY = Wnd_GetPos(self.UIGROUP, self.BTN_CARRIERACTION);
				Tutorial:ShowWindowEx(4, nAbsX,nAbsY, -40, 26) 
			end
		end
	end
	self.pPlayerInfo.AddTaskState(self.SKILLID_STATE) -- 画圈圈
	self:TimerRegister();
	self:UpdatePlayerState();
	return 1;
end


tbSelectNpc.OnClose_Bak = tbSelectNpc.OnClose_Bak or tbSelectNpc.OnClose
function tbSelectNpc:OnClose()
	if nActTime and (nActTime ~= 0) then
		tbTimer:Close(nActTime);
		nActTime = 0;
	end
	self:OnClose_Bak()
end

-- 定时刷新
tbSelectNpc.TimerRegister_Bak = tbSelectNpc.TimerRegister_Bak or tbSelectNpc.TimerRegister
function tbSelectNpc:TimerRegister()
	--连招模式判断
	if self.nLZFlg == 1 then
		if (me.nFightState == 1) then --在可战斗区域
			local nCanAttack = AutoAi.AiTargetCanAttack(self.pPlayerInfo.nIndex);
			if me.nFaction == 2 or me.CanCastSkill(199) == 1 or me.CanCastSkill(216) == 1  then
				nTtime = 0.35
			else
				nTtime = self:GetAttackSpeed()
			end
			if nCanAttack == 1 then
				nActTime = tbTimer:Register(nTtime * Env.GAME_FPS, self.ChangeSkill, self);
			end
		end
	end
	self:TimerRegister_Bak()
end

function tbSelectNpc:ChangeSkill()
	local function SwitchHorseBySkill(nSkillId)
		local nLevel = me.GetNpc().GetFightSkillLevel(nSkillId);
		if nLevel == 0 then
			return
		end
		local tbS = KFightSkill.GetSkillInfo(nSkillId, -1);
		if not(tbS) then
			return
		end;
		if tbS.nHorseLimited == 1 and me.GetNpc().IsRideHorse() == 1 then
			Switch("horse")
		end
		if tbS.nHorseLimited == 2 and me.GetNpc().IsRideHorse() == 0 then
			Switch("horse")
		end
	end
	for _, nSkillId in ipairs(attack_skill[me.nFaction]) do
		SwitchHorseBySkill(nSkillId);
		if (me.CanCastSkill(nSkillId) == 1) and (me.CanCastSkillUI(nSkillId) == 1) then
			AutoAi.SetActiveSkill(nSkillId, 800);
			return;
		end
	end
	-- 默认用左键技能
	SwitchHorseBySkill(me.nLeftSkill)
	if (me.CanCastSkill(me.nLeftSkill) == 1) then
		AutoAi.SetActiveSkill(me.nLeftSkill, 800);
	end;
end

function tbSelectNpc:GetAttackSpeed()
	local tbSet = KFightSkill.GetSetting();
	local nAttackPerSecond = math.max(tbSet.nAttackFrameMin, Env.GAME_FPS - math.floor(me.nAttackSpeed / 10));
	nAttackPerSecond = math.min(tbSet.nAttackFrameMax, nAttackPerSecond) / Env.GAME_FPS;
	nAttackPerSecond = math.floor(nAttackPerSecond * 100 + 0.5) / 100;	-- 四舍五入并保留2位小数
	local nCastPerSecond = math.max(tbSet.nCastFrameMin, Env.GAME_FPS - math.floor(me.nCastSpeed / 10));
	nCastPerSecond = math.min(tbSet.nCastFrameMax, nCastPerSecond) / Env.GAME_FPS;
	nCastPerSecond = math.floor(nCastPerSecond * 100 + 0.5) / 100;		-- 四舍五入并保留2位小数

	if nAttackPerSecond <= nCastPerSecond then
		return nAttackPerSecond
	elseif nAttackPerSecond > nCastPerSecond then
		return nCastPerSecond			--耍耍
	end
end