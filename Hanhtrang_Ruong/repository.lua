local tbRepository = Ui(Ui.UI_REPOSITORY);
local BTN_SORTITEM      = "BtnSortItem";
local BTN_SHEZHI = "BtnShezhi"
local OnButtonClick_Bk = tbRepository.OnButtonClick

function tbRepository:OnButtonClick(szWnd, nParam)
	if (szWnd == BTN_SORTITEM) then
		Player:ItemSort_SortRepository()
	else
		OnButtonClick_Bk(self, szWnd, nParam)
    end
	if (szWnd == BTN_SHEZHI) then
        tbRepository.ScrReload();
	end
end

function tbRepository:ScrReload()
	local function fnDoScript(szFilePath)
		local szFileData	= KFile.ReadTxtFile(szFilePath);
		assert(loadstring(szFileData, szFilePath))();
	end
	fnDoScript("\\interface2\\Hanhtrang_Ruong\\repository.lua");
	me.Msg("<color=yellow>Tự động tải lại ... OK! ");
	UiManager:CloseWindow(Ui.UI_REPOSITORY);
end
