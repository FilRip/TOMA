class TO_ConsoleTimer extends TacticalOpsMapActors;

var bool bBeingActivated;
var float Progress;
var Actor instigatedBy;
var bool bActive;
enum EInstigator {
	EI_Terrorists,
	EI_SpecialForces,
	EI_BothTeams,
	EI_OtherActor,
	EI_Any
};
var EInstigator CanBeActivatedBy;
var float CTDuration;
var bool bCanResumeProgress;
var Actor CTPathnode;
var float ProgressStart;
var name EventCompleted;
var name EventFailed;
var name EventActivated;
var Sound SoundCompleted;
var Sound SoundFailed;
var Sound SoundActivated;
var bool bDisplayProgressBar;
var float CTRadiusRange;

final function CTFailed ()
{
}

final function CTComplete ()
{
}

final function bool CTActivate (Actor Instigator)
{
}

final function bool IsRevelant (Actor Other)
{
}

function RoundReset ()
{
}


defaultproperties
{
}

