class TMGUIBaseMgr extends TO_GUIBaseMgr;

simulated function OwnerInit(s_HUD hud,TO_DesignInfo di)
{
	local int i;

	Root=TournamentConsole(hud.PlayerOwner.Player.Console).Root;
	OwnerHUD=hud;
	Design=di;

	TOUI_Tool_AddTab(UIT_SCORES,class'TMGUITabScores');
	TOUI_Tool_AddTab(UIT_SERVER,class'TO_GUITabServer');

	if (hud.PlayerOwner.IsA('s_Player'))
		TOUI_Tool_AddTab(UIT_BUYMENU,class'TO_GUITabBuymenu');
	TOUI_Tool_AddTab(UIT_CREDITS,class'TO_GUITabCredits');

	if (hud.PlayerOwner.IsA('s_Player'))
		TOUI_Tool_AddTab(UIT_BRIEFING, class'TO_GUITabBriefing');

	if ((s_SWATGame(Level.Game)!=None) && (s_SWATGame(Level.Game).bSinglePlayer))
		TOUI_Tool_AddTab(UIT_DEBRIEFING,class<TO_GUIBaseTab>(DynamicLoadObject("TO_SinglePlayer.TO_GUITabDebriefing",class'Class')));
}

defaultproperties
{
}

