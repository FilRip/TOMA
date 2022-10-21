//=============================================================================
// s_SpecialMessages
//=============================================================================
//
// Tactical Ops
// - http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_SpecialMessages expands CriticalEventPlus;


var localized		string	WinMessage[8];
var							Sound		WinSound[8];
 

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
	return (ClipY / 2);
}
 

///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     WinMessage(0)="You have successfully escaped!"
     WinMessage(1)="Follow me!"
     WinMessage(2)="Wait here, don't move!"
     WinMessage(3)="Don't move!"
     WinMessage(4)="Come here now"
     FontSize=0
     bBeep=False
     DrawColor=(R=255,G=255)
}
