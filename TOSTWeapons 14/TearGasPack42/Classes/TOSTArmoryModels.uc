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
///////////////////////////////////////
// TearGas
///////////////////////////////////////

//smoke
#exec texture IMPORT NAME=GreenSmoke FILE=Textures\TearGas\GreenSmoke.pcx LODSET=2 MIPS=OFF FLAGS=2

//teargas
#exec texture IMPORT NAME=TearGasWorld FILE=Textures\TearGas\TearGasWorld.pcx LODSET=2
#exec texture IMPORT NAME=TearGasTex0 FILE=Textures\TearGas\TearGasTex0.pcx LODSET=2
#exec texture IMPORT NAME=TearGasTex1 FILE=Textures\TearGas\TearGasTex1.pcx LODSET=2

//teargas 3rdPerson
#exec mesh IMPORT MESH=TearGas ANIVFILE=MODELS\TearGas_a.3d DATAFILE=MODELS\TearGas_d.3d X=0 Y=0 Z=0
#exec mesh LODPARAMS MESH=TearGas STRENGTH=0.3
#exec mesh ORIGIN MESH=TearGas X=-210 Y=-10 Z=-20 YAW=-64 PITCH=0 ROLL=0

#exec MESHMAP new   MESHMAP=TearGas MESH=TearGas
#exec MESHMAP scale MESHMAP=TearGas X=0.06 Y=0.06 Z=0.12

#exec MESHMAP SETTEXTURE MESHMAP=TearGas NUM=0 TEXTURE=TearGasWorld

//Solid && trans
#exec texture IMPORT NAME=TearGasTrans FILE=TEXTURES\Trans\TearGas.pcx LODSET=2 MIPS=OFF FLAGS=2
#exec texture IMPORT NAME=TearGasSolid FILE=TEXTURES\Solid\TearGas.pcx LODSET=2 MIPS=OFF FLAGS=2
