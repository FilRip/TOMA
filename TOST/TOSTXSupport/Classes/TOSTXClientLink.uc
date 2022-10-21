//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTXClientLink.uc
// Version : 0.5
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ First Release
//----------------------------------------------------------------------------

class TOSTXClientLink extends TCPLink;

var	TOSTXServerLink		SrvLink;

var bool	LoggedIn;
var int		InfoLevel;

var byte	Buffer[255];
var byte	Pos;
var byte	Size;

event Accepted()
{
	SrvLink = TOSTXServerLink(Owner);

	ReceiveMode = RMODE_Manual;
	LinkMode = MODE_Binary;
}

event Closed()
{
	Destroy();
}

event Timer()
{
	Close();
}

function	ClearBuffer()
{
	local	int	 i;

	for(i=0; i<255; i++)
		Buffer[i] = 0;
	Pos = 0;
}

// read/write binary data

function int	ReadInt()
{
	return ((Buffer[Pos++] << 24) + (Buffer[Pos++] << 16) + (Buffer[Pos++] << 8) + Buffer[Pos++]);
}

function bool	ReadBool()
{
	return (Buffer[Pos++] != 0);
}

function string	ReadString()
{
	local	string	s;

	while(Buffer[Pos] != 0)
		s = s$Chr(Buffer[Pos++]);
	Pos++;
	return	s;
}

function byte	ReadByte()
{
	return Buffer[Pos++];
}

function float	ReadFloat()
{
	// workaround only - not able to read IEEE float type
	return (float(ReadInt()) / 10000.0);
}

function WriteInt(int i)
{
	Buffer[Pos++] = (i >> 24) & 0xFF;
	Buffer[Pos++] = (i >> 16) & 0xFF;
	Buffer[Pos++] = (i >> 8) & 0xFF;
	Buffer[Pos++] = i & 0xFF;
}

function WriteBool(bool b)
{
	if (b)
		Buffer[Pos++] = 0xFF;
	else
		Buffer[Pos++] = 0x00;
}

function WriteString(string s)
{
	local	int i;

	for(i=0; i<Len(s); i++)
		Buffer[Pos++] = Asc(Mid(s, i, 1)) & 0xFF;
	Buffer[Pos++] = 0x00;
}

function WriteByte(byte b)
{
	Buffer[Pos++] = b;
}

function WriteFloat(float f)
{
	// workaround only - not able to write IEEE float type
	WriteInt(int(f * 10000));
}

function Tick(float Delta)
{
	if (IsDataPending())
	{
		ClearBuffer();
		Size = 255;
		ReadBinary(Size, Buffer);
		ProcessBinary();
	}
}

function ProcessBinary()
{
	local	int	i;

	Pos = 1;
	switch (Buffer[0]) {
		case 0 :	LogIn(ReadString(), ReadString()); break;
		case 1 :	LogOut(); break;
		case 2 :	SetInfoLevel(ReadInt()); break;
		case 10 :	SendMessage(ReadInt(), ReadInt(), ReadInt(), ReadFloat(), ReadString(), ReadBool()); break;
		case 11 :	ConsoleCmd(ReadString()); break;
		case 20 :	SendPlayerList(); break;
	}
}

function	Login(string User, string Pass)
{
	LoggedIn = (SrvLink.Master.User == User && SrvLink.Master.Pass == Pass && User != "" && Pass != "");
	if (LoggedIn)
		SrvLink.Master.XLog("User"@User@"logged in succesfully - IP"@IpAddrToString(RemoteAddr));
	ClearBuffer();
	WriteByte(0);
	WriteBool(LoggedIn);
	SendBinary(Pos, Buffer);
}

function	LogOut()
{
	ClearBuffer();
	WriteByte(1);
	WriteBool(true);
	SendBinary(Pos, Buffer);
}

function	SetInfoLevel(int Level)
{
	if (LoggedIn)
		InfoLevel = Level;
}

function	SendMessage(int MsgIndex, int i1, int i2, float f, string s, bool b)
{
	ClearBuffer();
	WriteByte(2);
	if (!LoggedIn)
	{
		WriteBool(false);
		SendBinary(Pos, Buffer);
		return;
	}
	WriteBool(true);

	SrvLink.Master.CltLink = self;
	SrvLink.Master.Params.Param1 = i1;
	SrvLink.Master.Params.Param2 = i2;
	SrvLink.Master.Params.Param3 = f;
	SrvLink.Master.Params.Param4 = s;
	SrvLink.Master.Params.Param5 = b;
	SrvLink.Master.Params.Param6 = none;

	SrvLink.Master.SendMessage(MsgIndex);
	// optional answer is included "automatically" -> see function Answer below
	SendBinary(Pos, Buffer);

	SrvLink.Master.CltLink = none;
}

function	Answer(int MsgIndex, int i1, int i2, float f, string s, bool b)
{
	WriteInt(MsgIndex);
	WriteInt(i1);
	WriteInt(i2);
	WriteFloat(f);
	WriteString(s);
	WriteBool(b);
}

function	ConsoleCmd(string Cmd)
{
	local	string	s;

	if (LoggedIn)
	{
		if (Left(Cmd, 4) ~= "say ")
			Level.BroadcastMessage("Admin: "$Mid(Cmd, 4));
		else
		{
			s = Level.Game.ConsoleCommand(Cmd);
			if (s != "")
				ConsoleMessage("(Result)"@s);
			else
				ConsoleMessage("(No Result)");
		}
	}
}

function	ConsoleMessage(string Msg)
{
	ClearBuffer();
	WriteByte(3);
	WriteString(Msg);
	SendBinary(Pos, Buffer);
}

function	SendPlayerList()
{
	local	int		i;
	local	PlayerReplicationInfo	PRI;
	local	Pawn	P;

	ClearBuffer();
	WriteByte(20);
	WriteBool(true);
	SendBinary(Pos, Buffer);
	for (P=Level.PawnList; P!=None; P=P.NextPawn)
	{
		if(	PlayerPawn(P) != None
			&&	P.PlayerReplicationInfo != None
			&&	NetConnection(PlayerPawn(P).Player) != None)
		{
			ClearBuffer();
			PRI = P.PlayerReplicationInfo;
			WriteInt(PRI.PlayerID);
			WriteString(PRI.PlayerName);
			WriteString(PlayerPawn(P).GetPlayerNetworkAddress());
			WriteByte(PRI.Team);
			WriteInt(PRI.Score);
			WriteInt(PRI.Deaths);
			WriteBool(PRI.bIsSpectator);
			SendBinary(Pos, Buffer);
		}
	}
	ClearBuffer();
	WriteInt(0xFFFFFFFF);
	SendBinary(Pos, Buffer);
}

defaultproperties
{
}
