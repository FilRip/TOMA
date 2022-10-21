//=============================================================================
// s_LaserDotChild
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class s_LaserDotChild extends s_LaserDot;

 
var float	Oldvdiff;


///////////////////////////////////////
// Tick 
///////////////////////////////////////

simulated function Tick(float DeltaTime)
{
	local vector X,Y,Z, StartTrace, EndTrace, HitLocation, HitNormal;
	local float Vdiff;
	local	Actor	HitActor;

	if ( Instigator != None )
	{
		if ( Instigator.Health < 1 )
			Destroy();
		
		if ( Instigator.Weapon == None )
			return;

		GetAxes(Instigator.ViewRotation,X,Y,Z);
		StartTrace = Instigator.Location + Instigator.Weapon.CalcDrawOffset() /*+ Instigator.Eyeheight * Z + X*/;
		EndTrace = StartTrace + 10000 * X; 
		HitActor = Instigator.TraceShot(HitLocation, HitNormal, EndTrace, StartTrace);		
	
		//HitLocation = HitLocation - vector(Instigator.ViewRotation) * 8/* + HitNormal * 4*/;
		Vdiff = VSize(StartTrace - HitLocation);
		if ( Oldvdiff != Vdiff )
		{
			if (Vdiff > 480)
				DrawScale = 0.2000000;
			else if (VDiff > 240)
				DrawScale = 0.1500000;
			else if (VDiff > 120)
				DrawScale = 0.1000000;
			else
				DrawScale = 0.0500000;
		}
	}

	//log("ST:"@StartTrace@"HL:"@HitLocation@"HN:"@HitNormal@"diff:"@(HitLocation-StartTrace));
	CheckLaser(HitLocation - HitNormal);
}
 

///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////
// NetUpdateFrequency=0.1
// NetPriority=0.000000

defaultproperties
{
     bOwnerNoSee=False
     bOnlyOwnerSee=True
     RemoteRole=ROLE_SimulatedProxy
}
