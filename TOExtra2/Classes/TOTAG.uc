//
// FilRip Production :)
//
// New mutator to tag decor
// Example command :
// "mutate TAG TOModels.3rdmuzzle3"
// Add the specified texture on wall/floor around the player is
// Destroyed after 20 seconds
//

class TOTAG extends Mutator;

var int CurrentRound;
var() config bool ResetAtAllRound;

function PreBeginPlay()
{
    super.PreBeginPlay();
    SetTimer(1,true);
}

// Main
// THE new mutate command
function Mutate(string MutateString,PlayerPawn Sender)
{
	local TOTagModel NewOne;
	local string texturename;
    local texture TheTex;
    local Actor Wall;
	local vector WallHit, WallNormal;
	local rotator PA;
    local int i;

    if (Sender!=None)
        if (MutateString!="")
            // Is it a command for this mutator
            if (caps(left(MutateString,4))=="TAG ")
            {
                texturename=right(MutateString,len(mutatestring)-4);
//                BroadcastMessage("Texture received : "$texturename);
                TheTex=Texture(DynamicLoadObject(texturename,class'Texture'));
                if (TheTex!=None)
                {
                    Wall=Trace(WallHit,WallNormal,(Sender.Location + vect(0.00,0.00,0.50) * Sender.BaseEyeHeight)+ vector(Sender.ViewRotation)*50,Sender.Location + vect(0.00,0.00,0.50) * Sender.BaseEyeHeight,False);
                    if (Wall.IsA('LevelInfo'))
                    {

// New set rotation function by helmut
/*	if ( WallNormal.x < 0.0 )
	{
		if ( WallNormal.y > 0.0 )
			PA.yaw = 16384+ASin(-WallNormal.x);
		else PA.yaw = -16384+ASin(WallNormal.x);
	}
	else PA.yaw = ASin(WallNormal.y);

	PA.yaw += 16384;

	PA.roll = -16384;
	PA.roll += ASin(WallNormal.z);

	if ( WallNormal.z != 0 )
		PA.yaw += sender.rotation.yaw+32768;  */
// End Helmut function, thx

 /*                       BroadcastMessage("DamienPA : "$string(PA));

                            PA.Pitch=PA.Pitch-16384;
                            PA.Yaw=PA.Yaw+16384;

                        broadcastMessage("WallHit : "$string(WallHit));
                        BroadcastMessage("WallNormal : "$string(WallNormal));
                        BroadcastMessage("PA : "$string(PA));*/
                        NewOne=Spawn(class'TOTagModel',,,WallHit+vect(0,-10,0),rotator(wallnormal)+rot(16384,0,0));
                        if (NewOne!=None)
                            NewOne.MultiSkins[0]=TheTex;
                        else Sender.ClientMessage("Unable to make tag, sorry");
                    } else Sender.ClientMessage("Wall too far away");
                } else Sender.ClientMessage("Tag doesn't exist on this server");
            }

	if (NextMutator!=None)
		NextMutator.Mutate(MutateString,Sender);
}

static final function float ASin  ( float A )
{
  if (A>1||A<-1)
    return 0;
  if (A==1)
    return 16384;
  if (A==-1)
    return -16384;
  return (ATan(A/Sqrt(1-Square(A)))/pi)*32768;
}

function PlaceTag(string tex)
{
}

function Timer()
{
    if (s_SWATGame(Level.Game).GamePeriod==GP_PreRound)
        if (s_SWATGame(Level.Game).RoundNumber!=CurrentRound)
        {
            CurrentRound=s_SWATGame(Level.Game).RoundNumber;
            DelTag();
        }
}

function DelTag()
{
    local TOTAGModel tag;

    foreach AllActors(class'TOTAGModel',tag)
        tag.Destroy();
}

defaultproperties
{
    ResetAtAllRound=True
}

