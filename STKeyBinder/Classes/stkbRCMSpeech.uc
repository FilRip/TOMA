//-----------------------------------------------------------
//    RightClickMenu Speech
//-----------------------------------------------------------
//
// Tactical Ops - SuperTeam KeyBinder -
//
// Source code rights:
// Copyright (C) 2002 Andrew Jakobs
//-----------------------------------------------------------
class stkbRCMSpeech expands stkbRightClickMenu;

var UWindowPulldownMenuItem pmi[6];

//------------------------------------------
//       Created (Override)
//------------------------------------------
function Created()
{
    Super.Created();

    pmi[0] = AddMenuItem("Acknowledge", None);
    pmi[0].CreateSubMenu(class'stkbRCMSpeechAcknowledge', OwnerWindow);
    pmi[1] = AddMenuItem("Friendly fire", None);
    pmi[1].CreateSubMenu(class'stkbRCMSpeechFriendlyFire', OwnerWindow);
    pmi[2] = AddMenuItem("Orders", None);
    pmi[2].CreateSubMenu(class'stkbRCMSpeechOrders', OwnerWindow);
    pmi[3] = AddMenuItem("Report", None);
    pmi[3].CreateSubMenu(class'stkbRCMSpeechReport', OwnerWindow);
    pmi[4] = AddMenuItem("Group", None);
    pmi[4].CreateSubMenu(class'stkbRCMSpeechGroup', OwnerWindow);
    pmi[5] = AddMenuItem("Status", None);
    pmi[5].CreateSubMenu(class'stkbRCMSpeechStatus', OwnerWindow);
}

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------

