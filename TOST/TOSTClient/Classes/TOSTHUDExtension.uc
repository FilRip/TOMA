// $Id: TOSTHUDExtension.uc 519 2004-04-01 23:43:40Z stark $
//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTHUDExtension.uc
// Version : 1.0
// Author  : BugBunny/MadOnion
//----------------------------------------------------------------------------

class TOSTHUDExtension expands TOSTHUDMutator config (TOSTUser);

#exec texture IMPORT NAME=Frame FILE=Textures\Frame.PCX MIPS=OFF FLAGS=3
#exec texture IMPORT NAME=DemoIndicator FILE=Textures\DemoIndicator.pcx MIPS=OFF FLAGS=2
#exec AUDIO IMPORT FILE="Sounds\HitSound.WAV" NAME="hitsound" GROUP="hitsound"
#exec AUDIO IMPORT FILE="Sounds\HitSoundFriendly.WAV" NAME="hitsoundteam" GROUP="hitsoundteam"
//#exec texture IMPORT NAME=hud_elements FILE=Textures\hud_elements.pcx GROUP="GUI" MIPS=OFF FLAGS=2

// HUD status messages
var string 	HUDMsg[6], DrawnText;
var int		HUDMsgTime[6];
var int 	MsgTotalTime, TextSpeed, LettersFading;
var	int		Ignored[32];
var float 	TimeBetweenMessages, MsgTick;

// Team HUD
var int		TerrTeamCount, TerrTeamAlive,
			SwatTeamCount, SwatTeamAlive,
			HossieCount, HossieAlive;

var config	int		TeamInfoStyle;

// Weapon HUD
var string		TextureSetNames;
var Texture		WeaponTex[27];
var Texture		DecoTex[2];
var bool		TexturesPresent;

var config	int		WeaponHUDStyle;

// Demo/Admin notification
var bool		bDemo;
var float		AdminWarning, AdminWarnStep;
var	int			SemiAdmin;

// AllowSound (just here to have it always avaiable)
var config	float	AllowedSoundLength;
var config	int		AllowedSoundClass;

// Console Log
var	byte			LastLineLogged;

var config	bool	LogConsole;

// Scoreboard
var bool			FirstShow;
var config	byte	SortMode;

// ScreenFlashes
var config	bool	HitFlashes;

// Clock Display ;)
var bool    bShowTime;
var int     TimeDisplayEnd;

// Debug
var float			MaxV, MaxA;

// - standard functions

simulated function	Init()
{
	super.Init();
	SetTimer(1, true);
	InitTextures();
	SwitchWeaponHud(true);
	AdminWarning = 0.3;
	AdminWarnStep = 1;
	SaveConfig();
	LastLineLogged = MyPlayer.Player.Console.TopLine;
}

simulated function	PostRender(Canvas C)
{
	local Font PreviousFont;
	local bool PreviousCenter;
	local Color PreviousColor;
	local byte PreviousStyle;

	PreviousCenter=c.bCenter;
	PreviousColor=c.DrawColor;
	PreviousFont=C.Font;
	PreviousStyle=c.Style;
	c.Reset();

	DrawDebug(C);
	DrawStatusTextBox(C);
	DrawTeamHUD(C);
	DrawWeaponHUD(C);
	DrawCameraInScoreScreen(C);
	DrawDemoNotification(C);
	DrawAdminNotification(C);
	DrawTime(C);

	c.bCenter=PreviousCenter;
	c.DrawColor=PreviousColor;
	c.Font=PreviousFont;
	c.Style=PreviousStyle;

	super.PostRender(C);
}

simulated function Tick(float Delta)
{
	local	string	s;
	local	Console C;
	local	byte	OldSortMode;
	local	int		i;

    // ScreenFlashes
	if (!HitFlashes)
	{
		MyPlayer.DesiredFlashScale = 0.0;
		MyPlayer.DesiredFlashFog = Vect(0,0,0);
		MyPlayer.InstantFlash = 0.0;
		MyPlayer.InstantFog = Vect(0,0,0);
	}

	// HUD status message
	MsgTick += Delta * TextSpeed;

	C = MyPlayer.Player.Console;
	S = C.GetMsgText(C.TopLine);

	// Demo Notification
	if ((InStr(S, "Demo recording started to ") == 0) && (!bDemo))
	{
		Comm.SendMessage(131,PlayerPawn(Owner.Owner).PlayerReplicationInfo.PlayerID,,,,true);
		bDemo = true;
	}
	if ((InStr(S, "Demo") == 0 && InStr(S, "stopped (") != -1 && InStr(S, " frames)") != -1) && (bDemo))
	{
		Comm.SendMessage(131,PlayerPawn(Owner.Owner).PlayerReplicationInfo.PlayerID,,,,false);
		bDemo = false;
	}

	// Console Log
	if (LogConsole && LastLineLogged != C.TopLine)
	{
		while (LastLineLogged != C.TopLine)
		{
			LastLineLogged++;
			if (LastLineLogged >= C.MaxLines)
				LastLineLogged = 0;
			if( ( C.GetMsgType(LastLineLogged) == 'Say' ) || ( C.GetMsgType(LastLineLogged) == 'TeamSay' ) )
				Log( C.GetMsgPlayer(LastLineLogged).PlayerName$":"@C.GetMsgText(LastLineLogged), 'Console' );
			else
				Log( C.GetMsgText(LastLineLogged), 'Console' );
		}
	}

	// Admin Notification
	if ((AdminWarning + (AdminWarnStep*Delta) > 0.7) || (AdminWarning + (AdminWarnStep*Delta) < 0.3))
		AdminWarnStep = -AdminWarnStep;
	AdminWarning += AdminWarnStep*Delta;
	if (AdminWarning > 0.7)
		AdminWarning = 0.7;
	if (AdminWarning < 0.3)
		AdminWarning = 0.3;

	// Scoreboardtracking
	if (s_HUD(myHUD) != none)
	{
		if (s_HUD(MyHUD).UserInterface.Visible() &&	s_HUD(MyHUD).UserInterface.CurrentTab==10)
		{
			if (!FirstShow)
			{
				FirstShow = true;
				switch (TO_GUITabScores(s_HUD(MyHUD).UserInterface.GetCurrentTab()).SortMode)
				{
					case 	SM_SCOREPTS		:	if (SortMode == 1)
													s_HUD(MyHUD).UserInterface.OwnerToggleMode();
												break;
					case	SM_KILLRATIO	:	if (SortMode == 0)
													s_HUD(MyHUD).UserInterface.OwnerToggleMode();
												break;
				}
			} else {
				OldSortMode = SortMode;
				switch (TO_GUITabScores(s_HUD(MyHUD).UserInterface.GetCurrentTab()).SortMode)
				{
					case 	SM_SCOREPTS		:	SortMode = 0; break;
					case	SM_KILLRATIO	:	SortMode = 1; break;
				}
				if (OldSortMode != SortMode)
					SaveConfig();
			}
		}
	}

	// Notify TOST the player changed the game password (for slot reserver)
	if ( Instr(Caps(S),"ADMIN SET ENGINE.GAMEINFO") != -1)
	{
		i = Instr(Caps(S)," GAMEPASSWORD");
		if ( i != -1 )
		{
			Comm.SendMessage(121,101,,,Right(S,Len(S)-i-14));
			PlayerPawn(Owner.Owner).Player.Console.addstring("");
		}
	}
}

simulated function Timer()
{
	// Team HUD
	CalculateTeamStats();
}

simulated function	PlayClientSound(string MySound, optional int MyClass, optional int PID)
{
	local	Sound	S;

	S = Sound(DynamicLoadObject(MySound, class'Sound', true));

	if (S != none && (AllowedSoundLength == 0 || AllowedSoundLength >= GetSoundDuration(S)) && ((1 << MyClass) & AllowedSoundClass) != 0 && !IsIgnored(PID))
	{
		MyPlayer.PlaySound(S, SLOT_None, 1.0, false);
		MyPlayer.PlaySound(S, SLOT_Talk, 1.0, false);
	}
}

simulated function	PlayerReplicationInfo	FindPRI(int PID)
{
	local	int	i;

	for (i=0; i<32; i++)
	{
		if (MyPlayer.GameReplicationInfo.PRIArray[i].PlayerID == PID)
			return MyPlayer.GameReplicationInfo.PRIArray[i];
	}
	return None;
}

simulated function	IgnoreSound(int PID)
{
	local	int		i, j;
	local	bool	b;
	local	PlayerReplicationInfo	PRI;

	if (PID == -2)
	{
		for (i=0; i<32; i++)
			Ignored[i] = 0xFFFFFFFF;
		MyPlayer.ClientMessage("Ignoring sounds from all players.");
		return;
	}

	if (PID == -3)
	{
		for (i=0; i<32; i++)
			Ignored[i] = 0;
		MyPlayer.ClientMessage("No longer ignoring all sounds.");
		return;
	}

	PRI = FindPRI(PID);
	if (PRI == None)
	{
		MyPlayer.ClientMessage("No player found with PlayerID "$PID);
		return;
	}

	i = PID/32;
	j = PID - i*32;

	b = (((Ignored[i] >> j) & 1) == 1);

	if (b)
	{
		Ignored[i] = Ignored[i] & (~(1<<j));
		MyPlayer.ClientMessage("No longer ignoring sounds from player "$PRI.PlayerName);
	} else {
		Ignored[i] = Ignored[i] | (1<<j);
		MyPlayer.ClientMessage("Ignoring sounds from player "$PRI.PlayerName);
	}
}

simulated function	bool IsIgnored(int PID)
{
	local	int		i, j;
	local	bool	b;

	if (PID > 0)
	{
		i = PID/32;
		j = PID - i*32;

		return (((Ignored[i] >> j) & 1) == 1);
	} else
		return False;
}

// - Demo/Admin Notification
simulated function	DrawDemoNotification(Canvas C)
{
	if (bDemo)
	{
		C.Style = ERenderStyle.STY_NORMAL;
		s_HUD(MyHUD).Design.SetScoreboardFont(C);
		C.DrawColor = s_HUD(MyHUD).Design.ColorRed;

		if (s_HUD(MyHUD).bHideHud || s_HUD(MyHUD).bHideStatus) {
			C.SetPos(C.ClipX - 49, C.ClipY-145+49);
		} else {
			C.SetPos(C.ClipX - 49, C.ClipY-145);
		}
		C.DrawText("REC", true);
	}
}

simulated function	DrawAdminNotification(Canvas C)
{
	local	string	S;
	local	float	CX, CY;

	if (MyPlayer.PlayerReplicationInfo.bAdmin || Master.SemiAdmin > 0)
	{
		C.Style = ERenderStyle.STY_NORMAL;
		s_HUD(MyHUD).Design.SetScoreboardFont(C);
		C.DrawColor.R = s_HUD(MyHUD).Design.ColorRed.R * AdminWarning;
		C.DrawColor.G = s_HUD(MyHUD).Design.ColorRed.G * AdminWarning;
		C.DrawColor.B = s_HUD(MyHUD).Design.ColorRed.B * AdminWarning;

		if (MyPlayer.PlayerReplicationInfo.bAdmin)
			S = "You are currently logged in as admin!";
		else
			S = "You are currently logged in as a level"@Master.SemiAdmin@"semiadmin!";

		C.StrLen(S, CX, CY);
		C.SetPos((C.ClipX-CX)/2, 5);
		C.DrawText(S, true);
	}
}

simulated function	DrawDebug(Canvas C)
{
/*
	local	float	XL, YL, Y;
	local	string	CurrentMessage;
	local	vector	v, w;

	C.Z = 1; // prevent screenflash

	C.Font = s_HUD(MyPlayer.myHUD).MyFonts.GetAReallySmallFont( C.ClipX );
	C.Style = ERenderStyle.STY_Translucent;
	C.DrawColor = s_HUD(MyPlayer.myHUD).Design.ColorSuperwhite;

	C.StrLen("test", XL, YL);
	Y = YL;
	YL += 8;

	CurrentMessage = "ScreenFlashes : "$bool(MyPlayer.ConsoleCommand("get windrv.windowsclient ScreenFlashes"));
	s_HUD(MyPlayer.myHUD).WriteDebugString(C, CurrentMessage, Y, true);
*/
}

// - Team HUD
simulated function	SwitchTeamInfo()
{
	TeamInfoStyle++;
	if (TeamInfoStyle == 3)
		TeamInfoStyle = 0;
	SaveConfig();
}

simulated function	CalculateTeamStats()
{
	local PlayerReplicationInfo PRI;

	TerrTeamCount = 0;
	TerrTeamAlive = 0;
	SwatTeamCount = 0;
	SwatTeamAlive = 0;
	HossieAlive = 0;
	HossieCount = 0;

	foreach AllActors(class'PlayerReplicationInfo', PRI)
	{
		if (PRI.Team == 0)
		{
			TerrTeamCount++;
			if (PRI.Owner != None && (PRI.Owner.isA('s_Player') || PRI.Owner.isA('s_Bot'))) {
				if (Pawn(PRI.Owner).Health > 0)
					TerrTeamAlive++;
			}
		} else {
			if (PRI.Team == 1) {
				SwatTeamCount++;
				if (PRI.Owner != None && (PRI.Owner.isA('s_Player')|| PRI.Owner.isA('s_Bot'))) {
					if (Pawn(PRI.Owner).Health > 0)
						SwatTeamAlive++;
				}
			} else {
				if (PRI.Team == 3) {// Hossie
					HossieCount++;
					if (PRI.Owner != none) {
						if (Pawn(PRI.Owner).Health > 0)
							HossieAlive++;
					}
				}
			}
		}
	}
}

simulated function	DrawTeamHUDCell(Canvas C, int YPos, int Value, int Team, bool Darken)
{
	if (s_HUD(MyHUD).bDrawBackground)
	{
		C.DrawColor = s_HUD(MyHUD).Design.ColorSuperWhite;
		C.Style = ERenderStyle.STY_Translucent;
		C.SetPos(C.ClipX-79, C.ClipY-YPos);
		C.DrawTile(Texture'hud_elements', 79, 18, 0, 52, 79.0, 18.0);
		C.Style = ERenderStyle.STY_Masked;
		C.SetPos(C.ClipX-79, C.ClipY-YPos);
		C.DrawTile(Texture'hud_elements', 79, 18, 0, 70, 79.0, 18.0);
	}

	s_HUD(MyHUD).TOHud_SetTeamColor(C, Team);
	C.SetPos(C.ClipX - 49, C.ClipY-YPos);
	if (Darken)
	{
		C.DrawColor.R = C.DrawColor.R * 0.4;
		C.DrawColor.G = C.DrawColor.G * 0.4;
		C.DrawColor.B = C.DrawColor.B * 0.4;
	}
	s_HUD(MyHUD).TOHud_Tool_DrawNum(C, Value, FS_SMALL, 2);
}

simulated function	DrawTOStyleTeamHUD(Canvas C)
{
	local int 	YOffset;

	// move down TeamInfo if StatusDisplay is turned off
	if (s_HUD(MyHUD).bHideHud || s_HUD(MyHUD).bHideStatus)
		YOffset = 49;
	else
		YOffset = 0;

	if (MyPlayer.GetStateName() != 'PreRound' && SWATTeamAlive > 0 && TerrTeamAlive > 0) {
		if (HossieAlive != 0)
			DrawTeamHUDCell(C, 121-YOffset, HossieAlive, 2, false);
		DrawTeamHUDCell(C, 97-YOffset, SwatTeamAlive, 1, false);
		DrawTeamHUDCell(C, 73-YOffset, TerrTeamAlive, 0, false);
	} else {
		if (HossieAlive != 0)
			DrawTeamHUDCell(C, 121-YOffset, HossieCount, 2, true);
		DrawTeamHUDCell(C, 97-YOffset, SwatTeamCount, 1, true);
		DrawTeamHUDCell(C, 73-YOffset, TerrTeamCount, 0, true);
	}
}

simulated function	DrawTextStyleTeamHUD(Canvas C)
{
	local int 	MyX, MyY;
	local float CX, CY;

	MyX = (C.ClipX - 60);
	MyY = (C.ClipY * 0.2);

	C.Style = ERenderStyle.STY_Normal;
	C.Font = MyHud.MyFonts.GetSmallFont(C.ClipX);
	C.TextSize("Hossie: ", CX, CY);

	s_HUD(MyHUD).TOHud_SetTeamColor(C,0);
	C.SetPos(7, MyY);
	C.DrawText("Terror: ");
	C.SetPos(7 + CX, MyY);
	C.DrawText(TerrTeamAlive$" ("$TerrTeamCount$")");

	s_HUD(MyHUD).TOHud_SetTeamColor(C,1);
	C.SetPos(7, MyY + 20);
	C.DrawText("S.F.: ");
	C.SetPos(7 + CX, MyY + 20);
	C.DrawText(SwatTeamAlive$" ("$SwatTeamCount$")");

	if (HossieAlive != 0)
	{
		s_HUD(MyHUD).TOHud_SetTeamColor(C,2);
	 	C.SetPos(7, MyY + 40);
	 	C.DrawText("Hossie: ");
	 	C.SetPos(7 + CX, MyY + 40);
	 	C.DrawText(HossieAlive$" ("$HossieCount$")");
	}
}

simulated function	DrawTeamHUD(Canvas C)
{
	switch (TeamInfoStyle)
	{
		case 1 : 	DrawTOStyleTeamHUD(C);
					break;
		case 2 :	DrawTextStyleTeamHUD(C);
					break;
		default : 	break;
	}
}

// - HUD status messages

// * DrawStatusTextBox - draw status messages
simulated function	DrawStatusTextBox(Canvas C)
{
	local	int		i, j;
	local	float	f;

	// return if GUI box open
	if (s_HUD(MyHUD).UserInterface.Visible())
		return;

//	C.Font = C.MedFont;
	C.Font = MyHUD.MyFonts.GetSmallestFont(C.ClipX);

	for(i=0; i<6; i++)
	{
		if(HUDMsg[i] == "")
			break;

		if(MsgTick - HUDMsgTime[i] <= MsgTotalTime * TextSpeed + Len(HUDMsg[i]))
		{
			f = (MsgTotalTime * TextSpeed + Len(HUDMsg[i]) - MsgTick + HUDMsgTime[i])/100;
			if (f > 1)
				f=1;

			C.DrawColor.R = 255*f;
			C.DrawColor.G = 255*f;
			C.DrawColor.B = (92+Rand(64))*f;

			C.SetPos(C.ClipX * 0.11, C.ClipY * (87 - i * 2) / 100);
			// drawing message
			if(MsgTick - HUDMsgTime[i] < Len(HUDMsg[i]))
			{
				DrawnText=Left(HUDMsg[i], MsgTick - HUDMsgTime[i]);
				for(j=1; j<=LettersFading; j++)
					DrawnText = DrawnText $ Chr(Asc(Mid(HUDMsg[i], MsgTick - HUDMsgTime[i] + LettersFading - j, 1)) - j);
				C.DrawText(DrawnText $ "_");
			}
			else
				C.DrawText(HUDMsg[i]);
		}
	}
}

// * AddStatusMessage - add message to the status text box (and console history)
simulated function AddStatusMessage(string Msg)
{
	local int i;

	// add to console history
	MyPlayer.Player.Console.AddString(Msg);

	// move old messages
	for(i=5; i>0; i--)
	{
		HUDMsg[i] = HUDMsg[i-1];
		HUDMsgTime[i] = HUDMsgTime[i-1];
	}
	HUDMsg[0] = Msg;
	// "beautify"
	if(TextSpeed * (MsgTick - HUDMsgTime[1]) < TimeBetweenMessages)
		HUDMsgTime[0] = HUDMsgTime[1] + TimeBetweenMessages * (1 / TextSpeed); //delay
	else
		HUDMsgTime[0] = MsgTick;
}

// - Weapon HUD

// * SwitchWeaponHud - change weapon HUD style
simulated function	SwitchWeaponHud(optional bool NoAdvance)
{
	if (!NoAdvance)
		WeaponHUDStyle++;
	if (WeaponHUDStyle > 5)
		WeaponHUDStyle = 0;
	if ((WeaponHUDStyle == 1) || (WeaponHUDStyle == 2))
	{
		TexturesPresent = LoadTextureSet("TOST4TexSolid");
		if (!TexturesPresent)
			MyPlayer.ClientMessage("Can't find texture file TOST4TexSolid.utx - Weapon HUD disabled");
	} else {
		if (WeaponHUDStyle == 3)
		{
			TexturesPresent = LoadTextureSet("TOST4TexTrans");
			if (!TexturesPresent)
				MyPlayer.ClientMessage("Can't find texture file TOST4TexTrans.utx - Weapon HUD disabled");
		}
	}
	SaveConfig();
}

// * InitTextures - load all non weapon textures
simulated function	InitTextures()
{
	DecoTex[0] = Texture'Frame';
	DecoTex[1] = Texture(DynamicLoadObject("Botpack.CHair8", class'Texture', true));
}

// * LoadTextureSet - load weapon textures from external package
simulated function	bool	LoadTextureSet(string Package)
{
	local	string	s;
	local	int		i, j;

	i = 0;
	s = TextureSetNames;
	while (s != "" && i < 27)
	{
		j = InStr(s, ";");
		if (j != -1)
		{
			WeaponTex[i] = Texture(DynamicLoadObject(Package$"."$Left(s, j), class'Texture', true));
			s = Mid(s, j+1);
		}
		else
		{
			WeaponTex[i] = Texture(DynamicLoadObject(Package$"."$s, class'Texture', true));
			s = "";
		}
		i++;
	}
	return (WeaponTex[0] != None);
}

// * GetWeaponTexuture - find matching texture for given Weapon
simulated function	Texture	GetWeaponTexture(Weapon Weapon)
{
	if (Weapon.isA('TOSTWeapon'))
	{
		if ((WeaponHUDStyle == 1) || (WeaponHUDStyle == 2))
			return TOSTWeapon(Weapon).SolidTex;
		if (WeaponHUDStyle == 3)
			return TOSTWeapon(Weapon).TransTex;
	}
	if (Weapon.isA('s_Knife')) 			return WeaponTex[0];
	if (Weapon.isA('TO_Berreta')) 		return WeaponTex[1];
	if (Weapon.isA('s_Glock'))    		return WeaponTex[2];
	if (Weapon.isA('s_DEagle'))   		return WeaponTex[3];
	if (Weapon.isA('TO_RagingBull')) 	return WeaponTex[4];
	if (Weapon.isA('s_GrenadeConc'))	return WeaponTex[5];
	if (Weapon.isA('s_GrenadeFB'))  	return WeaponTex[6];
	if (Weapon.isA('TO_GrenadeSmoke'))	return WeaponTex[7];
	if (Weapon.isA('TO_Grenade'))     	return WeaponTex[8];
	if (Weapon.isA('s_MAC10'))			return WeaponTex[9];
	if (Weapon.isA('s_MP5N'))     		return WeaponTex[10];
	if (Weapon.isA('TO_MP5KPDW')) 		return WeaponTex[11];
	if (Weapon.isA('s_M3'))				return WeaponTex[12];
	if (Weapon.isA('s_Mossberg'))		return WeaponTex[13];
	if (Weapon.isA('TO_Saiga'))  		return WeaponTex[14];
	if (Weapon.isA('s_Ak47'))			return WeaponTex[15];
	if (Weapon.isA('TO_M4A1'))			return WeaponTex[16];
	if (Weapon.isA('TO_HKSMG2'))		return WeaponTex[17];
	if (Weapon.isA('TO_SteyrAug'))		return WeaponTex[18];
	if (Weapon.isA('TO_HK33'))    		return WeaponTex[19];
	if (Weapon.isA('s_P85'))			return WeaponTex[20];
	if (Weapon.isA('s_PSG1'))			return WeaponTex[21];
	if (Weapon.isA('TO_M4m203'))		return WeaponTex[22];
	if (Weapon.isA('TO_M16')) 			return WeaponTex[23];
	if (Weapon.isA('TO_M60')) 			return WeaponTex[24];
	if (Weapon.isA('s_OICW'))   		return WeaponTex[25];
	if (Weapon.isA('TO_Binocs'))		return WeaponTex[26];
	return	None;
}

// * WeaponCount - count number of weapons (groups)
simulated function int		WeaponCount()
{
	local Inventory Inv;
	local int i, j;

	for (Inv = MyPlayer.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		if (Inv.IsA('s_Weapon') && !Inv.isA('s_C4') && !Inv.isA('TO_Binocs'))
			i++;
		j++;
		if (j > 25)
			break;
	}
	return i;
}

// * GetWeaponAmmunition - get percentage of ammo left in weapon
simulated function float 	GetWeaponAmmunition(Weapon Weapon)
{
	local int max, cur;

	// Nade/Knife fix
	if (Weapon.isA('TO_Grenade') || Weapon.isA('s_Knife') || Weapon.isA('TOSTGrenade') || Weapon.isA('TOST_Knife') ||Weapon.isA('TO_Binocs')) {
		return 1;
	} else {
		max = (s_Weapon(Weapon).MaxClip+1) * s_Weapon(Weapon).ClipSize;
		cur = s_Weapon(Weapon).RemainingClip * s_Weapon(Weapon).ClipSize + s_Weapon(Weapon).ClipAmmo;
		return float(cur)/float(max);
	}
}

// * GetClipAmmunition - get percentage of ammo left in clip
simulated function float	GetClipAmmunition(Weapon Weapon)
{
	local int max, cur;

	// Nade/Knife fix
	if (Weapon.isA('TO_Grenade') || Weapon.isA('s_Knife') || Weapon.isA('TOSTGrenade') || Weapon.isA('TOST_Knife') ||Weapon.isA('TO_Binocs')) {
		return 1;
	} else {
		max = s_Weapon(Weapon).ClipSize;
		cur = s_Weapon(Weapon).ClipAmmo;
		return float(cur)/float(max);
	}
}

// * GetWeaponByGroup - get weapon of the given inventory group
simulated function Weapon 	GetWeaponByGroup(int InventoryGroup)
{
	local Inventory Inv;
	local Weapon 	w;
	local int 		Count;

	if (MyPlayer == None)
		return None;

	// Binocs special handling
	if (InventoryGroup == 1 && MyPlayer.Weapon != None && MyPlayer.Weapon.isA('TO_Binocs'))
	{
		return MyPlayer.Weapon;
	}
	for (Inv = MyPlayer.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		w = Weapon(Inv);
		if (w != None) {
			// OICW special handling
			if (w.InventoryGroup == InventoryGroup && !w.IsA('s_OICW') && !w.IsA('TO_Binocs'))
			{
				return w;
			}
			if (InventoryGroup == 6 && w.IsA('s_OICW'))
			{
				return w;
			}
		}
		Count++;
		if (Count > 25) //avoid endless loop for circle in inventory list...
			break;
	}
	return None;
}

simulated function	bool	HasOICW()
{
	return (MyPlayer.FindInventoryType(class's_OICW') != none);
}

simulated function	DrawWeaponHUDSolid(Canvas C)
{
	local float 	MyX, MyY, MyScale;
	local int 		i, j, InvGroup, CurrWeapClass;
	local Weapon 	Weapon;
	local texture 	Tex;
	local bool 		OICW, Reload, AltStyle;

	AltStyle = (WeaponHUDStyle == 2);

	if (MyHUD == none || s_HUD(MyHUD) == none || MyPlayer == none)
		return;

	MyScale = MyHUD.Scale;
	C.Style = ERenderStyle.STY_Masked;

	if (s_HUD(MyHUD).bDrawHint && (s_HUD(MyHUD).Hint[0] != "" || s_HUD(MyHUD).FrameHint[0] < 8 || s_HUD(MyHUD).FrameHint[1] < 8 || s_HUD(MyHUD).Hint[1] != "")) {
		MyY = C.ClipY * 0.900;
	} else {
		MyY = C.ClipY * 0.935;
	}
	OICW = HasOICW();
	InvGroup = 7;

	// Get Current WeaponClass
	if (AltStyle)
	{
		for(i=1; i<7; i++)
		{
			if (MyPlayer.Weapon == GetWeaponByGroup(i))
				CurrWeapClass = i;
		}
	}

	// Render Weaponinventory
	for(i=6; i>0; i--)
	{
		if (i == 6 && !OICW)
		{
			i = 5;
			InvGroup--;
		}

		if (AltStyle)
		{
			InvGroup--;
			if(i==3)
			{
				Weapon = GetWeaponByGroup(CurrWeapClass);
				InvGroup++;
			} else {
				Weapon = GetWeaponByGroup(InvGroup);
			}

			if (Weapon == MyPlayer.Weapon && i != 3)
			{
				InvGroup--;
				Weapon = GetWeaponByGroup(InvGroup);
			}

		} else {
			Weapon = GetWeaponByGroup(i);
		}

		// how many weapons to draw total
		if (OICW) {
			if (AltStyle && i > 3)
				MyX = (C.ClipX - 6*128*MyScale)/2+130*MyScale*1.5+130*MyScale*(i-2);
			else
				MyX = (C.ClipX - 6*128*MyScale)/2+130*MyScale*(i-1);
		} else {
			if (AltStyle && i > 3)
				MyX = (C.ClipX - 5*128*MyScale)/2+130*MyScale*1.5+130*MyScale*(i-2);
			else
				MyX = (C.ClipX - 5*128*MyScale)/2+130*MyScale*(i-1);
		}

		if (Weapon != none && s_Weapon(Weapon) != none)
		{
			// Render Weapon
			C.DrawColor.R = 255;
			C.DrawColor.G = 255;
			C.DrawColor.B = 255;

			Tex = GetWeaponTexture(Weapon);
			if (AltStyle && i == 3)
			{
				C.SetPos(MyX, MyY-64*MyScale*0.5);
				C.DrawIcon(Tex, MyScale*1.5/2);
			} else {
				C.SetPos(MyX, MyY);
				C.DrawIcon(Tex, MyScale/2);
			}

			// Set Framecolor
			if (MyPlayer.Weapon == Weapon)
			{
				if (s_Weapon(Weapon).bReloadingWeapon)
				{
					// Frame Blue
					C.DrawColor.R = 0;
					C.DrawColor.G = 0;
					C.DrawColor.B = 255;
				} else {
					// Frame Green
					s_HUD(MyHUD).TOHud_SetTeamColor(C,2);
				}
			} else {
				if (s_Weapon(Weapon).RemainingClip == 0 && (s_Weapon(Weapon).ClipAmmo*100/s_Weapon(Weapon).ClipSize)<60 &&
					!Weapon.isA('TO_Grenade') && !Weapon.isA('s_Knife') && !Weapon.isA('TO_Binocs') && Weapon != none &&
					!Weapon.isA('TOST_Grenade') && !Weapon.isA('TOST_Knife'))
				{
					// Frame Red
					C.DrawColor.R = 255;
					C.DrawColor.G = 0;
					C.DrawColor.B = 0;
				} else {
					// Frame White
					C.DrawColor.R = 255;
					C.DrawColor.G = 255;
					C.DrawColor.B = 255;
				}
			}
		} else {
			// no weapon -> Frame White
			C.DrawColor.R = 255;
			C.DrawColor.G = 255;
			C.DrawColor.B = 255;
		}

		// Render Frame
		if (AltStyle && i==3)
		{
			C.SetPos(MyX, MyY-58*MyScale*0.5);
			C.DrawIcon(DecoTex[0], MyScale*1.5);

			MyX = MyX + 110 * MyScale * 1.5;
		} else {
			C.SetPos(MyX, MyY);
			C.DrawIcon(DecoTex[0], MyScale);

			MyX = MyX + 104 * MyScale;
		}
		// Render WeaponStats
		if(Weapon != none && !Weapon.isA('TO_Grenade') && !Weapon.isA('s_Knife') && !Weapon.isA('TOST_Grenade') && !Weapon.isA('TOST_Knife') && !Weapon.isA('TO_Binocs'))
		{
			s_HUD(MyHUD).Design.SetSmallFont(C);
			C.SetPos(MyX, MyY+21*MyScale);
			C.DrawText(s_Weapon(Weapon).RemainingClip);
			C.SetPos(MyX, MyY+36*MyScale);
			C.DrawText(s_Weapon(Weapon).ClipAmmo);
		}
	}
}

simulated function	DrawWeaponHUDTrans(Canvas C)
{
	local float 	MyX, MyY, MyScale, CC, CD;
	local int 		i, j, CB, InvGroup;
	local Weapon	Weapon;
	local texture 	Tex;
	local bool 		Reload;

	if (MyHUD == none || s_HUD(MyHUD) == none || MyPlayer == none)
		return;

	MyScale = MyHUD.Scale;
	C.Style = ERenderStyle.STY_Masked;

	if(s_HUD(MyHUD).bDrawHint && (s_HUD(MyHUD).Hint[0] != "" || s_HUD(MyHUD).FrameHint[0] < 8 || s_HUD(MyHUD).FrameHint[1] < 8 || s_HUD(MyHUD).Hint[1] != "")) {
		MyY = C.ClipY * 0.900 - 10;
	} else {
		MyY = C.ClipY * 0.935 - 10;
	}

	i = WeaponCount();
	j = 0;
	InvGroup = 1;
	do {
		Weapon = GetWeaponByGroup(InvGroup);
		if (Weapon != none && s_Weapon(Weapon) != none)
		{
			MyX = (200*MyScale) + ((C.ClipX - (512*MyScale)) / (i-1)) * j;
			j++;
			Tex = GetWeaponTexture(Weapon);
			C.Style = ERenderStyle.STY_Translucent;

			CC = GetWeaponAmmunition(Weapon);
			CD = 1.0-CC;

			if (MyPlayer.Weapon == Weapon) {
				CB = 255;
				Reload = s_Weapon(Weapon).bReloadingWeapon;
			} else {
				CB = 127;
				Reload = false;
			}

			//Concussion
			if (Weapon.isA('s_GrenadeConc') || Weapon.isA('TOST_GrenadeConc')) {
				CC = 0;
				CD = 1.0;
			}
			C.DrawColor.R = CB * CD;
			C.DrawColor.G = CB * CC;
			C.DrawColor.B = 0;

			//Smoke Fix
			if (Weapon.isA('TO_GrenadeSmoke') || Weapon.isA('TOST_GrenadeSmoke')) {
				C.DrawColor.R = 0;
				C.DrawColor.G = 0;
				C.DrawColor.B = CB;
			}
			C.SetPos(MyX, MyY);
			C.DrawIcon(Tex, MyScale / (Tex.USize / 128));
			if(!Weapon.isA('TO_Grenade') && !Weapon.isA('s_Knife') && !Weapon.isA('TOST_Grenade') && !Weapon.isA('TOST_Knife') && !Weapon.isA('TO_Binocs')) {
				if (!Reload) {
					CC = GetClipAmmunition(Weapon);
					CD = 1.0-CC;
					C.DrawColor.R = CB * CD;
					C.DrawColor.G = CB * CC;
					C.DrawColor.B = 0;
				} else {
					C.DrawColor.R = 0;
					C.DrawColor.G = 0;
					C.DrawColor.B = 255;
				}
				C.SetPos(MyX + (MyScale*128) - 96, MyY - 96);
				C.bNoSmooth = False;
				C.DrawIcon(DecoTex[1], 3.0);
			}
			C.Style = ERenderStyle.STY_Normal;
		}
		InvGroup++;
	} until (j>=i || InvGroup > 10)
}

simulated function	DrawWeaponHUDText(Canvas C)
{
	local float 	MyScale, DeltaX, DeltaY;
	local Weapon 	Weapon;

	Weapon = MyPlayer.Weapon;
	MyScale = MyHUD.Scale;
	C.Style = ERenderStyle.STY_Normal;
	C.Font = MyHUD.MyFonts.GetSmallFont(C.ClipX);
	s_HUD(MyHUD).TOHud_SetTeamColor(C, 2);
	C.TextSize("Weapon: ", DeltaX, DeltaY);

	if(WeaponHUDStyle == 4)
	{
		C.SetPos(5, 5);
		C.DrawText("Weapon: ");
		C.SetPos(5+DeltaX, 5);
		C.DrawText(Weapon.ItemName);
	} else {
		C.SetPos(C.ClipX/2+20*MyScale, C.ClipY/2+20*MyScale);
		C.DrawText("Weapon: ");
		C.SetPos(C.ClipX/2+DeltaX+20*MyScale, C.ClipY/2+20*MyScale);
		C.DrawText(Weapon.ItemName);
	}
}

// * DrawWeaponHUD - render Weapon HUD
simulated function DrawWeaponHUD(Canvas C)
{
	// no Weapon HUD or player dead - don't render
	if (WeaponHUDStyle == 0 || MyPlayer.Health < 0)
		return;

	// return if GUI box open
	if (s_HUD(MyHUD).UserInterface.Visible())
		return;

	if ((WeaponHUDStyle == 1) || (WeaponHUDStyle == 2)) {
		if (TexturesPresent)
			DrawWeaponHUDSolid(C);
	} else {
		if (WeaponHUDStyle == 3) {
			if (TexturesPresent)
				DrawWeaponHUDTrans(C);
		} else {
			DrawWeaponHUDText(C);
		}
	}
}

simulated function  ShowTime()
{
    bShowTime = true;
}

// a completely useless function by Stark :-)
simulated function	DrawTime(Canvas C)
{
    local float XL, YL;
    local string mydate, mytime;

	if (bShowTime)
	{
        if (TimeDisplayEnd == -1)
            TimeDisplayEnd = (Level.Second+6)%60;
        if (TimeDisplayEnd <= Level.Second)
            bShowTime = false;
        C.Font = s_HUD(MyPlayer.myHUD).MyFonts.GetHugeFont( C.ClipX );
    	C.Style = ERenderStyle.STY_Translucent;
    	C.DrawColor = s_HUD(MyPlayer.myHUD).Design.ColorSuperwhite;

        if (!s_HUD(MyPlayer.MyHUD).UserInterface.Visible())
        {
    	    mydate = GetDayOfWeek(Level.DayOfWeek)$", "$PadTime(Level.Day)$"."$PadTime(Level.Month)$"."$PadTime(Level.Year);
            mytime = PadTime(Level.Hour)$":"$PadTime(Level.Minute)$":"$PadTime(Level.Second);

            C.StrLen(mydate, XL, YL);
            C.setpos((C.ClipX-XL)/2, YL);
            C.DrawText(mydate);

            C.StrLen(mytime, XL, YL);
            C.setpos((C.ClipX-XL)/2, 2.5*YL);
            C.DrawText(mytime);
        }

    } else TimeDisplayEnd = -1;
}

// * DrawCameraInMenu - Draw list of camera's in the score screen
function DrawCameraInScoreScreen(Canvas C)
{
	local int Terr, SF, i, Y, start, MyY, ULineHeight, LLineHeight;

	if (s_HUD(MyHUD).UserInterface.CurrentTab == 10 && TOSTHUDExtComm(Comm).RecordingList != ";" && (TOSTHUDExtComm(Comm).CWMode || PlayerPawn(Owner).PlayerReplicationInfo.bAdmin))
	{
		// Draw camera in TO340 score screen
		if ( C.ClipY >= 600 )
		{
			C.DrawColor=s_HUD(MyHUD).UserInterface.Design.ColorWhite;
			s_HUD(MyHUD).UserInterface.Design.SetScoreboardFont(C);
			ULineHeight=s_HUD(MyHUD).UserInterface.Design.LineHeight;
			s_HUD(MyHUD).UserInterface.Design.SetTinyFont(C);
			LLineHeight=s_HUD(MyHUD).UserInterface.Design.LineHeight;

			myY=TO_GUITabScores(s_HUD(MyHUD).UserInterface.GetCurrentTab()).Top + TO_GUITabScores(s_HUD(MyHUD).UserInterface.GetCurrentTab()).padding[TO_GUITabScores(s_HUD(MyHUD).UserInterface.GetCurrentTab()).resolution]*3 + 20;

			if ( TO_GUITabScores(s_HUD(MyHUD).UserInterface.GetCurrentTab()).Scroll )
				Start=(TO_GUITabScores(s_HUD(MyHUD).UserInterface.GetCurrentTab()).Top + TO_GUITabScores(s_HUD(MyHUD).UserInterface.GetCurrentTab()).Height - MyY) / (s_HUD(MyHUD).UserInterface.Design.LineHeight*2 + 2);
			else Start=0;

			Terr=-start;
			SF=-start;

			for ( i=0;i<TO_GUITabScores(s_HUD(MyHUD).UserInterface.GetCurrentTab()).PlayerCount;i++ )
			{
				if ( TO_GUITabScores(s_HUD(MyHUD).UserInterface.GetCurrentTab()).PlayerList[i].team == 0 )
				{
					Y = Terr++ * (LLineHeight + ULineHeight + 2) + MyY;
					if ( bIsRecording(TO_GUITabScores(s_HUD(MyHUD).UserInterface.GetCurrentTab()).PlayerList[i]) )
					{
						C.SetPos(TO_GUITabScores(s_HUD(MyHUD).UserInterface.GetCurrentTab()).Left-29,Y );
						C.DrawTile(texture'DemoIndicator',23,13,3,8,23,13);
					}
				}
				else if ( TO_GUITabScores(s_HUD(MyHUD).UserInterface.GetCurrentTab()).PlayerList[i].team == 1 )
				{
					Y = SF++ * (LLineHeight + ULineHeight + 2) + MyY;
					if ( bIsRecording(TO_GUITabScores(s_HUD(MyHUD).UserInterface.GetCurrentTab()).PlayerList[i]) )
					{
						C.SetPos(TO_GUITabScores(s_HUD(MyHUD).UserInterface.GetCurrentTab()).Left+6 + s_HUD(MyHUD).UserInterface.Design.GetGoodWidth(c.ClipX,c.ClipY) - 240 ,Y);
						C.DrawTile(texture'DemoIndicator',23,13,3,8,23,13);
					}
				}
			}
		}
		// Draw camera in old menu for low res players
		else
		{
			C.DrawColor=s_HUD(MyHUD).UserInterface.Design.ColorWhite;
			Y=TO_GUITabScores(s_HUD(MyHUD).UserInterface.GetCurrentTab()).Top + TO_GUITabScores(s_HUD(MyHUD).UserInterface.GetCurrentTab()).SpaceTitle[TO_GUITabScores(s_HUD(MyHUD).UserInterface.GetCurrentTab()).Resolution];
			s_HUD(MyHUD).UserInterface.Design.SetScoreboardFont(C);
			TO_GUITabScores(s_HUD(MyHUD).UserInterface.GetCurrentTab()).TOScoreboard_Tool_UpdatePlayerlist();

			for ( i=0;i<TO_GUITabScores(s_HUD(MyHUD).UserInterface.GetCurrentTab()).PlayerCount;i++ )
			{
				Y += s_HUD(MyHUD).UserInterface.Design.LineHeight;
				if ( bIsRecording(TO_GUITabScores(s_HUD(MyHUD).UserInterface.GetCurrentTab()).PlayerList[i]) )
				{
					c.SetPos(TO_GUITabScores(s_HUD(MyHUD).UserInterface.GetCurrentTab()).Left-19 , Y);
					C.DrawTile(texture'DemoIndicator',16,16,3,8,23,13);
				}
			}
		}
	}
}

// * bIsRecording - look 4 playerID in the string: RecordingID
function bool bIsRecording(PlayerReplicationInfo PRI)
{
	if ( !PRI.bIsABot && InStr(TOSTHUDExtComm(Comm).RecordingList,";"$string(PRI.PlayerID)$";") != -1)
		return true;

	return false;
}

simulated function string PadTime(int i)
{
    if (i>=10)
        return string(i);
    else return "0"$i;
}

simulated function string GetDayOfWeek(int i)
{
    switch (i)
    {
        case 0: return "Sun";
        case 1: return "Mon";
        case 2: return "Tue";
        case 3: return "Wed";
        case 4: return "Thu";
        case 5: return "Fri";
        case 6: return "Sat";
    }
}

defaultproperties
{
	CommClass=class'TOSTHUDExtComm'

	// Weapon HUD
	TextureSetNames="Knife;Beretta;GL23;DEagle;Bull;Concussion;Flash;Smoke;HE;Mac10;MP5A2;MP5SD;SPAS12;Mossberg;Saiga;Ak47;M4A1;SMG2;Sig551;HK33;PH85;MSG90;M4m203;M16;M60;OICW;BINOC"

	// HUD status messages
	MsgTick=1
	MsgTotalTime=15
	TextSpeed=50
	LettersFading=5
	TimeBetweenMessages=0.5

	AllowedSoundLength=5.0
	AllowedSoundClass=255

	LogConsole=False
}

