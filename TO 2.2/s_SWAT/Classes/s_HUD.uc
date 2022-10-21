//=============================================================================
// s_HUD 
//=============================================================================
//
// Tactical Ops -- an Unreal Tournament modification
// -- http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_HUD extends ChallengeTeamHUD
	config;


var		string							s_team[2];
/*
var		SpeechWindow				s_SWATWindow;
var		SpeechWindow				SpeechOld;
*/
var		UWindowRootWindow		Root;
var		bool								bShowObjectives;

// ConsoleTimer
var		bool								bDrawCT;
var		float								CTVal;
var		TO_ConsoleTimer			CT;
//var		s_ExplosiveC4				C4;

var		byte								rmap;
var		byte								NightvisionFrame;
var		byte								lastnightvisionframe;
var		float								lastnightvisiondelta;
var		Color								GreyColor;

var		float		OldScale, Scale8, Scale16, Scale32, Scale64, Scale128, Scale256, 
								Scale80, Scale40, Scale12, Scale112, Scale72;

var		bool		bDisplayMapChangeMessage;
var		bool		bHUDModFix, bHideWidescreen;
var		bool		bHideHud;

// Deaths messages
struct s_DeathMessages
{
	var		String		Killer;
	var		String		Victim;
	var		color			KillerC;
	var		color			VictimC;
	var		byte			EndOfLife;
};


var		s_DeathMessages	s_DeathM[6];
var		int							s_DeathM_idx;

// Money
struct s_MoneyM
{
	var		int				Amount;
	var		byte			EndOfLife;
};


var		s_MoneyM				MoneyM[6];
var		byte						MoneyM_idx;


simulated function DrawFragCount(Canvas Canvas) { }
simulated function DrawWeapons(Canvas Canvas) { }
function DrawTalkFace(Canvas Canvas, int i, float YPos) {}
function bool DrawSpeechArea( Canvas Canvas, float XL, float YL ) { return false; }
simulated function DrawTeam(Canvas Canvas, TeamInfo TI) { }


///////////////////////////////////////
// PostBeginPlay 
///////////////////////////////////////

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	// Precalculate a few values
	PreCalcScale();
}


///////////////////////////////////////
// PreCalcScale 
///////////////////////////////////////
// Precalculate different Scale values so we don't calculate the same stuffs over and over every frame.
final simulated function PreCalcScale()
{
	OldScale = Scale;

	Scale8 = 8 * Scale;
	Scale16 = 16 * Scale;
	Scale32 = 32 * Scale;
	Scale64 = 64 * Scale;
	Scale128 = 128 * Scale;
	Scale256 = 256 * Scale; 
	Scale80 =  80 * Scale;
	Scale40 = 40 * Scale;
	Scale12 = 12 * Scale;
	Scale72 = 72 * Scale;
	Scale112 = 112 * Scale;
}


///////////////////////////////////////
// Destroyed
///////////////////////////////////////

event Destroyed()
{
	// Replacing our Action window by the original Speech window.
	if (Root != None && TO_Console(Root.Console) != None)
	{
	  TO_Console(Root.Console).Speechwindow = SpeechWindow(Root.CreateWindow(Class'SpeechWindow', 100, 100, 200, 200));
  	TO_Console(Root.Console).Speechwindow.SetAcceptsFocus();

		if(TO_Console(Root.Console).bShowSpeech)
		{
			Root.SetMousePos(0, 132.0/768 * Root.WinWidth);
			TO_Console(Root.Console).SpeechWindow.SlideInWindow();
		} 
		else
			TO_Console(Root.Console).SpeechWindow.HideWindow();
	}

	Super.Destroyed();
}


///////////////////////////////////////
// Tick
///////////////////////////////////////

simulated function Tick(float DeltaTime)
{
	local		float			temp;
	local		s_Player	P;

	Super.Tick(DeltaTime);

	if (PlayerOwner == None)
		return;

	P = s_Player(PlayerOwner);
	if (P != None) 
	{
		/*
		// Playing night vision animation
		if ((P.bNightVision) && (PlayerOwner.GameReplicationInfo != None) && !PlayerOwner.bShowScores )
		{
			lastnightvisiondelta += DeltaTime;
			temp = lastnightvisionframe - PlayerPawn(Owner).GameReplicationInfo.RemainingTime + lastnightvisiondelta;
			if ( (temp > 0.05) || (temp < 0) )
			{
				lastnightvisionframe = PlayerOwner.GameReplicationInfo.RemainingTime;
				lastnightvisiondelta = 0;
				if (NightVisionFrame < 4)
					NightVisionFrame++;
				else
					NightVisionFrame = 0;
			}
		}
		*/
		// FlashBang
		if (P.BlindTime > 0)
			P.BlindTime -= DeltaTime;

	}
}


///////////////////////////////////////
// PostRender
///////////////////////////////////////

simulated function PostRender( canvas Canvas )
{
	local float									XL, YL, XPos, YPos, FadeValue;
	local string								Message;
	local int										M, i, j, k, XOverflow, FaceNum;
	local float									OldOriginX;
	local	s_GameReplicationInfo	GRI;
	local	s_Player							P;
	local	bool									bWaiting, bSpectating;

	HUDSetup(canvas);

	if ( (PawnOwner == None) || (PlayerOwner == None) || (PlayerOwner.PlayerReplicationInfo == None) )
		return;

	bWaiting = PawnOwner.PlayerReplicationInfo.bWaitingPlayer;
	bSpectating = PawnOwner.PlayerReplicationInfo.bIsSpectator;
	
	if ( bWaiting )
		return;

	if ( (Root == None) && (PlayerOwner.Player != None) && (PlayerOwner.Player.Console != None) )
		Root = WindowConsole(PlayerOwner.Player.Console).Root;

	P = s_Player(PlayerOwner);

	// Precalc Scale values if needed
	if ( Scale != OldScale )
		PreCalcScale();

	// Maybe add a clientside option?
	Canvas.bNoSmooth = false;

	// Weapon's Crosshair
	if ( !PlayerOwner.bBehindView && (PawnOwner.Weapon != None) && (Level.LevelAction == LEVACT_None) && !bSpectating)
	{
		Canvas.DrawColor = WhiteColor;
		PawnOwner.Weapon.PostRender(Canvas);
		if ( !PawnOwner.Weapon.bOwnsCrossHair )
			DrawCrossHair(Canvas, 0, 0);
	}

	Canvas.bNoSmooth = false;

	if (P != None)
	{
		// FlashBang blinding
		if (P.BlindTime > 0)
			Draw_Blinded(Canvas);

		// WideScreen
		if (PlayerOwner.IsInState('PlayerSpectating') && !P.bHideWidescreen)
		{
			Canvas.SetPos(0,0);
			// HUDMODFIX
			if (!P.bHUDModFix)
			{
				Canvas.Style = 4;
				Canvas.DrawColor.R = 255;
				Canvas.DrawColor.G = 255;
				Canvas.DrawColor.B = 255;
				//Canvas.SetPos(0,0);
				Canvas.DrawTile(Texture'back_16_9', Canvas.ClipX, Canvas.ClipY, 0, 0, 64, 64);
			}
			else
			{
				Canvas.Style = ERenderStyle.STY_Normal;
				Canvas.DrawTile(Texture'back_16_9fix', Canvas.ClipX, Canvas.ClipY, 0, 0, 64, 64);
			}
			
		}


		// NightVision
		if ( P.bNightVision && !PlayerOwner.bShowScores )
		{
			PlayerOwner.RendMap = 2;
	
			Canvas.Style = Style;
			Canvas.DrawColor.R = 0;
			Canvas.DrawColor.G = 255;
			Canvas.DrawColor.B = 0;
			Canvas.SetPos(0,0);
			Canvas.DrawTile(Texture'Nightvision1', Canvas.ClipX, Canvas.ClipY, 0, 0, 256, 256);
			/*
			switch (NightVisionFrame)
			{
				case 0 : Canvas.DrawTile(Texture'Nightvision1', Canvas.ClipX, Canvas.ClipY, 0, 0, 256, 256);	
							 break;
							
				case 1 : Canvas.DrawTile(Texture'Nightvision2', Canvas.ClipX, Canvas.ClipY, 0, 0, 256, 256);	
								break;
							 
				case 2 : Canvas.DrawTile(Texture'Nightvision3', Canvas.ClipX, Canvas.ClipY, 0, 0, 256, 256);	
							 break;
							 
				case 3 : Canvas.DrawTile(Texture'Nightvision4', Canvas.ClipX, Canvas.ClipY, 0, 0, 256, 256);	
							 break;		
			}
			*/
			// HUDMODFIX
			if ( !P.bHUDModFix )
			{
				Canvas.Style = 4;
				Canvas.DrawColor.R = 128;
				Canvas.DrawColor.G = 128;
				Canvas.DrawColor.B = 128;
				Canvas.SetPos(0,0);
				Canvas.DrawTile(Texture'NightvisionMid', Canvas.ClipX, Canvas.ClipY, 0, 0, 256, 256);
			}
		}
		else if ( PlayerOwner.RendMap != 5 )
			PlayerOwner.RendMap = 5;

		Canvas.Style = Style;
	}

	if ( bShowInfo )
	{
		ServerInfo.RenderInfo( Canvas );
		return;
	}


	// Draw the death messages
	if ( !bHideHud )
		Draw_Death_Message(Canvas);

	// Draw Round remaining time
	if ( !bHideHud && !PlayerOwner.bShowScores )
		DrawRoundT(Canvas);

	Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
	OldOriginX = Canvas.OrgX;
	// Master message short queue control loop.
	FaceNum = -1;
	bDrawFaceArea = False;
	Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
	Canvas.StrLen("TEST", XL, YL);
	Canvas.SetClip(768 * Scale - 10, Canvas.ClipY);

	for (i=0; i<4; i++)
	{
		if ( !bHideHud && (ShortMessageQueue[i].Message != None) )
		{
			j++;

			if ( bResChanged || (ShortMessageQueue[i].XL == 0) )
			{
				if ( ShortMessageQueue[i].Message.Default.bComplexString )
					Canvas.StrLen(ShortMessageQueue[i].Message.Static.AssembleString( 
											self,
											ShortMessageQueue[i].Switch,
											ShortMessageQueue[i].RelatedPRI,
											ShortMessageQueue[i].StringMessage), 
								   ShortMessageQueue[i].XL, ShortMessageQueue[i].YL);
				else
					Canvas.StrLen(ShortMessageQueue[i].StringMessage, ShortMessageQueue[i].XL, ShortMessageQueue[i].YL);
				Canvas.StrLen("TEST", XL, YL);
				ShortMessageQueue[i].numLines = 1;
				if ( ShortMessageQueue[i].YL > YL )
				{
					ShortMessageQueue[i].numLines++;
					for (k=2; k<4-i; k++)
					{
						if (ShortMessageQueue[i].YL > YL*k)
							ShortMessageQueue[i].numLines++;
					}
				}
			}

			// Keep track of the amount of lines a message overflows, to offset the next message with.
			Canvas.SetPos(6, 2 + YL * YPos);
			YPos += ShortMessageQueue[i].numLines;
			if ( YPos > 4 )
				break; 

			if ( ShortMessageQueue[i].Message.Default.bComplexString )
			{
				// Use this for string messages with multiple colors.
				ShortMessageQueue[i].Message.Static.RenderComplexMessage( 
					Canvas,
					ShortMessageQueue[i].XL,  YL,
					ShortMessageQueue[i].StringMessage,
					ShortMessageQueue[i].Switch,
					ShortMessageQueue[i].RelatedPRI,
					None,
					ShortMessageQueue[i].OptionalObject
					);				
			} 
			else
			{
				//Canvas.DrawColor = ShortMessageQueue[i].Message.Default.DrawColor;
				//Canvas.DrawColor = ShortMessageQueue[i].Message.Static.GetTeamColor(ShortMessageQueue[i].RelatedPRI);
				Canvas.DrawColor = GetTeamColor(ShortMessageQueue[i].RelatedPRI);
				Canvas.DrawText(ShortMessageQueue[i].StringMessage, False);
			}
		}
	}


	Canvas.DrawColor = WhiteColor;
	Canvas.SetClip(OldClipX, Canvas.ClipY);
	Canvas.SetOrigin(OldOriginX, Canvas.OrgY);
	//YPos = FMax(YL*4 + 8, 70*Scale);

	if ( !bHideCenterMessages && !bHideHud )
	{
		// Master localized message control loop.
		for (i=0; i<10; i++)
		{
			if (LocalMessages[i].Message != None)
			{
				if (LocalMessages[i].Message.Default.bFadeMessage && Level.bHighDetailMode)
				{
					Canvas.Style = ERenderStyle.STY_Translucent;
					FadeValue = (LocalMessages[i].EndOfLife - Level.TimeSeconds);
					if (FadeValue > 0.0)
					{
						if ( bResChanged || (LocalMessages[i].XL == 0) )
						{
							if ( LocalMessages[i].Message.Static.GetFontSize(LocalMessages[i].Switch) == 1 )
								LocalMessages[i].StringFont = MyFonts.GetBigFont( Canvas.ClipX );
							else // ==2
								LocalMessages[i].StringFont = MyFonts.GetHugeFont( Canvas.ClipX );
							Canvas.Font = LocalMessages[i].StringFont;
							Canvas.StrLen(LocalMessages[i].StringMessage, LocalMessages[i].XL, LocalMessages[i].YL);
							LocalMessages[i].YPos = LocalMessages[i].Message.Static.GetOffset(LocalMessages[i].Switch, LocalMessages[i].YL, Canvas.ClipY);
						}
						Canvas.Font = LocalMessages[i].StringFont;
						Canvas.DrawColor = LocalMessages[i].DrawColor * (FadeValue/LocalMessages[i].LifeTime);
						Canvas.SetPos( 0.5 * (Canvas.ClipX - LocalMessages[i].XL), LocalMessages[i].YPos );
						Canvas.DrawText( LocalMessages[i].StringMessage, False );
					}
				} 
				else 
				{
					if ( bResChanged || (LocalMessages[i].XL == 0) )
					{
						if ( LocalMessages[i].Message.Static.GetFontSize(LocalMessages[i].Switch) == 1 )
							LocalMessages[i].StringFont = MyFonts.GetBigFont( Canvas.ClipX );
						else // == 2
							LocalMessages[i].StringFont = MyFonts.GetHugeFont( Canvas.ClipX );
						Canvas.Font = LocalMessages[i].StringFont;
						Canvas.StrLen(LocalMessages[i].StringMessage, LocalMessages[i].XL, LocalMessages[i].YL);
						LocalMessages[i].YPos = LocalMessages[i].Message.Static.GetOffset(LocalMessages[i].Switch, LocalMessages[i].YL, Canvas.ClipY);
					}
					Canvas.Font = LocalMessages[i].StringFont;
					Canvas.Style = ERenderStyle.STY_Normal;
					Canvas.DrawColor = LocalMessages[i].DrawColor;
					Canvas.SetPos( 0.5 * (Canvas.ClipX - LocalMessages[i].XL), LocalMessages[i].YPos );
					Canvas.DrawText( LocalMessages[i].StringMessage, False );
				}
			}
		}
	}
	Canvas.Style = ERenderStyle.STY_Normal;

	// Live Feed
	if ( (PawnOwner != Owner) && PawnOwner.bIsPlayer && !bHideHud )
	{
		Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
		Canvas.bCenter = true;
		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.DrawColor = CyanColor * TutIconBlink;

		Canvas.SetPos(4, Canvas.ClipY - 140 * Scale);
		Canvas.DrawText( LiveFeed$PawnOwner.PlayerReplicationInfo.PlayerName, true );

		//Canvas.SetPos(4, Canvas.ClipY - Scale112);
		//Canvas.DrawText("Use [altfire] to zoom in/out, [crouch]+[altfire] to move up/down camera axis", true );

		Canvas.bCenter = false;
		Canvas.DrawColor = WhiteColor;
		Canvas.Style = Style;
	}

	if ( !bHideHud && bStartUpMessage && (Level.TimeSeconds < 5) )
	{
		bStartUpMessage = false;
		PlayerOwner.SetProgressTime(7);
	}

	if ( !bHideHud && (PlayerOwner.ProgressTimeOut > Level.TimeSeconds) && !bHideCenterMessages )
		DisplayProgressMessage(Canvas);

	// Display MOTD
	if ( MOTDFadeOutTime > 0.0 )
		DrawMOTD(Canvas);

	if ( !bHideHUD )
	{
		if ( !bSpectating )
		{
			Canvas.Style = Style;

			// Draw Armor status
			DrawStatus(Canvas);

			if ( IsPlayerOwner() )
			{
				// Draw Money
				DrawMoney(Canvas);

				// Draw Ammo
				if ( !bHideAmmo )
					DrawAmmo(Canvas);
				
				if ( bDrawCT )
					DrawConsoleTimer(Canvas);

				// DrawZones
				DrawZones(Canvas);
			}
		}
	}

	// Display Identification Info
	if ( !bHideHud && (PawnOwner == PlayerOwner) || (PlayerOwner.IsA('s_Player') && P.bShowDebug && !PlayerOwner.bShowScores) )
		DrawIdentifyInfo(Canvas);

	if ( !bHideHud && (HUDMutator != None) )
		HUDMutator.PostRender(Canvas);
/*
	if ( (PlayerOwner.GameReplicationInfo != None) && (PlayerPawn(Owner).GameReplicationInfo.RemainingTime > 0) ) 
	{
		if ( TimeMessageClass == None )
			TimeMessageClass = class<CriticalEventPlus>(DynamicLoadObject("Botpack.TimeMessage", class'Class'));

		if ( (PlayerOwner.GameReplicationInfo.RemainingTime <= 300)
		  && (PlayerOwner.GameReplicationInfo.RemainingTime != LastReportedTime) )
		{
			LastReportedTime = PlayerOwner.GameReplicationInfo.RemainingTime;
			if ( PlayerOwner.GameReplicationInfo.RemainingTime <= 30 )
			{
				bTimeValid = ( bTimeValid || (PlayerOwner.GameReplicationInfo.RemainingTime > 0) );	
				if ( PlayerOwner.GameReplicationInfo.RemainingTime == 30 )
					TellTime(5);
				else if ( bTimeValid && PlayerOwner.GameReplicationInfo.RemainingTime <= 10 )
					TellTime(16 - PlayerOwner.GameReplicationInfo.RemainingTime);
			}
			else if ( PlayerOwner.GameReplicationInfo.RemainingTime % 60 == 0 )
			{
				M = PlayerOwner.GameReplicationInfo.RemainingTime/60;
				TellTime(5 - M);
			}
		}
	}
*/
	if ( !bHideHud && (PlayerOwner.GameReplicationInfo != None) )
	{
		if ( PlayerPawn(Owner).GameReplicationInfo.RemainingTime == 0 )
		{
			if ( bDisplayMapChangeMessage ) 
			{
				// tell level switch message
				PlayerOwner.ReceiveLocalizedMessage(class's_MessageRoundWinner', 8);
				bDisplayMapChangeMessage = false;
			}
		}
		else if ( !bDisplayMapChangeMessage )
			bDisplayMapChangeMessage = true;
	}
	
	// Show Scores
	if ( PlayerOwner.bShowScores || bForceScores )
	{
		if ( (PlayerOwner.Scoring == None) && (PlayerOwner.ScoringType != None) )
			PlayerOwner.Scoring = Spawn(PlayerOwner.ScoringType, PlayerOwner);
		if ( PlayerOwner.Scoring != None )
		{ 
			Canvas.Style = Style;
			PlayerOwner.Scoring.OwnerHUD = self;
			PlayerOwner.Scoring.ShowScores(Canvas);
			if ( PlayerOwner.Player.Console.bTyping )
				DrawTypingPrompt(Canvas, PlayerOwner.Player.Console);
			//return;
		}
	}

	if (P != None && P.bShowDebug && ( !PlayerOwner.bShowScores) )
		ShowDebug(Canvas);

	if ( PlayerOwner.Player.Console.bTyping )
		DrawTypingPrompt(Canvas, PlayerOwner.Player.Console);

	if ( P != None )
	{
		// PreRound
		if ( P.GameReplicationInfo != None )
		{
			//GRI = s_GameReplicationInfo(P.GameReplicationInfo);
			if ( IsPreRound() || bShowObjectives )
			{
				if ( !bShowObjectives )
					P.BlindTime = 0;

				ShowPreRound(Canvas);
			}
		}

		// Darken screen when using action window
		if ( P.bActionWindow )
		{
			//make function out of that
				if ( (s_Player(PlayerOwner) != None) && !s_Player(PlayerOwner).bHUDModFix )
				{
					Canvas.Style = 4;
					Canvas.DrawColor.R = 255;
					Canvas.DrawColor.G = 255;
					Canvas.DrawColor.B = 255;
					Canvas.SetPos(0,0);
					Canvas.DrawTile(Texture'debug16', Canvas.ClipX, Canvas.ClipY, 0, 0, 16, 16);
				}
		}
	}

	if ( PlayerOwner.bBadConnectionAlert && (PlayerOwner.Level.TimeSeconds > 5) )
	{
		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.DrawColor = WhiteColor;
		Canvas.SetPos(Canvas.ClipX - (Scale64), Canvas.ClipY / 2);
		Canvas.DrawIcon(texture'DisconnectWarn', Scale);
	}
}


///////////////////////////////////////
// GetTeamColor
///////////////////////////////////////

function Color GetTeamColor(PlayerReplicationInfo PRI)
{
	local	Byte i;
	if ( PRI == None )
		return Default.GreenColor;

	i = PRI.team;

	if ( PRI.bIsSpectator )
		return Default.GreyColor;

	if ( i < 2 )
		return Default.TeamColor[i];

	return Default.GreenColor;
}


///////////////////////////////////////
// DrawAmmo
///////////////////////////////////////

simulated function DrawAmmo(Canvas Canvas)
{
	local int		X, Y;

	if ( PawnOwner.Weapon == None )
		return;

	/*
		STY_None,
	STY_Normal,
	STY_Masked,
	STY_Translucent,
	STY_Modulated,
	*/
//	Canvas.Style = Style;
	Canvas.Style = ERenderStyle.STY_Translucent;
	Canvas.DrawColor = HUDColor;

	Y = Canvas.ClipY - Scale80;
	X = Canvas.ClipX - 176 * Scale;
	Canvas.SetPos(X, Y);
	if (PawnOwner.Weapon.IsA('s_Weapon'))
	{
		if (s_Weapon(PawnOwner.Weapon).bUseAmmo)
		{
			Canvas.DrawTile(Texture'Bullets64', Scale64, Scale64, 0, 0, 64.0, 64.0);
			DrawBigNum(Canvas, s_Weapon(PawnOwner.Weapon).ClipAmmo, X + 68 * Scale, Y + Scale12);

			if (s_Weapon(PawnOwner.Weapon).bUseClip)
			{
				Y = Canvas.ClipY - 160 * Scale;
				Canvas.SetPos(X, Y);
				Canvas.DrawTile(Texture'Clip64', Scale64, Scale64, 0, 0, 64.0, 64.0);
				//DrawBigNum(Canvas, PawnOwner.Weapon.AmmoType.AmmoAmount - s_Weapon(PawnOwner.Weapon).ClipAmmo, X + 68 * Scale, Y + 12 * Scale);
				DrawBigNum(Canvas, s_Weapon(PawnOwner.Weapon).RemainingClip, X + 68 * Scale, Y + Scale12);
			}
		}
	}
	else
	{
		Canvas.DrawTile(Texture'Bullets64', Scale64, Scale64, 0, 0, 64.0, 64.0);
		DrawBigNum(Canvas, PawnOwner.Weapon.AmmoType.AmmoAmount, X + 68 * Scale, Y + Scale12);
	}
}


///////////////////////////////////////
// Add_Death_Message
///////////////////////////////////////

final simulated function	Add_Death_Message(PlayerReplicationInfo KillerPRI, PlayerReplicationInfo VictimPRI)
{
	local	s_DeathMessages				message;
	local	string								clientmsg;

	if (VictimPRI == None)
		return;

	if (s_DeathM_idx > 5)
		s_DeathM_idx = 5;

	if (s_DeathM_idx == 5)
	{
		Shift_Death_Message();
		s_DeathM_idx = 4;
	}

	// Killer
	if (KillerPRI != None && KillerPRI.Team < 2)
	{
		message.Killer = KillerPRI.PlayerName;
		message.KillerC = TeamColor[KillerPRI.Team];
	}
	else
		message.Killer = "";

	// Victim
	if (VictimPRI.Team < 2)
	{
		message.VictimC = TeamColor[VictimPRI.Team];
		message.Victim = VictimPRI.PlayerName;
	}
	else
		message.Victim = "";

	if (KillerPRI != None)
		clientmsg = KillerPRI.PlayerName$" killed "$VictimPRI.PlayerName;
	else
		clientmsg = VictimPRI.PlayerName$" died";

	// client console logging
	if (PlayerOwner != None && PlayerOwner.PlayerReplicationInfo != None 
		&& PlayerOwner.Player != None && PlayerOwner.Player.Console != None)
		PlayerOwner.Player.Console.Message(PlayerOwner.PlayerReplicationInfo, clientmsg, '');

	s_DeathM[s_DeathM_idx] = message;			

	if (s_DeathM_idx == 0)
		s_DeathM[0].EndOfLife = 5;

	s_DeathM_idx++;
}


///////////////////////////////////////
// Shift_Death_Message
///////////////////////////////////////

final simulated function	Shift_Death_Message()
{
	local	s_DeathMessages	message;
	local	int							i;
	
	if (s_DeathM_idx > 0)
		{
			for (i = 0; i < s_DeathM_idx; i++)
				s_DeathM[i] = s_DeathM[i + 1];

			s_DeathM_idx--;
			s_DeathM[0].EndOfLife = 5;
		}
}


///////////////////////////////////////
// Draw_Death_Message
///////////////////////////////////////

final simulated function	Draw_Death_Message(Canvas C)
{
	local	s_DeathMessages	message;
	local	string					tmp;
	local	int							i;
	local	float						X, Y, XL, YL, XL2, YL2, Ystep;
	
	Y = Scale8;
	C.Font = MyFonts.GetSmallFont( C.ClipX );
	C.Style = ERenderStyle.STY_Translucent;
	C.StrLen("test", X, Ystep);
	YStep *= 1.5;

	if (s_DeathM_idx > 0)
		{
			for (i = 0; i < s_DeathM_idx; i++)
			{
				if (s_DeathM[i].Victim == "")
					continue;

				if (s_DeathM[i].Killer != "")
				{
					tmp = " killed "$s_DeathM[i].Victim;

					C.StrLen(tmp, XL2, YL);

					// Killer
					C.DrawColor = s_DeathM[i].KillerC;
					C.StrLen(s_DeathM[i].Killer, XL, YL);
					X = C.ClipX - XL - Scale8 - XL2;
					YL2 = (Scale32 - YL) / 2;
					C.SetPos(X, Y + YL2);
					C.DrawText(s_DeathM[i].Killer, False);

					// msg
					tmp = " killed ";

					C.DrawColor = WhiteColor;
					X = C.ClipX - XL2 - Scale8;
					C.SetPos(X, Y + YL2);
					C.DrawText(tmp, False);

					// Victim
					C.DrawColor = s_DeathM[i].VictimC;
					C.StrLen(s_DeathM[i].Victim, XL, YL);
					X = C.ClipX - XL - Scale8;
					C.SetPos(X, Y + YL2);
					C.DrawText(s_DeathM[i].Victim, False);
				}
				else
				{
					tmp = " died";
					C.StrLen(tmp, XL2, YL);

					// Victim
					C.DrawColor = s_DeathM[i].VictimC;
					C.StrLen(s_DeathM[i].Victim, XL, YL);
					X = C.ClipX - XL - Scale8 - XL2;
					YL2 = (Scale32 - YL) / 2;
					C.SetPos(X, Y + YL2);
					C.DrawText(s_DeathM[i].Victim, False);

					C.DrawColor = WhiteColor;
					X = C.ClipX - XL2 - Scale8;
					C.SetPos(X, Y + YL2);
					C.DrawText(tmp, False);

				}

				Y += YStep;
			}
		}
}


///////////////////////////////////////
// Add_Money_Message
///////////////////////////////////////

final simulated function Add_Money_Message(int Amount)
{
	local	s_MoneyM	message;

	if (MoneyM_idx > 5)
		MoneyM_idx = 5;

	if (MoneyM_idx == 5)
	{
		Shift_Money_Message();
		//MoneyM_idx = 4;
	}

	message.Amount = Amount;
	MoneyM[MoneyM_idx] = message;			
	MoneyM[MoneyM_idx].EndOfLife = 4;

	MoneyM_idx++;
}


///////////////////////////////////////
// Shift_Money_Message
///////////////////////////////////////

final simulated function	Shift_Money_Message()
{
	local	s_MoneyM				message;
	local	int							i, j;
	

	if (MoneyM_idx > 0)
	{
		for (i = 0; i < MoneyM_idx; i++)
			MoneyM[i] = MoneyM[i + 1];

		MoneyM_idx--;
		MoneyM[0].EndOfLife = 5;
	}
}


///////////////////////////////////////
// Draw_Money_Message
///////////////////////////////////////

final simulated function	Draw_Money_Message(Canvas C)
{
	local	s_MoneyM				message;
	local	int							i;
	local	float						X, Y;
	local	float						XL, YL;
	local	float						tmp;
	local	Color						DColor, OldColor;

	Y = C.ClipY - (224) * Scale;
	X = Scale16;
	C.Font = MyFonts.GetMediumFont( C.ClipX );
	C.Style = Style;
	OldColor = C.DrawColor;
	//C.Style = ERenderStyle.STY_Translucent;

	if (MoneyM_idx > 0)
		{
			for (i = 0; i < MoneyM_idx; i++)
			{
				// Setting Right color
				if (MoneyM[i].Amount > 0)
				{
					DColor.R = 0;
					DColor.G = 31 * MoneyM[i].EndOfLife;
					DColor.B = 0;
				}
				else
				{
					DColor.R = 31 * ( MoneyM[i].EndOfLife + 1);
					DColor.G = 0;
					DColor.B = 0;
				}

				C.DrawColor = DColor;
				
				C.SetPos(Scale16, Y);
				C.DrawTile(Texture'Money64', Scale40, Scale40, 0, 0, 64.0, 64.0);

				// Amount
				DrawBigNum(C, MoneyM[i].Amount, X + Scale64, Y);

				Y -= Scale40;
			}
		}
}

 
///////////////////////////////////////
// DrawMoney
///////////////////////////////////////
 
final simulated function DrawMoney(Canvas Canvas)
{
	local int		X,Y;

	Draw_Money_Message(Canvas);
	
	if ( PawnOwner == None )
		return;

	Canvas.Style = Style;
	Canvas.DrawColor = HUDColor;

	Y = Canvas.ClipY - 160 * Scale;
	Canvas.SetPos(Scale8, Y);
	Canvas.DrawTile(Texture'Money64', Scale64, Scale64, 0, 0, 64.0, 64.0);

	if ( PawnOwner.IsA('s_Player') /*&& (s_Player(PawnOwner).Money > 0)*/ )
		DrawBigNum(Canvas, s_Player(PawnOwner).Money, 100 * Scale, Y + Scale12);

	//else if (PawnOwner.IsA('s_Bot') && (s_Bot(PawnOwner).Money > 0) ) 
	//	DrawBigNum(Canvas, s_Bot(PawnOwner).Money, 100 * Scale, Y + 12 * Scale);
}


///////////////////////////////////////
// DrawStatus
///////////////////////////////////////

simulated function DrawStatus(Canvas Canvas)
{
	local int		X,Y, i, num;
	local float DamageTime, StatScale, XL, YL;
	local float	helmet, kevlar, legs;
	local	string	TOversion;

	if ( PawnOwner == None )
		return;

	Canvas.Style = Style;
	Canvas.DrawColor = HUDColor;
	
	// Health
	X = Scale8;
	Y = Canvas.ClipY - Scale80;
	Canvas.SetPos(X, Y);
	Canvas.DrawTile(Texture'Health2', Scale64, Scale64, 0, 0, 64.0, 64.0);
	DrawBigNum(Canvas, Max(0, PawnOwner.Health), X + Scale80, Y + Scale12);

	if ( PawnOwner.PlayerReplicationInfo.Team < 2 )
	{
		// Info string

		Y = Scale8;
		Canvas.Font = MyFonts.GetAReallySmallFont( Canvas.ClipX );
		Canvas.Style = ERenderStyle.STY_Translucent;
		Canvas.DrawColor = WhiteColor;
		Canvas.StrLen("test", XL, YL);
		Canvas.SetPos(XL, Canvas.ClipY - YL);

		if ( PawnOwner.IsA('s_Bot') )
			num = -1;
		else if (PawnOwner.IsA('s_Player'))
			num = s_Player(PawnOwner).PlayerModel;

		TOversion = class'TOSystem.TO_MenuBar'.default.TOVersionText;
		if ( class'TOSystem.TO_MenuBar'.default.Build != 0 )
			TOversion = TOversion@"Build:"@class'TOSystem.TO_MenuBar'.default.Build$"1.A2";
		TOversion = TOversion@"-"@PawnOwner.PlayerReplicationInfo.PlayerName;
		if ( num >=0 )
			TOversion = TOversion@"- ["$s_team[PawnOwner.PlayerReplicationInfo.Team]$"]";

		canvas.DrawText(TOversion, false);

		if ( IsPlayerOwner() )
		{
			// HitLocation
			Canvas.DrawColor.R = 128;
			Canvas.DrawColor.G = 160;
			Canvas.DrawColor.B = 160;

			X = Canvas.ClipX - Scale128;
			Y = Canvas.ClipY / 2 + Scale64;
			Canvas.SetPos(X, Y);
			Canvas.DrawTile(Texture'sHitLocation', Scale128, Scale256, 0, 0, 128.0, 256.0);

			if ( PawnOwner.IsA('s_Player') )
			{
				Helmet = s_Player(PawnOwner).HelmetCharge;
				kevlar = s_Player(PawnOwner).VestCharge;
				legs = s_Player(PawnOwner).LegsCharge;
			}
			else if ( PawnOwner.IsA('s_Bot') )
			{
				Helmet = s_Bot(PawnOwner).HelmetCharge;
				kevlar = s_Bot(PawnOwner).VestCharge;
				legs = s_Bot(PawnOwner).LegsCharge;
			}

			// Helmet
			if ( Helmet > 0 )
			{
				SetArmorColor(Canvas, Helmet);

				X = Canvas.ClipX - Scale128;
				Y = Canvas.ClipY / 2 + Scale64;
				Canvas.SetPos(X, Y);
				Canvas.DrawTile(Texture'sHitLocation', Scale128, 25*Scale, 128, 0, 128.0, 25.0);
			}
			
			// VestCharge
			if ( kevlar > 0 )
			{
				SetArmorColor(Canvas, kevlar);

				X = Canvas.ClipX - Scale128;
				Y = Canvas.ClipY / 2 + 25 * Scale + Scale64;
				Canvas.SetPos(X, Y);
				Canvas.DrawTile(Texture'sHitLocation', Scale128, Scale64, 128, 25, 128.0, 64.0);
			}

			// LegsCharge
			if ( legs > 0 )
			{
				SetArmorColor(Canvas, legs);

				X = Canvas.ClipX - Scale128;
				Y = Canvas.ClipY / 2 + 89 * Scale + Scale64;
				Canvas.SetPos(X, Y);
				Canvas.DrawTile(Texture'sHitLocation', Scale128, 167 * Scale, 128, 89, 128.0, 167.0);
			}

			X = Canvas.ClipX - Scale128;
			Y = Canvas.ClipY / 2 + Scale64;
			StatScale = Scale * StatusScale;
			Canvas.Style = Style;

		//	if ( (PawnOwner == PlayerOwner) && Level.bHighDetailMode && !Level.bDropDetail )
		//	{
				for ( i=0; i<4; i++ )
				{
					DamageTime = Level.TimeSeconds - HitTime[i];
					if ( DamageTime < 2 )
					{
						/*log("drawing damage ! HITPOS: "$HitPos[i].X$" "$HitPos[i].Y
							$" - StatScale: "$StatScale
							$" - DamageTime: "$DamageTime
							$" - HitDamage: "$HitDamage[i]
							); */
						Canvas.SetPos(X + HitPos[i].X * StatScale, Y + HitPos[i].Y * StatScale);
		/*				if ( (HUDColor.G > 100) || (HUDColor.B > 100) )
							Canvas.DrawColor = RedColor;
						else
							Canvas.DrawColor = (WhiteColor - HudColor) * FMin(1, 2 * DamageTime);
						Canvas.DrawColor.R = 255 * FMin(1, 2 * DamageTime);
						Canvas.DrawTile(Texture'BotPack.HudElements1', StatScale * HitDamage[i] * 25, StatScale * HitDamage[i] * 64, 0, 64, 25.0, 64.0);
		*/
						Canvas.DrawColor.R = 255;
						Canvas.DrawColor.G = 255;
						Canvas.DrawColor.B = 255;

						Canvas.DrawTile(Texture'LaserDot', Scale32, Scale32, 0, 0, 32, 32);
					}
				}
		//	}
		}
	}
}


///////////////////////////////////////
// SetDamage
///////////////////////////////////////

final function SetArmorColor(Canvas C, int value)
{
	if ( value > 75 )
	{
		C.DrawColor.R = 255 * (100 - value) / 25;
		C.DrawColor.G = 200;
		C.DrawColor.B = 0;
	}
	else if ( value > 50 )
	{
		C.DrawColor.R = 255;
		C.DrawColor.G = 200 * (value - 50) / 25;
		C.DrawColor.B = 0;
	}
	else
	{
		C.DrawColor.R = 255 * value / 50;
		C.DrawColor.G = 0;
		C.DrawColor.B = 0;
	}
}


///////////////////////////////////////
// SetDamage
///////////////////////////////////////

function SetDamage(vector HitLoc, float damage)
{
	local int i, best;
	local vector X,Y,Z;
	local float Max, XOffset, YOffset;

	if ( Level.bDropDetail || !PlayerOwner.IsA('s_Player') )
		return;

	for ( i=0; i<4; i++ )
		if ( Level.TimeSeconds - HitTime[i] > Max )
		{
			best = i;	
			Max = Level.TimeSeconds - HitTime[i];
		}

	HitTime[best] = Level.TimeSeconds;
	HitDamage[best] = FClamp(Damage * 0.06,2,4);
	GetAxes(Owner.Rotation,X,Y,Z);
	XOffset = - 0.5 * FClamp((Y Dot HitLoc)/CollisionRadius , -1, 1);
	YOffset = -0.5 * FClamp((Z Dot HitLoc)/CollisionHeight , -1, 1);

	// hack for positions around head or near legs
	if ( YOffset < -0.35 )
	{
		XOffset *= 0.3;
		YOffset = FMax(HitPos[best].Y, -0.45);
	}
	else if ( YOffset > 0.1 )
	{
		if ( abs(XOffset) < 0.25 )
		{
			if ( XOffset > 0 )
				XOffset = 0.25;
			else
				XOffset = -0.25;
		}				
		YOffset = FMin(YOffset, 0.4);
	}

	HitPos[best].X = 128 * (0.5 + XOffset) - 0.5 * 25 * HitDamage[best];
	HitPos[best].Y = 256 * (0.5 + YOffset) - 0.5 * HitDamage[Best] * 64;

	/*log("SetDamage ! - HitTime: "$HitTime[best]
		$" - HitDamage: "$HitDamage[best]
		$" - HitPosX: "$HitPos[best].X
		$" - HitPosY: "$HitPos[best].Y
		); */
}



///////////////////////////////////////
// DrawRoundT
///////////////////////////////////////

final simulated function DrawRoundT(Canvas Canvas)
{
	local int X,Y;
	local int time, min, secs;
	//local	s_SWATGame SG;
	local s_GameReplicationInfo GRI;

	Canvas.Style = Style;
	Canvas.DrawColor = HUDColor;

	if ( PawnOwner == None )
	{
		log("DrawRoundT - PawnOwner == none");
		return;
	}

	GRI = s_GameReplicationInfo(PlayerOwner.GameReplicationInfo);
	if ( (GRI != None) && !IsPreRound() )
		time = GRI.RoundDuration * 60 - (GRI.RoundStarted - GRI.Remainingtime);
	else
	{
		time = 0;
		Canvas.DrawColor.R *= 0.5;
		Canvas.DrawColor.G *= 0.5;
		Canvas.DrawColor.B *= 0.5;
	}

	X = (Canvas.ClipX / 2) - Scale80;
	Y = Canvas.ClipY - Scale80;
	Canvas.SetPos(X - Scale64, Y);
	Canvas.DrawTile(Texture'RoundT64', Scale64, Scale64, 0, 0, 64.0, 64.0);

	Canvas.SetPos(X, Y);
	min = time / 60;
	secs = time % 60;
	if (secs < 0)
		secs = 0;

	DrawBigNum(Canvas, min, X, Y + Scale12);
	Canvas.Font = MyFonts.GetHugeFont( Canvas.ClipX );
	Canvas.SetPos(X + 76 * Scale, Y + Scale8);
	Canvas.DrawText(":");
	DrawBigNum(Canvas, secs, X + 88 * Scale, Y + Scale12);

}


///////////////////////////////////////
// DrawConsoleTimer
///////////////////////////////////////

final simulated function DrawConsoleTimerHUD( bool bIsCT, bool bUsing, float CTPercentage )
{
	//log("s_HUD::DrawConsoleTimerHUD - CT:"@s_Player(PlayerOwner).CurrentCT);

	if ( bIsCT )
	{
		if ( (s_Player(PlayerOwner).CurrentCT == None) || !s_Player(PlayerOwner).CurrentCT.bDisplayProgressBar )
			return;
	}

	if ( bDrawCT && !bUsing )
	{
		//log("s_HUD::DrawConsoleTimerHUD - End");
		bDrawCT = false;
		CT = None;
	}
	else if ( !bDrawCT && bUsing )
	{

		bDrawCT = true;
		if ( bIsCT )
			CT = s_Player(PlayerOwner).CurrentCT;

		//log("s_HUD::DrawConsoleTimerHUD - Begin - bIsCT"@bIsCT@"-bUsing"@bUsing@"-CTPercentage"@CTPercentage@"-CT"@CT);
	}

	CTVal = CTPercentage;
}


///////////////////////////////////////
// DrawConsoleTimer
///////////////////////////////////////

final simulated function DrawConsoleTimer(Canvas C)
{
	local string	CT_Type;
	local	float		XO, YO, X, Y, XL, YL, BarWidth;

	C.bNoSmooth = false;
	C.Style = Style;
	C.DrawColor = HUDColor;
	C.Font = MyFonts.GetMediumFont( C.ClipX );

	XO = C.ClipX / 2;
	YO = C.ClipY / 2;
	BarWidth = 372;
	X = BarWidth * Scale;
	
	if ( CT != None )
		CT_Type = CT.CTMessage@byte(100 * CTVal)$"%";
	else
		CT_Type = "Defusing bomb..."@byte(100 * CTVal)$"%";

	C.SetPos(XO - X, YO);
	C.DrawText(CT_Type, false);
	C.StrLen("test", XL, YL);

	// Draw Gauge
	C.SetPos(XO - X, YO + YL * 1.5);
	C.DrawTile(Texture'TODatas.GaugeStart', Scale8 , Scale32, 0, 0, 8, 32);
	
	C.SetPos(XO - X + Scale8, YO + YL * 1.5);
	C.DrawTile(Texture'TODatas.GaugeMid', X * 2 - Scale16, Scale32, 0, 0, 8, 32);

	C.SetPos(XO + X - Scale8, YO + YL * 1.5);
	C.DrawTile(Texture'TODatas.GaugeEnd', Scale8 , Scale32, 0, 0, 8, 32);

	// Draw progress bar
	C.SetPos(XO - X + Scale8, YO + YL * 1.5);
	C.DrawTile(Texture'TODatas.GaugeBar', (X  - Scale8) * 2 * CTVal, Scale32, 0, 0, 8, 32);

	//log("s_HUD - DrawConsoleTimer");
/*
	C.bCenter = true;
	C.Style = Style;
	C.DrawColor = HUDColor;
	C.Font = MyFonts.GetHugeFont( C.ClipX );
	CT_Type = CT.CTMessage@byte(100 * CTVal)$"%";
	C.SetPos(100, C.ClipY / 2);
	C.DrawText(CT_Type, false);
	C.bCenter = false;
*/
}


final simulated function bool IsPlayerOwner()
{
	return ( (PawnOwner != None) && (PawnOwner == PlayerOwner) );
}


///////////////////////////////////////
// DrawZones
///////////////////////////////////////

final simulated function DrawZones(Canvas Canvas)
{
	local int						X, Y;

	if ( !IsPlayerOwner() )
		return;

	Canvas.Style = Style;
	Canvas.DrawColor.R = 0;
	Canvas.DrawColor.G = 200;
	Canvas.DrawColor.B = 0;

	X = Scale8;
	Y = Canvas.ClipY / 2 - Scale128;

	// Home base zone
	if ( IsInHomeBase(PawnOwner) )
	{
		Canvas.SetPos(X, Y);
		Canvas.DrawTile(Texture'Zone_Home64', Scale64, Scale64, 0, 0, 64.0, 64.0);		
		Y += Scale72;
	}

	// Buy zone
	if ( IsInBuyZone(PawnOwner) )
	{		
		Canvas.SetPos(X, Y);
		Canvas.DrawTile(Texture'Zone_Buy64', Scale64, Scale64, 0, 0, 64.0, 64.0);			
		Y += Scale72;
	}

	// Rescue zone
	if ( IsInRescueZone(PawnOwner) ) 
	{
		Canvas.SetPos(X, Y);
		Canvas.DrawTile(Texture'Zone_Rescue64', Scale64, Scale64, 0, 0, 64.0, 64.0);	
		Y += Scale72;
	}

	// Escape zone
	if ( IsInEscapeZone(PawnOwner) ) 
	{
		Canvas.SetPos(X, Y);
		Canvas.DrawTile(Texture'Zone_Escape', Scale64, Scale64, 0, 0, 64.0, 64.0);		
		Y += Scale72;
	}

	// Bombing zone
	if ( IsInBombingZone(PawnOwner) ) 
	{
		Canvas.SetPos(X, Y);
		Canvas.DrawTile(Texture'Zone_Bombing64', Scale64, Scale64, 0, 0, 64.0, 64.0);		
//		Y += Scale72;
	}


	Canvas.DrawColor.R = 200;
	Canvas.DrawColor.G = 200;
	Canvas.DrawColor.B = 0;

	X = Canvas.ClipX - Scale112;
	Y = Canvas.ClipY / 2 - Scale128;

	if ( PawnOwner.IsA('s_Player') && (s_Player(PawnOwner).Eidx > 0) )
	{
		Canvas.SetPos(X, Y);
		Canvas.DrawTile(Texture'Zone_Evidence', Scale64, Scale64, 0, 0, 64.0, 64.0);
		Y += Scale72;
	}

	if ( PawnOwner.IsA('s_Player') && s_Player(PawnOwner).bSpecialItem )
	{
		Canvas.SetPos(X, Y);
		Canvas.DrawTile(Texture'Zone_SpecialItems', Scale64, Scale64, 0, 0, 64.0, 64.0);
		Y += Scale72;
	}

	if ( PawnOwner.IsA('s_Player') && s_Player(PawnOwner).PlayerReplicationInfo.IsA('TO_PRI') 
		&& TO_PRI(s_Player(PawnOwner).PlayerReplicationInfo).bHasBomb )
	{
		Canvas.SetPos(X, Y);
		Canvas.DrawTile(Texture'Zone_Bomb64', Scale64, Scale64, 0, 0, 64.0, 64.0);
//		Y += Scale72;
	}
	
}


///////////////////////////////////////
// ShowPreRound
///////////////////////////////////////

final simulated function ShowPreRound(Canvas C)
{
	local	float									X, Y;
	local	float									XL, YL;
	local	TO_ScenarioInfo				SI;
	local float									Scale2;
	local	s_GameReplicationInfo	GRI;

	SI = s_Player(PlayerOwner).SI;

	if ( s_Player(PlayerOwner).bActionWindow || PlayerOwner.bShowScores || (SI == None) )
		return;

	// Darkening screen
	// HUDMODFIX
	if (s_Player(PlayerOwner) != None && !s_Player(PlayerOwner).bHUDModFix)
	{
		C.Style = 4;
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;
		C.SetPos(0,0);
		C.DrawTile(Texture'debug16', C.ClipX, C.ClipY, 0, 0, 16, 16);
	}

	C.Font = MyFonts.GetMediumFont( C.ClipX );
	//C.Style = ERenderStyle.STY_Translucent;
	C.Style = ERenderStyle.STY_Normal;
	C.DrawColor = WhiteColor;

	// Screenshots
	if ( SI.ObjShot1 != None )
	{
		C.SetPos( C.ClipX / 6.0 - Scale128, Scale64);
		C.DrawTile(SI.ObjShot1, Scale256, Scale256, 0, 0, 256, 256);
	}

	if ( SI.ObjShot2 != None )
	{
		C.SetPos( 5.0 * C.ClipX / 6.0 - Scale128, Scale64);
		C.DrawTile(SI.ObjShot2, Scale256, Scale256, 0, 0, 256, 256);
	}

	if ( SI.ObjShot3 != None )
	{
		C.SetPos( C.ClipX / 6.0 - Scale128, C.ClipY - Scale64 - Scale256);
		C.DrawTile(SI.ObjShot3, Scale256, Scale256, 0, 0, 256, 256);
	}

	if ( SI.ObjShot4 != None )
	{
		C.SetPos( 5.0 * C.ClipX / 6.0 - Scale128, C.ClipY - Scale64 - Scale256);
		C.DrawTile(SI.ObjShot4, Scale256, Scale256, 0, 0, 256, 256);
	}

	C.Style = Style;
	C.StrLen("test", XL, YL);
	X = 0;
	Y = YL * 7;
	YL += Scale8;
	C.bCenter = true;

	// Scenario
	C.DrawColor = RedColor;
	C.SetPos(X, Y);
	C.DrawText("Scenario - "$SI.ScenarioName, False);

	Y += YL * 2;

	C.Font = MyFonts.GetSmallFont( C.ClipX );

	// ScenarioComment1
	Y += YL;
	C.SetPos(X, Y);
	C.DrawText(SI.ScenarioDescription1, False);

	// ScenarioComment2
	Y += YL;
	C.SetPos(X, Y);
	C.DrawText(SI.ScenarioDescription2, False);

	Y += YL * 2;
	C.DrawColor = RedColor;
	C.Font = MyFonts.GetMediumFont( C.ClipX );
	C.SetPos(X, Y);
	C.DrawText("- Mission objectives -", False);

	C.Font = MyFonts.GetSmallFont( C.ClipX );
	C.DrawColor = WhiteColor;
	Y += YL;


	if (PlayerOwner.PlayerReplicationInfo.Team == 0)
	{
		// Terr_Mission1
		Y += YL;
		C.SetPos(X, Y);
		C.DrawText(SI.Terr_Objective1, False);

		// Terr_Mission2
		Y += YL;
		C.SetPos(X, Y);
		C.DrawText(SI.Terr_Objective2, False);

		// Terr_Mission3
		Y += YL;
		C.SetPos(X, Y);
		C.DrawText(SI.Terr_Objective3, False);

		// Terr_Mission4
		Y += YL;
		C.SetPos(X, Y);
		C.DrawText(SI.Terr_Objective4, False);
	}
	else if (PlayerOwner.PlayerReplicationInfo.Team == 1)
	{
		// CT_Mission1
		Y += YL;
		C.SetPos(X, Y);
		C.DrawText(SI.SF_Objective1, False);

		// CT_Mission2
		Y += YL;
		C.SetPos(X, Y);
		C.DrawText(SI.SF_Objective2, False);

		// CT_Mission3
		Y += YL;
		C.SetPos(X, Y);
		C.DrawText(SI.SF_Objective3, False);

		// CT_Mission4
		Y += YL;
		C.SetPos(X, Y);
		C.DrawText(SI.SF_Objective4, False);
	}

	C.Font = MyFonts.GetSmallFont( C.ClipX );
	C.bCenter = true;
	C.Style = ERenderStyle.STY_Normal;
	C.DrawColor = GreenColor * TutIconBlink;

	//GRI = s_GameReplicationInfo(s_Player(PlayerOwner).GameReplicationInfo);
	if ( IsPreRound() ) 
	{
		C.SetPos(4, C.ClipY - Scale128);
		C.DrawText("Use the Action Window to buy Weapons / Items / Ammo", true );
	}

	// Restore defaults
	C.bCenter = false;
	C.DrawColor = WhiteColor;
	C.Style = Style;

}


///////////////////////////////////////
// DrawBigNum
///////////////////////////////////////

simulated function DrawBigNum(Canvas Canvas, int Value, int X, int Y, optional float ScaleFactor)
{
	local int d, Mag, Step;
	local float UpScale;
	local byte bMinus;

	if ( ScaleFactor != 0 )
		UpScale = Scale * ScaleFactor;
	else
		UpScale = Scale;

	Canvas.CurX = X;	
	Canvas.CurY = Y;
	Step = 16 * UpScale;
	if ( Value < 0 )
		bMinus = 1;
	Mag = FMin(99999, Abs(Value));
	if (Mag >= 10000)
		Canvas.CurX +=Step;

	// Now supports 4 digits numbers.
	if ( Mag >= 10000 )
	{
		Canvas.CurX -= 2*Step;
		d = 0.0001 * Mag;
		DrawDigit(Canvas, d, Step, UpScale, bMinus);
		Mag = Mag - 10000 * d;
		//Canvas.CurX -= Step;
		d = 0.001 * Mag;
		DrawDigit(Canvas, d, Step, UpScale, bMinus);
		Mag = Mag - 1000 * d;
		d = 0.01 * Mag;
		DrawDigit(Canvas, d, Step, UpScale, bMinus);
		Mag = Mag - 100 * d;
	}
	else if ( Mag >= 1000 )
	{
		Canvas.CurX -= Step;
		d = 0.001 * Mag;
		DrawDigit(Canvas, d, Step, UpScale, bMinus);
		Mag = Mag - 1000 * d;
		d = 0.01 * Mag;
		DrawDigit(Canvas, d, Step, UpScale, bMinus);
		Mag = Mag - 100 * d;
	}
	else if ( Mag >= 100 )
	{
		d = 0.01 * Mag;
		DrawDigit(Canvas, d, Step, UpScale, bMinus);
		Mag = Mag - 100 * d;
	}
	else
		Canvas.CurX += Step;

	if ( Mag >= 10 )
	{
		d = 0.1 * Mag;
		DrawDigit(Canvas, d, Step, UpScale, bMinus);
		Mag = Mag - 10 * d;
	}
	else if ( d >= 0 )
		DrawDigit(Canvas, 0, Step, UpScale, bMinus);
	else
		Canvas.CurX += Step;

	DrawDigit(Canvas, Mag, Step, UpScale, bMinus);
}


///////////////////////////////////////
// SetIDColor
///////////////////////////////////////

simulated function SetIDColor( Canvas Canvas, int type )
{
	if (IdentifyTarget.Team < 2)
	{
		if ( type == 0 )
			Canvas.DrawColor = AltTeamColor[IdentifyTarget.Team] * 0.333 * IdentifyFadeTime;
		else
			Canvas.DrawColor = TeamColor[IdentifyTarget.Team] * 0.333 * IdentifyFadeTime;
	}

}


///////////////////////////////////////
// FindPRI
///////////////////////////////////////

simulated function PlayerReplicationInfo	FindPRI(int PlayerID)
{
	local Pawn	P;

	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		if (P != None && P.PlayerReplicationInfo != None && P.PlayerReplicationInfo.PlayerID == PlayerID)
			return P.PlayerReplicationInfo;
	
	return None;
}


///////////////////////////////////////
// Draw_Blinded
///////////////////////////////////////

final simulated function	Draw_Blinded(Canvas C)
{
	local float col;

	C.Style = Style;
	if ( s_Player(PlayerOwner).BlindTime < 10 )
		col = (255 * s_Player(PlayerOwner).BlindTime) / 10;
	else
		col = 255;

	C.DrawColor.R = col;
	C.DrawColor.G = col;
	C.DrawColor.B = col;
	C.SetPos(0, 0);
	C.DrawTile(Texture'TileWhite', C.ClipX, C.ClipY, 0, 0, 32.0, 32.0);
	
	//else
	//	s_Player(PlayerOwner).bBlinded=false;
}


///////////////////////////////////////
// Timer
///////////////////////////////////////

function Timer()
{
	local	int				i;
	//local	Mutator		M;

	Super.Timer();

	/*
	// No HUD mutators
	if ( HUDMutator != None )
	{
		M = HUDMutator;
		while ( M != None )
		{
			M = HUDMutator.NextHUDMutator;
			HUDMutator.Destroy();
			HUDMutator = M;
		}
	}
	*/
	// Death messages
	if ( s_DeathM_idx > 0 )
	{
		s_DeathM[0].EndOfLife--;
		if (s_DeathM[0].EndOfLife < 1)
			Shift_Death_Message();
	}

	// Money
	if ( MoneyM_idx > 0 )
	{
		MoneyM[0].EndOfLife--;
		if (MoneyM[0].EndOfLife < 1)
			Shift_Money_Message();
	}
}


///////////////////////////////////////
// IsInRescueZone
///////////////////////////////////////

final simulated function bool IsInRescueZone(Pawn P)
{
	if (P.IsA('s_Player'))
		return s_Player(P).bInRescueZone;

	return false;
}


///////////////////////////////////////
// IsInBuyZone
///////////////////////////////////////

final simulated function bool IsInBuyZone(Pawn P)
{
	if (P.IsA('s_Player'))
		return s_Player(P).bInBuyZone;

	return false;
}


///////////////////////////////////////
// IsInHomeBase
///////////////////////////////////////

final simulated function bool IsInHomeBase(Pawn P)
{
	if (P.IsA('s_Player'))
		return s_Player(P).bInHomeBase;

	return false;
}


///////////////////////////////////////
// IsInEscapeZone
///////////////////////////////////////

final simulated function bool IsInEscapeZone(Pawn P)
{
	if (P.IsA('s_Player'))
		return s_Player(P).bInEscapeZone;

	return false;
}


///////////////////////////////////////
// IsInBombingZone
///////////////////////////////////////

final simulated function bool IsInBombingZone(Pawn P)
{
	if (P.IsA('s_Player'))
		return s_Player(P).bInBombingZone;

	return false;
}


///////////////////////////////////////
// DrawSprayPaint
///////////////////////////////////////

simulated function DrawSprayPaint(Canvas C)
{ /*
	local float XLimit, IconDrawScale;
	local int i;
	local DecalGenerator DecalGen;

	IconDrawScale = scale * StatusScale;		// Used to position icon...
	XLimit = C.ClipX;												// Used to position icon...
	C.SetPos(XLimit - (128*IconDrawScale) - 104 * scale, 146 * scale);

	if (!s_Player(PlayerOwner).bDead)
	{
		foreach AllActors(class'DecalGenerator',DecalGen)
		{
			//log("scanning decals");
			if (DecalGen.Owner == PlayerOwner)
			{
				//log("drawing decal on HUD");
				C.DrawIcon(DecalGen.DecalTravel[DecalGen.DecalSelected],scale);
				break;
			}
		}
	}
	*/
}


///////////////////////////////////////
// s_kShowObjectives
///////////////////////////////////////

final exec function s_kShowObjectives()
{
//	local s_GameReplicationInfo		GRI;

//	GRI = s_GameReplicationInfo(s_Player(PawnOwner).GameReplicationInfo);
	if ( IsPreRound() || PlayerOwner.bShowScores)
		bShowObjectives = false;
	else
		bShowObjectives = !bShowObjectives;
}


simulated function bool	IsPreRound()
{
	if ( PlayerOwner.GetStateName() == 'PreRound' )
		return true;
	return false;
}


///////////////////////////////////////
// Message
///////////////////////////////////////

simulated function Message( PlayerReplicationInfo PRI, coerce string Msg, name MsgType )
{
	local int i;
	local Class<LocalMessage> MessageClass;

	switch (MsgType)
	{
		case 'Say':
			MessageClass = class's_SayMessage';
			break;
		case 'TeamSay':
			MessageClass = class's_TeamMessage';
			break;
		case 'CriticalEvent':
			MessageClass = class'CriticalStringPlus';
			LocalizedMessage( MessageClass, 0, None, None, None, Msg );
			return;
		default:
			MessageClass= class'StringMessagePlus';
			break;
	}

	for (i=0; i<4; i++)
	{
		if ( ShortMessageQueue[i].Message == None )
		{
			// Add the message here.
			ShortMessageQueue[i].Message = MessageClass;
			ShortMessageQueue[i].Switch = 0;
			ShortMessageQueue[i].RelatedPRI = PRI;
			ShortMessageQueue[i].OptionalObject = None;
			ShortMessageQueue[i].EndOfLife = MessageClass.Default.Lifetime + Level.TimeSeconds;
			if ( MessageClass.Default.bComplexString )
				ShortMessageQueue[i].StringMessage = Msg;
			else
				ShortMessageQueue[i].StringMessage = MessageClass.Static.AssembleString(self,0,PRI,Msg);
			ShortMessageQueue[i].bDrawing = ( ClassIsChildOf(MessageClass, class's_SayMessage') || 
				     ClassIsChildOf(MessageClass, class's_TeamMessage') );
			return;
		}
	}

	// No empty slots.  Force a message out.
	for (i=0; i<3; i++)
		CopyMessage(ShortMessageQueue[i],ShortMessageQueue[i+1]);

	ShortMessageQueue[3].Message = MessageClass;
	ShortMessageQueue[3].Switch = 0;
	ShortMessageQueue[3].RelatedPRI = PRI;
	ShortMessageQueue[3].OptionalObject = None;
	ShortMessageQueue[3].EndOfLife = MessageClass.Default.Lifetime + Level.TimeSeconds;
	if ( MessageClass.Default.bComplexString )
		ShortMessageQueue[3].StringMessage = Msg;
	else
		ShortMessageQueue[3].StringMessage = MessageClass.Static.AssembleString(self,0,PRI,Msg);
	ShortMessageQueue[3].bDrawing = ( ClassIsChildOf(MessageClass, class's_SayMessage') || 
			 ClassIsChildOf(MessageClass, class's_TeamMessage') );
}



///////////////////////////////////////
// TraceIdentify
///////////////////////////////////////

simulated function bool TraceIdentify(canvas Canvas)
{
	local actor		Other;
	local vector	HitLocation, HitNormal, StartTrace, EndTrace;
	local	float		MaxRange;

	if (PawnOwner.Weapon != None && PawnOwner.Weapon.IsA('s_Weapon') )
	{
		MaxRange = s_Weapon(PawnOwner.Weapon).MaxRange;
		if (MaxRange < 1000)
			MaxRange = 1000.0;
	}
	else
		MaxRange = 1000.0;

	StartTrace = PawnOwner.Location;
	StartTrace.Z += PawnOwner.BaseEyeHeight;
	EndTrace = StartTrace + vector(PawnOwner.ViewRotation) * MaxRange;
	Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

	if ( Pawn(Other) != None )
	{
		if ( Pawn(Other).bIsPlayer && !Other.bHidden )
		{
			IdentifyTarget = Pawn(Other).PlayerReplicationInfo;
			IdentifyFadeTime = 2.0;
		}
	}
	else if ( (Other != None) && SpecialIdentify(Canvas, Other) )
		return false;

	if ( (IdentifyFadeTime == 0.0) || (IdentifyTarget == None) || IdentifyTarget.bFeigningDeath )
	{
		if (IdentifyFadeTime == 0.0)
			IdentifyTarget = None;
		return false;
	}

	return true;
}

 
///////////////////////////////////////
// TraceCrosshair
///////////////////////////////////////

simulated function	PlayerReplicationInfo TraceCrosshair()
{
	local actor		Other;
	local vector	HitLocation, HitNormal, StartTrace, EndTrace;
	local	float		MaxRange;

	if (PlayerOwner.Weapon != None && PawnOwner.Weapon.IsA('s_Weapon'))
	{
		MaxRange = s_Weapon(PlayerOwner.Weapon).MaxRange;
		if (MaxRange < 1000)
			MaxRange = 1000.0;
	}
	else
		MaxRange = 1000.0;

	StartTrace = PawnOwner.Location;
	StartTrace.Z += PawnOwner.BaseEyeHeight;
	EndTrace = StartTrace + vector(PawnOwner.ViewRotation) * MaxRange;
	Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

	if ( Pawn(Other) != None )
	{
		if ( Pawn(Other).bIsPlayer && !Other.bHidden )
			return Pawn(Other).PlayerReplicationInfo;
	}

	return None;
}


///////////////////////////////////////
// DrawCrossHair
///////////////////////////////////////

simulated function DrawCrossHair( canvas Canvas, int X, int Y)
{
	local	PlayerReplicationInfo	TracedPRI;

	//TracedPRI = TraceCrosshair();
	TracedPRI = IdentifyTarget;

	CrosshairColor.R = 16;
	CrosshairColor.G = 16;
	CrosshairColor.B = 16;
	
	if (TracedPRI == None)
	{
		CrosshairColor.R = 16;
		CrosshairColor.G = 16;
		CrosshairColor.B = 16;
	}
	else if ( (TracedPRI != None) && (TracedPRI.Team == PlayerOwner.PlayerReplicationInfo.Team) && TracedPRI.Team < 2)
	{
		CrosshairColor.R = 0;
		CrosshairColor.G = 16;
		CrosshairColor.B = 0;
	}
	// Show enemies
/*	else if (TracedPRI != None && TracedPRI.Team != PlayerOwner.PlayerReplicationInfo.Team 
		&& TracedPRI.Team < 2)
	{
		CrosshairColor.R = 16;
		CrosshairColor.G = 0;
	}
*/
	Super.DrawCrossHair(Canvas, X, Y);

}


//
// Debugging
//


///////////////////////////////////////
// ShowDebug
///////////////////////////////////////

final function ShowDebug(Canvas C)
{
	local	float				Y;
	local	float				XL, YL;
	local	int					i;
	local	s_SWATGame	SG;
	local s_GameReplicationInfo		GRI;
	local	s_Player		PL;
	local	string			CurrentMessage;
	
	if (PawnOwner == None)
		return;

	SG = s_SWATGame(Level.game);
	GRI = s_GameReplicationInfo(PlayerOwner.GameReplicationInfo);
	PL = s_Player(PlayerOwner);

	// Darkening screen
	// HUDMODFIX
	if (PL != None && !PL.bHUDModFix)
	{
		C.Style = 4;
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;
		C.SetPos(0,0);
		C.DrawTile(Texture'Debug16', C.ClipX, C.ClipY, 0, 0, 16, 16);
	}

	C.Font = MyFonts.GetAReallySmallFont( C.ClipX );
	C.Style = ERenderStyle.STY_Translucent;
	C.DrawColor = WhiteColor;

	C.StrLen("test", XL, YL);
	Y = YL;
	YL += Scale8;

	ShowDebugActor(C, PawnOwner, Y, true);

/*
	// BotConfig.Difficulty
	if (s_SWATGame(Level.Game) != None)
	{
		Y += YL;
		C.SetPos(X, Y);
		C.DrawText("BotConfig.Difficulty: "$s_SWATGame(Level.Game).BotConfig.Difficulty, False);
	}
*/

	// Netmode
	CurrentMessage = "Level.NetMode: "$Level.NetMode;
	WriteDebugString(C, CurrentMessage, Y, true);

	// GRI
	if ( GRI != None )
		CurrentMessage = "GRI.bPreRound: "$GRI.bPreRound@"P:"@IsPreRound();
	else
		CurrentMessage = "s_GameReplicationInfo == None";
	WriteDebugString(C, CurrentMessage, Y, true);

	// Level.Game
	CurrentMessage = "Level.Game: "$Level.Game;
	WriteDebugString(C, CurrentMessage, Y, true);

	if (SG != None)
	{
		// TO_ScenarioInfo
		CurrentMessage = "TO_Scenario (L.G): "$SG.SI;
		WriteDebugString(C, CurrentMessage, Y, true);

		// TeamSize
		CurrentMessage = "Team size - Terrorists: "$SG.Teams[0].size$"- SWAT: "$SG.Teams[1].size;
		WriteDebugString(C, CurrentMessage, Y, true);

		if (SG.SI != None)
		{
			// -- Special Forces Objectives
			CurrentMessage = "-- Special Forces Objectives --";
			WriteDebugString(C, CurrentMessage, Y, true);

			for (i = 0; i < 10; i++)
				if (!SG.IsNullObjective(1, i))
				{
					CurrentMessage = "["$i$"]-Objective: "$SG.SI.GetTeamObjectiveName(1, i)
						$" -Order: "$SG.IsOrderObjective(1, i)
						$" -Primary: "$SG.IsPrimaryObjective(1, i)
						$" -Once: "$SG.IsOnceObjective(1, i)
						$" -bToggle: "$SG.SI.GetTeamObjectivePub(1, i).bToggle				
						$" -bToggleTo: "$SG.SI.GetTeamObjectivePub(1, i).bToggleTo
						$" -Accomplished: "$SG.SI.SF_ObjectivesPriv[i].bObjectiveAccomplished
						$" -Target: "$SG.SI.GetTeamObjectivePriv(1, i).ActorTarget;

					if ( SG.SI.GetTeamObjectivePriv(1, i).Leader != None )
						CurrentMessage = CurrentMessage$" -Leader: "$SG.SI.GetTeamObjectivePriv(1, i).Leader.GetHumanName();
					else
						CurrentMessage = CurrentMessage$" -Leader: None";

					WriteDebugString(C, CurrentMessage, Y, true);
				}

			// -- Terrorists Objectives
			CurrentMessage = "-- Terrorists Objectives --";
			WriteDebugString(C, CurrentMessage, Y, true);

			for (i = 0; i < 10; i++)
				if (!SG.IsNullObjective(0, i))
				{
					CurrentMessage = "["$i$"]-Objective: "$SG.SI.GetTeamObjectiveName(0, i)
						$" -Order: "$SG.IsOrderObjective(0, i)
						$" -Primary: "$SG.IsPrimaryObjective(0, i)
						$" -Once: "$SG.IsOnceObjective(0, i)
						$" -bToggle: "$SG.SI.GetTeamObjectivePub(0, i).bToggle				
						$" -bToggleTo: "$SG.SI.GetTeamObjectivePub(0, i).bToggleTo
						$" -Accomplished: "$SG.SI.Terr_ObjectivesPriv[i].bObjectiveAccomplished
						$" -Target: "$SG.SI.GetTeamObjectivePriv(0, i).ActorTarget;

					if ( SG.SI.GetTeamObjectivePriv(0, i).Leader != None )
						CurrentMessage = CurrentMessage$" -Leader: "$SG.SI.GetTeamObjectivePriv(0, i).Leader.GetHumanName();
					else
						CurrentMessage = CurrentMessage$" -Leader: None";
					WriteDebugString(C, CurrentMessage, Y, true);
				}		
		}
	}
	else
	{
		CurrentMessage = "SG: None";
		WriteDebugString(C, CurrentMessage, Y, true);
	}

}


///////////////////////////////////////
// WriteDebugString
///////////////////////////////////////

final function WriteDebugString(Canvas C, String CurrentMessage, out float Y, bool bLeftIdent)
{
	local	float	X, XL, YL, XL2, YL2;

	C.StrLen(" ", XL, YL);
	Y += YL;

	if (!bLeftIdent)
	{
		C.StrLen(CurrentMessage, XL2, YL2);
		X = C.ClipX - XL - XL2;
	}
	else
		X = XL;

	C.SetPos(X, Y);
	C.DrawText(CurrentMessage, False);
}


final function ShowDebugActor(Canvas C, Actor P, out float Y, bool bLeftIdent)
{
	local	String CurrentMessage;
	local	int	i;

	// Class
	CurrentMessage = "A Class: "$P.Class;
	WriteDebugString(C, CurrentMessage, Y, bLeftIdent);

	// AnimSequence
	CurrentMessage = "A AnimSequence: "$P.AnimSequence;
	WriteDebugString(C, CurrentMessage, Y, bLeftIdent);

	// State
	CurrentMessage = "A State: "$P.GetStateName();
	WriteDebugString(C, CurrentMessage, Y, bLeftIdent);

	// Physics
	CurrentMessage = "A Physics: "$P.Physics;
	WriteDebugString(C, CurrentMessage, Y, bLeftIdent);

	// Mesh
	CurrentMessage = "A Mesh: "$P.Mesh;
	WriteDebugString(C, CurrentMessage, Y, bLeftIdent);

	// Touching list
	for ( i=0; i<4; i++)
	{
		CurrentMessage = "A Touching["$i$"]:"@P.Touching[i];
		WriteDebugString(C, CurrentMessage, Y, bLeftIdent);
	}

	// RegionZone
	CurrentMessage = "A Zone:"@P.Region.Zone;
	WriteDebugString(C, CurrentMessage, Y, bLeftIdent);

	if ( Pawn(P) != None )
		ShowDebugPawn(C, Pawn(P), Y, bLeftIdent);
}


///////////////////////////////////////
// ShowDebugPawn
///////////////////////////////////////

final function ShowDebugPawn(Canvas C, Pawn P, out float Y, bool bLeftIdent)
{
	local	String CurrentMessage;

	// PlayerReplicationInfo
	if (P.PlayerReplicationInfo != None)
	{
		// name
		CurrentMessage = CurrentMessage$"P Name: "$P.PlayerReplicationInfo.PlayerName;
		WriteDebugString(C, CurrentMessage, Y, bLeftIdent);

		// Location
		if (P.PlayerReplicationInfo.PlayerLocation == None)
			CurrentMessage = "Pawn Location: None";
		else
			CurrentMessage = "Pawn Location: "$P.PlayerReplicationInfo.PlayerLocation.LocationName;

		if (P.PlayerReplicationInfo.PlayerZone != None)
		{
			WriteDebugString(C, CurrentMessage, Y, bLeftIdent);
		
			// ZoneName
			CurrentMessage = "Pawn ZoneName: "$P.PlayerReplicationInfo.PlayerZone.ZoneName;
		}
	}
	else
		CurrentMessage = "Pawn.PlayerReplicationInfo == None";
	WriteDebugString(C, CurrentMessage, Y, bLeftIdent);

	// Collision cylinder
	CurrentMessage = "Pawn CC height: "$P.CollisionHeight
		$"   width: "$P.CollisionRadius;
	WriteDebugString(C, CurrentMessage, Y, bLeftIdent);

	// Groundspeed
	CurrentMessage = "Groundspeed: "$P.Groundspeed;
	WriteDebugString(C, CurrentMessage, Y, bLeftIdent);

	// Weapon
	if ( P.Weapon != None && s_Weapon(P.Weapon) != None )
	{
		CurrentMessage = "Weapon: "$s_Weapon(P.Weapon)
			$" State: "$s_Weapon(P.Weapon).GetStateName()
			$" bFire: "$P.bFire
			$" AnimSequence:"@P.Weapon.AnimSequence
			$" bReloadingWeapon: "$s_Weapon(P.Weapon).bReloadingWeapon;
//			$" FlashO: "$s_Weapon(P.Weapon).FlashO;
		WriteDebugString(C, CurrentMessage, Y, bLeftIdent);

		CurrentMessage = "Weapon ShotCount: "$s_Weapon(P.Weapon).ShotCount
			$" Owner: "$s_Weapon(P.Weapon).Owner
			$" rPower: "$s_Weapon(P.Weapon).rPower
			$" AimError:"@P.Weapon.AimError;
		WriteDebugString(C, CurrentMessage, Y, bLeftIdent);

		CurrentMessage = "Weapon RecoilMultiplier: "$s_Weapon(P.Weapon).RecoilMultiplier
			$" HRecoil: "$s_Weapon(P.Weapon).HRecoil
			$" VRecoil: "$s_Weapon(P.Weapon).VRecoil;
		WriteDebugString(C, CurrentMessage, Y, bLeftIdent);

		CurrentMessage = "Weapon ClipAmmo: "$s_Weapon(P.Weapon).ClipAmmo
			$" - RemaningClips:"$s_Weapon(P.Weapon).RemainingClip;
		WriteDebugString(C, CurrentMessage, Y, bLeftIdent);

		CurrentMessage = "Weapon AmbientSound:"@s_Weapon(P.Weapon).AmbientSound
			@"SoundRadius:"@s_Weapon(P.Weapon).SoundRadius
			@"- SoundVolume:"@s_Weapon(P.Weapon).SoundVolume
			@"- SoundPitch:"@SoundPitch;
		WriteDebugString(C, CurrentMessage, Y, bLeftIdent);

		CurrentMessage = "W PlayerViewOffset:"@s_Weapon(P.Weapon).PlayerViewOffset
			@"bHideWeapon:"@s_Weapon(P.Weapon).bHideWeapon;
		WriteDebugString(C, CurrentMessage, Y, bLeftIdent);
	}

	if (P.IsA('Bot'))
		ShowDebugBot(C, Bot(P), Y, bLeftIdent);

	if (P.IsA('s_Player'))
		ShowDebugPlayer(C, s_Player(P), Y, bLeftIdent);
}


///////////////////////////////////////
// ShowDebugPlayer
///////////////////////////////////////

final function ShowDebugPlayer(Canvas C, s_Player P, out float Y, bool bLeftIdent)
{
	local	int	i;
	local	String	CurrentMessage;
/*
	// Armor
	CurrentMessage = "P Helmet: "$P.HelmetCharge$"  Vest: "$P.VestCharge$"  Legs: "$P.LegsCharge;
	WriteDebugString(C, CurrentMessage, Y, bLeftIdent);

	// Footsteps
	if (s_PlayerShadow(P.Shadow) != None)
	{
		if (s_PlayerShadow(P.Shadow).WalkTexture != None)
			CurrentMessage = "P footstepsound: "$s_PlayerShadow(P.Shadow).WalkTexture.FootstepSound;
		else
			CurrentMessage = "P footstepsound: WalkTexture == None";
	}
	else
		CurrentMessage = "P footstepsound: s_PlayerShadow == None";
	WriteDebugString(C, CurrentMessage, Y, bLeftIdent);
*/
	// bDuck & bCantStandUp & bIsCrouching
	CurrentMessage = "P bDuck: "$P.bDuck$" - bCantStandUp: "$P.bCantStandUp
		$" - bIsCrouching: "$P.bIsCrouching;
	WriteDebugString(C, CurrentMessage, Y, bLeftIdent);
/*
	// BehindViewDist
	CurrentMessage = "BehindViewDist: "$s_Player(PlayerOwner).BehindViewDist
	$" - BehindViewDistFactor"$s_Player(PlayerOwner).BehindViewDistFactor;
	WriteDebugString(C, CurrentMessage, Y, bLeftIdent);
*/
	CurrentMessage = "P DesiredFOV:"@P.DesiredFOV@"DefaultFOV:"@P.DefaultFOV@"FOVAngle:"@P.FOVAngle@"bSZoom:"@P.bSZoom;
	WriteDebugString(C, CurrentMessage, Y, bLeftIdent);

	// Game Flags
	CurrentMessage = "P GFlags: bNotPlaying: "$P.bNotPlaying;
	WriteDebugString(C, CurrentMessage, Y, bLeftIdent);

	// SLI
	if (P.SI != None)
		CurrentMessage = "P SI: "$P.SI$" - Scenario: "$P.SI.ScenarioName;
	else
		CurrentMessage = "P SI == None";
	WriteDebugString(C, CurrentMessage, Y, bLeftIdent);
/*
	// Zone Flags
	CurrentMessage = "P ZFlags: bBuyZone: "$P.bInBuyZone;
	WriteDebugString(C, CurrentMessage, Y, bLeftIdent);

	// Touching
	for (i=0; i<4; i++)
		if ( P.Touching[i] != None)
		{
			if (P.Touching[i].IsA('s_ZoneControlPoint') )
				CurrentMessage = "P Touching["$i$"]: "$P.Touching[i]$" - bBuyZone: "$s_ZoneControlPoint(P.Touching[i]).bBuyPoint;
			else
				CurrentMessage = "P Touching["$i$"]: "$P.Touching[i];
			WriteDebugString(C, CurrentMessage, Y, bLeftIdent);
		}

	// ViewFlash
	CurrentMessage = "P InstantFlash: "$P.InstantFlash$" - InstantFog: "$P.InstantFog
		$" - FlashScale: "$P.FlashScale$" - FlashFog: "$P.FlashFog
		$" - DesiredFlashScale: "$P.DesiredFlashScale$" - DesiredFlashFog: "$P.DesiredFlashFog;
	WriteDebugString(C, CurrentMessage, Y, bLeftIdent);
*/
}


///////////////////////////////////////
// ShowDebugBot
///////////////////////////////////////

final function ShowDebugBot(Canvas C, Bot B, out float Y, bool bLeftIdent)
{
	local string	CurrentMessage;

	// Skill
	CurrentMessage = "Bot Skill: "$B.Skill;
	WriteDebugString(C, CurrentMessage, Y, bLeftIdent);

	// Orders
	CurrentMessage = "Bot Orders: "$B.Orders;
	WriteDebugString(C, CurrentMessage, Y, bLeftIdent);

	// Order object
	CurrentMessage = "Bot OrderObject: "$B.OrderObject;
	WriteDebugString(C, CurrentMessage, Y, bLeftIdent);

	//	MoveTarget
	CurrentMessage = "Bot MoveTarget: "$B.MoveTarget;
	WriteDebugString(C, CurrentMessage, Y, bLeftIdent);

	if (B.IsA('s_Bot'))
		ShowDebugs_Bot(C, s_Bot(B), Y, bLeftIdent);

	if (B.IsA('s_NPCHostage'))
		ShowDebugHostage(C, s_NPCHostage(B), Y, bLeftIdent);
}


///////////////////////////////////////
// ShowDebugs_Bot
///////////////////////////////////////

final function ShowDebugs_Bot(Canvas C, s_Bot B, out float Y, bool bLeftIdent)
{
	local string	CurrentMessage;
		
	// Objective
	if (B.Objective == '')
		CurrentMessage = "s_Bot Objective:  None";
	else
		CurrentMessage = "s_Bot Objective: "$B.Objective$" - O_number: "$B.O_number;
	WriteDebugString(C, CurrentMessage, Y, bLeftIdent);

	//	Enemy
	CurrentMessage = "B Enemy: "$B.Enemy$" bReadyToAttack: "$B.bReadyToAttack;
	if (B.Enemy != None && B.Enemy.IsA('Pawn') && B.Enemy.PlayerReplicationInfo != None)
		CurrentMessage = CurrentMessage$" Name: "$B.Enemy.PlayerReplicationInfo.PlayerName;
	WriteDebugString(C, CurrentMessage, Y, bLeftIdent);

	//	HostageFollowing
	CurrentMessage = "B HostageFollowing: "$B.HostageFollowing;
	WriteDebugString(C, CurrentMessage, Y, bLeftIdent);

	// Money
	CurrentMessage = "s_Bot Money: "$B.Money;
	WriteDebugString(C, CurrentMessage, Y, bLeftIdent);

	// bNeedAmmo
	CurrentMessage = "s_Bot bNeedAmmo: "$B.bNeedAmmo;
	WriteDebugString(C, CurrentMessage, Y, bLeftIdent);

}


///////////////////////////////////////
// ShowDebugHostage
///////////////////////////////////////

final function ShowDebugHostage(Canvas C, s_NPCHostage	H, out float Y, bool bLeftIdent)
{
	local string	CurrentMessage;

	// bIsFree
	CurrentMessage = "Hostage bIsFree: "$H.bIsFree;
	WriteDebugString(C, CurrentMessage, Y, bLeftIdent);

	// Followed
	CurrentMessage = "Hostage Followed: "$H.Followed;
	WriteDebugString(C, CurrentMessage, Y, bLeftIdent);

}


///////////////////////////////////////
// TraceActor
///////////////////////////////////////

simulated function Actor TraceActor()
{
	local actor		Other;
	local vector	HitLocation, HitNormal, StartTrace, EndTrace;
	local	float		MaxRange;

	MaxRange = 10000.0;

	StartTrace = PawnOwner.Location;
	StartTrace.Z += PawnOwner.BaseEyeHeight;
	EndTrace = StartTrace + vector(PawnOwner.ViewRotation) * MaxRange;
	Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

	return Other;
}


///////////////////////////////////////
// DrawIdentifyInfo
///////////////////////////////////////

simulated function bool DrawIdentifyInfo(canvas Canvas)
{
	local	float					X, Y, X2;
	local float					XL, YL, XL2, YL2;
	local string				CurrentMessage;
	local	Actor					A;

	// Draw Identify
	if ( Super.DrawIdentifyInfo(Canvas) )
	{
		if ( s_Player(PlayerOwner).bShowDebug && (Pawn(IdentifyTarget.Owner) != None) )
		{
			/*P = Bot(IdentifyTarget.Owner);
			if ( P == None )
				return false;
	*/
			Canvas.Font = MyFonts.GetAReallySmallFont( Canvas.ClipX );
			Canvas.Style = ERenderStyle.STY_Translucent;
			Canvas.DrawColor = WhiteColor;

			Canvas.StrLen(" ", XL, YL);
			Y = YL;
			YL += Scale8;

			ShowDebugActor(Canvas, Pawn(IdentifyTarget.Owner), Y, false);

			Canvas.Style = Style;
		}
	}
	else if ( s_Player(PlayerOwner).bShowDebug )
	{
		// Trace debug
		A = TraceActor();
		if ( A != None )
			ShowDebugActor(Canvas, A, Y, false);
	}

	return true;
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     s_team(0)="Terrorists"
     s_team(1)="Special Forces"
     GreyColor=(R=128,G=128,B=128)
     FP1(0)=None
     FP1(1)=None
     FP1(2)=None
     FP2(0)=None
     FP2(1)=None
     FP2(2)=None
     FP3(0)=None
     FP3(1)=None
     FP3(2)=None
}
