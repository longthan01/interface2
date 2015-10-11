Require("\\interface2\\smalldragon\\Ultity.lua");

local self = AutoBigDesert;
local AutoBigDesert = Map.AutoBigDesert or {};
Map.AutoBigDesert = AutoBigDesert; -- assign new table to Map table


local nIsABDStarted = 0;
local nABDTimerId = 0;
local nABDInterval = 0.4;
local nABDCurrentStep = 1;
local nABDMaxStep = 7;
local nABDFindRange = 600;
local nABDLevel = 6; -- 6 star
local szTreasureName = "damogucheng";

local PICKITEM_INTERVAL = 40; -- default picking item interval
local USEITEM_INTERVAL = 40; -- default using item interval 

-- temporary variables
--
local STEP_CONFIG = {
	[1] = { -- go to quan nhu nghĩa quân, sign and enter treasure map
		POS = {1630,3944},
		ACTION = "login",
		NPCNAME = "Quan Quân Nhu (nghĩa quân)",
		MAPID = 29,
		FINDRANGE = 20, -- range to find npc Quan Nhu
		ISDONE = 0,
	},
	[2] = { -- go to diện cụ võ sĩ, kill him
		POS = {1740,3277},
		ACTION = "killnpc",
		NPCNAME = "Diện Cụ Võ Sĩ",
		ISDONE = 0,
	},
	[3] = { -- pick túi vải, tìm thấy chìa khóa xích sắt
		POS = {1740,3277},
		ACTION = "pickitem",
		TIMERID = 0,
		ITEMNAME = "1 túi vải",
		ITEMID = {18,1,95,1},
		PRECONDITION = "killallfirst",
		ISDONE = 0,
	},
	[4] = {	-- goto úy lữ, follow him 
		POS = {1656,3267},
		ACTION = "follownpc",
		NPCNAME = "Úy Lữ",
		DESTPOS = {1716,3300},
		PRECONDITION = "talktofirst",
		PRECONDITION_TALK_QUESTION = "",
		PRECONDITION_TALK_ANSWERSTRING = "giúp ngươi mở chiếc khóa này",
		ISDONE = 0,
	},
	[5] = {	-- go to Thi Trục Đạt Lỗ, kill him 
		POS = {1804, 3280}, 
		ACTION = "killnpc",
		NPCNAME = "Thi Trục Đạt Lỗ",
		ISDONE = 0,
	},
	[6] = {	-- pick túi lâu năm, tìm thấy đàn cổ
		POS = {1805, 3281},
		ACTION = "pickitem",
		TIMERID = 0,
		ITEMNAME = "Túi lâu năm",
		ITEMID = {18,1,1014,1},
		PRECONDITION = "killallfirst",
		ISDONE = 0,
	},
	[7] = {		-- go to des pos, use đàn cổ
		POS = {1908,3319},
		ACTION = "useitem",
		ITEMID = {18,1,1014,1},
		TIMERID = 0,
		ISDONE = 0,
	},
	[8] = { -- kill vô danh thị
		POS = {1906, 3320}, 
		ACTION = "killnpc",
		NPCNAME = "Vô Danh Thị",
		ISDONE = 0,
	}
};

function AutoBigDesert:IsPreconditionOk(nStep)
	UiManager:OpenWindow("UI_INFOBOARD","<color=yellow>Current step: "..nStep.."<color>");
	if nIsABDStarted == 0 then -- if flag is off, auto will be stop
		if nABDTimerId ~= 0 then
			Ui.tbLogic.tbTimer:Close(nABDTimerId);
			UiManager:OpenWindow("UI_INFOBOARD","<color=red>Auto stopped.<color>");
			return 0;
		end
	end
	
    if Map.SMUltity:IsArrived(STEP_CONFIG[nStep]["POS"]) == 0 then -- if not arrive pos
        Map.SMUltity:GotoWorldPos(STEP_CONFIG[nStep]["POS"]);
		return 0;
	end
    return 1;
end
function AutoBigDesert:IStepDone(nStep)
	return STEP_CONFIG[nStep]["ISDONE"];
end
function AutoBigDesert:Start()
	if Map.SMUltity:IsTeamLead("me") == 0 then 
		UiManager:OpenWindow("UI_INFOBOARD","<color=red>Only leader can be open treasure map. Auto stopped.<color>");
		return;
	end
    if n == 0 then
        nIsABDStarted = 1; -- start auto
        nABDTimerId = Ui.tbLogic.tbTimer:Register(nABDInterval * Env.GAME_FPS, AutoBigDesert.DoStep);
    end
end
function AutoBigDesert:Stop()
    if nIsABDStarted == 1 then
        nIsABDStarted = 0;
        Ui.tbLogic.tbTimer:Close(nABDTimerId);
		UiManager:OpenWindow("UI_INFOBOARD", "<color=red>Auto big desert stopped.<color>");
		-- add close step timer statement here
		for i=1, #STEP_CONFIG do 
			if STEP_CONFIG[i]["TIMERID"] then 
				if STEP_CONFIG[i]["TIMERID"] ~= 0 then 
					Ui.tbLogic.tbTimer:Close(STEP_CONFIG[i]["TIMERID"]);
				end
			end
		end
    end
end
function AutoBigDesert:DoStep()
	-- if current step is processed, go to next step
	if STEP_CONFIG[nABDCurrentStep]["ISDONE"] = 1 then 
		nABDCurrentStep = nABDCurrentStep + 1;
		-- if current step > max step mean is all step is processed, stop auto
		if nABDCurrentStep > nABDMaxStep then  
			AutoBigDesert:Stop();
			return;
		end
	end
	-- if CLOSEDIALOG not define, default is true 
	if not STEP_CONFIG[nABDCurrentStep]["CLOSEDIALOG"] then 
		if UiManager:WindowVisible(Ui.UI_SAYPANEL) == 1 then 
			UiManager:CloseWindow(Ui.UI_SAYPANEL);
		end
	else -- else if CLOSEDIALOG is defined, process it
		if STEP_CONFIG[nABDCurrentStep]["CLOSEDIALOG"] ~= 0 then 
			if UiManager:WindowVisible(Ui.UI_SAYPANEL) == 1 then 
				UiManager:CloseWindow(Ui.UI_SAYPANEL);
			end
		end
	end
	-- here if step is undone, process step
	if string.find(STEP_CONFIG[nABDCurrentStep]["ACTION"], "login") then
		AutoBigDesert:LoginTreasure();
	elseif string.find(STEP_CONFIG[nABDCurrentStep]["ACTION"], "killnpc") then
		AutoBigDesert:KillNpc(nABDCurrentStep);
	elseif string.find(STEP_CONFIG[nABDCurrentStep]["ACTION"], "pickitem") then
		AutoBigDesert:RegisterPickItem(nABDCurrentStep);
	elseif string.find(STEP_CONFIG[nABDCurrentStep]["ACTION"], "useitem") then 
		AutoBigDesert:RegisterUseItem(nABDCurrentStep);
	elseif string.find(STEP_CONFIG[nABDCurrentStep]["ACTION"], "follownpc") then
		AutoBigDesert:FollowNpc(nABDCurrentStep);
	end
end
-- [[ nStep always is current step ]]--
function AutoBigDesert:KillNpc(nStep)
	local npcIdx = Map.SMUltity:IsNpcHere(STEP_CONFIG[nStep]["NPCNAME"], nABDFindRange);
	if npcIdx == 0 then
		-- if npc is killed, update status
		STEP_CONFIG[nStep]["ISDONE"] = 1;
		return;
	end
	-- if npc already killed, return
	if AutoAi.AiTargetCanAttack(npcIdx) == 0 then 
		STEP_CONFIG[nStep]["ISDONE"] = 1;
		return;
	else
		AutoAi.StartAutoFight();
	end
end
function AutoBigDesert:FollowNpc(nStep)
	local nNpcIndex = Map.SMUltity:IsNpcHere(STEP_CONFIG[nStep]["NPCNAME"], nABDFindRange);
	-- if npc not found, return
	if nNpcIndex == 0 then 
		STEP_CONFIG[nStep]["ISDONE"] = 1;
		return;
	end
	-- if found npc, check pre-condition
	-- talk
	if string.find(STEP_CONFIG[nStep]["PRECONDITION"], "talktofirst") then 
		AutoAi.SetTargetIndex(nNpcIndex);
		if UiManager:WindowVisible(Ui.UI_SAYPANEL) == 1 then 
			local ques, tbAnswers = UiCallback:GetQuestionAndAnswer();
			for i, answer in ipairs(tbAnswers) do
				local config_ques = STEP_CONFIG[nStep]["PRECONDITION_TALK_QUESTION"];
				local config_answer = STEP_CONFIG[nStep]["PRECONDITION_TALK_ANSWERSTRING"];
				if string.find(ques, config_ques) 
				and string.find(answer, config_answer) then
					me.AnswerQestion(i-1);
				end
			end	
		end
		if UiManager:WindowVisible(Ui.UI_SAYPANEL) == 1 then 
			UiManager:CloseWindow(Ui.UI_SAYPANEL);
		end
	elseif string.find(STEP_CONFIG[nStep]["PRECONDITION"], "settargetindex") then 
		AutoAi.SetTargetIndex(nNpcIndex);
	end
	
	-- if i'm arrived DESTPOS, update status, return 
	if Map.SMUltity:IsArrived(STEP_CONFIG[nStep]["DESTPOS"]) == 1 then 
		STEP_CONFIG[nStep]["ISDONE"] = 1;
		return;	
	end
	
	local tbNpcs = KNpc.GetAroundNpcList(me, nABDFindRange);
	for _, npc in pairs(tbNpcs) do 
		if string.find(npc.szName, STEP_CONFIG[nStep]["NPCNAME"]) then 
			local _,x,y = npc.GetWorldPos();
			me.StartAutoPath(x,y);
		end
	end
end
function AutoBigDesert:RegisterPickItem(nStep)
	local itemCount = me.GetItemCountInBags(unpack(STEP_CONFIG[nStep]["ITEMID"]));
	-- if item count > 0 mean item is already picked
	if itemCount > 0 then 
		if STEP_CONFIG[nStep]["TIMERID"] ~= 0 then
			Ui.tbLogic.tbTimer:Close(STEP_CONFIG[nStep]["TIMERID"]);
			STEP_CONFIG[nStep]["TIMERID"] = 0;
		end
		STEP_CONFIG[nStep]["ISDONE"] = 1; 
	else
		if STEP_CONFIG[nStep]["TIMERID"] == 0 then 
			STEP_CONFIG[nStep]["TIMERID"] = Ui.tbLogic.tbTimer:Register(PICKITEM_INTERVAL * Env.GAME_FPS, AutoBigDesert.OnTimerPickItem);
		end
	end
end
function AutoBigDesert:OnTimerPickItem()
	local tbNpcs = KNpc.GetAroundNpcList(me,nABDFindRange);
	for _, npc in pairs(tbNpcs) do 
		if string.find(npc.szName, STEP_CONFIG[nABDCurrentStep]["ITEMNAME"]) then 
			AutoAi.SetTargetIndex(ncp.nIndex);
			return;
		end
	end
end
function AutoBigDesert:RegisterUseItem(nStep)
	local nItemCount = me.GetItemCountInBags(unpack(STEP_CONFIG[nStep]["ITEMID"]));
	-- if not found item in bag, step already is done, return
	if nItemCount == 0 then 
		if STEP_CONFIG[nStep]["TIMERID"] ~= 0 then 
			Ui.tbLogic.tbTimer:Close(STEP_CONFIG[nStep]["TIMERID"]);
		end
		STEP_CONFIG[nStep]["ISDONE"] = 1;
		return;
	end
	-- here is if item currently in bag, register use item
	if STEP_CONFIG[nStep]["TIMERID"] == 0 then 
		STEP_CONFIG[nStep]["TIMERID"] = Ui.tbLogic.tbTimer:Register(USEITEM_INTERVAL * Env.GAME_FPS, AutoBigDesert.OnTimerUseItem);
	end
end
function AutoBigDesert:OnTimerUseItem()
	Map.SMUltity:UseItem(STEP_CONFIG[nABDCurrentStep]["ITEMID"]);
end
function AutoBigDesert:LoginTreasure()
	local nMapId, x,y = me.GetWorldPos();
	if STEP_CONFIG[nABDCurrentStep]["MAPID"] then 
		if nMapId ~= STEP_CONFIG[nABDCurrentStep]["MAPID"] then 
			UiManager:OpenWindow("UI_INFOBOARD","<color=red>Please move to Lâm An city. Auto stopped.<color>");
			AutoBigDesert:Stop();
			return;
		end
	end
	local tbNpcs = KNpc.GetAroundNpcList(me, STEP_CONFIG[nABDCurrentStep]["FINDRANGE"]);
	for _, npc in pairs(tbNpcs) do 
		if string.find(npc.szName, STEP_CONFIG[nABDCurrentStep]["NPCNAME"]) then 
			-- sign treasure
			me.CallServerScript({"PlayerCmd","SignTreasure",szTreasureName,nABDLevel});
			-- enter treasure
			if UiManager:WindowVisible(Ui.UI_SAYPANEL) == 1 then 
			local ques, tbAnswers = UiCallback:GetQuestionAndAnswer();
				for i, tbInfo in ipairs(tbAnswers) do
					me.Msg(tbInfo.." - "..i);
					if string.find(tbInfo, "Dạng thường") then
						me.AnswerQestion(i-1);
						UiManager:CloseWindow(Ui.UI_SAYPANEL);
						me.CallServerScript({"PlayerCmd", "EnterTreasure"});
					end
				end	
			end
		end
	end
end













