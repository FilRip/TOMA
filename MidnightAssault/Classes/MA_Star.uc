class MA_Star extends Decoration;

#exec mesh import mesh=MAstar anivfile=Models\MAstar_a.3d datafile=Models\MAstar_d.3d x=0 y=0 z=0
#exec mesh origin mesh=MAstar x=0 y=0 z=0
#exec mesh sequence mesh=MAstar seq=All startframe=0 numframes=1
#exec mesh sequence mesh=MAstar seq=Still startframe=0 numframes=1

#exec meshmap new meshmap=MAstar mesh=MAstar
#exec meshmap scale meshmap=MAstar x=0.12500 y=0.12500 z=0.25000

defaultproperties
{
    bStatic=False
    DrawType=2
    Mesh=LodMesh'MAstar'
    DrawScale=0.00
    bUnlit=True
    MultiSkins=Texture'UWindow.WhiteTexture'
}
