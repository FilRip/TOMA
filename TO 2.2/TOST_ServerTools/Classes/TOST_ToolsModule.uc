//------------------------------------------------------------------------------
// PROJECT : Tactical Ops ServerAdmin Tool
// FILE    : TOST_ToolsModule.uc
// VERSION : 1.0
// INFO    : Handles Tools ServerSide
// AUTHOR  : Xian
//------------------------------------------------------------------------------
// CHANGES :
// v1.0     + Initial version
//------------------------------------------------------------------------------

class TOST_ToolsModule expands TOST_ServerModule;

// =============================================================================
// TOST Engine Functions

function NotifyPlayer_Connect (s_Player Player)
{
   Super.NotifyPlayer_Connect(Player);

   AttachModule(Class'TOST_ToolsHandler', Player);
}

function bool NotifyMessage_Team (Actor Sender, Pawn Receiver, PlayerReplicationInfo PRI, coerce string Message, name Type, optional bool bBeep)
{
   local string Msg;

   if ((Type == 'TeamSay') && (InStr(Message,"[TeamSay]") == -1))
   {
      Msg = ("[TeamSay] -" @ Message);

      if (Super.NotifyMessage_Team(Sender,Receiver,PRI,Msg,Type,bBeep))
         Receiver.TeamMessage(PRI,Msg,'TeamSay',bBeep);
      return False;
   }

   return Super.NotifyMessage_Team(Sender,Receiver,PRI,Message,Type,bBeep);
}

// =============================================================================
// Default Properties

defaultproperties
{
   ID="TOST Tools Module"
   Version="v1.00"
   Build="100"
   bServerSide=False
}
