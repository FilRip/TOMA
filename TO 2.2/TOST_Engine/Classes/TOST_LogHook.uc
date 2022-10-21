//------------------------------------------------------------------------------
// PROJECT : Tactical Ops ServerAdmin Tool
// FILE    : TOST_LogHook.uc
// VERSION : 1.0
// INFO    : Log Hook; Send calls to game events on the Mutator
// AUTHOR  : Xian
//------------------------------------------------------------------------------
// CHANGES :
// v1.0     + Initial version
//------------------------------------------------------------------------------

class TOST_LogHook expands TOST_LogModule;

// =============================================================================
// Attachments

var TOST_Mutator Link;                                                          // Pointer to the Mutator
var StatLog NextLog;                                                            // Pointer to the Next Log

// =============================================================================
// Obsolete Functions

function LogSpecialEvent (string Event, string Arg1, string Arg2, string Arg3, string Arg4)
{
   if (NextLog != None)
      NextLog.LogSpecialEvent(Event,Arg1,Arg2,Arg3,Arg4);
}

function LogItemDeactivate (Inventory Item, Pawn Player)
{
   if (NextLog != None)
      NextLog.LogItemDeactivate(Item,Player);
}

function LogItemActivate (Inventory Item, Pawn Player)
{
   if (NextLog != None)
      NextLog.LogItemActivate(Item,Player);
}

function LogTypingEvent (bool bTyping, Pawn Player)
{
   if (NextLog != None)
      NextLog.LogTypingEvent(bTyping,Player);
}

function LogPickup (Inventory Item, Pawn Player)
{
   if (NextLog != None)
      NextLog.LogPickup(Item,Player);
}

function LogEventString (string Event)
{
   if (NextLog != None)
      NextLog.LogEventString(Event);
}

function string GetLogFileName ()
{
   if (NextLog != None)
      NextLog.GetLogFileName();
}

function LogMapParameters ()
{
   if (NextLog != None)
      NextLog.LogMapParameters();
}

function LogStandardInfo ()
{
   if (NextLog != None)
      NextLog.LogStandardInfo();
}

function LogServerInfo ()
{
   if (NextLog != None)
      NextLog.LogServerInfo();
}

function StartLog ()
{
   if (NextLog != None)
      NextLog.StartLog();
}

function StopLog ()
{
   if (NextLog != None)
      NextLog.StopLog();
}

// =============================================================================
// Engine Specific Functions

function LogKill (int KillerID, int VictimID, string KillerWeapon, string VictimWeapon, name DamageType)
{
   if (KillerID != VictimID)
      Link.KillPlayer(KillerID, VictimID, KillerWeapon, VictimWeapon, DamageType);

   if (NextLog != None)
      NextLog.LogKill(KillerID, VictimID, KillerWeapon, VictimWeapon, DamageType);
}

function LogTeamKill (int KillerID, int VictimID, string KillerWeapon, string VictimWeapon, name DamageType)
{
   if (KillerID != VictimID)
      Link.TeamKillPlayer(KillerID, VictimID, KillerWeapon, VictimWeapon, DamageType);

   if (NextLog != None)
      NextLog.LogTeamKill(KillerID, VictimID, KillerWeapon, VictimWeapon, DamageType);
}

function LogSuicide (Pawn Victim, name DamageType, Pawn Killer)
{
   Link.SuicidePlayer(Victim, DamageType, Killer);

   if (NextLog != None)
      NextLog.LogSuicide(Victim,DamageType,Killer);
}

function LogTeamChange (Pawn Player)
{
   if (Player.IsA('s_Player'))
      Link.ChangeTeam(s_Player(Player));

   if (NextLog != None)
      NextLog.LogTeamChange(Player);
}

function LogNameChange (Pawn Player)
{
   if (Player.IsA('s_Player'))
      Link.ChangeName(s_Player(Player));

   if (NextLog != None)
      NextLog.LogNameChange(Player);
}

function LogPlayerConnect (Pawn Player, optional string Checksum)
{
   if (Player.IsA('s_Player'))
      Link.ConnectPlayer(s_Player(Player));

   if (NextLog != None)
      NextLog.LogPlayerConnect(Player,Checksum);
}

function LogPlayerDisconnect (Pawn Player)
{
   if (Player.IsA('s_Player'))
      Link.DisconnectPlayer(s_Player(Player));

   if (NextLog != None)
      NextLog.LogPlayerDisconnect(Player);
}

function LogGameEnd (string Reason)
{
   if (NextLog != None)
      NextLog.LogGameEnd(Reason);

	if (Reason != "")
	{
	   if (Reason ~= "MapChange")
	      Link.ChangeMap();
       else if (Reason ~= "ServerQuit")
          Link.QuitMap();
	}
}

// =============================================================================
// Default Properties

defaultproperties
{
   StatLogFile=""
   LocalLogDir=""
   WorldLogDir=""
   WorldBatcherURL=""
   LocalStatsURL=""
   WorldStatsURL=""
   LocalBatcherParams=""
   WorldBatcherParams=""
   bWorldBatcherError=False

   ActorID="TOST Log Hook:"
}
