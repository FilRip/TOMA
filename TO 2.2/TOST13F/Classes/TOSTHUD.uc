//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTHUD.uc
// Version : 1.2
// Author  : BugBunny
//----------------------------------------------------------------------------

class TOSTHUD extends Mutator config(user);

var float zzFadeOut;		// How long for the fade out
var float zzTotalTime;		// How long total will it be displayed
var TOSTRI zzRI;		// Pointer back the TOSTRI for passing back the canvas
var Hud zzMyHud;		// Pointer to the player's hud
var float zzFadeTimer;		// Used to fade out
var bool zzbHudOff;		// If true, don't render
var bool zzbInitialized;	// Once initialized, fade out
var mutator zzNextHud;

var globalconfig bool ShowTeamInfo;
var globalconfig int  WeaponHUDType;

var Texture zzHUDTex[23]; 	// HUD Weapon Icons
var Texture zzDotTex;

var int zzTerrTeamCount, zzTerrTeamAlive, zzSwatTeamCount, zzSwatTeamAlive;

var string zzVersionStr;	// Holds the version code from VUC++
var string zzMsg[5];

simulated event PostNetBeginPlay ()
{
	Super.PostNetBeginPlay();
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
	for (i=0; i<5; i++)
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
// Tick - Just decrease the fade timer.
// ==================================================================================
simulated function Tick(float zzdelta)
{
	if (!zzbInitialized)
	{
		return;
	}
	if (zzFadeTimer>=0.0)
		zzFadeTimer-= zzDelta;
	else
		zzbHudOff = true;
	Super.Tick(zzdelta);

} // Tick

simulated function Timer()
{
	local PlayerReplicationInfo zzPRI;

	zzTerrTeamCount = 0;
	zzTerrTeamAlive = 0;
	zzSwatTeamCount = 0;
	zzSwatTeamAlive = 0;
	foreach AllActors(class'PlayerReplicationInfo', zzPRI)
	{
		if (zzPRI.Team == 0)
		{
			zzTerrTeamCount++;
			if (zzPRI.Owner != None && (zzPRI.Owner.isA('s_Player') || zzPRI.Owner.isA('s_Bot'))) {
				if (Pawn(zzPRI.Owner).Health > 0)
					zzTerrTeamAlive++;
			}
		} else {
			if (zzPRI.Team == 1) {
				zzSwatTeamCount++;
				if (zzPRI.Owner != None && (zzPRI.Owner.isA('s_Player')|| zzPRI.Owner.isA('s_Bot'))) {
					if (Pawn(zzPRI.Owner).Health > 0)
						zzSwatTeamAlive++;
				}
			} else {
				// Hostages
			}

		}
	}

}

// ==================================================================================
// Weapon HUD Extension functions
// ==================================================================================
simulated function int WeaponCount()
{
	local Inventory zzInv;
	local int zzi, zzj;

	for (zzInv = s_Player(zzRI.zzMyPlayer).Inventory; zzInv != None; zzInv = zzInv.Inventory)
	{
		if (zzInv.isA('s_Weapon') && !zzInv.isA('s_C4'))
			zzi++;
		zzj++;
		if (zzj > 25)
			break;
	}
	return zzi;
}

simulated function float GetWeaponAmmunition(s_Weapon zzWeapon)
{
	local int zzmax, zzcur;

	// Nade/Knife fix
	if (zzWeapon.isA('TO_Grenade') || zzWeapon.isA('s_Knife')) {
		return 1;
	} else {
		zzmax = (zzWeapon.MaxClip+1) * zzWeapon.ClipSize;
		zzcur = zzWeapon.RemainingClip * zzWeapon.ClipSize + zzWeapon.ClipAmmo;

		return float(zzcur)/float(zzmax);
	}
}

simulated function float GetClipAmmunition(s_Weapon zzWeapon)
{
	local int zzmax, zzcur;

	// Nade/Knife fix
	if (zzWeapon.isA('TO_Grenade') || zzWeapon.isA('s_Knife')) {
		return 1;
	} else {
		zzmax = zzWeapon.ClipSize;
		zzcur = zzWeapon.ClipAmmo;

		return float(zzcur)/float(zzmax);
	}
}

simulated function s_Weapon GetWeaponByGroup(int zzInventoryGroup)
{
	local Inventory zzInv;
	local s_Weapon zzw;
	local int zzCount;


	for (zzInv = s_Player(zzRI.zzMyPlayer).Inventory; zzInv != None; zzInv = zzInv.Inventory)
	{
		zzw = s_Weapon(zzInv);
		if (zzw != None) {
			// OICW special handling
			if (zzw.InventoryGroup == zzInventoryGroup && !zzw.IsA('s_OICW'))
			{
				return zzw;
			}
			if (zzInventoryGroup == 6 && zzw.IsA('s_OICW'))
			{
				return zzw;
			}
		}
		zzCount++;
		if (zzCount > 25)	//avoid endless loop for circle in inventory list...
			break;
	}
	return None;
}

simulated function Texture GetWeaponIcon(s_Weapon zzWeapon)
{
	if (zzWeapon.isA('s_Knife'))
		return zzHUDTex[0];

	if (zzWeapon.isA('TO_Berreta'))
		return zzHUDTex[1];
	if (zzWeapon.isA('s_Glock'))
		return zzHUDTex[2];
	if (zzWeapon.isA('s_DEagle'))
		return zzHUDTex[3];

	if (zzWeapon.isA('s_GrenadeConc'))
		return zzHUDTex[4];
	if (zzWeapon.isA('s_GrenadeFB'))
		return zzHUDTex[5];
	if (zzWeapon.isA('TO_GrenadeSmoke'))
		return zzHUDTex[6];
	if (zzWeapon.isA('TO_Grenade'))
		return zzHUDTex[7];

	if (zzWeapon.isA('s_MAC10'))
		return zzHUDTex[8];
	if (zzWeapon.isA('s_MP5N'))
		return zzHUDTex[9];
	if (zzWeapon.isA('TO_MP5KPDW'))
		return zzHUDTex[10];

	if (zzWeapon.isA('s_M3'))
		return zzHUDTex[11];
	if (zzWeapon.isA('s_Mossberg'))
		return zzHUDTex[12];
	if (zzWeapon.isA('TO_Saiga'))
		return zzHUDTex[13];

	if (zzWeapon.isA('s_Ak47'))
		return zzHUDTex[14];
	if (zzWeapon.isA('s_FAMAS'))
		return zzHUDTex[15];
	if (zzWeapon.isA('s_HKSR9'))
		return zzHUDTex[16];
	if (zzWeapon.isA('TO_SteyrAug'))
		return zzHUDTex[17];
	if (zzWeapon.isA('TO_HK33'))
		return zzHUDTex[18];

	if (zzWeapon.isA('s_P85'))
		return zzHUDTex[19];
	if (zzWeapon.isA('s_PSG1'))
		return zzHUDTex[20];

	if (zzWeapon.isA('TO_M4m203'))
		return zzHUDTex[21];
	if (zzWeapon.isA('s_OICW'))
		return zzHUDTex[22];

	return None;
}

// ==================================================================================
// PostRender - Display our logo and the HUD extensions
// ==================================================================================
simulated function PostRender(Canvas zzC)
{
	local float zzMyX, zzMyY, zzCX, zzCY, zzScale, zzCC, zzCD;
	local float zzFadeValue;
	local int i, j, zzInvGroup, zzCB;
	local string zzmMsg;
	local s_Weapon zzWeapon;
	local Texture zzTex;
	local bool zzReload;


	if (zzRI != None && zzRI.zzMyPlayer != None && zzRI.zzMyPlayer.MyHud != None)
	{
		zzMyHud = zzRI.zzMyPlayer.MyHud;

		// ToST Logo

		if (!zzbInitialized)
		{
			zzmMsg = zzMsg[0];
			zzFadeTimer = zzTotalTime;
		}
		else
			zzmMsg = zzMsg[1];

		if (!zzbHudOff && zzFadeTimer>0)
		{

			zzC.Style = ERenderStyle.STY_Translucent;

			if (zzFadeTimer<=zzFadeOut)
				zzFadeValue = zzFadeTimer / zzFadeOut;
			else
				zzFadeValue = 1;
			zzScale = ChallengeHUD(zzMyHud).Scale;

			zzMyX = zzC.ClipX / 2;
			zzMyY = zzC.ClipY - 160 * zzScale - 64;

			zzC.DrawColor = ChallengeHud(zzMyHud).GoldColor * zzFadeValue;
			zzC.Font = ChallengeHud(zzMyHud).MyFonts.GetSmallFont(zzC.ClipX);
			zzC.TextSize(zzVersionStr, zzCX, zzCY);
			zzC.SetPos(zzMyX-(zzCX/2),zzMyY);
			zzC.DrawText(zzVersionStr);
			zzC.Font = ChallengeHud(zzMyHud).MyFonts.GetSmallestFont(zzC.ClipX);
			zzC.TextSize(zzmMsg, zzCX, zzCY);
			zzC.SetPos(zzMyX-(zzCX/2),zzMyY+24);
			zzC.DrawText(zzmMsg);
			zzC.Style = ERenderStyle.STY_Normal;
		}

		// Team Info

		if (zzRI.zzbShowTeamInfo && zzRI.zzAllowHUD) {
			zzScale = ChallengeHUD(zzMyHud).Scale;

			if (zzRI.zzShowWeapon == 2)
				zzMyX = (zzC.ClipX - 120);
			else
				zzMyX = (zzC.ClipX - 60);
			zzMyY = 160;

			zzC.Style = ERenderStyle.STY_Normal;

			zzC.Font = ChallengeHud(zzMyHud).MyFonts.GetSmallFont(zzC.ClipX);

			zzC.DrawColor.R = 255;
			zzC.DrawColor.G = 0;
			zzC.DrawColor.B = 0;
			zzC.TextSize(zzMsg[2], zzCX, zzCY);
			zzC.SetPos(zzMyX - zzCX, zzMyY);
			zzC.DrawText(zzMsg[2]);
			zzC.SetPos(zzMyX, zzMyY);
			zzC.DrawText(zzTerrTeamAlive$" ("$zzTerrTeamCount$")");

			zzC.DrawColor.R = 0;
			zzC.DrawColor.G = 0;
			zzC.DrawColor.B = 255;
			zzC.TextSize(zzMsg[3], zzCX, zzCY);
			zzC.SetPos(zzMyX - zzCX, zzMyY + 20);
			zzC.DrawText(zzMsg[3]);
			zzC.SetPos(zzMyX, zzMyY + 20);
			zzC.DrawText(zzSwatTeamAlive$" ("$zzSwatTeamCount$")");

		}

		// Weapon Info

		if (zzRI.zzShowWeapon != 0 && zzRI.zzMyPlayer != None && zzRI.zzMyPlayer.Inventory != None && zzRI.zzAllowHUD) {
			if (zzRI.zzShowWeapon == 2)
			{
				zzWeapon = s_Weapon(zzRI.zzMyPlayer.Weapon);
				zzScale = ChallengeHUD(zzMyHud).Scale;
				zzMyX = zzC.ClipX - 120;
				zzMyY = 160;
				zzC.Style = ERenderStyle.STY_Normal;
				zzC.Font = ChallengeHud(zzMyHud).MyFonts.GetSmallFont(zzC.ClipX);

				zzC.DrawColor.R = 0;
				zzC.DrawColor.G = 255;
				zzC.DrawColor.B = 0;
				zzC.TextSize(zzMsg[4], zzCX, zzCY);
				zzC.SetPos(zzMyX - zzCX, zzMyY + 40);
				zzC.DrawText(zzMsg[4]);
				zzC.SetPos(zzMyX, zzMyY + 40);
				zzC.DrawText(zzWeapon.ItemName);
			} else {

				zzScale = ChallengeHUD(zzMyHud).Scale;
				zzMyY = zzC.ClipY - 152 * zzScale;
				zzC.Style = ERenderStyle.STY_Normal;
				zzC.Font = ChallengeHud(zzMyHud).MyFonts.GetSmallFont(zzC.ClipX);

				i = WeaponCount();
				j = 0;
				zzInvGroup = 1;
				do {
					zzWeapon = GetWeaponByGroup(zzInvGroup);
					if (zzWeapon != None) {
						zzMyX = (200*zzScale) + ((zzC.ClipX - (512*zzScale)) / (i-1)) * j;
						j++;

						zzTex = GetWeaponIcon(zzWeapon);

						zzC.Style = ERenderStyle.STY_Translucent;

						zzCC = GetWeaponAmmunition(zzWeapon);
						zzCD = 1.0-zzCC;
						if (zzRI.zzMyPlayer.Weapon == zzWeapon)
						{
							zzCB = 255;
							zzReload = zzWeapon.bReloadingWeapon;
						} else {
							zzCB = 127;
							zzReload = False;
						}
						zzC.DrawColor.R = zzCB * zzCD;
						zzC.DrawColor.G = zzCB * zzCC;
						zzC.DrawColor.B = 0;

						zzC.SetPos(zzMyX, zzMyY);
						zzC.DrawIcon(zzTex, zzScale);

						if (!zzReload) {
							zzCC = GetClipAmmunition(zzWeapon);
							zzCD = 1.0-zzCC;

							zzC.DrawColor.R = zzCB * zzCD;
							zzC.DrawColor.G = zzCB * zzCC;
							zzC.DrawColor.B = 0;
						} else {
							zzC.DrawColor.R = 0;
							zzC.DrawColor.G = 0;
							zzC.DrawColor.B = 255;
						}

						zzC.SetPos(zzMyX + (zzScale*128) - 96, zzMyY - 96);
						zzC.bNoSmooth = False;
						zzC.DrawIcon(zzDotTex, 3.0);

						zzC.Style = ERenderStyle.STY_Normal;

					}
					zzInvGroup++;
				} until (j>=i || zzInvGroup > 10)
			}
		}
	}

	if (zzNextHud != None && zzNextHud != Self)
		zzNextHud.PostRender(zzC);

} // PostRender

function Init()
{
	local string zzPackage;

	zzPackage = "TOSTTex.";
	zzHUDTex[0] = Texture(DynamicLoadObject(zzPackage$"Knife", class'Texture'));
	zzHUDTex[1] = Texture(DynamicLoadObject(zzPackage$"Berreta", class'Texture'));
	zzHUDTex[2] = Texture(DynamicLoadObject(zzPackage$"Glock", class'Texture'));
	zzHUDTex[3] = Texture(DynamicLoadObject(zzPackage$"deagle", class'Texture'));
	zzHUDTex[4] = Texture(DynamicLoadObject(zzPackage$"concussion", class'Texture'));
	zzHUDTex[5] = Texture(DynamicLoadObject(zzPackage$"flash", class'Texture'));
	zzHUDTex[6] = Texture(DynamicLoadObject(zzPackage$"Smoke", class'Texture'));
	zzHUDTex[7] = Texture(DynamicLoadObject(zzPackage$"he", class'Texture'));
	zzHUDTex[8] = Texture(DynamicLoadObject(zzPackage$"mac10", class'Texture'));
	zzHUDTex[9] = Texture(DynamicLoadObject(zzPackage$"MP5Navy", class'Texture'));
	zzHUDTex[10] = Texture(DynamicLoadObject(zzPackage$"mp5kpdw", class'Texture'));
	zzHUDTex[11] = Texture(DynamicLoadObject(zzPackage$"Benelli", class'Texture'));
	zzHUDTex[12] = Texture(DynamicLoadObject(zzPackage$"mossberg", class'Texture'));
	zzHUDTex[13] = Texture(DynamicLoadObject(zzPackage$"Saiga", class'Texture'));
	zzHUDTex[14] = Texture(DynamicLoadObject(zzPackage$"Ak47", class'Texture'));
	zzHUDTex[15] = Texture(DynamicLoadObject(zzPackage$"FAMAS", class'Texture'));
	zzHUDTex[16] = Texture(DynamicLoadObject(zzPackage$"hksr9", class'Texture'));
	zzHUDTex[17] = Texture(DynamicLoadObject(zzPackage$"Steyr", class'Texture'));
	zzHUDTex[18] = Texture(DynamicLoadObject(zzPackage$"HK33", class'Texture'));
	zzHUDTex[19] = Texture(DynamicLoadObject(zzPackage$"PH85", class'Texture'));
	zzHUDTex[20] = Texture(DynamicLoadObject(zzPackage$"PSG1", class'Texture'));
	zzHUDTex[21] = Texture(DynamicLoadObject(zzPackage$"M4", class'Texture'));
	zzHUDTex[22] = Texture(DynamicLoadObject(zzPackage$"OICW", class'Texture'));

	zzDotTex = Texture(DynamicLoadObject("Botpack.CHair8", class'Texture'));

	SetTimer(1, true);
	zzbInitialized = true;
}

// ==================================================================================
// Auto state - just set up the standard values
// ==================================================================================
auto state zzTimeBomb
{
begin:
	zzDecryptStrings("CheckAimbot");
	zzFadeTimer = zzTotalTime;
}

/*
     zzFadeOut=2.000000
     zzTotalTime=8.000000
     zzVersionStr="TOST v1.2"
     zzMsg(0)="Connecting to Server..."
     zzMsg(1)="Client Verified and Connected"
     zzMsg(2)="Terr : "
     zzMsg(3)="Swat : "
     zzMsg(4)="Weapon : "
*/

defaultproperties
{
     zzFadeOut=2.000000
     zzTotalTime=8.000000
     zzVersionStr="TOST v1.3F"
     zzMsg(0)="AF58r@'n/pKsyR_(N6h?>r@"
     zzMsg(1)=")F5wJ8E:54#094z6,]zSuk26zyRnx"
     zzMsg(2)="z74@L2("
     zzMsg(3)="'eg$Psv"
     zzMsg(4)="V]2+z Ou)"
}
