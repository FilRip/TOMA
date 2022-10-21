//=============================================================================
//   ActorList v1.6
//=============================================================================
//
//   description:
//   this class provides actor management functions needed for round-based
//   map resetting
//
//   supported classes:
//   - Mover, AssertMover, AttachMover, ElevatorMover, MixMover, RotatingMover
//   - BioFear, CodeTrigger, Counter, Dispatcher, DistanceViewTrigger,
//     ElevatorTrigger, FadeViewTrigger, TriggeredDeath, FearSpot, Jumper,
//     Kicker, MusicEvent, RoundRobin, StochasticTrigger, TranslatorEvent(?),
//     TriggeredTexture
//   - Trigger, TeamTrigger, ZoneTrigger
//   - ExplodingWall, ExplosionChain
//   - SpotLight, TriggerLight, DistantLightning, QueenTeleportLight,
//     ChargeLight, SightLight, TorchFlame, WeaponLight
//
//   critical:
//   - TimedTrigger, TriggeredDeath('Tick'?)
//
//   Source code rights:
//   Copyright (C) 2000 Gerke "j3rky" Preussner (j3rky@gerke-preussner.de)
//
//   history:
//   - client-side Mover resetting fixed in v1.6
//   - TriggerLight resetting changed in v1.6
//   - Dispatcher resetting between 2 rounds fixed in v1.5
//   - Trigger resetting fixed in v1.4 (thx to Mathieu 'EMH_Mark3' Mallet)
//   - Dispatcher resetting fixed in v1.3 (thx to Mathieu 'EMH_Mark3' Mallet)
//   - TriggerLight resetting fixed in v1.3 (thx to Laurent 'Shag' Delayen)
//
//=============================================================================

class ActorList extends Actor;

/*
================
   properties
================
*/

var ActorListItem			Items;
var int					numTriggered;

/*
================
   enums
================
*/

enum EActorListItemType
{
	ALIT_MOVER,
	ALIT_DECORATION,
	ALIT_CUSTOM,
	ALIT_TRIGGER,
	ALIT_TRIGGERS,
	ALIT_EFFECTS,
	ALIT_LIGHT
};

/*
================
   events
================
*/

function Tick (float DeltaTime)
{
	local ActorListItem		i;
	local Fragment			f;


	// hide destroyed decos
	foreach AllActors(class'Fragment', f) {
		if ( (f.Owner != none) && f.Owner.IsA('ActorListItem') && !ActorListItem(f.Owner).Entity.bHidden ) {
			ActorListItem(f.Owner).Entity.bHidden = true;
			ActorListItem(f.Owner).Entity.SetCollision(false);
			numTriggered--;
		}

		if (numTriggered == 0) break;
	}

	numTriggered = 0;
	Disable('Tick');
}

function Trigger (actor Other, pawn EventInstigator)
{
	// a deco has been destroyed
	numTriggered++;
	Enable('Tick');
}

/*
================
   methods
================
*/

/////////////////
//  helpers
/////////////////

function Bool MatchNative (actor a, EActorListItemType type)
{
	local String		name;
	local int		pos;


	name = String(a.Class);

	pos = InStr(name, ".");
	while (pos != -1) {
		name = Right(name, Len(name) - pos - 1);
		pos = InStr(name, ".");
	}

	switch(type) {
		case ALIT_MOVER:	if(	(name  == "Mover") ||
						(name  == "AssertMover") ||
						(name  == "AttachMover") ||
						(name  == "ElevatorMover") ||
						(name  == "MixMover") ||
						(name  == "RotatingMover"))
						return true;
					break;

		case ALIT_TRIGGERS:	if(	(name  == "BioFear") ||
						(name  == "CodeTrigger") ||
						(name  == "Counter") ||
						(name  == "Dispatcher") ||
						(name  == "DistanceViewTrigger") ||
						(name  == "ElevatorTrigger") ||
						(name  == "FadeViewTrigger") ||
						(name  == "TriggeredDeath") ||
						(name  == "FearSpot") ||
						(name  == "Jumper") ||
						(name  == "Kicker") ||
						(name  == "MusicEvent") ||
						(name  == "RoundRobin") ||
						(name  == "StochasticTrigger") ||
						(name  == "TranslatorEvent") ||
						(name  == "Trigger") ||
						(name  == "TriggeredTexture"))
						return true;
					break;

		case ALIT_LIGHT:	if(	(name == "TriggerLight") ||
						(name == "DistanceLightning") ||
						(name == "ChargeLight"))
						return true;
					break;

   }
}

/////////////////
//  backup
/////////////////

function BackupAll ()
{
	local ActorListItem		item;
	local Actor			a;


	foreach AllActors(class'Actor', a)
	{
		// custom
		if (String(a.InitialState) == "IsResetableActor") {
			item = Spawn(class'ActorResetter.ActorListItem', self);
			item.Type = ALIT_CUSTOM;
		}
		// mover
		else if ( a.IsA('Mover') && MatchNative(a, ALIT_MOVER) ) {
			item = Spawn(class'ActorResetter.ActorListItem', self);
			item.iBuff = Mover(a).KeyNum;
			item.nBuff = Mover(a).InitialState;
			item.Type = ALIT_MOVER;
		}
		// triggers
		else if ( a.IsA('Triggers') && MatchNative(a, ALIT_TRIGGERS) ) {
			item = Spawn(class'ActorResetter.ActorListItem', self);
			if (a.IsA('Trigger')) item.bBuff = Trigger(a).bInitiallyActive;
			if (a.IsA('FearSpot')) item.bBuff = FearSpot(a).bInitiallyActive;
			item.Type = ALIT_TRIGGERS;
		}
		// effects
		else if (a.IsA('Effects')) {
			item = Spawn(class'ActorResetter.ActorListItem', self);
			item.Type = ALIT_EFFECTS;
		}
		// decoration
		else if ( a.IsA('Decoration') && !a.bHidden && a.bNoDelete ) {
			item = Spawn(class'ActorResetter.ActorListItem', self);
			a.SetOwner(item);
			item.SetLocation(a.Location);
			item.SetRotation(a.Rotation);
			item.Type = ALIT_DECORATION;
		}
		// lights
		else if ( a.IsA('Light') && MatchNative(a, ALIT_LIGHT) ) {
			item = Spawn(class'ActorResetter.ActorListItem', self);
			item.Type = ALIT_LIGHT;
		}

		// add to list
		if (item != none) {
			item.Entity = a;
			item.bHidden = true;

			if (Items == none)
				Items = item;
			else {
				item.Next = Items;
				Items = item;
			}
		}

		item = none;
	}

	// init
	Tag = 'RecoverMe';
	numTriggered = 0;
}

/////////////////
//  recover
/////////////////

function RecoverAll ()
{
	local ActorListItem		i;
	local Dispatcher		d;
	local int			j;


	i = Items;
	while (i != none)
	{
		// reset actor unspecific parts
		i.Entity.TimerRate = 0;

		// reset actor specif parts
		switch(i.Type)
		{
			case ALIT_CUSTOM:	i.Entity.BeginPlay();
						break;

			case ALIT_MOVER:	Mover(i.Entity).InterpolateTo(i.iBuff, 0.005);
						Mover(i.Entity).KeyNum = i.iBuff;
						Mover(i.Entity).PrevKeyNum = i.iBuff;
						Mover(i.Entity).GotoState(i.nBuff);

						Mover(i.Entity).BeginPlay();
						Mover(i.Entity).PostBeginPlay();

						Mover(i.Entity).Enable('Bump');
						Mover(i.Entity).Enable('Attach');
						Mover(i.Entity).Enable('Trigger');
						Mover(i.Entity).Enable('UnTrigger');

						Mover(i.Entity).numTriggerEvents = 0;
						Mover(i.Entity).bOpening = false;
						Mover(i.Entity).bDelaying = false;
						Mover(i.Entity).WaitingPawn = none;
						Mover(i.Entity).AmbientSound = none;
						Mover(i.Entity).SavedTrigger = none;
						break;

			case ALIT_DECORATION:	Decoration(i.Entity).SetLocation(i.Location);
						Decoration(i.Entity).SetRotation(i.Rotation);
						Decoration(i.Entity).SetCollision(true);
						Decoration(i.Entity).bHidden = false;

						if (i.Entity.IsA('Pylon')) Pylon(i.Entity).bFirstHit = false;
						break;

			case ALIT_TRIGGERS:	Triggers(i.Entity).SetCollision(true);

						if (i.Entity.IsA('Counter')) Counter(i.Entity).Reset();
						else if (i.Entity.IsA('Dispatcher'))
						{
							// Dispatcher(i.Entity).GotoState('');
							d = Spawn(class'Dispatcher', self);
							d.Tag = Dispatcher(i.Entity).Tag;
							for (j = 0; j < 8; j++)
							{
								d.OutEvents[j] = Dispatcher(i.Entity).OutEvents[j];
								d.OutDelays[j] = Dispatcher(i.Entity).OutDelays[j];
							}

							Dispatcher(i.Entity).Destroy();
							i.Entity = d;
						}
						else if (i.Entity.IsA('Trigger'))
						{
							Trigger(i.Entity).bInitiallyActive = i.bBuff;
							Trigger(i.Entity).TriggerTime = Level.TimeSeconds;
						}
						else if (i.Entity.IsA('FearSpot')) FearSpot(i.Entity).bInitiallyActive = i.bBuff;

						Triggers(i.Entity).BeginPlay();
						Triggers(i.Entity).PostBeginPlay();

						Triggers(i.Entity).Enable('Touch');
						Triggers(i.Entity).Enable('Trigger');
						break;

			case ALIT_EFFECTS:	if (i.Entity.IsA('ExplodingWall')) ExplodingWall(i.Entity).GotoState('Exploding');
						else if (i.Entity.IsA('ExplosionChain')) ExplosionChain(i.Entity).GotoState('');
						break;

			case ALIT_LIGHT:	if (i.Entity.IsA('TriggerLight')) {
							TriggerLight(i.Entity).Disable('Timer');
							TriggerLight(i.Entity).Disable('Tick');
							TriggerLight(i.Entity).SavedTrigger = None;
	
							if ( TriggerLight(i.Entity).bInitiallyOn )
							{
								TriggerLight(i.Entity).Alpha     = 1.0;
								TriggerLight(i.Entity).Direction = 1.0;
								TriggerLight(i.Entity).LightBrightness = TriggerLight(i.Entity).InitialBrightness;
							}
							else
							{
								TriggerLight(i.Entity).Alpha     = 0.0;
								TriggerLight(i.Entity).Direction = -1.0;
								TriggerLight(i.Entity).LightBrightness = 0;
							}

						}
						else i.Entity.BeginPlay();
						break;
		}

		i = i.Next;
	}
}

/*
================
   default
================
*/

defaultproperties
{
     bHidden=True
     Tag=RecoverMe
}
