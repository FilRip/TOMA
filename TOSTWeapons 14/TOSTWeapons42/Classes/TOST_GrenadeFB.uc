//----------------------------------------------------------------------------
// Project : TOST
// File    : TOST_GrenadeFB.uc
// Version : 0.5
// Author  : BugBunny/Shag
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
//----------------------------------------------------------------------------

class TOST_GrenadeFB extends TOSTGrenade;

function GrenadeThrown()
{
	local	Pawn	PawnOwner;

	PawnOwner = Pawn(Owner);
	if ( PawnOwner == None )
		return;

	if ( FRand() < 0.5 )
		PawnOwner.PlaySound(class<TO_VoicePack>(PawnOwner.PlayerReplicationInfo.VoiceType).default.OtherSound[11], Slot_Talk, 128.0, true);
	else
		PawnOwner.PlaySound(class<TO_VoicePack>(PawnOwner.PlayerReplicationInfo.VoiceType).default.OtherSound[12], Slot_Talk, 128.0, true);
}

defaultproperties
{
	NadeModeEnabled=true

	PlayerViewOffset=(X=170.000000,Y=190.000000,Z=-270.000000)
	PlayerViewMesh=SkeletalMesh'TOModels.GrenflashMesh'
	PlayerViewScale=0.12
	Price=400
	WeaponDescription="Classification: Level 3 FlashBang Grenade"
	PickupMessage="You picked up a Flashbang !"
	ItemName="Flashbang"
	PickupViewMesh=LodMesh'TOModels.wgrenadeflash'
	ThirdPersonMesh=LodMesh'TOModels.wgrenadeflash'

	NadeAwayClass=class'TOST_FlashBang'

	SolidTex=texture'TOST4TexSolid.HUD.Flash'
	TransTex=texture'TOST4TexTrans.HUD.Flash'
}

