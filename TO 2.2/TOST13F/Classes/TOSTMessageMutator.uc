//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTMessageMutator.uc
// Version : 1.2
// Author  : BugBunny/MadOnion
//----------------------------------------------------------------------------

class TOSTMessageMutator expands Mutator;

var string zzmMsg[2];

auto state zzStartUp
{
begin:
	zzDecryptStrings("CheckFlash");
}

simulated function zzDecryptStrings(string zzPassword)
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
	for (i=0; i<2; i++)
	{
		zzPlainString = "";
		for (j=0; j<Len(zzmMsg[i]); j++)
		{
			zzk++;
			if (zzk > Len(zzPassword))
				zzk = 1;
			zzPass = Mid(zzPassword, zzk-1, 1);
			zzCrypt = Mid(zzmMsg[i], j, 1);
			zzKey = Mid(Mid(zzPermString, InStr(zzPermString, zzPass), 88), InStr(zzPermString, zzCrypt), 1);
			zzPlain = Mid(Mid(zzPermString, InStr(zzPermString, zzPrevPlain), 88), InStr(zzPermString, zzKey), 1);
			zzPlainString = zzPlainString$zzPlain;
			zzPrevPlain = zzPlain;
		}
		zzmMsg[i] = zzPlainString;
	}
}

// ==================================================================================
// MutatorTeamMessage - Mark TeamMessages as those
// ==================================================================================

function bool MutatorTeamMessage( Actor zzSender, Pawn zzReceiver, PlayerReplicationInfo zzPRI, coerce string zzS, name zzType, optional bool zzbBeep )
{
    if (zzType == 'TeamSay')
    {
        if (InStr(zzS, zzmMsg[0]) != -1)
        {
            return Super.MutatorTeamMessage( zzSender, zzReceiver, zzPRI, zzS, zzType, zzbBeep );
        } else {
            zzS = zzmMsg[0]$zzS;
	    if (Super.MutatorTeamMessage( zzSender, zzReceiver, zzPRI, zzS, zzType, zzbBeep ))
	            zzReceiver.TeamMessage( zzPRI, zzS, 'TeamSay', zzbBeep );
            return false;
        }
    } else {
        return Super.MutatorTeamMessage( zzSender, zzReceiver, zzPRI, zzS, zzType, zzbBeep );
    }
}

// ==================================================================================
// MutatorBroadcastMessage - Stop summons not spawned by admins
// ==================================================================================

function bool MutatorBroadcastMessage( Actor zzSender,Pawn zzReceiver, out coerce string Msg, optional bool zzbBeep, out optional name zzType )
{
	local S_Player zzRealSender;

	if ((zzSender == Level.Game) && (zzType == 'Event'))
	{
		foreach AllActors(class'S_Player', zzRealSender)
		{
			if (InStr(Msg, zzRealSender.PlayerReplicationInfo.PlayerName@zzmMsg[1]) != -1 && !zzRealSender.bAdmin )
			{
				return False;
			}			 
		}
	}
	return Super.MutatorBroadcastMessage( zzSender,zzReceiver, Msg, zzbBeep, zzType );
}


// ==================================================================================
// MutatorBroadcastLocalizedMessage
// ==================================================================================
function bool MutatorBroadcastLocalizedMessage( Actor zzSender, Pawn zzReceiver, out class<LocalMessage> zzMessage, out optional int zzSwitch, out optional PlayerReplicationInfo zzRelatedPRI_1, out optional PlayerReplicationInfo zzRelatedPRI_2, out optional Object zzOptionalObject )
{
	return Super.MutatorBroadcastLocalizedMessage( zzSender, zzReceiver, zzMessage, zzSwitch, zzRelatedPRI_1, zzRelatedPRI_2, zzOptionalObject );
} // MutatorBroadcastLocalizedMessage

/*
*/

defaultproperties
{
     zzmMsg(0)="[K$4(]7@7#"
     zzmMsg(1)="r5y82;4N"
}
