//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTGUIBaseListBox.uc
// Version : 4.0
// Author  : BugBunny (based on code by J3rky)
//----------------------------------------------------------------------------
// Version	Changes
// 4.0		+ First Release
//----------------------------------------------------------------------------

class TOSTGUIBaseListbox expands UWindowDialogControl abstract;

// links
var TO_GUIBaseMgr	OwnerInterface;
var PlayerPawn		OwnerPlayer;
var s_Hud			OwnerHud;
var TO_GUIBaseTab	OwnerTab;

// items
var int			ItemsData[251];
var byte		Selected[251];		// LBSEL_NO, LBSEL_YES
var byte		Grouped[251];
var byte		MaxItems, NumItems, NumVisItems;
var byte		SelectedIndex, TopIndex, MouseoverIndex, DoubleclickIndex;

// dimensions
var float		ClientTop, ClientCenter, ClientHeight, ClientWidth;
var float		ItemHeight, ItemSpacing;
var font		ItemFont;

// options
var bool		bMultiselect, PlaySound;

// -consts-

// item types
const LBIT_NONE 		= 253;
const LBIT_SCROLLUP 	= 254;
const LBIT_SCROLLDOWN 	= 255;

// selections
const LBSEL_NO 	= 0;
const LBSEL_YES = 1;

// -operators-

// color
native(552) static final operator(16) color *( color A, float B );


// -methods (engine)-

// * Created
simulated function Created ()
{
	OwnerPlayer = GetPlayerOwner();
	OwnerHud = s_Hud(OwnerPlayer.myHud);
	OwnerInterface = OwnerHud.UserInterface;

	Super.Created();
}

// * Close
simulated function Close (optional bool bByParent)
{
	OwnerPlayer = None;
	OwnerHud = None;
	OwnerInterface = None;

	Super.Close(bByParent);
}

// * BeforePaint
simulated function BeforePaint (Canvas Canvas, float x, float y)
{
	// implemented in child class
}

// * Paint
simulated function Paint (Canvas Canvas, float x, float y)
{
	// implemented in child class
}

// * MouseMove
function MouseMove (float x, float y)
{
	local int	i;

	i = GetItemAt(x, y);
	if (i != LBIT_NONE)
	{
		MouseoverIndex = i;
		Cursor = Root.HandCursor;
	}
	else
	{
		MouseoverIndex = LBIT_NONE;
		Cursor = Root.NormalCursor;
	}

	if (OwnerTab != None)
	{
		OwnerTab.Notify(self, DE_MouseMove);
	}
}

// * MouseLeave
function MouseLeave ()
{
	Super.MouseLeave();
	MouseoverIndex = LBIT_NONE;

	if (OwnerTab != None)
	{
		OwnerTab.Notify(self, DE_MouseLeave);
	}
}


// * Click
function Click (float x, float y)
{
	local int				i;

	Super.LMouseDown(x, y);

	i = GetItemAt(x, y);

	if (i == LBIT_SCROLLUP)
	{
		TopIndex = Max(0, TopIndex-1);
		return;
	}
	if (i == LBIT_SCROLLDOWN)
	{
		TopIndex = Max(0, Min(NumItems-NumVisItems, TopIndex+1));
		return;
	}

	if (i == LBIT_NONE)
	{
		return;
	}

	if ( !bMultiselect && (i != SelectedIndex) )
	{
		if (SelectedIndex != LBIT_NONE)
		{
			Selected[SelectedIndex] = LBSEL_NO;
		}

		Selected[i] = LBSEL_YES;
		SelectedIndex = i;
	}
	else
	{
		if (Selected[i] == LBSEL_NO)
		{
			Selected[i] = LBSEL_YES;
		}
		else
		{
			Selected[i] = LBSEL_NO;
		}

		if (Selected[i] == LBSEL_YES)
		{
			SelectedIndex = i;
		}
		else
		{
			SelectedIndex = LBIT_NONE;
		}
	}

	if (OwnerTab != None)
	{
		OwnerTab.Notify(self, DE_Click);
	}

	if (PlaySound)
	{
		OwnerPlayer.PlaySound(Sound'LightSwitch', SLOT_None);
	}
}

// * RClick
function RClick (float x, float y)
{
	local int				i;

	Super.LMouseDown(x, y);

	i = GetItemAt(x, y);

	if (i == LBIT_SCROLLUP)
	{
		TopIndex = Max(0, TopIndex-NumVisItems+1);
		return;
	}
	if (i == LBIT_SCROLLDOWN)
	{
		TopIndex = Max(0, Min(NumItems-NumVisItems, TopIndex+NumVisItems-1));
		return;
	}
}

// * DoubleClick
function DoubleClick (float x, float y)
{
	local int				i;

	i = GetItemAt(x, y);
	if (i == LBIT_NONE)
	{
		return;
	}
/*	if (i == LBIT_SCROLLUP)
	{
		TopIndex = 0;
		return;
	}
	if (i == LBIT_SCROLLDOWN)
	{
		TopIndex = Max(0, NumItems-NumVisItems);
		return;
	}*/

	if (bMultiselect && (Grouped[i] == LBSEL_YES) )
	{
		for (i = 0; i < NumItems; i++)
		{
			if (Grouped[i] == LBSEL_YES)
			{
				Selected[i] = LBSEL_YES;
			}
		}
	}

	if (OwnerTab != None)
	{
		DoubleclickIndex = i;
		OwnerTab.Notify(self, DE_DoubleClick);
	}
}


// -methods (exported)-

// * Add
simulated function byte Add (int data, bool sel, optional bool group)
{
	if (NumItems >= MaxItems)
	{
		return LBIT_NONE;
	}

	ItemsData[NumItems] = data;
	if (sel)
	{
		Selected[NumItems] = LBSEL_YES;
		SelectedIndex = NumItems;
	}
	else
	{
		Selected[NumItems] = LBSEL_NO;
	}
	if (group)
	{
		Grouped[NumItems] = LBSEL_YES;
	}
	else
	{
		Grouped[NumItems] = LBSEL_NO;
	}
	NumItems++;

	return NumItems-1;
}

// * Clear
simulated function Clear ()
{
	NumItems = 0;
	TopIndex = 0;
	SelectedIndex = LBIT_NONE;
}

// * SetLength
simulated function SetLength (byte len)
{
	NumVisItems = len;
}

// * FindData
simulated function int FindData(int data)
{
	local int	i;

	for (i=0; i<NumItems; i++)
	{
		if (data == ItemsData[i])
			return i;
	}
	return -1;
}

// * SetWidth
simulated function SetWidth (Canvas Canvas, int width)
{
	WinWidth = width;

	OwnerHUD.Design.SetScoreboardFont(Canvas);

	ItemFont = Canvas.Font;
	ItemSpacing = OwnerHud.Design.LineSpacing + 2;

	ClientCenter = 0.5*WinWidth;
	ClientWidth = WinWidth - 4;

	/* set ClientTop, ItemHeight, ClientHeight & WinHeight in child classes */
}

// * GetSelected
simulated function int GetSelected ()
{
	if (!bMultiselect && (SelectedIndex != LBIT_NONE) )
	{
		return SelectedIndex;
	}
	else
	{
		return -1;
	}
}

// * GetData
simulated function int GetData (byte index)
{
	if (index < NumItems)
	{
		return ItemsData[index];
	}
	else
	{
		return -1;
	}
}

// * IsSelectedByIndex
simulated function bool IsSelectedByIndex (byte index)
{
	if (index < NumItems)
	{
		return Selected[index] == LBSEL_YES;
	}
	else
	{
		return false;
	}
}

// * SetSelectedByIndex
simulated function SetSelectedByIndex (byte index, bool value)
{
	if (index < NumItems)
	{
		if (value)
			Selected[index] = LBSEL_YES;
		else
			Selected[index] = LBSEL_NO;
	}
}


// * IsSelectedByData
simulated function bool IsSelectedByData (int data)
{
	local byte					i;


	for (i = 0; i < NumItems; i++)
	{
		if ( (ItemsData[i] == data) && (Selected[i] == LBSEL_YES) )
		{
			return true;
		}
	}

	return false;
}

// * IsGroupedByIndex
simulated function bool IsGroupedByIndex (byte index)
{
	if (index < NumItems)
	{
		return Grouped[index] == LBSEL_YES;
	}
	else
	{
		return false;
	}
}


// -methods (drawing)-

// * DrawItems
simulated function DrawItems (Canvas Canvas, float y)
{
	local byte					i, c;
	local texture				bg;

	c = Min(NumVisItems, NumItems-TopIndex);
	for (i=TopIndex; i < TopIndex+c; i++)
	{
		// background
		Canvas.SetPos(2, y);
		if (Selected[i] == LBSEL_YES)
		{
			Canvas.DrawColor = OwnerInterface.Design.ColorDarkgreen;
			bg = Texture'tilewhite';
		}
		else if (i == MouseoverIndex)
		{
			Canvas.DrawColor = OwnerInterface.Design.ColorTeam[OwnerPlayer.PlayerReplicationInfo.Team] * 0.7;
			bg = Texture'tilewhite';
		}
		else
		{
			Canvas.DrawColor = OwnerInterface.Design.ColorGrey;
			bg = Texture'debug16';
		}
		Canvas.DrawTile(bg, ClientWidth, ItemHeight, 0, 0, 16, 16);

		// data
		DrawItemData(Canvas, i, y);

		y += ItemHeight + 2;
	}
}


// * DrawItemData
simulated function DrawItemData (Canvas Canvas, byte item, float y)
{
	// implemented in child class
}


// -methods (input)-
simulated function byte GetItemAt (float x, float y)
{
	local int	i;

	if ( (x < 2) || (x > WinWidth-2) || (y < ClientTop) || (y > ClientTop+ClientHeight) )
	{
		return LBIT_NONE;
	}

	i = int( (y-ClientTop) / (ItemHeight+2)) + TopIndex;
	if (i >= Min(TopIndex + NumVisItems, NumItems))
	{
		return LBIT_NONE;
	}

	return i;
}

// -defaultproperties-
defaultproperties
{
	MaxItems=251
	NumItems=0
	NumVisItems=4

	SelectedIndex=253
	MouseoverIndex=253
	DoubleclickIndex=253

	PlaySound=true
}
