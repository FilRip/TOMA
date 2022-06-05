class TO_GlassMover extends Mover;

var() float Width;
var() float Height;
var() float Strength;
var() Texture GlassTexture;
var() Sound BreakingSound;
var() float FragmentArea;
var float remainingStrength;
var Vector fragmentLocation;

function PreBeginPlay ()
{
}

function BeginPlay ()
{
}

function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
{
}

auto state() IsResetableActor extends TriggerToggle
{
}

function bool HandleTriggerDoor (Pawn Other)
{
}

function bool HandleDoor (Pawn Other)
{
}
