Ui.UI_Server				= "UI_Server";
local Server			= Ui.tbWnd[Ui.UI_Server] or {};
Server.UIGROUP			= Ui.UI_Server;
Ui.tbWnd[Ui.UI_Server]	= Server

local self			= Server 

self.state = 0
self.state1 = 0
self.state2 = 0
self.state3 = 0

local sTimers = 0
local sTimers1 = 0
local sTimers2 = 0
local sTimers3 = 0


local uiSayPanel = Ui(Ui.UI_SAYPANEL)


function Server:State1()	
	if self.state1 == 0 then	
		sTimers1 = Ui.tbLogic.tbTimer:Register(Env.GAME_FPS * 0.2,18,self.OnTimer1); --2
		me.Msg("<color=white>Thông báo:<color> Chuẩn bi báo danh liên server");
		self.state1 = 1
	else		
		self.state1 = 0
		Ui.tbLogic.tbTimer:Close(sTimers1);
		me.Msg("<color=white>Thông báo:<color> Đã đến nơi");
		sTimers1 = 0
		Ui.tbScrCallUi:CloseWinDow()
	end	
end

function Server.OnTimer1()	
	if (self.state1 == 0) then
		return
	end
	local szQuestion, tbAnswers = UiCallback:GetQuestionAndAnswer();
	if me.GetMapTemplateId() < 65500 then
		if UiManager:WindowVisible(Ui.UI_SAYPANEL) == 1 then			
			for i = 1,table.getn(tbAnswers) do
				if string.find(tbAnswers[i],"<color=yellow>Mông Cổ Tây Hạ liên server") then
					me.Msg(tostring(""..tbAnswers[i]))
					return Env.GAME_FPS * 0.2, me.AnswerQestion(i-1);
				end					
			end
			for i = 1,table.getn(tbAnswers) do
				if string.find(tbAnswers[i],"Báo danh Biện Kinh") then
					me.Msg(tostring(""..tbAnswers[i]))
					return Env.GAME_FPS * 0.2, me.AnswerQestion(i-1), Ui.tbScrCallUi:CloseWinDow(), Server.Stop();
				end					
			end
		else
			local tbItem = me.FindItemInBags(18,1,195,1)[1]; -- vo han truyen tong phu
			if tbItem then
			me.UseItem(tbItem.pItem);
			end
		end						
	else
		return Env.GAME_FPS * 0.2, Ui.tbScrCallUi:CloseWinDow(), Server.Stop();
	end
end

function Server:State2()	
	if self.state2 == 0 then	
		sTimers2 = Ui.tbLogic.tbTimer:Register(Env.GAME_FPS * 0.2,18,self.OnTimer2); 
		UiManager:OpenWindow("UI_INFOBOARD", "<bclr=pink><color=white>Báo danh tiêu dao cốc !!!");
		self.state2 = 1
	else		
		self.state2 = 0
		Ui.tbLogic.tbTimer:Close(sTimers2);
		UiManager:OpenWindow("UI_INFOBOARD", "<bclr=pink><color=white>Đã đến !!!");
		sTimers2 = 0
		Ui.tbScrCallUi:CloseWinDow()
	end	
end

function Server.OnTimer2()	
	if (self.state2 == 0) then
		return
	end
	local szQuestion, tbAnswers = UiCallback:GetQuestionAndAnswer();
	if me.GetMapTemplateId() < 65500 then
		if UiManager:WindowVisible(Ui.UI_SAYPANEL) == 1 then			
			for i = 1,table.getn(tbAnswers) do
				if string.find(tbAnswers[i],"Tiêu Dao Cốc") then
					me.Msg(tostring(""..tbAnswers[i]))
					return Env.GAME_FPS * 0.2, me.AnswerQestion(i-1), Ui.tbScrCallUi:CloseWinDow(), Server.Stop();
				end					
			end	
			--for i = 1,table.getn(tbAnswers) do
				--if string.find(tbAnswers[i],"Báo danh Biện Kinh Phủ") then
					--me.Msg(tostring(""..tbAnswers[i]))
					--return Env.GAME_FPS * 1, me.AnswerQestion(i-1), Ui.tbScrCallUi:CloseWinDow(), Server.Stop();
				--end					
			--end
		else
			local tbItem = me.FindItemInBags(18,1,195,1)[1]; 
			if tbItem then
			me.UseItem(tbItem.pItem);
			end
		end						
	else
		return Env.GAME_FPS * 0.2, Ui.tbScrCallUi:CloseWinDow(), Server.Stop();
	end
end

function Server:State()	
	if self.state == 0 then	
		sTimers = Ui.tbLogic.tbTimer:Register(Env.GAME_FPS * 0.2,18,self.OnTimer); 
		UiManager:OpenWindow("UI_INFOBOARD", "<bclr=pink><color=white>Báo danh Mông Cổ Tây Hạ !!!");
		self.state = 1
	else		
		self.state = 0
		Ui.tbLogic.tbTimer:Close(sTimers);
		UiManager:OpenWindow("UI_INFOBOARD", "<bclr=pink><color=white>Đã đến !!!");
		sTimers = 0
		Ui.tbScrCallUi:CloseWinDow()
	end	
end

function Server.OnTimer()	
	if (self.state == 0) then
		return
	end
	local szQuestion, tbAnswers = UiCallback:GetQuestionAndAnswer();
	if me.GetMapTemplateId() < 65500 then
		if UiManager:WindowVisible(Ui.UI_SAYPANEL) == 1 then			
			for i = 1,table.getn(tbAnswers) do
				if string.find(tbAnswers[i],"Tính năng Mông Cổ Tây Hạ") then
					me.Msg(tostring(""..tbAnswers[i]))
					return Env.GAME_FPS * 0.2, me.AnswerQestion(i-1), Ui.tbScrCallUi:CloseWinDow(), Server.Stop();
				end					
			end
			--for i = 1,table.getn(tbAnswers) do
				--if string.find(tbAnswers[i],"Báo danh Đại Lý") then
					--me.Msg(tostring(""..tbAnswers[i]))
					--return Env.GAME_FPS * 1, me.AnswerQestion(i-1), Ui.tbScrCallUi:CloseWinDow(), Server.Stop();
				--end					
			--end
		else
			local tbItem = me.FindItemInBags(18,1,195,1)[1]; 
			if tbItem then
			me.UseItem(tbItem.pItem);
			end
		end						
	else
		return Env.GAME_FPS * 0.2, Ui.tbScrCallUi:CloseWinDow(), Server.Stop();
	end
end

function Server:State3()	
	if self.state3 == 0 then	
		sTimers3 = Ui.tbLogic.tbTimer:Register(Env.GAME_FPS * 0.2,18,self.OnTimer3); 
		UiManager:OpenWindow("UI_INFOBOARD", "<bclr=pink><color=white>Báo danh BHD liên server !!!");
		self.state3 = 1
	else		
		self.state3 = 0
		Ui.tbLogic.tbTimer:Close(sTimers3);
		UiManager:OpenWindow("UI_INFOBOARD", "<bclr=pink><color=white>Đã đến !!!");
		sTimers3 = 0
		Ui.tbScrCallUi:CloseWinDow()
	end	
end

function Server.OnTimer3()	
	if (self.state3 == 0) then
		return
	end
	local szQuestion, tbAnswers = UiCallback:GetQuestionAndAnswer();
	if me.GetMapTemplateId() < 65500 then
		if UiManager:WindowVisible(Ui.UI_SAYPANEL) == 1 then			
			for i = 1,table.getn(tbAnswers) do
				if string.find(tbAnswers[i],"Bạch Hổ Đường") then
					me.Msg(tostring(""..tbAnswers[i]))
					return Env.GAME_FPS * 1, me.AnswerQestion(i-1);
				end					
			end
			for i = 1,table.getn(tbAnswers) do
				if string.find(tbAnswers[i],"Báo danh Đại Lý") then
					me.Msg(tostring(""..tbAnswers[i]))
					return Env.GAME_FPS * 0.2, me.AnswerQestion(i-1), Ui.tbScrCallUi:CloseWinDow(), Server.Stop();
				end					
			end
		else
			local tbItem = me.FindItemInBags(18,1,195,1)[1]; 
			if tbItem then
			me.UseItem(tbItem.pItem);
			end
		end						
	else
		return Env.GAME_FPS * 0.2, Ui.tbScrCallUi:CloseWinDow(), Server.Stop();
	end
end
-------------------------------------------------------------------


function Server.Stop()	
	if self.state1 == 1 then	
	    Server:State1()	
	end

	if self.state2 == 1	then		
	    Server:State2()	
    end	
	
	if self.state == 1	then		
	    Server:State()	
    end	
	
	if self.state3 == 1	then		
	    Server:State3()	
    end
	
end
