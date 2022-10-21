//=============================================================================
// TO_GiveMoney.
//=============================================================================
class TO_GiveMoney expands TO_Logic;

var	bool	Triggered;
var()	int		Amount;
var()	bool	bTriggerOnceOnly;
var()	bool	bSummon;

auto state() IsResetableActor {

	function BeginPlay() {
		Triggered = false;
	}	

	function Trigger( actor Other, pawn EventInstigator ) {
		local 	s_MoneyPickUp	money;

		if (!Triggered) {

			if ( ( EventInstigator.IsA('s_Player') && !(s_Player(EventInstigator).bNotPlaying) ) || ( EventInstigator.IsA('s_Bot') && !s_Bot(EventInstigator).bNotPlaying ) ) {
				if (bSummon) {
					money = spawn(class's_MoneyPickup');
					money.amount = amount;
					log("Money spawned");
				}
				else {
					
					if (Level.Game != None)	{
						s_SWATGame(Level.Game).AddMoney(EventInstigator, Amount);
					}

					PlaySound (Sound'TODatas.Misc.buyammo', ,2.0);
					log("Money given");

				}

				if (bTriggerOnceOnly)
					Triggered = True;

			}

		}

	}

}

defaultproperties
{
     Amount=500
     bTriggerOnceOnly=True
     InitialState=IsResetableActor
}
