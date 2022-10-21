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
 
class s_MessageObjective expands CriticalEventPlus;

 
var localized		string	WinMessage[10];
var							Sound		WinSound[10];


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
	return Default.WinMessage[Switch];
}


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

	if (Default.WinSound[Switch] != None)
		P.ClientPlaySound(Default.WinSound[Switch],, true);
}


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
     WinMessage(0)="! Do nothing !"
     WinMessage(1)="Team just got home"
     WinMessage(2)="Enemy base sucessfully assaulted"
     WinMessage(3)="Buy point found"
     WinMessage(4)="Hostages rescued"
     WinMessage(5)="Team got to rendez-vous point"
     WinMessage(6)="Objective complete (Trigger)"
     FontSize=2
     bBeep=False
     DrawColor=(R=255,G=255)
}
