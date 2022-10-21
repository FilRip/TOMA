//=============================================================================
// TO_ScrollingMessageTexture.
//
// Tactical Ops
// - http://www.planetunreal.com/tacticalops
//
// Class Extended by Flux - Flux@tactical-ops.net
//=============================================================================

class TO_ScrollingMessageTexture expands ClientScriptedTexture;


var() localized string ScrollingMessage;
var localized string HisMessage, HerMessage;
var() Font Font;
var() color FontColor;
var() bool bCaps;
var() int PixelsPerSecond;
var() int ScrollWidth;
var() float YPos;
var() bool bResetPosOnTextChange;
var() bool bStill; //Texture won't move, no matte what value PixelsPerSecond has got
var() int TextPosition; //Ststic position of the Texture if bStill is true
var string OldText;
var int Position;
var float LastDrawTime;
var PlayerPawn Player;

/* parameters for ScrollingMessage:
%p - local player name
%h - his/her for local player
%lp - leading player's name
%lf - leading player's frags
%year - current year
%month - current month
%day - current day
%weekday - current day of the week
%hour - current client hour
%minute - current client minute
%second - current client second
%millisecond - current client Milliescond
*/

///////////////////////////////////////
// FindPlayer 
///////////////////////////////////////

simulated function FindPlayer()
{
	local PlayerPawn P;

	foreach AllActors(class'PlayerPawn', P)
		if(Viewport(P.Player) != None)
			Player = P;
}


///////////////////////////////////////
// RenderTexture 
///////////////////////////////////////

simulated event RenderTexture(ScriptedTexture Tex)
{
	local string Text;
	local PlayerReplicationInfo Leading, PRI;
	local int i;

	if (Player == None)
		FindPlayer();

	if (Player == None || Player.PlayerReplicationInfo == None || Player.GameReplicationInfo == None)
		return;

	if ( (LastDrawTime == 0) && (bStill == false) )
		Position = Tex.USize;
	else
		if (bStill)
			Position = TextPosition;
	else
		Position -= (Level.TimeSeconds-LastDrawTime) * PixelsPerSecond;

	if (Position < -ScrollWidth)
		Position = Tex.USize;

	LastDrawTime = Level.TimeSeconds;

	Text = ScrollingMessage;

	//time functions
	Text = Replace(Text, "%year", string(Level.Year));
	Text = Replace(Text, "%month", string(Level.Month));
	Text = Replace(Text, "%day", string(Level.Day));
	Text = Replace(Text, "%weekday", string(Level.DayOfWeek));

	if (Level.Hour < 10)
		Text = Replace(Text, "%hour", "0" $ string(Level.Hour));
		//makes the hours being displayed with two digits when below 10
	else
		Text = Replace(Text, "%hour", string(Level.Hour));

	if (Level.Minute < 10)
		Text = Replace(Text, "%minute", "0" $ string(Level.Minute));
		//makes the minutes being displayed with two digits when below 10
	else
		Text = Replace(Text, "%minute", string(Level.Minute));

	if (Level.Second < 10)
		Text = Replace(Text, "%second", "0" $ string(Level.Second));
	//makes the seconds being displayed with two digits when below 10
	else
		Text = Replace(Text, "%second", string(Level.Second));

	//time functions end.

	if (Player.bIsFemale)
		Text = Replace(Text, "%h", HerMessage);
	else
		Text = Replace(Text, "%h", HisMessage);

	Text = Replace(Text, "%p", Player.PlayerReplicationInfo.PlayerName);

	if (InStr(Text, "%lf") != -1 || InStr(Text, "%lp") != -1)
	{
		// find the leading player
		Leading = None;
		for (i=0; i<32; i++)
		{
			if (Player.GameReplicationInfo.PRIArray[i] != None)
			{
				PRI = Player.GameReplicationInfo.PRIArray[i];
				if ( !PRI.bIsSpectator && (Leading==None || PRI.Score>Leading.Score) )
					Leading = PRI;
			}
		}

		if (Leading == None)
			Leading = Player.PlayerReplicationInfo;

		Text = Replace(Text, "%lp", Leading.PlayerName);

		Text = Replace(Text, "%lf", string(int(Leading.Score)));
	}

	if (bCaps)
		Text = Caps(Text);

	if (Text != OldText && bResetPosOnTextChange)
	{
		Position = Tex.USize;
		OldText = Text;
	}

	Tex.DrawColoredText( Position, YPos, Text, Font, FontColor );
}


///////////////////////////////////////
// Replace 
///////////////////////////////////////

simulated function string Replace(string Text, string Match, string Replacement)
{
	local int i;

	i = InStr(Text, Match); 

	if (i != -1)
		return Left(Text, i) $ Replacement $ Replace(Mid(Text, i+Len(Match)), Match, Replacement);

	return Text;
}

defaultproperties
{
}
