class s_C4 extends S_Weapon;

var Vector OriginalLocation;
var bool bPlanted;
var bool bCanPlant;
var Pawn oldOwner;
var s_ExplosiveC4 ExplosiveC4Class;

function Fire (float Value)
{
}

simulated function bool ClientFire (float Value)
{
}

simulated function ForceClientStopFiring ()
{
}

function PlaceC4 ()
{
}

function bool IsInBombingSpot ()
{
}

simulated function PlayIdleAnim ()
{
}

simulated function ForceClientFinish ()
{
}

state ServerArmingBomb
{
	simulated function EndState ()
	{
	}

	simulated function AnimEnd ()
	{
	}

	simulated function Tick (float DeltaTime)
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

state ClientArmingBomb
{
	simulated function EndState ()
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

simulated function PlayC4Arming ()
{
}

simulated function PlayFiring ()
{
}

function ClientForceFire ()
{
}

simulated function ForceClientFire ()
{
}

function GiveTo (Pawn Other)
{
}

function DropFrom (Vector StartLocation)
{
}

event Destroyed ()
{
}

function DropBomb (bool bMessage)
{
}

event float BotDesireability (Pawn Bot)
{
}

function float SwitchPriority ()
{
}

function float RateSelf (out int bUseAltMode)
{
}

event FellOutOfWorld ()
{
}


defaultproperties
{
}

