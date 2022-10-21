//=============================================================================
// s_Voices
//=============================================================================
//
// Tactical Ops
// - http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_Voices extends Info;

var		Sound										Phrase[8];
var		string									PhraseString[8];
var		float										PhraseTime[8];
var		PlayerReplicationInfo		PhrasePRI[8];
var		bool										PhraseOver;
var		int											PhraseNum;
var		string									DelayedResponse;
var		bool										bDelayedResponse;
var		PlayerReplicationInfo		DelayedSender;

var		string	VoiceString[32], MessageString[32];


///////////////////////////////////////
// SetClientDynamicSound
///////////////////////////////////////

function SetClientDynamicSound(int messageIndex, int VoiceIndex, out Sound MessageSound, out Float MessageTime)
{
	// VoiceIndex = 0	Ryan sa
	//				1	Ryan sf
	//				2	Marc sa
	//				3	Marc sf
	//				4	Greg sa
	//				5	Greg sf

	local	string	s, aSoundName;
	local	byte a,b; 

	//if (Owner.IsA('PlayerPawn') && PlayerPawn(Owner).GetDefaultURL("HQVoices") != "True")
		VoiceIndex = VoiceIndex % 2;	

	if (VoiceIndex==0)
		s="TOM1Voice.sfsa.sfsa_ryan_";
	else if (VoiceIndex==1)
		s="TOM1Voice.sfsr.sfsr_ryan_";
	else if (VoiceIndex==2)
		s="TOM2Voice.sfsa.sfsa_marc_";
	else if (VoiceIndex==3)
		s="TOM2Voice.sfsr.sfsr_marc_";
	else if (VoiceIndex==4)
		s="TOM3Voice.sfsa.sfsa_greg_";
	else 
		s="TOM3Voice.sfsr.sfsr_greg_";

	aSoundName=s$VoiceString[messageIndex];

	MessageSound = Sound(DynamicLoadObject(aSoundName, class'Sound'));
	MessageTime = GetSoundDuration(MessageSound);
}


///////////////////////////////////////
// ClientInitialize
///////////////////////////////////////

function ClientInitialize(byte messageIndex, byte VoiceIndex, optional bool bOverride, optional PlayerReplicationInfo SenderPRI)
{
	local int		m;
	local Sound MessageSound;
	local float MessageTime;

	SetTimer(0.1, false);

	SetClientDynamicSound(messageIndex, VoiceIndex, MessageSound, MessageTime);
	Phrase[m] = MessageSound;
	PhraseTime[m] = MessageTime;

/*	if (SenderPRI!=None)
		PhraseString[m] = "("$SenderPRI.PlayerName$"): "$MessageString[messageIndex];
	else*/
		PhraseString[m] = MessageString[messageIndex];

	PhrasePRI[m]=SenderPRI;
	PhraseOver = (!bOverride);
}


///////////////////////////////////////
// Timer
///////////////////////////////////////

function Timer()
{
	local name MessageType;

	if ( Phrase[PhraseNum] != None )
	{
		if ( Owner.IsA('PlayerPawn') && !PlayerPawn(Owner).bNoVoices 
			&& (Level.TimeSeconds - PlayerPawn(Owner).LastPlaySound > 2)  ) 
		{
			if ( (PlayerPawn(Owner).ViewTarget != None) && !PlayerPawn(Owner).ViewTarget.IsA('Carcass') )
			{
				PlayerPawn(Owner).ViewTarget.PlaySound(Phrase[PhraseNum], SLOT_Interface, 163.0, PhraseOver);
				PlayerPawn(Owner).ViewTarget.PlaySound(Phrase[PhraseNum], SLOT_Misc, 163.0, PhraseOver);
			}
			else
			{
				PlayerPawn(Owner).PlaySound(Phrase[PhraseNum], SLOT_Interface, 163.0, PhraseOver);
				PlayerPawn(Owner).PlaySound(Phrase[PhraseNum], SLOT_Misc, 163.0, PhraseOver);
			}
			if (PhrasePRI[PhraseNum]!=None)
				PlayerPawn(Owner).TeamMessage(PhrasePRI[PhraseNum], PhraseString[PhraseNum], 'TeamSay');
			else
				PlayerPawn(Owner).ClientMessage("(Announcer): "$PhraseString[PhraseNum]);
		}
		if ( PhraseTime[PhraseNum] == 0 )
			Destroy();
		else
		{
			SetTimer(PhraseTime[PhraseNum], false);
			PhraseNum++;
		}
	}
	else 
		Destroy();
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     VoiceString(0)="goGoGO"
     VoiceString(1)="keepmoving"
     VoiceString(2)="letscleanthisplaceout"
     VoiceString(3)="moveMoveMOVE"
     VoiceString(4)="missionaborted"
     VoiceString(5)="well_done_men"
     VoiceString(6)="another_job_welldone"
     VoiceString(7)="congratulations_team"
     VoiceString(8)="good_job_men"
     VoiceString(9)="hahah_we_showed_em"
     VoiceString(10)="nice_going_guys"
     VoiceString(11)="their_no_match"
     VoiceString(12)="well_done_men"
     VoiceString(13)="enemydown"
     VoiceString(14)="enemyeliminated"
     VoiceString(15)="yesenemydown"
     VoiceString(16)="enemyobliterated"
     VoiceString(17)="5secb4assault"
     VoiceString(18)="hostagerescued"
     VoiceString(19)="fireinthehole"
     VoiceString(20)="watch4cover"
     VoiceString(21)="throwinblindgrenade"
     VoiceString(22)="coveryoureyes"
     VoiceString(23)="imunderfire"
     VoiceString(24)="imunderheavyattack"
     VoiceString(25)="emergency"
     VoiceString(26)="needsumbackupfast"
     VoiceString(27)="hefriendlyfire"
     VoiceString(28)="hewatchoutwhatareyoudoing"
     VoiceString(29)="ivegotyourback"
     MessageString(0)="go Go GO !"
     MessageString(1)="Keep moving."
     MessageString(2)="Let's clean this place out."
     MessageString(3)="move Move MOVE !"
     MessageString(4)="Mission aborted."
     MessageString(5)="Well done men."
     MessageString(6)="Another job welldone."
     MessageString(7)="Congratulations team !"
     MessageString(8)="Good job men."
     MessageString(9)="Hahah we showed them."
     MessageString(10)="Nice going guys."
     MessageString(11)="They are no match."
     MessageString(12)="well done men."
     MessageString(13)="Enemy down."
     MessageString(14)="Enemy eliminated."
     MessageString(15)="Yes ! Enemy down."
     MessageString(16)="Enemy obliterated."
     MessageString(17)="5 seconds before assault."
     MessageString(18)="Hostage rescued."
     MessageString(19)="Fire in the hole."
     MessageString(20)="Watch for cover."
     MessageString(21)="Throwing blind grenade."
     MessageString(22)="Cover your eyes."
     MessageString(23)="I'm under fire."
     MessageString(24)="I'm under heavy attack."
     MessageString(25)="Emergency."
     MessageString(26)="Need some backup fast !"
     MessageString(27)="He ! Friendly fire."
     MessageString(28)="He watch out ? What are you doing ?"
     MessageString(29)="I've got your back."
     RemoteRole=ROLE_None
     LifeSpan=10.000000
}
