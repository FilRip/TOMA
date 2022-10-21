//=============================================================================
// s_WeaponMessages
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_WeaponMessages expands CriticalEventPlus;


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
	return (ClipY * 6) / 8;
}
 

///////////////////////////////////////
// defaultproperties
///////////////////////////////////////
/*
	FM_None,				// Not a fire mode
	FM_SingleFire,	// Press [Fire] to fire each bullet
	FM_BurstFire,		// Press [Fire] to fire [BurstRoundnb] bullets
	FM_FullAuto,		// Hold [Fire] 
*/

defaultproperties
{
     WinMessage(0)="Bug - this is not a fire mode !"
     WinMessage(1)="Fire mode: Single shot"
     WinMessage(2)="Fire mode: 3 rounds burst fire"
     WinMessage(3)="Fire mode: Full automatic"
     WinMessage(5)="Fire mode: Slash"
     WinMessage(6)="Fire mode: Throw"
     WinMessage(7)="Need more knives"
     WinMessage(8)="Fire mode: Full automatic"
     WinMessage(9)="Fire mode: Grenade launcher"
     FontSize=4
     bBeep=False
     DrawColor=(R=255,G=255)
}
