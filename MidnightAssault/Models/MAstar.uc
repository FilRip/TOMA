//=============================================================================
// MAstar.
//=============================================================================
class MAstar extends TournamentPlayer;

#exec MESH IMPORT MESH=MAstar ANIVFILE=MODELS\MAstar_a.3d DATAFILE=MODELS\MAstar_d.3d
#exec MESH LODPARAMS MESH=MAstar HYSTERESIS=0.00 STRENGTH=1.00 MINVERTS=10.00 MORPH=0.30 ZDISP=0.00
#exec MESH ORIGIN MESH=MAstar X=0.00 Y=0.00 Z=0.00 YAW=0.00 ROLL=0.00 PITCH=0.00

#exec MESH SEQUENCE MESH=MAstar SEQ=All       STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=MAstar SEQ=Still     STARTFRAME=0 NUMFRAMES=1



#exec MESHMAP SCALE MESHMAP=MAstar X=0.13 Y=0.13 Z=0.25


