class s_C4 extends S_Weapon;

var bool bPlanted;
var bool bCanPlant;
var Vector OriginalLocation;
var Class<s_ExplosiveC4> ExplosiveC4Class;

function float RateSelf (out int bUseAltMode)
{
}

function float SwitchPriority ()
{
}

event float BotDesireability (Pawn Bot)
{
}

function DropBomb (bool bMessage)
{
}

event Destroyed ()
{
}

function DropFrom (Vector StartLocation)
{
}

function GiveTo (Pawn Other)
{
}

function Fire (float Value)
{
}

simulated function bool ClientFire (float Value)
{
}

simulated function ForceClientFire ()
{
}

function ClientForceFire ()
{
}

simulated function PlayFiring ()
{
}

simulated function PlayC4Arming ()
{
}

state ClientArmingBomb
{
	simulated function bool ClientFire (float Value)
	{
	}
	
	simulated function Tick (float DeltaTime)
	{
	}
	
	simulated function AnimEnd ()
	{
	}
	
	simulated function EndState ()
	{
	}
	
}

state ServerArmingBomb
{
	function Fire (float F)
	{
	}
	
	simulated function Tick (float DeltaTime)
	{
	}
	
	simulated function AnimEnd ()
	{
	}
	
	simulated function EndState ()
	{
	}
	
Begin:
}

simulated function ForceClientFinish ()
{
}

simulated function PlayIdleAnim ()
{
}

function bool IsInBombingSpot ()
{
}

function PlaceC4 ()
{
}
