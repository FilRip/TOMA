class TO_AlarmPoint extends Engine.NavigationPoint;

var s_bot BotUsing;
var float ducktime;
var bool bNotUsing;
var bool GetUp;
var bool bUsed;
var Actor ShootTargetActor;
var bool bComplete;
var float pausetime;
var name WalkTarget;
var name ShootTarget;
var float Priority;
enum ETeams {
	ET_Terrorists,
	ET_SpecialForces,
	ET_Both
};
var ETeams ActivatedBy;
var Actor WalkTargetTrg;
var float ShootDelay;
var float Radius;
var bool bTriggerOnce;

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


defaultproperties
{
}

