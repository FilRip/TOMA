class TOPAMClientSide extends SpawnNotify;

// Finalement, on ne va pas faire comme ca
// Ca change les valeurs de défaut de TO
// La classe reste la juste pour infos sur les mesh/models/skins
// Ne pas Spawner cette class

simulated function PostBeginPlay()
{
	Class'TO_ModelHandler'.Default.Skin0[19]="UnrealI.Skaarjl";
	Class'TO_ModelHandler'.Default.ModelMesh[19]=LodMesh'UnrealShare.Skaarjw';
	Class'TO_ModelHandler'.Default.ModelName[19]="SkaarjLord";
	Class'TO_ModelHandler'.Default.ModelType[19]=MT_Terrorist;

	Class'TO_ModelHandler'.Default.Skin0[20]="UnrealShare.JFly1";
	Class'TO_ModelHandler'.Default.ModelMesh[20]=LodMesh'UnrealShare.FlyM';
	Class'TO_ModelHandler'.Default.ModelName[20]="Fly";
	Class'TO_ModelHandler'.Default.ModelType[20]=MT_Terrorist;

	Class'TO_ModelHandler'.Default.Skin0[21]="UnrealI.jpupae1";
	Class'TO_ModelHandler'.Default.ModelMesh[21]=LodMesh'UnrealI.pupae1';
	Class'TO_ModelHandler'.Default.ModelName[21]="Pupae";
	Class'TO_ModelHandler'.Default.ModelType[21]=MT_Terrorist;

	Class'TO_ModelHandler'.Default.Skin0[22]="UnrealI.Jtitan1";
	Class'TO_ModelHandler'.Default.ModelMesh[22]=LodMesh'UnrealI.Titan1';
	Class'TO_ModelHandler'.Default.ModelName[22]="Titan";
	Class'TO_ModelHandler'.Default.ModelType[22]=MT_Terrorist;

	Class'TO_ModelHandler'.Default.Skin0[23]="UnrealI.Jwarlord1";
	Class'TO_ModelHandler'.Default.ModelMesh[23]=LodMesh'UnrealI.WarlordM';
	Class'TO_ModelHandler'.Default.ModelName[23]="WarLord";
	Class'TO_ModelHandler'.Default.ModelType[23]=MT_Terrorist;

	Class'TO_ModelHandler'.Default.Skin0[24]="UnrealShare.JCow1";
	Class'TO_ModelHandler'.Default.ModelMesh[24]=LodMesh'UnrealShare.NaliCow';
	Class'TO_ModelHandler'.Default.ModelName[24]="Cow";
	Class'TO_ModelHandler'.Default.ModelType[24]=MT_Terrorist;

	Class'TO_ModelHandler'.Default.Skin0[25]="UnrealI.Brute2";
	Class'TO_ModelHandler'.Default.ModelMesh[25]=LodMesh'UnrealShare.Brute1';
	Class'TO_ModelHandler'.Default.ModelName[25]="Behemoth";
	Class'TO_ModelHandler'.Default.ModelType[25]=MT_Terrorist;

	Class'TO_ModelHandler'.Default.Skin0[26]="UnrealShare.Jfish1";
	Class'TO_ModelHandler'.Default.ModelMesh[26]=LodMesh'UnrealShare.fish';
	Class'TO_ModelHandler'.Default.ModelName[26]="DevilFish";
	Class'TO_ModelHandler'.Default.ModelType[26]=MT_Terrorist;

	Class'TO_ModelHandler'.Default.Skin0[27]="UnrealI.jkrall";
	Class'TO_ModelHandler'.Default.ModelMesh[27]=LodMesh'UnrealI.KrallM';
	Class'TO_ModelHandler'.Default.ModelName[27]="Krall";
	Class'TO_ModelHandler'.Default.ModelType[27]=MT_Terrorist;

	Class'TO_ModelHandler'.Default.Skin0[28]="UnrealI.JMerc1";
	Class'TO_ModelHandler'.Default.ModelMesh[28]=LodMesh'UnrealI.Merc';
	Class'TO_ModelHandler'.Default.ModelName[28]="Mercenary";
	Class'TO_ModelHandler'.Default.ModelType[28]=MT_Terrorist;

	Class'TO_ModelHandler'.Default.Skin0[29]="UnrealI.GasBag2";
	Class'TO_ModelHandler'.Default.Skin1[29]="UnrealI.GasBag1";
	Class'TO_ModelHandler'.Default.ModelMesh[29]=LodMesh'UnrealI.GasBagM';
	Class'TO_ModelHandler'.Default.ModelName[29]="GasBag";
	Class'TO_ModelHandler'.Default.ModelType[29]=MT_Terrorist;

	Class'TO_ModelHandler'.Default.Skin0[30]="UnrealShare.JManta1";
	Class'TO_ModelHandler'.Default.ModelMesh[30]=LodMesh'UnrealShare.Manta1';
	Class'TO_ModelHandler'.Default.ModelName[30]="Manta";
	Class'TO_ModelHandler'.Default.ModelType[30]=MT_Terrorist;

	Class'TO_ModelHandler'.Default.Skin0[31]="UnrealI.JQueen1";
	Class'TO_ModelHandler'.Default.ModelMesh[31]=LodMesh'UnrealI.SkQueen';
	Class'TO_ModelHandler'.Default.ModelName[31]="Manta";
	Class'TO_ModelHandler'.Default.ModelType[31]=MT_Terrorist;

	Log("TOPAM skin added");
}
