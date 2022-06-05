class TOMAMakeShield extends s_Concussion config(TOMA);

simulated function Explosion (Vector HitLocation)
{
	Spawn(class'TOMAShieldZone',,,Self.Location);
	self.Destroy();
}

defaultproperties
{
}
