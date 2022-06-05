class TOMAHud extends s_HUD;

var float RadarPulse,RadarScale;
var config float RadarPosX,RadarPosY;
var float LastDrawRadar;
var bool bDisplayTOMAVote;

#EXEC OBJ LOAD name=TOMATex FILE=../Textures/TOMATex21.utx PACKAGE=TOMATex21

simulated function PostRender(Canvas Canvas)
{
	local bool hideCrap;
	local s_GameReplicationInfo GRI;
	local s_Player P;

	if ((PlayerOwner!=None) && (PlayerOwner.Player!=None) && (PlayerOwner.Player.Console!=None))
	{
		if (Root==None)
			Root=WindowConsole(PlayerOwner.Player.Console).Root;
		if (UserInterface==None)
		{
			Log("TOMAHUD::TOMATOHud_Tool_BeforePaint - spawning UserInterface");
			UserInterface=PlayerOwner.Spawn(Class'TOMATab',PlayerOwner);
			UserInterface.OwnerInit(self,Design);
		}
	}

	if ( !TOHud_Tool_BeforePaint(Canvas) )
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

	if ((PlayerOwner!=None) && (TOMAPlayer(PlayerOwner)!=None))
	{
        if (TOMAPlayer(PlayerOwner).bDrawRadar) DrawBackRadar(Canvas);
        if (TOMAPlayer(PlayerOwner).bDrawRadar) DrawRadar(Canvas);
        if (TOMAPlayer(PlayerOwner).WBR>0) DrawWaitCount(Canvas);
        if (TOMAPlayer(PlayerOwner).CptIAR>0) TOMADrawCptGodMod(Canvas);
        if (TOMAGameReplicationInfo(PlayerOwner.GameReplicationInfo)!=None)
        {
            if (TOMAPlayer(PlayerOwner).centerhud)
                Drawcenter(Canvas);
            if (TOMAPlayer(PlayerOwner).countershud)
            {
                DrawMonstersInMap(Canvas);
                DrawMonstersToKill(Canvas);
            }
            if (TOMAGameReplicationInfo(PlayerOwner.GameReplicationInfo).bEnableMagic) DrawMyMana(Canvas);
        }
    }

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
		if ((PawnOwner==PlayerOwner) || (PlayerOwner.IsA('s_Player') && P.bShowDebug && !PlayerOwner.bShowScores))
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
	   if (bDisplayTOMAVote)
	   {
	       UserInterface.SelectTab(16);
	       bDisplayTOMAVote=false;
	   }
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
		TOHud_DrawRoundtime(Canvas);
		TOHud_DrawLeveltime(Canvas);
		return;
	}
	else if (PawnOwner.PlayerReplicationInfo.bIsSpectator)
	{
		TOHud_DrawHints(Canvas);

		// time
		TOHud_DrawRoundtime(Canvas);
		TOHud_DrawLeveltime(Canvas);
		return;
	}

	//------------------
	//  more hud
	//------------------

	// time
	TOHud_DrawRoundtime(Canvas);
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
}

simulated function TOMADrawCptGodMod(Canvas C)
{
    local byte cpt;

    cpt=TOMAPlayer(PlayerOwner).CptIAR;
    if (cpt==0) return;
    if (s_GameReplicationInfo(PlayerOwner.GameReplicationInfo).bPreRound) return;
	C.Style=ERenderStyle.STY_Normal;
    C.Font=MyFonts.GetHugeFont(C.ClipX);
    C.SetPos(40,C.ClipY/2);
    C.DrawColor=Design.ColorWhite;
    if (Cpt<=2) C.DrawColor=Design.ColorRed;
    C.DrawText(string(Cpt));
}

simulated function DrawWaitCount(Canvas C)
{
    local byte cpt;

    cpt=TOMAPlayer(PlayerOwner).WBR;
    if (cpt==0) return;
	C.Style=ERenderStyle.STY_Normal;
    C.Font=MyFonts.GetHugeFont(C.ClipX);
    C.SetPos(40,C.ClipY/2);
    C.DrawColor=Design.ColorWhite;
    if (Cpt<=2) C.DrawColor=Design.ColorRed;
    C.DrawText(string(Cpt));
}

simulated function DrawRadar(Canvas C)
{
    local Pawn P;
    local float dist,maxdist,RadarWidth,PulseBrightness,Angle,DotSize,OffsetY,OffsetScale;
    local vector start;
	local rotator Dir;

    if ((TOMAGameReplicationInfo(PlayerOwner.GameReplicationInfo)!=None) && (!TOMAGameReplicationInfo(PlayerOwner.GameReplicationInfo).bAllowRadar)) return;

    if ((PlayerOwner.Health<=0) || (PlayerOwner.IsInState('PlayerWaiting'))) return;

	LastDrawRadar=Level.TimeSeconds;
	RadarWidth=0.5*RadarScale*C.ClipX;
	DotSize=24*C.ClipX*HUDScale/1600;
	if (PawnOwner==None)
		Start=PlayerOwner.Location;
	else
		Start=PawnOwner.Location;

	MaxDist=3000*RadarPulse;
	C.Style=ERenderStyle.STY_Translucent;
	OffsetY=RadarPosY+RadarWidth/C.ClipY;

	foreach AllActors(class'Pawn',P)
		if (P.Health>0)
		{
		    if (P!=PlayerOwner)
		    {
			Dist=VSize(Start-P.Location);
			if (Dist<3000)
			{
				if (Dist<MaxDist)
					PulseBrightness=255-255*Abs(Dist*0.00033-RadarPulse);
				else
					PulseBrightness=255-255*Abs(Dist*0.00033-RadarPulse-1);
				if (TOMAScriptedPawn(P)!=None)
				{
					C.DrawColor.R=PulseBrightness;
					C.DrawColor.G=0;
					C.DrawColor.B=0;
				}
				else
				{
				    if (s_NPCHostage(P)!=None)
				    {
    					C.DrawColor.R=PulseBrightness;
	   	       			C.DrawColor.G=PulseBrightness;
	       				C.DrawColor.B=0;
	       			}
                    else
				    {
    					C.DrawColor.R=0;
	   	       			C.DrawColor.G=0;
	       				C.DrawColor.B=PulseBrightness;
	       			}
				}
				Dir=rotator(P.Location-Start);
				OffsetScale=RadarScale*Dist*0.000167;
				Angle=((Dir.Yaw-PlayerOwner.Rotation.Yaw) & 65535)*6.2832/65536;
				if ((Angle>=4.8) || (Angle<=1.3))
				{
    				C.SetPos(RadarPosX*C.ClipX+OffsetScale*C.ClipX*sin(Angle)-0.5*DotSize,
	   				OffsetY*C.ClipY-OffsetScale*C.ClipY*cos(Angle)-0.5*DotSize);
				    C.DrawTile(texture'TOMATex21.Radar.HudSkinAB',DotSize,DotSize,0,0,144,144);
				}
			}
			}
		}
}

simulated function bool TOHud_DrawIdentification(Canvas Canvas)
{
	local float XL;
	local float YL;
	local Actor A;
	local string Id;

	if (bHideHUD)
		return false;
	if (TraceIdentify(Canvas))
	{
		TOHud_Tool_SetTextstyle(Canvas);
		if (IdentifyTarget!=None)
			if (IdentifyTarget.PlayerName!="")
			{
				Id=IdentifyTarget.PlayerName;
				Id=Id $ " - " $ string(Max(0,Pawn(IdentifyTarget.Owner).Health));
				Canvas.Font=MyFonts.GetBigFont(Canvas.ClipX);
				Canvas.StrLen(Id,XL,YL);
				TOHud_SetTeamColor(Canvas,IdentifyTarget.Team);
				Canvas.SetPos((Canvas.ClipX-XL)*0.5,0.75*Canvas.ClipY);
				Canvas.DrawText(Id);
			}
	}
	return true;
}

simulated function bool TraceIdentify(Canvas Canvas)
{
	local Actor Other;
	local Vector HitLocation;
	local Vector HitNormal;
	local Vector StartTrace;
	local Vector EndTrace;
	local float MaxRange;

	if ((PawnOwner.Weapon!=None) && PawnOwner.Weapon.IsA('S_Weapon'))
	{
		MaxRange=S_Weapon(PawnOwner.Weapon).MaxRange;
		if (MaxRange<1000)
			MaxRange=1000;
	}
	else
		MaxRange=1000;
	StartTrace=PawnOwner.Location;
	StartTrace.Z+=PawnOwner.BaseEyeHeight;
	EndTrace=StartTrace+vector(PawnOwner.ViewRotation)*MaxRange;
	Other=Trace(HitLocation,HitNormal,EndTrace,StartTrace,True);
	if (Other==None)
	{
		IdentifyTarget=None;
		return False;
	} else
	{
		if (Other.IsA('TOMAScriptedPawn'))
		{
			IdentifyTarget=TOMAScriptedPawn(Other).PlayerReplicationInfo;
			return True;
		} else return Super.TraceIdentify(Canvas);
	}
}

simulated function TOHud_DrawRoundtime (Canvas Canvas)
{
	if (TOMAGameReplicationInfo(PlayerOwner.GameReplicationInfo).bInfiniteTime) return;

    Super.TOHud_DrawRoundtime(Canvas);
}

simulated function TOHud_DrawLeveltime (Canvas Canvas)
{
	local s_GameReplicationInfo GRI;
	local int time;

	if ((bHideHud) || (!bDrawTime))
		return;

	if (TOMAGameReplicationInfo(PlayerOwner.GameReplicationInfo).bInfiniteTime) return;

	if (bDrawBackground)
	{
		Canvas.DrawColor=Design.ColorSuperwhite;
		Canvas.Style=ERenderStyle.STY_Translucent;
		Canvas.SetPos(Canvas.ClipX-127,7);
		Canvas.DrawTile(Texture'hud_elements',127,18,79,52,127,18);

		Canvas.Style=ERenderStyle.STY_Masked;
		Canvas.SetPos(Canvas.ClipX-127,7);
		Canvas.DrawTile(Texture'hud_elements',127,18,79,70,127,18);
	}

	if (bSinglePlayer)
		time=s_SWATGame(Level.Game).GetSPBestCurrentTime();
	else
	{
		GRI=s_GameReplicationInfo(PlayerOwner.GameReplicationInfo);
		if (GRI!=None)
			time=GRI.Remainingtime;
		else
			time=0;
	}

	Canvas.DrawColor=Design.ColorSuperwhite;
	Canvas.SetPos(Canvas.ClipX-88,15);
	TOHud_Tool_DrawTime(Canvas,time,2);
}

simulated function DrawBackRadar(Canvas C)
{
	local float RadarWidth, PulseWidth, PulseBrightness;

    if ((TOMAGameReplicationInfo(PlayerOwner.GameReplicationInfo)!=None) && (!TOMAGameReplicationInfo(PlayerOwner.GameReplicationInfo).bAllowRadar)) return;

    if ((PlayerOwner.Health<=0) || (PlayerOwner.IsInState('PlayerWaiting'))) return;

	RadarScale=Default.RadarScale*HUDScale;
	RadarWidth=0.5*RadarScale*C.ClipX;
	PulseWidth=RadarScale*C.ClipX;
	C.DrawColor=WhiteColor;
	C.Style=ERenderStyle.STY_Translucent;

	PulseBrightness=FMax(0,(1-2*RadarPulse)*255.0);
/*	C.DrawColor.R=PulseBrightness;
	C.DrawColor.G=PulseBrightness;
	C.DrawColor.B=PulseBrightness;
	C.SetPos(RadarPosX*C.ClipX-0.5*PulseWidth,RadarPosY*C.ClipY+RadarWidth-0.5*PulseWidth);
	C.DrawTile(texture'TOMATex21.Radar.HudSkinA',PulseWidth,PulseWidth,0,0,162,157);*/

	PulseWidth=RadarPulse*RadarScale*C.ClipX;
	C.DrawColor=WhiteColor;
	C.SetPos(RadarPosX*C.ClipX-0.5*PulseWidth,RadarPosY*C.ClipY+RadarWidth-0.5*PulseWidth);
	C.DrawTile(texture'TOMATex21.Radar.HudSkinA',PulseWidth,PulseWidth,0,0,162,157);

	C.DrawColor=WhiteColor;
//	C.SetPos(RadarPosX*C.ClipX-RadarWidth,RadarPosY*C.ClipY+RadarWidth);
//	C.DrawTile(texture'TOMATex21.Radar.AlienRadar',RadarWidth,RadarWidth,0,255,255,-255);
//	C.SetPos(RadarPosX*C.ClipX,RadarPosY*C.ClipY+RadarWidth);
//	C.DrawTile(texture'TOMATex21.Radar.AlienRadar',RadarWidth,RadarWidth,255,255,-255,-255);
	C.SetPos(RadarPosX*C.ClipX-RadarWidth,RadarPosY*C.ClipY);
	C.DrawTile(texture'TOMATex21.Radar.AlienRadar',RadarWidth,RadarWidth,0,0,255,255);
	C.SetPos(RadarPosX*C.ClipX,RadarPosY*C.ClipY);
	C.DrawTile(Texture'TOMATex21.Radar.AlienRadar',RadarWidth,RadarWidth,255,0,-255,255);
	if ((PulseWidth<2) && (TOMAPlayer(PlayerOwner).bPlayRadarSound)) s_Player(PlayerOwner).ClientPlaySound(Sound'TOMASounds21.Others.RadarPulseSound',,true);
}

simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);
	RadarPulse=RadarPulse+0.5*DeltaTime;
	if (RadarPulse>=1)
		RadarPulse=RadarPulse-1;
}

simulated function TOHud_DrawTeaminfo (Canvas Canvas)
{
	local Pawn					p;
	local int					xpos, ypos, xinfo;
	local float					xl, yl;
	local Vector				odir, oloc, pdir;
	local Vector				x, y, z;


	Canvas.Style = ERenderStyle.STY_Translucent;
	Canvas.Font = MyFonts.GetSmallFont(Canvas.ClipX);

	oloc = PlayerOwner.Location;
	oloc.Z += PlayerOwner.BaseEyeHeight;
	PlayerOwner.GetAxes(PlayerOwner.ViewRotation, x, y, z);

	foreach visiblecollidingactors(class'Pawn', P, 2000, oloc, true)
	{
		if ( (P.PlayerReplicationInfo==None) || (p.PlayerReplicationInfo.Team != PlayerOwner.PlayerReplicationInfo.Team) || (p == PlayerOwner) )
		{
			continue;
		}

		pdir = p.Location - oloc;
		pdir.Z -= 40;
		pdir = pdir/VSize(pdir);

		if ( (pdir Dot x) < 0.7 )
		{
			continue;
		}

		xpos = 0.5 * Canvas.ClipX * (1 + 1.4 * (pdir Dot y));
		ypos = 0.5 * Canvas.ClipY * (1 - 1.4 * (pdir Dot z));

		if ( (xpos < 16) || (xpos > Canvas.ClipX-16) || (ypos < 16) || (ypos > Canvas.ClipY-16) )
		{
			continue;
		}

		TOHud_Tool_SetPercentColor(Canvas, p.Health);

		// icon
		if (xpos > (Canvas.ClipX * 0.5) )
		{
			Canvas.SetPos(xpos - 32, ypos - 8);
			Canvas.DrawTile(texture'hud_elements', 40, 32, 111, 184, 40.0, 32.0);

			if ( (FrameTeaminfo & 1) == 0)
			{
				Canvas.StrLen(p.PlayerReplicationInfo.PlayerName, xl, yl);
				xinfo = xpos - xl - 41;
			}
			else if (p.Health > 99)
			{
				xinfo = xpos - 86;
			}
			else
			{
				xinfo = xpos - 69;
			}
		}
		else
		{
			Canvas.SetPos(xpos - 8, ypos - 8);
			Canvas.DrawTile(texture'hud_elements', 50, 36, 152, 184, -44.0, 36.0);
			xinfo = Canvas.CurX + 6;
		}

		// name & health
		Canvas.SetPos(xinfo, ypos + 16);
		if ( (FrameTeaminfo & 1) == 0 )
		{
			Canvas.DrawText(p.PlayerReplicationInfo.PlayerName, true);
		}
		else if (p.Health > 99)
		{
			TOHud_Tool_DrawNum(Canvas, p.Health, FS_SMALL, 3);
		}
		else
		{
			TOHud_Tool_DrawNum(Canvas, p.Health, FS_SMALL, 2);
		}
	}
}

simulated function TOHud_DrawMoney (Canvas Canvas)
{
	local TO_GUIBaseTab				tab;
	local int						money, offset;

    if ((TOMAGameReplicationInfo(PlayerOwner.GameReplicationInfo)!=None) && (!TOMAGameReplicationInfo(PlayerOwner.GameReplicationInfo).bFixBuyZone))
    {

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

	} else super.TOHud_DrawMoney(Canvas);
}

function DrawCenter(Canvas Canvas)
{
	local string text;
	local float X,Y;

	text=class'TOMAMod'.default.CurrentLevelText$" : " $ string(TOMAGameReplicationInfo(PlayerOwner.GameReplicationInfo).numlevel) $ " "$class'TOMAMod'.default.namedtext$" : " $ right(TOMAGameReplicationInfo(PlayerOwner.GameReplicationInfo).nameofmonster,len(TOMAGameReplicationInfo(PlayerOwner.GameReplicationInfo).nameofmonster)-11);
	text=text$", "$class'TOMAMod'.default.Monstersinmaptext$" : " $ string(TOMAGameReplicationInfo(PlayerOwner.GameReplicationInfo).nbmonstersinmap);
	text=text$", "$class'TOMAMod'.default.Monsterstokilltext$" : " $ string(TOMAGameReplicationInfo(PlayerOwner.GameReplicationInfo).nbmonsterstokill);
	Canvas.Font=Font(DynamicLoadObject("LadderFonts.UTLadder16",Class'Font'));
	Canvas.TextSize(text,X,Y);
	Canvas.SetPos((Canvas.ClipX/2)-(X/2),50);
	Canvas.DrawColor.R=255;
	Canvas.DrawColor.G=255;
	Canvas.DrawColor.B=255;
	Canvas.DrawText(".:"$text$":.");
}

simulated function DrawMonstersInMap(Canvas C)
{
	if ((bHideHUD) || (bHideStatus)) return;
	C.DrawColor=Design.ColorSuperwhite;
	C.Style=3;
	if (bDrawBackground)
	{
		C.SetPos(C.ClipX-79,C.ClipY-169);
		C.DrawTile(Texture'hud_elements',79,18,0,52,79,18);
		C.Style=2;
		C.SetPos(C.ClipX-79,C.ClipY-169);
		C.DrawTile(Texture'hud_elements',79,18,0,70,79,18);
	}
	TOHud_SetTeamColor(C,3);
	C.SetPos(C.ClipX-59,C.ClipY-169);
	TOHud_Tool_DrawNum(C,TOMAGameReplicationInfo(PlayerOwner.GameReplicationInfo).nbmonstersinmap,FS_SMALL,3);
}

simulated function DrawMonstersToKill(Canvas C)
{
	if ((bHideHUD) || (bHideStatus)) return;
	C.DrawColor=Design.ColorSuperwhite;
	C.Style=3;
	if (bDrawBackground)
	{
		C.SetPos(C.ClipX-79,C.ClipY-145);
		C.DrawTile(Texture'hud_elements',79,18,0,52,79,18);
		C.Style=2;
		C.SetPos(C.ClipX-79,C.ClipY-145);
		C.DrawTile(Texture'hud_elements',79,18,0,70,79,18);
	}
	TOHud_SetTeamColor(C,0);
	C.SetPos(C.ClipX-59,C.ClipY-145);
	TOHud_Tool_DrawNum(C,TOMAGameReplicationInfo(PlayerOwner.GameReplicationInfo).nbmonsterstokill,FS_SMALL,3);
}

simulated function DrawMyMana(Canvas C)
{
	if ((bHideHUD) || (bHideStatus)) return;
	C.DrawColor=Design.ColorSuperwhite;
	C.Style=3;
	if (bDrawBackground)
	{
		C.SetPos(C.ClipX-79,C.ClipY-217);
		C.DrawTile(Texture'hud_elements',79,18,0,52,79,18);
		C.Style=2;
		C.SetPos(C.ClipX-79,C.ClipY-217);
		C.DrawTile(Texture'hud_elements',79,18,0,70,79,18);
	}
	C.DrawColor=Design.ColorBlue;
	C.SetPos(C.ClipX-59,C.ClipY-217);
	TOHud_Tool_DrawNum(C,TOMAPlayer(PlayerOwner).Mana,FS_SMALL,3);
}

defaultproperties
{
	RadarScale=0.2
	RadarPosX=0.5
	RadarPosY=0.8
}

