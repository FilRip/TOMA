//-----------------------------------------------------------
//    FramedWindow KeyBinder
//-----------------------------------------------------------
//
// Tactical Ops - SuperTeam KeyBinder -
//
// Source code rights:
// Copyright (C) 2002 Andrew Jakobs
//-----------------------------------------------------------
class stkbFWKeyBinder expands UWindowFramedWindow
    config;

var config int SavedTop, SavedLeft, SavedWidth, SavedHeight;

//------------------------------------------
//       Created (Override)
//------------------------------------------
function Created()
{

    Super.Created();

    if(SavedWidth < 580)
        SavedWidth = 580;
    if(SavedHeight < 400)
        SavedHeight = 400;
    if(SavedTop < 0)
        SavedTop = (Root.WinHeight - SavedHeight) / 2;
    if(SavedTop < 0)
        SavedTop = 16;
    if(SavedLeft < 0)
        SavedLeft = (Root.WinWidth - SavedWidth) / 2;
    if(SavedLeft < 0)
        SavedLeft = 16;

    SetSize(SavedWidth, SavedHeight);
    MinWinWidth = 580;
    MinWinHeight = 400;
    WinLeft = SavedLeft;
    WinTop = SavedTop;
    bSizable = True;
}


//------------------------------------------
//       Resized (Override)
//------------------------------------------
function Resized()
{
    if(WinWidth != 580)
        WinWidth = 580;

    SavedWidth = WinWidth;
    SavedHeight = WinHeight;

    super.Resized();
}


//------------------------------------------
//       Close (Override)
//------------------------------------------
function Close(optional bool bByParent)
{
    SavedWidth = WinWidth;
    SavedHeight = WinHeight;
    SavedLeft = WinLeft;
    SavedTop = WinTop;

    SaveConfig();

    Super.Close(bByParent);  // also handles saving to ini
}

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------

defaultproperties
{
    SavedTop=-1
    SavedLeft=-1
    SavedWidth=580
    SavedHeight=400
    ClientClass=Class'stkbDCWKeyBinder'
    WindowTitle="Tactical Ops: AoT  - SuperTeam KeyBinder -    v1.2         programmed by: Andrew 'SuperDre' Jakobs"
}
