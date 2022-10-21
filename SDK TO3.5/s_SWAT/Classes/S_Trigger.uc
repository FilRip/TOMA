class S_Trigger extends Engine.Triggers;

var bool bInitiallyActive;
enum ETriggerType {
	TT_PlayerProximity,
	TT_PawnProximity,
	TT_ClassProximity,
	TT_AnyProximity,
	TT_Shoot,
	TT_Use
};
var ETriggerType TriggerType;
var bool bForceRoundPlay;
var Actor TriggerActor;
var float TriggerTime;
var float ReTriggerDelay;
var Actor TriggerActor2;
var float RepeatTriggerTime;
var bool bTriggerOnceOnly;
var S_Trigger NextTrigger;
var s_SWATPathNode TriggerSWATPathNode;
var bool bActivated;
enum ETeams {
	ET_Terrorists,
	ET_SpecialForces,
	ET_Both
};
var ETeams ActivatedBy;
var bool bInitiallyActiveBackup;
var bool bFirstTime;
var float DamageThreshold;
var name OptionalSWATPathNode;
var float Radius;
var bool bUseRadius;
var Actor ClassProximityType;

function PreBeginPlay ()
{
}

function PostBeginPlay ()
{
}

function FindTriggerActor ()
{
}

function Actor SpecialHandling (Pawn Other)
{
}

function CheckTouchList ()
{
}

state NormalTrigger
{
}

state OtherTriggerToggles
{
	function Trigger (Actor Other, Pawn EventInstigator)
	{
	}

}

state OtherTriggerTurnsOn
{
	function Trigger (Actor Other, Pawn EventInstigator)
	{
	}

}

state OtherTriggerTurnsOff
{
	function Trigger (Actor Other, Pawn EventInstigator)
	{
	}

}

function bool IsRelevant (Actor Other)
{
}

function bool CanBeActivated (Pawn Other)
{
}

function Touch (Actor Other)
{
}

function Timer ()
{
}

function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
{
}

function UnTouch (Actor Other)
{
}

function Use (Actor Other)
{
}

function TriggerObjective ()
{
}

function ResetTrigger ()
{
}

function bool IsRoundPeriodPlaying ()
{
}


defaultproperties
{
}

