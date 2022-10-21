class TGAS_GasSmoke expands UT_SpriteSmokePuff;

#exec TEXTURE IMPORT NAME=tgas  FILE=Textures\tgas.bmp  GROUP="Smoke"


simulated function BeginPlay()
{
Texture = Texture'tgas';
Enable('Timer');
SetTimer(0.15, true);
drawscale = 4;
scaleglow = 0.4;
ambientglow = 0.25;
}

simulated function Timer()
{
DrawScale += 1.2;
ScaleGlow*=0.92;
}

defaultproperties
{
    RisingRate=0.00
    LifeSpan=8.00
    LightBrightness=1
    LightSaturation=0
}
