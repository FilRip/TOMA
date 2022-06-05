class S_Trigger extends Triggers;

enum ETeams
{
	ET_Terrorists,
	ET_SpecialForces,
	ET_Both
};

enum ETriggerType
{
	TT_PlayerProximity,
	TT_PawnProximity,
	TT_ClassProximity,
	TT_AnyProximity,
	TT_Shoot,
	TT_Use
};

var() ETriggerType TriggerType;
var() ETeams ActivatedBy;
var() localized string Message;
var() bool bTriggerOnceOnly;
var() bool bInitiallyActive;
var bool bInitiallyActiveBackup;
var bool bFirstTime;
var() Class<Actor> ClassProximityType;
var() float RepeatTriggerTime;
var() float ReTriggerDelay;
var float TriggerTime;
var() float DamageThreshold;
var Actor TriggerActor;
var Actor TriggerActor2;
var bool bActivated;
var() bool bForceRoundPlay;
var(s_UseTrigger) bool bUseRadius;
var(s_UseTrigger) float Radius;
var() name OptionalSWATPathNode;
var s_SWATPathNode TriggerSWATPathNode;
var S_Trigger NextTrigger;

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

state() NormalTrigger
{
}

state() OtherTriggerToggles
{
	function Trigger (Actor Other, Pawn EventInstigator)
	{
	}
	
}

state() OtherTriggerTurnsOn
{
	function Trigger (Actor Other, Pawn EventInstigator)
	{
	}
	
}

state() OtherTriggerTurnsOff
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
