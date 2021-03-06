//=============================================================================
// ParentBlob.
//=============================================================================
class TOMAParentBlob extends TOMAFlockMasterPawn config(TOMA);

var bool bEnemyVisible;
var int numBlobs;
var	TOMAbloblet blobs[16]; 
var localized string BlobKillMessage;

function setMovementPhysics()
{
	SetPhysics(PHYS_Spider);
}

function string KillMessage(name damageType, pawn Other)
{
	return(BlobKillMessage);
}

function Shrink(TOMAbloblet b)
{
	local int i,j;
	
	for (i=0; i<numBlobs; i++ )
		if ( blobs[i] == b )
			break;
	numBlobs--;
	for (j=i;j<numBlobs; j++ )
		blobs[j] = blobs[j+1];
	if (numBlobs == 0)
		Destroy();
	else
		SetRadius();
}

function SetRadius()
{
	local int i;
	local float size;
	
	size = 24 + 1.5 * numBlobs;
	for (i=0; i<numBlobs; i++)
		blobs[i].Orientation = size * vector(rot(0,65536,0) * i/numBlobs);
}
	
function PreSetMovement()
{
	bCanWalk = true;
	bCanSwim = true;
	bCanFly = false;
	MinHitWall = -0.6;
}


function BaseChange()
{
}

function Killed(pawn Killer, pawn Other, name damageType)
{
	local int i;

	if (Other == Enemy)
	{
		for (i=0; i<numBlobs; i++ )
			blobs[i].GotoState('Sleep');
		GotoState('stasis');
	}
}

auto state stasis
{
ignores EncroachedBy, EnemyNotVisible;
	
	function SeePlayer(Actor SeenPlayer)
	{
		local tomabloblet b;
		local pawn aPawn;
		local int i;

		if ( numBlobs == 0)
		{
			aPawn = Level.PawnList;
			while ( aPawn != None )
			{
				b = tomabloblet(aPawn);
				if ((b!=None) && (b.tag==tag))
				{
					if (b.parentblob==None)
					{
						blobs[numBlobs] = b;
						numBlobs++;
						b.parentBlob = self;
						b.GotoState('Active');
					}
				}
				if (numBlobs < 15)
					aPawn = aPawn.nextPawn;
				else
					aPawn = None;
			}
			SetRadius();
		}
		enemy = Pawn(SeenPlayer);
		bEnemyVisible = true;
		Gotostate('Attacking');
	}

Begin:
	SetPhysics(PHYS_None);
}

state Attacking
{
	function Timer()
	{
		local int i;

		Enemy = None;
		for (i=0; i<numBlobs; i++ )
			blobs[i].GotoState('asleep');
		GotoState('Stasis');
	}

	function Tick(float DeltaTime)
	{
		local int i;
		
		for (i=0; i<numBlobs; i++ )
			if ( blobs[i].MoveTarget == None )
				blobs[i].Destination = Location + blobs[i].Orientation;
	}
	
	function SeePlayer(Actor SeenPlayer)
	{
		Disable('SeePlayer');
		Enable('EnemyNotVisible');
		bEnemyVisible = true;
		SetTimer(0, false);
	}
	
	function EnemyNotVisible()
	{
		Disable('EnemyNotVisible');
		Enable('SeePlayer');
		bEnemyVisible = false;
		SetTimer(35, false);
	}
		
Begin:
	SetPhysics(PHYS_Spider);
	
Chase:
	if (bEnemyVisible)
		MoveToward(Enemy);
	else
		MoveTo(LastSeenPos);

	Sleep(0.1);
	Goto('Chase');
}

defaultproperties
{
     BlobKillMessage="was corroded by a Blob"
     GroundSpeed=150
     WaterSpeed=150
     AccelRate=800
     JumpZ=-1
     MaxStepHeight=50
     SightRadius=1000
     PeripheralVision=-5
     HearingThreshold=50
     bHidden=True
     Tag=blob1
     NameOfMonster="Blob"
}
