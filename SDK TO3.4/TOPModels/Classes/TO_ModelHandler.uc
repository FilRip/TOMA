class TO_ModelHandler extends Actor;

enum EModelType
{
	MT_None,
	MT_SpecialForces,
	MT_Terrorist,
	MT_Hostage
};

var string Skin0[32];
var string Skin1[32];
var string Skin2[32];
var string Skin3[32];
var string Skin4[32];
var string Skin5[32];
var string Skin6[32];
var string Skin7[32];
var Mesh ModelMesh[32];
var localized string ModelName[32];
var int bFemale[32];
var EModelType ModelType[32];

static final function int NumberOfModelsInGame (Pawn Other, int ModelId)
{
}

static final function byte GetRandomSFModel (Pawn Other)
{
}

static final function int GetRandomTerrModel (Pawn Other)
{
}

static final function int GetRandomHostageModel (Pawn Other)
{
}

static final function int GetModelNamed (string Name)
{
}

static final function bool IsASFModel (int Num)
{
}

static final function bool IsATerrModel (int Num)
{
}

static final function bool CheckTeamModel (Pawn P, int Num)
{
}

static final function string GetModelName (int Num)
{
}

static final function int GetNextModel (int Num, int Team)
{
}

static final function int GetPrevModel (int Num, int Team)
{
}

static final function byte DressModel (Actor A, byte Num)
{
}
