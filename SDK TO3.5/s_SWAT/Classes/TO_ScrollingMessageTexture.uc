class TO_ScrollingMessageTexture extends Botpack.ClientScriptedTexture;

var PlayerPawn Player;
var int Position;
var float LastDrawTime;
var bool bStill;
var Font Font;
var Color FontColor;
var bool bCaps;
var int PixelsPerSecond;
var int ScrollWidth;
var float YPos;
var bool bResetPosOnTextChange;
var int TextPosition;

simulated function string Replace (string Text, string Match, string Replacement)
{
}

function RenderTexture (ScriptedTexture Tex)
{
}

simulated function FindPlayer ()
{
}


defaultproperties
{
}

