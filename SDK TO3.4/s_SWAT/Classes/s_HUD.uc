class s_HUD extends ChallengeTeamHUD;

struct s_DeathMessages
{
	var string Killer;
	var string Victim;
	var Color KillerC;
	var Color VictimC;
	var byte EndOfLife;
};

enum ETOHudFontSize
{
	FS_SMALL,
	FS_BIG
};

var bool bDisplayMapChangeMessage;
var bool bForceBriefing;
var bool bToggleCredits;
var bool bToggleBriefing;
var bool bToggleBuymenu;
var bool bPreroundShown;
var bool bPreroundHidden;
var bool bShowAlternativeHint;
var float CTVal;
var TO_ConsoleTimer ct;
var bool bDrawCT;
var byte rmap;
var byte FrameHint[2];
var byte FrameTime;
var byte FrameTeaminfo;
var byte FrameHitlocation[8];
var byte FrameNightvision;
var byte LastFrameNightvision;
var float LastDeltaNightvision;
var float LastDeltaTime;
var float LastDeltaHint;
var float MoneyDrawTime;
var byte AltHintTime;
var int MoneyVariationAmount;
var UWindowRootWindow Root;
var TO_DesignInfo Design;
var TO_GUIBaseMgr UserInterface;
var bool bSinglePlayer;
var string Hint[2];
var string TextPrompt;
var float YOffsetMsgs;
var float OldScreenResX;
var float OldScreenResY;
var bool bColorblind;
var HUDLocalizedMessage ShortMessageQueue[6];
var bool bNVActive;
var bool bFadeOut;
var bool bFadeIn;
var TO_NVLight NVLight;
var byte Fadeval;
var globalconfig bool bTranslucentText;
var globalconfig bool bDrawWidescreen;
var globalconfig bool bDrawBackground;
var globalconfig bool bDrawArmorguy;
var globalconfig bool bDrawHitlocation;
var globalconfig bool bDrawTime;
var globalconfig bool bDrawText;
var globalconfig bool bDrawHint;
var globalconfig bool bDrawChat;
var globalconfig bool bDrawDeathmsg;
var globalconfig bool bDrawPrebriefing;
var localized string TextHintBombzone[2];
var localized string TextHintRescue[2];
var localized string TextHintEscape[2];
var localized string TextHintEndround;
var localized string LS_Killed;
var localized string LS_Died;
var localized string LS_DefusingBomb;
var s_DeathMessages s_DeathM[6];
var int s_DeathM_idx;

simulated function PostBeginPlay()
{
}

event Destroyed()
{
}

function Timer ()
{
}

simulated function Tick (float DeltaTime)
{
}

simulated function PostRender (Canvas Canvas)
{
}

final exec function ToggleHUDCredits ()
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

final simulated function DrawConsoleTimerHUD (bool bIsCT, bool bUsing, float CTPercentage)
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

simulated function TOHud_DrawMoney (Canvas Canvas)
{
}

simulated function TOHud_DrawCrosshair (Canvas Canvas, int X, int Y)
{
}

simulated function TOHud_DrawHitlocation (Canvas Canvas)
{
}

simulated function TOHud_DrawTeaminfo (Canvas Canvas)
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

simulated function TOHud_DrawBlinded (Canvas Canvas)
{
}

simulated function TOHud_DrawNightvision (Canvas Canvas, bool hudmodfix)
{
}

simulated function TOHud_DrawConsoletimer (Canvas Canvas)
{
}

simulated function TOHud_DrawDeathmessage (Canvas Canvas)
{
}

simulated function TOHud_DrawShortmessages (Canvas Canvas)
{
}

simulated function TOHud_DrawTypingPrompt (Canvas Canvas, Console Console)
{
}

simulated function TOHud_DrawCentermessages (Canvas Canvas)
{
}

simulated function bool TOHud_DrawIdentification (Canvas Canvas)
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

final simulated function Add_Death_Message (PlayerReplicationInfo KillerPRI, PlayerReplicationInfo VictimPRI)
{
}

final simulated function Shift_Death_Message ()
{
}

final simulated function bool TOHud_Tool_BeforePaint (Canvas Canvas)
{
}

final simulated function TOHud_Tool_SetTextstyle (Canvas Canvas)
{
}

final simulated function TOHud_Tool_SetPercentColor (Canvas Canvas, int Percent)
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

final simulated function bool IsPlayerOwner ()
{
}

simulated function TOHud_Tool_DrawDigit (Canvas Canvas, int digit, ETOHudFontSize Size, float inc)
{
}

simulated function TOHud_Tool_DrawNum (Canvas Canvas, int Value, ETOHudFontSize Size, int maxdigits)
{
}

simulated function TOHud_Tool_DrawNumR (Canvas Canvas, int Value, ETOHudFontSize Size, int maxdigits)
{
}

simulated function TOHud_Tool_DrawTime (Canvas Canvas, int Time, int mdigits)
{
}

simulated function TOHud_Tool_TickTime (float DeltaTime)
{
}

simulated function TOHud_Tool_TickHint (byte hid)
{
}

simulated function TOHud_Tool_DrawHint (Canvas Canvas, byte hid, float Y, float vt, float yt)
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

final function ShowDebugs_Bot (Canvas C, s_bot B, out float Y, bool bLeftIdent)
{
}

final function ShowDebugBot (Canvas C, Bot B, out float Y, bool bLeftIdent)
{
}

final function ShowDebugHostage (Canvas C, s_NPCHostage H, out float Y, bool bLeftIdent)
{
}

final function ShowDebugPlayer (Canvas C, S_Player P, out float Y, bool bLeftIdent)
{
}

final function ShowDebugActor (Canvas C, Actor P, out float Y, bool bLeftIdent)
{
}

final function ShowDebugPawn (Canvas C, Pawn P, out float Y, bool bLeftIdent)
{
}

final function ShowDebug (Canvas C)
{
}

final function WriteDebugString (Canvas C, string CurrentMessage, out float Y, bool bLeftIdent)
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
