//-----------------------------------------------------------
//    RightClickMenu TOSTAdmin
//-----------------------------------------------------------
//
// Tactical Ops - SuperTeam KeyBinder -
//
// Source code rights:
// Copyright (C) 2002 Andrew Jakobs
//-----------------------------------------------------------
class stkbRCMTOSTAdmin expands stkbRightClickMenu;

var stkbPulldownMenuItem pmi[9];

//------------------------------------------
//       Created (Override)
//------------------------------------------
function Created()
{
    Super.Created();

    pmi[0] = AddMenuItemAlt("ShowAdminTab",  "ShowAdminTab", None);
    pmi[1] = AddMenuItemAlt("ShowGameTab",   "ShowGameTab", None);
    pmi[2] = AddMenuItemAlt("ShowIP <id>",   "ShowIP ", None);
    pmi[3] = AddMenuItemAlt("KickTK",        "kicktk", None);
    pmi[4] = AddMenuItemAlt("mkteams",       "mkteams", None);
    pmi[5] = AddMenuItemAlt("fteamchg <id>", "fteamchg ", None);
    pmi[6] = AddMenuItemAlt("xKick <id>",    "xkick ", None);
    pmi[7] = AddMenuItemAlt("xpKick <id>",   "xpkick ", None);
    pmi[8] = AddMenuItemAlt("protectsrv",    "protectsrv", None);
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

