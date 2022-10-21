class TMShield extends Actor;

var Pawn PawnOwner;
var int i;

auto state Explode
{
	simulated function Tick(float DeltaTime)
	{
        if (PawnOwner!=None)
            SetLocation(PawnOwner.Location);
	}

    function Timer()
    {
        i++;
        if (i==TMMod(Level.Game).SecGodMod) destroy();
    }

	simulated function BeginState()
	{
        SetTimer(1,true);
        LoopAnim('All',0.6);
	}
}

defaultproperties
{
    DrawType=DT_Mesh
    mesh=Mesh'botpack.Tele2'
    DrawScale=1
    LifeSpan=10
    Style=STY_Translucent
}

