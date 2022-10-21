//=============================================================================
// s_SWATGame
//=============================================================================
//
// Tactical Ops -- an Unreal Tournament modification
// -- http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_SWATGame extends TO_GameBasics
		config;


var	int	DistReachThreshold; // Minimum distance to consider a navpoint to be reached.



//
// GamePlay code
//
 

///////////////////////////////////////
// TOResetGame
///////////////////////////////////////
// Resets the game

final function TOResetGame()
{
	local Pawn	P;

	TournamentGameReplicationInfo(GameReplicationInfo).Teams[0].Score = 0;
	TournamentGameReplicationInfo(GameReplicationInfo).Teams[1].Score = 0;
	RoundNumber = 0;
	
	RemainingTime = 60 * TimeLimit;
	GameReplicationInfo.RemainingTime = RemainingTime;
	GameReplicationInfo.RemainingMinute = 0;
	GameReplicationInfo.ElapsedTime = 0;

	//s_GameReplicationInfo(GameReplicationInfo).RoundStarted = RemainingTime;
	//s_GameReplicationInfo(GameReplicationInfo).RoundDuration = RoundDuration;
	//RoundStarted = RemainingTime;

	for ( P=Level.PawnList; P!=None; P=P.nextPawn )
	{
		if ( P.PlayerReplicationInfo != None )
		{
			P.PlayerReplicationInfo.Score = 0;
			P.PlayerReplicationInfo.Deaths = 0;
		}

		KillInventory(P);

		if ( P.IsA('s_Player') )
		{
			s_Player(P).Money = 0;
			s_Player(P).HelmetCharge = 0;
			s_Player(P).VestCharge = 0;
			s_Player(P).LegsCharge = 0;
			s_Player(P).ResetTime(RemainingTime);
		}
		else if ( P.IsA('s_Bot') )
		{
			s_Bot(P).Money = 0;
			s_Bot(P).HelmetCharge = 0;
			s_Bot(P).VestCharge = 0;
			s_Bot(P).LegsCharge = 0;
		}
	}

	RestartRound();
}


///////////////////////////////////////
// RestartRound
///////////////////////////////////////

function RestartRound()
{
	// Restart a new round.
	local Pawn				PawnLink;
	local	s_Evidence	E;
	local	TO_PRI			TOPRI;
	local	TO_BRI			TOBRI;
	local	s_Player		P;
	local	TO_ConsoleTimer	CT;
	local	TacticalOpsMapActors	TOMA;

	local		s_Trigger			sT;

	if ( GamePeriod == GP_RoundRestarting )
		return;

	// Round Limit
	if ( (RoundLimit > 0) && (RoundNumber == RoundLimit) )
	{
		GamePeriod = GP_PostRound;
		Super(GameInfo).EndGame( "Round Limit" );
		return;
	}

	// Time Limit
	if ( (TimeLimit > 0) && (RemainingTime <= 0) )
	{
		GamePeriod = GP_PostRound;
		Super(GameInfo).EndGame( "Time Limit" );
		return;
	}

	RoundEnded();
	
	// Removing objects left in the level
	spawn(class's_Remover', self);

	GamePeriod = GP_RoundRestarting;
	RoundDelay = Default.RoundDelay;
	RoundNumber++;
	s_GameReplicationInfo(GameReplicationInfo).RoundNumber = RoundNumber;
	
	//Log("s_SWATGame::RestartRound - "@RoundNumber);

	// Playing last round?
	if ( RoundNumber == RoundLimit )
	{
		foreach allactors(class's_Player', P)
			P.ReceiveLocalizedMessage(class's_MessageRoundWinner', 8);
	}

	for ( PawnLink=Level.PawnList; PawnLink!=None; PawnLink=PawnLink.nextPawn )
	{
		P = s_Player(PawnLink);

		if ( !PawnLink.IsA('s_NPC') )
		{
			// Avoid continuous firing bug
			PawnLink.bFire = 0;
			PawnLink.bAltFire = 0;

			if ( PawnLink.IsA('s_Bot') )
			{
				TOBRI = TO_BRI(Pawnlink.PlayerReplicationInfo);
				if ( TOBRI != None )
				{
					TOBRI.bEscaped = false;
					TOBRI.bIsSpectator = false;
				}
				else 
					log("RestartRound - TOBRI == None");

				s_Bot(PawnLink).bNotPlaying = false;
				s_Bot(PawnLink).O_Count = 0;

				RestartPlayer(PawnLink);

				s_Bot(PawnLink).bDead = false;
				s_Bot(PawnLink).SetOrders('Freelance', None, false);
				s_Bot(PawnLink).OrderObject = None;
				s_Bot(PawnLink).Objective = 'O_DoNothing';
				s_Bot(PawnLink).O_number = 255;
				s_Bot(PawnLink).HostageFollowing = 0;

				// Award money if Bot owns Evidence
				if ( s_Bot(PawnLink).Eidx > 0 )
				{
					while ( s_Bot(PawnLink).Eidx != 0 )
					{
						s_Bot(PawnLink).Evidence[s_Bot(PawnLink).Eidx] = None;
						s_Bot(PawnLink).Eidx--;
						
						if ( PawnLink.PlayerReplicationInfo.Team == 0 )
							TerrAmount += EvidenceAmount;
						else
							CTAmount += EvidenceAmount;
					}
				}

				// Special items
				if ( s_Bot(PawnLink).bSpecialItem )
				{
					s_Bot(PawnLink).bSpecialItem = false;
					if (PawnLink.PlayerReplicationInfo.Team == 0)
						TerrAmount += EvidenceAmount;
					else
						CTAmount += EvidenceAmount;
				}

			}
			else if ( P != None )
			{
				if ( P.PlayerReplicationInfo.bWaitingPlayer )
					continue;

				// Award money if player owns Evidence
				if ( P.Eidx > 0 )
				{
					while ( P.Eidx != 0 )
					{
						P.Evidence[P.Eidx] = None;
						P.Eidx--;
						if (PawnLink.PlayerReplicationInfo.Team == 0)
							TerrAmount += EvidenceAmount;
						else
							CTAmount += EvidenceAmount;
					}
				}

				// Special items
				if ( P.bSpecialItem )
				{
					if ( PawnLink.PlayerReplicationInfo.Team == 0 )
						TerrAmount += EvidenceAmount;
					else
						CTAmount += EvidenceAmount;
					P.bSpecialItem = false;
				}

				TOPRI = TO_PRI(Pawnlink.PlayerReplicationInfo);
				if ( TOPRI != None )
				{
					TOPRI.bEscaped = false;

					// Clearing votes
					if ( (Level.NetMode != NM_StandAlone) && (RoundNumber % 4 == 0) )
					{
						P.ReceiveLocalizedMessage(class's_MessageVote', 6);
						TOPRI.ClearVotes();
					}
				}
				else 
					log("RestartRound - TOPRI == None");

				P.bNotPlaying = false;
				P.bAlreadyChangedTeam = false;

				RestartPlayer(PawnLink);

				P.bDead = false;

				//PawnLink.PlayerRestartState = PawnLink.Default.PlayerRestartState;

				PawnLink.SetPhysics(PHYS_None);
			}
			else
				RestartPlayer(PawnLink);
		}
	}

	ClearNPC();
	
	SetMoney();

	if ( ActorManager != None )
		ActorManager.RecoverAll();

	// Resetting triggers
	ForEach AllActors(class's_Trigger', sT)
		sT.ResetTrigger();

	// Resetting TacticalOpsMapActors
	ForEach AllActors(class'TacticalOpsMapActors', TOMA)
		TOMA.RoundReset();

	BeginRound();	
}


///////////////////////////////////////
// BeginRound
///////////////////////////////////////

function BeginRound()
{
	local		Pawn					P;
	local		s_Player			sP;
	local		s_Bot					B;
	local		float					temp;

	Escaped_Terr = 0;
	Escaped_SF = 0;
	bFirstKill = false;
	bBombDropped = false;
	PreRoundDelay = Default.PreRoundDuration1;
	s_GameReplicationInfo(GameReplicationInfo).bPreRound = true;

	if ( LocalLog != None )
		LocalLog.LogEventString(LocalLog.GetTimeStamp()$Chr(9)$"round_start"$Chr(9)$RoundNumber);
	if ( WorldLog != None )
		WorldLog.LogEventString(LocalLog.GetTimeStamp()$Chr(9)$"round_start"$Chr(9)$RoundNumber);

	// PreRound
	for ( P=Level.PawnList; P!=None; P=P.nextPawn )
	{
		sP = s_Player(P);
		B = s_Bot(P);

		if (sP != None )
		{
			if ( P.PlayerReplicationInfo.bWaitingPlayer )
				continue;

			sP.bNotPlaying = false;
			sP.GotoState('PreRound');
			ChangeModel(P, sP.PlayerModel);
			sP.CalculateWeight();
		}
		else if (B != None) 
		{
			if (!(B.GetStateName() == 'PreRound' || B.GetStateName() == 'BotBuying') )
				B.GotoState('PreRound');

			ChangeModel(P, B.PlayerModel);

			B.CalculateWeight();
		}
	}		

	// Adding hostages
	SetupHostages();

	WinAmount = Default.WinAmount;
	LostAmount = Default.LostAmount;

	// Objectives
	SetupObjectives();

	// Giving Bots orders.
	//InitRoundBotOrders();

	SpawnEvidence();
	SpawnSpecialItems();
	SpawnScriptedPawn();

	GamePeriod = GP_PreRound;
}


///////////////////////////////////////
// SetupObjectives
///////////////////////////////////////

final function SetupObjectives()
{
	local byte	i, j;

	bHostageRescueWin = false;
	bBombDefusion = false;
	bBombDefusionWin = false;
	bBombGiven = false;
	bBombPlanted = false;
	bC4Explodes = false;

	if ( SI != None )
	{
		// Ressetting objectives
		for (i = 0; i<10; i++)
		{
			SI.SF_ObjectivesPriv[i].bObjectiveAccomplished = false;
			SI.Terr_ObjectivesPriv[i].bObjectiveAccomplished = false;
			SI.SF_ObjectivesPriv[i].Leader = None;
			SI.Terr_ObjectivesPriv[i].Leader = None;

			// Hostage Rescue
			if ( !IsNullObjective(1, i) && (SI.SF_Objectives[i].ObjectiveType == O_SeekForHostages)
				&& SI.SF_Objectives[i].bWinRound )
				bHostageRescueWin = true;

			// Bomb defusion
			for (j = 0; j<2; j++)
			{
				if ( !IsNullObjective(j, i) && (SI.GetTeamObjectivePub(j, i).ObjectiveType == O_C4TargetLocation) )
				{
					bBombDefusion = true;
					//BombTeam = j;
					if ( SI.GetTeamObjectivePub(j, i).bWinRound )
						bBombDefusionWin = true;
				}
			}

		}
	}
	else
		log("SetupObjectives - SI == None !");

	// SBOMB
	// Give bomb.
	if ( bBombDefusion )
	{
		GiveBomb();
	}

}


///////////////////////////////////////
// GiveBomb
///////////////////////////////////////

function GiveBomb()
{
	local	Pawn	P, BestP;
	local	float	Score, BestScore;

	if ( bGivingBomb )
		return;

	bGivingBomb = true;
	BestScore = 0.0;
	for ( P=Level.PawnList; P!=None; P=P.nextPawn )
	{
		if ( (P.PlayerReplicationInfo.Team != 0) || ( P.PlayerReplicationInfo.bIsSpectator)
			|| (P.IsA('s_Player') && P.PlayerReplicationInfo.bWaitingPlayer) )
			continue;

		Score = FRand() * 2.0;

		// Make Players get the bomb more often than the bots.
		if ( P.IsA('s_Player') )
			Score += FRand();

		if ( Score > BestScore )
		{
			BestP = P;
			BestScore = Score;
		}
	}

	if ( BestP != None )
	{
		GiveWeapon(BestP, "s_SWAT.s_C4");
		bBombGiven = true;
	}
//	else
//		log("s_SWATGame::GiveBomb - Could not give bomb!");

	bGivingBomb = false;
}


///////////////////////////////////////
// SetAccomplishedObjective
///////////////////////////////////////

final function SetAccomplishedObjective(byte Team, byte number)
{
	local	Actor			A;
	local	bool			bothteams, bObjectivesCompleted, bPrioritaryCompleted, bPrioritary;
	local	s_Player	P;
	local	byte			i;

	if ( (Team > 1) || (number == 255) || (GamePeriod != GP_RoundPlaying) ) 
		return;

	// If Objective is already accomplished, return
	if ( !SI.GetTeamObjectivePub(Team, number).bToggle
		&& SI.GetTeamObjectivePriv(Team, number).bObjectiveAccomplished == true )
		return;
	//log("SetAccomplishedObjective - entering - T:"$Team$" num:"$number);

	if ( !SI.GetTeamObjectivePub(Team, number).bToggle )
		SI.SetAccomplishedObjective(Team, number, true);
	else
		SI.SetAccomplishedObjective(Team, number, !SI.GetTeamObjectivePriv(Team, number).bObjectiveAccomplished);

	// Broadcast trigger message to all matching actors
	if ( IsObjectiveAccomplished(Team, number) 
		&& (SI.GetTeamObjectivePub(Team, number).EventAccomplished != '') )
		foreach AllActors(class'Actor', A, SI.GetTeamObjectivePub(Team, number).EventAccomplished)
			A.Trigger(None, None);
/*		
	if (SI.GetTeamObjectivePub(Team, number).ObjectiveMeaning > 0)
	{
		bothteams = (SI.GetTeamObjectivePub(Team, number).ObjectiveMeaning > OM_TeamNotification);

		foreach allactors(class's_Player', P)
			if (P.PlayerReplicationInfo.Team == Team || (bothteams))
				P.ReceiveLocalizedMessage(class's_MessageObjective', SI.GetTeamObjectivePub(Team, number).ObjectiveType);
	}
*/
	// Check for end of round
	bPrioritary = false; // Check to see if there's any Prioritary objectives
	bObjectivesCompleted = true;
	bPrioritaryCompleted = true;
	i = 0;
	while ( i < 10 )
	{
		if ( !IsNullObjective(Team, i) )
		{
			if ( IsPrimaryObjective(team, i) && !bPrioritary )
				bPrioritary = true;

			if ( !IsObjectiveAccomplished(Team, i) )
			{
				// Found Objective not accomplished
				if ( IsPrimaryObjective(team, i) )
					bPrioritaryCompleted = false;
				bObjectivesCompleted = false;
			}
		}
		i++;
	}

	// OM_RoundWin Shortcut!
	if ( IsObjectiveAccomplished(Team, number) && SI.GetTeamObjectivePub(Team, number).bWinRound )
			bObjectivesCompleted = true;

	// Check for end of round
	if ( bObjectivesCompleted || (bPrioritary && bPrioritaryCompleted) )
	{
		if ( Team == 1 )
		{
			if ( SI.bShowDefaultWinMessages )
				BroadcastLocalizedMessage(class's_MessageRoundWinner', 9);
			SetWinner(1);
			EndGame("Special Forces win the round");
		}
		else
		{
			if ( SI.bShowDefaultWinMessages )
				BroadcastLocalizedMessage(class's_MessageRoundWinner', 10);
			SetWinner(0);
			EndGame("Terrorists win the round");
		}
	}

}


///////////////////////////////////////
// ObjectiveAccomplished
///////////////////////////////////////

final function ObjectiveAccomplished(actor Target)
{
	//log("TO_Game - ObjectiveAccomplished - Target: "$Target);
	if (Target.IsA('s_Trigger') || Target.IsA('TO_ConsoleTimer'))
	{
		SetObjectiveAccomplishedTarget(Target);
	}

}


///////////////////////////////////////
// SetObjectiveAccomplishedTarget
///////////////////////////////////////

final function SetObjectiveAccomplishedTarget(actor Target)
{
	local	byte	Team, number;

	//log("IsObjectiveTarget");
	for (Team = 0; Team < 2; Team++)
	{
		for (number = 0; number < 10; number++)
			if (SI.GetTeamObjectivePriv(Team, number).ActorTarget == Target )
				SetAccomplishedObjective(Team, number);
	}
}


///////////////////////////////////////
// C4Exploded
///////////////////////////////////////

final function C4Exploded( bool bExplodedInBombingZone, Actor BombingZone )
{
	local	byte	Team, number;

	if ( (SI == None) || (GamePeriod != GP_RoundPlaying) )
		return;

	//log("s_SWATGame::C4Exploded - bExplodedInBombingZone:"@bExplodedInBombingZone@"BombingZone:"@BombingZone);

	Team = 0;

	for (number=0; number<10; number++)
		if ( SI.GetTeamObjectivePub(Team, number).ObjectiveType == O_C4TargetLocation )
		{
			// Objective accomplished
			//if ( bExplodedInBombingZone )
			
			//log("s_SWATGame::C4Exploded - n:"@number@"AT:"@SI.GetTeamObjectivePriv(Team, number).ActorTarget);

			if ( ( BombingZone == None ) || (SI.GetTeamObjectivePriv(Team, number).ActorTarget ==  None)
				|| (SI.GetTeamObjectivePriv(Team, number).ActorTarget == BombingZone ) )
			{
				//log("s_SWATGame::C4Exploded - SetAccomplishedObjective T:"@Team@"n:"@number);
				BroadcastLocalizedMessage(class's_MessageRoundWinner', 10);
				SetAccomplishedObjective(Team, number);
				return;
			}

			// We currently only support winning when C4 explodes.
			/*
			else if ( SI.GetTeamObjectivePub(Team, number).bWinRound ) 
			{
				// Mission failed
	 			EndGame("Failed to place bomb");
		
				BroadcastLocalizedMessage(class'TO_MessageCustom', 0, None, None, SI);
				if ( SI.DefaultLooser != ET_Both )
				{
					WinAmount += SI.WinAmount;
					SetWinner( 1 - SI.DefaultLooser );
				}
			}
			*/
		}
	//log("s_SWATGame::C4Exploded - Could not set objective!");
}


///////////////////////////////////////
// C4Defused
///////////////////////////////////////

final function C4Defused( Actor Instigator )
{
	if ( GamePeriod != GP_RoundPlaying )
			return;
	
	if ( (Pawn(Instigator) != None) && (Pawn(Instigator).PlayerReplicationInfo != None) )
		BroadcastLocalizedMessage(class's_MessageRoundWinner', 13, Pawn(Instigator).PlayerReplicationInfo);

	WinAmount += SI.WinAmount;
	SetWinner( 1 );

	// Mission failed
	EndGame("Bomb defused");

	//if ( SI == None )
	//	return;

	/*
	if ( SI.DefaultLooser != ET_Both )
	{
		WinAmount += SI.WinAmount;
		SetWinner( 1 - SI.DefaultLooser );
	}
	*/
	// We currently force the Special Forces to win!

}



//
// Bot Objective code
//


///////////////////////////////////////
// CanAcceptObjective
///////////////////////////////////////
// This is used to force a bot to a special objective
// To prevent him from doing the default objectives if needed

final function bool CanAcceptObjective(s_Bot B)
{
	local byte tmp;
	local	Actor	A;

	// Bomb Planted, force Sf to disarm it
	if ( bBombPlanted )
	{

	}

	// Bomb dropped force bot to get it back
	if ( bBombDropped && (B.PlayerReplicationInfo.Team == 0) )
	{
		A = FindC4Dropped(B);
		if ( A != None )
		{
			B.Objective = 'O_GotoLocation';
			B.OrderObject = A;
			return false;			
		}
		else
		{
			// Problem. Bomb dropped, but actor cannot be found!
			log("s_SWATGame::CanAcceptObjective - Bomb dropped, but actor cannot be found!");
			bBombDropped = false;
		}
	}

	// Bot has C4 bomb!
	// So force him to plant it in bombing zone
	if ( (B.PlayerReplicationInfo.Team == 0) && TO_BRI(B.PlayerReplicationInfo).bHasBomb )
	{
		tmp = FindObjective(0, 'O_C4TargetLocation');
		if ( tmp != 255 )
		{
			B.Objective = 'O_C4TargetLocation';
			B.OrderObject = SI.GetTeamObjectivePriv(0, tmp).ActorTarget;
			return false;
		}
	}

	// Bot escorting hostage
	if ( B.HostageFollowing > 0 )
	{
		if ( B.PlayerReplicationInfo.Team == 0 )
		{
//			log("s_SWATGame::CanAcceptObjective -"@B.GetHumanName()@"- S:"@B.GetStateName()@"- Forced to bring back hostage to hiding point");

			// Terrorist
			B.Objective = 'O_GotoHostageHidingPoint';
			B.OrderObject = FindHostages(B);
		}
		else
		{
//			log("s_SWATGame::CanAcceptObjective -"@B.GetHumanName()@"- S:"@B.GetStateName()@"- Forced to bring back hostage to rescue zone");

			// Special Forces
			B.Objective = 'O_BringHostageHome';
			B.OrderObject = FindRescuePoint(B);
		}

		B.O_number = 255;
		return false;
	}

	return true;
}


///////////////////////////////////////
// DoesBotLead
///////////////////////////////////////
// Force bot to seek for objectives instead of supporting others

final function bool DoesBotLead(s_Bot B)
{
	// Bot has C4 bomb!
	// So force him to plant it in bombing zone
	if ( (B.PlayerReplicationInfo.Team == 0) && TO_BRI(B.PlayerReplicationInfo).bHasBomb )
		return true;

	return false;
}


///////////////////////////////////////
// SetNextObjective
///////////////////////////////////////
// Find an objective for a bot
final function SetNextObjective(s_Bot B)
{
	// Set Objectives to bots, based on Objectives' priorities
	local	byte			i, Team, numsupport, numleaders, numbots;
	local	s_Bot			Bl, BBot, BBotL;
	local	s_Bot			bot;
	local	float			Score, BestScore;
	local	s_Player	P, BP;
	local	bool			bTooManyLeaders;
	local	Pawn			PawnLink;

	//log("SetNextObjective - B.State - "$B.GetStateName());

	if ( (B.PlayerReplicationInfo == None) || (GamePeriod != GP_RoundPlaying) || B.bDoNotDisturb )
		return;

	if ( !CanAcceptObjective(B) )
		return;

	bTooManyLeaders = false;

	// Count leaders
	for ( PawnLink=Level.PawnList; PawnLink!=None; PawnLink=PawnLink.nextPawn )
	{
		BBotL = s_Bot(PawnLink);
		if (BBotL != None)
		{
			i++;
			if (i > 50)
				break;
			if (BBotL.PlayerReplicationInfo.Team == B.PlayerReplicationInfo.Team && !BBotL.bNotPlaying)
			{
				numbots++;
				if (BBotL.Orders == 'Freelance')
				{
					if (BBotL != B)
					{
						Score = FRand() * 100 + BBotL.Health * 100 + BBotL.Skill * 100;
						if (Score > BestScore)
							BBot = BBotL;
					}
					if (BBotL.Objective != 'O_DoNothing')
						numleaders++;
				}
				else if (BBotL.Orders == 'Follow')
					numsupport++;
			}
		}
	}

	if ( numleaders > (numbots * SI.LeaderThreshold) )
		bTooManyLeaders = true;

	// Do OrderObjectives first
	Team = B.PlayerReplicationInfo.Team;
	i = 0;
	while ( i < 10 )
	{
		if ( !IsNullObjective(Team, i) )
		{
			// Check leaders
			if ( SI.GetTeamObjectivePriv(Team, i).Leader != None )
/*				&& SI.GetTeamObjectivePriv(Team, i).Leader.IsA('s_Bot')
				&& !s_Bot(SI.GetTeamObjectivePriv(Team, i).Leader).bNotPlaying) */
			{
				// Check if leader is still on the objective
				bot = s_Bot(SI.GetTeamObjectivePriv(Team, i).Leader);

				if ( !Bot.bNotPlaying && (Bot.O_number != i) && ((Bot.LastObjective == '') || (Bot.LastO_number != i)) )
				{
					log("s_SWATGame::SetNextObjective - resetting leader:"@Bot.GetHumanName()@"-O:"@Bot.O_number@"-O:"@Bot.Objective);

					// Reset Objective leader
					if (Team == 1)
						SI.SF_ObjectivesPriv[i].Leader = None;
					else
						SI.Terr_ObjectivesPriv[i].Leader = None;

					ResetBotObjective(bot, 2.0);
				} 
				else if ( Bot.bNotPlaying || (Bot.PlayerReplicationInfo.Team != Team) )
				{
					// Reset Objective leader
					if (Team == 1)
						SI.SF_ObjectivesPriv[i].Leader = None;
					else
						SI.Terr_ObjectivesPriv[i].Leader = None;
				}
				else
				{
					// Still active objective leaders
					Score = FRand();
					if (Score > BestScore)
						Bl = s_Bot(SI.GetTeamObjectivePriv(Team, i).Leader);
				}
			}

			// If too many team leaders, continue and go to support
			if ( bTooManyLeaders && !DoesBotLead(B) )
			{
				i++;
				continue;
			}

			if ( !IsObjectiveAccomplished(Team, i) )
			{
				if (IsOrderObjective(Team, i) && CheckOrder(Team, i))
				{
					if (IsOnceObjective(Team, i) && SI.GetTeamObjectivePriv(Team, i).Leader == None)
					{ // Send bot to OnceOrder Objective
						SI.SetObjectiveLeader(Team, i, B);
						B.Objective = SI.GetTeamObjectiveName(Team, i);
						B.OrderObject = SI.GetTeamObjectivePriv(Team, i).ActorTarget;
						B.O_number = i;
						//log("assigned OnceOrder objective to: "$B$" - Objective: "$B.Objective$" - OrderObject: "$B.OrderObject$" - O_number: "$B.O_number);
						return;
					}
					if (!IsOnceObjective(Team, i) && (FRand() < 0.5))
					{ // Send bot to AlwaysOrder Objective
						//SI.SetObjectiveLeader(Team, i, B);
						B.Objective = SI.GetTeamObjectiveName(Team, i);
						B.OrderObject = SI.GetTeamObjectivePriv(Team, i).ActorTarget;
						B.O_number = i;
						//log("assigned AlwaysOrder objective to: "$B$" - Objective: "$B.Objective$" - OrderObject: "$B.OrderObject$" - O_number: "$B.O_number);
						return;					
					}
				}
				if (!IsOrderObjective(Team, i))
				{
					if (IsOnceObjective(Team, i) && SI.GetTeamObjectivePriv(Team, i).Leader == None)
					{ // Send bot to Once Objective
						SI.SetObjectiveLeader(Team, i, B);
						B.Objective = SI.GetTeamObjectiveName(Team, i);
						B.OrderObject = SI.GetTeamObjectivePriv(Team, i).ActorTarget;
						B.O_number = i;
						//log("assigned Once objective to: "$B$" - Objective: "$B.Objective$" - OrderObject: "$B.OrderObject$" - O_number: "$B.O_number);
						return;
					}
					if (!IsOnceObjective(Team, i) && (FRand() < 0.5))
					{ // Send bot to Always Objective
						//SI.SetObjectiveLeader(Team, i, B);
						B.Objective = SI.GetTeamObjectiveName(Team, i);
						B.OrderObject = SI.GetTeamObjectivePriv(Team, i).ActorTarget;
						B.O_number = i;					
						//log("assigned Always objective to: "$B$" - Objective: "$B.Objective$" - OrderObject: "$B.OrderObject$" - O_number: "$B.O_number);
						return;					
					}
				}
			}	
		}
		i++;
	}

	// If bot cannot get any objectives, then support a leader if any
	if ( !DoesBotLead(B) )
	{
		BestScore = 0;
		i = 0;

		for ( PawnLink=Level.PawnList; PawnLink!=None; PawnLink=PawnLink.nextPawn )
		{
			i++;
			if (i > 50)
				break;

			P = s_Player(PawnLink);
			if (P != None && P.PlayerReplicationInfo.Team == B.PlayerReplicationInfo.Team && !P.bNotPlaying)
			{
				Score = FRand() * P.Health * P.Skill;
				if (Score > BestScore)
					BP = P;
			}
		}
		
		if (numsupport < numplayers * 0.66 && FRand() < 0.50)
		{
			//log("SetNextObjective - Sent to Support");
			ResetBotObjective(B, 1.0);

			if (BP != None && FRand() < 0.33)
				B.SetOrders('Follow', BP, true);
			else if (Bl != None && Bl != B && FRand() < 0.33)
				B.SetOrders('Follow', Bl, true);
			else if (BBot != None && FRand() < 0.33)
				B.SetOrders('Follow', BBot, true);
			
			return;
		}
	}

	// Bot couldn't get any objective assigned!
	B.O_Count++;
//	if ( B.O_Count > 3 )
//	{
		//log("s_SWATGame::SetNextObjective - "@B.GetHumanName()@"couldn't get any objective - C:"@B.O_Count);
//	}
		

	//log("SetNextObjective - No objectives assigned");

	// Set bots to defense or attack.

}


///////////////////////////////////////
// SpecialObjectiveHandling
///////////////////////////////////////
// Handle special code depending on the objective

final function SpecialObjectiveHandling(s_Bot B)
{
	local	s_Trigger	T;

	// Objectives
	if (B.Objective == 'O_TriggerTarget' && B.OrderObject.IsA('s_Trigger') )
	{
		T = s_Trigger(B.OrderObject);
		// Optional s_Trigger Path Node
		if (T.TriggerSWATPathNode != None)
			B.OrderObject = T.TriggerSWATPathNode;
	}

	// Bot attitude
	if (B.Orders == 'Freelance' || B.Orders == 'Attack')
		B.bLeading = true;
	else
		B.bLeading = false;
}


///////////////////////////////////////
// FindSpecialAttractionFor
///////////////////////////////////////

function bool FindSpecialAttractionFor(Bot aBot)
{
	local		Actor									Nav, Best;
	local		s_HostageControlPoint	HNav;
	local		int										BestScore, Score;
	local		float									Dist;
	local		s_Bot									B;

	//return false;

	B = s_Bot(aBot);

	// Don't call this to often
	if ( (aBot.LastAttractCheck > Level.TimeSeconds) || (B == None) || (GamePeriod != GP_RoundPlaying) )
		return false;

	if ( B.IsInState('BotBuying') )
		return false;

	aBot.LastAttractCheck = Level.TimeSeconds + 1.5;
	//log("s_SWATGame::FindSpecialAttractionFor - "@B.GetHumanName()@"- S:"@B.GetStateName()@"- O:"@B.Objective);

	// Check if bot needs ammo
	if ( (B.Objective != 'O_FindClosestBuyPoint') 
		&& (B.Weapon != None) && (s_Weapon(B.Weapon) != None) && (s_Weapon(B.Weapon).bUseClip) && (B.bNeedAmmo) )
	{
		if (B.Money > 100) 
		{
			// No more ammo
			Best = FindBuyPoint(B);
			if (Best != None)
			{
				//log("Check if bot needs ammo");
				ResetBotObjective(B, 0.0);
				B.Objective = 'O_FindClosestBuyPoint';
				B.OrderObject = FindBuyPoint(B);
				return true;
			}
			else
				B.bNeedAmmo = false;
		}
		else
			B.bNeedAmmo = false;
	}


	// If bot supports another one, then do so
	if (aBot.Orders == 'Follow')
	{
		// Checking if leader is dead
		if ( (B.OrderObject != None && B.OrderObject.IsA('s_Player') && s_Player(B.OrderObject).bNotPlaying) 
		|| (B.OrderObject != None && B.OrderObject.IsA('s_Bot') && s_Bot(B.OrderObject).bNotPlaying) )
		{
			//log("FindSpecialAttractionFor - Leader is dead - Follow - Now go to Freelance !");
			ResetBotObjective(B, 1.0);
			return false;
		}
		return false;
	}

/*
	if (B.Orders == 'Attack')
	{
		if ((B.Enemy == None || B.Enemy == Self 
			|| (B.Enemy.IsA('s_Bot') && s_Bot(B.Enemy).bNotPlaying)
			|| (B.Enemy.IsA('s_Player') && s_Player(B.Enemy).bNotPlaying)
			) )
		{
			if (B.Enemy == None && FRand() < 0.3)
				ResetBotObjective(B, 0.0);
			else
				ResetBotObjective(B, 0.0);
		}
	}
*/

	// Assign new objective to bot !
	if ( (aBot.Orders == '') || ( B.Objective == 'O_DoNothing' && aBot.Orders == 'Freelance') ) 
	{
		//log("calling SetNextObjective ! "$B);
		SetNextObjective(B);
		if (B.Objective != 'O_DoNothing')
			SpecialObjectiveHandling(B);
	} 

	if (B.Objective == 'O_DoNothing' /*&& B.OrderObject == None*/) 
	{
		//if (B.MoveTarget == None && aBot.Orders != 'Freelance')
		//	ResetBotObjective(B, 0.0);
		return false;
	}

	Best = B.OrderObject;

	// Huge Objective list...
	switch (B.Objective)
	{
		// O_GoHome
		case 'O_GoHome' :	
			if (aBot.OrderObject != None && aBot.OrderObject.IsA('s_SWATPathNode'))
			{
				if ( NavigateSWATPathNode(B, s_SWATPathNode(aBot.OrderObject), Best) )
					Best = FindHomeBase(B);
			}
			else if (aBot.OrderObject != None && aBot.OrderObject.IsA('s_ZoneControlPoint'))
			{
				if ( NavigateActor(B, aBot.OrderObject, Best) )
				{
					// Objective accomplished
					if (IsOrderObjective(B.PlayerReplicationInfo.Team, B.O_number))
						SetAccomplishedObjective(B.PlayerReplicationInfo.Team, B.O_number);

					//log("O_GoHome - Objective accomplished");
					ResetBotObjective(B, 1.0);
					return false;
				}
			}
			else if (aBot.OrderObject == None)
			{
				Best = FindSWATPathNode(B);
				if (Best == None)
					Best = FindHomeBase(B);
			}
			break;

		// O_AssaultEnemy
		case 'O_AssaultEnemy' : 
			if (aBot.OrderObject != None && aBot.OrderObject.IsA('s_SWATPathNode'))
			{
				if ( NavigateSWATPathNode(B, s_SWATPathNode(aBot.OrderObject), Best) )
					Best = FindEnemyBase(B);
			}
			else if (aBot.OrderObject != None && aBot.OrderObject.IsA('s_ZoneControlPoint'))
			{
				if ( NavigateActor(B, aBot.OrderObject, Best) )
				{
					// Objective accomplished
					if (IsOrderObjective(B.PlayerReplicationInfo.Team, B.O_number))
						SetAccomplishedObjective(B.PlayerReplicationInfo.Team, B.O_number);

					//log("O_AssaultEnemy - Objective accomplished");
					ResetBotObjective(B, 2.0);
					return false;
				}
			}
			else if (aBot.OrderObject == None)
			{
				Best = FindSWATPathNode(B);
				if (Best == None)
					Best = FindEnemyBase(B);
			}
			break;
		
		// O_FindClosestBuyPoint
		case 'O_FindClosestBuyPoint' : 
			if (aBot.OrderObject != None && aBot.OrderObject.IsA('s_SWATPathNode'))
			{
				if ( NavigateSWATPathNode(B, s_SWATPathNode(aBot.OrderObject), Best) )
					Best = FindBuyPoint(B);
			}
			else if (aBot.OrderObject != None && aBot.OrderObject.IsA('s_ZoneControlPoint'))
			{
				if ( NavigateActor(B, aBot.OrderObject, Best) )
				{
					// Objective accomplished
					if (IsOrderObjective(B.PlayerReplicationInfo.Team, B.O_number))
						SetAccomplishedObjective(B.PlayerReplicationInfo.Team, B.O_number);	

					//log("O_FindClosestBuyPoint - Objective accomplished");
					ResetBotObjective(B, 1.0);
					B.LetsGetLoaded();
					return true;
				}
			}
			else if (aBot.OrderObject == None)
			{
				Best = FindSWATPathNode(B);
				if (Best == None)
					Best = FindBuyPoint(B);	
			}
			break;
		
		// O_SeekForHostages
		case 'O_SeekForHostages' : 
			if (aBot.OrderObject != None && aBot.OrderObject.IsA('s_SWATPathNode'))
			{
				if ( NavigateSWATPathNode(B, s_SWATPathNode(aBot.OrderObject), Best) )
					Best = FindHostages(B);
			}
			else if (aBot.OrderObject != None && aBot.OrderObject.IsA('s_ZoneControlPoint'))
			{
				if ( NavigateActor(B, aBot.OrderObject, Best) )
				{
					//log("s_SWATGame::FindSpecialAttractionFor:O_SeekForHostages -"@B.GetHumanName()@"- Went to hiding point");

					/*if (IsOrderObjective(B.PlayerReplicationInfo.Team, B.O_number))
					{
						// Objective accomplished
						SetAccomplishedObjective(B.PlayerReplicationInfo.Team, B.O_number);
					}*/
					//log("O_SeekForHostages - objective accomplished");
					ResetBotObjective(B, 1.0);
					return false;
				}
			}
			else if (aBot.OrderObject == None)
			{
				Best = FindSWATPathNode(B);
				if (Best == None)
					Best = FindHostages(B);
			}
			break;
		
		// O_GotoLocation
		case 'O_GotoLocation' : 
			if (aBot.OrderObject != None && aBot.OrderObject.IsA('s_SWATPathNode'))
			{
				if ( NavigateSWATPathNode(B, s_SWATPathNode(aBot.OrderObject), Best) )
				{
					//log("O_GotoLocation - last path node reached !");
					// Objective accomplished
					if (IsOrderObjective(B.PlayerReplicationInfo.Team, B.O_number))						
						SetAccomplishedObjective(B.PlayerReplicationInfo.Team, B.O_number);		

					//log("O_GotoLocation - Objective accomplished");
					ResetBotObjective(B, 1.0);
					return false;
				}
			}
			else if (aBot.OrderObject == None)
				// Try to find PathNode
				Best = FindSWATPathNode(B);
			else 
			{ // Goto Target location
				if ( NavigateActor(B, aBot.OrderObject, Best) )
				{
					// Objective accomplished
					if (IsOrderObjective(B.PlayerReplicationInfo.Team, B.O_number))						
						SetAccomplishedObjective(B.PlayerReplicationInfo.Team, B.O_number);		

					//log("O_GotoLocation - Target Objective accomplished");
					ResetBotObjective(B, 1.0);
					return false;
				}
			}
				// Goto Target location
				//Best = aBot.OrderObject;
			break;
		
		// O_TriggerTarget
		case 'O_TriggerTarget' : 
			if (aBot.OrderObject != None && aBot.OrderObject.IsA('s_SWATPathNode'))
			{
				if ( NavigateSWATPathNode(B, s_SWATPathNode(aBot.OrderObject), Best) )
				{
					if (B.O_number == 255)
					{
						//log("O_TriggerTarget - Target pathnode");
						ResetBotObjective(B, 1.0);
						return false;
					}
					else if (SI.GetTeamObjectivePriv(B.PlayerReplicationInfo.Team, B.O_number).ActorTarget.IsA('Triggers'))
						Best = SI.GetTeamObjectivePriv(B.PlayerReplicationInfo.Team, B.O_number).ActorTarget;
				}
			}
			else if (aBot.OrderObject == None)
				// Try to find PathNode
				Best = FindSWATPathNode(s_Bot(aBot));
			else 
			{ // Goto Target location
				if ( NavigateActor(B, aBot.OrderObject, Best) )
				{
					if (aBot.OrderObject.IsA('s_Trigger'))
					{
						if (s_Trigger(aBot.OrderObject).TriggerType == TT_Use)
						{
							//log("O_TriggerTarget - s_Trigger Use "$B);
							s_Trigger(aBot.OrderObject).Use(aBot);

							// Objective accomplished
							// Coded in s_Trigger	
							ResetBotObjective(B, 1.0);
							return false;
						}
						else if (Dist < 60)
						{
							//log("O_TriggerTarget - s_Trigger - Close enough "$B);
							ResetBotObjective(B, 0.0);
							return false;
						}
						else
							// Goto Target location
							Best = aBot.OrderObject;
					}
					else if (Dist < 60)
					{
						//log("O_TriggerTarget - Trigger - Close enough "$B);
						ResetBotObjective(B, 1.0);
						return false;
					}
					else
						// Goto Target location
						Best = aBot.OrderObject;
				}
			}
			break;
		
		// O_BringHostageHome (Special Forces)
		case 'O_BringHostageHome' : 
			if (aBot.OrderObject != None)
			{ // Goto location
				if ( NavigateActor(B, aBot.OrderObject, Best) )
				{
					//log("s_SWATGame::FindSpecialAttractionFor:O_BringHostageHome -"@B.GetHumanName()@"- Went to rescue zone");

					ResetBotObjective(B, 2.0);
					return false;
				}
			}
			else
				Best = FindRescuePoint(B);
			break;
		
		// O_GotoHostage (Both)
		case 'O_GotoHostage' : 
			if ( (aBot.OrderObject != None) && B.OrderObject.IsA('s_NPCHostage'))
			{ // Goto location
				if ( NavigateActor(B, aBot.OrderObject, Best) )
				{
					if (B.PlayerReplicationInfo.Team == 1)
					{ // Special Forces
						//log("s_SWATGame::FindSpecialAttractionFor:O_GotoHostage -"@B.GetHumanName()@"- Bring hostage to rescue zone");

						RescueHostage(B, s_NPCHostage(B.OrderObject));
						B.Objective = 'O_BringHostageHome';
						B.OrderObject = FindRescuePoint(B);
						B.O_number = 255;
						//return true;
					}
					else if ( B.PlayerReplicationInfo.Team == 0 )
					{ // Terrorists
						if ( s_NPCHostage(B.OrderObject).bIsFree )
						{ // Free
							if ( IsCloseToHidingPoint(B.OrderObject) )
							{
								//log("s_SWATGame::FindSpecialAttractionFor::O_GotoHostage -"@B.GetHumanName()@"- T locks hostage");

								LockHostage(B, s_NPCHostage(B.OrderObject));
								if ( B.Orders == 'Freelance' )
									ClearBotObjective(B);
								else
									ResetBotObjective(B, 1.0);
								return false;
							}
							else if ( B.Objective != 'O_GotoHostageHidingPoint' )
							{
								//log("s_SWATGame::FindSpecialAttractionFor::O_GotoHostage -"@B.GetHumanName()@"- T brings hostage to hiding point");

								TerrEscortHostage(B, s_NPCHostage(B.OrderObject));
								B.Objective = 'O_GotoHostageHidingPoint';
								B.OrderObject = FindHostages(B);
								B.O_number = 255;
								//return true;
							}
						}
						else
						{ // Locked
							if ( IsCloseToHidingPoint(B.OrderObject) )
							{
								//log("s_SWATGame::FindSpecialAttractionFor::O_GotoHostage -"@B.GetHumanName()@"- Hostage locked");

								if (B.Orders == 'Freelance')
									ClearBotObjective(B);
								else
									ResetBotObjective(B, 1.0);
								return false;
							}
							else if (B.Objective != 'O_GotoHostageHidingPoint')
							{
								//log("s_SWATGame::FindSpecialAttractionFor::O_GotoHostage -"@B.GetHumanName()@"- T moves toward hostage, to escort him to hiding point");

								TerrEscortHostage(B, s_NPCHostage(B.OrderObject));
								B.Objective = 'O_GotoHostageHidingPoint';
								B.OrderObject = FindHostages(B);
								B.O_number = 255;
								//return true;
							}
						}
					}
				}
			}
			break;
		
		// O_GotoHostageHidingPoint (Terrorist)
		case 'O_GotoHostageHidingPoint' : 
			if (aBot.OrderObject != None)
			{ // Goto location
				if ( NavigateActor(B, aBot.OrderObject, Best) )
				{
					//log("s_SWATGame::FindSpecialAttractionFor::O_GotoHostageHidingPoint -"@B.GetHumanName()@"- went to HidingPoint");

					//LockHostage(B, s_NPCHostage(B.OrderObject));
					ResetBotObjective(B, 3.0);
					return false;
				}
			}
			else
				Best = FindRescuePoint(B);
			break;

		// O_CollectSpecialItem 
		case 'O_CollectSpecialItem' : 
			if (aBot.OrderObject != None)
			{ // Goto location
				if ( NavigateActor(B, aBot.OrderObject, Best) )
				{
					ResetBotObjective(B, 1.0);
					return false;
				}
			}
			else
				Best = FindSpecialItem(B);
			break;

		// O_Escape
		case 'O_Escape' :  
			if (aBot.OrderObject != None)
			{ // Goto location
				if ( NavigateActor(B, aBot.OrderObject, Best) )
				{
					ResetBotObjective(B, 5.0);
					return false;
				}
			}
			else
				Best = FindEscapeZone(B);
			break;

		// O_CollectEvidence 
		case 'O_CollectEvidence' : 
			if (aBot.OrderObject != None)
			{ // Goto location
				if ( NavigateActor(B, aBot.OrderObject, Best) )
				{
					ResetBotObjective(B, 2.0);
					return false;
				}
			}
			else
				Best = FindEvidence(B);
			break;

		// O_C4TargetLocation 
		case 'O_C4TargetLocation' : 
			if (aBot.OrderObject != None)
			{ // Goto location
				if ( NavigateActor(B, aBot.OrderObject, Best) )
				{
					// Bot has bomb, so plant it!
					if ( (B.PlayerReplicationInfo.Team == 0) && TO_BRI(B.PlayerReplicationInfo).bHasBomb )
					{
						ResetBotObjective(B, 1.0);
						B.PlantC4Bomb();
					}
					else
						ResetBotObjective(B, 2.0);
					return false;
				}
			}
			else
				Best = FindC4TargetLocation(B);
			break;

		// O_ActivateTO_ConsoleTimer
		case 'O_ActivateTO_ConsoleTimer' : 
			if (TO_ConsoleTimerPN(aBot.OrderObject) != None)
			{ // Goto Target location
				//log("s_SWATGame::FindSpecialAttractionFor - O_ActivateTO_ConsoleTimer - moving toward CT:"$B.GetHumanName());
				if ( NavigateActor(B, aBot.OrderObject, Best) )
				{
					//log("s_SWATGame::FindSpecialAttractionFor - O_ActivateTO_ConsoleTimer - Activated by:"$B.GetHumanName());
					Best = TO_ConsoleTimerPN(aBot.OrderObject).CTActor;
					ResetBotObjective(B, 1.0);
					B.UseConsoleTimer( TO_ConsoleTimer(Best) );
					//Best = None;
					return false;
				}
			}
			else
			{
				log("s_SWATGame::FindSpecialAttractionFor - O_ActivateTO_ConsoleTimer - Finding BEST:"$B.GetHumanName());
				Best = FindTOConsoleTimer(B);
			}
			break;

		// O_DefuseC4
		case 'O_DefuseC4' : 
			if ( s_ExplosiveC4(aBot.OrderObject) != None )
			{ // Goto C4 location
				//log("s_SWATGame::FindSpecialAttractionFor - O_DefuseC4 - moving toward C4:"$B.GetHumanName());
				if ( NavigateActor(B, aBot.OrderObject, Best) )
				{
					//log("s_SWATGame::FindSpecialAttractionFor - O_ActivateTO_ConsoleTimer - Activated by:"$B.GetHumanName());
					Best = aBot.OrderObject;
					ResetBotObjective(B, 1.0);
					B.DefuseC4( s_ExplosiveC4(Best) );
					//Best = None;
					return false;
				}
			}
			else
			{
				log("s_SWATGame::FindSpecialAttractionFor - O_DefuseC4 - Finding BEST:"$B.GetHumanName());
				Best = FindC4Explosive(B);
			}
			break;


	}


	// Checking if destination is reachable
	if ( Best != None )
	{
		BotReplicationInfo(aBot.PlayerReplicationInfo).OrderObject = None;
		aBot.OrderObject = Best;
		if ( VSize(Best.Location - aBot.Location) < (DistReachThreshold / 2) )
		{
			aBot.OrderObject = None;
			return false;
		}
		else if ( aBot.ActorReachable(Best) )
			aBot.MoveTarget = Best;
		else
			aBot.MoveTarget = aBot.FindPathToward(Best);

		if ( aBot.MoveTarget != None )
		{
			if ( aBot.bVerbose )
				log(aBot$" moving toward "$Best$" using "$aBot.MoveTarget);

			SetAttractionStateFor(aBot);
			return true;
		}
		else 
		{
			//log("s_SWATGame::FindSpecialAttractionFor - MoveTarget == None, resetting bot: "$B.GetHumanName()$" O:"$B.Objective$" I:"$B.O_number$" T:"$B.PlayerReplicationInfo.Team$" E:"$B.Enemy$" O:"$B.Orders);
			B.bNeedAmmo = false;
			ResetBotObjective(B, 2.0);
		}
	}
	else
	{
		// maybe for bot to camp or go to random location.
		//log("s_SWATGame::FindSpecialAttractionFor -"@B.GetHumanName()@"- Best == None");
		if (B.Objective != 'O_DoNothing' || B.MoveTarget != None)
		{
			//log("s_SWATGame::FindSpecialAttractionFor - Best == None, resetting bot "$B.GetHumanName()$" O:"$B.Objective$" I:"$B.O_number$" T:"$B.PlayerReplicationInfo.Team$" E:"$B.Enemy$" O:"$B.Orders);
			ResetBotObjective(B, 2.0);
		}
	}


	return false;
}


///////////////////////////////////////
// BotHasEnemy
///////////////////////////////////////

final function bool BotHasEnemy(s_Bot B)
{
	if (B.Enemy != None 
				&& B.Enemy.IsA('Pawn')
				&& B.Enemy.PlayerReplicationInfo.Team != B.PlayerReplicationInfo.Team
				&& !B.Enemy.IsA('s_NPC'))
		return true;

	return false;
}


///////////////////////////////////////
// BotHasMission
///////////////////////////////////////

final function bool BotHasMission(s_Bot B)
{
	return (B.Objective != 'O_DoNothing');
}


///////////////////////////////////////
// BotHasObjective
///////////////////////////////////////

final function bool BotHasObjective(s_Bot B)
{
	return (B.Objective != 'O_DoNothing' && B.O_number != 255);
}


///////////////////////////////////////
// SendGlobalBotObjective
///////////////////////////////////////

final function SendGlobalBotObjective( Actor Target, float DesiredAssignment, byte team, name ObjectiveType, bool bLeadersOnly)
{
	local	Pawn	P;
	local	s_Bot	B;
	
	for ( P=Level.PawnList; P!=None; P=P.nextPawn )
	{
		B = s_Bot(P);
		if ( B != None )
		{
			if ( ((team == 2) || (B.PlayerReplicationInfo.Team == team)) && (FRand() < DesiredAssignment) )
			{
				if ( !bLeadersOnly || BotHasObjective(B) )
				{
					if ( (B.Objective != ObjectiveType) && !B.bDoNotDisturb )
					{
						ClearBotObjective(B);
						B.Objective = ObjectiveType;
						B.O_number = 255;
						B.OrderObject = Target;
					}
				}
			}
		}
	}
}


///////////////////////////////////////
// NavigateActor
///////////////////////////////////////

final function bool NavigateActor(s_Bot B, Actor A, out Actor Best)
{
	local		float	Dist;

	Dist = VSize(A.Location - B.Location);
	if ( Dist < DistReachThreshold )
		return true;
	else
		Best = A;

	return false;
}


///////////////////////////////////////
// NavigateSWATPathNode
///////////////////////////////////////

final function bool NavigateSWATPathNode(s_Bot B, s_SWATPathNode SPN, out Actor Best)
{
	local	float	Dist;

	Dist = VSize(SPN.Location - B.Location);
	if ( Dist < DistReachThreshold )
	{
		if ( IsLastSWATPathNode(SPN) )
			return true;
		else
			Best = FindNextSWATPathNode(B, SPN );
	}
	else
		Best = SPN;

	return false;
}


///////////////////////////////////////
// FindNextSWATPathNode
///////////////////////////////////////

final function s_SWATPathNode FindNextSWATPathNode(s_Bot B, s_SWATPathNode SPN)
{
	local int		i;
	local	float	score, bestscore;
	local	s_SWATPathNode	BestSPN;

	if (SPN == None)
		return None;

	for (i=0; i<8; i++)
	{
		if ( (SPN.NextNavPoint[i] != None) && (SPN.NextNavPoint[i] != SPN) 
			/*&& VSize(SPN.NextNavPoint[i].location - SPN.Location) > DistReachThreshold */
			&& BotCanReachTarget(B, SPN.NextNavPoint[i]) )
		{
			//log("FindNextSWATPathNode - found: "$
			Score = FRand();
			if (Score > BestScore)
			{
				BestScore = Score;
				BestSPN = SPN.NextNavPoint[i];
			}
		}
	}
	//log("FindNextSWATPathNode - found :"$BestSPN.Tag$" - "$BestSPN);

	return BestSPN;
}


///////////////////////////////////////
// IsLastSWATPathNode
///////////////////////////////////////

final function bool IsLastSWATPathNode(s_SWATPathNode SPN)
{
	local int	i;

	if (SPN.bLastOne)
		return true;

	for (i=0; i<8; i++)
	{
		if (SPN.NextNavPoint[i] != None)
			return false;
	}
	return true;
}


///////////////////////////////////////
// FindSWATPathNode
///////////////////////////////////////

final function NavigationPoint FindSWATPathNode(s_Bot aBot)
{
	local	s_SWATPathNode	SPN;
	local	Actor	A;

	if (aBot.O_number == 255 || aBot.PlayerReplicationInfo == None)
		return None;

	A = SI.GetTeamObjectivePriv(aBot.PlayerReplicationInfo.Team, aBot.O_number).ActorTarget;
	if ( A != None && A.IsA('s_SWATPathNode') )
		 SPN = s_SWATPathNode(A);
	else
		return None;

//	return GetClosestSPN(aBot, SPN);
}


///////////////////////////////////////
// GetClosestSPN
///////////////////////////////////////

final function NavigationPoint GetClosestSPN(s_Bot aBot, s_SWATPathNode SPN)
{
	// Enhance to get the closest pathnode to the bot
	return SPN;
}


///////////////////////////////////////
// IsNullObjective
///////////////////////////////////////

final function bool	IsNullObjective(byte Team, byte ObjectiveNum)
{
	if ( (ObjectiveNum == 255) || (SI == None) )
		return false;

	if (SI.GetTeamObjectivePub(Team, ObjectiveNum).ObjectiveType == O_DoNothing
		|| SI.GetTeamObjectivePub(Team, ObjectiveNum).ObjectivePriority == OP_None)
		return true;
	else
		return false;
}



///////////////////////////////////////
// IsPrimaryObjective
///////////////////////////////////////

final function bool	IsPrimaryObjective(byte Team, byte ObjectiveNum)
{
	if (SI == None)
	{
		log("s_SWATGame - IsPrimaryObjective - SI == None");
		return false;
	}
	if (ObjectiveNum == 255)
		return false;

	if (Team == 1)
	{
		if (SI.SF_Objectives[ObjectiveNum].ObjectivePriority != 0 
			&& SI.SF_Objectives[ObjectiveNum].ObjectivePriority % 2 == 0)
			return true;
		else
			return false;
	}
	else
	{
		if (SI.Terr_Objectives[ObjectiveNum].ObjectivePriority != 0 
			&& SI.Terr_Objectives[ObjectiveNum].ObjectivePriority % 2 == 0)
			return true;
		else
			return false;
	}
}


///////////////////////////////////////
// IsOrderObjective
///////////////////////////////////////

final function bool	IsOrderObjective(byte Team, byte ObjectiveNum)
{
	if (SI == None)
	{
		log("s_SWATGame - IsPrimaryObjective - SI == None");
		return false;
	}

	if (ObjectiveNum == 255)
		return false;

	if (Team == 1)
	{
		if (SI.SF_Objectives[ObjectiveNum].ObjectivePriority == OP_AlwaysOrder 
			|| SI.SF_Objectives[ObjectiveNum].ObjectivePriority == OP_AlwaysOrderPrioritary
			|| SI.SF_Objectives[ObjectiveNum].ObjectivePriority == OP_OnceOrder
			|| SI.SF_Objectives[ObjectiveNum].ObjectivePriority == OP_OnceOrderPrioritary)
			return true;
		else
			return false;
	}
	else
	{
		if (SI.Terr_Objectives[ObjectiveNum].ObjectivePriority == OP_AlwaysOrder 
			|| SI.Terr_Objectives[ObjectiveNum].ObjectivePriority == OP_AlwaysOrderPrioritary
			|| SI.Terr_Objectives[ObjectiveNum].ObjectivePriority == OP_OnceOrder
			|| SI.Terr_Objectives[ObjectiveNum].ObjectivePriority == OP_OnceOrderPrioritary)
			return true;
		else
			return false;
	}
}


///////////////////////////////////////
// IsOnceObjective
///////////////////////////////////////

final function bool	IsOnceObjective(byte Team, byte ObjectiveNum)
{
	if (SI == None)
	{
		log("s_SWATGame - IsOnceObjective - SI == None");
		return false;
	}

	if (ObjectiveNum == 255)
		return false;

	if (Team == 1)
		return (SI.SF_Objectives[ObjectiveNum].ObjectivePriority > OP_AlwaysOrderPrioritary); 
	else
		return (SI.Terr_Objectives[ObjectiveNum].ObjectivePriority > OP_AlwaysOrderPrioritary); 
}


///////////////////////////////////////
// CheckOrder
///////////////////////////////////////
// Returns 'True' if current OrderObjective can be accomplished

final function bool	CheckOrder(byte Team, byte ObjectiveNum)
{
	local	int	j;

	//log("CheckOrder - Team: "$Team$" - ObjectiveNum: "$ObjectiveNum);
	j = 0;
	while (j < ObjectiveNum)
	{
		if (!IsNullObjective(Team, j) && IsOrderObjective(Team, j) && !IsObjectiveAccomplished(Team, j) )
		{
			//log("CheckOrder - Found other objective to assign first: "$j);
			return false;
		}
		j++;
	}
	//log("CheckOrder - Order is fine");
	return true;
}


///////////////////////////////////////
// FindObjective
///////////////////////////////////////
// Find a specific AVAILABLE objective 
// returns its index, 255 otherwise.
final function	byte	FindObjective(byte Team, name ObjectiveType)
{
	local	int	j;
	local	float	score, bestscore;
	local	byte	bestidx;

	j = 0;
	bestidx = 255;
	bestscore = 0.0;

	while ( j < 10 )
	{
		if ( !IsNullObjective(Team, j) && (SI.GetTeamObjectiveName(Team, j) == ObjectiveType) 
			&& !IsObjectiveAccomplished(Team, j) )
		{
			// Once
			if ( IsOnceObjective(Team, j) )
			{
				if ( SI.GetTeamObjectivePriv(Team, j).Leader == None )
				{
					// Order
					if ( IsOrderObjective(Team, j) )
					{
						if ( CheckOrder(Team, j) )
						{
							score = FRand();
							if ( score > bestscore )
							{
								bestscore = score;
								bestidx = j;
							}
						}
					}
					else 
					{
						score = FRand();
						if ( score > bestscore )
						{
							bestscore = score;
							bestidx = j;
						}
					}
				}
			}
			// Always
			else 
			{
				// Order
				if ( IsOrderObjective(Team, j) )
				{
					if ( CheckOrder(Team, j) )
					{
						score = FRand();
						if ( score > bestscore )
						{
							bestscore = score;
							bestidx = j;
						}
					}
				}
				else 
				{
					score = FRand();
					if ( score > bestscore )
					{
						bestscore = score;
						bestidx = j;
					}
				}
			}
		}

		j++;
	}

	return bestidx;
}						


///////////////////////////////////////
// IsObjectiveAccomplished
///////////////////////////////////////

final function bool	IsObjectiveAccomplished(byte Team, byte num)
{
	if (SI.GetTeamObjectivePub(Team, num).bToggle)
	{
		if (SI.GetTeamObjectivePriv(Team, num).bObjectiveAccomplished == SI.GetTeamObjectivePub(Team, num).bToggleTo)
			return true;
	}
	else if (SI.GetTeamObjectivePriv(Team, num).bObjectiveAccomplished == true)
		return true;

	return false;
}


//
// Misc code
//

/* 
///////////////////////////////////////
// ResetMovers
///////////////////////////////////////

function ResetMovers()
{
	local Mover m;
	local actor A;

	foreach allactors(class'mover', m)
	{
		if (m.IsInState('TriggerControl'))
		{
			m.numTriggerEvents = 0;
			m.DoClose();
			m.GotoState(m.InitialState);
			m.BeginPlay();
			m.PostBeginPlay();
			m.InterpolateTo(0,0.01);
		}
	}
}
*/

///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     DistReachThreshold=80
     bReduceSFX=True
     TimeLimit=25
}
