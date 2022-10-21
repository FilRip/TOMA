//=============================================================================
// VoiceSF1
//=============================================================================
//
// Tactical Ops
// - http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class VoiceSF1 expands TO_VoicePack;

// Voice sfsa_greg

#exec OBJ LOAD FILE=..\Sounds\VoiceMaleSF1.uax PACKAGE=VoiceMaleSF1

/*
#exec AUDIO IMPORT FILE="Sounds\Voice\SF1\sfsa_greg_icopy.wav"				NAME="SF1icopy"			GROUP="SF1"
#exec AUDIO IMPORT FILE="Sounds\Voice\SF1\sfsa_greg_rogerthat.wav"		NAME="SF1roger"			GROUP="SF1"
#exec AUDIO IMPORT FILE="Sounds\Voice\SF1\sfsa_greg_you'vegotit.wav"	NAME="SF1yougotit"	GROUP="SF1"

#exec AUDIO IMPORT FILE="Sounds\Voice\SF1\sfsa_greg_hefriendlyfire.wav"				NAME="SF1FF1"			GROUP="SF1"
#exec AUDIO IMPORT FILE="Sounds\Voice\SF1\sfsa_greg_watchwhoreyashooting.wav"	NAME="SF1FF2"			GROUP="SF1"

#exec AUDIO IMPORT FILE="Sounds\Voice\SF1\sfsa_greg_enemydown.wav"				NAME="SF1enemydown"			GROUP="SF1"
#exec AUDIO IMPORT FILE="Sounds\Voice\SF1\sfsa_greg_enemyeliminated.wav"	NAME="SF1enemyelim"			GROUP="SF1"
#exec AUDIO IMPORT FILE="Sounds\Voice\SF1\sfsa_greg_gothim.wav"						NAME="SF1gothim"				GROUP="SF1"
#exec AUDIO IMPORT FILE="Sounds\Voice\SF1\sfsa_greg_yesenemydown.wav"			NAME="SF1yesenemydown"	GROUP="SF1"

#exec AUDIO IMPORT FILE="Sounds\Voice\SF1\sfsa_greg_return2base.wav"			NAME="SF1return2base"			GROUP="SF1"
#exec AUDIO IMPORT FILE="Sounds\Voice\SF1\sfsa_greg_holdthisposition.wav"	NAME="SF1holdposition"		GROUP="SF1"
#exec AUDIO IMPORT FILE="Sounds\Voice\SF1\sfsa_greg_attackmaintarget.wav"	NAME="SF1AttackTarget"		GROUP="SF1"
#exec AUDIO IMPORT FILE="Sounds\Voice\SF1\sfsa_greg_coverme.wav"					NAME="SF1coverme"					GROUP="SF1"
#exec AUDIO IMPORT FILE="Sounds\Voice\SF1\sfsa_greg_letscleanthisplaceout.wav"	NAME="SF1cleanplace"	GROUP="SF1"

#exec AUDIO IMPORT FILE="Sounds\Voice\SF1\sfsa_greg_emergency.wav"					NAME="SF1emergency"			GROUP="SF1"
#exec AUDIO IMPORT FILE="Sounds\Voice\SF1\sfsa_greg_needsumbackupfast.wav"	NAME="SF1backupfast"		GROUP="SF1"
#exec AUDIO IMPORT FILE="Sounds\Voice\SF1\sfsa_greg_ivegotyaback.wav"				NAME="SF1gotyaback"			GROUP="SF1"
#exec AUDIO IMPORT FILE="Sounds\Voice\SF1\sfsa_greg_imhit.wav"							NAME="SF1imhit"					GROUP="SF1"
#exec AUDIO IMPORT FILE="Sounds\Voice\SF1\sfsa_greg_watch4cover.wav"				NAME="SF1watchforcover"	GROUP="SF1"
#exec AUDIO IMPORT FILE="Sounds\Voice\SF1\sfsa_greg_imunderheavyattack.wav"	NAME="SF1heavyattack"		GROUP="SF1"
#exec AUDIO IMPORT FILE="Sounds\Voice\SF1\sfsa_greg_iminposition.wav"				NAME="SF1iminposition"	GROUP="SF1"
#exec AUDIO IMPORT FILE="Sounds\Voice\SF1\sfsa_greg_areacleared.wav"				NAME="SF1areacleared"		GROUP="SF1"
#exec AUDIO IMPORT FILE="Sounds\Voice\SF1\sfsa_greg_enemyspotted.wav"				NAME="SF1enemyspotted"	GROUP="SF1"
#exec AUDIO IMPORT FILE="Sounds\Voice\SF1\sfsa_greg_targetinsight.wav"			NAME="SF1targetinsight"	GROUP="SF1"

#exec AUDIO IMPORT FILE="Sounds\Voice\SF1\sfsa_greg_objectiveaccomplished.wav"	NAME="SF1objectiveok"	GROUP="SF1"
#exec AUDIO IMPORT FILE="Sounds\Voice\SF1\sfsa_greg_enemyspotted.wav"						NAME="SF1enemyspotted"	GROUP="SF1"
*/


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     AckSound(0)=Sound'VoiceMaleSF1.(All).SF1icopy'
     AckSound(1)=Sound'VoiceMaleSF1.(All).SF1roger'
     AckSound(2)=Sound'VoiceMaleSF1.(All).SF1yougotit'
     AckString(0)="I copy"
     AckString(1)="Roger that"
     AckString(2)="You got it"
     AckTime(0)=0.575000
     AckTime(1)=0.550000
     AckTime(2)=0.540000
     FFireSound(0)=Sound'VoiceMaleSF1.(All).SF1FF1'
     FFireSound(1)=Sound'VoiceMaleSF1.(All).SF1FF2'
     FFireString(0)="Hey! Friendly fire!"
     FFireString(1)="Watch who you shoot!"
     FFireAbbrev(0)="Friendly fire!"
     TauntSound(0)=Sound'VoiceMaleSF1.(All).SF1enemydown'
     TauntSound(1)=Sound'VoiceMaleSF1.(All).SF1enemyelim'
     TauntSound(2)=Sound'VoiceMaleSF1.(All).SF1gothim'
     TauntSound(3)=Sound'VoiceMaleSF1.(All).SF1yesenemydown'
     TauntString(0)="Enemy down!"
     TauntString(1)="Enemy eliminated!"
     TauntString(2)="Got him!"
     TauntString(3)="Yes! Enemy down!"
     numTaunts=4
     OrderSound(0)=Sound'VoiceMaleSF1.(All).SF1return2base'
     OrderSound(1)=Sound'VoiceMaleSF1.(All).SF1holdposition'
     OrderSound(2)=Sound'VoiceMaleSF1.(All).SF1AttackTarget'
     OrderSound(3)=Sound'VoiceMaleSF1.(All).SF1coverme'
     OrderSound(4)=Sound'VoiceMaleSF1.(All).SF1cleanplace'
     OrderSound(10)=Sound'VoiceMaleSF1.(All).SF1AttackTarget'
     OrderSound(11)=Sound'VoiceMaleSF1.(All).SF1cleanplace'
     OrderString(0)="Return to base!"
     OrderString(2)="Attack main target."
     OrderString(4)="Let's clean this place out."
     OrderString(10)="Attack main target."
     OrderString(11)="Let's clean this place out."
     OtherSound(0)=Sound'VoiceMaleSF1.(All).SF1return2base'
     OtherSound(1)=Sound'VoiceMaleSF1.(All).SF1emergency'
     OtherSound(2)=Sound'VoiceMaleSF1.(All).SF1objectiveok'
     OtherSound(3)=Sound'VoiceMaleSF1.(All).SF1gotyaback'
     OtherSound(4)=Sound'VoiceMaleSF1.(All).SF1imhit'
     OtherSound(5)=Sound'VoiceMaleSF1.(All).SF1emergency'
     OtherSound(6)=Sound'VoiceMaleSF1.(All).SF1heavyattack'
     OtherSound(7)=Sound'VoiceMaleSF1.(All).SF1yougotit'
     OtherSound(8)=Sound'VoiceMaleSF1.(All).SF1objectiveok'
     OtherSound(9)=Sound'VoiceMaleSF1.(All).SF1iminposition'
     OtherSound(10)=Sound'VoiceMaleSF1.(All).SF1holdposition'
     OtherSound(11)=Sound'VoiceMaleSF1.(All).SF1areacleared'
     OtherSound(12)=Sound'VoiceMaleSF1.(All).SF1enemyspotted'
     OtherSound(13)=Sound'VoiceMaleSF1.(All).SF1backupfast'
     OtherSound(14)=None
     OtherSound(15)=Sound'VoiceMaleSF1.(All).SF1gotyaback'
     OtherSound(16)=Sound'VoiceMaleSF1.(All).SF1objectiveok'
     OtherSound(17)=Sound'VoiceMaleSF1.(All).SF1backupfast'
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
