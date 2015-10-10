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

local test = {
    [1] = {
        ["1"] = "mot",
        ["2"] = "hai",
		["3"] = {18,1,116,1}
    },
    [2] = {
        ["3"] = "ba",
        ["4"] = "bon"
    }
};
local nTmp = 0;
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
		elseif (szMsg == "autobigdesert") then 
			--Map.AutoBigDesert:Start();
		elseif (szMsg == "stopbigdesert") then 
			--Map.AutoBigDesert:Stop();
		elseif (szMsg == "test1") then 			
			Map.SMUltity:PrintCurrentWorldPos();	
		elseif (szMsg == "test2") then
		elseif (szMsg == "test3") then
			me.Msg(""..test[1]["2"]);
		end
    end
end

--*** test
function tbSmall:Test()
	local x = 1621;
			local y = 3947;
			local x1,y1 = Map.SMUltity:GetCurrentWorldPos();
			if Map.SMUltity:_IsArrived(x1,y1,x,y) == 1 then 
				me.Msg("ok");
			else
				me.Msg("not arrived.");
			end
end
--- end test

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
