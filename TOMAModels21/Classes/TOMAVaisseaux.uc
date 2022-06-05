Class TOMAVaisseaux extends Actor;
//=============================================================================
// Scout.
//=============================================================================

#exec mesh IMPORT mesh=Scout ANIVFILE=MODELS\Vaisseaux\Scout_a.3d DATAFILE=MODELS\Vaisseaux\Scout_d.3d
#exec MESH LODPARAMS MESH=Scout HYSTERESIS=0.00 STRENGTH=0.00 MINVERTS=10.00 MORPH=0.30 ZDISP=0.00
#exec MESH ORIGIN MESH=Scout X=0.00 Y=0.00 Z=0.00 YAW=0.00 ROLL=0.00 PITCH=0.00

#exec MESH SEQUENCE MESH=Scout SEQ=All       STARTFRAME=0 NUMFRAMES=4
#exec MESH SEQUENCE MESH=Scout SEQ=Scout     STARTFRAME=0 NUMFRAMES=2
#exec MESH SEQUENCE MESH=Scout SEQ=crash     STARTFRAME=2 NUMFRAMES=2

#exec MESHMAP SETTEXTURE MESHMAP=Scout NUM=0 texture=TOMATex21.Vaisseaux.JScout1
#exec MESHMAP SETTEXTURE MESHMAP=Scout NUM=1 TEXTURE=TOMATex21.Vaisseaux.JScout2

#exec MESHMAP scale MESHMAP=Scout X=4.50 Y=4.50 Z=9.00

//=============================================================================
// spaceship.
//=============================================================================

#exec mesh IMPORT mesh=spaceship ANIVFILE=MODELS\Vaisseaux\spaceship_a.3d DATAFILE=MODELS\Vaisseaux\spaceship_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=spaceship X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=spaceship SEQ=All       STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=spaceship SEQ=SPACESHIP STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=spaceship MESH=spaceship
#exec MESHMAP SCALE MESHMAP=spaceship X=4.5 Y=4.5 Z=9

#exec MESHMAP SETTEXTURE MESHMAP=spaceship NUM=0 TEXTURE=TOMATex21.Vaisseaux.Jspaceship1
#exec MESHMAP SETTEXTURE MESHMAP=spaceship NUM=1 TEXTURE=TOMATex21.Vaisseaux.Jspaceship2
#exec MESHMAP SETTEXTURE MESHMAP=spaceship NUM=2 TEXTURE=TOMATex21.Vaisseaux.Jspaceship3
#exec MESHMAP SETTEXTURE MESHMAP=spaceship NUM=3 TEXTURE=TOMATex21.Vaisseaux.Jspaceship4
#exec MESHMAP SETTEXTURE MESHMAP=spaceship NUM=4 TEXTURE=TOMATex21.Vaisseaux.Jspaceship5
#exec MESHMAP SETTEXTURE MESHMAP=spaceship NUM=5 texture=TOMATex21.Vaisseaux.Jspaceship6
#exec MESHMAP SETTEXTURE MESHMAP=spaceship NUM=6 TEXTURE=TOMATex21.Vaisseaux.Jspaceship7



defaultproperties
{
	bHidden=True
}

