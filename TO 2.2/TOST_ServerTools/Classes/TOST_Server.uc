//------------------------------------------------------------------------------
// PROJECT : Tactical Ops ServerAdmin Tool
// FILE    : TOST_Server.uc
// VERSION : 1.0
// INFO    : Server Main Piece; Receives Player Information
// AUTHOR  : Xian
//------------------------------------------------------------------------------
// CHANGES :
// v1.0     + Initial version
//------------------------------------------------------------------------------

class TOST_Server expands TOST_ServerModule;

// =============================================================================
// Attachments

var TOST_Reporter Reporter;                                                     // Pointer to the Status Reporter

// =============================================================================
// TOST Engine Functions

function PostInitModule ()
{
   if (Engine.bUseReporter && (Reporter == None))
      Reporter = Spawn (Class 'TOST_Reporter', Self);

   if (Reporter != None)
      Reporter.Engine = Engine;                                                 // Assign Engine

   Super.PostInitModule();
}

function NotifyPlayer_Connect (s_Player Player)
{
   Super.NotifyPlayer_Connect(Player);

   AttachModule(Class'TOST_Client', Player);
}

function ExecuteFunction (int Function, Actor Sender, optional coerce string Text, optional string sResult, optional int iResult, optional float fResult, optional bool bResult, optional byte eResult)
{
   switch Function
   {
      case 1 : Reporter.LogConnect(TOST_Client(Sender)); break;
      case 2 : Reporter.LogDisconnect(TOST_Client(Sender)); break;
   }

   Super.ExecuteFunction(Function,Sender,Text,sResult,iResult,fResult,bResult,eResult);
}

function bool CheckFunction (int Function, Actor Sender, optional coerce string Text, optional string sResult, optional int iResult, optional float fResult, optional bool bResult, optional byte eResult)
{
   switch Function
   {
      case 1  : return True; break;
      case 2  : return True; break;
      default : return Super.CheckFunction(Function,Sender,Text,sResult,iResult,fResult,bResult,eResult); break;
   }
}

// =============================================================================
// Engine Specific Functions

// Called after being destroyed
function Destroyed ()
{
   if (Reporter != None)
   {
      Reporter.Destroy();
      Reporter = None;
   }

   Super.Destroyed();                                                           // Call Super
}

// =============================================================================
// Default Properties

defaultproperties
{
   ID="TOST Server"
   Version="v1.00"
   Build="100"
   bServerSide=False
}
