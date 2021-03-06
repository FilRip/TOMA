class TOMAShieldEffect extends Effects;

simulated function PostBeginPlay()
{
    SetTimer(0.1,true);
}

simulated function Timer()
{
    if (Owner==None) destroy();
    if ((TOMAPlayer(Owner)!=None) && (TOMAPlayer(Owner).CptIAR==0)) destroy();
    else if ((TOMABot(Owner)!=None) && (TOMABot(Owner).CptIAR==0)) destroy();
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

