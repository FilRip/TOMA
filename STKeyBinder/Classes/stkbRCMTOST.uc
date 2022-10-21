//-----------------------------------------------------------
//    RightClickMenu TOST
//-----------------------------------------------------------
//
// Tactical Ops - SuperTeam KeyBinder -
//
// Source code rights:
// Copyright (C) 2002 Andrew Jakobs
//-----------------------------------------------------------
class stkbRCMTOST expands stkbRightClickMenu;

var stkbPulldownMenuItem pmi[11];

//------------------------------------------
//       Created (Override)
//------------------------------------------
function Created()
{
    Super.Created();

    pmi[0] = AddMenuItemAlt("Echo",                     "Echo ", None);
    pmi[1] = AddMenuItemAlt("GetNextMap",               "GetNextMap", None);
    AddMenuItem("-", None);
    pmi[2] = AddMenuItemAlt("xSay",                     "xSay ", None);
    pmi[3] = AddMenuItemAlt("xTeamsay",                 "xTeamSay ", None);
    pmi[4] = AddMenuItemAlt("#W (players weapon)",      "#W", None);
    pmi[5] = AddMenuItemAlt("#T (players target name)", "#T", None);
    pmi[6] = AddMenuItemAlt("#N (players name)",        "#N", None);
    pmi[7] = AddMenuItemAlt("#L (players location)",    "#L", None);
    pmi[8] = AddMenuItemAlt("#H (players health)",      "#H", None);
    pmi[9] = AddMenuItemAlt("#B (players buddies)",    "#B", None);
    AddMenuItem("-", None);
    pmi[10] = AddMenuItemAlt("Admin", "", None);
    pmi[10].CreateSubMenu(class'stkbRCMTOSTAdmin', OwnerWindow);
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

