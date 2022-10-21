class s_RainGenerator extends TacticalOpsMapActors;

var int NumberOfDrips;
var float interval;
var float variance;
enum ERainType {
	RT_Rain,
	RT_Snow
};
var ERainType RainType;
var float DropSpeed;
var bool bMeshRainDrop;
var s_RainGenerator NextRGLink;
var int dropradius;
var bool bJerky;
var int Jerkyness;


defaultproperties
{
}

