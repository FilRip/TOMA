//-----------------------------------------------------------
//    RightClickMenu Gestures
//-----------------------------------------------------------
//
// Tactical Ops - SuperTeam KeyBinder -
//
// Source code rights:
// Copyright (C) 2002 Andrew Jakobs
//-----------------------------------------------------------
class stkbRCMGestures expands stkbRightClickMenu;

var stkbPulldownMenuItem pmi[3];

//------------------------------------------
//       Created (Override)
//------------------------------------------
function Created()
{
    Super.Created();

    pmi[0] = AddMenuItemAlt("Chicken dance", "taunt victory1", None);
    pmi[1] = AddMenuItemAlt("Bow",           "taunt taunt1", None);
    pmi[2] = AddMenuItemAlt("Wave",          "taunt wave", None);
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

