class TOMAWeaponsHandler extends TO_WeaponsHandler;

static function bool IsTeamMatch(Pawn Other,byte WeaponNumber)
{
	if (default.WeaponTeam[WeaponNumber]==WT_Both)
		return true;

	if (Other.PlayerReplicationInfo!=None)
	{
		if ((Other.PlayerReplicationInfo.Team==0) && (default.WeaponTeam[WeaponNumber]==WT_Terrorist))
			return true;
		else if ((Other.PlayerReplicationInfo.Team==1 && default.WeaponTeam[WeaponNumber]==WT_SpecialForces))
			return true;
	}
	else
		log("TOMAWeaponsHandler::IsTeamMatch - PlayerReplicationInfo == None - Other:"@Other);

	return false;
}

static function int GetIdByClass (string weaponclass)
{
	local int i;


	for (i=1;i<32;i++)
	{
		if (default.WeaponStr[i]==weaponclass)
		{
			return i;
		}
	}

	return -1;
}

defaultproperties
{
	WeaponName(25)="OICW"
	WeaponTeam(25)=WT_Both
	WeaponStr(25)="TOMA21.TOMAOICW"
	BotDesirability(25)=0.60
	BuymenuScale(25)=1.25

	WeaponTeam(12)=WT_Both
	WeaponStr(12)="TOMA21.TOMAGrenade"

	WeaponName(13)="Freeze Monster"
	WeaponTeam(13)=WT_Both
	WeaponStr(13)="TOMA21.TOMAFB"

	WeaponName(14)="Energy Shield Grenade"
	WeaponTeam(14)=WT_Both
	WeaponStr(14)="TOMA21.TOMAEnergyShieldNade"

	WeaponTeam(20)=WT_Both
	WeaponStr(20)="TOMA21.TOMAM4M203"

	WeaponName(19)="Attract Monster"
	WeaponTeam(19)=WT_Both
	WeaponStr(19)="TOMA21.TOMASmokeNade"

	WeaponName(26)="FAMAS"
	WeaponTeam(26)=WT_Both
	WeaponStr(26)="TOMA21.TOMAFAMAS"
	BotDesirability(26)=0.60
	BuymenuScale(26)=1.25

	WeaponName(27)="SteyrAug"
	WeaponTeam(27)=WT_Both
	WeaponStr(27)="TOMA21.TOMASteyrAug"
	BotDesirability(27)=0.60
	BuymenuScale(27)=1.25

	WeaponStr(23)="TOMA21.TOMAM60"

	WeaponName(28)="C4 Explosive"
	WeaponTeam(28)=WT_Both
	WeaponStr(28)="TOMA21.TOMAC4"
	BotDesirability(28)=0.60
	BuymenuScale(28)=1.25

	WeaponName(29)="Concussion"
	WeaponTeam(29)=WT_Both
	WeaponStr(29)="TOMA21.TOMAConcGrenade"
	BotDesirability(29)=0.60
	BuymenuScale(29)=1.25

	NumWeapons=29
}
