
------------------------Quốc Huy-----------------------------------

local nTimerId = 0;
local nNext = 0; 
local nAuto = 1; 

function AutoAi:StartQuickPray()
	if nTimerId == 0 then
		Ui(Ui.UI_TASKTIPS):Begin("<color=yellow>Bắt Đầu Quay<color>");
		nTimerId = Ui.tbLogic.tbTimer:Register(18, AutoAi.OnQuickPrayTimer, AutoAi);
	end
end

function AutoAi:StopQuickPray()
	if nTimerId > 0 then
		Ui.tbLogic.tbTimer:Close(nTimerId);
		nTimerId = 0;
	end
end

function AutoAi:OnQuickPrayTimer()
	local nMyMapId, nMyPosX, nMyPosY	= me.GetWorldPos();
	if (nMyMapId <= 0 or nMyPosX <= 0) then
		return;
	end

	if UiManager:WindowVisible(Ui.UI_SKILLPROGRESS) == 1 then
		return;
	end
	local nAllowPray = Task.tbPlayerPray:CheckAllowPray(me);     
	if (nAllowPray == 0) then	
		me.CallServerScript({"PlayerPrayCmd"});
	end
	local nAwardFlag = Task.tbPlayerPray:CheckAllowGetAward(me); 
	if nAwardFlag == 2 then
		me.Msg("<color=yellow>Rương Đầy<color>");
		AutoAi:StopQuickPray();
		return;
	end
	if nAwardFlag == 0 then
		me.Msg("<color=yellow>Nhận Thưởng<color>");
		me.CallServerScript({"ApplyGetPrayAward"});
		if nNext == 0 then
			AutoAi:StopQuickPray(); 
		end
	end
	if (nAllowPray > 0 and nAwardFlag == 1) then

		AutoAi:StopQuickPray();
	end
end

--[[function AutoAi:_Init()
	self.EnterGame_bak	= self.EnterGame_bak or Ui.EnterGame;
    function Ui:EnterGame()
	    AutoAi.EnterGame_bak(Ui);
	    AutoAi:OnEnterGame();
	if nAuto == 1 then
		AutoAi:StartQuickPray();
	end
	    print("AutoAi Loaded!");
    end
end]]

