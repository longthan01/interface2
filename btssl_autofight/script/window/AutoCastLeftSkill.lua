-- ====================== �ļ���Ϣ ======================
-- �� �� ������AutoCastLeftSkill.lua
-- �� �� �ߡ�����������
-- ����ʱ�䡡��2009-10-09
-- ��    ��  ���Զ��ͷ��������
-- ����޸�  �����޺ۡ�
-- �޸�ʱ�䡡��2010-01-23
-- ע��������뱣������˵���������ֶ�ԭ���ߺ��޸��ߵ�����
-- ======================================================

local uiCheckTeacher = Ui(Ui.UI_CHECKTEACHER);


local nCastState = 0;
local nCastTimerId = 0;
local nCastTime = 0.3;

function uiCheckTeacher:Switch()
	if nCastState == 0 then
		nCastState = 1;
		me.Msg("<color=green>bat<color>");
		assert(nCastTimerId == 0);
		nCastTimerId = Timer:Register(nCastTime * Env.GAME_FPS, self.AutoCast, self);
	else
		nCastState = 0;
		me.Msg("<color=yellow>tat<color>");
		Timer:Close(nCastTimerId);
		nCastTimerId = 0;
	end
end

function uiCheckTeacher:AutoCast()
	if (nCastTimerId ~= 0) then
		UseSkill(me.nLeftSkill);
	end
end

