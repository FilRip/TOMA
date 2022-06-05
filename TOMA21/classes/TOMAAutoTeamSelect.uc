Class TOMAAutoTeamSelect extends TOMATeamSelect;

function SwitchTeams (int requested_team)
{
	Log("TO_TeamSelectAuto::postbeginplay -- switching teams...");
	TOTeamsel_Tool_ChangeTeam(requested_team);
	Close();
}
