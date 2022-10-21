//=============================================================================
// VoiceT1
//=============================================================================
//
// Tactical Ops
// - http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class VoiceT1 expands TO_VoicePack;

// Voice sfsr_ryan

#exec OBJ LOAD FILE=..\Sounds\VoiceMaleT1.uax PACKAGE=VoiceMaleT1
/*
#exec AUDIO IMPORT FILE="Sounds\Voice\T1\sfsr_ryan_icopy.wav"				NAME="T1icopy"			GROUP="T1"
#exec AUDIO IMPORT FILE="Sounds\Voice\T1\sfsr_ryan_rogerthat.wav"		NAME="T1roger"			GROUP="T1"
#exec AUDIO IMPORT FILE="Sounds\Voice\T1\sfsr_ryan_youvegotit.wav"	NAME="T1yougotit"		GROUP="T1"

#exec AUDIO IMPORT FILE="Sounds\Voice\T1\sfsr_ryan_hefriendlyfire.wav"						NAME="T1FF1"	GROUP="T1"
#exec AUDIO IMPORT FILE="Sounds\Voice\T1\sfsr_ryan_hewatchoutwhatareyoudoing.wav"	NAME="T1FF2"	GROUP="T1"

#exec AUDIO IMPORT FILE="Sounds\Voice\T1\sfsr_ryan_enemydown.wav"					NAME="T1enemydown"		GROUP="T1"
#exec AUDIO IMPORT FILE="Sounds\Voice\T1\sfsr_ryan_enemyeliminated.wav"		NAME="T1enemyelim"		GROUP="T1"
#exec AUDIO IMPORT FILE="Sounds\Voice\T1\sfsr_ryan_gothim.wav"						NAME="T1gothim"				GROUP="T1"
#exec AUDIO IMPORT FILE="Sounds\Voice\T1\sfsr_ryan_yesenemydown.wav"			NAME="T1yesenemydown"	GROUP="T1"

#exec AUDIO IMPORT FILE="Sounds\Voice\T1\sfsr_ryan_return2base.wav"				NAME="T1return2base"		GROUP="T1"
#exec AUDIO IMPORT FILE="Sounds\Voice\T1\sfsr_ryan_holdthisposition.wav"	NAME="T1holdposition"		GROUP="T1"
#exec AUDIO IMPORT FILE="Sounds\Voice\T1\sfsr_ryan_attackmaintarget.wav"	NAME="T1AttackTarget"		GROUP="T1"
#exec AUDIO IMPORT FILE="Sounds\Voice\T1\sfsr_ryan_coverme.wav"						NAME="T1coverme"				GROUP="T1"
#exec AUDIO IMPORT FILE="Sounds\Voice\T1\sfsr_ryan_letscleanthisplaceout.wav"	NAME="T1cleanplace"	GROUP="T1"

#exec AUDIO IMPORT FILE="Sounds\Voice\T1\sfsr_ryan_emergency.wav"					NAME="T1emergency"			GROUP="T1"
#exec AUDIO IMPORT FILE="Sounds\Voice\T1\sfsr_ryan_ineedsumbackupfast.wav"	NAME="T1backupfast"			GROUP="T1"
#exec AUDIO IMPORT FILE="Sounds\Voice\T1\sfsr_ryan_ivegotyourback.wav"			NAME="T1gotyaback"			GROUP="T1"
#exec AUDIO IMPORT FILE="Sounds\Voice\T1\sfsr_ryan_imhit.wav"							NAME="T1imhit"					GROUP="T1"
#exec AUDIO IMPORT FILE="Sounds\Voice\T1\sfsr_ryan_watch4cover.wav"				NAME="T1watchforcover"	GROUP="T1"
#exec AUDIO IMPORT FILE="Sounds\Voice\T1\sfsr_ryan_imunderheavyattack.wav"	NAME="T1heavyattack"	GROUP="T1"
#exec AUDIO IMPORT FILE="Sounds\Voice\T1\sfsr_ryan_iminposition.wav"				NAME="T1iminposition"	GROUP="T1"
#exec AUDIO IMPORT FILE="Sounds\Voice\T1\sfsr_ryan_areacleared.wav"				NAME="T1areacleared"		GROUP="T1"
#exec AUDIO IMPORT FILE="Sounds\Voice\T1\sfsr_ryan_enemyspotted.wav"			NAME="T1enemyspotted"		GROUP="T1"

#exec AUDIO IMPORT FILE="Sounds\Voice\T1\sfsr_ryan_objectiveaccomplished.wav"	NAME="T1objectiveok"	GROUP="T1"
#exec AUDIO IMPORT FILE="Sounds\Voice\T1\sfsr_ryan_enemyspotted.wav"					NAME="T1enemyspotted"	GROUP="T1"
#exec AUDIO IMPORT FILE="Sounds\Voice\T1\sfsr_ryan_enemyimcomming.wav"				NAME="T1enemyincoming"	GROUP="T1"
*/


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     AckSound(0)=Sound'VoiceMaleT1.(All).T1icopy'
     AckSound(1)=Sound'VoiceMaleT1.(All).T1roger'
     AckSound(2)=Sound'VoiceMaleT1.(All).T1yougotit'
     AckString(0)="I copy"
     AckString(1)="Roger that"
     AckString(2)="You got it"
     AckTime(0)=0.575000
     AckTime(1)=0.550000
     AckTime(2)=0.540000
     FFireSound(0)=Sound'VoiceMaleT1.(All).T1FF1'
     FFireSound(1)=Sound'VoiceMaleT1.(All).T1FF2'
     FFireString(0)="Hey! Friendly fire!"
     FFireString(1)="Watch who you shoot!"
     FFireAbbrev(0)="Friendly fire!"
     TauntSound(0)=Sound'VoiceMaleT1.(All).T1enemydown'
     TauntSound(1)=Sound'VoiceMaleT1.(All).T1enemyelim'
     TauntSound(2)=Sound'VoiceMaleT1.(All).T1gothim'
     TauntSound(3)=Sound'VoiceMaleT1.(All).T1yesenemydown'
     TauntString(0)="Enemy down!"
     TauntString(1)="Enemy eliminated!"
     TauntString(2)="Got him!"
     TauntString(3)="Yes! Enemy down!"
     numTaunts=4
     OrderSound(0)=Sound'VoiceMaleT1.(All).T1return2base'
     OrderSound(1)=Sound'VoiceMaleT1.(All).T1holdposition'
     OrderSound(2)=Sound'VoiceMaleT1.(All).T1AttackTarget'
     OrderSound(3)=Sound'VoiceMaleT1.(All).T1coverme'
     OrderSound(4)=Sound'VoiceMaleT1.(All).T1cleanplace'
     OrderSound(10)=Sound'VoiceMaleT1.(All).T1AttackTarget'
     OrderSound(11)=Sound'VoiceMaleT1.(All).T1cleanplace'
     OrderString(0)="Return to base!"
     OrderString(2)="Attack main target."
     OrderString(4)="Let's clean this place out."
     OrderString(10)="Attack main target."
     OrderString(11)="Let's clean this place out."
     OtherSound(0)=Sound'VoiceMaleT1.(All).T1return2base'
     OtherSound(1)=Sound'VoiceMaleT1.(All).T1emergency'
     OtherSound(2)=Sound'VoiceMaleT1.(All).T1objectiveok'
     OtherSound(3)=Sound'VoiceMaleT1.(All).T1gotyaback'
     OtherSound(4)=Sound'VoiceMaleT1.(All).T1imhit'
     OtherSound(5)=Sound'VoiceMaleT1.(All).T1emergency'
     OtherSound(6)=Sound'VoiceMaleT1.(All).T1heavyattack'
     OtherSound(7)=Sound'VoiceMaleT1.(All).T1yougotit'
     OtherSound(8)=Sound'VoiceMaleT1.(All).T1objectiveok'
     OtherSound(9)=Sound'VoiceMaleT1.(All).T1iminposition'
     OtherSound(10)=Sound'VoiceMaleT1.(All).T1holdposition'
     OtherSound(11)=Sound'VoiceMaleT1.(All).T1areacleared'
     OtherSound(12)=Sound'VoiceMaleT1.(All).T1enemyspotted'
     OtherSound(13)=Sound'VoiceMaleT1.(All).T1backupfast'
     OtherSound(14)=Sound'VoiceMaleT1.(All).T1enemyincoming'
     OtherSound(15)=Sound'VoiceMaleT1.(All).T1gotyaback'
     OtherSound(16)=Sound'VoiceMaleT1.(All).T1objectiveok'
     OtherSound(17)=Sound'VoiceMaleT1.(All).T1backupfast'
     otherstring(0)="Return to base!"
     otherstring(1)="Emergency!"
     otherstring(2)="Objective accomplished!"
     otherstring(5)="Emergency! man down!"
     otherstring(7)="You got it."
     otherstring(8)="Objective accomplished!"
     otherstring(10)="Hold this position."
     otherstring(11)="Area cleared."
     otherstring(12)="Enemy spotted."
     otherstring(13)="I need some backup fast!"
     otherstring(14)="Enemy incoming."
     otherstring(16)="Objective accomplished."
     otherstring(17)="I need some backup fast!"
     OtherAbbrev(1)="Emergency!"
     OtherAbbrev(2)=""
     OtherAbbrev(8)=""
     OtherAbbrev(12)=""
}
