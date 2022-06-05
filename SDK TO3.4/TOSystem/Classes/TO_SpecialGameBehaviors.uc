class TO_SpecialGameBehaviors extends ReplicationInfo;

var string HiddenWeapons[32];
var int HiddenWeaponsListLength;
var string ForceShowWeapons[32];
var int ForceShowWeaponsListLength;
var bool bDisallowTeamSwitchs;

simulated function bool ShouldWeaponBeHidden (string W)
{
}

function addHiddenWeapon (string W)
{
}

simulated function bool ShouldWeaponBeShown (string W)
{
}

function addForceShowWeapon (string W)
{
}

