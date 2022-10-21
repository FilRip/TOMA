class TO22PlayerModels extends Mutator;

var byte i;

function Destroyed()
{
    class'TO_ModelHandler'.Default.Skin0[2]="TOPModels.Skins.TerrorTex0Urban";
    class'TO_ModelHandler'.Default.Skin0[3]="TOPModels.Skins.TerrorTex0Generic";
    class'TO_ModelHandler'.Default.Skin0[4]="TOPModels.Skins.TerrorTex0Wood";
    class'TO_ModelHandler'.Default.Skin0[9]="";

    class'TO_ModelHandler'.Default.Skin1[0]="TOPModels.Skins.HostageTex1";
    class'TO_ModelHandler'.Default.Skin1[1]="TOPModels.Skins.TerrorTex1SWAT";
    class'TO_ModelHandler'.Default.Skin1[2]="TOPModels.Skins.TerrorTex1Urban";
    class'TO_ModelHandler'.Default.Skin1[3]="TOPModels.Skins.TerrorTex1Generic";
    class'TO_ModelHandler'.Default.Skin1[4]="TOPModels.Skins.TerrorTex1Wood";
    class'TO_ModelHandler'.Default.Skin1[5]="TOPModels.Skins.SealTex1";
    class'TO_ModelHandler'.Default.Skin1[6]="TOPModels.Skins.SealTex1P";
    class'TO_ModelHandler'.Default.Skin1[7]="TOPModels.Skins.JillTex1P";
    class'TO_ModelHandler'.Default.Skin1[8]="TOPModels.Skins.JillTex1S";
    class'TO_ModelHandler'.Default.Skin1[9]="";

    class'TO_ModelHandler'.Default.Skin2[0]="TOPModels.Skins.HostageTex2b";
    class'TO_ModelHandler'.Default.Skin2[1]="TOPModels.Skins.TerrorTex2SWAT";
    class'TO_ModelHandler'.Default.Skin2[2]="TOPModels.Skins.TerrorTex2Urban";
    class'TO_ModelHandler'.Default.Skin2[3]="TOPModels.Skins.TerrorTex2Generic";
    class'TO_ModelHandler'.Default.Skin2[4]="TOPModels.Skins.TerrorTex2Wood";
    class'TO_ModelHandler'.Default.Skin2[5]="TOPModels.Skins.SealTex2";
    class'TO_ModelHandler'.Default.Skin2[6]="TOPModels.Skins.SealTex2P";
    class'TO_ModelHandler'.Default.Skin2[7]="TOPModels.Skins.JillTex2P";
    class'TO_ModelHandler'.Default.Skin2[8]="TOPModels.Skins.JillTex2S";
    class'TO_ModelHandler'.Default.Skin2[9]="";

    class'TO_ModelHandler'.Default.Skin3[0]="TOPModels.Skins.HostageTex3";
    class'TO_ModelHandler'.Default.Skin3[1]="TOPModels.Skins.TerrorTex3SWAT";
    class'TO_ModelHandler'.Default.Skin3[2]="TOPModels.Skins.TerrorTex3Urban";
    class'TO_ModelHandler'.Default.Skin3[3]="TOPModels.Skins.TerrorTex3Generic";
    class'TO_ModelHandler'.Default.Skin3[4]="TOPModels.Skins.TerrorTex3Wood";
    class'TO_ModelHandler'.Default.Skin3[5]="TOPModels.Skins.SealTex3";
    class'TO_ModelHandler'.Default.Skin3[6]="TOPModels.Skins.SealTex3P";
    class'TO_ModelHandler'.Default.Skin3[7]="TOPModels.Skins.JillTex3P";
    class'TO_ModelHandler'.Default.Skin3[8]="TOPModels.Skins.JillTex3S";
    class'TO_ModelHandler'.Default.Skin3[9]="";

    class'TO_ModelHandler'.Default.Skin4[0]="TOPModels.Skins.HostageTex4";
    class'TO_ModelHandler'.Default.Skin4[2]="TOPModels.Skins.TerrorTex4Urban";
    class'TO_ModelHandler'.Default.Skin4[3]="TOPModels.Skins.TerrorTex4Generic";
    class'TO_ModelHandler'.Default.Skin4[4]="TOPModels.Skins.TerrorTex4Wood";
    class'TO_ModelHandler'.Default.Skin4[5]="TOPModels.Skins.SealTex4";
    class'TO_ModelHandler'.Default.Skin4[6]="TOPModels.Skins.SealTex4P";
    class'TO_ModelHandler'.Default.Skin4[7]="TOPModels.Skins.JillTex4P";
    class'TO_ModelHandler'.Default.Skin4[8]="TOPModels.Skins.JillTex4S";

    class'TO_ModelHandler'.Default.Skin5[2]="TOPModels.Skins.TerrorTex5";
    class'TO_ModelHandler'.Default.Skin5[3]="TOPModels.Skins.TerrorTex5";
    class'TO_ModelHandler'.Default.Skin5[4]="TOPModels.Skins.TerrorTex5";

    Class'TO_ModelHandler'.Default.ModelMesh[0]=SkeletalMesh'topmodels.Hostage';
    Class'TO_ModelHandler'.Default.ModelMesh[1]=SkeletalMesh'topmodels.Terror2';
    Class'TO_ModelHandler'.Default.ModelMesh[2]=SkeletalMesh'topmodels.Terror2';
    Class'TO_ModelHandler'.Default.ModelMesh[3]=SkeletalMesh'topmodels.Terror2';
    Class'TO_ModelHandler'.Default.ModelMesh[4]=SkeletalMesh'topmodels.Terror2';
    Class'TO_ModelHandler'.Default.ModelMesh[5]=SkeletalMesh'topmodels.Seal';
    Class'TO_ModelHandler'.Default.ModelMesh[6]=SkeletalMesh'topmodels.Seal';
    Class'TO_ModelHandler'.Default.ModelMesh[7]=SkeletalMesh'topmodels.Jill';
    Class'TO_ModelHandler'.Default.ModelMesh[8]=SkeletalMesh'topmodels.Jill';
    Class'TO_ModelHandler'.Default.ModelMesh[9]=None;

    Class'TO_ModelHandler'.Default.ModelName[0]="Hostage";
    Class'TO_ModelHandler'.Default.ModelName[1]="SWAT light";
    Class'TO_ModelHandler'.Default.ModelName[2]="Urban Camo";
    Class'TO_ModelHandler'.Default.ModelName[3]="Urban Cargo";
    Class'TO_ModelHandler'.Default.ModelName[4]="WoodLand";
    Class'TO_ModelHandler'.Default.ModelName[5]="Navy Seal";
    Class'TO_ModelHandler'.Default.ModelName[6]="Polizei";
    Class'TO_ModelHandler'.Default.ModelName[7]="Police female";
    Class'TO_ModelHandler'.Default.ModelName[8]="SWAT female";
    Class'TO_ModelHandler'.Default.ModelName[9]="";

    Class'TO_ModelHandler'.Default.ModelType[0]=MT_Hostage;
    Class'TO_ModelHandler'.Default.ModelType[1]=MT_SpecialForces;
    Class'TO_ModelHandler'.Default.ModelType[2]=MT_Terrorist;
    Class'TO_ModelHandler'.Default.ModelType[3]=MT_Terrorist;
    Class'TO_ModelHandler'.Default.ModelType[4]=MT_Terrorist;
    Class'TO_ModelHandler'.Default.ModelType[5]=MT_SpecialForces;
    Class'TO_ModelHandler'.Default.ModelType[6]=MT_SpecialForces;
    Class'TO_ModelHandler'.Default.ModelType[7]=MT_SpecialForces;
    Class'TO_ModelHandler'.Default.ModelType[8]=MT_SpecialForces;
    Class'TO_ModelHandler'.Default.ModelType[9]=MT_None;

    super.Destroyed();
}

function PreBeginPlay()
{
    local int i;

    super.PreBeginPlay();
    Class'TO_ModelHandler'.Default.Skin0[2]="TOPModels220.SFMediumArmyTex2";
    Class'TO_ModelHandler'.Default.Skin0[3]="TOPModels220.SFMediumDesertTex2";
    Class'TO_ModelHandler'.Default.Skin0[4]="TOPModels220.SWAT_Face";
    Class'TO_ModelHandler'.Default.Skin0[9]="TOPModels220.YakuzaTorse";
    Class'TO_ModelHandler'.Default.Skin1[0]="TOPModels220.CJunk_Face";
    Class'TO_ModelHandler'.Default.Skin1[1]="TOPModels220.HSuitHead";
    Class'TO_ModelHandler'.Default.Skin1[2]="TOPModels220.SFMediumArmyTex1";
    Class'TO_ModelHandler'.Default.Skin1[3]="TOPModels220.SFMediumDesertTex1";
    Class'TO_ModelHandler'.Default.Skin1[4]="TOPModels220.SFMedSWATTex1";
    Class'TO_ModelHandler'.Default.Skin1[5]="TOPModels220.SWAT_Face";
    Class'TO_ModelHandler'.Default.Skin1[6]="TOPModels220.CC_Face";
    Class'TO_ModelHandler'.Default.Skin1[7]="TOPModels220.CCSM_Face";
    Class'TO_ModelHandler'.Default.Skin1[8]="TOPModels220.Scarface_Face";
    Class'TO_ModelHandler'.Default.Skin1[9]="TOPModels220.YakuzaArms";
    Class'TO_ModelHandler'.Default.Skin2[0]="TOPModels220.SFMediumSnowTex1";
    Class'TO_ModelHandler'.Default.Skin2[1]="TOPModels220.HSuitTorse";
    Class'TO_ModelHandler'.Default.Skin2[2]="TOPModels220.SFMediumArmyTex3";
    Class'TO_ModelHandler'.Default.Skin2[3]="TOPModels220.SFMediumDesertTex3";
    Class'TO_ModelHandler'.Default.Skin2[4]="TOPModels220.SFMedSWATTex3";
    Class'TO_ModelHandler'.Default.Skin2[5]="TOPModels220.SFMedSWATBTex1";
    Class'TO_ModelHandler'.Default.Skin2[6]="TOPModels220.CCSM_Hands";
    Class'TO_ModelHandler'.Default.Skin2[7]="TOPModels220.CCSM_Hands";
    Class'TO_ModelHandler'.Default.Skin2[8]="TOPModels220.Scarface_Hands";
    Class'TO_ModelHandler'.Default.Skin2[9]="TOPModels220.YakuzaHead";
    Class'TO_ModelHandler'.Default.Skin3[0]="TOPModels220.SFMediumSnowTex3";
    Class'TO_ModelHandler'.Default.Skin3[1]="TOPModels220.HSuitLegs";
    Class'TO_ModelHandler'.Default.Skin3[2]="TOPModels220.SFMediumArmyTex0";
    Class'TO_ModelHandler'.Default.Skin3[3]="TOPModels220.SFMediumDesertTex0";
    Class'TO_ModelHandler'.Default.Skin3[4]="TOPModels220.SFMedSWATTex0";
    Class'TO_ModelHandler'.Default.Skin3[5]="TOPModels220.SFMedSWATBTex3";
    Class'TO_ModelHandler'.Default.Skin3[6]="TOPModels220.CCSM_Legs";
    Class'TO_ModelHandler'.Default.Skin3[7]="TOPModels220.CCSM_Legs";
    Class'TO_ModelHandler'.Default.Skin3[8]="TOPModels220.Scarface_Legs";
    Class'TO_ModelHandler'.Default.Skin3[9]="TOPModels220.YakuzaLegs";
    Class'TO_ModelHandler'.Default.Skin4[0]="TOPModels220.SFMediumSnowTex0";
    Class'TO_ModelHandler'.Default.Skin4[2]="TOPModels220.SFMediumArmyTex4";
    Class'TO_ModelHandler'.Default.Skin4[3]="TOPModels220.SFMediumDesertTex4";
    Class'TO_ModelHandler'.Default.Skin4[4]="TOPModels220.SFMedSWATTex4";
    Class'TO_ModelHandler'.Default.Skin4[5]="TOPModels220.SFMedSWATTex0";
    Class'TO_ModelHandler'.Default.Skin4[6]="TOPModels220.CCSM_Torse";
    Class'TO_ModelHandler'.Default.Skin4[7]="TOPModels220.CCSM_Torse";
    Class'TO_ModelHandler'.Default.Skin4[8]="TOPModels220.Scarface_Torse";
    Class'TO_ModelHandler'.Default.Skin5[2]="TOPModels220.SFMediumArmyTex4";
    Class'TO_ModelHandler'.Default.Skin5[3]="TOPModels220.SFMediumDesertTex4";
    Class'TO_ModelHandler'.Default.Skin5[4]="TOPModels220.SFMedSWATTex4";
    Class'TO_ModelHandler'.Default.ModelMesh[0]=SkeletalMesh'TerrorMesh';
    Class'TO_ModelHandler'.Default.ModelMesh[1]=SkeletalMesh'HostageMesh';
    Class'TO_ModelHandler'.Default.ModelMesh[2]=SkeletalMesh'SFMediumMesh';
    Class'TO_ModelHandler'.Default.ModelMesh[3]=SkeletalMesh'SFMediumMesh';
    Class'TO_ModelHandler'.Default.ModelMesh[4]=SkeletalMesh'SFMediumMesh';
    Class'TO_ModelHandler'.Default.ModelMesh[5]=SkeletalMesh'TerrorMesh';
    Class'TO_ModelHandler'.Default.ModelMesh[6]=SkeletalMesh'TerrorMesh';
    Class'TO_ModelHandler'.Default.ModelMesh[7]=SkeletalMesh'TerrorMesh';
    Class'TO_ModelHandler'.Default.ModelMesh[8]=SkeletalMesh'TerrorMesh';
    Class'TO_ModelHandler'.Default.ModelMesh[9]=SkeletalMesh'YakuzaMesh';
    Class'TO_ModelHandler'.Default.ModelName[0]="Alpine Squad";
    Class'TO_ModelHandler'.Default.ModelName[1]="Hostage SuitBoy";
    Class'TO_ModelHandler'.Default.ModelName[2]="U.S. Army";
    Class'TO_ModelHandler'.Default.ModelName[3]="Desert Trooper";
    Class'TO_ModelHandler'.Default.ModelName[4]="Black S.W.A.T.";
    Class'TO_ModelHandler'.Default.ModelName[5]="Blue S.W.A.T.";
    Class'TO_ModelHandler'.Default.ModelName[6]="Camo Johnson";
    Class'TO_ModelHandler'.Default.ModelName[7]="Camo Ski Mask";
    Class'TO_ModelHandler'.Default.ModelName[8]="Scarface";
    Class'TO_ModelHandler'.Default.ModelName[9]="Yakuza";
    Class'TO_ModelHandler'.Default.ModelType[0]=MT_Terrorist;
    Class'TO_ModelHandler'.Default.ModelType[1]=MT_Hostage;
    Class'TO_ModelHandler'.Default.ModelType[2]=MT_SpecialForces;
    Class'TO_ModelHandler'.Default.ModelType[3]=MT_SpecialForces;
    Class'TO_ModelHandler'.Default.ModelType[4]=MT_SpecialForces;
    Class'TO_ModelHandler'.Default.ModelType[5]=MT_SpecialForces;
    Class'TO_ModelHandler'.Default.ModelType[6]=MT_Terrorist;
    Class'TO_ModelHandler'.Default.ModelType[7]=MT_Terrorist;
    Class'TO_ModelHandler'.Default.ModelType[8]=MT_Terrorist;
    Class'TO_ModelHandler'.Default.ModelType[9]=MT_Terrorist;
    for (i=10;i<19;i++)
        class'TO_ModelHandler'.Default.ModelType[i]=MT_None;
    i=1;
    SetTimer(1,true);
}

function Timer()
{
    if ((s_SWATGame(Level.Game).GamePeriod==GP_PostRound) && (i!=1)) i=1;
}

function ModifyLogin(out Class<PlayerPawn> SpawnClass,out string Portal,out string Options)
{
	if (SpawnClass==Class'S_Player_T')
		SpawnClass=Class'TOExtraPlayer';
	if (NextMutator!=None)
		NextMutator.ModifyLogin(SpawnClass,Portal,Options);
}

function bool ReplaceHostage(actor Other, string aClassName)
{
	local Actor A;
	local class<Actor> aClass;
    local Pawn P;
    local byte i;

	if ( Other.IsA('Inventory') && (Other.Location == vect(0,0,0)) )
		return false;
	aClass = class<Actor>(DynamicLoadObject(aClassName, class'Class'));
	if ( aClass != None )
		A = Spawn(aClass,Other.Owner,Other.tag,Other.Location, Other.Rotation);
	if ( A != None )
	{
		A.event = Other.event;
		A.tag = Other.tag;
		A.Mesh=Other.Mesh;
        TOExtra22Hostage(A).PlayerReplicationInfo.Team=2;
        TOExtra22Hostage(A).PlayerReplicationInfo.PlayerName="Hostage"$string(i);
        i++;
		for (i=0;i<4;i++)
		  A.MultiSkins[i]=Other.MultiSkins[i];
		class'TOPModels.TO_ModelHandler'.static.DressModel(A,1);
		return true;
	}
	return false;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    if ((Other.IsA('s_NPCHostage_M2')) && (!Other.IsA('TOExtra22Hostage')))
    {
        s_NPCHostage(Other).CarcassType=None;
        ReplaceHostage(Other,"TOExtra2.TOExtra22Hostage");
        return false;
    }
	return true;
}

defaultproperties
{
}

