class TO_TextureMaterial extends Engine.Info;

struct TBulletHit
{
	var bool bSmoke;
	var bool bImpactM;
	var bool bSparks;
	var bool bChips;
	var float ChipsSize;
	var Texture BHDecal;
	var Sound BI;
	var bool bRicochet;
}
var TBulletHit bh;
struct TTextureMaterial
{
	var Sound SoundID;
	var float WalkVolume;
	var Sound FSSound0;
	var Sound FSSound1;
	var bool bFootPrint;
}
var TTextureMaterial TM;

static final function float RandomizeFloat (float Value)
{
}

static final function byte PlayFootStepSound (Pawn P, Texture Tex, int MaterialIndex)
{
}

static final function byte FindMaterialIndex (Sound TexSound)
{
}

static final function PlayDefaultFootStep (Pawn P)
{
}

static final function Texture GetBulletHitDecal (byte MaterialIndex)
{
}

static final function bool GetbFootPrint (byte MaterialIndex)
{
}

static final function bool GetbSmoke (byte MaterialIndex)
{
}

static final function bool GetbImpactM (byte MaterialIndex)
{
}

static final function bool GetbSparks (byte MaterialIndex)
{
}

static final function bool GetbChips (byte MaterialIndex)
{
}

static final function float GetChipsSize (byte MaterialIndex)
{
}

static final function Sound GetBISound (byte MaterialIndex)
{
}

static final function byte GetDefaultMaterial ()
{
}

static final function bool GetbRicochet (byte MaterialIndex)
{
}


defaultproperties
{
}

