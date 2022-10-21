//-----------------------------------------------------------
//    RightClickMenu Speech Report
//-----------------------------------------------------------
//
// Tactical Ops - SuperTeam KeyBinder -
//
// Source code rights:
// Copyright (C) 2002 Andrew Jakobs
//-----------------------------------------------------------
class stkbRCMSpeechReport expands stkbRightClickMenu;

var stkbPulldownMenuItem pmi[15];

//------------------------------------------
//       Created (Override)
//------------------------------------------
function Created()
{
    Super.Created();

    pmi[0] =  AddMenuItemAlt("Enemy down",             "speech 3 0 0 'Enemy down", None);
    pmi[1] =  AddMenuItemAlt("Hostage rescued",        "Speech 4 0 0 'Hostage resqued", None);
    pmi[2] =  AddMenuItemAlt("Bomb has been planted",  "Speech 4 1 0 'Bomb has been planted", None);
    pmi[3] =  AddMenuItemAlt("Fire in the hole!",      "Speech 4 2 0 'Fire in the hole!", None);
    pmi[4] =  AddMenuItemAlt("I've got your back",     "speech 4 3 0 'I've got your back", None);
    pmi[5] =  AddMenuItemAlt("I'm hit",                "speech 4 4 0 'I'm hit", None);
    pmi[6] =  AddMenuItemAlt("Emergency! Man Down",    "speech 4 5 0 'Emergency! Man Down", None);
    pmi[7] =  AddMenuItemAlt("Cover your eyes",        "speech 4 11 0 'Cover your eyes", None);
    pmi[8] =  AddMenuItemAlt("Area cleared",           "speech 6 0 0 'Area cleared", None);
    pmi[9] =  AddMenuItemAlt("Enemy spotted",          "speech 6 2 0 'Enemy spotted", None);
    pmi[10] = AddMenuItemAlt("I'll keep them busy",    "Speech 6 3 0 'Ill keep them busy", None);
    pmi[11] = AddMenuItemAlt("I'm going in",           "Speech 6 4 0 'Im going in", None);
    pmi[12] = AddMenuItemAlt("I'm in position",        "speech 6 5 0 'I'm in position", None);
    pmi[13] = AddMenuItemAlt("Objective accomplished", "speech 6 7 0 'Objective accomplished", None);
    pmi[14] = AddMenuItemAlt("Target in sight",        "speech 6 8 0 'Target in sight", None);
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

