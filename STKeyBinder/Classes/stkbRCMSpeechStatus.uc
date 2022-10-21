//-----------------------------------------------------------
//    RightClickMenu Speech Status
//-----------------------------------------------------------
//
// Tactical Ops - SuperTeam KeyBinder -
//
// Source code rights:
// Copyright (C) 2002 Andrew Jakobs
//-----------------------------------------------------------
class stkbRCMSpeechStatus expands stkbRightClickMenu;

var stkbPulldownMenuItem pmi[6];

//------------------------------------------
//       Created (Override)
//------------------------------------------
function Created()
{
    Super.Created();

    pmi[0] = AddMenuItemAlt("Emergency!",               "speech 7 0 0 'Emergency!", None);
    pmi[1] = AddMenuItemAlt("Falling back",             "Speech 7 1 0 'falling back", None);
    pmi[2] = AddMenuItemAlt("I'm hit",                  "speech 7 2 0 'I'm hit", None);
    pmi[3] = AddMenuItemAlt("I'm under heavy attack!",  "speech 7 3 0 'I'm under heavy attack!", None);
    pmi[4] = AddMenuItemAlt("I need some backup fast!", "speech 7 4 0 'I need some backup fast!", None);
    pmi[5] = AddMenuItemAlt("Watch for cover",          "speech 7 5 0 'Watch for cover", None);
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

