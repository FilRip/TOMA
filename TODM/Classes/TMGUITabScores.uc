class TMGUITabScores extends TO_GUITabScores;

var float DMOffsetNick[5],DMOffsetTime[5],DMOffsetPing[5],DMOffsetLoc[5],DMOffsetKills[5],DMOffsetScore[5];
var localized string CurrentFragsRoundText;

simulated function Paint(Canvas Canvas,float x,float y)
{
	local byte listoffset;
	local byte vislines;
	local float	ypos;
	local int i;

	if (!bDraw)
		return;

	if (OwnerHud.bDrawBackground)
		Super(TO_GUIBaseTab).Paint(Canvas,x,y);

	Canvas.Style=OwnerInterface.ERenderStyle.STY_Normal;
	MyY=0;

	Canvas.Style=OwnerInterface.ERenderStyle.STY_Normal;
//	TOScoreboard_DrawTeamstats2(Canvas);

	ypos=Top+SpaceTitle[Resolution];
	TMScoreboard_DrawTable(Canvas,ypos);
// Pkoi je l'ai mi ? je ne sais plus, en tout cas, apres beta test 01 10 2003, on prefere po
//    SortMode=SM_KILLRATIO;
	TMScoreboard_Tool_UpdatePlayerlist();

	OwnerInterface.Design.SetScoreboardFont(Canvas);
	for (i=0;i<PlayerCount;i++)
	{
		ypos+=OwnerInterface.Design.LineHeight;
		TMScoreboard_DrawPlayer2(Canvas,PlayerList[i],ypos);
	}

	for (i=0;i<32;i++)
		PlayerList[i]=None;
}

simulated final function TMScoreboard_DrawPlayer2(Canvas Canvas,PlayerReplicationInfo pri,float ypos)
{
	local PlayerReplicationInfo ownerInfo;
	local TO_PRI TOPRI;
	local TO_BRI TOBRI;
	local float colormod,u;
	local float oldorigx,oldclipx;
	local int time;
	local texture icon;
	local string botorder;
	local int InflictedDmg;

	ownerInfo=OwnerPlayerPawn.PlayerReplicationInfo;

	TOPRI=TO_PRI(pri);
	TOBRI=TO_BRI(pri);

/*	if (((TOBRI!=None) && (TOBRI.bHasBomb==true)) || ((TOPRI!=None) && (TOPRI.bHasBomb==true)))
	{
		colormod=0.7;
		u=108;
	}
	else if (((TOBRI!=None) && (TOBRI.bEscaped==true)) || (TOPRI!=None && (TOPRI.bEscaped==true)))
	{
		colormod=0.4;
		u=136;
	}
	else if (pri.bIsSpectator)																				// dead
	{            */
		colormod=0.4;
		u=0;
/*	}
	else
	{
		colormod=0.7;
		u=0;
	}

	if (pri.Team<2)
	{
		Canvas.SetPos(Left+2,ypos);
		Canvas.Style=OwnerInterface.ERenderStyle.STY_Normal;
		Canvas.DrawColor=OwnerInterface.Design.ColorTeam[pri.Team]*colormod;
		Canvas.DrawTile(Texture'tilewhite',Width-4,OwnerInterface.Design.LineHeight,0,0,16.0,16.0);
	}
	else
	{       */
		Canvas.SetPos(Left+2,ypos);
		Canvas.Style=OwnerInterface.ERenderStyle.STY_Normal;
		Canvas.DrawColor=OwnerInterface.Design.ColorGreen*colormod;
		Canvas.DrawTile(Texture'tilewhite',Width-4,OwnerInterface.Design.LineHeight,0,0,16.0,16.0);
//	}

	if (pri.PlayerID==OwnerInfo.PlayerID)
	{
		if (pri.bAdmin)
			Canvas.DrawColor=OwnerInterface.Design.ColorYellow*(OwnerHUD.TutIconBlink+0.5);
		else
			Canvas.DrawColor=OwnerInterface.Design.ColorSuperwhite*(OwnerHUD.TutIconBlink+0.5);
	}
	else if (pri.bAdmin)
	{
		Canvas.DrawColor=OwnerInterface.Design.ColorYellow*colormod;
	}
	else if (pri.bIsSpectator)
	{
		Canvas.DrawColor=OwnerInterface.Design.ColorGrey;
	}
	else
	{
		Canvas.DrawColor=OwnerInterface.Design.Colorwhite;
	}

	if (u>0)
	{
		Canvas.Style=OwnerInterface.ERenderStyle.STY_Translucent;
		TOScoreboard_DrawIcon2(Canvas,u,237,ypos);
	}

	Canvas.Style=OwnerInterface.ERenderStyle.STY_Normal;
	ypos=ypos+OwnerInterface.Design.LineSpacing;

	OwnerInterface.Tool_DrawClippedText(Canvas,pri.PlayerName,Left+(Root.WinWidth - OwnerHUD.Design.GetGoodWidth(Root.WinWidth, Root.WinHeight))/2.0+DMOffsetNick[Resolution],ypos,DMOffsetScore[Resolution]-DMOffsetNick[Resolution]-Padding[Resolution]);

	if(PRI.bIsABot) InflictedDmg=TOBRI.InflictedDmg; else InflictedDmg=TOPRI.InflictedDmg;
	Canvas.SetPos(Left+DMOffsetScore[Resolution]-100,ypos);
	time=Max(1,(OwnerInterface.Level.TimeSeconds+OwnerInfo.StartTime-pri.StartTime)/60);
	Canvas.DrawText(InflictedDmg/10,false);

	if ((TOPRI!=None) && (TOPRI.bRealSpectator))
	{
		OwnerInterface.Tool_DrawClippedText(Canvas,"Spectator",Left+(Root.WinWidth-OwnerHUD.Design.GetGoodWidth(Root.WinWidth, Root.WinHeight))/2.0+DMOffsetLoc[Resolution],ypos,DMOffsetKills[Resolution]-DMOffsetLoc[Resolution]-Padding[Resolution]);
	}
	else if (OwnerInfo.Team==255)
	{
		OwnerInterface.Tool_DrawClippedText(Canvas,"Waiting Player",Left+(Root.WinWidth-OwnerHUD.Design.GetGoodWidth(Root.WinWidth, Root.WinHeight))/2.0+DMOffsetLoc[Resolution],ypos,DMOffsetKills[Resolution]-DMOffsetLoc[Resolution]-Padding[Resolution]);
	}
	else
	{
/*	else if ((OwnerInfo.Team==pri.Team) && (!pri.bIsSpectator))
	{
		if (PRI.bIsABot)
		{
			botorder=s_GameReplicationInfo(OwnerPlayerPawn.GameReplicationInfo).GetOrderString(PRI);
		}

		if ((bShowMode) && (botorder!=""))
		{
			OwnerInterface.Tool_DrawClippedText(Canvas,TextScoresOrders@botorder, Left+(Root.WinWidth-OwnerHUD.Design.GetGoodWidth(Root.WinWidth, Root.WinHeight))/2.0+DMOffsetLoc[Resolution],ypos,DMOffsetKills[Resolution]-DMOffsetLoc[Resolution]-Padding[Resolution]);
		}
		else
		{
			if (pri.PlayerLocation!=None)
			{       */
			     Canvas.SetPos(left+DMoffsetloc[Resolution],ypos);

				if (TMPRI(TOPRI)!=None) Canvas.DrawText(TMPRI(TOPRI).CurrentScore$"/"$TMPRI(TOPRI).NbRound);
				if (TMBRI(TOBRI)!=None) Canvas.DrawText(TMBRI(TOBRI).CurrentScore$"/"$TMBRI(TOBRI).NbRound);
/*			}
			else if (pri.PlayerZone != None)
			{
				OwnerInterface.Tool_DrawClippedText(Canvas, pri.PlayerZone.ZoneName, Left+(Root.WinWidth-OwnerHUD.Design.GetGoodWidth(Root.WinWidth, Root.WinHeight))/2.0+DMOffsetLoc[Resolution],ypos,DMOffsetKills[Resolution]-DMOffsetLoc[Resolution]-Padding[Resolution]
				);
			}
		}
	}     */
	}

	Canvas.SetPos(Left+DMOffsetKills[Resolution],ypos);
	Canvas.DrawText(int(pri.Score)$"/"$int(pri.Deaths),false);

	if (OwnerInterface.Level.NetMode!=NM_StandAlone)
	{
		Canvas.SetPos(Left+DMOffsetPing[Resolution],ypos);
		Canvas.DrawText(pri.Ping,false);

		if (!pri.bIsABot)
		{
			Canvas.SetPos(Left+DMOffsetScore[Resolution],ypos);
			Canvas.DrawText(pri.PlayerID,false);
		}
	}
}

simulated final function TMScoreboard_Tool_UpdatePlayerlist()
{
	local int i,j,max,SF,Terror;
	local int team;
	local PlayerReplicationInfo	pri;
	local PlayerPawn owner;
	local byte offset;

	PlayerCount=0;
	for (i=0;i<32;i++)
		PlayerList[i]=None;

	SpecCount=0;

	for (i=0;i<32;i++)
	{
		if (OwnerPlayerPawn.GameReplicationInfo.PRIArray[i]!=None)
		{
			pri=OwnerPlayerPawn.GameReplicationInfo.PRIArray[i];
			team=pri.Team;
			if ((pri.PlayerID!=0) && ((team<2) || (team==255)))
			{
				PlayerList[PlayerCount]=pri;
				PlayerCount++;
				SpecCount++;
			}
		}
	}

	for (i=0;i<PlayerCount;i++)
	{
		max=i;
		for (j=i+1;j<PlayerCount;j++)
			if (TMScoreboard_Tool_ComparePlayer(j,max))
				max=j;

		pri=PlayerList[max];
		PlayerList[max]=PlayerList[i];
		PlayerList[i]=pri;
	}
}

simulated final function bool TMScoreboard_Tool_ComparePlayer (int p1, int p2)
{
	local int InflictedDmg1, InflictedDmg2;

	if(PlayerList[p1].bIsABot) InflictedDmg1=TO_BRI(PlayerList[p1]).InflictedDmg; else InflictedDmg1=TO_PRI(PlayerList[p1]).InflictedDmg;
	if(PlayerList[p2].bIsABot) InflictedDmg2=TO_BRI(PlayerList[p2]).InflictedDmg; else InflictedDmg2=TO_PRI(PlayerList[p2]).InflictedDmg;

	switch (SortMode)
	{
		case SM_SCOREPTS:
								/*if (PlayerList[p1].Team<PlayerList[p2].Team) return true;
								else if (PlayerList[p1].Team>PlayerList[p2].Team) return false;*/

							 	if (InflictedDmg1>InflictedDmg2) return true;
								else if (InflictedDmg1<InflictedDmg2) return false;

								if (false) return false;

								if (PlayerList[p1].Score>PlayerList[p2].Score) return true;
								else if (PlayerList[p1].Score<PlayerList[p2].Score) return false;

								if (PlayerList[p1].Deaths<PlayerList[p2].Deaths) return true;
								else if (PlayerList[p1].Deaths>PlayerList[p2].Deaths) return false;
								break;

		case SM_KILLRATIO:
								/*if (PlayerList[p1].Team<PlayerList[p2].Team) return true;
								else if (PlayerList[p1].Team>PlayerList[p2].Team) return false;*/

								if (PlayerList[p1].Score>PlayerList[p2].Score) return true;
								else if (PlayerList[p1].Score<PlayerList[p2].Score) return false;

								if (PlayerList[p1].Deaths<PlayerList[p2].Deaths) return true;
								else if (PlayerList[p1].Deaths>PlayerList[p2].Deaths) return false;

								if (false) return false;

								if (InflictedDmg1>InflictedDmg2) return true;
								else if (InflictedDmg1<InflictedDmg2) return false;
								break;
	}

	return true;
}

simulated final function TMScoreboard_DrawTable(Canvas Canvas,float ypos)
{
	OwnerInterface.Design.SetSmallFont(Canvas);
	Canvas.DrawColor=OwnerInterface.Design.ColorWhite;
	Canvas.SetPos(Left+DMOffsetNick[Resolution], ypos);
    Canvas.DrawText(TextScoresTimeNick,true);
	Canvas.SetPos(Left+DMOffsetScore[Resolution]-100,ypos);
    Canvas.DrawText(TextScoresScore,true);
	Canvas.SetPos(Left+DMOffsetLoc[Resolution],ypos);
    Canvas.DrawText(CurrentFragsRoundText,true);
	Canvas.SetPos(Left+DMOffsetKills[Resolution],ypos);
    Canvas.DrawText(TextScoresKD,true);

	if (OwnerInterface.Level.NetMode!=NM_Standalone)
	{
		Canvas.SetPos(Left+DMOffsetPing[Resolution],ypos);
        Canvas.DrawText(TextScoresPing2,true);
		Canvas.SetPos(Left+DMOffsetScore[Resolution],ypos);
        Canvas.DrawText(TextScoresScore2,true);
	}
}

defaultproperties
{
    DMOffsetNick(0)=32.00
    DMOffsetNick(1)=40.00
    DMOffsetNick(2)=51.00
    DMOffsetNick(3)=68.00
    DMOffsetNick(4)=80.00
    DMOffsetPing(0)=142.40
    DMOffsetPing(1)=198.40
    DMOffsetPing(2)=246.60
    DMOffsetPing(3)=370.50
    DMOffsetPing(4)=452.00
    DMOffsetLoc(0)=174.40
    DMOffsetLoc(1)=238.40
    DMOffsetLoc(2)=297.60
    DMOffsetLoc(3)=438.50
    DMOffsetLoc(4)=532.00
    DMOffsetTime(0)=110.40
    DMOffsetTime(1)=158.40
    DMOffsetTime(2)=195.60
    DMOffsetTime(3)=302.50
    DMOffsetTime(4)=372.00
    DMOffsetKills(0)=320.00
    DMOffsetKills(1)=462.00
    DMOffsetKills(2)=656.00
    DMOffsetKills(3)=782.00
    DMOffsetKills(4)=1052.00
    DMOffsetScore(0)=350.00
    DMOffsetScore(1)=500.00
    DMOffsetScore(2)=710.00
    DMOffsetScore(3)=957.00
    DMOffsetScore(4)=1242.00
    CurrentFragsRoundText="Frags/Rounds"
}

