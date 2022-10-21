class TO22TeamSelectAuto extends TO22TeamSelect;

function SwitchTeams(int requested_team)
{
	/*if (TO_SinglePlayerGame(Level.Game) == none)
		log("TO_TeamSelectAuto::postbeginplay -- singleplayer game not found");
	else if (TO_SinglePlayerGame(Level.Game).SinglePlayerDefinition == None)
		log("TO_TeamSelectAuto::postbeginplay -- singleplayer game definition not found");
	else
		TOTeamsel_Tool_ChangeTeam(TO_SinglePlayerGame(Level.Game).SinglePlayerDefinition.PlayerTeam);*/
	log("TO_TeamSelectAuto::postbeginplay -- switching teams...");
	TOTeamsel_Tool_ChangeTeam(requested_team);
	Close();
}

defaultproperties
{
}

