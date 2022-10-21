class s_Knife extends S_Weapon;

var bool bThrow;
var byte BloodFrame;
var byte CurrentFrame;

simulated function ChangeFireMode (optional bool HideCrap)
{
}

simulated function bool ClientAltFire (float Value)
{
}

simulated function bool ClientFire (float Value)
{
}

function AltFire (float Value)
{
}

function Fire (float Value)
{
}

state ClientChangeFireMode
{
	simulated function AnimEnd ()
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

state ServerChangeFireMode
{
	simulated function AnimEnd ()
	{
	}

	function ChangeFireMode (optional bool HideCrap)
	{
	}

	function s_ReloadW ()
	{
	}

	function AltFire (float Value)
	{
	}

	function Fire (float Value)
	{
	}

}

state ClientCleanBlade
{
	simulated function AnimEnd ()
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

state ServerCleanBlade
{
	function AnimEnd ()
	{
	}

	function fCleanBlade ()
	{
	}

	function ChangeFireMode (optional bool HideCrap)
	{
	}

	function s_ReloadW ()
	{
	}

	function AltFire (float Value)
	{
	}

	function Fire (float Value)
	{
	}

}

state ServerSlash
{
	function AnimEnd ()
	{
	}

	function ThrowKnife ()
	{
	}

	function SlashHit ()
	{
	}

	function ChangeFireMode (optional bool HideCrap)
	{
	}

	function s_ReloadW ()
	{
	}

	function AltFire (float Value)
	{
	}

	function Fire (float Value)
	{
	}

}

state ClientSlash
{
	function ThrowKnife ()
	{
	}

	simulated function SlashHit ()
	{
	}

	simulated function AnimEnd ()
	{
	}

	simulated function bool ClientAltFire (float Value)
	{
	}

	simulated function bool ClientFire (float Value)
	{
	}

	function s_ReloadW ()
	{
	}

	function ChangeFireMode (optional bool HideCrap)
	{
	}

}

function bool IsBehind (Pawn Me, Pawn Target)
{
}

function FireBullet (Vector StartTrace, Vector EndTrace, Vector AimDir)
{
}

function TraceFire (float Accuracy)
{
}

simulated function PlayFiring ()
{
}

simulated function PlayCleaning ()
{
}

simulated function TweenDown ()
{
}

simulated function PlaySelect ()
{
}

simulated function PlayIdleAnim ()
{
}

simulated function PlayChangeFireMode ()
{
}

simulated function TweenToStill ()
{
}

simulated function ForceStillFrame ()
{
}

simulated function bool DoChangeFireMode (optional bool HideCrap)
{
}

simulated function ForceModeChange (optional bool HideCrap)
{
}

function CheckBlood ()
{
}

simulated function UpdateBloodSkin (byte BFrame)
{
}

function float SwitchPriority ()
{
}

function float SuggestDefenseStyle ()
{
}

function float SuggestAttackStyle ()
{
}

function float RateSelf (out int bUseAltMode)
{
}

event float BotDesireability (Pawn Bot)
{
}


defaultproperties
{
}

