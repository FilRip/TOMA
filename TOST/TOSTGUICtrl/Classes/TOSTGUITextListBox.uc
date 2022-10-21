//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTGUITextListBox.uc
// Version : 4.0
// Author  : BugBunny (based on code by J3rky)
//----------------------------------------------------------------------------
// Version	Changes
// 4.0		+ First Release
//----------------------------------------------------------------------------

class TOSTGUITextListBox expands TOSTGUIBaseListBox;

// -properties-

var string					Label;

// items
var string					ItemsText[251];
var string					ItemsHint[251];

// item types
const LBIT_ScrollClick = 252;

// -methods (engine)-

// * Created
simulated function Created ()
{
	Super.Created();
}

// * BeforePaint
simulated function BeforePaint (Canvas Canvas, float x, float y)
{
	// not used
}

// * Paint
simulated function Paint (Canvas Canvas, float x, float y)
{
	local float	ypos;
	local float	xl, yl;
        local float     newClientWidth;

	if ( (OwnerTab != None) && !OwnerTab.bDraw )
	{
		return;
	}

	Canvas.Style = OwnerHUD.ERenderStyle.STY_NORMAL;
	Canvas.DrawColor = OwnerHUD.Design.ColorWhite;

	// Make shure we dont scroll to far
	if (NumItems - NumVisItems < 1)
	  TopIndex = 0;
	else if (NumItems - NumVisItems < TopIndex)
	  TopIndex = NumItems - NumVisItems;

	if (NumVisItems < NumItems)
	  newClientWidth = ClientWidth - 34;
 	else
 	  newClientWidth = ClientWidth;

	// title panel
	ypos = 0;
	DrawPanel(Canvas, ypos, 256, -18, -19, false);
	Canvas.Font = OwnerHud.Design.Font10;
	Canvas.StrLen(Label, xl, yl);
	Canvas.SetPos(ClientCenter-0.5*xl, ypos+5);
	Canvas.DrawText(Label, true);

	// listbox
	ypos += 22;
	OwnerInterface.Tool_DrawBox(Canvas, 2, ypos+2, newClientWidth, ClientHeight-2);

 	// Scroll bar
	DrawGrimsScrollBar(Canvas, Canvas.CurX+2, ypos+2, ClientHeight-2);

	// items
	Canvas.Font = ItemFont;
	DrawItems(Canvas, ypos+2);

	// hint panel
	ypos += ClientHeight + 7;
	DrawPanel(Canvas, ypos, 237, -18, 19, false);
	if (!bMultiselect && (SelectedIndex > LBIT_NONE) )
	{
		Canvas.Font = OwnerHud.Design.Font10;
		Canvas.StrLen(ItemsHint[SelectedIndex], xl, yl);
		if (NumVisItems < NumItems)
			Canvas.SetPos(ClientCenter-34-0.5*xl, ypos+3);
		else
			Canvas.SetPos(ClientCenter-0.5*xl, ypos+3);
		Canvas.DrawText(ItemsHint[SelectedIndex], true);
	}

}

// -methods (exported)-

// * Add
simulated function byte AddItem (string text, string hint, int data, bool sel)
{
	local byte	index;

	index = Super.Add(data, sel);
	if (index == LBIT_NONE)
	{
		return LBIT_NONE;
	}

	ItemsText[index] = text;
	ItemsHint[index] = hint;

	return index;
}

// * SetWidth
simulated function SetWidth (Canvas Canvas, int width)
{
	Super.SetWidth(Canvas, width);

	ClientTop = 23;
	ItemHeight = OwnerHud.Design.LineHeight + 3;
	ClientHeight = NumVisItems*(ItemHeight+ItemSpacing);
	WinHeight = ClientHeight + 44;
}


// * methods (drawing)

simulated function DrawItems (Canvas Canvas, float y)
{
	local byte					i, c;
	local texture				bg;

	if (NumVisItems < NumItems)
 	{
	  ClientWidth = ClientWidth - 34;
	  ClientCenter = ClientCenter - 27;
	}

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

 	//Put back to start
	if (NumVisItems < NumItems)
	{
	  ClientWidth = ClientWidth + 34;
	  ClientCenter = ClientCenter + 27;
  	}
}

// * DrawItemData
simulated function DrawItemData (Canvas Canvas, byte item, float y)
{
	local float	xl, yl;

	if (Selected[item] == LBSEL_YES)
	{
		Canvas.DrawColor = OwnerInterface.Design.ColorDarkgrey;
	}
	else
	{
		Canvas.DrawColor = OwnerInterface.Design.ColorWhite;
	}
	Canvas.StrLen(ItemsText[item], xl, yl);
	Canvas.SetPos(ClientCenter-0.5*xl, y+ItemSpacing);
	Canvas.DrawText(ItemsText[item], true);
}

// * DrawPanel
simulated function DrawPanel(Canvas Canvas, float y, float vt, float vtoffs, float yt, bool scroll)
{
	local float	w;

	w = WinWidth - 34;
	if ((NumVisItems < NumItems) && scroll)
		w = w - 2*34;

	// background
	Canvas.DrawColor = OwnerHud.WhiteColor;

	Canvas.SetPos(17, y);
	Canvas.Style = OwnerHud.ERenderStyle.STY_Translucent;
	Canvas.DrawTile(Texture'hud_elements', w, 19, 17, vt, 16.0, yt);	// bg

	Canvas.SetPos(17, y);
	Canvas.Style = OwnerHud.ERenderStyle.STY_Masked;
	Canvas.DrawTile(Texture'hud_elements', w, 19, 67, vt+vtoffs, 16.0, yt);	// fg

	// background borders
	Canvas.Style = OwnerHud.ERenderStyle.STY_Translucent;			// right
	Canvas.SetPos(Canvas.CurX, y);
	Canvas.DrawTile(Texture'hud_elements', 16, 19, 34, vt, 16.0, yt);
	Canvas.Style = OwnerHud.ERenderStyle.STY_Masked;
	Canvas.SetPos(Canvas.CurX - 17, y);
	Canvas.DrawTile(Texture'hud_elements', 17, 19, 84, vt, 17.0, yt);

	// scroll buttons
	if ((NumVisItems < NumItems) && scroll)
	{
		if (MouseOverIndex == LBIT_SCROLLUP)
			Canvas.DrawColor = OwnerInterface.Design.ColorTeam[OwnerPlayer.PlayerReplicationInfo.Team] * 0.7;
		else
			Canvas.DrawColor = OwnerHud.WhiteColor;

		Canvas.Style = OwnerHud.ERenderStyle.STY_Translucent;		// scroll up
		Canvas.SetPos(Canvas.CurX, y);
		Canvas.DrawTile(Texture'hud_elements', 16, 19, 0, vt+yt, 16.0, -yt);
		Canvas.Style = OwnerHud.ERenderStyle.STY_Masked;
		Canvas.SetPos(Canvas.CurX - 17, y);
		Canvas.DrawTile(Texture'hud_elements', 17, 19, 49, vt+yt, 17.0, -yt);
		Canvas.Style = OwnerHud.ERenderStyle.STY_Translucent;
		Canvas.SetPos(Canvas.CurX+1, y);
		Canvas.DrawTile(Texture'hud_elements', 16, 19, 34, vt+yt, 16.0, -yt);
		Canvas.Style = OwnerHud.ERenderStyle.STY_Masked;
		Canvas.SetPos(Canvas.CurX - 17, y);
		Canvas.DrawTile(Texture'hud_elements', 17, 19, 84, vt+yt, 17.0, -yt);

		if (MouseOverIndex == LBIT_SCROLLDOWN)
			Canvas.DrawColor = OwnerInterface.Design.ColorTeam[OwnerPlayer.PlayerReplicationInfo.Team] * 0.7;
		else
			Canvas.DrawColor = OwnerHud.WhiteColor;

		Canvas.Style = OwnerHud.ERenderStyle.STY_Translucent;		// scroll down
		Canvas.SetPos(Canvas.CurX, y);
		Canvas.DrawTile(Texture'hud_elements', 16, 19, 0, vt, 16.0, yt);
		Canvas.Style = OwnerHud.ERenderStyle.STY_Masked;
		Canvas.SetPos(Canvas.CurX - 17, y);
		Canvas.DrawTile(Texture'hud_elements', 17, 19, 49, vt, 17.0, yt);
		Canvas.Style = OwnerHud.ERenderStyle.STY_Translucent;							// right
		Canvas.SetPos(Canvas.CurX+1, y);
		Canvas.DrawTile(Texture'hud_elements', 16, 19, 34, vt, 16.0, yt);
		Canvas.Style = OwnerHud.ERenderStyle.STY_Masked;
		Canvas.SetPos(Canvas.CurX - 17, y);
		Canvas.DrawTile(Texture'hud_elements', 17, 19, 84, vt, 17.0, yt);
	}

	// background borders
	Canvas.DrawColor = OwnerHud.WhiteColor;

	Canvas.Style = OwnerHud.ERenderStyle.STY_Translucent;							// left
	Canvas.SetPos(1, y);
	Canvas.DrawTile(Texture'hud_elements', 16, 19, 0, vt, 16.0, yt);
	Canvas.Style = OwnerHud.ERenderStyle.STY_Masked;
	Canvas.SetPos(1, y);
	Canvas.DrawTile(Texture'hud_elements', 17, 19, 49, vt, 17.0, yt);
}

simulated function DrawGrimsScrollBar(Canvas Canvas, float X, float y, float MaxHeight)
{
	local float vt,yt, scrH;

	vt = 256;
	yt = -19;

	// scroll buttons
	if (NumVisItems < NumItems)
	{
		if (MouseOverIndex == LBIT_SCROLLUP)
			Canvas.DrawColor = OwnerInterface.Design.ColorTeam[OwnerPlayer.PlayerReplicationInfo.Team] * 0.7;
		else
			Canvas.DrawColor = OwnerHud.WhiteColor;

		Canvas.Style = OwnerHud.ERenderStyle.STY_Translucent;		// scroll up
		Canvas.SetPos(X, y);
		Canvas.DrawTile(Texture'hud_elements', 16, 19, 0, vt, 16.0, yt);
		Canvas.Style = OwnerHud.ERenderStyle.STY_Masked;
		Canvas.SetPos(Canvas.CurX - 17, y);
		Canvas.DrawTile(Texture'hud_elements', 17, 19, 49, vt, 17.0, yt);
		Canvas.Style = OwnerHud.ERenderStyle.STY_Translucent;
		Canvas.SetPos(Canvas.CurX+1, y);
		Canvas.DrawTile(Texture'hud_elements', 16, 19, 34, vt, 16.0, yt);
		Canvas.Style = OwnerHud.ERenderStyle.STY_Masked;
		Canvas.SetPos(Canvas.CurX- 17, y);
		Canvas.DrawTile(Texture'hud_elements', 17, 19, 84, vt, 17.0, yt);

		if (MouseOverIndex == LBIT_SCROLLDOWN)
			Canvas.DrawColor = OwnerInterface.Design.ColorTeam[OwnerPlayer.PlayerReplicationInfo.Team] * 0.7;
		else
			Canvas.DrawColor = OwnerHud.WhiteColor;

		Canvas.Style = OwnerHud.ERenderStyle.STY_Translucent;		// scroll down
		Canvas.SetPos(X, y + MaxHeight - 17);
		Canvas.DrawTile(Texture'hud_elements', 16, 19, 0, vt+yt, 16.0, -yt);
		Canvas.Style = OwnerHud.ERenderStyle.STY_Masked;
		Canvas.SetPos(Canvas.CurX - 17, y + MaxHeight - 17);
		Canvas.DrawTile(Texture'hud_elements', 17, 19, 49, vt+yt, 17.0, -yt);
		Canvas.Style = OwnerHud.ERenderStyle.STY_Translucent;							// right
		Canvas.SetPos(Canvas.CurX+1, y + MaxHeight - 17);
		Canvas.DrawTile(Texture'hud_elements', 16, 19, 34, vt+yt, 16.0, -yt);
		Canvas.Style = OwnerHud.ERenderStyle.STY_Masked;
		Canvas.SetPos(Canvas.CurX - 17, y + MaxHeight - 17);
		Canvas.DrawTile(Texture'hud_elements', 17, 19, 84, vt+yt, 17.0, -yt);

		//Draw the scroll box
		Canvas.DrawColor = OwnerInterface.Design.ColorGrey;
		Canvas.SetPos(X+4,Y+24);
		Canvas.DrawTile(Texture'debug16', 25, MaxHeight-48, 17, vt, 16.0, yt);

		Canvas.Style = OwnerHUD.ERenderStyle.STY_NORMAL;
		Canvas.DrawColor = OwnerHUD.Design.ColorWhite;
		OwnerInterface.Tool_DrawBox(Canvas, X + 5, y + 24, 24, MaxHeight-48);

		//Now to work out settings for the scroll box itself

		// Get height compared to num items
		scrH = (MaxHeight-48) / NumItems;
		Canvas.SetPos(X+5,y + 24 + (TopIndex * scrH));
//		Canvas.DrawTile(Texture'debug16', 23, scrH*NumVisItems, 17, vt, 16.0, yt);
		Canvas.DrawTile(Texture'tilewhite', 23, scrH*NumVisItems, 17, vt, 16.0, yt);
	}
}

// * RClick
function RClick (float x, float y)
{
	local int	i, NewTopIndex;

	Super.RClick(x, y);

	i = GetItemAt(x, y);

	if (i == LBIT_ScrollClick)
	{
  		NewTopIndex = Max(0, Min(NumItems-NumVisItems, (y - ClientTop - 25) / ((ClientHeight-50) / NumItems)));
  		if (NewTopIndex < TopIndex)
			TopIndex = Max(0, TopIndex-NumVisItems+1);
  		if (NewTopIndex - NumVisItems > TopIndex)
			TopIndex = Max(0, Min(NumItems-NumVisItems, TopIndex+NumVisItems-1));
		return;
	}
}

// * Click
function Click (float x, float y)
{
	local int	i;

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

	if (i == LBIT_ScrollClick)
	{
  		TopIndex = Max(0, Min(NumItems-NumVisItems, (y - 46) / ((ClientHeight-50) / (NumItems - NumVisItems + 1)) ));
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

// -methods (input)-
simulated function byte GetItemAt (float x, float y)
{
	local int	i, dy, dx;

	if (NumVisItems < NumItems)
	{
		if (x > WinWidth - 34 && x <= WinWidth && y >= ClientTop && y <= ClientTop+22)
			return LBIT_SCROLLUP;
		if (x > WinWidth - 34 && x <= WinWidth && y >= (ClientTop + ClientHeight - 17) && y <= ClientTop+ClientHeight)
			return LBIT_SCROLLDOWN;

		if (x > WinWidth - 34 && x <= WinWidth && y >= (ClientTop) && y <= ClientTop+ClientHeight)
			return LBIT_ScrollClick;

		if ( (x < 2) || (x > WinWidth-34) || (y < ClientTop) || (y > ClientTop+ClientHeight) )
		  return LBIT_NONE;
	}
	else
	  if ( (x < 2) || (x > WinWidth-2) || (y < ClientTop) || (y > ClientTop+ClientHeight) )
	    return LBIT_NONE;


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
	NumVisItems=8
}
