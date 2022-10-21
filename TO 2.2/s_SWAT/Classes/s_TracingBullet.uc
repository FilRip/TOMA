//=============================================================================
// s_TracingBullet
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class s_TracingBullet extends s_Projectile;
 

///////////////////////////////////////
// PostBeginPlay
///////////////////////////////////////

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	//if ( Level.bDropDetail )
		LightType = LT_None;
}
 

///////////////////////////////////////
// defaultproperties
///////////////////////////////////////
//bReplicateInstigator=false
/*
    LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=30
     LightSaturation=69
     LightRadius=3
*/

defaultproperties
{
     bHidden=False
     bOwnerNoSee=False
     bOnlyOwnerSee=False
     Style=STY_Translucent
     Texture=FireTexture'UnrealShare.Effect1.FireEffect1u'
     Mesh=LodMesh'Botpack.MiniTrace'
     DrawScale=0.800000
     AmbientGlow=187
     NetPriority=2.000000
}
