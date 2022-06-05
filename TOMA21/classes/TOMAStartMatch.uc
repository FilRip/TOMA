Class TOMAStartMatch extends TO_StartMatch;

function Created ()
{
	ClientClass=Class'TOMAStartMatchCW';
	FixedAreaClass=None;
	Super(UWindowScrollingDialogClient).Created();
}

defaultproperties
{
}
