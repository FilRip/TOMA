//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTGUIBaseUpdown.uc
// Version : 4.0
// Author  : BugBunny (based on code by J3rky)
//----------------------------------------------------------------------------
// Version	Changes
// 4.0		+ First Release
//----------------------------------------------------------------------------

class TOSTGUIBaseUpdown expands UWindowDialogControl;

enum ETOUpdownStyle
{
	ST_HORIZONTAL,			// not supported yet
	ST_VERTICAL
};

enum ETOUpdownButton
{
	BTN_NONE,
	BTN_PLUS,
	BTN_MINUS,
	BTN_NUMBER
};

var TO_GUIBaseMgr			OwnerInterface;
var PlayerPawn				OwnerPlayer;
var s_Hud					OwnerHud;
var TO_GUIBaseTab			OwnerTab;

var ETOUpdownStyle			Style;
var string					Label;
var int						Data;

// updown
var int						Value, MinValue, MaxValue, IncValue, IncValue2;
var int						NumDigits;
var float					ButtonHeight, ButtonSpacing;
var float					ClientHeight, ClientWidth, ClientCenter;
var font					ButtonFont, LabelFont;

// input
var bool					bMouseover, bMouseoverPlus, bMouseoverMinus;
var bool					PlaySound;


// color
native(552) static final operator(16) color *( color A, float B );

// - methods (engine)

simulated function Created ()
{
	OwnerPlayer = GetPlayerOwner();
	OwnerHud = s_Hud(OwnerPlayer.myHud);
	OwnerInterface = OwnerHud.UserInterface;

	Super.Created();
}

simulated function Close (optional bool bByParent)
{
	OwnerPlayer = None;
	OwnerHud = None;
	OwnerInterface = None;

	Super.Close(bByParent);
}

simulated function BeforePaint (Canvas Canvas, float x, float y)
{
	if (Value < MinValue)
	{
		Value = MinValue;
	}
	else if (Value > MaxValue)
	{
		Value = MaxValue;
	}
}

simulated function Paint (Canvas Canvas, float x, float y)
{
	if ( (OwnerTab != None) && !OwnerTab.bDraw )
	{
		return;
	}

	// box
	OwnerInterface.Tool_DrawBox(Canvas, 2, 2, ClientWidth, ClientHeight);

	// buttons & value
	Canvas.Font = ButtonFont;
	DrawButton (Canvas, "+", false, bMouseoverPlus);
	DrawButton (Canvas, "-", true, bMouseoverMinus);
	DrawValue (Canvas);

	Canvas.Font = LabelFont;
	DrawLabel (Canvas);
}

function MouseMove (float x, float y)
{
	local ETOUpdownButton			b;


	b = GetButtonAt(x, y);

	bMouseoverPlus = (b == BTN_PLUS);
	bMouseoverMinus = (b == BTN_MINUS);
	bMouseover = (b != BTN_NONE);

	if (OwnerTab != None)
	{
		OwnerTab.Notify(self, DE_MouseMove);
	}
}

function MouseLeave ()
{
	Super.MouseLeave();

	bMouseoverPlus = false;
	bMouseoverMinus = false;
	bMouseover = false;

	if (OwnerTab != None)
	{
		OwnerTab.Notify(self, DE_MouseLeave);
	}
}

function Click (float x, float y)
{
	local ETOUpdownButton			b;

	b = GetButtonAt(x, y);
	if ( (b == BTN_PLUS) && (Value < MaxValue) )
	{
		Value += IncValue;
		if (Value > MaxValue)
			Value = MaxValue;
	}
	else if ( (b == BTN_MINUS) && (Value > MinValue) )
	{
		Value -= IncValue;
		if (Value < MinValue)
			Value = MinValue;
	}
	else
	{
		return;
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

function RClick (float x, float y)
{
	local ETOUpdownButton			b;

	b = GetButtonAt(x, y);
	if ( (b == BTN_PLUS) && (Value < MaxValue) )
	{
		Value += IncValue2;
		if (Value > MaxValue)
			Value = MaxValue;
	}
	else if ( (b == BTN_MINUS) && (Value > MinValue) )
	{
		Value -= IncValue2;
		if (Value < MinValue)
			Value = MinValue;
	}
	else
	{
		return;
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

function DoubleClick (float x, float y)
{
	local ETOUpdownButton			b;

	b = GetButtonAt(x, y);

	if (b == BTN_NUMBER)
	{
		if (Value == MaxValue)
			Value = MinValue;
		else
			Value = MaxValue;
	} else {
		return;
	}

	if (OwnerTab != None)
	{
		OwnerTab.Notify(self, DE_Click);
	}
}

// - methods (exported)
simulated function SetWidth (Canvas Canvas, int width)
{
	local	float	cx, cy;

	OwnerHUD.Design.SetHeadlineFont(Canvas);
	LabelFont = Canvas.Font;
	Canvas.TextSize(Label, cx, cy);
	OwnerHUD.Design.SetScoreboardFont(Canvas);
	ButtonFont = Canvas.Font;

	ButtonHeight = OwnerHud.Design.LineHeight + 3;
	ButtonSpacing = OwnerHud.Design.LineSpacing + 2;

	ClientWidth = Width;
	ClientHeight = 3*ButtonHeight;
	ClientCenter = 0.5*Width;

	WinWidth = Width + ButtonSpacing + cx + 14;
	WinHeight = 4 + ClientHeight;
}

// - methods (drawing)
simulated function DrawButton (Canvas Canvas, string caption, bool minus, bool mouseover)
{
	local float					y, xl, yl;
	local color					textcolor;
	local texture				bg;


	Canvas.Style = OwnerHud.ERenderStyle.STY_NORMAL;

	if (mouseover && !((Value == MaxValue && !minus) || (Value == MinValue && minus)))
	{
		Canvas.DrawColor = OwnerInterface.Design.ColorTeam[OwnerPlayer.PlayerReplicationInfo.Team] * 0.7;
		textcolor = OwnerInterface.Design.ColorWhite;
		bg = Texture'tilewhite';
	}
	else if ((Value == MaxValue && !minus) || (Value == MinValue && minus))
	{
		Canvas.DrawColor = OwnerInterface.Design.ColorDarkgrey;
		textcolor = OwnerInterface.Design.ColorDarkRed;
		bg = Texture'tilewhite';
	}
	else
	{
		Canvas.DrawColor = OwnerInterface.Design.ColorWhite;
		textcolor = OwnerInterface.Design.ColorWhite;
		bg = Texture'debug16';
	}
	Canvas.StrLen(caption, xl, yl);

	switch (Style)
	{
		case ST_VERTICAL:		y = 2;
								if (minus)
								{
									y += 2*ButtonHeight;
								}
								Canvas.SetPos(2, y);
								Canvas.DrawTile(bg, ClientWidth, ButtonHeight, 0, 0, 16, 16 );

								Canvas.DrawColor = textcolor;
								Canvas.SetPos(ClientCenter-0.5*xl, y+0.5*(ButtonHeight-yl)+ButtonSpacing);
								Canvas.DrawText(caption, true);
								break;

		case ST_HORIZONTAL:		// not supported yet
								break;
	}
}

simulated function DrawValue (Canvas Canvas)
{
	local float					xl, yl;


	Canvas.Style = OwnerHud.ERenderStyle.STY_NORMAL;
	Canvas.DrawColor = OwnerInterface.Design.ColorWhite;

	Canvas.StrLen(Value, xl, yl);
	switch (Style)
	{
		case ST_VERTICAL:		xl = ClientCenter-0.5*xl;
								yl = 2 + ButtonHeight + ButtonSpacing + 0.5*(ButtonHeight-yl);
								break;

		case ST_HORIZONTAL:		// not supported yet
								break;
	}

	Canvas.SetPos(xl, yl);
	Canvas.DrawText(Value, true);
}

simulated function DrawLabel (Canvas Canvas)
{
	local float					xl, yl;


	Canvas.Style = OwnerHud.ERenderStyle.STY_NORMAL;
	Canvas.DrawColor = OwnerInterface.Design.ColorWhite;

	Canvas.StrLen(Label, xl, yl);
	switch (Style)
	{
		case ST_VERTICAL:		xl = ClientWidth + ButtonSpacing + 12;
								yl = 2 + ButtonHeight + ButtonSpacing + 0.5*(ButtonHeight-yl);
								break;

		case ST_HORIZONTAL:		// not supported yet
								break;
	}

	Canvas.SetPos(xl, yl);
	Canvas.DrawText(Label, true);
}

// - methods (input)
simulated function ETOUpdownButton GetButtonAt (float x, float y)
{
	if ( (x < 2) || (x > WinWidth-2) || (y < 2) || (y > WinHeight-2) )
	{
		return BTN_NONE;
	}

	switch (Style)
	{
		case ST_VERTICAL:			if (y < (2 + ButtonHeight))
										return BTN_PLUS;
									else
										if (y > (2 + 2*ButtonHeight))
											return BTN_MINUS;
										else
											return BTN_NUMBER;
									break;

		case ST_HORIZONTAL:			// not supported yet
									break;
	}
}

// - defaultproperties
defaultproperties
{
	MinValue=0
	MaxValue=9
	IncValue=1

	Style=ST_VERTICAL

	PlaySound=true
}
