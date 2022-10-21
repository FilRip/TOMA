class TGAS_Brightblinder extends actor;

#exec TEXTURE IMPORT NAME=lens3  FILE=Textures\lens3.bmp  GROUP="Special"

var bool bRenderme;

defaultproperties
{
    bOnlyOwnerSee=True
    bDirectional=True
    Style=3
    Texture=Texture'Special.lens3'
    DrawScale=0.00
}
