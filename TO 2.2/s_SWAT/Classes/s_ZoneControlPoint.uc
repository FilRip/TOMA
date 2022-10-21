//=============================================================================
// s_ZoneControlPoint
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_ZoneControlPoint extends NavigationPoint;

var(TO)		byte		OwnedTeam;						// 0 = Terr - 1 = Special Forces
var(TO)		bool		bBuyPoint;						// can buy ammo, items and weapons ?
var(TO)		bool		bRescuePoint;					// can rescue hostages (Special Forces Only !)
var(TO)		bool		bHomeBase;						// Home base !
var(TO)		bool		bEscapeZone;					// Escape zone => send player to spectator
var(TO)		bool		bHostageHidingPlace;	// where Terr hide hostages
var(TO)		bool		bBombingZone;					// If C4 Target is a location

var(Obsolete)		float		radius;						// Radius - obsolete ! Use Collision Height/Radius instead

var	Pawn	PL[32];	// PawnList

var		s_ZoneControlPoint	NextZCP;


///////////////////////////////////////
// PostBeginPlay 
///////////////////////////////////////

function PostBeginPlay()
{
	local	s_ZoneControlPoint	ZCP;
	local	s_SWATGame				SW;
	local	int								i;

	Super.PostBeginPlay();

	// temporary hack
	if ( radius != 200 )
		SetCollisionSize(radius, CollisionHeight);
	//SetCollision(true, false, false);

	//SetTimer( Frand() );

	if ( Role < Role_Authority )
		return;

	SW = s_SWATGame(Level.Game);

	// Register TO_ConsoleTimer in s_SWATGame
	if (SW == None)
		log("s_ZoneControlPoint - s_SWATGame(Level.Game) == None "$Level.Game);
	else 
	{
		if (SW.ZCPLink == None)
		{
			SW.ZCPLink = Self;
			return;
		}

		for ( ZCP=SW.ZCPLink; ZCP!=None; ZCP=ZCP.NextZCP)
		{
			if ( ZCP.NextZCP == None )
			{
				ZCP.NextZCP = Self;
				return;
			}
			i++;
			if (i>100)
				break;
		}

		log("s_ZoneControlPoint - Couldn't register class");
	}
}

/*
simulated function Timer()
{
	CheckZones();
	SetTimer(1.0, true);
}


final simulated function CheckZones()
{
	local	Pawn	P;
	local	int		i;

	for (i=0; i<32; i++)
	{
		if ( PL[i] != None )
		{
			ClearFlags(PL[i]);
			PL[i] = None;
		}
	}
	i = 0;

	ForEach CollidingActors(class'Pawn', P, CollisionRadius)
	{
		PL[i] = P;
		i++;

		SetFlags(PL[i]);
	}
}


final simulated function ClearFlags(Pawn P)
{
	local	s_Player	sP;
	local	s_BotBase	sB;

	if ( P.IsA('s_Player') )
	{
		sP = s_Player(P);
		sP.bInBuyZone = false;
		sP.bInHomeBase = false;
		sP.bInEscapeZone = false;
		sP.bInRescueZone = false;
		sP.bInBombingZone = false;
	}
	else if ( P.IsA('s_BotBase') )
	{
		sB = s_BotBase(P);
		sB.bInBuyZone = false;
		sB.bInHomeBase = false;
		sB.bInEscapeZone = false;
		sB.bInRescueZone = false;
		sB.bInBombingZone = false;
	}
}


final simulated function SetFlags( Pawn P )
{
	local	s_Player			sP;
	local	s_Bot					B;
	local	s_NPCHostage	H;
	local	s_SWATGame		SG;

	sP = s_Player(P);
	B = s_Bot(P);
	H = s_NPCHostage(P);

	if ( (sP != None) && !sP.PlayerReplicationInfo.bIsSpectator )
	{
		sP.bInRescueZone = sP.bInRescueZone || bRescuePoint;
		sP.bInBombingZone = sP.bInBombingZone || bBombingZone;
		if ( sP.PlayerReplicationInfo.team == OwnedTeam )
		{
			sP.bInBuyZone = sP.bInBuyZone || bBuyPoint;
			sP.bInHomeBase = sP.bInHomeBase || bHomeBase;
			if ( bEscapeZone )
			{
				sP.bInEscapeZone = sP.bInEscapeZone || bEscapeZone;
				if ( Role == Role_Authority )
					sP.Escape();
			}
		}
	}
	else if ( Role == Role_Authority )
	{
		if ( (B != None) && !B.bNotPlaying )
		{
			if ( bRescuePoint )
				B.bInRescueZone = B.bInRescueZone || bRescuePoint;

			B.bInHostageHidingPlace = B.bInHostageHidingPlace || bHostageHidingPlace;
			B.bInBombingZone = B.bInBombingZone || bBombingZone;

			if ( B.PlayerReplicationInfo.team == OwnedTeam )
			{
				B.bInBuyZone = B.bInBuyZone || bBuyPoint;
				B.bInHomeBase = B.bInHomeBase || bHomeBase;

				if ( bEscapeZone )
				{
					B.bInEscapeZone = B.bInEscapeZone || bEscapeZone;
					B.Escape();
				}
			}
		}
		else if ( H != None )
		{
			H.bInHostageHidingPlace = bHostageHidingPlace;

			if ( bRescuePoint )
			{
				if ( (H.Followed != None) && (s_Bot(H.Followed) != None) )
				{
					if ( s_Bot(H.Followed).HostageFollowing > 0 )
						s_Bot(H.Followed).HostageFollowing--;

					SG = s_SWATGame(Level.Game);

					if ( (s_Bot(H.Followed).HostageFollowing < 1) && (SG != None) )
						SG.ClearBotObjective(s_Bot(H.Followed));
				}

				H.Rescued();
			}
		}
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
	local	s_Bot					B;
	local	s_NPCHostage	H;
	local	s_SWATGame		SG;

	if (Other == None)
		return;

	P = s_Player(Other);
	B = s_Bot(Other);
	H = s_NPCHostage(Other);
	SG = s_SWATGame(Level.Game);

	if (P != None && !P.bNotPlaying)
	{
		P.bInRescueZone = bRescuePoint;
		P.bInBombingZone = bBombingZone;
		if (P.PlayerReplicationInfo != None && P.PlayerReplicationInfo.team == OwnedTeam)
		{
			P.bInBuyZone = bBuyPoint;
			P.bInHomeBase = bHomeBase;
			if (bEscapeZone == true)
			{
				P.bInEscapeZone = bEscapeZone;
				if (Role == Role_Authority )
					P.Escape();
			}
		}
//		else if (P.PlayerReplicationInfo == None)
//			log("s_ZoneControlPoint - Touch - PlayerReplicationInfo == None!!");
	}
	else if (Role == Role_Authority)
	{
		if (B != None && !B.bNotPlaying)
		{
			if (bRescuePoint)
			{
				B.bInRescueZone = bRescuePoint;
			}
			B.bInHostageHidingPlace = bHostageHidingPlace;
			B.bInBombingZone = bBombingZone;
			if (B.PlayerReplicationInfo != None && B.PlayerReplicationInfo.team == OwnedTeam)
			{
				B.bInBuyZone = bBuyPoint;
				B.bInHomeBase = bHomeBase;
				if (bEscapeZone == true)
				{
					B.bInEscapeZone = bEscapeZone;
					B.Escape();
				}
			}
		}
		else if (H != None && Role == Role_Authority)
		{
			H.bInHostageHidingPlace = bHostageHidingPlace;
			if ( bRescuePoint )
			{
				if ( (H.Followed != None) && (s_Bot(H.Followed) != None) )
				{
					if ( s_Bot(H.Followed).HostageFollowing > 0 )
						s_Bot(H.Followed).HostageFollowing--;

					if ( (s_Bot(H.Followed).HostageFollowing < 1) && (SG != None) )
						SG.ClearBotObjective(s_Bot(H.Followed));
				}

				H.Rescued();
			}
		}
	}
} 


///////////////////////////////////////
// UnTouch 
///////////////////////////////////////

simulated event UnTouch( Actor Other )
{
	local s_Player			P;
	local	s_Bot					B;
	local	s_NPCHostage	H;

	P = s_Player(Other);
	B = s_Bot(Other);
	H = s_NPCHostage(Other);

	if (P != None)
	{
		P.bInBuyZone = false;
		P.bInHomeBase = false;
		P.bInEscapeZone = false;
		P.bInRescueZone = false;
		P.bInBombingZone = false;
	}
	else if (B != None)
	{
		B.bInBuyZone = false;
		B.bInHomeBase = false;
		B.bInEscapeZone = false;
		B.bInRescueZone = false;
		B.bInHostageHidingPlace = false;
		B.bInBombingZone = false;
	}
	else if (H != None)
	{
		H.bInHostageHidingPlace = false;
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
	local	s_Bot					B;
	local	s_NPCHostage	H;
	local	s_SWATGame		SG;

//	if ( Other == None )
//		return;

	P = s_Player(Other);

	if ( (P != None) && !P.bNotPlaying )
	{
		P.bInRescueZone = P.bInRescueZone || bRescuePoint;
		P.bInBombingZone = P.bInBombingZone || bBombingZone;
		if ( (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.team == OwnedTeam) )
		{
			P.bInBuyZone = P.bInBuyZone || bBuyPoint;
			P.bInHomeBase = P.bInHomeBase || bHomeBase;
			if ( bEscapeZone )
			{
				P.bInEscapeZone = P.bInEscapeZone || bEscapeZone;
				if ( Role == Role_Authority )
					P.Escape();
			}
		}
//		else if (P.PlayerReplicationInfo == None)
//			log("s_ZoneControlPoint - Touch - PlayerReplicationInfo == None!!");
	}
	else if ( Role == Role_Authority )
	{
		B = s_Bot(Other);
		H = s_NPCHostage(Other);

		if ( (B != None) && !B.bNotPlaying )
		{
			if ( bRescuePoint )
				B.bInRescueZone = bRescuePoint;

			B.bInHostageHidingPlace = bHostageHidingPlace;
			B.bInBombingZone = bBombingZone;

			if ( (B.PlayerReplicationInfo != None) && (B.PlayerReplicationInfo.team == OwnedTeam) )
			{
				B.bInBuyZone = bBuyPoint;
				B.bInHomeBase = bHomeBase;

				if ( bEscapeZone )
				{
					B.bInEscapeZone = bEscapeZone;
					B.Escape();
				}
			}
		}
		else if ( H != None )
		{
			H.bInHostageHidingPlace = bHostageHidingPlace;

			if ( bRescuePoint )
			{
				if ( (H.Followed != None) && (s_Bot(H.Followed) != None) )
				{
					if ( s_Bot(H.Followed).HostageFollowing > 0 )
						s_Bot(H.Followed).HostageFollowing--;

					SG = s_SWATGame(Level.Game);

					if ( (s_Bot(H.Followed).HostageFollowing < 1) && (SG != None) )
						SG.ClearBotObjective(s_Bot(H.Followed));
				}

				H.Rescued();
			}
		}
	}
} 
*/

///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////
/*
ROLE_SimulatedProxy
*/

defaultproperties
{
     bBuyPoint=True
     bRescuePoint=True
     bHomeBase=True
     Radius=200.000000
     Texture=Texture'TODatas.Engine.SWATZone'
     CollisionRadius=200.000000
     CollisionHeight=40.000000
     bCollideActors=True
}
