
local szCmd	= [=[
		AutoAi:JieBao();
	]=];
UiShortcutAlias:AddAlias("GM_S4", szCmd);	-- phím tắt Ctrl+5 

function AutoAi:JieBao()
	local pTabFile = KIo.OpenTabFile("\\setting\\setting.pak.txt");
	local nHeight = pTabFile.GetHeight();
	for i = 3, nHeight do
		local nFile 	= pTabFile.GetStr(i, 4);
		local szMsg	= KFile.ReadTxtFile(nFile);
		KFile.WriteFile("\\user"..nFile, szMsg);	-- đường dẫn folder sau khi unpak
	end
	KIo.CloseTabFile(pTabFile);

	local pTabFile = KIo.OpenTabFile("\\script\\script.pak.txt");
	local nHeight = pTabFile.GetHeight();
	for i = 3, nHeight do
		local nFile 	= pTabFile.GetStr(i, 4);
		local szMsg	= KFile.ReadTxtFile(nFile);
		KFile.WriteFile("\\user"..nFile, szMsg);	-- đường dẫn folder sau khi unpak
	end
	KIo.CloseTabFile(pTabFile);

	local pTabFile = KIo.OpenTabFile("\\ui\\ui.pak.txt");
	local nHeight = pTabFile.GetHeight();
	for i = 3, nHeight do
		local nFile 	= pTabFile.GetStr(i, 4);
		local szMsg	= KFile.ReadTxtFile(nFile);
		KFile.WriteFile("\\user"..nFile, szMsg);	-- đường dẫn folder sau khi unpak
	end
	KIo.CloseTabFile(pTabFile);
end


