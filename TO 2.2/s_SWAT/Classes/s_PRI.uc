//=============================================================================
// s_PRI
//=============================================================================
//
// Tactical Ops
// - http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_PRI extends	Actor;

var		Pawn		PawnOwner;
var		int			OldHealth;
var		float		dtime, dtimeadjust, Scale;
 

///////////////////////////////////////
// PostBeginPlay
///////////////////////////////////////

function	PostBeginPlay()
{
	OldHealth = 0;
	PawnOwner = Pawn(Owner);
	SetTimer(FRand() * 4.0, false);
}


///////////////////////////////////////
// SetNextSplat
///////////////////////////////////////

final function	SetNextSplat()
{
	local	float	dtime;

	if ( OldHealth != PawnOwner.Health )
	{
		OldHealth = PawnOwner.Health;
		dtime = float(PawnOwner.Health) / 100.0;

		if ( Level.bHighDetailMode )
			dtimeadjust *= 1.5;
		else
			dtimeadjust *= 3.0;

		if ( dtimeadjust < 0.5 )
			dtimeadjust = 0.5;

		Scale = 1.0 - dtime / 2.0;
	}

	SpawnBloodSplat(Scale);

	SetTimer(dtimeadjust, false);
}


///////////////////////////////////////
// Timer
///////////////////////////////////////

function Timer()
{
	if ( PawnOwner == None )
	{
		//log("s_PRI - Timer - PawnOwner == None");
		destroy();
	}

	//log("s_PRI::Timer - T:"@Level.TimeSeconds@"Self:"@Self@"Owner:"@Owner);

	if ( (PawnOwner.Health > 80) || (PawnOwner.Health < 1) || Level.bDropDetail )
	{
		SetTimer(4.0, false);
		return;
	}

	SetNextSplat();
}


///////////////////////////////////////
// SpawnBloodSplat
///////////////////////////////////////

final function SpawnBloodSplat(float	Scale)
{
	local	TO_BloodTrails	BT;

	BT = spawn(class'TO_BloodTrails', Owner,, Owner.Location, Owner.Rotation);
	BT.SpawnBloodSplat(Scale);
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     bHidden=True
     bAlwaysTick=True
     RemoteRole=ROLE_None
     DrawType=DT_None
     Texture=None
}
