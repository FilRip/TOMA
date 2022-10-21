//-----------------------------------------------------------
//    RightClickMenu Various
//-----------------------------------------------------------
//
// Tactical Ops - SuperTeam KeyBinder -
//
// Source code rights:
// Copyright (C) 2002 Andrew Jakobs
//-----------------------------------------------------------
class stkbRCMVarious expands stkbRightClickMenu;

var stkbPulldownMenuItem pmi[12];

//------------------------------------------
//       Created (Override)
//------------------------------------------
function Created()
{
    Super.Created();

    pmi[0] =  AddMenuItemAlt("Next Command | ",       " | ", None);
    pmi[1] =  AddMenuItemAlt("onrelease",             "onrelease ", None);
    pmi[2] =  AddMenuItemAlt("Set input",             "Set input ", None);
    pmi[3] =  AddMenuItemAlt("SAY",                   "SAY ", None);
    pmi[4] =  AddMenuItemAlt("TEAMSAY",               "TEAMSAY ", None);
    AddMenuItem("-", None);
    pmi[5] =  AddMenuItemAlt("ShowScores",            "ShowScores", None);
    pmi[6] =  AddMenuItemAlt("ShowServerInfo",        "ShowServerInfo", None);
    AddMenuItem("-", None);
    pmi[7] =  AddMenuItemAlt("Find internet games",   "MenuCmd 1 0 'find internet games", None);
    pmi[8] =  AddMenuItemAlt("Disconnect server",     "MenuCmd 1 5 'disconnect server", None);
    pmi[9] =  AddMenuItemAlt("Reconnect server",      "MenuCmd 1 6 'Reconnect server", None);
    pmi[10] = AddMenuItemAlt("-SuperTeam- Keybinder", "MenuCmd 4 x 'SuperTeam KeyBinder (Replace x with corresponding menu)", None);
    AddMenuItem("-", None);
    pmi[11] = AddMenuItemAlt("Mapvote",               "MUTATE BDBMAPVOTE VOTEMENU", None);
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

