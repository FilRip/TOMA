class s_HUD extends Botpack.ChallengeTeamHUD;

var TO_DesignInfo Design;
var TO_GUIBaseMgr UserInterface;
var HUDLocalizedMessage ShortMessageQueue;
var byte FrameHitlocation;
struct s_DeathMessages
{
	var string Killer;
	var string Victim;
	var Color KillerC;
	var Color VictimC;
	var byte EndOfLife;
}
var s_DeathMessages s_DeathM;
var byte Fadeval;
var TO_HUDMutator TO_HUDMutator;
var bool bDrawBackground;
var byte FrameHint;
var int s_DeathM_idx;
var UWindowRootWindow Root;
var byte FrameTeaminfo;
var float WeaponModeX;
var float WeaponModeY;
var byte FrameTime;
var bool bDrawTime;
var float MoneyDrawTime;
var bool bDrawArmorguy;
var bool bDrawText;
var int MoneyVariationAmount;
var bool bSinglePlayer;
var bool bFadeOut;
var bool bFadeIn;
var TO_NVLight NVLight;
var bool bDrawHint;
var bool bDrawCT;
var byte FireModeDrawStyle;
var bool bPreroundHidden;
var bool bCustomCrossHairColor;
var bool bDrawWidescreen;
var bool bNVActive;
var TO_ConsoleTimer ct;
var float CTVal;
var bool bDisplayMapChangeMessage;
var bool bNadeColors;
var byte CustomCrosshairColorB;
var byte CustomCrosshairColorG;
var byte CustomCrosshairColorR;
var bool bGreenCrossHairForTeam;
var bool DisplayRoundsPlayed;
var bool bDrawDeathmsg;
var bool bDrawChat;
var bool bDrawHitlocation;
var bool bTranslucentText;
var bool bAutoTeamInfo;
var bool bColorblind;
var float YOffsetMsgs;
var float LastDeltaHint;
var float LastDeltaTime;
var bool bShowAlternativeHint;
var bool bToggleBuymenu;
var bool bToggleBriefing;
var bool bToggleCredits;
var bool bForceBriefing;
var bool bPreroundShown;
var byte AltHintTime;
var float OldScreenResX;
var float OldScreenResY;
var byte rmap;
var byte FrameNightvision;
var byte LastFrameNightvision;
var float LastDeltaNightvision;
var bool bDrawPrebriefing;

final simulated function TOHud_Tool_SetTextstyle (Canvas Canvas)
{
}

final simulated function DrawConsoleTimerHUD (bool bIsCT, bool bUsing, float CTPercentage)
{
}

function TOHud_Tool_SetPercentColor (Canvas Canvas, int Percent)
{
}

final simulated function Add_Death_Message (PlayerReplicationInfo KillerPRI, PlayerReplicationInfo VictimPRI)
{
}

final simulated function Shift_Death_Message ()
{
}

final simulated function bool IsPlayerOwner ()
{
}

final simulated function bool TOHud_Tool_BeforePaint (Canvas Canvas)
{
}

simulated function PostBeginPlay ()
{
}

event Destroyed ()
{
}

function Timer ()
{
}

simulated function Tick (float DeltaTime)
{
}

simulated function DisableNV ()
{
}

function bool ProcessKeyEvent (int Key, int Action, float Delta)
{
}

simulated function PostRender (Canvas Canvas)
{
}

final exec function ToggleNadeColors ()
{
}

final exec function togglehudcredits ()
{
}

exec function ShowServerInfo ()
{
}

final exec function ToggleHUDBriefing ()
{
}

final exec function ToggleHUDBuymenu ()
{
}

final exec function ToggleHUDTeaminfo ()
{
}

final exec function ToggleUIMode ()
{
}

simulated exec function ScrScores ()
{
}

exec function GrowHUD ()
{
}

exec function ShrinkHUD ()
{
}

simulated function Message (PlayerReplicationInfo PRI, coerce string Msg, name MsgType)
{
}

function SetDamage (Vector HitLoc, float Damage)
{
}

simulated function ResolutionChanged (float W, float H)
{
}

simulated function Add_Money_Message (int Amount)
{
}

simulated function TOHud_DrawRoundtime (Canvas Canvas)
{
}

simulated function TOHud_DrawLeveltime (Canvas Canvas)
{
}

function TOHud_DrawMoney (Canvas Canvas)
{
}

simulated function TOHud_DrawCrosshair (Canvas Canvas, int X, int Y)
{
}

simulated function TOHud_DrawHitlocation (Canvas Canvas)
{
}

final latent function TOHud_DrawTeaminfo (Canvas Canvas)
{
}

simulated function TOHud_DrawAmmo (Canvas Canvas)
{
}

simulated function TOHud_DrawStatus (Canvas Canvas)
{
}

simulated function TOHud_DrawIcons (Canvas Canvas)
{
}

simulated function TOHud_DrawWidescreen (Canvas Canvas, bool hudmodfix)
{
}

function TOHud_DrawBlinded (Canvas Canvas)
{
}

simulated function TOHud_DrawNightvision (Canvas Canvas, bool hudmodfix)
{
}

function TOHud_DrawConsoletimer (Canvas Canvas)
{
}

simulated function TOHud_DrawDeathmessage (Canvas Canvas)
{
}

function TOHud_DrawShortmessages (Canvas Canvas)
{
}

simulated function TOHud_DrawTypingPrompt (Canvas Canvas, Console Console)
{
}

simulated function TOHud_DrawCentermessages (Canvas Canvas)
{
}

final latent function bool TOHud_DrawIdentification (Canvas Canvas)
{
}

simulated function TOHud_DrawHints (Canvas Canvas)
{
}

simulated function TOHud_DrawSpecials (Canvas Canvas)
{
}

simulated function TOHud_DarkenScreen (Canvas Canvas)
{
}

simulated function TOHud_SetIDColor (Canvas Canvas, int Type)
{
}

simulated function TOHud_Tool_ClearHitlocation ()
{
}

simulated function TOHud_SetTeamColor (Canvas Canvas, int Team)
{
}

simulated function PlayerReplicationInfo FindPRI (int PlayerID)
{
}

simulated function bool IsPreRound ()
{
}

simulated function TOHud_Tool_DrawDigit (Canvas Canvas, int digit, ETOHudFontSize Size, float inc)
{
}

function TOHud_Tool_DrawNum (Canvas Canvas, int Value, ETOHudFontSize Size, int maxdigits)
{
}

function TOHud_Tool_DrawNumR (Canvas Canvas, int Value, ETOHudFontSize Size, int maxdigits)
{
}

function TOHud_Tool_DrawTime (Canvas Canvas, int Time, int mdigits)
{
}

simulated function TOHud_Tool_TickTime (float DeltaTime)
{
}

simulated function TOHud_Tool_TickHint (byte hid)
{
}

function TOHud_Tool_DrawHint (Canvas Canvas, byte hid, float Y, float vt, float yt)
{
}

simulated function TOHud_Tool_DrawIcon (Canvas Canvas, Texture Icon, float UB, float vb, float ui, float vi)
{
}

simulated function TOHud_DrawSpectatedId (Canvas Canvas)
{
}

simulated function Actor TraceActorDebug ()
{
}

simulated function bool TraceIdentify (Canvas Canvas)
{
}

simulated function DrawCrossHair (Canvas Canvas, int X, int Y)
{
}

simulated function DrawAmmo (Canvas Canvas)
{
}

simulated function DrawStatus (Canvas Canvas)
{
}

simulated function DrawSprayPaint (Canvas C)
{
}

simulated function bool DrawIdentifyInfo (Canvas Canvas)
{
}

final simulated function Draw_Death_Message (Canvas C)
{
}

final simulated function DrawConsoleTimer (Canvas C)
{
}

final simulated function DrawRoundT (Canvas Canvas)
{
}

simulated function DrawFragCount (Canvas Canvas)
{
}

simulated function DrawWeapons (Canvas Canvas)
{
}

function DrawTalkFace (Canvas Canvas, int i, float YPos)
{
}

function bool DrawSpeechArea (Canvas Canvas, float XL, float YL)
{
}

simulated function DrawTeam (Canvas Canvas, TeamInfo TI)
{
}


defaultproperties
{
}

