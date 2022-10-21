class TO_MeshActor extends Info;


var TO_TeamSelect NotifyClient;


function AnimEnd()
{
	NotifyClient.AnimEnd(Self);
}

defaultproperties
{
     bHidden=False
     bOnlyOwnerSee=True
     bAlwaysTick=True
     Physics=PHYS_Rotating
     RemoteRole=ROLE_None
     DrawType=DT_Mesh
     DrawScale=0.030000
     AmbientGlow=255
     bUnlit=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
