//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTXSupport.uc
// Version : 0.5
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ First Release
//----------------------------------------------------------------------------

class TOSTXSupport extends TOSTPiece config;

var config	bool	XSupportEnabled;

var config	string	User;
var config	string	Pass;

var	TOSTXServerLink		SrvLink;
var TOSTXSpectator		Spec;

var TOSTXClientLink		CltLink;	// send answer to this link

// ** Event Handling

function 		EventPlayerConnect(Pawn Player)
{
	Super.EventPlayerConnect(Player);
}

function 		EventPlayerDisconnect(Pawn Player)
{
	Super.EventPlayerDisconnect(Player);
}

function 		EventNameChange(Pawn Other)
{
	Super.EventNameChange(Other);
}

function 		EventTeamChange(Pawn Other)
{
	Super.EventTeamChange(Other);
}

function		EventAfterEndGame(string Reason)
{
	Super.EventAfterEndGame(Reason);
}

function bool	EventRestartGame()
{
	return Super.EventRestartGame();
}

function 		EventScoreKill(Pawn Killer, Pawn Other)
{
	Super.EventScoreKill(Killer, Other);
}

function 		EventTakeDamage( out int ActualDamage, Pawn Victim, Pawn InstigatedBy, out Vector HitLocation, out vector Momentum, name DamageType)
{
	Super.EventTakeDamage(ActualDamage, Victim, InstigatedBy, HitLocation, Momentum, DamageType);
}

function	EventInit()
{
	if (XSupportEnabled)
	{
		SrvLink	= spawn(class'TOSTXServerLink', self);
		SrvLink.Master = self;
		SrvLink.Init();

		Spec = Level.spawn(class'TOSTXSpectator');
		Spec.SrvLink = SrvLink;
	}

	super.EventInit();
}

function	EventAnswerMessage(TOSTPiece Sender, int MsgIndex)
{
	if (CltLink != none)
		CltLink.Answer(MsgIndex, Params.Param1, Params.Param2, Params.Param3, Params.Param4, Params.Param5);
}

defaultproperties
{
	bHidden=True

	PieceName="TOST XSupport"
	PieceVersion="0.5.0.0"
	PieceOrder=20
	ServerOnly=True

	XSupportEnabled=false
}
