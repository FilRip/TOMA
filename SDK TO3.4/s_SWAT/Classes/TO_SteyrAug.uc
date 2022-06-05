class TO_SteyrAug extends S_Weapon;

var() Texture MuzzleFlashVariations[6];
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

function AltFire (float Value)
{
}

simulated function bool ClientAltFire (float Value)
{
}

simulated function PlayIdleAnim ()
{
}

simulated function ClipIn ()
{
}

simulated function ClipOut ()
{
}

simulated function ClipLever ()
{
}
