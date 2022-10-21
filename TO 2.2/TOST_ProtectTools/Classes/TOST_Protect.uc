class TOST_Protect extends TOST_ServerModule;

// New FilRip
// package data
struct PackData {
	var int		zzNames;
	var int		zzNameSpace;
	var int		zzImports;
	var int		zzExports;
	var int		zzGenerations;
	var int		zzLazy;
};
struct PackageData {
	var string		zzPkgName;
	var int			zzCount;
	var PackData	zzVersion[3];
};
var PackageData		zzPackages[200];
var int				zzPackageCount;
var string			zzServerPackages[20];
var int				zzServerPkgCount[20];
var int				zzSrvPkgLines;
var string	zzTOSTPackage;	// name of the TOST package
var string CheckMe;
// End new FilRip

// New stuff from FilRip
// code from TOST 3.0

var string zzMsg[37];
var() config int SecurityLevel; // 0=Nothing, 1=Kicked, 2=Banned, 3=TempKickBanned (during the whole map)

// * CollectPackageData - collect all data for packages
function xxCollectPackageData()
{
	local string	zzUsedPackages, zzPackage, zzPkgName, zzTOSTPkg;

	zzUsedPackages = Self.ConsoleCommand("OBJ LINKERS");

 	zzPackage = xxParsePackage(zzUsedPackages);
	zzSrvPkgLines = 0;
	while (zzPackage != "")
	{
		zzPkgName = xxParseLine(zzPackage, zzPackageCount);
		zzPackage = xxParsePackage(zzUsedPackages);
		if (zzPkgName != "" && Caps(zzPkgName) != zzTOSTPackage)
		{
			if (zzPackageCount > zzSrvPkgLines*20) {
				zzSrvPkgLines++;
				zzServerPackages[zzSrvPkgLines-1] = zzPkgName;
				zzServerPkgCount[zzSrvPkgLines-1] = 1;
			} else {
				zzServerPackages[zzSrvPkgLines-1] = zzServerPackages[zzSrvPkgLines-1]$";"$zzPkgName;
				zzServerPkgCount[zzSrvPkgLines-1] = zzServerPkgCount[zzSrvPkgLines-1] + 1;
			}
		}
	}
}

// * ParsePackage - determines the package name
function string xxParsePackage(out string zzUsedPackages)
{
	local int zzPos;
	local string zzPackage;

	zzPos = instr(zzUsedPackages,".u");
	if (zzPos != -1)
	{
		zzPackage = left(zzUsedPackages, zzPos);
		zzUsedPackages = mid(zzUsedPackages, zzPos+1);
	}
	else
	{
		zzPackage = zzUsedPackages;
		zzUsedPackages = "";
	}
	return zzPackage;
}

// * ParseLine - Gets all the values of 1 full line from the obj linker
function string xxParseLine(string zzpackage, out int zzPackageCnt)
{
	local int zzPackageNo, zzSubNo, zzI;
	local string zzPackageName;
	local PackData zzTestData;

	zzPackageName = xxParsePart(zzpackage,"(Package ",")");
	// valid package name ?
	if (zzPackageName == "")
		return zzPackageName;

	// disallowed package ?
/*	if (InStr(Caps(";"$DisallowPackages$";"), Caps(";"$zzPackageName$";")) != -1)
	{
		// perform dummy parsing
		zzTestData.zzNames = int(xxParsePart(zzpackage,"="," "));
		zzTestData.zzNameSpace = int(xxParsePart(zzpackage,"/","K"));
		zzTestData.zzImports = int(xxParsePart(zzpackage,"="," "));
		zzTestData.zzExports = int(xxParsePart(zzpackage,"="," "));
		zzTestData.zzGenerations = int(xxParsePart(zzpackage,"="," "));
		zzTestData.zzLazy = int(xxParsePart(zzpackage,"="," "));

		zzPackageName = "";

		return zzPackageName;

	} else {
        */
		// already have a version of this package ?
		zzPackageNo = xxGetPackageData(zzPackageName);
		if (zzPackageNo == -1) {
			// no
			zzPackageNo = zzPackageCnt;
			zzPackageCnt++;
			zzSubNo = 0;
			zzPackages[zzPackageNo].zzPkgName = zzPackageName;
			zzPackages[zzPackageNo].zzCount = 1;
		} else {
			// yes
			zzSubNo = zzPackages[zzPackageNo].zzCount;
			zzPackageName = "";
		}
		zzTestData.zzNames = int(xxParsePart(zzpackage,"="," "));
		zzTestData.zzNameSpace = int(xxParsePart(zzpackage,"/","K"));
		zzTestData.zzImports = int(xxParsePart(zzpackage,"="," "));
		zzTestData.zzExports = int(xxParsePart(zzpackage,"="," "));
		zzTestData.zzGenerations = int(xxParsePart(zzpackage,"="," "));
		zzTestData.zzLazy = int(xxParsePart(zzpackage,"="," "));
		if (zzPackageName != "") {
			// add new (first) version
			zzPackages[zzPackageNo].zzVersion[zzSubNo] = zzTestData;
		} else {
			// test for redundant data
			for (zzI=0; zzI<zzSubNo; zzI++)
				if ((zzPackages[zzPackageNo].zzVersion[zzI].zzNames - zzPackages[zzPackageNo].zzVersion[zzI].zzGenerations == zzTestData.zzNames - zzTestData.zzGenerations)
				   && zzPackages[zzPackageNo].zzVersion[zzI].zzImports == zzTestData.zzImports
				   && zzPackages[zzPackageNo].zzVersion[zzI].zzExports == zzTestData.zzExports)
				{
					return zzPackageName;
				}
			// add new version
			zzPackages[zzPackageNo].zzVersion[zzSubNo] = zzTestData;
			zzPackages[zzPackageNo].zzCount = zzPackages[zzPackageNo].zzCount + 1;
		}
		return zzPackageName;
//	}
}

// * ParsePart - Grabs the different potions of an obj linker entry
function string xxParsePart(out string zzpackage, string zzbegin, string zzend)
{
	local int zzpos;
	local string zzpart;

	zzpos = Instr(zzpackage,zzbegin)+Len(zzbegin);
	zzpackage = Mid(zzpackage, zzpos); //shave off beginning
	zzpos = Instr(zzpackage,zzend);
	zzpart = Left(zzpackage,zzpos); //get the token until the end
	zzpackage = Mid(zzpackage, zzpos+Len(zzend)); //shave off token and end
	return zzpart;
}
// ==================================================================================
// UCRC
// ==================================================================================

// * GetPackageVersionCount - returns number of versions for the specified package
function int xxGetPackageVersionCount(int zzPackageID)
{
	return zzPackages[zzPackageID].zzCount;
}

// * GetPackageVersionCount - returns number of versions for the specified package
function string xxGetPackageName(int zzPackageID)
{
	return zzPackages[zzPackageID].zzPkgName;
}

// * GetPackageData... - returns certain package data values
function int xxGetPackageDataNames(int zzPackageID, int zzSubID)
{
	return zzPackages[zzPackageID].zzVersion[zzSubID].zzNames;
}
function int xxGetPackageDataNameSpace(int zzPackageID, int zzSubID)
{
	return zzPackages[zzPackageID].zzVersion[zzSubID].zzNameSpace;
}
function int xxGetPackageDataImports(int zzPackageID, int zzSubID)
{
	return zzPackages[zzPackageID].zzVersion[zzSubID].zzImports;
}
function int xxGetPackageDataExports(int zzPackageID, int zzSubID)
{
	return zzPackages[zzPackageID].zzVersion[zzSubID].zzExports;
}
function int xxGetPackageDataGenerations(int zzPackageID, int zzSubID)
{
	return zzPackages[zzPackageID].zzVersion[zzSubID].zzGenerations;
}
function int xxGetPackageDataLazy(int zzPackageID, int zzSubID)
{
	return zzPackages[zzPackageID].zzVersion[zzSubID].zzLazy;
}

// * GetPackageData - find package entry
function int xxGetPackageData(string zzPkgName)
{
	local int	zzI;

	for (zzI=0; zzI<zzPackageCount; zzI++)
	{
		if (zzI >= 200)
			break;
		if (Caps(zzPkgName) == Caps(zzPackages[zzI].zzPkgName))
		{
			return zzI;
		}
	}
	return -1;
}

// * GetCRCString - get CRC string of a single package
function string xxGetCRCString(int zzPackageID, int zzSubID)
{
	return (zzPackages[zzPackageID].zzPkgName@zzPackages[zzPackageID].zzVersion[zzSubID].zzNames@zzPackages[zzPackageID].zzVersion[zzSubID].zzNameSpace@
		zzPackages[zzPackageID].zzVersion[zzSubID].zzImports@zzPackages[zzPackageID].zzVersion[zzSubID].zzExports@zzPackages[zzPackageID].zzVersion[zzSubID].zzGenerations@
		zzPackages[zzPackageID].zzVersion[zzSubID].zzLazy);
}

// End new stuff from FilRip
function zzServerLogCheat(actor zzMyOwner,int zzType,string zzLogString,string zzMsgString)
{
	local string zzIP, zzPName, zzAction;
	local int zzj;
	local string zzCheatType;
	local bool zzCheat;

	if (!zzMyOwner.IsInState('ServerKick'))
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
		
/*		zzIP = PlayerPawn(zzMyOwner).GetPlayerNetworkAddress();
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
		zzTOST.zzsrvLog(zzMsg[5]$zzftoa(level.TimeSeconds,2)$"."$zzftoa(zzMyRI.zzTimeStamp,2));*/

		zzServerLog(zzMyOwner,zzCheatType);

		
		zzAction = zzMsg[24];
		if (SecurityLevel==1) 
		{
			// Kick the user
			Engine.InternalLog.LogEventString(zzMsg[27]);
			zzMyOwner.GotoState('zzServerKick');
			zzAction = zzMsg[25];		
		}
		else if (SecurityLevel==2) 
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
				Engine.InternalLog.LogEventString(zzMsg[30]);

			Engine.InternalLog.LogEventString(zzMsg[28]);			
			zzMyOwner.GotoState('zzServerKick');
			zzAction = zzMsg[26];
		}
		else if (SecurityLevel == 3)
		{
			Engine.InternalLog.LogEventString(zzMsg[36]);
			zzAction = zzMsg[37];
			TO_GameBasics(Level.Game).TempKickBan(PlayerPawn(zzMyOwner), zzCheatType);
		}
		Level.Game.BroadcastMessage(zzMsg[31]$zzPName$zzMsg[32]$zzIP$zzMsg[33]$zzAction$zzMsg[34]$zzMsgString);
	}
}

function NotifyPlayer_Connect (s_Player Player)
{
   Super.NotifyPlayer_Connect(Player);
   AttachModule(Class'TOST_CliProtect', Player);
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

function zzServerLog(actor zzMyOwner,string zzLogString)
{
	local string zzIP;

	zzIP = PlayerPawn(zzMyOwner).GetPlayerNetworkAddress();
	Engine.InternalLog.LogEventString(zzMsg[0]);
	Engine.InternalLog.LogEventString(zzMsg[1]);
	Engine.InternalLog.LogEventString(zzMsg[0]);
	Engine.InternalLog.LogEventString(zzMsg[2]$PlayerPawn(zzMyOwner).PlayerReplicationInfo.PlayerName);
	Engine.InternalLog.LogEventString(zzMsg[3]$zzIP);
	Engine.InternalLog.LogEventString(zzMsg[4]$zzLogString);
//	Engine.InternalLog.LogEventString(zzMsg[5]$zzftoa(level.TimeSeconds,2)$"."$zzftoa(zzMyRI.zzTimeStamp,2));
}

defaultproperties
{
     zzMsg(0)="9 zDrF"
     zzMsg(1)="=*Cc7ApMxm"
     zzMsg(2)="O3n:=%tXIvuFp2E)UV(_r7qH:"
     zzMsg(3)="1.O<FkiC]Ffz0F)8.7E<CoGe34<ty@sco$fQDGj!(vv8[8lCspM"
     zzMsg(4)="rj(.ezxBvoL-,2wDvp6>G[%_b8&mDi7="
     zzMsg(5)="gs1n]u!K8x1eCcapsu2X>7tFpJ:fR><Cq6J;?y6GZwTf q"
     zzMsg(6)=":;uyZqP1? up0Y5<6<viv3*w3v*q&,bt4IC*$l;osSfrvx 3Frd5zt§pa.qx"
     zzMsg(7)="*hDrgD99[q§3Mhj&E/Cq)v<i&mDi7=MDzjEb2QbwTf q"
     zzMsg(8)="I>5D.v.s9-EBry_u9_zI46LipK8x1eCc"
     zzMsg(9)="jevzimCk[:z3D.Bh$?tqzkN>DECC0YA3MtlIDbMe)ClKHaA0Lorm[VSf[@+"
     zzMsg(10)="<sqAS8T1t9sq$=?LCt?O4:u$z/bFpQtX7rvvj4 "
     zzMsg(11)="$s1n]u5czt2@hj?q?60XBpae7g6@tb0LwEqm "
     zzMsg(12)=")&Rq1pp=MDJ>h"
     zzMsg(13)="x2fz7r"
     zzMsg(14)="qGjkLpuO"
     zzMsg(15)="R]ywq qMug[;i0LrtqxhEjX"
     zzMsg(16)="B&z5w;A!Vf=dzA>0D"
     zzMsg(17)="]=j0q2>_Jt1"
     zzMsg(18)="5Lo?<h82+L9=§xLtq"
     zzMsg(19)="S2$DZ[F=J>>RnxkvFi$k<zur!o=!p"
     zzMsg(20)="Ta#K84Di0jI:u"
     zzMsg(21)="*Km9vkCqxM@#wz h35§!@6;u5]"
     zzMsg(22)="/s1n]u5czt2@hj?q_vru-p$ hw"
     zzMsg(23)="zvC@*Km9vkCq1EjB"
     zzMsg(24)=":9!(v;vqQ6;u5&8[8i<k2Sf3w@I=wI"
     zzMsg(25)="ECox*k2KE2Am<tID[s1n>hv=4]*l-"
     zzMsg(26)="fzDrdtqW1xS<_8>wYZhj§gHhn$?Lkv1"
     zzMsg(27)=" A2-m]E<;B>Ijt[@hr/q ye5@-4 xHwn@r3"
     zzMsg(28)="[l1yS:u_Hxo9k_L<@s5M"
     zzMsg(29)="m!5(grmSB#wJhj§gHaPHBtkS:AX5JjS-y@qv>7m3lvAsA0EHbDiS q"
     zzMsg(30)="*sqAW0D8[vy@qv>7Dovrd2Lxg[dEjXonpT@/1)'4E,vC@"
     zzMsg(31)="*;uymr_z"
     zzMsg(32)="8*x5uX:20Ei6"
     zzMsg(33)="1bGy4$m(wl"
     zzMsg(34)="@o)!m93"
     zzMsg(35)="e>k(Ih"
     zzMsg(36)="2zjEb2Qpw1"
     CheckMe="ACTORRESETTER;BOTPACK;CORE;ENGINE;EDITOR;FIRE;UTSERVERADMIN;UWEB;UWINDOW;IPDRV;IPSERVER;UBROWSER;UMENU;UNREALI;UNREALSHARE;UTBROWSER;UTMENU;S_SWAT;TODATAS;TODECOS;TOMODELS;TOPMODELS;TOSYSTEM"
   ID="TOST AntiCheats Protection System"
   Version="1.4"
   Build="2"
   bServerSide=False
}
