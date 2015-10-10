local uiCheckTeacher = Ui(Ui.UI_CHECKTEACHER);
local self = uiCheckTeacher
self.nquick = 0; 

local nTimeOut = 0;  
local Space_Time = 0.17;  


uiCheckTeacher.quickPickup = function(self)

	if self.nquick ==0 then
		self.nquick=1;
		nTimeOut = Timer:Register(Space_Time * Env.GAME_FPS, self.OnTimer3, self);
		UiManager:OpenWindow("UI_INFOBOARD", "<bclr=pink><color=white>开启光速拾取，注意关闭（Ctrl+S）");
		me.Msg("<color=yellow>0.17秒帮你敲下空格键捡东西！<color>")
	else

		self.nquick=0;
		Timer:Close(nTimeOut);
		nTimeOut = 0;
		UiManager:OpenWindow("UI_INFOBOARD", "<bclr=blue><color=white>关闭光速拾取");

	end
end

uiCheckTeacher.OnTimer3 = function(self)

	AutoAi.PickAroundItem(Space);

end

