class TO_GUIBaseListBox extends UWindowDialogControl;

const LBSEL_YES=1;
const LBSEL_NO=0;
const LBIT_NONE=31;

var TO_GUIBaseMgr OwnerInterface;
var PlayerPawn OwnerPlayer;
var s_HUD OwnerHUD;
var TO_GUIBaseTab OwnerTab;
var int ItemsData[31];
var byte Selected[31];
var byte Grouped[31];
var byte MaxItems;
var byte numitems;
var byte NumVisItems;
var byte SelectedIndex;
var byte TopIndex;
var byte MouseoverIndex;
var byte DoubleclickIndex;
var float ClientTop;
var float ClientCenter;
var float ClientHeight;
var float ClientWidth;
var float ItemHeight;
var float ItemSpacing;
var Font ItemFont;
var bool bMultiselect;
var bool PlaySound;

native(552) static final operator(16) Color * (Color A, float B);

simulated function Created ()
{
}

simulated function Close (optional bool bByParent)
{
}

simulated function BeforePaint (Canvas Canvas, float X, float Y)
{
}

simulated function Paint (Canvas Canvas, float X, float Y)
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

simulated function byte Add (int Data, bool sel, optional bool Group)
{
}

simulated function Clear ()
{
}

simulated function SetLength (byte Len)
{
}

simulated function SetWidth (Canvas Canvas, int Width)
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

simulated function TOUIBaseListbox_DrawItemData (Canvas Canvas, byte Item, float Y)
{
}

simulated function byte TOUIBaseListbox_GetItemAt (float X, float Y)
{
}
