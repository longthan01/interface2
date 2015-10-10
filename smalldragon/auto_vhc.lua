Require("\\interface2\\smalldragon\\Ultity.lua");
local self = AutoVHC;
local AutoVHC	   = Map.AutoVHC or {};
Map.AutoVHC		   = AutoVHC;
local SMUltity = Map.SMUltity;
--
local nVHC_CURRENT_STEP = 2; 
local IsStartedAutoVHC = 0;
local nMAPID = 29; -- lâm an
local nAutoVHCTimerId = 0;
local nINTERVAL = 0.5;
local nVHC_MAPID = 65738;
local nNPC_FIND_RANGE = 700;
--
local STEP_1_POS = {1631,3944};
local STEP_2_POS = {1596,3178};
local STEP_3_POS = {1596,3178};
local STEP_4_POS = {1658,3068};
local STEP_5_POS = {1680,3142};
local STEP_6_POS = {1680,3142};
local STEP_7_POS = {1668,3049};
local STEP_8_POS = {1713,3075};
local STEP_9_POS = {1731,2954};
local STEP_10_POS = {1684,2895};
local STEP_11_POS = {1684,2890};
local STEP_12_POS = {1610,3043};
--
local STEP_1_NPCPOS = {1629,3945}; 
local STEP_1_NPCNAME = "Quan Quân Nhu (nghĩa quân)"

local STEP_2_NPCPOS = {1595,3179};
local STEP_2_NPCNAME = "Đào Tử"
local STEP_2_NPC1NAME = "Thiết Mạc Tây";

local STEP_3_TIMERID = 0;
local STEP_3_INTERVAL = 0.5;
local STEP_3_CURRENT_POS = 1;
local STEP_3_ISDONE = 0;
local STEP_3_NPCNAME = "Đào Tử";

local STEP_4_TIMERID = 0;
local STEP_4_INTERVAL = 0.5;
local STEP_4_ISDONE = 0;
local STEP_4_NPCNAME = "Đào Tử";
local STEP_4_CHECKPOS = {1654,3079};

local STEP_7_NPCPOS = {1681,3142};
local BAG = "1 túi vải";
local STEP_5_NPC1NAME = "Thiết Phù Đồ"

local KEY = {18,1,246,1};

local STEP_6_TIMERID = 0;
local STEP_6_INTERVAL = 50;
local STEP_8_ISDONE = 0;

local STEP_7_NPCPOS = {1668,3049};
local STEP_7_ISDONE = 0;
local STEP_7_TIMERID = 0;
local STEP_7_INTERVAL = 11;
local STEP_7_NPCNAME = " "; -- cánh cửa

local STEP_8_NPCNAME = "Bách Vũ";
local STEP_8_NPCPOS = {1712,3078};

local STEP_9_NPCNAME = "Hoàng Tán Nhất";
local STEP_9_NPCPOS = {1731,2954};

local STEP_10_NPC1NAME = "Liễu Sinh";
local STEP_10_NPC2NAME = "Giả Như";
local STEP_10_NPCPOS = {1682,2897};

local STEP_11_NPCNAME = "1 túi vải";
local STEP_11_NPCID = {18,1,1016,1};
local STEP_11_TIMERID = 0;
local STEP_11_INTERVAL = 50;

local STEP_12_NPCID = {18,1,1016,1};
local STEP_12_TIMERID = 0;
local STEP_12_INTERVAL = 30;
local STEP_12_NPCPOS = {1610,3043};
local STEP_12_ISDONE = 0;
--
function AutoVHC:GetMyMiniMapPos()
	local _, nx, ny = me.GetWorldPos();
	return math.floor(nx/8), math.floor(ny/16);
end
--
function AutoVHC:SwitchState()
	if IsStartedAutoVHC == 0 then 
		IsStartedAutoVHC = 1; -- started
		UiManager:OpenWindow("UI_INFOBOARD", "<bclr=White><color=green>Begin auto vạn hoa cốc.<color>");
		nAutoVHCTimerId = Ui.tbLogic.tbTimer:Register(nINTERVAL * Env.GAME_FPS, AutoVHC.DoStep);
	else
		Ui.tbLogic.tbTimer:Close(nAutoVHCTimerId);
		IsStartedAutoVHC = 0; -- stopped.
		nAutoVHCTimerId = 0;
		nVHC_CURRENT_STEP = 1; -- reset step
		UiManager:OpenWindow("UI_INFOBOARD", "<bclr=White><color=red>Auto vạn hoa cốc stopped.<color>");
	end
end

function AutoVHC:Start()
	if Map.SMUltity:IsTeamLead("me") == 0 then 
		UiManager:OpenWindow("UI_INFOBOARD", "<bclr=pink><color=Yellow>Only Leader can open VHC. Auto stopped.<color>");
		return;
	end
	if IsStartedAutoVHC == 0 then 
		IsStartedAutoVHC = 1; -- started
		UiManager:OpenWindow("UI_INFOBOARD", "<bclr=White><color=green>Begin auto vạn hoa cốc.<color>");
		nAutoVHCTimerId = Ui.tbLogic.tbTimer:Register(nINTERVAL * Env.GAME_FPS, self.DoStep);
	end
end
function AutoVHC:Stop()
	if IsStartedAutoVHC == 1 then 
		Ui.tbLogic.tbTimer:Close(nAutoVHCTimerId);
		IsStartedAutoVHC = 0; -- stopped.
		nAutoVHCTimerId = 0;
		nVHC_CURRENT_STEP = 1; -- reset step
		-- close all timer
		Map.SMUltity:CloseTimer(STEP_3_TIMERID);
		Map.SMUltity:CloseTimer(STEP_4_TIMERID);
		Map.SMUltity:CloseTimer(STEP_7_TIMERID);
		Map.SMUltity:CloseTimer(STEP_6_TIMERID);
		Map.SMUltity:CloseTimer(STEP_7_TIMERID);
		Map.SMUltity:CloseTimer(STEP_11_TIMERID);
		Map.SMUltity:CloseTimer(STEP_12_TIMERID);
		-- end --
		UiManager:OpenWindow("UI_INFOBOARD", "<bclr=White><color=red>Auto vạn hoa cốc stopped.<color>");
	end
end
function AutoVHC:CheckPrecondition(nStep)
	UiManager:OpenWindow("UI_INFOBOARD","<color=pink>Step: "..nStep.."<color>");
	if IsStartedAutoVHC == 0 then
		if nAutoVHCTimerId ~= 0 then
			Ui.tbLogic.tbTimer:Close(nAutoVHCTimerId);
			return 0;
		end
	end
	if nStep == 1 then 
		if Map.SMUltity:IsArrived(STEP_1_POS) == 0 then 
			Map.SMUltity:GotoWorldPos(STEP_1_POS);
			return 0;
		end
		return 1;
	elseif nStep == 2 then 
		if Map.SMUltity:IsArrived(STEP_2_POS) == 0 then 
			Map.SMUltity:GotoWorldPos(STEP_2_POS);
			return 0;
		end
		return 1;
	elseif nStep == 3 then return 1;
	elseif nStep == 4 then 
		if Map.SMUltity:IsArrived(STEP_4_POS) == 0 then 
			Map.SMUltity:GotoWorldPos(STEP_4_POS);
			return 0;
		end
		return 1;
	elseif nStep == 5 then 
		if Map.SMUltity:IsArrived(STEP_5_POS) == 0 then 
			Map.SMUltity:GotoWorldPos(STEP_5_POS);
			return 0;
		end
		return 1;
	elseif nStep == 6 then 
		if Map.SMUltity:IsArrived(STEP_6_POS) == 0 then 
			Map.SMUltity:GotoWorldPos(STEP_6_POS);
			return 0;
		end
		return 1;
	elseif nStep == 7 then 
		if Map.SMUltity:IsArrived(STEP_7_POS) == 0 then 
			Map.SMUltity:GotoWorldPos(STEP_7_POS);
			return 0;
		end
		return 1;
	elseif nStep == 8 then 
		if Map.SMUltity:IsArrived(STEP_8_POS) == 0 then 
			Map.SMUltity:GotoWorldPos(STEP_8_POS);
			return 0;
		end
		return 1;
	elseif nStep == 9 then 
		if Map.SMUltity:IsArrived(STEP_9_POS) == 0 then 
			Map.SMUltity:GotoWorldPos(STEP_9_POS);
			return 0;
		end
		return 1;
	elseif nStep == 10 then 
		if Map.SMUltity:IsArrived(STEP_10_POS) == 0 then 
			Map.SMUltity:GotoWorldPos(STEP_10_POS);
			return 0;
		end
		return 1;
	elseif nStep == 11 then 
		if Map.SMUltity:IsArrived(STEP_11_POS) == 0 then 
			Map.SMUltity:GotoWorldPos(STEP_11_POS);
			return 0;
		end
		return 1;
	elseif nStep == 12 then 
		if Map.SMUltity:IsArrived(STEP_12_POS) == 0 then 
			Map.SMUltity:GotoWorldPos(STEP_12_POS);
			return 0;
		end
		return 1;
	end
	return 0;
end
function AutoVHC:DoStep()
	if AutoVHC:CheckPrecondition(nVHC_CURRENT_STEP) == 0 then 
		--me.Msg("Check pre-condition failed. Auto stop.");
		return; 
	end
	--me.Msg("Check pre-condition success. Auto begin.");
	if nVHC_CURRENT_STEP == 1 then 
		AutoVHC:DoStep1();
	elseif nVHC_CURRENT_STEP == 2 then 
		SendChannelMsg("Team", "Anh em vào Hầm thôi!!!");
		AutoVHC:DoStep2();
	elseif nVHC_CURRENT_STEP == 3 then 
		AutoVHC:DoStep3();
	elseif nVHC_CURRENT_STEP == 4 then 
		AutoVHC:DoStep4();
	elseif nVHC_CURRENT_STEP == 5 then 
		AutoVHC:DoStep5();
	elseif nVHC_CURRENT_STEP == 6 then 
		AutoVHC:DoStep6();
	elseif nVHC_CURRENT_STEP == 7 then 
		AutoVHC:DoStep7();
	elseif nVHC_CURRENT_STEP == 8 then 
		AutoVHC:DoStep8();
	elseif nVHC_CURRENT_STEP == 9 then 
		AutoVHC:DoStep9();
	elseif nVHC_CURRENT_STEP == 10 then 
		AutoVHC:DoStep10();
	elseif nVHC_CURRENT_STEP == 11 then 
		AutoVHC:DoStep11();
	elseif nVHC_CURRENT_STEP == 12 then 
		AutoVHC:DoStep12();
	end
end

function AutoVHC:DoStep1() -- goto quan nhu, sign in and enter treasure map
	local nMapid,nx,ny = me.GetWorldPos();
	if nMapid ~= nMAPID then 
		UiManager:OpenWindow("UI_INFOBOARD", "<bclr=White><color=red>Please move to Lâm An city. Auto stopped... <color>");
		AutoVHC:Stop();
		return;
	else -- current city is Lâm An
		UiManager:OpenWindow("UI_INFOBOARD", "<color=red>Open vạn hoa cốc.<color>");
		AutoVHC:_Step1_SignIn();
		if UiManager:WindowVisible(Ui.UI_SAYPANEL) == 1 then 
			local ques, tbAnswers = UiCallback:GetQuestionAndAnswer();
			for i, tbInfo in ipairs(tbAnswers) do
				me.Msg(tbInfo.."+"..i);
				if string.find(tbInfo, "Dạng thường") then
					me.AnswerQestion(i-1);
					UiManager:CloseWindow(Ui.UI_SAYPANEL);
					if UiManager:WindowVisible(Ui.UI_SAYPANEL) == 1 then
						UiManager:CloseWindow(Ui.UI_SAYPANEL);
					end
					me.CallServerScript({"PlayerCmd", "EnterTreasure"});
					nVHC_CURRENT_STEP = 2; -- goto step 2 
					break;
				end
			end	
		end
	end
end
function AutoVHC:_Step1_SignIn()
	local tbNpcs = KNpc.GetAroundNpcList(me,50);
	for _, npc in pairs(tbNpcs) do 
		if npc.szName == STEP_1_NPCNAME then
			me.CallServerScript({"PlayerCmd","SignTreasure","wanhuagu",6});
			return;
		end
	end
end
function AutoVHC:DoStep2() -- go to npc thiết mạc tây, kill him, say with đào tử.
	if UiManager:WindowVisible(Ui.UI_SAYPANEL) == 1 then 
		UiManager:CloseWindow(Ui.UI_SAYPANEL);
	end
	local _,nx,ny = me.GetWorldPos();
	local tbAroundNpcs = KNpc.GetAroundNpcList(me,nNPC_FIND_RANGE);
	for i,npc in pairs(tbAroundNpcs) do 
		if npc.szName == STEP_2_NPC1NAME then 
			AutoAi.StartAutoFight(); 
			return;
		end
	end
	for i,npc in pairs(tbAroundNpcs) do 
		if npc.szName == STEP_2_NPCNAME then 
			AutoAi.StopAutoFight();
			AutoAi.SetTargetIndex(npc.nIndex);
			nVHC_CURRENT_STEP = 3;
			return;
		end
	end
	nVHC_CURRENT_STEP = 3;
end
function AutoVHC:DoStep3() -- follow đào tử
	if STEP_3_TIMERID == 0 and STEP_3_ISDONE == 0 then 
		STEP_3_TIMERID = Ui.tbLogic.tbTimer:Register(STEP_3_INTERVAL * Env.GAME_FPS, AutoVHC._Step3_Follow);
	elseif STEP_3_ISDONE == 1 then 
		Ui.tbLogic.tbTimer:Close(STEP_3_TIMERID);
		STEP_3_TIMERID = 0;
		STEP_3_ISDONE = 0; -- RESET STEP 3
		AutoAi.StartAutoFight();
		nVHC_CURRENT_STEP = 4;
	end
end
function AutoVHC:_Step3_Follow()
	if Map.SMUltity:IsArrived(STEP_4_POS) == 1 then 
		STEP_3_ISDONE = 1;
		return;
	end
	local tbNpcs = KNpc.GetAroundNpcList(me,300);
	for _, npc in pairs(tbNpcs) do
		if npc.szName == STEP_3_NPCNAME then
			local _, x,y = npc.GetWorldPos();
			me.StartAutoPath(x,y);
		end
	end
end
function AutoVHC:DoStep4() -- kill all zombie which attacked đào tử
	AutoAi.StartAutoFight();
	local tbNpcs = KNpc.GetAroundNpcList(me, nNPC_FIND_RANGE);
	for _, npc in pairs(tbNpcs) do 
		if string.find(npc.szName,STEP_4_NPCNAME) then
			local _, x,y = npc.GetWorldPos();
			UiManager:OpenWindow("UI_INFOBOARD", "<color=yellow>Found "..npc.szName.." at: "..x.." - "..y.."<color>");
			if Map.SMUltity:IsNpcArrived(x,y,STEP_4_CHECKPOS) == 1 then
				AutoAi.StopAutoFight();
				nVHC_CURRENT_STEP = 5;
				return;
			end
		end
	end
end
function AutoVHC:DoStep5() -- go to npc thiết phù đồ, kill him
	local tbNpcs = KNpc.GetAroundNpcList(me, nNPC_FIND_RANGE);
	for _, npc in pairs (tbNpcs) do 
		if npc.szName == STEP_5_NPC1NAME then 
			AutoAi.StartAutoFight();
			return;
		end
		if npc.szName == BAG then 
			nVHC_CURRENT_STEP = 6;
			return;
		end
	end
end
function AutoVHC:DoStep6() -- pick bag
	if me.GetItemCountInBags(unpack(KEY)) > 0 then
		if STEP_6_TIMERID ~= 0 then 
			Ui.tbLogic.tbTimer:Close(STEP_6_TIMERID);
			STEP_6_TIMERID = 0;
		end
		nVHC_CURRENT_STEP = 7;
		return;
	else
		if STEP_6_TIMERID == 0 then 
			AutoAi.StopAutoFight();
			AutoVHC:_Step6_PickBag();
			STEP_6_TIMERID = Ui.tbLogic.tbTimer:Register(STEP_6_INTERVAL * Env.GAME_FPS, AutoVHC._Step6_PickBag);
		end
	end
end
function AutoVHC:_Step6_PickBag()
	local tbNpcs = KNpc.GetAroundNpcList(me, nNPC_FIND_RANGE);
	for _, npc in pairs(tbNpcs) do 
		if npc.szName == BAG then 
			AutoAi.SetTargetIndex(npc.nIndex);
			return;
		end
	end
	nVHC_CURRENT_STEP = 7; -- đã nhặt khóa và mở cửa
end
function AutoVHC:DoStep7() -- open door
	if STEP_6_TIMERID ~= 0 then 
		Ui.tbLogic.tbTimer:Close(STEP_6_TIMERID);
	end
	if Map.SMUltity:ImHere(STEP_7_NPCPOS) == 1 then 
		if STEP_7_ISDONE == 0 and STEP_7_TIMERID == 0 
			and Map.SMUltity:IsNpcHere(STEP_7_NPCNAME, nNPC_FIND_RANGE) ~= 0 then 
			AutoVHC:_Step7_OpenDoor();
			STEP_7_TIMERID = Ui.tbLogic.tbTimer:Register(STEP_7_INTERVAL * Env.GAME_FPS, AutoVHC._Step7_OpenDoor);
			return;
		elseif STEP_7_ISDONE == 1 or Map.SMUltity:IsNpcHere(STEP_7_NPCNAME, nNPC_FIND_RANGE) == 0 then 
			me.Msg("2");
			Ui.tbLogic.tbTimer:Close(STEP_7_TIMERID);
			STEP_7_TIMERID = 0;
			STEP_7_ISDONE = 0; -- RESET STEP 9
			nVHC_CURRENT_STEP = 8; -- go to next step
		end
	else
		me.StartAutoPath(STEP_7_NPCPOS[1], STEP_7_NPCPOS[2]);
	end
end
function AutoVHC:_Step7_OpenDoor()
	local nNpcIndex = Map.SMUltity:IsNpcHere(STEP_7_NPCNAME, nNPC_FIND_RANGE); -- cánh cửa
	if nNpcIndex ~= 0 then 
		AutoAi.SetTargetIndex(nNpcIndex);
	else
		STEP_7_ISDONE = 1;
	end
end
function AutoVHC:DoStep8() -- find and kill bách vũ
	local nNpcIndex = Map.SMUltity:IsNpcHere(STEP_8_NPCNAME, nNPC_FIND_RANGE);
	if nNpcIndex ~= 0 then 
		AutoAi.StartAutoFight();
		return;
	else
		AutoAi.StopAutoFight();
		nVHC_CURRENT_STEP = 9;
	end
end
function AutoVHC:DoStep9()	-- find and kill hoàng tán nhất.
	local nNpcIndex = Map.SMUltity:IsNpcHere(STEP_9_NPCNAME, nNPC_FIND_RANGE);
	if nNpcIndex ~= 0 and AutoAi.AiTargetCanAttack(nNpcIndex) == 1 then 
		AutoAi.StartAutoFight();
		return;
	else
		AutoAi.StopAutoFight();
		nVHC_CURRENT_STEP = 10;
	end
end
function AutoVHC:DoStep10() -- find and kill liễu sinh
	local nNpcIdx1 = Map.SMUltity:IsNpcHere(STEP_10_NPC1NAME, nNPC_FIND_RANGE);
	local nNpcIdx2 = Map.SMUltity:IsNpcHere(STEP_10_NPC2NAME, nNPC_FIND_RANGE);
	if nNpcIdx1 ~= 0 or nNpcIdx2 ~= 0 then 
		AutoAi.StartAutoFight();
		return;
	else
		if Map.SMUltity:IsArrived(STEP_10_NPCPOS) ~= 1 then 
			AutoAi.StopAutoFight();
			me.StartAutoPath(STEP_10_NPCPOS[1],STEP_10_NPCPOS[2]);
			return;
		end
		AutoAi.StopAutoFight();
		nVHC_CURRENT_STEP = 11;
		return;
	end
end
function AutoVHC:DoStep11() -- pick wine
	--if me.GetItemCountInBags(STEP_11_NPCID[1],STEP_11_NPCID[2],STEP_11_NPCID[3],STEP_11_NPCID[4]) > 0 then
	if me.GetItemCountInBags(unpack(STEP_11_NPCID)) > 0 then
		if STEP_11_TIMERID ~= 0 then 
			Ui.tbLogic.tbTimer:Close(STEP_11_TIMERID);
			STEP_11_TIMERID = 0;
		end
		nVHC_CURRENT_STEP = 12;
	else 
		if STEP_11_TIMERID == 0 then
			AutoVHC:_Step11_PickBag();
			STEP_11_TIMERID = Ui.tbLogic.tbTimer:Register(STEP_11_INTERVAL * Env.GAME_FPS, AutoVHC._Step11_PickBag);
		end
	end
end
function AutoVHC:_Step11_PickBag()
	local tbNpcs = KNpc.GetAroundNpcList(me, nNPC_FIND_RANGE);
	for _, npc in pairs(tbNpcs) do 
		if npc.szName == STEP_11_NPCNAME then 
			AutoAi.SetTargetIndex(npc.nIndex);
			return;
		end
	end
end
function AutoVHC:DoStep12()
	if STEP_12_TIMERID == 0 and STEP_12_ISDONE == 0 then 
		AutoVHC:_Step12_UseWine(); -- cross-delay
		STEP_12_TIMERID = Ui.tbLogic.tbTimer:Register(STEP_12_INTERVAL * Env.GAME_FPS, AutoVHC._Step12_UseWine);
	elseif STEP_12_ISDONE == 1 then 
		Ui.tbLogic.tbTimer:Close(STEP_12_TIMERID);
		STEP_12_TIMERID = 0;
		STEP_12_ISDONE = 0;
		AutoAi:UpdateCfg(Ui.tbLogic.tbAutoFightData:ShortKey());
		IsStartedAutoVHC = 0; -- stop
		return;
	end
end
function AutoVHC:_Step12_UseWine()
	local tbFind = me.FindItemInBags(unpack(STEP_12_NPCID));
	if not tbFind then 
		STEP_12_ISDONE = 1;
		return;
	end
	for _, tbItem in pairs(tbFind) do 
		me.UseItem(tbItem.pItem);
		me.UseItem(tbItem.pItem);
		
		return;
	end
end








































