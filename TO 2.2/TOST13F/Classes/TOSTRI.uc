//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTRI.uc
// Version : 1.2
// Author  : BugBunny
//----------------------------------------------------------------------------

class TOSTRI expands ReplicationInfo;

var string zzVersionStr;			// Holds the version code from VUC++
var string zzMsg[49];

// -------- Replicated Variables

var int zzSecurityLevel;
var bool zzAllowHUD;
var bool zzVoicePackFix;

// --------- Used on Both sides

var bool zzbInitialized;	// Has the TOSTRI been initialized
var float zzTimeStamp;		// Used for hack detection

// --------- Client Side Variables

var float zzTimeCheck;		// Count down to the next check
var PlayerPawn zzMyPlayer;	// Points to the PlayerPawn that owns this player
var TOSTHUD zzxHUD;		// Points to our hud mutator
var int zzCheckSum;		// CheckSum
var UWindowRootWindow zzRoot;	//
var int zzCheckFlag;		// Indicates passed tests
var string zzKnownPackage[50];	// contains all Trusted packages
var int kp;			// number of Trusted packages
var float zzBlindTime;		// blind time backup
var bool zzbShowTeamInfo;	// HUD extension active : TeamInfo
var int zzShowWeapon;		// HUD extension active : WeaponHUD
var bool zzRecoilCheckPassed;
var bool zzRecoilTest;
var int zzCheckCount;
var s_Weapon zzOldWeapon;

var bool zzbSetPlayerAlready;

var Actor zzTestActors[50];

// --------- zzServer Side Variables

var TOSTServerMutator zzTOST;		// Pointer back to the zzServer side mutator
var float zzLastHey;			// Holds the time when the last HeyServer was received
var bool zzClientReportedIn;
var int zzClientInitStatus;		// Were in the init process is the client
var int zzClientInitTries;		// How many times have we tried to init the client
var float zzTimeOutGrace;		// Used to determine the grace period before a timeout
					// on the initial join
var bool zzSelfTest;			// indicates zzSelfTest state
var bool zzCrossChecked;
var int zzSelfTestFlags;		// self tests passed
var TOSTReporter zzReporter;		// the Reporter
var int zzTestActorTime;
var string zzsMsg[13];

// New FilRip
var string	SrvEncMsg[2];
var int		zzSelftestCount;

var byte toff,aa;
var int	zzPackageCount;
struct PackageData {
	var string	zzPkgName;
	var int		zzNames;
	var int		zzNameSpace;
	var int		zzImports;
	var int		zzExports;
	var int		zzGenerations;
	var int		zzLazy;
	var bool	zzKnown;
	var bool	zzVerified;
};
var PackageData		zzPackages[200];
// End New FilRip

replication
{
	// Function the Client calls on the Server

	reliable if ( Role < ROLE_Authority)
		zzServerLog, zzServerLog2, zzServerLogCheat;

	reliable if ( Role < ROLE_Authority )
		zzServerGo, zzServerACK, zzHeyServer;

	reliable if ( Role < ROLE_Authority )
		zzFixVoicepack, zzCrossCheck;

	// Client Commands
	reliable if ( Role < ROLE_Authority )
		zzSrvMkTeams, zzSrvProtectSrv, zzSrvKickTK, zzSrvTOSTInfo, zzSrvXKick, zzSrvXPKick;

	// Variables the Server sets on the client.

	reliable if ( Role == ROLE_Authority )
		zzSecurityLevel, zzVoicePackFix, zzAllowHUD,xxVerifyPackage;

	// Functions the Server calls on the client.

	reliable if ( ROLE == ROLE_Authority)
		zzClientGo, zzClientACK, zzHeyClient,CheckActors;

	reliable if ( ROLE == ROLE_Authority)
		zzAddKnownPackages, zzToggleWeaponInfo, zzToggleTeamInfo, zzSetBlindTime;
}

// ==================================================================================
// PostNetBeginPlay - Start everything up
// ==================================================================================
simulated event PostNetBeginPlay ()
{
	Super.PostNetBeginPlay();

	// on client goto state zzClientInitializing instead of zzServerInitializing
	if ( (Level.NetMode == NM_Client && ROLE < ROLE_SimulatedProxy) || (!bNetOwner) )
		return;
	zzDecryptStrings("MadOnion");
        GotoState('zzClientInitializing');
}

simulated function zzDecryptStrings(string zzPassword)
{
	local string zzPermString;
	local int i, j, zzk;
	local string zzCrypt, zzPass, zzKey, zzPrevPlain, zzPlain, zzPlainString;

	zzPermString="[]()/&%$§'!=?+*#-_.,;:<>@ ";
	for (i=9; i>=0; i--)
		zzPermString=Chr(48+i)$zzPermString;
	for (i=25; i>=0; i--)
		zzPermString=Chr(97+i)$zzPermString;
	for (i=25; i>=0; i--)
		zzPermString=Chr(65+i)$zzPermString;
	zzPermString = zzPermString$zzPermString;

	zzPrevPlain="A";
	zzk=0;
	for (i=0; i<49; i++)
	{
		zzPlainString = "";
		for (j=0; j<Len(zzMsg[i]); j++)
		{
			zzk++;
			if (zzk > Len(zzPassword))
				zzk = 1;
			zzPass = Mid(zzPassword, zzk-1, 1);
			zzCrypt = Mid(zzMsg[i], j, 1);
			zzKey = Mid(Mid(zzPermString, InStr(zzPermString, zzPass), 88), InStr(zzPermString, zzCrypt), 1);
			zzPlain = Mid(Mid(zzPermString, InStr(zzPermString, zzPrevPlain), 88), InStr(zzPermString, zzKey), 1);
			zzPlainString = zzPlainString$zzPlain;
			zzPrevPlain = zzPlain;
		}
		zzMsg[i] = zzPlainString;
	}
}

// ==================================================================================
// ==================================================================================
// SERVER SIDE
// ==================================================================================
// ==================================================================================

// ==================================================================================
// client commands
// ==================================================================================

final function zzSrvTOSTInfo(PlayerPawn zzMyPlayer)
{
	zzTOST.zzTOSTInfo(zzMyPlayer);
}

final function zzSrvProtectSrv(PlayerPawn zzMyPlayer)
{
	zzTOST.zzProtectSrv(zzMyPlayer);
}

final function zzSrvKickTK(PlayerPawn zzMyPlayer)
{
	zzTOST.zzKickTK(zzMyPlayer);
}

final function zzSrvMkTeams(PlayerPawn zzMyPlayer)
{
	zzTOST.zzMkTeams(zzMyPlayer);
}

final function zzSrvXKick(PlayerPawn zzMyPlayer, coerce string s)
{
	zzTOST.zzXKick(zzMyPlayer, s);
}

final function zzSrvXPKick(PlayerPawn zzMyPlayer, byte PID)
{
	zzTOST.zzXPKick(zzMyPlayer, PID);
}


// ==================================================================================
// Server side logging functions
// ==================================================================================

function zzServerLog(string zzLogString)
{
	zzReporter.zzServerLog(Owner, Self, zzLogString);
}

function zzServerLog2(string zzLogString)
{
	zzReporter.zzServerLog2(Owner, zzLogString);
}

function zzServerLogCheat(int zzType, string zzLogString, string zzMsgString)
{
	zzReporter.zzServerLogCheat(Owner, Self, zzType, zzLogString, zzMsgString);
}

// ==================================================================================
// ServerACK - Let's the server know the client has spawned the RI and is ready
// ==================================================================================

function zzServerACK(float zzTimeStamp)
{
	// UT
	zzAddKnownPackages(zzsMsg[1]);
	// TO
	zzAddKnownPackages(zzsMsg[2]);
	// Used Packages
	if (zzTOST.UsedPackages != "")
		zzAddKnownPackages(Caps(zzTOST.UsedPackages));
	zzSelfTestFlags = 0;
	zzSelfTest = True;
	zzCrossChecked = False;
	zzClientAck(Level.TimeSeconds);
}
// ==================================================================================
// ServerGo - Allow the server to go
// ==================================================================================

function zzServerGo(float zzTimeStamp)
{
	local string zzClassStr, zzPackageStr;

	zzSelfTest = False;
	// TOST - add after selftest to make selftest work for FakeAimingDevice
	zzClassStr = Caps(String(self.Class));
	zzPackageStr = Left(zzClassStr, InStr(zzClassStr, "."));
	zzAddKnownPackages(zzPackageStr);
	xxVerifyPackages(zzTOST.Checkme);

	if (zzSelfTestFlags != 6 || !zzCrossChecked) {
		zzServerLogCheat(-1, zzsMsg[4]$zzSelfTestFlags$")", zzsMsg[12]);
		GotoState('zzServerKick');
	} else {
		zzClientGo(Level.TimeSeconds);
		if (!IsInState('zzServerKick'))
			GotoState('zzServerWorking');
	}
}

// ==================================================================================
// HeyServer - Called from the client.  The client passes in a number of checks to here
// and if any are true, the client is kicked.
// ==================================================================================
function zzHeyServer(float zzNewTimeStamp, int zzCheckSums, int zzCheckFlags)
{
	// update timestamps
	zzTimeStamp = zzNewTimeStamp;
	zzLastHey = Level.TimeSeconds;

	// the magic numbers for CheckRootWindow and CheckHUD
	if (zzCheckSums != 155291082 && zzCheckSums != 20873526) {
		zzServerLogCheat(-1, zzsMsg[6]$zzCheckSums$")", zzsMsg[5]);
	}

	if (zzCheckFlags != 0) {
		zzServerLogCheat(-1, zzsMsg[7], zzsMsg[5]);
	}
}

// ==================================================================================
// CheckTimeStamp - Checks to make sure the player's communication system is still working
// ==================================================================================

function bool zzCheckTimeStamp(float zzDelta)
{

	if (Level.TimeSeconds <= zzTimeOutGrace)
		return false;

	if ((Level.TimeSeconds - zzLastHey) > zzTOST.SecurityTolerance)
        {
        	zzReporter.zzClientTimedOut(owner,self);
        }

	return ((Level.TimeSeconds - zzLastHey) > zzTOST.SecurityTolerance);
}

// ==================================================================================
// FixVoicePack
// ==================================================================================
function zzFixVoicePack(PlayerReplicationInfo zzPRI)
{
	local class<VoicePack> zzVoicePackClass;

	TO_GameBasics(Level.Game).SetVoiceType(zzPRI);
	zzVoicePackClass = zzPRI.VoiceType;
	TournamentPlayer(zzPRI.Owner).UpdateURL(zzsMsg[8], String(zzVoicePackClass), True);
}

// ==================================================================================
// CrossCheck
// ==================================================================================
function zzCrossCheck(class<UWindowBase> zzrw, class<HUD> zzhud)
{
	if (zzrw != class'TOSystem.TO_RootWindow')
	{
		zzServerLogCheat(3, zzsMsg[10]$String(zzrw), zzsMsg[11]$String(zzrw));
	}
	if (zzhud != class's_SWAT.s_HUD')
	{
		zzServerLogCheat(-1, zzsMsg[7], zzsMsg[5]);
	}
	zzCrossChecked = True;
}

// ==================================================================================
// AwaitingACK - This is the default state.  Here the server waits for the initial ACK
// from the client
// ==================================================================================

auto state zzServerAwaitingACK
{
	function zzTalkToClient()
	{
		if (zzClientInitTries > zzTOST.MaxInitTries)
		{
			// If we get here, the client has timed out
			zzReporter.zzClientTimedOut(owner,self);
		}
		else
			zzClientInitTries++;
	}


Begin:
	while (true)
	{
		Sleep(2*Level.TimeDilation);
		if (zzsMsg[0] != "")
			zzTalkToClient();
	}

}

// ==================================================================================
// ServerWorking - Calls the client every 2 seconds so the client verifys itself.
// ==================================================================================

state zzServerWorking
{
	function BeginState()
	{
		local int zzi;
	        zzLastHey = level.TimeSeconds;
		zzReporter.zzClientLoggedOn(Owner, Self);
		zzbInitialized = true;
	}

	// ==================================================================================

	function zzTalkToClient(bool zzTestActor)
	{
		if (zzCheckTimeStamp(0.0)) {
			zzServerLog(zzsMsg[9]);
		} else {
			if (PlayerPawn(Owner) != None && PlayerPawn(Owner).Weapon != None) {
				zzHeyClient(Level.TimeSeconds, 31, zzTestActor, s_Weapon(PlayerPawn(Owner).Weapon).default.HRecoil, s_Weapon(PlayerPawn(Owner).Weapon).default.VRecoil, s_Weapon(PlayerPawn(Owner).Weapon).default.RecoilMultiplier);
			} else {
				zzHeyClient(Level.TimeSeconds, 31, zzTestActor, -1.0, -1.0, -1.0);
			}
		}
	}
Begin:
	zzTimeStamp = 0.0;
	zzTestActorTime = 0;
	while (true)
	{
		Sleep(zzTOST.SecurityFrequency*Level.TimeDilation);
		zzTestActorTime++;
		if (((TO_GameBasics(Level.Game).GamePeriod != GP_RoundPlaying) && (zzTestActorTime > 4)) || (zzTestActorTime > 30))
			zzTestActorTime = 0;
		if (PlayerPawn(Owner) != None && PlayerPawn(Owner).Weapon != None) {
			zzTalkToClient(zzTestActorTime==0);
		} else
			zzTalkToClient(zzTestActorTime==0);
	}
}

// ==================================================================================
// ServerKick - Waits 1/2 a second, then kicks the player
// ==================================================================================

state zzServerKick
{
begin:
	zzTOST.zzEraseStats(s_Player(Owner).PlayerReplicationInfo.PlayerName);
	Sleep(0.5);
	Owner.Destroy();
	Destroy();
}


// ==================================================================================
// ==================================================================================
// CLIENT SIDE
// ==================================================================================
// ==================================================================================

// ==================================================================================
// AttachHUD - Adds our hud controller/mutator & the flash spawn notification
// ==================================================================================

simulated function zzAttachHUD()
{
	local Mutator zzHM;

	// spawn the hud mutator
	if ( (zzxHUD != None) || (zzMyPlayer == None) || (zzMyPlayer.MyHUD==None) )
	{
		return;
	}

	zzxHUD = Spawn(class'TOSTHUD', zzMyPlayer);
	if (zzxHUD == None)
		zzServerLog(zzMsg[0]);
	else
	{
		// attach it to the player
		zzHM = zzMyPlayer.MyHUD.HudMutator;
		if (zzHM != None)
		{
			zzxHUD.zzNextHUD = zzHM;
		}
		zzxHUD.zzRI = self;
		zzxHUD.zzmyHud = zzMyPlayer.myHUD;
		zzMyPlayer.myHud.HudMutator = zzxHUD;
		zzbShowTeamInfo = zzxHUD.ShowTeamInfo;
		zzShowWeapon = zzxHUD.WeaponHUDType;
	}
}

// ==================================================================================
// Communication Functions - Client Side only
// ==================================================================================

////////////////////////////////////////////////////////
// SetBlindTime
////////////////////////////////////////////////////////
simulated function zzSetBlindTime(float zzTime)
{
	zzBlindTime = zzTime;
}

////////////////////////////////////////////////////////
// AddKnownPackages - add trusted packages
////////////////////////////////////////////////////////
simulated function zzAddKnownPackages(string zzPackageList)
{
	local string zzPackage;
	local int zzi;

	zzPackage = zzPackageList;

	zzi = InStr(zzPackage, ";");
	while (zzi != -1)
	{
		zzKnownPackage[kp++] = Left(zzPackage, zzi);
		zzPackage = Right(zzPackage, Len(zzPackage) - zzi - 1);
		zzi = InStr(zzPackage, ";");
	}
	zzKnownPackage[kp++] = zzPackage;
}

////////////////////////////////////////////////////////
// AckClient - Tell the client the server is listening
////////////////////////////////////////////////////////

simulated function zzClientACK(float zzTimeStamp)
{
	local HUD zzmyHUD;
	local TOSTFakeAimingDevice zzmyAimbot;

	if ( !IsInState('zzClientAcking') )
	{
		zzServerLog2(zzMsg[2]$level.timeseconds$zzMsg[3]$zzTimeStamp$zzMsg[4]);
		return;
	}
	// perform selftest

	// HUD & Aiming Device
	if (zzMyPlayer != None && zzMyPlayer.myHUD != None)
	{
		zzmyHUD = zzMyPlayer.MyHUD;
		zzMyPlayer.MyHUD = spawn(class'TOSTFakeHUD', zzMyPlayer);
		zzFindTestActors();
		zzCheckClient(-1.0, -1.0, -1.0);
		zzCrossCheck(zzRoot.Class, zzMyPlayer.MyHUD.Class);
		zzmyAimbot = spawn(class'TOSTFakeAimingDevice', zzMyPlayer);
		zzmyAimbot.zzPP = zzMyPlayer;
		zzFindTestActors();
		zzCheckClient(-1.0, -1.0, -1.0);
		zzmyAimbot.Destroy();
		zzMyPlayer.MyHUD.Destroy();
		zzMyPlayer.MyHUD = zzmyHUD;
	}
	GotoState('zzClientAuthorizing');
	xxCollectPackageData();
}

/////////////////////////////////////////////
// ClientGo - tell the client it's ok to go
/////////////////////////////////////////////

simulated function zzClientGo(float zzTimeStamp)
{

	if ( !IsInState('zzClientAuthorizing') )
	{
		zzServerLog2(zzMsg[5]$level.timeseconds$zzMsg[3]$zzTimeStamp$zzMsg[4]);
		return;
	}
	// startup checks (no SelfTest !)
	zzCheckSum = 0;
	zzCheckRootWindow();
	zzCheckBuyZone();
	zzCheckBlindTime();
	zzCheckSmokeNades();
	zzHeyServer(Level.TimeSeconds, zzCheckSum, 0); // CheckSum test for CheckRootWindow
	GotoState('zzClientWorking');
}

/////////////////////////////////////////////////
// HeyClient - Called from the Server for checks
/////////////////////////////////////////////////

simulated function zzHeyClient(float zzTimeStamp, int zzChecks, bool zzTestActor, float DefHRecoil, float DefVRecoil, float DefRecoilMultiplier)
{
	if (!IsInState('zzClientWorking') )
	{
		zzServerLog2(zzMsg[6]$level.timeseconds$zzMsg[3]$zzTimeStamp$zzMsg[4]);
		return;
	}
	zzCheckFlag = zzChecks;
	if (zzTestActor)
		zzFindTestActors();
	zzCheckClient(DefHRecoil, DefVRecoil, DefRecoilMultiplier);
        zzHeyServer(Level.TimeSeconds, zzCheckSum, zzCheckFlag);
}

// ==================================================================================
// Tick - executed on client and serverside !
// ==================================================================================

simulated function Tick(float zzdelta)
{
    local bool sh,th;

	// NoRecoil Typ 2 - Recoil call is not executed...
	if ((Role < ROLE_Authority) && (!IsInState('zzServerKick')))
	{
		zzCheckAnims();
		if (!zzRecoilCheckPassed && zzMyPlayer != None && s_Weapon(zzMyPlayer.Weapon) != None)
		{
			if (!zzRecoilTest || zzOldWeapon != s_Weapon(zzMyPlayer.Weapon))
			{
				zzRecoilTest = True;
				s_Weapon(zzMyPlayer.Weapon).RecoilVal = 0;
				s_Player(zzMyPlayer).bDoRecoil = True;
				zzOldWeapon = s_Weapon(zzMyPlayer.Weapon);
			} else {
				if ((!s_Player(zzMyPlayer).bDoRecoil) && (zzMyPlayer.Weapon.IsInState('sClientFire') || zzMyPlayer.Weapon.IsInState('Idle'))) {
					zzRecoilCheckPassed = True;
					if (s_Weapon(zzMyPlayer.Weapon).RecoilVal == 0)
						zzServerLogCheat(6, zzMsg[7]$"(NRC)", zzMsg[8]);
				}
			}
		}
		if ((class'WaterTexture'.default.bInvisible) || (class'FractalTexture'.default.bInvisible) || (class'WetTexture'.default.bInvisible))
		{
            zzServerLogCheat(7,"Invisible water","Invisible water");
            GotoState('zzServerKick');
		}
	}
// New stuff from FilRip
	toff++;
	if (toff==255)
	{
    	if ((zzMyPlayer!=None) && (!IsInState('zzServerKick')))
        {
            CheckCanvas();
            CheckActors();
            sh=false;
            th=false;
            if (zzMyPlayer.Physics==PHYS_Flying)
            {
                if (zzMyPlayer.IsInState('PlayerWalking'))
                {
                    zzServerLogCheat(7,"Fly bug user","Fly bug user");
                    GotoState('zzServerKick');
                }
            }
            if ((s_Player(zzMyPlayer)!=None) && (zzMyPlayer.IsInState('PlayerWalking')))
            {
                if (s_Player(zzMyPlayer).PlayerModel==1)
                    sh=true;
                if (zzMyPlayer.PlayerReplicationInfo.Team==0)
                    if (class'TO_ModelHandler'.Default.ModelType[s_Player(zzMyPlayer).PlayerModel]!=MT_Terrorist) sh=true;
                if (zzMyPlayer.PlayerReplicationInfo.Team==1)
                    if (class'TO_ModelHandler'.Default.ModelType[s_Player(zzMyPlayer).PlayerModel]!=MT_SpecialForces) sh=true;
                if (zzMyPlayer.PlayerReplicationInfo.Team>1)
                    th=true;
                if (th)
                {
                    zzServerLogCheat(7,"Team Hack","Team Hack");
                    GotoState('zzServerKick');
                }
                if (sh)
                {
                    zzServerLogCheat(7,"Team/Hostages Skin Hack","Team/Hostages Skin Hack");
                    GotoState('zzServerKick');
                }
            }
        }
        toff=0;
        aa=0;
	}
// End new stuff from FilRip
}

function CheckCanvas()
{
    local string a;

    a=zzMyPlayer.ConsoleCommand("get ini:Engine.Engine.Canvas class");
    zzMyPlayer.ClientMessage("Canvas="$a);
    Log("Canvas="$a);

/*    if (Caps(string(zzMyPlayer.Canvas.Class))!="ENGINE.CANVAS")
    {
        zzServerLogCheat(2,"Unknown canvas "$Caps(A.Class),"Unknown canvas "$Caps(A.Class));
        GotoState('zzServerKick');
    }*/
}

// New stuff from FilRip
final simulated function CheckActors()
{
    local Actor A;
    local string Package;
    local bool ok;
    local byte i;

    foreach zzMyPlayer.getEntryLevel().AllActors(class'Actor',A)
    {
        ok=false;
        Package=Left(Caps(String(A.Class)),Instr(Caps(String(A.Class)),"."));
        for (i=0;i<50;i++)
            if (Package==zzKnownPackage[i]) ok=true;
        if (!ok)
        {
            zzServerLogCheat(2,"Unknown actor "$Caps(string(A.Class)),"Unknown actor "$Caps(string(A.Class)));
            GotoState('zzServerKick');
        }
    }
}
// End new stuff from FilRip

// ==================================================================================
// client commands
// ==================================================================================

final simulated function zzTOSTInfo()
{
	zzSrvTOSTInfo(zzMyPlayer);
}

final simulated function zzToggleTeamInfo()
{
	zzbShowTeamInfo = !zzbShowTeamInfo;
	zzxHUD.ShowTeamInfo = zzbShowTeamInfo;
	zzxHUD.SaveConfig();
}

final simulated function zzToggleWeaponInfo()
{
	zzShowWeapon++;
	if (zzShowWeapon > 2)
		zzShowWeapon=0;
	zzxHUD.WeaponHUDType = zzShowWeapon;
	zzxHUD.SaveConfig();
}

final simulated function zzProtectSrv()
{
	zzSrvProtectSrv(zzMyPlayer);
}

final simulated function zzKickTK()
{
	zzSrvKickTK(zzMyPlayer);
}

final simulated function zzMkTeams()
{
	zzSrvMkTeams(zzMyPlayer);
}

final simulated function zzXSay(coerce string s)
{
	zzMyPlayer.Say(zzFormatString(s));
}

final simulated function zzXTeamSay(coerce string s)
{
	zzMyPlayer.TeamSay(zzFormatString(s));
}

final simulated function zzXKick(coerce string s)
{
	zzSrvXKick(zzMyPlayer, s);
}

final simulated function zzXPKick(int PID)
{
	zzSrvXPKick(zzMyPlayer, PID);
}

final simulated function zzEcho(coerce string s)
{
	zzMyPlayer.ClientMessage(zzMyPlayer.PlayerReplicationInfo.PlayerName$":(Echo) "$zzFormatString(s));
}

// ==================================================================================
// Check Functions - Client Side only
// ==================================================================================

//////////////////////////////////////////////////////
// CheckClient
//////////////////////////////////////////////////////
final   simulated function zzCheckClient(float DefHRecoil, float DefVRecoil, float DefRecoilMultiplier)
{
	zzCheckSum = 0;
	zzCheckHUD(zzMyPlayer.myHUD.Class);
	if (zzVoicePackFix)
		zzCheckVoicePack();
	zzCheckNetSpeed();
	zzCheckCV();
	zzCheckAimingDevice();
	zzCheckRecoil(DefHRecoil, DefVRecoil, DefRecoilMultiplier);
	zzCheckGlow();
	// only sparse testing...
	if (zzCheckCount == 0)
		zzCheckNoRecoilScripts();
	zzCheckCount++;
	if (zzCheckCount > 18)
		zzCheckCount = 0;
}

/////////////////////////////////////////////////////
// CalcCheckSum - calculates a checksum for a string
/////////////////////////////////////////////////////
final	simulated function zzCalcCheckSum(string zzs)
{
	local int zzi, zzj;
	for (zzi=1; zzi<Len(zzs); zzi++) {
		zzj = (Asc(Mid(zzs,zzi,1)) * Asc(Mid(zzs,zzi+1,1)) * Len(zzs)) % 65536;
		if (zzi%2 == 1) {
		  zzCheckSum += zzj * 256;
		} else {
		  zzCheckSum += zzj;
		}
	}
}

///////////////////////////////////////
// CheckRecoil
///////////////////////////////////////
final simulated function zzCheckRecoil(float DefHRecoil, float DefVRecoil, float DefRecoilMultiplier)
{
	local s_Weapon zzW;
	local int zzCurrentMode;
	local float zzHRecoil, zzVRecoil, zzRecoilMultiplier;

	zzW = s_Weapon(zzMyPlayer.Weapon);

	if (zzW==None) {
		zzCheckFlag -= 8;
		return;
	}

	// ZeroAccuracy is allowed only for Sniperrifles
	if (zzW.bZeroAccuracy && !zzW.IsA('s_PSG1'))
	{
		zzServerLogCheat(6, zzMsg[7]$"(ZA)", zzMsg[8]);
		zzW.SetAimError();
	}

	if (!zzW.bZeroAccuracy && zzW.AimError < 0.001)
	{
		zzServerLogCheat(6, zzMsg[7]$"(AE)", zzMsg[8]);
		zzW.SetAimError();
	}

	if ((zzW.IsInState('sClientFire') || zzW.IsInState('Idle')) && DefHRecoil != -1.0 && DefVRecoil != -1.0 && DefRecoilMultiplier != -1.0)
	{
		// calculate minimal possible values (Single Shot Mode)
		zzRecoilMultiplier = DefRecoilMultiplier * 0.80;
		zzVRecoil = DefVRecoil * 0.80;
		// fix for zoomable non-sniper weapons
		if (zzW.isA('TO_SteyrAug') || zzW.isA('TO_HK33') || zzW.isA('s_OICW'))
			zzHRecoil = 0.4 * 0.80;
		else
			zzHRecoil = DefHRecoil * 0.80;

		if (zzW.VRecoil < zzVRecoil || zzW.HRecoil < zzHRecoil || zzW.RecoilMultiplier < zzRecoilMultiplier)
		{
			zzServerLogCheat(6, zzMsg[7]$"(VHM)", zzMsg[8]);
			zzW.SetAimError();
		}
	}

	if (zzW.PlayerAimError < 0.001)
	{
		zzServerLogCheat(6, zzMsg[7]$"(PAE)", zzMsg[8]);
		zzW.SetAimError();
	}

	zzCheckFlag -= 8;
}

///////////////////////////////////////
// CheckGlow
///////////////////////////////////////
final simulated function zzCheckGlow()
{
	local s_Player zzP;
	local bool zzAlreadyLogged;

	zzAlreadyLogged = False;
	foreach AllActors(Class's_Player', zzP)
	{
		if (zzP.LightEffect != LE_None || zzP.LightType != LT_None)
		{
			// only report once :)
			if (!zzAlreadyLogged)
			{
				zzAlreadyLogged = True;
				zzServerLogCheat(7, zzMsg[9], zzMsg[10]);
			}
			zzP.AmbientGlow = 0;
			zzP.LightEffect = LE_None;
			zzP.LightRadius = 0;
			zzP.LightType = LT_None;
			zzP.LightBrightness = 0;
			zzP.LightSaturation = 0;
			zzP.LightHue = 0;
		}
	}
	zzCheckFlag -= 16;
}

///////////////////////////////////////
// CheckBlindTime
///////////////////////////////////////
final simulated function zzCheckBlindTime()
{
	local float r;

	r = Rand(5) + 2;

	s_Player(zzMyPlayer).SetBlindTime(r);
	if (s_Player(zzMyPlayer).BlindTime != r)
		zzServerLogCheat(5, zzMsg[11]$"(BT)", zzMsg[12]);
	s_Player(zzMyPlayer).SetBlindTime(0);
}

///////////////////////////////////////
// CheckBuyZone
///////////////////////////////////////
final simulated function zzCheckBuyZone()
{
	local s_Player zzPlayer;

	if (zzMyPlayer != None)
	{
		zzPlayer = s_Player(zzMyPlayer);

		if (!zzPlayer.PZone.xxNotValidOwner())
		{
			zzPlayer.PZone.xxClearPZone();

			if (zzPlayer.bInBuyZone)
			{
				zzServerLogCheat(8, zzMsg[37], zzMsg[1]);
			}

			zzPlayer.PZone.xxProcessChecks();
		}
	}
}

///////////////////////////////////////
// CheckHUD
///////////////////////////////////////
final	simulated function zzCheckHUD(Class<HUD> zzMyHUD)
{
	local string	 zzClassStr;
	local Mutator	 hm;
	local TO_Console con;

	zzClassStr = Caps(String(zzMyHUD));

	zzCalcCheckSum(zzMsg[31]);
	zzCheckFlag--;

	if ( (zzMyHUD != zzMyPlayer.default.HUDType)
		|| (Left(zzClassStr, InStr(zzClassStr, ".")) != Caps(zzMsg[31])) )
	{
		con = TO_Console(zzRoot.Console);
		if (con.bShowSpeech || con.bShowMessage) {
			// checks for open console or buymenu to avoid spamming
			return;
		} else {
			if (zzMyPlayer.MyHUD.IsA('ADE_s_HUD'))
			{
				zzServerLogCheat(2, zzMsg[13], zzMsg[14]);
			} else	{
				zzServerLogCheat(1, zzMsg[15]$zzClassStr, zzMsg[16]$zzClassStr);
			}
			hm = zzMyPlayer.MyHUD.HUDMutator;
			zzMyPlayer.MyHUD.Destroy();
			zzMyPlayer.MyHUD = spawn(zzMyPlayer.default.HUDType, zzMyPlayer);
			zzMyPlayer.MyHUD.HUDMutator = hm;
		}
	}
}

///////////////////////////////////////
// CheckCenterView
///////////////////////////////////////
final simulated function zzCheckCV()
{
	zzCheckFlag -= 2;
	if (zzMyPlayer.bCenterView || zzMyPlayer.bSnapLevel != 0)
	{
		zzServerLogCheat(4, zzMsg[17], zzMsg[18]);
		zzMyPlayer.bCenterView = False;
		zzMyPlayer.bSnapLevel = 0;
	}
}

///////////////////////////////////////
// CheckVoicePack
///////////////////////////////////////
final simulated function zzCheckVoicePack()
{
	local string zzClassStr;

	if (zzMyPlayer == None || zzMyPlayer.PlayerReplicationInfo == None || zzMyPlayer.PlayerReplicationInfo.VoiceType == None)
		return;

	zzClassStr = Caps(String(zzMyPlayer.PlayerReplicationInfo.VoiceType));
	if (Left(zzClassStr, InStr(zzClassStr, ".")) != zzMsg[19])
		zzFixVoicePack(zzMyPlayer.PlayerReplicationInfo);
}

//////////////////////////////////////
// CheckNoRecoilScripts
//////////////////////////////////////
final simulated function zzCheckNoRecoilScripts()
{
	local int zzI;
	local string zzKeyName;
	local string zzAlias;

	for (zzI=0; zzI<255; zzI++)
	{
		zzKeyName = zzMyPlayer.ConsoleCommand(zzMsg[42]$zzI);
		if ( zzKeyName != "" )
		{
			zzAlias = Caps(zzMyPlayer.ConsoleCommand(zzMsg[43]$zzKeyName));
			if (InStr(zzAlias, zzMsg[44]) >= 0 && InStr(zzAlias, zzMsg[45]) >= 0 && InStr(zzAlias, zzMsg[46]) >= 0)
			{
				zzServerLogCheat(6, zzMsg[40]$" : "$zzKeyName$" - "$zzAlias, zzMsg[41]);
// silent logging		zzServerLog2(zzMsg[40]$" : "$zzKeyName$" - "$zzAlias);
			}
		}
	}
}


///////////////////////////////////////
// CheckNetspeed
///////////////////////////////////////
final simulated function zzCheckNetSpeed()
{
	if (zzMyPlayer.Player.CurrentNetSpeed < 2600)
		zzMyPlayer.ConsoleCommand(zzMsg[32]);
}

///////////////////////////////////////
// CheckSmokeNades
///////////////////////////////////////
final simulated function zzCheckSmokeNades()
{
	if (class's_SWAT.TO_SmokeLarge'.default.Lifespan != 10.0)
		zzServerLogCheat(7, zzMsg[38], zzMsg[39]);
}

///////////////////////////////////////
// CheckAnims
///////////////////////////////////////
final simulated function zzCheckAnims()
{
    if ((zzMyPlayer==None) || (s_Player(zzMyPlayer)==None)) return;

    if ( (zzMyPlayer.Health>0)
     && ((zzMyPlayer.AnimSequence=='DeathEnd')
     || (zzMyPlayer.AnimSequence=='DeathEnd2')
     || (zzMyPlayer.AnimSequence=='DeathEnd3')) ) aa++;

    if ( (zzMyPlayer.AnimSequence=='HostageNealBreath')
     || (zzMyPlayer.AnimSequence=='HostageStandBreath')
     || (zzMyPlayer.AnimSequence=='HostageDown')
     || (zzMyPlayer.AnimSequence=='HostageRun')
     || (zzMyPlayer.AnimSequence=='HostageUp')
     || (zzMyPlayer.AnimSequence=='HostageWalk') ) aa++;

/*	if ( !zzMyPlayer.IsInState('PreRound') && (
		zzMyPlayer.AnimSequence=='All' ||
		(zzMyPlayer.AnimSequence=='DuckWlkS' && !zzMyPlayer.bIsCrouching && zzMyPlayer.bDuck==0 && !s_Player(zzMyPlayer).bCantStandUp && zzMyPlayer.Physics != PHYS_Falling) ||
		((zzMyPlayer.AnimSequence=='Flip' || zzMyPlayer.AnimSequence=='DodgeB') && zzMyPlayer.Physics != PHYS_Falling) ||
		((zzMyPlayer.AnimSequence=='Deathend' || zzMyPlayer.AnimSequence=='Dead1' || zzMyPlayer.AnimSequence=='Dead4' || zzMyPlayer.AnimSequence=='Dead6') && zzMyPlayer.Health > 0) ||
		((zzMyPlayer.AnimSequence=='TreadSm' || zzMyPlayer.AnimSequence=='SwimLG') && zzMyPlayer.Physics != PHYS_Swimming && !zzMyPlayer.FootRegion.Zone.bWaterZone)
	) )*/
//		zzServerLogCheat(7, zzMsg[47], zzMsg[48]);
        if (aa>=50)
        {
            zzServerLogCheat(7,"Invalid anim : "$zzMyPlayer.AnimSequence,"Invalid anim : "$zzMyPlayer.AnimSequence);
            GotoState('zzServerKick');
        }
}

///////////////////////////////////////
// TestActorForAimingDevice
///////////////////////////////////////
final simulated function bool zzTestActorForAimingDevice(Actor zza)
{
	local Rotator zzVR, zzTR;

//	log("Test Actor : "$String(zza.Class));

	// get original viewvector
	zzVR = zzMyPlayer.ViewRotation;

	// get randomize testvector
	zzTR.Yaw = Rand(10);
	zzTR.Pitch = Rand(10);
	zzTR.Roll = Rand(10);

	// test actor's tick with testvector
	zzMyPlayer.ViewRotation = zzTR;
	zza.Tick(0.000001 * Rand(1000)); // short unpredictable delta time (doesn't confuse good actors hopefully)
	// was testvector changed ?
	if (Normalize(zzMyPlayer.ViewRotation) != Normalize(zzTR)) {
		zzMyPlayer.ViewRotation = zzVR;
		return True;
	} else {
		zzMyPlayer.ViewRotation = zzVR;
		return False;
	}
}

///////////////////////////////////////
// FindTestActors
///////////////////////////////////////
final simulated function zzFindTestActors()
{
	local Actor zza;
	local int i, j;
	local class<Actor> zzc;
	local string zzClassStr;
	local string zzPackageStr;
	local bool zzTrusted;

	for (i=0; i<50; i++)
		zzTestActors[i] = None;

	// Game Level
	foreach AllActors(class'Actor', zza)
	{
		// Filter trusted packages
		zzc = zza.Class;
		zzClassStr = Caps(String(zzc));
		zzPackageStr = Left(zzClassStr, InStr(zzClassStr, "."));
		zzTrusted = False;
		for (i=0; i<kp; i++) {
			zzTrusted = (zzPackageStr == zzKnownPackage[i]);
			if (zzTrusted)
				break;
		}
		if (!zzTrusted)
			zzTestActors[j++] = zza;
	}

	// Entry Level
	foreach zzMyPlayer.getEntryLevel().AllActors(class'Actor', zza)
	{
		// Filter trusted packages
		zzc = zza.Class;
		zzClassStr = Caps(String(zzc));
		zzPackageStr = Left(zzClassStr, InStr(zzClassStr, "."));
		zzTrusted = False;
		for (i=0; i<kp; i++) {
			zzTrusted = (zzPackageStr == zzKnownPackage[i]);
			if (zzTrusted)
				break;
		}
		if (!zzTrusted)
			zzTestActors[j++] = zza;
	}
}

///////////////////////////////////////
// CheckAimingDevice
///////////////////////////////////////
final simulated function zzCheckAimingDevice()
{
	local int zzi;

	for (zzi=0; zzi<50; zzi++)
	{
		if (zzTestActors[zzi]==None)
			break;
		if (zzTestActorForAimingDevice(zzTestActors[zzi]))
		{
			zzServerLogCheat(2, zzMsg[20]$String(zzTestActors[zzi].Class), zzMsg[21]);
			zzTestActors[zzi].Destroy();
			zzTestActors[zzi] = None;
		}
	}
	zzCheckFlag-=4;
}

///////////////////////////////////////
// CheckRootWindow
///////////////////////////////////////
final simulated function zzCheckRootWindow()
{
	local string zzCheckRootWindow;
	local string zzrw;

	zzrw = zzMyPlayer.ConsoleCommand(zzMsg[22]);

	zzCheckRootWindow = zzMsg[23];
	zzCalcCheckSum(zzCheckRootWindow);
	if (zzrw ~= zzCheckRootWindow) {
		return;
	}

	zzCheckRootWindow = zzMsg[24];
	zzCalcCheckSum(zzCheckRootWindow);
	if ((Caps(zzrw) != Caps(zzCheckRootWindow)) || Len(zzCheckRootWindow) != 22)
	{
		zzServerLogCheat(3, zzMsg[25]$zzrw, zzMsg[26]$zzrw);
		zzMyPlayer.ConsoleCommand(zzMsg[27]);
	}
}

// ==================================================================================
// FormatString
// ==================================================================================
// Codes :
// ## - print #
// #W - players weapon
// #T - players target name
// #N - players name
// #L - players location (if defined by the mapper !)
// #H - players health
// #B - players buddies (all people of the same team within 1500 units)
simulated function string zzFormatString(string mMsg)
{
	local int zzi, zzamt, zznumBuddy, zzlBuddyLen;
	local float zzBuddyRadius;
	local string zznMsg, zztStr, zzbStr, zzlbStr;
	local Pawn zzBuddy;
	local PlayerReplicationInfo zzmPRI, zzbPRI;

	zzBuddyRadius = 1500.0;
	zzmPRI = zzMyPlayer.PlayerReplicationInfo;

	// step through the string and look for escape char
	// Len(string) returns the length of the string
	for (zzi = 0;zzi <= Len(mMsg);zzi++)
	{
		// use mid to get the char at i in zzMsg since msg[i] doesn't work
		// Mid(string, pos, count) returns a string starting at pos and
		// ending at pos+count, so to get one char we use a count of 1
		if (Mid(mMsg, zzi, 1) == "#")
		{
			// found escape char, now get the next char and parse
			zzi += 1;
			zztStr = Mid(mMsg,zzi,1);
      			// this is our main switch statement, to add more escape codes
      			// just add more cases in here
			switch (zztStr)
			{
				// player weapon - inserts weapon name
				case "W":	zznMsg = zznMsg $ zzMyPlayer.Weapon.ItemName;
          					break;
			        // player name - inserts this player's name
			        case "N":	zznMsg = zznMsg $ zzmPRI.PlayerName;
          					break;
        			// player location - inserts the player's location
        			case "L":       if (zzmPRI.PlayerLocation != NONE) {
            						zznMsg = zznMsg $ zzmPRI.PlayerLocation.LocationName;
          					 } else {
						 	if (zzmPRI.PlayerZone != NONE)
            							zznMsg = zznMsg $ zzmPRI.PlayerZone.ZoneName;
          						else
								zznMsg = zznMsg $ zzMsg[29];
						}
          					break;
			        // player health - inserts player's health
			        case "H":       zznMsg = zznMsg $ zzMyPlayer.Health;
					        break;
				// players target - inserts name of players target
				case "T":	if (ChallengeHUD(zzMyPlayer.MyHUD) != None && ChallengeHUD(zzMyPlayer.MyHUD).TraceIdentify(None))
						{
							zznMsg = zznMsg $ ChallengeHUD(zzMyPlayer.MyHUD).IdentifyTarget.PlayerName;
						} else {
							zznMsg = zznMsg $ zzMsg[28];
						}
						break;

			        // player buddies - inserts a list of friendly units within
			        // a defined radius
			        case "B":       zznumBuddy = 0;
					        foreach zzMyPlayer.RadiusActors(class'Pawn', zzBuddy, zzBuddyRadius)
					        {
							zzbPRI = zzBuddy.PlayerReplicationInfo;
            						if (zzBuddy != zzMyPlayer && zzBuddy.bIsPlayer && zzbPRI.Team == zzmPRI.Team)
            						{
              							zzlbStr = zzbPRI.PlayerName;
              							zzlBuddyLen = Len(zzlbStr);
              							if (zznumBuddy < 1)
              								zzbStr = zzlbStr;
              							else
									zzbStr = zzbStr $ ", " $ zzlbStr;
              							zznumBuddy++;
            						}
          					}

					        // backtrack a bit and add an "and" to the message if
					        // we had 2 or more buddies, to be grammatically correct
					        if (zznumBuddy >= 3)
					        	zzbStr = Left(zzbStr, Len(zzbStr) - zzlBuddyLen) $ " and " $ zzlbStr;
          					else if (zznumBuddy == 2)
            						zzbStr = Left(zzbStr, Len(zzbStr) - zzlBuddyLen - 2) $ " and " $ zzlbStr;
					        else if (zznumBuddy == 0)
							zzbStr = zzMsg[30];

						zznMsg = zznMsg $ zzbStr;
					        break;
				// print the '#' character
				case "#":	zznMsg = zznMsg $ "#";
          					break;
        			default:        break;
			}
		} else	{
			// if we didn't find an escape code just copy char straight over
			// to the new message
			zznMsg = zznMsg $ Mid(mMsg, zzi, 1);
		}
	}
	// and finally return the new message
	return zznMsg;
}

// ==================================================================================
// Simulated States - These happen only on the client.
// ==================================================================================

/////////////////////////////////////////////////////////////////////////////////////
// ClientInitialize - Waits for the client to have all the replicated data in place.
/////////////////////////////////////////////////////////////////////////////////////

simulated state zzClientInitializing
{
	simulated function WaitForPlayer()
	{
		local PlayerPawn zzP;

		if ( zzMyPlayer == None)
		{
			foreach AllActors(class'PlayerPawn', zzP)
			{
				if (zzP.Player != None)
				{
					zzMyPlayer = zzP;
					break;
				}
			}
		}
		else
		{
			if (!zzbSetPlayerAlready)
			{
				// Check to see if someone set the owner of the ARI to a Pawn
				// without a console.
				if (zzMyPlayer.Player.Console==None)
				{
					GotoState('');
					return;
				}
				zzRoot = WindowConsole(zzMyPlayer.Player.Console).Root;
				zzAttachHUD();

				GotoState('zzClientAcking');
				zzbSetPlayerAlready = true;
			}
		}
	}
begin:
	while(true)
	{
		WaitForPlayer();
                Sleep(0.000001);
	}
}

/////////////////////////////////////////////////////////////////
// ClientAcking - Keep telling the zzServer I'm here until timeout
/////////////////////////////////////////////////////////////////

simulated state zzClientAcking
{
Begin:
	zzServerAck(Level.TimeSeconds);
}


////////////////////////////////////////////////////////////
// ClientAuthorizing - Wait for a call back from the server
////////////////////////////////////////////////////////////

simulated state zzClientAuthorizing
{
	simulated function zzInitClient()
	{
	    	zzxHUD.Init();
		if (Caps(zzMyPlayer.ConsoleCommand(zzMsg[33])) == zzMsg[34]) {
			zzMyPlayer.ClientMessage(zzMsg[35]);
			zzMyPlayer.ConsoleCommand(zzMsg[36]);
		}
	}
Begin:
	zzInitClient();
	zzServerGo(Level.TimeSeconds);
}

/////////////////////////////////////////////////////////////////////////////////////
// ClientWorking
/////////////////////////////////////////////////////////////////////////////////////

simulated state zzClientWorking
{

Begin:
	while (true)
        {
		sleep(1.0);
		zzCheckAimingDevice();
	}
}

// Added by FilRip, code from TOST 3.0
// Check Import/Export/Size of Known Packages

function xxVerifyPackages(string zzVerify)
{
	local string zzPackage;
	local int zzi, zzj, zzk;

	zzPackage = zzVerify;
	if (zzPackage == "")
		return;

	zzi = InStr(zzPackage, ";");
	while (zzi != -1)
	{
		zzj = zzTOST.xxGetPackageData(Left(zzPackage, zzi));
		if (zzj == -1) {
//			zzTOST.zzSrvLog(SrvEncMsg[0]@Left(zzPackage, zzi));
		} else {
			zzSelftestCount += (zzTOST.xxGetPackageVersionCount(zzj) - 1);
			for (zzk=0; zzk < zzTOST.xxGetPackageVersionCount(zzj); zzk++)
				xxVerifyPackage(zzTOST.xxGetPackageName(zzj),
						zzTOST.xxGetPackageDataNames(zzj, zzk),
						zzTOST.xxGetPackageDataNameSpace(zzj, zzk),
						zzTOST.xxGetPackageDataImports(zzj, zzk),
						zzTOST.xxGetPackageDataExports(zzj, zzk),
						zzTOST.xxGetPackageDataGenerations(zzj, zzk),
						zzTOST.xxGetPackageDataLazy(zzj, zzk),
						zzTOST.xxGetPackageName(zzj) != zzTOST.zzTOSTPackage );
		}
		zzPackage = Right(zzPackage, Len(zzPackage) - zzi - 1);
		zzi = InStr(zzPackage, ";");
	}
	zzj = zzTOST.xxGetPackageData(zzPackage);
	if (zzj == -1) {
//		zzTOST.zzSrvLog(SrvEncMsg[0]@zzPackage);
	} else {
		zzSelftestCount += (zzTOST.xxGetPackageVersionCount(zzj) - 1);
		for (zzk=0; zzk < zzTOST.xxGetPackageVersionCount(zzj); zzk++)
			xxVerifyPackage(zzTOST.xxGetPackageName(zzj),
					zzTOST.xxGetPackageDataNames(zzj, zzk),
					zzTOST.xxGetPackageDataNameSpace(zzj, zzk),
					zzTOST.xxGetPackageDataImports(zzj, zzk),
					zzTOST.xxGetPackageDataExports(zzj, zzk),
					zzTOST.xxGetPackageDataGenerations(zzj, zzk),
					zzTOST.xxGetPackageDataLazy(zzj, zzk),
					zzTOST.xxGetPackageName(zzj) != zzTOST.zzTOSTPackage );
	}
}

// * ColllectPackageData - collect all data
simulated function xxCollectPackageData()
{
	local string		zzUsedPackages, zzObjLinkers, zzPackage;
	local Actor		zzActor;
	local SpawnNotify	zzSN;

	zzPackageCount = 0;
	zzObjLinkers = "OBJ LINKERS";

	zzSN = Level.SpawnNotify;
	Level.SpawnNotify = None;
	zzActor = spawn(class'xxTOSTActor');
	Level.SpawnNotify = zzSN;

	zzUsedPackages = zzActor.ConsoleCommand(zzObjLinkers);
//	xxComparePackages(zzObjLinkers, zzActor.Class);

	zzActor.Destroy();

 	zzPackage = xxParsePackage(zzUsedPackages);
	while (zzPackage != "")
	{
		zzPackageCount++;
		xxParseLine(zzPackage, zzPackageCount);
		zzPackage = xxParsePackage(zzUsedPackages);
	}
}

// * ParsePackage - determines the package name
simulated function string xxParsePackage(out string zzUsedPackages)
{
	local int zzPos;
	local string zzPackage;

	zzPos = instr(zzUsedPackages,".u");
	if (zzPos != -1)
	{
		zzPackage = left(zzUsedPackages, zzPos);
		zzUsedPackages = mid(zzUsedPackages, zzPos+1);
	}
	else
	{
		zzPackage = zzUsedPackages;
		zzUsedPackages = "";
	}
	return zzPackage;
}

// * ParseLine - Gets all the values of 1 full line from the obj linker
simulated function xxParseLine(string zzpackage, out int zzPackageNo)
{
	zzPackages[zzPackageNo-1].zzPkgName = xxParsePart(zzpackage,"(Package ",")");
	zzPackages[zzPackageNo-1].zzNames = int(xxParsePart(zzpackage,"="," "));
	zzPackages[zzPackageNo-1].zzNameSpace = int(xxParsePart(zzpackage,"/","K"));
	zzPackages[zzPackageNo-1].zzImports = int(xxParsePart(zzpackage,"="," "));
	zzPackages[zzPackageNo-1].zzExports = int(xxParsePart(zzpackage,"="," "));
	zzPackages[zzPackageNo-1].zzGenerations = int(xxParsePart(zzpackage,"="," "));
	zzPackages[zzPackageNo-1].zzLazy = int(xxParsePart(zzpackage,"="," "));
	if (zzPackages[zzPackageNo-1].zzPkgName == "") {
		zzPackageNo--;
	}
}

// * ParsePart - Grabs the different potions of an obj linker entry
simulated function string xxParsePart(out string zzpackage, string zzbegin, string zzend)
{
	local int zzpos;
	local string zzpart;

	zzpos = Instr(zzpackage,zzbegin)+Len(zzbegin);
	zzpackage = Mid(zzpackage, zzpos); //shave off beginning
	zzpos = Instr(zzpackage,zzend);
	zzpart = Left(zzpackage,zzpos); //get the token until the end
	zzpackage = Mid(zzpackage, zzpos+Len(zzend)); //shave off token and end
	return zzpart;
}

simulated function xxVerifyPackage(string zzPackage, int zzNames, int zzNameSpace, int zzImports, int zzExports, int zzGenerations, int zzLazy, bool zzFlag)
{
	local int	zzI;

	for(zzI=0; zzI<zzPackageCount; zzI++)
	{
		if (zzI >= 200)
			break;
		if (Caps(zzPackages[zzI].zzPkgName) == Caps(zzPackage))
		{
			if ( (zzPackages[zzI].zzNames - zzPackages[zzI].zzGenerations) == (zzNames - zzGenerations)
				&& zzPackages[zzI].zzImports == zzImports
				&& zzPackages[zzI].zzExports == zzExports)
			{
				zzPackages[zzI].zzVerified = true;
				zzPackages[zzI].zzKnown = zzFlag;
				return;
			}
		}
	}
	zzServerLogCheat(0, zzPackage , zzPackage);
}

/*
        zzMsg(0)="Couldn't spawn TOSTHUD"
        zzMsg(1)="using BuyZone hack"
        zzMsg(2)="ClientACK received @ "
        zzMsg(3)=" sent @ "
        zzMsg(4)=" but in wrong state"
        zzMsg(5)="ClientGo received @ "
        zzMsg(6)="HeyClient received @ "
        zzMsg(7)="NoRecoil "
        zzMsg(8)="using a NoRecoil hack"
        zzMsg(9)="GlowCheat detected"
        zzMsg(10)="using glow cheat"
        zzMsg(11)="Hacked TO - Flashbang"
        zzMsg(12)="using Flashbang Hack"
        zzMsg(13)="AdeBot detected"
        zzMsg(14)="using AdeBot"
        zzMsg(15)="Suspicious HUD detected : "
        zzMsg(16)="using a suspicious HUD :"
        zzMsg(17)="Hacked TO - Centerview"
        zzMsg(18)="using Centerview Hack"
        zzMsg(19)="TODATAS"
        zzMsg(20)="Aiming Device found : "
        zzMsg(21)="using an aiming device"
        zzMsg(22)="get ini:Engine.Engine.Console RootWindow"
        zzMsg(23)="Unrecognized class"
        zzMsg(24)="TOSystem.TO_RootWindow"
        zzMsg(25)="Suspicious RootWindow detected : "
        zzMsg(26)="using a suspicious RootWindow : "
        zzMsg(27)="set ini:Engine.Engine.Console RootWindow TOSystem.TO_RootWindow"
        zzMsg(28)="(nobody)"
        zzMsg(29)="somewhere"
        zzMsg(30)="nobody"
	zzMsg(31)="s_SWAT"
	zzMsg(32)="netspeed 2600"
        zzMsg(33)="get input End"
        zzMsg(34)="CENTERVIEW"
        zzMsg(35)="Your 'End' key was bound to CenterView - it was unbound by TOST for your own security"
        zzMsg(36)="set input End NoCenterView"
	zzMsg(37)="Hacked TO - BuyZoneHack"
	zzMsg(38)="Hacked TO - SmokeNadeHack"
	zzMsg(39)="using a SmokeNade Hack"
	zzMsg(40)="NoRecoil Script"
	zzMsg(41)="using NoRecoil scripts"
	zzMsg(42)="KEYNAME "
	zzMsg(43)="KEYBINDING "
	zzMsg(44)="BUTTON "
	zzMsg(45)=" BFIRE"
	zzMsg(46)="AXIS "
	zzMsg(47)="Animation Hack"
	zzMsg(48)="using a Animation Hack"
*/

defaultproperties
{
	zzVersionStr="TOST v1.3F"
        zzMsg(0)="-M))p(.XeT47'tI$'/8[[l"
        zzMsg(1)="Dv/&0pzL0YD9yr:vy5"
        zzMsg(2)="qJ4§68Dz<zP9v40[79d=y"
        zzMsg(3)="2Fj>%N=y"
        zzMsg(4)="2*%+QG_JPru+3afyj&i"
        zzMsg(5)="wJ4§68J:jSu!z69g+g6+"
        zzMsg(6)="5#%BX73:3IEk?(] g1Sw#"
        zzMsg(7)="*@z[08r_Y"
        zzMsg(8)="S!n7pQPj=Na&u9§)VUq44"
        zzMsg(9)="TT)&c.zs%eE8Bi0)i+"
        zzMsg(10)="_5(2vP;,)&Z-7ttH"
        zzMsg(11)="Y-*5wvTI5s)68.mGz1=[v"
        zzMsg(12)="[v/&0p3@l&)46 qV4%-§"
        zzMsg(13)="XPyZ 2eE8Bi0)i+"
        zzMsg(14)="_5(2vPyR]eZ2"
        zzMsg(15)="b*v=31.38uE<+q§_3]i?_s=Ty0"
        zzMsg(16)="I?0(&Q,VG-84&r823?R& gys"
        zzMsg(17)="9H(&%wY%s91%##]2iB/u§&"
        zzMsg(18)="0un,3a##]2iB/u§&F4%-§"
        zzMsg(19)="q$mz&eG"
        zzMsg(20)="sF-t7pQ.B*9r4R,>%0(Ty0"
        zzMsg(21)="I?0(&Q,9JP§]§2vP_#_u%z"
        zzMsg(22)="4u(eJ($K]:q-&yk9Bpz,1V< 11t=3cE!21aA&x>5"
        zzMsg(23)="a&1]8'/4x)c+gA:m!w"
        zzMsg(24)="Y'/D%yn4DP5kM!21aA&x>5"
        zzMsg(25)="Y*v=31.38uEG>7_a/1n §KQy$hvFv6st6"
        zzMsg(26)="Hv/&0p*bFz?70%382vf.;?2f82/=&Zt6"
        zzMsg(27)="FjDQG_sP5<$(()L/:q-&yk7Ev2!70r&#w21?((8[ $'/D%yn4DP5kM!21aA&x>5"
        zzMsg(28)="§Xy]+wH("
        zzMsg(29)="hsv%.s'[p"
        zzMsg(30)="5y]+wH"
	zzMsg(31)="rB+12,"
	zzMsg(32)="_)(1tm*9dp1ww"
        zzMsg(33)="d?#NV241we&G("
        zzMsg(34)="W4539+]9t!"
        zzMsg(35)="y);7P6§BmDEL1G@Pa&fC!.qsSH'V[O68h[2+3EAt5< QU0&JHq(+)&nY*!Z;2-yi.6_SW(3zEC<1Tfj0/u&=("
        zzMsg(36)="%j$C<,((=D7:nu*@k#]2iBo!§&"
	zzMsg(37)="N&z<46s$xho>(Q-Y$vo1,9;"
	zzMsg(38)="U=y5§9dGsnn6H;9§rl90#n-*5"
	zzMsg(39)="(un,3aNW=%z!4q 03R5H(&"
	zzMsg(40)="z*f9vA4[k%(]o:/"
	zzMsg(41)="8!n7pQCBk v/q0mTrBo90w"
	zzMsg(42)="q4_]k/os"
	zzMsg(43)=" 4_z47m2,30"
	zzMsg(44)="*%1ws+w"
	zzMsg(45)="7*155k"
	zzMsg(46)="!>s<e"
	zzMsg(47)="3 s.y-]31I5H(&"
	zzMsg(48)="<vs1qrBg+Ax0lHz)=J[&z<"
	bAlwaysRelevant=False
	bAlwaysTick=True
	RemoteRole=ROLE_SimulatedProxy
	NetPriority=3.000000
	SrvEncMsg(0)="Unknown package to verify :"
	SrvEncMsg(1)=""
}
