class TOSgtNutzPlayerModels extends Mutator;

var int CurrentRound;

function Destroyed()
{
    class'TO_ModelHandler'.Default.Skin0[2]="TOPModels.Skins.TerrorTex0Urban";
    class'TO_ModelHandler'.Default.Skin0[3]="TOPModels.Skins.TerrorTex0Generic";
    class'TO_ModelHandler'.Default.Skin0[4]="TOPModels.Skins.TerrorTex0Wood";

    class'TO_ModelHandler'.Default.Skin1[0]="TOPModels.Skins.HostageTex1";
    class'TO_ModelHandler'.Default.Skin1[1]="TOPModels.Skins.TerrorTex1SWAT";
    class'TO_ModelHandler'.Default.Skin1[2]="TOPModels.Skins.TerrorTex1Urban";
    class'TO_ModelHandler'.Default.Skin1[3]="TOPModels.Skins.TerrorTex1Generic";
    class'TO_ModelHandler'.Default.Skin1[4]="TOPModels.Skins.TerrorTex1Wood";

    class'TO_ModelHandler'.Default.Skin2[0]="TOPModels.Skins.HostageTex2b";
    class'TO_ModelHandler'.Default.Skin2[1]="TOPModels.Skins.TerrorTex2SWAT";
    class'TO_ModelHandler'.Default.Skin2[2]="TOPModels.Skins.TerrorTex2Urban";
    class'TO_ModelHandler'.Default.Skin2[3]="TOPModels.Skins.TerrorTex2Generic";
    class'TO_ModelHandler'.Default.Skin2[4]="TOPModels.Skins.TerrorTex2Wood";

    class'TO_ModelHandler'.Default.Skin3[0]="TOPModels.Skins.HostageTex3";
    class'TO_ModelHandler'.Default.Skin3[1]="TOPModels.Skins.TerrorTex3SWAT";
    class'TO_ModelHandler'.Default.Skin3[2]="TOPModels.Skins.TerrorTex3Urban";
    class'TO_ModelHandler'.Default.Skin3[3]="TOPModels.Skins.TerrorTex3Generic";
    class'TO_ModelHandler'.Default.Skin3[4]="TOPModels.Skins.TerrorTex3Wood";

    class'TO_ModelHandler'.Default.Skin4[0]="TOPModels.Skins.HostageTex4";
    class'TO_ModelHandler'.Default.Skin4[2]="TOPModels.Skins.TerrorTex4Urban";
    class'TO_ModelHandler'.Default.Skin4[3]="TOPModels.Skins.TerrorTex4Generic";
    class'TO_ModelHandler'.Default.Skin4[4]="TOPModels.Skins.TerrorTex4Wood";

    class'TO_ModelHandler'.Default.Skin5[2]="TOPModels.Skins.TerrorTex5";
    class'TO_ModelHandler'.Default.Skin5[3]="TOPModels.Skins.TerrorTex5";
    class'TO_ModelHandler'.Default.Skin5[4]="TOPModels.Skins.TerrorTex5";

    Class'TO_ModelHandler'.Default.ModelMesh[0]=SkeletalMesh'topmodels.Hostage';
    Class'TO_ModelHandler'.Default.ModelMesh[1]=SkeletalMesh'topmodels.Terror2';
    Class'TO_ModelHandler'.Default.ModelMesh[2]=SkeletalMesh'topmodels.Terror2';
    Class'TO_ModelHandler'.Default.ModelMesh[3]=SkeletalMesh'topmodels.Terror2';
    Class'TO_ModelHandler'.Default.ModelMesh[4]=SkeletalMesh'topmodels.Terror2';

    Class'TO_ModelHandler'.Default.ModelName[0]="Hostage";
    Class'TO_ModelHandler'.Default.ModelName[1]="SWAT light";
    Class'TO_ModelHandler'.Default.ModelName[2]="Urban Camo";
    Class'TO_ModelHandler'.Default.ModelName[3]="Urban Cargo";
    Class'TO_ModelHandler'.Default.ModelName[4]="WoodLand";

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
    local byte i;

    super.PreBeginPlay();
    Class'TO_ModelHandler'.Default.Skin0[0]="TOExtraModels.Skins.VisageBleu";
    Class'TO_ModelHandler'.Default.Skin1[0]="TOExtraModels.Skins.TenuVert";
    Class'TO_ModelHandler'.Default.ModelMesh[0]=LODMesh'TOExtraModels.Squirrel';
    Class'TO_ModelHandler'.Default.ModelName[0]="Sergent Nutz - Terrorist One";
    Class'TO_ModelHandler'.Default.ModelType[0]=MT_Terrorist;

    Class'TO_ModelHandler'.Default.Skin0[1]="TOExtraModels.Skins.VisageBleu";
    Class'TO_ModelHandler'.Default.Skin1[1]="TOExtraModels.Skins.TenuJaune";
    Class'TO_ModelHandler'.Default.ModelMesh[1]=LODMesh'TOExtraModels.Squirrel';
    Class'TO_ModelHandler'.Default.ModelName[1]="Sergent Nutz - Terrorist Two";
    Class'TO_ModelHandler'.Default.ModelType[1]=MT_Terrorist;

    Class'TO_ModelHandler'.Default.Skin0[2]="TOExtraModels.Skins.VisageMarron";
    Class'TO_ModelHandler'.Default.Skin1[2]="TOExtraModels.Skins.TenuNoir";
    Class'TO_ModelHandler'.Default.ModelMesh[2]=LODMesh'TOExtraModels.Squirrel';
    Class'TO_ModelHandler'.Default.ModelName[2]="Sergent Nutz - Special Force One";
    Class'TO_ModelHandler'.Default.ModelType[2]=MT_SpecialForces;

    Class'TO_ModelHandler'.Default.Skin0[3]="TOExtraModels.Skins.VisageMarron";
    Class'TO_ModelHandler'.Default.Skin1[3]="TOExtraModels.Skins.TenuBleu";
    Class'TO_ModelHandler'.Default.ModelMesh[3]=LODMesh'TOExtraModels.Squirrel';
    Class'TO_ModelHandler'.Default.ModelName[3]="Sergent Nutz - Special Force Two";
    Class'TO_ModelHandler'.Default.ModelType[3]=MT_SpecialForces;

    Class'TO_ModelHandler'.Default.Skin0[4]="TOExtraModels.Skins.VisageBleu";
    Class'TO_ModelHandler'.Default.Skin1[4]="TOExtraModels.Skins.TenuOtage";
    Class'TO_ModelHandler'.Default.ModelMesh[4]=LODMesh'TOExtraModels.Squirrel';
    Class'TO_ModelHandler'.Default.ModelName[4]="Sergent Nutz - Hostage";
    Class'TO_ModelHandler'.Default.ModelType[4]=MT_Hostage;

    for (i=5;i<19;i++)
        class'TO_ModelHandler'.Default.ModelType[i]=MT_None;
    SetTimer(1,true);
}

function ModifyLogin(out Class<PlayerPawn> SpawnClass,out string Portal,out string Options)
{
	if (SpawnClass==Class'S_Player_T')
		SpawnClass=Class'TOExtraSgtNutzPlayer';
	if (NextMutator!=None)
		NextMutator.ModifyLogin(SpawnClass,Portal,Options);
}

function Timer()
{
    if ((s_SWATGame(Level.Game).GamePeriod==GP_PreRound) && (s_SWATGame(Level.Game).RoundNumber!=CurrentRound))
    {
        CurrentRound=s_SWATGame(Level.Game).RoundNumber;
        SetNewSize();
    }
}

function SetNewSize()
{
    local Pawn P;

    for (P=Level.PawnList;P!=None;P=P.NextPawn)
        if ((P.IsA('s_Bot')) || (P.IsA('s_NPCHostage')))
            P.SetCollisionSize(44,42);
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    if ((Other.IsA('s_Bot')) || (Other.IsA('s_NPC')))
    {
        Other.SetCollisionSize(44,42);
        Other.DrawScale=1.250000;
    }
    return true;
}

defaultproperties
{
}

