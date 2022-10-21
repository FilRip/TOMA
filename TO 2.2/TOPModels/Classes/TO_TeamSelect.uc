//=============================================================================
// TO_TeamSelect
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
// Tactical Ops v2.0 menu code & GFX by j3rky
// - (Shag) Various enhancements. Including model selection, credits scrolling, disconnect, and random selection..
//=============================================================================

class TO_TeamSelect expands UWindowDialogClientWindow;


#exec TEXTURE IMPORT NAME=bg_bdr_bl	FILE=Textures\Startmenu\bg_bdr_bl-0.BMP GROUP="StartMenu"	MIPS=OFF
#exec TEXTURE IMPORT NAME=bg_bdr_br	FILE=Textures\Startmenu\bg_bdr_br-0.BMP GROUP="StartMenu"	MIPS=OFF
#exec TEXTURE IMPORT NAME=bg_bdr_h	FILE=Textures\Startmenu\bg_bdr_h-0.BMP  GROUP="StartMenu"	MIPS=OFF
#exec TEXTURE IMPORT NAME=bg_bdr_tl	FILE=Textures\Startmenu\bg_bdr_tl-0.BMP GROUP="StartMenu"	MIPS=OFF
#exec TEXTURE IMPORT NAME=bg_bdr_tr	FILE=Textures\Startmenu\bg_bdr_tr-0.BMP GROUP="StartMenu"	MIPS=OFF
#exec TEXTURE IMPORT NAME=bg_bdr_v	FILE=Textures\Startmenu\bg_bdr_v-0.BMP  GROUP="StartMenu"	MIPS=OFF
#exec TEXTURE IMPORT NAME=bg_black	FILE=Textures\Startmenu\bg_black-0.BMP  GROUP="StartMenu"	MIPS=OFF
#exec TEXTURE IMPORT NAME=bg_cnt		FILE=Textures\Startmenu\bg_cnt-0.BMP    GROUP="StartMenu"	MIPS=OFF
#exec TEXTURE IMPORT NAME=bg_dot_bl	FILE=Textures\Startmenu\bg_dot_bl-0.BMP   GROUP="StartMenu"	MIPS=OFF
#exec TEXTURE IMPORT NAME=bg_dot_h	FILE=Textures\Startmenu\bg_dot_h-0.BMP    GROUP="StartMenu"	MIPS=OFF
#exec TEXTURE IMPORT NAME=bg_dot_tr	FILE=Textures\Startmenu\bg_dot_tr-0.BMP   GROUP="StartMenu"	MIPS=OFF
#exec TEXTURE IMPORT NAME=bg_dot_v	FILE=Textures\Startmenu\bg_dot_v-0.BMP    GROUP="StartMenu"	MIPS=OFF
#exec TEXTURE IMPORT NAME=bg_logo_tacops20	FILE=Textures\Startmenu\bg_logo_tacops20-0.BMP  GROUP="StartMenu"	MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=btn_back_sel			FILE=Textures\Startmenu\btn_back_sel-0.BMP      GROUP="StartMenu"	MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=btn_back					FILE=Textures\Startmenu\btn_back-0.BMP          GROUP="StartMenu"	MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=btn_exitgame_sel	FILE=Textures\Startmenu\btn_exitgame_sel-0.BMP  GROUP="StartMenu"	MIPS=OFF 
#exec TEXTURE IMPORT NAME=btn_exitgame			FILE=Textures\Startmenu\btn_exitgame-0.BMP      GROUP="StartMenu"	MIPS=OFF 
#exec TEXTURE IMPORT NAME=btn_joinsf_sel		FILE=Textures\Startmenu\btn_joinsf_sel-0.BMP    GROUP="StartMenu"	MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=btn_joinsf				FILE=Textures\Startmenu\btn_joinsf-0.BMP        GROUP="StartMenu"	MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=btn_jointr_sel		FILE=Textures\Startmenu\btn_jointr_sel-0.BMP    GROUP="StartMenu"	MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=btn_jointr				FILE=Textures\Startmenu\btn_jointr-0.BMP        GROUP="StartMenu"	MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=btn_quit_sel	FILE=Textures\Startmenu\btn_quit_sel-0.BMP      GROUP="StartMenu"	MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=btn_quit			FILE=Textures\Startmenu\btn_quit-0.BMP          GROUP="StartMenu"	MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=btn_swat_sel	FILE=Textures\Startmenu\btn_swat_sel-0.BMP      GROUP="StartMenu"	MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=btn_swat			FILE=Textures\Startmenu\btn_swat-0.BMP          GROUP="StartMenu"	MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=btn_terr_sel	FILE=Textures\Startmenu\btn_terr_sel-0.BMP      GROUP="StartMenu"	MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=btn_terr			FILE=Textures\Startmenu\btn_terr-0.BMP          GROUP="StartMenu"	MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=Tile_Black		FILE=Textures\Startmenu\Tile_Black-0.BMP        GROUP="StartMenu"	MIPS=OFF

#exec TEXTURE IMPORT NAME=btn_rndteam					FILE=Textures\Startmenu\btn_rndteam-0.BMP					GROUP="StartMenu"	MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=btn_rndteam_sel			FILE=Textures\Startmenu\btn_rndteam_sel-0.BMP     GROUP="StartMenu"	MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=btn_disconnect			FILE=Textures\Startmenu\btn_disconnect-0.BMP			GROUP="StartMenu"	MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=btn_disconnect_sel	FILE=Textures\Startmenu\btn_disconnect_sel-0.BMP  GROUP="StartMenu"	MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=btn_prev						FILE=Textures\Startmenu\btn_prev-0.BMP						GROUP="StartMenu"	MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=btn_prev_sel				FILE=Textures\Startmenu\btn_prev_sel-0.BMP        GROUP="StartMenu"	MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=btn_next						FILE=Textures\Startmenu\btn_next-0.BMP						GROUP="StartMenu"	MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=btn_next_sel				FILE=Textures\Startmenu\btn_next_sel-0.BMP        GROUP="StartMenu"	MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=btn_enter						FILE=Textures\Startmenu\btn_enter-0.BMP						GROUP="StartMenu"	MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=btn_enter_sel				FILE=Textures\Startmenu\btn_enter_sel-0.BMP				GROUP="StartMenu"	MIPS=OFF FLAGS=2


/*
========================
  enums
========================
*/

enum EMenuItem
{
	MI_SERVER,
	MI_TEAM,
	MI_SKIN,
	MI_CREDITS
};

/*
========================
  properties
========================
*/

var TO_MenuButton		BtnExitGame, BtnPrev, BtnNext, BtnEnter;
var TO_MenuButton		BtnServerQt, BtnServerDisconnect, BtnMiscBack;
var TO_MenuButton		BtnServerSF, BtnServerTR, BtnRndTeam;
var TO_MenuButton		BtnTeamJnSF, BtnTeamJnTR;
var	color						WhiteColor, BlueColor, DarkBlueColor, RedColor, DarkRedColor;

var	EMenuItem		menuItem, menuNext;
var int					menuFadingFrame, menuFadingSpeed;
var int					menuTeam, menuSkin;
var	bool				bRandomTeam;

var float				xo, yo;
var float				xm, ym;
var float				we, he;
var	float				Scale;

var	string								ModelHandlerClass;
var	class<TO_ModelHandler>	ModelHandler;
var	TO_MeshActor					MeshActor;
var rotator								CenterRotator, ViewRotator;

var	TO_Credits						Credits;

 
/*
========================
  methods
========================
*/

////////////////////
//  engine
////////////////////

function Created()
{
	local	int							i;

	Super.Created();

	if ( Root.Console.bShowConsole )
		Root.Console.HideConsole();

	// Align Window and Hide the Menu/Status Bars	
//	TO_RootWindow(Root).MenuBar.HideWindow();
//	TO_RootWindow(Root).StatusBar.HideWindow();

	// coords
	WinLeft = 0;
	WinTop = 0;

	xo = WinWidth / 2;
	yo = WinHeight / 2;

	xm = xo-24;
	ym = yo-192;

	// buttons
	BtnExitGame = AddButton(xo-216, yo+192, 128, 16, texture'btn_exitgame', texture'btn_exitgame_sel', texture'btn_exitgame', true);
	BtnMiscBack = AddButton(xo-280, yo+120, 256, 32, texture'btn_back', texture'btn_back_sel', texture'btn_back', true);

	BtnServerQt = AddButton(xo-280, yo+24, 256, 32, texture'btn_quit', texture'btn_quit_sel', texture'btn_quit', true);
	BtnServerDisconnect = AddButton(xo-280, yo+72, 256, 32, texture'btn_disconnect', texture'btn_disconnect_sel', texture'btn_disconnect', true);

	BtnServerSF = AddButton(xo-280, yo+24, 256, 32, texture'btn_swat', texture'btn_swat_sel', texture'btn_swat', true);
	BtnServerTR = AddButton(xo-280, yo+72, 256, 32, texture'btn_terr', texture'btn_terr_sel', texture'btn_terr', true);
	BtnRndTeam = AddButton(xo-280, yo+120, 256, 32, texture'btn_rndteam', texture'btn_rndteam_sel', texture'btn_rndteam', true);
		
	BtnPrev = AddButton(xo-280, yo+24, 128, 32, texture'btn_prev', texture'btn_prev_sel', texture'btn_prev', true);
	BtnNext = AddButton(xo-152, yo+24, 128, 32, texture'btn_next', texture'btn_next_sel', texture'btn_next', true);
	BtnEnter = AddButton(xo-280, yo+72, 280, 32, texture'btn_enter', texture'btn_enter_sel', texture'btn_enter', true);

	BtnTeamJnSF = AddButton(xo-280, yo+48, 256, 32, texture'btn_joinsf', texture'btn_joinsf_sel', texture'btn_joinsf', true);
	BtnTeamJnTR = AddButton(xo-280, yo+48, 256, 32, texture'btn_jointr', texture'btn_jointr_sel', texture'btn_jointr', true);

	TOTeamsel_Btn_HideAll();
	BtnExitGame.Show();

	// init menu
	menuItem = MI_SERVER;
	menuFadingFrame = 0;
	menuFadingSpeed = 8;
	bLeaveOnScreen = true;

	Root.bAllowConsole = false;
	//TO_Console(Root.Console).bTeamMenu = true;
}



function BeforePaint(Canvas C, float X, float Y)
{
	xo = WinWidth / 2;
	yo = WinHeight / 2;

	we = (WinWidth-640) / 2;
	he = (WinHeight-480) / 2;
}



function Paint(Canvas C, float X, float Y)
{
	local	int		i;
	local	string version;
	local	float	xl, yl;

	if ( GetPlayerOwner() == None )
		Close();

	Scale = 1024 / C.ClipX;

	// Black background
	C.bNoSmooth = false;
	DrawStretchedTexture(C, 0, 0, WinWidth, he+32, Texture'bg_black');
	DrawStretchedTexture(C, 0, yo+208, WinWidth, he+32, Texture'bg_black');
	DrawStretchedTexture(C, xo-264, yo-208, 224, 208, Texture'bg_black');		// top box
	DrawStretchedTexture(C, xo-264, yo+176, 224, 32, Texture'bg_black');		// bottom box

	// bg lines
	C.bNoSmooth = true;
	if (WinWidth > 640)
	{
		DrawStretchedTexture(C, 0, yo+208, WinWidth, 8, Texture'bg_bdr_h');
		DrawStretchedTexture(C, 0, yo-224, WinWidth, 8, Texture'bg_bdr_h');
	}
	if (WinHeight > 480)
	{
		DrawStretchedTexture(C, xo-256, 0, 8, he, Texture'bg_bdr_v');		// top
		DrawStretchedTexture(C, xo-48, 0, 8, he, Texture'bg_bdr_v');
		DrawStretchedTexture(C, xo-256, yo+240, 8, he, Texture'bg_bdr_v');		// bottom
		DrawStretchedTexture(C, xo-48, yo+240, 8, he, Texture'bg_bdr_v');

	}

	// bg dots (lines)
	for (i = 0; i < 80; i++)
	{
		DrawStretchedTexture(C, xo-320 + 8*i, yo-224, 8, 8, Texture'bg_dot_h');	// top
		DrawStretchedTexture(C, xo-320 + 8*i, yo+208, 8, 8, Texture'bg_dot_h');	// bottom
	}

	// bg dots (top/bottom box)
	for (i = 0; i < 26; i++)
	{
		DrawStretchedTexture(C, xo-256 + 8*i, yo-16, 8, 8, Texture'bg_dot_h');	// top box
		DrawStretchedTexture(C, xo-256 + 8*i, yo+176, 8, 8, Texture'bg_dot_h');	// bottom box
	}
	for (i = 0; i < 29; i++)
	{
		DrawStretchedTexture(C, xo-256, yo-240 + 8*i, 8, 8, Texture'bg_dot_v');	// top box
		DrawStretchedTexture(C, xo-48, yo-240 + 8*i, 8, 8, Texture'bg_dot_v');
	}
	for (i = 0; i < 7; i++)
	{
		DrawStretchedTexture(C, xo-256, yo+184 + 8*i, 8, 8, Texture'bg_dot_v');	// bottom box
		DrawStretchedTexture(C, xo-48, yo+184 + 8*i, 8, 8, Texture'bg_dot_v');
	}

	// bg dots (corners)
	DrawStretchedTexture(C, xo-256, yo-224, 8, 8, Texture'bg_dot_bl');		// top box
	DrawStretchedTexture(C, xo-256, yo-16, 8, 8, Texture'bg_dot_bl');	
	DrawStretchedTexture(C, xo-48, yo-224, 8, 8, Texture'bg_dot_bl');	
	DrawStretchedTexture(C, xo-256, yo+208, 8, 8, Texture'bg_dot_bl');		// bottom box
	DrawStretchedTexture(C, xo-48, yo+208, 8, 8, Texture'bg_dot_bl');	
	DrawStretchedTexture(C, xo-48, yo+176, 8, 8, Texture'bg_dot_tr');

	C.bNoSmooth = false;
	// logo
	version = class'TOSystem.TO_MenuBar'.default.TOVersionText;
	C.Font = Font(DynamicLoadObject("LadderFonts.UTLadder20", class'Font'));
	C.StrLen(version, xl, yl);
	C.DrawColor = WhiteColor;
	C.SetPos(xo-152-xl/2, yo-227-yl/2);
	//C.SetPos(xo+108-xl/2, ym);
	C.DrawText(version, false);
	//DrawStretchedTexture(C, xo-280, yo-235, 256, 16, Texture'bg_logo_tacops20');
	
	// level screenshot
	if ( (GetPlayerOwner() != none) && (GetPlayerOwner().Level.Screenshot != None) )
		DrawStretchedTexture(C, xo-248, yo-208, 192, 192, GetPlayerOwner().Level.Screenshot);

	C.bNoSmooth = true;

	// menus
	TOTeamsel_Paint(C);
}



function Notify (UWindowDialogControl C, byte E)
{
	local	bool	bAnimateMenu;

	bAnimateMenu = true;
	Super.Notify(C,E);

	if ( E == DE_Click )
	{
		switch( C )
		{
			case BtnServerTR:	menuTeam = 0;
								menuItem = MI_TEAM;
								break;

			case BtnServerSF:	menuTeam = 1;
								menuItem = MI_TEAM;
								break;

			case BtnRndTeam:
								menuTeam = 254; // Random Team (255 being waiting players)
								menuSkin = 255; // Random Model
								TOTeamsel_Tool_ChangeTeam(menuTeam);
								Close();
								break;

			case BtnTeamJnSF:
			case BtnTeamJnTR:
								// Load last used skin by default instead
								ModelHandler = class<TO_ModelHandler>(DynamicLoadObject(ModelHandlerClass, class'Class'));
								menuSkin = ModelHandler.static.GetNextModel(MenuSkin, menuTeam);
								SetMeshActor();
								menuItem = MI_SKIN;
								//TOTeamsel_Tool_ChangeTeam(menuTeam);
								//Close();
								break;



			case	BtnPrev:
								ModelHandler = class<TO_ModelHandler>(DynamicLoadObject(ModelHandlerClass, class'Class'));
								menuSkin = ModelHandler.static.GetPrevModel(MenuSkin, menuTeam);
								SetMeshActor();
								break;

			case	BtnNext:
								ModelHandler = class<TO_ModelHandler>(DynamicLoadObject(ModelHandlerClass, class'Class'));
								menuSkin = ModelHandler.static.GetNextModel(MenuSkin, menuTeam);
								SetMeshActor();
								break;

			case BtnEnter:
								TOTeamsel_Tool_ChangeTeam(menuTeam);
								DelMeshActor();
								Close();
								break;

			case BtnExitGame:	
								if ( menuItem != MI_CREDITS )
								{
									menuItem = MI_CREDITS;
									Credits = GetPlayerOwner().Spawn(class'TO_Credits',GetPlayerOwner());
									if ( Credits != None )
										Credits.Initialize(xo-40, yo-168, xo+256, yo+192, Font(DynamicLoadObject("LadderFonts.UTLadder10", class'Font')), 15.0);
								}
								else
									bAnimateMenu = false;
								break;

			case BtnServerQt:	Close();
								//GetPlayerOwner().ConsoleCommand("disconnect");
								GetPlayerOwner().ConsoleCommand("exit");
								break;

			case BtnServerDisconnect:	Close();
								GetPlayerOwner().ConsoleCommand("disconnect");
								break;

			case BtnMiscBack:	
								menuItem = MI_SERVER;
								if ( menuItem == MI_CREDITS ) 
								{
									Credits.Destroy();
									Credits = None;
								}
								else if ( menuItem == MI_SKIN )
									DelMeshActor();
								break;
		}

		if ( bAnimateMenu )
		{
			TOTeamsel_Btn_HideAll();
			menuFadingFrame = menuFadingSpeed;
		}
	}
}




function Close (optional bool bByParent) 
{
	local	PlayerPawn	P;

	P = GetPlayerOwner();
	if ( (P != None) && P.IsA('TO_SysPlayer') )
		TO_SysPlayer(P).StartMenu = None;
	
	// Cleanup
	if ( Credits != None )
	{
		Credits.Destroy();
		Credits = None;
	}

	DelMeshActor();

	//Root.Console.bNoDrawWorld = true;
	if ( Root != None )
	{
/*		if (TO_RootWindow(Root) != None)
		{
			if (TO_RootWindow(Root).MenuBar != None)
				TO_RootWindow(Root).MenuBar.ShowWindow();
			if (TO_RootWindow(Root).StatusBar != None)
				TO_RootWindow(Root).StatusBar.ShowWindow();
		}
*/
		Root.Console.bQuickKeyEnable = false;
		Root.Console.CloseUWindow();

		Root.bAllowConsole = true;
		//TO_Console(Root.Console).bTeamMenu = false;
		//Root.Console.bLocked = false;
	}
	
	Super.Close(bByParent);
}



////////////////////
//  menus
////////////////////

function TOTeamsel_Paint (Canvas C)
{
	local	float								x1, x2;

	if ( menuFadingFrame == 0 )
	{
		// print menu
		TOTeamsel_Paint_Bg(C, xo-40, xo-256);

		switch( menuItem )
		{
			case MI_SERVER:		TOTeamsel_Paint_Server(C); break;
			case MI_TEAM:			TOTeamsel_Paint_Team(C); break;
			case MI_CREDITS:	TOTeamsel_Paint_Credits(C); break;
			case MI_SKIN:			TOTeamsel_Paint_Skin(C); break;
		}
	}
	else
	{
		// fade in next menu
		x1 = ( (we+360) / menuFadingSpeed) * menuFadingFrame + xo - 40;
		x2 = xo - 256 - ( (we+280) / menuFadingSpeed) * menuFadingFrame;
		TOTeamsel_Paint_Bg(C, x1, x2);

		if (--menuFadingFrame == 0)
			GetPlayerOwner().PlaySound(Sound'LightSwitch', SLOT_None);
	}
}



function TOTeamsel_Paint_Bg (Canvas C, float x1, float x2)
{
	C.Style = 3;
	C.DrawColor.R = 144;
	C.DrawColor.G = 144;
	C.DrawColor.B = 144;

	C.SetPos(x1, yo-208); C.DrawPattern(Texture'bg_cnt', 296, 416, 1.0);
	C.SetPos(x1, yo-208); C.DrawTile(Texture'bg_bdr_tl', 8, 8, 0, 0, 8, 8);
	C.SetPos(x1+288, yo-208); C.DrawTile(Texture'bg_bdr_tr', 8, 8, 0, 0, 8, 8);
	C.SetPos(x1, yo+200); C.DrawTile(Texture'bg_bdr_bl', 8, 8, 0, 0, 8, 8);
	C.SetPos(x1+288, yo+200); C.DrawTile(Texture'bg_bdr_br', 8, 8, 0, 0, 8, 8);

	C.SetPos(x2, yo); C.DrawPattern(Texture'bg_cnt', 208, 176, 1.0);
	C.SetPos(x2, yo); C.DrawTile(Texture'bg_bdr_tl', 8, 8, 0, 0, 8, 8);
	C.SetPos(x2+200, yo); C.DrawTile(Texture'bg_bdr_tr', 8, 8, 0, 0, 8, 8);
	C.SetPos(x2, yo+168); C.DrawTile(Texture'bg_bdr_bl', 8, 8, 0, 0, 8, 8);
	C.SetPos(x2+200, yo+168); C.DrawTile(Texture'bg_bdr_br', 8, 8, 0, 0, 8, 8);

	C.Font = Font(DynamicLoadObject("LadderFonts.UTLadder10", class'Font'));
	C.SetPos(xm-16, yo-229); C.DrawText("mess with the best - die like the rest", false);
}



function TOTeamsel_Paint_Headline (Canvas C, string hl)
{
	local	float								xl, yl;


	C.Font = Font(DynamicLoadObject("LadderFonts.UTLadder14", class'Font'));
	C.StrLen(hl, xl, yl);
	C.DrawColor = WhiteColor;
	C.SetPos(xo+108-xl/2, ym);
	C.DrawText(hl, false);
}


function TOTeamsel_Paint_Time (Canvas C, string prefix, int time)
{
	local	int									min, secs;

	min = time / 60;
	secs = time % 60;
	if ( secs < 0 )
		secs = 0;

	C.DrawText(prefix$TOTeamsel_Tool_TwoDigits(min)$":"$TOTeamsel_Tool_TwoDigits(secs), false);
}


function TOTeamsel_Paint_Server (Canvas C)
{
	Local	s_GameReplicationInfo	GRI;
	local	string								version;
	local	float									xl, yl, y;
	local	TO_SysPlayer					sP;
//local	s_SWATGame							SG;

	sP = TO_SysPlayer(GetPlayerOwner());

	if ( sP == None )
	{
		log("TO_TeamSelect::TOTeamsel_Paint_Server - sP == None");
		Close();
	}


	GRI = s_GameReplicationInfo(sP.GameReplicationInfo);
//	SG = s_SWATGame(Owner.Level.Game);

	if ( GRI == None )
	{
		//log("TO_TeamSelect::TOTeamsel_Paint_Server - GRI == None");
		return;
	}

	TOTeamsel_Paint_Headline(C, "server :: info");

	C.Font = Font(DynamicLoadObject("LadderFonts.UTLadder10", class'Font'));
	C.StrLen(" ", xl, yl);
	C.Style = 1;

	y = ym + 24;
	if ( GRI != None )
	{
		if (GRI.MotdLine1 != "")	
		{
			C.SetPos(xm, y);
			C.DrawText(GRI.MotdLine1, false);

			y += yl; C.SetPos(xm, y);
			C.DrawText(GRI.MotdLine2, false);

			y += yl; C.SetPos(xm, y);
			C.DrawText(GRI.MotdLine3, false);

			y += yl; C.SetPos(xm, y);
			C.DrawText(GRI.MotdLine4, false);

			y += yl * 2;
		}

		C.SetPos(xm, y);
		C.DrawText("server:  "$GRI.ServerName, false);

		y += yl; C.SetPos(xm, y);
		C.DrawText("admin:  "$GRI.AdminName, false);

		y += yl; C.SetPos(xm, y);
		C.DrawText("email:  "$GRI.AdminEmail, false);
	}

	if ( sP.Level != None )
	{
		// Title
		y += yl * 2; C.SetPos(xm, y);
		C.DrawText("scenario:  "$sP.Level.Title, false);

		// Author
		y += yl; C.SetPos(xm, y);
		C.DrawText("author:  "$sP.Level.Author, false);

		// IdealPlayerCount
		y += yl; C.SetPos(xm, y);
		C.DrawText("ideal player count:  "$sP.Level.IdealPlayerCount, false);
	}

	if ( GRI != None )
	{
		y += yl * 2;

		// Terrorists
		if ( GRI.Teams[0] != None )
		{
			C.DrawColor = RedColor;
			C.SetPos(xm, y);
			C.DrawText("terrorists:  "$GRI.Teams[0].Size$" players ("$int(GRI.Teams[0].Score)$" wins)", false);
			y += yl;
		}

		// Special Forces
		if ( GRI.Teams[1] != None )
		{
			C.DrawColor = BlueColor;
			C.SetPos(xm, y);
			C.DrawText("special Forces:  "$GRI.Teams[1].Size$" players ("$int(GRI.Teams[1].Score)$" wins)", false);
			y += yl;
		}

		C.DrawColor = WhiteColor;
		
		// time stats
		y += yl; C.SetPos(xm, y);
		if ( !GRI.bPreRound )
			TOTeamsel_Paint_Time(C, "remaining round time:  ", GRI.RoundDuration * 60 - (GRI.RoundStarted - GRI.Remainingtime));
		else
			C.DrawText("remaining round time:  pre-round", false);

		y += yl; C.SetPos(xm, y);
		if ( GRI.RemainingTime <= 0 )
			TOTeamsel_Paint_Time(C, "remaining total time:  ", 0);
		else
			TOTeamsel_Paint_Time(C, "remaining total time:  ", GRI.RemainingTime);

		y += yl*2; C.SetPos(xm, y);
		C.DrawText("allow ghost cam:  "$GRI.bAllowGhostCam, false);
		y += yl; C.SetPos(xm, y);
		C.DrawText("mirror damage:  "$GRI.bMirrorDamage, false);
		y += yl; C.SetPos(xm, y);
		C.DrawText("ballistics:  "$GRI.bEnableBallistics, false);
		y += yl; C.SetPos(xm, y);
		C.DrawText("friendly fire scale:  "$GRI.friendlyfirescale$"%", false);
	}

	if ( (sP.PlayerReplicationInfo != None) && (sP.Level.NetMode != NM_StandAlone) )
	{
		y += yl*2; C.SetPos(xm, y);
		C.DrawText("Ping:  "$sP.PlayerReplicationInfo.Ping, false);
	}
/*
	// game info
	y += yl * 2; C.SetPos(xm, y);
	C.DrawText("friendly fire:  "$int(SG.FriendlyFireScale)*100$"%", false);

	y += yl; C.SetPos(xm, y);
	if (SG.bEnableBallistics)
		C.DrawText("ballistics:  enabled", false);
	else
		C.DrawText("ballistics:  disabled", false);

	y += yl; C.SetPos(xm, y);
	if (!SG.bDisableRealDamages)
		C.DrawText("real damage:  enabled", false);
	else
		C.DrawText("real damage:  disabled", false);
		
	y += yl; C.SetPos(xm, y);
	if (SG.bReduceSFX)
		C.DrawText("effects:  reduced", false);
	else
		C.DrawText("effects:  normal", false);

	y += yl * 2; C.SetPos(xm, y);
	C.DrawText("round limit:  "$SG.RoundLimit, false);
	y += yl; C.SetPos(xm, y);
	C.DrawText("current round:  "$SG.RoundNumber, false);
*/
	// show buttons
	BtnServerSF.Show();
	BtnServerTR.Show();
	BtnRndTeam.Show();
}


function TOTeamsel_Paint_Team (Canvas C)
{
	local PlayerReplicationInfo				PRI, OwnerInfo;
	local TournamentGameReplicationInfo		OwnerGame;
	local TO_SysPlayer							Owner;
	local float								xl, yl, y;
	local int								i, j;
	local string							s;


	if ( menuTeam == 1 )
	{
		TOTeamsel_Paint_Headline(C, "team :: special forces");
		BtnTeamJnSF.Show();
	}
	else
	{
		TOTeamsel_Paint_Headline(C, "team :: terrorists");
		BtnTeamJnTR.Show();
	}

	C.Font = Font(DynamicLoadObject("LadderFonts.UTLadder10", class'Font'));
	C.StrLen(" ", xl, yl);

	y = ym + 24;

	// player table header
	C.DrawColor = WhiteColor;
	C.SetPos(xm, y); C.DrawText("nick", false);
	C.SetPos(xo+144-xl*4, y); C.DrawText("score", false);
	C.SetPos(xo+188-xl*4, y); C.DrawText("time", false);
	C.SetPos(xo+232-xl*4, y); C.DrawText("ping", false);
	y += yl*2;

	Owner = TO_SysPlayer(GetPlayerOwner());
	OwnerInfo = Owner.PlayerReplicationInfo;

	for (i = 0; (i < 32) && (j < 16); i++)
	{
		if ( Owner.GameReplicationInfo.PRIArray[i] != None )
		{
			PRI = Owner.GameReplicationInfo.PRIArray[i];
			if ( !PRI.bWaitingPlayer && (PRI.Team == menuTeam) )
			{
				// determine color
				if (PRI.PlayerName == Owner.PlayerReplicationInfo.PlayerName)
					continue;

				// player info
				C.DrawColor = WhiteColor;
				s = string(Max(1, (Owner.Level.TimeSeconds + OwnerInfo.StartTime - PRI.StartTime)/60));
				C.StrLen(s, xl, yl); C.SetPos(xo+144-xl, y); C.DrawText(int(PRI.Score)$"/"$int(PRI.Deaths), false);
				s = string(Max(1, (Owner.Level.TimeSeconds + OwnerInfo.StartTime - PRI.StartTime)/60));
				C.StrLen(s, xl, yl); C.SetPos(xo+192-xl, y); C.DrawText(s, false);
				s = string(PRI.Ping);
				C.StrLen(s, xl, yl); C.SetPos(xo+236-xl, y); C.DrawText(s, false);

				if ( PRI.bAdmin )
					C.DrawColor = WhiteColor;
				else if ( menuTeam == 1 )
				{
					if ( PRI.bIsSpectator )
						C.DrawColor = DarkBlueColor;
					else
						C.DrawColor = BlueColor;
				}
				else
				{
					if ( PRI.bIsSpectator )
						C.DrawColor = DarkRedColor;
					else
						C.DrawColor = RedColor;
				}

				// player name
				C.SetPos(xm, y);
				C.DrawText(PRI.PlayerName, false);

				y += yl * 1.5;
				j++;
			}
		}
	}

	BtnMiscBack.Show();
}



function TOTeamsel_Paint_Skin(Canvas C)
{
	local float		OldFov;
	local	Vector	Position;

	ModelHandler = class<TO_ModelHandler>(DynamicLoadObject(ModelHandlerClass, class'Class'));
	TOTeamsel_Paint_Headline(C, "model selection ::"@ModelHandler.default.ModelName[menuSkin]);
	
	//C.Style = GetPlayerOwner().ERenderStyle.STY_Modulated;
	//DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'BlackTexture');
	//C.Style = GetPlayerOwner().ERenderStyle.STY_Normal;

	if ( MeshActor != None )
	{
		MeshActor.DrawScale = MeshActor.default.DrawScale * Scale;
		OldFov = GetPlayerOwner().FOVAngle;
		GetPlayerOwner().SetFOVAngle(30);

		Position = /*Vect(10.0, 0.0, 0.0) +*/ Vect(0, 0.8, -0.1)*Scale;
		DrawClippedActor(C, WinWidth/2, WinHeight/2, MeshActor, false, ViewRotator, Position);
		GetPlayerOwner().SetFOVAngle(OldFov);
	}

	BtnPrev.Show();
	BtnNext.Show();
	BtnEnter.Show();
	BtnMiscBack.Show();
}


function TOTeamsel_Paint_Credits (Canvas C)
{
	TOTeamsel_Paint_Headline(C, "exit game :: credits");

	if ( Credits != None )
		Credits.RenderCredits(C);

	BtnServerQt.Show();
	BtnServerDisconnect.Show();
	BtnMiscBack.Show();
}


function	Tick( float DeltaTime)
{
	if ( menuItem == MI_SKIN )
		ViewRotator.Yaw += 20000 * DeltaTime;
}


////////////////////
//  actions
////////////////////

function EscClose()
{
	GetPlayerOwner().PlaySound(Sound'hithelmet', SLOT_None);
}



////////////////////
//  buttons
////////////////////

function TO_MenuButton AddButton(int x, int y, int w, int h, texture UPtex, texture OVERtex, texture DOWNtex, bool bForward)
{

	local TO_MenuButton b;
	
	b = TO_MenuButton(CreateControl(class'TO_MenuButton', x, y, w, h));
	b.Hide();

	b.UpTexture = UPtex;
	b.DownTexture = DOWNtex;
	b.OverTexture = OVERtex;
	b.DisabledTexture = UPtex;
	b.DisplayPosX = x;
	b.DisplayPosY = y;
	
	b.ToolTipString = "";

	if ( bForward )
		b.DownSound = Sound'BerClipIn';
	else
		b.DownSound = Sound'BerClipIn';
	b.OverSound = Sound'LightSwitch';

	return b;
}



////////////////////
//  tools
////////////////////

function TOTeamsel_Btn_HideAll ()
{
	BtnServerQt.Hide();
	BtnServerDisconnect.Hide();
	BtnServerSF.Hide();
	BtnServerTR.Hide();
	BtnRndTeam.Hide();
	BtnTeamJnSF.Hide();
	BtnTeamJnTR.Hide();
	BtnMiscBack.Hide();
	BtnPrev.Hide();
	BtnNext.Hide();
	BtnEnter.Hide();
}


function string TOTeamsel_Tool_TwoDigits (int num)
{
	if ( num < 10 )
		return "0"$num;
	else
		return string(num);
}


function bool TOTeamsel_Tool_ChangeTeam(int NewTeam)
{
	local int PlayerSpread, OldTeam;
	local string msg;
	local int TerrSize, SWATSize;

	if ( GetPlayerOwner() == None )
	{
		log("TO_TeamSelect::TOTeamsel_Tool_ChangeTeam - GetPlayerOwner() == None");
		Close();
		return false;
	}

	OldTeam = GetPlayerOwner().PlayerReplicationInfo.Team;

	if ( TO_SysPlayer(GetPlayerOwner()) != None )
	{
		TO_SysPlayer(GetPlayerOwner()).s_ChangeTeam(MenuSkin, NewTeam, false);
		return true;
	}
	else
		log("TO_TeamSelect::TOTeamsel_Tool_ChangeTeam - TO_SysPlayer(GetPlayerOwner()) == None");
	
	Close();
	return false;
}


function	SetMeshActor()
{
	local	bool	bAlreadyCreated;

	if ( MeshActor == None )
	{
		MeshActor = GetEntryLevel().Spawn(class'TO_MeshActor', GetEntryLevel());
		ViewRotator = rot(0, 32768, 0);
	}
	else
		bAlreadyCreated = true;

	if ( MeshActor != None )
	{	
		ModelHandler = class<TO_ModelHandler>(DynamicLoadObject(ModelHandlerClass, class'Class'));
		ModelHandler.static.DressModel(MeshActor, menuSkin);
		if ( !bAlreadyCreated )
		{
			MeshActor.NotifyClient = Self;
			MeshActor.PlayAnim('Breath2', 1.0);
		}
	}
	else
		log("TO_TeamSelect::SetMeshActor - MeshActor == None!");
}


function	DelMeshActor()
{
	if ( MeshActor != None )
	{
		MeshActor.Destroy();
		MeshActor = None;
	}
}

function AnimEnd(TO_MeshActor MyMesh)
{
	
	if ( MyMesh.AnimSequence == 'Breath2' )
		MyMesh.TweenAnim('Breath1', 0.5);
	else
		MyMesh.PlayAnim('Breath2', 1.0);
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     WhiteColor=(R=255,G=255,B=255)
     BlueColor=(R=115,G=172,B=229)
     DarkBlueColor=(R=74,G=109,B=145)
     RedColor=(R=230,G=115,B=115)
     DarkRedColor=(R=145,G=74,B=74)
     ModelHandlerClass="TOPModels.TO_ModelHandler"
}
