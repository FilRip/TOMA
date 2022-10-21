//=============================================================================
// TO_SnowFlake
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000 Greg '[DM]Matryx' Sweetman
// Continued by Laurent "SHAG" Delayen
//=============================================================================

class TO_SnowFlake expands s_raindrop;

 
var int Jerkyness;
 

///////////////////////////////////////
// FallingState 
///////////////////////////////////////

auto state FallingState
{

	simulated function Landed( vector HitNormal )
	{
		Destroy();
	}

	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		Destroy();
		//Landed(Normal(HitLocation-Other.Location));
	}

	simulated function HitWall (vector HitNormal, actor Wall) 
	{
		Destroy();
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
		Destroy();
	}

	simulated function Timer() 
	{
		velocity.x += (FRand() - 0.5) * Jerkyness;
		velocity.y += (FRand() - 0.5) * Jerkyness;

		if ( Level.bDropDetail )
			SetTimer(1.5, false);
		else
			SetTimer(0.4, false);
//		velocity.z -= FRand() * Jerkyness * 4;
	}

Begin:
	if ( Jerkyness != 0 )
	{
		// randomize jerkyness
		SetTimer(FRand()+FRand(), false);
	}
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     speed=2000.000000
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=Texture'TODatas.Engine.SnowFlake'
     Mesh=None
     ScaleGlow=0.750000
}
