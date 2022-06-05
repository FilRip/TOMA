class TO_Grenade extends S_Weapon;

var bool bCanHold;
var bool bGrenadeReady;
var bool bDrawGauge;
var float Power;
var localized string LS_ThrowingRange;

function float RateSelf (out int bUseAltMode)
{
}

function float SwitchPriority ()
{
}

function Fire (float Value)
{
}

simulated function bool ClientFire (float Value)
{
}

simulated function PlayFiring ()
{
}

simulated function PlayIdleAnim ()
{
}

simulated function PlayEndThrow ()
{
}

simulated function MNthrow ()
{
}

state ClientHoldGrenade
{
	ignores  s_ReloadW, ChangeFireMode;
	
	simulated function bool ClientFire (float Value)
	{
	}
	
	simulated function Tick (float DeltaTime)
	{
	}
	
	simulated function AnimEnd ()
	{
	}
	
	simulated function BeingState ()
	{
	}
}

state ServerHoldGrenade
{
	ignores  s_ReloadW, ChangeFireMode;
	
	function Fire (float F)
	{
	}
	
	function Tick (float DeltaTime)
	{
	}
	
	function AnimEnd ()
	{
	}
	
	function DropFrom (Vector StartLocation)
	{
	}
	
	function BeginState ()
	{
	}
	
	function EndState ()
	{
	}
Begin:
}

state ClientThrowGrenade
{
	ignores  s_ReloadW, ChangeFireMode;
}

state ServerThrowingGrenade
{
	ignores  s_ReloadW, ChangeFireMode;
	
	function Fire (float F)
	{
	}
	
	function AnimEnd ()
	{
	}
Begin:
}

function BotThrowGrenade ()
{
}

simulated function ThrowGrenade ()
{
}

simulated function DropGrenade ()
{
}

function GrenadeThrown ()
{
}

simulated event RenderOverlays (Canvas Canvas)
{
}

function FinishGrenade ()
{
}
