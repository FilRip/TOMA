class VIPTO_VIPSkins extends SpawnNotify;

simulated function PostBeginPlay()
{
	Class'TO_ModelHandler'.Default.Skin0[19]="VIPTOTex.Skins.VIP1Tex0";
	Class'TO_ModelHandler'.Default.Skin1[19]="VIPTOTex.Skins.VIP1Tex1";
	Class'TO_ModelHandler'.Default.Skin2[19]="VIPTOTex.Skins.VIP1Tex2";
	Class'TO_ModelHandler'.Default.Skin3[19]="VIPTOTex.Skins.VIP1Tex3";
	Class'TO_ModelHandler'.Default.Skin4[19]="VIPTOTex.Skins.VIP1Tex4";
	Class'TO_ModelHandler'.Default.ModelMesh[19]=Class'TO_ModelHandler'.Default.ModelMesh[13];
	Class'TO_ModelHandler'.Default.ModelName[19]="VIP 1";
	Class'TO_ModelHandler'.Default.ModelType[19]=MT_Hostage;
	Class'TO_ModelHandler'.Default.Skin0[20]="VIPTOTex.Skins.VIP2Tex0";
	Class'TO_ModelHandler'.Default.Skin1[20]="VIPTOTex.Skins.VIP2Tex1";
	Class'TO_ModelHandler'.Default.Skin2[20]="VIPTOTex.Skins.VIP2Tex2";
	Class'TO_ModelHandler'.Default.Skin3[20]="VIPTOTex.Skins.VIP2Tex3";
	Class'TO_ModelHandler'.Default.Skin4[20]="VIPTOTex.Skins.VIP2Tex4";
	Class'TO_ModelHandler'.Default.ModelMesh[20]=Class'TO_ModelHandler'.Default.ModelMesh[13];
	Class'TO_ModelHandler'.Default.ModelName[20]="VIP 2";
	Class'TO_ModelHandler'.Default.ModelType[20]=MT_Hostage;
}

defaultproperties
{
	ActorClass=class'VIPTOMut.VIPTO_Player'
}
