class TO_ScrollingMessageTexture extends ClientScriptedTexture;

var() localized string ScrollingMessage;
var localized string HisMessage;
var localized string HerMessage;
var() Font Font;
var() Color FontColor;
var() bool bCaps;
var() int PixelsPerSecond;
var() int ScrollWidth;
var() float YPos;
var() bool bResetPosOnTextChange;
var() bool bStill;
var() int TextPosition;
var string OldText;
var int Position;
var float LastDrawTime;
var PlayerPawn Player;

simulated function FindPlayer ()
{
}

simulated event RenderTexture (ScriptedTexture Tex)
{
}

simulated function string Replace (string Text, string Match, string Replacement)
{
}

