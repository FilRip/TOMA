//----------------------------------------------------------------------------//
//	Project	:	TOSTWeaponsServer											  //
//	File	:	TOSTWeaponsServer.uc										  //
//	Version	:	1.0															  //
//	Author	:	H-Lotti														  //
//----------------------------------------------------------------------------//
//	Version	Changes															  //
//	0.1		+ First beta													  //
//	0.2		+ Remasterized the whole things									  //
//	0.x		+ bugs removed (compatible issues with other server, keybind bug) //
//	0.9		+ added c4 support												  //
//	1.0		+ First official beta											  //
//			+ advanced settings support(default + tost)						  //
//			+ remove spectator bug											  //
//	1.1		+ add multi c4 support											  //
//			+ trying cwmode support											  //
//	1.2		+ add detect c4 maps and remove tost c4							  //
//			+ reducing tostweapons pack size								  //
//			+ adding oicw map default										  //
//			+ fixing get a c4 if defused when allready has a nade			  //
//			+ adding reset/endround fixed support							  //
//			+ adding teargas nade support tanx to Slava						  //
//	1.2.1	+ GasMask improved ( no blind | water heal | see text )			  //
//			+ spectator bug fixed (an other)								  //
//			+ internal to grenade bug less buggy							  //
//	1.3		+ TOST42 Compatible												  //
//			+ correction with save/load settings							  //
//----------------------------------------------------------------------------//
//	MsgIdx		Details					Params								  //
//	550			Send_AllWeaponsTeam		string WeaponsTeam					  //
//	551			Send_AWeaponTeam		int WeaponID, int team, int free	  //
//	552			Set_AWeaponTeam			int WeaponID, int team, int free	  //
//	553			Send_ASetting			int Index, String SettingName		  //
//	554			load_ASetting			int Index							  //
//	555			save_ASetting			int Index, String SettingName		  //
//	556			Set_MapMode				int Index, optional string mapname	  //
//	557			Set_DefaultMapMode		int Index							  //
//	558			ServerBuyGasmask		bool								  //
//	559			removeme3hp													  //
//----------------------------------------------------------------------------//

class TOSTWeaponsServer extends TOSTPiece;

const ClientPackage = "TOSTWeaponsClient42";
const Version = 1400;

var byte WeaponTeam[31], WeaponFree[31];
var config string RecordString[10], DefaultMapMode[10];
var config int CurrentDefSettings;
var	config int VersionSettings;//if version mismatch all settings are erased
var config bool showKiller;

var	string	WeaponStr[31], WeaponName[31], WeaponsTeam, randomstream;
var float	WeaponWeight[31];
var	byte	MaxClip[31], ClipSize[31], BackupMaxClip[31], BackupClipSize[31], ItemFree[6], Special[9], RandomWeapon, NextWeaponTeam[31], NextWeaponFree[31], NextItemFree[6], NextSpecial[9], TerrWFree[4], SFWFree[4], Sort[31], MaxRifles[2], Cheaper[31], nbrandomweapon, OICWTeam;
var int 	RandomTime, CheckRandomTime, NextRandomTime;
var bool 	ChangedMode, BRound, CWMode, Desactivated, c4map;
var TO_OICWStartPoint OICWSP;
var byte	roundNB;//used to know if endround during gp=0
var bool	bSteyrPack, bFamasPack, bC4Pack, bTearGasPack;

//----------------------------------------------------------------------------//
//	Comments:																  //
//	index	WeaponTeam[i]	WeaponFree[i]	TO_WeaponsHandler.Weaponname[i]	  //
//	1		1				0				Desert Eagle					  //
//	2		3				0				UZI								  //
//	3		3				0				MP5	(terro)						  //
//	4		3				0				Mossberg						  //
//	5		2				0				AP2								  //
//	6		3				0				AK47							  //
//	7		2				0				HK33							  //
//	.		.				.				.								  //
//	.		.				.				.								  //
//	.		.				.				.								  //
//																			  //
//	weaponTeam 	0 = none, 1 = both, 2 = SF, 3 = Terr, 4 = default(oicw)		  //
//	WeaponFree	0 = not free, 1 = free ( for selected WeaponTeam )			  //
//																			  //
//	special index: i = 0													  //
//	weaponTeam[0]	=	team who can grab the oicw in resurrection,...		  //
//	WeaponFree[0]	=	nothing												  //
//																			  //
//----------------------------------------------------------------------------//


//----------------------------------------------------------------------------//
// TOST Piece general function												  //
//----------------------------------------------------------------------------//

function EventInit()
{
	super.EventInit();

	if ( GetItemName(string(Level.Game.Class)) != "s_SWATGame" )
		destroy();

	//register TOSTWeaponsHUD on client
	Params.param4 = ClientPackage$".TOSTWeaponsHUD";
	SendMessage(160);

	//register TOSTWeaponsTab on client
	Params.param4 = ClientPackage$".TOSTWeaponsTab";
	SendMessage(161);

	//register TOSTWeaponsCommander on client
	Params.param4 = ClientPackage$".TOSTWeaponsCommander";
	SendMessage(164);

}

function EventPostInit()
{
	super.EventPostInit();

	spawn(class'PackageSniffer',self);

	Init_Server();
}

function EventTeamChange(Pawn Other)
{
	Super.EventTeamChange(Other);

	if ( Desactivated )
	{
		setTimer(1.0,false);
		Params.param5 = CWMode;
		BroadcastClientMessage(553);
		return;
	}

	if ( (!Other.PlayerReplicationInfo.bisSpectator) && (!Other.PlayerReplicationInfo.bWaitingPlayer) )
	{
		if ( isRandom() )
			ProcessA_RandomWeapons(PlayerPawn(Other), RandomWeapon);
		else ProcessA_FreeWeapons(PlayerPawn(Other));
	}
}

function EventGamePeriodChanged (int GP)
{
	super.EventGamePeriodChanged(GP);

	if ( GP == 0 )
		BeginRound();

	if ( (GP == 1) && (isRandom()) )
	{
		CheckRandomTime = 0;
		ProcessAll_RandomWeapons();
	}
}

function bool EventBeforePickup (Pawn Other, Inventory Item, out byte bAllowPickup)
{
	local Class<Actor> InputClass;
	local Inventory PlayerItem;
	local int Clip, PlayerClip;

	if ( Desactivated )
	return Super.EventBeforePickup(Other,Item,bAllowPickup);

	if ((Item.isa('TOST_C4')) && (Other.findinventorytype(Class<Actor>(DynamicLoadObject("TOSTWeapons42.TOSTGrenade",Class'Class'))) != none))
	{
		return true;
	}

	if( Special[3] == 0 || !Item.isa('TOSTWeapon') )
		return Super.EventBeforePickup(Other,Item,bAllowPickup);

	PlayerItem = Other.findinventorytype(Item.class);

	if ( PlayerItem != none)
	{
		Clip = s_weapon(PlayerItem).RemainingClip;

		s_weapon(PlayerItem).RemainingClip += s_weapon(Item).RemainingClip;
		if ( s_weapon(PlayerItem).RemainingClip > s_weapon(PlayerItem).MaxClip )
			s_weapon(PlayerItem).RemainingClip = s_weapon(PlayerItem).MaxClip;

		Clip = s_weapon(PlayerItem).RemainingClip - Clip;

		if ( Clip > 0)
		{
			Other.ReceiveLocalizedMessage(Class'PickupMessagePlus',0,None,None,class'TOSTWeapons42.TOST_EmptyWeapon');
			Item.PlaySound(Item.PickupSound);
		}

		s_weapon(Item).RemainingClip -= Clip;

		return true;
	}
	return Super.EventBeforePickup(Other,Item,bAllowPickup);
}

function bool EventCheckReplacement (Actor Other, out byte bSuperRelevant)
{
    local int i;

	if ( Other.isa('TOST_ExplosiveC4') )
	{
		TOST_ExplosiveC4(Other).CanBeShooted = ( Special[6] == 1 );
	}

	else if ( (Other.isa('TOST_Grenade')) || (Other.isa('TOST_GrenadeConc')) || (Other.isa('TOST_GrenadeFB')) )
	{
		TOSTGrenade(Other).NadeModeEnabled = ( Special[7] == 1 );
	}

    else if ( Other.isa('TOST_EmptyWeapon') )
    {
    	return false;
    }

	else if ( Other.isa('TOSTWeapon') && !Other.isa('TOSTGrenade') )
	{
	    i = GetIdByClass(String(other.class));
	    if ( i != -1)
    	{
            if (Special[0] == 1)
            {
    	    	s_weapon(other).RemainingClip = s_weapon(other).maxClip;
   	    		s_weapon(other).BackupClip = s_weapon(other).BackupMaxClip;
    	    }
	    }
	}

    if ( Other.isa('s_C4') )
	{
		if ( (NextSpecial[1] == 0) && (!Desactivated) )
			return false;
	}

	return Super.EventCheckReplacement(Other,bSuperRelevant);
}

//dont take damage if ffnade=off && damage = explosion
function EventTakeDamage( out int ActualDamage, Pawn Victim, Pawn InstigatedBy, out Vector HitLocation, out vector Momentum, name DamageType)
{
	if ( (DamageType == 'Explosion') && (!s_SWATGame(level.game).bExplosionFF) && (Victim != none) && (InstigatedBy != none ) && (Victim.PlayerReplicationInfo != none)  && (InstigatedBy.PlayerReplicationInfo != none) &&(Victim.PlayerReplicationInfo.Team == InstigatedBy.PlayerReplicationInfo.Team) )
	{//if ffnade off dont do a shit to our peeps if damage = explosion
		ActualDamage = 0;
	}
	else if ( NextPiece != None )
		NextPiece.EventTakeDamage(ActualDamage, Victim, InstigatedBy, HitLocation, Momentum, DamageType);
}

//extra, show the killer to the dead man
function bool EventPreventDeath(Pawn Killed, Pawn Killer, name damageType, vector HitLocation)
{// instant show killer
	local ShowKiller tmp;

	if ( !Desactivated && showKiller )
	{
		if ( Killed != Killer && PlayerPawn(Killed) != none && Killer != none && Killer.playerReplicationInfo != none )
		{
			tmp = spawn(class'ShowKiller',Killed);
			tmp.Killer = Killer.playerReplicationInfo.PlayerName;
			tmp.father = self;
		}
	}
	return Super.EventPreventDeath(Killed, Killer, DamageType, HitLocation);
}
//----------------------------------------------------------------------------//
// TOST Piece Message function												  //
//----------------------------------------------------------------------------//
function bool EventCheckClearance(TOSTPiece Sender, PlayerPawn Player, int MsgType, out int Allowed)
{
	local bool b;

	b =	super.EventCheckClearance(Sender, Player, MsgType, Allowed);

	if ( ((MsgType == BaseMessage+2) || (MsgType == BaseMessage+4) ) && (Player.bAdmin))
	{
		Allowed = 1;
		return true;
	}

	if ( ((MsgType == 110) || (MsgType == 111) ) && (Player.bAdmin))
	{
		Allowed = 1;
		return true;
	}

	if ( (MsgType == BaseMessage) || (MsgType == BaseMessage+1) || (MsgType == BaseMessage+3) || (MsgType == BaseMessage+8) || (MsgType == BaseMessage+9) )
	{
	    Allowed = 1;
	    return true;
	}

	return b;
}

function EventMessage(TOSTPiece Sender, int MsgIndex)
{
	switch (MsgIndex)
	{
		// saendround
		case 110			:	BeginRound();
								break;
		// saadminreset
		case 111			:	BeginRound();
								break;
		// GetSettings
		case 143 			:	GetSettings(Sender);
								break;
		// CWModeChanges
		case 117			:	CWMode = Sender.Params.Param5;
								break;
		// SendAllWeaponsTeam And Free Guns
		case BaseMessage	:	Send_AllWeaponsTeam(Sender.Params.Param6);
								if ( isRandom() )
									ProcessA_RandomWeapons(Sender.Params.Param6, RandomWeapon);
								else ProcessA_FreeWeapons(Sender.Params.Param6);
	                            break;
	    // SendAWeaponTeam
	    case BaseMessage+1  :   Send_AWeaponTeam(Sender.Params.Param6, Sender.Params.Param1);
	                            break;
	    // SetAWeaponTeam
	    case BaseMessage+2  :   Set_AWeaponTeam(Sender.Params.Param6, Sender.Params.Param1, Sender.Params.Param2, int(Sender.Params.Param3));
	                            break;
	    // SendAWeaponTeam
	    case BaseMessage+3  :   Send_ASetting(Sender.Params.Param6, Sender.Params.Param1);
	                            break;
	    // SetLoad
	    case BaseMessage+4  :   Load_ASetting(Sender.Params.Param1);
	                            break;
	    // SetSave
	    case BaseMessage+5  :   Save_ASetting(Sender.Params.Param6, Sender.Params.Param1, Sender.Params.Param4);
	                            break;
	    // Set_mapmode
	    case BaseMessage+6  :   Set_MapMode(Sender.Params.Param6, Sender.Params.Param1, Sender.Params.Param4);
	                            break;
	    // Set_Defaultmapmode
	    case BaseMessage+7  :   Set_DefaultMapMode(Sender.Params.Param6, Sender.Params.Param1);
	                            break;
	    // ServerBuyGasmask
	    case BaseMessage+8  :   ServerBuyGasmask(Sender.Params.Param6,bool(Sender.Params.param1),Sender.Params.Param5);
	                            break;
	    // Removeme3hp
	    case BaseMessage+9  :   Sender.Params.Param6.health -= 3;
	                            break;
	}

	super.EventMessage(Sender, MsgIndex);
}

function EventAnswerMessage(TOSTPiece Sender, int MsgIndex)
{
	switch (MsgIndex)
	{
		// SetSettings - report back error messages
		case 144 			:	SetSettings(Sender, Sender.Params.Param4);
								break;
	}
}


//----------------------------------------------------------------------------//
// TOSTWeaponsServer Init functions											  //
//----------------------------------------------------------------------------//
function BeginRound()
{
	local TOSTWeapon tmp;

	if ( CWMode && !Desactivated )
		Desactivate();
	if ( !CWMode && Desactivated )
		Init_Server();

	Params.param5 = CWMode;
	BroadcastClientMessage(553);

	if ( Desactivated )
		return;

    if ( ChangedMode )
	{
	    ChangedMode = false;
	    Build_FreeWeapons();
		Create_NewWeaponsSettings();
		Set_WeaponsTeam();
		Build_WeaponsTeam_Stream();
		Set_OICWStartPoint_Properties();
		SendAll_AllWeaponsTeam();
		Set_C4Shootable();
		Set_NadeTimer();
	}
	if ( isRandom() )
		ProcessAll_RandomWeapons();
	else ProcessAll_FreeWeapons();

	foreach AllActors(class'TOSTWeapon',tmp)
		if ( tmp.owner == none )
			tmp.destroy();

	Params.param1 = ItemFree[5];
	BroadcastClientMessage(555);// reset all gas

	BRound = true;
}

function Init_Server()
{
	ChangedMode = false;
	desactivated = false;
	c4map = false;

	roundNB = s_SWATGame(Level.Game).RoundNumber;

    setTimer(3.0, true);

	RemoveAll_Weapons();
	CheckVersion();
	Init_C4_Properties();
	Init_OICWStartPoint_Properties();
	Load_MapDefault();
    Init_WeaponsSpec();
    Init_WeaponHandler();
    Init_DefaultWeapons();
	Set_OICWStartPoint_Properties();
    Set_WeaponsTeam();
    Build_WeaponsTeam_Stream();
	Build_FreeWeapons();
	Set_LightWeapons();
	Set_CrazyWeapons();
	Set_C4Shootable();
	Set_NadeTimer();
}

function Init_WeaponsSpec()
{
	class'TearGasPack42.TOST_ProjGasGren'.default.Piece = self;

    class's_SWAT.s_OICW'.default.BackupAmmo = 4;
    class'TOSTWeapons42.TOST_OICW'.default.BackupAmmo = 4;
    class'TOSTWeapons42.TOST_OICW'.default.BackupClip = 0;
	class'TOSTWeapons42.TOST_OICW'.default.RemainingClip=0;
    class'TOSTWeapons42.TOST_OICW'.default.Price = 16000;
}

function Init_WeaponHandler()
{
	local int i;
	for ( i=1;i<25;i++)
	{
		class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i] = WeaponStr[i];
		class'TOModels.TO_WeaponsHandler'.default.WeaponName[i] = WeaponName[i];
		class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[i] = WT_NONE;
	}

	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[25] = "FamasPack42.TOSTFAMAS";
	class'TOModels.TO_WeaponsHandler'.default.WeaponName[25] = "FAMAS";
	class'TOModels.TO_WeaponsHandler'.default.BuyMenuScale[25] = 1.0;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[25] = WT_NONE;
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[26] = "SteyrAugPack42.TOSTSteyrAug";
	class'TOModels.TO_WeaponsHandler'.default.WeaponName[26] = "SteyrAug";
	class'TOModels.TO_WeaponsHandler'.default.BuyMenuScale[26] = 1.0;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[26] = WT_NONE;
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[27] = "TOSTWeapons42.TOST_OICW";
	class'TOModels.TO_WeaponsHandler'.default.WeaponName[27] = "OICW";
	class'TOModels.TO_WeaponsHandler'.default.BuyMenuScale[27] = 1.0;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[27] = WT_NONE;
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[28] = "TearGasPack42.TOST_GrenadeGas";
	class'TOModels.TO_WeaponsHandler'.default.WeaponName[28] = "Teargas Grenade";
	class'TOModels.TO_WeaponsHandler'.default.BuyMenuScale[28] = 1.0;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[28] = WT_NONE;
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[29] = "C4Pack42.TOST_C4Lazer";
	class'TOModels.TO_WeaponsHandler'.default.WeaponName[29] = "Lazer C4";
	class'TOModels.TO_WeaponsHandler'.default.BuyMenuScale[29] = 1.0;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[29] = WT_NONE;
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[30] = "C4Pack42.TOST_C4Timer";
	class'TOModels.TO_WeaponsHandler'.default.WeaponName[30] = "Timer C4";
	class'TOModels.TO_WeaponsHandler'.default.BuyMenuScale[30] = 1.0;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[30] = WT_NONE;
}

function Init_DefaultWeapons()
{
    local s_SWATGame SG;

    foreach allactors(class's_SWATGame',SG)
    {
        SG.DefTeamWeapon[0]=class'TOSTWeapons42.TOST_EmptyWeapon';
        SG.DefTeamWeapon[1]=class'TOSTWeapons42.TOST_EmptyWeapon';
    }
}

function Init_C4_Properties()
{
    local s_ZoneControlPoint tmp;

	foreach allactors(class's_ZoneControlPoint',tmp)
	{
		if ( tmp.bBombingZone )
			c4map = true;
	}
}

function Init_OICWStartPoint_Properties()
{
    local TacticalOpsMapActors TOMA;

    foreach allactors(class'TacticalOpsMapActors', TOMA)
        if ( TOMA.isA('TO_OICWStartPoint') )
        {
            OICWSP = TO_OICWStartPoint(TOMA);
            OICWTeam = OICWSP.CanPickupOICW;
            if ( OICWTeam  == 0 )
            	OICWTeam = 3;
            else if ( OICWTeam == 1 )
            	OICWTeam = 2;
            else
            	OICWTeam = 0;
        }

	if ( OICWSP != none )
	{
	    TOMA = OICWSP;
	    OICWSP = spawn(class'TOSTWeapons42.TOST_OICWStartPoint',TOMA.Owner,TOMA.Tag,TOMA.Location,TOMA.Rotation);
	    TOMA.destroy();
	}
}


//----------------------------------------------------------------------------//
// TOSTWeaponsServer Setup functions										  //
//----------------------------------------------------------------------------//
function Create_NewWeaponsSettings()
{
    local int i;

    for(i=0;i<31;i++)
    {
		WeaponTeam[i] =	NextWeaponTeam[i];
        WeaponFree[i] = NextWeaponFree[i];
        if ( i < 9 )
        {
        	if ( (i == 2) && (Special[i] != NextSpecial[i]) )
				Set_LightWeapons();
        	if ( (i == 4) && (Special[i] != NextSpecial[i]) )
				Set_CrazyWeapons();
        	Special[i] = NextSpecial[i];
        	if ( i < 6 )
        	{
        		ItemFree[i] = NextItemFree[i];
        	}
        }
    }
    RandomTime = NextRandomTime;
}

function Set_WeaponsTeam()
{
    local int i;

    for(i=1; i<31; i++)
    {
    	if ( WeaponTeam[i] == 0 )
            class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[i] = WT_None;
    	else if ( WeaponTeam[i] == 1 )
            class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[i] = WT_Both;
    	else if ( WeaponTeam[i] == 2 )
            class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[i] = WT_SpecialForces;
        else class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[i] = WT_Terrorist;
    }
}

function Build_WeaponsTeam_Stream()
{
    local int i;

    WeaponsTeam = "";
    randomstream = "";
    nbrandomweapon = 0;

    for (i=1; i<31; i++)
    	if ( !isRandom() )
        	WeaponsTeam = WeaponsTeam $ class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[i] $ ";";
        else
		{
			WeaponsTeam = WeaponsTeam $"0;";
			if (class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[i] != 0)
			{
				nbrandomweapon++;
				randomstream = randomstream$i$";";
			}
		}
    WeaponsTeam = WeaponsTeam $ Special[2] $ ";";
    WeaponsTeam = WeaponsTeam $ Special[4] $ ";";
}

function Set_OICWStartPoint_Properties()
{
    if ( OICWSP == none )
        return;

	if ( WeaponTeam[0] == 0 )
		TOST_OICWStartPoint(OICWSP).bCanPickup = false;
	else TOST_OICWStartPoint(OICWSP).bCanPickup = true;

    if ( WeaponTeam[0] == 1 )
        OICWSP.CanPickupOICW = ET_Both;
    else if ( WeaponTeam[0] == 2 )
        OICWSP.CanPickupOICW = ET_SpecialForces;
    else if ( WeaponTeam[0] == 3 )
		OICWSP.CanPickupOICW = ET_Terrorists;
    else if ( WeaponTeam[0] == 4 )
    {
	    if ( OICWTeam == 1 )
	        OICWSP.CanPickupOICW = ET_Both;
	    else if ( OICWTeam == 2 )
	        OICWSP.CanPickupOICW = ET_SpecialForces;
	    else if ( OICWTeam == 3 )
			OICWSP.CanPickupOICW = ET_Terrorists;
    }
}

function Set_AWeaponTeam(playerpawn sender, int WeaponID, int WeaponTeam, int Free)
{
	if ( (WeaponID == 14) && (!bFamasPack) )
	{
		sender.clientmessage("This Server doesn't support that feature");
		return;
	}
	else if ( (WeaponID == 19) && (!bSteyrPack) )
	{
		sender.clientmessage("This Server doesn't support that feature");
		return;
	}
	else if ( (WeaponID == 28) && (!bTearGasPack) )
	{
		sender.clientmessage("This Server doesn't support that feature");
		return;
	}
	else if ( ((WeaponID == 29)||(WeaponID == 30)) && (!bC4Pack) )
	{
		sender.clientmessage("This Server doesn't support that feature");
		return;
	}
	else if ( (WeaponID >= 0) && (WeaponID <= 30 ) )
	{
		if ( WeaponID>= 29 && WeaponID <= 30 && NextSpecial[1] == 1 && c4map )//tostc4 unallowed
			WeaponTeam = 0;
		//check that there is not too much rifles for a team(8 max)
		if ( (WeaponID >= 12) && (WeaponID <= 23) )
		{
			//Calc_MaxRifles(); --> try to remove with new buymenu
			//WeaponTeam = Check_MaxRifles(NextWeaponTeam[Cheaper[WeaponID]], WeaponTeam);
		}

		//check for free
		if ( Free == 1 )
			Free = int(Check_FreeWeapons(WeaponId, WeaponTeam));

		weaponid = cheaper[weaponid];

		NextWeaponTeam[WeaponID] = WeaponTeam;
		NextWeaponFree[WeaponID] = Free;
	}
	else if ( (WeaponID >= 50) && (WeaponID <= 55 ) )
	{

		if ( (WeaponID == 55) && (!bTearGasPack) )
		{
			sender.clientmessage("This Server doesn't support that feature");
			return;
		}
		NextItemFree[WeaponID-50] = Free;
	}
	else if ( (WeaponID >= 40) && (WeaponID <= 48 ) )
	{
		NextSpecial[WeaponID-40] = Free;
		if ( WeaponID == 44 )//set crazy --> set full ammo
			NextSpecial[0] = 1;
		if ( WeaponID == 40 )//set full ammo off --> set crazy off
			NextSpecial[4] = 0;
		if ( WeaponID == 45 )
			NextRandomTime = WeaponTeam;
		if ( WeaponID == 41 && c4map ) //tostc4 disallowed
		{
			NextWeaponTeam[29]=0;
			NextWeaponFree[29]=0;
			NextWeaponTeam[30]=0;
			NextWeaponFree[30]=0;
		}
	}
	ChangedMode = true;
}


//----------------------------------------------------------------------------//
// TOSTWeaponsServer Communication functions								  //
//----------------------------------------------------------------------------//
function SendAll_AllWeaponsTeam()
{
	Params.param4 = WeaponsTeam;

	BroadcastClientMessage(550);
}

function Send_AllWeaponsTeam(PlayerPawn Player)
{
	Params.param4 = WeaponsTeam;
	Params.param6 = Player;

	SendClientMessage(550);
}

function Send_AWeaponTeam(PlayerPawn Player, int WeaponID)
{
	Params.param1 = WeaponID;
	if (weaponid <= 30)
		weaponid = cheaper[weaponid];
	Params.param6 = Player;

	if ( WeaponID == 0 )
	{
		if ( NextWeaponTeam[WeaponID] == 4 )
			Params.param2 = OICWTeam;
		else
			Params.param2 = NextWeaponTeam[WeaponID];
	}
	else if ( (WeaponID > 0) && (WeaponID <= 30 ) )
	{
		Params.param2 = NextWeaponTeam[WeaponID];
		Params.param3 = NextWeaponFree[WeaponID];
	}
	else if ( (WeaponID >= 50) && (WeaponID <= 55 ) )
	{
		Params.param3 = NextItemFree[WeaponID-50];
	}
	else if ( (WeaponID >= 40) && (WeaponID <= 48 ) )
	{
		Params.param3 = NextSpecial[WeaponID-40];
		if ( WeaponID == 45 )
			Params.param2 = NextRandomTime;
	}

    SendClientMessage(551);
}

function Send_ASetting(PlayerPawn Player, int Index)
{
	Params.param1 = Index;
	Params.param6 = Player;
	Params.param4 = Get_RecordName(Index);

	SendClientMessage(552);
}


//----------------------------------------------------------------------------//
// TOSTWeaponsServer Give / Remove Weapons functions						  //
//----------------------------------------------------------------------------//
function ProcessAll_FreeWeapons()
{
	local PlayerPawn PP;

	foreach AllActors(class'PlayerPawn', PP)
		ProcessA_FreeWeapons(PP);
}

function ProcessA_FreeWeapons(PlayerPawn PP)
{
    if ( (PP.PlayerReplicationInfo == none) || (PP.PlayerReplicationInfo.team > 1) )
        return;

	RemoveA_BannedWeapons(PP);
	GiveA_FreeWeapons(PP);
	GiveA_FreeArmor(PP);
}

function GiveA_FreeArmor(PlayerPawn Player)
{// and knife and binocs
	local inventory inv;

	if (ItemFree[0] == 1)
		s_player(Player).HelmetCharge = 100;
	if (ItemFree[1] == 1)
		s_player(Player).VestCharge = 100;
	if (ItemFree[2] == 1)
		s_player(Player).LegsCharge = 100;
	if (ItemFree[3] == 1)
		s_player(Player).bHasNV = true;
	if ( special[8] == 1 )
	{
		inv = Player.findinventorytype(Class<Actor>(DynamicLoadObject("S_Swat.s_Knife",Class'Class')));
		if ( inv != none )
			s_weapon(inv).clipammo = s_weapon(inv).clipSize;
	}
	if ( ItemFree[4] == 0 )
	{
		inv = Player.findinventorytype(Class<Actor>(DynamicLoadObject("S_Swat.to_Binocs",Class'Class')));
		if ( inv != none )
		{
			player.switchweapon(0);
			inv.destroy();
		}
	}
}

function GiveA_FreeWeapons(PlayerPawn Player)
{
    local int i;

	if ( Player.PlayerReplicationInfo.bisSpectator )
		return;

    for ( i=0; i<4; i++)
        if ((Player.PlayerReplicationInfo.Team == 0) && (TerrWFree[i] !=0) && (WeaponFree[TerrWFree[i]] != 0))
            GiveWeapon(Player,TerrWFree[i]);
		else if ((Player.PlayerReplicationInfo.Team == 1) && (SFWFree[i] !=0) && (WeaponFree[SFWFree[i]] != 0))
			GiveWeapon(Player,SFWFree[i]);
}

function RemoveA_BannedWeapons(PlayerPawn Player)
{
	local Inventory tmpinv;
	local int i;

	for(i=1;i<31;i++)
		if (NextWeaponTeam[i] == 0)
		{
			tmpinv=Player.findinventorytype(Class<Actor>(DynamicLoadObject(class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i],Class'Class')));
			if (tmpinv!=none)
			{
				tmpinv.destroy();
				NotifyPlayer(1, Player, "your " @class'TOModels.TO_WeaponsHandler'.default.WeaponName[i]@" is not allowed now !");
			}
		}
}

function RemoveAll_Weapons()
{
	local s_Weapon Weapon;

	foreach AllActors(class's_Weapon', Weapon)
		if ( (!Weapon.isa('s_knife')) && (!Weapon.isa('TO_Binocs')) )
			Weapon.destroy();
}


//----------------------------------------------------------------------------//
// TOSTWeaponsServer Random Weapons functions								  //
//----------------------------------------------------------------------------//
function ProcessAll_RandomWeapons()
{
    local PlayerPawn PP;
    local byte NewRandomWeapon,i,curs;
    local string tmp;

	if ( nbrandomweapon < 1 )
	{
		NewRandomWeapon = RandomWeapon;
		while ( NewRandomWeapon == RandomWeapon )
		{
			NewRandomWeapon = cheaper[rand(29) + 1];
			//test if allowed or not
			if ( (NewRandomWeapon == 25) && (!bFamasPack) )
				NewRandomWeapon = RandomWeapon;
			else if ( (NewRandomWeapon == 26) && (!bSteyrPack) )
				NewRandomWeapon = RandomWeapon;
			else if ( (NewRandomWeapon == 28) && (!bTearGasPack) )
				NewRandomWeapon = RandomWeapon;
			else if ( ((NewRandomWeapon == 29)||(NewRandomWeapon == 30)) && (!bC4Pack) )
				NewRandomWeapon = RandomWeapon;
		}
	}
	else
	{
		tmp = randomstream;
		NewRandomWeapon = rand(nbrandomweapon);
		for ( i=0; i<newRandomWeapon; i++)
		{
    		curs = instr(tmp,";");
			tmp = right(tmp,len(tmp)-(curs+1));
		}
		newrandomweapon = byte(left(tmp,instr(tmp,";")));
	}

	set_AllUnavailable();

	RemoveAll_Weapons();

    foreach allactors(class'PlayerPawn',PP)
    {
    	ProcessA_RandomWeapons(PP, NewRandomWeapon);
    }

    RandomWeapon = NewRandomWeapon;
}

function ProcessA_RandomWeapons(PlayerPawn PP, byte NewRandomWeapon)
{
    if ( (PP.PlayerReplicationInfo == none) || (PP.PlayerReplicationInfo.team > 1) )
        return;

	GiveA_FreeArmor(PP);

	if ( s_SWATGame(Level.game).GamePeriod != GP_RoundPlaying )
		return;

	GiveA_RandomWeapon(PP, NewRandomWeapon);
	GiveA_FreeArmor(PP);
}

function RemoveA_RandomWeapon(PlayerPawn PP)
{
	local Inventory tmpinv;
	local Class<Actor> InputClass;
    local actor weapon;

    if ( RandomWeapon == 0 )
    	return;

	InputClass=Class<Actor>(DynamicLoadObject(class'TOModels.TO_WeaponsHandler'.default.WeaponStr[RandomWeapon],Class'Class'));
	foreach AllActors(inputclass, Weapon)
		Weapon.destroy();
	return;

	foreach AllActors(Class'PlayerPawn',PP)
		if ( (PP.PlayerReplicationInfo != None) && (PP.PlayerReplicationInfo.Team <= 1) )
		{
			tmpinv=PP.findinventorytype(InputClass);
			if (tmpinv!=none)
			{
			    s_player(PP).bSZoom = false;
				if ( ( RandomWeapon == 1) && (s_deagle(tmpinv).laserDot != None))
                    s_deagle(tmpinv).killlaserdot();
				if ( ( RandomWeapon == 9) && (TO_M16(tmpinv).laserDot != None) )
                    TO_M16(tmpinv).killlaserdot();
				PP.deleteinventory(tmpinv);
			}
		}
}

function GiveA_RandomWeapon(PlayerPawn PP, int NewRandomWeapon)
{
    if ( NewRandomWeapon == 0 )
    	return;

	if ( PP.PlayerReplicationInfo.bIsSpectator )
		return;

	s_SWATGame(Level.Game).GiveWeapon(PP,class'TOModels.TO_WeaponsHandler'.default.WeaponStr[NewRandomWeapon]);
	PP.ReceiveLocalizedMessage(Class'PickupMessagePlus',0,None,None,DynamicLoadObject(class'TOModels.TO_WeaponsHandler'.default.WeaponStr[NewRandomWeapon],Class'Class'));
}

function bool isRandom()
{
	return ( Special[5] != 0 );
}

//----------------------------------------------------------------------------//
// TOSTWeaponsServer RecordString functions									  //
//----------------------------------------------------------------------------//
function string Get_RecordName(int i)
{
	local int curs;

    curs = instr(RecordString[i],";");

    if ( curs == -1 )
    	return "";
    else return Left(RecordString[i],curs);
}

function Save_ASetting(playerpawn sender, int Index, string SettingName)
{
	local int i;

	if ( SettingName ~= "")
	{
		RecordString[Index] = "";
		DefaultMapMode[Index] = "";
	    saveconfig();
		return;
	}

    NotifyPlayer(1,sender,SettingName@"settings Saved");

	RecordString[Index] = SettingName$";";

	for (i=0; i<31; i++)
	{
		RecordString[Index] = RecordString[Index]$NextWeaponTeam[i]$";";
	}

	for (i=0; i<31; i++)
	{
		RecordString[Index] = RecordString[Index]$NextWeaponFree[i]$";";
	}

	for (i=0; i<6; i++)
	{
		RecordString[Index] = RecordString[Index]$NextItemFree[i]$";";
	}

	for (i=0; i<9; i++)
	{
		if ( i != 5 )
			RecordString[Index] = RecordString[Index]$NextSpecial[i]$";";
	}
	if ( NextSpecial[5] == 1 )
		RecordString[Index] = RecordString[Index]$NextRandomTime$";";
	else RecordString[Index] = RecordString[Index]$"-1;";

    saveconfig();
}

function Load_ASetting(int Index)
{
    local string tmp;

    tmp = RecordString[Index];

    if ( tmp == "" )
    	return;

	log("---------------------------TOSTWeapons---------------------------");
	log("The following weapon-mode was loaded");
	log("> preset mode \""$Left(RecordString[Index],instr(RecordString[Index],";"))$"\"");

	Load_this(tmp);
}

function Load_this(string tmp)
{
    local int i, curs;

	ChangedMode = true;
	i = -1;
	while ( tmp != "" )
	{
    	curs = instr(tmp,";");
    	if (i == -1)
    		NotifyAll(1,Left(tmp,curs)@"settings Loaded");
		else if ((i >= 0) && (i < 31))
			NextWeaponTeam[i] = int(Left(tmp,curs));
		else if ((i >= 31) && (i < 62))
			NextWeaponFree[i-31] = int(Left(tmp,curs));
		else if ((i >= 62) && (i < 68))
			NextItemFree[i-62] = int(Left(tmp,curs));
		else if ((i >= 68) && (i < 76)) {
			if ( i-68 >= 5 )
				NextSpecial[i-67] = int(Left(tmp,curs));
			else NextSpecial[i-68] = int(Left(tmp,curs));
		}
		else if ( i == 76 )
		{
			NextRandomTime = int(Left(tmp,curs));
			if ( NextRandomTime != -1 )
				NextSpecial[5] = 1;
			else NextSpecial[5] = 0;
		}
		i++;
		tmp = right(tmp,len(tmp)-(curs+1));
	}
	//check the serverpackages 4 being sure
	if ( !bFamasPack && NextWeaponTeam[25] == 1 )
	{
		NextWeaponTeam[25] = 0;
		log("SETTINGS ERROR! Famas is disabled!");
	}
	if ( !bSteyrPack && NextWeaponTeam[26] == 1 )
	{
		NextWeaponTeam[26] = 0;
		log("SETTINGS ERROR! SteyrAug is disabled!");
	}
	if ( !bTearGasPack && NextWeaponTeam[28] == 1 )
	{
		NextWeaponTeam[28] = 0;
		NextItemFree[5] = 0;
		log("SETTINGS ERROR! TearGas is disabled!");
	}
	if ( !bC4Pack && (NextWeaponTeam[29]==1||NextWeaponTeam[30]==1) )
	{
		NextWeaponTeam[29] = 0;
		NextWeaponTeam[30] = 0;
		log("SETTINGS ERROR! TOSTC4s are disabled!");
	}
	if ( NextItemFree[5]==1 && NextWeaponTeam[28]==0 )
		NextItemFree[5]=0;//disable teargasmask if !teargas
	if ( C4map && NextSpecial[1] == 1 && (NextWeaponTeam[29]==1||NextWeaponTeam[30]==1) )
	{//disable tostc4 if c4 in map set and true
		NextWeaponTeam[29] = 0;
		NextWeaponTeam[30] = 0;
		log("This map has it's own C4! --> TOSTC4s are disabled!");
	}
	else if ( C4map && NextSpecial[1] == 0 )
		log("This map has it's own C4 but is disabled!");
	else if ( C4map  )
		log("This map has it's own C4 and is enabled!");
	if ( OICWTeam != 0 )
	{//say what team owns oicw if default set
	    if ( OICWTeam == 1 )
			log("This map has it's own OICW! --> Owning team = BOTH");
	    else if ( OICWTeam == 2 )
			log("This map has it's own OICW! --> Owning team = SF");
	    else if ( OICWTeam == 3 )
			log("This map has it's own OICW! --> Owning team = Terrorists");
		if ( NextWeaponTeam[0] == 0 )
			log("--> OICW is set for NONE!");
		else if ( NextWeaponTeam[0] == 1 )
			log("--> OICW is set for BOTH teams!");
		else if ( NextWeaponTeam[0] == 2 )
			log("--> OICW is set for SF team!");
		else if ( NextWeaponTeam[0] == 3 )
			log("--> OICW is set for Terrorists team!");
		else log("--> Using map setting!");
	}
	log("-----------------------------------------------------------------");
	log("");
}

function Load_MapDefault()
{
	local int i,curs;
	local string tmp,def;

	curs = -1;
	def = "Default AOT 3.40;4;1;3;3;3;2;3;3;2;1;2;1;1;1;1;2;3;2;2;1;2;2;2;3;3;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;0;0;0;1;0;0;0;0;0;0;0;0;0;0;1;0;0;1;0;1;0;0;0;0;-1;";

	for ( i=0 ; i<10; i++ )
	{
		if ( instr(caps(DefaultMapMode[i]),caps(Left(Level,instr(Level,".")))) != -1 )
		{
			curs = i;
			break;
		}
	}
	if ( curs == -1 )
		curs = CurrentDefSettings;

	log("---------------------------TOSTWeapons---------------------------");
	log("The following weapon-mode apllied to map:"@Left(Level,instr(Level,".")));
	if ( curs == -1 )
	{
		tmp = def;
		log("> default mode");
	}
	else
	{
		tmp = RecordString[curs];
	    if ( tmp == "" )
	    {
	    	tmp = def;
			log("> default mode (preset mode"@curs@"is not valide)");
		}
	    else log("> preset mode \""$Left(RecordString[curs],instr(RecordString[curs],";"))$"\"");
	}

	Load_This(tmp);
	Create_NewWeaponsSettings();
}

function Set_MapMode(playerpawn sender, int index, string map)
{
	local int i, curs;
	local TOSTMapHandling tmh;

	foreach allactors(class'TOSTMapHandling',tmh)
	{
		if (tmh.findmapindex(map)==-1)
		{
			NotifyPlayer(1, sender, "map"@map@"is unknown.");
			return;
		}
		else map = tmh.NormalizeMapName(map);
	}

	map = map$";";

	//delete map from other then add
	for ( i=0; i<10 ;i++ )
	{
		curs = instr(caps(DefaultMapMode[i]),caps(map));
		if ( curs != -1 )
		{
			DefaultMapMode[i] = Left(DefaultMapMode[i],instr(caps(DefaultMapMode[i]),caps(map)))$right(DefaultMapMode[i],instr(caps(DefaultMapMode[i]),caps(map))-len(map));
		}
	}

	if ( (index < 10) && (index >= 0) && (RecordString[index] != "") )
	{
		DefaultMapMode[index] = DefaultMapMode[index]$map;
  		NotifyPlayer(1, sender, "settings \""$Left(RecordString[index],instr(RecordString[index],";"))$"\"set as default for map"@left(map,len(map)-1));
	}
	else NotifyPlayer(1, sender, "default settings set as default for map"@left(map,len(map)-1));

	saveconfig();
}

function Set_DefaultMapMode(playerpawn sender, int index)
{
	if ( (index < 10) && (index >= 0) && (RecordString[index] != "") )
	{
		CurrentDefSettings = index;
  		NotifyPlayer(1, sender, "settings \""$Left(RecordString[index],instr(RecordString[index],";"))$"\"set as default");
	}
	else if ( index == -1 )
	{
		CurrentDefSettings = index;
  		NotifyPlayer(1, sender, "TOSTWeapons default settings set as default");
	}

	saveconfig();
}

function GetSettings(TOSTPiece Sender)
{
	Params.Param4 = String(CurrentDefSettings)$";";
	SendAnswerMessage(Sender, 143);
}

function SetSettings(TOSTPiece Sender, string Settings)
{
	local int i, j;
	local string s;

	s = Settings;
	if (s != "")
	{
		j = InStr(s, ";");
		if (j != -1)
		{
			i = int(Left(s, j));
			s = Mid(s, j+1);
		} else {
			i = int(s);
			s = "";
		}
		CurrentDefSettings = i;
	}
	SaveConfig();
}

//----------------------------------------------------------------------------//
// TOSTWeaponsServer Misc functions											  //
//----------------------------------------------------------------------------//
function int GetIdByClass (string weaponclass)
{
	local int i;

	for (i=1; i < 31; i++)
		if (class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i] == weaponclass)
			return i;
	return -1;
}

function set_AllUnavailable()
{
	local int i;
	for (i=1; i<31; i++)
	{
		class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[i] = WT_None;
	}
}
/*
function byte Check_MaxRifles(byte OldWeaponTeam, byte WeaponTeam)
{
	if ( weaponteam == oldweaponteam )
		return weaponteam;
	if ( (WeaponTeam == 2) && (MaxRifles[0] >= 8) && (OldWeaponTeam != 1))
		return 0;
	else if ( (WeaponTeam == 3) && (MaxRifles[1] >= 8) && (OldWeaponTeam != 1))
		return 0;
	else if (WeaponTeam == 1)
	{
		if (OldWeaponTeam == 2)
		{
			if (MaxRifles[1] >= 8)
				return 2;
		}
		else
		{
			if (MaxRifles[0] >= 8)
				return 3;
		}
	}
	return WeaponTeam;
}

function Calc_MaxRifles()
{
	local int i;

	MaxRifles[0]=0;
	MaxRifles[1]=0;

	for ( i=12; i<24; i++ )
	{
		if ( NextWeaponTeam[cheaper[i]] == 1 )
		{
			MaxRifles[0]++;
			MaxRifles[1]++;
		}
		else if ( NextWeaponTeam[cheaper[i]] == 2 )
		{
			MaxRifles[0]++;
		}
		else if ( NextWeaponTeam[cheaper[i]] == 3 )
		{
			MaxRifles[1]++;
		}
	}
}*/

function Build_FreeWeapons()
{
	local int i, j ;

	for ( i=0; i<4; i++)
	{
		SFWFree[i] = 0;
		TerrWFree[i] = 0;
	}

	j = 0;

	for ( i=1; i<31; i++ )
	{
		if ( (i == 5) || (i == 12) || (i == 24) )
			j++;

		if ( NextWeaponFree[cheaper[i]] == 1 )
		{
			if ( NextWeaponTeam[cheaper[i]] == 1 )
			{
				SFWFree[j] = cheaper[i];
				TerrWFree[j] = cheaper[i];
			}
			if ( NextWeaponTeam[cheaper[i]] == 2 )
				SFWFree[j] = cheaper[i];
			if ( NextWeaponTeam[cheaper[i]] == 3 )
				TerrWFree[j] = cheaper[i];
		}
	}
}

function bool Check_FreeWeapons(byte WeaponID, byte Team)
{
	local int i;
	local bool Free;

	Build_FreeWeapons();

	Free = false;

	if ( Team == 0 )
		return Free;

	if ( (WeaponID >= 1) && (WeaponID < 5) )
	{
		if ( (Team == 2) && (SFWFree[0] == 0) )
		{
			SFWFree[0] = WeaponID;
			Free = true;
		}
		else if ( (Team == 3) && (TerrWFree[0] == 0) )
		{
			TerrWFree[0] = WeaponID;
			Free = true;
		}
		else if ( (Team == 1) && (TerrWFree[0] == 0) && (SFWFree[0] == 0) )
		{
			SFWFree[0] = WeaponID;
			TerrWFree[0] = WeaponID;
			Free = true;
		}
	}
	else if ( (WeaponID >= 5) && (WeaponID < 12) )
	{
		if ( (Team == 2) && (SFWFree[1] == 0) )
		{
			SFWFree[1] = WeaponID;
			Free = true;
		}
		else if ( (Team == 3) && (TerrWFree[1] == 0) )
		{
			TerrWFree[1] = WeaponID;
			Free = true;
		}
		else if ( (Team == 1) && (TerrWFree[1] == 0) && (SFWFree[1] == 0) )
		{
			SFWFree[1] = WeaponID;
			TerrWFree[1] = WeaponID;
			Free = true;
		}
	}
	else if ( (WeaponID >= 12) && (WeaponID < 24) )
	{
		if ( (Team == 2) && (SFWFree[2] == 0) )
		{
			SFWFree[2] = WeaponID;
			Free = true;
		}
		else if ( (Team == 3) && (TerrWFree[2] == 0) )
		{
			TerrWFree[2] = WeaponID;
			Free = true;
		}
		else if ( (Team == 1) && (TerrWFree[2] == 0) && (SFWFree[2] == 0) )
		{
			SFWFree[2] = WeaponID;
			TerrWFree[2] = WeaponID;
			Free = true;
		}
	}
	else if ( (WeaponID >= 24) && (WeaponID < 31) )
	{
		if ( (Team == 2) && ((SFWFree[3] == 0) || (SFWFree[3] == WeaponID)) )
		{
			SFWFree[3] = WeaponID;
			Free = true;
		}
		else if ( (Team == 3) && (TerrWFree[3] == 0) )
		{
			TerrWFree[3] = WeaponID;
			Free = true;
		}
		else if ( (Team == 1) && (TerrWFree[3] == 0) && (SFWFree[3] == 0) )
		{
			SFWFree[3] = WeaponID;
			TerrWFree[3] = WeaponID;
			Free = true;
		}
	}

	return Free;
}

function timer()
{
	local s_C4 C4;

	if ( Desactivated )
	{
		Params.param5 = CWMode;
		BroadcastClientMessage(553);
		return;
	}

	CheckRandomTime += TimerRate;

	if ( CheckRandomTime >= RandomTime )
	{
		CheckRandomTime = 0;
		if ( (isRandom()) && (RandomTime != 0) )
			ProcessAll_RandomWeapons();
	}

	if ( BRound )
	{
		BRound = false;
	    if (Special[1] == 0)
    	{
    		foreach AllActors(class's_C4',C4)
    		{
    			C4.destroy();
    		}
		}
	}
}

function tick(float delta)
{//used to call gameperiodchanged(0) when gp stay = 0
	if ((s_SWATGame(Level.Game).GameReplicationInfo.RemainingTime==s_SWATGame(Level.Game).TimeLimit*60) && (s_SWATGame(Level.Game).GamePeriod==GP_PreRound))
		BeginRound();
	if (s_SWATGame(Level.Game).RoundNumber != roundNB)
	{
		roundNB = s_SWATGame(Level.Game).RoundNumber;
		BeginRound();
	}
}

function Set_LightWeapons()
{
	local int i;
	local TOSTWeapon Weapon;

	if ( NextSpecial[2] == 1 )
	{
		for ( i=1; i<31; i++ )
			Class<TOSTWeapon>(DynamicLoadObject(class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i],Class'Class')).default.WeaponWeight = 0.0;

		foreach AllActors(class'TOSTWeapon', Weapon)
			Weapon.WeaponWeight = 0.0;
	}
	else
	{
		for ( i=1; i<31; i++ )
			Class<TOSTWeapon>(DynamicLoadObject(class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i],Class'Class')).default.WeaponWeight = WeaponWeight[i];

		foreach AllActors(class'TOSTWeapon', Weapon)
		{
			i = GetidByClass(string(Weapon.class));
			if ( i != -1 )
				Weapon.WeaponWeight = WeaponWeight[i];
		}
	}
}

function Set_CrazyWeapons()
{
	local int h,i;
	local TOSTWeapon Weapon;

	if ( NextSpecial[4] == 1 )
	{
		for ( h=1; h<24; h++ )
		{
			i=cheaper[h];
			Class<TOSTWeapon>(DynamicLoadObject(class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i],Class'Class')).default.ClipSize = 255;
			Class<TOSTWeapon>(DynamicLoadObject(class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i],Class'Class')).default.ClipAmmo = 255;
			Class<TOSTWeapon>(DynamicLoadObject(class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i],Class'Class')).default.MaxClip = 255;
	    	if ( BackupMaxClip[i] != 0 )
	    	{
				Class<TOSTWeapon>(DynamicLoadObject(class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i],Class'Class')).default.BackupClipSize = 255;
				Class<TOSTWeapon>(DynamicLoadObject(class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i],Class'Class')).default.BackupAmmo = 255;
				Class<TOSTWeapon>(DynamicLoadObject(class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i],Class'Class')).default.BackupMaxClip = 255;
			}
		}

		foreach AllActors(class'TOSTWeapon', Weapon)
		{
			i = GetidByClass(string(Weapon.class));
			if ( i != 0 )
			{
				if ( !Weapon.isa('TOSTGrenade') )
				{
					Weapon.ClipSize = 255;
					Weapon.ClipAmmo = 255;
					Weapon.MaxClip = 255;
					if ( BackupMaxClip[i] != 0 )
					{
						Weapon.BackupClipSize = 255;
						Weapon.BackupAmmo = 255;
						Weapon.BackupMaxClip = 255;
					}
				}
			}
		}
	}
	else
	{
		for ( h=1; h<24; h++ )
		{
			i= cheaper[h];
			Class<TOSTWeapon>(DynamicLoadObject(class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i],Class'Class')).default.ClipSize = ClipSize[i];
			Class<TOSTWeapon>(DynamicLoadObject(class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i],Class'Class')).default.ClipAmmo = ClipSize[i];
			Class<TOSTWeapon>(DynamicLoadObject(class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i],Class'Class')).default.MaxClip = MaxClip[i];
	    	if ( BackupMaxClip[i] != 0 )
	    	{
				Class<TOSTWeapon>(DynamicLoadObject(class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i],Class'Class')).default.BackupClipSize = BackupClipSize[i];
				Class<TOSTWeapon>(DynamicLoadObject(class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i],Class'Class')).default.BackupAmmo = BackupClipSize[i];
				Class<TOSTWeapon>(DynamicLoadObject(class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i],Class'Class')).default.BackupMaxClip = BackupMaxClip[i];
			}
		}

		foreach AllActors(class'TOSTWeapon', Weapon)
		{
			i = GetidByClass(string(Weapon.class));
			if ( i != 0 )
			{
				if ( !Weapon.isa('TOSTGrenade') )
				{
					Weapon.ClipSize = ClipSize[i];
					Weapon.ClipAmmo = ClipSize[i];
					Weapon.MaxClip = MaxClip[i];
					if ( Weapon.RemainingClip > Weapon.MaxClip )
						Weapon.RemainingClip = Weapon.MaxClip;
					if ( BackupMaxClip[i] != 0 )
					{
						Weapon.BackupClipSize = BackupClipSize[i];
						Weapon.BackupAmmo = BackupClipSize[i];
						Weapon.BackupMaxClip = BackupMaxClip[i];
						if ( Weapon.BackupClip > Weapon.BackupMaxClip )
							Weapon.BackupClip = Weapon.BackupMaxClip;
					}
				}
			}
		}
	}
}

function GiveWeapon(PlayerPawn Player, byte WeaponID)
{
	local Inventory Weapon;
	local byte Min, Max, i;

	WeaponID = Sort[WeaponID];

	if ( (WeaponID >=1) && (WeaponID < 5) )
	{
		Min = 1;
		Max = 5;
	}
	else if ( (WeaponID >=5) && (WeaponID < 12) )
	{
		Min = 5;
		Max = 12;
	}
	else if ( (WeaponID >=12) && (WeaponID < 24) )
	{
		Min = 12;
		Max = 24;
	}
	else if ( (WeaponID >=24) && (WeaponID < 31) )
	{
		Min = 24;
		Max = 30;
	}

	for ( i=min; i<max; i++)
	{
		Weapon = Player.findinventorytype(Class<Actor>(DynamicLoadObject(class'TOModels.TO_WeaponsHandler'.default.WeaponStr[Cheaper[i]],Class'Class')));

		if ( Weapon != none )
		{
			//test + if has glock and free berreta dont change !
			if ( WeaponID > i && WeaponID != 2 )
			{//delete that gun
				s_player(player).bSZoom = false;
				if ( (i == 1) && (TOST_DEagle(Weapon).laserDot != None))
                    TOST_deagle(Weapon).killlaserdot();
				if ( (i == 9) && (TOST_M16(Weapon).laserDot != None) )
                    TOST_M16(Weapon).killlaserdot();
				player.deleteinventory(Weapon);
			}
			else if ( WeaponID == i || (WeaponID == 2 && i == 1) )
			{//add ammo maybe
				if (weaponid >=24)// no need 4 nades
					return;
				if ( Special[0] == 1 )
				{
	    	    	s_weapon(Weapon).ClipAmmo = s_weapon(Weapon).ClipSize;
	    	    	s_weapon(Weapon).RemainingClip = s_weapon(Weapon).maxClip;
	   	    		s_weapon(Weapon).BackupAmmo = s_weapon(Weapon).BackupClipSize;
	   	    		s_weapon(Weapon).BackupClip = s_weapon(Weapon).BackupMaxClip;
				}
				else
				{
	    	    	s_weapon(Weapon).ClipAmmo = s_weapon(Weapon).ClipSize;
					s_weapon(Weapon).BackupAmmo = s_weapon(Weapon).BackupClipSize;
				}
				return;
			}
			else
			{//better his gun than free one
				return;
			}
		}
	}
	s_SWATGame(Level.Game).GiveWeapon(Player,class'TOModels.TO_WeaponsHandler'.default.WeaponStr[Cheaper[WeaponID]]);
}

function Desactivate()
{
	desactivated = true;

	setTimer(0.0,false);

	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[1]="s_SWAT.s_DEagle";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[2]="s_SWAT.s_MAC10";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[3]="s_SWAT.s_MP5N";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[4]="s_SWAT.s_Mossberg";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[5]="s_SWAT.s_M3";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[6]="s_SWAT.s_Ak47";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[7]="s_SWAT.TO_SteyrAug";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[8]="s_SWAT.TO_M4A1";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[9]="s_SWAT.TO_M16";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[10]="s_SWAT.TO_HK33";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[11]="s_SWAT.s_PSG1";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[12]="s_SWAT.TO_Grenade";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[13]="s_SWAT.s_GrenadeFB";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[14]="s_SWAT.s_GrenadeConc";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[15]="s_SWAT.s_p85";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[16]="s_SWAT.TO_Saiga";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[17]="s_SWAT.TO_MP5KPDW";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[18]="s_SWAT.TO_Berreta";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[19]="s_SWAT.TO_GrenadeSmoke";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[20]="s_SWAT.TO_M4m203";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[21]="s_SWAT.TO_HKSMG2";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[22]="s_SWAT.TO_RagingBull";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[23]="s_SWAT.TO_m60";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[24]="s_SWAT.s_Glock";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[25]="";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[26]="";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[27]="";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[28]="";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[29]="";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[30]="";

	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[1]=WT_Both;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[2]=WT_Terrorist;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[3]=WT_Terrorist;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[4]=WT_Terrorist;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[5]=WT_SpecialForces;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[6]=WT_Terrorist;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[7]=WT_Terrorist;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[8]=WT_SpecialForces;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[9]=WT_Both;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[10]=WT_SpecialForces;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[11]=WT_Both;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[12]=WT_Both;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[13]=WT_Both;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[14]=WT_Both;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[15]=WT_SpecialForces;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[16]=WT_Terrorist;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[17]=WT_SpecialForces;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[18]=WT_SpecialForces;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[19]=WT_Both;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[20]=WT_SpecialForces;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[21]=WT_SpecialForces;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[22]=WT_SpecialForces;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[23]=WT_Terrorist;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[24]=WT_Terrorist;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[25]=WT_None;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[26]=WT_None;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[27]=WT_None;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[28]=WT_None;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[29]=WT_None;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[30]=WT_None;

	s_SwatGame(Level.Game).DefTeamWeapon[0]=class's_SWAT.s_Glock';
	s_SwatGame(Level.Game).DefTeamWeapon[1]=class's_SWAT.TO_Berreta';

	RemoveAll_Weapons();
}

function CheckVersion()
{
	local int i;

	if ( versionsettings == version )
		return;

	CurrentDefSettings = -1;
	for ( i = 0; i < 10; i++ )
	{
		RecordString[i]="";
		DefaultMapMode[i]="";
	}

	RecordString[0]="TO Default;4;1;3;3;3;2;3;3;2;1;2;1;1;1;1;2;3;2;2;1;2;2;2;3;3;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;0;0;0;1;0;0;0;0;0;0;0;0;0;0;1;0;0;1;0;1;0;0;0;0;-1;";
	RecordString[1]="Default + Steyr + FAMAS + GasNade;4;1;3;3;3;2;3;3;2;1;2;1;1;1;1;2;3;2;2;1;2;2;2;3;3;1;1;0;1;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;0;0;0;1;0;0;0;0;0;0;0;0;0;0;1;0;0;1;0;1;0;0;0;0;-1;";
	RecordString[2]="DE ONLY;4;1;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;1;1;1;1;0;1;0;0;0;0;0;0;0;-1;";
	RecordString[3]="DE + NADES;4;1;0;0;0;0;0;0;0;0;0;0;1;1;1;0;0;0;0;1;0;0;0;0;0;0;0;0;1;0;0;0;1;0;0;0;0;0;0;0;0;0;0;1;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;1;1;1;1;0;1;0;0;0;0;0;0;0;-1;";
	RecordString[4]="TOSTWeapons;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;1;0;1;0;1;1;0;-1;";
	RecordString[5]="CRAZY MODE;4;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;1;1;1;1;0;1;0;1;1;1;1;1;1;20;";

	versionsettings = version;
	saveConfig();
}

function ServerBuyGasmask(PlayerPawn Sender, bool bHasGasmask, bool eGasmask)
{
	if ( bHasGasmask && !eGasmask )
	{
		S_Player_T(Sender).AddMoney(800);
	}
	else if ( !bHasGasmask && eGasmask )
	{
		S_Player_T(Sender).AddMoney(-800);
	}
}

function Set_C4Shootable()
{
	local TOST_ExplosiveC4 tmp;

	foreach allactors(class'TOST_ExplosiveC4',tmp)
	{
		tmp.CanBeShooted = ( Special[6] == 1 );
	}
}

function Set_NadeTimer()
{
	local TOSTGrenade tmp;

	foreach allactors(class'TOSTGrenade',tmp)
	{
		if ( (tmp.isa('TOST_Grenade')) || (tmp.isa('TOST_GrenadeConc')) || (tmp.isa('TOST_GrenadeFB')) )
		{
			tmp.NadeModeEnabled = ( Special[7] == 1 );
		}
	}
}

//----------------------------------------------------------------------------//
// TOSTWeaponsServer defaultproperties										  //
//----------------------------------------------------------------------------//
defaultproperties
{
	bHidden=true
	PieceName="TOST Weapons Configurator"
	PieceVersion="1.4.0.0"
	CurrentDefSettings=-1
	PieceOrder=160

	ServerOnly=true
	BaseMessage=550
	showKiller=true
	RecordString(0)=TO Default;4;1;3;3;3;2;3;3;2;1;2;1;1;1;1;2;3;2;2;1;2;2;2;3;3;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;0;0;0;1;0;0;0;0;0;0;0;0;0;0;1;0;0;1;0;1;0;0;0;0;-1;
	RecordString(1)=Default + Steyr + FAMAS + GasNade;4;1;3;3;3;2;3;3;2;1;2;1;1;1;1;2;3;2;2;1;2;2;2;3;3;1;1;0;1;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;0;0;0;1;0;0;0;0;0;0;0;0;0;0;1;0;0;1;0;1;0;0;0;0;-1;
	RecordString(2)=DE ONLY;4;1;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;1;1;1;1;0;1;0;0;0;0;0;0;0;-1;
	RecordString(3)=DE + NADES;4;1;0;0;0;0;0;0;0;0;0;0;1;1;1;0;0;0;0;1;0;0;0;0;0;0;0;0;1;0;0;0;1;0;0;0;0;0;0;0;0;0;0;1;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;1;1;1;1;0;1;0;0;0;0;0;0;0;-1;
	RecordString(4)=TOSTWeapons;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;1;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;0;1;0;1;0;1;1;0;-1;
	RecordString(5)=CRAZY MODE;4;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;1;1;1;1;0;1;0;1;1;1;1;1;1;20;

	WeaponStr(1)="TOSTWeapons42.TOST_DEagle"
	WeaponStr(2)="TOSTWeapons42.TOST_MAC10"
	WeaponStr(3)="TOSTWeapons42.TOST_MP5N"
	WeaponStr(4)="TOSTWeapons42.TOST_Mossberg"
	WeaponStr(5)="TOSTWeapons42.TOST_M3"
	WeaponStr(6)="TOSTWeapons42.TOST_Ak47"
	WeaponStr(7)="TOSTWeapons42.TOST_SteyrAug"
	WeaponStr(8)="TOSTWeapons42.TOST_M4A1"
	WeaponStr(9)="TOSTWeapons42.TOST_M16"
	WeaponStr(10)="TOSTWeapons42.TOST_HK33"
	WeaponStr(11)="TOSTWeapons42.TOST_PSG1"
	WeaponStr(12)="TOSTWeapons42.TOST_Grenade"
	WeaponStr(13)="TOSTWeapons42.TOST_GrenadeFB"
	WeaponStr(14)="TOSTWeapons42.TOST_GrenadeConc"
	WeaponStr(15)="TOSTWeapons42.TOST_P85"
	WeaponStr(16)="TOSTWeapons42.TOST_Saiga"
	WeaponStr(17)="TOSTWeapons42.TOST_MP5KPDW"
	WeaponStr(18)="TOSTWeapons42.TOST_Beretta"
	WeaponStr(19)="TOSTWeapons42.TOST_GrenadeSmoke"
	WeaponStr(20)="TOSTWeapons42.TOST_M4m203"
	WeaponStr(21)="TOSTWeapons42.TOST_HKSMG2"
	WeaponStr(22)="TOSTWeapons42.TOST_RagingBull"
	WeaponStr(23)="TOSTWeapons42.TOST_M60"
	WeaponStr(24)="TOSTWeapons42.TOST_Glock"
	WeaponStr(25)="FamasPack42.TOSTFAMAS"
	WeaponStr(26)="SteyrAugPack42.TOSTSteyrAug"
	WeaponStr(27)="TOSTWeapons42.TOST_OICW"
	WeaponStr(28)="TearGasPack42.TOST_GrenadeGas"
	WeaponStr(29)="C4Pack42.TOST_C4Lazer"
	WeaponStr(30)="C4Pack42.TOST_C4Timer"

	WeaponName(1)="Desert Eagle"
	WeaponName(2)="Ingram MAC 10"
	WeaponName(3)="MP5A2"
	WeaponName(4)="Mossberg Shotgun"
	WeaponName(5)="SPAS 12"
	WeaponName(6)="AK-47"
	WeaponName(7)="Sig 551"
	WeaponName(8)="M4A1"
	WeaponName(9)="M16A2"
	WeaponName(10)="HK 33"
	WeaponName(11)="MSG 90"
	WeaponName(12)="HE Grenade"
	WeaponName(13)="FlashBang"
	WeaponName(14)="Conc. Grenade"
	WeaponName(15)="Parker-Hale 85"
	WeaponName(16)="Saiga 12"
	WeaponName(17)="MP5 SD"
	WeaponName(18)="Beretta 92F"
	WeaponName(19)="Smoke Grenade"
	WeaponName(20)="M4A2m203"
	WeaponName(21)="SMG II"
	WeaponName(22)="Raging Bull"
	WeaponName(23)="M60"
	WeaponName(24)="GL 23"
	WeaponName(25)="FAMAS"
	WeaponName(26)="SteyrAug"
	WeaponName(27)="OICW"
	WeaponName(28)="Teargas Grenade"
	WeaponName(29)="Laser C4"
	WeaponName(30)="Timer C4"

	WeaponWeight(1)=6.000000
	WeaponWeight(2)=6.000000
	WeaponWeight(3)=15.000000
	WeaponWeight(4)=20.000000
	WeaponWeight(5)=20.000000
	WeaponWeight(6)=20.000000
	WeaponWeight(7)=28.000000
	WeaponWeight(8)=25.000000
	WeaponWeight(9)=22.000000
	WeaponWeight(10)=25.000000
	WeaponWeight(11)=30.000000
	WeaponWeight(12)=4.000000
	WeaponWeight(13)=4.000000
	WeaponWeight(14)=4.000000
	WeaponWeight(15)=35.000000
	WeaponWeight(16)=20.000000
	WeaponWeight(17)=15.000000
	WeaponWeight(18)=4.000000
	WeaponWeight(19)=4.000000
	WeaponWeight(20)=30.000000
	WeaponWeight(21)=5.000000
	WeaponWeight(22)=10.000000
	WeaponWeight(23)=60.000000
	WeaponWeight(24)=2.000000
	WeaponWeight(25)=25.000000
	WeaponWeight(26)=25.000000
	WeaponWeight(27)=40.000000
	WeaponWeight(28)=4.000000
	WeaponWeight(29)=2.000000
	WeaponWeight(30)=2.000000

	MaxClip(1)=7
	MaxClip(2)=6
	MaxClip(3)=5
	MaxClip(4)=40
	MaxClip(5)=40
	MaxClip(6)=5
	MaxClip(7)=4
	MaxClip(8)=5
	MaxClip(9)=4
	MaxClip(10)=4
	MaxClip(11)=4
	MaxClip(12)=0
	MaxClip(13)=0
	MaxClip(14)=0
	MaxClip(15)=4
	MaxClip(16)=4
	MaxClip(17)=5
	MaxClip(18)=4
	MaxClip(19)=0
	MaxClip(20)=5
	MaxClip(21)=6
	MaxClip(22)=7
	MaxClip(23)=2
	MaxClip(24)=5
	MaxClip(25)=6
	MaxClip(26)=5
	MaxClip(27)=6
	MaxClip(28)=0
	MaxClip(29)=0
	MaxClip(30)=0

	clipSize(1)=7
	clipSize(2)=32
	clipSize(3)=30
	clipSize(4)=8
	clipSize(5)=8
	clipSize(6)=30
	clipSize(7)=30
	clipSize(8)=30
	clipSize(9)=20
	clipSize(10)=30
	clipSize(11)=5
	clipSize(12)=0
	clipSize(13)=0
	clipSize(14)=0
	clipSize(15)=10
	clipSize(16)=7
	clipSize(17)=30
	clipSize(18)=15
	clipSize(19)=0
	clipSize(20)=30
	clipSize(21)=30
	clipSize(22)=6
	clipSize(23)=100
	clipSize(24)=13
	clipSize(25)=25
	clipSize(26)=30
	clipSize(27)=25
	clipSize(28)=0
	clipSize(29)=0
	clipSize(30)=0

	BackupMaxClip(1)=0
	BackupMaxClip(2)=0
	BackupMaxClip(3)=0
	BackupMaxClip(4)=0
	BackupMaxClip(5)=0
	BackupMaxClip(6)=0
	BackupMaxClip(7)=0
	BackupMaxClip(8)=0
	BackupMaxClip(9)=0
	BackupMaxClip(10)=0
	BackupMaxClip(11)=0
	BackupMaxClip(12)=0
	BackupMaxClip(13)=0
	BackupMaxClip(14)=0
	BackupMaxClip(15)=0
	BackupMaxClip(16)=0
	BackupMaxClip(17)=0
	BackupMaxClip(18)=0
	BackupMaxClip(19)=0
	BackupMaxClip(20)=4
	BackupMaxClip(21)=0
	BackupMaxClip(22)=0
	BackupMaxClip(23)=0
	BackupMaxClip(24)=0
	BackupMaxClip(25)=0
	BackupMaxClip(26)=0
	BackupMaxClip(27)=2
	BackupMaxClip(28)=0
	BackupMaxClip(29)=0
	BackupMaxClip(30)=0

	BackupClipSize(1)=0
	BackupClipSize(2)=0
	BackupClipSize(3)=0
	BackupClipSize(4)=0
	BackupClipSize(5)=0
	BackupClipSize(6)=0
	BackupClipSize(7)=0
	BackupClipSize(8)=0
	BackupClipSize(9)=0
	BackupClipSize(10)=0
	BackupClipSize(11)=0
	BackupClipSize(12)=0
	BackupClipSize(13)=0
	BackupClipSize(14)=0
	BackupClipSize(15)=0
	BackupClipSize(16)=0
	BackupClipSize(17)=0
	BackupClipSize(18)=0
	BackupClipSize(19)=0
	BackupClipSize(20)=1
	BackupClipSize(21)=0
	BackupClipSize(22)=0
	BackupClipSize(23)=0
	BackupClipSize(24)=0
	BackupClipSize(25)=0
	BackupClipSize(26)=0
	BackupClipSize(27)=4
	BackupClipSize(28)=0
	BackupClipSize(29)=0
	BackupClipSize(30)=0

	WeaponTeam(0)=0
	WeaponTeam(1)=1
	WeaponTeam(2)=3
	WeaponTeam(3)=3
	WeaponTeam(4)=3
	WeaponTeam(5)=2
	WeaponTeam(6)=3
	WeaponTeam(7)=3
	WeaponTeam(8)=2
	WeaponTeam(9)=1
	WeaponTeam(10)=2
	WeaponTeam(11)=1
	WeaponTeam(12)=1
	WeaponTeam(13)=1
	WeaponTeam(14)=1
	WeaponTeam(15)=2
	WeaponTeam(16)=3
	WeaponTeam(17)=2
	WeaponTeam(18)=2
	WeaponTeam(19)=1
	WeaponTeam(20)=2
	WeaponTeam(21)=2
	WeaponTeam(22)=2
	WeaponTeam(23)=3
	WeaponTeam(24)=3
	WeaponTeam(25)=0
	WeaponTeam(26)=0
	WeaponTeam(27)=0
	WeaponTeam(28)=0
	WeaponTeam(29)=0
	WeaponTeam(30)=0

    WeaponFree(0)=0
    WeaponFree(1)=0
    WeaponFree(2)=0
    WeaponFree(3)=0
    WeaponFree(4)=0
    WeaponFree(5)=0
    WeaponFree(6)=0
    WeaponFree(7)=0
    WeaponFree(8)=0
    WeaponFree(9)=0
    WeaponFree(10)=0
    WeaponFree(11)=0
    WeaponFree(12)=0
    WeaponFree(13)=0
    WeaponFree(14)=0
    WeaponFree(15)=0
    WeaponFree(16)=0
    WeaponFree(17)=0
    WeaponFree(18)=0
    WeaponFree(19)=0
    WeaponFree(20)=0
    WeaponFree(21)=0
    WeaponFree(22)=0
    WeaponFree(23)=0
    WeaponFree(24)=0
    WeaponFree(25)=0
    WeaponFree(26)=0
    WeaponFree(27)=0
    WeaponFree(28)=0
    WeaponFree(29)=0
    WeaponFree(30)=0

    ItemFree(0)=0
    ItemFree(1)=0
    ItemFree(2)=0
    ItemFree(3)=0
    ItemFree(4)=0
    ItemFree(5)=0

    Special(0)=0
    Special(1)=1
    Special(2)=0
    Special(3)=1
    Special(4)=0
    Special(5)=0
    Special(6)=0
    Special(7)=0
    Special(8)=0

    Sort(1)=3
    Sort(2)=6
    Sort(3)=9
    Sort(4)=7
    Sort(5)=8
    Sort(6)=12
    Sort(7)=18
    Sort(8)=13
    Sort(9)=15
    Sort(10)=17
    Sort(11)=16
    Sort(12)=27
    Sort(13)=25
    Sort(14)=24
    Sort(15)=20
    Sort(16)=11
    Sort(17)=10
    Sort(18)=2
    Sort(19)=26
    Sort(20)=22
    Sort(21)=5
    Sort(22)=4
    Sort(23)=21
    Sort(24)=1
    Sort(25)=14
    Sort(26)=19
    Sort(27)=23
    Sort(28)=28
    Sort(29)=29
    Sort(30)=30

	Cheaper(1)=24
	Cheaper(2)=18
	Cheaper(3)=1
	Cheaper(4)=22
	Cheaper(5)=21
	Cheaper(6)=2
	Cheaper(7)=4
	Cheaper(8)=5
	Cheaper(9)=3
	Cheaper(10)=17
	Cheaper(11)=16
	Cheaper(12)=6
	Cheaper(13)=8
	Cheaper(14)=25
	Cheaper(15)=9
	Cheaper(16)=11
	Cheaper(17)=10
	Cheaper(18)=7
	Cheaper(19)=26
	Cheaper(20)=15
	Cheaper(21)=23
	Cheaper(22)=20
	Cheaper(23)=27
	Cheaper(24)=14
	Cheaper(25)=13
	Cheaper(26)=19
	Cheaper(27)=12
	Cheaper(28)=28
	Cheaper(29)=29
	Cheaper(30)=30

    RandomTime=0
}
