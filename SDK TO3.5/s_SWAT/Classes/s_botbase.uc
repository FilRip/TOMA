class s_botbase extends Botpack.Bot;

var TO_AlarmPoint AlarmPoint;
var int i;
var TO_LaserDot LaserDot;
var bool bInHostageHidingPlace;
var bool bLaserDot;
var Rotator SmoothedView;
var bool bInBuyZone;
var int TO_SinglePlayerBotAttitude;
var TO_DefensePoint DefensePoint;
var bool bInRescueZone;
var bool bInEscapeZone;
var bool bInHomeBase;
var bool bInBombingZone;
var bool bTakeCover;
var float LastClientDeathTime;
var bool bShouldCrawl;
var name MoveTargetTag;
var bool SpawnedCarcass;
var int TO_SinglePlayerBotType;
var Actor TmpActor;

simulated function Destroyed ()
{
}

function PlayDyingSound ()
{
}

state Dying
{
	function BeginState ()
	{
	}

	function SetFall ()
	{
	}

	function LongFall ()
	{
	}

	function WarnTarget (Pawn shooter, float projSpeed, Vector FireDir)
	{
	}

	function Died (Pawn Killer, name DamageType, Vector HitLocation)
	{
	}

}

state StakeOut
{
}

state TacticalMove
{
	function PickRegDestination (bool bNoCharge)
	{
	}

	function EndState ()
	{
	}

	function BeginState ()
	{
	}

}

state Attacking
{
	function BeginState ()
	{
	}

	function Timer ()
	{
	}

	function EnemyNotVisible ()
	{
	}

	function ChooseAttackMode ()
	{
	}

}

function EAttitude AttitudeTo (Pawn Other)
{
}

function WhatToDoNext (name LikelyState, name LikelyLabel)
{
}

function Carcass SpawnCarcass ()
{
}

simulated function ClientDeath ()
{
}

function PlayHit (float Damage, Vector HitLocation, name DamageType, Vector Momentum)
{
}

state Cover
{
}

function Actor FindActorTag (name FindTag)
{
}

function PlayWeaponReloading ()
{
}

function PlayGrenadeThrow ()
{
}

function PlayAnimNicely (name AnimSeq)
{
}

static function bool SetSkinElement (Actor SkinActor, int SkinNo, string SkinName, string DefaultSkinName)
{
}

static function SetMultiSkin (Actor SkinActor, string SkinName, string FaceName, byte TeamNum)
{
}

simulated function PlayFootStep ()
{
}

state Hunting
{
	function PickDestination ()
	{
	}

}

state Fallback
{
	function PickDestination ()
	{
	}

}

state Roaming
{
	function PickDestination ()
	{
	}

	function EnemyAcquired ()
	{
	}

}

state wandering
{
	function bool TestDirection (Vector Dir, out Vector pick)
	{
	}

}

function bool FindAmbushSpot ()
{
}

function MaybeTaunt (Pawn Other)
{
}

function PreSetMovement ()
{
}

function ReSetSkill ()
{
}

function float AssessThreat (Pawn NewThreat)
{
}

function bool DeferTo (Bot Other)
{
}

function InitRating ()
{
}

function bool IsDead (Actor Dude)
{
}

simulated function Tick (float Delta)
{
}

function SpawnGibbedCarcass ()
{
}

function bool Gibbed (name DamageType)
{
}


defaultproperties
{
}

