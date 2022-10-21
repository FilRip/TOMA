class TGAS_PlyReplInfo expands ReplicationInfo;

var TGAS_player PawnOwner;
var byte Teartime;
var Bool binitialized;

replication
{
reliable if (ROLE == ROLE_Authority)
    Teartime;

  // Functions clients can call on server
  reliable if( Role < ROLE_Authority)
       SetGasSkin;

}


simulated function PostBeginPlay ()
{
	PawnOwner=TGAS_player(Owner);
}

function BeginPlay()
{
   enable ('timer');
   SetTimer(0.4, true);
}

function SetGasSkin ()
{
// Remarked due to 3.32 skinhack kick
/*
    if ( (PawnOwner.playermodel==7) || (PawnOwner.playermodel==8) || (PawnOwner.playermodel==12) )
       {
        // Jill:
        PawnOwner.MultiSkins[4]=Texture(DynamicLoadObject("teargas3.jgasface",Class'Texture'));
       }
    else if ( (PawnOwner.playermodel==5) || (PawnOwner.playermodel==6) )
       {
        // Seal:
        PawnOwner.MultiSkins[0]=Texture(DynamicLoadObject("teargas3.tgasface",Class'Texture'));
       }
    else
       {
        // Terror2:
        PawnOwner.MultiSkins[4]=Texture(DynamicLoadObject("teargas3.tgasface",Class'Texture'));
       }
*/
 if (PawnOwner.Playermodel == 1)
	 PawnOwner.Playermodel = 19;
 else if (PawnOwner.Playermodel == 2)
	 PawnOwner.Playermodel = 24;
 else if (PawnOwner.Playermodel == 3)
	 PawnOwner.Playermodel = 25;
 else if (PawnOwner.Playermodel == 4)
	 PawnOwner.Playermodel = 26;
 else if (PawnOwner.Playermodel == 5)
	 PawnOwner.Playermodel = 21;
 else if (PawnOwner.Playermodel == 6)
	 PawnOwner.Playermodel = 20;
 else if (PawnOwner.Playermodel == 7)
	 PawnOwner.Playermodel = 22;
 else if (PawnOwner.Playermodel == 8)
	 PawnOwner.Playermodel = 23;
 else if (PawnOwner.Playermodel == 10)
	 PawnOwner.Playermodel = 20;
 else if (PawnOwner.Playermodel == 11)
	 PawnOwner.Playermodel = 27;
 else if (PawnOwner.Playermodel == 12)
	 PawnOwner.Playermodel = 28;
 else if (PawnOwner.Playermodel == 15)
	 PawnOwner.Playermodel = 29;
 else if (PawnOwner.Playermodel == 16)
	 PawnOwner.Playermodel = 30;
 else if (PawnOwner.Playermodel == 17)
	 PawnOwner.Playermodel = 25;
 else if (PawnOwner.Playermodel == 18)
	 PawnOwner.Playermodel = 19;

 PawnOwner.SetMultiSkin (self,"","",PawnOwner.playermodel);

}


simulated function Timer ()
{
if (Pawnowner == none)
 {
	destroy();
	return;
 }

if (!binitialized)
	{
	Pawnowner.setupclient();
	binitialized = True;
	}

if ( Level.Netmode == NM_client )
   return;

	if ( PawnOwner == None )
	{
//  log ("Teargas mutator - Player gone, teargas RI destroyed");
		Destroy();
	}

if ( PawnOwner.bnotplaying )
 {
   teartime = 0;
   return;
 }
If (Teartime > 0)
 {
  teartime-=2;
 }

}

