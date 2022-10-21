//=============================================================================
// s_MessageRoundWinner
//=============================================================================
//
// Tactical Ops
// - http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_MessageRoundWinner expands CriticalEventPlus;


var localized		string	WinMessage[14];
//var							Sound		WinSound[10];
 

///////////////////////////////////////
// GetString
///////////////////////////////////////

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	switch (Switch)
	{
		// Bombing
		case 11 : if (RelatedPRI_1 != None)
								return RelatedPRI_1.PlayerName$" dropped the bomb!";
							return "Bomb dropped!";

		case 12 : if (RelatedPRI_1 != None)
								return RelatedPRI_1.PlayerName$" planted the bomb!";
							return "Bomb planted!";

		case 13 : if (RelatedPRI_1 != None)
								return RelatedPRI_1.PlayerName$" defused the bomb!";
							return "Bomb defused!";
	}

	return Default.WinMessage[Switch];
}

/*
///////////////////////////////////////
// ClientReceive
///////////////////////////////////////

static simulated function ClientReceive( 
	PlayerPawn P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	if ( Switch < 8 && Default.WinSound[Switch] != None)
		P.ClientPlaySound(Default.WinSound[Switch],, true);
}
*/

///////////////////////////////////////
// GetOffset
///////////////////////////////////////

static function float GetOffset(int Switch, float YL, float ClipY )
{
	return (ClipY / 3);
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     WinMessage(0)="D R A W  G A M E !"
     WinMessage(1)="Special Forces exterminated!"
     WinMessage(2)="Terrorists exterminated!"
     WinMessage(3)="All Hostages rescued!"
     WinMessage(4)="Most of the Terrorists have escaped!"
     WinMessage(5)="Most of the Special Forces have escaped!"
     WinMessage(6)="Terrorists failed to escape!"
     WinMessage(7)="Special Forces failed to escape!"
     WinMessage(8)="Playing last round before map change!"
     WinMessage(9)="Special Forces win the round!"
     WinMessage(10)="Terrorists win the round!"
     FontSize=2
     bBeep=False
     DrawColor=(R=255,G=255)
}
