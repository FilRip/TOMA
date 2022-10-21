//=============================================================================
// s_ScoreBoard
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_ScoreBoard extends TeamScoreboard;
 

///////////////////////////////////////
// ShowScores
///////////////////////////////////////

function ShowScores( canvas Canvas )
{
	local PlayerReplicationInfo PRI;
	local int										PlayerCount, i;
	local float									LoopCountTeam[4];
	local float									XL, YL, XOffset, YOffset, XStart;
	local int										PlayerCounts[4];
	local int										LongLists[4];
	local int										BottomSlot[4];
	local font									CanvasFont;
	local bool									bCompressed;
	local float									r;

	if (s_Player(Owner) != None && !s_HUD(s_Player(Owner).MyHud).bHUDModFix)
	{
		Canvas.Style = 4;
		Canvas.DrawColor.R = 255;
		Canvas.DrawColor.G = 255;
		Canvas.DrawColor.B = 255;
		Canvas.SetPos(0,0);
		Canvas.DrawTile(Texture'Debug16', Canvas.ClipX, Canvas.ClipY, 0, 0, 16, 16);
	}

	OwnerInfo = Pawn(Owner).PlayerReplicationInfo;
	OwnerGame = TournamentGameReplicationInfo(PlayerPawn(Owner).GameReplicationInfo);	
	Canvas.Style = ERenderStyle.STY_Normal;
	CanvasFont = Canvas.Font;

	// Header
	DrawHeader(Canvas);

	for ( i=0; i<32; i++ )
		Ordered[i] = None;

	for ( i=0; i<32; i++ )
	{
		if (PlayerPawn(Owner).GameReplicationInfo.PRIArray[i] != None)
		{
			PRI = PlayerPawn(Owner).GameReplicationInfo.PRIArray[i];
			//if ( !PRI.bIsSpectator || PRI.bWaitingPlayer )
			if (PRI.Team < 2)
			{
				Ordered[PlayerCount] = PRI;
				PlayerCount++;
				PlayerCounts[PRI.Team]++;
			}
		}
	}

	SortScores(PlayerCount);
	Canvas.Font = MyFonts.GetMediumFont( Canvas.ClipX );
	Canvas.StrLen("TEXT", XL, YL);

	//ScoreStart = Canvas.CurY + YL*2;
	ScoreStart = YL * 5;

	if ( ScoreStart + PlayerCount * YL + 2 > Canvas.ClipY )
	{
		bCompressed = true;
		CanvasFont = Canvas.Font;
		Canvas.Font = font'SmallFont';
		r = YL;
		Canvas.StrLen("TEXT", XL, YL);
		r = YL/r;
		Canvas.Font = CanvasFont;
	}
	for ( I=0; I<PlayerCount; I++ )
	{
		if ( Ordered[I].Team < 4 )
		{
			if ( Ordered[I].Team % 2 == 0 )
				XOffset = (Canvas.ClipX / 4) - (Canvas.ClipX / 8);
			else
				XOffset = ((Canvas.ClipX / 4) * 3) - (Canvas.ClipX / 8);

			Canvas.StrLen("TEXT", XL, YL);
			Canvas.DrawColor = AltTeamColor[Ordered[I].Team];
			YOffset = ScoreStart + (LoopCountTeam[Ordered[I].Team] * YL) + 2;
			if (( Ordered[I].Team > 1 ) && ( PlayerCounts[Ordered[I].Team-2] > 0 ))
			{
				BottomSlot[Ordered[I].Team] = 1;
				YOffset = ScoreStart + YL*11 + LoopCountTeam[Ordered[I].Team]*YL;
			}

			// Draw Name and Ping
			if ( (Ordered[I].Team < 2) && (BottomSlot[Ordered[I].Team] == 0) && (PlayerCounts[Ordered[I].Team+2] == 0))
			{
				LongLists[Ordered[I].Team] = 1;
				DrawNameAndPing( Canvas, Ordered[I], XOffset, YOffset, bCompressed);
			} 
			else if (LoopCountTeam[Ordered[I].Team] < 8)
				DrawNameAndPing( Canvas, Ordered[I], XOffset, YOffset, bCompressed);
			if ( bCompressed )
				LoopCountTeam[Ordered[I].Team] += 1;
			else
				LoopCountTeam[Ordered[I].Team] += 2;
		}
	}

	for ( i=0; i<4; i++ )
	{
		Canvas.Font = MyFonts.GetMediumFont( Canvas.ClipX );
		if ( PlayerCounts[i] > 0 )
		{
			if ( i % 2 == 0 )
				XOffset = (Canvas.ClipX / 4) - (Canvas.ClipX / 8);
			else
				XOffset = ((Canvas.ClipX / 4) * 3) - (Canvas.ClipX / 8);
			YOffset = ScoreStart - YL * 1.5;

			if ( i > 1 )
				if (PlayerCounts[i-2] > 0)
					YOffset = ScoreStart + YL * 10;

			Canvas.DrawColor = TeamColor[i];
			Canvas.SetPos(XOffset, YOffset);
			Canvas.StrLen(TeamName[i], XL, YL);
			Canvas.DrawText(TeamName[i], false);
			Canvas.StrLen(int(OwnerGame.Teams[i].Score), XL, YL);
			Canvas.SetPos(XOffset + (Canvas.ClipX/4) - XL, YOffset);
			Canvas.DrawText(int(OwnerGame.Teams[i].Score), false);
				
			if ( PlayerCounts[i] > 4 )
			{
				if ( i < 2 )
					YOffset = ScoreStart + YL * 8;
				else
					YOffset = ScoreStart + YL * 19;
				Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
				Canvas.SetPos(XOffset, YOffset);
				if (LongLists[i] == 0)
					Canvas.DrawText(PlayerCounts[i] - 4 @ PlayersNotShown, false);
			}
		}
	}

	// Trailer
	if ( !Level.bLowRes )
	{
		Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
		DrawTrailer(Canvas);
	}
	Canvas.Font = CanvasFont;
	Canvas.DrawColor = WhiteColor;
}


///////////////////////////////////////
// DrawNameAndPing
///////////////////////////////////////

function DrawNameAndPing(Canvas Canvas, PlayerReplicationInfo PRI, float XOffset, float YOffset, bool bCompressed)
{
	local float					XL, YL, XL2, YL2, YB, AA, BB;
	local BotReplicationInfo BRI;
	local String				S, O, L, PID;
	local Font					CanvasFont;
	local bool					bAdminPlayer, bNotPlaying;
	local PlayerPawn		PlayerOwner;
	local int						Time;
	local	float					Scale;
	local	TO_PRI				TOPRI;
	local	TO_BRI				TOBRI;
	local	Byte					CRS;
	local	Color					BckCol;

	Canvas.bNoSmooth = false;

	PlayerOwner = PlayerPawn(Owner);

	bAdminPlayer = PRI.bAdmin;

	TOPRI = TO_PRI(PRI);
	TOBRI = TO_BRI(PRI);

	// Draw Name
	if (PRI.PlayerName == PlayerOwner.PlayerReplicationInfo.PlayerName)
		Canvas.DrawColor = GoldColor;

	if ( bAdminPlayer )
		Canvas.DrawColor = WhiteColor;

	Scale = ChallengeHUD(PlayerPawn(Owner).myHUD).Scale;

	if ( (TOBRI != None && TOBRI.bHasBomb == true)
		|| (TOPRI != None && TOPRI.bHasBomb == true) )
	{
		// Player has C4 Bomb
		CRS = Canvas.Style;
		Canvas.Style = ERenderStyle.STY_Translucent;
		Canvas.SetPos(XOffset - 72 * Scale, YOffset);
		Canvas.DrawTile(Texture'Bomb32', 64*Scale, 32*Scale, 0, 0, 64.0, 32.0);
		Canvas.Style = CRS;
	}
	else if ( (TOBRI != None && TOBRI.bEscaped == true)
		|| (TOPRI != None && TOPRI.bEscaped == true) )

	{
		// Player Escaped
		bNotPlaying = true;
		Canvas.DrawColor = Canvas.DrawColor * 0.5;
		CRS = Canvas.Style;
		Canvas.Style = ERenderStyle.STY_Translucent;
		Canvas.SetPos(XOffset - 72 * Scale, YOffset);
		Canvas.DrawTile(Texture'SB_Escaped', 64*Scale, 32*Scale, 0, 0, 64.0, 32.0);
		Canvas.Style = CRS;
	}
	else if (PRI.bIsSpectator)
	{
		// If player is dead, draw a little 'K.I.A'
		bNotPlaying = true;
		Canvas.DrawColor = Canvas.DrawColor * 0.5;
		CRS = Canvas.Style;
		Canvas.Style = ERenderStyle.STY_Translucent;
		Canvas.SetPos(XOffset - 72 * Scale, YOffset);
		Canvas.DrawTile(Texture'KIA32', 64*Scale, 32*Scale, 0, 0, 64.0, 32.0);
		Canvas.Style = CRS;
	}
  
	Canvas.SetPos(XOffset, YOffset);
	Canvas.DrawText(PRI.PlayerName, False);
	Canvas.StrLen(PRI.PlayerName, XL, YB);
	Canvas.StrLen(" ", AA, BB);

	if ( !PRI.bIsABot )
	{
		// PlayerID
		CanvasFont = Canvas.Font;
		Canvas.Font = Font'SmallFont';

		PID = "PlayerID: "$PRI.PlayerID;
		Canvas.StrLen(PID, XL2, YL2);

		if (PRI.Team == OwnerInfo.Team)
			Canvas.SetPos(XOffset - XL2 - 8 * Scale, YOffset + YB);
		else
			Canvas.SetPos(XOffset, YOffset + YB);

		Canvas.DrawText(PID, False);

	//Canvas.Font = CanvasFont;
//	if ( !PRI.bIsABot )
//	{
		if ( Canvas.ClipX > 512)
		{
			BckCol = Canvas.DrawColor;
			Canvas.DrawColor = WhiteColor;

			if (Level.NetMode != NM_Standalone)
			{
				if ( !bCompressed || (Canvas.ClipX > 640) )
				{
					// Draw Time
					Time = Max(1, (Level.TimeSeconds + PlayerOwner.PlayerReplicationInfo.StartTime - PRI.StartTime)/60);
					Canvas.StrLen(TimeString$":     ", XL, YL);
					//Canvas.SetPos(XOffset - XL - 6, YOffset);
					Canvas.SetPos(XOffset + (Canvas.ClipX/4) + AA * 6, YOffset);
					Canvas.DrawText(TimeString$":"@Time, false);
				}

				// Draw Ping
				//Canvas.StrLen(PingString$":     ", XL2, YL2);
				//Canvas.SetPos(XOffset - XL2 - 6, YOffset + (YL+1));
				Canvas.SetPos(XOffset + (Canvas.ClipX/4) + AA * 6, YOffset + (YL+1));
				Canvas.DrawText(PingString$":"@PRI.Ping, false);

				Canvas.SetPos(XOffset + (Canvas.ClipX/4) + AA * 6, YOffset + (YL*2+1));
				Canvas.DrawText(LossString$":"@PRI.PacketLoss, false);
			}
			Canvas.DrawColor = BckCol;
		}

		Canvas.Font = CanvasFont;
	}
/*
	// Draw Score
	if (PRI.PlayerName == PlayerOwner.PlayerReplicationInfo.PlayerName)
		Canvas.DrawColor = GoldColor;
	else
		Canvas.DrawColor = TeamColor[PRI.Team];
*/
	DrawScore(Canvas, PRI.Score, XOffset, YOffset);
	DrawDeaths(Canvas, PRI.Deaths, XOffset, YOffset);

	if (Canvas.ClipX < 512)
		return;

	// Draw location, Order
	if ( !bNotPlaying && !bCompressed && (PRI.Team == OwnerInfo.Team) )
	{
		CanvasFont = Canvas.Font;
		Canvas.Font = Font'SmallFont';

		if ( PRI.PlayerLocation != None )
			L = PRI.PlayerLocation.LocationName;
		else if ( PRI.PlayerZone != None )
			L = PRI.PlayerZone.ZoneName;
		else 
			L = "";
		if ( L != "" )
		{
			L = InString@L;
			Canvas.SetPos(XOffset, YOffset + YB);
			Canvas.DrawText(L, False);
		}
		O = OwnerGame.GetOrderString(PRI);
		if (O != "")
		{
			O = OrdersString@O;
			Canvas.StrLen(O, XL2, YL2);
			Canvas.SetPos(XOffset, YOffset + YB + YL2);
			Canvas.DrawText(O, False);
		}
		Canvas.Font = CanvasFont;
	} 
} 


///////////////////////////////////////
// DrawVictoryConditions
///////////////////////////////////////

function DrawVictoryConditions(Canvas Canvas)
{
	local TournamentGameReplicationInfo TGRI;
	local float XL, YL;

	TGRI = TournamentGameReplicationInfo(PlayerPawn(Owner).GameReplicationInfo);
	if ( TGRI == None )
		return;

	Canvas.StrLen("Test", XL, YL);
	Canvas.SetPos(0, YL * 0.5);
	Canvas.DrawText(TGRI.GameName);
	Canvas.SetPos(0, YL);

	//if ( TGRI.FragLimit > 0 )
	//{
	//	Canvas.DrawText(FragGoal@TGRI.FragLimit);
	//	Canvas.StrLen("Test", XL, YL);
	//	Canvas.SetPos(0, Canvas.CurY - YL);
	//}

	//if ( TGRI.TimeLimit > 0 )
	//	Canvas.DrawText(TimeLimit@TGRI.TimeLimit$":00");
}


///////////////////////////////////////
// DrawDeaths
///////////////////////////////////////

function DrawDeaths(Canvas Canvas, float Deaths, float XOffset, float YOffset)
{
	local float XL, YL;

	Canvas.Style = ERenderStyle.STY_Translucent;
	Canvas.StrLen(" ", XL, YL);
	Canvas.SetPos(XOffset + (Canvas.ClipX/4) + XL, YOffset);
	Canvas.DrawText("/ "$int(Deaths), False);
}


///////////////////////////////////////
// DrawTrailer
///////////////////////////////////////

function DrawTrailer( canvas Canvas )
{
	local int Hours, Minutes, Seconds;
	local float XL, YL;
	local PlayerPawn PlayerOwner;

	Canvas.bCenter = true;
	Canvas.StrLen("Test", XL, YL);
	Canvas.DrawColor = WhiteColor;
	PlayerOwner = PlayerPawn(Owner);
	Canvas.SetPos(0, Canvas.ClipY - 2 * YL);
	if ( (Level.NetMode == NM_Standalone) && Level.Game.IsA('TO_DeathMatchPlus') )
	{
		if ( TO_DeathMatchPlus(Level.Game).bRatedGame )
			Canvas.DrawText("Round #"$(s_GameReplicationInfo(PlayerOwner.GameReplicationInfo).RoundNumber+1)@TO_DeathMatchPlus(Level.Game).RatedGameLadderObj.SkillText@MapTitle@MapTitleQuote$Level.Title$MapTitleQuote, true);
		else if ( TO_DeathMatchPlus(Level.Game).bNoviceMode ) 
			Canvas.DrawText("Round #"$(s_GameReplicationInfo(PlayerOwner.GameReplicationInfo).RoundNumber+1)@class's_BotInfo'.default.Skills[Level.Game.Difficulty]@MapTitle@MapTitleQuote$Level.Title$MapTitleQuote, true);
		else  
			Canvas.DrawText("Round #"$(s_GameReplicationInfo(PlayerOwner.GameReplicationInfo).RoundNumber+1)@class's_BotInfo'.default.Skills[Level.Game.Difficulty + 4]@MapTitle@MapTitleQuote$Level.Title$MapTitleQuote, true);
	}
	else
		Canvas.DrawText("Round #"$(s_GameReplicationInfo(PlayerOwner.GameReplicationInfo).RoundNumber+1)@MapTitle@Level.Title, true);

	Canvas.SetPos(0, Canvas.ClipY - YL);
	if ( bTimeDown || (PlayerOwner.GameReplicationInfo.RemainingTime > 0) )
	{
		bTimeDown = true;
		if ( PlayerOwner.GameReplicationInfo.RemainingTime <= 0 )
			Canvas.DrawText(RemainingTime@"00:00", true);
		else
		{
			Minutes = PlayerOwner.GameReplicationInfo.RemainingTime/60;
			Seconds = PlayerOwner.GameReplicationInfo.RemainingTime % 60;
			Canvas.DrawText(RemainingTime@TwoDigitString(Minutes)$":"$TwoDigitString(Seconds), true);
		}
	}
	else
	{
		Seconds = PlayerOwner.GameReplicationInfo.ElapsedTime;
		Minutes = Seconds / 60;
		Hours   = Minutes / 60;
		Seconds = Seconds - (Minutes * 60);
		Minutes = Minutes - (Hours * 60);
		Canvas.DrawText(ElapsedTime@TwoDigitString(Hours)$":"$TwoDigitString(Minutes)$":"$TwoDigitString(Seconds), true);
	}

	if ( PlayerOwner.GameReplicationInfo.GameEndedComments != "" )
	{
		Canvas.bCenter = true;
		Canvas.StrLen("Test", XL, YL);
		Canvas.SetPos(0, Canvas.ClipY - Min(YL*6, Canvas.ClipY * 0.1));
		Canvas.DrawColor = GreenColor;
		if ( Level.NetMode == NM_Standalone )
			Canvas.DrawText(Ended@Continue, true);
		else
			Canvas.DrawText(Ended, true);
	}
	else if ( (PlayerOwner != None) && (PlayerOwner.Health <= 0) )
	{
		Canvas.bCenter = true;
		Canvas.StrLen("Test", XL, YL);
		Canvas.SetPos(0, Canvas.ClipY - Min(YL*6, Canvas.ClipY * 0.1));
		Canvas.DrawColor = GreenColor;
		Canvas.DrawText(Restart, true);
	}
	Canvas.bCenter = false;
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     TeamName(0)="Terrorists"
     TeamName(1)="Special Forces"
     Restart=""
     Continue=""
}
