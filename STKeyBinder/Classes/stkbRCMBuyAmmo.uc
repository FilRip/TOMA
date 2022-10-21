//-----------------------------------------------------------
//    RightClickMenu Buy Ammo
//-----------------------------------------------------------
//
// Tactical Ops - SuperTeam KeyBinder -
//
// Source code rights:
// Copyright (C) 2002 Andrew Jakobs
//-----------------------------------------------------------
class stkbRCMBuyAmmo expands stkbRightClickMenu;

var stkbPulldownMenuItem pmi[2];

//------------------------------------------
//       Created (Override)
//------------------------------------------
function Created()
{
    Super.Created();

    pmi[0] = AddMenuItemAlt("Ammo clip (This one is better)", "s_kAmmo 'Buy Ammo", None);
    pmi[1] = AddMenuItemAlt("Ammo for weapon in hand",        "s_kAmmoAuto 999 'Buy Ammo for weapon in hand", None);
}

//------------------------------------------
//       ExecuteItem (Override)
//------------------------------------------
function ExecuteItem(UWindowPulldownMenuItem I)
{
     //If the AltValue is not empty, set the editbox with its value
    if(stkbPulldownMenuItem(I).AltValue != "")
        stkbDCWKeyBinder(OwnerWindow).InsertCommand(stkbPulldownMenuItem(I).AltValue);
    Super.ExecuteItem(I);
}

