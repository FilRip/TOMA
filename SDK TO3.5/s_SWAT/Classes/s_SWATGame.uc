class s_SWATGame extends TO_GameBasics;

var int DistReachThreshold;

final function bool NavigateActor (s_bot B, Actor A, out Actor Best)
{
}

final function bool IsOrderObjective (byte Team, byte ObjectiveNum)
{
}

final function SetAccomplishedObjective (byte Team, byte Number)
{
}

final function bool NavigateSWATPathNode (s_bot B, s_SWATPathNode SPN, out Actor Best)
{
}

final function NavigationPoint FindSWATPathNode (s_bot aBot)
{
}

final function bool IsNullObjective (byte Team, byte ObjectiveNum)
{
}

final function bool IsObjectiveAccomplished (byte Team, byte Num)
{
}

final function bool IsOnceObjective (byte Team, byte ObjectiveNum)
{
}

final function SendGlobalBotObjective (Actor Target, float DesiredAssignment, byte Team, name ObjectiveType, bool bLeadersOnly)
{
}

final function bool ObjectiveAccomplished (Actor Target)
{
}

final function bool CheckOrder (byte Team, byte ObjectiveNum)
{
}

final function bool IsPrimaryObjective (byte Team, byte ObjectiveNum)
{
}

final function bool DoesBotLead (s_bot B)
{
}

final function SetupObjectives ()
{
}

final function bool SetObjectiveAccomplishedTarget (Actor Target)
{
}

final function C4Exploded (bool bExplodedInBombingZone, Actor BombingZone)
{
}

final function C4Defused (Actor Instigator)
{
}

final function bool CanAcceptObjective (s_bot B)
{
}

final function SetNextObjective (s_bot B)
{
}

final function SpecialObjectiveHandling (s_bot B)
{
}

final function bool BotHasEnemy (s_bot B)
{
}

final function bool BotHasObjective (s_bot B)
{
}

final function s_SWATPathNode FindNextSWATPathNode (s_bot B, s_SWATPathNode SPN)
{
}

final function bool IsLastSWATPathNode (s_SWATPathNode SPN)
{
}

final function byte FindObjective (byte Team, name ObjectiveType)
{
}

final function NavigationPoint GetClosestSPN (s_bot aBot, s_SWATPathNode SPN)
{
}

final function bool BotHasMission (s_bot B)
{
}

function bool FindSpecialAttractionFor (Bot aBot)
{
}

function GiveBomb ()
{
}

function BeginRound ()
{
}

function RestartRound (optional string Reason)
{
}

function TOResetGame ()
{
}


defaultproperties
{
}

