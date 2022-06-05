class TO_ConsoleTimer extends TacticalOpsMapActors;

enum EInstigator
{
	EI_Terrorists,
	EI_SpecialForces,
	EI_BothTeams,
	EI_OtherActor,
	EI_Any
};

var() EInstigator CanBeActivatedBy;
var() bool bCanResumeProgress;
var() bool bDisplayProgressBar;
var() float CTDuration;
var() float CTRadiusRange;
var() localized string CTMessage;
var() Sound SoundActivated;
var() Sound SoundFailed;
var() Sound SoundCompleted;
var(Events) name EventActivated;
var(Events) name EventFailed;
var(Events) name EventCompleted;
var bool bActive;
var bool bBeingActivated;
var Actor instigatedBy;
var float Progress;
var float ProgressStart;
var Actor CTPathnode;

final function bool IsRevelant (Actor Other)
{
}

final function bool CTActivate (Actor Instigator)
{
}

final function CTFailed ()
{
}

final function CTComplete ()
{
}

function RoundReset ()
{
}
