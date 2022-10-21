//=============================================================================
// s_Trigger
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================
  
class s_Trigger extends Triggers;

//-----------------------------------------------------------------------------
// Trigger variables.

// Trigger type.
var() enum ETriggerType
{
	TT_PlayerProximity,		// Trigger is activated by player proximity.
	TT_PawnProximity,			// Trigger is activated by any pawn's proximity
	TT_ClassProximity,		// Trigger is activated by actor of that class only
	TT_AnyProximity,			// Trigger is activated by any actor in proximity.
	TT_Shoot,							// Trigger is activated by player shooting it.
	TT_Use,								// Trigger is activated by the use key
} TriggerType;

var() enum ETeams
{
	ET_Terrorists,	
	ET_SpecialForces,	
	ET_Both,					
} ActivatedBy;

var() localized		string	Message;		// Human readable triggering message.

var()	bool		bTriggerOnceOnly;			// Only trigger once and then go dormant.

var() bool		bInitiallyActive;			// For triggers that are activated/deactivated by other triggers.
var		bool		bInitiallyActiveBackup;
var		bool	bFirstTime;

var() class<actor>	ClassProximityType;

var() float	RepeatTriggerTime;	//if > 0, repeat trigger message at this interval is still touching other
var() float ReTriggerDelay;			//minimum time before trigger can be triggered again
var	  float TriggerTime;
var() float DamageThreshold;		//minimum damage to trigger if TT_Shoot

// AI vars
var	actor TriggerActor;					// actor that triggers this trigger
var actor TriggerActor2;

// Enhanced stuffs
var									bool		bActivated;	// If Trigger has already been activated	
var()								bool		bForceRoundPlay;	// If trigger can only be activated during RoundPlaying
var(s_UseTrigger)		bool		bUseRadius;	// Use Radius or Touch()	
var(s_UseTrigger)		float		Radius;			// If Trigger uses Radius instead of CollisionBox

var(s_Trigger)			name		OptionalSWATPathNode; 
var									s_SWATPathNode	TriggerSWATPathNode; 

var	s_Trigger		NextTrigger;


//=============================================================================
// AI related functions


///////////////////////////////////////
// PreBeginPlay 
///////////////////////////////////////

function PreBeginPlay()
{
	local	s_SWATPathNode	SPN;

	if (OptionalSWATPathNode != '')
	{
		foreach AllActors(class 's_SWATPathNode', SPN)
			if (SPN.Tag == OptionalSWATPathNode)
			{
				TriggerSWATPathNode = SPN;
				break;
			}
	}
	
	Super.PreBeginPlay();
}


///////////////////////////////////////
// PostBeginPlay 
///////////////////////////////////////

function PostBeginPlay()
{
	local s_Trigger		T;
	local	s_SWATGame	SW;
	local	int					i;

	bInitiallyActiveBackup = bInitiallyActive;

	if ( !bInitiallyActive )
		FindTriggerActor();

	if ( TriggerType == TT_Shoot )
	{
		bHidden = false;
		bProjTarget = true;
		DrawType = DT_None;
	}
		
	Super.PostBeginPlay();

	SW = s_SWATGame(Level.Game);

	if ( !bFirstTime )
		return;

	bFirstTime = false;

	// Only register usable s_Trigger in s_SWATGame
	if (TriggerType == TT_Use)
	{
		if (SW == None)
			log("s_Trigger - s_SWATGame(Level.Game) == None "$Level.Game);
		else
		{
			if (SW.s_Trigger == None)
			{
				SW.s_Trigger = Self;
				return;
			}

			for ( T=SW.s_Trigger; T!=None; T=T.NextTrigger)
			{
				if ( T.NextTrigger == None )
				{
					T.NextTrigger = self;
					return;
				}
				i++;
				if (i > 200)
					break;
			}
			log("s_Trigger - couldn't register class");
		}
	}
}


///////////////////////////////////////
// FindTriggerActor 
///////////////////////////////////////

function FindTriggerActor()
{
	local Actor A;

	TriggerActor = None;
	TriggerActor2 = None;
	ForEach AllActors(class 'Actor', A)
		if ( A.Event == Tag)
		{
			if ( Counter(A) != None )
				return; //FIXME - handle counters
			if (TriggerActor == None)
				TriggerActor = A;
			else
			{
				TriggerActor2 = A;
				return;
			}
		}
}


///////////////////////////////////////
// SpecialHandling 
///////////////////////////////////////

function Actor SpecialHandling(Pawn Other)
{
	local int i;

	if (bForceRoundPlay && !IsRoundPeriodPlaying())
		return None;

	if ( bTriggerOnceOnly && !bCollideActors )
		return None;

	if ( (TriggerType == TT_PlayerProximity) && !Other.bIsPlayer )
		return None;

	if ( !bInitiallyActive )
	{
		if ( TriggerActor == None )
			FindTriggerActor();
		if ( TriggerActor == None )
			return None;
		if ( (TriggerActor2 != None) 
			&& (VSize(TriggerActor2.Location - Other.Location) < VSize(TriggerActor.Location - Other.Location)) )
			return TriggerActor2;
		else
			return TriggerActor;
	}

	// is this a shootable trigger?
	if ( TriggerType == TT_Shoot )
	{
		if ( !Other.bCanDoSpecial || (Other.Weapon == None) )
			return None;

		Other.Target = self;
		Other.bShootSpecial = true;
		Other.FireWeapon();
		Other.bFire = 0;
		Other.bAltFire = 0;
		return Other;
	}

	// can other trigger it right away?
	if ( IsRelevant(Other) )
	{
		for (i=0;i<4;i++)
			if (Touching[i] == Other)
				Touch(Other);
		return self;
	}

	return self;
}


///////////////////////////////////////
// CheckTouchList 
///////////////////////////////////////

// when trigger gets turned on, check its touch list
function CheckTouchList()
{
	local int i;

	for (i=0;i<4;i++)
		if ( Touching[i] != None )
			Touch(Touching[i]);
}



//=============================================================================
// Trigger states.


///////////////////////////////////////
// NormalTrigger 
///////////////////////////////////////

// Trigger is always active.
state() NormalTrigger
{
}


///////////////////////////////////////
// OtherTriggerToggles 
///////////////////////////////////////

// Other trigger toggles this trigger's activity.
state() OtherTriggerToggles
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if (bForceRoundPlay && !IsRoundPeriodPlaying())
			return;

		bInitiallyActive = !bInitiallyActive;
		if ( bInitiallyActive )
			CheckTouchList();
	}
}


///////////////////////////////////////
// OtherTriggerTurnsOn 
///////////////////////////////////////

// Other trigger turns this on.
state() OtherTriggerTurnsOn
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		local bool bWasActive;

		if (bForceRoundPlay && !IsRoundPeriodPlaying())
			return;

		bWasActive = bInitiallyActive;
		bInitiallyActive = true;
		if ( !bWasActive )
			CheckTouchList();
	}
}


///////////////////////////////////////
// OtherTriggerTurnsOff 
///////////////////////////////////////

// Other trigger turns this off.
state() OtherTriggerTurnsOff
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if (bForceRoundPlay && !IsRoundPeriodPlaying())
			return;

		bInitiallyActive = false;
	}
}



//=============================================================================
// Trigger logic.


///////////////////////////////////////
// IsRelevant 
///////////////////////////////////////

// See whether the other actor is relevant to this trigger.
function bool IsRelevant( actor Other )
{
	if (bForceRoundPlay && !IsRoundPeriodPlaying())
		return false;

	if( !bInitiallyActive )
		return false;

	switch( TriggerType )
	{
		case TT_PlayerProximity:
			return Pawn(Other)!=None && Pawn(Other).bIsPlayer && CanBeActivated(Pawn(Other));
		case TT_PawnProximity:
			return Pawn(Other)!=None && ( Pawn(Other).Intelligence > BRAINS_None ) && CanBeActivated(Pawn(Other));
		case TT_ClassProximity:
			return ClassIsChildOf(Other.Class, ClassProximityType);
		case TT_AnyProximity:
			return true;
		case TT_Shoot:
			return ( (s_Projectile(Other) != None) && (s_Projectile(Other).MaxDamage >= DamageThreshold) );
		case TT_Use:
			return false;
	}
}


///////////////////////////////////////
// CanBeActivated 
///////////////////////////////////////

function bool	CanBeActivated(Pawn Other)
{
	local	byte	TeamNb;
	
	if ( Other.PlayerReplicationInfo == None )
		return false;

	TeamNb = ActivatedBy;
	if ((ActivatedBy == ET_Both) || (TeamNb == Other.PlayerReplicationInfo.Team))
		return true;

	return false;
}


///////////////////////////////////////
// Touch 
///////////////////////////////////////

// Called when something touches the trigger.
function Touch( actor Other )
{
	local actor A;

	if( IsRelevant( Other ) )
	{
		if ( ReTriggerDelay > 0 )
		{
			if ( Level.TimeSeconds - TriggerTime < ReTriggerDelay )
				return;
			TriggerTime = Level.TimeSeconds;
		}
		// Broadcast the Trigger message to all matching actors.
		if( Event != '' )
			foreach AllActors( class 'Actor', A, Event )
				A.Trigger( Other, Other.Instigator );

		if ( Other.IsA('Pawn') && (Pawn(Other).SpecialGoal == self) )
			Pawn(Other).SpecialGoal = None;
				
		if( Message != "" )
			// Send a string message to the toucher.
			Other.Instigator.ClientMessage( Message );

		TriggerObjective();

		if( bTriggerOnceOnly )
			// Ignore future touches.
			SetCollision(False);
		else if ( RepeatTriggerTime > 0 )
			SetTimer(RepeatTriggerTime, false);
	}
}


///////////////////////////////////////
// Timer 
///////////////////////////////////////

function Timer()
{
	local bool bKeepTiming;
	local int i;

	bKeepTiming = false;

	for (i=0;i<4;i++)
		if ( (Touching[i] != None) && IsRelevant(Touching[i]) )
		{
			bKeepTiming = true;
			Touch(Touching[i]);
		}

	if ( bKeepTiming )
		SetTimer(RepeatTriggerTime, false);
}


///////////////////////////////////////
// TakeDamage 
///////////////////////////////////////

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, name damageType)
{
	local actor A;

	if (bForceRoundPlay && !IsRoundPeriodPlaying())
		return;

	if ( bInitiallyActive && (TriggerType == TT_Shoot) && (Damage >= DamageThreshold) && (instigatedBy != None) )
	{
		if ( ReTriggerDelay > 0 )
		{
			if ( Level.TimeSeconds - TriggerTime < ReTriggerDelay )
				return;
			TriggerTime = Level.TimeSeconds;
		}
		// Broadcast the Trigger message to all matching actors.
		if ( Event != '' )
			foreach AllActors( class 'Actor', A, Event )
				A.Trigger( instigatedBy, instigatedBy );

		if ( Message != "" )
			// Send a string message to the toucher.
			instigatedBy.Instigator.ClientMessage( Message );

		if ( bTriggerOnceOnly )
			// Ignore future touches.
			SetCollision(False);

		TriggerObjective();
	}
}


///////////////////////////////////////
// UnTouch 
///////////////////////////////////////

// When something untouches the trigger.
function UnTouch( actor Other )
{
	local actor A;
	if( IsRelevant( Other ) )
	{
		// Untrigger all matching actors.
		if( Event != '' )
			foreach AllActors( class 'Actor', A, Event )
				A.UnTrigger( Other, Other.Instigator );
	}
}


///////////////////////////////////////
// Use
///////////////////////////////////////

// Called when someone 'uses' the trigger.
function Use( actor Other )
{
	local actor A;

	if ( bForceRoundPlay && !IsRoundPeriodPlaying() )
		return;

//	log("s_Trigger - Use");
	if ( !bInitiallyActive || !CanBeActivated(Pawn(Other)) )
		return;

	if ( bTriggerOnceOnly && bActivated )
		return;

	if ( TriggerType == TT_Use )
	{
		Other.PlaySound(Sound'LightSwitch', SLOT_None);
		Other.MakeNoise(1.0);
	}

	bActivated = true;
	if ( ReTriggerDelay > 0 )
	{
		if ( Level.TimeSeconds - TriggerTime < ReTriggerDelay )
			return;
		TriggerTime = Level.TimeSeconds;
	}

	// Broadcast the Trigger message to all matching actors.
	if ( Event != '' )
		foreach AllActors( class 'Actor', A, Event )
			A.Trigger( Other, Other.Instigator );

	if ( Other.IsA('Pawn') && (Pawn(Other).SpecialGoal == self) )
		Pawn(Other).SpecialGoal = None;
				
	if( Message != "" )
		// Send a string message to the toucher.
		Other.Instigator.ClientMessage( Message );

	TriggerObjective();

	if( bTriggerOnceOnly )
		// Ignore future touches.
		SetCollision(False);
	else if ( RepeatTriggerTime > 0 )
		SetTimer(RepeatTriggerTime, false);
}


///////////////////////////////////////
// TriggerObjective
///////////////////////////////////////

function TriggerObjective()
{
	local	s_SWATGame	SG;

	//log("s_Trigger - Trigger Objective");
	SG = s_SWATGame(Level.Game);
	if (SG != None)
		SG.ObjectiveAccomplished(Self);
	else
		log("s_Trigger - TriggerObjective - SG == None");
}
 

///////////////////////////////////////
// ResetTrigger
///////////////////////////////////////

function ResetTrigger()
{
	SetCollision(true);

	//bInitiallyActive = Default.bInitiallyActive;
	bInitiallyActive = bInitiallyActiveBackup;
	
	TriggerTime = Level.TimeSeconds;
	bActivated = false;
	BeginPlay();
	PostBeginPlay();
	Enable('Touch');
	Enable('Trigger');

/*
	//log("s_Trigger - ResetTrigger");
	bInitiallyActive = Default.bInitiallyActive;
	bActivated = false;
//	TriggerTime = 0;
	SetCollision(true);
	TriggerTime = Level.TimeSeconds;

//	BeginPlay();
//	PostBeginPlay();
	
//	Disable('Timer');
	Enable('Touch');
	Enable('Trigger');

	
	//AmbiantSound = None;
*/
}


///////////////////////////////////////
// IsRoundPeriodPlaying
///////////////////////////////////////

function bool IsRoundPeriodPlaying()
{
	local	s_SWATGame	SG;

	SG = s_SWATGame(Level.Game);
	if (SG != None)
	{ 
		if (SG.GamePeriod == GP_RoundPlaying)
			return true;
	}
	else
		log("s_Trigger - IsRoundPeriodPlaying - SG == None");

	return false;
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     ActivatedBy=ET_Both
     bInitiallyActive=True
     bFirstTime=True
     Radius=40.000000
     InitialState=NormalTrigger
     Texture=Texture'TODatas.Engine.SWATTrigger'
}
