//=============================================================================
// TO_ControlsClientWindow
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_ControlsClientWindow expands UMenuCustomizeClientWindow;

var int VoiceKeyNumber;
var int ConsoleKeyNumber;
var	int	UseKeyNumber;


function Created()
{
	local int ButtonWidth, ButtonLeft, ButtonTop, I, J, pos;
	local int LabelWidth, LabelLeft;
	local UMenuLabelControl Heading;
	local bool bTop;

	bIgnoreLDoubleClick = True;
	bIgnoreMDoubleClick = True;
	bIgnoreRDoubleClick = True;

	bJoystick =	bool(GetPlayerOwner().ConsoleCommand("get windrv.windowsclient usejoystick"));

	Super(UMenuPageWindow).Created();

	SetAcceptsFocus();

	ButtonWidth = WinWidth - 140;
	ButtonLeft = WinWidth - ButtonWidth - 40;

	LabelWidth = WinWidth - 100;
	LabelLeft = 20;

	// Defaults Button
	DefaultsButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 30, 10, 48, 16));
	DefaultsButton.SetText(DefaultsText);
	DefaultsButton.SetFont(F_Normal);
	DefaultsButton.SetHelpText(DefaultsHelp);
	
	ButtonTop = 25;
	bTop = True;
	for (I=0; I<ArrayCount(AliasNames); I++)
	{
		if (AliasNames[I] == "" )
			continue;

		if ( AliasNames[I] == "stop" )
			break;

		j = InStr(LabelList[I], ",");
		if(j != -1)
		{
			if(!bTop)
				ButtonTop += 10;
			Heading = UMenuLabelControl(CreateControl(class'UMenuLabelControl', LabelLeft-10, ButtonTop+3, WinWidth, 1));
			Heading.SetText(Left(LabelList[I], j));
			Heading.SetFont(F_Bold);
			LabelList[I] = Mid(LabelList[I], j+1);
			ButtonTop += 19;
		}
		bTop = False;

		KeyNames[I] = UMenuLabelControl(CreateControl(class'UMenuLabelControl', LabelLeft, ButtonTop+3, LabelWidth, 1));
		KeyNames[I].SetText(LabelList[I]);
		KeyNames[I].SetHelpText(CustomizeHelp);
		KeyNames[I].SetFont(F_Normal);
		KeyButtons[I] = UMenuRaisedButton(CreateControl(class'UMenuRaisedButton', ButtonLeft, ButtonTop, ButtonWidth, 1));
		KeyButtons[I].SetHelpText(CustomizeHelp);
		KeyButtons[I].bAcceptsFocus = False;
		KeyButtons[I].bIgnoreLDoubleClick = True;
		KeyButtons[I].bIgnoreMDoubleClick = True;
		KeyButtons[I].bIgnoreRDoubleClick = True;
		ButtonTop += 19;
	}
	AliasCount = I;

	NoJoyDesiredHeight = ButtonTop + 10;

	// Joystick
	ButtonTop += 10;
	JoystickHeading = UMenuLabelControl(CreateControl(class'UMenuLabelControl', LabelLeft-10, ButtonTop+3, WinWidth, 1));
	JoystickHeading.SetText(JoystickText);
	JoystickHeading.SetFont(F_Bold);
	LabelList[I] = Mid(LabelList[I], j+1);
	ButtonTop += 19;

	JoyXCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', 20, ButtonTop, WinWidth - 40, 1));
	JoyXCombo.CancelAcceptsFocus();
	JoyXCombo.SetText(JoyXText);
	JoyXCombo.SetHelpText(JoyXHelp);
	JoyXCombo.SetFont(F_Normal);
	JoyXCombo.SetEditable(False);
	JoyXCombo.AddItem(JoyXOptions[0]);
	JoyXCombo.AddItem(JoyXOptions[1]);
	JoyXCombo.EditBoxWidth = ButtonWidth;
	ButtonTop += 20;

	JoyYCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', 20, ButtonTop, WinWidth - 40, 1));
	JoyYCombo.CancelAcceptsFocus();
	JoyYCombo.SetText(JoyYText);
	JoyYCombo.SetHelpText(JoyYHelp);
	JoyYCombo.SetFont(F_Normal);
	JoyYCombo.SetEditable(False);
	JoyYCombo.AddItem(JoyYOptions[0]);
	JoyYCombo.AddItem(JoyYOptions[1]);
	JoyYCombo.EditBoxWidth = ButtonWidth;
	ButtonTop += 20;

	LoadExistingKeys();

	DesiredWidth = 220;
	JoyDesiredHeight = ButtonTop + 10;
	DesiredHeight = JoyDesiredHeight;
}


///////////////////////////////////////
// WindowShown
///////////////////////////////////////

function BeforePaint(Canvas C, float X, float Y)
{
	local int ButtonWidth, ButtonLeft, I;
	local int LabelWidth, LabelLeft;

	ButtonWidth = WinWidth - 135;
	ButtonLeft = WinWidth - ButtonWidth - 20;

	DefaultsButton.AutoWidth(C);
	DefaultsButton.WinLeft = ButtonLeft + ButtonWidth - DefaultsButton.WinWidth;

	LabelWidth = WinWidth - 100;
	LabelLeft = 20;

	if(bJoystick)
	{
		DesiredHeight = JoyDesiredHeight;

		JoystickHeading.ShowWindow();
		JoyXCombo.ShowWindow();
		JoyYCombo.ShowWindow();

		JoyXCombo.SetSize(WinWidth - 40, 1);
		JoyXCombo.EditBoxWidth = ButtonWidth;

		JoyYCombo.SetSize(WinWidth - 40, 1);
		JoyYCombo.EditBoxWidth = ButtonWidth;
	}
	else
	{
		DesiredHeight = NoJoyDesiredHeight;

		JoystickHeading.HideWindow();
		JoyXCombo.HideWindow();
		JoyYCombo.HideWindow();
	}

	for (I=0; I<AliasCount; I++)
	{
		if ( KeyButtons[I] != None )
		{
			KeyButtons[I].SetSize(ButtonWidth, 1);
			KeyButtons[I].WinLeft = ButtonLeft;
		}

		if ( KeyNames[I] != None )
		{
			KeyNames[I].SetSize(LabelWidth, 1);
			KeyNames[I].WinLeft = LabelLeft;
		}
	}

	for (I=0; I<AliasCount; I++ )
	{
		if ( KeyButtons[I] != None )
		{
			if ( BoundKey1[I] == 0 )
				KeyButtons[I].SetText("");
			else
				if ( BoundKey2[I] == 0 )
				KeyButtons[I].SetText(LocalizedKeyName[BoundKey1[I]]);
			else
				KeyButtons[I].SetText(LocalizedKeyName[BoundKey1[I]]$OrString$LocalizedKeyName[BoundKey2[I]]);
		}
	}
}


///////////////////////////////////////
// WindowShown
///////////////////////////////////////

function WindowShown()
{
	Super.WindowShown();
	Root.bAllowConsole = false;
}


///////////////////////////////////////
// WindowHidden
///////////////////////////////////////

function WindowHidden()
{
	Super.WindowHidden();
	Root.bAllowConsole = true;
}


///////////////////////////////////////
// LoadExistingKeys
///////////////////////////////////////

function LoadExistingKeys()
{
	Super.LoadExistingKeys();

	if(Root.Console.IsA('TO_Console'))
	{
		BoundKey1[VoiceKeyNumber] = TO_Console(Root.Console).SpeechKey;
		BoundKey1[UseKeyNumber] = TO_Console(Root.Console).UseKey;
	}

	BoundKey1[ConsoleKeyNumber] = Root.Console.ConsoleKey;
}


///////////////////////////////////////
// SetKey
///////////////////////////////////////

function SetKey(int KeyNo, string KeyName)
{
	if (Selection == UseKeyNumber)
	{
		if(KeyNo != 1 && KeyNo != 27 && Root.Console.IsA('TO_Console'))
		{
			TO_Console(Root.Console).UseKey = KeyNo;
			Root.Console.SaveConfig();

			BoundKey1[Selection] = KeyNo;
			BoundKey2[Selection] = 0;
		}
	}
	else if (Selection == VoiceKeyNumber)
	{
		if(KeyNo != 1 && KeyNo != 27 && Root.Console.IsA('TO_Console'))
		{
			TO_Console(Root.Console).SpeechKey = KeyNo;
			Root.Console.SaveConfig();

			BoundKey1[Selection] = KeyNo;
			BoundKey2[Selection] = 0;
		}
	}
	else if(Selection == ConsoleKeyNumber)
	{
		if(KeyNo != 1 && KeyNo != 27) // LeftMouse, Escape
		{
			Root.Console.ConsoleKey = KeyNo;
			Root.Console.SaveConfig();

			BoundKey1[Selection] = KeyNo;
			BoundKey2[Selection] = 0;
		}
	}
	else
	{
		if (Root.Console.IsA('TO_Console') && KeyNo == TO_Console(Root.Console).SpeechKey)
		{
			TO_Console(Root.Console).UseKey = 0;
			Root.Console.SaveConfig();
			BoundKey1[UseKeyNumber] = 0;	
		}
		if (KeyNo == Root.Console.ConsoleKey)
		{
			Root.Console.ConsoleKey = 0;
			Root.Console.SaveConfig();
			BoundKey1[ConsoleKeyNumber] = 0;	
		}
		if (Root.Console.IsA('TO_Console') && KeyNo == TO_Console(Root.Console).SpeechKey)
		{
			TO_Console(Root.Console).SpeechKey = 0;
			Root.Console.SaveConfig();
			BoundKey1[VoiceKeyNumber] = 0;	
		}
		Super.SetKey(KeyNo, KeyName);
	}
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////
/*
     LabelList(13)="Center View"
	      LabelList(16)="Feign Death"
*/

defaultproperties
{
     VoiceKeyNumber=19
     ConsoleKeyNumber=40
     UseKeyNumber=44
     LabelList(0)="Controls,Fire"
     LabelList(4)="Strafe Left"
     LabelList(5)="Strafe Right"
     LabelList(6)="Turn Left"
     LabelList(7)="Turn Right"
     LabelList(11)="Look Up"
     LabelList(12)="Look Down"
     LabelList(14)="Walk"
     LabelList(15)="Strafe"
     LabelList(17)="Taunts / Chat,Say"
     LabelList(18)="Team Say"
     LabelList(19)="Show Voice Menu"
     LabelList(20)="Thrust"
     LabelList(21)="Wave"
     LabelList(22)="Victory1"
     LabelList(23)="Victory2"
     LabelList(24)="Weapons,Next Weapon"
     LabelList(25)="Previous Weapon"
     LabelList(26)="Throw Weapon"
     LabelList(27)="Select Best Weapon"
     LabelList(28)="View from Teammate,Teammate 1"
     LabelList(29)="Teammate 2"
     LabelList(30)="Teammate 3"
     LabelList(31)="Teammate 4"
     LabelList(32)="Teammate 5"
     LabelList(33)="Teammate 6"
     LabelList(34)="Teammate 7"
     LabelList(35)="Teammate 8"
     LabelList(36)="Teammate 9"
     LabelList(37)="Teammate 10"
     LabelList(38)="HUD,Increase HUD"
     LabelList(39)="Decrease HUD"
     LabelList(40)="Console,Console Key"
     LabelList(41)="Quick Console Key"
     LabelList(42)="Tactical Ops Specific Keys,Reload weapon"
     LabelList(43)="Buy Primary Ammo"
     LabelList(44)="Use key"
     LabelList(45)="Nightvision toggle"
     LabelList(46)="Display Objectives"
     LabelList(47)="Switch fire mode"
     LabelList(48)="Switch flashlight"
     AliasNames(4)="StrafeLeft"
     AliasNames(5)="StrafeRight"
     AliasNames(6)="TurnLeft"
     AliasNames(7)="TurnRight"
     AliasNames(11)="LookUp"
     AliasNames(12)="LookDown"
     AliasNames(13)=""
     AliasNames(14)="Walking"
     AliasNames(15)="Strafe"
     AliasNames(16)=""
     AliasNames(17)="Talk"
     AliasNames(18)="TeamTalk"
     AliasNames(19)="None"
     AliasNames(20)="taunt thrust"
     AliasNames(21)="taunt wave"
     AliasNames(22)="taunt taunt1"
     AliasNames(23)="taunt victory1"
     AliasNames(24)="NextWeapon"
     AliasNames(25)="PrevWeapon"
     AliasNames(26)="ThrowWeapon"
     AliasNames(27)="switchtobestweapon"
     AliasNames(28)="ViewPlayerNum 0"
     AliasNames(29)="ViewPlayerNum 1"
     AliasNames(30)="ViewPlayerNum 2"
     AliasNames(31)="ViewPlayerNum 3"
     AliasNames(32)="ViewPlayerNum 4"
     AliasNames(33)="ViewPlayerNum 5"
     AliasNames(34)="ViewPlayerNum 6"
     AliasNames(35)="ViewPlayerNum 7"
     AliasNames(36)="ViewPlayerNum 8"
     AliasNames(37)="ViewPlayerNum 9"
     AliasNames(38)="GrowHUD"
     AliasNames(39)="ShrinkHUD"
     AliasNames(40)="None"
     AliasNames(41)="Type"
     AliasNames(42)="s_kReload"
     AliasNames(43)="s_kAmmo"
     AliasNames(44)="None"
     AliasNames(45)="s_kNightVision"
     AliasNames(46)="s_kShowObjectives"
     AliasNames(47)="s_kChangeFireMode"
     AliasNames(48)="s_kFlashlight"
     AliasNames(49)="stop"
}
