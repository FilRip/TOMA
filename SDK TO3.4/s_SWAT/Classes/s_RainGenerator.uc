class s_RainGenerator extends TacticalOpsMapActors;

enum ERainType
{
	RT_Rain,
	RT_Snow
};

var() float interval;
var() float variance;
var() float DropSpeed;
var() int dropradius;
var() int NumberOfDrips;
var() ERainType RainType;
var(Rain) bool bMeshRainDrop;
var(Snow) bool bJerky;
var(Snow) int Jerkyness;
var s_RainGenerator NextRGLink;
