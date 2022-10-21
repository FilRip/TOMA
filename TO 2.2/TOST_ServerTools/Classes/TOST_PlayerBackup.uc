//------------------------------------------------------------------------------
// PROJECT : Tactical Ops ServerAdmin Tool
// FILE    : TOST_PlayerBackup.uc
// VERSION : 1.3
// INFO    : Stores Player Game Info (Frags, Deaths, ID, Money etc.)
// AUTHOR  : BugBunny, MadOnion, updated by Xian
//------------------------------------------------------------------------------
// CHANGES :
// v1.3     + Porting to TOST v1.3
// v1.0     + Initial version
//------------------------------------------------------------------------------

class TOST_PlayerBackup expands TOST_ServerModule;

var struct StructPB
{
	var string PlayerName;                                                      // Stores Player's Name
	var string IP;                                                              // Stores Player's IP
	var int Money;                                                              // Stores Player's Money
	var int Kills;                                                              // Stores Player's Frags
	var int Deaths;                                                             // Stores Player's Deaths
	var int PlayTime;                                                           // Stores Player's Play Time
	var float Timestamp;                                                        // Stores Last Time Stamp
	var int ID;                                                                 // Stores Player's ID
} PlayerBackup[255];                                                            // Pointer to the Player Backup

// =============================================================================
// Player & Backup Memory Handling

function int FindIndexByName (string Name)
{
	local int i;

	i = 0;
    while ((i < 255) && (!(PlayerBackup[i].PlayerName ~= Name)))
       ++ i;

	if (i == 255)
	{
		i = 0;
        while ((i < 255) && ((InStr(PlayerBackup[i].PlayerName, Name) != -1) || (InStr(Name, PlayerBackup[i].PlayerName) != -1)))
           ++ i;

		if (i == 255)
		   i = -1;
	}

	return i;
}

function int FindIndexByIP (string IP)
{
	local int i, j;

    j = -1;

	for (i = 0; i < 255; ++ i)
	{
	   if (PlayerBackup[i].IP == IP)
	   {
	      j = i;
	      break;
	   }
    }

	return j;
}

function int FindIndex (string Name, string IP)
{
	local int i, j;

	i = FindIndexByIP (IP);
	j = FindIndexByName(Name);

	if (i == -1)
	   return j;

	if ((j == -1) || (j == i))
	   return i;

	if (PlayerBackup[j].IP == PlayerBackup[i].IP)
		return j;

	return i;
}

function int FindOldestIndex ()
{
	local int i, j;

	j = -1;

	for (i = 0; i < 255; ++ i)
	{
	   if (PlayerBackup[i].PlayerName == "")
	   {
	      j = i;
	      break;
	   }
    }

	if (j == -1)
	{
   	   for (i = 0; i < 255; ++ i)
   	   {
	      if (PlayerBackup[i].Timestamp < PlayerBackup[j].Timestamp)
	      {
             j = i;
             break;
          }
       }
    }

    if (j == -1)
       ++ j;

	return j;
}

function EraseStats (int ID)
{
	local int i;

    for (i = 0; i < 255; ++ i)
    {
       if ((PlayerBackup[i].PlayerName != "") && (PlayerBackup[i].ID != -1))
       {
          if (PlayerBackup[i].ID == ID)
          {
 		     PlayerBackup[i].PlayerName = "";
		     PlayerBackup[i].IP = "";
             PlayerBackup[i].Money = 1000;
             PlayerBackup[i].Deaths = 0;
             PlayerBackup[i].Kills = 0;
             PlayerBackup[i].PlayTime = 1;
	         PlayerBackup[i].Timestamp = 0;
             PlayerBackup[i].ID = -1;
             break;
          }
       }
    }
}

// =============================================================================
// TOST Engine Functions

function NotifyEvent_Tick ()
{
   local int Index;
   local int ID;
   local string IP;
   local TO_PRI PRI;
   local Pawn Pawn;
   local s_Player Player;

   for (Pawn = Level.PawnList; Pawn != None; Pawn = Pawn.NextPawn)
   {
      if (Pawn.IsA('s_Player'))
      {
         Player = s_Player(Pawn);

         if (Player != None)
         {
            PRI = TO_PRI(Player.PlayerReplicationInfo);
            ID = Engine.GetPlayerIndex(Player);

            if (PRI == None)
               return;

            IP = ResolveHost(Player.GetPlayerNetworkAddress(), 0);
            Index = FindIndex (PRI.PlayerName, IP);

            if (Index != -1)
            {
               PlayerBackup[Index].Timestamp = Level.TimeSeconds;
               PlayerBackup[Index].PlayTime = Level.TimeSeconds - PRI.StartTime;
            }
         }
      }
   }

   Super.NotifyEvent_Tick();
}

function NotifyPlayer_ChangeName (s_Player Player)
{
   local PlayerReplicationInfo PRI;
   local int Index;
   local string IP;

   if ((Player == None) || (Player.PlayerReplicationInfo == None))
      return;

   IP = ResolveHost(Player.GetPlayerNetworkAddress(), 0);
   PRI = Player.PlayerReplicationInfo;
   Index = FindIndex (PRI.PlayerName, IP);

   if (PlayerBackup[Index].PlayerName != PRI.PlayerName)
      PlayerBackup[Index].PlayerName = PRI.PlayerName;

   Super.NotifyPlayer_ChangeName(Player);
}

function NotifyPlayer_Login (s_Player Player)
{
   local int Index;
   local string IP;
   local TO_PRI PRI;

   PRI = TO_PRI(Player.PlayerReplicationInfo);

   if (PRI == None)
      return;

   IP = ResolveHost(Player.GetPlayerNetworkAddress(), 0);
   Index = FindIndex (PRI.PlayerName, IP);

   if (Index != -1)
   {
      PlayerBackup[Index].Timestamp = Level.TimeSeconds;
      PlayerBackup[Index].PlayerName = PRI.PlayerName;
      PlayerBackup[Index].IP = IP;
      Player.Money = PlayerBackup[Index].Money;
      PRI.Score = PlayerBackup[Index].Kills;
      PRI.Deaths = PlayerBackup[Index].Deaths;
      PRI.PlayerID = PlayerBackup[Index].ID;
      PRI.StartTime = (PlayerBackup[Index].Timestamp - PlayerBackup[Index].PlayTime);
   }
   else
   {
      Index = FindOldestIndex();

      PlayerBackup[Index].PlayTime = 0;
      PlayerBackup[Index].Timestamp = Level.TimeSeconds;
      PlayerBackup[Index].PlayerName = PRI.PlayerName;
      PlayerBackup[Index].IP = IP;
      PlayerBackup[Index].Money = Player.Money;
      PlayerBackup[Index].Kills = PRI.Score;
      PlayerBackup[Index].Deaths = PRI.Deaths;

      if (PlayerBackup[Index].ID == -1)
         PlayerBackup[Index].ID = PRI.PlayerID;
      else
         PRI.PlayerID = PlayerBackup[Index].ID;
   }

   Super.NotifyPlayer_Login(Player);
}

function NotifyPlayer_Disconnect (s_Player Player)
{
   local int Index;
   local string IP;
   local TO_PRI PRI;

   PRI = TO_PRI(Player.PlayerReplicationInfo);

   if (PRI == None)
      return;

   IP = ResolveHost(Player.GetPlayerNetworkAddress(), 0);
   Index = FindIndex (PRI.PlayerName, IP);

   if (Index == -1)
      return;

   PlayerBackup[Index].PlayerName = PRI.PlayerName;
   PlayerBackup[Index].IP = IP;
   PlayerBackup[Index].Money = Player.Money;
   PlayerBackup[Index].Kills = PRI.Score;
   PlayerBackup[Index].Deaths = PRI.Deaths;
   PlayerBackup[Index].ID = PRI.PlayerID;

   Super.NotifyPlayer_Disconnect(Player);
}

function ExecuteFunction (int Function, Actor Sender, optional coerce string Text, optional string sResult, optional int iResult, optional float fResult, optional bool bResult, optional byte eResult)
{
   switch Function
   {
      case 50 : EraseStats(iResult); break;
   }

   Super.ExecuteFunction(Function,Sender,Text,sResult,iResult,fResult,bResult,eResult);
}

function bool CheckFunction (int Function, Actor Sender, optional coerce string Text, optional string sResult, optional int iResult, optional float fResult, optional bool bResult, optional byte eResult)
{
   switch Function
   {
      case 50 : return True; break;
      default : return Super.CheckFunction(Function,Sender,Text,sResult,iResult,fResult,bResult,eResult); break;
   }
}

// =============================================================================
// Default Properties

defaultproperties
{
   ID="TOST Player Backup"
   Version="v1.30"
   Build="105"
   bServerSide=True
}
