//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTGUIEditControl.uc
// Version : 4.0
// Author  : MadOnion (based on code by J3rky)
//----------------------------------------------------------------------------
// Version	Changes
// 4.0		+ First Release
//----------------------------------------------------------------------------

class TOSTGUIEditControl expands UWindowDialogControl;

var float			EditBoxWidth;
var float			EditAreaDrawX, EditAreaDrawY;
var TOSTGUIEditBox	EditBox;

var TO_GUIBaseMgr	OwnerInterface;
var PlayerPawn		OwnerPlayer;
var s_Hud			OwnerHud;
var TO_GUIBaseTab	OwnerTab;

var string					Label;

// dimensions
var float					ClientTop, ClientCenter, ClientHeight, ClientWidth;
var float					ItemHeight, ItemSpacing;
var font					ItemFont;


// -operators-

// color
native(552) static final operator(16) color *     ( color A, float B );

// -methods (engine)-

function Created()
{
	// TO GUI
	OwnerPlayer = GetPlayerOwner();
	OwnerHud = s_Hud(OwnerPlayer.myHud);
	OwnerInterface = OwnerHud.UserInterface;

	Super.Created();

	//Editbox stuff
	EditBox = TOSTGUIEditBox(CreateWindow(class'TOSTGUIEditBox', 0, 0, WinWidth, WinHeight));
	EditBox.NotifyOwner = Self;
	EditBox.bSelectOnFocus = True;
	EditBoxWidth = WinWidth / 2;
}

simulated function Close (optional bool bByParent)
{
	EditBox.Close();

	OwnerPlayer = None;
	OwnerHud = None;
	OwnerInterface = None;

	Super.Close(bByParent);
}

function SetNumericOnly(bool bNumericOnly)
{
	EditBox.bNumericOnly = bNumericOnly;
}

function SetNumericFloat(bool bNumericFloat)
{
	EditBox.bNumericFloat = bNumericFloat;
}

function SetHistory(bool bInHistory)
{
	EditBox.SetHistory(bInHistory);
}

function Clear()
{
	EditBox.Clear();
}

function string GetValue()
{
	return EditBox.GetValue();
}

function SetValue(string NewValue)
{
	EditBox.SetValue(NewValue);
}

function SetMaxLength(int MaxLength)
{
	EditBox.MaxLength = MaxLength;
}

function SetDelayedNotify(bool bDelayedNotify)
{
	Editbox.bDelayedNotify = bDelayedNotify;
}

simulated function Paint (Canvas Canvas, float x, float y)
{
	local float					ypos;
	local float					xl, yl;


	if ( (OwnerTab != None) && !OwnerTab.bDraw )
	{
		return;
	}


	Canvas.Style = OwnerHUD.ERenderStyle.STY_NORMAL;
	Canvas.DrawColor = OwnerHUD.Design.ColorWhite;

	// title panel
	ypos = 0;

	DrawPanel(Canvas, ypos, 256, -18, -19);

	Canvas.Font = OwnerHud.Design.Font10;
	Canvas.StrLen(Label, xl, yl);
	Canvas.SetPos(ClientCenter-0.5*xl, ypos+5);
	Canvas.DrawText(Label, true);

	// listbox
	ypos += 22;
	OwnerInterface.Tool_DrawBox(Canvas, 2, ypos+2, ClientWidth, ClientHeight-2);


	// items
	Canvas.Font = ItemFont;
	DrawEditBackground(Canvas, ypos+2);
}

// - methods (drawing)

simulated function DrawEditBackground(Canvas Canvas, float y)
{
	local byte	i, c;
	local texture	bg;

	// background
	Canvas.SetPos(2, y);

	Canvas.DrawColor = OwnerInterface.Design.ColorGrey;
	bg = Texture'debug16';

	Canvas.DrawTile(bg, ClientWidth, ItemHeight, 0, 0, 16, 16);
}

simulated function DrawPanel (Canvas Canvas, float y, float vt, float vtoffs, float yt)
{
	local float				w;


	w = WinWidth - 34;

	// background
	Canvas.DrawColor = OwnerHud.WhiteColor;

	Canvas.SetPos(17, y);
	Canvas.Style = OwnerHud.ERenderStyle.STY_Translucent;
	Canvas.DrawTile(Texture'hud_elements', w, 19, 17, vt, 16.0, yt);				// bg

	Canvas.SetPos(17, y);
	Canvas.Style = OwnerHud.ERenderStyle.STY_Masked;
	Canvas.DrawTile(Texture'hud_elements', w, 19, 67, vt+vtoffs, 16.0, yt);			// fg

	// background borders
	Canvas.Style = OwnerHud.ERenderStyle.STY_Translucent;							// right
	Canvas.SetPos(Canvas.CurX, y);
	Canvas.DrawTile(Texture'hud_elements', 16, 19, 34, vt, 16.0, yt);
	Canvas.Style = OwnerHud.ERenderStyle.STY_Masked;
	Canvas.SetPos(Canvas.CurX - 17, y);
	Canvas.DrawTile(Texture'hud_elements', 17, 19, 84, vt, 17.0, yt);

	Canvas.Style = OwnerHud.ERenderStyle.STY_Translucent;							// left
	Canvas.SetPos(1, y);
	Canvas.DrawTile(Texture'hud_elements', 16, 19, 0, vt, 16.0, yt);
	Canvas.Style = OwnerHud.ERenderStyle.STY_Masked;
	Canvas.SetPos(1, y);
	Canvas.DrawTile(Texture'hud_elements', 17, 19, 49, vt, 17.0, yt);
}

simulated function SetWidth (Canvas Canvas, int width)
{
	// Resize EditBox
	EditBox.SetWidth(Canvas, width);

	WinWidth = width;

	OwnerHUD.Design.SetScoreboardFont(Canvas);

	ItemFont = Canvas.Font;
	ItemSpacing = OwnerHud.Design.LineSpacing + 2;

	ClientCenter = 0.5*WinWidth;
	ClientWidth = WinWidth - 4;

	/* set ClientTop, ItemHeight, ClientHeight & WinHeight in child classes */

	ClientTop = 23;
	ItemHeight = OwnerHud.Design.LineHeight + 3;
	ClientHeight = ItemHeight+ItemSpacing;
	WinHeight = ClientHeight + 22;
}

DefaultProperties
{
}
