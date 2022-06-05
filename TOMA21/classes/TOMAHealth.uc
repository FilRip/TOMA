Class TOMAHealth extends Health;

function SetRespawn()
{
	GotoState('Sleeping');
}

defaultproperties
{
	HealingAmount=20
}
