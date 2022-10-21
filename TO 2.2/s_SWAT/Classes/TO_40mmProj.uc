//=============================================================================
// TO_40mmProj
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_40mmProj expands TO_20mmHE;


///////////////////////////////////////
// Flying 
///////////////////////////////////////

auto state Flying
{
	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		local TO_GrenadeExplosion s;
		local int i;
		local s_ConcussionChunk C;

		for (i=0; i < 10; i++)
		{
			C = Spawn(class's_ConcussionChunk',,,Location,);
			C.DrawScale *= 0.5;
			C.RemoteRole = ROLE_None;
		}

		s = spawn(class'TO_ExplConc',,, HitLocation + HitNormal * 16);
 		s.RemoteRole = ROLE_None;

		bHidden = true;
 		Destroy();
	}
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     bSmoke=False
     speed=1000.000000
     DrawScale=0.015000
}
