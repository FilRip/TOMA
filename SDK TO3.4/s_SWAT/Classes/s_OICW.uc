class s_OICW extends S_Weapon;

var() Texture MuzzleFlashVariations;
var float Scale;
var float OldScale;
var int XO;
var int YO;
var int XOffset;
var int RealXO;
var int RealYO;

simulated function PostRender (Canvas Canvas)
{
}

simulated event RenderOverlays (Canvas Canvas)
{
}

function float RateSelf (out int bUseAltMode)
{
}

function GenerateBullet ()
{
}

function GenerateRocket ()
{
}

simulated function bool ClientAltFire (float Value)
{
}

function AltFire (float Value)
{
}

simulated function PlayReloadWeapon ()
{
}

simulated function PlayIdleAnim ()
{
}

simulated function bool DoChangeFireMode ()
{
}

simulated function ClientChangeFireMode (bool DesiredbAltMode)
{
}

simulated function ChangeFireModeSpecs (bool DesiredbAltMode)
{
}

simulated function PlayFiring ()
{
}

simulated function ClipIn ()
{
}

simulated function ClipOut ()
{
}
