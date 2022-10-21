//=============================================================================
// TO_TeamGamePlus
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class TO_TeamGamePlus extends TO_DeathMatchPlus
	config
	abstract;


var								int		NumSupportingPlayer; 
var globalconfig	bool	bBalanceTeams;				// bots balance teams
var globalconfig	bool	bPlayersBalanceTeams;	// players balance teams
var								bool	bBalancing;
var() config			float FriendlyFireScale;		//scale friendly fire damage by this value
var() config			int		MaxTeams;							//Maximum number of teams allowed in (up to MaxAllowedTeams)
var								int		MaxAllowedTeams;
var								TeamInfo Teams[4];					// Red, Blue, Green, Gold
var() config			int		MaxTeamSize;
var localized string StartUpTeamMessage, TeamChangeMessage, TeamPrefix;
var localized string TeamColor[4];

var	int		NextBotTeam;
var byte	TEAM_Red, TEAM_Blue, TEAM_Green, TEAM_Gold;
var name	CurrentOrders[4];
var int		PlayerTeamNum;


function PlayStartUpMessage(PlayerPawn NewPlayer) {	bRequireReady = false; }


///////////////////////////////////////
// PostBeginPlay()
///////////////////////////////////////

function PostBeginPlay()
{
	local int i;
	for (i=0; i<4; i++)
	{
		Teams[i] = Spawn(class'TeamInfo');
		Teams[i].Size = 0;
		Teams[i].Score = 0;
		Teams[i].TeamName = TeamColor[i];
		Teams[i].TeamIndex = i;
		TournamentGameReplicationInfo(GameReplicationInfo).Teams[i] = Teams[i];
	}
	
	Super.PostBeginPlay();

	if ( bRatedGame )
	{
		FriendlyFireScale = 0;
		MaxTeams = 2;
	}
}


///////////////////////////////////////
// InitGame()
///////////////////////////////////////

event InitGame( string Options, out string Error )
{
	Super.InitGame(Options, Error);
	MaxTeams = Min(MaxTeams, MaxAllowedTeams);
}


///////////////////////////////////////
// InitRatedGame()
///////////////////////////////////////
// Set game settings based on ladder information.
// Called when RatedPlayer logs in.

function InitRatedGame(LadderInventory LadderObj, PlayerPawn LadderPlayer)
{
	local class<RatedMatchInfo> RMI;
	local Weapon W;

	Super.InitRatedGame(LadderObj, LadderPlayer);	
	bCoopWeaponMode = true;
	FriendlyFireScale = 0.0;
	MaxTeams = 2;
	ForEach AllActors(class'Weapon', W)
		W.SetWeaponStay();
}


///////////////////////////////////////
// CheckReady()
///////////////////////////////////////

function CheckReady()
{
	if ( TimeLimit == 0)
	{
		TimeLimit = 20;
		RemainingTime = 60 * TimeLimit;
	}
}

/*
///////////////////////////////////////
// PostLogin()
///////////////////////////////////////

event PostLogin( playerpawn NewPlayer )
{
	Super.PostLogin(NewPlayer);

//	if ( Level.NetMode != NM_Standalone )
//		NewPlayer.ClientChangeTeam(NewPlayer.PlayerReplicationInfo.Team);
}
*/

///////////////////////////////////////
// LogGameParameters()
///////////////////////////////////////

function LogGameParameters(StatLog StatLog)
{
	if (StatLog == None)
		return;
	
	Super.LogGameParameters(StatLog);

	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"FriendlyFireScale"$Chr(9)$FriendlyFireScale);
}


//------------------------------------------------------------------------------
// Player start functions


///////////////////////////////////////
// Login
///////////////////////////////////////

function playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local PlayerPawn			newPlayer;
	local NavigationPoint StartSpot;
	local String					InFace, InPassword, InSkin;
	local byte						InTeam;

	SpawnClass = class's_Player_T';
	bRequireReady = false;
	newPlayer = Super.Login(Portal, Options, Error, SpawnClass);

	if ( NewPlayer == None )
	{
		Error = "Couldn't spawn player.";
		return None;
	}

	if ( Left(NewPlayer.PlayerReplicationInfo.PlayerName, 6) == DefaultPlayerName )
	{
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogSpecialEvent("forced_name_change", NewPlayer.PlayerReplicationInfo.PlayerName, NewPlayer.PlayerReplicationInfo.PlayerID, DefaultPlayerName$NumPlayers);
		ChangeName( NewPlayer, (DefaultPlayerName$NumPlayers), false );
	}

	NewPlayer.bAutoActivate = true;
	/*
	if ( (bGameEnded || (bRequireReady && (CountDown > 0))) && !NewPlayer.IsA('Spectator') )
		NewPlayer.PlayerRestartState = 'PlayerWaiting';
	else
		NewPlayer.PlayerRestartState = NewPlayer.Default.PlayerRestartState;
	*/

	//if ( NewPlayer.IsA('TournamentPlayer') )
	//		TournamentPlayer(NewPlayer).StartSpot = LastStartSpot;

	/*
	StartSpot = FindPlayerStart(NewPlayer, newPlayer.PlayerReplicationInfo.Team);

	if (StartSpot == None)
	{
		Error = "Couldn't find player start";
		Return None;
	}

	if ( StartSpot != None )
	{
		NewPlayer.SetLocation(StartSpot.Location);
		NewPlayer.SetRotation(StartSpot.Rotation);
		NewPlayer.ViewRotation = StartSpot.Rotation;
		NewPlayer.ClientSetRotation(NewPlayer.Rotation);
	}
	*/
	// Init player's replication info
	NewPlayer.GameReplicationInfo = GameReplicationInfo;

	PlayerTeamNum = NewPlayer.PlayerReplicationInfo.Team;

	return newPlayer;
}


///////////////////////////////////////
// Logout()
///////////////////////////////////////

function Logout(pawn Exiting)
{
	//if ( Exiting.IsA('Spectator') )
	//	return;

	if ( Exiting.PlayerReplicationInfo.Team < 4 )
		Teams[Exiting.PlayerReplicationInfo.Team].Size--;
	
	ClearOrders(Exiting);

	Super.Logout(Exiting);

	if ( !bGameEnded && bBalanceTeams && !bRatedGame )
		ReBalance();
}


///////////////////////////////////////
// FindTeamByName()
///////////////////////////////////////
// Find a team given its name

function byte FindTeamByName( string TeamName )
{
	local byte i;

	for ( i=0; i<MaxTeams; i++ )
		if ( Teams[i].TeamName == TeamName )
			return i;

	return 255; // No Team
}


///////////////////////////////////////
// ReBalance()
///////////////////////////////////////
// rebalance teams after player changes teams or leaves
// find biggest and smallest teams.  If 2 apart, move bot from biggest to smallest

function ReBalance()
{
	local int big, small, i, bigsize, smallsize;
	local Pawn P, A;
	local Bot B;

	if ( bBalancing || (NumBots == 0) )
		return;

	big = 0;
	small = 0;
	bigsize = Teams[0].Size;
	smallsize = Teams[0].Size;
	for ( i=1; i<MaxTeams; i++ )
	{
		if ( Teams[i].Size > bigsize )
		{
			big = i;
			bigsize = Teams[i].Size;
		}
		else if ( Teams[i].Size < smallsize )
		{
			small = i;
			smallsize = Teams[i].Size;
		}
	}
	
	bBalancing = true;
	while ( bigsize - smallsize > 1 )
	{
		for ( P=Level.PawnList; P!=None; P=P.NextPawn )
			if ( P.bIsPlayer && (P.PlayerReplicationInfo.Team == big)
				&& P.IsA('Bot') )
			{
				B = Bot(P);
				break;
			}
		if ( B != None )
		{
			B.Health = 0;
			B.Died( None, 'Suicided', B.Location );
			bigsize--;
			smallsize++;
			ChangeTeam(B, small);
		}
		else
			Break;
	}
	bBalancing = false;

	// re-assign orders to follower bots with no leaders
	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		if ( P.bIsPlayer && P.IsA('Bot') && (BotReplicationInfo(P.PlayerReplicationInfo).RealOrders == 'Follow') )
		{
			A = Pawn(Bot(P).OrderObject);
			if ( (A == None) || A.bDeleteMe || !A.bIsPlayer || (A.PlayerReplicationInfo.Team != P.PlayerReplicationInfo.Team) )
			{
				Bot(P).OrderObject = None;
				SetBotOrders(Bot(P));
			}
		}

}


///////////////////////////////////////
// ReduceDamage()
///////////////////////////////////////
//-------------------------------------------------------------------------------------
// Level gameplay modification
//Use reduce damage for teamplay modifications, etc.

function int ReduceDamage(int Damage, name DamageType, pawn injured, pawn instigatedBy)
{
	Damage = Super.ReduceDamage(Damage, DamageType, injured, instigatedBy);
	
	if ( instigatedBy == None )
		return Damage;

	if ( (instigatedBy != injured) && injured.bIsPlayer && instigatedBy.bIsPlayer 
		&& (injured.PlayerReplicationInfo.Team == instigatedBy.PlayerReplicationInfo.Team) )
	{
		if ( injured.IsA('Bot') )
			Bot(Injured).YellAt(instigatedBy);
		return (Damage * FriendlyFireScale);
	}
	else
		return Damage;
}


///////////////////////////////////////
// ChangeTeam()
///////////////////////////////////////

function bool ChangeTeam(Pawn Other, int NewTeam)
{
	local int i, Smallest, DesiredTeam;
	local pawn APlayer, P;
	local teaminfo SmallestTeam;

	if ( bRatedGame && (Other.PlayerReplicationInfo.Team != 255) )
		return false;
	if ( Other.IsA('Spectator') )
	{
		Other.PlayerReplicationInfo.Team = 255;
		if (LocalLog != None)
			LocalLog.LogTeamChange(Other);
		if (WorldLog != None)
			WorldLog.LogTeamChange(Other);
		return true;
	}

	// find smallest team
	Smallest = 0;
	for( i=1; i<MaxTeams; i++ )
		if ( Teams[Smallest].Size > Teams[i].Size )
			Smallest = i;

	if ( (NewTeam == 255) || (NewTeam >= MaxTeams) )
		NewTeam = Smallest;

	if ( bPlayersBalanceTeams && (Level.NetMode != NM_Standalone) )
	{
		if ( Teams[NewTeam].Size > Teams[Smallest].Size )
			NewTeam = Smallest;
		if ( NumBots == 1 )
		{
			// join bot's team if sizes are equal, because he will leave
			for ( P=Level.PawnList; P!=None; P=P.NextPawn )
				if ( P.IsA('Bot') )
					break;
			
			if ( (P != None) && (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Team != 255)
				&& (Teams[P.PlayerReplicationInfo.Team].Size == Teams[Smallest].Size) )
				NewTeam = P.PlayerReplicationInfo.Team;
		}
	}

	if ( Other.IsA('TournamentPlayer') )
		TournamentPlayer(Other).StartSpot = None;

	if ( Other.PlayerReplicationInfo.Team != 255 )
	{
		ClearOrders(Other);
		Teams[Other.PlayerReplicationInfo.Team].Size--;
	}

	if ( Teams[NewTeam].Size < MaxTeamSize )
	{
		AddToTeam(NewTeam, Other);
		return true;
	}

	if ( Other.PlayerReplicationInfo.Team == 255 )
	{
		AddToTeam(Smallest, Other);
		return true;
	}

	return false;
}


///////////////////////////////////////
// AddToTeam()
///////////////////////////////////////

function AddToTeam( int num, Pawn Other )
{
	local teaminfo aTeam;
	local Pawn P;
	local bool bSuccess;
	local string SkinName, FaceName;

	if ( Other == None )
	{
		log("Added none to team!!!");
		return;
	}

	aTeam = Teams[num];

	aTeam.Size++;
	Other.PlayerReplicationInfo.Team = num;
	Other.PlayerReplicationInfo.TeamName = aTeam.TeamName;
	if (LocalLog != None)
		LocalLog.LogTeamChange(Other);
	if (WorldLog != None)
		WorldLog.LogTeamChange(Other);
	bSuccess = false;
	if ( Other.IsA('PlayerPawn') )
	{
		Other.PlayerReplicationInfo.TeamID = 0;
		PlayerPawn(Other).ClientChangeTeam(Other.PlayerReplicationInfo.Team);
	}
	else
		Other.PlayerReplicationInfo.TeamID = 1;

	while ( !bSuccess )
	{
		bSuccess = true;
		for ( P=Level.PawnList; P!=None; P=P.nextPawn )
            if ( P.bIsPlayer && (P != Other) 
				&& (P.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team) 
				&& (P.PlayerReplicationInfo.TeamId == Other.PlayerReplicationInfo.TeamId) )
				bSuccess = false;
		if ( !bSuccess )
			Other.PlayerReplicationInfo.TeamID++;
	}

	BroadcastLocalizedMessage( DMMessageClass, 3, Other.PlayerReplicationInfo, None, aTeam );

	//Other.static.GetMultiSkin(Other, SkinName, FaceName);
	//Other.static.SetMultiSkin(Other, SkinName, FaceName, num);

	if ( bBalanceTeams && !bRatedGame )
		ReBalance();
}


///////////////////////////////////////
// CanSpectate()
///////////////////////////////////////

function bool CanSpectate( pawn Viewer, actor ViewTarget )
{
	if ( ViewTarget.bIsPawn && (Pawn(ViewTarget).PlayerReplicationInfo != None)
		&& Pawn(ViewTarget).PlayerReplicationInfo.bIsSpectator )
		return false;
	if ( Viewer.PlayerReplicationInfo.bIsSpectator && (Viewer.PlayerReplicationInfo.Team == 255) )
		return true;
	return ( (Pawn(ViewTarget) != None) && Pawn(ViewTarget).bIsPlayer 
		&& (Pawn(ViewTarget).PlayerReplicationInfo.Team == Viewer.PlayerReplicationInfo.Team) );
}


///////////////////////////////////////
// GetTeam()
///////////////////////////////////////

function TeamInfo GetTeam(int TeamNum )
{
	if ( TeamNum < ArrayCount(Teams) )
		return Teams[TeamNum];
	else return None;
}


///////////////////////////////////////
// IsOnTeam()
///////////////////////////////////////

function bool IsOnTeam(Pawn Other, int TeamNum)
{
	if ( Other.PlayerReplicationInfo.Team == TeamNum )
		return true;

	return false;
}


///////////////////////////////////////
// SetBotOrders()
///////////////////////////////////////

function SetBotOrders(Bot NewBot)
{
	local Pawn P, L;
	local int num, total;

	// only follow players, if there are any
	if ( (NumSupportingPlayer == 0)
		 || (NumSupportingPlayer < Teams[NewBot.PlayerReplicationInfo.Team].Size/2 - 1) ) 
	{
		For ( P=Level.PawnList; P!=None; P= P.NextPawn )
			if ( P.IsA('PlayerPawn') && (P.PlayerReplicationInfo.Team == NewBot.PlayerReplicationInfo.Team)
				&& !P.IsA('Spectator') )
		{
			num++;
			if ( (L == None) || (FRand() < 1.0/float(num)) )
				L = P;
		}

		if ( L != None )
		{
			NumSupportingPlayer++;
			NewBot.SetOrders('Follow',L,true);
			return;
		}
	}
	num = 0;
	For ( P=Level.PawnList; P!=None; P= P.NextPawn )
		if ( P.bIsPlayer && (P.PlayerReplicationInfo.Team == NewBot.PlayerReplicationInfo.Team) )
		{
			total++;
			if ( (P != NewBot) && P.IsA('Bot') && (Bot(P).Orders == 'FreeLance') )
			{
				num++;
				if ( (L == None) || (FRand() < 1/float(num)) )
					L = P;
			}
		}
				
	if ( (L != None) && (FRand() < float(num)/float(total)) )
	{
		NewBot.SetOrders('Follow',L,true);
		return;
	}
	NewBot.SetOrders('Freelance', None,true);
}				 


///////////////////////////////////////
// AssessBotAttitude()
///////////////////////////////////////

function byte AssessBotAttitude(Bot aBot, Pawn Other)
{
	if ( (Other.bIsPlayer && (aBot.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team))
		|| (Other.IsA('TeamCannon') 
			&& (StationaryPawn(Other).SameTeamAs(aBot.PlayerReplicationInfo.Team))) ) 
		return 3;
	else 
		return Super.AssessBotAttitude(aBot, Other);
}


///////////////////////////////////////
// SetDefenseFor()
///////////////////////////////////////

function Actor SetDefenseFor(Bot aBot)
{
	return None;
}


///////////////////////////////////////
// FindSpecialAttractionFor()
///////////////////////////////////////

function bool FindSpecialAttractionFor(Bot aBot)
{
	return false;
}


///////////////////////////////////////
// SetAttractionStateFor()
///////////////////////////////////////

function SetAttractionStateFor(Bot aBot)
{
	if ( aBot.Enemy != None )
	{
		if ( !aBot.IsInState('FallBack') )
		{
			aBot.bNoClearSpecial = true;
			aBot.TweenToRunning(0.1);
			aBot.GotoState('FallBack','SpecialNavig');
		}
	}
	else if ( !aBot.IsInState('Roaming') )
	{
		aBot.bNoClearSpecial = true;
		aBot.TweenToRunning(0.1);
		aBot.GotoState('Roaming', 'SpecialNavig');
	}
}


///////////////////////////////////////
// PickAmbushSpotFor()
///////////////////////////////////////

function PickAmbushSpotFor(Bot aBot)
{
	local NavigationPoint N;
	local	int	i;

	for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
		if ( N.IsA('Ambushpoint') && !N.taken )
		{
			i++;
			if (i > 100)
				break;

			if ( aBot.Orders == 'Defend' )
			{
				if ( N.IsA('DefensePoint') && (DefensePoint(N).team == aBot.PlayerReplicationInfo.team) )
				{
					if ( (DefensePoint(aBot.Ambushspot) == None)
						|| (DefensePoint(N).priority > DefensePoint(aBot.Ambushspot).priority) )
						aBot.Ambushspot = Ambushpoint(N);
					else if ( (DefensePoint(N).priority == DefensePoint(aBot.Ambushspot).priority)
						&& (FRand() < 0.4) ) 
						aBot.Ambushspot = Ambushpoint(N);
				}		
				else if ( (DefensePoint(aBot.AmbushSpot) == None)
						&& (VSize(N.Location - aBot.OrderObject.Location) < 1500)
						&& FastTrace(aBot.OrderObject.Location, N.Location)
						&& ((aBot.Ambushspot == None) || (FRand() < 0.5)) )
							aBot.Ambushspot = Ambushpoint(N);
			}
			else if ( (aBot.AmbushSpot == None)
				|| (VSize(aBot.Location - aBot.Ambushspot.Location)
					 > VSize(aBot.Location - N.Location)) )
				aBot.Ambushspot = Ambushpoint(N);
		}
}


///////////////////////////////////////
// PriorityObjective()
///////////////////////////////////////

function byte PriorityObjective(Bot aBot)
{
	return 0;
}


///////////////////////////////////////
// ClearOrders()
///////////////////////////////////////

function ClearOrders(Pawn Leaving)
{
	local Pawn P;

	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		if ( P.IsA('Bot') && (Bot(P).OrderObject == Leaving) )
			Bot(P).SetOrders('Freelance', None);
}


///////////////////////////////////////
// WaitForPoint()
///////////////////////////////////////

function bool WaitForPoint(bot aBot)
{
	return false;
}


///////////////////////////////////////
// SendBotToGoal()
///////////////////////////////////////

function bool SendBotToGoal(Bot aBot)
{
	return false;
}


///////////////////////////////////////
// HandleTieUp()
///////////////////////////////////////

function bool HandleTieUp(Bot Bumper, Bot Bumpee)
{
	return false;
}

//------------------------------------------------------------------------------
// Game Querying.


///////////////////////////////////////
// GetRules()
///////////////////////////////////////

function string GetRules()
{
	local string ResultSet;
	ResultSet = Super(TournamentGameInfo).GetRules();

	ResultSet = ResultSet$"\\timelimit\\"$TimeLimit;
	Resultset = ResultSet$"\\minplayers\\"$MinPlayers;
	Resultset = ResultSet$"\\changelevels\\"$bChangeLevels;
	ResultSet = ResultSet$"\\maxteams\\"$MaxTeams;
	ResultSet = ResultSet$"\\balanceteams\\"$bBalanceTeams;
	ResultSet = ResultSet$"\\playersbalanceteams\\"$bPlayersBalanceTeams;
	ResultSet = ResultSet$"\\friendlyfire\\"$int(FriendlyFireScale*100)$"%";
	Resultset = ResultSet$"\\tournament\\"$bTournament;
	if(bMegaSpeed)
		Resultset = ResultSet$"\\gamestyle\\Turbo";
	else
	if(bHardcoreMode)
		Resultset = ResultSet$"\\gamestyle\\Hardcore";
	else
		Resultset = ResultSet$"\\gamestyle\\Classic";

	if(MinPlayers > 0)
		Resultset = ResultSet$"\\botskill\\"$class'ChallengeBotInfo'.default.Skills[Difficulty];

	return ResultSet;
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     bBalanceTeams=True
     bPlayersBalanceTeams=True
     MaxTeams=2
     MaxAllowedTeams=4
     MaxTeamSize=16
     StartUpTeamMessage="You are on"
     TeamChangeMessage="Use Options->Player Setup to change teams."
     TeamColor(0)="Red"
     TeamColor(1)="Blue"
     TeamColor(2)="Green"
     TeamColor(3)="Gold"
     TEAM_Blue=1
     TEAM_Green=2
     TEAM_Gold=3
     CurrentOrders(0)=Defend
     CurrentOrders(1)=Defend
     CurrentOrders(2)=Defend
     CurrentOrders(3)=Defend
     StartUpMessage="Work with your teammates against the other teams."
     MaxCommanders=2
     bCanChangeSkin=False
     bTeamGame=True
     ScoreBoardType=Class'Botpack.TeamScoreBoard'
     RulesMenuType="UTMenu.UTTeamRSClient"
     SettingsMenuType="UTMenu.UTTeamSSClient"
     HUDType=Class'Botpack.ChallengeTeamHUD'
     BeaconName="TTeam"
     GameName="Tournament Team Game"
}
