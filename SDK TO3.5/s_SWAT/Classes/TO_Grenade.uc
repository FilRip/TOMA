class TO_Grenade extends S_Weapon;

var float Power;
var bool bGrenadeReady;
var bool bThrown;
var bool bDrawGauge;
var bool bCanHold;

function DropGrenade ()
{
}

function ThrowGrenade ()
{
}

function Fire (float Value)
{
}

function GrenadeThrown ()
{
}

simulated function bool ClientFire (float Value)
{
}

function FinishGrenade ()
{
}

simulated event RenderOverlays (Canvas Canvas)
{
}

function BotThrowGrenade ()
{
}

state ServerThrowingGrenade
{
	function DropFrom (Vector StartLocation)
	{
	}

	function AnimEnd ()
	{
	}

	function Fire (float F)
	{
	}

	function s_ReloadW ()
	{
	}

	function ChangeFireMode (optional bool HideCrap)
	{
	}

}

state ClientThrowGrenade
{
	function s_ReloadW ()
	{
	}

	function ChangeFireMode (optional bool HideCrap)
	{
	}

}

state ServerHoldGrenade
{
	function EndState ()
	{
	}

	function BeginState ()
	{
	}

	function DropFrom (Vector StartLocation)
	{
	}

	function AnimEnd ()
	{
	}

	function Tick (float DeltaTime)
	{
	}

	function Fire (float F)
	{
	}

	function s_ReloadW ()
	{
	}

	function ChangeFireMode (optional bool HideCrap)
	{
	}

}

state ClientHoldGrenade
{
	simulated function BeingState ()
	{
	}

	simulated function AnimEnd ()
	{
	}

	simulated function Tick (float DeltaTime)
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

simulated function MNthrow ()
{
}

simulated function PlayEndThrow ()
{
}

simulated function PlayIdleAnim ()
{
}

simulated function PlayFiring ()
{
}

function float SwitchPriority ()
{
}

function float RateSelf (out int bUseAltMode)
{
}


defaultproperties
{
}

