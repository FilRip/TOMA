//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTGUIVoteListBox.uc
// Version : 4.0
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 4.0		+ First Release
//----------------------------------------------------------------------------

class TOSTGUIVoteListBox expands TOSTGUITextListBox;

var int		Data[251];
var int		MaxItem;

simulated function UpdateData(byte Item, int NewData)
{
	local int i;

	Data[Item] = NewData;

	MaxItem = 0;
	for (i=0; i<251; i++)
		if (Data[i] > MaxItem)
			MaxItem = Data[i];
}

// * methods (drawing)
simulated function DrawItems (Canvas Canvas, float y)
{
	local byte					i, c;
	local texture				bg;
	local float					pct, cd;

	if (NumVisItems < NumItems) 
 	  {
  	    //Change so centre moves, would use SetWidth but dont trust it
	    ClientWidth = ClientWidth - 34;
	    ClientCenter = ClientCenter - 27;
 	  }

	cd = 1.75;

	c = Min(NumVisItems, NumItems-TopIndex);
	for (i=TopIndex; i < TopIndex+c; i++)
	{
		if (MaxItem != 0)
		{
			pct = (1/MaxItem) * Data[i];
		} else {
			pct = 0;
		}

		// background
		Canvas.SetPos(2, y);
		if (Selected[i] == LBSEL_YES)
		{
			Canvas.DrawColor = OwnerInterface.Design.ColorDarkgreen*cd;
			bg = Texture'tilewhite';
		}
		else if (i == MouseoverIndex)
		{
			Canvas.DrawColor = OwnerInterface.Design.ColorTeam[OwnerPlayer.PlayerReplicationInfo.Team] * 0.7*cd;
			bg = Texture'tilewhite';
		}
		else
		{
			Canvas.DrawColor = OwnerInterface.Design.ColorGrey*cd;
			bg = Texture'debug16';
		}
		Canvas.DrawTile(bg, ClientWidth *pct, ItemHeight, 0, 0, 16, 16);

		Canvas.SetPos(2+ClientWidth *pct, y);
		Canvas.DrawColor = Canvas.DrawColor * (1/cd);
		Canvas.DrawTile(bg, ClientWidth  - ClientWidth *pct, ItemHeight, 0, 0, 16, 16);

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

simulated function DrawItemData (Canvas Canvas, byte item, float y)
{
	local float	xl, yl;
	local string s;

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

	s = string(Data[Item]);
	Canvas.StrLen(s, xl, yl);
	Canvas.SetPos(ClientWidth - 4 - xl, y+ItemSpacing);
	Canvas.DrawText(s, true);
}


