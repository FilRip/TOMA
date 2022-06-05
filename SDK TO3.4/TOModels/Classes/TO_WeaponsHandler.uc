class TO_WeaponsHandler extends Actor;

enum EWeaponTeam
{
	WT_None,
	WT_Both,
	WT_SpecialForces,
	WT_Terrorist
};

var byte NumWeapons;
var string WeaponStr[32];
var localized string WeaponName[32];
var float BotDesirability[32];
var float BuymenuScale[32];
var EWeaponTeam WeaponTeam[32];

static function bool IsTeamMatch (Pawn Other, byte WeaponNumber)
{
}

static function int GetIdByClass (string WeaponClass)
{
}
