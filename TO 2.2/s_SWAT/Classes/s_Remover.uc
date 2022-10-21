//=============================================================================
// s_Remover
//=============================================================================
//
// Tactical Ops
// - http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_Remover expands Info;


var		string	DestroyActor[32];	// actors being removed


///////////////////////////////////////
// BeginPlay
///////////////////////////////////////

simulated function BeginPlay()
{
	local	int	i;

	// list
	for (i=0; i<32; i++)
		if ( DestroyActor[i] != "" )
			DestroyClass( DestroyActor[i] );
	
	// Weapons
	for (i=0; i<=class'TOModels.TO_WeaponsHandler'.default.NumWeapons; i++)
		if ( class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i] != "" )
			DestroyClass( class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i] );

	Destroy();
}
 

///////////////////////////////////////
// DestroyClass
///////////////////////////////////////

final simulated function DestroyClass(string RemovedActor)
{
	local Actor					replaced, replacer, foundActor;
	local class<actor>	ReplacedClass, ReplacerClass;

	ReplacedClass = class<actor>(DynamicLoadObject( RemovedActor, class'Class' ) );

	if (ReplacedClass != None)
	{
/*
		foreach ChildActors(ReplacedClass, foundActor)
		{
			replaced = foundActor;
										
			if (replaced.IsA('Inventory') )
			{
				if ( Inventory(replaced).IsInState('Pickup') || !Inventory(replaced).bHeldItem )					
					if( !replaced.Destroy() )
						log("ERROR! Could not destroy "$replaced);
			}
			else if( !replaced.Destroy() )
				log("ERROR! Could not destroy "$replaced);
		}
*/
		foreach AllActors(ReplacedClass, foundActor)
		{						
			replaced = foundActor;
											
			if ( replaced.IsA('Inventory') )
			{
				if ( Inventory(replaced).IsInState('Pickup') || !Inventory(replaced).bHeldItem )	
					replaced.Destroy();
					//if( !replaced.Destroy() )
					//	log("ERROR! Could not destroy "$replaced);
			}
			else 
				replaced.Destroy();
				//if( !replaced.Destroy() )
				//log("s_Remover - ERROR! Could not destroy "$replaced);
		}
	}
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     DestroyActor(0)="s_SWAT.s_C4"
     DestroyActor(1)="s_SWAT.s_ExplosiveC4"
     DestroyActor(2)="s_SWAT.TO_KnifePickup"
     DestroyActor(3)="engine.carcass"
     DestroyActor(4)="s_SWAT.s_PlayerCarcass"
     DestroyActor(5)="s_SWAT.s_PlayerHead"
     DestroyActor(6)="s_SWAT.s_PlayerMasterChunks"
     DestroyActor(7)="s_SWAT.s_Projectile"
     DestroyActor(8)="BotPack.ut_SpriteSmokePuff"
     DestroyActor(10)="s_SWAT.s_MoneyPickup"
     DestroyActor(11)="s_SWAT.s_SpecialItemCocaine"
     DestroyActor(13)="s_SWAT.s_OICW"
     DestroyActor(14)="s_SWAT.s_Evidence"
     DestroyActor(15)="s_SWAT.s_MoneyPickUp"
     DestroyActor(16)="UnrealShare.FlockPawn"
     DestroyActor(17)="BotPack.UT_SpriteSmokePuff"
     DestroyActor(18)="s_SWAT.s_raindrop"
     DestroyActor(20)="s_SWAT.s_FlashBang"
     DestroyActor(21)="s_SWAT.s_Concussion"
     DestroyActor(22)="s_SWAT.TO_ProjSmokeGren"
     DestroyActor(23)="s_SWAT.s_GrenadeAway"
     DestroyActor(24)="BotPack.TMale2Carcass"
     DestroyActor(26)="s_SWAT.TO_BloodTrails"
     DestroyActor(27)="Botpack.UTMasterCreatureChunk"
     DestroyActor(28)="Botpack.UTHeads"
     DestroyActor(29)="s_SWAT.s_ThrowingKnife"
}
