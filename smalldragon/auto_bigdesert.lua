Require("\\interface2\\smalldragon\\Ultity.lua");

local seft = AutoBigDesert;
local AutoBigDesert = Map.AutoBigDesert or {};
Map.AutoBigDesert = AutoBigDesert; -- assign new table to Map table
local SMUltity = Map.SMUltity or {};
Map.SMUltity = SMUltity;

local nIsAutoTreasureStarted = 0;
local nAutoTreasureTimerId = 0;
local nAutreasureInterval = 0.4;
local nCurrentStep = 1;
local nFindRange = 600;

local STEP_STATUS = { -- Done/UnDone
	[1] = {
		[1] = {NPC = "UnDone", ITEM = "UnDone"},
		[2] = {NPC = "UnDone", ITEM = "UnDone"}
	},
	[2] = {NPC = "UnDone", ITEM = "UnDone"},
	[3] = {NPC = "UnDone", ITEM = "UnDone"},
};
local STEP_POS = {
    [1] = {1740,3277},
    [2] = {1656, 3265}
};
local STEP_ITEM_CONFIG_COLLECTION {
	[1] = {
		[1] = {
			ITEM_ACTION = "Pick",
			ITEM_NAME_ONTHEGROUND = "1 túi vãi",
			ITEM_NAME_INBAG = "Chìa khóa xích sắt",
			ITEM_ID = {18,1,95,1},
			ITEM_POS = {1740,3277}
		}
	},
	[2] = {},
	[3] = {}
};
local STEP_NPC_CONFIG_COLLECTION{
	[1] = {
		[1] = {
				NPC_ACTION = "Kill",
				NPC_NAME = "Diện Cụ Võ Sĩ",
				NPC_PRECONDITION = "null"
			}
		},
	[2] = {
		[1] = {
			NPC_ACTION = "Follow",
			NPC_DESPOS = {100,100}, -- temporary
			NPC_NAME = "Úy Lữ",
			NPC_PRECONDITION = "Say",
			NPC_PRECONDITION_SAYSTRING = "",
			NPC_PRECONDITION_SAYINDEX = 0
			}
		},
	[3] = {},
};

function AutoBigDesert:IsPreconditionOk(nStep)
	UiManager:OpenWindow("UI_INFOBOARD","<color=yellow>Current step: "..nStep.."<color>");
	if nIsAutoTreasureStarted == 0 then -- if flag is off, auto will be stop
		if nAutoTreasureTimerId ~= 0 then
			Ui.tbLogic.tbTimer:Close(nAutoTreasureTimerId);
			return 0;
		end
	end
    if nStep then
        if SMUltity:IsArrived(STEP_POS[nStep]) == 0 then
            Map.SMUltity:GotoWorldPos(STEP_POS[nStep]);
			return 0;
        end
    end
    return 1;
end
function AutoBigDesert:Start()
	if SMUltity:IsTeamLead("me") == 0 then 
		UiManager:OpenWindow("UI_INFOBOARD", "<bclr=pink><color=yellow>Only Leader can open treasure. Auto stopped.<color>");
		return;
	end
    if nIsAutoTreasureStarted == 0 then
        nIsAutoTreasureStarted = 1; -- start auto
        nAutoTreasureTimerId = Ui.tbLogic.tbTimer:Register(nAutreasureInterval * Env.GAME_FPS, AutoBigDesert.DoStep);
    end
end
function AutoBigDesert:Stop()
    if nIsAutoTreasureStarted == 1 then
        nIsAutoTreasureStarted = 0;
        Ui.tbLogic.tbTimer:Close(nAutoTreasureTimerId);
		UiManager:OpenWindow("UI_INFOBOARD", "<bclr=pink><color=red>Auto big-desert stopped.<color>");
		-- add statement close step timer here
		
    end
end
function AutoBigDesert:DoStep()
	if AutoBigDesert:IsPreconditionOk() == 0 then 
		return; 
	end
	local i = nCurrentStep;
	if STEP_NPC_CONFIG_COLLECTION[i] then
		
	end
end
function ProcessNpc(npcConfig)
	if npcConfig["NPC_ACTION"]
	and npcConfig["NPC_PRECONDITION"] 
	and npcConfig["NPC_NAME"] then -- check config is right
	
		if npcConfig["NPC_ACTION"] == "Kill" then
			AutoBigDesert:KillNpc(npcConfig);
		-- FOLLOW
		elseif npcConfig["NPC_ACTION"] == "Follow" then 
			-- find npc, if npc is zombie, we must be kill him firstly.
			
		end
	else
		UiManager:OpenWindow("UI_INFOBOARD", "<bclr=red><color=red>There are somethings wrong in your config. Auto stopped.<color>");
		AutoBigDesert:Stop();
	end
end

function AutoBigDesert:KillNpc(npcConfigItem, nIndexInCurrentStep)
	-- check pre-condition
	if npcConfigItem["NPC_PRECONDITION"] == "SetTargetIndex" then
		local npcIdx = SMUltity:IsNpcHere(npcConfigItem["NPC_NAME"], nFindRange);
		if npcIdx == 0 then
			-- if npc is killed, update status
			STEP_STATUS[nCurrentStep]["NPC"] = "Done";
		else -- npc is here
			AutoAi.SetTargetIndex(npcIdx);
		end
	end
	-- start auto fight
	local tbNpcs = KNpc.GetAroundNpcList(me, nFindRange);
	for _, npc in pairs(tbNpcs) do 
		if npc.szName == npcConfigItem["NPC_NAME"] then 
			AutoAi.StartAutoFight();
			return;
		end
	end
	STEP_STATUS[nCurrentStep][nIndexInCurrentStep]["NPC"] = "Done";
end

function AutoBigDesert:FollowNpc(tbNpcConfigItem, nNpcIndexInCurrentStep)
	local npcIndex = SMUltity:IsNpcHere(npcConfig["NPC_NAME"], nFindRange);
	
	if npcIndex == 0 then  -- if not found npc, set current's npc status is done
		STEP_STATUS[nCurrentStep][nNpcIndexInCurrentStep]["NPC"] = "Done";
		return;
	end
	
	if tbNpcConfigItem["NPC_PRECONDITION"] == "SetTargetIndex" then  -- action = set target index 
		if npcIndex == 0 then
			return; -- if not found npc
		else -- npc is here
			if AutoAi.AiTargetCanAttack(npcIndex) == 1 then
				AutoAi.SetTargetIndex(npcIndex);
			end
		end
	elseif tbNpcConfigItem["NPC_PRECONDITION"] == "Say" then -- action = say
	-- npc must be set target index firstly
		AutoAi.SetTargetIndex(npcIndex);
		if UiManager:WindowVisible(Ui.UI_SAYPANEL) == 1 then	-- if is visible say panel (target index has been set)
			if tbNpcConfigItem["NPC_PRECONDITION_SAYSTRING"] then -- find answer by string 
			local ques, tbAnswers = UiCallback:GetQuestionAndAnswer();
			for i, tbInfo in ipairs(tbAnswers) do
				if string.find(tbInfo, tbNpcConfigItem["NPC_PRECONDITION_SAYSTRING"]) then
					me.AnswerQestion(i-1);
				end
			end
			else
				if tbNpcConfigItem["NPC_PRECONDITION_SAYINDEX"] then -- find answer by index 
					me.AnswerQestion(tbNpcConfigItem["NPC_PRECONDITION_SAYINDEX"]);
				end
			end
		end
		-- close ui say panel if auto is delayed.
		if UiManager:WindowVisible(Ui.UI_SAYPANEL) == 1 then 
			UiManager:CloseWindow(Ui.UI_SAYPANEL);
		end
	end
	-- follow
	local npcs = KNpc.GetAroundNpcList(me, nFindRange);
	for _, npc in pairs(npcs) do
		if npc.szName == tbNpcConfigItem["NPC_NAME"] then
			local _, x, y = npc.GetWorldPos();
			SMUltity:GotoWorldPos({x,y});
			return;
		end
	end
	-- end follow, turn on flag 
	STEP_STATUS[nCurrentStep]["NPC"] = "Done";
end








































