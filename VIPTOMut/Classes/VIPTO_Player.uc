class VIPTO_Player expands S_Player_T;

#EXEC OBJ LOAD NAME=VIPTOTex FILE=../textures/VIPTOTex.utx

var localized string killallsf;
var localized string killallterro;
var localized string PreventVIPEscape;
var localized string SFHelpVIP;
var localized string EscapeZoneList;
var localized string VIPScenario1;
var localized string MapNotPlayable;
var localized string NoVIPForThisRound;
var bool isvip;
var bool havealreadybevip;
var VIPTO_GameReplicationInfo repl;
var int previousskin;
var bool vipescaped;

replication
{
	reliable if (Role==ROLE_Authority)
		isvip,havealreadybevip;
}

function PlayerReplicationInfo RetourneReplVIP()
{
	local VIPTO_Player joueur;

	foreach AllActors(class'VIPTO_Player',joueur)
		if (joueur.PlayerReplicationInfo.PlayerID==repl.idduvip) return joueur.PlayerReplicationInfo;
}

simulated event Possess()
{
	local s_SWATLevelInfo SWLI;
	local TO_ScenarioInfoInternal SIint;
	local TournamentConsole C;
	local UWindowRootWindow Root;
	local string Message;
	local TO_ScenarioInfo localSI;
	local s_SWATLevelInfo localSWLI;
	local VIPTO_GameReplicationInfo localrepl;

// Possess S_Player_t
	UpdateURL("Class","s_SWAT.s_Player_T",True);
	UpdateURL("Skin","None",True);
	UpdateURL("Face","None",True);
	UpdateURL("Team","255",True);
	UpdateURL("Voice","None",True);
	if ((PlayerReplicationInfo != None) && (PlayerReplicationInfo.PlayerName~="Player"))
	{
		ChangeName(Class'TO_GameOptionsCW'.Default.DefaultPlayerName);
		UpdateURL("Name",Class'TO_GameOptionsCW'.Default.DefaultPlayerName,True);
	}

// Possess to_sysplayer

	if (Level.NetMode==NM_Client)
	{
		ServerNeverSwitchOnPickup(bNeverAutoSwitch);
		ServerSetHandedness(Handedness);
		UpdateWeaponPriorities();
	}
	ServerUpdateWeapons();
	bIsPlayer=True;
	DodgeClickTime=FMin(0.30,DodgeClickTime);
	EyeHeight=BaseEyeHeight;
	NetPriority=3;
	if ((Level.Game!=None) && (!Level.Game.IsA('s_SWATGame')))
	{
		StartWalk();
		if (Handedness==1)
			LoadLeftHand();
	}
	else
	{
		if ((Role==Role_Authority) && (Level.NetMode!=NM_Standalone))
			Spawn(Class'TO_Protect',self);
	}
	if (Level.NetMode==NM_Client)
	{
		ServerSetTaunt(bAutoTaunt);
		if ((Level.Game!=None) && (!Level.Game.IsA('s_SWATGame')))
			ServerSetInstantRocket(bInstantRocket);
	}

// Possess s_bplayer
	if ( Role < Role_Authority )
	{
		ServerSetHideDeathMsg(bHideDeathMsg);
		ServerSetAutoReload(bAutomaticReload);
	}
	Bob=OriginalBob;

// Possess S_Player_t
	FixMapProblems();
	if ((Level!=None) && (Level.Game!=None) && !Level.Game.IsA('s_SWATGame'))
		return;
	if (Level.NetMode!=NM_DedicatedServer)
	{
		Message="s_Player::Possess - " $ Class'TO_MenuBar'.Default.TOVersionText;
		Log(Message);
		if ((Player!=None) && (Player.Console!=None))
		{
			SetupRainGen();
			if (Level.bHighDetailMode)
				toggleraingen();
		}
	}
	if (PZone!=None)
		PZone.Destroy();
	PZone=Spawn(Class'VIPTO_PZone',self);
	if (PZone!=None)
		PZone.Initialize();
	if (SI==None)
	{
		foreach AllActors(Class'TO_ScenarioInfo',SI)
			if (SI!=None) localSI=SI;
		if (localSI!=None) SI=localSI;
	}
	if (Role<Role_Authority)
	{
		if (SI==None)
		{
			foreach AllActors(Class's_SWATLevelInfo',SWLI)
				if (SWLI!=None) localSWLI=SWLI;
			if (LocalSWLI!=None) SWLI=localSWLI;
			if (SWLI!=None)
			{
				SIint=Spawn(Class'TO_ScenarioInfoInternal',self,,Location);
				if (SIint!=None)
				{
					SIint.ConvertActor(SWLI);
					SI=SIint;
				}
				else
					Log("s_Player - PostBeginPlay - ConvertSWLI - SI == None");
			}
			else
				Log("s_Player - PostBeginPlay - SWLI == None");
		}
	}
	if ((Player!=None) && (Player.Console==None) && (Role==Role_Authority))
		return;
	if ((myHUD!=None) && (s_HUD(myHUD)!=None) && (s_HUD(myHUD).UserInterface!=None))
	{
		s_HUD(myHUD).UserInterface.Destroy();
		s_HUD(myHUD).UserInterface=None;
	}
	bGUIActive=True;
	if (StartMenu!=None)
	{
		StartMenu.Close();
		StartMenu=None;
	}
	if ((Player!=None) && (Player.Console!=None))
		C=TournamentConsole(Player.Console);
	if (C.bShowSpeech)
		C.HideSpeech();
	if (C.Root==None)
	{
		Log("s_Player::Possess - C.Root == None - creating Root");
		C.CreateRootWindow(None);
	}
	else
	{
		if ((Level.Game!=None) && s_SWATGame(Level.Game).bSinglePlayer)
		{
			C.bQuickKeyEnable=True;
			C.LaunchUWindow();
			StartMenu=VIPTO_AutoTeamSelect(C.Root.CreateWindow(Class'VIPTO_AutoTeamSelect',0,0,C.Root.WinWidth,C.Root.WinHeight));
		}
		else
		{
			C.bQuickKeyEnable=True;
			C.LaunchUWindow();
			StartMenu=VIPTO_TeamSelect(C.Root.CreateWindow(Class'VIPTO_TeamSelect',0,0,C.Root.WinWidth,C.Root.WinHeight));
		}
	}
	if ((Player!=None) && (Player.Console!=None) && (TO_Console(Player.Console)!=None) && ((TO_Console(Player.Console).SpeechWindow==None) || !TO_Console(Player.Console).SpeechWindow.IsA('VIPTO_SWATWindow')))
	{
		Root=WindowConsole(Player.Console).Root;
		TO_Console(Player.Console).SpeechWindow=SpeechWindow(Root.CreateWindow(Class'VIPTO_SWATWindow',100,100,200,200));
		if (TO_Console(Player.Console).SpeechWindow==None)
		{
			Log("s_Player::Possess - Speechwindow == None");
			return;
		}
		TO_Console(Player.Console).SpeechWindow.bLeaveOnscreen=True;
		if (TO_Console(Player.Console).bShowSpeech)
		{
			Root.SetMousePos(0,132/768*Root.WinWidth);
			TO_Console(Player.Console).SpeechWindow.SlideInWindow();
		}
		else
			TO_Console(Player.Console).SpeechWindow.HideWindow();
	}
	else
		Log("s_Player::Possess - cannot replace speechwindow");
	if (StartMenu==None)
	{
		Log("s_Player::Possess - StartMenu == None");
	}
	GotoState('PlayerWaiting');
// Create bug, on disconnect, still "BodyGuard"
//	class'TO_DesignInfo'.Default.NameTeam[1]="Bodyguards";
	foreach AllActors(class'VIPTO_GameReplicationInfo',localrepl)
		repl=localrepl;
	InitTheObjectives();
}

simulated function CalculateWeight ()
{
	local float Weight;

	if (bNotPlaying)
		return;
	if (!isvip)
	{
		if (bSpecialItem)
			Weight+=Class's_SpecialItem'.Default.Weight;
		if (HelmetCharge>0)
			Weight+=5;
		if (VestCharge>0)
			Weight+=10;
		if (LegsCharge>0)
			Weight+=10;
		if ((Weapon!=None) && Weapon.IsA('S_Weapon'))
			Weight+=S_Weapon(Weapon).WeaponWeight;
	}
	if (bIsCrouching)
	{
		PrePivot.Z=Default.CollisionHeight-CrouchHeight-2;
		Weight+=200;
	}
	else
		PrePivot.Z=0;
	if (Weight>220)
		Weight=220;
	GroundSpeed=280-Weight;
	AirSpeed=300+Weight;
	AccelRate=2048+Weight;
	AirControl=0.30-Weight/1000;
}

function InitTheObjectives()
{
	If (Left(Level.Title,4)!="VIP-")
	{
/*		SI.DefaultLooser=ET_SpecialForces;
		SI.DefaultLooseMessage=VIPFailedToEscape;
		SI.WinAmount=1000;
		SI.bSFAttitudeOffensive=true;
		SI.bTerrAttitudeOffensive=true;*/
		SI.ScenarioDescription1=VIPScenario1;
		SI.ScenarioDescription2=EscapeZoneList;
		SI.SF_Objective1=SFHelpVIP;
		SI.SF_Objective2=killallterro;
		SI.SF_Objective3="";
		SI.SF_Objective4="";
		SI.Terr_Objective1=preventvipescape;
		SI.Terr_Objective2=killallsf;
		SI.Terr_Objective3="";
		SI.Terr_Objective4="";
		InitObjectivesScreenShots();
	}
}

function InitObjectivesScreenShots()
{
	if (Level.Title=="The Getaway") SI.ObjShot3=None;
	if (Level.Title=="Scope ")
	{
		SI.ObjShot1=SI.ObjShot3;
		SI.objShot2=None;
		SI.ObjShot3=None;
		SI.ObjShot4=None;
	}
	if (Level.Title=="CIA")
	{
		SI.ObjShot1=SI.ObjShot2;
		SI.objShot2=None;
		SI.ObjShot3=None;
		SI.ObjShot4=None;
	}
	if (Level.Title=="Blister")
	{
		SI.ObjShot1=SI.ObjShot2;
		SI.objShot2=SI.ObjShot3;
		SI.ObjShot3=None;
		SI.ObjShot4=None;
	}
	if (Level.Title=="TO-Conundrum")
	{
		SI.ObjShot1=SI.ObjShot2;
		SI.objShot2=None;
		SI.ObjShot3=None;
		SI.ObjShot4=None;
	}
	if (Level.Title=="TO-Crossfire")
	{
		SI.ObjShot3=None;
		SI.ObjShot4=None;
	}
	if (Level.Title=="TO-Dragon")
	{
		SI.ObjShot1=SI.ObjShot2;
		SI.objShot2=None;
		SI.ObjShot3=None;
		SI.ObjShot4=None;
	}
	if (Level.Title=="Eskero")
	{
		SI.ObjShot1=SI.ObjShot4;
		SI.objShot2=None;
		SI.ObjShot3=None;
		SI.ObjShot4=None;
	}
	if (Level.Title=="Monastery")
	{
		SI.ObjShot1=SI.ObjShot4;
		SI.objShot2=None;
		SI.ObjShot3=None;
		SI.ObjShot4=None;
	}
	if (Level.Title=="November Rain")
	{
		SI.ObjShot1=None;
		SI.objShot2=None;
		SI.ObjShot3=None;
		SI.ObjShot4=None;
	}
	if (Level.Title=="Oilrig")
	{
		SI.ObjShot1=None;
		SI.objShot2=None;
		SI.ObjShot3=None;
		SI.ObjShot4=None;
	}
	if (Level.Title=="Omega")
	{
		SI.ObjShot1=None;
		SI.objShot2=None;
		SI.ObjShot3=None;
		SI.ObjShot4=None;
	}
	if (Level.Title=="RapidWaters][")
	{
		SI.ObjShot1=SI.ObjShot2;
		SI.objShot2=None;
		SI.ObjShot3=None;
		SI.ObjShot4=None;
	}
	if (Level.Title=="Rebirth")
	{
		SI.ObjShot1=None;
		SI.objShot2=None;
		SI.ObjShot3=None;
		SI.ObjShot4=None;
	}
	if (Level.Title=="Spynet by Night")
	{
		SI.objShot2=None;
		SI.ObjShot3=None;
		SI.ObjShot4=None;
	}
	if (Level.Title=="Terrorist's Mansion")
	{
		SI.ObjShot1=None;
		SI.objShot2=None;
		SI.ObjShot3=None;
		SI.ObjShot4=None;
	}
	if (Level.Title=="Thanassos")
	{
		SI.ObjShot1=SI.objShot2;
		SI.objShot2=None;
		SI.ObjShot3=None;
		SI.ObjShot4=None;
	}
	if (Level.Title=="Thunderball")
	{
		SI.ObjShot1=SI.objShot2;
		SI.objShot2=None;
		SI.ObjShot3=None;
		SI.ObjShot4=None;
	}
	if (Level.Title=="Yarmouth Trainstation")
	{
		SI.ObjShot1=SI.objShot2;
		SI.objShot2=None;
		SI.ObjShot3=None;
		SI.ObjShot4=None;
	}
	if (Level.Title=="Verdon")
	{
		SI.ObjShot3=None;
	}
	if (Level.Title=="WinterRansom")
	{
		SI.ObjShot1=None;
		SI.objShot2=None;
		SI.ObjShot3=None;
		SI.ObjShot4=None;
	}
}

event PostRender(canvas Canvas)
{
	local string texte;

/*	if (isvip) bInBuyZone=false;
	else
	{
		if (s_GameReplicationInfo(Level.Game.GameReplicationInfo).bPreRound)
			peutacheter=true;
		bInBuyZone=peutacheter;
	}*/

	Super.PostRender(canvas);

	Canvas.DrawColor.G=128;
	if (self.PlayerReplicationInfo.Team==0)
	{
		Canvas.DrawColor.R=255;
		Canvas.DrawColor.B=128;
	}
	else
	{
		Canvas.DrawColor.R=128;
		Canvas.DrawColor.B=255;
	}
	Canvas.SetPos(10,5);

	if (repl==none) GetRepl();

	if ((repl!=None) && (repl.idduvip!=(-1)))
	{
		Canvas.Font=Font(DynamicLoadObject("LadderFonts.UTLadder16",Class'Font'));
		if (playerReplicationInfo.PlayerID==repl.idduvip)
		{
			Texte="You are the VIP !";
			if (PlayerReplicationInfo.PlayerLocation!=None)
				if (PlayerReplicationInfo.PlayerLocation.LocationName!="") texte=texte $ " Location : " $ PlayerReplicationInfo.PlayerLocation.LocationName;
		}
		else
		{
/*			if (repl.idduvip==chr(254)) texte=LeVIPStr $ VIPKilledByTerro;
			if (repl.idduvip==chr(252)) texte=LeVIPStr $ VIPKilledHimself;
			if (repl.idduvip==chr(253)) texte=VIPHasEscaped;
			if (repl.idduvip==chr(250)) texte=LeVIPStr $ VIPKilledByBodyguard;*/
			if (repl.idduvip==0) texte=NoVIPForThisRound;

			if ((texte=="") && (RetourneReplVIP()!=None))
			{
				Texte="The VIP is : " $ RetourneReplVIP().PlayerName;
				if (RetourneReplVIP().PlayerLocation!=None)
					if ((RetourneReplVIP().PlayerLocation.LocationName!="") && (PlayerReplicationInfo.Team==1)) texte=texte $ " Located : " $ RetourneReplVIP().PlayerLocation.LocationName;
			}

		}
		Canvas.DrawText(texte);
	}
	else
	{
		Canvas.Font=Font(DynamicLoadObject("LadderFonts.UTLadder12",Class'Font'));
		Canvas.DrawText(MapNotPlayable);
	}

//	if ((self.IsInState('PlayerWalking')) || (self.IsInState('PlayerSwimming')) || (self.IsInState('Climbing'))) CheckVIPWeapon();

	if ((s_HUD(myHUD).bHideHUD) || (s_HUD(myHUD).bHideStatus)) return;

    DrawTeamInfo(Canvas);
}

simulated function DrawTeamInfo(Canvas Canvas)
{
	if (!IsInState('PlayerSpectating'))
		if (!IsInState('PlayerWaiting'))
		{
			Canvas.bNoSmooth=true;
			Canvas.Style=3;
			Canvas.SetPos(10,Canvas.ClipY-318);
			Canvas.DrawColor.R=255;
			Canvas.DrawColor.G=128;
			Canvas.DrawColor.B=128;
			Canvas.DrawTile(Texture'VIPTOTex.Icons.TERRO',32,32,0,0,32,32);
			Canvas.SetPos(52,Canvas.ClipY-318);
			Canvas.DrawText(string(NbStillAlive(0)));
			Canvas.SetPos(10,Canvas.ClipY-278);
			Canvas.DrawColor.R=128;
			Canvas.DrawColor.G=128;
			Canvas.DrawColor.B=255;
			Canvas.DrawTile(Texture'VIPTOTex.Icons.SF',32,32,0,0,32,32);
			Canvas.SetPos(52,Canvas.ClipY-278);
			if (RetourneReplVIP()!=None) Canvas.DrawText(string(NbStillAlive(1)-1)); else Canvas.DrawText(string(NbStillAlive(1)));
		}
}

simulated function s_ChangeTeam (int Num, int Team, bool bDie)
{
	if (self.isvip)
	{
		if (Team==0)
		{
/*			if (self.IsInState('PreRound'))
				Super.s_ChangeTeam(Num,Team,bDie);
			else */ClientMessage("You can't change team when you are the VIP");
		}
	}
	else
		Super.s_ChangeTeam(Num,Team,bDie);
}

function PlayInAir()
{
	local float TweenTime;

	BaseEyeHeight =  0.7 * Default.BaseEyeHeight;
	if ( GetAnimGroup(AnimSequence) == 'Jumping' )
	{
		if ( (Weapon != None) && (Weapon.Mass < 11) )
			TweenAnim('DuckWlkKG', 2);
		if ( (Weapon == None) || (Weapon.Mass < 20) )
			TweenAnim('DuckWlkS', 2);
		else
			TweenAnim('DuckWlkL', 2);
		return;
	}
	else if ( GetAnimGroup(AnimSequence) == 'Ducking' )
		TweenTime = 2;
	else
		TweenTime = 0.7;

	if ( (Weapon == None) || (Weapon.Mass < 20) )
		TweenAnim('JumpSMFR', TweenTime);
	else
		TweenAnim('JumpLGFR', TweenTime);
}

/*function PlayInAir ()
{
	local Vector X;
	local Vector Y;
	local Vector Z;
	local Vector Dir;
	local float F;
	local float TweenTime;

	BaseEyeHeight=0.70 * Default.BaseEyeHeight;
	if ((AnimSequence!='') && ((GetAnimGroup(AnimSequence)=='Landing') && (!bLastJumpAlt)))
	{
		GetAxes(Rotation,X,Y,Z);
		Dir=Normal(Acceleration);
		F=Dir Dot Y;
		if (F>0.70)
		{
			if ((Weapon==None) || (Weapon.Mass<20))
				TweenAnim('DodgeLSm',0.35);
			else
				TweenAnim('DodgeLLg',0.35);
		}
		else
		{
			if (F<-0.70)
			{
				if ((Weapon==None) || (Weapon.Mass<20))
					TweenAnim('DodgeRSm',0.35);
				else
					TweenAnim('DodgeRLg',0.35);
			}
			else
			{
				if (Dir Dot X>0)
				{
					if ((Weapon==None) || (Weapon.Mass<20))
						TweenAnim('DodgeFSm',0.35);
					else
						TweenAnim('DodgeFLg',0.35);
				}
				else
				{
					if ((Weapon==None) || (Weapon.Mass<20))
						TweenAnim('DodgeBSm',0.35);
					else
						TweenAnim('DodgeBLg',0.35);
				}
			}
		}
		bLastJumpAlt=True;
		return;
	}
	bLastJumpAlt=False;
	if ((AnimSequence!='') && (GetAnimGroup(AnimSequence)=='Jumping'))
	{
		if ((Weapon==None) || (Weapon.Mass<20))
			TweenAnim('DuckWlkS',2.00);
		else
			TweenAnim('DuckWlkL',2.00);
		return;
	}
	else
	{
		if ((AnimSequence!='') && (GetAnimGroup(AnimSequence)=='Ducking'))
			TweenTime=2.00;
		else
			TweenTime=0.70;
	}
	if (AnimSequence=='StrafeL')
	{
		if ((Weapon==None) || (Weapon.Mass<20))
			TweenAnim('DodgeRSm',TweenTime);
		else
			TweenAnim('DodgeRLg',TweenTime);
	}
	else
	{
		if (AnimSequence=='StrafeR')
		{
			if ((Weapon==None) || (Weapon.Mass<20))
				TweenAnim('DodgeLSm',TweenTime);
			else
				TweenAnim('DodgeLLg',TweenTime);
		}
		else
		{
			if ((AnimSequence=='BackRun') || (AnimSequence=='BackRunS') || (AnimSequence=='BackRunKG') || (AnimSequence=='BackWalk'))
			{
				if ((Weapon==None) || (Weapon.Mass<20))
					TweenAnim('DodgeBSm',TweenTime);
				else
					TweenAnim('DodgeBLg',TweenTime);
			}
			else
			{
				if ((Weapon==None) || (Weapon.Mass<20))
					TweenAnim('JumpSmFr',TweenTime);
				else
					TweenAnim('JumpLgFr',TweenTime);
			}
		}
	}
}*/

function int NbStillAlive(int team)
{
	local int i;
	local VIPTO_Player VP;
	local s_Bot lesbots;

	foreach AllActors(class'VIPTO_Player',VP)
		if ((!VP.bDead) && (VP.PlayerReplicationInfo.Team==team)) i++;
    foreach AllActors(class's_Bot',lesbots)
        if ((!lesbots.bDead) && (lesbots.PlayerReplicationInfo.Team==team)) i++;

	return i;
}

function GetRepl()
{
	local VIPTO_GameReplicationInfo localrepl;

	foreach AllActors(class'VIPTO_GameReplicationInfo',localrepl)
		repl=localrepl;
}

/*function CheckVIPWeapon()
{
	local S_Weapon currentweapon;

	if (isvip)
		if ((Weapon!=None) && (S_Weapon(Weapon)!=None))
		{
			currentweapon=S_Weapon(Weapon);
			if ((!currentweapon.IsA('s_knife')) && (!currentweapon.IsA('s_DEagle')) && (!s_GameReplicationInfo(Level.Game.GameReplicationInfo).bPreRound)) ThrowWeapon();
		}
} */

simulated event Destroyed()
{
	if (Level.NetMode!=NM_DedicatedServer)
	{
		class'TO_ModelHandler'.default.ModelType[19]=MT_None;
		class'TO_ModelHandler'.default.ModelType[20]=MT_None;
//		class'TO_DesignInfo'.Default.NameTeam[1]="Special Forces";
	}
	Super.Destroyed();
}

/*simulated event Touch (Actor Other)
{
	Super.Touch(Other);
	if (Other.IsA('s_ZoneControlPoint') && (!isvip))
	{
		if (s_ZoneControlPoint(Other).bBuyPoint)
			if (1-s_ZoneControlPoint(Other).OwnedTeam==PlayerReplicationInfo.Team) peutacheter=true;
	}
}

simulated event UnTouch (Actor Other)
{
	Super.UnTouch(Other);
	if (Other.IsA('s_ZoneControlPoint') && (!isvip))
		if (s_ZoneControlPoint(Other).bBuyPoint)
			if (1-s_ZoneControlPoint(Other).OwnedTeam==PlayerReplicationInfo.Team) peutacheter=false;
}*/

exec function ThrowWeapon()
{
	if (S_Weapon(Weapon)==None)
		return;
	if ((S_Weapon(Weapon).IsA('s_DEagle')) && (isvip))
		return;
	Super.ThrowWeapon();
}

simulated function bool IsInBuyZone()
{
	local	s_ZoneControlPoint	ZCP;
	local	s_SWATGame			SG;
	local	float				dist;

    if (isvip) return false; //else return super.IsInBuyZone();

	if ( ROLE == ROLE_Authority )
	{
		SG = s_SWATGame(Level.Game);
		// On the server it needs to be checked independantly, because of the Touching[] tab size limit
		for (ZCP=SG.ZCPLink; ZCP!=None; ZCP=ZCP.NextZCP)
		{
			if ( ZCP.bBuyPoint && 1-ZCP.OwnedTeam==PlayerReplicationInfo.Team )
			{
				dist = VSize(Location-ZCP.Location) - CollisionRadius;
				if ( dist <= ZCP.CollisionRadius )
					return true;
			}
		}

		return false;
		/*
		b = false;
		for (i=0; i<4; i++)
			if ( Touching[i] != None && Touching[i].IsA('s_ZoneControlPoint') )
				b = b || (s_ZoneControlPoint(Touching[i]).bBuyPoint && s_ZoneControlPoint(Touching[i]).OwnedTeam == PlayerReplicationInfo.Team);
		return b;*/

	}
	return bInBuyZone;
}

defaultproperties
{
	KillAllSF="Kill all Special Forces"
	PreventVIPEscape="Prevent the VIP from reaching the escape zones by killing him."
	KillAllTerro="Kill all terrorists"
	SFHelpVIP="Help the VIP reaching one of the escape zones"
	EscapeZoneList="Here is the list of espace zone"
	VIPScenario1="After being kidnapped, we have a VIP in trouble and he must escape. Some terrorists are still around to finish the job."
	MapNotPlayable="This map is not playable in VIPTO Mod, You are now in TO standard mode"
	NoVIPForThisRound="There is no VIP for this round"
}
