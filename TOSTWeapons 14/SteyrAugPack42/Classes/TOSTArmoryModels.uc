//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTArmoryModels.uc
// Version : 0.5
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
// 0.7		+ added multi c4
// 1.2		+ splitted
//----------------------------------------------------------------------------

class TOSTArmoryModels expands Actor;

#exec texture IMPORT NAME=Steyrarms_sf		FILE=TEXTURES\skins\player\H1.bmp			GROUP="Skins"	LODSET=2

// SteyrAug 1st person model
#exec MESH IMPORT MESH=SteyrAug ANIVFILE=MODELS\SteyrAug\aug_a.3d DATAFILE=MODELS\SteyrAug\aug_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=SteyrAug X=0 Y=0 Z=0 YAW=192 PITCH=0 ROLL=0

#exec MESH SEQUENCE MESH=SteyrAug SEQ=All		STARTFRAME=0	NUMFRAMES=56
#exec MESH SEQUENCE MESH=SteyrAug SEQ=RELOAD    STARTFRAME=0	NUMFRAMES=32
#exec MESH SEQUENCE MESH=SteyrAug SEQ=FIRE      STARTFRAME=32	NUMFRAMES=5		RATE 15
#exec MESH SEQUENCE MESH=SteyrAug SEQ=DOWN      STARTFRAME=37	NUMFRAMES=4		RATE 15
#exec MESH SEQUENCE MESH=SteyrAug SEQ=SELECT    STARTFRAME=41	NUMFRAMES=13	RATE 20
#exec MESH SEQUENCE MESH=SteyrAug SEQ=IDLE1     STARTFRAME=54	NUMFRAMES=2
#exec MESH SEQUENCE MESH=SteyrAug SEQ=IDLE      STARTFRAME=54	NUMFRAMES=2
#exec MESH SEQUENCE MESH=SteyrAug SEQ=FIX		STARTFRAME=54	NUMFRAMES=2

#exec MESH NOTIFY MESH=SteyrAug SEQ=RELOAD TIME=0.22 FUNCTION=ClipIn
#exec MESH NOTIFY MESH=SteyrAug SEQ=RELOAD TIME=0.50 FUNCTION=ClipOut
#exec MESH NOTIFY MESH=SteyrAug SEQ=RELOAD TIME=0.80 FUNCTION=ClipLever
#exec MESH NOTIFY MESH=SteyrAug SEQ=Fire   TIME=0.10 FUNCTION=AnimFire

#exec texture IMPORT NAME=JSteyrAug1 FILE=TEXTURES\SteyrAug\augbarrel.bmp	GROUP="Skins"	LODSET=2
#exec texture IMPORT NAME=JSteyrAug2 FILE=TEXTURES\SteyrAug\augclamps.bmp	GROUP="Skins"	LODSET=2
#exec texture IMPORT NAME=JSteyrAug3 FILE=TEXTURES\SteyrAug\augbase.bmp		GROUP="Skins"	LODSET=2

#exec MESHMAP NEW   MESHMAP=SteyrAug MESH=SteyrAug
#exec MESHMAP SCALE MESHMAP=SteyrAug X=0.05 Y=0.05 Z=0.1

#exec MESHMAP SETTEXTURE MESHMAP=SteyrAug NUM=0 TEXTURE=JSteyrAug1
#exec MESHMAP SETTEXTURE MESHMAP=SteyrAug NUM=1 TEXTURE=JSteyrAug2
#exec MESHMAP SETTEXTURE MESHMAP=SteyrAug NUM=2 TEXTURE=JSteyrAug3
#exec MESHMAP SETTEXTURE MESHMAP=SteyrAug NUM=3 TEXTURE=Steyrarms_sf

// SteyrAug 3rdPerson
#exec MESH IMPORT MESH=wAug ANIVFILE=MODELS\SteyrAug\waug_a.3d DATAFILE=MODELS\SteyrAug\waug_d.3d X=0 Y=0 Z=0
#exec mesh ORIGIN MESH=wAug X=0 Y=100 Z=-40 YAW=64 PITCH=0 ROLL=0

#exec texture IMPORT NAME=wJAug1 FILE=TEXTURES\SteyrAug\augworld1.bmp GROUP="Skins"	LODSET=2
#exec texture IMPORT NAME=wJAug2 FILE=TEXTURES\SteyrAug\augworld2.bmp GROUP="Skins"	LODSET=2

#exec MESHMAP NEW   MESHMAP=wAug MESH=wAug
#exec MESHMAP scale MESHMAP=wAug X=0.035 Y=0.035 Z=0.07

#exec MESHMAP SETTEXTURE MESHMAP=wAug NUM=0 TEXTURE=wJAug1
#exec MESHMAP SETTEXTURE MESHMAP=wAug NUM=1 TEXTURE=wJAug2

// SteyrAug Pickup
#exec MESH IMPORT MESH=pAug ANIVFILE=MODELS\SteyrAug\waug_a.3d DATAFILE=MODELS\SteyrAug\waug_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=pAug X=200 Y=7 Z=0 YAW=-64 PITCH=64 ROLL=0

#exec MESHMAP NEW   MESHMAP=pAug MESH=pAug
#exec MESHMAP SCALE MESHMAP=pAug X=0.04 Y=0.04 Z=0.08

#exec MESHMAP SETTEXTURE MESHMAP=pAug NUM=0 TEXTURE=wJAug1
#exec MESHMAP SETTEXTURE MESHMAP=pAug NUM=1 TEXTURE=wJAug2

// SteyrAug Audio
#exec AUDIO IMPORT FILE="Sounds\SteyrAug\SAClipIn1.wav"		NAME="SAClipIn"		GROUP="Weapons"
#exec AUDIO IMPORT FILE="Sounds\SteyrAug\SAClipOut1.wav"	NAME="SAClipOut"	GROUP="Weapons"
#exec AUDIO IMPORT FILE="Sounds\SteyrAug\SAClipLever1.wav"	NAME="SAClipLever"	GROUP="Weapons"
#exec AUDIO IMPORT FILE="Sounds\SteyrAug\SAFire1.wav"		NAME="SAFire"		GROUP="Weapons"

// SteyrText
#exec texture IMPORT NAME=SteyrTrans	FILE=TEXTURES\Trans\Steyr.pcx	LODSET=2 MIPS=OFF FLAGS=2
#exec texture IMPORT NAME=SteyrSolid	FILE=TEXTURES\Solid\Steyr.pcx	LODSET=2 MIPS=OFF FLAGS=2
