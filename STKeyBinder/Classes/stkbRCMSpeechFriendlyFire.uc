//-----------------------------------------------------------
//    RightClickMenu Speech Friendly Fire
//-----------------------------------------------------------
//
// Tactical Ops - SuperTeam KeyBinder -
//
// Source code rights:
// Copyright (C) 2002 Andrew Jakobs
//-----------------------------------------------------------
class stkbRCMSpeechFriendlyFire expands stkbRightClickMenu;

var stkbPulldownMenuItem pmi[2];

//------------------------------------------
//       Created (Override)
//------------------------------------------
function Created()
{
    Super.Created();

    pmi[0] = AddMenuItemAlt("Hey! Friendly fire!",  "speech 1 0 0 'Hey! Friendly fire!", None);
    pmi[1] = AddMenuItemAlt("Watch who you shoot!", "speech 1 1 0 'Watch who you shoot!", None);
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

