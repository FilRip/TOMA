//=============================================================================
// MAbox.
//=============================================================================
class MAbox extends TournamentPlayer;

#exec MESH IMPORT MESH=MAbox ANIVFILE=MODELS\MAbox_a.3d DATAFILE=MODELS\MAbox_d.3d
#exec MESH LODPARAMS MESH=MAbox HYSTERESIS=0.00 STRENGTH=1.00 MINVERTS=10.00 MORPH=0.30 ZDISP=0.00
#exec MESH ORIGIN MESH=MAbox X=0.00 Y=0.00 Z=0.00 YAW=0.00 ROLL=0.00 PITCH=0.00

#exec MESH SEQUENCE MESH=MAbox SEQ=All       STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=MAbox SEQ=Still     STARTFRAME=0 NUMFRAMES=1



#exec MESHMAP SCALE MESHMAP=MAbox X=0.38 Y=0.38 Z=0.75


