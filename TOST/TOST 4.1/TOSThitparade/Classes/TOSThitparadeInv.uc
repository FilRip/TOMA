class TOSThitparadeInv expands Inventory;

var TOSTClientPiece		Connect;

// init

simulated event PostNetBeginPlay ()
{
	super.PostNetBeginPlay();
	if ( (Level.NetMode == NM_Client && ROLE < ROLE_SimulatedProxy) || (!bNetOwner))
		return;
	// ClientPiece only used for sending, so no need for an extra class
	Connect = spawn(class'TOSTClientPiece', self);
}

// server features

exec simulated function toggleHitHUD()
{
	Connect.SendMessage(250);
}

defaultproperties
{
	bHidden=True
}