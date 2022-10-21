//=============================================================================
// TO_LadderEnd
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class TO_LadderEnd extends NavigationPoint;

var() config bool bPosition; // True == Top, False == Bottom


///////////////////////////////////////
// Touch 
///////////////////////////////////////

simulated event Touch(Actor Other)
{
	local s_Bot ClimbingBot;
		
	ClimbingBot = s_Bot(Other);
	if (ClimbingBot == None)
		return;
	
	if (ClimbingBot.byteClimbDir == 0)
	{
		if (bPosition)
			ClimbingBot.byteClimbDir = 2;
		else
			ClimbingBot.byteClimbDir = 1;
	}
	else
	{	
		ClimbingBot.byteClimbDir = 0;
		ClimbingBot.bCanFly = False;
		ClimbingBot.SetPhysics(PHYS_Walking);
	}
}


///////////////////////////////////////
// UnTouch 
///////////////////////////////////////

simulated event UnTouch(Actor Other)
{
	local s_Bot ClimbingBot;
		
	ClimbingBot = s_Bot(Other);
	if (ClimbingBot == None)
		return;
		
	if (!ClimbingBot.MoveTarget.IsA('TO_Ladder') || !ClimbingBot.MoveTarget.IsA('TO_LadderEnd'))
	{
		ClimbingBot.byteClimbDir = 0;
		if (ClimbingBot.bCanFly)
		{
			ClimbingBot.bCanFly = False;
			ClimbingBot.SetPhysics(PHYS_Walking);
		}	
	}
}

 
///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     bPosition=True
}
