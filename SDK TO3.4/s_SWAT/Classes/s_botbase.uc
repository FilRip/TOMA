class s_botbase extends Bot;

var bool bInBuyZone;
var bool bInHomeBase;
var bool bInEscapeZone;
var bool bInRescueZone;
var bool bInHostageHidingPlace;
var bool bInBombingZone;
var TO_AlarmPoint AlarmPoint;
var TO_DefensePoint DefensePoint;
var int i;
var name MoveTargetTag;
var bool bTakeCover;
var Actor TmpActor;
var bool bShouldCrawl;
var int TO_SinglePlayerBotType;
var int TO_SinglePlayerBotAttitude;

function bool Gibbed (name DamageType)
{
}

function SpawnGibbedCarcass ()
{
}

function Carcass SpawnCarcass ()
{
}

function bool IsDead (Actor Dude)
{
}

function InitRating ()
{
}

function WhatToDoNext (name LikelyState, name LikelyLabel)
{
}

function bool DeferTo (Bot Other)
{
}

function EAttitude AttitudeTo (Pawn Other)
{
}

function float AssessThreat (Pawn NewThreat)
{
}

function ReSetSkill ()
{
}

function PreSetMovement ()
{
}

function MaybeTaunt (Pawn Other)
{
}

function bool FindAmbushSpot ()
{
}

state wandering
{
	function bool TestDirection (Vector Dir, out Vector pick)
	{
	}
	
wander:
Begin:
Moving:
Pausing:
ContinueWander:
Turn:
AdjustFromWall:
}

state Roaming
{
	function EnemyAcquired ()
	{
	}
	
	function PickDestination ()
	{
	}
	
LongCamp:
GiveWay:
Camp:
ReCamp:
PreBegin:
Begin:
RunAway:
SpecialNavig:
Moving:
TakeHit:
Landed:
AdjustFromWall:
ShootDecoration:
}

state Attacking
{
	function ChooseAttackMode ()
	{
	}
	
	function EnemyNotVisible ()
	{
	}
	
	function Timer ()
	{
	}
	
	function BeginState ()
	{
	}
	
Begin:
}

state Fallback
{
	function PickDestination ()
	{
	}
	
Begin:
RunAway:
SpecialNavig:
Moving:
Landed:
TakeHit:
AdjustFromWall:
}

state TacticalMove
{
	function PickRegDestination (bool bNoCharge)
	{
	}
	
	function BeginState ()
	{
	}
	
	function EndState ()
	{
	}
	
TacticalTick:
Begin:
DoMove:
DoDirectMove:
DoStrafeMove:
NoCharge:
AdjustFromWall:
TakeHit:
RecoverEnemy:
}

state Hunting
{
	function PickDestination ()
	{
	}
	
AdjustFromWall:
Begin:
AfterFall:
Follow:
SpecialNavig:
}

state StakeOut
{
Begin:
}

state Dying
{
	function BeginState ()
	{
	}
	
Begin:
}

simulated function PlayFootStep ()
{
}

static function SetMultiSkin (Actor SkinActor, string SkinName, string FaceName, byte TeamNum)
{
}

static function bool SetSkinElement (Actor SkinActor, int SkinNo, string SkinName, string DefaultSkinName)
{
}

function PlayAnimNicely (name AnimSeq)
{
}

function PlayGrenadeThrow ()
{
}

function PlayWeaponReloading ()
{
}

function Actor FindActorTag (name FindTag)
{
}

state Cover
{
Moving:
Begin:
}

function PlayDyingSound ()
{
}
