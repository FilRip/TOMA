//-----------------------------------------------------------
//    MenuModItem KeyBinder
//-----------------------------------------------------------
//
// Tactical Ops - SuperTeam KeyBinder -
//
// Source code rights:
// Copyright (C) 2002 Andrew Jakobs
//-----------------------------------------------------------
class stkbMMIKeyBinder expands UMenuModMenuItem;

//#exec TEXTURE IMPORT NAME=FlashBangTexture FILE=TEXTURES\FlashBang.bmp
//#exec TEXTURE IMPORT NAME=RifleM60Texture FILE=TEXTURES\Riflem60.bmp

//------------------------------------------
//       Execute (Override)
//------------------------------------------
function Execute()
{
    // create a default window (everything will be set in stkbWindow
    MenuItem.Owner.Root.Createwindow(class'stkbFWKeyBinder', 1, 1, 1, 1);
}

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------

defaultproperties
{
    MenuCaption="Tactical Ops: AoT  - SuperTeam KeyBinder - v1.2"
    MenuHelp="Let's you bind keys with a visual keyboard/mouse/joystick"
}
