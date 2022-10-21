//-----------------------------------------------------------
//    RightClickMenu Buy
//-----------------------------------------------------------
//
// Tactical Ops - SuperTeam KeyBinder -
//
// Source code rights:
// Copyright (C) 2002 Andrew Jakobs
//-----------------------------------------------------------
class stkbRCMBuy expands stkbRightClickMenu;

var UWindowPulldownMenuItem pmi[3];

//------------------------------------------
//       Created (Override)
//------------------------------------------
function Created()
{
    Super.Created();

//    AddMenuItem("-", None);
    pmi[0] = AddMenuItem("Weapons", None);
    pmi[0].CreateSubMenu(class'stkbRCMBuyWeapons', OwnerWindow);
    pmi[1] = AddMenuItem("Ammo", None);
    pmi[1].CreateSubMenu(class'stkbRCMBuyAmmo', OwnerWindow);
    pmi[2] = AddMenuItem("Items", None);
    pmi[2].CreateSubMenu(class'stkbRCMBuyItems', OwnerWindow);
}

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------

