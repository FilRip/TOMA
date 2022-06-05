class TOMAEnergyShieldModel extends Actor;

// FilRip
//
// You search something ?

//#exec TEXTURE IMPORT NAME=ShieldTex FILE=textures\shield.PCX GROUP="Skins" Flags=3

#EXEC OBJ LOAD name=TOMATex FILE=../Textures/TOMATex21.utx PACKAGE=TOMATex21

#exec mesh IMPORT MESH=EnergyShieldM ANIVFILE=MODELS\Weapons\Shield_a.3D DATAFILE=MODELS\Weapons\Shield_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=EnergyShieldM X=0 Y=0 Z=0 YAW=0 PITCH=64
#exec MESH SEQUENCE MESH=EnergyShieldM SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESHMAP NEW MESHMAP=EnergyShieldM MESH=EnergyShieldM
#exec MESHMAP SCALE MESHMAP=EnergyShieldM X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=EnergyShieldM NUM=1 texture=TOMATex21.Weapons.Shield
#exec MESHMAP SETTEXTURE MESHMAP=EnergyShieldM NUM=0 TEXTURE=TOMATex21.Weapons.Shield

defaultproperties
{
}
