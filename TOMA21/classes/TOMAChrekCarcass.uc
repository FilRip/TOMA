class TOMAChrekCarcass extends TMale1Carcass;

function CreateReplacement()
{
	if ( Mesh == Default.Mesh )
		MasterReplacement = class'TMaleMasterChunk';

	Super.CreateReplacement();
}

defaultproperties
{
    MasterReplacement=Class'TOMAChrekMasterChunk'
}
