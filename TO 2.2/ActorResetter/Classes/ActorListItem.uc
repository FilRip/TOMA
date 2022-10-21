//=============================================================================
//   ActorListItem
//=============================================================================
//
//   description:
//   this class provides actor management functions needed for round-based
//   map resetting
//
//   Source code rights:
//   Copyright (C) 2000 Gerke "j3rky" Preussner (j3rky@gerke-preussner.de)
//
//=============================================================================


class ActorListItem extends Actor;

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
   variables
================
*/

var ActorListItem		Next;

var Actor			Entity;
var EActorListItemType		Type;

var int				iBuff;
var name			nBuff;
var bool			bBuff;
var Actor			aBuff;

defaultproperties
{
}
