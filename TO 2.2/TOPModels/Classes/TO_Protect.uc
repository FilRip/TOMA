//=============================================================================
// TO_Protect
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_Protect extends Actor;

var	PlayerPawn	P;
var	bool				bInit, bValidConsole;
var	int					CheckMeChecks, Count;


///////////////////////////////////////
// replication 
///////////////////////////////////////

replication 
{
	// Client->Server replication
  reliable if ( Role < ROLE_Authority )
  	CheckMe;
}


///////////////////////////////////////
// PostBeginPlay
///////////////////////////////////////

simulated function	PostBeginPlay()
{
	//log("TO_Protect::PostBeginPlay");
	// Randomize checks. So we don't end up processing all the players the same tick.
	SetTimer(5.0 + 2.0 * FRand() + FRand(), false);
}


///////////////////////////////////////
// Timer
///////////////////////////////////////

simulated function Timer()
{
	if ( Owner == None )
	{
		//log("TO_Protect::Timer - Owner == None");
		Destroy();
		return;
	}

	//log("TO_Protect::Timer"@Owner.GetHumanName()@"LO:"@Level.Owner);

	if ( !bInit )
	{
		bInit = true;
		P = PlayerPawn(Owner);
		if ( HasAValidConsole() )
		{
			bValidConsole = true;
			SetTimer(5.0, true);
		}
		else
		{
			// Just keep this to destroy actor when player leaves game.
			SetTimer(5.0, true);
		}
		return;
	}

	if ( bValidConsole )
		ProcessChecks();
	
	if ( Role == Role_Authority )
	{
		Count++;
		if ( Count > 10 ) 
		{
			if ( CheckMeChecks < 1 )
			{
				log("TO_Protect::Timer - CheckMeChecks missing!! (Cheater?) Kicking Player"@P.GetHumanName());
				KickPlayer();
				//P.Destroy();
			}
			else
			{	
				Count = 0;
				CheckMeChecks = 0;
			}
		}
	}
}


///////////////////////////////////////
// HasAValidConsole
///////////////////////////////////////

final simulated function bool HasAValidConsole()
{
	return ( (P.Player != None) && (P.Player.Console != None) );
}


///////////////////////////////////////
// ProcessChecks
///////////////////////////////////////

final simulated function ProcessChecks()
{
	//log("TO_Protect::ProcessChecks"@Owner.GetHumanName());
			
	CheckMe(P.Player.Console.Class);

	if ( bool(P.ConsoleCommand("get ini:Engine.Engine.ViewportManager NoLighting")) )
		P.ConsoleCommand("set ini:Engine.Engine.ViewportManager NoLighting false");
}


///////////////////////////////////////
// CheckMe
///////////////////////////////////////

final	function CheckMe(Class<Console> MyConsole)
{
	local string	ClassStr;

	ClassStr = String(MyConsole);
	//log("TO_Protect::CheckMe - C:"@ClassStr);

	if ( (MyConsole != Class'TOPModels.TO_Console') 
		|| (Left(ClassStr, InStr(ClassStr, ".")) != "TOPModels") )
	{	
		log("TO_Protect::CheckMe - Invalide Console (cheater?), kicking player!");
		//P.Destroy();
		KickPlayer();
	}
	else
		CheckMeChecks++;
}


///////////////////////////////////////
// KickPlayer 
///////////////////////////////////////

final function KickPlayer()
{
	if ( P.IsA('TO_SysPlayer') )
		TO_SysPlayer(P).ForceTempKickBan("Invalide Console (cheater?)");
	else
		P.Destroy();
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////
//

defaultproperties
{
     bHidden=True
     bAlwaysTick=True
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_None
     Texture=None
}
