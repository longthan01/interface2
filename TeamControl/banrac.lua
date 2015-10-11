-- ====================== quochuy ======================

--local tbbanrac	= UiManager
local tbTimer = Ui.tbLogic.tbTimer;
local tbbanrac	= Map.tbbanrac or {};
Map.tbbanrac		= tbbanrac;

local self = tbbanrac

self.nbanracClock = 0; 
local nbanracState = 0;
local nbanracPutFlg = 0;

local Sundry = {
	[1] = {18,1,1,1},       --huyền tinh 1
	[2] = {18,1,1,2},       --huyền tinh 2
	[3] = {18,1,1,3},       --huyền tinh 3
	[4] = {18,1,1,4},	    --huyền tinh 4	
	[5] = {18,1,1,5},       --huyền tinh 5
	[6] = {18,1,1,6},       --huyền tinh 6
	[7] = {18,1,114,1},	    --huyền tinh 1	
	[8] = {18,1,114,2},	    --huyền tinh 2	
	[9] = {18,1,114,3},	    --huyền tinh 3	
	[10] = {18,1,114,4},    --huyền tinh 4	
	[11] = {18,1,114,5},    --huyền tinh 5
	-- [12] = {18,1,114,6},    --huyền tinh 6
	--[13] = {18,1,20310,1},  --kim long bảo châu
	[14] = {18,1,20307,1},	--- mảnh kim long ngọc
   -- [15] = {18,1,1314,1},   --Khoáng thạch Nhân Dũng Hoàng Lăng
   -- [16] = {18,1,1313,1},   --Khoáng thạch Tinh Anh Hiệp Dũng	
   -- [17] = {18,1,1316,1},   --Khoáng thạch tiêu dao kì bảo
	[18] = {18,1,1452,1},   --Lam Điền Ngọc
	[19] = {18,1,1452,10},  --Lam Điền Khoáng chưa chạm trổ
	[20] = {18,1,1235,1},   --Vật Báu Lâu Lan-Bích Ngọc (Cấp 1)
    [21] = {18,1,1236,1},   --Vật Báu Lâu Lan-Nhã Từ (Cấp 1)
    [22] = {18,1,1235,2},   --Vật Báu Lâu Lan-Linh Tinh (Cấp 2)
    [23] = {18,1,1236,2},   --Vật Báu Lâu Lan-Bạch Ngọc (Cấp 2)
   -- [24] = {18,1,1235,3},   --Vật Báu Lâu Lan-Minh Châu (Cấp 3)
   -- [25] = {18,1,1236,3},   --Vật Báu Lâu Lan-Lưu Ly (Cấp 3)
	--[26] = {18,1,252,1},    --Rương tranh đoạt lãnh thổ
	[27] = {22,1,41,1},     --Tử Tinh Nguyên Thạch
    [28] = {22,1,35,1},     --Tiên Linh Nguyên Mộc
    [29] = {22,1,43,1},     --Tiên Linh Quả
    [30] = {22,1,39,1},     --Linh Thú Huyết
    [31] = {22,1,37,1},     --Da lông Linh Thú
	--[32] = {18,1,290,3},     --Rương vàng bị khóa
	--[33] = {18,1,20504,1},	--Vé Đổi Điểm Năng Động	
	[34] = {22,1,11,10}, --Bạch long tu [hoạt khí cấp 10]
	[35] = {22,1,9,10}, --Tuyết liên [bổ huyết cấp 10]	
	[36] = {22,1,69,1}, --Quả thu hoạch	
	[37] = {18,1,1997,1}, --báu vật lâu lan bình
	[38] = {18,1,114,7},  --ht7
	[39] = {18,1,20449,1},	--rưong càn khôn
	[40] = {18,1,20415,1},	-- đảo thiên tư kinh nghiệm đơn
	[41] = {18,1,1974,1},	-- thần nguyệt sa
	[42] = {18,1,1974,2},	-- thần nhật sa
	[43] = {18,1,252,1},	-- rương tranh đoạt lãnh thổ
	[44] = {18,1,20444,1},	-- quang vũ tinh hoa
	[45] = {18,1,20763,1} 	-- kĩ năng tàn quyển
};

local tCmd={ "Map.tbbanrac:banrac()", "banrac", "", "Shift+C", "Shift+C", "Bán Rác"};
	AddCommand(tCmd[4], tCmd[3], tCmd[2], tCmd[7] or UiShortcutAlias.emKSTATE_INGAME);
	UiShortcutAlias:AddAlias(tCmd[2], tCmd[1]);	
local szCmd = [=[
	Map.tbbanrac:banrac();
]=];
function tbbanrac:banrac()
	if self.nbanracClock == 0 then
		nbanracPutFlg = 0;
		self:GetbanracState();
		UiManager:OpenWindow("UI_INFOBOARD", "<bclr=pink><color=white>Bật Tự động bán rác<color>");
		self.nbanracClock = tbTimer:Register(Env.GAME_FPS, self.banracTime, self);
	else
		tbTimer:Close(self.nbanracClock);
		self.nbanracClock = 0;
		UiManager:OpenWindow("UI_INFOBOARD", "<bclr=blue><color=white>Tắt Tự động bán rác<color>");
	end
end

function tbbanrac:GetbanracState()
	local ncount1 = 0;
	for i,tbFitem in pairs(Sundry) do
		ncount1 = ncount1 + me.GetItemCountInBags(tbFitem[1],tbFitem[2],tbFitem[3],tbFitem[4]);
	end
	if ncount1 > 0 then
		nbanracState = 1;
		return;
	end
	nbanracState = 0;
end

function tbbanrac:banracTime()
	if UiManager:WindowVisible(Ui.UI_SKILLPROGRESS) == 1 then
		return;
	end	
	if nbanracState == 0 then
		self:banrac();
	elseif nbanracState >= 99 then 
		if UiManager:WindowVisible(Ui.UI_SHOP) == 1 then
			UiManager:CloseWindow(Ui.UI_SHOP);
			UiManager:CloseWindow(Ui.UI_ITEMBOX);			
		end	
		self:GetbanracState();
	elseif nbanracState == 1 then 
		self:banracSellItem();		
	end
end

function tbbanrac:banracSellItem()
	local nId = me.CallServerScript({"ApplyKinSalaryOpenShop", 241}); 
	if nId then
		if (UiManager:WindowVisible(SALA_SILVERSHOP) ~= 1) then
			if (UiManager:WindowVisible(Ui.UI_SAYPANEL) ~= 1) then
				AutoAi.SetTargetIndex(nId)				
			for i,tbFitem in pairs(Sundry) do
				local tbFind = me.FindItemInBags(unpack(tbFitem));
				for j, tbItem in pairs(tbFind) do
					local num = me.GetItemCountInBags(tbFitem[1],tbFitem[2],tbFitem[3],tbFitem[4]);
						me.ShopSellItem(tbItem.pItem, num);
						--me.Msg("ádf");
						--SendChannelMsg("GM","<color=yellow>Đã bán: "..KItem.GetNameById(tbItem[1],tbItem[2],tbItem[3],tbItem[4]));
					return;
				end
			end
			nbanracState = 99;
		    end	 
	    end
    end
end
