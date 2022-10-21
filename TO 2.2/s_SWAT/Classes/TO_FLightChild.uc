//=============================================================================
// TO_FLightChild
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_FLightChild extends TO_FLight;

var float	Oldvdiff;


///////////////////////////////////////
// Tick 
///////////////////////////////////////

simulated function Tick(float DeltaTime)
{
	local vector X,Y,Z, StartTrace, EndTrace, HitLocation, HitNormal;
	local float Vdiff;
	local	Actor	HitActor;

	if (Owner != None && (Pawn(Owner) != None))
	{
		if (Pawn(Owner).Health < 1)
			Destroy();
		
		if ( Pawn(Owner).Weapon == None )
			return;

		GetAxes(Pawn(Owner).ViewRotation,X,Y,Z);
		StartTrace = Pawn(Owner).Location + Pawn(Owner).Weapon.CalcDrawOffset() /*Pawn(Owner).Eyeheight * Z + X*/;
		EndTrace = StartTrace + 10000 * X; 
		HitActor = Pawn(Owner).TraceShot(HitLocation, HitNormal, EndTrace, StartTrace);		
	
		Vdiff = VSize(StartTrace - HitLocation);

		HitLocation = HitLocation - vector(Pawn(Owner).ViewRotation) * 32 + HitNormal * 32;

		if ( Oldvdiff != Vdiff )
		{
			if (Vdiff > 2500)
			{
				LightBrightness = 0;
				LightRadius = 25;
			}
			else if (Vdiff < 200)
			{
				LightBrightness = 250;
				LightRadius = 4;			
			}
			else
			{
				LightBrightness = 255 * (2500 - VDiff) / 2300;
				LightRadius = 8 * (Vdiff / 400);
			}
		}
	}

	CheckFlashLight(HitLocation);
}
 

///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////
// NetUpdateFrequency=0.1

defaultproperties
{
     bOwnerNoSee=False
     bOnlyOwnerSee=True
     bNetOptional=True
     RemoteRole=ROLE_SimulatedProxy
     LightType=LT_None
     NetPriority=0.000000
}
