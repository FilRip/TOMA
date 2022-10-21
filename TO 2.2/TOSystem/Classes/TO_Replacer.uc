//=============================================================================
// TO_Replacer.
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================
 
class TO_Replacer expands Info
		config(TO_Replacer);

var					string	ReplacedActor[32];	// actors being replaced

var	config	byte		ReplaceIndex[32];
var config  bool		bRand;
var					byte		maxweapons;


///////////////////////////////////////
// BeginPlay
///////////////////////////////////////

function BeginPlay()
{
	local Actor replaced, replacer, foundActor;
	local class<actor> ReplacedClass, ReplacerClass;
	local byte i, k, j, inc;
	local vector X,Y,Z, RLocation;
	local	rotator	RRotation;
	
	maxweapons = class'TOModels.TO_WeaponsHandler'.default.NumWeapons;
	if ( bRand )
	{
		k = Rand(maxweapons);
		inc = Rand(5) + 1;
	}

	for (i=0; i<32; i++)
		if (ReplacedActor[i] != "")
		{
			ReplacedClass = class<actor>(DynamicLoadObject( ReplacedActor[i], class'Class' ));

			if ( ReplacedClass != None )
			{
				foreach AllActors(ReplacedClass, foundActor)
				{
					if ( foundActor.class != ReplacedClass )
						continue;
						
					replaced = foundActor;
					GetAxes(replaced.Rotation,X,Y,Z);	

					if ( bRand )
					{
						k += inc;
						if ( k > maxweapons )
							k = k % inc;
					}
					else
						k = ReplaceIndex[i];

					RLocation = replaced.Location;
					RRotation = replaced.Rotation;

					if ( replaced.IsA('Inventory') && Inventory(replaced).MyMarker != None )
					{
						if ( replacer != none )
						{
							Inventory(replaced).MyMarker.markedItem = Inventory(replacer);

							if ( Inventory(replacer) != None )
								Inventory(replacer).MyMarker = Inventory(replaced).MyMarker;
						}
						Inventory(replaced).MyMarker = None;
					}										

					if( !replaced.Destroy() )
						log("ERROR! Could not destroy "$replaced);


					if ( class'TOModels.TO_WeaponsHandler'.default.WeaponStr[k] != "" )
					{
						// force Unreal to load external packages
						ReplacerClass = class<actor>( DynamicLoadObject( class'TOModels.TO_WeaponsHandler'.default.WeaponStr[k], class'Class' ) );
						if ( ReplacerClass != None )
						{
							replacer = Spawn( ReplacerClass ,,, RLocation + Vect(0,0,5), RRotation );
							replacer.SetCollision(true); // prevent things falling out of world
							/*
							if ( replacer.IsA('Weapon') )
							{
								Weapon(replacer).InventoryGroup = Weapon(replaced).InventoryGroup;
								//if ( Replacer.IsA('s_Weapon') && s_Weapon(Replacer).bUseClip )
								//	s_Weapon(Replacer).RemainingClip = s_Weapon(Replacer).MaxClip;
							}
							*/
						}
					}
					

				}

			}
		}
			
	Destroy();
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     ReplacedActor(0)="Botpack.Enforcer"
     ReplacedActor(1)="Botpack.UT_BioRifle"
     ReplacedActor(2)="Botpack.ShockRifle"
     ReplacedActor(3)="Botpack.PulseGun"
     ReplacedActor(4)="Botpack.Ripper"
     ReplacedActor(5)="Botpack.Minigun2"
     ReplacedActor(6)="Botpack.UT_FlakCannon"
     ReplacedActor(7)="Botpack.UT_Eightball"
     ReplacedActor(8)="Botpack.SniperRifle"
     ReplacedActor(9)="Botpack.WarheadLauncher"
}
