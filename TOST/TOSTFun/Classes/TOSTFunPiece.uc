//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTFunPiece.uc
// Version : 1.0
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
// 0.6		+ first beta release
// 1.0		+ first public release
// 1.1		+ extended sound slots
// 1.1.0.5  + only send hitsound when actualdamage > 0
//----------------------------------------------------------------------------

class TOSTFunPiece extends TOSTPiece config;

var config	bool	AnnounceHeadshots;
var	config	bool	OnlyHeadshots;
var config	bool	SoundMessages;
var config	bool	HitSounds;
var config	string	TriggerText[250];
var config	string	TriggeredSound[250];

var config	float	DamageFactor;

var	bool			CWMode;

// ** SETTINGS

function		GetSettings(TOSTPiece Sender)
{
	local int	Bits;

	Bits = 0;
	if (AnnounceHeadshots)
		Bits += 1;
	if (OnlyHeadshots)
		Bits += 2;
	if (SoundMessages)
		Bits += 4;
	if (HitSounds)
		Bits += 8;

	Params.Param4 = String(Bits)$";"$DamageFactor;
	SendAnswerMessage(Sender, 143);
}

function		SetSettings(TOSTPiece Sender, string Settings)
{
	local	int			i, j;
	local	string		s;

	s = Settings;
	if (s != "")
	{
		j = InStr(s, ";");
		if (j != -1)
		{
			i = int(Left(s, j));
			s = Mid(s, j+1);
		} else {
			i = int(s);
			s = "";
		}

		AnnounceHeadShots = ((i & 1) == 1);
		OnlyHeadshots = ((i & 2) == 2);
		SoundMessages = ((i & 4) == 4);
		HitSounds = ((i & 8) == 8);

		if (s != "")
		{
			j = InStr(s, ";");
			if (j != -1)
			{
				DamageFactor = float(Left(s, j));
				s = Mid(s, j+1);
			} else {
				DamageFactor = float(s);
				s = "";
			}
		}
	}
	SaveConfig();
}

// ** EVENT HANDLING

function 		EventTakeDamage( out int ActualDamage, Pawn Victim, Pawn InstigatedBy, out Vector HitLocation, out vector Momentum, name DamageType)
{
	local	float	HitHeight;

	if (!CWMode && Victim != None && InstigatedBy != None)
	{
		HitHeight = HitLocation.Z - Victim.Location.Z;
		if (AnnounceHeadshots && HitHeight > 28 && InstigatedBy.IsA('PlayerPawn'))
		{
			Params.Param1 = 2;
			Params.Param2 = 0;
			Params.Param6 = PlayerPawn(InstigatedBy);
			Params.Param4 = "Announcer.Headshot";
			SendClientMessage(121);
		}

		if (OnlyHeadshots && HitHeight <= 28)
		{
			ActualDamage = 0;
		}

		if (DamageFactor > 0)
			ActualDamage *= DamageFactor;

		if (HitSounds && InstigatedBy.IsA('PlayerPawn') && ActualDamage > 0 && Damagetype!='Explosion')
		{
    		Params.Param1 = 2;
			Params.Param2 = 0;
			Params.Param6 = PlayerPawn(InstigatedBy);
			if (Victim.PlayerReplicationInfo.Team==InstigatedBy.PlayerReplicationInfo.Team)
			   Params.Param4 = "TOSTClient.hitsoundteam";
			else
			   Params.Param4 = "TOSTClient.hitsound";
			SendClientMessage(121);
		}
	}
	super.EventTakeDamage(ActualDamage, Victim, InstigatedBy, HitLocation, Momentum, DamageType);
}

function bool 	EventTeamMessage( Actor Sender, Pawn Receiver, PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep )
{
	local	int		i;

	if (!CWMode && SoundMessages && Receiver.IsA('PlayerPawn'))
	{
		for (i=0; i<ArrayCount(TriggerText); i++)
		{
			if (TriggerText[i] != "" && InStr(Caps(S), Caps(TriggerText[i])) != -1)
			{
				Params.Param1 = 1;
				if (PRI != none)
					Params.Param2 = PRI.PlayerID;
				else
					Params.Param2 = 0;
				Params.Param6 = PlayerPawn(Receiver);
				Params.Param4 = TriggeredSound[i];
				SendClientMessage(121);
			}
		}
	}
	return Super.EventTeamMessage(Sender, Receiver, PRI, S, Type, bBeep);
}

// ** MESSAGE HANDLING

function	EventMessage(TOSTPiece Sender, int MsgIndex)
{
	switch (MsgIndex)
	{
		// CWModeChanges
		case 117			:	CWMode = Sender.Params.Param5;
								break;
		// GetSettings
		case 143 			:	GetSettings(Sender);
								break;
	}
	super.EventMessage(Sender, MsgIndex);
}

function	EventAnswerMessage(TOSTPiece Sender, int MsgIndex)
{
	switch (MsgIndex)
	{
		// SetSettings - report back error messages
		case 144 			:	SetSettings(Sender, Sender.Params.Param4);
								break;
	}
}

defaultproperties
{
	PieceName="TOST Fun"
	PieceVersion="1.1.0.5"
	ServerOnly=true
	PieceOrder=80

	BaseMessage=170

	AnnounceHeadshots=false
	OnlyHeadshots=false
	SoundMessages=false
    HitSounds=false

	DamageFactor=1.0
}
