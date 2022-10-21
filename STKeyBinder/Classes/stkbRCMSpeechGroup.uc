//-----------------------------------------------------------
//    RightClickMenu Speech Group
//-----------------------------------------------------------
//
// Tactical Ops - SuperTeam KeyBinder -
//
// Source code rights:
// Copyright (C) 2002 Andrew Jakobs
//-----------------------------------------------------------
class stkbRCMSpeechGroup expands stkbRightClickMenu;

var stkbPulldownMenuItem pmi[6];

//------------------------------------------
//       Created (Override)
//------------------------------------------
function Created()
{
    Super.Created();

    pmi[0] = AddMenuItemAlt("5 Seconds before assault!", "Speech 5 0 0 'Assault in 5", None);
    pmi[1] = AddMenuItemAlt("Get in position",           "Speech 5 1 0 'Get in position", None);
    pmi[2] = AddMenuItemAlt("Keep moving",               "Speech 5 2 0 'Keep moving", None);
    pmi[3] = AddMenuItemAlt("Meet at rendez-vous point", "Speech 5 3 0 'Meet at rendezvous", None);
    pmi[4] = AddMenuItemAlt("Split in pairs",            "Speech 5 4 0 'Split in pairs", None);
    pmi[5] = AddMenuItemAlt("Stay together team",        "Speech 5 5 0 'Stay together team", None);
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

