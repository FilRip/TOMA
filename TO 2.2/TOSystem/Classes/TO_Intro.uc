//=============================================================================
// TO_Intro
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================


class TO_Intro extends UTIntro;


event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local PlayerPawn NewPlayer;
	local SpectatorCam Cam;

	// Don't allow player to be a spectator
	//if( !SpawnClass.Default.bCollideActors )
	SpawnClass = class<PlayerPawn>(DynamicLoadObject("s_SWAT.s_Player_T", class'Class'));

	bRatedGame = true;
	NewPlayer = Super(TournamentGameInfo).Login(Portal, Options, Error, SpawnClass);
	bRatedGame = false;
	NewPlayer.bHidden = True;

	foreach AllActors(class'SpectatorCam', Cam) 
		NewPlayer.ViewTarget = Cam;

	return NewPlayer;
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     GameUMenuType="TOSystem.TO_GameMenu"
     MultiplayerUMenuType="TOSystem.TO_MultiplayerMenu"
     GameOptionsMenuType="TOSystem.TO_OptionMenu"
     HUDType=Class'TOSystem.TO_IntroHUD'
}
