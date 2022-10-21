//------------------------------------------------------------------------------
// PROJECT : Tactical Ops ServerAdmin Tool
// FILE    : TOST_SemiAdmin.uc
// VERSION : 1.0
// INFO    : Handles Semi Admin Functions
// AUTHOR  : Xian
//------------------------------------------------------------------------------
// CHANGES :
// v1.0     + Initial version
//------------------------------------------------------------------------------

class TOST_SemiAdmin expands TOST_ServerModule;

// =============================================================================
// Configuration

var struct SAS
{
   var int Level;
   var bool bSilent;
} SemiAdminStatus[32];

// =============================================================================
// Semi Admin options

var int SemiAdminLevel[32];

var int Terrorists;
var int SWATForces;

// =============================================================================
// Semi Admin Handling

function MKTeams (s_Player Player, byte Type)
{
   local int Difference;
   local Pawn Pawn;

   Difference = ((Terrorists - SWATForces) / 2);

   if (Difference > 0)
   {
      do
      {
          Pawn = GetPlayer(0);
          ChangePlayerTeam(Pawn,Type,Player);
          -- Difference;
      } until (Difference == 0);
   }
   else
   {
      do
      {
          Pawn = GetPlayer(1);
          ChangePlayerTeam(Pawn,Type,Player);
          -- Difference;
      } until (Difference == 0);
   }
}

function ChangePlayerTeam (Pawn Pawn, byte Type, s_Player Player)
{
   if (Pawn != None)
   {
      if (Pawn.IsA('s_Player'))
      {
         if (TO_PRI(Pawn.PlayerReplicationInfo).bHasBomb)
         {
            s_C4(Pawn.FindInventoryType(Class 's_C4')).Destroy();
            Engine.Game.GiveBomb();
         }

         s_Player(Pawn).ClearProgressMessages();
         s_Player(Pawn).SetProgressTime(5);
         s_Player(Pawn).SetProgressMessage("You are now on the opposite team!",0);
      }

      if (Pawn.IsA('s_Bot'))
      {
         if (TO_BRI(Pawn.PlayerReplicationInfo).bHasBomb)
         {
            s_C4(Pawn.FindInventoryType(Class 's_C4')).Destroy();
            Engine.Game.GiveBomb();
         }
      }

      Engine.Game.ChangeTeam(Pawn, GetOppositeTeam(Pawn));
      Engine.Game.AddDefaultInventory(Pawn);
      BroadcastAction(Player,Type,Pawn);
   }
}

function ChangeMap (coerce string Map, s_Player Player)
{
   local string NextMap;
   local Class <GameInfo> Game;
   local bool bRestart;

   Game = Engine.Game.Class;

   if (Map == "")
   {
      NextMap = "?restart";
      bRestart = True;
   }
   else
      NextMap = Map;

   if (bRestart)
      Engine.BroadcastEvent(2,-1,Player.GetHumanName() @ "restarted the current map",Self,None,False);
   else
      Engine.BroadcastEvent(0,1,Player.GetHumanName() @ "changed the map to " $ Map,Self,None,False);

   Level.ServerTravel(NextMap$"?game="$Game, false);
}

function Punish (s_Player Player, int VictimID, int Damage)
{
   local bool bDead;
   local Pawn Victim;

   if ((Player == None) || (VictimID == -1))
      return;

   Victim = Engine.GetPlayerByID(VictimID);

   bDead = (Victim.Health <= Damage);
   Victim.Health -= Damage;

   if (bDead)
      Engine.BroadcastEvent(0,1,Player.GetHumanName() @ "punished" @ Victim.GetHumanName() @ "with death",Self,None,False);
   else
      Engine.BroadcastEvent(0,1,Player.GetHumanName() @ "punished" @ Victim.GetHumanName() @ "with" @ Damage @ "dmg",Self,None,False);
}

function int GetLevel (s_Player Player)
{
   local int ID;

   ID = Engine.GetPlayerIndex(Player);

   if (ID != -1)
      return SemiAdminStatus[ID].Level;
   else
      return -1;
}

// =============================================================================
// TOST Engine Functions

// =============================================================================
// Semi Admin Specific Functions

// Player Handling

function GetPlayers ()
{
   local s_GameReplicationInfo GRI;

   GRI = s_GameReplicationInfo(Engine.Game.GameReplicationInfo);

   if (GRI == None)
      return;

   Terrorists = GRI.Teams[0].Size;
   SWATForces = GRI.Teams[1].Size;
}

function Pawn GetPlayer (int Team)
{
   local Pawn PrevPawn;
   local Pawn NextPawn;

   PrevPawn = Level.Pawnlist;
   NextPawn = None;

   while (NextPawn == None)
   {
      if (PrevPawn.PlayerReplicationInfo.Team == Team)
         NextPawn = PrevPawn;

      if (PrevPawn.NextPawn != None)
         PrevPawn = PrevPawn.NextPawn;
   }

   for (PrevPawn = Level.PawnList; PrevPawn != None; PrevPawn = PrevPawn.NextPawn)
   {
      if ((PrevPawn.PlayerReplicationInfo.Team == Team) && (PrevPawn.PlayerReplicationInfo.StartTime > NextPawn.PlayerReplicationInfo.StartTime))
         NextPawn = PrevPawn;
   }

   return NextPawn;
}

function int GetOppositeTeam (Pawn Pawn)
{
   if (Pawn == None)
      return 255;
   else
      return (1 - Pawn.PlayerReplicationInfo.Team);
}

// Messaging

function BroadcastAction (s_Player Player, int Action, optional Pawn Pawn)
{
   local string Admin;
   local string Message;
   local string Name;
   local string Type;
   local byte AdminType;
   local int ID;

   if (Player != None)
   {
      ID = Engine.GetPlayerIndex(Player);

      if (Player.bAdmin)
         AdminType = 0;

      if (ID != -1)
      {
         if (SemiAdminStatus[ID].Level > 0)
            AdminType = 1;

         if (SemiAdminStatus[ID].bSilent)
            AdminType = 2;
      }
   }
   else
       AdminType = 3;

   if (Pawn != None)
      Name = ("on" @ Pawn.GetHumanName());

   switch AdminType
   {
      case 0 : Type = "Admin"; break;
      case 1 : Type = "Semi Admin"; break;
      case 2 : Type = "Silent Admin"; break;
      case 3 : Type = "Auto"; break;
   }

   switch Action
   {
      case 0 : Message = "Team Balance executed"; break;
      case 1 : Message = "Team Change executed" @ Name; break;
   }

   Engine.BroadcastEvent(2,-1,Admin @ Message,Self,None,True);
}

// =============================================================================
// Default Properties

defaultproperties
{
   ID="TOST Semi Admin"
   Version="v1.00"
   Build="100"
   bServerSide=True
}
