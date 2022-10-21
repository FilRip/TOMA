class TO_GUIBaseListBox extends UWindow.UWindowDialogControl;

var s_HUD OwnerHUD;
var byte numitems;
var TO_GUIBaseTab OwnerTab;
var byte MouseoverIndex;
var byte SelectedIndex;
var byte Selected;
var float ItemHeight;
var TO_GUIBaseMgr OwnerInterface;
var float ClientHeight;
var PlayerPawn OwnerPlayer;
var byte Grouped;
var float ClientTop;
var float ClientCenter;
var float ClientWidth;
var bool bMultiselect;
var byte NumVisItems;
var int ItemsData;
var float ItemSpacing;
var Font ItemFont;
var byte DoubleclickIndex;
var byte TopIndex;
var byte MaxItems;
var bool PlaySound;

simulated function Created ()
{
}

simulated function SetWidth (Canvas Canvas, int Width)
{
}

simulated function TOUIBaseListbox_DrawItemData (Canvas Canvas, byte Item, float Y)
{
}

simulated function byte Add (int Data, bool sel, optional bool Group)
{
}

simulated function Paint (Canvas Canvas, float X, float Y)
{
}

simulated function BeforePaint (Canvas Canvas, float X, float Y)
{
}

native(552) static final operator(16) Color * (Color A, float B)
{
}

simulated function Close (optional bool bByParent)
{
}

function MouseMove (float X, float Y)
{
}

function MouseLeave ()
{
}

function Click (float X, float Y)
{
}

function RClick (float X, float Y)
{
}

function DoubleClick (float X, float Y)
{
}

simulated function Clear ()
{
}

simulated function SetLength (byte Len)
{
}

simulated function int GetSelected ()
{
}

simulated function int GetData (byte Index)
{
}

simulated function bool IsSelectedByIndex (byte Index)
{
}

simulated function bool IsSelectedByData (int Data)
{
}

simulated function bool IsGroupedByIndex (byte Index)
{
}

simulated function TOUIBaseListbox_DrawItems (Canvas Canvas, float Y)
{
}

function byte TOUIBaseListbox_GetItemAt (float X, float Y)
{
}


defaultproperties
{
}

