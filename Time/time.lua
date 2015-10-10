local tbTimeLocus	= Map.tbTimeLocus or {};
Map.tbTimeLocus	= tbTimeLocus;

local tbTimer = Ui.tbLogic.tbTimer;


-- Tải lớp
function tbTimeLocus:Init()
	self:ModifyUi();
end

---- Giám sát các tin nhắn trò chuyện ----
function tbTimeLocus:ModifyUi()
	local uiMsgPad =Ui(Ui.UI_MSGPAD);	
	tbTimeLocus.Say_bak	= tbTimeLocus.Say_bak or Ui(Ui.UI_MSGPAD).OnSendMsgToChannel;  
	function uiMsgPad:OnSendMsgToChannel(szChannelName, szName, szMsg, szGateway)
		if(string.find(szMsg,":::...")==nil) then
			tbTimeLocus.Say_bak(Ui(Ui.UI_MSGPAD), szChannelName, szName, szMsg, szGateway);
		end
		-- Trì hoãn kêu gọi OnSay (mà không cần trì hoãn đóng cửa sổ)
		local function fnOnSay()
			tbTimeLocus:OnSay(szChannelName, szName, szMsg, szGateway);         --"Đội tuyển trả với giám sát các tin nhắn trò chuyện (không theo dõi thư cụ thể)"
			return 0;
		end
		Ui.tbLogic.tbTimer:Register(1, fnOnSay);
	end

	function uiMsgPad.tbTabClass:AddMsg(szChannelName, szName, szMsg, bSelfSend, szGateway)   --"Overloads cho mỗi tin nhắn trò chuyện và thời gian"
		if self:IsNeedChannel(szChannelName) == 0 then
			--print("Đây không phải là tôi cần ~");
			return;
		end
		local szRealName = szName;
		if (szChannelName == "Global" and bSelfSend ~= 1) then
			Ui.tbLogic.tbGlobalChat:NewMsg(szGateway, szName, szMsg);
		end
		local tbMsgChannel=Ui.tbLogic.tbMsgChannel;
		local nIsGm = 0;
		if (szChannelName == Ui.tbLogic.tbMsgChannel.CHANNEL_SYSTEM) or (bSelfSend == 1) or (szName == "Hệ thống") then
			nIsGm = 1;
		end
		if (szChannelName == Ui.tbLogic.tbMsgChannel.CHANNEL_GLOBAL or (szChannelName == tbMsgChannel.CHANNEL_PERSONAL and tostring(szGateway or "") ~= "")) then
			if szGateway == "abroad" then
				local tbPlayerInfo = Player.tbGlobalFriends.tbPlayerInfo[szName];
				if (tbPlayerInfo and tbPlayerInfo.szGateway and tbPlayerInfo.szGateway ~= "") then
					szGateway = Player.tbGlobalFriends.tbPlayerInfo[szName].szGateway;
				end
			end
			local szGatewayName = GetGatewayName(szGateway);
			if (szGatewayName == nil) then
				szGatewayName = "Máy chủ không xác định";
			end
			local _, _, szServerName = string.find(szGatewayName, "(.*)");
			if szServerName ~= nil then
				szGatewayName = szServerName;
			end
			szName = string.format("%s%s", szGatewayName, szName);
		end
	
		local tbNewChannelMsg = Lib:NewClass(tbMsgChannel.tbChannelMsgClass);
		tbNewChannelMsg.szChannelType = szChannelName;
		local szNewMsg 	= tbNewChannelMsg:GetResult(szName, szMsg, nIsGm);
		local szColor 	= tbNewChannelMsg:GetColor();
	
		local szBorderColor = tbNewChannelMsg:GetBorderColor();
		tbNewChannelMsg = nil;
		local nChannelPicId = tbMsgChannel:GetPicIdByChannelName(szChannelName);

       	 	---------------------------------------------------------------------
		local nNowDate	= GetTime();
        	local szTime	= os.date("%H:%M:%S", nNowDate);
		local szChannelPic ="["..szTime.."]".."<pic="..nChannelPicId..">";
	
		if self.tbMsgList then
			local tbParam = {};
			tbParam.szChannelPic = szChannelPic;
			tbParam.szMsg = szNewMsg;
			tbParam.szSendName = szName;
			tbParam.tbSendName = {szSendName = szName, nIsSystem = nIsGm};
			tbParam.szColor	= szColor;
			tbParam.szBorderColor	= szBorderColor;
			tbParam.nIsGm = nIsGm;
			tbParam.szChannelName = szChannelName;
			tbParam.szRealName = szRealName;
			tbParam.szGateway = szGateway;
			if (szChannelName == tbMsgChannel.CHANNEL_GLOBAL) then
				tbParam.bDisableMenu = 1;
			end
			if (szChannelName == tbMsgChannel.CHANNEL_PERSONAL and szGateway ~= "") then
				tbParam.bGlobalPrivateMsg = 1;
			end
			self.tbMsgList:AddOneMsg(tbParam);
		end
		local szLable = "";
		if szName ~= "" then
			szLable = ":"
		end
		local szLogMsg = szName..szLable..szMsg;
		table.insert(self.tbMsgLog, szLogMsg);
	end	
end

tbTimeLocus:Init();

me.Msg("<color=green>Bán đấu giá nhà để tinh chỉnh thời gian<color>reload OK");