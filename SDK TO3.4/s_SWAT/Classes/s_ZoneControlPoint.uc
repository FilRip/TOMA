class s_ZoneControlPoint extends NavigationPoint;

var(to) byte OwnedTeam;
var(to) bool bBuyPoint;
var(to) bool bRescuePoint;
var(to) bool bHomeBase;
var(to) bool bEscapeZone;
var(to) bool bHostageHidingPlace;
var(to) bool bBombingZone;
var(Obsolete) float Radius;
var Pawn PL[32];
var s_ZoneControlPoint NextZCP;

function PostBeginPlay ()
{
}
