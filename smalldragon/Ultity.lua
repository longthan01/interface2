local SMUltity	   = Map.SMUltity or {};
Map.SMUltity	   = SMUltity;
local ARRIVE_RANGE = 4;
local NPC_ARRIVE_RANGE = 2;
function SMUltity:GoToMiniPos(x,y)
	me.StartAutoPath(x*8, y*16);
end

function SMUltity:GotoWorldPos(tbPos)
	me.StartAutoPath(tbPos[1], tbPos[2]);
end
function SMUltity:GetCurrentWorldPos()
	local _,x,y = me.GetWorldPos();
	return x,y;
end
function SMUltity:GetCurrentMapId()
	local nMapId,_,__ = me.GetWorldPos();
	return nMapId;
end
function SMUltity:PrintCurrentWorldPos()
	local nMapId, nx,ny = me.GetWorldPos();
	me.Msg("MapId: "..nMapId);
	me.Msg("X: "..nx.." Y: "..ny);
end
function SMUltity:ImHere(tbPos)	-- return 1 if me is arrived to tbPos
	local _, x,y = me.GetWorldPos();
	if x == tbPos[1] and y == tbPos[2] then 
		return 1;
	else 
		return 0;
	end
end
function SMUltity:IsNpcHere(szNpcName, nFindRange) -- return npcIndex if npc is here
	local tbNpcs = KNpc.GetAroundNpcList(me, nFindRange);
	for _, npc in pairs(tbNpcs) do 
		if string.find(npc.szName,szNpcName) == 1 then 
			return npc.nIndex;
		end
	end
	return 0;
end
function SMUltity:_IsArrived(worldx, worldy, myx, myy, arrive_range) -- world map pos 
	if myx <= worldx + arrive_range 
	and myx >= worldx - arrive_range 
	and myy <= worldy + arrive_range 
	and myy >= worldy - arrive_range then 
		return 1;
	end
	return 0;
end
function SMUltity:IsArrived(tbWorldPos) -- for me
	local myx, myy = SMUltity:GetCurrentWorldPos();
	return SMUltity:_IsArrived(tbWorldPos[1], tbWorldPos[2], myx, myy, ARRIVE_RANGE);
end
function SMUltity:IsNpcArrived(npcX,npcY,tbWorldPos) -- return 1 if npc is relative arrived tbWorldPos
	return SMUltity:_IsArrived(tbWorldPos[1], tbWorldPos[2], npcX,npcY, NPC_ARRIVE_RANGE); -- NPC_ARRIVE_RANGE is relative range to compare pos
end
function SMUltity:WriteFile(szOutFile, szData)
	KFile.WriteFile(szOutFile, szData);
end
function SMUltity:IsTeamLead(szTeamMemberName) -- return 1 if szTeamMemberName is team leader
	if szTeamMemberName == me.GetNpc().szName or szTeamMemberName == "me" then 
		return SMUltity:_ImTeamLead();
	end
	local tbMember = me.GetTeamMemberInfo();
	if tbMember then
		for i = 1, #tbMember do
			if tbMember[i].nLeader == 1 and tbMember[i].szName == szTeamMemberName then
				return 1;
			end
		end
	end
	return 0;
end
function SMUltity:_ImTeamLead() -- return 1 if me is team leader
	local tbMember = me.GetTeamMemberInfo();
	if tbMember then
		for i = 1, #tbMember do
			if tbMember[i].nLeader == 1 then
				return 0;
			end
		end
	end
	return 1;
end
function SMUltity:CloseTimer(nTimerId) -- close a timer id 
	if nTimerId ~= 0 then 
		Ui.tbLogic.tbTimer:Close(nTimerId);
	end
end
function SMUltity:TalkToNpcWithAnswerString(nNpcIndex,szQuestion,szAnswer) -- talk to npc and choose an answer by string
	if UiManager:WindowVisible(Ui.UI_SAYPANEL) == 1 then
		local ques, tbAnswers = UiCallback:GetQuestionAndAnswer();
		for i, answer in ipairs(tbAnswers) do
			if string.find(ques, szQuestion) then 
				if string.find(szAnswer, answer) then
					me.AnswerQestion(i-1);
					return 1; -- success
				end
			end
		end
	else
		AutoAi.SetTargetIndex(nNpcIndex);
	end
	return 0; -- unsuccess
end
function SMUltity:TalkToNpcWithAnswerIndex(nNpcIndex, szQuestion, nAnswerIndex) -- talk to npc and choose an answer by index
	if UiManager:WindowVisible(Ui.UI_SAYPANEL) == 1 then
		me.AnswerQestion(nAnswerIndex);
		return 1; -- success
	else
		AutoAi.SetTargetIndex(nNpcIndex);
	end
	return 0; -- unsuccess
end






