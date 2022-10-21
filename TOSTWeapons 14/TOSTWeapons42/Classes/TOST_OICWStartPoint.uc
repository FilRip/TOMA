class TOST_OICWStartPoint extends TO_OICWStartPoint;

var bool bCanPickup;

function bool IsRevelant(Actor Other)
{
	local byte Team;

	if ( Other.IsA('Pawn') && bCanPickup )
	{
		Team=CanPickupOICW;
		if ( (Team == 2) || (Pawn(Other).PlayerReplicationInfo.Team == Team) )
		{
			DisplayMessage(Other);
			return True;
		}
	}
	return False;
}

function DisplayMessage(Actor Other)
{
	local Pawn P;
	local PlayerPawn PP;
	local string Message;

 	if ( Pawn(Other).PlayerReplicationInfo.Team == 0 )
 		Message = "Warning: Terrorsits stole the OICW !";
 	else if ( Pawn(Other).PlayerReplicationInfo.Team == 1 )
		Message = "Warning: SF stole the OICW !";
	else Message = "Warning: Someone stole the OICW !";

	for (P=Level.PawnList;P!=none;P=P.NextPawn)
	{
		PP=PlayerPawn(P);
		if ( PP == None )
		{
			continue;
		}
		PP.ClearProgressMessages();
		PP.SetProgressTime(6.00);
		PP.SetProgressMessage(Message,0);
	}
}

defaultproperties
{
	bCanPickup=true
}
