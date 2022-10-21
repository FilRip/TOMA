Class TMStartMatch extends TO_StartMatch;

function Created ()
{
	ClientClass=Class'TMStartMatchCW';
	FixedAreaClass=None;
	Super(UWindowScrollingDialogClient).Created();
}

defaultproperties
{
}
