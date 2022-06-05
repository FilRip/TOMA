class TOMARemover extends s_Remover;

simulated function BeginPlay()
{
	local	int	i;

	// list
	for (i=0;i<32;i++)
		if (DestroyActor[i]!="")
			DestroyClass(DestroyActor[i]);

	// Weapons
	for (i=0;i<=class'TOMA21.TOMAWeaponsHandler'.default.NumWeapons;i++)
		if (class'TOMA21.TOMAWeaponsHandler'.default.WeaponStr[i]!="")
			DestroyClass(class'TOMA21.TOMAWeaponsHandler'.default.WeaponStr[i] );

	Destroy();
}

defaultproperties
{
    DestroyActor(30)="TOMA21.TOMAScriptedPawn"
    DestroyActor(31)="TOMA21.TOMAShieldZone"
}

