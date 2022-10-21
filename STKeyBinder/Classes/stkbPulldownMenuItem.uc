// EWindow by Wormbo
//=============================================================================
// EWindowPulldownMenuItem
//=============================================================================
//
//  This class is renamed to stkbPulldownMenuItem
//

class stkbPulldownMenuItem extends UWindowPulldownMenuItem;

var string AltValue;

function Select()
{
    if ( SubMenu != None ) {
        SubMenu.WinLeft = Owner.WinLeft + Owner.WinWidth - Owner.HBorder;
        SubMenu.WinTop = ItemTop - Owner.VBorder;
        
        if ( stkbPulldownMenu(Owner) != None )
            stkbPulldownMenu(Owner).SubMenu = stkbPulldownMenu(SubMenu);
        if ( stkbPulldownMenu(SubMenu) != None )
            stkbPulldownMenu(SubMenu).ParentMenu = Owner;
        SubMenu.ShowWindow();
    }
}

function DeSelect()
{
    if ( SubMenu != None ) {
        if ( stkbPulldownMenu(Owner) != None && stkbPulldownMenu(Owner).SubMenu == SubMenu )
            stkbPulldownMenu(Owner).SubMenu = None;
        if ( stkbPulldownMenu(SubMenu) != None )
            stkbPulldownMenu(SubMenu).ParentMenu = None;
        SubMenu.DeSelect();
        SubMenu.HideWindow();
    }
}
