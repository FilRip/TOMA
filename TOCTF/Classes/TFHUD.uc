class TFHUD extends s_HUD;

var TFFlags MyFlag;
var TFFlags OurFlag;
var byte lastsay;

simulated function PostRender(canvas Canvas)
{
	local bool								hideCrap;
	local s_GameReplicationInfo				GRI;
	local s_Player							P;

	if ( !TFHud_Tool_BeforePaint(Canvas) )
	{
		if ( UserInterface != None )
			UserInterface.Hide();

		return;
	}

	//------------------
	//  effects
	//------------------

	P = s_Player(PlayerOwner);

	//------------------
	//  TO specific
	//------------------

	if ( P != None )
	{
   		// Turn off NVLight
		if ((bNVActive && !P.zzbNightVision) || (!P.bHasNV && P.zzbNightVision))
        {
            bNVActive = false;
            P.zzbNightVision = false;
            NVLight.Destroy();
            //s_Player(PlayerOwner).Weapon.AmbientGlow=0;
            //s_Player(PlayerOwner).Weapon.ScaleGlow=1;
        }

		// nightvision
		if ( P.zzbNightVision && !PlayerOwner.bShowScores && P.bHasNV)
		{
			TOHud_DrawNightvision(Canvas, P.bHUDModFix);
		}

	}

   	// flashbang
	TOHud_DrawBlinded(Canvas); // moved

	if ( P != None )
	{
		// widescreen
		if (PlayerOwner.IsInState('PlayerSpectating') && bDrawWidescreen)
		{
			TOHud_DrawWidescreen(Canvas, P.bHUDModFix);
		}

		if ( P.RendMap != 5 ) // catch lightingcheaters
		{
			P.RendMap = 5;
		}

		Canvas.Style = Style;

		// action window
		if ( P.bActionWindow && (s_Player(PlayerOwner) != None) && !s_Player(PlayerOwner).bHUDModFix)
		{
			TOHud_DarkenScreen(Canvas);
		}
	}

	//------------------
	//  main menu hide
	//------------------

	if ( (P != None) && (P.bMenuVisible) )
	{
		return;
	}

	if ( PlayerOwner.IsA('TO_Spectator') && TO_Spectator(PlayerOwner).bMenuVisible )
		return;

	// GUI visible?
	if ( UserInterface != None )
		hideCrap = UserInterface.Visible();
	else
		hideCrap = false;

	//------------------
	//  hud
	//------------------

	if ( !hideCrap )
	{
		// team info & identification
		if ( !PlayerOwner.PlayerReplicationInfo.bIsSpectator && (FrameTeaminfo != 255) && (PlayerOwner.DesiredFOV == PlayerOwner.DefaultFOV) )
		{
			TOHud_DrawTeaminfo(Canvas);
		}
		else if ( (PawnOwner == PlayerOwner) || (PlayerOwner.IsA('s_Player') && P.bShowDebug && !PlayerOwner.bShowScores) )
		{
			TOHud_DrawIdentification(Canvas);
		}

		// crosshair & hit location
		if ( !PlayerOwner.bBehindView && (PawnOwner.Weapon != None) && (Level.LevelAction == LEVACT_None))
		{
			if (!hideCrap)
			{
				TOHud_DrawCrosshair(Canvas, 0, 0);
			}
			TOHud_DrawHitlocation(Canvas);
		}
		else
		{
			TOHud_Tool_ClearHitlocation();
		}
	}

	//------------------
	//  messages
	//------------------

	// death msg
	TOHud_DrawDeathmessage(Canvas);

	// short msg
	TOHud_DrawShortmessages(Canvas);

	if ( hideCrap )
	{
		// GUI visible, draw dark background
		TOHud_DarkenScreen(Canvas);
	}


	//------------------
	//  gui
	//------------------

	if ( UserInterface != None )
	{
		// briefing
		if ( bForceBriefing )
		{
			UserInterface.SelectTab(UserInterface.UIT_BRIEFING);
			bForceBriefing = false;
		}
		else if ( IsPreRound() && !bPreroundShown )
		{
			UserInterface.SelectTab(UserInterface.UIT_BRIEFING);
			bPreroundHidden = false;
			//if ( Level.Netmode != NM_StandAlone )
			bPreroundShown = true;
		}
		else if ( bToggleBriefing )
		{
			UserInterface.ToggleTab(UserInterface.UIT_BRIEFING);
			bPreroundHidden = true;
			bToggleBriefing = false;
		}
		// buymenu
		else if (bToggleBuymenu)
		{
			UserInterface.ToggleTab(UserInterface.UIT_BUYMENU);
			bToggleBuymenu = false;
		}
		// server info
		else if ( bShowInfo )
		{
			UserInterface.ToggleTab(UserInterface.UIT_SERVER);
			bShowInfo = false;
		}
		// credits
		else if ( bToggleCredits )
		{
			UserInterface.ToggleTab(UserInterface.UIT_CREDITS);
			bToggleCredits = false;
		}

		// hide pre round briefing
		if ( !bPreroundHidden && !IsPreRound() )
		{
			UserInterface.HideTab(UserInterface.UIT_BRIEFING);
			bPreroundHidden = true;
		}

		// hide buymenu
		if ( PawnOwner.Health <= 0 )
		{
			UserInterface.HideTab(UserInterface.UIT_BUYMENU);
		}
	}

	//------------------
	//  scoreboard
	//------------------

	if ( UserInterface != None )
	{
		// EMH REPLACE {
		if (bSinglePlayer && bForceScores) {	// Show debriefing screen if the game is over and we're playing in single player
			UserInterface.SelectTab(UserInterface.UIT_DEBRIEFING);
		}
		else if (bForceScores)
		{
			UserInterface.SelectTab(UserInterface.UIT_SCORES);
		}
		// } EMH
		else if (PlayerOwner.bShowScores)
		{
			UserInterface.ToggleTab(UserInterface.UIT_SCORES);
			PlayerOwner.bShowScores = false;
		}
	}

	//------------------
	//  mutators
	//------------------

	// hud mutator
	if ( HUDMutator != None )
	{
		HUDMutator.PostRender(Canvas);
	}

	if ( UserInterface != None )
		UserInterface.Render(Canvas);

	//------------------
	//  typing prompt
	//------------------

	if ( PlayerOwner.Player.Console.bTyping )
	{
		TOHud_DrawTypingPrompt(Canvas, PlayerOwner.Player.Console);
	}

	//------------------
	//  system
	//------------------

	// motd
	if (MOTDFadeOutTime > 0.0)
	{
		DrawMOTD(Canvas);
	}

	// startup
	if (bStartUpMessage && (Level.TimeSeconds < 5) )
	{
		bStartUpMessage = false;
		PlayerOwner.SetProgressTime(7);
	}

	// center & progress
	if (!bHideCenterMessages)
	{
		TOHud_DrawCentermessages(Canvas);
		if (PlayerOwner.ProgressTimeOut > Level.TimeSeconds)
		{
			DisplayProgressMessage(Canvas);
		}
	}

	// mapchange
	if (PlayerOwner.GameReplicationInfo != None)
	{
		if ( PlayerPawn(Owner).GameReplicationInfo.RemainingTime == 0 )
		{
			if ( bDisplayMapChangeMessage )
			{
				PlayerOwner.ReceiveLocalizedMessage(class's_MessageRoundWinner', 8);
				bDisplayMapChangeMessage = false;
			}
		}
		else if ( !bDisplayMapChangeMessage )
		{
			bDisplayMapChangeMessage = true;
		}
	}

	//------------------
	//  debug
	//------------------

	if ( (P != None) && P.bShowDebug && !PlayerOwner.bShowScores )
	{
		ShowDebug(Canvas);
	}

	//------------------
	//  lifefeed & spectator
	//------------------

	// live feed
	if ( (PawnOwner != Owner) && PawnOwner.bIsPlayer && P != none)
	{
		if (!P.bBehindView && s_BPlayer(PawnOwner) != none)
		{
    		//replicate zoom stuff
			P.bSZoom = s_BPlayer(PawnOwner).bSZoom;
			P.SZoomVal = s_BPlayer(PawnOwner).SZoomVal;
			if ( P.bSZoom )
			{
				//DesiredFOV = FClamp(90.0 - (SZoomVal * 88.0), 1, 170);
				//if ( DefaultFOV != 90.0000 )
				//	DefaultFOV = 90.0000;
				if ( P.bSurroundGaming )
				{
					if ( P.SZoomVal == 0.5 )
						P.DesiredFOV = P.DefaultSurroundZoomLvl1;
					else if ( P.SZoomVal == 0.85 )
						P.DesiredFOV = P.DefaultSurroundZoomLvl2;
					else
						P.DesiredFOV = P.DefaultSurroundFOV;

					if ( P.DefaultFOV != P.DefaultSurroundFOV )
						P.DefaultFOV = P.DefaultSurroundFOV;
				}
				else
				{
					if ( P.SZoomVal == 0.5 )
						P.DesiredFOV = P.DefaultZoomLvl1;
					else if ( P.SZoomVal == 0.85 )
						P.DesiredFOV = P.DefaultZoomLvl2;
					else
						P.DesiredFOV = P.DefaultOriginalFOV;

					if ( P.DefaultFOV != P.DefaultOriginalFOV )
						P.DefaultFOV = P.DefaultOriginalFOV;
				}
			}
			else
			{
				// Enlarging default field of view.
				if ( P.bSurroundGaming )
					P.DesiredFOV = P.DefaultSurroundFOV;
				else
					P.DesiredFOV = P.DefaultOriginalFOV;

				P.FOVAngle = P.DesiredFOV;
				P.DefaultFOV = P.DesiredFOV;
			}
			/*
			// teleporters affect your FOV, so adjust it back down
			if ( P.FOVAngle != P.DesiredFOV )
			{
				if ( !P.bSZoomStraight )
				{
					if ( P.FOVAngle > P.DesiredFOV )
						P.FOVAngle = P.FOVAngle - FMax(7, 0.9 * DeltaTime * (P.FOVAngle - P.DesiredFOV));
					else
						P.FOVAngle = P.FOVAngle - FMin(-7, 0.9 * DeltaTime * (P.FOVAngle - P.DesiredFOV));
					if ( Abs(P.FOVAngle - P.DesiredFOV) <= 10 )
						P.FOVAngle = P.DesiredFOV;
				}
				else
				{
					P.FOVAngle = P.DesiredFOV;
				}
			}*/

			//hide weapon when zoomed
			if (s_Weapon(s_BPlayer(PawnOwner).Weapon) != none)
			{
				if(s_BPlayer(PawnOwner).bSZoom)
					s_Weapon(s_BPlayer(PawnOwner).Weapon).bHideWeapon = true;
				else
					s_Weapon(s_BPlayer(PawnOwner).Weapon).bHideWeapon = false;
			}
		} else {
			if ( P.bSZoomStraight )
				P.FOVAngle = P.DefaultFOV;

			P.DesiredFOV = P.DefaultFOV;
			P.SZoomVal = 0.0;
			P.bSZoomStraight = false;
			P.bSZoom = false;
			P.Bob = P.OriginalBob;
		}


		if (bDrawHint)
		{
			if ( (Level.Netmode == NM_StandAlone) && bShowAlternativeHint)
			{
				Hint[0] = TextHintEndround;
			}
			else
			{
				Hint[0] = LiveFeed$PawnOwner.PlayerReplicationInfo.PlayerName;
			}

			TOHud_DrawHints(Canvas);
			TOHud_DrawSpectatedId(Canvas);
		}

		// time
//		TOHud_DrawRoundtime(Canvas);
		TOHud_DrawLeveltime(Canvas);
		return;
	}
	else if (PawnOwner.PlayerReplicationInfo.bIsSpectator)
	{
		TOHud_DrawHints(Canvas);

		// time
//		TOHud_DrawRoundtime(Canvas);
		TOHud_DrawLeveltime(Canvas);
		return;
	}

	//------------------
	//  more hud
	//------------------

	// time
//	TOHud_DrawRoundtime(Canvas);
	TOHud_DrawLeveltime(Canvas);

	// money
	TOHud_DrawMoney(Canvas);

	// armor & health
	TOHud_DrawStatus(Canvas);

	if (IsPlayerOwner())
	{
		// ammo
		TOHud_DrawAmmo(Canvas);

		if (!hideCrap)
		{
			// zones
			TOHud_DrawIcons(Canvas);

			// console timer
			if (bDrawCT)
			{
				TOHud_DrawConsoletimer(Canvas);
			}
		}
	}

	//------------------
	//  misc
	//------------------

	// hints
	TOHud_DrawHints(Canvas);
	TOHud_DrawSpecials(Canvas);

	// EMH {
	// Temporary variables displayed on the screen
	if (bSinglePlayer)
		s_SWATGame(Level.Game).DrawAdditionnalHudElements(Canvas, Design, self); 	// Primarily used to debug, can be used to display additionnal elements on the hdu

	// } EMH


    if ((PlayerOwner.PlayerReplicationInfo.bIsSpectator) || (PlayerOwner.PlayerReplicationInfo.bWaitingPlayer)) return;
	MyFlag=TFGameReplicationInfo(PlayerOwner.GameReplicationInfo).TheFlags[PlayerOwner.PlayerReplicationInfo.Team];
	OurFlag=TFGameReplicationInfo(PlayerOwner.GameReplicationInfo).TheFlags[1-PlayerOwner.PlayerReplicationInfo.Team];
	TFDrawCptGodMod(Canvas);
//	DrawFlagsIcons(Canvas);
}

/*simulated function DrawFlagsIcons(Canvas C)
{
    if (!TFGameReplicationInfo(PlayerOwner.GameReplicationInfo).TheFlags[0].IsFree)
    {
        C.SetPos(20,55);
    	C.Style=ERenderStyle.STY_Translucent;
        C.DrawIcon(Texture'TOCTFTex.Icons.redflag',2);
    }
    if (!TFGameReplicationInfo(PlayerOwner.GameReplicationInfo).TheFlags[1].IsFree)
    {
        C.SetPos(20,95);
    	C.Style=ERenderStyle.STY_Translucent;
        C.DrawIcon(Texture'TOCTFTex.Icons.blueflag',2);
    }
}*/

simulated function TFDrawCptGodMod(Canvas C)
{
    local byte cpt;

    cpt=TFPlayer(PlayerOwner).CptIAR;
    if (cpt==0) return;
    if (s_GameReplicationInfo(PlayerOwner.GameReplicationInfo).bPreRound) return;
	C.Style=ERenderStyle.STY_Normal;
    C.Font=MyFonts.GetHugeFont(C.ClipX);
    C.SetPos(40,C.ClipY/2);
    C.DrawColor=Design.ColorWhite;
    if (Cpt<=2) C.DrawColor=Design.ColorRed;
    C.DrawText(string(Cpt));
}

function Timer()
{
    local sound SoundCpt;
    local byte curcpt;

    super.Timer();

	if ((PlayerOwner==None) || (PawnOwner.PlayerReplicationInfo==None)) return;

    if (s_GameReplicationInfo(PlayerOwner.GameReplicationInfo).bPreRound) return;

	if (TFPlayerReplicationInfo(PawnOwner.PlayerReplicationInfo).bHasFlag)
		PlayerOwner.ReceiveLocalizedMessage(class'TFCTFMessageActualCarrier',0);

	if ((MyFlag!=None) && (!MyFlag.IsFree))
		PlayerOwner.ReceiveLocalizedMessage(class'TFCTFMessageActualCarrier',1);

	if ((OurFlag!=None) && (!OurFlag.IsFree) && (OurFlag.Carrier!=None) && (!TFPlayerReplicationInfo(PawnOwner.PlayerReplicationInfo).bHasFlag))
		PlayerOwner.ReceiveLocalizedMessage(class'TFCTFMessageActualCarrier',2);

    if (!TFPlayer(PlayerOwner).bPlayAnnouncer) return;
    curcpt=TFPlayer(PlayerOwner).CptIAR;
    if (curcpt==lastsay) curcpt--;
    if (curcpt>lastsay) return;
    if (curcpt>0)
    {
        switch (curcpt)
        {
            case 1:SoundCpt=Sound'Announcer.cd1';
                    lastsay=0;
                    break;
            case 2:SoundCpt=Sound'Announcer.cd2';
                    break;
            case 3:SoundCpt=Sound'Announcer.cd3';
                    break;
            case 4:SoundCpt=Sound'Announcer.cd4';
                    break;
            case 5:SoundCpt=Sound'Announcer.cd5';
                    break;
            default:break;
        }
        if (SoundCpt!=None)
        {
            lastsay=curcpt;
            PlayerOwner.ClientPlaySound(SoundCpt,false,true);
        }
    }
}

simulated function TOHud_DrawRoundtime(Canvas Canvas)
{
}

simulated final function bool TFHud_Tool_BeforePaint (Canvas Canvas)
{
	HUDSetup(Canvas);

	if ( (PawnOwner == None) || (PlayerOwner == None) || /*(s_Player(PlayerOwner) == None) ||*/ (PlayerOwner.PlayerReplicationInfo == None) || PawnOwner.PlayerReplicationInfo.bWaitingPlayer)
	{
		return false;
	}


	Canvas.bNoSmooth = true;

	// reset hints
	Hint[0] = "";
	Hint[1] = "";

	// do base initialization here coz fucking messy unreal script
	// obviously likes to insert random None's everywhere
	if ( (PlayerOwner.Player != None) && (PlayerOwner.Player.Console != None) )
	{
		if ( (Root == None) )
		{
			Root = WindowConsole(PlayerOwner.Player.Console).Root;
		}

		if ( (UserInterface == None) /*&& s_Player(PlayerOwner).bGUIActive*/ )
		{
			log("s_HUD::TOHud_Tool_BeforePaint - spawning UserInterface");
			UserInterface = PlayerOwner.Spawn(class'TFGUIBaseMgr', PlayerOwner);
			UserInterface.OwnerInit(self, Design);
		}
	}

	if ( (OldScreenResX != Canvas.ClipX) || (OldScreenResY != Canvas.ClipY) )
	{
		ResolutionChanged(Canvas.ClipX, Canvas.ClipY);
	}

	return true;
}

simulated function TOHud_DrawMoney (Canvas Canvas)
{
	local TO_GUIBaseTab				tab;
	local int						money, offset;


	if ( bHideHud /*|| (FrameTime >= 8)*/ )
	{
		return;
	}


	// background
	if ( bDrawBackground )
	{
		offset = 0 /*- FrameTime*18.875*/;

		Canvas.DrawColor = Design.ColorSuperwhite;
		Canvas.Style = ERenderStyle.STY_Translucent;
		Canvas.SetPos(offset, 31);
		Canvas.DrawTile(Texture'hud_elements2', 151, 18, 0, 180, 151.0, 18.0);

		Canvas.Style = ERenderStyle.STY_Masked;
		Canvas.SetPos(offset, 31);
		Canvas.DrawTile(Texture'hud_elements2', 151, 18, 0, 162, 151.0, 18.0);
	}

/*	if (FrameTime > 0)
	{
		return;
	}*/


	// amount
	Canvas.SetPos(16, 39);

	if ( (MoneyDrawTime > 0) && (int(MoneyDrawTime*100)%50 < 25) )
	{
		if ( MoneyVariationAmount > 0 )
			Canvas.DrawColor = Design.ColorGreen;
		else
			Canvas.DrawColor = Design.ColorRed;
		TOHud_Tool_DrawDigit(Canvas, 12, FS_SMALL, 1);
		TOHud_Tool_DrawNumR(Canvas, MoneyVariationAmount, FS_SMALL, 5);
	}
	else
	{
		money = s_Player(PlayerOwner).Money;
		Canvas.DrawColor = Design.ColorSuperwhite;
		TOHud_Tool_DrawDigit(Canvas, 12, FS_SMALL, 1);
		TOHud_Tool_DrawNumR(Canvas, money, FS_SMALL, 5);
	}
}

defaultproperties
{
}

