class s_NPC extends s_botbase;

var s_PRI TOPRI;
var TO_PZone PZone;
var float LastWhatToDoNextCheck;
var int HelmetCharge;
var int VestCharge;
var int LegsCharge;
var int EnemyTeam;
var Pawn Tortionary;
var bool bCanUseWeapon;
var float NPCWAff;
var Vector MoveAwayFrom;

simulated function PostBeginPlay ()
{
}

simulated event Destroyed ()
{
}

function InitPawn ()
{
}

auto state startup
{
Begin:
}

function Carcass SpawnCarcass ()
{
}

function SetMovementPhysics ()
{
}

function Falling ()
{
}

function Bump (Actor Other)
{
}

function bool CanTossWeaponTo (Pawn aPlayer)
{
}

function EAttitude AttitudeTo (Pawn Other)
{
}

function FireWeapon ()
{
}

function bool CloseToPointMan (Pawn Other)
{
}

function bool CanImpactJump ()
{
}

state Waiting
{
	function AnimEnd ()
	{
	}
	
	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}
Begin:
}

state Following
{
	function SetOrders (name NewOrders, Pawn OrderGiver, optional bool bNoAck)
	{
	}
	
	function HearPickup (Pawn Other)
	{
	}
	
	function ShootTarget (Actor NewTarget)
	{
	}
	
	function MayFall ()
	{
	}
	
	function HandleHelpMessageFrom (Pawn Other)
	{
	}
	
	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}
	
	function FearThisSpot (Actor ASpot)
	{
	}
	
	function Timer ()
	{
	}
	
	function SetFall ()
	{
	}
	
	function EnemyAcquired ()
	{
	}
	
	function HitWall (Vector HitNormal, Actor Wall)
	{
	}
	
	function PickDestination ()
	{
	}
	
	function AnimEnd ()
	{
	}
	
	function ShareWith (Pawn Other)
	{
	}
	
	function BeginState ()
	{
	}
	
	function EndState ()
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

state TacticalMove
{
	function Timer ()
	{
	}
	
	function GiveUpTactical (bool bNoCharge)
	{
	}
	
	function PickDestination (bool bNoCharge)
	{
	}
	
	function PickRegDestination (bool bNoCharge)
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

state Retreating
{
	function PickDestination ()
	{
	}
	
	function BeginState ()
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

state RangedAttack
{
	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}
	
	function BeginState ()
	{
	}
Challenge:
Begin:
FaceTarget:
ReadyToAttack:
Firing:
DoneFiring:
}

state Dying
{
	function RestartPlayer ()
	{
	}
	
	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}
	
	function BeginState ()
	{
	}
Begin:
}

state StakeOut
{
	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}
	
	singular function HearNoise (float Loudness, Actor NoiseMaker)
	{
	}
	
	function SetFall ()
	{
	}
	
	function bool SetEnemy (Pawn NewEnemy)
	{
	}
	
	function Timer ()
	{
	}
	
	function Rotator AdjustAim (float projSpeed, Vector projStart, int aimerror, bool leadTarget, bool WarnTarget)
	{
	}
	
	function bool ClearShot ()
	{
	}
	
	function FindNewStakeOutDir ()
	{
	}
	
	function bool ContinueStakeOut ()
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

state ImpactJumping
{
	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}
	
	function Vector ImpactLook ()
	{
	}
	
	function AnimEnd ()
	{
	}
	
	function ChangeToHammer ()
	{
	}
	
	function EndState ()
	{
	}
Begin:
}

state Escape
{
	function SetOrders (name NewOrders, Pawn OrderGiver, optional bool bNoAck)
	{
	}
	
	function HearPickup (Pawn Other)
	{
	}
	
	function ShootTarget (Actor NewTarget)
	{
	}
	
	function MayFall ()
	{
	}
	
	function HandleHelpMessageFrom (Pawn Other)
	{
	}
	
	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}
	
	function FearThisSpot (Actor ASpot)
	{
	}
	
	function Timer ()
	{
	}
	
	function SetFall ()
	{
	}
	
	function EnemyAcquired ()
	{
	}
	
	function HitWall (Vector HitNormal, Actor Wall)
	{
	}
	
	function PickDestination ()
	{
	}
	
	function AnimEnd ()
	{
	}
	
	function ShareWith (Pawn Other)
	{
	}
	
	function BeginState ()
	{
	}
	
	function EndState ()
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

state s_Wandering
{
	function SetOrders (name NewOrders, Pawn OrderGiver, optional bool bNoAck)
	{
	}
	
	function HearPickup (Pawn Other)
	{
	}
	
	function ShootTarget (Actor NewTarget)
	{
	}
	
	function MayFall ()
	{
	}
	
	function HandleHelpMessageFrom (Pawn Other)
	{
	}
	
	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}
	
	function FearThisSpot (Actor ASpot)
	{
	}
	
	function Timer ()
	{
	}
	
	function SetFall ()
	{
	}
	
	function EnemyAcquired ()
	{
	}
	
	function HitWall (Vector HitNormal, Actor Wall)
	{
	}
	
	function PickDestination ()
	{
	}
	
	function AnimEnd ()
	{
	}
	
	function ShareWith (Pawn Other)
	{
	}
	
	function BeginState ()
	{
	}
	
	function EndState ()
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

function MoveAway (Actor Other)
{
}

state smoveawayfrom
{
	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}
	
Begin:
}

simulated function CalculateWeight ()
{
}
