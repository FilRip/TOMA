class TO_ModelHandler extends Engine.Actor;

enum EModelType {
	MT_None,
	MT_SpecialForces,
	MT_Terrorist,
	MT_Hostage
};
var EModelType ModelType;
var Mesh ModelMesh;
var Mesh SwimMesh;
var int bFemale;

static final function int GetNextModel (int Num, int Team)
{
}

static final function int NumberOfModelsInGame (Pawn Other, int ModelId)
{
}

static final function byte DressModel (Actor A, byte Num)
{
}

static final function int GetPrevModel (int Num, int Team)
{
}

static final function bool CheckTeamModel (Pawn P, int Num)
{
}

static final function int GetRandomHostageModel (Pawn Other)
{
}

static final function Mesh GetSwimMesh (Mesh M)
{
}

static final function Mesh GetRegularMesh (Mesh M)
{
}

static final function string GetModelName (int Num)
{
}

static final function bool IsATerrModel (int Num)
{
}

static final function byte GetRandomSFModel (Pawn Other)
{
}

static final function int GetRandomTerrModel (Pawn Other)
{
}

static final function int GetModelNamed (string Name)
{
}

static final function bool IsASFModel (int Num)
{
}


defaultproperties
{
}

