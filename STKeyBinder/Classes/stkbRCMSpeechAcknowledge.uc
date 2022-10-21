//-----------------------------------------------------------
//    RightClickMenu Speech Acknowledge
//-----------------------------------------------------------
//
// Tactical Ops - SuperTeam KeyBinder -
//
// Source code rights:
// Copyright (C) 2002 Andrew Jakobs
//-----------------------------------------------------------
class stkbRCMSpeechAcknowledge expands stkbRightClickMenu;

var stkbPulldownMenuItem pmi[4];

//------------------------------------------
//       Created (Override)
//------------------------------------------
function Created()
{
    Super.Created();

    pmi[0] = AddMenuItemAlt("I copy",     "speech 0 0 0 'I Copy", None);
    pmi[1] = AddMenuItemAlt("Roger that", "speech 0 1 0 'Roger that", None);
    pmi[2] = AddMenuItemAlt("You got it", "speech 0 2 0 'You got it", None);
    pmi[3] = AddMenuItemAlt("Negative",   "speech 0 3 0 'Negative", None);
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

