class TMHUD extends s_HUD;

var byte lastsay;

simulated function PostRender (canvas Canvas)
{
	local bool hideCrap;
	local s_GameReplicationInfo GRI;
	local s_Player P;

	if (!TMTool_BeforePaint(Canvas))
	{
		if (UserInterface!=None)
			UserInterface.Hide();

		return;
	}

	P=s_Player(PlayerOwner);

	if (P!=None)
	{
		if (((bNVActive) && (!P.zzbNightVision)) || ((!P.bHasNV) && (P.zzbNightVision)))
        {
            bNVActive=false;
            P.zzbNightVision=false;
            NVLight.Destroy();
        }

		if ((P.zzbNightVision) && (!PlayerOwner.bShowScores) && (P.bHasNV))
		{
			TOHud_DrawNightvision(Canvas,P.bHUDModFix);
		}

	}

	TOHud_DrawBlinded(Canvas);

	if (P!=None)
	{
		if (PlayerOwner.IsInState('PlayerSpectating') && bDrawWidescreen)
		{
			TOHud_DrawWidescreen(Canvas,P.bHUDModFix);
		}

		if (P.RendMap!=5)
		{
			P.RendMap=5;
		}

		Canvas.Style=Style;

		if ((P.bActionWindow) && (s_Player(PlayerOwner)!=None) && (!s_Player(PlayerOwner).bHUDModFix))
		{
			TOHud_DarkenScreen(Canvas);
		}
	}

	if ((P!=None) && (P.bMenuVisible))
		return;

	if ((PlayerOwner.IsA('TO_Spectator')) && (TO_Spectator(PlayerOwner).bMenuVisible))
		return;

	if (UserInterface!=None)
		hideCrap=UserInterface.Visible();
	else
		hideCrap=false;

	if (!hideCrap)
	{
		/*if ((!PlayerOwner.PlayerReplicationInfo.bIsSpectator) && (FrameTeaminfo!=255) && (PlayerOwner.DesiredFOV==PlayerOwner.DefaultFOV))
		{
			TOHud_DrawTeaminfo(Canvas);
		}
		else */ if ((PawnOwner==PlayerOwner) || (PlayerOwner.IsA('s_Player') && (P.bShowDebug) && (!PlayerOwner.bShowScores)))
		{
			TOHud_DrawIdentification(Canvas);
		}

		if ((!PlayerOwner.bBehindView) && (PawnOwner.Weapon!=None) && (Level.LevelAction==LEVACT_None))
		{
			if (!hideCrap)
			{
				TOHud_DrawCrosshair(Canvas,0,0);
			}
			TOHud_DrawHitlocation(Canvas);
		}
		else
		{
			TOHud_Tool_ClearHitlocation();
		}
	}

	TOHud_DrawDeathmessage(Canvas);

	TOHud_DrawShortmessages(Canvas);

	if (hideCrap)
	{
		TOHud_DarkenScreen(Canvas);
	}

	if (UserInterface!=None)
	{
		if (bForceBriefing)
		{
			UserInterface.SelectTab(UserInterface.UIT_BRIEFING);
			bForceBriefing=false;
		}
		else if ((IsPreRound()) && (!bPreroundShown))
		{
			UserInterface.SelectTab(UserInterface.UIT_BRIEFING);
			bPreroundHidden=false;
			bPreroundShown=true;
		}
		else if (bToggleBriefing)
		{
			UserInterface.ToggleTab(UserInterface.UIT_BRIEFING);
			bPreroundHidden=true;
			bToggleBriefing=false;
		}
		else if (bToggleBuymenu)
		{
			UserInterface.ToggleTab(UserInterface.UIT_BUYMENU);
			bToggleBuymenu=false;
		}
		else if (bShowInfo)
		{
			UserInterface.ToggleTab(UserInterface.UIT_SERVER);
			bShowInfo=false;
		}
		else if (bToggleCredits)
		{
			UserInterface.ToggleTab(UserInterface.UIT_CREDITS);
			bToggleCredits=false;
		}

		if ((!bPreroundHidden) && (!IsPreRound()))
		{
			UserInterface.HideTab(UserInterface.UIT_BRIEFING);
			bPreroundHidden=true;
		}

		if (PawnOwner.Health<=0)
		{
			UserInterface.HideTab(UserInterface.UIT_BUYMENU);
		}
	}

	if (UserInterface!=None)
	{
		if (bSinglePlayer && bForceScores)
        {
			UserInterface.SelectTab(UserInterface.UIT_DEBRIEFING);
		}
		else if (bForceScores)
		{
			UserInterface.SelectTab(UserInterface.UIT_SCORES);
		}
		else if (PlayerOwner.bShowScores)
		{
			UserInterface.ToggleTab(UserInterface.UIT_SCORES);
			PlayerOwner.bShowScores=false;
		}
	}

	if (HUDMutator!=None)
	{
		HUDMutator.PostRender(Canvas);
	}

	if (UserInterface!=None)
		UserInterface.Render(Canvas);

	if (PlayerOwner.Player.Console.bTyping)
	{
		TOHud_DrawTypingPrompt(Canvas,PlayerOwner.Player.Console);
	}

	if (MOTDFadeOutTime>0.0)
	{
		DrawMOTD(Canvas);
	}

	if ((bStartUpMessage) && (Level.TimeSeconds<5))
	{
		bStartUpMessage=false;
		PlayerOwner.SetProgressTime(7);
	}

	if (!bHideCenterMessages)
	{
		TOHud_DrawCentermessages(Canvas);
		if (PlayerOwner.ProgressTimeOut>Level.TimeSeconds)
		{
			DisplayProgressMessage(Canvas);
		}
	}

	if (PlayerOwner.GameReplicationInfo!=None)
	{
		if (PlayerPawn(Owner).GameReplicationInfo.RemainingTime==0)
		{
			if (bDisplayMapChangeMessage)
			{
				PlayerOwner.ReceiveLocalizedMessage(class's_MessageRoundWinner',8);
				bDisplayMapChangeMessage=false;
			}
		}
		else if (!bDisplayMapChangeMessage)
		{
			bDisplayMapChangeMessage=true;
		}
	}

	if ((P!=None) && (P.bShowDebug) && (!PlayerOwner.bShowScores))
	{
		ShowDebug(Canvas);
	}

	if ((PawnOwner!=Owner) && (PawnOwner.bIsPlayer) && (P!=none))
	{
		if (!P.bBehindView && s_BPlayer(PawnOwner) != none)
		{
			P.bSZoom=s_BPlayer(PawnOwner).bSZoom;
			P.SZoomVal=s_BPlayer(PawnOwner).SZoomVal;
			if (P.bSZoom)
			{
				if (P.bSurroundGaming)
				{
					if (P.SZoomVal==0.5)
						P.DesiredFOV=P.DefaultSurroundZoomLvl1;
					else if (P.SZoomVal==0.85)
						P.DesiredFOV=P.DefaultSurroundZoomLvl2;
					else
						P.DesiredFOV=P.DefaultSurroundFOV;

					if (P.DefaultFOV!=P.DefaultSurroundFOV)
						P.DefaultFOV=P.DefaultSurroundFOV;
				}
				else
				{
					if (P.SZoomVal==0.5)
						P.DesiredFOV=P.DefaultZoomLvl1;
					else if (P.SZoomVal==0.85)
						P.DesiredFOV=P.DefaultZoomLvl2;
					else
						P.DesiredFOV=P.DefaultOriginalFOV;

					if (P.DefaultFOV!=P.DefaultOriginalFOV)
						P.DefaultFOV=P.DefaultOriginalFOV;
				}
			}
			else
			{
				if (P.bSurroundGaming)
					P.DesiredFOV=P.DefaultSurroundFOV;
				else
					P.DesiredFOV=P.DefaultOriginalFOV;

				P.FOVAngle=P.DesiredFOV;
				P.DefaultFOV=P.DesiredFOV;
			}

			if (s_Weapon(s_BPlayer(PawnOwner).Weapon)!=none)
			{
				if(s_BPlayer(PawnOwner).bSZoom)
					s_Weapon(s_BPlayer(PawnOwner).Weapon).bHideWeapon=true;
				else
					s_Weapon(s_BPlayer(PawnOwner).Weapon).bHideWeapon=false;
			}
		} else {
			if (P.bSZoomStraight)
				P.FOVAngle=P.DefaultFOV;

			P.DesiredFOV=P.DefaultFOV;
			P.SZoomVal=0.0;
			P.bSZoomStraight=false;
			P.bSZoom=false;
			P.Bob=P.OriginalBob;
		}

		if (bDrawHint)
		{
			if ((Level.Netmode==NM_StandAlone) && (bShowAlternativeHint))
			{
				Hint[0]=TextHintEndround;
			}
			else
			{
				Hint[0]=LiveFeed$PawnOwner.PlayerReplicationInfo.PlayerName;
			}

			TOHud_DrawHints(Canvas);
			TOHud_DrawSpectatedId(Canvas);
		}

		TOHud_DrawRoundtime(Canvas);
		TOHud_DrawLeveltime(Canvas);
		return;
	}
	else if (PawnOwner.PlayerReplicationInfo.bIsSpectator)
	{
		TOHud_DrawHints(Canvas);

		TOHud_DrawRoundtime(Canvas);
		TOHud_DrawLeveltime(Canvas);
		return;
	}

	TOHud_DrawRoundtime(Canvas);
	TOHud_DrawLeveltime(Canvas);

	TOHud_DrawMoney(Canvas);

	TOHud_DrawStatus(Canvas);

	if (IsPlayerOwner())
	{
		TOHud_DrawAmmo(Canvas);

		if (!hideCrap)
		{
			TOHud_DrawIcons(Canvas);

			if (bDrawCT)
			{
				TOHud_DrawConsoletimer(Canvas);
			}
		}
	}

	TOHud_DrawHints(Canvas);
	TOHud_DrawSpecials(Canvas);

	if (bSinglePlayer)
		s_SWATGame(Level.Game).DrawAdditionnalHudElements(Canvas,Design,self);
	TMDrawCptGodMod(Canvas);
}

simulated function TMDrawCptGodMod(Canvas C)
{
    local byte cpt;

    cpt=TMPlayer(PlayerOwner).CptIAR;
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
    if (!TMPlayer(PlayerOwner).bPlayAnnouncer) return;
    if (s_GameReplicationInfo(PlayerOwner.GameReplicationInfo).bPreRound) return;
    curcpt=TMPlayer(PlayerOwner).CptIAR;
    if (curcpt==lastsay) curcpt--;
    if (curcpt>lastsay) return;
    if (curcpt>0)
    {
        switch (TMPlayer(PlayerOwner).CptIAR)
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
            TMPlayer(PlayerOwner).ClientPlaySound(SoundCpt,,true);
        }
    }
}

simulated final function bool TMTool_BeforePaint(Canvas Canvas)
{
	HUDSetup(Canvas);

	if ((PawnOwner==None) || (PlayerOwner==None) || (PlayerOwner.PlayerReplicationInfo==None) || (PawnOwner.PlayerReplicationInfo.bWaitingPlayer))
		return false;

	Canvas.bNoSmooth=true;

	Hint[0]="";
	Hint[1]="";

	if ((PlayerOwner.Player!=None) && (PlayerOwner.Player.Console!=None))
	{
		if ((Root==None))
			Root=WindowConsole(PlayerOwner.Player.Console).Root;

		if (UserInterface==None)
		{
			log("s_HUD::TOHud_Tool_BeforePaint - spawning UserInterface");
			UserInterface=PlayerOwner.Spawn(class'TMGUIBaseMgr',PlayerOwner);
			UserInterface.OwnerInit(self,Design);
		}
	}

	if ((OldScreenResX!=Canvas.ClipX) || (OldScreenResY!=Canvas.ClipY))
		ResolutionChanged(Canvas.ClipX, Canvas.ClipY);

	return true;
}

simulated function TOHud_DrawRoundtime (Canvas Canvas)
{
}

final simulated function TMAdd_Death_Message(PlayerReplicationInfo KillerPRI, PlayerReplicationInfo VictimPRI)
{
	local s_DeathMessages message;
	local string clientmsg;

	if (VictimPRI==None)
		return;

	if (s_DeathM_idx>5)
		Shift_Death_Message();

	if ((KillerPRI!=None) && (KillerPRI.Team<2))
	{
		message.Killer=KillerPRI.PlayerName;
		if (KillerPRI==PlayerOwner.PlayerReplicationInfo) message.KillerC=Design.ColorGreen; else message.KillerC=Design.ColorGrey;
	}
	else
		message.Killer="";

	if (VictimPRI.Team<2)
	{
		message.Victim=VictimPRI.PlayerName;
		if (VictimPRI==PlayerOwner.PlayerReplicationInfo) message.VictimC=Design.ColorGreen; else message.VictimC=Design.ColorGrey;
	}
	else
		message.Victim="";

	if (KillerPRI!=None)
		clientmsg=KillerPRI.PlayerName@LS_Killed@VictimPRI.PlayerName;
	else
		clientmsg = VictimPRI.PlayerName@LS_Died;

	if ((PlayerOwner!=None) && (PlayerOwner.PlayerReplicationInfo!=None) && (PlayerOwner.Player!=none) && (PlayerOwner.Player.Console!=None))
		PlayerOwner.Player.Console.Message(PlayerOwner.PlayerReplicationInfo,clientmsg,'');

	s_DeathM[s_DeathM_idx]=message;
	s_DeathM[s_DeathM_idx].EndOfLife=10;

	s_DeathM_idx++;
}

simulated function TOHud_DrawShortmessages (Canvas Canvas)
{
	local float oldclipx, oldclipy;
	local int i, j, k, lines;
	local float XL, YL;

	if (bHideHud || !bDrawText || !bDrawChat)
	{
		return;
	}

	// backup data
	oldclipx=Canvas.ClipX;
	oldclipy=Canvas.ClipY;

	// init
	Design.SetSmallFont(Canvas);
	TOHud_Tool_SetTextstyle(Canvas);
	Canvas.SetClip(Canvas.ClipX-160,Canvas.ClipY);
	bDrawFaceArea=False;
	lines=0;

	// print messages
	for (i=0;i<6;i++)
	{
		if (ShortMessageQueue[i].Message==None)
		{
			continue;
		}

		j++;
		if ((bResChanged) || (ShortMessageQueue[i].XL==0))
		{
			// updated message dimensions
			if ( ShortMessageQueue[i].Message.Default.bComplexString )
			{
				Canvas.StrLen
				(
					ShortMessageQueue[i].Message.Static.AssembleString
					(
						self,
						ShortMessageQueue[i].Switch,
						ShortMessageQueue[i].RelatedPRI,
						ShortMessageQueue[i].StringMessage
					),
					ShortMessageQueue[i].XL,
					ShortMessageQueue[i].YL
				);
			}
			else
			{
				Canvas.StrLen(ShortMessageQueue[i].StringMessage,ShortMessageQueue[i].XL,ShortMessageQueue[i].YL);
			}

			// calculate number oflines
			ShortMessageQueue[i].numLines=1;
			if ( ShortMessageQueue[i].YL>1.5*Design.LineHeight)
			{
				ShortMessageQueue[i].numLines++;
				for (k=2;k<6-i;k++)
				{
					if (ShortMessageQueue[i].YL>1.5*k*Design.LineHeight)
					{
						ShortMessageQueue[i].numLines++;
					}
				}
			}
		}

		// Keep track of the amount of lines a message overflows, to offset the next message with.
		Canvas.SetPos(16, YOffsetMsgs + lines*Design.LineHeight);
		lines+=ShortMessageQueue[i].numLines;
		if (lines>6)
		{
			break;
		}

		// colored srings
		if (ShortMessageQueue[i].Message.Default.bComplexString)
		{
			//TOHud_Tool_DrawComplexMessage(Canvas,ShortMessageQueue[i]);
	        Canvas.StrLen("TEST",XL,YL);

			// Use this for string messages with multiple colors.
			class'TMSayMessage'.Static.RenderComplexMessage(
					Canvas,
					ShortMessageQueue[i].XL,YL /*Design.LineHeight*/,
					ShortMessageQueue[i].StringMessage,
					ShortMessageQueue[i].Switch,
					ShortMessageQueue[i].RelatedPRI,
					PlayerOwner.PlayerReplicationInfo,
					ShortMessageQueue[i].OptionalObject
					);
		}
		else
		{
			if (ShortMessageQueue[i].RelatedPRI==PlayerOwner.PlayerReplicationInfo) Canvas.DrawColor=Design.ColorGreen; else Canvas.DrawColor=Design.ColorGrey;
			Canvas.DrawText(ShortMessageQueue[i].StringMessage,false);
		}
	}

	Canvas.SetClip(oldclipx, oldclipy);
}

simulated function bool TOHud_DrawIdentification (Canvas Canvas)
{
	local float xl, yl;
	local Actor a;
	local string id;

	if (bHideHud)
	{
		return true;
	}

	// Draw Identify
	if(TraceIdentify(Canvas) || (IdentifyFadeTime>0.0))
	{
		TOHud_Tool_SetTextstyle(Canvas);

			if (IdentifyTarget!=None && IdentifyTarget.PlayerName!="" && (IdentifyFadeTime<=3.0))
			{
				id=IdentifyTarget.PlayerName;

				Canvas.Font=MyFonts.GetBigFont(Canvas.ClipX);
				Canvas.StrLen(id,xl,yl);

				TOHud_SetTeamColor(Canvas, IdentifyTarget.Team);
				Canvas.SetPos((Canvas.ClipX - xl)*0.5, 0.75*Canvas.ClipY);
				Canvas.DrawColor.R = Canvas.DrawColor.R * IdentifyFadeTime * 0.333;
				Canvas.DrawColor.G = Canvas.DrawColor.G * IdentifyFadeTime * 0.333;
				Canvas.DrawColor.B = Canvas.DrawColor.B * IdentifyFadeTime * 0.333;
				Canvas.DrawText(id);
			}

		if ( PlayerOwner!=None && PlayerOwner.IsA('s_Player') && s_Player(PlayerOwner).bShowDebug && (Pawn(IdentifyTarget.Owner) != None) )
		{
			Canvas.Font = MyFonts.GetAReallySmallFont(Canvas.ClipX);
			Canvas.DrawColor = Design.ColorSuperwhite;

			Canvas.StrLen(" ", xl, yl);
			ShowDebugActor(Canvas, Pawn(IdentifyTarget.Owner), yl, false);
		}
	}
	else if ((PlayerOwner!=None) && (PlayerOwner.IsA('s_Player')) && (s_Player(PlayerOwner).bShowDebug))
	{
		a=TraceActorDebug();
		if (A!=None)
		{
			yl=0;
			ShowDebugActor(Canvas,a,yl,false);
		}
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

