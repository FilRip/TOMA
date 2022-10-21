//=============================================================================
// TO_WeaponsHandler
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================
// Handles weapons.
// Supports AutoAliases, UT gametypes weapon replacer, bots weapons buying system, Player 'Action Window' buying.

// Bug: hole in list! => replacer is not synched

class TO_WeaponsHandler extends Actor
	abstract;


var	byte	NumWeapons;

// TO Weapons definition
var	string					WeaponStr[32];
var	string					WeaponName[32];
var	float						BotDesirability[32];
	
enum EWeaponTeam
{
	WT_Both,
	WT_SpecialForces,					
	WT_Terrorist,
};

var	EWeaponTeam	WeaponTeam[32];


///////////////////////////////////////
// IsTeamMatch
///////////////////////////////////////

static function bool IsTeamMatch(Pawn Other, byte WeaponNumber)
{
	// Test Hack
	//return true;

	if ( default.WeaponTeam[WeaponNumber] == WT_Both )
		return true;

	if ( Other.PlayerReplicationInfo != None )
	{
		if ( (Other.PlayerReplicationInfo.Team == 0) && (default.WeaponTeam[WeaponNumber] == WT_Terrorist) )
			return true;
		else if ( (Other.PlayerReplicationInfo.Team == 1 && default.WeaponTeam[WeaponNumber] == WT_SpecialForces) )
			return true;
	}
	else
		log("TO_WeaponsHandler::IsTeamMatch - PlayerReplicationInfo == None - Other:"@Other);

	return false;
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////


/*


	WeaponName(21)="OICW"
	WeaponStr(21)="s_SWAT.s_OICW"
	BotDesirability(21)=0.45
	WeaponTeam(21)=WT_Both
*/

	/*
	WeaponName(0)="TEST WEAPON"
	WeaponStr(0)="s_SWAT.TO_MP5KPDW"
	BotDesirability(0)=1.00
	WeaponTeam(0)=WT_Both
	NumWeapons=0


	*/

defaultproperties
{
     NumWeapons=20
     WeaponStr(0)="s_SWAT.s_Glock"
     WeaponStr(1)="s_SWAT.s_deagle"
     WeaponStr(2)="s_SWAT.s_MAC10"
     WeaponStr(3)="s_SWAT.s_MP5N"
     WeaponStr(4)="s_SWAT.s_MossBerg"
     WeaponStr(5)="s_SWAT.s_M3"
     WeaponStr(6)="s_SWAT.s_Ak47"
     WeaponStr(7)="s_SWAT.TO_SteyrAug"
     WeaponStr(8)="s_SWAT.s_FAMAS"
     WeaponStr(9)="s_SWAT.s_HKSR9"
     WeaponStr(10)="s_SWAT.TO_HK33"
     WeaponStr(11)="s_SWAT.s_PSG1"
     WeaponStr(12)="s_SWAT.TO_Grenade"
     WeaponStr(13)="s_SWAT.s_GrenadeFB"
     WeaponStr(14)="s_SWAT.s_GrenadeConc"
     WeaponStr(15)="s_SWAT.s_p85"
     WeaponStr(16)="s_SWAT.TO_Saiga"
     WeaponStr(17)="s_SWAT.TO_MP5KPDW"
     WeaponStr(18)="s_SWAT.TO_Berreta"
     WeaponStr(19)="s_SWAT.TO_GrenadeSmoke"
     WeaponStr(20)="s_SWAT.TO_M4m203"
     WeaponName(0)="Glock 21"
     WeaponName(1)="Desert Eagle"
     WeaponName(2)="INGRAM MAC 10"
     WeaponName(3)="MP5 Navy"
     WeaponName(4)="Mossberg Shotgun"
     WeaponName(5)="M3 Benelli Shotgun"
     WeaponName(6)="AK 47"
     WeaponName(7)="Steyr Aug"
     WeaponName(8)="FAMAS"
     WeaponName(9)="HK SR9"
     WeaponName(10)="HK 33"
     WeaponName(11)="HK PSG1"
     WeaponName(12)="HE Grenade"
     WeaponName(13)="FlashBang"
     WeaponName(14)="Conc. Grenade"
     WeaponName(15)="Parker Hale 85"
     WeaponName(16)="Saiga"
     WeaponName(17)="MP5k PDW"
     WeaponName(18)="Beretta 92F"
     WeaponName(19)="Smoke Grenade"
     WeaponName(20)="M4A1m203"
     BotDesirability(0)=0.100000
     BotDesirability(1)=0.500000
     BotDesirability(2)=0.600000
     BotDesirability(3)=0.500000
     BotDesirability(4)=0.300000
     BotDesirability(5)=0.300000
     BotDesirability(6)=0.500000
     BotDesirability(7)=0.400000
     BotDesirability(8)=0.500000
     BotDesirability(9)=0.450000
     BotDesirability(10)=0.450000
     BotDesirability(11)=0.100000
     BotDesirability(12)=0.150000
     BotDesirability(13)=0.150000
     BotDesirability(14)=0.100000
     BotDesirability(15)=0.100000
     BotDesirability(16)=0.450000
     BotDesirability(17)=0.600000
     BotDesirability(18)=0.100000
     BotDesirability(19)=0.150000
     BotDesirability(20)=0.500000
     WeaponTeam(0)=WT_Terrorist
     WeaponTeam(2)=WT_Terrorist
     WeaponTeam(3)=WT_SpecialForces
     WeaponTeam(4)=WT_Terrorist
     WeaponTeam(5)=WT_SpecialForces
     WeaponTeam(6)=WT_Terrorist
     WeaponTeam(7)=WT_SpecialForces
     WeaponTeam(8)=WT_SpecialForces
     WeaponTeam(10)=WT_Terrorist
     WeaponTeam(15)=WT_Terrorist
     WeaponTeam(16)=WT_Terrorist
     WeaponTeam(17)=WT_Terrorist
     WeaponTeam(18)=WT_SpecialForces
     WeaponTeam(20)=WT_SpecialForces
}
