//-----------------------------------------------------------
//    RightClickMenu Options
//-----------------------------------------------------------
//
// Tactical Ops - SuperTeam KeyBinder -
//
// Source code rights:
// Copyright (C) 2002 Andrew Jakobs
//-----------------------------------------------------------
class stkbRCMOptions expands stkbRightClickMenu;

var UWindowPulldownMenuItem pmi[12];
var stkbDCWKeyBinder        STParent;

//------------------------------------------
//       Created (Override)
//------------------------------------------
function Created()
{
    Super.Created();

    pmi[0] = AddMenuItem("Buy", None);
    pmi[0].CreateSubMenu(class'stkbRCMBuy', OwnerWindow);
    pmi[1] = AddMenuItem("Speech", None);
    pmi[1].CreateSubMenu(class'stkbRCMSpeech', OwnerWindow);
    pmi[2] = AddMenuItem("Gestures", None);
    pmi[2].CreateSubMenu(class'stkbRCMGestures', OwnerWindow);
    pmi[3] = AddMenuItem("Various", None);
    pmi[3].CreateSubMenu(class'stkbRCMVarious', OwnerWindow);
    pmi[4] = AddMenuItem("TOST", None);
    pmi[4].CreateSubMenu(class'stkbRCMTOST', OwnerWindow);
    AddMenuItem("-", None);
    pmi[5] = AddMenuItem("Clear", None);
    AddMenuItem("-", None);
    pmi[6] = AddMenuItem("Cut", None);
    pmi[7] = AddMenuItem("Copy", None);
    pmi[8] = AddMenuItem("Paste", None);
    AddMenuItem("-", None);
    pmi[9] = AddMenuItem("About", None);
   // pmi[10] = AddMenuItem("Test", None);
}

//------------------------------------------
//       ExecuteItem (Override)
//------------------------------------------
function ExecuteItem(UWindowPulldownMenuItem I)
{
    switch(I)
    {
    case pmi[5]:
        stkbDCWKeyBinder(OwnerWindow).edcNewBinding.EditBox.Clear();
        break;
    case pmi[6]:
        GetPlayerOwner().CopyToClipboard(stkbDCWKeyBinder(OwnerWindow).edcNewBinding.EditBox.Value);
        stkbDCWKeyBinder(OwnerWindow).edcNewBinding.EditBox.Clear();
//        stkbDCWKeyBinder(OwnerWindow).edcNewBinding.EditBox.EditCut();
        break;
    case pmi[7]:
        GetPlayerOwner().CopyToClipboard(stkbDCWKeyBinder(OwnerWindow).edcNewBinding.EditBox.Value);
        break;
    case pmi[8]:
        stkbDCWKeyBinder(OwnerWindow).edcNewBinding.EditBox.EditPaste();
        break;
    case pmi[9]:
        stkbDCWKeyBinder(OwnerWindow).ShowAboutBox();
        break;
//    case pmi[10]:
//        stkbDCWKeyBinder(OwnerWindow).edcNewBinding.setValue("get ini:Engine.Engine.ViewportManager Brightness");
//        break;
    };
    Super.ExecuteItem(I);
}


//------------------------------------------
//       ShowWindow (Override)
//------------------------------------------
function ShowWindow()
{
    Super.ShowWindow();
}

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------

