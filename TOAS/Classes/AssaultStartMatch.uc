Class AssaultStartMatch extends TO_StartMatch;

function Created ()
{
	ClientClass=Class'AssaultStartMatchCW';
	FixedAreaClass=None;
	Super(UWindowScrollingDialogClient).Created();
}

defaultproperties
{
}
