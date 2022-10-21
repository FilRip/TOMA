///////////////////////////////////////
// Add Yakuza player model on TO 3.4 //
///////////////////////////////////////

class YakuzaModel extends Mutator;

#exec texture IMPORT NAME=YakuzaTex0 FILE=textures\YakuzaTex0.bmp GROUP="Skins" Flags=3
#exec texture IMPORT NAME=YakuzaTex1 FILE=textures\YakuzaTex1.bmp GROUP="Skins" Flags=3
#exec texture IMPORT NAME=YakuzaTex2 FILE=textures\YakuzaTex2.bmp GROUP="Skins" Flags=3
#exec texture IMPORT NAME=YakuzaTex3 FILE=textures\YakuzaTex3.bmp GROUP="Skins" Flags=3
#exec texture IMPORT NAME=YakuzaTex4 FILE=textures\YakuzaTex4.bmp GROUP="Skins" Flags=3
#exec texture IMPORT NAME=YakuzaTex5 FILE=textures\YakuzaTex5.bmp GROUP="Skins" Flags=3

function PreBeginPlay()
{
	Class'TO_ModelHandler'.default.Skin0[19]="TOExtra.Skins.YakuzaTex0";
	Class'TO_ModelHandler'.default.Skin1[19]="TOExtra.Skins.YakuzaTex1";
	Class'TO_ModelHandler'.default.Skin2[19]="TOExtra.Skins.YakuzaTex2";
	Class'TO_ModelHandler'.default.Skin3[19]="TOExtra.Skins.YakuzaTex3";
	Class'TO_ModelHandler'.default.Skin4[19]="TOExtra.Skins.YakuzaTex4";
	Class'TO_ModelHandler'.default.Skin5[19]="TOExtra.Skins.YakuzaTex5";
	Class'TO_ModelHandler'.default.ModelMesh[19]=SkeletalMesh'TOExtraModels.Yakuza315';
	Class'TO_ModelHandler'.default.ModelName[19]="Yakuza";
	Class'TO_ModelHandler'.default.ModelType[19]=MT_Terrorist;
    super.PreBeginPlay();
    spawn(class'YakuzaCS');
}

/*function ModifyLogin(out Class<PlayerPawn> SpawnClass,out string Portal,out string Options)
{
	if (SpawnClass==Class'S_Player_T')
		SpawnClass=Class'TOExtraPlayer';
	if (NextMutator!=None)
		NextMutator.ModifyLogin(SpawnClass,Portal,Options);
}*/

defaultproperties
{
    bHidden=true
}

