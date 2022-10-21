class  TO_GameOptionsSC extends UMenuGameOptionsScrollClient;

function Created()
{
	ClientClass = class'TO_GameOptionsCW';
	FixedAreaClass = None;//class'UMenuScrollWindowOKArea';
	Super.Created();
}

defaultproperties
{
}
