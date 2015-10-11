local self = tbSmall;
local tbSmall	= Map.tbSmall or {};
Map.tbSmall	= tbSmall;

Require("\\interface2\\btssl_autofight\\script\\window\\autofight_setting.lua");
Require("\\interface2\\All\\callback.lua");
Require("\\interface2\\smalldragon\\auto_vhc.lua");
--Require("\\interface2\\smalldragon\\auto_bigdesert.lua");


local nIsQuitBMS = 0;
local nIsTransferred = 0;
local nGlobalCount = 7;
local nHLVMTimerId = 0; -- for quit hlvm function
local nBMSTimerId = 0;
local nQuickTransferTimerId = 0; -- for quick transfer

local tbSellItems = {
	[1] = {22,1,112,1},
	[2] = {22,1,112,2},
	[3] = {22,1,112,3},
	[4] = {22,1,113,1},
	[5] = {22,1,113,2},
	[6] = {22,1,113,3},
	[7] = {22,1,114,1},
	[8] = {22,1,114,2},
	[9] = {22,1,114,3}
};
-----------------end variable decleration-------------------------------------------------------------------


function tbSmall:Reload()
    local function fnDoScript(szFilePath, szFileName)
        local szFileData  = KFile.ReadTxtFile(szFilePath);
        assert(loadstring(szFileData, szFilePath))();
        me.Msg("<bclr=255,100,0><color=white><bclr><color><bclr=pink><color=white> ".. GetLocalDate("%d-%m-%Y %H:%M:%S") .." <bclr><color> "..szFileName.." reload: <bclr=255,100,0><color=white> Ok !");
	end
    fnDoScript("\\interface2\\smalldragon\\smalldragon.lua","smalldragon.lua");
    fnDoScript("\\interface2\\Kato\\KhongTuoc.lua","KhongTuoc.lua");
    fnDoScript("\\interface2\\supermaplink\\supermaplink.lua","supermaplink.lua");
    fnDoScript("\\interface2\\AutoThief\\AutoThief.lua","AutoThief.lua");
	fnDoScript("\\interface2\\TeamControl\\banrac.lua","banrac.lua");
	fnDoScript("\\interface2\\smalldragon\\auto_vhc.lua","auto_vhc.lua");
	fnDoScript("\\interface2\\smalldragon\\Ultity.lua","Ultity.lua");
	--fnDoScript("\\interface2\\TeamControl\\AutoChiLing.lua","AutoChiLing.lua");
end

function tbSmall:Init()
    local uiMsgPad =Ui(Ui.UI_MSGPAD)
    tbSmall.Say_bak	= tbSmall.Say_bak or Ui(Ui.UI_MSGPAD).OnSendMsgToChannel;
    function uiMsgPad:OnSendMsgToChannel(szChannelName, szName, szMsg, szGateway)
        tbSmall.Say_bak(Ui(Ui.UI_MSGPAD), szChannelName, szName, szMsg, szGateway);
        local function fnOnSay()
            tbSmall:OnSay(szChannelName, szName, szMsg, szGateway);
            return 0;
        end
        Timer:Register(1, fnOnSay);
    end
end
function tbSmall:OnSay(szChannelName, szName, szMsg, szGateway)
    if szChannelName=="Team" then
        if (szMsg == "atk") then
            tbSmall:StartKnockback();
        elseif (szMsg == "smreload") then
            tbSmall:Reload();
        elseif (szMsg == "ridehorse") then
            tbSmall:RideHorse();
        elseif (szMsg == "walk") then
            tbSmall:Walk();
        elseif (szMsg == "returncity") then
            tbSmall:ReturnCity();
        elseif (szMsg == "quithl") then
            tbSmall:QuitHLVM();
		elseif (szMsg == "quitbms") then 
			tbSmall:InitQuitBMS();
		elseif (szMsg == "hspnrowing") then 
			tbSmall:HspnRowing();
		elseif (szMsg == "quithspn") then 
			tbSmall:HspnQuit();
		elseif (szMsg == "movelmpk") then 
			tbSmall:TransferLMPK();
		elseif (szMsg == "movettt1") then 
			tbSmall:MoveTTT();
		elseif (szMsg == "qdt1") then 
			tbSmall:Camp_Floor(1);
		elseif (szMsg == "qdt2") then 
			tbSmall:Camp_Floor(2);
		elseif (szMsg == "qdt3") then 
			tbSmall:Camp_Floor(3);
		elseif (szMsg == "openward") then 
			tbSmall:OpenTreasure();
		elseif (szMsg == "outqd") then 
			tbSmall:OutFuben();
		elseif (szMsg == "picktst") then 
			tbSmall:PickTST();	
		elseif (szMsg == "autovhc") then
			if szName == me.GetNpc().szName then
				Map.AutoVHC:Start();
			end
		elseif (szMsg == "stopvhc") then 
			Map.AutoVHC:Stop();
		elseif (szMsg == "selldragonsoul") then 
			tbSmall:SellDragonSoul();
		elseif (szMsg == "autobigdesert") then 
			--Map.AutoBigDesert:Start();
		elseif (szMsg == "stopbigdesert") then 
			--Map.AutoBigDesert:Stop();
		elseif (szMsg == "gooutbms") then 			
			tbSmall:GoOutBms();	
		elseif (szMsg == "bmstransport") then 			
			tbSmall:BmsTransport()
		elseif (szMsg == "test1") then 			
			Map.SMUltity:PrintCurrentWorldPos();	
		elseif (szMsg == "test2") then
			tbSmall:test1();
		elseif (szMsg == "test3") then
			local tbFind = me.FindItemInBags(unpack({18,1,1016,1}));
			for _, tbItem in pairs(tbFind) do 
				me.UseItem(tbItem.pItem);
				return;
			end
		elseif (szMsg == "test4") then
			local n = me.GetItemCountInBags(18,1,1016,1);
			if n > 0 then 
				me.Msg(KItem.GetNameById(18,1,1016,1));
			end
		end
    end
end

--*** test
local t1timerid = 0;
local arg = "argument";
function tbSmall:test1()
	if t1timerid == 0 then 
		t1timerid = Ui.tbLogic.tbTimer:Register(Env.GAME_FPS,arg,tbSmall.test1_ontimer);
	else
		Ui.tbLogic.tbTimer:Close(t1timerid);
		t1timerid = 0;
	end
end
function tbSmall:test1_ontimer(arg)
	SendChannelMsg("Team",""..arg..t1timerid.." "..GetLocalDate("%H:%M:%S"));
end

function tbSmall:Test()
	local tbNpcs = KNpc.GetAroundNpcList(me, 500);
	for _, npc in pairs(tbNpcs) do 
		if string.find(npc.szName,"Lộ Lộ Thông") then
			AutoAi.SetTargetIndex(npc.nIndex);
			if UiManager:WindowVisible(Ui.UI_SAYPANEL) == 1 then 
				local ques, tbAnswers = UiCallback:GetQuestionAndAnswer();
				for i, tbInfo in ipairs(tbAnswers) do
					me.Msg(tbInfo);
					if string.find(tbInfo, "Đăng Kỳ Mê Trận") then
						me.AnswerQestion(i-1);
					end
				end	
			end
		end
	end
end
--- end test
-- go out bms / transer bms
function tbSmall:GoOutBms()
	me.StartAutoPath(213*8, 194*16);
end
function tbSmall:BmsTransport()
	local tbNpcs = KNpc.GetAroundNpcList(me, 500);
	for _, npc in pairs(tbNpcs) do 
		if string.find(npc.szName,"Lộ Lộ Thông") then
			AutoAi.SetTargetIndex(npc.nIndex);
			if UiManager:WindowVisible(Ui.UI_SAYPANEL) == 1 then 
				local ques, tbAnswers = UiCallback:GetQuestionAndAnswer();
				for i, tbInfo in ipairs(tbAnswers) do
					me.Msg(tbInfo);
					if string.find(tbInfo, "Thiên Tuyệt Phong") then
						me.AnswerQestion(i-1);
					end
				end	
			end
		end
	end
end
-- sell long hồn giám
function tbSmall:SellDragonSoul()
	local nId = me.CallServerScript({"ApplyKinSalaryOpenShop", 241}); 
	if nId then
		if (UiManager:WindowVisible(SALA_SILVERSHOP) ~= 1) then
			if (UiManager:WindowVisible(Ui.UI_SAYPANEL) ~= 1) then
				AutoAi.SetTargetIndex(nId)				
			for i,tbFitem in pairs(tbSellItems) do
				local tbFind = me.FindItemInBags(unpack(tbFitem));
				for j, tbItem in pairs(tbFind) do
					local num = me.GetItemCountInBags(tbFitem[1],tbFitem[2],tbFitem[3],tbFitem[4]);
						me.ShopSellItem(tbItem.pItem, num);
						SendChannelMsg("Nearby","<color=yellow>Đã bán: "..num.." "..KItem.GetNameById(tbItem[1],tbItem[2],tbItem[3],tbItem[4]));
					end
				end
		    end	 
	    end
		if (UiManager:WindowVisible(Ui.UI_SAYPANEL) ~= 1) then
			UiManager:CloseWindow(Ui.UI_SAYPANEL);
		end
    end
end
-- *** nhặt trường sinh thảo
function tbSmall:PickTST()
	local tbAroundNpc = KNpc.GetAroundNpcList(me, 30);
	for _,npc in pairs(tbAroundNpc) do 
		if (npc.szName == "Trường Sinh Thảo") then 
			AutoAi.SetTargetIndex(npc.nIndex);
			break;
		end
	end
end
-- end

-- go out phó bản
function tbSmall:OutFuben()
	local tbAroundNpc = KNpc.GetAroundNpcList(me, 500);
	for _,npc in pairs(tbAroundNpc) do 
		if (npc.szName == "Truyền Tống Quân Doanh") then 
			AutoAi.SetTargetIndex(npc.nIndex);
			me.AnswerQestion(0);
			break;
		end
	end
end
-- end go out phó bản

-- open treasure
function tbSmall:OpenTreasure()
	local tbAroundNpc = KNpc.GetAroundNpcList(me, 500);
	for _,npc in pairs(tbAroundNpc) do 
		if (npc.szName == "Bảo rương") then 
			AutoAi.SetTargetIndex(npc.nIndex);
			break;
		end
	end
end
-- end open treasure

-- ** transfer LMPK
function tbSmall:TransferLMPK()
	local tbAroundNpc = KNpc.GetAroundNpcList(me, 100);
	for _,npc in pairs(tbAroundNpc) do 
		if (npc.szName == "Điểm truyền tống") then 
			AutoAi.SetTargetIndex(npc.nIndex);
			me.AnswerQestion(0);
			break;
		end
	end
end
-- ** end transfer LMPK

-- ** transfer TTT
function tbSmall:MoveTTT()
	UiManager:OpenWindow("UI_INFOBOARD", "<bclr=Black><color=Red>Begin moving ... <color>");
	me.StartAutoPath(186*8, 186*16);
end
-- ** end transfer TTT


-- ** transfer LMPK
function tbSmall:Camp_Floor(nfloor)
	local tbAroundNpc = KNpc.GetAroundNpcList(me, 600);
	for _,npc in pairs(tbAroundNpc) do 
		if (npc.szName == "Lộ Lộ Thông") then 
			AutoAi.SetTargetIndex(npc.nIndex);
			me.AnswerQestion(nfloor - 1);
			break;
		end
	end
end
-- ** end transfer LMPK


-- *** quit HLVM function
function tbSmall:QuitHLVM()
    if me.GetMapTemplateId() > 65000 then
        UiManager:OpenWindow("UI_INFOBOARD", "<bclr=Black><color=Red>Begin quit HLVM <color>");
	end
end

function tbSmall:FinishAutoPath()
end
-- end quit HLVM function

-- *** quit bms function
function tbSmall:InitQuitBMS() -- initialize - monitoring
   if nIsQuitBMS == 0 and nBMSTimerId == 0 then
       nIsQuitBMS = 1;
	   UiManager:OpenWindow("UI_INFOBOARD", "<bclr=pink><color=Yellow>Begin quit BMS<color>");
       SendChannelMsg("Team", "Start quit BMS");
       nBMSTimerId = Ui.tbLogic.tbTimer:Register(1 * Env.GAME_FPS,self.QuitBMS,self);
	end
end
function tbSmall:QuitBMS()
    if me.GetMapTemplateId() > 65000 then
        UiManager:OpenWindow("UI_INFOBOARD", "<bclr=Black><color=Yellow>Begin quit BMS <color>");
		me.StartAutoPath(229*8, 177*16);
		local tbAroundNpc = KNpc.GetAroundNpcList(me, 100);
		for _,npc in pairs(tbAroundNpc) do 
			me.Msg(npc.szName);
			if (npc.szName == "Nhị A") then 
				AutoAi.SetTargetIndex(npc.nIndex);
				me.AnswerQestion(0);
			end
		end
    else
		UiManager:OpenWindow("UI_INFOBOARD", "<bclr=black><color=white>Stop quit BMS<color>");
		SendChannelMsg("Team", "Stop quit BMS");
		Ui.tbLogic.tbTimer:Close(nBMSTimerId);
		nIsQuitBMS = 1;
		nBMSTimerId = 0;
	end
end
-- end quit bms function

-- *** transfer HSPN
function tbSmall:HspnRowing()
	local tbAroundNpc = KNpc.GetAroundNpcList(me, 400);
	for _,npc in pairs(tbAroundNpc) do 
		me.Msg(npc.szName);
		if (npc.szName == "Thuyền cũ") then 
			me.Msg(npc.nIndex);
			AutoAi.SetTargetIndex(npc.nIndex);
			me.AnswerQestion(0);
		end
	end
end
function tbSmall:HspnQuit()
	if me.GetMapTemplateId() > 65000 then 
	local tbAroundNpc = KNpc.GetAroundNpcList(me, 400);
		for _,npc in pairs(tbAroundNpc) do 
			me.Msg(npc.szName);
			if (npc.szName == "Thuyền Phu") then 
				AutoAi.SetTargetIndex(npc.nIndex);
				if UiManager:WindowVisible(Ui.UI_SAYPANEL) == 1 then
					me.AnswerQestion(0);
					break;
				end
			end
		end
	end
end
-- end transfer HSPN

function tbSmall:ReturnCity()
    me.SendClientCmdRevive(0);
end
function tbSmall:RideHorse()
    if me.GetNpc().IsRideHorse() == 0 then
        Switch("horse");
    end
end
function tbSmall:Walk()
    if me.GetNpc().IsRideHorse() == 1 then
        Switch("horse");
    end
end
function tbSmall:StartKnockback() -- open knock back
    UiManager:OpenWindow("UI_INFOBOARD", "<bclr=Blue><color=white>Open knock back...");
    local tbAroundNpc = KNpc.GetAroundNpcList(me, 500);
	local nMapId, _, __ = me.GetWorldPos();
    for _, npc in pairs(tbAroundNpc) do
        local nCanAttack = AutoAi.AiTargetCanAttack(npc.nIndex);
        if (nCanAttack == 1) then
            UiManager:OpenWindow("UI_INFOBOARD","<bclr=yellow>Begin attack: "..npc.szName);
			AutoAi.SetTargetIndex(npc.nIndex);
			me.Msg(""..npc.nTemplateId);
			me.AddSkillEffect(me.nLeftSkill);
			--me.CastSkill(me.nLeftSkill, 1, )
			
			local nX, nY = KNpc.ClientGetNpcPos(nMapId, npc.nTemplateId);
            break;
        end
    end
end

tbSmall:Init();
