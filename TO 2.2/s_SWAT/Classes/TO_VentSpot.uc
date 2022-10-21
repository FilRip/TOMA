//=============================================================================
// TO_VentSpot
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================
 
class TO_VentSpot extends NavigationPoint;

var Bot PendingBot;


///////////////////////////////////////
// SpecialCost 
///////////////////////////////////////

event int SpecialCost(Pawn Seeker)
{
	local Bot B;

	B = Bot(Seeker);
	if (B == None)
		return 100000000;

	return 100000000;
}


///////////////////////////////////////
// SpecialHandling 
///////////////////////////////////////
/* SpecialHandling is called by the navigation code when the next path has been found.  
It gives that path an opportunity to modify the result based on any special considerations
*/
function Actor SpecialHandling(Pawn Other)
{
	local Bot B;

	if (!Other.IsA('Bot'))
		return None;

	PendingBot = B;
	GotoState('PendingCrouch');

	return self;
}


///////////////////////////////////////
// PendingCrouch 
///////////////////////////////////////
// don't do crouches right away because a state change here could be dangerous during navigation
State PendingCrouch
{
	function Actor SpecialHandling(Pawn Other)
	{
		if (PendingBot != None)
		{
			PendingBot.PlayDuck();
			PendingBot.SetCollisionSize(PendingBot.Default.CollisionRadius, PendingBot.CollisionHeight * PendingBot.Default.CollisionHeight * 0.5);
			PendingBot.bViewTarget = True;
			PendingBot = None;
		}
		return Super.SpecialHandling(Other);
	}

	function Tick(float DeltaTime)
	{
		if (PendingBot != None)
		{
			PendingBot.PlayDuck();
			PendingBot.SetCollisionSize(PendingBot.Default.CollisionRadius, PendingBot.CollisionHeight * PendingBot.Default.CollisionHeight * 0.5);
			PendingBot.bViewTarget = True;
			PendingBot = None;
		}
		GotoState('');
	}
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     bSpecialCost=True
}
