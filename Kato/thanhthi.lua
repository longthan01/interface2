Ui.UI_thanh				= "UI_thanh";
local thanh			= Ui.tbWnd[Ui.UI_thanh] or {};
thanh.UIGROUP			= Ui.UI_thanh;
Ui.tbWnd[Ui.UI_thanh]	= thanh

local self			= thanh 

self.state = 0
self.state1 = 0
self.state2 = 0
self.state3 = 0
self.state4 = 0
self.state5 = 0
self.state6 = 0
--self.state7 = 0

local sTimers = 0
local sTimers1 = 0
local sTimers2 = 0
local sTimers3 = 0
local sTimers4 = 0
local sTimers5 = 0
local sTimers6 = 0
--local sTimers7 = 0


local uiSayPanel = Ui(Ui.UI_SAYPANEL)

function thanh:State()	
	if self.state == 0 then	
		sTimers = Ui.tbLogic.tbTimer:Register(Env.GAME_FPS * 0.2,18,self.OnTimer); 
		self.state = 1
	else		
		self.state = 0
		Ui.tbLogic.tbTimer:Close(sTimers);
		sTimers = 0
		Ui.tbScrCallUi:CloseWinDow()
	end	
end

function thanh.OnTimer()	
	if (self.state == 0) then
		return
	end
	local szQuestion, tbAnswers = UiCallback:GetQuestionAndAnswer();
	if me.GetMapTemplateId() < 65500 then
		if UiManager:WindowVisible(Ui.UI_SAYPANEL) == 1 then
		    me.AnswerQestion(1);
			me.AnswerQestion(0);
			for i = 1,table.getn(tbAnswers) do
				if string.find(tbAnswers[i],"Kết thúc đối thoại") then
					return thanh.Stop();		        					
				end					
			end
		else
			local tbItem = me.FindItemInBags(18,1,195,1)[1]; 
			if tbItem then
			me.UseItem(tbItem.pItem);
			end
		end						
	end
end

function thanh:State1()	
	if self.state1 == 0 then	
		sTimers1 = Ui.tbLogic.tbTimer:Register(Env.GAME_FPS * 0.2,18,self.OnTimer1); 
		self.state1 = 1
	else		
		self.state1 = 0
		Ui.tbLogic.tbTimer:Close(sTimers1);
		sTimers1 = 0
		Ui.tbScrCallUi:CloseWinDow()
	end	
end

function thanh.OnTimer1()	
	if (self.state1 == 0) then
		return
	end
	local szQuestion, tbAnswers = UiCallback:GetQuestionAndAnswer();
	if me.GetMapTemplateId() < 65500 then
		if UiManager:WindowVisible(Ui.UI_SAYPANEL) == 1 then
		    me.AnswerQestion(1);
			me.AnswerQestion(1);
			for i = 1,table.getn(tbAnswers) do
				if string.find(tbAnswers[i],"Kết thúc đối thoại") then
					return thanh.Stop();		        					
				end					
			end
		else
			local tbItem = me.FindItemInBags(18,1,195,1)[1]; 
			if tbItem then
			me.UseItem(tbItem.pItem);
			end
		end						
	end
end

function thanh:State2()	
	if self.state2 == 0 then	
		sTimers2 = Ui.tbLogic.tbTimer:Register(Env.GAME_FPS * 0.2,18,self.OnTimer2); 
		self.state2 = 1
	else		
		self.state2 = 0
		Ui.tbLogic.tbTimer:Close(sTimers2);
		sTimers2 = 0
		Ui.tbScrCallUi:CloseWinDow()
	end	
end

function thanh.OnTimer2()	
	if (self.state2 == 0) then
		return
	end
	local szQuestion, tbAnswers = UiCallback:GetQuestionAndAnswer();
	if me.GetMapTemplateId() < 65500 then
		if UiManager:WindowVisible(Ui.UI_SAYPANEL) == 1 then
		    me.AnswerQestion(1);
			me.AnswerQestion(2);
			for i = 1,table.getn(tbAnswers) do
				if string.find(tbAnswers[i],"Kết thúc đối thoại") then
					return thanh.Stop();		        					
				end					
			end
		else
			local tbItem = me.FindItemInBags(18,1,195,1)[1]; 
			if tbItem then
			me.UseItem(tbItem.pItem);
			end
		end						
	end
end

function thanh:State3()	
	if self.state3 == 0 then	
		sTimers3 = Ui.tbLogic.tbTimer:Register(Env.GAME_FPS * 0.2,18,self.OnTimer3); 
		self.state3 = 1
	else		
		self.state3 = 0
		Ui.tbLogic.tbTimer:Close(sTimers3);
		sTimers3 = 0
		Ui.tbScrCallUi:CloseWinDow()
	end	
end

function thanh.OnTimer3()	
	if (self.state3 == 0) then
		return
	end
	local szQuestion, tbAnswers = UiCallback:GetQuestionAndAnswer();
	if me.GetMapTemplateId() < 65500 then
		if UiManager:WindowVisible(Ui.UI_SAYPANEL) == 1 then
		    me.AnswerQestion(1);
			me.AnswerQestion(3);
			for i = 1,table.getn(tbAnswers) do
				if string.find(tbAnswers[i],"Kết thúc đối thoại") then
					return thanh.Stop();		        					
				end					
			end
		else
			local tbItem = me.FindItemInBags(18,1,195,1)[1]; 
			if tbItem then
			me.UseItem(tbItem.pItem);
			end
		end						
	end
end

function thanh:State4()	
	if self.state4 == 0 then	
		sTimers4 = Ui.tbLogic.tbTimer:Register(Env.GAME_FPS * 0.2,18,self.OnTimer4); 
		self.state4 = 1
	else		
		self.state4 = 0
		Ui.tbLogic.tbTimer:Close(sTimers4);
		sTimers4 = 0
		Ui.tbScrCallUi:CloseWinDow()
	end	
end

function thanh.OnTimer4()	
	if (self.state4 == 0) then
		return
	end
	local szQuestion, tbAnswers = UiCallback:GetQuestionAndAnswer();
	if me.GetMapTemplateId() < 65500 then
		if UiManager:WindowVisible(Ui.UI_SAYPANEL) == 1 then
		    me.AnswerQestion(1);
			me.AnswerQestion(4);
			for i = 1,table.getn(tbAnswers) do
				if string.find(tbAnswers[i],"Kết thúc đối thoại") then
					return thanh.Stop();		        					
				end					
			end
		else
			local tbItem = me.FindItemInBags(18,1,195,1)[1]; 
			if tbItem then
			me.UseItem(tbItem.pItem);
			end
		end						
	end
end

function thanh:State5()	
	if self.state5 == 0 then	
		sTimers5 = Ui.tbLogic.tbTimer:Register(Env.GAME_FPS * 0.2,18,self.OnTimer5); 
		self.state5 = 1
	else		
		self.state5 = 0
		Ui.tbLogic.tbTimer:Close(sTimers5);
		sTimers5 = 0
		Ui.tbScrCallUi:CloseWinDow()
	end	
end

function thanh.OnTimer5()	
	if (self.state5 == 0) then
		return
	end
	local szQuestion, tbAnswers = UiCallback:GetQuestionAndAnswer();
	if me.GetMapTemplateId() < 65500 then
		if UiManager:WindowVisible(Ui.UI_SAYPANEL) == 1 then
		    me.AnswerQestion(1);
			me.AnswerQestion(5);
			for i = 1,table.getn(tbAnswers) do
				if string.find(tbAnswers[i],"Kết thúc đối thoại") then
					return thanh.Stop();		        					
				end					
			end
		else
			local tbItem = me.FindItemInBags(18,1,195,1)[1]; 
			if tbItem then
			me.UseItem(tbItem.pItem);
			end
		end						
	end
end

function thanh:State6()	
	if self.state6 == 0 then	
		sTimers6 = Ui.tbLogic.tbTimer:Register(Env.GAME_FPS * 0.2,18,self.OnTimer6); 
		self.state6 = 1
	else		
		self.state6 = 0
		Ui.tbLogic.tbTimer:Close(sTimers6);
		sTimers6 = 0
		Ui.tbScrCallUi:CloseWinDow()
	end	
end

function thanh.OnTimer6()	
	if (self.state6 == 0) then
		return
	end
	local szQuestion, tbAnswers = UiCallback:GetQuestionAndAnswer();
	if me.GetMapTemplateId() < 65500 then
		if UiManager:WindowVisible(Ui.UI_SAYPANEL) == 1 then
		    me.AnswerQestion(1);
			me.AnswerQestion(6);
			for i = 1,table.getn(tbAnswers) do
				if string.find(tbAnswers[i],"Kết thúc đối thoại") then
					return thanh.Stop();		        					
				end					
			end
		else
			local tbItem = me.FindItemInBags(18,1,195,1)[1]; 
			if tbItem then
			me.UseItem(tbItem.pItem);
			end
		end						
	end
end
-------------------------------------------------------------------


function thanh.Stop()
	self.state = 1			
	thanh:State()	
    			
	self.state1 = 1 	
	thanh:State1()	
	
	self.state2 = 1			
	thanh:State2()	
    		
	self.state3 = 1			
	thanh:State3()	

	self.state4 = 1 	
	thanh:State4()	
	
	self.state5 = 1			
	thanh:State5()	
    		
	self.state6 = 1			
	thanh:State6()	
end
