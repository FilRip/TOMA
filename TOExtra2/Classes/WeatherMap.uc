class WeatherMap extends Mutator;

var() config string Type;
var() config string MapName[255];
var() config vector MapLocation[255];
var() config bool EnableWeather;

function PreBeginPlay()
{
	local TOExtraRainGenerator SG;
    local vector LocationForThisMap;
    local int i;

    if (!EnableWeather) return;
    for (i=0;i<255;i++)
        if (MapName[i]==Level.Title)
        {
            LocationForThisMap=MapLocation[i];
            Log("MapLocation="$MapLocation[i]);
            Log("NewLoc="$LocationForThisMap);
        }

	SG=Spawn(class'TOExtraRainGenerator');
	SG.SetLocation(LocationForThisMap);
	Log("Create weather type "$Type$" at "$string(LocationForThisMap)$" in map : "$Level.Title);
	if (Type=="rain") SG.RainType=RT_Rain;
	if (Type=="snow") SG.RainType=RT_Snow;
}

defaultproperties
{
    MapName(0)="Scope "
    MapLocation(0)=(X=-269,Y=1,Z=920)
    MapName(1)="RapidWaters]["
    MapLocation(1)=(X=17,Y=-511,Z=526)
    MapName(2)="Blister"
    MapLocation(2)=(X=-2727,Y=-1291,Z=775)
    MapName(3)="CIA"
    MapLocation(3)=(X=1152,Y=350,Z=-1979)
    MapName(4)="TO-Conundrum"
    MapLocation(4)=(X=-1298,Y=3214,Z=1477)
    MapName(5)="TO-Dragon"
    MapLocation(5)=(X=-1623,Y=416,Z=0)
    MapName(6)="Deadly Drought"
    MapLocation(6)=(X=-127,Y=603,Z=709)
    MapName(7)="Eskero"
    MapLocation(7)=(X=-1567,Y=1518,Z=1336)
    MapName(8)="Forge"
    MapLocation(8)=(X=184,Y=-4094,Z=8)
    MapName(9)="Operation FrozenScar"
    MapLocation(9)=(X=158,Y=-1049,Z=476)
    MapName(10)="The Getaway"
    MapLocation(10)=(X=-264,Y=-562,Z=-639)
    MapName(11)="Monastery"
    MapLocation(11)=(X=-18,Y=-323,Z=857)
    MapName(12)="Oilrig"
    MapLocation(12)=(X=-1379,Y=337,Z=1728)
    MapName(13)="Resurrection"
    MapLocation(13)=(X=-448,Y=-8,Z=-57)
    MapName(14)="Spynet by Night"
    MapLocation(14)=(X=2462,Y=6931,Z=981)
    MapName(15)="Terrorist's Mansion"
    MapLocation(15)=(X=-161,Y=910,Z=461)
    MapName(16)="Thanassos"
    MapLocation(16)=(X=931,Y=-2961,Z=1172)
    MapName(17)="Thunderball"
    MapLocation(17)=(X=3656,Y=-111,Z=706)
    MapName(18)="Tirojonpi"
    MapLocation(18)=(X=1,Y=0,Z=606)
    MapName(19)="Yarmouth Trainstation"
    MapLocation(19)=(X=2082,Y=602,Z=402)
    MapName(20)="Trooper ]["
    MapLocation(20)=(X=720,Y=416,Z=801)
    MapName(21)="Unbreakable"
    MapLocation(21)=(X=-815,Y=-5391,Z=1050)
    MapName(22)="Assault on Verdon"
    MapLocation(22)=(X=-292,Y=-3912,Z=2735)
    MapName(23)="-2- Alpia"
    MapLocation(23)=(X=461,Y=-830,Z=-108)
    MapName(24)="-2- Ambush"
    MapLocation(24)=(X=53,Y=-45,Z=311)
    MapName(25)="-2- Arena"
    MapLocation(25)=(X=-125,Y=-32,Z=765)
    MapName(26)="-2- Bridge"
    MapLocation(26)=(X=773,Y=-174,Z=-936)
    MapName(27)="-2- Broken Faith"
    MapLocation(27)=(X=8,Y=-5,Z=193)
    MapName(28)="-2- Chicago"
    MapLocation(28)=(X=3547,Y=-1553,Z=1207)
    MapName(29)="-2- Chiesa"
    MapLocation(29)=(X=-21,Y=-24,Z=539)
    MapName(30)="-2- A Cold Day"
    MapLocation(30)=(X=-464,Y=-432,Z=208)
    MapName(31)="-2- Crossmaglen"
    MapLocation(31)=(X=0,Y=-9,Z=555)
    MapName(32)="-2- Equinox"
    MapLocation(32)=(X=-1,Y=-595,Z=-53)
    MapName(33)="-2- Slow Water"
    MapLocation(33)=(X=1955,Y=-81,Z=799)
    MapName(34)="-2- Toscana"
    MapLocation(34)=(X=180,Y=-49,Z=634)
    MapName(35)="-X- Baxtown"
    MapLocation(35)=(X=1664,Y=938,Z=903)
    MapName(36)="-X- Belfast"
    MapLocation(36)=(X=-249,Y=-1013,Z=1126)
    MapName(37)="-X- Operation Deadly Dusk"
    MapLocation(37)=(X=-1210,Y=-1377,Z=1076)
    MapName(38)="-X- DrugIsle"
    MapLocation(38)=(X=200,Y=-187,Z=-657)
    MapName(39)="-X- C4-Entrepot2-2"
    MapLocation(39)=(X=-3738,Y=-3536,Z=178)
    MapName(40)="-X- Extraction "
    MapLocation(40)=(X=-773,Y=-133,Z=521)
    MapName(41)="-X- Moving Day Massacre"
    MapLocation(41)=(X=-906,Y=595,Z=1105)
    MapName(42)="-X- Petronas Towers"
    MapLocation(42)=(X=2845,Y=-2459,Z=1169)
    MapName(43)="-X- Province"
    MapLocation(43)=(X=-1222,Y=-285,Z=338)
    MapName(44)="-X- Revolution"
    MapLocation(44)=(X=1247,Y=-1381,Z=7861)
    MapName(45)="-X- RMS Titanic"
    MapLocation(45)=(X=608,Y=8,Z=705)
    MapName(46)="-X- Salsa"
    MapLocation(46)=(X=592,Y=-177,Z=850)
    MapName(47)="-X- Singa"
    MapLocation(47)=(X=-970,Y=-2458,Z=711)
    MapName(48)="-X- SubwayStandoff"
    MapLocation(48)=(X=-2150,Y=56,Z=354)
    MapName(49)="-X- Sunset"
    MapLocation(49)=(X=152,Y=445,Z=1372)
    MapName(50)="-X- Texas Bank"
    MapLocation(50)=(X=221,Y=1594,Z=113)
    Type="rain"
    EnableWeather=true
}

