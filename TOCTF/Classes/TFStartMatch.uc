Class TFStartMatch extends TO_StartMatch;

function Created ()
{
	ClientClass=Class'TFStartMatchCW';
	FixedAreaClass=None;
	Super(UWindowScrollingDialogClient).Created();
}

defaultproperties
{
}
