Class VIPTO_AutoTeamSelect extends VIPTO_TeamSelect;

function SwitchTeams (int requested_team)
{
	Log("TO_TeamSelectAuto::postbeginplay -- switching teams...");
	TOTeamsel_Tool_ChangeTeam(requested_team);
	Close();
}
