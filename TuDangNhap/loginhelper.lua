--cyberdemon--
Ui.UI_LOGINHELPER		= "UI_LOGINHELPER";
local uiLoginHelper		= Ui.tbWnd[Ui.UI_LOGINHELPER] or {};
uiLoginHelper.UIGROUP	= Ui.UI_LOGINHELPER;
Ui.tbWnd[Ui.UI_LOGINHELPER] = uiLoginHelper;
local uiAccountLogin 	= Ui(Ui.UI_ACCOUNT_LOGIN);
local uiSelAndNewRole 	= Ui(Ui.UI_SELANDNEW_ROLE);
local MY_DIR = "\\interface2\\tudangnhap\\";
local DATA_FILE = "\\user\\login.dat";
uiLoginHelper.LIST_NAME			= "ListName";
uiLoginHelper.CURRENT_LIST_TEXT	= "TxtCurList";
uiLoginHelper.BTN_PRE_PAGE		= "BtnLeft";
uiLoginHelper.BTN_NEXT_PAGE		= "BtnRight";
uiLoginHelper.TEXT_CUR_PAGE		= "TxtPage";
uiLoginHelper.BUTTON_RECORD		= "BtnRecord";
uiLoginHelper.NUMBER_PER_PAGE	= 20;

function uiLoginHelper:OnOpen()
	self.nListCurPage = 1;
	self.szCurRoleName = nil;
	self.szCurAccount = nil;
	Btn_Check(self.UIGROUP, self.BUTTON_RECORD, 1);
	self:UpdatePanel();
end

function uiLoginHelper:UpdatePanel()
	self:LoadData();
	Txt_SetTxt(self.UIGROUP, self.CURRENT_LIST_TEXT, "Có: ".. #self.tbAccountList .." nhân vật");
	
	self:ClearList();
	
	local nMaxPage = math.ceil(#self.tbAccountList / self.NUMBER_PER_PAGE);
	if (self.nListCurPage < 1) then
		self.nListCurPage = 1;
	elseif (self.nListCurPage > nMaxPage) then
		self.nListCurPage = nMaxPage;
	end
	
	Txt_SetTxt(self.UIGROUP, self.TEXT_CUR_PAGE, tostring(self.nListCurPage));

	for i = 1, self.NUMBER_PER_PAGE do
		local nIndex = (self.nListCurPage - 1) * self.NUMBER_PER_PAGE + i;
		local tbAccount = self.tbAccountList[nIndex];
		if (not tbAccount) then
			break;
		end
		local nColor = tbAccount.nLevel + 100;
		if (nColor > 255) then
			nColor = 255;
		end
		local szBuffer = string.format("<color=0x%06x>%s",
			nColor * 65536 + nColor * 256 + 255 - nColor, tbAccount.szRolename);
		Lst_SetCell(self.UIGROUP, self.LIST_NAME, i, 0, szBuffer);
		Lst_SetLineData(self.UIGROUP, self.LIST_NAME, i, nIndex);
	end
end

function uiLoginHelper:ClearList()
	Lst_Clear(self.UIGROUP, self.LIST_NAME);
	for i = 1, self.NUMBER_PER_PAGE do
		Wnd_Hide(self.UIGROUP, string.format("Sns_%02d", i));
	end
end

function uiLoginHelper:OnButtonClick(szWnd, nParam)
	if szWnd == self.BTN_PRE_PAGE then
		self.nListCurPage = self.nListCurPage - 1;
		self:UpdatePanel();
	elseif szWnd == self.BTN_NEXT_PAGE then
		self.nListCurPage = self.nListCurPage + 1;
		self:UpdatePanel();
	elseif szWnd == self.BUTTON_RECORD then
		local n = Btn_GetCheck(self.UIGROUP, self.BUTTON_RECORD);
		Btn_Check(self.UIGROUP, self.BUTTON_RECORD, n);
	elseif (string.sub(szWnd, 1, 4) == "Sns_") then
		local nKey = tonumber(string.sub(szWnd, 5));
		local nIndex = (self.nListCurPage - 1) * self.NUMBER_PER_PAGE + nKey;
		print("SNS", nIndex);
	end
end

-- Tip
function uiLoginHelper:OnListOver(szWnd, nListItem)
	if szWnd == self.LIST_NAME and nListItem > 0 then
		local tbAccount = self:GetItemAccount(nListItem);
		local szName = string.format("Tên: <color=yellow>%s<color>", tbAccount.szRolename);
		local szTip = string.format("Server: %s\nTài Khoản: %s\nLevel: %d\nGiới tính: %s\nMôn Phái: %s\n",
			tbAccount.szServer, tbAccount.szAccount, tbAccount.nLevel,
			Env.SEX_NAME[tbAccount.nSex], Player.tbFactions[tbAccount.nFaction].szName);
		local szPath = GetPortraitSpr(math.mod(tbAccount.nFaction - 1, 4) + 1, tbAccount.nSex);
		Wnd_ShowMouseHoverInfo(self.UIGROUP, szWnd, szName, szTip, szPath);
	end
end

function uiLoginHelper:OnListDClick(szWnd, nListItem)
	local tbAccount = self:GetItemAccount(nListItem);
	self.szCurRoleName = tbAccount.szRolename;
	uiAccountLogin:Login();
end

function uiLoginHelper:OnListSel(szWnd, nListItem)
	local tbAccount = self:GetItemAccount(nListItem);
	SetLastSvrTitle(tbAccount.szServer)
	uiAccountLogin:UpdateSelSvr();
	Edt_SetTxt(uiAccountLogin.UIGROUP, uiAccountLogin.EDIT_ACCOUNT, tbAccount.szAccount);
	Edt_SetTxt(uiAccountLogin.UIGROUP, uiAccountLogin.EDIT_PASSWORD, tbAccount.szPassword);
end

function uiLoginHelper:OnListRClick(szWnd, nParam)
	if szWnd and nParam then
		local nCount = Lst_GetLineCount(self.UIGROUP, szWnd);
		if nParam > nCount then
			return;
		end

		Lst_SetCurKey(self.UIGROUP, szWnd, nParam);
		DisplayPopupMenu(
			self.UIGROUP, szWnd, 4, nParam,
			"Đăng nhập", 1,
			"Xóa tài khoản", 2,
			"Đổi mật khẩu", 3,
			"Reload!", 0
		);
	end
end

function uiLoginHelper:OnMenuItemSelected(szWnd, nItemId, nListItem)
	local tbAccount = self:GetItemAccount(nListItem);
	--print("DI", tbAccount.szRolename, nItemId);
	if (nItemId == 0) then
		self:Reload();
	elseif (nItemId == 1) then
		self:OnListSel(szWnd, nListItem);
		self:OnListDClick(szWnd, nListItem);
	elseif (nItemId == 2) then
		local nIndex = Lst_GetLineData(self.UIGROUP, self.LIST_NAME, nListItem);
		table.remove(self.tbAccountList, nIndex);
		self:SaveData();
		self:UpdatePanel();
	elseif (nItemId == 3) then
		self.szCurAccount = tbAccount.szAccount;
		local tbParam = {
			tbTable = uiLoginHelper,
			fnAccept = uiLoginHelper.ChangePassword,
			nMaxLen = 20,
			szTitle = "Nhập mật khẩu mới:",
		};
		UiManager:OpenWindow(Ui.UI_TEXTINPUT, tbParam)
	end
end

function uiLoginHelper:ChangePassword(szPassword)
	if (not szPassword) then
		return;
	end
	self:LoadData();
	for _, tbAccount in pairs(self.tbAccountList) do
		if (tbAccount.szAccount == self.szCurAccount) then
			tbAccount.szPassword = szPassword;
		end
	end
	self:SaveData();
	print("Mật khẩu đã được thay đổi.");
end

function uiLoginHelper:GetItemAccount(nListItem)
	local nIndex = Lst_GetLineData(self.UIGROUP, self.LIST_NAME, nListItem);
	return self.tbAccountList[nIndex];
end

function uiLoginHelper:TryRecordCurAccount(tbRole)
	local szPassword = nil;
	for _, tbAccount in ipairs(uiLoginHelper.tbAccountList) do
		if (tbAccount.szAccount == uiLoginHelper.szCurAccount) then
			if (tbAccount.szRolename == tbRole.Name) then
				print("Same Role.");
				return;
			end
			szPassword = tbAccount.szPassword;
		end
	end
	self.tbCurRole = tbRole;
	if (szPassword) then
		uiLoginHelper:RecordCurAccount(szPassword);
	else
		local tbParam = {
			tbTable = uiLoginHelper,
			fnAccept = uiLoginHelper.RecordCurAccount,
			nMaxLen = 20,
			szTitle = "Nhập lại mật khẩu mới:",
		};
		UiManager:OpenWindow(Ui.UI_TEXTINPUT, tbParam)
	end
end

function uiLoginHelper:RecordCurAccount(szPassword)
	if (not szPassword) then
		return;
	end
	local tbAccount = {
		szAccount = self.szCurAccount,
		szPassword = szPassword,
		szServer = GetLastSvrTitle(),
		szRolename = self.tbCurRole.Name,
		nFaction = self.tbCurRole.Faction,
		nSex = self.tbCurRole.Sex,
		nLevel = self.tbCurRole.Level,
	};
	self:LoadData();
	table.insert(self.tbAccountList, tbAccount);
	self:SaveData();
	print("Role Saved.", tbAccount.szRolename);
end

function uiLoginHelper:LoadData()
	local szData = KIo.ReadTxtFile(DATA_FILE) or "{}";
	self.tbAccountList = Lib:Str2Val(szData);
end

function uiLoginHelper:SaveData()
	local szData = Lib:Val2Str(self.tbAccountList);
	KIo.WriteFile(DATA_FILE, szData);
end

function uiLoginHelper.fnSelRoleOnOpen(tbSelRole)
	print("S!!", uiLoginHelper.szCurRoleName);
	Lib:CallNextHook(tbSelRole);
	local nRoleCount, tbRoleList = GetRoleList();
	for i = 1, nRoleCount do
		local tbRole = tbRoleList[i];
		for _, tbAccount in ipairs(uiLoginHelper.tbAccountList) do
			if (tbAccount.szAccount == uiLoginHelper.szCurAccount and tbAccount.szRolename == tbRole.Name) then
				tbAccount.nFaction = tbRole.Faction;
				tbAccount.nSex = tbRole.Sex;
				tbAccount.nLevel = tbRole.Level;
			end
		end
	end
	if (uiLoginHelper.szCurRoleName) then
		Btn_Check(tbSelRole.UIGROUP, tbSelRole.BTN_PKPROMPT, 1);
		tbSelRole:SelectRole(uiLoginHelper.szCurRoleName);
		tbSelRole:OnConfirmSel();
	end
end

function uiLoginHelper.fnOnConfirmSel(...)
	if (uiLoginHelper.bRecordLogin == 1) then
		local nRoleCount, tbRoleList = GetRoleList();
		local tbRole = nil;
		for i = 1, nRoleCount do
			if (tbRoleList[i].Name == uiSelAndNewRole.szCurRoleName) then
				tbRole = tbRoleList[i];
				break;
			end
		end
		assert(tbRole);
		uiLoginHelper:TryRecordCurAccount(tbRole);
	end
	return Lib:CallNextHook(...);
end

function uiLoginHelper:_Init()
	local function fnAccLoginOnOpen(...)
		UiManager:OpenWindow(self.UIGROUP);
		return Lib:CallNextHook(...);
	end
	local function fnAccLoginOnClose(...)
		UiManager:CloseWindow(self.UIGROUP);
		return Lib:CallNextHook(...);
	end
	local function fnAccLoginOnLogin(...)
		self.szCurAccount = Edt_GetTxt(uiAccountLogin.UIGROUP, uiAccountLogin.EDIT_ACCOUNT);
		self.bRecordLogin = Btn_GetCheck(self.UIGROUP, self.BUTTON_RECORD);
		return Lib:CallNextHook(...);
	end
	local function fnOnCreateRole(szName, nSex, nCity)
		print("CreateRole", szName, nSex, nCity)
		local tbRole = {
			Name = szName,
			Faction = 0,
			Sex = nSex,
			Level = 1,
		};
		self:TryRecordCurAccount(tbRole);
		return Lib:CallNextHook(szName, nSex, nCity);
	end
	Lib:HookFunc(uiAccountLogin, "OnOpen", fnAccLoginOnOpen, "uiLoginHelper");
	Lib:HookFunc(uiAccountLogin, "OnClose", fnAccLoginOnClose, "uiLoginHelper");
	Lib:HookFunc(uiAccountLogin, "Login", fnAccLoginOnLogin, "uiLoginHelper");
	Lib:HookFunc(uiSelAndNewRole, "UpdateSelSvr", self.fnSelRoleOnOpen, "uiLoginHelper");
	Lib:HookFunc(uiSelAndNewRole, "OnConfirmSel", self.fnOnConfirmSel, "uiLoginHelper");
	Lib:HookFunc(_G, "CreateRole", fnOnCreateRole, "uiLoginHelper");
	local bIsOpen = UiManager:WindowVisible(self.UIGROUP);
	LoadUiGroup(self.UIGROUP, "loginhelper.ini");
	if (bIsOpen == 1) then
		UiManager:OpenWindow(self.UIGROUP);
	end
end

-- 重载插件
function uiLoginHelper:Reload()
	local function fnDoScript(szFilePath)
		local szFileData	= KFile.ReadTxtFile(szFilePath);
		assert(loadstring(szFileData, szFilePath))();
	end
	fnDoScript(MY_DIR .. "loginhelper.lua");
	self:UpdatePanel();
	print(GetLocalDate("LH Reloaded!! %Y%m%d %H:%M:%S"));
end

uiLoginHelper:_Init();
