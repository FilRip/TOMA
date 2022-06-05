class s_Knife extends S_Weapon;

var byte BloodFrame;
var byte CurrentFrame;
var bool bThrow;

event float BotDesireability (Pawn Bot)
{
}

function float RateSelf (out int bUseAltMode)
{
}

function float SuggestAttackStyle ()
{
}

function float SuggestDefenseStyle ()
{
}

function float SwitchPriority ()
{
}

simulated function UpdateBloodSkin (byte BFrame)
{
}

function CheckBlood ()
{
}

function Fire (float Value)
{
}

function AltFire (float Value)
{
}

simulated function bool ClientFire (float Value)
{
}

simulated function bool ClientAltFire (float Value)
{
}

simulated function ChangeFireMode ()
{
}

simulated function ForceModeChange ()
{
}

simulated function bool DoChangeFireMode ()
{
}

simulated function ForceStillFrame ()
{
}

simulated function TweenToStill ()
{
}

simulated function PlayChangeFireMode ()
{
}

simulated function PlayIdleAnim ()
{
}

simulated function PlaySelect ()
{
}

simulated function TweenDown ()
{
}

simulated function PlayCleaning ()
{
}

simulated function PlayFiring ()
{
}

function TraceFire (float Accuracy)
{
}

function FireBullet (Vector StartTrace, Vector EndTrace, Vector AimDir)
{
}

function bool IsBehind (Pawn Me, Pawn Target)
{
}

state ClientSlash
{
	simulated function bool ClientFire (float Value)
	{
	}
	
	simulated function bool ClientAltFire (float Value)
	{
	}
	
	simulated function AnimEnd ()
	{
	}
	
	simulated function SlashHit ()
	{
	}
	
	function ThrowKnife ()
	{
	}
	
}

state ServerSlash
{	
	function ChangeFireMode ()
	{
	}
	
	function SlashHit ()
	{
	}
	
	function ThrowKnife ()
	{
	}
	
	function AnimEnd ()
	{
	}
	
Begin:
}

state ServerCleanBlade
{
	function fCleanBlade ()
	{
	}
	
	function AnimEnd ()
	{
	}
	
Begin:
}

state ClientCleanBlade
{	
	simulated function bool ClientFire (float Value)
	{
	}
	
	simulated function bool ClientAltFire (float Value)
	{
	}
	
	simulated function AnimEnd ()
	{
	}
	
}

state ServerChangeFireMode
{
	simulated function AnimEnd ()
	{
	}
	
Begin:
}

state ClientChangeFireMode
{
	simulated function bool ClientFire (float Value)
	{
	}
	
	simulated function bool ClientAltFire (float Value)
	{
	}
	
	simulated function AnimEnd ()
	{
	}
	
}
