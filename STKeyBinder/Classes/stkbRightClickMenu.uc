// EWindow by Wormbo
//=============================================================================
// EWindowRightClickMenu
// This class can handle more than one submenu.
//=============================================================================
//
//   This class is renamed to stkbRightClickMenu
//

class stkbRightClickMenu extends stkbPulldownMenu;

function Created()
{
    bTransient = True;
    Super.Created();
}

function RMouseDown(float X, float Y)
{
    LMouseDown(X, Y);
}

function RMouseUp(float X, float Y)
{
    LMouseUp(X, Y);
}

function CloseUp(optional bool bByOwner)
{
    Super.CloseUp(bByOwner);
    HideWindow();
}
