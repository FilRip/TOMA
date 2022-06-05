class TOMATab extends TO_GUIBaseMgr;

simulated function OwnerInit (s_HUD HUD, TO_DesignInfo di)
{
	local int i;

	Root=TournamentConsole(HUD.PlayerOwner.Player.Console).Root;
	OwnerHUD=HUD;
	Design=di;
	TOUI_Tool_AddTab(10,Class'TOMAScoreBoard');
	TOUI_Tool_AddTab(1,Class'TO_GUITabServer');
	if (HUD.PlayerOwner.IsA('TOMAPlayer'))
	{
		TOUI_Tool_AddTab(4,Class'TOMABuyMenu');
		Log("TOMABuyMenu added");
	}
	TOUI_Tool_AddTab(8,Class'TO_GUITabCredits');
	TOUI_Tool_AddTab(16,Class'TOMAGUITabVote');
	if (HUD.PlayerOwner.IsA('TOMAPlayer'))
		TOUI_Tool_AddTab(6,Class'TO_GUITabBriefing');
	if ((TOMAMod(Level.Game)!=None) && (TOMAMod(Level.Game).bSinglePlayer))
		TOUI_Tool_AddTab(9,Class<TO_GUIBaseTab>(DynamicLoadObject("TO_SinglePlayer.TO_GUITabDebriefing",Class'Class')));
}

defaultproperties
{
}
