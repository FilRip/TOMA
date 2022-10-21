class YakuzaCS extends SpawnNotify;

simulated function PostBeginPlay()
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
}

defaultproperties
{
    ActorClass=class'Pawn'
    bHidden=true
}

