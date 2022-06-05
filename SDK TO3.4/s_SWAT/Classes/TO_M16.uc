class TO_M16 extends S_Weapon;

var() Texture MuzzleFlashVariations;
var s_LaserDot LaserDot;

simulated function PostRender (Canvas Canvas)
{
}

event Destroyed ()
{
}

simulated function KillLaserDot ()
{
}

simulated function Tick (float DeltaTime)
{
}

simulated function PlayAltFiring ()
{
}

function AltFire (float Value)
{
}

state DownWeapon
{
	ignores  AltFire, Fire;
	
	function BeginState ()
	{
	}
	
}

function BecomePickup ()
{
}

simulated event RenderOverlays (Canvas Canvas)
{
}

simulated function SetAimError ()
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
