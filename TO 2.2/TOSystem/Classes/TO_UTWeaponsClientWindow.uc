//=============================================================================
// TO_UTWeaponsClientWindow
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_UTWeaponsClientWindow expands UMenuPageWindow;

// Random
var UWindowCheckbox		RandomCheck;
var localized string	RandomText;
var localized string	RandomHelp;

var UWindowComboControl WCombo[11];	
var localized string Weapons[2];	
var localized string WText[11];
var localized string WHelp;

// Default Button
var UWindowSmallButton DefaultButton;
var localized string DefaultText;
var localized string DefaultHelp;

// Remove Button
var UWindowSmallButton RemoveButton;
var localized string RemoveText;
var localized string RemoveHelp;

var	class<TO_Replacer>	ReplacerClass;

var int Y;

 
///////////////////////////////////////
// Created
///////////////////////////////////////

function Created()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, X;
  local int i, j, cOff;

  Super.Created();

	ReplacerClass = class<TO_Replacer>(DynamicLoadObject("TOSystem.TO_Replacer", class'Class' ));
	if ( ReplacerClass == None )
		log("TO_UTWeaponsClientWindow::Created - ReplacerClass == None");

	ControlWidth = WinWidth/1.5;
	ControlLeft = WinWidth/2 - ControlWidth/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	RandomCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, 20, ControlWidth, 1));
	RandomCheck.SetText(RandomText);
	RandomCheck.SetHelpText(RandomHelp);
	RandomCheck.SetFont(F_Normal);
	RandomCheck.Align = TA_Left;

	Y = 50;

  // Weapon 1 - 10
  for (i=0; i < ArrayCount(WCombo); i++)
  {
    WCombo[i] = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, Y, ControlWidth, 1));
		WCombo[i].SetText(WText[i]);
    WCombo[i].SetHelpText(WHelp $ " " $ WText[i]);
    WCombo[i].SetEditable(False);
    WCombo[i].SetFont(F_Normal);
    for (j=0; j < class'TOModels.TO_WeaponsHandler'.default.NumWeapons + 3; j++)
		{
			if (j == 1)
				WCombo[i].AddItem(WText[i]);
			else
			{
				if (j > 1)
				{
					if (class'TOModels.TO_WeaponsHandler'.default.WeaponName[j-2] != "")
						WCombo[i].AddItem(class'TOModels.TO_WeaponsHandler'.default.WeaponName[j-2]);
				}
				else
					WCombo[i].AddItem(Weapons[j]);
			}
		}
    WCombo[i].SetSelectedIndex(1);
    WCombo[i].SetSize(220, 1);
    WCombo[i].WinLeft = CenterPos;
    WCombo[i].EditBoxWidth = 120;
		WCombo[i].List.MaxVisible = Min(class'TOModels.TO_WeaponsHandler'.default.NumWeapons, 8);
		//RandomCheck.Align = TA_Left;
    Y += 20;
  }

  // Default Button
  Y += 20;
  X = CenterPos;
  DefaultButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', X, Y, 48, 16));
  DefaultButton.SetText(DefaultText);
  DefaultButton.SetFont(F_Normal);
  DefaultButton.SetHelpText(DefaultHelp);
	DefaultButton.Align = TA_Right;
  X += 70;

	/*// Remove Button
	RemoveButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', w, ControlOffset, 48, 16));
    RemoveButton.SetText(RemoveText);
    RemoveButton.SetFont(F_Normal);
    RemoveButton.SetHelpText(RemoveHelp);*/

  // Setup all elements by using the configs
  SetSavedValues();
}


//////////////////////////////////////
// BeforePaint
///////////////////////////////////////

function BeforePaint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;
	local	int	i;

	Super.BeforePaint(C, X, Y);

	ControlWidth = WinWidth/1.5;
	ControlLeft = WinWidth/2 - ControlWidth/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	if ( RandomCheck != None )
	{
		RandomCheck.SetSize(ControlWidth, 1);
		RandomCheck.WinLeft = ControlLeft;
	}

	for (i=0; i < ArrayCount(WCombo); i++)
  {
		if (WCombo[i] != None)
		{
			WCombo[i].SetSize(220, 1);
			WCombo[i].WinLeft = CenterPos;
		}
		//WCombo[i].SetSize(ControlWidth, 1);
		//WCombo[i].WinLeft = ControlLeft;
	}

//	DefaultButton.SetSize(ControlWidth, 1);
	if ( DefaultButton != None )
		DefaultButton.WinLeft = CenterPos;
}


///////////////////////////////////////
// Notify
///////////////////////////////////////

function Notify(UWindowDialogControl C, byte E)
{
    super.Notify(C, E);

    switch(E)
    {
		case DE_Change:
			switch(C)
			{
				case RandomCheck:
					RandomChanged();
					break;
			}

    case DE_Click:
        switch(C)
        {
            case DefaultButton:
                SetDefault();
                break;

            case RemoveButton:
                RemoveWeapons();
                break;
        }
    }
}


///////////////////////////////////////
// RandomChanged
///////////////////////////////////////

function RandomChanged()
{

}


///////////////////////////////////////
// Close
///////////////////////////////////////

function Close(optional bool bByParent)
{
    local int i;

		ReplacerClass.default.bRand = RandomCheck.bChecked;
    for (i=0; i < ArrayCount(WCombo); i++)
        ReplacerClass.default.ReplaceIndex[i] = WCombo[i].GetSelectedIndex() - 2;

    ReplacerClass.SaveConfig();
    ReplacerClass.static.StaticSaveConfig();
		GetPlayerOwner().SaveConfig();

    Super.Close(bByParent);
}


///////////////////////////////////////
// SetSavedValues
///////////////////////////////////////

function SetSavedValues()
{
  local int i;

	RandomCheck.bChecked = ReplacerClass.default.bRand;

  for (i=0; i < ArrayCount(WCombo); i++)
		WCombo[i].SetSelectedIndex( ReplacerClass.default.ReplaceIndex[i] + 2 );
}


///////////////////////////////////////
// SetDefault
///////////////////////////////////////

function SetDefault()
{
  local int i;

	for (i=0; i < ArrayCount(WCombo); i++)
		WCombo[i].SetSelectedIndex(i + 2); 
}


///////////////////////////////////////
// RemoveWeapons
///////////////////////////////////////

function RemoveWeapons()
{
  local int i;

	for (i=0; i < ArrayCount(WCombo); i++)
		WCombo[i].SetSelectedIndex(0);
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     RandomText="Force random"
     RandomHelp="Randomize all weapons in the level."
     Weapons(0)="Remove weapon"
     WText(0)="Enforcer (Default)"
     WText(1)="Bio Rifle"
     WText(2)="Shock Rifle"
     WText(3)="Pulse Gun"
     WText(4)="Ripper"
     WText(5)="Minigun"
     WText(6)="Flak Cannon"
     WText(7)="Rocket Launcher"
     WText(8)="Sniper Rifle"
     WText(9)="Redeemer"
     WText(10)="Chainsaw"
     WHelp="Select weapon to replace the "
     DefaultText="Default"
     DefaultHelp="Default weapon exchange setup."
     RemoveText="Remove"
     RemoveHelp="Remove all weapons."
}
