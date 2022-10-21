//=============================================================================
// s_M3
//=============================================================================
//
// Tactical Ops 
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class s_M3 extends s_Mossberg;
 

///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     DamageRadius=1.000000
     NumPellets=8
     MaxDamage=18.000000
     MaxClip=40
     RoundPerMin=110
     price=2000
     VRecoil=500.000000
     HRecoil=10.000000
     WeaponID=23
     MaxRange=1440.000000
     FireModes(0)=FM_FullAuto
     MuzScale=3.500000
     MuzX=591
     MuzY=449
     WeaponDescription="Classification: M3 Benelli Shotgun"
     AutoSwitchPriority=23
     PickupMessage="You picked up an M3 Benelli Shotgun!"
     ItemName="M3 Benelli Shotgun"
     PlayerViewMesh=LodMesh'TOModels.m3'
     PickupViewMesh=LodMesh'TOModels.pm3'
     ThirdPersonMesh=LodMesh'TOModels.wm3'
     Mesh=LodMesh'TOModels.pm3'
}
