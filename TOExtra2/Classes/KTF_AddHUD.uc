class KTF_AddHUD expands SpawnNotify;

simulated event Actor SpawnNotification(Actor A)
{
    local KTF_MutatorHUD nh;

    nh=spawn(class'KTF_MutatorHUD',A);
    nh.originalhud=s_HUD(A);
	if (HUD(A).HUDMutator==none)
		HUD(A).HUDMutator=nh;
	else
		HUD(A).HUDMutator.AddMutator(nh);

	return A;
}

defaultproperties
{
	ActorClass=class's_SWAT.s_HUD'
}

