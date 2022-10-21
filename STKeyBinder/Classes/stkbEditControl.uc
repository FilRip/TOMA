//-----------------------------------------------------------
//    EditControl KeyBinder
//-----------------------------------------------------------
//
// Tactical Ops - SuperTeam KeyBinder -
//
// Source code rights:
// Copyright (C) 2002 Andrew Jakobs
// Replacement of the standard UWindowEditControl
//-----------------------------------------------------------
class stkbEditControl extends UWindowEditControl;

var stkbEditBox     EditBox;

function Created()
{
     //This clls the UWindowDialogControl.Created
     Super(UWindowDialogControl).Created();

     //This is the code originally in the UWindowEditControl
     //only changed to use the stkbEditBox instead of UWindowEditBox
     EditBox = stkbEditBox(CreateWindow(class'stkbEditBox', 2, 0, WinWidth, WinHeight));
     EditBox.NotifyOwner = Self;
     EditBox.bSelectOnFocus = True;

     EditBoxWidth = WinWidth / 2;

     SetEditTextColor(LookAndFeel.EditBoxTextColor);
}


function SetNumericOnly(bool bNumericOnly)
{
     EditBox.bNumericOnly = bNumericOnly;
}

function SetNumericFloat(bool bNumericFloat)
{
     EditBox.bNumericFloat = bNumericFloat;
}

function SetFont(int NewFont)
{
     Super.SetFont(NewFont);
     EditBox.SetFont(NewFont);
}

function SetHistory(bool bInHistory)
{
     EditBox.SetHistory(bInHistory);
}

function SetEditTextColor(Color NewColor)
{
     EditBox.SetTextColor(NewColor);
}

function Clear()
{
     EditBox.Clear();
}

function string GetValue()
{
     return EditBox.GetValue();
}

function SetValue(string NewValue)
{
     EditBox.SetValue(NewValue);
}

function SetMaxLength(int MaxLength)
{
     EditBox.MaxLength = MaxLength;
}

function Paint(Canvas C, float X, float Y)
{
     LookAndFeel.Editbox_Draw(Self, C);
     Super(UWindowDialogControl).Paint(C, X, Y);
}


function BeforePaint(Canvas C, float X, float Y)
{
     Super(UWindowDialogControl).BeforePaint(C, X, Y);
     LookAndFeel.Editbox_SetupSizes(Self, C);
}

function SetDelayedNotify(bool bDelayedNotify)
{
     Editbox.bDelayedNotify = bDelayedNotify;
}


function InsertText(string Text)
{
    EditBox.bAllSelected = False;
    EditBox.InsertText(Text);
}

