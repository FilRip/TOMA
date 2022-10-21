//=============================================================================
// s_NPCHostage_M2
//=============================================================================
//
// Tactical Ops -- an Unreal Tournament modification
// -- http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_NPCHostage_M2 extends s_NPCHostage_Anim;
 

///////////////////////////////////////
// defaultproperties
///////////////////////////////////////
/*
   SelectionMesh="Botpack.SelectionMale2"
     SpecialMesh="Botpack.TrophyMale2"
     MenuName="Male Soldier"
     VoiceType="BotPack.VoiceMaleTwo"

	    CarcassType=Class'Botpack.TMale1Carcass'
     DefaultSkinName="SoldierSkins.blkt"
     DefaultPackage="SoldierSkins."
  
     Mesh=LodMesh'Botpack.Commando'
*/

defaultproperties
{
     CarcassType=Class's_SWAT.s_PlayerCarcass'
     DefaultSkinName=""
     DefaultPackage=""
     VoicePackMetaClass="BotPack.VoiceFemale"
     Mesh=SkeletalMesh'TOPModels.HostageMesh'
}
