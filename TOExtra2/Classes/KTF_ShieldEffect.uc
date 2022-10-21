class KTF_ShieldEffect extends Effects;

var byte ic;

simulated function PostBeginPlay()
{
    SetTimer(1,true);
}

simulated function Timer()
{
    if (Owner==None) destroy();
    ic--;
    if (ic==0) destroy();
}

defaultproperties
{
     bAnimByOwner=True
     bNetTemporary=False
     Physics=PHYS_Trailer
     bTrailerSameRotation=True
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_Mesh
     Style=STY_Translucent
     AmbientGlow=64
     Fatness=157
     bUnlit=True
     bMeshEnviroMap=True
     bOwnerNoSee=True
     bOnlyOwnerSee=False
}

