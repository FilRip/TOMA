//=============================================================================
// raindrop
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000 Greg '[DM]Matryx' Sweetman
// Continued by Laurent "SHAG" Delayen
//=============================================================================

class s_raindrop expands Projectile;
 

///////////////////////////////////////
// FallingState 
///////////////////////////////////////

auto state FallingState
{

	simulated function Landed( vector HitNormal )
	{
		local waterring w;

		if (!Level.bDropDetail)
		{
			w = Spawn(class'WaterRing',,,,rotator(Hitnormal));
			if (w != None)
			{
				w.DrawScale = 0.05;
				w.RemoteRole = ROLE_None;
			}
		}

		Destroy();
	}

	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		Landed(Normal(HitLocation-Other.Location));
	}

	simulated function HitWall (vector HitNormal, actor Wall) 
	{
		Landed(HitNormal);
	}
	
	simulated function ZoneChange( Zoneinfo NewZone )
	{
		local waterring w;
		
		if (!NewZone.bWaterZone)
			return;
	
	if (!Level.bDropDetail)
		{
			w = Spawn(class'WaterRing',,,,rot(16384,0,0));
			if (w != None)
			{
				w.DrawScale = 0.05;
				w.RemoteRole = ROLE_None;
			}
		}
		Destroy();
	}

	simulated singular function touch(actor Other)
	{
		local waterring w;

		if (!Level.bDropDetail)
		{
			w = Spawn(class'WaterRing',,,,rot(16384,0,0));
			if (w != None)
			{
				w.DrawScale = 0.05;
				w.RemoteRole = ROLE_None;
			}
		}
		Destroy();
	}

	function BeginState()
	{
		if (Region.Zone.bWaterZone)
			destroy();
	}

}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     speed=3000.000000
     RemoteRole=ROLE_None
     LifeSpan=20.000000
     Texture=None
     Mesh=LodMesh'UnrealShare.dripMesh'
     DrawScale=0.500000
     Fatness=64
     bUnlit=True
     bGameRelevant=False
}
