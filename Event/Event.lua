
Ui.UI_Event				= "UI_Event";
local Event			= Ui.tbWnd[Ui.UI_Event] or {};
Event.UIGROUP			= Ui.UI_Event;
Ui.tbWnd[Ui.UI_Event]	= Event

Event.state1 = 0
local sTimers1 = 0
local uiSayPanel = Ui(Ui.UI_SAYPANEL)

function Event:State1()	
	if Event.state1 == 0 then	
		UiManager:OpenWindow("UI_INFOBOARD", "<bclr=Black><color=Yellow>Ăn Bao Lì Xì Không KNB<color>");
		sTimers1 = Ui.tbLogic.tbTimer:Register(Env.GAME_FPS * 0.5,18,Event.OnTimer1); --2
		Event.state1 = 1
	else	
		UiManager:OpenWindow("UI_INFOBOARD", "<bclr=Black><color=Red>Stop<color>");
		Event.state1 = 0
		Ui.tbLogic.tbTimer:Close(sTimers1);
		sTimers1 = 0
		Ui.tbScrCallUi:CloseWinDow()
	end	
end

function Event.OnTimer1()	
	local nMapId,nMyPosX,nMyPosY = me.GetWorldPos()
	local szQuestion, tbAnswers = UiCallback:GetQuestionAndAnswer();
		
		if UiManager:WindowVisible(Ui.UI_SAYPANEL) == 1 then
			UiManager:SwitchWindow(Ui.UI_SAYPANEL)
				for i = 1,table.getn(tbAnswers) do
					me.AnswerQestion(0)
					break
				end
		else
			if me.GetItemCountInBags(18,1,20687,1) > 0 then
				local tbFind = me.FindItemInBags(18,1,20687,1);
				for j, tbItem in pairs(tbFind) do
					me.UseItem(tbItem.pItem);
				end	
			else
				Event.Stop()
			end
			
		end
end

function Event.DoiThoaiNPC(idNPC)
	local tbAroundNpc	= KNpc.GetAroundNpcList(me, 1000);
		for _, pNpc in ipairs(tbAroundNpc) do		
			if (pNpc.nTemplateId == idNPC) then					
				AutoAi.SetTargetIndex(pNpc.nIndex)
				return Env.GAME_FPS * 0.5
			end
		end
end
-------------------------------------------------------------------

function Event.Stop()
	
	Event.state1 = 1 
	Event:State1()		
end
Ui:RegisterNewUiWindow("UI_Event", "Event", {"a", 250, 150}, {"b", 250, 150}, {"c", 250, 150});
local tCmd={"Ui(Ui.UI_Event):State1()", "Event", "", "Shift+W", "Shift+W", "Gánh nước"};
	AddCommand(tCmd[4], tCmd[3], tCmd[2], tCmd[7] or UiShortcutAlias.emKSTATE_INGAME);
	UiShortcutAlias:AddAlias(tCmd[2], tCmd[1]);
