//----------------------------------------------------------------------------//
//	Project	:	TOSTWeaponsClient											  //
//	File	:	TOSTWeaponsClient.uc										  //
//	Version	:	1.2.1														  //
//	Author	:	H-Lotti														  //
//----------------------------------------------------------------------------//
//	Version	Changes															  //
//	0.1		+ First beta													  //
//	0.2		+ Remasterized the whole things									  //
//	0.x		+ bugs removed (compatible issues with other server, keybind bug) //
//	0.9		+ First official beta											  //
//  1.0		+ added c4														  //
//  1.1		+ added mutli c4												  //
//	1.2		+ added TearGas													  //
//	1.2.1	+ GasMask improved ( no blind | water heal | see text )			  //
//			+ spectator bug fixed											  //
//----------------------------------------------------------------------------//
//	MsgIdx		Details					Params								  //
//	550			GetAllWeaponsTeam		string weapons						  //
//	551			GetAWeaponTeam			int WeaponID, int team, int free	  //
//	552			GetASettings			int Index, string SettingName		  //
//	553			SwitchToCWMode			bool CWMode							  //
//	554			GasHurted													  //
//	555			GasReset													  //
//----------------------------------------------------------------------------//

class TOSTWeaponsClient extends TOSTClientPiece;

//sounds
#exec AUDIO IMPORT FILE="Sounds\TearGas\cough1.wav" NAME="cough1"
#exec AUDIO IMPORT FILE="Sounds\TearGas\cough2.wav" NAME="cough2"
#exec AUDIO IMPORT FILE="Sounds\TearGas\breath.wav" NAME="breath"

var string	WeaponStr[31], WeaponName[31], NormStr[31];
var float	WeaponWeight[31];
var	byte	LightWeapons, Crazy, MaxClip[31], BackupMaxClip[31], ClipSize[31], BackupClipSize[31], WeaponTeam[31], cheaper[31];
var bool	CWMode;

var S_Player_T PawnOwner;

//teargas related
var bool	bGmaskActive, bHasGasMask;
var byte	Teartime;

//----------------------------------------------------------------------------//
// TOSTClientPiece general function											  //
//----------------------------------------------------------------------------//
simulated function EventInit()
{
	Init_ClientWeapons();
	PawnOwner = S_Player_T(MasterTab.OwnerPlayerPawn);
	setTimer(0.4,true);
}


//----------------------------------------------------------------------------//
// TOSTClientPiece Message function											  //
//----------------------------------------------------------------------------//
simulated function EventMessage(int MsgIndex)
{
	switch (MsgIndex)
	{
		//	GetAllWeaponsTeam
		case BaseMessage	:	Get_AllWeaponsTeam(Handler.params.param4);
								break;
		//	GetAWeaponTeam
	    case BaseMessage+1	:	Get_AWeaponTeam(Handler.params.param1, Handler.params.param2, Handler.params.param3);
	                            break;
		//	GetASettings
	    case BaseMessage+2	:	Get_ASettings(Handler.params.param1, Handler.params.param4);
	                            break;
		//	SwitchTo
	    case BaseMessage+3	:	SwitchToCWMode(Handler.params.param5);
	                            break;
		//	GasHurted
	    case BaseMessage+4	:	GasHurted();
	                            break;
		//	GasReset
	    case BaseMessage+5	:	SetTearGas(Handler.params.param1);
	                            break;
		// view killer
		case BaseMessage+6	: 	viewKiller(Handler.params.param4);
								break;
    }

    super.EventMessage(MsgIndex);
}


//----------------------------------------------------------------------------//
// TOSTWeaponsClient Misc functions											  //
//----------------------------------------------------------------------------//
simulated function Init_ClientWeapons()
{
	local TOST_OICW TOICW;
    local int i;
    local class<s_weapon> buggy;

	if ( Class<TOSTWeapon>(DynamicLoadObject("FamasPack42.TOSTFAMAS",Class'Class')) != none )
		WeaponStr[25]="FamasPack42.TOSTFAMAS";
	if ( Class<TOSTWeapon>(DynamicLoadObject("SteyrAugPack42.TOSTSteyrAug",Class'Class')) != none )
		WeaponStr[26]="SteyrAugPack42.TOSTSteyrAug";
	if ( Class<TOSTWeapon>(DynamicLoadObject("TearGasPack42.TOST_GrenadeGas",Class'Class')) != none )
		WeaponStr[28]="TearGasPack42.TOST_GrenadeGas";
	if ( Class<TOSTWeapon>(DynamicLoadObject("C4Pack42.TOST_C4Lazer",Class'Class')) != none )
	{
		WeaponStr[29]="C4Pack42.TOST_C4Lazer";
		WeaponStr[30]="C4Pack42.TOST_C4Timer";
	}

    class's_SWAT.s_OICW'.default.BackupAmmo = 4;

	for ( i=1;i<25;i++)
	{
		class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i] = WeaponStr[i];
		class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[i] = WT_NONE;
	}

	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[25] = WeaponStr[25];
	class'TOModels.TO_WeaponsHandler'.default.WeaponName[25] = "FAMAS";
	class'TOModels.TO_WeaponsHandler'.default.BuyMenuScale[25] = 1.0;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[25] = WT_NONE;
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[26] = WeaponStr[26];
	class'TOModels.TO_WeaponsHandler'.default.WeaponName[26] = "SteyrAug";
	class'TOModels.TO_WeaponsHandler'.default.BuyMenuScale[26] = 1.0;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[26] = WT_NONE;
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[27] = WeaponStr[27];
	class'TOModels.TO_WeaponsHandler'.default.WeaponName[27] = "OICW";
	class'TOModels.TO_WeaponsHandler'.default.BuyMenuScale[27] = 1.0;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[27] = WT_NONE;
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[28] = WeaponStr[28];
	class'TOModels.TO_WeaponsHandler'.default.WeaponName[28] = "Teargas Grenade";
	class'TOModels.TO_WeaponsHandler'.default.BuyMenuScale[28] = 2.0;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[28] = WT_NONE;
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[29] = WeaponStr[29];
	class'TOModels.TO_WeaponsHandler'.default.WeaponName[29] = "Lazer C4";
	class'TOModels.TO_WeaponsHandler'.default.BuyMenuScale[29] = 2.0;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[29] = WT_NONE;
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[30] = WeaponStr[30];
	class'TOModels.TO_WeaponsHandler'.default.WeaponName[30] = "Timer C4";
	class'TOModels.TO_WeaponsHandler'.default.BuyMenuScale[30] = 2.0;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[30] = WT_NONE;

	/* used to remove an ucc bug :( "cant assign byte = 0 in defproperties"*/
	buggy = class<s_weapon>(DynamicLoadObject("C4Pack42.TOST_C4Lazer",Class'Class'));
	if ( buggy != none)
		buggy.default.maxclip = 0;
	buggy = class<s_weapon>(DynamicLoadObject("C4Pack42.TOST_C4Timer",Class'Class'));
	if ( buggy != none)
		buggy.default.maxclip = 0;

	buggy = class<s_weapon>(DynamicLoadObject("TearGasPack42.TOST_GrenadeGas",Class'Class'));
	if ( buggy != none)
		buggy.default.maxclip = 0;

	class<s_weapon>(DynamicLoadObject("TOSTWeapons42.TOST_Grenade",Class'Class')).default.maxclip=0;
	class<s_weapon>(DynamicLoadObject("TOSTWeapons42.TOST_GrenadeConc",Class'Class')).default.maxclip=0;
	class<s_weapon>(DynamicLoadObject("TOSTWeapons42.TOST_GrenadeFB",Class'Class')).default.maxclip=0;
	class<s_weapon>(DynamicLoadObject("TOSTWeapons42.TOST_GrenadeSmoke",Class'Class')).default.maxclip=0;
	/* done */

	LightWeapons = 0;
	ChangeLightMode();
	Crazy = 0;
	ChangeCrazyMode();

    SendMessage(BaseMessage);
}

simulated function Get_AllWeaponsTeam(String WeaponTeams)
{
    local int i, curs, team;

    for(i=1; i<33; i++)
    {
        curs = instr(WeaponTeams,";");
        team = int(left(Weaponteams,curs));
        Weaponteams = right(Weaponteams,len(Weaponteams)-(curs+1));

		if ( i < 31 )
	        WeaponTeam[i] = team;

        if ( i == 31 )
			if ( team != LightWeapons )
			{
				LightWeapons = team;
				ChangeLightMode();
			}

        if ( i == 32 )
			if ( team != Crazy )
			{
				Crazy = team;
				ChangeCrazyMode();
			}
    }
    if ( WeaponTeam[28] == 0)// remove gasmask if teargas unavailable
    {
    	bGmaskActive = false;
    	bHasGasMask = false;
    }
}

simulated function Get_AWeaponTeam(int Index, int Team, int Free)
{
   	if ( (Index >= 0) && (Index <= 30) )
    {
        if ( Team == 0 )
        {
            TOSTWeaponsTab(MasterTab).CHKSFW[Index].bChecked = false;
            TOSTWeaponsTab(MasterTab).CHKTERRW[Index].bChecked = false;
        }
        else if ( Team == 1 )
        {
            TOSTWeaponsTab(MasterTab).CHKSFW[Index].bChecked = true;
            TOSTWeaponsTab(MasterTab).CHKTERRW[Index].bChecked = true;
        }
        else if ( Team == 2 )
        {
            TOSTWeaponsTab(MasterTab).CHKSFW[Index].bChecked = true;
            TOSTWeaponsTab(MasterTab).CHKTERRW[Index].bChecked = false;
        }
        else
        {
            TOSTWeaponsTab(MasterTab).CHKSFW[Index].bChecked = false;
            TOSTWeaponsTab(MasterTab).CHKTERRW[Index].bChecked = true;
        }

        TOSTWeaponsTab(MasterTab).CHKFreeW[Index].bChecked = bool(Free);
	}
	else if ( (Index >= 50) && (Index <= 55) )
	{
		TOSTWeaponsTab(MasterTab).CHKFreeI[Index-50].bChecked = bool(Free);
	}
	else if ( (Index >= 40) && (Index <= 48) )
	{
		TOSTWeaponsTab(MasterTab).CHKSpec[Index-40].bChecked = bool(Free);
		if ( Index == 45 )
			TOSTWeaponsTab(MasterTab).UpDownRandomTime.value = Team;
	}
}

simulated function Get_ASettings(int Index, string SettingName)
{
	TOSTWeaponsTab(MasterTab).EditSettings[Index].SetValue(SettingName);
}

simulated function int GetIdByClass (string weaponclass)
{
	local int i;

	for (i=1; i < 31; i++)
		if (WeaponStr[i] ~= weaponclass)
			return i;
	return -1;
}

simulated function ChangeLightMode()
{
	local int i;
	local TOSTWeapon Weapon;

	if ( LightWeapons == 1 )
	{
		for ( i=1; i<31; i++ )
			Class<TOSTWeapon>(DynamicLoadObject(WeaponStr[i],Class'Class')).default.WeaponWeight = 0.0;

		foreach AllActors(class'TOSTWeapon', Weapon)
			Weapon.WeaponWeight = 0.0;
	}
	else
	{
		for ( i=1; i<31; i++ )
			Class<TOSTWeapon>(DynamicLoadObject(WeaponStr[i],Class'Class')).default.WeaponWeight = weaponweight[i];

		foreach AllActors(class'TOSTWeapon', Weapon)
		{
			i = GetidByClass(string(Weapon.class));
			if ( i != -1 )
				Weapon.WeaponWeight = WeaponWeight[i];
		}
	}
}

simulated function ChangeCrazyMode()
{
	local int h,i;
	local TOSTWeapon Weapon;

	if ( Crazy == 1 )
	{
		for ( h=1; h<24; h++ )
		{
			i= cheaper[h];
			Class<TOSTWeapon>(DynamicLoadObject(WeaponStr[i],Class'Class')).default.ClipSize = 255;
			Class<TOSTWeapon>(DynamicLoadObject(WeaponStr[i],Class'Class')).default.ClipAmmo = 255;
			Class<TOSTWeapon>(DynamicLoadObject(WeaponStr[i],Class'Class')).default.MaxClip = 255;
	    	if ( BackupMaxClip[i] != 0 )
	    	{
				Class<TOSTWeapon>(DynamicLoadObject(WeaponStr[i],Class'Class')).default.BackupClipSize = 255;
				Class<TOSTWeapon>(DynamicLoadObject(WeaponStr[i],Class'Class')).default.BackupAmmo = 255;
				Class<TOSTWeapon>(DynamicLoadObject(WeaponStr[i],Class'Class')).default.BackupMaxClip = 255;
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
					Weapon.RemainingClip = 255;
					if ( BackupMaxClip[i] != 0 )
					{
						Weapon.BackupClipSize = 255;
						Weapon.BackupAmmo = 255;
						Weapon.BackupMaxClip = 255;
						Weapon.BackupClip = 255;
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
			Class<TOSTWeapon>(DynamicLoadObject(WeaponStr[i],Class'Class')).default.ClipSize = ClipSize[i];
			Class<TOSTWeapon>(DynamicLoadObject(WeaponStr[i],Class'Class')).default.ClipAmmo = ClipSize[i];
			Class<TOSTWeapon>(DynamicLoadObject(WeaponStr[i],Class'Class')).default.MaxClip = MaxClip[i];
	    	if ( BackupMaxClip[i] != 0 )
	    	{
				Class<TOSTWeapon>(DynamicLoadObject(WeaponStr[i],Class'Class')).default.BackupClipSize = BackupClipSize[i];
				Class<TOSTWeapon>(DynamicLoadObject(WeaponStr[i],Class'Class')).default.BackupAmmo = BackupClipSize[i];
				Class<TOSTWeapon>(DynamicLoadObject(WeaponStr[i],Class'Class')).default.BackupMaxClip = BackupMaxClip[i];
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

simulated function SwitchToCWMode(bool CW)
{
	local int i;

	CWMode = CW;
	if ( CWMode )
	{
		bGmaskActive = false;
		bHasGasMask = false;
	}
}

simulated function GasHurted()
{
	if ( bGmaskActive )
		return;

	if ( Teartime < 225 )
	{
		Teartime += 30;
	}
	if ( PawnOwner.Health > 30 )
	{
		SendMessage(559);
	}
	PawnOwner.PainTime=1.00;
}

simulated function BuyGasmask (bool eGasmask)
{
	if ( bHasGasmask && !eGasmask )
		bGmaskActive = false;

	SendMessage(558,int(bHasGasmask),,,,eGasmask);
	bHasGasmask = eGasmask;
}

simulated function GasMask()
{
	if ( bHasGasmask )
		bGmaskActive = !bGmaskActive;
}

simulated function SetTearGas(int possess)
{
	TearTime = 0;
	if ( possess == 1 )
		bHasGasMask = true;
}

simulated function keyBindBuy(int code)
{
	setSpecialHandlerWeaponTeam();
	PawnOwner.s_kammoAuto(code);
	setNormalHandlerWeaponTeam();
}

simulated function setSpecialHandlerWeaponTeam()
{
	local int i;
	class'TOModels.TO_WeaponsHandler'.default.NumWeapons = 30;
	for (i=1; i<31; i++)
	{
		class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i] = WeaponStr[i];
		class'TOModels.TO_WeaponsHandler'.default.WeaponName[i] = WeaponName[i];

    	if ( WeaponTeam[i] == 0 )
            class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[i] = WT_NONE;
    	else if ( WeaponTeam[i] == 1 )
            class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[i] = WT_BOTH;
    	else if ( WeaponTeam[i] == 2 )
            class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[i] = WT_SpecialForces;
        else class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[i] = WT_Terrorist;
    }
}

simulated function setNormalHandlerWeaponTeam()
{
	local int i;
	class'TOModels.TO_WeaponsHandler'.default.NumWeapons = 24;
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

	for ( i=1; i<31; i++ )
	{
		class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i]=NormStr[i];
	}
}

simulated function viewKiller(string nom)
{
	local Pawn tmp, killer;

	if ( nom == "" )
	{
		if ( Pawn(PawnOwner.viewTarget).PlayerReplicationInfo.TeamID != PawnOwner.PlayerReplicationInfo.TeamID )
			PawnOwner.fire();
		return;
	}

	foreach allactors(class'pawn',tmp)
	{

		if ( tmp.bIsPlayer && (tmp.PlayerReplicationInfo.PlayerName ~= nom) )
		{
			killer = tmp;
			break;
		}
	}
	if ( killer != none )
	{
		if ( killer == PawnOwner )
			PawnOwner.ViewTarget = none;
		else
		{
			PawnOwner.ClientMessage(PawnOwner.ViewingFrom @ killer.PlayerReplicationInfo.PlayerName,'Event',True);
			PawnOwner.ViewTarget = killer;
		}
	}
}

simulated function Timer ()
{
	if ( PawnOwner.bnotplaying )
	{
		TearTime = 0;
		return;
	}

	if ( PawnOwner.Region.Zone.bWaterZone && TearTime > 0 )
	{
		TearTime = 0;
		PawnOwner.ClientPlaySound(Sound'gasp02',,True);
		return;
	}

	if (TearTime > 0)
	{
		TearTime-=2;

		if (Frand() <0.14)
		{
			if (Frand() < 0.5)
				PawnOwner.ClientPlaySound(sound'cough1',,True);
			else
				PawnOwner.ClientPlaySound(sound'cough2',,True);

			PawnOwner.ShakeView(1, TearTime * 6, TearTime * 0.2);
		}
	}
}
//----------------------------------------------------------------------------//
// TOSTWeaponsClient defaultproperties										  //
//----------------------------------------------------------------------------//

defaultproperties
{
    BaseMessage=550

	NormStr(1)="s_SWAT.s_DEagle"
	NormStr(2)="s_SWAT.s_MAC10"
	NormStr(3)="s_SWAT.s_MP5N"
	NormStr(4)="s_SWAT.s_Mossberg"
	NormStr(5)="s_SWAT.s_M3"
	NormStr(6)="s_SWAT.s_Ak47"
	NormStr(7)="s_SWAT.TO_SteyrAug"
	NormStr(8)="s_SWAT.TO_M4A1"
	NormStr(9)="s_SWAT.TO_M16"
	NormStr(10)="s_SWAT.TO_HK33"
	NormStr(11)="s_SWAT.s_PSG1"
	NormStr(12)="s_SWAT.TO_Grenade"
	NormStr(13)="s_SWAT.s_GrenadeFB"
	NormStr(14)="s_SWAT.s_GrenadeConc"
	NormStr(15)="s_SWAT.s_p85"
	NormStr(16)="s_SWAT.TO_Saiga"
	NormStr(17)="s_SWAT.TO_MP5KPDW"
	NormStr(18)="s_SWAT.TO_Berreta"
	NormStr(19)="s_SWAT.TO_GrenadeSmoke"
	NormStr(20)="s_SWAT.TO_M4m203"
	NormStr(21)="s_SWAT.TO_HKSMG2"
	NormStr(22)="s_SWAT.TO_RagingBull"
	NormStr(23)="s_SWAT.TO_m60"
	NormStr(24)="s_SWAT.s_Glock"
	NormStr(25)=""
	NormStr(26)=""
	NormStr(27)=""
	NormStr(28)=""
	NormStr(29)=""
	NormStr(30)=""

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
	WeaponStr(25)="TOSTWeapons42.TOST_EmptyWeapon"
	WeaponStr(26)="TOSTWeapons42.TOST_EmptyWeapon"
	WeaponStr(27)="TOSTWeapons42.TOST_OICW"
	WeaponStr(28)="TOSTWeapons42.TOST_EmptyWeapon"
	WeaponStr(29)="TOSTWeapons42.TOST_EmptyWeapon"
	WeaponStr(30)="TOSTWeapons42.TOST_EmptyWeapon"

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
	WeaponName(24)="Glock 21"
	WeaponName(25)="FAMAS F1"
	WeaponName(26)="Steyr Aug"
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
}
