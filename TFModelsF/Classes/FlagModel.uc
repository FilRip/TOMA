Class FlagModel extends Actor;

// FilRip coding
//
// You search something ?

#exec MESH IMPORT MESH=TFFlag ANIVFILE=MODELS\pflag_a.3d DATAFILE=MODELS\pflag_d.3d X=0 Y=0 Z=0 ZEROTEX=1
#exec MESH ORIGIN MESH=TFFlag X=400 Y=0 Z=0 YAW=128

#exec MESH SEQUENCE MESH=TFFlag SEQ=All   STARTFRAME=0 NUMFRAMES=133
#exec MESH SEQUENCE MESH=TFFlag SEQ=pflag STARTFRAME=0 NUMFRAMES=133

#exec TEXTURE IMPORT NAME=SFFlagTex FILE=textures\JpflagB.bmp GROUP=Skins FLAGS=2 // twosided
#exec TEXTURE IMPORT NAME=TerroFlagTex FILE=textures\JpflagR.bmp GROUP=Skins FLAGS=2 // twosided

#exec MESHMAP NEW MESHMAP=TFFlag MESH=TFFlag
#exec MESHMAP SCALE MESHMAP=TFFlag X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=TFFlag NUM=0 TEXTURE=TerroFlagTex

#exec AUDIO IMPORT FILE="Sounds\CaptureSound2.wav" NAME="CaptureSound2"
#exec AUDIO IMPORT FILE="Sounds\flagtaken.wav" NAME="flagtaken"
#exec AUDIO IMPORT FILE="Sounds\ReturnSound.wav" NAME="ReturnSound"

defaultproperties
{
	bHidden=true
}
