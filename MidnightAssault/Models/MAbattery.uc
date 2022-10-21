//=============================================================================
// MAbattery.
//=============================================================================
class MAbattery extends TournamentPlayer;

#exec MESH IMPORT MESH=MAbattery ANIVFILE=MODELS\MAbattery_a.3d DATAFILE=MODELS\MAbattery_d.3d MLOD=0
#exec MESH ORIGIN MESH=MAbattery X=0.00 Y=0.00 Z=0.00 YAW=0.00 ROLL=0.00 PITCH=0.00

#exec MESH SEQUENCE MESH=MAbattery SEQ=All       STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=MAbattery SEQ=Still     STARTFRAME=0 NUMFRAMES=1



#exec MESHMAP SCALE MESHMAP=MAbattery X=0.13 Y=0.13 Z=0.26


