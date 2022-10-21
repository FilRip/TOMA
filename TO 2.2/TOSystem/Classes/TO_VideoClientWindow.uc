//=============================================================================
// TO_VideoClientWindow
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_VideoClientWindow extends UMenuVideoClientWindow;


///////////////////////////////////////
// MessageBoxDone
///////////////////////////////////////

function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
	if(W == ConfirmDriver)
	{
		ConfirmDriver = None;
		if(Result == MR_Yes)
		{
			GetParent(class'UWindowFramedWindow').Close();
			Root.Console.CloseUWindow();
			GetPlayerOwner().ConsoleCommand("RELAUNCH -changevideo TO-Logo-Map.unr?game=TOSystem.TO_Intro INI=TacticalOps.ini USERINI=TOUser.ini LOG=TacticalOps.log");
		}
	}
  else
		Super.MessageBoxDone(W,Result);
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
}
