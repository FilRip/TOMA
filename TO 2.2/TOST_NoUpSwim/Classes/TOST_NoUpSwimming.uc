Class TOST_NoUpSwimming extends TOST_ServerModule;

function PreInitModule ()
{
	local ZoneInfo ZI;

	if (Level.Title~="RapidWaters][")
		foreach AllActors(Class'ZoneInfo',ZI)
			if ( (ZI.Location == vect(600.804199,-760.311768,-476.897766)) || (ZI.Location == vect(551.197632,-217.899994,-437.349152)) )
				ZI.ZoneGravity=vect(288000.00,0.00,-25000.00);
}

defaultproperties
{
   ID="Prevent UpSwimming the Rapid"
   Version="1.0"
   Build="H.lotti"
   bServerSide=True
}
