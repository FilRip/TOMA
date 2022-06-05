class TO_Ladder extends NavigationPoint;

var Bot PendingBot;
var() config name LadderTopTag;
var() config name LadderBottomTag;
var() Sound ClimbingSounds[4];
var() bool bUseCustomSounds;
var TO_LadderEnd LadderTop;
var TO_LadderEnd LadderBottom;

function PostBeginPlay ()
{
}
