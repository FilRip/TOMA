//-----------------------------------------------------------
//    RightClickMenu Buy Items
//-----------------------------------------------------------
//
// Tactical Ops - SuperTeam KeyBinder -
//
// Source code rights:
// Copyright (C) 2002 Andrew Jakobs
//-----------------------------------------------------------
class stkbRCMBuyItems expands stkbRightClickMenu;

var stkbPulldownMenuItem pmi[6];

//------------------------------------------
//       Created (Override)
//------------------------------------------
function Created()
{
    Super.Created();

    pmi[0] = AddMenuItemAlt("Needed armor (All armor is better)", "s_kAmmoAuto 333 'Buy Buy Needed Armor", None);
    pmi[1] = AddMenuItemAlt("All armor",                          "s_kAmmoAuto 304 'Buy All Armor", None);
    pmi[2] = AddMenuItemAlt("Kevlar vest",                        "s_kAmmoAuto 301 'Buy Kevlar Vest", None);
    pmi[3] = AddMenuItemAlt("Helmet",                             "s_kAmmoAuto 302 'Buy Helmet", None);
    pmi[4] = AddMenuItemAlt("Thigh pads",                         "s_kAmmoAuto 303 'Buy Thigh Pads", None);
    AddMenuItem("-", None);
    pmi[5] = AddMenuItemAlt("Nighvision goggles",                 "s_kAmmoAuto 401 'Buy Nightvision", None);
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

