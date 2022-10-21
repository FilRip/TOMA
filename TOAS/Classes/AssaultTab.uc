Class AssaultTab extends TO_GUIBaseMgr;

simulated function OwnerInit (s_HUD HUD, TO_DesignInfo di)
{
	local int i;

	Root=TournamentConsole(HUD.PlayerOwner.Player.Console).Root;
	OwnerHUD=HUD;
	Design=di;
	TOUI_Tool_AddTab(10,Class'TO_GUITabScores');
	TOUI_Tool_AddTab(1,Class'TO_GUITabServer');
	if (HUD.PlayerOwner.IsA('AssaultPlayer'))
	{
		TOUI_Tool_AddTab(4,Class'AssaultBuyMenu');
		Log("AssaultBuyMenu added");
	}
	TOUI_Tool_AddTab(8,Class'TO_GUITabCredits');
	if (HUD.PlayerOwner.IsA('AssaultPlayer'))
		TOUI_Tool_AddTab(6,Class'TO_GUITabBriefing');
	if ((AssaultMod(Level.Game)!=None) && (AssaultMod(Level.Game).bSinglePlayer))
		TOUI_Tool_AddTab(9,Class<TO_GUIBaseTab>(DynamicLoadObject("TO_SinglePlayer.TO_GUITabDebriefing",Class'Class')));
}

defaultproperties
{
}
