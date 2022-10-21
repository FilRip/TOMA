//=============================================================================
// TO_CreditsHUD
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_CreditsHUD extends CHNullHud;


var	TO_Credits	Credits;


///////////////////////////////////////
// Destroyed 
///////////////////////////////////////

simulated event Destroyed()
{
	if ( Credits != None )
	{
		Credits.Destroy();
		Credits = None;
	}

	Super.Destroyed();
}


///////////////////////////////////////
// PostRender
///////////////////////////////////////

function PostRender( canvas Canvas )
{
	if ( Credits == None )
	{
		Credits = Pawn(Owner).Spawn(class'TO_Credits', Owner);
	
		if ( Credits != None )
			Credits.Initialize(0, Canvas.ClipY / 40.0, Canvas.ClipX, Canvas.ClipY - Canvas.ClipY / 40.0, Font(DynamicLoadObject("LadderFonts.UTLadder14", class'Font')), Canvas.ClipY / 10.0);
	}

	if ( Credits != None )
		Credits.RenderCredits(Canvas);

	//Super.PostRender(Canvas);
}


///////////////////////////////////////
// DisplayMessages
///////////////////////////////////////

simulated function bool DisplayMessages( canvas C )
{
	if ( PlayerPawn(Owner).Player.Console.bTyping )
		DrawTypingPrompt(C, PlayerPawn(Owner).Player.Console);

	return true;
}

function Tick(float Delta) {}

defaultproperties
{
}
