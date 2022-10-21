//=============================================================================
// TO_FLight
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

//class TO_FLight extends Projectile;
class TO_FLight extends Actor;


var		TO_FLight		FlashLight;

/*
simulated singular function Touch(Actor Other) {}
simulated function HitWall (vector HitNormal, actor Wall) {}
simulated function Explode(vector HitLocation, vector HitNormal) {}
*/

///////////////////////////////////////
// BeginPlay 
///////////////////////////////////////

function BeginPlay()
{
	Super.BeginPlay();

	if (Role == Role_Authority)
		SetTimer(2.0, true);
}


///////////////////////////////////////
// Destroyed 
///////////////////////////////////////

simulated event Destroyed()
{
	bHidden = true;
	if ( FlashLight != None )
		FlashLight.Destroy();

	Super.Destroyed();
}


///////////////////////////////////////
// Timer 
///////////////////////////////////////

function Timer()
{
	MakeNoise(1.0);
}


///////////////////////////////////////
// CheckFlashLight 
///////////////////////////////////////

final simulated function CheckFlashLight(vector HitLocation)
{
	//SetLocation(HitLocation - vector(Instigator.ViewRotation) * 32 + HitNormal * 32);	
	SetLocation(HitLocation);	

	if ( (Role == ROLE_Authority) && (FlashLight == None) )
		FlashLight = Spawn(class'TO_FLight', Owner, , HitLocation); 

	// Updating server LaserDot
	if (FlashLight != None)
	{
		FlashLight.SetLocation(HitLocation);
		FlashLight.LightBrightness = LightBrightness;
		FlashLight.LightRadius = LightRadius;
	}

}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     bOwnerNoSee=True
     bReplicateInstigator=True
     DrawType=DT_None
     bUnlit=True
     LightType=LT_Steady
     LightBrightness=255
     LightHue=160
     LightSaturation=200
     LightRadius=9
     NetPriority=1.800000
}
