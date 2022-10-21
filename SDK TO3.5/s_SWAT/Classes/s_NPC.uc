class s_NPC extends s_botbase;

var Pawn Tortionary;
var bool bCanUseWeapon;
var int EnemyTeam;
var Vector MoveAwayFrom;
var s_PRI TOPRI;
var int HelmetCharge;
var int VestCharge;
var int LegsCharge;
var float LastWhatToDoNextCheck;
var float NPCWAff;

state ImpactJumping
{
	function EndState ()
	{
	}

	function ChangeToHammer ()
	{
	}

	function AnimEnd ()
	{
	}

	function Vector ImpactLook ()
	{
	}

	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}

}

function EAttitude AttitudeTo (Pawn Other)
{
}

simulated function CalculateWeight ()
{
}

state smoveawayfrom
{
	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}

}

function MoveAway (Actor Other)
{
}

state s_Wandering
{
	function EndState ()
	{
	}

	function BeginState ()
	{
	}

	function ShareWith (Pawn Other)
	{
	}

	function AnimEnd ()
	{
	}

	function PickDestination ()
	{
	}

	function HitWall (Vector HitNormal, Actor Wall)
	{
	}

	function EnemyAcquired ()
	{
	}

	function SetFall ()
	{
	}

	function Timer ()
	{
	}

	function FearThisSpot (Actor ASpot)
	{
	}

	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}

	function HandleHelpMessageFrom (Pawn Other)
	{
	}

	function MayFall ()
	{
	}

	function ShootTarget (Actor NewTarget)
	{
	}

	function HearPickup (Pawn Other)
	{
	}

	function SetOrders (name NewOrders, Pawn OrderGiver, optional bool bNoAck)
	{
	}

}

state Escape
{
	function EndState ()
	{
	}

	function BeginState ()
	{
	}

	function ShareWith (Pawn Other)
	{
	}

	function AnimEnd ()
	{
	}

	function PickDestination ()
	{
	}

	function HitWall (Vector HitNormal, Actor Wall)
	{
	}

	function EnemyAcquired ()
	{
	}

	function SetFall ()
	{
	}

	function Timer ()
	{
	}

	function FearThisSpot (Actor ASpot)
	{
	}

	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}

	function HandleHelpMessageFrom (Pawn Other)
	{
	}

	function MayFall ()
	{
	}

	function ShootTarget (Actor NewTarget)
	{
	}

	function HearPickup (Pawn Other)
	{
	}

	function SetOrders (name NewOrders, Pawn OrderGiver, optional bool bNoAck)
	{
	}

}

state StakeOut
{
	function EndState ()
	{
	}

	function BeginState ()
	{
	}

	function bool ContinueStakeOut ()
	{
	}

	function FindNewStakeOutDir ()
	{
	}

	function bool ClearShot ()
	{
	}

	function Rotator AdjustAim (float projSpeed, Vector projStart, int aimerror, bool leadTarget, bool WarnTarget)
	{
	}

	function Timer ()
	{
	}

	function bool SetEnemy (Pawn NewEnemy)
	{
	}

	function SetFall ()
	{
	}

	function HearNoise (float Loudness, Actor NoiseMaker)
	{
	}

	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}

}

state Dying
{
	function BeginState ()
	{
	}

	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}

	function RestartPlayer ()
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

state RangedAttack
{
	function BeginState ()
	{
	}

	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}

}

state Retreating
{
	function BeginState ()
	{
	}

	function PickDestination ()
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

state TacticalMove
{
	function PickRegDestination (bool bNoCharge)
	{
	}

	function PickDestination (bool bNoCharge)
	{
	}

	function GiveUpTactical (bool bNoCharge)
	{
	}

	function Timer ()
	{
	}

}

state Following
{
	function EndState ()
	{
	}

	function BeginState ()
	{
	}

	function ShareWith (Pawn Other)
	{
	}

	function AnimEnd ()
	{
	}

	function PickDestination ()
	{
	}

	function HitWall (Vector HitNormal, Actor Wall)
	{
	}

	function EnemyAcquired ()
	{
	}

	function SetFall ()
	{
	}

	function Timer ()
	{
	}

	function FearThisSpot (Actor ASpot)
	{
	}

	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}

	function HandleHelpMessageFrom (Pawn Other)
	{
	}

	function MayFall ()
	{
	}

	function ShootTarget (Actor NewTarget)
	{
	}

	function HearPickup (Pawn Other)
	{
	}

	function SetOrders (name NewOrders, Pawn OrderGiver, optional bool bNoAck)
	{
	}

}

state Waiting
{
	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}

	function AnimEnd ()
	{
	}

}

state TakeHit
{
	function BeginState ()
	{
	}

	function PlayHitAnim (Vector HitLocation, float Damage)
	{
	}

	function Timer ()
	{
	}

	function Landed (Vector HitNormal)
	{
	}

	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}

}

function bool CanImpactJump ()
{
}

function bool CloseToPointMan (Pawn Other)
{
}

function FireWeapon ()
{
}

function bool CanTossWeaponTo (Pawn aPlayer)
{
}

function Bump (Actor Other)
{
}

function Falling ()
{
}

function SetMovementPhysics ()
{
}

function Carcass SpawnCarcass ()
{
}

state startup
{
}

function InitPawn ()
{
}

simulated event Destroyed ()
{
}

simulated function PostBeginPlay ()
{
}


defaultproperties
{
}

