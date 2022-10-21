//	Obsolete, do not use !

class s_Ladder extends NavigationPoint;

var() localized string		LadderName;
var()						float			Radius;
var							float			Height;

 
///////////////////////////////////////
// PostBeginPlay 
///////////////////////////////////////

function PostBeginPlay()
{
	local s_Ladder			L;
	local s_LadderTop		Top;
	local	s_SWATGame		SW;
	local vector V;

	Super.PostBeginPlay();

	foreach allactors(class's_LadderTop', Top)
	{
		if ( Abs(Top.Location.X-Location.X)<10 && Abs(Top.Location.Y-Location.Y)<10 )
		{
			Height = Abs(Top.Location.Z-Location.Z);
			V = Location;
			V.Z += (Height / 2);
			SetLocation(V);
		}
	}
	SetCollisionSize(radius, height / 2 + 80);
	SetCollision(true, false, false);

}

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
	if (P != None)
	{
		if (P.GetStateName() != 'Climbing')
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

defaultproperties
{
     Radius=40.000000
     Texture=Texture'TODatas.Engine.SWATLadder'
     bCollideActors=True
}
