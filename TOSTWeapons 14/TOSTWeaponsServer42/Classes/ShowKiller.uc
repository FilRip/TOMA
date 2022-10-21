class ShowKiller extends Actor;

var string killer;
var TOSTWeaponsServer father;
var bool bDone;

function spawned()
{
	setTimer(0.5,true);
}

function Timer()
{
	if ( bDone )
	{
		father.Params.param6 = PlayerPawn(owner);
		father.Params.param4 = "";
		father.SendClientMessage(556);
		destroy();
	}
	else
	{
		if ( killer != "" && father != none )
		{
			father.Params.param6 = PlayerPawn(owner);
			father.Params.param4 = killer;
			father.SendClientMessage(556);
			setTimer(2,true);
			bDone = true;
		}
	}
}
