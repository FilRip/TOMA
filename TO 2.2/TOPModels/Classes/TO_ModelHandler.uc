//=============================================================================
// TO_ModelHandler
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_ModelHandler extends Actor
	abstract;

// TO model definition
var	localized string	Skin0[32], Skin1[32], Skin2[32], Skin3[32], Skin4[32], Skin5[32];
var	Mesh							ModelMesh[32];
var	localized string	ModelName[32];

enum EModelType
{
	MT_None,
	MT_SpecialForces,					
	MT_Terrorist,
	MT_Hostage,
};

var	EModelType	ModelType[32];



///////////////////////////////////////
// GetRandomSFModel
///////////////////////////////////////

final static function byte GetRandomSFModel(Pawn Other)
{
	local	int		i, num;
	local	float	Score, BestScore;

	while ( i < 32 )
	{
		//log("model "$PlayerModel[i].name$" num:"$i$" mesh:"$PlayerModel[i].Mesh);
		if (default.ModelType[i] == MT_SpecialForces)
		{
			Score = Frand();
			if (Score > BestScore)
			{
				num = i;
				BestScore = Score;
			}
		}
		i++;
	}

	return num;
}


///////////////////////////////////////
// GetRandomTerrModel
///////////////////////////////////////

final static function int GetRandomTerrModel(Pawn Other)
{
	local	int		i, num;
	local	float	Score, BestScore;

	while ( i < 32 )
	{		
		if (default.ModelType[i] == MT_Terrorist)
		{
			Score = Frand();
			if (Score > BestScore)
			{
				num = i;
				BestScore = Score;
			}
		}
		i++;
	}
	return num;
}


///////////////////////////////////////
// GetRandomHostageModel
///////////////////////////////////////

final static function int GetRandomHostageModel()
{
	local	int		i, num;
	local	float	Score, BestScore;

	while (i < 32)
	{		
		if (default.ModelType[i] == MT_Hostage)
		{
			Score = Frand();
			if (Score > BestScore)
			{
				num = i;
				BestScore = Score;
			}
		}
		i++;
	}
	return num;
}


///////////////////////////////////////
// IsASFModel
///////////////////////////////////////

final static function bool IsASFModel(int num)
{
	if (default.ModelType[num] == MT_SpecialForces)
		return true;

	return false;
}


///////////////////////////////////////
// IsATerrModel
///////////////////////////////////////

final static function bool IsATerrModel(int num)
{
	if (default.ModelType[num] == MT_Terrorist)
		return true;

	return false;
}


///////////////////////////////////////
// GetModelName
///////////////////////////////////////

final static function String GetModelName(int num)
{
	return default.ModelName[num];
}


///////////////////////////////////////
// GetNextModel
///////////////////////////////////////

final static function int GetNextModel(int num, int team)
{
	while ( true )
	{
		num++;
		if ( num == 32 )
			num = 0;

		if ( default.ModelName[num] != "" )
		{
			if ( (team == 0) && (default.ModelType[num] == MT_Terrorist) )
				return num;

			if ( (team == 1) && (default.ModelType[num] == MT_SpecialForces) )
				return num;
		}
	}
}


///////////////////////////////////////
// GetPrevModel
///////////////////////////////////////

final static function int GetPrevModel(int num, int team)
{
	while ( true )
	{
		num--;
		if ( num == -1 )
			num = 31;

		if ( default.ModelName[num] != "" )
		{
			if ( (team == 0) && (default.ModelType[num] == MT_Terrorist) )
				return num;

			if ( (team == 1) && (default.ModelType[num] == MT_SpecialForces) )
				return num;
		}
	}
}


///////////////////////////////////////
// DressModel
///////////////////////////////////////

final static function DressModel(Actor A, int num) 
{
	A.Mesh = default.ModelMesh[num];

	if ( default.Skin0[num] != "" )
		A.MultiSkins[0] = Texture(DynamicLoadObject(default.Skin0[num], class'Texture'));
	
	A.MultiSkins[1] = Texture(DynamicLoadObject(default.Skin1[num], class'Texture'));
	A.MultiSkins[2] = Texture(DynamicLoadObject(default.Skin2[num], class'Texture'));
	A.MultiSkins[3] = Texture(DynamicLoadObject(default.Skin3[num], class'Texture'));

	if ( default.Skin4[num] != "" )
		A.MultiSkins[4] = Texture(DynamicLoadObject(default.Skin4[num], class'Texture'));

	if ( default.Skin5[num] != "" )
		A.MultiSkins[5] = Texture(DynamicLoadObject(default.Skin5[num], class'Texture'));
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////



/*
  ModelName(0)="SFLight TEST"
	ModelType(0)=MT_Terrorist
	ModelMesh(0)=SkeletalMesh'TOPModels.SFLightMesh'
	Skin0(0)="TOPModels.SFLightTex0"
	Skin1(0)="TOPModels.SFLightTex1"
	Skin2(0)="TOPModels.SFLightTex2"
	Skin3(0)="TOPModels.SFLightTex3"
	Skin4(0)="TOPModels.SFLightTex4"

	ModelName(6)="White Seal"
	ModelType(6)=MT_Terrorist
	ModelMesh(6)=SkeletalMesh'TOPModels.SealMesh'
	Skin0(6)="TOPModels.WhiteSeal_Hands"
  Skin1(6)="TOPModels.WhiteSeal_Face"
	Skin2(6)="TOPModels.WhiteSeal_Legs"	
  Skin3(6)="TOPModels.WhiteSeal_Torse" 

	ModelName(1)="SFMedium Police TEST"
	ModelType(1)=MT_SpecialForces
	ModelMesh(1)=SkeletalMesh'TOPModels.SFMediumMesh'
	Skin0(1)="TOPModels.SFMediumTex4"
	Skin1(1)="TOPModels.SFMediumTex2"
	Skin2(1)="TOPModels.SFMediumTex1"
	Skin3(1)="TOPModels.SFMediumTex3"
	Skin4(1)="TOPModels.SFMediumTex0"
	Skin5(1)="TOPModels.SFMediumTex4"

	ModelName(7)="S.W.A.T."
	ModelType(7)=MT_SpecialForces
	ModelMesh(7)=SkeletalMesh'TOPModels.TerrorMesh'
	Skin1(7)="TOPModels.SWAT_Face"
	Skin2(7)="TOPModels.SWAT_Hands"
	Skin3(7)="TOPModels.SWAT_Legs"
	Skin4(7)="TOPModels.SWAT_Torse"

	ModelName(8)="Police"
	ModelType(8)=MT_SpecialForces
	ModelMesh(8)=SkeletalMesh'TOPModels.TerrorMesh'
  Skin1(8)="TOPModels.Police_Face"
	Skin2(8)="TOPModels.Police_Hands"
	Skin3(8)="TOPModels.Police_Legs"
	Skin4(8)="TOPModels.Police_Torse"

	ModelName(9)="S.W.A.T. Black Heavy"
	ModelType(9)=MT_SpecialForces
	ModelMesh(9)=SkeletalMesh'TOPModels.SFMediumMesh'
	Skin0(9)="TOPModels.SFMedSWATTex4"
	Skin1(9)="TOPModels.SWAT_Face"
	Skin2(9)="TOPModels.SFMedSWATTex1"
	Skin3(9)="TOPModels.SFMedSWATTex3"
	Skin4(9)="TOPModels.SFMedSWATTex0"
	Skin5(9)="TOPModels.SFMedSWATTex4"


*/

/*

	ModelName(10)="Junky"
	ModelType(10)=MT_Terrorist
	ModelMesh(10)=SkeletalMesh'TOPModels.TerrorMesh'
	Skin1(10)="TOPModels.CJunk_Face"
	Skin2(10)="TOPModels.Scarface_Hands"
	Skin3(10)="TOPModels.SFMediumSnowTex3"
	Skin4(10)="TOPModels.Scarface_Torse"



*/

defaultproperties
{
     Skin0(2)="TOPModels.SFMediumArmyTex2"
     Skin0(3)="TOPModels.SFMediumDesertTex2"
     Skin0(4)="TOPModels.SWAT_Face"
     Skin0(9)="TOPModels.YakuzaTorse"
     Skin1(0)="TOPModels.CJunk_Face"
     Skin1(1)="TOPModels.HSuitHead"
     Skin1(2)="TOPModels.SFMediumArmyTex1"
     Skin1(3)="TOPModels.SFMediumDesertTex1"
     Skin1(4)="TOPModels.SFMedSWATTex1"
     Skin1(5)="TOPModels.SWAT_Face"
     Skin1(6)="TOPModels.CC_Face"
     Skin1(7)="TOPModels.CCSM_Face"
     Skin1(8)="TOPModels.Scarface_Face"
     Skin1(9)="TOPModels.YakuzaArms"
     Skin2(0)="TOPModels.SFMediumSnowTex1"
     Skin2(1)="TOPModels.HSuitTorse"
     Skin2(2)="TOPModels.SFMediumArmyTex3"
     Skin2(3)="TOPModels.SFMediumDesertTex3"
     Skin2(4)="TOPModels.SFMedSWATTex3"
     Skin2(5)="TOPModels.SFMedSWATBTex1"
     Skin2(6)="TOPModels.CCSM_Hands"
     Skin2(7)="TOPModels.CCSM_Hands"
     Skin2(8)="TOPModels.Scarface_Hands"
     Skin2(9)="TOPModels.YakuzaHead"
     Skin3(0)="TOPModels.SFMediumSnowTex3"
     Skin3(1)="TOPModels.HSuitLegs"
     Skin3(2)="TOPModels.SFMediumArmyTex0"
     Skin3(3)="TOPModels.SFMediumDesertTex0"
     Skin3(4)="TOPModels.SFMedSWATTex0"
     Skin3(5)="TOPModels.SFMedSWATBTex3"
     Skin3(6)="TOPModels.CCSM_Legs"
     Skin3(7)="TOPModels.CCSM_Legs"
     Skin3(8)="TOPModels.Scarface_Legs"
     Skin3(9)="TOPModels.YakuzaLegs"
     Skin4(0)="TOPModels.SFMediumSnowTex0"
     Skin4(2)="TOPModels.SFMediumArmyTex4"
     Skin4(3)="TOPModels.SFMediumDesertTex4"
     Skin4(4)="TOPModels.SFMedSWATTex4"
     Skin4(5)="TOPModels.SFMedSWATTex0"
     Skin4(6)="TOPModels.CCSM_Torse"
     Skin4(7)="TOPModels.CCSM_Torse"
     Skin4(8)="TOPModels.Scarface_Torse"
     Skin5(2)="TOPModels.SFMediumArmyTex4"
     Skin5(3)="TOPModels.SFMediumDesertTex4"
     Skin5(4)="TOPModels.SFMedSWATTex4"
     ModelMesh(0)=SkeletalMesh'TOPModels.TerrorMesh'
     ModelMesh(1)=SkeletalMesh'TOPModels.HostageMesh'
     ModelMesh(2)=SkeletalMesh'TOPModels.SFMediumMesh'
     ModelMesh(3)=SkeletalMesh'TOPModels.SFMediumMesh'
     ModelMesh(4)=SkeletalMesh'TOPModels.SFMediumMesh'
     ModelMesh(5)=SkeletalMesh'TOPModels.TerrorMesh'
     ModelMesh(6)=SkeletalMesh'TOPModels.TerrorMesh'
     ModelMesh(7)=SkeletalMesh'TOPModels.TerrorMesh'
     ModelMesh(8)=SkeletalMesh'TOPModels.TerrorMesh'
     ModelMesh(9)=SkeletalMesh'TOPModels.YakuzaMesh'
     ModelName(0)="Alpine Squad"
     ModelName(1)="Hostage SuitBoy"
     ModelName(2)="U.S. Army"
     ModelName(3)="Desert Trooper"
     ModelName(4)="Black S.W.A.T."
     ModelName(5)="Blue S.W.A.T."
     ModelName(6)="Camo Johnson"
     ModelName(7)="Camo Ski Mask"
     ModelName(8)="Scarface"
     ModelName(9)="Yakuza"
     ModelType(0)=MT_Terrorist
     ModelType(1)=MT_Hostage
     ModelType(2)=MT_SpecialForces
     ModelType(3)=MT_SpecialForces
     ModelType(4)=MT_SpecialForces
     ModelType(5)=MT_SpecialForces
     ModelType(6)=MT_Terrorist
     ModelType(7)=MT_Terrorist
     ModelType(8)=MT_Terrorist
     ModelType(9)=MT_Terrorist
}
