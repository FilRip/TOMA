class s_OICW extends S_Weapon;

var float Scale;
var int RealYO;
var int RealXO;
var int XOffset;
var int XO;
var int YO;
var float OldScale;
var Texture MuzzleFlashVariations;

simulated function ClipOut ()
{
}

simulated function ClipIn ()
{
}

simulated function PlayFiring ()
{
}

simulated function ChangeFireModeSpecs (bool DesiredbAltMode)
{
}

simulated function ClientChangeFireMode (bool DesiredbAltMode)
{
}

simulated function bool DoChangeFireMode (optional bool HideCrap)
{
}

simulated function PlayIdleAnim ()
{
}

simulated function PlayReloadWeapon ()
{
}

function AltFire (float Value)
{
}

simulated function bool ClientAltFire (float Value)
{
}

function GenerateRocket ()
{
}

function GenerateBullet ()
{
}

function float RateSelf (out int bUseAltMode)
{
}

simulated event RenderOverlays (Canvas Canvas)
{
}

native(11540) final latent function PostRender (Canvas Canvas)
{
}


defaultproperties
{
}

