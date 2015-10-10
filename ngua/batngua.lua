-----------------------------------------------------
--创建者		：	耍耍
--创建时间	：	2011-12-18
--功能描述	：智能空放6,7,8号数字键技能, 鄂伦河源套马！
------------------------------------------------------

local uiCheckTeacher = Ui(Ui.UI_CHECKTEACHER);

local self = uiCheckTeacher
self.nCastState = 0;
local nCastTimerId = 0;
local nST = 0
local nTM = 0

function uiCheckTeacher:Switch()
	local nCastTime
	local nTtime = self:GetAttackSpeed()
	if (me.nFaction == 5 and me.CanCastSkill(98) == 1 and me.nRouteId == 2 ) then
		nCastTime = 2
	elseif (me.nFaction == 3 and me.nRouteId == 1) or (me.nFaction == 11 and me.nRouteId == 2 and me.nLevel > 89) or (me.nFaction == 14 and me.nRouteId == 1) then
		nCastTime = nTtime*3
		self:Go()
	elseif (me.nFaction == 8 and me.nRouteId == 2) or (me.nFaction == 10 and me.nRouteId == 2) or (me.nFaction == 11 and me.nRouteId == 2 and me.nLevel < 90) then
		nCastTime = nTtime*2
		self:Go()
	else
		nCastTime = nTtime
	end

	if self.nCastState == 0 then 
		self.nCastState = 1;

		if me.CanCastSkill(2589) == 1 and me.nTemplateMapId == 2152 then
			--UiManager:OpenWindow("UI_INFOBOARD", "<color=0,255,255>Put ngựa rỗng mà có thể tự động tắt!");
			assert(nCastTimerId == 0);
			nST = 1
			nCastTimerId = Timer:Register(1 * Env.GAME_FPS, self.AutoCast, self);
			return
		end

		if (me.nFaction == 3 and me.nRouteId == 1) or (me.nFaction == 11 and me.nRouteId == 2 and me.nLevel > 89) or (me.nFaction == 14 and me.nRouteId == 1) then
			--UiManager:OpenWindow("UI_INFOBOARD", "<bclr=pink><color=white>Trống nơi số 6,7,8 kỹ năng thông minh quan trọng [ R ]");
		elseif (me.nFaction == 8 and me.nRouteId == 2) or (me.nFaction == 10 and me.nRouteId == 2) or (me.nFaction == 11 and me.nRouteId == 2 and me.nLevel < 90) then
			UiManager:OpenWindow("UI_INFOBOARD", "<bclr=pink><color=white>BẬT BẮT NGỰA");
		else
			--UiManager:OpenWindow("UI_INFOBOARD", "<bclr=pink><color=white>Chỗ trống không tự động trên các kỹ năng quan trọng thứ 6 [ R ]");
		end
		assert(nCastTimerId == 0);
		nCastTimerId = Timer:Register(nCastTime * Env.GAME_FPS, self.AutoCast, self);
	else
		self.nCastState = 0;
		nST = 0
		UiManager:OpenWindow("UI_INFOBOARD", "<bclr=blue><color=white>TẮT BẮT NGỰA<color>");
		Timer:Close(nCastTimerId);
		nCastTimerId = 0;
		nTM = 0
	end
end

function uiCheckTeacher:AutoCast()
	if me.nFightState ~= 1 then
		return;
	end
	if (nCastTimerId ~= 0) then
		if nST == 1 then
			if me.CanCastSkill(2589) == 1 then
				UseSkill(2589);
				nTM = 0
			else
				nTM = nTM + 1
				if nTM > 10 then
					self.nCastState = 0;
					nST = 0;
					--UiManager:OpenWindow("UI_INFOBOARD", "<bclr=blue><color=white>Ngựa tự động tắt !<color>");
					Timer:Close(nCastTimerId);
					nCastTimerId = 0;
					nTM = 0
				end
			end
			return;
		end
		self:Go()
	end
end

function uiCheckTeacher:Go()
	Ui(Ui.UI_SHORTCUTBAR):OnUseShortcutObj(5)	--六号键
	if (me.nFaction == 3 and me.nRouteId == 1) or (me.nFaction == 11 and me.nRouteId == 2 and me.nLevel > 89) or (me.nFaction == 14 and me.nRouteId == 1) then		--剑明，陷阱，掌逍遥连招。6.7.8号键
		local nTtime = self:GetAttackSpeed()
		local function fnST1()
			if self.nCastState == 0 then
				return 0;
			end
			Ui(Ui.UI_SHORTCUTBAR):OnUseShortcutObj(6)		--七号
			return 0;			
		end
		local function fnST2()
			if self.nCastState == 0 then
				return 0;
			end
			Ui(Ui.UI_SHORTCUTBAR):OnUseShortcutObj(7)		--八号
			return 0;			
		end

		Ui.tbLogic.tbTimer:Register(nTtime * Env.GAME_FPS, fnST1);		--七号键时间
		Ui.tbLogic.tbTimer:Register(nTtime*2 * Env.GAME_FPS, fnST2);		--八号键时间
	end
	if (me.nFaction == 8 and me.nRouteId == 2) or (me.nFaction == 10 and me.nRouteId == 2) or (me.nFaction == 11 and me.nRouteId == 2 and me.nLevel < 90) then	--魔忍，剑昆, 低级剑明连招。6.7号键
		local nTtime = self:GetAttackSpeed()
		local function fnST3()
			if self.nCastState == 0 then
				return 0;
			end
			Ui(Ui.UI_SHORTCUTBAR):OnUseShortcutObj(6)		--七号
			return 0;			
		end
		Ui.tbLogic.tbTimer:Register(nTtime * Env.GAME_FPS, fnST3);		--七号键时间
	end
end

function uiCheckTeacher:GetAttackSpeed()
	local tbSet = KFightSkill.GetSetting();
	local nAttackPerSecond = math.max(tbSet.nAttackFrameMin, Env.GAME_FPS - math.floor(me.nAttackSpeed / 10));
	nAttackPerSecond = math.min(tbSet.nAttackFrameMax, nAttackPerSecond) / Env.GAME_FPS;
	nAttackPerSecond = math.floor(nAttackPerSecond * 100 + 0.5) / 100;
	local nCastPerSecond = math.max(tbSet.nCastFrameMin, Env.GAME_FPS - math.floor(me.nCastSpeed / 10));
	nCastPerSecond = math.min(tbSet.nCastFrameMax, nCastPerSecond) / Env.GAME_FPS;
	nCastPerSecond = math.floor(nCastPerSecond * 100 + 0.5) / 100;

	if nAttackPerSecond <= nCastPerSecond then
		return nAttackPerSecond
	elseif nAttackPerSecond > nCastPerSecond then
		return nCastPerSecond			--耍耍
	end
end