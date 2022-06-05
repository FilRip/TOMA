class TO_DesignInfo extends Info;

const TRANSPMODE_MODULATED=2;
const TRANSPMODE_TRANSLUCENT=1;
const TRANSPMODE_MASKED=0;

var Color ColorGrey;
var Color ColorDarkgrey;
var Color ColorBlack;
var Color ColorDarkred;
var Color ColorRed;
var Color ColorOrange;
var Color ColorBlue;
var Color ColorYellow;
var Color ColorGreen;
var Color ColorDarkgreen;
var Color ColorWhite;
var Color ColorSuperwhite;
var Color ColorHudBg;
var Color ColorHitlocation;
var Color ColorBombzone;
var Color ColorEscape;
var Color ColorRescue;
var Color ColorTeam[4];
var Font Font5;
var Font Font8;
var Font Font10;
var Font Font12;
var Font Font14;
var Font Font16;
var Font Font18;
var Font Font20;
var Font Font22;
var Font Font30;
var float LineHeight;
var float LineSpacing;
var localized string NameTeam[2];
var globalconfig int BgQuality;

simulated function PostBeginPlay ()
{
}

function byte GetResolution (Canvas Canvas)
{
}

function int GetGoodWidth (int Width, int Height)
{
}

function SetTinyFont (Canvas Canvas)
{
}

function SetVerySmallFont (Canvas Canvas)
{
}

function SetSmallFont (Canvas Canvas)
{
}

function SetScoreboardFont (Canvas Canvas)
{
}

function SetTableFont (Canvas Canvas)
{
}

function SetHeadlineFont (Canvas Canvas)
{
}

function SetBgTransparency (Canvas Canvas)
{
}

function Texture GetBgTexture ()
{
}
