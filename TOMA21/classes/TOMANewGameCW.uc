Class TOMANewGameCW extends TO_StartMPCW;

var localized string ExtendSettingsTab;

function CreatePages ()
{
	local Class<UWindowPageWindow> PageClass;

	Pages=UMenuPageControl(CreateWindow(Class'UMenuPageControl',0,0,WinWidth,WinHeight));
	Pages.SetMultiLine(True);
	Pages.AddPage(StartMatchTab,Class'TOMAStartMatch');
	PageClass=Class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.RulesMenuType,Class'Class'));
	if (PageClass!=None)
		Pages.AddPage(RulesTab,PageClass);
	PageClass=Class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.SettingsMenuType,Class'Class'));
	if (PageClass!=None)
		Pages.AddPage(SettingsTab,PageClass);
	PageClass=Class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.BotMenuType,Class'Class'));
	if (PageClass!=None)
		Pages.AddPage(BotConfigTab,PageClass);
	PageClass=Class<UWindowPageWindow>(DynamicLoadObject("TOMA21.TOMAExtSettingsSC",Class'Class'));
	if (PageClass!=None)
		Pages.AddPage(ExtendSettingsTab,PageClass);
}

defaultproperties
{
	GameType="TOMA21.TOMAMod"
	Map="TO-Scope.unr"
	ExtendSettingsTab="TOMA Settings"
}
