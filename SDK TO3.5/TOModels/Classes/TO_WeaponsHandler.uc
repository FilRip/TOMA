class TO_WeaponsHandler extends Engine.Actor;

enum EWeaponTeam {
	WT_None,
	WT_Both,
	WT_SpecialForces,
	WT_Terrorist
};
var EWeaponTeam WeaponTeam;
var byte NumWeapons;
var float BotDesirability;
var float BuymenuScale;

static function bool IsTeamMatch (Pawn Other, byte WeaponNumber)
{
}

static function int GetIdByClass (string WeaponClass)
{
}

static function int GetIdByAlias (string Alias)
{
}


defaultproperties
{
}

