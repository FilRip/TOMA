class TOSTWeaponsTab extends TOSTGUIBaseTab;

var	TOSTGUIBaseButton 	ButtonClose, ButtonPrevPage, ButtonNextPage, ButtonWeapon[31], ButtonSave[10], ButtonLoad[10];
var	TOSTGUILabel		LabelPage, LabelSF, LabelTerr, LabelFree, LabelArmor[3], LabelItem[3], LabelFull, LabelC4, LabelRandom, LabelCrazy, LabelLight, LabelClips, LabelShootC4, LabelNadeTimer, LabelFullKnife;
var	TOSTGUICheckBox		CHKSFW[31], CHKTerrW[31], CHKFreeW[31], CHKFreeI[6], CHKSpec[9];
var	TOSTGUIEditControl	EditSettings[10];
var TOSTGUIBaseUpdown	UpDownRandomTime;

var localized string	TextHintCloseButton, TextHintDefault, TextHintDefaultAlt, TextHintNextPage, TextHintPrevPage;
var localized string	TextButtonWeapon, TextTerrWeapon, TextSFWeapon, TextFreeWeapon, AltTextFreeItem[6], TextFreeItem;
var localized string	TextOICWTerr, TextOICWSF, TextFullAmmo, TextC4, TextLightGuns, TextPickClips, TextCrazyAmmo, TextRandomGun, AltTextRandomGun, TextRandomTime, AltTextRandomTime, TextShootableC4, TextNadeTimer, TextFullKnife;
var localized string	TextLoadSettings, TextSaveSettings, TextSettings;

var	int					CurrentPage, MaxPages;

var float				AdminWarning, AdminWarnStep;

var string				WeaponName[31];
var byte				WeaponTeam[31];

simulated function Created()
{
	local int i;

	super.Created();

	AdminWarning = 0.3;
	AdminWarnStep = 1;

	//General
 	Title = "WeaponsTab";

	ButtonClose = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonClose.Text = "Close";
	ButtonClose.OwnerTab = self;

	ButtonPrevPage = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonPrevPage.Text = "<";
	ButtonPrevPage.OwnerTab = self;

	ButtonNextPage = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonNextPage.Text = ">";
	ButtonNextPage.OwnerTab = self;

	LabelPage = TOSTGUILabel(CreateWindow(class'TOSTGUILabel', 0, 0, WinWidth, WinHeight));
	LabelPage.OwnerTab = self;

	//Labels SF-Terr-Free
	LabelSF = TOSTGUILabel(CreateWindow(class'TOSTGUILabel', 0, 0, WinWidth, WinHeight));
	LabelSF.OwnerTab = self;
	LabelSF.text = "Special Forces";

	LabelTerr = TOSTGUILabel(CreateWindow(class'TOSTGUILabel', 0, 0, WinWidth, WinHeight));
	LabelTerr.OwnerTab = self;
	LabelTerr.text = "Terrorist";

	LabelFree = TOSTGUILabel(CreateWindow(class'TOSTGUILabel', 0, 0, WinWidth, WinHeight));
	LabelFree.OwnerTab = self;
	LabelFree.text = "Free";

	//Buttons Weapons && Chkbox
	for ( i=0; i<31; i++ )
	{
		ButtonWeapon[i] = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
		ButtonWeapon[i].Text = WeaponName[i];
		ButtonWeapon[i].OwnerTab = self;

		CHKSFW[i] = TOSTGUICheckBox(CreateWindow(class'TOSTGUICheckBox', 0, 0, WinWidth, WinHeight));
		CHKSFW[i].OwnerTab = self;
		CHKSFW[i].Text = "";

		CHKTerrW[i] = TOSTGUICheckBox(CreateWindow(class'TOSTGUICheckBox', 0, 0, WinWidth, WinHeight));
		CHKTerrW[i].OwnerTab = self;
		CHKTerrW[i].Text = "";

		CHKFreeW[i] = TOSTGUICheckBox(CreateWindow(class'TOSTGUICheckBox', 0, 0, WinWidth, WinHeight));
		CHKFreeW[i].OwnerTab = self;
		CHKFreeW[i].Text = "";
	}

	//Label Armor - NV
	LabelArmor[0] = TOSTGUILabel(CreateWindow(class'TOSTGUILabel', 0, 0, WinWidth, WinHeight));
	LabelArmor[0].Text = "Helmet";
	LabelArmor[0].OwnerTab = self;

	LabelArmor[1] = TOSTGUILabel(CreateWindow(class'TOSTGUILabel', 0, 0, WinWidth, WinHeight));
	LabelArmor[1].Text = "Vest";
	LabelArmor[1].OwnerTab = self;

	LabelArmor[2] = TOSTGUILabel(CreateWindow(class'TOSTGUILabel', 0, 0, WinWidth, WinHeight));
	LabelArmor[2].Text = "Legs";
	LabelArmor[2].OwnerTab = self;

	LabelItem[0] = TOSTGUILabel(CreateWindow(class'TOSTGUILabel', 0, 0, WinWidth, WinHeight));
	LabelItem[0].Text = "NightVision";
	LabelItem[0].OwnerTab = self;

	LabelItem[1] = TOSTGUILabel(CreateWindow(class'TOSTGUILabel', 0, 0, WinWidth, WinHeight));
	LabelItem[1].Text = "Binocular";
	LabelItem[1].OwnerTab = self;

	LabelItem[2] = TOSTGUILabel(CreateWindow(class'TOSTGUILabel', 0, 0, WinWidth, WinHeight));
	LabelItem[2].Text = "TearGas Mask";
	LabelItem[2].OwnerTab = self;

	//items & extra
	for ( i=0; i<6; i++ )
	{
		CHKFreeI[i] = TOSTGUICheckBox(CreateWindow(class'TOSTGUICheckBox', 0, 0, WinWidth, WinHeight));
		CHKFreeI[i].OwnerTab = self;
		CHKFreeI[i].Text = "";
	}

	for ( i=0; i<9; i++ )
	{
		CHKSpec[i] = TOSTGUICheckBox(CreateWindow(class'TOSTGUICheckBox', 0, 0, WinWidth, WinHeight));
		CHKSpec[i].OwnerTab = self;
		CHKSpec[i].Text = "";
	}

	LabelFull = TOSTGUILabel(CreateWindow(class'TOSTGUILabel', 0, 0, WinWidth, WinHeight));
	LabelFull.Text = "Full Ammo";
	LabelFull.OwnerTab = self;

	LabelC4 = TOSTGUILabel(CreateWindow(class'TOSTGUILabel', 0, 0, WinWidth, WinHeight));
	LabelC4.Text = "In map C4";
	LabelC4.OwnerTab = self;

	LabelCrazy = TOSTGUILabel(CreateWindow(class'TOSTGUILabel', 0, 0, WinWidth, WinHeight));
	LabelCrazy.Text = "Crazy Ammo";
	LabelCrazy.OwnerTab = self;

	LabelLight = TOSTGUILabel(CreateWindow(class'TOSTGUILabel', 0, 0, WinWidth, WinHeight));
	LabelLight.Text = "Light Guns";
	LabelLight.OwnerTab = self;

	LabelClips = TOSTGUILabel(CreateWindow(class'TOSTGUILabel', 0, 0, WinWidth, WinHeight));
	LabelClips.Text = "Pick Clips";
	LabelClips.OwnerTab = self;

	LabelShootC4 = TOSTGUILabel(CreateWindow(class'TOSTGUILabel', 0, 0, WinWidth, WinHeight));
	LabelShootC4.Text = "Shootable C4";
	LabelShootC4.OwnerTab = self;

	LabelNadeTimer = TOSTGUILabel(CreateWindow(class'TOSTGUILabel', 0, 0, WinWidth, WinHeight));
	LabelNadeTimer.Text = "Nade Timer";
	LabelNadeTimer.OwnerTab = self;

	LabelFullKnife = TOSTGUILabel(CreateWindow(class'TOSTGUILabel', 0, 0, WinWidth, WinHeight));
	LabelFullKnife.Text = "Full Knife";
	LabelFullKnife.OwnerTab = self;

	LabelRandom = TOSTGUILabel(CreateWindow(class'TOSTGUILabel', 0, 0, WinWidth, WinHeight));
	LabelRandom.Text = "Random Gun";
	LabelRandom.OwnerTab = self;

	UpDownRandomTime = TOSTGUIBaseUpdown(CreateControl(class'TOSTGUIBaseUpdown', 0, 0, WinWidth, WinHeight));
    UpDownRandomTime.MinValue=0;
    UpDownRandomTime.MaxValue=240;
    UpDownRandomTime.IncValue=10;
    UpDownRandomTime.IncValue2=30;
	UpDownRandomTime.Label = "Random Time";
	UpDownRandomTime.OwnerTab = self;

	// Settings Page
	for (i=0; i<10; i++)
	{
		EditSettings[i] = TOSTGUIEditControl(CreateControl(Class'TOSTGUIEditControl', 0, 0, WinWidth, WinHeight));
		EditSettings[i].Label = "Weapons Settings "$i;
		EditSettings[i].OwnerTab = self;
		EditSettings[i].SetValue("");
		EditSettings[i].SetNumericOnly(False);
		EditSettings[i].SetMaxLength(60);
		EditSettings[i].SetDelayedNotify(True);

		ButtonSave[i] = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
		ButtonSave[i].Text = "Save";
		ButtonSave[i].OwnerTab = self;

		ButtonLoad[i] = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
		ButtonLoad[i].Text = "Load";
		ButtonLoad[i].OwnerTab = self;
	}

	//hide all
	for ( i=0; i<MaxPages; i++)
	{
		Currentpage = i;
		HideCurrentPage();
	}

	CurrentPage = 0;
	OpenCurrentPage();
}

simulated function Clearup()
{
	if ( !bInitialized )
		return;
}

simulated function BeforeShow ()
{
	ClearUp();

	LoadCurrentPage();
	ShowCurrentPage();

	ButtonClose.ShowWindow();
	ButtonPrevPage.ShowWindow();
	ButtonNextPage.ShowWindow();
	LabelPage.ShowWindow();
}

simulated function LoadCurrentPage()
{
	local int i;

	if ( TabComm == none )
		return;

	switch(CurrentPage)
	{
		case 0 :	for ( i=1; i<12; i++ )
					{
						TabComm.SendMessage(551, i);
					}
					break;
		case 1 :	for ( i=12; i<24; i++ )
					{
						TabComm.SendMessage(551, i);
					}
					break;
		case 2 :	for ( i=24; i<31; i++ )
					{
						TabComm.SendMessage(551, i);
					}
					for ( i=0; i<6; i++ )
					{
						TabComm.SendMessage(551, 50+i);
					}
					break;
		case 3 :	for ( i=0; i<9; i++ )
					{
						TabComm.SendMessage(551, 40+i);
					}
					TabComm.SendMessage(551, 0);
					break;
		case 4 :	for ( i=0; i<10; i++ )
					{
						TabComm.SendMessage(553, i);
					}
					break;
	}
}

simulated function OpenCurrentPage()
{
	switch(CurrentPage)
	{
		case 0 :	LabelPage.Text="Guns / SMG";
					break;
		case 1 :	LabelPage.Text="Rifles";
					break;
		case 2 :	LabelPage.Text="Nades / Armor";
					break;
		case 3 :	LabelPage.Text="Special Settings";
					break;
		case 4 :	LabelPage.Text="Load / Save";
					break;
	}

	LoadCurrentPage();
	ShowCurrentPage();
}

simulated function ShowCurrentPage()
{
	local int i;

	switch(CurrentPage)
	{
		case 0 :	for ( i=1; i<12; i++ )
					{
						ButtonWeapon[i].showWindow();
						CHKSFW[i].showWindow();
						CHKTerrW[i].showWindow();
						CHKFreeW[i].showWindow();
					}
					LabelSF.showWindow();
					LabelTerr.showWindow();
					LabelFree.showWindow();
					break;
		case 1 :	for ( i=12; i<24; i++ )
					{
						ButtonWeapon[i].showWindow();
						CHKSFW[i].showWindow();
						CHKTerrW[i].showWindow();
						CHKFreeW[i].showWindow();
					}
					LabelSF.showWindow();
					LabelTerr.showWindow();
					LabelFree.showWindow();
					break;
		case 2 :	for ( i=24; i<31; i++ )
					{
						ButtonWeapon[i].showWindow();
						CHKSFW[i].showWindow();
						CHKTerrW[i].showWindow();
						CHKFreeW[i].showWindow();
					}
					for ( i=0; i<3; i++ )
					{
						LabelArmor[i].showWindow();
						CHKFreeI[i].showWindow();
						LabelItem[i].showWindow();
						CHKFreeI[3+i].showWindow();
					}
					LabelSF.showWindow();
					LabelTerr.showWindow();
					LabelFree.showWindow();
					break;
		case 3 :	ButtonWeapon[0].showWindow();
					CHKSFW[0].showWindow();
					CHKTerrW[0].showWindow();
					LabelFull.showWindow();
					LabelC4.showWindow();
					LabelCrazy.showWindow();
					LabelLight.showWindow();
					LabelClips.showWindow();
					LabelShootC4.showWindow();
					LabelNadeTimer.showWindow();
					LabelFullKnife.showWindow();
					LabelRandom.showWindow();
					UpDownRandomTime.showWindow();
					for ( i=0; i<9; i++)
					{
						CHKSpec[i].showWindow();
					}
					LabelSF.showWindow();
					LabelTerr.showWindow();
					break;
		case 4 :	for ( i=0; i<MaxVisibleItems(); i++ )
					{
						EditSettings[i].showWindow();
						ButtonLoad[i].showWindow();
						ButtonSave[i].showWindow();
					}
					break;
	}
}

simulated function HideCurrentPage()
{
	local int i;

	switch(CurrentPage)
	{
		case 0 :	for ( i=1; i<12; i++ )
					{
						ButtonWeapon[i].hideWindow();
						CHKSFW[i].hideWindow();
						CHKTerrW[i].hideWindow();
						CHKFreeW[i].hideWindow();
					}
					LabelSF.hideWindow();
					LabelTerr.hideWindow();
					LabelFree.hideWindow();
					break;
		case 1 :	for ( i=12; i<24; i++ )
					{
						ButtonWeapon[i].hideWindow();
						CHKSFW[i].hideWindow();
						CHKTerrW[i].hideWindow();
						CHKFreeW[i].hideWindow();
					}
					LabelSF.hideWindow();
					LabelTerr.hideWindow();
					LabelFree.hideWindow();
					break;
		case 2 :	for ( i=24; i<31; i++ )
					{
						ButtonWeapon[i].hideWindow();
						CHKSFW[i].hideWindow();
						CHKTerrW[i].hideWindow();
						CHKFreeW[i].hideWindow();
					}
					for ( i=0; i<3; i++ )
					{
						LabelArmor[i].hideWindow();
						CHKFreeI[i].hideWindow();
						LabelItem[i].hideWindow();
						CHKFreeI[3+i].hideWindow();
					}
					LabelSF.hideWindow();
					LabelTerr.hideWindow();
					LabelFree.hideWindow();
					break;
		case 3 :	ButtonWeapon[0].hideWindow();
					CHKSFW[0].hideWindow();
					CHKTerrW[0].hideWindow();
					LabelFull.hideWindow();
					LabelC4.hideWindow();
					LabelCrazy.hideWindow();
					LabelLight.hideWindow();
					LabelClips.hideWindow();
					LabelShootC4.hideWindow();
					LabelNadeTimer.hideWindow();
					LabelFullKnife.hideWindow();
					LabelRandom.hideWindow();
					UpDownRandomTime.hideWindow();
					for ( i=0; i<9; i++)
					{
						CHKSpec[i].hideWindow();
					}
					LabelSF.hideWindow();
					LabelTerr.hideWindow();
					break;
		case 4 :	for ( i=0; i<10; i++ )
					{
						EditSettings[i].hideWindow();
						ButtonLoad[i].hideWindow();
						ButtonSave[i].hideWindow();
					}
					break;
	}
}

simulated function BeforeHide ()
{
	HideCurrentPage();

	ButtonClose.HideWindow();
	ButtonPrevPage.HideWindow();
	ButtonNextPage.HideWindow();
	LabelPage.HideWindow();
}

simulated function int MaxVisibleItems()
{
	if ( Resolution == 0 )
		return 7;
	else if ( Resolution == 1 )
		return 9;
	else return 10;
}

simulated function CloseCurrentPage()
{
	HideCurrentPage();
}

simulated function Close(optional bool bByParent)
{
	local int i;

	ButtonClose.Close();
	ButtonPrevPage.Close();
	ButtonNextPage.Close();
	LabelPage.Close();
	LabelSF.Close();
	LabelTerr.Close();
	LabelFree.Close();
	LabelFull.Close();
	LabelC4.Close();
	LabelRandom.Close();
	LabelCrazy.Close();
	LabelLight.Close();
	LabelClips.Close();
	LabelShootC4.Close();
	LabelNadeTimer.Close();
	LabelFullKnife.Close();
	UpDownRandomTime.Close();

	for ( i=0; i<=30; i++ )
	{

		CHKSFW[i].Close();
		CHKTerrW[i].Close();
		CHKFreeW[i].Close();
		ButtonWeapon[i].Close();
		if ( i < 10 )
		{
			ButtonSave[i].Close();
			ButtonLoad[i].Close();
			EditSettings[i].Close();
			if ( i < 9 )
			{
				CHKSpec[i].Close();
				if ( i < 6 )
				{
					CHKFreeI[i].Close();
					if ( i < 3 )
						LabelItem[i].Close();
				}
			}
		}
	}
}

simulated function Tick (float delta)
{
	if (!OwnerPlayer.PlayerReplicationInfo.bAdmin)
	{
		if ((AdminWarning + (AdminWarnStep*delta) > 0.7) || (AdminWarning + (AdminWarnStep*delta) < 0.3))
			AdminWarnStep = -AdminWarnStep;
		AdminWarning += AdminWarnStep*delta;
		if (AdminWarning > 0.7)
			AdminWarning = 0.7;
		if (AdminWarning < 0.3)
			AdminWarning = 0.3;
	}
}

simulated function Paint (Canvas Canvas, float x, float y)
{
	local float BH;

	Super.Paint(Canvas, x, y);

	if (bDraw)
		if (!OwnerPlayer.PlayerReplicationInfo.bAdmin && Master.SemiAdmin == 0)
			PaintAdminWarning(Canvas);

	Canvas.DrawColor = OwnerInterface.Design.ColorWhite;
	if ( CurrentPage == 3 )
	{
		OwnerInterface.Tool_DrawBox(Canvas, Left + 8, Top + 8, Width - 16, CHKSFW[1].winTop - 8);
		OwnerInterface.Tool_DrawBox(Canvas, Left + 8, CHKSFW[3].WinTop + 8, Width - 16, CHKSFW[7].WinTop - CHKSFW[1].WinTop);
		OwnerInterface.Tool_DrawBox(Canvas, Left + 8, CHKSFW[10].WinTop + 8, Width - 16, ButtonClose.WinTop - CHKSFW[10].WinTop - ButtonClose.WinHeight - 12);
	}
	else if ( CurrentPage == 2 )
	{
		OwnerInterface.Tool_DrawBox(Canvas, Left + 8, Top + 8, Width - 16, CHKSFW[10].WinTop - CHKSFW[1].WinTop);
		OwnerInterface.Tool_DrawBox(Canvas, Left + 8, CHKSFW[8].WinTop + 16, Width - 16, ButtonClose.WinTop - CHKSFW[8].WinTop - ButtonClose.WinHeight - 20);
	}
	else
		OwnerInterface.Tool_DrawBox(Canvas, Left + 8, Top + 8, Width - 16, ButtonClose.WinTop - Top - ButtonClose.WinHeight - 12);

}

simulated function PaintAdminWarning (Canvas Canvas)
{
	local float	x1, y1;

	Canvas.Style = OwnerHUD.ERenderStyle.STY_NORMAL;
	OwnerInterface.Design.SetScoreboardFont(Canvas);

	Canvas.DrawColor.R = OwnerInterface.Design.ColorRed.R * AdminWarning;
	Canvas.DrawColor.G = OwnerInterface.Design.ColorRed.G * AdminWarning;
	Canvas.DrawColor.B = OwnerInterface.Design.ColorRed.B * AdminWarning;

	Canvas.StrLen("You are currently not logged in as admin!", x1, y1);
	Canvas.SetPos(Left + ((Width-x1) / 2), ButtonClose.WinTop - ButtonClose.WinHeight - 4 + ((ButtonClose.WinHeight - y1)/2));
	Canvas.DrawText("You are currently not logged in as admin!", true);
}

simulated function Setup(Canvas Canvas)
{
	local float W, SW;
	local int LH;
	local int i, j;

	OwnerHud.Design.SetHeadLineFont(Canvas);

	W = Width * 0.25 - Padding[Resolution];
	SW = (Width / 4 - (W - Padding[Resolution])) / 2;
	LH = OwnerHud.Design.LineHeight;

	ButtonClose.WinLeft = Left + Width - W;
	ButtonClose.WinTop = Top + Height - Padding[Resolution] - LH - 3;
	ButtonClose.SetWidth(Canvas, W - Padding[Resolution]);

	ButtonPrevPage.WinLeft = Left + Padding[Resolution];
	ButtonPrevPage.WinTop = Top + Height - Padding[Resolution] - LH - 3;
	ButtonPrevPage.SetWidth(Canvas, W * 0.25);

	ButtonNextPage.WinLeft = Left + Width * 0.5 - ButtonPrevPage.WinWidth;
	ButtonNextPage.WinTop = Top + Height - Padding[Resolution] - LH - 3;
	ButtonNextPage.SetWidth(Canvas, W * 0.25);

	LabelPage.WinLeft = ButtonPrevPage.WinLeft + ButtonPrevPage.WinWidth + Padding[Resolution];
	LabelPage.WinTop = Top + Height - Padding[Resolution] - LH - 3;
	LabelPage.SetWidth(Canvas, ButtonNextPage.WinLeft - Padding[Resolution] - LabelPage.WinLeft);

	LabelSF.WinLeft = Left + Width / 4 + SW;
	LabelSF.WinTop = Top + LH;
	LabelSF.SetWidth(Canvas, W - Padding[Resolution]);

	LabelTerr.WinLeft = Left + Width / 2 + SW;
	LabelTerr.WinTop = Top + LH;
	LabelTerr.SetWidth(Canvas, W - Padding[Resolution]);

	LabelFree.WinLeft = Left + 3 * Width / 4 + SW;
	LabelFree.WinTop = Top + LH;
	LabelFree.SetWidth(Canvas, W - Padding[Resolution]);

	//weapon
	for ( i=0; i<31; i++)
	{
		if ( (i == 0) || (i == 1) || (i == 12) || (i == 24) )
			j = 2;

		ButtonWeapon[i].WinLeft = Left + SW;
		ButtonWeapon[i].WinTop = Top + (Padding[Resolution] + LH) * j;
		ButtonWeapon[i].SetWidth(Canvas, W - Padding[Resolution]);

		CHKSFW[i].WinLeft = LabelSF.WinLeft + LabelSF.WinWidth / 2 - 2 * Padding[Resolution];
		CHKSFW[i].WinTop = Top + (Padding[Resolution] + LH) * j;
		CHKSFW[i].SetWidth(Canvas, W - Padding[Resolution]);

		CHKTerrW[i].WinLeft = LabelTerr.WinLeft + LabelTerr.WinWidth / 2 - 2 * Padding[Resolution];
		CHKTerrW[i].WinTop = Top + (Padding[Resolution] + LH) * j;
		CHKTerrW[i].SetWidth(Canvas, W - Padding[Resolution]);

		CHKFreeW[i].WinLeft = LabelFree.WinLeft + LabelFree.WinWidth / 2 - 2 * Padding[Resolution];
		CHKFreeW[i].WinTop = Top + (Padding[Resolution] + LH) * j;
		CHKFreeW[i].SetWidth(Canvas, W - Padding[Resolution]);

		j++;
	}
	CHKFreeW[0].hideWindow();

	//armor/nv
	j = 10;
	for ( i=0; i<3; i++)
	{
		LabelArmor[i].WinLeft = Left + SW;
		LabelArmor[i].WinTop = Top + (Padding[Resolution] + LH) * j;
		LabelArmor[i].SetWidth(Canvas, W - Padding[Resolution]);

		CHKFreeI[i].WinLeft = LabelSF.WinLeft + LabelSF.WinWidth / 2 - 2 * Padding[Resolution];
		CHKFreeI[i].WinTop = Top + (Padding[Resolution] + LH) * j;
		CHKFreeI[i].SetWidth(Canvas, W - Padding[Resolution]);

		j++;
	}

	j = 10;
	for ( i=0; i<3; i++)
	{
		LabelItem[i].WinLeft = LabelTerr.WinLeft;
		LabelItem[i].WinTop = Top + (Padding[Resolution] + LH) * j;
		LabelItem[i].SetWidth(Canvas, W - Padding[Resolution]);

		CHKFreeI[3+i].WinLeft = LabelFree.WinLeft + LabelFree.WinWidth / 2 - 2 * Padding[Resolution];
		CHKFreeI[3+i].WinTop = Top + (Padding[Resolution] + LH) * j;
		CHKFreeI[3+i].SetWidth(Canvas, W - Padding[Resolution]);

		j++;
	}

	//spec items

	LabelFull.WinLeft = Left + SW;
	LabelFull.WinTop = Top + (Padding[Resolution] + LH) * 5;
	LabelFull.SetWidth(Canvas, W - Padding[Resolution]);

	LabelC4.WinLeft = Left + SW;
	LabelC4.WinTop = Top + (Padding[Resolution] + LH) * 6;
	LabelC4.SetWidth(Canvas, W - Padding[Resolution]);

	LabelLight.WinLeft = Left + SW;
	LabelLight.WinTop = Top + (Padding[Resolution] + LH) * 7;
	LabelLight.SetWidth(Canvas, W - Padding[Resolution]);

	LabelClips.WinLeft = Left + SW;
	LabelClips.WinTop = Top + (Padding[Resolution] + LH) * 8;
	LabelClips.SetWidth(Canvas, W - Padding[Resolution]);

	LabelCrazy.WinLeft = LabelTerr.WinLeft;
	LabelCrazy.WinTop = Top + (Padding[Resolution] + LH) * 5;
	LabelCrazy.SetWidth(Canvas, W - Padding[Resolution]);

	LabelShootC4.WinLeft = LabelTerr.WinLeft;
	LabelShootC4.WinTop = Top + (Padding[Resolution] + LH) * 6;
	LabelShootC4.SetWidth(Canvas, W - Padding[Resolution]);

	LabelNadeTimer.WinLeft = LabelTerr.WinLeft;
	LabelNadeTimer.WinTop = Top + (Padding[Resolution] + LH) * 7;
	LabelNadeTimer.SetWidth(Canvas, W - Padding[Resolution]);

	LabelFullKnife.WinLeft = LabelTerr.WinLeft;
	LabelFullKnife.WinTop = Top + (Padding[Resolution] + LH) * 8;
	LabelFullKnife.SetWidth(Canvas, W - Padding[Resolution]);

	LabelRandom.WinLeft = Left + SW;
	LabelRandom.WinTop = Top + (Padding[Resolution] + LH) * 13;
	LabelRandom.SetWidth(Canvas, W - Padding[Resolution]);

	UpDownRandomTime.WinLeft = LabelTerr.WinLeft + SW + Padding[Resolution];
	UpDownRandomTime.WinTop = ButtonWeapon[11].WinTop;
	UpDownRandomTime.SetWidth(Canvas, W * 0.5);

	j = 5;
	for ( i=0; i<4; i++)
	{
		CHKSpec[i].WinLeft = LabelSF.WinLeft + LabelSF.WinWidth / 2 - 2 * Padding[Resolution];
		CHKSpec[i].WinTop = Top + (Padding[Resolution] + LH) * j;
		CHKSpec[i].SetWidth(Canvas, W - Padding[Resolution]);
		j++;
	}

	j = 5;
	for ( i=4; i<9; i++)
	{
		if ( i == 5 )
			continue;
		CHKSpec[i].WinLeft = CHKFreeW[1].WinLeft;
		CHKSpec[i].WinTop = Top + (Padding[Resolution] + LH) * j;
		CHKSpec[i].SetWidth(Canvas, W - Padding[Resolution]);
		j++;
	}

	CHKSpec[5].WinLeft = LabelSF.WinLeft + LabelSF.WinWidth / 2 - 2 * Padding[Resolution];
	CHKSpec[5].WinTop = Top + (Padding[Resolution] + LH) * 13;
	CHKSpec[5].SetWidth(Canvas, W - Padding[Resolution]);

	// settings page
	for (i=0; i<10; i++)
	{
		EditSettings[i].WinLeft = Left + Padding[Resolution];
		if (i==0)
			EditSettings[i].WinTop = Top + Padding[Resolution];
		else
			EditSettings[i].WinTop = EditSettings[i-1].WinTop + EditSettings[i-1].WinHeight + Padding[Resolution];
		EditSettings[i].SetWidth(Canvas, 2 * (W - Padding[Resolution]) + W * 0.4);

		ButtonLoad[i].WinLeft = Left + 2*Padding[Resolution] + 2 * W - Padding[Resolution] + W * 0.8;
		ButtonLoad[i].WinTop = EditSettings[i].WinTop + 19;
		ButtonLoad[i].SetWidth(Canvas, W * 0.4);

		ButtonSave[i].WinLeft = Left + Padding[Resolution] + 2 * W - Padding[Resolution] + W * 0.4;
		ButtonSave[i].WinTop = EditSettings[i].WinTop + 19;
		ButtonSave[i].SetWidth(Canvas, W * 0.4);
	}

}

simulated function Notify (UWindowDialogControl Control, byte Event)
{
	local int i;

 	//close
 	if ( Control == ButtonClose )
 	{
 		if ( Event == DE_Click )
 		{
 			OwnerInterface.Hide();
 			Clearup();
 		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintCloseButton;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
 	}
 	//Next Page
 	if ( Control == ButtonNextPage )
 	{
 		if ( Event == DE_Click )
 		{
 			CloseCurrentPage();
 			CurrentPage++;
 			if ( CurrentPage >= MaxPages )
 				CurrentPage = 0;
 			OpenCurrentPage();
 		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintNextPage;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
 	}
 	//Prev Page
 	if ( Control == ButtonPrevPage )
 	{
 		if ( Event == DE_Click )
 		{
 			CloseCurrentPage();
 			CurrentPage--;
 			if ( CurrentPage < 0 )
 				CurrentPage = MaxPages - 1;
 			OpenCurrentPage();
 		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintPrevPage;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
 	}
 	//Weapons
 	for ( i=0; i<31; i++)
 	{
	 	if ( Control == ButtonWeapon[i] )
	 	{
	 		if ( Event == DE_Click )
	 		{
	 			if ( TabComm != none )
	 			{
	 				Send_Weapon(i, true);
	 			}
	 		}
			else if (event == DE_MouseMove)
			{
				Hint = WeaponName[i];
				AltHint = TextButtonWeapon;
			}
			else if (event == DE_MouseLeave)
			{
				Hint = TextHintDefault;
				AltHint = TextHintDefaultAlt;
			}
	 	}
	 	else if (Control == CHKSFW[i])
	 	{
	 		if ( event == DE_Click )
	 		{
	 			if ( TabComm != none )
	 			{
	 				Send_Weapon(i);
	 			}
	 		}
			else if (event == DE_MouseMove)
			{
				Hint = WeaponName[i];
				if ( i == 0 )
					AltHint = TextOICWSF;
				else AltHint = TextSFWeapon;
			}
			else if (event == DE_MouseLeave)
			{
				Hint = TextHintDefault;
				AltHint = TextHintDefaultAlt;
			}
	 	}
	 	else if (Control == CHKTerrW[i])
	 	{
	 		if ( event == DE_Click )
	 		{
	 			if ( TabComm != none )
	 			{
	 				Send_Weapon(i);
	 			}
	 		}
			else if (event == DE_MouseMove)
			{
				Hint = WeaponName[i];
				if ( i == 0 )
					AltHint = TextOICWTerr;
				else
				AltHint = TextTerrWeapon;
			}
			else if (event == DE_MouseLeave)
			{
				Hint = TextHintDefault;
				AltHint = TextHintDefaultAlt;
			}
	 	}
	 	else if (Control == CHKFreeW[i])
	 	{
	 		if ( event == DE_Click )
	 		{
	 			if ( TabComm != none )
	 			{
	 				Send_Weapon(i);
	 			}
	 		}
			else if (event == DE_MouseMove)
			{
				Hint = WeaponName[i];
				AltHint = TextFreeWeapon;
			}
			else if (event == DE_MouseLeave)
			{
				Hint = TextHintDefault;
				AltHint = TextHintDefaultAlt;
			}
	 	}
	}
 	//Items
 	for ( i=0; i<6; i++)
 	{
	 	if ( Control == CHKFreeI[i] )
	 	{
	 		if ( Event == DE_Click )
	 		{
	 			if ( TabComm != none )
	 			{
	 				Send_Item(i);
	 			}
	 		}
			else if (event == DE_MouseMove)
			{
				Hint = TextFreeItem;
				AltHint = AltTextFreeItem[i];
			}
			else if (event == DE_MouseLeave)
			{
				Hint = TextHintDefault;
				AltHint = TextHintDefaultAlt;
			}
	 	}
	}
 	//Specs
 	for ( i=0; i<9; i++)
 	{
	 	if ( Control == CHKSpec[i] )
	 	{
	 		if ( Event == DE_Click )
	 		{
	 			if ( TabComm != none )
	 			{
	 				Send_Special(i);
	 			}
	 		}
			else if (event == DE_MouseMove)
			{
				switch(i)
				{
					case 0: Hint = TextFullAmmo;
							AltHint = TextFullAmmo;
							break;
					case 1: Hint = TextC4;
							AltHint = TextC4;
							break;
					case 2: Hint = TextLightGuns;
							AltHint = TextLightGuns;
							break;
					case 3: Hint = TextPickClips;
							AltHint = TextPickClips;
							break;
					case 4: Hint = TextCrazyAmmo;
							AltHint = TextCrazyAmmo;
							break;
					case 5: Hint = TextRandomGun;
							AltHint = AltTextRandomGun;
							break;
					case 6: Hint = TextShootableC4;
							AltHint = TextShootableC4;
							break;
					case 7: Hint = TextNadeTimer;
							AltHint = TextNadeTimer;
							break;
					case 8: Hint = TextFullKnife;
							AltHint = TextFullKnife;
							break;
				}
			}
			else if (event == DE_MouseLeave)
			{
				Hint = TextHintDefault;
				AltHint = TextHintDefaultAlt;
			}
	 	}
	}
	if ( Control == UpDownRandomTime )
 	{
 		if ( Event == DE_Click )
 		{
 			if ( TabComm != none )
 			{
 				Send_Special(5);
 			}
 		}
		else if (event == DE_MouseMove)
		{
			Hint = TextRandomTime;
			AltHint = AltTextRandomTime;
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
 	}
 	//Load/Save
 	for ( i=0; i<10; i++)
 	{
	 	if (Control == ButtonLoad[i])
	 	{
	 		if ( Event == DE_Click )
	 		{
	 			if ( TabComm != none )
	 			{
	 				Send_Settings(i, 0);
	 			}
	 		}
			else if (event == DE_MouseMove)
			{
				Hint = EditSettings[i].GetValue();
				AltHint = TextLoadSettings;
			}
			else if (event == DE_MouseLeave)
			{
				Hint = TextHintDefault;
				AltHint = TextHintDefaultAlt;
			}
	 	}
	 	else if (Control == ButtonSave[i])
	 	{
	 		if ( Event == DE_Click )
	 		{
	 			if ( TabComm != none )
	 			{
	 				Send_Settings(i, 1);
	 			}
	 		}
			else if (event == DE_MouseMove)
			{
				Hint = EditSettings[i].GetValue();
				AltHint = TextSaveSettings;
			}
			else if (event == DE_MouseLeave)
			{
				Hint = TextHintDefault;
				AltHint = TextHintDefaultAlt;
			}
	 	}
	 	else if (Control == EditSettings[i])
	 	{
			if (event == DE_MouseMove)
			{
				Hint = EditSettings[i].GetValue();
				AltHint = TextSettings;
			}
			else if (event == DE_MouseLeave)
			{
				Hint = TextHintDefault;
				AltHint = TextHintDefaultAlt;
			}
	 	}
	}
}

simulated function Send_Weapon(int Weapon, optional bool def)
{
	local int Team;

	Team = 0;

	if ( def )
	{
		if ( weapon == 0 )
			TabComm.SendMessage(552, Weapon, 4);
		else
			TabComm.SendMessage(552, Weapon, WeaponTeam[Weapon], 0);
		TabComm.SendMessage(551, Weapon);
	}
	else
	{
		if ( CHKSFW[Weapon].bChecked )
		{
			if ( CHKTerrW[Weapon].bChecked )
				Team = 1;
			else Team = 2;
		}
		else if ( CHKTerrW[Weapon].bChecked )
			Team = 3;

		TabComm.SendMessage(552, Weapon, Team, int(CHKFreeW[Weapon].bChecked));
		TabComm.SendMessage(551, Weapon);
		if ( weapon == 28 && team == 0 )//desactivate gasmask
		{
			TabComm.SendMessage(552, 55, 0, 0);
			TabComm.SendMessage(551, 55);
		}
	}
}

simulated function Send_Item(int Item)
{
	TabComm.SendMessage(552, 50+Item, 0, int(CHKFreeI[Item].bChecked));
	TabComm.SendMessage(551, 50+Item);
	if ( item == 5 && !CHKTerrW[28].bChecked && !CHKSFW[28].bChecked )//activate gas nade
	{
		TabComm.SendMessage(552, 28, 1, 0);
		TabComm.SendMessage(551, 28);
	}
}

simulated function Send_Special(int Spec)
{
	TabComm.SendMessage(552, 40+Spec, UpDownRandomTime.Value, int(CHKSpec[Spec].bChecked));
	TabComm.SendMessage(551, 40+Spec);
	if ( Spec == 4 )
		TabComm.SendMessage(551, 40);
	if ( Spec == 0 )
		TabComm.SendMessage(551, 44);
}

simulated function Send_Settings(int ID, int Action)
{
	if (Action == 0 )
		TabComm.SendMessage(554, ID);
	else TabComm.SendMessage(555, ID,,, EditSettings[ID].GetValue());

	TabComm.SendMessage(553, ID);
}

defaultproperties
{
	ShowNav=true
	TabCommClass=class'TOSTWeaponsClient'
	TabName="TOST WeaponsTab"

	WeaponName(0)="OICW in map"
    WeaponName(1)="Glock 21"
    WeaponName(2)="Beretta 92F"
    WeaponName(3)="Desert Eagle"
    WeaponName(4)="Raging Bull"
    WeaponName(5)="SMG II"
    WeaponName(6)="Ingram MAC 10"
    WeaponName(7)="Mossberg"
    WeaponName(8)="SPAS 12"
    WeaponName(9)="MP5A2"
    WeaponName(10)="MP5 SD"
    WeaponName(11)="Saiga 12"
    WeaponName(12)="AK-47"
    WeaponName(13)="M4A1"
    WeaponName(14)="FAMAS F1"
    WeaponName(15)="M16A2"
    WeaponName(16)="MSG 90"
    WeaponName(17)="HK 33"
    WeaponName(18)="Sig 551"
    WeaponName(19)="Steyr Aug"
    WeaponName(20)="Parker-Hale 85"
    WeaponName(21)="M60"
    WeaponName(22)="M4A2m203"
    WeaponName(23)="OICW"
    WeaponName(24)="Conc. Grenade"
    WeaponName(25)="FlashBang"
    WeaponName(26)="Smoke Grenade"
    WeaponName(27)="HE Grenade"
    WeaponName(28)="Teargas Grenade"
    WeaponName(29)="Laser C4"
    WeaponName(30)="Timer C4"

	WeaponTeam(0)=0
	WeaponTeam(1)=3
	WeaponTeam(2)=2
	WeaponTeam(3)=1
	WeaponTeam(4)=2
	WeaponTeam(5)=2
	WeaponTeam(6)=3
	WeaponTeam(7)=3
	WeaponTeam(8)=2
	WeaponTeam(9)=3
	WeaponTeam(10)=2
	WeaponTeam(11)=3
	WeaponTeam(12)=3
	WeaponTeam(13)=2
	WeaponTeam(14)=0
	WeaponTeam(15)=1
	WeaponTeam(16)=1
	WeaponTeam(17)=3
	WeaponTeam(18)=2
	WeaponTeam(19)=0
	WeaponTeam(20)=2
	WeaponTeam(21)=3
	WeaponTeam(22)=2
	WeaponTeam(23)=0
	WeaponTeam(24)=1
	WeaponTeam(25)=1
	WeaponTeam(26)=1
	WeaponTeam(27)=1
	WeaponTeam(28)=0
	WeaponTeam(29)=0
	WeaponTeam(30)=0

	MaxPages=5

	TextHintDefault="Select your actions"
	TextHintDefaultAlt="You need privileges to perform any of these actions"

	TextHintNextPage="Goto next page"
	TextHintPrevPage="Goto previous page"

	TextHintCloseButton="Click to close weapon menu"

	TextButtonWeapon="Click to set default value for this weapon"
	TextTerrWeapon="Click to allow / disallow Terr to buy this weapon"
	TextSFWeapon="Click to allow / disallow SF to buy this weapon"
	TextFreeWeapon="Click to set this weapon free / unfree"
	TextFreeItem="Click to set this item free / unfree"
	AltTextFreeItem(0)="Helmet"
	AltTextFreeItem(1)="Vest"
	AltTextFreeItem(2)="Legs"
	AltTextFreeItem(3)="NightVision"
	AltTextFreeItem(4)="Binoculars"
	AltTextFreeItem(5)="TearGas Mask"

	TextOICWTerr="Click to allow / disallow Terr to take OICW"
	TextOICWSF="Click to allow / disallow SF to take OICW"
	TextFullAmmo="Click to enable / disable fully loaded guns when free"
	TextC4="Click to enable / disable in map c4"
	TextLightGuns="Click to enable / disable light weapons"
	TextShootableC4="Click to enable / disable shootable C4"
	TextNadeTimer="Click to enable / disable Nade Timer"
	TextFullKnife="Click to enable / disable Free full knife"
	TextPickClips="Click to allow / disallow players to only take clips of lost guns"
	TextCrazyAmmo="Click to enable / disable CrazyAmmo (insane clips)"
	TextRandomGun="Click to enable / disable guns randomization"
	AltTextRandomGun="Apply on selected weapons. On all guns if none are selected"
	TextRandomTime="Select time between guns randomization"
	AltTextRandomTime="if \"0\" then randomization only occurd at map start"

	TextLoadSettings="Click to load these settings"
	TextSaveSettings="Click to save these settings"
	TextSettings="Type here the name of these settings"
}
