//=============================================================================
// TO_Ladder
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================
//
// Place the TO_Ladder actor in the middle of your ladder shape in the map.
// Set the [CollisionRadius] and [CollisionHeight] to cover the whole ladder shape.
// Set Actors->Radii view on the viewport properties to view the ladder collision cylinder.

//class TO_Ladder extends TacticalOpsMapActors;
class TO_Ladder extends NavigationPoint;

var Bot PendingBot;

var() config name LadderTopTag;
var() config name LadderBottomTag;

var TO_LadderEnd LadderTop;
var TO_LadderEnd LadderBottom;


///////////////////////////////////////
// PostBeginPlay 
///////////////////////////////////////

function PostBeginPlay()
{
	if ( LadderTopTag != '' )
		ForEach AllActors(Class'TO_LadderEnd', LadderTop, LadderTopTag)
			break;
		
	if ( LadderBottomTag != '' )
		ForEach AllActors(Class'TO_LadderEnd', LadderBottom, LadderBottomTag)
			break;

	Super.PostBeginPlay();
}

/*
///////////////////////////////////////
// SpecialCost 
///////////////////////////////////////

event int SpecialCost(Pawn Seeker)
{
	if (Bot(Seeker) != None)
		return 100000000;
}


///////////////////////////////////////
// SpecialHandling 
///////////////////////////////////////
// SpecialHandling is called by the navigation code when the next path has been found.  
//It gives that path an opportunity to modify the result based on any special considerations

function Actor SpecialHandling(Pawn Other)
{
	if (!Other.IsA('Bot') && ((LadderTop == None) || (LadderBottom == None)))
		return None;

	PendingBot = Bot(Other);
	GotoState('PendingClimb');

	return self;
}


///////////////////////////////////////
// PendingClimb 
///////////////////////////////////////
// don't do climbing right away because a state change here could be dangerous during navigation
State PendingClimb
{
	function Actor SpecialHandling(Pawn Other)
	{
		local s_Bot ClimbingBot;
		
		ClimbingBot = s_Bot(PendingBot);
		if ((ClimbingBot != None) && (LadderBottom != None) && (LadderTop != None))
		{			
			ClimbingBot.bCanFly = True;

			ClimbingBot.SetPhysics(PHYS_Flying);
			if (!ClimbingBot.IsAnimating())  
				ClimbingBot.PlayWalking();
				
			if (ClimbingBot.byteClimbDir == 1)
				ClimbingBot.MoveTarget = LadderBottom;
			else if (ClimbingBot.byteClimbDir == 2)
				ClimbingBot.MoveTarget = LadderTop;
			ClimbingBot.byteClimbDir = 0;
							
			PendingBot = None;
		}
		
		return Super.SpecialHandling(Other);
	}

	function Tick(float DeltaTime)
	{
		local s_Bot ClimbingBot;
		
		ClimbingBot = s_Bot(PendingBot);
		if ((ClimbingBot != None) && (LadderBottom != None) && (LadderTop != None))
		{				
			ClimbingBot.bCanFly = True;

			ClimbingBot.SetPhysics(PHYS_Flying);
			if (!ClimbingBot.IsAnimating()) 
				ClimbingBot.PlayWalking();
				
			if (ClimbingBot.byteClimbDir == 1)
				ClimbingBot.MoveTarget = LadderBottom;
			else if (ClimbingBot.byteClimbDir == 2)
				ClimbingBot.MoveTarget = LadderTop;
			ClimbingBot.byteClimbDir = 0;
							
			PendingBot = None;
		}
		GotoState('');
	}
}
*/


/*
///////////////////////////////////////
// Touch 
///////////////////////////////////////

simulated event Touch( Actor Other )
{
	local s_Player			P;
	
	if ( Role != Role_Authority )
		return;

	P = s_Player(Other);
	if ( P != None )
	{
		if ( P.GetStateName() != 'Climbing' )
			P.GotoState('Climbing');
		P.CalculateWeight();
	}
}


///////////////////////////////////////
// UnTouch 
///////////////////////////////////////

simulated event UnTouch( Actor Other )
{
	local s_Player			P;

	if ( Role != Role_Authority )
		return;

	P = s_Player(Other);
	if ( P != None )
	{
		if ( P.GetStateName() == 'Climbing' )
		{
			//P.PlayerRestartState = 'PlayerWalking';
			//P.StartWalk();
			if ( P.Region.Zone.bWaterZone )
			{
				P.SetPhysics(PHYS_Swimming);
				P.GotoState('PlayerSwimming');
			}
			else
				P.GotoState('PlayerWalking');
		}
		P.CalculateWeight();
	}
}
*/

///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////
// bSpecialCost=True

defaultproperties
{
     Texture=Texture'TODatas.Engine.SWATLadder'
     CollisionRadius=32.000000
     CollisionHeight=100.000000
     bCollideActors=True
}
