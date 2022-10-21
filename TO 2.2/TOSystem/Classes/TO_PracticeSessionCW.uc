//=============================================================================
// TO_PracticeSessionCW
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_PracticeSessionCW expands UMenuBotmatchClientWindow;


///////////////////////////////////////
// CreatePages
///////////////////////////////////////

function CreatePages()
{
	local class<UWindowPageWindow> PageClass;

	Pages = UMenuPageControl(CreateWindow(class'UMenuPageControl', 0, 0, WinWidth, WinHeight));
	Pages.SetMultiLine(True);
	Pages.AddPage(StartMatchTab, class'TO_StartMatch');

	PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.RulesMenuType, class'Class'));
	if(PageClass != None)
		Pages.AddPage(RulesTab, PageClass);

	PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.SettingsMenuType, class'Class'));
	if(PageClass != None)
		Pages.AddPage(SettingsTab, PageClass);

	PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.BotMenuType, class'Class'));
	if(PageClass != None)
		Pages.AddPage(BotConfigTab, PageClass);
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     Map="SW-CargoShip.unr"
     GameType="s_SWAT.s_SWATGame"
}
