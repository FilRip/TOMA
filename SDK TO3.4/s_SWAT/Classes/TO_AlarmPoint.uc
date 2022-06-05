class TO_AlarmPoint extends NavigationPoint;

enum ETeams
{
	ET_Terrorists,
	ET_SpecialForces,
	ET_Both
};

var() float ducktime;
var() float pausetime;
var() name WalkTarget;
var() name ShootTarget[8];
var Actor ShootTargetActor[8];
var() float Priority;
var() bool bTriggerOnce;
var() float Radius;
var() float ShootDelay;
var() ETeams ActivatedBy;
var bool bUsed;
var bool bNotUsing;
var bool bComplete;
var s_bot BotUsing;
var bool GetUp;
var Actor WalkTargetTrg;

function PreBeginPlay ()
{
}

function BeginPlay ()
{
}

function Tick (float DeltaTime)
{
}

function Timer ()
{
}

function NoUse ()
{
}

function UnTouch (Actor Other)
{
}

function Touch (Actor Other)
{
}

state IsResetableActor
{
	function BeginState ()
	{
	}
	
}
