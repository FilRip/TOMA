//------------------------------------------------------------------------------
// PROJECT : Tactical Ops ServerAdmin Tool
// FILE    : TOST_ServerModule.uc
// VERSION : 1.0
// INFO    : Handles Server specific information
// AUTHOR  : Xian
//------------------------------------------------------------------------------
// CHANGES :
// v1.0     + Initial version
//------------------------------------------------------------------------------

class TOST_ServerModule expands TOST_Module;

// =============================================================================
// Configuration

var string ID;                                                                  // ID of the Module
var string Version;                                                             // Module Version; default: Unknown
var string Build;                                                               // Build Version; default: Unknown
var bool bServerSide;                                                           // Is the Package Server Side ?
var int TotalSeconds;                                                           // Total Timer Seconds
var int RemainingSeconds;                                                       // Remaining Timer Seconds
var TOST_ServerModule NextModule;                                               // Pointer to the Next Module

// =============================================================================
// Engine Specific Functions

// Called after being created
function Spawned ()
{
   Super.Spawned();                                                             // Call Super

   ActorID = (ID $ ":");
}

// Called after being destroyed
function Destroyed ()
{
   Super.Destroyed();                                                           // Call Super

   SaveConfig();                                                                // Save current options

   if (ROLE == ROLE_Authority)
   {
      if (NextModule != None)                                                   // Remove Next Module
      {
         NextModule.Destroy();
         NextModule = None;
      }
   }
}

// =============================================================================
// Module Handling

// Adding a new Module to the Chain
final function AddNextModule (TOST_ServerModule Module)
{
    if (Module == None)
       return;

	if (NextModule == None)
	{
		NextModule = Module;
        NextModule.PreInitModule();
	}
	else
	{
        if (Module.Class != NextModule.Class)
		    NextModule.SetNextModule(Module);
	}
}

// Setting a specific Server Module as "NextModule"
final function SetNextModule (TOST_ServerModule Module)
{
    if (Module == None)
       return;

	if (NextModule == None)
	{
		NextModule = Module;
        NextModule.PreInitModule();
	}
	else
	{
        if (Module.Class != NextModule.Class)
        {
           Module.SetNextModule(NextModule);
           NextModule = Module;
           NextModule.PreInitModule();
        }
	}
}

// Reset a specific Module
final function ResetModule (TOST_ServerModule Module)
{
    local TOST_ServerModule Temp;

    if (Module == None)
       return;

	if (NextModule != None)
    {
       if (Module.Class == NextModule.Class)
       {
          Temp = NextModule;
          NextModule.Destroy();
          NextModule = Temp.NextModule;
          Temp.Destroy();
	   }
	   else
          NextModule.ResetModule(Module);
	}
}

// Reset the Next Module
final function ResetNextModule ()
{
    local TOST_ServerModule Temp;

	if (NextModule != None)
    {
       Temp = NextModule.NextModule;
       NextModule.Destroy();
       NextModule = Temp;
       Temp.Destroy();
	}
}

// Attaching Client Modules
function AttachModule (Class <TOST_ClientModule> ModuleClass, s_Player Player)
{
   local TOST_ClientModule Module;
   local int ID;

   ID = Engine.GetPlayerIndex(Player);

   if (ID == -1)
      return;                                                                   // Ignore disconnected players

   // Spawn Module
   Module = Spawn (ModuleClass, Player, ,Player.Location, Player.Rotation);

   if (Module != None)                                                          // Attach the Module
   {
      Module.Engine = Engine;                                                   // Assign Engine
      Module.Module = Self;                                                     // Assign Module Owner
      Module.Player = Player;                                                   // Assign Player
      Module.ServerInit();

      Engine.SetClientModuleByIndex(Module,ID);
   }
   else                                                                         // if Error occurs, log it
      Engine.LogEvent("Failed to attach Client Module -" @ ModuleClass @ "on" @ Player.GetHumanName(), 'Error', Self);
}

// =============================================================================
// TOST Engine Functions

function PreInitModule ()
{
   if (NextModule != None)
      NextModule.PreInitModule();
   RemainingSeconds = TotalSeconds;
}

function PostInitModule ()
{
   if (NextModule != None)
      NextModule.PostInitModule();
}

function NotifyEvent_PeriodChanged ()
{
   if (NextModule != None)
      NextModule.NotifyEvent_PeriodChanged();
}

function NotifyEvent_TakeDamage (out int Damage, Pawn Victim, Pawn Killer, out vector Momentum, name DamageType)
{
   if (NextModule != None)
      NextModule.NotifyEvent_TakeDamage(Damage, Victim, Killer, Momentum, DamageType);
}

function NotifyEvent_Scoring (Pawn Killer, Pawn Victim)
{
   if (NextModule != None)
      NextModule.NotifyEvent_Scoring(Killer, Victim);
}

function NotifyEvent_EnemyKill (int KillerID, int VictimID, string KillerWeapon, string VictimWeapon, name DamageType)
{
   if (NextModule != None)
      NextModule.NotifyEvent_EnemyKill(KillerID, VictimID, KillerWeapon, VictimWeapon, DamageType);
}

function NotifyEvent_TeamKill (int KillerID, int VictimID, string KillerWeapon, string VictimWeapon, name DamageType)
{
   if (NextModule != None)
      NextModule.NotifyEvent_TeamKill(KillerID, VictimID, KillerWeapon, VictimWeapon, DamageType);
}

function NotifyEvent_Suicide (Pawn Victim, name DamageType, Pawn Killer)
{
   if (NextModule != None)
      NextModule.NotifyEvent_Suicide(Victim, DamageType, Killer);
}

function NotifyEvent_Timer ()
{
   if (NextModule != None)
      NextModule.NotifyEvent_Timer();
}

function NotifyEvent_Tick ()
{
   if (NextModule != None)
      NextModule.NotifyEvent_Tick();
}

function NotifyPlayer_Modify (s_Player Player)
{
   if (NextModule != None)
      NextModule.NotifyPlayer_Modify(Player);
}

function NotifyPlayer_ChangeName (s_Player Player)
{
   if (NextModule != None)
      NextModule.NotifyPlayer_ChangeName(Player);
}

function NotifyPlayer_ChangeTeam (s_Player Player)
{
   if (NextModule != None)
      NextModule.NotifyPlayer_ChangeTeam(Player);
}

function NotifyPlayer_Connect (s_Player Player)
{
   if (NextModule != None)
      NextModule.NotifyPlayer_Connect(Player);
}

function NotifyPlayer_Disconnect (s_Player Player)
{
   if (NextModule != None)
      NextModule.NotifyPlayer_Disconnect(Player);
}

function NotifyPlayer_Login (s_Player Player)
{
   if (NextModule != None)
      NextModule.NotifyPlayer_Login(Player);
}

function NotifyMap_Change ()
{
   if (NextModule != None)
      NextModule.NotifyMap_Change();
}

function NotifyMap_Quit ()
{
   if (NextModule != None)
      NextModule.NotifyMap_Quit();
}

function bool NotifyMap_Restart ()
{
   if (NextModule != None)
      return NextModule.NotifyMap_Restart();

   return False;
}

function bool NotifyMap_End ()
{
   if (NextModule != None)
      return NextModule.NotifyMap_End();

   return False;
}

function Notify_Logging (out string Event, out name Type, Actor Sender)
{
   if (NextModule != None)
      NextModule.Notify_Logging(Event,Type,Sender);
}

function bool NotifyMessage_Team (Actor Sender, Pawn Receiver, PlayerReplicationInfo PRI, coerce string Message, name Type, optional bool bBeep)
{
   if (NextModule != None)
      return NextModule.NotifyMessage_Team(Sender,Receiver,PRI,Message,Type,bBeep);

   return True;
}

function bool NotifyMessage_Broadcast (Actor Sender, Pawn Receiver, out coerce string Message, optional bool bBeep, out optional name Type)
{
   if (NextModule != None)
      return NextModule.NotifyMessage_Broadcast(Sender,Receiver,Message,bBeep,Type);

   return True;
}

function bool NotifyMessage_Localized (Actor Sender, Pawn Receiver, out class<LocalMessage> Message, out optional int Switch, out optional PlayerReplicationInfo RelatedPRI_1, out optional PlayerReplicationInfo RelatedPRI_2, out optional Object OptionalObject)
{
   if (NextModule != None)
      return NextModule.NotifyMessage_Localized(Sender,Receiver,Message,Switch,RelatedPRI_1,RelatedPRI_2,OptionalObject);

   return True;
}

function ExecuteFunction (int Function, Actor Sender, optional coerce string Text, optional string sResult, optional int iResult, optional float fResult, optional bool bResult, optional byte eResult)
{
   local bool bHandled;

   bHandled = CheckFunction(Function,Sender,Text,sResult,iResult,fResult,bResult,eResult);

   if (bHandled && (NextModule != None))
      NextModule.ExecuteFunction(Function,Sender,Text,sResult,iResult,fResult,bResult,eResult);

   if (!bHandled && Sender.IsA('s_Player'))
      s_Player(Sender).ClientMessage("Unrecognized command",'TOST');
}

function bool CheckFunction (int Function, Actor Sender, optional coerce string Text, optional string sResult, optional int iResult, optional float fResult, optional bool bResult, optional byte eResult)
{
   if (NextModule != None)
      return NextModule.CheckFunction(Function,Sender,Text,sResult,iResult,fResult,bResult,eResult);

   return True;
}

// =============================================================================
// Default Properties

defaultproperties
{
   ID="Unknown TOST Server Module"
   Version="Unknown"
   Build="Unknown"
   bServerSide=False
}
