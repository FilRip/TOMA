class MA_skyzone extends Decoration;

#exec mesh import mesh=MAbox anivfile=Models\MAbox_a.3d datafile=Models\MAbox_d.3d x=0 y=0 z=0
#exec mesh origin mesh=MAbox x=0 y=0 z=0
#exec mesh sequence mesh=MAbox seq=All startframe=0 numframes=1
#exec mesh sequence mesh=MAbox seq=Still startframe=0 numframes=1

#exec meshmap new meshmap=MAbox mesh=MAbox
#exec meshmap scale meshmap=MAbox x=0.37500 y=0.37500 z=0.75000

var string WorkingMaps[24];

function BeginPlay()
{
	local string Map;
	local int i;

	Super.BeginPlay();

	Texture.Drawscale = 0.1;

	Map=Left(Level,instr(Level,"."));

	while ( i < 24 )
	{
		if ( Map ~= WorkingMaps[i] )
		{
			Destroy();
		}
		i++;
	}
}

                              
defaultproperties
{
    WorkingMaps(0)="TO-Avalanche"
    WorkingMaps(1)="TO-Blaze-of-Glory"
    WorkingMaps(2)="TO-CIA"
    WorkingMaps(3)="TO-Conundrum"
    WorkingMaps(4)="TO-Crossfire"
    WorkingMaps(5)="TO-Dragon"
    WorkingMaps(6)="TO-Drought"
    WorkingMaps(7)="TO-Eskero"
    WorkingMaps(8)="TO-Forge"
    WorkingMaps(9)="TO-FrozenScar"
    WorkingMaps(10)="TO-Getaway"
    WorkingMaps(11)="TO-IcyBreeze"
    WorkingMaps(12)="TO-KnightsEdge-B"
    WorkingMaps(13)="TO-Monastery"
    WorkingMaps(14)="TO-November-Rain"
    WorkingMaps(15)="TO-Omega"
    WorkingMaps(16)="TO-RapidWaters"
    WorkingMaps(17)="TO-Rebirth"
    WorkingMaps(18)="TO-Resurrection"
    WorkingMaps(19)="TO-Scope"
    WorkingMaps(20)="TO-Spynet"
    WorkingMaps(21)="TO-TerrorMansion"
    WorkingMaps(22)="TO-Thanassos"
    WorkingMaps(23)="TO-TrainStation"
    bStatic=False
    DrawType=2
    Mesh=LodMesh'MAbox'
    DrawScale=0.25
    MultiSkins=Texture'UWindow.WhiteTexture'
}
