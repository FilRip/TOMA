class TGAS_main expands mutator config;

var config Bool Improved_Flashbangs;
var config Bool Movement_Decrease;
var config Bool Impact_Reactions;
var config bool Sniper_Skills;
var config bool Teargas_nades;
var config bool Nade_Timers;
var config byte Clientside_Trace_Freq;
var config byte Clientside_thermal_prefference;
var config bool TeargasMutatorEnabled;
var config bool Inventory_Weights;
var Bool nadetimer;
var Bool ImprovedFB;
var Bool MoveDecrease;
var Bool ImpactReaction;
var bool SniperSkills;
var bool Tearnades;
var bool InvWeights;

replication
{
    reliable if ( Role == ROLE_Authority )
        ImprovedFB, MoveDecrease, ImpactReaction, SniperSkills,Tearnades,InvWeights,nadetimer;
}

function Destroyed()
{
 if (TeargasMutatorEnabled)
   {
   if (Tearnades)
	{
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[25] = "";
	class'TOModels.TO_WeaponsHandler'.default.WeaponName[25] = "";
	class'TOModels.TO_WeaponsHandler'.default.BotDesirability[25] = 0.10;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[25] = WT_none;
	class'TOModels.TO_WeaponsHandler'.default.NumWeapons -= 1;
	}
   if (Nadetimer)
	{
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[12] = "s_SWAT.TO_Grenade";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[13] = "s_SWAT.s_GrenadeFB";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[14] = "s_SWAT.s_GrenadeConc";
	}
   }
 super.destroyed();
}

function PreBeginPlay()
{
 if ( Level.Netmode == NM_Client)
	return;
 Nadetimer = Nade_Timers;
 ImprovedFB = Improved_Flashbangs;
 MoveDecrease = Movement_Decrease;
 ImpactReaction = Impact_Reactions;
 SniperSkills = Sniper_Skills;
 Tearnades = Teargas_nades;
 InvWeights = Inventory_Weights;
 Super.PreBeginPlay();
}

function BeginPlay()
{
 local TGAS_PlyNotify p;

 if ( Level.Netmode == NM_Client )
	return;
 if (!TeargasMutatorEnabled)
	Return;

 p=spawn (Class'TGAS_PlyNotify');
 p.tgmut = self;
 if (Tearnades)
 {
 class'TOModels.TO_WeaponsHandler'.default.NumWeapons += 1;
 class'TOModels.TO_WeaponsHandler'.default.WeaponStr[25] = "teargas3.TGAS_Grenadegas";
 class'TOModels.TO_WeaponsHandler'.default.WeaponName[25] = "Tear Gas Grenade";
 class'TOModels.TO_WeaponsHandler'.default.BotDesirability[25] = 0.10;
 class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[25] = WT_SpecialForces;
 }
 if (Nadetimer)
 {
 class'TOModels.TO_WeaponsHandler'.default.WeaponStr[12] = "teargas3.NADE_TOgrenade";
 class'TOModels.TO_WeaponsHandler'.default.WeaponStr[13] = "teargas3.NADE_GrenadeFB";
 class'TOModels.TO_WeaponsHandler'.default.WeaponStr[14] = "teargas3.NADE_grenadeconc";
 }
 class'TOPModels.TO_modelHandler'.default.Skin0[19] = "TOPModels.Skins.TerrorTex0SWAT";
 class'TOPModels.TO_modelHandler'.default.Skin1[19] = "TOPModels.Skins.TerrorTex1SWAT";
 class'TOPModels.TO_modelHandler'.default.Skin2[19] = "TOPModels.Skins.TerrorTex2SWAT";
 class'TOPModels.TO_modelHandler'.default.Skin3[19] = "TOPModels.Skins.TerrorTex3SWAT";
 class'TOPModels.TO_modelHandler'.default.Skin4[19] = "teargas3.special.tgasface";
 class'TOPModels.TO_modelHandler'.default.Skin5[19] = "TOPModels.Skins.SFTex5";
 class'TOPModels.TO_modelHandler'.default.modelmesh[19] = SkeletalMesh'Terror2';
 class'TOPModels.TO_modelHandler'.default.modeltype[19] = MT_SpecialForces;
 class'TOPModels.TO_modelHandler'.default.modelname[19] = "Swat gasmask";

 class'TOPModels.TO_modelHandler'.default.Skin0[20] = "teargas3.special.tgasface";
 class'TOPModels.TO_modelHandler'.default.Skin1[20] = "TOPModels.Skins.SealTex1P";
 class'TOPModels.TO_modelHandler'.default.Skin2[20] = "TOPModels.Skins.SealTex2P";
 class'TOPModels.TO_modelHandler'.default.Skin3[20] = "TOPModels.Skins.SealTex3P";
 class'TOPModels.TO_modelHandler'.default.Skin4[20] = "TOPModels.Skins.SealTex4P";
 class'TOPModels.TO_modelHandler'.default.Skin5[20] = "TOPModels.Skins.SealTex5P";
 class'TOPModels.TO_modelHandler'.default.Skin6[20] = "TOPModels.Skins.SFTex5";
 class'TOPModels.TO_modelHandler'.default.modelmesh[20] = SkeletalMesh'Seal';
 class'TOPModels.TO_modelHandler'.default.modeltype[20] = MT_SpecialForces;
 class'TOPModels.TO_modelHandler'.default.modelname[20] = "Police gasmask";

 class'TOPModels.TO_modelHandler'.default.Skin0[21] = "teargas3.special.tgasface";
 class'TOPModels.TO_modelHandler'.default.Skin1[21] = "TOPModels.Skins.SealTex1";
 class'TOPModels.TO_modelHandler'.default.Skin2[21] = "TOPModels.Skins.SealTex2";
 class'TOPModels.TO_modelHandler'.default.Skin3[21] = "TOPModels.Skins.SealTex3";
 class'TOPModels.TO_modelHandler'.default.Skin4[21] = "TOPModels.Skins.SealTex4";
 class'TOPModels.TO_modelHandler'.default.Skin5[21] = "TOPModels.Skins.SealTex5";
 class'TOPModels.TO_modelHandler'.default.Skin6[21] = "TOPModels.Skins.SFTex5";
 class'TOPModels.TO_modelHandler'.default.modelmesh[21] = SkeletalMesh'Seal';
 class'TOPModels.TO_modelHandler'.default.modeltype[21] = MT_SpecialForces;
 class'TOPModels.TO_modelHandler'.default.modelname[21] = "Seal gasmask";

 class'TOPModels.TO_modelHandler'.default.Skin0[22] = "TOPModels.Skins.JillTex0P";
 class'TOPModels.TO_modelHandler'.default.Skin1[22] = "TOPModels.Skins.JillTex1P";
 class'TOPModels.TO_modelHandler'.default.Skin2[22] = "TOPModels.Skins.JillTex2P";
 class'TOPModels.TO_modelHandler'.default.Skin3[22] = "TOPModels.Skins.JillTex3P";
 class'TOPModels.TO_modelHandler'.default.Skin4[22] = "teargas3.special.jgasface";
 class'TOPModels.TO_modelHandler'.default.Skin5[22] = "TOPModels.Skins.SFTex5";
 class'TOPModels.TO_modelHandler'.default.bFemale[22] = 1;
 class'TOPModels.TO_modelHandler'.default.modelmesh[22] = SkeletalMesh'Jill';
 class'TOPModels.TO_modelHandler'.default.modeltype[22] = MT_SpecialForces;
 class'TOPModels.TO_modelHandler'.default.modelname[22] = "Police female gasmask";

 class'TOPModels.TO_modelHandler'.default.Skin0[23] = "TOPModels.Skins.JillTex0S";
 class'TOPModels.TO_modelHandler'.default.Skin1[23] = "TOPModels.Skins.JillTex1S";
 class'TOPModels.TO_modelHandler'.default.Skin2[23] = "TOPModels.Skins.JillTex2S";
 class'TOPModels.TO_modelHandler'.default.Skin3[23] = "TOPModels.Skins.JillTex3S";
 class'TOPModels.TO_modelHandler'.default.Skin4[23] = "teargas3.special.jgasface";
 class'TOPModels.TO_modelHandler'.default.Skin5[23] = "TOPModels.Skins.SFTex5";
 class'TOPModels.TO_modelHandler'.default.bFemale[23] = 1;
 class'TOPModels.TO_modelHandler'.default.modelmesh[23] = SkeletalMesh'Jill';
 class'TOPModels.TO_modelHandler'.default.modeltype[23] = MT_SpecialForces;
 class'TOPModels.TO_modelHandler'.default.modelname[23] = "Swat female gasmask";

 class'TOPModels.TO_modelHandler'.default.Skin0[24] = "TOPModels.Skins.TerrorTex0Urban";
 class'TOPModels.TO_modelHandler'.default.Skin1[24] = "TOPModels.Skins.TerrorTex1Urban";
 class'TOPModels.TO_modelHandler'.default.Skin2[24] = "TOPModels.Skins.TerrorTex2Urban";
 class'TOPModels.TO_modelHandler'.default.Skin3[24] = "TOPModels.Skins.TerrorTex3Urban";
 class'TOPModels.TO_modelHandler'.default.Skin4[24] = "teargas3.special.tgasface";
 class'TOPModels.TO_modelHandler'.default.Skin5[24] = "TOPModels.Skins.TerrorTex5";
 class'TOPModels.TO_modelHandler'.default.modelmesh[24] = SkeletalMesh'Terror2';
 class'TOPModels.TO_modelHandler'.default.modeltype[24] = MT_Terrorist;
 class'TOPModels.TO_modelHandler'.default.modelname[24] = "Urban Camo gasmask";

 class'TOPModels.TO_modelHandler'.default.Skin0[25] = "TOPModels.Skins.TerrorTex0AB";
 class'TOPModels.TO_modelHandler'.default.Skin1[25] = "TOPModels.Skins.TerrorTex1AB";
 class'TOPModels.TO_modelHandler'.default.Skin2[25] = "TOPModels.Skins.TerrorTex2AB";
 class'TOPModels.TO_modelHandler'.default.Skin3[25] = "TOPModels.Skins.TerrorTex3AB";
 class'TOPModels.TO_modelHandler'.default.Skin4[25] = "teargas3.special.tgasface";
 class'TOPModels.TO_modelHandler'.default.Skin5[25] = "TOPModels.Skins.TerrorTex5";
 class'TOPModels.TO_modelHandler'.default.Skin6[25] = "TOPModels.Skins.TerrorTex6AB";
 class'TOPModels.TO_modelHandler'.default.modelmesh[25] = SkeletalMesh'TerrorBelt';
 class'TOPModels.TO_modelHandler'.default.modeltype[25] = MT_Terrorist;
 class'TOPModels.TO_modelHandler'.default.modelname[25] = "Red leader gasmask";

 class'TOPModels.TO_modelHandler'.default.Skin0[26] = "TOPModels.Skins.TerrorTex0Wood";
 class'TOPModels.TO_modelHandler'.default.Skin1[26] = "TOPModels.Skins.TerrorTex1Wood";
 class'TOPModels.TO_modelHandler'.default.Skin2[26] = "TOPModels.Skins.TerrorTex2Wood";
 class'TOPModels.TO_modelHandler'.default.Skin3[26] = "TOPModels.Skins.TerrorTex3Wood";
 class'TOPModels.TO_modelHandler'.default.Skin4[26] = "teargas3.special.tgasface";
 class'TOPModels.TO_modelHandler'.default.Skin5[26] = "TOPModels.Skins.TerrorTex5";
 class'TOPModels.TO_modelHandler'.default.modelmesh[26] = SkeletalMesh'Terror2';
 class'TOPModels.TO_modelHandler'.default.modeltype[26] = MT_Terrorist;
 class'TOPModels.TO_modelHandler'.default.modelname[26] = "Woodland gasmask";

 class'TOPModels.TO_modelHandler'.default.Skin0[27] = "TOPModels.Skins.TerrorTex0L";
 class'TOPModels.TO_modelHandler'.default.Skin1[27] = "TOPModels.Skins.TerrorTex1L";
 class'TOPModels.TO_modelHandler'.default.Skin2[27] = "TOPModels.Skins.TerrorTex2L";
 class'TOPModels.TO_modelHandler'.default.Skin3[27] = "TOPModels.Skins.TerrorTex3L";
 class'TOPModels.TO_modelHandler'.default.Skin4[27] = "teargas3.special.tgasface";
 class'TOPModels.TO_modelHandler'.default.Skin5[27] = "TOPModels.Skins.TerrorTex5";
 class'TOPModels.TO_modelHandler'.default.modelmesh[27] = SkeletalMesh'Terror2';
 class'TOPModels.TO_modelHandler'.default.modeltype[27] = MT_Terrorist;
 class'TOPModels.TO_modelHandler'.default.modelname[27] = "Urban gang gasmask";

 class'TOPModels.TO_modelHandler'.default.Skin0[28] = "TOPModels.Skins.JillTex0T";
 class'TOPModels.TO_modelHandler'.default.Skin1[28] = "TOPModels.Skins.JillTex1T";
 class'TOPModels.TO_modelHandler'.default.Skin2[28] = "TOPModels.Skins.JillTex2T";
 class'TOPModels.TO_modelHandler'.default.Skin3[28] = "TOPModels.Skins.JillTex3T";
 class'TOPModels.TO_modelHandler'.default.Skin4[28] = "teargas3.special.jgasface";
 class'TOPModels.TO_modelHandler'.default.Skin5[28] = "TOPModels.Skins.TerrorTex5";
 class'TOPModels.TO_modelHandler'.default.modelmesh[28] = SkeletalMesh'Jill';
 class'TOPModels.TO_modelHandler'.default.modeltype[28] = MT_Terrorist;
 class'TOPModels.TO_modelHandler'.default.modelname[28] = "Forza armada gasmask";
 class'TOPModels.TO_modelHandler'.default.bFemale[28] = 1;

 class'TOPModels.TO_modelHandler'.default.Skin0[29] = "TOPModels.Skins.TerrorTex0A";
 class'TOPModels.TO_modelHandler'.default.Skin1[29] = "TOPModels.Skins.TerrorTex1A";
 class'TOPModels.TO_modelHandler'.default.Skin2[29] = "TOPModels.Skins.TerrorTex2A";
 class'TOPModels.TO_modelHandler'.default.Skin3[29] = "TOPModels.Skins.TerrorTex3A";
 class'TOPModels.TO_modelHandler'.default.Skin4[29] = "teargas3.special.tgasface";
 class'TOPModels.TO_modelHandler'.default.Skin5[29] = "TOPModels.Skins.TerrorTex5";
 class'TOPModels.TO_modelHandler'.default.modelmesh[29] = SkeletalMesh'Terror2';
 class'TOPModels.TO_modelHandler'.default.modeltype[29] = MT_Terrorist;
 class'TOPModels.TO_modelHandler'.default.modelname[29] = "Arctic gasmask";

 class'TOPModels.TO_modelHandler'.default.Skin0[30] = "TOPModels.Skins.JillTex0A";
 class'TOPModels.TO_modelHandler'.default.Skin1[30] = "TOPModels.Skins.JillTex1A";
 class'TOPModels.TO_modelHandler'.default.Skin2[30] = "TOPModels.Skins.JillTex2A";
 class'TOPModels.TO_modelHandler'.default.Skin3[30] = "TOPModels.Skins.JillTex3A";
 class'TOPModels.TO_modelHandler'.default.Skin4[30] = "teargas3.special.jgasface";
 class'TOPModels.TO_modelHandler'.default.Skin5[30] = "TOPModels.Skins.TerrorTex5";
 class'TOPModels.TO_modelHandler'.default.modelmesh[30] = SkeletalMesh'Jill';
 class'TOPModels.TO_modelHandler'.default.modeltype[30] = MT_Terrorist;
 class'TOPModels.TO_modelHandler'.default.modelname[30] = "Arctic female gasmask";
 class'TOPModels.TO_modelHandler'.default.bFemale[30] = 1;

	SaveConfig();
 log ("Teargas mutator loaded");
}

function ModifyLogin(out class<playerpawn> SpawnClass, out string Portal, out string Options)
{
  if (TeargasMutatorEnabled)
   {
   //   log ("Teargas mutator  - player logging in with class: "$Spawnclass);
   If (SpawnClass == class's_Swat.s_player_T')
    	spawnclass = class'TGAS_player';
   If (SpawnClass == class'MA_player')
    	spawnclass = class'TGAS_player_MA';
   }

   if ( NextMutator != None )
	NextMutator.ModifyLogin(SpawnClass, Portal, Options);
}

function bool HandleEndGame()
{
	SaveConfig();
}

defaultproperties
{
    Improved_Flashbangs=True
    Movement_Decrease=True
    Impact_Reactions=True
    Sniper_Skills=True
    Teargas_nades=True
    Clientside_Trace_Freq=6
    TeargasMutatorEnabled=True
    Inventory_Weights=True
    bAlwaysRelevant=True
}
