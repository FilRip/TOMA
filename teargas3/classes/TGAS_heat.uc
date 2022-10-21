class TGAS_heat extends Effects;

#exec TEXTURE IMPORT NAME=heat FILE=Textures\heat.bmp GROUP="Special"
#exec TEXTURE IMPORT NAME=heat2 FILE=Textures\heat2.bmp GROUP="Special"

var int FatnessOffset;
var bool RenderMe,bNoZBufferMe;

simulated function Tick(float DeltaTime)
{
  local int IdealFatness;

 if (owner == none )
    	destroy();
 else if (pawn(owner).health == 0)
    	destroy();

  if ( bHidden || (Level.NetMode == NM_DedicatedServer) || (Owner == None) )
  {
    Disable('Tick');
    return;
  }

  IdealFatness = Owner.Fatness; // Convert to int for safety.
  IdealFatness += FatnessOffset;

  if ( Fatness > IdealFatness )
    Fatness = Max(IdealFatness, Fatness - 130 * DeltaTime);
  else
  Fatness = Min(IdealFatness, 255);
}

defaultproperties
{
    FatnessOffset=24
    bAnimByOwner=True
    bOwnerNoSee=True
    bNetTemporary=False
    bTrailerSameRotation=True
    Physics=11
    RemoteRole=0
    DrawType=2
    Style=3
    Texture=Texture'Special.Heat'
    ScaleGlow=0.80
    Fatness=140
    bUnlit=True
}
