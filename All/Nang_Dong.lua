local tbNangDong = Ui:GetClass("tbNangDong");
tbNangDong.state = 0
local Dem = 0
--local n = 0
local Timer =  Env.GAME_FPS * 0.5
local uiSayPanel = Ui(Ui.UI_SAYPANEL)
tbNangDong.Say_bak = tbNangDong.Say_bak or uiSayPanel.OnOpen

function uiSayPanel:OnOpen(tbParam)
	tbNangDong.Say_bak(uiSayPanel,tbParam)
	if tbNangDong.state == 0 then 
		return 
	end
		for i = 1,table.getn(tbParam[2]) do
			if string.find(tbParam[2][i],"<color=yellow>Nhận phần thưởng 90 điểm năng động")
				or string.find(tbParam[2][i],"<color=yellow>Nhận phần thưởng 120 điểm năng động")
				or string.find(tbParam[2][i],"<color=yellow>Nhận phần thưởng 160 điểm năng động")
				or string.find(tbParam[2][i],"<color=yellow>Nhận phần thưởng 200 điểm năng động")
				or string.find(tbParam[2][i],"<color=yellow>Nhận phần thưởng 235 điểm năng động")
				or string.find(tbParam[2][i],"<color=yellow>Nhận phần thưởng 255 điểm năng động")
				or string.find(tbParam[2][i],"<color=yellow>Nhận phần thưởng 280 điểm năng động") then
				me.Msg(tostring(""..tbParam[2][i]))	
				me.AnswerQestion(i-1)
				me.AnswerQestion(0)
				break
			end	
		end
	
end

function tbNangDong:State()
	if tbNangDong.state == 0 then
		UiManager:OpenWindow("UI_INFOBOARD", "<bclr=Black><color=Yellow>Bắt đầu nhận điểm năng động<color>");
		Timer = Ui.tbLogic.tbTimer:Register(Env.GAME_FPS * 0.5,tbNangDong.OnTimer);
		tbNangDong.state = 1
		
	else
		UiManager:OpenWindow("UI_INFOBOARD", "<bclr=Black><color=Red>Stop<color>");
		tbNangDong.state = 0
		Ui.tbLogic.tbTimer:Close(Timer)
		Timer = 0
	end
end

function tbNangDong.OnTimer()	
	if Dem == 7 then
		UiManager:CloseWindow(Ui.UI_SAYPANEL)
		Dem = 0 tbNangDong:State()
	else	
		me.CallServerScript({"GetVnGuiYuanAward"})
		Dem = Dem + 1
	end	

end

Ui:RegisterNewUiWindow("UI_tbNangDong", "tbNangDong", {"a", 250, 150}, {"b", 250, 150}, {"c", 250, 150});
--local tCmd={"Ui(Ui.UI_tbNangDong):State()", "tbNangDong", "", "Shift+F12", "Shift+F12", "Gánh nước"};
--	AddCommand(tCmd[4], tCmd[3], tCmd[2], tCmd[7] or UiShortcutAlias.emKSTATE_INGAME);
--	UiShortcutAlias:AddAlias(tCmd[2], tCmd[1]);
