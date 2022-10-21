class TFGUITabScores extends TO_GUITabScores;

simulated function Paint (Canvas Canvas, float x, float y)
{
	local byte				listoffset;
	local byte				vislines;
	local float				ypos;
	local int				i;
	if (!bDraw)
	{
		return;
	}

	// background
	if (OwnerHud.bDrawBackground)
	{
		Super.Paint(Canvas, x, y);
	}

	Canvas.Style = OwnerInterface.ERenderStyle.STY_Normal;
	MyY = 0;

	if (Canvas.ClipY>=600) //draw new scoreboard
	{
		// round scores
		TOScoreboard_DrawTeamstats(Canvas);

		// table header
		TOScoreboard_DrawTableHeader(Canvas);

		// players
		TOScoreboard_Tool_UpdatePlayerlist();
		TFScoreboard_DrawPlayerList(Canvas);
	} else { // draw old scoreboard
		// round scores
		Canvas.Style = OwnerInterface.ERenderStyle.STY_Normal;
		TOScoreboard_DrawTeamstats2(Canvas);

		// table
		ypos = Top + SpaceTitle[Resolution];
		TOScoreboard_DrawTable(Canvas, ypos);

		// players
		TOScoreboard_Tool_UpdatePlayerlist();

		OwnerInterface.Design.SetScoreboardFont(Canvas);
		for (i=0; i<PlayerCount; i++)
		{
			ypos += OwnerInterface.Design.LineHeight;
			TFScoreboard_DrawPlayer2(Canvas, PlayerList[i], ypos);
		}

		// Clear list
		for (i=0; i<32; i++)
		{
			PlayerList[i] = None;
		}
	}
}

simulated final function TFScoreboard_DrawPlayer (Canvas Canvas, PlayerReplicationInfo pri, int ypos, int BoxHeight, int MyX)
{
	local PlayerReplicationInfo		ownerInfo;
	local TO_PRI					TOPRI;
	local TO_BRI					TOBRI;
	local float						colormod, u;
	local float						oldorigx, oldclipx;
	local int						time, InflictedDmg;
	local texture					icon;
	local string					botorder;
    local byte hasflag;

	ownerInfo = OwnerPlayerPawn.PlayerReplicationInfo;

	TOPRI = TO_PRI(pri);
	TOBRI = TO_BRI(pri);
    hasflag=3;
	// player state
/*	if ( (TOBRI != None && TOBRI.bHasBomb == true) || ((TOPRI != None) && TOPRI.bHasBomb == true) )			// c4
	{
		colormod = 0.7;
		u = 108;
	}
	else if ( (TOBRI != None && TOBRI.bEscaped == true) || (TOPRI != None && TOPRI.bEscaped == true) )		// escaped
	{
		colormod = 0.4;
		u = 136;
	}*/
	if ((TOBRI!=None) && (TOBRI.HasFlag!=None))
	{
	   hasflag=TOBRI.Team;
	}
	else if ((TOPRI!=None) && (TOPRI.HasFlag!=None))
	{
	   hasflag=TOPRI.team;
	}
	else if (pri.bIsSpectator)																				// dead
	{
		colormod = 0.4;
		u = 0;
	}
	else
	{
		colormod = 0.7;
		u = 0;
	}

   	OwnerInterface.Design.SetScoreboardFont(canvas);

	// background
	if (pri.Team < 2)
	{
		Canvas.SetPos(MyX+2, ypos);
		//Canvas.Style = OwnerInterface.ERenderStyle.STY_Normal;
		Canvas.Style = OwnerInterface.ERenderStyle.STY_Translucent;
		Canvas.DrawColor = OwnerInterface.Design.ColorTeam[pri.Team] * colormod;
		Canvas.DrawTile(Texture'tilewhite', Width/2-3, BoxHeight, 0, 0, 16.0, 16.0);
	}
	else
	{
		Canvas.SetPos(MyX+2, ypos);
		//Canvas.Style = OwnerInterface.ERenderStyle.STY_Normal;
		Canvas.Style = OwnerInterface.ERenderStyle.STY_Translucent;
		Canvas.DrawColor = OwnerInterface.Design.ColorGreen * colormod;
		Canvas.DrawTile(Texture'tilewhite', Width/2-3, BoxHeight, 0, 0, 16.0, 16.0);
	}

	// highlight owner & admin
	if (pri.PlayerID == OwnerInfo.PlayerID)
	{
		if ( pri.bAdmin )
		{
			Canvas.DrawColor = OwnerInterface.Design.ColorYellow * (OwnerHUD.TutIconBlink+0.5);
		}
		else
			Canvas.DrawColor = OwnerInterface.Design.ColorSuperwhite * (OwnerHUD.TutIconBlink+0.5);
	}
	else if (pri.bAdmin)
	{
		Canvas.DrawColor = OwnerInterface.Design.ColorYellow * colormod;
	}
	else if (pri.bIsSpectator)
	{
		Canvas.DrawColor = OwnerInterface.Design.ColorGrey;
	}
	else
	{
		Canvas.DrawColor = OwnerInterface.Design.Colorwhite;
	}

	// icons
/*	if (u > 0)
	{
		Canvas.Style = OwnerInterface.ERenderStyle.STY_Translucent;
		TOScoreboard_DrawIcon(Canvas, u, 237, ypos, MyX, BoxHeight);
	}*/

	if (hasflag <3)
	{
		Canvas.Style = OwnerInterface.ERenderStyle.STY_Normal;
		TFScoreboard_DrawFlagIcon(Canvas,hasflag, 237, ypos, MyX, BoxHeight);
	}

	Canvas.Style = OwnerInterface.ERenderStyle.STY_Normal;
	ypos = ypos + OwnerInterface.Design.LineSpacing;

	// nickname
	OwnerInterface.Tool_DrawClippedText(Canvas, pri.PlayerName, MyX+(Root.WinWidth - OwnerHUD.Design.GetGoodWidth(Root.WinWidth, Root.WinHeight))/2.0+OffsetNick[Resolution], ypos, OffsetTime[Resolution] - OffsetNick[Resolution] - Padding[Resolution]);

	// score
	if(pri.Team!=255)
	{
		if(PRI.bIsABot) InflictedDmg = TOBRI.InflictedDmg; else InflictedDmg = TOPRI.InflictedDmg;
		Canvas.SetPos(MyX+OffsetScore[Resolution], ypos);
		Canvas.DrawText(InflictedDmg/10 , false);
	}

	// kills & deaths
	if(pri.Team!=255)
	{
		Canvas.SetPos(MyX+OffsetKills[Resolution], ypos);
		Canvas.DrawText(int(pri.Score)$"/"$int(pri.Deaths), false);
	}

	// id
	if (!pri.bIsABot)
	{
		Canvas.SetPos(MyX+OffsetID[Resolution], ypos);
		Canvas.DrawText(pri.PlayerID, false);
	}


	if (pri.Team==255) return; // if not spectator
	// then goto line 2
	ypos = ypos + OwnerInterface.Design.LineHeight;
	OwnerInterface.Design.SetTinyFont(canvas);

	// location / orders
	if ( TOPRI!=None && TOPRI.bRealSpectator )
	{
		OwnerInterface.Tool_DrawClippedText(Canvas, "Spectator", MyX+(Root.WinWidth-OwnerHUD.Design.GetGoodWidth(Root.WinWidth, Root.WinHeight))/2.0+OffsetLoc[Resolution], ypos, OffsetKills[Resolution] - OffsetLoc[Resolution] - Padding[Resolution]);
	}
	else if ( OwnerInfo.Team == 255 )
	{
		OwnerInterface.Tool_DrawClippedText(Canvas, "Waiting Player", MyX+(Root.WinWidth-OwnerHUD.Design.GetGoodWidth(Root.WinWidth, Root.WinHeight))/2.0+OffsetLoc[Resolution], ypos, OffsetKills[Resolution] - OffsetLoc[Resolution] - Padding[Resolution]);
	}
	else if ( (OwnerInfo.Team == pri.Team) && !pri.bIsSpectator )
	{
		if (PRI.bIsABot)
		{
			botorder = s_GameReplicationInfo(OwnerPlayerPawn.GameReplicationInfo).GetOrderString(PRI);
		}

		if (bShowMode && (botorder != ""))
		{
			OwnerInterface.Tool_DrawClippedText(Canvas, TextScoresOrders@botorder, MyX+(Root.WinWidth-OwnerHUD.Design.GetGoodWidth(Root.WinWidth, Root.WinHeight))/2.0+OffsetLoc[Resolution], ypos, OffsetKills[Resolution] - OffsetLoc[Resolution] - Padding[Resolution]);
		}
		else
		{
			if (pri.PlayerLocation != None)
			{
				OwnerInterface.Tool_DrawClippedText(Canvas, pri.PlayerLocation.LocationName, MyX+(Root.WinWidth-OwnerHUD.Design.GetGoodWidth(Root.WinWidth, Root.WinHeight))/2.0+OffsetLoc[Resolution], ypos, OffsetKills[Resolution] - OffsetLoc[Resolution] - Padding[Resolution]);
			}
			else if (pri.PlayerZone != None)
			{
				OwnerInterface.Tool_DrawClippedText(Canvas, pri.PlayerZone.ZoneName, MyX+(Root.WinWidth-OwnerHUD.Design.GetGoodWidth(Root.WinWidth, Root.WinHeight))/2.0+OffsetLoc[Resolution], ypos, OffsetKills[Resolution] - OffsetLoc[Resolution] - Padding[Resolution]);
			}
		}
	}

	// time
	Canvas.SetPos(MyX+OffsetTime[Resolution], ypos);
	time = Max(1, (OwnerInterface.Level.TimeSeconds + OwnerInfo.StartTime - pri.StartTime)/60);
	Canvas.DrawText(TextScoresTime@time, false);

	if ( OwnerInterface.Level.NetMode != NM_Standalone )
	{
		// ping
		Canvas.SetPos(MyX+OffsetPing[Resolution], ypos);
		Canvas.DrawText(TextScoresPing@pri.Ping, false);

		// packetloss
		Canvas.SetPos(MyX+OffsetPL[Resolution], ypos);
		Canvas.DrawText(TextScoresPL@pri.Packetloss, false);

		// TOProtect status
		if (TOPRI != none && (pri.Team == 0 || pri.Team == 1) && s_GameReplicationInfo(OwnerPlayerPawn.GameReplicationInfo).bTOProtectActive )
			RenderTOPStatus(Canvas, TOPRI, ypos, MyX, BoxHeight);
	}
}

simulated final function TFScoreboard_DrawPlayerList (Canvas Canvas)
{
	local int i, x, y, GoodWidth, numtiles, Terrors, Specials, Specs, ULineHeight, LLineHeight, Start;
	local bool right;

	// GetBoxHeight
	OwnerInterface.Design.SetScoreboardFont(canvas);
	ULineHeight = OwnerInterface.Design.LineHeight;
	GoodWidth = OwnerInterface.Design.GetGoodWidth(Canvas.ClipX, Canvas.ClipY) - 240;
	OwnerInterface.Design.SetTinyFont(canvas);
	LLineHeight = OwnerInterface.Design.LineHeight;

	if (Scroll) {
		Start = ((Top + Height - MyY) / (ULineHeight + LLineHeight + 2));// - 1; // <-- -1 nicht sicher
	} else
		Start = 0;
	Terrors = -Start;
	Specials = -Start;

	//Draw 0815 players
	for (i=0; i<PlayerCount; i++)
	{

		if (PlayerList[i].Team==0)
		{
			y = Terrors++ * (ULineHeight + LLineHeight + 2) + MyY;
			if (Terrors <= 0) continue;
		} else if (PlayerList[i].Team==1)
		{
			y = Specials++ * (ULineHeight + LLineHeight + 2) + MyY;
			if (Specials <= 0) continue;
		}
		if (PlayerList[i].Team==255) continue;
		if (y + ULineHeight + LLineHeight > Top + Height) continue;
		//Playerposition
		if (PlayerList[i].team == 1)
			MyX = Left + GoodWidth/2-1;
		else
			MyX = Left;
		TFScoreboard_DrawPlayer(Canvas, PlayerList[i], y, ULineHeight+LLineHeight, MyX);
	}

	MyY = (TeamMaxPlayerCount + Start) * (ULineHeight + LLineHeight + 2) + MyY;

	if (MyY + 20 + ULineHeight + LLineHeight > Top + Height) return;

 	if (TeamMaxPlayerCount - Start != 0)
 	{
		// Draw another bar here
		numtiles = (OwnerInterface.Design.GetGoodWidth(Canvas.ClipX, Canvas.ClipY) - 240) >> 4;	// 16px per tile

		// set position
	   	y = MyY;

		x = ( OwnerInterface.Design.GetGoodWidth(Canvas.ClipX, Canvas.ClipY)
		  + ( Canvas.ClipX - OwnerInterface.Design.GetGoodWidth(Canvas.ClipX, Canvas.ClipY) ) / 2.0 - numtiles*16 + 48 ) * 0.5
		  + ( Canvas.ClipX - OwnerInterface.Design.GetGoodWidth(Canvas.ClipX, Canvas.ClipY) ) / 4.0;

		Canvas.CurX = x;

		// draw bar
		Canvas.DrawColor = OwnerInterface.Design.ColorWhite;
		for (i = 0; i < numtiles; i++)
		{
			Canvas.CurY = y;

			Canvas.Style = OwnerHud.ERenderStyle.STY_Translucent;
			Canvas.DrawTile(Texture'hud_elements', 16, 19, 17, 237 , 16.0, 19);	// bg

			Canvas.CurX -= 16.0;
			Canvas.Style = OwnerHud.ERenderStyle.STY_Masked;
			Canvas.DrawTile(Texture'hud_elements', 16, 19, 67, 237, 16.0, 19);	// fg
		}

		MyY = y + 20;
	}

	// Draw specs
	for (i=0; i<PlayerCount; i++)
	{
		if (PlayerList[i].Team==255)
			y = MyY + Specs * (ULineHeight + 2);
		else continue;
		if (y + ULineHeight > Top + Height) continue;
		// Playerposition
		if (right)
			MyX = Left + GoodWidth/2-1;
		else
			MyX = Left;

		TFScoreboard_DrawPlayer(Canvas, PlayerList[i], y, ULineHeight, MyX);
		if (right) Specs++;
		right = !right;
	}
}

simulated final function TFScoreboard_DrawPlayer2 (Canvas Canvas, PlayerReplicationInfo pri, float ypos)
{
	local PlayerReplicationInfo		ownerInfo;
	local TO_PRI					TOPRI;
	local TO_BRI					TOBRI;
	local float						colormod, u;
	local float						oldorigx, oldclipx;
	local int						time;
	local texture					icon;
	local string					botorder;
	local int						InflictedDmg;
    local byte hasflag;

	ownerInfo = OwnerPlayerPawn.PlayerReplicationInfo;

	TOPRI = TO_PRI(pri);
	TOBRI = TO_BRI(pri);
    hasflag=3;
	// player state
/*	if ( (TOBRI != None && TOBRI.bHasBomb == true) || ((TOPRI != None) && TOPRI.bHasBomb == true) )			// c4
	{
		colormod = 0.7;
		u = 108;
	}
	else if ( (TOBRI != None && TOBRI.bEscaped == true) || (TOPRI != None && TOPRI.bEscaped == true) )		// escaped
	{
		colormod = 0.4;
		u = 136;
	}*/
	if ((TOBRI!=None) && (TOBRI.HasFlag!=NOne))
    {
        hasflag=TOBRI.Team;
    }
	else if ((TOPRI!=None) && (TOPRI.HasFlag!=NOne))
    {
        hasflag=TOBRI.Team;
    }
	else if (pri.bIsSpectator)																				// dead
	{
		colormod = 0.4;
		u = 0;
	}
	else
	{
		colormod = 0.7;
		u = 0;
	}

	// background
	if (pri.Team < 2)
	{
		Canvas.SetPos(Left+2, ypos);
		Canvas.Style = OwnerInterface.ERenderStyle.STY_Normal;
		//Canvas.Style = OwnerInterface.ERenderStyle.STY_Translucent;
		Canvas.DrawColor = OwnerInterface.Design.ColorTeam[pri.Team] * colormod;
		Canvas.DrawTile(Texture'tilewhite', Width-4, OwnerInterface.Design.LineHeight, 0, 0, 16.0, 16.0);
	}
	else
	{
		Canvas.SetPos(Left+2, ypos);
		Canvas.Style = OwnerInterface.ERenderStyle.STY_Normal;
		//Canvas.Style = OwnerInterface.ERenderStyle.STY_Translucent;
		Canvas.DrawColor = OwnerInterface.Design.ColorGreen * colormod;
		Canvas.DrawTile(Texture'tilewhite', Width-4, OwnerInterface.Design.LineHeight, 0, 0, 16.0, 16.0);
	}

	// highlight owner & admin
	if (pri.PlayerID == OwnerInfo.PlayerID)
	{
		if ( pri.bAdmin )
		{
			Canvas.DrawColor = OwnerInterface.Design.ColorYellow * (OwnerHUD.TutIconBlink+0.5);
		}
		else
			Canvas.DrawColor = OwnerInterface.Design.ColorSuperwhite * (OwnerHUD.TutIconBlink+0.5);
	}
	else if (pri.bAdmin)
	{
		Canvas.DrawColor = OwnerInterface.Design.ColorYellow * colormod;
	}
	else if (pri.bIsSpectator)
	{
		Canvas.DrawColor = OwnerInterface.Design.ColorGrey;
	}
	else
	{
		Canvas.DrawColor = OwnerInterface.Design.Colorwhite;
	}

	// icons
/*	if (u > 0)
	{
		Canvas.Style = OwnerInterface.ERenderStyle.STY_Translucent;
		TOScoreboard_DrawIcon2(Canvas, u, 237, ypos);
	}*/

	if (hasflag<3)
	{
		Canvas.Style = OwnerInterface.ERenderStyle.STY_Normal;
		TOScoreboard_DrawFlagIcon2(Canvas,hasflag, 237, ypos);
	}

	Canvas.Style = OwnerInterface.ERenderStyle.STY_Normal;
	ypos = ypos + OwnerInterface.Design.LineSpacing;

	// nickname
	OwnerInterface.Tool_DrawClippedText(Canvas, pri.PlayerName, Left+(Root.WinWidth - OwnerHUD.Design.GetGoodWidth(Root.WinWidth, Root.WinHeight))/2.0+OffsetNick2, ypos, OffsetScore2 - OffsetNick2 - Padding[Resolution]);

	// score
	if(PRI.bIsABot) InflictedDmg = TOBRI.InflictedDmg; else InflictedDmg = TOPRI.InflictedDmg;
	Canvas.SetPos(Left+OffsetScore2, ypos);
	time = Max(1, (OwnerInterface.Level.TimeSeconds + OwnerInfo.StartTime - pri.StartTime)/60);
	Canvas.DrawText(InflictedDmg/10, false);

	// location / orders
	if ( TOPRI!=None && TOPRI.bRealSpectator )
	{
		OwnerInterface.Tool_DrawClippedText(Canvas, "Spectator", Left+(Root.WinWidth-OwnerHUD.Design.GetGoodWidth(Root.WinWidth, Root.WinHeight))/2.0+OffsetLoc2, ypos, OffsetKills2 - OffsetLoc2 - Padding[Resolution]);
	}
	else if ( OwnerInfo.Team == 255 )
	{
		OwnerInterface.Tool_DrawClippedText(Canvas, "Waiting Player", Left+(Root.WinWidth-OwnerHUD.Design.GetGoodWidth(Root.WinWidth, Root.WinHeight))/2.0+OffsetLoc2, ypos, OffsetKills2 - OffsetLoc2 - Padding[Resolution]);
	}
	else if ( (OwnerInfo.Team == pri.Team) && !pri.bIsSpectator )
	{
		if (PRI.bIsABot)
		{
			botorder = s_GameReplicationInfo(OwnerPlayerPawn.GameReplicationInfo).GetOrderString(PRI);
		}

		if (bShowMode && (botorder != ""))
		{
			OwnerInterface.Tool_DrawClippedText(Canvas, TextScoresOrders@botorder, Left+(Root.WinWidth-OwnerHUD.Design.GetGoodWidth(Root.WinWidth, Root.WinHeight))/2.0+OffsetLoc2, ypos, OffsetKills2 - OffsetLoc2 - Padding[Resolution]);
		}
		else
		{
			if (pri.PlayerLocation != None)
			{
				OwnerInterface.Tool_DrawClippedText(Canvas, pri.PlayerLocation.LocationName, Left+(Root.WinWidth-OwnerHUD.Design.GetGoodWidth(Root.WinWidth, Root.WinHeight))/2.0+OffsetLoc2, ypos, OffsetKills2 - OffsetLoc2 - Padding[Resolution]);
			}
			else if (pri.PlayerZone != None)
			{
				OwnerInterface.Tool_DrawClippedText(Canvas, pri.PlayerZone.ZoneName, Left+(Root.WinWidth-OwnerHUD.Design.GetGoodWidth(Root.WinWidth, Root.WinHeight))/2.0+OffsetLoc2, ypos, OffsetKills2 - OffsetLoc2 - Padding[Resolution]
				);
			}
		}
	}

	// kills & deaths
	Canvas.SetPos(Left+OffsetKills2, ypos);
	Canvas.DrawText(int(pri.Score)$"/"$int(pri.Deaths), false);

	if ( OwnerInterface.Level.NetMode != NM_StandAlone )
	{
		// ping
		Canvas.SetPos(Left+OffsetPing2, ypos);
		Canvas.DrawText(pri.Ping, false);

		// id (todo: replace with score)
		if (!pri.bIsABot)
		{
			Canvas.SetPos(Left+OffsetID2, ypos);
			Canvas.DrawText(pri.PlayerID, false);
		}
	}
}

simulated final function TOScoreboard_DrawFlagIcon2(Canvas Canvas, byte u, float v, float ypos)
{
	local float					xl, yl;


	if (Canvas.ClipY < 768)
	{
		xl = 12;
		yl = 10;
	}
	else
	{
		xl = 24;
		yl = 19;
	}

	Canvas.bNoSmooth = false;
	Canvas.SetPos(Left+Padding[Resolution], ypos + 0.5*(OwnerInterface.Design.LineHeight-yl));
	if (u==0) Canvas.DrawTile(Texture'TOCTFTex.Icons.BlueFlag', xl, yl, 0, 0, 32, 32);
	else Canvas.DrawTile(Texture'TOCTFTex.Icons.RedFlag', xl, yl, 0, 0, 32, 32);
	Canvas.bNoSmooth = true;
}

simulated final function TFScoreboard_DrawFlagIcon (Canvas Canvas, byte u, float v, float ypos, int MyX, int BoxHeight)
{
	local float					xl, yl;


	if (Canvas.ClipY < 768)
	{
		xl = 12;
		yl = 10;
	}
	else
	{
		xl = 24;
		yl = 19;
	}

	Canvas.bNoSmooth = false;
	Canvas.SetPos(MyX+5, ypos + 0.5*(BoxHeight-yl) - 3);
	if (u==0) Canvas.DrawTile(Texture'TOCTFTex.Icons.BlueFlag', xl, yl, 0, 0, 32, 32);
	else Canvas.DrawTile(Texture'TOCTFTex.Icons.RedFlag', xl, yl, 0, 0, 32, 32);
	Canvas.bNoSmooth = true;
}

defaultproperties
{
}

