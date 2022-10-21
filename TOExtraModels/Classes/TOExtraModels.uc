//
// FilRip
// (CB) CoolBytes clan
//
// You search something ?

Class TOExtraModels extends Actor;

// Poster pour les TAG

#exec mesh IMPORT MESH=poster ANIVFILE=MODELS\poster_a.3d DATAFILE=MODELS\poster_d.3d
#exec mesh ORIGIN MESH=poster X=0 Y=0 Z=0 Pitch=0 Yaw=0 Roll=0

#exec MESH SEQUENCE MESH=poster SEQ=All    STARTFRAME=0 NUMFRAMES=1
//#exec mesh SEQUENCE MESH=poster SEQ=POSTER STARTFRAME=0 NUMFRAMES=1

#exec texture IMPORT NAME=Jposter0 FILE=MODELS\poster0.bmp GROUP=Skins FLAGS=2 // SKIN

#exec MESHMAP new   MESHMAP=poster MESH=poster
#exec MESHMAP SCALE MESHMAP=poster X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=poster NUM=0 TEXTURE=Jposter0

#exec AUDIO IMPORT FILE="Sounds\HostageDown.wav" NAME="HostageDown"
#exec AUDIO IMPORT FILE="Sounds\sonbt.WAV" NAME="sonbt"

defaultproperties
{
    bHidden=true
}

