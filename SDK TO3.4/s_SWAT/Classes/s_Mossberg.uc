class s_Mossberg extends S_Weapon;

enum EShotReloadPhase
{
	SRP_PreReload,
	SRP_Reloading,
	SRP_PostReload
};

var() Texture MuzzleFlashVariations;
var float DamageRadius;
var int NumPellets;
var int BackRemainingClip;
var int BackClipAmmo;
var EShotReloadPhase ReloadPhase;

function GenerateBullet ()
{
}

simulated event RenderOverlays (Canvas Canvas)
{
}

simulated function PlayIdleAnim ()
{
}

simulated function PlayReloadWeapon ()
{
}

simulated function PlayInsertShell ()
{
}

simulated function PlayReloadEnd ()
{
}

simulated function PlayPump ()
{
}

simulated function PlayInsertShellSound ()
{
}

simulated function EjectShell ()
{
}

state ServerReloadWeapon
{
	function Fire (float F)
	{
	}
	
	function AltFire (float F)
	{
	}
	
	function BeginState ()
	{
	}
	
	function EndState ()
	{
	}
	
	function AnimEnd ()
	{
	}
Begin:
}

state ClientReloadWeapon
{
	simulated function bool ClientFire (float Value)
	{
	}
	
	simulated function bool ClientAltFire (float Value)
	{
	}
	
	simulated function BeginState ()
	{
	}
	
	simulated function EndState ()
	{
	}
	
	simulated function AnimEnd ()
	{
	}
}
