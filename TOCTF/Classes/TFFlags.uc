class TFFlags extends Decoration;

var vector Home;
var byte Team;
var Pawn Carrier;
var bool IsFree;

replication
{
	reliable if (Role==ROLE_Authority)
        Carrier,IsFree,Team;
}

function Landed(vector HitNormall)
{
}

event FellOutOfWorld()
{
	SetLocation(Home);
	GotoState('HomeBase');
}

function Teleported()
{
    TFMod(Level.Game).ResetAmbientToPlayer(Carrier);
	if (TFPlayerReplicationInfo(Carrier.PlayerReplicationInfo)!=None)
	   TFPlayerReplicationInfo(Carrier.PlayerReplicationInfo).bHasFlag=false;
	if (TFBRI(Carrier.PlayerReplicationInfo)!=None)
	   TFBRI(Carrier.PlayerReplicationInfo).bHasFlag=false;
    Carrier.PlayerReplicationInfo.HasFlag=None;
    TFMod(Level.Game).DropFlag(1-Carrier.PlayerReplicationInfo.Team,Carrier.Location);
	Carrier=None;
}

/*function PlaySoundToAll(sound s)
{
	local Pawn aPlayer;

	for (aPlayer=Level.PawnList;aPlayer!=None;aPlayer=aPlayer.NextPawn)
		if (aPlayer.IsA('TFPlayer'))
			TFPlayer(aPlayer).ClientPlaySound(s,,true);
}*/

state Carrying
{

    event FellOutOfWorld()
    {
    }

	event Touch(Actor Other)
	{
	}

	function BeginState()
	{
        IsFree=false;
        Enable('Tick');
        bCollideWorld=false;
        SetPhysics(PHYS_None);
        SetCollision(false,false,false);
        bHidden=true;
        Carrier.PlayerReplicationInfo.HasFlag=self;
        SetAmbientToPlayer(Carrier);
        TFMod(Level.Game).PlaySoundToAll(Sound'TFModelsF.flagtaken');
        BroadcastLocalizedMessage(class'TFCTFMessage',4,Carrier.PlayerReplicationInfo,None,TFMod(Level.Game).Teams[Team]);
    }
}

function SetAmbientToPlayer(Pawn P)
{
    if (!TFMod(Level.Game).DoGlowOnFlagCarrier) return;
	P.AmbientGlow=255;
	P.LightEffect=LE_NonIncidence;
	P.LightRadius=5;
	P.LightType=LT_Steady;
	P.LightBrightness=255;
	P.LightSaturation=127;
	if (P.PlayerReplicationInfo.Team==0) P.LightHue=170; else P.LightHue=255;
}

auto state HomeBase
{
	event Touch(Actor Other)
	{
		local Pawn P;

		P=Pawn(Other);
		if ((P!=None) && (P.bIsPlayer))
		{
        	if ((P.PlayerReplicationInfo==None) || (P.PlayerReplicationInfo.bIsSpectator) || (P.PlayerReplicationInfo.bWaitingPlayer))
                return;
    		if ((!P.IsA('TFPlayer')) && (!P.IsA('TFBot'))) return;
			if (P.Health>0)
			{
                if (P.PlayerReplicationInfo.Team==Team)
                {
                    // Team number "team" scored. end round
                    if ((TFPlayerReplicationInfo(P.PlayerReplicationInfo)!=None) && (TFPlayerReplicationInfo(P.PlayerReplicationInfo).bHasFlag))
                        BroadcastLocalizedMessage(class'TFCTFMessage',0,P.PlayerReplicationInfo, None, self );
                    if ((TFBRI(P.PlayerReplicationInfo)!=None) && (TFBRI(P.PlayerReplicationInfo).bHasFlag))
                        BroadcastLocalizedMessage(class'TFCTFMessage',0,P.PlayerReplicationInfo, None, self );
                    if (P.PlayerReplicationInfo.HasFlag!=None) TFMod(Level.Game).TeamScored(P);
                    return;
                }
                else
                {
                    // opposite team take the flag
				    if (TFPlayerReplicationInfo(P.PlayerReplicationInfo)!=None)
                        TFPlayerReplicationInfo(P.PlayerReplicationInfo).bHasFlag=true;
				    if (TFBRI(P.PlayerReplicationInfo)!=None)
                        TFBRI(P.PlayerReplicationInfo).bHasFlag=true;
                    Carrier=P;
/*                    P.PlayerReplicationInfo.HasFlag=self;
                    bHidden=true;
                    SetAmbientToPlayer(Pawn(Other));
                    BroadcastLocalizedMessage(class'TFCTFMessage',4,P.PlayerReplicationInfo, None, TFMod(Level.Game).Teams[Team] );*/
                    GotoState('Carrying');
                    return;
				}
			}
		}
	}

	function BeginState()
	{
        IsFree=True;
		bHidden=false;
		bCollideWorld=true;
		SetCollision(true,false,false);
		Velocity.Z=300;
		SetPhysics(PHYS_Falling);
		if (Carrier!=None) Carrier.PlayerReplicationInfo.HasFlag=None;
		Carrier=None;
        if (Team==0) Setlocation(TFMod(Level.Game).TerroBase); else Setlocation(TFMod(Level.Game).SFBase);
	}
}

state Dropped
{
	event Touch(Actor Other)
	{
		local Pawn P;

		P=Pawn(Other);
		if ((P!=None) && (P.bIsPlayer))
		{
    		if ((!P.IsA('TFPlayer')) && (!P.IsA('TFBot'))) return;
        	if ((P.PlayerReplicationInfo==None) || (P.PlayerReplicationInfo.bIsSpectator) || (P.PlayerReplicationInfo.bWaitingPlayer))
                return;
			if (P.Health>0)
			{
    			if (P.PlayerReplicationInfo.Team==Team)
	       		{
			        // Return flag to base
                    BroadcastLocalizedMessage(class'TFCTFMessage',3,P.PlayerReplicationInfo,None,TFMod(Level.Game).Teams[Team]);
			        GotoState('HomeBase');
                    TFMod(Level.Game).PlaySoundToAll(Sound'TFModelsF.ReturnSound');
			        return;
                }
                else
                {
				    // opposite team take the flag
				    if (TFPlayerReplicationInfo(P.PlayerReplicationInfo)!=None)
                        TFPlayerReplicationInfo(P.PlayerReplicationInfo).bHasFlag=true;
				    if (TFBRI(P.PlayerReplicationInfo)!=None)
                        TFBRI(P.PlayerReplicationInfo).bHasFlag=true;
                    Carrier=P;
//                    bHidden=true;
                    GotoState('Carrying');
                    return;
				}
			}
		}
	}

    function Timer()
    {
        GotoState('HomeBase');
        TFMod(Level.Game).PlaySoundToAll(Sound'TFModelsF.ReturnSound');
        return;
    }

	function BeginState()
	{
        IsFree=False;
		bHidden=false;
		bCollideWorld=true;
		SetPhysics(PHYS_Falling);
		SetCollision(true,false,false);
//		Velocity.Z=300;
		if (Carrier!=None) Carrier.PlayerReplicationInfo.HasFlag=None;
		Carrier=None;
		SetTimer(30,false);
	}

	function EndState()
	{
	   Region.Zone.AmbientGlow=0;
	}
}

function PostBeginPlay()
{
	local rotator rp;

	Super.PostBeginPlay();
	LoopAnim('pflag');
	rp.Pitch=0;
	rp.Yaw=0;
	rp.Roll=-7000;
	SetRotation(rp);
}

defaultproperties
{
	Mesh=TFModelsF.pflag
	DrawType=DT_Mesh
	Skin=TFModelsF.JpflagR
	bStatic=False
	DrawScale=0.6
	CollisionRadius=48
	CollisionHeight=30
	bCollideActors=True
	bCollideWorld=True
	LightType=LT_Steady
	LightEffect=LE_NonIncidence
	LightBrightness=255
	LightRadius=6
	Mass=30
	Buoyancy=20
    bAlwaysRelevant=True
    NetPriority=3.000000
}
