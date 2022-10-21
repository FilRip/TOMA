//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTReporter.uc
// Version : 1.2
// Author  : BugBunny
//----------------------------------------------------------------------------

class TOSTReporter extends Info;

var TOSTServerMutator zzTOST;

var string zzMsg[38];

event PreBeginPlay ()
{
	zzDecryptStrings("HaraKiri");
}

function zzDecryptStrings(string zzPassword)
{
	local string zzPermString;
	local int i, j, zzk;
	local string zzCrypt, zzPass, zzKey, zzPrevPlain, zzPlain, zzPlainString;	
	
	zzPermString="[]()/&%$§'!=?+*#-_.,;:<>@ ";
	for (i=9; i>=0; i--)
		zzPermString=Chr(48+i)$zzPermString;	
	for (i=25; i>=0; i--)
		zzPermString=Chr(97+i)$zzPermString;	
	for (i=25; i>=0; i--)
		zzPermString=Chr(65+i)$zzPermString;
	zzPermString = zzPermString$zzPermString;
	
	zzPrevPlain="A";
	zzk=0;
	for (i=0; i<38; i++)
	{
		zzPlainString = "";
		for (j=0; j<Len(zzMsg[i]); j++)
		{
			zzk++;
			if (zzk > Len(zzPassword))
				zzk = 1;
			zzPass = Mid(zzPassword, zzk-1, 1);
			zzCrypt = Mid(zzMsg[i], j, 1);
			zzKey = Mid(Mid(zzPermString, InStr(zzPermString, zzPass), 88), InStr(zzPermString, zzCrypt), 1);
			zzPlain = Mid(Mid(zzPermString, InStr(zzPermString, zzPrevPlain), 88), InStr(zzPermString, zzKey), 1);
			zzPlainString = zzPlainString$zzPlain;
			zzPrevPlain = zzPlain;
		}
		zzMsg[i] = zzPlainString;
	}
}


function string zzftoa(float zzzFloat, int zzPrecision)
{
	return left(zzzFloat,instr(zzzFloat,".")+zzPrecision);
}

// ==================================================================================
// This function outputs something to the server
// ==================================================================================

function zzServerLog(actor zzMyOwner, TOSTRI zzMyRI, string zzLogString)
{
	local string zzIP;
	zzIP = PlayerPawn(zzMyOwner).GetPlayerNetworkAddress();
	zzTOST.zzsrvLog(zzMsg[0]);
	zzTOST.zzsrvLog(zzMsg[1]);
	zzTOST.zzsrvLog(zzMsg[0]);
	zzTOST.zzsrvLog(zzMsg[2]$PlayerPawn(zzMyOwner).PlayerReplicationInfo.PlayerName);
	zzTOST.zzsrvLog(zzMsg[3]$zzIP);
	zzTOST.zzsrvLog(zzMsg[4]$zzLogString);
	zzTOST.zzsrvLog(zzMsg[5]$zzftoa(level.TimeSeconds,2)$"."$zzftoa(zzMyRI.zzTimeStamp,2));
}
function zzServerLogCheat(actor zzMyOwner, TOSTRI zzMyRI, int zzType, string zzLogString, string zzMsgString)
{
	local string zzIP, zzPName, zzAction;
	local int zzj;
	local string zzCheatType;
	local bool zzCheat;

	zzCheat = False;
	if (zzMyRI.zzSelfTest) {
	// Selftest in progress, do NOT log/kick/kickban TESTED Cheats 
		switch (zzType) {
//			case 0 : zzMyRI.zzSelfTestFlags += 1; break;
			case 1 : zzMyRI.zzSelfTestFlags += 2; break;
			case 2 : zzMyRI.zzSelfTestFlags += 4; break;
//			case 3 : zzMyRI.zzSelfTestFlags += 8; break;
//			case 4 : zzMyRI.zzSelfTestFlags += 16; break;
//			case 5 : zzMyRI.zzSelfTestFlags += 32; break;
//			case 6 : zzMyRI.zzSelfTestFlags += 64; break;
//			case 7 : zzMyRI.zzSelfTestFlags += 128; break;
//			case 8 : zzMyRI.zzSelfTestFlags += 256; break;
			default : zzCheat = True; break;
		}
	}
	
	if ((!zzMyRI.zzSelfTest || zzCheat) && !zzMyRI.IsInState('ServerKick'))
	{
	// Cheater detected...
		switch (zzType) {
			case -1 : zzCheatType = zzMsg[14]; break;
			case 0  : zzCheatType = zzMsg[15]; break;
			case 1  : zzCheatType = zzMsg[16]; break;
			case 2  : zzCheatType = zzMsg[17]; break;
			case 3  : zzCheatType = zzMsg[18]; break;
			case 4  : zzCheatType = zzMsg[19]; break;
			case 5  : zzCheatType = zzMsg[20]; break;
			case 6  : zzCheatType = zzMsg[21]; break;
			case 7  : zzCheatType = zzMsg[22]; break;
			case 8  : zzCheatType = zzMsg[35]; break;
			default : zzCheatType = zzMsg[23]; break;
		}	
		
		zzIP = PlayerPawn(zzMyOwner).GetPlayerNetworkAddress();
		zzPName = PlayerPawn(zzMyOwner).PlayerReplicationInfo.PlayerName;
		zzTOST.zzsrvLog(zzMsg[0]);
		zzTOST.zzsrvLog(zzMsg[6]);
		zzTOST.zzsrvLog(zzMsg[0]);
		zzTOST.zzsrvLog(zzMsg[2]$zzPName);
		zzTOST.zzsrvLog(zzMsg[3]$zzIP);
		zzTOST.zzsrvLog(zzMsg[10]$PlayerPawn(zzMyOwner).PlayerReplicationInfo.Ping);
		zzTOST.zzsrvLog(zzMsg[11]$PlayerPawn(zzMyOwner).PlayerReplicationInfo.PacketLoss);
		zzTOST.zzsrvLog(zzMsg[7]$zzCheatType);
		zzTOST.zzsrvLog(zzMsg[8]$zzLogString);
		zzTOST.zzsrvLog(zzMsg[5]$zzftoa(level.TimeSeconds,2)$"."$zzftoa(zzMyRI.zzTimeStamp,2));

		
		zzAction = zzMsg[24];
		if (zzMyRI.zzSecurityLevel == 1) 
		{
			// Kick the user
			zzTOST.zzsrvLog(zzMsg[27]);
			zzMyRI.GotoState('zzServerKick');
			zzAction = zzMsg[25];		
		}
		else if (zzMyRI.zzSecurityLevel == 2) 
		{
			zzIP = Left(zzIP, InStr(zzIP, ":"));
			for(zzj=0;zzj<50;zzj++)
				if(Level.Game.IPPolicies[zzj] == "")
					break;
			if(zzj < 50)
			{
				Level.Game.IPPolicies[zzj] = zzMsg[29]$zzIP;
				Level.Game.SaveConfig();
			}
			else
				zzTOST.zzsrvLog(zzMsg[30]);

			zzTOST.zzsrvLog(zzMsg[28]);			
			zzMyRI.GotoState('zzServerKick');
			zzAction = zzMsg[26];
		}
		else if (zzMyRI.zzSecurityLevel == 3)
		{
			zzTOST.zzsrvLog(zzMsg[36]);
			zzAction = zzMsg[37];
			TO_GameBasics(Level.Game).TempKickBan(PlayerPawn(zzMyOwner), zzCheatType);
		}
		Level.Game.BroadcastMessage(zzMsg[31]$zzPName$zzMsg[32]$zzIP$zzMsg[33]$zzAction$zzMsg[34]$zzMsgString);
	}
}

function zzServerLog2(actor zzMyOwner, string zzLogString)
{
	zzTOST.zzsrvLog("* "$PlayerPawn(zzMyOwner).PlayerReplicationInfo.PlayerName$" - "$zzLogString);
}

function zzClientTimedOut(actor zzMyOwner, TOSTRI zzMyRI)
{
	local string zzIP;

	zzIP = PlayerPawn(zzMyOwner).GetPlayerNetworkAddress();

	zzTOST.zzsrvLog(zzMsg[0]);
	zzTOST.zzsrvLog(zzMsg[9]);
	zzTOST.zzsrvLog(zzMsg[0]);
	zzTOST.zzsrvLog(zzMsg[2]$PlayerPawn(zzMyOwner).PlayerReplicationInfo.PlayerName);
	zzTOST.zzsrvLog(zzMsg[3]$zzIP);
	zzTOST.zzsrvLog(zzMsg[10]$PlayerPawn(zzMyOwner).PlayerReplicationInfo.Ping);
	zzTOST.zzsrvLog(zzMsg[11]$PlayerPawn(zzMyOwner).PlayerReplicationInfo.PacketLoss);
	zzTOST.zzsrvLog(zzMsg[5]$zzftoa(level.TimeSeconds,2)$"."$zzftoa(zzMyRI.zzTimeStamp,2));
	zzMyOwner.Destroy();
	zzMyRI.Destroy();
}

function zzClientLoggedOn(actor zzMyOwner, TOSTRI zzMyRI)
{
	zzTOST.zzsrvLog("["$Pawn(zzMyOwner).PlayerReplicationInfo.PlayerName$"]"$zzMsg[12]$"@ "$zzftoa(level.TimeSeconds,2)$"."$zzftoa(zzMyRI.zzTimeStamp,2));
}

function ClientLoggedIn(actor zzMyOwner, TOSTRI zzMyRI)
{
	zzTOST.zzsrvLog("["$Pawn(zzMyOwner).PlayerReplicationInfo.PlayerName$"]"$zzMsg[13]$"@ "$zzftoa(level.TimeSeconds,2)$"."$zzftoa(zzMyRI.zzTimeStamp,2));
}

/*
	zzMsg(0)="* -------------------------------- *"
	zzMsg(1)="*         CLIENT WARNING           *"
	zzMsg(2)="* - Player Name : "
	zzMsg(3)="* - Player IP   : "
	zzMsg(4)="* - Warning     : "
	zzMsg(5)="* - TimeStamps  : "
	zzMsg(6)="*       CLIENT CHEAT WARNING       *"
	zzMsg(7)="* - Type        : "
	zzMsg(8)="* - Message     : "
	zzMsg(9)="*          Client TimeOut          *"
	zzMsg(10)="* - Player Ping : "
	zzMsg(11)="* - Player P/L  : "
	zzMsg(12)=" Client has been verified "
	zzMsg(13)=" Client has logged in "
	zzMsg(14)="Hacked TOST"
	zzMsg(15)="Checksum failed"
	zzMsg(16)="HUD replaced"
	zzMsg(17)="Aimbot"
	zzMsg(18)="Rootwindow replaced"
	zzMsg(19)="Centerview"
	zzMsg(20)="Flashbanghack"
	zzMsg(21)="NoRecoil"
	zzMsg(22)="Visual Cheat"
	zzMsg(23)="Unspecified"
	zzMsg(24)="logged"
	zzMsg(25)="kicked"
	zzMsg(26)="kickbanned"
	zzMsg(27)="* - Action      : Kicked"
	zzMsg(28)="* - Action      : Kickbanned"
	zzMsg(29)="DENY,"
	zzMsg(30)="* - Warning     : Ban List Full"
	zzMsg(31)="TOST : "
	zzMsg(32)=" (IP :"
	zzMsg(33)=") has been "
	zzMsg(34)=" for "
	zzMsg(35)="BuyZone"
	zzMsg(36)="* - Action      : Temp. Kickbanned"
	zzMsg(37)="temp. kickbanned"
*/

defaultproperties
{
	zzMsg(0)="$=k[-2t2,[t[-2t2,[t[-2t2,[t[-2t2,[2z"
	zzMsg(1)="-)t2,[t[-2w]-62%6#X'#5y3'2t2,[t[-2tr"
	zzMsg(2)=",=k'G*i-9+B*D/lX#/"
	zzMsg(3)="i=$]9*§@Z+i]0m,[p/"
	zzMsg(4)="&)k]Q/[6=7mV,[t[?6"
	zzMsg(5)="i)!')#;uh,[?w)h2p6"
	zzMsg(6)="§=t[-2t2<'q6 8Z5@7p,6#X'#5y3'2t2,[tz"
	zzMsg(7)="-)k]NFkzv2t2,[t[?6"
	zzMsg(8)="i)!'6.E2b8_ft[-2p6"
	zzMsg(9)="§=t[-2t2,[t)Zzp] Q)#;ud@.Qt[-2t2,[tz"
	zzMsg(10)="-)k]J<i@6&B§M&md?6"
	zzMsg(11)="i)!'9<&-Z&l-IH/2p6"
	zzMsg(12)=",).7?]zIb3]RS5t]pWc+$zwy.g"
	zzMsg(13)="t)Zzp] Q_3IJ:5=[r9wByO"
	zzMsg(14)="B,v§!1P?*/u"
	zzMsg(15)="tVzr[B(lXWx15?9"
	zzMsg(16)="X+9yBpE6i(.1"
	zzMsg(17)="QA>z6&"
	zzMsg(18)="y#t7<wy0B[<K%=pz.4s"
	zzMsg(19)="bV'zvD6gyL"
	zzMsg(20)="T#zIrn1G3u3.["
	zzMsg(21)="W,6+r?!5"
	zzMsg(22)="d&D(Z=o5*z#,"
	zzMsg(23)="U,:zi0 7w6#"
	zzMsg(24)="[wu,8s"
	zzMsg(25)="$*w1w."
	zzMsg(26)="$r4@ts&,1s"
	zzMsg(27)="VBt23V_i%#Ot2,[t6;)$wB4s"
	zzMsg(28)="VBt23V_i%#Ot2,[t6;)$wB1s+-ts"
	zzMsg(29)="c;'4f"
	zzMsg(30)="=)k]Q/[6=7mV,[t[?6v_GW5>A3 8i1t"
	zzMsg(31)="s=6ui#/"
	zzMsg(32)="tnW9dy"
	zzMsg(33)="]<_3IJ=5,'F"
	zzMsg(34)="[W]wK"
	zzMsg(35)=":TxlF1k"
	zzMsg(36)="ME12]S'i8.Wt[-2ty>;4§,F0)R411#&tt."
	zzMsg(37)="-e§,F0D_411#&tt."
}
