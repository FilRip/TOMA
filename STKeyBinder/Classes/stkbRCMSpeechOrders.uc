//-----------------------------------------------------------
//    RightClickMenu Speech Orders
//-----------------------------------------------------------
//
// Tactical Ops - SuperTeam KeyBinder -
//
// Source code rights:
// Copyright (C) 2002 Andrew Jakobs
//-----------------------------------------------------------
class stkbRCMSpeechOrders expands stkbRightClickMenu;

var stkbPulldownMenuItem pmi[5];

//------------------------------------------
//       Created (Override)
//------------------------------------------
function Created()
{
    Super.Created();

    pmi[0] = AddMenuItemAlt("Return to base",             "speech 2 0 -1 'Return to base!", None);
    pmi[1] = AddMenuItemAlt("Hold this position",         "speech 2 1 -1 'Hold this position", None);
    pmi[2] = AddMenuItemAlt("Let's clean this place out", "speech 2 2 -1 'Let's clean this place out", None);
    pmi[3] = AddMenuItemAlt("Cover me",                   "speech 2 3 -1 'Cover me", None);
    pmi[4] = AddMenuItemAlt("Attack main target",         "speech 2 4 -1 'Attack main target", None);
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

