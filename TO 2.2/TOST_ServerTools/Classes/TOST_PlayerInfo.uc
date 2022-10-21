//------------------------------------------------------------------------------
// PROJECT : Tactical Ops ServerAdmin Tool
// FILE    : TOST_PlayerInfo.uc
// VERSION : 1.0
// INFO    : Handles Voting, TeamKills and Renames
// AUTHOR  : Xian
//------------------------------------------------------------------------------
// CHANGES :
// v1.0     + Initial version
//------------------------------------------------------------------------------

class TOST_PlayerInfo expands TOST_ServerModule config (TOST_Server);

// =============================================================================
// Configuration

var () config int MaxTeamKills;                                                 // Maximum Allowed TeamKills
var () config int MaxRenames;                                                   // Maximum Allowed Renames
var () config bool bEnhancedVotes;                                              // Is Enh. Vote System enabled ?
var () config bool bBotSupport;                                                 // Are bots supported ?

var struct StructPI
{
   var int TeamKills;                                                           // Current Player TeamKills
   var int Renames;                                                             // Current Player Renames
   var int Votes;                                                               // Internal kick votes
   var float LastFF;                                                            // Last FF Event
   var string PlayerName;                                                       // Current Player Name
   var string Stats;                                                            // Last Killer Stats
   var Pawn TeamKiller;                                                         // Pointer to the TeamKiller
} PlayerInfo[32];                                                               // Pointer to the Player Info

// =============================================================================
// TOST Engine Functions

function NotifyPlayer_Disconnect (s_Player Player)
{
   local int ID;

   if (Player == None)
      return;

   ID = Engine.GetPlayerIndex(Player);

   if (ID == -1)
      return;

   PlayerInfo[ID].Renames = 0;
   PlayerInfo[ID].TeamKills = 0;
   PlayerInfo[ID].PlayerName = "";
   PlayerInfo[ID].Stats = "";
   PlayerInfo[ID].TeamKiller = None;

   Super.NotifyPlayer_Disconnect(Player);
}

function NotifyPlayer_ChangeName (s_Player Player)
{
   local string Message;
   local PlayerReplicationInfo PRI;

   if ((Player == None) || (Player.PlayerReplicationInfo == None))
      return;

   PRI = Player.PlayerReplicationInfo;

   if (!(PRI.PlayerName ~= PRI.OldName))
   {
      Message = (PRI.OldName @ "is now known as" @ PRI.PlayerName);
      Engine.LogEvent(Message,'Config',Self);
      Engine.BroadcastEvent(1,0,Message,Self,Player,True);
      CalculateRenames(Player);
   }

   Super.NotifyPlayer_ChangeName(Player);
}

function NotifyEvent_PeriodChanged ()
{
   local int i;
   local int Period;

   Period = Engine.GetGamePeriod();

   if (Period == 0)
   {
      for (i = 0; i < 32; ++ i)
      {
         if (PlayerInfo[i].TeamKiller != None)
            PlayerInfo[i].TeamKiller = None;

         if (PlayerInfo[i].Stats != "")
            PlayerInfo[i].Stats = "";

         if (Engine.Game.RoundNumber > 0)
            KillTKers();
         else if (Engine.Game.RoundNumber == 0)
         {
            if (PlayerInfo[i].Renames != 0)
               PlayerInfo[i].Renames = 0;

            if (PlayerInfo[i].TeamKills != 0)
               PlayerInfo[i].TeamKills = 0;
         }
      }
   }

   Super.NotifyEvent_PeriodChanged();
}

function NotifyEvent_Suicide (Pawn Victim, name DamageType, Pawn Killer)
{
   local string Message;
   local s_Player Player;

   if ((Victim == None) || !Victim.IsA('s_Player'))
      return;

   Player = s_Player(Victim);
   Message = (Player.GetHumanName() @ "committed suicide...");
   Engine.BroadcastEvent(1,0,Message,Self,Player,True);
   Message = "You committed suicide...";
   Engine.BroadcastEvent(0,0,Message,Self,Player,True);

   Super.NotifyEvent_Suicide(Victim, DamageType, Killer);
}

function NotifyEvent_EnemyKill (int KillerID, int VictimID, string KillerWeapon, string VictimWeapon, name DamageType)
{
   local string Weapon;
   local string Stats;
   local string Message;
   local s_Player Killer;
   local s_Player Victim;
   local int ID;

   Killer = Engine.GetPlayerByID(KillerID);
   Victim = Engine.GetPlayerByID(VictimID);

   ID = Engine.GetPlayerIndex(Victim);

   if (ID == -1)
      return;

   if ((Killer != None) && (Victim != None) && (Killer != Victim))
   {
      Weapon = GetWeapon(KillerWeapon, None, DamageType);
      Stats = GetStats(Killer);
      Message = Killer.GetHumanName() @ "(" @ Stats @ ") killed you" @ Weapon;
      PlayerInfo[ID].Stats = Message;
      Engine.BroadcastEvent(0,0,Message,Self,Victim,True);
   }

   Super.NotifyEvent_EnemyKill(KillerID, VictimID, KillerWeapon, VictimWeapon, DamageType);
}

function NotifyEvent_TeamKill (int KillerID, int VictimID, string KillerWeapon, string VictimWeapon, name DamageType)
{
   local string Message;
   local s_Player Killer;
   local s_Player Victim;
   local int ID;

   Killer = Engine.GetPlayerByID(KillerID);
   Victim = Engine.GetPlayerByID(VictimID);

   ID = Engine.GetPlayerIndex(Victim);

   if (ID == -1)
      return;

   if ((Killer != None) && (Victim != None) && (Killer != Victim))
   {
      Message = ("You teamkilled" @ Victim.GetHumanName());
      Engine.BroadcastEvent(0,0,Message,Self,Killer,True);
      Message = (Killer.GetHumanName() @ "teamkilled you...");
      Engine.BroadcastEvent(0,0,Message,Self,Victim,True);
      PlayerInfo[ID].TeamKiller = Killer;
      PlayerInfo[ID].Stats = Message;
      CalculateTKs(Killer);

      if (bEnhancedVotes)
         CalculateVotes(Killer);
   }

   Super.NotifyEvent_TeamKill(KillerID, VictimID, KillerWeapon, VictimWeapon, DamageType);
}

function NotifyEvent_TakeDamage (out int Damage, Pawn Victim, Pawn Killer, out vector Momentum, name DamageType)
{
   local PlayerReplicationInfo KillerPRI, VictimPRI;
   local string Message;
   local s_Player Player;
   local int ID;

   KillerPRI = Killer.PlayerReplicationInfo;
   VictimPRI = Victim.PlayerReplicationInfo;

   if ((KillerPRI != None) && (VictimPRI != None) && (KillerPRI != VictimPRI))
   {
      if (Killer.IsA('s_Player'))
      {
         Player = s_Player(Killer);
         ID = Engine.GetPlayerIndex(Player);
      }

      if ((KillerPRI.Team == VictimPRI.Team) && (Damage > 0))
      {
         if (ID != -1)
         {
            if ((Level.TimeSeconds - PlayerInfo[ID].LastFF) > 10)
            {
               Message = (KillerPRI.PlayerName @ "(ID:" @ KillerPRI.PlayerID $ ") shot at" @ VictimPRI.PlayerName);
               PlayerInfo[ID].LastFF = Level.TimeSeconds;
            }

            Engine.BroadcastEvent(0,0,"You attacked" @ VictimPRI.PlayerName,Self,Player,True);
         }
         else
            Message = (KillerPRI.PlayerName @ "shot at" @ VictimPRI.PlayerName);
      }

      Engine.BroadcastEvent(2,-1,Message,Self,None,True);
   }

   Super.NotifyEvent_TakeDamage(Damage, Victim, Killer, Momentum, DamageType);
}

function NotifyEvent_Scoring (Pawn Killer, Pawn Victim)
{
   local s_Player Player;
   local string Weapon;
   local string Stats;
   local string Message;
   local int ID;

   if ((Killer != None) && (Victim != None) && (Killer != Victim) && (Killer.Weapon != None)
   && (Victim.PlayerReplicationInfo != None) && (Killer.PlayerReplicationInfo != None))
   {
      if (Victim.PlayerReplicationInfo.Team != Killer.PlayerReplicationInfo.Team)
      {
         if (Victim.IsA('s_Player') && Killer.IsA('s_Bot') && bBotSupport)
         {
            Player = s_Player(Victim);
            ID = Engine.GetPlayerIndex(Player);

            if (ID == -1)
               return;

            Weapon = GetWeapon(Killer.Weapon.ItemName, Killer.Weapon, '');
            Stats = GetStats(Killer);
            Message = Killer.GetHumanName() @ "(" @ Stats @ ") killed you" @ Weapon;
            PlayerInfo[ID].Stats = Message;
            Engine.BroadcastEvent(0,0,Message,Self,Player,True);
         }
      }
      else
      {
         Message = (Killer.GetHumanName() @ "teamkilled" @ Victim.GetHumanName());
         Engine.BroadcastEvent(2,-1,Message,Self,None,True);
      }
   }
}

function NotifyEvent_Tick ()
{
   local int TotalPlayers;
   local int NeededVotes;
   local int ID;
   local Pawn Pawn;
   local s_Player Player;

   Super.NotifyEvent_Tick();

   if (!bEnhancedVotes)
      return;

   TotalPlayers = Engine.Game.Numplayers;
   NeededVotes = Max(Min((TotalPlayers - 2), (TotalPlayers / 2)), 1);

   for (Pawn = Level.PawnList; Pawn != None; Pawn = Pawn.NextPawn)
   {
      if (Pawn.IsA('s_Player'))
      {
         Player = s_Player(Pawn);
         ID = Engine.GetPlayerIndex(Player);

         if (ID == -1)
            return;

         if (PlayerInfo[ID].Votes > NeededVotes)
         {
            PlayerInfo[ID].Votes = 0;
            Engine.BroadcastLocalizedEvent(Class 's_MessageVote', 1, Player.PlayerReplicationInfo);
            Engine.RemovePlayer(Player, 6, "Voted out of the game");
         }
      }
   }
}

function ExecuteFunction (int Function, Actor Sender, optional coerce string Text, optional string sResult, optional int iResult, optional float fResult, optional bool bResult, optional byte eResult)
{
   switch Function
   {
      case 53 : ForgiveTKers(iResult); break;
      case 54 : PunishTKers(iResult); break;
      case 55 : GetKillerStats(iResult); break;
   }

   Super.ExecuteFunction(Function,Sender,Text,sResult,iResult,fResult,bResult,eResult);
}

function bool CheckFunction (int Function, Actor Sender, optional coerce string Text, optional string sResult, optional int iResult, optional float fResult, optional bool bResult, optional byte eResult)
{
   switch Function
   {
      case 53 : return True; break;
      case 54 : return True; break;
      case 55 : return True; break;
      default : return Super.CheckFunction(Function,Sender,Text,sResult,iResult,fResult,bResult,eResult); break;
   }
}

// =============================================================================
// Killer Stats Handling

function string GetWeapon (coerce string WeaponID, Weapon Weapon, name DamageType)
{
   local string FirstLetter;
   local string ItemName;
   local string Message;

   if ((Weapon == None) && (WeaponID == ""))
      return Message;

   if (DamageType == 'Explosion')
      ItemName = "Nade";
   else
   {
      if (Weapon != None)
         ItemName = Weapon.ItemName;
      else
         ItemName = WeaponID;
   }

   FirstLetter = (Left(ItemName, 1));
   if ((FirstLetter ~= "a") || (FirstLetter ~= "e") || (FirstLetter ~= "i") || (FirstLetter ~= "o") || (FirstLetter ~= "u"))
      Message = ("with an" @ ItemName);
   else
      Message = ("with a" @ ItemName);

   return Message;
}

function string GetStats (Pawn Pawn)
{
   local string Message;
   local string HP;
   local int Armor;
   local string AP;
   local s_Player Player;
   local s_Bot Bot;

   if (Pawn == None)
      return Message;

   if (Pawn.IsA('s_Player'))
   {
      Player = s_Player(Pawn);

      if (Player.Health > 0)
         HP = Player.Health @ "Health";
      else
         HP = "* Dead *";

      if (HP != "* Dead *")
      {
         Armor = ((Player.HelmetCharge + Player.VestCharge + Player.LegsCharge) / 3);
         AP = "-" @ Armor @ "Armor";
      }
   }

   if (Pawn.IsA('s_Bot') && bBotSupport)
   {
      Bot = s_Bot(Pawn);

      if (Bot.Health > 0)
         HP = Bot.Health @ "Health";
      else
         HP = "* Dead *";

      if (HP != "* Dead *")
      {
         Armor = ((Bot.HelmetCharge + Bot.VestCharge + Bot.LegsCharge) / 3);
         AP = "-" @ Armor @ "Armor";
      }
   }

   Message = HP @ AP;
   return Message;
}

// =============================================================================
// Calculation Routines

function KillTKers ()
{
   local int i;
   local string Message;

   for (i = 0; i < 32; ++ i)
   {
      if (PlayerInfo[i].TeamKiller != None)
      {
         Message = (PlayerInfo[i].TeamKiller @ "was punished for teamkilling...");
         Engine.BroadcastEvent(2,-1,Message,Self,None,True);
         PlayerInfo[i].TeamKiller.KilledBy(None);
         PlayerInfo[i].TeamKiller = None;
      }
   }
}

function PunishTKers (int ID)
{
   local string Message;

   if (ID == -1)
      return;

   if (PlayerInfo[ID].TeamKiller != None)
   {
      Message = (PlayerInfo[ID].PlayerName @ "punished" @ PlayerInfo[ID].TeamKiller.GetHumanName() @ "for teamkilling");
      Engine.BroadcastEvent(2,-1,Message,Self,None,True);
      PlayerInfo[ID].TeamKiller.KilledBy(None);
      PlayerInfo[ID].TeamKiller = None;
   }
}

function ForgiveTKers (int ID)
{
   local string Message;

   if (ID == -1)
      return;

   if (PlayerInfo[ID].TeamKiller != None)
   {
      Message = (PlayerInfo[ID].PlayerName @ "forgave" @ PlayerInfo[ID].TeamKiller.GetHumanName());
      Engine.BroadcastEvent(2,-1,Message,Self,None,True);
      PlayerInfo[ID].TeamKiller = None;
   }
}

function CalculateVotes (s_Player Player)
{
   local int ID;
   local int i;
   local int Votes;
   local TO_PRI PRI;
   local TOST_SemiAdmin SA;

   ID = Engine.GetPlayerIndex(Player);

   if ((ID == -1) || (Player.PlayerReplicationInfo == None))
      return;

   PRI = TO_PRI(Player.PlayerReplicationInfo);
   SA = TOST_SemiAdmin(Engine.GetModuleByID("TOST Semi Admin"));

   for (i = 0; i < 48; ++ i)
   {
      if (PRI.VoteFrom[i] != None)
      {
         if (Player.bAdmin || ((SA != None) && (SA.GetLevel(Player) > 0)))
         {
            PRI.VoteFrom[i] = None;
            Votes = 0;
         }
         else
         {
            if (PRI.VoteFrom[i] != None)
               ++ Votes;

            Votes += PlayerInfo[ID].TeamKills;
         }
      }
   }

   PlayerInfo[ID].Votes = Votes;
}

function CalculateTKs (s_Player Player)
{
   local int ID;
   local string Stats;
   local string Message;

   if ((Player == None) || (MaxTeamKills <= 0))
      return;

   ID = Engine.GetPlayerIndex(Player);

   if (ID == -1)
      return;

   ++ PlayerInfo[ID].TeamKills;
   Stats = (PlayerInfo[ID].TeamKills @ "/" @ MaxTeamKills);

   if (PlayerInfo[ID].TeamKills > MaxTeamKills)
   {
      Engine.RemovePlayer(Player, 5, "for having too many TeamKills");
      return;
   }

   if (PlayerInfo[ID].TeamKills < MaxTeamKills)
      Message = ("You have" @ Stats @ "TeamKills");
   else if (PlayerInfo[ID].TeamKills == MaxTeamKills)
      Message = ("You will be kicked on the next TeamKill");

   Engine.BroadcastEvent(0,0,Message,Self,Player,False);
}

function CalculateRenames (s_Player Player)
{
   local int ID;
   local string Stats;
   local string Message;

   if ((Player == None) || (MaxRenames <= 0))
      return;

   ID = Engine.GetPlayerIndex(Player);

   if (ID == -1)
      return;

   ++ PlayerInfo[ID].Renames;

   if (PlayerInfo[ID].Renames <= MaxRenames)
   {
      PlayerInfo[ID].PlayerName = Player.PlayerReplicationInfo.PlayerName;

      if (PlayerInfo[ID].Renames < MaxRenames)
      {
         Stats = (PlayerInfo[ID].Renames @ "/" @ MaxRenames);
         Message = ("You have" @ Stats @ "name changes");
      }
      else if (PlayerInfo[ID].Renames == MaxRenames)
         Message = ("No more name changes allowed on this map");
   }
   else
   {
      if (PlayerInfo[ID].Renames < (MaxRenames + 5))
      {
         Player.PlayerReplicationInfo.PlayerName = PlayerInfo[ID].PlayerName;
         Player.PlayerReplicationInfo.OldName = PlayerInfo[ID].PlayerName;
         Player.UpdateURL("Name",PlayerInfo[ID].PlayerName,True);

         if (PlayerInfo[ID].Renames == (MaxRenames + 1))
            Message = ("No more name changes allowed on this map");

         if (PlayerInfo[ID].Renames == (MaxRenames + 2))
            Message = ("No more name changes allowed on this map; stop renaming...");

         if (PlayerInfo[ID].Renames == (MaxRenames + 3))
            Message = ("If you continue renaming, you will be kicked...");

         if (PlayerInfo[ID].Renames == (MaxRenames + 4))
            Message = ("This is your final warning...");
      }
      else if (PlayerInfo[ID].Renames == (MaxRenames + 5))
         Engine.RemovePlayer(Player, 5, "for excessive renaming");
   }

   Engine.BroadcastEvent(0,0,Message,Self,Player,False);
}

function GetKillerStats (int ID)
{
   local string Message;
   local s_Player Player;

   Message = PlayerInfo[ID].Stats;
   Player = Engine.GetPlayerByIndex(ID);

   Engine.BroadcastEvent(0,0,Message,Self,Player,True);
}

// =============================================================================
// Default Properties

defaultproperties
{
   MaxTeamKills=3
   MaxRenames=5
   bBotSupport=True

   ID="TOST Player Info"
   Version="v1.10"
   Build="110"
   bServerSide=True
}
