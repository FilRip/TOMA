class s_Mossberg extends S_Weapon;

enum EShotReloadPhase {
	SRP_PreReload,
	SRP_Reloading,
	SRP_PostReload
};
var EShotReloadPhase ReloadPhase;
var bool bStopReload;
var float DamageRadius;
var int NumPellets;
var int BackClipAmmo;
var int BackRemainingClip;
var Texture MuzzleFlashVariations;
var bool bStoppedReload;

simulated function s_ReloadW ()
{
}

simulated function ChangeFireMode (optional bool HideCrap)
{
}

function ServerStopReload ()
{
}

state ClientReloadWeapon
{
	simulated function AnimEnd ()
	{
	}

	simulated function EndState ()
	{
	}

	simulated function BeginState ()
	{
	}

	simulated function bool ClientAltFire (float Value)
	{
	}

	simulated function bool ClientFire (float Value)
	{
	}

	function ChangeFireMode (optional bool HideCrap)
	{
	}

	function s_ReloadW ()
	{
	}

}

state ServerReloadWeapon
{
	function AnimEnd ()
	{
	}

	function EndState ()
	{
	}

	function ServerStopReload ()
	{
	}

	function BeginState ()
	{
	}

	function AltFire (float F)
	{
	}

	function Fire (float F)
	{
	}

	function ChangeFireMode (optional bool HideCrap)
	{
	}

	function s_ReloadW ()
	{
	}

}

simulated function EjectShell ()
{
}

simulated function PlayInsertShellSound ()
{
}

simulated function PlayPump ()
{
}

simulated function PlayReloadEnd ()
{
}

simulated function PlayInsertShell ()
{
}

simulated function PlayReloadWeapon ()
{
}

simulated function PlayIdleAnim ()
{
}

simulated event RenderOverlays (Canvas Canvas)
{
}

function GenerateBullet ()
{
}

simulated function int GetRemainingClips (bool Mode)
{
}

simulated function ClientFixFireMode (byte nw)
{
}

function bool DoChangeFireMode (optional bool HideCrap)
{
}


defaultproperties
{
}

