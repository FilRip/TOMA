class TGAS_ProjGasGren extends TO_ProjSmokeGren;

var bool	bExploded;
var Int gastime;

simulated function BeginPlay()
{
     Super.BeginPlay();
 gastime = 120;

          SetTimer(4.0, false);
	Enable('Timer');
}

simulated function Explosion(vector HitLocation)
{
    	bNoSmoke = true;
     bExploded = true;
     SoundVolume=128;
     SetTimer(0.01, false);
}

simulated function SpawnSomeSmoke()
{
local TGAS_GasSmoke b;

       b = Spawn(class'TGAS_GasSmoke');
     b.RemoteRole = ROLE_None;
      b.Velocity.x = 60 - ( FRand()* 120);
      b.Velocity.y = 60 - ( FRand()* 120);
}

function BlindEffect()
{
local TGAS_plyReplInfo P;
local s_NPCHostage H;
local byte i;

     foreach AllActors(class'teargas3.TGAS_plyReplInfo', P)
     {
	if (p.owner != none)
	{

          if ( ( VSize(P.owner.Location - Location) < gastime ) && (!TGAS_player(p.owner).bGmaskActive) && (TGAS_player(p.owner).health > 0) )
               {
                            if (p.teartime < 225)
				p.Teartime+= 30;
                      if ( TGAS_player(p.owner).Health > 30 )
                                           TGAS_player(p.owner).health -= 3;
                      TGAS_player(p.owner).PainTime = 1.0;
               }
          i++;
          if ( i>40 )
               break;
	}
     }
     i=0;
     foreach AllActors(class's_swat.s_NPCHostage', H)
     {
          if ( VSize(H.Location - Location) < gastime )
               {
		h.TakeDamage (2, s_player(p.owner), Vect(0,0,0), Vect(0,0,0), 'Explosion');
		h.GotoState('Escape');
               }
          i++;
          if ( i>100 )
               break;
     }
}

simulated function Timer()
{

gastime+=19;
	if ( !bExploded )
     Super.Timer();

if ( Level.Netmode != NM_client )
   BlindEffect();

if ( Level.Netmode != NM_DedicatedServer )
   SpawnSomeSmoke();

SetTimer(1.5, false);
}


defaultproperties
{
    bServerTiming=True
    ImpactPitch=0.50
    LifeSpan=34.00
    AmbientSound=Sound'TODatas.Weapons.SmokeGrenSound'
    SoundRadius=64
    SoundVolume=20
}
